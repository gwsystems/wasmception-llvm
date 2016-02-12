//===- llvm-pdbdump.cpp - Dump debug info from a PDB file -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Dumps debug information present in PDB files.  This utility makes use of
// the Microsoft Windows SDK, so will not compile or run on non-Windows
// platforms.
//
//===----------------------------------------------------------------------===//

#include "llvm-pdbdump.h"
#include "CompilandDumper.h"
#include "ExternalSymbolDumper.h"
#include "FunctionDumper.h"
#include "LinePrinter.h"
#include "TypeDumper.h"
#include "VariableDumper.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Config/config.h"
#include "llvm/DebugInfo/PDB/IPDBEnumChildren.h"
#include "llvm/DebugInfo/PDB/IPDBRawSymbol.h"
#include "llvm/DebugInfo/PDB/IPDBSession.h"
#include "llvm/DebugInfo/PDB/PDB.h"
#include "llvm/DebugInfo/PDB/PDBSymbolCompiland.h"
#include "llvm/DebugInfo/PDB/PDBSymbolData.h"
#include "llvm/DebugInfo/PDB/PDBSymbolExe.h"
#include "llvm/DebugInfo/PDB/PDBSymbolFunc.h"
#include "llvm/DebugInfo/PDB/PDBSymbolThunk.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ConvertUTF.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Signals.h"

#if defined(HAVE_DIA_SDK)
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#endif

using namespace llvm;

namespace opts {

enum class PDB_DumpType { ByType, ByObjFile, Both };

cl::list<std::string> InputFilenames(cl::Positional,
                                     cl::desc("<input PDB files>"),
                                     cl::OneOrMore);

cl::OptionCategory TypeCategory("Symbol Type Options");
cl::OptionCategory FilterCategory("Filtering Options");
cl::OptionCategory OtherOptions("Other Options");

cl::opt<bool> Compilands("compilands", cl::desc("Display compilands"),
                         cl::cat(TypeCategory));
cl::opt<bool> Symbols("symbols", cl::desc("Display symbols for each compiland"),
                      cl::cat(TypeCategory));
cl::opt<bool> Globals("globals", cl::desc("Dump global symbols"),
                      cl::cat(TypeCategory));
cl::opt<bool> Externals("externals", cl::desc("Dump external symbols"),
                        cl::cat(TypeCategory));
cl::opt<bool> Types("types", cl::desc("Display types"), cl::cat(TypeCategory));
cl::opt<bool>
    All("all", cl::desc("Implies all other options in 'Symbol Types' category"),
        cl::cat(TypeCategory));

cl::opt<uint64_t> LoadAddress(
    "load-address",
    cl::desc("Assume the module is loaded at the specified address"),
    cl::cat(OtherOptions));

cl::opt<bool> DumpHeaders("dump-headers", cl::desc("dump PDB headers"),
                          cl::cat(OtherOptions));
cl::opt<bool> DumpStreamSizes("dump-stream-sizes",
                              cl::desc("dump PDB stream sizes"),
                              cl::cat(OtherOptions));
cl::opt<bool> DumpStreamBlocks("dump-stream-blocks",
                               cl::desc("dump PDB stream blocks"),
                               cl::cat(OtherOptions));
cl::opt<std::string> DumpStreamData("dump-stream", cl::desc("dump stream data"),
                                    cl::cat(OtherOptions));

cl::list<std::string>
    ExcludeTypes("exclude-types",
                 cl::desc("Exclude types by regular expression"),
                 cl::ZeroOrMore, cl::cat(FilterCategory));
cl::list<std::string>
    ExcludeSymbols("exclude-symbols",
                   cl::desc("Exclude symbols by regular expression"),
                   cl::ZeroOrMore, cl::cat(FilterCategory));
cl::list<std::string>
    ExcludeCompilands("exclude-compilands",
                      cl::desc("Exclude compilands by regular expression"),
                      cl::ZeroOrMore, cl::cat(FilterCategory));

cl::list<std::string> IncludeTypes(
    "include-types",
    cl::desc("Include only types which match a regular expression"),
    cl::ZeroOrMore, cl::cat(FilterCategory));
cl::list<std::string> IncludeSymbols(
    "include-symbols",
    cl::desc("Include only symbols which match a regular expression"),
    cl::ZeroOrMore, cl::cat(FilterCategory));
cl::list<std::string> IncludeCompilands(
    "include-compilands",
    cl::desc("Include only compilands those which match a regular expression"),
    cl::ZeroOrMore, cl::cat(FilterCategory));

cl::opt<bool> ExcludeCompilerGenerated(
    "no-compiler-generated",
    cl::desc("Don't show compiler generated types and symbols"),
    cl::cat(FilterCategory));
cl::opt<bool>
    ExcludeSystemLibraries("no-system-libs",
                           cl::desc("Don't show symbols from system libraries"),
                           cl::cat(FilterCategory));
cl::opt<bool> NoClassDefs("no-class-definitions",
                          cl::desc("Don't display full class definitions"),
                          cl::cat(FilterCategory));
cl::opt<bool> NoEnumDefs("no-enum-definitions",
                         cl::desc("Don't display full enum definitions"),
                         cl::cat(FilterCategory));
}


