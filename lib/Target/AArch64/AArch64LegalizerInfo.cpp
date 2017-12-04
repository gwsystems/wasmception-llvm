//===- AArch64LegalizerInfo.cpp ----------------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the Machinelegalizer class for
/// AArch64.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "AArch64LegalizerInfo.h"
#include "AArch64Subtarget.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetOpcodes.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Type.h"

using namespace llvm;

/// FIXME: The following static functions are SizeChangeStrategy functions
/// that are meant to temporarily mimic the behaviour of the old legalization
/// based on doubling/halving non-legal types as closely as possible. This is
/// not entirly possible as only legalizing the types that are exactly a power
/// of 2 times the size of the legal types would require specifying all those
/// sizes explicitly.
/// In practice, not specifying those isn't a problem, and the below functions
/// should disappear quickly as we add support for legalizing non-power-of-2
/// sized types further.
static void
addAndInterleaveWithUnsupported(LegalizerInfo::SizeAndActionsVec &result,
                                const LegalizerInfo::SizeAndActionsVec &v) {
  for (unsigned i = 0; i < v.size(); ++i) {
    result.push_back(v[i]);
    if (i + 1 < v[i].first && i + 1 < v.size() &&
        v[i + 1].first != v[i].first + 1)
      result.push_back({v[i].first + 1, LegalizerInfo::Unsupported});
  }
}

static LegalizerInfo::SizeAndActionsVec
widen_1_narrow_128_ToLargest(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 2);
  LegalizerInfo::SizeAndActionsVec result = {{1, LegalizerInfo::WidenScalar},
                                             {2, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  assert(Largest + 1 < 128);
  result.push_back({Largest + 1, LegalizerInfo::Unsupported});
  result.push_back({128, LegalizerInfo::NarrowScalar});
  result.push_back({129, LegalizerInfo::Unsupported});
  return result;
}

static LegalizerInfo::SizeAndActionsVec
widen_16(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 17);
  LegalizerInfo::SizeAndActionsVec result = {{1, LegalizerInfo::Unsupported},
                                             {16, LegalizerInfo::WidenScalar},
                                             {17, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegalizerInfo::Unsupported});
  return result;
}

static LegalizerInfo::SizeAndActionsVec
widen_1_8(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 9);
  LegalizerInfo::SizeAndActionsVec result = {
      {1, LegalizerInfo::WidenScalar},  {2, LegalizerInfo::Unsupported},
      {8, LegalizerInfo::WidenScalar},  {9, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegalizerInfo::Unsupported});
  return result;
}

static LegalizerInfo::SizeAndActionsVec
widen_1_8_16(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 17);
  LegalizerInfo::SizeAndActionsVec result = {
      {1, LegalizerInfo::WidenScalar},  {2, LegalizerInfo::Unsupported},
      {8, LegalizerInfo::WidenScalar},  {9, LegalizerInfo::Unsupported},
      {16, LegalizerInfo::WidenScalar}, {17, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegalizerInfo::Unsupported});
  return result;
}

static LegalizerInfo::SizeAndActionsVec
widen_1_8_16_narrowToLargest(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 17);
  LegalizerInfo::SizeAndActionsVec result = {
      {1, LegalizerInfo::WidenScalar},  {2, LegalizerInfo::Unsupported},
      {8, LegalizerInfo::WidenScalar},  {9, LegalizerInfo::Unsupported},
      {16, LegalizerInfo::WidenScalar}, {17, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegalizerInfo::NarrowScalar});
  return result;
}

static LegalizerInfo::SizeAndActionsVec
widen_1_8_16_32(const LegalizerInfo::SizeAndActionsVec &v) {
  assert(v.size() >= 1);
  assert(v[0].first > 33);
  LegalizerInfo::SizeAndActionsVec result = {
      {1, LegalizerInfo::WidenScalar},  {2, LegalizerInfo::Unsupported},
      {8, LegalizerInfo::WidenScalar},  {9, LegalizerInfo::Unsupported},
      {16, LegalizerInfo::WidenScalar}, {17, LegalizerInfo::Unsupported},
      {32, LegalizerInfo::WidenScalar}, {33, LegalizerInfo::Unsupported}};
  addAndInterleaveWithUnsupported(result, v);
  auto Largest = result.back().first;
  result.push_back({Largest + 1, LegalizerInfo::Unsupported});
  return result;
}

