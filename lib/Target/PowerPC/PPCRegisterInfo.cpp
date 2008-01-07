//===- PPCRegisterInfo.cpp - PowerPC Register Information -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the PowerPC implementation of the MRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "reginfo"
#include "PPC.h"
#include "PPCInstrBuilder.h"
#include "PPCMachineFunctionInfo.h"
#include "PPCRegisterInfo.h"
#include "PPCFrameInfo.h"
#include "PPCSubtarget.h"
#include "llvm/Constants.h"
#include "llvm/Type.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineLocation.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/Target/TargetFrameInfo.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include <cstdlib>
using namespace llvm;

/// getRegisterNumbering - Given the enum value for some register, e.g.
/// PPC::F14, return the number that it corresponds to (e.g. 14).
unsigned PPCRegisterInfo::getRegisterNumbering(unsigned RegEnum) {
  using namespace PPC;
  switch (RegEnum) {
  case R0 :  case X0 :  case F0 :  case V0 : case CR0:  return  0;
  case R1 :  case X1 :  case F1 :  case V1 : case CR1:  return  1;
  case R2 :  case X2 :  case F2 :  case V2 : case CR2:  return  2;
  case R3 :  case X3 :  case F3 :  case V3 : case CR3:  return  3;
  case R4 :  case X4 :  case F4 :  case V4 : case CR4:  return  4;
  case R5 :  case X5 :  case F5 :  case V5 : case CR5:  return  5;
  case R6 :  case X6 :  case F6 :  case V6 : case CR6:  return  6;
  case R7 :  case X7 :  case F7 :  case V7 : case CR7:  return  7;
  case R8 :  case X8 :  case F8 :  case V8 : return  8;
  case R9 :  case X9 :  case F9 :  case V9 : return  9;
  case R10:  case X10:  case F10:  case V10: return 10;
  case R11:  case X11:  case F11:  case V11: return 11;
  case R12:  case X12:  case F12:  case V12: return 12;
  case R13:  case X13:  case F13:  case V13: return 13;
  case R14:  case X14:  case F14:  case V14: return 14;
  case R15:  case X15:  case F15:  case V15: return 15;
  case R16:  case X16:  case F16:  case V16: return 16;
  case R17:  case X17:  case F17:  case V17: return 17;
  case R18:  case X18:  case F18:  case V18: return 18;
  case R19:  case X19:  case F19:  case V19: return 19;
  case R20:  case X20:  case F20:  case V20: return 20;
  case R21:  case X21:  case F21:  case V21: return 21;
  case R22:  case X22:  case F22:  case V22: return 22;
  case R23:  case X23:  case F23:  case V23: return 23;
  case R24:  case X24:  case F24:  case V24: return 24;
  case R25:  case X25:  case F25:  case V25: return 25;
  case R26:  case X26:  case F26:  case V26: return 26;
  case R27:  case X27:  case F27:  case V27: return 27;
  case R28:  case X28:  case F28:  case V28: return 28;
  case R29:  case X29:  case F29:  case V29: return 29;
  case R30:  case X30:  case F30:  case V30: return 30;
  case R31:  case X31:  case F31:  case V31: return 31;
  default:
    cerr << "Unhandled reg in PPCRegisterInfo::getRegisterNumbering!\n";
    abort();
  }
}

PPCRegisterInfo::PPCRegisterInfo(const PPCSubtarget &ST,
                                 const TargetInstrInfo &tii)
  : PPCGenRegisterInfo(PPC::ADJCALLSTACKDOWN, PPC::ADJCALLSTACKUP),
    Subtarget(ST), TII(tii) {
  ImmToIdxMap[PPC::LD]   = PPC::LDX;    ImmToIdxMap[PPC::STD]  = PPC::STDX;
  ImmToIdxMap[PPC::LBZ]  = PPC::LBZX;   ImmToIdxMap[PPC::STB]  = PPC::STBX;
  ImmToIdxMap[PPC::LHZ]  = PPC::LHZX;   ImmToIdxMap[PPC::LHA]  = PPC::LHAX;
  ImmToIdxMap[PPC::LWZ]  = PPC::LWZX;   ImmToIdxMap[PPC::LWA]  = PPC::LWAX;
  ImmToIdxMap[PPC::LFS]  = PPC::LFSX;   ImmToIdxMap[PPC::LFD]  = PPC::LFDX;
  ImmToIdxMap[PPC::STH]  = PPC::STHX;   ImmToIdxMap[PPC::STW]  = PPC::STWX;
  ImmToIdxMap[PPC::STFS] = PPC::STFSX;  ImmToIdxMap[PPC::STFD] = PPC::STFDX;
  ImmToIdxMap[PPC::ADDI] = PPC::ADD4;

  // 64-bit
  ImmToIdxMap[PPC::LHA8] = PPC::LHAX8; ImmToIdxMap[PPC::LBZ8] = PPC::LBZX8;
  ImmToIdxMap[PPC::LHZ8] = PPC::LHZX8; ImmToIdxMap[PPC::LWZ8] = PPC::LWZX8;
  ImmToIdxMap[PPC::STB8] = PPC::STBX8; ImmToIdxMap[PPC::STH8] = PPC::STHX8;
  ImmToIdxMap[PPC::STW8] = PPC::STWX8; ImmToIdxMap[PPC::STDU] = PPC::STDUX;
  ImmToIdxMap[PPC::ADDI8] = PPC::ADD8; ImmToIdxMap[PPC::STD_32] = PPC::STDX_32;
}

