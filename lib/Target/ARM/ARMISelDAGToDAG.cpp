//===-- ARMISelDAGToDAG.cpp - A dag to dag inst selector for ARM ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the ARM target.
//
//===----------------------------------------------------------------------===//

#include "ARM.h"
#include "ARMAddressingModes.h"
#include "ARMConstantPoolValue.h"
#include "ARMISelLowering.h"
#include "ARMTargetMachine.h"
#include "llvm/CallingConv.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Function.h"
#include "llvm/Intrinsics.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

static const unsigned arm_dsubreg_0 = 5;
static const unsigned arm_dsubreg_1 = 6;

//===--------------------------------------------------------------------===//
/// ARMDAGToDAGISel - ARM specific code to select ARM machine
/// instructions for SelectionDAG operations.
///
namespace {
class ARMDAGToDAGISel : public SelectionDAGISel {
  ARMTargetMachine &TM;

  /// Subtarget - Keep a pointer to the ARMSubtarget around so that we can
  /// make the right decision when generating code for different targets.
  const ARMSubtarget *Subtarget;

public:
  explicit ARMDAGToDAGISel(ARMTargetMachine &tm)
    : SelectionDAGISel(tm), TM(tm),
    Subtarget(&TM.getSubtarget<ARMSubtarget>()) {
  }

  virtual const char *getPassName() const {
    return "ARM Instruction Selection";
  }

 /// getI32Imm - Return a target constant with the specified value, of type i32.
  inline SDValue getI32Imm(unsigned Imm) {
    return CurDAG->getTargetConstant(Imm, MVT::i32);
  }

  SDNode *Select(SDValue Op);
  virtual void InstructionSelect();
  bool SelectAddrMode2(SDValue Op, SDValue N, SDValue &Base,
                       SDValue &Offset, SDValue &Opc);
  bool SelectAddrMode2Offset(SDValue Op, SDValue N,
                             SDValue &Offset, SDValue &Opc);
  bool SelectAddrMode3(SDValue Op, SDValue N, SDValue &Base,
                       SDValue &Offset, SDValue &Opc);
  bool SelectAddrMode3Offset(SDValue Op, SDValue N,
                             SDValue &Offset, SDValue &Opc);
  bool SelectAddrMode5(SDValue Op, SDValue N, SDValue &Base,
                       SDValue &Offset);

  bool SelectAddrModePC(SDValue Op, SDValue N, SDValue &Offset,
                         SDValue &Label);

  bool SelectThumbAddrModeRR(SDValue Op, SDValue N, SDValue &Base,
                             SDValue &Offset);
  bool SelectThumbAddrModeRI5(SDValue Op, SDValue N, unsigned Scale,
                              SDValue &Base, SDValue &OffImm,
                              SDValue &Offset);
  bool SelectThumbAddrModeS1(SDValue Op, SDValue N, SDValue &Base,
                             SDValue &OffImm, SDValue &Offset);
  bool SelectThumbAddrModeS2(SDValue Op, SDValue N, SDValue &Base,
                             SDValue &OffImm, SDValue &Offset);
  bool SelectThumbAddrModeS4(SDValue Op, SDValue N, SDValue &Base,
                             SDValue &OffImm, SDValue &Offset);
  bool SelectThumbAddrModeSP(SDValue Op, SDValue N, SDValue &Base,
                             SDValue &OffImm);

  bool SelectShifterOperand(SDValue Op, SDValue N,
                            SDValue &BaseReg, SDValue &Opc);

  bool SelectShifterOperandReg(SDValue Op, SDValue N, SDValue &A,
                               SDValue &B, SDValue &C);
  
  // Include the pieces autogenerated from the target description.
#include "ARMGenDAGISel.inc"

private:
    /// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
    /// inline asm expressions.
    virtual bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                              char ConstraintCode,
                                              std::vector<SDValue> &OutOps);
};
}

void ARMDAGToDAGISel::InstructionSelect() {
  DEBUG(BB->dump());

  SelectRoot(*CurDAG);
  CurDAG->RemoveDeadNodes();
}

