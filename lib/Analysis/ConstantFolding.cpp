//===-- ConstantFolding.cpp - Fold instructions into constants ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines routines for folding instructions into constants.
//
// Also, to supplement the basic IR ConstantExpr simplifications,
// this file defines some additional folding routines that can make use of
// DataLayout information. These functions cannot go in IR due to library
// dependency issues.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/Config/config.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GetElementPtrTypeIterator.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Operator.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include <cassert>
#include <cerrno>
#include <cfenv>
#include <cmath>
#include <limits>

using namespace llvm;

namespace {

//===----------------------------------------------------------------------===//
// Constant Folding internal helper functions
//===----------------------------------------------------------------------===//

/// Constant fold bitcast, symbolically evaluating it with DataLayout.
/// This always returns a non-null constant, but it may be a
/// ConstantExpr if unfoldable.
Constant *FoldBitCast(Constant *C, Type *DestTy, const DataLayout &DL) {
  // Catch the obvious splat cases.
  if (C->isNullValue() && !DestTy->isX86_MMXTy())
    return Constant::getNullValue(DestTy);
  if (C->isAllOnesValue() && !DestTy->isX86_MMXTy() &&
      !DestTy->isPtrOrPtrVectorTy()) // Don't get ones for ptr types!
    return Constant::getAllOnesValue(DestTy);

  // Handle a vector->integer cast.
  if (auto *IT = dyn_cast<IntegerType>(DestTy)) {
    auto *VTy = dyn_cast<VectorType>(C->getType());
    if (!VTy)
      return ConstantExpr::getBitCast(C, DestTy);

    unsigned NumSrcElts = VTy->getNumElements();
    Type *SrcEltTy = VTy->getElementType();

    // If the vector is a vector of floating point, convert it to vector of int
    // to simplify things.
    if (SrcEltTy->isFloatingPointTy()) {
      unsigned FPWidth = SrcEltTy->getPrimitiveSizeInBits();
      Type *SrcIVTy =
        VectorType::get(IntegerType::get(C->getContext(), FPWidth), NumSrcElts);
      // Ask IR to do the conversion now that #elts line up.
      C = ConstantExpr::getBitCast(C, SrcIVTy);
    }

    // Now that we know that the input value is a vector of integers, just shift
    // and insert them into our result.
    unsigned BitShift = DL.getTypeSizeInBits(SrcEltTy);
    APInt Result(IT->getBitWidth(), 0);
    for (unsigned i = 0; i != NumSrcElts; ++i) {
      Constant *Element;
      if (DL.isLittleEndian())
        Element = C->getAggregateElement(NumSrcElts-i-1);
      else
        Element = C->getAggregateElement(i);

      auto *ElementCI = dyn_cast_or_null<ConstantInt>(Element);
      if (!ElementCI)
        return ConstantExpr::getBitCast(C, DestTy);

      Result <<= BitShift;
      Result |= ElementCI->getValue().zextOrSelf(IT->getBitWidth());
    }

    return ConstantInt::get(IT, Result);
  }

  // The code below only handles casts to vectors currently.
  auto *DestVTy = dyn_cast<VectorType>(DestTy);
  if (!DestVTy)
    return ConstantExpr::getBitCast(C, DestTy);

  // If this is a scalar -> vector cast, convert the input into a <1 x scalar>
  // vector so the code below can handle it uniformly.
  if (isa<ConstantFP>(C) || isa<ConstantInt>(C)) {
    Constant *Ops = C; // don't take the address of C!
    return FoldBitCast(ConstantVector::get(Ops), DestTy, DL);
  }

  // If this is a bitcast from constant vector -> vector, fold it.
  if (!isa<ConstantDataVector>(C) && !isa<ConstantVector>(C))
    return ConstantExpr::getBitCast(C, DestTy);

  // If the element types match, IR can fold it.
  unsigned NumDstElt = DestVTy->getNumElements();
  unsigned NumSrcElt = C->getType()->getVectorNumElements();
  if (NumDstElt == NumSrcElt)
    return ConstantExpr::getBitCast(C, DestTy);

  Type *SrcEltTy = C->getType()->getVectorElementType();
  Type *DstEltTy = DestVTy->getElementType();

  // Otherwise, we're changing the number of elements in a vector, which
  // requires endianness information to do the right thing.  For example,
  //    bitcast (<2 x i64> <i64 0, i64 1> to <4 x i32>)
  // folds to (little endian):
  //    <4 x i32> <i32 0, i32 0, i32 1, i32 0>
  // and to (big endian):
  //    <4 x i32> <i32 0, i32 0, i32 0, i32 1>

  // First thing is first.  We only want to think about integer here, so if
  // we have something in FP form, recast it as integer.
  if (DstEltTy->isFloatingPointTy()) {
    // Fold to an vector of integers with same size as our FP type.
    unsigned FPWidth = DstEltTy->getPrimitiveSizeInBits();
    Type *DestIVTy =
      VectorType::get(IntegerType::get(C->getContext(), FPWidth), NumDstElt);
    // Recursively handle this integer conversion, if possible.
    C = FoldBitCast(C, DestIVTy, DL);

    // Finally, IR can handle this now that #elts line up.
    return ConstantExpr::getBitCast(C, DestTy);
  }

  // Okay, we know the destination is integer, if the input is FP, convert
  // it to integer first.
  if (SrcEltTy->isFloatingPointTy()) {
    unsigned FPWidth = SrcEltTy->getPrimitiveSizeInBits();
    Type *SrcIVTy =
      VectorType::get(IntegerType::get(C->getContext(), FPWidth), NumSrcElt);
    // Ask IR to do the conversion now that #elts line up.
    C = ConstantExpr::getBitCast(C, SrcIVTy);
    // If IR wasn't able to fold it, bail out.
    if (!isa<ConstantVector>(C) &&  // FIXME: Remove ConstantVector.
        !isa<ConstantDataVector>(C))
      return C;
  }

  // Now we know that the input and output vectors are both integer vectors
  // of the same size, and that their #elements is not the same.  Do the
  // conversion here, which depends on whether the input or output has
  // more elements.
  bool isLittleEndian = DL.isLittleEndian();

  SmallVector<Constant*, 32> Result;
  if (NumDstElt < NumSrcElt) {
    // Handle: bitcast (<4 x i32> <i32 0, i32 1, i32 2, i32 3> to <2 x i64>)
    Constant *Zero = Constant::getNullValue(DstEltTy);
    unsigned Ratio = NumSrcElt/NumDstElt;
    unsigned SrcBitSize = SrcEltTy->getPrimitiveSizeInBits();
    unsigned SrcElt = 0;
    for (unsigned i = 0; i != NumDstElt; ++i) {
      // Build each element of the result.
      Constant *Elt = Zero;
      unsigned ShiftAmt = isLittleEndian ? 0 : SrcBitSize*(Ratio-1);
      for (unsigned j = 0; j != Ratio; ++j) {
        Constant *Src = dyn_cast<ConstantInt>(C->getAggregateElement(SrcElt++));
        if (!Src)  // Reject constantexpr elements.
          return ConstantExpr::getBitCast(C, DestTy);

        // Zero extend the element to the right size.
        Src = ConstantExpr::getZExt(Src, Elt->getType());

        // Shift it to the right place, depending on endianness.
        Src = ConstantExpr::getShl(Src,
                                   ConstantInt::get(Src->getType(), ShiftAmt));
        ShiftAmt += isLittleEndian ? SrcBitSize : -SrcBitSize;

        // Mix it in.
        Elt = ConstantExpr::getOr(Elt, Src);
      }
      Result.push_back(Elt);
    }
    return ConstantVector::get(Result);
  }

  // Handle: bitcast (<2 x i64> <i64 0, i64 1> to <4 x i32>)
  unsigned Ratio = NumDstElt/NumSrcElt;
  unsigned DstBitSize = DL.getTypeSizeInBits(DstEltTy);

  // Loop over each source value, expanding into multiple results.
  for (unsigned i = 0; i != NumSrcElt; ++i) {
    auto *Src = dyn_cast<ConstantInt>(C->getAggregateElement(i));
    if (!Src)  // Reject constantexpr elements.
      return ConstantExpr::getBitCast(C, DestTy);

    unsigned ShiftAmt = isLittleEndian ? 0 : DstBitSize*(Ratio-1);
    for (unsigned j = 0; j != Ratio; ++j) {
      // Shift the piece of the value into the right place, depending on
      // endianness.
      Constant *Elt = ConstantExpr::getLShr(Src,
                                  ConstantInt::get(Src->getType(), ShiftAmt));
      ShiftAmt += isLittleEndian ? DstBitSize : -DstBitSize;

      // Truncate the element to an integer with the same pointer size and
      // convert the element back to a pointer using a inttoptr.
      if (DstEltTy->isPointerTy()) {
        IntegerType *DstIntTy = Type::getIntNTy(C->getContext(), DstBitSize);
        Constant *CE = ConstantExpr::getTrunc(Elt, DstIntTy);
        Result.push_back(ConstantExpr::getIntToPtr(CE, DstEltTy));
        continue;
      }

      // Truncate and remember this piece.
      Result.push_back(ConstantExpr::getTrunc(Elt, DstEltTy));
    }
  }

  return ConstantVector::get(Result);
}

} // end anonymous namespace

/// If this constant is a constant offset from a global, return the global and
/// the constant. Because of constantexprs, this function is recursive.
bool llvm::IsConstantOffsetFromGlobal(Constant *C, GlobalValue *&GV,
                                      APInt &Offset, const DataLayout &DL) {
  // Trivial case, constant is the global.
  if ((GV = dyn_cast<GlobalValue>(C))) {
    unsigned BitWidth = DL.getPointerTypeSizeInBits(GV->getType());
    Offset = APInt(BitWidth, 0);
    return true;
  }

  // Otherwise, if this isn't a constant expr, bail out.
  auto *CE = dyn_cast<ConstantExpr>(C);
  if (!CE) return false;

  // Look through ptr->int and ptr->ptr casts.
  if (CE->getOpcode() == Instruction::PtrToInt ||
      CE->getOpcode() == Instruction::BitCast)
    return IsConstantOffsetFromGlobal(CE->getOperand(0), GV, Offset, DL);

  // i32* getelementptr ([5 x i32]* @a, i32 0, i32 5)
  auto *GEP = dyn_cast<GEPOperator>(CE);
  if (!GEP)
    return false;

  unsigned BitWidth = DL.getPointerTypeSizeInBits(GEP->getType());
  APInt TmpOffset(BitWidth, 0);

  // If the base isn't a global+constant, we aren't either.
  if (!IsConstantOffsetFromGlobal(CE->getOperand(0), GV, TmpOffset, DL))
    return false;

  // Otherwise, add any offset that our operands provide.
  if (!GEP->accumulateConstantOffset(DL, TmpOffset))
    return false;

  Offset = TmpOffset;
  return true;
}

