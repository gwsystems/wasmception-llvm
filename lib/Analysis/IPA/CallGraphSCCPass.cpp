//===- CallGraphSCCPass.cpp - Pass that operates BU on call graph ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the CallGraphSCCPass class, which is used for passes
// which are implemented as bottom-up traversals on the call graph.  Because
// there may be cycles in the call graph, passes of this type operate on the
// call-graph in SCC order: that is, they process function bottom-up, except for
// recursive functions, which they process all at once.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "cgscc-passmgr"
#include "llvm/CallGraphSCCPass.h"
#include "llvm/IntrinsicInst.h"
#include "llvm/Function.h"
#include "llvm/PassManagers.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Timer.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

//===----------------------------------------------------------------------===//
// CGPassManager
//
/// CGPassManager manages FPPassManagers and CallGraphSCCPasses.

namespace {

class CGPassManager : public ModulePass, public PMDataManager {
public:
  static char ID;
  explicit CGPassManager(int Depth) 
    : ModulePass(&ID), PMDataManager(Depth) { }

  /// run - Execute all of the passes scheduled for execution.  Keep track of
  /// whether any of the passes modifies the module, and if so, return true.
  bool runOnModule(Module &M);

  bool doInitialization(CallGraph &CG);
  bool doFinalization(CallGraph &CG);

  /// Pass Manager itself does not invalidate any analysis info.
  void getAnalysisUsage(AnalysisUsage &Info) const {
    // CGPassManager walks SCC and it needs CallGraph.
    Info.addRequired<CallGraph>();
    Info.setPreservesAll();
  }

  virtual const char *getPassName() const {
    return "CallGraph Pass Manager";
  }

  virtual PMDataManager *getAsPMDataManager() { return this; }
  virtual Pass *getAsPass() { return this; }

  // Print passes managed by this manager
  void dumpPassStructure(unsigned Offset) {
    errs().indent(Offset*2) << "Call Graph SCC Pass Manager\n";
    for (unsigned Index = 0; Index < getNumContainedPasses(); ++Index) {
      Pass *P = getContainedPass(Index);
      P->dumpPassStructure(Offset + 1);
      dumpLastUses(P, Offset+1);
    }
  }

  Pass *getContainedPass(unsigned N) {
    assert(N < PassVector.size() && "Pass number out of range!");
    return static_cast<Pass *>(PassVector[N]);
  }

  virtual PassManagerType getPassManagerType() const { 
    return PMT_CallGraphPassManager; 
  }
  
private:
  bool RunPassOnSCC(Pass *P, CallGraphSCC &CurSCC,
                    CallGraph &CG, bool &CallGraphUpToDate);
  void RefreshCallGraph(CallGraphSCC &CurSCC, CallGraph &CG,
                        bool IsCheckingMode);
};

} // end anonymous namespace.

char CGPassManager::ID = 0;


bool CGPassManager::RunPassOnSCC(Pass *P, CallGraphSCC &CurSCC,
                                 CallGraph &CG, bool &CallGraphUpToDate) {
  bool Changed = false;
  PMDataManager *PM = P->getAsPMDataManager();

  if (PM == 0) {
    CallGraphSCCPass *CGSP = (CallGraphSCCPass*)P;
    if (!CallGraphUpToDate) {
      RefreshCallGraph(CurSCC, CG, false);
      CallGraphUpToDate = true;
    }

    {
      TimeRegion PassTimer(getPassTimer(CGSP));
      Changed = CGSP->runOnSCC(CurSCC);
    }
    
    // After the CGSCCPass is done, when assertions are enabled, use
    // RefreshCallGraph to verify that the callgraph was correctly updated.
#ifndef NDEBUG
    if (Changed)
      RefreshCallGraph(CurSCC, CG, true);
#endif
    
    return Changed;
  }
  
  
  assert(PM->getPassManagerType() == PMT_FunctionPassManager &&
         "Invalid CGPassManager member");
  FPPassManager *FPP = (FPPassManager*)P;
  
  // Run pass P on all functions in the current SCC.
  for (CallGraphSCC::iterator I = CurSCC.begin(), E = CurSCC.end();
       I != E; ++I) {
    if (Function *F = (*I)->getFunction()) {
      dumpPassInfo(P, EXECUTION_MSG, ON_FUNCTION_MSG, F->getName());
      TimeRegion PassTimer(getPassTimer(FPP));
      Changed |= FPP->runOnFunction(*F);
    }
  }
  
  // The function pass(es) modified the IR, they may have clobbered the
  // callgraph.
  if (Changed && CallGraphUpToDate) {
    DEBUG(dbgs() << "CGSCCPASSMGR: Pass Dirtied SCC: "
                 << P->getPassName() << '\n');
    CallGraphUpToDate = false;
  }
  return Changed;
}


