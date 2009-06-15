//===-- ARMLoadStoreOptimizer.cpp - ARM load / store opt. pass ----*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that performs load / store related peephole
// optimizations. This pass should be run after register allocation.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "arm-ldst-opt"
#include "ARM.h"
#include "ARMAddressingModes.h"
#include "ARMMachineFunctionInfo.h"
#include "ARMRegisterInfo.h"
#include "llvm/DerivedTypes.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Support/Compiler.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
using namespace llvm;

STATISTIC(NumLDMGened , "Number of ldm instructions generated");
STATISTIC(NumSTMGened , "Number of stm instructions generated");
STATISTIC(NumFLDMGened, "Number of fldm instructions generated");
STATISTIC(NumFSTMGened, "Number of fstm instructions generated");
STATISTIC(NumLdStMoved, "Number of load / store instructions moved");

/// ARMAllocLoadStoreOpt - Post- register allocation pass the combine
/// load / store instructions to form ldm / stm instructions.

namespace {
  struct VISIBILITY_HIDDEN ARMLoadStoreOpt : public MachineFunctionPass {
    static char ID;
    ARMLoadStoreOpt() : MachineFunctionPass(&ID) {}

    const TargetInstrInfo *TII;
    const TargetRegisterInfo *TRI;
    ARMFunctionInfo *AFI;
    RegScavenger *RS;

    virtual bool runOnMachineFunction(MachineFunction &Fn);

    virtual const char *getPassName() const {
      return "ARM load / store optimization pass";
    }

  private:
    struct MemOpQueueEntry {
      int Offset;
      unsigned Position;
      MachineBasicBlock::iterator MBBI;
      bool Merged;
      MemOpQueueEntry(int o, int p, MachineBasicBlock::iterator i)
        : Offset(o), Position(p), MBBI(i), Merged(false) {};
    };
    typedef SmallVector<MemOpQueueEntry,8> MemOpQueue;
    typedef MemOpQueue::iterator MemOpQueueIter;

    bool MergeOps(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                  int Offset, unsigned Base, bool BaseKill, int Opcode,
                  ARMCC::CondCodes Pred, unsigned PredReg, unsigned Scratch,
                  DebugLoc dl, SmallVector<std::pair<unsigned, bool>, 8> &Regs);
    void MergeLDR_STR(MachineBasicBlock &MBB, unsigned SIndex, unsigned Base,
                      int Opcode, unsigned Size,
                      ARMCC::CondCodes Pred, unsigned PredReg,
                      unsigned Scratch, MemOpQueue &MemOps,
                      SmallVector<MachineBasicBlock::iterator, 4> &Merges);

    void AdvanceRS(MachineBasicBlock &MBB, MemOpQueue &MemOps);
    bool FixInvalidRegPairOp(MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator &MBBI);
    bool LoadStoreMultipleOpti(MachineBasicBlock &MBB);
    bool MergeReturnIntoLDM(MachineBasicBlock &MBB);
  };
  char ARMLoadStoreOpt::ID = 0;
}

static int getLoadStoreMultipleOpcode(int Opcode) {
  switch (Opcode) {
  case ARM::LDR:
    NumLDMGened++;
    return ARM::LDM;
  case ARM::STR:
    NumSTMGened++;
    return ARM::STM;
  case ARM::FLDS:
    NumFLDMGened++;
    return ARM::FLDMS;
  case ARM::FSTS:
    NumFSTMGened++;
    return ARM::FSTMS;
  case ARM::FLDD:
    NumFLDMGened++;
    return ARM::FLDMD;
  case ARM::FSTD:
    NumFSTMGened++;
    return ARM::FSTMD;
  default: abort();
  }
  return 0;
}

/// MergeOps - Create and insert a LDM or STM with Base as base register and
/// registers in Regs as the register operands that would be loaded / stored.
/// It returns true if the transformation is done. 
bool
ARMLoadStoreOpt::MergeOps(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI,
                          int Offset, unsigned Base, bool BaseKill,
                          int Opcode, ARMCC::CondCodes Pred,
                          unsigned PredReg, unsigned Scratch, DebugLoc dl,
                          SmallVector<std::pair<unsigned, bool>, 8> &Regs) {
  // Only a single register to load / store. Don't bother.
  unsigned NumRegs = Regs.size();
  if (NumRegs <= 1)
    return false;

  ARM_AM::AMSubMode Mode = ARM_AM::ia;
  bool isAM4 = Opcode == ARM::LDR || Opcode == ARM::STR;
  if (isAM4 && Offset == 4)
    Mode = ARM_AM::ib;
  else if (isAM4 && Offset == -4 * (int)NumRegs + 4)
    Mode = ARM_AM::da;
  else if (isAM4 && Offset == -4 * (int)NumRegs)
    Mode = ARM_AM::db;
  else if (Offset != 0) {
    // If starting offset isn't zero, insert a MI to materialize a new base.
    // But only do so if it is cost effective, i.e. merging more than two
    // loads / stores.
    if (NumRegs <= 2)
      return false;

    unsigned NewBase;
    if (Opcode == ARM::LDR)
      // If it is a load, then just use one of the destination register to
      // use as the new base.
      NewBase = Regs[NumRegs-1].first;
    else {
      // Use the scratch register to use as a new base.
      NewBase = Scratch;
      if (NewBase == 0)
        return false;
    }
    int BaseOpc = ARM::ADDri;
    if (Offset < 0) {
      BaseOpc = ARM::SUBri;
      Offset = - Offset;
    }
    int ImmedOffset = ARM_AM::getSOImmVal(Offset);
    if (ImmedOffset == -1)
      return false;  // Probably not worth it then.

    BuildMI(MBB, MBBI, dl, TII->get(BaseOpc), NewBase)
      .addReg(Base, getKillRegState(BaseKill)).addImm(ImmedOffset)
      .addImm(Pred).addReg(PredReg).addReg(0);
    Base = NewBase;
    BaseKill = true;  // New base is always killed right its use.
  }

  bool isDPR = Opcode == ARM::FLDD || Opcode == ARM::FSTD;
  bool isDef = Opcode == ARM::LDR || Opcode == ARM::FLDS || Opcode == ARM::FLDD;
  Opcode = getLoadStoreMultipleOpcode(Opcode);
  MachineInstrBuilder MIB = (isAM4)
    ? BuildMI(MBB, MBBI, dl, TII->get(Opcode))
        .addReg(Base, getKillRegState(BaseKill))
        .addImm(ARM_AM::getAM4ModeImm(Mode)).addImm(Pred).addReg(PredReg)
    : BuildMI(MBB, MBBI, dl, TII->get(Opcode))
        .addReg(Base, getKillRegState(BaseKill))
        .addImm(ARM_AM::getAM5Opc(Mode, false, isDPR ? NumRegs<<1 : NumRegs))
        .addImm(Pred).addReg(PredReg);
  for (unsigned i = 0; i != NumRegs; ++i)
    MIB = MIB.addReg(Regs[i].first, getDefRegState(isDef)
                     | getKillRegState(Regs[i].second));

  return true;
}

