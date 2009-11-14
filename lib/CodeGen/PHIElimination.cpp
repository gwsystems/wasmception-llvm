//===-- PhiElimination.cpp - Eliminate PHI nodes by inserting copies ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass eliminates machine instruction PHI nodes by inserting copy
// instructions.  This destroys SSA information, but is the desired input for
// some register allocators.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "phielim"
#include "PHIElimination.h"
#include "llvm/CodeGen/LiveVariables.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Function.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include <algorithm>
#include <map>
using namespace llvm;

STATISTIC(NumAtomic, "Number of atomic phis lowered");
STATISTIC(NumSplits, "Number of critical edges split on demand");

static cl::opt<bool>
SplitEdges("split-phi-edges",
           cl::desc("Split critical edges during phi elimination"),
           cl::init(false), cl::Hidden);

char PHIElimination::ID = 0;
static RegisterPass<PHIElimination>
X("phi-node-elimination", "Eliminate PHI nodes for register allocation");

const PassInfo *const llvm::PHIEliminationID = &X;

void llvm::PHIElimination::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addPreserved<LiveVariables>();
  AU.addPreserved<MachineDominatorTree>();
  if (SplitEdges) {
    AU.addRequired<LiveVariables>();
  } else {
    AU.setPreservesCFG();
    AU.addPreservedID(MachineLoopInfoID);
  }
  MachineFunctionPass::getAnalysisUsage(AU);
}

bool llvm::PHIElimination::runOnMachineFunction(MachineFunction &Fn) {
  MRI = &Fn.getRegInfo();

  PHIDefs.clear();
  PHIKills.clear();

  bool Changed = false;

  // Split critical edges to help the coalescer
  if (SplitEdges)
    for (MachineFunction::iterator I = Fn.begin(), E = Fn.end(); I != E; ++I)
      Changed |= SplitPHIEdges(Fn, *I);

  // Populate VRegPHIUseCount
  analyzePHINodes(Fn);

  // Eliminate PHI instructions by inserting copies into predecessor blocks.
  for (MachineFunction::iterator I = Fn.begin(), E = Fn.end(); I != E; ++I)
    Changed |= EliminatePHINodes(Fn, *I);

  // Remove dead IMPLICIT_DEF instructions.
  for (SmallPtrSet<MachineInstr*,4>::iterator I = ImpDefs.begin(),
         E = ImpDefs.end(); I != E; ++I) {
    MachineInstr *DefMI = *I;
    unsigned DefReg = DefMI->getOperand(0).getReg();
    if (MRI->use_empty(DefReg))
      DefMI->eraseFromParent();
  }

  ImpDefs.clear();
  VRegPHIUseCount.clear();
  return Changed;
}

/// EliminatePHINodes - Eliminate phi nodes by inserting copy instructions in
/// predecessor basic blocks.
///
bool llvm::PHIElimination::EliminatePHINodes(MachineFunction &MF,
                                             MachineBasicBlock &MBB) {
  if (MBB.empty() || MBB.front().getOpcode() != TargetInstrInfo::PHI)
    return false;   // Quick exit for basic blocks without PHIs.

  // Get an iterator to the first instruction after the last PHI node (this may
  // also be the end of the basic block).
  MachineBasicBlock::iterator AfterPHIsIt = SkipPHIsAndLabels(MBB, MBB.begin());

  while (MBB.front().getOpcode() == TargetInstrInfo::PHI)
    LowerAtomicPHINode(MBB, AfterPHIsIt);

  return true;
}

/// isSourceDefinedByImplicitDef - Return true if all sources of the phi node
/// are implicit_def's.
static bool isSourceDefinedByImplicitDef(const MachineInstr *MPhi,
                                         const MachineRegisterInfo *MRI) {
  for (unsigned i = 1; i != MPhi->getNumOperands(); i += 2) {
    unsigned SrcReg = MPhi->getOperand(i).getReg();
    const MachineInstr *DefMI = MRI->getVRegDef(SrcReg);
    if (!DefMI || DefMI->getOpcode() != TargetInstrInfo::IMPLICIT_DEF)
      return false;
  }
  return true;
}

