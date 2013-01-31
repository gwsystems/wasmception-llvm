//===-- AMDILISelDAGToDAG.cpp - A dag to dag inst selector for AMDIL ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//==-----------------------------------------------------------------------===//
//
/// \file
/// \brief Defines an instruction selector for the AMDGPU target.
//
//===----------------------------------------------------------------------===//
#include "AMDGPUInstrInfo.h"
#include "AMDGPUISelLowering.h" // For AMDGPUISD
#include "AMDGPURegisterInfo.h"
#include "AMDILDevices.h"
#include "R600InstrInfo.h"
#include "llvm/ADT/ValueMap.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Compiler.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include <list>
#include <queue>

using namespace llvm;

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

namespace {
/// AMDGPU specific code to select AMDGPU machine instructions for
/// SelectionDAG operations.
class AMDGPUDAGToDAGISel : public SelectionDAGISel {
  // Subtarget - Keep a pointer to the AMDGPU Subtarget around so that we can
  // make the right decision when generating code for different targets.
  const AMDGPUSubtarget &Subtarget;
public:
  AMDGPUDAGToDAGISel(TargetMachine &TM);
  virtual ~AMDGPUDAGToDAGISel();

  SDNode *Select(SDNode *N);
  virtual const char *getPassName() const;

private:
  inline SDValue getSmallIPtrImm(unsigned Imm);
  bool FoldOperands(unsigned, const R600InstrInfo *, std::vector<SDValue> &);

  // Complex pattern selectors
  bool SelectADDRParam(SDValue Addr, SDValue& R1, SDValue& R2);
  bool SelectADDR(SDValue N, SDValue &R1, SDValue &R2);
  bool SelectADDR64(SDValue N, SDValue &R1, SDValue &R2);

  static bool checkType(const Value *ptr, unsigned int addrspace);
  static const Value *getBasePointerValue(const Value *V);

  static bool isGlobalStore(const StoreSDNode *N);
  static bool isPrivateStore(const StoreSDNode *N);
  static bool isLocalStore(const StoreSDNode *N);
  static bool isRegionStore(const StoreSDNode *N);

  static bool isCPLoad(const LoadSDNode *N);
  static bool isConstantLoad(const LoadSDNode *N, int cbID);
  static bool isGlobalLoad(const LoadSDNode *N);
  static bool isParamLoad(const LoadSDNode *N);
  static bool isPrivateLoad(const LoadSDNode *N);
  static bool isLocalLoad(const LoadSDNode *N);
  static bool isRegionLoad(const LoadSDNode *N);

  bool SelectGlobalValueConstantOffset(SDValue Addr, SDValue& IntPtr);
  bool SelectGlobalValueVariableOffset(SDValue Addr,
      SDValue &BaseReg, SDValue& Offset);
  bool SelectADDR8BitOffset(SDValue Addr, SDValue& Base, SDValue& Offset);
  bool SelectADDRReg(SDValue Addr, SDValue& Base, SDValue& Offset);
  bool SelectADDRVTX_READ(SDValue Addr, SDValue &Base, SDValue &Offset);

  // Include the pieces autogenerated from the target description.
#include "AMDGPUGenDAGISel.inc"
};
}  // end anonymous namespace

/// \brief This pass converts a legalized DAG into a AMDGPU-specific
// DAG, ready for instruction scheduling.
FunctionPass *llvm::createAMDGPUISelDag(TargetMachine &TM
                                       ) {
  return new AMDGPUDAGToDAGISel(TM);
}

AMDGPUDAGToDAGISel::AMDGPUDAGToDAGISel(TargetMachine &TM
                                     )
  : SelectionDAGISel(TM), Subtarget(TM.getSubtarget<AMDGPUSubtarget>()) {
}

AMDGPUDAGToDAGISel::~AMDGPUDAGToDAGISel() {
}

SDValue AMDGPUDAGToDAGISel::getSmallIPtrImm(unsigned int Imm) {
  return CurDAG->getTargetConstant(Imm, MVT::i32);
}