namespace {

/// Recursive helper to read bits out of global. C is the constant being copied
/// out of. ByteOffset is an offset into C. CurPtr is the pointer to copy
/// results into and BytesLeft is the number of bytes left in
/// the CurPtr buffer. DL is the DataLayout.
bool ReadDataFromGlobal(Constant *C, uint64_t ByteOffset, unsigned char *CurPtr,
                        unsigned BytesLeft, const DataLayout &DL) {
  assert(ByteOffset <= DL.getTypeAllocSize(C->getType()) &&
         "Out of range access");

  // If this element is zero or undefined, we can just return since *CurPtr is
  // zero initialized.
  if (isa<ConstantAggregateZero>(C) || isa<UndefValue>(C))
    return true;

  if (auto *CI = dyn_cast<ConstantInt>(C)) {
    if (CI->getBitWidth() > 64 ||
        (CI->getBitWidth() & 7) != 0)
      return false;

    uint64_t Val = CI->getZExtValue();
    unsigned IntBytes = unsigned(CI->getBitWidth()/8);

    for (unsigned i = 0; i != BytesLeft && ByteOffset != IntBytes; ++i) {
      int n = ByteOffset;
      if (!DL.isLittleEndian())
        n = IntBytes - n - 1;
      CurPtr[i] = (unsigned char)(Val >> (n * 8));
      ++ByteOffset;
    }
    return true;
  }

  if (auto *CFP = dyn_cast<ConstantFP>(C)) {
    if (CFP->getType()->isDoubleTy()) {
      C = FoldBitCast(C, Type::getInt64Ty(C->getContext()), DL);
      return ReadDataFromGlobal(C, ByteOffset, CurPtr, BytesLeft, DL);
    }
    if (CFP->getType()->isFloatTy()){
      C = FoldBitCast(C, Type::getInt32Ty(C->getContext()), DL);
      return ReadDataFromGlobal(C, ByteOffset, CurPtr, BytesLeft, DL);
    }
    if (CFP->getType()->isHalfTy()){
      C = FoldBitCast(C, Type::getInt16Ty(C->getContext()), DL);
      return ReadDataFromGlobal(C, ByteOffset, CurPtr, BytesLeft, DL);
    }
    return false;
  }

  if (auto *CS = dyn_cast<ConstantStruct>(C)) {
    const StructLayout *SL = DL.getStructLayout(CS->getType());
    unsigned Index = SL->getElementContainingOffset(ByteOffset);
    uint64_t CurEltOffset = SL->getElementOffset(Index);
    ByteOffset -= CurEltOffset;

    while (1) {
      // If the element access is to the element itself and not to tail padding,
      // read the bytes from the element.
      uint64_t EltSize = DL.getTypeAllocSize(CS->getOperand(Index)->getType());

      if (ByteOffset < EltSize &&
          !ReadDataFromGlobal(CS->getOperand(Index), ByteOffset, CurPtr,
                              BytesLeft, DL))
        return false;

      ++Index;

      // Check to see if we read from the last struct element, if so we're done.
      if (Index == CS->getType()->getNumElements())
        return true;

      // If we read all of the bytes we needed from this element we're done.
      uint64_t NextEltOffset = SL->getElementOffset(Index);

      if (BytesLeft <= NextEltOffset - CurEltOffset - ByteOffset)
        return true;

      // Move to the next element of the struct.
      CurPtr += NextEltOffset - CurEltOffset - ByteOffset;
      BytesLeft -= NextEltOffset - CurEltOffset - ByteOffset;
      ByteOffset = 0;
      CurEltOffset = NextEltOffset;
    }
    // not reached.
  }

  if (isa<ConstantArray>(C) || isa<ConstantVector>(C) ||
      isa<ConstantDataSequential>(C)) {
    Type *EltTy = C->getType()->getSequentialElementType();
    uint64_t EltSize = DL.getTypeAllocSize(EltTy);
    uint64_t Index = ByteOffset / EltSize;
    uint64_t Offset = ByteOffset - Index * EltSize;
    uint64_t NumElts;
    if (auto *AT = dyn_cast<ArrayType>(C->getType()))
      NumElts = AT->getNumElements();
    else
      NumElts = C->getType()->getVectorNumElements();

    for (; Index != NumElts; ++Index) {
      if (!ReadDataFromGlobal(C->getAggregateElement(Index), Offset, CurPtr,
                              BytesLeft, DL))
        return false;

      uint64_t BytesWritten = EltSize - Offset;
      assert(BytesWritten <= EltSize && "Not indexing into this element?");
      if (BytesWritten >= BytesLeft)
        return true;

      Offset = 0;
      BytesLeft -= BytesWritten;
      CurPtr += BytesWritten;
    }
    return true;
  }

  if (auto *CE = dyn_cast<ConstantExpr>(C)) {
    if (CE->getOpcode() == Instruction::IntToPtr &&
        CE->getOperand(0)->getType() == DL.getIntPtrType(CE->getType())) {
      return ReadDataFromGlobal(CE->getOperand(0), ByteOffset, CurPtr,
                                BytesLeft, DL);
    }
  }

  // Otherwise, unknown initializer type.
  return false;
}

Constant *FoldReinterpretLoadFromConstPtr(Constant *C, Type *LoadTy,
                                          const DataLayout &DL) {
  auto *PTy = cast<PointerType>(C->getType());
  auto *IntType = dyn_cast<IntegerType>(LoadTy);

  // If this isn't an integer load we can't fold it directly.
  if (!IntType) {
    unsigned AS = PTy->getAddressSpace();

    // If this is a float/double load, we can try folding it as an int32/64 load
    // and then bitcast the result.  This can be useful for union cases.  Note
    // that address spaces don't matter here since we're not going to result in
    // an actual new load.
    Type *MapTy;
    if (LoadTy->isHalfTy())
      MapTy = Type::getInt16Ty(C->getContext());
    else if (LoadTy->isFloatTy())
      MapTy = Type::getInt32Ty(C->getContext());
    else if (LoadTy->isDoubleTy())
      MapTy = Type::getInt64Ty(C->getContext());
    else if (LoadTy->isVectorTy()) {
      MapTy = PointerType::getIntNTy(C->getContext(),
                                     DL.getTypeAllocSizeInBits(LoadTy));
    } else
      return nullptr;

    C = FoldBitCast(C, MapTy->getPointerTo(AS), DL);
    if (Constant *Res = FoldReinterpretLoadFromConstPtr(C, MapTy, DL))
      return FoldBitCast(Res, LoadTy, DL);
    return nullptr;
  }

  unsigned BytesLoaded = (IntType->getBitWidth() + 7) / 8;
  if (BytesLoaded > 32 || BytesLoaded == 0)
    return nullptr;

  GlobalValue *GVal;
  APInt OffsetAI;
  if (!IsConstantOffsetFromGlobal(C, GVal, OffsetAI, DL))
    return nullptr;

  auto *GV = dyn_cast<GlobalVariable>(GVal);
  if (!GV || !GV->isConstant() || !GV->hasDefinitiveInitializer() ||
      !GV->getInitializer()->getType()->isSized())
    return nullptr;

  int64_t Offset = OffsetAI.getSExtValue();
  int64_t InitializerSize = DL.getTypeAllocSize(GV->getInitializer()->getType());

  // If we're not accessing anything in this constant, the result is undefined.
  if (Offset + BytesLoaded <= 0)
    return UndefValue::get(IntType);

  // If we're not accessing anything in this constant, the result is undefined.
  if (Offset >= InitializerSize)
    return UndefValue::get(IntType);

  unsigned char RawBytes[32] = {0};
  unsigned char *CurPtr = RawBytes;
  unsigned BytesLeft = BytesLoaded;

  // If we're loading off the beginning of the global, some bytes may be valid.
  if (Offset < 0) {
    CurPtr += -Offset;
    BytesLeft += Offset;
    Offset = 0;
  }

  if (!ReadDataFromGlobal(GV->getInitializer(), Offset, CurPtr, BytesLeft, DL))
    return nullptr;

  APInt ResultVal = APInt(IntType->getBitWidth(), 0);
  if (DL.isLittleEndian()) {
    ResultVal = RawBytes[BytesLoaded - 1];
    for (unsigned i = 1; i != BytesLoaded; ++i) {
      ResultVal <<= 8;
      ResultVal |= RawBytes[BytesLoaded - 1 - i];
    }
  } else {
    ResultVal = RawBytes[0];
    for (unsigned i = 1; i != BytesLoaded; ++i) {
      ResultVal <<= 8;
      ResultVal |= RawBytes[i];
    }
  }

  return ConstantInt::get(IntType->getContext(), ResultVal);
}

Constant *ConstantFoldLoadThroughBitcast(ConstantExpr *CE, Type *DestTy,
                                         const DataLayout &DL) {
  auto *SrcPtr = CE->getOperand(0);
  auto *SrcPtrTy = dyn_cast<PointerType>(SrcPtr->getType());
  if (!SrcPtrTy)
    return nullptr;
  Type *SrcTy = SrcPtrTy->getPointerElementType();

  Constant *C = ConstantFoldLoadFromConstPtr(SrcPtr, SrcTy, DL);
  if (!C)
    return nullptr;

  do {
    Type *SrcTy = C->getType();

    // If the type sizes are the same and a cast is legal, just directly
    // cast the constant.
    if (DL.getTypeSizeInBits(DestTy) == DL.getTypeSizeInBits(SrcTy)) {
      Instruction::CastOps Cast = Instruction::BitCast;
      // If we are going from a pointer to int or vice versa, we spell the cast
      // differently.
      if (SrcTy->isIntegerTy() && DestTy->isPointerTy())
        Cast = Instruction::IntToPtr;
      else if (SrcTy->isPointerTy() && DestTy->isIntegerTy())
        Cast = Instruction::PtrToInt;

      if (CastInst::castIsValid(Cast, C, DestTy))
        return ConstantExpr::getCast(Cast, C, DestTy);
    }

    // If this isn't an aggregate type, there is nothing we can do to drill down
    // and find a bitcastable constant.
    if (!SrcTy->isAggregateType())
      return nullptr;

    // We're simulating a load through a pointer that was bitcast to point to
    // a different type, so we can try to walk down through the initial
    // elements of an aggregate to see if some part of th e aggregate is
    // castable to implement the "load" semantic model.
    C = C->getAggregateElement(0u);
  } while (C);

  return nullptr;
}

} // end anonymous namespace

