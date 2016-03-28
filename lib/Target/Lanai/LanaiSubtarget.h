//=====-- LanaiSubtarget.h - Define Subtarget for the Lanai -----*- C++ -*--==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Lanai specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_LANAI_LANAISUBTARGET_H
#define LLVM_LIB_TARGET_LANAI_LANAISUBTARGET_H

#include "LanaiFrameLowering.h"
#include "LanaiISelLowering.h"
#include "LanaiInstrInfo.h"
#include "LanaiSelectionDAGInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetSubtargetInfo.h"

#define GET_SUBTARGETINFO_HEADER
#include "LanaiGenSubtargetInfo.inc"

namespace llvm {

class LanaiSubtarget : public LanaiGenSubtargetInfo {
public:
  // This constructor initializes the data members to match that
  // of the specified triple.
  LanaiSubtarget(const Triple &TargetTriple, StringRef Cpu,
                 StringRef FeatureString, const TargetMachine &TM,
                 const TargetOptions &Options, Reloc::Model RelocationModel,
                 CodeModel::Model CodeModel, CodeGenOpt::Level OptLevel);

  // ParseSubtargetFeatures - Parses features string setting specified
  // subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  LanaiSubtarget &initializeSubtargetDependencies(StringRef CPU, StringRef FS);

  void initSubtargetFeatures(StringRef CPU, StringRef FS);

  bool enableMachineScheduler() const override { return true; }

  const LanaiInstrInfo *getInstrInfo() const override { return &InstrInfo; }

  const TargetFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }

  const LanaiRegisterInfo *getRegisterInfo() const override {
    return &InstrInfo.getRegisterInfo();
  }

  const LanaiTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }

  const LanaiSelectionDAGInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }

private:
  LanaiFrameLowering FrameLowering;
  LanaiInstrInfo InstrInfo;
  LanaiTargetLowering TLInfo;
  LanaiSelectionDAGInfo TSInfo;
};
} // namespace llvm

#endif // LLVM_LIB_TARGET_LANAI_LANAISUBTARGET_H
