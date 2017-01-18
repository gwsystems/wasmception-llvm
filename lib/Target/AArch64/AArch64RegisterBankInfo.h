//===- AArch64RegisterBankInfo -----------------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares the targeting of the RegisterBankInfo class for AArch64.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_AARCH64_AARCH64REGISTERBANKINFO_H
#define LLVM_LIB_TARGET_AARCH64_AARCH64REGISTERBANKINFO_H

#include "llvm/CodeGen/GlobalISel/RegisterBankInfo.h"

namespace llvm {

class TargetRegisterInfo;

namespace AArch64 {
enum {
  GPRRegBankID = 0, /// General Purpose Registers: W, X.
  FPRRegBankID = 1, /// Floating Point/Vector Registers: B, H, S, D, Q.
  CCRRegBankID = 2, /// Conditional register: NZCV.
  NumRegisterBanks
};
} // End AArch64 namespace.

class AArch64GenRegisterBankInfo : public RegisterBankInfo {
private:
  static RegisterBank *RegBanks[];

protected:
  AArch64GenRegisterBankInfo();

  enum PartialMappingIdx {
    PMI_None = -1,
    PMI_GPR32 = 1,
    PMI_GPR64,
    PMI_FPR32,
    PMI_FPR64,
    PMI_FPR128,
    PMI_FPR256,
    PMI_FPR512,
    PMI_FirstGPR = PMI_GPR32,
    PMI_LastGPR = PMI_GPR64,
    PMI_FirstFPR = PMI_FPR32,
    PMI_LastFPR = PMI_FPR512,
    PMI_Min = PMI_FirstGPR,
  };

  static RegisterBankInfo::PartialMapping PartMappings[];
  static RegisterBankInfo::ValueMapping ValMappings[];
  static PartialMappingIdx BankIDToCopyMapIdx[];

  enum ValueMappingIdx {
    First3OpsIdx = 0,
    Last3OpsIdx = 18,
    DistanceBetweenRegBanks = 3,
    FirstCrossRegCpyIdx = 21,
    LastCrossRegCpyIdx = 27,
    DistanceBetweenCrossRegCpy = 2
  };

  static bool checkPartialMap(unsigned Idx, unsigned ValStartIdx,
                              unsigned ValLength, const RegisterBank &RB);
  static bool checkValueMapImpl(unsigned Idx, unsigned FirstInBank,
                                unsigned Size, unsigned Offset);
  static bool checkPartialMappingIdx(PartialMappingIdx FirstAlias,
                                     PartialMappingIdx LastAlias,
                                     ArrayRef<PartialMappingIdx> Order);

  static unsigned getRegBankBaseIdxOffset(unsigned RBIdx, unsigned Size);

  /// Get the pointer to the ValueMapping representing the RegisterBank
  /// at \p RBIdx with a size of \p Size.
  ///
  /// The returned mapping works for instructions with the same kind of
  /// operands for up to 3 operands.
  ///
  /// \pre \p RBIdx != PartialMappingIdx::None
  static const RegisterBankInfo::ValueMapping *
  getValueMapping(PartialMappingIdx RBIdx, unsigned Size);

  /// Get the pointer to the ValueMapping of the operands of a copy
  /// instruction from the \p SrcBankID register bank to the \p DstBankID
  /// register bank with a size of \p Size.
  static const RegisterBankInfo::ValueMapping *
  getCopyMapping(unsigned DstBankID, unsigned SrcBankID, unsigned Size);
};

/// This class provides the information for the target register banks.
class AArch64RegisterBankInfo final : public AArch64GenRegisterBankInfo {
  /// See RegisterBankInfo::applyMapping.
  void applyMappingImpl(const OperandsMapper &OpdMapper) const override;

  /// Get an instruction mapping where all the operands map to
  /// the same register bank and have similar size.
  ///
  /// \pre MI.getNumOperands() <= 3
  ///
  /// \return An InstructionMappings with a statically allocated
  /// OperandsMapping.
  static InstructionMapping
  getSameKindOfOperandsMapping(const MachineInstr &MI);

public:
  AArch64RegisterBankInfo(const TargetRegisterInfo &TRI);

  unsigned copyCost(const RegisterBank &A, const RegisterBank &B,
                    unsigned Size) const override;

  const RegisterBank &
  getRegBankFromRegClass(const TargetRegisterClass &RC) const override;

  InstructionMappings
  getInstrAlternativeMappings(const MachineInstr &MI) const override;

  InstructionMapping getInstrMapping(const MachineInstr &MI) const override;
};
} // End llvm namespace.
#endif
