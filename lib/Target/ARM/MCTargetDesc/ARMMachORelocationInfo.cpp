//===-- ARMMachORelocationInfo.cpp ----------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/ARMMCTargetDesc.h"
#include "ARMMCExpr.h"
#include "llvm-c/Disassembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCDisassembler/MCRelocationInfo.h"

using namespace llvm;
using namespace object;

namespace {
class ARMMachORelocationInfo : public MCRelocationInfo {
public:
  ARMMachORelocationInfo(MCContext &Ctx) : MCRelocationInfo(Ctx) {}

  const MCExpr *createExprForCAPIVariantKind(const MCExpr *SubExpr,
                                             unsigned VariantKind) override {
    switch(VariantKind) {
    case LLVMDisassembler_VariantKind_ARM_HI16:
      return ARMMCExpr::createUpper16(SubExpr, Ctx);
    case LLVMDisassembler_VariantKind_ARM_LO16:
      return ARMMCExpr::createLower16(SubExpr, Ctx);
    default:
      return MCRelocationInfo::createExprForCAPIVariantKind(SubExpr,
                                                            VariantKind);
    }
  }
};
} // End unnamed namespace

/// createARMMachORelocationInfo - Construct an ARM Mach-O RelocationInfo.
MCRelocationInfo *llvm::createARMMachORelocationInfo(MCContext &Ctx) {
  return new ARMMachORelocationInfo(Ctx);
}