void PPCRegisterInfo::reMaterialize(MachineBasicBlock &MBB,
                                    MachineBasicBlock::iterator I,
                                    unsigned DestReg,
                                    const MachineInstr *Orig) const {
  MachineInstr *MI = Orig->clone();
  MI->getOperand(0).setReg(DestReg);
  MBB.insert(I, MI);
}

const unsigned*
PPCRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  // 32-bit Darwin calling convention. 
  static const unsigned Macho32_CalleeSavedRegs[] = {
              PPC::R13, PPC::R14, PPC::R15,
    PPC::R16, PPC::R17, PPC::R18, PPC::R19,
    PPC::R20, PPC::R21, PPC::R22, PPC::R23,
    PPC::R24, PPC::R25, PPC::R26, PPC::R27,
    PPC::R28, PPC::R29, PPC::R30, PPC::R31,

    PPC::F14, PPC::F15, PPC::F16, PPC::F17,
    PPC::F18, PPC::F19, PPC::F20, PPC::F21,
    PPC::F22, PPC::F23, PPC::F24, PPC::F25,
    PPC::F26, PPC::F27, PPC::F28, PPC::F29,
    PPC::F30, PPC::F31,
    
    PPC::CR2, PPC::CR3, PPC::CR4,
    PPC::V20, PPC::V21, PPC::V22, PPC::V23,
    PPC::V24, PPC::V25, PPC::V26, PPC::V27,
    PPC::V28, PPC::V29, PPC::V30, PPC::V31,
    
    PPC::LR,  0
  };
  
  static const unsigned ELF32_CalleeSavedRegs[] = {
              PPC::R13, PPC::R14, PPC::R15,
    PPC::R16, PPC::R17, PPC::R18, PPC::R19,
    PPC::R20, PPC::R21, PPC::R22, PPC::R23,
    PPC::R24, PPC::R25, PPC::R26, PPC::R27,
    PPC::R28, PPC::R29, PPC::R30, PPC::R31,

                                  PPC::F9,
    PPC::F10, PPC::F11, PPC::F12, PPC::F13,
    PPC::F14, PPC::F15, PPC::F16, PPC::F17,
    PPC::F18, PPC::F19, PPC::F20, PPC::F21,
    PPC::F22, PPC::F23, PPC::F24, PPC::F25,
    PPC::F26, PPC::F27, PPC::F28, PPC::F29,
    PPC::F30, PPC::F31,
    
    PPC::CR2, PPC::CR3, PPC::CR4,
    PPC::V20, PPC::V21, PPC::V22, PPC::V23,
    PPC::V24, PPC::V25, PPC::V26, PPC::V27,
    PPC::V28, PPC::V29, PPC::V30, PPC::V31,
    
    PPC::LR,  0
  };
  // 64-bit Darwin calling convention. 
  static const unsigned Macho64_CalleeSavedRegs[] = {
    PPC::X14, PPC::X15,
    PPC::X16, PPC::X17, PPC::X18, PPC::X19,
    PPC::X20, PPC::X21, PPC::X22, PPC::X23,
    PPC::X24, PPC::X25, PPC::X26, PPC::X27,
    PPC::X28, PPC::X29, PPC::X30, PPC::X31,
    
    PPC::F14, PPC::F15, PPC::F16, PPC::F17,
    PPC::F18, PPC::F19, PPC::F20, PPC::F21,
    PPC::F22, PPC::F23, PPC::F24, PPC::F25,
    PPC::F26, PPC::F27, PPC::F28, PPC::F29,
    PPC::F30, PPC::F31,
    
    PPC::CR2, PPC::CR3, PPC::CR4,
    PPC::V20, PPC::V21, PPC::V22, PPC::V23,
    PPC::V24, PPC::V25, PPC::V26, PPC::V27,
    PPC::V28, PPC::V29, PPC::V30, PPC::V31,
    
    PPC::LR8,  0
  };
  
  if (Subtarget.isMachoABI())
    return Subtarget.isPPC64() ? Macho64_CalleeSavedRegs :
                                 Macho32_CalleeSavedRegs;
  
  // ELF 32.
  return ELF32_CalleeSavedRegs;
}

const TargetRegisterClass* const*
PPCRegisterInfo::getCalleeSavedRegClasses(const MachineFunction *MF) const {
  // 32-bit Macho calling convention. 
  static const TargetRegisterClass * const Macho32_CalleeSavedRegClasses[] = {
                       &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,

    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,
    
    &PPC::CRRCRegClass,&PPC::CRRCRegClass,&PPC::CRRCRegClass,
    
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    
    &PPC::GPRCRegClass, 0
  };
  
  static const TargetRegisterClass * const ELF32_CalleeSavedRegClasses[] = {
                       &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,
    &PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,&PPC::GPRCRegClass,

                                                             &PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,
    
    &PPC::CRRCRegClass,&PPC::CRRCRegClass,&PPC::CRRCRegClass,
    
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    
    &PPC::GPRCRegClass, 0
  };
  
  // 64-bit Macho calling convention. 
  static const TargetRegisterClass * const Macho64_CalleeSavedRegClasses[] = {
    &PPC::G8RCRegClass,&PPC::G8RCRegClass,
    &PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,
    &PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,
    &PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,
    &PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,&PPC::G8RCRegClass,
    
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,&PPC::F8RCRegClass,
    &PPC::F8RCRegClass,&PPC::F8RCRegClass,
    
    &PPC::CRRCRegClass,&PPC::CRRCRegClass,&PPC::CRRCRegClass,
    
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    &PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,&PPC::VRRCRegClass,
    
    &PPC::G8RCRegClass, 0
  };
  
  if (Subtarget.isMachoABI())
    return Subtarget.isPPC64() ? Macho64_CalleeSavedRegClasses :
                                 Macho32_CalleeSavedRegClasses;
  
  // ELF 32.
  return ELF32_CalleeSavedRegClasses;
}

