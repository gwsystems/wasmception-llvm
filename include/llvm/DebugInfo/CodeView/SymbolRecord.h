//===- SymbolRecord.h -------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_CODEVIEW_SYMBOLRECORD_H
#define LLVM_DEBUGINFO_CODEVIEW_SYMBOLRECORD_H

#include "llvm/ADT/APSInt.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/iterator_range.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/DebugInfo/CodeView/CVRecord.h"
#include "llvm/DebugInfo/CodeView/CodeView.h"
#include "llvm/DebugInfo/CodeView/RecordSerialization.h"
#include "llvm/DebugInfo/CodeView/TypeIndex.h"
#include "llvm/DebugInfo/MSF/StreamArray.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/Error.h"
#include <cstddef>
#include <cstdint>
#include <vector>

namespace llvm {
namespace codeview {

using support::ulittle16_t;
using support::ulittle32_t;
using support::little32_t;

class SymbolRecord {
protected:
  explicit SymbolRecord(SymbolRecordKind Kind) : Kind(Kind) {}

public:
  SymbolRecordKind getKind() const { return Kind; }

private:
  SymbolRecordKind Kind;
};

// S_GPROC32, S_LPROC32, S_GPROC32_ID, S_LPROC32_ID, S_LPROC32_DPC or
// S_LPROC32_DPC_ID
class ProcSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t PtrParent;
    ulittle32_t PtrEnd;
    ulittle32_t PtrNext;
    ulittle32_t CodeSize;
    ulittle32_t DbgStart;
    ulittle32_t DbgEnd;
    TypeIndex FunctionType;
    ulittle32_t CodeOffset;
    ulittle16_t Segment;
    uint8_t Flags; // ProcSymFlags enum
                   // Name: The null-terminated name follows.
  };

  explicit ProcSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ProcSym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *H,
          StringRef Name)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*H), Name(Name) {
  }

  static Expected<ProcSym> deserialize(SymbolRecordKind Kind,
                                       uint32_t RecordOffset,
                                       msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return ProcSym(Kind, RecordOffset, H, Name);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_THUNK32
class Thunk32Sym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Parent;
    ulittle32_t End;
    ulittle32_t Next;
    ulittle32_t Off;
    ulittle16_t Seg;
    ulittle16_t Len;
    uint8_t Ord; // ThunkOrdinal enumeration
                 // Name: The null-terminated name follows.
                 // Variant portion of thunk
  };

  explicit Thunk32Sym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  Thunk32Sym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *H,
             StringRef Name, ArrayRef<uint8_t> VariantData)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*H), Name(Name),
        VariantData(VariantData) {}

  static Expected<Thunk32Sym> deserialize(SymbolRecordKind Kind,
                                          uint32_t RecordOffset,
                                          msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    ArrayRef<uint8_t> VariantData;

    CV_DESERIALIZE(Reader, H, Name, CV_ARRAY_FIELD_TAIL(VariantData));

    return Thunk32Sym(Kind, RecordOffset, H, Name, VariantData);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
  ArrayRef<uint8_t> VariantData;
};

