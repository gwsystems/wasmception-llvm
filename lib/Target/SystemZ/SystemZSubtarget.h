//==-- SystemZSubtarget.h - Define Subtarget for the SystemZ ---*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the SystemZ specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_SystemZ_SUBTARGET_H
#define LLVM_TARGET_SystemZ_SUBTARGET_H

#include "llvm/Target/TargetSubtargetInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "SystemZGenSubtarget.inc"

namespace llvm {
class GlobalValue;
class TargetMachine;

class SystemZSubtarget : public SystemZGenSubtargetInfo {
  bool HasZ10Insts;
public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  SystemZSubtarget(const std::string &TT, const std::string &CPU,
                   const std::string &FS);

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(const std::string &FS, const std::string &CPU);

  bool isZ10() const { return HasZ10Insts; }

  bool GVRequiresExtraLoad(const GlobalValue* GV, const TargetMachine& TM,
                           bool isDirectCall) const;
};
} // End llvm namespace

#endif  // LLVM_TARGET_SystemZ_SUBTARGET_H
