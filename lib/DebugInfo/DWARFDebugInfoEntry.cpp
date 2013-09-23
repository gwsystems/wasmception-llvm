//===-- DWARFDebugInfoEntry.cpp -------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "DWARFDebugInfoEntry.h"
#include "DWARFCompileUnit.h"
#include "DWARFContext.h"
#include "DWARFDebugAbbrev.h"
#include "llvm/DebugInfo/DWARFFormValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;
using namespace dwarf;

void DWARFDebugInfoEntryMinimal::dump(raw_ostream &OS, const DWARFUnit *u,
                                      unsigned recurseDepth,
                                      unsigned indent) const {
  DataExtractor debug_info_data = u->getDebugInfoExtractor();
  uint32_t offset = Offset;

  if (debug_info_data.isValidOffset(offset)) {
    uint32_t abbrCode = debug_info_data.getULEB128(&offset);

    OS << format("\n0x%8.8x: ", Offset);
    if (abbrCode) {
      if (AbbrevDecl) {
        const char *tagString = TagString(getTag());
        if (tagString)
          OS.indent(indent) << tagString;
        else
          OS.indent(indent) << format("DW_TAG_Unknown_%x", getTag());
        OS << format(" [%u] %c\n", abbrCode,
                     AbbrevDecl->hasChildren() ? '*' : ' ');

        // Dump all data in the DIE for the attributes.
        const uint32_t numAttributes = AbbrevDecl->getNumAttributes();
        for (uint32_t i = 0; i != numAttributes; ++i) {
          uint16_t attr = AbbrevDecl->getAttrByIndex(i);
          uint16_t form = AbbrevDecl->getFormByIndex(i);
          dumpAttribute(OS, u, &offset, attr, form, indent);
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

void DWARFDebugInfoEntryMinimal::dumpAttribute(raw_ostream &OS,
                                               const DWARFUnit *u,
                                               uint32_t *offset_ptr,
                                               uint16_t attr, uint16_t form,
                                               unsigned indent) const {
  OS << "            ";
  OS.indent(indent+2);
  const char *attrString = AttributeString(attr);
  if (attrString)
    OS << attrString;
  else
    OS << format("DW_AT_Unknown_%x", attr);
  const char *formString = FormEncodingString(form);
  if (formString)
    OS << " [" << formString << ']';
  else
    OS << format(" [DW_FORM_Unknown_%x]", form);

  DWARFFormValue formValue(form);

  if (!formValue.extractValue(u->getDebugInfoExtractor(), offset_ptr, u))
    return;

  OS << "\t(";
  formValue.dump(OS, u);
  OS << ")\n";
}

bool DWARFDebugInfoEntryMinimal::extractFast(const DWARFUnit *U,
                                             const uint8_t *FixedFormSizes,
                                             uint32_t *OffsetPtr) {
  Offset = *OffsetPtr;
  DataExtractor DebugInfoData = U->getDebugInfoExtractor();
  uint64_t AbbrCode = DebugInfoData.getULEB128(OffsetPtr);
  if (0 == AbbrCode) {
    // NULL debug tag entry.
    AbbrevDecl = NULL;
    return true;
  }
  AbbrevDecl = U->getAbbreviations()->getAbbreviationDeclaration(AbbrCode);
  assert(AbbrevDecl);
  assert(FixedFormSizes); // For best performance this should be specified!

  // Skip all data in the .debug_info for the attributes
  for (uint32_t i = 0, n = AbbrevDecl->getNumAttributes(); i < n; ++i) {
    uint16_t Form = AbbrevDecl->getFormByIndex(i);

    // FIXME: Currently we're checking if this is less than the last
    // entry in the fixed_form_sizes table, but this should be changed
    // to use dynamic dispatch.
    uint8_t FixedFormSize =
        (Form < DW_FORM_ref_sig8) ? FixedFormSizes[Form] : 0;
    if (FixedFormSize)
      *OffsetPtr += FixedFormSize;
    else if (!DWARFFormValue::skipValue(Form, DebugInfoData, OffsetPtr,
                                        U)) {
      // Restore the original offset.
      *OffsetPtr = Offset;
      return false;
    }
  }
  return true;
}

bool DWARFDebugInfoEntryMinimal::extract(const DWARFUnit *U,
                                         uint32_t *OffsetPtr) {
  DataExtractor DebugInfoData = U->getDebugInfoExtractor();
  const uint32_t UEndOffset = U->getNextUnitOffset();
  Offset = *OffsetPtr;
  if ((Offset >= UEndOffset) || !DebugInfoData.isValidOffset(Offset))
    return false;
  uint64_t AbbrCode = DebugInfoData.getULEB128(OffsetPtr);
  if (0 == AbbrCode) {
    // NULL debug tag entry.
    AbbrevDecl = NULL;
    return true;
  }
  AbbrevDecl = U->getAbbreviations()->getAbbreviationDeclaration(AbbrCode);
  if (0 == AbbrevDecl) {
    // Restore the original offset.
    *OffsetPtr = Offset;
    return false;
  }
  bool IsCompileUnitTag = (AbbrevDecl->getTag() == DW_TAG_compile_unit);
  if (IsCompileUnitTag)
    const_cast<DWARFUnit *>(U)->setBaseAddress(0);

  // Skip all data in the .debug_info for the attributes
  for (uint32_t i = 0, n = AbbrevDecl->getNumAttributes(); i < n; ++i) {
    uint16_t Attr = AbbrevDecl->getAttrByIndex(i);
    uint16_t Form = AbbrevDecl->getFormByIndex(i);

    if (IsCompileUnitTag &&
        ((Attr == DW_AT_entry_pc) || (Attr == DW_AT_low_pc))) {
      DWARFFormValue FormValue(Form);
      if (FormValue.extractValue(DebugInfoData, OffsetPtr, U)) {
        if (Attr == DW_AT_low_pc || Attr == DW_AT_entry_pc)
          const_cast<DWARFUnit *>(U)->setBaseAddress(FormValue.getUnsigned());
      }
    } else if (!DWARFFormValue::skipValue(Form, DebugInfoData, OffsetPtr, U)) {
      // Restore the original offset.
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

uint32_t DWARFDebugInfoEntryMinimal::getAttributeValue(
    const DWARFUnit *u, const uint16_t attr, DWARFFormValue &form_value,
    uint32_t *end_attr_offset_ptr) const {
  if (AbbrevDecl) {
    uint32_t attr_idx = AbbrevDecl->findAttributeIndex(attr);

    if (attr_idx != -1U) {
      uint32_t offset = getOffset();

      DataExtractor debug_info_data = u->getDebugInfoExtractor();

      // Skip the abbreviation code so we are at the data for the attributes
      debug_info_data.getULEB128(&offset);

      uint32_t idx = 0;
      while (idx < attr_idx)
        DWARFFormValue::skipValue(AbbrevDecl->getFormByIndex(idx++),
                                  debug_info_data, &offset, u);

      const uint32_t attr_offset = offset;
      form_value = DWARFFormValue(AbbrevDecl->getFormByIndex(idx));
      if (form_value.extractValue(debug_info_data, &offset, u)) {
        if (end_attr_offset_ptr)
          *end_attr_offset_ptr = offset;
        return attr_offset;
      }
    }
  }

  return 0;
}

const char *DWARFDebugInfoEntryMinimal::getAttributeValueAsString(
    const DWARFUnit *U, const uint16_t Attr, const char *FailValue) const {
  DWARFFormValue FormValue;
  if (getAttributeValue(U, Attr, FormValue))
    return FormValue.getAsCString(U);
  return FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsAddress(
    const DWARFUnit *U, const uint16_t Attr, uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (getAttributeValue(U, Attr, FormValue))
    return FormValue.getAsAddress(U);
  return FailValue;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsUnsigned(
    const DWARFUnit *U, const uint16_t Attr, uint64_t FailValue) const {
  DWARFFormValue FormValue;
  if (getAttributeValue(U, Attr, FormValue))
    return FormValue.getUnsigned();
  return FailValue;
}

int64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsSigned(
    const DWARFUnit *u, const uint16_t attr, int64_t fail_value) const {
  DWARFFormValue form_value;
  if (getAttributeValue(u, attr, form_value))
      return form_value.getSigned();
  return fail_value;
}

uint64_t DWARFDebugInfoEntryMinimal::getAttributeValueAsReference(
    const DWARFUnit *u, const uint16_t attr, uint64_t fail_value) const {
  DWARFFormValue form_value;
  if (getAttributeValue(u, attr, form_value))
      return form_value.getReference(u);
  return fail_value;
}

bool DWARFDebugInfoEntryMinimal::getLowAndHighPC(const DWARFUnit *U,
                                                 uint64_t &LowPC,
                                                 uint64_t &HighPC) const {
  HighPC = -1ULL;
  LowPC = getAttributeValueAsAddress(U, DW_AT_low_pc, -1ULL);
  if (LowPC != -1ULL)
    HighPC = getAttributeValueAsAddress(U, DW_AT_high_pc, -1ULL);
  return (HighPC != -1ULL);
}

void DWARFDebugInfoEntryMinimal::buildAddressRangeTable(
    const DWARFUnit *U, DWARFDebugAranges *DebugAranges,
    uint32_t UOffsetInAranges) const {
  if (AbbrevDecl) {
    if (isSubprogramDIE()) {
      uint64_t LowPC, HighPC;
      if (getLowAndHighPC(U, LowPC, HighPC))
        DebugAranges->appendRange(UOffsetInAranges, LowPC, HighPC);
      // FIXME: try to append ranges from .debug_ranges section.
    }

    const DWARFDebugInfoEntryMinimal *Child = getFirstChild();
    while (Child) {
      Child->buildAddressRangeTable(U, DebugAranges, UOffsetInAranges);
      Child = Child->getSibling();
    }
  }
}

bool DWARFDebugInfoEntryMinimal::addressRangeContainsAddress(
    const DWARFUnit *U, const uint64_t Address) const {
  if (isNULL())
    return false;
  uint64_t LowPC, HighPC;
  if (getLowAndHighPC(U, LowPC, HighPC))
    return (LowPC <= Address && Address <= HighPC);
  // Try to get address ranges from .debug_ranges section.
  uint32_t RangesOffset = getAttributeValueAsReference(U, DW_AT_ranges, -1U);
  if (RangesOffset != -1U) {
    DWARFDebugRangeList RangeList;
    if (U->extractRangeList(RangesOffset, RangeList))
      return RangeList.containsAddress(U->getBaseAddress(), Address);
  }
  return false;
}

const char *
DWARFDebugInfoEntryMinimal::getSubroutineName(const DWARFUnit *U) const {
  if (!isSubroutineDIE())
    return 0;
  // Try to get mangled name if possible.
  if (const char *name =
      getAttributeValueAsString(U, DW_AT_MIPS_linkage_name, 0))
    return name;
  if (const char *name = getAttributeValueAsString(U, DW_AT_linkage_name, 0))
    return name;
  if (const char *name = getAttributeValueAsString(U, DW_AT_name, 0))
    return name;
  // Try to get name from specification DIE.
  uint32_t spec_ref =
      getAttributeValueAsReference(U, DW_AT_specification, -1U);
  if (spec_ref != -1U) {
    DWARFDebugInfoEntryMinimal spec_die;
    if (spec_die.extract(U, &spec_ref)) {
      if (const char *name = spec_die.getSubroutineName(U))
        return name;
    }
  }
  // Try to get name from abstract origin DIE.
  uint32_t abs_origin_ref =
      getAttributeValueAsReference(U, DW_AT_abstract_origin, -1U);
  if (abs_origin_ref != -1U) {
    DWARFDebugInfoEntryMinimal abs_origin_die;
    if (abs_origin_die.extract(U, &abs_origin_ref)) {
      if (const char *name = abs_origin_die.getSubroutineName(U))
        return name;
    }
  }
  return 0;
}

void DWARFDebugInfoEntryMinimal::getCallerFrame(const DWARFUnit *U,
                                                uint32_t &CallFile,
                                                uint32_t &CallLine,
                                                uint32_t &CallColumn) const {
  CallFile = getAttributeValueAsUnsigned(U, DW_AT_call_file, 0);
  CallLine = getAttributeValueAsUnsigned(U, DW_AT_call_line, 0);
  CallColumn = getAttributeValueAsUnsigned(U, DW_AT_call_column, 0);
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
