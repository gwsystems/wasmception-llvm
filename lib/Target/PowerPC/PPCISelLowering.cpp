//===-- PPC32ISelLowering.cpp - PPC32 DAG Lowering Implementation ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Chris Lattner and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the PPC32ISelLowering class.
//
//===----------------------------------------------------------------------===//

#include "PPCISelLowering.h"
#include "PPCTargetMachine.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SSARegMap.h"
#include "llvm/Constants.h"
#include "llvm/Function.h"
using namespace llvm;

PPC32TargetLowering::PPC32TargetLowering(TargetMachine &TM)
  : TargetLowering(TM) {
    
  // Fold away setcc operations if possible.
  setSetCCIsExpensive();
  
  // Use _setjmp/_longjmp instead of setjmp/longjmp.
  setUseUnderscoreSetJmpLongJmp(true);
    
  // Set up the register classes.
  addRegisterClass(MVT::i32, PPC32::GPRCRegisterClass);
  addRegisterClass(MVT::f32, PPC32::F4RCRegisterClass);
  addRegisterClass(MVT::f64, PPC32::F8RCRegisterClass);
  
  // PowerPC has no intrinsics for these particular operations
  setOperationAction(ISD::MEMMOVE, MVT::Other, Expand);
  setOperationAction(ISD::MEMSET, MVT::Other, Expand);
  setOperationAction(ISD::MEMCPY, MVT::Other, Expand);
  
  // PowerPC has an i16 but no i8 (or i1) SEXTLOAD
  setOperationAction(ISD::SEXTLOAD, MVT::i1, Expand);
  setOperationAction(ISD::SEXTLOAD, MVT::i8, Expand);
  
  // PowerPC has no SREM/UREM instructions
  setOperationAction(ISD::SREM, MVT::i32, Expand);
  setOperationAction(ISD::UREM, MVT::i32, Expand);
  
  // We don't support sin/cos/sqrt/fmod
  setOperationAction(ISD::FSIN , MVT::f64, Expand);
  setOperationAction(ISD::FCOS , MVT::f64, Expand);
  setOperationAction(ISD::FREM , MVT::f64, Expand);
  setOperationAction(ISD::FSIN , MVT::f32, Expand);
  setOperationAction(ISD::FCOS , MVT::f32, Expand);
  setOperationAction(ISD::FREM , MVT::f32, Expand);
  
  // If we're enabling GP optimizations, use hardware square root
  if (!TM.getSubtarget<PPCSubtarget>().hasFSQRT()) {
    setOperationAction(ISD::FSQRT, MVT::f64, Expand);
    setOperationAction(ISD::FSQRT, MVT::f32, Expand);
  }
  
  // PowerPC does not have CTPOP or CTTZ
  setOperationAction(ISD::CTPOP, MVT::i32  , Expand);
  setOperationAction(ISD::CTTZ , MVT::i32  , Expand);
  
  // PowerPC does not have Select
  setOperationAction(ISD::SELECT, MVT::i32, Expand);
  setOperationAction(ISD::SELECT, MVT::f32, Expand);
  setOperationAction(ISD::SELECT, MVT::f64, Expand);
  
  // PowerPC wants to turn select_cc of FP into fsel when possible.
  setOperationAction(ISD::SELECT_CC, MVT::f32, Custom);
  setOperationAction(ISD::SELECT_CC, MVT::f64, Custom);
  
  // PowerPC wants to expand i64 shifts itself.
  setOperationAction(ISD::SHL, MVT::i64, Custom);
  setOperationAction(ISD::SRL, MVT::i64, Custom);
  setOperationAction(ISD::SRA, MVT::i64, Custom);

  // PowerPC does not have BRCOND* which requires SetCC
  setOperationAction(ISD::BRCOND,       MVT::Other, Expand);
  setOperationAction(ISD::BRCONDTWOWAY, MVT::Other, Expand);
  
  // PowerPC does not have FP_TO_UINT
  setOperationAction(ISD::FP_TO_UINT, MVT::i32, Expand);
  
  // PowerPC turns FP_TO_SINT into FCTIWZ and some load/stores.
  setOperationAction(ISD::FP_TO_SINT, MVT::i32, Custom);

  // PowerPC does not have [U|S]INT_TO_FP
  setOperationAction(ISD::SINT_TO_FP, MVT::i32, Expand);
  setOperationAction(ISD::UINT_TO_FP, MVT::i32, Expand);

  // PowerPC does not have truncstore for i1.
  setOperationAction(ISD::TRUNCSTORE, MVT::i1, Promote);
  
  // 64 bit PowerPC implementations have instructions to facilitate conversion
  // between i64 and fp.
  if (TM.getSubtarget<PPCSubtarget>().is64Bit()) {
    setOperationAction(ISD::FP_TO_SINT, MVT::i64, Custom);
    setOperationAction(ISD::SINT_TO_FP, MVT::i64, Custom);
  }
  
  setSetCCResultContents(ZeroOrOneSetCCResult);
  
  computeRegisterProperties();
}

