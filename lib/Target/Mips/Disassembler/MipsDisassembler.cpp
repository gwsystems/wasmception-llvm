//===- MipsDisassembler.cpp - Disassembler for Mips -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is part of the Mips Disassembler.
//
//===----------------------------------------------------------------------===//

#include "Mips.h"
#include "MipsRegisterInfo.h"
#include "MipsSubtarget.h"
#include "llvm/MC/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/MemoryObject.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

/// MipsDisassemblerBase - a disasembler class for Mips.
class MipsDisassemblerBase : public MCDisassembler {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  MipsDisassemblerBase(const MCSubtargetInfo &STI, const MCRegisterInfo *Info,
                       bool bigEndian) :
    MCDisassembler(STI), RegInfo(Info), isBigEndian(bigEndian) {}

  virtual ~MipsDisassemblerBase() {}

  const MCRegisterInfo *getRegInfo() const { return RegInfo; }

private:
  const MCRegisterInfo *RegInfo;
protected:
  bool isBigEndian;
};

/// MipsDisassembler - a disasembler class for Mips32.
class MipsDisassembler : public MipsDisassemblerBase {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  MipsDisassembler(const MCSubtargetInfo &STI, const MCRegisterInfo *Info,
                   bool bigEndian) :
    MipsDisassemblerBase(STI, Info, bigEndian) {}

  /// getInstruction - See MCDisassembler.
  virtual DecodeStatus getInstruction(MCInst &instr,
                                      uint64_t &size,
                                      const MemoryObject &region,
                                      uint64_t address,
                                      raw_ostream &vStream,
                                      raw_ostream &cStream) const;
};


/// Mips64Disassembler - a disasembler class for Mips64.
class Mips64Disassembler : public MipsDisassemblerBase {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  Mips64Disassembler(const MCSubtargetInfo &STI, const MCRegisterInfo *Info,
                     bool bigEndian) :
    MipsDisassemblerBase(STI, Info, bigEndian) {}

  /// getInstruction - See MCDisassembler.
  virtual DecodeStatus getInstruction(MCInst &instr,
                                      uint64_t &size,
                                      const MemoryObject &region,
                                      uint64_t address,
                                      raw_ostream &vStream,
                                      raw_ostream &cStream) const;
};

} // end anonymous namespace

// Forward declare these because the autogenerated code will reference them.
// Definitions are further down.
static DecodeStatus DecodeCPU64RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder);

static DecodeStatus DecodeCPU16RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder);

static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);

static DecodeStatus DecodeDSPRegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);

static DecodeStatus DecodeFGR64RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder);

static DecodeStatus DecodeFGR32RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder);

static DecodeStatus DecodeCCRRegisterClass(MCInst &Inst,
                                           unsigned RegNo,
                                           uint64_t Address,
                                           const void *Decoder);

static DecodeStatus DecodeHWRegsRegisterClass(MCInst &Inst,
                                              unsigned Insn,
                                              uint64_t Address,
                                              const void *Decoder);

static DecodeStatus DecodeAFGR64RegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder);

static DecodeStatus DecodeHWRegs64RegisterClass(MCInst &Inst,
                                                unsigned Insn,
                                                uint64_t Address,
                                                const void *Decoder);

static DecodeStatus DecodeACRegsRegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder);

static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                                       unsigned Offset,
                                       uint64_t Address,
                                       const void *Decoder);

static DecodeStatus DecodeBC1(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder);


static DecodeStatus DecodeJumpTarget(MCInst &Inst,
                                     unsigned Insn,
                                     uint64_t Address,
                                     const void *Decoder);

static DecodeStatus DecodeMem(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder);

static DecodeStatus DecodeFMem(MCInst &Inst, unsigned Insn,
                               uint64_t Address,
                               const void *Decoder);

static DecodeStatus DecodeSimm16(MCInst &Inst,
                                 unsigned Insn,
                                 uint64_t Address,
                                 const void *Decoder);

static DecodeStatus DecodeCondCode(MCInst &Inst,
                                   unsigned Insn,
                                   uint64_t Address,
                                   const void *Decoder);

static DecodeStatus DecodeInsSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder);

static DecodeStatus DecodeExtSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder);

namespace llvm {
extern Target TheMipselTarget, TheMipsTarget, TheMips64Target,
              TheMips64elTarget;
}

static MCDisassembler *createMipsDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new MipsDisassembler(STI, T.createMCRegInfo(""), true);
}

