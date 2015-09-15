//===-- MipsMCAsmInfo.cpp - Mips Asm Properties ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the MipsMCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "MipsMCAsmInfo.h"
#include "llvm/ADT/TargetTuple.h"

using namespace llvm;

void MipsMCAsmInfo::anchor() { }

MipsMCAsmInfo::MipsMCAsmInfo(const TargetTuple &TT) {
  if ((TT.getArch() == TargetTuple::mips) ||
      (TT.getArch() == TargetTuple::mips64))
    IsLittleEndian = false;

  if ((TT.getArch() == TargetTuple::mips64el) ||
      (TT.getArch() == TargetTuple::mips64)) {
    PointerSize = CalleeSaveStackSlotSize = 8;
  }

  AlignmentIsInBytes          = false;
  Data16bitsDirective         = "\t.2byte\t";
  Data32bitsDirective         = "\t.4byte\t";
  Data64bitsDirective         = "\t.8byte\t";
  PrivateGlobalPrefix         = "$";
  PrivateLabelPrefix          = "$";
  CommentString               = "#";
  ZeroDirective               = "\t.space\t";
  GPRel32Directive            = "\t.gpword\t";
  GPRel64Directive            = "\t.gpdword\t";
  UseAssignmentForEHBegin = true;
  SupportsDebugInformation = true;
  ExceptionsType = ExceptionHandling::DwarfCFI;
  DwarfRegNumForCFI = true;
}
