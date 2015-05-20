//===-- MipsMCAsmInfo.h - Mips Asm Info ------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the MipsMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MIPS_MCTARGETDESC_MIPSMCASMINFO_H
#define LLVM_LIB_TARGET_MIPS_MCTARGETDESC_MIPSMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
  class StringRef;
  class MipsABIInfo;
  class LLVMTargetMachine;

  class MipsMCAsmInfo : public MCAsmInfoELF {
    void anchor() override;
  public:
    explicit MipsMCAsmInfo(StringRef TT);

    void finishInit(const LLVMTargetMachine &TM) override;
  };

} // namespace llvm

#endif
