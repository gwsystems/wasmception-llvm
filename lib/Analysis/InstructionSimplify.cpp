//===- InstructionSimplify.cpp - Fold instruction operands ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements routines for folding instructions into simpler forms
// that do not require creating new instructions.  For example, this does
// constant folding, and can handle identities like (X&0)->0.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/Support/ValueHandle.h"
#include "llvm/Instructions.h"
#include "llvm/Support/PatternMatch.h"
using namespace llvm;
using namespace llvm::PatternMatch;

#define MaxRecursionDepth 3

static Value *SimplifyBinOp(unsigned, Value *, Value *, const TargetData *,
                            unsigned);
static Value *SimplifyCmpInst(unsigned, Value *, Value *, const TargetData *,
                              unsigned);

/// ThreadBinOpOverSelect - In the case of a binary operation with a select
/// instruction as an operand, try to simplify the binop by seeing whether
/// evaluating it on both branches of the select results in the same value.
/// Returns the common value if so, otherwise returns null.
static Value *ThreadBinOpOverSelect(unsigned Opcode, Value *LHS, Value *RHS,
                                    const TargetData *TD, unsigned MaxRecurse) {
  SelectInst *SI;
  if (isa<SelectInst>(LHS)) {
    SI = cast<SelectInst>(LHS);
  } else {
    assert(isa<SelectInst>(RHS) && "No select instruction operand!");
    SI = cast<SelectInst>(RHS);
  }

  // Evaluate the BinOp on the true and false branches of the select.
  Value *TV;
  Value *FV;
  if (SI == LHS) {
    TV = SimplifyBinOp(Opcode, SI->getTrueValue(), RHS, TD, MaxRecurse);
    FV = SimplifyBinOp(Opcode, SI->getFalseValue(), RHS, TD, MaxRecurse);
  } else {
    TV = SimplifyBinOp(Opcode, LHS, SI->getTrueValue(), TD, MaxRecurse);
    FV = SimplifyBinOp(Opcode, LHS, SI->getFalseValue(), TD, MaxRecurse);
  }

  // If they simplified to the same value, then return the common value.
  // If they both failed to simplify then return null.
  if (TV == FV)
    return TV;

  // If one branch simplified to undef, return the other one.
  if (TV && isa<UndefValue>(TV))
    return FV;
  if (FV && isa<UndefValue>(FV))
    return TV;

  // If applying the operation did not change the true and false select values,
  // then the result of the binop is the select itself.
  if (TV == SI->getTrueValue() && FV == SI->getFalseValue())
    return SI;

  // If one branch simplified and the other did not, and the simplified
  // value is equal to the unsimplified one, return the simplified value.
  // For example, select (cond, X, X & Z) & Z -> X & Z.
  if ((FV && !TV) || (TV && !FV)) {
    // Check that the simplified value has the form "X op Y" where "op" is the
    // same as the original operation.
    Instruction *Simplified = dyn_cast<Instruction>(FV ? FV : TV);
    if (Simplified && Simplified->getOpcode() == Opcode) {
      // The value that didn't simplify is "UnsimplifiedLHS op UnsimplifiedRHS".
      // We already know that "op" is the same as for the simplified value.  See
      // if the operands match too.  If so, return the simplified value.
      Value *UnsimplifiedBranch = FV ? SI->getTrueValue() : SI->getFalseValue();
      Value *UnsimplifiedLHS = SI == LHS ? UnsimplifiedBranch : LHS;
      Value *UnsimplifiedRHS = SI == LHS ? RHS : UnsimplifiedBranch;
      if (Simplified->getOperand(0) == UnsimplifiedLHS &&
          Simplified->getOperand(1) == UnsimplifiedRHS)
        return Simplified;
      if (Simplified->isCommutative() &&
          Simplified->getOperand(1) == UnsimplifiedLHS &&
          Simplified->getOperand(0) == UnsimplifiedRHS)
        return Simplified;
    }
  }

  return 0;
}

