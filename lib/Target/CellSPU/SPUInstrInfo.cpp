//===- SPUInstrInfo.cpp - Cell SPU Instruction Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Cell SPU implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "SPURegisterNames.h"
#include "SPUInstrInfo.h"
#include "SPUInstrBuilder.h"
#include "SPUTargetMachine.h"
#include "SPUGenInstrInfo.inc"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include <iostream>

using namespace llvm;

SPUInstrInfo::SPUInstrInfo(SPUTargetMachine &tm)
  : TargetInstrInfoImpl(SPUInsts, sizeof(SPUInsts)/sizeof(SPUInsts[0])),
    TM(tm),
    RI(*TM.getSubtargetImpl(), *this)
{
  /* NOP */
}

/// getPointerRegClass - Return the register class to use to hold pointers.
/// This is used for addressing modes.
const TargetRegisterClass *
SPUInstrInfo::getPointerRegClass() const
{
  return &SPU::R32CRegClass;
}

bool
SPUInstrInfo::isMoveInstr(const MachineInstr& MI,
                          unsigned& sourceReg,
                          unsigned& destReg) const {
  // Primarily, ORI and OR are generated by copyRegToReg. But, there are other
  // cases where we can safely say that what's being done is really a move
  // (see how PowerPC does this -- it's the model for this code too.)
  switch (MI.getOpcode()) {
  default:
    break;
  case SPU::ORIv4i32:
  case SPU::ORIr32:
  case SPU::ORHIv8i16:
  case SPU::ORHIr16:
  case SPU::ORHIi8i16:
  case SPU::ORBIv16i8:
  case SPU::ORBIr8:
  case SPU::ORIi16i32:
  case SPU::ORIi8i32:
  case SPU::AHIvec:
  case SPU::AHIr16:
  case SPU::AIvec:
    assert(MI.getNumOperands() == 3 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           MI.getOperand(2).isImmediate() &&
           "invalid SPU ORI/ORHI/ORBI/AHI/AI/SFI/SFHI instruction!");
    if (MI.getOperand(2).getImm() == 0) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
    break;
  case SPU::AIr32:
    assert(MI.getNumOperands() == 3 &&
           "wrong number of operands to AIr32");
    if (MI.getOperand(0).isRegister() &&
        (MI.getOperand(1).isRegister() ||
         MI.getOperand(1).isFrameIndex()) &&
        (MI.getOperand(2).isImmediate() &&
         MI.getOperand(2).getImm() == 0)) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
    break;
  case SPU::ORv16i8_i8:
  case SPU::ORv8i16_i16:
  case SPU::ORv4i32_i32:
  case SPU::ORv2i64_i64:
  case SPU::ORv4f32_f32:
  case SPU::ORv2f64_f64:
  case SPU::ORi8_v16i8:
  case SPU::ORi16_v8i16:
  case SPU::ORi32_v4i32:
  case SPU::ORi64_v2i64:
  case SPU::ORf32_v4f32:
  case SPU::ORf64_v2f64:
  case SPU::ORv16i8:
  case SPU::ORv8i16:
  case SPU::ORv4i32:
  case SPU::ORr32:
  case SPU::ORr64:
  case SPU::ORf32:
  case SPU::ORf64:
    assert(MI.getNumOperands() == 3 &&
           MI.getOperand(0).isRegister() &&
           MI.getOperand(1).isRegister() &&
           MI.getOperand(2).isRegister() &&
           "invalid SPU OR(vec|r32|r64|gprc) instruction!");
    if (MI.getOperand(1).getReg() == MI.getOperand(2).getReg()) {
      sourceReg = MI.getOperand(1).getReg();
      destReg = MI.getOperand(0).getReg();
      return true;
    }
    break;
  }

  return false;
}

unsigned
SPUInstrInfo::isLoadFromStackSlot(MachineInstr *MI, int &FrameIndex) const {
  switch (MI->getOpcode()) {
  default: break;
  case SPU::LQDv16i8:
  case SPU::LQDv8i16:
  case SPU::LQDv4i32:
  case SPU::LQDv4f32:
  case SPU::LQDv2f64:
  case SPU::LQDr128:
  case SPU::LQDr64:
  case SPU::LQDr32:
  case SPU::LQDr16:
  case SPU::LQXv4i32:
  case SPU::LQXr128:
  case SPU::LQXr64:
  case SPU::LQXr32:
  case SPU::LQXr16:
    if (MI->getOperand(1).isImmediate() && !MI->getOperand(1).getImm() &&
        MI->getOperand(2).isFrameIndex()) {
      FrameIndex = MI->getOperand(2).getIndex();
      return MI->getOperand(0).getReg();
    }
    break;
  }
  return 0;
}