/// MergeLDR_STR - Merge a number of load / store instructions into one or more
/// load / store multiple instructions.
void
ARMLoadStoreOpt::MergeLDR_STR(MachineBasicBlock &MBB, unsigned SIndex,
                          unsigned Base, int Opcode, unsigned Size,
                          ARMCC::CondCodes Pred, unsigned PredReg,
                          unsigned Scratch, MemOpQueue &MemOps,
                          SmallVector<MachineBasicBlock::iterator, 4> &Merges) {
  bool isAM4 = Opcode == ARM::LDR || Opcode == ARM::STR;
  int Offset = MemOps[SIndex].Offset;
  int SOffset = Offset;
  unsigned Pos = MemOps[SIndex].Position;
  MachineBasicBlock::iterator Loc = MemOps[SIndex].MBBI;
  DebugLoc dl = Loc->getDebugLoc();
  unsigned PReg = Loc->getOperand(0).getReg();
  unsigned PRegNum = ARMRegisterInfo::getRegisterNumbering(PReg);
  bool isKill = Loc->getOperand(0).isKill();

  SmallVector<std::pair<unsigned,bool>, 8> Regs;
  Regs.push_back(std::make_pair(PReg, isKill));
  for (unsigned i = SIndex+1, e = MemOps.size(); i != e; ++i) {
    int NewOffset = MemOps[i].Offset;
    unsigned Reg = MemOps[i].MBBI->getOperand(0).getReg();
    unsigned RegNum = ARMRegisterInfo::getRegisterNumbering(Reg);
    isKill = MemOps[i].MBBI->getOperand(0).isKill();
    // AM4 - register numbers in ascending order.
    // AM5 - consecutive register numbers in ascending order.
    if (NewOffset == Offset + (int)Size &&
        ((isAM4 && RegNum > PRegNum) || RegNum == PRegNum+1)) {
      Offset += Size;
      Regs.push_back(std::make_pair(Reg, isKill));
      PRegNum = RegNum;
    } else {
      // Can't merge this in. Try merge the earlier ones first.
      if (MergeOps(MBB, ++Loc, SOffset, Base, false, Opcode, Pred, PredReg,
                   Scratch, dl, Regs)) {
        Merges.push_back(prior(Loc));
        for (unsigned j = SIndex; j < i; ++j) {
          MBB.erase(MemOps[j].MBBI);
          MemOps[j].Merged = true;
        }
      }
      MergeLDR_STR(MBB, i, Base, Opcode, Size, Pred, PredReg, Scratch,
                   MemOps, Merges);
      return;
    }

    if (MemOps[i].Position > Pos) {
      Pos = MemOps[i].Position;
      Loc = MemOps[i].MBBI;
    }
  }

  bool BaseKill = Loc->findRegisterUseOperandIdx(Base, true) != -1;
  if (MergeOps(MBB, ++Loc, SOffset, Base, BaseKill, Opcode, Pred, PredReg,
               Scratch, dl, Regs)) {
    Merges.push_back(prior(Loc));
    for (unsigned i = SIndex, e = MemOps.size(); i != e; ++i) {
      MBB.erase(MemOps[i].MBBI);
      MemOps[i].Merged = true;
    }
  }

  return;
}

/// getInstrPredicate - If instruction is predicated, returns its predicate
/// condition, otherwise returns AL. It also returns the condition code
/// register by reference.
static ARMCC::CondCodes getInstrPredicate(MachineInstr *MI, unsigned &PredReg) {
  int PIdx = MI->findFirstPredOperandIdx();
  if (PIdx == -1) {
    PredReg = 0;
    return ARMCC::AL;
  }

  PredReg = MI->getOperand(PIdx+1).getReg();
  return (ARMCC::CondCodes)MI->getOperand(PIdx).getImm();
}

static inline bool isMatchingDecrement(MachineInstr *MI, unsigned Base,
                                       unsigned Bytes, ARMCC::CondCodes Pred,
                                       unsigned PredReg) {
  unsigned MyPredReg = 0;
  return (MI && MI->getOpcode() == ARM::SUBri &&
          MI->getOperand(0).getReg() == Base &&
          MI->getOperand(1).getReg() == Base &&
          ARM_AM::getAM2Offset(MI->getOperand(2).getImm()) == Bytes &&
          getInstrPredicate(MI, MyPredReg) == Pred &&
          MyPredReg == PredReg);
}

static inline bool isMatchingIncrement(MachineInstr *MI, unsigned Base,
                                       unsigned Bytes, ARMCC::CondCodes Pred,
                                       unsigned PredReg) {
  unsigned MyPredReg = 0;
  return (MI && MI->getOpcode() == ARM::ADDri &&
          MI->getOperand(0).getReg() == Base &&
          MI->getOperand(1).getReg() == Base &&
          ARM_AM::getAM2Offset(MI->getOperand(2).getImm()) == Bytes &&
          getInstrPredicate(MI, MyPredReg) == Pred &&
          MyPredReg == PredReg);
}

static inline unsigned getLSMultipleTransferSize(MachineInstr *MI) {
  switch (MI->getOpcode()) {
  default: return 0;
  case ARM::LDR:
  case ARM::STR:
  case ARM::FLDS:
  case ARM::FSTS:
    return 4;
  case ARM::FLDD:
  case ARM::FSTD:
    return 8;
  case ARM::LDM:
  case ARM::STM:
    return (MI->getNumOperands() - 4) * 4;
  case ARM::FLDMS:
  case ARM::FSTMS:
  case ARM::FLDMD:
  case ARM::FSTMD:
    return ARM_AM::getAM5Offset(MI->getOperand(1).getImm()) * 4;
  }
}

