//===- JumpThreading.cpp - Thread control through conditional blocks ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Jump Threading pass.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "jump-threading"
#include "llvm/Transforms/Scalar.h"
#include "llvm/IntrinsicInst.h"
#include "llvm/LLVMContext.h"
#include "llvm/Pass.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include "llvm/Target/TargetData.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

STATISTIC(NumThreads, "Number of jumps threaded");
STATISTIC(NumFolds,   "Number of terminators folded");
STATISTIC(NumDupes,   "Number of branch blocks duplicated to eliminate phi");

static cl::opt<unsigned>
Threshold("jump-threading-threshold", 
          cl::desc("Max block size to duplicate for jump threading"),
          cl::init(6), cl::Hidden);

namespace {
  /// This pass performs 'jump threading', which looks at blocks that have
  /// multiple predecessors and multiple successors.  If one or more of the
  /// predecessors of the block can be proven to always jump to one of the
  /// successors, we forward the edge from the predecessor to the successor by
  /// duplicating the contents of this block.
  ///
  /// An example of when this can occur is code like this:
  ///
  ///   if () { ...
  ///     X = 4;
  ///   }
  ///   if (X < 3) {
  ///
  /// In this case, the unconditional branch at the end of the first if can be
  /// revectored to the false side of the second if.
  ///
  class JumpThreading : public FunctionPass {
    TargetData *TD;
#ifdef NDEBUG
    SmallPtrSet<BasicBlock*, 16> LoopHeaders;
#else
    SmallSet<AssertingVH<BasicBlock>, 16> LoopHeaders;
#endif
  public:
    static char ID; // Pass identification
    JumpThreading() : FunctionPass(&ID) {}

    bool runOnFunction(Function &F);
    void FindLoopHeaders(Function &F);
    
    bool ProcessBlock(BasicBlock *BB);
    bool ThreadEdge(BasicBlock *BB, const SmallVectorImpl<BasicBlock*> &PredBBs,
                    BasicBlock *SuccBB);
    bool DuplicateCondBranchOnPHIIntoPred(BasicBlock *BB,
                                          BasicBlock *PredBB);
    
    typedef SmallVectorImpl<std::pair<ConstantInt*,
                                      BasicBlock*> > PredValueInfo;
    
    bool ComputeValueKnownInPredecessors(Value *V, BasicBlock *BB,
                                         PredValueInfo &Result);
    bool ProcessThreadableEdges(Instruction *CondInst, BasicBlock *BB);
    
    
    bool ProcessBranchOnDuplicateCond(BasicBlock *PredBB, BasicBlock *DestBB);
    bool ProcessSwitchOnDuplicateCond(BasicBlock *PredBB, BasicBlock *DestBB);

    bool ProcessJumpOnPHI(PHINode *PN);
    
    bool SimplifyPartiallyRedundantLoad(LoadInst *LI);
  };
}

char JumpThreading::ID = 0;
static RegisterPass<JumpThreading>
X("jump-threading", "Jump Threading");

// Public interface to the Jump Threading pass
FunctionPass *llvm::createJumpThreadingPass() { return new JumpThreading(); }

/// runOnFunction - Top level algorithm.
///
bool JumpThreading::runOnFunction(Function &F) {
  DEBUG(errs() << "Jump threading on function '" << F.getName() << "'\n");
  TD = getAnalysisIfAvailable<TargetData>();
  
  FindLoopHeaders(F);
  
  bool AnotherIteration = true, EverChanged = false;
  while (AnotherIteration) {
    AnotherIteration = false;
    bool Changed = false;
    for (Function::iterator I = F.begin(), E = F.end(); I != E;) {
      BasicBlock *BB = I;
      while (ProcessBlock(BB))
        Changed = true;
      
      ++I;
      
      // If the block is trivially dead, zap it.  This eliminates the successor
      // edges which simplifies the CFG.
      if (pred_begin(BB) == pred_end(BB) &&
          BB != &BB->getParent()->getEntryBlock()) {
        DEBUG(errs() << "  JT: Deleting dead block '" << BB->getName()
              << "' with terminator: " << *BB->getTerminator() << '\n');
        LoopHeaders.erase(BB);
        DeleteDeadBlock(BB);
        Changed = true;
      }
    }
    AnotherIteration = Changed;
    EverChanged |= Changed;
  }
  
  LoopHeaders.clear();
  return EverChanged;
}

/// getJumpThreadDuplicationCost - Return the cost of duplicating this block to
/// thread across it.
static unsigned getJumpThreadDuplicationCost(const BasicBlock *BB) {
  /// Ignore PHI nodes, these will be flattened when duplication happens.
  BasicBlock::const_iterator I = BB->getFirstNonPHI();
  
  // Sum up the cost of each instruction until we get to the terminator.  Don't
  // include the terminator because the copy won't include it.
  unsigned Size = 0;
  for (; !isa<TerminatorInst>(I); ++I) {
    // Debugger intrinsics don't incur code size.
    if (isa<DbgInfoIntrinsic>(I)) continue;
    
    // If this is a pointer->pointer bitcast, it is free.
    if (isa<BitCastInst>(I) && isa<PointerType>(I->getType()))
      continue;
    
    // All other instructions count for at least one unit.
    ++Size;
    
    // Calls are more expensive.  If they are non-intrinsic calls, we model them
    // as having cost of 4.  If they are a non-vector intrinsic, we model them
    // as having cost of 2 total, and if they are a vector intrinsic, we model
    // them as having cost 1.
    if (const CallInst *CI = dyn_cast<CallInst>(I)) {
      if (!isa<IntrinsicInst>(CI))
        Size += 3;
      else if (!isa<VectorType>(CI->getType()))
        Size += 1;
    }
  }
  
  // Threading through a switch statement is particularly profitable.  If this
  // block ends in a switch, decrease its cost to make it more likely to happen.
  if (isa<SwitchInst>(I))
    Size = Size > 6 ? Size-6 : 0;
  
  return Size;
}


//===----------------------------------------------------------------------===//


