//===-- llvm/Target/TargetInstrItineraries.h - Scheduling -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the structures used for instruction itineraries and
// stages.  This is used by schedulers to determine instruction stages and
// latencies.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_TARGETINSTRITINERARIES_H
#define LLVM_TARGET_TARGETINSTRITINERARIES_H

#include <algorithm>

namespace llvm {

//===----------------------------------------------------------------------===//
/// Instruction stage - These values represent a non-pipelined step in
/// the execution of an instruction.  Cycles represents the number of
/// discrete time slots needed to complete the stage.  Units represent
/// the choice of functional units that can be used to complete the
/// stage.  Eg. IntUnit1, IntUnit2. NextCycles indicates how many
/// cycles should elapse from the start of this stage to the start of
/// the next stage in the itinerary. A value of -1 indicates that the
/// next stage should start immediately after the current one.
/// For example:
///
///   { 1, x, -1 }
///      indicates that the stage occupies FU x for 1 cycle and that
///      the next stage starts immediately after this one.
///
///   { 2, x|y, 1 }
///      indicates that the stage occupies either FU x or FU y for 2
///      consecuative cycles and that the next stage starts one cycle
///      after this stage starts. That is, the stage requirements
///      overlap in time.
///
///   { 1, x, 0 }
///      indicates that the stage occupies FU x for 1 cycle and that
///      the next stage starts in this same cycle. This can be used to
///      indicate that the instruction requires multiple stages at the
///      same time.
///
struct InstrStage {
  unsigned Cycles_;  ///< Length of stage in machine cycles
  unsigned Units_;   ///< Choice of functional units
  int NextCycles_;   ///< Number of machine cycles to next stage 

  /// getCycles - returns the number of cycles the stage is occupied
  unsigned getCycles() const {
    return Cycles_;
  }

  /// getUnits - returns the choice of FUs
  unsigned getUnits() const {
    return Units_;
  }

  /// getNextCycles - returns the number of cycles from the start of
  /// this stage to the start of the next stage in the itinerary
  unsigned getNextCycles() const {
    return (NextCycles_ >= 0) ? (unsigned)NextCycles_ : Cycles_;
  }
};


//===----------------------------------------------------------------------===//
/// Instruction itinerary - An itinerary represents a sequential series of steps
/// required to complete an instruction.  Itineraries are represented as
/// sequences of instruction stages.
///
struct InstrItinerary {
  unsigned First;    ///< Index of first stage in itinerary
  unsigned Last;     ///< Index of last + 1 stage in itinerary
};



//===----------------------------------------------------------------------===//
/// Instruction itinerary Data - Itinerary data supplied by a subtarget to be
/// used by a target.
///
struct InstrItineraryData {
  const InstrStage     *Stages;         ///< Array of stages selected
  const InstrItinerary *Itineratries;   ///< Array of itineraries selected

  /// Ctors.
  ///
  InstrItineraryData() : Stages(0), Itineratries(0) {}
  InstrItineraryData(const InstrStage *S, const InstrItinerary *I)
    : Stages(S), Itineratries(I) {}
  
  /// isEmpty - Returns true if there are no itineraries.
  ///
  bool isEmpty() const { return Itineratries == 0; }
  
  /// begin - Return the first stage of the itinerary.
  /// 
  const InstrStage *begin(unsigned ItinClassIndx) const {
    unsigned StageIdx = Itineratries[ItinClassIndx].First;
    return Stages + StageIdx;
  }

  /// end - Return the last+1 stage of the itinerary.
  /// 
  const InstrStage *end(unsigned ItinClassIndx) const {
    unsigned StageIdx = Itineratries[ItinClassIndx].Last;
    return Stages + StageIdx;
  }

  /// getLatency - Return the scheduling latency of the given class.  A
  /// simple latency value for an instruction is an over-simplification
  /// for some architectures, but it's a reasonable first approximation.
  ///
  unsigned getLatency(unsigned ItinClassIndx) const {
    // If the target doesn't provide latency information, use a simple
    // non-zero default value for all instructions.
    if (isEmpty())
      return 1;

    // Caclulate the maximum completion time for any stage. The
    // assumption is that all inputs are consumed at the start of the
    // first stage and that all outputs are produced at the end of the
    // latest completing last stage.
    unsigned Latency = 0, StartCycle = 0;
    for (const InstrStage *IS = begin(ItinClassIndx), *E = end(ItinClassIndx);
         IS != E; ++IS) {
      Latency = std::max(Latency, StartCycle + IS->getCycles());
      StartCycle += IS->getNextCycles();
    }

    return Latency;
  }
};


} // End llvm namespace

#endif
