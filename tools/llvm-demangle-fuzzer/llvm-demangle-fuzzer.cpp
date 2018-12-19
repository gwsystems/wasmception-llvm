//===--- llvm-demangle-fuzzer.cpp - Fuzzer for the Itanium Demangler ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Demangle/Demangle.h"

#include <cstdint>
#include <cstdlib>
#include <string>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  std::string NullTerminatedString((const char *)Data, Size);
  int status = 0;
  if (char *demangle = llvm::itaniumDemangle(NullTerminatedString.c_str(), nullptr,
                                         nullptr, &status))
    free(demangle);

  return 0;
}