static MCDisassembler *createMipselDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new MipsDisassembler(STI, T.createMCRegInfo(""), false);
}

static MCDisassembler *createMips64Disassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Mips64Disassembler(STI, T.createMCRegInfo(""), true);
}

static MCDisassembler *createMips64elDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Mips64Disassembler(STI, T.createMCRegInfo(""), false);
}

extern "C" void LLVMInitializeMipsDisassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(TheMipsTarget,
                                         createMipsDisassembler);
  TargetRegistry::RegisterMCDisassembler(TheMipselTarget,
                                         createMipselDisassembler);
  TargetRegistry::RegisterMCDisassembler(TheMips64Target,
                                         createMips64Disassembler);
  TargetRegistry::RegisterMCDisassembler(TheMips64elTarget,
                                         createMips64elDisassembler);
}


#include "MipsGenDisassemblerTables.inc"

  /// readInstruction - read four bytes from the MemoryObject
  /// and return 32 bit word sorted according to the given endianess
static DecodeStatus readInstruction32(const MemoryObject &region,
                                      uint64_t address,
                                      uint64_t &size,
                                      uint32_t &insn,
                                      bool isBigEndian) {
  uint8_t Bytes[4];

  // We want to read exactly 4 Bytes of data.
  if (region.readBytes(address, 4, (uint8_t*)Bytes, NULL) == -1) {
    size = 0;
    return MCDisassembler::Fail;
  }

  if (isBigEndian) {
    // Encoded as a big-endian 32-bit word in the stream.
    insn = (Bytes[3] <<  0) |
           (Bytes[2] <<  8) |
           (Bytes[1] << 16) |
           (Bytes[0] << 24);
  }
  else {
    // Encoded as a small-endian 32-bit word in the stream.
    insn = (Bytes[0] <<  0) |
           (Bytes[1] <<  8) |
           (Bytes[2] << 16) |
           (Bytes[3] << 24);
  }

  return MCDisassembler::Success;
}

DecodeStatus
MipsDisassembler::getInstruction(MCInst &instr,
                                 uint64_t &Size,
                                 const MemoryObject &Region,
                                 uint64_t Address,
                                 raw_ostream &vStream,
                                 raw_ostream &cStream) const {
  uint32_t Insn;

  DecodeStatus Result = readInstruction32(Region, Address, Size,
                                          Insn, isBigEndian);
  if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;

  // Calling the auto-generated decoder function.
  Result = decodeInstruction(DecoderTableMips32, instr, Insn, Address,
                             this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }

  return MCDisassembler::Fail;
}

DecodeStatus
Mips64Disassembler::getInstruction(MCInst &instr,
                                   uint64_t &Size,
                                   const MemoryObject &Region,
                                   uint64_t Address,
                                   raw_ostream &vStream,
                                   raw_ostream &cStream) const {
  uint32_t Insn;

  DecodeStatus Result = readInstruction32(Region, Address, Size,
                                          Insn, isBigEndian);
  if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;

  // Calling the auto-generated decoder function.
  Result = decodeInstruction(DecoderTableMips6432, instr, Insn, Address,
                             this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }
  // If we fail to decode in Mips64 decoder space we can try in Mips32
  Result = decodeInstruction(DecoderTableMips32, instr, Insn, Address,
                             this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }

  return MCDisassembler::Fail;
}

static unsigned getReg(const void *D, unsigned RC, unsigned RegNo) {
  const MipsDisassemblerBase *Dis = static_cast<const MipsDisassemblerBase*>(D);
  return *(Dis->getRegInfo()->getRegClass(RC).begin() + RegNo);
}

static DecodeStatus DecodeCPU16RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder) {

  return MCDisassembler::Fail;

}