/// mergeBaseUpdateLSMultiple - Fold proceeding/trailing inc/dec of base
/// register into the LDM/STM/FLDM{D|S}/FSTM{D|S} op when possible:
///
/// stmia rn, <ra, rb, rc>
/// rn := rn + 4 * 3;
/// =>
/// stmia rn!, <ra, rb, rc>
///
/// rn := rn - 4 * 3;
/// ldmia rn, <ra, rb, rc>
/// =>
/// ldmdb rn!, <ra, rb, rc>
static bool mergeBaseUpdateLSMultiple(MachineBasicBlock &MBB,
                                      MachineBasicBlock::iterator MBBI,
                                      bool &Advance,
                                      MachineBasicBlock::iterator &I) {
  MachineInstr *MI = MBBI;
  unsigned Base = MI->getOperand(0).getReg();
  unsigned Bytes = getLSMultipleTransferSize(MI);
  unsigned PredReg = 0;
  ARMCC::CondCodes Pred = getInstrPredicate(MI, PredReg);
  int Opcode = MI->getOpcode();
  bool isAM4 = Opcode == ARM::LDM || Opcode == ARM::STM;

  if (isAM4) {
    if (ARM_AM::getAM4WBFlag(MI->getOperand(1).getImm()))
      return false;

    // Can't use the updating AM4 sub-mode if the base register is also a dest
    // register. e.g. ldmdb r0!, {r0, r1, r2}. The behavior is undefined.
    for (unsigned i = 3, e = MI->getNumOperands(); i != e; ++i) {
      if (MI->getOperand(i).getReg() == Base)
        return false;
    }

    ARM_AM::AMSubMode Mode = ARM_AM::getAM4SubMode(MI->getOperand(1).getImm());
    if (MBBI != MBB.begin()) {
      MachineBasicBlock::iterator PrevMBBI = prior(MBBI);
      if (Mode == ARM_AM::ia &&
          isMatchingDecrement(PrevMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM4ModeImm(ARM_AM::db, true));
        MBB.erase(PrevMBBI);
        return true;
      } else if (Mode == ARM_AM::ib &&
                 isMatchingDecrement(PrevMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM4ModeImm(ARM_AM::da, true));
        MBB.erase(PrevMBBI);
        return true;
      }
    }

    if (MBBI != MBB.end()) {
      MachineBasicBlock::iterator NextMBBI = next(MBBI);
      if ((Mode == ARM_AM::ia || Mode == ARM_AM::ib) &&
          isMatchingIncrement(NextMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM4ModeImm(Mode, true));
        if (NextMBBI == I) {
          Advance = true;
          ++I;
        }
        MBB.erase(NextMBBI);
        return true;
      } else if ((Mode == ARM_AM::da || Mode == ARM_AM::db) &&
                 isMatchingDecrement(NextMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM4ModeImm(Mode, true));
        if (NextMBBI == I) {
          Advance = true;
          ++I;
        }
        MBB.erase(NextMBBI);
        return true;
      }
    }
  } else {
    // FLDM{D|S}, FSTM{D|S} addressing mode 5 ops.
    if (ARM_AM::getAM5WBFlag(MI->getOperand(1).getImm()))
      return false;

    ARM_AM::AMSubMode Mode = ARM_AM::getAM5SubMode(MI->getOperand(1).getImm());
    unsigned Offset = ARM_AM::getAM5Offset(MI->getOperand(1).getImm());
    if (MBBI != MBB.begin()) {
      MachineBasicBlock::iterator PrevMBBI = prior(MBBI);
      if (Mode == ARM_AM::ia &&
          isMatchingDecrement(PrevMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM5Opc(ARM_AM::db, true, Offset));
        MBB.erase(PrevMBBI);
        return true;
      }
    }

    if (MBBI != MBB.end()) {
      MachineBasicBlock::iterator NextMBBI = next(MBBI);
      if (Mode == ARM_AM::ia &&
          isMatchingIncrement(NextMBBI, Base, Bytes, Pred, PredReg)) {
        MI->getOperand(1).setImm(ARM_AM::getAM5Opc(ARM_AM::ia, true, Offset));
        if (NextMBBI == I) {
          Advance = true;
          ++I;
        }
        MBB.erase(NextMBBI);
      }
      return true;
    }
  }

  return false;
}

static unsigned getPreIndexedLoadStoreOpcode(unsigned Opc) {
  switch (Opc) {
  case ARM::LDR: return ARM::LDR_PRE;
  case ARM::STR: return ARM::STR_PRE;
  case ARM::FLDS: return ARM::FLDMS;
  case ARM::FLDD: return ARM::FLDMD;
  case ARM::FSTS: return ARM::FSTMS;
  case ARM::FSTD: return ARM::FSTMD;
  default: abort();
  }
  return 0;
}

static unsigned getPostIndexedLoadStoreOpcode(unsigned Opc) {
  switch (Opc) {
  case ARM::LDR: return ARM::LDR_POST;
  case ARM::STR: return ARM::STR_POST;
  case ARM::FLDS: return ARM::FLDMS;
  case ARM::FLDD: return ARM::FLDMD;
  case ARM::FSTS: return ARM::FSTMS;
  case ARM::FSTD: return ARM::FSTMD;
  default: abort();
  }
  return 0;
}

