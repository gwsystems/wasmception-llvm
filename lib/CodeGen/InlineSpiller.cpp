//===-------- InlineSpiller.cpp - Insert spills and restores inline -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The inline spiller modifies the machine function directly instead of
// inserting spills and restores in VirtRegMap.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "spiller"
#include "Spiller.h"
#include "LiveRangeEdit.h"
#include "SplitKit.h"
#include "VirtRegMap.h"
#include "llvm/CodeGen/LiveIntervalAnalysis.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class InlineSpiller : public Spiller {
  MachineFunctionPass &pass_;
  MachineFunction &mf_;
  LiveIntervals &lis_;
  MachineLoopInfo &loops_;
  VirtRegMap &vrm_;
  MachineFrameInfo &mfi_;
  MachineRegisterInfo &mri_;
  const TargetInstrInfo &tii_;
  const TargetRegisterInfo &tri_;
  const BitVector reserved_;

  SplitAnalysis splitAnalysis_;

  // Variables that are valid during spill(), but used by multiple methods.
  LiveRangeEdit *edit_;
  const TargetRegisterClass *rc_;
  int stackSlot_;

  // Values of the current interval that can potentially remat.
  SmallPtrSet<VNInfo*, 8> reMattable_;

  // Values in reMattable_ that failed to remat at some point.
  SmallPtrSet<VNInfo*, 8> usedValues_;

  ~InlineSpiller() {}

public:
  InlineSpiller(MachineFunctionPass &pass,
                MachineFunction &mf,
                VirtRegMap &vrm)
    : pass_(pass),
      mf_(mf),
      lis_(pass.getAnalysis<LiveIntervals>()),
      loops_(pass.getAnalysis<MachineLoopInfo>()),
      vrm_(vrm),
      mfi_(*mf.getFrameInfo()),
      mri_(mf.getRegInfo()),
      tii_(*mf.getTarget().getInstrInfo()),
      tri_(*mf.getTarget().getRegisterInfo()),
      reserved_(tri_.getReservedRegs(mf_)),
      splitAnalysis_(mf, lis_, loops_) {}

  void spill(LiveInterval *li,
             SmallVectorImpl<LiveInterval*> &newIntervals,
             SmallVectorImpl<LiveInterval*> &spillIs);

  void spill(LiveRangeEdit &);

private:
  bool split();

  bool reMaterializeFor(MachineBasicBlock::iterator MI);
  void reMaterializeAll();

  bool coalesceStackAccess(MachineInstr *MI);
  bool foldMemoryOperand(MachineBasicBlock::iterator MI,
                         const SmallVectorImpl<unsigned> &Ops);
  void insertReload(LiveInterval &NewLI, MachineBasicBlock::iterator MI);
  void insertSpill(LiveInterval &NewLI, MachineBasicBlock::iterator MI);
};
}

namespace llvm {
Spiller *createInlineSpiller(MachineFunctionPass &pass,
                             MachineFunction &mf,
                             VirtRegMap &vrm) {
  return new InlineSpiller(pass, mf, vrm);
}
}

/// split - try splitting the current interval into pieces that may allocate
/// separately. Return true if successful.
bool InlineSpiller::split() {
  splitAnalysis_.analyze(&edit_->getParent());

  // Try splitting around loops.
  if (const MachineLoop *loop = splitAnalysis_.getBestSplitLoop()) {
    SplitEditor(splitAnalysis_, lis_, vrm_, *edit_)
      .splitAroundLoop(loop);
    return true;
  }

  // Try splitting into single block intervals.
  SplitAnalysis::BlockPtrSet blocks;
  if (splitAnalysis_.getMultiUseBlocks(blocks)) {
    SplitEditor(splitAnalysis_, lis_, vrm_, *edit_)
      .splitSingleBlocks(blocks);
    return true;
  }

  // Try splitting inside a basic block.
  if (const MachineBasicBlock *MBB = splitAnalysis_.getBlockForInsideSplit()) {
    SplitEditor(splitAnalysis_, lis_, vrm_, *edit_)
      .splitInsideBlock(MBB);
    return true;
  }

  return false;
}

