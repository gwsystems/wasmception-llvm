//===-- PTXISelDAGToDAG.cpp - A dag to dag inst selector for PTX ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the PTX target.
//
//===----------------------------------------------------------------------===//

#include "PTX.h"
#include "PTXTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/DerivedTypes.h"

using namespace llvm;

namespace {
// PTXDAGToDAGISel - PTX specific code to select PTX machine
// instructions for SelectionDAG operations.
class PTXDAGToDAGISel : public SelectionDAGISel {
  public:
    PTXDAGToDAGISel(PTXTargetMachine &TM, CodeGenOpt::Level OptLevel);

    virtual const char *getPassName() const {
      return "PTX DAG->DAG Pattern Instruction Selection";
    }

    SDNode *Select(SDNode *Node);

    // Complex Pattern Selectors.
    bool SelectADDRrr(SDValue &Addr, SDValue &R1, SDValue &R2);
    bool SelectADDRri(SDValue &Addr, SDValue &Base, SDValue &Offset);
    bool SelectADDRii(SDValue &Addr, SDValue &Base, SDValue &Offset);

    // Include the pieces auto'gened from the target description
#include "PTXGenDAGISel.inc"

  private:
    bool isImm(const SDValue &operand);
    bool SelectImm(const SDValue &operand, SDValue &imm);
}; // class PTXDAGToDAGISel
} // namespace

// createPTXISelDag - This pass converts a legalized DAG into a
// PTX-specific DAG, ready for instruction scheduling
FunctionPass *llvm::createPTXISelDag(PTXTargetMachine &TM,
                                     CodeGenOpt::Level OptLevel) {
  return new PTXDAGToDAGISel(TM, OptLevel);
}

PTXDAGToDAGISel::PTXDAGToDAGISel(PTXTargetMachine &TM,
                                 CodeGenOpt::Level OptLevel)
  : SelectionDAGISel(TM, OptLevel) {}

SDNode *PTXDAGToDAGISel::Select(SDNode *Node) {
  // SelectCode() is auto'gened
  return SelectCode(Node);
}

// Match memory operand of the form [reg+reg]
bool PTXDAGToDAGISel::SelectADDRrr(SDValue &Addr, SDValue &R1, SDValue &R2) {
  if (Addr.getOpcode() != ISD::ADD || Addr.getNumOperands() < 2 ||
      isImm(Addr.getOperand(0)) || isImm(Addr.getOperand(1)))
    return false;

  R1 = Addr.getOperand(0);
  R2 = Addr.getOperand(1);
  return true;
}

// Match memory operand of the form [reg], [imm+reg], and [reg+imm]
bool PTXDAGToDAGISel::SelectADDRri(SDValue &Addr, SDValue &Base,
                                   SDValue &Offset) {
  if (Addr.getOpcode() != ISD::ADD) {
    if (isImm(Addr))
      return false;
    // is [reg] but not [imm]
    Base = Addr;
    Offset = CurDAG->getTargetConstant(0, MVT::i32);
    return true;
  }

  // let SelectADDRii handle the [imm+imm] case
  if (Addr.getNumOperands() >= 2 &&
      isImm(Addr.getOperand(0)) && isImm(Addr.getOperand(1)))
    return false;

  // try [reg+imm] and [imm+reg]
  for (int i = 0; i < 2; i ++)
    if (SelectImm(Addr.getOperand(1-i), Offset)) {
      Base = Addr.getOperand(i);
      return true;
    }

  // either [reg+imm] and [imm+reg]
  for (int i = 0; i < 2; i ++)
    if (SelectImm(Addr.getOperand(1-i), Offset)) {
      Base = Addr.getOperand(i);
      return true;
    }

  return false;
}

// Match memory operand of the form [imm+imm] and [imm]
bool PTXDAGToDAGISel::SelectADDRii(SDValue &Addr, SDValue &Base,
                                   SDValue &Offset) {
  // is [imm+imm]?
  if (Addr.getOpcode() == ISD::ADD) {
    return SelectImm(Addr.getOperand(0), Base) &&
           SelectImm(Addr.getOperand(1), Offset);
  }

  // is [imm]?
  if (SelectImm(Addr, Base)) {
    Offset = CurDAG->getTargetConstant(0, MVT::i32);
    return true;
  }

  return false;
}

bool PTXDAGToDAGISel::isImm(const SDValue &operand) {
  return ConstantSDNode::classof(operand.getNode());
}

bool PTXDAGToDAGISel::SelectImm(const SDValue &operand, SDValue &imm) {
  SDNode *node = operand.getNode();
  if (!ConstantSDNode::classof(node))
    return false;

  ConstantSDNode *CN = cast<ConstantSDNode>(node);
  imm = CurDAG->getTargetConstant(*CN->getConstantIntValue(), MVT::i32);
  return true;
}
