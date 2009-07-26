//===-- MipsTargetInfo.cpp - Mips Target Implementation -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "Mips.h"
#include "llvm/Module.h"
#include "llvm/Target/TargetRegistry.h"
using namespace llvm;

Target llvm::TheMipsTarget;

static unsigned Mips_TripleMatchQuality(const std::string &TT) {
  // We strongly match "mips*-*".
  if (TT.size() >= 5 && std::string(TT.begin(), TT.begin()+5) == "mips-")
    return 20;
  
  if (TT.size() >= 13 && std::string(TT.begin(), 
      TT.begin()+13) == "mipsallegrex-")
    return 20;

  return 0;
}

Target llvm::TheMipselTarget;

static unsigned Mipsel_TripleMatchQuality(const std::string &TT) {
  // We strongly match "mips*el-*".
  if (TT.size() >= 7 && std::string(TT.begin(), TT.begin()+7) == "mipsel-")
    return 20;

  if (TT.size() >= 15 && std::string(TT.begin(), 
      TT.begin()+15) == "mipsallegrexel-")
    return 20;

  if (TT.size() == 3 && std::string(TT.begin(), TT.begin()+3) == "psp")
    return 20;

  return 0;
}

extern "C" void LLVMInitializeMipsTargetInfo() { 
  TargetRegistry::RegisterTarget(TheMipsTarget, "mips",
                                  "Mips",
                                  &Mips_TripleMatchQuality);

  TargetRegistry::RegisterTarget(TheMipselTarget, "mipsel",
                                  "Mipsel",
                                  &Mipsel_TripleMatchQuality);
}
