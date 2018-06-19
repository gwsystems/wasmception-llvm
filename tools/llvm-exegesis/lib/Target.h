//===-- Target.h ------------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
///
/// Classes that handle the creation of target-specific objects. This is
/// similar to llvm::Target/TargetRegistry.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_EXEGESIS_TARGET_H
#define LLVM_TOOLS_LLVM_EXEGESIS_TARGET_H

#include "llvm/ADT/Triple.h"

namespace exegesis {

class ExegesisTarget {
public:
  // Returns the ExegesisTarget for the given triple or nullptr if the target
  // does not exist.
  static const ExegesisTarget* lookup(llvm::StringRef TT);
  // Registers a target. Not thread safe.
  static void registerTarget(ExegesisTarget *T);

  ~ExegesisTarget();

private:
  virtual bool matchesArch(llvm::Triple::ArchType Arch) const = 0;
  const ExegesisTarget* Next = nullptr;
};

}  // namespace exegesis

#endif // LLVM_TOOLS_LLVM_EXEGESIS_TARGET_H