AArch64LegalizerInfo::AArch64LegalizerInfo(const AArch64Subtarget &ST) {
  using namespace TargetOpcode;
  const LLT p0 = LLT::pointer(0, 64);
  const LLT s1 = LLT::scalar(1);
  const LLT s8 = LLT::scalar(8);
  const LLT s16 = LLT::scalar(16);
  const LLT s32 = LLT::scalar(32);
  const LLT s64 = LLT::scalar(64);
  const LLT s128 = LLT::scalar(128);
  const LLT v2s32 = LLT::vector(2, 32);
  const LLT v4s32 = LLT::vector(4, 32);
  const LLT v2s64 = LLT::vector(2, 64);

  for (auto Ty : {p0, s1, s8, s16, s32, s64})
    setAction({G_IMPLICIT_DEF, Ty}, Legal);

  for (auto Ty : {s16, s32, s64, p0})
    setAction({G_PHI, Ty}, Legal);

  setLegalizeScalarToDifferentSizeStrategy(G_PHI, 0, widen_1_8);

  for (auto Ty : { s32, s64 })
    setAction({G_BSWAP, Ty}, Legal);

  for (unsigned BinOp : {G_ADD, G_SUB, G_MUL, G_AND, G_OR, G_XOR, G_SHL}) {
    // These operations naturally get the right answer when used on
    // GPR32, even if the actual type is narrower.
    for (auto Ty : {s32, s64, v2s32, v4s32, v2s64})
      setAction({BinOp, Ty}, Legal);

    if (BinOp != G_ADD)
      setLegalizeScalarToDifferentSizeStrategy(BinOp, 0,
                                               widen_1_8_16_narrowToLargest);
  }

  setAction({G_GEP, p0}, Legal);
  setAction({G_GEP, 1, s64}, Legal);

  setLegalizeScalarToDifferentSizeStrategy(G_GEP, 1, widen_1_8_16_32);

  setAction({G_PTR_MASK, p0}, Legal);

  for (unsigned BinOp : {G_LSHR, G_ASHR, G_SDIV, G_UDIV}) {
    for (auto Ty : {s32, s64})
      setAction({BinOp, Ty}, Legal);

    setLegalizeScalarToDifferentSizeStrategy(BinOp, 0, widen_1_8_16);
  }

  for (unsigned BinOp : {G_SREM, G_UREM})
    for (auto Ty : { s1, s8, s16, s32, s64 })
      setAction({BinOp, Ty}, Lower);

  for (unsigned Op : {G_SMULO, G_UMULO}) {
    setAction({Op, 0, s64}, Lower);
    setAction({Op, 1, s1}, Legal);
  }

  for (unsigned Op : {G_UADDE, G_USUBE, G_SADDO, G_SSUBO, G_SMULH, G_UMULH}) {
    for (auto Ty : { s32, s64 })
      setAction({Op, Ty}, Legal);

    setAction({Op, 1, s1}, Legal);
  }

  for (unsigned BinOp : {G_FADD, G_FSUB, G_FMA, G_FMUL, G_FDIV})
    for (auto Ty : {s32, s64})
      setAction({BinOp, Ty}, Legal);

  for (unsigned BinOp : {G_FREM, G_FPOW}) {
    setAction({BinOp, s32}, Libcall);
    setAction({BinOp, s64}, Libcall);
  }

  for (auto Ty : {s32, s64, p0}) {
    setAction({G_INSERT, Ty}, Legal);
    setAction({G_INSERT, 1, Ty}, Legal);
  }
  setLegalizeScalarToDifferentSizeStrategy(G_INSERT, 0,
                                           widen_1_8_16_narrowToLargest);
  for (auto Ty : {s1, s8, s16}) {
    setAction({G_INSERT, 1, Ty}, Legal);
    // FIXME: Can't widen the sources because that violates the constraints on
    // G_INSERT (It seems entirely reasonable that inputs shouldn't overlap).
  }

  for (auto Ty : {s1, s8, s16, s32, s64, p0})
    setAction({G_EXTRACT, Ty}, Legal);

  for (auto Ty : {s32, s64})
    setAction({G_EXTRACT, 1, Ty}, Legal);

  for (unsigned MemOp : {G_LOAD, G_STORE}) {
    for (auto Ty : {s8, s16, s32, s64, p0, v2s32})
      setAction({MemOp, Ty}, Legal);

    setLegalizeScalarToDifferentSizeStrategy(MemOp, 0,
                                             widen_1_narrow_128_ToLargest);

    // And everything's fine in addrspace 0.
    setAction({MemOp, 1, p0}, Legal);
  }

  for (unsigned MemOp : {G_ATOMIC_LOAD, G_ATOMIC_STORE}) {
    for (auto Ty : {s8, s16, s32, s64, p0})
      setAction({MemOp, Ty}, Legal);

    // And everything's fine in addrspace 0.
    setAction({MemOp, 1, p0}, Legal);
  }

  // Constants
  for (auto Ty : {s32, s64}) {
    setAction({TargetOpcode::G_CONSTANT, Ty}, Legal);
    setAction({TargetOpcode::G_FCONSTANT, Ty}, Legal);
  }

  setAction({G_CONSTANT, p0}, Legal);

  setLegalizeScalarToDifferentSizeStrategy(G_CONSTANT, 0, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_FCONSTANT, 0, widen_16);

  setAction({G_ICMP, 1, s32}, Legal);
  setAction({G_ICMP, 1, s64}, Legal);
  setAction({G_ICMP, 1, p0}, Legal);

  setLegalizeScalarToDifferentSizeStrategy(G_ICMP, 0, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_FCMP, 0, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_ICMP, 1, widen_1_8_16);

  setAction({G_ICMP, s32}, Legal);
  setAction({G_FCMP, s32}, Legal);
  setAction({G_FCMP, 1, s32}, Legal);
  setAction({G_FCMP, 1, s64}, Legal);

  // Extensions
  for (auto Ty : { s1, s8, s16, s32, s64 }) {
    setAction({G_ZEXT, Ty}, Legal);
    setAction({G_SEXT, Ty}, Legal);
    setAction({G_ANYEXT, Ty}, Legal);
  }

  // FP conversions
  for (auto Ty : { s16, s32 }) {
    setAction({G_FPTRUNC, Ty}, Legal);
    setAction({G_FPEXT, 1, Ty}, Legal);
  }

  for (auto Ty : { s32, s64 }) {
    setAction({G_FPTRUNC, 1, Ty}, Legal);
    setAction({G_FPEXT, Ty}, Legal);
  }

  // Conversions
  for (auto Ty : { s32, s64 }) {
    setAction({G_FPTOSI, 0, Ty}, Legal);
    setAction({G_FPTOUI, 0, Ty}, Legal);
    setAction({G_SITOFP, 1, Ty}, Legal);
    setAction({G_UITOFP, 1, Ty}, Legal);
  }
  setLegalizeScalarToDifferentSizeStrategy(G_FPTOSI, 0, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_FPTOUI, 0, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_SITOFP, 1, widen_1_8_16);
  setLegalizeScalarToDifferentSizeStrategy(G_UITOFP, 1, widen_1_8_16);

  for (auto Ty : { s32, s64 }) {
    setAction({G_FPTOSI, 1, Ty}, Legal);
    setAction({G_FPTOUI, 1, Ty}, Legal);
    setAction({G_SITOFP, 0, Ty}, Legal);
    setAction({G_UITOFP, 0, Ty}, Legal);
  }

  // Control-flow
  for (auto Ty : {s1, s8, s16, s32})
    setAction({G_BRCOND, Ty}, Legal);
  setAction({G_BRINDIRECT, p0}, Legal);

  // Select
  setLegalizeScalarToDifferentSizeStrategy(G_SELECT, 0, widen_1_8_16);

  for (auto Ty : {s32, s64, p0})
    setAction({G_SELECT, Ty}, Legal);

  setAction({G_SELECT, 1, s1}, Legal);

  // Pointer-handling
  setAction({G_FRAME_INDEX, p0}, Legal);
  setAction({G_GLOBAL_VALUE, p0}, Legal);

  for (auto Ty : {s1, s8, s16, s32, s64})
    setAction({G_PTRTOINT, 0, Ty}, Legal);

  setAction({G_PTRTOINT, 1, p0}, Legal);

  setAction({G_INTTOPTR, 0, p0}, Legal);
  setAction({G_INTTOPTR, 1, s64}, Legal);

  // Casts for 32 and 64-bit width type are just copies.
  // Same for 128-bit width type, except they are on the FPR bank.
  for (auto Ty : {s1, s8, s16, s32, s64, s128}) {
    setAction({G_BITCAST, 0, Ty}, Legal);
    setAction({G_BITCAST, 1, Ty}, Legal);
  }

  // For the sake of copying bits around, the type does not really
  // matter as long as it fits a register.
  for (int EltSize = 8; EltSize <= 64; EltSize *= 2) {
    setAction({G_BITCAST, 0, LLT::vector(128/EltSize, EltSize)}, Legal);
    setAction({G_BITCAST, 1, LLT::vector(128/EltSize, EltSize)}, Legal);
    if (EltSize >= 64)
      continue;

    setAction({G_BITCAST, 0, LLT::vector(64/EltSize, EltSize)}, Legal);
    setAction({G_BITCAST, 1, LLT::vector(64/EltSize, EltSize)}, Legal);
    if (EltSize >= 32)
      continue;

    setAction({G_BITCAST, 0, LLT::vector(32/EltSize, EltSize)}, Legal);
    setAction({G_BITCAST, 1, LLT::vector(32/EltSize, EltSize)}, Legal);
  }

  setAction({G_VASTART, p0}, Legal);

  // va_list must be a pointer, but most sized types are pretty easy to handle
  // as the destination.
  setAction({G_VAARG, 1, p0}, Legal);

  for (auto Ty : {s8, s16, s32, s64, p0})
    setAction({G_VAARG, Ty}, Custom);

  if (ST.hasLSE()) {
    for (auto Ty : {s8, s16, s32, s64}) {
      setAction({G_ATOMIC_CMPXCHG_WITH_SUCCESS, Ty}, Lower);
      setAction({G_ATOMIC_CMPXCHG, Ty}, Legal);
    }
    setAction({G_ATOMIC_CMPXCHG, 1, p0}, Legal);

    for (unsigned Op :
         {G_ATOMICRMW_XCHG, G_ATOMICRMW_ADD, G_ATOMICRMW_SUB, G_ATOMICRMW_AND,
          G_ATOMICRMW_OR, G_ATOMICRMW_XOR, G_ATOMICRMW_MIN, G_ATOMICRMW_MAX,
          G_ATOMICRMW_UMIN, G_ATOMICRMW_UMAX}) {
      for (auto Ty : {s8, s16, s32, s64}) {
        setAction({Op, Ty}, Legal);
      }
      setAction({Op, 1, p0}, Legal);
    }
  }

  // Merge/Unmerge
  for (unsigned Op : {G_MERGE_VALUES, G_UNMERGE_VALUES})
    for (int Sz : {8, 16, 32, 64, 128, 192, 256, 384, 512}) {
      LLT ScalarTy = LLT::scalar(Sz);
      setAction({Op, ScalarTy}, Legal);
      setAction({Op, 1, ScalarTy}, Legal);
      if (Sz < 32)
        continue;
      for (int EltSize = 8; EltSize <= 64; EltSize *= 2) {
        if (EltSize >= Sz)
          continue;
        LLT VecTy = LLT::vector(Sz / EltSize, EltSize);
        setAction({Op, VecTy}, Legal);
        setAction({Op, 1, VecTy}, Legal);
      }
    }

  computeTables();
}

