//===- LoopVectorize.cpp - A Loop Vectorizer ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This is a simple loop vectorizer. We currently only support single block
// loops. We have a very simple and restrictive legality check: we need to read
// and write from disjoint memory locations. We still don't have a cost model.
// We do support integer reductions.
//
// This pass has three parts:
// 1. The main loop pass that drives the different parts.
// 2. LoopVectorizationLegality - A helper class that checks for the legality
//    of the vectorization.
// 3. SingleBlockLoopVectorizer - A helper class that performs the actual
//    widening of instructions.
//
//===----------------------------------------------------------------------===//
#define LV_NAME "loop-vectorize"
#define DEBUG_TYPE LV_NAME
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Instructions.h"
#include "llvm/LLVMContext.h"
#include "llvm/Pass.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Value.h"
#include "llvm/Function.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Module.h"
#include "llvm/Type.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AliasSetTracker.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/ScalarEvolutionExpander.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/DataLayout.h"
#include "llvm/Transforms/Utils/Local.h"
#include <algorithm>
using namespace llvm;

static cl::opt<unsigned>
DefaultVectorizationFactor("default-loop-vectorize-width",
                          cl::init(4), cl::Hidden,
                          cl::desc("Set the default loop vectorization width"));
namespace {

// Forward declaration.
class LoopVectorizationLegality;

/// Vectorize a simple loop. This class performs the widening of simple single
/// basic block loops into vectors. It does not perform any
/// vectorization-legality checks, and just does it.  It widens the vectors
/// to a given vectorization factor (VF).
class SingleBlockLoopVectorizer {
public:
  /// Ctor.
  SingleBlockLoopVectorizer(Loop *OrigLoop, ScalarEvolution *Se, LoopInfo *Li,
                            LPPassManager *Lpm, unsigned VecWidth):
  Orig(OrigLoop), SE(Se), LI(Li), LPM(Lpm), VF(VecWidth),
  Builder(Se->getContext()), Induction(0), OldInduction(0) { }

  // Perform the actual loop widening (vectorization).
  void vectorize(LoopVectorizationLegality *Legal) {
    ///Create a new empty loop. Unlink the old loop and connect the new one.
    createEmptyLoop(Legal);
    /// Widen each instruction in the old loop to a new one in the new loop.
    /// Use the Legality module to find the induction and reduction variables.
   vectorizeLoop(Legal);
    // register the new loop.
    cleanup();
 }

private:
  /// Create an empty loop, based on the loop ranges of the old loop.
  void createEmptyLoop(LoopVectorizationLegality *Legal);
  /// Copy and widen the instructions from the old loop.
  void vectorizeLoop(LoopVectorizationLegality *Legal);
  /// Insert the new loop to the loop hierarchy and pass manager.
  void cleanup();

  /// This instruction is un-vectorizable. Implement it as a sequence
  /// of scalars.
  void scalarizeInstruction(Instruction *Instr);

  /// Create a broadcast instruction. This method generates a broadcast
  /// instruction (shuffle) for loop invariant values and for the induction
  /// value. If this is the induction variable then we extend it to N, N+1, ...
  /// this is needed because each iteration in the loop corresponds to a SIMD
  /// element.
  Value *getBroadcastInstrs(Value *V);

  /// This is a helper function used by getBroadcastInstrs. It adds 0, 1, 2 ..
  /// for each element in the vector. Starting from zero.
  Value *getConsecutiveVector(Value* Val);

  /// When we go over instructions in the basic block we rely on previous
  /// values within the current basic block or on loop invariant values.
  /// When we widen (vectorize) values we place them in the map. If the values
  /// are not within the map, they have to be loop invariant, so we simply
  /// broadcast them into a vector.
  Value *getVectorValue(Value *V);

  /// Get a uniform vector of constant integers. We use this to get
  /// vectors of ones and zeros for the reduction code.
  Constant* getUniformVector(unsigned Val, Type* ScalarTy);

  typedef DenseMap<Value*, Value*> ValueMap;

  /// The original loop.
  Loop *Orig;
  // Scev analysis to use.
  ScalarEvolution *SE;
  // Loop Info.
  LoopInfo *LI;
  // Loop Pass Manager;
  LPPassManager *LPM;
  // The vectorization factor to use.
  unsigned VF;

  // The builder that we use
  IRBuilder<> Builder;

  // --- Vectorization state ---

  /// Middle Block between the vector and the scalar.
  BasicBlock *LoopMiddleBlock;
  ///The ExitBlock of the scalar loop.
  BasicBlock *LoopExitBlock;
  ///The vector loop body.
  BasicBlock *LoopVectorBody;
  ///The scalar loop body.
  BasicBlock *LoopScalarBody;
  ///The first bypass block.
  BasicBlock *LoopBypassBlock;

  /// The new Induction variable which was added to the new block.
  PHINode *Induction;
  /// The induction variable of the old basic block.
  PHINode *OldInduction;
  // Maps scalars to widened vectors.
  ValueMap WidenMap;
};

/// Perform the vectorization legality check. This class does not look at the
/// profitability of vectorization, only the legality. At the moment the checks
/// are very simple and focus on single basic block loops with a constant
/// iteration count and no reductions.
class LoopVectorizationLegality {
public:
  LoopVectorizationLegality(Loop *Lp, ScalarEvolution *Se, DataLayout *Dl):
  TheLoop(Lp), SE(Se), DL(Dl), Induction(0) { }

  /// This represents the kinds of reductions that we support.
  enum ReductionKind {
    IntegerAdd, /// Sum of numbers.
    IntegerMult, /// Product of numbers.
    NoReduction /// Not a reduction.
  };

  // Holds a pairing of reduction instruction and the reduction kind.
  typedef std::pair<Instruction*, ReductionKind> ReductionPair;

  /// ReductionList contains the reduction variables
  /// as well as a single EXIT (from the block) value and the kind of
  /// reduction variable..
  /// Notice that the EXIT instruction can also be the PHI itself.
  typedef DenseMap<PHINode*, ReductionPair> ReductionList;

  /// Returns the maximum vectorization factor that we *can* use to vectorize
  /// this loop. This does not mean that it is profitable to vectorize this
  /// loop, only that it is legal to do so. This may be a large number. We
  /// can vectorize to any SIMD width below this number.
  unsigned getLoopMaxVF();

