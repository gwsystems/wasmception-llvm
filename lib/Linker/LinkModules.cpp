//===- lib/Linker/LinkModules.cpp - Module Linker Implementation ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the LLVM module linker.
//
//===----------------------------------------------------------------------===//

#include "LinkDiagnosticInfo.h"
#include "llvm-c/Linker.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Transforms/Utils/FunctionImportUtils.h"
using namespace llvm;

namespace {

/// This is an implementation class for the LinkModules function, which is the
/// entrypoint for this file.
class ModuleLinker {
  IRMover &Mover;
  std::unique_ptr<Module> SrcM;

  SetVector<GlobalValue *> ValuesToLink;
  StringSet<> Internalize;

  /// For symbol clashes, prefer those from Src.
  unsigned Flags;

  /// Module summary index passed into ModuleLinker for using in function
  /// importing/exporting handling.
  const ModuleSummaryIndex *ImportIndex;

  /// Functions to import from source module, all other functions are
  /// imported as declarations instead of definitions.
  DenseSet<const GlobalValue *> *FunctionsToImport;

  /// Set to true if the given ModuleSummaryIndex contains any functions
  /// from this source module, in which case we must conservatively assume
  /// that any of its functions may be imported into another module
  /// as part of a different backend compilation process.
  bool HasExportedFunctions = false;

  /// Association between metadata value id and temporary metadata that
  /// remains unmapped after function importing. Saved during function
  /// importing and consumed during the metadata linking postpass.
  DenseMap<unsigned, MDNode *> *ValIDToTempMDMap;

  /// Used as the callback for lazy linking.
  /// The mover has just hit GV and we have to decide if it, and other members
  /// of the same comdat, should be linked. Every member to be linked is passed
  /// to Add.
  void addLazyFor(GlobalValue &GV, IRMover::ValueAdder Add);

  bool shouldOverrideFromSrc() { return Flags & Linker::OverrideFromSrc; }
  bool shouldLinkOnlyNeeded() { return Flags & Linker::LinkOnlyNeeded; }
  bool shouldInternalizeLinkedSymbols() {
    return Flags & Linker::InternalizeLinkedSymbols;
  }

  bool shouldLinkFromSource(bool &LinkFromSrc, const GlobalValue &Dest,
                            const GlobalValue &Src);

  /// Should we have mover and linker error diag info?
  bool emitError(const Twine &Message) {
    SrcM->getContext().diagnose(LinkDiagnosticInfo(DS_Error, Message));
    return true;
  }

  bool getComdatLeader(Module &M, StringRef ComdatName,
                       const GlobalVariable *&GVar);
  bool computeResultingSelectionKind(StringRef ComdatName,
                                     Comdat::SelectionKind Src,
                                     Comdat::SelectionKind Dst,
                                     Comdat::SelectionKind &Result,
                                     bool &LinkFromSrc);
  std::map<const Comdat *, std::pair<Comdat::SelectionKind, bool>>
      ComdatsChosen;
  bool getComdatResult(const Comdat *SrcC, Comdat::SelectionKind &SK,
                       bool &LinkFromSrc);
  // Keep track of the global value members of each comdat in source.
  DenseMap<const Comdat *, std::vector<GlobalValue *>> ComdatMembers;

  /// Given a global in the source module, return the global in the
  /// destination module that is being linked to, if any.
  GlobalValue *getLinkedToGlobal(const GlobalValue *SrcGV) {
    Module &DstM = Mover.getModule();
    // If the source has no name it can't link.  If it has local linkage,
    // there is no name match-up going on.
    if (!SrcGV->hasName() || GlobalValue::isLocalLinkage(SrcGV->getLinkage()))
      return nullptr;

    // Otherwise see if we have a match in the destination module's symtab.
    GlobalValue *DGV = DstM.getNamedValue(SrcGV->getName());
    if (!DGV)
      return nullptr;

    // If we found a global with the same name in the dest module, but it has
    // internal linkage, we are really not doing any linkage here.
    if (DGV->hasLocalLinkage())
      return nullptr;

    // Otherwise, we do in fact link to the destination global.
    return DGV;
  }

  bool linkIfNeeded(GlobalValue &GV);

  /// Helper method to check if we are importing from the current source
  /// module.
  bool isPerformingImport() const { return FunctionsToImport != nullptr; }

