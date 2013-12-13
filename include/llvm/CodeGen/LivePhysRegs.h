//===- llvm/CodeGen/LivePhysRegs.h - Live Physical Register Set -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements a set of live physical registers. This can be used for
// ad hoc liveness tracking after register allocation. You can start with the
// live-ins/live-outs at the beginning/end of a block and update the information
// while walking the instructions inside the block.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_LIVE_PHYS_REGS_H
#define LLVM_CODEGEN_LIVE_PHYS_REGS_H

#include "llvm/ADT/SparseSet.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include <cassert>

namespace llvm {

class MachineInstr;

/// \brief A set of live physical registers with functions to track liveness
/// when walking backward/forward through a basic block.
class LivePhysRegs {
  const TargetRegisterInfo *TRI;
  SparseSet<unsigned> LiveRegs;

  LivePhysRegs(const LivePhysRegs&) LLVM_DELETED_FUNCTION;
  LivePhysRegs &operator=(const LivePhysRegs&) LLVM_DELETED_FUNCTION;
public:
  /// \brief Constructs a new empty LivePhysRegs set.
  LivePhysRegs() : TRI(0), LiveRegs() {}

  /// \brief Constructs and initialize an empty LivePhysRegs set.
  LivePhysRegs(const TargetRegisterInfo *TRI) : TRI(TRI) {
    LiveRegs.setUniverse(TRI->getNumRegs());
  }

  /// \brief Clear and initialize the LivePhysRegs set.
  void init(const TargetRegisterInfo *_TRI) {
    TRI = _TRI;
    LiveRegs.clear();
    LiveRegs.setUniverse(TRI->getNumRegs());
  }

  /// \brief Clears the LivePhysRegs set.
  void clear() { LiveRegs.clear(); }

  /// \brief Returns true if the set is empty.
  bool empty() const { return LiveRegs.empty(); }

  /// \brief Adds a physical register and all its sub-registers to the set.
  void addReg(unsigned Reg) {
    assert(TRI && "LivePhysRegs is not initialized.");
    for (MCSubRegIterator SubRegs(Reg, TRI, /*IncludeSelf=*/true);
         SubRegs.isValid(); ++SubRegs)
      LiveRegs.insert(*SubRegs);
  }

  /// \brief Removes a physical register, all its sub-registers, and all its
  /// super-registers from the set.
  void removeReg(unsigned Reg) {
    assert(TRI && "LivePhysRegs is not initialized.");
    for (MCSubRegIterator SubRegs(Reg, TRI, /*IncludeSelf=*/true);
         SubRegs.isValid(); ++SubRegs)
      LiveRegs.erase(*SubRegs);
    for (MCSuperRegIterator SuperRegs(Reg, TRI, /*IncludeSelf=*/false);
         SuperRegs.isValid(); ++SuperRegs)
      LiveRegs.erase(*SuperRegs);
  }

  /// \brief Removes physical registers clobbered by the regmask operand @p MO.
  void removeRegsInMask(const MachineOperand &MO);

  /// \brief Returns true if register @p Reg is contained in the set. This also
  /// works if only the super register of @p Reg has been defined, because we
  /// always add also all sub-registers to the set.
  bool contains(unsigned Reg) const { return LiveRegs.count(Reg); }

  /// \brief Simulates liveness when stepping backwards over an
  /// instruction(bundle): Remove Defs, add uses. This is the recommended way of
  /// calculating liveness.
  void stepBackward(const MachineInstr &MI);

  /// \brief Simulates liveness when stepping forward over an
  /// instruction(bundle): Remove killed-uses, add defs. This is the not
  /// recommended way, because it depends on accurate kill flags. If possible
  /// use stepBackwards() instead of this function.
  void stepForward(const MachineInstr &MI);

  /// \brief Adds all live-in registers of basic block @p MBB.
  void addLiveIns(const MachineBasicBlock *MBB) {
    for (MachineBasicBlock::livein_iterator LI = MBB->livein_begin(),
         LE = MBB->livein_end(); LI != LE; ++LI)
      addReg(*LI);
  }

  /// \brief Adds all live-out registers of basic block @p MBB.
  void addLiveOuts(const MachineBasicBlock *MBB) {
    for (MachineBasicBlock::const_succ_iterator SI = MBB->succ_begin(),
         SE = MBB->succ_end(); SI != SE; ++SI)
      addLiveIns(*SI);
  }

  typedef SparseSet<unsigned>::const_iterator const_iterator;
  const_iterator begin() const { return LiveRegs.begin(); }
  const_iterator end() const { return LiveRegs.end(); }
};

} // namespace llvm

#endif