  /// Returns the Induction variable.
  PHINode *getInduction() {return Induction;}

  /// Returns the reduction variables found in the loop.
  ReductionList *getReductionVars() { return &Reductions; }

  /// Check that the GEP operands are all uniform except for the last index
  /// which has to be the induction variable.
  bool isConsecutiveGep(Value *Ptr);

private:
  /// Check if a single basic block loop is vectorizable.
  /// At this point we know that this is a loop with a constant trip count
  /// and we only need to check individual instructions.
  bool canVectorizeBlock(BasicBlock &BB);

  /// When we vectorize loops we may change the order in which
  /// we read and write from memory. This method checks if it is
  /// legal to vectorize the code, considering only memory constrains.
  /// Returns true if BB is vectorizable
  bool canVectorizeMemory(BasicBlock &BB);

  // Check if a pointer value is known to be disjoint.
  // Example: Alloca, Global, NoAlias.
  bool isIdentifiedSafeObject(Value* Val);

  /// Returns True, if 'Phi' is the kind of reduction variable for type
  /// 'Kind'. If this is a reduction variable, it adds it to ReductionList.
  bool AddReductionVar(PHINode *Phi, ReductionKind Kind);
  /// Checks if a constant matches the reduction kind.
  /// Sums starts with zero. Products start at one.
  bool isReductionConstant(Value *V, ReductionKind Kind);
  /// Returns true if the instruction I can be a reduction variable of type
  /// 'Kind'.
  bool isReductionInstr(Instruction *I, ReductionKind Kind);
  /// Returns True, if 'Phi' is an induction variable.
  bool isInductionVariable(PHINode *Phi);

  /// The loop that we evaluate.
  Loop *TheLoop;
  /// Scev analysis.
  ScalarEvolution *SE;
  /// DataLayout analysis.
  DataLayout *DL;

  //  ---  vectorization state --- //

  /// Holds the induction variable.
  PHINode *Induction;
  /// Holds the reduction variables.
  ReductionList Reductions;
  /// Allowed outside users. This holds the reduction
  /// vars which can be accessed from outside the loop.
  SmallPtrSet<Value*, 4> AllowedExit;
};

struct LoopVectorize : public LoopPass {
  static char ID; // Pass identification, replacement for typeid

  LoopVectorize() : LoopPass(ID) {
    initializeLoopVectorizePass(*PassRegistry::getPassRegistry());
  }

  ScalarEvolution *SE;
  DataLayout *DL;
  LoopInfo *LI;

  virtual bool runOnLoop(Loop *L, LPPassManager &LPM) {

    // Only vectorize innermost loops.
    if (!L->empty())
      return false;

    SE = &getAnalysis<ScalarEvolution>();
    DL = getAnalysisIfAvailable<DataLayout>();
    LI = &getAnalysis<LoopInfo>();

    DEBUG(dbgs() << "LV: Checking a loop in \"" <<
          L->getHeader()->getParent()->getName() << "\"\n");

    // Check if it is legal to vectorize the loop.
    LoopVectorizationLegality LVL(L, SE, DL);
    unsigned MaxVF = LVL.getLoopMaxVF();

    // Check that we can vectorize using the chosen vectorization width.
    if (MaxVF < DefaultVectorizationFactor) {
      DEBUG(dbgs() << "LV: non-vectorizable MaxVF ("<< MaxVF << ").\n");
      return false;
    }

    DEBUG(dbgs() << "LV: Found a vectorizable loop ("<< MaxVF << ").\n");

    // If we decided that is is *legal* to vectorizer the loop. Do it.
    SingleBlockLoopVectorizer LB(L, SE, LI, &LPM, DefaultVectorizationFactor);
    LB.vectorize(&LVL);

    DEBUG(verifyFunction(*L->getHeader()->getParent()));
    return true;
  }

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
    LoopPass::getAnalysisUsage(AU);
    AU.addRequiredID(LoopSimplifyID);
    AU.addRequiredID(LCSSAID);
    AU.addRequired<LoopInfo>();
    AU.addRequired<ScalarEvolution>();
  }

};

Value *SingleBlockLoopVectorizer::getBroadcastInstrs(Value *V) {
  // Instructions that access the old induction variable
  // actually want to get the new one.
  if (V == OldInduction)
    V = Induction;
  // Create the types.
  LLVMContext &C = V->getContext();
  Type *VTy = VectorType::get(V->getType(), VF);
  Type *I32 = IntegerType::getInt32Ty(C);
  Constant *Zero = ConstantInt::get(I32, 0);
  Value *Zeros = ConstantAggregateZero::get(VectorType::get(I32, VF));
  Value *UndefVal = UndefValue::get(VTy);
  // Insert the value into a new vector.
  Value *SingleElem = Builder.CreateInsertElement(UndefVal, V, Zero);
  // Broadcast the scalar into all locations in the vector.
  Value *Shuf = Builder.CreateShuffleVector(SingleElem, UndefVal, Zeros,
                                             "broadcast");
  // We are accessing the induction variable. Make sure to promote the
  // index for each consecutive SIMD lane. This adds 0,1,2 ... to all lanes.
  if (V == Induction)
    return getConsecutiveVector(Shuf);
  return Shuf;
}

Value *SingleBlockLoopVectorizer::getConsecutiveVector(Value* Val) {
  assert(Val->getType()->isVectorTy() && "Must be a vector");
  assert(Val->getType()->getScalarType()->isIntegerTy() &&
         "Elem must be an integer");
  // Create the types.
  Type *ITy = Val->getType()->getScalarType();
  VectorType *Ty = cast<VectorType>(Val->getType());
  unsigned VLen = Ty->getNumElements();
  SmallVector<Constant*, 8> Indices;

  // Create a vector of consecutive numbers from zero to VF.
  for (unsigned i = 0; i < VLen; ++i)
    Indices.push_back(ConstantInt::get(ITy, i));

  // Add the consecutive indices to the vector value.
  Constant *Cv = ConstantVector::get(Indices);
  assert(Cv->getType() == Val->getType() && "Invalid consecutive vec");
  return Builder.CreateAdd(Val, Cv, "induction");
}

