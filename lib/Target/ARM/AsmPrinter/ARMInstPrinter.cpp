//===-- ARMInstPrinter.cpp - Convert ARM MCInst to assembly syntax --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an ARM MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"
#include "ARMInstPrinter.h"
#include "llvm/MC/MCInst.h"
//#include "llvm/MC/MCAsmInfo.h"
//#include "llvm/MC/MCExpr.h"
//#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "ARMGenInstrNames.inc"
using namespace llvm;

// Include the auto-generated portion of the assembly writer.
#define MachineInstr MCInst
#define ARMAsmPrinter ARMInstPrinter  // FIXME: REMOVE.
#define NO_ASM_WRITER_BOILERPLATE
#include "ARMGenAsmWriter.inc"
#undef MachineInstr
#undef ARMAsmPrinter

void ARMInstPrinter::printInst(const MCInst *MI) { printInstruction(MI); }

