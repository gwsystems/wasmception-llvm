//===-- SparcTargetMachine.h - Define TargetMachine for Sparc ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Sparc specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef SPARCTARGETMACHINE_H
#define SPARCTARGETMACHINE_H

#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetFrameInfo.h"
#include "SparcInstrInfo.h"
#include "SparcSubtarget.h"
#include "SparcISelLowering.h"

namespace llvm {

class Module;

class SparcTargetMachine : public LLVMTargetMachine {
  const TargetData DataLayout;       // Calculates type size & alignment
  SparcSubtarget Subtarget;
  SparcTargetLowering TLInfo;
  SparcInstrInfo InstrInfo;
  TargetFrameInfo FrameInfo;
  
protected:
  virtual const TargetAsmInfo *createTargetAsmInfo() const;
  
public:
  SparcTargetMachine(const Target &T, const Module &M, const std::string &FS);

  virtual const SparcInstrInfo *getInstrInfo() const { return &InstrInfo; }
  virtual const TargetFrameInfo  *getFrameInfo() const { return &FrameInfo; }
  virtual const SparcSubtarget   *getSubtargetImpl() const{ return &Subtarget; }
  virtual const SparcRegisterInfo *getRegisterInfo() const {
    return &InstrInfo.getRegisterInfo();
  }
  virtual SparcTargetLowering* getTargetLowering() const {
    return const_cast<SparcTargetLowering*>(&TLInfo);
  }
  virtual const TargetData       *getTargetData() const { return &DataLayout; }

  // Pass Pipeline Configuration
  virtual bool addInstSelector(PassManagerBase &PM, CodeGenOpt::Level OptLevel);
  virtual bool addPreEmitPass(PassManagerBase &PM, CodeGenOpt::Level OptLevel);
  virtual bool addAssemblyEmitter(PassManagerBase &PM,
                                  CodeGenOpt::Level OptLevel,
                                  bool Verbose, formatted_raw_ostream &Out);
};

} // end namespace llvm

#endif
