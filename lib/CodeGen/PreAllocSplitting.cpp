//===-- PreAllocSplitting.cpp - Pre-allocation Interval Spltting Pass. ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the machine instruction level pre-register allocation
// live interval splitting pass. It finds live interval barriers, i.e.
// instructions which will kill all physical registers in certain register
// classes, and split all live intervals which cross the barrier.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "pre-alloc-split"
#include "llvm/CodeGen/LiveIntervalAnalysis.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/RegisterCoalescer.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include <map>
using namespace llvm;

STATISTIC(NumSplit     , "Number of intervals split");

namespace {
  class VISIBILITY_HIDDEN PreAllocSplitting : public MachineFunctionPass {
    MachineFunction       *CurMF;
    const TargetMachine   *TM;
    const TargetInstrInfo *TII;
    MachineFrameInfo      *MFI;
    MachineRegisterInfo   *MRI;
    LiveIntervals         *LIs;

    // Barrier - Current barrier being processed.
    MachineInstr          *Barrier;

    // BarrierMBB - Basic block where the barrier resides in.
    MachineBasicBlock     *BarrierMBB;

    // Barrier - Current barrier index.
    unsigned              BarrierIdx;

    // CurrLI - Current live interval being split.
    LiveInterval          *CurrLI;

    // LIValNoSSMap - A map from live interval and val# pairs to spill slots.
    // This records what live interval's val# has been split and what spill
    // slot was used.
    std::map<std::pair<unsigned, unsigned>, int> LIValNoSSMap;

  public:
    static char ID;
    PreAllocSplitting() : MachineFunctionPass(&ID) {}

    virtual bool runOnMachineFunction(MachineFunction &MF);

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.addRequired<LiveIntervals>();
      AU.addPreserved<LiveIntervals>();
      AU.addPreserved<RegisterCoalescer>();
      if (StrongPHIElim)
        AU.addPreservedID(StrongPHIEliminationID);
      else
        AU.addPreservedID(PHIEliminationID);
      MachineFunctionPass::getAnalysisUsage(AU);
    }
    
    virtual void releaseMemory() {
      LIValNoSSMap.clear();
    }

    virtual const char *getPassName() const {
      return "Pre-Register Allocaton Live Interval Splitting";
    }

    /// print - Implement the dump method.
    virtual void print(std::ostream &O, const Module* M = 0) const {
      LIs->print(O, M);
    }

    void print(std::ostream *O, const Module* M = 0) const {
      if (O) print(*O, M);
    }

  private:
    MachineBasicBlock::iterator
      findNextEmptySlot(MachineBasicBlock*, MachineInstr*,
                        unsigned&);

    MachineBasicBlock::iterator
      findSpillPoint(MachineBasicBlock*, MachineInstr*,
                     SmallPtrSet<MachineInstr*, 4>&, unsigned&);

    MachineBasicBlock::iterator
      findRestorePoint(MachineBasicBlock*, MachineInstr*,
                     SmallPtrSet<MachineInstr*, 4>&, unsigned&);

    void RecordSplit(unsigned, unsigned, unsigned, int);

    bool isAlreadySplit(unsigned, unsigned, int&);

    void UpdateIntervalForSplit(VNInfo*, unsigned, unsigned);

    bool ShrinkWrapToLastUse(MachineBasicBlock*,
                             std::vector<MachineOperand*>&);

    void ShrinkWrapLiveInterval(VNInfo*, MachineBasicBlock*,
                        MachineBasicBlock*, SmallPtrSet<MachineBasicBlock*, 8>&,
                            DenseMap<unsigned, std::vector<MachineOperand*> >&);

    bool SplitRegLiveInterval(LiveInterval*);

    bool SplitRegLiveIntervals(const TargetRegisterClass **);
  };
} // end anonymous namespace

char PreAllocSplitting::ID = 0;

static RegisterPass<PreAllocSplitting>
X("pre-alloc-splitting", "Pre-Register Allocation Live Interval Splitting");

const PassInfo *const llvm::PreAllocSplittingID = &X;


