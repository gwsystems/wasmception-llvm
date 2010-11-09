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
Value *llvm::SimplifyAndInst(Value *Op0, Value *Op1, const TargetData *TD) {
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

  return 0;
}

/// SimplifyOrInst - Given operands for an Or, see if we can
/// fold the result.  If not, this returns null.
Value *llvm::SimplifyOrInst(Value *Op0, Value *Op1, const TargetData *TD) {
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

  return 0;
}


static const Type *GetCompareTy(Value *Op) {
  return CmpInst::makeCmpResultType(Op->getType());
}

/// ThreadCmpOverSelect - In the case of a comparison with a select instruction,
/// try to simplify the comparison by seeing whether both branches of the select
/// result in the same value.  Returns the common value if so, otherwise returns
/// null.
static Value *ThreadCmpOverSelect(CmpInst::Predicate Pred, Value *LHS,
                                  Value *RHS, const TargetData *TD) {
  // Make sure the select is on the LHS.
  if (!isa<SelectInst>(LHS)) {
    std::swap(LHS, RHS);
    Pred = CmpInst::getSwappedPredicate(Pred);
  }
  assert(isa<SelectInst>(LHS) && "Not comparing with a select instruction!");
  SelectInst *SI = cast<SelectInst>(LHS);

  // Now that we have "cmp select(cond, TV, FV), RHS", analyse it.
  // Does "cmp TV, RHS" simplify?
  if (Value *TCmp = SimplifyCmpInst(Pred, SI->getTrueValue(), RHS, TD))
    // It does!  Does "cmp FV, RHS" simplify?
    if (Value *FCmp = SimplifyCmpInst(Pred, SI->getFalseValue(), RHS, TD))
      // It does!  If they simplified to the same value, then use it as the
      // result of the original comparison.
      if (TCmp == FCmp)
        return TCmp;
  return 0;
}

/// SimplifyICmpInst - Given operands for an ICmpInst, see if we can
/// fold the result.  If not, this returns null.
Value *llvm::SimplifyICmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                              const TargetData *TD) {
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
  if (isa<SelectInst>(LHS) || isa<SelectInst>(RHS))
    if (Value *V = ThreadCmpOverSelect(Pred, LHS, RHS, TD))
      return V;

  return 0;
}

/// SimplifyFCmpInst - Given operands for an FCmpInst, see if we can
/// fold the result.  If not, this returns null.
Value *llvm::SimplifyFCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                              const TargetData *TD) {
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
  if (isa<SelectInst>(LHS) || isa<SelectInst>(RHS))
    if (Value *V = ThreadCmpOverSelect(Pred, LHS, RHS, TD))
      return V;

  return 0;
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
Value *llvm::SimplifyBinOp(unsigned Opcode, Value *LHS, Value *RHS, 
                           const TargetData *TD) {
  switch (Opcode) {
  case Instruction::And: return SimplifyAndInst(LHS, RHS, TD);
  case Instruction::Or:  return SimplifyOrInst(LHS, RHS, TD);
  default:
    if (Constant *CLHS = dyn_cast<Constant>(LHS))
      if (Constant *CRHS = dyn_cast<Constant>(RHS)) {
        Constant *COps[] = {CLHS, CRHS};
        return ConstantFoldInstOperands(Opcode, LHS->getType(), COps, 2, TD);
      }
    return 0;
  }
}

/// SimplifyCmpInst - Given operands for a CmpInst, see if we can
/// fold the result.
Value *llvm::SimplifyCmpInst(unsigned Predicate, Value *LHS, Value *RHS,
                             const TargetData *TD) {
  if (CmpInst::isIntPredicate((CmpInst::Predicate)Predicate))
    return SimplifyICmpInst(Predicate, LHS, RHS, TD);
  return SimplifyFCmpInst(Predicate, LHS, RHS, TD);
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

