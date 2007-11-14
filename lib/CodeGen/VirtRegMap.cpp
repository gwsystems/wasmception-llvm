//===-- llvm/CodeGen/VirtRegMap.cpp - Virtual Register Map ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the VirtRegMap class.
//
// It also contains implementations of the the Spiller interface, which, given a
// virtual register map and a machine function, eliminates all virtual
// references by replacing them with physical register references - adding spill
// code as necessary.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "spiller"
#include "VirtRegMap.h"
#include "llvm/Function.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/SSARegMap.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Compiler.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallSet.h"
#include <algorithm>
using namespace llvm;

STATISTIC(NumSpills, "Number of register spills");
STATISTIC(NumReMats, "Number of re-materialization");
STATISTIC(NumDRM   , "Number of re-materializable defs elided");
STATISTIC(NumStores, "Number of stores added");
STATISTIC(NumLoads , "Number of loads added");
STATISTIC(NumReused, "Number of values reused");
STATISTIC(NumDSE   , "Number of dead stores elided");
STATISTIC(NumDCE   , "Number of copies elided");

namespace {
  enum SpillerName { simple, local };

  static cl::opt<SpillerName>
  SpillerOpt("spiller",
             cl::desc("Spiller to use: (default: local)"),
             cl::Prefix,
             cl::values(clEnumVal(simple, "  simple spiller"),
                        clEnumVal(local,  "  local spiller"),
                        clEnumValEnd),
             cl::init(local));
}

//===----------------------------------------------------------------------===//
//  VirtRegMap implementation
//===----------------------------------------------------------------------===//

VirtRegMap::VirtRegMap(MachineFunction &mf)
  : TII(*mf.getTarget().getInstrInfo()), MF(mf), 
    Virt2PhysMap(NO_PHYS_REG), Virt2StackSlotMap(NO_STACK_SLOT),
    Virt2ReMatIdMap(NO_STACK_SLOT), ReMatMap(NULL),
    ReMatId(MAX_STACK_SLOT+1) {
  grow();
}

void VirtRegMap::grow() {
  unsigned LastVirtReg = MF.getSSARegMap()->getLastVirtReg();
  Virt2PhysMap.grow(LastVirtReg);
  Virt2StackSlotMap.grow(LastVirtReg);
  Virt2ReMatIdMap.grow(LastVirtReg);
  ReMatMap.grow(LastVirtReg);
}

int VirtRegMap::assignVirt2StackSlot(unsigned virtReg) {
  assert(MRegisterInfo::isVirtualRegister(virtReg));
  assert(Virt2StackSlotMap[virtReg] == NO_STACK_SLOT &&
         "attempt to assign stack slot to already spilled register");
  const TargetRegisterClass* RC = MF.getSSARegMap()->getRegClass(virtReg);
  int frameIndex = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
                                                        RC->getAlignment());
  Virt2StackSlotMap[virtReg] = frameIndex;
  ++NumSpills;
  return frameIndex;
}

void VirtRegMap::assignVirt2StackSlot(unsigned virtReg, int frameIndex) {
  assert(MRegisterInfo::isVirtualRegister(virtReg));
  assert(Virt2StackSlotMap[virtReg] == NO_STACK_SLOT &&
         "attempt to assign stack slot to already spilled register");
  assert((frameIndex >= 0 ||
          (frameIndex >= MF.getFrameInfo()->getObjectIndexBegin())) &&
         "illegal fixed frame index");
  Virt2StackSlotMap[virtReg] = frameIndex;
}

int VirtRegMap::assignVirtReMatId(unsigned virtReg) {
  assert(MRegisterInfo::isVirtualRegister(virtReg));
  assert(Virt2ReMatIdMap[virtReg] == NO_STACK_SLOT &&
         "attempt to assign re-mat id to already spilled register");
  Virt2ReMatIdMap[virtReg] = ReMatId;
  return ReMatId++;
}

void VirtRegMap::assignVirtReMatId(unsigned virtReg, int id) {
  assert(MRegisterInfo::isVirtualRegister(virtReg));
  assert(Virt2ReMatIdMap[virtReg] == NO_STACK_SLOT &&
         "attempt to assign re-mat id to already spilled register");
  Virt2ReMatIdMap[virtReg] = id;
}

void VirtRegMap::virtFolded(unsigned VirtReg, MachineInstr *OldMI,
                            unsigned OpNo, MachineInstr *NewMI) {
  // Move previous memory references folded to new instruction.
  MI2VirtMapTy::iterator IP = MI2VirtMap.lower_bound(NewMI);
  for (MI2VirtMapTy::iterator I = MI2VirtMap.lower_bound(OldMI),
         E = MI2VirtMap.end(); I != E && I->first == OldMI; ) {
    MI2VirtMap.insert(IP, std::make_pair(NewMI, I->second));
    MI2VirtMap.erase(I++);
  }

  ModRef MRInfo;
  const TargetInstrDescriptor *TID = OldMI->getInstrDescriptor();
  if (TID->getOperandConstraint(OpNo, TOI::TIED_TO) != -1 ||
      TID->findTiedToSrcOperand(OpNo) != -1) {
    // Folded a two-address operand.
    MRInfo = isModRef;
  } else if (OldMI->getOperand(OpNo).isDef()) {
    MRInfo = isMod;
  } else {
    MRInfo = isRef;
  }

  // add new memory reference
  MI2VirtMap.insert(IP, std::make_pair(NewMI, std::make_pair(VirtReg, MRInfo)));
}

void VirtRegMap::virtFolded(unsigned VirtReg, MachineInstr *MI, ModRef MRInfo) {
  MI2VirtMapTy::iterator IP = MI2VirtMap.lower_bound(MI);
  MI2VirtMap.insert(IP, std::make_pair(MI, std::make_pair(VirtReg, MRInfo)));
}

void VirtRegMap::print(std::ostream &OS) const {
  const MRegisterInfo* MRI = MF.getTarget().getRegisterInfo();

  OS << "********** REGISTER MAP **********\n";
  for (unsigned i = MRegisterInfo::FirstVirtualRegister,
         e = MF.getSSARegMap()->getLastVirtReg(); i <= e; ++i) {
    if (Virt2PhysMap[i] != (unsigned)VirtRegMap::NO_PHYS_REG)
      OS << "[reg" << i << " -> " << MRI->getName(Virt2PhysMap[i]) << "]\n";

  }

  for (unsigned i = MRegisterInfo::FirstVirtualRegister,
         e = MF.getSSARegMap()->getLastVirtReg(); i <= e; ++i)
    if (Virt2StackSlotMap[i] != VirtRegMap::NO_STACK_SLOT)
      OS << "[reg" << i << " -> fi#" << Virt2StackSlotMap[i] << "]\n";
  OS << '\n';
}

void VirtRegMap::dump() const {
  print(DOUT);
}


//===----------------------------------------------------------------------===//
// Simple Spiller Implementation
//===----------------------------------------------------------------------===//

Spiller::~Spiller() {}

namespace {
  struct VISIBILITY_HIDDEN SimpleSpiller : public Spiller {
    bool runOnMachineFunction(MachineFunction& mf, VirtRegMap &VRM);
  };
}