static void reportError(StringRef Input, StringRef Message) {
  if (Input == "-")
    Input = "<stdin>";
  errs() << Input << ": " << Message << "\n";
  errs().flush();
  exit(1);
}

static void reportError(StringRef Input, std::error_code EC) {
  reportError(Input, EC.message());
}

static std::error_code checkOffset(MemoryBufferRef M, uintptr_t Addr,
                                   const uint64_t Size) {
  if (Addr + Size < Addr || Addr + Size < Size ||
      Addr + Size > uintptr_t(M.getBufferEnd()) ||
      Addr < uintptr_t(M.getBufferStart())) {
    return std::make_error_code(std::errc::bad_address);
  }
  return std::error_code();
}

template <typename T>
static std::error_code checkOffset(MemoryBufferRef M, ArrayRef<T> AR) {
  return checkOffset(M, uintptr_t(AR.data()), (uint64_t)AR.size() * sizeof(T));
}

static std::error_code checkOffset(MemoryBufferRef M, StringRef SR) {
  return checkOffset(M, uintptr_t(SR.data()), SR.size());
}

// Sets Obj unless any bytes in [addr, addr + size) fall outsize of m.
// Returns unexpected_eof if error.
template <typename T>
static std::error_code getObject(const T *&Obj, MemoryBufferRef M,
                                 const void *Ptr,
                                 const uint64_t Size = sizeof(T)) {
  uintptr_t Addr = uintptr_t(Ptr);
  if (std::error_code EC = checkOffset(M, Addr, Size))
    return EC;
  Obj = reinterpret_cast<const T *>(Addr);
  return std::error_code();
}

static uint64_t bytesToBlocks(uint64_t NumBytes, uint64_t BlockSize) {
  return alignTo(NumBytes, BlockSize) / BlockSize;
}

static uint64_t blockToOffset(uint64_t BlockNumber, uint64_t BlockSize) {
  return BlockNumber * BlockSize;
}

struct PDBStructureContext {
  const PDB::SuperBlock *SB;
  MemoryBufferRef M;
  std::vector<uint32_t> StreamSizes;
  DenseMap<uint32_t, std::vector<uint32_t>> StreamMap;

  SmallVector<char, 512> Scratch;

