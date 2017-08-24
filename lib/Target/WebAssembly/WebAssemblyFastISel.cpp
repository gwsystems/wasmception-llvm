//===-- WebAssemblyFastISel.cpp - WebAssembly FastISel implementation -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// \brief This file defines the WebAssembly-specific support for the FastISel
/// class. Some of the target-specific code is generated by tablegen in the file
/// WebAssemblyGenFastISel.inc, which is #included here.
///
/// TODO: kill flags
///
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/WebAssemblyMCTargetDesc.h"
#include "WebAssembly.h"
#include "WebAssemblyMachineFunctionInfo.h"
#include "WebAssemblySubtarget.h"
#include "WebAssemblyTargetMachine.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/CodeGen/FastISel.h"
#include "llvm/CodeGen/FunctionLoweringInfo.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GetElementPtrTypeIterator.h"
#include "llvm/IR/GlobalAlias.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Operator.h"
using namespace llvm;

#define DEBUG_TYPE "wasm-fastisel"

namespace {

class WebAssemblyFastISel final : public FastISel {
  // All possible address modes.
  class Address {
  public:
    typedef enum { RegBase, FrameIndexBase } BaseKind;

  private:
    BaseKind Kind;
    union {
      unsigned Reg;
      int FI;
    } Base;

    int64_t Offset;

    const GlobalValue *GV;

  public:
    // Innocuous defaults for our address.
    Address() : Kind(RegBase), Offset(0), GV(0) { Base.Reg = 0; }
    void setKind(BaseKind K) {
      assert(!isSet() && "Can't change kind with non-zero base");
      Kind = K;
    }
    BaseKind getKind() const { return Kind; }
    bool isRegBase() const { return Kind == RegBase; }
    bool isFIBase() const { return Kind == FrameIndexBase; }
    void setReg(unsigned Reg) {
      assert(isRegBase() && "Invalid base register access!");
      assert(Base.Reg == 0 && "Overwriting non-zero register");
      Base.Reg = Reg;
    }
    unsigned getReg() const {
      assert(isRegBase() && "Invalid base register access!");
      return Base.Reg;
    }
    void setFI(unsigned FI) {
      assert(isFIBase() && "Invalid base frame index access!");
      assert(Base.FI == 0 && "Overwriting non-zero frame index");
      Base.FI = FI;
    }
    unsigned getFI() const {
      assert(isFIBase() && "Invalid base frame index access!");
      return Base.FI;
    }

    void setOffset(int64_t Offset_) {
      assert(Offset_ >= 0 && "Offsets must be non-negative");
      Offset = Offset_;
    }
    int64_t getOffset() const { return Offset; }
    void setGlobalValue(const GlobalValue *G) { GV = G; }
    const GlobalValue *getGlobalValue() const { return GV; }
    bool isSet() const {
      if (isRegBase()) {
        return Base.Reg != 0;
      } else {
        return Base.FI != 0;
      }
    }
  };

  /// Keep a pointer to the WebAssemblySubtarget around so that we can make the
  /// right decision when generating code for different targets.
  const WebAssemblySubtarget *Subtarget;
  LLVMContext *Context;

private:
  // Utility helper routines
  MVT::SimpleValueType getSimpleType(Type *Ty) {
    EVT VT = TLI.getValueType(DL, Ty, /*HandleUnknown=*/true);
    return VT.isSimple() ? VT.getSimpleVT().SimpleTy :
                           MVT::INVALID_SIMPLE_VALUE_TYPE;
  }
  MVT::SimpleValueType getLegalType(MVT::SimpleValueType VT) {
    switch (VT) {
    case MVT::i1:
    case MVT::i8:
    case MVT::i16:
      return MVT::i32;
    case MVT::i32:
    case MVT::i64:
    case MVT::f32:
    case MVT::f64:
      return VT;
    case MVT::f16:
      return MVT::f32;
    case MVT::v16i8:
    case MVT::v8i16:
    case MVT::v4i32:
    case MVT::v4f32:
      if (Subtarget->hasSIMD128())
        return VT;
      break;
    default:
      break;
    }
    return MVT::INVALID_SIMPLE_VALUE_TYPE;
  }
  bool computeAddress(const Value *Obj, Address &Addr);
  void materializeLoadStoreOperands(Address &Addr);
  void addLoadStoreOperands(const Address &Addr, const MachineInstrBuilder &MIB,
                            MachineMemOperand *MMO);
  unsigned maskI1Value(unsigned Reg, const Value *V);
  unsigned getRegForI1Value(const Value *V, bool &Not);
  unsigned zeroExtendToI32(unsigned Reg, const Value *V,
                           MVT::SimpleValueType From);
  unsigned signExtendToI32(unsigned Reg, const Value *V,
                           MVT::SimpleValueType From);
  unsigned zeroExtend(unsigned Reg, const Value *V,
                      MVT::SimpleValueType From,
                      MVT::SimpleValueType To);
  unsigned signExtend(unsigned Reg, const Value *V,
                      MVT::SimpleValueType From,
                      MVT::SimpleValueType To);
  unsigned getRegForUnsignedValue(const Value *V);
  unsigned getRegForSignedValue(const Value *V);
  unsigned getRegForPromotedValue(const Value *V, bool IsSigned);
  unsigned notValue(unsigned Reg);
  unsigned copyValue(unsigned Reg);

  // Backend specific FastISel code.
  unsigned fastMaterializeAlloca(const AllocaInst *AI) override;
  unsigned fastMaterializeConstant(const Constant *C) override;
  bool fastLowerArguments() override;