/// isFloatingPointZero - Return true if this is 0.0 or -0.0.
static bool isFloatingPointZero(SDOperand Op) {
  if (ConstantFPSDNode *CFP = dyn_cast<ConstantFPSDNode>(Op))
    return CFP->isExactlyValue(-0.0) || CFP->isExactlyValue(0.0);
  else if (Op.getOpcode() == ISD::EXTLOAD || Op.getOpcode() == ISD::LOAD) {
    // Maybe this has already been legalized into the constant pool?
    if (ConstantPoolSDNode *CP = dyn_cast<ConstantPoolSDNode>(Op.getOperand(1)))
      if (ConstantFP *CFP = dyn_cast<ConstantFP>(CP->get()))
        return CFP->isExactlyValue(-0.0) || CFP->isExactlyValue(0.0);
  }
  return false;
}

/// LowerOperation - Provide custom lowering hooks for some operations.
///
SDOperand PPC32TargetLowering::LowerOperation(SDOperand Op, SelectionDAG &DAG) {
  switch (Op.getOpcode()) {
  default: assert(0 && "Wasn't expecting to be able to lower this!"); 
  case ISD::FP_TO_SINT: {
    assert(MVT::isFloatingPoint(Op.getOperand(0).getValueType()));
    SDOperand Src = Op.getOperand(0);
    if (Src.getValueType() == MVT::f32)
      Src = DAG.getNode(ISD::FP_EXTEND, MVT::f64, Src);
    
    switch (Op.getValueType()) {
    default: assert(0 && "Unhandled FP_TO_SINT type in custom expander!");
    case MVT::i32:
      Op = DAG.getNode(PPCISD::FCTIWZ, MVT::f64, Src);
      break;
    case MVT::i64:
      Op = DAG.getNode(PPCISD::FCTIDZ, MVT::f64, Src);
      break;
    }
   
    int FrameIdx =
      DAG.getMachineFunction().getFrameInfo()->CreateStackObject(8, 8);
    SDOperand FI = DAG.getFrameIndex(FrameIdx, MVT::i32);
    SDOperand ST = DAG.getNode(ISD::STORE, MVT::Other, DAG.getEntryNode(),
                               Op, FI, DAG.getSrcValue(0));
    if (Op.getOpcode() == PPCISD::FCTIDZ) {
      Op = DAG.getLoad(MVT::i64, ST, FI, DAG.getSrcValue(0));
    } else {
      FI = DAG.getNode(ISD::ADD, MVT::i32, FI, DAG.getConstant(4, MVT::i32));
      Op = DAG.getLoad(MVT::i32, ST, FI, DAG.getSrcValue(0));
    }
    return Op;
  }
  case ISD::SINT_TO_FP: {
    assert(MVT::i64 == Op.getOperand(0).getValueType() && 
           "Unhandled SINT_TO_FP type in custom expander!");
    int FrameIdx =
      DAG.getMachineFunction().getFrameInfo()->CreateStackObject(8, 8);
    SDOperand FI = DAG.getFrameIndex(FrameIdx, MVT::i32);
    SDOperand ST = DAG.getNode(ISD::STORE, MVT::Other, DAG.getEntryNode(),
                               Op.getOperand(0), FI, DAG.getSrcValue(0));
    SDOperand LD = DAG.getLoad(MVT::f64, ST, FI, DAG.getSrcValue(0));
    SDOperand FP = DAG.getNode(PPCISD::FCFID, MVT::f64, LD);
    if (MVT::f32 == Op.getValueType())
      FP = DAG.getNode(ISD::FP_ROUND, MVT::f32, FP);
    return FP;
  }
  case ISD::SELECT_CC: {
    // Turn FP only select_cc's into fsel instructions.
    if (!MVT::isFloatingPoint(Op.getOperand(0).getValueType()) ||
        !MVT::isFloatingPoint(Op.getOperand(2).getValueType()))
      break;
    
    ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(4))->get();
    
    // Cannot handle SETEQ/SETNE.
    if (CC == ISD::SETEQ || CC == ISD::SETNE) break;
    
    MVT::ValueType ResVT = Op.getValueType();
    MVT::ValueType CmpVT = Op.getOperand(0).getValueType();
    SDOperand LHS = Op.getOperand(0), RHS = Op.getOperand(1);
    SDOperand TV  = Op.getOperand(2), FV  = Op.getOperand(3);

    // If the RHS of the comparison is a 0.0, we don't need to do the
    // subtraction at all.
    if (isFloatingPointZero(RHS))
      switch (CC) {
      default: assert(0 && "Invalid FSEL condition"); abort();
      case ISD::SETULT:
      case ISD::SETLT:
        std::swap(TV, FV);  // fsel is natively setge, swap operands for setlt
      case ISD::SETUGE:
      case ISD::SETGE:
        return DAG.getNode(PPCISD::FSEL, ResVT, LHS, TV, FV);
      case ISD::SETUGT:
      case ISD::SETGT:
        std::swap(TV, FV);  // fsel is natively setge, swap operands for setlt
      case ISD::SETULE:
      case ISD::SETLE:
        return DAG.getNode(PPCISD::FSEL, ResVT,
                           DAG.getNode(ISD::FNEG, ResVT, LHS), TV, FV);
      }
    
    switch (CC) {
    default: assert(0 && "Invalid FSEL condition"); abort();
    case ISD::SETULT:
    case ISD::SETLT:
      return DAG.getNode(PPCISD::FSEL, ResVT,
                         DAG.getNode(ISD::FSUB, CmpVT, LHS, RHS), FV, TV);
    case ISD::SETUGE:
    case ISD::SETGE:
      return DAG.getNode(PPCISD::FSEL, ResVT,
                         DAG.getNode(ISD::FSUB, CmpVT, LHS, RHS), TV, FV);
    case ISD::SETUGT:
    case ISD::SETGT:
      return DAG.getNode(PPCISD::FSEL, ResVT,
                         DAG.getNode(ISD::FSUB, CmpVT, RHS, LHS), FV, TV);
    case ISD::SETULE:
    case ISD::SETLE:
      return DAG.getNode(PPCISD::FSEL, ResVT,
                         DAG.getNode(ISD::FSUB, CmpVT, RHS, LHS), TV, FV);
    }
    break;
  }
  case ISD::SHL: {
    assert(Op.getValueType() == MVT::i64 &&
           Op.getOperand(1).getValueType() == MVT::i32 && "Unexpected SHL!");
    // The generic code does a fine job expanding shift by a constant.
    if (isa<ConstantSDNode>(Op.getOperand(1))) break;
    
    // Otherwise, expand into a bunch of logical ops.  Note that these ops
    // depend on the PPC behavior for oversized shift amounts.
    SDOperand Lo = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(0, MVT::i32));
    SDOperand Hi = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(1, MVT::i32));
    SDOperand Amt = Op.getOperand(1);
    
    SDOperand Tmp1 = DAG.getNode(ISD::SUB, MVT::i32,
                                 DAG.getConstant(32, MVT::i32), Amt);
    SDOperand Tmp2 = DAG.getNode(ISD::SHL, MVT::i32, Hi, Amt);
    SDOperand Tmp3 = DAG.getNode(ISD::SRL, MVT::i32, Lo, Tmp1);
    SDOperand Tmp4 = DAG.getNode(ISD::OR , MVT::i32, Tmp2, Tmp3);
    SDOperand Tmp5 = DAG.getNode(ISD::ADD, MVT::i32, Amt,
                                 DAG.getConstant(-32U, MVT::i32));
    SDOperand Tmp6 = DAG.getNode(ISD::SHL, MVT::i32, Lo, Tmp5);
    SDOperand OutHi = DAG.getNode(ISD::OR, MVT::i32, Tmp4, Tmp6);
    SDOperand OutLo = DAG.getNode(ISD::SHL, MVT::i32, Lo, Amt);
    return DAG.getNode(ISD::BUILD_PAIR, MVT::i64, OutLo, OutHi);
  }
  case ISD::SRL: {
    assert(Op.getValueType() == MVT::i64 &&
           Op.getOperand(1).getValueType() == MVT::i32 && "Unexpected SHL!");
    // The generic code does a fine job expanding shift by a constant.
    if (isa<ConstantSDNode>(Op.getOperand(1))) break;
    
    // Otherwise, expand into a bunch of logical ops.  Note that these ops
    // depend on the PPC behavior for oversized shift amounts.
    SDOperand Lo = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(0, MVT::i32));
    SDOperand Hi = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(1, MVT::i32));
    SDOperand Amt = Op.getOperand(1);
    
    SDOperand Tmp1 = DAG.getNode(ISD::SUB, MVT::i32,
                                 DAG.getConstant(32, MVT::i32), Amt);
    SDOperand Tmp2 = DAG.getNode(ISD::SRL, MVT::i32, Lo, Amt);
    SDOperand Tmp3 = DAG.getNode(ISD::SHL, MVT::i32, Hi, Tmp1);
    SDOperand Tmp4 = DAG.getNode(ISD::OR , MVT::i32, Tmp2, Tmp3);
    SDOperand Tmp5 = DAG.getNode(ISD::ADD, MVT::i32, Amt,
                                 DAG.getConstant(-32U, MVT::i32));
    SDOperand Tmp6 = DAG.getNode(ISD::SRL, MVT::i32, Hi, Tmp5);
    SDOperand OutLo = DAG.getNode(ISD::OR, MVT::i32, Tmp4, Tmp6);
    SDOperand OutHi = DAG.getNode(ISD::SRL, MVT::i32, Hi, Amt);
    return DAG.getNode(ISD::BUILD_PAIR, MVT::i64, OutLo, OutHi);
  }    
  case ISD::SRA: {
    assert(Op.getValueType() == MVT::i64 &&
           Op.getOperand(1).getValueType() == MVT::i32 && "Unexpected SRA!");
    // The generic code does a fine job expanding shift by a constant.
    if (isa<ConstantSDNode>(Op.getOperand(1))) break;
      
    // Otherwise, expand into a bunch of logical ops, followed by a select_cc.
    SDOperand Lo = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(0, MVT::i32));
    SDOperand Hi = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32, Op.getOperand(0),
                               DAG.getConstant(1, MVT::i32));
    SDOperand Amt = Op.getOperand(1);
    
    SDOperand Tmp1 = DAG.getNode(ISD::SUB, MVT::i32,
                                 DAG.getConstant(32, MVT::i32), Amt);
    SDOperand Tmp2 = DAG.getNode(ISD::SRL, MVT::i32, Lo, Amt);
    SDOperand Tmp3 = DAG.getNode(ISD::SHL, MVT::i32, Hi, Tmp1);
    SDOperand Tmp4 = DAG.getNode(ISD::OR , MVT::i32, Tmp2, Tmp3);
    SDOperand Tmp5 = DAG.getNode(ISD::ADD, MVT::i32, Amt,
                                 DAG.getConstant(-32U, MVT::i32));
    SDOperand Tmp6 = DAG.getNode(ISD::SRA, MVT::i32, Hi, Tmp5);
    SDOperand OutHi = DAG.getNode(ISD::SRA, MVT::i32, Hi, Amt);
    SDOperand OutLo = DAG.getSelectCC(Tmp5, DAG.getConstant(0, MVT::i32),
                                      Tmp4, Tmp6, ISD::SETLE);
    return DAG.getNode(ISD::BUILD_PAIR, MVT::i64, OutLo, OutHi);
  }
  }
  return SDOperand();
}

