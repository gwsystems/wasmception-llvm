//===-- llvm/ConstantRangesSet.h - The constant set of ranges ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// @file
/// This file contains class that implements constant set of ranges:
/// [<Low0,High0>,...,<LowN,HighN>]. Mainly, this set is used by SwitchInst and
/// represents case value that may contain multiple ranges for a single
/// successor.
///
//
//===----------------------------------------------------------------------===//

#ifndef CONSTANTRANGESSET_H_
#define CONSTANTRANGESSET_H_

#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/LLVMContext.h"

namespace llvm {
  
  // The IntItem is a wrapper for APInt.
  // 1. It determines sign of integer, it allows to use
  //    comparison operators >,<,>=,<=, and as result we got shorter and cleaner
  //    constructions.
  // 2. It helps to implement PR1255 (case ranges) as a series of small patches.
  // 3. Currently we can interpret IntItem both as ConstantInt and as APInt.
  //    It allows to provide SwitchInst methods that works with ConstantInt for
  //    non-updated passes. And it allows to use APInt interface for new methods.   
  // 4. IntItem can be easily replaced with APInt.
  
  // The set of macros that allows to propagate APInt operators to the IntItem. 

#define INT_ITEM_DEFINE_COMPARISON(op,func) \
  bool operator op (const APInt& RHS) const { \
    return ConstantIntVal->getValue().func(RHS); \
  }
  
#define INT_ITEM_DEFINE_UNARY_OP(op) \
  IntItem operator op () const { \
    APInt res = op(ConstantIntVal->getValue()); \
    Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res); \
    return IntItem(cast<ConstantInt>(NewVal)); \
  }
  
#define INT_ITEM_DEFINE_BINARY_OP(op) \
  IntItem operator op (const APInt& RHS) const { \
    APInt res = ConstantIntVal->getValue() op RHS; \
    Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res); \
    return IntItem(cast<ConstantInt>(NewVal)); \
  }
  
#define INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(op) \
  IntItem& operator op (const APInt& RHS) {\
    APInt res = ConstantIntVal->getValue();\
    res op RHS; \
    Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res); \
    ConstantIntVal = cast<ConstantInt>(NewVal); \
    return *this; \
  }  
  
#define INT_ITEM_DEFINE_PREINCDEC(op) \
    IntItem& operator op () { \
      APInt res = ConstantIntVal->getValue(); \
      op(res); \
      Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res); \
      ConstantIntVal = cast<ConstantInt>(NewVal); \
      return *this; \
    }    

#define INT_ITEM_DEFINE_POSTINCDEC(op) \
    IntItem& operator op (int) { \
      APInt res = ConstantIntVal->getValue();\
      op(res); \
      Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res); \
      OldConstantIntVal = ConstantIntVal; \
      ConstantIntVal = cast<ConstantInt>(NewVal); \
      return IntItem(OldConstantIntVal); \
    }   
  
#define INT_ITEM_DEFINE_OP_STANDARD_INT(RetTy, op, IntTy) \
  RetTy operator op (IntTy RHS) const { \
    return (*this) op APInt(ConstantIntVal->getValue().getBitWidth(), RHS); \
  }  

class IntItem {
  ConstantInt *ConstantIntVal;
  IntItem(const ConstantInt *V) : ConstantIntVal(const_cast<ConstantInt*>(V)) {}
public:
  
  IntItem() {}
  
  operator const APInt&() const {
    return (const APInt&)ConstantIntVal->getValue();
  }  
  
  // Propogate APInt operators.
  // Note, that
  // /,/=,>>,>>= are not implemented in APInt.
  // <<= is implemented for unsigned RHS, but not implemented for APInt RHS.
  
  INT_ITEM_DEFINE_COMPARISON(<, ult)
  INT_ITEM_DEFINE_COMPARISON(>, ugt)
  INT_ITEM_DEFINE_COMPARISON(<=, ule)
  INT_ITEM_DEFINE_COMPARISON(>=, uge)
  INT_ITEM_DEFINE_COMPARISON(==, eq)
  INT_ITEM_DEFINE_COMPARISON(!=, ne)
  
  INT_ITEM_DEFINE_BINARY_OP(*)
  INT_ITEM_DEFINE_BINARY_OP(+)
  INT_ITEM_DEFINE_OP_STANDARD_INT(IntItem,+,uint64_t)
  INT_ITEM_DEFINE_BINARY_OP(-)
  INT_ITEM_DEFINE_OP_STANDARD_INT(IntItem,-,uint64_t)
  INT_ITEM_DEFINE_BINARY_OP(<<)
  INT_ITEM_DEFINE_OP_STANDARD_INT(IntItem,<<,unsigned)
  INT_ITEM_DEFINE_BINARY_OP(&)
  INT_ITEM_DEFINE_BINARY_OP(^)
  INT_ITEM_DEFINE_BINARY_OP(|)
  
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(*=)
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(+=)
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(-=)
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(&=)
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(^=)
  INT_ITEM_DEFINE_ASSIGNMENT_BY_OP(|=)
  
