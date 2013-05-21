//===------ utils/obj2yaml.cpp - obj2yaml conversion tool -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "obj2yaml.h"
#include "llvm/Object/COFF.h"
#include "llvm/Object/COFFYaml.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/YAMLTraits.h"

#include <list>

using namespace llvm;

namespace {

class COFFDumper {
  const object::COFFObjectFile &Obj;
  COFFYAML::Object YAMLObj;
  void dumpHeader(const object::coff_file_header *Header);
  void dumpSections(unsigned numSections);
  void dumpSymbols(unsigned numSymbols);
  StringRef getHexString(ArrayRef<uint8_t> Data);
  std::list<std::string> Strings;

public:
  COFFDumper(const object::COFFObjectFile &Obj);
  COFFYAML::Object &getYAMLObj();
};

}

static void check(error_code ec) {
  if (ec)
    report_fatal_error(ec.message());
}

COFFDumper::COFFDumper(const object::COFFObjectFile &Obj) : Obj(Obj) {
  const object::coff_file_header *Header;
  check(Obj.getHeader(Header));
  dumpHeader(Header);
  dumpSections(Header->NumberOfSections);
  dumpSymbols(Header->NumberOfSymbols);
}

void COFFDumper::dumpHeader(const object::coff_file_header *Header) {
  YAMLObj.Header.Machine = Header->Machine;
  YAMLObj.Header.Characteristics = Header->Characteristics;
}

void COFFDumper::dumpSections(unsigned NumSections) {
  std::vector<COFFYAML::Section> &Sections = YAMLObj.Sections;
  error_code ec;
  for (object::section_iterator iter = Obj.begin_sections();
       iter != Obj.end_sections(); iter.increment(ec)) {
    check(ec);
    const object::coff_section *Sect = Obj.getCOFFSection(iter);
    COFFYAML::Section Sec;
    Sec.Name = Sect->Name; // FIXME: check the null termination!
    uint32_t Characteristics = Sect->Characteristics;
    Sec.Header.Characteristics = Characteristics;
    Sec.Alignment = 1 << (((Characteristics >> 20) & 0xf) - 1);

    ArrayRef<uint8_t> sectionData;
    Obj.getSectionContents(Sect, sectionData);
    Sec.SectionData = getHexString(sectionData);

    std::vector<COFF::relocation> Relocations;
    for (object::relocation_iterator rIter = iter->begin_relocations();
                       rIter != iter->end_relocations(); rIter.increment(ec)) {
      const object::coff_relocation *reloc = Obj.getCOFFRelocation(rIter);
      COFF::relocation Rel;
      Rel.VirtualAddress = reloc->VirtualAddress;
      Rel.SymbolTableIndex = reloc->SymbolTableIndex;
      Rel.Type = reloc->Type;
      Relocations.push_back(Rel);
    }
    Sec.Relocations = Relocations;
    Sections.push_back(Sec);
  }
}

void COFFDumper::dumpSymbols(unsigned NumSymbols) {
  error_code ec;
  std::vector<COFFYAML::Symbol> &Symbols = YAMLObj.Symbols;
  for (object::symbol_iterator iter = Obj.begin_symbols();
       iter != Obj.end_symbols(); iter.increment(ec)) {
    check(ec);
    const object::coff_symbol *Symbol = Obj.getCOFFSymbol(iter);
    COFFYAML::Symbol Sym;
    Obj.getSymbolName(Symbol, Sym.Name);
    Sym.SimpleType = COFF::SymbolBaseType(Symbol->getBaseType());
    Sym.ComplexType = COFF::SymbolComplexType(Symbol->getComplexType());
    Sym.Header.StorageClass = Symbol->StorageClass;
    Sym.Header.Value = Symbol->Value;
    Sym.Header.SectionNumber = Symbol->SectionNumber;
    Sym.Header.NumberOfAuxSymbols = Symbol->NumberOfAuxSymbols;
    Sym.AuxiliaryData = getHexString(Obj.getSymbolAuxData(Symbol));
    Symbols.push_back(Sym);
  }
}

StringRef COFFDumper::getHexString(ArrayRef<uint8_t> Data) {
  std::string S;
  for (ArrayRef<uint8_t>::iterator I = Data.begin(), E = Data.end(); I != E;
       ++I) {
    uint8_t Byte = *I;
    S.push_back(hexdigit(Byte >> 4));
    S.push_back(hexdigit(Byte & 0xf));
  }
  Strings.push_back(S);
  return Strings.back();
}

COFFYAML::Object &COFFDumper::getYAMLObj() {
  return YAMLObj;
}

error_code coff2yaml(raw_ostream &Out, MemoryBuffer *Buff) {
  error_code ec;
  object::COFFObjectFile Obj(Buff, ec);
  check(ec);
  COFFDumper Dumper(Obj);

  yaml::Output Yout(Out);
  Yout << Dumper.getYAMLObj();

  return object::object_error::success;
}
