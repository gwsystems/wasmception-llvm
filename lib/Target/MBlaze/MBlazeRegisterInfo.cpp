//===- MBlazeRegisterInfo.cpp - MBlaze Register Information -== -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the MBlaze implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "mblaze-frame-info"

#include "MBlaze.h"
#include "MBlazeSubtarget.h"
#include "MBlazeRegisterInfo.h"
#include "MBlazeMachineFunction.h"
#include "llvm/Constants.h"
#include "llvm/Type.h"
#include "llvm/Function.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"

#define GET_REGINFO_TARGET_DESC
#include "MBlazeGenRegisterInfo.inc"

using namespace llvm;

MBlazeRegisterInfo::
MBlazeRegisterInfo(const MBlazeSubtarget &ST, const TargetInstrInfo &tii)
  : MBlazeGenRegisterInfo(MBlaze::R15), Subtarget(ST), TII(tii) {}

/// getRegisterFromNumbering - Given the enum value for some register, e.g.
/// MBlaze::R0, return the number that it corresponds to (e.g. 0).
unsigned MBlazeRegisterInfo::getRegisterFromNumbering(unsigned Reg) {
  switch (Reg) {
    case 0  : return MBlaze::R0;
    case 1  : return MBlaze::R1;
    case 2  : return MBlaze::R2;
    case 3  : return MBlaze::R3;
    case 4  : return MBlaze::R4;
    case 5  : return MBlaze::R5;
    case 6  : return MBlaze::R6;
    case 7  : return MBlaze::R7;
    case 8  : return MBlaze::R8;
    case 9  : return MBlaze::R9;
    case 10 : return MBlaze::R10;
    case 11 : return MBlaze::R11;
    case 12 : return MBlaze::R12;
    case 13 : return MBlaze::R13;
    case 14 : return MBlaze::R14;
    case 15 : return MBlaze::R15;
    case 16 : return MBlaze::R16;
    case 17 : return MBlaze::R17;
    case 18 : return MBlaze::R18;
    case 19 : return MBlaze::R19;
    case 20 : return MBlaze::R20;
    case 21 : return MBlaze::R21;
    case 22 : return MBlaze::R22;
    case 23 : return MBlaze::R23;
    case 24 : return MBlaze::R24;
    case 25 : return MBlaze::R25;
    case 26 : return MBlaze::R26;
    case 27 : return MBlaze::R27;
    case 28 : return MBlaze::R28;
    case 29 : return MBlaze::R29;
    case 30 : return MBlaze::R30;
    case 31 : return MBlaze::R31;
    default: llvm_unreachable("Unknown register number!");
  }
  return 0; // Not reached
}

unsigned MBlazeRegisterInfo::getPICCallReg() {
  return MBlaze::R20;
}

//===----------------------------------------------------------------------===//
// Callee Saved Registers methods
//===----------------------------------------------------------------------===//

/// MBlaze Callee Saved Registers
const unsigned* MBlazeRegisterInfo::
getCalleeSavedRegs(const MachineFunction *MF) const {
  // MBlaze callee-save register range is R20 - R31
  static const unsigned CalleeSavedRegs[] = {
    MBlaze::R20, MBlaze::R21, MBlaze::R22, MBlaze::R23,
    MBlaze::R24, MBlaze::R25, MBlaze::R26, MBlaze::R27,
    MBlaze::R28, MBlaze::R29, MBlaze::R30, MBlaze::R31,
    0
  };

  return CalleeSavedRegs;
}

BitVector MBlazeRegisterInfo::
getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  Reserved.set(MBlaze::R0);
  Reserved.set(MBlaze::R1);
  Reserved.set(MBlaze::R2);
  Reserved.set(MBlaze::R13);
  Reserved.set(MBlaze::R14);
  Reserved.set(MBlaze::R15);
  Reserved.set(MBlaze::R16);
  Reserved.set(MBlaze::R17);
  Reserved.set(MBlaze::R18);
  Reserved.set(MBlaze::R19);
  return Reserved;
}

