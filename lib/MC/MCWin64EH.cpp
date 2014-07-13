//===- lib/MC/MCWin64EH.cpp - MCWin64EH implementation --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCWin64EH.h"
#include "llvm/ADT/Twine.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCSectionCOFF.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"

namespace llvm {

// NOTE: All relocations generated here are 4-byte image-relative.

static uint8_t CountOfUnwindCodes(std::vector<MCWin64EHInstruction> &Insns) {
  uint8_t Count = 0;
  for (const auto &I : Insns) {
    switch (I.Operation) {
    case Win64EH::UOP_PushNonVol:
    case Win64EH::UOP_AllocSmall:
    case Win64EH::UOP_SetFPReg:
    case Win64EH::UOP_PushMachFrame:
      Count += 1;
      break;
    case Win64EH::UOP_SaveNonVol:
    case Win64EH::UOP_SaveXMM128:
      Count += 2;
      break;
    case Win64EH::UOP_SaveNonVolBig:
    case Win64EH::UOP_SaveXMM128Big:
      Count += 3;
      break;
    case Win64EH::UOP_AllocLarge:
      Count += (I.Offset > 512 * 1024 - 8) ? 3 : 2;
      break;
    }
  }
  return Count;
}

static void EmitAbsDifference(MCStreamer &Streamer, const MCSymbol *LHS,
                              const MCSymbol *RHS) {
  MCContext &Context = Streamer.getContext();
  const MCExpr *Diff =
      MCBinaryExpr::CreateSub(MCSymbolRefExpr::Create(LHS, Context),
                              MCSymbolRefExpr::Create(RHS, Context), Context);
  Streamer.EmitAbsValue(Diff, 1);
}

static void EmitUnwindCode(MCStreamer &streamer, MCSymbol *begin,
                           MCWin64EHInstruction &inst) {
  uint8_t b2;
  uint16_t w;
  b2 = (inst.Operation & 0x0F);
  switch (inst.Operation) {
  case Win64EH::UOP_PushNonVol:
    EmitAbsDifference(streamer, inst.Label, begin);
    b2 |= (inst.Register & 0x0F) << 4;
    streamer.EmitIntValue(b2, 1);
    break;
  case Win64EH::UOP_AllocLarge:
    EmitAbsDifference(streamer, inst.Label, begin);
    if (inst.Offset > 512 * 1024 - 8) {
      b2 |= 0x10;
      streamer.EmitIntValue(b2, 1);
      w = inst.Offset & 0xFFF8;
      streamer.EmitIntValue(w, 2);
      w = inst.Offset >> 16;
    } else {
      streamer.EmitIntValue(b2, 1);
      w = inst.Offset >> 3;
    }
    streamer.EmitIntValue(w, 2);
    break;
  case Win64EH::UOP_AllocSmall:
    b2 |= (((inst.Offset - 8) >> 3) & 0x0F) << 4;
    EmitAbsDifference(streamer, inst.Label, begin);
    streamer.EmitIntValue(b2, 1);
    break;
  case Win64EH::UOP_SetFPReg:
    EmitAbsDifference(streamer, inst.Label, begin);
    streamer.EmitIntValue(b2, 1);
    break;
  case Win64EH::UOP_SaveNonVol:
  case Win64EH::UOP_SaveXMM128:
    b2 |= (inst.Register & 0x0F) << 4;
    EmitAbsDifference(streamer, inst.Label, begin);
    streamer.EmitIntValue(b2, 1);
    w = inst.Offset >> 3;
    if (inst.Operation == Win64EH::UOP_SaveXMM128)
      w >>= 1;
    streamer.EmitIntValue(w, 2);
    break;
  case Win64EH::UOP_SaveNonVolBig:
  case Win64EH::UOP_SaveXMM128Big:
    b2 |= (inst.Register & 0x0F) << 4;
    EmitAbsDifference(streamer, inst.Label, begin);
    streamer.EmitIntValue(b2, 1);
    if (inst.Operation == Win64EH::UOP_SaveXMM128Big)
      w = inst.Offset & 0xFFF0;
    else
      w = inst.Offset & 0xFFF8;
    streamer.EmitIntValue(w, 2);
    w = inst.Offset >> 16;
    streamer.EmitIntValue(w, 2);
    break;
  case Win64EH::UOP_PushMachFrame:
    if (inst.Offset == 1)
      b2 |= 0x10;
    EmitAbsDifference(streamer, inst.Label, begin);
    streamer.EmitIntValue(b2, 1);
    break;
  }
}

static void EmitSymbolRefWithOfs(MCStreamer &streamer,
                                 const MCSymbol *Base,
                                 const MCSymbol *Other) {
  MCContext &Context = streamer.getContext();
  const MCSymbolRefExpr *BaseRef = MCSymbolRefExpr::Create(Base, Context);
  const MCSymbolRefExpr *OtherRef = MCSymbolRefExpr::Create(Other, Context);
  const MCExpr *Ofs = MCBinaryExpr::CreateSub(OtherRef, BaseRef, Context);
  const MCSymbolRefExpr *BaseRefRel = MCSymbolRefExpr::Create(Base,
                                              MCSymbolRefExpr::VK_COFF_IMGREL32,
                                              Context);
  streamer.EmitValue(MCBinaryExpr::CreateAdd(BaseRefRel, Ofs, Context), 4);
}

static void EmitRuntimeFunction(MCStreamer &streamer,
                                const MCWinFrameInfo *info) {
  MCContext &context = streamer.getContext();

  streamer.EmitValueToAlignment(4);
  EmitSymbolRefWithOfs(streamer, info->Function, info->Begin);
  EmitSymbolRefWithOfs(streamer, info->Function, info->End);
  streamer.EmitValue(MCSymbolRefExpr::Create(info->Symbol,
                                             MCSymbolRefExpr::VK_COFF_IMGREL32,
                                             context), 4);
}

static void EmitUnwindInfo(MCStreamer &streamer, MCWinFrameInfo *info) {
  // If this UNWIND_INFO already has a symbol, it's already been emitted.
  if (info->Symbol) return;

  MCContext &context = streamer.getContext();
  streamer.EmitValueToAlignment(4);
  info->Symbol = context.CreateTempSymbol();
  streamer.EmitLabel(info->Symbol);

  // Upper 3 bits are the version number (currently 1).
  uint8_t flags = 0x01;
  if (info->ChainedParent)
    flags |= Win64EH::UNW_ChainInfo << 3;
  else {
    if (info->HandlesUnwind)
      flags |= Win64EH::UNW_TerminateHandler << 3;
    if (info->HandlesExceptions)
      flags |= Win64EH::UNW_ExceptionHandler << 3;
  }
  streamer.EmitIntValue(flags, 1);

  if (info->PrologEnd)
    EmitAbsDifference(streamer, info->PrologEnd, info->Begin);
  else
    streamer.EmitIntValue(0, 1);

  uint8_t numCodes = CountOfUnwindCodes(info->Instructions);
  streamer.EmitIntValue(numCodes, 1);

  uint8_t frame = 0;
  if (info->LastFrameInst >= 0) {
    MCWin64EHInstruction &frameInst = info->Instructions[info->LastFrameInst];
    assert(frameInst.Operation == Win64EH::UOP_SetFPReg);
    frame = (frameInst.Register & 0x0F) | (frameInst.Offset & 0xF0);
  }
  streamer.EmitIntValue(frame, 1);

  // Emit unwind instructions (in reverse order).
  uint8_t numInst = info->Instructions.size();
  for (uint8_t c = 0; c < numInst; ++c) {
    MCWin64EHInstruction inst = info->Instructions.back();
    info->Instructions.pop_back();
    EmitUnwindCode(streamer, info->Begin, inst);
  }

  // For alignment purposes, the instruction array will always have an even
  // number of entries, with the final entry potentially unused (in which case
  // the array will be one longer than indicated by the count of unwind codes
  // field).
  if (numCodes & 1) {
    streamer.EmitIntValue(0, 2);
  }

  if (flags & (Win64EH::UNW_ChainInfo << 3))
    EmitRuntimeFunction(streamer, info->ChainedParent);
  else if (flags &
           ((Win64EH::UNW_TerminateHandler|Win64EH::UNW_ExceptionHandler) << 3))
    streamer.EmitValue(MCSymbolRefExpr::Create(info->ExceptionHandler,
                                              MCSymbolRefExpr::VK_COFF_IMGREL32,
                                              context), 4);
  else if (numCodes == 0) {
    // The minimum size of an UNWIND_INFO struct is 8 bytes. If we're not
    // a chained unwind info, if there is no handler, and if there are fewer
    // than 2 slots used in the unwind code array, we have to pad to 8 bytes.
    streamer.EmitIntValue(0, 4);
  }
}

StringRef MCWin64EHUnwindEmitter::GetSectionSuffix(const MCSymbol *func) {
  if (!func || !func->isInSection()) return "";
  const MCSection *section = &func->getSection();
  const MCSectionCOFF *COFFSection;
  if ((COFFSection = dyn_cast<MCSectionCOFF>(section))) {
    StringRef name = COFFSection->getSectionName();
    size_t dollar = name.find('$');
    size_t dot = name.find('.', 1);
    if (dollar == StringRef::npos && dot == StringRef::npos)
      return "";
    if (dot == StringRef::npos)
      return name.substr(dollar);
    if (dollar == StringRef::npos || dot < dollar)
      return name.substr(dot);
    return name.substr(dollar);
  }
  return "";
}

static const MCSection *getWin64EHTableSection(StringRef suffix,
                                               MCContext &context) {
  if (suffix == "")
    return context.getObjectFileInfo()->getXDataSection();

  return context.getCOFFSection((".xdata"+suffix).str(),
                                COFF::IMAGE_SCN_CNT_INITIALIZED_DATA |
                                COFF::IMAGE_SCN_MEM_READ,
                                SectionKind::getDataRel());
}

static const MCSection *getWin64EHFuncTableSection(StringRef suffix,
                                                   MCContext &context) {
  if (suffix == "")
    return context.getObjectFileInfo()->getPDataSection();
  return context.getCOFFSection((".pdata"+suffix).str(),
                                COFF::IMAGE_SCN_CNT_INITIALIZED_DATA |
                                COFF::IMAGE_SCN_MEM_READ,
                                SectionKind::getDataRel());
}

void MCWin64EHUnwindEmitter::EmitUnwindInfo(MCStreamer &streamer,
                                            MCWinFrameInfo *info) {
  // Switch sections (the static function above is meant to be called from
  // here and from Emit().
  MCContext &context = streamer.getContext();
  const MCSection *xdataSect =
    getWin64EHTableSection(GetSectionSuffix(info->Function), context);
  streamer.SwitchSection(xdataSect);

  llvm::EmitUnwindInfo(streamer, info);
}

void MCWin64EHUnwindEmitter::Emit(MCStreamer &Streamer) {
  MCContext &Context = Streamer.getContext();

  // Emit the unwind info structs first.
  for (const auto &CFI : Streamer.getWinFrameInfos()) {
    const MCSection *XData =
        getWin64EHTableSection(GetSectionSuffix(CFI->Function), Context);
    Streamer.SwitchSection(XData);
    EmitUnwindInfo(Streamer, CFI);
  }

  // Now emit RUNTIME_FUNCTION entries.
  for (const auto &CFI : Streamer.getWinFrameInfos()) {
    const MCSection *PData =
        getWin64EHFuncTableSection(GetSectionSuffix(CFI->Function), Context);
    Streamer.SwitchSection(PData);
    EmitRuntimeFunction(Streamer, CFI);
  }
}

} // End of namespace llvm

