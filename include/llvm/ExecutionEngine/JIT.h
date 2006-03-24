//===- ExecutionEngine.h - Abstract Execution Engine Interface --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Jeff Cohen and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file forces the interpreter to link in on certain operating systems.
// (Windows).
//
//===----------------------------------------------------------------------===//

#ifndef EXECUTION_ENGINE_JIT_H
#define EXECUTION_ENGINE_JIT_H

#include "llvm/ExecutionEngine/ExecutionEngine.h"

namespace llvm {
  extern void LinkInJIT();
}

namespace {
  struct ForceJITLinking {
    ForceJITLinking() {
      // We must reference the passes in such a way that compilers will not
      // delete it all as dead code, even with whole program optimization,
      // yet is effectively a NO-OP. As the compiler isn't smart enough
      // to know that getenv() never returns -1, this will do the job.
      if (std::getenv("bar") != (char*) -1)
        return;

      llvm::LinkInJIT();
    }
  } ForceJITLinking;
}

#endif
