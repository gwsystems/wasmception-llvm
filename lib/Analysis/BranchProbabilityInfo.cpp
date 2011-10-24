//===-- BranchProbabilityInfo.cpp - Branch Probability Analysis -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Loops should be simplified before this analysis.
//
//===----------------------------------------------------------------------===//

#include "llvm/Constants.h"
#include "llvm/Function.h"
#include "llvm/Instructions.h"
#include "llvm/LLVMContext.h"
#include "llvm/Metadata.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/CFG.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

INITIALIZE_PASS_BEGIN(BranchProbabilityInfo, "branch-prob",
                      "Branch Probability Analysis", false, true)
INITIALIZE_PASS_DEPENDENCY(LoopInfo)
INITIALIZE_PASS_END(BranchProbabilityInfo, "branch-prob",
                    "Branch Probability Analysis", false, true)

char BranchProbabilityInfo::ID = 0;

// Weights are for internal use only. They are used by heuristics to help to
// estimate edges' probability. Example:
//
// Using "Loop Branch Heuristics" we predict weights of edges for the
// block BB2.
//         ...
//          |
//          V
//         BB1<-+
//          |   |
//          |   | (Weight = 124)
//          V   |
//         BB2--+
//          |
//          | (Weight = 4)
//          V
//         BB3
//
// Probability of the edge BB2->BB1 = 124 / (124 + 4) = 0.96875
// Probability of the edge BB2->BB3 = 4 / (124 + 4) = 0.03125
static const uint32_t LBH_TAKEN_WEIGHT = 124;
static const uint32_t LBH_NONTAKEN_WEIGHT = 4;

static const uint32_t RH_TAKEN_WEIGHT = 24;
static const uint32_t RH_NONTAKEN_WEIGHT = 8;

static const uint32_t PH_TAKEN_WEIGHT = 20;
static const uint32_t PH_NONTAKEN_WEIGHT = 12;

static const uint32_t ZH_TAKEN_WEIGHT = 20;
static const uint32_t ZH_NONTAKEN_WEIGHT = 12;

static const uint32_t FPH_TAKEN_WEIGHT = 20;
static const uint32_t FPH_NONTAKEN_WEIGHT = 12;

// Standard weight value. Used when none of the heuristics set weight for
// the edge.
static const uint32_t NORMAL_WEIGHT = 16;

// Minimum weight of an edge. Please note, that weight is NEVER 0.
static const uint32_t MIN_WEIGHT = 1;

// Return TRUE if BB leads directly to a Return Instruction.
static bool isReturningBlock(BasicBlock *BB) {
  SmallPtrSet<BasicBlock *, 8> Visited;

  while (true) {
    TerminatorInst *TI = BB->getTerminator();
    if (isa<ReturnInst>(TI))
      return true;

    if (TI->getNumSuccessors() > 1)
      break;

    // It is unreachable block which we can consider as a return instruction.
    if (TI->getNumSuccessors() == 0)
      return true;

    Visited.insert(BB);
    BB = TI->getSuccessor(0);

    // Stop if cycle is detected.
    if (Visited.count(BB))
      return false;
  }

  return false;
}

static uint32_t getMaxWeightFor(BasicBlock *BB) {
  return UINT32_MAX / BB->getTerminator()->getNumSuccessors();
}


// Propagate existing explicit probabilities from either profile data or
// 'expect' intrinsic processing.
bool BranchProbabilityInfo::calcMetadataWeights(BasicBlock *BB) {
  TerminatorInst *TI = BB->getTerminator();
  if (TI->getNumSuccessors() == 1)
    return false;
  if (!isa<BranchInst>(TI) && !isa<SwitchInst>(TI))
    return false;

  MDNode *WeightsNode = TI->getMetadata(LLVMContext::MD_prof);
  if (!WeightsNode)
    return false;

  // Ensure there are weights for all of the successors. Note that the first
  // operand to the metadata node is a name, not a weight.
  if (WeightsNode->getNumOperands() != TI->getNumSuccessors() + 1)
    return false;

  // Build up the final weights that will be used in a temporary buffer, but
  // don't add them until all weihts are present. Each weight value is clamped
  // to [1, getMaxWeightFor(BB)].
  uint32_t WeightLimit = getMaxWeightFor(BB);
  SmallVector<uint32_t, 2> Weights;
  Weights.reserve(TI->getNumSuccessors());
  for (unsigned i = 1, e = WeightsNode->getNumOperands(); i != e; ++i) {
    ConstantInt *Weight = dyn_cast<ConstantInt>(WeightsNode->getOperand(i));
    if (!Weight)
      return false;
    Weights.push_back(
      std::max<uint32_t>(1, Weight->getLimitedValue(WeightLimit)));
  }
  assert(Weights.size() == TI->getNumSuccessors() && "Checked above");
  for (unsigned i = 0, e = TI->getNumSuccessors(); i != e; ++i)
    setEdgeWeight(BB, TI->getSuccessor(i), Weights[i]);

  return true;
}

