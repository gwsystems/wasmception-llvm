//===-- PPCCodeEmitter.cpp - JIT Code Emitter for PowerPC32 -------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the PowerPC 32-bit CodeEmitter and associated machinery to
// JIT-compile bytecode to native PowerPC.
//
//===----------------------------------------------------------------------===//

#include "PPCTargetMachine.h"
#include "PPCRelocations.h"
#include "PPC.h"
#include "llvm/Module.h"
#include "llvm/PassManager.h"
#include "llvm/CodeGen/MachineCodeEmitter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetOptions.h"
#include <iostream>
using namespace llvm;

namespace {
  class PPCCodeEmitter : public MachineFunctionPass {
    TargetMachine &TM;
    MachineCodeEmitter &MCE;

    // Tracks which instruction references which BasicBlock
    std::vector<std::pair<MachineBasicBlock*, unsigned*> > BBRefs;
    // Tracks where each BasicBlock starts
    std::map<MachineBasicBlock*, long> BBLocations;

    /// getMachineOpValue - evaluates the MachineOperand of a given MachineInstr
    ///
    int getMachineOpValue(MachineInstr &MI, MachineOperand &MO);

  public:
    PPCCodeEmitter(TargetMachine &T, MachineCodeEmitter &M)
      : TM(T), MCE(M) {}

    const char *getPassName() const { return "PowerPC Machine Code Emitter"; }

    /// runOnMachineFunction - emits the given MachineFunction to memory
    ///
    bool runOnMachineFunction(MachineFunction &MF);

    /// emitBasicBlock - emits the given MachineBasicBlock to memory
    ///
    void emitBasicBlock(MachineBasicBlock &MBB);

    /// emitWord - write a 32-bit word to memory at the current PC
    ///
    void emitWord(unsigned w) { MCE.emitWord(w); }

    /// getValueBit - return the particular bit of Val
    ///
    unsigned getValueBit(int64_t Val, unsigned bit) { return (Val >> bit) & 1; }

    /// getBinaryCodeForInstr - This function, generated by the
    /// CodeEmitterGenerator using TableGen, produces the binary encoding for
    /// machine instructions.
    ///
    unsigned getBinaryCodeForInstr(MachineInstr &MI);
  };
}

/// addPassesToEmitMachineCode - Add passes to the specified pass manager to get
/// machine code emitted.  This uses a MachineCodeEmitter object to handle
/// actually outputting the machine code and resolving things like the address
/// of functions.  This method should returns true if machine code emission is
/// not supported.
///
bool PPCTargetMachine::addPassesToEmitMachineCode(FunctionPassManager &PM,
                                                  MachineCodeEmitter &MCE) {
  // Machine code emitter pass for PowerPC
  PM.add(new PPCCodeEmitter(*this, MCE));
  // Delete machine code for this function after emitting it
  PM.add(createMachineCodeDeleter());
  return false;
}

bool PPCCodeEmitter::runOnMachineFunction(MachineFunction &MF) {
  MCE.startFunction(MF);
  MCE.emitConstantPool(MF.getConstantPool());
  for (MachineFunction::iterator BB = MF.begin(), E = MF.end(); BB != E; ++BB)
    emitBasicBlock(*BB);
  MCE.finishFunction(MF);

  // Resolve branches to BasicBlocks for the entire function
  for (unsigned i = 0, e = BBRefs.size(); i != e; ++i) {
    intptr_t Location = BBLocations[BBRefs[i].first];
    unsigned *Ref = BBRefs[i].second;
    DEBUG(std::cerr << "Fixup @ " << (void*)Ref << " to " << (void*)Location
                    << "\n");
    unsigned Instr = *Ref;
    intptr_t BranchTargetDisp = (Location - (intptr_t)Ref) >> 2;

    switch (Instr >> 26) {
    default: assert(0 && "Unknown branch user!");
    case 18:  // This is B or BL
      *Ref |= (BranchTargetDisp & ((1 << 24)-1)) << 2;
      break;
    case 16:  // This is BLT,BLE,BEQ,BGE,BGT,BNE, or other bcx instruction
      *Ref |= (BranchTargetDisp & ((1 << 14)-1)) << 2;
      break;
    }
  }
  BBRefs.clear();
  BBLocations.clear();

  return false;
}

void PPCCodeEmitter::emitBasicBlock(MachineBasicBlock &MBB) {
  assert(!PICEnabled && "CodeEmitter does not support PIC!");
  BBLocations[&MBB] = MCE.getCurrentPCValue();
  for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end(); I != E; ++I){
    MachineInstr &MI = *I;
    unsigned Opcode = MI.getOpcode();
    switch (MI.getOpcode()) {
    default:
      emitWord(getBinaryCodeForInstr(*I));
      break;
    case PPC::IMPLICIT_DEF_GPR:
    case PPC::IMPLICIT_DEF_F8:
    case PPC::IMPLICIT_DEF_F4:
      break; // pseudo opcode, no side effects
    case PPC::MovePCtoLR:
      assert(0 && "CodeEmitter does not support MovePCtoLR instruction");
      break;
    }
  }
}