std::vector<SDOperand>
PPC32TargetLowering::LowerArguments(Function &F, SelectionDAG &DAG) {
  //
  // add beautiful description of PPC stack frame format, or at least some docs
  //
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MachineBasicBlock& BB = MF.front();
  SSARegMap *RegMap = MF.getSSARegMap();
  std::vector<SDOperand> ArgValues;
  
  unsigned ArgOffset = 24;
  unsigned GPR_remaining = 8;
  unsigned FPR_remaining = 13;
  unsigned GPR_idx = 0, FPR_idx = 0;
  static const unsigned GPR[] = {
    PPC::R3, PPC::R4, PPC::R5, PPC::R6,
    PPC::R7, PPC::R8, PPC::R9, PPC::R10,
  };
  static const unsigned FPR[] = {
    PPC::F1, PPC::F2, PPC::F3, PPC::F4, PPC::F5, PPC::F6, PPC::F7,
    PPC::F8, PPC::F9, PPC::F10, PPC::F11, PPC::F12, PPC::F13
  };
  
  // Add DAG nodes to load the arguments...  On entry to a function on PPC,
  // the arguments start at offset 24, although they are likely to be passed
  // in registers.
  for (Function::arg_iterator I = F.arg_begin(), E = F.arg_end(); I != E; ++I) {
    SDOperand newroot, argt;
    unsigned ObjSize;
    bool needsLoad = false;
    bool ArgLive = !I->use_empty();
    MVT::ValueType ObjectVT = getValueType(I->getType());
    
    switch (ObjectVT) {
    default: assert(0 && "Unhandled argument type!");
    case MVT::i1:
    case MVT::i8:
    case MVT::i16:
    case MVT::i32:
      ObjSize = 4;
      if (!ArgLive) break;
      if (GPR_remaining > 0) {
        unsigned VReg = RegMap->createVirtualRegister(&PPC32::GPRCRegClass);
        MF.addLiveIn(GPR[GPR_idx], VReg);
        argt = newroot = DAG.getCopyFromReg(DAG.getRoot(), VReg, MVT::i32);
        if (ObjectVT != MVT::i32) {
          unsigned AssertOp = I->getType()->isSigned() ? ISD::AssertSext 
                                                       : ISD::AssertZext;
          argt = DAG.getNode(AssertOp, MVT::i32, argt, 
                             DAG.getValueType(ObjectVT));
          argt = DAG.getNode(ISD::TRUNCATE, ObjectVT, argt);
        }
      } else {
        needsLoad = true;
      }
      break;
    case MVT::i64: ObjSize = 8;
      if (!ArgLive) break;
      if (GPR_remaining > 0) {
        SDOperand argHi, argLo;
        unsigned VReg = RegMap->createVirtualRegister(&PPC32::GPRCRegClass);
        MF.addLiveIn(GPR[GPR_idx], VReg);
        argHi = DAG.getCopyFromReg(DAG.getRoot(), VReg, MVT::i32);
        // If we have two or more remaining argument registers, then both halves
        // of the i64 can be sourced from there.  Otherwise, the lower half will
        // have to come off the stack.  This can happen when an i64 is preceded
        // by 28 bytes of arguments.
        if (GPR_remaining > 1) {
          unsigned VReg = RegMap->createVirtualRegister(&PPC32::GPRCRegClass);
          MF.addLiveIn(GPR[GPR_idx+1], VReg);
          argLo = DAG.getCopyFromReg(argHi, VReg, MVT::i32);
        } else {
          int FI = MFI->CreateFixedObject(4, ArgOffset+4);
          SDOperand FIN = DAG.getFrameIndex(FI, MVT::i32);
          argLo = DAG.getLoad(MVT::i32, DAG.getEntryNode(), FIN,
                              DAG.getSrcValue(NULL));
        }
        // Build the outgoing arg thingy
        argt = DAG.getNode(ISD::BUILD_PAIR, MVT::i64, argLo, argHi);
        newroot = argLo;
      } else {
        needsLoad = true;
      }
      break;
    case MVT::f32:
    case MVT::f64:
      ObjSize = (ObjectVT == MVT::f64) ? 8 : 4;
      if (!ArgLive) break;
      if (FPR_remaining > 0) {
        unsigned VReg;
        if (ObjectVT == MVT::f32)
          VReg = RegMap->createVirtualRegister(&PPC32::F4RCRegClass);
        else
          VReg = RegMap->createVirtualRegister(&PPC32::F8RCRegClass);
        MF.addLiveIn(FPR[FPR_idx], VReg);
        argt = newroot = DAG.getCopyFromReg(DAG.getRoot(), VReg, ObjectVT);
        --FPR_remaining;
        ++FPR_idx;
      } else {
        needsLoad = true;
      }
      break;
    }
    
    // We need to load the argument to a virtual register if we determined above
    // that we ran out of physical registers of the appropriate type
    if (needsLoad) {
      unsigned SubregOffset = 0;
      if (ObjectVT == MVT::i8 || ObjectVT == MVT::i1) SubregOffset = 3;
      if (ObjectVT == MVT::i16) SubregOffset = 2;
      int FI = MFI->CreateFixedObject(ObjSize, ArgOffset);
      SDOperand FIN = DAG.getFrameIndex(FI, MVT::i32);
      FIN = DAG.getNode(ISD::ADD, MVT::i32, FIN,
                        DAG.getConstant(SubregOffset, MVT::i32));
      argt = newroot = DAG.getLoad(ObjectVT, DAG.getEntryNode(), FIN,
                                   DAG.getSrcValue(NULL));
    }
    
    // Every 4 bytes of argument space consumes one of the GPRs available for
    // argument passing.
    if (GPR_remaining > 0) {
      unsigned delta = (GPR_remaining > 1 && ObjSize == 8) ? 2 : 1;
      GPR_remaining -= delta;
      GPR_idx += delta;
    }
    ArgOffset += ObjSize;
    if (newroot.Val)
      DAG.setRoot(newroot.getValue(1));
    
    ArgValues.push_back(argt);
  }
  
  // If the function takes variable number of arguments, make a frame index for
  // the start of the first vararg value... for expansion of llvm.va_start.
  if (F.isVarArg()) {
    VarArgsFrameIndex = MFI->CreateFixedObject(4, ArgOffset);
    SDOperand FIN = DAG.getFrameIndex(VarArgsFrameIndex, MVT::i32);
    // If this function is vararg, store any remaining integer argument regs
    // to their spots on the stack so that they may be loaded by deferencing the
    // result of va_next.
    std::vector<SDOperand> MemOps;
    for (; GPR_remaining > 0; --GPR_remaining, ++GPR_idx) {
      unsigned VReg = RegMap->createVirtualRegister(&PPC32::GPRCRegClass);
      MF.addLiveIn(GPR[GPR_idx], VReg);
      SDOperand Val = DAG.getCopyFromReg(DAG.getRoot(), VReg, MVT::i32);
      SDOperand Store = DAG.getNode(ISD::STORE, MVT::Other, Val.getValue(1),
                                    Val, FIN, DAG.getSrcValue(NULL));
      MemOps.push_back(Store);
      // Increment the address by four for the next argument to store
      SDOperand PtrOff = DAG.getConstant(4, getPointerTy());
      FIN = DAG.getNode(ISD::ADD, MVT::i32, FIN, PtrOff);
    }
    DAG.setRoot(DAG.getNode(ISD::TokenFactor, MVT::Other, MemOps));
  }
  
  // Finally, inform the code generator which regs we return values in.
  switch (getValueType(F.getReturnType())) {
    default: assert(0 && "Unknown type!");
    case MVT::isVoid: break;
    case MVT::i1:
    case MVT::i8:
    case MVT::i16:
    case MVT::i32:
      MF.addLiveOut(PPC::R3);
      break;
    case MVT::i64:
      MF.addLiveOut(PPC::R3);
      MF.addLiveOut(PPC::R4);
      break;
    case MVT::f32:
    case MVT::f64:
      MF.addLiveOut(PPC::F1);
      break;
  }
  
  return ArgValues;
}

