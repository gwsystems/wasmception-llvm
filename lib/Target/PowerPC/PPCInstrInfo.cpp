//===- PPC32InstrInfo.cpp - PowerPC32 Instruction Information ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the PowerPC implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "PPC32InstrInfo.h"
#include "PPCGenInstrInfo.inc"
#include "PowerPC.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include <iostream>
using namespace llvm;

PPC32InstrInfo::PPC32InstrInfo()
  : TargetInstrInfo(PPCInsts, sizeof(PPCInsts)/sizeof(PPCInsts[0])) {}

bool PPC32InstrInfo::isMoveInstr(const MachineInstr& MI,
                                 unsigned& sourceReg,
                                 unsigned& destReg) const {
  MachineOpCode oc = MI.getOpcode();
  if (oc == PPC::OR) {                      // or r1, r2, r2
    assert(MI.getNumOperands() == 3 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           MI.getOperand(2).isRegister() &&
           "invalid PPC OR instruction!");
    if (MI.getOperand(1).getReg() == MI.getOperand(2).getReg()) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
  } else if (oc == PPC::ADDI) {             // addi r1, r2, 0
    assert(MI.getNumOperands() == 3 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(2).isImmediate() &&
           "invalid PPC ADDI instruction!");
    if (MI.getOperand(1).isRegister() && MI.getOperand(2).getImmedValue()==0) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
  } else if (oc == PPC::ORI) {             // ori r1, r2, 0
    assert(MI.getNumOperands() == 3 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           MI.getOperand(2).isImmediate() &&
           "invalid PPC ORI instruction!");
    if (MI.getOperand(2).getImmedValue()==0) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
  } else if (oc == PPC::FMRS || oc == PPC::FMRD ||
             oc == PPC::FMRSD) {      // fmr r1, r2
    assert(MI.getNumOperands() == 2 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           "invalid PPC FMR instruction");
    sourceReg = MI.getOperand(1).getReg();
    destReg = MI.getOperand(0).getReg();
    return true;
  } else if (oc == PPC::MCRF) {             // mcrf cr1, cr2
    assert(MI.getNumOperands() == 2 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           "invalid PPC MCRF instruction");
    sourceReg = MI.getOperand(1).getReg();
    destReg = MI.getOperand(0).getReg();
    return true;
  }
  return false;
}

// commuteInstruction - We can commute rlwimi instructions, but only if the
// rotate amt is zero.  We also have to munge the immediates a bit.
MachineInstr *PPC32InstrInfo::commuteInstruction(MachineInstr *MI) const {
  // Normal instructions can be commuted the obvious way.
  if (MI->getOpcode() != PPC::RLWIMI)
    return TargetInstrInfo::commuteInstruction(MI);
  
  // Cannot commute if it has a non-zero rotate count.
  if (MI->getOperand(3).getImmedValue() != 0)
    return 0;
  
  // If we have a zero rotate count, we have:
  //   M = mask(MB,ME)
  //   Op0 = (Op1 & ~M) | (Op2 & M)
  // Change this to:
  //   M = mask((ME+1)&31, (MB-1)&31)
  //   Op0 = (Op2 & ~M) | (Op1 & M)

  // Swap op1/op2
  unsigned Reg1 = MI->getOperand(1).getReg();
  unsigned Reg2 = MI->getOperand(2).getReg();
  MI->SetMachineOperandReg(2, Reg1);
  MI->SetMachineOperandReg(1, Reg2);
  
  // Swap the mask around.
  unsigned MB = MI->getOperand(4).getImmedValue();
  unsigned ME = MI->getOperand(5).getImmedValue();
  MI->getOperand(4).setImmedValue((ME+1) & 31);
  MI->getOperand(5).setImmedValue((MB-1) & 31);
  return MI;
}