/// RemovePredecessorAndSimplify - Like BasicBlock::removePredecessor, this
/// method is called when we're about to delete Pred as a predecessor of BB.  If
/// BB contains any PHI nodes, this drops the entries in the PHI nodes for Pred.
///
/// Unlike the removePredecessor method, this attempts to simplify uses of PHI
/// nodes that collapse into identity values.  For example, if we have:
///   x = phi(1, 0, 0, 0)
///   y = and x, z
///
/// .. and delete the predecessor corresponding to the '1', this will attempt to
/// recursively fold the and to 0.
static void RemovePredecessorAndSimplify(BasicBlock *BB, BasicBlock *Pred,
                                         TargetData *TD) {
  // This only adjusts blocks with PHI nodes.
  if (!isa<PHINode>(BB->begin()))
    return;
  
  // Remove the entries for Pred from the PHI nodes in BB, but do not simplify
  // them down.  This will leave us with single entry phi nodes and other phis
  // that can be removed.
  BB->removePredecessor(Pred, true);
  
  WeakVH PhiIt = &BB->front();
  while (PHINode *PN = dyn_cast<PHINode>(PhiIt)) {
    PhiIt = &*++BasicBlock::iterator(cast<Instruction>(PhiIt));
    
    Value *PNV = PN->hasConstantValue();
    if (PNV == 0) continue;
    
    assert(PNV != PN && "hasConstantValue broken");
    
    // If we're able to simplify the phi to a constant, simplify it into its
    // uses.
    while (!PN->use_empty()) {
      // Update the instruction to use the new value.
      Use &U = PN->use_begin().getUse();
      Instruction *User = cast<Instruction>(U.getUser());
      U = PNV;
      
      // See if we can simplify it.
      if (Value *V = SimplifyInstruction(User, TD)) {
        User->replaceAllUsesWith(V);
        User->eraseFromParent();
      }
    }
    
    PN->replaceAllUsesWith(PNV);
    PN->eraseFromParent();
    
    // If recursive simplification ended up deleting the next PHI node we would
    // iterate to, then our iterator is invalid, restart scanning from the top
    // of the block.
    if (PhiIt == 0) PhiIt = &BB->front();
  }
}

//===----------------------------------------------------------------------===//


/// FindLoopHeaders - We do not want jump threading to turn proper loop
/// structures into irreducible loops.  Doing this breaks up the loop nesting
/// hierarchy and pessimizes later transformations.  To prevent this from
/// happening, we first have to find the loop headers.  Here we approximate this
/// by finding targets of backedges in the CFG.
///
/// Note that there definitely are cases when we want to allow threading of
/// edges across a loop header.  For example, threading a jump from outside the
/// loop (the preheader) to an exit block of the loop is definitely profitable.
/// It is also almost always profitable to thread backedges from within the loop
/// to exit blocks, and is often profitable to thread backedges to other blocks
/// within the loop (forming a nested loop).  This simple analysis is not rich
/// enough to track all of these properties and keep it up-to-date as the CFG
/// mutates, so we don't allow any of these transformations.
///
void JumpThreading::FindLoopHeaders(Function &F) {
  SmallVector<std::pair<const BasicBlock*,const BasicBlock*>, 32> Edges;
  FindFunctionBackedges(F, Edges);
  
  for (unsigned i = 0, e = Edges.size(); i != e; ++i)
    LoopHeaders.insert(const_cast<BasicBlock*>(Edges[i].second));
}

/// ComputeValueKnownInPredecessors - Given a basic block BB and a value V, see
/// if we can infer that the value is a known ConstantInt in any of our
/// predecessors.  If so, return the known list of value and pred BB in the
/// result vector.  If a value is known to be undef, it is returned as null.
///
/// The BB basic block is known to start with a PHI node.
///
/// This returns true if there were any known values.
///
///
/// TODO: Per PR2563, we could infer value range information about a predecessor
/// based on its terminator.
bool JumpThreading::
ComputeValueKnownInPredecessors(Value *V, BasicBlock *BB,PredValueInfo &Result){
  PHINode *TheFirstPHI = cast<PHINode>(BB->begin());
  
  // If V is a constantint, then it is known in all predecessors.
  if (isa<ConstantInt>(V) || isa<UndefValue>(V)) {
    ConstantInt *CI = dyn_cast<ConstantInt>(V);
    Result.resize(TheFirstPHI->getNumIncomingValues());
    for (unsigned i = 0, e = Result.size(); i != e; ++i)
      Result[i] = std::make_pair(CI, TheFirstPHI->getIncomingBlock(i));
    return true;
  }
  
  // If V is a non-instruction value, or an instruction in a different block,
  // then it can't be derived from a PHI.
  Instruction *I = dyn_cast<Instruction>(V);
  if (I == 0 || I->getParent() != BB)
    return false;
  
  /// If I is a PHI node, then we know the incoming values for any constants.
  if (PHINode *PN = dyn_cast<PHINode>(I)) {
    for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i) {
      Value *InVal = PN->getIncomingValue(i);
      if (isa<ConstantInt>(InVal) || isa<UndefValue>(InVal)) {
        ConstantInt *CI = dyn_cast<ConstantInt>(InVal);
        Result.push_back(std::make_pair(CI, PN->getIncomingBlock(i)));
      }
    }
    return !Result.empty();
  }
  
  SmallVector<std::pair<ConstantInt*, BasicBlock*>, 8> LHSVals, RHSVals;

  // Handle some boolean conditions.
  if (I->getType()->getPrimitiveSizeInBits() == 1) { 
    // X | true -> true
    // X & false -> false
    if (I->getOpcode() == Instruction::Or ||
        I->getOpcode() == Instruction::And) {
      ComputeValueKnownInPredecessors(I->getOperand(0), BB, LHSVals);
      ComputeValueKnownInPredecessors(I->getOperand(1), BB, RHSVals);
      
      if (LHSVals.empty() && RHSVals.empty())
        return false;
      
      ConstantInt *InterestingVal;
      if (I->getOpcode() == Instruction::Or)
        InterestingVal = ConstantInt::getTrue(I->getContext());
      else
        InterestingVal = ConstantInt::getFalse(I->getContext());
      
      // Scan for the sentinel.
      for (unsigned i = 0, e = LHSVals.size(); i != e; ++i)
        if (LHSVals[i].first == InterestingVal || LHSVals[i].first == 0)
          Result.push_back(LHSVals[i]);
      for (unsigned i = 0, e = RHSVals.size(); i != e; ++i)
        if (RHSVals[i].first == InterestingVal || RHSVals[i].first == 0)
          Result.push_back(RHSVals[i]);
      return !Result.empty();
    }
    
    // TODO: Should handle the NOT form of XOR.
    
  }
  
  // Handle compare with phi operand, where the PHI is defined in this block.
  if (CmpInst *Cmp = dyn_cast<CmpInst>(I)) {
    PHINode *PN = dyn_cast<PHINode>(Cmp->getOperand(0));
    if (PN && PN->getParent() == BB) {
      // We can do this simplification if any comparisons fold to true or false.
      // See if any do.
      for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i) {
        BasicBlock *PredBB = PN->getIncomingBlock(i);
        Value *LHS = PN->getIncomingValue(i);
        Value *RHS = Cmp->getOperand(1)->DoPHITranslation(BB, PredBB);
        
        Value *Res = SimplifyCmpInst(Cmp->getPredicate(), LHS, RHS);
        if (Res == 0) continue;
        
        if (isa<UndefValue>(Res))
          Result.push_back(std::make_pair((ConstantInt*)0, PredBB));
        else if (ConstantInt *CI = dyn_cast<ConstantInt>(Res))
          Result.push_back(std::make_pair(CI, PredBB));
      }
      
      return !Result.empty();
    }
    
    // TODO: We could also recurse to see if we can determine constants another
    // way.
  }
  return false;
}