bool LoopVectorizationLegality::isConsecutiveGep(Value *Ptr) {
  GetElementPtrInst *Gep = dyn_cast<GetElementPtrInst>(Ptr);
  if (!Gep)
    return false;

  unsigned NumOperands = Gep->getNumOperands();
  Value *LastIndex = Gep->getOperand(NumOperands - 1);

  // Check that all of the gep indices are uniform except for the last.
  for (unsigned i = 0; i < NumOperands - 1; ++i)
    if (!SE->isLoopInvariant(SE->getSCEV(Gep->getOperand(i)), TheLoop))
      return false;

  // We can emit wide load/stores only of the last index is the induction
  // variable.
  const SCEV *Last = SE->getSCEV(LastIndex);
  if (const SCEVAddRecExpr *AR = dyn_cast<SCEVAddRecExpr>(Last)) {
    const SCEV *Step = AR->getStepRecurrence(*SE);

    // The memory is consecutive because the last index is consecutive
    // and all other indices are loop invariant.
    if (Step->isOne())
      return true;
  }

  return false;
}

Value *SingleBlockLoopVectorizer::getVectorValue(Value *V) {
  assert(!V->getType()->isVectorTy() && "Can't widen a vector");
  // If we saved a vectorized copy of V, use it.
  ValueMap::iterator it = WidenMap.find(V);
  if (it != WidenMap.end())
     return it->second;

  // Broadcast V and save the value for future uses.
  Value *B = getBroadcastInstrs(V);
  WidenMap[V] = B;
  return B;
}

Constant*
SingleBlockLoopVectorizer::getUniformVector(unsigned Val, Type* ScalarTy) {
  SmallVector<Constant*, 8> Indices;
  // Create a vector of consecutive numbers from zero to VF.
  for (unsigned i = 0; i < VF; ++i)
    Indices.push_back(ConstantInt::get(ScalarTy, Val));

  // Add the consecutive indices to the vector value.
  return ConstantVector::get(Indices);
}

void SingleBlockLoopVectorizer::scalarizeInstruction(Instruction *Instr) {
  assert(!Instr->getType()->isAggregateType() && "Can't handle vectors");
  // Holds vector parameters or scalars, in case of uniform vals.
  SmallVector<Value*, 8> Params;

  // Find all of the vectorized parameters.
  for (unsigned op = 0, e = Instr->getNumOperands(); op != e; ++op) {
    Value *SrcOp = Instr->getOperand(op);

    // If we are accessing the old induction variable, use the new one.
    if (SrcOp == OldInduction) {
      Params.push_back(getBroadcastInstrs(Induction));
      continue;
    }

    // Try using previously calculated values.
    Instruction *SrcInst = dyn_cast<Instruction>(SrcOp);

    // If the src is an instruction that appeared earlier in the basic block
    // then it should already be vectorized.
    if (SrcInst && SrcInst->getParent() == Instr->getParent()) {
      assert(WidenMap.count(SrcInst) && "Source operand is unavailable");
      // The parameter is a vector value from earlier.
      Params.push_back(WidenMap[SrcInst]);
    } else {
      // The parameter is a scalar from outside the loop. Maybe even a constant.
      Params.push_back(SrcOp);
    }
  }

  assert(Params.size() == Instr->getNumOperands() &&
         "Invalid number of operands");

  // Does this instruction return a value ?
  bool IsVoidRetTy = Instr->getType()->isVoidTy();
  Value *VecResults = 0;

  // If we have a return value, create an empty vector. We place the scalarized
  // instructions in this vector.
  if (!IsVoidRetTy)
    VecResults = UndefValue::get(VectorType::get(Instr->getType(), VF));

  // For each scalar that we create.
  for (unsigned i = 0; i < VF; ++i) {
    Instruction *Cloned = Instr->clone();
    if (!IsVoidRetTy)
      Cloned->setName(Instr->getName() + ".cloned");
    // Replace the operands of the cloned instrucions with extracted scalars.
    for (unsigned op = 0, e = Instr->getNumOperands(); op != e; ++op) {
      Value *Op = Params[op];
      // Param is a vector. Need to extract the right lane.
      if (Op->getType()->isVectorTy())
        Op = Builder.CreateExtractElement(Op, Builder.getInt32(i));
      Cloned->setOperand(op, Op);
    }

    // Place the cloned scalar in the new loop.
    Builder.Insert(Cloned);

    // If the original scalar returns a value we need to place it in a vector
    // so that future users will be able to use it.
    if (!IsVoidRetTy)
      VecResults = Builder.CreateInsertElement(VecResults, Cloned,
                                               Builder.getInt32(i));
  }

  if (!IsVoidRetTy)
    WidenMap[Instr] = VecResults;
}