  // getObject tries to stitch together non-contiguous blocks into a contiguous
  // value.  The storage for the value comes from the memory mapped file if the
  // memory would be contiguous.  Otherwise, it uses 'Scratch' to buffer the
  // data.
  template <typename T>
  void getObject(const T *&Obj, uint32_t StreamIdx, uint32_t &Offset) {
    // Make sure the stream index is valid.
    auto StreamBlockI = StreamMap.find(StreamIdx);
    if (StreamBlockI == StreamMap.end())
      reportError(M.getBufferIdentifier(),
                  std::make_error_code(std::errc::bad_address));

    auto &StreamBlocks = StreamBlockI->second;
    uint32_t BlockNum = Offset / SB->BlockSize;
    uint32_t OffsetInBlock = Offset % SB->BlockSize;

    // Make sure we aren't trying to read beyond the end of the stream.
    if (Offset + sizeof(T) > StreamSizes[StreamIdx])
      reportError(M.getBufferIdentifier(),
                  std::make_error_code(std::errc::bad_address));

    // Modify the passed in offset to point to the data after the object.
    Offset += sizeof(T);

    // Handle the contiguous case: the offset + size stays within a block.
    if (OffsetInBlock + sizeof(T) <= SB->BlockSize) {
      uint32_t StreamBlockAddr = StreamBlocks[BlockNum];
      uint64_t StreamBlockOffset =
          blockToOffset(StreamBlockAddr, SB->BlockSize) + OffsetInBlock;
      // Return a pointer to the memory buffer.
      Obj = reinterpret_cast<const T *>(M.getBufferStart() + StreamBlockOffset);
      return;
    }

    // The non-contiguous case: we will stitch together non-contiguous chunks
    // into the scratch buffer.
    Scratch.clear();

    uint32_t BytesLeft = sizeof(T);
    while (BytesLeft > 0) {
      uint32_t StreamBlockAddr = StreamBlocks[BlockNum];
      uint64_t StreamBlockOffset =
          blockToOffset(StreamBlockAddr, SB->BlockSize) + OffsetInBlock;

      const char *ChunkStart =
          M.getBufferStart() + StreamBlockOffset;
      uint32_t BytesInChunk =
          std::min(BytesLeft, SB->BlockSize - OffsetInBlock);
      Scratch.append(ChunkStart, ChunkStart + BytesInChunk);

      BytesLeft -= BytesInChunk;
      ++BlockNum;
      OffsetInBlock = 0;
    }

    // Return a pointer to the scratch buffer.
    Obj = reinterpret_cast<const T *>(Scratch.data());
  }

  template <typename T>
  T getInt(uint32_t StreamIdx, uint32_t &Offset) {
    const support::detail::packed_endian_specific_integral<
        T, support::little, support::unaligned> *P;
    getObject(P, StreamIdx, Offset);
    return *P;
  }

  template <typename T>
  T getObject(uint32_t StreamIdx, uint32_t &Offset) {
    const T *P;
    getObject(P, StreamIdx, Offset);
    return *P;
  }
};