  // Selection routines.
  bool selectCall(const Instruction *I);
  bool selectSelect(const Instruction *I);
  bool selectTrunc(const Instruction *I);
  bool selectZExt(const Instruction *I);
  bool selectSExt(const Instruction *I);
  bool selectICmp(const Instruction *I);
  bool selectFCmp(const Instruction *I);
  bool selectBitCast(const Instruction *I);
  bool selectLoad(const Instruction *I);
  bool selectStore(const Instruction *I);
  bool selectBr(const Instruction *I);
  bool selectRet(const Instruction *I);
  bool selectUnreachable(const Instruction *I);

public:
  // Backend specific FastISel code.
  WebAssemblyFastISel(FunctionLoweringInfo &FuncInfo,
                      const TargetLibraryInfo *LibInfo)
      : FastISel(FuncInfo, LibInfo, /*SkipTargetIndependentISel=*/true) {
    Subtarget = &FuncInfo.MF->getSubtarget<WebAssemblySubtarget>();
    Context = &FuncInfo.Fn->getContext();
  }

  bool fastSelectInstruction(const Instruction *I) override;

#include "WebAssemblyGenFastISel.inc"
};

} // end anonymous namespace

bool WebAssemblyFastISel::computeAddress(const Value *Obj, Address &Addr) {

  const User *U = nullptr;
  unsigned Opcode = Instruction::UserOp1;
  if (const Instruction *I = dyn_cast<Instruction>(Obj)) {
    // Don't walk into other basic blocks unless the object is an alloca from
    // another block, otherwise it may not have a virtual register assigned.
    if (FuncInfo.StaticAllocaMap.count(static_cast<const AllocaInst *>(Obj)) ||
        FuncInfo.MBBMap[I->getParent()] == FuncInfo.MBB) {
      Opcode = I->getOpcode();
      U = I;
    }
  } else if (const ConstantExpr *C = dyn_cast<ConstantExpr>(Obj)) {
    Opcode = C->getOpcode();
    U = C;
  }

  if (auto *Ty = dyn_cast<PointerType>(Obj->getType()))
    if (Ty->getAddressSpace() > 255)
      // Fast instruction selection doesn't support the special
      // address spaces.
      return false;

  if (const GlobalValue *GV = dyn_cast<GlobalValue>(Obj)) {
    if (Addr.getGlobalValue())
      return false;
    Addr.setGlobalValue(GV);
    return true;
  }

  switch (Opcode) {
  default:
    break;
  case Instruction::BitCast: {
    // Look through bitcasts.
    return computeAddress(U->getOperand(0), Addr);
  }
  case Instruction::IntToPtr: {
    // Look past no-op inttoptrs.
    if (TLI.getValueType(DL, U->getOperand(0)->getType()) ==
        TLI.getPointerTy(DL))
      return computeAddress(U->getOperand(0), Addr);
    break;
  }
  case Instruction::PtrToInt: {
    // Look past no-op ptrtoints.
    if (TLI.getValueType(DL, U->getType()) == TLI.getPointerTy(DL))
      return computeAddress(U->getOperand(0), Addr);
    break;
  }
  case Instruction::GetElementPtr: {
    Address SavedAddr = Addr;
    uint64_t TmpOffset = Addr.getOffset();
    // Non-inbounds geps can wrap; wasm's offsets can't.
    if (!cast<GEPOperator>(U)->isInBounds())
      goto unsupported_gep;
    // Iterate through the GEP folding the constants into offsets where
    // we can.
    for (gep_type_iterator GTI = gep_type_begin(U), E = gep_type_end(U);
         GTI != E; ++GTI) {
      const Value *Op = GTI.getOperand();
      if (StructType *STy = GTI.getStructTypeOrNull()) {
        const StructLayout *SL = DL.getStructLayout(STy);
        unsigned Idx = cast<ConstantInt>(Op)->getZExtValue();
        TmpOffset += SL->getElementOffset(Idx);
      } else {
        uint64_t S = DL.getTypeAllocSize(GTI.getIndexedType());
        for (;;) {
          if (const ConstantInt *CI = dyn_cast<ConstantInt>(Op)) {
            // Constant-offset addressing.
            TmpOffset += CI->getSExtValue() * S;
            break;
          }
          if (S == 1 && Addr.isRegBase() && Addr.getReg() == 0) {
            // An unscaled add of a register. Set it as the new base.
            Addr.setReg(getRegForValue(Op));
            break;
          }
          if (canFoldAddIntoGEP(U, Op)) {
            // A compatible add with a constant operand. Fold the constant.
            ConstantInt *CI =
                cast<ConstantInt>(cast<AddOperator>(Op)->getOperand(1));
            TmpOffset += CI->getSExtValue() * S;
            // Iterate on the other operand.
            Op = cast<AddOperator>(Op)->getOperand(0);
            continue;
          }
          // Unsupported
          goto unsupported_gep;
        }
      }
    }
    // Don't fold in negative offsets.
    if (int64_t(TmpOffset) >= 0) {
      // Try to grab the base operand now.
      Addr.setOffset(TmpOffset);
      if (computeAddress(U->getOperand(0), Addr))
        return true;
    }
    // We failed, restore everything and try the other options.
    Addr = SavedAddr;
  unsupported_gep:
    break;
  }
  case Instruction::Alloca: {
    const AllocaInst *AI = cast<AllocaInst>(Obj);
    DenseMap<const AllocaInst *, int>::iterator SI =
        FuncInfo.StaticAllocaMap.find(AI);
    if (SI != FuncInfo.StaticAllocaMap.end()) {
      if (Addr.isSet()) {
        return false;
      }
      Addr.setKind(Address::FrameIndexBase);
      Addr.setFI(SI->second);
      return true;
    }
    break;
  }
  case Instruction::Add: {
    // Adds of constants are common and easy enough.
    const Value *LHS = U->getOperand(0);
    const Value *RHS = U->getOperand(1);

    if (isa<ConstantInt>(LHS))
      std::swap(LHS, RHS);

    if (const ConstantInt *CI = dyn_cast<ConstantInt>(RHS)) {
      uint64_t TmpOffset = Addr.getOffset() + CI->getSExtValue();
      if (int64_t(TmpOffset) >= 0) {
        Addr.setOffset(TmpOffset);
        return computeAddress(LHS, Addr);
      }
    }

    Address Backup = Addr;
    if (computeAddress(LHS, Addr) && computeAddress(RHS, Addr))
      return true;
    Addr = Backup;

    break;
  }
  case Instruction::Sub: {
    // Subs of constants are common and easy enough.
    const Value *LHS = U->getOperand(0);
    const Value *RHS = U->getOperand(1);

    if (const ConstantInt *CI = dyn_cast<ConstantInt>(RHS)) {
      int64_t TmpOffset = Addr.getOffset() - CI->getSExtValue();
      if (TmpOffset >= 0) {
        Addr.setOffset(TmpOffset);
        return computeAddress(LHS, Addr);
      }
    }
    break;
  }
  }
  if (Addr.isSet()) {
    return false;
  }
  Addr.setReg(getRegForValue(Obj));
  return Addr.getReg() != 0;
}