bool ARMDAGToDAGISel::SelectAddrMode2(SDValue Op, SDValue N,
                                      SDValue &Base, SDValue &Offset,
                                      SDValue &Opc) {
  if (N.getOpcode() == ISD::MUL) {
    if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      // X * [3,5,9] -> X + X * [2,4,8] etc.
      int RHSC = (int)RHS->getZExtValue();
      if (RHSC & 1) {
        RHSC = RHSC & ~1;
        ARM_AM::AddrOpc AddSub = ARM_AM::add;
        if (RHSC < 0) {
          AddSub = ARM_AM::sub;
          RHSC = - RHSC;
        }
        if (isPowerOf2_32(RHSC)) {
          unsigned ShAmt = Log2_32(RHSC);
          Base = Offset = N.getOperand(0);
          Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(AddSub, ShAmt,
                                                            ARM_AM::lsl),
                                          MVT::i32);
          return true;
        }
      }
    }
  }

  if (N.getOpcode() != ISD::ADD && N.getOpcode() != ISD::SUB) {
    Base = N;
    if (N.getOpcode() == ISD::FrameIndex) {
      int FI = cast<FrameIndexSDNode>(N)->getIndex();
      Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    } else if (N.getOpcode() == ARMISD::Wrapper) {
      Base = N.getOperand(0);
    }
    Offset = CurDAG->getRegister(0, MVT::i32);
    Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(ARM_AM::add, 0,
                                                      ARM_AM::no_shift),
                                    MVT::i32);
    return true;
  }
  
  // Match simple R +/- imm12 operands.
  if (N.getOpcode() == ISD::ADD)
    if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      int RHSC = (int)RHS->getZExtValue();
      if ((RHSC >= 0 && RHSC < 0x1000) ||
          (RHSC < 0 && RHSC > -0x1000)) { // 12 bits.
        Base = N.getOperand(0);
        if (Base.getOpcode() == ISD::FrameIndex) {
          int FI = cast<FrameIndexSDNode>(Base)->getIndex();
          Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
        }
        Offset = CurDAG->getRegister(0, MVT::i32);

        ARM_AM::AddrOpc AddSub = ARM_AM::add;
        if (RHSC < 0) {
          AddSub = ARM_AM::sub;
          RHSC = - RHSC;
        }
        Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(AddSub, RHSC,
                                                          ARM_AM::no_shift),
                                        MVT::i32);
        return true;
      }
    }
  
  // Otherwise this is R +/- [possibly shifted] R
  ARM_AM::AddrOpc AddSub = N.getOpcode() == ISD::ADD ? ARM_AM::add:ARM_AM::sub;
  ARM_AM::ShiftOpc ShOpcVal = ARM_AM::getShiftOpcForNode(N.getOperand(1));
  unsigned ShAmt = 0;
  
  Base   = N.getOperand(0);
  Offset = N.getOperand(1);
  
  if (ShOpcVal != ARM_AM::no_shift) {
    // Check to see if the RHS of the shift is a constant, if not, we can't fold
    // it.
    if (ConstantSDNode *Sh =
           dyn_cast<ConstantSDNode>(N.getOperand(1).getOperand(1))) {
      ShAmt = Sh->getZExtValue();
      Offset = N.getOperand(1).getOperand(0);
    } else {
      ShOpcVal = ARM_AM::no_shift;
    }
  }
  
  // Try matching (R shl C) + (R).
  if (N.getOpcode() == ISD::ADD && ShOpcVal == ARM_AM::no_shift) {
    ShOpcVal = ARM_AM::getShiftOpcForNode(N.getOperand(0));
    if (ShOpcVal != ARM_AM::no_shift) {
      // Check to see if the RHS of the shift is a constant, if not, we can't
      // fold it.
      if (ConstantSDNode *Sh =
          dyn_cast<ConstantSDNode>(N.getOperand(0).getOperand(1))) {
        ShAmt = Sh->getZExtValue();
        Offset = N.getOperand(0).getOperand(0);
        Base = N.getOperand(1);
      } else {
        ShOpcVal = ARM_AM::no_shift;
      }
    }
  }
  
  Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(AddSub, ShAmt, ShOpcVal),
                                  MVT::i32);
  return true;
}

bool ARMDAGToDAGISel::SelectAddrMode2Offset(SDValue Op, SDValue N,
                                            SDValue &Offset, SDValue &Opc) {
  unsigned Opcode = Op.getOpcode();
  ISD::MemIndexedMode AM = (Opcode == ISD::LOAD)
    ? cast<LoadSDNode>(Op)->getAddressingMode()
    : cast<StoreSDNode>(Op)->getAddressingMode();
  ARM_AM::AddrOpc AddSub = (AM == ISD::PRE_INC || AM == ISD::POST_INC)
    ? ARM_AM::add : ARM_AM::sub;
  if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(N)) {
    int Val = (int)C->getZExtValue();
    if (Val >= 0 && Val < 0x1000) { // 12 bits.
      Offset = CurDAG->getRegister(0, MVT::i32);
      Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(AddSub, Val,
                                                        ARM_AM::no_shift),
                                      MVT::i32);
      return true;
    }
  }

  Offset = N;
  ARM_AM::ShiftOpc ShOpcVal = ARM_AM::getShiftOpcForNode(N);
  unsigned ShAmt = 0;
  if (ShOpcVal != ARM_AM::no_shift) {
    // Check to see if the RHS of the shift is a constant, if not, we can't fold
    // it.
    if (ConstantSDNode *Sh = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      ShAmt = Sh->getZExtValue();
      Offset = N.getOperand(0);
    } else {
      ShOpcVal = ARM_AM::no_shift;
    }
  }

  Opc = CurDAG->getTargetConstant(ARM_AM::getAM2Opc(AddSub, ShAmt, ShOpcVal),
                                  MVT::i32);
  return true;
}


bool ARMDAGToDAGISel::SelectAddrMode3(SDValue Op, SDValue N,
                                      SDValue &Base, SDValue &Offset,
                                      SDValue &Opc) {
  if (N.getOpcode() == ISD::SUB) {
    // X - C  is canonicalize to X + -C, no need to handle it here.
    Base = N.getOperand(0);
    Offset = N.getOperand(1);
    Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(ARM_AM::sub, 0),MVT::i32);
    return true;
  }
  
  if (N.getOpcode() != ISD::ADD) {
    Base = N;
    if (N.getOpcode() == ISD::FrameIndex) {
      int FI = cast<FrameIndexSDNode>(N)->getIndex();
      Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    }
    Offset = CurDAG->getRegister(0, MVT::i32);
    Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(ARM_AM::add, 0),MVT::i32);
    return true;
  }
  
  // If the RHS is +/- imm8, fold into addr mode.
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
    int RHSC = (int)RHS->getZExtValue();
    if ((RHSC >= 0 && RHSC < 256) ||
        (RHSC < 0 && RHSC > -256)) { // note -256 itself isn't allowed.
      Base = N.getOperand(0);
      if (Base.getOpcode() == ISD::FrameIndex) {
        int FI = cast<FrameIndexSDNode>(Base)->getIndex();
        Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
      }
      Offset = CurDAG->getRegister(0, MVT::i32);

      ARM_AM::AddrOpc AddSub = ARM_AM::add;
      if (RHSC < 0) {
        AddSub = ARM_AM::sub;
        RHSC = - RHSC;
      }
      Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(AddSub, RHSC),MVT::i32);
      return true;
    }
  }
  
  Base = N.getOperand(0);
  Offset = N.getOperand(1);
  Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(ARM_AM::add, 0), MVT::i32);
  return true;
}

