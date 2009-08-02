//===-- CTargetMachine.h - TargetMachine for the C backend ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the TargetMachine that is used by the C backend.
//
//===----------------------------------------------------------------------===//

#ifndef CTARGETMACHINE_H
#define CTARGETMACHINE_H

#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetData.h"

namespace llvm {

struct CTargetMachine : public TargetMachine {
  const TargetData DataLayout;       // Calculates type size & alignment

  CTargetMachine(const Target &T, const Module &M,
                 const std::string &FS)
    : TargetMachine(T), DataLayout(&M) {}

  virtual bool WantsWholeFile() const { return true; }
  virtual bool addPassesToEmitWholeFile(PassManager &PM,
                                        formatted_raw_ostream &Out,
                                        CodeGenFileType FileType,
                                        CodeGenOpt::Level OptLevel);
  
  virtual const TargetData *getTargetData() const { return &DataLayout; }
};

extern Target TheCBackendTarget;

} // End llvm namespace


#endif