  // Special case for <<=
  IntItem& operator <<= (unsigned RHS) {
    APInt res = ConstantIntVal->getValue();
    res <<= RHS;
    Constant *NewVal = ConstantInt::get(ConstantIntVal->getContext(), res);
    ConstantIntVal = cast<ConstantInt>(NewVal);
    return *this;    
  }
  
  INT_ITEM_DEFINE_UNARY_OP(-)
  INT_ITEM_DEFINE_UNARY_OP(~)
  
  INT_ITEM_DEFINE_PREINCDEC(++)
  INT_ITEM_DEFINE_PREINCDEC(--)
  
  // The set of workarounds, since currently we use ConstantInt implemented
  // integer.
  
  static IntItem fromConstantInt(const ConstantInt *V) {
    return IntItem(V);
  }
  static IntItem fromType(Type* Ty, const APInt& V) {
    ConstantInt *C = cast<ConstantInt>(ConstantInt::get(Ty, V));
    return fromConstantInt(C);
  }
  static IntItem withImplLikeThis(const IntItem& LikeThis, const APInt& V) {
    ConstantInt *C = cast<ConstantInt>(ConstantInt::get(
        LikeThis.ConstantIntVal->getContext(), V));
    return fromConstantInt(C);
  }
  ConstantInt *toConstantInt() {
    return ConstantIntVal;
  }
};

// TODO: it should be a class in next commit.
struct IntRange {

    IntItem Low;
    IntItem High;
    bool IsEmpty : 1;
    bool IsSingleNumber : 1;
// TODO: 
// public:
    
    typedef std::pair<IntRange, IntRange> SubRes;
    
    IntRange() : IsEmpty(true) {}
    IntRange(const IntRange &RHS) :
      Low(RHS.Low), High(RHS.High), IsEmpty(false), IsSingleNumber(false) {}
    IntRange(const IntItem &C) :
      Low(C), High(C), IsEmpty(false), IsSingleNumber(true) {}
    IntRange(const IntItem &L, const IntItem &H) : Low(L), High(H),
        IsEmpty(false), IsSingleNumber(false) {}
    
    bool isEmpty() const { return IsEmpty; }
    bool isSingleNumber() const { return IsSingleNumber; }
    
    const IntItem& getLow() {
      assert(!IsEmpty && "Range is empty.");
      return Low;
    }
    const IntItem& getHigh() {
      assert(!IsEmpty && "Range is empty.");
      return High;
    }
   
    bool operator<(const IntRange &RHS) const {
      assert(!IsEmpty && "Left range is empty.");
      assert(!RHS.IsEmpty && "Right range is empty.");
      if (Low == RHS.Low) {
        if (High > RHS.High)
          return true;
        return false;
      }
      if (Low < RHS.Low)
        return true;
      return false;
    }

    bool operator==(const IntRange &RHS) const {
      assert(!IsEmpty && "Left range is empty.");
      assert(!RHS.IsEmpty && "Right range is empty.");
      return Low == RHS.Low && High == RHS.High;      
    }
 
    bool operator!=(const IntRange &RHS) const {
      return !operator ==(RHS);      
    }
 
    static bool LessBySize(const IntRange &LHS, const IntRange &RHS) {
      return (LHS.High - LHS.Low) < (RHS.High - RHS.Low);
    }
 
    bool isInRange(const IntItem &IntVal) const {
      assert(!IsEmpty && "Range is empty.");
      return IntVal >= Low && IntVal <= High;      
    }    
  
    SubRes sub(const IntRange &RHS) const {
      SubRes Res;
      
      // RHS is either more global and includes this range or
      // if it doesn't intersected with this range.
      if (!isInRange(RHS.Low) && !isInRange(RHS.High)) {
        
        // If RHS more global (it is enough to check
        // only one border in this case.
        if (RHS.isInRange(Low))
          return std::make_pair(IntRange(Low, High), IntRange()); 
        
        return Res;
      }
      
      if (Low < RHS.Low) {
        Res.first.Low = Low;
        IntItem NewHigh = RHS.Low;
        --NewHigh;
        Res.first.High = NewHigh;
      }
      if (High > RHS.High) {
        IntItem NewLow = RHS.High;
        ++NewLow;
        Res.second.Low = NewLow;
        Res.second.High = High;
      }
      return Res;      
    }
  };      

//===----------------------------------------------------------------------===//
/// ConstantRangesSet - class that implements constant set of ranges.
/// It is a wrapper for some real "holder" class (currently ConstantArray).
/// It contains functions, that allows to parse "holder" like a set of ranges.
/// Note: It is assumed that "holder" is inherited from Constant object.
///       ConstantRangesSet may be converted to and from Constant* pointer.
///
class IntegersSubset {
  Constant *Array;
public:
  
  bool IsWide;
  
  // implicit
  IntegersSubset(Constant *V) : Array(V) {
    ArrayType *ArrTy = cast<ArrayType>(Array->getType());
    VectorType *VecTy = cast<VectorType>(ArrTy->getElementType());
    IntegerType *IntTy = cast<IntegerType>(VecTy->getElementType());
    IsWide = IntTy->getBitWidth() > 64;    
  }
  