void SingleBlockLoopVectorizer::createEmptyLoop(LoopVectorizationLegality *Legal) {
  /*
   In this function we generate a new loop. The new loop will contain
   the vectorized instructions while the old loop will continue to run the
   scalar remainder.

   [  ] <-- vector loop bypass.
  /  |
 /   v
|   [ ]     <-- vector pre header.
|    |
|    v
|   [  ] \
|   [  ]_|   <-- vector loop.
|    |
 \   v
   >[ ]   <--- middle-block.
  /  |
 /   v
|   [ ]     <--- new preheader.
|    |
|    v
|   [ ] \
|   [ ]_|   <-- old scalar loop to handle remainder.
 \   |
  \  v
   >[ ]     <-- exit block.
   ...
   */

  // This is the original scalar-loop preheader.
  BasicBlock *BypassBlock = Orig->getLoopPreheader();
  BasicBlock *ExitBlock = Orig->getExitBlock();
  assert(ExitBlock && "Must have an exit block");

  assert(Orig->getNumBlocks() == 1 && "Invalid loop");
  assert(BypassBlock && "Invalid loop structure");

  BasicBlock *VectorPH =
      BypassBlock->splitBasicBlock(BypassBlock->getTerminator(), "vector.ph");
  BasicBlock *VecBody = VectorPH->splitBasicBlock(VectorPH->getTerminator(),
                                                 "vector.body");

  BasicBlock *MiddleBlock = VecBody->splitBasicBlock(VecBody->getTerminator(),
                                                  "middle.block");
  BasicBlock *ScalarPH =
    MiddleBlock->splitBasicBlock(MiddleBlock->getTerminator(),
                                 "scalar.preheader");
  // Find the induction variable.
  BasicBlock *OldBasicBlock = Orig->getHeader();
  OldInduction = Legal->getInduction();
  assert(OldInduction && "We must have a single phi node.");
  Type *IdxTy = OldInduction->getType();

  // Use this IR builder to create the loop instructions (Phi, Br, Cmp)
  // inside the loop.
  Builder.SetInsertPoint(VecBody->getFirstInsertionPt());

  // Generate the induction variable.
  Induction = Builder.CreatePHI(IdxTy, 2, "index");
  Constant *Zero = ConstantInt::get(IdxTy, 0);
  Constant *Step = ConstantInt::get(IdxTy, VF);

  // Find the loop boundaries.
  const SCEV *ExitCount = SE->getExitCount(Orig, Orig->getHeader());
  assert(ExitCount != SE->getCouldNotCompute() && "Invalid loop count");

  // Get the total trip count from the count by adding 1.
  ExitCount = SE->getAddExpr(ExitCount,
                             SE->getConstant(ExitCount->getType(), 1));

  // Expand the trip count and place the new instructions in the preheader.
  // Notice that the pre-header does not change, only the loop body.
  SCEVExpander Exp(*SE, "induction");
  Instruction *Loc = BypassBlock->getTerminator();

  // We may need to extend the index in case there is a type mismatch.
  // We know that the count starts at zero and does not overflow.
  // We are using Zext because it should be less expensive.
  if (ExitCount->getType() != Induction->getType())
    ExitCount = SE->getZeroExtendExpr(ExitCount, IdxTy);

  // Count holds the overall loop count (N).
  Value *Count = Exp.expandCodeFor(ExitCount, Induction->getType(), Loc);
  // Now we need to generate the expression for N - (N % VF), which is
  // the part that the vectorized body will execute.
  Constant *CIVF = ConstantInt::get(IdxTy, VF);
  Value *R = BinaryOperator::CreateURem(Count, CIVF, "n.mod.vf", Loc);
  Value *CountRoundDown = BinaryOperator::CreateSub(Count, R, "n.vec", Loc);

  // Now, compare the new count to zero. If it is zero, jump to the scalar part.
  Value *Cmp = CmpInst::Create(Instruction::ICmp, CmpInst::ICMP_EQ,
                               CountRoundDown, ConstantInt::getNullValue(IdxTy),
                               "cmp.zero", Loc);
  BranchInst::Create(MiddleBlock, VectorPH, Cmp, Loc);
  // Remove the old terminator.
  Loc->eraseFromParent();

  // Add a check in the middle block to see if we have completed
  // all of the iterations in the first vector loop.
  // If (N - N%VF) == N, then we *don't* need to run the remainder.
  Value *CmpN = CmpInst::Create(Instruction::ICmp, CmpInst::ICMP_EQ, Count,
                                CountRoundDown, "cmp.n",
                                MiddleBlock->getTerminator());

  BranchInst::Create(ExitBlock, ScalarPH, CmpN, MiddleBlock->getTerminator());
  // Remove the old terminator.
  MiddleBlock->getTerminator()->eraseFromParent();

  // Create i+1 and fill the PHINode.
  Value *NextIdx = Builder.CreateAdd(Induction, Step, "index.next");
  Induction->addIncoming(Zero, VectorPH);
  Induction->addIncoming(NextIdx, VecBody);
  // Create the compare.
  Value *ICmp = Builder.CreateICmpEQ(NextIdx, CountRoundDown);
  Builder.CreateCondBr(ICmp, MiddleBlock, VecBody);

  // Now we have two terminators. Remove the old one from the block.
  VecBody->getTerminator()->eraseFromParent();

  // Fix the scalar body iteration count.
  unsigned BlockIdx = OldInduction->getBasicBlockIndex(ScalarPH);
  OldInduction->setIncomingValue(BlockIdx, CountRoundDown);

  // Get ready to start creating new instructions into the vectorized body.
  Builder.SetInsertPoint(VecBody->getFirstInsertionPt());

  // Register the new loop.
  Loop* Lp = new Loop();
  LPM->insertLoop(Lp, Orig->getParentLoop());

  Lp->addBasicBlockToLoop(VecBody, LI->getBase());

  Loop *ParentLoop = Orig->getParentLoop();
  if (ParentLoop) {
    ParentLoop->addBasicBlockToLoop(ScalarPH, LI->getBase());
    ParentLoop->addBasicBlockToLoop(VectorPH, LI->getBase());
    ParentLoop->addBasicBlockToLoop(MiddleBlock, LI->getBase());
  }

  // Save the state.
  LoopMiddleBlock = MiddleBlock;
  LoopExitBlock = ExitBlock;
  LoopVectorBody = VecBody;
  LoopScalarBody = OldBasicBlock;
  LoopBypassBlock = BypassBlock;
}