/// findNextEmptySlot - Find a gap after the given machine instruction in the
/// instruction index map. If there isn't one, return end().
MachineBasicBlock::iterator
PreAllocSplitting::findNextEmptySlot(MachineBasicBlock *MBB, MachineInstr *MI,
                                     unsigned &SpotIndex) {
  MachineBasicBlock::iterator MII = MI;
  if (++MII != MBB->end()) {
    unsigned Index = LIs->findGapBeforeInstr(LIs->getInstructionIndex(MII));
    if (Index) {
      SpotIndex = Index;
      return MII;
    }
  }
  return MBB->end();
}

/// findSpillPoint - Find a gap as far away from the given MI that's suitable
/// for spilling the current live interval. The index must be before any
/// defs and uses of the live interval register in the mbb. Return begin() if
/// none is found.
MachineBasicBlock::iterator
PreAllocSplitting::findSpillPoint(MachineBasicBlock *MBB, MachineInstr *MI,
                                  SmallPtrSet<MachineInstr*, 4> &RefsInMBB,
                                  unsigned &SpillIndex) {
  MachineBasicBlock::iterator Pt = MBB->begin();

  // Go top down if RefsInMBB is empty.
  if (RefsInMBB.empty()) {
    MachineBasicBlock::iterator MII = MBB->begin();
    MachineBasicBlock::iterator EndPt = MI;
    do {
      ++MII;
      unsigned Index = LIs->getInstructionIndex(MII);
      unsigned Gap = LIs->findGapBeforeInstr(Index);
      if (Gap) {
        Pt = MII;
        SpillIndex = Gap;
        break;
      }
    } while (MII != EndPt);
  } else {
    MachineBasicBlock::iterator MII = MI;
    while (MII != MBB->begin() && !RefsInMBB.count(MII)) {
      unsigned Index = LIs->getInstructionIndex(MII);
      if (LIs->hasGapBeforeInstr(Index)) {
        Pt = MII;
        SpillIndex = LIs->findGapBeforeInstr(Index, true);
      }
      --MII;
    }
  }

  return Pt;
}

/// findRestorePoint - Find a gap in the instruction index map that's suitable
/// for restoring the current live interval value. The index must be before any
/// uses of the live interval register in the mbb. Return end() if none is
/// found.
MachineBasicBlock::iterator
PreAllocSplitting::findRestorePoint(MachineBasicBlock *MBB, MachineInstr *MI,
                                    SmallPtrSet<MachineInstr*, 4> &RefsInMBB,
                                    unsigned &RestoreIndex) {
  MachineBasicBlock::iterator Pt = MBB->end();

  // Go bottom up if RefsInMBB is empty.
  if (RefsInMBB.empty()) {
    MachineBasicBlock::iterator MII = MBB->end();
    MachineBasicBlock::iterator EndPt = MI;
    do {
      --MII;
      unsigned Index = LIs->getInstructionIndex(MII);
      unsigned Gap = LIs->hasGapBeforeInstr(Index);
      if (Gap) {
        Pt = MII;
        RestoreIndex = Gap;
        break;
      }
    } while (MII != EndPt);
  } else {
    MachineBasicBlock::iterator MII = MI;
    MII = ++MII;
    while (MII != MBB->end()) {
      unsigned Index = LIs->getInstructionIndex(MII);
      unsigned Gap = LIs->findGapBeforeInstr(Index);
      if (Gap) {
        Pt = MII;
        RestoreIndex = Gap;
      }
      if (RefsInMBB.count(MII))
        break;
      ++MII;
    }
  }

  return Pt;
}

/// RecordSplit - Given a register live interval is split, remember the spill
/// slot where the val#s are in.
void PreAllocSplitting::RecordSplit(unsigned Reg, unsigned SpillIndex,
                                    unsigned RestoreIndex, int SS) {
  LiveInterval::iterator LR =
    CurrLI->FindLiveRangeContaining(LIs->getUseIndex(SpillIndex));
  LIValNoSSMap.insert(std::make_pair(std::make_pair(CurrLI->reg, LR->valno->id),
                                     SS));
  LR = CurrLI->FindLiveRangeContaining(LIs->getDefIndex(RestoreIndex));
  LIValNoSSMap.insert(std::make_pair(std::make_pair(CurrLI->reg, LR->valno->id),
                                     SS));
}

/// isAlreadySplit - Return if a given val# of a register live interval is already
/// split. Also return by reference the spill stock where the value is.
bool PreAllocSplitting::isAlreadySplit(unsigned Reg, unsigned ValNoId, int &SS){
  std::map<std::pair<unsigned, unsigned>, int>::iterator I =
    LIValNoSSMap.find(std::make_pair(Reg, ValNoId));
  if (I == LIValNoSSMap.end())
    return false;
  SS = I->second;
  return true;
}