// S_TRAMPOLINE
class TrampolineSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t Type; // TrampolineType enum
    ulittle16_t Size;
    ulittle32_t ThunkOff;
    ulittle32_t TargetOff;
    ulittle16_t ThunkSection;
    ulittle16_t TargetSection;
  };

  explicit TrampolineSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  TrampolineSym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*H) {}

  static Expected<TrampolineSym> deserialize(SymbolRecordKind Kind,
                                             uint32_t RecordOffset,
                                             msf::StreamReader &Reader) {
    const Hdr *H = nullptr;

    CV_DESERIALIZE(Reader, H);

    return TrampolineSym(Kind, RecordOffset, H);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_SECTION
class SectionSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t SectionNumber;
    uint8_t Alignment;
    uint8_t Reserved; // Must be 0
    ulittle32_t Rva;
    ulittle32_t Length;
    ulittle32_t Characteristics;
    // Name: The null-terminated name follows.
  };

  explicit SectionSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  SectionSym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *H,
             StringRef Name)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*H), Name(Name) {
  }

  static Expected<SectionSym> deserialize(SymbolRecordKind Kind,
                                          uint32_t RecordOffset,
                                          msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;

    CV_DESERIALIZE(Reader, H, Name);

    return SectionSym(Kind, RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_COFFGROUP
class CoffGroupSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Size;
    ulittle32_t Characteristics;
    ulittle32_t Offset;
    ulittle16_t Segment;
    // Name: The null-terminated name follows.
  };

  explicit CoffGroupSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  CoffGroupSym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *H,
               StringRef Name)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*H), Name(Name) {
  }

  static Expected<CoffGroupSym> deserialize(SymbolRecordKind Kind,
                                            uint32_t RecordOffset,
                                            msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;

    CV_DESERIALIZE(Reader, H, Name);

    return CoffGroupSym(Kind, RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

class ScopeEndSym : public SymbolRecord {
public:
  explicit ScopeEndSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ScopeEndSym(SymbolRecordKind Kind, uint32_t RecordOffset)
      : SymbolRecord(Kind), RecordOffset(RecordOffset) {}

  static Expected<ScopeEndSym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    return ScopeEndSym(Kind, RecordOffset);
  }
  uint32_t RecordOffset;
};

class CallerSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Count;
  };

  explicit CallerSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  CallerSym(SymbolRecordKind Kind, uint32_t RecordOffset, const Hdr *Header,
            ArrayRef<TypeIndex> Indices)
      : SymbolRecord(Kind), RecordOffset(RecordOffset), Header(*Header),
        Indices(Indices) {}

  static Expected<CallerSym> deserialize(SymbolRecordKind Kind,
                                         uint32_t RecordOffset,
                                         msf::StreamReader &Reader) {
    const Hdr *Header;
    ArrayRef<TypeIndex> Indices;

    CV_DESERIALIZE(Reader, Header, CV_ARRAY_FIELD_N(Indices, Header->Count));

    return CallerSym(Kind, RecordOffset, Header, Indices);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<TypeIndex> Indices;
};

struct BinaryAnnotationIterator {
  struct AnnotationData {
    BinaryAnnotationsOpCode OpCode;
    StringRef Name;
    uint32_t U1;
    uint32_t U2;
    int32_t S1;
  };

  BinaryAnnotationIterator(ArrayRef<uint8_t> Annotations) : Data(Annotations) {}
  BinaryAnnotationIterator() = default;
  BinaryAnnotationIterator(const BinaryAnnotationIterator &Other)
      : Data(Other.Data) {}

  bool operator==(BinaryAnnotationIterator Other) const {
    return Data == Other.Data;
  }

  bool operator!=(BinaryAnnotationIterator Other) const {
    return !(*this == Other);
  }

  BinaryAnnotationIterator &operator=(const BinaryAnnotationIterator Other) {
    Data = Other.Data;
    return *this;
  }

  BinaryAnnotationIterator &operator++() {
    if (!ParseCurrentAnnotation()) {
      *this = BinaryAnnotationIterator();
      return *this;
    }
    Data = Next;
    Next = ArrayRef<uint8_t>();
    Current.reset();
    return *this;
  }

  BinaryAnnotationIterator operator++(int) {
    BinaryAnnotationIterator Orig(*this);
    ++(*this);
    return Orig;
  }

  const AnnotationData &operator*() {
    ParseCurrentAnnotation();
    return Current.getValue();
  }

private:
  static uint32_t GetCompressedAnnotation(ArrayRef<uint8_t> &Annotations) {
    if (Annotations.empty())
      return -1;

    uint8_t FirstByte = Annotations.front();
    Annotations = Annotations.drop_front();

    if ((FirstByte & 0x80) == 0x00)
      return FirstByte;

    if (Annotations.empty())
      return -1;

    uint8_t SecondByte = Annotations.front();
    Annotations = Annotations.drop_front();

    if ((FirstByte & 0xC0) == 0x80)
      return ((FirstByte & 0x3F) << 8) | SecondByte;

    if (Annotations.empty())
      return -1;

    uint8_t ThirdByte = Annotations.front();
    Annotations = Annotations.drop_front();

    if (Annotations.empty())
      return -1;

    uint8_t FourthByte = Annotations.front();
    Annotations = Annotations.drop_front();

    if ((FirstByte & 0xE0) == 0xC0)
      return ((FirstByte & 0x1F) << 24) | (SecondByte << 16) |
             (ThirdByte << 8) | FourthByte;

    return -1;
  };