/// ThreadCmpOverSelect - In the case of a comparison with a select instruction,
/// try to simplify the comparison by seeing whether both branches of the select
/// result in the same value.  Returns the common value if so, otherwise returns
/// null.
static Value *ThreadCmpOverSelect(CmpInst::Predicate Pred, Value *LHS,
                                  Value *RHS, const TargetData *TD,
                                  unsigned MaxRecurse) {
  // Make sure the select is on the LHS.
  if (!isa<SelectInst>(LHS)) {
    std::swap(LHS, RHS);
    Pred = CmpInst::getSwappedPredicate(Pred);
  }
  assert(isa<SelectInst>(LHS) && "Not comparing with a select instruction!");
  SelectInst *SI = cast<SelectInst>(LHS);

  // Now that we have "cmp select(cond, TV, FV), RHS", analyse it.
  // Does "cmp TV, RHS" simplify?
  if (Value *TCmp = SimplifyCmpInst(Pred, SI->getTrueValue(), RHS, TD,
                                    MaxRecurse))
    // It does!  Does "cmp FV, RHS" simplify?
    if (Value *FCmp = SimplifyCmpInst(Pred, SI->getFalseValue(), RHS, TD,
                                      MaxRecurse))
      // It does!  If they simplified to the same value, then use it as the
      // result of the original comparison.
      if (TCmp == FCmp)
        return TCmp;
  return 0;
}

/// ThreadBinOpOverPHI - In the case of a binary operation with an operand that
/// is a PHI instruction, try to simplify the binop by seeing whether evaluating
/// it on the incoming phi values yields the same result for every value.  If so
/// returns the common value, otherwise returns null.
static Value *ThreadBinOpOverPHI(unsigned Opcode, Value *LHS, Value *RHS,
                                 const TargetData *TD, unsigned MaxRecurse) {
  PHINode *PI;
  if (isa<PHINode>(LHS)) {
    PI = cast<PHINode>(LHS);
  } else {
    assert(isa<PHINode>(RHS) && "No PHI instruction operand!");
    PI = cast<PHINode>(RHS);
  }

  // Evaluate the BinOp on the incoming phi values.
  Value *CommonValue = 0;
  for (unsigned i = 0, e = PI->getNumIncomingValues(); i != e; ++i) {
    Value *V = PI == LHS ?
      SimplifyBinOp(Opcode, PI->getIncomingValue(i), RHS, TD, MaxRecurse) :
      SimplifyBinOp(Opcode, LHS, PI->getIncomingValue(i), TD, MaxRecurse);
    // If the operation failed to simplify, or simplified to a different value
    // to previously, then give up.
    if (!V || (CommonValue && V != CommonValue))
      return 0;
    CommonValue = V;
  }

  return CommonValue;
}

/// ThreadCmpOverPHI - In the case of a comparison with a PHI instruction, try
/// try to simplify the comparison by seeing whether comparing with all of the
/// incoming phi values yields the same result every time.  If so returns the
/// common result, otherwise returns null.
static Value *ThreadCmpOverPHI(CmpInst::Predicate Pred, Value *LHS, Value *RHS,
                               const TargetData *TD, unsigned MaxRecurse) {
  // Make sure the phi is on the LHS.
  if (!isa<PHINode>(LHS)) {
    std::swap(LHS, RHS);
    Pred = CmpInst::getSwappedPredicate(Pred);
  }
  assert(isa<PHINode>(LHS) && "Not comparing with a phi instruction!");
  PHINode *PI = cast<PHINode>(LHS);

  // Evaluate the BinOp on the incoming phi values.
  Value *CommonValue = 0;
  for (unsigned i = 0, e = PI->getNumIncomingValues(); i != e; ++i) {
    Value *V = SimplifyCmpInst(Pred, PI->getIncomingValue(i), RHS, TD,
                               MaxRecurse);
    // If the operation failed to simplify, or simplified to a different value
    // to previously, then give up.
    if (!V || (CommonValue && V != CommonValue))
      return 0;
    CommonValue = V;
  }

  return CommonValue;
}

