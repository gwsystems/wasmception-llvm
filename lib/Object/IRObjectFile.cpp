//===- IRObjectFile.cpp - IR object file implementation ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Part of the IRObjectFile class implementation.
//
//===----------------------------------------------------------------------===//

#include "llvm/Object/IRObjectFile.h"
#include "RecordStreamer.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/IR/GVMaterializer.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCParser/MCAsmParser.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;
using namespace object;

IRObjectFile::IRObjectFile(MemoryBufferRef Object, std::unique_ptr<Module> Mod)
    : SymbolicFile(Binary::ID_IR, Object), M(std::move(Mod)) {
  Mang.reset(new Mangler());

  for (Function &F : *M)
    SymTab.push_back(&F);
  for (GlobalVariable &GV : M->globals())
    SymTab.push_back(&GV);
  for (GlobalAlias &GA : M->aliases())
    SymTab.push_back(&GA);

  CollectAsmUndefinedRefs(Triple(M->getTargetTriple()), M->getModuleInlineAsm(),
                          [this](StringRef Name, BasicSymbolRef::Flags Flags) {
                            SymTab.push_back(new (AsmSymbols.Allocate())
                                                 AsmSymbol(Name, Flags));
                          });
}

// Parse inline ASM and collect the list of symbols that are not defined in
// the current module. This is inspired from IRObjectFile.
void IRObjectFile::CollectAsmUndefinedRefs(
    const Triple &TT, StringRef InlineAsm,
    function_ref<void(StringRef, BasicSymbolRef::Flags)> AsmUndefinedRefs) {
  if (InlineAsm.empty())
    return;

  std::string Err;
  const Target *T = TargetRegistry::lookupTarget(TT.str(), Err);
  assert(T && T->hasMCAsmParser());

  std::unique_ptr<MCRegisterInfo> MRI(T->createMCRegInfo(TT.str()));
  if (!MRI)
    return;

  std::unique_ptr<MCAsmInfo> MAI(T->createMCAsmInfo(*MRI, TT.str()));
  if (!MAI)
    return;

  std::unique_ptr<MCSubtargetInfo> STI(
      T->createMCSubtargetInfo(TT.str(), "", ""));
  if (!STI)
    return;

  std::unique_ptr<MCInstrInfo> MCII(T->createMCInstrInfo());
  if (!MCII)
    return;

  MCObjectFileInfo MOFI;
  MCContext MCCtx(MAI.get(), MRI.get(), &MOFI);
  MOFI.InitMCObjectFileInfo(TT, /*PIC*/ false, CodeModel::Default, MCCtx);
  RecordStreamer Streamer(MCCtx);
  T->createNullTargetStreamer(Streamer);

  std::unique_ptr<MemoryBuffer> Buffer(MemoryBuffer::getMemBuffer(InlineAsm));
  SourceMgr SrcMgr;
  SrcMgr.AddNewSourceBuffer(std::move(Buffer), SMLoc());
  std::unique_ptr<MCAsmParser> Parser(
      createMCAsmParser(SrcMgr, MCCtx, Streamer, *MAI));

  MCTargetOptions MCOptions;
  std::unique_ptr<MCTargetAsmParser> TAP(
      T->createMCAsmParser(*STI, *Parser, *MCII, MCOptions));
  if (!TAP)
    return;

  Parser->setTargetParser(*TAP);
  if (Parser->Run(false))
    return;

  for (auto &KV : Streamer) {
    StringRef Key = KV.first();
    RecordStreamer::State Value = KV.second;
    uint32_t Res = BasicSymbolRef::SF_None;
    switch (Value) {
    case RecordStreamer::NeverSeen:
      llvm_unreachable("NeverSeen should have been replaced earlier");
    case RecordStreamer::DefinedGlobal:
      Res |= BasicSymbolRef::SF_Global;
      break;
    case RecordStreamer::Defined:
      break;
    case RecordStreamer::Global:
    case RecordStreamer::Used:
      Res |= BasicSymbolRef::SF_Undefined;
      Res |= BasicSymbolRef::SF_Global;
      break;
    case RecordStreamer::DefinedWeak:
      Res |= BasicSymbolRef::SF_Weak;
      Res |= BasicSymbolRef::SF_Global;
      break;
    case RecordStreamer::UndefinedWeak:
      Res |= BasicSymbolRef::SF_Weak;
      Res |= BasicSymbolRef::SF_Undefined;
    }
    AsmUndefinedRefs(Key, BasicSymbolRef::Flags(Res));
  }
}

IRObjectFile::~IRObjectFile() {}

void IRObjectFile::moveSymbolNext(DataRefImpl &Symb) const {
  Symb.p += sizeof(Sym);
}