/// GetBestDestForBranchOnUndef - If we determine that the specified block ends
/// in an undefined jump, decide which block is best to revector to.
///
/// Since we can pick an arbitrary destination, we pick the successor with the
/// fewest predecessors.  This should reduce the in-degree of the others.
///
static unsigned GetBestDestForJumpOnUndef(BasicBlock *BB) {
  TerminatorInst *BBTerm = BB->getTerminator();
  unsigned MinSucc = 0;
  BasicBlock *TestBB = BBTerm->getSuccessor(MinSucc);
  // Compute the successor with the minimum number of predecessors.
  unsigned MinNumPreds = std::distance(pred_begin(TestBB), pred_end(TestBB));
  for (unsigned i = 1, e = BBTerm->getNumSuccessors(); i != e; ++i) {
    TestBB = BBTerm->getSuccessor(i);
    unsigned NumPreds = std::distance(pred_begin(TestBB), pred_end(TestBB));
    if (NumPreds < MinNumPreds)
      MinSucc = i;
  }
  
  return MinSucc;
}

/// ProcessBlock - If there are any predecessors whose control can be threaded
/// through to a successor, transform them now.
bool JumpThreading::ProcessBlock(BasicBlock *BB) {
  // If this block has a single predecessor, and if that pred has a single
  // successor, merge the blocks.  This encourages recursive jump threading
  // because now the condition in this block can be threaded through
  // predecessors of our predecessor block.
  if (BasicBlock *SinglePred = BB->getSinglePredecessor()) {
    if (SinglePred->getTerminator()->getNumSuccessors() == 1 &&
        SinglePred != BB) {
      // If SinglePred was a loop header, BB becomes one.
      if (LoopHeaders.erase(SinglePred))
        LoopHeaders.insert(BB);
      
      // Remember if SinglePred was the entry block of the function.  If so, we
      // will need to move BB back to the entry position.
      bool isEntry = SinglePred == &SinglePred->getParent()->getEntryBlock();
      MergeBasicBlockIntoOnlyPred(BB);
      
      if (isEntry && BB != &BB->getParent()->getEntryBlock())
        BB->moveBefore(&BB->getParent()->getEntryBlock());
      return true;
    }
  }

  // Look to see if the terminator is a branch of switch, if not we can't thread
  // it.
  Value *Condition;
  if (BranchInst *BI = dyn_cast<BranchInst>(BB->getTerminator())) {
    // Can't thread an unconditional jump.
    if (BI->isUnconditional()) return false;
    Condition = BI->getCondition();
  } else if (SwitchInst *SI = dyn_cast<SwitchInst>(BB->getTerminator()))
    Condition = SI->getCondition();
  else
    return false; // Must be an invoke.
  
  // If the terminator of this block is branching on a constant, simplify the
  // terminator to an unconditional branch.  This can occur due to threading in
  // other blocks.
  if (isa<ConstantInt>(Condition)) {
    DEBUG(errs() << "  In block '" << BB->getName()
          << "' folding terminator: " << *BB->getTerminator() << '\n');
    ++NumFolds;
    ConstantFoldTerminator(BB);
    return true;
  }
  
  // If the terminator is branching on an undef, we can pick any of the
  // successors to branch to.  Let GetBestDestForJumpOnUndef decide.
  if (isa<UndefValue>(Condition)) {
    unsigned BestSucc = GetBestDestForJumpOnUndef(BB);
    
    // Fold the branch/switch.
    TerminatorInst *BBTerm = BB->getTerminator();
    for (unsigned i = 0, e = BBTerm->getNumSuccessors(); i != e; ++i) {
      if (i == BestSucc) continue;
      RemovePredecessorAndSimplify(BBTerm->getSuccessor(i), BB, TD);
    }
    
    DEBUG(errs() << "  In block '" << BB->getName()
          << "' folding undef terminator: " << *BBTerm << '\n');
    BranchInst::Create(BBTerm->getSuccessor(BestSucc), BBTerm);
    BBTerm->eraseFromParent();
    return true;
  }
  
  Instruction *CondInst = dyn_cast<Instruction>(Condition);

  // If the condition is an instruction defined in another block, see if a
  // predecessor has the same condition:
  //     br COND, BBX, BBY
  //  BBX:
  //     br COND, BBZ, BBW
  if (!Condition->hasOneUse() && // Multiple uses.
      (CondInst == 0 || CondInst->getParent() != BB)) { // Non-local definition.
    pred_iterator PI = pred_begin(BB), E = pred_end(BB);
    if (isa<BranchInst>(BB->getTerminator())) {
      for (; PI != E; ++PI)
        if (BranchInst *PBI = dyn_cast<BranchInst>((*PI)->getTerminator()))
          if (PBI->isConditional() && PBI->getCondition() == Condition &&
              ProcessBranchOnDuplicateCond(*PI, BB))
            return true;
    } else {
      assert(isa<SwitchInst>(BB->getTerminator()) && "Unknown jump terminator");
      for (; PI != E; ++PI)
        if (SwitchInst *PSI = dyn_cast<SwitchInst>((*PI)->getTerminator()))
          if (PSI->getCondition() == Condition &&
              ProcessSwitchOnDuplicateCond(*PI, BB))
            return true;
    }
  }

  // All the rest of our checks depend on the condition being an instruction.
  if (CondInst == 0)
    return false;
  
  // See if this is a phi node in the current block.
  if (PHINode *PN = dyn_cast<PHINode>(CondInst))
    if (PN->getParent() == BB)
      return ProcessJumpOnPHI(PN);
  
  if (CmpInst *CondCmp = dyn_cast<CmpInst>(CondInst)) {
    if (!isa<PHINode>(CondCmp->getOperand(0)) ||
        cast<PHINode>(CondCmp->getOperand(0))->getParent() != BB) {
      // If we have a comparison, loop over the predecessors to see if there is
      // a condition with a lexically identical value.
      pred_iterator PI = pred_begin(BB), E = pred_end(BB);
      for (; PI != E; ++PI)
        if (BranchInst *PBI = dyn_cast<BranchInst>((*PI)->getTerminator()))
          if (PBI->isConditional() && *PI != BB) {
            if (CmpInst *CI = dyn_cast<CmpInst>(PBI->getCondition())) {
              if (CI->getOperand(0) == CondCmp->getOperand(0) &&
                  CI->getOperand(1) == CondCmp->getOperand(1) &&
                  CI->getPredicate() == CondCmp->getPredicate()) {
                // TODO: Could handle things like (x != 4) --> (x == 17)
                if (ProcessBranchOnDuplicateCond(*PI, BB))
                  return true;
              }
            }
          }
    }
  }

  // Check for some cases that are worth simplifying.  Right now we want to look
  // for loads that are used by a switch or by the condition for the branch.  If
  // we see one, check to see if it's partially redundant.  If so, insert a PHI
  // which can then be used to thread the values.
  //
  // This is particularly important because reg2mem inserts loads and stores all
  // over the place, and this blocks jump threading if we don't zap them.
  Value *SimplifyValue = CondInst;
  if (CmpInst *CondCmp = dyn_cast<CmpInst>(SimplifyValue))
    if (isa<Constant>(CondCmp->getOperand(1)))
      SimplifyValue = CondCmp->getOperand(0);
  
  if (LoadInst *LI = dyn_cast<LoadInst>(SimplifyValue))
    if (SimplifyPartiallyRedundantLoad(LI))
      return true;
  
  
  // Handle a variety of cases where we are branching on something derived from
  // a PHI node in the current block.  If we can prove that any predecessors
  // compute a predictable value based on a PHI node, thread those predecessors.
  //
  // We only bother doing this if the current block has a PHI node and if the
  // conditional instruction lives in the current block.  If either condition
  // fails, this won't be a computable value anyway.
  if (CondInst->getParent() == BB && isa<PHINode>(BB->front()))
    if (ProcessThreadableEdges(CondInst, BB))
      return true;
  
  
  // TODO: If we have: "br (X > 0)"  and we have a predecessor where we know
  // "(X == 4)" thread through this block.
  
  return false;
}