  static int32_t DecodeSignedOperand(uint32_t Operand) {
    if (Operand & 1)
      return -(Operand >> 1);
    return Operand >> 1;
  };

  static int32_t DecodeSignedOperand(ArrayRef<uint8_t> &Annotations) {
    return DecodeSignedOperand(GetCompressedAnnotation(Annotations));
  };

  bool ParseCurrentAnnotation() {
    if (Current.hasValue())
      return true;

    Next = Data;
    uint32_t Op = GetCompressedAnnotation(Next);
    AnnotationData Result;
    Result.OpCode = static_cast<BinaryAnnotationsOpCode>(Op);
    switch (Result.OpCode) {
    case BinaryAnnotationsOpCode::Invalid:
      Result.Name = "Invalid";
      Next = ArrayRef<uint8_t>();
      break;
    case BinaryAnnotationsOpCode::CodeOffset:
      Result.Name = "CodeOffset";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeCodeOffsetBase:
      Result.Name = "ChangeCodeOffsetBase";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeCodeOffset:
      Result.Name = "ChangeCodeOffset";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeCodeLength:
      Result.Name = "ChangeCodeLength";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeFile:
      Result.Name = "ChangeFile";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeLineEndDelta:
      Result.Name = "ChangeLineEndDelta";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeRangeKind:
      Result.Name = "ChangeRangeKind";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeColumnStart:
      Result.Name = "ChangeColumnStart";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeColumnEnd:
      Result.Name = "ChangeColumnEnd";
      Result.U1 = GetCompressedAnnotation(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeLineOffset:
      Result.Name = "ChangeLineOffset";
      Result.S1 = DecodeSignedOperand(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeColumnEndDelta:
      Result.Name = "ChangeColumnEndDelta";
      Result.S1 = DecodeSignedOperand(Next);
      break;
    case BinaryAnnotationsOpCode::ChangeCodeOffsetAndLineOffset: {
      Result.Name = "ChangeCodeOffsetAndLineOffset";
      uint32_t Annotation = GetCompressedAnnotation(Next);
      Result.S1 = DecodeSignedOperand(Annotation >> 4);
      Result.U1 = Annotation & 0xf;
      break;
    }
    case BinaryAnnotationsOpCode::ChangeCodeLengthAndCodeOffset: {
      Result.Name = "ChangeCodeLengthAndCodeOffset";
      Result.U1 = GetCompressedAnnotation(Next);
      Result.U2 = GetCompressedAnnotation(Next);
      break;
    }
    }
    Current = Result;
    return true;
  }

  Optional<AnnotationData> Current;
  ArrayRef<uint8_t> Data;
  ArrayRef<uint8_t> Next;
};

// S_INLINESITE
class InlineSiteSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t PtrParent;
    ulittle32_t PtrEnd;
    TypeIndex Inlinee;
    // BinaryAnnotations
  };

  explicit InlineSiteSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  InlineSiteSym(uint32_t RecordOffset, const Hdr *H,
                ArrayRef<uint8_t> Annotations)
      : SymbolRecord(SymbolRecordKind::InlineSiteSym),
        RecordOffset(RecordOffset), Header(*H), Annotations(Annotations) {}

  static Expected<InlineSiteSym> deserialize(SymbolRecordKind Kind,
                                             uint32_t RecordOffset,
                                             msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<uint8_t> Annotations;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Annotations));

    return InlineSiteSym(RecordOffset, H, Annotations);
  }

  llvm::iterator_range<BinaryAnnotationIterator> annotations() const {
    return llvm::make_range(BinaryAnnotationIterator(Annotations),
                            BinaryAnnotationIterator());
  }

  uint32_t RecordOffset;
  Hdr Header;

private:
  ArrayRef<uint8_t> Annotations;
};