bool AMDGPUDAGToDAGISel::SelectADDRParam(
    SDValue Addr, SDValue& R1, SDValue& R2) {

  if (Addr.getOpcode() == ISD::FrameIndex) {
    if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
      R1 = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
      R2 = CurDAG->getTargetConstant(0, MVT::i32);
    } else {
      R1 = Addr;
      R2 = CurDAG->getTargetConstant(0, MVT::i32);
    }
  } else if (Addr.getOpcode() == ISD::ADD) {
    R1 = Addr.getOperand(0);
    R2 = Addr.getOperand(1);
  } else {
    R1 = Addr;
    R2 = CurDAG->getTargetConstant(0, MVT::i32);
  }
  return true;
}

bool AMDGPUDAGToDAGISel::SelectADDR(SDValue Addr, SDValue& R1, SDValue& R2) {
  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress) {
    return false;
  }
  return SelectADDRParam(Addr, R1, R2);
}


bool AMDGPUDAGToDAGISel::SelectADDR64(SDValue Addr, SDValue& R1, SDValue& R2) {
  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress) {
    return false;
  }

  if (Addr.getOpcode() == ISD::FrameIndex) {
    if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
      R1 = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i64);
      R2 = CurDAG->getTargetConstant(0, MVT::i64);
    } else {
      R1 = Addr;
      R2 = CurDAG->getTargetConstant(0, MVT::i64);
    }
  } else if (Addr.getOpcode() == ISD::ADD) {
    R1 = Addr.getOperand(0);
    R2 = Addr.getOperand(1);
  } else {
    R1 = Addr;
    R2 = CurDAG->getTargetConstant(0, MVT::i64);
  }
  return true;
}

SDNode *AMDGPUDAGToDAGISel::Select(SDNode *N) {
  unsigned int Opc = N->getOpcode();
  if (N->isMachineOpcode()) {
    return NULL;   // Already selected.
  }
  switch (Opc) {
  default: break;
  case ISD::FrameIndex: {
    if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(N)) {
      unsigned int FI = FIN->getIndex();
      EVT OpVT = N->getValueType(0);
      unsigned int NewOpc = AMDGPU::COPY;
      SDValue TFI = CurDAG->getTargetFrameIndex(FI, MVT::i32);
      return CurDAG->SelectNodeTo(N, NewOpc, OpVT, TFI);
    }
    break;
  }
  case ISD::ConstantFP:
  case ISD::Constant: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    // XXX: Custom immediate lowering not implemented yet.  Instead we use
    // pseudo instructions defined in SIInstructions.td
    if (ST.device()->getGeneration() > AMDGPUDeviceInfo::HD6XXX) {
      break;
    }
    const R600InstrInfo *TII = static_cast<const R600InstrInfo*>(TM.getInstrInfo());

    uint64_t ImmValue = 0;
    unsigned ImmReg = AMDGPU::ALU_LITERAL_X;

    if (N->getOpcode() == ISD::ConstantFP) {
      // XXX: 64-bit Immediates not supported yet
      assert(N->getValueType(0) != MVT::f64);

      ConstantFPSDNode *C = dyn_cast<ConstantFPSDNode>(N);
      APFloat Value = C->getValueAPF();
      float FloatValue = Value.convertToFloat();
      if (FloatValue == 0.0) {
        ImmReg = AMDGPU::ZERO;
      } else if (FloatValue == 0.5) {
        ImmReg = AMDGPU::HALF;
      } else if (FloatValue == 1.0) {
        ImmReg = AMDGPU::ONE;
      } else {
        ImmValue = Value.bitcastToAPInt().getZExtValue();
      }
    } else {
      // XXX: 64-bit Immediates not supported yet
      assert(N->getValueType(0) != MVT::i64);

      ConstantSDNode *C = dyn_cast<ConstantSDNode>(N);
      if (C->getZExtValue() == 0) {
        ImmReg = AMDGPU::ZERO;
      } else if (C->getZExtValue() == 1) {
        ImmReg = AMDGPU::ONE_INT;
      } else {
        ImmValue = C->getZExtValue();
      }
    }

    for (SDNode::use_iterator Use = N->use_begin(), Next = llvm::next(Use);
                              Use != SDNode::use_end(); Use = Next) {
      Next = llvm::next(Use);
      std::vector<SDValue> Ops;
      for (unsigned i = 0; i < Use->getNumOperands(); ++i) {
        Ops.push_back(Use->getOperand(i));
      }

      if (!Use->isMachineOpcode()) {
          if (ImmReg == AMDGPU::ALU_LITERAL_X) {
            // We can only use literal constants (e.g. AMDGPU::ZERO,
            // AMDGPU::ONE, etc) in machine opcodes.
            continue;
          }
      } else {
        if (!TII->isALUInstr(Use->getMachineOpcode())) {
          continue;
        }

        int ImmIdx = TII->getOperandIdx(Use->getMachineOpcode(), R600Operands::IMM);
        assert(ImmIdx != -1);

        // subtract one from ImmIdx, because the DST operand is usually index
        // 0 for MachineInstrs, but we have no DST in the Ops vector.
        ImmIdx--;

        // Check that we aren't already using an immediate.
        // XXX: It's possible for an instruction to have more than one
        // immediate operand, but this is not supported yet.
        if (ImmReg == AMDGPU::ALU_LITERAL_X) {
          ConstantSDNode *C = dyn_cast<ConstantSDNode>(Use->getOperand(ImmIdx));
          assert(C);

          if (C->getZExtValue() != 0) {
            // This instruction is already using an immediate.
            continue;
          }

          // Set the immediate value
          Ops[ImmIdx] = CurDAG->getTargetConstant(ImmValue, MVT::i32);
        }
      }
      // Set the immediate register
      Ops[Use.getOperandNo()] = CurDAG->getRegister(ImmReg, MVT::i32);

      CurDAG->UpdateNodeOperands(*Use, Ops.data(), Use->getNumOperands());
    }
    break;
  }
  }
  SDNode *Result = SelectCode(N);

  // Fold operands of selected node

  const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
  if (ST.device()->getGeneration() <= AMDGPUDeviceInfo::HD6XXX) {
    const R600InstrInfo *TII =
        static_cast<const R600InstrInfo*>(TM.getInstrInfo());
    if (Result && TII->isALUInstr(Result->getMachineOpcode())) {
      bool IsModified = false;
      do {
        std::vector<SDValue> Ops;
        for(SDNode::op_iterator I = Result->op_begin(), E = Result->op_end();
            I != E; ++I)
          Ops.push_back(*I);
        IsModified = FoldOperands(Result->getMachineOpcode(), TII, Ops);
        if (IsModified) {
          Result = CurDAG->MorphNodeTo(Result, Result->getOpcode(),
              Result->getVTList(), Ops.data(), Ops.size());
        }
      } while (IsModified);
    }
  }

  return Result;
}