static unsigned enumRegToMachineReg(unsigned enumReg) {
  switch (enumReg) {
  case PPC::R0 :  case PPC::F0 :  case PPC::CR0:  return  0;
  case PPC::R1 :  case PPC::F1 :  case PPC::CR1:  return  1;
  case PPC::R2 :  case PPC::F2 :  case PPC::CR2:  return  2;
  case PPC::R3 :  case PPC::F3 :  case PPC::CR3:  return  3;
  case PPC::R4 :  case PPC::F4 :  case PPC::CR4:  return  4;
  case PPC::R5 :  case PPC::F5 :  case PPC::CR5:  return  5;
  case PPC::R6 :  case PPC::F6 :  case PPC::CR6:  return  6;
  case PPC::R7 :  case PPC::F7 :  case PPC::CR7:  return  7;
  case PPC::R8 :  case PPC::F8 :  return  8;
  case PPC::R9 :  case PPC::F9 :  return  9;
  case PPC::R10:  case PPC::F10:  return 10;
  case PPC::R11:  case PPC::F11:  return 11;
  case PPC::R12:  case PPC::F12:  return 12;
  case PPC::R13:  case PPC::F13:  return 13;
  case PPC::R14:  case PPC::F14:  return 14;
  case PPC::R15:  case PPC::F15:  return 15;
  case PPC::R16:  case PPC::F16:  return 16;
  case PPC::R17:  case PPC::F17:  return 17;
  case PPC::R18:  case PPC::F18:  return 18;
  case PPC::R19:  case PPC::F19:  return 19;
  case PPC::R20:  case PPC::F20:  return 20;
  case PPC::R21:  case PPC::F21:  return 21;
  case PPC::R22:  case PPC::F22:  return 22;
  case PPC::R23:  case PPC::F23:  return 23;
  case PPC::R24:  case PPC::F24:  return 24;
  case PPC::R25:  case PPC::F25:  return 25;
  case PPC::R26:  case PPC::F26:  return 26;
  case PPC::R27:  case PPC::F27:  return 27;
  case PPC::R28:  case PPC::F28:  return 28;
  case PPC::R29:  case PPC::F29:  return 29;
  case PPC::R30:  case PPC::F30:  return 30;
  case PPC::R31:  case PPC::F31:  return 31;
  default:
    std::cerr << "Unhandled reg in enumRegToRealReg!\n";
    abort();
  }
}

int PPCCodeEmitter::getMachineOpValue(MachineInstr &MI, MachineOperand &MO) {

  int rv = 0; // Return value; defaults to 0 for unhandled cases
                  // or things that get fixed up later by the JIT.
  if (MO.isRegister()) {
    rv = enumRegToMachineReg(MO.getReg());

    // Special encoding for MTCRF and MFOCRF, which uses a bit mask for the
    // register, not the register number directly.
    if ((MI.getOpcode() == PPC::MTCRF || MI.getOpcode() == PPC::MFOCRF) &&
        (MO.getReg() >= PPC::CR0 && MO.getReg() <= PPC::CR7)) {
      rv = 0x80 >> rv;
    }
  } else if (MO.isImmediate()) {
    rv = MO.getImmedValue();
  } else if (MO.isGlobalAddress() || MO.isExternalSymbol()) {
    bool isExternal = MO.isExternalSymbol() ||
                      MO.getGlobal()->hasWeakLinkage() ||
                      MO.getGlobal()->hasLinkOnceLinkage() ||
                      (MO.getGlobal()->isExternal() &&
                       !MO.getGlobal()->hasNotBeenReadFromBytecode());
    unsigned Reloc = 0;
    if (MI.getOpcode() == PPC::BL)
      Reloc = PPC::reloc_pcrel_bx;
    else {
      switch (MI.getOpcode()) {
      default: MI.dump(); assert(0 && "Unknown instruction for relocation!");
      case PPC::LIS:
        if (isExternal)
          Reloc = PPC::reloc_absolute_ptr_high;   // Pointer to stub
        else
          Reloc = PPC::reloc_absolute_high;       // Pointer to symbol
        break;
      case PPC::LA:
        assert(!isExternal && "Something in the ISEL changed\n");
        Reloc = PPC::reloc_absolute_low;
        break;
      case PPC::LBZ:
      case PPC::LHA:
      case PPC::LHZ:
      case PPC::LWZ:
      case PPC::LFS:
      case PPC::LFD:
      case PPC::STB:
      case PPC::STH:
      case PPC::STW:
      case PPC::STFS:
      case PPC::STFD:
        if (isExternal)
          Reloc = PPC::reloc_absolute_ptr_low;
        else
          Reloc = PPC::reloc_absolute_low;
        break;
      }
    }
    if (MO.isGlobalAddress())
      MCE.addRelocation(MachineRelocation(MCE.getCurrentPCOffset(),
                                          Reloc, MO.getGlobal(), 0));
    else
      MCE.addRelocation(MachineRelocation(MCE.getCurrentPCOffset(),
                                          Reloc, MO.getSymbolName(), 0));
  } else if (MO.isMachineBasicBlock()) {
    unsigned* CurrPC = (unsigned*)(intptr_t)MCE.getCurrentPCValue();
    BBRefs.push_back(std::make_pair(MO.getMachineBasicBlock(), CurrPC));
  } else if (MO.isConstantPoolIndex()) {
    unsigned index = MO.getConstantPoolIndex();
    unsigned Opcode = MI.getOpcode();
    rv = MCE.getConstantPoolEntryAddress(index);
    if (Opcode == PPC::LIS || Opcode == PPC::ADDIS) {
      // lis wants hi16(addr)
      if ((short)rv < 0) rv += 1 << 16;
      rv >>= 16;
    } else if (Opcode == PPC::LWZ || Opcode == PPC::LA ||
               Opcode == PPC::LI ||
               Opcode == PPC::LFS || Opcode == PPC::LFD) {
      // These load opcodes want lo16(addr)
      rv &= 0xffff;
    } else {
      assert(0 && "Unknown constant pool using instruction!");
    }
  } else {
    std::cerr << "ERROR: Unknown type of MachineOperand: " << MO << "\n";
    abort();
  }

  return rv;
}

#include "PPCGenCodeEmitter.inc"

