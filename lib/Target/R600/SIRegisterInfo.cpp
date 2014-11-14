//===-- SIRegisterInfo.cpp - SI Register Information ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// \brief SI implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//


#include "SIRegisterInfo.h"
#include "AMDGPUSubtarget.h"
#include "SIInstrInfo.h"
#include "SIMachineFunctionInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"

using namespace llvm;

SIRegisterInfo::SIRegisterInfo(const AMDGPUSubtarget &st)
: AMDGPURegisterInfo(st)
  { }

BitVector SIRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  Reserved.set(AMDGPU::EXEC);

  // EXEC_LO and EXEC_HI could be allocated and used as regular register,
  // but this seems likely to result in bugs, so I'm marking them as reserved.
  Reserved.set(AMDGPU::EXEC_LO);
  Reserved.set(AMDGPU::EXEC_HI);

  Reserved.set(AMDGPU::INDIRECT_BASE_ADDR);
  Reserved.set(AMDGPU::FLAT_SCR);

  // Reserve some VGPRs to use as temp registers in case we have to spill VGPRs
  Reserved.set(AMDGPU::VGPR255);
  Reserved.set(AMDGPU::VGPR254);

  return Reserved;
}

unsigned SIRegisterInfo::getRegPressureLimit(const TargetRegisterClass *RC,
                                             MachineFunction &MF) const {
  return RC->getNumRegs();
}

bool SIRegisterInfo::requiresRegisterScavenging(const MachineFunction &Fn) const {
  return Fn.getFrameInfo()->hasStackObjects();
}

static unsigned getNumSubRegsForSpillOp(unsigned Op) {

  switch (Op) {
  case AMDGPU::SI_SPILL_S512_SAVE:
  case AMDGPU::SI_SPILL_S512_RESTORE:
  case AMDGPU::SI_SPILL_V512_SAVE:
  case AMDGPU::SI_SPILL_V512_RESTORE:
    return 16;
  case AMDGPU::SI_SPILL_S256_SAVE:
  case AMDGPU::SI_SPILL_S256_RESTORE:
  case AMDGPU::SI_SPILL_V256_SAVE:
  case AMDGPU::SI_SPILL_V256_RESTORE:
    return 8;
  case AMDGPU::SI_SPILL_S128_SAVE:
  case AMDGPU::SI_SPILL_S128_RESTORE:
  case AMDGPU::SI_SPILL_V128_SAVE:
  case AMDGPU::SI_SPILL_V128_RESTORE:
    return 4;
  case AMDGPU::SI_SPILL_V96_SAVE:
  case AMDGPU::SI_SPILL_V96_RESTORE:
    return 3;
  case AMDGPU::SI_SPILL_S64_SAVE:
  case AMDGPU::SI_SPILL_S64_RESTORE:
  case AMDGPU::SI_SPILL_V64_SAVE:
  case AMDGPU::SI_SPILL_V64_RESTORE:
    return 2;
  case AMDGPU::SI_SPILL_S32_SAVE:
  case AMDGPU::SI_SPILL_S32_RESTORE:
  case AMDGPU::SI_SPILL_V32_SAVE:
  case AMDGPU::SI_SPILL_V32_RESTORE:
    return 1;
  default: llvm_unreachable("Invalid spill opcode");
  }
}

void SIRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator MI,
                                        int SPAdj, unsigned FIOperandNum,
                                        RegScavenger *RS) const {
  MachineFunction *MF = MI->getParent()->getParent();
  MachineBasicBlock *MBB = MI->getParent();
  SIMachineFunctionInfo *MFI = MF->getInfo<SIMachineFunctionInfo>();
  MachineFrameInfo *FrameInfo = MF->getFrameInfo();
  const SIInstrInfo *TII = static_cast<const SIInstrInfo*>(ST.getInstrInfo());
  DebugLoc DL = MI->getDebugLoc();

  MachineOperand &FIOp = MI->getOperand(FIOperandNum);
  int Index = MI->getOperand(FIOperandNum).getIndex();

  switch (MI->getOpcode()) {
    // SGPR register spill
    case AMDGPU::SI_SPILL_S512_SAVE:
    case AMDGPU::SI_SPILL_S256_SAVE:
    case AMDGPU::SI_SPILL_S128_SAVE:
    case AMDGPU::SI_SPILL_S64_SAVE:
    case AMDGPU::SI_SPILL_S32_SAVE: {
      unsigned NumSubRegs = getNumSubRegsForSpillOp(MI->getOpcode());

      for (unsigned i = 0, e = NumSubRegs; i < e; ++i) {
        unsigned SubReg = getPhysRegSubReg(MI->getOperand(0).getReg(),
                                           &AMDGPU::SGPR_32RegClass, i);
        struct SIMachineFunctionInfo::SpilledReg Spill =
            MFI->getSpilledReg(MF, Index, i);

        if (Spill.VGPR == AMDGPU::NoRegister) {
           LLVMContext &Ctx = MF->getFunction()->getContext();
           Ctx.emitError("Ran out of VGPRs for spilling SGPR");
        }

        BuildMI(*MBB, MI, DL, TII->get(AMDGPU::V_WRITELANE_B32), Spill.VGPR)
                .addReg(SubReg)
                .addImm(Spill.Lane);

      }
      MI->eraseFromParent();
      break;
    }

    // SGPR register restore
    case AMDGPU::SI_SPILL_S512_RESTORE:
    case AMDGPU::SI_SPILL_S256_RESTORE:
    case AMDGPU::SI_SPILL_S128_RESTORE:
    case AMDGPU::SI_SPILL_S64_RESTORE:
    case AMDGPU::SI_SPILL_S32_RESTORE: {
      unsigned NumSubRegs = getNumSubRegsForSpillOp(MI->getOpcode());

      for (unsigned i = 0, e = NumSubRegs; i < e; ++i) {
        unsigned SubReg = getPhysRegSubReg(MI->getOperand(0).getReg(),
                                           &AMDGPU::SGPR_32RegClass, i);
        bool isM0 = SubReg == AMDGPU::M0;
        struct SIMachineFunctionInfo::SpilledReg Spill =
            MFI->getSpilledReg(MF, Index, i);

        if (Spill.VGPR == AMDGPU::NoRegister) {
           LLVMContext &Ctx = MF->getFunction()->getContext();
           Ctx.emitError("Ran out of VGPRs for spilling SGPR");
        }

        if (isM0) {
          SubReg = RS->scavengeRegister(&AMDGPU::SGPR_32RegClass, MI, 0);
        }

        BuildMI(*MBB, MI, DL, TII->get(AMDGPU::V_READLANE_B32), SubReg)
                .addReg(Spill.VGPR)
                .addImm(Spill.Lane);
        if (isM0) {
          BuildMI(*MBB, MI, DL, TII->get(AMDGPU::S_MOV_B32), AMDGPU::M0)
                  .addReg(SubReg);
        }
      }
      TII->insertNOPs(MI, 3);
      MI->eraseFromParent();
      break;
    }

    // VGPR register spill
    case AMDGPU::SI_SPILL_V512_SAVE:
    case AMDGPU::SI_SPILL_V256_SAVE:
    case AMDGPU::SI_SPILL_V128_SAVE:
    case AMDGPU::SI_SPILL_V96_SAVE:
    case AMDGPU::SI_SPILL_V64_SAVE:
    case AMDGPU::SI_SPILL_V32_SAVE: {
      unsigned NumSubRegs = getNumSubRegsForSpillOp(MI->getOpcode());
      unsigned SrcReg = MI->getOperand(0).getReg();
      int64_t Offset = FrameInfo->getObjectOffset(Index);
      unsigned Size = NumSubRegs * 4;
      unsigned TmpReg = RS->scavengeRegister(&AMDGPU::VGPR_32RegClass, MI, 0);

      for (unsigned i = 0, e = NumSubRegs; i != e; ++i) {
        unsigned SubReg = NumSubRegs > 1 ?
            getPhysRegSubReg(SrcReg, &AMDGPU::VGPR_32RegClass, i) :
            SrcReg;
        Offset += (i * 4);
        MFI->LDSWaveSpillSize = std::max((unsigned)Offset + 4, (unsigned)MFI->LDSWaveSpillSize);

        unsigned AddrReg = TII->calculateLDSSpillAddress(*MBB, MI, RS, TmpReg,
                                                         Offset, Size);

        if (AddrReg == AMDGPU::NoRegister) {
           LLVMContext &Ctx = MF->getFunction()->getContext();
           Ctx.emitError("Ran out of VGPRs for spilling VGPRS");
           AddrReg = AMDGPU::VGPR0;
        }

        // Store the value in LDS
        BuildMI(*MBB, MI, DL, TII->get(AMDGPU::DS_WRITE_B32))
                .addImm(0) // gds
                .addReg(AddrReg, RegState::Kill) // addr
                .addReg(SubReg) // data0
                .addImm(0); // offset
      }

      MI->eraseFromParent();
      break;
    }
    case AMDGPU::SI_SPILL_V32_RESTORE:
    case AMDGPU::SI_SPILL_V64_RESTORE:
    case AMDGPU::SI_SPILL_V128_RESTORE:
    case AMDGPU::SI_SPILL_V256_RESTORE:
    case AMDGPU::SI_SPILL_V512_RESTORE: {
      unsigned NumSubRegs = getNumSubRegsForSpillOp(MI->getOpcode());
      unsigned DstReg = MI->getOperand(0).getReg();
      int64_t Offset = FrameInfo->getObjectOffset(Index);
      unsigned Size = NumSubRegs * 4;
      unsigned TmpReg = RS->scavengeRegister(&AMDGPU::VGPR_32RegClass, MI, 0);

      // FIXME: We could use DS_READ_B64 here to optimize for larger registers.
      for (unsigned i = 0, e = NumSubRegs; i != e; ++i) {
        unsigned SubReg = NumSubRegs > 1 ?
            getPhysRegSubReg(DstReg, &AMDGPU::VGPR_32RegClass, i) :
            DstReg;

        Offset += (i * 4);
        unsigned AddrReg = TII->calculateLDSSpillAddress(*MBB, MI, RS, TmpReg,
                                                          Offset, Size);
        if (AddrReg == AMDGPU::NoRegister) {
           LLVMContext &Ctx = MF->getFunction()->getContext();
           Ctx.emitError("Ran out of VGPRs for spilling VGPRs");
           AddrReg = AMDGPU::VGPR0;
        }

        BuildMI(*MBB, MI, DL, TII->get(AMDGPU::DS_READ_B32), SubReg)
                .addImm(0) // gds
                .addReg(AddrReg, RegState::Kill) // addr
                .addImm(0); //offset
      }
      MI->eraseFromParent();
      break;
    }

    default: {
      int64_t Offset = FrameInfo->getObjectOffset(Index);
      FIOp.ChangeToImmediate(Offset);
      if (!TII->isImmOperandLegal(MI, FIOperandNum, FIOp)) {
        unsigned TmpReg = RS->scavengeRegister(&AMDGPU::VReg_32RegClass, MI, SPAdj);
        BuildMI(*MBB, MI, MI->getDebugLoc(),
                TII->get(AMDGPU::V_MOV_B32_e32), TmpReg)
                .addImm(Offset);
        FIOp.ChangeToRegister(TmpReg, false);
      }
    }
  }
}

