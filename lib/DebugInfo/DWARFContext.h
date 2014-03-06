//===-- DWARFContext.h ------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===/

#ifndef LLVM_DEBUGINFO_DWARFCONTEXT_H
#define LLVM_DEBUGINFO_DWARFCONTEXT_H

#include "DWARFCompileUnit.h"
#include "DWARFDebugAranges.h"
#include "DWARFDebugFrame.h"
#include "DWARFDebugLine.h"
#include "DWARFDebugLoc.h"
#include "DWARFDebugRangeList.h"
#include "DWARFTypeUnit.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/DebugInfo/DIContext.h"

namespace llvm {

/// DWARFContext
/// This data structure is the top level entity that deals with dwarf debug
/// information parsing. The actual data is supplied through pure virtual
/// methods that a concrete implementation provides.
class DWARFContext : public DIContext {
  SmallVector<DWARFCompileUnit *, 1> CUs;
  SmallVector<DWARFTypeUnit *, 1> TUs;
  std::unique_ptr<DWARFDebugAbbrev> Abbrev;
  std::unique_ptr<DWARFDebugLoc> Loc;
  std::unique_ptr<DWARFDebugAranges> Aranges;
  std::unique_ptr<DWARFDebugLine> Line;
  std::unique_ptr<DWARFDebugFrame> DebugFrame;

  SmallVector<DWARFCompileUnit *, 1> DWOCUs;
  SmallVector<DWARFTypeUnit *, 1> DWOTUs;
  std::unique_ptr<DWARFDebugAbbrev> AbbrevDWO;

  DWARFContext(DWARFContext &) LLVM_DELETED_FUNCTION;
  DWARFContext &operator=(DWARFContext &) LLVM_DELETED_FUNCTION;

  /// Read compile units from the debug_info section and store them in CUs.
  void parseCompileUnits();

  /// Read type units from the debug_types sections and store them in CUs.
  void parseTypeUnits();

  /// Read compile units from the debug_info.dwo section and store them in
  /// DWOCUs.
  void parseDWOCompileUnits();

  /// Read type units from the debug_types.dwo section and store them in
  /// DWOTUs.
  void parseDWOTypeUnits();

public:
  struct Section {
    StringRef Data;
    RelocAddrMap Relocs;
  };

  DWARFContext() : DIContext(CK_DWARF) {}
  virtual ~DWARFContext();

  static bool classof(const DIContext *DICtx) {
    return DICtx->getKind() == CK_DWARF;
  }

  void dump(raw_ostream &OS, DIDumpType DumpType = DIDT_All) override;

  /// Get the number of compile units in this context.
  unsigned getNumCompileUnits() {
    if (CUs.empty())
      parseCompileUnits();
    return CUs.size();
  }

  /// Get the number of compile units in this context.
  unsigned getNumTypeUnits() {
    if (TUs.empty())
      parseTypeUnits();
    return TUs.size();
  }

  /// Get the number of compile units in the DWO context.
  unsigned getNumDWOCompileUnits() {
    if (DWOCUs.empty())
      parseDWOCompileUnits();
    return DWOCUs.size();
  }

  /// Get the number of compile units in the DWO context.
  unsigned getNumDWOTypeUnits() {
    if (DWOTUs.empty())
      parseDWOTypeUnits();
    return DWOTUs.size();
  }

  /// Get the compile unit at the specified index for this compile unit.
  DWARFCompileUnit *getCompileUnitAtIndex(unsigned index) {
    if (CUs.empty())
      parseCompileUnits();
    return CUs[index];
  }

  /// Get the type unit at the specified index for this compile unit.
  DWARFTypeUnit *getTypeUnitAtIndex(unsigned index) {
    if (TUs.empty())
      parseTypeUnits();
    return TUs[index];
  }

  /// Get the compile unit at the specified index for the DWO compile units.
  DWARFCompileUnit *getDWOCompileUnitAtIndex(unsigned index) {
    if (DWOCUs.empty())
      parseDWOCompileUnits();
    return DWOCUs[index];
  }

  /// Get the type unit at the specified index for the DWO type units.
  DWARFTypeUnit *getDWOTypeUnitAtIndex(unsigned index) {
    if (DWOTUs.empty())
      parseDWOTypeUnits();
    return DWOTUs[index];
  }

  /// Get a pointer to the parsed DebugAbbrev object.
  const DWARFDebugAbbrev *getDebugAbbrev();

  /// Get a pointer to the parsed DebugLoc object.
  const DWARFDebugLoc *getDebugLoc();

  /// Get a pointer to the parsed dwo abbreviations object.
  const DWARFDebugAbbrev *getDebugAbbrevDWO();

  /// Get a pointer to the parsed DebugAranges object.
  const DWARFDebugAranges *getDebugAranges();

  /// Get a pointer to the parsed frame information object.
  const DWARFDebugFrame *getDebugFrame();

  /// Get a pointer to a parsed line table corresponding to a compile unit.
  const DWARFDebugLine::LineTable *
  getLineTableForCompileUnit(DWARFCompileUnit *cu);