// FindCopyInsertPoint - Find a safe place in MBB to insert a copy from SrcReg
// when following the CFG edge to SuccMBB. This needs to be after any def of
// SrcReg, but before any subsequent point where control flow might jump out of
// the basic block.
MachineBasicBlock::iterator
llvm::PHIElimination::FindCopyInsertPoint(MachineBasicBlock &MBB,
                                          MachineBasicBlock &SuccMBB,
                                          unsigned SrcReg) {
  // Handle the trivial case trivially.
  if (MBB.empty())
    return MBB.begin();

  // Usually, we just want to insert the copy before the first terminator
  // instruction. However, for the edge going to a landing pad, we must insert
  // the copy before the call/invoke instruction.
  if (!SuccMBB.isLandingPad())
    return MBB.getFirstTerminator();

  // Discover any definitions in this basic block.
  SmallPtrSet<MachineInstr*, 8> DefUsesInMBB;
  for (MachineRegisterInfo::def_iterator RI = MRI->def_begin(SrcReg),
         RE = MRI->def_end(); RI != RE; ++RI) {
    MachineInstr *DefUseMI = &*RI;
    if (DefUseMI->getParent() == &MBB)
      DefUsesInMBB.insert(DefUseMI);
  }

  MachineBasicBlock::iterator InsertPoint;
  if (DefUsesInMBB.empty()) {
    // No defs.  Insert the copy at the start of the basic block.
    InsertPoint = MBB.begin();
  } else if (DefUsesInMBB.size() == 1) {
    // Insert the copy immediately after the def.
    InsertPoint = *DefUsesInMBB.begin();
    ++InsertPoint;
  } else {
    // Insert the copy immediately after the last def.
    InsertPoint = MBB.end();
    while (!DefUsesInMBB.count(&*--InsertPoint)) {}
    ++InsertPoint;
  }

  // Make sure the copy goes after any phi nodes however.
  return SkipPHIsAndLabels(MBB, InsertPoint);
}

