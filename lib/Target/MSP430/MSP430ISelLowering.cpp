//===-- MSP430ISelLowering.cpp - MSP430 DAG Lowering Implementation  ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the MSP430TargetLowering class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "msp430-lower"

#include "MSP430ISelLowering.h"
#include "MSP430.h"
#include "MSP430TargetMachine.h"
#include "MSP430Subtarget.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Function.h"
#include "llvm/Intrinsics.h"
#include "llvm/CallingConv.h"
#include "llvm/GlobalVariable.h"
#include "llvm/GlobalAlias.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/Support/Debug.h"
#include "llvm/ADT/VectorExtras.h"
using namespace llvm;

MSP430TargetLowering::MSP430TargetLowering(MSP430TargetMachine &tm) :
  TargetLowering(tm), Subtarget(*tm.getSubtargetImpl()), TM(tm) {

  // Set up the register classes.
  addRegisterClass(MVT::i16, MSP430::MSP430RegsRegisterClass);

  // Compute derived properties from the register classes
  computeRegisterProperties();
}

SDValue MSP430TargetLowering::
LowerOperation(SDValue Op, SelectionDAG &DAG) {
  switch (Op.getOpcode()) {
  case ISD::FORMAL_ARGUMENTS: return LowerFORMAL_ARGUMENTS(Op, DAG);
  default:
    assert(0 && "unimplemented operand");
    return SDValue();
  }
}

//===----------------------------------------------------------------------===//
//                      Calling Convention Implementation
//===----------------------------------------------------------------------===//

#include "MSP430GenCallingConv.inc"

SDValue MSP430TargetLowering::LowerFORMAL_ARGUMENTS(SDValue Op,
                                                    SelectionDAG &DAG) {
  unsigned CC = cast<ConstantSDNode>(Op.getOperand(1))->getZExtValue();
  switch (CC) {
  default:
    assert(0 && "Unsupported calling convention");
  case CallingConv::C:
  case CallingConv::Fast:
    return LowerCCCArguments(Op, DAG);
  }
}

/// LowerCCCArguments - transform physical registers into virtual registers and
/// generate load operations for arguments places on the stack.
// FIXME: struct return stuff
// FIXME: varargs
SDValue MSP430TargetLowering:: LowerCCCArguments(SDValue Op,
                                                 SelectionDAG &DAG) {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  SDValue Root = Op.getOperand(0);
  bool isVarArg = cast<ConstantSDNode>(Op.getOperand(2))->getZExtValue() != 0;
  unsigned CC = MF.getFunction()->getCallingConv();
  DebugLoc dl = Op.getDebugLoc();

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CC, isVarArg, getTargetMachine(), ArgLocs);
  CCInfo.AnalyzeFormalArguments(Op.getNode(), CC_MSP430);

  assert(!isVarArg && "Varargs not supported yet");

  SmallVector<SDValue, 16> ArgValues;
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    if (VA.isRegLoc()) {
      // Arguments passed in registers
      MVT RegVT = VA.getLocVT();
      switch (RegVT.getSimpleVT()) {
      default:
        cerr << "LowerFORMAL_ARGUMENTS Unhandled argument type: "
             << RegVT.getSimpleVT()
             << "\n";
        abort();
      case MVT::i16:
        unsigned VReg =
          RegInfo.createVirtualRegister(MSP430::MSP430RegsRegisterClass);
        RegInfo.addLiveIn(VA.getLocReg(), VReg);
        SDValue ArgValue = DAG.getCopyFromReg(Root, dl, VReg, RegVT);

        // If this is an 8-bit value, it is really passed promoted to 16
        // bits. Insert an assert[sz]ext to capture this, then truncate to the
        // right size.
        if (VA.getLocInfo() == CCValAssign::SExt)
          ArgValue = DAG.getNode(ISD::AssertSext, dl, RegVT, ArgValue,
                                 DAG.getValueType(VA.getValVT()));
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          ArgValue = DAG.getNode(ISD::AssertZext, dl, RegVT, ArgValue,
                                 DAG.getValueType(VA.getValVT()));

        if (VA.getLocInfo() != CCValAssign::Full)
          ArgValue = DAG.getNode(ISD::TRUNCATE, dl, VA.getValVT(), ArgValue);

        ArgValues.push_back(ArgValue);
      }
    } else {
      // Sanity check
      assert(VA.isMemLoc());
      // Load the argument to a virtual register
      unsigned ObjSize = VA.getLocVT().getSizeInBits()/8;
      if (ObjSize > 2) {
        cerr << "LowerFORMAL_ARGUMENTS Unhandled argument type: "
             << VA.getLocVT().getSimpleVT()
             << "\n";
      }
      // Create the frame index object for this incoming parameter...
      int FI = MFI->CreateFixedObject(ObjSize, VA.getLocMemOffset());

      // Create the SelectionDAG nodes corresponding to a load
      //from this parameter
      SDValue FIN = DAG.getFrameIndex(FI, MVT::i16);
      ArgValues.push_back(DAG.getLoad(VA.getLocVT(), dl, Root, FIN,
                                      PseudoSourceValue::getFixedStack(FI), 0));
    }
  }

  ArgValues.push_back(Root);

  // Return the new list of results.
  return DAG.getNode(ISD::MERGE_VALUES, dl, Op.getNode()->getVTList(),
                     &ArgValues[0], ArgValues.size()).getValue(Op.getResNo());
}