// S_PUB32
class PublicSym32 : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Index; // Type index, or Metadata token if a managed symbol
    ulittle32_t Off;
    ulittle16_t Seg;
    // Name: The null-terminated name follows.
  };

  explicit PublicSym32(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  PublicSym32(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::PublicSym32), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<PublicSym32> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return PublicSym32(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_REGISTER
class RegisterSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Index;    // Type index or Metadata token
    ulittle16_t Register; // RegisterId enumeration
    // Name: The null-terminated name follows.
  };

  explicit RegisterSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  RegisterSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::RegisterSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<RegisterSym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return RegisterSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_PROCREF, S_LPROCREF
class ProcRefSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t SumName;   // SUC of the name (?)
    ulittle32_t SymOffset; // Offset of actual symbol in $$Symbols
    ulittle16_t Mod;       // Module containing the actual symbol
                           // Name:  The null-terminated name follows.
  };

  explicit ProcRefSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ProcRefSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::ProcRefSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<ProcRefSym> deserialize(SymbolRecordKind Kind,
                                          uint32_t RecordOffset,
                                          msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return ProcRefSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_LOCAL
class LocalSym : public SymbolRecord {
public:
  struct Hdr {
    TypeIndex Type;
    ulittle16_t Flags; // LocalSymFlags enum
                       // Name: The null-terminated name follows.
  };

  explicit LocalSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  LocalSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::LocalSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<LocalSym> deserialize(SymbolRecordKind Kind,
                                        uint32_t RecordOffset,
                                        msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return LocalSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

struct LocalVariableAddrRange {
  ulittle32_t OffsetStart;
  ulittle16_t ISectStart;
  ulittle16_t Range;
};

struct LocalVariableAddrGap {
  ulittle16_t GapStartOffset;
  ulittle16_t Range;
};

enum : uint16_t { MaxDefRange = 0xf000 };

// S_DEFRANGE
class DefRangeSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Program;
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };

  explicit DefRangeSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  DefRangeSym(uint32_t RecordOffset, const Hdr *H,
              ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeSym), RecordOffset(RecordOffset),
        Header(*H), Gaps(Gaps) {}

  static Expected<DefRangeSym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeSym(RecordOffset, H, Gaps);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_SUBFIELD
class DefRangeSubfieldSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Program;
    ulittle16_t OffsetInParent;
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };
  explicit DefRangeSubfieldSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  DefRangeSubfieldSym(uint32_t RecordOffset, const Hdr *H,
                      ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeSubfieldSym),
        RecordOffset(RecordOffset), Header(*H), Gaps(Gaps) {}

  static Expected<DefRangeSubfieldSym> deserialize(SymbolRecordKind Kind,
                                                   uint32_t RecordOffset,
                                                   msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeSubfieldSym(RecordOffset, H, Gaps);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_REGISTER
class DefRangeRegisterSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t Register;
    ulittle16_t MayHaveNoName;
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };

  explicit DefRangeRegisterSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  DefRangeRegisterSym(uint32_t RecordOffset, const Hdr *H,
                      ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeRegisterSym),
        RecordOffset(RecordOffset), Header(*H), Gaps(Gaps) {}

  DefRangeRegisterSym(uint16_t Register, uint16_t MayHaveNoName,
                      ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeRegisterSym), RecordOffset(0),
        Gaps(Gaps) {
    Header.Register = Register;
    Header.MayHaveNoName = MayHaveNoName;
    Header.Range = {};
  }

  static Expected<DefRangeRegisterSym> deserialize(SymbolRecordKind Kind,
                                                   uint32_t RecordOffset,
                                                   msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeRegisterSym(RecordOffset, H, Gaps);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_SUBFIELD_REGISTER
class DefRangeSubfieldRegisterSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t Register; // Register to which the variable is relative
    ulittle16_t MayHaveNoName;
    ulittle32_t OffsetInParent;
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };

  explicit DefRangeSubfieldRegisterSym(SymbolRecordKind Kind)
      : SymbolRecord(Kind) {}
  DefRangeSubfieldRegisterSym(uint32_t RecordOffset, const Hdr *H,
                              ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeSubfieldRegisterSym),
        RecordOffset(RecordOffset), Header(*H), Gaps(Gaps) {}

  DefRangeSubfieldRegisterSym(uint16_t Register, uint16_t MayHaveNoName,
                              uint32_t OffsetInParent,
                              ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeSubfieldRegisterSym),
        RecordOffset(0), Gaps(Gaps) {
    Header.Register = Register;
    Header.MayHaveNoName = MayHaveNoName;
    Header.OffsetInParent = OffsetInParent;
    Header.Range = {};
  }

  static Expected<DefRangeSubfieldRegisterSym>
  deserialize(SymbolRecordKind Kind, uint32_t RecordOffset,
              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeSubfieldRegisterSym(RecordOffset, H, Gaps);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_FRAMEPOINTER_REL
class DefRangeFramePointerRelSym : public SymbolRecord {
public:
  struct Hdr {
    little32_t Offset; // Offset from the frame pointer register
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };

  explicit DefRangeFramePointerRelSym(SymbolRecordKind Kind)
      : SymbolRecord(Kind) {}
  DefRangeFramePointerRelSym(uint32_t RecordOffset, const Hdr *H,
                             ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeFramePointerRelSym),
        RecordOffset(RecordOffset), Header(*H), Gaps(Gaps) {}

  static Expected<DefRangeFramePointerRelSym>
  deserialize(SymbolRecordKind Kind, uint32_t RecordOffset,
              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeFramePointerRelSym(RecordOffset, H, Gaps);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_REGISTER_REL
class DefRangeRegisterRelSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t BaseRegister;
    ulittle16_t Flags;
    little32_t BasePointerOffset;
    LocalVariableAddrRange Range;
    // LocalVariableAddrGap Gaps[];
  };

  explicit DefRangeRegisterRelSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  DefRangeRegisterRelSym(uint32_t RecordOffset, const Hdr *H,
                         ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeRegisterRelSym),
        RecordOffset(RecordOffset), Header(*H), Gaps(Gaps) {}

  DefRangeRegisterRelSym(uint16_t BaseRegister, uint16_t Flags,
                         int32_t BasePointerOffset,
                         ArrayRef<LocalVariableAddrGap> Gaps)
      : SymbolRecord(SymbolRecordKind::DefRangeRegisterRelSym), RecordOffset(0),
        Gaps(Gaps) {
    Header.BaseRegister = BaseRegister;
    Header.Flags = Flags;
    Header.BasePointerOffset = BasePointerOffset;
    Header.Range = {};
  }

  static Expected<DefRangeRegisterRelSym>
  deserialize(SymbolRecordKind Kind, uint32_t RecordOffset,
              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    ArrayRef<LocalVariableAddrGap> Gaps;
    CV_DESERIALIZE(Reader, H, CV_ARRAY_FIELD_TAIL(Gaps));

    return DefRangeRegisterRelSym(RecordOffset, H, Gaps);
  }

  // The flags implement this notional bitfield:
  //   uint16_t IsSubfield : 1;
  //   uint16_t Padding : 3;
  //   uint16_t OffsetInParent : 12;
  enum : uint16_t {
    IsSubfieldFlag = 1,
    OffsetInParentShift = 4,
  };

  bool hasSpilledUDTMember() const { return Header.Flags & IsSubfieldFlag; }
  uint16_t offsetInParent() const { return Header.Flags >> OffsetInParentShift; }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, Range);
  }

  uint32_t RecordOffset;
  Hdr Header;
  ArrayRef<LocalVariableAddrGap> Gaps;
};