/// UpdateIntervalForSplit - Given the specified val# of the current live
/// interval is being split, and the split and rejoin indices, update the live
/// interval accordingly.
void
PreAllocSplitting::UpdateIntervalForSplit(VNInfo *ValNo, unsigned SplitIndex,
                                          unsigned JoinIndex) {
  SmallVector<std::pair<unsigned,unsigned>, 4> Before;
  SmallVector<std::pair<unsigned,unsigned>, 4> After;
  SmallVector<unsigned, 4> BeforeKills;
  SmallVector<unsigned, 4> AfterKills;
  SmallPtrSet<const LiveRange*, 4> Processed;

  // First, let's figure out which parts of the live interval is now defined
  // by the restore, which are defined by the original definition.
  const LiveRange *LR = CurrLI->getLiveRangeContaining(JoinIndex);
  After.push_back(std::make_pair(JoinIndex, LR->end));
  assert(LR->contains(SplitIndex));
  Before.push_back(std::make_pair(LR->start, SplitIndex));
  BeforeKills.push_back(SplitIndex);
  Processed.insert(LR);

  SmallVector<MachineBasicBlock*, 4> WorkList;
  MachineBasicBlock *MBB = LIs->getMBBFromIndex(LR->end-1);
  for (MachineBasicBlock::succ_iterator SI = MBB->succ_begin(),
         SE = MBB->succ_end(); SI != SE; ++SI)
    WorkList.push_back(*SI);

  while (!WorkList.empty()) {
    MBB = WorkList.back();
    WorkList.pop_back();
    unsigned Idx = LIs->getMBBStartIdx(MBB);
    LR = CurrLI->getLiveRangeContaining(Idx);
    if (LR && LR->valno == ValNo && !Processed.count(LR)) {
      After.push_back(std::make_pair(LR->start, LR->end));
      if (CurrLI->isKill(ValNo, LR->end))
        AfterKills.push_back(LR->end);
      Idx = LIs->getMBBEndIdx(MBB);
      if (LR->end > Idx) {
        for (MachineBasicBlock::succ_iterator SI = MBB->succ_begin(),
               SE = MBB->succ_end(); SI != SE; ++SI)
          WorkList.push_back(*SI);
        if (LR->end > Idx+1) {
          MBB = LIs->getMBBFromIndex(LR->end-1);
          for (MachineBasicBlock::succ_iterator SI = MBB->succ_begin(),
                 SE = MBB->succ_end(); SI != SE; ++SI)
            WorkList.push_back(*SI);
        }
      }
      Processed.insert(LR);
    }
  }

  for (LiveInterval::iterator I = CurrLI->begin(), E = CurrLI->end();
       I != E; ++I) {
    LiveRange *LR = I;
    if (LR->valno == ValNo && !Processed.count(LR)) {
      Before.push_back(std::make_pair(LR->start, LR->end));
      if (CurrLI->isKill(ValNo, LR->end))
        BeforeKills.push_back(LR->end);
    }
  }

  // Now create new val#s to represent the live ranges defined by the old def
  // those defined by the restore.
  unsigned AfterDef = ValNo->def;
  MachineInstr *AfterCopy = ValNo->copy;
  bool HasPHIKill = ValNo->hasPHIKill;
  CurrLI->removeValNo(ValNo);
  VNInfo *BValNo = CurrLI->getNextValue(AfterDef, AfterCopy,
                                        LIs->getVNInfoAllocator());
  VNInfo *AValNo = CurrLI->getNextValue(JoinIndex,0, LIs->getVNInfoAllocator());
  AValNo->hasPHIKill = HasPHIKill;
  CurrLI->addKills(AValNo, AfterKills);
  CurrLI->addKills(BValNo, BeforeKills);

  for (unsigned i = 0, e = Before.size(); i != e; ++i) {
    unsigned Start = Before[i].first;
    unsigned End   = Before[i].second;
    CurrLI->addRange(LiveRange(Start, End, BValNo));
  }
  for (unsigned i = 0, e = After.size(); i != e; ++i) {
    unsigned Start = After[i].first;
    unsigned End   = After[i].second;
    CurrLI->addRange(LiveRange(Start, End, AValNo));
  }
}

