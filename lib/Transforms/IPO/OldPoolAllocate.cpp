//===-- PoolAllocate.cpp - Pool Allocation Pass ---------------------------===//
//
// This transform changes programs so that disjoint data structures are
// allocated out of different pools of memory, increasing locality and shrinking
// pointer size.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/IPO/PoolAllocate.h"
#include "llvm/Transforms/CloneFunction.h"
#include "llvm/Analysis/DataStructure.h"
#include "llvm/Analysis/DataStructureGraph.h"
#include "llvm/Pass.h"
#include "llvm/Module.h"
#include "llvm/Function.h"
#include "llvm/iMemory.h"
#include "llvm/iTerminators.h"
#include "llvm/iOther.h"
#include "llvm/ConstantVals.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Support/InstVisitor.h"
#include "Support/DepthFirstIterator.h"
#include "Support/STLExtras.h"
#include <algorithm>


// FIXME: This is dependant on the sparc backend layout conventions!!
static TargetData TargetData("test");

namespace {
  // ScalarInfo - Information about an LLVM value that we know points to some
  // datastructure we are processing.
  //
  struct ScalarInfo {
    Value       *Val;            // Scalar value in Current Function
    AllocDSNode *AllocNode;      // Allocation node it points to
    Value       *PoolHandle;     // PoolTy* LLVM value
    
    ScalarInfo(Value *V, AllocDSNode *AN, Value *PH)
      : Val(V), AllocNode(AN), PoolHandle(PH) {}
  };

  // CallArgInfo - Information on one operand for a call that got expanded.
  struct CallArgInfo {
    int ArgNo;              // Call argument number this corresponds to
    AllocDSNode *AllocNode; // The allocation graph node for the pool
    Value *PoolHandle;      // The LLVM value that is the pool pointer

    CallArgInfo(int Arg, AllocDSNode *AN, Value *PH)
      : ArgNo(Arg), AllocNode(AN), PoolHandle(PH) {
    }

    bool operator<(const CallArgInfo &CAI) const {
      return ArgNo < CAI.ArgNo;
    }
  };

  // TransformFunctionInfo - Information about how a function eeds to be
  // transformed.
  //
  struct TransformFunctionInfo {
    // ArgInfo - Maintain information about the arguments that need to be
    // processed.  Each pair corresponds to an argument (whose number is the
    // first element) that needs to have a pool pointer (the second element)
    // passed into the transformed function with it.
    //
    // As a special case, "argument" number -1 corresponds to the return value.
    //
    vector<CallArgInfo> ArgInfo;

    // Func - The function to be transformed...
    Function *Func;

    // default ctor...
    TransformFunctionInfo() : Func(0) {}
    
    bool operator<(const TransformFunctionInfo &TFI) const {
      if (Func < TFI.Func) return true;
      if (Func > TFI.Func) return false;
      if (ArgInfo.size() < TFI.ArgInfo.size()) return true;
      if (ArgInfo.size() > TFI.ArgInfo.size()) return false;
      return ArgInfo < TFI.ArgInfo;
    }

    void finalizeConstruction() {
      // Sort the vector so that the return value is first, followed by the
      // argument records, in order.
      sort(ArgInfo.begin(), ArgInfo.end());
    }
  };


  // Define the pass class that we implement...
  class PoolAllocate : public Pass {
    // PoolTy - The type of a scalar value that contains a pool pointer.
    PointerType *PoolTy;
  public:

    PoolAllocate() {
      // Initialize the PoolTy instance variable, since the type never changes.
      vector<const Type*> PoolElements;
      PoolElements.push_back(PointerType::get(Type::SByteTy));
      PoolElements.push_back(Type::UIntTy);
      PoolTy = PointerType::get(StructType::get(PoolElements));
      // PoolTy = { sbyte*, uint }*

      CurModule = 0; DS = 0;
      PoolInit = PoolDestroy = PoolAlloc = PoolFree = 0;
    }

    bool run(Module *M);