/// ProcessBranchOnDuplicateCond - We found a block and a predecessor of that
/// block that jump on exactly the same condition.  This means that we almost
/// always know the direction of the edge in the DESTBB:
///  PREDBB:
///     br COND, DESTBB, BBY
///  DESTBB:
///     br COND, BBZ, BBW
///
/// If DESTBB has multiple predecessors, we can't just constant fold the branch
/// in DESTBB, we have to thread over it.
bool JumpThreading::ProcessBranchOnDuplicateCond(BasicBlock *PredBB,
                                                 BasicBlock *BB) {
  BranchInst *PredBI = cast<BranchInst>(PredBB->getTerminator());
  
  // If both successors of PredBB go to DESTBB, we don't know anything.  We can
  // fold the branch to an unconditional one, which allows other recursive
  // simplifications.
  bool BranchDir;
  if (PredBI->getSuccessor(1) != BB)
    BranchDir = true;
  else if (PredBI->getSuccessor(0) != BB)
    BranchDir = false;
  else {
    DEBUG(errs() << "  In block '" << PredBB->getName()
          << "' folding terminator: " << *PredBB->getTerminator() << '\n');
    ++NumFolds;
    ConstantFoldTerminator(PredBB);
    return true;
  }
   
  BranchInst *DestBI = cast<BranchInst>(BB->getTerminator());

  // If the dest block has one predecessor, just fix the branch condition to a
  // constant and fold it.
  if (BB->getSinglePredecessor()) {
    DEBUG(errs() << "  In block '" << BB->getName()
          << "' folding condition to '" << BranchDir << "': "
          << *BB->getTerminator() << '\n');
    ++NumFolds;
    Value *OldCond = DestBI->getCondition();
    DestBI->setCondition(ConstantInt::get(Type::getInt1Ty(BB->getContext()),
                                          BranchDir));
    ConstantFoldTerminator(BB);
    RecursivelyDeleteTriviallyDeadInstructions(OldCond);
    return true;
  }
 
  
  // Next, figure out which successor we are threading to.
  BasicBlock *SuccBB = DestBI->getSuccessor(!BranchDir);
  
  SmallVector<BasicBlock*, 2> Preds;
  Preds.push_back(PredBB);
  
  // Ok, try to thread it!
  return ThreadEdge(BB, Preds, SuccBB);
}

/// ProcessSwitchOnDuplicateCond - We found a block and a predecessor of that
/// block that switch on exactly the same condition.  This means that we almost
/// always know the direction of the edge in the DESTBB:
///  PREDBB:
///     switch COND [... DESTBB, BBY ... ]
///  DESTBB:
///     switch COND [... BBZ, BBW ]
///
/// Optimizing switches like this is very important, because simplifycfg builds
/// switches out of repeated 'if' conditions.
bool JumpThreading::ProcessSwitchOnDuplicateCond(BasicBlock *PredBB,
                                                 BasicBlock *DestBB) {
  // Can't thread edge to self.
  if (PredBB == DestBB)
    return false;
  
  SwitchInst *PredSI = cast<SwitchInst>(PredBB->getTerminator());
  SwitchInst *DestSI = cast<SwitchInst>(DestBB->getTerminator());

  // There are a variety of optimizations that we can potentially do on these
  // blocks: we order them from most to least preferable.
  
  // If DESTBB *just* contains the switch, then we can forward edges from PREDBB
  // directly to their destination.  This does not introduce *any* code size
  // growth.  Skip debug info first.
  BasicBlock::iterator BBI = DestBB->begin();
  while (isa<DbgInfoIntrinsic>(BBI))
    BBI++;
  
  // FIXME: Thread if it just contains a PHI.
  if (isa<SwitchInst>(BBI)) {
    bool MadeChange = false;
    // Ignore the default edge for now.
    for (unsigned i = 1, e = DestSI->getNumSuccessors(); i != e; ++i) {
      ConstantInt *DestVal = DestSI->getCaseValue(i);
      BasicBlock *DestSucc = DestSI->getSuccessor(i);
      
      // Okay, DestSI has a case for 'DestVal' that goes to 'DestSucc'.  See if
      // PredSI has an explicit case for it.  If so, forward.  If it is covered
      // by the default case, we can't update PredSI.
      unsigned PredCase = PredSI->findCaseValue(DestVal);
      if (PredCase == 0) continue;
      
      // If PredSI doesn't go to DestBB on this value, then it won't reach the
      // case on this condition.
      if (PredSI->getSuccessor(PredCase) != DestBB &&
          DestSI->getSuccessor(i) != DestBB)
        continue;

      // Otherwise, we're safe to make the change.  Make sure that the edge from
      // DestSI to DestSucc is not critical and has no PHI nodes.
      DEBUG(errs() << "FORWARDING EDGE " << *DestVal << "   FROM: " << *PredSI);
      DEBUG(errs() << "THROUGH: " << *DestSI);

      // If the destination has PHI nodes, just split the edge for updating
      // simplicity.
      if (isa<PHINode>(DestSucc->begin()) && !DestSucc->getSinglePredecessor()){
        SplitCriticalEdge(DestSI, i, this);
        DestSucc = DestSI->getSuccessor(i);
      }
      FoldSingleEntryPHINodes(DestSucc);
      PredSI->setSuccessor(PredCase, DestSucc);
      MadeChange = true;
    }
    
    if (MadeChange)
      return true;
  }
  
  return false;
}


