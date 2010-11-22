//=======- Thumb1FrameInfo.cpp - Thumb1 Frame Information ------*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Thumb1 implementation of TargetFrameInfo class.
//
//===----------------------------------------------------------------------===//

#include "Thumb1FrameInfo.h"
#include "ARMBaseInstrInfo.h"
#include "ARMMachineFunctionInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

bool Thumb1FrameInfo::hasReservedCallFrame(const MachineFunction &MF) const {
  const MachineFrameInfo *FFI = MF.getFrameInfo();
  unsigned CFSize = FFI->getMaxCallFrameSize();
  // It's not always a good idea to include the call frame as part of the
  // stack frame. ARM (especially Thumb) has small immediate offset to
  // address the stack frame. So a large call frame can cause poor codegen
  // and may even makes it impossible to scavenge a register.
  if (CFSize >= ((1 << 8) - 1) * 4 / 2) // Half of imm8 * 4
    return false;

  return !MF.getFrameInfo()->hasVarSizedObjects();
}

static void emitSPUpdate(MachineBasicBlock &MBB,
                         MachineBasicBlock::iterator &MBBI,
                         const TargetInstrInfo &TII, DebugLoc dl,
                         const Thumb1RegisterInfo &MRI,
                         int NumBytes) {
  emitThumbRegPlusImmediate(MBB, MBBI, ARM::SP, ARM::SP, NumBytes, TII,
                            MRI, dl);
}

void Thumb1FrameInfo::emitPrologue(MachineFunction &MF) const {
  MachineBasicBlock &MBB = MF.front();
  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo  *MFI = MF.getFrameInfo();
  ARMFunctionInfo *AFI = MF.getInfo<ARMFunctionInfo>();
  const Thumb1RegisterInfo *RegInfo =
    static_cast<const Thumb1RegisterInfo*>(MF.getTarget().getRegisterInfo());
  const Thumb1InstrInfo &TII =
    *static_cast<const Thumb1InstrInfo*>(MF.getTarget().getInstrInfo());

  unsigned VARegSaveSize = AFI->getVarArgsRegSaveSize();
  unsigned NumBytes = MFI->getStackSize();
  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
  DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  unsigned FramePtr = RegInfo->getFrameRegister(MF);
  unsigned BasePtr = RegInfo->getBaseRegister();

  // Thumb add/sub sp, imm8 instructions implicitly multiply the offset by 4.
  NumBytes = (NumBytes + 3) & ~3;
  MFI->setStackSize(NumBytes);

  // Determine the sizes of each callee-save spill areas and record which frame
  // belongs to which callee-save spill areas.
  unsigned GPRCS1Size = 0, GPRCS2Size = 0, DPRCSSize = 0;
  int FramePtrSpillFI = 0;

  if (VARegSaveSize)
    emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, -VARegSaveSize);

  if (!AFI->hasStackFrame()) {
    if (NumBytes != 0)
      emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, -NumBytes);
    return;
  }

  for (unsigned i = 0, e = CSI.size(); i != e; ++i) {
    unsigned Reg = CSI[i].getReg();
    int FI = CSI[i].getFrameIdx();
    switch (Reg) {
    case ARM::R4:
    case ARM::R5:
    case ARM::R6:
    case ARM::R7:
    case ARM::LR:
      if (Reg == FramePtr)
        FramePtrSpillFI = FI;
      AFI->addGPRCalleeSavedArea1Frame(FI);
      GPRCS1Size += 4;
      break;
    case ARM::R8:
    case ARM::R9:
    case ARM::R10:
    case ARM::R11:
      if (Reg == FramePtr)
        FramePtrSpillFI = FI;
      if (STI.isTargetDarwin()) {
        AFI->addGPRCalleeSavedArea2Frame(FI);
        GPRCS2Size += 4;
      } else {
        AFI->addGPRCalleeSavedArea1Frame(FI);
        GPRCS1Size += 4;
      }
      break;
    default:
      AFI->addDPRCalleeSavedAreaFrame(FI);
      DPRCSSize += 8;
    }
  }

  if (MBBI != MBB.end() && MBBI->getOpcode() == ARM::tPUSH) {
    ++MBBI;
    if (MBBI != MBB.end())
      dl = MBBI->getDebugLoc();
  }

  // Determine starting offsets of spill areas.
  unsigned DPRCSOffset  = NumBytes - (GPRCS1Size + GPRCS2Size + DPRCSSize);
  unsigned GPRCS2Offset = DPRCSOffset + DPRCSSize;
  unsigned GPRCS1Offset = GPRCS2Offset + GPRCS2Size;
  AFI->setFramePtrSpillOffset(MFI->getObjectOffset(FramePtrSpillFI) + NumBytes);
  AFI->setGPRCalleeSavedArea1Offset(GPRCS1Offset);
  AFI->setGPRCalleeSavedArea2Offset(GPRCS2Offset);
  AFI->setDPRCalleeSavedAreaOffset(DPRCSOffset);
  NumBytes = DPRCSOffset;

  // Adjust FP so it point to the stack slot that contains the previous FP.
  if (hasFP(MF)) {
    BuildMI(MBB, MBBI, dl, TII.get(ARM::tADDrSPi), FramePtr)
      .addFrameIndex(FramePtrSpillFI).addImm(0);
    if (NumBytes > 7)
      // If offset is > 7 then sp cannot be adjusted in a single instruction,
      // try restoring from fp instead.
      AFI->setShouldRestoreSPFromFP(true);
  }

  if (NumBytes)
    // Insert it after all the callee-save spills.
    emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, -NumBytes);

  if (STI.isTargetELF() && hasFP(MF))
    MFI->setOffsetAdjustment(MFI->getOffsetAdjustment() -
                             AFI->getFramePtrSpillOffset());

  AFI->setGPRCalleeSavedArea1Size(GPRCS1Size);
  AFI->setGPRCalleeSavedArea2Size(GPRCS2Size);
  AFI->setDPRCalleeSavedAreaSize(DPRCSSize);

  // If we need a base pointer, set it up here. It's whatever the value
  // of the stack pointer is at this point. Any variable size objects
  // will be allocated after this, so we can still use the base pointer
  // to reference locals.
  if (RegInfo->hasBasePointer(MF))
    BuildMI(MBB, MBBI, dl, TII.get(ARM::tMOVgpr2gpr), BasePtr).addReg(ARM::SP);
}

