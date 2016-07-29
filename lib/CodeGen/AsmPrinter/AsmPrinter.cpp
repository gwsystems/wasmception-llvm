//===-- AsmPrinter.cpp - Common AsmPrinter code ---------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the AsmPrinter class.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/AsmPrinter.h"
#include "CodeViewDebug.h"
#include "DwarfDebug.h"
#include "DwarfException.h"
#include "WinException.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/CodeGen/Analysis.h"
#include "llvm/CodeGen/GCMetadataPrinter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Operator.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Timer.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Target/TargetSubtargetInfo.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

static const char *const DWARFGroupName = "DWARF Emission";
static const char *const DbgTimerName = "Debug Info Emission";
static const char *const EHTimerName = "DWARF Exception Writer";
static const char *const CodeViewLineTablesGroupName = "CodeView Line Tables";

STATISTIC(EmittedInsts, "Number of machine instrs printed");

char AsmPrinter::ID = 0;

typedef DenseMap<GCStrategy*, std::unique_ptr<GCMetadataPrinter>> gcp_map_type;
static gcp_map_type &getGCMap(void *&P) {
  if (!P)
    P = new gcp_map_type();
  return *(gcp_map_type*)P;
}


/// getGVAlignmentLog2 - Return the alignment to use for the specified global
/// value in log2 form.  This rounds up to the preferred alignment if possible
/// and legal.
static unsigned getGVAlignmentLog2(const GlobalValue *GV, const DataLayout &DL,
                                   unsigned InBits = 0) {
  unsigned NumBits = 0;
  if (const GlobalVariable *GVar = dyn_cast<GlobalVariable>(GV))
    NumBits = DL.getPreferredAlignmentLog(GVar);

  // If InBits is specified, round it to it.
  if (InBits > NumBits)
    NumBits = InBits;

  // If the GV has a specified alignment, take it into account.
  if (GV->getAlignment() == 0)
    return NumBits;

  unsigned GVAlign = Log2_32(GV->getAlignment());

  // If the GVAlign is larger than NumBits, or if we are required to obey
  // NumBits because the GV has an assigned section, obey it.
  if (GVAlign > NumBits || GV->hasSection())
    NumBits = GVAlign;
  return NumBits;
}

AsmPrinter::AsmPrinter(TargetMachine &tm, std::unique_ptr<MCStreamer> Streamer)
    : MachineFunctionPass(ID), TM(tm), MAI(tm.getMCAsmInfo()),
      OutContext(Streamer->getContext()), OutStreamer(std::move(Streamer)),
      LastMI(nullptr), LastFn(0), Counter(~0U) {
  DD = nullptr;
  MMI = nullptr;
  LI = nullptr;
  MF = nullptr;
  CurExceptionSym = CurrentFnSym = CurrentFnSymForSize = nullptr;
  CurrentFnBegin = nullptr;
  CurrentFnEnd = nullptr;
  GCMetadataPrinters = nullptr;
  VerboseAsm = OutStreamer->isVerboseAsm();
}

AsmPrinter::~AsmPrinter() {
  assert(!DD && Handlers.empty() && "Debug/EH info didn't get finalized");

  if (GCMetadataPrinters) {
    gcp_map_type &GCMap = getGCMap(GCMetadataPrinters);

    delete &GCMap;
    GCMetadataPrinters = nullptr;
  }
}

bool AsmPrinter::isPositionIndependent() const {
  return TM.isPositionIndependent();
}

/// getFunctionNumber - Return a unique ID for the current function.
///
unsigned AsmPrinter::getFunctionNumber() const {
  return MF->getFunctionNumber();
}

const TargetLoweringObjectFile &AsmPrinter::getObjFileLowering() const {
  return *TM.getObjFileLowering();
}

const DataLayout &AsmPrinter::getDataLayout() const {
  return MMI->getModule()->getDataLayout();
}

// Do not use the cached DataLayout because some client use it without a Module
// (llmv-dsymutil, llvm-dwarfdump).
unsigned AsmPrinter::getPointerSize() const { return TM.getPointerSize(); }

const MCSubtargetInfo &AsmPrinter::getSubtargetInfo() const {
  assert(MF && "getSubtargetInfo requires a valid MachineFunction!");
  return MF->getSubtarget<MCSubtargetInfo>();
}

void AsmPrinter::EmitToStreamer(MCStreamer &S, const MCInst &Inst) {
  S.EmitInstruction(Inst, getSubtargetInfo());
}

StringRef AsmPrinter::getTargetTriple() const {
  return TM.getTargetTriple().str();
}

/// getCurrentSection() - Return the current section we are emitting to.
const MCSection *AsmPrinter::getCurrentSection() const {
  return OutStreamer->getCurrentSection().first;
}



void AsmPrinter::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  MachineFunctionPass::getAnalysisUsage(AU);
  AU.addRequired<MachineModuleInfo>();
  AU.addRequired<GCModuleInfo>();
  if (isVerbose())
    AU.addRequired<MachineLoopInfo>();
}

bool AsmPrinter::doInitialization(Module &M) {
  MMI = getAnalysisIfAvailable<MachineModuleInfo>();

  // Initialize TargetLoweringObjectFile.
  const_cast<TargetLoweringObjectFile&>(getObjFileLowering())
    .Initialize(OutContext, TM);

  OutStreamer->InitSections(false);

  Mang = new Mangler();

  // Emit the version-min deplyment target directive if needed.
  //
  // FIXME: If we end up with a collection of these sorts of Darwin-specific
  // or ELF-specific things, it may make sense to have a platform helper class
  // that will work with the target helper class. For now keep it here, as the
  // alternative is duplicated code in each of the target asm printers that
  // use the directive, where it would need the same conditionalization
  // anyway.
  Triple TT(getTargetTriple());
  // If there is a version specified, Major will be non-zero.
  if (TT.isOSDarwin() && TT.getOSMajorVersion() != 0) {
    unsigned Major, Minor, Update;
    MCVersionMinType VersionType;
    if (TT.isWatchOS()) {
      VersionType = MCVM_WatchOSVersionMin;
      TT.getWatchOSVersion(Major, Minor, Update);
    } else if (TT.isTvOS()) {
      VersionType = MCVM_TvOSVersionMin;
      TT.getiOSVersion(Major, Minor, Update);
    } else if (TT.isMacOSX()) {
      VersionType = MCVM_OSXVersionMin;
      if (!TT.getMacOSXVersion(Major, Minor, Update))
        Major = 0;
    } else {
      VersionType = MCVM_IOSVersionMin;
      TT.getiOSVersion(Major, Minor, Update);
    }
    if (Major != 0)
      OutStreamer->EmitVersionMin(VersionType, Major, Minor, Update);
  }

  // Allow the target to emit any magic that it wants at the start of the file.
  EmitStartOfAsmFile(M);

  // Very minimal debug info. It is ignored if we emit actual debug info. If we
  // don't, this at least helps the user find where a global came from.
  if (MAI->hasSingleParameterDotFile()) {
    // .file "foo.c"
    OutStreamer->EmitFileDirective(M.getModuleIdentifier());
  }

  GCModuleInfo *MI = getAnalysisIfAvailable<GCModuleInfo>();
  assert(MI && "AsmPrinter didn't require GCModuleInfo?");
  for (auto &I : *MI)
    if (GCMetadataPrinter *MP = GetOrCreateGCPrinter(*I))
      MP->beginAssembly(M, *MI, *this);

  // Emit module-level inline asm if it exists.
  if (!M.getModuleInlineAsm().empty()) {
    // We're at the module level. Construct MCSubtarget from the default CPU
    // and target triple.
    std::unique_ptr<MCSubtargetInfo> STI(TM.getTarget().createMCSubtargetInfo(
        TM.getTargetTriple().str(), TM.getTargetCPU(),
        TM.getTargetFeatureString()));
    OutStreamer->AddComment("Start of file scope inline assembly");
    OutStreamer->AddBlankLine();
    EmitInlineAsm(M.getModuleInlineAsm()+"\n",
                  OutContext.getSubtargetCopy(*STI), TM.Options.MCOptions);
    OutStreamer->AddComment("End of file scope inline assembly");
    OutStreamer->AddBlankLine();
  }

  if (MAI->doesSupportDebugInformation()) {
    bool EmitCodeView = MMI->getModule()->getCodeViewFlag();
    if (EmitCodeView && TM.getTargetTriple().isKnownWindowsMSVCEnvironment()) {
      Handlers.push_back(HandlerInfo(new CodeViewDebug(this),
                                     DbgTimerName,
                                     CodeViewLineTablesGroupName));
    }
    if (!EmitCodeView || MMI->getModule()->getDwarfVersion()) {
      DD = new DwarfDebug(this, &M);
      DD->beginModule();
      Handlers.push_back(HandlerInfo(DD, DbgTimerName, DWARFGroupName));
    }
  }

  EHStreamer *ES = nullptr;
  switch (MAI->getExceptionHandlingType()) {
  case ExceptionHandling::None:
    break;
  case ExceptionHandling::SjLj:
  case ExceptionHandling::DwarfCFI:
    ES = new DwarfCFIException(this);
    break;
  case ExceptionHandling::ARM:
    ES = new ARMException(this);
    break;
  case ExceptionHandling::WinEH:
    switch (MAI->getWinEHEncodingType()) {
    default: llvm_unreachable("unsupported unwinding information encoding");
    case WinEH::EncodingType::Invalid:
      break;
    case WinEH::EncodingType::X86:
    case WinEH::EncodingType::Itanium:
      ES = new WinException(this);
      break;
    }
    break;
  }
  if (ES)
    Handlers.push_back(HandlerInfo(ES, EHTimerName, DWARFGroupName));
  return false;
}

static bool canBeHidden(const GlobalValue *GV, const MCAsmInfo &MAI) {
  if (!MAI.hasWeakDefCanBeHiddenDirective())
    return false;

  return canBeOmittedFromSymbolTable(GV);
}

void AsmPrinter::EmitLinkage(const GlobalValue *GV, MCSymbol *GVSym) const {
  GlobalValue::LinkageTypes Linkage = GV->getLinkage();
  switch (Linkage) {
  case GlobalValue::CommonLinkage:
  case GlobalValue::LinkOnceAnyLinkage:
  case GlobalValue::LinkOnceODRLinkage:
  case GlobalValue::WeakAnyLinkage:
  case GlobalValue::WeakODRLinkage:
    if (MAI->hasWeakDefDirective()) {
      // .globl _foo
      OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Global);

      if (!canBeHidden(GV, *MAI))
        // .weak_definition _foo
        OutStreamer->EmitSymbolAttribute(GVSym, MCSA_WeakDefinition);
      else
        OutStreamer->EmitSymbolAttribute(GVSym, MCSA_WeakDefAutoPrivate);
    } else if (MAI->hasLinkOnceDirective()) {
      // .globl _foo
      OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Global);
      //NOTE: linkonce is handled by the section the symbol was assigned to.
    } else {
      // .weak _foo
      OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Weak);
    }
    return;
  case GlobalValue::ExternalLinkage:
    // If external, declare as a global symbol: .globl _foo
    OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Global);
    return;
  case GlobalValue::PrivateLinkage:
  case GlobalValue::InternalLinkage:
    return;
  case GlobalValue::AppendingLinkage:
  case GlobalValue::AvailableExternallyLinkage:
  case GlobalValue::ExternalWeakLinkage:
    llvm_unreachable("Should never emit this");
  }
  llvm_unreachable("Unknown linkage type!");
}

void AsmPrinter::getNameWithPrefix(SmallVectorImpl<char> &Name,
                                   const GlobalValue *GV) const {
  TM.getNameWithPrefix(Name, GV, *Mang);
}

MCSymbol *AsmPrinter::getSymbol(const GlobalValue *GV) const {
  return TM.getSymbol(GV, *Mang);
}

