//===-- MSP430Subtarget.h - Define Subtarget for the MSP430 ----*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the MSP430 specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MSP430_MSP430SUBTARGET_H
#define LLVM_LIB_TARGET_MSP430_MSP430SUBTARGET_H

#include "MSP430FrameLowering.h"
#include "MSP430ISelLowering.h"
#include "MSP430InstrInfo.h"
#include "MSP430RegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "MSP430GenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class MSP430Subtarget : public MSP430GenSubtargetInfo {
public:
  enum HWMultEnum {
    NoHWMult, HWMult16, HWMult32, HWMultF5
  };

private:
  virtual void anchor();
  bool ExtendedInsts;
  HWMultEnum HWMultMode;
  MSP430FrameLowering FrameLowering;
  MSP430InstrInfo InstrInfo;
  MSP430TargetLowering TLInfo;
  SelectionDAGTargetInfo TSInfo;

public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  MSP430Subtarget(const Triple &TT, const std::string &CPU,
                  const std::string &FS, const TargetMachine &TM);

  MSP430Subtarget &initializeSubtargetDependencies(StringRef CPU, StringRef FS);

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  bool hasHWMult16() const { return HWMultMode == HWMult16; }
  bool hasHWMult32() const { return HWMultMode == HWMult32; }
  bool hasHWMultF5() const { return HWMultMode == HWMultF5; }

  const TargetFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const MSP430InstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const TargetRegisterInfo *getRegisterInfo() const override {
    return &InstrInfo.getRegisterInfo();
  }
  const MSP430TargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
};
} // End llvm namespace

#endif  // LLVM_TARGET_MSP430_SUBTARGET_H