void WebAssemblyFastISel::materializeLoadStoreOperands(Address &Addr) {
  if (Addr.isRegBase()) {
    unsigned Reg = Addr.getReg();
    if (Reg == 0) {
      Reg = createResultReg(Subtarget->hasAddr64() ?
                            &WebAssembly::I64RegClass :
                            &WebAssembly::I32RegClass);
      unsigned Opc = Subtarget->hasAddr64() ?
                     WebAssembly::CONST_I64 :
                     WebAssembly::CONST_I32;
      BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), Reg)
         .addImm(0);
      Addr.setReg(Reg);
    }
  }
}

void WebAssemblyFastISel::addLoadStoreOperands(const Address &Addr,
                                               const MachineInstrBuilder &MIB,
                                               MachineMemOperand *MMO) {
  // Set the alignment operand (this is rewritten in SetP2AlignOperands).
  // TODO: Disable SetP2AlignOperands for FastISel and just do it here.
  MIB.addImm(0);

  if (const GlobalValue *GV = Addr.getGlobalValue())
    MIB.addGlobalAddress(GV, Addr.getOffset());
  else
    MIB.addImm(Addr.getOffset());

  if (Addr.isRegBase())
    MIB.addReg(Addr.getReg());
  else
    MIB.addFrameIndex(Addr.getFI());

  MIB.addMemOperand(MMO);
}

unsigned WebAssemblyFastISel::maskI1Value(unsigned Reg, const Value *V) {
  return zeroExtendToI32(Reg, V, MVT::i1);
}

unsigned WebAssemblyFastISel::getRegForI1Value(const Value *V, bool &Not) {
  if (const ICmpInst *ICmp = dyn_cast<ICmpInst>(V))
    if (const ConstantInt *C = dyn_cast<ConstantInt>(ICmp->getOperand(1)))
      if (ICmp->isEquality() && C->isZero() && C->getType()->isIntegerTy(32)) {
        Not = ICmp->isTrueWhenEqual();
        return getRegForValue(ICmp->getOperand(0));
      }

  if (BinaryOperator::isNot(V)) {
    Not = true;
    return getRegForValue(BinaryOperator::getNotArgument(V));
  }

  Not = false;
  return maskI1Value(getRegForValue(V), V);
}

unsigned WebAssemblyFastISel::zeroExtendToI32(unsigned Reg, const Value *V,
                                              MVT::SimpleValueType From) {
  if (Reg == 0)
    return 0;

  switch (From) {
  case MVT::i1:
    // If the value is naturally an i1, we don't need to mask it.
    // TODO: Recursively examine selects, phis, and, or, xor, constants.
    if (From == MVT::i1 && V != nullptr) {
      if (isa<CmpInst>(V) ||
          (isa<Argument>(V) && cast<Argument>(V)->hasZExtAttr()))
        return copyValue(Reg);
    }
  case MVT::i8:
  case MVT::i16:
    break;
  case MVT::i32:
    return copyValue(Reg);
  default:
    return 0;
  }

  unsigned Imm = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::CONST_I32), Imm)
    .addImm(~(~uint64_t(0) << MVT(From).getSizeInBits()));

  unsigned Result = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::AND_I32), Result)
    .addReg(Reg)
    .addReg(Imm);

  return Result;
}

unsigned WebAssemblyFastISel::signExtendToI32(unsigned Reg, const Value *V,
                                              MVT::SimpleValueType From) {
  if (Reg == 0)
    return 0;

  switch (From) {
  case MVT::i1:
  case MVT::i8:
  case MVT::i16:
    break;
  case MVT::i32:
    return copyValue(Reg);
  default:
    return 0;
  }

  unsigned Imm = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::CONST_I32), Imm)
    .addImm(32 - MVT(From).getSizeInBits());

  unsigned Left = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::SHL_I32), Left)
    .addReg(Reg)
    .addReg(Imm);

  unsigned Right = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::SHR_S_I32), Right)
    .addReg(Left)
    .addReg(Imm);

  return Right;
}

unsigned WebAssemblyFastISel::zeroExtend(unsigned Reg, const Value *V,
                                         MVT::SimpleValueType From,
                                         MVT::SimpleValueType To) {
  if (To == MVT::i64) {
    if (From == MVT::i64)
      return copyValue(Reg);

    Reg = zeroExtendToI32(Reg, V, From);

    unsigned Result = createResultReg(&WebAssembly::I64RegClass);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
            TII.get(WebAssembly::I64_EXTEND_U_I32), Result)
        .addReg(Reg);
    return Result;
  }

  return zeroExtendToI32(Reg, V, From);
}