std::pair<SDOperand, SDOperand>
PPC32TargetLowering::LowerCallTo(SDOperand Chain,
                                 const Type *RetTy, bool isVarArg,
                                 unsigned CallingConv, bool isTailCall,
                                 SDOperand Callee, ArgListTy &Args,
                                 SelectionDAG &DAG) {
  // args_to_use will accumulate outgoing args for the ISD::CALL case in
  // SelectExpr to use to put the arguments in the appropriate registers.
  std::vector<SDOperand> args_to_use;
  
  // Count how many bytes are to be pushed on the stack, including the linkage
  // area, and parameter passing area.
  unsigned NumBytes = 24;
  
  if (Args.empty()) {
    Chain = DAG.getNode(ISD::CALLSEQ_START, MVT::Other, Chain,
                        DAG.getConstant(NumBytes, getPointerTy()));
  } else {
    for (unsigned i = 0, e = Args.size(); i != e; ++i) {
      switch (getValueType(Args[i].second)) {
      default: assert(0 && "Unknown value type!");
      case MVT::i1:
      case MVT::i8:
      case MVT::i16:
      case MVT::i32:
      case MVT::f32:
        NumBytes += 4;
        break;
      case MVT::i64:
      case MVT::f64:
        NumBytes += 8;
        break;
      }
    }
        
    // Just to be safe, we'll always reserve the full 24 bytes of linkage area
    // plus 32 bytes of argument space in case any called code gets funky on us.
    // (Required by ABI to support var arg)
    if (NumBytes < 56) NumBytes = 56;
    
    // Adjust the stack pointer for the new arguments...
    // These operations are automatically eliminated by the prolog/epilog pass
    Chain = DAG.getNode(ISD::CALLSEQ_START, MVT::Other, Chain,
                        DAG.getConstant(NumBytes, getPointerTy()));
    
    // Set up a copy of the stack pointer for use loading and storing any
    // arguments that may not fit in the registers available for argument
    // passing.
    SDOperand StackPtr = DAG.getCopyFromReg(DAG.getEntryNode(),
                                            PPC::R1, MVT::i32);
    
    // Figure out which arguments are going to go in registers, and which in
    // memory.  Also, if this is a vararg function, floating point operations
    // must be stored to our stack, and loaded into integer regs as well, if
    // any integer regs are available for argument passing.
    unsigned ArgOffset = 24;
    unsigned GPR_remaining = 8;
    unsigned FPR_remaining = 13;
    
    std::vector<SDOperand> MemOps;
    for (unsigned i = 0, e = Args.size(); i != e; ++i) {
      // PtrOff will be used to store the current argument to the stack if a
      // register cannot be found for it.
      SDOperand PtrOff = DAG.getConstant(ArgOffset, getPointerTy());
      PtrOff = DAG.getNode(ISD::ADD, MVT::i32, StackPtr, PtrOff);
      MVT::ValueType ArgVT = getValueType(Args[i].second);
      
      switch (ArgVT) {
      default: assert(0 && "Unexpected ValueType for argument!");
      case MVT::i1:
      case MVT::i8:
      case MVT::i16:
        // Promote the integer to 32 bits.  If the input type is signed use a
        // sign extend, otherwise use a zero extend.
        if (Args[i].second->isSigned())
          Args[i].first =DAG.getNode(ISD::SIGN_EXTEND, MVT::i32, Args[i].first);
        else
          Args[i].first =DAG.getNode(ISD::ZERO_EXTEND, MVT::i32, Args[i].first);
        // FALL THROUGH
      case MVT::i32:
        if (GPR_remaining > 0) {
          args_to_use.push_back(Args[i].first);
          --GPR_remaining;
        } else {
          MemOps.push_back(DAG.getNode(ISD::STORE, MVT::Other, Chain,
                                       Args[i].first, PtrOff,
                                       DAG.getSrcValue(NULL)));
        }
        ArgOffset += 4;
        break;
      case MVT::i64:
        // If we have one free GPR left, we can place the upper half of the i64
        // in it, and store the other half to the stack.  If we have two or more
        // free GPRs, then we can pass both halves of the i64 in registers.
        if (GPR_remaining > 0) {
          SDOperand Hi = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32,
                                     Args[i].first, DAG.getConstant(1, MVT::i32));
          SDOperand Lo = DAG.getNode(ISD::EXTRACT_ELEMENT, MVT::i32,
                                     Args[i].first, DAG.getConstant(0, MVT::i32));
          args_to_use.push_back(Hi);
          --GPR_remaining;
          if (GPR_remaining > 0) {
            args_to_use.push_back(Lo);
            --GPR_remaining;
          } else {
            SDOperand ConstFour = DAG.getConstant(4, getPointerTy());
            PtrOff = DAG.getNode(ISD::ADD, MVT::i32, PtrOff, ConstFour);
            MemOps.push_back(DAG.getNode(ISD::STORE, MVT::Other, Chain,
                                         Lo, PtrOff, DAG.getSrcValue(NULL)));
          }
        } else {
          MemOps.push_back(DAG.getNode(ISD::STORE, MVT::Other, Chain,
                                       Args[i].first, PtrOff,
                                       DAG.getSrcValue(NULL)));
        }
        ArgOffset += 8;
        break;
      case MVT::f32:
      case MVT::f64:
        if (FPR_remaining > 0) {
          args_to_use.push_back(Args[i].first);
          --FPR_remaining;
          if (isVarArg) {
            SDOperand Store = DAG.getNode(ISD::STORE, MVT::Other, Chain,
                                          Args[i].first, PtrOff,
                                          DAG.getSrcValue(NULL));
            MemOps.push_back(Store);
            // Float varargs are always shadowed in available integer registers
            if (GPR_remaining > 0) {
              SDOperand Load = DAG.getLoad(MVT::i32, Store, PtrOff,
                                           DAG.getSrcValue(NULL));
              MemOps.push_back(Load);
              args_to_use.push_back(Load);
              --GPR_remaining;
            }
            if (GPR_remaining > 0 && MVT::f64 == ArgVT) {
              SDOperand ConstFour = DAG.getConstant(4, getPointerTy());
              PtrOff = DAG.getNode(ISD::ADD, MVT::i32, PtrOff, ConstFour);
              SDOperand Load = DAG.getLoad(MVT::i32, Store, PtrOff,
                                           DAG.getSrcValue(NULL));
              MemOps.push_back(Load);
              args_to_use.push_back(Load);
              --GPR_remaining;
            }
          } else {
            // If we have any FPRs remaining, we may also have GPRs remaining.
            // Args passed in FPRs consume either 1 (f32) or 2 (f64) available
            // GPRs.
            if (GPR_remaining > 0) {
              args_to_use.push_back(DAG.getNode(ISD::UNDEF, MVT::i32));
              --GPR_remaining;
            }
            if (GPR_remaining > 0 && MVT::f64 == ArgVT) {
              args_to_use.push_back(DAG.getNode(ISD::UNDEF, MVT::i32));
              --GPR_remaining;
            }
          }
        } else {
          MemOps.push_back(DAG.getNode(ISD::STORE, MVT::Other, Chain,
                                       Args[i].first, PtrOff,
                                       DAG.getSrcValue(NULL)));
        }
        ArgOffset += (ArgVT == MVT::f32) ? 4 : 8;
        break;
      }
    }
    if (!MemOps.empty())
      Chain = DAG.getNode(ISD::TokenFactor, MVT::Other, MemOps);
  }
  
  std::vector<MVT::ValueType> RetVals;
  MVT::ValueType RetTyVT = getValueType(RetTy);
  MVT::ValueType ActualRetTyVT = RetTyVT;
  if (RetTyVT >= MVT::i1 && RetTyVT <= MVT::i16)
    ActualRetTyVT = MVT::i32;   // Promote result to i32.
    
  if (RetTyVT != MVT::isVoid)
    RetVals.push_back(ActualRetTyVT);
  RetVals.push_back(MVT::Other);
  
  SDOperand TheCall = SDOperand(DAG.getCall(RetVals,
                                            Chain, Callee, args_to_use), 0);
  Chain = TheCall.getValue(RetTyVT != MVT::isVoid);
  Chain = DAG.getNode(ISD::CALLSEQ_END, MVT::Other, Chain,
                      DAG.getConstant(NumBytes, getPointerTy()));
  SDOperand RetVal = TheCall;
  
  // If the result is a small value, add a note so that we keep track of the
  // information about whether it is sign or zero extended.
  if (RetTyVT != ActualRetTyVT) {
    RetVal = DAG.getNode(RetTy->isSigned() ? ISD::AssertSext : ISD::AssertZext,
                         MVT::i32, RetVal, DAG.getValueType(RetTyVT));
    RetVal = DAG.getNode(ISD::TRUNCATE, RetTyVT, RetVal);
  }
  
  return std::make_pair(RetVal, Chain);
}