/// SimplifyAddInst - Given operands for an Add, see if we can
/// fold the result.  If not, this returns null.
Value *llvm::SimplifyAddInst(Value *Op0, Value *Op1, bool isNSW, bool isNUW,
                             const TargetData *TD) {
  if (Constant *CLHS = dyn_cast<Constant>(Op0)) {
    if (Constant *CRHS = dyn_cast<Constant>(Op1)) {
      Constant *Ops[] = { CLHS, CRHS };
      return ConstantFoldInstOperands(Instruction::Add, CLHS->getType(),
                                      Ops, 2, TD);
    }

    // Canonicalize the constant to the RHS.
    std::swap(Op0, Op1);
  }

  if (Constant *Op1C = dyn_cast<Constant>(Op1)) {
    // X + undef -> undef
    if (isa<UndefValue>(Op1C))
      return Op1C;

    // X + 0 --> X
    if (Op1C->isNullValue())
      return Op0;
  }

  // FIXME: Could pull several more out of instcombine.
  return 0;
}

/// SimplifyAndInst - Given operands for an And, see if we can
/// fold the result.  If not, this returns null.
static Value *SimplifyAndInst(Value *Op0, Value *Op1, const TargetData *TD,
                              unsigned MaxRecurse) {
  if (Constant *CLHS = dyn_cast<Constant>(Op0)) {
    if (Constant *CRHS = dyn_cast<Constant>(Op1)) {
      Constant *Ops[] = { CLHS, CRHS };
      return ConstantFoldInstOperands(Instruction::And, CLHS->getType(),
                                      Ops, 2, TD);
    }

    // Canonicalize the constant to the RHS.
    std::swap(Op0, Op1);
  }

  // X & undef -> 0
  if (isa<UndefValue>(Op1))
    return Constant::getNullValue(Op0->getType());

  // X & X = X
  if (Op0 == Op1)
    return Op0;

  // X & <0,0> = <0,0>
  if (isa<ConstantAggregateZero>(Op1))
    return Op1;

  // X & <-1,-1> = X
  if (ConstantVector *CP = dyn_cast<ConstantVector>(Op1))
    if (CP->isAllOnesValue())
      return Op0;

  if (ConstantInt *Op1CI = dyn_cast<ConstantInt>(Op1)) {
    // X & 0 = 0
    if (Op1CI->isZero())
      return Op1CI;
    // X & -1 = X
    if (Op1CI->isAllOnesValue())
      return Op0;
  }

  // A & ~A  =  ~A & A  =  0
  Value *A, *B;
  if ((match(Op0, m_Not(m_Value(A))) && A == Op1) ||
      (match(Op1, m_Not(m_Value(A))) && A == Op0))
    return Constant::getNullValue(Op0->getType());

  // (A | ?) & A = A
  if (match(Op0, m_Or(m_Value(A), m_Value(B))) &&
      (A == Op1 || B == Op1))
    return Op1;

  // A & (A | ?) = A
  if (match(Op1, m_Or(m_Value(A), m_Value(B))) &&
      (A == Op0 || B == Op0))
    return Op0;

  // (A & B) & A -> A & B
  if (match(Op0, m_And(m_Value(A), m_Value(B))) &&
      (A == Op1 || B == Op1))
    return Op0;

  // A & (A & B) -> A & B
  if (match(Op1, m_And(m_Value(A), m_Value(B))) &&
      (A == Op0 || B == Op0))
    return Op1;

  // If the operation is with the result of a select instruction, check whether
  // operating on either branch of the select always yields the same value.
  if (MaxRecurse && (isa<SelectInst>(Op0) || isa<SelectInst>(Op1)))
    if (Value *V = ThreadBinOpOverSelect(Instruction::And, Op0, Op1, TD,
                                         MaxRecurse-1))
      return V;

  // If the operation is with the result of a phi instruction, check whether
  // operating on all incoming values of the phi always yields the same value.
  if (MaxRecurse && (isa<PHINode>(Op0) || isa<PHINode>(Op1)))
    if (Value *V = ThreadBinOpOverPHI(Instruction::And, Op0, Op1, TD,
                                      MaxRecurse-1))
      return V;

  return 0;
}