bool AMDGPUDAGToDAGISel::FoldOperands(unsigned Opcode,
    const R600InstrInfo *TII, std::vector<SDValue> &Ops) {
  int OperandIdx[] = {
    TII->getOperandIdx(Opcode, R600Operands::SRC0),
    TII->getOperandIdx(Opcode, R600Operands::SRC1),
    TII->getOperandIdx(Opcode, R600Operands::SRC2)
  };
  int SelIdx[] = {
    TII->getOperandIdx(Opcode, R600Operands::SRC0_SEL),
    TII->getOperandIdx(Opcode, R600Operands::SRC1_SEL),
    TII->getOperandIdx(Opcode, R600Operands::SRC2_SEL)
  };
  for (unsigned i = 0; i < 3; i++) {
    if (OperandIdx[i] < 0)
      return false;
    SDValue Operand = Ops[OperandIdx[i] - 1];
    switch (Operand.getOpcode()) {
    case AMDGPUISD::CONST_ADDRESS: {
      SDValue CstOffset;
      if (!Operand.getValueType().isVector() &&
          SelectGlobalValueConstantOffset(Operand.getOperand(0), CstOffset)) {
        Ops[OperandIdx[i] - 1] = CurDAG->getRegister(AMDGPU::ALU_CONST, MVT::f32);
        Ops[SelIdx[i] - 1] = CstOffset;
        return true;
      }
      }
      break;
    case ISD::BITCAST:
      Ops[OperandIdx[i] - 1] = Operand.getOperand(0);
      return true;
    default:
      break;
    }
  }
  return false;
}

bool AMDGPUDAGToDAGISel::checkType(const Value *ptr, unsigned int addrspace) {
  if (!ptr) {
    return false;
  }
  Type *ptrType = ptr->getType();
  return dyn_cast<PointerType>(ptrType)->getAddressSpace() == addrspace;
}