/// SimplifyPartiallyRedundantLoad - If LI is an obviously partially redundant
/// load instruction, eliminate it by replacing it with a PHI node.  This is an
/// important optimization that encourages jump threading, and needs to be run
/// interlaced with other jump threading tasks.
bool JumpThreading::SimplifyPartiallyRedundantLoad(LoadInst *LI) {
  // Don't hack volatile loads.
  if (LI->isVolatile()) return false;
  
  // If the load is defined in a block with exactly one predecessor, it can't be
  // partially redundant.
  BasicBlock *LoadBB = LI->getParent();
  if (LoadBB->getSinglePredecessor())
    return false;
  
  Value *LoadedPtr = LI->getOperand(0);

  // If the loaded operand is defined in the LoadBB, it can't be available.
  // FIXME: Could do PHI translation, that would be fun :)
  if (Instruction *PtrOp = dyn_cast<Instruction>(LoadedPtr))
    if (PtrOp->getParent() == LoadBB)
      return false;
  
  // Scan a few instructions up from the load, to see if it is obviously live at
  // the entry to its block.
  BasicBlock::iterator BBIt = LI;

  if (Value *AvailableVal = FindAvailableLoadedValue(LoadedPtr, LoadBB, 
                                                     BBIt, 6)) {
    // If the value if the load is locally available within the block, just use
    // it.  This frequently occurs for reg2mem'd allocas.
    //cerr << "LOAD ELIMINATED:\n" << *BBIt << *LI << "\n";
    
    // If the returned value is the load itself, replace with an undef. This can
    // only happen in dead loops.
    if (AvailableVal == LI) AvailableVal = UndefValue::get(LI->getType());
    LI->replaceAllUsesWith(AvailableVal);
    LI->eraseFromParent();
    return true;
  }

  // Otherwise, if we scanned the whole block and got to the top of the block,
  // we know the block is locally transparent to the load.  If not, something
  // might clobber its value.
  if (BBIt != LoadBB->begin())
    return false;
  
  
  SmallPtrSet<BasicBlock*, 8> PredsScanned;
  typedef SmallVector<std::pair<BasicBlock*, Value*>, 8> AvailablePredsTy;
  AvailablePredsTy AvailablePreds;
  BasicBlock *OneUnavailablePred = 0;
  
  // If we got here, the loaded value is transparent through to the start of the
  // block.  Check to see if it is available in any of the predecessor blocks.
  for (pred_iterator PI = pred_begin(LoadBB), PE = pred_end(LoadBB);
       PI != PE; ++PI) {
    BasicBlock *PredBB = *PI;

    // If we already scanned this predecessor, skip it.
    if (!PredsScanned.insert(PredBB))
      continue;

    // Scan the predecessor to see if the value is available in the pred.
    BBIt = PredBB->end();
    Value *PredAvailable = FindAvailableLoadedValue(LoadedPtr, PredBB, BBIt, 6);
    if (!PredAvailable) {
      OneUnavailablePred = PredBB;
      continue;
    }
    
    // If so, this load is partially redundant.  Remember this info so that we
    // can create a PHI node.
    AvailablePreds.push_back(std::make_pair(PredBB, PredAvailable));
  }
  
  // If the loaded value isn't available in any predecessor, it isn't partially
  // redundant.
  if (AvailablePreds.empty()) return false;
  
  // Okay, the loaded value is available in at least one (and maybe all!)
  // predecessors.  If the value is unavailable in more than one unique
  // predecessor, we want to insert a merge block for those common predecessors.
  // This ensures that we only have to insert one reload, thus not increasing
  // code size.
  BasicBlock *UnavailablePred = 0;
  
  // If there is exactly one predecessor where the value is unavailable, the
  // already computed 'OneUnavailablePred' block is it.  If it ends in an
  // unconditional branch, we know that it isn't a critical edge.
  if (PredsScanned.size() == AvailablePreds.size()+1 &&
      OneUnavailablePred->getTerminator()->getNumSuccessors() == 1) {
    UnavailablePred = OneUnavailablePred;
  } else if (PredsScanned.size() != AvailablePreds.size()) {
    // Otherwise, we had multiple unavailable predecessors or we had a critical
    // edge from the one.
    SmallVector<BasicBlock*, 8> PredsToSplit;
    SmallPtrSet<BasicBlock*, 8> AvailablePredSet;

    for (unsigned i = 0, e = AvailablePreds.size(); i != e; ++i)
      AvailablePredSet.insert(AvailablePreds[i].first);

    // Add all the unavailable predecessors to the PredsToSplit list.
    for (pred_iterator PI = pred_begin(LoadBB), PE = pred_end(LoadBB);
         PI != PE; ++PI)
      if (!AvailablePredSet.count(*PI))
        PredsToSplit.push_back(*PI);
    
    // Split them out to their own block.
    UnavailablePred =
      SplitBlockPredecessors(LoadBB, &PredsToSplit[0], PredsToSplit.size(),
                             "thread-split", this);
  }
  
  // If the value isn't available in all predecessors, then there will be
  // exactly one where it isn't available.  Insert a load on that edge and add
  // it to the AvailablePreds list.
  if (UnavailablePred) {
    assert(UnavailablePred->getTerminator()->getNumSuccessors() == 1 &&
           "Can't handle critical edge here!");
    Value *NewVal = new LoadInst(LoadedPtr, LI->getName()+".pr",
                                 UnavailablePred->getTerminator());
    AvailablePreds.push_back(std::make_pair(UnavailablePred, NewVal));
  }
  
  // Now we know that each predecessor of this block has a value in
  // AvailablePreds, sort them for efficient access as we're walking the preds.
  array_pod_sort(AvailablePreds.begin(), AvailablePreds.end());
  
  // Create a PHI node at the start of the block for the PRE'd load value.
  PHINode *PN = PHINode::Create(LI->getType(), "", LoadBB->begin());
  PN->takeName(LI);
  
  // Insert new entries into the PHI for each predecessor.  A single block may
  // have multiple entries here.
  for (pred_iterator PI = pred_begin(LoadBB), E = pred_end(LoadBB); PI != E;
       ++PI) {
    AvailablePredsTy::iterator I = 
      std::lower_bound(AvailablePreds.begin(), AvailablePreds.end(),
                       std::make_pair(*PI, (Value*)0));
    
    assert(I != AvailablePreds.end() && I->first == *PI &&
           "Didn't find entry for predecessor!");
    
    PN->addIncoming(I->second, I->first);
  }
  
  //cerr << "PRE: " << *LI << *PN << "\n";
  
  LI->replaceAllUsesWith(PN);
  LI->eraseFromParent();
  
  return true;
}

