//===-- DWARFDebugInfoEntry.cpp -------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "SyntaxHighlighting.h"
#include "llvm/DebugInfo/DWARF/DWARFCompileUnit.h"
#include "llvm/DebugInfo/DWARF/DWARFContext.h"
#include "llvm/DebugInfo/DWARF/DWARFDebugAbbrev.h"
#include "llvm/DebugInfo/DWARF/DWARFDebugInfoEntry.h"
#include "llvm/DebugInfo/DWARF/DWARFFormValue.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;
using namespace dwarf;
using namespace syntax;

// Small helper to extract a DIE pointed by a reference
// attribute. It looks up the Unit containing the DIE and calls
// DIE.extractFast with the right unit. Returns new unit on success,
// nullptr otherwise.
static const DWARFUnit *findUnitAndExtractFast(DWARFDebugInfoEntryMinimal &DIE,
                                               const DWARFUnit *Unit,
                                               uint32_t *Offset) {
  Unit = Unit->getUnitSection().getUnitForOffset(*Offset);
  return (Unit && DIE.extractFast(*Unit, Offset)) ? Unit : nullptr;
}

void DWARFDebugInfoEntryMinimal::dump(raw_ostream &OS, DWARFUnit *u,
                                      unsigned recurseDepth,
                                      unsigned indent) const {
  DataExtractor debug_info_data = u->getDebugInfoExtractor();
  uint32_t offset = Offset;

  if (debug_info_data.isValidOffset(offset)) {
    uint32_t abbrCode = debug_info_data.getULEB128(&offset);
    WithColor(OS, syntax::Address).get() << format("\n0x%8.8x: ", Offset);

    if (abbrCode) {
      if (AbbrevDecl) {
        auto tagString = TagString(getTag());
        if (!tagString.empty())
          WithColor(OS, syntax::Tag).get().indent(indent) << tagString;
        else
          WithColor(OS, syntax::Tag).get().indent(indent)
              << format("DW_TAG_Unknown_%x", getTag());

        OS << format(" [%u] %c\n", abbrCode,
                     AbbrevDecl->hasChildren() ? '*' : ' ');

        // Dump all data in the DIE for the attributes.
        for (const auto &AttrSpec : AbbrevDecl->attributes()) {
          dumpAttribute(OS, u, &offset, AttrSpec.Attr, AttrSpec.Form, indent);
        }

        const DWARFDebugInfoEntryMinimal *child = getFirstChild();
        if (recurseDepth > 0 && child) {
          while (child) {
            child->dump(OS, u, recurseDepth-1, indent+2);
            child = child->getSibling();
          }
        }
      } else {
        OS << "Abbreviation code not found in 'debug_abbrev' class for code: "
           << abbrCode << '\n';
      }
    } else {
      OS.indent(indent) << "NULL\n";
    }
  }
}

static void dumpApplePropertyAttribute(raw_ostream &OS, uint64_t Val) {
  OS << " (";
  do {
    uint64_t Shift = countTrailingZeros(Val);
    assert(Shift < 64 && "undefined behavior");
    uint64_t Bit = 1ULL << Shift;
    auto PropName = ApplePropertyString(Bit);
    if (!PropName.empty())
      OS << PropName;
    else
      OS << format("DW_APPLE_PROPERTY_0x%" PRIx64, Bit);
    if (!(Val ^= Bit))
      break;
    OS << ", ";
  } while (true);
  OS << ")";
}

static void dumpRanges(raw_ostream &OS, const DWARFAddressRangesVector& Ranges,
                       unsigned AddressSize, unsigned Indent) {
  if (Ranges.empty())
    return;

  for (const auto &Range: Ranges) {
    OS << '\n';
    OS.indent(Indent);
    OS << format("[0x%0*" PRIx64 " - 0x%0*" PRIx64 ")",
                 AddressSize*2, Range.first,
                 AddressSize*2, Range.second);
  }
}