/// LowerAtomicPHINode - Lower the PHI node at the top of the specified block,
/// under the assuption that it needs to be lowered in a way that supports
/// atomic execution of PHIs.  This lowering method is always correct all of the
/// time.
///
void llvm::PHIElimination::LowerAtomicPHINode(
                                      MachineBasicBlock &MBB,
                                      MachineBasicBlock::iterator AfterPHIsIt) {
  // Unlink the PHI node from the basic block, but don't delete the PHI yet.
  MachineInstr *MPhi = MBB.remove(MBB.begin());

  unsigned NumSrcs = (MPhi->getNumOperands() - 1) / 2;
  unsigned DestReg = MPhi->getOperand(0).getReg();
  bool isDead = MPhi->getOperand(0).isDead();

  // Create a new register for the incoming PHI arguments.
  MachineFunction &MF = *MBB.getParent();
  const TargetRegisterClass *RC = MF.getRegInfo().getRegClass(DestReg);
  unsigned IncomingReg = 0;

  // Insert a register to register copy at the top of the current block (but
  // after any remaining phi nodes) which copies the new incoming register
  // into the phi node destination.
  const TargetInstrInfo *TII = MF.getTarget().getInstrInfo();
  if (isSourceDefinedByImplicitDef(MPhi, MRI))
    // If all sources of a PHI node are implicit_def, just emit an
    // implicit_def instead of a copy.
    BuildMI(MBB, AfterPHIsIt, MPhi->getDebugLoc(),
            TII->get(TargetInstrInfo::IMPLICIT_DEF), DestReg);
  else {
    IncomingReg = MF.getRegInfo().createVirtualRegister(RC);
    TII->copyRegToReg(MBB, AfterPHIsIt, DestReg, IncomingReg, RC, RC);
  }

  // Record PHI def.
  assert(!hasPHIDef(DestReg) && "Vreg has multiple phi-defs?");
  PHIDefs[DestReg] = &MBB;

  // Update live variable information if there is any.
  LiveVariables *LV = getAnalysisIfAvailable<LiveVariables>();
  if (LV) {
    MachineInstr *PHICopy = prior(AfterPHIsIt);

    if (IncomingReg) {
      // Increment use count of the newly created virtual register.
      LV->getVarInfo(IncomingReg).NumUses++;

      // Add information to LiveVariables to know that the incoming value is
      // killed.  Note that because the value is defined in several places (once
      // each for each incoming block), the "def" block and instruction fields
      // for the VarInfo is not filled in.
      LV->addVirtualRegisterKilled(IncomingReg, PHICopy);
    }

    // Since we are going to be deleting the PHI node, if it is the last use of
    // any registers, or if the value itself is dead, we need to move this
    // information over to the new copy we just inserted.
    LV->removeVirtualRegistersKilled(MPhi);

    // If the result is dead, update LV.
    if (isDead) {
      LV->addVirtualRegisterDead(DestReg, PHICopy);
      LV->removeVirtualRegisterDead(DestReg, MPhi);
    }
  }

  // Adjust the VRegPHIUseCount map to account for the removal of this PHI node.
  for (unsigned i = 1; i != MPhi->getNumOperands(); i += 2)
    --VRegPHIUseCount[BBVRegPair(MPhi->getOperand(i + 1).getMBB(),
                                 MPhi->getOperand(i).getReg())];

  // Now loop over all of the incoming arguments, changing them to copy into the
  // IncomingReg register in the corresponding predecessor basic block.
  SmallPtrSet<MachineBasicBlock*, 8> MBBsInsertedInto;
  for (int i = NumSrcs - 1; i >= 0; --i) {
    unsigned SrcReg = MPhi->getOperand(i*2+1).getReg();
    assert(TargetRegisterInfo::isVirtualRegister(SrcReg) &&
           "Machine PHI Operands must all be virtual registers!");

    // Get the MachineBasicBlock equivalent of the BasicBlock that is the source
    // path the PHI.
    MachineBasicBlock &opBlock = *MPhi->getOperand(i*2+2).getMBB();

    // Record the kill.
    PHIKills[SrcReg].insert(&opBlock);

    // If source is defined by an implicit def, there is no need to insert a
    // copy.
    MachineInstr *DefMI = MRI->getVRegDef(SrcReg);
    if (DefMI->getOpcode() == TargetInstrInfo::IMPLICIT_DEF) {
      ImpDefs.insert(DefMI);
      continue;
    }

    // Check to make sure we haven't already emitted the copy for this block.
    // This can happen because PHI nodes may have multiple entries for the same
    // basic block.
    if (!MBBsInsertedInto.insert(&opBlock))
      continue;  // If the copy has already been emitted, we're done.

    // Find a safe location to insert the copy, this may be the first terminator
    // in the block (or end()).
    MachineBasicBlock::iterator InsertPos =
      FindCopyInsertPoint(opBlock, MBB, SrcReg);

    // Insert the copy.
    TII->copyRegToReg(opBlock, InsertPos, IncomingReg, SrcReg, RC, RC);

    // Now update live variable information if we have it.  Otherwise we're done
    if (!LV) continue;

    // We want to be able to insert a kill of the register if this PHI (aka, the
    // copy we just inserted) is the last use of the source value.  Live
    // variable analysis conservatively handles this by saying that the value is
    // live until the end of the block the PHI entry lives in.  If the value
    // really is dead at the PHI copy, there will be no successor blocks which
    // have the value live-in.

    // Also check to see if this register is in use by another PHI node which
    // has not yet been eliminated.  If so, it will be killed at an appropriate
    // point later.

    // Is it used by any PHI instructions in this block?
    bool ValueIsUsed = VRegPHIUseCount[BBVRegPair(&opBlock, SrcReg)] != 0;

    // Okay, if we now know that the value is not live out of the block, we can
    // add a kill marker in this block saying that it kills the incoming value!
    if (!ValueIsUsed && !isLiveOut(SrcReg, opBlock, *LV)) {
      // In our final twist, we have to decide which instruction kills the
      // register.  In most cases this is the copy, however, the first
      // terminator instruction at the end of the block may also use the value.
      // In this case, we should mark *it* as being the killing block, not the
      // copy.
      MachineBasicBlock::iterator KillInst = prior(InsertPos);
      MachineBasicBlock::iterator Term = opBlock.getFirstTerminator();
      if (Term != opBlock.end()) {
        if (Term->readsRegister(SrcReg))
          KillInst = Term;

        // Check that no other terminators use values.
#ifndef NDEBUG
        for (MachineBasicBlock::iterator TI = next(Term); TI != opBlock.end();
             ++TI) {
          assert(!TI->readsRegister(SrcReg) &&
                 "Terminator instructions cannot use virtual registers unless"
                 "they are the first terminator in a block!");
        }
#endif
      }

      // Finally, mark it killed.
      LV->addVirtualRegisterKilled(SrcReg, KillInst);

      // This vreg no longer lives all of the way through opBlock.
      unsigned opBlockNum = opBlock.getNumber();
      LV->getVarInfo(SrcReg).AliveBlocks.reset(opBlockNum);
    }
  }

  // Really delete the PHI instruction now!
  MF.DeleteMachineInstr(MPhi);
  ++NumAtomic;
}