unsigned
SPUInstrInfo::isStoreToStackSlot(MachineInstr *MI, int &FrameIndex) const {
  switch (MI->getOpcode()) {
  default: break;
  case SPU::STQDv16i8:
  case SPU::STQDv8i16:
  case SPU::STQDv4i32:
  case SPU::STQDv4f32:
  case SPU::STQDv2f64:
  case SPU::STQDr128:
  case SPU::STQDr64:
  case SPU::STQDr32:
  case SPU::STQDr16:
    // case SPU::STQDr8:
  case SPU::STQXv16i8:
  case SPU::STQXv8i16:
  case SPU::STQXv4i32:
  case SPU::STQXv4f32:
  case SPU::STQXv2f64:
  case SPU::STQXr128:
  case SPU::STQXr64:
  case SPU::STQXr32:
  case SPU::STQXr16:
    // case SPU::STQXr8:
    if (MI->getOperand(1).isImmediate() && !MI->getOperand(1).getImm() &&
        MI->getOperand(2).isFrameIndex()) {
      FrameIndex = MI->getOperand(2).getIndex();
      return MI->getOperand(0).getReg();
    }
    break;
  }
  return 0;
}

void SPUInstrInfo::copyRegToReg(MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MI,
                                   unsigned DestReg, unsigned SrcReg,
                                   const TargetRegisterClass *DestRC,
                                   const TargetRegisterClass *SrcRC) const
{
  if (DestRC != SrcRC) {
    cerr << "SPUInstrInfo::copyRegToReg(): DestRC != SrcRC not supported!\n";
    abort();
  }

  if (DestRC == SPU::R8CRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORBIr8), DestReg).addReg(SrcReg).addImm(0);
  } else if (DestRC == SPU::R16CRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORHIr16), DestReg).addReg(SrcReg).addImm(0);
  } else if (DestRC == SPU::R32CRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORIr32), DestReg).addReg(SrcReg).addImm(0);
  } else if (DestRC == SPU::R32FPRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORf32), DestReg).addReg(SrcReg)
      .addReg(SrcReg);
  } else if (DestRC == SPU::R64CRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORr64), DestReg).addReg(SrcReg)
      .addReg(SrcReg);
  } else if (DestRC == SPU::R64FPRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORf64), DestReg).addReg(SrcReg)
      .addReg(SrcReg);
  } /* else if (DestRC == SPU::GPRCRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORgprc), DestReg).addReg(SrcReg)
      .addReg(SrcReg);
  } */ else if (DestRC == SPU::VECREGRegisterClass) {
    BuildMI(MBB, MI, get(SPU::ORv4i32), DestReg).addReg(SrcReg)
      .addReg(SrcReg);
  } else {
    std::cerr << "Attempt to copy unknown/unsupported register class!\n";
    abort();
  }
}

void
SPUInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MI,
                                     unsigned SrcReg, bool isKill, int FrameIdx,
                                     const TargetRegisterClass *RC) const
{
  unsigned opc;
  if (RC == SPU::GPRCRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::STQDr128
      : SPU::STQXr128;
  } else if (RC == SPU::R64CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::STQDr64
      : SPU::STQXr64;
  } else if (RC == SPU::R64FPRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::STQDr64
      : SPU::STQXr64;
  } else if (RC == SPU::R32CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::STQDr32
      : SPU::STQXr32;
  } else if (RC == SPU::R32FPRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::STQDr32
      : SPU::STQXr32;
  } else if (RC == SPU::R16CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset()) ?
      SPU::STQDr16
      : SPU::STQXr16;
  } else {
    assert(0 && "Unknown regclass!");
    abort();
  }

  addFrameReference(BuildMI(MBB, MI, get(opc))
                    .addReg(SrcReg, false, false, isKill), FrameIdx);
}

void SPUInstrInfo::storeRegToAddr(MachineFunction &MF, unsigned SrcReg,
                                     bool isKill,
                                     SmallVectorImpl<MachineOperand> &Addr,
                                     const TargetRegisterClass *RC,
                                     SmallVectorImpl<MachineInstr*> &NewMIs) const {
  cerr << "storeRegToAddr() invoked!\n";
  abort();

  if (Addr[0].isFrameIndex()) {
    /* do what storeRegToStackSlot does here */
  } else {
    unsigned Opc = 0;
    if (RC == SPU::GPRCRegisterClass) {
      /* Opc = PPC::STW; */
    } else if (RC == SPU::R16CRegisterClass) {
      /* Opc = PPC::STD; */
    } else if (RC == SPU::R32CRegisterClass) {
      /* Opc = PPC::STFD; */
    } else if (RC == SPU::R32FPRegisterClass) {
      /* Opc = PPC::STFD; */
    } else if (RC == SPU::R64FPRegisterClass) {
      /* Opc = PPC::STFS; */
    } else if (RC == SPU::VECREGRegisterClass) {
      /* Opc = PPC::STVX; */
    } else {
      assert(0 && "Unknown regclass!");
      abort();
    }
    MachineInstrBuilder MIB = BuildMI(get(Opc))
      .addReg(SrcReg, false, false, isKill);
    for (unsigned i = 0, e = Addr.size(); i != e; ++i) {
      MachineOperand &MO = Addr[i];
      if (MO.isRegister())
        MIB.addReg(MO.getReg());
      else if (MO.isImmediate())
        MIB.addImm(MO.getImm());
      else
        MIB.addFrameIndex(MO.getIndex());
    }
    NewMIs.push_back(MIB);
  }
}