  /// If we are importing from the source module, checks if we should
  /// import SGV as a definition, otherwise import as a declaration.
  bool doImportAsDefinition(const GlobalValue *SGV);

public:
  ModuleLinker(IRMover &Mover, std::unique_ptr<Module> SrcM, unsigned Flags,
               const ModuleSummaryIndex *Index = nullptr,
               DenseSet<const GlobalValue *> *FunctionsToImport = nullptr,
               DenseMap<unsigned, MDNode *> *ValIDToTempMDMap = nullptr)
      : Mover(Mover), SrcM(std::move(SrcM)), Flags(Flags), ImportIndex(Index),
        FunctionsToImport(FunctionsToImport),
        ValIDToTempMDMap(ValIDToTempMDMap) {
    assert((ImportIndex || !FunctionsToImport) &&
           "Expect a ModuleSummaryIndex when importing");
    // If we have a ModuleSummaryIndex but no function to import,
    // then this is the primary module being compiled in a ThinLTO
    // backend compilation, and we need to see if it has functions that
    // may be exported to another backend compilation.
    if (ImportIndex && !FunctionsToImport)
      HasExportedFunctions = ImportIndex->hasExportedFunctions(*this->SrcM);
  }

  bool run();
};
}

bool ModuleLinker::doImportAsDefinition(const GlobalValue *SGV) {
  if (!isPerformingImport())
    return false;
  return FunctionImportGlobalProcessing::doImportAsDefinition(
      SGV, FunctionsToImport);
}

static GlobalValue::VisibilityTypes
getMinVisibility(GlobalValue::VisibilityTypes A,
                 GlobalValue::VisibilityTypes B) {
  if (A == GlobalValue::HiddenVisibility || B == GlobalValue::HiddenVisibility)
    return GlobalValue::HiddenVisibility;
  if (A == GlobalValue::ProtectedVisibility ||
      B == GlobalValue::ProtectedVisibility)
    return GlobalValue::ProtectedVisibility;
  return GlobalValue::DefaultVisibility;
}

bool ModuleLinker::getComdatLeader(Module &M, StringRef ComdatName,
                                   const GlobalVariable *&GVar) {
  const GlobalValue *GVal = M.getNamedValue(ComdatName);
  if (const auto *GA = dyn_cast_or_null<GlobalAlias>(GVal)) {
    GVal = GA->getBaseObject();
    if (!GVal)
      // We cannot resolve the size of the aliasee yet.
      return emitError("Linking COMDATs named '" + ComdatName +
                       "': COMDAT key involves incomputable alias size.");
  }

  GVar = dyn_cast_or_null<GlobalVariable>(GVal);
  if (!GVar)
    return emitError(
        "Linking COMDATs named '" + ComdatName +
        "': GlobalVariable required for data dependent selection!");

  return false;
}

bool ModuleLinker::computeResultingSelectionKind(StringRef ComdatName,
                                                 Comdat::SelectionKind Src,
                                                 Comdat::SelectionKind Dst,
                                                 Comdat::SelectionKind &Result,
                                                 bool &LinkFromSrc) {
  Module &DstM = Mover.getModule();
  // The ability to mix Comdat::SelectionKind::Any with
  // Comdat::SelectionKind::Largest is a behavior that comes from COFF.
  bool DstAnyOrLargest = Dst == Comdat::SelectionKind::Any ||
                         Dst == Comdat::SelectionKind::Largest;
  bool SrcAnyOrLargest = Src == Comdat::SelectionKind::Any ||
                         Src == Comdat::SelectionKind::Largest;
  if (DstAnyOrLargest && SrcAnyOrLargest) {
    if (Dst == Comdat::SelectionKind::Largest ||
        Src == Comdat::SelectionKind::Largest)
      Result = Comdat::SelectionKind::Largest;
    else
      Result = Comdat::SelectionKind::Any;
  } else if (Src == Dst) {
    Result = Dst;
  } else {
    return emitError("Linking COMDATs named '" + ComdatName +
                     "': invalid selection kinds!");
  }

  switch (Result) {
  case Comdat::SelectionKind::Any:
    // Go with Dst.
    LinkFromSrc = false;
    break;
  case Comdat::SelectionKind::NoDuplicates:
    return emitError("Linking COMDATs named '" + ComdatName +
                     "': noduplicates has been violated!");
  case Comdat::SelectionKind::ExactMatch:
  case Comdat::SelectionKind::Largest:
  case Comdat::SelectionKind::SameSize: {
    const GlobalVariable *DstGV;
    const GlobalVariable *SrcGV;
    if (getComdatLeader(DstM, ComdatName, DstGV) ||
        getComdatLeader(*SrcM, ComdatName, SrcGV))
      return true;

    const DataLayout &DstDL = DstM.getDataLayout();
    const DataLayout &SrcDL = SrcM->getDataLayout();
    uint64_t DstSize = DstDL.getTypeAllocSize(DstGV->getValueType());
    uint64_t SrcSize = SrcDL.getTypeAllocSize(SrcGV->getValueType());
    if (Result == Comdat::SelectionKind::ExactMatch) {
      if (SrcGV->getInitializer() != DstGV->getInitializer())
        return emitError("Linking COMDATs named '" + ComdatName +
                         "': ExactMatch violated!");
      LinkFromSrc = false;
    } else if (Result == Comdat::SelectionKind::Largest) {
      LinkFromSrc = SrcSize > DstSize;
    } else if (Result == Comdat::SelectionKind::SameSize) {
      if (SrcSize != DstSize)
        return emitError("Linking COMDATs named '" + ComdatName +
                         "': SameSize violated!");
      LinkFromSrc = false;
    } else {
      llvm_unreachable("unknown selection kind");
    }
    break;
  }
  }

  return false;
}

