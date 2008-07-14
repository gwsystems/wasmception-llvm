//=====-- MipsSubtarget.h - Define Subtarget for the Mips -----*- C++ -*--====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Mips specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef MIPSSUBTARGET_H
#define MIPSSUBTARGET_H

#include "llvm/Target/TargetSubtarget.h"
#include "llvm/Target/TargetMachine.h"

#include <string>

namespace llvm {
class Module;

class MipsSubtarget : public TargetSubtarget {

public:
  enum MipsABIEnum {
    O32, O64, N32, N64, EABI
  }; 

protected:

  enum MipsArchEnum {
    Mips1, Mips2, Mips3, Mips4, Mips32, Mips32r2, Mips64, Mips64r2
  };

  // Mips architecture version 
  MipsArchEnum MipsArchVersion;

  // Mips supported ABIs 
  MipsABIEnum MipsABI;

  // IsLittle - The target is Little Endian
  bool IsLittle;

  // IsSingleFloat - The target only supports single precision float
  // point operations. This enable the target to use all 32 32-bit
  // floating point registers instead of only using even ones.
  bool IsSingleFloat;

  // IsFP64bit - The target processor has 64-bit floating point registers.
  bool IsFP64bit;

  // IsFP64bit - General-purpose registers are 64 bits wide
  bool IsGP64bit;

  // HasVFPU - Processor has a vector floating point unit.
  bool HasVFPU;

  // HasSEInReg - Target has SEB and SEH (signext in register) instructions.
  bool HasSEInReg;

  // IsABICall - Enable SRV4 code for SVR4-style dynamic objects 
  bool HasABICall;

  // HasAbsoluteCall - Enable code that is not fully position-independent.
  // Only works with HasABICall enabled.
  bool HasAbsoluteCall;

  // isLinux - Target system is Linux. Is false we consider ELFOS for now.
  bool IsLinux;

  InstrItineraryData InstrItins;

public:

  /// Only O32 and EABI supported right now.
  bool isABI_EABI() const { return MipsABI == EABI; }
  bool isABI_O32() const { return MipsABI == O32; }
  unsigned getTargetABI() const { return MipsABI; }

  /// This constructor initializes the data members to match that
  /// of the specified module.
  MipsSubtarget(const TargetMachine &TM, const Module &M, 
                const std::string &FS, bool little);
  
  /// ParseSubtargetFeatures - Parses features string setting specified 
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(const std::string &FS, const std::string &CPU);

  bool hasMips2Ops() const { return MipsArchVersion >= Mips2; }

  bool isLittle() const { return IsLittle; }
  bool isFP64bit() const { return IsFP64bit; };
  bool isGP64bit() const { return IsGP64bit; };
  bool isGP32bit() const { return !IsGP64bit; };
  bool isSingleFloat() const { return IsSingleFloat; };
  bool isNotSingleFloat() const { return !IsSingleFloat; };
  bool hasVFPU() const { return HasVFPU; };
  bool hasSEInReg() const { return HasSEInReg; };
  bool hasABICall() const { return HasABICall; };
  bool hasAbsoluteCall() const { return HasAbsoluteCall; };
  bool isLinux() const { return IsLinux; };

};
} // End llvm namespace

#endif
