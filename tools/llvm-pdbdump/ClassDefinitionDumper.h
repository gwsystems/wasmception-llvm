//===- ClassDefinitionDumper.h - --------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVMPDBDUMP_CLASSDEFINITIONDUMPER_H
#define LLVM_TOOLS_LLVMPDBDUMP_CLASSDEFINITIONDUMPER_H

#include "llvm/DebugInfo/PDB/PDBSymDumper.h"
#include "llvm/DebugInfo/PDB/PDBSymbolFunc.h"
#include "llvm/DebugInfo/PDB/PDBSymbolData.h"

#include <list>
#include <memory>
#include <unordered_map>

namespace llvm {

class ClassDefinitionDumper : public PDBSymDumper {
public:
  ClassDefinitionDumper();

  void start(const PDBSymbolTypeUDT &Exe, raw_ostream &OS, int Indent);

  void dump(const PDBSymbolTypeBaseClass &Symbol, raw_ostream &OS,
            int Indent) override;
  void dump(const PDBSymbolData &Symbol, raw_ostream &OS, int Indent) override;
  void dump(const PDBSymbolTypeEnum &Symbol, raw_ostream &OS,
            int Indent) override;
  void dump(const PDBSymbolFunc &Symbol, raw_ostream &OS, int Indent) override;
  void dump(const PDBSymbolTypeTypedef &Symbol, raw_ostream &OS,
            int Indent) override;
  void dump(const PDBSymbolTypeUDT &Symbol, raw_ostream &OS,
            int Indent) override;
  void dump(const PDBSymbolTypeVTable &Symbol, raw_ostream &OS,
            int Indent) override;

private:
  struct SymbolGroup {
    SymbolGroup() {}
    SymbolGroup(SymbolGroup &&Other) {
      Functions = std::move(Other.Functions);
      Data = std::move(Other.Data);
      Unknown = std::move(Other.Unknown);
    }

    std::list<std::unique_ptr<PDBSymbolFunc>> Functions;
    std::list<std::unique_ptr<PDBSymbolData>> Data;
    std::list<std::unique_ptr<PDBSymbol>> Unknown;
    SymbolGroup(const SymbolGroup &other) = delete;
    SymbolGroup &operator=(const SymbolGroup &other) = delete;
  };
  typedef std::unordered_map<int, SymbolGroup> SymbolGroupByAccess;

  int dumpAccessGroup(PDB_MemberAccess Access, const SymbolGroup &Group,
                      raw_ostream &OS, int Indent);
};
}

#endif