bool SimpleSpiller::runOnMachineFunction(MachineFunction &MF, VirtRegMap &VRM) {
  DOUT << "********** REWRITE MACHINE CODE **********\n";
  DOUT << "********** Function: " << MF.getFunction()->getName() << '\n';
  const TargetMachine &TM = MF.getTarget();
  const MRegisterInfo &MRI = *TM.getRegisterInfo();

  // LoadedRegs - Keep track of which vregs are loaded, so that we only load
  // each vreg once (in the case where a spilled vreg is used by multiple
  // operands).  This is always smaller than the number of operands to the
  // current machine instr, so it should be small.
  std::vector<unsigned> LoadedRegs;

  for (MachineFunction::iterator MBBI = MF.begin(), E = MF.end();
       MBBI != E; ++MBBI) {
    DOUT << MBBI->getBasicBlock()->getName() << ":\n";
    MachineBasicBlock &MBB = *MBBI;
    for (MachineBasicBlock::iterator MII = MBB.begin(),
           E = MBB.end(); MII != E; ++MII) {
      MachineInstr &MI = *MII;
      for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
        MachineOperand &MO = MI.getOperand(i);
        if (MO.isRegister() && MO.getReg())
          if (MRegisterInfo::isVirtualRegister(MO.getReg())) {
            unsigned VirtReg = MO.getReg();
            unsigned PhysReg = VRM.getPhys(VirtReg);
            if (!VRM.isAssignedReg(VirtReg)) {
              int StackSlot = VRM.getStackSlot(VirtReg);
              const TargetRegisterClass* RC =
                MF.getSSARegMap()->getRegClass(VirtReg);

              if (MO.isUse() &&
                  std::find(LoadedRegs.begin(), LoadedRegs.end(), VirtReg)
                  == LoadedRegs.end()) {
                MRI.loadRegFromStackSlot(MBB, &MI, PhysReg, StackSlot, RC);
                LoadedRegs.push_back(VirtReg);
                ++NumLoads;
                DOUT << '\t' << *prior(MII);
              }

              if (MO.isDef()) {
                MRI.storeRegToStackSlot(MBB, next(MII), PhysReg, StackSlot, RC);
                ++NumStores;
              }
            }
            MF.setPhysRegUsed(PhysReg);
            MI.getOperand(i).setReg(PhysReg);
          } else {
            MF.setPhysRegUsed(MO.getReg());
          }
      }

      DOUT << '\t' << MI;
      LoadedRegs.clear();
    }
  }
  return true;
}

//===----------------------------------------------------------------------===//
//  Local Spiller Implementation
//===----------------------------------------------------------------------===//

namespace {
  class AvailableSpills;

  /// LocalSpiller - This spiller does a simple pass over the machine basic
  /// block to attempt to keep spills in registers as much as possible for
  /// blocks that have low register pressure (the vreg may be spilled due to
  /// register pressure in other blocks).
  class VISIBILITY_HIDDEN LocalSpiller : public Spiller {
    SSARegMap *RegMap;
    const MRegisterInfo *MRI;
    const TargetInstrInfo *TII;
  public:
    bool runOnMachineFunction(MachineFunction &MF, VirtRegMap &VRM) {
      RegMap = MF.getSSARegMap();
      MRI = MF.getTarget().getRegisterInfo();
      TII = MF.getTarget().getInstrInfo();
      DOUT << "\n**** Local spiller rewriting function '"
           << MF.getFunction()->getName() << "':\n";
      DOUT << "**** Machine Instrs (NOTE! Does not include spills and reloads!) ****\n";
      DEBUG(MF.dump());

      for (MachineFunction::iterator MBB = MF.begin(), E = MF.end();
           MBB != E; ++MBB)
        RewriteMBB(*MBB, VRM);

      DOUT << "**** Post Machine Instrs ****\n";
      DEBUG(MF.dump());

      return true;
    }
  private:
    bool PrepForUnfoldOpti(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator &MII,
                           std::vector<MachineInstr*> &MaybeDeadStores,
                           AvailableSpills &Spills, BitVector &RegKills,
                           std::vector<MachineOperand*> &KillOps,
                           VirtRegMap &VRM);
    void RewriteMBB(MachineBasicBlock &MBB, VirtRegMap &VRM);
  };
}

/// AvailableSpills - As the local spiller is scanning and rewriting an MBB from
/// top down, keep track of which spills slots or remat are available in each
/// register.
///
/// Note that not all physregs are created equal here.  In particular, some
/// physregs are reloads that we are allowed to clobber or ignore at any time.
/// Other physregs are values that the register allocated program is using that
/// we cannot CHANGE, but we can read if we like.  We keep track of this on a 
/// per-stack-slot / remat id basis as the low bit in the value of the
/// SpillSlotsAvailable entries.  The predicate 'canClobberPhysReg()' checks
/// this bit and addAvailable sets it if.
namespace {
class VISIBILITY_HIDDEN AvailableSpills {
  const MRegisterInfo *MRI;
  const TargetInstrInfo *TII;

  // SpillSlotsOrReMatsAvailable - This map keeps track of all of the spilled
  // or remat'ed virtual register values that are still available, due to being
  // loaded or stored to, but not invalidated yet.
  std::map<int, unsigned> SpillSlotsOrReMatsAvailable;
    
  // PhysRegsAvailable - This is the inverse of SpillSlotsOrReMatsAvailable,
  // indicating which stack slot values are currently held by a physreg.  This
  // is used to invalidate entries in SpillSlotsOrReMatsAvailable when a
  // physreg is modified.
  std::multimap<unsigned, int> PhysRegsAvailable;
  
  void disallowClobberPhysRegOnly(unsigned PhysReg);

  void ClobberPhysRegOnly(unsigned PhysReg);
public:
  AvailableSpills(const MRegisterInfo *mri, const TargetInstrInfo *tii)
    : MRI(mri), TII(tii) {
  }
  
  const MRegisterInfo *getRegInfo() const { return MRI; }

  /// getSpillSlotOrReMatPhysReg - If the specified stack slot or remat is
  /// available in a  physical register, return that PhysReg, otherwise
  /// return 0.
  unsigned getSpillSlotOrReMatPhysReg(int Slot) const {
    std::map<int, unsigned>::const_iterator I =
      SpillSlotsOrReMatsAvailable.find(Slot);
    if (I != SpillSlotsOrReMatsAvailable.end()) {
      return I->second >> 1;  // Remove the CanClobber bit.
    }
    return 0;
  }

  /// addAvailable - Mark that the specified stack slot / remat is available in
  /// the specified physreg.  If CanClobber is true, the physreg can be modified
  /// at any time without changing the semantics of the program.
  void addAvailable(int SlotOrReMat, MachineInstr *MI, unsigned Reg,
                    bool CanClobber = true) {
    // If this stack slot is thought to be available in some other physreg, 
    // remove its record.
    ModifyStackSlotOrReMat(SlotOrReMat);
    
    PhysRegsAvailable.insert(std::make_pair(Reg, SlotOrReMat));
    SpillSlotsOrReMatsAvailable[SlotOrReMat]= (Reg << 1) | (unsigned)CanClobber;
  
    if (SlotOrReMat > VirtRegMap::MAX_STACK_SLOT)
      DOUT << "Remembering RM#" << SlotOrReMat-VirtRegMap::MAX_STACK_SLOT-1;
    else
      DOUT << "Remembering SS#" << SlotOrReMat;
    DOUT << " in physreg " << MRI->getName(Reg) << "\n";
  }

  /// canClobberPhysReg - Return true if the spiller is allowed to change the 
  /// value of the specified stackslot register if it desires.  The specified
  /// stack slot must be available in a physreg for this query to make sense.
  bool canClobberPhysReg(int SlotOrReMat) const {
    assert(SpillSlotsOrReMatsAvailable.count(SlotOrReMat) &&
           "Value not available!");
    return SpillSlotsOrReMatsAvailable.find(SlotOrReMat)->second & 1;
  }
  
  /// disallowClobberPhysReg - Unset the CanClobber bit of the specified
  /// stackslot register. The register is still available but is no longer
  /// allowed to be modifed.
  void disallowClobberPhysReg(unsigned PhysReg);
  
