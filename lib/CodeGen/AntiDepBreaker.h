//=- llvm/CodeGen/AntiDepBreaker.h - Anti-Dependence Breaking -*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the AntiDepBreaker class, which implements
// anti-dependence breaking heuristics for post-register-allocation scheduling.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_ANTIDEPBREAKER_H
#define LLVM_CODEGEN_ANTIDEPBREAKER_H

#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/SmallVector.h"

namespace llvm {

/// AntiDepBreaker - This class works into conjunction with the
/// post-RA scheduler to rename registers to break register
/// anti-dependencies.
class AntiDepBreaker {
public:
  typedef SmallSet<unsigned, 4> AntiDepRegSet;
  typedef SmallVector<unsigned, 4> AntiDepRegVector;
  typedef std::map<SUnit *, AntiDepRegVector> CandidateMap;

  virtual ~AntiDepBreaker();

  /// GetMaxTrials - Return the maximum number of anti-dependence
  /// breaking attempts that will be made for a block.
  virtual unsigned GetMaxTrials() =0;

  /// NeedCandidates - Return true if the schedule must provide
  /// candidates with BreakAntiDependencies().
  virtual bool NeedCandidates() =0;

  /// Start - Initialize anti-dep breaking for a new basic block.
  virtual void StartBlock(MachineBasicBlock *BB) =0;

  /// BreakAntiDependencies - Identifiy anti-dependencies within a
  /// basic-block region and break them by renaming registers. Return
  /// the number of anti-dependencies broken.
  ///
  virtual unsigned BreakAntiDependencies(std::vector<SUnit>& SUnits,
                                CandidateMap& Candidates,
                                MachineBasicBlock::iterator& Begin,
                                MachineBasicBlock::iterator& End,
                                unsigned InsertPosIndex) =0;
  
  /// Observe - Update liveness information to account for the current
  /// instruction, which will not be scheduled.
  ///
  virtual void Observe(MachineInstr *MI, unsigned Count,
                       unsigned InsertPosIndex) =0;
  
  /// Finish - Finish anti-dep breaking for a basic block.
  virtual void FinishBlock() =0;
};

}

#endif