bool ModuleLinker::getComdatResult(const Comdat *SrcC,
                                   Comdat::SelectionKind &Result,
                                   bool &LinkFromSrc) {
  Module &DstM = Mover.getModule();
  Comdat::SelectionKind SSK = SrcC->getSelectionKind();
  StringRef ComdatName = SrcC->getName();
  Module::ComdatSymTabType &ComdatSymTab = DstM.getComdatSymbolTable();
  Module::ComdatSymTabType::iterator DstCI = ComdatSymTab.find(ComdatName);

  if (DstCI == ComdatSymTab.end()) {
    // Use the comdat if it is only available in one of the modules.
    LinkFromSrc = true;
    Result = SSK;
    return false;
  }

  const Comdat *DstC = &DstCI->second;
  Comdat::SelectionKind DSK = DstC->getSelectionKind();
  return computeResultingSelectionKind(ComdatName, SSK, DSK, Result,
                                       LinkFromSrc);
}

bool ModuleLinker::shouldLinkFromSource(bool &LinkFromSrc,
                                        const GlobalValue &Dest,
                                        const GlobalValue &Src) {

  // Should we unconditionally use the Src?
  if (shouldOverrideFromSrc()) {
    LinkFromSrc = true;
    return false;
  }

  // We always have to add Src if it has appending linkage.
  if (Src.hasAppendingLinkage()) {
    // Should have prevented importing for appending linkage in linkIfNeeded.
    assert(!isPerformingImport());
    LinkFromSrc = true;
    return false;
  }

  bool SrcIsDeclaration = Src.isDeclarationForLinker();
  bool DestIsDeclaration = Dest.isDeclarationForLinker();

  if (isPerformingImport()) {
    if (isa<Function>(&Src)) {
      // For functions, LinkFromSrc iff this is a function requested
      // for importing. For variables, decide below normally.
      LinkFromSrc = FunctionsToImport->count(&Src);
      return false;
    }

    // Check if this is an alias with an already existing definition
    // in Dest, which must have come from a prior importing pass from
    // the same Src module. Unlike imported function and variable
    // definitions, which are imported as available_externally and are
    // not definitions for the linker, that is not a valid linkage for
    // imported aliases which must be definitions. Simply use the existing
    // Dest copy.
    if (isa<GlobalAlias>(&Src) && !DestIsDeclaration) {
      assert(isa<GlobalAlias>(&Dest));
      LinkFromSrc = false;
      return false;
    }
  }

  if (SrcIsDeclaration) {
    // If Src is external or if both Src & Dest are external..  Just link the
    // external globals, we aren't adding anything.
    if (Src.hasDLLImportStorageClass()) {
      // If one of GVs is marked as DLLImport, result should be dllimport'ed.
      LinkFromSrc = DestIsDeclaration;
      return false;
    }
    // If the Dest is weak, use the source linkage.
    if (Dest.hasExternalWeakLinkage()) {
      LinkFromSrc = true;
      return false;
    }
    // Link an available_externally over a declaration.
    LinkFromSrc = !Src.isDeclaration() && Dest.isDeclaration();
    return false;
  }

  if (DestIsDeclaration) {
    // If Dest is external but Src is not:
    LinkFromSrc = true;
    return false;
  }

  if (Src.hasCommonLinkage()) {
    if (Dest.hasLinkOnceLinkage() || Dest.hasWeakLinkage()) {
      LinkFromSrc = true;
      return false;
    }

    if (!Dest.hasCommonLinkage()) {
      LinkFromSrc = false;
      return false;
    }

    const DataLayout &DL = Dest.getParent()->getDataLayout();
    uint64_t DestSize = DL.getTypeAllocSize(Dest.getValueType());
    uint64_t SrcSize = DL.getTypeAllocSize(Src.getValueType());
    LinkFromSrc = SrcSize > DestSize;
    return false;
  }

  if (Src.isWeakForLinker()) {
    assert(!Dest.hasExternalWeakLinkage());
    assert(!Dest.hasAvailableExternallyLinkage());

    if (Dest.hasLinkOnceLinkage() && Src.hasWeakLinkage()) {
      LinkFromSrc = true;
      return false;
    }

    LinkFromSrc = false;
    return false;
  }

  if (Dest.isWeakForLinker()) {
    assert(Src.hasExternalLinkage());
    LinkFromSrc = true;
    return false;
  }

  assert(!Src.hasExternalWeakLinkage());
  assert(!Dest.hasExternalWeakLinkage());
  assert(Dest.hasExternalLinkage() && Src.hasExternalLinkage() &&
         "Unexpected linkage type!");
  return emitError("Linking globals named '" + Src.getName() +
                   "': symbol multiply defined!");
}

