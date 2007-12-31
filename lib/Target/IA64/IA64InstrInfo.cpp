//===- IA64InstrInfo.cpp - IA64 Instruction Information -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the IA64 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "IA64InstrInfo.h"
#include "IA64.h"
#include "IA64InstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "IA64GenInstrInfo.inc"
using namespace llvm;

IA64InstrInfo::IA64InstrInfo()
  : TargetInstrInfo(IA64Insts, sizeof(IA64Insts)/sizeof(IA64Insts[0])),
    RI(*this) {
}


bool IA64InstrInfo::isMoveInstr(const MachineInstr& MI,
                               unsigned& sourceReg,
                               unsigned& destReg) const {
  MachineOpCode oc = MI.getOpcode();
  if (oc == IA64::MOV || oc == IA64::FMOV) {
  // TODO: this doesn't detect predicate moves
     assert(MI.getNumOperands() >= 2 &&
             /* MI.getOperand(0).isRegister() &&
             MI.getOperand(1).isRegister() && */
             "invalid register-register move instruction");
     if( MI.getOperand(0).isRegister() &&
         MI.getOperand(1).isRegister() ) {
       // if both operands of the MOV/FMOV are registers, then
       // yes, this is a move instruction
       sourceReg = MI.getOperand(1).getReg();
       destReg = MI.getOperand(0).getReg();
       return true;
     }
  }
  return false; // we don't consider e.g. %regN = MOV <FrameIndex #x> a
                // move instruction
}

unsigned
IA64InstrInfo::InsertBranch(MachineBasicBlock &MBB,MachineBasicBlock *TBB,
                            MachineBasicBlock *FBB,
                            const std::vector<MachineOperand> &Cond)const {
  // Can only insert uncond branches so far.
  assert(Cond.empty() && !FBB && TBB && "Can only handle uncond branches!");
  BuildMI(&MBB, get(IA64::BRL_NOTCALL)).addMBB(TBB);
  return 1;
}

void IA64InstrInfo::copyRegToReg(MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MI,
                                   unsigned DestReg, unsigned SrcReg,
                                   const TargetRegisterClass *DestRC,
                                   const TargetRegisterClass *SrcRC) const {
  if (DestRC != SrcRC) {
    cerr << "Not yet supported!";
    abort();
  }

  if(DestRC == IA64::PRRegisterClass ) // if a bool, we use pseudocode
    // (SrcReg) DestReg = cmp.eq.unc(r0, r0)
    BuildMI(MBB, MI, get(IA64::PCMPEQUNC), DestReg)
      .addReg(IA64::r0).addReg(IA64::r0).addReg(SrcReg);
  else // otherwise, MOV works (for both gen. regs and FP regs)
    BuildMI(MBB, MI, get(IA64::MOV), DestReg).addReg(SrcReg);
}