/// analyzePHINodes - Gather information about the PHI nodes in here. In
/// particular, we want to map the number of uses of a virtual register which is
/// used in a PHI node. We map that to the BB the vreg is coming from. This is
/// used later to determine when the vreg is killed in the BB.
///
void llvm::PHIElimination::analyzePHINodes(const MachineFunction& Fn) {
  for (MachineFunction::const_iterator I = Fn.begin(), E = Fn.end();
       I != E; ++I)
    for (MachineBasicBlock::const_iterator BBI = I->begin(), BBE = I->end();
         BBI != BBE && BBI->getOpcode() == TargetInstrInfo::PHI; ++BBI)
      for (unsigned i = 1, e = BBI->getNumOperands(); i != e; i += 2)
        ++VRegPHIUseCount[BBVRegPair(BBI->getOperand(i + 1).getMBB(),
                                     BBI->getOperand(i).getReg())];
}

bool llvm::PHIElimination::SplitPHIEdges(MachineFunction &MF,
                                         MachineBasicBlock &MBB) {
  if (MBB.empty() || MBB.front().getOpcode() != TargetInstrInfo::PHI)
    return false;   // Quick exit for basic blocks without PHIs.
  LiveVariables &LV = getAnalysis<LiveVariables>();
  for (MachineBasicBlock::const_iterator BBI = MBB.begin(), BBE = MBB.end();
       BBI != BBE && BBI->getOpcode() == TargetInstrInfo::PHI; ++BBI) {
    for (unsigned i = 1, e = BBI->getNumOperands(); i != e; i += 2) {
      unsigned Reg = BBI->getOperand(i).getReg();
      MachineBasicBlock *PreMBB = BBI->getOperand(i+1).getMBB();
      // We break edges when registers are live out from the predecessor block
      // (not considering PHI nodes). If the register is live in to this block
      // anyway, we would gain nothing from splitting.
      if (isLiveOut(Reg, *PreMBB, LV) && !isLiveIn(Reg, MBB, LV))
        SplitCriticalEdge(PreMBB, &MBB);
    }
  }
  return true;
}