/// EmitGlobalVariable - Emit the specified global variable to the .s file.
void AsmPrinter::EmitGlobalVariable(const GlobalVariable *GV) {
  bool IsEmuTLSVar = TM.Options.EmulatedTLS && GV->isThreadLocal();
  assert(!(IsEmuTLSVar && GV->hasCommonLinkage()) &&
         "No emulated TLS variables in the common section");

  // Never emit TLS variable xyz in emulated TLS model.
  // The initialization value is in __emutls_t.xyz instead of xyz.
  if (IsEmuTLSVar)
    return;

  if (GV->hasInitializer()) {
    // Check to see if this is a special global used by LLVM, if so, emit it.
    if (EmitSpecialLLVMGlobal(GV))
      return;

    // Skip the emission of global equivalents. The symbol can be emitted later
    // on by emitGlobalGOTEquivs in case it turns out to be needed.
    if (GlobalGOTEquivs.count(getSymbol(GV)))
      return;

    if (isVerbose()) {
      // When printing the control variable __emutls_v.*,
      // we don't need to print the original TLS variable name.
      GV->printAsOperand(OutStreamer->GetCommentOS(),
                     /*PrintType=*/false, GV->getParent());
      OutStreamer->GetCommentOS() << '\n';
    }
  }

  MCSymbol *GVSym = getSymbol(GV);
  MCSymbol *EmittedSym = GVSym;

  // getOrCreateEmuTLSControlSym only creates the symbol with name and default
  // attributes.
  // GV's or GVSym's attributes will be used for the EmittedSym.
  EmitVisibility(EmittedSym, GV->getVisibility(), !GV->isDeclaration());

  if (!GV->hasInitializer())   // External globals require no extra code.
    return;

  GVSym->redefineIfPossible();
  if (GVSym->isDefined() || GVSym->isVariable())
    report_fatal_error("symbol '" + Twine(GVSym->getName()) +
                       "' is already defined");

  if (MAI->hasDotTypeDotSizeDirective())
    OutStreamer->EmitSymbolAttribute(EmittedSym, MCSA_ELF_TypeObject);

  SectionKind GVKind = TargetLoweringObjectFile::getKindForGlobal(GV, TM);

  const DataLayout &DL = GV->getParent()->getDataLayout();
  uint64_t Size = DL.getTypeAllocSize(GV->getType()->getElementType());

  // If the alignment is specified, we *must* obey it.  Overaligning a global
  // with a specified alignment is a prompt way to break globals emitted to
  // sections and expected to be contiguous (e.g. ObjC metadata).
  unsigned AlignLog = getGVAlignmentLog2(GV, DL);

  for (const HandlerInfo &HI : Handlers) {
    NamedRegionTimer T(HI.TimerName, HI.TimerGroupName, TimePassesIsEnabled);
    HI.Handler->setSymbolSize(GVSym, Size);
  }

  // Handle common symbols
  if (GVKind.isCommon()) {
    if (Size == 0) Size = 1;   // .comm Foo, 0 is undefined, avoid it.
    unsigned Align = 1 << AlignLog;
    if (!getObjFileLowering().getCommDirectiveSupportsAlignment())
      Align = 0;

    // .comm _foo, 42, 4
    OutStreamer->EmitCommonSymbol(GVSym, Size, Align);
    return;
  }

  // Determine to which section this global should be emitted.
  MCSection *TheSection =
      getObjFileLowering().SectionForGlobal(GV, GVKind, *Mang, TM);

  // If we have a bss global going to a section that supports the
  // zerofill directive, do so here.
  if (GVKind.isBSS() && MAI->hasMachoZeroFillDirective() &&
      TheSection->isVirtualSection()) {
    if (Size == 0)
      Size = 1; // zerofill of 0 bytes is undefined.
    unsigned Align = 1 << AlignLog;
    EmitLinkage(GV, GVSym);
    // .zerofill __DATA, __bss, _foo, 400, 5
    OutStreamer->EmitZerofill(TheSection, GVSym, Size, Align);
    return;
  }

  // If this is a BSS local symbol and we are emitting in the BSS
  // section use .lcomm/.comm directive.
  if (GVKind.isBSSLocal() &&
      getObjFileLowering().getBSSSection() == TheSection) {
    if (Size == 0)
      Size = 1; // .comm Foo, 0 is undefined, avoid it.
    unsigned Align = 1 << AlignLog;

    // Use .lcomm only if it supports user-specified alignment.
    // Otherwise, while it would still be correct to use .lcomm in some
    // cases (e.g. when Align == 1), the external assembler might enfore
    // some -unknown- default alignment behavior, which could cause
    // spurious differences between external and integrated assembler.
    // Prefer to simply fall back to .local / .comm in this case.
    if (MAI->getLCOMMDirectiveAlignmentType() != LCOMM::NoAlignment) {
      // .lcomm _foo, 42
      OutStreamer->EmitLocalCommonSymbol(GVSym, Size, Align);
      return;
    }

    if (!getObjFileLowering().getCommDirectiveSupportsAlignment())
      Align = 0;

    // .local _foo
    OutStreamer->EmitSymbolAttribute(GVSym, MCSA_Local);
    // .comm _foo, 42, 4
    OutStreamer->EmitCommonSymbol(GVSym, Size, Align);
    return;
  }

  // Handle thread local data for mach-o which requires us to output an
  // additional structure of data and mangle the original symbol so that we
  // can reference it later.
  //
  // TODO: This should become an "emit thread local global" method on TLOF.
  // All of this macho specific stuff should be sunk down into TLOFMachO and
  // stuff like "TLSExtraDataSection" should no longer be part of the parent
  // TLOF class.  This will also make it more obvious that stuff like
  // MCStreamer::EmitTBSSSymbol is macho specific and only called from macho
  // specific code.
  if (GVKind.isThreadLocal() && MAI->hasMachoTBSSDirective()) {
    // Emit the .tbss symbol
    MCSymbol *MangSym =
      OutContext.getOrCreateSymbol(GVSym->getName() + Twine("$tlv$init"));

    if (GVKind.isThreadBSS()) {
      TheSection = getObjFileLowering().getTLSBSSSection();
      OutStreamer->EmitTBSSSymbol(TheSection, MangSym, Size, 1 << AlignLog);
    } else if (GVKind.isThreadData()) {
      OutStreamer->SwitchSection(TheSection);

      EmitAlignment(AlignLog, GV);
      OutStreamer->EmitLabel(MangSym);

      EmitGlobalConstant(GV->getParent()->getDataLayout(),
                         GV->getInitializer());
    }

    OutStreamer->AddBlankLine();

    // Emit the variable struct for the runtime.
    MCSection *TLVSect = getObjFileLowering().getTLSExtraDataSection();

    OutStreamer->SwitchSection(TLVSect);
    // Emit the linkage here.
    EmitLinkage(GV, GVSym);
    OutStreamer->EmitLabel(GVSym);

    // Three pointers in size:
    //   - __tlv_bootstrap - used to make sure support exists
    //   - spare pointer, used when mapped by the runtime
    //   - pointer to mangled symbol above with initializer
    unsigned PtrSize = DL.getPointerTypeSize(GV->getType());
    OutStreamer->EmitSymbolValue(GetExternalSymbolSymbol("_tlv_bootstrap"),
                                PtrSize);
    OutStreamer->EmitIntValue(0, PtrSize);
    OutStreamer->EmitSymbolValue(MangSym, PtrSize);

    OutStreamer->AddBlankLine();
    return;
  }

  MCSymbol *EmittedInitSym = GVSym;

  OutStreamer->SwitchSection(TheSection);

  EmitLinkage(GV, EmittedInitSym);
  EmitAlignment(AlignLog, GV);

  OutStreamer->EmitLabel(EmittedInitSym);

  EmitGlobalConstant(GV->getParent()->getDataLayout(), GV->getInitializer());

  if (MAI->hasDotTypeDotSizeDirective())
    // .size foo, 42
    OutStreamer->emitELFSize(cast<MCSymbolELF>(EmittedInitSym),
                             MCConstantExpr::create(Size, OutContext));

  OutStreamer->AddBlankLine();
}

/// EmitFunctionHeader - This method emits the header for the current
/// function.
void AsmPrinter::EmitFunctionHeader() {
  // Print out constants referenced by the function
  EmitConstantPool();

  // Print the 'header' of function.
  const Function *F = MF->getFunction();

  OutStreamer->SwitchSection(
      getObjFileLowering().SectionForGlobal(F, *Mang, TM));
  EmitVisibility(CurrentFnSym, F->getVisibility());

  EmitLinkage(F, CurrentFnSym);
  if (MAI->hasFunctionAlignment())
    EmitAlignment(MF->getAlignment(), F);

  if (MAI->hasDotTypeDotSizeDirective())
    OutStreamer->EmitSymbolAttribute(CurrentFnSym, MCSA_ELF_TypeFunction);

  if (isVerbose()) {
    F->printAsOperand(OutStreamer->GetCommentOS(),
                   /*PrintType=*/false, F->getParent());
    OutStreamer->GetCommentOS() << '\n';
  }

  // Emit the prefix data.
  if (F->hasPrefixData())
    EmitGlobalConstant(F->getParent()->getDataLayout(), F->getPrefixData());

  // Emit the CurrentFnSym.  This is a virtual function to allow targets to
  // do their wild and crazy things as required.
  EmitFunctionEntryLabel();

  // If the function had address-taken blocks that got deleted, then we have
  // references to the dangling symbols.  Emit them at the start of the function
  // so that we don't get references to undefined symbols.
  std::vector<MCSymbol*> DeadBlockSyms;
  MMI->takeDeletedSymbolsForFunction(F, DeadBlockSyms);
  for (unsigned i = 0, e = DeadBlockSyms.size(); i != e; ++i) {
    OutStreamer->AddComment("Address taken block that was later removed");
    OutStreamer->EmitLabel(DeadBlockSyms[i]);
  }

  if (CurrentFnBegin) {
    if (MAI->useAssignmentForEHBegin()) {
      MCSymbol *CurPos = OutContext.createTempSymbol();
      OutStreamer->EmitLabel(CurPos);
      OutStreamer->EmitAssignment(CurrentFnBegin,
                                 MCSymbolRefExpr::create(CurPos, OutContext));
    } else {
      OutStreamer->EmitLabel(CurrentFnBegin);
    }
  }

  // Emit pre-function debug and/or EH information.
  for (const HandlerInfo &HI : Handlers) {
    NamedRegionTimer T(HI.TimerName, HI.TimerGroupName, TimePassesIsEnabled);
    HI.Handler->beginFunction(MF);
  }

  // Emit the prologue data.
  if (F->hasPrologueData())
    EmitGlobalConstant(F->getParent()->getDataLayout(), F->getPrologueData());
}

/// EmitFunctionEntryLabel - Emit the label that is the entrypoint for the
/// function.  This can be overridden by targets as required to do custom stuff.
void AsmPrinter::EmitFunctionEntryLabel() {
  CurrentFnSym->redefineIfPossible();

  // The function label could have already been emitted if two symbols end up
  // conflicting due to asm renaming.  Detect this and emit an error.
  if (CurrentFnSym->isVariable())
    report_fatal_error("'" + Twine(CurrentFnSym->getName()) +
                       "' is a protected alias");
  if (CurrentFnSym->isDefined())
    report_fatal_error("'" + Twine(CurrentFnSym->getName()) +
                       "' label emitted multiple times to assembly file");

  return OutStreamer->EmitLabel(CurrentFnSym);
}

/// emitComments - Pretty-print comments for instructions.
static void emitComments(const MachineInstr &MI, raw_ostream &CommentOS) {
  const MachineFunction *MF = MI.getParent()->getParent();
  const TargetInstrInfo *TII = MF->getSubtarget().getInstrInfo();

  // Check for spills and reloads
  int FI;

  const MachineFrameInfo &MFI = MF->getFrameInfo();

  // We assume a single instruction only has a spill or reload, not
  // both.
  const MachineMemOperand *MMO;
  if (TII->isLoadFromStackSlotPostFE(MI, FI)) {
    if (MFI.isSpillSlotObjectIndex(FI)) {
      MMO = *MI.memoperands_begin();
      CommentOS << MMO->getSize() << "-byte Reload\n";
    }
  } else if (TII->hasLoadFromStackSlot(MI, MMO, FI)) {
    if (MFI.isSpillSlotObjectIndex(FI))
      CommentOS << MMO->getSize() << "-byte Folded Reload\n";
  } else if (TII->isStoreToStackSlotPostFE(MI, FI)) {
    if (MFI.isSpillSlotObjectIndex(FI)) {
      MMO = *MI.memoperands_begin();
      CommentOS << MMO->getSize() << "-byte Spill\n";
    }
  } else if (TII->hasStoreToStackSlot(MI, MMO, FI)) {
    if (MFI.isSpillSlotObjectIndex(FI))
      CommentOS << MMO->getSize() << "-byte Folded Spill\n";
  }

  // Check for spill-induced copies
  if (MI.getAsmPrinterFlag(MachineInstr::ReloadReuse))
    CommentOS << " Reload Reuse\n";
}

/// emitImplicitDef - This method emits the specified machine instruction
/// that is an implicit def.
void AsmPrinter::emitImplicitDef(const MachineInstr *MI) const {
  unsigned RegNo = MI->getOperand(0).getReg();

  SmallString<128> Str;
  raw_svector_ostream OS(Str);
  OS << "implicit-def: "
     << PrintReg(RegNo, MF->getSubtarget().getRegisterInfo());

  OutStreamer->AddComment(OS.str());
  OutStreamer->AddBlankLine();
}

static void emitKill(const MachineInstr *MI, AsmPrinter &AP) {
  std::string Str;
  raw_string_ostream OS(Str);
  OS << "kill:";
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &Op = MI->getOperand(i);
    assert(Op.isReg() && "KILL instruction must have only register operands");
    OS << ' '
       << PrintReg(Op.getReg(),
                   AP.MF->getSubtarget().getRegisterInfo())
       << (Op.isDef() ? "<def>" : "<kill>");
  }
  AP.OutStreamer->AddComment(OS.str());
  AP.OutStreamer->AddBlankLine();
}

