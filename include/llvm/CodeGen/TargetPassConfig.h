//===-- TargetPassConfig.h - Code Generation pass options -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// Target-Independent Code Generator Pass Configuration Options pass.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_TARGETPASSCONFIG_H
#define LLVM_CODEGEN_TARGETPASSCONFIG_H

#include "llvm/Pass.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/CommandLine.h"
#include <string>

extern llvm::cl::opt<bool> UseIPRA;

namespace llvm {

class PassConfigImpl;
class ScheduleDAGInstrs;
class TargetMachine;
struct MachineSchedContext;

// The old pass manager infrastructure is hidden in a legacy namespace now.
namespace legacy {
class PassManagerBase;
}
using legacy::PassManagerBase;

/// Discriminated union of Pass ID types.
///
/// The PassConfig API prefers dealing with IDs because they are safer and more
/// efficient. IDs decouple configuration from instantiation. This way, when a
/// pass is overriden, it isn't unnecessarily instantiated. It is also unsafe to
/// refer to a Pass pointer after adding it to a pass manager, which deletes
/// redundant pass instances.
///
/// However, it is convient to directly instantiate target passes with
/// non-default ctors. These often don't have a registered PassInfo. Rather than
/// force all target passes to implement the pass registry boilerplate, allow
/// the PassConfig API to handle either type.
///
/// AnalysisID is sadly char*, so PointerIntPair won't work.
class IdentifyingPassPtr {
  union {
    AnalysisID ID;
    Pass *P;
  };
  bool IsInstance;
public:
  IdentifyingPassPtr() : P(nullptr), IsInstance(false) {}
  IdentifyingPassPtr(AnalysisID IDPtr) : ID(IDPtr), IsInstance(false) {}
  IdentifyingPassPtr(Pass *InstancePtr) : P(InstancePtr), IsInstance(true) {}

  bool isValid() const { return P; }
  bool isInstance() const { return IsInstance; }

  AnalysisID getID() const {
    assert(!IsInstance && "Not a Pass ID");
    return ID;
  }
  Pass *getInstance() const {
    assert(IsInstance && "Not a Pass Instance");
    return P;
  }
};

template <> struct isPodLike<IdentifyingPassPtr> {
  static const bool value = true;
};

/// Target-Independent Code Generator Pass Configuration Options.
///
/// This is an ImmutablePass solely for the purpose of exposing CodeGen options
/// to the internals of other CodeGen passes.
class TargetPassConfig : public ImmutablePass {
public:
  /// Pseudo Pass IDs. These are defined within TargetPassConfig because they
  /// are unregistered pass IDs. They are only useful for use with
  /// TargetPassConfig APIs to identify multiple occurrences of the same pass.
  ///

  /// EarlyTailDuplicate - A clone of the TailDuplicate pass that runs early
  /// during codegen, on SSA form.
  static char EarlyTailDuplicateID;

  /// PostRAMachineLICM - A clone of the LICM pass that runs during late machine
  /// optimization after regalloc.
  static char PostRAMachineLICMID;

private:
  PassManagerBase *PM;
  AnalysisID StartBefore, StartAfter;
  AnalysisID StopAfter;
  bool Started;
  bool Stopped;
  bool AddingMachinePasses;

protected:
  TargetMachine *TM;
  PassConfigImpl *Impl; // Internal data structures
  bool Initialized;     // Flagged after all passes are configured.

  // Target Pass Options
  // Targets provide a default setting, user flags override.
  //
  bool DisableVerify;

  /// Default setting for -enable-tail-merge on this target.
  bool EnableTailMerge;

public:
  TargetPassConfig(TargetMachine *tm, PassManagerBase &pm);
  // Dummy constructor.
  TargetPassConfig();

  ~TargetPassConfig() override;

  static char ID;

  /// Get the right type of TargetMachine for this target.
  template<typename TMC> TMC &getTM() const {
    return *static_cast<TMC*>(TM);
  }

  //
  void setInitialized() { Initialized = true; }

  CodeGenOpt::Level getOptLevel() const;

  /// Set the StartAfter, StartBefore and StopAfter passes to allow running only
  /// a portion of the normal code-gen pass sequence.
  ///
  /// If the StartAfter and StartBefore pass ID is zero, then compilation will
  /// begin at the normal point; otherwise, clear the Started flag to indicate
  /// that passes should not be added until the starting pass is seen.  If the
  /// Stop pass ID is zero, then compilation will continue to the end.
  ///
  /// This function expects that at least one of the StartAfter or the
  /// StartBefore pass IDs is null.
  void setStartStopPasses(AnalysisID StartBefore, AnalysisID StartAfter,
                          AnalysisID StopAfter) {
    if (StartAfter)
      assert(!StartBefore && "Start after and start before passes are given");
    this->StartBefore = StartBefore;
    this->StartAfter = StartAfter;
    this->StopAfter = StopAfter;
    Started = (StartAfter == nullptr) && (StartBefore == nullptr);
  }