unsigned WebAssemblyFastISel::signExtend(unsigned Reg, const Value *V,
                                         MVT::SimpleValueType From,
                                         MVT::SimpleValueType To) {
  if (To == MVT::i64) {
    if (From == MVT::i64)
      return copyValue(Reg);

    Reg = signExtendToI32(Reg, V, From);

    unsigned Result = createResultReg(&WebAssembly::I64RegClass);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
            TII.get(WebAssembly::I64_EXTEND_S_I32), Result)
        .addReg(Reg);
    return Result;
  }

  return signExtendToI32(Reg, V, From);
}

unsigned WebAssemblyFastISel::getRegForUnsignedValue(const Value *V) {
  MVT::SimpleValueType From = getSimpleType(V->getType());
  MVT::SimpleValueType To = getLegalType(From);
  return zeroExtend(getRegForValue(V), V, From, To);
}

unsigned WebAssemblyFastISel::getRegForSignedValue(const Value *V) {
  MVT::SimpleValueType From = getSimpleType(V->getType());
  MVT::SimpleValueType To = getLegalType(From);
  return zeroExtend(getRegForValue(V), V, From, To);
}

unsigned WebAssemblyFastISel::getRegForPromotedValue(const Value *V,
                                                     bool IsSigned) {
  return IsSigned ? getRegForSignedValue(V) :
                    getRegForUnsignedValue(V);
}

unsigned WebAssemblyFastISel::notValue(unsigned Reg) {
  assert(MRI.getRegClass(Reg) == &WebAssembly::I32RegClass);

  unsigned NotReg = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::EQZ_I32), NotReg)
    .addReg(Reg);
  return NotReg;
}

unsigned WebAssemblyFastISel::copyValue(unsigned Reg) {
  unsigned ResultReg = createResultReg(MRI.getRegClass(Reg));
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::COPY), ResultReg)
    .addReg(Reg);
  return ResultReg;
}

unsigned WebAssemblyFastISel::fastMaterializeAlloca(const AllocaInst *AI) {
  DenseMap<const AllocaInst *, int>::iterator SI =
      FuncInfo.StaticAllocaMap.find(AI);

  if (SI != FuncInfo.StaticAllocaMap.end()) {
    unsigned ResultReg = createResultReg(Subtarget->hasAddr64() ?
                                         &WebAssembly::I64RegClass :
                                         &WebAssembly::I32RegClass);
    unsigned Opc = Subtarget->hasAddr64() ?
                   WebAssembly::COPY_I64 :
                   WebAssembly::COPY_I32;
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
        .addFrameIndex(SI->second);
    return ResultReg;
  }

  return 0;
}

unsigned WebAssemblyFastISel::fastMaterializeConstant(const Constant *C) {
  if (const GlobalValue *GV = dyn_cast<GlobalValue>(C)) {
    unsigned ResultReg = createResultReg(Subtarget->hasAddr64() ?
                                         &WebAssembly::I64RegClass :
                                         &WebAssembly::I32RegClass);
    unsigned Opc = Subtarget->hasAddr64() ?
                   WebAssembly::CONST_I64 :
                   WebAssembly::CONST_I32;
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
       .addGlobalAddress(GV);
    return ResultReg;
  }

  // Let target-independent code handle it.
  return 0;
}

bool WebAssemblyFastISel::fastLowerArguments() {
  if (!FuncInfo.CanLowerReturn)
    return false;

  const Function *F = FuncInfo.Fn;
  if (F->isVarArg())
    return false;

  unsigned i = 0;
  for (auto const &Arg : F->args()) {
    const AttributeList &Attrs = F->getAttributes();
    if (Attrs.hasParamAttribute(i, Attribute::ByVal) ||
        Attrs.hasParamAttribute(i, Attribute::SwiftSelf) ||
        Attrs.hasParamAttribute(i, Attribute::SwiftError) ||
        Attrs.hasParamAttribute(i, Attribute::InAlloca) ||
        Attrs.hasParamAttribute(i, Attribute::Nest))
      return false;

    Type *ArgTy = Arg.getType();
    if (ArgTy->isStructTy() || ArgTy->isArrayTy())
      return false;
    if (!Subtarget->hasSIMD128() && ArgTy->isVectorTy())
      return false;

    unsigned Opc;
    const TargetRegisterClass *RC;
    switch (getSimpleType(ArgTy)) {
    case MVT::i1:
    case MVT::i8:
    case MVT::i16:
    case MVT::i32:
      Opc = WebAssembly::ARGUMENT_I32;
      RC = &WebAssembly::I32RegClass;
      break;
    case MVT::i64:
      Opc = WebAssembly::ARGUMENT_I64;
      RC = &WebAssembly::I64RegClass;
      break;
    case MVT::f32:
      Opc = WebAssembly::ARGUMENT_F32;
      RC = &WebAssembly::F32RegClass;
      break;
    case MVT::f64:
      Opc = WebAssembly::ARGUMENT_F64;
      RC = &WebAssembly::F64RegClass;
      break;
    case MVT::v16i8:
      Opc = WebAssembly::ARGUMENT_v16i8;
      RC = &WebAssembly::V128RegClass;
      break;
    case MVT::v8i16:
      Opc = WebAssembly::ARGUMENT_v8i16;
      RC = &WebAssembly::V128RegClass;
      break;
    case MVT::v4i32:
      Opc = WebAssembly::ARGUMENT_v4i32;
      RC = &WebAssembly::V128RegClass;
      break;
    case MVT::v4f32:
      Opc = WebAssembly::ARGUMENT_v4f32;
      RC = &WebAssembly::V128RegClass;
      break;
    default:
      return false;
    }
    unsigned ResultReg = createResultReg(RC);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
      .addImm(i);
    updateValueMap(&Arg, ResultReg);

    ++i;
  }

  MRI.addLiveIn(WebAssembly::ARGUMENTS);

  auto *MFI = MF->getInfo<WebAssemblyFunctionInfo>();
  for (auto const &Arg : F->args())
    MFI->addParam(getLegalType(getSimpleType(Arg.getType())));

  if (!F->getReturnType()->isVoidTy())
    MFI->addResult(getLegalType(getSimpleType(F->getReturnType())));

  return true;
}