Value *llvm::SimplifyAndInst(Value *Op0, Value *Op1, const TargetData *TD) {
  return ::SimplifyAndInst(Op0, Op1, TD, MaxRecursionDepth);
}

/// SimplifyOrInst - Given operands for an Or, see if we can
/// fold the result.  If not, this returns null.
static Value *SimplifyOrInst(Value *Op0, Value *Op1, const TargetData *TD,
                             unsigned MaxRecurse) {
  if (Constant *CLHS = dyn_cast<Constant>(Op0)) {
    if (Constant *CRHS = dyn_cast<Constant>(Op1)) {
      Constant *Ops[] = { CLHS, CRHS };
      return ConstantFoldInstOperands(Instruction::Or, CLHS->getType(),
                                      Ops, 2, TD);
    }

    // Canonicalize the constant to the RHS.
    std::swap(Op0, Op1);
  }

  // X | undef -> -1
  if (isa<UndefValue>(Op1))
    return Constant::getAllOnesValue(Op0->getType());

  // X | X = X
  if (Op0 == Op1)
    return Op0;

  // X | <0,0> = X
  if (isa<ConstantAggregateZero>(Op1))
    return Op0;

  // X | <-1,-1> = <-1,-1>
  if (ConstantVector *CP = dyn_cast<ConstantVector>(Op1))
    if (CP->isAllOnesValue())
      return Op1;

  if (ConstantInt *Op1CI = dyn_cast<ConstantInt>(Op1)) {
    // X | 0 = X
    if (Op1CI->isZero())
      return Op0;
    // X | -1 = -1
    if (Op1CI->isAllOnesValue())
      return Op1CI;
  }

  // A | ~A  =  ~A | A  =  -1
  Value *A, *B;
  if ((match(Op0, m_Not(m_Value(A))) && A == Op1) ||
      (match(Op1, m_Not(m_Value(A))) && A == Op0))
    return Constant::getAllOnesValue(Op0->getType());

  // (A & ?) | A = A
  if (match(Op0, m_And(m_Value(A), m_Value(B))) &&
      (A == Op1 || B == Op1))
    return Op1;

  // A | (A & ?) = A
  if (match(Op1, m_And(m_Value(A), m_Value(B))) &&
      (A == Op0 || B == Op0))
    return Op0;

  // (A | B) | A -> A | B
  if (match(Op0, m_Or(m_Value(A), m_Value(B))) &&
      (A == Op1 || B == Op1))
    return Op0;

  // A | (A | B) -> A | B
  if (match(Op1, m_Or(m_Value(A), m_Value(B))) &&
      (A == Op0 || B == Op0))
    return Op1;

  // If the operation is with the result of a select instruction, check whether
  // operating on either branch of the select always yields the same value.
  if (MaxRecurse && (isa<SelectInst>(Op0) || isa<SelectInst>(Op1)))
    if (Value *V = ThreadBinOpOverSelect(Instruction::Or, Op0, Op1, TD,
                                         MaxRecurse-1))
      return V;

  // If the operation is with the result of a phi instruction, check whether
  // operating on all incoming values of the phi always yields the same value.
  if (MaxRecurse && (isa<PHINode>(Op0) || isa<PHINode>(Op1)))
    if (Value *V = ThreadBinOpOverPHI(Instruction::Or, Op0, Op1, TD,
                                      MaxRecurse-1))
      return V;

  return 0;
}

Value *llvm::SimplifyOrInst(Value *Op0, Value *Op1, const TargetData *TD) {
  return ::SimplifyOrInst(Op0, Op1, TD, MaxRecursionDepth);
}

static const Type *GetCompareTy(Value *Op) {
  return CmpInst::makeCmpResultType(Op->getType());
}

