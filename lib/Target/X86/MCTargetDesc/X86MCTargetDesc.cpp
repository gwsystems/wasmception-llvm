//===-- X86MCTargetDesc.cpp - X86 Target Descriptions -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides X86 specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "X86MCTargetDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Target/TargetRegistry.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Support/Host.h"

#define GET_REGINFO_MC_DESC
#include "X86GenRegisterInfo.inc"

#define GET_INSTRINFO_MC_DESC
#include "X86GenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#define GET_SUBTARGETINFO_MC_DESC
#include "X86GenSubtargetInfo.inc"

using namespace llvm;


std::string X86_MC::ParseX86Triple(StringRef TT) {
  Triple TheTriple(TT);
  if (TheTriple.getArch() == Triple::x86_64)
    return "+64bit-mode";
  return "-64bit-mode";
}

/// GetCpuIDAndInfo - Execute the specified cpuid and return the 4 values in the
/// specified arguments.  If we can't run cpuid on the host, return true.
bool X86_MC::GetCpuIDAndInfo(unsigned value, unsigned *rEAX,
                             unsigned *rEBX, unsigned *rECX, unsigned *rEDX) {
#if defined(__x86_64__) || defined(_M_AMD64) || defined (_M_X64)
  #if defined(__GNUC__)
    // gcc doesn't know cpuid would clobber ebx/rbx. Preseve it manually.
    asm ("movq\t%%rbx, %%rsi\n\t"
         "cpuid\n\t"
         "xchgq\t%%rbx, %%rsi\n\t"
         : "=a" (*rEAX),
           "=S" (*rEBX),
           "=c" (*rECX),
           "=d" (*rEDX)
         :  "a" (value));
    return false;
  #elif defined(_MSC_VER)
    int registers[4];
    __cpuid(registers, value);
    *rEAX = registers[0];
    *rEBX = registers[1];
    *rECX = registers[2];
    *rEDX = registers[3];
    return false;
  #endif
#elif defined(i386) || defined(__i386__) || defined(__x86__) || defined(_M_IX86)
  #if defined(__GNUC__)
    asm ("movl\t%%ebx, %%esi\n\t"
         "cpuid\n\t"
         "xchgl\t%%ebx, %%esi\n\t"
         : "=a" (*rEAX),
           "=S" (*rEBX),
           "=c" (*rECX),
           "=d" (*rEDX)
         :  "a" (value));
    return false;
  #elif defined(_MSC_VER)
    __asm {
      mov   eax,value
      cpuid
      mov   esi,rEAX
      mov   dword ptr [esi],eax
      mov   esi,rEBX
      mov   dword ptr [esi],ebx
      mov   esi,rECX
      mov   dword ptr [esi],ecx
      mov   esi,rEDX
      mov   dword ptr [esi],edx
    }
    return false;
  #endif
#endif
  return true;
}

void X86_MC::DetectFamilyModel(unsigned EAX, unsigned &Family,
                               unsigned &Model) {
  Family = (EAX >> 8) & 0xf; // Bits 8 - 11
  Model  = (EAX >> 4) & 0xf; // Bits 4 - 7
  if (Family == 6 || Family == 0xf) {
    if (Family == 0xf)
      // Examine extended family ID if family ID is F.
      Family += (EAX >> 20) & 0xff;    // Bits 20 - 27
    // Examine extended model ID if family ID is 6 or F.
    Model += ((EAX >> 16) & 0xf) << 4; // Bits 16 - 19
  }
}

static bool hasX86_64() {
  // FIXME: Code duplication. See X86Subtarget::AutoDetectSubtargetFeatures.
  unsigned EAX = 0, EBX = 0, ECX = 0, EDX = 0;
  union {
    unsigned u[3];
    char     c[12];
  } text;
  
  if (X86_MC::GetCpuIDAndInfo(0, &EAX, text.u+0, text.u+2, text.u+1))
    return false;

  bool IsIntel = memcmp(text.c, "GenuineIntel", 12) == 0;
  bool IsAMD   = !IsIntel && memcmp(text.c, "AuthenticAMD", 12) == 0;
  if (IsIntel || IsAMD) {
    X86_MC::GetCpuIDAndInfo(0x80000001, &EAX, &EBX, &ECX, &EDX);
    if ((EDX >> 29) & 0x1)
      return true;
  }

  return false;
}

MCSubtargetInfo *X86_MC::createX86MCSubtargetInfo(StringRef TT, StringRef CPU,
                                                  StringRef FS) {
  std::string ArchFS = X86_MC::ParseX86Triple(TT);
  if (!FS.empty()) {
    if (!ArchFS.empty())
      ArchFS = ArchFS + "," + FS.str();
    else
      ArchFS = FS;
  }

  std::string CPUName = CPU;
  if (CPUName.empty()) {
#if defined (__x86_64__) || defined(__i386__)
    CPUName = sys::getHostCPUName();
#else
    CPUName = "generic";
#endif
  }

  if (ArchFS.empty() && CPUName.empty() && hasX86_64())
    // Auto-detect if host is 64-bit capable, it's the default if true.
    ArchFS = "+64bit-mode";

  MCSubtargetInfo *X = new MCSubtargetInfo();
  InitX86MCSubtargetInfo(X, CPUName, ArchFS);
  return X;
}

MCInstrInfo *createX86MCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitX86MCInstrInfo(X);
  return X;
}

MCRegisterInfo *createX86MCRegisterInfo() {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitX86MCRegisterInfo(X);
  return X;
}

// Force static initialization.
extern "C" void LLVMInitializeX86MCInstrInfo() {
  RegisterMCInstrInfo<MCInstrInfo> X(TheX86_32Target);
  RegisterMCInstrInfo<MCInstrInfo> Y(TheX86_64Target);

  TargetRegistry::RegisterMCInstrInfo(TheX86_32Target, createX86MCInstrInfo);
  TargetRegistry::RegisterMCInstrInfo(TheX86_64Target, createX86MCInstrInfo);
}

extern "C" void LLVMInitializeX86MCRegInfo() {
  RegisterMCRegInfo<MCRegisterInfo> X(TheX86_32Target);
  RegisterMCRegInfo<MCRegisterInfo> Y(TheX86_64Target);

  TargetRegistry::RegisterMCRegInfo(TheX86_32Target, createX86MCRegisterInfo);
  TargetRegistry::RegisterMCRegInfo(TheX86_64Target, createX86MCRegisterInfo);
}