// Calculate Edge Weights using "Return Heuristics". Predict a successor which
// leads directly to Return Instruction will not be taken.
bool BranchProbabilityInfo::calcReturnHeuristics(BasicBlock *BB){
  if (BB->getTerminator()->getNumSuccessors() == 1)
    return false;

  SmallPtrSet<BasicBlock *, 4> ReturningEdges;
  SmallPtrSet<BasicBlock *, 4> StayEdges;

  for (succ_iterator I = succ_begin(BB), E = succ_end(BB); I != E; ++I) {
    BasicBlock *Succ = *I;
    if (isReturningBlock(Succ))
      ReturningEdges.insert(Succ);
    else
      StayEdges.insert(Succ);
  }

  if (uint32_t numStayEdges = StayEdges.size()) {
    uint32_t stayWeight = RH_TAKEN_WEIGHT / numStayEdges;
    if (stayWeight < NORMAL_WEIGHT)
      stayWeight = NORMAL_WEIGHT;

    for (SmallPtrSet<BasicBlock *, 4>::iterator I = StayEdges.begin(),
         E = StayEdges.end(); I != E; ++I)
      setEdgeWeight(BB, *I, stayWeight);
  }

  if (uint32_t numRetEdges = ReturningEdges.size()) {
    uint32_t retWeight = RH_NONTAKEN_WEIGHT / numRetEdges;
    if (retWeight < MIN_WEIGHT)
      retWeight = MIN_WEIGHT;
    for (SmallPtrSet<BasicBlock *, 4>::iterator I = ReturningEdges.begin(),
         E = ReturningEdges.end(); I != E; ++I) {
      setEdgeWeight(BB, *I, retWeight);
    }
  }

  return ReturningEdges.size() > 0;
}

// Calculate Edge Weights using "Pointer Heuristics". Predict a comparsion
// between two pointer or pointer and NULL will fail.
bool BranchProbabilityInfo::calcPointerHeuristics(BasicBlock *BB) {
  BranchInst * BI = dyn_cast<BranchInst>(BB->getTerminator());
  if (!BI || !BI->isConditional())
    return false;

  Value *Cond = BI->getCondition();
  ICmpInst *CI = dyn_cast<ICmpInst>(Cond);
  if (!CI || !CI->isEquality())
    return false;

  Value *LHS = CI->getOperand(0);

  if (!LHS->getType()->isPointerTy())
    return false;

  assert(CI->getOperand(1)->getType()->isPointerTy());

  BasicBlock *Taken = BI->getSuccessor(0);
  BasicBlock *NonTaken = BI->getSuccessor(1);

  // p != 0   ->   isProb = true
  // p == 0   ->   isProb = false
  // p != q   ->   isProb = true
  // p == q   ->   isProb = false;
  bool isProb = CI->getPredicate() == ICmpInst::ICMP_NE;
  if (!isProb)
    std::swap(Taken, NonTaken);

  setEdgeWeight(BB, Taken, PH_TAKEN_WEIGHT);
  setEdgeWeight(BB, NonTaken, PH_NONTAKEN_WEIGHT);
  return true;
}

