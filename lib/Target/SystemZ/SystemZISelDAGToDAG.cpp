//==-- SystemZISelDAGToDAG.cpp - A dag to dag inst selector for SystemZ ---===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the SystemZ target.
//
//===----------------------------------------------------------------------===//

#include "SystemZ.h"
#include "SystemZISelLowering.h"
#include "SystemZTargetMachine.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Function.h"
#include "llvm/Intrinsics.h"
#include "llvm/CallingConv.h"
#include "llvm/Constants.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

static const unsigned subreg_32bit = 1;
static const unsigned subreg_even = 1;
static const unsigned subreg_odd = 2;

namespace {
  /// SystemZRRIAddressMode - This corresponds to rriaddr, but uses SDValue's
  /// instead of register numbers for the leaves of the matched tree.
  struct SystemZRRIAddressMode {
    enum {
      RegBase,
      FrameIndexBase
    } BaseType;

    struct {            // This is really a union, discriminated by BaseType!
      SDValue Reg;
      int FrameIndex;
    } Base;

    SDValue IndexReg;
    int64_t Disp;
    bool isRI;

    SystemZRRIAddressMode(bool RI = false)
      : BaseType(RegBase), IndexReg(), Disp(0), isRI(RI) {
    }

    void dump() {
      cerr << "SystemZRRIAddressMode " << this << '\n';
      if (BaseType == RegBase) {
        cerr << "Base.Reg ";
        if (Base.Reg.getNode() != 0) Base.Reg.getNode()->dump();
        else cerr << "nul";
        cerr << '\n';
      } else {
        cerr << " Base.FrameIndex " << Base.FrameIndex << '\n';
      }
      if (!isRI) {
        cerr << "IndexReg ";
        if (IndexReg.getNode() != 0) IndexReg.getNode()->dump();
        else cerr << "nul";
      }
      cerr << " Disp " << Disp << '\n';
    }
  };
}

/// SystemZDAGToDAGISel - SystemZ specific code to select SystemZ machine
/// instructions for SelectionDAG operations.
///
namespace {
  class SystemZDAGToDAGISel : public SelectionDAGISel {
    SystemZTargetLowering &Lowering;
    const SystemZSubtarget &Subtarget;

    void getAddressOperandsRI(const SystemZRRIAddressMode &AM,
                            SDValue &Base, SDValue &Disp);
    void getAddressOperands(const SystemZRRIAddressMode &AM,
                            SDValue &Base, SDValue &Disp,
                            SDValue &Index);

  public:
    SystemZDAGToDAGISel(SystemZTargetMachine &TM, CodeGenOpt::Level OptLevel)
      : SelectionDAGISel(TM, OptLevel),
        Lowering(*TM.getTargetLowering()),
        Subtarget(*TM.getSubtargetImpl()) { }

    virtual void InstructionSelect();

    virtual const char *getPassName() const {
      return "SystemZ DAG->DAG Pattern Instruction Selection";
    }

    /// getI16Imm - Return a target constant with the specified value, of type
    /// i16.
    inline SDValue getI16Imm(uint64_t Imm) {
      return CurDAG->getTargetConstant(Imm, MVT::i16);
    }

    /// getI32Imm - Return a target constant with the specified value, of type
    /// i32.
    inline SDValue getI32Imm(uint64_t Imm) {
      return CurDAG->getTargetConstant(Imm, MVT::i32);
    }

    // Include the pieces autogenerated from the target description.
    #include "SystemZGenDAGISel.inc"

  private:
    bool SelectAddrRI12Only(SDValue Op, SDValue& Addr,
                            SDValue &Base, SDValue &Disp);
    bool SelectAddrRI12(SDValue Op, SDValue& Addr,
                        SDValue &Base, SDValue &Disp,
                        bool is12BitOnly = false);
    bool SelectAddrRI(SDValue Op, SDValue& Addr,
                      SDValue &Base, SDValue &Disp);
    bool SelectAddrRRI12(SDValue Op, SDValue Addr,
                         SDValue &Base, SDValue &Disp, SDValue &Index);
    bool SelectAddrRRI20(SDValue Op, SDValue Addr,
                         SDValue &Base, SDValue &Disp, SDValue &Index);
    bool SelectLAAddr(SDValue Op, SDValue Addr,
                      SDValue &Base, SDValue &Disp, SDValue &Index);