static void dumpStructure(MemoryBufferRef M) {
  const PDB::SuperBlock *SB;

  auto Error = [&](std::error_code EC) {
    if (EC)
      reportError(M.getBufferIdentifier(), EC);
  };

  Error(getObject(SB, M, M.getBufferStart()));

  if (opts::DumpHeaders) {
    outs() << "BlockSize: " << SB->BlockSize << '\n';
    outs() << "Unknown0: " << SB->Unknown0 << '\n';
    outs() << "NumBlocks: " << SB->NumBlocks << '\n';
    outs() << "NumDirectoryBytes: " << SB->NumDirectoryBytes << '\n';
    outs() << "Unknown1: " << SB->Unknown1 << '\n';
    outs() << "BlockMapAddr: " << SB->BlockMapAddr << '\n';
  }

  // We don't support blocksizes which aren't a multiple of four bytes.
  if (SB->BlockSize % sizeof(support::ulittle32_t) != 0)
    Error(std::make_error_code(std::errc::not_supported));

  // We don't support directories whose sizes aren't a multiple of four bytes.
  if (SB->NumDirectoryBytes % sizeof(support::ulittle32_t) != 0)
    Error(std::make_error_code(std::errc::not_supported));

  // The number of blocks which comprise the directory is a simple function of
  // the number of bytes it contains.
  uint64_t NumDirectoryBlocks =
      bytesToBlocks(SB->NumDirectoryBytes, SB->BlockSize);
  if (opts::DumpHeaders)
    outs() << "NumDirectoryBlocks: " << NumDirectoryBlocks << '\n';

  // The block map, as we understand it, is a block which consists of a list of
  // block numbers.
  // It is unclear what would happen if the number of blocks couldn't fit on a
  // single block.
  if (NumDirectoryBlocks > SB->BlockSize / sizeof(support::ulittle32_t))
    Error(std::make_error_code(std::errc::illegal_byte_sequence));

  uint64_t BlockMapOffset = (uint64_t)SB->BlockMapAddr * SB->BlockSize;
  if (opts::DumpHeaders)
    outs() << "BlockMapOffset: " << BlockMapOffset << '\n';

  // The directory is not contiguous.  Instead, the block map contains a
  // contiguous list of block numbers whose contents, when concatenated in
  // order, make up the directory.
  auto DirectoryBlocks =
      makeArrayRef(reinterpret_cast<const support::ulittle32_t *>(
                       M.getBufferStart() + BlockMapOffset),
                   NumDirectoryBlocks);
  Error(checkOffset(M, DirectoryBlocks));

  if (opts::DumpHeaders) {
    outs() << "DirectoryBlocks: [";
    for (const support::ulittle32_t &DirectoryBlockAddr : DirectoryBlocks) {
      if (&DirectoryBlockAddr != &DirectoryBlocks.front())
        outs() << ", ";
      outs() << DirectoryBlockAddr;
    }
    outs() << "]\n";
  }

  bool SeenNumStreams = false;
  uint32_t NumStreams = 0;
  uint32_t StreamIdx = 0;
  uint64_t DirectoryBytesRead = 0;
  PDBStructureContext Ctx;
  Ctx.SB = SB;
  Ctx.M = M;
  // The structure of the directory is as follows:
  //    struct PDBDirectory {
  //      uint32_t NumStreams;
  //      uint32_t StreamSizes[NumStreams];
  //      uint32_t StreamMap[NumStreams][];
  //    };
  //
  //  Empty streams don't consume entries in the StreamMap.
  for (uint32_t DirectoryBlockAddr : DirectoryBlocks) {
    uint64_t DirectoryBlockOffset =
        blockToOffset(DirectoryBlockAddr, SB->BlockSize);
    auto DirectoryBlock =
        makeArrayRef(reinterpret_cast<const support::ulittle32_t *>(
                         M.getBufferStart() + DirectoryBlockOffset),
                     SB->BlockSize / sizeof(support::ulittle32_t));
    Error(checkOffset(M, DirectoryBlock));

    // We read data out of the directory four bytes at a time.  Depending on
    // where we are in the directory, the contents may be: the number of streams
    // in the directory, a stream's size, or a block in the stream map.
    for (uint32_t Data : DirectoryBlock) {
      // Don't read beyond the end of the directory.
      if (DirectoryBytesRead == SB->NumDirectoryBytes)
        break;

      DirectoryBytesRead += sizeof(Data);

      // This data must be the number of streams if we haven't seen it yet.
      if (!SeenNumStreams) {
        NumStreams = Data;
        SeenNumStreams = true;
        continue;
      }
      // This data must be a stream size if we have not seen them all yet.
      if (Ctx.StreamSizes.size() < NumStreams) {
        // It seems like some streams have their set to -1 when their contents
        // are not present.  Treat them like empty streams for now.
        if (Data == UINT32_MAX)
          Ctx.StreamSizes.push_back(0);
        else
          Ctx.StreamSizes.push_back(Data);
        continue;
      }

      // This data must be a stream block number if we have seen all of the
      // stream sizes.
      std::vector<uint32_t> *StreamBlocks = nullptr;
      // Figure out which stream this block number belongs to.
      while (StreamIdx < NumStreams) {
        uint64_t NumExpectedStreamBlocks =
            bytesToBlocks(Ctx.StreamSizes[StreamIdx], SB->BlockSize);
        StreamBlocks = &Ctx.StreamMap[StreamIdx];
        if (NumExpectedStreamBlocks > StreamBlocks->size())
          break;
        ++StreamIdx;
      }
      // It seems this block doesn't belong to any stream?  The stream is either
      // corrupt or something more mysterious is going on.
      if (StreamIdx == NumStreams)
        Error(std::make_error_code(std::errc::illegal_byte_sequence));

      StreamBlocks->push_back(Data);
    }
  }

  // We should have read exactly SB->NumDirectoryBytes bytes.
  assert(DirectoryBytesRead == SB->NumDirectoryBytes);

  if (opts::DumpHeaders)
    outs() << "NumStreams: " << NumStreams << '\n';
  if (opts::DumpStreamSizes)
    for (uint32_t StreamIdx = 0; StreamIdx < NumStreams; ++StreamIdx)
      outs() << "StreamSizes[" << StreamIdx
             << "]: " << Ctx.StreamSizes[StreamIdx] << '\n';

  if (opts::DumpStreamBlocks) {
    for (uint32_t StreamIdx = 0; StreamIdx < NumStreams; ++StreamIdx) {
      outs() << "StreamBlocks[" << StreamIdx << "]: [";
      std::vector<uint32_t> &StreamBlocks = Ctx.StreamMap[StreamIdx];
      for (uint32_t &StreamBlock : StreamBlocks) {
        if (&StreamBlock != &StreamBlocks.front())
          outs() << ", ";
        outs() << StreamBlock;
      }
      outs() << "]\n";
    }
  }

  StringRef DumpStreamStr = opts::DumpStreamData;
  uint32_t DumpStreamNum;
  if (!DumpStreamStr.getAsInteger(/*Radix=*/0U, DumpStreamNum) &&
      DumpStreamNum < NumStreams) {
    uint32_t StreamBytesRead = 0;
    uint32_t StreamSize = Ctx.StreamSizes[DumpStreamNum];
    std::vector<uint32_t> &StreamBlocks = Ctx.StreamMap[DumpStreamNum];
    for (uint32_t &StreamBlockAddr : StreamBlocks) {
      uint64_t StreamBlockOffset = blockToOffset(StreamBlockAddr, SB->BlockSize);
      uint32_t BytesLeftToReadInStream = StreamSize - StreamBytesRead;
      if (BytesLeftToReadInStream == 0)
        break;

      uint32_t BytesToReadInBlock = std::min(
          BytesLeftToReadInStream, static_cast<uint32_t>(SB->BlockSize));
      auto StreamBlockData =
          StringRef(M.getBufferStart() + StreamBlockOffset, BytesToReadInBlock);
      Error(checkOffset(M, StreamBlockData));

      outs() << StreamBlockData;
      StreamBytesRead += StreamBlockData.size();
    }
  }

  uint32_t Offset = 0;

  // Stream 1 starts with the following header:
  //   uint32_t Version;
  //   uint32_t Signature;
  //   uint32_t Age;
  //   GUID Guid;
  auto Version = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "Version: " << Version << '\n';

  // PDB's with versions before PDBImpvVC70 might not have the Guid field, we
  // don't support them.
  if (Version < 20000404)
    Error(std::make_error_code(std::errc::not_supported));

  // This appears to be the time the PDB was last opened by an MSVC tool?
  // It is definitely a timestamp of some sort.
  auto Signature = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "Signature: ";
  outs().write_hex(Signature) << '\n';

  // This appears to be a number which is used to determine that the PDB is kept
  // in sync with the EXE.
  auto Age = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "Age: " << Age << '\n';

  // I'm not sure what the purpose of the GUID is.
  using GuidTy = char[16];
  const GuidTy *Guid;
  Ctx.getObject(Guid, /*PDBStream=*/1, Offset);
  outs() << "Guid: ";
  for (char C : *Guid)
    outs().write_hex(C & 0xff) << ' ';
  outs() << '\n';

  // This is some sort of weird string-set/hash table encoded in the stream.
  // It starts with the number of bytes in the table.
  auto NumberOfBytes = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "NumberOfBytes: " << NumberOfBytes << '\n';

  // Following that field is the starting offset of strings in the name table.
  uint32_t StringsOffset = Offset;
  Offset += NumberOfBytes;

  // This appears to be equivalent to the total number of strings *actually*
  // in the name table.
  auto HashSize = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "HashSize: " << HashSize << '\n';

  // This appears to be an upper bound on the number of strings in the name
  // table.
  auto MaxNumberOfStrings = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "MaxNumberOfStrings: " << MaxNumberOfStrings << '\n';

  // This appears to be a hash table which uses bitfields to determine whether
  // or not a bucket is 'present'.
  auto NumPresentWords = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "NumPresentWords: " << NumPresentWords << '\n';

  // Store all the 'present' bits in a vector for later processing.
  SmallVector<uint32_t, 1> PresentWords;
  for (uint32_t I = 0; I != NumPresentWords; ++I) {
    auto Word = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
    PresentWords.push_back(Word);
    outs() << "Word: " << Word << '\n';
  }

  // This appears to be a hash table which uses bitfields to determine whether
  // or not a bucket is 'deleted'.
  auto NumDeletedWords = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
  outs() << "NumDeletedWords: " << NumDeletedWords << '\n';

  // Store all the 'deleted' bits in a vector for later processing.
  SmallVector<uint32_t, 1> DeletedWords;
  for (uint32_t I = 0; I != NumDeletedWords; ++I) {
    auto Word = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
    DeletedWords.push_back(Word);
    outs() << "Word: " << Word << '\n';
  }

  BitVector Present(MaxNumberOfStrings, false);
  if (!PresentWords.empty())
    Present.setBitsInMask(PresentWords.data(), PresentWords.size());
  BitVector Deleted(MaxNumberOfStrings, false);
  if (!DeletedWords.empty())
    Deleted.setBitsInMask(DeletedWords.data(), DeletedWords.size());

  StringMap<uint32_t> NamedStreams;
  for (uint32_t I = 0; I < MaxNumberOfStrings; ++I) {
    if (!Present.test(I))
      continue;

    // For all present entries, dump out their mapping.

    // This appears to be an offset relative to the start of the strings.
    // It tells us where the null-terminated string begins.
    auto NameOffset = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
    outs() << "NameOffset: " << NameOffset << '\n';

    // This appears to be a stream number into the stream directory.
    auto NameIndex = Ctx.getInt<uint32_t>(/*PDBStream=*/1, Offset);
    outs() << "NameIndex: " << NameIndex << '\n';

    // Compute the offset of the start of the string relative to the stream.
    uint32_t StringOffset = StringsOffset + NameOffset;

    // Pump out our c-string from the stream.
    SmallString<8> Str;
    char C;
    do {
      C = Ctx.getObject<char>(/*PDBStream=*/1, StringOffset);
      if (C != '\0')
        Str += C;
    } while (C != '\0');
    outs() << "String: " << Str << "\n\n";

    // Add this to a string-map from name to stream number.
    NamedStreams.insert({Str, NameIndex});
  }

  // Let's try to dump out the named stream "/names".
  auto NameI = NamedStreams.find("/names");
  if (NameI != NamedStreams.end()) {
    uint32_t NameStream = NameI->second;
    outs() << "NameStream: " << NameStream << '\n';

    uint32_t NameStreamOffset = 0;

    // The name stream appears to start with a signature and version.
    auto NameStreamSignature =
        Ctx.getInt<uint32_t>(/*PDBStream=*/NameStream, NameStreamOffset);
    outs() << "NameStreamSignature: ";
    outs().write_hex(NameStreamSignature) << '\n';

    auto NameStreamVersion =
        Ctx.getInt<uint32_t>(/*PDBStream=*/NameStream, NameStreamOffset);
    outs() << "NameStreamVersion: " << NameStreamVersion << '\n';

    // We only support this particular version of the name stream.
    if (NameStreamSignature != 0xeffeeffe || NameStreamVersion != 1)
      Error(std::make_error_code(std::errc::not_supported));
  }
}

