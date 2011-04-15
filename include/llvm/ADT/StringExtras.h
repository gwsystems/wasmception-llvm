//===-- llvm/ADT/StringExtras.h - Useful string functions -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains some functions that are useful when dealing with strings.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ADT_STRINGEXTRAS_H
#define LLVM_ADT_STRINGEXTRAS_H

#include "llvm/Support/DataTypes.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/StringRef.h"
#include <cctype>
#include <cstdio>
#include <string>
#include <vector>

namespace llvm {
template<typename T> class SmallVectorImpl;

/// hexdigit - Return the hexadecimal character for the
/// given number \arg X (which should be less than 16).
static inline char hexdigit(unsigned X, bool LowerCase = false) {
  const char HexChar = LowerCase ? 'a' : 'A';
  return X < 10 ? '0' + X : HexChar + X - 10;
}

/// utohex_buffer - Emit the specified number into the buffer specified by
/// BufferEnd, returning a pointer to the start of the string.  This can be used
/// like this: (note that the buffer must be large enough to handle any number):
///    char Buffer[40];
///    printf("0x%s", utohex_buffer(X, Buffer+40));
///
/// This should only be used with unsigned types.
///
template<typename IntTy>
static inline char *utohex_buffer(IntTy X, char *BufferEnd) {
  char *BufPtr = BufferEnd;
  *--BufPtr = 0;      // Null terminate buffer.
  if (X == 0) {
    *--BufPtr = '0';  // Handle special case.
    return BufPtr;
  }

  while (X) {
    unsigned char Mod = static_cast<unsigned char>(X) & 15;
    *--BufPtr = hexdigit(Mod);
    X >>= 4;
  }
  return BufPtr;
}

static inline std::string utohexstr(uint64_t X) {
  char Buffer[17];
  return utohex_buffer(X, Buffer+17);
}

static inline std::string utostr_32(uint32_t X, bool isNeg = false) {
  char Buffer[11];
  char *BufPtr = Buffer+11;

  if (X == 0) *--BufPtr = '0';  // Handle special case...

  while (X) {
    *--BufPtr = '0' + char(X % 10);
    X /= 10;
  }

  if (isNeg) *--BufPtr = '-';   // Add negative sign...

  return std::string(BufPtr, Buffer+11);
}

static inline std::string utostr(uint64_t X, bool isNeg = false) {
  char Buffer[21];
  char *BufPtr = Buffer+21;

  if (X == 0) *--BufPtr = '0';  // Handle special case...

  while (X) {
    *--BufPtr = '0' + char(X % 10);
    X /= 10;
  }

  if (isNeg) *--BufPtr = '-';   // Add negative sign...
  return std::string(BufPtr, Buffer+21);
}


static inline std::string itostr(int64_t X) {
  if (X < 0)
    return utostr(static_cast<uint64_t>(-X), true);
  else
    return utostr(static_cast<uint64_t>(X));
}

static inline std::string ftostr(double V) {
  char Buffer[200];
  sprintf(Buffer, "%20.6e", V);
  char *B = Buffer;
  while (*B == ' ') ++B;
  return B;
}

static inline std::string ftostr(const APFloat& V) {
  if (&V.getSemantics() == &APFloat::IEEEdouble)
    return ftostr(V.convertToDouble());
  else if (&V.getSemantics() == &APFloat::IEEEsingle)
    return ftostr((double)V.convertToFloat());
  return "<unknown format in ftostr>"; // error
}

static inline std::string LowercaseString(const std::string &S) {
  std::string result(S);
  for (unsigned i = 0; i < S.length(); ++i)
    if (isupper(result[i]))
      result[i] = char(tolower(result[i]));
  return result;
}

static inline std::string UppercaseString(const std::string &S) {
  std::string result(S);
  for (unsigned i = 0; i < S.length(); ++i)
    if (islower(result[i]))
      result[i] = char(toupper(result[i]));
  return result;
}

/// StrInStrNoCase - Portable version of strcasestr.  Locates the first
/// occurrence of string 's1' in string 's2', ignoring case.  Returns
/// the offset of s2 in s1 or npos if s2 cannot be found.
StringRef::size_type StrInStrNoCase(StringRef s1, StringRef s2);

/// getToken - This function extracts one token from source, ignoring any
/// leading characters that appear in the Delimiters string, and ending the
/// token at any of the characters that appear in the Delimiters string.  If
/// there are no tokens in the source string, an empty string is returned.
/// The function returns a pair containing the extracted token and the
/// remaining tail string.
std::pair<StringRef, StringRef> getToken(StringRef Source,
                                         StringRef Delimiters = " \t\n\v\f\r");

/// SplitString - Split up the specified string according to the specified
/// delimiters, appending the result fragments to the output list.
void SplitString(StringRef Source,
                 SmallVectorImpl<StringRef> &OutFragments,
                 StringRef Delimiters = " \t\n\v\f\r");

/// HashString - Hash function for strings.
///
/// This is the Bernstein hash function.
//
// FIXME: Investigate whether a modified bernstein hash function performs
// better: http://eternallyconfuzzled.com/tuts/algorithms/jsw_tut_hashing.aspx
//   X*33+c -> X*33^c
static inline unsigned HashString(StringRef Str, unsigned Result = 0) {
  for (unsigned i = 0, e = Str.size(); i != e; ++i)
    Result = Result * 33 + Str[i];
  return Result;
}

} // End llvm namespace

#endif
