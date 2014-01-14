//===-- MipsTargetStreamer.cpp - Mips Target Streamer Methods -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides Mips specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "MipsTargetStreamer.h"
#include "llvm/MC/MCELF.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

static cl::opt<bool> PrintHackDirectives("print-hack-directives",
                                         cl::init(false), cl::Hidden);

// Pin vtable to this file.
void MipsTargetStreamer::anchor() {}

MipsTargetAsmStreamer::MipsTargetAsmStreamer(formatted_raw_ostream &OS)
    : OS(OS) {}

void MipsTargetAsmStreamer::emitMipsHackELFFlags(unsigned Flags) {
  if (!PrintHackDirectives)
    return;

  OS << "\t.mips_hack_elf_flags 0x";
  OS.write_hex(Flags);
  OS << '\n';
}

void MipsTargetAsmStreamer::emitDirectiveSetMicroMips() {
  OS << "\t.set\tmicromips\n";
}

void MipsTargetAsmStreamer::emitDirectiveSetNoMicroMips() {
  OS << "\t.set\tnomicromips\n";
}

void MipsTargetAsmStreamer::emitDirectiveAbiCalls() { OS << "\t.abicalls\n"; }
void MipsTargetAsmStreamer::emitDirectiveOptionPic0() {
  OS << "\t.option\tpic0\n";
}

// This part is for ELF object output.
MipsTargetELFStreamer::MipsTargetELFStreamer() {}

void MipsTargetELFStreamer::emitLabel(MCSymbol *Symbol) {
  MCSymbolData &Data = getStreamer().getOrCreateSymbolData(Symbol);
  // The "other" values are stored in the last 6 bits of the second byte
  // The traditional defines for STO values assume the full byte and thus
  // the shift to pack it.
  if (isMicroMipsEnabled())
    MCELF::setOther(Data, ELF::STO_MIPS_MICROMIPS >> 2);
}

MCELFStreamer &MipsTargetELFStreamer::getStreamer() {
  return static_cast<MCELFStreamer &>(*Streamer);
}

void MipsTargetELFStreamer::emitMipsHackELFFlags(unsigned Flags) {
  MCAssembler &MCA = getStreamer().getAssembler();
  MCA.setELFHeaderEFlags(Flags);
}

void MipsTargetELFStreamer::emitDirectiveSetMicroMips() {
  MicroMipsEnabled = true;
}

void MipsTargetELFStreamer::emitDirectiveSetNoMicroMips() {
  MicroMipsEnabled = false;
}

void MipsTargetELFStreamer::emitDirectiveAbiCalls() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags |= ELF::EF_MIPS_CPIC;
  MCA.setELFHeaderEFlags(Flags);
}
void MipsTargetELFStreamer::emitDirectiveOptionPic0() {
  MCAssembler &MCA = getStreamer().getAssembler();
  unsigned Flags = MCA.getELFHeaderEFlags();
  Flags &= ~ELF::EF_MIPS_PIC;
  MCA.setELFHeaderEFlags(Flags);
}