  void setDisableVerify(bool Disable) { setOpt(DisableVerify, Disable); }

  bool getEnableTailMerge() const { return EnableTailMerge; }
  void setEnableTailMerge(bool Enable) { setOpt(EnableTailMerge, Enable); }

  /// Allow the target to override a specific pass without overriding the pass
  /// pipeline. When passes are added to the standard pipeline at the
  /// point where StandardID is expected, add TargetID in its place.
  void substitutePass(AnalysisID StandardID, IdentifyingPassPtr TargetID);

  /// Insert InsertedPassID pass after TargetPassID pass.
  void insertPass(AnalysisID TargetPassID, IdentifyingPassPtr InsertedPassID,
                  bool VerifyAfter = true, bool PrintAfter = true);

  /// Allow the target to enable a specific standard pass by default.
  void enablePass(AnalysisID PassID) { substitutePass(PassID, PassID); }

  /// Allow the target to disable a specific standard pass by default.
  void disablePass(AnalysisID PassID) {
    substitutePass(PassID, IdentifyingPassPtr());
  }

  /// Return the pass substituted for StandardID by the target.
  /// If no substitution exists, return StandardID.
  IdentifyingPassPtr getPassSubstitution(AnalysisID StandardID) const;

  /// Return true if the pass has been substituted by the target or
  /// overridden on the command line.
  bool isPassSubstitutedOrOverridden(AnalysisID ID) const;

  /// Return true if the optimized regalloc pipeline is enabled.
  bool getOptimizeRegAlloc() const;

  /// Return true if shrink wrapping is enabled.
  bool getEnableShrinkWrap() const;

  /// Return true if the default global register allocator is in use and
  /// has not be overriden on the command line with '-regalloc=...'
  bool usingDefaultRegAlloc() const;

  /// Add common target configurable passes that perform LLVM IR to IR
  /// transforms following machine independent optimization.
  virtual void addIRPasses();

  /// Add passes to lower exception handling for the code generator.
  void addPassesToHandleExceptions();

  /// Add pass to prepare the LLVM IR for code generation. This should be done
  /// before exception handling preparation passes.
  virtual void addCodeGenPrepare();

  /// Add common passes that perform LLVM IR to IR transforms in preparation for
  /// instruction selection.
  virtual void addISelPrepare();

  /// addInstSelector - This method should install an instruction selector pass,
  /// which converts from LLVM code to machine instructions.
  virtual bool addInstSelector() {
    return true;
  }

  /// This method should install an IR translator pass, which converts from
  /// LLVM code to machine instructions with possibly generic opcodes.
  virtual bool addIRTranslator() { return true; }

  /// This method may be implemented by targets that want to run passes
  /// immediately before the register bank selection.
  virtual void addPreRegBankSelect() {}

  /// This method should install a register bank selector pass, which
  /// assigns register banks to virtual registers without a register
  /// class or register banks.
  virtual bool addRegBankSelect() { return true; }

  /// Add the complete, standard set of LLVM CodeGen passes.
  /// Fully developed targets will not generally override this.
  virtual void addMachinePasses();

  /// Create an instance of ScheduleDAGInstrs to be run within the standard
  /// MachineScheduler pass for this function and target at the current
  /// optimization level.
  ///
  /// This can also be used to plug a new MachineSchedStrategy into an instance
  /// of the standard ScheduleDAGMI:
  ///   return new ScheduleDAGMI(C, make_unique<MyStrategy>(C), /*RemoveKillFlags=*/false)
  ///
  /// Return NULL to select the default (generic) machine scheduler.
  virtual ScheduleDAGInstrs *
  createMachineScheduler(MachineSchedContext *C) const {
    return nullptr;
  }

  /// Similar to createMachineScheduler but used when postRA machine scheduling
  /// is enabled.
  virtual ScheduleDAGInstrs *
  createPostMachineScheduler(MachineSchedContext *C) const {
    return nullptr;
  }

  /// printAndVerify - Add a pass to dump then verify the machine function, if
  /// those steps are enabled.
  ///
  void printAndVerify(const std::string &Banner);

  /// Add a pass to print the machine function if printing is enabled.
  void addPrintPass(const std::string &Banner);

