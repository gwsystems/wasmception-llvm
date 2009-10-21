//===-- MSP430InstPrinter.h - Convert MSP430 MCInst to assembly syntax ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints a MSP430 MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef MSP430INSTPRINTER_H
#define MSP430INSTPRINTER_H

#include "llvm/MC/MCInstPrinter.h"

namespace llvm
{

  class MCOperand;

  class MSP430InstPrinter : public MCInstPrinter {
  public:
    MSP430InstPrinter(raw_ostream &O, const MCAsmInfo &MAI) :
      MCInstPrinter(O, MAI){
    }

    virtual void printInst(const MCInst *MI);

    // Autogenerated by tblgen.
    void printInstruction(const MCInst *MI);
    static const char *getRegisterName(unsigned RegNo);

    void printOperand(const MCInst *MI, unsigned OpNo,
                      const char *Modifier = 0);

    void printSrcMemOperand(const MCInst *MI, unsigned OpNo,
                            const char *Modifier = 0) {
    }
    void printCCOperand(const MCInst *MI, unsigned OpNo) {
    }

  };
}

#endif