/// reMaterializeFor - Attempt to rematerialize edit_->getReg() before MI instead of
/// reloading it.
bool InlineSpiller::reMaterializeFor(MachineBasicBlock::iterator MI) {
  SlotIndex UseIdx = lis_.getInstructionIndex(MI).getUseIndex();
  VNInfo *OrigVNI = edit_->getParent().getVNInfoAt(UseIdx);
  if (!OrigVNI) {
    DEBUG(dbgs() << "\tadding <undef> flags: ");
    for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
      MachineOperand &MO = MI->getOperand(i);
      if (MO.isReg() && MO.isUse() && MO.getReg() == edit_->getReg())
        MO.setIsUndef();
    }
    DEBUG(dbgs() << UseIdx << '\t' << *MI);
    return true;
  }
  if (!reMattable_.count(OrigVNI)) {
    DEBUG(dbgs() << "\tusing non-remat valno " << OrigVNI->id << ": "
                 << UseIdx << '\t' << *MI);
    return false;
  }
  MachineInstr *OrigMI = lis_.getInstructionFromIndex(OrigVNI->def);
  if (!edit_->allUsesAvailableAt(OrigMI, OrigVNI->def, UseIdx, lis_)) {
    usedValues_.insert(OrigVNI);
    DEBUG(dbgs() << "\tcannot remat for " << UseIdx << '\t' << *MI);
    return false;
  }

  // If the instruction also writes edit_->getReg(), it had better not require the same
  // register for uses and defs.
  bool Reads, Writes;
  SmallVector<unsigned, 8> Ops;
  tie(Reads, Writes) = MI->readsWritesVirtualRegister(edit_->getReg(), &Ops);
  if (Writes) {
    for (unsigned i = 0, e = Ops.size(); i != e; ++i) {
      MachineOperand &MO = MI->getOperand(Ops[i]);
      if (MO.isUse() ? MI->isRegTiedToDefOperand(Ops[i]) : MO.getSubReg()) {
        usedValues_.insert(OrigVNI);
        DEBUG(dbgs() << "\tcannot remat tied reg: " << UseIdx << '\t' << *MI);
        return false;
      }
    }
  }

  // Alocate a new register for the remat.
  LiveInterval &NewLI = edit_->create(mri_, lis_, vrm_);
  NewLI.markNotSpillable();

  // Finally we can rematerialize OrigMI before MI.
  MachineBasicBlock &MBB = *MI->getParent();
  tii_.reMaterialize(MBB, MI, NewLI.reg, 0, OrigMI, tri_);
  MachineBasicBlock::iterator RematMI = MI;
  SlotIndex DefIdx = lis_.InsertMachineInstrInMaps(--RematMI).getDefIndex();
  DEBUG(dbgs() << "\tremat:  " << DefIdx << '\t' << *RematMI);

  // Replace operands
  for (unsigned i = 0, e = Ops.size(); i != e; ++i) {
    MachineOperand &MO = MI->getOperand(Ops[i]);
    if (MO.isReg() && MO.isUse() && MO.getReg() == edit_->getReg()) {
      MO.setReg(NewLI.reg);
      MO.setIsKill();
    }
  }
  DEBUG(dbgs() << "\t        " << UseIdx << '\t' << *MI);

  VNInfo *DefVNI = NewLI.getNextValue(DefIdx, 0, lis_.getVNInfoAllocator());
  NewLI.addRange(LiveRange(DefIdx, UseIdx.getDefIndex(), DefVNI));
  DEBUG(dbgs() << "\tinterval: " << NewLI << '\n');
  return true;
}