bool WebAssemblyFastISel::selectCall(const Instruction *I) {
  const CallInst *Call = cast<CallInst>(I);

  if (Call->isMustTailCall() || Call->isInlineAsm() ||
      Call->getFunctionType()->isVarArg())
    return false;

  Function *Func = Call->getCalledFunction();
  if (Func && Func->isIntrinsic())
    return false;

  bool IsDirect = Func != nullptr;
  if (!IsDirect && isa<ConstantExpr>(Call->getCalledValue()))
    return false;

  FunctionType *FuncTy = Call->getFunctionType();
  unsigned Opc;
  bool IsVoid = FuncTy->getReturnType()->isVoidTy();
  unsigned ResultReg;
  if (IsVoid) {
    Opc = IsDirect ? WebAssembly::CALL_VOID : WebAssembly::PCALL_INDIRECT_VOID;
  } else {
    if (!Subtarget->hasSIMD128() && Call->getType()->isVectorTy())
      return false;

    MVT::SimpleValueType RetTy = getSimpleType(Call->getType());
    switch (RetTy) {
    case MVT::i1:
    case MVT::i8:
    case MVT::i16:
    case MVT::i32:
      Opc = IsDirect ? WebAssembly::CALL_I32 : WebAssembly::PCALL_INDIRECT_I32;
      ResultReg = createResultReg(&WebAssembly::I32RegClass);
      break;
    case MVT::i64:
      Opc = IsDirect ? WebAssembly::CALL_I64 : WebAssembly::PCALL_INDIRECT_I64;
      ResultReg = createResultReg(&WebAssembly::I64RegClass);
      break;
    case MVT::f32:
      Opc = IsDirect ? WebAssembly::CALL_F32 : WebAssembly::PCALL_INDIRECT_F32;
      ResultReg = createResultReg(&WebAssembly::F32RegClass);
      break;
    case MVT::f64:
      Opc = IsDirect ? WebAssembly::CALL_F64 : WebAssembly::PCALL_INDIRECT_F64;
      ResultReg = createResultReg(&WebAssembly::F64RegClass);
      break;
    case MVT::v16i8:
      Opc =
          IsDirect ? WebAssembly::CALL_v16i8 : WebAssembly::PCALL_INDIRECT_v16i8;
      ResultReg = createResultReg(&WebAssembly::V128RegClass);
      break;
    case MVT::v8i16:
      Opc =
          IsDirect ? WebAssembly::CALL_v8i16 : WebAssembly::PCALL_INDIRECT_v8i16;
      ResultReg = createResultReg(&WebAssembly::V128RegClass);
      break;
    case MVT::v4i32:
      Opc =
          IsDirect ? WebAssembly::CALL_v4i32 : WebAssembly::PCALL_INDIRECT_v4i32;
      ResultReg = createResultReg(&WebAssembly::V128RegClass);
      break;
    case MVT::v4f32:
      Opc =
          IsDirect ? WebAssembly::CALL_v4f32 : WebAssembly::PCALL_INDIRECT_v4f32;
      ResultReg = createResultReg(&WebAssembly::V128RegClass);
      break;
    default:
      return false;
    }
  }

  SmallVector<unsigned, 8> Args;
  for (unsigned i = 0, e = Call->getNumArgOperands(); i < e; ++i) {
    Value *V = Call->getArgOperand(i);
    MVT::SimpleValueType ArgTy = getSimpleType(V->getType());
    if (ArgTy == MVT::INVALID_SIMPLE_VALUE_TYPE)
      return false;

    const AttributeList &Attrs = Call->getAttributes();
    if (Attrs.hasParamAttribute(i, Attribute::ByVal) ||
        Attrs.hasParamAttribute(i, Attribute::SwiftSelf) ||
        Attrs.hasParamAttribute(i, Attribute::SwiftError) ||
        Attrs.hasParamAttribute(i, Attribute::InAlloca) ||
        Attrs.hasParamAttribute(i, Attribute::Nest))
      return false;

    unsigned Reg;

    if (Attrs.hasParamAttribute(i, Attribute::SExt))
      Reg = getRegForSignedValue(V);
    else if (Attrs.hasParamAttribute(i, Attribute::ZExt))
      Reg = getRegForUnsignedValue(V);
    else
      Reg = getRegForValue(V);

    if (Reg == 0)
      return false;

    Args.push_back(Reg);
  }

  auto MIB = BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc));

  if (!IsVoid)
    MIB.addReg(ResultReg, RegState::Define);

  if (IsDirect)
    MIB.addGlobalAddress(Func);
  else
    MIB.addReg(getRegForValue(Call->getCalledValue()));

  for (unsigned ArgReg : Args)
    MIB.addReg(ArgReg);

  if (!IsVoid)
    updateValueMap(Call, ResultReg);
  return true;
}

