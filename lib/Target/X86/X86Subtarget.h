//=====---- X86Subtarget.h - Define Subtarget for the X86 -----*- C++ -*--====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the X86 specific subclass of TargetSubtarget.
//
//===----------------------------------------------------------------------===//

#ifndef X86SUBTARGET_H
#define X86SUBTARGET_H

#include "llvm/Target/TargetSubtarget.h"
#include <string>

namespace llvm {
class GlobalValue;
class TargetMachine;
  
/// PICStyles - The X86 backend supports a number of different styles of PIC.
/// 
namespace PICStyles {
enum Style {
  StubPIC,          // Used on i386-darwin in -fPIC mode.
  StubDynamicNoPIC, // Used on i386-darwin in -mdynamic-no-pic mode.
  GOT,              // Used on many 32-bit unices in -fPIC mode.
  RIPRel,           // Used on X86-64 when not in -static mode.
  None              // Set when in -static mode (not PIC or DynamicNoPIC mode).
};
}

class X86Subtarget : public TargetSubtarget {
protected:
  enum X86SSEEnum {
    NoMMXSSE, MMX, SSE1, SSE2, SSE3, SSSE3, SSE41, SSE42
  };

  enum X863DNowEnum {
    NoThreeDNow, ThreeDNow, ThreeDNowA
  };

  /// PICStyle - Which PIC style to use
  ///
  PICStyles::Style PICStyle;
  
  /// X86SSELevel - MMX, SSE1, SSE2, SSE3, SSSE3, SSE41, SSE42, or
  /// none supported.
  X86SSEEnum X86SSELevel;

  /// X863DNowLevel - 3DNow or 3DNow Athlon, or none supported.
  ///
  X863DNowEnum X863DNowLevel;

  /// HasCMov - True if this processor has conditional move instructions
  /// (generally pentium pro+).
  bool HasCMov;
  
  /// HasX86_64 - True if the processor supports X86-64 instructions.
  ///
  bool HasX86_64;

  /// HasSSE4A - True if the processor supports SSE4A instructions.
  bool HasSSE4A;

  /// HasAVX - Target has AVX instructions
  bool HasAVX;

  /// HasFMA3 - Target has 3-operand fused multiply-add
  bool HasFMA3;

  /// HasFMA4 - Target has 4-operand fused multiply-add
  bool HasFMA4;

  /// IsBTMemSlow - True if BT (bit test) of memory instructions are slow.
  bool IsBTMemSlow;
  
  /// DarwinVers - Nonzero if this is a darwin platform: the numeric
  /// version of the platform, e.g. 8 = 10.4 (Tiger), 9 = 10.5 (Leopard), etc.
  unsigned char DarwinVers; // Is any darwin-x86 platform.

  /// stackAlignment - The minimum alignment known to hold of the stack frame on
  /// entry to the function and which must be maintained by every function.
  unsigned stackAlignment;

  /// Max. memset / memcpy size that is turned into rep/movs, rep/stos ops.
  ///
  unsigned MaxInlineSizeThreshold;

private:
  /// Is64Bit - True if the processor supports 64-bit instructions and
  /// pointer size is 64 bit.
  bool Is64Bit;

public:
  enum {
    isELF, isCygwin, isDarwin, isWindows, isMingw
  } TargetType;

  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  X86Subtarget(const std::string &TT, const std::string &FS, bool is64Bit);

  /// getStackAlignment - Returns the minimum alignment known to hold of the
  /// stack frame on entry to the function and which must be maintained by every
  /// function for this subtarget.
  unsigned getStackAlignment() const { return stackAlignment; }

  /// getMaxInlineSizeThreshold - Returns the maximum memset / memcpy size
  /// that still makes it profitable to inline the call.
  unsigned getMaxInlineSizeThreshold() const { return MaxInlineSizeThreshold; }

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  std::string ParseSubtargetFeatures(const std::string &FS,
                                     const std::string &CPU);

  /// AutoDetectSubtargetFeatures - Auto-detect CPU features using CPUID
  /// instruction.
  void AutoDetectSubtargetFeatures();

  bool is64Bit() const { return Is64Bit; }

  PICStyles::Style getPICStyle() const { return PICStyle; }
  void setPICStyle(PICStyles::Style Style)  { PICStyle = Style; }

