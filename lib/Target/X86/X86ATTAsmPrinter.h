//===-- X86ATTAsmPrinter.h - Convert X86 LLVM code to Intel assembly ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// AT&T assembly code printer class.
//
//===----------------------------------------------------------------------===//

#ifndef X86ATTASMPRINTER_H
#define X86ATTASMPRINTER_H

#include "X86AsmPrinter.h"
#include "llvm/CodeGen/ValueTypes.h"

namespace llvm {
namespace x86 {

struct X86ATTAsmPrinter : public X86SharedAsmPrinter {
  X86ATTAsmPrinter(std::ostream &O, TargetMachine &TM)
    : X86SharedAsmPrinter(O, TM) { }

  virtual const char *getPassName() const {
    return "X86 AT&T-Style Assembly Printer";
  }

  /// printInstruction - This method is automatically generated by tablegen
  /// from the instruction set description.  This method returns true if the
  /// machine instruction was sufficiently described to print it, otherwise it
  /// returns false.
  bool printInstruction(const MachineInstr *MI);

  // This method is used by the tablegen'erated instruction printer.
  void printOperand(const MachineInstr *MI, unsigned OpNo){
    printOp(MI->getOperand(OpNo));
  }
  void printCallOperand(const MachineInstr *MI, unsigned OpNo) {
    printOp(MI->getOperand(OpNo), true); // Don't print '$' prefix.
  }
  void printi8mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi16mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi32mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printi64mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf32mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf64mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  void printf80mem(const MachineInstr *MI, unsigned OpNo) {
    printMemReference(MI, OpNo);
  }
  
  void printMachineInstruction(const MachineInstr *MI);
  void printOp(const MachineOperand &MO, bool isCallOperand = false);
  void printSSECC(const MachineInstr *MI, unsigned Op);
  void printMemReference(const MachineInstr *MI, unsigned Op);
  bool runOnMachineFunction(MachineFunction &F);
};

} // end namespace x86
} // end namespace llvm

#endif
