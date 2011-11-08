//===- ExecutionDepsFix.cpp - Fix execution dependecy issues ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the execution dependency fix pass.
//
// Some X86 SSE instructions like mov, and, or, xor are available in different
// variants for different operand types. These variant instructions are
// equivalent, but on Nehalem and newer cpus there is extra latency
// transferring data between integer and floating point domains.  ARM cores
// have similar issues when they are configured with both VFP and NEON
// pipelines.
//
// This pass changes the variant instructions to minimize domain crossings.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "execution-fix"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/Support/Allocator.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

/// A DomainValue is a bit like LiveIntervals' ValNo, but it also keeps track
/// of execution domains.
///
/// An open DomainValue represents a set of instructions that can still switch
/// execution domain. Multiple registers may refer to the same open
/// DomainValue - they will eventually be collapsed to the same execution
/// domain.
///
/// A collapsed DomainValue represents a single register that has been forced
/// into one of more execution domains. There is a separate collapsed
/// DomainValue for each register, but it may contain multiple execution
/// domains. A register value is initially created in a single execution
/// domain, but if we were forced to pay the penalty of a domain crossing, we
/// keep track of the fact the the register is now available in multiple
/// domains.
namespace {
struct DomainValue {
  // Basic reference counting.
  unsigned Refs;

  // Bitmask of available domains. For an open DomainValue, it is the still
  // possible domains for collapsing. For a collapsed DomainValue it is the
  // domains where the register is available for free.
  unsigned AvailableDomains;

  // Position of the last defining instruction.
  unsigned Dist;

  // Twiddleable instructions using or defining these registers.
  SmallVector<MachineInstr*, 8> Instrs;

  // A collapsed DomainValue has no instructions to twiddle - it simply keeps
  // track of the domains where the registers are already available.
  bool isCollapsed() const { return Instrs.empty(); }

  // Is domain available?
  bool hasDomain(unsigned domain) const {
    return AvailableDomains & (1u << domain);
  }

  // Mark domain as available.
  void addDomain(unsigned domain) {
    AvailableDomains |= 1u << domain;
  }

  // Restrict to a single domain available.
  void setSingleDomain(unsigned domain) {
    AvailableDomains = 1u << domain;
  }

  // Return bitmask of domains that are available and in mask.
  unsigned getCommonDomains(unsigned mask) const {
    return AvailableDomains & mask;
  }

  // First domain available.
  unsigned getFirstDomain() const {
    return CountTrailingZeros_32(AvailableDomains);
  }

  DomainValue() { clear(); }

  void clear() {
    Refs = AvailableDomains = Dist = 0;
    Instrs.clear();
  }
};
}

namespace {
class ExeDepsFix : public MachineFunctionPass {
  static char ID;
  SpecificBumpPtrAllocator<DomainValue> Allocator;
  SmallVector<DomainValue*,16> Avail;

  const TargetRegisterClass *const RC;
  MachineFunction *MF;
  const TargetInstrInfo *TII;
  const TargetRegisterInfo *TRI;
  std::vector<int> AliasMap;
  const unsigned NumRegs;
  DomainValue **LiveRegs;
  typedef DenseMap<MachineBasicBlock*,DomainValue**> LiveOutMap;
  LiveOutMap LiveOuts;
  unsigned Distance;

public:
  ExeDepsFix(const TargetRegisterClass *rc)
    : MachineFunctionPass(ID), RC(rc), NumRegs(RC->getNumRegs()) {}

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  virtual bool runOnMachineFunction(MachineFunction &MF);

  virtual const char *getPassName() const {
    return "Execution dependency fix";
  }

private:
  // Register mapping.
  int RegIndex(unsigned Reg);

  // DomainValue allocation.
  DomainValue *Alloc(int domain = -1);
  void release(DomainValue*);

  // LiveRegs manipulations.
  void SetLiveReg(int rx, DomainValue *DV);
  void Kill(int rx);
  void Force(int rx, unsigned domain);
  void Collapse(DomainValue *dv, unsigned domain);
  bool Merge(DomainValue *A, DomainValue *B);

  void enterBasicBlock(MachineBasicBlock*);
  void leaveBasicBlock(MachineBasicBlock*);
  void visitInstr(MachineInstr*);
  void visitGenericInstr(MachineInstr*);
  void visitSoftInstr(MachineInstr*, unsigned mask);
  void visitHardInstr(MachineInstr*, unsigned domain);
};
}

char ExeDepsFix::ID = 0;

/// Translate TRI register number to an index into our smaller tables of
/// interesting registers. Return -1 for boring registers.
int ExeDepsFix::RegIndex(unsigned Reg) {
  assert(Reg < AliasMap.size() && "Invalid register");
  return AliasMap[Reg];
}