/// mergeBaseUpdateLoadStore - Fold proceeding/trailing inc/dec of base
/// register into the LDR/STR/FLD{D|S}/FST{D|S} op when possible:
static bool mergeBaseUpdateLoadStore(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MBBI,
                                     const TargetInstrInfo *TII,
                                     bool &Advance,
                                     MachineBasicBlock::iterator &I) {
  MachineInstr *MI = MBBI;
  unsigned Base = MI->getOperand(1).getReg();
  bool BaseKill = MI->getOperand(1).isKill();
  unsigned Bytes = getLSMultipleTransferSize(MI);
  int Opcode = MI->getOpcode();
  DebugLoc dl = MI->getDebugLoc();
  bool isAM2 = Opcode == ARM::LDR || Opcode == ARM::STR;
  if ((isAM2 && ARM_AM::getAM2Offset(MI->getOperand(3).getImm()) != 0) ||
      (!isAM2 && ARM_AM::getAM5Offset(MI->getOperand(2).getImm()) != 0))
    return false;

  bool isLd = Opcode == ARM::LDR || Opcode == ARM::FLDS || Opcode == ARM::FLDD;
  // Can't do the merge if the destination register is the same as the would-be
  // writeback register.
  if (isLd && MI->getOperand(0).getReg() == Base)
    return false;

  unsigned PredReg = 0;
  ARMCC::CondCodes Pred = getInstrPredicate(MI, PredReg);
  bool DoMerge = false;
  ARM_AM::AddrOpc AddSub = ARM_AM::add;
  unsigned NewOpc = 0;
  if (MBBI != MBB.begin()) {
    MachineBasicBlock::iterator PrevMBBI = prior(MBBI);
    if (isMatchingDecrement(PrevMBBI, Base, Bytes, Pred, PredReg)) {
      DoMerge = true;
      AddSub = ARM_AM::sub;
      NewOpc = getPreIndexedLoadStoreOpcode(Opcode);
    } else if (isAM2 && isMatchingIncrement(PrevMBBI, Base, Bytes,
                                            Pred, PredReg)) {
      DoMerge = true;
      NewOpc = getPreIndexedLoadStoreOpcode(Opcode);
    }
    if (DoMerge)
      MBB.erase(PrevMBBI);
  }

  if (!DoMerge && MBBI != MBB.end()) {
    MachineBasicBlock::iterator NextMBBI = next(MBBI);
    if (isAM2 && isMatchingDecrement(NextMBBI, Base, Bytes, Pred, PredReg)) {
      DoMerge = true;
      AddSub = ARM_AM::sub;
      NewOpc = getPostIndexedLoadStoreOpcode(Opcode);
    } else if (isMatchingIncrement(NextMBBI, Base, Bytes, Pred, PredReg)) {
      DoMerge = true;
      NewOpc = getPostIndexedLoadStoreOpcode(Opcode);
    }
    if (DoMerge) {
      if (NextMBBI == I) {
        Advance = true;
        ++I;
      }
      MBB.erase(NextMBBI);
    }
  }

  if (!DoMerge)
    return false;

  bool isDPR = NewOpc == ARM::FLDMD || NewOpc == ARM::FSTMD;
  unsigned Offset = isAM2 ? ARM_AM::getAM2Opc(AddSub, Bytes, ARM_AM::no_shift)
    : ARM_AM::getAM5Opc((AddSub == ARM_AM::sub) ? ARM_AM::db : ARM_AM::ia,
                        true, isDPR ? 2 : 1);
  if (isLd) {
    if (isAM2)
      // LDR_PRE, LDR_POST;
      BuildMI(MBB, MBBI, dl, TII->get(NewOpc), MI->getOperand(0).getReg())
        .addReg(Base, RegState::Define)
        .addReg(Base).addReg(0).addImm(Offset).addImm(Pred).addReg(PredReg);
    else
      // FLDMS, FLDMD
      BuildMI(MBB, MBBI, dl, TII->get(NewOpc))
        .addReg(Base, getKillRegState(BaseKill))
        .addImm(Offset).addImm(Pred).addReg(PredReg)
        .addReg(MI->getOperand(0).getReg(), RegState::Define);
  } else {
    MachineOperand &MO = MI->getOperand(0);
    if (isAM2)
      // STR_PRE, STR_POST;
      BuildMI(MBB, MBBI, dl, TII->get(NewOpc), Base)
        .addReg(MO.getReg(), getKillRegState(MO.isKill()))
        .addReg(Base).addReg(0).addImm(Offset).addImm(Pred).addReg(PredReg);
    else
      // FSTMS, FSTMD
      BuildMI(MBB, MBBI, dl, TII->get(NewOpc)).addReg(Base).addImm(Offset)
        .addImm(Pred).addReg(PredReg)
        .addReg(MO.getReg(), getKillRegState(MO.isKill()));
  }
  MBB.erase(MBBI);

  return true;
}

/// isMemoryOp - Returns true if instruction is a memory operations (that this
/// pass is capable of operating on).
static bool isMemoryOp(MachineInstr *MI) {
  int Opcode = MI->getOpcode();
  switch (Opcode) {
  default: break;
  case ARM::LDR:
  case ARM::STR:
    return MI->getOperand(1).isReg() && MI->getOperand(2).getReg() == 0;
  case ARM::FLDS:
  case ARM::FSTS:
    return MI->getOperand(1).isReg();
  case ARM::FLDD:
  case ARM::FSTD:
    return MI->getOperand(1).isReg();
  }
  return false;
}

/// AdvanceRS - Advance register scavenger to just before the earliest memory
/// op that is being merged.
void ARMLoadStoreOpt::AdvanceRS(MachineBasicBlock &MBB, MemOpQueue &MemOps) {
  MachineBasicBlock::iterator Loc = MemOps[0].MBBI;
  unsigned Position = MemOps[0].Position;
  for (unsigned i = 1, e = MemOps.size(); i != e; ++i) {
    if (MemOps[i].Position < Position) {
      Position = MemOps[i].Position;
      Loc = MemOps[i].MBBI;
    }
  }

  if (Loc != MBB.begin())
    RS->forward(prior(Loc));
}

static int getMemoryOpOffset(const MachineInstr *MI) {
  int Opcode = MI->getOpcode();
  bool isAM2 = Opcode == ARM::LDR || Opcode == ARM::STR;
  bool isAM3 = Opcode == ARM::LDRD || Opcode == ARM::STRD;
  unsigned NumOperands = MI->getDesc().getNumOperands();
  unsigned OffField = MI->getOperand(NumOperands-3).getImm();
  int Offset = isAM2
    ? ARM_AM::getAM2Offset(OffField)
    : (isAM3 ? ARM_AM::getAM3Offset(OffField)
             : ARM_AM::getAM5Offset(OffField) * 4);
  if (isAM2) {
    if (ARM_AM::getAM2Op(OffField) == ARM_AM::sub)
      Offset = -Offset;
  } else if (isAM3) {
    if (ARM_AM::getAM3Op(OffField) == ARM_AM::sub)
      Offset = -Offset;
  } else {
    if (ARM_AM::getAM5Op(OffField) == ARM_AM::sub)
      Offset = -Offset;
  }
  return Offset;
}

static void InsertLDR_STR(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator &MBBI,
                          int OffImm, bool isDef,
                          DebugLoc dl, unsigned NewOpc,
                          unsigned Reg, bool RegKill,
                          unsigned BaseReg, bool BaseKill,
                          unsigned OffReg, bool OffKill,
                          ARMCC::CondCodes Pred, unsigned PredReg,
                          const TargetInstrInfo *TII) {
  unsigned Offset;
  if (OffImm < 0)
    Offset = ARM_AM::getAM2Opc(ARM_AM::sub, -OffImm, ARM_AM::no_shift);
  else
    Offset = ARM_AM::getAM2Opc(ARM_AM::add, OffImm, ARM_AM::no_shift);
  if (isDef)
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(NewOpc), Reg)
      .addReg(BaseReg, getKillRegState(BaseKill))
      .addReg(OffReg,  getKillRegState(OffKill))
      .addImm(Offset)
      .addImm(Pred).addReg(PredReg);
  else
    BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(NewOpc))
      .addReg(Reg, getKillRegState(RegKill))
      .addReg(BaseReg, getKillRegState(BaseKill))
      .addReg(OffReg,  getKillRegState(OffKill))
      .addImm(Offset)
      .addImm(Pred).addReg(PredReg);
}

