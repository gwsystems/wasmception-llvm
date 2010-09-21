//===-- MBlazeISelDAGToDAG.cpp - A dag to dag inst selector for MBlaze ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the MBlaze target.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "mblaze-isel"
#include "MBlaze.h"
#include "MBlazeMachineFunction.h"
#include "MBlazeRegisterInfo.h"
#include "MBlazeSubtarget.h"
#include "MBlazeTargetMachine.h"
#include "llvm/GlobalValue.h"
#include "llvm/Instructions.h"
#include "llvm/Intrinsics.h"
#include "llvm/Support/CFG.h"
#include "llvm/Type.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MBlazeDAGToDAGISel - MBlaze specific code to select MBlaze machine
// instructions for SelectionDAG operations.
//===----------------------------------------------------------------------===//
namespace {

class MBlazeDAGToDAGISel : public SelectionDAGISel {

  /// TM - Keep a reference to MBlazeTargetMachine.
  MBlazeTargetMachine &TM;

  /// Subtarget - Keep a pointer to the MBlazeSubtarget around so that we can
  /// make the right decision when generating code for different targets.
  const MBlazeSubtarget &Subtarget;

public:
  explicit MBlazeDAGToDAGISel(MBlazeTargetMachine &tm) :
  SelectionDAGISel(tm),
  TM(tm), Subtarget(tm.getSubtarget<MBlazeSubtarget>()) {}

  // Pass Name
  virtual const char *getPassName() const {
    return "MBlaze DAG->DAG Pattern Instruction Selection";
  }
private:
  // Include the pieces autogenerated from the target description.
  #include "MBlazeGenDAGISel.inc"

  /// getTargetMachine - Return a reference to the TargetMachine, casted
  /// to the target-specific type.
  const MBlazeTargetMachine &getTargetMachine() {
    return static_cast<const MBlazeTargetMachine &>(TM);
  }

  /// getInstrInfo - Return a reference to the TargetInstrInfo, casted
  /// to the target-specific type.
  const MBlazeInstrInfo *getInstrInfo() {
    return getTargetMachine().getInstrInfo();
  }

  SDNode *getGlobalBaseReg();
  SDNode *Select(SDNode *N);

  // Address Selection
  bool SelectAddrRegReg(SDValue N, SDValue &Base, SDValue &Index);
  bool SelectAddrRegImm(SDValue N, SDValue &Disp, SDValue &Base);

  // getI32Imm - Return a target constant with the specified value, of type i32.
  inline SDValue getI32Imm(unsigned Imm) {
    return CurDAG->getTargetConstant(Imm, MVT::i32);
  }
};

}

/// isIntS32Immediate - This method tests to see if the node is either a 32-bit
/// or 64-bit immediate, and if the value can be accurately represented as a
/// sign extension from a 32-bit value.  If so, this returns true and the
/// immediate.
static bool isIntS32Immediate(SDNode *N, int32_t &Imm) {
  unsigned Opc = N->getOpcode();
  if (Opc != ISD::Constant)
    return false;

  Imm = (int32_t)cast<ConstantSDNode>(N)->getZExtValue();
  if (N->getValueType(0) == MVT::i32)
    return Imm == (int32_t)cast<ConstantSDNode>(N)->getZExtValue();
  else
    return Imm == (int64_t)cast<ConstantSDNode>(N)->getZExtValue();
}

static bool isIntS32Immediate(SDValue Op, int32_t &Imm) {
  return isIntS32Immediate(Op.getNode(), Imm);
}


/// SelectAddressRegReg - Given the specified addressed, check to see if it
/// can be represented as an indexed [r+r] operation.  Returns false if it
/// can be more efficiently represented with [r+imm].
bool MBlazeDAGToDAGISel::
SelectAddrRegReg(SDValue N, SDValue &Base, SDValue &Index) {
  if (N.getOpcode() == ISD::FrameIndex) return false;
  if (N.getOpcode() == ISD::TargetExternalSymbol ||
      N.getOpcode() == ISD::TargetGlobalAddress)
    return false;  // direct calls.

  int32_t imm = 0;
  if (N.getOpcode() == ISD::ADD || N.getOpcode() == ISD::OR) {
    if (isIntS32Immediate(N.getOperand(1), imm))
      return false;    // r+i

    if (N.getOperand(0).getOpcode() == ISD::TargetJumpTable ||
        N.getOperand(1).getOpcode() == ISD::TargetJumpTable)
      return false; // jump tables.

    Base = N.getOperand(1);
    Index = N.getOperand(0);
    return true;
  }

  return false;
}