const Value * AMDGPUDAGToDAGISel::getBasePointerValue(const Value *V) {
  if (!V) {
    return NULL;
  }
  const Value *ret = NULL;
  ValueMap<const Value *, bool> ValueBitMap;
  std::queue<const Value *, std::list<const Value *> > ValueQueue;
  ValueQueue.push(V);
  while (!ValueQueue.empty()) {
    V = ValueQueue.front();
    if (ValueBitMap.find(V) == ValueBitMap.end()) {
      ValueBitMap[V] = true;
      if (dyn_cast<Argument>(V) && dyn_cast<PointerType>(V->getType())) {
        ret = V;
        break;
      } else if (dyn_cast<GlobalVariable>(V)) {
        ret = V;
        break;
      } else if (dyn_cast<Constant>(V)) {
        const ConstantExpr *CE = dyn_cast<ConstantExpr>(V);
        if (CE) {
          ValueQueue.push(CE->getOperand(0));
        }
      } else if (const AllocaInst *AI = dyn_cast<AllocaInst>(V)) {
        ret = AI;
        break;
      } else if (const Instruction *I = dyn_cast<Instruction>(V)) {
        uint32_t numOps = I->getNumOperands();
        for (uint32_t x = 0; x < numOps; ++x) {
          ValueQueue.push(I->getOperand(x));
        }
      } else {
        assert(!"Found a Value that we didn't know how to handle!");
      }
    }
    ValueQueue.pop();
  }
  return ret;
}

