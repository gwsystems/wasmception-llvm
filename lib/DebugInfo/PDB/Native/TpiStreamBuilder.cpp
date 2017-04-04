//===- TpiStreamBuilder.cpp -   -------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/DebugInfo/PDB/Native/TpiStreamBuilder.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/DebugInfo/CodeView/TypeIndex.h"
#include "llvm/DebugInfo/CodeView/TypeRecord.h"
#include "llvm/DebugInfo/MSF/MSFBuilder.h"
#include "llvm/DebugInfo/MSF/MappedBlockStream.h"
#include "llvm/DebugInfo/PDB/Native/PDBFile.h"
#include "llvm/DebugInfo/PDB/Native/RawError.h"
#include "llvm/DebugInfo/PDB/Native/RawTypes.h"
#include "llvm/DebugInfo/PDB/Native/TpiStream.h"
#include "llvm/Support/Allocator.h"
#include "llvm/Support/BinaryByteStream.h"
#include "llvm/Support/BinaryStreamArray.h"
#include "llvm/Support/BinaryStreamReader.h"
#include "llvm/Support/BinaryStreamWriter.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/Error.h"
#include <algorithm>
#include <cstdint>

using namespace llvm;
using namespace llvm::msf;
using namespace llvm::pdb;
using namespace llvm::support;

TpiStreamBuilder::TpiStreamBuilder(MSFBuilder &Msf, uint32_t StreamIdx)
    : Msf(Msf), Allocator(Msf.getAllocator()), Header(nullptr), Idx(StreamIdx) {
}

TpiStreamBuilder::~TpiStreamBuilder() = default;

void TpiStreamBuilder::setVersionHeader(PdbRaw_TpiVer Version) {
  VerHeader = Version;
}

void TpiStreamBuilder::addTypeRecord(ArrayRef<uint8_t> Record,
                                     Optional<uint32_t> Hash) {
  TypeRecordBytes += Record.size();
  TypeRecords.push_back(Record);
  if (Hash)
    TypeHashes.push_back(*Hash);
}

Error TpiStreamBuilder::finalize() {
  if (Header)
    return Error::success();

  TpiStreamHeader *H = Allocator.Allocate<TpiStreamHeader>();

  uint32_t Count = TypeRecords.size();
  uint32_t HashBufferSize = calculateHashBufferSize();

  H->Version = *VerHeader;
  H->HeaderSize = sizeof(TpiStreamHeader);
  H->TypeIndexBegin = codeview::TypeIndex::FirstNonSimpleIndex;
  H->TypeIndexEnd = H->TypeIndexBegin + Count;
  H->TypeRecordBytes = TypeRecordBytes;

  H->HashStreamIndex = HashStreamIndex;
  H->HashAuxStreamIndex = kInvalidStreamIndex;
  H->HashKeySize = sizeof(ulittle32_t);
  H->NumHashBuckets = MinTpiHashBuckets;

  // Recall that hash values go into a completely different stream identified by
  // the `HashStreamIndex` field of the `TpiStreamHeader`.  Therefore, the data
  // begins at offset 0 of this independent stream.
  H->HashValueBuffer.Off = 0;
  H->HashValueBuffer.Length = HashBufferSize;
  H->HashAdjBuffer.Off = H->HashValueBuffer.Off + H->HashValueBuffer.Length;
  H->HashAdjBuffer.Length = 0;
  H->IndexOffsetBuffer.Off = H->HashAdjBuffer.Off + H->HashAdjBuffer.Length;
  H->IndexOffsetBuffer.Length = 0;

  Header = H;
  return Error::success();
}

uint32_t TpiStreamBuilder::calculateSerializedLength() {
  return sizeof(TpiStreamHeader) + TypeRecordBytes;
}

uint32_t TpiStreamBuilder::calculateHashBufferSize() const {
  assert(TypeHashes.size() == TypeHashes.size() &&
         "either all or no type records should have hashes");
  return TypeHashes.size() * sizeof(ulittle32_t);
}

Error TpiStreamBuilder::finalizeMsfLayout() {
  uint32_t Length = calculateSerializedLength();
  if (auto EC = Msf.setStreamSize(Idx, Length))
    return EC;

  uint32_t HashBufferSize = calculateHashBufferSize();

  if (HashBufferSize == 0)
    return Error::success();

  auto ExpectedIndex = Msf.addStream(HashBufferSize);
  if (!ExpectedIndex)
    return ExpectedIndex.takeError();
  HashStreamIndex = *ExpectedIndex;
  ulittle32_t *H = Allocator.Allocate<ulittle32_t>(TypeHashes.size());
  MutableArrayRef<ulittle32_t> HashBuffer(H, TypeHashes.size());
  for (uint32_t I = 0; I < TypeHashes.size(); ++I) {
    HashBuffer[I] = TypeHashes[I] % MinTpiHashBuckets;
  }
  ArrayRef<uint8_t> Bytes(reinterpret_cast<const uint8_t *>(HashBuffer.data()),
                          HashBufferSize);
  HashValueStream =
      llvm::make_unique<BinaryByteStream>(Bytes, llvm::support::little);
  return Error::success();
}

Error TpiStreamBuilder::commit(const msf::MSFLayout &Layout,
                               WritableBinaryStreamRef Buffer) {
  if (auto EC = finalize())
    return EC;

  auto InfoS =
      WritableMappedBlockStream::createIndexedStream(Layout, Buffer, Idx);

  BinaryStreamWriter Writer(*InfoS);
  if (auto EC = Writer.writeObject(*Header))
    return EC;

  for (auto Rec : TypeRecords)
    if (auto EC = Writer.writeBytes(Rec))
      return EC;

  if (HashStreamIndex != kInvalidStreamIndex) {
    auto HVS = WritableMappedBlockStream::createIndexedStream(Layout, Buffer,
                                                              HashStreamIndex);
    BinaryStreamWriter HW(*HVS);
    if (auto EC = HW.writeStreamRef(*HashValueStream))
      return EC;
  }

  return Error::success();
}