void
SingleBlockLoopVectorizer::vectorizeLoop(LoopVectorizationLegality *Legal) {
  typedef SmallVector<PHINode*, 4> PhiVector;
  BasicBlock &BB = *Orig->getHeader();

  // In order to support reduction variables we need to be able to vectorize
  // Phi nodes. Phi nodes have cycles, so we need to vectorize them in two
  // steages. First, we create a new vector PHI node with no incoming edges.
  // We use this value when we vectorize all of the instructions that use the
  // PHI. Next, after all of the instructions in the block are complete we
  // add the new incoming edges to the PHI. At this point all of the
  // instructions in the basic block are vectorized, so we can use them to
  // construct the PHI.
  PhiVector PHIsToFix;

  // For each instruction in the old loop.
  for (BasicBlock::iterator it = BB.begin(), e = BB.end(); it != e; ++it) {
    Instruction *Inst = it;

    switch (Inst->getOpcode()) {
      case Instruction::Br:
        // Nothing to do for PHIs and BR, since we already took care of the
        // loop control flow instructions.
        continue;
      case Instruction::PHI:{
        PHINode* P = cast<PHINode>(Inst);
        // Special handling for the induction var.
        if (OldInduction == Inst)
          continue;
        // This is phase one of vectorizing PHIs.
        // This has to be a reduction variable.
        assert(Legal->getReductionVars()->count(P) && "Not a Reduction");
        Type *VecTy = VectorType::get(Inst->getType(), VF);
        WidenMap[Inst] = Builder.CreatePHI(VecTy, 2, "vec.phi");
        PHIsToFix.push_back(P);
        continue;
      }
      case Instruction::Add:
      case Instruction::FAdd:
      case Instruction::Sub:
      case Instruction::FSub:
      case Instruction::Mul:
      case Instruction::FMul:
      case Instruction::UDiv:
      case Instruction::SDiv:
      case Instruction::FDiv:
      case Instruction::URem:
      case Instruction::SRem:
      case Instruction::FRem:
      case Instruction::Shl:
      case Instruction::LShr:
      case Instruction::AShr:
      case Instruction::And:
      case Instruction::Or:
      case Instruction::Xor: {
        // Just widen binops.
        BinaryOperator *BinOp = dyn_cast<BinaryOperator>(Inst);
        Value *A = getVectorValue(Inst->getOperand(0));
        Value *B = getVectorValue(Inst->getOperand(1));
        // Use this vector value for all users of the original instruction.
        WidenMap[Inst] = Builder.CreateBinOp(BinOp->getOpcode(), A, B);
        break;
      }
      case Instruction::Select: {
        // Widen selects.
        // TODO: If the selector is loop invariant we can issue a select
        // instruction with a scalar condition.
        Value *A = getVectorValue(Inst->getOperand(0));
        Value *B = getVectorValue(Inst->getOperand(1));
        Value *C = getVectorValue(Inst->getOperand(2));
        WidenMap[Inst] = Builder.CreateSelect(A, B, C);
        break;
      }

      case Instruction::ICmp:
      case Instruction::FCmp: {
        // Widen compares. Generate vector compares.
        bool FCmp = (Inst->getOpcode() == Instruction::FCmp);
        CmpInst *Cmp = dyn_cast<CmpInst>(Inst);
        Value *A = getVectorValue(Inst->getOperand(0));
        Value *B = getVectorValue(Inst->getOperand(1));
        if (FCmp)
          WidenMap[Inst] = Builder.CreateFCmp(Cmp->getPredicate(), A, B);
        else
          WidenMap[Inst] = Builder.CreateICmp(Cmp->getPredicate(), A, B);
        break;
      }

      case Instruction::Store: {
        // Attempt to issue a wide store.
        StoreInst *SI = dyn_cast<StoreInst>(Inst);
        Type *StTy = VectorType::get(SI->getValueOperand()->getType(), VF);
        Value *Ptr = SI->getPointerOperand();
        unsigned Alignment = SI->getAlignment();
        GetElementPtrInst *Gep = dyn_cast<GetElementPtrInst>(Ptr);
        // This store does not use GEPs.
        if (!Legal->isConsecutiveGep(Gep)) {
          scalarizeInstruction(Inst);
          break;
        }

        // Create the new GEP with the new induction variable.
        GetElementPtrInst *Gep2 = cast<GetElementPtrInst>(Gep->clone());
        unsigned NumOperands = Gep->getNumOperands();
        Gep2->setOperand(NumOperands - 1, Induction);
        Ptr = Builder.Insert(Gep2);
        Ptr = Builder.CreateBitCast(Ptr, StTy->getPointerTo());
        Value *Val = getVectorValue(SI->getValueOperand());
        Builder.CreateStore(Val, Ptr)->setAlignment(Alignment);
        break;
      }
      case Instruction::Load: {
        // Attempt to issue a wide load.
        LoadInst *LI = dyn_cast<LoadInst>(Inst);
        Type *RetTy = VectorType::get(LI->getType(), VF);
        Value *Ptr = LI->getPointerOperand();
        unsigned Alignment = LI->getAlignment();
        GetElementPtrInst *Gep = dyn_cast<GetElementPtrInst>(Ptr);

        // We don't have a gep. Scalarize the load.
        if (!Legal->isConsecutiveGep(Gep)) {
          scalarizeInstruction(Inst);
          break;
        }

        // Create the new GEP with the new induction variable.
        GetElementPtrInst *Gep2 = cast<GetElementPtrInst>(Gep->clone());
        unsigned NumOperands = Gep->getNumOperands();
        Gep2->setOperand(NumOperands - 1, Induction);
        Ptr = Builder.Insert(Gep2);
        Ptr = Builder.CreateBitCast(Ptr, RetTy->getPointerTo());
        LI = Builder.CreateLoad(Ptr);
        LI->setAlignment(Alignment);
        // Use this vector value for all users of the load.
        WidenMap[Inst] = LI;
        break;
      }
      case Instruction::ZExt:
      case Instruction::SExt:
      case Instruction::FPToUI:
      case Instruction::FPToSI:
      case Instruction::FPExt:
      case Instruction::PtrToInt:
      case Instruction::IntToPtr:
      case Instruction::SIToFP:
      case Instruction::UIToFP:
      case Instruction::Trunc:
      case Instruction::FPTrunc:
      case Instruction::BitCast: {
        /// Vectorize bitcasts.
        CastInst *CI = dyn_cast<CastInst>(Inst);
        Value *A = getVectorValue(Inst->getOperand(0));
        Type *DestTy = VectorType::get(CI->getType()->getScalarType(), VF);
        WidenMap[Inst] = Builder.CreateCast(CI->getOpcode(), A, DestTy);
        break;
      }

      default:
        /// All other instructions are unsupported. Scalarize them.
        scalarizeInstruction(Inst);
        break;
    }// end of switch.
  }// end of for_each instr.

  // At this point every instruction in the original loop is widended to
  // a vector form. We are almost done. Now, we need to fix the PHI nodes
  // that we vectorized. The PHI nodes are currently empty because we did
  // not want to introduce cycles. Notice that the remaining PHI nodes
  // that we need to fix are reduction variables.

  // Create the 'reduced' values for each of the induction vars.
  // The reduced values are the vector values that we scalarize and combine
  // after the loop is finished.
  for (PhiVector::iterator it = PHIsToFix.begin(), e = PHIsToFix.end();
       it != e; ++it) {
    PHINode *RdxPhi = *it;
    PHINode *VecRdxPhi = dyn_cast<PHINode>(WidenMap[RdxPhi]);
    assert(RdxPhi && "Unable to recover vectorized PHI");

    // Find the reduction variable.
    assert(Legal->getReductionVars()->count(RdxPhi) &&
           "Unable to find the reduction variable");
    LoopVectorizationLegality::ReductionPair ReductionVar =
      (*Legal->getReductionVars())[RdxPhi];

    // This is the vector-clone of the value that leaves the loop.
    Value *VectorExit = getVectorValue(ReductionVar.first);
    Type *VecTy = VectorExit->getType();

    // This is the kind of reduction.
    LoopVectorizationLegality::ReductionKind RdxKind = ReductionVar.second;
    // Find the reduction identity variable.
    // Zero for addition. One for Multiplication.
    unsigned IdentitySclr =
      (RdxKind == LoopVectorizationLegality::IntegerAdd ? 0 : 1);
    Constant *Identity = getUniformVector(IdentitySclr, VecTy->getScalarType());

    // Fix the vector-loop phi.
    // We created the induction variable so we know that the
    // preheader is the first entry.
    BasicBlock *VecPreheader = Induction->getIncomingBlock(0);
    VecRdxPhi->addIncoming(Identity, VecPreheader);
    unsigned SelfEdgeIdx = (RdxPhi)->getBasicBlockIndex(LoopScalarBody);
    Value *Val = getVectorValue(RdxPhi->getIncomingValue(SelfEdgeIdx));
    VecRdxPhi->addIncoming(Val, LoopVectorBody);

    // Before each round, move the insertion point right between
    // the PHIs and the values we are going to write.
    // This allows us to write both PHINodes and the extractelement
    // instructions.
    Builder.SetInsertPoint(LoopMiddleBlock->getFirstInsertionPt());

    // This PHINode contains the vectorized reduction variable, or
    // the identity vector, if we bypass the vector loop.
    PHINode *NewPhi = Builder.CreatePHI(VecTy, 2, "rdx.vec.exit.phi");
    NewPhi->addIncoming(Identity, LoopBypassBlock);
    NewPhi->addIncoming(getVectorValue(ReductionVar.first), LoopVectorBody);

    // Extract the first scalar.
    Value *Scalar0 =
      Builder.CreateExtractElement(NewPhi, Builder.getInt32(0));
    // Extract and sum the remaining vector elements.
    for (unsigned i=1; i < VF; ++i) {
      Value *Scalar1 =
        Builder.CreateExtractElement(NewPhi, Builder.getInt32(i));
      if (RdxKind == LoopVectorizationLegality::IntegerAdd) {
        Scalar0 = Builder.CreateAdd(Scalar0, Scalar1);
      } else {
        Scalar0 = Builder.CreateMul(Scalar0, Scalar1);
      }
    }

    // Now, we need to fix the users of the reduction variable
    // inside and outside of the scalar remainder loop.
    // We know that the loop is in LCSSA form. We need to update the
    // PHI nodes in the exit blocks.
    for (BasicBlock::iterator LEI = LoopExitBlock->begin(),
         LEE = LoopExitBlock->end(); LEI != LEE; ++LEI) {
      PHINode *LCSSAPhi = dyn_cast<PHINode>(LEI);
      if (!LCSSAPhi) continue;

      // All PHINodes need to have a single entry edge, or two if we already fixed them.
      assert(LCSSAPhi->getNumIncomingValues() < 3 && "Invalid LCSSA PHI");

      // We found our reduction value exit-PHI. Update it with the incoming bypass edge.
      if (LCSSAPhi->getIncomingValue(0) == ReductionVar.first) {
        // Add an edge coming from the bypass.
        LCSSAPhi->addIncoming(Scalar0, LoopMiddleBlock);
        break;
      }
    }// end of the LCSSA phi scan.

    // Fix the scalar loop reduction variable with the incoming reduction sum
    // from the vector body and from the backedge value.
    int IncomingEdgeBlockIdx = (RdxPhi)->getBasicBlockIndex(LoopScalarBody);
    int SelfEdgeBlockIdx = (IncomingEdgeBlockIdx ? 0 : 1); // The other block.
    (RdxPhi)->setIncomingValue(SelfEdgeBlockIdx, Scalar0);
    (RdxPhi)->setIncomingValue(IncomingEdgeBlockIdx, ReductionVar.first);
  }// end of for each redux variable.
}

