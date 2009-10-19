//===-- ARMMCInstLower.cpp - Convert ARM MachineInstr to an MCInst --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower ARM MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "ARMMCInstLower.h"
//#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
//#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/SmallString.h"
using namespace llvm;


#if 0
const ARMSubtarget &ARMMCInstLower::getSubtarget() const {
  return AsmPrinter.getSubtarget();
}

MachineModuleInfoMachO &ARMMCInstLower::getMachOMMI() const {
  assert(getSubtarget().isTargetDarwin() &&"Can only get MachO info on darwin");
  return AsmPrinter.MMI->getObjFileInfo<MachineModuleInfoMachO>(); 
}
#endif

MCSymbol *ARMMCInstLower::
GetGlobalAddressSymbol(const MachineOperand &MO) const {
  const GlobalValue *GV = MO.getGlobal();
  
  SmallString<128> Name;
  Mang.getNameWithPrefix(Name, GV, false);
  
  // FIXME: HANDLE PLT references how??
  switch (MO.getTargetFlags()) {
  default: assert(0 && "Unknown target flag on GV operand");
  case 0: break;
  }
  
  return Ctx.GetOrCreateSymbol(Name.str());
}


MCSymbol *ARMMCInstLower::
GetJumpTableSymbol(const MachineOperand &MO) const {
  SmallString<256> Name;
  raw_svector_ostream(Name) << MAI.getPrivateGlobalPrefix() << "JTI"
    << CurFunctionNumber << '_' << MO.getIndex();
  
#if 0
  switch (MO.getTargetFlags()) {
    default: llvm_unreachable("Unknown target flag on GV operand");
  }
#endif
  
  // Create a symbol for the name.
  return Ctx.GetOrCreateSymbol(Name.str());
}

MCSymbol *ARMMCInstLower::
GetConstantPoolIndexSymbol(const MachineOperand &MO) const {
  SmallString<256> Name;
  raw_svector_ostream(Name) << MAI.getPrivateGlobalPrefix() << "CPI"
    << CurFunctionNumber << '_' << MO.getIndex();
  
#if 0
  switch (MO.getTargetFlags()) {
  default: llvm_unreachable("Unknown target flag on GV operand");
  }
#endif
  
  // Create a symbol for the name.
  return Ctx.GetOrCreateSymbol(Name.str());
}
  
MCOperand ARMMCInstLower::
LowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym) const {
  // FIXME: We would like an efficient form for this, so we don't have to do a
  // lot of extra uniquing.
  const MCExpr *Expr = MCSymbolRefExpr::Create(Sym, Ctx);
  
#if 0
  switch (MO.getTargetFlags()) {
  default: llvm_unreachable("Unknown target flag on GV operand");
  }
#endif
  
  if (!MO.isJTI() && MO.getOffset())
    Expr = MCBinaryExpr::CreateAdd(Expr,
                                   MCConstantExpr::Create(MO.getOffset(), Ctx),
                                   Ctx);
  return MCOperand::CreateExpr(Expr);
}


void ARMMCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
  OutMI.setOpcode(MI->getOpcode());
  
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI->getOperand(i);
    
    MCOperand MCOp;
    switch (MO.getType()) {
    default:
      MI->dump();
      assert(0 && "unknown operand type");
    case MachineOperand::MO_Register:
      // Ignore all implicit register operands.
      if (MO.isImplicit()) continue;
      MCOp = MCOperand::CreateReg(MO.getReg());
      break;
    case MachineOperand::MO_Immediate:
      MCOp = MCOperand::CreateImm(MO.getImm());
      break;
#if 0
    case MachineOperand::MO_MachineBasicBlock:
      MCOp = MCOperand::CreateExpr(MCSymbolRefExpr::Create(
                       AsmPrinter.GetMBBSymbol(MO.getMBB()->getNumber()), Ctx));
      break;
#endif
    case MachineOperand::MO_GlobalAddress:
      MCOp = LowerSymbolOperand(MO, GetGlobalAddressSymbol(MO));
      break;
#if 0
    case MachineOperand::MO_ExternalSymbol:
      MCOp = LowerSymbolOperand(MO, GetExternalSymbolSymbol(MO));
      break;
#endif
    case MachineOperand::MO_JumpTableIndex:
      MCOp = LowerSymbolOperand(MO, GetJumpTableSymbol(MO));
      break;
    case MachineOperand::MO_ConstantPoolIndex:
      MCOp = LowerSymbolOperand(MO, GetConstantPoolIndexSymbol(MO));
      break;
    }
    
    OutMI.addOperand(MCOp);
  }
  
}
