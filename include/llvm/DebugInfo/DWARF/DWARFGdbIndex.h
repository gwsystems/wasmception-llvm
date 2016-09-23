//===-- DWARFGdbIndex.h -----------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_DEBUGINFO_DWARFGDBINDEX_H
#define LLVM_LIB_DEBUGINFO_DWARFGDBINDEX_H

#include "llvm/Support/DataExtractor.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/raw_ostream.h"

namespace llvm {
class DWARFGdbIndex {
  uint32_t Version;

  uint32_t CuListOffset;
  uint32_t AddressAreaOffset;
  uint32_t SymbolTableOffset;
  uint32_t ConstantPoolOffset;

  struct CompUnitEntry {
    uint64_t Offset; // Offset of a CU in the .debug_info section.
    uint64_t Length; // Length of that CU.
  };
  SmallVector<CompUnitEntry, 0> CuList;

  struct AddressEntry {
    uint64_t LowAddress;  // The low address.
    uint64_t HighAddress; // The high address.
    uint32_t CuIndex;     // The CU index.
  };
  SmallVector<AddressEntry, 0> AddressArea;

  struct SymTableEntry {
    uint32_t NameOffset; // Offset of the symbol's name in the constant pool.
    uint32_t VecOffset;  // Offset of the CU vector in the constant pool.
  };
  SmallVector<SymTableEntry, 0> SymbolTable;

  // Each value is CU index + attributes.
  SmallVector<std::pair<uint32_t, SmallVector<uint32_t, 0>>, 0>
      ConstantPoolVectors;

  StringRef ConstantPoolStrings;
  uint32_t StringPoolOffset;

  void dumpCUList(raw_ostream &OS) const;
  void dumpAddressArea(raw_ostream &OS) const;
  void dumpSymbolTable(raw_ostream &OS) const;
  void dumpConstantPool(raw_ostream &OS) const;

  bool parseImpl(DataExtractor Data);

public:
  void dump(raw_ostream &OS);
  void parse(DataExtractor Data);

  bool HasContent = false;
  bool HasError = false;
};
}

#endif // LLVM_LIB_DEBUGINFO_DWARFGDBINDEX_H