bool ARMDAGToDAGISel::SelectAddrMode3Offset(SDValue Op, SDValue N,
                                            SDValue &Offset, SDValue &Opc) {
  unsigned Opcode = Op.getOpcode();
  ISD::MemIndexedMode AM = (Opcode == ISD::LOAD)
    ? cast<LoadSDNode>(Op)->getAddressingMode()
    : cast<StoreSDNode>(Op)->getAddressingMode();
  ARM_AM::AddrOpc AddSub = (AM == ISD::PRE_INC || AM == ISD::POST_INC)
    ? ARM_AM::add : ARM_AM::sub;
  if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(N)) {
    int Val = (int)C->getZExtValue();
    if (Val >= 0 && Val < 256) {
      Offset = CurDAG->getRegister(0, MVT::i32);
      Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(AddSub, Val), MVT::i32);
      return true;
    }
  }

  Offset = N;
  Opc = CurDAG->getTargetConstant(ARM_AM::getAM3Opc(AddSub, 0), MVT::i32);
  return true;
}


bool ARMDAGToDAGISel::SelectAddrMode5(SDValue Op, SDValue N,
                                      SDValue &Base, SDValue &Offset) {
  if (N.getOpcode() != ISD::ADD) {
    Base = N;
    if (N.getOpcode() == ISD::FrameIndex) {
      int FI = cast<FrameIndexSDNode>(N)->getIndex();
      Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    } else if (N.getOpcode() == ARMISD::Wrapper) {
      Base = N.getOperand(0);
    }
    Offset = CurDAG->getTargetConstant(ARM_AM::getAM5Opc(ARM_AM::add, 0),
                                       MVT::i32);
    return true;
  }
  
  // If the RHS is +/- imm8, fold into addr mode.
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
    int RHSC = (int)RHS->getZExtValue();
    if ((RHSC & 3) == 0) {  // The constant is implicitly multiplied by 4.
      RHSC >>= 2;
      if ((RHSC >= 0 && RHSC < 256) ||
          (RHSC < 0 && RHSC > -256)) { // note -256 itself isn't allowed.
        Base = N.getOperand(0);
        if (Base.getOpcode() == ISD::FrameIndex) {
          int FI = cast<FrameIndexSDNode>(Base)->getIndex();
          Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
        }

        ARM_AM::AddrOpc AddSub = ARM_AM::add;
        if (RHSC < 0) {
          AddSub = ARM_AM::sub;
          RHSC = - RHSC;
        }
        Offset = CurDAG->getTargetConstant(ARM_AM::getAM5Opc(AddSub, RHSC),
                                           MVT::i32);
        return true;
      }
    }
  }
  
  Base = N;
  Offset = CurDAG->getTargetConstant(ARM_AM::getAM5Opc(ARM_AM::add, 0),
                                     MVT::i32);
  return true;
}

bool ARMDAGToDAGISel::SelectAddrModePC(SDValue Op, SDValue N,
                                        SDValue &Offset, SDValue &Label) {
  if (N.getOpcode() == ARMISD::PIC_ADD && N.hasOneUse()) {
    Offset = N.getOperand(0);
    SDValue N1 = N.getOperand(1);
    Label  = CurDAG->getTargetConstant(cast<ConstantSDNode>(N1)->getZExtValue(),
                                       MVT::i32);
    return true;
  }
  return false;
}

bool ARMDAGToDAGISel::SelectThumbAddrModeRR(SDValue Op, SDValue N,
                                            SDValue &Base, SDValue &Offset){
  // FIXME dl should come from the parent load or store, not the address
  DebugLoc dl = Op.getDebugLoc();
  if (N.getOpcode() != ISD::ADD) {
    Base = N;
    // We must materialize a zero in a reg! Returning a constant here
    // wouldn't work without additional code to position the node within
    // ISel's topological ordering in a place where ISel will process it
    // normally.  Instead, just explicitly issue a tMOVri8 node!
    Offset = SDValue(CurDAG->getTargetNode(ARM::tMOVi8, dl, MVT::i32,
                                    CurDAG->getTargetConstant(0, MVT::i32)), 0);
    return true;
  }

  Base = N.getOperand(0);
  Offset = N.getOperand(1);
  return true;
}