// needsFP - Return true if the specified function should have a dedicated frame
// pointer register.  This is true if the function has variable sized allocas or
// if frame pointer elimination is disabled.
//
static bool needsFP(const MachineFunction &MF) {
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  return NoFramePointerElim || MFI->hasVarSizedObjects();
}

BitVector PPCRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  Reserved.set(PPC::R0);
  Reserved.set(PPC::R1);
  Reserved.set(PPC::LR);
  // In Linux, r2 is reserved for the OS.
  if (!Subtarget.isDarwin())
    Reserved.set(PPC::R2);
  // On PPC64, r13 is the thread pointer.  Never allocate this register.
  // Note that this is overconservative, as it also prevents allocation of
  // R31 when the FP is not needed.
  if (Subtarget.isPPC64()) {
    Reserved.set(PPC::R13);
    Reserved.set(PPC::R31);
  }
  if (needsFP(MF))
    Reserved.set(PPC::R31);
  return Reserved;
}

//===----------------------------------------------------------------------===//
// Stack Frame Processing methods
//===----------------------------------------------------------------------===//

// hasFP - Return true if the specified function actually has a dedicated frame
// pointer register.  This is true if the function needs a frame pointer and has
// a non-zero stack size.
bool PPCRegisterInfo::hasFP(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  return MFI->getStackSize() && needsFP(MF);
}

/// MustSaveLR - Return true if this function requires that we save the LR
/// register onto the stack in the prolog and restore it in the epilog of the
/// function.
static bool MustSaveLR(const MachineFunction &MF) {
  const PPCFunctionInfo *MFI = MF.getInfo<PPCFunctionInfo>();
  
  // We need an save/restore of LR if there is any use/def of LR explicitly, or
  // if there is some use of the LR stack slot (e.g. for builtin_return_address.
  return MFI->usesLR() || MFI->isLRStoreRequired() ||
         // FIXME: Anything that has a call should clobber the LR register,
         // isn't this redundant??
         MF.getFrameInfo()->hasCalls();
}

void PPCRegisterInfo::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  // Simply discard ADJCALLSTACKDOWN, ADJCALLSTACKUP instructions.
  MBB.erase(I);
}

/// LowerDynamicAlloc - Generate the code for allocating an object in the
/// current frame.  The sequence of code with be in the general form
///
///   addi   R0, SP, #frameSize ; get the address of the previous frame
///   stwxu  R0, SP, Rnegsize   ; add and update the SP with the negated size
///   addi   Rnew, SP, #maxCalFrameSize ; get the top of the allocation
///
void PPCRegisterInfo::lowerDynamicAlloc(MachineBasicBlock::iterator II) const {
  // Get the instruction.
  MachineInstr &MI = *II;
  // Get the instruction's basic block.
  MachineBasicBlock &MBB = *MI.getParent();
  // Get the basic block's function.
  MachineFunction &MF = *MBB.getParent();
  // Get the frame info.
  MachineFrameInfo *MFI = MF.getFrameInfo();
  // Determine whether 64-bit pointers are used.
  bool LP64 = Subtarget.isPPC64();

  // Get the maximum call stack size.
  unsigned maxCallFrameSize = MFI->getMaxCallFrameSize();
  // Get the total frame size.
  unsigned FrameSize = MFI->getStackSize();
  
  // Get stack alignments.
  unsigned TargetAlign = MF.getTarget().getFrameInfo()->getStackAlignment();
  unsigned MaxAlign = MFI->getMaxAlignment();
  assert(MaxAlign <= TargetAlign &&
         "Dynamic alloca with large aligns not supported");

  // Determine the previous frame's address.  If FrameSize can't be
  // represented as 16 bits or we need special alignment, then we load the
  // previous frame's address from 0(SP).  Why not do an addis of the hi? 
  // Because R0 is our only safe tmp register and addi/addis treat R0 as zero. 
  // Constructing the constant and adding would take 3 instructions. 
  // Fortunately, a frame greater than 32K is rare.
  if (MaxAlign < TargetAlign && isInt16(FrameSize)) {
    BuildMI(MBB, II, TII.get(PPC::ADDI), PPC::R0)
      .addReg(PPC::R31)
      .addImm(FrameSize);
  } else if (LP64) {
    BuildMI(MBB, II, TII.get(PPC::LD), PPC::X0)
      .addImm(0)
      .addReg(PPC::X1);
  } else {
    BuildMI(MBB, II, TII.get(PPC::LWZ), PPC::R0)
      .addImm(0)
      .addReg(PPC::R1);
  }
  
  // Grow the stack and update the stack pointer link, then
  // determine the address of new allocated space.
  if (LP64) {
    BuildMI(MBB, II, TII.get(PPC::STDUX))
      .addReg(PPC::X0)
      .addReg(PPC::X1)
      .addReg(MI.getOperand(1).getReg());
    BuildMI(MBB, II, TII.get(PPC::ADDI8), MI.getOperand(0).getReg())
      .addReg(PPC::X1)
      .addImm(maxCallFrameSize);
  } else {
    BuildMI(MBB, II, TII.get(PPC::STWUX))
      .addReg(PPC::R0)
      .addReg(PPC::R1)
      .addReg(MI.getOperand(1).getReg());
    BuildMI(MBB, II, TII.get(PPC::ADDI), MI.getOperand(0).getReg())
      .addReg(PPC::R1)
      .addImm(maxCallFrameSize);
  }
  
  // Discard the DYNALLOC instruction.
  MBB.erase(II);
}

void PPCRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected");

  // Get the instruction.
  MachineInstr &MI = *II;
  // Get the instruction's basic block.
  MachineBasicBlock &MBB = *MI.getParent();
  // Get the basic block's function.
  MachineFunction &MF = *MBB.getParent();
  // Get the frame info.
  MachineFrameInfo *MFI = MF.getFrameInfo();

  // Find out which operand is the frame index.
  unsigned FIOperandNo = 0;
  while (!MI.getOperand(FIOperandNo).isFrameIndex()) {
    ++FIOperandNo;
    assert(FIOperandNo != MI.getNumOperands() &&
           "Instr doesn't have FrameIndex operand!");
  }
  // Take into account whether it's an add or mem instruction
  unsigned OffsetOperandNo = (FIOperandNo == 2) ? 1 : 2;
  if (MI.getOpcode() == TargetInstrInfo::INLINEASM)
    OffsetOperandNo = FIOperandNo-1;
      
  // Get the frame index.
  int FrameIndex = MI.getOperand(FIOperandNo).getIndex();
  
  // Get the frame pointer save index.  Users of this index are primarily
  // DYNALLOC instructions.
  PPCFunctionInfo *FI = MF.getInfo<PPCFunctionInfo>();
  int FPSI = FI->getFramePointerSaveIndex();
  // Get the instruction opcode.
  unsigned OpC = MI.getOpcode();
  
  // Special case for dynamic alloca.
  if (FPSI && FrameIndex == FPSI &&
      (OpC == PPC::DYNALLOC || OpC == PPC::DYNALLOC8)) {
    lowerDynamicAlloc(II);
    return;
  }

  // Replace the FrameIndex with base register with GPR1 (SP) or GPR31 (FP).
  MI.getOperand(FIOperandNo).ChangeToRegister(hasFP(MF) ? PPC::R31 : PPC::R1,
                                              false);

  // Figure out if the offset in the instruction is shifted right two bits. This
  // is true for instructions like "STD", which the machine implicitly adds two
  // low zeros to.
  bool isIXAddr = false;
  switch (OpC) {
  case PPC::LWA:
  case PPC::LD:
  case PPC::STD:
  case PPC::STD_32:
    isIXAddr = true;
    break;
  }
  
  // Now add the frame object offset to the offset from r1.
  int Offset = MFI->getObjectOffset(FrameIndex);
  if (!isIXAddr)
    Offset += MI.getOperand(OffsetOperandNo).getImm();
  else
    Offset += MI.getOperand(OffsetOperandNo).getImm() << 2;

  // If we're not using a Frame Pointer that has been set to the value of the
  // SP before having the stack size subtracted from it, then add the stack size
  // to Offset to get the correct offset.
  Offset += MFI->getStackSize();

  // If we can, encode the offset directly into the instruction.  If this is a
  // normal PPC "ri" instruction, any 16-bit value can be safely encoded.  If
  // this is a PPC64 "ix" instruction, only a 16-bit value with the low two bits
  // clear can be encoded.  This is extremely uncommon, because normally you
  // only "std" to a stack slot that is at least 4-byte aligned, but it can
  // happen in invalid code.
  if (isInt16(Offset) && (!isIXAddr || (Offset & 3) == 0)) {
    if (isIXAddr)
      Offset >>= 2;    // The actual encoded value has the low two bits zero.
    MI.getOperand(OffsetOperandNo).ChangeToImmediate(Offset);
    return;
  }
  
  // Insert a set of r0 with the full offset value before the ld, st, or add
  BuildMI(MBB, II, TII.get(PPC::LIS), PPC::R0).addImm(Offset >> 16);
  BuildMI(MBB, II, TII.get(PPC::ORI), PPC::R0).addReg(PPC::R0).addImm(Offset);
  
  // Convert into indexed form of the instruction
  // sth 0:rA, 1:imm 2:(rB) ==> sthx 0:rA, 2:rB, 1:r0
  // addi 0:rA 1:rB, 2, imm ==> add 0:rA, 1:rB, 2:r0
  unsigned OperandBase;
  if (OpC != TargetInstrInfo::INLINEASM) {
    assert(ImmToIdxMap.count(OpC) &&
           "No indexed form of load or store available!");
    unsigned NewOpcode = ImmToIdxMap.find(OpC)->second;
    MI.setInstrDescriptor(TII.get(NewOpcode));
    OperandBase = 1;
  } else {
    OperandBase = OffsetOperandNo;
  }
    
  unsigned StackReg = MI.getOperand(FIOperandNo).getReg();
  MI.getOperand(OperandBase).ChangeToRegister(StackReg, false);
  MI.getOperand(OperandBase+1).ChangeToRegister(PPC::R0, false);
}

/// VRRegNo - Map from a numbered VR register to its enum value.
///
static const unsigned short VRRegNo[] = {
 PPC::V0 , PPC::V1 , PPC::V2 , PPC::V3 , PPC::V4 , PPC::V5 , PPC::V6 , PPC::V7 ,
 PPC::V8 , PPC::V9 , PPC::V10, PPC::V11, PPC::V12, PPC::V13, PPC::V14, PPC::V15,
 PPC::V16, PPC::V17, PPC::V18, PPC::V19, PPC::V20, PPC::V21, PPC::V22, PPC::V23,
 PPC::V24, PPC::V25, PPC::V26, PPC::V27, PPC::V28, PPC::V29, PPC::V30, PPC::V31
};

