//===-- X86TargetFrameLowering.h - Define frame lowering for X86 -*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class implements X86-specific bits of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_X86_X86FRAMELOWERING_H
#define LLVM_LIB_TARGET_X86_X86FRAMELOWERING_H

#include "llvm/Target/TargetFrameLowering.h"

namespace llvm {

class X86Subtarget;
class X86RegisterInfo;

class X86FrameLowering : public TargetFrameLowering {
public:
  X86FrameLowering(const X86Subtarget &STI, unsigned StackAlignOverride);

  // Cached subtarget predicates.

  const X86Subtarget &STI;
  const TargetInstrInfo &TII;
  const X86RegisterInfo *RegInfo;

  unsigned SlotSize;

  /// Is64Bit implies that x86_64 instructions are available.
  bool Is64Bit;

  bool IsLP64;

  /// True if the 64-bit frame or stack pointer should be used. True for most
  /// 64-bit targets with the exception of x32. If this is false, 32-bit
  /// instruction operands should be used to manipulate StackPtr and FramePtr.
  bool Uses64BitFramePtr;

  /// Emit a call to the target's stack probe function. This is required for all
  /// large stack allocations on Windows. The caller is required to materialize
  /// the number of bytes to probe in RAX/EAX.
  void emitStackProbeCall(MachineFunction &MF, MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI, DebugLoc DL) const;

  void emitCalleeSavedFrameMoves(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MBBI,
                                 DebugLoc DL) const;

  /// emitProlog/emitEpilog - These methods insert prolog and epilog code into
  /// the function.
  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

  void adjustForSegmentedStacks(MachineFunction &MF,
                                MachineBasicBlock &PrologueMBB) const override;

  void adjustForHiPEPrologue(MachineFunction &MF,
                             MachineBasicBlock &PrologueMBB) const override;

  void processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                     RegScavenger *RS = nullptr) const override;

  bool
  assignCalleeSavedSpillSlots(MachineFunction &MF,
                              const TargetRegisterInfo *TRI,
                              std::vector<CalleeSavedInfo> &CSI) const override;

  bool spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MI,
                                 const std::vector<CalleeSavedInfo> &CSI,
                                 const TargetRegisterInfo *TRI) const override;

  bool restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MI,
                                  const std::vector<CalleeSavedInfo> &CSI,
                                  const TargetRegisterInfo *TRI) const override;

  bool hasFP(const MachineFunction &MF) const override;
  bool hasReservedCallFrame(const MachineFunction &MF) const override;
  bool canSimplifyCallFramePseudos(const MachineFunction &MF) const override;
  bool needsFrameIndexResolution(const MachineFunction &MF) const override;

  int getFrameIndexOffset(const MachineFunction &MF, int FI) const override;
  int getFrameIndexReference(const MachineFunction &MF, int FI,
                             unsigned &FrameReg) const override;

  int getFrameIndexOffsetFromSP(const MachineFunction &MF, int FI) const;
  int getFrameIndexReferenceFromSP(const MachineFunction &MF, int FI,
                                   unsigned &FrameReg) const override;

  void eliminateCallFramePseudoInstr(MachineFunction &MF,
                                 MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MI) const override;

  /// Check the instruction before/after the passed instruction. If
  /// it is an ADD/SUB/LEA instruction it is deleted argument and the
  /// stack adjustment is returned as a positive value for ADD/LEA and
  /// a negative for SUB.
  int mergeSPUpdates(MachineBasicBlock &MBB, MachineBasicBlock::iterator &MBBI,
                     unsigned StackPtr, bool doMergeWithPrevious) const;

  /// Emit a series of instructions to increment / decrement the stack
  /// pointer by a constant value.
  void emitSPUpdate(MachineBasicBlock &MBB, MachineBasicBlock::iterator &MBBI,
                    unsigned StackPtr, int64_t NumBytes, bool Is64BitTarget,
                    bool Is64BitStackPtr, bool UseLEA,
                    const TargetInstrInfo &TII,
                    const TargetRegisterInfo &TRI) const;

  /// Check that LEA can be used on SP in an epilogue sequence for \p MF.
  bool canUseLEAForSPInEpilogue(const MachineFunction &MF) const;

  /// Check whether or not the given \p MBB can be used as a epilogue
  /// for the target.
  /// The epilogue will be inserted before the first terminator of that block.
  /// This method is used by the shrink-wrapping pass to decide if
  /// \p MBB will be correctly handled by the target.
  bool canUseAsEpilogue(const MachineBasicBlock &MBB) const override;

private:
  /// convertArgMovsToPushes - This method tries to convert a call sequence
  /// that uses sub and mov instructions to put the argument onto the stack
  /// into a series of pushes.
  /// Returns true if the transformation succeeded, false if not.
  bool convertArgMovsToPushes(MachineFunction &MF, 
                              MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I, 
                              uint64_t Amount) const;

  uint64_t calculateMaxStackAlign(const MachineFunction &MF) const;
};

} // End llvm namespace

#endif
