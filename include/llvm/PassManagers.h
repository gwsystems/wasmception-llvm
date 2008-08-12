//===- llvm/PassManager.h - Pass Inftrastructre classes  --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the LLVM Pass Manager infrastructure. 
//
//===----------------------------------------------------------------------===//

#include "llvm/PassManager.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/DenseMap.h"
#include <deque>
#include <map>

//===----------------------------------------------------------------------===//
// Overview:
// The Pass Manager Infrastructure manages passes. It's responsibilities are:
// 
//   o Manage optimization pass execution order
//   o Make required Analysis information available before pass P is run
//   o Release memory occupied by dead passes
//   o If Analysis information is dirtied by a pass then regenerate Analysis 
//     information before it is consumed by another pass.
//
// Pass Manager Infrastructure uses multiple pass managers.  They are
// PassManager, FunctionPassManager, MPPassManager, FPPassManager, BBPassManager.
// This class hierarchy uses multiple inheritance but pass managers do not
// derive from another pass manager.
//
// PassManager and FunctionPassManager are two top-level pass manager that
// represents the external interface of this entire pass manager infrastucture.
//
// Important classes :
//
// [o] class PMTopLevelManager;
//
// Two top level managers, PassManager and FunctionPassManager, derive from 
// PMTopLevelManager. PMTopLevelManager manages information used by top level 
// managers such as last user info.
//
// [o] class PMDataManager;
//
// PMDataManager manages information, e.g. list of available analysis info, 
// used by a pass manager to manage execution order of passes. It also provides
// a place to implement common pass manager APIs. All pass managers derive from
// PMDataManager.
//
// [o] class BBPassManager : public FunctionPass, public PMDataManager;
//
// BBPassManager manages BasicBlockPasses.
//
// [o] class FunctionPassManager;
//
// This is a external interface used by JIT to manage FunctionPasses. This
// interface relies on FunctionPassManagerImpl to do all the tasks.
//
// [o] class FunctionPassManagerImpl : public ModulePass, PMDataManager,
//                                     public PMTopLevelManager;
//
// FunctionPassManagerImpl is a top level manager. It manages FPPassManagers
//
// [o] class FPPassManager : public ModulePass, public PMDataManager;
//
// FPPassManager manages FunctionPasses and BBPassManagers
//
// [o] class MPPassManager : public Pass, public PMDataManager;
//
// MPPassManager manages ModulePasses and FPPassManagers
//
// [o] class PassManager;
//
// This is a external interface used by various tools to manages passes. It
// relies on PassManagerImpl to do all the tasks.
//
// [o] class PassManagerImpl : public Pass, public PMDataManager,
//                             public PMDTopLevelManager
//
// PassManagerImpl is a top level pass manager responsible for managing
// MPPassManagers.
//===----------------------------------------------------------------------===//

#ifndef PASSMANAGERS_H
#define PASSMANAGERS_H

#include "llvm/Pass.h"
#include <deque>

namespace llvm {

/// FunctionPassManager and PassManager, two top level managers, serve 
/// as the public interface of pass manager infrastructure.
enum TopLevelManagerType {
  TLM_Function,  // FunctionPassManager
  TLM_Pass       // PassManager
};
    
// enums for debugging strings
enum PassDebuggingString {
  EXECUTION_MSG, // "Executing Pass '"
  MODIFICATION_MSG, // "' Made Modification '"
  FREEING_MSG, // " Freeing Pass '"
  ON_BASICBLOCK_MSG, // "'  on BasicBlock '" + PassName + "'...\n"
  ON_FUNCTION_MSG, // "' on Function '" + FunctionName + "'...\n"
  ON_MODULE_MSG, // "' on Module '" + ModuleName + "'...\n"
  ON_LOOP_MSG, // " 'on Loop ...\n'"
  ON_CG_MSG // "' on Call Graph ...\n'"
};  

//===----------------------------------------------------------------------===//
// PMStack
//
/// PMStack
/// Top level pass managers (see PassManager.cpp) maintain active Pass Managers 
/// using PMStack. Each Pass implements assignPassManager() to connect itself
/// with appropriate manager. assignPassManager() walks PMStack to find
/// suitable manager.
///
/// PMStack is just a wrapper around standard deque that overrides pop() and
/// push() methods.
class PMStack {
public:
  typedef std::deque<PMDataManager *>::reverse_iterator iterator;
  iterator begin() { return S.rbegin(); }
  iterator end() { return S.rend(); }

  void handleLastUserOverflow();

  void pop();
  inline PMDataManager *top() { return S.back(); }
  void push(PMDataManager *PM);
  inline bool empty() { return S.empty(); }

  void dump();
private:
  std::deque<PMDataManager *> S;
};


//===----------------------------------------------------------------------===//
// PMTopLevelManager
//
/// PMTopLevelManager manages LastUser info and collects common APIs used by
/// top level pass managers.
class PMTopLevelManager {
public:

