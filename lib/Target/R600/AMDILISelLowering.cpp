//===-- AMDILISelLowering.cpp - AMDIL DAG Lowering Implementation ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//==-----------------------------------------------------------------------===//
//
/// \file
/// \brief TargetLowering functions borrowed from AMDIL.
//
//===----------------------------------------------------------------------===//

#include "AMDGPUISelLowering.h"
#include "AMDGPURegisterInfo.h"
#include "AMDGPUSubtarget.h"
#include "AMDILIntrinsicInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;
//===----------------------------------------------------------------------===//
// TargetLowering Implementation Help Functions End
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// TargetLowering Class Implementation Begins
//===----------------------------------------------------------------------===//
void AMDGPUTargetLowering::InitAMDILLowering() {
  static const MVT::SimpleValueType types[] = {
    MVT::i32,
    MVT::f32,
    MVT::f64,
    MVT::i64,
    MVT::v4f32,
    MVT::v4i32,
    MVT::v2f32,
    MVT::v2i32
  };

  static const MVT::SimpleValueType FloatTypes[] = {
    MVT::f32,
    MVT::f64
  };

  static const MVT::SimpleValueType VectorTypes[] = {
    MVT::v4f32,
    MVT::v4i32,
    MVT::v2f32,
    MVT::v2i32
  };

  const AMDGPUSubtarget &STM = getTargetMachine().getSubtarget<AMDGPUSubtarget>();

  for (MVT VT : types) {
    setOperationAction(ISD::SUBE, VT, Expand);
    setOperationAction(ISD::SUBC, VT, Expand);
    setOperationAction(ISD::ADDE, VT, Expand);
    setOperationAction(ISD::ADDC, VT, Expand);
    setOperationAction(ISD::BRCOND, VT, Custom);
    setOperationAction(ISD::BR_JT, VT, Expand);
    setOperationAction(ISD::BRIND, VT, Expand);
    // TODO: Implement custom UREM/SREM routines
    setOperationAction(ISD::SREM, VT, Expand);
    setOperationAction(ISD::SMUL_LOHI, VT, Expand);
    setOperationAction(ISD::UMUL_LOHI, VT, Expand);
    if (VT != MVT::i64)
      setOperationAction(ISD::SDIV, VT, Custom);
  }

  for (MVT VT : FloatTypes) {
    setOperationAction(ISD::FP_ROUND_INREG, VT, Expand);
  }

  for (MVT VT : VectorTypes) {
    setOperationAction(ISD::VECTOR_SHUFFLE, VT, Expand);
    setOperationAction(ISD::SELECT_CC, VT, Expand);
  }

  setOperationAction(ISD::MULHU, MVT::i64, Expand);
  setOperationAction(ISD::MULHS, MVT::i64, Expand);
  if (STM.hasHWFP64()) {
    setOperationAction(ISD::ConstantFP, MVT::f64, Legal);
    setOperationAction(ISD::FABS, MVT::f64, Expand);
  }

  setOperationAction(ISD::SUBC, MVT::Other, Expand);
  setOperationAction(ISD::ADDE, MVT::Other, Expand);
  setOperationAction(ISD::ADDC, MVT::Other, Expand);
  setOperationAction(ISD::BRCOND, MVT::Other, Custom);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  setOperationAction(ISD::BRIND, MVT::Other, Expand);

  setOperationAction(ISD::Constant, MVT::i32, Legal);
  setOperationAction(ISD::Constant, MVT::i64, Legal);
  setOperationAction(ISD::ConstantFP, MVT::f32, Legal);

  setPow2DivIsCheap(false);
  setSelectIsExpensive(true); // FIXME: This makes no sense at all
}

bool
AMDGPUTargetLowering::getTgtMemIntrinsic(IntrinsicInfo &Info,
    const CallInst &I, unsigned Intrinsic) const {
  return false;
}

// The backend supports 32 and 64 bit floating point immediates
bool
AMDGPUTargetLowering::isFPImmLegal(const APFloat &Imm, EVT VT) const {
  if (VT.getScalarType().getSimpleVT().SimpleTy == MVT::f32
      || VT.getScalarType().getSimpleVT().SimpleTy == MVT::f64) {
    return true;
  } else {
    return false;
  }
}

bool
AMDGPUTargetLowering::ShouldShrinkFPConstant(EVT VT) const {
  if (VT.getScalarType().getSimpleVT().SimpleTy == MVT::f32
      || VT.getScalarType().getSimpleVT().SimpleTy == MVT::f64) {
    return false;
  } else {
    return true;
  }
}

//===----------------------------------------------------------------------===//
//                           Other Lowering Hooks
//===----------------------------------------------------------------------===//

SDValue AMDGPUTargetLowering::LowerBRCOND(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  SDValue Cond  = Op.getOperand(1);
  SDValue Jump  = Op.getOperand(2);

  return DAG.getNode(AMDGPUISD::BRANCH_COND, SDLoc(Op), Op.getValueType(),
                     Chain, Jump, Cond);
}