/// reMaterializeAll - Try to rematerialize as many uses as possible,
/// and trim the live ranges after.
void InlineSpiller::reMaterializeAll() {
  // Do a quick scan of the interval values to find if any are remattable.
  reMattable_.clear();
  usedValues_.clear();
  for (LiveInterval::const_vni_iterator I = edit_->getParent().vni_begin(),
       E = edit_->getParent().vni_end(); I != E; ++I) {
    VNInfo *VNI = *I;
    if (VNI->isUnused())
      continue;
    MachineInstr *DefMI = lis_.getInstructionFromIndex(VNI->def);
    if (!DefMI || !tii_.isTriviallyReMaterializable(DefMI))
      continue;
    reMattable_.insert(VNI);
  }

  // Often, no defs are remattable.
  if (reMattable_.empty())
    return;

  // Try to remat before all uses of edit_->getReg().
  bool anyRemat = false;
  for (MachineRegisterInfo::use_nodbg_iterator
       RI = mri_.use_nodbg_begin(edit_->getReg());
       MachineInstr *MI = RI.skipInstruction();)
     anyRemat |= reMaterializeFor(MI);

  if (!anyRemat)
    return;

  // Remove any values that were completely rematted.
  bool anyRemoved = false;
  for (SmallPtrSet<VNInfo*, 8>::iterator I = reMattable_.begin(),
       E = reMattable_.end(); I != E; ++I) {
    VNInfo *VNI = *I;
    if (VNI->hasPHIKill() || usedValues_.count(VNI))
      continue;
    MachineInstr *DefMI = lis_.getInstructionFromIndex(VNI->def);
    DEBUG(dbgs() << "\tremoving dead def: " << VNI->def << '\t' << *DefMI);
    lis_.RemoveMachineInstrFromMaps(DefMI);
    vrm_.RemoveMachineInstrFromMaps(DefMI);
    DefMI->eraseFromParent();
    VNI->def = SlotIndex();
    anyRemoved = true;
  }

  if (!anyRemoved)
    return;

  // Removing values may cause debug uses where parent is not live.
  for (MachineRegisterInfo::use_iterator RI = mri_.use_begin(edit_->getReg());
       MachineInstr *MI = RI.skipInstruction();) {
    if (!MI->isDebugValue())
      continue;
    // Try to preserve the debug value if parent is live immediately after it.
    MachineBasicBlock::iterator NextMI = MI;
    ++NextMI;
    if (NextMI != MI->getParent()->end() && !lis_.isNotInMIMap(NextMI)) {
      SlotIndex Idx = lis_.getInstructionIndex(NextMI);
      VNInfo *VNI = edit_->getParent().getVNInfoAt(Idx);
      if (VNI && (VNI->hasPHIKill() || usedValues_.count(VNI)))
        continue;
    }
    DEBUG(dbgs() << "Removing debug info due to remat:" << "\t" << *MI);
    MI->eraseFromParent();
  }
}

/// If MI is a load or store of stackSlot_, it can be removed.
bool InlineSpiller::coalesceStackAccess(MachineInstr *MI) {
  int FI = 0;
  unsigned reg;
  if (!(reg = tii_.isLoadFromStackSlot(MI, FI)) &&
      !(reg = tii_.isStoreToStackSlot(MI, FI)))
    return false;

  // We have a stack access. Is it the right register and slot?
  if (reg != edit_->getReg() || FI != stackSlot_)
    return false;

  DEBUG(dbgs() << "Coalescing stack access: " << *MI);
  lis_.RemoveMachineInstrFromMaps(MI);
  MI->eraseFromParent();
  return true;
}

/// foldMemoryOperand - Try folding stack slot references in Ops into MI.
/// Return true on success, and MI will be erased.
bool InlineSpiller::foldMemoryOperand(MachineBasicBlock::iterator MI,
                                      const SmallVectorImpl<unsigned> &Ops) {
  // TargetInstrInfo::foldMemoryOperand only expects explicit, non-tied
  // operands.
  SmallVector<unsigned, 8> FoldOps;
  for (unsigned i = 0, e = Ops.size(); i != e; ++i) {
    unsigned Idx = Ops[i];
    MachineOperand &MO = MI->getOperand(Idx);
    if (MO.isImplicit())
      continue;
    // FIXME: Teach targets to deal with subregs.
    if (MO.getSubReg())
      return false;
    // Tied use operands should not be passed to foldMemoryOperand.
    if (!MI->isRegTiedToDefOperand(Idx))
      FoldOps.push_back(Idx);
  }

  MachineInstr *FoldMI = tii_.foldMemoryOperand(MI, FoldOps, stackSlot_);
  if (!FoldMI)
    return false;
  lis_.ReplaceMachineInstrInMaps(MI, FoldMI);
  vrm_.addSpillSlotUse(stackSlot_, FoldMI);
  MI->eraseFromParent();
  DEBUG(dbgs() << "\tfolded: " << *FoldMI);
  return true;
}

/// insertReload - Insert a reload of NewLI.reg before MI.
void InlineSpiller::insertReload(LiveInterval &NewLI,
                                 MachineBasicBlock::iterator MI) {
  MachineBasicBlock &MBB = *MI->getParent();
  SlotIndex Idx = lis_.getInstructionIndex(MI).getDefIndex();
  tii_.loadRegFromStackSlot(MBB, MI, NewLI.reg, stackSlot_, rc_, &tri_);
  --MI; // Point to load instruction.
  SlotIndex LoadIdx = lis_.InsertMachineInstrInMaps(MI).getDefIndex();
  vrm_.addSpillSlotUse(stackSlot_, MI);
  DEBUG(dbgs() << "\treload:  " << LoadIdx << '\t' << *MI);
  VNInfo *LoadVNI = NewLI.getNextValue(LoadIdx, 0,
                                       lis_.getVNInfoAllocator());
  NewLI.addRange(LiveRange(LoadIdx, Idx, LoadVNI));
}

