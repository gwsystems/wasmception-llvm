//===--------------------- SchedulerStatistics.h ----------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines class SchedulerStatistics. Class SchedulerStatistics is a
/// View that listens to instruction issue events in order to print general
/// statistics related to the hardware schedulers.
///
/// Example:
/// ========
///
/// Schedulers - number of cycles where we saw N instructions issued:
/// [# issued], [# cycles]
///  0,          7  (5.4%)
///  1,          4  (3.1%)
///  2,          8  (6.2%)
///
/// Scheduler's queue usage:
/// JALU01,  0/20
/// JFPU01,  18/18
/// JLSAGU,  0/12
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_MCA_SCHEDULERSTATISTICS_H
#define LLVM_TOOLS_LLVM_MCA_SCHEDULERSTATISTICS_H

#include "View.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/MC/MCSubtargetInfo.h"

namespace mca {

class SchedulerStatistics : public View {
  const llvm::MCSubtargetInfo &STI;

  using Histogram = llvm::DenseMap<unsigned, unsigned>;
  Histogram IssuedPerCycle;

  unsigned NumIssued;
  unsigned NumCycles;

  // Tracks the usage of a scheduler's queue.
  struct BufferUsage {
    unsigned SlotsInUse;
    unsigned MaxUsedSlots;
  };

  llvm::DenseMap<unsigned, BufferUsage> BufferedResources;

  void updateHistograms() {
    IssuedPerCycle[NumIssued]++;
    NumIssued = 0;
  }

  void printSchedulerStatistics(llvm::raw_ostream &OS) const;

  void printIssuePerCycle(const Histogram &IssuePerCycle,
                          unsigned TotalCycles) const;
  void printSchedulerUsage(llvm::raw_ostream &OS,
                           const llvm::MCSchedModel &SM) const;

public:
  SchedulerStatistics(const llvm::MCSubtargetInfo &sti)
      : STI(sti), NumIssued(0), NumCycles(0) { }

  void onInstructionEvent(const HWInstructionEvent &Event) override;

  void onCycleBegin(unsigned Cycle) override { NumCycles++; }

  void onCycleEnd(unsigned Cycle) override { updateHistograms(); }

  // Increases the number of used scheduler queue slots of every buffered
  // resource in the Buffers set.
  void onReservedBuffers(llvm::ArrayRef<unsigned> Buffers) override;

  // Decreases by one the number of used scheduler queue slots of every
  // buffered resource in the Buffers set.
  void onReleasedBuffers(llvm::ArrayRef<unsigned> Buffers) override;

  void printView(llvm::raw_ostream &OS) const override {
    printSchedulerStatistics(OS);
    printSchedulerUsage(OS, STI.getSchedModel());
  }
};
} // namespace mca

#endif
