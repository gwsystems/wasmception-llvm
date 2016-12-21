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

bool DWARFDebugInfoEntry::extractFast(const DWARFUnit &U,
                                             uint32_t *OffsetPtr) {
  DataExtractor DebugInfoData = U.getDebugInfoExtractor();
  const uint32_t UEndOffset = U.getNextUnitOffset();
  return extractFast(U, OffsetPtr, DebugInfoData, UEndOffset, 0);
}
bool DWARFDebugInfoEntry::extractFast(const DWARFUnit &U, uint32_t *OffsetPtr,
                                      const DataExtractor &DebugInfoData,
                                      uint32_t UEndOffset, uint32_t D) {
  Offset = *OffsetPtr;
  Depth = D;
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