/// emitDebugValueComment - This method handles the target-independent form
/// of DBG_VALUE, returning true if it was able to do so.  A false return
/// means the target will need to handle MI in EmitInstruction.
static bool emitDebugValueComment(const MachineInstr *MI, AsmPrinter &AP) {
  // This code handles only the 4-operand target-independent form.
  if (MI->getNumOperands() != 4)
    return false;

  SmallString<128> Str;
  raw_svector_ostream OS(Str);
  OS << "DEBUG_VALUE: ";

  const DILocalVariable *V = MI->getDebugVariable();
  if (auto *SP = dyn_cast<DISubprogram>(V->getScope())) {
    StringRef Name = SP->getDisplayName();
    if (!Name.empty())
      OS << Name << ":";
  }
  OS << V->getName();

  const DIExpression *Expr = MI->getDebugExpression();
  if (Expr->isBitPiece())
    OS << " [bit_piece offset=" << Expr->getBitPieceOffset()
       << " size=" << Expr->getBitPieceSize() << "]";
  OS << " <- ";

  // The second operand is only an offset if it's an immediate.
  bool Deref = MI->getOperand(0).isReg() && MI->getOperand(1).isImm();
  int64_t Offset = Deref ? MI->getOperand(1).getImm() : 0;

  for (unsigned i = 0; i < Expr->getNumElements(); ++i) {
    if (Deref) {
      // We currently don't support extra Offsets or derefs after the first
      // one. Bail out early instead of emitting an incorrect comment
      OS << " [complex expression]";
      AP.OutStreamer->emitRawComment(OS.str());
      return true;
    }
    uint64_t Op = Expr->getElement(i);
    if (Op == dwarf::DW_OP_deref) {
      Deref = true;
      continue;
    } else if (Op == dwarf::DW_OP_bit_piece) {
      // There can't be any operands after this in a valid expression
      break;
    }
    uint64_t ExtraOffset = Expr->getElement(i++);
    if (Op == dwarf::DW_OP_plus)
      Offset += ExtraOffset;
    else {
      assert(Op == dwarf::DW_OP_minus);
      Offset -= ExtraOffset;
    }
  }

  // Register or immediate value. Register 0 means undef.
  if (MI->getOperand(0).isFPImm()) {
    APFloat APF = APFloat(MI->getOperand(0).getFPImm()->getValueAPF());
    if (MI->getOperand(0).getFPImm()->getType()->isFloatTy()) {
      OS << (double)APF.convertToFloat();
    } else if (MI->getOperand(0).getFPImm()->getType()->isDoubleTy()) {
      OS << APF.convertToDouble();
    } else {
      // There is no good way to print long double.  Convert a copy to
      // double.  Ah well, it's only a comment.
      bool ignored;
      APF.convert(APFloat::IEEEdouble, APFloat::rmNearestTiesToEven,
                  &ignored);
      OS << "(long double) " << APF.convertToDouble();
    }
  } else if (MI->getOperand(0).isImm()) {
    OS << MI->getOperand(0).getImm();
  } else if (MI->getOperand(0).isCImm()) {
    MI->getOperand(0).getCImm()->getValue().print(OS, false /*isSigned*/);
  } else {
    unsigned Reg;
    if (MI->getOperand(0).isReg()) {
      Reg = MI->getOperand(0).getReg();
    } else {
      assert(MI->getOperand(0).isFI() && "Unknown operand type");
      const TargetFrameLowering *TFI = AP.MF->getSubtarget().getFrameLowering();
      Offset += TFI->getFrameIndexReference(*AP.MF,
                                            MI->getOperand(0).getIndex(), Reg);
      Deref = true;
    }
    if (Reg == 0) {
      // Suppress offset, it is not meaningful here.
      OS << "undef";
      // NOTE: Want this comment at start of line, don't emit with AddComment.
      AP.OutStreamer->emitRawComment(OS.str());
      return true;
    }
    if (Deref)
      OS << '[';
    OS << PrintReg(Reg, AP.MF->getSubtarget().getRegisterInfo());
  }

  if (Deref)
    OS << '+' << Offset << ']';

  // NOTE: Want this comment at start of line, don't emit with AddComment.
  AP.OutStreamer->emitRawComment(OS.str());
  return true;
}

AsmPrinter::CFIMoveType AsmPrinter::needsCFIMoves() {
  if (MAI->getExceptionHandlingType() == ExceptionHandling::DwarfCFI &&
      MF->getFunction()->needsUnwindTableEntry())
    return CFI_M_EH;

  if (MMI->hasDebugInfo())
    return CFI_M_Debug;

  return CFI_M_None;
}

bool AsmPrinter::needsSEHMoves() {
  return MAI->usesWindowsCFI() && MF->getFunction()->needsUnwindTableEntry();
}

void AsmPrinter::emitCFIInstruction(const MachineInstr &MI) {
  ExceptionHandling ExceptionHandlingType = MAI->getExceptionHandlingType();
  if (ExceptionHandlingType != ExceptionHandling::DwarfCFI &&
      ExceptionHandlingType != ExceptionHandling::ARM)
    return;

  if (needsCFIMoves() == CFI_M_None)
    return;

  const MachineModuleInfo &MMI = MF->getMMI();
  const std::vector<MCCFIInstruction> &Instrs = MMI.getFrameInstructions();
  unsigned CFIIndex = MI.getOperand(0).getCFIIndex();
  const MCCFIInstruction &CFI = Instrs[CFIIndex];
  emitCFIInstruction(CFI);
}

void AsmPrinter::emitFrameAlloc(const MachineInstr &MI) {
  // The operands are the MCSymbol and the frame offset of the allocation.
  MCSymbol *FrameAllocSym = MI.getOperand(0).getMCSymbol();
  int FrameOffset = MI.getOperand(1).getImm();

  // Emit a symbol assignment.
  OutStreamer->EmitAssignment(FrameAllocSym,
                             MCConstantExpr::create(FrameOffset, OutContext));
}

/// EmitFunctionBody - This method emits the body and trailer for a
/// function.
void AsmPrinter::EmitFunctionBody() {
  EmitFunctionHeader();

  // Emit target-specific gunk before the function body.
  EmitFunctionBodyStart();

  bool ShouldPrintDebugScopes = MMI->hasDebugInfo();

  // Print out code for the function.
  bool HasAnyRealCode = false;
  for (auto &MBB : *MF) {
    // Print a label for the basic block.
    EmitBasicBlockStart(MBB);
    for (auto &MI : MBB) {

      // Print the assembly for the instruction.
      if (!MI.isPosition() && !MI.isImplicitDef() && !MI.isKill() &&
          !MI.isDebugValue()) {
        HasAnyRealCode = true;
        ++EmittedInsts;
      }

      if (ShouldPrintDebugScopes) {
        for (const HandlerInfo &HI : Handlers) {
          NamedRegionTimer T(HI.TimerName, HI.TimerGroupName,
                             TimePassesIsEnabled);
          HI.Handler->beginInstruction(&MI);
        }
      }

      if (isVerbose())
        emitComments(MI, OutStreamer->GetCommentOS());

      switch (MI.getOpcode()) {
      case TargetOpcode::CFI_INSTRUCTION:
        emitCFIInstruction(MI);
        break;

      case TargetOpcode::LOCAL_ESCAPE:
        emitFrameAlloc(MI);
        break;

      case TargetOpcode::EH_LABEL:
      case TargetOpcode::GC_LABEL:
        OutStreamer->EmitLabel(MI.getOperand(0).getMCSymbol());
        break;
      case TargetOpcode::INLINEASM:
        EmitInlineAsm(&MI);
        break;
      case TargetOpcode::DBG_VALUE:
        if (isVerbose()) {
          if (!emitDebugValueComment(&MI, *this))
            EmitInstruction(&MI);
        }
        break;
      case TargetOpcode::IMPLICIT_DEF:
        if (isVerbose()) emitImplicitDef(&MI);
        break;
      case TargetOpcode::KILL:
        if (isVerbose()) emitKill(&MI, *this);
        break;
      default:
        EmitInstruction(&MI);
        break;
      }

      if (ShouldPrintDebugScopes) {
        for (const HandlerInfo &HI : Handlers) {
          NamedRegionTimer T(HI.TimerName, HI.TimerGroupName,
                             TimePassesIsEnabled);
          HI.Handler->endInstruction();
        }
      }
    }

    EmitBasicBlockEnd(MBB);
  }

  // If the function is empty and the object file uses .subsections_via_symbols,
  // then we need to emit *something* to the function body to prevent the
  // labels from collapsing together.  Just emit a noop.
  if ((MAI->hasSubsectionsViaSymbols() && !HasAnyRealCode)) {
    MCInst Noop;
    MF->getSubtarget().getInstrInfo()->getNoopForMachoTarget(Noop);
    OutStreamer->AddComment("avoids zero-length function");

    // Targets can opt-out of emitting the noop here by leaving the opcode
    // unspecified.
    if (Noop.getOpcode())
      OutStreamer->EmitInstruction(Noop, getSubtargetInfo());
  }

  const Function *F = MF->getFunction();
  for (const auto &BB : *F) {
    if (!BB.hasAddressTaken())
      continue;
    MCSymbol *Sym = GetBlockAddressSymbol(&BB);
    if (Sym->isDefined())
      continue;
    OutStreamer->AddComment("Address of block that was removed by CodeGen");
    OutStreamer->EmitLabel(Sym);
  }

  // Emit target-specific gunk after the function body.
  EmitFunctionBodyEnd();

  if (!MMI->getLandingPads().empty() || MMI->hasDebugInfo() ||
      MMI->hasEHFunclets() || MAI->hasDotTypeDotSizeDirective()) {
    // Create a symbol for the end of function.
    CurrentFnEnd = createTempSymbol("func_end");
    OutStreamer->EmitLabel(CurrentFnEnd);
  }

  // If the target wants a .size directive for the size of the function, emit
  // it.
  if (MAI->hasDotTypeDotSizeDirective()) {
    // We can get the size as difference between the function label and the
    // temp label.
    const MCExpr *SizeExp = MCBinaryExpr::createSub(
        MCSymbolRefExpr::create(CurrentFnEnd, OutContext),
        MCSymbolRefExpr::create(CurrentFnSymForSize, OutContext), OutContext);
    if (auto Sym = dyn_cast<MCSymbolELF>(CurrentFnSym))
      OutStreamer->emitELFSize(Sym, SizeExp);
  }

  for (const HandlerInfo &HI : Handlers) {
    NamedRegionTimer T(HI.TimerName, HI.TimerGroupName, TimePassesIsEnabled);
    HI.Handler->markFunctionEnd();
  }

  // Print out jump tables referenced by the function.
  EmitJumpTableInfo();

  // Emit post-function debug and/or EH information.
  for (const HandlerInfo &HI : Handlers) {
    NamedRegionTimer T(HI.TimerName, HI.TimerGroupName, TimePassesIsEnabled);
    HI.Handler->endFunction(MF);
  }
  MMI->EndFunction();

  OutStreamer->AddBlankLine();
}

/// \brief Compute the number of Global Variables that uses a Constant.
static unsigned getNumGlobalVariableUses(const Constant *C) {
  if (!C)
    return 0;

  if (isa<GlobalVariable>(C))
    return 1;

  unsigned NumUses = 0;
  for (auto *CU : C->users())
    NumUses += getNumGlobalVariableUses(dyn_cast<Constant>(CU));

  return NumUses;
}

/// \brief Only consider global GOT equivalents if at least one user is a
/// cstexpr inside an initializer of another global variables. Also, don't
/// handle cstexpr inside instructions. During global variable emission,
/// candidates are skipped and are emitted later in case at least one cstexpr
/// isn't replaced by a PC relative GOT entry access.
static bool isGOTEquivalentCandidate(const GlobalVariable *GV,
                                     unsigned &NumGOTEquivUsers) {
  // Global GOT equivalents are unnamed private globals with a constant
  // pointer initializer to another global symbol. They must point to a
  // GlobalVariable or Function, i.e., as GlobalValue.
  if (!GV->hasGlobalUnnamedAddr() || !GV->hasInitializer() ||
      !GV->isConstant() || !GV->isDiscardableIfUnused() ||
      !dyn_cast<GlobalValue>(GV->getOperand(0)))
    return false;

  // To be a got equivalent, at least one of its users need to be a constant
  // expression used by another global variable.
  for (auto *U : GV->users())
    NumGOTEquivUsers += getNumGlobalVariableUses(dyn_cast<Constant>(U));

  return NumGOTEquivUsers > 0;
}

/// \brief Unnamed constant global variables solely contaning a pointer to
/// another globals variable is equivalent to a GOT table entry; it contains the
/// the address of another symbol. Optimize it and replace accesses to these
/// "GOT equivalents" by using the GOT entry for the final global instead.
/// Compute GOT equivalent candidates among all global variables to avoid
/// emitting them if possible later on, after it use is replaced by a GOT entry
/// access.
void AsmPrinter::computeGlobalGOTEquivs(Module &M) {
  if (!getObjFileLowering().supportIndirectSymViaGOTPCRel())
    return;

  for (const auto &G : M.globals()) {
    unsigned NumGOTEquivUsers = 0;
    if (!isGOTEquivalentCandidate(&G, NumGOTEquivUsers))
      continue;

    const MCSymbol *GOTEquivSym = getSymbol(&G);
    GlobalGOTEquivs[GOTEquivSym] = std::make_pair(&G, NumGOTEquivUsers);
  }
}

/// \brief Constant expressions using GOT equivalent globals may not be eligible
/// for PC relative GOT entry conversion, in such cases we need to emit such
/// globals we previously omitted in EmitGlobalVariable.
void AsmPrinter::emitGlobalGOTEquivs() {
  if (!getObjFileLowering().supportIndirectSymViaGOTPCRel())
    return;

  SmallVector<const GlobalVariable *, 8> FailedCandidates;
  for (auto &I : GlobalGOTEquivs) {
    const GlobalVariable *GV = I.second.first;
    unsigned Cnt = I.second.second;
    if (Cnt)
      FailedCandidates.push_back(GV);
  }
  GlobalGOTEquivs.clear();

  for (auto *GV : FailedCandidates)
    EmitGlobalVariable(GV);
}