/// ShrinkWrapToLastUse - There are uses of the current live interval in the
/// given block, shrink wrap the live interval to the last use (i.e. remove
/// from last use to the end of the mbb). In case mbb is the where the barrier
/// is, remove from the last use to the barrier.
bool
PreAllocSplitting::ShrinkWrapToLastUse(MachineBasicBlock *MBB,
                                       std::vector<MachineOperand*> &Uses) {
  MachineOperand *LastMO = 0;
  MachineInstr *LastMI = 0;
  if (MBB != BarrierMBB && Uses.size() == 1) {
    // Single use, no need to traverse the block. We can't assume this for the
    // barrier bb though since the use is probably below the barrier.
    LastMO = Uses[0];
    LastMI = LastMO->getParent();
  } else {
    SmallPtrSet<MachineInstr*, 4> UseMIs;
    for (unsigned i = 0, e = Uses.size(); i != e; ++i)
      UseMIs.insert(Uses[i]->getParent());
    MachineBasicBlock::iterator MII;
    if (MBB == BarrierMBB) {
      MII = Barrier;
      --MII;
    } else
      MII = MBB->end();
    for (MachineBasicBlock::iterator MEE = MBB->begin(); MII != MEE; --MII) {
      MachineInstr *UseMI = &*MII;
      if (!UseMIs.count(UseMI))
        continue;
      for (unsigned i = 0, e = UseMI->getNumOperands(); i != e; ++i) {
        MachineOperand &MO = UseMI->getOperand(i);
        if (MO.isReg() && MO.getReg() == CurrLI->reg) {
          LastMO = &MO;
          break;
        }
      }
      LastMI = UseMI;
      break;
    }
  }

  // Cut off live range from last use (or beginning of the mbb if there
  // are no uses in it) to the end of the mbb.
  unsigned RangeStart, RangeEnd = LIs->getMBBEndIdx(MBB)+1;
  if (LastMI) {
    RangeStart = LIs->getUseIndex(LIs->getInstructionIndex(LastMI))+1;
    assert(!LastMO->isKill() && "Last use already terminates the interval?");
    LastMO->setIsKill();
  } else {
    assert(MBB == BarrierMBB);
    RangeStart = LIs->getMBBStartIdx(MBB);
  }
  if (MBB == BarrierMBB)
    RangeEnd = LIs->getUseIndex(BarrierIdx);
  CurrLI->removeRange(RangeStart, RangeEnd);

  // Return true if the last use becomes a new kill.
  return LastMI;
}

/// ShrinkWrapLiveInterval - Recursively traverse the predecessor
/// chain to find the new 'kills' and shrink wrap the live interval to the
/// new kill indices.
void
PreAllocSplitting::ShrinkWrapLiveInterval(VNInfo *ValNo,
                      MachineBasicBlock *MBB, MachineBasicBlock *DefMBB,
                      SmallPtrSet<MachineBasicBlock*, 8> &Visited,
                      DenseMap<unsigned, std::vector<MachineOperand*> > &Uses) {
  if (!Visited.insert(MBB))
    return;

  DenseMap<unsigned, std::vector<MachineOperand*> >::iterator UMII =
    Uses.find(MBB->getNumber());
  if (UMII != Uses.end()) {
    // At least one use in this mbb, lets look for the kill.
    if (ShrinkWrapToLastUse(MBB, UMII->second))
      // Found a kill, shrink wrapping of this path ends here.
      return;
  } else {
    // Remove entire live range of the bb out of the live interval.
    CurrLI->removeRange(LIs->getMBBStartIdx(MBB), LIs->getMBBEndIdx(MBB));
    abort(); // FIXME
  }

  if (MBB == DefMBB)
    // Reached the def mbb, stop traversing this path further.
    return;

  // Traverse the pathes up the predecessor chains further.
  for (MachineBasicBlock::pred_iterator PI = MBB->pred_begin(),
         PE = MBB->pred_end(); PI != PE; ++PI) {
    MachineBasicBlock *Pred = *PI;
    if (Pred == MBB)
      continue;
    if (Pred == DefMBB && ValNo->hasPHIKill)
      // Pred is the def bb and the def reaches other val#s, we must
      // allow the value to be live out of the bb.
      continue;
    ShrinkWrapLiveInterval(ValNo, Pred, DefMBB, Visited, Uses);
  }

  return;
}

