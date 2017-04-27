//===- RawTypes.h -----------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_PDB_RAW_RAWTYPES_H
#define LLVM_DEBUGINFO_PDB_RAW_RAWTYPES_H

#include "llvm/DebugInfo/CodeView/TypeRecord.h"
#include "llvm/Support/Endian.h"

namespace llvm {
namespace pdb {
// This struct is defined as "SO" in langapi/include/pdb.h.
struct SectionOffset {
  support::ulittle32_t Off;
  support::ulittle16_t Isect;
  char Padding[2];
};

// This is HRFile.
struct PSHashRecord {
  support::ulittle32_t Off; // Offset in the symbol record stream
  support::ulittle32_t CRef;
};

// This struct is defined as `SC` in include/dbicommon.h
struct SectionContrib {
  support::ulittle16_t ISect;
  char Padding[2];
  support::little32_t Off;
  support::little32_t Size;
  support::ulittle32_t Characteristics;
  support::ulittle16_t Imod;
  char Padding2[2];
  support::ulittle32_t DataCrc;
  support::ulittle32_t RelocCrc;
};

// This struct is defined as `SC2` in include/dbicommon.h
struct SectionContrib2 {
  // To guarantee SectionContrib2 is standard layout, we cannot use inheritance.
  SectionContrib Base;
  support::ulittle32_t ISectCoff;
};

// This corresponds to the `OMFSegMap` structure.
struct SecMapHeader {
  support::ulittle16_t SecCount;    // Number of segment descriptors in table
  support::ulittle16_t SecCountLog; // Number of logical segment descriptors
};

// This corresponds to the `OMFSegMapDesc` structure.  The definition is not
// present in the reference implementation, but the layout is derived from
// code that accesses the fields.
struct SecMapEntry {
  support::ulittle16_t Flags; // Descriptor flags.  See OMFSegDescFlags
  support::ulittle16_t Ovl;   // Logical overlay number.
  support::ulittle16_t Group; // Group index into descriptor array.
  support::ulittle16_t Frame;
  support::ulittle16_t SecName;       // Byte index of the segment or group name
                                      // in the sstSegName table, or 0xFFFF.
  support::ulittle16_t ClassName;     // Byte index of the class name in the
                                      // sstSegName table, or 0xFFFF.
  support::ulittle32_t Offset;        // Byte offset of the logical segment
                                      // within the specified physical segment.
                                      // If group is set in flags, offset is the
                                      // offset of the group.
  support::ulittle32_t SecByteLength; // Byte count of the segment or group.
};

// Used for serialized hash table in TPI stream.
// In the reference, it is an array of TI and cbOff pair.
struct TypeIndexOffset {
  codeview::TypeIndex Type;
  support::ulittle32_t Offset;
};

/// Some of the values are stored in bitfields.  Since this needs to be portable
/// across compilers and architectures (big / little endian in particular) we
/// can't use the actual structures below, but must instead do the shifting
/// and masking ourselves.  The struct definitions are provided for reference.
struct DbiFlags {
  ///  uint16_t IncrementalLinking : 1; // True if linked incrementally
  ///  uint16_t IsStripped : 1;         // True if private symbols were
  ///  stripped.
  ///  uint16_t HasCTypes : 1;          // True if linked with /debug:ctypes.
  ///  uint16_t Reserved : 13;
  static const uint16_t FlagIncrementalMask = 0x0001;
  static const uint16_t FlagStrippedMask = 0x0002;
  static const uint16_t FlagHasCTypesMask = 0x0004;
};

struct DbiBuildNo {
  ///  uint16_t MinorVersion : 8;
  ///  uint16_t MajorVersion : 7;
  ///  uint16_t NewVersionFormat : 1;
  static const uint16_t BuildMinorMask = 0x00FF;
  static const uint16_t BuildMinorShift = 0;

  static const uint16_t BuildMajorMask = 0x7F00;
  static const uint16_t BuildMajorShift = 8;
};

/// The fixed size header that appears at the beginning of the DBI Stream.
struct DbiStreamHeader {
  support::little32_t VersionSignature;
  support::ulittle32_t VersionHeader;

  /// How "old" is this DBI Stream. Should match the age of the PDB InfoStream.
  support::ulittle32_t Age;

  /// Global symbol stream #
  support::ulittle16_t GlobalSymbolStreamIndex;

  /// See DbiBuildNo structure.
  support::ulittle16_t BuildNumber;

  /// Public symbols stream #
  support::ulittle16_t PublicSymbolStreamIndex;

  /// version of mspdbNNN.dll
  support::ulittle16_t PdbDllVersion;

  /// Symbol records stream #
  support::ulittle16_t SymRecordStreamIndex;

  /// rbld number of mspdbNNN.dll
  support::ulittle16_t PdbDllRbld;

  /// Size of module info stream
  support::little32_t ModiSubstreamSize;

  /// Size of sec. contrib stream
  support::little32_t SecContrSubstreamSize;

  /// Size of sec. map substream
  support::little32_t SectionMapSize;

  /// Size of file info substream
  support::little32_t FileInfoSize;

  /// Size of type server map
  support::little32_t TypeServerSize;

  /// Index of MFC Type Server
  support::ulittle32_t MFCTypeServerIndex;

  /// Size of DbgHeader info
  support::little32_t OptionalDbgHdrSize;

  /// Size of EC stream (what is EC?)
  support::little32_t ECSubstreamSize;

  /// See DbiFlags enum.
  support::ulittle16_t Flags;

  /// See PDB_MachineType enum.
  support::ulittle16_t MachineType;

