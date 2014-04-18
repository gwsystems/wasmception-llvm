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
#include "R600InstrInfo.h"
#include "SIISelLowering.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Support/Compiler.h"
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
  bool isInlineImmediate(SDNode *N) const;
  inline SDValue getSmallIPtrImm(unsigned Imm);
  bool FoldOperand(SDValue &Src, SDValue &Sel, SDValue &Neg, SDValue &Abs,
                   const R600InstrInfo *TII);
  bool FoldOperands(unsigned, const R600InstrInfo *, std::vector<SDValue> &);
  bool FoldDotOperands(unsigned, const R600InstrInfo *, std::vector<SDValue> &);

  // Complex pattern selectors
  bool SelectADDRParam(SDValue Addr, SDValue& R1, SDValue& R2);
  bool SelectADDR(SDValue N, SDValue &R1, SDValue &R2);
  bool SelectADDR64(SDValue N, SDValue &R1, SDValue &R2);

  static bool checkType(const Value *ptr, unsigned int addrspace);
  static bool checkPrivateAddress(const MachineMemOperand *Op);

  static bool isGlobalStore(const StoreSDNode *N);
  static bool isPrivateStore(const StoreSDNode *N);
  static bool isLocalStore(const StoreSDNode *N);
  static bool isRegionStore(const StoreSDNode *N);

  bool isCPLoad(const LoadSDNode *N) const;
  bool isConstantLoad(const LoadSDNode *N, int cbID) const;
  bool isGlobalLoad(const LoadSDNode *N) const;
  bool isParamLoad(const LoadSDNode *N) const;
  bool isPrivateLoad(const LoadSDNode *N) const;
  bool isLocalLoad(const LoadSDNode *N) const;
  bool isRegionLoad(const LoadSDNode *N) const;

  const TargetRegisterClass *getOperandRegClass(SDNode *N, unsigned OpNo) const;
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

AMDGPUDAGToDAGISel::AMDGPUDAGToDAGISel(TargetMachine &TM)
  : SelectionDAGISel(TM), Subtarget(TM.getSubtarget<AMDGPUSubtarget>()) {
}

AMDGPUDAGToDAGISel::~AMDGPUDAGToDAGISel() {
}

bool AMDGPUDAGToDAGISel::isInlineImmediate(SDNode *N) const {
  const SITargetLowering *TL
      = static_cast<const SITargetLowering *>(getTargetLowering());
  return TL->analyzeImmediate(N) == 0;
}