void AsmPrinter::emitGlobalIndirectSymbol(Module &M,
                                          const GlobalIndirectSymbol& GIS) {
  MCSymbol *Name = getSymbol(&GIS);

  if (GIS.hasExternalLinkage() || !MAI->getWeakRefDirective())
    OutStreamer->EmitSymbolAttribute(Name, MCSA_Global);
  else if (GIS.hasWeakLinkage() || GIS.hasLinkOnceLinkage())
    OutStreamer->EmitSymbolAttribute(Name, MCSA_WeakReference);
  else
    assert(GIS.hasLocalLinkage() && "Invalid alias or ifunc linkage");

  // Set the symbol type to function if the alias has a function type.
  // This affects codegen when the aliasee is not a function.
  if (GIS.getType()->getPointerElementType()->isFunctionTy()) {
    OutStreamer->EmitSymbolAttribute(Name, MCSA_ELF_TypeFunction);
    if (isa<GlobalIFunc>(GIS))
      OutStreamer->EmitSymbolAttribute(Name, MCSA_ELF_TypeIndFunction);
  }

  EmitVisibility(Name, GIS.getVisibility());

  const MCExpr *Expr = lowerConstant(GIS.getIndirectSymbol());

  if (isa<GlobalAlias>(&GIS) && MAI->hasAltEntry() && isa<MCBinaryExpr>(Expr))
    OutStreamer->EmitSymbolAttribute(Name, MCSA_AltEntry);

  // Emit the directives as assignments aka .set:
  OutStreamer->EmitAssignment(Name, Expr);

  if (auto *GA = dyn_cast<GlobalAlias>(&GIS)) {
    // If the aliasee does not correspond to a symbol in the output, i.e. the
    // alias is not of an object or the aliased object is private, then set the
    // size of the alias symbol from the type of the alias. We don't do this in
    // other situations as the alias and aliasee having differing types but same
    // size may be intentional.
    const GlobalObject *BaseObject = GA->getBaseObject();
    if (MAI->hasDotTypeDotSizeDirective() && GA->getValueType()->isSized() &&
        (!BaseObject || BaseObject->hasPrivateLinkage())) {
      const DataLayout &DL = M.getDataLayout();
      uint64_t Size = DL.getTypeAllocSize(GA->getValueType());
      OutStreamer->emitELFSize(cast<MCSymbolELF>(Name),
                               MCConstantExpr::create(Size, OutContext));
    }
  }
}

bool AsmPrinter::doFinalization(Module &M) {
  // Set the MachineFunction to nullptr so that we can catch attempted
  // accesses to MF specific features at the module level and so that
  // we can conditionalize accesses based on whether or not it is nullptr.
  MF = nullptr;

  // Gather all GOT equivalent globals in the module. We really need two
  // passes over the globals: one to compute and another to avoid its emission
  // in EmitGlobalVariable, otherwise we would not be able to handle cases
  // where the got equivalent shows up before its use.
  computeGlobalGOTEquivs(M);

  // Emit global variables.
  for (const auto &G : M.globals())
    EmitGlobalVariable(&G);

  // Emit remaining GOT equivalent globals.
  emitGlobalGOTEquivs();

  // Emit visibility info for declarations
  for (const Function &F : M) {
    if (!F.isDeclarationForLinker())
      continue;
    GlobalValue::VisibilityTypes V = F.getVisibility();
    if (V == GlobalValue::DefaultVisibility)
      continue;

    MCSymbol *Name = getSymbol(&F);
    EmitVisibility(Name, V, false);
  }

  const TargetLoweringObjectFile &TLOF = getObjFileLowering();

  // Emit module flags.
  SmallVector<Module::ModuleFlagEntry, 8> ModuleFlags;
  M.getModuleFlagsMetadata(ModuleFlags);
  if (!ModuleFlags.empty())
    TLOF.emitModuleFlags(*OutStreamer, ModuleFlags, *Mang, TM);

  if (TM.getTargetTriple().isOSBinFormatELF()) {
    MachineModuleInfoELF &MMIELF = MMI->getObjFileInfo<MachineModuleInfoELF>();

    // Output stubs for external and common global variables.
    MachineModuleInfoELF::SymbolListTy Stubs = MMIELF.GetGVStubList();
    if (!Stubs.empty()) {
      OutStreamer->SwitchSection(TLOF.getDataSection());
      const DataLayout &DL = M.getDataLayout();

      for (const auto &Stub : Stubs) {
        OutStreamer->EmitLabel(Stub.first);
        OutStreamer->EmitSymbolValue(Stub.second.getPointer(),
                                     DL.getPointerSize());
      }
    }
  }

  // Finalize debug and EH information.
  for (const HandlerInfo &HI : Handlers) {
    NamedRegionTimer T(HI.TimerName, HI.TimerGroupName,
                       TimePassesIsEnabled);
    HI.Handler->endModule();
    delete HI.Handler;
  }
  Handlers.clear();
  DD = nullptr;

  // If the target wants to know about weak references, print them all.
  if (MAI->getWeakRefDirective()) {
    // FIXME: This is not lazy, it would be nice to only print weak references
    // to stuff that is actually used.  Note that doing so would require targets
    // to notice uses in operands (due to constant exprs etc).  This should
    // happen with the MC stuff eventually.

    // Print out module-level global objects here.
    for (const auto &GO : M.global_objects()) {
      if (!GO.hasExternalWeakLinkage())
        continue;
      OutStreamer->EmitSymbolAttribute(getSymbol(&GO), MCSA_WeakReference);
    }
  }

  OutStreamer->AddBlankLine();

  // Print aliases in topological order, that is, for each alias a = b,
  // b must be printed before a.
  // This is because on some targets (e.g. PowerPC) linker expects aliases in
  // such an order to generate correct TOC information.
  SmallVector<const GlobalAlias *, 16> AliasStack;
  SmallPtrSet<const GlobalAlias *, 16> AliasVisited;
  for (const auto &Alias : M.aliases()) {
    for (const GlobalAlias *Cur = &Alias; Cur;
         Cur = dyn_cast<GlobalAlias>(Cur->getAliasee())) {
      if (!AliasVisited.insert(Cur).second)
        break;
      AliasStack.push_back(Cur);
    }
    for (const GlobalAlias *AncestorAlias : reverse(AliasStack))
      emitGlobalIndirectSymbol(M, *AncestorAlias);
    AliasStack.clear();
  }
  for (const auto &IFunc : M.ifuncs())
    emitGlobalIndirectSymbol(M, IFunc);

  GCModuleInfo *MI = getAnalysisIfAvailable<GCModuleInfo>();
  assert(MI && "AsmPrinter didn't require GCModuleInfo?");
  for (GCModuleInfo::iterator I = MI->end(), E = MI->begin(); I != E; )
    if (GCMetadataPrinter *MP = GetOrCreateGCPrinter(**--I))
      MP->finishAssembly(M, *MI, *this);

  // Emit llvm.ident metadata in an '.ident' directive.
  EmitModuleIdents(M);

  // Emit __morestack address if needed for indirect calls.
  if (MMI->usesMorestackAddr()) {
    unsigned Align = 1;
    MCSection *ReadOnlySection = getObjFileLowering().getSectionForConstant(
        getDataLayout(), SectionKind::getReadOnly(),
        /*C=*/nullptr, Align);
    OutStreamer->SwitchSection(ReadOnlySection);

    MCSymbol *AddrSymbol =
        OutContext.getOrCreateSymbol(StringRef("__morestack_addr"));
    OutStreamer->EmitLabel(AddrSymbol);

    unsigned PtrSize = M.getDataLayout().getPointerSize(0);
    OutStreamer->EmitSymbolValue(GetExternalSymbolSymbol("__morestack"),
                                 PtrSize);
  }

  // If we don't have any trampolines, then we don't require stack memory
  // to be executable. Some targets have a directive to declare this.
  Function *InitTrampolineIntrinsic = M.getFunction("llvm.init.trampoline");
  if (!InitTrampolineIntrinsic || InitTrampolineIntrinsic->use_empty())
    if (MCSection *S = MAI->getNonexecutableStackSection(OutContext))
      OutStreamer->SwitchSection(S);

  // Allow the target to emit any magic that it wants at the end of the file,
  // after everything else has gone out.
  EmitEndOfAsmFile(M);

  delete Mang; Mang = nullptr;
  MMI = nullptr;

  OutStreamer->Finish();
  OutStreamer->reset();

  return false;
}

MCSymbol *AsmPrinter::getCurExceptionSym() {
  if (!CurExceptionSym)
    CurExceptionSym = createTempSymbol("exception");
  return CurExceptionSym;
}

void AsmPrinter::SetupMachineFunction(MachineFunction &MF) {
  this->MF = &MF;
  // Get the function symbol.
  CurrentFnSym = getSymbol(MF.getFunction());
  CurrentFnSymForSize = CurrentFnSym;
  CurrentFnBegin = nullptr;
  CurExceptionSym = nullptr;
  bool NeedsLocalForSize = MAI->needsLocalForSize();
  if (!MMI->getLandingPads().empty() || MMI->hasDebugInfo() ||
      MMI->hasEHFunclets() || NeedsLocalForSize) {
    CurrentFnBegin = createTempSymbol("func_begin");
    if (NeedsLocalForSize)
      CurrentFnSymForSize = CurrentFnBegin;
  }

  if (isVerbose())
    LI = &getAnalysis<MachineLoopInfo>();
}

namespace {
// Keep track the alignment, constpool entries per Section.
  struct SectionCPs {
    MCSection *S;
    unsigned Alignment;
    SmallVector<unsigned, 4> CPEs;
    SectionCPs(MCSection *s, unsigned a) : S(s), Alignment(a) {}
  };
}

/// EmitConstantPool - Print to the current output stream assembly
/// representations of the constants in the constant pool MCP. This is
/// used to print out constants which have been "spilled to memory" by
/// the code generator.
///
void AsmPrinter::EmitConstantPool() {
  const MachineConstantPool *MCP = MF->getConstantPool();
  const std::vector<MachineConstantPoolEntry> &CP = MCP->getConstants();
  if (CP.empty()) return;

  // Calculate sections for constant pool entries. We collect entries to go into
  // the same section together to reduce amount of section switch statements.
  SmallVector<SectionCPs, 4> CPSections;
  for (unsigned i = 0, e = CP.size(); i != e; ++i) {
    const MachineConstantPoolEntry &CPE = CP[i];
    unsigned Align = CPE.getAlignment();

    SectionKind Kind = CPE.getSectionKind(&getDataLayout());

    const Constant *C = nullptr;
    if (!CPE.isMachineConstantPoolEntry())
      C = CPE.Val.ConstVal;

    MCSection *S = getObjFileLowering().getSectionForConstant(getDataLayout(),
                                                              Kind, C, Align);

    // The number of sections are small, just do a linear search from the
    // last section to the first.
    bool Found = false;
    unsigned SecIdx = CPSections.size();
    while (SecIdx != 0) {
      if (CPSections[--SecIdx].S == S) {
        Found = true;
        break;
      }
    }
    if (!Found) {
      SecIdx = CPSections.size();
      CPSections.push_back(SectionCPs(S, Align));
    }

    if (Align > CPSections[SecIdx].Alignment)
      CPSections[SecIdx].Alignment = Align;
    CPSections[SecIdx].CPEs.push_back(i);
  }

  // Now print stuff into the calculated sections.
  const MCSection *CurSection = nullptr;
  unsigned Offset = 0;
  for (unsigned i = 0, e = CPSections.size(); i != e; ++i) {
    for (unsigned j = 0, ee = CPSections[i].CPEs.size(); j != ee; ++j) {
      unsigned CPI = CPSections[i].CPEs[j];
      MCSymbol *Sym = GetCPISymbol(CPI);
      if (!Sym->isUndefined())
        continue;

      if (CurSection != CPSections[i].S) {
        OutStreamer->SwitchSection(CPSections[i].S);
        EmitAlignment(Log2_32(CPSections[i].Alignment));
        CurSection = CPSections[i].S;
        Offset = 0;
      }

      MachineConstantPoolEntry CPE = CP[CPI];

      // Emit inter-object padding for alignment.
      unsigned AlignMask = CPE.getAlignment() - 1;
      unsigned NewOffset = (Offset + AlignMask) & ~AlignMask;
      OutStreamer->EmitZeros(NewOffset - Offset);

      Type *Ty = CPE.getType();
      Offset = NewOffset + getDataLayout().getTypeAllocSize(Ty);

      OutStreamer->EmitLabel(Sym);
      if (CPE.isMachineConstantPoolEntry())
        EmitMachineConstantPoolValue(CPE.Val.MachineCPVal);
      else
        EmitGlobalConstant(getDataLayout(), CPE.Val.ConstVal);
    }
  }
}