/// RefreshCallGraph - Scan the functions in the specified CFG and resync the
/// callgraph with the call sites found in it.  This is used after
/// FunctionPasses have potentially munged the callgraph, and can be used after
/// CallGraphSCC passes to verify that they correctly updated the callgraph.
///
void CGPassManager::RefreshCallGraph(CallGraphSCC &CurSCC,
                                     CallGraph &CG, bool CheckingMode) {
  DenseMap<Value*, CallGraphNode*> CallSites;
  
  DEBUG(dbgs() << "CGSCCPASSMGR: Refreshing SCC with " << CurSCC.size()
               << " nodes:\n";
        for (CallGraphSCC::iterator I = CurSCC.begin(), E = CurSCC.end();
             I != E; ++I)
          (*I)->dump();
        );

  bool MadeChange = false;
  
  // Scan all functions in the SCC.
  unsigned FunctionNo = 0;
  for (CallGraphSCC::iterator SCCIdx = CurSCC.begin(), E = CurSCC.end();
       SCCIdx != E; ++SCCIdx, ++FunctionNo) {
    CallGraphNode *CGN = *SCCIdx;
    Function *F = CGN->getFunction();
    if (F == 0 || F->isDeclaration()) continue;
    
    // Walk the function body looking for call sites.  Sync up the call sites in
    // CGN with those actually in the function.
    
    // Get the set of call sites currently in the function.
    for (CallGraphNode::iterator I = CGN->begin(), E = CGN->end(); I != E; ) {
      // If this call site is null, then the function pass deleted the call
      // entirely and the WeakVH nulled it out.  
      if (I->first == 0 ||
          // If we've already seen this call site, then the FunctionPass RAUW'd
          // one call with another, which resulted in two "uses" in the edge
          // list of the same call.
          CallSites.count(I->first) ||

          // If the call edge is not from a call or invoke, then the function
          // pass RAUW'd a call with another value.  This can happen when
          // constant folding happens of well known functions etc.
          CallSite::get(I->first).getInstruction() == 0) {
        assert(!CheckingMode &&
               "CallGraphSCCPass did not update the CallGraph correctly!");
        
        // Just remove the edge from the set of callees, keep track of whether
        // I points to the last element of the vector.
        bool WasLast = I + 1 == E;
        CGN->removeCallEdge(I);
        
        // If I pointed to the last element of the vector, we have to bail out:
        // iterator checking rejects comparisons of the resultant pointer with
        // end.
        if (WasLast)
          break;
        E = CGN->end();
        continue;
      }
      
      assert(!CallSites.count(I->first) &&
             "Call site occurs in node multiple times");
      CallSites.insert(std::make_pair(I->first, I->second));
      ++I;
    }
    
    // Loop over all of the instructions in the function, getting the callsites.
    for (Function::iterator BB = F->begin(), E = F->end(); BB != E; ++BB)
      for (BasicBlock::iterator I = BB->begin(), E = BB->end(); I != E; ++I) {
        CallSite CS = CallSite::get(I);
        if (!CS.getInstruction() || isa<DbgInfoIntrinsic>(I)) continue;
        
        // If this call site already existed in the callgraph, just verify it
        // matches up to expectations and remove it from CallSites.
        DenseMap<Value*, CallGraphNode*>::iterator ExistingIt =
          CallSites.find(CS.getInstruction());
        if (ExistingIt != CallSites.end()) {
          CallGraphNode *ExistingNode = ExistingIt->second;

          // Remove from CallSites since we have now seen it.
          CallSites.erase(ExistingIt);
          
          // Verify that the callee is right.
          if (ExistingNode->getFunction() == CS.getCalledFunction())
            continue;
          
          // If we are in checking mode, we are not allowed to actually mutate
          // the callgraph.  If this is a case where we can infer that the
          // callgraph is less precise than it could be (e.g. an indirect call
          // site could be turned direct), don't reject it in checking mode, and
          // don't tweak it to be more precise.
          if (CheckingMode && CS.getCalledFunction() &&
              ExistingNode->getFunction() == 0)
            continue;
          
          assert(!CheckingMode &&
                 "CallGraphSCCPass did not update the CallGraph correctly!");
          
          // If not, we either went from a direct call to indirect, indirect to
          // direct, or direct to different direct.
          CallGraphNode *CalleeNode;
          if (Function *Callee = CS.getCalledFunction())
            CalleeNode = CG.getOrInsertFunction(Callee);
          else
            CalleeNode = CG.getCallsExternalNode();

          // Update the edge target in CGN.
          for (CallGraphNode::iterator I = CGN->begin(); ; ++I) {
            assert(I != CGN->end() && "Didn't find call entry");
            if (I->first == CS.getInstruction()) {
              I->second = CalleeNode;
              break;
            }
          }
          MadeChange = true;
          continue;
        }
        
        assert(!CheckingMode &&
               "CallGraphSCCPass did not update the CallGraph correctly!");

        // If the call site didn't exist in the CGN yet, add it.  We assume that
        // newly introduced call sites won't be indirect.  This could be fixed
        // in the future.
        CallGraphNode *CalleeNode;
        if (Function *Callee = CS.getCalledFunction())
          CalleeNode = CG.getOrInsertFunction(Callee);
        else
          CalleeNode = CG.getCallsExternalNode();
        
        CGN->addCalledFunction(CS, CalleeNode);
        MadeChange = true;
      }
    
    // After scanning this function, if we still have entries in callsites, then
    // they are dangling pointers.  WeakVH should save us for this, so abort if
    // this happens.
    assert(CallSites.empty() && "Dangling pointers found in call sites map");
    
    // Periodically do an explicit clear to remove tombstones when processing
    // large scc's.
    if ((FunctionNo & 15) == 15)
      CallSites.clear();
  }

  DEBUG(if (MadeChange) {
          dbgs() << "CGSCCPASSMGR: Refreshed SCC is now:\n";
          for (CallGraphSCC::iterator I = CurSCC.begin(), E = CurSCC.end();
            I != E; ++I)
              (*I)->dump();
         } else {
           dbgs() << "CGSCCPASSMGR: SCC Refresh didn't change call graph.\n";
         }
        );
}