static bool isCalleeSavedRegister(unsigned Reg, const unsigned *CSRegs) {
  for (unsigned i = 0; CSRegs[i]; ++i)
    if (Reg == CSRegs[i])
      return true;
  return false;
}

static bool isCSRestore(MachineInstr *MI, const unsigned *CSRegs) {
  if (MI->getOpcode() == ARM::tRestore &&
      MI->getOperand(1).isFI() &&
      isCalleeSavedRegister(MI->getOperand(0).getReg(), CSRegs))
    return true;
  else if (MI->getOpcode() == ARM::tPOP) {
    // The first two operands are predicates. The last two are
    // imp-def and imp-use of SP. Check everything in between.
    for (int i = 2, e = MI->getNumOperands() - 2; i != e; ++i)
      if (!isCalleeSavedRegister(MI->getOperand(i).getReg(), CSRegs))
        return false;
    return true;
  }
  return false;
}

void Thumb1FrameInfo::emitEpilogue(MachineFunction &MF,
                                   MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = prior(MBB.end());
  assert((MBBI->getOpcode() == ARM::tBX_RET ||
          MBBI->getOpcode() == ARM::tPOP_RET) &&
         "Can only insert epilog into returning blocks");
  DebugLoc dl = MBBI->getDebugLoc();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  ARMFunctionInfo *AFI = MF.getInfo<ARMFunctionInfo>();
  const Thumb1RegisterInfo *RegInfo =
    static_cast<const Thumb1RegisterInfo*>(MF.getTarget().getRegisterInfo());
  const Thumb1InstrInfo &TII =
    *static_cast<const Thumb1InstrInfo*>(MF.getTarget().getInstrInfo());

  unsigned VARegSaveSize = AFI->getVarArgsRegSaveSize();
  int NumBytes = (int)MFI->getStackSize();
  const unsigned *CSRegs = RegInfo->getCalleeSavedRegs();
  unsigned FramePtr = RegInfo->getFrameRegister(MF);

  if (!AFI->hasStackFrame()) {
    if (NumBytes != 0)
      emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, NumBytes);
  } else {
    // Unwind MBBI to point to first LDR / VLDRD.
    if (MBBI != MBB.begin()) {
      do
        --MBBI;
      while (MBBI != MBB.begin() && isCSRestore(MBBI, CSRegs));
      if (!isCSRestore(MBBI, CSRegs))
        ++MBBI;
    }

    // Move SP to start of FP callee save spill area.
    NumBytes -= (AFI->getGPRCalleeSavedArea1Size() +
                 AFI->getGPRCalleeSavedArea2Size() +
                 AFI->getDPRCalleeSavedAreaSize());

    if (AFI->shouldRestoreSPFromFP()) {
      NumBytes = AFI->getFramePtrSpillOffset() - NumBytes;
      // Reset SP based on frame pointer only if the stack frame extends beyond
      // frame pointer stack slot or target is ELF and the function has FP.
      if (NumBytes) {
        assert(MF.getRegInfo().isPhysRegUsed(ARM::R4) &&
               "No scratch register to restore SP from FP!");
        emitThumbRegPlusImmediate(MBB, MBBI, ARM::R4, FramePtr, -NumBytes,
                                  TII, *RegInfo, dl);
        BuildMI(MBB, MBBI, dl, TII.get(ARM::tMOVtgpr2gpr), ARM::SP)
          .addReg(ARM::R4);
      } else
        BuildMI(MBB, MBBI, dl, TII.get(ARM::tMOVtgpr2gpr), ARM::SP)
          .addReg(FramePtr);
    } else {
      if (MBBI->getOpcode() == ARM::tBX_RET &&
          &MBB.front() != MBBI &&
          prior(MBBI)->getOpcode() == ARM::tPOP) {
        MachineBasicBlock::iterator PMBBI = prior(MBBI);
        emitSPUpdate(MBB, PMBBI, TII, dl, *RegInfo, NumBytes);
      } else
        emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, NumBytes);
    }
  }

  if (VARegSaveSize) {
    // Unlike T2 and ARM mode, the T1 pop instruction cannot restore
    // to LR, and we can't pop the value directly to the PC since
    // we need to update the SP after popping the value. Therefore, we
    // pop the old LR into R3 as a temporary.

    // Move back past the callee-saved register restoration
    while (MBBI != MBB.end() && isCSRestore(MBBI, CSRegs))
      ++MBBI;
    // Epilogue for vararg functions: pop LR to R3 and branch off it.
    AddDefaultPred(BuildMI(MBB, MBBI, dl, TII.get(ARM::tPOP)))
      .addReg(ARM::R3, RegState::Define);

    emitSPUpdate(MBB, MBBI, TII, dl, *RegInfo, VARegSaveSize);

    BuildMI(MBB, MBBI, dl, TII.get(ARM::tBX_RET_vararg))
      .addReg(ARM::R3, RegState::Kill);
    // erase the old tBX_RET instruction
    MBB.erase(MBBI);
  }
}