SDOperand PPC32TargetLowering::LowerVAStart(SDOperand Chain, SDOperand VAListP,
                                            Value *VAListV, SelectionDAG &DAG) {
  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  SDOperand FR = DAG.getFrameIndex(VarArgsFrameIndex, MVT::i32);
  return DAG.getNode(ISD::STORE, MVT::Other, Chain, FR, VAListP,
                     DAG.getSrcValue(VAListV));
}

std::pair<SDOperand,SDOperand>
PPC32TargetLowering::LowerVAArg(SDOperand Chain,
                                SDOperand VAListP, Value *VAListV,
                                const Type *ArgTy, SelectionDAG &DAG) {
  MVT::ValueType ArgVT = getValueType(ArgTy);
  
  SDOperand VAList =
    DAG.getLoad(MVT::i32, Chain, VAListP, DAG.getSrcValue(VAListV));
  SDOperand Result = DAG.getLoad(ArgVT, Chain, VAList, DAG.getSrcValue(NULL));
  unsigned Amt;
  if (ArgVT == MVT::i32 || ArgVT == MVT::f32)
    Amt = 4;
  else {
    assert((ArgVT == MVT::i64 || ArgVT == MVT::f64) &&
           "Other types should have been promoted for varargs!");
    Amt = 8;
  }
  VAList = DAG.getNode(ISD::ADD, VAList.getValueType(), VAList,
                       DAG.getConstant(Amt, VAList.getValueType()));
  Chain = DAG.getNode(ISD::STORE, MVT::Other, Chain,
                      VAList, VAListP, DAG.getSrcValue(VAListV));
  return std::make_pair(Result, Chain);
}