static DecodeStatus DecodeCPU64RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder) {

  if (RegNo > 31)
    return MCDisassembler::Fail;

  unsigned Reg = getReg(Decoder, Mips::CPU64RegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;
  unsigned Reg = getReg(Decoder, Mips::CPURegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeDSPRegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  return DecodeCPURegsRegisterClass(Inst, RegNo, Address, Decoder);
}

static DecodeStatus DecodeFGR64RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  unsigned Reg = getReg(Decoder, Mips::FGR64RegClassID, RegNo);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeFGR32RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  unsigned Reg = getReg(Decoder, Mips::FGR32RegClassID, RegNo);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeCCRRegisterClass(MCInst &Inst,
                                           unsigned RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  Inst.addOperand(MCOperand::CreateReg(RegNo));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeMem(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder) {
  int Offset = SignExtend32<16>(Insn & 0xffff);
  unsigned Reg = fieldFromInstruction(Insn, 16, 5);
  unsigned Base = fieldFromInstruction(Insn, 21, 5);

  Reg = getReg(Decoder, Mips::CPURegsRegClassID, Reg);
  Base = getReg(Decoder, Mips::CPURegsRegClassID, Base);

  if(Inst.getOpcode() == Mips::SC){
    Inst.addOperand(MCOperand::CreateReg(Reg));
  }

  Inst.addOperand(MCOperand::CreateReg(Reg));
  Inst.addOperand(MCOperand::CreateReg(Base));
  Inst.addOperand(MCOperand::CreateImm(Offset));

  return MCDisassembler::Success;
}

static DecodeStatus DecodeFMem(MCInst &Inst,
                               unsigned Insn,
                               uint64_t Address,
                               const void *Decoder) {
  int Offset = SignExtend32<16>(Insn & 0xffff);
  unsigned Reg = fieldFromInstruction(Insn, 16, 5);
  unsigned Base = fieldFromInstruction(Insn, 21, 5);

  Reg = getReg(Decoder, Mips::FGR64RegClassID, Reg);
  Base = getReg(Decoder, Mips::CPURegsRegClassID, Base);

  Inst.addOperand(MCOperand::CreateReg(Reg));
  Inst.addOperand(MCOperand::CreateReg(Base));
  Inst.addOperand(MCOperand::CreateImm(Offset));

  return MCDisassembler::Success;
}


static DecodeStatus DecodeHWRegsRegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  // Currently only hardware register 29 is supported.
  if (RegNo != 29)
    return  MCDisassembler::Fail;
  Inst.addOperand(MCOperand::CreateReg(Mips::HWR29));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeCondCode(MCInst &Inst,
                                   unsigned Insn,
                                   uint64_t Address,
                                   const void *Decoder) {
  int CondCode = Insn & 0xf;
  Inst.addOperand(MCOperand::CreateImm(CondCode));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeAFGR64RegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  if (RegNo > 30 || RegNo %2)
    return MCDisassembler::Fail;

  ;
  unsigned Reg = getReg(Decoder, Mips::AFGR64RegClassID, RegNo /2);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeHWRegs64RegisterClass(MCInst &Inst,
                                                unsigned RegNo,
                                                uint64_t Address,
                                                const void *Decoder) {
  //Currently only hardware register 29 is supported
  if (RegNo != 29)
    return  MCDisassembler::Fail;
  Inst.addOperand(MCOperand::CreateReg(Mips::HWR29_64));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeACRegsRegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  if (RegNo >= 4)
    return MCDisassembler::Fail;

  unsigned Reg = getReg(Decoder, Mips::ACRegsRegClassID, RegNo);
  Inst.addOperand(MCOperand::CreateReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                                       unsigned Offset,
                                       uint64_t Address,
                                       const void *Decoder) {
  unsigned BranchOffset = Offset & 0xffff;
  BranchOffset = SignExtend32<18>(BranchOffset << 2) + 4;
  Inst.addOperand(MCOperand::CreateImm(BranchOffset));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeBC1(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder) {
  unsigned BranchOffset = Insn & 0xffff;
  BranchOffset = SignExtend32<18>(BranchOffset << 2) + 4;
  Inst.addOperand(MCOperand::CreateImm(BranchOffset));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeJumpTarget(MCInst &Inst,
                                     unsigned Insn,
                                     uint64_t Address,
                                     const void *Decoder) {

  unsigned JumpOffset = fieldFromInstruction(Insn, 0, 26) << 2;
  Inst.addOperand(MCOperand::CreateImm(JumpOffset));
  return MCDisassembler::Success;
}


static DecodeStatus DecodeSimm16(MCInst &Inst,
                                 unsigned Insn,
                                 uint64_t Address,
                                 const void *Decoder) {
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Insn)));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeInsSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder) {
  // First we need to grab the pos(lsb) from MCInst.
  int Pos = Inst.getOperand(2).getImm();
  int Size = (int) Insn - Pos + 1;
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Size)));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeExtSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder) {
  int Size = (int) Insn  + 1;
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Size)));
  return MCDisassembler::Success;
}
