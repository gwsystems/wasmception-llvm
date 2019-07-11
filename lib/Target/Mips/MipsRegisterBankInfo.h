//===- MipsRegisterBankInfo.h -----------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares the targeting of the RegisterBankInfo class for Mips.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MIPS_MIPSREGISTERBANKINFO_H
#define LLVM_LIB_TARGET_MIPS_MIPSREGISTERBANKINFO_H

#include "llvm/CodeGen/GlobalISel/RegisterBankInfo.h"

#define GET_REGBANK_DECLARATIONS
#include "MipsGenRegisterBank.inc"

namespace llvm {

class TargetRegisterInfo;

class MipsGenRegisterBankInfo : public RegisterBankInfo {
#define GET_TARGET_REGBANK_CLASS
#include "MipsGenRegisterBank.inc"
};

/// This class provides the information for the target register banks.
class MipsRegisterBankInfo final : public MipsGenRegisterBankInfo {
public:
  MipsRegisterBankInfo(const TargetRegisterInfo &TRI);

  const RegisterBank &
  getRegBankFromRegClass(const TargetRegisterClass &RC) const override;

  const InstructionMapping &
  getInstrMapping(const MachineInstr &MI) const override;

  void applyMappingImpl(const OperandsMapper &OpdMapper) const override;

private:
  /// Some instructions are used with both floating point and integer operands.
  /// We assign InstType to such instructions as it helps us to avoid cross bank
  /// copies. InstType deppends on context.
  enum InstType {
    /// Temporary type, when visit(..., nullptr) finishes will convert to one of
    /// the remaining types: Integer, FloatingPoint or Ambiguous.
    NotDetermined,
    /// Connected with instruction that interprets 'bags of bits' as integers.
    /// Select gprb to avoid cross bank copies.
    Integer,
    /// Connected with instruction that interprets 'bags of bits' as floating
    /// point numbers. Select fprb to avoid cross bank copies.
    FloatingPoint,
    /// Represents moving 'bags of bits' around. Select same bank for entire
    /// chain to avoid cross bank copies. Currently we select fprb for s64 and
    /// gprb for s32 Ambiguous operands.
    Ambiguous
  };

  /// Some generic instructions have operands that can be mapped to either fprb
  /// or gprb e.g. for G_LOAD we consider only operand 0 as ambiguous, operand 1
  /// is always gprb since it is a pointer.
  /// This class provides containers for MI's ambiguous:
  /// DefUses : MachineInstrs that use one of MI's ambiguous def operands.
  /// UseDefs : MachineInstrs that define MI's ambiguous use operands.
  class AmbiguousRegDefUseContainer {
    SmallVector<MachineInstr *, 2> DefUses;
    SmallVector<MachineInstr *, 2> UseDefs;

    void addDefUses(Register Reg, const MachineRegisterInfo &MRI);
    void addUseDef(Register Reg, const MachineRegisterInfo &MRI);

  public:
    AmbiguousRegDefUseContainer(const MachineInstr *MI);
    SmallVectorImpl<MachineInstr *> &getDefUses() { return DefUses; }
    SmallVectorImpl<MachineInstr *> &getUseDefs() { return UseDefs; }
  };

  class TypeInfoForMF {
    /// MachineFunction name is used to recognise when MF changes.
    std::string MFName = "";
    /// <key, value> : value is vector of all MachineInstrs that are waiting for
    /// key to figure out type of some of its ambiguous operands.
    DenseMap<const MachineInstr *, SmallVector<const MachineInstr *, 2>>
        WaitingQueues;
    /// Recorded InstTypes for visited instructions.
    DenseMap<const MachineInstr *, InstType> Types;

    /// Recursively visit MI's adjacent instructions and find MI's InstType.
    bool visit(const MachineInstr *MI, const MachineInstr *WaitingForTypeOfMI);

    /// Visit MI's adjacent UseDefs or DefUses.
    bool visitAdjacentInstrs(const MachineInstr *MI,
                             SmallVectorImpl<MachineInstr *> &AdjacentInstrs,
                             bool isDefUse);

    /// Set type for MI, and recursively for all instructions that are
    /// waiting for MI's type.
    void setTypes(const MachineInstr *MI, InstType ITy);

    /// InstType for MI is determined, set it to InstType that corresponds to
    /// physical regisiter that is operand number Op in CopyInst.
    void setTypesAccordingToPhysicalRegister(const MachineInstr *MI,
                                             const MachineInstr *CopyInst,
                                             unsigned Op);

    /// Set default values for MI in order to start visit.
    void startVisit(const MachineInstr *MI) {
      Types.try_emplace(MI, InstType::NotDetermined);
      WaitingQueues.try_emplace(MI);
    }

    /// Returns true if instruction was already visited. Type might not be
    /// determined at this point but will be when visit(..., nullptr) finishes.
    bool wasVisited(const MachineInstr *MI) const { return Types.count(MI); };

    /// Returns recorded type for instruction.
    const InstType &getRecordedTypeForInstr(const MachineInstr *MI) const {
      assert(wasVisited(MI) && "Instruction was not visited!");
      return Types.find(MI)->getSecond();
    };

    /// Change recorded type for instruction.
    void changeRecordedTypeForInstr(const MachineInstr *MI, InstType InstTy) {
      assert(wasVisited(MI) && "Instruction was not visited!");
      Types.find(MI)->getSecond() = InstTy;
    };

    /// Returns WaitingQueue for instruction.
    const SmallVectorImpl<const MachineInstr *> &
    getWaitingQueueFor(const MachineInstr *MI) const {
      assert(WaitingQueues.count(MI) && "Instruction was not visited!");
      return WaitingQueues.find(MI)->getSecond();
    };

    /// Add WaitingForMI to MI's WaitingQueue.
    void addToWaitingQueue(const MachineInstr *MI,
                           const MachineInstr *WaitingForMI) {
      assert(WaitingQueues.count(MI) && "Instruction was not visited!");
      WaitingQueues.find(MI)->getSecond().push_back(WaitingForMI);
    };

  public:
    InstType determineInstType(const MachineInstr *MI);

    void cleanupIfNewFunction(llvm::StringRef FunctionName);
  };
};
} // end namespace llvm
#endif