/// RemoveVRSaveCode - We have found that this function does not need any code
/// to manipulate the VRSAVE register, even though it uses vector registers.
/// This can happen when the only registers used are known to be live in or out
/// of the function.  Remove all of the VRSAVE related code from the function.
static void RemoveVRSaveCode(MachineInstr *MI) {
  MachineBasicBlock *Entry = MI->getParent();
  MachineFunction *MF = Entry->getParent();

  // We know that the MTVRSAVE instruction immediately follows MI.  Remove it.
  MachineBasicBlock::iterator MBBI = MI;
  ++MBBI;
  assert(MBBI != Entry->end() && MBBI->getOpcode() == PPC::MTVRSAVE);
  MBBI->eraseFromParent();
  
  bool RemovedAllMTVRSAVEs = true;
  // See if we can find and remove the MTVRSAVE instruction from all of the
  // epilog blocks.
  const TargetInstrInfo &TII = *MF->getTarget().getInstrInfo();
  for (MachineFunction::iterator I = MF->begin(), E = MF->end(); I != E; ++I) {
    // If last instruction is a return instruction, add an epilogue
    if (!I->empty() && TII.isReturn(I->back().getOpcode())) {
      bool FoundIt = false;
      for (MBBI = I->end(); MBBI != I->begin(); ) {
        --MBBI;
        if (MBBI->getOpcode() == PPC::MTVRSAVE) {
          MBBI->eraseFromParent();  // remove it.
          FoundIt = true;
          break;
        }
      }
      RemovedAllMTVRSAVEs &= FoundIt;
    }
  }

  // If we found and removed all MTVRSAVE instructions, remove the read of
  // VRSAVE as well.
  if (RemovedAllMTVRSAVEs) {
    MBBI = MI;
    assert(MBBI != Entry->begin() && "UPDATE_VRSAVE is first instr in block?");
    --MBBI;
    assert(MBBI->getOpcode() == PPC::MFVRSAVE && "VRSAVE instrs wandered?");
    MBBI->eraseFromParent();
  }
  
  // Finally, nuke the UPDATE_VRSAVE.
  MI->eraseFromParent();
}

// HandleVRSaveUpdate - MI is the UPDATE_VRSAVE instruction introduced by the
// instruction selector.  Based on the vector registers that have been used,
// transform this into the appropriate ORI instruction.
static void HandleVRSaveUpdate(MachineInstr *MI, const TargetInstrInfo &TII) {
  MachineFunction *MF = MI->getParent()->getParent();

  unsigned UsedRegMask = 0;
  for (unsigned i = 0; i != 32; ++i)
    if (MF->getRegInfo().isPhysRegUsed(VRRegNo[i]))
      UsedRegMask |= 1 << (31-i);
  
  // Live in and live out values already must be in the mask, so don't bother
  // marking them.
  for (MachineRegisterInfo::livein_iterator
       I = MF->getRegInfo().livein_begin(),
       E = MF->getRegInfo().livein_end(); I != E; ++I) {
    unsigned RegNo = PPCRegisterInfo::getRegisterNumbering(I->first);
    if (VRRegNo[RegNo] == I->first)        // If this really is a vector reg.
      UsedRegMask &= ~(1 << (31-RegNo));   // Doesn't need to be marked.
  }
  for (MachineRegisterInfo::liveout_iterator
       I = MF->getRegInfo().liveout_begin(),
       E = MF->getRegInfo().liveout_end(); I != E; ++I) {
    unsigned RegNo = PPCRegisterInfo::getRegisterNumbering(*I);
    if (VRRegNo[RegNo] == *I)              // If this really is a vector reg.
      UsedRegMask &= ~(1 << (31-RegNo));   // Doesn't need to be marked.
  }
  
  unsigned SrcReg = MI->getOperand(1).getReg();
  unsigned DstReg = MI->getOperand(0).getReg();
  // If no registers are used, turn this into a copy.
  if (UsedRegMask == 0) {
    // Remove all VRSAVE code.
    RemoveVRSaveCode(MI);
    return;
  } else if ((UsedRegMask & 0xFFFF) == UsedRegMask) {
    BuildMI(*MI->getParent(), MI, TII.get(PPC::ORI), DstReg)
        .addReg(SrcReg).addImm(UsedRegMask);
  } else if ((UsedRegMask & 0xFFFF0000) == UsedRegMask) {
    BuildMI(*MI->getParent(), MI, TII.get(PPC::ORIS), DstReg)
        .addReg(SrcReg).addImm(UsedRegMask >> 16);
  } else {
    BuildMI(*MI->getParent(), MI, TII.get(PPC::ORIS), DstReg)
       .addReg(SrcReg).addImm(UsedRegMask >> 16);
    BuildMI(*MI->getParent(), MI, TII.get(PPC::ORI), DstReg)
      .addReg(DstReg).addImm(UsedRegMask & 0xFFFF);
  }
  
  // Remove the old UPDATE_VRSAVE instruction.
  MI->eraseFromParent();
}