std::error_code IRObjectFile::printSymbolName(raw_ostream &OS,
                                              DataRefImpl Symb) const {
  Sym S = getSym(Symb);
  if (S.is<AsmSymbol *>()) {
    OS << S.get<AsmSymbol *>()->first;
    return std::error_code();
  }

  auto *GV = S.get<GlobalValue *>();
  if (GV->hasDLLImportStorageClass())
    OS << "__imp_";

  if (Mang)
    Mang->getNameWithPrefix(OS, GV, false);
  else
    OS << GV->getName();

  return std::error_code();
}

uint32_t IRObjectFile::getSymbolFlags(DataRefImpl Symb) const {
  Sym S = getSym(Symb);
  if (S.is<AsmSymbol *>())
    return S.get<AsmSymbol *>()->second;

  auto *GV = S.get<GlobalValue *>();

  uint32_t Res = BasicSymbolRef::SF_None;
  if (GV->isDeclarationForLinker())
    Res |= BasicSymbolRef::SF_Undefined;
  else if (GV->hasHiddenVisibility() && !GV->hasLocalLinkage())
    Res |= BasicSymbolRef::SF_Hidden;
  if (const GlobalVariable *GVar = dyn_cast<GlobalVariable>(GV)) {
    if (GVar->isConstant())
      Res |= BasicSymbolRef::SF_Const;
  }
  if (GV->hasPrivateLinkage())
    Res |= BasicSymbolRef::SF_FormatSpecific;
  if (!GV->hasLocalLinkage())
    Res |= BasicSymbolRef::SF_Global;
  if (GV->hasCommonLinkage())
    Res |= BasicSymbolRef::SF_Common;
  if (GV->hasLinkOnceLinkage() || GV->hasWeakLinkage() ||
      GV->hasExternalWeakLinkage())
    Res |= BasicSymbolRef::SF_Weak;

  if (GV->getName().startswith("llvm."))
    Res |= BasicSymbolRef::SF_FormatSpecific;
  else if (auto *Var = dyn_cast<GlobalVariable>(GV)) {
    if (Var->getSection() == "llvm.metadata")
      Res |= BasicSymbolRef::SF_FormatSpecific;
  }

  return Res;
}

GlobalValue *IRObjectFile::getSymbolGV(DataRefImpl Symb) {
  return getSym(Symb).dyn_cast<GlobalValue *>();
}

std::unique_ptr<Module> IRObjectFile::takeModule() { return std::move(M); }

basic_symbol_iterator IRObjectFile::symbol_begin() const {
  DataRefImpl Ret;
  Ret.p = reinterpret_cast<uintptr_t>(SymTab.data());
  return basic_symbol_iterator(BasicSymbolRef(Ret, this));
}

basic_symbol_iterator IRObjectFile::symbol_end() const {
  DataRefImpl Ret;
  Ret.p = reinterpret_cast<uintptr_t>(SymTab.data() + SymTab.size());
  return basic_symbol_iterator(BasicSymbolRef(Ret, this));
}

StringRef IRObjectFile::getTargetTriple() const { return M->getTargetTriple(); }

ErrorOr<MemoryBufferRef> IRObjectFile::findBitcodeInObject(const ObjectFile &Obj) {
  for (const SectionRef &Sec : Obj.sections()) {
    if (Sec.isBitcode()) {
      StringRef SecContents;
      if (std::error_code EC = Sec.getContents(SecContents))
        return EC;
      return MemoryBufferRef(SecContents, Obj.getFileName());
    }
  }

  return object_error::bitcode_section_not_found;
}

ErrorOr<MemoryBufferRef> IRObjectFile::findBitcodeInMemBuffer(MemoryBufferRef Object) {
  sys::fs::file_magic Type = sys::fs::identify_magic(Object.getBuffer());
  switch (Type) {
  case sys::fs::file_magic::bitcode:
    return Object;
  case sys::fs::file_magic::elf_relocatable:
  case sys::fs::file_magic::macho_object:
  case sys::fs::file_magic::coff_object: {
    Expected<std::unique_ptr<ObjectFile>> ObjFile =
        ObjectFile::createObjectFile(Object, Type);
    if (!ObjFile)
      return errorToErrorCode(ObjFile.takeError());
    return findBitcodeInObject(*ObjFile->get());
  }
  default:
    return object_error::invalid_file_type;
  }
}

Expected<std::unique_ptr<IRObjectFile>>
llvm::object::IRObjectFile::create(MemoryBufferRef Object,
                                   LLVMContext &Context) {
  ErrorOr<MemoryBufferRef> BCOrErr = findBitcodeInMemBuffer(Object);
  if (!BCOrErr)
    return errorCodeToError(BCOrErr.getError());

  Expected<std::unique_ptr<Module>> MOrErr =
      getLazyBitcodeModule(*BCOrErr, Context,
                           /*ShouldLazyLoadMetadata*/ true);
  if (!MOrErr)
    return MOrErr.takeError();

  std::unique_ptr<Module> &M = MOrErr.get();
  return llvm::make_unique<IRObjectFile>(BCOrErr.get(), std::move(M));
}
