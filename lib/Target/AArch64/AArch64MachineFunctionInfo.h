//=- AArch64MachineFunctionInfo.h - AArch64 machine function info -*- C++ -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares AArch64-specific per-machine-function information.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_AARCH64_AARCH64MACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_AARCH64_AARCH64MACHINEFUNCTIONINFO_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/IR/Function.h"
#include "llvm/MC/MCLinkerOptimizationHint.h"
#include <cassert>

namespace llvm {

class MachineInstr;

/// AArch64FunctionInfo - This class is derived from MachineFunctionInfo and
/// contains private AArch64-specific information for each MachineFunction.
class AArch64FunctionInfo final : public MachineFunctionInfo {
  /// Number of bytes of arguments this function has on the stack. If the callee
  /// is expected to restore the argument stack this should be a multiple of 16,
  /// all usable during a tail call.
  ///
  /// The alternative would forbid tail call optimisation in some cases: if we
  /// want to transfer control from a function with 8-bytes of stack-argument
  /// space to a function with 16-bytes then misalignment of this value would
  /// make a stack adjustment necessary, which could not be undone by the
  /// callee.
  unsigned BytesInStackArgArea = 0;

  /// The number of bytes to restore to deallocate space for incoming
  /// arguments. Canonically 0 in the C calling convention, but non-zero when
  /// callee is expected to pop the args.
  unsigned ArgumentStackToRestore = 0;

  /// HasStackFrame - True if this function has a stack frame. Set by
  /// determineCalleeSaves().
  bool HasStackFrame = false;

  /// Amount of stack frame size, not including callee-saved registers.
  unsigned LocalStackSize;

  /// Amount of stack frame size used for saving callee-saved registers.
  unsigned CalleeSavedStackSize;
  bool HasCalleeSavedStackSize = false;

  /// Number of TLS accesses using the special (combinable)
  /// _TLS_MODULE_BASE_ symbol.
  unsigned NumLocalDynamicTLSAccesses = 0;

  /// FrameIndex for start of varargs area for arguments passed on the
  /// stack.
  int VarArgsStackIndex = 0;

  /// FrameIndex for start of varargs area for arguments passed in
  /// general purpose registers.
  int VarArgsGPRIndex = 0;

  /// Size of the varargs area for arguments passed in general purpose
  /// registers.
  unsigned VarArgsGPRSize = 0;

  /// FrameIndex for start of varargs area for arguments passed in
  /// floating-point registers.
  int VarArgsFPRIndex = 0;

  /// Size of the varargs area for arguments passed in floating-point
  /// registers.
  unsigned VarArgsFPRSize = 0;

  /// True if this function has a subset of CSRs that is handled explicitly via
  /// copies.
  bool IsSplitCSR = false;

  /// True when the stack gets realigned dynamically because the size of stack
  /// frame is unknown at compile time. e.g., in case of VLAs.
  bool StackRealigned = false;

  /// True when the callee-save stack area has unused gaps that may be used for
  /// other stack allocations.
  bool CalleeSaveStackHasFreeSpace = false;

  /// SRetReturnReg - sret lowering includes returning the value of the
  /// returned struct in a register. This field holds the virtual register into
  /// which the sret argument is passed.
  unsigned SRetReturnReg = 0;
  /// SVE stack size (for predicates and data vectors) are maintained here
  /// rather than in FrameInfo, as the placement and Stack IDs are target
  /// specific.
  uint64_t StackSizeSVE = 0;

  /// HasCalculatedStackSizeSVE indicates whether StackSizeSVE is valid.
  bool HasCalculatedStackSizeSVE = false;

  /// Has a value when it is known whether or not the function uses a
  /// redzone, and no value otherwise.
  /// Initialized during frame lowering, unless the function has the noredzone
  /// attribute, in which case it is set to false at construction.
  Optional<bool> HasRedZone;

  /// ForwardedMustTailRegParms - A list of virtual and physical registers
  /// that must be forwarded to every musttail call.
  SmallVector<ForwardedRegister, 1> ForwardedMustTailRegParms;

