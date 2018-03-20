
//===----------------------- HWEventListener.h ------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines the main interface for hardware event listeners.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_MCA_HWEVENTLISTENER_H
#define LLVM_TOOLS_LLVM_MCA_HWEVENTLISTENER_H

#include "llvm/ADT/ArrayRef.h"
#include <utility>

namespace mca {

// An HWInstructionEvent represents state changes of instructions that
// listeners might be interested in. Listeners can choose to ignore any event
// they are not interested in.
class HWInstructionEvent {
public:
  // This is the list of event types that are shared by all targets, that
  // generic subtarget-agnostic classes (e.g. Backend, HWInstructionEvent, ...)
  // and generic Views can manipulate.
  // Subtargets are free to define additional event types, that are goin to be
  // handled by generic components as opaque values, but can still be
  // emitted by subtarget-specific pipeline components (e.g. Scheduler,
  // DispatchUnit, ...) and interpreted by subtarget-specific EventListener
  // implementations.
  enum GenericEventType {
    Invalid = 0,
    // Events generated by the Retire Control Unit.
    Retired,
    // Events generated by the Scheduler.
    Ready,
    Issued,
    Executed,
    // Events generated by the Dispatch logic.
    Dispatched,

    LastGenericEventType,
  };

  HWInstructionEvent(unsigned Type, unsigned Index)
      : Type(Type), Index(Index) {}

  // The event type. The exact meaning depends on the subtarget.
  const unsigned Type;
  // The index of the instruction in the source manager.
  const unsigned Index;
};

class HWInstructionIssuedEvent : public HWInstructionEvent {
public:
  using ResourceRef = std::pair<uint64_t, uint64_t>;
  HWInstructionIssuedEvent(
      unsigned Index, const llvm::ArrayRef<std::pair<ResourceRef, unsigned>> UR)
      : HWInstructionEvent(HWInstructionEvent::Issued, Index),
        UsedResources(UR) {}

  const llvm::ArrayRef<std::pair<ResourceRef, unsigned>> UsedResources;
};

// A HWStallEvent represents a pipeline stall caused by the lack of hardware
// resources.
class HWStallEvent {
public:
  enum GenericEventType {
    Invalid = 0,
    // Generic stall events generated by the DispatchUnit.
    RegisterFileStall,
    RetireControlUnitStall,
    DispatchGroupStall,
    SchedulerQueueFull,
    LoadQueueFull,
    StoreQueueFull,
    LastGenericEvent
  };

  HWStallEvent(unsigned type, unsigned index) : Type(type), Index(index) {}

  // The exact meaning of the stall event type depends on the subtarget.
  const unsigned Type;
  // The index of the instruction in the source manager.
  const unsigned Index;
};

class HWEventListener {
public:
  // Generic events generated by the backend pipeline.
  virtual void onCycleBegin(unsigned Cycle) {}
  virtual void onCycleEnd(unsigned Cycle) {}

  virtual void onInstructionEvent(const HWInstructionEvent &Event) {}
  virtual void onStallEvent(const HWStallEvent &Event) {}

  using ResourceRef = std::pair<uint64_t, uint64_t>;
  virtual void onResourceAvailable(const ResourceRef &RRef) {}

  // Events generated by the Scheduler when buffered resources are
  // consumed/freed.
  virtual void onReservedBuffers(llvm::ArrayRef<unsigned> Buffers) {}
  virtual void onReleasedBuffers(llvm::ArrayRef<unsigned> Buffers) {}

  virtual ~HWEventListener() {}

private:
  virtual void anchor();
};

} // namespace mca

#endif
