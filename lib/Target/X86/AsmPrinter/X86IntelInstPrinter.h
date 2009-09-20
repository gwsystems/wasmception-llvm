//===-- X86IntelInstPrinter.h - Convert X86 MCInst to assembly syntax -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an X86 MCInst to intel style .s file syntax.
//
//===----------------------------------------------------------------------===//

#ifndef X86_INTEL_INST_PRINTER_H
#define X86_INTEL_INST_PRINTER_H

#include "llvm/MC/MCInstPrinter.h"
#include "llvm/Support/raw_ostream.h"

namespace llvm {
  class MCOperand;
  
class X86IntelInstPrinter : public MCInstPrinter {
public:
  X86IntelInstPrinter(raw_ostream &O, const MCAsmInfo &MAI)
    : MCInstPrinter(O, MAI) {}
  
  virtual void printInst(const MCInst *MI);
  
  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI);
  static const char *getRegisterName(unsigned RegNo);


  void printOperand(const MCInst *MI, unsigned OpNo,
                    const char *Modifier = 0);
  void printMemReference(const MCInst *MI, unsigned Op);
  void printLeaMemReference(const MCInst *MI, unsigned Op);
  void printSSECC(const MCInst *MI, unsigned Op);
  void printPICLabel(const MCInst *MI, unsigned Op);
  void print_pcrel_imm(const MCInst *MI, unsigned OpNo);
  
  void printopaquemem(const MCInst *MI, unsigned OpNo) {
    O << "OPAQUE PTR ";
    printMemReference(MI, OpNo);
  }
  
  void printi8mem(const MCInst *MI, unsigned OpNo) {
    O << "BYTE PTR ";
    printMemReference(MI, OpNo);
  }
  void printi16mem(const MCInst *MI, unsigned OpNo) {
    O << "WORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printi32mem(const MCInst *MI, unsigned OpNo) {
    O << "DWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printi64mem(const MCInst *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printi128mem(const MCInst *MI, unsigned OpNo) {
    O << "XMMWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf32mem(const MCInst *MI, unsigned OpNo) {
    O << "DWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf64mem(const MCInst *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf80mem(const MCInst *MI, unsigned OpNo) {
    O << "XWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf128mem(const MCInst *MI, unsigned OpNo) {
    O << "XMMWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printlea32mem(const MCInst *MI, unsigned OpNo) {
    O << "DWORD PTR ";
    printLeaMemReference(MI, OpNo);
  }
  void printlea64mem(const MCInst *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printLeaMemReference(MI, OpNo);
  }
  void printlea64_32mem(const MCInst *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printLeaMemReference(MI, OpNo);
  }
};
  
}

#endif
