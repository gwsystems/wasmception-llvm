//===- Steensgaard.cpp - Context Insensitive Alias Analysis ---------------===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This pass uses the data structure graphs to implement a simple context
// insensitive alias analysis.  It does this by computing the local analysis
// graphs for all of the functions, then merging them together into a single big
// graph without cloning.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/DataStructure/DataStructure.h"
#include "llvm/Analysis/DataStructure/DSGraph.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Module.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

namespace {
  class Steens : public ModulePass, public AliasAnalysis {
    DSGraph *ResultGraph;
    DSGraph *GlobalsGraph;  // FIXME: Eliminate globals graph stuff from DNE

    EquivalenceClasses<GlobalValue*> GlobalECs;  // Always empty
  public:
    Steens() : ResultGraph(0), GlobalsGraph(0) {}
    ~Steens() {
      releaseMyMemory();
      assert(ResultGraph == 0 && "releaseMemory not called?");
    }

    //------------------------------------------------
    // Implement the Pass API
    //

    // run - Build up the result graph, representing the pointer graph for the
    // program.
    //
    bool runOnModule(Module &M);

    virtual void releaseMyMemory() { delete ResultGraph; ResultGraph = 0; }

    virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      AliasAnalysis::getAnalysisUsage(AU);
      AU.setPreservesAll();                    // Does not transform code...
      AU.addRequired<LocalDataStructures>();   // Uses local dsgraph
    }

    // print - Implement the Pass::print method...
    void print(std::ostream &O, const Module *M) const {
      assert(ResultGraph && "Result graph has not yet been computed!");
      ResultGraph->writeGraphToFile(O, "steensgaards");
    }

    //------------------------------------------------
    // Implement the AliasAnalysis API
    //  

    // alias - This is the only method here that does anything interesting...
    AliasResult alias(const Value *V1, unsigned V1Size,
                      const Value *V2, unsigned V2Size);
    
  private:
    void ResolveFunctionCall(Function *F, const DSCallSite &Call,
                             DSNodeHandle &RetVal);
  };

  // Register the pass...
  RegisterOpt<Steens> X("steens-aa",
                        "Steensgaard's alias analysis (DSGraph based)");

  // Register as an implementation of AliasAnalysis
  RegisterAnalysisGroup<AliasAnalysis, Steens> Y;
}

ModulePass *llvm::createSteensgaardPass() { return new Steens(); }

/// ResolveFunctionCall - Resolve the actual arguments of a call to function F
/// with the specified call site descriptor.  This function links the arguments
/// and the return value for the call site context-insensitively.
///
void Steens::ResolveFunctionCall(Function *F, const DSCallSite &Call,
                                 DSNodeHandle &RetVal) {
  assert(ResultGraph != 0 && "Result graph not allocated!");
  DSGraph::ScalarMapTy &ValMap = ResultGraph->getScalarMap();

  // Handle the return value of the function...
  if (Call.getRetVal().getNode() && RetVal.getNode())
    RetVal.mergeWith(Call.getRetVal());

  // Loop over all pointer arguments, resolving them to their provided pointers
  unsigned PtrArgIdx = 0;
  for (Function::arg_iterator AI = F->arg_begin(), AE = F->arg_end();
       AI != AE && PtrArgIdx < Call.getNumPtrArgs(); ++AI) {
    DSGraph::ScalarMapTy::iterator I = ValMap.find(AI);
    if (I != ValMap.end())    // If its a pointer argument...
      I->second.mergeWith(Call.getPtrArg(PtrArgIdx++));
  }
}