    SDNode *Select(SDValue Op);

    bool TryFoldLoad(SDValue P, SDValue N,
                     SDValue &Base, SDValue &Disp, SDValue &Index);

    bool MatchAddress(SDValue N, SystemZRRIAddressMode &AM,
                      bool is12Bit, unsigned Depth = 0);
    bool MatchAddressBase(SDValue N, SystemZRRIAddressMode &AM);
    bool MatchAddressRI(SDValue N, SystemZRRIAddressMode &AM,
                        bool is12Bit);

  #ifndef NDEBUG
    unsigned Indent;
  #endif
  };
}  // end anonymous namespace

/// createSystemZISelDag - This pass converts a legalized DAG into a
/// SystemZ-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createSystemZISelDag(SystemZTargetMachine &TM,
                                        CodeGenOpt::Level OptLevel) {
  return new SystemZDAGToDAGISel(TM, OptLevel);
}

/// isImmSExt20 - This method tests to see if the node is either a 32-bit
/// or 64-bit immediate, and if the value can be accurately represented as a
/// sign extension from a 20-bit value. If so, this returns true and the
/// immediate.
static bool isImmSExt20(int64_t Val, int64_t &Imm) {
  if (Val >= -524288 && Val <= 524287) {
    Imm = Val;
    return true;
  }
  return false;
}

/// isImmZExt12 - This method tests to see if the node is either a 32-bit
/// or 64-bit immediate, and if the value can be accurately represented as a
/// zero extension from a 12-bit value. If so, this returns true and the
/// immediate.
static bool isImmZExt12(int64_t Val, int64_t &Imm) {
  if (Val >= 0 && Val <= 0xFFF) {
    Imm = Val;
    return true;
  }
  return false;
}