bool WebAssemblyFastISel::selectSelect(const Instruction *I) {
  const SelectInst *Select = cast<SelectInst>(I);

  bool Not;
  unsigned CondReg  = getRegForI1Value(Select->getCondition(), Not);
  if (CondReg == 0)
    return false;

  unsigned TrueReg  = getRegForValue(Select->getTrueValue());
  if (TrueReg == 0)
    return false;

  unsigned FalseReg = getRegForValue(Select->getFalseValue());
  if (FalseReg == 0)
    return false;

  if (Not)
    std::swap(TrueReg, FalseReg);

  unsigned Opc;
  const TargetRegisterClass *RC;
  switch (getSimpleType(Select->getType())) {
  case MVT::i1:
  case MVT::i8:
  case MVT::i16:
  case MVT::i32:
    Opc = WebAssembly::SELECT_I32;
    RC = &WebAssembly::I32RegClass;
    break;
  case MVT::i64:
    Opc = WebAssembly::SELECT_I64;
    RC = &WebAssembly::I64RegClass;
    break;
  case MVT::f32:
    Opc = WebAssembly::SELECT_F32;
    RC = &WebAssembly::F32RegClass;
    break;
  case MVT::f64:
    Opc = WebAssembly::SELECT_F64;
    RC = &WebAssembly::F64RegClass;
    break;
  default:
    return false;
  }

  unsigned ResultReg = createResultReg(RC);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
    .addReg(TrueReg)
    .addReg(FalseReg)
    .addReg(CondReg);

  updateValueMap(Select, ResultReg);
  return true;
}

bool WebAssemblyFastISel::selectTrunc(const Instruction *I) {
  const TruncInst *Trunc = cast<TruncInst>(I);

  unsigned Reg = getRegForValue(Trunc->getOperand(0));
  if (Reg == 0)
    return false;

  if (Trunc->getOperand(0)->getType()->isIntegerTy(64)) {
    unsigned Result = createResultReg(&WebAssembly::I32RegClass);
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
            TII.get(WebAssembly::I32_WRAP_I64), Result)
        .addReg(Reg);
    Reg = Result;
  }

  updateValueMap(Trunc, Reg);
  return true;
}

bool WebAssemblyFastISel::selectZExt(const Instruction *I) {
  const ZExtInst *ZExt = cast<ZExtInst>(I);

  const Value *Op = ZExt->getOperand(0);
  MVT::SimpleValueType From = getSimpleType(Op->getType());
  MVT::SimpleValueType To = getLegalType(getSimpleType(ZExt->getType()));
  unsigned Reg = zeroExtend(getRegForValue(Op), Op, From, To);
  if (Reg == 0)
    return false;

  updateValueMap(ZExt, Reg);
  return true;
}

bool WebAssemblyFastISel::selectSExt(const Instruction *I) {
  const SExtInst *SExt = cast<SExtInst>(I);

  const Value *Op = SExt->getOperand(0);
  MVT::SimpleValueType From = getSimpleType(Op->getType());
  MVT::SimpleValueType To = getLegalType(getSimpleType(SExt->getType()));
  unsigned Reg = signExtend(getRegForValue(Op), Op, From, To);
  if (Reg == 0)
    return false;

  updateValueMap(SExt, Reg);
  return true;
}

bool WebAssemblyFastISel::selectICmp(const Instruction *I) {
  const ICmpInst *ICmp = cast<ICmpInst>(I);

  bool I32 = getSimpleType(ICmp->getOperand(0)->getType()) != MVT::i64;
  unsigned Opc;
  bool isSigned = false;
  switch (ICmp->getPredicate()) {
  case ICmpInst::ICMP_EQ:
    Opc = I32 ? WebAssembly::EQ_I32 : WebAssembly::EQ_I64;
    break;
  case ICmpInst::ICMP_NE:
    Opc = I32 ? WebAssembly::NE_I32 : WebAssembly::NE_I64;
    break;
  case ICmpInst::ICMP_UGT:
    Opc = I32 ? WebAssembly::GT_U_I32 : WebAssembly::GT_U_I64;
    break;
  case ICmpInst::ICMP_UGE:
    Opc = I32 ? WebAssembly::GE_U_I32 : WebAssembly::GE_U_I64;
    break;
  case ICmpInst::ICMP_ULT:
    Opc = I32 ? WebAssembly::LT_U_I32 : WebAssembly::LT_U_I64;
    break;
  case ICmpInst::ICMP_ULE:
    Opc = I32 ? WebAssembly::LE_U_I32 : WebAssembly::LE_U_I64;
    break;
  case ICmpInst::ICMP_SGT:
    Opc = I32 ? WebAssembly::GT_S_I32 : WebAssembly::GT_S_I64;
    isSigned = true;
    break;
  case ICmpInst::ICMP_SGE:
    Opc = I32 ? WebAssembly::GE_S_I32 : WebAssembly::GE_S_I64;
    isSigned = true;
    break;
  case ICmpInst::ICMP_SLT:
    Opc = I32 ? WebAssembly::LT_S_I32 : WebAssembly::LT_S_I64;
    isSigned = true;
    break;
  case ICmpInst::ICMP_SLE:
    Opc = I32 ? WebAssembly::LE_S_I32 : WebAssembly::LE_S_I64;
    isSigned = true;
    break;
  default: return false;
  }

  unsigned LHS = getRegForPromotedValue(ICmp->getOperand(0), isSigned);
  if (LHS == 0)
    return false;

  unsigned RHS = getRegForPromotedValue(ICmp->getOperand(1), isSigned);
  if (RHS == 0)
    return false;

  unsigned ResultReg = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
      .addReg(LHS)
      .addReg(RHS);
  updateValueMap(ICmp, ResultReg);
  return true;
}