/// EmitJumpTableInfo - Print assembly representations of the jump tables used
/// by the current function to the current output stream.
///
void AsmPrinter::EmitJumpTableInfo() {
  const DataLayout &DL = MF->getDataLayout();
  const MachineJumpTableInfo *MJTI = MF->getJumpTableInfo();
  if (!MJTI) return;
  if (MJTI->getEntryKind() == MachineJumpTableInfo::EK_Inline) return;
  const std::vector<MachineJumpTableEntry> &JT = MJTI->getJumpTables();
  if (JT.empty()) return;

  // Pick the directive to use to print the jump table entries, and switch to
  // the appropriate section.
  const Function *F = MF->getFunction();
  const TargetLoweringObjectFile &TLOF = getObjFileLowering();
  bool JTInDiffSection = !TLOF.shouldPutJumpTableInFunctionSection(
      MJTI->getEntryKind() == MachineJumpTableInfo::EK_LabelDifference32,
      *F);
  if (JTInDiffSection) {
    // Drop it in the readonly section.
    MCSection *ReadOnlySection = TLOF.getSectionForJumpTable(*F, *Mang, TM);
    OutStreamer->SwitchSection(ReadOnlySection);
  }

  EmitAlignment(Log2_32(MJTI->getEntryAlignment(DL)));

  // Jump tables in code sections are marked with a data_region directive
  // where that's supported.
  if (!JTInDiffSection)
    OutStreamer->EmitDataRegion(MCDR_DataRegionJT32);

  for (unsigned JTI = 0, e = JT.size(); JTI != e; ++JTI) {
    const std::vector<MachineBasicBlock*> &JTBBs = JT[JTI].MBBs;

    // If this jump table was deleted, ignore it.
    if (JTBBs.empty()) continue;

    // For the EK_LabelDifference32 entry, if using .set avoids a relocation,
    /// emit a .set directive for each unique entry.
    if (MJTI->getEntryKind() == MachineJumpTableInfo::EK_LabelDifference32 &&
        MAI->doesSetDirectiveSuppressReloc()) {
      SmallPtrSet<const MachineBasicBlock*, 16> EmittedSets;
      const TargetLowering *TLI = MF->getSubtarget().getTargetLowering();
      const MCExpr *Base = TLI->getPICJumpTableRelocBaseExpr(MF,JTI,OutContext);
      for (unsigned ii = 0, ee = JTBBs.size(); ii != ee; ++ii) {
        const MachineBasicBlock *MBB = JTBBs[ii];
        if (!EmittedSets.insert(MBB).second)
          continue;

        // .set LJTSet, LBB32-base
        const MCExpr *LHS =
          MCSymbolRefExpr::create(MBB->getSymbol(), OutContext);
        OutStreamer->EmitAssignment(GetJTSetSymbol(JTI, MBB->getNumber()),
                                    MCBinaryExpr::createSub(LHS, Base,
                                                            OutContext));
      }
    }

    // On some targets (e.g. Darwin) we want to emit two consecutive labels
    // before each jump table.  The first label is never referenced, but tells
    // the assembler and linker the extents of the jump table object.  The
    // second label is actually referenced by the code.
    if (JTInDiffSection && DL.hasLinkerPrivateGlobalPrefix())
      // FIXME: This doesn't have to have any specific name, just any randomly
      // named and numbered 'l' label would work.  Simplify GetJTISymbol.
      OutStreamer->EmitLabel(GetJTISymbol(JTI, true));

    OutStreamer->EmitLabel(GetJTISymbol(JTI));

    for (unsigned ii = 0, ee = JTBBs.size(); ii != ee; ++ii)
      EmitJumpTableEntry(MJTI, JTBBs[ii], JTI);
  }
  if (!JTInDiffSection)
    OutStreamer->EmitDataRegion(MCDR_DataRegionEnd);
}

/// EmitJumpTableEntry - Emit a jump table entry for the specified MBB to the
/// current stream.
void AsmPrinter::EmitJumpTableEntry(const MachineJumpTableInfo *MJTI,
                                    const MachineBasicBlock *MBB,
                                    unsigned UID) const {
  assert(MBB && MBB->getNumber() >= 0 && "Invalid basic block");
  const MCExpr *Value = nullptr;
  switch (MJTI->getEntryKind()) {
  case MachineJumpTableInfo::EK_Inline:
    llvm_unreachable("Cannot emit EK_Inline jump table entry");
  case MachineJumpTableInfo::EK_Custom32:
    Value = MF->getSubtarget().getTargetLowering()->LowerCustomJumpTableEntry(
        MJTI, MBB, UID, OutContext);
    break;
  case MachineJumpTableInfo::EK_BlockAddress:
    // EK_BlockAddress - Each entry is a plain address of block, e.g.:
    //     .word LBB123
    Value = MCSymbolRefExpr::create(MBB->getSymbol(), OutContext);
    break;
  case MachineJumpTableInfo::EK_GPRel32BlockAddress: {
    // EK_GPRel32BlockAddress - Each entry is an address of block, encoded
    // with a relocation as gp-relative, e.g.:
    //     .gprel32 LBB123
    MCSymbol *MBBSym = MBB->getSymbol();
    OutStreamer->EmitGPRel32Value(MCSymbolRefExpr::create(MBBSym, OutContext));
    return;
  }

  case MachineJumpTableInfo::EK_GPRel64BlockAddress: {
    // EK_GPRel64BlockAddress - Each entry is an address of block, encoded
    // with a relocation as gp-relative, e.g.:
    //     .gpdword LBB123
    MCSymbol *MBBSym = MBB->getSymbol();
    OutStreamer->EmitGPRel64Value(MCSymbolRefExpr::create(MBBSym, OutContext));
    return;
  }

  case MachineJumpTableInfo::EK_LabelDifference32: {
    // Each entry is the address of the block minus the address of the jump
    // table. This is used for PIC jump tables where gprel32 is not supported.
    // e.g.:
    //      .word LBB123 - LJTI1_2
    // If the .set directive avoids relocations, this is emitted as:
    //      .set L4_5_set_123, LBB123 - LJTI1_2
    //      .word L4_5_set_123
    if (MAI->doesSetDirectiveSuppressReloc()) {
      Value = MCSymbolRefExpr::create(GetJTSetSymbol(UID, MBB->getNumber()),
                                      OutContext);
      break;
    }
    Value = MCSymbolRefExpr::create(MBB->getSymbol(), OutContext);
    const TargetLowering *TLI = MF->getSubtarget().getTargetLowering();
    const MCExpr *Base = TLI->getPICJumpTableRelocBaseExpr(MF, UID, OutContext);
    Value = MCBinaryExpr::createSub(Value, Base, OutContext);
    break;
  }
  }

  assert(Value && "Unknown entry kind!");

  unsigned EntrySize = MJTI->getEntrySize(getDataLayout());
  OutStreamer->EmitValue(Value, EntrySize);
}


/// EmitSpecialLLVMGlobal - Check to see if the specified global is a
/// special global used by LLVM.  If so, emit it and return true, otherwise
/// do nothing and return false.
bool AsmPrinter::EmitSpecialLLVMGlobal(const GlobalVariable *GV) {
  if (GV->getName() == "llvm.used") {
    if (MAI->hasNoDeadStrip())    // No need to emit this at all.
      EmitLLVMUsedList(cast<ConstantArray>(GV->getInitializer()));
    return true;
  }

  // Ignore debug and non-emitted data.  This handles llvm.compiler.used.
  if (GV->getSection() == "llvm.metadata" ||
      GV->hasAvailableExternallyLinkage())
    return true;

  if (!GV->hasAppendingLinkage()) return false;

  assert(GV->hasInitializer() && "Not a special LLVM global!");

  if (GV->getName() == "llvm.global_ctors") {
    EmitXXStructorList(GV->getParent()->getDataLayout(), GV->getInitializer(),
                       /* isCtor */ true);

    if (TM.getRelocationModel() == Reloc::Static &&
        MAI->hasStaticCtorDtorReferenceInStaticMode()) {
      StringRef Sym(".constructors_used");
      OutStreamer->EmitSymbolAttribute(OutContext.getOrCreateSymbol(Sym),
                                       MCSA_Reference);
    }
    return true;
  }

  if (GV->getName() == "llvm.global_dtors") {
    EmitXXStructorList(GV->getParent()->getDataLayout(), GV->getInitializer(),
                       /* isCtor */ false);

    if (TM.getRelocationModel() == Reloc::Static &&
        MAI->hasStaticCtorDtorReferenceInStaticMode()) {
      StringRef Sym(".destructors_used");
      OutStreamer->EmitSymbolAttribute(OutContext.getOrCreateSymbol(Sym),
                                       MCSA_Reference);
    }
    return true;
  }

  report_fatal_error("unknown special variable");
}

/// EmitLLVMUsedList - For targets that define a MAI::UsedDirective, mark each
/// global in the specified llvm.used list for which emitUsedDirectiveFor
/// is true, as being used with this directive.
void AsmPrinter::EmitLLVMUsedList(const ConstantArray *InitList) {
  // Should be an array of 'i8*'.
  for (unsigned i = 0, e = InitList->getNumOperands(); i != e; ++i) {
    const GlobalValue *GV =
      dyn_cast<GlobalValue>(InitList->getOperand(i)->stripPointerCasts());
    if (GV)
      OutStreamer->EmitSymbolAttribute(getSymbol(GV), MCSA_NoDeadStrip);
  }
}

namespace {
struct Structor {
  Structor() : Priority(0), Func(nullptr), ComdatKey(nullptr) {}
  int Priority;
  llvm::Constant *Func;
  llvm::GlobalValue *ComdatKey;
};
} // end namespace

/// EmitXXStructorList - Emit the ctor or dtor list taking into account the init
/// priority.
void AsmPrinter::EmitXXStructorList(const DataLayout &DL, const Constant *List,
                                    bool isCtor) {
  // Should be an array of '{ int, void ()* }' structs.  The first value is the
  // init priority.
  if (!isa<ConstantArray>(List)) return;

  // Sanity check the structors list.
  const ConstantArray *InitList = dyn_cast<ConstantArray>(List);
  if (!InitList) return; // Not an array!
  StructType *ETy = dyn_cast<StructType>(InitList->getType()->getElementType());
  // FIXME: Only allow the 3-field form in LLVM 4.0.
  if (!ETy || ETy->getNumElements() < 2 || ETy->getNumElements() > 3)
    return; // Not an array of two or three elements!
  if (!isa<IntegerType>(ETy->getTypeAtIndex(0U)) ||
      !isa<PointerType>(ETy->getTypeAtIndex(1U))) return; // Not (int, ptr).
  if (ETy->getNumElements() == 3 && !isa<PointerType>(ETy->getTypeAtIndex(2U)))
    return; // Not (int, ptr, ptr).

  // Gather the structors in a form that's convenient for sorting by priority.
  SmallVector<Structor, 8> Structors;
  for (Value *O : InitList->operands()) {
    ConstantStruct *CS = dyn_cast<ConstantStruct>(O);
    if (!CS) continue; // Malformed.
    if (CS->getOperand(1)->isNullValue())
      break;  // Found a null terminator, skip the rest.
    ConstantInt *Priority = dyn_cast<ConstantInt>(CS->getOperand(0));
    if (!Priority) continue; // Malformed.
    Structors.push_back(Structor());
    Structor &S = Structors.back();
    S.Priority = Priority->getLimitedValue(65535);
    S.Func = CS->getOperand(1);
    if (ETy->getNumElements() == 3 && !CS->getOperand(2)->isNullValue())
      S.ComdatKey =
          dyn_cast<GlobalValue>(CS->getOperand(2)->stripPointerCasts());
  }

  // Emit the function pointers in the target-specific order
  unsigned Align = Log2_32(DL.getPointerPrefAlignment());
  std::stable_sort(Structors.begin(), Structors.end(),
                   [](const Structor &L,
                      const Structor &R) { return L.Priority < R.Priority; });
  for (Structor &S : Structors) {
    const TargetLoweringObjectFile &Obj = getObjFileLowering();
    const MCSymbol *KeySym = nullptr;
    if (GlobalValue *GV = S.ComdatKey) {
      if (GV->hasAvailableExternallyLinkage())
        // If the associated variable is available_externally, some other TU
        // will provide its dynamic initializer.
        continue;

      KeySym = getSymbol(GV);
    }
    MCSection *OutputSection =
        (isCtor ? Obj.getStaticCtorSection(S.Priority, KeySym)
                : Obj.getStaticDtorSection(S.Priority, KeySym));
    OutStreamer->SwitchSection(OutputSection);
    if (OutStreamer->getCurrentSection() != OutStreamer->getPreviousSection())
      EmitAlignment(Align);
    EmitXXStructor(DL, S.Func);
  }
}

void AsmPrinter::EmitModuleIdents(Module &M) {
  if (!MAI->hasIdentDirective())
    return;

  if (const NamedMDNode *NMD = M.getNamedMetadata("llvm.ident")) {
    for (unsigned i = 0, e = NMD->getNumOperands(); i != e; ++i) {
      const MDNode *N = NMD->getOperand(i);
      assert(N->getNumOperands() == 1 &&
             "llvm.ident metadata entry can have only one operand");
      const MDString *S = cast<MDString>(N->getOperand(0));
      OutStreamer->EmitIdent(S->getString());
    }
  }
}

//===--------------------------------------------------------------------===//
// Emission and print routines
//

/// EmitInt8 - Emit a byte directive and value.
///
void AsmPrinter::EmitInt8(int Value) const {
  OutStreamer->EmitIntValue(Value, 1);
}