void
SPUInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator MI,
                                        unsigned DestReg, int FrameIdx,
                                        const TargetRegisterClass *RC) const
{
  unsigned opc;
  if (RC == SPU::GPRCRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr128
      : SPU::LQXr128;
  } else if (RC == SPU::R64CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr64
      : SPU::LQXr64;
  } else if (RC == SPU::R64FPRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr64
      : SPU::LQXr64;
  } else if (RC == SPU::R32CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr32
      : SPU::LQXr32;
  } else if (RC == SPU::R32FPRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr32
      : SPU::LQXr32;
  } else if (RC == SPU::R16CRegisterClass) {
    opc = (FrameIdx < SPUFrameInfo::maxFrameOffset())
      ? SPU::LQDr16
      : SPU::LQXr16;
  } else {
    assert(0 && "Unknown regclass in loadRegFromStackSlot!");
    abort();
  }

  addFrameReference(BuildMI(MBB, MI, get(opc)).addReg(DestReg), FrameIdx);
}

/*!
  \note We are really pessimistic here about what kind of a load we're doing.
 */
void SPUInstrInfo::loadRegFromAddr(MachineFunction &MF, unsigned DestReg,
                                      SmallVectorImpl<MachineOperand> &Addr,
                                      const TargetRegisterClass *RC,
                                      SmallVectorImpl<MachineInstr*> &NewMIs)
    const {
  cerr << "loadRegToAddr() invoked!\n";
  abort();

  if (Addr[0].isFrameIndex()) {
    /* do what loadRegFromStackSlot does here... */
  } else {
    unsigned Opc = 0;
    if (RC == SPU::R8CRegisterClass) {
      /* do brilliance here */
    } else if (RC == SPU::R16CRegisterClass) {
      /* Opc = PPC::LWZ; */
    } else if (RC == SPU::R32CRegisterClass) {
      /* Opc = PPC::LD; */
    } else if (RC == SPU::R32FPRegisterClass) {
      /* Opc = PPC::LFD; */
    } else if (RC == SPU::R64FPRegisterClass) {
      /* Opc = PPC::LFS; */
    } else if (RC == SPU::VECREGRegisterClass) {
      /* Opc = PPC::LVX; */
    } else if (RC == SPU::GPRCRegisterClass) {
      /* Opc = something else! */
    } else {
      assert(0 && "Unknown regclass!");
      abort();
    }
    MachineInstrBuilder MIB = BuildMI(get(Opc), DestReg);
    for (unsigned i = 0, e = Addr.size(); i != e; ++i) {
      MachineOperand &MO = Addr[i];
      if (MO.isRegister())
        MIB.addReg(MO.getReg());
      else if (MO.isImmediate())
        MIB.addImm(MO.getImm());
      else
        MIB.addFrameIndex(MO.getIndex());
    }
    NewMIs.push_back(MIB);
  }
}

/// foldMemoryOperand - SPU, like PPC, can only fold spills into
/// copy instructions, turning them into load/store instructions.
MachineInstr *
SPUInstrInfo::foldMemoryOperand(MachineFunction &MF,
                                MachineInstr *MI,
                                SmallVectorImpl<unsigned> &Ops,
                                int FrameIndex) const
{
#if SOMEDAY_SCOTT_LOOKS_AT_ME_AGAIN
  if (Ops.size() != 1) return NULL;

  unsigned OpNum = Ops[0];
  unsigned Opc = MI->getOpcode();
  MachineInstr *NewMI = 0;
  
  if ((Opc == SPU::ORr32
       || Opc == SPU::ORv4i32)
       && MI->getOperand(1).getReg() == MI->getOperand(2).getReg()) {
    if (OpNum == 0) {  // move -> store
      unsigned InReg = MI->getOperand(1).getReg();
      if (FrameIndex < SPUFrameInfo::maxFrameOffset()) {
        NewMI = addFrameReference(BuildMI(TII.get(SPU::STQDr32)).addReg(InReg),
                                  FrameIndex);
      }
    } else {           // move -> load
      unsigned OutReg = MI->getOperand(0).getReg();
      Opc = (FrameIndex < SPUFrameInfo::maxFrameOffset()) ? SPU::STQDr32 : SPU::STQXr32;
      NewMI = addFrameReference(BuildMI(TII.get(Opc), OutReg), FrameIndex);
    }
  }

  if (NewMI)
    NewMI->copyKillDeadInfo(MI);

  return NewMI;
#else
  return 0;
#endif
}

