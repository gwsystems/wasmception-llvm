//===- llvm/System/Atomic.h - Atomic Operations -----------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the llvm::sys atomic operations.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SYSTEM_ATOMIC_H
#define LLVM_SYSTEM_ATOMIC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
  namespace sys {
    void MemoryFence();

    typedef uint32_t cas_flag;
    cas_flag CompareAndSwap(volatile cas_flag* ptr,
                            cas_flag new_value,
                            cas_flag old_value);
    cas_flag AtomicPostIncrement(volatile cas_flag* ptr);
    cas_flag AtomicPostDecrement(volatile cas_flag* ptr);
  }
}

#endif