void SingleBlockLoopVectorizer::cleanup() {
  // The original basic block.
  SE->forgetLoop(Orig);
}

unsigned LoopVectorizationLegality::getLoopMaxVF() {
  if (!TheLoop->getLoopPreheader()) {
    assert(false && "No preheader!!");
    DEBUG(dbgs() << "LV: Loop not normalized." << "\n");
    return  1;
  }

  // We can only vectorize single basic block loops.
  unsigned NumBlocks = TheLoop->getNumBlocks();
  if (NumBlocks != 1) {
    DEBUG(dbgs() << "LV: Too many blocks:" << NumBlocks << "\n");
    return 1;
  }

  // We need to have a loop header.
  BasicBlock *BB = TheLoop->getHeader();
  DEBUG(dbgs() << "LV: Found a loop: " << BB->getName() << "\n");

  // Go over each instruction and look at memory deps.
  if (!canVectorizeBlock(*BB)) {
    DEBUG(dbgs() << "LV: Can't vectorize this loop header\n");
    return 1;
  }

  // ScalarEvolution needs to be able to find the exit count.
  const SCEV *ExitCount = SE->getExitCount(TheLoop, BB);
  if (ExitCount == SE->getCouldNotCompute()) {
    DEBUG(dbgs() << "LV: SCEV could not compute the loop exit count.\n");
    return 1;
  }

  DEBUG(dbgs() << "LV: We can vectorize this loop!\n");

  // Okay! We can vectorize. At this point we don't have any other mem analysis
  // which may limit our maximum vectorization factor, so just return the
  // maximum SIMD size.
  return DefaultVectorizationFactor;
}