  /// ClobberPhysReg - This is called when the specified physreg changes
  /// value.  We use this to invalidate any info about stuff that lives in
  /// it and any of its aliases.
  void ClobberPhysReg(unsigned PhysReg);

  /// ModifyStackSlotOrReMat - This method is called when the value in a stack
  /// slot changes.  This removes information about which register the previous
  /// value for this slot lives in (as the previous value is dead now).
  void ModifyStackSlotOrReMat(int SlotOrReMat);
};
}

/// disallowClobberPhysRegOnly - Unset the CanClobber bit of the specified
/// stackslot register. The register is still available but is no longer
/// allowed to be modifed.
void AvailableSpills::disallowClobberPhysRegOnly(unsigned PhysReg) {
  std::multimap<unsigned, int>::iterator I =
    PhysRegsAvailable.lower_bound(PhysReg);
  while (I != PhysRegsAvailable.end() && I->first == PhysReg) {
    int SlotOrReMat = I->second;
    I++;
    assert((SpillSlotsOrReMatsAvailable[SlotOrReMat] >> 1) == PhysReg &&
           "Bidirectional map mismatch!");
    SpillSlotsOrReMatsAvailable[SlotOrReMat] &= ~1;
    DOUT << "PhysReg " << MRI->getName(PhysReg)
         << " copied, it is available for use but can no longer be modified\n";
  }
}

/// disallowClobberPhysReg - Unset the CanClobber bit of the specified
/// stackslot register and its aliases. The register and its aliases may
/// still available but is no longer allowed to be modifed.
void AvailableSpills::disallowClobberPhysReg(unsigned PhysReg) {
  for (const unsigned *AS = MRI->getAliasSet(PhysReg); *AS; ++AS)
    disallowClobberPhysRegOnly(*AS);
  disallowClobberPhysRegOnly(PhysReg);
}

/// ClobberPhysRegOnly - This is called when the specified physreg changes
/// value.  We use this to invalidate any info about stuff we thing lives in it.
void AvailableSpills::ClobberPhysRegOnly(unsigned PhysReg) {
  std::multimap<unsigned, int>::iterator I =
    PhysRegsAvailable.lower_bound(PhysReg);
  while (I != PhysRegsAvailable.end() && I->first == PhysReg) {
    int SlotOrReMat = I->second;
    PhysRegsAvailable.erase(I++);
    assert((SpillSlotsOrReMatsAvailable[SlotOrReMat] >> 1) == PhysReg &&
           "Bidirectional map mismatch!");
    SpillSlotsOrReMatsAvailable.erase(SlotOrReMat);
    DOUT << "PhysReg " << MRI->getName(PhysReg)
         << " clobbered, invalidating ";
    if (SlotOrReMat > VirtRegMap::MAX_STACK_SLOT)
      DOUT << "RM#" << SlotOrReMat-VirtRegMap::MAX_STACK_SLOT-1 << "\n";
    else
      DOUT << "SS#" << SlotOrReMat << "\n";
  }
}

/// ClobberPhysReg - This is called when the specified physreg changes
/// value.  We use this to invalidate any info about stuff we thing lives in
/// it and any of its aliases.
void AvailableSpills::ClobberPhysReg(unsigned PhysReg) {
  for (const unsigned *AS = MRI->getAliasSet(PhysReg); *AS; ++AS)
    ClobberPhysRegOnly(*AS);
  ClobberPhysRegOnly(PhysReg);
}

/// ModifyStackSlotOrReMat - This method is called when the value in a stack
/// slot changes.  This removes information about which register the previous
/// value for this slot lives in (as the previous value is dead now).
void AvailableSpills::ModifyStackSlotOrReMat(int SlotOrReMat) {
  std::map<int, unsigned>::iterator It =
    SpillSlotsOrReMatsAvailable.find(SlotOrReMat);
  if (It == SpillSlotsOrReMatsAvailable.end()) return;
  unsigned Reg = It->second >> 1;
  SpillSlotsOrReMatsAvailable.erase(It);
  
  // This register may hold the value of multiple stack slots, only remove this
  // stack slot from the set of values the register contains.
  std::multimap<unsigned, int>::iterator I = PhysRegsAvailable.lower_bound(Reg);
  for (; ; ++I) {
    assert(I != PhysRegsAvailable.end() && I->first == Reg &&
           "Map inverse broken!");
    if (I->second == SlotOrReMat) break;
  }
  PhysRegsAvailable.erase(I);
}



/// InvalidateKills - MI is going to be deleted. If any of its operands are
/// marked kill, then invalidate the information.
static void InvalidateKills(MachineInstr &MI, BitVector &RegKills,
                            std::vector<MachineOperand*> &KillOps,
                            SmallVector<unsigned, 2> *KillRegs = NULL) {
  for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI.getOperand(i);
    if (!MO.isRegister() || !MO.isUse() || !MO.isKill())
      continue;
    unsigned Reg = MO.getReg();
    if (KillRegs)
      KillRegs->push_back(Reg);
    if (KillOps[Reg] == &MO) {
      RegKills.reset(Reg);
      KillOps[Reg] = NULL;
    }
  }
}

/// InvalidateRegDef - If the def operand of the specified def MI is now dead
/// (since it's spill instruction is removed), mark it isDead. Also checks if
/// the def MI has other definition operands that are not dead. Returns it by
/// reference.
static bool InvalidateRegDef(MachineBasicBlock::iterator I,
                             MachineInstr &NewDef, unsigned Reg,
                             bool &HasLiveDef) {
  // Due to remat, it's possible this reg isn't being reused. That is,
  // the def of this reg (by prev MI) is now dead.
  MachineInstr *DefMI = I;
  MachineOperand *DefOp = NULL;
  for (unsigned i = 0, e = DefMI->getNumOperands(); i != e; ++i) {
    MachineOperand &MO = DefMI->getOperand(i);
    if (MO.isRegister() && MO.isDef()) {
      if (MO.getReg() == Reg)
        DefOp = &MO;
      else if (!MO.isDead())
        HasLiveDef = true;
    }
  }
  if (!DefOp)
    return false;

  bool FoundUse = false, Done = false;
  MachineBasicBlock::iterator E = NewDef;
  ++I; ++E;
  for (; !Done && I != E; ++I) {
    MachineInstr *NMI = I;
    for (unsigned j = 0, ee = NMI->getNumOperands(); j != ee; ++j) {
      MachineOperand &MO = NMI->getOperand(j);
      if (!MO.isRegister() || MO.getReg() != Reg)
        continue;
      if (MO.isUse())
        FoundUse = true;
      Done = true; // Stop after scanning all the operands of this MI.
    }
  }
  if (!FoundUse) {
    // Def is dead!
    DefOp->setIsDead();
    return true;
  }
  return false;
}

/// UpdateKills - Track and update kill info. If a MI reads a register that is
/// marked kill, then it must be due to register reuse. Transfer the kill info
/// over.
static void UpdateKills(MachineInstr &MI, BitVector &RegKills,
                        std::vector<MachineOperand*> &KillOps) {
  const TargetInstrDescriptor *TID = MI.getInstrDescriptor();
  for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI.getOperand(i);
    if (!MO.isRegister() || !MO.isUse())
      continue;
    unsigned Reg = MO.getReg();
    if (Reg == 0)
      continue;
    
    if (RegKills[Reg]) {
      // That can't be right. Register is killed but not re-defined and it's
      // being reused. Let's fix that.
      KillOps[Reg]->unsetIsKill();
      if (i < TID->numOperands &&
          TID->getOperandConstraint(i, TOI::TIED_TO) == -1)
        // Unless it's a two-address operand, this is the new kill.
        MO.setIsKill();
    }

    if (MO.isKill()) {
      RegKills.set(Reg);
      KillOps[Reg] = &MO;
    }
  }

  for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI.getOperand(i);
    if (!MO.isRegister() || !MO.isDef())
      continue;
    unsigned Reg = MO.getReg();
    RegKills.reset(Reg);
    KillOps[Reg] = NULL;
  }
}