Constant *llvm::ConstantFoldLoadFromConstPtr(Constant *C, Type *Ty,
                                             const DataLayout &DL) {
  // First, try the easy cases:
  if (auto *GV = dyn_cast<GlobalVariable>(C))
    if (GV->isConstant() && GV->hasDefinitiveInitializer())
      return GV->getInitializer();

  if (auto *GA = dyn_cast<GlobalAlias>(C))
    if (GA->getAliasee() && !GA->isInterposable())
      return ConstantFoldLoadFromConstPtr(GA->getAliasee(), Ty, DL);

  // If the loaded value isn't a constant expr, we can't handle it.
  auto *CE = dyn_cast<ConstantExpr>(C);
  if (!CE)
    return nullptr;

  if (CE->getOpcode() == Instruction::GetElementPtr) {
    if (auto *GV = dyn_cast<GlobalVariable>(CE->getOperand(0))) {
      if (GV->isConstant() && GV->hasDefinitiveInitializer()) {
        if (Constant *V =
             ConstantFoldLoadThroughGEPConstantExpr(GV->getInitializer(), CE))
          return V;
      }
    }
  }

  if (CE->getOpcode() == Instruction::BitCast)
    if (Constant *LoadedC = ConstantFoldLoadThroughBitcast(CE, Ty, DL))
      return LoadedC;

  // Instead of loading constant c string, use corresponding integer value
  // directly if string length is small enough.
  StringRef Str;
  if (getConstantStringInfo(CE, Str) && !Str.empty()) {
    size_t StrLen = Str.size();
    unsigned NumBits = Ty->getPrimitiveSizeInBits();
    // Replace load with immediate integer if the result is an integer or fp
    // value.
    if ((NumBits >> 3) == StrLen + 1 && (NumBits & 7) == 0 &&
        (isa<IntegerType>(Ty) || Ty->isFloatingPointTy())) {
      APInt StrVal(NumBits, 0);
      APInt SingleChar(NumBits, 0);
      if (DL.isLittleEndian()) {
        for (unsigned char C : reverse(Str.bytes())) {
          SingleChar = static_cast<uint64_t>(C);
          StrVal = (StrVal << 8) | SingleChar;
        }
      } else {
        for (unsigned char C : Str.bytes()) {
          SingleChar = static_cast<uint64_t>(C);
          StrVal = (StrVal << 8) | SingleChar;
        }
        // Append NULL at the end.
        SingleChar = 0;
        StrVal = (StrVal << 8) | SingleChar;
      }

      Constant *Res = ConstantInt::get(CE->getContext(), StrVal);
      if (Ty->isFloatingPointTy())
        Res = ConstantExpr::getBitCast(Res, Ty);
      return Res;
    }
  }

  // If this load comes from anywhere in a constant global, and if the global
  // is all undef or zero, we know what it loads.
  if (auto *GV = dyn_cast<GlobalVariable>(GetUnderlyingObject(CE, DL))) {
    if (GV->isConstant() && GV->hasDefinitiveInitializer()) {
      if (GV->getInitializer()->isNullValue())
        return Constant::getNullValue(Ty);
      if (isa<UndefValue>(GV->getInitializer()))
        return UndefValue::get(Ty);
    }
  }

  // Try hard to fold loads from bitcasted strange and non-type-safe things.
  return FoldReinterpretLoadFromConstPtr(CE, Ty, DL);
}

