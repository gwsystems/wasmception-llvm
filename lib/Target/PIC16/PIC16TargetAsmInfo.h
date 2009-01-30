//=====-- PIC16TargetAsmInfo.h - PIC16 asm properties ---------*- C++ -*--====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source 
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the PIC16TargetAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef PIC16TARGETASMINFO_H
#define PIC16TARGETASMINFO_H

#include "llvm/Target/TargetAsmInfo.h"

namespace llvm {

  // Forward declaration.
  class PIC16TargetMachine;

  struct PIC16TargetAsmInfo : public TargetAsmInfo {
    PIC16TargetAsmInfo(const PIC16TargetMachine &TM);
    const char *RomData8bitsDirective;
    const char *RomData16bitsDirective;
    const char *RomData32bitsDirective;
    public :
    virtual const char *getData8bitsDirective(unsigned AddrSpace = 0) const;
    virtual const char *getData16bitsDirective(unsigned AddrSpace = 0) const;
    virtual const char *getData32bitsDirective(unsigned AddrSpace = 0) const;
  };

} // namespace llvm

#endif