void DWARFDebugInfoEntryMinimal::dumpAttribute(raw_ostream &OS,
                                               DWARFUnit *u,
                                               uint32_t *offset_ptr,
                                               dwarf::Attribute attr, 
                                               dwarf::Form form,
                                               unsigned indent) const {
  const char BaseIndent[] = "            ";
  OS << BaseIndent;
  OS.indent(indent+2);
  auto attrString = AttributeString(attr);
  if (!attrString.empty())
    WithColor(OS, syntax::Attribute) << attrString;
  else
    WithColor(OS, syntax::Attribute).get() << format("DW_AT_Unknown_%x", attr);

  auto formString = FormEncodingString(form);
  if (!formString.empty())
    OS << " [" << formString << ']';
  else
    OS << format(" [DW_FORM_Unknown_%x]", form);

  DWARFFormValue formValue(form);

  if (!formValue.extractValue(u->getDebugInfoExtractor(), offset_ptr, u))
    return;

  OS << "\t(";

  StringRef Name;
  std::string File;
  auto Color = syntax::Enumerator;
  if (attr == DW_AT_decl_file || attr == DW_AT_call_file) {
    Color = syntax::String;
    if (const auto *LT = u->getContext().getLineTableForUnit(u))
      if (LT->getFileNameByIndex(
             formValue.getAsUnsignedConstant().getValue(),
             u->getCompilationDir(),
             DILineInfoSpecifier::FileLineInfoKind::AbsoluteFilePath, File)) {
        File = '"' + File + '"';
        Name = File;
      }
  } else if (Optional<uint64_t> Val = formValue.getAsUnsignedConstant())
    Name = AttributeValueString(attr, *Val);

  if (!Name.empty())
    WithColor(OS, Color) << Name;
  else if (attr == DW_AT_decl_line || attr == DW_AT_call_line)
    OS << *formValue.getAsUnsignedConstant();
  else
    formValue.dump(OS);

  // We have dumped the attribute raw value. For some attributes
  // having both the raw value and the pretty-printed value is
  // interesting. These attributes are handled below.
  if (attr == DW_AT_specification || attr == DW_AT_abstract_origin) {
    Optional<uint64_t> Ref = formValue.getAsReference();
    if (Ref.hasValue()) {
      uint32_t RefOffset = Ref.getValue();
      DWARFDebugInfoEntryMinimal DIE;
      if (const DWARFUnit *RefU = findUnitAndExtractFast(DIE, u, &RefOffset))
        if (const char *Name = DIE.getName(RefU, DINameKind::LinkageName))
          OS << " \"" << Name << '\"';
    }
  } else if (attr == DW_AT_APPLE_property_attribute) {
    if (Optional<uint64_t> OptVal = formValue.getAsUnsignedConstant())
      dumpApplePropertyAttribute(OS, *OptVal);
  } else if (attr == DW_AT_ranges) {
    dumpRanges(OS, getAddressRanges(u), u->getAddressByteSize(),
               sizeof(BaseIndent)+indent+4);
  }

  OS << ")\n";
}

bool DWARFDebugInfoEntryMinimal::extractFast(const DWARFUnit &U,
                                             uint32_t *OffsetPtr) {
  DataExtractor DebugInfoData = U.getDebugInfoExtractor();
  const uint32_t UEndOffset = U.getNextUnitOffset();
  return extractFast(U, OffsetPtr, DebugInfoData, UEndOffset);
}
bool DWARFDebugInfoEntryMinimal::extractFast(const DWARFUnit &U,
                                             uint32_t *OffsetPtr,
                                             const DataExtractor &DebugInfoData,
                                             uint32_t UEndOffset) {
  Offset = *OffsetPtr;
  if (Offset >= UEndOffset || !DebugInfoData.isValidOffset(Offset))
    return false;
  uint64_t AbbrCode = DebugInfoData.getULEB128(OffsetPtr);
  if (0 == AbbrCode) {
    // NULL debug tag entry.
    AbbrevDecl = nullptr;
    return true;
  }
  AbbrevDecl = U.getAbbreviations()->getAbbreviationDeclaration(AbbrCode);
  if (nullptr == AbbrevDecl) {
    // Restore the original offset.
    *OffsetPtr = Offset;
    return false;
  }
  // See if all attributes in this DIE have fixed byte sizes. If so, we can
  // just add this size to the offset to skip to the next DIE.
  if (Optional<size_t> FixedSize = AbbrevDecl->getFixedAttributesByteSize(U)) {
    *OffsetPtr += *FixedSize;
    return true;
  }

  // Skip all data in the .debug_info for the attributes
  for (const auto &AttrSpec : AbbrevDecl->attributes()) {
    // Check if this attribute has a fixed byte size.
    if (Optional<uint8_t> FixedSize = AttrSpec.getByteSize(U)) {
      // Attribute byte size if fixed, just add the size to the offset.
      *OffsetPtr += *FixedSize;
    } else if (!DWARFFormValue::skipValue(AttrSpec.Form, DebugInfoData,
                                          OffsetPtr, &U)) {
      // We failed to skip this attribute's value, restore the original offset
      // and return the failure status.
      *OffsetPtr = Offset;
      return false;
    }
  }
  return true;
}

