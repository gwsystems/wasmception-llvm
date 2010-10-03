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

#include "llvm/ADT/Triple.h"
#include "llvm/Target/TargetSubtarget.h"
#include "llvm/CallingConv.h"
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

  /// HasAES - Target has AES instructions
  bool HasAES;

  /// HasCLMUL - Target has carry-less multiplication
  bool HasCLMUL;

  /// HasFMA3 - Target has 3-operand fused multiply-add
  bool HasFMA3;

  /// HasFMA4 - Target has 4-operand fused multiply-add
  bool HasFMA4;

  /// IsBTMemSlow - True if BT (bit test) of memory instructions are slow.
  bool IsBTMemSlow;

  /// IsUAMemFast - True if unaligned memory access is fast.
  bool IsUAMemFast;

  /// HasVectorUAMem - True if SIMD operations can have unaligned memory
  /// operands. This may require setting a feature bit in the processor.
  bool HasVectorUAMem;

  /// stackAlignment - The minimum alignment known to hold of the stack frame on
  /// entry to the function and which must be maintained by every function.
  unsigned stackAlignment;

  /// Max. memset / memcpy size that is turned into rep/movs, rep/stos ops.
  ///
  unsigned MaxInlineSizeThreshold;
  
  /// TargetTriple - What processor and OS we're targeting.
  Triple TargetTriple;

private:
  /// Is64Bit - True if the processor supports 64-bit instructions and
  /// pointer size is 64 bit.
  bool Is64Bit;

public:

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

  bool hasCMov() const { return HasCMov; }
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
  bool hasAES() const { return HasAES; }
  bool hasCLMUL() const { return HasCLMUL; }
  bool hasFMA3() const { return HasFMA3; }
  bool hasFMA4() const { return HasFMA4; }
  bool isBTMemSlow() const { return IsBTMemSlow; }
  bool isUnalignedMemAccessFast() const { return IsUAMemFast; }
  bool hasVectorUAMem() const { return HasVectorUAMem; }

  bool isTargetDarwin() const { return TargetTriple.getOS() == Triple::Darwin; }
  
  // ELF is a reasonably sane default and the only other X86 targets we
  // support are Darwin and Windows. Just use "not those".
  bool isTargetELF() const { 
    return !isTargetDarwin() && !isTargetWindows() && !isTargetCygMing();
  }
  bool isTargetLinux() const { return TargetTriple.getOS() == Triple::Linux; }

  bool isTargetWindows() const { return TargetTriple.getOS() == Triple::Win32; }
  bool isTargetMingw() const { 
    return TargetTriple.getOS() == Triple::MinGW32 ||
           TargetTriple.getOS() == Triple::MinGW64; }
  bool isTargetCygwin() const { return TargetTriple.getOS() == Triple::Cygwin; }
  bool isTargetCygMing() const {
    return isTargetMingw() || isTargetCygwin();
  }
  
  /// isTargetCOFF - Return true if this is any COFF/Windows target variant.
  bool isTargetCOFF() const {
    return isTargetMingw() || isTargetCygwin() || isTargetWindows();
  }

  bool isTargetWin64() const {
    return Is64Bit && (isTargetMingw() || isTargetWindows());
  }

  bool isTargetWin32() const {
    return !Is64Bit && (isTargetMingw() || isTargetWindows());
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
  unsigned getDarwinVers() const {
    if (isTargetDarwin()) return TargetTriple.getDarwinMajorNumber();
    return 0;
  }

  /// ClassifyGlobalReference - Classify a global variable reference for the
  /// current subtarget according to how we should reference it in a non-pcrel
  /// context.
  unsigned char ClassifyGlobalReference(const GlobalValue *GV,
                                        const TargetMachine &TM)const;

  /// ClassifyBlockAddressReference - Classify a blockaddress reference for the
  /// current subtarget according to how we should reference it in a non-pcrel
  /// context.
  unsigned char ClassifyBlockAddressReference() const;

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

  /// IsCalleePop - Test whether a function should pop its own arguments.
  bool IsCalleePop(bool isVarArg, CallingConv::ID CallConv) const;
};

} // End llvm namespace

#endif