  DILineInfo getLineInfoForAddress(uint64_t Address,
      DILineInfoSpecifier Specifier = DILineInfoSpecifier()) override;
  DILineInfoTable getLineInfoForAddressRange(uint64_t Address, uint64_t Size,
      DILineInfoSpecifier Specifier = DILineInfoSpecifier()) override;
  DIInliningInfo getInliningInfoForAddress(uint64_t Address,
      DILineInfoSpecifier Specifier = DILineInfoSpecifier()) override;

  virtual bool isLittleEndian() const = 0;
  virtual uint8_t getAddressSize() const = 0;
  virtual const Section &getInfoSection() = 0;
  typedef MapVector<object::SectionRef, Section,
                    std::map<object::SectionRef, unsigned> > TypeSectionMap;
  virtual const TypeSectionMap &getTypesSections() = 0;
  virtual StringRef getAbbrevSection() = 0;
  virtual const Section &getLocSection() = 0;
  virtual StringRef getARangeSection() = 0;
  virtual StringRef getDebugFrameSection() = 0;
  virtual const Section &getLineSection() = 0;
  virtual const Section &getLineDWOSection() = 0;
  virtual StringRef getStringSection() = 0;
  virtual StringRef getRangeSection() = 0;
  virtual StringRef getPubNamesSection() = 0;
  virtual StringRef getPubTypesSection() = 0;
  virtual StringRef getGnuPubNamesSection() = 0;
  virtual StringRef getGnuPubTypesSection() = 0;

  // Sections for DWARF5 split dwarf proposal.
  virtual const Section &getInfoDWOSection() = 0;
  virtual const TypeSectionMap &getTypesDWOSections() = 0;
  virtual StringRef getAbbrevDWOSection() = 0;
  virtual StringRef getStringDWOSection() = 0;
  virtual StringRef getStringOffsetDWOSection() = 0;
  virtual StringRef getRangeDWOSection() = 0;
  virtual StringRef getAddrSection() = 0;

  static bool isSupportedVersion(unsigned version) {
    return version == 2 || version == 3 || version == 4;
  }
private:
  /// Return the compile unit that includes an offset (relative to .debug_info).
  DWARFCompileUnit *getCompileUnitForOffset(uint32_t Offset);

  /// Return the compile unit which contains instruction with provided
  /// address.
  DWARFCompileUnit *getCompileUnitForAddress(uint64_t Address);
};

/// DWARFContextInMemory is the simplest possible implementation of a
/// DWARFContext. It assumes all content is available in memory and stores
/// pointers to it.
class DWARFContextInMemory : public DWARFContext {
  virtual void anchor();
  bool IsLittleEndian;
  uint8_t AddressSize;
  Section InfoSection;
  TypeSectionMap TypesSections;
  StringRef AbbrevSection;
  Section LocSection;
  StringRef ARangeSection;
  StringRef DebugFrameSection;
  Section LineSection;
  Section LineDWOSection;
  StringRef StringSection;
  StringRef RangeSection;
  StringRef PubNamesSection;
  StringRef PubTypesSection;
  StringRef GnuPubNamesSection;
  StringRef GnuPubTypesSection;

  // Sections for DWARF5 split dwarf proposal.
  Section InfoDWOSection;
  TypeSectionMap TypesDWOSections;
  StringRef AbbrevDWOSection;
  StringRef StringDWOSection;
  StringRef StringOffsetDWOSection;
  StringRef RangeDWOSection;
  StringRef AddrSection;

  SmallVector<MemoryBuffer*, 4> UncompressedSections;

public:
  DWARFContextInMemory(object::ObjectFile *);
  ~DWARFContextInMemory();
  bool isLittleEndian() const override { return IsLittleEndian; }
  uint8_t getAddressSize() const override { return AddressSize; }
  const Section &getInfoSection() override { return InfoSection; }
  const TypeSectionMap &getTypesSections() override { return TypesSections; }
  StringRef getAbbrevSection() override { return AbbrevSection; }
  const Section &getLocSection() override { return LocSection; }
  StringRef getARangeSection() override { return ARangeSection; }
  StringRef getDebugFrameSection() override { return DebugFrameSection; }
  const Section &getLineSection() override { return LineSection; }
  const Section &getLineDWOSection() override { return LineDWOSection; }
  StringRef getStringSection() override { return StringSection; }
  StringRef getRangeSection() override { return RangeSection; }
  StringRef getPubNamesSection() override { return PubNamesSection; }
  StringRef getPubTypesSection() override { return PubTypesSection; }
  StringRef getGnuPubNamesSection() override { return GnuPubNamesSection; }
  StringRef getGnuPubTypesSection() override { return GnuPubTypesSection; }

  // Sections for DWARF5 split dwarf proposal.
  const Section &getInfoDWOSection() override { return InfoDWOSection; }
  const TypeSectionMap &getTypesDWOSections() override {
    return TypesDWOSections;
  }
  StringRef getAbbrevDWOSection() override { return AbbrevDWOSection; }
  StringRef getStringDWOSection() override { return StringDWOSection; }
  StringRef getStringOffsetDWOSection() override {
    return StringOffsetDWOSection;
  }
  StringRef getRangeDWOSection() override { return RangeDWOSection; }
  StringRef getAddrSection() override {
    return AddrSection;
  }
};

}

#endif