static void dumpInput(StringRef Path) {
  if (opts::DumpHeaders || !opts::DumpStreamData.empty()) {
    ErrorOr<std::unique_ptr<MemoryBuffer>> ErrorOrBuffer =
        MemoryBuffer::getFileOrSTDIN(Path, /*FileSize=*/-1,
                                     /*RequiresNullTerminator=*/false);

    if (std::error_code EC = ErrorOrBuffer.getError())
      reportError(Path, EC);

    std::unique_ptr<MemoryBuffer> &Buffer = ErrorOrBuffer.get();

    dumpStructure(Buffer->getMemBufferRef());

    outs().flush();
    return;
  }

  std::unique_ptr<IPDBSession> Session;
  PDB_ErrorCode Error = loadDataForPDB(PDB_ReaderType::DIA, Path, Session);
  switch (Error) {
  case PDB_ErrorCode::Success:
    break;
  case PDB_ErrorCode::NoPdbImpl:
    outs() << "Reading PDBs is not supported on this platform.\n";
    return;
  case PDB_ErrorCode::InvalidPath:
    outs() << "Unable to load PDB at '" << Path
           << "'.  Check that the file exists and is readable.\n";
    return;
  case PDB_ErrorCode::InvalidFileFormat:
    outs() << "Unable to load PDB at '" << Path
           << "'.  The file has an unrecognized format.\n";
    return;
  default:
    outs() << "Unable to load PDB at '" << Path
           << "'.  An unknown error occured.\n";
    return;
  }
  if (opts::LoadAddress)
    Session->setLoadAddress(opts::LoadAddress);

  LinePrinter Printer(2, outs());

  auto GlobalScope(Session->getGlobalScope());
  std::string FileName(GlobalScope->getSymbolsFileName());

  WithColor(Printer, PDB_ColorItem::None).get() << "Summary for ";
  WithColor(Printer, PDB_ColorItem::Path).get() << FileName;
  Printer.Indent();
  uint64_t FileSize = 0;

  Printer.NewLine();
  WithColor(Printer, PDB_ColorItem::Identifier).get() << "Size";
  if (!sys::fs::file_size(FileName, FileSize)) {
    Printer << ": " << FileSize << " bytes";
  } else {
    Printer << ": (Unable to obtain file size)";
  }

  Printer.NewLine();
  WithColor(Printer, PDB_ColorItem::Identifier).get() << "Guid";
  Printer << ": " << GlobalScope->getGuid();

  Printer.NewLine();
  WithColor(Printer, PDB_ColorItem::Identifier).get() << "Age";
  Printer << ": " << GlobalScope->getAge();

  Printer.NewLine();
  WithColor(Printer, PDB_ColorItem::Identifier).get() << "Attributes";
  Printer << ": ";
  if (GlobalScope->hasCTypes())
    outs() << "HasCTypes ";
  if (GlobalScope->hasPrivateSymbols())
    outs() << "HasPrivateSymbols ";
  Printer.Unindent();

  if (opts::Compilands) {
    Printer.NewLine();
    WithColor(Printer, PDB_ColorItem::SectionHeader).get()
        << "---COMPILANDS---";
    Printer.Indent();
    auto Compilands = GlobalScope->findAllChildren<PDBSymbolCompiland>();
    CompilandDumper Dumper(Printer);
    while (auto Compiland = Compilands->getNext())
      Dumper.start(*Compiland, false);
    Printer.Unindent();
  }

  if (opts::Types) {
    Printer.NewLine();
    WithColor(Printer, PDB_ColorItem::SectionHeader).get() << "---TYPES---";
    Printer.Indent();
    TypeDumper Dumper(Printer);
    Dumper.start(*GlobalScope);
    Printer.Unindent();
  }

  if (opts::Symbols) {
    Printer.NewLine();
    WithColor(Printer, PDB_ColorItem::SectionHeader).get() << "---SYMBOLS---";
    Printer.Indent();
    auto Compilands = GlobalScope->findAllChildren<PDBSymbolCompiland>();
    CompilandDumper Dumper(Printer);
    while (auto Compiland = Compilands->getNext())
      Dumper.start(*Compiland, true);
    Printer.Unindent();
  }

  if (opts::Globals) {
    Printer.NewLine();
    WithColor(Printer, PDB_ColorItem::SectionHeader).get() << "---GLOBALS---";
    Printer.Indent();
    {
      FunctionDumper Dumper(Printer);
      auto Functions = GlobalScope->findAllChildren<PDBSymbolFunc>();
      while (auto Function = Functions->getNext()) {
        Printer.NewLine();
        Dumper.start(*Function, FunctionDumper::PointerType::None);
      }
    }
    {
      auto Vars = GlobalScope->findAllChildren<PDBSymbolData>();
      VariableDumper Dumper(Printer);
      while (auto Var = Vars->getNext())
        Dumper.start(*Var);
    }
    {
      auto Thunks = GlobalScope->findAllChildren<PDBSymbolThunk>();
      CompilandDumper Dumper(Printer);
      while (auto Thunk = Thunks->getNext())
        Dumper.dump(*Thunk);
    }
    Printer.Unindent();
  }
  if (opts::Externals) {
    Printer.NewLine();
    WithColor(Printer, PDB_ColorItem::SectionHeader).get() << "---EXTERNALS---";
    Printer.Indent();
    ExternalSymbolDumper Dumper(Printer);
    Dumper.start(*GlobalScope);
  }
  outs().flush();
}

