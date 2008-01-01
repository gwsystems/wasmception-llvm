//===-- llvm/CodeGen/MachineRegisterInfo.h ----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the MachineRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINEREGISTERINFO_H
#define LLVM_CODEGEN_MACHINEREGISTERINFO_H

#include "llvm/Target/MRegisterInfo.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/iterator"
#include <vector>

namespace llvm {
  
/// MachineRegisterInfo - Keep track of information for each virtual register,
/// including its register class.
class MachineRegisterInfo {
  /// VRegInfo - Information we keep for each virtual register.  The entries in
  /// this vector are actually converted to vreg numbers by adding the 
  /// MRegisterInfo::FirstVirtualRegister delta to their index.
  ///
  /// Each element in this list contains the register class of the vreg and the
  /// start of the use/def list for the register.
  std::vector<std::pair<const TargetRegisterClass*, MachineOperand*> > VRegInfo;
  
  /// PhysRegUseDefLists - This is an array of the head of the use/def list for
  /// physical registers.
  MachineOperand **PhysRegUseDefLists; 
  
  /// UsedPhysRegs - This is a bit vector that is computed and set by the
  /// register allocator, and must be kept up to date by passes that run after
  /// register allocation (though most don't modify this).  This is used
  /// so that the code generator knows which callee save registers to save and
  /// for other target specific uses.
  BitVector UsedPhysRegs;
  
  /// LiveIns/LiveOuts - Keep track of the physical registers that are
  /// livein/liveout of the function.  Live in values are typically arguments in
  /// registers, live out values are typically return values in registers.
  /// LiveIn values are allowed to have virtual registers associated with them,
  /// stored in the second element.
  std::vector<std::pair<unsigned, unsigned> > LiveIns;
  std::vector<unsigned> LiveOuts;
  
  MachineRegisterInfo(const MachineRegisterInfo&); // DO NOT IMPLEMENT
  void operator=(const MachineRegisterInfo&);      // DO NOT IMPLEMENT
public:
  MachineRegisterInfo(const MRegisterInfo &MRI);
  ~MachineRegisterInfo();
  
  //===--------------------------------------------------------------------===//
  // Register Info
  //===--------------------------------------------------------------------===//

  /// reg_begin/reg_end - Provide iteration support to walk over all definitions
  /// and uses of a register within the MachineFunction that corresponds to this
  /// MachineRegisterInfo object.
  class reg_iterator;
  reg_iterator reg_begin(unsigned RegNo) const {
    return reg_iterator(getRegUseDefListHead(RegNo));
  }
  static reg_iterator reg_end() { return reg_iterator(0); }
  
  /// getRegUseDefListHead - Return the head pointer for the register use/def
  /// list for the specified virtual or physical register.
  MachineOperand *&getRegUseDefListHead(unsigned RegNo) {
    if (RegNo < MRegisterInfo::FirstVirtualRegister)
      return PhysRegUseDefLists[RegNo];
    RegNo -= MRegisterInfo::FirstVirtualRegister;
    return VRegInfo[RegNo].second;
  }
  
  MachineOperand *getRegUseDefListHead(unsigned RegNo) const {
    if (RegNo < MRegisterInfo::FirstVirtualRegister)
      return PhysRegUseDefLists[RegNo];
    RegNo -= MRegisterInfo::FirstVirtualRegister;
    return VRegInfo[RegNo].second;
  }
  
  //===--------------------------------------------------------------------===//
  // Virtual Register Info
  //===--------------------------------------------------------------------===//
  
  /// getRegClass - Return the register class of the specified virtual register.
  const TargetRegisterClass *getRegClass(unsigned Reg) {
    Reg -= MRegisterInfo::FirstVirtualRegister;
    assert(Reg < VRegInfo.size() && "Invalid vreg!");
    return VRegInfo[Reg].first;
  }
  