/// FindMostPopularDest - The specified list contains multiple possible
/// threadable destinations.  Pick the one that occurs the most frequently in
/// the list.
static BasicBlock *
FindMostPopularDest(BasicBlock *BB,
                    const SmallVectorImpl<std::pair<BasicBlock*,
                                  BasicBlock*> > &PredToDestList) {
  assert(!PredToDestList.empty());
  
  // Determine popularity.  If there are multiple possible destinations, we
  // explicitly choose to ignore 'undef' destinations.  We prefer to thread
  // blocks with known and real destinations to threading undef.  We'll handle
  // them later if interesting.
  DenseMap<BasicBlock*, unsigned> DestPopularity;
  for (unsigned i = 0, e = PredToDestList.size(); i != e; ++i)
    if (PredToDestList[i].second)
      DestPopularity[PredToDestList[i].second]++;
  
  // Find the most popular dest.
  DenseMap<BasicBlock*, unsigned>::iterator DPI = DestPopularity.begin();
  BasicBlock *MostPopularDest = DPI->first;
  unsigned Popularity = DPI->second;
  SmallVector<BasicBlock*, 4> SamePopularity;
  
  for (++DPI; DPI != DestPopularity.end(); ++DPI) {
    // If the popularity of this entry isn't higher than the popularity we've
    // seen so far, ignore it.
    if (DPI->second < Popularity)
      ; // ignore.
    else if (DPI->second == Popularity) {
      // If it is the same as what we've seen so far, keep track of it.
      SamePopularity.push_back(DPI->first);
    } else {
      // If it is more popular, remember it.
      SamePopularity.clear();
      MostPopularDest = DPI->first;
      Popularity = DPI->second;
    }      
  }
  
  // Okay, now we know the most popular destination.  If there is more than
  // destination, we need to determine one.  This is arbitrary, but we need
  // to make a deterministic decision.  Pick the first one that appears in the
  // successor list.
  if (!SamePopularity.empty()) {
    SamePopularity.push_back(MostPopularDest);
    TerminatorInst *TI = BB->getTerminator();
    for (unsigned i = 0; ; ++i) {
      assert(i != TI->getNumSuccessors() && "Didn't find any successor!");
      
      if (std::find(SamePopularity.begin(), SamePopularity.end(),
                    TI->getSuccessor(i)) == SamePopularity.end())
        continue;
      
      MostPopularDest = TI->getSuccessor(i);
      break;
    }
  }
  
  // Okay, we have finally picked the most popular destination.
  return MostPopularDest;
}

bool JumpThreading::ProcessThreadableEdges(Instruction *CondInst,
                                           BasicBlock *BB) {
  // If threading this would thread across a loop header, don't even try to
  // thread the edge.
  if (LoopHeaders.count(BB))
    return false;
  
  SmallVector<std::pair<ConstantInt*, BasicBlock*>, 8> PredValues;
  if (!ComputeValueKnownInPredecessors(CondInst, BB, PredValues))
    return false;
  assert(!PredValues.empty() &&
         "ComputeValueKnownInPredecessors returned true with no values");

  DEBUG(errs() << "IN BB: " << *BB;
        for (unsigned i = 0, e = PredValues.size(); i != e; ++i) {
          errs() << "  BB '" << BB->getName() << "': FOUND condition = ";
          if (PredValues[i].first)
            errs() << *PredValues[i].first;
          else
            errs() << "UNDEF";
          errs() << " for pred '" << PredValues[i].second->getName()
          << "'.\n";
        });
  
  // Decide what we want to thread through.  Convert our list of known values to
  // a list of known destinations for each pred.  This also discards duplicate
  // predecessors and keeps track of the undefined inputs (which are represented
  // as a null dest in the PredToDestList).
  SmallPtrSet<BasicBlock*, 16> SeenPreds;
  SmallVector<std::pair<BasicBlock*, BasicBlock*>, 16> PredToDestList;
  
  BasicBlock *OnlyDest = 0;
  BasicBlock *MultipleDestSentinel = (BasicBlock*)(intptr_t)~0ULL;
  
  for (unsigned i = 0, e = PredValues.size(); i != e; ++i) {
    BasicBlock *Pred = PredValues[i].second;
    if (!SeenPreds.insert(Pred))
      continue;  // Duplicate predecessor entry.
    
    // If the predecessor ends with an indirect goto, we can't change its
    // destination.
    if (isa<IndirectBrInst>(Pred->getTerminator()))
      continue;
    
    ConstantInt *Val = PredValues[i].first;
    
    BasicBlock *DestBB;
    if (Val == 0)      // Undef.
      DestBB = 0;
    else if (BranchInst *BI = dyn_cast<BranchInst>(BB->getTerminator()))
      DestBB = BI->getSuccessor(Val->isZero());
    else {
      SwitchInst *SI = cast<SwitchInst>(BB->getTerminator());
      DestBB = SI->getSuccessor(SI->findCaseValue(Val));
    }

    // If we have exactly one destination, remember it for efficiency below.
    if (i == 0)
      OnlyDest = DestBB;
    else if (OnlyDest != DestBB)
      OnlyDest = MultipleDestSentinel;
    
    PredToDestList.push_back(std::make_pair(Pred, DestBB));
  }
  
  // If all edges were unthreadable, we fail.
  if (PredToDestList.empty())
    return false;
  
  // Determine which is the most common successor.  If we have many inputs and
  // this block is a switch, we want to start by threading the batch that goes
  // to the most popular destination first.  If we only know about one
  // threadable destination (the common case) we can avoid this.
  BasicBlock *MostPopularDest = OnlyDest;
  
  if (MostPopularDest == MultipleDestSentinel)
    MostPopularDest = FindMostPopularDest(BB, PredToDestList);
  
  // Now that we know what the most popular destination is, factor all
  // predecessors that will jump to it into a single predecessor.
  SmallVector<BasicBlock*, 16> PredsToFactor;
  for (unsigned i = 0, e = PredToDestList.size(); i != e; ++i)
    if (PredToDestList[i].second == MostPopularDest) {
      BasicBlock *Pred = PredToDestList[i].first;
      
      // This predecessor may be a switch or something else that has multiple
      // edges to the block.  Factor each of these edges by listing them
      // according to # occurrences in PredsToFactor.
      TerminatorInst *PredTI = Pred->getTerminator();
      for (unsigned i = 0, e = PredTI->getNumSuccessors(); i != e; ++i)
        if (PredTI->getSuccessor(i) == BB)
          PredsToFactor.push_back(Pred);
    }

  // If the threadable edges are branching on an undefined value, we get to pick
  // the destination that these predecessors should get to.
  if (MostPopularDest == 0)
    MostPopularDest = BB->getTerminator()->
                            getSuccessor(GetBestDestForJumpOnUndef(BB));
        
  // Ok, try to thread it!
  return ThreadEdge(BB, PredsToFactor, MostPopularDest);
}

