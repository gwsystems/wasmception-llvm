//===-- Sparc/SparcCodeEmitter.cpp - Convert Sparc Code to Machine Code ---===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===---------------------------------------------------------------------===//
//
// This file contains the pass that transforms the Sparc machine instructions
// into relocatable machine code.
//
//===---------------------------------------------------------------------===//

#include "Sparc.h"
#include "MCTargetDesc/SparcMCExpr.h"
#include "SparcRelocations.h"
#include "SparcTargetMachine.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/JITCodeEmitter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "jit"

STATISTIC(NumEmitted, "Number of machine instructions emitted");

namespace {

class SparcCodeEmitter : public MachineFunctionPass {
  SparcJITInfo *JTI;
  const SparcInstrInfo *II;
  const DataLayout *TD;
  const SparcSubtarget *Subtarget;
  TargetMachine &TM;
  JITCodeEmitter &MCE;
  const std::vector<MachineConstantPoolEntry> *MCPEs;
  bool IsPIC;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineModuleInfo> ();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  static char ID;

public:
  SparcCodeEmitter(TargetMachine &tm, JITCodeEmitter &mce)
    : MachineFunctionPass(ID), JTI(nullptr), II(nullptr), TD(nullptr),
      TM(tm), MCE(mce), MCPEs(nullptr),
      IsPIC(TM.getRelocationModel() == Reloc::PIC_) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  const char *getPassName() const override {
    return "Sparc Machine Code Emitter";
  }

  /// getBinaryCodeForInstr - This function, generated by the
  /// CodeEmitterGenerator using TableGen, produces the binary encoding for
  /// machine instructions.
  uint64_t getBinaryCodeForInstr(const MachineInstr &MI) const;

  void emitInstruction(MachineBasicBlock::instr_iterator MI,
                       MachineBasicBlock &MBB);

private:
  /// getMachineOpValue - Return binary encoding of operand. If the machine
  /// operand requires relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MachineInstr &MI,
                             const MachineOperand &MO) const;

  unsigned getCallTargetOpValue(const MachineInstr &MI,
                                unsigned) const;
  unsigned getBranchTargetOpValue(const MachineInstr &MI,
                                  unsigned) const;
  unsigned getBranchPredTargetOpValue(const MachineInstr &MI,
                                      unsigned) const;
  unsigned getBranchOnRegTargetOpValue(const MachineInstr &MI,
                                       unsigned) const;

  void emitWord(unsigned Word);

  unsigned getRelocation(const MachineInstr &MI,
                         const MachineOperand &MO) const;

  void emitGlobalAddress(const GlobalValue *GV, unsigned Reloc) const;
  void emitExternalSymbolAddress(const char *ES, unsigned Reloc) const;
  void emitConstPoolAddress(unsigned CPI, unsigned Reloc) const;
  void emitMachineBasicBlock(MachineBasicBlock *BB, unsigned Reloc) const;
};
}  // end anonymous namespace.

char SparcCodeEmitter::ID = 0;

bool SparcCodeEmitter::runOnMachineFunction(MachineFunction &MF) {
  SparcTargetMachine &Target = static_cast<SparcTargetMachine &>(
                                const_cast<TargetMachine &>(MF.getTarget()));

  JTI = Target.getSubtargetImpl()->getJITInfo();
  II = Target.getSubtargetImpl()->getInstrInfo();
  TD = Target.getSubtargetImpl()->getDataLayout();
  Subtarget = &TM.getSubtarget<SparcSubtarget>();
  MCPEs = &MF.getConstantPool()->getConstants();
  JTI->Initialize(MF, IsPIC);
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

void SparcCodeEmitter::emitInstruction(MachineBasicBlock::instr_iterator MI,
                                      MachineBasicBlock &MBB) {
  DEBUG(errs() << "JIT: " << (void*)MCE.getCurrentPCValue() << ":\t" << *MI);

  MCE.processDebugLoc(MI->getDebugLoc(), true);

  ++NumEmitted;

  switch (MI->getOpcode()) {
  default: {
    emitWord(getBinaryCodeForInstr(*MI));
    break;
  }
  case TargetOpcode::INLINEASM: {
    // We allow inline assembler nodes with empty bodies - they can
    // implicitly define registers, which is ok for JIT.
    if (MI->getOperand(0).getSymbolName()[0]) {
      report_fatal_error("JIT does not support inline asm!");
    }
    break;
  }
  case TargetOpcode::CFI_INSTRUCTION:
    break;
  case TargetOpcode::EH_LABEL: {
    MCE.emitLabel(MI->getOperand(0).getMCSymbol());
    break;
  }
  case TargetOpcode::IMPLICIT_DEF:
  case TargetOpcode::KILL: {
    // Do nothing.
    break;
  }
  case SP::GETPCX: {
    report_fatal_error("JIT does not support pseudo instruction GETPCX yet!");
    break;
  }
  }

  MCE.processDebugLoc(MI->getDebugLoc(), false);
}

void SparcCodeEmitter::emitWord(unsigned Word) {
  DEBUG(errs() << "  0x";
        errs().write_hex(Word) << "\n");
  MCE.emitWordBE(Word);
}

/// getMachineOpValue - Return binary encoding of operand. If the machine
/// operand requires relocation, record the relocation and return zero.
unsigned SparcCodeEmitter::getMachineOpValue(const MachineInstr &MI,
                                             const MachineOperand &MO) const {
  if (MO.isReg())
    return TM.getSubtargetImpl()->getRegisterInfo()->getEncodingValue(
        MO.getReg());
  else if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());
  else if (MO.isGlobal())
    emitGlobalAddress(MO.getGlobal(), getRelocation(MI, MO));
  else if (MO.isSymbol())
    emitExternalSymbolAddress(MO.getSymbolName(), getRelocation(MI, MO));
  else if (MO.isCPI())
    emitConstPoolAddress(MO.getIndex(), getRelocation(MI, MO));
  else if (MO.isMBB())
    emitMachineBasicBlock(MO.getMBB(), getRelocation(MI, MO));
  else
    llvm_unreachable("Unable to encode MachineOperand!");
  return 0;
}
unsigned SparcCodeEmitter::getCallTargetOpValue(const MachineInstr &MI,
                                                unsigned opIdx) const {
  const MachineOperand MO = MI.getOperand(opIdx);
  return getMachineOpValue(MI, MO);
}