    // getAnalysisUsageInfo - This function requires data structure information
    // to be able to see what is pool allocatable.
    //
    virtual void getAnalysisUsageInfo(Pass::AnalysisSet &Required,
                                      Pass::AnalysisSet &,Pass::AnalysisSet &) {
      Required.push_back(DataStructure::ID);
    }

  public:
    // CurModule - The module being processed.
    Module *CurModule;

    // DS - The data structure graph for the module being processed.
    DataStructure *DS;

    // Prototypes that we add to support pool allocation...
    Function *PoolInit, *PoolDestroy, *PoolAlloc, *PoolFree;

    // The map of already transformed functions...
    map<TransformFunctionInfo, Function*> TransformedFunctions;

    // getTransformedFunction - Get a transformed function, or return null if
    // the function specified hasn't been transformed yet.
    //
    Function *getTransformedFunction(TransformFunctionInfo &TFI) const {
      map<TransformFunctionInfo, Function*>::const_iterator I =
        TransformedFunctions.find(TFI);
      if (I != TransformedFunctions.end()) return I->second;
      return 0;
    }


    // addPoolPrototypes - Add prototypes for the pool methods to the specified
    // module and update the Pool* instance variables to point to them.
    //
    void addPoolPrototypes(Module *M);


    // CreatePools - Insert instructions into the function we are processing to
    // create all of the memory pool objects themselves.  This also inserts
    // destruction code.  Add an alloca for each pool that is allocated to the
    // PoolDescriptors vector.
    //
    void CreatePools(Function *F, const vector<AllocDSNode*> &Allocs,
                     map<AllocDSNode*, AllocaInst*> &PoolDescriptors);

    // processFunction - Convert a function to use pool allocation where
    // available.
    //
    bool processFunction(Function *F);

    
    void transformFunctionBody(Function *F, vector<ScalarInfo> &Scalars,
                               map<AllocDSNode*, AllocaInst*> &PoolDescriptors);

    // transformFunction - Transform the specified function the specified way.
    // It we have already transformed that function that way, don't do anything.
    //
    void transformFunction(TransformFunctionInfo &TFI);

  };
}



// isNotPoolableAlloc - This is a predicate that returns true if the specified
// allocation node in a data structure graph is eligable for pool allocation.
//
static bool isNotPoolableAlloc(const AllocDSNode *DS) {
  if (DS->isAllocaNode()) return true;  // Do not pool allocate alloca's.

  MallocInst *MI = cast<MallocInst>(DS->getAllocation());
  if (MI->isArrayAllocation() && !isa<Constant>(MI->getArraySize()))
    return true;   // Do not allow variable size allocations...

  return false;
}

