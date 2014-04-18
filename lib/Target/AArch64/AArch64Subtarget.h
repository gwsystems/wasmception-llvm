//==-- AArch64Subtarget.h - Define Subtarget for the AArch64 ---*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the AArch64 specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_AARCH64_SUBTARGET_H
#define LLVM_TARGET_AARCH64_SUBTARGET_H

#include "llvm/ADT/Triple.h"
#include "llvm/Target/TargetSubtargetInfo.h"

#define GET_SUBTARGETINFO_HEADER
#include "AArch64GenSubtargetInfo.inc"

#include <string>

namespace llvm {
class StringRef;
class GlobalValue;

class AArch64Subtarget : public AArch64GenSubtargetInfo {
  virtual void anchor();
protected:
  enum ARMProcFamilyEnum {Others, CortexA53, CortexA57};

  /// ARMProcFamily - ARM processor family: Cortex-A53, Cortex-A57, and others.
  ARMProcFamilyEnum ARMProcFamily;

  bool HasFPARMv8;
  bool HasNEON;
  bool HasCrypto;

  /// AllowsUnalignedMem - If true, the subtarget allows unaligned memory
  /// accesses for some types.  For details, see
  /// AArch64TargetLowering::allowsUnalignedMemoryAccesses().
  bool AllowsUnalignedMem;

  /// TargetTriple - What processor and OS we're targeting.
  Triple TargetTriple;

  /// CPUString - String name of used CPU.
  std::string CPUString;

  /// IsLittleEndian - The target is Little Endian
  bool IsLittleEndian;

private:
  void initializeSubtargetFeatures(StringRef CPU, StringRef FS);

public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  AArch64Subtarget(StringRef TT, StringRef CPU, StringRef FS,
                   bool LittleEndian);

  virtual bool enableMachineScheduler() const {
    return true;
  }

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  bool GVIsIndirectSymbol(const GlobalValue *GV, Reloc::Model RelocM) const;

  bool isTargetELF() const { return TargetTriple.isOSBinFormatELF(); }
  bool isTargetLinux() const { return TargetTriple.isOSLinux(); }

  bool hasFPARMv8() const { return HasFPARMv8; }
  bool hasNEON() const { return HasNEON; }
  bool hasCrypto() const { return HasCrypto; }

  bool allowsUnalignedMem() const { return AllowsUnalignedMem; }

  bool isLittle() const { return IsLittleEndian; }

  const std::string & getCPUString() const { return CPUString; }
};
} // End llvm namespace

#endif  // LLVM_TARGET_AARCH64_SUBTARGET_H