DomainValue *ExeDepsFix::Alloc(int domain) {
  DomainValue *dv = Avail.empty() ?
                      new(Allocator.Allocate()) DomainValue :
                      Avail.pop_back_val();
  dv->Dist = Distance;
  if (domain >= 0)
    dv->addDomain(domain);
  return dv;
}

/// release - Release a reference to DV.  When the last reference is released,
/// collapse if needed.
void ExeDepsFix::release(DomainValue *DV) {
  assert(DV && DV->Refs && "Bad DomainValue");
  if (--DV->Refs)
    return;

  // There are no more DV references. Collapse any contained instructions.
  if (DV->AvailableDomains && !DV->isCollapsed())
    Collapse(DV, DV->getFirstDomain());

  DV->clear();
  Avail.push_back(DV);
}

/// Set LiveRegs[rx] = dv, updating reference counts.
void ExeDepsFix::SetLiveReg(int rx, DomainValue *dv) {
  assert(unsigned(rx) < NumRegs && "Invalid index");
  if (!LiveRegs) {
    LiveRegs = new DomainValue*[NumRegs];
    std::fill(LiveRegs, LiveRegs+NumRegs, (DomainValue*)0);
  }

  if (LiveRegs[rx] == dv)
    return;
  if (LiveRegs[rx])
    release(LiveRegs[rx]);
  LiveRegs[rx] = dv;
  if (dv) ++dv->Refs;
}

// Kill register rx, recycle or collapse any DomainValue.
void ExeDepsFix::Kill(int rx) {
  assert(unsigned(rx) < NumRegs && "Invalid index");
  if (!LiveRegs || !LiveRegs[rx]) return;

  release(LiveRegs[rx]);
  LiveRegs[rx] = 0;
}

/// Force register rx into domain.
void ExeDepsFix::Force(int rx, unsigned domain) {
  assert(unsigned(rx) < NumRegs && "Invalid index");
  DomainValue *dv;
  if (LiveRegs && (dv = LiveRegs[rx])) {
    if (dv->isCollapsed())
      dv->addDomain(domain);
    else if (dv->hasDomain(domain))
      Collapse(dv, domain);
    else {
      // This is an incompatible open DomainValue. Collapse it to whatever and
      // force the new value into domain. This costs a domain crossing.
      Collapse(dv, dv->getFirstDomain());
      assert(LiveRegs[rx] && "Not live after collapse?");
      LiveRegs[rx]->addDomain(domain);
    }
  } else {
    // Set up basic collapsed DomainValue.
    SetLiveReg(rx, Alloc(domain));
  }
}

/// Collapse open DomainValue into given domain. If there are multiple
/// registers using dv, they each get a unique collapsed DomainValue.
void ExeDepsFix::Collapse(DomainValue *dv, unsigned domain) {
  assert(dv->hasDomain(domain) && "Cannot collapse");

  // Collapse all the instructions.
  while (!dv->Instrs.empty())
    TII->setExecutionDomain(dv->Instrs.pop_back_val(), domain);
  dv->setSingleDomain(domain);

  // If there are multiple users, give them new, unique DomainValues.
  if (LiveRegs && dv->Refs > 1)
    for (unsigned rx = 0; rx != NumRegs; ++rx)
      if (LiveRegs[rx] == dv)
        SetLiveReg(rx, Alloc(domain));
}

/// Merge - All instructions and registers in B are moved to A, and B is
/// released.
bool ExeDepsFix::Merge(DomainValue *A, DomainValue *B) {
  assert(!A->isCollapsed() && "Cannot merge into collapsed");
  assert(!B->isCollapsed() && "Cannot merge from collapsed");
  if (A == B)
    return true;
  // Restrict to the domains that A and B have in common.
  unsigned common = A->getCommonDomains(B->AvailableDomains);
  if (!common)
    return false;
  A->AvailableDomains = common;
  A->Dist = std::max(A->Dist, B->Dist);
  A->Instrs.append(B->Instrs.begin(), B->Instrs.end());

  // Clear the old DomainValue so we won't try to swizzle instructions twice.
  B->Instrs.clear();
  B->AvailableDomains = 0;

  for (unsigned rx = 0; rx != NumRegs; ++rx)
    if (LiveRegs[rx] == B)
      SetLiveReg(rx, A);
  return true;
}