// processFunction - Convert a function to use pool allocation where
// available.
//
bool PoolAllocate::processFunction(Function *F) {
  // Get the closed datastructure graph for the current function... if there are
  // any allocations in this graph that are not escaping, we need to pool
  // allocate them here!
  //
  FunctionDSGraph &IPGraph = DS->getClosedDSGraph(F);

  // Get all of the allocations that do not escape the current function.  Since
  // they are still live (they exist in the graph at all), this means we must
  // have scalar references to these nodes, but the scalars are never returned.
  // 
  vector<AllocDSNode*> Allocs;
  IPGraph.getNonEscapingAllocations(Allocs);

  // Filter out allocations that we cannot handle.  Currently, this includes
  // variable sized array allocations and alloca's (which we do not want to
  // pool allocate)
  //
  Allocs.erase(remove_if(Allocs.begin(), Allocs.end(), isNotPoolableAlloc),
               Allocs.end());


  if (Allocs.empty()) return false;  // Nothing to do.

  // Insert instructions into the function we are processing to create all of
  // the memory pool objects themselves.  This also inserts destruction code.
  // This fills in the PoolDescriptors map to associate the alloc node with the
  // allocation of the memory pool corresponding to it.
  // 
  map<AllocDSNode*, AllocaInst*> PoolDescriptors;
  CreatePools(F, Allocs, PoolDescriptors);


  // Loop through the value map looking for scalars that refer to nonescaping
  // allocations.  Add them to the Scalars vector.  Note that we may have
  // multiple entries in the Scalars vector for each value if it points to more
  // than one object.
  //
  map<Value*, PointerValSet> &ValMap = IPGraph.getValueMap();
  vector<ScalarInfo> Scalars;

  for (map<Value*, PointerValSet>::iterator I = ValMap.begin(),
         E = ValMap.end(); I != E; ++I) {
    const PointerValSet &PVS = I->second;  // Set of things pointed to by scalar

    assert(PVS.size() == 1 &&
           "Only handle scalars that point to one thing so far!");

    // Check to see if the scalar points to anything that is an allocation...
    for (unsigned i = 0, e = PVS.size(); i != e; ++i)
      if (AllocDSNode *Alloc = dyn_cast<AllocDSNode>(PVS[i].Node)) {
        assert(PVS[i].Index == 0 && "Nonzero not handled yet!");
        
        // If the allocation is in the nonescaping set...
        map<AllocDSNode*, AllocaInst*>::iterator AI=PoolDescriptors.find(Alloc);
        if (AI != PoolDescriptors.end()) // Add it to the list of scalars
          Scalars.push_back(ScalarInfo(I->first, Alloc, AI->second));
      }
  }

  // Now we need to figure out what called methods we need to transform, and
  // how.  To do this, we look at all of the scalars, seeing which functions are
  // either used as a scalar value (so they return a data structure), or are
  // passed one of our scalar values.
  //
  transformFunctionBody(F, Scalars, PoolDescriptors);

  return true;
}


class FunctionBodyTransformer : public InstVisitor<FunctionBodyTransformer> {
  PoolAllocate &PoolAllocator;
  vector<ScalarInfo> &Scalars;
  map<CallInst*, TransformFunctionInfo> &CallMap;

  const ScalarInfo &getScalar(const Value *V) {
    for (unsigned i = 0, e = Scalars.size(); i != e; ++i)
      if (Scalars[i].Val == V) return Scalars[i];
    assert(0 && "Scalar not found in getScalar!");
    abort();
    return Scalars[0];
  }

  // updateScalars - Map the scalars array entries that look like 'From' to look
  // like 'To'.
  //
  void updateScalars(Value *From, Value *To) {
    for (unsigned i = 0, e = Scalars.size(); i != e; ++i)
      if (Scalars[i].Val == From) Scalars[i].Val = To;
  }

public:
  FunctionBodyTransformer(PoolAllocate &PA, vector<ScalarInfo> &S,
                          map<CallInst*, TransformFunctionInfo> &C)
    : PoolAllocator(PA), Scalars(S), CallMap(C) {}

  void visitMemAccessInst(MemAccessInst *MAI) {
    // Don't do anything to load, store, or GEP yet...
  }

  // Convert a malloc instruction into a call to poolalloc
  void visitMallocInst(MallocInst *I) {
    const ScalarInfo &SC = getScalar(I);
    BasicBlock *BB = I->getParent();
    BasicBlock::iterator MI = find(BB->begin(), BB->end(), I);
    BB->getInstList().remove(MI);  // Remove the Malloc instruction from the BB

    // Create a new call to poolalloc before the malloc instruction
    vector<Value*> Args;
    Args.push_back(SC.PoolHandle);
    CallInst *Call = new CallInst(PoolAllocator.PoolAlloc, Args, I->getName());
    MI = BB->getInstList().insert(MI, Call)+1;

    // If the type desired is not void*, cast it now...
    Value *Ptr = Call;
    if (Call->getType() != I->getType()) {
      CastInst *CI = new CastInst(Ptr, I->getType(), I->getName());
      BB->getInstList().insert(MI, CI);
      Ptr = CI;
    }

    // Change everything that used the malloc to now use the pool alloc...
    I->replaceAllUsesWith(Ptr);

    // Update the scalars array...
    updateScalars(I, Ptr);

    // Delete the instruction now.
    delete I;
  }

