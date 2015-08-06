//===-- dsymutil.cpp - Debug info dumping utility for llvm ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This program is a utility that aims to be a dropin replacement for
// Darwin's dsymutil.
//
//===----------------------------------------------------------------------===//

#include "DebugMap.h"
#include "MachOUtils.h"
#include "dsymutil.h"
#include "llvm/Object/MachO.h"
#include "llvm/Support/FileUtilities.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Options.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetSelect.h"
#include <string>

using namespace llvm::dsymutil;

namespace {
using namespace llvm::cl;

OptionCategory DsymCategory("Specific Options");
static opt<bool> Help("h", desc("Alias for -help"), Hidden);
static opt<bool> Version("v", desc("Alias for -version"), Hidden);

static list<std::string> InputFiles(Positional, OneOrMore,
                                    desc("<input files>"), cat(DsymCategory));

static opt<std::string>
    OutputFileOpt("o",
                  desc("Specify the output file. default: <input file>.dwarf"),
                  value_desc("filename"), cat(DsymCategory));

static opt<std::string> OsoPrependPath(
    "oso-prepend-path",
    desc("Specify a directory to prepend to the paths of object files."),
    value_desc("path"), cat(DsymCategory));

static opt<bool> FlatOut("flat",
                         desc("Produce a flat dSYM file (not a bundle)."),
                         init(false), cat(DsymCategory));
static alias FlatOutA("f", desc("Alias for --flat"), aliasopt(FlatOut));

static opt<bool> Verbose("verbose", desc("Verbosity level"), init(false),
                         cat(DsymCategory));

static opt<bool>
    NoOutput("no-output",
             desc("Do the link in memory, but do not emit the result file."),
             init(false), cat(DsymCategory));

static list<std::string> ArchFlags(
    "arch",
    desc("Link DWARF debug information only for specified CPU architecture\n"
         "types. This option can be specified multiple times, once for each\n"
         "desired architecture.  All cpu architectures will be linked by\n"
         "default."),
    ZeroOrMore, cat(DsymCategory));

static opt<bool>
    NoODR("no-odr",
          desc("Do not use ODR (One Definition Rule) for type uniquing."),
          init(false), cat(DsymCategory));

static opt<bool> DumpDebugMap(
    "dump-debug-map",
    desc("Parse and dump the debug map to standard output. Not DWARF link "
         "will take place."),
    init(false), cat(DsymCategory));

static opt<bool> InputIsYAMLDebugMap(
    "y", desc("Treat the input file is a YAML debug map rather than a binary."),
    init(false), cat(DsymCategory));
}

static std::error_code getUniqueFile(const llvm::Twine &Model, int &ResultFD,
                                     llvm::SmallVectorImpl<char> &ResultPath) {
  // If in NoOutput mode, use the createUniqueFile variant that
  // doesn't open the file but still generates a somewhat unique
  // name. In the real usage scenario, we'll want to ensure that the
  // file is trully unique, and creating it is the only way to achieve
  // that.
  if (NoOutput)
    return llvm::sys::fs::createUniqueFile(Model, ResultPath);
  return llvm::sys::fs::createUniqueFile(Model, ResultFD, ResultPath);
}

static std::string getOutputFileName(llvm::StringRef InputFile,
                                     bool TempFile = false) {
  if (TempFile) {
    llvm::Twine OutputFile = InputFile + ".tmp%%%%%%.dwarf";
    int FD;
    llvm::SmallString<128> UniqueFile;
    if (auto EC = getUniqueFile(OutputFile, FD, UniqueFile)) {
      llvm::errs() << "error: failed to create temporary outfile '"
                   << OutputFile << "': " << EC.message() << '\n';
      return "";
    }
    llvm::sys::RemoveFileOnSignal(UniqueFile);
    if (!NoOutput) {
      // Close the file immediately. We know it is unique. It will be
      // reopened and written to later.
      llvm::raw_fd_ostream CloseImmediately(FD, true /* shouldClose */, true);
    }
    return UniqueFile.str();
  }

  if (OutputFileOpt.empty()) {
    if (InputFile == "-")
      return "a.out.dwarf";
    return (InputFile + ".dwarf").str();
  }
  return OutputFileOpt;
}

