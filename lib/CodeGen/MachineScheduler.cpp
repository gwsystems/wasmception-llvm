//===- MachineScheduler.cpp - Machine Instruction Scheduler ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// MachineScheduler schedules machine instructions after phi elimination. It
// preserves LiveIntervals so it can be invoked before register allocation.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "misched"

#include "ScheduleDAGInstrs.h"
#include "LiveDebugVariables.h"
#include "llvm/CodeGen/LiveIntervalAnalysis.h"
#include "llvm/CodeGen/MachinePassRegistry.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/OwningPtr.h"

using namespace llvm;

//===----------------------------------------------------------------------===//
// Machine Instruction Scheduling Pass and Registry
//===----------------------------------------------------------------------===//

namespace {
/// MachineScheduler runs after coalescing and before register allocation.
class MachineScheduler : public MachineFunctionPass {
public:
  MachineFunction *MF;
  const TargetInstrInfo *TII;
  const MachineLoopInfo *MLI;
  const MachineDominatorTree *MDT;

  MachineScheduler();

  virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  virtual void releaseMemory() {}

  virtual bool runOnMachineFunction(MachineFunction&);

  virtual void print(raw_ostream &O, const Module* = 0) const;

  static char ID; // Class identification, replacement for typeinfo
};
} // namespace

char MachineScheduler::ID = 0;

char &llvm::MachineSchedulerID = MachineScheduler::ID;

INITIALIZE_PASS_BEGIN(MachineScheduler, "misched",
                      "Machine Instruction Scheduler", false, false)
INITIALIZE_AG_DEPENDENCY(AliasAnalysis)
INITIALIZE_PASS_DEPENDENCY(SlotIndexes)
INITIALIZE_PASS_DEPENDENCY(LiveIntervals)
INITIALIZE_PASS_DEPENDENCY(LiveDebugVariables)
INITIALIZE_PASS_DEPENDENCY(StrongPHIElimination)
INITIALIZE_PASS_DEPENDENCY(RegisterCoalescer)
INITIALIZE_PASS_END(MachineScheduler, "misched",
                    "Machine Instruction Scheduler", false, false)

MachineScheduler::MachineScheduler()
: MachineFunctionPass(ID), MF(0), MLI(0), MDT(0) {
  initializeMachineSchedulerPass(*PassRegistry::getPassRegistry());
}

void MachineScheduler::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesCFG();
  AU.addRequiredID(MachineDominatorsID);
  AU.addRequired<MachineLoopInfo>();
  AU.addRequired<AliasAnalysis>();
  AU.addPreserved<AliasAnalysis>();
  AU.addRequired<SlotIndexes>();
  AU.addPreserved<SlotIndexes>();
  AU.addRequired<LiveIntervals>();
  AU.addPreserved<LiveIntervals>();
  AU.addRequired<LiveDebugVariables>();
  AU.addPreserved<LiveDebugVariables>();
  if (StrongPHIElim) {
    AU.addRequiredID(StrongPHIEliminationID);
    AU.addPreservedID(StrongPHIEliminationID);
  }
  AU.addRequiredID(RegisterCoalescerPassID);
  AU.addPreservedID(RegisterCoalescerPassID);
  MachineFunctionPass::getAnalysisUsage(AU);
}

namespace {
/// MachineSchedRegistry provides a selection of available machine instruction
/// schedulers.
class MachineSchedRegistry : public MachinePassRegistryNode {
public:
  typedef ScheduleDAGInstrs *(*ScheduleDAGCtor)(MachineScheduler *);

  // RegisterPassParser requires a (misnamed) FunctionPassCtor type.
  typedef ScheduleDAGCtor FunctionPassCtor;

  static MachinePassRegistry Registry;

  MachineSchedRegistry(const char *N, const char *D, ScheduleDAGCtor C)
    : MachinePassRegistryNode(N, D, (MachinePassCtor)C) {
    Registry.Add(this);
  }
  ~MachineSchedRegistry() { Registry.Remove(this); }

  // Accessors.
  //
  MachineSchedRegistry *getNext() const {
    return (MachineSchedRegistry *)MachinePassRegistryNode::getNext();
  }
  static MachineSchedRegistry *getList() {
    return (MachineSchedRegistry *)Registry.getList();
  }
  static ScheduleDAGCtor getDefault() {
    return (ScheduleDAGCtor)Registry.getDefault();
  }
  static void setDefault(ScheduleDAGCtor C) {
    Registry.setDefault((MachinePassCtor)C);
  }
  static void setListener(MachinePassRegistryListener *L) {
    Registry.setListener(L);
  }
};
} // namespace

MachinePassRegistry MachineSchedRegistry::Registry;

static ScheduleDAGInstrs *createDefaultMachineSched(MachineScheduler *P);

/// MachineSchedOpt allows command line selection of the scheduler.
static cl::opt<MachineSchedRegistry::ScheduleDAGCtor, false,
               RegisterPassParser<MachineSchedRegistry> >
MachineSchedOpt("misched",
                cl::init(&createDefaultMachineSched), cl::Hidden,
                cl::desc("Machine instruction scheduler to use"));