  // Convert the free instruction into a call to poolfree
  void visitFreeInst(FreeInst *I) {
    Value *Ptr = I->getOperand(0);
    const ScalarInfo &SC = getScalar(Ptr);
    BasicBlock *BB = I->getParent();
    BasicBlock::iterator FI = find(BB->begin(), BB->end(), I);

    // If the value is not an sbyte*, convert it now!
    if (Ptr->getType() != PointerType::get(Type::SByteTy)) {
      CastInst *CI = new CastInst(Ptr, PointerType::get(Type::SByteTy),
                                  Ptr->getName());
      FI = BB->getInstList().insert(FI, CI)+1;
      Ptr = CI;
    }

    // Create a new call to poolfree before the free instruction
    vector<Value*> Args;
    Args.push_back(SC.PoolHandle);
    Args.push_back(Ptr);
    CallInst *Call = new CallInst(PoolAllocator.PoolFree, Args);
    FI = BB->getInstList().insert(FI, Call)+1;

    // Remove the old free instruction...
    delete BB->getInstList().remove(FI);
  }

  // visitCallInst - Create a new call instruction with the extra arguments for
  // all of the memory pools that the call needs.
  //
  void visitCallInst(CallInst *I) {
    TransformFunctionInfo &TI = CallMap[I];
    BasicBlock *BB = I->getParent();
    BasicBlock::iterator CI = find(BB->begin(), BB->end(), I);
    BB->getInstList().remove(CI);  // Remove the old call instruction

    // Start with all of the old arguments...
    vector<Value*> Args(I->op_begin()+1, I->op_end());

    // Add all of the pool arguments...
    for (unsigned i = 0, e = TI.ArgInfo.size(); i != e; ++i)
      Args.push_back(TI.ArgInfo[i].PoolHandle);
    
    Function *NF = PoolAllocator.getTransformedFunction(TI);
    CallInst *NewCall = new CallInst(NF, Args, I->getName());
    BB->getInstList().insert(CI, NewCall);

    // Change everything that used the malloc to now use the pool alloc...
    if (I->getType() != Type::VoidTy) {
      I->replaceAllUsesWith(NewCall);

      // Update the scalars array...
      updateScalars(I, NewCall);
    }

    delete I;  // Delete the old call instruction now...
  }

  void visitPHINode(PHINode *PN) {
    // Handle PHI Node
  }

  void visitInstruction(Instruction *I) {
    cerr << "Unknown instruction to FunctionBodyTransformer:\n";
    I->dump();
  }

};


static void addCallInfo(TransformFunctionInfo &TFI, CallInst *CI, int Arg, 
                        DSNode *AllocNode,
                        map<AllocDSNode*, AllocaInst*> &PoolDescriptors) {

  // For now, add the entire graph that is pointed to by the call argument.
  // This graph can and should be pruned to only what the function itself will
  // use, because often this will be a dramatically smaller subset of what we
  // are providing.
  //
  for (df_iterator<DSNode*> I = df_begin(AllocNode), E = df_end(AllocNode);
       I != E; ++I) {
    if (AllocDSNode *AN = dyn_cast<AllocDSNode>(*I))
      TFI.ArgInfo.push_back(CallArgInfo(Arg, AN, PoolDescriptors[AN]));
  }

  assert(CI->getCalledFunction() && "Cannot handle indirect calls yet!");
  assert(TFI.Func == 0 || TFI.Func == CI->getCalledFunction() &&
         "Function call record should always call the same function!");
  TFI.Func = CI->getCalledFunction();
}

