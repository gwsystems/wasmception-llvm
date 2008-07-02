//===- DCE.cpp - Code to perform dead code elimination --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Aggressive Dead Code Elimination pass.  This pass
// optimistically assumes that all instructions are dead until proven otherwise,
// allowing it to eliminate dead computations that other DCE passes do not 
// catch, particularly involving loop computations.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "adce"
#include "llvm/Transforms/Scalar.h"
#include "llvm/BasicBlock.h"
#include "llvm/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Support/CFG.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/SmallVector.h"

using namespace llvm;

STATISTIC(NumRemoved, "Number of instructions removed");

namespace {
  struct VISIBILITY_HIDDEN ADCE : public FunctionPass {
    static char ID; // Pass identification, replacement for typeid
    ADCE() : FunctionPass((intptr_t)&ID) {}
    
    DenseSet<Instruction*> alive;
    SmallVector<Instruction*, 1024> worklist;
    
    DenseSet<BasicBlock*> reachable;
    SmallVector<BasicBlock*, 1024> unreachable;
    
    virtual bool runOnFunction(Function& F);
    
    virtual void getAnalysisUsage(AnalysisUsage& AU) const {
      AU.setPreservesCFG();
    }
    
  };
}

char ADCE::ID = 0;
static RegisterPass<ADCE> X("adce", "Aggressive Dead Code Elimination");

bool ADCE::runOnFunction(Function& F) {
  alive.clear();
  worklist.clear();
  reachable.clear();
  unreachable.clear();
  
  // First, collect the set of reachable blocks ...
  for (df_iterator<BasicBlock*> DI = df_begin(&F.getEntryBlock()),
       DE = df_end(&F.getEntryBlock()); DI != DE; ++DI)
    reachable.insert(*DI);
  
  // ... and then invert it into the list of unreachable ones.  These
  // blocks will be removed from the function.
  for (Function::iterator FI = F.begin(), FE = F.end(); FI != FE; ++FI)
    if (!reachable.count(FI))
      unreachable.push_back(FI);
  
  // Prepare to remove blocks by removing the PHI node entries for those blocks
  // in their successors, and remove them from reference counting.
  for (SmallVector<BasicBlock*, 1024>::iterator UI = unreachable.begin(),
       UE = unreachable.end(); UI != UE; ++UI) {
    BasicBlock* BB = *UI;
    for (succ_iterator SI = succ_begin(BB), SE = succ_end(BB);
         SI != SE; ++SI) {
      BasicBlock* succ = *SI;
      BasicBlock::iterator succ_inst = succ->begin();
      while (PHINode* P = dyn_cast<PHINode>(succ_inst)) {
        P->removeIncomingValue(BB);
        ++succ_inst;
      }
    }
    
    BB->dropAllReferences();
  }
  
  // Finally, erase the unreachable blocks.
  for (SmallVector<BasicBlock*, 1024>::iterator UI = unreachable.begin(),
       UE = unreachable.end(); UI != UE; ++UI)
    (*UI)->eraseFromParent();
  
  // Collect the set of "root" instructions that are known live.
  for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I)
    if (isa<TerminatorInst>(I.getInstructionIterator()) ||
        I->mayWriteToMemory()) {
      alive.insert(I.getInstructionIterator());
      worklist.push_back(I.getInstructionIterator());
    }
  
  // Propagate liveness backwards to operands.
  while (!worklist.empty()) {
    Instruction* curr = worklist.back();
    worklist.pop_back();
    
    for (Instruction::op_iterator OI = curr->op_begin(), OE = curr->op_end();
         OI != OE; ++OI)
      if (Instruction* Inst = dyn_cast<Instruction>(OI))
        if (alive.insert(Inst))
          worklist.push_back(Inst);
  }
  
  // The inverse of the live set is the dead set.  These are those instructions
  // which have no side effects and do not influence the control flow or return
  // value of the function, and may therefore be deleted safely.
  // NOTE: We reuse the worklist vector here for memory efficiency.
  for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I)
    if (!alive.count(I.getInstructionIterator())) {
      worklist.push_back(I.getInstructionIterator());
      I->dropAllReferences();
    }
  
  for (SmallVector<Instruction*, 1024>::iterator I = worklist.begin(),
       E = worklist.end(); I != E; ++I) {
    NumRemoved++;
    (*I)->eraseFromParent();
  }
    
  return !worklist.empty();
}

FunctionPass *llvm::createAggressiveDCEPass() {
  return new ADCE();
}