std::pair<SDOperand, SDOperand> PPC32TargetLowering::
LowerFrameReturnAddress(bool isFrameAddress, SDOperand Chain, unsigned Depth,
                        SelectionDAG &DAG) {
  assert(0 && "LowerFrameReturnAddress unimplemented");
  abort();
}

MachineBasicBlock *
PPC32TargetLowering::InsertAtEndOfBasicBlock(MachineInstr *MI,
                                             MachineBasicBlock *BB) {
  assert((MI->getOpcode() == PPC::SELECT_CC_Int ||
          MI->getOpcode() == PPC::SELECT_CC_F4 ||
          MI->getOpcode() == PPC::SELECT_CC_F8) &&
         "Unexpected instr type to insert");
  
  // To "insert" a SELECT_CC instruction, we actually have to insert the diamond
  // control-flow pattern.  The incoming instruction knows the destination vreg
  // to set, the condition code register to branch on, the true/false values to
  // select between, and a branch opcode to use.
  const BasicBlock *LLVM_BB = BB->getBasicBlock();
  ilist<MachineBasicBlock>::iterator It = BB;
  ++It;
  
  //  thisMBB:
  //  ...
  //   TrueVal = ...
  //   cmpTY ccX, r1, r2
  //   bCC copy1MBB
  //   fallthrough --> copy0MBB
  MachineBasicBlock *thisMBB = BB;
  MachineBasicBlock *copy0MBB = new MachineBasicBlock(LLVM_BB);
  MachineBasicBlock *sinkMBB = new MachineBasicBlock(LLVM_BB);
  BuildMI(BB, MI->getOperand(4).getImmedValue(), 2)
    .addReg(MI->getOperand(1).getReg()).addMBB(sinkMBB);
  MachineFunction *F = BB->getParent();
  F->getBasicBlockList().insert(It, copy0MBB);
  F->getBasicBlockList().insert(It, sinkMBB);
  // Update machine-CFG edges
  BB->addSuccessor(copy0MBB);
  BB->addSuccessor(sinkMBB);
  
  //  copy0MBB:
  //   %FalseValue = ...
  //   # fallthrough to sinkMBB
  BB = copy0MBB;
  
  // Update machine-CFG edges
  BB->addSuccessor(sinkMBB);
  
  //  sinkMBB:
  //   %Result = phi [ %FalseValue, copy0MBB ], [ %TrueValue, thisMBB ]
  //  ...
  BB = sinkMBB;
  BuildMI(BB, PPC::PHI, 4, MI->getOperand(0).getReg())
    .addReg(MI->getOperand(3).getReg()).addMBB(copy0MBB)
    .addReg(MI->getOperand(2).getReg()).addMBB(thisMBB);

  delete MI;   // The pseudo instruction is gone now.
  return BB;
}