//===----------------------------------------------------------------------===//
// Machine Instruction Scheduling Common Implementation
//===----------------------------------------------------------------------===//

namespace {
/// MachineScheduler is an implementation of ScheduleDAGInstrs that schedules
/// machine instructions while updating LiveIntervals.
class ScheduleTopDownLive : public ScheduleDAGInstrs {
protected:
  MachineScheduler *Pass;
public:
  ScheduleTopDownLive(MachineScheduler *P):
    ScheduleDAGInstrs(*P->MF, *P->MLI, *P->MDT, /*IsPostRA=*/false), Pass(P) {}
};
} // namespace

bool MachineScheduler::runOnMachineFunction(MachineFunction &mf) {
  // Initialize the context of the pass.
  MF = &mf;
  MLI = &getAnalysis<MachineLoopInfo>();
  MDT = &getAnalysis<MachineDominatorTree>();
  TII = MF->getTarget().getInstrInfo();

  // Select the scheduler, or set the default.
  MachineSchedRegistry::ScheduleDAGCtor Ctor =
    MachineSchedRegistry::getDefault();
  if (!Ctor) {
    Ctor = MachineSchedOpt;
    MachineSchedRegistry::setDefault(Ctor);
  }
  // Instantiate the selected scheduler.
  OwningPtr<ScheduleDAGInstrs> Scheduler(Ctor(this));

  // Visit all machine basic blocks.
  for (MachineFunction::iterator MBB = MF->begin(), MBBEnd = MF->end();
       MBB != MBBEnd; ++MBB) {

    // Break the block into scheduling regions [I, RegionEnd), and schedule each
    // region as soon as it is discovered.
    unsigned RemainingCount = MBB->size();
    for(MachineBasicBlock::iterator RegionEnd = MBB->end();
        RegionEnd != MBB->begin();) {
      // The next region starts above the previous region. Look backward in the
      // instruction stream until we find the nearest boundary.
      MachineBasicBlock::iterator I = RegionEnd;
      for(;I != MBB->begin(); --I, --RemainingCount) {
        if (TII->isSchedulingBoundary(llvm::prior(I), MBB, *MF))
          break;
      }
      if (I == RegionEnd) {
        // Skip empty scheduling regions.
        RegionEnd = llvm::prior(RegionEnd);
        --RemainingCount;
        continue;
      }
      // Schedule regions with more than one instruction.
      if (I != llvm::prior(RegionEnd)) {
        DEBUG(dbgs() << "MachineScheduling " << MF->getFunction()->getName()
              << ":BB#" << MBB->getNumber() << "\n  From: " << *I << "    To: "
              << *RegionEnd << " Remaining: " << RemainingCount << "\n");

        // Inform ScheduleDAGInstrs of the region being scheduled. It calls back
        // to our Schedule() method.
        Scheduler->Run(MBB, I, RegionEnd, MBB->size());
      }
      RegionEnd = I;
    }
    assert(RemainingCount == 0 && "Instruction count mismatch!");
  }
  return true;
}

void MachineScheduler::print(raw_ostream &O, const Module* m) const {
  // unimplemented
}

//===----------------------------------------------------------------------===//
// Placeholder for extending the machine instruction scheduler.
//===----------------------------------------------------------------------===//

namespace {
class DefaultMachineScheduler : public ScheduleTopDownLive {
public:
  DefaultMachineScheduler(MachineScheduler *P):
    ScheduleTopDownLive(P) {}

  void Schedule();
};
} // namespace

static ScheduleDAGInstrs *createDefaultMachineSched(MachineScheduler *P) {
  return new DefaultMachineScheduler(P);
}
static MachineSchedRegistry
SchedDefaultRegistry("default", "Activate the scheduler pass, "
                     "but don't reorder instructions",
                     createDefaultMachineSched);


/// Schedule - This is called back from ScheduleDAGInstrs::Run() when it's
/// time to do some work.
void DefaultMachineScheduler::Schedule() {
  BuildSchedGraph(&Pass->getAnalysis<AliasAnalysis>());

  DEBUG(dbgs() << "********** MI Scheduling **********\n");
  DEBUG(for (unsigned su = 0, e = SUnits.size(); su != e; ++su)
          SUnits[su].dumpAll(this));

  // TODO: Put interesting things here.
}

//===----------------------------------------------------------------------===//
// Machine Instruction Shuffler for Correctness Testing
//===----------------------------------------------------------------------===//

#ifndef NDEBUG
namespace {
/// Reorder instructions as much as possible.
class InstructionShuffler : public ScheduleTopDownLive {
  MachineScheduler *Pass;
public:
  InstructionShuffler(MachineScheduler *P):
    ScheduleTopDownLive(P) {}

  /// Schedule - This is called back from ScheduleDAGInstrs::Run() when it's
  /// time to do some work.
  virtual void Schedule() {
    llvm_unreachable("unimplemented");
  }
};
} // namespace

static ScheduleDAGInstrs *createInstructionShuffler(MachineScheduler *P) {
  return new InstructionShuffler(P);
}
static MachineSchedRegistry ShufflerRegistry("shuffle",
                                             "Shuffle machine instructions",
                                             createInstructionShuffler);
#endif // !NDEBUG
