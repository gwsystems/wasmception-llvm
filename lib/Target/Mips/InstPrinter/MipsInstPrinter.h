//=== MipsInstPrinter.h - Convert Mips MCInst to assembly syntax -*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints a Mips MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef MIPSINSTPRINTER_H
#define MIPSINSTPRINTER_H
#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
// These enumeration declarations were originally in MipsInstrInfo.h but
// had to be moved here to avoid circular dependencies between
// LLVMMipsCodeGen and LLVMMipsAsmPrinter.
namespace Mips {
// Mips Branch Codes
enum FPBranchCode {
  BRANCH_F,
  BRANCH_T,
  BRANCH_FL,
  BRANCH_TL,
  BRANCH_INVALID
};

// Mips Condition Codes
enum CondCode {
  // To be used with float branch True
  FCOND_F,
  FCOND_UN,
  FCOND_OEQ,
  FCOND_UEQ,
  FCOND_OLT,
  FCOND_ULT,
  FCOND_OLE,
  FCOND_ULE,
  FCOND_SF,
  FCOND_NGLE,
  FCOND_SEQ,
  FCOND_NGL,
  FCOND_LT,
  FCOND_NGE,
  FCOND_LE,
  FCOND_NGT,

  // To be used with float branch False
  // This conditions have the same mnemonic as the
  // above ones, but are used with a branch False;
  FCOND_T,
  FCOND_OR,
  FCOND_UNE,
  FCOND_ONE,
  FCOND_UGE,
  FCOND_OGE,
  FCOND_UGT,
  FCOND_OGT,
  FCOND_ST,
  FCOND_GLE,
  FCOND_SNE,
  FCOND_GL,
  FCOND_NLT,
  FCOND_GE,
  FCOND_NLE,
  FCOND_GT
};

const char *MipsFCCToString(Mips::CondCode CC);
} // end namespace Mips

class TargetMachine;

class MipsInstPrinter : public MCInstPrinter {
public:
  MipsInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                  const MCRegisterInfo &MRI)
    : MCInstPrinter(MAI, MII, MRI) {}

  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI, raw_ostream &O);
  static const char *getRegisterName(unsigned RegNo);

  virtual void printRegName(raw_ostream &OS, unsigned RegNo) const;
  virtual void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot);
  void printCPURegs(const MCInst *MI, unsigned OpNo, raw_ostream &O);

private:
  void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printUnsignedImm(const MCInst *MI, int opNum, raw_ostream &O);
  void printMemOperand(const MCInst *MI, int opNum, raw_ostream &O);
  void printMemOperandEA(const MCInst *MI, int opNum, raw_ostream &O);
  void printFCCOperand(const MCInst *MI, int opNum, raw_ostream &O);
};
} // end namespace llvm

#endif