/// MatchAddress - Add the specified node to the specified addressing mode,
/// returning true if it cannot be done.  This just pattern matches for the
/// addressing mode.
bool SystemZDAGToDAGISel::MatchAddress(SDValue N, SystemZRRIAddressMode &AM,
                                       bool is12Bit, unsigned Depth) {
  DebugLoc dl = N.getDebugLoc();
  DOUT << "MatchAddress: "; DEBUG(AM.dump());
  // Limit recursion.
  if (Depth > 5)
    return MatchAddressBase(N, AM);

  // FIXME: We can perform better here. If we have something like
  // (shift (add A, imm), N), we can try to reassociate stuff and fold shift of
  // imm into addressing mode.
  switch (N.getOpcode()) {
  default: break;
  case ISD::Constant: {
    int64_t Val = cast<ConstantSDNode>(N)->getSExtValue();
    int64_t Imm;
    bool Match = (is12Bit ?
                  isImmZExt12(AM.Disp + Val, Imm) :
                  isImmSExt20(AM.Disp + Val, Imm));
    if (Match) {
      AM.Disp = Imm;
      return false;
    }
    break;
  }

  case ISD::FrameIndex:
    if (AM.BaseType == SystemZRRIAddressMode::RegBase &&
        AM.Base.Reg.getNode() == 0) {
      AM.BaseType = SystemZRRIAddressMode::FrameIndexBase;
      AM.Base.FrameIndex = cast<FrameIndexSDNode>(N)->getIndex();
      return false;
    }
    break;

  case ISD::SUB: {
    // Given A-B, if A can be completely folded into the address and
    // the index field with the index field unused, use -B as the index.
    // This is a win if a has multiple parts that can be folded into
    // the address. Also, this saves a mov if the base register has
    // other uses, since it avoids a two-address sub instruction, however
    // it costs an additional mov if the index register has other uses.

    // Test if the LHS of the sub can be folded.
    SystemZRRIAddressMode Backup = AM;
    if (MatchAddress(N.getNode()->getOperand(0), AM, is12Bit, Depth+1)) {
      AM = Backup;
      break;
    }
    // Test if the index field is free for use.
    if (AM.IndexReg.getNode() && !AM.isRI) {
      AM = Backup;
      break;
    }

    // If the base is a register with multiple uses, this transformation may
    // save a mov. Otherwise it's probably better not to do it.
    if (AM.BaseType == SystemZRRIAddressMode::RegBase &&
        (!AM.Base.Reg.getNode() || AM.Base.Reg.getNode()->hasOneUse())) {
      AM = Backup;
      break;
    }

    // Ok, the transformation is legal and appears profitable. Go for it.
    SDValue RHS = N.getNode()->getOperand(1);
    SDValue Zero = CurDAG->getConstant(0, N.getValueType());
    SDValue Neg = CurDAG->getNode(ISD::SUB, dl, N.getValueType(), Zero, RHS);
    AM.IndexReg = Neg;

    // Insert the new nodes into the topological ordering.
    if (Zero.getNode()->getNodeId() == -1 ||
        Zero.getNode()->getNodeId() > N.getNode()->getNodeId()) {
      CurDAG->RepositionNode(N.getNode(), Zero.getNode());
      Zero.getNode()->setNodeId(N.getNode()->getNodeId());
    }
    if (Neg.getNode()->getNodeId() == -1 ||
        Neg.getNode()->getNodeId() > N.getNode()->getNodeId()) {
      CurDAG->RepositionNode(N.getNode(), Neg.getNode());
      Neg.getNode()->setNodeId(N.getNode()->getNodeId());
    }
    return false;
  }

  case ISD::ADD: {
    SystemZRRIAddressMode Backup = AM;
    if (!MatchAddress(N.getNode()->getOperand(0), AM, is12Bit, Depth+1) &&
        !MatchAddress(N.getNode()->getOperand(1), AM, is12Bit, Depth+1))
      return false;
    AM = Backup;
    if (!MatchAddress(N.getNode()->getOperand(1), AM, is12Bit, Depth+1) &&
        !MatchAddress(N.getNode()->getOperand(0), AM, is12Bit, Depth+1))
      return false;
    AM = Backup;

    // If we couldn't fold both operands into the address at the same time,
    // see if we can just put each operand into a register and fold at least
    // the add.
    if (!AM.isRI &&
        AM.BaseType == SystemZRRIAddressMode::RegBase &&
        !AM.Base.Reg.getNode() && !AM.IndexReg.getNode()) {
      AM.Base.Reg = N.getNode()->getOperand(0);
      AM.IndexReg = N.getNode()->getOperand(1);
      return false;
    }
    break;
  }

  case ISD::OR:
    // Handle "X | C" as "X + C" iff X is known to have C bits clear.
    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      SystemZRRIAddressMode Backup = AM;
      int64_t Offset = CN->getSExtValue();
      int64_t Imm;
      bool MatchOffset = (is12Bit ?
                          isImmZExt12(AM.Disp + Offset, Imm) :
                          isImmSExt20(AM.Disp + Offset, Imm));
      // The resultant disp must fit in 12 or 20-bits.
      if (MatchOffset &&
          // LHS should be an addr mode.
          !MatchAddress(N.getOperand(0), AM, is12Bit, Depth+1) &&
          // Check to see if the LHS & C is zero.
          CurDAG->MaskedValueIsZero(N.getOperand(0), CN->getAPIntValue())) {
        AM.Disp = Imm;
        return false;
      }
      AM = Backup;
    }
    break;
  }

  return MatchAddressBase(N, AM);
}