/// EmitInt16 - Emit a short directive and value.
///
void AsmPrinter::EmitInt16(int Value) const {
  OutStreamer->EmitIntValue(Value, 2);
}

/// EmitInt32 - Emit a long directive and value.
///
void AsmPrinter::EmitInt32(int Value) const {
  OutStreamer->EmitIntValue(Value, 4);
}

/// Emit something like ".long Hi-Lo" where the size in bytes of the directive
/// is specified by Size and Hi/Lo specify the labels. This implicitly uses
/// .set if it avoids relocations.
void AsmPrinter::EmitLabelDifference(const MCSymbol *Hi, const MCSymbol *Lo,
                                     unsigned Size) const {
  OutStreamer->emitAbsoluteSymbolDiff(Hi, Lo, Size);
}

/// EmitLabelPlusOffset - Emit something like ".long Label+Offset"
/// where the size in bytes of the directive is specified by Size and Label
/// specifies the label.  This implicitly uses .set if it is available.
void AsmPrinter::EmitLabelPlusOffset(const MCSymbol *Label, uint64_t Offset,
                                     unsigned Size,
                                     bool IsSectionRelative) const {
  if (MAI->needsDwarfSectionOffsetDirective() && IsSectionRelative) {
    OutStreamer->EmitCOFFSecRel32(Label);
    return;
  }

  // Emit Label+Offset (or just Label if Offset is zero)
  const MCExpr *Expr = MCSymbolRefExpr::create(Label, OutContext);
  if (Offset)
    Expr = MCBinaryExpr::createAdd(
        Expr, MCConstantExpr::create(Offset, OutContext), OutContext);

  OutStreamer->EmitValue(Expr, Size);
}

//===----------------------------------------------------------------------===//

// EmitAlignment - Emit an alignment directive to the specified power of
// two boundary.  For example, if you pass in 3 here, you will get an 8
// byte alignment.  If a global value is specified, and if that global has
// an explicit alignment requested, it will override the alignment request
// if required for correctness.
//
void AsmPrinter::EmitAlignment(unsigned NumBits, const GlobalObject *GV) const {
  if (GV)
    NumBits = getGVAlignmentLog2(GV, GV->getParent()->getDataLayout(), NumBits);

  if (NumBits == 0) return;   // 1-byte aligned: no need to emit alignment.

  assert(NumBits <
             static_cast<unsigned>(std::numeric_limits<unsigned>::digits) &&
         "undefined behavior");
  if (getCurrentSection()->getKind().isText())
    OutStreamer->EmitCodeAlignment(1u << NumBits);
  else
    OutStreamer->EmitValueToAlignment(1u << NumBits);
}

//===----------------------------------------------------------------------===//
// Constant emission.
//===----------------------------------------------------------------------===//

const MCExpr *AsmPrinter::lowerConstant(const Constant *CV) {
  MCContext &Ctx = OutContext;

  if (CV->isNullValue() || isa<UndefValue>(CV))
    return MCConstantExpr::create(0, Ctx);

  if (const ConstantInt *CI = dyn_cast<ConstantInt>(CV))
    return MCConstantExpr::create(CI->getZExtValue(), Ctx);

  if (const GlobalValue *GV = dyn_cast<GlobalValue>(CV))
    return MCSymbolRefExpr::create(getSymbol(GV), Ctx);

  if (const BlockAddress *BA = dyn_cast<BlockAddress>(CV))
    return MCSymbolRefExpr::create(GetBlockAddressSymbol(BA), Ctx);

  const ConstantExpr *CE = dyn_cast<ConstantExpr>(CV);
  if (!CE) {
    llvm_unreachable("Unknown constant value to lower!");
  }

  switch (CE->getOpcode()) {
  default:
    // If the code isn't optimized, there may be outstanding folding
    // opportunities. Attempt to fold the expression using DataLayout as a
    // last resort before giving up.
    if (Constant *C = ConstantFoldConstant(CE, getDataLayout()))
      if (C != CE)
        return lowerConstant(C);

    // Otherwise report the problem to the user.
    {
      std::string S;
      raw_string_ostream OS(S);
      OS << "Unsupported expression in static initializer: ";
      CE->printAsOperand(OS, /*PrintType=*/false,
                     !MF ? nullptr : MF->getFunction()->getParent());
      report_fatal_error(OS.str());
    }
  case Instruction::GetElementPtr: {
    // Generate a symbolic expression for the byte address
    APInt OffsetAI(getDataLayout().getPointerTypeSizeInBits(CE->getType()), 0);
    cast<GEPOperator>(CE)->accumulateConstantOffset(getDataLayout(), OffsetAI);

    const MCExpr *Base = lowerConstant(CE->getOperand(0));
    if (!OffsetAI)
      return Base;

    int64_t Offset = OffsetAI.getSExtValue();
    return MCBinaryExpr::createAdd(Base, MCConstantExpr::create(Offset, Ctx),
                                   Ctx);
  }

  case Instruction::Trunc:
    // We emit the value and depend on the assembler to truncate the generated
    // expression properly.  This is important for differences between
    // blockaddress labels.  Since the two labels are in the same function, it
    // is reasonable to treat their delta as a 32-bit value.
    // FALL THROUGH.
  case Instruction::BitCast:
    return lowerConstant(CE->getOperand(0));

  case Instruction::IntToPtr: {
    const DataLayout &DL = getDataLayout();

    // Handle casts to pointers by changing them into casts to the appropriate
    // integer type.  This promotes constant folding and simplifies this code.
    Constant *Op = CE->getOperand(0);
    Op = ConstantExpr::getIntegerCast(Op, DL.getIntPtrType(CV->getType()),
                                      false/*ZExt*/);
    return lowerConstant(Op);
  }

  case Instruction::PtrToInt: {
    const DataLayout &DL = getDataLayout();

    // Support only foldable casts to/from pointers that can be eliminated by
    // changing the pointer to the appropriately sized integer type.
    Constant *Op = CE->getOperand(0);
    Type *Ty = CE->getType();

    const MCExpr *OpExpr = lowerConstant(Op);

    // We can emit the pointer value into this slot if the slot is an
    // integer slot equal to the size of the pointer.
    if (DL.getTypeAllocSize(Ty) == DL.getTypeAllocSize(Op->getType()))
      return OpExpr;

    // Otherwise the pointer is smaller than the resultant integer, mask off
    // the high bits so we are sure to get a proper truncation if the input is
    // a constant expr.
    unsigned InBits = DL.getTypeAllocSizeInBits(Op->getType());
    const MCExpr *MaskExpr = MCConstantExpr::create(~0ULL >> (64-InBits), Ctx);
    return MCBinaryExpr::createAnd(OpExpr, MaskExpr, Ctx);
  }

  case Instruction::Sub: {
    GlobalValue *LHSGV;
    APInt LHSOffset;
    if (IsConstantOffsetFromGlobal(CE->getOperand(0), LHSGV, LHSOffset,
                                   getDataLayout())) {
      GlobalValue *RHSGV;
      APInt RHSOffset;
      if (IsConstantOffsetFromGlobal(CE->getOperand(1), RHSGV, RHSOffset,
                                     getDataLayout())) {
        const MCExpr *RelocExpr = getObjFileLowering().lowerRelativeReference(
            LHSGV, RHSGV, *Mang, TM);
        if (!RelocExpr)
          RelocExpr = MCBinaryExpr::createSub(
              MCSymbolRefExpr::create(getSymbol(LHSGV), Ctx),
              MCSymbolRefExpr::create(getSymbol(RHSGV), Ctx), Ctx);
        int64_t Addend = (LHSOffset - RHSOffset).getSExtValue();
        if (Addend != 0)
          RelocExpr = MCBinaryExpr::createAdd(
              RelocExpr, MCConstantExpr::create(Addend, Ctx), Ctx);
        return RelocExpr;
      }
    }
  }
  // else fallthrough

  // The MC library also has a right-shift operator, but it isn't consistently
  // signed or unsigned between different targets.
  case Instruction::Add:
  case Instruction::Mul:
  case Instruction::SDiv:
  case Instruction::SRem:
  case Instruction::Shl:
  case Instruction::And:
  case Instruction::Or:
  case Instruction::Xor: {
    const MCExpr *LHS = lowerConstant(CE->getOperand(0));
    const MCExpr *RHS = lowerConstant(CE->getOperand(1));
    switch (CE->getOpcode()) {
    default: llvm_unreachable("Unknown binary operator constant cast expr");
    case Instruction::Add: return MCBinaryExpr::createAdd(LHS, RHS, Ctx);
    case Instruction::Sub: return MCBinaryExpr::createSub(LHS, RHS, Ctx);
    case Instruction::Mul: return MCBinaryExpr::createMul(LHS, RHS, Ctx);
    case Instruction::SDiv: return MCBinaryExpr::createDiv(LHS, RHS, Ctx);
    case Instruction::SRem: return MCBinaryExpr::createMod(LHS, RHS, Ctx);
    case Instruction::Shl: return MCBinaryExpr::createShl(LHS, RHS, Ctx);
    case Instruction::And: return MCBinaryExpr::createAnd(LHS, RHS, Ctx);
    case Instruction::Or:  return MCBinaryExpr::createOr (LHS, RHS, Ctx);
    case Instruction::Xor: return MCBinaryExpr::createXor(LHS, RHS, Ctx);
    }
  }
  }
}

static void emitGlobalConstantImpl(const DataLayout &DL, const Constant *C,
                                   AsmPrinter &AP,
                                   const Constant *BaseCV = nullptr,
                                   uint64_t Offset = 0);

static void emitGlobalConstantFP(const ConstantFP *CFP, AsmPrinter &AP);

/// isRepeatedByteSequence - Determine whether the given value is
/// composed of a repeated sequence of identical bytes and return the
/// byte value.  If it is not a repeated sequence, return -1.
static int isRepeatedByteSequence(const ConstantDataSequential *V) {
  StringRef Data = V->getRawDataValues();
  assert(!Data.empty() && "Empty aggregates should be CAZ node");
  char C = Data[0];
  for (unsigned i = 1, e = Data.size(); i != e; ++i)
    if (Data[i] != C) return -1;
  return static_cast<uint8_t>(C); // Ensure 255 is not returned as -1.
}


/// isRepeatedByteSequence - Determine whether the given value is
/// composed of a repeated sequence of identical bytes and return the
/// byte value.  If it is not a repeated sequence, return -1.
static int isRepeatedByteSequence(const Value *V, const DataLayout &DL) {
  if (const ConstantInt *CI = dyn_cast<ConstantInt>(V)) {
    uint64_t Size = DL.getTypeAllocSizeInBits(V->getType());
    assert(Size % 8 == 0);

    // Extend the element to take zero padding into account.
    APInt Value = CI->getValue().zextOrSelf(Size);
    if (!Value.isSplat(8))
      return -1;

    return Value.zextOrTrunc(8).getZExtValue();
  }
  if (const ConstantArray *CA = dyn_cast<ConstantArray>(V)) {
    // Make sure all array elements are sequences of the same repeated
    // byte.
    assert(CA->getNumOperands() != 0 && "Should be a CAZ");
    Constant *Op0 = CA->getOperand(0);
    int Byte = isRepeatedByteSequence(Op0, DL);
    if (Byte == -1)
      return -1;

    // All array elements must be equal.
    for (unsigned i = 1, e = CA->getNumOperands(); i != e; ++i)
      if (CA->getOperand(i) != Op0)
        return -1;
    return Byte;
  }

  if (const ConstantDataSequential *CDS = dyn_cast<ConstantDataSequential>(V))
    return isRepeatedByteSequence(CDS);

  return -1;
}

static void emitGlobalConstantDataSequential(const DataLayout &DL,
                                             const ConstantDataSequential *CDS,
                                             AsmPrinter &AP) {

  // See if we can aggregate this into a .fill, if so, emit it as such.
  int Value = isRepeatedByteSequence(CDS, DL);
  if (Value != -1) {
    uint64_t Bytes = DL.getTypeAllocSize(CDS->getType());
    // Don't emit a 1-byte object as a .fill.
    if (Bytes > 1)
      return AP.OutStreamer->emitFill(Bytes, Value);
  }

  // If this can be emitted with .ascii/.asciz, emit it as such.
  if (CDS->isString())
    return AP.OutStreamer->EmitBytes(CDS->getAsString());

  // Otherwise, emit the values in successive locations.
  unsigned ElementByteSize = CDS->getElementByteSize();
  if (isa<IntegerType>(CDS->getElementType())) {
    for (unsigned i = 0, e = CDS->getNumElements(); i != e; ++i) {
      if (AP.isVerbose())
        AP.OutStreamer->GetCommentOS() << format("0x%" PRIx64 "\n",
                                                 CDS->getElementAsInteger(i));
      AP.OutStreamer->EmitIntValue(CDS->getElementAsInteger(i),
                                   ElementByteSize);
    }
  } else {
    for (unsigned I = 0, E = CDS->getNumElements(); I != E; ++I)
      emitGlobalConstantFP(cast<ConstantFP>(CDS->getElementAsConstant(I)), AP);
  }

  unsigned Size = DL.getTypeAllocSize(CDS->getType());
  unsigned EmittedSize = DL.getTypeAllocSize(CDS->getType()->getElementType()) *
                        CDS->getNumElements();
  if (unsigned Padding = Size - EmittedSize)
    AP.OutStreamer->EmitZeros(Padding);

}

