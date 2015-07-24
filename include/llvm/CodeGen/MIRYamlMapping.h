//===- MIRYAMLMapping.h - Describes the mapping between MIR and YAML ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The MIR serialization library is currently a work in progress. It can't
// serialize machine functions at this time.
//
// This file implements the mapping between various MIR data structures and
// their corresponding YAML representation.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_CODEGEN_MIRYAMLMAPPING_H
#define LLVM_LIB_CODEGEN_MIRYAMLMAPPING_H

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/Support/YAMLTraits.h"
#include <vector>

namespace llvm {
namespace yaml {

/// A wrapper around std::string which contains a source range that's being
/// set during parsing.
struct StringValue {
  std::string Value;
  SMRange SourceRange;

  StringValue() {}
  StringValue(std::string Value) : Value(std::move(Value)) {}

  bool operator==(const StringValue &Other) const {
    return Value == Other.Value;
  }
};

template <> struct ScalarTraits<StringValue> {
  static void output(const StringValue &S, void *, llvm::raw_ostream &OS) {
    OS << S.Value;
  }

  static StringRef input(StringRef Scalar, void *Ctx, StringValue &S) {
    S.Value = Scalar.str();
    if (const auto *Node =
            reinterpret_cast<yaml::Input *>(Ctx)->getCurrentNode())
      S.SourceRange = Node->getSourceRange();
    return "";
  }

  static bool mustQuote(StringRef Scalar) { return needsQuotes(Scalar); }
};

struct FlowStringValue : StringValue {
  FlowStringValue() {}
  FlowStringValue(std::string Value) : StringValue(Value) {}
};

template <> struct ScalarTraits<FlowStringValue> {
  static void output(const FlowStringValue &S, void *, llvm::raw_ostream &OS) {
    return ScalarTraits<StringValue>::output(S, nullptr, OS);
  }

  static StringRef input(StringRef Scalar, void *Ctx, FlowStringValue &S) {
    return ScalarTraits<StringValue>::input(Scalar, Ctx, S);
  }

  static bool mustQuote(StringRef Scalar) { return needsQuotes(Scalar); }
};

template <> struct ScalarEnumerationTraits<MachineJumpTableInfo::JTEntryKind> {
  static void enumeration(yaml::IO &IO,
                          MachineJumpTableInfo::JTEntryKind &EntryKind) {
    IO.enumCase(EntryKind, "block-address",
                MachineJumpTableInfo::EK_BlockAddress);
    IO.enumCase(EntryKind, "gp-rel64-block-address",
                MachineJumpTableInfo::EK_GPRel64BlockAddress);
    IO.enumCase(EntryKind, "gp-rel32-block-address",
                MachineJumpTableInfo::EK_GPRel32BlockAddress);
    IO.enumCase(EntryKind, "label-difference32",
                MachineJumpTableInfo::EK_LabelDifference32);
    IO.enumCase(EntryKind, "inline", MachineJumpTableInfo::EK_Inline);
    IO.enumCase(EntryKind, "custom32", MachineJumpTableInfo::EK_Custom32);
  }
};

} // end namespace yaml
} // end namespace llvm

LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::StringValue)
LLVM_YAML_IS_FLOW_SEQUENCE_VECTOR(llvm::yaml::FlowStringValue)