// Calculate Edge Weights using "Loop Branch Heuristics". Predict backedges
// as taken, exiting edges as not-taken.
bool BranchProbabilityInfo::calcLoopBranchHeuristics(BasicBlock *BB) {
  uint32_t numSuccs = BB->getTerminator()->getNumSuccessors();

  Loop *L = LI->getLoopFor(BB);
  if (!L)
    return false;

  SmallPtrSet<BasicBlock *, 8> BackEdges;
  SmallPtrSet<BasicBlock *, 8> ExitingEdges;
  SmallPtrSet<BasicBlock *, 8> InEdges; // Edges from header to the loop.

  bool isHeader = BB == L->getHeader();

  for (succ_iterator I = succ_begin(BB), E = succ_end(BB); I != E; ++I) {
    BasicBlock *Succ = *I;
    Loop *SuccL = LI->getLoopFor(Succ);
    if (SuccL != L)
      ExitingEdges.insert(Succ);
    else if (Succ == L->getHeader())
      BackEdges.insert(Succ);
    else if (isHeader)
      InEdges.insert(Succ);
  }

  if (uint32_t numBackEdges = BackEdges.size()) {
    uint32_t backWeight = LBH_TAKEN_WEIGHT / numBackEdges;
    if (backWeight < NORMAL_WEIGHT)
      backWeight = NORMAL_WEIGHT;

    for (SmallPtrSet<BasicBlock *, 8>::iterator EI = BackEdges.begin(),
         EE = BackEdges.end(); EI != EE; ++EI) {
      BasicBlock *Back = *EI;
      setEdgeWeight(BB, Back, backWeight);
    }
  }

  if (uint32_t numInEdges = InEdges.size()) {
    uint32_t inWeight = LBH_TAKEN_WEIGHT / numInEdges;
    if (inWeight < NORMAL_WEIGHT)
      inWeight = NORMAL_WEIGHT;

    for (SmallPtrSet<BasicBlock *, 8>::iterator EI = InEdges.begin(),
         EE = InEdges.end(); EI != EE; ++EI) {
      BasicBlock *Back = *EI;
      setEdgeWeight(BB, Back, inWeight);
    }
  }

  uint32_t numExitingEdges = ExitingEdges.size();
  if (uint32_t numNonExitingEdges = numSuccs - numExitingEdges) {
    uint32_t exitWeight = LBH_NONTAKEN_WEIGHT / numNonExitingEdges;
    if (exitWeight < MIN_WEIGHT)
      exitWeight = MIN_WEIGHT;

    for (SmallPtrSet<BasicBlock *, 8>::iterator EI = ExitingEdges.begin(),
         EE = ExitingEdges.end(); EI != EE; ++EI) {
      BasicBlock *Exiting = *EI;
      setEdgeWeight(BB, Exiting, exitWeight);
    }
  }

  return true;
}

bool BranchProbabilityInfo::calcZeroHeuristics(BasicBlock *BB) {
  BranchInst * BI = dyn_cast<BranchInst>(BB->getTerminator());
  if (!BI || !BI->isConditional())
    return false;

  Value *Cond = BI->getCondition();
  ICmpInst *CI = dyn_cast<ICmpInst>(Cond);
  if (!CI)
    return false;

  Value *RHS = CI->getOperand(1);
  ConstantInt *CV = dyn_cast<ConstantInt>(RHS);
  if (!CV)
    return false;

  bool isProb;
  if (CV->isZero()) {
    switch (CI->getPredicate()) {
    case CmpInst::ICMP_EQ:
      // X == 0   ->  Unlikely
      isProb = false;
      break;
    case CmpInst::ICMP_NE:
      // X != 0   ->  Likely
      isProb = true;
      break;
    case CmpInst::ICMP_SLT:
      // X < 0   ->  Unlikely
      isProb = false;
      break;
    case CmpInst::ICMP_SGT:
      // X > 0   ->  Likely
      isProb = true;
      break;
    default:
      return false;
    }
  } else if (CV->isOne() && CI->getPredicate() == CmpInst::ICMP_SLT) {
    // InstCombine canonicalizes X <= 0 into X < 1.
    // X <= 0   ->  Unlikely
    isProb = false;
  } else if (CV->isAllOnesValue() && CI->getPredicate() == CmpInst::ICMP_SGT) {
    // InstCombine canonicalizes X >= 0 into X > -1.
    // X >= 0   ->  Likely
    isProb = true;
  } else {
    return false;
  }

  BasicBlock *Taken = BI->getSuccessor(0);
  BasicBlock *NonTaken = BI->getSuccessor(1);

  if (!isProb)
    std::swap(Taken, NonTaken);

  setEdgeWeight(BB, Taken, ZH_TAKEN_WEIGHT);
  setEdgeWeight(BB, NonTaken, ZH_NONTAKEN_WEIGHT);

  return true;
}

bool BranchProbabilityInfo::calcFloatingPointHeuristics(BasicBlock *BB) {
  BranchInst *BI = dyn_cast<BranchInst>(BB->getTerminator());
  if (!BI || !BI->isConditional())
    return false;

  Value *Cond = BI->getCondition();
  FCmpInst *FCmp = dyn_cast<FCmpInst>(Cond);
  if (!FCmp)
    return false;

  bool isProb;
  if (FCmp->isEquality()) {
    // f1 == f2 -> Unlikely
    // f1 != f2 -> Likely
    isProb = !FCmp->isTrueWhenEqual();
  } else if (FCmp->getPredicate() == FCmpInst::FCMP_ORD) {
    // !isnan -> Likely
    isProb = true;
  } else if (FCmp->getPredicate() == FCmpInst::FCMP_UNO) {
    // isnan -> Unlikely
    isProb = false;
  } else {
    return false;
  }

  BasicBlock *Taken = BI->getSuccessor(0);
  BasicBlock *NonTaken = BI->getSuccessor(1);

  if (!isProb)
    std::swap(Taken, NonTaken);

  setEdgeWeight(BB, Taken, FPH_TAKEN_WEIGHT);
  setEdgeWeight(BB, NonTaken, FPH_NONTAKEN_WEIGHT);

  return true;
}