/// MatchAddressBase - Helper for MatchAddress. Add the specified node to the
/// specified addressing mode without any further recursion.
bool SystemZDAGToDAGISel::MatchAddressBase(SDValue N,
                                           SystemZRRIAddressMode &AM) {
  // Is the base register already occupied?
  if (AM.BaseType != SystemZRRIAddressMode::RegBase || AM.Base.Reg.getNode()) {
    // If so, check to see if the index register is set.
    if (AM.IndexReg.getNode() == 0 && !AM.isRI) {
      AM.IndexReg = N;
      return false;
    }

    // Otherwise, we cannot select it.
    return true;
  }

  // Default, generate it as a register.
  AM.BaseType = SystemZRRIAddressMode::RegBase;
  AM.Base.Reg = N;
  return false;
}

void SystemZDAGToDAGISel::getAddressOperandsRI(const SystemZRRIAddressMode &AM,
                                               SDValue &Base, SDValue &Disp) {
  if (AM.BaseType == SystemZRRIAddressMode::RegBase)
    Base = AM.Base.Reg;
  else
    Base = CurDAG->getTargetFrameIndex(AM.Base.FrameIndex, TLI.getPointerTy());
  Disp = CurDAG->getTargetConstant(AM.Disp, MVT::i64);
}

void SystemZDAGToDAGISel::getAddressOperands(const SystemZRRIAddressMode &AM,
                                             SDValue &Base, SDValue &Disp,
                                             SDValue &Index) {
  getAddressOperandsRI(AM, Base, Disp);
  Index = AM.IndexReg;
}

/// Returns true if the address can be represented by a base register plus
/// an unsigned 12-bit displacement [r+imm].
bool SystemZDAGToDAGISel::SelectAddrRI12Only(SDValue Op, SDValue& Addr,
                                             SDValue &Base, SDValue &Disp) {
  return SelectAddrRI12(Op, Addr, Base, Disp, /*is12BitOnly*/true);
}

bool SystemZDAGToDAGISel::SelectAddrRI12(SDValue Op, SDValue& Addr,
                                         SDValue &Base, SDValue &Disp,
                                         bool is12BitOnly) {
  SystemZRRIAddressMode AM20(/*isRI*/true), AM12(/*isRI*/true);
  bool Done = false;

  if (!Addr.hasOneUse()) {
    unsigned Opcode = Addr.getOpcode();
    if (Opcode != ISD::Constant && Opcode != ISD::FrameIndex) {
      // If we are able to fold N into addressing mode, then we'll allow it even
      // if N has multiple uses. In general, addressing computation is used as
      // addresses by all of its uses. But watch out for CopyToReg uses, that
      // means the address computation is liveout. It will be computed by a LA
      // so we want to avoid computing the address twice.
      for (SDNode::use_iterator UI = Addr.getNode()->use_begin(),
             UE = Addr.getNode()->use_end(); UI != UE; ++UI) {
        if (UI->getOpcode() == ISD::CopyToReg) {
          MatchAddressBase(Addr, AM12);
          Done = true;
          break;
        }
      }
    }
  }
  if (!Done && MatchAddress(Addr, AM12, /* is12Bit */ true))
    return false;

  // Check, whether we can match stuff using 20-bit displacements
  if (!Done && !is12BitOnly &&
      !MatchAddress(Addr, AM20, /* is12Bit */ false))
    if (AM12.Disp == 0 && AM20.Disp != 0)
      return false;

  DOUT << "MatchAddress (final): "; DEBUG(AM12.dump());

  MVT VT = Addr.getValueType();
  if (AM12.BaseType == SystemZRRIAddressMode::RegBase) {
    if (!AM12.Base.Reg.getNode())
      AM12.Base.Reg = CurDAG->getRegister(0, VT);
  }

  assert(AM12.IndexReg.getNode() == 0 && "Invalid reg-imm address mode!");

  getAddressOperandsRI(AM12, Base, Disp);

  return true;
}