bool llvm::PHIElimination::isLiveOut(unsigned Reg, const MachineBasicBlock &MBB,
                                     LiveVariables &LV) {
  LiveVariables::VarInfo &VI = LV.getVarInfo(Reg);

  // Loop over all of the successors of the basic block, checking to see if
  // the value is either live in the block, or if it is killed in the block.
  std::vector<MachineBasicBlock*> OpSuccBlocks;
  for (MachineBasicBlock::const_succ_iterator SI = MBB.succ_begin(),
         E = MBB.succ_end(); SI != E; ++SI) {
    MachineBasicBlock *SuccMBB = *SI;

    // Is it alive in this successor?
    unsigned SuccIdx = SuccMBB->getNumber();
    if (VI.AliveBlocks.test(SuccIdx))
      return true;
    OpSuccBlocks.push_back(SuccMBB);
  }

  // Check to see if this value is live because there is a use in a successor
  // that kills it.
  switch (OpSuccBlocks.size()) {
  case 1: {
    MachineBasicBlock *SuccMBB = OpSuccBlocks[0];
    for (unsigned i = 0, e = VI.Kills.size(); i != e; ++i)
      if (VI.Kills[i]->getParent() == SuccMBB)
        return true;
    break;
  }
  case 2: {
    MachineBasicBlock *SuccMBB1 = OpSuccBlocks[0], *SuccMBB2 = OpSuccBlocks[1];
    for (unsigned i = 0, e = VI.Kills.size(); i != e; ++i)
      if (VI.Kills[i]->getParent() == SuccMBB1 ||
          VI.Kills[i]->getParent() == SuccMBB2)
        return true;
    break;
  }
  default:
    std::sort(OpSuccBlocks.begin(), OpSuccBlocks.end());
    for (unsigned i = 0, e = VI.Kills.size(); i != e; ++i)
      if (std::binary_search(OpSuccBlocks.begin(), OpSuccBlocks.end(),
                             VI.Kills[i]->getParent()))
        return true;
  }
  return false;
}

bool llvm::PHIElimination::isLiveIn(unsigned Reg, const MachineBasicBlock &MBB,
                                    LiveVariables &LV) {
  LiveVariables::VarInfo &VI = LV.getVarInfo(Reg);

  return VI.AliveBlocks.test(MBB.getNumber()) || VI.findKill(&MBB);
}

MachineBasicBlock *PHIElimination::SplitCriticalEdge(MachineBasicBlock *A,
                                                     MachineBasicBlock *B) {
  assert(A && B && "Missing MBB end point");
  ++NumSplits;

  MachineFunction *MF = A->getParent();
  MachineBasicBlock *NMBB = MF->CreateMachineBasicBlock();
  MF->push_back(NMBB);
  DEBUG(errs() << "PHIElimination splitting critical edge:"
        " BB#" << A->getNumber()
        << " -- BB#" << NMBB->getNumber()
        << " -- BB#" << B->getNumber() << '\n');

  A->ReplaceUsesOfBlockWith(B, NMBB);
  NMBB->addSuccessor(B);

  // Insert unconditional "jump B" instruction in NMBB.
  SmallVector<MachineOperand, 4> Cond;
  MF->getTarget().getInstrInfo()->InsertBranch(*NMBB, B, NULL, Cond);

  // Fix PHI nodes in B so they refer to NMBB instead of A
  for (MachineBasicBlock::iterator i = B->begin(), e = B->end();
       i != e && i->getOpcode() == TargetInstrInfo::PHI; ++i)
    for (unsigned ni = 1, ne = i->getNumOperands(); ni != ne; ni += 2)
      if (i->getOperand(ni+1).getMBB() == A)
        i->getOperand(ni+1).setMBB(NMBB);

  if (LiveVariables *LV=getAnalysisIfAvailable<LiveVariables>())
    LV->addNewBlock(NMBB, A);

  if (MachineDominatorTree *MDT=getAnalysisIfAvailable<MachineDominatorTree>())
    MDT->addNewBlock(NMBB, A);

  return NMBB;
}
