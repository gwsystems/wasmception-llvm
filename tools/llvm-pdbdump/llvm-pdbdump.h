//===- llvm-pdbdump.h ----------------------------------------- *- C++ --*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVMPDBDUMP_LLVMPDBDUMP_H
#define LLVM_TOOLS_LLVMPDBDUMP_LLVMPDBDUMP_H

#include "llvm/ADT/Optional.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include <memory>
#include <stdint.h>

namespace llvm {
namespace pdb {
class PDBSymbolData;
class PDBSymbolFunc;
uint32_t getTypeLength(const PDBSymbolData &Symbol);
}
}

namespace opts {

enum class ModuleSubsection {
  Unknown,
  Lines,
  FileChecksums,
  InlineeLines,
  CrossScopeImports,
  CrossScopeExports,
  StringTable,
  Symbols,
  FrameData,
  All
};

bool checkModuleSubsection(ModuleSubsection Kind);

template <typename... Ts>
bool checkModuleSubsection(ModuleSubsection K1, ModuleSubsection K2,
                           Ts &&... Rest) {
  return checkModuleSubsection(K1) ||
         checkModuleSubsection(K2, std::forward<Ts>(Rest)...);
}

namespace pretty {

enum class ClassDefinitionFormat { None, Layout, All };
enum class ClassSortMode {
  None,
  Name,
  Size,
  Padding,
  PaddingPct,
  PaddingImmediate,
  PaddingPctImmediate
};

enum class SymbolSortMode { None, Name, Size };

enum class SymLevel { Functions, Data, Thunks, All };

bool shouldDumpSymLevel(SymLevel Level);
bool compareFunctionSymbols(
    const std::unique_ptr<llvm::pdb::PDBSymbolFunc> &F1,
    const std::unique_ptr<llvm::pdb::PDBSymbolFunc> &F2);
bool compareDataSymbols(const std::unique_ptr<llvm::pdb::PDBSymbolData> &F1,
                        const std::unique_ptr<llvm::pdb::PDBSymbolData> &F2);

extern llvm::cl::opt<bool> Compilands;
extern llvm::cl::opt<bool> Symbols;
extern llvm::cl::opt<bool> Globals;
extern llvm::cl::opt<bool> Classes;
extern llvm::cl::opt<bool> Enums;
extern llvm::cl::opt<bool> Typedefs;
extern llvm::cl::opt<bool> All;
extern llvm::cl::opt<bool> ExcludeCompilerGenerated;

extern llvm::cl::opt<bool> NoEnumDefs;
extern llvm::cl::list<std::string> ExcludeTypes;
extern llvm::cl::list<std::string> ExcludeSymbols;
extern llvm::cl::list<std::string> ExcludeCompilands;
extern llvm::cl::list<std::string> IncludeTypes;
extern llvm::cl::list<std::string> IncludeSymbols;
extern llvm::cl::list<std::string> IncludeCompilands;
extern llvm::cl::opt<SymbolSortMode> SymbolOrder;
extern llvm::cl::opt<ClassSortMode> ClassOrder;
extern llvm::cl::opt<uint32_t> SizeThreshold;
extern llvm::cl::opt<uint32_t> PaddingThreshold;
extern llvm::cl::opt<uint32_t> ImmediatePaddingThreshold;
extern llvm::cl::opt<ClassDefinitionFormat> ClassFormat;
extern llvm::cl::opt<uint32_t> ClassRecursionDepth;
}

namespace raw {
struct BlockRange {
  uint32_t Min;
  llvm::Optional<uint32_t> Max;
};

extern llvm::Optional<BlockRange> DumpBlockRange;
extern llvm::cl::list<std::string> DumpStreamData;

extern llvm::cl::opt<bool> CompactRecords;
extern llvm::cl::opt<bool> DumpGlobals;
extern llvm::cl::opt<bool> DumpHeaders;
extern llvm::cl::opt<bool> DumpStreamBlocks;
extern llvm::cl::opt<bool> DumpStreamSummary;
extern llvm::cl::opt<bool> DumpPageStats;
extern llvm::cl::opt<bool> DumpTpiHash;
extern llvm::cl::opt<bool> DumpTpiRecordBytes;
extern llvm::cl::opt<bool> DumpTpiRecords;
extern llvm::cl::opt<bool> DumpIpiRecords;
extern llvm::cl::opt<bool> DumpIpiRecordBytes;
extern llvm::cl::opt<bool> DumpPublics;
extern llvm::cl::opt<bool> DumpSectionContribs;
extern llvm::cl::opt<bool> DumpSectionMap;
extern llvm::cl::opt<bool> DumpSymRecordBytes;
extern llvm::cl::opt<bool> DumpSectionHeaders;
extern llvm::cl::opt<bool> DumpFpo;
extern llvm::cl::opt<bool> DumpStringTable;
}

namespace diff {
extern llvm::cl::opt<bool> Pedantic;
}

namespace pdb2yaml {
extern llvm::cl::opt<bool> All;
extern llvm::cl::opt<bool> NoFileHeaders;
extern llvm::cl::opt<bool> Minimal;
extern llvm::cl::opt<bool> StreamMetadata;
extern llvm::cl::opt<bool> StreamDirectory;
extern llvm::cl::opt<bool> StringTable;
extern llvm::cl::opt<bool> PdbStream;
extern llvm::cl::opt<bool> DbiStream;
extern llvm::cl::opt<bool> TpiStream;
extern llvm::cl::opt<bool> IpiStream;
extern llvm::cl::list<std::string> InputFilename;
}

namespace shared {
extern llvm::cl::opt<bool> DumpModules;
extern llvm::cl::opt<bool> DumpModuleFiles;
extern llvm::cl::list<ModuleSubsection> DumpModuleSubsections;
extern llvm::cl::opt<bool> DumpModuleSyms;
} // namespace shared
}

#endif
