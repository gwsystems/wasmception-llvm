//===- StringToOffsetTable.h - Emit a big concatenated string ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef TBLGEN_STRING_TO_OFFSET_TABLE_H
#define TBLGEN_STRING_TO_OFFSET_TABLE_H

#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/Support/raw_ostream.h"
#include <cctype>

namespace llvm {

/// StringToOffsetTable - This class uniques a bunch of nul-terminated strings
/// and keeps track of their offset in a massive contiguous string allocation.
/// It can then output this string blob and use indexes into the string to
/// reference each piece.
class StringToOffsetTable {
  StringMap<unsigned> StringOffset;
  std::string AggregateString;

public:
  unsigned GetOrAddStringOffset(StringRef Str, bool appendZero = true) {
    StringMapEntry<unsigned> &Entry = StringOffset.GetOrCreateValue(Str, -1U);
    if (Entry.getValue() == -1U) {
      // Add the string to the aggregate if this is the first time found.
      Entry.setValue(AggregateString.size());
      AggregateString.append(Str.begin(), Str.end());
      if (appendZero)
        AggregateString += '\0';
    }

    return Entry.getValue();
  }

  void EmitString(raw_ostream &O) {
    // Escape the string.
    small_string_ostream<256> Str;
    Str.write_escaped(AggregateString);
    AggregateString = Str.str();

    O << "    \"";
    unsigned CharsPrinted = 0;
    for (unsigned i = 0, e = AggregateString.size(); i != e; ++i) {
      if (CharsPrinted > 70) {
        O << "\"\n    \"";
        CharsPrinted = 0;
      }
      O << AggregateString[i];
      ++CharsPrinted;

      // Print escape sequences all together.
      if (AggregateString[i] != '\\')
        continue;

      assert(i+1 < AggregateString.size() && "Incomplete escape sequence!");
      if (isdigit(AggregateString[i+1])) {
        assert(isdigit(AggregateString[i+2]) && 
               isdigit(AggregateString[i+3]) &&
               "Expected 3 digit octal escape!");
        O << AggregateString[++i];
        O << AggregateString[++i];
        O << AggregateString[++i];
        CharsPrinted += 3;
      } else {
        O << AggregateString[++i];
        ++CharsPrinted;
      }
    }
    O << "\"";
  }
};

} // end namespace llvm

#endif