/// SplitRegLiveInterval - Split (spill and restore) the given live interval
/// so it would not cross the barrier that's being processed. Shrink wrap
/// (minimize) the live interval to the last uses.
bool PreAllocSplitting::SplitRegLiveInterval(LiveInterval *LI) {
  CurrLI = LI;

  // Find live range where current interval cross the barrier.
  LiveInterval::iterator LR =
    CurrLI->FindLiveRangeContaining(LIs->getUseIndex(BarrierIdx));
  VNInfo *ValNo = LR->valno;

  if (ValNo->def == ~1U) {
    // Defined by a dead def? How can this be?
    assert(0 && "Val# is defined by a dead def?");
    abort();
  }

  // Find all references in the barrier mbb.
  SmallPtrSet<MachineInstr*, 4> RefsInMBB;
  for (MachineRegisterInfo::reg_iterator I = MRI->reg_begin(CurrLI->reg),
         E = MRI->reg_end(); I != E; ++I) {
    MachineInstr *RefMI = &*I;
    if (RefMI->getParent() == BarrierMBB)
      RefsInMBB.insert(RefMI);
  }

  // Find a point to restore the value after the barrier.
  unsigned RestoreIndex;
  MachineBasicBlock::iterator RestorePt =
    findRestorePoint(BarrierMBB, Barrier, RefsInMBB, RestoreIndex);
  if (RestorePt == BarrierMBB->end())
    return false;

  // Add a spill either before the barrier or after the definition.
  MachineBasicBlock *DefMBB = NULL;
  const TargetRegisterClass *RC = MRI->getRegClass(CurrLI->reg);
  int SS;
  unsigned SpillIndex = 0;
  if (isAlreadySplit(CurrLI->reg, ValNo->id, SS)) {
    // If it's already split, just restore the value. There is no need to spill
    // the def again.
    abort(); // FIXME
  } else if (ValNo->def == ~0U) {
    // If it's defined by a phi, we must split just before the barrier.
    MachineBasicBlock::iterator SpillPt = 
      findSpillPoint(BarrierMBB, Barrier, RefsInMBB, SpillIndex);
    if (SpillPt == BarrierMBB->begin())
      return false; // No gap to insert spill.
    // Add spill.
    SS = MFI->CreateStackObject(RC->getSize(), RC->getAlignment());
    TII->storeRegToStackSlot(*BarrierMBB, SpillPt, CurrLI->reg, true, SS, RC);
    MachineInstr *StoreMI = prior(SpillPt);
    LIs->InsertMachineInstrInMaps(StoreMI, SpillIndex);
  } else {
    // Check if it's possible to insert a spill after the def MI.
    MachineInstr *DefMI = LIs->getInstructionFromIndex(ValNo->def);
    DefMBB = DefMI->getParent();
    MachineBasicBlock::iterator SpillPt =
      findNextEmptySlot(DefMBB, DefMI, SpillIndex);
    if (SpillPt == DefMBB->end())
      return false; // No gap to insert spill.
    SS = MFI->CreateStackObject(RC->getSize(), RC->getAlignment());

    // Add spill. The store instruction does *not* kill the register.
    TII->storeRegToStackSlot(*DefMBB, SpillPt, CurrLI->reg, false, SS, RC);
    MachineInstr *StoreMI = prior(SpillPt);
    LIs->InsertMachineInstrInMaps(StoreMI, SpillIndex);
  }

  // Add restore.
  // FIXME: Create live interval for stack slot.
  TII->loadRegFromStackSlot(*BarrierMBB, RestorePt, CurrLI->reg, SS, RC);
  MachineInstr *LoadMI = prior(RestorePt);
  LIs->InsertMachineInstrInMaps(LoadMI, RestoreIndex);

  // If live interval is spilled in the same block as the barrier, just
  // create a hole in the interval.
  if (!DefMBB ||
      LIs->getInstructionFromIndex(SpillIndex)->getParent() == BarrierMBB) {
    UpdateIntervalForSplit(ValNo, LIs->getUseIndex(SpillIndex)+1,
                           LIs->getDefIndex(RestoreIndex));

    // Record val# values are in the specific spill slot.
    RecordSplit(CurrLI->reg, SpillIndex, RestoreIndex, SS);

    ++NumSplit;
    return true;
  }

  // Shrink wrap the live interval by walking up the CFG and find the
  // new kills.
  // Now let's find all the uses of the val#.
  DenseMap<unsigned, std::vector<MachineOperand*> > Uses;
  for (MachineRegisterInfo::use_iterator UI = MRI->use_begin(CurrLI->reg),
         UE = MRI->use_end(); UI != UE; ++UI) {
    MachineOperand &UseMO = UI.getOperand();
    MachineInstr *UseMI = UseMO.getParent();
    unsigned UseIdx = LIs->getInstructionIndex(UseMI);
    LiveInterval::iterator ULR = CurrLI->FindLiveRangeContaining(UseIdx);
    if (ULR->valno != ValNo)
      continue;
    MachineBasicBlock *UseMBB = UseMI->getParent();
    unsigned MBBId = UseMBB->getNumber();
    DenseMap<unsigned, std::vector<MachineOperand*> >::iterator UMII =
      Uses.find(MBBId);
    if (UMII != Uses.end())
      UMII->second.push_back(&UseMO);
    else {
      std::vector<MachineOperand*> Ops;
      Ops.push_back(&UseMO);
      Uses.insert(std::make_pair(MBBId, Ops));
    }
  }

  // Walk up the predecessor chains.
  SmallPtrSet<MachineBasicBlock*, 8> Visited;
  ShrinkWrapLiveInterval(ValNo, BarrierMBB, DefMBB, Visited, Uses);

  // Remove live range from barrier to the restore. FIXME: Find a better
  // point to re-start the live interval.
  UpdateIntervalForSplit(ValNo, LIs->getUseIndex(BarrierIdx)+1,
                         LIs->getDefIndex(RestoreIndex));
  // Record val# values are in the specific spill slot.
  RecordSplit(CurrLI->reg, BarrierIdx, RestoreIndex, SS);

  ++NumSplit;
  return true;
}

