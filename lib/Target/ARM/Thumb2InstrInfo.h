//===- Thumb2InstrInfo.h - Thumb-2 Instruction Information ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Thumb-2 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef THUMB2INSTRUCTIONINFO_H
#define THUMB2INSTRUCTIONINFO_H

#include "llvm/Target/TargetInstrInfo.h"
#include "ARM.h"
#include "ARMInstrInfo.h"
#include "Thumb2RegisterInfo.h"

namespace llvm {
  class ARMSubtarget;

class Thumb2InstrInfo : public ARMBaseInstrInfo {
  Thumb2RegisterInfo RI;
public:
  explicit Thumb2InstrInfo(const ARMSubtarget &STI);

  // Return the non-pre/post incrementing version of 'Opc'. Return 0
  // if there is not such an opcode.
  unsigned getUnindexedOpcode(unsigned Opc) const;

  // Return the opcode that implements 'Op', or 0 if no opcode
  unsigned getOpcode(ARMII::Op Op) const;

  // If 'opcode' is an instruction with an unsigned offset that also
  // has a version with a signed offset, return the opcode for the
  // version with the signed offset. In 'NumBits' return the number of
  // bits for the signed offset.
  unsigned unsignedOffsetOpcodeToSigned(unsigned opcode,
                                        unsigned *NumBits) const;

  // Return true if the block does not fall through.
  bool BlockHasNoFallThrough(const MachineBasicBlock &MBB) const;

  bool copyRegToReg(MachineBasicBlock &MBB,
                    MachineBasicBlock::iterator I,
                    unsigned DestReg, unsigned SrcReg,
                    const TargetRegisterClass *DestRC,
                    const TargetRegisterClass *SrcRC) const;

  /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
  /// such, whenever a client has an instance of instruction info, it should
  /// always be able to get register info as well (through this method).
  ///
  const Thumb2RegisterInfo &getRegisterInfo() const { return RI; }
};
}

#endif // THUMB2INSTRUCTIONINFO_H