namespace {

Constant *ConstantFoldLoadInst(const LoadInst *LI, const DataLayout &DL) {
  if (LI->isVolatile()) return nullptr;

  if (auto *C = dyn_cast<Constant>(LI->getOperand(0)))
    return ConstantFoldLoadFromConstPtr(C, LI->getType(), DL);

  return nullptr;
}

/// One of Op0/Op1 is a constant expression.
/// Attempt to symbolically evaluate the result of a binary operator merging
/// these together.  If target data info is available, it is provided as DL,
/// otherwise DL is null.
Constant *SymbolicallyEvaluateBinop(unsigned Opc, Constant *Op0, Constant *Op1,
                                    const DataLayout &DL) {
  // SROA

  // Fold (and 0xffffffff00000000, (shl x, 32)) -> shl.
  // Fold (lshr (or X, Y), 32) -> (lshr [X/Y], 32) if one doesn't contribute
  // bits.

  if (Opc == Instruction::And) {
    unsigned BitWidth = DL.getTypeSizeInBits(Op0->getType()->getScalarType());
    APInt KnownZero0(BitWidth, 0), KnownOne0(BitWidth, 0);
    APInt KnownZero1(BitWidth, 0), KnownOne1(BitWidth, 0);
    computeKnownBits(Op0, KnownZero0, KnownOne0, DL);
    computeKnownBits(Op1, KnownZero1, KnownOne1, DL);
    if ((KnownOne1 | KnownZero0).isAllOnesValue()) {
      // All the bits of Op0 that the 'and' could be masking are already zero.
      return Op0;
    }
    if ((KnownOne0 | KnownZero1).isAllOnesValue()) {
      // All the bits of Op1 that the 'and' could be masking are already zero.
      return Op1;
    }

    APInt KnownZero = KnownZero0 | KnownZero1;
    APInt KnownOne = KnownOne0 & KnownOne1;
    if ((KnownZero | KnownOne).isAllOnesValue()) {
      return ConstantInt::get(Op0->getType(), KnownOne);
    }
  }

  // If the constant expr is something like &A[123] - &A[4].f, fold this into a
  // constant.  This happens frequently when iterating over a global array.
  if (Opc == Instruction::Sub) {
    GlobalValue *GV1, *GV2;
    APInt Offs1, Offs2;

    if (IsConstantOffsetFromGlobal(Op0, GV1, Offs1, DL))
      if (IsConstantOffsetFromGlobal(Op1, GV2, Offs2, DL) && GV1 == GV2) {
        unsigned OpSize = DL.getTypeSizeInBits(Op0->getType());

        // (&GV+C1) - (&GV+C2) -> C1-C2, pointer arithmetic cannot overflow.
        // PtrToInt may change the bitwidth so we have convert to the right size
        // first.
        return ConstantInt::get(Op0->getType(), Offs1.zextOrTrunc(OpSize) -
                                                Offs2.zextOrTrunc(OpSize));
      }
  }

  return nullptr;
}

/// If array indices are not pointer-sized integers, explicitly cast them so
/// that they aren't implicitly casted by the getelementptr.
Constant *CastGEPIndices(Type *SrcElemTy, ArrayRef<Constant *> Ops,
                         Type *ResultTy, const DataLayout &DL,
                         const TargetLibraryInfo *TLI) {
  Type *IntPtrTy = DL.getIntPtrType(ResultTy);

  bool Any = false;
  SmallVector<Constant*, 32> NewIdxs;
  for (unsigned i = 1, e = Ops.size(); i != e; ++i) {
    if ((i == 1 ||
         !isa<StructType>(GetElementPtrInst::getIndexedType(SrcElemTy,
             Ops.slice(1, i - 1)))) &&
        Ops[i]->getType() != IntPtrTy) {
      Any = true;
      NewIdxs.push_back(ConstantExpr::getCast(CastInst::getCastOpcode(Ops[i],
                                                                      true,
                                                                      IntPtrTy,
                                                                      true),
                                              Ops[i], IntPtrTy));
    } else
      NewIdxs.push_back(Ops[i]);
  }

  if (!Any)
    return nullptr;

  Constant *C = ConstantExpr::getGetElementPtr(SrcElemTy, Ops[0], NewIdxs);
  if (Constant *Folded = ConstantFoldConstant(C, DL, TLI))
    C = Folded;

  return C;
}

/// Strip the pointer casts, but preserve the address space information.
Constant* StripPtrCastKeepAS(Constant* Ptr, Type *&ElemTy) {
  assert(Ptr->getType()->isPointerTy() && "Not a pointer type");
  auto *OldPtrTy = cast<PointerType>(Ptr->getType());
  Ptr = Ptr->stripPointerCasts();
  auto *NewPtrTy = cast<PointerType>(Ptr->getType());

  ElemTy = NewPtrTy->getPointerElementType();

  // Preserve the address space number of the pointer.
  if (NewPtrTy->getAddressSpace() != OldPtrTy->getAddressSpace()) {
    NewPtrTy = ElemTy->getPointerTo(OldPtrTy->getAddressSpace());
    Ptr = ConstantExpr::getPointerCast(Ptr, NewPtrTy);
  }
  return Ptr;
}

/// If we can symbolically evaluate the GEP constant expression, do so.
Constant *SymbolicallyEvaluateGEP(const GEPOperator *GEP,
                                  ArrayRef<Constant *> Ops,
                                  const DataLayout &DL,
                                  const TargetLibraryInfo *TLI) {
  Type *SrcElemTy = GEP->getSourceElementType();
  Type *ResElemTy = GEP->getResultElementType();
  Type *ResTy = GEP->getType();
  if (!SrcElemTy->isSized())
    return nullptr;

  if (Constant *C = CastGEPIndices(SrcElemTy, Ops, ResTy, DL, TLI))
    return C;

  Constant *Ptr = Ops[0];
  if (!Ptr->getType()->isPointerTy())
    return nullptr;

  Type *IntPtrTy = DL.getIntPtrType(Ptr->getType());

  // If this is a constant expr gep that is effectively computing an
  // "offsetof", fold it into 'cast int Size to T*' instead of 'gep 0, 0, 12'
  for (unsigned i = 1, e = Ops.size(); i != e; ++i)
    if (!isa<ConstantInt>(Ops[i])) {

      // If this is "gep i8* Ptr, (sub 0, V)", fold this as:
      // "inttoptr (sub (ptrtoint Ptr), V)"
      if (Ops.size() == 2 && ResElemTy->isIntegerTy(8)) {
        auto *CE = dyn_cast<ConstantExpr>(Ops[1]);
        assert((!CE || CE->getType() == IntPtrTy) &&
               "CastGEPIndices didn't canonicalize index types!");
        if (CE && CE->getOpcode() == Instruction::Sub &&
            CE->getOperand(0)->isNullValue()) {
          Constant *Res = ConstantExpr::getPtrToInt(Ptr, CE->getType());
          Res = ConstantExpr::getSub(Res, CE->getOperand(1));
          Res = ConstantExpr::getIntToPtr(Res, ResTy);
          if (auto *FoldedRes = ConstantFoldConstant(Res, DL, TLI))
            Res = FoldedRes;
          return Res;
        }
      }
      return nullptr;
    }

  unsigned BitWidth = DL.getTypeSizeInBits(IntPtrTy);
  APInt Offset =
      APInt(BitWidth,
            DL.getIndexedOffsetInType(
                SrcElemTy,
                makeArrayRef((Value * const *)Ops.data() + 1, Ops.size() - 1)));
  Ptr = StripPtrCastKeepAS(Ptr, SrcElemTy);

  // If this is a GEP of a GEP, fold it all into a single GEP.
  while (auto *GEP = dyn_cast<GEPOperator>(Ptr)) {
    SmallVector<Value *, 4> NestedOps(GEP->op_begin() + 1, GEP->op_end());

    // Do not try the incorporate the sub-GEP if some index is not a number.
    bool AllConstantInt = true;
    for (Value *NestedOp : NestedOps)
      if (!isa<ConstantInt>(NestedOp)) {
        AllConstantInt = false;
        break;
      }
    if (!AllConstantInt)
      break;

    Ptr = cast<Constant>(GEP->getOperand(0));
    SrcElemTy = GEP->getSourceElementType();
    Offset += APInt(BitWidth, DL.getIndexedOffsetInType(SrcElemTy, NestedOps));
    Ptr = StripPtrCastKeepAS(Ptr, SrcElemTy);
  }

  // If the base value for this address is a literal integer value, fold the
  // getelementptr to the resulting integer value casted to the pointer type.
  APInt BasePtr(BitWidth, 0);
  if (auto *CE = dyn_cast<ConstantExpr>(Ptr)) {
    if (CE->getOpcode() == Instruction::IntToPtr) {
      if (auto *Base = dyn_cast<ConstantInt>(CE->getOperand(0)))
        BasePtr = Base->getValue().zextOrTrunc(BitWidth);
    }
  }

  if (Ptr->isNullValue() || BasePtr != 0) {
    Constant *C = ConstantInt::get(Ptr->getContext(), Offset + BasePtr);
    return ConstantExpr::getIntToPtr(C, ResTy);
  }

  // Otherwise form a regular getelementptr. Recompute the indices so that
  // we eliminate over-indexing of the notional static type array bounds.
  // This makes it easy to determine if the getelementptr is "inbounds".
  // Also, this helps GlobalOpt do SROA on GlobalVariables.
  Type *Ty = Ptr->getType();
  assert(Ty->isPointerTy() && "Forming regular GEP of non-pointer type");
  SmallVector<Constant *, 32> NewIdxs;

  do {
    if (!Ty->isStructTy()) {
      if (Ty->isPointerTy()) {
        // The only pointer indexing we'll do is on the first index of the GEP.
        if (!NewIdxs.empty())
          break;

        Ty = SrcElemTy;

        // Only handle pointers to sized types, not pointers to functions.
        if (!Ty->isSized())
          return nullptr;
      } else if (auto *ATy = dyn_cast<SequentialType>(Ty)) {
        Ty = ATy->getElementType();
      } else {
        // We've reached some non-indexable type.
        break;
      }

      // Determine which element of the array the offset points into.
      APInt ElemSize(BitWidth, DL.getTypeAllocSize(Ty));
      if (ElemSize == 0) {
        // The element size is 0. This may be [0 x Ty]*, so just use a zero
        // index for this level and proceed to the next level to see if it can
        // accommodate the offset.
        NewIdxs.push_back(ConstantInt::get(IntPtrTy, 0));
      } else {
        // The element size is non-zero divide the offset by the element
        // size (rounding down), to compute the index at this level.
        bool Overflow;
        APInt NewIdx = Offset.sdiv_ov(ElemSize, Overflow);
        if (Overflow)
          break;
        Offset -= NewIdx * ElemSize;
        NewIdxs.push_back(ConstantInt::get(IntPtrTy, NewIdx));
      }
    } else {
      auto *STy = cast<StructType>(Ty);
      // If we end up with an offset that isn't valid for this struct type, we
      // can't re-form this GEP in a regular form, so bail out. The pointer
      // operand likely went through casts that are necessary to make the GEP
      // sensible.
      const StructLayout &SL = *DL.getStructLayout(STy);
      if (Offset.isNegative() || Offset.uge(SL.getSizeInBytes()))
        break;

      // Determine which field of the struct the offset points into. The
      // getZExtValue is fine as we've already ensured that the offset is
      // within the range representable by the StructLayout API.
      unsigned ElIdx = SL.getElementContainingOffset(Offset.getZExtValue());
      NewIdxs.push_back(ConstantInt::get(Type::getInt32Ty(Ty->getContext()),
                                         ElIdx));
      Offset -= APInt(BitWidth, SL.getElementOffset(ElIdx));
      Ty = STy->getTypeAtIndex(ElIdx);
    }
  } while (Ty != ResElemTy);

  // If we haven't used up the entire offset by descending the static
  // type, then the offset is pointing into the middle of an indivisible
  // member, so we can't simplify it.
  if (Offset != 0)
    return nullptr;

  // Create a GEP.
  Constant *C = ConstantExpr::getGetElementPtr(SrcElemTy, Ptr, NewIdxs);
  assert(C->getType()->getPointerElementType() == Ty &&
         "Computed GetElementPtr has unexpected type!");

  // If we ended up indexing a member with a type that doesn't match
  // the type of what the original indices indexed, add a cast.
  if (Ty != ResElemTy)
    C = FoldBitCast(C, ResTy, DL);

  return C;
}

/// Attempt to constant fold an instruction with the
/// specified opcode and operands.  If successful, the constant result is
/// returned, if not, null is returned.  Note that this function can fail when
/// attempting to fold instructions like loads and stores, which have no
/// constant expression form.
///
/// TODO: This function neither utilizes nor preserves nsw/nuw/inbounds/etc
/// information, due to only being passed an opcode and operands. Constant
/// folding using this function strips this information.
///
Constant *ConstantFoldInstOperandsImpl(const Value *InstOrCE, Type *DestTy,
                                       unsigned Opcode,
                                       ArrayRef<Constant *> Ops,
                                       const DataLayout &DL,
                                       const TargetLibraryInfo *TLI) {
  // Handle easy binops first.
  if (Instruction::isBinaryOp(Opcode))
    return ConstantFoldBinaryOpOperands(Opcode, Ops[0], Ops[1], DL);

  if (Instruction::isCast(Opcode))
    return ConstantFoldCastOperand(Opcode, Ops[0], DestTy, DL);

  if (auto *GEP = dyn_cast<GEPOperator>(InstOrCE)) {
    if (Constant *C = SymbolicallyEvaluateGEP(GEP, Ops, DL, TLI))
      return C;

    return ConstantExpr::getGetElementPtr(GEP->getSourceElementType(),
                                          Ops[0], Ops.slice(1));
  }

  switch (Opcode) {
  default: return nullptr;
  case Instruction::ICmp:
  case Instruction::FCmp: llvm_unreachable("Invalid for compares");
  case Instruction::Call:
    if (auto *F = dyn_cast<Function>(Ops.back()))
      if (canConstantFoldCallTo(F))
        return ConstantFoldCall(F, Ops.slice(0, Ops.size() - 1), TLI);
    return nullptr;
  case Instruction::Select:
    return ConstantExpr::getSelect(Ops[0], Ops[1], Ops[2]);
  case Instruction::ExtractElement:
    return ConstantExpr::getExtractElement(Ops[0], Ops[1]);
  case Instruction::InsertElement:
    return ConstantExpr::getInsertElement(Ops[0], Ops[1], Ops[2]);
  case Instruction::ShuffleVector:
    return ConstantExpr::getShuffleVector(Ops[0], Ops[1], Ops[2]);
  }
}

} // end anonymous namespace

//===----------------------------------------------------------------------===//
// Constant Folding public APIs
//===----------------------------------------------------------------------===//

namespace {

Constant *
ConstantFoldConstantImpl(const Constant *C, const DataLayout &DL,
                         const TargetLibraryInfo *TLI,
                         SmallDenseMap<Constant *, Constant *> &FoldedOps) {
  if (!isa<ConstantVector>(C) && !isa<ConstantExpr>(C))
    return nullptr;

  SmallVector<Constant *, 8> Ops;
  for (const Use &NewU : C->operands()) {
    auto *NewC = cast<Constant>(&NewU);
    // Recursively fold the ConstantExpr's operands. If we have already folded
    // a ConstantExpr, we don't have to process it again.
    if (isa<ConstantVector>(NewC) || isa<ConstantExpr>(NewC)) {
      auto It = FoldedOps.find(NewC);
      if (It == FoldedOps.end()) {
        if (auto *FoldedC =
                ConstantFoldConstantImpl(NewC, DL, TLI, FoldedOps)) {
          NewC = FoldedC;
          FoldedOps.insert({NewC, FoldedC});
        } else {
          FoldedOps.insert({NewC, NewC});
        }
      } else {
        NewC = It->second;
      }
    }
    Ops.push_back(NewC);
  }

  if (auto *CE = dyn_cast<ConstantExpr>(C)) {
    if (CE->isCompare())
      return ConstantFoldCompareInstOperands(CE->getPredicate(), Ops[0], Ops[1],
                                             DL, TLI);

    return ConstantFoldInstOperandsImpl(CE, CE->getType(), CE->getOpcode(), Ops,
                                        DL, TLI);
  }

  assert(isa<ConstantVector>(C));
  return ConstantVector::get(Ops);
}

} // end anonymous namespace