  /// Add a pass to perform basic verification of the machine function if
  /// verification is enabled.
  void addVerifyPass(const std::string &Banner);

protected:
  // Helper to verify the analysis is really immutable.
  void setOpt(bool &Opt, bool Val);

  /// Methods with trivial inline returns are convenient points in the common
  /// codegen pass pipeline where targets may insert passes. Methods with
  /// out-of-line standard implementations are major CodeGen stages called by
  /// addMachinePasses. Some targets may override major stages when inserting
  /// passes is insufficient, but maintaining overriden stages is more work.
  ///

  /// addPreISelPasses - This method should add any "last minute" LLVM->LLVM
  /// passes (which are run just before instruction selector).
  virtual bool addPreISel() {
    return true;
  }

  /// addMachineSSAOptimization - Add standard passes that optimize machine
  /// instructions in SSA form.
  virtual void addMachineSSAOptimization();

  /// Add passes that optimize instruction level parallelism for out-of-order
  /// targets. These passes are run while the machine code is still in SSA
  /// form, so they can use MachineTraceMetrics to control their heuristics.
  ///
  /// All passes added here should preserve the MachineDominatorTree,
  /// MachineLoopInfo, and MachineTraceMetrics analyses.
  virtual bool addILPOpts() {
    return false;
  }

  /// This method may be implemented by targets that want to run passes
  /// immediately before register allocation.
  virtual void addPreRegAlloc() { }

  /// createTargetRegisterAllocator - Create the register allocator pass for
  /// this target at the current optimization level.
  virtual FunctionPass *createTargetRegisterAllocator(bool Optimized);

  /// addFastRegAlloc - Add the minimum set of target-independent passes that
  /// are required for fast register allocation.
  virtual void addFastRegAlloc(FunctionPass *RegAllocPass);

  /// addOptimizedRegAlloc - Add passes related to register allocation.
  /// LLVMTargetMachine provides standard regalloc passes for most targets.
  virtual void addOptimizedRegAlloc(FunctionPass *RegAllocPass);

  /// addPreRewrite - Add passes to the optimized register allocation pipeline
  /// after register allocation is complete, but before virtual registers are
  /// rewritten to physical registers.
  ///
  /// These passes must preserve VirtRegMap and LiveIntervals, and when running
  /// after RABasic or RAGreedy, they should take advantage of LiveRegMatrix.
  /// When these passes run, VirtRegMap contains legal physreg assignments for
  /// all virtual registers.
  virtual bool addPreRewrite() {
    return false;
  }

  /// This method may be implemented by targets that want to run passes after
  /// register allocation pass pipeline but before prolog-epilog insertion.
  virtual void addPostRegAlloc() { }

  /// Add passes that optimize machine instructions after register allocation.
  virtual void addMachineLateOptimization();

  /// This method may be implemented by targets that want to run passes after
  /// prolog-epilog insertion and before the second instruction scheduling pass.
  virtual void addPreSched2() { }

  /// addGCPasses - Add late codegen passes that analyze code for garbage
  /// collection. This should return true if GC info should be printed after
  /// these passes.
  virtual bool addGCPasses();

  /// Add standard basic block placement passes.
  virtual void addBlockPlacement();

  /// This pass may be implemented by targets that want to run passes
  /// immediately before machine code is emitted.
  virtual void addPreEmitPass() { }

  /// Utilities for targets to add passes to the pass manager.
  ///

  /// Add a CodeGen pass at this point in the pipeline after checking overrides.
  /// Return the pass that was added, or zero if no pass was added.
  /// @p printAfter    if true and adding a machine function pass add an extra
  ///                  machine printer pass afterwards
  /// @p verifyAfter   if true and adding a machine function pass add an extra
  ///                  machine verification pass afterwards.
  AnalysisID addPass(AnalysisID PassID, bool verifyAfter = true,
                     bool printAfter = true);

  /// Add a pass to the PassManager if that pass is supposed to be run, as
  /// determined by the StartAfter and StopAfter options. Takes ownership of the
  /// pass.
  /// @p printAfter    if true and adding a machine function pass add an extra
  ///                  machine printer pass afterwards
  /// @p verifyAfter   if true and adding a machine function pass add an extra
  ///                  machine verification pass afterwards.
  void addPass(Pass *P, bool verifyAfter = true, bool printAfter = true);

  /// addMachinePasses helper to create the target-selected or overriden
  /// regalloc pass.
  FunctionPass *createRegAllocPass(bool Optimized);
};

} // end namespace llvm

#endif