bool DWARFDebugInfoEntryMinimal::isSubprogramDIE() const {
  return getTag() == DW_TAG_subprogram;
}

bool DWARFDebugInfoEntryMinimal::isSubroutineDIE() const {
  uint32_t Tag = getTag();
  return Tag == DW_TAG_subprogram ||
         Tag == DW_TAG_inlined_subroutine;
}

bool DWARFDebugInfoEntryMinimal::getAttributeValue(const DWARFUnit *U, 
    dwarf::Attribute Attr, DWARFFormValue &FormValue) const {
  if (!AbbrevDecl || !U)
    return false;
  return AbbrevDecl->getAttributeValue(Offset, Attr, *U, FormValue);
}

const char *DWARFDebugInfoEntryMinimal::getAttributeValueAsString(
    const DWARFUnit *U, dwarf::Attribute Attr, 
    const char *FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<const char *> Result = FormValue.getAsCString();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsAddress(
    const DWARFUnit *U, dwarf::Attribute Attr, 
    uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<uint64_t> Result = FormValue.getAsAddress();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

int64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsSignedConstant(
    const DWARFUnit *U, dwarf::Attribute Attr, int64_t FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<int64_t> Result = FormValue.getAsSignedConstant();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsUnsignedConstant(
    const DWARFUnit *U, dwarf::Attribute Attr, 
    uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<uint64_t> Result = FormValue.getAsUnsignedConstant();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsReference(
    const DWARFUnit *U, dwarf::Attribute Attr, 
    uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<uint64_t> Result = FormValue.getAsReference();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsSectionOffset(
    const DWARFUnit *U, dwarf::Attribute Attr, 
    uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (!getAttributeValue(U, Attr, FormValue))
    return FailValue;
  Optional<uint64_t> Result = FormValue.getAsSectionOffset();
  return Result.hasValue() ? Result.getValue() : FailValue;
}

uint64_t
DWARFDebugInfoEntryMinimal::getRangesBaseAttribute(const DWARFUnit *U,
                                                   uint64_t FailValue) const {
  uint64_t Result =
      getAttributeValueAsSectionOffset(U, DW_AT_rnglists_base, -1ULL);
  if (Result != -1ULL)
    return Result;
  return getAttributeValueAsSectionOffset(U, DW_AT_GNU_ranges_base, FailValue);
}

bool DWARFDebugInfoEntryMinimal::getLowAndHighPC(const DWARFUnit *U,
                                                 uint64_t &LowPC,
                                                 uint64_t &HighPC) const {
  LowPC = getAttributeValueAsAddress(U, DW_AT_low_pc, -1ULL);
  if (LowPC == -1ULL)
    return false;
  HighPC = getAttributeValueAsAddress(U, DW_AT_high_pc, -1ULL);
  if (HighPC == -1ULL) {
    // Since DWARF4, DW_AT_high_pc may also be of class constant, in which case
    // it represents function size.
    HighPC = getAttributeValueAsUnsignedConstant(U, DW_AT_high_pc, -1ULL);
    if (HighPC != -1ULL)
      HighPC += LowPC;
  }
  return (HighPC != -1ULL);
}

DWARFAddressRangesVector
DWARFDebugInfoEntryMinimal::getAddressRanges(const DWARFUnit *U) const {
  if (isNULL())
    return DWARFAddressRangesVector();
  // Single range specified by low/high PC.
  uint64_t LowPC, HighPC;
  if (getLowAndHighPC(U, LowPC, HighPC)) {
    return DWARFAddressRangesVector(1, std::make_pair(LowPC, HighPC));
  }
  // Multiple ranges from .debug_ranges section.
  uint32_t RangesOffset =
      getAttributeValueAsSectionOffset(U, DW_AT_ranges, -1U);
  if (RangesOffset != -1U) {
    DWARFDebugRangeList RangeList;
    if (U->extractRangeList(RangesOffset, RangeList))
      return RangeList.getAbsoluteRanges(U->getBaseAddress());
  }
  return DWARFAddressRangesVector();
}

void DWARFDebugInfoEntryMinimal::collectChildrenAddressRanges(
    const DWARFUnit *U, DWARFAddressRangesVector& Ranges) const {
  if (isNULL())
    return;
  if (isSubprogramDIE()) {
    const auto &DIERanges = getAddressRanges(U);
    Ranges.insert(Ranges.end(), DIERanges.begin(), DIERanges.end());
  }

  const DWARFDebugInfoEntryMinimal *Child = getFirstChild();
  while (Child) {
    Child->collectChildrenAddressRanges(U, Ranges);
    Child = Child->getSibling();
  }
}

bool DWARFDebugInfoEntryMinimal::addressRangeContainsAddress(
    const DWARFUnit *U, const uint64_t Address) const {
  for (const auto& R : getAddressRanges(U)) {
    if (R.first <= Address && Address < R.second)
      return true;
  }
  return false;
}

const char *
DWARFDebugInfoEntryMinimal::getSubroutineName(const DWARFUnit *U,
                                              DINameKind Kind) const {
  if (!isSubroutineDIE())
    return nullptr;
  return getName(U, Kind);
}

const char *
DWARFDebugInfoEntryMinimal::getName(const DWARFUnit *U,
                                    DINameKind Kind) const {
  if (Kind == DINameKind::None)
    return nullptr;
  // Try to get mangled name only if it was asked for.
  if (Kind == DINameKind::LinkageName) {
    if (const char *name =
            getAttributeValueAsString(U, DW_AT_MIPS_linkage_name, nullptr))
      return name;
    if (const char *name =
            getAttributeValueAsString(U, DW_AT_linkage_name, nullptr))
      return name;
  }
  if (const char *name = getAttributeValueAsString(U, DW_AT_name, nullptr))
    return name;
  // Try to get name from specification DIE.
  uint32_t spec_ref =
      getAttributeValueAsReference(U, DW_AT_specification, -1U);
  if (spec_ref != -1U) {
    DWARFDebugInfoEntryMinimal spec_die;
    if (const DWARFUnit *RefU = findUnitAndExtractFast(spec_die, U, &spec_ref)) {
      if (const char *name = spec_die.getName(RefU, Kind))
        return name;
    }
  }
  // Try to get name from abstract origin DIE.
  uint32_t abs_origin_ref =
      getAttributeValueAsReference(U, DW_AT_abstract_origin, -1U);
  if (abs_origin_ref != -1U) {
    DWARFDebugInfoEntryMinimal abs_origin_die;
    if (const DWARFUnit *RefU = findUnitAndExtractFast(abs_origin_die, U,
                                                       &abs_origin_ref)) {
      if (const char *name = abs_origin_die.getName(RefU, Kind))
        return name;
    }
  }
  return nullptr;
}

void DWARFDebugInfoEntryMinimal::getCallerFrame(const DWARFUnit *U,
                                                uint32_t &CallFile,
                                                uint32_t &CallLine,
                                                uint32_t &CallColumn) const {
  CallFile = getAttributeValueAsUnsignedConstant(U, DW_AT_call_file, 0);
  CallLine = getAttributeValueAsUnsignedConstant(U, DW_AT_call_line, 0);
  CallColumn = getAttributeValueAsUnsignedConstant(U, DW_AT_call_column, 0);
}

DWARFDebugInfoEntryInlinedChain
DWARFDebugInfoEntryMinimal::getInlinedChainForAddress(
    const DWARFUnit *U, const uint64_t Address) const {
  DWARFDebugInfoEntryInlinedChain InlinedChain;
  InlinedChain.U = U;
  if (isNULL())
    return InlinedChain;
  for (const DWARFDebugInfoEntryMinimal *DIE = this; DIE; ) {
    // Append current DIE to inlined chain only if it has correct tag
    // (e.g. it is not a lexical block).
    if (DIE->isSubroutineDIE()) {
      InlinedChain.DIEs.push_back(*DIE);
    }
    // Try to get child which also contains provided address.
    const DWARFDebugInfoEntryMinimal *Child = DIE->getFirstChild();
    while (Child) {
      if (Child->addressRangeContainsAddress(U, Address)) {
        // Assume there is only one such child.
        break;
      }
      Child = Child->getSibling();
    }
    DIE = Child;
  }
  // Reverse the obtained chain to make the root of inlined chain last.
  std::reverse(InlinedChain.DIEs.begin(), InlinedChain.DIEs.end());
  return InlinedChain;
}