static void emitGlobalConstantArray(const DataLayout &DL,
                                    const ConstantArray *CA, AsmPrinter &AP,
                                    const Constant *BaseCV, uint64_t Offset) {
  // See if we can aggregate some values.  Make sure it can be
  // represented as a series of bytes of the constant value.
  int Value = isRepeatedByteSequence(CA, DL);

  if (Value != -1) {
    uint64_t Bytes = DL.getTypeAllocSize(CA->getType());
    AP.OutStreamer->emitFill(Bytes, Value);
  }
  else {
    for (unsigned i = 0, e = CA->getNumOperands(); i != e; ++i) {
      emitGlobalConstantImpl(DL, CA->getOperand(i), AP, BaseCV, Offset);
      Offset += DL.getTypeAllocSize(CA->getOperand(i)->getType());
    }
  }
}

static void emitGlobalConstantVector(const DataLayout &DL,
                                     const ConstantVector *CV, AsmPrinter &AP) {
  for (unsigned i = 0, e = CV->getType()->getNumElements(); i != e; ++i)
    emitGlobalConstantImpl(DL, CV->getOperand(i), AP);

  unsigned Size = DL.getTypeAllocSize(CV->getType());
  unsigned EmittedSize = DL.getTypeAllocSize(CV->getType()->getElementType()) *
                         CV->getType()->getNumElements();
  if (unsigned Padding = Size - EmittedSize)
    AP.OutStreamer->EmitZeros(Padding);
}

static void emitGlobalConstantStruct(const DataLayout &DL,
                                     const ConstantStruct *CS, AsmPrinter &AP,
                                     const Constant *BaseCV, uint64_t Offset) {
  // Print the fields in successive locations. Pad to align if needed!
  unsigned Size = DL.getTypeAllocSize(CS->getType());
  const StructLayout *Layout = DL.getStructLayout(CS->getType());
  uint64_t SizeSoFar = 0;
  for (unsigned i = 0, e = CS->getNumOperands(); i != e; ++i) {
    const Constant *Field = CS->getOperand(i);

    // Print the actual field value.
    emitGlobalConstantImpl(DL, Field, AP, BaseCV, Offset + SizeSoFar);

    // Check if padding is needed and insert one or more 0s.
    uint64_t FieldSize = DL.getTypeAllocSize(Field->getType());
    uint64_t PadSize = ((i == e-1 ? Size : Layout->getElementOffset(i+1))
                        - Layout->getElementOffset(i)) - FieldSize;
    SizeSoFar += FieldSize + PadSize;

    // Insert padding - this may include padding to increase the size of the
    // current field up to the ABI size (if the struct is not packed) as well
    // as padding to ensure that the next field starts at the right offset.
    AP.OutStreamer->EmitZeros(PadSize);
  }
  assert(SizeSoFar == Layout->getSizeInBytes() &&
         "Layout of constant struct may be incorrect!");
}

static void emitGlobalConstantFP(const ConstantFP *CFP, AsmPrinter &AP) {
  APInt API = CFP->getValueAPF().bitcastToAPInt();

  // First print a comment with what we think the original floating-point value
  // should have been.
  if (AP.isVerbose()) {
    SmallString<8> StrVal;
    CFP->getValueAPF().toString(StrVal);

    if (CFP->getType())
      CFP->getType()->print(AP.OutStreamer->GetCommentOS());
    else
      AP.OutStreamer->GetCommentOS() << "Printing <null> Type";
    AP.OutStreamer->GetCommentOS() << ' ' << StrVal << '\n';
  }

  // Now iterate through the APInt chunks, emitting them in endian-correct
  // order, possibly with a smaller chunk at beginning/end (e.g. for x87 80-bit
  // floats).
  unsigned NumBytes = API.getBitWidth() / 8;
  unsigned TrailingBytes = NumBytes % sizeof(uint64_t);
  const uint64_t *p = API.getRawData();

  // PPC's long double has odd notions of endianness compared to how LLVM
  // handles it: p[0] goes first for *big* endian on PPC.
  if (AP.getDataLayout().isBigEndian() && !CFP->getType()->isPPC_FP128Ty()) {
    int Chunk = API.getNumWords() - 1;

    if (TrailingBytes)
      AP.OutStreamer->EmitIntValue(p[Chunk--], TrailingBytes);

    for (; Chunk >= 0; --Chunk)
      AP.OutStreamer->EmitIntValue(p[Chunk], sizeof(uint64_t));
  } else {
    unsigned Chunk;
    for (Chunk = 0; Chunk < NumBytes / sizeof(uint64_t); ++Chunk)
      AP.OutStreamer->EmitIntValue(p[Chunk], sizeof(uint64_t));

    if (TrailingBytes)
      AP.OutStreamer->EmitIntValue(p[Chunk], TrailingBytes);
  }

  // Emit the tail padding for the long double.
  const DataLayout &DL = AP.getDataLayout();
  AP.OutStreamer->EmitZeros(DL.getTypeAllocSize(CFP->getType()) -
                            DL.getTypeStoreSize(CFP->getType()));
}

static void emitGlobalConstantLargeInt(const ConstantInt *CI, AsmPrinter &AP) {
  const DataLayout &DL = AP.getDataLayout();
  unsigned BitWidth = CI->getBitWidth();

  // Copy the value as we may massage the layout for constants whose bit width
  // is not a multiple of 64-bits.
  APInt Realigned(CI->getValue());
  uint64_t ExtraBits = 0;
  unsigned ExtraBitsSize = BitWidth & 63;

  if (ExtraBitsSize) {
    // The bit width of the data is not a multiple of 64-bits.
    // The extra bits are expected to be at the end of the chunk of the memory.
    // Little endian:
    // * Nothing to be done, just record the extra bits to emit.
    // Big endian:
    // * Record the extra bits to emit.
    // * Realign the raw data to emit the chunks of 64-bits.
    if (DL.isBigEndian()) {
      // Basically the structure of the raw data is a chunk of 64-bits cells:
      //    0        1         BitWidth / 64
      // [chunk1][chunk2] ... [chunkN].
      // The most significant chunk is chunkN and it should be emitted first.
      // However, due to the alignment issue chunkN contains useless bits.
      // Realign the chunks so that they contain only useless information:
      // ExtraBits     0       1       (BitWidth / 64) - 1
      //       chu[nk1 chu][nk2 chu] ... [nkN-1 chunkN]
      ExtraBits = Realigned.getRawData()[0] &
        (((uint64_t)-1) >> (64 - ExtraBitsSize));
      Realigned = Realigned.lshr(ExtraBitsSize);
    } else
      ExtraBits = Realigned.getRawData()[BitWidth / 64];
  }

  // We don't expect assemblers to support integer data directives
  // for more than 64 bits, so we emit the data in at most 64-bit
  // quantities at a time.
  const uint64_t *RawData = Realigned.getRawData();
  for (unsigned i = 0, e = BitWidth / 64; i != e; ++i) {
    uint64_t Val = DL.isBigEndian() ? RawData[e - i - 1] : RawData[i];
    AP.OutStreamer->EmitIntValue(Val, 8);
  }

  if (ExtraBitsSize) {
    // Emit the extra bits after the 64-bits chunks.

    // Emit a directive that fills the expected size.
    uint64_t Size = AP.getDataLayout().getTypeAllocSize(CI->getType());
    Size -= (BitWidth / 64) * 8;
    assert(Size && Size * 8 >= ExtraBitsSize &&
           (ExtraBits & (((uint64_t)-1) >> (64 - ExtraBitsSize)))
           == ExtraBits && "Directive too small for extra bits.");
    AP.OutStreamer->EmitIntValue(ExtraBits, Size);
  }
}

/// \brief Transform a not absolute MCExpr containing a reference to a GOT
/// equivalent global, by a target specific GOT pc relative access to the
/// final symbol.
static void handleIndirectSymViaGOTPCRel(AsmPrinter &AP, const MCExpr **ME,
                                         const Constant *BaseCst,
                                         uint64_t Offset) {
  // The global @foo below illustrates a global that uses a got equivalent.
  //
  //  @bar = global i32 42
  //  @gotequiv = private unnamed_addr constant i32* @bar
  //  @foo = i32 trunc (i64 sub (i64 ptrtoint (i32** @gotequiv to i64),
  //                             i64 ptrtoint (i32* @foo to i64))
  //                        to i32)
  //
  // The cstexpr in @foo is converted into the MCExpr `ME`, where we actually
  // check whether @foo is suitable to use a GOTPCREL. `ME` is usually in the
  // form:
  //
  //  foo = cstexpr, where
  //    cstexpr := <gotequiv> - "." + <cst>
  //    cstexpr := <gotequiv> - (<foo> - <offset from @foo base>) + <cst>
  //
  // After canonicalization by evaluateAsRelocatable `ME` turns into:
  //
  //  cstexpr := <gotequiv> - <foo> + gotpcrelcst, where
  //    gotpcrelcst := <offset from @foo base> + <cst>
  //
  MCValue MV;
  if (!(*ME)->evaluateAsRelocatable(MV, nullptr, nullptr) || MV.isAbsolute())
    return;
  const MCSymbolRefExpr *SymA = MV.getSymA();
  if (!SymA)
    return;

  // Check that GOT equivalent symbol is cached.
  const MCSymbol *GOTEquivSym = &SymA->getSymbol();
  if (!AP.GlobalGOTEquivs.count(GOTEquivSym))
    return;

  const GlobalValue *BaseGV = dyn_cast_or_null<GlobalValue>(BaseCst);
  if (!BaseGV)
    return;

  // Check for a valid base symbol
  const MCSymbol *BaseSym = AP.getSymbol(BaseGV);
  const MCSymbolRefExpr *SymB = MV.getSymB();

  if (!SymB || BaseSym != &SymB->getSymbol())
    return;

  // Make sure to match:
  //
  //    gotpcrelcst := <offset from @foo base> + <cst>
  //
  // If gotpcrelcst is positive it means that we can safely fold the pc rel
  // displacement into the GOTPCREL. We can also can have an extra offset <cst>
  // if the target knows how to encode it.
  //
  int64_t GOTPCRelCst = Offset + MV.getConstant();
  if (GOTPCRelCst < 0)
    return;
  if (!AP.getObjFileLowering().supportGOTPCRelWithOffset() && GOTPCRelCst != 0)
    return;

  // Emit the GOT PC relative to replace the got equivalent global, i.e.:
  //
  //  bar:
  //    .long 42
  //  gotequiv:
  //    .quad bar
  //  foo:
  //    .long gotequiv - "." + <cst>
  //
  // is replaced by the target specific equivalent to:
  //
  //  bar:
  //    .long 42
  //  foo:
  //    .long bar@GOTPCREL+<gotpcrelcst>
  //
  AsmPrinter::GOTEquivUsePair Result = AP.GlobalGOTEquivs[GOTEquivSym];
  const GlobalVariable *GV = Result.first;
  int NumUses = (int)Result.second;
  const GlobalValue *FinalGV = dyn_cast<GlobalValue>(GV->getOperand(0));
  const MCSymbol *FinalSym = AP.getSymbol(FinalGV);
  *ME = AP.getObjFileLowering().getIndirectSymViaGOTPCRel(
      FinalSym, MV, Offset, AP.MMI, *AP.OutStreamer);

  // Update GOT equivalent usage information
  --NumUses;
  if (NumUses >= 0)
    AP.GlobalGOTEquivs[GOTEquivSym] = std::make_pair(GV, NumUses);
}

static void emitGlobalConstantImpl(const DataLayout &DL, const Constant *CV,
                                   AsmPrinter &AP, const Constant *BaseCV,
                                   uint64_t Offset) {
  uint64_t Size = DL.getTypeAllocSize(CV->getType());

  // Globals with sub-elements such as combinations of arrays and structs
  // are handled recursively by emitGlobalConstantImpl. Keep track of the
  // constant symbol base and the current position with BaseCV and Offset.
  if (!BaseCV && CV->hasOneUse())
    BaseCV = dyn_cast<Constant>(CV->user_back());

  if (isa<ConstantAggregateZero>(CV) || isa<UndefValue>(CV))
    return AP.OutStreamer->EmitZeros(Size);

  if (const ConstantInt *CI = dyn_cast<ConstantInt>(CV)) {
    switch (Size) {
    case 1:
    case 2:
    case 4:
    case 8:
      if (AP.isVerbose())
        AP.OutStreamer->GetCommentOS() << format("0x%" PRIx64 "\n",
                                                 CI->getZExtValue());
      AP.OutStreamer->EmitIntValue(CI->getZExtValue(), Size);
      return;
    default:
      emitGlobalConstantLargeInt(CI, AP);
      return;
    }
  }

  if (const ConstantFP *CFP = dyn_cast<ConstantFP>(CV))
    return emitGlobalConstantFP(CFP, AP);

  if (isa<ConstantPointerNull>(CV)) {
    AP.OutStreamer->EmitIntValue(0, Size);
    return;
  }

  if (const ConstantDataSequential *CDS = dyn_cast<ConstantDataSequential>(CV))
    return emitGlobalConstantDataSequential(DL, CDS, AP);

  if (const ConstantArray *CVA = dyn_cast<ConstantArray>(CV))
    return emitGlobalConstantArray(DL, CVA, AP, BaseCV, Offset);

  if (const ConstantStruct *CVS = dyn_cast<ConstantStruct>(CV))
    return emitGlobalConstantStruct(DL, CVS, AP, BaseCV, Offset);

  if (const ConstantExpr *CE = dyn_cast<ConstantExpr>(CV)) {
    // Look through bitcasts, which might not be able to be MCExpr'ized (e.g. of
    // vectors).
    if (CE->getOpcode() == Instruction::BitCast)
      return emitGlobalConstantImpl(DL, CE->getOperand(0), AP);

    if (Size > 8) {
      // If the constant expression's size is greater than 64-bits, then we have
      // to emit the value in chunks. Try to constant fold the value and emit it
      // that way.
      Constant *New = ConstantFoldConstant(CE, DL);
      if (New && New != CE)
        return emitGlobalConstantImpl(DL, New, AP);
    }
  }

  if (const ConstantVector *V = dyn_cast<ConstantVector>(CV))
    return emitGlobalConstantVector(DL, V, AP);

  // Otherwise, it must be a ConstantExpr.  Lower it to an MCExpr, then emit it
  // thread the streamer with EmitValue.
  const MCExpr *ME = AP.lowerConstant(CV);

  // Since lowerConstant already folded and got rid of all IR pointer and
  // integer casts, detect GOT equivalent accesses by looking into the MCExpr
  // directly.
  if (AP.getObjFileLowering().supportIndirectSymViaGOTPCRel())
    handleIndirectSymViaGOTPCRel(AP, &ME, BaseCV, Offset);

  AP.OutStreamer->EmitValue(ME, Size);
}