const TargetRegisterClass * SIRegisterInfo::getCFGStructurizerRegClass(
                                                                   MVT VT) const {
  switch(VT.SimpleTy) {
    default:
    case MVT::i32: return &AMDGPU::VReg_32RegClass;
  }
}

unsigned SIRegisterInfo::getHWRegIndex(unsigned Reg) const {
  return getEncodingValue(Reg) & 0xff;
}

const TargetRegisterClass *SIRegisterInfo::getPhysRegClass(unsigned Reg) const {
  assert(!TargetRegisterInfo::isVirtualRegister(Reg));

  static const TargetRegisterClass *BaseClasses[] = {
    &AMDGPU::VReg_32RegClass,
    &AMDGPU::SReg_32RegClass,
    &AMDGPU::VReg_64RegClass,
    &AMDGPU::SReg_64RegClass,
    &AMDGPU::VReg_96RegClass,
    &AMDGPU::VReg_128RegClass,
    &AMDGPU::SReg_128RegClass,
    &AMDGPU::VReg_256RegClass,
    &AMDGPU::SReg_256RegClass,
    &AMDGPU::VReg_512RegClass
  };

  for (const TargetRegisterClass *BaseClass : BaseClasses) {
    if (BaseClass->contains(Reg)) {
      return BaseClass;
    }
  }
  return nullptr;
}