bool ARMLoadStoreOpt::FixInvalidRegPairOp(MachineBasicBlock &MBB,
                                          MachineBasicBlock::iterator &MBBI) {
  MachineInstr *MI = &*MBBI;
  unsigned Opcode = MI->getOpcode();
  if (Opcode == ARM::LDRD || Opcode == ARM::STRD) {
    unsigned EvenReg = MI->getOperand(0).getReg();
    unsigned OddReg  = MI->getOperand(1).getReg();
    unsigned EvenRegNum = TRI->getDwarfRegNum(EvenReg, false);
    unsigned OddRegNum  = TRI->getDwarfRegNum(OddReg, false);
    if ((EvenRegNum & 1) == 0 && (EvenRegNum + 1) == OddRegNum)
      return false;

    bool isDef = Opcode == ARM::LDRD;
    bool EvenKill = isDef ? false : MI->getOperand(0).isKill();
    bool OddKill  = isDef ? false : MI->getOperand(1).isKill();
    const MachineOperand &BaseOp = MI->getOperand(2);
    unsigned BaseReg = BaseOp.getReg();
    bool BaseKill = BaseOp.isKill();
    const MachineOperand &OffOp = MI->getOperand(3);
    unsigned OffReg = OffOp.getReg();
    bool OffKill = OffOp.isKill();
    int OffImm = getMemoryOpOffset(MI);
    unsigned PredReg = 0;
    ARMCC::CondCodes Pred = getInstrPredicate(MI, PredReg);

    if (OddRegNum > EvenRegNum && OffReg == 0 && OffImm == 0) {
      // Ascending register numbers and no offset. It's safe to change it to a
      // ldm or stm.
      unsigned NewOpc = (Opcode == ARM::LDRD) ? ARM::LDM : ARM::STM;
      BuildMI(MBB, MBBI, MBBI->getDebugLoc(), TII->get(NewOpc))
        .addReg(BaseReg, getKillRegState(BaseKill))
        .addImm(ARM_AM::getAM4ModeImm(ARM_AM::ia))
        .addImm(Pred).addReg(PredReg)
        .addReg(EvenReg, getDefRegState(isDef))
        .addReg(OddReg, getDefRegState(isDef));
    } else {
      // Split into two instructions.
      unsigned NewOpc = (Opcode == ARM::LDRD) ? ARM::LDR : ARM::STR;
      DebugLoc dl = MBBI->getDebugLoc();
      // If this is a load and base register is killed, it may have been
      // re-defed by the load, make sure the first load does not clobber it.
      if (isDef &&
          (BaseKill || OffKill) &&
          (TRI->regsOverlap(EvenReg, BaseReg) ||
           (OffReg && TRI->regsOverlap(EvenReg, OffReg)))) {
        assert(!TRI->regsOverlap(OddReg, BaseReg) &&
               (!OffReg || !TRI->regsOverlap(OddReg, OffReg)));
        InsertLDR_STR(MBB, MBBI, OffImm+4, isDef, dl, NewOpc, OddReg, OddKill,
                      BaseReg, false, OffReg, false, Pred, PredReg, TII);
        InsertLDR_STR(MBB, MBBI, OffImm, isDef, dl, NewOpc, EvenReg, EvenKill,
                      BaseReg, BaseKill, OffReg, OffKill, Pred, PredReg, TII);
      } else {
        InsertLDR_STR(MBB, MBBI, OffImm, isDef, dl, NewOpc, EvenReg, EvenKill,
                      BaseReg, false, OffReg, false, Pred, PredReg, TII);
        InsertLDR_STR(MBB, MBBI, OffImm+4, isDef, dl, NewOpc, OddReg, OddKill,
                      BaseReg, BaseKill, OffReg, OffKill, Pred, PredReg, TII);
      }
    }

    MBBI = prior(MBBI);
    MBB.erase(MI);
  }
  return false;
}