/// insertSpill - Insert a spill of NewLI.reg after MI.
void InlineSpiller::insertSpill(LiveInterval &NewLI,
                                MachineBasicBlock::iterator MI) {
  MachineBasicBlock &MBB = *MI->getParent();
  SlotIndex Idx = lis_.getInstructionIndex(MI).getDefIndex();
  tii_.storeRegToStackSlot(MBB, ++MI, NewLI.reg, true, stackSlot_, rc_, &tri_);
  --MI; // Point to store instruction.
  SlotIndex StoreIdx = lis_.InsertMachineInstrInMaps(MI).getDefIndex();
  vrm_.addSpillSlotUse(stackSlot_, MI);
  DEBUG(dbgs() << "\tspilled: " << StoreIdx << '\t' << *MI);
  VNInfo *StoreVNI = NewLI.getNextValue(Idx, 0, lis_.getVNInfoAllocator());
  NewLI.addRange(LiveRange(Idx, StoreIdx, StoreVNI));
}

void InlineSpiller::spill(LiveInterval *li,
                          SmallVectorImpl<LiveInterval*> &newIntervals,
                          SmallVectorImpl<LiveInterval*> &spillIs) {
  LiveRangeEdit edit(*li, newIntervals, spillIs);
  spill(edit);
}

void InlineSpiller::spill(LiveRangeEdit &edit) {
  edit_ = &edit;
  DEBUG(dbgs() << "Inline spilling " << edit.getParent() << "\n");
  assert(edit.getParent().isSpillable() &&
         "Attempting to spill already spilled value.");
  assert(!edit.getParent().isStackSlot() && "Trying to spill a stack slot.");

  if (split())
    return;

  reMaterializeAll();

  // Remat may handle everything.
  if (edit_->getParent().empty())
    return;

  rc_ = mri_.getRegClass(edit.getReg());
  stackSlot_ = edit.assignStackSlot(vrm_);

  // Iterate over instructions using register.
  for (MachineRegisterInfo::reg_iterator RI = mri_.reg_begin(edit.getReg());
       MachineInstr *MI = RI.skipInstruction();) {

    // Debug values are not allowed to affect codegen.
    if (MI->isDebugValue()) {
      // Modify DBG_VALUE now that the value is in a spill slot.
      uint64_t Offset = MI->getOperand(1).getImm();
      const MDNode *MDPtr = MI->getOperand(2).getMetadata();
      DebugLoc DL = MI->getDebugLoc();
      if (MachineInstr *NewDV = tii_.emitFrameIndexDebugValue(mf_, stackSlot_,
                                                           Offset, MDPtr, DL)) {
        DEBUG(dbgs() << "Modifying debug info due to spill:" << "\t" << *MI);
        MachineBasicBlock *MBB = MI->getParent();
        MBB->insert(MBB->erase(MI), NewDV);
      } else {
        DEBUG(dbgs() << "Removing debug info due to spill:" << "\t" << *MI);
        MI->eraseFromParent();
      }
      continue;
    }

    // Stack slot accesses may coalesce away.
    if (coalesceStackAccess(MI))
      continue;

    // Analyze instruction.
    bool Reads, Writes;
    SmallVector<unsigned, 8> Ops;
    tie(Reads, Writes) = MI->readsWritesVirtualRegister(edit.getReg(), &Ops);

    // Attempt to fold memory ops.
    if (foldMemoryOperand(MI, Ops))
      continue;

    // Allocate interval around instruction.
    // FIXME: Infer regclass from instruction alone.
    LiveInterval &NewLI = edit.create(mri_, lis_, vrm_);
    NewLI.markNotSpillable();

    if (Reads)
      insertReload(NewLI, MI);

    // Rewrite instruction operands.
    bool hasLiveDef = false;
    for (unsigned i = 0, e = Ops.size(); i != e; ++i) {
      MachineOperand &MO = MI->getOperand(Ops[i]);
      MO.setReg(NewLI.reg);
      if (MO.isUse()) {
        if (!MI->isRegTiedToDefOperand(Ops[i]))
          MO.setIsKill();
      } else {
        if (!MO.isDead())
          hasLiveDef = true;
      }
    }

    // FIXME: Use a second vreg if instruction has no tied ops.
    if (Writes && hasLiveDef)
      insertSpill(NewLI, MI);

    DEBUG(dbgs() << "\tinterval: " << NewLI << '\n');
  }
}
