//===- MipsLegalizerInfo ----------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares the targeting of the Machinelegalizer class for Mips.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MIPS_MIPSMACHINELEGALIZER_H
#define LLVM_LIB_TARGET_MIPS_MIPSMACHINELEGALIZER_H

#include "llvm/CodeGen/GlobalISel/GISelChangeObserver.h"
#include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"

namespace llvm {

class MipsSubtarget;

/// This class provides legalization strategies.
class MipsLegalizerInfo : public LegalizerInfo {
public:
  MipsLegalizerInfo(const MipsSubtarget &ST);

  bool legalizeCustom(MachineInstr &MI, MachineRegisterInfo &MRI,
                      MachineIRBuilder &MIRBuilder,
                      GISelChangeObserver &Observer) const override;
};
} // end namespace llvm
#endif