/// ProcessJumpOnPHI - We have a conditional branch or switch on a PHI node in
/// the current block.  See if there are any simplifications we can do based on
/// inputs to the phi node.
/// 
bool JumpThreading::ProcessJumpOnPHI(PHINode *PN) {
  BasicBlock *BB = PN->getParent();
  
  // If any of the predecessor blocks end in an unconditional branch, we can
  // *duplicate* the jump into that block in order to further encourage jump
  // threading and to eliminate cases where we have branch on a phi of an icmp
  // (branch on icmp is much better).

  // We don't want to do this tranformation for switches, because we don't
  // really want to duplicate a switch.
  if (isa<SwitchInst>(BB->getTerminator()))
    return false;
  
  // Look for unconditional branch predecessors.
  for (unsigned i = 0, e = PN->getNumIncomingValues(); i != e; ++i) {
    BasicBlock *PredBB = PN->getIncomingBlock(i);
    if (BranchInst *PredBr = dyn_cast<BranchInst>(PredBB->getTerminator()))
      if (PredBr->isUnconditional() &&
          // Try to duplicate BB into PredBB.
          DuplicateCondBranchOnPHIIntoPred(BB, PredBB))
        return true;
  }

  return false;
}


/// AddPHINodeEntriesForMappedBlock - We're adding 'NewPred' as a new
/// predecessor to the PHIBB block.  If it has PHI nodes, add entries for
/// NewPred using the entries from OldPred (suitably mapped).
static void AddPHINodeEntriesForMappedBlock(BasicBlock *PHIBB,
                                            BasicBlock *OldPred,
                                            BasicBlock *NewPred,
                                     DenseMap<Instruction*, Value*> &ValueMap) {
  for (BasicBlock::iterator PNI = PHIBB->begin();
       PHINode *PN = dyn_cast<PHINode>(PNI); ++PNI) {
    // Ok, we have a PHI node.  Figure out what the incoming value was for the
    // DestBlock.
    Value *IV = PN->getIncomingValueForBlock(OldPred);
    
    // Remap the value if necessary.
    if (Instruction *Inst = dyn_cast<Instruction>(IV)) {
      DenseMap<Instruction*, Value*>::iterator I = ValueMap.find(Inst);
      if (I != ValueMap.end())
        IV = I->second;
    }
    
    PN->addIncoming(IV, NewPred);
  }
}

/// ThreadEdge - We have decided that it is safe and profitable to factor the
/// blocks in PredBBs to one predecessor, then thread an edge from it to SuccBB
/// across BB.  Transform the IR to reflect this change.
bool JumpThreading::ThreadEdge(BasicBlock *BB, 
                               const SmallVectorImpl<BasicBlock*> &PredBBs, 
                               BasicBlock *SuccBB) {
  // If threading to the same block as we come from, we would infinite loop.
  if (SuccBB == BB) {
    DEBUG(errs() << "  Not threading across BB '" << BB->getName()
          << "' - would thread to self!\n");
    return false;
  }
  
  // If threading this would thread across a loop header, don't thread the edge.
  // See the comments above FindLoopHeaders for justifications and caveats.
  if (LoopHeaders.count(BB)) {
    DEBUG(errs() << "  Not threading across loop header BB '" << BB->getName()
          << "' to dest BB '" << SuccBB->getName()
          << "' - it might create an irreducible loop!\n");
    return false;
  }

  unsigned JumpThreadCost = getJumpThreadDuplicationCost(BB);
  if (JumpThreadCost > Threshold) {
    DEBUG(errs() << "  Not threading BB '" << BB->getName()
          << "' - Cost is too high: " << JumpThreadCost << "\n");
    return false;
  }
  
  // And finally, do it!  Start by factoring the predecessors is needed.
  BasicBlock *PredBB;
  if (PredBBs.size() == 1)
    PredBB = PredBBs[0];
  else {
    DEBUG(errs() << "  Factoring out " << PredBBs.size()
          << " common predecessors.\n");
    PredBB = SplitBlockPredecessors(BB, &PredBBs[0], PredBBs.size(),
                                    ".thr_comm", this);
  }
  
  // And finally, do it!
  DEBUG(errs() << "  Threading edge from '" << PredBB->getName() << "' to '"
        << SuccBB->getName() << "' with cost: " << JumpThreadCost
        << ", across block:\n    "
        << *BB << "\n");
  
  // We are going to have to map operands from the original BB block to the new
  // copy of the block 'NewBB'.  If there are PHI nodes in BB, evaluate them to
  // account for entry from PredBB.
  DenseMap<Instruction*, Value*> ValueMapping;
  
  BasicBlock *NewBB = BasicBlock::Create(BB->getContext(), 
                                         BB->getName()+".thread", 
                                         BB->getParent(), BB);
  NewBB->moveAfter(PredBB);
  
  BasicBlock::iterator BI = BB->begin();
  for (; PHINode *PN = dyn_cast<PHINode>(BI); ++BI)
    ValueMapping[PN] = PN->getIncomingValueForBlock(PredBB);
  
  // Clone the non-phi instructions of BB into NewBB, keeping track of the
  // mapping and using it to remap operands in the cloned instructions.
  for (; !isa<TerminatorInst>(BI); ++BI) {
    Instruction *New = BI->clone();
    New->setName(BI->getName());
    NewBB->getInstList().push_back(New);
    ValueMapping[BI] = New;
   
    // Remap operands to patch up intra-block references.
    for (unsigned i = 0, e = New->getNumOperands(); i != e; ++i)
      if (Instruction *Inst = dyn_cast<Instruction>(New->getOperand(i))) {
        DenseMap<Instruction*, Value*>::iterator I = ValueMapping.find(Inst);
        if (I != ValueMapping.end())
          New->setOperand(i, I->second);
      }
  }
  
  // We didn't copy the terminator from BB over to NewBB, because there is now
  // an unconditional jump to SuccBB.  Insert the unconditional jump.
  BranchInst::Create(SuccBB, NewBB);
  
  // Check to see if SuccBB has PHI nodes. If so, we need to add entries to the
  // PHI nodes for NewBB now.
  AddPHINodeEntriesForMappedBlock(SuccBB, BB, NewBB, ValueMapping);
  
  // If there were values defined in BB that are used outside the block, then we
  // now have to update all uses of the value to use either the original value,
  // the cloned value, or some PHI derived value.  This can require arbitrary
  // PHI insertion, of which we are prepared to do, clean these up now.
  SSAUpdater SSAUpdate;
  SmallVector<Use*, 16> UsesToRename;
  for (BasicBlock::iterator I = BB->begin(); I != BB->end(); ++I) {
    // Scan all uses of this instruction to see if it is used outside of its
    // block, and if so, record them in UsesToRename.
    for (Value::use_iterator UI = I->use_begin(), E = I->use_end(); UI != E;
         ++UI) {
      Instruction *User = cast<Instruction>(*UI);
      if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
        if (UserPN->getIncomingBlock(UI) == BB)
          continue;
      } else if (User->getParent() == BB)
        continue;
      
      UsesToRename.push_back(&UI.getUse());
    }
    
    // If there are no uses outside the block, we're done with this instruction.
    if (UsesToRename.empty())
      continue;
    
    DEBUG(errs() << "JT: Renaming non-local uses of: " << *I << "\n");

    // We found a use of I outside of BB.  Rename all uses of I that are outside
    // its block to be uses of the appropriate PHI node etc.  See ValuesInBlocks
    // with the two values we know.
    SSAUpdate.Initialize(I);
    SSAUpdate.AddAvailableValue(BB, I);
    SSAUpdate.AddAvailableValue(NewBB, ValueMapping[I]);
    
    while (!UsesToRename.empty())
      SSAUpdate.RewriteUse(*UsesToRename.pop_back_val());
    DEBUG(errs() << "\n");
  }
  
  
  // Ok, NewBB is good to go.  Update the terminator of PredBB to jump to
  // NewBB instead of BB.  This eliminates predecessors from BB, which requires
  // us to simplify any PHI nodes in BB.
  TerminatorInst *PredTerm = PredBB->getTerminator();
  for (unsigned i = 0, e = PredTerm->getNumSuccessors(); i != e; ++i)
    if (PredTerm->getSuccessor(i) == BB) {
      RemovePredecessorAndSimplify(BB, PredBB, TD);
      PredTerm->setSuccessor(i, NewBB);
    }
  
  // At this point, the IR is fully up to date and consistent.  Do a quick scan
  // over the new instructions and zap any that are constants or dead.  This
  // frequently happens because of phi translation.
  BI = NewBB->begin();
  for (BasicBlock::iterator E = NewBB->end(); BI != E; ) {
    Instruction *Inst = BI++;
    if (Value *V = SimplifyInstruction(Inst, TD)) {
      Inst->replaceAllUsesWith(V);
      Inst->eraseFromParent();
      continue;
    }
    
    RecursivelyDeleteTriviallyDeadInstructions(Inst);
  }
  
  // Threaded an edge!
  ++NumThreads;
  return true;
}