void ExeDepsFix::enterBasicBlock(MachineBasicBlock *MBB) {
  // Try to coalesce live-out registers from predecessors.
  for (MachineBasicBlock::livein_iterator i = MBB->livein_begin(),
         e = MBB->livein_end(); i != e; ++i) {
    int rx = RegIndex(*i);
    if (rx < 0) continue;
    for (MachineBasicBlock::const_pred_iterator pi = MBB->pred_begin(),
           pe = MBB->pred_end(); pi != pe; ++pi) {
      LiveOutMap::const_iterator fi = LiveOuts.find(*pi);
      if (fi == LiveOuts.end()) continue;
      DomainValue *pdv = fi->second[rx];
      if (!pdv || !pdv->AvailableDomains) continue;
      if (!LiveRegs || !LiveRegs[rx]) {
        SetLiveReg(rx, pdv);
        continue;
      }

      // We have a live DomainValue from more than one predecessor.
      if (LiveRegs[rx]->isCollapsed()) {
        // We are already collapsed, but predecessor is not. Force him.
        unsigned domain = LiveRegs[rx]->getFirstDomain();
        if (!pdv->isCollapsed() && pdv->hasDomain(domain))
          Collapse(pdv, domain);
        continue;
      }

      // Currently open, merge in predecessor.
      if (!pdv->isCollapsed())
        Merge(LiveRegs[rx], pdv);
      else
        Force(rx, pdv->getFirstDomain());
    }
  }
}

void ExeDepsFix::leaveBasicBlock(MachineBasicBlock *MBB) {
  // Save live registers at end of MBB - used by enterBasicBlock().
  if (LiveRegs)
    LiveOuts.insert(std::make_pair(MBB, LiveRegs));
  LiveRegs = 0;
}

void ExeDepsFix::visitInstr(MachineInstr *MI) {
  if (MI->isDebugValue())
    return;
  ++Distance;
  std::pair<uint16_t, uint16_t> domp = TII->getExecutionDomain(MI);
  if (domp.first)
    if (domp.second)
      visitSoftInstr(MI, domp.second);
    else
      visitHardInstr(MI, domp.first);
  else if (LiveRegs)
    visitGenericInstr(MI);
}

// A hard instruction only works in one domain. All input registers will be
// forced into that domain.
void ExeDepsFix::visitHardInstr(MachineInstr *mi, unsigned domain) {
  // Collapse all uses.
  for (unsigned i = mi->getDesc().getNumDefs(),
                e = mi->getDesc().getNumOperands(); i != e; ++i) {
    MachineOperand &mo = mi->getOperand(i);
    if (!mo.isReg()) continue;
    int rx = RegIndex(mo.getReg());
    if (rx < 0) continue;
    Force(rx, domain);
  }

  // Kill all defs and force them.
  for (unsigned i = 0, e = mi->getDesc().getNumDefs(); i != e; ++i) {
    MachineOperand &mo = mi->getOperand(i);
    if (!mo.isReg()) continue;
    int rx = RegIndex(mo.getReg());
    if (rx < 0) continue;
    Kill(rx);
    Force(rx, domain);
  }
}

// A soft instruction can be changed to work in other domains given by mask.
void ExeDepsFix::visitSoftInstr(MachineInstr *mi, unsigned mask) {
  // Bitmask of available domains for this instruction after taking collapsed
  // operands into account.
  unsigned available = mask;

  // Scan the explicit use operands for incoming domains.
  SmallVector<int, 4> used;
  if (LiveRegs)
    for (unsigned i = mi->getDesc().getNumDefs(),
                  e = mi->getDesc().getNumOperands(); i != e; ++i) {
      MachineOperand &mo = mi->getOperand(i);
      if (!mo.isReg()) continue;
      int rx = RegIndex(mo.getReg());
      if (rx < 0) continue;
      if (DomainValue *dv = LiveRegs[rx]) {
        // Bitmask of domains that dv and available have in common.
        unsigned common = dv->getCommonDomains(available);
        // Is it possible to use this collapsed register for free?
        if (dv->isCollapsed()) {
          // Restrict available domains to the ones in common with the operand.
          // If there are no common domains, we must pay the cross-domain 
          // penalty for this operand.
          if (common) available = common;
        } else if (common)
          // Open DomainValue is compatible, save it for merging.
          used.push_back(rx);
        else
          // Open DomainValue is not compatible with instruction. It is useless
          // now.
          Kill(rx);
      }
    }

  // If the collapsed operands force a single domain, propagate the collapse.
  if (isPowerOf2_32(available)) {
    unsigned domain = CountTrailingZeros_32(available);
    TII->setExecutionDomain(mi, domain);
    visitHardInstr(mi, domain);
    return;
  }

  // Kill off any remaining uses that don't match available, and build a list of
  // incoming DomainValues that we want to merge.
  SmallVector<DomainValue*,4> doms;
  for (SmallVector<int, 4>::iterator i=used.begin(), e=used.end(); i!=e; ++i) {
    int rx = *i;
    DomainValue *dv = LiveRegs[rx];
    // This useless DomainValue could have been missed above.
    if (!dv->getCommonDomains(available)) {
      Kill(*i);
      continue;
    }
    // sorted, uniqued insert.
    bool inserted = false;
    for (SmallVector<DomainValue*,4>::iterator i = doms.begin(), e = doms.end();
           i != e && !inserted; ++i) {
      if (dv == *i)
        inserted = true;
      else if (dv->Dist < (*i)->Dist) {
        inserted = true;
        doms.insert(i, dv);
      }
    }
    if (!inserted)
      doms.push_back(dv);
  }

  // doms are now sorted in order of appearance. Try to merge them all, giving
  // priority to the latest ones.
  DomainValue *dv = 0;
  while (!doms.empty()) {
    if (!dv) {
      dv = doms.pop_back_val();
      continue;
    }

    DomainValue *latest = doms.pop_back_val();
    if (Merge(dv, latest)) continue;

    // If latest didn't merge, it is useless now. Kill all registers using it.
    for (SmallVector<int,4>::iterator i=used.begin(), e=used.end(); i != e; ++i)
      if (LiveRegs[*i] == latest)
        Kill(*i);
  }

  // dv is the DomainValue we are going to use for this instruction.
  if (!dv)
    dv = Alloc();
  dv->Dist = Distance;
  dv->AvailableDomains = available;
  dv->Instrs.push_back(mi);

  // Finally set all defs and non-collapsed uses to dv.
  for (unsigned i = 0, e = mi->getDesc().getNumOperands(); i != e; ++i) {
    MachineOperand &mo = mi->getOperand(i);
    if (!mo.isReg()) continue;
    int rx = RegIndex(mo.getReg());
    if (rx < 0) continue;
    if (!LiveRegs || !LiveRegs[rx] || (mo.isDef() && LiveRegs[rx]!=dv)) {
      Kill(rx);
      SetLiveReg(rx, dv);
    }
  }
}