  bool hasMMX() const { return X86SSELevel >= MMX; }
  bool hasSSE1() const { return X86SSELevel >= SSE1; }
  bool hasSSE2() const { return X86SSELevel >= SSE2; }
  bool hasSSE3() const { return X86SSELevel >= SSE3; }
  bool hasSSSE3() const { return X86SSELevel >= SSSE3; }
  bool hasSSE41() const { return X86SSELevel >= SSE41; }
  bool hasSSE42() const { return X86SSELevel >= SSE42; }
  bool hasSSE4A() const { return HasSSE4A; }
  bool has3DNow() const { return X863DNowLevel >= ThreeDNow; }
  bool has3DNowA() const { return X863DNowLevel >= ThreeDNowA; }
  bool hasAVX() const { return HasAVX; }
  bool hasFMA3() const { return HasFMA3; }
  bool hasFMA4() const { return HasFMA4; }
  bool isBTMemSlow() const { return IsBTMemSlow; }

  bool isTargetDarwin() const { return TargetType == isDarwin; }
  bool isTargetELF() const { return TargetType == isELF; }
  
  bool isTargetWindows() const { return TargetType == isWindows; }
  bool isTargetMingw() const { return TargetType == isMingw; }
  bool isTargetCygwin() const { return TargetType == isCygwin; }
  bool isTargetCygMing() const {
    return TargetType == isMingw || TargetType == isCygwin;
  }
  
  /// isTargetCOFF - Return true if this is any COFF/Windows target variant.
  bool isTargetCOFF() const {
    return TargetType == isMingw || TargetType == isCygwin ||
           TargetType == isWindows;
  }
  
  bool isTargetWin64() const {
    return Is64Bit && (TargetType == isMingw || TargetType == isWindows);
  }

  std::string getDataLayout() const {
    const char *p;
    if (is64Bit())
      p = "e-p:64:64-s:64-f64:64:64-i64:64:64-f80:128:128-n8:16:32:64";
    else if (isTargetDarwin())
      p = "e-p:32:32-f64:32:64-i64:32:64-f80:128:128-n8:16:32";
    else
      p = "e-p:32:32-f64:32:64-i64:32:64-f80:32:32-n8:16:32";
    return std::string(p);
  }

  bool isPICStyleSet() const { return PICStyle != PICStyles::None; }
  bool isPICStyleGOT() const { return PICStyle == PICStyles::GOT; }
  bool isPICStyleRIPRel() const { return PICStyle == PICStyles::RIPRel; }

  bool isPICStyleStubPIC() const {
    return PICStyle == PICStyles::StubPIC;
  }

  bool isPICStyleStubNoDynamic() const {
    return PICStyle == PICStyles::StubDynamicNoPIC;
  }
  bool isPICStyleStubAny() const {
    return PICStyle == PICStyles::StubDynamicNoPIC ||
           PICStyle == PICStyles::StubPIC; }
  
  /// getDarwinVers - Return the darwin version number, 8 = Tiger, 9 = Leopard,
  /// 10 = Snow Leopard, etc.
  unsigned getDarwinVers() const { return DarwinVers; }
    
  /// ClassifyGlobalReference - Classify a global variable reference for the
  /// current subtarget according to how we should reference it in a non-pcrel
  /// context.
  unsigned char ClassifyGlobalReference(const GlobalValue *GV,
                                        const TargetMachine &TM)const;

  /// IsLegalToCallImmediateAddr - Return true if the subtarget allows calls
  /// to immediate address.
  bool IsLegalToCallImmediateAddr(const TargetMachine &TM) const;

  /// This function returns the name of a function which has an interface
  /// like the non-standard bzero function, if such a function exists on
  /// the current subtarget and it is considered prefereable over
  /// memset with zero passed as the second argument. Otherwise it
  /// returns null.
  const char *getBZeroEntry() const;

  /// getSpecialAddressLatency - For targets where it is beneficial to
  /// backschedule instructions that compute addresses, return a value
  /// indicating the number of scheduling cycles of backscheduling that
  /// should be attempted.
  unsigned getSpecialAddressLatency() const;

  /// enablePostRAScheduler - X86 target is enabling post-alloc scheduling
  /// at 'More' optimization level.
  bool enablePostRAScheduler(CodeGenOpt::Level OptLevel,
                             TargetSubtarget::AntiDepBreakMode& Mode,
                             ExcludedRCVector& ExcludedRCs) const;
};

} // End llvm namespace

#endif