bool WebAssemblyFastISel::selectFCmp(const Instruction *I) {
  const FCmpInst *FCmp = cast<FCmpInst>(I);

  unsigned LHS = getRegForValue(FCmp->getOperand(0));
  if (LHS == 0)
    return false;

  unsigned RHS = getRegForValue(FCmp->getOperand(1));
  if (RHS == 0)
    return false;

  bool F32 = getSimpleType(FCmp->getOperand(0)->getType()) != MVT::f64;
  unsigned Opc;
  bool Not = false;
  switch (FCmp->getPredicate()) {
  case FCmpInst::FCMP_OEQ:
    Opc = F32 ? WebAssembly::EQ_F32 : WebAssembly::EQ_F64;
    break;
  case FCmpInst::FCMP_UNE:
    Opc = F32 ? WebAssembly::NE_F32 : WebAssembly::NE_F64;
    break;
  case FCmpInst::FCMP_OGT:
    Opc = F32 ? WebAssembly::GT_F32 : WebAssembly::GT_F64;
    break;
  case FCmpInst::FCMP_OGE:
    Opc = F32 ? WebAssembly::GE_F32 : WebAssembly::GE_F64;
    break;
  case FCmpInst::FCMP_OLT:
    Opc = F32 ? WebAssembly::LT_F32 : WebAssembly::LT_F64;
    break;
  case FCmpInst::FCMP_OLE:
    Opc = F32 ? WebAssembly::LE_F32 : WebAssembly::LE_F64;
    break;
  case FCmpInst::FCMP_UGT:
    Opc = F32 ? WebAssembly::LE_F32 : WebAssembly::LE_F64;
    Not = true;
    break;
  case FCmpInst::FCMP_UGE:
    Opc = F32 ? WebAssembly::LT_F32 : WebAssembly::LT_F64;
    Not = true;
    break;
  case FCmpInst::FCMP_ULT:
    Opc = F32 ? WebAssembly::GE_F32 : WebAssembly::GE_F64;
    Not = true;
    break;
  case FCmpInst::FCMP_ULE:
    Opc = F32 ? WebAssembly::GT_F32 : WebAssembly::GT_F64;
    Not = true;
    break;
  default:
    return false;
  }

  unsigned ResultReg = createResultReg(&WebAssembly::I32RegClass);
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc), ResultReg)
      .addReg(LHS)
      .addReg(RHS);

  if (Not)
    ResultReg = notValue(ResultReg);

  updateValueMap(FCmp, ResultReg);
  return true;
}

bool WebAssemblyFastISel::selectBitCast(const Instruction *I) {
  // Target-independent code can handle this, except it doesn't set the dead
  // flag on the ARGUMENTS clobber, so we have to do that manually in order
  // to satisfy code that expects this of isBitcast() instructions.
  EVT VT = TLI.getValueType(DL, I->getOperand(0)->getType());
  EVT RetVT = TLI.getValueType(DL, I->getType());
  if (!VT.isSimple() || !RetVT.isSimple())
    return false;

  if (VT == RetVT) {
    // No-op bitcast.
    updateValueMap(I, getRegForValue(I->getOperand(0)));
    return true;
  }

  unsigned Reg = fastEmit_ISD_BITCAST_r(VT.getSimpleVT(), RetVT.getSimpleVT(),
                                        getRegForValue(I->getOperand(0)),
                                        I->getOperand(0)->hasOneUse());
  if (!Reg)
    return false;
  MachineBasicBlock::iterator Iter = FuncInfo.InsertPt;
  --Iter;
  assert(Iter->isBitcast());
  Iter->setPhysRegsDeadExcept(ArrayRef<unsigned>(), TRI);
  updateValueMap(I, Reg);
  return true;
}

bool WebAssemblyFastISel::selectLoad(const Instruction *I) {
  const LoadInst *Load = cast<LoadInst>(I);
  if (Load->isAtomic())
    return false;
  if (!Subtarget->hasSIMD128() && Load->getType()->isVectorTy())
    return false;

  Address Addr;
  if (!computeAddress(Load->getPointerOperand(), Addr))
    return false;

  // TODO: Fold a following sign-/zero-extend into the load instruction.

  unsigned Opc;
  const TargetRegisterClass *RC;
  switch (getSimpleType(Load->getType())) {
  case MVT::i1:
  case MVT::i8:
    Opc = WebAssembly::LOAD8_U_I32;
    RC = &WebAssembly::I32RegClass;
    break;
  case MVT::i16:
    Opc = WebAssembly::LOAD16_U_I32;
    RC = &WebAssembly::I32RegClass;
    break;
  case MVT::i32:
    Opc = WebAssembly::LOAD_I32;
    RC = &WebAssembly::I32RegClass;
    break;
  case MVT::i64:
    Opc = WebAssembly::LOAD_I64;
    RC = &WebAssembly::I64RegClass;
    break;
  case MVT::f32:
    Opc = WebAssembly::LOAD_F32;
    RC = &WebAssembly::F32RegClass;
    break;
  case MVT::f64:
    Opc = WebAssembly::LOAD_F64;
    RC = &WebAssembly::F64RegClass;
    break;
  default:
    return false;
  }

  materializeLoadStoreOperands(Addr);

  unsigned ResultReg = createResultReg(RC);
  auto MIB = BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc),
                     ResultReg);

  addLoadStoreOperands(Addr, MIB, createMachineMemOperandFor(Load));

  updateValueMap(Load, ResultReg);
  return true;
}

