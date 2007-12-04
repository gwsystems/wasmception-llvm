//===-- SPUFrameInfo.h - Top-level interface for Cell SPU Target -*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by a team from the Computer Systems Research
// Department at The Aerospace Corporation.
//
// See README.txt for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains CellSPU frame information that doesn't fit anywhere else
// cleanly...
//
//===----------------------------------------------------------------------===//

#if !defined(SPUFRAMEINFO_H)

#include "llvm/Target/TargetFrameInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "SPURegisterInfo.h"

namespace llvm {
  class SPUFrameInfo: public TargetFrameInfo {
    const TargetMachine &TM;
    std::pair<unsigned, int> LR[1];

  public:
    SPUFrameInfo(const TargetMachine &tm);

    //! Return a function's saved spill slots
    /*!
      For CellSPU, a function's saved spill slots is just the link register.
     */
    const std::pair<unsigned, int> *
    getCalleeSaveSpillSlots(unsigned &NumEntries) const;

    //! Stack slot size (16 bytes)
    static const int stackSlotSize() {
      return 16;
    }
    //! Maximum frame offset representable by a signed 10-bit integer
    /*!
      This is the maximum frame offset that can be expressed as a 10-bit
      integer, used in D-form addresses.
     */
    static const int maxFrameOffset() {
      return ((1 << 9) - 1) * stackSlotSize();
    }
    //! Minimum frame offset representable by a signed 10-bit integer
    static const int minFrameOffset() {
      return -(1 << 9) * stackSlotSize();
    }
    //! Minimum frame size (enough to spill LR + SP)
    static const int minStackSize() {
      return (2 * stackSlotSize());
    }
    //! Frame size required to spill all registers plus frame info
    static const int fullSpillSize() {
      return (SPURegisterInfo::getNumArgRegs() * stackSlotSize());
    }
    //! Number of instructions required to overcome hint-for-branch latency
    /*!
      HBR (hint-for-branch) instructions can be inserted when, for example,
      we know that a given function is going to be called, such as printf(),
      in the control flow graph. HBRs are only inserted if a sufficient number
      of instructions occurs between the HBR and the target. Currently, HBRs
      take 6 cycles, ergo, the magic number 6.
     */
    static const int branchHintPenalty() {
      return 6;
    }
  };
}

#define SPUFRAMEINFO_H 1
#endif