bool ModuleLinker::linkIfNeeded(GlobalValue &GV) {
  GlobalValue *DGV = getLinkedToGlobal(&GV);

  if (shouldLinkOnlyNeeded() && !(DGV && DGV->isDeclaration()))
    return false;

  if (DGV && !GV.hasLocalLinkage() && !GV.hasAppendingLinkage()) {
    auto *DGVar = dyn_cast<GlobalVariable>(DGV);
    auto *SGVar = dyn_cast<GlobalVariable>(&GV);
    if (DGVar && SGVar) {
      if (DGVar->isDeclaration() && SGVar->isDeclaration() &&
          (!DGVar->isConstant() || !SGVar->isConstant())) {
        DGVar->setConstant(false);
        SGVar->setConstant(false);
      }
      if (DGVar->hasCommonLinkage() && SGVar->hasCommonLinkage()) {
        unsigned Align = std::max(DGVar->getAlignment(), SGVar->getAlignment());
        SGVar->setAlignment(Align);
        DGVar->setAlignment(Align);
      }
    }

    GlobalValue::VisibilityTypes Visibility =
        getMinVisibility(DGV->getVisibility(), GV.getVisibility());
    DGV->setVisibility(Visibility);
    GV.setVisibility(Visibility);

    bool HasUnnamedAddr = GV.hasUnnamedAddr() && DGV->hasUnnamedAddr();
    DGV->setUnnamedAddr(HasUnnamedAddr);
    GV.setUnnamedAddr(HasUnnamedAddr);
  }

  // Don't want to append to global_ctors list, for example, when we
  // are importing for ThinLTO, otherwise the global ctors and dtors
  // get executed multiple times for local variables (the latter causing
  // double frees).
  if (GV.hasAppendingLinkage() && isPerformingImport())
    return false;

  if (isPerformingImport() && !doImportAsDefinition(&GV))
    return false;

  if (!DGV && !shouldOverrideFromSrc() &&
      (GV.hasLocalLinkage() || GV.hasLinkOnceLinkage() ||
       GV.hasAvailableExternallyLinkage()))
    return false;

  if (GV.isDeclaration())
    return false;

  if (const Comdat *SC = GV.getComdat()) {
    bool LinkFromSrc;
    Comdat::SelectionKind SK;
    std::tie(SK, LinkFromSrc) = ComdatsChosen[SC];
    if (LinkFromSrc)
      ValuesToLink.insert(&GV);
    return false;
  }

  bool LinkFromSrc = true;
  if (DGV && shouldLinkFromSource(LinkFromSrc, *DGV, GV))
    return true;
  if (LinkFromSrc)
    ValuesToLink.insert(&GV);
  return false;
}

void ModuleLinker::addLazyFor(GlobalValue &GV, IRMover::ValueAdder Add) {
  // Add these to the internalize list
  if (!GV.hasLinkOnceLinkage())
    return;

  if (shouldInternalizeLinkedSymbols())
    Internalize.insert(GV.getName());
  Add(GV);

  const Comdat *SC = GV.getComdat();
  if (!SC)
    return;
  for (GlobalValue *GV2 : ComdatMembers[SC]) {
    if (!GV2->hasLocalLinkage() && shouldInternalizeLinkedSymbols())
      Internalize.insert(GV2->getName());
    Add(*GV2);
  }
}

