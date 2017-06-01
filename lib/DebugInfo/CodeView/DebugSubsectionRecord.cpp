//===- DebugSubsectionRecord.cpp -----------------------------*- C++-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/DebugInfo/CodeView/DebugSubsectionRecord.h"
#include "llvm/DebugInfo/CodeView/DebugSubsection.h"

#include "llvm/Support/BinaryStreamReader.h"

using namespace llvm;
using namespace llvm::codeview;

DebugSubsectionRecord::DebugSubsectionRecord()
    : Kind(DebugSubsectionKind::None),
      Container(CodeViewContainer::ObjectFile) {}

DebugSubsectionRecord::DebugSubsectionRecord(DebugSubsectionKind Kind,
                                             BinaryStreamRef Data,
                                             CodeViewContainer Container)
    : Kind(Kind), Data(Data), Container(Container) {}

Error DebugSubsectionRecord::initialize(BinaryStreamRef Stream,
                                        DebugSubsectionRecord &Info,
                                        CodeViewContainer Container) {
  const DebugSubsectionHeader *Header;
  BinaryStreamReader Reader(Stream);
  if (auto EC = Reader.readObject(Header))
    return EC;

  DebugSubsectionKind Kind =
      static_cast<DebugSubsectionKind>(uint32_t(Header->Kind));
  switch (Kind) {
  case DebugSubsectionKind::FileChecksums:
  case DebugSubsectionKind::Lines:
  case DebugSubsectionKind::InlineeLines:
    break;
  default:
    llvm_unreachable("Unexpected debug fragment kind!");
  }
  if (auto EC = Reader.readStreamRef(Info.Data, Header->Length))
    return EC;
  Info.Container = Container;
  Info.Kind = Kind;
  return Error::success();
}

uint32_t DebugSubsectionRecord::getRecordLength() const {
  uint32_t Result = sizeof(DebugSubsectionHeader) + Data.getLength();
  assert(Result % alignOf(Container) == 0);
  return Result;
}

DebugSubsectionKind DebugSubsectionRecord::kind() const { return Kind; }

BinaryStreamRef DebugSubsectionRecord::getRecordData() const { return Data; }

DebugSubsectionRecordBuilder::DebugSubsectionRecordBuilder(
    DebugSubsectionKind Kind, DebugSubsection &Frag,
    CodeViewContainer Container)
    : Kind(Kind), Frag(Frag), Container(Container) {}

uint32_t DebugSubsectionRecordBuilder::calculateSerializedLength() {
  uint32_t Size = sizeof(DebugSubsectionHeader) +
                  alignTo(Frag.calculateSerializedSize(), alignOf(Container));
  return Size;
}

Error DebugSubsectionRecordBuilder::commit(BinaryStreamWriter &Writer) {
  assert(Writer.getOffset() % alignOf(Container) == 0 &&
         "Debug Subsection not properly aligned");

  DebugSubsectionHeader Header;
  Header.Kind = uint32_t(Kind);
  Header.Length = calculateSerializedLength() - sizeof(DebugSubsectionHeader);

  if (auto EC = Writer.writeObject(Header))
    return EC;
  if (auto EC = Frag.commit(Writer))
    return EC;
  if (auto EC = Writer.padToAlignment(alignOf(Container)))
    return EC;

  return Error::success();
}