  /// Pad to 64 bytes
  support::ulittle32_t Reserved;
};
static_assert(sizeof(DbiStreamHeader) == 64, "Invalid DbiStreamHeader size!");

struct SectionContribEntry {
  support::ulittle16_t Section;
  char Padding1[2];
  support::little32_t Offset;
  support::little32_t Size;
  support::ulittle32_t Characteristics;
  support::ulittle16_t ModuleIndex;
  char Padding2[2];
  support::ulittle32_t DataCrc;
  support::ulittle32_t RelocCrc;
};

/// The header preceeding the File Info Substream of the DBI stream.
struct FileInfoSubstreamHeader {
  /// Total # of modules, should match number of records in the ModuleInfo
  /// substream.
  support::ulittle16_t NumModules;

  /// Total # of source files. This value is not accurate because PDB actually
  /// supports more than 64k source files, so we ignore it and compute the value
  /// from other stream fields.
  support::ulittle16_t NumSourceFiles;

  /// Following this header the File Info Substream is laid out as follows:
  ///   ulittle16_t ModIndices[NumModules];
  ///   ulittle16_t ModFileCounts[NumModules];
  ///   ulittle32_t FileNameOffsets[NumSourceFiles];
  ///   char Names[][NumSourceFiles];
  /// with the caveat that `NumSourceFiles` cannot be trusted, so
  /// it is computed by summing the `ModFileCounts` array.
};

struct ModInfoFlags {
  ///  uint16_t fWritten : 1;   // True if DbiModuleDescriptor is dirty
  ///  uint16_t fECEnabled : 1; // Is EC symbolic info present?  (What is EC?)
  ///  uint16_t unused : 6;     // Reserved
  ///  uint16_t iTSM : 8;       // Type Server Index for this module
  static const uint16_t HasECFlagMask = 0x2;

  static const uint16_t TypeServerIndexMask = 0xFF00;
  static const uint16_t TypeServerIndexShift = 8;
};

/// The header preceeding each entry in the Module Info substream of the DBI
/// stream.
struct ModuleInfoHeader {
  /// Currently opened module. This field is a pointer in the reference
  /// implementation, but that won't work on 64-bit systems, and anyway it
  /// doesn't make sense to read a pointer from a file. For now it is unused,
  /// so just ignore it.
  support::ulittle32_t Mod;

  /// First section contribution of this module.
  SectionContribEntry SC;

  /// See ModInfoFlags definition.
  support::ulittle16_t Flags;

  /// Stream Number of module debug info
  support::ulittle16_t ModDiStream;

  /// Size of local symbol debug info in above stream
  support::ulittle32_t SymBytes;

  /// Size of line number debug info in above stream
  support::ulittle32_t LineBytes;

  /// Size of C13 line number info in above stream
  support::ulittle32_t C13Bytes;

  /// Number of files contributing to this module
  support::ulittle16_t NumFiles;

  /// Padding so the next field is 4-byte aligned.
  char Padding1[2];

  /// Array of [0..NumFiles) DBI name buffer offsets.  This field is a pointer
  /// in the reference implementation, but as with `Mod`, we ignore it for now
  /// since it is unused.
  support::ulittle32_t FileNameOffs;

  /// Name Index for src file name
  support::ulittle32_t SrcFileNameNI;

  /// Name Index for path to compiler PDB
  support::ulittle32_t PdbFilePathNI;

  /// Following this header are two zero terminated strings.
  /// char ModuleName[];
  /// char ObjFileName[];
};

/// Defines a 128-bit unique identifier.  This maps to a GUID on Windows, but
/// is abstracted here for the purposes of non-Windows platforms that don't have
/// the GUID structure defined.
struct PDB_UniqueId {
  uint8_t Guid[16];
};

inline bool operator==(const PDB_UniqueId &LHS, const PDB_UniqueId &RHS) {
  return 0 == ::memcmp(LHS.Guid, RHS.Guid, sizeof(LHS.Guid));
}

// The header preceeding the global TPI stream.
// This corresponds to `HDR` in PDB/dbi/tpi.h.
struct TpiStreamHeader {
  struct EmbeddedBuf {
    support::little32_t Off;
    support::ulittle32_t Length;
  };

  support::ulittle32_t Version;
  support::ulittle32_t HeaderSize;
  support::ulittle32_t TypeIndexBegin;
  support::ulittle32_t TypeIndexEnd;
  support::ulittle32_t TypeRecordBytes;

  // The following members correspond to `TpiHash` in PDB/dbi/tpi.h.
  support::ulittle16_t HashStreamIndex;
  support::ulittle16_t HashAuxStreamIndex;
  support::ulittle32_t HashKeySize;
  support::ulittle32_t NumHashBuckets;

  EmbeddedBuf HashValueBuffer;
  EmbeddedBuf IndexOffsetBuffer;
  EmbeddedBuf HashAdjBuffer;
};

const uint32_t MinTpiHashBuckets = 0x1000;
const uint32_t MaxTpiHashBuckets = 0x40000;

/// The header preceeding the global PDB Stream (Stream 1)
struct InfoStreamHeader {
  support::ulittle32_t Version;
  support::ulittle32_t Signature;
  support::ulittle32_t Age;
  PDB_UniqueId Guid;
};

/// The header preceeding the /names stream.
struct StringTableHeader {
  support::ulittle32_t Signature;
  support::ulittle32_t HashVersion;
  support::ulittle32_t ByteSize;
};

const uint32_t StringTableSignature = 0xEFFEEFFE;

} // namespace pdb
} // namespace llvm

#endif