bool AMDGPUDAGToDAGISel::isGlobalStore(const StoreSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::GLOBAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isPrivateStore(const StoreSDNode *N) {
  return (!checkType(N->getSrcValue(), AMDGPUAS::LOCAL_ADDRESS)
          && !checkType(N->getSrcValue(), AMDGPUAS::GLOBAL_ADDRESS)
          && !checkType(N->getSrcValue(), AMDGPUAS::REGION_ADDRESS));
}

bool AMDGPUDAGToDAGISel::isLocalStore(const StoreSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::LOCAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isRegionStore(const StoreSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::REGION_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isConstantLoad(const LoadSDNode *N, int cbID) {
  if (checkType(N->getSrcValue(), AMDGPUAS::CONSTANT_ADDRESS)) {
    return true;
  }
  MachineMemOperand *MMO = N->getMemOperand();
  const Value *V = MMO->getValue();
  const Value *BV = getBasePointerValue(V);
  if (MMO
      && MMO->getValue()
      && ((V && dyn_cast<GlobalValue>(V))
          || (BV && dyn_cast<GlobalValue>(
                        getBasePointerValue(MMO->getValue()))))) {
    return checkType(N->getSrcValue(), AMDGPUAS::PRIVATE_ADDRESS);
  } else {
    return false;
  }
}

bool AMDGPUDAGToDAGISel::isGlobalLoad(const LoadSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::GLOBAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isParamLoad(const LoadSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::PARAM_I_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isLocalLoad(const  LoadSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::LOCAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isRegionLoad(const  LoadSDNode *N) {
  return checkType(N->getSrcValue(), AMDGPUAS::REGION_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isCPLoad(const LoadSDNode *N) {
  MachineMemOperand *MMO = N->getMemOperand();
  if (checkType(N->getSrcValue(), AMDGPUAS::PRIVATE_ADDRESS)) {
    if (MMO) {
      const Value *V = MMO->getValue();
      const PseudoSourceValue *PSV = dyn_cast<PseudoSourceValue>(V);
      if (PSV && PSV == PseudoSourceValue::getConstantPool()) {
        return true;
      }
    }
  }
  return false;
}

bool AMDGPUDAGToDAGISel::isPrivateLoad(const LoadSDNode *N) {
  if (checkType(N->getSrcValue(), AMDGPUAS::PRIVATE_ADDRESS)) {
    // Check to make sure we are not a constant pool load or a constant load
    // that is marked as a private load
    if (isCPLoad(N) || isConstantLoad(N, -1)) {
      return false;
    }
  }
  if (!checkType(N->getSrcValue(), AMDGPUAS::LOCAL_ADDRESS)
      && !checkType(N->getSrcValue(), AMDGPUAS::GLOBAL_ADDRESS)
      && !checkType(N->getSrcValue(), AMDGPUAS::REGION_ADDRESS)
      && !checkType(N->getSrcValue(), AMDGPUAS::CONSTANT_ADDRESS)
      && !checkType(N->getSrcValue(), AMDGPUAS::PARAM_D_ADDRESS)
      && !checkType(N->getSrcValue(), AMDGPUAS::PARAM_I_ADDRESS)) {
    return true;
  }
  return false;
}

const char *AMDGPUDAGToDAGISel::getPassName() const {
  return "AMDGPU DAG->DAG Pattern Instruction Selection";
}

#ifdef DEBUGTMP
#undef INT64_C
#endif
#undef DEBUGTMP

///==== AMDGPU Functions ====///

bool AMDGPUDAGToDAGISel::SelectGlobalValueConstantOffset(SDValue Addr,
    SDValue& IntPtr) {
  if (ConstantSDNode *Cst = dyn_cast<ConstantSDNode>(Addr)) {
    IntPtr = CurDAG->getIntPtrConstant(Cst->getZExtValue() / 4, true);
    return true;
  }
  return false;
}

bool AMDGPUDAGToDAGISel::SelectGlobalValueVariableOffset(SDValue Addr,
    SDValue& BaseReg, SDValue &Offset) {
  if (!dyn_cast<ConstantSDNode>(Addr)) {
    BaseReg = Addr;
    Offset = CurDAG->getIntPtrConstant(0, true);
    return true;
  }
  return false;
}

bool AMDGPUDAGToDAGISel::SelectADDR8BitOffset(SDValue Addr, SDValue& Base,
                                             SDValue& Offset) {
  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress) {
    return false;
  }


  if (Addr.getOpcode() == ISD::ADD) {
    bool Match = false;

    // Find the base ptr and the offset
    for (unsigned i = 0; i < Addr.getNumOperands(); i++) {
      SDValue Arg = Addr.getOperand(i);
      ConstantSDNode * OffsetNode = dyn_cast<ConstantSDNode>(Arg);
      // This arg isn't a constant so it must be the base PTR.
      if (!OffsetNode) {
        Base = Addr.getOperand(i);
        continue;
      }
      // Check if the constant argument fits in 8-bits.  The offset is in bytes
      // so we need to convert it to dwords.
      if (isUInt<8>(OffsetNode->getZExtValue() >> 2)) {
        Match = true;
        Offset = CurDAG->getTargetConstant(OffsetNode->getZExtValue() >> 2,
                                           MVT::i32);
      }
    }
    return Match;
  }

  // Default case, no offset
  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, MVT::i32);
  return true;
}

bool AMDGPUDAGToDAGISel::SelectADDRVTX_READ(SDValue Addr, SDValue &Base,
                                           SDValue &Offset) {
  ConstantSDNode * IMMOffset;

  if (Addr.getOpcode() == ISD::ADD
      && (IMMOffset = dyn_cast<ConstantSDNode>(Addr.getOperand(1)))
      && isInt<16>(IMMOffset->getZExtValue())) {

      Base = Addr.getOperand(0);
      Offset = CurDAG->getTargetConstant(IMMOffset->getZExtValue(), MVT::i32);
      return true;
  // If the pointer address is constant, we can move it to the offset field.
  } else if ((IMMOffset = dyn_cast<ConstantSDNode>(Addr))
             && isInt<16>(IMMOffset->getZExtValue())) {
    Base = CurDAG->getCopyFromReg(CurDAG->getEntryNode(),
                                  CurDAG->getEntryNode().getDebugLoc(),
                                  AMDGPU::ZERO, MVT::i32);
    Offset = CurDAG->getTargetConstant(IMMOffset->getZExtValue(), MVT::i32);
    return true;
  }

  // Default case, no offset
  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, MVT::i32);
  return true;
}

bool AMDGPUDAGToDAGISel::SelectADDRReg(SDValue Addr, SDValue& Base,
                                      SDValue& Offset) {
  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress  ||
      Addr.getOpcode() != ISD::ADD) {
    return false;
  }

  Base = Addr.getOperand(0);
  Offset = Addr.getOperand(1);

  return true;
}
