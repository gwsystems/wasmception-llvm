//===-- Alpha/AlphaCodeEmitter.cpp - Convert Alpha code to machine code ---===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the pass that transforms the Alpha machine instructions
// into relocatable machine code.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "alpha-emitter"
#include "AlphaTargetMachine.h"
#include "AlphaRelocations.h"
#include "Alpha.h"
#include "llvm/PassManager.h"
#include "llvm/CodeGen/JITCodeEmitter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Function.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

namespace {
  class AlphaCodeEmitter : public MachineFunctionPass {
    JITCodeEmitter &MCE;
    const AlphaInstrInfo *II;
  public:
    static char ID;

    AlphaCodeEmitter(JITCodeEmitter &mce) : MachineFunctionPass(ID),
    MCE(mce) {}

    /// getBinaryCodeForInstr - This function, generated by the
    /// CodeEmitterGenerator using TableGen, produces the binary encoding for
    /// machine instructions.

    unsigned getBinaryCodeForInstr(const MachineInstr &MI) const;

    /// getMachineOpValue - evaluates the MachineOperand of a given MachineInstr

    unsigned getMachineOpValue(const MachineInstr &MI,
                               const MachineOperand &MO) const;
    
    bool runOnMachineFunction(MachineFunction &MF);
    
    virtual const char *getPassName() const {
      return "Alpha Machine Code Emitter";
    }
    
  private:
    void emitBasicBlock(MachineBasicBlock &MBB);
  };
}

char AlphaCodeEmitter::ID = 0;


/// createAlphaCodeEmitterPass - Return a pass that emits the collected Alpha
/// code to the specified MCE object.

FunctionPass *llvm::createAlphaJITCodeEmitterPass(AlphaTargetMachine &TM,
                                                  JITCodeEmitter &JCE) {
  return new AlphaCodeEmitter(JCE);
}

bool AlphaCodeEmitter::runOnMachineFunction(MachineFunction &MF) {
  II = ((AlphaTargetMachine&)MF.getTarget()).getInstrInfo();

  do {
    MCE.startFunction(MF);
    for (MachineFunction::iterator I = MF.begin(), E = MF.end(); I != E; ++I)
      emitBasicBlock(*I);
  } while (MCE.finishFunction(MF));

  return false;
}

void AlphaCodeEmitter::emitBasicBlock(MachineBasicBlock &MBB) {
  MCE.StartMachineBasicBlock(&MBB);
  for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end();
       I != E; ++I) {
    const MachineInstr &MI = *I;
    MCE.processDebugLoc(MI.getDebugLoc(), true);
    switch(MI.getOpcode()) {
    default:
      MCE.emitWordLE(getBinaryCodeForInstr(*I));
      break;
    case Alpha::ALTENT:
    case Alpha::PCLABEL:
    case Alpha::MEMLABEL:
    case TargetOpcode::IMPLICIT_DEF:
    case TargetOpcode::KILL:
      break; //skip these
    }
    MCE.processDebugLoc(MI.getDebugLoc(), false);
  }
}