/// DuplicateCondBranchOnPHIIntoPred - PredBB contains an unconditional branch
/// to BB which contains an i1 PHI node and a conditional branch on that PHI.
/// If we can duplicate the contents of BB up into PredBB do so now, this
/// improves the odds that the branch will be on an analyzable instruction like
/// a compare.
bool JumpThreading::DuplicateCondBranchOnPHIIntoPred(BasicBlock *BB,
                                                     BasicBlock *PredBB) {
  // If BB is a loop header, then duplicating this block outside the loop would
  // cause us to transform this into an irreducible loop, don't do this.
  // See the comments above FindLoopHeaders for justifications and caveats.
  if (LoopHeaders.count(BB)) {
    DEBUG(errs() << "  Not duplicating loop header '" << BB->getName()
          << "' into predecessor block '" << PredBB->getName()
          << "' - it might create an irreducible loop!\n");
    return false;
  }
  
  unsigned DuplicationCost = getJumpThreadDuplicationCost(BB);
  if (DuplicationCost > Threshold) {
    DEBUG(errs() << "  Not duplicating BB '" << BB->getName()
          << "' - Cost is too high: " << DuplicationCost << "\n");
    return false;
  }
  
  // Okay, we decided to do this!  Clone all the instructions in BB onto the end
  // of PredBB.
  DEBUG(errs() << "  Duplicating block '" << BB->getName() << "' into end of '"
        << PredBB->getName() << "' to eliminate branch on phi.  Cost: "
        << DuplicationCost << " block is:" << *BB << "\n");
  
  // We are going to have to map operands from the original BB block into the
  // PredBB block.  Evaluate PHI nodes in BB.
  DenseMap<Instruction*, Value*> ValueMapping;
  
  BasicBlock::iterator BI = BB->begin();
  for (; PHINode *PN = dyn_cast<PHINode>(BI); ++BI)
    ValueMapping[PN] = PN->getIncomingValueForBlock(PredBB);
  
  BranchInst *OldPredBranch = cast<BranchInst>(PredBB->getTerminator());
  
  // Clone the non-phi instructions of BB into PredBB, keeping track of the
  // mapping and using it to remap operands in the cloned instructions.
  for (; BI != BB->end(); ++BI) {
    Instruction *New = BI->clone();
    New->setName(BI->getName());
    PredBB->getInstList().insert(OldPredBranch, New);
    ValueMapping[BI] = New;
    
    // Remap operands to patch up intra-block references.
    for (unsigned i = 0, e = New->getNumOperands(); i != e; ++i)
      if (Instruction *Inst = dyn_cast<Instruction>(New->getOperand(i))) {
        DenseMap<Instruction*, Value*>::iterator I = ValueMapping.find(Inst);
        if (I != ValueMapping.end())
          New->setOperand(i, I->second);
      }
  }
  
  // Check to see if the targets of the branch had PHI nodes. If so, we need to
  // add entries to the PHI nodes for branch from PredBB now.
  BranchInst *BBBranch = cast<BranchInst>(BB->getTerminator());
  AddPHINodeEntriesForMappedBlock(BBBranch->getSuccessor(0), BB, PredBB,
                                  ValueMapping);
  AddPHINodeEntriesForMappedBlock(BBBranch->getSuccessor(1), BB, PredBB,
                                  ValueMapping);
  
  // If there were values defined in BB that are used outside the block, then we
  // now have to update all uses of the value to use either the original value,
  // the cloned value, or some PHI derived value.  This can require arbitrary
  // PHI insertion, of which we are prepared to do, clean these up now.
  SSAUpdater SSAUpdate;
  SmallVector<Use*, 16> UsesToRename;
  for (BasicBlock::iterator I = BB->begin(); I != BB->end(); ++I) {
    // Scan all uses of this instruction to see if it is used outside of its
    // block, and if so, record them in UsesToRename.
    for (Value::use_iterator UI = I->use_begin(), E = I->use_end(); UI != E;
         ++UI) {
      Instruction *User = cast<Instruction>(*UI);
      if (PHINode *UserPN = dyn_cast<PHINode>(User)) {
        if (UserPN->getIncomingBlock(UI) == BB)
          continue;
      } else if (User->getParent() == BB)
        continue;
      
      UsesToRename.push_back(&UI.getUse());
    }
    
    // If there are no uses outside the block, we're done with this instruction.
    if (UsesToRename.empty())
      continue;
    
    DEBUG(errs() << "JT: Renaming non-local uses of: " << *I << "\n");
    
    // We found a use of I outside of BB.  Rename all uses of I that are outside
    // its block to be uses of the appropriate PHI node etc.  See ValuesInBlocks
    // with the two values we know.
    SSAUpdate.Initialize(I);
    SSAUpdate.AddAvailableValue(BB, I);
    SSAUpdate.AddAvailableValue(PredBB, ValueMapping[I]);
    
    while (!UsesToRename.empty())
      SSAUpdate.RewriteUse(*UsesToRename.pop_back_val());
    DEBUG(errs() << "\n");
  }
  
  // PredBB no longer jumps to BB, remove entries in the PHI node for the edge
  // that we nuked.
  RemovePredecessorAndSimplify(BB, PredBB, TD);
  
  // Remove the unconditional branch at the end of the PredBB block.
  OldPredBranch->eraseFromParent();
  
  ++NumDupes;
  return true;
}