bool
ARMDAGToDAGISel::SelectThumbAddrModeRI5(SDValue Op, SDValue N,
                                        unsigned Scale, SDValue &Base,
                                        SDValue &OffImm, SDValue &Offset) {
  if (Scale == 4) {
    SDValue TmpBase, TmpOffImm;
    if (SelectThumbAddrModeSP(Op, N, TmpBase, TmpOffImm))
      return false;  // We want to select tLDRspi / tSTRspi instead.
    if (N.getOpcode() == ARMISD::Wrapper &&
        N.getOperand(0).getOpcode() == ISD::TargetConstantPool)
      return false;  // We want to select tLDRpci instead.
  }

  if (N.getOpcode() != ISD::ADD) {
    Base = (N.getOpcode() == ARMISD::Wrapper) ? N.getOperand(0) : N;
    Offset = CurDAG->getRegister(0, MVT::i32);
    OffImm = CurDAG->getTargetConstant(0, MVT::i32);
    return true;
  }

  // Thumb does not have [sp, r] address mode.
  RegisterSDNode *LHSR = dyn_cast<RegisterSDNode>(N.getOperand(0));
  RegisterSDNode *RHSR = dyn_cast<RegisterSDNode>(N.getOperand(1));
  if ((LHSR && LHSR->getReg() == ARM::SP) ||
      (RHSR && RHSR->getReg() == ARM::SP)) {
    Base = N;
    Offset = CurDAG->getRegister(0, MVT::i32);
    OffImm = CurDAG->getTargetConstant(0, MVT::i32);
    return true;
  }

  // If the RHS is + imm5 * scale, fold into addr mode.
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
    int RHSC = (int)RHS->getZExtValue();
    if ((RHSC & (Scale-1)) == 0) {  // The constant is implicitly multiplied.
      RHSC /= Scale;
      if (RHSC >= 0 && RHSC < 32) {
        Base = N.getOperand(0);
        Offset = CurDAG->getRegister(0, MVT::i32);
        OffImm = CurDAG->getTargetConstant(RHSC, MVT::i32);
        return true;
      }
    }
  }

  Base = N.getOperand(0);
  Offset = N.getOperand(1);
  OffImm = CurDAG->getTargetConstant(0, MVT::i32);
  return true;
}

bool ARMDAGToDAGISel::SelectThumbAddrModeS1(SDValue Op, SDValue N,
                                            SDValue &Base, SDValue &OffImm,
                                            SDValue &Offset) {
  return SelectThumbAddrModeRI5(Op, N, 1, Base, OffImm, Offset);
}

bool ARMDAGToDAGISel::SelectThumbAddrModeS2(SDValue Op, SDValue N,
                                            SDValue &Base, SDValue &OffImm,
                                            SDValue &Offset) {
  return SelectThumbAddrModeRI5(Op, N, 2, Base, OffImm, Offset);
}

bool ARMDAGToDAGISel::SelectThumbAddrModeS4(SDValue Op, SDValue N,
                                            SDValue &Base, SDValue &OffImm,
                                            SDValue &Offset) {
  return SelectThumbAddrModeRI5(Op, N, 4, Base, OffImm, Offset);
}

bool ARMDAGToDAGISel::SelectThumbAddrModeSP(SDValue Op, SDValue N,
                                           SDValue &Base, SDValue &OffImm) {
  if (N.getOpcode() == ISD::FrameIndex) {
    int FI = cast<FrameIndexSDNode>(N)->getIndex();
    Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    OffImm = CurDAG->getTargetConstant(0, MVT::i32);
    return true;
  }

  if (N.getOpcode() != ISD::ADD)
    return false;

  RegisterSDNode *LHSR = dyn_cast<RegisterSDNode>(N.getOperand(0));
  if (N.getOperand(0).getOpcode() == ISD::FrameIndex ||
      (LHSR && LHSR->getReg() == ARM::SP)) {
    // If the RHS is + imm8 * scale, fold into addr mode.
    if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      int RHSC = (int)RHS->getZExtValue();
      if ((RHSC & 3) == 0) {  // The constant is implicitly multiplied.
        RHSC >>= 2;
        if (RHSC >= 0 && RHSC < 256) {
          Base = N.getOperand(0);
          if (Base.getOpcode() == ISD::FrameIndex) {
            int FI = cast<FrameIndexSDNode>(Base)->getIndex();
            Base = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
          }
          OffImm = CurDAG->getTargetConstant(RHSC, MVT::i32);
          return true;
        }
      }
    }
  }
  
  return false;
}

bool ARMDAGToDAGISel::SelectShifterOperand(SDValue Op,
                                           SDValue N,
                                           SDValue &BaseReg,
                                           SDValue &Opc) {
  ARM_AM::ShiftOpc ShOpcVal = ARM_AM::getShiftOpcForNode(N);

  // Don't match base register only case. That is matched to a separate
  // lower complexity pattern with explicit register operand.
  if (ShOpcVal == ARM_AM::no_shift) return false;

  BaseReg = N.getOperand(0);
  unsigned ShImmVal = 0;
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1)))
    ShImmVal = RHS->getZExtValue() & 31;
  else
    return false;

  Opc = getI32Imm(ARM_AM::getSORegOpc(ShOpcVal, ShImmVal));

  return true;
}

bool ARMDAGToDAGISel::SelectShifterOperandReg(SDValue Op,
                                              SDValue N,
                                              SDValue &BaseReg,
                                              SDValue &ShReg,
                                              SDValue &Opc) {
  ARM_AM::ShiftOpc ShOpcVal = ARM_AM::getShiftOpcForNode(N);

  // Don't match base register only case. That is matched to a separate
  // lower complexity pattern with explicit register operand.
  if (ShOpcVal == ARM_AM::no_shift) return false;
  
  BaseReg = N.getOperand(0);
  unsigned ShImmVal = 0;
  if (ConstantSDNode *RHS = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
    ShReg = CurDAG->getRegister(0, MVT::i32);
    ShImmVal = RHS->getZExtValue() & 31;
  } else {
    ShReg = N.getOperand(1);
  }
  Opc = CurDAG->getTargetConstant(ARM_AM::getSORegOpc(ShOpcVal, ShImmVal),
                                  MVT::i32);
  return true;
}

