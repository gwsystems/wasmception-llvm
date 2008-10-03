//===- Memory.cpp - Memory Handling Support ---------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines some helpful functions for allocating memory and dealing
// with memory mapped files
//
//===----------------------------------------------------------------------===//

#include "llvm/System/Memory.h"
#include "llvm/Config/config.h"

namespace llvm {
using namespace sys;
}

// Include the platform-specific parts of this class.
#ifdef LLVM_ON_UNIX
#include "Unix/Memory.inc"
#endif
#ifdef LLVM_ON_WIN32
#include "Win32/Memory.inc"
#endif

extern "C" void sys_icache_invalidate(const void *Addr, size_t len);

/// InvalidateInstructionCache - Before the JIT can run a block of code
/// that has been emitted it must invalidate the instruction cache on some
/// platforms.
void llvm::sys::Memory::InvalidateInstructionCache(const void *Addr,
                                                   size_t Len) {
  
// icache invalidation for PPC.
#if (defined(__POWERPC__) || defined (__ppc__) || \
     defined(_POWER) || defined(_ARCH_PPC))
   #if defined(__APPLE__)
       sys_icache_invalidate(Addr, Len);
   #elif defined(__GNUC__)
        const size_t LineSize = 32;

        const intptr_t Mask = ~(LineSize - 1);
        const intptr_t StartLine = ((intptr_t) Addr) & Mask;
        const intptr_t EndLine = ((intptr_t) Addr + Len + LineSize - 1) & Mask;

        for (intptr_t Line = StartLine; Line < EndLine; Line += LineSize)
          asm volatile("dcbf 0, %0" : : "r"(Line));
        asm volatile("sync");

        for (intptr_t Line = StartLine; Line < EndLine; Line += LineSize)
          asm volatile("icbi 0, %0" : : "r"(Line));
        asm volatile("isync");
   #endif
#endif  // end PPC

}
