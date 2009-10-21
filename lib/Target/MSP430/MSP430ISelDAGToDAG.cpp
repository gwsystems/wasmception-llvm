//===-- MSP430ISelDAGToDAG.cpp - A dag to dag inst selector for MSP430 ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the MSP430 target.
//
//===----------------------------------------------------------------------===//

#include "MSP430.h"
#include "MSP430ISelLowering.h"
#include "MSP430TargetMachine.h"
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
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/Statistic.h"

using namespace llvm;

#ifndef NDEBUG
static cl::opt<bool>
ViewRMWDAGs("view-msp430-rmw-dags", cl::Hidden,
          cl::desc("Pop up a window to show isel dags after RMW preprocess"));
#else
static const bool ViewRMWDAGs = false;
#endif

STATISTIC(NumLoadMoved, "Number of loads moved below TokenFactor");

/// MSP430DAGToDAGISel - MSP430 specific code to select MSP430 machine
/// instructions for SelectionDAG operations.
///
namespace {
  class MSP430DAGToDAGISel : public SelectionDAGISel {
    MSP430TargetLowering &Lowering;
    const MSP430Subtarget &Subtarget;

  public:
    MSP430DAGToDAGISel(MSP430TargetMachine &TM, CodeGenOpt::Level OptLevel)
      : SelectionDAGISel(TM, OptLevel),
        Lowering(*TM.getTargetLowering()),
        Subtarget(*TM.getSubtargetImpl()) { }

    virtual void InstructionSelect();

    virtual const char *getPassName() const {
      return "MSP430 DAG->DAG Pattern Instruction Selection";
    }

    virtual bool
    SelectInlineAsmMemoryOperand(const SDValue &Op, char ConstraintCode,
                                 std::vector<SDValue> &OutOps);

    // Include the pieces autogenerated from the target description.
  #include "MSP430GenDAGISel.inc"

  private:
    void PreprocessForRMW();
    SDNode *Select(SDValue Op);
    bool SelectAddr(SDValue Op, SDValue Addr, SDValue &Base, SDValue &Disp);

  #ifndef NDEBUG
    unsigned Indent;
  #endif
  };
}  // end anonymous namespace

/// createMSP430ISelDag - This pass converts a legalized DAG into a
/// MSP430-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createMSP430ISelDag(MSP430TargetMachine &TM,
                                        CodeGenOpt::Level OptLevel) {
  return new MSP430DAGToDAGISel(TM, OptLevel);
}

// FIXME: This is pretty dummy routine and needs to be rewritten in the future.
bool MSP430DAGToDAGISel::SelectAddr(SDValue Op, SDValue Addr,
                                    SDValue &Base, SDValue &Disp) {
  // Try to match frame address first.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i16);
    Disp = CurDAG->getTargetConstant(0, MVT::i16);
    return true;
  }

  switch (Addr.getOpcode()) {
  case ISD::ADD:
   // Operand is a result from ADD with constant operand which fits into i16.
   if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1))) {
      uint64_t CVal = CN->getZExtValue();
      // Offset should fit into 16 bits.
      if (((CVal << 48) >> 48) == CVal) {
        SDValue N0 = Addr.getOperand(0);
        if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(N0))
          Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i16);
        else
          Base = N0;

        Disp = CurDAG->getTargetConstant(CVal, MVT::i16);
        return true;
      }
    }
    break;
  case MSP430ISD::Wrapper:
    SDValue N0 = Addr.getOperand(0);
    if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(N0)) {
      Base = CurDAG->getTargetGlobalAddress(G->getGlobal(),
                                            MVT::i16, G->getOffset());
      Disp = CurDAG->getTargetConstant(0, MVT::i16);
      return true;
    } else if (ExternalSymbolSDNode *E = dyn_cast<ExternalSymbolSDNode>(N0)) {
      Base = CurDAG->getTargetExternalSymbol(E->getSymbol(), MVT::i16);
      Disp = CurDAG->getTargetConstant(0, MVT::i16);
    }
    break;
  };

  Base = Addr;
  Disp = CurDAG->getTargetConstant(0, MVT::i16);

  return true;
}


