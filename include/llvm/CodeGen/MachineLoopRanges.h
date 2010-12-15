//===- MachineLoopRanges.h - Ranges of machine loops -----------*- c++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides the interface to the MachineLoopRanges analysis.
//
// Provide on-demand information about the ranges of machine instructions
// covered by a loop.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINELOOPRANGES_H
#define LLVM_CODEGEN_MACHINELOOPRANGES_H

#include "llvm/ADT/IntervalMap.h"
#include "llvm/CodeGen/SlotIndexes.h"

namespace llvm {

class MachineLoop;
class MachineLoopInfo;
class raw_ostream;

/// MachineLoopRange - Range information for a single loop.
class MachineLoopRange {
  friend class MachineLoopRanges;
  typedef IntervalMap<SlotIndex, unsigned, 4> RangeMap;
  typedef RangeMap::Allocator Allocator;

  /// The mapped loop.
  const MachineLoop *const Loop;

  /// Map intervals to a bit mask.
  /// Bit 0 = inside loop block.
  RangeMap Intervals;

  /// Create a MachineLoopRange, only accessible to MachineLoopRanges.
  MachineLoopRange(const MachineLoop*, Allocator&, SlotIndexes&);

public:
  /// overlaps - Return true if this loop overlaps the given range of machine
  /// inteructions.
  bool overlaps(SlotIndex Start, SlotIndex Stop);

  /// print - Print loop ranges on OS.
  void print(raw_ostream&) const;
};

raw_ostream &operator<<(raw_ostream&, const MachineLoopRange&);

/// MachineLoopRanges - Analysis pass that provides on-demand per-loop range
/// information.
class MachineLoopRanges : public MachineFunctionPass {
  typedef DenseMap<const MachineLoop*, MachineLoopRange*> CacheMap;
  typedef MachineLoopRange::Allocator MapAllocator;

  MapAllocator Allocator;
  SlotIndexes *Indexes;
  CacheMap Cache;

public:
  static char ID; // Pass identification, replacement for typeid

  MachineLoopRanges() : MachineFunctionPass(ID), Indexes(0) {}
  ~MachineLoopRanges() { releaseMemory(); }

  /// getLoopRange - Return the range of loop.
  MachineLoopRange *getLoopRange(const MachineLoop *Loop);

private:
  virtual bool runOnMachineFunction(MachineFunction&);
  virtual void releaseMemory();
  virtual void getAnalysisUsage(AnalysisUsage&) const;
};


} // end namespace llvm

#endif // LLVM_CODEGEN_MACHINELOOPRANGES_H