bool AArch64LegalizerInfo::legalizeCustom(MachineInstr &MI,
                                          MachineRegisterInfo &MRI,
                                          MachineIRBuilder &MIRBuilder) const {
  switch (MI.getOpcode()) {
  default:
    // No idea what to do.
    return false;
  case TargetOpcode::G_VAARG:
    return legalizeVaArg(MI, MRI, MIRBuilder);
  }

  llvm_unreachable("expected switch to return");
}

bool AArch64LegalizerInfo::legalizeVaArg(MachineInstr &MI,
                                         MachineRegisterInfo &MRI,
                                         MachineIRBuilder &MIRBuilder) const {
  MIRBuilder.setInstr(MI);
  MachineFunction &MF = MIRBuilder.getMF();
  unsigned Align = MI.getOperand(2).getImm();
  unsigned Dst = MI.getOperand(0).getReg();
  unsigned ListPtr = MI.getOperand(1).getReg();

  LLT PtrTy = MRI.getType(ListPtr);
  LLT IntPtrTy = LLT::scalar(PtrTy.getSizeInBits());

  const unsigned PtrSize = PtrTy.getSizeInBits() / 8;
  unsigned List = MRI.createGenericVirtualRegister(PtrTy);
  MIRBuilder.buildLoad(
      List, ListPtr,
      *MF.getMachineMemOperand(MachinePointerInfo(), MachineMemOperand::MOLoad,
                               PtrSize, /* Align = */ PtrSize));

  unsigned DstPtr;
  if (Align > PtrSize) {
    // Realign the list to the actual required alignment.
    auto AlignMinus1 = MIRBuilder.buildConstant(IntPtrTy, Align - 1);

    unsigned ListTmp = MRI.createGenericVirtualRegister(PtrTy);
    MIRBuilder.buildGEP(ListTmp, List, AlignMinus1->getOperand(0).getReg());

    DstPtr = MRI.createGenericVirtualRegister(PtrTy);
    MIRBuilder.buildPtrMask(DstPtr, ListTmp, Log2_64(Align));
  } else
    DstPtr = List;

  uint64_t ValSize = MRI.getType(Dst).getSizeInBits() / 8;
  MIRBuilder.buildLoad(
      Dst, DstPtr,
      *MF.getMachineMemOperand(MachinePointerInfo(), MachineMemOperand::MOLoad,
                               ValSize, std::max(Align, PtrSize)));

  unsigned SizeReg = MRI.createGenericVirtualRegister(IntPtrTy);
  MIRBuilder.buildConstant(SizeReg, alignTo(ValSize, PtrSize));

  unsigned NewList = MRI.createGenericVirtualRegister(PtrTy);
  MIRBuilder.buildGEP(NewList, DstPtr, SizeReg);

  MIRBuilder.buildStore(
      NewList, ListPtr,
      *MF.getMachineMemOperand(MachinePointerInfo(), MachineMemOperand::MOStore,
                               PtrSize, /* Align = */ PtrSize));

  MI.eraseFromParent();
  return true;
}