/// SimplifyICmpInst - Given operands for an ICmpInst, see if we can
/// fold the result.  If not, this returns null.
static Value *SimplifyICmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                               const TargetData *TD, unsigned MaxRecurse) {
  CmpInst::Predicate Pred = (CmpInst::Predicate)Predicate;
  assert(CmpInst::isIntPredicate(Pred) && "Not an integer compare!");

  if (Constant *CLHS = dyn_cast<Constant>(LHS)) {
    if (Constant *CRHS = dyn_cast<Constant>(RHS))
      return ConstantFoldCompareInstOperands(Pred, CLHS, CRHS, TD);

    // If we have a constant, make sure it is on the RHS.
    std::swap(LHS, RHS);
    Pred = CmpInst::getSwappedPredicate(Pred);
  }

  // ITy - This is the return type of the compare we're considering.
  const Type *ITy = GetCompareTy(LHS);

  // icmp X, X -> true/false
  // X icmp undef -> true/false.  For example, icmp ugt %X, undef -> false
  // because X could be 0.
  if (LHS == RHS || isa<UndefValue>(RHS))
    return ConstantInt::get(ITy, CmpInst::isTrueWhenEqual(Pred));

  // icmp <global/alloca*/null>, <global/alloca*/null> - Global/Stack value
  // addresses never equal each other!  We already know that Op0 != Op1.
  if ((isa<GlobalValue>(LHS) || isa<AllocaInst>(LHS) ||
       isa<ConstantPointerNull>(LHS)) &&
      (isa<GlobalValue>(RHS) || isa<AllocaInst>(RHS) ||
       isa<ConstantPointerNull>(RHS)))
    return ConstantInt::get(ITy, CmpInst::isFalseWhenEqual(Pred));

  // See if we are doing a comparison with a constant.
  if (ConstantInt *CI = dyn_cast<ConstantInt>(RHS)) {
    // If we have an icmp le or icmp ge instruction, turn it into the
    // appropriate icmp lt or icmp gt instruction.  This allows us to rely on
    // them being folded in the code below.
    switch (Pred) {
    default: break;
    case ICmpInst::ICMP_ULE:
      if (CI->isMaxValue(false))                 // A <=u MAX -> TRUE
        return ConstantInt::getTrue(CI->getContext());
      break;
    case ICmpInst::ICMP_SLE:
      if (CI->isMaxValue(true))                  // A <=s MAX -> TRUE
        return ConstantInt::getTrue(CI->getContext());
      break;
    case ICmpInst::ICMP_UGE:
      if (CI->isMinValue(false))                 // A >=u MIN -> TRUE
        return ConstantInt::getTrue(CI->getContext());
      break;
    case ICmpInst::ICMP_SGE:
      if (CI->isMinValue(true))                  // A >=s MIN -> TRUE
        return ConstantInt::getTrue(CI->getContext());
      break;
    }
  }

  // If the comparison is with the result of a select instruction, check whether
  // comparing with either branch of the select always yields the same value.
  if (MaxRecurse && (isa<SelectInst>(LHS) || isa<SelectInst>(RHS)))
    if (Value *V = ThreadCmpOverSelect(Pred, LHS, RHS, TD, MaxRecurse-1))
      return V;

  // If the comparison is with the result of a phi instruction, check whether
  // doing the compare with each incoming phi value yields a common result.
  if (MaxRecurse && (isa<PHINode>(LHS) || isa<PHINode>(RHS)))
    if (Value *V = ThreadCmpOverPHI(Pred, LHS, RHS, TD, MaxRecurse-1))
      return V;

  return 0;
}

Value *llvm::SimplifyICmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                              const TargetData *TD) {
  return ::SimplifyICmpInst(Predicate, LHS, RHS, TD, MaxRecursionDepth);
}