  virtual unsigned getNumContainedManagers() const {
    return (unsigned)PassManagers.size();
  }

  /// Schedule pass P for execution. Make sure that passes required by
  /// P are run before P is run. Update analysis info maintained by
  /// the manager. Remove dead passes. This is a recursive function.
  void schedulePass(Pass *P);

  /// This is implemented by top level pass manager and used by 
  /// schedulePass() to add analysis info passes that are not available.
  virtual void addTopLevelPass(Pass  *P) = 0;

  /// Set pass P as the last user of the given analysis passes.
  void setLastUser(SmallVector<Pass *, 12> &AnalysisPasses, Pass *P);

  /// Collect passes whose last user is P
  void collectLastUses(SmallVector<Pass *, 12> &LastUses, Pass *P);

  /// Find the pass that implements Analysis AID. Search immutable
  /// passes and all pass managers. If desired pass is not found
  /// then return NULL.
  Pass *findAnalysisPass(AnalysisID AID);

  /// Find analysis usage information for the pass P.
  AnalysisUsage *findAnalysisUsage(Pass *P);

  explicit PMTopLevelManager(enum TopLevelManagerType t);
  virtual ~PMTopLevelManager(); 

  /// Add immutable pass and initialize it.
  inline void addImmutablePass(ImmutablePass *P) {
    P->initializePass();
    ImmutablePasses.push_back(P);
  }

  inline std::vector<ImmutablePass *>& getImmutablePasses() {
    return ImmutablePasses;
  }

  void addPassManager(PMDataManager *Manager) {
    PassManagers.push_back(Manager);
  }

  // Add Manager into the list of managers that are not directly
  // maintained by this top level pass manager
  inline void addIndirectPassManager(PMDataManager *Manager) {
    IndirectPassManagers.push_back(Manager);
  }

  // Print passes managed by this top level manager.
  void dumpPasses() const;
  void dumpArguments() const;

  void initializeAllAnalysisInfo();

  // Active Pass Managers
  PMStack activeStack;

protected:
  
  /// Collection of pass managers
  std::vector<PMDataManager *> PassManagers;

private:

  /// Collection of pass managers that are not directly maintained
  /// by this pass manager
  std::vector<PMDataManager *> IndirectPassManagers;

  // Map to keep track of last user of the analysis pass.
  // LastUser->second is the last user of Lastuser->first.
  DenseMap<Pass *, Pass *> LastUser;

  // Map to keep track of passes that are last used by a pass.
  // This inverse map is initialized at PM->run() based on
  // LastUser map.
  DenseMap<Pass *, SmallPtrSet<Pass *, 8> > InversedLastUser;

  /// Immutable passes are managed by top level manager.
  std::vector<ImmutablePass *> ImmutablePasses;

  DenseMap<Pass *, AnalysisUsage *> AnUsageMap;
};


  
//===----------------------------------------------------------------------===//
// PMDataManager

/// PMDataManager provides the common place to manage the analysis data
/// used by pass managers.
class PMDataManager {
public:

  explicit PMDataManager(int Depth) : TPM(NULL), Depth(Depth) {
    initializeAnalysisInfo();
  }

  virtual ~PMDataManager();

  /// Augment AvailableAnalysis by adding analysis made available by pass P.
  void recordAvailableAnalysis(Pass *P);

  /// verifyPreservedAnalysis -- Verify analysis presreved by pass P.
  void verifyPreservedAnalysis(Pass *P);

  /// verifyDomInfo -- Verify dominator information if it is available.
  void verifyDomInfo(Pass &P, Function &F);

  /// Remove Analysis that is not preserved by the pass
  void removeNotPreservedAnalysis(Pass *P);
  
  /// Remove dead passes
  void removeDeadPasses(Pass *P, const char *Msg, enum PassDebuggingString);

  /// Add pass P into the PassVector. Update 
  /// AvailableAnalysis appropriately if ProcessAnalysis is true.
  void add(Pass *P, bool ProcessAnalysis = true);

  /// Add RequiredPass into list of lower level passes required by pass P.
  /// RequiredPass is run on the fly by Pass Manager when P requests it
  /// through getAnalysis interface.
  virtual void addLowerLevelRequiredPass(Pass *P, Pass *RequiredPass);

  virtual Pass * getOnTheFlyPass(Pass *P, const PassInfo *PI, Function &F) {
    assert (0 && "Unable to find on the fly pass");
    return NULL;
  }

  /// Initialize available analysis information.
  void initializeAnalysisInfo() { 
    AvailableAnalysis.clear();
    for (unsigned i = 0; i < PMT_Last; ++i)
      InheritedAnalysis[i] = NULL;
  }

  // Return true if P preserves high level analysis used by other
  // passes that are managed by this manager.
  bool preserveHigherLevelAnalysis(Pass *P);


