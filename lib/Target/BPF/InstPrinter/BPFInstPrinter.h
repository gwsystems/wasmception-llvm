//===-- BPFInstPrinter.h - Convert BPF MCInst to asm syntax -------*- C++ -*--//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class prints a BPF MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BPF_INSTPRINTER_BPFINSTPRINTER_H
#define LLVM_LIB_TARGET_BPF_INSTPRINTER_BPFINSTPRINTER_H

#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
class BPFInstPrinter : public MCInstPrinter {
public:
  BPFInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                 const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot,
                 const MCSubtargetInfo &STI) override;
  void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O,
                    const char *Modifier = nullptr);
  void printMemOperand(const MCInst *MI, int OpNo, raw_ostream &O,
                       const char *Modifier = nullptr);
  void printImm64Operand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrTargetOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI, raw_ostream &O);
  static const char *getRegisterName(unsigned RegNo);
};
}

#endif
