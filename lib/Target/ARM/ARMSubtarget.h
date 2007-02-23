//=====---- ARMSubtarget.h - Define Subtarget for the ARM -----*- C++ -*--====//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Evan Cheng and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the ARM specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef ARMSUBTARGET_H
#define ARMSUBTARGET_H

#include "llvm/Target/TargetSubtarget.h"
#include <string>

namespace llvm {
class Module;

class ARMSubtarget : public TargetSubtarget {
protected:
  enum ARMArchEnum {
    V4T, V5T, V5TE, V6
  };

  /// ARMArchVersion - ARM architecture vecrsion: V4T (base), V5T, V5TE,
  /// and V6.
  ARMArchEnum ARMArchVersion;

  /// HasVFP2 - True if the processor supports Vector Floating Point (VFP) V2
  /// instructions.
  bool HasVFP2;

  /// IsThumb - True if we are in thumb mode, false if in ARM mode.
  bool IsThumb;

  /// UseThumbBacktraces - True if we use thumb style backtraces.
  bool UseThumbBacktraces;

  /// IsR9Reserved - True if R9 is a not available as general purpose register.
  bool IsR9Reserved;

  /// stackAlignment - The minimum alignment known to hold of the stack frame on
  /// entry to the function and which must be maintained by every function.
  unsigned stackAlignment;

 public:
  enum {
    isELF, isDarwin
  } TargetType;

  enum {
    ARM_ABI_APCS,
    ARM_ABI_AAPCS // ARM EABI
  } TargetABI;

  /// This constructor initializes the data members to match that
  /// of the specified module.
  ///
  ARMSubtarget(const Module &M, const std::string &FS, bool thumb);

  /// ParseSubtargetFeatures - Parses features string setting specified 
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(const std::string &FS, const std::string &CPU);

  bool hasV4TOps()  const { return ARMArchVersion >= V4T; }
  bool hasV5TOps()  const { return ARMArchVersion >= V5T; }
  bool hasV5TEOps() const { return ARMArchVersion >= V5TE; }
  bool hasV6Ops()   const { return ARMArchVersion >= V6; }

  bool hasVFP2() const { return HasVFP2; }
  
  bool isTargetDarwin() const { return TargetType == isDarwin; }
  bool isTargetELF() const { return TargetType == isELF; }

  bool isAPCS_ABI() const { return TargetABI == ARM_ABI_APCS; }
  bool isAAPCS_ABI() const { return TargetABI == ARM_ABI_AAPCS; }

  bool isThumb() const { return IsThumb; }

  bool useThumbBacktraces() const { return UseThumbBacktraces; }
  bool isR9Reserved() const { return IsR9Reserved; }

  /// getStackAlignment - Returns the minimum alignment known to hold of the
  /// stack frame on entry to the function and which must be maintained by every
  /// function for this subtarget.
  unsigned getStackAlignment() const { return stackAlignment; }
};
} // End llvm namespace

#endif  // ARMSUBTARGET_H