unsigned SparcCodeEmitter::getBranchTargetOpValue(const MachineInstr &MI,
                                                  unsigned opIdx) const {
  const MachineOperand MO = MI.getOperand(opIdx);
  return getMachineOpValue(MI, MO);
}

unsigned SparcCodeEmitter::getBranchPredTargetOpValue(const MachineInstr &MI,
                                                      unsigned opIdx) const {
  const MachineOperand MO = MI.getOperand(opIdx);
  return getMachineOpValue(MI, MO);
}

unsigned SparcCodeEmitter::getBranchOnRegTargetOpValue(const MachineInstr &MI,
                                                       unsigned opIdx) const {
  const MachineOperand MO = MI.getOperand(opIdx);
  return getMachineOpValue(MI, MO);
}

unsigned SparcCodeEmitter::getRelocation(const MachineInstr &MI,
                                         const MachineOperand &MO) const {

  unsigned TF = MO.getTargetFlags();
  switch (TF) {
  default:
  case SparcMCExpr::VK_Sparc_None:  break;
  case SparcMCExpr::VK_Sparc_LO:    return SP::reloc_sparc_lo;
  case SparcMCExpr::VK_Sparc_HI:    return SP::reloc_sparc_hi;
  case SparcMCExpr::VK_Sparc_H44:   return SP::reloc_sparc_h44;
  case SparcMCExpr::VK_Sparc_M44:   return SP::reloc_sparc_m44;
  case SparcMCExpr::VK_Sparc_L44:   return SP::reloc_sparc_l44;
  case SparcMCExpr::VK_Sparc_HH:    return SP::reloc_sparc_hh;
  case SparcMCExpr::VK_Sparc_HM:    return SP::reloc_sparc_hm;
  }

  unsigned Opc = MI.getOpcode();
  switch (Opc) {
  default: break;
  case SP::CALL:    return SP::reloc_sparc_pc30;
  case SP::BA:
  case SP::BCOND:
  case SP::FBCOND:  return SP::reloc_sparc_pc22;
  case SP::BPXCC:   return SP::reloc_sparc_pc19;
  }
  llvm_unreachable("unknown reloc!");
}

void SparcCodeEmitter::emitGlobalAddress(const GlobalValue *GV,
                                        unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getGV(MCE.getCurrentPCOffset(), Reloc,
                                             const_cast<GlobalValue *>(GV), 0,
                                             true));
}

void SparcCodeEmitter::
emitExternalSymbolAddress(const char *ES, unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getExtSym(MCE.getCurrentPCOffset(),
                                                 Reloc, ES, 0, 0));
}

void SparcCodeEmitter::
emitConstPoolAddress(unsigned CPI, unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getConstPool(MCE.getCurrentPCOffset(),
                                                    Reloc, CPI, 0, false));
}

void SparcCodeEmitter::emitMachineBasicBlock(MachineBasicBlock *BB,
                                            unsigned Reloc) const {
  MCE.addRelocation(MachineRelocation::getBB(MCE.getCurrentPCOffset(),
                                             Reloc, BB));
}


/// createSparcJITCodeEmitterPass - Return a pass that emits the collected Sparc
/// code to the specified MCE object.
FunctionPass *llvm::createSparcJITCodeEmitterPass(SparcTargetMachine &TM,
                                                 JITCodeEmitter &JCE) {
  return new SparcCodeEmitter(TM, JCE);
}

#include "SparcGenCodeEmitter.inc"