void ExeDepsFix::visitGenericInstr(MachineInstr *mi) {
  // Process explicit defs, kill any relevant registers redefined.
  for (unsigned i = 0, e = mi->getDesc().getNumDefs(); i != e; ++i) {
    MachineOperand &mo = mi->getOperand(i);
    if (!mo.isReg()) continue;
    int rx = RegIndex(mo.getReg());
    if (rx < 0) continue;
    Kill(rx);
  }
}

bool ExeDepsFix::runOnMachineFunction(MachineFunction &mf) {
  MF = &mf;
  TII = MF->getTarget().getInstrInfo();
  TRI = MF->getTarget().getRegisterInfo();
  LiveRegs = 0;
  Distance = 0;
  assert(NumRegs == RC->getNumRegs() && "Bad regclass");

  // If no relevant registers are used in the function, we can skip it
  // completely.
  bool anyregs = false;
  for (TargetRegisterClass::const_iterator I = RC->begin(), E = RC->end();
       I != E; ++I)
    if (MF->getRegInfo().isPhysRegUsed(*I)) {
      anyregs = true;
      break;
    }
  if (!anyregs) return false;

  // Initialize the AliasMap on the first use.
  if (AliasMap.empty()) {
    // Given a PhysReg, AliasMap[PhysReg] is either the relevant index into RC,
    // or -1.
    AliasMap.resize(TRI->getNumRegs(), -1);
    for (unsigned i = 0, e = RC->getNumRegs(); i != e; ++i)
      for (const unsigned *AI = TRI->getOverlaps(RC->getRegister(i)); *AI; ++AI)
        AliasMap[*AI] = i;
  }

  MachineBasicBlock *Entry = MF->begin();
  ReversePostOrderTraversal<MachineBasicBlock*> RPOT(Entry);
  for (ReversePostOrderTraversal<MachineBasicBlock*>::rpo_iterator
         MBBI = RPOT.begin(), MBBE = RPOT.end(); MBBI != MBBE; ++MBBI) {
    MachineBasicBlock *MBB = *MBBI;
    enterBasicBlock(MBB);
    for (MachineBasicBlock::iterator I = MBB->begin(), E = MBB->end(); I != E;
        ++I)
      visitInstr(I);
    leaveBasicBlock(MBB);
  }

  // Clear the LiveOuts vectors and collapse any remaining DomainValues.
  for (ReversePostOrderTraversal<MachineBasicBlock*>::rpo_iterator
         MBBI = RPOT.begin(), MBBE = RPOT.end(); MBBI != MBBE; ++MBBI) {
    LiveOutMap::const_iterator FI = LiveOuts.find(*MBBI);
    if (FI == LiveOuts.end())
      continue;
    assert(FI->second && "Null entry");
    // The DomainValue is collapsed when the last reference is killed.
    LiveRegs = FI->second;
    for (unsigned i = 0, e = NumRegs; i != e; ++i)
      if (LiveRegs[i])
        Kill(i);
    delete[] LiveRegs;
  }
  LiveOuts.clear();
  Avail.clear();
  Allocator.DestroyAll();

  return false;
}

FunctionPass *
llvm::createExecutionDependencyFixPass(const TargetRegisterClass *RC) {
  return new ExeDepsFix(RC);
}