void PoolAllocate::transformFunctionBody(Function *F,
                                         vector<ScalarInfo> &Scalars,
                             map<AllocDSNode*, AllocaInst*> &PoolDescriptors) {
  cerr << "In '" << F->getName()
       << "': Found the following values that point to poolable nodes:\n";

  for (unsigned i = 0, e = Scalars.size(); i != e; ++i)
    Scalars[i].Val->dump();

  // CallMap - Contain an entry for every call instruction that needs to be
  // transformed.  Each entry in the map contains information about what we need
  // to do to each call site to change it to work.
  //
  map<CallInst*, TransformFunctionInfo> CallMap;

  // Now we need to figure out what called methods we need to transform, and
  // how.  To do this, we look at all of the scalars, seeing which functions are
  // either used as a scalar value (so they return a data structure), or are
  // passed one of our scalar values.
  //
  for (unsigned i = 0, e = Scalars.size(); i != e; ++i) {
    Value *ScalarVal = Scalars[i].Val;

    // Check to see if the scalar _IS_ a call...
    if (CallInst *CI = dyn_cast<CallInst>(ScalarVal))
      // If so, add information about the pool it will be returning...
      addCallInfo(CallMap[CI], CI, -1, Scalars[i].AllocNode, PoolDescriptors);

    // Check to see if the scalar is an operand to a call...
    for (Value::use_iterator UI = ScalarVal->use_begin(),
           UE = ScalarVal->use_end(); UI != UE; ++UI) {
      if (CallInst *CI = dyn_cast<CallInst>(*UI)) {
        // Find out which operand this is to the call instruction...
        User::op_iterator OI = find(CI->op_begin(), CI->op_end(), ScalarVal);
        assert(OI != CI->op_end() && "Call on use list but not an operand!?");
        assert(OI != CI->op_begin() && "Pointer operand is call destination?");

        // FIXME: This is broken if the same pointer is passed to a call more
        // than once!  It will get multiple entries for the first pointer.

        // Add the operand number and pool handle to the call table...
        addCallInfo(CallMap[CI], CI, OI-CI->op_begin()-1, Scalars[i].AllocNode,
                    PoolDescriptors);
      }
    }
  }

  // Print out call map...
  for (map<CallInst*, TransformFunctionInfo>::iterator I = CallMap.begin();
       I != CallMap.end(); ++I) {
    cerr << "\nFor call: ";
    I->first->dump();
    I->second.finalizeConstruction();
    cerr << I->second.Func->getName() << " must pass pool pointer for arg #";
    for (unsigned i = 0; i < I->second.ArgInfo.size(); ++i)
      cerr << I->second.ArgInfo[i].ArgNo << " ";
    cerr << "\n";
  }

  // Loop through all of the call nodes, recursively creating the new functions
  // that we want to call...  This uses a map to prevent infinite recursion and
  // to avoid duplicating functions unneccesarily.
  //
  for (map<CallInst*, TransformFunctionInfo>::iterator I = CallMap.begin(),
         E = CallMap.end(); I != E; ++I) {
    // Make sure the entries are sorted.
    I->second.finalizeConstruction();
    transformFunction(I->second);
  }

  // Now that all of the functions that we want to call are available, transform
  // the local method so that it uses the pools locally and passes them to the
  // functions that we just hacked up.
  //

  // First step, find the instructions to be modified.
  vector<Instruction*> InstToFix;
  for (unsigned i = 0, e = Scalars.size(); i != e; ++i) {
    Value *ScalarVal = Scalars[i].Val;

    // Check to see if the scalar _IS_ an instruction.  If so, it is involved.
    if (Instruction *Inst = dyn_cast<Instruction>(ScalarVal))
      InstToFix.push_back(Inst);

    // All all of the instructions that use the scalar as an operand...
    for (Value::use_iterator UI = ScalarVal->use_begin(),
           UE = ScalarVal->use_end(); UI != UE; ++UI)
      InstToFix.push_back(dyn_cast<Instruction>(*UI));
  }

  // Eliminate duplicates by sorting, then removing equal neighbors.
  sort(InstToFix.begin(), InstToFix.end());
  InstToFix.erase(unique(InstToFix.begin(), InstToFix.end()), InstToFix.end());

  // Use a FunctionBodyTransformer to transform all of the involved instructions
  FunctionBodyTransformer FBT(*this, Scalars, CallMap);
  for (unsigned i = 0, e = InstToFix.size(); i != e; ++i)
    FBT.visit(InstToFix[i]);


  // Since we have liberally hacked the function to pieces, we want to inform
  // the datastructure pass that its internal representation is out of date.
  //
  DS->invalidateFunction(F);
}