int main(int argc_, const char *argv_[]) {
  // Print a stack trace if we signal out.
  sys::PrintStackTraceOnErrorSignal();
  PrettyStackTraceProgram X(argc_, argv_);

  SmallVector<const char *, 256> argv;
  SpecificBumpPtrAllocator<char> ArgAllocator;
  std::error_code EC = sys::Process::GetArgumentVector(
      argv, makeArrayRef(argv_, argc_), ArgAllocator);
  if (EC) {
    errs() << "error: couldn't get arguments: " << EC.message() << '\n';
    return 1;
  }

  llvm_shutdown_obj Y; // Call llvm_shutdown() on exit.

  cl::ParseCommandLineOptions(argv.size(), argv.data(), "LLVM PDB Dumper\n");
  if (opts::All) {
    opts::Compilands = true;
    opts::Symbols = true;
    opts::Globals = true;
    opts::Types = true;
    opts::Externals = true;
  }
  if (opts::ExcludeCompilerGenerated) {
    opts::ExcludeTypes.push_back("__vc_attributes");
    opts::ExcludeCompilands.push_back("* Linker *");
  }
  if (opts::ExcludeSystemLibraries) {
    opts::ExcludeCompilands.push_back(
        "f:\\binaries\\Intermediate\\vctools\\crt_bld");
  }

#if defined(HAVE_DIA_SDK)
  CoInitializeEx(nullptr, COINIT_MULTITHREADED);
#endif

  std::for_each(opts::InputFilenames.begin(), opts::InputFilenames.end(),
                dumpInput);

#if defined(HAVE_DIA_SDK)
  CoUninitialize();
#endif

  return 0;
}