/// Returns true if the address can be represented by a base register plus
/// a signed 20-bit displacement [r+imm].
bool SystemZDAGToDAGISel::SelectAddrRI(SDValue Op, SDValue& Addr,
                                       SDValue &Base, SDValue &Disp) {
  SystemZRRIAddressMode AM(/*isRI*/true);
  bool Done = false;

  if (!Addr.hasOneUse()) {
    unsigned Opcode = Addr.getOpcode();
    if (Opcode != ISD::Constant && Opcode != ISD::FrameIndex) {
      // If we are able to fold N into addressing mode, then we'll allow it even
      // if N has multiple uses. In general, addressing computation is used as
      // addresses by all of its uses. But watch out for CopyToReg uses, that
      // means the address computation is liveout. It will be computed by a LA
      // so we want to avoid computing the address twice.
      for (SDNode::use_iterator UI = Addr.getNode()->use_begin(),
             UE = Addr.getNode()->use_end(); UI != UE; ++UI) {
        if (UI->getOpcode() == ISD::CopyToReg) {
          MatchAddressBase(Addr, AM);
          Done = true;
          break;
        }
      }
    }
  }
  if (!Done && MatchAddress(Addr, AM, /* is12Bit */ false))
    return false;

  DOUT << "MatchAddress (final): "; DEBUG(AM.dump());

  MVT VT = Addr.getValueType();
  if (AM.BaseType == SystemZRRIAddressMode::RegBase) {
    if (!AM.Base.Reg.getNode())
      AM.Base.Reg = CurDAG->getRegister(0, VT);
  }

  assert(AM.IndexReg.getNode() == 0 && "Invalid reg-imm address mode!");

  getAddressOperandsRI(AM, Base, Disp);

  return true;
}

/// Returns true if the address can be represented by a base register plus
/// index register plus an unsigned 12-bit displacement [base + idx + imm].
bool SystemZDAGToDAGISel::SelectAddrRRI12(SDValue Op, SDValue Addr,
                                SDValue &Base, SDValue &Disp, SDValue &Index) {
  SystemZRRIAddressMode AM20, AM12;
  bool Done = false;

  if (!Addr.hasOneUse()) {
    unsigned Opcode = Addr.getOpcode();
    if (Opcode != ISD::Constant && Opcode != ISD::FrameIndex) {
      // If we are able to fold N into addressing mode, then we'll allow it even
      // if N has multiple uses. In general, addressing computation is used as
      // addresses by all of its uses. But watch out for CopyToReg uses, that
      // means the address computation is liveout. It will be computed by a LA
      // so we want to avoid computing the address twice.
      for (SDNode::use_iterator UI = Addr.getNode()->use_begin(),
             UE = Addr.getNode()->use_end(); UI != UE; ++UI) {
        if (UI->getOpcode() == ISD::CopyToReg) {
          MatchAddressBase(Addr, AM12);
          Done = true;
          break;
        }
      }
    }
  }
  if (!Done && MatchAddress(Addr, AM12, /* is12Bit */ true))
    return false;

  // Check, whether we can match stuff using 20-bit displacements
  if (!Done && !MatchAddress(Addr, AM20, /* is12Bit */ false))
    if (AM12.Disp == 0 && AM20.Disp != 0)
      return false;

  DOUT << "MatchAddress (final): "; DEBUG(AM12.dump());

  MVT VT = Addr.getValueType();
  if (AM12.BaseType == SystemZRRIAddressMode::RegBase) {
    if (!AM12.Base.Reg.getNode())
      AM12.Base.Reg = CurDAG->getRegister(0, VT);
  }

  if (!AM12.IndexReg.getNode())
    AM12.IndexReg = CurDAG->getRegister(0, VT);

  getAddressOperands(AM12, Base, Disp, Index);

  return true;
}