// ReusedOp - For each reused operand, we keep track of a bit of information, in
// case we need to rollback upon processing a new operand.  See comments below.
namespace {
  struct ReusedOp {
    // The MachineInstr operand that reused an available value.
    unsigned Operand;

    // StackSlotOrReMat - The spill slot or remat id of the value being reused.
    unsigned StackSlotOrReMat;

    // PhysRegReused - The physical register the value was available in.
    unsigned PhysRegReused;

    // AssignedPhysReg - The physreg that was assigned for use by the reload.
    unsigned AssignedPhysReg;
    
    // VirtReg - The virtual register itself.
    unsigned VirtReg;

    ReusedOp(unsigned o, unsigned ss, unsigned prr, unsigned apr,
             unsigned vreg)
      : Operand(o), StackSlotOrReMat(ss), PhysRegReused(prr),
        AssignedPhysReg(apr), VirtReg(vreg) {}
  };
  
  /// ReuseInfo - This maintains a collection of ReuseOp's for each operand that
  /// is reused instead of reloaded.
  class VISIBILITY_HIDDEN ReuseInfo {
    MachineInstr &MI;
    std::vector<ReusedOp> Reuses;
    BitVector PhysRegsClobbered;
  public:
    ReuseInfo(MachineInstr &mi, const MRegisterInfo *mri) : MI(mi) {
      PhysRegsClobbered.resize(mri->getNumRegs());
    }
    
    bool hasReuses() const {
      return !Reuses.empty();
    }
    
    /// addReuse - If we choose to reuse a virtual register that is already
    /// available instead of reloading it, remember that we did so.
    void addReuse(unsigned OpNo, unsigned StackSlotOrReMat,
                  unsigned PhysRegReused, unsigned AssignedPhysReg,
                  unsigned VirtReg) {
      // If the reload is to the assigned register anyway, no undo will be
      // required.
      if (PhysRegReused == AssignedPhysReg) return;
      
      // Otherwise, remember this.
      Reuses.push_back(ReusedOp(OpNo, StackSlotOrReMat, PhysRegReused, 
                                AssignedPhysReg, VirtReg));
    }

    void markClobbered(unsigned PhysReg) {
      PhysRegsClobbered.set(PhysReg);
    }

    bool isClobbered(unsigned PhysReg) const {
      return PhysRegsClobbered.test(PhysReg);
    }
    
    /// GetRegForReload - We are about to emit a reload into PhysReg.  If there
    /// is some other operand that is using the specified register, either pick
    /// a new register to use, or evict the previous reload and use this reg. 
    unsigned GetRegForReload(unsigned PhysReg, MachineInstr *MI,
                             AvailableSpills &Spills,
                             std::vector<MachineInstr*> &MaybeDeadStores,
                             SmallSet<unsigned, 8> &Rejected,
                             BitVector &RegKills,
                             std::vector<MachineOperand*> &KillOps,
                             VirtRegMap &VRM) {
      if (Reuses.empty()) return PhysReg;  // This is most often empty.

      for (unsigned ro = 0, e = Reuses.size(); ro != e; ++ro) {
        ReusedOp &Op = Reuses[ro];
        // If we find some other reuse that was supposed to use this register
        // exactly for its reload, we can change this reload to use ITS reload
        // register. That is, unless its reload register has already been
        // considered and subsequently rejected because it has also been reused
        // by another operand.
        if (Op.PhysRegReused == PhysReg &&
            Rejected.count(Op.AssignedPhysReg) == 0) {
          // Yup, use the reload register that we didn't use before.
          unsigned NewReg = Op.AssignedPhysReg;
          Rejected.insert(PhysReg);
          return GetRegForReload(NewReg, MI, Spills, MaybeDeadStores, Rejected,
                                 RegKills, KillOps, VRM);
        } else {
          // Otherwise, we might also have a problem if a previously reused
          // value aliases the new register.  If so, codegen the previous reload
          // and use this one.          
          unsigned PRRU = Op.PhysRegReused;
          const MRegisterInfo *MRI = Spills.getRegInfo();
          if (MRI->areAliases(PRRU, PhysReg)) {
            // Okay, we found out that an alias of a reused register
            // was used.  This isn't good because it means we have
            // to undo a previous reuse.
            MachineBasicBlock *MBB = MI->getParent();
            const TargetRegisterClass *AliasRC =
              MBB->getParent()->getSSARegMap()->getRegClass(Op.VirtReg);

            // Copy Op out of the vector and remove it, we're going to insert an
            // explicit load for it.
            ReusedOp NewOp = Op;
            Reuses.erase(Reuses.begin()+ro);

            // Ok, we're going to try to reload the assigned physreg into the
            // slot that we were supposed to in the first place.  However, that
            // register could hold a reuse.  Check to see if it conflicts or
            // would prefer us to use a different register.
            unsigned NewPhysReg = GetRegForReload(NewOp.AssignedPhysReg,
                                                  MI, Spills, MaybeDeadStores,
                                              Rejected, RegKills, KillOps, VRM);
            
            if (NewOp.StackSlotOrReMat > VirtRegMap::MAX_STACK_SLOT) {
              MRI->reMaterialize(*MBB, MI, NewPhysReg,
                                 VRM.getReMaterializedMI(NewOp.VirtReg));
              ++NumReMats;
            } else {
              MRI->loadRegFromStackSlot(*MBB, MI, NewPhysReg,
                                        NewOp.StackSlotOrReMat, AliasRC);
              // Any stores to this stack slot are not dead anymore.
              MaybeDeadStores[NewOp.StackSlotOrReMat] = NULL;            
              ++NumLoads;
            }
            Spills.ClobberPhysReg(NewPhysReg);
            Spills.ClobberPhysReg(NewOp.PhysRegReused);
            
            MI->getOperand(NewOp.Operand).setReg(NewPhysReg);
            
            Spills.addAvailable(NewOp.StackSlotOrReMat, MI, NewPhysReg);
            MachineBasicBlock::iterator MII = MI;
            --MII;
            UpdateKills(*MII, RegKills, KillOps);
            DOUT << '\t' << *MII;
            
            DOUT << "Reuse undone!\n";
            --NumReused;
            
            // Finally, PhysReg is now available, go ahead and use it.
            return PhysReg;
          }
        }
      }
      return PhysReg;
    }

    /// GetRegForReload - Helper for the above GetRegForReload(). Add a
    /// 'Rejected' set to remember which registers have been considered and
    /// rejected for the reload. This avoids infinite looping in case like
    /// this:
    /// t1 := op t2, t3
    /// t2 <- assigned r0 for use by the reload but ended up reuse r1
    /// t3 <- assigned r1 for use by the reload but ended up reuse r0
    /// t1 <- desires r1
    ///       sees r1 is taken by t2, tries t2's reload register r0
    ///       sees r0 is taken by t3, tries t3's reload register r1
    ///       sees r1 is taken by t2, tries t2's reload register r0 ...
    unsigned GetRegForReload(unsigned PhysReg, MachineInstr *MI,
                             AvailableSpills &Spills,
                             std::vector<MachineInstr*> &MaybeDeadStores,
                             BitVector &RegKills,
                             std::vector<MachineOperand*> &KillOps,
                             VirtRegMap &VRM) {
      SmallSet<unsigned, 8> Rejected;
      return GetRegForReload(PhysReg, MI, Spills, MaybeDeadStores, Rejected,
                             RegKills, KillOps, VRM);
    }
  };
}

