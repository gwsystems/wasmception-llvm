//===-- X86TargetMachine.cpp - Define TargetMachine for the X86 -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the X86 specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#include "X86TargetAsmInfo.h"
#include "X86TargetMachine.h"
#include "X86.h"
#include "llvm/Module.h"
#include "llvm/PassManager.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/Target/TargetMachineRegistry.h"
using namespace llvm;

// Register the target.
static RegisterTarget<X86_32TargetMachine>
X(TheX86_32Target, "x86",    "32-bit X86: Pentium-Pro and above");

static RegisterTarget<X86_64TargetMachine>
Y(TheX86_64Target, "x86-64", "64-bit X86: EM64T and AMD64");

// Force static initialization.
extern "C" void LLVMInitializeX86Target() { 
  
}

const TargetAsmInfo *X86TargetMachine::createTargetAsmInfo() const {
  if (Subtarget.isFlavorIntel())
    return new X86WinTargetAsmInfo(*this);
  else
    switch (Subtarget.TargetType) {
     case X86Subtarget::isDarwin:
      return new X86DarwinTargetAsmInfo(*this);
     case X86Subtarget::isELF:
      return new X86ELFTargetAsmInfo(*this);
     case X86Subtarget::isMingw:
     case X86Subtarget::isCygwin:
      return new X86COFFTargetAsmInfo(*this);
     case X86Subtarget::isWindows:
      return new X86WinTargetAsmInfo(*this);
     default:
      return new X86GenericTargetAsmInfo(*this);
    }
}

X86_32TargetMachine::X86_32TargetMachine(const Target &T, const Module &M, 
                                         const std::string &FS)
  : X86TargetMachine(T, M, FS, false) {
}


X86_64TargetMachine::X86_64TargetMachine(const Target &T, const Module &M, 
                                         const std::string &FS)
  : X86TargetMachine(T, M, FS, true) {
}

/// X86TargetMachine ctor - Create an X86 target.
///
X86TargetMachine::X86TargetMachine(const Target &T, const Module &M, 
                                   const std::string &FS, bool is64Bit)
  : LLVMTargetMachine(T), 
    Subtarget(M, FS, is64Bit),
    DataLayout(Subtarget.getDataLayout()),
    FrameInfo(TargetFrameInfo::StackGrowsDown,
              Subtarget.getStackAlignment(), Subtarget.is64Bit() ? -8 : -4),
    InstrInfo(*this), JITInfo(*this), TLInfo(*this), ELFWriterInfo(*this) {
  DefRelocModel = getRelocationModel();
      
  // If no relocation model was picked, default as appropriate for the target.
  if (getRelocationModel() == Reloc::Default) {
    if (!Subtarget.isTargetDarwin())
      setRelocationModel(Reloc::Static);
    else if (Subtarget.is64Bit())
      setRelocationModel(Reloc::PIC_);
    else
      setRelocationModel(Reloc::DynamicNoPIC);
  }

  assert(getRelocationModel() != Reloc::Default &&
         "Relocation mode not picked");

  // If no code model is picked, default to small.
  if (getCodeModel() == CodeModel::Default)
    setCodeModel(CodeModel::Small);
      
  // ELF and X86-64 don't have a distinct DynamicNoPIC model.  DynamicNoPIC
  // is defined as a model for code which may be used in static or dynamic
  // executables but not necessarily a shared library. On X86-32 we just
  // compile in -static mode, in x86-64 we use PIC.
  if (getRelocationModel() == Reloc::DynamicNoPIC) {
    if (is64Bit)
      setRelocationModel(Reloc::PIC_);
    else if (!Subtarget.isTargetDarwin())
      setRelocationModel(Reloc::Static);
  }

  // If we are on Darwin, disallow static relocation model in X86-64 mode, since
  // the Mach-O file format doesn't support it.
  if (getRelocationModel() == Reloc::Static &&
      Subtarget.isTargetDarwin() &&
      is64Bit)
    setRelocationModel(Reloc::PIC_);
      
  // Determine the PICStyle based on the target selected.
  if (getRelocationModel() == Reloc::Static) {
    // Unless we're in PIC or DynamicNoPIC mode, set the PIC style to None.
    Subtarget.setPICStyle(PICStyles::None);
  } else if (Subtarget.isTargetCygMing()) {
    Subtarget.setPICStyle(PICStyles::None);
  } else if (Subtarget.isTargetDarwin()) {
    if (Subtarget.is64Bit())
      Subtarget.setPICStyle(PICStyles::RIPRel);
    else if (getRelocationModel() == Reloc::PIC_)
      Subtarget.setPICStyle(PICStyles::StubPIC);
    else {
      assert(getRelocationModel() == Reloc::DynamicNoPIC);
      Subtarget.setPICStyle(PICStyles::StubDynamicNoPIC);
    }
  } else if (Subtarget.isTargetELF()) {
    if (Subtarget.is64Bit())
      Subtarget.setPICStyle(PICStyles::RIPRel);
    else
      Subtarget.setPICStyle(PICStyles::GOT);
  }
      
  // Finally, if we have "none" as our PIC style, force to static mode.
  if (Subtarget.getPICStyle() == PICStyles::None)
    setRelocationModel(Reloc::Static);
}

