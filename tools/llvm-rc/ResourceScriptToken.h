//===-- ResourceScriptToken.h -----------------------------------*- C++-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===---------------------------------------------------------------------===//
//
// This declares the .rc script tokens and defines an interface for tokenizing
// the input data. The list of available tokens is located at
// ResourceScriptTokenList.h.
//
// Note that the tokenizer does not support comments or preprocessor
// directives. The preprocessor should do its work on the .rc file before
// running llvm-rc.
//
// As for now, it is possible to parse ASCII files only (the behavior on
// UTF files might be undefined). However, it already consumes UTF-8 BOM, if
// there is any. Thus, ASCII-compatible UTF-8 files are tokenized correctly.
//
// Ref: msdn.microsoft.com/en-us/library/windows/desktop/aa380599(v=vs.85).aspx
//
//===---------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVMRC_RESOURCESCRIPTTOKEN_H
#define LLVM_TOOLS_LLVMRC_RESOURCESCRIPTTOKEN_H

#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Error.h"

#include <cstdint>
#include <map>
#include <string>
#include <vector>

namespace llvm {

// A definition of a single resource script token. Each token has its kind
// (declared in ResourceScriptTokenList) and holds a value - a reference
// representation of the token.
// RCToken does not claim ownership on its value. A memory buffer containing
// the token value should be stored in a safe place and cannot be freed
// nor reallocated.
class RCToken {
public:
  enum class Kind {
#define TOKEN(Name) Name,
#define SHORT_TOKEN(Name, Ch) Name,
#include "ResourceScriptTokenList.h"
#undef TOKEN
#undef SHORT_TOKEN
  };

  RCToken(RCToken::Kind RCTokenKind, StringRef Value);

  // Get an integer value of the integer token.
  uint32_t intValue() const;

  StringRef value() const;
  Kind kind() const;

private:
  Kind TokenKind;
  StringRef TokenValue;
};

// Tokenize Input.
// In case no error occured, the return value contains
//   tokens in order they were in the input file.
// In case of any error, the return value contains
//   a textual representation of error.
//
// Tokens returned by this function hold only references to the parts
// of the Input. Memory buffer containing Input cannot be freed,
// modified or reallocated.
Expected<std::vector<RCToken>> tokenizeRC(StringRef Input);

} // namespace llvm

#endif