/// PrepForUnfoldOpti - Turn a store folding instruction into a load folding
/// instruction. e.g.
///     xorl  %edi, %eax
///     movl  %eax, -32(%ebp)
///     movl  -36(%ebp), %eax
///	orl   %eax, -32(%ebp)
/// ==>
///     xorl  %edi, %eax
///     orl   -36(%ebp), %eax
///     mov   %eax, -32(%ebp)
/// This enables unfolding optimization for a subsequent instruction which will
/// also eliminate the newly introduced store instruction.
bool LocalSpiller::PrepForUnfoldOpti(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator &MII,
                                    std::vector<MachineInstr*> &MaybeDeadStores,
                                     AvailableSpills &Spills,
                                     BitVector &RegKills,
                                     std::vector<MachineOperand*> &KillOps,
                                     VirtRegMap &VRM) {
  MachineFunction &MF = *MBB.getParent();
  MachineInstr &MI = *MII;
  unsigned UnfoldedOpc = 0;
  unsigned UnfoldPR = 0;
  unsigned UnfoldVR = 0;
  int FoldedSS = VirtRegMap::NO_STACK_SLOT;
  VirtRegMap::MI2VirtMapTy::const_iterator I, End;
  for (tie(I, End) = VRM.getFoldedVirts(&MI); I != End; ++I) {
    // Only transform a MI that folds a single register.
    if (UnfoldedOpc)
      return false;
    UnfoldVR = I->second.first;
    VirtRegMap::ModRef MR = I->second.second;
    if (VRM.isAssignedReg(UnfoldVR))
      continue;
    // If this reference is not a use, any previous store is now dead.
    // Otherwise, the store to this stack slot is not dead anymore.
    FoldedSS = VRM.getStackSlot(UnfoldVR);
    MachineInstr* DeadStore = MaybeDeadStores[FoldedSS];
    if (DeadStore && (MR & VirtRegMap::isModRef)) {
      unsigned PhysReg = Spills.getSpillSlotOrReMatPhysReg(FoldedSS);
      if (!PhysReg ||
          DeadStore->findRegisterUseOperandIdx(PhysReg, true) == -1)
        continue;
      UnfoldPR = PhysReg;
      UnfoldedOpc = MRI->getOpcodeAfterMemoryUnfold(MI.getOpcode(),
                                                    false, true);
    }
  }

  if (!UnfoldedOpc)
    return false;

  for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
    MachineOperand &MO = MI.getOperand(i);
    if (!MO.isRegister() || MO.getReg() == 0 || !MO.isUse())
      continue;
    unsigned VirtReg = MO.getReg();
    if (MRegisterInfo::isPhysicalRegister(VirtReg) || MO.getSubReg())
      continue;
    if (VRM.isAssignedReg(VirtReg)) {
      unsigned PhysReg = VRM.getPhys(VirtReg);
      if (PhysReg && MRI->regsOverlap(PhysReg, UnfoldPR))
        return false;
    } else if (VRM.isReMaterialized(VirtReg))
      continue;
    int SS = VRM.getStackSlot(VirtReg);
    unsigned PhysReg = Spills.getSpillSlotOrReMatPhysReg(SS);
    if (PhysReg) {
      if (MRI->regsOverlap(PhysReg, UnfoldPR))
        return false;
      continue;
    }
    PhysReg = VRM.getPhys(VirtReg);
    if (!MRI->regsOverlap(PhysReg, UnfoldPR))
      continue;

    // Ok, we'll need to reload the value into a register which makes
    // it impossible to perform the store unfolding optimization later.
    // Let's see if it is possible to fold the load if the store is
    // unfolded. This allows us to perform the store unfolding
    // optimization.
    SmallVector<MachineInstr*, 4> NewMIs;
    if (MRI->unfoldMemoryOperand(MF, &MI, UnfoldVR, false, false, NewMIs)) {
      assert(NewMIs.size() == 1);
      MachineInstr *NewMI = NewMIs.back();
      NewMIs.clear();
      unsigned Idx = NewMI->findRegisterUseOperandIdx(VirtReg);
      MachineInstr *FoldedMI = MRI->foldMemoryOperand(NewMI, Idx, SS);
      if (FoldedMI) {
        if (!VRM.hasPhys(UnfoldVR))
          VRM.assignVirt2Phys(UnfoldVR, UnfoldPR);
        VRM.virtFolded(VirtReg, FoldedMI, VirtRegMap::isRef);
        MII = MBB.insert(MII, FoldedMI);
        VRM.RemoveFromFoldedVirtMap(&MI);
        MBB.erase(&MI);
        return true;
      }
      delete NewMI;
    }
  }
  return false;
}

/// findSuperReg - Find the SubReg's super-register of given register class
/// where its SubIdx sub-register is SubReg.
static unsigned findSuperReg(const TargetRegisterClass *RC, unsigned SubReg,
                             unsigned SubIdx, const MRegisterInfo *MRI) {
  for (TargetRegisterClass::iterator I = RC->begin(), E = RC->end();
       I != E; ++I) {
    unsigned Reg = *I;
    if (MRI->getSubReg(Reg, SubIdx) == SubReg)
      return Reg;
  }
  return 0;
}