bool MSP430DAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op, char ConstraintCode,
                             std::vector<SDValue> &OutOps) {
  SDValue Op0, Op1;
  switch (ConstraintCode) {
  default: return true;
  case 'm':   // memory
    if (!SelectAddr(Op, Op, Op0, Op1))
      return true;
    break;
  }

  OutOps.push_back(Op0);
  OutOps.push_back(Op1);
  return false;
}

/// MoveBelowTokenFactor - Replace TokenFactor operand with load's chain operand
/// and move load below the TokenFactor. Replace store's chain operand with
/// load's chain result.
static void MoveBelowTokenFactor(SelectionDAG *CurDAG, SDValue Load,
                                 SDValue Store, SDValue TF) {
  SmallVector<SDValue, 4> Ops;
  for (unsigned i = 0, e = TF.getNode()->getNumOperands(); i != e; ++i)
    if (Load.getNode() == TF.getOperand(i).getNode())
      Ops.push_back(Load.getOperand(0));
    else
      Ops.push_back(TF.getOperand(i));
  SDValue NewTF = CurDAG->UpdateNodeOperands(TF, &Ops[0], Ops.size());
  SDValue NewLoad = CurDAG->UpdateNodeOperands(Load, NewTF,
                                               Load.getOperand(1),
                                               Load.getOperand(2));
  CurDAG->UpdateNodeOperands(Store, NewLoad.getValue(1), Store.getOperand(1),
                             Store.getOperand(2), Store.getOperand(3));
}

/// isRMWLoad - Return true if N is a load that's part of RMW sub-DAG.
/// The chain produced by the load must only be used by the store's chain
/// operand, otherwise this may produce a cycle in the DAG.
static bool isRMWLoad(SDValue N, SDValue Chain, SDValue Address,
                      SDValue &Load) {
  if (N.getOpcode() == ISD::BIT_CONVERT)
    N = N.getOperand(0);

  LoadSDNode *LD = dyn_cast<LoadSDNode>(N);
  if (!LD || LD->isVolatile())
    return false;
  if (LD->getAddressingMode() != ISD::UNINDEXED)
    return false;

  ISD::LoadExtType ExtType = LD->getExtensionType();
  if (ExtType != ISD::NON_EXTLOAD && ExtType != ISD::EXTLOAD)
    return false;

  if (N.hasOneUse() &&
      LD->hasNUsesOfValue(1, 1) &&
      N.getOperand(1) == Address &&
      LD->isOperandOf(Chain.getNode())) {
    Load = N;
    return true;
  }
  return false;
}