bool LoopVectorizationLegality::canVectorizeBlock(BasicBlock &BB) {
  // Scan the instructions in the block and look for hazards.
  for (BasicBlock::iterator it = BB.begin(), e = BB.end(); it != e; ++it) {
    Instruction *I = it;

    PHINode *Phi = dyn_cast<PHINode>(I);
    if (Phi) {
      // This should not happen because the loop should be normalized.
      if (Phi->getNumIncomingValues() != 2) {
        DEBUG(dbgs() << "LV: Found an invalid PHI.\n");
        return false;
      }
      // We only look at integer phi nodes.
      if (!Phi->getType()->isIntegerTy()) {
        DEBUG(dbgs() << "LV: Found an non-int PHI.\n");
        return false;
      }

      if (isInductionVariable(Phi)) {
        if (Induction) {
          DEBUG(dbgs() << "LV: Found too many inductions."<< *Phi <<"\n");
          return false;
        }
        DEBUG(dbgs() << "LV: Found the induction PHI."<< *Phi <<"\n");
        Induction = Phi;
        continue;
      }
      if (AddReductionVar(Phi, IntegerAdd)) {
        DEBUG(dbgs() << "LV: Found an ADD reduction PHI."<< *Phi <<"\n");
        continue;
      }
      if (AddReductionVar(Phi, IntegerMult)) {
        DEBUG(dbgs() << "LV: Found an Mult reduction PHI."<< *Phi <<"\n");
        continue;
      }
    }// end of PHI handling

    // We still don't handle functions.
    CallInst *CI = dyn_cast<CallInst>(I);
    if (CI) {
      DEBUG(dbgs() << "LV: Found a call site:"<<
            CI->getCalledFunction()->getName() << "\n");
      return false;
    }

    // We do not re-vectorize vectors.
    if (!VectorType::isValidElementType(I->getType()) &&
        !I->getType()->isVoidTy()) {
      DEBUG(dbgs() << "LV: Found unvectorizable type." << "\n");
      return false;
    }

    // Reduction instructions are allowed to have exit users.
    // All other instructions must not have external users.
    if (!AllowedExit.count(I))
      //Check that all of the users of the loop are inside the BB.
      for (Value::use_iterator it = I->use_begin(), e = I->use_end();
           it != e; ++it) {
        Instruction *U = cast<Instruction>(*it);
        // This user may be a reduction exit value.
        BasicBlock *Parent = U->getParent();
        if (Parent != &BB) {
          DEBUG(dbgs() << "LV: Found an outside user for : "<< *U << "\n");
          return false;
        }
    }
  } // next instr.

  if (!Induction) {
      DEBUG(dbgs() << "LV: Did not find an induction var.\n");
      return false;
  }

  // If the memory dependencies do not prevent us from
  // vectorizing, then vectorize.
  return canVectorizeMemory(BB);
}

bool LoopVectorizationLegality::canVectorizeMemory(BasicBlock &BB) {
  typedef SmallVector<Value*, 16> ValueVector;
  typedef SmallPtrSet<Value*, 16> ValueSet;
  // Holds the Load and Store *instructions*.
  ValueVector Loads;
  ValueVector Stores;

  // Scan the BB and collect legal loads and stores.
  for (BasicBlock::iterator it = BB.begin(), e = BB.end(); it != e; ++it) {
    Instruction *I = it;

    // If this is a load, save it. If this instruction can read from memory
    // but is not a load, then we quit. Notice that we don't handle function
    // calls that read or write.
    if (I->mayReadFromMemory()) {
      LoadInst *Ld = dyn_cast<LoadInst>(I);
      if (!Ld) return false;
      if (!Ld->isSimple()) {
        DEBUG(dbgs() << "LV: Found a non-simple load.\n");
        return false;
      }
      Loads.push_back(Ld);
      continue;
    }

    // Save store instructions. Abort if other instructions write to memory.
    if (I->mayWriteToMemory()) {
      StoreInst *St = dyn_cast<StoreInst>(I);
      if (!St) return false;
      if (!St->isSimple()) {
        DEBUG(dbgs() << "LV: Found a non-simple store.\n");
        return false;
      }
      Stores.push_back(St);
    }
  } // next instr.

  // Now we have two lists that hold the loads and the stores.
  // Next, we find the pointers that they use.

  // Check if we see any stores. If there are no stores, then we don't
  // care if the pointers are *restrict*.
  if (!Stores.size()) {
        DEBUG(dbgs() << "LV: Found a read-only loop!\n");
        return true;
  }

  // Holds the read and read-write *pointers* that we find.
  ValueVector Reads;
  ValueVector ReadWrites;

  // Holds the analyzed pointers. We don't want to call GetUnderlyingObjects
  // multiple times on the same object. If the ptr is accessed twice, once
  // for read and once for write, it will only appear once (on the write
  // list). This is okay, since we are going to check for conflicts between
  // writes and between reads and writes, but not between reads and reads.
  ValueSet Seen;

  ValueVector::iterator I, IE;
  for (I = Stores.begin(), IE = Stores.end(); I != IE; ++I) {
    StoreInst *ST = dyn_cast<StoreInst>(*I);
    assert(ST && "Bad StoreInst");
    Value* Ptr = ST->getPointerOperand();
    // If we did *not* see this pointer before, insert it to
    // the read-write list. At this phase it is only a 'write' list.
    if (Seen.insert(Ptr))
      ReadWrites.push_back(Ptr);
  }

  for (I = Loads.begin(), IE = Loads.end(); I != IE; ++I) {
    LoadInst *LD = dyn_cast<LoadInst>(*I);
    assert(LD && "Bad LoadInst");
    Value* Ptr = LD->getPointerOperand();
    // If we did *not* see this pointer before, insert it to the
    // read list. If we *did* see it before, then it is already in
    // the read-write list. This allows us to vectorize expressions
    // such as A[i] += x;  Because the address of A[i] is a read-write
    // pointer. This only works if the index of A[i] is consecutive.
    // If the address of i is unknown (for example A[B[i]]) then we may
    // read a few words, modify, and write a few words, and some of the
    // words may be written to the same address.
    if (Seen.insert(Ptr) || !isConsecutiveGep(Ptr))
      Reads.push_back(Ptr);
  }

  // Now that the pointers are in two lists (Reads and ReadWrites), we
  // can check that there are no conflicts between each of the writes and
  // between the writes to the reads.
  ValueSet WriteObjects;
  ValueVector TempObjects;

  // Check that the read-writes do not conflict with other read-write
  // pointers.
  for (I = ReadWrites.begin(), IE = ReadWrites.end(); I != IE; ++I) {
    GetUnderlyingObjects(*I, TempObjects, DL);
    for (ValueVector::iterator it=TempObjects.begin(), e=TempObjects.end();
         it != e; ++it) {
      if (!isIdentifiedSafeObject(*it)) {
        DEBUG(dbgs() << "LV: Found an unidentified write ptr:"<< **it <<"\n");
        return false;
      }
      if (!WriteObjects.insert(*it)) {
        DEBUG(dbgs() << "LV: Found a possible write-write reorder:"
              << **it <<"\n");
        return false;
      }
    }
    TempObjects.clear();
  }

  /// Check that the reads don't conflict with the read-writes.
  for (I = Reads.begin(), IE = Reads.end(); I != IE; ++I) {
    GetUnderlyingObjects(*I, TempObjects, DL);
    for (ValueVector::iterator it=TempObjects.begin(), e=TempObjects.end();
         it != e; ++it) {
      if (!isIdentifiedSafeObject(*it)) {
        DEBUG(dbgs() << "LV: Found an unidentified read ptr:"<< **it <<"\n");
        return false;
      }
      if (WriteObjects.count(*it)) {
        DEBUG(dbgs() << "LV: Found a possible read/write reorder:"
              << **it <<"\n");
        return false;
      }
    }
    TempObjects.clear();
  }

  // All is okay.
  return true;
}