/// SimplifyFCmpInst - Given operands for an FCmpInst, see if we can
/// fold the result.  If not, this returns null.
static Value *SimplifyFCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                               const TargetData *TD, unsigned MaxRecurse) {
  CmpInst::Predicate Pred = (CmpInst::Predicate)Predicate;
  assert(CmpInst::isFPPredicate(Pred) && "Not an FP compare!");

  if (Constant *CLHS = dyn_cast<Constant>(LHS)) {
    if (Constant *CRHS = dyn_cast<Constant>(RHS))
      return ConstantFoldCompareInstOperands(Pred, CLHS, CRHS, TD);

    // If we have a constant, make sure it is on the RHS.
    std::swap(LHS, RHS);
    Pred = CmpInst::getSwappedPredicate(Pred);
  }

  // Fold trivial predicates.
  if (Pred == FCmpInst::FCMP_FALSE)
    return ConstantInt::get(GetCompareTy(LHS), 0);
  if (Pred == FCmpInst::FCMP_TRUE)
    return ConstantInt::get(GetCompareTy(LHS), 1);

  if (isa<UndefValue>(RHS))                  // fcmp pred X, undef -> undef
    return UndefValue::get(GetCompareTy(LHS));

  // fcmp x,x -> true/false.  Not all compares are foldable.
  if (LHS == RHS) {
    if (CmpInst::isTrueWhenEqual(Pred))
      return ConstantInt::get(GetCompareTy(LHS), 1);
    if (CmpInst::isFalseWhenEqual(Pred))
      return ConstantInt::get(GetCompareTy(LHS), 0);
  }

  // Handle fcmp with constant RHS
  if (Constant *RHSC = dyn_cast<Constant>(RHS)) {
    // If the constant is a nan, see if we can fold the comparison based on it.
    if (ConstantFP *CFP = dyn_cast<ConstantFP>(RHSC)) {
      if (CFP->getValueAPF().isNaN()) {
        if (FCmpInst::isOrdered(Pred))   // True "if ordered and foo"
          return ConstantInt::getFalse(CFP->getContext());
        assert(FCmpInst::isUnordered(Pred) &&
               "Comparison must be either ordered or unordered!");
        // True if unordered.
        return ConstantInt::getTrue(CFP->getContext());
      }
      // Check whether the constant is an infinity.
      if (CFP->getValueAPF().isInfinity()) {
        if (CFP->getValueAPF().isNegative()) {
          switch (Pred) {
          case FCmpInst::FCMP_OLT:
            // No value is ordered and less than negative infinity.
            return ConstantInt::getFalse(CFP->getContext());
          case FCmpInst::FCMP_UGE:
            // All values are unordered with or at least negative infinity.
            return ConstantInt::getTrue(CFP->getContext());
          default:
            break;
          }
        } else {
          switch (Pred) {
          case FCmpInst::FCMP_OGT:
            // No value is ordered and greater than infinity.
            return ConstantInt::getFalse(CFP->getContext());
          case FCmpInst::FCMP_ULE:
            // All values are unordered with and at most infinity.
            return ConstantInt::getTrue(CFP->getContext());
          default:
            break;
          }
        }
      }
    }
  }

  // If the comparison is with the result of a select instruction, check whether
  // comparing with either branch of the select always yields the same value.
  if (MaxRecurse && (isa<SelectInst>(LHS) || isa<SelectInst>(RHS)))
    if (Value *V = ThreadCmpOverSelect(Pred, LHS, RHS, TD, MaxRecurse-1))
      return V;

  // If the comparison is with the result of a phi instruction, check whether
  // doing the compare with each incoming phi value yields a common result.
  if (MaxRecurse && (isa<PHINode>(LHS) || isa<PHINode>(RHS)))
    if (Value *V = ThreadCmpOverPHI(Pred, LHS, RHS, TD, MaxRecurse-1))
      return V;

  return 0;
}

Value *llvm::SimplifyFCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                              const TargetData *TD) {
  return ::SimplifyFCmpInst(Predicate, LHS, RHS, TD, MaxRecursionDepth);
}