/// PreprocessForRMW - Preprocess the DAG to make instruction selection better.
/// This is only run if not in -O0 mode.
/// This allows the instruction selector to pick more read-modify-write
/// instructions. This is a common case:
///
///     [Load chain]
///         ^
///         |
///       [Load]
///       ^    ^
///       |    |
///      /      \-
///     /         |
/// [TokenFactor] [Op]
///     ^          ^
///     |          |
///      \        /
///       \      /
///       [Store]
///
/// The fact the store's chain operand != load's chain will prevent the
/// (store (op (load))) instruction from being selected. We can transform it to:
///
///     [Load chain]
///         ^
///         |
///    [TokenFactor]
///         ^
///         |
///       [Load]
///       ^    ^
///       |    |
///       |     \-
///       |       |
///       |     [Op]
///       |       ^
///       |       |
///       \      /
///        \    /
///       [Store]
void MSP430DAGToDAGISel::PreprocessForRMW() {
  for (SelectionDAG::allnodes_iterator I = CurDAG->allnodes_begin(),
         E = CurDAG->allnodes_end(); I != E; ++I) {
    if (!ISD::isNON_TRUNCStore(I))
      continue;
    SDValue Chain = I->getOperand(0);

    if (Chain.getNode()->getOpcode() != ISD::TokenFactor)
      continue;

    SDValue N1 = I->getOperand(1);
    SDValue N2 = I->getOperand(2);
    if ((N1.getValueType().isFloatingPoint() &&
         !N1.getValueType().isVector()) ||
        !N1.hasOneUse())
      continue;

    bool RModW = false;
    SDValue Load;
    unsigned Opcode = N1.getNode()->getOpcode();
    switch (Opcode) {
    case ISD::ADD:
    case ISD::AND:
    case ISD::OR:
    case ISD::XOR:
    case ISD::ADDC:
    case ISD::ADDE: {
      SDValue N10 = N1.getOperand(0);
      SDValue N11 = N1.getOperand(1);
      RModW = isRMWLoad(N10, Chain, N2, Load);
      if (!RModW)
        RModW = isRMWLoad(N11, Chain, N2, Load);
      break;
    }
    case ISD::SUB:
    case ISD::SUBC:
    case ISD::SUBE: {
      SDValue N10 = N1.getOperand(0);
      RModW = isRMWLoad(N10, Chain, N2, Load);
      break;
    }
    }

    if (RModW) {
      MoveBelowTokenFactor(CurDAG, Load, SDValue(I, 0), Chain);
      ++NumLoadMoved;
    }
  }
}

/// InstructionSelect - This callback is invoked by
/// SelectionDAGISel when it has created a SelectionDAG for us to codegen.
void MSP430DAGToDAGISel::InstructionSelect() {
  std::string BlockName;
  if (ViewRMWDAGs)
    BlockName = MF->getFunction()->getNameStr() + ":" +
                BB->getBasicBlock()->getNameStr();

  PreprocessForRMW();

  if (ViewRMWDAGs) CurDAG->viewGraph("RMW preprocessed:" + BlockName);

  DEBUG(errs() << "Selection DAG after RMW preprocessing:\n");
  DEBUG(CurDAG->dump());

  DEBUG(BB->dump());

  // Codegen the basic block.
  DEBUG(errs() << "===== Instruction selection begins:\n");
  DEBUG(Indent = 0);
  SelectRoot(*CurDAG);
  DEBUG(errs() << "===== Instruction selection ends:\n");

  CurDAG->RemoveDeadNodes();
}

SDNode *MSP430DAGToDAGISel::Select(SDValue Op) {
  SDNode *Node = Op.getNode();
  DebugLoc dl = Op.getDebugLoc();

  // Dump information about the Node being selected
  DEBUG(errs().indent(Indent) << "Selecting: ");
  DEBUG(Node->dump(CurDAG));
  DEBUG(errs() << "\n");
  DEBUG(Indent += 2);

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    DEBUG(errs().indent(Indent-2) << "== ";
          Node->dump(CurDAG);
          errs() << "\n");
    DEBUG(Indent -= 2);
    return NULL;
  }

  // Few custom selection stuff.
  switch (Node->getOpcode()) {
  default: break;
  case ISD::FrameIndex: {
    assert(Op.getValueType() == MVT::i16);
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, MVT::i16);
    if (Node->hasOneUse())
      return CurDAG->SelectNodeTo(Node, MSP430::ADD16ri, MVT::i16,
                                  TFI, CurDAG->getTargetConstant(0, MVT::i16));
    return CurDAG->getMachineNode(MSP430::ADD16ri, dl, MVT::i16,
                                  TFI, CurDAG->getTargetConstant(0, MVT::i16));
  }
  }

  // Select the default instruction
  SDNode *ResNode = SelectCode(Op);

  DEBUG(errs() << std::string(Indent-2, ' ') << "=> ");
  if (ResNode == NULL || ResNode == Op.getNode())
    DEBUG(Op.getNode()->dump(CurDAG));
  else
    DEBUG(ResNode->dump(CurDAG));
  DEBUG(errs() << "\n");
  DEBUG(Indent -= 2);

  return ResNode;
}