/// Returns true if the address N can be represented by a base register plus
/// a signed 32-bit displacement [r+imm], and if it is not better
/// represented as reg+reg.
bool MBlazeDAGToDAGISel::
SelectAddrRegImm(SDValue N, SDValue &Disp, SDValue &Base) {
  // If this can be more profitably realized as r+r, fail.
  if (SelectAddrRegReg(N, Disp, Base))
    return false;

  if (N.getOpcode() == ISD::ADD || N.getOpcode() == ISD::OR) {
    int32_t imm = 0;
    if (isIntS32Immediate(N.getOperand(1), imm)) {
      Disp = CurDAG->getTargetConstant(imm, MVT::i32);
      if (FrameIndexSDNode *FI = dyn_cast<FrameIndexSDNode>(N.getOperand(0))) {
        Base = CurDAG->getTargetFrameIndex(FI->getIndex(), N.getValueType());
      } else {
        Base = N.getOperand(0);
      }
      DEBUG( errs() << "WESLEY: Using Operand Immediate\n" );
      return true; // [r+i]
    }
  } else if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N)) {
    // Loading from a constant address.
    uint32_t Imm = CN->getZExtValue();
    Disp = CurDAG->getTargetConstant(Imm, CN->getValueType(0));
    Base = CurDAG->getRegister(MBlaze::R0, CN->getValueType(0));
    DEBUG( errs() << "WESLEY: Using Constant Node\n" );
    return true;
  }

  Disp = CurDAG->getTargetConstant(0, TM.getTargetLowering()->getPointerTy());
  if (FrameIndexSDNode *FI = dyn_cast<FrameIndexSDNode>(N))
    Base = CurDAG->getTargetFrameIndex(FI->getIndex(), N.getValueType());
  else
    Base = N;
  return true;      // [r+0]
}

/// getGlobalBaseReg - Output the instructions required to put the
/// GOT address into a register.
SDNode *MBlazeDAGToDAGISel::getGlobalBaseReg() {
  unsigned GlobalBaseReg = getInstrInfo()->getGlobalBaseReg(MF);
  return CurDAG->getRegister(GlobalBaseReg, TLI.getPointerTy()).getNode();
}

/// Select instructions not customized! Used for
/// expanded, promoted and normal instructions
SDNode* MBlazeDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  DebugLoc dl = Node->getDebugLoc();

  // Dump information about the Node being selected
  DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    return NULL;
  }

  ///
  // Instruction Selection not handled by the auto-generated
  // tablegen selection should be handled here.
  ///
  switch(Opcode) {
    default: break;

    // Get target GOT address.
    case ISD::GLOBAL_OFFSET_TABLE:
      return getGlobalBaseReg();

    case ISD::FrameIndex: {
        SDValue imm = CurDAG->getTargetConstant(0, MVT::i32);
        int FI = dyn_cast<FrameIndexSDNode>(Node)->getIndex();
        EVT VT = Node->getValueType(0);
        SDValue TFI = CurDAG->getTargetFrameIndex(FI, VT);
        unsigned Opc = MBlaze::ADDI;
        if (Node->hasOneUse())
          return CurDAG->SelectNodeTo(Node, Opc, VT, TFI, imm);
        return CurDAG->getMachineNode(Opc, dl, VT, TFI, imm);
    }


    /// Handle direct and indirect calls when using PIC. On PIC, when
    /// GOT is smaller than about 64k (small code) the GA target is
    /// loaded with only one instruction. Otherwise GA's target must
    /// be loaded with 3 instructions.
    case MBlazeISD::JmpLink: {
      if (TM.getRelocationModel() == Reloc::PIC_) {
        SDValue Chain  = Node->getOperand(0);
        SDValue Callee = Node->getOperand(1);
        SDValue R20Reg = CurDAG->getRegister(MBlaze::R20, MVT::i32);
        SDValue InFlag(0, 0);

        if ( (isa<GlobalAddressSDNode>(Callee)) ||
             (isa<ExternalSymbolSDNode>(Callee)) )
        {
          /// Direct call for global addresses and external symbols
          SDValue GPReg = CurDAG->getRegister(MBlaze::R15, MVT::i32);

          // Use load to get GOT target
          SDValue Ops[] = { Callee, GPReg, Chain };
          SDValue Load = SDValue(CurDAG->getMachineNode(MBlaze::LW, dl,
                                 MVT::i32, MVT::Other, Ops, 3), 0);
          Chain = Load.getValue(1);

          // Call target must be on T9
          Chain = CurDAG->getCopyToReg(Chain, dl, R20Reg, Load, InFlag);
        } else
          /// Indirect call
          Chain = CurDAG->getCopyToReg(Chain, dl, R20Reg, Callee, InFlag);

        // Emit Jump and Link Register
        SDNode *ResNode = CurDAG->getMachineNode(MBlaze::BRLID, dl, MVT::Other,
                                                 MVT::Flag, R20Reg, Chain);
        Chain  = SDValue(ResNode, 0);
        InFlag = SDValue(ResNode, 1);
        ReplaceUses(SDValue(Node, 0), Chain);
        ReplaceUses(SDValue(Node, 1), InFlag);
        return ResNode;
      }
    }
  }

  // Select the default instruction
  SDNode *ResNode = SelectCode(Node);

  DEBUG(errs() << "=> ");
  if (ResNode == NULL || ResNode == Node)
    DEBUG(Node->dump(CurDAG));
  else
    DEBUG(ResNode->dump(CurDAG));
  DEBUG(errs() << "\n");
  return ResNode;
}

/// createMBlazeISelDag - This pass converts a legalized DAG into a
/// MBlaze-specific DAG, ready for instruction scheduling.
FunctionPass *llvm::createMBlazeISelDag(MBlazeTargetMachine &TM) {
  return new MBlazeDAGToDAGISel(TM);
}