/// EmitGlobalConstant - Print a general LLVM constant to the .s file.
void AsmPrinter::EmitGlobalConstant(const DataLayout &DL, const Constant *CV) {
  uint64_t Size = DL.getTypeAllocSize(CV->getType());
  if (Size)
    emitGlobalConstantImpl(DL, CV, *this);
  else if (MAI->hasSubsectionsViaSymbols()) {
    // If the global has zero size, emit a single byte so that two labels don't
    // look like they are at the same location.
    OutStreamer->EmitIntValue(0, 1);
  }
}

void AsmPrinter::EmitMachineConstantPoolValue(MachineConstantPoolValue *MCPV) {
  // Target doesn't support this yet!
  llvm_unreachable("Target does not support EmitMachineConstantPoolValue");
}

void AsmPrinter::printOffset(int64_t Offset, raw_ostream &OS) const {
  if (Offset > 0)
    OS << '+' << Offset;
  else if (Offset < 0)
    OS << Offset;
}

//===----------------------------------------------------------------------===//
// Symbol Lowering Routines.
//===----------------------------------------------------------------------===//

MCSymbol *AsmPrinter::createTempSymbol(const Twine &Name) const {
  return OutContext.createTempSymbol(Name, true);
}

MCSymbol *AsmPrinter::GetBlockAddressSymbol(const BlockAddress *BA) const {
  return MMI->getAddrLabelSymbol(BA->getBasicBlock());
}

MCSymbol *AsmPrinter::GetBlockAddressSymbol(const BasicBlock *BB) const {
  return MMI->getAddrLabelSymbol(BB);
}

/// GetCPISymbol - Return the symbol for the specified constant pool entry.
MCSymbol *AsmPrinter::GetCPISymbol(unsigned CPID) const {
  const DataLayout &DL = getDataLayout();
  return OutContext.getOrCreateSymbol(Twine(DL.getPrivateGlobalPrefix()) +
                                      "CPI" + Twine(getFunctionNumber()) + "_" +
                                      Twine(CPID));
}

/// GetJTISymbol - Return the symbol for the specified jump table entry.
MCSymbol *AsmPrinter::GetJTISymbol(unsigned JTID, bool isLinkerPrivate) const {
  return MF->getJTISymbol(JTID, OutContext, isLinkerPrivate);
}

/// GetJTSetSymbol - Return the symbol for the specified jump table .set
/// FIXME: privatize to AsmPrinter.
MCSymbol *AsmPrinter::GetJTSetSymbol(unsigned UID, unsigned MBBID) const {
  const DataLayout &DL = getDataLayout();
  return OutContext.getOrCreateSymbol(Twine(DL.getPrivateGlobalPrefix()) +
                                      Twine(getFunctionNumber()) + "_" +
                                      Twine(UID) + "_set_" + Twine(MBBID));
}

MCSymbol *AsmPrinter::getSymbolWithGlobalValueBase(const GlobalValue *GV,
                                                   StringRef Suffix) const {
  return getObjFileLowering().getSymbolWithGlobalValueBase(GV, Suffix, *Mang,
                                                           TM);
}

/// Return the MCSymbol for the specified ExternalSymbol.
MCSymbol *AsmPrinter::GetExternalSymbolSymbol(StringRef Sym) const {
  SmallString<60> NameStr;
  Mangler::getNameWithPrefix(NameStr, Sym, getDataLayout());
  return OutContext.getOrCreateSymbol(NameStr);
}



/// PrintParentLoopComment - Print comments about parent loops of this one.
static void PrintParentLoopComment(raw_ostream &OS, const MachineLoop *Loop,
                                   unsigned FunctionNumber) {
  if (!Loop) return;
  PrintParentLoopComment(OS, Loop->getParentLoop(), FunctionNumber);
  OS.indent(Loop->getLoopDepth()*2)
    << "Parent Loop BB" << FunctionNumber << "_"
    << Loop->getHeader()->getNumber()
    << " Depth=" << Loop->getLoopDepth() << '\n';
}


/// PrintChildLoopComment - Print comments about child loops within
/// the loop for this basic block, with nesting.
static void PrintChildLoopComment(raw_ostream &OS, const MachineLoop *Loop,
                                  unsigned FunctionNumber) {
  // Add child loop information
  for (const MachineLoop *CL : *Loop) {
    OS.indent(CL->getLoopDepth()*2)
      << "Child Loop BB" << FunctionNumber << "_"
      << CL->getHeader()->getNumber() << " Depth " << CL->getLoopDepth()
      << '\n';
    PrintChildLoopComment(OS, CL, FunctionNumber);
  }
}

/// emitBasicBlockLoopComments - Pretty-print comments for basic blocks.
static void emitBasicBlockLoopComments(const MachineBasicBlock &MBB,
                                       const MachineLoopInfo *LI,
                                       const AsmPrinter &AP) {
  // Add loop depth information
  const MachineLoop *Loop = LI->getLoopFor(&MBB);
  if (!Loop) return;

  MachineBasicBlock *Header = Loop->getHeader();
  assert(Header && "No header for loop");

  // If this block is not a loop header, just print out what is the loop header
  // and return.
  if (Header != &MBB) {
    AP.OutStreamer->AddComment("  in Loop: Header=BB" +
                               Twine(AP.getFunctionNumber())+"_" +
                               Twine(Loop->getHeader()->getNumber())+
                               " Depth="+Twine(Loop->getLoopDepth()));
    return;
  }

  // Otherwise, it is a loop header.  Print out information about child and
  // parent loops.
  raw_ostream &OS = AP.OutStreamer->GetCommentOS();

  PrintParentLoopComment(OS, Loop->getParentLoop(), AP.getFunctionNumber());

  OS << "=>";
  OS.indent(Loop->getLoopDepth()*2-2);

  OS << "This ";
  if (Loop->empty())
    OS << "Inner ";
  OS << "Loop Header: Depth=" + Twine(Loop->getLoopDepth()) << '\n';

  PrintChildLoopComment(OS, Loop, AP.getFunctionNumber());
}


/// EmitBasicBlockStart - This method prints the label for the specified
/// MachineBasicBlock, an alignment (if present) and a comment describing
/// it if appropriate.
void AsmPrinter::EmitBasicBlockStart(const MachineBasicBlock &MBB) const {
  // End the previous funclet and start a new one.
  if (MBB.isEHFuncletEntry()) {
    for (const HandlerInfo &HI : Handlers) {
      HI.Handler->endFunclet();
      HI.Handler->beginFunclet(MBB);
    }
  }

  // Emit an alignment directive for this block, if needed.
  if (unsigned Align = MBB.getAlignment())
    EmitAlignment(Align);

  // If the block has its address taken, emit any labels that were used to
  // reference the block.  It is possible that there is more than one label
  // here, because multiple LLVM BB's may have been RAUW'd to this block after
  // the references were generated.
  if (MBB.hasAddressTaken()) {
    const BasicBlock *BB = MBB.getBasicBlock();
    if (isVerbose())
      OutStreamer->AddComment("Block address taken");

    // MBBs can have their address taken as part of CodeGen without having
    // their corresponding BB's address taken in IR
    if (BB->hasAddressTaken())
      for (MCSymbol *Sym : MMI->getAddrLabelSymbolToEmit(BB))
        OutStreamer->EmitLabel(Sym);
  }

  // Print some verbose block comments.
  if (isVerbose()) {
    if (const BasicBlock *BB = MBB.getBasicBlock()) {
      if (BB->hasName()) {
        BB->printAsOperand(OutStreamer->GetCommentOS(),
                           /*PrintType=*/false, BB->getModule());
        OutStreamer->GetCommentOS() << '\n';
      }
    }
    emitBasicBlockLoopComments(MBB, LI, *this);
  }

  // Print the main label for the block.
  if (MBB.pred_empty() ||
      (isBlockOnlyReachableByFallthrough(&MBB) && !MBB.isEHFuncletEntry())) {
    if (isVerbose()) {
      // NOTE: Want this comment at start of line, don't emit with AddComment.
      OutStreamer->emitRawComment(" BB#" + Twine(MBB.getNumber()) + ":", false);
    }
  } else {
    OutStreamer->EmitLabel(MBB.getSymbol());
  }
}

void AsmPrinter::EmitVisibility(MCSymbol *Sym, unsigned Visibility,
                                bool IsDefinition) const {
  MCSymbolAttr Attr = MCSA_Invalid;

  switch (Visibility) {
  default: break;
  case GlobalValue::HiddenVisibility:
    if (IsDefinition)
      Attr = MAI->getHiddenVisibilityAttr();
    else
      Attr = MAI->getHiddenDeclarationVisibilityAttr();
    break;
  case GlobalValue::ProtectedVisibility:
    Attr = MAI->getProtectedVisibilityAttr();
    break;
  }

  if (Attr != MCSA_Invalid)
    OutStreamer->EmitSymbolAttribute(Sym, Attr);
}

/// isBlockOnlyReachableByFallthough - Return true if the basic block has
/// exactly one predecessor and the control transfer mechanism between
/// the predecessor and this block is a fall-through.
bool AsmPrinter::
isBlockOnlyReachableByFallthrough(const MachineBasicBlock *MBB) const {
  // If this is a landing pad, it isn't a fall through.  If it has no preds,
  // then nothing falls through to it.
  if (MBB->isEHPad() || MBB->pred_empty())
    return false;

  // If there isn't exactly one predecessor, it can't be a fall through.
  if (MBB->pred_size() > 1)
    return false;

  // The predecessor has to be immediately before this block.
  MachineBasicBlock *Pred = *MBB->pred_begin();
  if (!Pred->isLayoutSuccessor(MBB))
    return false;

  // If the block is completely empty, then it definitely does fall through.
  if (Pred->empty())
    return true;

  // Check the terminators in the previous blocks
  for (const auto &MI : Pred->terminators()) {
    // If it is not a simple branch, we are in a table somewhere.
    if (!MI.isBranch() || MI.isIndirectBranch())
      return false;

    // If we are the operands of one of the branches, this is not a fall
    // through. Note that targets with delay slots will usually bundle
    // terminators with the delay slot instruction.
    for (ConstMIBundleOperands OP(MI); OP.isValid(); ++OP) {
      if (OP->isJTI())
        return false;
      if (OP->isMBB() && OP->getMBB() == MBB)
        return false;
    }
  }

  return true;
}



GCMetadataPrinter *AsmPrinter::GetOrCreateGCPrinter(GCStrategy &S) {
  if (!S.usesMetadata())
    return nullptr;

  assert(!S.useStatepoints() && "statepoints do not currently support custom"
         " stackmap formats, please see the documentation for a description of"
         " the default format.  If you really need a custom serialized format,"
         " please file a bug");

  gcp_map_type &GCMap = getGCMap(GCMetadataPrinters);
  gcp_map_type::iterator GCPI = GCMap.find(&S);
  if (GCPI != GCMap.end())
    return GCPI->second.get();

  const char *Name = S.getName().c_str();

  for (GCMetadataPrinterRegistry::iterator
         I = GCMetadataPrinterRegistry::begin(),
         E = GCMetadataPrinterRegistry::end(); I != E; ++I)
    if (strcmp(Name, I->getName()) == 0) {
      std::unique_ptr<GCMetadataPrinter> GMP = I->instantiate();
      GMP->S = &S;
      auto IterBool = GCMap.insert(std::make_pair(&S, std::move(GMP)));
      return IterBool.first->second.get();
    }

  report_fatal_error("no GCMetadataPrinter registered for GC: " + Twine(Name));
}

/// Pin vtable to this file.
AsmPrinterHandler::~AsmPrinterHandler() {}

void AsmPrinterHandler::markFunctionEnd() {}