void llvm::dsymutil::exitDsymutil(int ExitStatus) {
  // Cleanup temporary files.
  llvm::sys::RunInterruptHandlers();
  exit(ExitStatus);
}

int main(int argc, char **argv) {
  llvm::sys::PrintStackTraceOnErrorSignal();
  llvm::PrettyStackTraceProgram StackPrinter(argc, argv);
  llvm::llvm_shutdown_obj Shutdown;
  LinkOptions Options;

  HideUnrelatedOptions(DsymCategory);
  llvm::cl::ParseCommandLineOptions(
      argc, argv,
      "manipulate archived DWARF debug symbol files.\n\n"
      "dsymutil links the DWARF debug information found in the object files\n"
      "for the executable <input file> by using debug symbols information\n"
      "contained in its symbol table.\n");

  if (Help)
    PrintHelpMessage();

  if (Version) {
    llvm::cl::PrintVersionMessage();
    return 0;
  }

  Options.Verbose = Verbose;
  Options.NoOutput = NoOutput;
  Options.NoODR = NoODR;

  llvm::InitializeAllTargetInfos();
  llvm::InitializeAllTargetMCs();
  llvm::InitializeAllTargets();
  llvm::InitializeAllAsmPrinters();

  if (!FlatOut && OutputFileOpt == "-") {
    llvm::errs() << "error: cannot emit to standard output without --flat\n";
    return 1;
  }

  if (InputFiles.size() > 1 && FlatOut && !OutputFileOpt.empty()) {
    llvm::errs() << "error: cannot use -o with multiple inputs in flat mode\n";
    return 1;
  }

  for (const auto &Arch : ArchFlags)
    if (Arch != "*" && Arch != "all" &&
        !llvm::object::MachOObjectFile::isValidArch(Arch)) {
      llvm::errs() << "error: Unsupported cpu architecture: '" << Arch << "'\n";
      exitDsymutil(1);
    }

  for (auto &InputFile : InputFiles) {
    auto DebugMapPtrsOrErr = parseDebugMap(InputFile, ArchFlags, OsoPrependPath,
                                           Verbose, InputIsYAMLDebugMap);

    if (auto EC = DebugMapPtrsOrErr.getError()) {
      llvm::errs() << "error: cannot parse the debug map for \"" << InputFile
                   << "\": " << EC.message() << '\n';
      exitDsymutil(1);
    }

    if (DebugMapPtrsOrErr->empty()) {
      llvm::errs() << "error: no architecture to link\n";
      exitDsymutil(1);
    }

    // If there is more than one link to execute, we need to generate
    // temporary files.
    bool NeedsTempFiles = !DumpDebugMap && (*DebugMapPtrsOrErr).size() != 1;
    llvm::SmallVector<MachOUtils::ArchAndFilename, 4> TempFiles;
    for (auto &Map : *DebugMapPtrsOrErr) {
      if (Verbose || DumpDebugMap)
        Map->print(llvm::outs());

      if (DumpDebugMap)
        continue;

      std::string OutputFile = getOutputFileName(InputFile, NeedsTempFiles);
      if (OutputFile.empty() || !linkDwarf(OutputFile, *Map, Options))
        exitDsymutil(1);

      if (NeedsTempFiles)
        TempFiles.emplace_back(Map->getTriple().getArchName().str(),
                               OutputFile);
    }

    if (NeedsTempFiles &&
        !MachOUtils::generateUniversalBinary(
            TempFiles, getOutputFileName(InputFile), Options))
      exitDsymutil(1);
  }

  exitDsymutil(0);
}