// S_DEFRANGE_FRAMEPOINTER_REL_FULL_SCOPE
class DefRangeFramePointerRelFullScopeSym : public SymbolRecord {
public:
  struct Hdr {
    little32_t Offset; // Offset from the frame pointer register
  };

  explicit DefRangeFramePointerRelFullScopeSym(SymbolRecordKind Kind)
      : SymbolRecord(Kind) {}
  DefRangeFramePointerRelFullScopeSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::DefRangeFramePointerRelFullScopeSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<DefRangeFramePointerRelFullScopeSym>
  deserialize(SymbolRecordKind Kind, uint32_t RecordOffset,
              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return DefRangeFramePointerRelFullScopeSym(RecordOffset, H);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_BLOCK32
class BlockSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t PtrParent;
    ulittle32_t PtrEnd;
    ulittle32_t CodeSize;
    ulittle32_t CodeOffset;
    ulittle16_t Segment;
    // Name: The null-terminated name follows.
  };

  explicit BlockSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  BlockSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::BlockSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<BlockSym> deserialize(SymbolRecordKind Kind,
                                        uint32_t RecordOffset,
                                        msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return BlockSym(RecordOffset, H, Name);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_LABEL32
class LabelSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t CodeOffset;
    ulittle16_t Segment;
    uint8_t Flags; // CV_PROCFLAGS
                   // Name: The null-terminated name follows.
  };

