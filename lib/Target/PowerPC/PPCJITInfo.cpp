//===-- PPC32JITInfo.cpp - Implement the JIT interfaces for the PowerPC ---===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This file implements the JIT interfaces for the 32-bit PowerPC target.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "jit"
#include "PPC32JITInfo.h"
#include "PPC32Relocations.h"
#include "llvm/CodeGen/MachineCodeEmitter.h"
#include "llvm/Config/alloca.h"
using namespace llvm;

static TargetJITInfo::JITCompilerFn JITCompilerFunction;

#define BUILD_ADDIS(RD,RS,IMM16) \
  ((15 << 26) | ((RD) << 21) | ((RS) << 16) | ((IMM16) & 65535))
#define BUILD_ORI(RD,RS,UIMM16) \
  ((24 << 26) | ((RS) << 21) | ((RD) << 16) | ((UIMM16) & 65535))
#define BUILD_MTSPR(RS,SPR)      \
  ((31 << 26) | ((RS) << 21) | ((SPR) << 16) | (467 << 1))
#define BUILD_BCCTRx(BO,BI,LINK) \
  ((19 << 26) | ((BO) << 21) | ((BI) << 16) | (528 << 1) | ((LINK) & 1))

// Pseudo-ops
#define BUILD_LIS(RD,IMM16)    BUILD_ADDIS(RD,0,IMM16)
#define BUILD_MTCTR(RS)        BUILD_MTSPR(RS,9)
#define BUILD_BCTR(LINK)       BUILD_BCCTRx(20,0,LINK)


static void EmitBranchToAt(void *At, void *To, bool isCall) {
  intptr_t Addr = (intptr_t)To;

  // FIXME: should special case the short branch case.
  unsigned *AtI = (unsigned*)At;

  AtI[0] = BUILD_LIS(12, Addr >> 16);   // lis r12, hi16(address)
  AtI[1] = BUILD_ORI(12, 12, Addr);     // ori r12, r12, low16(address)
  AtI[2] = BUILD_MTCTR(12);             // mtctr r12
  AtI[3] = BUILD_BCTR(isCall);          // bctr/bctrl
}

static void CompilationCallback() {
  // FIXME: Should save R3-R10 and F1-F13 onto the stack, just like the Sparc
  // version does.
  //int IntRegs[8];
  //uint64_t FPRegs[13];
  unsigned *CameFromStub = (unsigned*)__builtin_return_address(0);
  unsigned *CameFromOrig = (unsigned*)__builtin_return_address(1);

  // Adjust our pointers to the branches, not the return addresses.
  --CameFromStub; --CameFromOrig;

  void *Target = JITCompilerFunction(CameFromStub);

  // Check to see if CameFromOrig[-1] is a 'bl' instruction, and if we can
  // rewrite it to branch directly to the destination.  If so, rewrite it so it
  // does not need to go through the stub anymore.
  unsigned CameFromOrigInst = *CameFromOrig;
  if ((CameFromOrigInst >> 26) == 18) {     // Direct call.
    intptr_t Offset = ((intptr_t)Target-(intptr_t)CameFromOrig) >> 2;
    if (Offset >= -(1 << 23) && Offset < (1 << 23)) {   // In range?
      // FIXME: hasn't been tested at all.
      // Clear the original target out:
      CameFromOrigInst &= (63 << 26) | 3;
      CameFromOrigInst |= Offset << 2;
      *CameFromOrig = CameFromOrigInst;
    }
  }
  
  // Locate the start of the stub.  If this is a short call, adjust backwards
  // the short amount, otherwise the full amount.
  bool isShortStub = (*CameFromStub >> 26) == 18;
  CameFromStub -= isShortStub ? 3 : 7;

  // Rewrite the stub with an unconditional branch to the target, for any users
  // who took the address of the stub.
  EmitBranchToAt(CameFromStub, Target, false);


  // FIXME: Need to restore the registers from IntRegs/FPRegs.

  // FIXME: Need to pop two frames off of the stack and return to a place where
  // we magically reexecute the call, or jump directly to the caller.  This
  // requires inline asm majik.
  assert(0 && "CompilationCallback not finished yet!");
}



TargetJITInfo::LazyResolverFn 
PPC32JITInfo::getLazyResolverFunction(JITCompilerFn Fn) {
  JITCompilerFunction = Fn;
  return CompilationCallback;
}

void *PPC32JITInfo::emitFunctionStub(void *Fn, MachineCodeEmitter &MCE) {
  // If this is just a call to an external function, emit a branch instead of a
  // call.  The code is the same except for one bit of the last instruction.
  if (Fn != CompilationCallback) {
    MCE.startFunctionStub(4*4);
    void *Addr = (void*)(intptr_t)MCE.getCurrentPCValue();
    MCE.emitWord(0);
    MCE.emitWord(0);
    MCE.emitWord(0);
    MCE.emitWord(0);
    EmitBranchToAt(Addr, Fn, false);
    return MCE.finishFunctionStub(0);
  }

  MCE.startFunctionStub(4*7);
  MCE.emitWord(0x9421ffe0);     // stwu    r1,-32(r1)
  MCE.emitWord(0x7d6802a6);     // mflr r11
  MCE.emitWord(0x91610028);     // stw r11, 40(r1)
  void *Addr = (void*)(intptr_t)MCE.getCurrentPCValue();
  MCE.emitWord(0);
  MCE.emitWord(0);
  MCE.emitWord(0);
  MCE.emitWord(0);
  EmitBranchToAt(Addr, Fn, true/*is call*/);
  return MCE.finishFunctionStub(0);
}


void PPC32JITInfo::relocate(void *Function, MachineRelocation *MR,
                            unsigned NumRelocs) {
  for (unsigned i = 0; i != NumRelocs; ++i, ++MR) {
    unsigned *RelocPos = (unsigned*)Function + MR->getMachineCodeOffset()/4;
    intptr_t ResultPtr = (intptr_t)MR->getResultPointer();
    switch ((PPC::RelocationType)MR->getRelocationType()) {
    default: assert(0 && "Unknown relocation type!");
    case PPC::reloc_pcrel_bx:
      // PC-relative relocation for b and bl instructions.
      ResultPtr = (ResultPtr-(intptr_t)RelocPos) >> 2;
      assert(ResultPtr >= -(1 << 23) && ResultPtr < (1 << 23) &&
             "Relocation out of range!");
      *RelocPos |= (ResultPtr & ((1 << 24)-1))  << 2;
      break;
    case PPC::reloc_absolute_loadhi:   // Relocate high bits into addis
    case PPC::reloc_absolute_la:       // Relocate low bits into addi
      ResultPtr += MR->getConstantVal();

      if (MR->getRelocationType() == PPC::reloc_absolute_loadhi) {
        // If the low part will have a carry (really a borrow) from the low
        // 16-bits into the high 16, add a bit to borrow from.
        if (((int)ResultPtr << 16) < 0)
          ResultPtr += 1 << 16;
        ResultPtr >>= 16;
      }

      // Do the addition then mask, so the addition does not overflow the 16-bit
      // immediate section of the instruction.
      unsigned LowBits  = (*RelocPos + ResultPtr) & 65535;
      unsigned HighBits = *RelocPos & ~65535;
      *RelocPos = LowBits | HighBits;  // Slam into low 16-bits
      break;
    }
  }
}

void PPC32JITInfo::replaceMachineCodeForFunction(void *Old, void *New) {
  EmitBranchToAt(Old, New, false);
}
