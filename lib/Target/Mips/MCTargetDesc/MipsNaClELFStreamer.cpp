//===-- MipsNaClELFStreamer.cpp - ELF Object Output for Mips NaCl ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements MCELFStreamer for Mips NaCl.  It emits .o object files
// as required by NaCl's SFI sandbox.  It inserts address-masking instructions
// before dangerous control-flow and memory access instructions.  It inserts
// address-masking instructions after instructions that change the stack
// pointer.  It ensures that the mask and the dangerous instruction are always
// emitted in the same bundle.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "mips-mc-nacl"

#include "Mips.h"
#include "MipsMCNaCl.h"
#include "llvm/MC/MCELFStreamer.h"

using namespace llvm;

namespace {

const unsigned IndirectBranchMaskReg = Mips::T6;
const unsigned LoadStoreStackMaskReg = Mips::T7;

/// Extend the generic MCELFStreamer class so that it can mask dangerous
/// instructions.

class MipsNaClELFStreamer : public MCELFStreamer {
public:
  MipsNaClELFStreamer(MCContext &Context, MCAsmBackend &TAB, raw_ostream &OS,
                      MCCodeEmitter *Emitter)
    : MCELFStreamer(Context, TAB, OS, Emitter) {}

  ~MipsNaClELFStreamer() {}

private:
  bool isIndirectJump(const MCInst &MI) {
    return MI.getOpcode() == Mips::JR || MI.getOpcode() == Mips::RET;
  }

  bool isStackPointerFirstOperand(const MCInst &MI) {
    return (MI.getNumOperands() > 0 && MI.getOperand(0).isReg()
            && MI.getOperand(0).getReg() == Mips::SP);
  }

  void emitMask(unsigned AddrReg, unsigned MaskReg,
                const MCSubtargetInfo &STI) {
    MCInst MaskInst;
    MaskInst.setOpcode(Mips::AND);
    MaskInst.addOperand(MCOperand::CreateReg(AddrReg));
    MaskInst.addOperand(MCOperand::CreateReg(AddrReg));
    MaskInst.addOperand(MCOperand::CreateReg(MaskReg));
    MCELFStreamer::EmitInstruction(MaskInst, STI);
  }

  // Sandbox indirect branch or return instruction by inserting mask operation
  // before it.
  void sandboxIndirectJump(const MCInst &MI, const MCSubtargetInfo &STI) {
    unsigned AddrReg = MI.getOperand(0).getReg();

    EmitBundleLock(false);
    emitMask(AddrReg, IndirectBranchMaskReg, STI);
    MCELFStreamer::EmitInstruction(MI, STI);
    EmitBundleUnlock();
  }

  // Sandbox memory access or SP change.  Insert mask operation before and/or
  // after the instruction.
  void sandboxLoadStoreStackChange(const MCInst &MI, unsigned AddrIdx,
                                   const MCSubtargetInfo &STI, bool MaskBefore,
                                   bool MaskAfter) {
    EmitBundleLock(false);
    if (MaskBefore) {
      // Sandbox memory access.
      unsigned BaseReg = MI.getOperand(AddrIdx).getReg();
      emitMask(BaseReg, LoadStoreStackMaskReg, STI);
    }
    MCELFStreamer::EmitInstruction(MI, STI);
    if (MaskAfter) {
      // Sandbox SP change.
      unsigned SPReg = MI.getOperand(0).getReg();
      assert((Mips::SP == SPReg) && "Unexpected stack-pointer register.");
      emitMask(SPReg, LoadStoreStackMaskReg, STI);
    }
    EmitBundleUnlock();
  }

public:
  /// This function is the one used to emit instruction data into the ELF
  /// streamer.  We override it to mask dangerous instructions.
  virtual void EmitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI) {
    // Sandbox indirect jumps.
    if (isIndirectJump(Inst)) {
      sandboxIndirectJump(Inst, STI);
      return;
    }

    // Sandbox loads, stores and SP changes.
    unsigned AddrIdx;
    bool IsStore;
    bool IsMemAccess = isBasePlusOffsetMemoryAccess(Inst.getOpcode(), &AddrIdx,
                                                    &IsStore);
    bool IsSPFirstOperand = isStackPointerFirstOperand(Inst);
    if (IsMemAccess || IsSPFirstOperand) {
      bool MaskBefore = (IsMemAccess
                         && baseRegNeedsLoadStoreMask(Inst.getOperand(AddrIdx)
                                                          .getReg()));
      bool MaskAfter = IsSPFirstOperand && !IsStore;
      if (MaskBefore || MaskAfter)
        sandboxLoadStoreStackChange(Inst, AddrIdx, STI, MaskBefore, MaskAfter);
      else
        MCELFStreamer::EmitInstruction(Inst, STI);
      return;
    }

    // None of the sandboxing applies, just emit the instruction.
    MCELFStreamer::EmitInstruction(Inst, STI);
  }
};

} // end anonymous namespace

namespace llvm {

bool isBasePlusOffsetMemoryAccess(unsigned Opcode, unsigned *AddrIdx,
                                  bool *IsStore) {
  if (IsStore)
    *IsStore = false;

  switch (Opcode) {
  default:
    return false;

  // Load instructions with base address register in position 1.
  case Mips::LB:
  case Mips::LBu:
  case Mips::LH:
  case Mips::LHu:
  case Mips::LW:
  case Mips::LWC1:
  case Mips::LDC1:
  case Mips::LL:
  case Mips::LWL:
  case Mips::LWR:
    *AddrIdx = 1;
    return true;

  // Store instructions with base address register in position 1.
  case Mips::SB:
  case Mips::SH:
  case Mips::SW:
  case Mips::SWC1:
  case Mips::SDC1:
  case Mips::SWL:
  case Mips::SWR:
    *AddrIdx = 1;
    if (IsStore)
      *IsStore = true;
    return true;

  // Store instructions with base address register in position 2.
  case Mips::SC:
    *AddrIdx = 2;
    if (IsStore)
      *IsStore = true;
    return true;
  }
}

bool baseRegNeedsLoadStoreMask(unsigned Reg) {
  // The contents of SP and thread pointer register do not require masking.
  return Reg != Mips::SP && Reg != Mips::T8;
}

MCELFStreamer *createMipsNaClELFStreamer(MCContext &Context, MCAsmBackend &TAB,
                                         raw_ostream &OS,
                                         MCCodeEmitter *Emitter, bool RelaxAll,
                                         bool NoExecStack) {
  MipsNaClELFStreamer *S = new MipsNaClELFStreamer(Context, TAB, OS, Emitter);
  if (RelaxAll)
    S->getAssembler().setRelaxAll(true);
  if (NoExecStack)
    S->getAssembler().setNoExecStack(true);

  // Set bundle-alignment as required by the NaCl ABI for the target.
  S->EmitBundleAlignMode(MIPS_NACL_BUNDLE_ALIGN);

  return S;
}

}
