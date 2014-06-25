//===-- ARMMCExpr.cpp - ARM specific MC expression classes ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ARMMCExpr.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
using namespace llvm;

#define DEBUG_TYPE "armmcexpr"

const ARMMCExpr*
ARMMCExpr::Create(VariantKind Kind, const MCExpr *Expr,
                       MCContext &Ctx) {
  return new (Ctx) ARMMCExpr(Kind, Expr);
}

void ARMMCExpr::PrintImpl(raw_ostream &OS) const {
  switch (Kind) {
  default: llvm_unreachable("Invalid kind!");
  case VK_ARM_HI16: OS << ":upper16:"; break;
  case VK_ARM_LO16: OS << ":lower16:"; break;
  }

  const MCExpr *Expr = getSubExpr();
  if (Expr->getKind() != MCExpr::SymbolRef)
    OS << '(';
  Expr->print(OS);
  if (Expr->getKind() != MCExpr::SymbolRef)
    OS << ')';
}

bool
ARMMCExpr::EvaluateAsRelocatableImpl(MCValue &Res,
                                     const MCAsmLayout *Layout) const {
  return false;
}

void ARMMCExpr::visitUsedExpr(MCObjectStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}