Constant *llvm::ConstantFoldInstruction(Instruction *I, const DataLayout &DL,
                                        const TargetLibraryInfo *TLI) {
  // Handle PHI nodes quickly here...
  if (auto *PN = dyn_cast<PHINode>(I)) {
    Constant *CommonValue = nullptr;

    SmallDenseMap<Constant *, Constant *> FoldedOps;
    for (Value *Incoming : PN->incoming_values()) {
      // If the incoming value is undef then skip it.  Note that while we could
      // skip the value if it is equal to the phi node itself we choose not to
      // because that would break the rule that constant folding only applies if
      // all operands are constants.
      if (isa<UndefValue>(Incoming))
        continue;
      // If the incoming value is not a constant, then give up.
      auto *C = dyn_cast<Constant>(Incoming);
      if (!C)
        return nullptr;
      // Fold the PHI's operands.
      if (auto *FoldedC = ConstantFoldConstantImpl(C, DL, TLI, FoldedOps))
        C = FoldedC;
      // If the incoming value is a different constant to
      // the one we saw previously, then give up.
      if (CommonValue && C != CommonValue)
        return nullptr;
      CommonValue = C;
    }

    // If we reach here, all incoming values are the same constant or undef.
    return CommonValue ? CommonValue : UndefValue::get(PN->getType());
  }

  // Scan the operand list, checking to see if they are all constants, if so,
  // hand off to ConstantFoldInstOperandsImpl.
  if (!all_of(I->operands(), [](Use &U) { return isa<Constant>(U); }))
    return nullptr;

  SmallDenseMap<Constant *, Constant *> FoldedOps;
  SmallVector<Constant *, 8> Ops;
  for (const Use &OpU : I->operands()) {
    auto *Op = cast<Constant>(&OpU);
    // Fold the Instruction's operands.
    if (auto *FoldedOp = ConstantFoldConstantImpl(Op, DL, TLI, FoldedOps))
      Op = FoldedOp;

    Ops.push_back(Op);
  }

  if (const auto *CI = dyn_cast<CmpInst>(I))
    return ConstantFoldCompareInstOperands(CI->getPredicate(), Ops[0], Ops[1],
                                           DL, TLI);

  if (const auto *LI = dyn_cast<LoadInst>(I))
    return ConstantFoldLoadInst(LI, DL);

  if (auto *IVI = dyn_cast<InsertValueInst>(I)) {
    return ConstantExpr::getInsertValue(
                                cast<Constant>(IVI->getAggregateOperand()),
                                cast<Constant>(IVI->getInsertedValueOperand()),
                                IVI->getIndices());
  }

  if (auto *EVI = dyn_cast<ExtractValueInst>(I)) {
    return ConstantExpr::getExtractValue(
                                    cast<Constant>(EVI->getAggregateOperand()),
                                    EVI->getIndices());
  }

  return ConstantFoldInstOperands(I, Ops, DL, TLI);
}

Constant *llvm::ConstantFoldConstant(const Constant *C, const DataLayout &DL,
                                     const TargetLibraryInfo *TLI) {
  SmallDenseMap<Constant *, Constant *> FoldedOps;
  return ConstantFoldConstantImpl(C, DL, TLI, FoldedOps);
}

Constant *llvm::ConstantFoldInstOperands(Instruction *I,
                                         ArrayRef<Constant *> Ops,
                                         const DataLayout &DL,
                                         const TargetLibraryInfo *TLI) {
  return ConstantFoldInstOperandsImpl(I, I->getType(), I->getOpcode(), Ops, DL,
                                      TLI);
}

Constant *llvm::ConstantFoldInstOperands(unsigned Opcode, Type *DestTy,
                                         ArrayRef<Constant *> Ops,
                                         const DataLayout &DL,
                                         const TargetLibraryInfo *TLI) {
  assert(Opcode != Instruction::GetElementPtr && "Invalid for GEPs");
  return ConstantFoldInstOperandsImpl(nullptr, DestTy, Opcode, Ops, DL, TLI);
}

Constant *llvm::ConstantFoldCompareInstOperands(unsigned Predicate,
                                                Constant *Ops0, Constant *Ops1,
                                                const DataLayout &DL,
                                                const TargetLibraryInfo *TLI) {
  // fold: icmp (inttoptr x), null         -> icmp x, 0
  // fold: icmp (ptrtoint x), 0            -> icmp x, null
  // fold: icmp (inttoptr x), (inttoptr y) -> icmp trunc/zext x, trunc/zext y
  // fold: icmp (ptrtoint x), (ptrtoint y) -> icmp x, y
  //
  // FIXME: The following comment is out of data and the DataLayout is here now.
  // ConstantExpr::getCompare cannot do this, because it doesn't have DL
  // around to know if bit truncation is happening.
  if (auto *CE0 = dyn_cast<ConstantExpr>(Ops0)) {
    if (Ops1->isNullValue()) {
      if (CE0->getOpcode() == Instruction::IntToPtr) {
        Type *IntPtrTy = DL.getIntPtrType(CE0->getType());
        // Convert the integer value to the right size to ensure we get the
        // proper extension or truncation.
        Constant *C = ConstantExpr::getIntegerCast(CE0->getOperand(0),
                                                   IntPtrTy, false);
        Constant *Null = Constant::getNullValue(C->getType());
        return ConstantFoldCompareInstOperands(Predicate, C, Null, DL, TLI);
      }

      // Only do this transformation if the int is intptrty in size, otherwise
      // there is a truncation or extension that we aren't modeling.
      if (CE0->getOpcode() == Instruction::PtrToInt) {
        Type *IntPtrTy = DL.getIntPtrType(CE0->getOperand(0)->getType());
        if (CE0->getType() == IntPtrTy) {
          Constant *C = CE0->getOperand(0);
          Constant *Null = Constant::getNullValue(C->getType());
          return ConstantFoldCompareInstOperands(Predicate, C, Null, DL, TLI);
        }
      }
    }

    if (auto *CE1 = dyn_cast<ConstantExpr>(Ops1)) {
      if (CE0->getOpcode() == CE1->getOpcode()) {
        if (CE0->getOpcode() == Instruction::IntToPtr) {
          Type *IntPtrTy = DL.getIntPtrType(CE0->getType());

          // Convert the integer value to the right size to ensure we get the
          // proper extension or truncation.
          Constant *C0 = ConstantExpr::getIntegerCast(CE0->getOperand(0),
                                                      IntPtrTy, false);
          Constant *C1 = ConstantExpr::getIntegerCast(CE1->getOperand(0),
                                                      IntPtrTy, false);
          return ConstantFoldCompareInstOperands(Predicate, C0, C1, DL, TLI);
        }

        // Only do this transformation if the int is intptrty in size, otherwise
        // there is a truncation or extension that we aren't modeling.
        if (CE0->getOpcode() == Instruction::PtrToInt) {
          Type *IntPtrTy = DL.getIntPtrType(CE0->getOperand(0)->getType());
          if (CE0->getType() == IntPtrTy &&
              CE0->getOperand(0)->getType() == CE1->getOperand(0)->getType()) {
            return ConstantFoldCompareInstOperands(
                Predicate, CE0->getOperand(0), CE1->getOperand(0), DL, TLI);
          }
        }
      }
    }

    // icmp eq (or x, y), 0 -> (icmp eq x, 0) & (icmp eq y, 0)
    // icmp ne (or x, y), 0 -> (icmp ne x, 0) | (icmp ne y, 0)
    if ((Predicate == ICmpInst::ICMP_EQ || Predicate == ICmpInst::ICMP_NE) &&
        CE0->getOpcode() == Instruction::Or && Ops1->isNullValue()) {
      Constant *LHS = ConstantFoldCompareInstOperands(
          Predicate, CE0->getOperand(0), Ops1, DL, TLI);
      Constant *RHS = ConstantFoldCompareInstOperands(
          Predicate, CE0->getOperand(1), Ops1, DL, TLI);
      unsigned OpC =
        Predicate == ICmpInst::ICMP_EQ ? Instruction::And : Instruction::Or;
      return ConstantFoldBinaryOpOperands(OpC, LHS, RHS, DL);
    }
  }

  return ConstantExpr::getCompare(Predicate, Ops0, Ops1);
}

Constant *llvm::ConstantFoldBinaryOpOperands(unsigned Opcode, Constant *LHS,
                                             Constant *RHS,
                                             const DataLayout &DL) {
  assert(Instruction::isBinaryOp(Opcode));
  if (isa<ConstantExpr>(LHS) || isa<ConstantExpr>(RHS))
    if (Constant *C = SymbolicallyEvaluateBinop(Opcode, LHS, RHS, DL))
      return C;

  return ConstantExpr::get(Opcode, LHS, RHS);
}