/// Returns true if the address can be represented by a base register plus
/// index register plus a signed 20-bit displacement [base + idx + imm].
bool SystemZDAGToDAGISel::SelectAddrRRI20(SDValue Op, SDValue Addr,
                                SDValue &Base, SDValue &Disp, SDValue &Index) {
  SystemZRRIAddressMode AM;
  bool Done = false;

  if (!Addr.hasOneUse()) {
    unsigned Opcode = Addr.getOpcode();
    if (Opcode != ISD::Constant && Opcode != ISD::FrameIndex) {
      // If we are able to fold N into addressing mode, then we'll allow it even
      // if N has multiple uses. In general, addressing computation is used as
      // addresses by all of its uses. But watch out for CopyToReg uses, that
      // means the address computation is liveout. It will be computed by a LA
      // so we want to avoid computing the address twice.
      for (SDNode::use_iterator UI = Addr.getNode()->use_begin(),
             UE = Addr.getNode()->use_end(); UI != UE; ++UI) {
        if (UI->getOpcode() == ISD::CopyToReg) {
          MatchAddressBase(Addr, AM);
          Done = true;
          break;
        }
      }
    }
  }
  if (!Done && MatchAddress(Addr, AM, /* is12Bit */ false))
    return false;

  DOUT << "MatchAddress (final): "; DEBUG(AM.dump());

  MVT VT = Addr.getValueType();
  if (AM.BaseType == SystemZRRIAddressMode::RegBase) {
    if (!AM.Base.Reg.getNode())
      AM.Base.Reg = CurDAG->getRegister(0, VT);
  }

  if (!AM.IndexReg.getNode())
    AM.IndexReg = CurDAG->getRegister(0, VT);

  getAddressOperands(AM, Base, Disp, Index);

  return true;
}

/// SelectLAAddr - it calls SelectAddr and determines if the maximal addressing
/// mode it matches can be cost effectively emitted as an LA/LAY instruction.
bool SystemZDAGToDAGISel::SelectLAAddr(SDValue Op, SDValue Addr,
                                  SDValue &Base, SDValue &Disp, SDValue &Index) {
  SystemZRRIAddressMode AM;

  if (MatchAddress(Addr, AM, false))
    return false;

  MVT VT = Addr.getValueType();
  unsigned Complexity = 0;
  if (AM.BaseType == SystemZRRIAddressMode::RegBase)
    if (AM.Base.Reg.getNode())
      Complexity = 1;
    else
      AM.Base.Reg = CurDAG->getRegister(0, VT);
  else if (AM.BaseType == SystemZRRIAddressMode::FrameIndexBase)
    Complexity = 4;

  if (AM.IndexReg.getNode())
    Complexity += 1;
  else
    AM.IndexReg = CurDAG->getRegister(0, VT);

  if (AM.Disp && (AM.Base.Reg.getNode() || AM.IndexReg.getNode()))
    Complexity += 1;

  if (Complexity > 2) {
    getAddressOperands(AM, Base, Disp, Index);
    return true;
  }

  return false;
}

bool SystemZDAGToDAGISel::TryFoldLoad(SDValue P, SDValue N,
                                 SDValue &Base, SDValue &Disp, SDValue &Index) {
  if (ISD::isNON_EXTLoad(N.getNode()) &&
      N.hasOneUse() &&
      IsLegalAndProfitableToFold(N.getNode(), P.getNode(), P.getNode()))
    return SelectAddrRRI20(P, N.getOperand(1), Base, Disp, Index);
  return false;
}

/// InstructionSelect - This callback is invoked by
/// SelectionDAGISel when it has created a SelectionDAG for us to codegen.
void SystemZDAGToDAGISel::InstructionSelect() {
  DEBUG(BB->dump());

  // Codegen the basic block.
#ifndef NDEBUG
  DOUT << "===== Instruction selection begins:\n";
  Indent = 0;
#endif
  SelectRoot(*CurDAG);
#ifndef NDEBUG
  DOUT << "===== Instruction selection ends:\n";
#endif

  CurDAG->RemoveDeadNodes();
}