  // Offset from SP-at-entry to the tagged base pointer.
  // Tagged base pointer is set up to point to the first (lowest address) tagged
  // stack slot.
  unsigned TaggedBasePointerOffset;

public:
  AArch64FunctionInfo() = default;

  explicit AArch64FunctionInfo(MachineFunction &MF) {
    (void)MF;

    // If we already know that the function doesn't have a redzone, set
    // HasRedZone here.
    if (MF.getFunction().hasFnAttribute(Attribute::NoRedZone))
      HasRedZone = false;
  }

  unsigned getBytesInStackArgArea() const { return BytesInStackArgArea; }
  void setBytesInStackArgArea(unsigned bytes) { BytesInStackArgArea = bytes; }

  unsigned getArgumentStackToRestore() const { return ArgumentStackToRestore; }
  void setArgumentStackToRestore(unsigned bytes) {
    ArgumentStackToRestore = bytes;
  }

  bool hasCalculatedStackSizeSVE() const { return HasCalculatedStackSizeSVE; }

  void setStackSizeSVE(uint64_t S) {
    HasCalculatedStackSizeSVE = true;
    StackSizeSVE = S;
  }

  uint64_t getStackSizeSVE() const { return StackSizeSVE; }

  bool hasStackFrame() const { return HasStackFrame; }
  void setHasStackFrame(bool s) { HasStackFrame = s; }

  bool isStackRealigned() const { return StackRealigned; }
  void setStackRealigned(bool s) { StackRealigned = s; }

  bool hasCalleeSaveStackFreeSpace() const {
    return CalleeSaveStackHasFreeSpace;
  }
  void setCalleeSaveStackHasFreeSpace(bool s) {
    CalleeSaveStackHasFreeSpace = s;
  }

  bool isSplitCSR() const { return IsSplitCSR; }
  void setIsSplitCSR(bool s) { IsSplitCSR = s; }

  void setLocalStackSize(unsigned Size) { LocalStackSize = Size; }
  unsigned getLocalStackSize() const { return LocalStackSize; }

  void setCalleeSavedStackSize(unsigned Size) {
    CalleeSavedStackSize = Size;
    HasCalleeSavedStackSize = true;
  }

  // When CalleeSavedStackSize has not been set (for example when
  // some MachineIR pass is run in isolation), then recalculate
  // the CalleeSavedStackSize directly from the CalleeSavedInfo.
  // Note: This information can only be recalculated after PEI
  // has assigned offsets to the callee save objects.
  unsigned getCalleeSavedStackSize(const MachineFrameInfo &MFI) const {
    bool ValidateCalleeSavedStackSize = false;

#ifndef NDEBUG
    // Make sure the calculated size derived from the CalleeSavedInfo
    // equals the cached size that was calculated elsewhere (e.g. in
    // determineCalleeSaves).
    ValidateCalleeSavedStackSize = HasCalleeSavedStackSize;
#endif

    if (!HasCalleeSavedStackSize || ValidateCalleeSavedStackSize) {
      assert(MFI.isCalleeSavedInfoValid() && "CalleeSavedInfo not calculated");
      if (MFI.getCalleeSavedInfo().empty())
        return 0;

      int64_t MinOffset = std::numeric_limits<int64_t>::max();
      int64_t MaxOffset = std::numeric_limits<int64_t>::min();
      for (const auto &Info : MFI.getCalleeSavedInfo()) {
        int FrameIdx = Info.getFrameIdx();
        int64_t Offset = MFI.getObjectOffset(FrameIdx);
        int64_t ObjSize = MFI.getObjectSize(FrameIdx);
        MinOffset = std::min<int64_t>(Offset, MinOffset);
        MaxOffset = std::max<int64_t>(Offset + ObjSize, MaxOffset);
      }

      unsigned Size = alignTo(MaxOffset - MinOffset, 16);
      assert((!HasCalleeSavedStackSize || getCalleeSavedStackSize() == Size) &&
             "Invalid size calculated for callee saves");
      return Size;
    }

    return getCalleeSavedStackSize();
  }