/// \brief Determine the register class for \p OpNo
/// \returns The register class of the virtual register that will be used for
/// the given operand number \OpNo or NULL if the register class cannot be
/// determined.
const TargetRegisterClass *AMDGPUDAGToDAGISel::getOperandRegClass(SDNode *N,
                                                          unsigned OpNo) const {
  if (!N->isMachineOpcode()) {
    return NULL;
  }
  switch (N->getMachineOpcode()) {
  default: {
    const MCInstrDesc &Desc = TM.getInstrInfo()->get(N->getMachineOpcode());
    unsigned OpIdx = Desc.getNumDefs() + OpNo;
    if (OpIdx >= Desc.getNumOperands())
      return NULL;
    int RegClass = Desc.OpInfo[OpIdx].RegClass;
    if (RegClass == -1) {
      return NULL;
    }
    return TM.getRegisterInfo()->getRegClass(RegClass);
  }
  case AMDGPU::REG_SEQUENCE: {
    const TargetRegisterClass *SuperRC = TM.getRegisterInfo()->getRegClass(
                      cast<ConstantSDNode>(N->getOperand(0))->getZExtValue());
    unsigned SubRegIdx =
            dyn_cast<ConstantSDNode>(N->getOperand(OpNo + 1))->getZExtValue();
    return TM.getRegisterInfo()->getSubClassWithSubReg(SuperRC, SubRegIdx);
  }
  }
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
    N->setNodeId(-1);
    return NULL;   // Already selected.
  }
  switch (Opc) {
  default: break;
  // We are selecting i64 ADD here instead of custom lower it during
  // DAG legalization, so we can fold some i64 ADDs used for address
  // calculation into the LOAD and STORE instructions.
  case ISD::ADD: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (N->getValueType(0) != MVT::i64 ||
        ST.getGeneration() < AMDGPUSubtarget::SOUTHERN_ISLANDS)
      break;

    SDLoc DL(N);
    SDValue LHS = N->getOperand(0);
    SDValue RHS = N->getOperand(1);

    SDValue Sub0 = CurDAG->getTargetConstant(AMDGPU::sub0, MVT::i32);
    SDValue Sub1 = CurDAG->getTargetConstant(AMDGPU::sub1, MVT::i32);

    SDNode *Lo0 = CurDAG->getMachineNode(TargetOpcode::EXTRACT_SUBREG,
                                         DL, MVT::i32, LHS, Sub0);
    SDNode *Hi0 = CurDAG->getMachineNode(TargetOpcode::EXTRACT_SUBREG,
                                         DL, MVT::i32, LHS, Sub1);

    SDNode *Lo1 = CurDAG->getMachineNode(TargetOpcode::EXTRACT_SUBREG,
                                         DL, MVT::i32, RHS, Sub0);
    SDNode *Hi1 = CurDAG->getMachineNode(TargetOpcode::EXTRACT_SUBREG,
                                         DL, MVT::i32, RHS, Sub1);

    SDVTList VTList = CurDAG->getVTList(MVT::i32, MVT::Glue);

    SmallVector<SDValue, 8> AddLoArgs;
    AddLoArgs.push_back(SDValue(Lo0, 0));
    AddLoArgs.push_back(SDValue(Lo1, 0));

    SDNode *AddLo = CurDAG->getMachineNode(AMDGPU::S_ADD_I32, DL,
                                           VTList, AddLoArgs);
    SDValue Carry = SDValue(AddLo, 1);
    SDNode *AddHi = CurDAG->getMachineNode(AMDGPU::S_ADDC_U32, DL,
                                           MVT::i32, SDValue(Hi0, 0),
                                           SDValue(Hi1, 0), Carry);

    SDValue Args[5] = {
      CurDAG->getTargetConstant(AMDGPU::SReg_64RegClassID, MVT::i32),
      SDValue(AddLo,0),
      Sub0,
      SDValue(AddHi,0),
      Sub1,
    };
    return CurDAG->SelectNodeTo(N, AMDGPU::REG_SEQUENCE, MVT::i64, Args, 5);
  }
  case ISD::BUILD_VECTOR: {
    unsigned RegClassID;
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    const AMDGPURegisterInfo *TRI =
                   static_cast<const AMDGPURegisterInfo*>(TM.getRegisterInfo());
    const SIRegisterInfo *SIRI =
                   static_cast<const SIRegisterInfo*>(TM.getRegisterInfo());
    EVT VT = N->getValueType(0);
    unsigned NumVectorElts = VT.getVectorNumElements();
    assert(VT.getVectorElementType().bitsEq(MVT::i32));
    if (ST.getGeneration() >= AMDGPUSubtarget::SOUTHERN_ISLANDS) {
      bool UseVReg = true;
      for (SDNode::use_iterator U = N->use_begin(), E = SDNode::use_end();
                                                    U != E; ++U) {
        if (!U->isMachineOpcode()) {
          continue;
        }
        const TargetRegisterClass *RC = getOperandRegClass(*U, U.getOperandNo());
        if (!RC) {
          continue;
        }
        if (SIRI->isSGPRClass(RC)) {
          UseVReg = false;
        }
      }
      switch(NumVectorElts) {
      case 1: RegClassID = UseVReg ? AMDGPU::VReg_32RegClassID :
                                     AMDGPU::SReg_32RegClassID;
        break;
      case 2: RegClassID = UseVReg ? AMDGPU::VReg_64RegClassID :
                                     AMDGPU::SReg_64RegClassID;
        break;
      case 4: RegClassID = UseVReg ? AMDGPU::VReg_128RegClassID :
                                     AMDGPU::SReg_128RegClassID;
        break;
      case 8: RegClassID = UseVReg ? AMDGPU::VReg_256RegClassID :
                                     AMDGPU::SReg_256RegClassID;
        break;
      case 16: RegClassID = UseVReg ? AMDGPU::VReg_512RegClassID :
                                      AMDGPU::SReg_512RegClassID;
        break;
      default: llvm_unreachable("Do not know how to lower this BUILD_VECTOR");
      }
    } else {
      // BUILD_VECTOR was lowered into an IMPLICIT_DEF + 4 INSERT_SUBREG
      // that adds a 128 bits reg copy when going through TwoAddressInstructions
      // pass. We want to avoid 128 bits copies as much as possible because they
      // can't be bundled by our scheduler.
      switch(NumVectorElts) {
      case 2: RegClassID = AMDGPU::R600_Reg64RegClassID; break;
      case 4: RegClassID = AMDGPU::R600_Reg128RegClassID; break;
      default: llvm_unreachable("Do not know how to lower this BUILD_VECTOR");
      }
    }

    SDValue RegClass = CurDAG->getTargetConstant(RegClassID, MVT::i32);

    if (NumVectorElts == 1) {
      return CurDAG->SelectNodeTo(N, AMDGPU::COPY_TO_REGCLASS,
                                  VT.getVectorElementType(),
                                  N->getOperand(0), RegClass);
    }

    assert(NumVectorElts <= 16 && "Vectors with more than 16 elements not "
                                  "supported yet");
    // 16 = Max Num Vector Elements
    // 2 = 2 REG_SEQUENCE operands per element (value, subreg index)
    // 1 = Vector Register Class
    SDValue RegSeqArgs[16 * 2 + 1];

    RegSeqArgs[0] = CurDAG->getTargetConstant(RegClassID, MVT::i32);
    bool IsRegSeq = true;
    for (unsigned i = 0; i < N->getNumOperands(); i++) {
      // XXX: Why is this here?
      if (dyn_cast<RegisterSDNode>(N->getOperand(i))) {
        IsRegSeq = false;
        break;
      }
      RegSeqArgs[1 + (2 * i)] = N->getOperand(i);
      RegSeqArgs[1 + (2 * i) + 1] =
              CurDAG->getTargetConstant(TRI->getSubRegFromChannel(i), MVT::i32);
    }
    if (!IsRegSeq)
      break;
    return CurDAG->SelectNodeTo(N, AMDGPU::REG_SEQUENCE, N->getVTList(),
        RegSeqArgs, 2 * N->getNumOperands() + 1);
  }
  case ISD::BUILD_PAIR: {
    SDValue RC, SubReg0, SubReg1;
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.getGeneration() <= AMDGPUSubtarget::NORTHERN_ISLANDS) {
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
                                  SDLoc(N), N->getValueType(0), Ops);
  }

  case ISD::Constant:
  case ISD::ConstantFP: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.getGeneration() < AMDGPUSubtarget::SOUTHERN_ISLANDS ||
        N->getValueType(0).getSizeInBits() != 64 || isInlineImmediate(N))
      break;

    uint64_t Imm;
    if (ConstantFPSDNode *FP = dyn_cast<ConstantFPSDNode>(N))
      Imm = FP->getValueAPF().bitcastToAPInt().getZExtValue();
    else {
      ConstantSDNode *C = cast<ConstantSDNode>(N);
      Imm = C->getZExtValue();
    }

    SDNode *Lo = CurDAG->getMachineNode(AMDGPU::S_MOV_B32, SDLoc(N), MVT::i32,
                                CurDAG->getConstant(Imm & 0xFFFFFFFF, MVT::i32));
    SDNode *Hi = CurDAG->getMachineNode(AMDGPU::S_MOV_B32, SDLoc(N), MVT::i32,
                                CurDAG->getConstant(Imm >> 32, MVT::i32));
    const SDValue Ops[] = {
      CurDAG->getTargetConstant(AMDGPU::SReg_64RegClassID, MVT::i32),
      SDValue(Lo, 0), CurDAG->getTargetConstant(AMDGPU::sub0, MVT::i32),
      SDValue(Hi, 0), CurDAG->getTargetConstant(AMDGPU::sub1, MVT::i32)
    };

    return CurDAG->getMachineNode(TargetOpcode::REG_SEQUENCE, SDLoc(N),
                                  N->getValueType(0), Ops);
  }

  case AMDGPUISD::REGISTER_LOAD: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.getGeneration() <= AMDGPUSubtarget::NORTHERN_ISLANDS)
      break;
    SDValue Addr, Offset;

    SelectADDRIndirect(N->getOperand(1), Addr, Offset);
    const SDValue Ops[] = {
      Addr,
      Offset,
      CurDAG->getTargetConstant(0, MVT::i32),
      N->getOperand(0),
    };
    return CurDAG->getMachineNode(AMDGPU::SI_RegisterLoad, SDLoc(N),
                                  CurDAG->getVTList(MVT::i32, MVT::i64, MVT::Other),
                                  Ops);
  }
  case AMDGPUISD::REGISTER_STORE: {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.getGeneration() <= AMDGPUSubtarget::NORTHERN_ISLANDS)
      break;
    SDValue Addr, Offset;
    SelectADDRIndirect(N->getOperand(2), Addr, Offset);
    const SDValue Ops[] = {
      N->getOperand(1),
      Addr,
      Offset,
      CurDAG->getTargetConstant(0, MVT::i32),
      N->getOperand(0),
    };
    return CurDAG->getMachineNode(AMDGPU::SI_RegisterStorePseudo, SDLoc(N),
                                        CurDAG->getVTList(MVT::Other),
                                        Ops);
  }
  }
  return SelectCode(N);
}


