//===-- llvm/Target/X86/X86TargetObjectFile.cpp - X86 Object Info ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "X86TargetObjectFile.h"
#include "X86MCTargetExpr.h"
#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/MC/MCContext.h"
#include "llvm/Target/Mangler.h"
#include "llvm/ADT/SmallString.h"
using namespace llvm;

const MCExpr *X8632_MachoTargetObjectFile::
getSymbolForDwarfGlobalReference(const GlobalValue *GV, Mangler *Mang,
                                 MachineModuleInfo *MMI,
                                 bool &IsIndirect, bool &IsPCRel) const {
  // The mach-o version of this method defaults to returning a stub reference.
  IsIndirect = true;
  IsPCRel    = false;
  
  
  MachineModuleInfoMachO &MachOMMI =
  MMI->getObjFileInfo<MachineModuleInfoMachO>();
  
  // FIXME: Use GetSymbolWithGlobalValueBase.
  SmallString<128> Name;
  Mang->getNameWithPrefix(Name, GV, true);
  Name += "$non_lazy_ptr";
  
  // Add information about the stub reference to MachOMMI so that the stub gets
  // emitted by the asmprinter.
  MCSymbol *Sym = getContext().GetOrCreateSymbol(Name.str());
  MCSymbol *&StubSym = MachOMMI.getGVStubEntry(Sym);
  if (StubSym == 0) {
    Name.clear();
    Mang->getNameWithPrefix(Name, GV, false);
    StubSym = getContext().GetOrCreateSymbol(Name.str());
  }
  
  return MCSymbolRefExpr::Create(Sym, getContext());
}

const MCExpr *X8664_MachoTargetObjectFile::
getSymbolForDwarfGlobalReference(const GlobalValue *GV, Mangler *Mang,
                                 MachineModuleInfo *MMI,
                                 bool &IsIndirect, bool &IsPCRel) const {
  
  // On Darwin/X86-64, we can reference dwarf symbols with foo@GOTPCREL+4, which
  // is an indirect pc-relative reference.
  IsIndirect = true;
  IsPCRel    = true;
  
  // FIXME: Use GetSymbolWithGlobalValueBase.
  SmallString<128> Name;
  Mang->getNameWithPrefix(Name, GV, false);
  const MCSymbol *Sym = getContext().CreateSymbol(Name);
  const MCExpr *Res =
    X86MCTargetExpr::Create(Sym, X86MCTargetExpr::GOTPCREL, getContext());
  const MCExpr *Four = MCConstantExpr::Create(4, getContext());
  return MCBinaryExpr::CreateAdd(Res, Four, getContext());
}