  operator Constant*() { return Array; }
  operator const Constant*() const { return Array; }
  Constant *operator->() { return Array; }
  const Constant *operator->() const { return Array; }
  
  typedef IntRange Range;
 
  /// Checks is the given constant satisfies this case. Returns
  /// true if it equals to one of contained values or belongs to the one of
  /// contained ranges.
  bool isSatisfies(const IntItem &CheckingVal) const {
    for (unsigned i = 0, e = getNumItems(); i < e; ++i) {
      const Constant *CV = Array->getAggregateElement(i);
      unsigned VecSize = cast<VectorType>(CV->getType())->getNumElements();
      switch (VecSize) {
      case 1:
        if (cast<const ConstantInt>(CV->getAggregateElement(0U))->getValue() ==
            CheckingVal)
          return true;
        break;
      case 2: {
        const APInt &Lo =
            cast<const ConstantInt>(CV->getAggregateElement(0U))->getValue();
        const APInt &Hi =
            cast<const ConstantInt>(CV->getAggregateElement(1))->getValue();
        if (Lo.uge(CheckingVal) && Hi.ule(CheckingVal))
          return true;
      }
        break;
      default:
        assert(0 && "Only pairs and single numbers are allowed here.");
        break;
      }
    }
    return false;    
  }
  
  /// Returns set's item with given index.
  Range getItem(unsigned idx) {
    Constant *CV = Array->getAggregateElement(idx);
    unsigned NumEls = cast<VectorType>(CV->getType())->getNumElements();
    switch (NumEls) {
    case 1:
      return Range(IntItem::fromConstantInt(
                    cast<ConstantInt>(CV->getAggregateElement(0U))));
    case 2:
      return Range(IntItem::fromConstantInt(
                     cast<ConstantInt>(CV->getAggregateElement(0U))),
                   IntItem::fromConstantInt(
                     cast<ConstantInt>(CV->getAggregateElement(1U))));
    default:
      assert(0 && "Only pairs and single numbers are allowed here.");
      return Range();
    }    
  }
  
  const Range getItem(unsigned idx) const {
    const Constant *CV = Array->getAggregateElement(idx);
    
    unsigned NumEls = cast<VectorType>(CV->getType())->getNumElements();
    switch (NumEls) {
    case 1:
      return Range(IntItem::fromConstantInt(
                     cast<ConstantInt>(CV->getAggregateElement(0U))),
                   IntItem::fromConstantInt(cast<ConstantInt>(
                     cast<ConstantInt>(CV->getAggregateElement(0U)))));
    case 2:
      return Range(IntItem::fromConstantInt(
                     cast<ConstantInt>(CV->getAggregateElement(0U))),
                   IntItem::fromConstantInt(
                   cast<ConstantInt>(CV->getAggregateElement(1))));
    default:
      assert(0 && "Only pairs and single numbers are allowed here.");
      return Range();
    }    
  }
  
  /// Return number of items (ranges) stored in set.
  unsigned getNumItems() const {
    return cast<ArrayType>(Array->getType())->getNumElements();
  }
  
  bool isWideNumberFormat() const { return IsWide; }
  
  bool isSingleNumber(unsigned idx) const {
    Constant *CV = Array->getAggregateElement(idx);
    return cast<VectorType>(CV->getType())->getNumElements() == 1;
  }
  
  /// Returns set the size, that equals number of all values + sizes of all
  /// ranges.
  /// Ranges set is considered as flat numbers collection.
  /// E.g.: for range [<0>, <1>, <4,8>] the size will 7;
  ///       for range [<0>, <1>, <5>] the size will 3
  unsigned getSize() const {
    APInt sz(((const APInt&)getItem(0).Low).getBitWidth(), 0);
    for (unsigned i = 0, e = getNumItems(); i != e; ++i) {
      const APInt &Low = getItem(i).Low;
      const APInt &High = getItem(i).High;
      const APInt &S = High - Low;
      sz += S;
    }
    return sz.getZExtValue();    
  }
  
  /// Allows to access single value even if it belongs to some range.
  /// Ranges set is considered as flat numbers collection.
  /// [<1>, <4,8>] is considered as [1,4,5,6,7,8] 
  /// For range [<1>, <4,8>] getSingleValue(3) returns 6.
  APInt getSingleValue(unsigned idx) const {
    APInt sz(((const APInt&)getItem(0).Low).getBitWidth(), 0);
    for (unsigned i = 0, e = getNumItems(); i != e; ++i) {
      const APInt &Low = getItem(i).Low;
      const APInt &High = getItem(i).High;      
      const APInt& S = High - Low;
      APInt oldSz = sz;
      sz += S;
      if (oldSz.uge(i) && sz.ult(i)) {
        APInt Res = Low;
        APInt Offset(oldSz.getBitWidth(), i);
        Offset -= oldSz;
        Res += Offset;
        return Res;
      }
    }
    assert(0 && "Index exceeds high border.");
    return sz;    
  }
};  

}

#endif /* CONSTANTRANGESSET_H_ */