/// run - Execute all of the passes scheduled for execution.  Keep track of
/// whether any of the passes modifies the module, and if so, return true.
bool CGPassManager::runOnModule(Module &M) {
  CallGraph &CG = getAnalysis<CallGraph>();
  bool Changed = doInitialization(CG);

  // Walk the callgraph in bottom-up SCC order.
  scc_iterator<CallGraph*> CGI = scc_begin(&CG);

  CallGraphSCC CurSCC(&CGI);
  while (!CGI.isAtEnd()) {
    // Copy the current SCC and increment past it so that the pass can hack
    // on the SCC if it wants to without invalidating our iterator.
    std::vector<CallGraphNode*> &NodeVec = *CGI;
    CurSCC.initialize(&NodeVec[0], &NodeVec[0]+NodeVec.size());
    ++CGI;
    
    // CallGraphUpToDate - Keep track of whether the callgraph is known to be
    // up-to-date or not.  The CGSSC pass manager runs two types of passes:
    // CallGraphSCC Passes and other random function passes.  Because other
    // random function passes are not CallGraph aware, they may clobber the
    // call graph by introducing new calls or deleting other ones.  This flag
    // is set to false when we run a function pass so that we know to clean up
    // the callgraph when we need to run a CGSCCPass again.
    bool CallGraphUpToDate = true;
    
    // Run all passes on current SCC.
    for (unsigned PassNo = 0, e = getNumContainedPasses();
         PassNo != e; ++PassNo) {
      Pass *P = getContainedPass(PassNo);

      // If we're in -debug-pass=Executions mode, construct the SCC node list,
      // otherwise avoid constructing this string as it is expensive.
      if (isPassDebuggingExecutionsOrMore()) {
        std::string Functions;
#ifndef NDEBUG
        raw_string_ostream OS(Functions);
        for (CallGraphSCC::iterator I = CurSCC.begin(), E = CurSCC.end();
             I != E; ++I) {
          if (I != CurSCC.begin()) OS << ", ";
          (*I)->print(OS);
        }
        OS.flush();
#endif
        dumpPassInfo(P, EXECUTION_MSG, ON_CG_MSG, Functions);
      }
      dumpRequiredSet(P);

      initializeAnalysisImpl(P);

      // Actually run this pass on the current SCC.
      Changed |= RunPassOnSCC(P, CurSCC, CG, CallGraphUpToDate);

      if (Changed)
        dumpPassInfo(P, MODIFICATION_MSG, ON_CG_MSG, "");
      dumpPreservedSet(P);

      verifyPreservedAnalysis(P);      
      removeNotPreservedAnalysis(P);
      recordAvailableAnalysis(P);
      removeDeadPasses(P, "", ON_CG_MSG);
    }
    
    // If the callgraph was left out of date (because the last pass run was a
    // functionpass), refresh it before we move on to the next SCC.
    if (!CallGraphUpToDate)
      RefreshCallGraph(CurSCC, CG, false);
  }
  Changed |= doFinalization(CG);
  return Changed;
}