bool SIRegisterInfo::hasVGPRs(const TargetRegisterClass *RC) const {
  return getCommonSubClass(&AMDGPU::VReg_32RegClass, RC) ||
         getCommonSubClass(&AMDGPU::VReg_64RegClass, RC) ||
         getCommonSubClass(&AMDGPU::VReg_96RegClass, RC) ||
         getCommonSubClass(&AMDGPU::VReg_128RegClass, RC) ||
         getCommonSubClass(&AMDGPU::VReg_256RegClass, RC) ||
         getCommonSubClass(&AMDGPU::VReg_512RegClass, RC);
}

const TargetRegisterClass *SIRegisterInfo::getEquivalentVGPRClass(
                                         const TargetRegisterClass *SRC) const {
    if (hasVGPRs(SRC)) {
      return SRC;
    } else if (SRC == &AMDGPU::SCCRegRegClass) {
      return &AMDGPU::VCCRegRegClass;
    } else if (getCommonSubClass(SRC, &AMDGPU::SGPR_32RegClass)) {
      return &AMDGPU::VReg_32RegClass;
    } else if (getCommonSubClass(SRC, &AMDGPU::SGPR_64RegClass)) {
      return &AMDGPU::VReg_64RegClass;
    } else if (getCommonSubClass(SRC, &AMDGPU::SReg_128RegClass)) {
      return &AMDGPU::VReg_128RegClass;
    } else if (getCommonSubClass(SRC, &AMDGPU::SReg_256RegClass)) {
      return &AMDGPU::VReg_256RegClass;
    } else if (getCommonSubClass(SRC, &AMDGPU::SReg_512RegClass)) {
      return &AMDGPU::VReg_512RegClass;
    }
    return nullptr;
}

const TargetRegisterClass *SIRegisterInfo::getSubRegClass(
                         const TargetRegisterClass *RC, unsigned SubIdx) const {
  if (SubIdx == AMDGPU::NoSubRegister)
    return RC;

  // If this register has a sub-register, we can safely assume it is a 32-bit
  // register, because all of SI's sub-registers are 32-bit.
  if (isSGPRClass(RC)) {
    return &AMDGPU::SGPR_32RegClass;
  } else {
    return &AMDGPU::VGPR_32RegClass;
  }
}