/// getAL - Returns a ARMCC::AL immediate node.
static inline SDValue getAL(SelectionDAG *CurDAG) {
  return CurDAG->getTargetConstant((uint64_t)ARMCC::AL, MVT::i32);
}


SDNode *ARMDAGToDAGISel::Select(SDValue Op) {
  SDNode *N = Op.getNode();
  DebugLoc dl = N->getDebugLoc();

  if (N->isMachineOpcode())
    return NULL;   // Already selected.

  switch (N->getOpcode()) {
  default: break;
  case ISD::Constant: {
    unsigned Val = cast<ConstantSDNode>(N)->getZExtValue();
    bool UseCP = true;
    if (Subtarget->isThumb()) {
      if (Subtarget->hasThumb2())
        // Thumb2 has the MOVT instruction, so all immediates can
        // be done with MOV + MOVT, at worst.
        UseCP = 0;
      else
        UseCP = (Val > 255 &&                          // MOV
                 ~Val > 255 &&                         // MOV + MVN
                 !ARM_AM::isThumbImmShiftedVal(Val));  // MOV + LSL
    } else
      UseCP = (ARM_AM::getSOImmVal(Val) == -1 &&     // MOV
               ARM_AM::getSOImmVal(~Val) == -1 &&    // MVN
               !ARM_AM::isSOImmTwoPartVal(Val));     // two instrs.
    if (UseCP) {
      SDValue CPIdx =
        CurDAG->getTargetConstantPool(ConstantInt::get(Type::Int32Ty, Val),
                                      TLI.getPointerTy());

      SDNode *ResNode;
      if (Subtarget->isThumb())
        ResNode = CurDAG->getTargetNode(ARM::tLDRcp, dl, MVT::i32, MVT::Other,
                                        CPIdx, CurDAG->getEntryNode());
      else {
        SDValue Ops[] = {
          CPIdx, 
          CurDAG->getRegister(0, MVT::i32),
          CurDAG->getTargetConstant(0, MVT::i32),
          getAL(CurDAG),
          CurDAG->getRegister(0, MVT::i32),
          CurDAG->getEntryNode()
        };
        ResNode=CurDAG->getTargetNode(ARM::LDRcp, dl, MVT::i32, MVT::Other,
                                      Ops, 6);
      }
      ReplaceUses(Op, SDValue(ResNode, 0));
      return NULL;
    }
      
    // Other cases are autogenerated.
    break;
  }
  case ISD::FrameIndex: {
    // Selects to ADDri FI, 0 which in turn will become ADDri SP, imm.
    int FI = cast<FrameIndexSDNode>(N)->getIndex();
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    if (Subtarget->isThumb()) {
      return CurDAG->SelectNodeTo(N, ARM::tADDrSPi, MVT::i32, TFI,
                                  CurDAG->getTargetConstant(0, MVT::i32));
    } else {
      SDValue Ops[] = { TFI, CurDAG->getTargetConstant(0, MVT::i32),
                          getAL(CurDAG), CurDAG->getRegister(0, MVT::i32),
                          CurDAG->getRegister(0, MVT::i32) };
      return CurDAG->SelectNodeTo(N, ARM::ADDri, MVT::i32, Ops, 5);
    }
  }
  case ISD::ADD: {
    if (!Subtarget->isThumb())
      break;
    // Select add sp, c to tADDhirr.
    SDValue N0 = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    RegisterSDNode *LHSR = dyn_cast<RegisterSDNode>(Op.getOperand(0));
    RegisterSDNode *RHSR = dyn_cast<RegisterSDNode>(Op.getOperand(1));
    if (LHSR && LHSR->getReg() == ARM::SP) {
      std::swap(N0, N1);
      std::swap(LHSR, RHSR);
    }
    if (RHSR && RHSR->getReg() == ARM::SP) {
      SDValue Val = SDValue(CurDAG->getTargetNode(ARM::tMOVlor2hir, dl,
                                  Op.getValueType(), N0, N0), 0);
      return CurDAG->SelectNodeTo(N, ARM::tADDhirr, Op.getValueType(), Val, N1);
    }
    break;
  }
  case ISD::MUL:
    if (Subtarget->isThumb())
      break;
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op.getOperand(1))) {
      unsigned RHSV = C->getZExtValue();
      if (!RHSV) break;
      if (isPowerOf2_32(RHSV-1)) {  // 2^n+1?
        SDValue V = Op.getOperand(0);
        unsigned ShImm = ARM_AM::getSORegOpc(ARM_AM::lsl, Log2_32(RHSV-1));
        SDValue Ops[] = { V, V, CurDAG->getRegister(0, MVT::i32),
                            CurDAG->getTargetConstant(ShImm, MVT::i32),
                            getAL(CurDAG), CurDAG->getRegister(0, MVT::i32),
                            CurDAG->getRegister(0, MVT::i32) };
        return CurDAG->SelectNodeTo(N, ARM::ADDrs, MVT::i32, Ops, 7);
      }
      if (isPowerOf2_32(RHSV+1)) {  // 2^n-1?
        SDValue V = Op.getOperand(0);
        unsigned ShImm = ARM_AM::getSORegOpc(ARM_AM::lsl, Log2_32(RHSV+1));
        SDValue Ops[] = { V, V, CurDAG->getRegister(0, MVT::i32),
                            CurDAG->getTargetConstant(ShImm, MVT::i32),
                            getAL(CurDAG), CurDAG->getRegister(0, MVT::i32),
                            CurDAG->getRegister(0, MVT::i32) };
        return CurDAG->SelectNodeTo(N, ARM::RSBrs, MVT::i32, Ops, 7);
      }
    }
    break;
  case ARMISD::FMRRD:
    return CurDAG->getTargetNode(ARM::FMRRD, dl, MVT::i32, MVT::i32,
                                 Op.getOperand(0), getAL(CurDAG),
                                 CurDAG->getRegister(0, MVT::i32));
  case ISD::UMUL_LOHI: {
    SDValue Ops[] = { Op.getOperand(0), Op.getOperand(1),
                        getAL(CurDAG), CurDAG->getRegister(0, MVT::i32),
                        CurDAG->getRegister(0, MVT::i32) };
    return CurDAG->getTargetNode(ARM::UMULL, dl, MVT::i32, MVT::i32, Ops, 5);
  }
  case ISD::SMUL_LOHI: {
    SDValue Ops[] = { Op.getOperand(0), Op.getOperand(1),
                        getAL(CurDAG), CurDAG->getRegister(0, MVT::i32),
                        CurDAG->getRegister(0, MVT::i32) };
    return CurDAG->getTargetNode(ARM::SMULL, dl, MVT::i32, MVT::i32, Ops, 5);
  }
  case ISD::LOAD: {
    LoadSDNode *LD = cast<LoadSDNode>(Op);
    ISD::MemIndexedMode AM = LD->getAddressingMode();
    MVT LoadedVT = LD->getMemoryVT();
    if (AM != ISD::UNINDEXED) {
      SDValue Offset, AMOpc;
      bool isPre = (AM == ISD::PRE_INC) || (AM == ISD::PRE_DEC);
      unsigned Opcode = 0;
      bool Match = false;
      if (LoadedVT == MVT::i32 &&
          SelectAddrMode2Offset(Op, LD->getOffset(), Offset, AMOpc)) {
        Opcode = isPre ? ARM::LDR_PRE : ARM::LDR_POST;
        Match = true;
      } else if (LoadedVT == MVT::i16 &&
                 SelectAddrMode3Offset(Op, LD->getOffset(), Offset, AMOpc)) {
        Match = true;
        Opcode = (LD->getExtensionType() == ISD::SEXTLOAD)
          ? (isPre ? ARM::LDRSH_PRE : ARM::LDRSH_POST)
          : (isPre ? ARM::LDRH_PRE : ARM::LDRH_POST);
      } else if (LoadedVT == MVT::i8 || LoadedVT == MVT::i1) {
        if (LD->getExtensionType() == ISD::SEXTLOAD) {
          if (SelectAddrMode3Offset(Op, LD->getOffset(), Offset, AMOpc)) {
            Match = true;
            Opcode = isPre ? ARM::LDRSB_PRE : ARM::LDRSB_POST;
          }
        } else {
          if (SelectAddrMode2Offset(Op, LD->getOffset(), Offset, AMOpc)) {
            Match = true;
            Opcode = isPre ? ARM::LDRB_PRE : ARM::LDRB_POST;
          }
        }
      }

      if (Match) {
        SDValue Chain = LD->getChain();
        SDValue Base = LD->getBasePtr();
        SDValue Ops[]= { Base, Offset, AMOpc, getAL(CurDAG),
                           CurDAG->getRegister(0, MVT::i32), Chain };
        return CurDAG->getTargetNode(Opcode, dl, MVT::i32, MVT::i32,
                                     MVT::Other, Ops, 6);
      }
    }
    // Other cases are autogenerated.
    break;
  }
  case ARMISD::BRCOND: {
    // Pattern: (ARMbrcond:void (bb:Other):$dst, (imm:i32):$cc)
    // Emits: (Bcc:void (bb:Other):$dst, (imm:i32):$cc)
    // Pattern complexity = 6  cost = 1  size = 0

    // Pattern: (ARMbrcond:void (bb:Other):$dst, (imm:i32):$cc)
    // Emits: (tBcc:void (bb:Other):$dst, (imm:i32):$cc)
    // Pattern complexity = 6  cost = 1  size = 0

    unsigned Opc = Subtarget->isThumb() ? ARM::tBcc : ARM::Bcc;
    SDValue Chain = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    SDValue N2 = Op.getOperand(2);
    SDValue N3 = Op.getOperand(3);
    SDValue InFlag = Op.getOperand(4);
    assert(N1.getOpcode() == ISD::BasicBlock);
    assert(N2.getOpcode() == ISD::Constant);
    assert(N3.getOpcode() == ISD::Register);

    SDValue Tmp2 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N2)->getZExtValue()),
                               MVT::i32);
    SDValue Ops[] = { N1, Tmp2, N3, Chain, InFlag };
    SDNode *ResNode = CurDAG->getTargetNode(Opc, dl, MVT::Other, 
                                            MVT::Flag, Ops, 5);
    Chain = SDValue(ResNode, 0);
    if (Op.getNode()->getNumValues() == 2) {
      InFlag = SDValue(ResNode, 1);
      ReplaceUses(SDValue(Op.getNode(), 1), InFlag);
    }
    ReplaceUses(SDValue(Op.getNode(), 0), SDValue(Chain.getNode(), Chain.getResNo()));
    return NULL;
  }
  case ARMISD::CMOV: {
    bool isThumb = Subtarget->isThumb();
    MVT VT = Op.getValueType();
    SDValue N0 = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    SDValue N2 = Op.getOperand(2);
    SDValue N3 = Op.getOperand(3);
    SDValue InFlag = Op.getOperand(4);
    assert(N2.getOpcode() == ISD::Constant);
    assert(N3.getOpcode() == ISD::Register);

    // Pattern: (ARMcmov:i32 GPR:i32:$false, so_reg:i32:$true, (imm:i32):$cc)
    // Emits: (MOVCCs:i32 GPR:i32:$false, so_reg:i32:$true, (imm:i32):$cc)
    // Pattern complexity = 18  cost = 1  size = 0
    SDValue CPTmp0;
    SDValue CPTmp1;
    SDValue CPTmp2;
    if (!isThumb && VT == MVT::i32 &&
        SelectShifterOperandReg(Op, N1, CPTmp0, CPTmp1, CPTmp2)) {
      SDValue Tmp2 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N2)->getZExtValue()),
                               MVT::i32);
      SDValue Ops[] = { N0, CPTmp0, CPTmp1, CPTmp2, Tmp2, N3, InFlag };
      return CurDAG->SelectNodeTo(Op.getNode(), ARM::MOVCCs, MVT::i32, Ops, 7);
    }

    // Pattern: (ARMcmov:i32 GPR:i32:$false,
    //             (imm:i32)<<P:Predicate_so_imm>><<X:so_imm_XFORM>>:$true,
    //             (imm:i32):$cc)
    // Emits: (MOVCCi:i32 GPR:i32:$false,
    //           (so_imm_XFORM:i32 (imm:i32):$true), (imm:i32):$cc)
    // Pattern complexity = 10  cost = 1  size = 0
    if (VT == MVT::i32 &&
        N3.getOpcode() == ISD::Constant &&
        Predicate_so_imm(N3.getNode())) {
      SDValue Tmp1 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N1)->getZExtValue()),
                               MVT::i32);
      Tmp1 = Transform_so_imm_XFORM(Tmp1.getNode());
      SDValue Tmp2 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N2)->getZExtValue()),
                               MVT::i32);
      SDValue Ops[] = { N0, Tmp1, Tmp2, N3, InFlag };
      return CurDAG->SelectNodeTo(Op.getNode(), ARM::MOVCCi, MVT::i32, Ops, 5);
    }

    // Pattern: (ARMcmov:i32 GPR:i32:$false, GPR:i32:$true, (imm:i32):$cc)
    // Emits: (MOVCCr:i32 GPR:i32:$false, GPR:i32:$true, (imm:i32):$cc)
    // Pattern complexity = 6  cost = 1  size = 0
    //
    // Pattern: (ARMcmov:i32 GPR:i32:$false, GPR:i32:$true, (imm:i32):$cc)
    // Emits: (tMOVCCr:i32 GPR:i32:$false, GPR:i32:$true, (imm:i32):$cc)
    // Pattern complexity = 6  cost = 11  size = 0
    //
    // Also FCPYScc and FCPYDcc.
    SDValue Tmp2 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N2)->getZExtValue()),
                               MVT::i32);
    SDValue Ops[] = { N0, N1, Tmp2, N3, InFlag };
    unsigned Opc = 0;
    switch (VT.getSimpleVT()) {
    default: assert(false && "Illegal conditional move type!");
      break;
    case MVT::i32:
      Opc = isThumb ? ARM::tMOVCCr : ARM::MOVCCr;
      break;
    case MVT::f32:
      Opc = ARM::FCPYScc;
      break;
    case MVT::f64:
      Opc = ARM::FCPYDcc;
      break; 
    }
    return CurDAG->SelectNodeTo(Op.getNode(), Opc, VT, Ops, 5);
  }
  case ARMISD::CNEG: {
    MVT VT = Op.getValueType();
    SDValue N0 = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    SDValue N2 = Op.getOperand(2);
    SDValue N3 = Op.getOperand(3);
    SDValue InFlag = Op.getOperand(4);
    assert(N2.getOpcode() == ISD::Constant);
    assert(N3.getOpcode() == ISD::Register);

    SDValue Tmp2 = CurDAG->getTargetConstant(((unsigned)
                               cast<ConstantSDNode>(N2)->getZExtValue()),
                               MVT::i32);
    SDValue Ops[] = { N0, N1, Tmp2, N3, InFlag };
    unsigned Opc = 0;
    switch (VT.getSimpleVT()) {
    default: assert(false && "Illegal conditional move type!");
      break;
    case MVT::f32:
      Opc = ARM::FNEGScc;
      break;
    case MVT::f64:
      Opc = ARM::FNEGDcc;
      break;
    }
    return CurDAG->SelectNodeTo(Op.getNode(), Opc, VT, Ops, 5);
  }

  case ISD::DECLARE: {
    SDValue Chain = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    SDValue N2 = Op.getOperand(2);
    FrameIndexSDNode *FINode = dyn_cast<FrameIndexSDNode>(N1);
    // FIXME: handle VLAs.
    if (!FINode) {
      ReplaceUses(Op.getValue(0), Chain);
      return NULL;
    }
    if (N2.getOpcode() == ARMISD::PIC_ADD && isa<LoadSDNode>(N2.getOperand(0)))
      N2 = N2.getOperand(0);
    LoadSDNode *Ld = dyn_cast<LoadSDNode>(N2);
    if (!Ld) {
      ReplaceUses(Op.getValue(0), Chain);
      return NULL;
    }
    SDValue BasePtr = Ld->getBasePtr();
    assert(BasePtr.getOpcode() == ARMISD::Wrapper &&
           isa<ConstantPoolSDNode>(BasePtr.getOperand(0)) &&
           "llvm.dbg.variable should be a constantpool node");
    ConstantPoolSDNode *CP = cast<ConstantPoolSDNode>(BasePtr.getOperand(0));
    GlobalValue *GV = 0;
    if (CP->isMachineConstantPoolEntry()) {
      ARMConstantPoolValue *ACPV = (ARMConstantPoolValue*)CP->getMachineCPVal();
      GV = ACPV->getGV();
    } else
      GV = dyn_cast<GlobalValue>(CP->getConstVal());
    if (!GV) {
      ReplaceUses(Op.getValue(0), Chain);
      return NULL;
    }
    
    SDValue Tmp1 = CurDAG->getTargetFrameIndex(FINode->getIndex(),
                                               TLI.getPointerTy());
    SDValue Tmp2 = CurDAG->getTargetGlobalAddress(GV, TLI.getPointerTy());
    SDValue Ops[] = { Tmp1, Tmp2, Chain };
    return CurDAG->getTargetNode(TargetInstrInfo::DECLARE, dl,
                                 MVT::Other, Ops, 3);
  }

  case ISD::CONCAT_VECTORS: {
    MVT VT = Op.getValueType();
    assert(VT.is128BitVector() && Op.getNumOperands() == 2 &&
           "unexpected CONCAT_VECTORS");
    SDValue N0 = Op.getOperand(0);
    SDValue N1 = Op.getOperand(1);
    SDNode *Result =
      CurDAG->getTargetNode(TargetInstrInfo::IMPLICIT_DEF, dl, VT);
    if (N0.getOpcode() != ISD::UNDEF)
      Result = CurDAG->getTargetNode(TargetInstrInfo::INSERT_SUBREG, dl, VT,
                                     SDValue(Result, 0), N0,
                                     CurDAG->getTargetConstant(arm_dsubreg_0,
                                                               MVT::i32));
    if (N1.getOpcode() != ISD::UNDEF)
      Result = CurDAG->getTargetNode(TargetInstrInfo::INSERT_SUBREG, dl, VT,
                                     SDValue(Result, 0), N1,
                                     CurDAG->getTargetConstant(arm_dsubreg_1,
                                                               MVT::i32));
    return Result;
  }

  case ISD::VECTOR_SHUFFLE: {
    MVT VT = Op.getValueType();

    // Match 128-bit splat to VDUPLANEQ.  (This could be done with a Pat in
    // ARMInstrNEON.td but it is awkward because the shuffle mask needs to be
    // transformed first into a lane number and then to both a subregister
    // index and an adjusted lane number.)  If the source operand is a
    // SCALAR_TO_VECTOR, leave it so it will be matched later as a VDUP.
    ShuffleVectorSDNode *SVOp = cast<ShuffleVectorSDNode>(N);
    if (VT.is128BitVector() && SVOp->isSplat() &&
        Op.getOperand(0).getOpcode() != ISD::SCALAR_TO_VECTOR &&
        Op.getOperand(1).getOpcode() == ISD::UNDEF) {
      unsigned LaneVal = SVOp->getSplatIndex();

      MVT HalfVT;
      unsigned Opc = 0;
      switch (VT.getVectorElementType().getSimpleVT()) {
      default: assert(false && "unhandled VDUP splat type");
      case MVT::i8:  Opc = ARM::VDUPLN8q;  HalfVT = MVT::v8i8; break;
      case MVT::i16: Opc = ARM::VDUPLN16q; HalfVT = MVT::v4i16; break;
      case MVT::i32: Opc = ARM::VDUPLN32q; HalfVT = MVT::v2i32; break;
      case MVT::f32: Opc = ARM::VDUPLNfq;  HalfVT = MVT::v2f32; break;
      }

      // The source operand needs to be changed to a subreg of the original
      // 128-bit operand, and the lane number needs to be adjusted accordingly.
      unsigned NumElts = VT.getVectorNumElements() / 2;
      unsigned SRVal = (LaneVal < NumElts ? arm_dsubreg_0 : arm_dsubreg_1);
      SDValue SR = CurDAG->getTargetConstant(SRVal, MVT::i32);
      SDValue NewLane = CurDAG->getTargetConstant(LaneVal % NumElts, MVT::i32);
      SDNode *SubReg = CurDAG->getTargetNode(TargetInstrInfo::EXTRACT_SUBREG,
                                             dl, HalfVT, N->getOperand(0), SR);
      return CurDAG->SelectNodeTo(N, Opc, VT, SDValue(SubReg, 0), NewLane);
    }

    break;
  }
  }

  return SelectCode(Op);
}

bool ARMDAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op, char ConstraintCode,
                             std::vector<SDValue> &OutOps) {
  assert(ConstraintCode == 'm' && "unexpected asm memory constraint");

  SDValue Base, Offset, Opc;
  if (!SelectAddrMode2(Op, Op, Base, Offset, Opc))
    return true;
  
  OutOps.push_back(Base);
  OutOps.push_back(Offset);
  OutOps.push_back(Opc);
  return false;
}

/// createARMISelDag - This pass converts a legalized DAG into a
/// ARM-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createARMISelDag(ARMTargetMachine &TM) {
  return new ARMDAGToDAGISel(TM);
}
