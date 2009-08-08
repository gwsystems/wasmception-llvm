//===-- SparcTargetAsmInfo.cpp - Sparc asm properties ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the SparcTargetAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "SparcTargetAsmInfo.h"
#include "llvm/ADT/SmallVector.h"
using namespace llvm;

SparcELFTargetAsmInfo::SparcELFTargetAsmInfo() {
  Data16bitsDirective = "\t.half\t";
  Data32bitsDirective = "\t.word\t";
  Data64bitsDirective = 0;  // .xword is only supported by V9.
  ZeroDirective = "\t.skip\t";
  CommentString = "!";
  COMMDirectiveTakesAlignment = true;
  
  SunStyleELFSectionSwitchSyntax = true;
}