SDNode *SystemZDAGToDAGISel::Select(SDValue Op) {
  SDNode *Node = Op.getNode();
  MVT NVT = Node->getValueType(0);
  DebugLoc dl = Op.getDebugLoc();
  unsigned Opcode = Node->getOpcode();

  // Dump information about the Node being selected
  #ifndef NDEBUG
  DOUT << std::string(Indent, ' ') << "Selecting: ";
  DEBUG(Node->dump(CurDAG));
  DOUT << "\n";
  Indent += 2;
  #endif

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    #ifndef NDEBUG
    DOUT << std::string(Indent-2, ' ') << "== ";
    DEBUG(Node->dump(CurDAG));
    DOUT << "\n";
    Indent -= 2;
    #endif
    return NULL; // Already selected.
  }

  switch (Opcode) {
  default: break;
  case ISD::SDIVREM: {
    unsigned Opc, MOpc, ClrOpc = 0;
    SDValue N0 = Node->getOperand(0);
    SDValue N1 = Node->getOperand(1);

    MVT ResVT;
    switch (NVT.getSimpleVT()) {
      default: assert(0 && "Unsupported VT!");
      case MVT::i32:
        Opc = SystemZ::SDIVREM32r; MOpc = SystemZ::SDIVREM32m;
        ClrOpc = SystemZ::MOV64Pr0_even;
        ResVT = MVT::v2i32;
        break;
      case MVT::i64:
        Opc = SystemZ::SDIVREM64r; MOpc = SystemZ::SDIVREM64m;
        ResVT = MVT::v2i64;
        break;
    }

    SDValue Tmp0, Tmp1, Tmp2;
    bool foldedLoad = TryFoldLoad(Op, N1, Tmp0, Tmp1, Tmp2);

    // Prepare the dividend
    SDNode *Dividend = N0.getNode();

    // Insert prepared dividend into suitable 'subreg'
    SDNode *Tmp = CurDAG->getTargetNode(TargetInstrInfo::IMPLICIT_DEF,
                                        dl, ResVT);
    Dividend =
      CurDAG->getTargetNode(TargetInstrInfo::INSERT_SUBREG, dl, ResVT,
                            SDValue(Tmp, 0), SDValue(Dividend, 0),
                            CurDAG->getTargetConstant(subreg_odd, MVT::i32));

    // Zero out even subreg, if needed
    if (ClrOpc)
      Dividend = CurDAG->getTargetNode(ClrOpc, dl, ResVT, SDValue(Dividend, 0));

    SDNode *Result;
    SDValue DivVal = SDValue(Dividend, 0);
    if (foldedLoad) {
      SDValue Ops[] = { DivVal, Tmp0, Tmp1, Tmp2, N1.getOperand(0) };
      Result = CurDAG->getTargetNode(MOpc, dl, ResVT, Ops, array_lengthof(Ops));
      // Update the chain.
      ReplaceUses(N1.getValue(1), SDValue(Result, 0));
    } else {
      Result = CurDAG->getTargetNode(Opc, dl, ResVT, SDValue(Dividend, 0), N1);
    }

    // Copy the division (odd subreg) result, if it is needed.
    if (!Op.getValue(0).use_empty()) {
      SDNode *Div = CurDAG->getTargetNode(TargetInstrInfo::EXTRACT_SUBREG,
                                          dl, NVT,
                                          SDValue(Result, 0),
                                          CurDAG->getTargetConstant(subreg_odd,
                                                                    MVT::i32));
      ReplaceUses(Op.getValue(0), SDValue(Div, 0));
      #ifndef NDEBUG
      DOUT << std::string(Indent-2, ' ') << "=> ";
      DEBUG(Result->dump(CurDAG));
      DOUT << "\n";
      #endif
    }

    // Copy the remainder (even subreg) result, if it is needed.
    if (!Op.getValue(1).use_empty()) {
      SDNode *Rem = CurDAG->getTargetNode(TargetInstrInfo::EXTRACT_SUBREG,
                                          dl, NVT,
                                          SDValue(Result, 0),
                                          CurDAG->getTargetConstant(subreg_even,
                                                                    MVT::i32));
      ReplaceUses(Op.getValue(1), SDValue(Rem, 0));
      #ifndef NDEBUG
      DOUT << std::string(Indent-2, ' ') << "=> ";
      DEBUG(Result->dump(CurDAG));
      DOUT << "\n";
      #endif
    }

#ifndef NDEBUG
    Indent -= 2;
#endif

    return NULL;
  }
  case ISD::UDIVREM: {
    unsigned Opc, MOpc, ClrOpc;
    SDValue N0 = Node->getOperand(0);
    SDValue N1 = Node->getOperand(1);
    MVT ResVT;

    switch (NVT.getSimpleVT()) {
      default: assert(0 && "Unsupported VT!");
      case MVT::i32:
        Opc = SystemZ::UDIVREM32r; MOpc = SystemZ::UDIVREM32m;
        ClrOpc = SystemZ::MOV64Pr0_even;
        ResVT = MVT::v2i32;
        break;
      case MVT::i64:
        Opc = SystemZ::UDIVREM64r; MOpc = SystemZ::UDIVREM64m;
        ClrOpc = SystemZ::MOV128r0_even;
        ResVT = MVT::v2i64;
        break;
    }

    SDValue Tmp0, Tmp1, Tmp2;
    bool foldedLoad = TryFoldLoad(Op, N1, Tmp0, Tmp1, Tmp2);

    // Prepare the dividend
    SDNode *Dividend = N0.getNode();

    // Insert prepared dividend into suitable 'subreg'
    SDNode *Tmp = CurDAG->getTargetNode(TargetInstrInfo::IMPLICIT_DEF,
                                        dl, ResVT);
    Dividend =
      CurDAG->getTargetNode(TargetInstrInfo::INSERT_SUBREG, dl, ResVT,
                            SDValue(Tmp, 0), SDValue(Dividend, 0),
                            CurDAG->getTargetConstant(subreg_odd, MVT::i32));

    // Zero out even subreg
    Dividend = CurDAG->getTargetNode(ClrOpc, dl, ResVT, SDValue(Dividend, 0));

    SDValue DivVal = SDValue(Dividend, 0);
    SDNode *Result;
    if (foldedLoad) {
      SDValue Ops[] = { DivVal, Tmp0, Tmp1, Tmp2, N1.getOperand(0) };
      Result = CurDAG->getTargetNode(MOpc, dl,ResVT,
                                     Ops, array_lengthof(Ops));
      // Update the chain.
      ReplaceUses(N1.getValue(1), SDValue(Result, 0));
    } else {
      Result = CurDAG->getTargetNode(Opc, dl, ResVT, DivVal, N1);
    }

    // Copy the division (odd subreg) result, if it is needed.
    if (!Op.getValue(0).use_empty()) {
      SDNode *Div = CurDAG->getTargetNode(TargetInstrInfo::EXTRACT_SUBREG,
                                          dl, NVT,
                                          SDValue(Result, 0),
                                          CurDAG->getTargetConstant(subreg_odd,
                                                                    MVT::i32));
      ReplaceUses(Op.getValue(0), SDValue(Div, 0));
      #ifndef NDEBUG
      DOUT << std::string(Indent-2, ' ') << "=> ";
      DEBUG(Result->dump(CurDAG));
      DOUT << "\n";
      #endif
    }

    // Copy the remainder (even subreg) result, if it is needed.
    if (!Op.getValue(1).use_empty()) {
      SDNode *Rem = CurDAG->getTargetNode(TargetInstrInfo::EXTRACT_SUBREG,
                                          dl, NVT,
                                          SDValue(Result, 0),
                                          CurDAG->getTargetConstant(subreg_even,
                                                                    MVT::i32));
      ReplaceUses(Op.getValue(1), SDValue(Rem, 0));
      #ifndef NDEBUG
      DOUT << std::string(Indent-2, ' ') << "=> ";
      DEBUG(Result->dump(CurDAG));
      DOUT << "\n";
      #endif
    }

#ifndef NDEBUG
    Indent -= 2;
#endif

    return NULL;
  }
  }

  // Select the default instruction
  SDNode *ResNode = SelectCode(Op);

  #ifndef NDEBUG
  DOUT << std::string(Indent-2, ' ') << "=> ";
  if (ResNode == NULL || ResNode == Op.getNode())
    DEBUG(Op.getNode()->dump(CurDAG));
  else
    DEBUG(ResNode->dump(CurDAG));
  DOUT << "\n";
  Indent -= 2;
  #endif

  return ResNode;
}