/// Initialize CG
bool CGPassManager::doInitialization(CallGraph &CG) {
  bool Changed = false;
  for (unsigned i = 0, e = getNumContainedPasses(); i != e; ++i) {  
    if (PMDataManager *PM = getContainedPass(i)->getAsPMDataManager()) {
      assert(PM->getPassManagerType() == PMT_FunctionPassManager &&
             "Invalid CGPassManager member");
      Changed |= ((FPPassManager*)PM)->doInitialization(CG.getModule());
    } else {
      Changed |= ((CallGraphSCCPass*)getContainedPass(i))->doInitialization(CG);
    }
  }
  return Changed;
}

/// Finalize CG
bool CGPassManager::doFinalization(CallGraph &CG) {
  bool Changed = false;
  for (unsigned i = 0, e = getNumContainedPasses(); i != e; ++i) {  
    if (PMDataManager *PM = getContainedPass(i)->getAsPMDataManager()) {
      assert(PM->getPassManagerType() == PMT_FunctionPassManager &&
             "Invalid CGPassManager member");
      Changed |= ((FPPassManager*)PM)->doFinalization(CG.getModule());
    } else {
      Changed |= ((CallGraphSCCPass*)getContainedPass(i))->doFinalization(CG);
    }
  }
  return Changed;
}

//===----------------------------------------------------------------------===//
// CallGraphSCC Implementation
//===----------------------------------------------------------------------===//

/// ReplaceNode - This informs the SCC and the pass manager that the specified
/// Old node has been deleted, and New is to be used in its place.
void CallGraphSCC::ReplaceNode(CallGraphNode *Old, CallGraphNode *New) {
  assert(Old != New && "Should not replace node with self");
  for (unsigned i = 0; ; ++i) {
    assert(i != Nodes.size() && "Node not in SCC");
    if (Nodes[i] != Old) continue;
    Nodes[i] = New;
    break;
  }
}


//===----------------------------------------------------------------------===//
// CallGraphSCCPass Implementation
//===----------------------------------------------------------------------===//

/// Assign pass manager to manage this pass.
void CallGraphSCCPass::assignPassManager(PMStack &PMS,
                                         PassManagerType PreferredType) {
  // Find CGPassManager 
  while (!PMS.empty() &&
         PMS.top()->getPassManagerType() > PMT_CallGraphPassManager)
    PMS.pop();

  assert(!PMS.empty() && "Unable to handle Call Graph Pass");
  CGPassManager *CGP;
  
  if (PMS.top()->getPassManagerType() == PMT_CallGraphPassManager)
    CGP = (CGPassManager*)PMS.top();
  else {
    // Create new Call Graph SCC Pass Manager if it does not exist. 
    assert(!PMS.empty() && "Unable to create Call Graph Pass Manager");
    PMDataManager *PMD = PMS.top();

    // [1] Create new Call Graph Pass Manager
    CGP = new CGPassManager(PMD->getDepth() + 1);

    // [2] Set up new manager's top level manager
    PMTopLevelManager *TPM = PMD->getTopLevelManager();
    TPM->addIndirectPassManager(CGP);

    // [3] Assign manager to manage this new manager. This may create
    // and push new managers into PMS
    Pass *P = CGP;
    TPM->schedulePass(P);

    // [4] Push new manager into PMS
    PMS.push(CGP);
  }

  CGP->add(this);
}

/// getAnalysisUsage - For this class, we declare that we require and preserve
/// the call graph.  If the derived class implements this method, it should
/// always explicitly call the implementation here.
void CallGraphSCCPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<CallGraph>();
  AU.addPreserved<CallGraph>();
}


//===----------------------------------------------------------------------===//
// PrintCallGraphPass Implementation
//===----------------------------------------------------------------------===//

namespace {
  /// PrintCallGraphPass - Print a Module corresponding to a call graph.
  ///
  class PrintCallGraphPass : public CallGraphSCCPass {
    std::string Banner;
    raw_ostream &Out;       // raw_ostream to print on.
    
  public:
    static char ID;
    PrintCallGraphPass() : CallGraphSCCPass(&ID), Out(dbgs()) {}
    PrintCallGraphPass(const std::string &B, raw_ostream &o)
      : CallGraphSCCPass(&ID), Banner(B), Out(o) {}
    
    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AU.setPreservesAll();
    }
    
    bool runOnSCC(CallGraphSCC &SCC) {
      Out << Banner;
      for (CallGraphSCC::iterator I = SCC.begin(), E = SCC.end(); I != E; ++I)
        (*I)->getFunction()->print(Out);
      return false;
    }
  };
  
} // end anonymous namespace.

char PrintCallGraphPass::ID = 0;

Pass *CallGraphSCCPass::createPrinterPass(raw_ostream &O,
                                          const std::string &Banner) const {
  return new PrintCallGraphPass(Banner, O);
}

