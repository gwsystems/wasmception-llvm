//===- llvm-cov.cpp - LLVM coverage tool ----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// llvm-cov is a command line tools to analyze and report coverage information.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Path.h"
#include <string>

using namespace llvm;

/// \brief The main entry point for the 'show' subcommand.
int show_main(int argc, const char **argv);

/// \brief The main entry point for the 'report' subcommand.
int report_main(int argc, const char **argv);

/// \brief The main entry point for the 'convert-for-testing' subcommand.
int convert_for_testing_main(int argc, const char **argv);

/// \brief The main entry point for the gcov compatible coverage tool.
int gcov_main(int argc, const char **argv);

/// \brief Top level help.
int help_main(int argc, const char **argv) {
  errs() << "OVERVIEW: LLVM code coverage tool\n\n"
         << "USAGE: llvm-cov {gcov|report|show}\n";
  return 0;
}

int main(int argc, const char **argv) {
  // If argv[0] is or ends with 'gcov', always be gcov compatible
  if (sys::path::stem(argv[0]).endswith_lower("gcov"))
    return gcov_main(argc, argv);

  // Check if we are invoking a specific tool command.
  if (argc > 1) {
    typedef int (*MainFunction)(int, const char **);
    MainFunction func =
        StringSwitch<MainFunction>(argv[1])
            .Case("convert-for-testing", convert_for_testing_main)
            .Case("gcov", gcov_main)
            .Case("report", report_main)
            .Case("show", show_main)
            .Cases("-h", "-help", "--help", help_main)
            .Default(nullptr);

    if (func) {
      std::string Invocation = std::string(argv[0]) + " " + argv[1];
      argv[1] = Invocation.c_str();
      return func(argc - 1, argv + 1);
    }
  }

  // Give a warning and fall back to gcov
  errs().changeColor(raw_ostream::RED);
  errs() << "warning:";
  // Assume that argv[1] wasn't a command when it stats with a '-' or is a
  // filename (i.e. contains a '.')
  if (argc > 1 && !StringRef(argv[1]).startswith("-") &&
      StringRef(argv[1]).find(".") == StringRef::npos)
    errs() << " Unrecognized command '" << argv[1] << "'.";
  errs() << " Using the gcov compatible mode "
            "(this behaviour may be dropped in the future).";
  errs().resetColor();
  errs() << "\n";

  return gcov_main(argc, argv);
}
