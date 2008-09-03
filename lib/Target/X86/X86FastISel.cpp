//===-- X86FastISel.cpp - X86 FastISel implementation ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the X86-specific support for the FastISel class. Much
// of the target-specific code is generated by tablegen in the file
// X86GenFastISel.inc, which is #included here.
//
//===----------------------------------------------------------------------===//

#include "X86.h"
#include "X86ISelLowering.h"
#include "X86RegisterInfo.h"
#include "X86Subtarget.h"
#include "X86TargetMachine.h"
#include "llvm/CodeGen/FastISel.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

class X86FastISel : public FastISel {
  /// Subtarget - Keep a pointer to the X86Subtarget around so that we can
  /// make the right decision when generating code for different targets.
  const X86Subtarget *Subtarget;
    
 public:
  explicit X86FastISel(MachineFunction &mf) : FastISel(mf) {
    Subtarget = &TM.getSubtarget<X86Subtarget>();
  }

  virtual bool
    TargetSelectInstruction(Instruction *I,
                            DenseMap<const Value *, unsigned> &ValueMap,
                      DenseMap<const BasicBlock *, MachineBasicBlock *> &MBBMap,
                            MachineBasicBlock *MBB);

#include "X86GenFastISel.inc"
};

bool
X86FastISel::TargetSelectInstruction(Instruction *I,
                                  DenseMap<const Value *, unsigned> &ValueMap,
                      DenseMap<const BasicBlock *, MachineBasicBlock *> &MBBMap,
                                  MachineBasicBlock *MBB)  {
  switch (I->getOpcode()) {
  default: break;
  }

  return false;
}

namespace llvm {
  llvm::FastISel *X86::createFastISel(MachineFunction &mf) {
    return new X86FastISel(mf);
  }
}
