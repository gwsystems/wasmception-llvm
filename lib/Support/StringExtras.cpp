//===-- StringExtras.cpp - Implement the StringExtras header --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the StringExtras.h header
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringExtras.h"
using namespace llvm;

/// getToken - This function extracts one token from source, ignoring any
/// leading characters that appear in the Delimiters string, and ending the
/// token at any of the characters that appear in the Delimiters string.  If
/// there are no tokens in the source string, an empty string is returned.
/// The function returns a pair containing the extracted token and the
/// remaining tail string.
std::pair<StringRef, StringRef> llvm::getToken(StringRef Source,
                                               StringRef Delimiters) {
  // Figure out where the token starts.
  StringRef::size_type Start = Source.find_first_not_of(Delimiters);
  if (Start == StringRef::npos) Start = Source.size();

  // Find the next occurrence of the delimiter.
  StringRef::size_type End = Source.find_first_of(Delimiters, Start);
  if (End == StringRef::npos) End = Source.size();

  return std::make_pair(Source.substr(Start, End), Source.substr(End));
}

/// SplitString - Split up the specified string according to the specified
/// delimiters, appending the result fragments to the output list.
void llvm::SplitString(StringRef Source,
                       SmallVectorImpl<StringRef> &OutFragments,
                       StringRef Delimiters) {
  StringRef S2, S;
  tie(S2, S) = getToken(Source, Delimiters);
  while (!S2.empty()) {
    OutFragments.push_back(S2);
    tie(S2, S) = getToken(S, Delimiters);
  }
}

// FIXME: remove when llvm-gcc doesn't use this anymore
void llvm::SplitString(StringRef Source,
                       std::vector<std::string> &OutFragments,
                       StringRef Delimiters) {
  StringRef S2, S;
  tie(S2, S) = getToken(Source, Delimiters);
  while (!S2.empty()) {
    OutFragments.push_back(S2);
    tie(S2, S) = getToken(S, Delimiters);
  }
}

void llvm::StringRef::split(SmallVectorImpl<StringRef> &A,
                            StringRef Separators, int MaxSplit,
                            bool KeepEmpty) const {
  StringRef rest = *this;

  // rest.data() is used to distinguish cases like "a," that splits into
  // "a" + "" and "a" that splits into "a" + 0.
  for (int splits = 0;
       rest.data() != NULL && (MaxSplit < 0 || splits < MaxSplit);
       ++splits) {
    std::pair<llvm::StringRef, llvm::StringRef> p = rest.split(Separators);

    if (p.first.size() != 0 || KeepEmpty)
      A.push_back(p.first);
    rest = p.second;
  }
  // If we have a tail left, add it.
  if (rest.data() != NULL && (rest.size() != 0 || KeepEmpty))
    A.push_back(rest);
}
