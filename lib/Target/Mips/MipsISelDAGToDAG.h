//===---- MipsISelDAGToDAG.h - A Dag to Dag Inst Selector for Mips --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the MIPS target.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MIPS_MIPSISELDAGTODAG_H
#define LLVM_LIB_TARGET_MIPS_MIPSISELDAGTODAG_H

#include "Mips.h"
#include "MipsSubtarget.h"
#include "MipsTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MipsDAGToDAGISel - MIPS specific code to select MIPS machine
// instructions for SelectionDAG operations.
//===----------------------------------------------------------------------===//
namespace llvm {

class MipsDAGToDAGISel : public SelectionDAGISel {
public:
  explicit MipsDAGToDAGISel(MipsTargetMachine &TM)
      : SelectionDAGISel(TM), Subtarget(nullptr) {}

  // Pass Name
  const char *getPassName() const override {
    return "MIPS DAG->DAG Pattern Instruction Selection";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

protected:
  SDNode *getGlobalBaseReg();

  /// Keep a pointer to the MipsSubtarget around so that we can make the right
  /// decision when generating code for different targets.
  const MipsSubtarget *Subtarget;

private:
  // Include the pieces autogenerated from the target description.
  #include "MipsGenDAGISel.inc"

  // Complex Pattern.
  /// (reg + imm).
  virtual bool selectAddrRegImm(SDValue Addr, SDValue &Base,
                                SDValue &Offset) const;

  // Complex Pattern.
  /// (reg + reg).
  virtual bool selectAddrRegReg(SDValue Addr, SDValue &Base,
                                SDValue &Offset) const;

  /// Fall back on this function if all else fails.
  virtual bool selectAddrDefault(SDValue Addr, SDValue &Base,
                                 SDValue &Offset) const;

  /// Match integer address pattern.
  virtual bool selectIntAddr(SDValue Addr, SDValue &Base,
                             SDValue &Offset) const;

  virtual bool selectIntAddrMM(SDValue Addr, SDValue &Base,
                               SDValue &Offset) const;

  virtual bool selectIntAddrLSL2MM(SDValue Addr, SDValue &Base,
                                   SDValue &Offset) const;

  /// Match addr+simm10 and addr
  virtual bool selectIntAddrMSA(SDValue Addr, SDValue &Base,
                                SDValue &Offset) const;

  virtual bool selectAddr16(SDNode *Parent, SDValue N, SDValue &Base,
                            SDValue &Offset, SDValue &Alias);

  /// \brief Select constant vector splats.
  virtual bool selectVSplat(SDNode *N, APInt &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm1.
  virtual bool selectVSplatUimm1(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm2.
  virtual bool selectVSplatUimm2(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm3.
  virtual bool selectVSplatUimm3(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm4.
  virtual bool selectVSplatUimm4(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm5.
  virtual bool selectVSplatUimm5(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm6.
  virtual bool selectVSplatUimm6(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a uimm8.
  virtual bool selectVSplatUimm8(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value fits in a simm5.
  virtual bool selectVSplatSimm5(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value is a power of 2.
  virtual bool selectVSplatUimmPow2(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value is the inverse of a
  /// power of 2.
  virtual bool selectVSplatUimmInvPow2(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value is a run of set bits
  /// ending at the most significant bit
  virtual bool selectVSplatMaskL(SDValue N, SDValue &Imm) const;
  /// \brief Select constant vector splats whose value is a run of set bits
  /// starting at bit zero.
  virtual bool selectVSplatMaskR(SDValue N, SDValue &Imm) const;

  SDNode *Select(SDNode *N) override;

  virtual std::pair<bool, SDNode*> selectNode(SDNode *Node) = 0;

  // getImm - Return a target constant with the specified value.
  inline SDValue getImm(const SDNode *Node, uint64_t Imm) {
    return CurDAG->getTargetConstant(Imm, Node->getValueType(0));
  }

  virtual void processFunctionAfterISel(MachineFunction &MF) = 0;

  bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                    unsigned ConstraintID,
                                    std::vector<SDValue> &OutOps) override;
};
}

#endif