Constant *llvm::ConstantFoldCastOperand(unsigned Opcode, Constant *C,
                                        Type *DestTy, const DataLayout &DL) {
  assert(Instruction::isCast(Opcode));
  switch (Opcode) {
  default:
    llvm_unreachable("Missing case");
  case Instruction::PtrToInt:
    // If the input is a inttoptr, eliminate the pair.  This requires knowing
    // the width of a pointer, so it can't be done in ConstantExpr::getCast.
    if (auto *CE = dyn_cast<ConstantExpr>(C)) {
      if (CE->getOpcode() == Instruction::IntToPtr) {
        Constant *Input = CE->getOperand(0);
        unsigned InWidth = Input->getType()->getScalarSizeInBits();
        unsigned PtrWidth = DL.getPointerTypeSizeInBits(CE->getType());
        if (PtrWidth < InWidth) {
          Constant *Mask =
            ConstantInt::get(CE->getContext(),
                             APInt::getLowBitsSet(InWidth, PtrWidth));
          Input = ConstantExpr::getAnd(Input, Mask);
        }
        // Do a zext or trunc to get to the dest size.
        return ConstantExpr::getIntegerCast(Input, DestTy, false);
      }
    }
    return ConstantExpr::getCast(Opcode, C, DestTy);
  case Instruction::IntToPtr:
    // If the input is a ptrtoint, turn the pair into a ptr to ptr bitcast if
    // the int size is >= the ptr size and the address spaces are the same.
    // This requires knowing the width of a pointer, so it can't be done in
    // ConstantExpr::getCast.
    if (auto *CE = dyn_cast<ConstantExpr>(C)) {
      if (CE->getOpcode() == Instruction::PtrToInt) {
        Constant *SrcPtr = CE->getOperand(0);
        unsigned SrcPtrSize = DL.getPointerTypeSizeInBits(SrcPtr->getType());
        unsigned MidIntSize = CE->getType()->getScalarSizeInBits();

        if (MidIntSize >= SrcPtrSize) {
          unsigned SrcAS = SrcPtr->getType()->getPointerAddressSpace();
          if (SrcAS == DestTy->getPointerAddressSpace())
            return FoldBitCast(CE->getOperand(0), DestTy, DL);
        }
      }
    }

    return ConstantExpr::getCast(Opcode, C, DestTy);
  case Instruction::Trunc:
  case Instruction::ZExt:
  case Instruction::SExt:
  case Instruction::FPTrunc:
  case Instruction::FPExt:
  case Instruction::UIToFP:
  case Instruction::SIToFP:
  case Instruction::FPToUI:
  case Instruction::FPToSI:
  case Instruction::AddrSpaceCast:
      return ConstantExpr::getCast(Opcode, C, DestTy);
  case Instruction::BitCast:
    return FoldBitCast(C, DestTy, DL);
  }
}

Constant *llvm::ConstantFoldLoadThroughGEPConstantExpr(Constant *C,
                                                       ConstantExpr *CE) {
  if (!CE->getOperand(1)->isNullValue())
    return nullptr;  // Do not allow stepping over the value!

  // Loop over all of the operands, tracking down which value we are
  // addressing.
  for (unsigned i = 2, e = CE->getNumOperands(); i != e; ++i) {
    C = C->getAggregateElement(CE->getOperand(i));
    if (!C)
      return nullptr;
  }
  return C;
}

Constant *
llvm::ConstantFoldLoadThroughGEPIndices(Constant *C,
                                        ArrayRef<Constant *> Indices) {
  // Loop over all of the operands, tracking down which value we are
  // addressing.
  for (Constant *Index : Indices) {
    C = C->getAggregateElement(Index);
    if (!C)
      return nullptr;
  }
  return C;
}

//===----------------------------------------------------------------------===//
//  Constant Folding for Calls
//

bool llvm::canConstantFoldCallTo(const Function *F) {
  switch (F->getIntrinsicID()) {
  case Intrinsic::fabs:
  case Intrinsic::minnum:
  case Intrinsic::maxnum:
  case Intrinsic::log:
  case Intrinsic::log2:
  case Intrinsic::log10:
  case Intrinsic::exp:
  case Intrinsic::exp2:
  case Intrinsic::floor:
  case Intrinsic::ceil:
  case Intrinsic::sqrt:
  case Intrinsic::sin:
  case Intrinsic::cos:
  case Intrinsic::trunc:
  case Intrinsic::rint:
  case Intrinsic::nearbyint:
  case Intrinsic::pow:
  case Intrinsic::powi:
  case Intrinsic::bswap:
  case Intrinsic::ctpop:
  case Intrinsic::ctlz:
  case Intrinsic::cttz:
  case Intrinsic::fma:
  case Intrinsic::fmuladd:
  case Intrinsic::copysign:
  case Intrinsic::round:
  case Intrinsic::masked_load:
  case Intrinsic::sadd_with_overflow:
  case Intrinsic::uadd_with_overflow:
  case Intrinsic::ssub_with_overflow:
  case Intrinsic::usub_with_overflow:
  case Intrinsic::smul_with_overflow:
  case Intrinsic::umul_with_overflow:
  case Intrinsic::convert_from_fp16:
  case Intrinsic::convert_to_fp16:
  case Intrinsic::bitreverse:
  case Intrinsic::x86_sse_cvtss2si:
  case Intrinsic::x86_sse_cvtss2si64:
  case Intrinsic::x86_sse_cvttss2si:
  case Intrinsic::x86_sse_cvttss2si64:
  case Intrinsic::x86_sse2_cvtsd2si:
  case Intrinsic::x86_sse2_cvtsd2si64:
  case Intrinsic::x86_sse2_cvttsd2si:
  case Intrinsic::x86_sse2_cvttsd2si64:
    return true;
  default:
    return false;
  case 0: break;
  }

  if (!F->hasName())
    return false;
  StringRef Name = F->getName();

  // In these cases, the check of the length is required.  We don't want to
  // return true for a name like "cos\0blah" which strcmp would return equal to
  // "cos", but has length 8.
  switch (Name[0]) {
  default:
    return false;
  case 'a':
    return Name == "acos" || Name == "asin" || Name == "atan" ||
           Name == "atan2" || Name == "acosf" || Name == "asinf" ||
           Name == "atanf" || Name == "atan2f";
  case 'c':
    return Name == "ceil" || Name == "cos" || Name == "cosh" ||
           Name == "ceilf" || Name == "cosf" || Name == "coshf";
  case 'e':
    return Name == "exp" || Name == "exp2" || Name == "expf" || Name == "exp2f";
  case 'f':
    return Name == "fabs" || Name == "floor" || Name == "fmod" ||
           Name == "fabsf" || Name == "floorf" || Name == "fmodf";
  case 'l':
    return Name == "log" || Name == "log10" || Name == "logf" ||
           Name == "log10f";
  case 'p':
    return Name == "pow" || Name == "powf";
  case 's':
    return Name == "sin" || Name == "sinh" || Name == "sqrt" ||
           Name == "sinf" || Name == "sinhf" || Name == "sqrtf";
  case 't':
    return Name == "tan" || Name == "tanh" || Name == "tanf" || Name == "tanhf";
  }
}