/// determineFrameLayout - Determine the size of the frame and maximum call
/// frame size.
void PPCRegisterInfo::determineFrameLayout(MachineFunction &MF) const {
  MachineFrameInfo *MFI = MF.getFrameInfo();

  // Get the number of bytes to allocate from the FrameInfo
  unsigned FrameSize = MFI->getStackSize();
  
  // Get the alignments provided by the target, and the maximum alignment
  // (if any) of the fixed frame objects.
  unsigned MaxAlign = MFI->getMaxAlignment();
  unsigned TargetAlign = MF.getTarget().getFrameInfo()->getStackAlignment();
  unsigned AlignMask = TargetAlign - 1;  //

  // If we are a leaf function, and use up to 224 bytes of stack space,
  // don't have a frame pointer, calls, or dynamic alloca then we do not need
  // to adjust the stack pointer (we fit in the Red Zone).
  if (FrameSize <= 224 &&             // Fits in red zone.
      !MFI->hasVarSizedObjects() &&   // No dynamic alloca.
      !MFI->hasCalls() &&             // No calls.
      MaxAlign <= TargetAlign) {      // No special alignment.
    // No need for frame
    MFI->setStackSize(0);
    return;
  }
  
  // Get the maximum call frame size of all the calls.
  unsigned maxCallFrameSize = MFI->getMaxCallFrameSize();
  
  // Maximum call frame needs to be at least big enough for linkage and 8 args.
  unsigned minCallFrameSize =
    PPCFrameInfo::getMinCallFrameSize(Subtarget.isPPC64(), 
                                      Subtarget.isMachoABI());
  maxCallFrameSize = std::max(maxCallFrameSize, minCallFrameSize);

  // If we have dynamic alloca then maxCallFrameSize needs to be aligned so
  // that allocations will be aligned.
  if (MFI->hasVarSizedObjects())
    maxCallFrameSize = (maxCallFrameSize + AlignMask) & ~AlignMask;
  
  // Update maximum call frame size.
  MFI->setMaxCallFrameSize(maxCallFrameSize);
  
  // Include call frame size in total.
  FrameSize += maxCallFrameSize;
  
  // Make sure the frame is aligned.
  FrameSize = (FrameSize + AlignMask) & ~AlignMask;

  // Update frame info.
  MFI->setStackSize(FrameSize);
}

void PPCRegisterInfo::processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                                           RegScavenger *RS)
  const {
  //  Save and clear the LR state.
  PPCFunctionInfo *FI = MF.getInfo<PPCFunctionInfo>();
  unsigned LR = getRARegister();
  FI->setUsesLR(MF.getRegInfo().isPhysRegUsed(LR));
  MF.getRegInfo().setPhysRegUnused(LR);

  //  Save R31 if necessary
  int FPSI = FI->getFramePointerSaveIndex();
  bool IsPPC64 = Subtarget.isPPC64();
  bool IsELF32_ABI = Subtarget.isELF32_ABI();
  bool IsMachoABI  = Subtarget.isMachoABI();
  const MachineFrameInfo *MFI = MF.getFrameInfo();
 
  // If the frame pointer save index hasn't been defined yet.
  if (!FPSI && (NoFramePointerElim || MFI->hasVarSizedObjects()) &&
      IsELF32_ABI) {
    // Find out what the fix offset of the frame pointer save area.
    int FPOffset = PPCFrameInfo::getFramePointerSaveOffset(IsPPC64,
                                                           IsMachoABI);
    // Allocate the frame index for frame pointer save area.
    FPSI = MF.getFrameInfo()->CreateFixedObject(IsPPC64? 8 : 4, FPOffset);
    // Save the result.
    FI->setFramePointerSaveIndex(FPSI);                      
  }

}