  /// Populate RequiredPasses with analysis pass that are required by
  /// pass P and are available. Populate ReqPassNotAvailable with analysis
  /// pass that are required by pass P but are not available.
  void collectRequiredAnalysis(SmallVector<Pass *, 8> &RequiredPasses,
                               SmallVector<AnalysisID, 8> &ReqPassNotAvailable,
                               Pass *P);

  /// All Required analyses should be available to the pass as it runs!  Here
  /// we fill in the AnalysisImpls member of the pass so that it can
  /// successfully use the getAnalysis() method to retrieve the
  /// implementations it needs.
  void initializeAnalysisImpl(Pass *P);

  /// Find the pass that implements Analysis AID. If desired pass is not found
  /// then return NULL.
  Pass *findAnalysisPass(AnalysisID AID, bool Direction);

  // Access toplevel manager
  PMTopLevelManager *getTopLevelManager() { return TPM; }
  void setTopLevelManager(PMTopLevelManager *T) { TPM = T; }

  unsigned getDepth() const { return Depth; }

  // Print routines used by debug-pass
  void dumpLastUses(Pass *P, unsigned Offset) const;
  void dumpPassArguments() const;
  void dumpPassInfo(Pass *P, enum PassDebuggingString S1,
                    enum PassDebuggingString S2, const char *Msg);
  void dumpRequiredSet(const Pass *P) const;
  void dumpPreservedSet(const Pass *P) const;

  virtual unsigned getNumContainedPasses() const {
    return (unsigned)PassVector.size();
  }

  virtual PassManagerType getPassManagerType() const { 
    assert ( 0 && "Invalid use of getPassManagerType");
    return PMT_Unknown; 
  }

  std::map<AnalysisID, Pass*> *getAvailableAnalysis() {
    return &AvailableAnalysis;
  }

  // Collect AvailableAnalysis from all the active Pass Managers.
  void populateInheritedAnalysis(PMStack &PMS) {
    unsigned Index = 0;
    for (PMStack::iterator I = PMS.begin(), E = PMS.end();
         I != E; ++I)
      InheritedAnalysis[Index++] = (*I)->getAvailableAnalysis();
  }

protected:

  // Top level manager.
  PMTopLevelManager *TPM;

  // Collection of pass that are managed by this manager
  std::vector<Pass *> PassVector;

  // Collection of Analysis provided by Parent pass manager and
  // used by current pass manager. At at time there can not be more
  // then PMT_Last active pass mangers.
  std::map<AnalysisID, Pass *> *InheritedAnalysis[PMT_Last];

private:
  void dumpAnalysisUsage(const char *Msg, const Pass *P,
                           const AnalysisUsage::VectorType &Set) const;

  // Set of available Analysis. This information is used while scheduling 
  // pass. If a pass requires an analysis which is not not available then 
  // equired analysis pass is scheduled to run before the pass itself is 
  // scheduled to run.
  std::map<AnalysisID, Pass*> AvailableAnalysis;

  // Collection of higher level analysis used by the pass managed by
  // this manager.
  std::vector<Pass *> HigherLevelAnalysis;

  unsigned Depth;
};

//===----------------------------------------------------------------------===//
// FPPassManager
//
/// FPPassManager manages BBPassManagers and FunctionPasses.
/// It batches all function passes and basic block pass managers together and 
/// sequence them to process one function at a time before processing next 
/// function.

class FPPassManager : public ModulePass, public PMDataManager {
 
public:
  static char ID;
  explicit FPPassManager(int Depth) 
  : ModulePass(intptr_t(&ID)), PMDataManager(Depth) { }
  
  /// run - Execute all of the passes scheduled for execution.  Keep track of
  /// whether any of the passes modifies the module, and if so, return true.
  bool runOnFunction(Function &F);
  bool runOnModule(Module &M);

  /// doInitialization - Run all of the initializers for the function passes.
  ///
  bool doInitialization(Module &M);
  
  /// doFinalization - Run all of the finalizers for the function passes.
  ///
  bool doFinalization(Module &M);

  /// Pass Manager itself does not invalidate any analysis info.
  void getAnalysisUsage(AnalysisUsage &Info) const {
    Info.setPreservesAll();
  }

  // Print passes managed by this manager
  void dumpPassStructure(unsigned Offset);

  virtual const char *getPassName() const {
    return "Function Pass Manager";
  }

  FunctionPass *getContainedPass(unsigned N) {
    assert ( N < PassVector.size() && "Pass number out of range!");
    FunctionPass *FP = static_cast<FunctionPass *>(PassVector[N]);
    return FP;
  }

  virtual PassManagerType getPassManagerType() const { 
    return PMT_FunctionPassManager; 
  }
};

}

extern void StartPassTimer(llvm::Pass *);
extern void StopPassTimer(llvm::Pass *);

#endif