  explicit LabelSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  LabelSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::LabelSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<LabelSym> deserialize(SymbolRecordKind Kind,
                                        uint32_t RecordOffset,
                                        msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return LabelSym(RecordOffset, H, Name);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_OBJNAME
class ObjNameSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Signature;
    // Name: The null-terminated name follows.
  };

  explicit ObjNameSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ObjNameSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::ObjNameSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<ObjNameSym> deserialize(SymbolRecordKind Kind,
                                          uint32_t RecordOffset,
                                          msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return ObjNameSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_ENVBLOCK
class EnvBlockSym : public SymbolRecord {
public:
  struct Hdr {
    uint8_t Reserved;
    // Sequence of zero terminated strings.
  };

  explicit EnvBlockSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  EnvBlockSym(uint32_t RecordOffset, const Hdr *H,
              const std::vector<StringRef> &Fields)
      : SymbolRecord(SymbolRecordKind::EnvBlockSym), RecordOffset(RecordOffset),
        Header(*H), Fields(Fields) {}

  static Expected<EnvBlockSym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    std::vector<StringRef> Fields;
    CV_DESERIALIZE(Reader, H, CV_STRING_ARRAY_NULL_TERM(Fields));

    return EnvBlockSym(RecordOffset, H, Fields);
  }

  uint32_t RecordOffset;
  Hdr Header;
  std::vector<StringRef> Fields;
};

// S_EXPORT
class ExportSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle16_t Ordinal;
    ulittle16_t Flags; // ExportFlags
                       // Name: The null-terminated name follows.
  };

  explicit ExportSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ExportSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::ExportSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<ExportSym> deserialize(SymbolRecordKind Kind,
                                         uint32_t RecordOffset,
                                         msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return ExportSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_FILESTATIC
class FileStaticSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Index;             // Type Index
    ulittle32_t ModFilenameOffset; // Index of mod filename in string table
    ulittle16_t Flags;             // LocalSymFlags enum
                                   // Name: The null-terminated name follows.
  };

  explicit FileStaticSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  FileStaticSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::FileStaticSym),
        RecordOffset(RecordOffset), Header(*H), Name(Name) {}

  static Expected<FileStaticSym> deserialize(SymbolRecordKind Kind,
                                             uint32_t RecordOffset,
                                             msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return FileStaticSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_COMPILE2
class Compile2Sym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t flags; // CompileSym2Flags enum
    uint8_t getLanguage() const { return flags & 0xFF; }
    unsigned short Machine; // CPUType enum
    unsigned short VersionFrontendMajor;
    unsigned short VersionFrontendMinor;
    unsigned short VersionFrontendBuild;
    unsigned short VersionBackendMajor;
    unsigned short VersionBackendMinor;
    unsigned short VersionBackendBuild;
    // Version: The null-terminated version string follows.
    // Optional block of zero terminated strings terminated with a double zero.
  };

  explicit Compile2Sym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  Compile2Sym(uint32_t RecordOffset, const Hdr *H, StringRef Version)
      : SymbolRecord(SymbolRecordKind::Compile2Sym), RecordOffset(RecordOffset),
        Header(*H), Version(Version) {}

  static Expected<Compile2Sym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Version;
    CV_DESERIALIZE(Reader, H, Version);

    return Compile2Sym(RecordOffset, H, Version);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Version;
};

