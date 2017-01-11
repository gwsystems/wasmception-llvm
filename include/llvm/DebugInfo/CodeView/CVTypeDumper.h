//===-- CVTypeDumper.h - CodeView type info dumper --------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_CODEVIEW_CVTYPEDUMPER_H
#define LLVM_DEBUGINFO_CODEVIEW_CVTYPEDUMPER_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/DebugInfo/CodeView/TypeDatabase.h"
#include "llvm/DebugInfo/CodeView/TypeIndex.h"
#include "llvm/DebugInfo/CodeView/TypeRecord.h"
#include "llvm/DebugInfo/CodeView/TypeVisitorCallbacks.h"

namespace llvm {
class ScopedPrinter;

namespace codeview {

/// Dumper for CodeView type streams found in COFF object files and PDB files.
class CVTypeDumper : public TypeVisitorCallbacks {
public:
  CVTypeDumper(ScopedPrinter *W, bool PrintRecordBytes)
      : W(W), PrintRecordBytes(PrintRecordBytes) {}

  void printTypeIndex(StringRef FieldName, TypeIndex TI);

  /// Dumps one type record.  Returns false if there was a type parsing error,
  /// and true otherwise.  This should be called in order, since the dumper
  /// maintains state about previous records which are necessary for cross
  /// type references.
  Error dump(const CVRecord<TypeLeafKind> &Record);

  /// Dumps the type records in Types. Returns false if there was a type stream
  /// parse error, and true otherwise.
  Error dump(const CVTypeArray &Types);

  /// Dumps the type records in Data. Returns false if there was a type stream
  /// parse error, and true otherwise. Use this method instead of the
  /// CVTypeArray overload when type records are laid out contiguously in
  /// memory.
  Error dump(ArrayRef<uint8_t> Data);

  void setPrinter(ScopedPrinter *P);
  ScopedPrinter *getPrinter() { return W; }

  /// Action to take on unknown types. By default, they are ignored.
  Error visitUnknownType(CVType &Record) override;
  Error visitUnknownMember(CVMemberRecord &Record) override;

  /// Paired begin/end actions for all types. Receives all record data,
  /// including the fixed-length record prefix.
  Error visitTypeBegin(CVType &Record) override;
  Error visitTypeEnd(CVType &Record) override;
  Error visitMemberBegin(CVMemberRecord &Record) override;
  Error visitMemberEnd(CVMemberRecord &Record) override;

#define TYPE_RECORD(EnumName, EnumVal, Name)                                   \
  Error visitKnownRecord(CVType &CVR, Name##Record &Record) override;
#define MEMBER_RECORD(EnumName, EnumVal, Name)                                 \
  Error visitKnownMember(CVMemberRecord &CVR, Name##Record &Record) override;
#define TYPE_RECORD_ALIAS(EnumName, EnumVal, Name, AliasName)
#define MEMBER_RECORD_ALIAS(EnumName, EnumVal, Name, AliasName)
#include "TypeRecords.def"

private:
  void printMemberAttributes(MemberAttributes Attrs);
  void printMemberAttributes(MemberAccess Access, MethodKind Kind,
                             MethodOptions Options);

  ScopedPrinter *W;

  bool PrintRecordBytes = false;

  TypeDatabase TypeDB;
};

} // end namespace codeview
} // end namespace llvm

#endif // LLVM_DEBUGINFO_CODEVIEW_TYPEDUMPER_H
