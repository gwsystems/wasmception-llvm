//===--------------------- Backend.cpp --------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// Implementation of class Backend which emulates an hardware OoO backend.
///
//===----------------------------------------------------------------------===//

#include "Backend.h"
#include "HWEventListener.h"
#include "llvm/CodeGen/TargetSchedule.h"
#include "llvm/Support/Debug.h"

namespace mca {

#define DEBUG_TYPE "llvm-mca"

using namespace llvm;

void Backend::addEventListener(HWEventListener *Listener) {
  if (Listener)
    Listeners.insert(Listener);
}

void Backend::runCycle(unsigned Cycle) {
  notifyCycleBegin(Cycle);

  if (!SM.hasNext()) {
    notifyCycleEnd(Cycle);
    return;
  }

  InstRef IR = SM.peekNext();
  const InstrDesc *Desc = &IB->getOrCreateInstrDesc(STI, *IR.second);
  while (DU->isAvailable(Desc->NumMicroOps) && DU->canDispatch(*Desc)) {
    Instruction *NewIS = IB->createInstruction(STI, *DU, IR.first, *IR.second);
    Instructions[IR.first] = std::unique_ptr<Instruction>(NewIS);
    NewIS->setRCUTokenID(DU->dispatch(IR.first, NewIS));

    // Check if we have dispatched all the instructions.
    SM.updateNext();
    if (!SM.hasNext())
      break;

    // Prepare for the next round.
    IR = SM.peekNext();
    Desc = &IB->getOrCreateInstrDesc(STI, *IR.second);
  }

  notifyCycleEnd(Cycle);
}

void Backend::notifyCycleBegin(unsigned Cycle) {
  DEBUG(dbgs() << "[E] Cycle begin: " << Cycle << '\n');
  for (HWEventListener *Listener : Listeners)
    Listener->onCycleBegin(Cycle);

  DU->cycleEvent(Cycle);
  HWS->cycleEvent(Cycle);
}

void Backend::notifyInstructionEvent(const HWInstructionEvent &Event) {
  for (HWEventListener *Listener : Listeners)
    Listener->onInstructionEvent(Event);
}

void Backend::notifyResourceAvailable(const ResourceRef &RR) {
  DEBUG(dbgs() << "[E] Resource Available: [" << RR.first << '.' << RR.second
               << "]\n");
  for (HWEventListener *Listener : Listeners)
    Listener->onResourceAvailable(RR);
}

void Backend::notifyCycleEnd(unsigned Cycle) {
  DEBUG(dbgs() << "[E] Cycle end: " << Cycle << "\n\n");
  for (HWEventListener *Listener : Listeners)
    Listener->onCycleEnd(Cycle);
}

} // namespace mca.