  unsigned getCalleeSavedStackSize() const {
    assert(HasCalleeSavedStackSize &&
           "CalleeSavedStackSize has not been calculated");
    return CalleeSavedStackSize;
  }

  void incNumLocalDynamicTLSAccesses() { ++NumLocalDynamicTLSAccesses; }
  unsigned getNumLocalDynamicTLSAccesses() const {
    return NumLocalDynamicTLSAccesses;
  }

  Optional<bool> hasRedZone() const { return HasRedZone; }
  void setHasRedZone(bool s) { HasRedZone = s; }

  int getVarArgsStackIndex() const { return VarArgsStackIndex; }
  void setVarArgsStackIndex(int Index) { VarArgsStackIndex = Index; }

  int getVarArgsGPRIndex() const { return VarArgsGPRIndex; }
  void setVarArgsGPRIndex(int Index) { VarArgsGPRIndex = Index; }

  unsigned getVarArgsGPRSize() const { return VarArgsGPRSize; }
  void setVarArgsGPRSize(unsigned Size) { VarArgsGPRSize = Size; }

  int getVarArgsFPRIndex() const { return VarArgsFPRIndex; }
  void setVarArgsFPRIndex(int Index) { VarArgsFPRIndex = Index; }

  unsigned getVarArgsFPRSize() const { return VarArgsFPRSize; }
  void setVarArgsFPRSize(unsigned Size) { VarArgsFPRSize = Size; }

  unsigned getSRetReturnReg() const { return SRetReturnReg; }
  void setSRetReturnReg(unsigned Reg) { SRetReturnReg = Reg; }

  unsigned getJumpTableEntrySize(int Idx) const {
    auto It = JumpTableEntryInfo.find(Idx);
    if (It != JumpTableEntryInfo.end())
      return It->second.first;
    return 4;
  }
  MCSymbol *getJumpTableEntryPCRelSymbol(int Idx) const {
    return JumpTableEntryInfo.find(Idx)->second.second;
  }
  void setJumpTableEntryInfo(int Idx, unsigned Size, MCSymbol *PCRelSym) {
    JumpTableEntryInfo[Idx] = std::make_pair(Size, PCRelSym);
  }

  using SetOfInstructions = SmallPtrSet<const MachineInstr *, 16>;

  const SetOfInstructions &getLOHRelated() const { return LOHRelated; }

  // Shortcuts for LOH related types.
  class MILOHDirective {
    MCLOHType Kind;

    /// Arguments of this directive. Order matters.
    SmallVector<const MachineInstr *, 3> Args;

  public:
    using LOHArgs = ArrayRef<const MachineInstr *>;

    MILOHDirective(MCLOHType Kind, LOHArgs Args)
        : Kind(Kind), Args(Args.begin(), Args.end()) {
      assert(isValidMCLOHType(Kind) && "Invalid LOH directive type!");
    }

    MCLOHType getKind() const { return Kind; }
    LOHArgs getArgs() const { return Args; }
  };

  using MILOHArgs = MILOHDirective::LOHArgs;
  using MILOHContainer = SmallVector<MILOHDirective, 32>;

  const MILOHContainer &getLOHContainer() const { return LOHContainerSet; }

  /// Add a LOH directive of this @p Kind and this @p Args.
  void addLOHDirective(MCLOHType Kind, MILOHArgs Args) {
    LOHContainerSet.push_back(MILOHDirective(Kind, Args));
    LOHRelated.insert(Args.begin(), Args.end());
  }

  SmallVectorImpl<ForwardedRegister> &getForwardedMustTailRegParms() {
    return ForwardedMustTailRegParms;
  }

  unsigned getTaggedBasePointerOffset() const {
    return TaggedBasePointerOffset;
  }
  void setTaggedBasePointerOffset(unsigned Offset) {
    TaggedBasePointerOffset = Offset;
  }

private:
  // Hold the lists of LOHs.
  MILOHContainer LOHContainerSet;
  SetOfInstructions LOHRelated;

  DenseMap<int, std::pair<unsigned, MCSymbol *>> JumpTableEntryInfo;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_AARCH64_AARCH64MACHINEFUNCTIONINFO_H