unsigned SIRegisterInfo::getPhysRegSubReg(unsigned Reg,
                                          const TargetRegisterClass *SubRC,
                                          unsigned Channel) const {

  switch (Reg) {
    case AMDGPU::VCC:
      switch(Channel) {
        case 0: return AMDGPU::VCC_LO;
        case 1: return AMDGPU::VCC_HI;
        default: llvm_unreachable("Invalid SubIdx for VCC");
      }

  case AMDGPU::FLAT_SCR:
    switch (Channel) {
    case 0:
      return AMDGPU::FLAT_SCR_LO;
    case 1:
      return AMDGPU::FLAT_SCR_HI;
    default:
      llvm_unreachable("Invalid SubIdx for FLAT_SCR");
    }
    break;

  case AMDGPU::EXEC:
    switch (Channel) {
    case 0:
      return AMDGPU::EXEC_LO;
    case 1:
      return AMDGPU::EXEC_HI;
    default:
      llvm_unreachable("Invalid SubIdx for EXEC");
    }
    break;
  }

  const TargetRegisterClass *RC = getPhysRegClass(Reg);
  // 32-bit registers don't have sub-registers, so we can just return the
  // Reg.  We need to have this check here, because the calculation below
  // using getHWRegIndex() will fail with special 32-bit registers like
  // VCC_LO, VCC_HI, EXEC_LO, EXEC_HI and M0.
  if (RC->getSize() == 4) {
    assert(Channel == 0);
    return Reg;
  }

  unsigned Index = getHWRegIndex(Reg);
  return SubRC->getRegister(Index + Channel);
}

bool SIRegisterInfo::regClassCanUseLiteralConstant(int RCID) const {
  switch (RCID) {
  default: return false;
  case AMDGPU::SSrc_32RegClassID:
  case AMDGPU::SSrc_64RegClassID:
  case AMDGPU::VSrc_32RegClassID:
  case AMDGPU::VSrc_64RegClassID:
    return true;
  }
}

bool SIRegisterInfo::regClassCanUseLiteralConstant(
                             const TargetRegisterClass *RC) const {
  return regClassCanUseLiteralConstant(RC->getID());
}

bool SIRegisterInfo::regClassCanUseInlineConstant(int RCID) const {
  if (regClassCanUseLiteralConstant(RCID))
    return true;

  switch (RCID) {
  default: return false;
  case AMDGPU::VCSrc_32RegClassID:
  case AMDGPU::VCSrc_64RegClassID:
    return true;
  }
}

bool SIRegisterInfo::regClassCanUseInlineConstant(
                            const TargetRegisterClass *RC) const {
  return regClassCanUseInlineConstant(RC->getID());
}


unsigned SIRegisterInfo::getPreloadedValue(const MachineFunction &MF,
                                           enum PreloadedValue Value) const {

  const SIMachineFunctionInfo *MFI = MF.getInfo<SIMachineFunctionInfo>();
  switch (Value) {
  case SIRegisterInfo::TGID_X:
    return AMDGPU::SReg_32RegClass.getRegister(MFI->NumUserSGPRs + 0);
  case SIRegisterInfo::TGID_Y:
    return AMDGPU::SReg_32RegClass.getRegister(MFI->NumUserSGPRs + 1);
  case SIRegisterInfo::TGID_Z:
    return AMDGPU::SReg_32RegClass.getRegister(MFI->NumUserSGPRs + 2);
  case SIRegisterInfo::SCRATCH_WAVE_OFFSET:
    return AMDGPU::SReg_32RegClass.getRegister(MFI->NumUserSGPRs + 4);
  case SIRegisterInfo::SCRATCH_PTR:
    return AMDGPU::SGPR2_SGPR3;
  case SIRegisterInfo::INPUT_PTR:
    return AMDGPU::SGPR0_SGPR1;
  case SIRegisterInfo::TIDIG_X:
    return AMDGPU::VGPR0;
  case SIRegisterInfo::TIDIG_Y:
    return AMDGPU::VGPR1;
  case SIRegisterInfo::TIDIG_Z:
    return AMDGPU::VGPR2;
  }
  llvm_unreachable("unexpected preloaded value type");
}

/// \brief Returns a register that is not used at any point in the function.
///        If all registers are used, then this function will return
//         AMDGPU::NoRegister.
unsigned SIRegisterInfo::findUnusedVGPR(const MachineRegisterInfo &MRI) const {

  const TargetRegisterClass *RC = &AMDGPU::VGPR_32RegClass;

  for (TargetRegisterClass::iterator I = RC->begin(), E = RC->end();
       I != E; ++I) {
    if (!MRI.isPhysRegUsed(*I))
      return *I;
  }
  return AMDGPU::NoRegister;
}

