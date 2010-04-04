//===--- lib/CodeGen/DwarfPrinter.cpp - Dwarf Printer ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Emit general DWARF directives.
//
//===----------------------------------------------------------------------===//

#include "DwarfPrinter.h"
#include "llvm/Module.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetFrameInfo.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/ADT/SmallString.h"
using namespace llvm;

DwarfPrinter::DwarfPrinter(AsmPrinter *A)
: Asm(A), MAI(A->MAI), TD(Asm->TM.getTargetData()),
  RI(Asm->TM.getRegisterInfo()), M(NULL), MF(NULL), MMI(NULL),
  SubprogramCount(0) {}

/// SizeOfEncodedValue - Return the size of the encoding in bytes.
unsigned DwarfPrinter::SizeOfEncodedValue(unsigned Encoding) const {
  if (Encoding == dwarf::DW_EH_PE_omit)
    return 0;

  switch (Encoding & 0x07) {
  default:   assert(0 && "Invalid encoded value.");
  case dwarf::DW_EH_PE_absptr: return TD->getPointerSize();
  case dwarf::DW_EH_PE_udata2: return 2;
  case dwarf::DW_EH_PE_udata4: return 4;
  case dwarf::DW_EH_PE_udata8: return 8;
  }
}

void DwarfPrinter::EmitReference(const MCSymbol *Sym, unsigned Encoding) const {
  const TargetLoweringObjectFile &TLOF = Asm->getObjFileLowering();

  const MCExpr *Exp = TLOF.getExprForDwarfReference(Sym, Asm->Mang,
                                                    Asm->MMI, Encoding,
                                                    Asm->OutStreamer);
  Asm->OutStreamer.EmitValue(Exp, SizeOfEncodedValue(Encoding), /*addrspace*/0);
}

void DwarfPrinter::EmitReference(const GlobalValue *GV, unsigned Encoding)const{
  const TargetLoweringObjectFile &TLOF = Asm->getObjFileLowering();

  const MCExpr *Exp =
    TLOF.getExprForDwarfGlobalReference(GV, Asm->Mang, Asm->MMI, Encoding,
                                        Asm->OutStreamer);
  Asm->OutStreamer.EmitValue(Exp, SizeOfEncodedValue(Encoding), /*addrspace*/0);
}

void DwarfPrinter::EmitSectionOffset(const MCSymbol *Label,
                                     const MCSymbol *Section,
                                     bool IsSmall, bool isEH) {
  bool isAbsolute;
  if (isEH)
    isAbsolute = MAI->isAbsoluteEHSectionOffsets();
  else
    isAbsolute = MAI->isAbsoluteDebugSectionOffsets();

  if (!isAbsolute)
    return Asm->EmitLabelDifference(Label, Section,
                                    IsSmall ? 4 : TD->getPointerSize());
  
  // On COFF targets, we have to emit the weird .secrel32 directive.
  if (const char *SecOffDir = MAI->getDwarfSectionOffsetDirective()) {
    // FIXME: MCize.
    Asm->OutStreamer.EmitRawText(SecOffDir + Twine(Label->getName()));
  } else {
    unsigned Size = IsSmall ? 4 : TD->getPointerSize();
    Asm->OutStreamer.EmitSymbolValue(Label, Size, 0/*AddrSpace*/);
  }
}

/// EmitFrameMoves - Emit frame instructions to describe the layout of the
/// frame.
void DwarfPrinter::EmitFrameMoves(MCSymbol *BaseLabel,
                                  const std::vector<MachineMove> &Moves,
                                  bool isEH) {
  int stackGrowth = TD->getPointerSize();
  if (Asm->TM.getFrameInfo()->getStackGrowthDirection() !=
      TargetFrameInfo::StackGrowsUp)
    stackGrowth *= -1;
  
  for (unsigned i = 0, N = Moves.size(); i < N; ++i) {
    const MachineMove &Move = Moves[i];
    MCSymbol *Label = Move.getLabel();
    // Throw out move if the label is invalid.
    if (Label && !Label->isDefined()) continue; // Not emitted, in dead code.

    const MachineLocation &Dst = Move.getDestination();
    const MachineLocation &Src = Move.getSource();

    // Advance row if new location.
    if (BaseLabel && Label) {
      MCSymbol *ThisSym = Label;
      if (ThisSym != BaseLabel) {
        Asm->EmitCFAByte(dwarf::DW_CFA_advance_loc4);
        Asm->EmitLabelDifference(ThisSym, BaseLabel, 4);
        BaseLabel = ThisSym;
      }
    }

    // If advancing cfa.
    if (Dst.isReg() && Dst.getReg() == MachineLocation::VirtualFP) {
      if (!Src.isReg()) {
        if (Src.getReg() == MachineLocation::VirtualFP) {
          Asm->EmitCFAByte(dwarf::DW_CFA_def_cfa_offset);
        } else {
          Asm->EmitCFAByte(dwarf::DW_CFA_def_cfa);
          Asm->EmitULEB128(RI->getDwarfRegNum(Src.getReg(), isEH), "Register");
        }

        int Offset = -Src.getOffset();
        Asm->EmitULEB128(Offset, "Offset");
      } else {
        llvm_unreachable("Machine move not supported yet.");
      }
    } else if (Src.isReg() &&
               Src.getReg() == MachineLocation::VirtualFP) {
      if (Dst.isReg()) {
        Asm->EmitCFAByte(dwarf::DW_CFA_def_cfa_register);
        Asm->EmitULEB128(RI->getDwarfRegNum(Dst.getReg(), isEH), "Register");
      } else {
        llvm_unreachable("Machine move not supported yet.");
      }
    } else {
      unsigned Reg = RI->getDwarfRegNum(Src.getReg(), isEH);
      int Offset = Dst.getOffset() / stackGrowth;

      if (Offset < 0) {
        Asm->EmitCFAByte(dwarf::DW_CFA_offset_extended_sf);
        Asm->EmitULEB128(Reg, "Reg");
        Asm->EmitSLEB128(Offset, "Offset");
      } else if (Reg < 64) {
        Asm->EmitCFAByte(dwarf::DW_CFA_offset + Reg);
        Asm->EmitULEB128(Offset, "Offset");
      } else {
        Asm->EmitCFAByte(dwarf::DW_CFA_offset_extended);
        Asm->EmitULEB128(Reg, "Reg");
        Asm->EmitULEB128(Offset, "Offset");
      }
    }
  }
}