void PPCRegisterInfo::emitPrologue(MachineFunction &MF) const {
  MachineBasicBlock &MBB = MF.front();   // Prolog goes in entry BB
  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MachineModuleInfo *MMI = MFI->getMachineModuleInfo();
  
  // Prepare for frame info.
  unsigned FrameLabelId = 0;
  
  // Scan the prolog, looking for an UPDATE_VRSAVE instruction.  If we find it,
  // process it.
  for (unsigned i = 0; MBBI != MBB.end(); ++i, ++MBBI) {
    if (MBBI->getOpcode() == PPC::UPDATE_VRSAVE) {
      HandleVRSaveUpdate(MBBI, TII);
      break;
    }
  }
  
  // Move MBBI back to the beginning of the function.
  MBBI = MBB.begin();
  
  // Work out frame sizes.
  determineFrameLayout(MF);
  unsigned FrameSize = MFI->getStackSize();
  
  int NegFrameSize = -FrameSize;
  
  // Get processor type.
  bool IsPPC64 = Subtarget.isPPC64();
  // Get operating system
  bool IsMachoABI = Subtarget.isMachoABI();
  // Check if the link register (LR) has been used.
  bool UsesLR = MustSaveLR(MF);
  // Do we have a frame pointer for this function?
  bool HasFP = hasFP(MF) && FrameSize;
  
  int LROffset = PPCFrameInfo::getReturnSaveOffset(IsPPC64, IsMachoABI);
  int FPOffset = PPCFrameInfo::getFramePointerSaveOffset(IsPPC64, IsMachoABI);
  
  if (IsPPC64) {
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::MFLR8), PPC::X0);
      
    if (HasFP)
      BuildMI(MBB, MBBI, TII.get(PPC::STD))
         .addReg(PPC::X31).addImm(FPOffset/4).addReg(PPC::X1);
    
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::STD))
         .addReg(PPC::X0).addImm(LROffset/4).addReg(PPC::X1);
  } else {
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::MFLR), PPC::R0);
      
    if (HasFP)
      BuildMI(MBB, MBBI, TII.get(PPC::STW))
        .addReg(PPC::R31).addImm(FPOffset).addReg(PPC::R1);

    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::STW))
        .addReg(PPC::R0).addImm(LROffset).addReg(PPC::R1);
  }
  
  // Skip if a leaf routine.
  if (!FrameSize) return;
  
  // Get stack alignments.
  unsigned TargetAlign = MF.getTarget().getFrameInfo()->getStackAlignment();
  unsigned MaxAlign = MFI->getMaxAlignment();

  if (MMI && MMI->needsFrameInfo()) {
    // Mark effective beginning of when frame pointer becomes valid.
    FrameLabelId = MMI->NextLabelID();
    BuildMI(MBB, MBBI, TII.get(PPC::LABEL)).addImm(FrameLabelId);
  }
  
  // Adjust stack pointer: r1 += NegFrameSize.
  // If there is a preferred stack alignment, align R1 now
  if (!IsPPC64) {
    // PPC32.
    if (MaxAlign > TargetAlign) {
      assert(isPowerOf2_32(MaxAlign)&&isInt16(MaxAlign)&&"Invalid alignment!");
      assert(isInt16(NegFrameSize) && "Unhandled stack size and alignment!");
      BuildMI(MBB, MBBI, TII.get(PPC::RLWINM), PPC::R0)
        .addReg(PPC::R1).addImm(0).addImm(32-Log2_32(MaxAlign)).addImm(31);
      BuildMI(MBB, MBBI, TII.get(PPC::SUBFIC) ,PPC::R0).addReg(PPC::R0)
        .addImm(NegFrameSize);
      BuildMI(MBB, MBBI, TII.get(PPC::STWUX))
        .addReg(PPC::R1).addReg(PPC::R1).addReg(PPC::R0);
    } else if (isInt16(NegFrameSize)) {
      BuildMI(MBB, MBBI, TII.get(PPC::STWU),
              PPC::R1).addReg(PPC::R1).addImm(NegFrameSize).addReg(PPC::R1);
    } else {
      BuildMI(MBB, MBBI, TII.get(PPC::LIS), PPC::R0).addImm(NegFrameSize >> 16);
      BuildMI(MBB, MBBI, TII.get(PPC::ORI), PPC::R0).addReg(PPC::R0)
        .addImm(NegFrameSize & 0xFFFF);
      BuildMI(MBB, MBBI, TII.get(PPC::STWUX)).addReg(PPC::R1).addReg(PPC::R1)
        .addReg(PPC::R0);
    }
  } else {    // PPC64.
    if (MaxAlign > TargetAlign) {
      assert(isPowerOf2_32(MaxAlign)&&isInt16(MaxAlign)&&"Invalid alignment!");
      assert(isInt16(NegFrameSize) && "Unhandled stack size and alignment!");
      BuildMI(MBB, MBBI, TII.get(PPC::RLDICL), PPC::X0)
        .addReg(PPC::X1).addImm(0).addImm(64-Log2_32(MaxAlign));
      BuildMI(MBB, MBBI, TII.get(PPC::SUBFIC8), PPC::X0).addReg(PPC::X0)
        .addImm(NegFrameSize);
      BuildMI(MBB, MBBI, TII.get(PPC::STDUX))
        .addReg(PPC::X1).addReg(PPC::X1).addReg(PPC::X0);
    } else if (isInt16(NegFrameSize)) {
      BuildMI(MBB, MBBI, TII.get(PPC::STDU), PPC::X1)
             .addReg(PPC::X1).addImm(NegFrameSize/4).addReg(PPC::X1);
    } else {
      BuildMI(MBB, MBBI, TII.get(PPC::LIS8), PPC::X0).addImm(NegFrameSize >>16);
      BuildMI(MBB, MBBI, TII.get(PPC::ORI8), PPC::X0).addReg(PPC::X0)
        .addImm(NegFrameSize & 0xFFFF);
      BuildMI(MBB, MBBI, TII.get(PPC::STDUX)).addReg(PPC::X1).addReg(PPC::X1)
        .addReg(PPC::X0);
    }
  }
  
  if (MMI && MMI->needsFrameInfo()) {
    std::vector<MachineMove> &Moves = MMI->getFrameMoves();
    
    if (NegFrameSize) {
      // Show update of SP.
      MachineLocation SPDst(MachineLocation::VirtualFP);
      MachineLocation SPSrc(MachineLocation::VirtualFP, NegFrameSize);
      Moves.push_back(MachineMove(FrameLabelId, SPDst, SPSrc));
    } else {
      MachineLocation SP(IsPPC64 ? PPC::X31 : PPC::R31);
      Moves.push_back(MachineMove(FrameLabelId, SP, SP));
    }
    
    if (HasFP) {
      MachineLocation FPDst(MachineLocation::VirtualFP, FPOffset);
      MachineLocation FPSrc(IsPPC64 ? PPC::X31 : PPC::R31);
      Moves.push_back(MachineMove(FrameLabelId, FPDst, FPSrc));
    }

    // Add callee saved registers to move list.
    const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
    for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
      int Offset = MFI->getObjectOffset(CSI[I].getFrameIdx());
      unsigned Reg = CSI[I].getReg();
      if (Reg == PPC::LR || Reg == PPC::LR8) continue;
      MachineLocation CSDst(MachineLocation::VirtualFP, Offset);
      MachineLocation CSSrc(Reg);
      Moves.push_back(MachineMove(FrameLabelId, CSDst, CSSrc));
    }
    
    MachineLocation LRDst(MachineLocation::VirtualFP, LROffset);
    MachineLocation LRSrc(IsPPC64 ? PPC::LR8 : PPC::LR);
    Moves.push_back(MachineMove(FrameLabelId, LRDst, LRSrc));
    
    // Mark effective beginning of when frame pointer is ready.
    unsigned ReadyLabelId = MMI->NextLabelID();
    BuildMI(MBB, MBBI, TII.get(PPC::LABEL)).addImm(ReadyLabelId);
    
    MachineLocation FPDst(HasFP ? (IsPPC64 ? PPC::X31 : PPC::R31) :
                                  (IsPPC64 ? PPC::X1 : PPC::R1));
    MachineLocation FPSrc(MachineLocation::VirtualFP);
    Moves.push_back(MachineMove(ReadyLabelId, FPDst, FPSrc));
  }

  // If there is a frame pointer, copy R1 into R31
  if (HasFP) {
    if (!IsPPC64) {
      BuildMI(MBB, MBBI, TII.get(PPC::OR), PPC::R31).addReg(PPC::R1)
        .addReg(PPC::R1);
    } else {
      BuildMI(MBB, MBBI, TII.get(PPC::OR8), PPC::X31).addReg(PPC::X1)
        .addReg(PPC::X1);
    }
  }
}