namespace llvm {
namespace yaml {

struct VirtualRegisterDefinition {
  unsigned ID;
  StringValue Class;
  StringValue PreferredRegister;
  // TODO: Serialize the target specific register hints.
};

template <> struct MappingTraits<VirtualRegisterDefinition> {
  static void mapping(IO &YamlIO, VirtualRegisterDefinition &Reg) {
    YamlIO.mapRequired("id", Reg.ID);
    YamlIO.mapRequired("class", Reg.Class);
    YamlIO.mapOptional("preferred-register", Reg.PreferredRegister,
                       StringValue()); // Don't print out when it's empty.
  }

  static const bool flow = true;
};

struct MachineBasicBlock {
  unsigned ID;
  StringValue Name;
  unsigned Alignment = 0;
  bool IsLandingPad = false;
  bool AddressTaken = false;
  // TODO: Serialize the successor weights.
  std::vector<FlowStringValue> Successors;
  std::vector<FlowStringValue> LiveIns;
  std::vector<StringValue> Instructions;
};

template <> struct MappingTraits<MachineBasicBlock> {
  static void mapping(IO &YamlIO, MachineBasicBlock &MBB) {
    YamlIO.mapRequired("id", MBB.ID);
    YamlIO.mapOptional("name", MBB.Name,
                       StringValue()); // Don't print out an empty name.
    YamlIO.mapOptional("alignment", MBB.Alignment);
    YamlIO.mapOptional("isLandingPad", MBB.IsLandingPad);
    YamlIO.mapOptional("addressTaken", MBB.AddressTaken);
    YamlIO.mapOptional("successors", MBB.Successors);
    YamlIO.mapOptional("liveins", MBB.LiveIns);
    YamlIO.mapOptional("instructions", MBB.Instructions);
  }
};

/// Serializable representation of stack object from the MachineFrameInfo class.
///
/// The flags 'isImmutable' and 'isAliased' aren't serialized, as they are
/// determined by the object's type and frame information flags.
/// Dead stack objects aren't serialized.
///
/// TODO: Determine isPreallocated flag by mapping between objects and local
/// objects (Serialize local objects).
struct MachineStackObject {
  enum ObjectType { DefaultType, SpillSlot, VariableSized };
  unsigned ID;
  StringValue Name;
  // TODO: Serialize unnamed LLVM alloca reference.
  ObjectType Type = DefaultType;
  int64_t Offset = 0;
  uint64_t Size = 0;
  unsigned Alignment = 0;
};

template <> struct ScalarEnumerationTraits<MachineStackObject::ObjectType> {
  static void enumeration(yaml::IO &IO, MachineStackObject::ObjectType &Type) {
    IO.enumCase(Type, "default", MachineStackObject::DefaultType);
    IO.enumCase(Type, "spill-slot", MachineStackObject::SpillSlot);
    IO.enumCase(Type, "variable-sized", MachineStackObject::VariableSized);
  }
};

template <> struct MappingTraits<MachineStackObject> {
  static void mapping(yaml::IO &YamlIO, MachineStackObject &Object) {
    YamlIO.mapRequired("id", Object.ID);
    YamlIO.mapOptional("name", Object.Name,
                       StringValue()); // Don't print out an empty name.
    YamlIO.mapOptional(
        "type", Object.Type,
        MachineStackObject::DefaultType); // Don't print the default type.
    YamlIO.mapOptional("offset", Object.Offset);
    if (Object.Type != MachineStackObject::VariableSized)
      YamlIO.mapRequired("size", Object.Size);
    YamlIO.mapOptional("alignment", Object.Alignment);
  }

  static const bool flow = true;
};

/// Serializable representation of the fixed stack object from the
/// MachineFrameInfo class.
struct FixedMachineStackObject {
  enum ObjectType { DefaultType, SpillSlot };
  unsigned ID;
  ObjectType Type = DefaultType;
  int64_t Offset = 0;
  uint64_t Size = 0;
  unsigned Alignment = 0;
  bool IsImmutable = false;
  bool IsAliased = false;
};

template <>
struct ScalarEnumerationTraits<FixedMachineStackObject::ObjectType> {
  static void enumeration(yaml::IO &IO,
                          FixedMachineStackObject::ObjectType &Type) {
    IO.enumCase(Type, "default", FixedMachineStackObject::DefaultType);
    IO.enumCase(Type, "spill-slot", FixedMachineStackObject::SpillSlot);
  }
};

template <> struct MappingTraits<FixedMachineStackObject> {
  static void mapping(yaml::IO &YamlIO, FixedMachineStackObject &Object) {
    YamlIO.mapRequired("id", Object.ID);
    YamlIO.mapOptional(
        "type", Object.Type,
        FixedMachineStackObject::DefaultType); // Don't print the default type.
    YamlIO.mapOptional("offset", Object.Offset);
    YamlIO.mapOptional("size", Object.Size);
    YamlIO.mapOptional("alignment", Object.Alignment);
    if (Object.Type != FixedMachineStackObject::SpillSlot) {
      YamlIO.mapOptional("isImmutable", Object.IsImmutable);
      YamlIO.mapOptional("isAliased", Object.IsAliased);
    }
  }

  static const bool flow = true;
};

struct MachineConstantPoolValue {
  unsigned ID;
  StringValue Value;
  unsigned Alignment = 0;
};

template <> struct MappingTraits<MachineConstantPoolValue> {
  static void mapping(IO &YamlIO, MachineConstantPoolValue &Constant) {
    YamlIO.mapRequired("id", Constant.ID);
    YamlIO.mapOptional("value", Constant.Value);
    YamlIO.mapOptional("alignment", Constant.Alignment);
  }
};

struct MachineJumpTable {
  struct Entry {
    unsigned ID;
    std::vector<FlowStringValue> Blocks;
  };

  MachineJumpTableInfo::JTEntryKind Kind = MachineJumpTableInfo::EK_Custom32;
  std::vector<Entry> Entries;
};

template <> struct MappingTraits<MachineJumpTable::Entry> {
  static void mapping(IO &YamlIO, MachineJumpTable::Entry &Entry) {
    YamlIO.mapRequired("id", Entry.ID);
    YamlIO.mapOptional("blocks", Entry.Blocks);
  }
};

} // end namespace yaml
} // end namespace llvm

LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::VirtualRegisterDefinition)
LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::MachineBasicBlock)
LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::MachineStackObject)
LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::FixedMachineStackObject)
LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::MachineConstantPoolValue)
LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::yaml::MachineJumpTable::Entry)

