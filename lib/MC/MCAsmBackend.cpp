//===-- MCAsmBackend.cpp - Target MC Assembly Backend ----------------------==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCAsmBackend.h"
using namespace llvm;

MCAsmBackend::MCAsmBackend()
  : HasReliableSymbolDifference(false)
{
}

MCAsmBackend::~MCAsmBackend() {
}

const MCFixupKindInfo &
MCAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  static const MCFixupKindInfo Builtins[] = {
    { "FK_Data_1",  0,  8, 0 },
    { "FK_Data_2",  0, 16, 0 },
    { "FK_Data_4",  0, 32, 0 },
    { "FK_Data_8",  0, 64, 0 },
    { "FK_PCRel_1", 0,  8, MCFixupKindInfo::FKF_IsPCRel },
    { "FK_PCRel_2", 0, 16, MCFixupKindInfo::FKF_IsPCRel },
    { "FK_PCRel_4", 0, 32, MCFixupKindInfo::FKF_IsPCRel },
    { "FK_PCRel_8", 0, 64, MCFixupKindInfo::FKF_IsPCRel },
    { "FK_GPRel_1", 0,  8, 0 },
    { "FK_GPRel_2", 0, 16, 0 },
    { "FK_GPRel_4", 0, 32, 0 },
    { "FK_GPRel_8", 0, 64, 0 }
  };
  
  assert((size_t)Kind <= sizeof(Builtins) / sizeof(Builtins[0]) &&
         "Unknown fixup kind");
  return Builtins[Kind];
}