/// run - Build up the result graph, representing the pointer graph for the
/// program.
///
bool Steens::runOnModule(Module &M) {
  InitializeAliasAnalysis(this);
  assert(ResultGraph == 0 && "Result graph already allocated!");
  LocalDataStructures &LDS = getAnalysis<LocalDataStructures>();

  // Create a new, empty, graph...
  ResultGraph = new DSGraph(GlobalECs, getTargetData());
  GlobalsGraph = new DSGraph(GlobalECs, getTargetData());
  ResultGraph->setGlobalsGraph(GlobalsGraph);
  ResultGraph->setPrintAuxCalls();

  // RetValMap - Keep track of the return values for all functions that return
  // valid pointers.
  //
  DSGraph::ReturnNodesTy RetValMap;

  // Loop over the rest of the module, merging graphs for non-external functions
  // into this graph.
  //
  for (Module::iterator I = M.begin(), E = M.end(); I != E; ++I)
    if (!I->isExternal()) {
      DSGraph::NodeMapTy NodeMap;
      ResultGraph->cloneInto(LDS.getDSGraph(*I), RetValMap, NodeMap, 0);
    }

  ResultGraph->removeTriviallyDeadNodes();

  // FIXME: Must recalculate and use the Incomplete markers!!

  // Now that we have all of the graphs inlined, we can go about eliminating
  // call nodes...
  //
  std::list<DSCallSite> &Calls = ResultGraph->getAuxFunctionCalls();
  assert(Calls.empty() && "Aux call list is already in use??");

  // Start with a copy of the original call sites.
  Calls = ResultGraph->getFunctionCalls();

  for (std::list<DSCallSite>::iterator CI = Calls.begin(), E = Calls.end();
       CI != E;) {
    DSCallSite &CurCall = *CI++;
    
    // Loop over the called functions, eliminating as many as possible...
    std::vector<Function*> CallTargets;
    if (CurCall.isDirectCall())
      CallTargets.push_back(CurCall.getCalleeFunc());
    else 
      CurCall.getCalleeNode()->addFullFunctionList(CallTargets);

    for (unsigned c = 0; c != CallTargets.size(); ) {
      // If we can eliminate this function call, do so!
      Function *F = CallTargets[c];
      if (!F->isExternal()) {
        ResolveFunctionCall(F, CurCall, RetValMap[F]);
        CallTargets[c] = CallTargets.back();
        CallTargets.pop_back();
      } else
        ++c;  // Cannot eliminate this call, skip over it...
    }

    if (CallTargets.empty()) {        // Eliminated all calls?
      std::list<DSCallSite>::iterator I = CI;
      Calls.erase(--I);               // Remove entry
    }
  }

  RetValMap.clear();

  // Update the "incomplete" markers on the nodes, ignoring unknownness due to
  // incoming arguments...
  ResultGraph->maskIncompleteMarkers();
  ResultGraph->markIncompleteNodes(DSGraph::IgnoreFormalArgs);

  // Remove any nodes that are dead after all of the merging we have done...
  // FIXME: We should be able to disable the globals graph for steens!
  ResultGraph->removeDeadNodes(DSGraph::KeepUnreachableGlobals);

  DEBUG(print(std::cerr, &M));
  return false;
}

// alias - This is the only method here that does anything interesting...
AliasAnalysis::AliasResult Steens::alias(const Value *V1, unsigned V1Size,
                                         const Value *V2, unsigned V2Size) {
  // FIXME: HANDLE Size argument!
  assert(ResultGraph && "Result graph has not been computed yet!");

  DSGraph::ScalarMapTy &GSM = ResultGraph->getScalarMap();

  DSGraph::ScalarMapTy::iterator I = GSM.find(const_cast<Value*>(V1));
  if (I != GSM.end() && I->second.getNode()) {
    DSNodeHandle &V1H = I->second;
    DSGraph::ScalarMapTy::iterator J=GSM.find(const_cast<Value*>(V2));
    if (J != GSM.end() && J->second.getNode()) {
      DSNodeHandle &V2H = J->second;
      // If the two pointers point to different data structure graph nodes, they
      // cannot alias!
      if (V1H.getNode() != V2H.getNode())    // FIXME: Handle incompleteness!
        return NoAlias;

      // FIXME: If the two pointers point to the same node, and the offsets are
      // different, and the LinkIndex vector doesn't alias the section, then the
      // two pointers do not alias.  We need access size information for the two
      // accesses though!
      //
    }
  }

  // If we cannot determine alias properties based on our graph, fall back on
  // some other AA implementation.
  //
  return AliasAnalysis::alias(V1, V1Size, V2, V2Size);
}
