//===- ARMRegisterInfo.cpp - ARM Register Information -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the "Instituto Nokia de Tecnologia" and
// is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the ARM implementation of the MRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "ARM.h"
#include "ARMRegisterInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineLocation.h"
#include "llvm/Type.h"
#include "llvm/ADT/STLExtras.h"
#include <iostream>
using namespace llvm;

ARMRegisterInfo::ARMRegisterInfo()
  : ARMGenRegisterInfo(ARM::ADJCALLSTACKDOWN, ARM::ADJCALLSTACKUP) {
}

void ARMRegisterInfo::
storeRegToStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                    unsigned SrcReg, int FI,
                    const TargetRegisterClass *RC) const {
  // On the order of operands here: think "[FI + 0] = SrcReg".
  assert (RC == ARM::IntRegsRegisterClass);
  BuildMI(MBB, I, ARM::str, 3).addFrameIndex(FI).addImm(0).addReg(SrcReg);
}

void ARMRegisterInfo::
loadRegFromStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                     unsigned DestReg, int FI,
                     const TargetRegisterClass *RC) const {
  assert (RC == ARM::IntRegsRegisterClass);
  BuildMI(MBB, I, ARM::ldr, 2, DestReg).addFrameIndex(FI).addImm(0);
}

void ARMRegisterInfo::copyRegToReg(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I,
                                     unsigned DestReg, unsigned SrcReg,
                                     const TargetRegisterClass *RC) const {
  assert (RC == ARM::IntRegsRegisterClass);
  BuildMI(MBB, I, ARM::movrr, 1, DestReg).addReg(SrcReg);
}

MachineInstr *ARMRegisterInfo::foldMemoryOperand(MachineInstr* MI,
                                                   unsigned OpNum,
                                                   int FI) const {
  return NULL;
}

const unsigned* ARMRegisterInfo::getCalleeSaveRegs() const {
  static const unsigned CalleeSaveRegs[] = { 0 };
  return CalleeSaveRegs;
}

const TargetRegisterClass* const *
ARMRegisterInfo::getCalleeSaveRegClasses() const {
  static const TargetRegisterClass * const CalleeSaveRegClasses[] = { 0 };
  return CalleeSaveRegClasses;
}

void ARMRegisterInfo::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  MBB.erase(I);
}

void
ARMRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II) const {
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  MachineFunction &MF = *MBB.getParent();

  assert (MI.getOpcode() == ARM::movrr);

  unsigned FrameIdx = 1;

  int FrameIndex = MI.getOperand(FrameIdx).getFrameIndex();

  int Offset = MF.getFrameInfo()->getObjectOffset(FrameIndex);

  unsigned StackSize = MF.getFrameInfo()->getStackSize();

  Offset += StackSize;

  // Insert a set of r12 with the full address
  // r12 = r13 + offset
  MachineBasicBlock *MBB2 = MI.getParent();
  BuildMI(*MBB2, II, ARM::addri, 2, ARM::R12).addReg(ARM::R13).addImm(Offset);

  // Replace the FrameIndex with r12
  MI.getOperand(FrameIdx).ChangeToRegister(ARM::R12);
}

void ARMRegisterInfo::
processFunctionBeforeFrameFinalized(MachineFunction &MF) const {}

void ARMRegisterInfo::emitPrologue(MachineFunction &MF) const {
}

void ARMRegisterInfo::emitEpilogue(MachineFunction &MF,
				   MachineBasicBlock &MBB) const {
}

unsigned ARMRegisterInfo::getRARegister() const {
  return ARM::R14;
}

unsigned ARMRegisterInfo::getFrameRegister(MachineFunction &MF) const {
  return ARM::R13;
}

#include "ARMGenRegisterInfo.inc"