/// LoadStoreMultipleOpti - An optimization pass to turn multiple LDR / STR
/// ops of the same base and incrementing offset into LDM / STM ops.
bool ARMLoadStoreOpt::LoadStoreMultipleOpti(MachineBasicBlock &MBB) {
  unsigned NumMerges = 0;
  unsigned NumMemOps = 0;
  MemOpQueue MemOps;
  unsigned CurrBase = 0;
  int CurrOpc = -1;
  unsigned CurrSize = 0;
  ARMCC::CondCodes CurrPred = ARMCC::AL;
  unsigned CurrPredReg = 0;
  unsigned Position = 0;
  SmallVector<MachineBasicBlock::iterator,4> Merges;

  RS->enterBasicBlock(&MBB);
  MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
  while (MBBI != E) {
    if (FixInvalidRegPairOp(MBB, MBBI))
      continue;

    bool Advance  = false;
    bool TryMerge = false;
    bool Clobber  = false;

    bool isMemOp = isMemoryOp(MBBI);
    if (isMemOp) {
      int Opcode = MBBI->getOpcode();
      unsigned Size = getLSMultipleTransferSize(MBBI);
      unsigned Base = MBBI->getOperand(1).getReg();
      unsigned PredReg = 0;
      ARMCC::CondCodes Pred = getInstrPredicate(MBBI, PredReg);
      int Offset = getMemoryOpOffset(MBBI);
      // Watch out for:
      // r4 := ldr [r5]
      // r5 := ldr [r5, #4]
      // r6 := ldr [r5, #8]
      //
      // The second ldr has effectively broken the chain even though it
      // looks like the later ldr(s) use the same base register. Try to
      // merge the ldr's so far, including this one. But don't try to
      // combine the following ldr(s).
      Clobber = (Opcode == ARM::LDR && Base == MBBI->getOperand(0).getReg());
      if (CurrBase == 0 && !Clobber) {
        // Start of a new chain.
        CurrBase = Base;
        CurrOpc  = Opcode;
        CurrSize = Size;
        CurrPred = Pred;
        CurrPredReg = PredReg;
        MemOps.push_back(MemOpQueueEntry(Offset, Position, MBBI));
        NumMemOps++;
        Advance = true;
      } else {
        if (Clobber) {
          TryMerge = true;
          Advance = true;
        }

        if (CurrOpc == Opcode && CurrBase == Base && CurrPred == Pred) {
          // No need to match PredReg.
          // Continue adding to the queue.
          if (Offset > MemOps.back().Offset) {
            MemOps.push_back(MemOpQueueEntry(Offset, Position, MBBI));
            NumMemOps++;
            Advance = true;
          } else {
            for (MemOpQueueIter I = MemOps.begin(), E = MemOps.end();
                 I != E; ++I) {
              if (Offset < I->Offset) {
                MemOps.insert(I, MemOpQueueEntry(Offset, Position, MBBI));
                NumMemOps++;
                Advance = true;
                break;
              } else if (Offset == I->Offset) {
                // Collision! This can't be merged!
                break;
              }
            }
          }
        }
      }
    }

    if (Advance) {
      ++Position;
      ++MBBI;
    } else
      TryMerge = true;

    if (TryMerge) {
      if (NumMemOps > 1) {
        // Try to find a free register to use as a new base in case it's needed.
        // First advance to the instruction just before the start of the chain.
        AdvanceRS(MBB, MemOps);
        // Find a scratch register. Make sure it's a call clobbered register or
        // a spilled callee-saved register.
        unsigned Scratch = RS->FindUnusedReg(&ARM::GPRRegClass, true);
        if (!Scratch)
          Scratch = RS->FindUnusedReg(&ARM::GPRRegClass,
                                      AFI->getSpilledCSRegisters());
        // Process the load / store instructions.
        RS->forward(prior(MBBI));

        // Merge ops.
        Merges.clear();
        MergeLDR_STR(MBB, 0, CurrBase, CurrOpc, CurrSize,
                     CurrPred, CurrPredReg, Scratch, MemOps, Merges);

        // Try folding preceeding/trailing base inc/dec into the generated
        // LDM/STM ops.
        for (unsigned i = 0, e = Merges.size(); i < e; ++i)
          if (mergeBaseUpdateLSMultiple(MBB, Merges[i], Advance, MBBI))
            ++NumMerges;
        NumMerges += Merges.size();

        // Try folding preceeding/trailing base inc/dec into those load/store
        // that were not merged to form LDM/STM ops.
        for (unsigned i = 0; i != NumMemOps; ++i)
          if (!MemOps[i].Merged)
            if (mergeBaseUpdateLoadStore(MBB, MemOps[i].MBBI, TII,Advance,MBBI))
              ++NumMerges;

        // RS may be pointing to an instruction that's deleted. 
        RS->skipTo(prior(MBBI));
      } else if (NumMemOps == 1) {
        // Try folding preceeding/trailing base inc/dec into the single
        // load/store.
        if (mergeBaseUpdateLoadStore(MBB, MemOps[0].MBBI, TII, Advance, MBBI)) {
          ++NumMerges;
          RS->forward(prior(MBBI));
        }
      }

      CurrBase = 0;
      CurrOpc = -1;
      CurrSize = 0;
      CurrPred = ARMCC::AL;
      CurrPredReg = 0;
      if (NumMemOps) {
        MemOps.clear();
        NumMemOps = 0;
      }

      // If iterator hasn't been advanced and this is not a memory op, skip it.
      // It can't start a new chain anyway.
      if (!Advance && !isMemOp && MBBI != E) {
        ++Position;
        ++MBBI;
      }
    }
  }
  return NumMerges > 0;
}

namespace {
  struct OffsetCompare {
    bool operator()(const MachineInstr *LHS, const MachineInstr *RHS) const {
      int LOffset = getMemoryOpOffset(LHS);
      int ROffset = getMemoryOpOffset(RHS);
      assert(LHS == RHS || LOffset != ROffset);
      return LOffset > ROffset;
    }
  };
}

/// MergeReturnIntoLDM - If this is a exit BB, try merging the return op
/// (bx lr) into the preceeding stack restore so it directly restore the value
/// of LR into pc.
///   ldmfd sp!, {r7, lr}
///   bx lr
/// =>
///   ldmfd sp!, {r7, pc}
bool ARMLoadStoreOpt::MergeReturnIntoLDM(MachineBasicBlock &MBB) {
  if (MBB.empty()) return false;

  MachineBasicBlock::iterator MBBI = prior(MBB.end());
  if (MBBI->getOpcode() == ARM::BX_RET && MBBI != MBB.begin()) {
    MachineInstr *PrevMI = prior(MBBI);
    if (PrevMI->getOpcode() == ARM::LDM) {
      MachineOperand &MO = PrevMI->getOperand(PrevMI->getNumOperands()-1);
      if (MO.getReg() == ARM::LR) {
        PrevMI->setDesc(TII->get(ARM::LDM_RET));
        MO.setReg(ARM::PC);
        MBB.erase(MBBI);
        return true;
      }
    }
  }
  return false;
}

bool ARMLoadStoreOpt::runOnMachineFunction(MachineFunction &Fn) {
  const TargetMachine &TM = Fn.getTarget();
  AFI = Fn.getInfo<ARMFunctionInfo>();
  TII = TM.getInstrInfo();
  TRI = TM.getRegisterInfo();
  RS = new RegScavenger();

  bool Modified = false;
  for (MachineFunction::iterator MFI = Fn.begin(), E = Fn.end(); MFI != E;
       ++MFI) {
    MachineBasicBlock &MBB = *MFI;
    Modified |= LoadStoreMultipleOpti(MBB);
    Modified |= MergeReturnIntoLDM(MBB);
  }

  delete RS;
  return Modified;
}


/// ARMPreAllocLoadStoreOpt - Pre- register allocation pass that move
/// load / stores from consecutive locations close to make it more
/// likely they will be combined later.

namespace {
  struct VISIBILITY_HIDDEN ARMPreAllocLoadStoreOpt : public MachineFunctionPass{
    static char ID;
    ARMPreAllocLoadStoreOpt() : MachineFunctionPass(&ID) {}

    const TargetData *TD;
    const TargetInstrInfo *TII;
    const TargetRegisterInfo *TRI;
    const ARMSubtarget *STI;
    MachineRegisterInfo *MRI;

    virtual bool runOnMachineFunction(MachineFunction &Fn);

