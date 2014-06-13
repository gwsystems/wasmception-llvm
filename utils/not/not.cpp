//===- not.cpp - The 'not' testing tool -----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/Path.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

int main(int argc, const char **argv) {
  bool ExpectCrash = false;

  ++argv;
  --argc;

  if (argc > 0 && StringRef(argv[0]) == "--crash") {
    ++argv;
    --argc;
    ExpectCrash = true;
  }

  if (argc == 0)
    return 1;

  std::string Program = sys::FindProgramByName(argv[0]);

  std::string ErrMsg;
  int Result = sys::ExecuteAndWait(Program, argv, nullptr, nullptr, 0, 0,
                                   &ErrMsg);
#ifdef _WIN32
  // Handle abort() in msvcrt -- It has exit code as 3.
  // abort(), aka unreachable, may be handled as crash.
  // FIXME: Could we move this into Win32/Program.inc?
  if (Result == 3)
    Result = -3;
#endif
  if (Result < 0) {
    errs() << "Error: " << ErrMsg << "\n";
    if (ExpectCrash)
      return 0;
    return 1;
  }

  if (ExpectCrash)
    return 1;

  return Result == 0;
}
