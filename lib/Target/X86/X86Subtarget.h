//=====---- X86Subtarget.h - Define Subtarget for the X86 -----*- C++ -*--====//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Nate Begeman and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
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
class Module;

class X86Subtarget : public TargetSubtarget {
protected:
  enum X86SSEEnum {
    NoMMXSSE, MMX, SSE1, SSE2, SSE3
  };

  enum X863DNowEnum {
    NoThreeDNow, ThreeDNow, ThreeDNowA
  };

  /// X86SSELevel - MMX, SSE1, SSE2, SSE3, or none supported.
  X86SSEEnum X86SSELevel;

  /// X863DNowLevel - 3DNow or 3DNow Athlon, or none supported.
  X863DNowEnum X863DNowLevel;

  /// Is64Bit - True if the processor supports Em64T.
  bool Is64Bit;

  /// stackAlignment - The minimum alignment known to hold of the stack frame on
  /// entry to the function and which must be maintained by every function.
  unsigned stackAlignment;

  /// Min. memset / memcpy size that is turned into rep/movs, rep/stos ops.
  unsigned MinRepStrSizeThreshold;

public:
  enum {
    isELF, isCygwin, isDarwin, isWindows
  } TargetType;
    
  /// This constructor initializes the data members to match that
  /// of the specified module.
  ///
  X86Subtarget(const Module &M, const std::string &FS);

  /// getStackAlignment - Returns the minimum alignment known to hold of the
  /// stack frame on entry to the function and which must be maintained by every
  /// function for this subtarget.
  unsigned getStackAlignment() const { return stackAlignment; }

  /// getMinRepStrSizeThreshold - Returns the minimum memset / memcpy size
  /// required to turn the operation into a X86 rep/movs or rep/stos
  /// instruction. This is only used if the src / dst alignment is not DWORD
  /// aligned.
  unsigned getMinRepStrSizeThreshold() const { return MinRepStrSizeThreshold; }
 
  /// ParseSubtargetFeatures - Parses features string setting specified 
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(const std::string &FS, const std::string &CPU);

  bool is64Bit() const { return Is64Bit; }

  bool hasMMX() const { return X86SSELevel >= MMX; }
  bool hasSSE1() const { return X86SSELevel >= SSE1; }
  bool hasSSE2() const { return X86SSELevel >= SSE2; }
  bool hasSSE3() const { return X86SSELevel >= SSE3; }
  bool has3DNow() const { return X863DNowLevel >= ThreeDNow; }
  bool has3DNowA() const { return X863DNowLevel >= ThreeDNowA; }

  bool isTargetDarwin() const { return TargetType == isDarwin; }
  bool isTargetELF() const { return TargetType == isELF; }
};
} // End llvm namespace

#endif