    virtual const char *getPassName() const {
      return "ARM pre- register allocation load / store optimization pass";
    }

  private:
    bool SatisfyLdStDWordlignment(MachineInstr *MI);
    bool RescheduleOps(MachineBasicBlock *MBB,
                       SmallVector<MachineInstr*, 4> &Ops,
                       unsigned Base, bool isLd,
                       DenseMap<MachineInstr*, unsigned> &MI2LocMap);
    bool RescheduleLoadStoreInstrs(MachineBasicBlock *MBB);
  };
  char ARMPreAllocLoadStoreOpt::ID = 0;
}

bool ARMPreAllocLoadStoreOpt::runOnMachineFunction(MachineFunction &Fn) {
  TD  = Fn.getTarget().getTargetData();
  TII = Fn.getTarget().getInstrInfo();
  TRI = Fn.getTarget().getRegisterInfo();
  STI = &Fn.getTarget().getSubtarget<ARMSubtarget>();
  MRI = &Fn.getRegInfo();

  bool Modified = false;
  for (MachineFunction::iterator MFI = Fn.begin(), E = Fn.end(); MFI != E;
       ++MFI)
    Modified |= RescheduleLoadStoreInstrs(MFI);

  return Modified;
}

static bool IsSafeToMove(bool isLd, unsigned Base,
                         MachineBasicBlock::iterator I,
                         MachineBasicBlock::iterator E,
                         SmallPtrSet<MachineInstr*, 4> MoveOps,
                         const TargetRegisterInfo *TRI) {
  // Are there stores / loads / calls between them?
  // FIXME: This is overly conservative. We should make use of alias information
  // some day.
  while (++I != E) {
    const TargetInstrDesc &TID = I->getDesc();
    if (TID.isCall() || TID.isTerminator() || TID.hasUnmodeledSideEffects())
      return false;
    if (isLd && TID.mayStore())
      return false;
    if (!isLd) {
      if (TID.mayLoad())
        return false;
      // It's not safe to move the first 'str' down.
      // str r1, [r0]
      // strh r5, [r0]
      // str r4, [r0, #+4]
      if (TID.mayStore() && !MoveOps.count(&*I))
        return false;
    }
    for (unsigned j = 0, NumOps = I->getNumOperands(); j != NumOps; ++j) {
      MachineOperand &MO = I->getOperand(j);
      if (MO.isReg() && MO.isDef() && TRI->regsOverlap(MO.getReg(), Base))
        return false;
    }
  }
  return true;
}

bool ARMPreAllocLoadStoreOpt::SatisfyLdStDWordlignment(MachineInstr *MI) {
  if (!MI->hasOneMemOperand() ||
      !MI->memoperands_begin()->getValue() ||
      MI->memoperands_begin()->isVolatile())
    return false;

  unsigned Align = MI->memoperands_begin()->getAlignment();
  unsigned ReqAlign = STI->hasV6Ops()
    ? TD->getPrefTypeAlignment(Type::Int64Ty) : 8; // Pre-v6 need 8-byte align
  return Align >= ReqAlign;
}

bool ARMPreAllocLoadStoreOpt::RescheduleOps(MachineBasicBlock *MBB,
                                 SmallVector<MachineInstr*, 4> &Ops,
                                 unsigned Base, bool isLd,
                                 DenseMap<MachineInstr*, unsigned> &MI2LocMap) {
  bool RetVal = false;

  // Sort by offset (in reverse order).
  std::sort(Ops.begin(), Ops.end(), OffsetCompare());

  // The loads / stores of the same base are in order. Scan them from first to
  // last and check for the followins:
  // 1. Any def of base.
  // 2. Any gaps.
  while (Ops.size() > 1) {
    unsigned FirstLoc = ~0U;
    unsigned LastLoc = 0;
    MachineInstr *FirstOp = 0;
    MachineInstr *LastOp = 0;
    int LastOffset = 0;
    unsigned LastBytes = 0;
    unsigned NumMove = 0;
    for (int i = Ops.size() - 1; i >= 0; --i) {
      MachineInstr *Op = Ops[i];
      unsigned Loc = MI2LocMap[Op];
      if (Loc <= FirstLoc) {
        FirstLoc = Loc;
        FirstOp = Op;
      }
      if (Loc >= LastLoc) {
        LastLoc = Loc;
        LastOp = Op;
      }

      int Offset = getMemoryOpOffset(Op);
      unsigned Bytes = getLSMultipleTransferSize(Op);
      if (LastBytes) {
        if (Bytes != LastBytes || Offset != (LastOffset + (int)Bytes))
          break;
      }
      LastOffset = Offset;
      LastBytes = Bytes;
      if (++NumMove == 4)
        break;
    }

    if (NumMove <= 1)
      Ops.pop_back();
    else {
      SmallPtrSet<MachineInstr*, 4> MoveOps;
      for (int i = NumMove-1; i >= 0; --i)
        MoveOps.insert(Ops[i]);

      // Be conservative, if the instructions are too far apart, don't
      // move them. We want to limit the increase of register pressure.
      bool DoMove = (LastLoc - FirstLoc) < NumMove*4;
      if (DoMove)
        DoMove = IsSafeToMove(isLd, Base, FirstOp, LastOp, MoveOps, TRI);
      if (!DoMove) {
        for (unsigned i = 0; i != NumMove; ++i)
          Ops.pop_back();
      } else {
        // This is the new location for the loads / stores.
        MachineBasicBlock::iterator InsertPos = isLd ? FirstOp : LastOp;
        while (InsertPos != MBB->end() && MoveOps.count(InsertPos))
          ++InsertPos;

        // If we are moving a pair of loads / stores, see if it makes sense
        // to try to allocate a pair of registers that can form register pairs.
        unsigned PairOpcode = 0;
        unsigned Offset = 0;

        // Make sure the alignment requirement is met.
        if (NumMove == 2 && SatisfyLdStDWordlignment(Ops.back())) {
          int Opcode = Ops.back()->getOpcode();
          // FIXME: FLDS / FSTS -> FLDD / FSTD
          if (Opcode == ARM::LDR)
            PairOpcode = ARM::LDRD;
          else if (Opcode == ARM::STR)
            PairOpcode = ARM::STRD;
        }
        // Then make sure the immediate offset fits.
        if (PairOpcode) {
          int OffImm = getMemoryOpOffset(Ops.back());
          ARM_AM::AddrOpc AddSub = ARM_AM::add;
          if (OffImm < 0) {
            AddSub = ARM_AM::sub;
            OffImm = - OffImm;
          }
          if (OffImm >= 256) // 8 bits
            PairOpcode = 0;
          else
            Offset = ARM_AM::getAM3Opc(AddSub, OffImm);
        }

        if (!PairOpcode) {
          for (unsigned i = 0; i != NumMove; ++i) {
            MachineInstr *Op = Ops.back();
            Ops.pop_back();
            MBB->splice(InsertPos, MBB, Op);
          }
        } else {
          // Form the pair instruction instead.
          unsigned EvenReg = 0, OddReg = 0;
          unsigned BaseReg = 0, OffReg = 0, PredReg = 0;
          ARMCC::CondCodes Pred;
          DebugLoc dl;
          for (unsigned i = 0; i != NumMove; ++i) {
            MachineInstr *Op = Ops.back();
            Ops.pop_back();
            unsigned Reg = Op->getOperand(0).getReg();
            if (i == 0) {
              EvenReg = Reg;
              BaseReg = Op->getOperand(1).getReg();
              OffReg = Op->getOperand(2).getReg();
              Pred = getInstrPredicate(Op, PredReg);
              dl = Op->getDebugLoc();
            } else
              OddReg = Reg;
            MBB->erase(Op);
          }
          if (isLd)
            BuildMI(*MBB, InsertPos, dl, TII->get(PairOpcode))
              .addReg(EvenReg, RegState::Define)
              .addReg(OddReg, RegState::Define)
              .addReg(BaseReg).addReg(0).addImm(Offset)
              .addImm(Pred).addReg(PredReg);
          else
            BuildMI(*MBB, InsertPos, dl, TII->get(PairOpcode))
              .addReg(EvenReg)
              .addReg(OddReg)
              .addReg(BaseReg).addReg(0).addImm(Offset)
              .addImm(Pred).addReg(PredReg);

          // Add register allocation hints to form register pairs.
          MRI->setRegAllocationHint(EvenReg, ARMRI::RegPairEven, OddReg);
          MRI->setRegAllocationHint(OddReg,  ARMRI::RegPairOdd, EvenReg);
        }

        NumLdStMoved += NumMove;
        RetVal = true;
      }
    }
  }

  return RetVal;
}