// This function eliminate ADJCALLSTACKDOWN/ADJCALLSTACKUP pseudo instructions
void MBlazeRegisterInfo::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  if (!TFI->hasReservedCallFrame(MF)) {
    // If we have a frame pointer, turn the adjcallstackup instruction into a
    // 'addi r1, r1, -<amt>' and the adjcallstackdown instruction into
    // 'addi r1, r1, <amt>'
    MachineInstr *Old = I;
    int Amount = Old->getOperand(0).getImm() + 4;
    if (Amount != 0) {
      // We need to keep the stack aligned properly.  To do this, we round the
      // amount of space needed for the outgoing arguments up to the next
      // alignment boundary.
      unsigned Align = TFI->getStackAlignment();
      Amount = (Amount+Align-1)/Align*Align;

      MachineInstr *New;
      if (Old->getOpcode() == MBlaze::ADJCALLSTACKDOWN) {
        New = BuildMI(MF,Old->getDebugLoc(),TII.get(MBlaze::ADDIK),MBlaze::R1)
                .addReg(MBlaze::R1).addImm(-Amount);
      } else {
        assert(Old->getOpcode() == MBlaze::ADJCALLSTACKUP);
        New = BuildMI(MF,Old->getDebugLoc(),TII.get(MBlaze::ADDIK),MBlaze::R1)
                .addReg(MBlaze::R1).addImm(Amount);
      }

      // Replace the pseudo instruction with a new instruction...
      MBB.insert(I, New);
    }
  }

  // Simply discard ADJCALLSTACKDOWN, ADJCALLSTACKUP instructions.
  MBB.erase(I);
}

// FrameIndex represent objects inside a abstract stack.
// We must replace FrameIndex with an stack/frame pointer
// direct reference.
void MBlazeRegisterInfo::
eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                    RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  MachineFrameInfo *MFI = MF.getFrameInfo();

  unsigned i = 0;
  while (!MI.getOperand(i).isFI()) {
    ++i;
    assert(i < MI.getNumOperands() &&
           "Instr doesn't have FrameIndex operand!");
  }

  unsigned oi = i == 2 ? 1 : 2;

  DEBUG(dbgs() << "\nFunction : " << MF.getFunction()->getName() << "\n";
        dbgs() << "<--------->\n" << MI);

  int FrameIndex = MI.getOperand(i).getIndex();
  int stackSize  = MFI->getStackSize();
  int spOffset   = MFI->getObjectOffset(FrameIndex);

  DEBUG(MBlazeFunctionInfo *MBlazeFI = MF.getInfo<MBlazeFunctionInfo>();
        dbgs() << "FrameIndex : " << FrameIndex << "\n"
               << "spOffset   : " << spOffset << "\n"
               << "stackSize  : " << stackSize << "\n"
               << "isFixed    : " << MFI->isFixedObjectIndex(FrameIndex) << "\n"
               << "isLiveIn   : " << MBlazeFI->isLiveIn(FrameIndex) << "\n"
               << "isSpill    : " << MFI->isSpillSlotObjectIndex(FrameIndex)
               << "\n" );

  // as explained on LowerFormalArguments, detect negative offsets
  // and adjust SPOffsets considering the final stack size.
  int Offset = (spOffset < 0) ? (stackSize - spOffset) : spOffset;
  Offset += MI.getOperand(oi).getImm();

  DEBUG(dbgs() << "Offset     : " << Offset << "\n" << "<--------->\n");

  MI.getOperand(oi).ChangeToImmediate(Offset);
  MI.getOperand(i).ChangeToRegister(getFrameRegister(MF), false);
}

void MBlazeRegisterInfo::
processFunctionBeforeFrameFinalized(MachineFunction &MF) const {
  // Set the stack offset where GP must be saved/loaded from.
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MBlazeFunctionInfo *MBlazeFI = MF.getInfo<MBlazeFunctionInfo>();
  if (MBlazeFI->needGPSaveRestore())
    MFI->setObjectOffset(MBlazeFI->getGPFI(), MBlazeFI->getGPStackOffset());
}

unsigned MBlazeRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  return TFI->hasFP(MF) ? MBlaze::R19 : MBlaze::R1;
}

unsigned MBlazeRegisterInfo::getEHExceptionRegister() const {
  llvm_unreachable("What is the exception register");
  return 0;
}

unsigned MBlazeRegisterInfo::getEHHandlerRegister() const {
  llvm_unreachable("What is the exception handler register");
  return 0;
}