// transformFunction - Transform the specified function the specified way.
// It we have already transformed that function that way, don't do anything.
//
void PoolAllocate::transformFunction(TransformFunctionInfo &TFI) {
  if (getTransformedFunction(TFI)) return;  // Function xformation already done?

  Function *FuncToXForm = TFI.Func;
  const FunctionType *OldFuncType = FuncToXForm->getFunctionType();

  assert(!OldFuncType->isVarArg() && "Vararg functions not handled yet!");

  // Build the type for the new function that we are transforming
  vector<const Type*> ArgTys;
  for (unsigned i = 0, e = OldFuncType->getNumParams(); i != e; ++i)
    ArgTys.push_back(OldFuncType->getParamType(i));

  // Add one pool pointer for every argument that needs to be supplemented.
  ArgTys.insert(ArgTys.end(), TFI.ArgInfo.size(), PoolTy);

  // Build the new function type...
  const // FIXME when types are not const
  FunctionType *NewFuncType = FunctionType::get(OldFuncType->getReturnType(),
                                                ArgTys,OldFuncType->isVarArg());

  // The new function is internal, because we know that only we can call it.
  // This also helps subsequent IP transformations to eliminate duplicated pool
  // pointers. [in the future when they are implemented].
  //
  Function *NewFunc = new Function(NewFuncType, true,
                                   FuncToXForm->getName()+".poolxform");
  CurModule->getFunctionList().push_back(NewFunc);

  // Add the newly formed function to the TransformedFunctions table so that
  // infinite recursion does not occur!
  //
  TransformedFunctions[TFI] = NewFunc;

  // Add arguments to the function... starting with all of the old arguments
  vector<Value*> ArgMap;
  for (unsigned i = 0, e = FuncToXForm->getArgumentList().size(); i != e; ++i) {
    const FunctionArgument *OFA = FuncToXForm->getArgumentList()[i];
    FunctionArgument *NFA = new FunctionArgument(OFA->getType(),OFA->getName());
    NewFunc->getArgumentList().push_back(NFA);
    ArgMap.push_back(NFA);  // Keep track of the arguments 
  }

  // Now add all of the arguments corresponding to pools passed in...
  for (unsigned i = 0, e = TFI.ArgInfo.size(); i != e; ++i) {
    string Name;
    if (TFI.ArgInfo[i].ArgNo == -1)
      Name = "retpool";
    else
      Name = ArgMap[TFI.ArgInfo[i].ArgNo]->getName();  // Get the arg name
    FunctionArgument *NFA = new FunctionArgument(PoolTy, Name+".pool");
    NewFunc->getArgumentList().push_back(NFA);
  }

  // Now clone the body of the old function into the new function...
  CloneFunctionInto(NewFunc, FuncToXForm, ArgMap);
  
  // Okay, now we have a function that is identical to the old one, except that
  // it has extra arguments for the pools coming in.  


}