bool
ARMPreAllocLoadStoreOpt::RescheduleLoadStoreInstrs(MachineBasicBlock *MBB) {
  bool RetVal = false;

  DenseMap<MachineInstr*, unsigned> MI2LocMap;
  DenseMap<unsigned, SmallVector<MachineInstr*, 4> > Base2LdsMap;
  DenseMap<unsigned, SmallVector<MachineInstr*, 4> > Base2StsMap;
  SmallVector<unsigned, 4> LdBases;
  SmallVector<unsigned, 4> StBases;

  unsigned Loc = 0;
  MachineBasicBlock::iterator MBBI = MBB->begin();
  MachineBasicBlock::iterator E = MBB->end();
  while (MBBI != E) {
    for (; MBBI != E; ++MBBI) {
      MachineInstr *MI = MBBI;
      const TargetInstrDesc &TID = MI->getDesc();
      if (TID.isCall() || TID.isTerminator()) {
        // Stop at barriers.
        ++MBBI;
        break;
      }

      MI2LocMap[MI] = Loc++;
      if (!isMemoryOp(MI))
        continue;
      unsigned PredReg = 0;
      if (getInstrPredicate(MI, PredReg) != ARMCC::AL)
        continue;

      int Opcode = MI->getOpcode();
      bool isLd = Opcode == ARM::LDR ||
        Opcode == ARM::FLDS || Opcode == ARM::FLDD;
      unsigned Base = MI->getOperand(1).getReg();
      int Offset = getMemoryOpOffset(MI);

      bool StopHere = false;
      if (isLd) {
        DenseMap<unsigned, SmallVector<MachineInstr*, 4> >::iterator BI =
          Base2LdsMap.find(Base);
        if (BI != Base2LdsMap.end()) {
          for (unsigned i = 0, e = BI->second.size(); i != e; ++i) {
            if (Offset == getMemoryOpOffset(BI->second[i])) {
              StopHere = true;
              break;
            }
          }
          if (!StopHere)
            BI->second.push_back(MI);
        } else {
          SmallVector<MachineInstr*, 4> MIs;
          MIs.push_back(MI);
          Base2LdsMap[Base] = MIs;
          LdBases.push_back(Base);
        }
      } else {
        DenseMap<unsigned, SmallVector<MachineInstr*, 4> >::iterator BI =
          Base2StsMap.find(Base);
        if (BI != Base2StsMap.end()) {
          for (unsigned i = 0, e = BI->second.size(); i != e; ++i) {
            if (Offset == getMemoryOpOffset(BI->second[i])) {
              StopHere = true;
              break;
            }
          }
          if (!StopHere)
            BI->second.push_back(MI);
        } else {
          SmallVector<MachineInstr*, 4> MIs;
          MIs.push_back(MI);
          Base2StsMap[Base] = MIs;
          StBases.push_back(Base);
        }
      }

      if (StopHere) {
        // Found a duplicate (a base+offset combination that's seen earlier). Backtrack.
        --Loc;
        break;
      }
    }

    // Re-schedule loads.
    for (unsigned i = 0, e = LdBases.size(); i != e; ++i) {
      unsigned Base = LdBases[i];
      SmallVector<MachineInstr*, 4> &Lds = Base2LdsMap[Base];
      if (Lds.size() > 1)
        RetVal |= RescheduleOps(MBB, Lds, Base, true, MI2LocMap);
    }

    // Re-schedule stores.
    for (unsigned i = 0, e = StBases.size(); i != e; ++i) {
      unsigned Base = StBases[i];
      SmallVector<MachineInstr*, 4> &Sts = Base2StsMap[Base];
      if (Sts.size() > 1)
        RetVal |= RescheduleOps(MBB, Sts, Base, false, MI2LocMap);
    }

    if (MBBI != E) {
      Base2LdsMap.clear();
      Base2StsMap.clear();
      LdBases.clear();
      StBases.clear();
    }
  }

  return RetVal;
}


/// createARMLoadStoreOptimizationPass - returns an instance of the load / store
/// optimization pass.
FunctionPass *llvm::createARMLoadStoreOptimizationPass(bool PreAlloc) {
  if (PreAlloc)
    return new ARMPreAllocLoadStoreOpt();
  return new ARMLoadStoreOpt();
}