namespace {

Constant *GetConstantFoldFPValue(double V, Type *Ty) {
  if (Ty->isHalfTy()) {
    APFloat APF(V);
    bool unused;
    APF.convert(APFloat::IEEEhalf, APFloat::rmNearestTiesToEven, &unused);
    return ConstantFP::get(Ty->getContext(), APF);
  }
  if (Ty->isFloatTy())
    return ConstantFP::get(Ty->getContext(), APFloat((float)V));
  if (Ty->isDoubleTy())
    return ConstantFP::get(Ty->getContext(), APFloat(V));
  llvm_unreachable("Can only constant fold half/float/double");
}

/// Clear the floating-point exception state.
inline void llvm_fenv_clearexcept() {
#if defined(HAVE_FENV_H) && HAVE_DECL_FE_ALL_EXCEPT
  feclearexcept(FE_ALL_EXCEPT);
#endif
  errno = 0;
}

/// Test if a floating-point exception was raised.
inline bool llvm_fenv_testexcept() {
  int errno_val = errno;
  if (errno_val == ERANGE || errno_val == EDOM)
    return true;
#if defined(HAVE_FENV_H) && HAVE_DECL_FE_ALL_EXCEPT && HAVE_DECL_FE_INEXACT
  if (fetestexcept(FE_ALL_EXCEPT & ~FE_INEXACT))
    return true;
#endif
  return false;
}

Constant *ConstantFoldFP(double (*NativeFP)(double), double V, Type *Ty) {
  llvm_fenv_clearexcept();
  V = NativeFP(V);
  if (llvm_fenv_testexcept()) {
    llvm_fenv_clearexcept();
    return nullptr;
  }

  return GetConstantFoldFPValue(V, Ty);
}

Constant *ConstantFoldBinaryFP(double (*NativeFP)(double, double), double V,
                               double W, Type *Ty) {
  llvm_fenv_clearexcept();
  V = NativeFP(V, W);
  if (llvm_fenv_testexcept()) {
    llvm_fenv_clearexcept();
    return nullptr;
  }

  return GetConstantFoldFPValue(V, Ty);
}

/// Attempt to fold an SSE floating point to integer conversion of a constant
/// floating point. If roundTowardZero is false, the default IEEE rounding is
/// used (toward nearest, ties to even). This matches the behavior of the
/// non-truncating SSE instructions in the default rounding mode. The desired
/// integer type Ty is used to select how many bits are available for the
/// result. Returns null if the conversion cannot be performed, otherwise
/// returns the Constant value resulting from the conversion.
Constant *ConstantFoldSSEConvertToInt(const APFloat &Val, bool roundTowardZero,
                                      Type *Ty) {
  // All of these conversion intrinsics form an integer of at most 64bits.
  unsigned ResultWidth = Ty->getIntegerBitWidth();
  assert(ResultWidth <= 64 &&
         "Can only constant fold conversions to 64 and 32 bit ints");

  uint64_t UIntVal;
  bool isExact = false;
  APFloat::roundingMode mode = roundTowardZero? APFloat::rmTowardZero
                                              : APFloat::rmNearestTiesToEven;
  APFloat::opStatus status = Val.convertToInteger(&UIntVal, ResultWidth,
                                                  /*isSigned=*/true, mode,
                                                  &isExact);
  if (status != APFloat::opOK &&
      (!roundTowardZero || status != APFloat::opInexact))
    return nullptr;
  return ConstantInt::get(Ty, UIntVal, /*isSigned=*/true);
}

double getValueAsDouble(ConstantFP *Op) {
  Type *Ty = Op->getType();

  if (Ty->isFloatTy())
    return Op->getValueAPF().convertToFloat();

  if (Ty->isDoubleTy())
    return Op->getValueAPF().convertToDouble();

  bool unused;
  APFloat APF = Op->getValueAPF();
  APF.convert(APFloat::IEEEdouble, APFloat::rmNearestTiesToEven, &unused);
  return APF.convertToDouble();
}

Constant *ConstantFoldScalarCall(StringRef Name, unsigned IntrinsicID, Type *Ty,
                                 ArrayRef<Constant *> Operands,
                                 const TargetLibraryInfo *TLI) {
  if (Operands.size() == 1) {
    if (isa<UndefValue>(Operands[0])) {
      // cosine(arg) is between -1 and 1. cosine(invalid arg) is NaN
      if (IntrinsicID == Intrinsic::cos)
        return Constant::getNullValue(Ty);
    }
    if (auto *Op = dyn_cast<ConstantFP>(Operands[0])) {
      if (IntrinsicID == Intrinsic::convert_to_fp16) {
        APFloat Val(Op->getValueAPF());

        bool lost = false;
        Val.convert(APFloat::IEEEhalf, APFloat::rmNearestTiesToEven, &lost);

        return ConstantInt::get(Ty->getContext(), Val.bitcastToAPInt());
      }

      if (!Ty->isHalfTy() && !Ty->isFloatTy() && !Ty->isDoubleTy())
        return nullptr;

      if (IntrinsicID == Intrinsic::round) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmNearestTiesToAway);
        return ConstantFP::get(Ty->getContext(), V);
      }

      if (IntrinsicID == Intrinsic::floor) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmTowardNegative);
        return ConstantFP::get(Ty->getContext(), V);
      }

      if (IntrinsicID == Intrinsic::ceil) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmTowardPositive);
        return ConstantFP::get(Ty->getContext(), V);
      }

      if (IntrinsicID == Intrinsic::trunc) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmTowardZero);
        return ConstantFP::get(Ty->getContext(), V);
      }

      if (IntrinsicID == Intrinsic::rint) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmNearestTiesToEven);
        return ConstantFP::get(Ty->getContext(), V);
      }

      if (IntrinsicID == Intrinsic::nearbyint) {
        APFloat V = Op->getValueAPF();
        V.roundToIntegral(APFloat::rmNearestTiesToEven);
        return ConstantFP::get(Ty->getContext(), V);
      }

      /// We only fold functions with finite arguments. Folding NaN and inf is
      /// likely to be aborted with an exception anyway, and some host libms
      /// have known errors raising exceptions.
      if (Op->getValueAPF().isNaN() || Op->getValueAPF().isInfinity())
        return nullptr;

      /// Currently APFloat versions of these functions do not exist, so we use
      /// the host native double versions.  Float versions are not called
      /// directly but for all these it is true (float)(f((double)arg)) ==
      /// f(arg).  Long double not supported yet.
      double V = getValueAsDouble(Op);

      switch (IntrinsicID) {
        default: break;
        case Intrinsic::fabs:
          return ConstantFoldFP(fabs, V, Ty);
        case Intrinsic::log2:
          return ConstantFoldFP(Log2, V, Ty);
        case Intrinsic::log:
          return ConstantFoldFP(log, V, Ty);
        case Intrinsic::log10:
          return ConstantFoldFP(log10, V, Ty);
        case Intrinsic::exp:
          return ConstantFoldFP(exp, V, Ty);
        case Intrinsic::exp2:
          return ConstantFoldFP(exp2, V, Ty);
        case Intrinsic::sin:
          return ConstantFoldFP(sin, V, Ty);
        case Intrinsic::cos:
          return ConstantFoldFP(cos, V, Ty);
      }

      if (!TLI)
        return nullptr;

      switch (Name[0]) {
      case 'a':
        if ((Name == "acos" && TLI->has(LibFunc::acos)) ||
            (Name == "acosf" && TLI->has(LibFunc::acosf)))
          return ConstantFoldFP(acos, V, Ty);
        else if ((Name == "asin" && TLI->has(LibFunc::asin)) ||
                 (Name == "asinf" && TLI->has(LibFunc::asinf)))
          return ConstantFoldFP(asin, V, Ty);
        else if ((Name == "atan" && TLI->has(LibFunc::atan)) ||
                 (Name == "atanf" && TLI->has(LibFunc::atanf)))
          return ConstantFoldFP(atan, V, Ty);
        break;
      case 'c':
        if ((Name == "ceil" && TLI->has(LibFunc::ceil)) ||
            (Name == "ceilf" && TLI->has(LibFunc::ceilf)))
          return ConstantFoldFP(ceil, V, Ty);
        else if ((Name == "cos" && TLI->has(LibFunc::cos)) ||
                 (Name == "cosf" && TLI->has(LibFunc::cosf)))
          return ConstantFoldFP(cos, V, Ty);
        else if ((Name == "cosh" && TLI->has(LibFunc::cosh)) ||
                 (Name == "coshf" && TLI->has(LibFunc::coshf)))
          return ConstantFoldFP(cosh, V, Ty);
        break;
      case 'e':
        if ((Name == "exp" && TLI->has(LibFunc::exp)) ||
            (Name == "expf" && TLI->has(LibFunc::expf)))
          return ConstantFoldFP(exp, V, Ty);
        if ((Name == "exp2" && TLI->has(LibFunc::exp2)) ||
            (Name == "exp2f" && TLI->has(LibFunc::exp2f)))
          // Constant fold exp2(x) as pow(2,x) in case the host doesn't have a
          // C99 library.
          return ConstantFoldBinaryFP(pow, 2.0, V, Ty);
        break;
      case 'f':
        if ((Name == "fabs" && TLI->has(LibFunc::fabs)) ||
            (Name == "fabsf" && TLI->has(LibFunc::fabsf)))
          return ConstantFoldFP(fabs, V, Ty);
        else if ((Name == "floor" && TLI->has(LibFunc::floor)) ||
                 (Name == "floorf" && TLI->has(LibFunc::floorf)))
          return ConstantFoldFP(floor, V, Ty);
        break;
      case 'l':
        if ((Name == "log" && V > 0 && TLI->has(LibFunc::log)) ||
            (Name == "logf" && V > 0 && TLI->has(LibFunc::logf)))
          return ConstantFoldFP(log, V, Ty);
        else if ((Name == "log10" && V > 0 && TLI->has(LibFunc::log10)) ||
                 (Name == "log10f" && V > 0 && TLI->has(LibFunc::log10f)))
          return ConstantFoldFP(log10, V, Ty);
        else if (IntrinsicID == Intrinsic::sqrt &&
                 (Ty->isHalfTy() || Ty->isFloatTy() || Ty->isDoubleTy())) {
          if (V >= -0.0)
            return ConstantFoldFP(sqrt, V, Ty);
          else {
            // Unlike the sqrt definitions in C/C++, POSIX, and IEEE-754 - which
            // all guarantee or favor returning NaN - the square root of a
            // negative number is not defined for the LLVM sqrt intrinsic.
            // This is because the intrinsic should only be emitted in place of
            // libm's sqrt function when using "no-nans-fp-math".
            return UndefValue::get(Ty);
          }
        }
        break;
      case 's':
        if ((Name == "sin" && TLI->has(LibFunc::sin)) ||
            (Name == "sinf" && TLI->has(LibFunc::sinf)))
          return ConstantFoldFP(sin, V, Ty);
        else if ((Name == "sinh" && TLI->has(LibFunc::sinh)) ||
                 (Name == "sinhf" && TLI->has(LibFunc::sinhf)))
          return ConstantFoldFP(sinh, V, Ty);
        else if ((Name == "sqrt" && V >= 0 && TLI->has(LibFunc::sqrt)) ||
                 (Name == "sqrtf" && V >= 0 && TLI->has(LibFunc::sqrtf)))
          return ConstantFoldFP(sqrt, V, Ty);
        break;
      case 't':
        if ((Name == "tan" && TLI->has(LibFunc::tan)) ||
            (Name == "tanf" && TLI->has(LibFunc::tanf)))
          return ConstantFoldFP(tan, V, Ty);
        else if ((Name == "tanh" && TLI->has(LibFunc::tanh)) ||
                 (Name == "tanhf" && TLI->has(LibFunc::tanhf)))
          return ConstantFoldFP(tanh, V, Ty);
        break;
      default:
        break;
      }
      return nullptr;
    }

    if (auto *Op = dyn_cast<ConstantInt>(Operands[0])) {
      switch (IntrinsicID) {
      case Intrinsic::bswap:
        return ConstantInt::get(Ty->getContext(), Op->getValue().byteSwap());
      case Intrinsic::ctpop:
        return ConstantInt::get(Ty, Op->getValue().countPopulation());
      case Intrinsic::bitreverse:
        return ConstantInt::get(Ty->getContext(), Op->getValue().reverseBits());
      case Intrinsic::convert_from_fp16: {
        APFloat Val(APFloat::IEEEhalf, Op->getValue());

        bool lost = false;
        APFloat::opStatus status = Val.convert(
            Ty->getFltSemantics(), APFloat::rmNearestTiesToEven, &lost);

        // Conversion is always precise.
        (void)status;
        assert(status == APFloat::opOK && !lost &&
               "Precision lost during fp16 constfolding");

        return ConstantFP::get(Ty->getContext(), Val);
      }
      default:
        return nullptr;
      }
    }

    // Support ConstantVector in case we have an Undef in the top.
    if (isa<ConstantVector>(Operands[0]) ||
        isa<ConstantDataVector>(Operands[0])) {
      auto *Op = cast<Constant>(Operands[0]);
      switch (IntrinsicID) {
      default: break;
      case Intrinsic::x86_sse_cvtss2si:
      case Intrinsic::x86_sse_cvtss2si64:
      case Intrinsic::x86_sse2_cvtsd2si:
      case Intrinsic::x86_sse2_cvtsd2si64:
        if (ConstantFP *FPOp =
                dyn_cast_or_null<ConstantFP>(Op->getAggregateElement(0U)))
          return ConstantFoldSSEConvertToInt(FPOp->getValueAPF(),
                                             /*roundTowardZero=*/false, Ty);
      case Intrinsic::x86_sse_cvttss2si:
      case Intrinsic::x86_sse_cvttss2si64:
      case Intrinsic::x86_sse2_cvttsd2si:
      case Intrinsic::x86_sse2_cvttsd2si64:
        if (ConstantFP *FPOp =
                dyn_cast_or_null<ConstantFP>(Op->getAggregateElement(0U)))
          return ConstantFoldSSEConvertToInt(FPOp->getValueAPF(),
                                             /*roundTowardZero=*/true, Ty);
      }
    }

    if (isa<UndefValue>(Operands[0])) {
      if (IntrinsicID == Intrinsic::bswap)
        return Operands[0];
      return nullptr;
    }

    return nullptr;
  }

  if (Operands.size() == 2) {
    if (auto *Op1 = dyn_cast<ConstantFP>(Operands[0])) {
      if (!Ty->isHalfTy() && !Ty->isFloatTy() && !Ty->isDoubleTy())
        return nullptr;
      double Op1V = getValueAsDouble(Op1);

      if (auto *Op2 = dyn_cast<ConstantFP>(Operands[1])) {
        if (Op2->getType() != Op1->getType())
          return nullptr;

        double Op2V = getValueAsDouble(Op2);
        if (IntrinsicID == Intrinsic::pow) {
          return ConstantFoldBinaryFP(pow, Op1V, Op2V, Ty);
        }
        if (IntrinsicID == Intrinsic::copysign) {
          APFloat V1 = Op1->getValueAPF();
          const APFloat &V2 = Op2->getValueAPF();
          V1.copySign(V2);
          return ConstantFP::get(Ty->getContext(), V1);
        }

        if (IntrinsicID == Intrinsic::minnum) {
          const APFloat &C1 = Op1->getValueAPF();
          const APFloat &C2 = Op2->getValueAPF();
          return ConstantFP::get(Ty->getContext(), minnum(C1, C2));
        }

        if (IntrinsicID == Intrinsic::maxnum) {
          const APFloat &C1 = Op1->getValueAPF();
          const APFloat &C2 = Op2->getValueAPF();
          return ConstantFP::get(Ty->getContext(), maxnum(C1, C2));
        }

        if (!TLI)
          return nullptr;
        if ((Name == "pow" && TLI->has(LibFunc::pow)) ||
            (Name == "powf" && TLI->has(LibFunc::powf)))
          return ConstantFoldBinaryFP(pow, Op1V, Op2V, Ty);
        if ((Name == "fmod" && TLI->has(LibFunc::fmod)) ||
            (Name == "fmodf" && TLI->has(LibFunc::fmodf)))
          return ConstantFoldBinaryFP(fmod, Op1V, Op2V, Ty);
        if ((Name == "atan2" && TLI->has(LibFunc::atan2)) ||
            (Name == "atan2f" && TLI->has(LibFunc::atan2f)))
          return ConstantFoldBinaryFP(atan2, Op1V, Op2V, Ty);
      } else if (auto *Op2C = dyn_cast<ConstantInt>(Operands[1])) {
        if (IntrinsicID == Intrinsic::powi && Ty->isHalfTy())
          return ConstantFP::get(Ty->getContext(),
                                 APFloat((float)std::pow((float)Op1V,
                                                 (int)Op2C->getZExtValue())));
        if (IntrinsicID == Intrinsic::powi && Ty->isFloatTy())
          return ConstantFP::get(Ty->getContext(),
                                 APFloat((float)std::pow((float)Op1V,
                                                 (int)Op2C->getZExtValue())));
        if (IntrinsicID == Intrinsic::powi && Ty->isDoubleTy())
          return ConstantFP::get(Ty->getContext(),
                                 APFloat((double)std::pow((double)Op1V,
                                                   (int)Op2C->getZExtValue())));
      }
      return nullptr;
    }

    if (auto *Op1 = dyn_cast<ConstantInt>(Operands[0])) {
      if (auto *Op2 = dyn_cast<ConstantInt>(Operands[1])) {
        switch (IntrinsicID) {
        default: break;
        case Intrinsic::sadd_with_overflow:
        case Intrinsic::uadd_with_overflow:
        case Intrinsic::ssub_with_overflow:
        case Intrinsic::usub_with_overflow:
        case Intrinsic::smul_with_overflow:
        case Intrinsic::umul_with_overflow: {
          APInt Res;
          bool Overflow;
          switch (IntrinsicID) {
          default: llvm_unreachable("Invalid case");
          case Intrinsic::sadd_with_overflow:
            Res = Op1->getValue().sadd_ov(Op2->getValue(), Overflow);
            break;
          case Intrinsic::uadd_with_overflow:
            Res = Op1->getValue().uadd_ov(Op2->getValue(), Overflow);
            break;
          case Intrinsic::ssub_with_overflow:
            Res = Op1->getValue().ssub_ov(Op2->getValue(), Overflow);
            break;
          case Intrinsic::usub_with_overflow:
            Res = Op1->getValue().usub_ov(Op2->getValue(), Overflow);
            break;
          case Intrinsic::smul_with_overflow:
            Res = Op1->getValue().smul_ov(Op2->getValue(), Overflow);
            break;
          case Intrinsic::umul_with_overflow:
            Res = Op1->getValue().umul_ov(Op2->getValue(), Overflow);
            break;
          }
          Constant *Ops[] = {
            ConstantInt::get(Ty->getContext(), Res),
            ConstantInt::get(Type::getInt1Ty(Ty->getContext()), Overflow)
          };
          return ConstantStruct::get(cast<StructType>(Ty), Ops);
        }
        case Intrinsic::cttz:
          if (Op2->isOne() && Op1->isZero()) // cttz(0, 1) is undef.
            return UndefValue::get(Ty);
          return ConstantInt::get(Ty, Op1->getValue().countTrailingZeros());
        case Intrinsic::ctlz:
          if (Op2->isOne() && Op1->isZero()) // ctlz(0, 1) is undef.
            return UndefValue::get(Ty);
          return ConstantInt::get(Ty, Op1->getValue().countLeadingZeros());
        }
      }

      return nullptr;
    }
    return nullptr;
  }

  if (Operands.size() != 3)
    return nullptr;

  if (const auto *Op1 = dyn_cast<ConstantFP>(Operands[0])) {
    if (const auto *Op2 = dyn_cast<ConstantFP>(Operands[1])) {
      if (const auto *Op3 = dyn_cast<ConstantFP>(Operands[2])) {
        switch (IntrinsicID) {
        default: break;
        case Intrinsic::fma:
        case Intrinsic::fmuladd: {
          APFloat V = Op1->getValueAPF();
          APFloat::opStatus s = V.fusedMultiplyAdd(Op2->getValueAPF(),
                                                   Op3->getValueAPF(),
                                                   APFloat::rmNearestTiesToEven);
          if (s != APFloat::opInvalidOp)
            return ConstantFP::get(Ty->getContext(), V);

          return nullptr;
        }
        }
      }
    }
  }

  return nullptr;
}

