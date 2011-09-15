//===- lib/MC/MCInst.cpp - MCInst implementation --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

void MCOperand::print(raw_ostream &OS, const MCAsmInfo *MAI) const {
  OS << "<MCOperand ";
  if (!isValid())
    OS << "INVALID";
  else if (isReg())
    OS << "Reg:" << getReg();
  else if (isImm())
    OS << "Imm:" << getImm();
  else if (isExpr()) {
    OS << "Expr:(" << *getExpr() << ")";
  } else
    OS << "UNDEFINED";
  OS << ">";
}

void MCOperand::dump() const {
  print(dbgs(), 0);
  dbgs() << "\n";
}

void MCInst::print(raw_ostream &OS, const MCAsmInfo *MAI) const {
  OS << "<MCInst " << getOpcode();
  for (unsigned i = 0, e = getNumOperands(); i != e; ++i) {
    OS << " ";
    getOperand(i).print(OS, MAI);
  }

  if (getNumAnnotations()) {
    OS << " # Annots: ";
    for (unsigned i = 0, e = getNumAnnotations(); i != e; ++i) {
      OS << " \"";
      OS << getAnnotation(i);
      OS << '"';
    }
  }

  OS << ">";
}

void MCInst::dump_pretty(raw_ostream &OS, const MCAsmInfo *MAI,
                         const MCInstPrinter *Printer,
                         StringRef Separator) const {
  OS << "<MCInst #" << getOpcode();

  // Show the instruction opcode name if we have access to a printer.
  if (Printer)
    OS << ' ' << Printer->getOpcodeName(getOpcode());

  for (unsigned i = 0, e = getNumOperands(); i != e; ++i) {
    OS << Separator;
    getOperand(i).print(OS, MAI);
  }

  if (getNumAnnotations()) {
    OS << " # Annots: ";
    for (unsigned i = 0, e = getNumAnnotations(); i != e; ++i) {
      OS << Separator;
      OS << '"';
      OS << getAnnotation(i);
      OS << '"';
    }
  }

  OS << ">";
}

void MCInst::dump() const {
  print(dbgs(), 0);
  dbgs() << "\n";
}
