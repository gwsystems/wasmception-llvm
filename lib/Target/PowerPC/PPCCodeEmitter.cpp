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
#include "llvm/Support/Visibility.h"
#include "llvm/Target/TargetOptions.h"
#include <iostream>
using namespace llvm;

namespace {
  class VISIBILITY_HIDDEN PPCCodeEmitter : public MachineFunctionPass {
    TargetMachine &TM;
    MachineCodeEmitter &MCE;

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

#ifdef __APPLE__ 
extern "C" void sys_icache_invalidate(const void *Addr, size_t len);
#endif

bool PPCCodeEmitter::runOnMachineFunction(MachineFunction &MF) {
  assert((MF.getTarget().getRelocationModel() != Reloc::Default ||
          MF.getTarget().getRelocationModel() != Reloc::Static) &&
         "JIT relocation model must be set to static or default!");
  do {
    MCE.startFunction(MF);
    for (MachineFunction::iterator BB = MF.begin(), E = MF.end(); BB != E; ++BB)
      emitBasicBlock(*BB);
  } while (MCE.finishFunction(MF));

  return false;
}

void PPCCodeEmitter::emitBasicBlock(MachineBasicBlock &MBB) {
  MCE.StartMachineBasicBlock(&MBB);
  
  for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end(); I != E; ++I){
    MachineInstr &MI = *I;
    unsigned Opcode = MI.getOpcode();
    switch (MI.getOpcode()) {
    default:
      MCE.emitWordBE(getBinaryCodeForInstr(*I));
      break;
    case PPC::IMPLICIT_DEF_GPRC:
    case PPC::IMPLICIT_DEF_G8RC:
    case PPC::IMPLICIT_DEF_F8:
    case PPC::IMPLICIT_DEF_F4:
    case PPC::IMPLICIT_DEF_VRRC:
      break; // pseudo opcode, no side effects
    case PPC::MovePCtoLR:
      assert(0 && "CodeEmitter does not support MovePCtoLR instruction");
      break;
    }
  }
}

int PPCCodeEmitter::getMachineOpValue(MachineInstr &MI, MachineOperand &MO) {

  intptr_t rv = 0; // Return value; defaults to 0 for unhandled cases
                   // or things that get fixed up later by the JIT.
  if (MO.isRegister()) {
    rv = PPCRegisterInfo::getRegisterNumbering(MO.getReg());

    // Special encoding for MTCRF and MFOCRF, which uses a bit mask for the
    // register, not the register number directly.
    if ((MI.getOpcode() == PPC::MTCRF || MI.getOpcode() == PPC::MFOCRF) &&
        (MO.getReg() >= PPC::CR0 && MO.getReg() <= PPC::CR7)) {
      rv = 0x80 >> rv;
    }
  } else if (MO.isImmediate()) {
    rv = MO.getImmedValue();
  } else if (MO.isGlobalAddress() || MO.isExternalSymbol()) {
    unsigned Reloc = 0;
    if (MI.getOpcode() == PPC::BL)
      Reloc = PPC::reloc_pcrel_bx;
    else {
      switch (MI.getOpcode()) {
      default: DEBUG(MI.dump()); assert(0 && "Unknown instruction for relocation!");
      case PPC::LIS:
      case PPC::LIS8:
      case PPC::ADDIS8:
        Reloc = PPC::reloc_absolute_high;       // Pointer to symbol
        break;
      case PPC::LI:
      case PPC::LI8:
      case PPC::LA:
      // Loads.
      case PPC::LBZ:
      case PPC::LHA:
      case PPC::LHZ:
      case PPC::LWZ:
      case PPC::LFS:
      case PPC::LFD:
      case PPC::LWZ8:
      
      // Stores.
      case PPC::STB:
      case PPC::STH:
      case PPC::STW:
      case PPC::STFS:
      case PPC::STFD:
        Reloc = PPC::reloc_absolute_low;
        break;

      case PPC::LWA:
      case PPC::LD:
      case PPC::STD:
      case PPC::STD_32:
        Reloc = PPC::reloc_absolute_low_ix;
        break;
      }
    }
    if (MO.isGlobalAddress())
      MCE.addRelocation(MachineRelocation::getGV(MCE.getCurrentPCOffset(),
                                          Reloc, MO.getGlobal(), 0));
    else
      MCE.addRelocation(MachineRelocation::getExtSym(MCE.getCurrentPCOffset(),
                                          Reloc, MO.getSymbolName(), 0));
  } else if (MO.isMachineBasicBlock()) {
    unsigned* CurrPC = (unsigned*)(intptr_t)MCE.getCurrentPCValue();
    TM.getJITInfo()->addBBRef(MO.getMachineBasicBlock(), (intptr_t)CurrPC);
  } else if (MO.isConstantPoolIndex() || MO.isJumpTableIndex()) {
    if (MO.isConstantPoolIndex())
      rv = MCE.getConstantPoolEntryAddress(MO.getConstantPoolIndex());
    else
      rv = MCE.getJumpTableEntryAddress(MO.getJumpTableIndex());

    unsigned Opcode = MI.getOpcode();
    if (Opcode == PPC::LIS || Opcode == PPC::LIS8 ||
        Opcode == PPC::ADDIS || Opcode == PPC::ADDIS8) {
      // lis wants hi16(addr)
      if ((short)rv < 0) rv += 1 << 16;
      rv >>= 16;
    } else if (Opcode == PPC::LWZ || Opcode == PPC::LWZ8 ||
               Opcode == PPC::LA ||
               Opcode == PPC::LI  || Opcode == PPC::LI8 ||
               Opcode == PPC::LFS || Opcode == PPC::LFD) {
      // These load opcodes want lo16(addr)
      rv &= 0xffff;
    } else {
      MI.dump();
      assert(0 && "Unknown constant pool or jump table using instruction!");
    }
  } else {
    std::cerr << "ERROR: Unknown type of MachineOperand: " << MO << "\n";
    abort();
  }

  return rv;
}

#include "PPCGenCodeEmitter.inc"

