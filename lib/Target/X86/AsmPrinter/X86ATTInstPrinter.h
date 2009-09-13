//===-- X86ATTInstPrinter.h - Convert X86 MCInst to assembly syntax -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an X86 MCInst to AT&T style .s file syntax.
//
//===----------------------------------------------------------------------===//

#ifndef X86_ATT_INST_PRINTER_H
#define X86_ATT_INST_PRINTER_H

namespace llvm {
  class MCAsmInfo;
  class MCInst;
  class MCOperand;
  class raw_ostream;
  class TargetRegisterInfo; // FIXME: ELIM
  
class X86ATTInstPrinter {
  raw_ostream &O;
  const MCAsmInfo *MAI;
  const TargetRegisterInfo *TRI;  // FIXME: Elim.
public:
  X86ATTInstPrinter(raw_ostream &o, const MCAsmInfo *mai,
                    const TargetRegisterInfo *tri) : O(o), MAI(mai), TRI(tri) {}
  
  void printInstruction(const MCInst *MI);

  void printOperand(const MCInst *MI, unsigned OpNo,
                    const char *Modifier = 0);
  void printMemReference(const MCInst *MI, unsigned Op);
  void printLeaMemReference(const MCInst *MI, unsigned Op);
  void printSSECC(const MCInst *MI, unsigned Op);
  void printPICLabel(const MCInst *MI, unsigned Op);
  void print_pcrel_imm(const MCInst *MI, unsigned OpNo);
  
  void printopaquemem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  
  void printi8mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi16mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi32mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi64mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi128mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf32mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf64mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf80mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf128mem(const MCInst *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printlea32mem(const MCInst *MI, unsigned OpNo) {
    printLeaMemReference(MI, OpNo);
  }
  void printlea64mem(const MCInst *MI, unsigned OpNo) {
    printLeaMemReference(MI, OpNo);
  }
  void printlea64_32mem(const MCInst *MI, unsigned OpNo) {
    printLeaMemReference(MI, OpNo);
  }
};
  
}

#endif