  /// createVirtualRegister - Create and return a new virtual register in the
  /// function with the specified register class.
  ///
  unsigned createVirtualRegister(const TargetRegisterClass *RegClass) {
    assert(RegClass && "Cannot create register without RegClass!");
    // Add a reg, but keep track of whether the vector reallocated or not.
    void *ArrayBase = &VRegInfo[0];
    VRegInfo.push_back(std::make_pair(RegClass, (MachineOperand*)0));
    
    if (&VRegInfo[0] == ArrayBase)
      return getLastVirtReg();

    // Otherwise, the vector reallocated, handle this now.
    HandleVRegListReallocation();
    return getLastVirtReg();
  }

  /// getLastVirtReg - Return the highest currently assigned virtual register.
  ///
  unsigned getLastVirtReg() const {
    return VRegInfo.size()+MRegisterInfo::FirstVirtualRegister-1;
  }
  
  //===--------------------------------------------------------------------===//
  // Physical Register Use Info
  //===--------------------------------------------------------------------===//
  
  /// isPhysRegUsed - Return true if the specified register is used in this
  /// function.  This only works after register allocation.
  bool isPhysRegUsed(unsigned Reg) const { return UsedPhysRegs[Reg]; }
  
  /// setPhysRegUsed - Mark the specified register used in this function.
  /// This should only be called during and after register allocation.
  void setPhysRegUsed(unsigned Reg) { UsedPhysRegs[Reg] = true; }
  
  /// setPhysRegUnused - Mark the specified register unused in this function.
  /// This should only be called during and after register allocation.
  void setPhysRegUnused(unsigned Reg) { UsedPhysRegs[Reg] = false; }
  

  //===--------------------------------------------------------------------===//
  // LiveIn/LiveOut Management
  //===--------------------------------------------------------------------===//
  
  /// addLiveIn/Out - Add the specified register as a live in/out.  Note that it
  /// is an error to add the same register to the same set more than once.
  void addLiveIn(unsigned Reg, unsigned vreg = 0) {
    LiveIns.push_back(std::make_pair(Reg, vreg));
  }
  void addLiveOut(unsigned Reg) { LiveOuts.push_back(Reg); }
  
  // Iteration support for live in/out sets.  These sets are kept in sorted
  // order by their register number.
  typedef std::vector<std::pair<unsigned,unsigned> >::const_iterator
  livein_iterator;
  typedef std::vector<unsigned>::const_iterator liveout_iterator;
  livein_iterator livein_begin() const { return LiveIns.begin(); }
  livein_iterator livein_end()   const { return LiveIns.end(); }
  bool            livein_empty() const { return LiveIns.empty(); }
  liveout_iterator liveout_begin() const { return LiveOuts.begin(); }
  liveout_iterator liveout_end()   const { return LiveOuts.end(); }
  bool             liveout_empty() const { return LiveOuts.empty(); }
private:
  void HandleVRegListReallocation();
  
public:
  /// reg_iterator - This class provides iterator support for machine
  /// operands in the function that use or define a specific register.
  class reg_iterator : public forward_iterator<MachineOperand, ptrdiff_t> {
    typedef forward_iterator<MachineOperand, ptrdiff_t> super;
    
    MachineOperand *Op;
    reg_iterator(MachineOperand *op) : Op(op) {}
    friend class MachineRegisterInfo;
  public:
    typedef super::reference reference;
    typedef super::pointer pointer;
    
    reg_iterator(const reg_iterator &I) : Op(I.Op) {}
    reg_iterator() : Op(0) {}
    
    bool operator==(const reg_iterator &x) const {
      return Op == x.Op;
    }
    bool operator!=(const reg_iterator &x) const {
      return !operator==(x);
    }
    
    /// atEnd - return true if this iterator is equal to reg_end() on the value.
    bool atEnd() const { return Op == 0; }
    
    // Iterator traversal: forward iteration only
    reg_iterator &operator++() {          // Preincrement
      assert(Op && "Cannot increment end iterator!");
      Op = Op->getNextOperandForReg();
      return *this;
    }
    reg_iterator operator++(int) {        // Postincrement
      reg_iterator tmp = *this; ++*this; return tmp;
    }
    
    // Retrieve a reference to the current operand.
    MachineOperand &operator*() const {
      assert(Op && "Cannot dereference end iterator!");
      return *Op;
    }
    
    MachineOperand *operator->() const { return Op; }
  };
  
};

} // End llvm namespace

#endif
