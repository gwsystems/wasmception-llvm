//===- PDBSymbolTypeFunctionSig.cpp - --------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/DebugInfo/PDB/PDBSymbolTypeFunctionSig.h"

#include "llvm/DebugInfo/PDB/ConcreteSymbolEnumerator.h"
#include "llvm/DebugInfo/PDB/IPDBEnumChildren.h"
#include "llvm/DebugInfo/PDB/IPDBSession.h"
#include "llvm/DebugInfo/PDB/PDBSymbol.h"
#include "llvm/DebugInfo/PDB/PDBSymbolTypeFunctionArg.h"

#include <utility>

using namespace llvm;

namespace {
class FunctionArgEnumerator : public IPDBEnumSymbols {
public:
  typedef ConcreteSymbolEnumerator<PDBSymbolTypeFunctionArg> ArgEnumeratorType;

  FunctionArgEnumerator(const IPDBSession &PDBSession,
                        const PDBSymbolTypeFunctionSig &Sig)
      : Session(PDBSession),
        Enumerator(Sig.findAllChildren<PDBSymbolTypeFunctionArg>()) {}

  FunctionArgEnumerator(const IPDBSession &PDBSession,
                        std::unique_ptr<ArgEnumeratorType> ArgEnumerator)
      : Session(PDBSession), Enumerator(std::move(ArgEnumerator)) {}

  uint32_t getChildCount() const { return Enumerator->getChildCount(); }

  std::unique_ptr<PDBSymbol> getChildAtIndex(uint32_t Index) const {
    auto FunctionArgSymbol = Enumerator->getChildAtIndex(Index);
    if (!FunctionArgSymbol)
      return nullptr;
    return Session.getSymbolById(FunctionArgSymbol->getTypeId());
  }

  std::unique_ptr<PDBSymbol> getNext() {
    auto FunctionArgSymbol = Enumerator->getNext();
    if (!FunctionArgSymbol)
      return nullptr;
    return Session.getSymbolById(FunctionArgSymbol->getTypeId());
  }

  void reset() { Enumerator->reset(); }

  MyType *clone() const {
    std::unique_ptr<ArgEnumeratorType> Clone(Enumerator->clone());
    return new FunctionArgEnumerator(Session, std::move(Clone));
  }

private:
  const IPDBSession &Session;
  std::unique_ptr<ArgEnumeratorType> Enumerator;
};
}

PDBSymbolTypeFunctionSig::PDBSymbolTypeFunctionSig(
    const IPDBSession &PDBSession, std::unique_ptr<IPDBRawSymbol> Symbol)
    : PDBSymbol(PDBSession, std::move(Symbol)) {}

std::unique_ptr<PDBSymbol> PDBSymbolTypeFunctionSig::getReturnType() const {
  return Session.getSymbolById(getTypeId());
}

std::unique_ptr<IPDBEnumSymbols>
PDBSymbolTypeFunctionSig::getArguments() const {
  return llvm::make_unique<FunctionArgEnumerator>(Session, *this);
}

std::unique_ptr<PDBSymbol> PDBSymbolTypeFunctionSig::getClassParent() const {
  uint32_t ClassId = getClassParentId();
  if (ClassId == 0)
    return nullptr;
  return Session.getSymbolById(ClassId);
}

void PDBSymbolTypeFunctionSig::dumpArgList(raw_ostream &OS) const {
  OS << "(";
  if (auto ChildEnum = getArguments()) {
    uint32_t Index = 0;
    while (auto Arg = ChildEnum->getNext()) {
      Arg->dump(OS, 0, PDB_DumpLevel::Compact, PDB_DF_Children);
      if (++Index < ChildEnum->getChildCount())
        OS << ", ";
    }
  }
  OS << ")";
  if (isConstType())
    OS << " const";
  if (isVolatileType())
    OS << " volatile";
}

void PDBSymbolTypeFunctionSig::dump(raw_ostream &OS, int Indent,
                                    PDB_DumpLevel Level, PDB_DumpFlags Flags) const {
  OS << stream_indent(Indent);

  if (auto ReturnType = getReturnType()) {
    ReturnType->dump(OS, 0, PDB_DumpLevel::Compact, PDB_DF_Children);
    OS << " ";
  }

  OS << getCallingConvention() << " ";
  if (auto ClassParent = getClassParent()) {
    OS << "(";
    ClassParent->dump(OS, 0, PDB_DumpLevel::Compact, PDB_DF_Children);
    OS << "::*)";
  }

  dumpArgList(OS);
}
