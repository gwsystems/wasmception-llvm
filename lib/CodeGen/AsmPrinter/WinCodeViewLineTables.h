//===-- llvm/lib/CodeGen/AsmPrinter/WinCodeViewLineTables.h ----*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains support for writing line tables info into COFF files.
//
//===----------------------------------------------------------------------===//

#ifndef CODEGEN_ASMPRINTER_WINCODEVIEWLINETABLES_H__
#define CODEGEN_ASMPRINTER_WINCODEVIEWLINETABLES_H__

#include "AsmPrinterHandler.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/DebugInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/LexicalScopes.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/DebugLoc.h"
#include "llvm/Target/TargetLoweringObjectFile.h"

namespace llvm {
/// \brief Collects and handles line tables information in a CodeView format.
class WinCodeViewLineTables : public AsmPrinterHandler {
  AsmPrinter *Asm;
  DebugLoc PrevInstLoc;
  LexicalScopes LScopes;

  // For each function, store a vector of labels to its instructions, as well as
  // to the end of the function.
  struct FunctionInfo {
    SmallVector<MCSymbol *, 10> Instrs;
    MCSymbol *End;
  } *CurFn;

  typedef DenseMap<const Function *, FunctionInfo> FnDebugInfoTy;
  FnDebugInfoTy FnDebugInfo;
  // Store the functions we've visited in a vector so we can maintain a stable
  // order while emitting subsections.
  SmallVector<const Function *, 10> VisitedFunctions;

  // InstrInfoTy - Holds the Filename:LineNumber information for every
  // instruction with a unique debug location.
  struct InstrInfoTy {
    StringRef Filename;
    unsigned LineNumber;

    InstrInfoTy() : LineNumber(0) {}

    InstrInfoTy(StringRef Filename, unsigned LineNumber)
        : Filename(Filename), LineNumber(LineNumber) {}
  };
  DenseMap<MCSymbol *, InstrInfoTy> InstrInfo;

  // FileNameRegistry - Manages filenames observed while generating debug info
  // by filtering out duplicates and bookkeeping the offsets in the string
  // table to be generated.
  struct FileNameRegistryTy {
    SmallVector<StringRef, 10> Filenames;
    struct PerFileInfo {
      size_t FilenameID, StartOffset;
    };
    StringMap<PerFileInfo> Infos;

    // The offset in the string table where we'll write the next unique
    // filename.
    size_t LastOffset;

    FileNameRegistryTy() {
      clear();
    }

    // Add Filename to the registry, if it was not observed before.
    void add(StringRef Filename) {
      if (Infos.count(Filename))
        return;
      size_t OldSize = Infos.size();
      Infos[Filename].FilenameID = OldSize;
      Infos[Filename].StartOffset = LastOffset;
      LastOffset += Filename.size() + 1;
      Filenames.push_back(Filename);
    }

    void clear() {
      LastOffset = 1;
      Infos.clear();
      Filenames.clear();
    }
  } FileNameRegistry;

  typedef std::map<std::pair<StringRef, StringRef>, char *>
      DirAndFilenameToFilepathMapTy;
  DirAndFilenameToFilepathMapTy DirAndFilenameToFilepathMap;
  StringRef getFullFilepath(const MDNode *S);

  void maybeRecordLocation(DebugLoc DL, const MachineFunction *MF);

  void clear() {
    assert(CurFn == 0);
    FileNameRegistry.clear();
    InstrInfo.clear();
  }

  void emitDebugInfoForFunction(const Function *GV);

public:
  WinCodeViewLineTables(AsmPrinter *Asm);

  ~WinCodeViewLineTables() {
    for (DirAndFilenameToFilepathMapTy::iterator
             I = DirAndFilenameToFilepathMap.begin(),
             E = DirAndFilenameToFilepathMap.end();
         I != E; ++I)
      free(I->second);
  }

  virtual void setSymbolSize(const llvm::MCSymbol *, uint64_t) {}

  /// \brief Emit the COFF section that holds the line table information.
  virtual void endModule();

  /// \brief Gather pre-function debug information.
  virtual void beginFunction(const MachineFunction *MF);

  /// \brief Gather post-function debug information.
  virtual void endFunction(const MachineFunction *);

  /// \brief Process beginning of an instruction.
  virtual void beginInstruction(const MachineInstr *MI);

  /// \brief Process end of an instruction.
  virtual void endInstruction() {}
};
} // End of namespace llvm

#endif
