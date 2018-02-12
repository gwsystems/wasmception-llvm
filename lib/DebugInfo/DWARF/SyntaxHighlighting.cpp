//===- SyntaxHighlighting.cpp ---------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "SyntaxHighlighting.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using namespace dwarf;
using namespace syntax;

static cl::opt<cl::boolOrDefault>
    UseColor("color",
             cl::desc("use colored syntax highlighting (default=autodetect)"),
             cl::init(cl::BOU_UNSET));

bool WithColor::colorsEnabled(raw_ostream &OS) {
  switch (UseColor) {
  case cl::BOU_UNSET: return OS.has_colors();
  case cl::BOU_TRUE:  return true;
  case cl::BOU_FALSE: return false;
  }
}

WithColor::WithColor(raw_ostream &OS, enum HighlightColor Type) : OS(OS) {
  // Detect color from terminal type unless the user passed the --color option.
  if (colorsEnabled(OS)) {
    switch (Type) {
    case Address:    OS.changeColor(raw_ostream::YELLOW);         break;
    case String:     OS.changeColor(raw_ostream::GREEN);          break;
    case Tag:        OS.changeColor(raw_ostream::BLUE);           break;
    case Attribute:  OS.changeColor(raw_ostream::CYAN);           break;
    case Enumerator: OS.changeColor(raw_ostream::MAGENTA);        break;
    case Macro:      OS.changeColor(raw_ostream::RED);            break;
    case Error:      OS.changeColor(raw_ostream::RED, true);      break;
    case Warning:    OS.changeColor(raw_ostream::MAGENTA, true);  break;
    case Note:       OS.changeColor(raw_ostream::BLACK, true);    break;
    }
  }
}

WithColor::~WithColor() {
  if (colorsEnabled(OS))
    OS.resetColor();
}