/// SimplifySelectInst - Given operands for a SelectInst, see if we can fold
/// the result.  If not, this returns null.
Value *llvm::SimplifySelectInst(Value *CondVal, Value *TrueVal, Value *FalseVal,
                                const TargetData *TD) {
  // select true, X, Y  -> X
  // select false, X, Y -> Y
  if (ConstantInt *CB = dyn_cast<ConstantInt>(CondVal))
    return CB->getZExtValue() ? TrueVal : FalseVal;

  // select C, X, X -> X
  if (TrueVal == FalseVal)
    return TrueVal;

  if (isa<UndefValue>(TrueVal))   // select C, undef, X -> X
    return FalseVal;
  if (isa<UndefValue>(FalseVal))   // select C, X, undef -> X
    return TrueVal;
  if (isa<UndefValue>(CondVal)) {  // select undef, X, Y -> X or Y
    if (isa<Constant>(TrueVal))
      return TrueVal;
    return FalseVal;
  }

  return 0;
}


/// SimplifyGEPInst - Given operands for an GetElementPtrInst, see if we can
/// fold the result.  If not, this returns null.
Value *llvm::SimplifyGEPInst(Value *const *Ops, unsigned NumOps,
                             const TargetData *TD) {
  // getelementptr P -> P.
  if (NumOps == 1)
    return Ops[0];

  // TODO.
  //if (isa<UndefValue>(Ops[0]))
  //  return UndefValue::get(GEP.getType());

  // getelementptr P, 0 -> P.
  if (NumOps == 2)
    if (ConstantInt *C = dyn_cast<ConstantInt>(Ops[1]))
      if (C->isZero())
        return Ops[0];

  // Check to see if this is constant foldable.
  for (unsigned i = 0; i != NumOps; ++i)
    if (!isa<Constant>(Ops[i]))
      return 0;

  return ConstantExpr::getGetElementPtr(cast<Constant>(Ops[0]),
                                        (Constant *const*)Ops+1, NumOps-1);
}


//=== Helper functions for higher up the class hierarchy.

/// SimplifyBinOp - Given operands for a BinaryOperator, see if we can
/// fold the result.  If not, this returns null.
static Value *SimplifyBinOp(unsigned Opcode, Value *LHS, Value *RHS,
                            const TargetData *TD, unsigned MaxRecurse) {
  switch (Opcode) {
  case Instruction::And: return SimplifyAndInst(LHS, RHS, TD, MaxRecurse);
  case Instruction::Or:  return SimplifyOrInst(LHS, RHS, TD, MaxRecurse);
  default:
    if (Constant *CLHS = dyn_cast<Constant>(LHS))
      if (Constant *CRHS = dyn_cast<Constant>(RHS)) {
        Constant *COps[] = {CLHS, CRHS};
        return ConstantFoldInstOperands(Opcode, LHS->getType(), COps, 2, TD);
      }

    // If the operation is with the result of a select instruction, check whether
    // operating on either branch of the select always yields the same value.
    if (MaxRecurse && (isa<SelectInst>(LHS) || isa<SelectInst>(RHS)))
      if (Value *V = ThreadBinOpOverSelect(Opcode, LHS, RHS, TD, MaxRecurse-1))
        return V;

    // If the operation is with the result of a phi instruction, check whether
    // operating on all incoming values of the phi always yields the same value.
    if (MaxRecurse && (isa<PHINode>(LHS) || isa<PHINode>(RHS)))
      if (Value *V = ThreadBinOpOverPHI(Opcode, LHS, RHS, TD, MaxRecurse-1))
        return V;

    return 0;
  }
}

Value *llvm::SimplifyBinOp(unsigned Opcode, Value *LHS, Value *RHS,
                           const TargetData *TD) {
  return ::SimplifyBinOp(Opcode, LHS, RHS, TD, MaxRecursionDepth);
}

/// SimplifyCmpInst - Given operands for a CmpInst, see if we can
/// fold the result.
static Value *SimplifyCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                              const TargetData *TD, unsigned MaxRecurse) {
  if (CmpInst::isIntPredicate((CmpInst::Predicate)Predicate))
    return SimplifyICmpInst(Predicate, LHS, RHS, TD, MaxRecurse);
  return SimplifyFCmpInst(Predicate, LHS, RHS, TD, MaxRecurse);
}

