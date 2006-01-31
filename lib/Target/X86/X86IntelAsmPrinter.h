//===-- X86IntelAsmPrinter.h - Convert X86 LLVM code to Intel assembly ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Intel assembly code printer class.
//
//===----------------------------------------------------------------------===//

#ifndef X86INTELASMPRINTER_H
#define X86INTELASMPRINTER_H

#include "X86AsmPrinter.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/MRegisterInfo.h"

namespace llvm {
namespace x86 {

struct X86IntelAsmPrinter : public X86SharedAsmPrinter {
  X86IntelAsmPrinter(std::ostream &O, TargetMachine &TM)
    : X86SharedAsmPrinter(O, TM) { }

  virtual const char *getPassName() const {
    return "X86 Intel-Style Assembly Printer";
  }

  /// printInstruction - This method is automatically generated by tablegen
  /// from the instruction set description.  This method returns true if the
  /// machine instruction was sufficiently described to print it, otherwise it
  /// returns false.
  bool printInstruction(const MachineInstr *MI);

  // This method is used by the tablegen'erated instruction printer.
  void printOperand(const MachineInstr *MI, unsigned OpNo){
    const MachineOperand &MO = MI->getOperand(OpNo);
    if (MO.getType() == MachineOperand::MO_MachineRegister) {
      assert(MRegisterInfo::isPhysicalRegister(MO.getReg())&&"Not physref??");
      // Bug Workaround: See note in Printer::doInitialization about %.
      O << "%" << TM.getRegisterInfo()->get(MO.getReg()).Name;
    } else {
      printOp(MO);
    }
  }

  void printCallOperand(const MachineInstr *MI, unsigned OpNo) {
    printOp(MI->getOperand(OpNo), true); // Don't print "OFFSET".
  }

  void printi8mem(const MachineInstr *MI, unsigned OpNo) {
    O << "BYTE PTR ";
    printMemReference(MI, OpNo);
  }
  void printi16mem(const MachineInstr *MI, unsigned OpNo) {
    O << "WORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printi32mem(const MachineInstr *MI, unsigned OpNo) {
    O << "DWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printi64mem(const MachineInstr *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf32mem(const MachineInstr *MI, unsigned OpNo) {
    O << "DWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf64mem(const MachineInstr *MI, unsigned OpNo) {
    O << "QWORD PTR ";
    printMemReference(MI, OpNo);
  }
  void printf128mem(const MachineInstr *MI, unsigned OpNo) {
    O << "XMMWORD PTR ";
    printMemReference(MI, OpNo);
  }

  void printMachineInstruction(const MachineInstr *MI);
  void printOp(const MachineOperand &MO, bool elideOffsetKeyword = false);
  void printSSECC(const MachineInstr *MI, unsigned Op);
  void printMemReference(const MachineInstr *MI, unsigned Op);
  bool runOnMachineFunction(MachineFunction &F);
  bool doInitialization(Module &M);
};

} // end namespace x86
} // end namespace llvm

#endif