bool AMDGPUDAGToDAGISel::checkType(const Value *ptr, unsigned int addrspace) {
  assert(addrspace != 0 && "Use checkPrivateAddress instead.");
  if (!ptr) {
    return false;
  }
  Type *ptrType = ptr->getType();
  return dyn_cast<PointerType>(ptrType)->getAddressSpace() == addrspace;
}

bool AMDGPUDAGToDAGISel::checkPrivateAddress(const MachineMemOperand *Op) {
  if (Op->getPseudoValue()) return true;
  const Value *ptr = Op->getValue();
  if (!ptr) return false;
  PointerType *ptrType = dyn_cast<PointerType>(ptr->getType());
  return ptrType->getAddressSpace() == AMDGPUAS::PRIVATE_ADDRESS;
}

bool AMDGPUDAGToDAGISel::isGlobalStore(const StoreSDNode *N) {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::GLOBAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isPrivateStore(const StoreSDNode *N) {
  return (!checkType(N->getMemOperand()->getValue(), AMDGPUAS::LOCAL_ADDRESS)
          && !checkType(N->getMemOperand()->getValue(),
                        AMDGPUAS::GLOBAL_ADDRESS)
          && !checkType(N->getMemOperand()->getValue(),
                        AMDGPUAS::REGION_ADDRESS));
}

bool AMDGPUDAGToDAGISel::isLocalStore(const StoreSDNode *N) {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::LOCAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isRegionStore(const StoreSDNode *N) {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::REGION_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isConstantLoad(const LoadSDNode *N, int CbId) const {
  if (CbId == -1) {
    return checkType(N->getMemOperand()->getValue(),
                     AMDGPUAS::CONSTANT_ADDRESS);
  }
  return checkType(N->getMemOperand()->getValue(),
                   AMDGPUAS::CONSTANT_BUFFER_0 + CbId);
}

bool AMDGPUDAGToDAGISel::isGlobalLoad(const LoadSDNode *N) const {
  if (N->getAddressSpace() == AMDGPUAS::CONSTANT_ADDRESS) {
    const AMDGPUSubtarget &ST = TM.getSubtarget<AMDGPUSubtarget>();
    if (ST.getGeneration() < AMDGPUSubtarget::SOUTHERN_ISLANDS ||
        N->getMemoryVT().bitsLT(MVT::i32)) {
      return true;
    }
  }
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::GLOBAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isParamLoad(const LoadSDNode *N) const {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::PARAM_I_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isLocalLoad(const  LoadSDNode *N) const {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::LOCAL_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isRegionLoad(const  LoadSDNode *N) const {
  return checkType(N->getMemOperand()->getValue(), AMDGPUAS::REGION_ADDRESS);
}

bool AMDGPUDAGToDAGISel::isCPLoad(const LoadSDNode *N) const {
  MachineMemOperand *MMO = N->getMemOperand();
  if (checkPrivateAddress(N->getMemOperand())) {
    if (MMO) {
      const PseudoSourceValue *PSV = MMO->getPseudoValue();
      if (PSV && PSV == PseudoSourceValue::getConstantPool()) {
        return true;
      }
    }
  }
  return false;
}

bool AMDGPUDAGToDAGISel::isPrivateLoad(const LoadSDNode *N) const {
  if (checkPrivateAddress(N->getMemOperand())) {
    // Check to make sure we are not a constant pool load or a constant load
    // that is marked as a private load
    if (isCPLoad(N) || isConstantLoad(N, -1)) {
      return false;
    }
  }
  if (!checkType(N->getMemOperand()->getValue(), AMDGPUAS::LOCAL_ADDRESS)
      && !checkType(N->getMemOperand()->getValue(), AMDGPUAS::GLOBAL_ADDRESS)
      && !checkType(N->getMemOperand()->getValue(), AMDGPUAS::REGION_ADDRESS)
      && !checkType(N->getMemOperand()->getValue(), AMDGPUAS::CONSTANT_ADDRESS)
      && !checkType(N->getMemOperand()->getValue(), AMDGPUAS::PARAM_D_ADDRESS)
      && !checkType(N->getMemOperand()->getValue(), AMDGPUAS::PARAM_I_ADDRESS)){
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

//===----------------------------------------------------------------------===//
// Complex Patterns
//===----------------------------------------------------------------------===//

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
                                  SDLoc(CurDAG->getEntryNode()),
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
  const AMDGPUTargetLowering& Lowering =
    (*(const AMDGPUTargetLowering*)getTargetLowering());
  bool IsModified = false;
  do {
    IsModified = false;
    // Go over all selected nodes and try to fold them a bit more
    for (SelectionDAG::allnodes_iterator I = CurDAG->allnodes_begin(),
         E = CurDAG->allnodes_end(); I != E; ++I) {

      SDNode *Node = I;

      MachineSDNode *MachineNode = dyn_cast<MachineSDNode>(I);
      if (!MachineNode)
        continue;

      SDNode *ResNode = Lowering.PostISelFolding(MachineNode, *CurDAG);
      if (ResNode != Node) {
        ReplaceUses(Node, ResNode);
        IsModified = true;
      }
    }
    CurDAG->RemoveDeadNodes();
  } while (IsModified);
}
