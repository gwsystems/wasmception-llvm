//===- llvm/ADT/SmallString.h - 'Normally small' strings --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the SmallString class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ADT_SMALLSTRING_H
#define LLVM_ADT_SMALLSTRING_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"

namespace llvm {

/// SmallString - A SmallString is just a SmallVector with methods and accessors
/// that make it work better as a string (e.g. operator+ etc).
template<unsigned InternalLen>
class SmallString : public SmallVector<char, InternalLen> {
public:
  /// Default ctor - Initialize to empty.
  SmallString() {}

  /// Initialize from a StringRef.
  /*implicit*/ SmallString(StringRef S) : SmallVector<char, InternalLen>(S.begin(), S.end()) {}

  /// Initialize with a range.
  template<typename ItTy>
  SmallString(ItTy S, ItTy E) : SmallVector<char, InternalLen>(S, E) {}

  /// @}
  /// @name String Assignment
  /// @{

  // Provide assign from SmallVectorImpl<char>
  using SmallVectorImpl<char>::assign;

  /// Assign from a StringRef.
  void assign(StringRef RHS) {
    this->clear();
    SmallVectorImpl<char>::append(RHS.begin(), RHS.end());
  }

  /// Assign from a SmallVector.
  void assign(const SmallVectorImpl<char> &RHS) {
    this->clear();
    SmallVectorImpl<char>::append(RHS.begin(), RHS.end());
  }

  using SmallVectorImpl<char>::append;

  /// Append from a StringRef.
  void append(StringRef RHS) {
    SmallVectorImpl<char>::append(RHS.begin(), RHS.end());
  }

  /// Append from a SmallVector.
  void append(const SmallVectorImpl<char> &RHS) {
    SmallVectorImpl<char>::append(RHS.begin(), RHS.end());
  }

  /// @}
  /// @name String Comparison
  /// @{

  /// Check for string equality, ignoring case.
  bool equals_lower(StringRef RHS) const {
    return str().equals_lower(RHS);
  }

  /// Compare two strings; the result is -1, 0, or 1 if this string is
  /// lexicographically less than, equal to, or greater than the \p RHS.
  int compare(StringRef RHS) const {
    return str().compare(RHS);
  }

  /// compare_lower - Compare two strings, ignoring case.
  int compare_lower(StringRef RHS) const {
    return str().compare_lower(RHS);
  }

  /// compare_numeric - Compare two strings, treating sequences of digits as
  /// numbers.
  int compare_numeric(StringRef RHS) const {
    return str().compare_numeric(RHS);
  }

  /// @}
  /// @name String Predicates
  /// @{

  /// startswith - Check if this string starts with the given \p Prefix.
  bool startswith(StringRef Prefix) const {
    return str().startswith(Prefix);
  }

  /// endswith - Check if this string ends with the given \p Suffix.
  bool endswith(StringRef Suffix) const {
    return str().endswith(Suffix);
  }

  /// @}
  /// @name String Searching
  /// @{

  /// find - Search for the first character \p C in the string.
  ///
  /// \return - The index of the first occurrence of \p C, or npos if not
  /// found.
  size_t find(char C, size_t From = 0) const {
    return str().find(C, From);
  }

  /// Search for the first string \p Str in the string.
  ///
  /// \returns The index of the first occurrence of \p Str, or npos if not
  /// found.
  size_t find(StringRef Str, size_t From = 0) const {
    return str().find(Str, From);
  }

  /// Search for the last character \p C in the string.
  ///
  /// \returns The index of the last occurrence of \p C, or npos if not
  /// found.
  size_t rfind(char C, size_t From = StringRef::npos) const {
    return str().rfind(C, From);
  }

  /// Search for the last string \p Str in the string.
  ///
  /// \returns The index of the last occurrence of \p Str, or npos if not
  /// found.
  size_t rfind(StringRef Str) const {
    return str().rfind(Str);
  }

  /// Find the first character in the string that is \p C, or npos if not
  /// found. Same as find.
  size_t find_first_of(char C, size_t From = 0) const {
    return str().find_first_of(C, From);
  }

  /// Find the first character in the string that is in \p Chars, or npos if
  /// not found.
  ///
  /// Complexity: O(size() + Chars.size())
  size_t find_first_of(StringRef Chars, size_t From = 0) const {
    return str().find_first_of(Chars, From);
  }

  /// Find the first character in the string that is not \p C or npos if not
  /// found.
  size_t find_first_not_of(char C, size_t From = 0) const {
    return str().find_first_not_of(C, From);
  }

  /// Find the first character in the string that is not in the string
  /// \p Chars, or npos if not found.
  ///
  /// Complexity: O(size() + Chars.size())
  size_t find_first_not_of(StringRef Chars, size_t From = 0) const {
    return str().find_first_not_of(Chars, From);
  }

  /// Find the last character in the string that is \p C, or npos if not
  /// found.
  size_t find_last_of(char C, size_t From = StringRef::npos) const {
    return str().find_last_of(C, From);
  }

  /// Find the last character in the string that is in \p C, or npos if not
  /// found.
  ///
  /// Complexity: O(size() + Chars.size())
  size_t find_last_of(
      StringRef Chars, size_t From = StringRef::npos) const {
    return str().find_last_of(Chars, From);
  }

  /// @}
  /// @name Helpful Algorithms
  /// @{

  /// Return the number of occurrences of \p C in the string.
  size_t count(char C) const {
    return str().count(C);
  }

  /// Return the number of non-overlapped occurrences of \p Str in the
  /// string.
  size_t count(StringRef Str) const {
    return str().count(Str);
  }

  /// @}
  /// @name Substring Operations
  /// @{

  /// Return a reference to the substring from [Start, Start + N).
  ///
  /// \param Start The index of the starting character in the substring; if
  /// the index is npos or greater than the length of the string then the
  /// empty substring will be returned.
  ///
  /// \param N The number of characters to included in the substring. If \p N
  /// exceeds the number of characters remaining in the string, the string
  /// suffix (starting with \p Start) will be returned.
  StringRef substr(size_t Start, size_t N = StringRef::npos) const {
    return str().substr(Start, N);
  }

  /// Return a reference to the substring from [Start, End).
  ///
  /// \param Start The index of the starting character in the substring; if
  /// the index is npos or greater than the length of the string then the
  /// empty substring will be returned.
  ///
  /// \param End The index following the last character to include in the
  /// substring. If this is npos, or less than \p Start, or exceeds the
  /// number of characters remaining in the string, the string suffix
  /// (starting with \p Start) will be returned.
  StringRef slice(size_t Start, size_t End) const {
    return str().slice(Start, End);
  }

  // Extra methods.

  /// Explicit conversion to StringRef.
  StringRef str() const { return StringRef(this->begin(), this->size()); }

  // TODO: Make this const, if it's safe...
  const char* c_str() {
    this->push_back(0);
    this->pop_back();
    return this->data();
  }

  /// Implicit conversion to StringRef.
  operator StringRef() const { return str(); }

  // Provide op= for SmallVectorImpl<char>
  using SmallVectorImpl<char>::operator=;

  // Extra operators.
  const SmallString &operator=(StringRef RHS) {
    this->clear();
    return *this += RHS;
  }

  SmallString &operator+=(StringRef RHS) {
    append(RHS.begin(), RHS.end());
    return *this;
  }

  SmallString &operator+=(const SmallVectorImpl<char> &RHS) {
    append(RHS.begin(), RHS.end());
    return *this;
  }

  SmallString &operator+=(char C) {
    this->push_back(C);
    return *this;
  }
};

}

#endif