bool WebAssemblyFastISel::selectStore(const Instruction *I) {
  const StoreInst *Store = cast<StoreInst>(I);
  if (Store->isAtomic())
    return false;
  if (!Subtarget->hasSIMD128() &&
      Store->getValueOperand()->getType()->isVectorTy())
    return false;

  Address Addr;
  if (!computeAddress(Store->getPointerOperand(), Addr))
    return false;

  unsigned Opc;
  bool VTIsi1 = false;
  switch (getSimpleType(Store->getValueOperand()->getType())) {
  case MVT::i1:
    VTIsi1 = true;
  case MVT::i8:
    Opc = WebAssembly::STORE8_I32;
    break;
  case MVT::i16:
    Opc = WebAssembly::STORE16_I32;
    break;
  case MVT::i32:
    Opc = WebAssembly::STORE_I32;
    break;
  case MVT::i64:
    Opc = WebAssembly::STORE_I64;
    break;
  case MVT::f32:
    Opc = WebAssembly::STORE_F32;
    break;
  case MVT::f64:
    Opc = WebAssembly::STORE_F64;
    break;
  default: return false;
  }

  materializeLoadStoreOperands(Addr);

  unsigned ValueReg = getRegForValue(Store->getValueOperand());
  if (ValueReg == 0)
    return false;
  if (VTIsi1)
    ValueReg = maskI1Value(ValueReg, Store->getValueOperand());

  auto MIB = BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc));

  addLoadStoreOperands(Addr, MIB, createMachineMemOperandFor(Store));

  MIB.addReg(ValueReg);
  return true;
}

bool WebAssemblyFastISel::selectBr(const Instruction *I) {
  const BranchInst *Br = cast<BranchInst>(I);
  if (Br->isUnconditional()) {
    MachineBasicBlock *MSucc = FuncInfo.MBBMap[Br->getSuccessor(0)];
    fastEmitBranch(MSucc, Br->getDebugLoc());
    return true;
  }

  MachineBasicBlock *TBB = FuncInfo.MBBMap[Br->getSuccessor(0)];
  MachineBasicBlock *FBB = FuncInfo.MBBMap[Br->getSuccessor(1)];

  bool Not;
  unsigned CondReg = getRegForI1Value(Br->getCondition(), Not);
  if (CondReg == 0)
    return false;

  unsigned Opc = WebAssembly::BR_IF;
  if (Not)
    Opc = WebAssembly::BR_UNLESS;

  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc))
      .addMBB(TBB)
      .addReg(CondReg);

  finishCondBranch(Br->getParent(), TBB, FBB);
  return true;
}

bool WebAssemblyFastISel::selectRet(const Instruction *I) {
  if (!FuncInfo.CanLowerReturn)
    return false;

  const ReturnInst *Ret = cast<ReturnInst>(I);

  if (Ret->getNumOperands() == 0) {
    BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
            TII.get(WebAssembly::RETURN_VOID));
    return true;
  }

  Value *RV = Ret->getOperand(0);
  if (!Subtarget->hasSIMD128() && RV->getType()->isVectorTy())
    return false;

  unsigned Opc;
  switch (getSimpleType(RV->getType())) {
  case MVT::i1: case MVT::i8:
  case MVT::i16: case MVT::i32:
    Opc = WebAssembly::RETURN_I32;
    break;
  case MVT::i64:
    Opc = WebAssembly::RETURN_I64;
    break;
  case MVT::f32:
    Opc = WebAssembly::RETURN_F32;
    break;
  case MVT::f64:
    Opc = WebAssembly::RETURN_F64;
    break;
  case MVT::v16i8:
    Opc = WebAssembly::RETURN_v16i8;
    break;
  case MVT::v8i16:
    Opc = WebAssembly::RETURN_v8i16;
    break;
  case MVT::v4i32:
    Opc = WebAssembly::RETURN_v4i32;
    break;
  case MVT::v4f32:
    Opc = WebAssembly::RETURN_v4f32;
    break;
  default: return false;
  }

  unsigned Reg;
  if (FuncInfo.Fn->getAttributes().hasAttribute(0, Attribute::SExt))
    Reg = getRegForSignedValue(RV);
  else if (FuncInfo.Fn->getAttributes().hasAttribute(0, Attribute::ZExt))
    Reg = getRegForUnsignedValue(RV);
  else
    Reg = getRegForValue(RV);

  if (Reg == 0)
    return false;

  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc, TII.get(Opc)).addReg(Reg);
  return true;
}

bool WebAssemblyFastISel::selectUnreachable(const Instruction *I) {
  BuildMI(*FuncInfo.MBB, FuncInfo.InsertPt, DbgLoc,
          TII.get(WebAssembly::UNREACHABLE));
  return true;
}

bool WebAssemblyFastISel::fastSelectInstruction(const Instruction *I) {
  switch (I->getOpcode()) {
  case Instruction::Call:
    if (selectCall(I))
      return true;
    break;
  case Instruction::Select:      return selectSelect(I);
  case Instruction::Trunc:       return selectTrunc(I);
  case Instruction::ZExt:        return selectZExt(I);
  case Instruction::SExt:        return selectSExt(I);
  case Instruction::ICmp:        return selectICmp(I);
  case Instruction::FCmp:        return selectFCmp(I);
  case Instruction::BitCast:     return selectBitCast(I);
  case Instruction::Load:        return selectLoad(I);
  case Instruction::Store:       return selectStore(I);
  case Instruction::Br:          return selectBr(I);
  case Instruction::Ret:         return selectRet(I);
  case Instruction::Unreachable: return selectUnreachable(I);
  default: break;
  }

  // Fall back to target-independent instruction selection.
  return selectOperator(I, I->getOpcode());
}

FastISel *WebAssembly::createFastISel(FunctionLoweringInfo &FuncInfo,
                                      const TargetLibraryInfo *LibInfo) {
  return new WebAssemblyFastISel(FuncInfo, LibInfo);
}