/// rewriteMBB - Keep track of which spills are available even after the
/// register allocator is done with them.  If possible, avoid reloading vregs.
void LocalSpiller::RewriteMBB(MachineBasicBlock &MBB, VirtRegMap &VRM) {
  DOUT << MBB.getBasicBlock()->getName() << ":\n";

  MachineFunction &MF = *MBB.getParent();

  // Spills - Keep track of which spilled values are available in physregs so
  // that we can choose to reuse the physregs instead of emitting reloads.
  AvailableSpills Spills(MRI, TII);
  
  // MaybeDeadStores - When we need to write a value back into a stack slot,
  // keep track of the inserted store.  If the stack slot value is never read
  // (because the value was used from some available register, for example), and
  // subsequently stored to, the original store is dead.  This map keeps track
  // of inserted stores that are not used.  If we see a subsequent store to the
  // same stack slot, the original store is deleted.
  std::vector<MachineInstr*> MaybeDeadStores;
  MaybeDeadStores.resize(MF.getFrameInfo()->getObjectIndexEnd(), NULL);

  // ReMatDefs - These are rematerializable def MIs which are not deleted.
  SmallSet<MachineInstr*, 4> ReMatDefs;

  // Keep track of kill information.
  BitVector RegKills(MRI->getNumRegs());
  std::vector<MachineOperand*>  KillOps;
  KillOps.resize(MRI->getNumRegs(), NULL);

  for (MachineBasicBlock::iterator MII = MBB.begin(), E = MBB.end();
       MII != E; ) {
    MachineBasicBlock::iterator NextMII = MII; ++NextMII;

    VirtRegMap::MI2VirtMapTy::const_iterator I, End;
    bool Erased = false;
    bool BackTracked = false;
    if (PrepForUnfoldOpti(MBB, MII,
                          MaybeDeadStores, Spills, RegKills, KillOps, VRM))
      NextMII = next(MII);

    /// ReusedOperands - Keep track of operand reuse in case we need to undo
    /// reuse.
    MachineInstr &MI = *MII;
    ReuseInfo ReusedOperands(MI, MRI);

    const TargetInstrDescriptor *TID = MI.getInstrDescriptor();

    // Process all of the spilled uses and all non spilled reg references.
    for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
      MachineOperand &MO = MI.getOperand(i);
      if (!MO.isRegister() || MO.getReg() == 0)
        continue;   // Ignore non-register operands.
      
      unsigned VirtReg = MO.getReg();
      if (MRegisterInfo::isPhysicalRegister(VirtReg)) {
        // Ignore physregs for spilling, but remember that it is used by this
        // function.
        MF.setPhysRegUsed(VirtReg);
        continue;
      }
      
      assert(MRegisterInfo::isVirtualRegister(VirtReg) &&
             "Not a virtual or a physical register?");
      
      unsigned SubIdx = MO.getSubReg();
      if (VRM.isAssignedReg(VirtReg)) {
        // This virtual register was assigned a physreg!
        unsigned Phys = VRM.getPhys(VirtReg);
        MF.setPhysRegUsed(Phys);
        if (MO.isDef())
          ReusedOperands.markClobbered(Phys);
        unsigned RReg = SubIdx ? MRI->getSubReg(Phys, SubIdx) : Phys;
        MI.getOperand(i).setReg(RReg);
        continue;
      }
      
      // This virtual register is now known to be a spilled value.
      if (!MO.isUse())
        continue;  // Handle defs in the loop below (handle use&def here though)

      bool DoReMat = VRM.isReMaterialized(VirtReg);
      int SSorRMId = DoReMat
        ? VRM.getReMatId(VirtReg) : VRM.getStackSlot(VirtReg);
      int ReuseSlot = SSorRMId;

      // Check to see if this stack slot is available.
      unsigned PhysReg = Spills.getSpillSlotOrReMatPhysReg(SSorRMId);
      if (!PhysReg && DoReMat) {
        // This use is rematerializable. But perhaps the value is available in
        // a register if the definition is not deleted. If so, check if we can
        // reuse the value.
        ReuseSlot = VRM.getStackSlot(VirtReg);
        if (ReuseSlot != VirtRegMap::NO_STACK_SLOT)
          PhysReg = Spills.getSpillSlotOrReMatPhysReg(ReuseSlot);
      }

      // If this is a sub-register use, make sure the reuse register is in the
      // right register class. For example, for x86 not all of the 32-bit
      // registers have accessible sub-registers.
      // Similarly so for EXTRACT_SUBREG. Consider this:
      // EDI = op
      // MOV32_mr fi#1, EDI
      // ...
      //       = EXTRACT_SUBREG fi#1
      // fi#1 is available in EDI, but it cannot be reused because it's not in
      // the right register file.
      if (PhysReg &&
          (SubIdx || MI.getOpcode() == TargetInstrInfo::EXTRACT_SUBREG)) {
        const TargetRegisterClass* RC = RegMap->getRegClass(VirtReg);
        if (!RC->contains(PhysReg))
          PhysReg = 0;
      }

      if (PhysReg) {
        // This spilled operand might be part of a two-address operand.  If this
        // is the case, then changing it will necessarily require changing the 
        // def part of the instruction as well.  However, in some cases, we
        // aren't allowed to modify the reused register.  If none of these cases
        // apply, reuse it.
        bool CanReuse = true;
        int ti = TID->getOperandConstraint(i, TOI::TIED_TO);
        if (ti != -1 &&
            MI.getOperand(ti).isRegister() && 
            MI.getOperand(ti).getReg() == VirtReg) {
          // Okay, we have a two address operand.  We can reuse this physreg as
          // long as we are allowed to clobber the value and there isn't an
          // earlier def that has already clobbered the physreg.
          CanReuse = Spills.canClobberPhysReg(ReuseSlot) &&
            !ReusedOperands.isClobbered(PhysReg);
        }
        
        if (CanReuse) {
          // If this stack slot value is already available, reuse it!
          if (ReuseSlot > VirtRegMap::MAX_STACK_SLOT)
            DOUT << "Reusing RM#" << ReuseSlot-VirtRegMap::MAX_STACK_SLOT-1;
          else
            DOUT << "Reusing SS#" << ReuseSlot;
          DOUT << " from physreg "
               << MRI->getName(PhysReg) << " for vreg"
               << VirtReg <<" instead of reloading into physreg "
               << MRI->getName(VRM.getPhys(VirtReg)) << "\n";
          unsigned RReg = SubIdx ? MRI->getSubReg(PhysReg, SubIdx) : PhysReg;
          MI.getOperand(i).setReg(RReg);

          // The only technical detail we have is that we don't know that
          // PhysReg won't be clobbered by a reloaded stack slot that occurs
          // later in the instruction.  In particular, consider 'op V1, V2'.
          // If V1 is available in physreg R0, we would choose to reuse it
          // here, instead of reloading it into the register the allocator
          // indicated (say R1).  However, V2 might have to be reloaded
          // later, and it might indicate that it needs to live in R0.  When
          // this occurs, we need to have information available that
          // indicates it is safe to use R1 for the reload instead of R0.
          //
          // To further complicate matters, we might conflict with an alias,
          // or R0 and R1 might not be compatible with each other.  In this
          // case, we actually insert a reload for V1 in R1, ensuring that
          // we can get at R0 or its alias.
          ReusedOperands.addReuse(i, ReuseSlot, PhysReg,
                                  VRM.getPhys(VirtReg), VirtReg);
          if (ti != -1)
            // Only mark it clobbered if this is a use&def operand.
            ReusedOperands.markClobbered(PhysReg);
          ++NumReused;

          if (MI.getOperand(i).isKill() &&
              ReuseSlot <= VirtRegMap::MAX_STACK_SLOT) {
            // This was the last use and the spilled value is still available
            // for reuse. That means the spill was unnecessary!
            MachineInstr* DeadStore = MaybeDeadStores[ReuseSlot];
            if (DeadStore) {
              DOUT << "Removed dead store:\t" << *DeadStore;
              InvalidateKills(*DeadStore, RegKills, KillOps);
              VRM.RemoveFromFoldedVirtMap(DeadStore);
              MBB.erase(DeadStore);
              MaybeDeadStores[ReuseSlot] = NULL;
              ++NumDSE;
            }
          }
          continue;
        }  // CanReuse
        
        // Otherwise we have a situation where we have a two-address instruction
        // whose mod/ref operand needs to be reloaded.  This reload is already
        // available in some register "PhysReg", but if we used PhysReg as the
        // operand to our 2-addr instruction, the instruction would modify
        // PhysReg.  This isn't cool if something later uses PhysReg and expects
        // to get its initial value.
        //
        // To avoid this problem, and to avoid doing a load right after a store,
        // we emit a copy from PhysReg into the designated register for this
        // operand.
        unsigned DesignatedReg = VRM.getPhys(VirtReg);
        assert(DesignatedReg && "Must map virtreg to physreg!");

        // Note that, if we reused a register for a previous operand, the
        // register we want to reload into might not actually be
        // available.  If this occurs, use the register indicated by the
        // reuser.
        if (ReusedOperands.hasReuses())
          DesignatedReg = ReusedOperands.GetRegForReload(DesignatedReg, &MI, 
                               Spills, MaybeDeadStores, RegKills, KillOps, VRM);
        
        // If the mapped designated register is actually the physreg we have
        // incoming, we don't need to inserted a dead copy.
        if (DesignatedReg == PhysReg) {
          // If this stack slot value is already available, reuse it!
          if (ReuseSlot > VirtRegMap::MAX_STACK_SLOT)
            DOUT << "Reusing RM#" << ReuseSlot-VirtRegMap::MAX_STACK_SLOT-1;
          else
            DOUT << "Reusing SS#" << ReuseSlot;
          DOUT << " from physreg " << MRI->getName(PhysReg) << " for vreg"
               << VirtReg
               << " instead of reloading into same physreg.\n";
          unsigned RReg = SubIdx ? MRI->getSubReg(PhysReg, SubIdx) : PhysReg;
          MI.getOperand(i).setReg(RReg);
          ReusedOperands.markClobbered(RReg);
          ++NumReused;
          continue;
        }
        
        const TargetRegisterClass* RC = RegMap->getRegClass(VirtReg);
        MF.setPhysRegUsed(DesignatedReg);
        ReusedOperands.markClobbered(DesignatedReg);
        MRI->copyRegToReg(MBB, &MI, DesignatedReg, PhysReg, RC, RC);

        MachineInstr *CopyMI = prior(MII);
        UpdateKills(*CopyMI, RegKills, KillOps);

        // This invalidates DesignatedReg.
        Spills.ClobberPhysReg(DesignatedReg);
        
        Spills.addAvailable(ReuseSlot, &MI, DesignatedReg);
        unsigned RReg =
          SubIdx ? MRI->getSubReg(DesignatedReg, SubIdx) : DesignatedReg;
        MI.getOperand(i).setReg(RReg);
        DOUT << '\t' << *prior(MII);
        ++NumReused;
        continue;
      } // if (PhysReg)
      
      // Otherwise, reload it and remember that we have it.
      PhysReg = VRM.getPhys(VirtReg);
      assert(PhysReg && "Must map virtreg to physreg!");

      // Note that, if we reused a register for a previous operand, the
      // register we want to reload into might not actually be
      // available.  If this occurs, use the register indicated by the
      // reuser.
      if (ReusedOperands.hasReuses())
        PhysReg = ReusedOperands.GetRegForReload(PhysReg, &MI, 
                               Spills, MaybeDeadStores, RegKills, KillOps, VRM);
      
      MF.setPhysRegUsed(PhysReg);
      ReusedOperands.markClobbered(PhysReg);
      if (DoReMat) {
        MRI->reMaterialize(MBB, &MI, PhysReg, VRM.getReMaterializedMI(VirtReg));
        ++NumReMats;
      } else {
        const TargetRegisterClass* RC = RegMap->getRegClass(VirtReg);
        MRI->loadRegFromStackSlot(MBB, &MI, PhysReg, SSorRMId, RC);
        ++NumLoads;
      }
      // This invalidates PhysReg.
      Spills.ClobberPhysReg(PhysReg);

      // Any stores to this stack slot are not dead anymore.
      if (!DoReMat)
        MaybeDeadStores[SSorRMId] = NULL;
      Spills.addAvailable(SSorRMId, &MI, PhysReg);
      // Assumes this is the last use. IsKill will be unset if reg is reused
      // unless it's a two-address operand.
      if (TID->getOperandConstraint(i, TOI::TIED_TO) == -1)
        MI.getOperand(i).setIsKill();
      unsigned RReg = SubIdx ? MRI->getSubReg(PhysReg, SubIdx) : PhysReg;
      MI.getOperand(i).setReg(RReg);
      UpdateKills(*prior(MII), RegKills, KillOps);
      DOUT << '\t' << *prior(MII);
    }

    DOUT << '\t' << MI;

    // If we have folded references to memory operands, make sure we clear all
    // physical registers that may contain the value of the spilled virtual
    // register
    SmallSet<int, 2> FoldedSS;
    for (tie(I, End) = VRM.getFoldedVirts(&MI); I != End; ++I) {
      unsigned VirtReg = I->second.first;
      VirtRegMap::ModRef MR = I->second.second;
      DOUT << "Folded vreg: " << VirtReg << "  MR: " << MR;
      if (VRM.isAssignedReg(VirtReg)) {
        DOUT << ": No stack slot!\n";
        continue;
      }
      int SS = VRM.getStackSlot(VirtReg);
      FoldedSS.insert(SS);
      DOUT << " - StackSlot: " << SS << "\n";
      
      // If this folded instruction is just a use, check to see if it's a
      // straight load from the virt reg slot.
      if ((MR & VirtRegMap::isRef) && !(MR & VirtRegMap::isMod)) {
        int FrameIdx;
        unsigned DestReg = TII->isLoadFromStackSlot(&MI, FrameIdx);
        if (DestReg && FrameIdx == SS) {
          // If this spill slot is available, turn it into a copy (or nothing)
          // instead of leaving it as a load!
          if (unsigned InReg = Spills.getSpillSlotOrReMatPhysReg(SS)) {
            DOUT << "Promoted Load To Copy: " << MI;
            if (DestReg != InReg) {
              const TargetRegisterClass *RC = RegMap->getRegClass(VirtReg);
              MRI->copyRegToReg(MBB, &MI, DestReg, InReg, RC, RC);
              // Revisit the copy so we make sure to notice the effects of the
              // operation on the destreg (either needing to RA it if it's 
              // virtual or needing to clobber any values if it's physical).
              NextMII = &MI;
              --NextMII;  // backtrack to the copy.
              BackTracked = true;
            } else
              DOUT << "Removing now-noop copy: " << MI;

            VRM.RemoveFromFoldedVirtMap(&MI);
            MBB.erase(&MI);
            Erased = true;
            goto ProcessNextInst;
          }
        } else {
          unsigned PhysReg = Spills.getSpillSlotOrReMatPhysReg(SS);
          SmallVector<MachineInstr*, 4> NewMIs;
          if (PhysReg &&
              MRI->unfoldMemoryOperand(MF, &MI, PhysReg, false, false, NewMIs)) {
            MBB.insert(MII, NewMIs[0]);
            VRM.RemoveFromFoldedVirtMap(&MI);
            MBB.erase(&MI);
            Erased = true;
            --NextMII;  // backtrack to the unfolded instruction.
            BackTracked = true;
            goto ProcessNextInst;
          }
        }
      }

      // If this reference is not a use, any previous store is now dead.
      // Otherwise, the store to this stack slot is not dead anymore.
      MachineInstr* DeadStore = MaybeDeadStores[SS];
      if (DeadStore) {
        bool isDead = !(MR & VirtRegMap::isRef);
        MachineInstr *NewStore = NULL;
        if (MR & VirtRegMap::isModRef) {
          unsigned PhysReg = Spills.getSpillSlotOrReMatPhysReg(SS);
          SmallVector<MachineInstr*, 4> NewMIs;
          if (PhysReg &&
              DeadStore->findRegisterUseOperandIdx(PhysReg, true) != -1 &&
              MRI->unfoldMemoryOperand(MF, &MI, PhysReg, false, true, NewMIs)) {
            MBB.insert(MII, NewMIs[0]);
            NewStore = NewMIs[1];
            MBB.insert(MII, NewStore);
            VRM.RemoveFromFoldedVirtMap(&MI);
            MBB.erase(&MI);
            Erased = true;
            --NextMII;
            --NextMII;  // backtrack to the unfolded instruction.
            BackTracked = true;
            isDead = true;
          }
        }

        if (isDead) {  // Previous store is dead.
          // If we get here, the store is dead, nuke it now.
          DOUT << "Removed dead store:\t" << *DeadStore;
          InvalidateKills(*DeadStore, RegKills, KillOps);
          VRM.RemoveFromFoldedVirtMap(DeadStore);
          MBB.erase(DeadStore);
          if (!NewStore)
            ++NumDSE;
        }

        MaybeDeadStores[SS] = NULL;
        if (NewStore) {
          // Treat this store as a spill merged into a copy. That makes the
          // stack slot value available.
          VRM.virtFolded(VirtReg, NewStore, VirtRegMap::isMod);
          goto ProcessNextInst;
        }
      }

      // If the spill slot value is available, and this is a new definition of
      // the value, the value is not available anymore.
      if (MR & VirtRegMap::isMod) {
        // Notice that the value in this stack slot has been modified.
        Spills.ModifyStackSlotOrReMat(SS);
        
        // If this is *just* a mod of the value, check to see if this is just a
        // store to the spill slot (i.e. the spill got merged into the copy). If
        // so, realize that the vreg is available now, and add the store to the
        // MaybeDeadStore info.
        int StackSlot;
        if (!(MR & VirtRegMap::isRef)) {
          if (unsigned SrcReg = TII->isStoreToStackSlot(&MI, StackSlot)) {
            assert(MRegisterInfo::isPhysicalRegister(SrcReg) &&
                   "Src hasn't been allocated yet?");
            // Okay, this is certainly a store of SrcReg to [StackSlot].  Mark
            // this as a potentially dead store in case there is a subsequent
            // store into the stack slot without a read from it.
            MaybeDeadStores[StackSlot] = &MI;

            // If the stack slot value was previously available in some other
            // register, change it now.  Otherwise, make the register available,
            // in PhysReg.
            Spills.addAvailable(StackSlot, &MI, SrcReg, false/*don't clobber*/);
          }
        }
      }
    }

    // Process all of the spilled defs.
    for (unsigned i = 0, e = MI.getNumOperands(); i != e; ++i) {
      MachineOperand &MO = MI.getOperand(i);
      if (!(MO.isRegister() && MO.getReg() && MO.isDef()))
        continue;

      unsigned VirtReg = MO.getReg();
      if (!MRegisterInfo::isVirtualRegister(VirtReg)) {
        // Check to see if this is a noop copy.  If so, eliminate the
        // instruction before considering the dest reg to be changed.
        unsigned Src, Dst;
        if (TII->isMoveInstr(MI, Src, Dst) && Src == Dst) {
          ++NumDCE;
          DOUT << "Removing now-noop copy: " << MI;
          MBB.erase(&MI);
          Erased = true;
          VRM.RemoveFromFoldedVirtMap(&MI);
          Spills.disallowClobberPhysReg(VirtReg);
          goto ProcessNextInst;
        }
          
        // If it's not a no-op copy, it clobbers the value in the destreg.
        Spills.ClobberPhysReg(VirtReg);
        ReusedOperands.markClobbered(VirtReg);
 
        // Check to see if this instruction is a load from a stack slot into
        // a register.  If so, this provides the stack slot value in the reg.
        int FrameIdx;
        if (unsigned DestReg = TII->isLoadFromStackSlot(&MI, FrameIdx)) {
          assert(DestReg == VirtReg && "Unknown load situation!");

          // If it is a folded reference, then it's not safe to clobber.
          bool Folded = FoldedSS.count(FrameIdx);
          // Otherwise, if it wasn't available, remember that it is now!
          Spills.addAvailable(FrameIdx, &MI, DestReg, !Folded);
          goto ProcessNextInst;
        }
            
        continue;
      }

      unsigned SubIdx = MO.getSubReg();
      bool DoReMat = VRM.isReMaterialized(VirtReg);
      if (DoReMat)
        ReMatDefs.insert(&MI);

      // The only vregs left are stack slot definitions.
      int StackSlot = VRM.getStackSlot(VirtReg);
      const TargetRegisterClass *RC = RegMap->getRegClass(VirtReg);

      // If this def is part of a two-address operand, make sure to execute
      // the store from the correct physical register.
      unsigned PhysReg;
      int TiedOp = MI.getInstrDescriptor()->findTiedToSrcOperand(i);
      if (TiedOp != -1) {
        PhysReg = MI.getOperand(TiedOp).getReg();
        if (SubIdx) {
          unsigned SuperReg = findSuperReg(RC, PhysReg, SubIdx, MRI);
          assert(SuperReg && MRI->getSubReg(SuperReg, SubIdx) == PhysReg &&
                 "Can't find corresponding super-register!");
          PhysReg = SuperReg;
        }
      } else {
        PhysReg = VRM.getPhys(VirtReg);
        if (ReusedOperands.isClobbered(PhysReg)) {
          // Another def has taken the assigned physreg. It must have been a
          // use&def which got it due to reuse. Undo the reuse!
          PhysReg = ReusedOperands.GetRegForReload(PhysReg, &MI, 
                               Spills, MaybeDeadStores, RegKills, KillOps, VRM);
        }
      }

      MF.setPhysRegUsed(PhysReg);
      unsigned RReg = SubIdx ? MRI->getSubReg(PhysReg, SubIdx) : PhysReg;
      ReusedOperands.markClobbered(RReg);
      MI.getOperand(i).setReg(RReg);

      if (!MO.isDead()) {
        MRI->storeRegToStackSlot(MBB, next(MII), PhysReg, StackSlot, RC);
        DOUT << "Store:\t" << *next(MII);

        // If there is a dead store to this stack slot, nuke it now.
        MachineInstr *&LastStore = MaybeDeadStores[StackSlot];
        if (LastStore) {
          DOUT << "Removed dead store:\t" << *LastStore;
          ++NumDSE;
          SmallVector<unsigned, 2> KillRegs;
          InvalidateKills(*LastStore, RegKills, KillOps, &KillRegs);
          MachineBasicBlock::iterator PrevMII = LastStore;
          bool CheckDef = PrevMII != MBB.begin();
          if (CheckDef)
            --PrevMII;
          MBB.erase(LastStore);
          VRM.RemoveFromFoldedVirtMap(LastStore);
          if (CheckDef) {
            // Look at defs of killed registers on the store. Mark the defs
            // as dead since the store has been deleted and they aren't
            // being reused.
            for (unsigned j = 0, ee = KillRegs.size(); j != ee; ++j) {
              bool HasOtherDef = false;
              if (InvalidateRegDef(PrevMII, MI, KillRegs[j], HasOtherDef)) {
                MachineInstr *DeadDef = PrevMII;
                if (ReMatDefs.count(DeadDef) && !HasOtherDef) {
                  // FIXME: This assumes a remat def does not have side
                  // effects.
                  MBB.erase(DeadDef);
                  VRM.RemoveFromFoldedVirtMap(DeadDef);
                  ++NumDRM;
                }
              }
            }
          }
        }
        LastStore = next(MII);

        // If the stack slot value was previously available in some other
        // register, change it now.  Otherwise, make the register available,
        // in PhysReg.
        Spills.ModifyStackSlotOrReMat(StackSlot);
        Spills.ClobberPhysReg(PhysReg);
        Spills.addAvailable(StackSlot, LastStore, PhysReg);
        ++NumStores;

        // Check to see if this is a noop copy.  If so, eliminate the
        // instruction before considering the dest reg to be changed.
        {
          unsigned Src, Dst;
          if (TII->isMoveInstr(MI, Src, Dst) && Src == Dst) {
            ++NumDCE;
            DOUT << "Removing now-noop copy: " << MI;
            MBB.erase(&MI);
            Erased = true;
            VRM.RemoveFromFoldedVirtMap(&MI);
            UpdateKills(*LastStore, RegKills, KillOps);
            goto ProcessNextInst;
          }
        }
      }    
    }
  ProcessNextInst:
    if (!Erased && !BackTracked)
      for (MachineBasicBlock::iterator II = MI; II != NextMII; ++II)
        UpdateKills(*II, RegKills, KillOps);
    MII = NextMII;
  }
}


llvm::Spiller* llvm::createSpiller() {
  switch (SpillerOpt) {
  default: assert(0 && "Unreachable!");
  case local:
    return new LocalSpiller();
  case simple:
    return new SimpleSpiller();
  }
}