Value *llvm::SimplifyCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                             const TargetData *TD) {
  return ::SimplifyCmpInst(Predicate, LHS, RHS, TD, MaxRecursionDepth);
}

/// SimplifyInstruction - See if we can compute a simplified version of this
/// instruction.  If not, this returns null.
Value *llvm::SimplifyInstruction(Instruction *I, const TargetData *TD) {
  switch (I->getOpcode()) {
  default:
    return ConstantFoldInstruction(I, TD);
  case Instruction::Add:
    return SimplifyAddInst(I->getOperand(0), I->getOperand(1),
                           cast<BinaryOperator>(I)->hasNoSignedWrap(),
                           cast<BinaryOperator>(I)->hasNoUnsignedWrap(), TD);
  case Instruction::And:
    return SimplifyAndInst(I->getOperand(0), I->getOperand(1), TD);
  case Instruction::Or:
    return SimplifyOrInst(I->getOperand(0), I->getOperand(1), TD);
  case Instruction::ICmp:
    return SimplifyICmpInst(cast<ICmpInst>(I)->getPredicate(),
                            I->getOperand(0), I->getOperand(1), TD);
  case Instruction::FCmp:
    return SimplifyFCmpInst(cast<FCmpInst>(I)->getPredicate(),
                            I->getOperand(0), I->getOperand(1), TD);
  case Instruction::Select:
    return SimplifySelectInst(I->getOperand(0), I->getOperand(1),
                              I->getOperand(2), TD);
  case Instruction::GetElementPtr: {
    SmallVector<Value*, 8> Ops(I->op_begin(), I->op_end());
    return SimplifyGEPInst(&Ops[0], Ops.size(), TD);
  }
  }
}

/// ReplaceAndSimplifyAllUses - Perform From->replaceAllUsesWith(To) and then
/// delete the From instruction.  In addition to a basic RAUW, this does a
/// recursive simplification of the newly formed instructions.  This catches
/// things where one simplification exposes other opportunities.  This only
/// simplifies and deletes scalar operations, it does not change the CFG.
///
void llvm::ReplaceAndSimplifyAllUses(Instruction *From, Value *To,
                                     const TargetData *TD) {
  assert(From != To && "ReplaceAndSimplifyAllUses(X,X) is not valid!");

  // FromHandle/ToHandle - This keeps a WeakVH on the from/to values so that
  // we can know if it gets deleted out from under us or replaced in a
  // recursive simplification.
  WeakVH FromHandle(From);
  WeakVH ToHandle(To);

  while (!From->use_empty()) {
    // Update the instruction to use the new value.
    Use &TheUse = From->use_begin().getUse();
    Instruction *User = cast<Instruction>(TheUse.getUser());
    TheUse = To;

    // Check to see if the instruction can be folded due to the operand
    // replacement.  For example changing (or X, Y) into (or X, -1) can replace
    // the 'or' with -1.
    Value *SimplifiedVal;
    {
      // Sanity check to make sure 'User' doesn't dangle across
      // SimplifyInstruction.
      AssertingVH<> UserHandle(User);

      SimplifiedVal = SimplifyInstruction(User, TD);
      if (SimplifiedVal == 0) continue;
    }

    // Recursively simplify this user to the new value.
    ReplaceAndSimplifyAllUses(User, SimplifiedVal, TD);
    From = dyn_cast_or_null<Instruction>((Value*)FromHandle);
    To = ToHandle;

    assert(ToHandle && "To value deleted by recursive simplification?");

    // If the recursive simplification ended up revisiting and deleting
    // 'From' then we're done.
    if (From == 0)
      return;
  }

  // If 'From' has value handles referring to it, do a real RAUW to update them.
  From->replaceAllUsesWith(To);

  From->eraseFromParent();
}