//===----------------------------------------------------------------------===//
// Pass Pipeline Configuration
//===----------------------------------------------------------------------===//

bool X86TargetMachine::addInstSelector(PassManagerBase &PM,
                                       CodeGenOpt::Level OptLevel) {
  // Install an instruction selector.
  PM.add(createX86ISelDag(*this, OptLevel));

  // If we're using Fast-ISel, clean up the mess.
  if (EnableFastISel)
    PM.add(createDeadMachineInstructionElimPass());

  // Install a pass to insert x87 FP_REG_KILL instructions, as needed.
  PM.add(createX87FPRegKillInserterPass());

  return false;
}

bool X86TargetMachine::addPreRegAlloc(PassManagerBase &PM,
                                      CodeGenOpt::Level OptLevel) {
  // Calculate and set max stack object alignment early, so we can decide
  // whether we will need stack realignment (and thus FP).
  PM.add(createX86MaxStackAlignmentCalculatorPass());
  return false;  // -print-machineinstr shouldn't print after this.
}

bool X86TargetMachine::addPostRegAlloc(PassManagerBase &PM,
                                       CodeGenOpt::Level OptLevel) {
  PM.add(createX86FloatingPointStackifierPass());
  return true;  // -print-machineinstr should print after this.
}

bool X86TargetMachine::addCodeEmitter(PassManagerBase &PM,
                                      CodeGenOpt::Level OptLevel,
                                      MachineCodeEmitter &MCE) {
  // FIXME: Move this to TargetJITInfo!
  // On Darwin, do not override 64-bit setting made in X86TargetMachine().
  if (DefRelocModel == Reloc::Default && 
      (!Subtarget.isTargetDarwin() || !Subtarget.is64Bit())) {
    setRelocationModel(Reloc::Static);
    Subtarget.setPICStyle(PICStyles::None);
  }
  
  // 64-bit JIT places everything in the same buffer except external functions.
  // On Darwin, use small code model but hack the call instruction for 
  // externals.  Elsewhere, do not assume globals are in the lower 4G.
  if (Subtarget.is64Bit()) {
    if (Subtarget.isTargetDarwin())
      setCodeModel(CodeModel::Small);
    else
      setCodeModel(CodeModel::Large);
  }

  PM.add(createX86CodeEmitterPass(*this, MCE));

  return false;
}

bool X86TargetMachine::addCodeEmitter(PassManagerBase &PM,
                                      CodeGenOpt::Level OptLevel,
                                      JITCodeEmitter &JCE) {
  // FIXME: Move this to TargetJITInfo!
  // On Darwin, do not override 64-bit setting made in X86TargetMachine().
  if (DefRelocModel == Reloc::Default && 
      (!Subtarget.isTargetDarwin() || !Subtarget.is64Bit())) {
    setRelocationModel(Reloc::Static);
    Subtarget.setPICStyle(PICStyles::None);
  }
  
  // 64-bit JIT places everything in the same buffer except external functions.
  // On Darwin, use small code model but hack the call instruction for 
  // externals.  Elsewhere, do not assume globals are in the lower 4G.
  if (Subtarget.is64Bit()) {
    if (Subtarget.isTargetDarwin())
      setCodeModel(CodeModel::Small);
    else
      setCodeModel(CodeModel::Large);
  }

  PM.add(createX86JITCodeEmitterPass(*this, JCE));

  return false;
}

bool X86TargetMachine::addCodeEmitter(PassManagerBase &PM,
                                      CodeGenOpt::Level OptLevel,
                                      ObjectCodeEmitter &OCE) {
  PM.add(createX86ObjectCodeEmitterPass(*this, OCE));
  return false;
}

bool X86TargetMachine::addSimpleCodeEmitter(PassManagerBase &PM,
                                            CodeGenOpt::Level OptLevel,
                                            MachineCodeEmitter &MCE) {
  PM.add(createX86CodeEmitterPass(*this, MCE));
  return false;
}

bool X86TargetMachine::addSimpleCodeEmitter(PassManagerBase &PM,
                                            CodeGenOpt::Level OptLevel,
                                            JITCodeEmitter &JCE) {
  PM.add(createX86JITCodeEmitterPass(*this, JCE));
  return false;
}

bool X86TargetMachine::addSimpleCodeEmitter(PassManagerBase &PM,
                                            CodeGenOpt::Level OptLevel,
                                            ObjectCodeEmitter &OCE) {
  PM.add(createX86ObjectCodeEmitterPass(*this, OCE));
  return false;
}