static unsigned getAlphaRegNumber(unsigned Reg) {
  switch (Reg) {
  case Alpha::R0  : case Alpha::F0  : return 0;
  case Alpha::R1  : case Alpha::F1  : return 1;
  case Alpha::R2  : case Alpha::F2  : return 2;
  case Alpha::R3  : case Alpha::F3  : return 3;
  case Alpha::R4  : case Alpha::F4  : return 4;
  case Alpha::R5  : case Alpha::F5  : return 5;
  case Alpha::R6  : case Alpha::F6  : return 6;
  case Alpha::R7  : case Alpha::F7  : return 7;
  case Alpha::R8  : case Alpha::F8  : return 8;
  case Alpha::R9  : case Alpha::F9  : return 9;
  case Alpha::R10 : case Alpha::F10 : return 10;
  case Alpha::R11 : case Alpha::F11 : return 11;
  case Alpha::R12 : case Alpha::F12 : return 12;
  case Alpha::R13 : case Alpha::F13 : return 13;
  case Alpha::R14 : case Alpha::F14 : return 14;
  case Alpha::R15 : case Alpha::F15 : return 15;
  case Alpha::R16 : case Alpha::F16 : return 16;
  case Alpha::R17 : case Alpha::F17 : return 17;
  case Alpha::R18 : case Alpha::F18 : return 18;
  case Alpha::R19 : case Alpha::F19 : return 19;
  case Alpha::R20 : case Alpha::F20 : return 20;
  case Alpha::R21 : case Alpha::F21 : return 21;
  case Alpha::R22 : case Alpha::F22 : return 22;
  case Alpha::R23 : case Alpha::F23 : return 23;
  case Alpha::R24 : case Alpha::F24 : return 24;
  case Alpha::R25 : case Alpha::F25 : return 25;
  case Alpha::R26 : case Alpha::F26 : return 26;
  case Alpha::R27 : case Alpha::F27 : return 27;
  case Alpha::R28 : case Alpha::F28 : return 28;
  case Alpha::R29 : case Alpha::F29 : return 29;
  case Alpha::R30 : case Alpha::F30 : return 30;
  case Alpha::R31 : case Alpha::F31 : return 31;
  default:
    llvm_unreachable("Unhandled reg");
  }
}

unsigned AlphaCodeEmitter::getMachineOpValue(const MachineInstr &MI,
                                             const MachineOperand &MO) const {

  unsigned rv = 0; // Return value; defaults to 0 for unhandled cases
                   // or things that get fixed up later by the JIT.

  if (MO.isReg()) {
    rv = getAlphaRegNumber(MO.getReg());
  } else if (MO.isImm()) {
    rv = MO.getImm();
  } else if (MO.isGlobal() || MO.isSymbol() || MO.isCPI()) {
    DEBUG(errs() << MO << " is a relocated op for " << MI << "\n");
    unsigned Reloc = 0;
    int Offset = 0;
    bool useGOT = false;
    switch (MI.getOpcode()) {
    case Alpha::BSR:
      Reloc = Alpha::reloc_bsr;
      break;
    case Alpha::LDLr:
    case Alpha::LDQr:
    case Alpha::LDBUr:
    case Alpha::LDWUr:
    case Alpha::LDSr:
    case Alpha::LDTr:
    case Alpha::LDAr:
    case Alpha::STQr:
    case Alpha::STLr:
    case Alpha::STWr:
    case Alpha::STBr:
    case Alpha::STSr:
    case Alpha::STTr:
      Reloc = Alpha::reloc_gprellow;
      break;
    case Alpha::LDAHr:
      Reloc = Alpha::reloc_gprelhigh;
      break;
    case Alpha::LDQl:
      Reloc = Alpha::reloc_literal;
      useGOT = true;
      break;
    case Alpha::LDAg:
    case Alpha::LDAHg:
      Reloc = Alpha::reloc_gpdist;
      Offset = MI.getOperand(3).getImm();
      break;
    default:
      llvm_unreachable("unknown relocatable instruction");
    }
    if (MO.isGlobal())
      MCE.addRelocation(MachineRelocation::getGV(
            MCE.getCurrentPCOffset(),
            Reloc,
            const_cast<GlobalValue *>(MO.getGlobal()),
            Offset,
            isa<Function>(MO.getGlobal()),
            useGOT));
    else if (MO.isSymbol())
      MCE.addRelocation(MachineRelocation::getExtSym(MCE.getCurrentPCOffset(),
                                                     Reloc, MO.getSymbolName(),
                                                     Offset, true));
    else
     MCE.addRelocation(MachineRelocation::getConstPool(MCE.getCurrentPCOffset(),
                                          Reloc, MO.getIndex(), Offset));
  } else if (MO.isMBB()) {
    MCE.addRelocation(MachineRelocation::getBB(MCE.getCurrentPCOffset(),
                                               Alpha::reloc_bsr, MO.getMBB()));
  } else {
#ifndef NDEBUG
    errs() << "ERROR: Unknown type of MachineOperand: " << MO << "\n";
#endif
    llvm_unreachable(0);
  }

  return rv;
}

#include "AlphaGenCodeEmitter.inc"
