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
#include "SIISelLowering.h"
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
  virtual void PostprocessISelDAG();

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
  bool SelectADDRVTX_READ(SDValue Addr, SDValue &Base, SDValue &Offset);
  bool SelectADDRIndirect(SDValue Addr, SDValue &Base, SDValue &Offset);

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
  case ISD::BUILD_VECTOR: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.device()->getGeneration() > AMDGPUDeviceInfo::HD6XXX) {
      break;
    }
    // BUILD_VECTOR is usually lowered into an IMPLICIT_DEF + 4 INSERT_SUBREG
    // that adds a 128 bits reg copy when going through TwoAddressInstructions
    // pass. We want to avoid 128 bits copies as much as possible because they
    // can't be bundled by our scheduler.
    SDValue RegSeqArgs[9] = {
      CurDAG->getTargetConstant(AMDGPU::R600_Reg128RegClassID, MVT::i32),
      SDValue(), CurDAG->getTargetConstant(AMDGPU::sub0, MVT::i32),
      SDValue(), CurDAG->getTargetConstant(AMDGPU::sub1, MVT::i32),
      SDValue(), CurDAG->getTargetConstant(AMDGPU::sub2, MVT::i32),
      SDValue(), CurDAG->getTargetConstant(AMDGPU::sub3, MVT::i32)
    };
    bool IsRegSeq = true;
    for (unsigned i = 0; i < N->getNumOperands(); i++) {
      if (dyn_cast<RegisterSDNode>(N->getOperand(i))) {
        IsRegSeq = false;
        break;
      }
      RegSeqArgs[2 * i + 1] = N->getOperand(i);
    }
    if (!IsRegSeq)
      break;
    return CurDAG->SelectNodeTo(N, AMDGPU::REG_SEQUENCE, N->getVTList(),
        RegSeqArgs, 2 * N->getNumOperands() + 1);
  }
  case ISD::BUILD_PAIR: {
    SDValue RC, SubReg0, SubReg1;
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.device()->getGeneration() <= AMDGPUDeviceInfo::HD6XXX) {
      break;
    }
    if (N->getValueType(0) == MVT::i128) {
      RC = CurDAG->getTargetConstant(AMDGPU::SReg_128RegClassID, MVT::i32);
      SubReg0 = CurDAG->getTargetConstant(AMDGPU::sub0_sub1, MVT::i32);
      SubReg1 = CurDAG->getTargetConstant(AMDGPU::sub2_sub3, MVT::i32);
    } else if (N->getValueType(0) == MVT::i64) {
      RC = CurDAG->getTargetConstant(AMDGPU::SReg_64RegClassID, MVT::i32);
      SubReg0 = CurDAG->getTargetConstant(AMDGPU::sub0, MVT::i32);
      SubReg1 = CurDAG->getTargetConstant(AMDGPU::sub1, MVT::i32);
    } else {
      llvm_unreachable("Unhandled value type for BUILD_PAIR");
    }
    const SDValue Ops[] = { RC, N->getOperand(0), SubReg0,
                            N->getOperand(1), SubReg1 };
    return CurDAG->getMachineNode(TargetOpcode::REG_SEQUENCE,
                                  N->getDebugLoc(), N->getValueType(0), Ops, 5);
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
        if (!TII->isALUInstr(Use->getMachineOpcode()) ||
            (TII->get(Use->getMachineOpcode()).TSFlags &
            R600_InstFlag::VECTOR)) {
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
    if (Result && Result->isMachineOpcode() &&
        !(TII->get(Result->getMachineOpcode()).TSFlags & R600_InstFlag::VECTOR)
        && TII->isALUInstr(Result->getMachineOpcode())) {
      // Fold FNEG/FABS/CONST_ADDRESS
      // TODO: Isel can generate multiple MachineInst, we need to recursively
      // parse Result
      bool IsModified = false;
      do {
        std::vector<SDValue> Ops;
        for(SDNode::op_iterator I = Result->op_begin(), E = Result->op_end();
            I != E; ++I)
          Ops.push_back(*I);
        IsModified = FoldOperands(Result->getMachineOpcode(), TII, Ops);
        if (IsModified) {
          Result = CurDAG->UpdateNodeOperands(Result, Ops.data(), Ops.size());
        }
      } while (IsModified);

      // If node has a single use which is CLAMP_R600, folds it
      if (Result->hasOneUse() && Result->isMachineOpcode()) {
        SDNode *PotentialClamp = *Result->use_begin();
        if (PotentialClamp->isMachineOpcode() &&
            PotentialClamp->getMachineOpcode() == AMDGPU::CLAMP_R600) {
          unsigned ClampIdx =
            TII->getOperandIdx(Result->getMachineOpcode(), R600Operands::CLAMP);
          std::vector<SDValue> Ops;
          unsigned NumOp = Result->getNumOperands();
          for (unsigned i = 0; i < NumOp; ++i) {
            Ops.push_back(Result->getOperand(i));
          }
          Ops[ClampIdx - 1] = CurDAG->getTargetConstant(1, MVT::i32);
          Result = CurDAG->SelectNodeTo(PotentialClamp,
              Result->getMachineOpcode(), PotentialClamp->getVTList(),
              Ops.data(), NumOp);
        }
      }
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
  int NegIdx[] = {
    TII->getOperandIdx(Opcode, R600Operands::SRC0_NEG),
    TII->getOperandIdx(Opcode, R600Operands::SRC1_NEG),
    TII->getOperandIdx(Opcode, R600Operands::SRC2_NEG)
  };
  int AbsIdx[] = {
    TII->getOperandIdx(Opcode, R600Operands::SRC0_ABS),
    TII->getOperandIdx(Opcode, R600Operands::SRC1_ABS),
    -1
  };

  for (unsigned i = 0; i < 3; i++) {
    if (OperandIdx[i] < 0)
      return false;
    SDValue Operand = Ops[OperandIdx[i] - 1];
    switch (Operand.getOpcode()) {
    case AMDGPUISD::CONST_ADDRESS: {
      SDValue CstOffset;
      if (Operand.getValueType().isVector() ||
          !SelectGlobalValueConstantOffset(Operand.getOperand(0), CstOffset))
        break;

      // Gather others constants values
      std::vector<unsigned> Consts;
      for (unsigned j = 0; j < 3; j++) {
        int SrcIdx = OperandIdx[j];
        if (SrcIdx < 0)
          break;
        if (RegisterSDNode *Reg = dyn_cast<RegisterSDNode>(Ops[SrcIdx - 1])) {
          if (Reg->getReg() == AMDGPU::ALU_CONST) {
            ConstantSDNode *Cst = dyn_cast<ConstantSDNode>(Ops[SelIdx[j] - 1]);
            Consts.push_back(Cst->getZExtValue());
          }
        }
      }

      ConstantSDNode *Cst = dyn_cast<ConstantSDNode>(CstOffset);
      Consts.push_back(Cst->getZExtValue());
      if (!TII->fitsConstReadLimitations(Consts))
        break;

      Ops[OperandIdx[i] - 1] = CurDAG->getRegister(AMDGPU::ALU_CONST, MVT::f32);
      Ops[SelIdx[i] - 1] = CstOffset;
      return true;
      }
    case ISD::FNEG:
      if (NegIdx[i] < 0)
        break;
      Ops[OperandIdx[i] - 1] = Operand.getOperand(0);
      Ops[NegIdx[i] - 1] = CurDAG->getTargetConstant(1, MVT::i32);
      return true;
    case ISD::FABS:
      if (AbsIdx[i] < 0)
        break;
      Ops[OperandIdx[i] - 1] = Operand.getOperand(0);
      Ops[AbsIdx[i] - 1] = CurDAG->getTargetConstant(1, MVT::i32);
      return true;
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

bool AMDGPUDAGToDAGISel::SelectADDRIndirect(SDValue Addr, SDValue &Base,
                                            SDValue &Offset) {
  ConstantSDNode *C;

  if ((C = dyn_cast<ConstantSDNode>(Addr))) {
    Base = CurDAG->getRegister(AMDGPU::INDIRECT_BASE_ADDR, MVT::i32);
    Offset = CurDAG->getTargetConstant(C->getZExtValue(), MVT::i32);
  } else if ((Addr.getOpcode() == ISD::ADD || Addr.getOpcode() == ISD::OR) &&
            (C = dyn_cast<ConstantSDNode>(Addr.getOperand(1)))) {
    Base = Addr.getOperand(0);
    Offset = CurDAG->getTargetConstant(C->getZExtValue(), MVT::i32);
  } else {
    Base = Addr;
    Offset = CurDAG->getTargetConstant(0, MVT::i32);
  }

  return true;
}

void AMDGPUDAGToDAGISel::PostprocessISelDAG() {

  // Go over all selected nodes and try to fold them a bit more
  const AMDGPUTargetLowering& Lowering = ((const AMDGPUTargetLowering&)TLI);
  for (SelectionDAG::allnodes_iterator I = CurDAG->allnodes_begin(),
       E = CurDAG->allnodes_end(); I != E; ++I) {

    MachineSDNode *Node = dyn_cast<MachineSDNode>(I);
    if (!Node)
      continue;

    SDNode *ResNode = Lowering.PostISelFolding(Node, *CurDAG);
    if (ResNode != Node)
      ReplaceUses(Node, ResNode);
  }
}