Constant *ConstantFoldVectorCall(StringRef Name, unsigned IntrinsicID,
                                 VectorType *VTy, ArrayRef<Constant *> Operands,
                                 const DataLayout &DL,
                                 const TargetLibraryInfo *TLI) {
  SmallVector<Constant *, 4> Result(VTy->getNumElements());
  SmallVector<Constant *, 4> Lane(Operands.size());
  Type *Ty = VTy->getElementType();

  if (IntrinsicID == Intrinsic::masked_load) {
    auto *SrcPtr = Operands[0];
    auto *Mask = Operands[2];
    auto *Passthru = Operands[3];

    Constant *VecData = ConstantFoldLoadFromConstPtr(SrcPtr, VTy, DL);

    SmallVector<Constant *, 32> NewElements;
    for (unsigned I = 0, E = VTy->getNumElements(); I != E; ++I) {
      auto *MaskElt = Mask->getAggregateElement(I);
      if (!MaskElt)
        break;
      auto *PassthruElt = Passthru->getAggregateElement(I);
      auto *VecElt = VecData ? VecData->getAggregateElement(I) : nullptr;
      if (isa<UndefValue>(MaskElt)) {
        if (PassthruElt)
          NewElements.push_back(PassthruElt);
        else if (VecElt)
          NewElements.push_back(VecElt);
        else
          return nullptr;
      }
      if (MaskElt->isNullValue()) {
        if (!PassthruElt)
          return nullptr;
        NewElements.push_back(PassthruElt);
      } else if (MaskElt->isOneValue()) {
        if (!VecElt)
          return nullptr;
        NewElements.push_back(VecElt);
      } else {
        return nullptr;
      }
    }
    if (NewElements.size() != VTy->getNumElements())
      return nullptr;
    return ConstantVector::get(NewElements);
  }

  for (unsigned I = 0, E = VTy->getNumElements(); I != E; ++I) {
    // Gather a column of constants.
    for (unsigned J = 0, JE = Operands.size(); J != JE; ++J) {
      Constant *Agg = Operands[J]->getAggregateElement(I);
      if (!Agg)
        return nullptr;

      Lane[J] = Agg;
    }

    // Use the regular scalar folding to simplify this column.
    Constant *Folded = ConstantFoldScalarCall(Name, IntrinsicID, Ty, Lane, TLI);
    if (!Folded)
      return nullptr;
    Result[I] = Folded;
  }

  return ConstantVector::get(Result);
}

} // end anonymous namespace

Constant *
llvm::ConstantFoldCall(Function *F, ArrayRef<Constant *> Operands,
                       const TargetLibraryInfo *TLI) {
  if (!F->hasName())
    return nullptr;
  StringRef Name = F->getName();

  Type *Ty = F->getReturnType();

  if (auto *VTy = dyn_cast<VectorType>(Ty))
    return ConstantFoldVectorCall(Name, F->getIntrinsicID(), VTy, Operands,
                                  F->getParent()->getDataLayout(), TLI);

  return ConstantFoldScalarCall(Name, F->getIntrinsicID(), Ty, Operands, TLI);
}
