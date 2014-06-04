//===--- ARMWinEHPrinter.h - Windows on ARM Unwind Information Printer ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License.  See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_READOBJ_ARMWINEHPRINTER_H
#define LLVM_READOBJ_ARMWINEHPRINTER_H

#include "StreamWriter.h"
#include "llvm/object/COFF.h"
#include "llvm/Support/ErrorOr.h"

namespace llvm {
namespace ARM {
namespace WinEH {
class RuntimeFunction;

class Decoder {
  static const size_t PDataEntrySize;

  StreamWriter &SW;
  raw_ostream &OS;

  struct RingEntry {
    uint8_t Mask;
    uint8_t Value;
    bool (Decoder::*Routine)(const support::ulittle8_t *, unsigned &, unsigned,
                             bool);
  };
  static const RingEntry Ring[];

  bool opcode_0xxxxxxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_10Lxxxxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_1100xxxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11010Lxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11011Lxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11100xxx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_111010xx(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_1110110L(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11101110(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11101111(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11110101(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11110110(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11110111(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111000(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111001(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111010(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111011(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111100(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111101(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111110(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);
  bool opcode_11111111(const support::ulittle8_t *Opcodes, unsigned &Offset,
                       unsigned Length, bool Prologue);

  void decodeOpcodes(ArrayRef<support::ulittle8_t> Opcodes, unsigned Offset,
                     bool Prologue);

  void printRegisters(const std::pair<uint16_t, uint32_t> &RegisterMask);

  ErrorOr<object::SectionRef>
  getSectionContaining(const object::COFFObjectFile &COFF, uint64_t Address);

  ErrorOr<object::SymbolRef>
  getSymbol(const object::COFFObjectFile &COFF, uint64_t Address,
            bool FunctionOnly = false);

  ErrorOr<object::SymbolRef>
  getRelocatedSymbol(const object::COFFObjectFile &COFF,
                     const object::SectionRef &Section, uint64_t Offset);

  bool dumpXDataRecord(const object::COFFObjectFile &COFF,
                       const object::SectionRef &Section,
                       uint64_t FunctionAddress, uint64_t VA);
  bool dumpUnpackedEntry(const object::COFFObjectFile &COFF,
                         const object::SectionRef Section, uint64_t Offset,
                         unsigned Index, const RuntimeFunction &Entry);
  bool dumpPackedEntry(const object::COFFObjectFile &COFF,
                       const object::SectionRef Section, uint64_t Offset,
                       unsigned Index, const RuntimeFunction &Entry);
  bool dumpProcedureDataEntry(const object::COFFObjectFile &COFF,
                              const object::SectionRef Section, unsigned Entry,
                              ArrayRef<uint8_t> Contents);
  void dumpProcedureData(const object::COFFObjectFile &COFF,
                         const object::SectionRef Section);

public:
  Decoder(StreamWriter &SW) : SW(SW), OS(SW.getOStream()) {}
  error_code dumpProcedureData(const object::COFFObjectFile &COFF);
};
}
}
}

#endif