namespace llvm {
namespace yaml {

template <> struct MappingTraits<MachineJumpTable> {
  static void mapping(IO &YamlIO, MachineJumpTable &JT) {
    YamlIO.mapRequired("kind", JT.Kind);
    YamlIO.mapOptional("entries", JT.Entries);
  }
};

/// Serializable representation of MachineFrameInfo.
///
/// Doesn't serialize attributes like 'StackAlignment', 'IsStackRealignable' and
/// 'RealignOption' as they are determined by the target and LLVM function
/// attributes.
/// It also doesn't serialize attributes like 'NumFixedObject' and
/// 'HasVarSizedObjects' as they are determined by the frame objects themselves.
struct MachineFrameInfo {
  bool IsFrameAddressTaken = false;
  bool IsReturnAddressTaken = false;
  bool HasStackMap = false;
  bool HasPatchPoint = false;
  uint64_t StackSize = 0;
  int OffsetAdjustment = 0;
  unsigned MaxAlignment = 0;
  bool AdjustsStack = false;
  bool HasCalls = false;
  // TODO: Serialize StackProtectorIdx and FunctionContextIdx
  unsigned MaxCallFrameSize = 0;
  // TODO: Serialize callee saved info.
  // TODO: Serialize local frame objects.
  bool HasOpaqueSPAdjustment = false;
  bool HasVAStart = false;
  bool HasMustTailInVarArgFunc = false;
  // TODO: Serialize save and restore MBB references.
};

template <> struct MappingTraits<MachineFrameInfo> {
  static void mapping(IO &YamlIO, MachineFrameInfo &MFI) {
    YamlIO.mapOptional("isFrameAddressTaken", MFI.IsFrameAddressTaken);
    YamlIO.mapOptional("isReturnAddressTaken", MFI.IsReturnAddressTaken);
    YamlIO.mapOptional("hasStackMap", MFI.HasStackMap);
    YamlIO.mapOptional("hasPatchPoint", MFI.HasPatchPoint);
    YamlIO.mapOptional("stackSize", MFI.StackSize);
    YamlIO.mapOptional("offsetAdjustment", MFI.OffsetAdjustment);
    YamlIO.mapOptional("maxAlignment", MFI.MaxAlignment);
    YamlIO.mapOptional("adjustsStack", MFI.AdjustsStack);
    YamlIO.mapOptional("hasCalls", MFI.HasCalls);
    YamlIO.mapOptional("maxCallFrameSize", MFI.MaxCallFrameSize);
    YamlIO.mapOptional("hasOpaqueSPAdjustment", MFI.HasOpaqueSPAdjustment);
    YamlIO.mapOptional("hasVAStart", MFI.HasVAStart);
    YamlIO.mapOptional("hasMustTailInVarArgFunc", MFI.HasMustTailInVarArgFunc);
  }
};

struct MachineFunction {
  StringRef Name;
  unsigned Alignment = 0;
  bool ExposesReturnsTwice = false;
  bool HasInlineAsm = false;
  // Register information
  bool IsSSA = false;
  bool TracksRegLiveness = false;
  bool TracksSubRegLiveness = false;
  std::vector<VirtualRegisterDefinition> VirtualRegisters;
  // TODO: Serialize the various register masks.
  // TODO: Serialize live in registers.
  // Frame information
  MachineFrameInfo FrameInfo;
  std::vector<FixedMachineStackObject> FixedStackObjects;
  std::vector<MachineStackObject> StackObjects;
  std::vector<MachineConstantPoolValue> Constants; /// Constant pool.
  MachineJumpTable JumpTableInfo;

  std::vector<MachineBasicBlock> BasicBlocks;
};

template <> struct MappingTraits<MachineFunction> {
  static void mapping(IO &YamlIO, MachineFunction &MF) {
    YamlIO.mapRequired("name", MF.Name);
    YamlIO.mapOptional("alignment", MF.Alignment);
    YamlIO.mapOptional("exposesReturnsTwice", MF.ExposesReturnsTwice);
    YamlIO.mapOptional("hasInlineAsm", MF.HasInlineAsm);
    YamlIO.mapOptional("isSSA", MF.IsSSA);
    YamlIO.mapOptional("tracksRegLiveness", MF.TracksRegLiveness);
    YamlIO.mapOptional("tracksSubRegLiveness", MF.TracksSubRegLiveness);
    YamlIO.mapOptional("registers", MF.VirtualRegisters);
    YamlIO.mapOptional("frameInfo", MF.FrameInfo);
    YamlIO.mapOptional("fixedStack", MF.FixedStackObjects);
    YamlIO.mapOptional("stack", MF.StackObjects);
    YamlIO.mapOptional("constants", MF.Constants);
    if (!YamlIO.outputting() || !MF.JumpTableInfo.Entries.empty())
      YamlIO.mapOptional("jumpTable", MF.JumpTableInfo);
    YamlIO.mapOptional("body", MF.BasicBlocks);
  }
};

} // end namespace yaml
} // end namespace llvm

#endif