void PPCRegisterInfo::emitEpilogue(MachineFunction &MF,
                                   MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = prior(MBB.end());
  assert(MBBI->getOpcode() == PPC::BLR &&
         "Can only insert epilog into returning blocks");

  // Get alignment info so we know how to restore r1
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  unsigned TargetAlign = MF.getTarget().getFrameInfo()->getStackAlignment();
  unsigned MaxAlign = MFI->getMaxAlignment();

  // Get the number of bytes allocated from the FrameInfo.
  unsigned FrameSize = MFI->getStackSize();

  // Get processor type.
  bool IsPPC64 = Subtarget.isPPC64();
  // Get operating system
  bool IsMachoABI = Subtarget.isMachoABI();
  // Check if the link register (LR) has been used.
  bool UsesLR = MustSaveLR(MF);
  // Do we have a frame pointer for this function?
  bool HasFP = hasFP(MF) && FrameSize;
  
  int LROffset = PPCFrameInfo::getReturnSaveOffset(IsPPC64, IsMachoABI);
  int FPOffset = PPCFrameInfo::getFramePointerSaveOffset(IsPPC64, IsMachoABI);
  
  if (FrameSize) {
    // The loaded (or persistent) stack pointer value is offset by the 'stwu'
    // on entry to the function.  Add this offset back now.
    if (!Subtarget.isPPC64()) {
      if (isInt16(FrameSize) && TargetAlign >= MaxAlign &&
            !MFI->hasVarSizedObjects()) {
          BuildMI(MBB, MBBI, TII.get(PPC::ADDI), PPC::R1)
              .addReg(PPC::R1).addImm(FrameSize);
      } else {
        BuildMI(MBB, MBBI, TII.get(PPC::LWZ),PPC::R1).addImm(0).addReg(PPC::R1);
      }
    } else {
      if (isInt16(FrameSize) && TargetAlign >= MaxAlign &&
            !MFI->hasVarSizedObjects()) {
        BuildMI(MBB, MBBI, TII.get(PPC::ADDI8), PPC::X1)
           .addReg(PPC::X1).addImm(FrameSize);
      } else {
        BuildMI(MBB, MBBI, TII.get(PPC::LD), PPC::X1).addImm(0).addReg(PPC::X1);
      }
    }
  }

  if (IsPPC64) {
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::LD), PPC::X0)
        .addImm(LROffset/4).addReg(PPC::X1);
        
    if (HasFP)
      BuildMI(MBB, MBBI, TII.get(PPC::LD), PPC::X31)
        .addImm(FPOffset/4).addReg(PPC::X1);
        
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::MTLR8)).addReg(PPC::X0);
  } else {
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::LWZ), PPC::R0)
          .addImm(LROffset).addReg(PPC::R1);
        
    if (HasFP)
      BuildMI(MBB, MBBI, TII.get(PPC::LWZ), PPC::R31)
          .addImm(FPOffset).addReg(PPC::R1);
          
    if (UsesLR)
      BuildMI(MBB, MBBI, TII.get(PPC::MTLR)).addReg(PPC::R0);
  }
}

unsigned PPCRegisterInfo::getRARegister() const {
  return !Subtarget.isPPC64() ? PPC::LR : PPC::LR8;
}

unsigned PPCRegisterInfo::getFrameRegister(MachineFunction &MF) const {
  if (!Subtarget.isPPC64())
    return hasFP(MF) ? PPC::R31 : PPC::R1;
  else
    return hasFP(MF) ? PPC::X31 : PPC::X1;
}

void PPCRegisterInfo::getInitialFrameState(std::vector<MachineMove> &Moves)
                                                                         const {
  // Initial state of the frame pointer is R1.
  MachineLocation Dst(MachineLocation::VirtualFP);
  MachineLocation Src(PPC::R1, 0);
  Moves.push_back(MachineMove(0, Dst, Src));
}

unsigned PPCRegisterInfo::getEHExceptionRegister() const {
  return !Subtarget.isPPC64() ? PPC::R3 : PPC::X3;
}

unsigned PPCRegisterInfo::getEHHandlerRegister() const {
  return !Subtarget.isPPC64() ? PPC::R4 : PPC::X4;
}

int PPCRegisterInfo::getDwarfRegNum(unsigned RegNum, bool isEH) const {
  // FIXME: Most probably dwarf numbers differs for Linux and Darwin
  return PPCGenRegisterInfo::getDwarfRegNumFull(RegNum, 0);
}

#include "PPCGenRegisterInfo.inc"