// CreatePools - Insert instructions into the function we are processing to
// create all of the memory pool objects themselves.  This also inserts
// destruction code.  Add an alloca for each pool that is allocated to the
// PoolDescriptors vector.
//
void PoolAllocate::CreatePools(Function *F, const vector<AllocDSNode*> &Allocs,
                               map<AllocDSNode*, AllocaInst*> &PoolDescriptors){
  // FIXME: This should use an IP version of the UnifyAllExits pass!
  vector<BasicBlock*> ReturnNodes;
  for (Function::iterator I = F->begin(), E = F->end(); I != E; ++I)
    if (isa<ReturnInst>((*I)->getTerminator()))
      ReturnNodes.push_back(*I);
  

  // Create the code that goes in the entry and exit nodes for the method...
  vector<Instruction*> EntryNodeInsts;
  for (unsigned i = 0, e = Allocs.size(); i != e; ++i) {
    // Add an allocation and a free for each pool...
    AllocaInst *PoolAlloc = new AllocaInst(PoolTy, 0, "pool");
    EntryNodeInsts.push_back(PoolAlloc);
    PoolDescriptors[Allocs[i]] = PoolAlloc;   // Keep track of pool allocas
    AllocationInst *AI = Allocs[i]->getAllocation();

    // Initialize the pool.  We need to know how big each allocation is.  For
    // our purposes here, we assume we are allocating a scalar, or array of
    // constant size.
    //
    unsigned ElSize = TargetData.getTypeSize(AI->getAllocatedType());
    ElSize *= cast<ConstantUInt>(AI->getArraySize())->getValue();

    vector<Value*> Args;
    Args.push_back(PoolAlloc);    // Pool to initialize
    Args.push_back(ConstantUInt::get(Type::UIntTy, ElSize));
    EntryNodeInsts.push_back(new CallInst(PoolInit, Args));

    // Destroy the pool...
    Args.pop_back();

    for (unsigned EN = 0, ENE = ReturnNodes.size(); EN != ENE; ++EN) {
      Instruction *Destroy = new CallInst(PoolDestroy, Args);

      // Insert it before the return instruction...
      BasicBlock *RetNode = ReturnNodes[EN];
      RetNode->getInstList().insert(RetNode->end()-1, Destroy);
    }
  }

  // Insert the entry node code into the entry block...
  F->getEntryNode()->getInstList().insert(F->getEntryNode()->begin()+1,
                                          EntryNodeInsts.begin(),
                                          EntryNodeInsts.end());
}


// addPoolPrototypes - Add prototypes for the pool methods to the specified
// module and update the Pool* instance variables to point to them.
//
void PoolAllocate::addPoolPrototypes(Module *M) {
  // Get PoolInit function...
  vector<const Type*> Args;
  Args.push_back(PoolTy);           // Pool to initialize
  Args.push_back(Type::UIntTy);     // Num bytes per element
  FunctionType *PoolInitTy = FunctionType::get(Type::VoidTy, Args, false);
  PoolInit = M->getOrInsertFunction("poolinit", PoolInitTy);

  // Get pooldestroy function...
  Args.pop_back();  // Only takes a pool...
  FunctionType *PoolDestroyTy = FunctionType::get(Type::VoidTy, Args, false);
  PoolDestroy = M->getOrInsertFunction("pooldestroy", PoolDestroyTy);

  const Type *PtrVoid = PointerType::get(Type::SByteTy);

  // Get the poolalloc function...
  FunctionType *PoolAllocTy = FunctionType::get(PtrVoid, Args, false);
  PoolAlloc = M->getOrInsertFunction("poolalloc", PoolAllocTy);

  // Get the poolfree function...
  Args.push_back(PtrVoid);
  FunctionType *PoolFreeTy = FunctionType::get(Type::VoidTy, Args, false);
  PoolFree = M->getOrInsertFunction("poolfree", PoolFreeTy);

  // Add the %PoolTy type to the symbol table of the module...
  M->addTypeName("PoolTy", PoolTy->getElementType());
}


bool PoolAllocate::run(Module *M) {
  addPoolPrototypes(M);
  CurModule = M;
  
  DS = &getAnalysis<DataStructure>();
  bool Changed = false;

  // We cannot use an iterator here because it will get invalidated when we add
  // functions to the module later...
  for (unsigned i = 0; i != M->size(); ++i)
    if (!M->getFunctionList()[i]->isExternal()) {
      Changed |= processFunction(M->getFunctionList()[i]);
      if (Changed) {
        cerr << "Only processing one function\n";
        break;
      }
    }

  CurModule = 0;
  DS = 0;
  return false;
}


// createPoolAllocatePass - Global function to access the functionality of this
// pass...
//
Pass *createPoolAllocatePass() { return new PoolAllocate(); }
