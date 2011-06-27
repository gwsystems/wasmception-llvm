//===-- MBlaze.h - Top-level interface for MBlaze ---------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in
// the LLVM MBlaze back-end.
//
//===----------------------------------------------------------------------===//

#ifndef TARGET_MBLAZE_H
#define TARGET_MBLAZE_H

#include "llvm/Target/TargetMachine.h"

namespace llvm {
  class MBlazeTargetMachine;
  class FunctionPass;
  class MachineCodeEmitter;
  class MCCodeEmitter;
  class TargetAsmBackend;
  class formatted_raw_ostream;

  MCCodeEmitter *createMBlazeMCCodeEmitter(const Target &,
                                           TargetMachine &TM,
                                           MCContext &Ctx);

  TargetAsmBackend *createMBlazeAsmBackend(const Target &, const std::string &);

  FunctionPass *createMBlazeISelDag(MBlazeTargetMachine &TM);
  FunctionPass *createMBlazeDelaySlotFillerPass(MBlazeTargetMachine &TM);

  extern Target TheMBlazeTarget;
} // end namespace llvm;

// Defines symbolic names for MBlaze registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "MBlazeGenRegisterInfo.inc"

// Defines symbolic names for the MBlaze instructions.
#include "MBlazeGenInstrNames.inc"

#endif
