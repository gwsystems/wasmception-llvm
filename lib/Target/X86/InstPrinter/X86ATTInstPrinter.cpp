//===-- X86ATTInstPrinter.cpp - AT&T assembly instruction printing --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file includes code for rendering MCInst instances as AT&T-style
// assembly.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"
#include "X86ATTInstPrinter.h"
#include "X86InstComments.h"
#include "MCTargetDesc/X86BaseInfo.h"
#include "MCTargetDesc/X86MCTargetDesc.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/FormattedStream.h"
#include <map>
using namespace llvm;

// Include the auto-generated portion of the assembly writer.
#define PRINT_ALIAS_INSTR
#include "X86GenAsmWriter.inc"

void X86ATTInstPrinter::printRegName(raw_ostream &OS,
                                     unsigned RegNo) const {
  if (UseMarkup)
    OS << "<reg:";
  OS << '%' << getRegisterName(RegNo);
  if (UseMarkup)
    OS << ">";
}

void X86ATTInstPrinter::printInst(const MCInst *MI, raw_ostream &OS,
                                  StringRef Annot) {
  const MCInstrDesc &Desc = MII.get(MI->getOpcode());
  uint64_t TSFlags = Desc.TSFlags;

  if (TSFlags & X86II::LOCK)
    OS << "\tlock\n";

  // Try to print any aliases first.
  if (!printAliasInstr(MI, OS))
    printInstruction(MI, OS);
  
  // Next always print the annotation.
  printAnnotation(OS, Annot);

  // If verbose assembly is enabled, we can print some informative comments.
  if (CommentStream)
    EmitAnyX86InstComments(MI, *CommentStream, getRegisterName);
}

void X86ATTInstPrinter::printSSECC(const MCInst *MI, unsigned Op,
                                   raw_ostream &O) {
  int64_t Imm = MI->getOperand(Op).getImm() & 0xf;
  switch (Imm) {
  default: llvm_unreachable("Invalid ssecc argument!");
  case    0: O << "eq"; break;
  case    1: O << "lt"; break;
  case    2: O << "le"; break;
  case    3: O << "unord"; break;
  case    4: O << "neq"; break;
  case    5: O << "nlt"; break;
  case    6: O << "nle"; break;
  case    7: O << "ord"; break;
  case    8: O << "eq_uq"; break;
  case    9: O << "nge"; break;
  case  0xa: O << "ngt"; break;
  case  0xb: O << "false"; break;
  case  0xc: O << "neq_oq"; break;
  case  0xd: O << "ge"; break;
  case  0xe: O << "gt"; break;
  case  0xf: O << "true"; break;
  }
}

void X86ATTInstPrinter::printAVXCC(const MCInst *MI, unsigned Op,
                                   raw_ostream &O) {
  int64_t Imm = MI->getOperand(Op).getImm() & 0x1f;
  switch (Imm) {
  default: llvm_unreachable("Invalid avxcc argument!");
  case    0: O << "eq"; break;
  case    1: O << "lt"; break;
  case    2: O << "le"; break;
  case    3: O << "unord"; break;
  case    4: O << "neq"; break;
  case    5: O << "nlt"; break;
  case    6: O << "nle"; break;
  case    7: O << "ord"; break;
  case    8: O << "eq_uq"; break;
  case    9: O << "nge"; break;
  case  0xa: O << "ngt"; break;
  case  0xb: O << "false"; break;
  case  0xc: O << "neq_oq"; break;
  case  0xd: O << "ge"; break;
  case  0xe: O << "gt"; break;
  case  0xf: O << "true"; break;
  case 0x10: O << "eq_os"; break;
  case 0x11: O << "lt_oq"; break;
  case 0x12: O << "le_oq"; break;
  case 0x13: O << "unord_s"; break;
  case 0x14: O << "neq_us"; break;
  case 0x15: O << "nlt_uq"; break;
  case 0x16: O << "nle_uq"; break;
  case 0x17: O << "ord_s"; break;
  case 0x18: O << "eq_us"; break;
  case 0x19: O << "nge_uq"; break;
  case 0x1a: O << "ngt_uq"; break;
  case 0x1b: O << "false_os"; break;
  case 0x1c: O << "neq_os"; break;
  case 0x1d: O << "ge_oq"; break;
  case 0x1e: O << "gt_oq"; break;
  case 0x1f: O << "true_us"; break;
  }
}

/// printPCRelImm - This is used to print an immediate value that ends up
/// being encoded as a pc-relative value (e.g. for jumps and calls).  These
/// print slightly differently than normal immediates.  For example, a $ is not
/// emitted.
void X86ATTInstPrinter::printPCRelImm(const MCInst *MI, unsigned OpNo,
                                      raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isImm())
    O << Op.getImm();
  else {
    assert(Op.isExpr() && "unknown pcrel immediate operand");
    // If a symbolic branch target was added as a constant expression then print
    // that address in hex.
    const MCConstantExpr *BranchTarget = dyn_cast<MCConstantExpr>(Op.getExpr());
    int64_t Address;
    if (BranchTarget && BranchTarget->EvaluateAsAbsolute(Address)) {
      O << "0x";
      O.write_hex(Address);
    }
    else {
      // Otherwise, just print the expression.
      O << *Op.getExpr();
    }
  }
}

void X86ATTInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    if (UseMarkup)
      O << "<reg:";
    O << '%' << getRegisterName(Op.getReg());
    if (UseMarkup)
      O << ">";
  } else if (Op.isImm()) {
    if (UseMarkup)
      O << "<imm:";
    // Print X86 immediates as signed values.
    O << '$' << (int64_t)Op.getImm();
    if (UseMarkup)
      O << ">";
    
    if (CommentStream && (Op.getImm() > 255 || Op.getImm() < -256))
      *CommentStream << format("imm = 0x%" PRIX64 "\n", (uint64_t)Op.getImm());
    
  } else {
    assert(Op.isExpr() && "unknown operand kind in printOperand");
    if (UseMarkup)
      O << "<imm:";
    O << '$' << *Op.getExpr();
    if (UseMarkup)
      O << ">";
  }
}

void X86ATTInstPrinter::printMemReference(const MCInst *MI, unsigned Op,
                                          raw_ostream &O) {
  const MCOperand &BaseReg  = MI->getOperand(Op);
  const MCOperand &IndexReg = MI->getOperand(Op+2);
  const MCOperand &DispSpec = MI->getOperand(Op+3);
  const MCOperand &SegReg = MI->getOperand(Op+4);
  
  if (UseMarkup)
    O << "<mem:";

  // If this has a segment register, print it.
  if (SegReg.getReg()) {
    printOperand(MI, Op+4, O);
    O << ':';
  }
  
  if (DispSpec.isImm()) {
    int64_t DispVal = DispSpec.getImm();
    if (DispVal || (!IndexReg.getReg() && !BaseReg.getReg()))
      O << DispVal;
  } else {
    assert(DispSpec.isExpr() && "non-immediate displacement for LEA?");
    O << *DispSpec.getExpr();
  }
  
  if (IndexReg.getReg() || BaseReg.getReg()) {
    O << '(';
    if (BaseReg.getReg())
      printOperand(MI, Op, O);
    
    if (IndexReg.getReg()) {
      O << ',';
      printOperand(MI, Op+2, O);
      unsigned ScaleVal = MI->getOperand(Op+1).getImm();
      if (ScaleVal != 1) {
        O << ',';
        if (UseMarkup)
          O << "<imm:";
        O << ScaleVal;
        if (UseMarkup)
          O << ">";
      }
    }
    O << ')';
  }

  if (UseMarkup)
    O << ">";
}