bool ModuleLinker::run() {
  for (const auto &SMEC : SrcM->getComdatSymbolTable()) {
    const Comdat &C = SMEC.getValue();
    if (ComdatsChosen.count(&C))
      continue;
    Comdat::SelectionKind SK;
    bool LinkFromSrc;
    if (getComdatResult(&C, SK, LinkFromSrc))
      return true;
    ComdatsChosen[&C] = std::make_pair(SK, LinkFromSrc);
  }

  for (GlobalVariable &GV : SrcM->globals())
    if (const Comdat *SC = GV.getComdat())
      ComdatMembers[SC].push_back(&GV);

  for (Function &SF : *SrcM)
    if (const Comdat *SC = SF.getComdat())
      ComdatMembers[SC].push_back(&SF);

  for (GlobalAlias &GA : SrcM->aliases())
    if (const Comdat *SC = GA.getComdat())
      ComdatMembers[SC].push_back(&GA);

  // Insert all of the globals in src into the DstM module... without linking
  // initializers (which could refer to functions not yet mapped over).
  for (GlobalVariable &GV : SrcM->globals())
    if (linkIfNeeded(GV))
      return true;

  for (Function &SF : *SrcM)
    if (linkIfNeeded(SF))
      return true;

  for (GlobalAlias &GA : SrcM->aliases())
    if (linkIfNeeded(GA))
      return true;

  if (ImportIndex) {
    FunctionImportGlobalProcessing ThinLTOProcessing(*SrcM, *ImportIndex,
                                                     FunctionsToImport);
    if (ThinLTOProcessing.run())
      return true;
    for (auto *GV : ThinLTOProcessing.getNewExportedValues())
      ValuesToLink.insert(GV);
  }

  for (unsigned I = 0; I < ValuesToLink.size(); ++I) {
    GlobalValue *GV = ValuesToLink[I];
    const Comdat *SC = GV->getComdat();
    if (!SC)
      continue;
    for (GlobalValue *GV2 : ComdatMembers[SC])
      ValuesToLink.insert(GV2);
  }

  if (shouldInternalizeLinkedSymbols()) {
    for (GlobalValue *GV : ValuesToLink)
      Internalize.insert(GV->getName());
  }

  if (Mover.move(std::move(SrcM), ValuesToLink.getArrayRef(),
                 [this](GlobalValue &GV, IRMover::ValueAdder Add) {
                   addLazyFor(GV, Add);
                 },
                 ValIDToTempMDMap, false))
    return true;
  Module &DstM = Mover.getModule();
  for (auto &P : Internalize) {
    GlobalValue *GV = DstM.getNamedValue(P.first());
    GV->setLinkage(GlobalValue::InternalLinkage);
  }

  return false;
}

Linker::Linker(Module &M) : Mover(M) {}

bool Linker::linkInModule(std::unique_ptr<Module> Src, unsigned Flags,
                          const ModuleSummaryIndex *Index,
                          DenseSet<const GlobalValue *> *FunctionsToImport,
                          DenseMap<unsigned, MDNode *> *ValIDToTempMDMap) {
  ModuleLinker ModLinker(Mover, std::move(Src), Flags, Index, FunctionsToImport,
                         ValIDToTempMDMap);
  return ModLinker.run();
}

bool Linker::linkInMetadata(std::unique_ptr<Module> Src,
                            DenseMap<unsigned, MDNode *> *ValIDToTempMDMap) {
  SetVector<GlobalValue *> ValuesToLink;
  if (Mover.move(
          std::move(Src), ValuesToLink.getArrayRef(),
          [this](GlobalValue &GV, IRMover::ValueAdder Add) { assert(false); },
          ValIDToTempMDMap, true))
    return true;
  return false;
}

//===----------------------------------------------------------------------===//
// LinkModules entrypoint.
//===----------------------------------------------------------------------===//

/// This function links two modules together, with the resulting Dest module
/// modified to be the composite of the two input modules. If an error occurs,
/// true is returned and ErrorMsg (if not null) is set to indicate the problem.
/// Upon failure, the Dest module could be in a modified state, and shouldn't be
/// relied on to be consistent.
bool Linker::linkModules(Module &Dest, std::unique_ptr<Module> Src,
                         unsigned Flags) {
  Linker L(Dest);
  return L.linkInModule(std::move(Src), Flags);
}

//===----------------------------------------------------------------------===//
// C API.
//===----------------------------------------------------------------------===//

LLVMBool LLVMLinkModules2(LLVMModuleRef Dest, LLVMModuleRef Src) {
  Module *D = unwrap(Dest);
  std::unique_ptr<Module> M(unwrap(Src));
  return Linker::linkModules(*D, std::move(M));
}
