//===-- PPCSubtarget.h - Define Subtarget for the PPC ----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the PowerPC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef POWERPCSUBTARGET_H
#define POWERPCSUBTARGET_H

#include "llvm/ADT/Triple.h"
#include "llvm/MC/MCInstrItineraries.h"
#include "llvm/Target/TargetSubtargetInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "PPCGenSubtargetInfo.inc"

// GCC #defines PPC on Linux but we use it as our namespace name
#undef PPC

namespace llvm {
class StringRef;

namespace PPC {
  // -m directive values.
  enum {
    DIR_NONE,
    DIR_32,
    DIR_440,
    DIR_601,
    DIR_602,
    DIR_603,
    DIR_7400,
    DIR_750,
    DIR_970,
    DIR_A2,
    DIR_E500mc,
    DIR_E5500,
    DIR_PWR3,
    DIR_PWR4,
    DIR_PWR5,
    DIR_PWR5X,
    DIR_PWR6,
    DIR_PWR6X,
    DIR_PWR7,
    DIR_64
  };
}

class GlobalValue;
class TargetMachine;

class PPCSubtarget : public PPCGenSubtargetInfo {
protected:
  /// stackAlignment - The minimum alignment known to hold of the stack frame on
  /// entry to the function and which must be maintained by every function.
  unsigned StackAlignment;

  /// Selected instruction itineraries (one entry per itinerary class.)
  InstrItineraryData InstrItins;

  /// Which cpu directive was used.
  unsigned DarwinDirective;

  /// Used by the ISel to turn in optimizations for POWER4-derived architectures
  bool HasMFOCRF;
  bool Has64BitSupport;
  bool Use64BitRegs;
  bool IsPPC64;
  bool HasAltivec;
  bool HasQPX;
  bool HasFSQRT;
  bool HasSTFIWX;
  bool HasLFIWAX;
  bool HasFPRND;
  bool HasISEL;
  bool HasPOPCNTD;
  bool HasLDBRX;
  bool IsBookE;
  bool HasLazyResolverStubs;
  bool IsJITCodeModel;

  /// TargetTriple - What processor and OS we're targeting.
  Triple TargetTriple;

public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  PPCSubtarget(const std::string &TT, const std::string &CPU,
               const std::string &FS, bool is64Bit);

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);

  /// SetJITMode - This is called to inform the subtarget info that we are
  /// producing code for the JIT.
  void SetJITMode();

  /// getStackAlignment - Returns the minimum alignment known to hold of the
  /// stack frame on entry to the function and which must be maintained by every
  /// function for this subtarget.
  unsigned getStackAlignment() const { return StackAlignment; }

  /// getDarwinDirective - Returns the -m directive specified for the cpu.
  ///
  unsigned getDarwinDirective() const { return DarwinDirective; }

  /// getInstrItins - Return the instruction itineraies based on subtarget
  /// selection.
  const InstrItineraryData &getInstrItineraryData() const { return InstrItins; }

  /// getDataLayoutString - Return the pointer size and type alignment
  /// properties of this subtarget.
  const char *getDataLayoutString() const {
    // Note, the alignment values for f64 and i64 on ppc64 in Darwin
    // documentation are wrong; these are correct (i.e. "what gcc does").
    if (isPPC64() && isSVR4ABI()) {
      if (TargetTriple.getOS() == llvm::Triple::FreeBSD)
        return "E-p:64:64-f64:64:64-i64:64:64-f128:64:64-v128:128:128-n32:64";
      else
        return "E-p:64:64-f64:64:64-i64:64:64-f128:128:128-v128:128:128-n32:64";
    }

    return isPPC64() ? "E-p:64:64-f64:64:64-i64:64:64-f128:64:128-n32:64"
                     : "E-p:32:32-f64:64:64-i64:64:64-f128:64:128-n32";
  }

  /// isPPC64 - Return true if we are generating code for 64-bit pointer mode.
  ///
  bool isPPC64() const { return IsPPC64; }

  /// has64BitSupport - Return true if the selected CPU supports 64-bit
  /// instructions, regardless of whether we are in 32-bit or 64-bit mode.
  bool has64BitSupport() const { return Has64BitSupport; }

  /// use64BitRegs - Return true if in 64-bit mode or if we should use 64-bit
  /// registers in 32-bit mode when possible.  This can only true if
  /// has64BitSupport() returns true.
  bool use64BitRegs() const { return Use64BitRegs; }

  /// hasLazyResolverStub - Return true if accesses to the specified global have
  /// to go through a dyld lazy resolution stub.  This means that an extra load
  /// is required to get the address of the global.
  bool hasLazyResolverStub(const GlobalValue *GV,
                           const TargetMachine &TM) const;

  // isJITCodeModel - True if we're generating code for the JIT
  bool isJITCodeModel() const { return IsJITCodeModel; }

  // Specific obvious features.
  bool hasFSQRT() const { return HasFSQRT; }
  bool hasSTFIWX() const { return HasSTFIWX; }
  bool hasLFIWAX() const { return HasLFIWAX; }
  bool hasFPRND() const { return HasFPRND; }
  bool hasAltivec() const { return HasAltivec; }
  bool hasQPX() const { return HasQPX; }
  bool hasMFOCRF() const { return HasMFOCRF; }
  bool hasISEL() const { return HasISEL; }
  bool hasPOPCNTD() const { return HasPOPCNTD; }
  bool hasLDBRX() const { return HasLDBRX; }
  bool isBookE() const { return IsBookE; }

  const Triple &getTargetTriple() const { return TargetTriple; }

  /// isDarwin - True if this is any darwin platform.
  bool isDarwin() const { return TargetTriple.isMacOSX(); }
  /// isBGP - True if this is a BG/P platform.
  bool isBGP() const { return TargetTriple.getVendor() == Triple::BGP; }
  /// isBGQ - True if this is a BG/Q platform.
  bool isBGQ() const { return TargetTriple.getVendor() == Triple::BGQ; }

  bool isDarwinABI() const { return isDarwin(); }
  bool isSVR4ABI() const { return !isDarwin(); }

  /// enablePostRAScheduler - True at 'More' optimization.
  bool enablePostRAScheduler(CodeGenOpt::Level OptLevel,
                             TargetSubtargetInfo::AntiDepBreakMode& Mode,
                             RegClassVector& CriticalPathRCs) const;
};
} // End llvm namespace

#endif