/// SplitRegLiveIntervals - Split all register live intervals that cross the
/// barrier that's being processed.
bool
PreAllocSplitting::SplitRegLiveIntervals(const TargetRegisterClass **RCs) {
  // First find all the virtual registers whose live intervals are intercepted
  // by the current barrier.
  SmallVector<LiveInterval*, 8> Intervals;
  for (const TargetRegisterClass **RC = RCs; *RC; ++RC) {
    std::vector<unsigned> &VRs = MRI->getRegClassVirtRegs(*RC);
    for (unsigned i = 0, e = VRs.size(); i != e; ++i) {
      unsigned Reg = VRs[i];
      if (!LIs->hasInterval(Reg))
        continue;
      LiveInterval *LI = &LIs->getInterval(Reg);
      if (LI->liveAt(BarrierIdx) && !Barrier->readsRegister(Reg))
        // Virtual register live interval is intercepted by the barrier. We
        // should split and shrink wrap its interval if possible.
        Intervals.push_back(LI);
    }
  }

  // Process the affected live intervals.
  bool Change = false;
  while (!Intervals.empty()) {
    LiveInterval *LI = Intervals.back();
    Intervals.pop_back();
    Change |= SplitRegLiveInterval(LI);
  }

  return Change;
}

bool PreAllocSplitting::runOnMachineFunction(MachineFunction &MF) {
  CurMF = &MF;
  TM    = &MF.getTarget();
  TII   = TM->getInstrInfo();
  MFI   = MF.getFrameInfo();
  MRI   = &MF.getRegInfo();
  LIs   = &getAnalysis<LiveIntervals>();

  bool MadeChange = false;

  // Make sure blocks are numbered in order.
  MF.RenumberBlocks();

  for (MachineFunction::reverse_iterator I = MF.rbegin(), E = MF.rend();
       I != E; ++I) {
    BarrierMBB = &*I;
    for (MachineBasicBlock::reverse_iterator II = BarrierMBB->rbegin(),
           EE = BarrierMBB->rend(); II != EE; ++II) {
      Barrier = &*II;
      const TargetRegisterClass **BarrierRCs =
        Barrier->getDesc().getRegClassBarriers();
      if (!BarrierRCs)
        continue;
      BarrierIdx = LIs->getInstructionIndex(Barrier);
      MadeChange |= SplitRegLiveIntervals(BarrierRCs);
    }
  }

  return MadeChange;
}
