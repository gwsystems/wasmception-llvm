//===-- Mips/MipsCodeEmitter.cpp - Convert Mips Code to Machine Code ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===---------------------------------------------------------------------===//
//
// This file contains the pass that transforms the Mips machine instructions
// into relocatable machine code.
//
//===---------------------------------------------------------------------===//

#define DEBUG_TYPE "jit"
#include "Mips.h"
#include "MCTargetDesc/MipsBaseInfo.h"
#include "MipsInstrInfo.h"
#include "MipsRelocations.h"
#include "MipsSubtarget.h"
#include "MipsTargetMachine.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/JITCodeEmitter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/PassManager.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#ifndef NDEBUG
#include <iomanip>
#endif

using namespace llvm;

STATISTIC(NumEmitted, "Number of machine instructions emitted");

namespace {

class MipsCodeEmitter : public MachineFunctionPass {
  MipsJITInfo *JTI;
  const MipsInstrInfo *II;
  const DataLayout *TD;
  const MipsSubtarget *Subtarget;
  TargetMachine &TM;
  JITCodeEmitter &MCE;
  const std::vector<MachineConstantPoolEntry> *MCPEs;
  const std::vector<MachineJumpTableEntry> *MJTEs;
  bool IsPIC;

  void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<MachineModuleInfo> ();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  static char ID;

public:
  MipsCodeEmitter(TargetMachine &tm, JITCodeEmitter &mce)
    : MachineFunctionPass(ID), JTI(0), II(0), TD(0),
      TM(tm), MCE(mce), MCPEs(0), MJTEs(0),
      IsPIC(TM.getRelocationModel() == Reloc::PIC_) {}

  bool runOnMachineFunction(MachineFunction &MF);

  virtual const char *getPassName() const {
    return "Mips Machine Code Emitter";
  }

  /// getBinaryCodeForInstr - This function, generated by the
  /// CodeEmitterGenerator using TableGen, produces the binary encoding for
  /// machine instructions.
  uint64_t getBinaryCodeForInstr(const MachineInstr &MI) const;

  void emitInstruction(MachineBasicBlock::instr_iterator MI,
                       MachineBasicBlock &MBB);

private:

  void emitWord(unsigned Word);

  /// Routines that handle operands which add machine relocations which are
  /// fixed up by the relocation stage.
  void emitGlobalAddress(const GlobalValue *GV, unsigned Reloc,
                         bool MayNeedFarStub) const;
  void emitExternalSymbolAddress(const char *ES, unsigned Reloc) const;
  void emitConstPoolAddress(unsigned CPI, unsigned Reloc) const;
  void emitJumpTableAddress(unsigned JTIndex, unsigned Reloc) const;
  void emitMachineBasicBlock(MachineBasicBlock *BB, unsigned Reloc) const;

  /// getMachineOpValue - Return binary encoding of operand. If the machine
  /// operand requires relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MachineInstr &MI,
                             const MachineOperand &MO) const;

  unsigned getRelocation(const MachineInstr &MI,
                         const MachineOperand &MO) const;