void BranchProbabilityInfo::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<LoopInfo>();
  AU.setPreservesAll();
}

bool BranchProbabilityInfo::runOnFunction(Function &F) {
  LastF = &F; // Store the last function we ran on for printing.
  LI = &getAnalysis<LoopInfo>();

  for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I) {
    if (calcMetadataWeights(I))
      continue;
    if (calcLoopBranchHeuristics(I))
      continue;
    if (calcReturnHeuristics(I))
      continue;
    if (calcPointerHeuristics(I))
      continue;
    if (calcZeroHeuristics(I))
      continue;
    calcFloatingPointHeuristics(I);
  }
  return false;
}

void BranchProbabilityInfo::print(raw_ostream &OS, const Module *) const {
  OS << "---- Branch Probabilities ----\n";
  // We print the probabilities from the last function the analysis ran over,
  // or the function it is currently running over.
  assert(LastF && "Cannot print prior to running over a function");
  for (Function::const_iterator BI = LastF->begin(), BE = LastF->end();
       BI != BE; ++BI) {
    for (succ_const_iterator SI = succ_begin(BI), SE = succ_end(BI);
         SI != SE; ++SI) {
      printEdgeProbability(OS << "  ", BI, *SI);
    }
  }
}

uint32_t BranchProbabilityInfo::getSumForBlock(const BasicBlock *BB) const {
  uint32_t Sum = 0;

  for (succ_const_iterator I = succ_begin(BB), E = succ_end(BB); I != E; ++I) {
    const BasicBlock *Succ = *I;
    uint32_t Weight = getEdgeWeight(BB, Succ);
    uint32_t PrevSum = Sum;

    Sum += Weight;
    assert(Sum > PrevSum); (void) PrevSum;
  }

  return Sum;
}

bool BranchProbabilityInfo::
isEdgeHot(const BasicBlock *Src, const BasicBlock *Dst) const {
  // Hot probability is at least 4/5 = 80%
  // FIXME: Compare against a static "hot" BranchProbability.
  return getEdgeProbability(Src, Dst) > BranchProbability(4, 5);
}

BasicBlock *BranchProbabilityInfo::getHotSucc(BasicBlock *BB) const {
  uint32_t Sum = 0;
  uint32_t MaxWeight = 0;
  BasicBlock *MaxSucc = 0;

  for (succ_iterator I = succ_begin(BB), E = succ_end(BB); I != E; ++I) {
    BasicBlock *Succ = *I;
    uint32_t Weight = getEdgeWeight(BB, Succ);
    uint32_t PrevSum = Sum;

    Sum += Weight;
    assert(Sum > PrevSum); (void) PrevSum;

    if (Weight > MaxWeight) {
      MaxWeight = Weight;
      MaxSucc = Succ;
    }
  }

  // Hot probability is at least 4/5 = 80%
  if (BranchProbability(MaxWeight, Sum) > BranchProbability(4, 5))
    return MaxSucc;

  return 0;
}

// Return edge's weight. If can't find it, return DEFAULT_WEIGHT value.
uint32_t BranchProbabilityInfo::
getEdgeWeight(const BasicBlock *Src, const BasicBlock *Dst) const {
  Edge E(Src, Dst);
  DenseMap<Edge, uint32_t>::const_iterator I = Weights.find(E);

  if (I != Weights.end())
    return I->second;

  return DEFAULT_WEIGHT;
}

void BranchProbabilityInfo::
setEdgeWeight(const BasicBlock *Src, const BasicBlock *Dst, uint32_t Weight) {
  Weights[std::make_pair(Src, Dst)] = Weight;
  DEBUG(dbgs() << "set edge " << Src->getNameStr() << " -> "
               << Dst->getNameStr() << " weight to " << Weight
               << (isEdgeHot(Src, Dst) ? " [is HOT now]\n" : "\n"));
}


BranchProbability BranchProbabilityInfo::
getEdgeProbability(const BasicBlock *Src, const BasicBlock *Dst) const {

  uint32_t N = getEdgeWeight(Src, Dst);
  uint32_t D = getSumForBlock(Src);

  return BranchProbability(N, D);
}

raw_ostream &
BranchProbabilityInfo::printEdgeProbability(raw_ostream &OS,
                                            const BasicBlock *Src,
                                            const BasicBlock *Dst) const {

  const BranchProbability Prob = getEdgeProbability(Src, Dst);
  OS << "edge " << Src->getNameStr() << " -> " << Dst->getNameStr()
     << " probability is " << Prob
     << (isEdgeHot(Src, Dst) ? " [HOT edge]\n" : "\n");

  return OS;
}