// S_COMPILE3
class Compile3Sym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t flags; // CompileSym3Flags enum
    uint8_t getLanguage() const { return flags & 0xff; }
    ulittle16_t Machine; // CPUType enum
    ulittle16_t VersionFrontendMajor;
    ulittle16_t VersionFrontendMinor;
    ulittle16_t VersionFrontendBuild;
    ulittle16_t VersionFrontendQFE;
    ulittle16_t VersionBackendMajor;
    ulittle16_t VersionBackendMinor;
    ulittle16_t VersionBackendBuild;
    ulittle16_t VersionBackendQFE;
    // VersionString: The null-terminated version string follows.
  };

  explicit Compile3Sym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  Compile3Sym(uint32_t RecordOffset, const Hdr *H, StringRef Version)
      : SymbolRecord(SymbolRecordKind::Compile3Sym), RecordOffset(RecordOffset),
        Header(*H), Version(Version) {}

  static Expected<Compile3Sym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Version;
    CV_DESERIALIZE(Reader, H, Version);

    return Compile3Sym(RecordOffset, H, Version);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Version;
};

// S_FRAMEPROC
class FrameProcSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t TotalFrameBytes;
    ulittle32_t PaddingFrameBytes;
    ulittle32_t OffsetToPadding;
    ulittle32_t BytesOfCalleeSavedRegisters;
    ulittle32_t OffsetOfExceptionHandler;
    ulittle16_t SectionIdOfExceptionHandler;
    ulittle32_t Flags;
  };

  explicit FrameProcSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  FrameProcSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::FrameProcSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<FrameProcSym> deserialize(SymbolRecordKind Kind,
                                            uint32_t RecordOffset,
                                            msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return FrameProcSym(RecordOffset, H);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_CALLSITEINFO
class CallSiteInfoSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t CodeOffset;
    ulittle16_t Segment;
    ulittle16_t Reserved;
    TypeIndex Type;
  };

  explicit CallSiteInfoSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  CallSiteInfoSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::CallSiteInfoSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<CallSiteInfoSym> deserialize(SymbolRecordKind Kind,
                                               uint32_t RecordOffset,
                                               msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return CallSiteInfoSym(RecordOffset, H);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_HEAPALLOCSITE
class HeapAllocationSiteSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t CodeOffset;
    ulittle16_t Segment;
    ulittle16_t CallInstructionSize;
    TypeIndex Type;
  };

  explicit HeapAllocationSiteSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  HeapAllocationSiteSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::HeapAllocationSiteSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<HeapAllocationSiteSym>
  deserialize(SymbolRecordKind Kind, uint32_t RecordOffset,
              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return HeapAllocationSiteSym(RecordOffset, H);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_FRAMECOOKIE
class FrameCookieSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t CodeOffset;
    ulittle16_t Register;
    uint8_t CookieKind;
    uint8_t Flags;
  };

  explicit FrameCookieSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  FrameCookieSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::FrameCookieSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<FrameCookieSym> deserialize(SymbolRecordKind Kind,
                                              uint32_t RecordOffset,
                                              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return FrameCookieSym(RecordOffset, H);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, CodeOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_UDT, S_COBOLUDT
class UDTSym : public SymbolRecord {
public:
  struct Hdr {
    TypeIndex Type; // Type of the UDT
                    // Name: The null-terminated name follows.
  };

  explicit UDTSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  UDTSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::UDTSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<UDTSym> deserialize(SymbolRecordKind Kind,
                                      uint32_t RecordOffset,
                                      msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return UDTSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_BUILDINFO
class BuildInfoSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t BuildId;
  };

  explicit BuildInfoSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  BuildInfoSym(uint32_t RecordOffset, const Hdr *H)
      : SymbolRecord(SymbolRecordKind::BuildInfoSym),
        RecordOffset(RecordOffset), Header(*H) {}

  static Expected<BuildInfoSym> deserialize(SymbolRecordKind Kind,
                                            uint32_t RecordOffset,
                                            msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    CV_DESERIALIZE(Reader, H);

    return BuildInfoSym(RecordOffset, H);
  }

  uint32_t RecordOffset;
  Hdr Header;
};

// S_BPREL32
class BPRelativeSym : public SymbolRecord {
public:
  struct Hdr {
    little32_t Offset; // Offset from the base pointer register
    TypeIndex Type;    // Type of the variable
                       // Name: The null-terminated name follows.
  };

  explicit BPRelativeSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  BPRelativeSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::BPRelativeSym),
        RecordOffset(RecordOffset), Header(*H), Name(Name) {}

  static Expected<BPRelativeSym> deserialize(SymbolRecordKind Kind,
                                             uint32_t RecordOffset,
                                             msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return BPRelativeSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_REGREL32
class RegRelativeSym : public SymbolRecord {
public:
  struct Hdr {
    ulittle32_t Offset;   // Offset from the register
    TypeIndex Type;       // Type of the variable
    ulittle16_t Register; // Register to which the variable is relative
                          // Name: The null-terminated name follows.
  };

  explicit RegRelativeSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  RegRelativeSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::RegRelativeSym),
        RecordOffset(RecordOffset), Header(*H), Name(Name) {}

  static Expected<RegRelativeSym> deserialize(SymbolRecordKind Kind,
                                              uint32_t RecordOffset,
                                              msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return RegRelativeSym(RecordOffset, H, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_CONSTANT, S_MANCONSTANT
class ConstantSym : public SymbolRecord {
public:
  struct Hdr {
    TypeIndex Type;
    // Value: The value of the constant.
    // Name: The null-terminated name follows.
  };

  explicit ConstantSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ConstantSym(uint32_t RecordOffset, const Hdr *H, const APSInt &Value,
              StringRef Name)
      : SymbolRecord(SymbolRecordKind::ConstantSym), RecordOffset(RecordOffset),
        Header(*H), Value(Value), Name(Name) {}

  static Expected<ConstantSym> deserialize(SymbolRecordKind Kind,
                                           uint32_t RecordOffset,
                                           msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    APSInt Value;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Value, Name);

    return ConstantSym(RecordOffset, H, Value, Name);
  }

  uint32_t RecordOffset;
  Hdr Header;
  APSInt Value;
  StringRef Name;
};

// S_LDATA32, S_GDATA32, S_LMANDATA, S_GMANDATA
class DataSym : public SymbolRecord {
public:
  struct Hdr {
    TypeIndex Type;
    ulittle32_t DataOffset;
    ulittle16_t Segment;
    // Name: The null-terminated name follows.
  };

  explicit DataSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  DataSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::DataSym), RecordOffset(RecordOffset),
        Header(*H), Name(Name) {}

  static Expected<DataSym> deserialize(SymbolRecordKind Kind,
                                       uint32_t RecordOffset,
                                       msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return DataSym(RecordOffset, H, Name);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, DataOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

// S_LTHREAD32, S_GTHREAD32
class ThreadLocalDataSym : public SymbolRecord {
public:
  struct Hdr {
    TypeIndex Type;
    ulittle32_t DataOffset;
    ulittle16_t Segment;
    // Name: The null-terminated name follows.
  };

  explicit ThreadLocalDataSym(SymbolRecordKind Kind) : SymbolRecord(Kind) {}
  ThreadLocalDataSym(uint32_t RecordOffset, const Hdr *H, StringRef Name)
      : SymbolRecord(SymbolRecordKind::ThreadLocalDataSym),
        RecordOffset(RecordOffset), Header(*H), Name(Name) {}

  static Expected<ThreadLocalDataSym> deserialize(SymbolRecordKind Kind,
                                                  uint32_t RecordOffset,
                                                  msf::StreamReader &Reader) {
    const Hdr *H = nullptr;
    StringRef Name;
    CV_DESERIALIZE(Reader, H, Name);

    return ThreadLocalDataSym(RecordOffset, H, Name);
  }

  uint32_t getRelocationOffset() const {
    return RecordOffset + offsetof(Hdr, DataOffset);
  }

  uint32_t RecordOffset;
  Hdr Header;
  StringRef Name;
};

typedef CVRecord<SymbolKind> CVSymbol;
typedef msf::VarStreamArray<CVSymbol> CVSymbolArray;

} // end namespace codeview
} // end namespace llvm

#endif // LLVM_DEBUGINFO_CODEVIEW_SYMBOLRECORD_H