/// Checks if the value is a Global variable or if it is an Arguments
/// marked with the NoAlias attribute.
bool LoopVectorizationLegality::isIdentifiedSafeObject(Value* Val) {
  assert(Val && "Invalid value");
  if (dyn_cast<GlobalValue>(Val))
    return true;
  if (dyn_cast<AllocaInst>(Val))
    return true;
  Argument *A = dyn_cast<Argument>(Val);
  if (!A)
    return false;
  return A->hasNoAliasAttr();
}

bool LoopVectorizationLegality::AddReductionVar(PHINode *Phi,
                                                    ReductionKind Kind) {
  if (Phi->getNumIncomingValues() != 2)
    return false;

  // Find the possible incoming reduction variable.
  BasicBlock *BB = Phi->getParent();
  int SelfEdgeIdx = Phi->getBasicBlockIndex(BB);
  int InEdgeBlockIdx = (SelfEdgeIdx ? 0 : 1); // The other entry.
  Value *RdxStart = Phi->getIncomingValue(InEdgeBlockIdx);

  // We must have a constant that starts the reduction.
  if (!isReductionConstant(RdxStart, Kind))
    return false;

  // ExitInstruction is the single value which is used outside the loop.
  // We only allow for a single reduction value to be used outside the loop.
  // This includes users of the reduction, variables (which form a cycle
  // which ends in the phi node).
  Instruction *ExitInstruction = 0;

  // Iter is our iterator. We start with the PHI node and scan for all of the
  // users of this instruction. All users must be instructions which can be
  // used as reduction variables (such as ADD). We may have a single
  // out-of-block user. They cycle must end with the original PHI.
  // Also, we can't have multiple block-local users.
  Instruction *Iter = Phi;
  while (true) {
    // Any reduction instr must be of one of the allowed kinds.
    if (!isReductionInstr(Iter, Kind))
      return false;

    // Did we found a user inside this block ?
    bool FoundInBlockUser = false;
    // Did we reach the initial PHI node ?
    bool FoundStartPHI = false;
    // For each of the *users* of iter.
    for (Value::use_iterator it = Iter->use_begin(), e = Iter->use_end();
         it != e; ++it) {
      Instruction *U = cast<Instruction>(*it);
      // We already know that the PHI is a user.
      if (U == Phi) {
        FoundStartPHI = true;
        continue;
      }
      // Check if we found the exit user.
      BasicBlock *Parent = U->getParent();
      if (Parent != BB) {
        // We must have a single exit instruction.
        if (ExitInstruction != 0)
          return false;
        ExitInstruction = Iter;
      }
      // We can't have multiple inside users.
      if (FoundInBlockUser)
        return false;
      FoundInBlockUser = true;
      Iter = U;
    }

    // We found a reduction var if we have reached the original
    // phi node and we only have a single instruction with out-of-loop
    // users.
   if (FoundStartPHI && ExitInstruction) {
     // This instruction is allowed to have out-of-loop users.
     AllowedExit.insert(ExitInstruction);
     // Mark this as a reduction var.
     Reductions[Phi] = std::make_pair(ExitInstruction, Kind);
     return true;
   }
  }
}

bool
LoopVectorizationLegality::isReductionConstant(Value *V, ReductionKind Kind) {
  ConstantInt *CI = dyn_cast<ConstantInt>(V);
  if (!CI)
    return false;
  if (Kind == IntegerMult && CI->isOne())
    return true;
  if (Kind == IntegerAdd && CI->isZero())
    return true;
  return false;
}

bool
LoopVectorizationLegality::isReductionInstr(Instruction *I,
                                            ReductionKind Kind) {
    switch (I->getOpcode()) {
    default:
      return false;
    case Instruction::PHI:
      // possibly.
      return true;
    case Instruction::Add:
    case Instruction::Sub:
      return Kind == IntegerAdd;
    case Instruction::Mul:
    case Instruction::UDiv:
    case Instruction::SDiv:
      return Kind == IntegerMult;
    }
}

bool LoopVectorizationLegality::isInductionVariable(PHINode *Phi) {
  // Check that the PHI is consecutive and starts at zero.
  const SCEV *PhiScev = SE->getSCEV(Phi);
  const SCEVAddRecExpr *AR = dyn_cast<SCEVAddRecExpr>(PhiScev);
  if (!AR) {
    DEBUG(dbgs() << "LV: PHI is not a poly recurrence.\n");
    return false;
  }
  const SCEV *Step = AR->getStepRecurrence(*SE);
  const SCEV *Start = AR->getStart();

  if (!Step->isOne() || !Start->isZero()) {
    DEBUG(dbgs() << "LV: PHI does not start at zero or steps by one.\n");
    return false;
  }
  return true;
}

} // namespace

char LoopVectorize::ID = 0;
static const char lv_name[] = "Loop Vectorization";
INITIALIZE_PASS_BEGIN(LoopVectorize, LV_NAME, lv_name, false, false)
INITIALIZE_AG_DEPENDENCY(AliasAnalysis)
INITIALIZE_PASS_DEPENDENCY(ScalarEvolution)
INITIALIZE_PASS_DEPENDENCY(LoopSimplify)
INITIALIZE_PASS_END(LoopVectorize, LV_NAME, lv_name, false, false)

namespace llvm {
  Pass *createLoopVectorizePass() {
    return new LoopVectorize();
  }
}