  unsigned getJumpTargetOpValue(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getJumpTargetOpValueMM(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getBranchTargetOpValueMM(const MachineInstr &MI,
                                    unsigned OpNo) const;

  unsigned getBranchTargetOpValue(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getMemEncoding(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getMemEncodingMMImm12(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getMSAMemEncoding(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getSizeExtEncoding(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getSizeInsEncoding(const MachineInstr &MI, unsigned OpNo) const;
  unsigned getLSAImmEncoding(const MachineInstr &MI, unsigned OpNo) const;

  /// Expand pseudo instructions with accumulator register operands.
  void expandACCInstr(MachineBasicBlock::instr_iterator MI,
                      MachineBasicBlock &MBB, unsigned Opc) const;

  /// \brief Expand pseudo instruction. Return true if MI was expanded.
  bool expandPseudos(MachineBasicBlock::instr_iterator &MI,
                     MachineBasicBlock &MBB) const;
};
}

char MipsCodeEmitter::ID = 0;

bool MipsCodeEmitter::runOnMachineFunction(MachineFunction &MF) {
  MipsTargetMachine &Target = static_cast<MipsTargetMachine &>(
                                const_cast<TargetMachine &>(MF.getTarget()));

  JTI = Target.getJITInfo();
  II = Target.getInstrInfo();
  TD = Target.getDataLayout();
  Subtarget = &TM.getSubtarget<MipsSubtarget> ();
  MCPEs = &MF.getConstantPool()->getConstants();
  MJTEs = 0;
  if (MF.getJumpTableInfo()) MJTEs = &MF.getJumpTableInfo()->getJumpTables();
  JTI->Initialize(MF, IsPIC, Subtarget->isLittle());
  MCE.setModuleInfo(&getAnalysis<MachineModuleInfo> ());

  do {
    DEBUG(errs() << "JITTing function '"
        << MF.getName() << "'\n");
    MCE.startFunction(MF);

    for (MachineFunction::iterator MBB = MF.begin(), E = MF.end();
        MBB != E; ++MBB){
      MCE.StartMachineBasicBlock(MBB);
      for (MachineBasicBlock::instr_iterator I = MBB->instr_begin(),
           E = MBB->instr_end(); I != E;)
        emitInstruction(*I++, *MBB);
    }
  } while (MCE.finishFunction(MF));

  return false;
}

unsigned MipsCodeEmitter::getRelocation(const MachineInstr &MI,
                                        const MachineOperand &MO) const {
  // NOTE: This relocations are for static.
  uint64_t TSFlags = MI.getDesc().TSFlags;
  uint64_t Form = TSFlags & MipsII::FormMask;
  if (Form == MipsII::FrmJ)
    return Mips::reloc_mips_26;
  if ((Form == MipsII::FrmI || Form == MipsII::FrmFI)
       && MI.isBranch())
    return Mips::reloc_mips_pc16;
  if (Form == MipsII::FrmI && MI.getOpcode() == Mips::LUi)
    return Mips::reloc_mips_hi;
  return Mips::reloc_mips_lo;
}

unsigned MipsCodeEmitter::getJumpTargetOpValue(const MachineInstr &MI,
                                               unsigned OpNo) const {
  MachineOperand MO = MI.getOperand(OpNo);
  if (MO.isGlobal())
    emitGlobalAddress(MO.getGlobal(), getRelocation(MI, MO), true);
  else if (MO.isSymbol())
    emitExternalSymbolAddress(MO.getSymbolName(), getRelocation(MI, MO));
  else if (MO.isMBB())
    emitMachineBasicBlock(MO.getMBB(), getRelocation(MI, MO));
  else
    llvm_unreachable("Unexpected jump target operand kind.");
  return 0;
}

unsigned MipsCodeEmitter::getJumpTargetOpValueMM(const MachineInstr &MI,
                                                 unsigned OpNo) const {
  llvm_unreachable("Unimplemented function.");
  return 0;
}

unsigned MipsCodeEmitter::getBranchTargetOpValueMM(const MachineInstr &MI,
                                                   unsigned OpNo) const {
  llvm_unreachable("Unimplemented function.");
  return 0;
}

unsigned MipsCodeEmitter::getBranchTargetOpValue(const MachineInstr &MI,
                                                 unsigned OpNo) const {
  MachineOperand MO = MI.getOperand(OpNo);
  emitMachineBasicBlock(MO.getMBB(), getRelocation(MI, MO));
  return 0;
}

unsigned MipsCodeEmitter::getMemEncoding(const MachineInstr &MI,
                                         unsigned OpNo) const {
  // Base register is encoded in bits 20-16, offset is encoded in bits 15-0.
  assert(MI.getOperand(OpNo).isReg());
  unsigned RegBits = getMachineOpValue(MI, MI.getOperand(OpNo)) << 16;
  return (getMachineOpValue(MI, MI.getOperand(OpNo+1)) & 0xFFFF) | RegBits;
}

unsigned MipsCodeEmitter::getMemEncodingMMImm12(const MachineInstr &MI,
                                                unsigned OpNo) const {
  llvm_unreachable("Unimplemented function.");
  return 0;
}

unsigned MipsCodeEmitter::getMSAMemEncoding(const MachineInstr &MI,
                                            unsigned OpNo) const {
  llvm_unreachable("Unimplemented function.");
  return 0;
}

unsigned MipsCodeEmitter::getSizeExtEncoding(const MachineInstr &MI,
                                             unsigned OpNo) const {
  // size is encoded as size-1.
  return getMachineOpValue(MI, MI.getOperand(OpNo)) - 1;
}

unsigned MipsCodeEmitter::getSizeInsEncoding(const MachineInstr &MI,
                                             unsigned OpNo) const {
  // size is encoded as pos+size-1.
  return getMachineOpValue(MI, MI.getOperand(OpNo-1)) +
         getMachineOpValue(MI, MI.getOperand(OpNo)) - 1;
}

unsigned MipsCodeEmitter::getLSAImmEncoding(const MachineInstr &MI,
                                            unsigned OpNo) const {
  llvm_unreachable("Unimplemented function.");
  return 0;
}

/// getMachineOpValue - Return binary encoding of operand. If the machine
/// operand requires relocation, record the relocation and return zero.
unsigned MipsCodeEmitter::getMachineOpValue(const MachineInstr &MI,
                                            const MachineOperand &MO) const {
  if (MO.isReg())
    return TM.getRegisterInfo()->getEncodingValue(MO.getReg());
  else if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());
  else if (MO.isGlobal())
    emitGlobalAddress(MO.getGlobal(), getRelocation(MI, MO), true);
  else if (MO.isSymbol())
    emitExternalSymbolAddress(MO.getSymbolName(), getRelocation(MI, MO));
  else if (MO.isCPI())
    emitConstPoolAddress(MO.getIndex(), getRelocation(MI, MO));
  else if (MO.isJTI())
    emitJumpTableAddress(MO.getIndex(), getRelocation(MI, MO));
  else if (MO.isMBB())
    emitMachineBasicBlock(MO.getMBB(), getRelocation(MI, MO));
  else
    llvm_unreachable("Unable to encode MachineOperand!");
  return 0;
}

void MipsCodeEmitter::emitGlobalAddress(const GlobalValue *GV, unsigned Reloc,
                                        bool MayNeedFarStub) const {
  MCE.addRelocation(MachineRelocation::getGV(MCE.getCurrentPCOffset(), Reloc,
                                             const_cast<GlobalValue *>(GV), 0,
                                             MayNeedFarStub));
}

void MipsCodeEmitter::
emitExternalSymbolAddress(const char *ES, unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getExtSym(MCE.getCurrentPCOffset(),
                                                 Reloc, ES, 0, 0));
}

void MipsCodeEmitter::emitConstPoolAddress(unsigned CPI, unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getConstPool(MCE.getCurrentPCOffset(),
                                                    Reloc, CPI, 0, false));
}

void MipsCodeEmitter::
emitJumpTableAddress(unsigned JTIndex, unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getJumpTable(MCE.getCurrentPCOffset(),
                                                    Reloc, JTIndex, 0, false));
}

void MipsCodeEmitter::emitMachineBasicBlock(MachineBasicBlock *BB,
                                            unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getBB(MCE.getCurrentPCOffset(),
                                             Reloc, BB));
}

void MipsCodeEmitter::emitInstruction(MachineBasicBlock::instr_iterator MI,
                                      MachineBasicBlock &MBB) {
  DEBUG(errs() << "JIT: " << (void*)MCE.getCurrentPCValue() << ":\t" << *MI);

  // Expand pseudo instruction. Skip if MI was not expanded.
  if (((MI->getDesc().TSFlags & MipsII::FormMask) == MipsII::Pseudo) &&
      !expandPseudos(MI, MBB))
    return;

  MCE.processDebugLoc(MI->getDebugLoc(), true);

  emitWord(getBinaryCodeForInstr(*MI));
  ++NumEmitted;  // Keep track of the # of mi's emitted

  MCE.processDebugLoc(MI->getDebugLoc(), false);
}

void MipsCodeEmitter::emitWord(unsigned Word) {
  DEBUG(errs() << "  0x";
        errs().write_hex(Word) << "\n");
  if (Subtarget->isLittle())
    MCE.emitWordLE(Word);
  else
    MCE.emitWordBE(Word);
}

void MipsCodeEmitter::expandACCInstr(MachineBasicBlock::instr_iterator MI,
                                     MachineBasicBlock &MBB,
                                     unsigned Opc) const {
  // Expand "pseudomult $ac0, $t0, $t1" to "mult $t0, $t1".
  BuildMI(MBB, &*MI, MI->getDebugLoc(), II->get(Opc))
    .addReg(MI->getOperand(1).getReg()).addReg(MI->getOperand(2).getReg());
}

bool MipsCodeEmitter::expandPseudos(MachineBasicBlock::instr_iterator &MI,
                                    MachineBasicBlock &MBB) const {
  switch (MI->getOpcode()) {
  case Mips::NOP:
    BuildMI(MBB, &*MI, MI->getDebugLoc(), II->get(Mips::SLL), Mips::ZERO)
      .addReg(Mips::ZERO).addImm(0);
    break;
  case Mips::B:
    BuildMI(MBB, &*MI, MI->getDebugLoc(), II->get(Mips::BEQ)).addReg(Mips::ZERO)
      .addReg(Mips::ZERO).addOperand(MI->getOperand(0));
    break;
  case Mips::TRAP:
    BuildMI(MBB, &*MI, MI->getDebugLoc(), II->get(Mips::BREAK)).addImm(0)
      .addImm(0);
    break;
  case Mips::JALRPseudo:
    BuildMI(MBB, &*MI, MI->getDebugLoc(), II->get(Mips::JALR), Mips::RA)
      .addReg(MI->getOperand(0).getReg());
    break;
  case Mips::PseudoMULT:
    expandACCInstr(MI, MBB, Mips::MULT);
    break;
  case Mips::PseudoMULTu:
    expandACCInstr(MI, MBB, Mips::MULTu);
    break;
  case Mips::PseudoSDIV:
    expandACCInstr(MI, MBB, Mips::SDIV);
    break;
  case Mips::PseudoUDIV:
    expandACCInstr(MI, MBB, Mips::UDIV);
    break;
  case Mips::PseudoMADD:
    expandACCInstr(MI, MBB, Mips::MADD);
    break;
  case Mips::PseudoMADDU:
    expandACCInstr(MI, MBB, Mips::MADDU);
    break;
  case Mips::PseudoMSUB:
    expandACCInstr(MI, MBB, Mips::MSUB);
    break;
  case Mips::PseudoMSUBU:
    expandACCInstr(MI, MBB, Mips::MSUBU);
    break;
  default:
    return false;
  }

  (MI--)->eraseFromBundle();
  return true;
}

/// createMipsJITCodeEmitterPass - Return a pass that emits the collected Mips
/// code to the specified MCE object.
FunctionPass *llvm::createMipsJITCodeEmitterPass(MipsTargetMachine &TM,
                                                 JITCodeEmitter &JCE) {
  return new MipsCodeEmitter(TM, JCE);
}

#include "MipsGenCodeEmitter.inc"
