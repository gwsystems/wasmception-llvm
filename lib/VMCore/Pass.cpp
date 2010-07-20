//===- Pass.cpp - LLVM Pass Infrastructure Implementation -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the LLVM Pass infrastructure.  It is primarily
// responsible with ensuring that passes are executed and batched together
// optimally.
//
//===----------------------------------------------------------------------===//

#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/PassRegistry.h"
#include "llvm/Module.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/Assembly/PrintModulePass.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/PassNameParser.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/System/Atomic.h"
#include "llvm/System/Mutex.h"
#include "llvm/System/Threading.h"
#include <algorithm>
#include <map>
#include <set>
using namespace llvm;

//===----------------------------------------------------------------------===//
// Pass Implementation
//

Pass::Pass(PassKind K, intptr_t pid) : Resolver(0), PassID(pid), Kind(K) {
  assert(pid && "pid cannot be 0");
}

Pass::Pass(PassKind K, const void *pid)
  : Resolver(0), PassID((intptr_t)pid), Kind(K) {
  assert(pid && "pid cannot be 0");
}

// Force out-of-line virtual method.
Pass::~Pass() { 
  delete Resolver; 
}

// Force out-of-line virtual method.
ModulePass::~ModulePass() { }

Pass *ModulePass::createPrinterPass(raw_ostream &O,
                                    const std::string &Banner) const {
  return createPrintModulePass(&O, false, Banner);
}

PassManagerType ModulePass::getPotentialPassManagerType() const {
  return PMT_ModulePassManager;
}

bool Pass::mustPreserveAnalysisID(const PassInfo *AnalysisID) const {
  return Resolver->getAnalysisIfAvailable(AnalysisID, true) != 0;
}

// dumpPassStructure - Implement the -debug-passes=Structure option
void Pass::dumpPassStructure(unsigned Offset) {
  dbgs().indent(Offset*2) << getPassName() << "\n";
}

/// getPassName - Return a nice clean name for a pass.  This usually
/// implemented in terms of the name that is registered by one of the
/// Registration templates, but can be overloaded directly.
///
const char *Pass::getPassName() const {
  if (const PassInfo *PI = getPassInfo())
    return PI->getPassName();
  return "Unnamed pass: implement Pass::getPassName()";
}

void Pass::preparePassManager(PMStack &) {
  // By default, don't do anything.
}

PassManagerType Pass::getPotentialPassManagerType() const {
  // Default implementation.
  return PMT_Unknown; 
}

void Pass::getAnalysisUsage(AnalysisUsage &) const {
  // By default, no analysis results are used, all are invalidated.
}

void Pass::releaseMemory() {
  // By default, don't do anything.
}

void Pass::verifyAnalysis() const {
  // By default, don't do anything.
}

void *Pass::getAdjustedAnalysisPointer(const PassInfo *) {
  return this;
}

ImmutablePass *Pass::getAsImmutablePass() {
  return 0;
}

PMDataManager *Pass::getAsPMDataManager() {
  return 0;
}

void Pass::setResolver(AnalysisResolver *AR) {
  assert(!Resolver && "Resolver is already set");
  Resolver = AR;
}

// print - Print out the internal state of the pass.  This is called by Analyze
// to print out the contents of an analysis.  Otherwise it is not necessary to
// implement this method.
//
void Pass::print(raw_ostream &O,const Module*) const {
  O << "Pass::print not implemented for pass: '" << getPassName() << "'!\n";
}

// dump - call print(cerr);
void Pass::dump() const {
  print(dbgs(), 0);
}

//===----------------------------------------------------------------------===//
// ImmutablePass Implementation
//
// Force out-of-line virtual method.
ImmutablePass::~ImmutablePass() { }

void ImmutablePass::initializePass() {
  // By default, don't do anything.
}

//===----------------------------------------------------------------------===//
// FunctionPass Implementation
//

Pass *FunctionPass::createPrinterPass(raw_ostream &O,
                                      const std::string &Banner) const {
  return createPrintFunctionPass(Banner, &O);
}

// run - On a module, we run this pass by initializing, runOnFunction'ing once
// for every function in the module, then by finalizing.
//
bool FunctionPass::runOnModule(Module &M) {
  bool Changed = doInitialization(M);

  for (Module::iterator I = M.begin(), E = M.end(); I != E; ++I)
    if (!I->isDeclaration())      // Passes are not run on external functions!
    Changed |= runOnFunction(*I);

  return Changed | doFinalization(M);
}

// run - On a function, we simply initialize, run the function, then finalize.
//
bool FunctionPass::run(Function &F) {
  // Passes are not run on external functions!
  if (F.isDeclaration()) return false;

  bool Changed = doInitialization(*F.getParent());
  Changed |= runOnFunction(F);
  return Changed | doFinalization(*F.getParent());
}

bool FunctionPass::doInitialization(Module &) {
  // By default, don't do anything.
  return false;
}

bool FunctionPass::doFinalization(Module &) {
  // By default, don't do anything.
  return false;
}

PassManagerType FunctionPass::getPotentialPassManagerType() const {
  return PMT_FunctionPassManager;
}

//===----------------------------------------------------------------------===//
// BasicBlockPass Implementation
//

Pass *BasicBlockPass::createPrinterPass(raw_ostream &O,
                                        const std::string &Banner) const {
  
  llvm_unreachable("BasicBlockPass printing unsupported.");
  return 0;
}

// To run this pass on a function, we simply call runOnBasicBlock once for each
// function.
//
bool BasicBlockPass::runOnFunction(Function &F) {
  bool Changed = doInitialization(F);
  for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I)
    Changed |= runOnBasicBlock(*I);
  return Changed | doFinalization(F);
}

bool BasicBlockPass::doInitialization(Module &) {
  // By default, don't do anything.
  return false;
}

bool BasicBlockPass::doInitialization(Function &) {
  // By default, don't do anything.
  return false;
}

bool BasicBlockPass::doFinalization(Function &) {
  // By default, don't do anything.
  return false;
}

bool BasicBlockPass::doFinalization(Module &) {
  // By default, don't do anything.
  return false;
}

PassManagerType BasicBlockPass::getPotentialPassManagerType() const {
  return PMT_BasicBlockPassManager; 
}

//===----------------------------------------------------------------------===//
// Pass Registration mechanism
//

static std::vector<PassRegistrationListener*> *Listeners = 0;
static sys::SmartMutex<true> ListenersLock;

static PassRegistry *PassRegistryObj = 0;
static PassRegistry *getPassRegistry() {
  // Use double-checked locking to safely initialize the registrar when
  // we're running in multithreaded mode.
  PassRegistry* tmp = PassRegistryObj;
  if (llvm_is_multithreaded()) {
    sys::MemoryFence();
    if (!tmp) {
      llvm_acquire_global_lock();
      tmp = PassRegistryObj;
      if (!tmp) {
        tmp = new PassRegistry();
        sys::MemoryFence();
        PassRegistryObj = tmp;
      }
      llvm_release_global_lock();
    }
  } else if (!tmp) {
    PassRegistryObj = new PassRegistry();
  }
  
  return PassRegistryObj;
}

namespace {

// FIXME: We use ManagedCleanup to erase the pass registrar on shutdown.
// Unfortunately, passes are registered with static ctors, and having
// llvm_shutdown clear this map prevents successful ressurection after 
// llvm_shutdown is run.  Ideally we should find a solution so that we don't
// leak the map, AND can still resurrect after shutdown.
void cleanupPassRegistry(void*) {
  if (PassRegistryObj) {
    delete PassRegistryObj;
    PassRegistryObj = 0;
  }
}
ManagedCleanup<&cleanupPassRegistry> registryCleanup ATTRIBUTE_USED;

}

// getPassInfo - Return the PassInfo data structure that corresponds to this
// pass...
const PassInfo *Pass::getPassInfo() const {
  return lookupPassInfo(PassID);
}

const PassInfo *Pass::lookupPassInfo(intptr_t TI) {
  return getPassRegistry()->getPassInfo(TI);
}

const PassInfo *Pass::lookupPassInfo(StringRef Arg) {
  return getPassRegistry()->getPassInfo(Arg);
}

void PassInfo::registerPass() {
  getPassRegistry()->registerPass(*this);

  // Notify any listeners.
  sys::SmartScopedLock<true> Lock(ListenersLock);
  if (Listeners)
    for (std::vector<PassRegistrationListener*>::iterator
           I = Listeners->begin(), E = Listeners->end(); I != E; ++I)
      (*I)->passRegistered(this);
}

void PassInfo::unregisterPass() {
  getPassRegistry()->unregisterPass(*this);
}

Pass *PassInfo::createPass() const {
  assert((!isAnalysisGroup() || NormalCtor) &&
         "No default implementation found for analysis group!");
  assert(NormalCtor &&
         "Cannot call createPass on PassInfo without default ctor!");
  return NormalCtor();
}

//===----------------------------------------------------------------------===//
//                  Analysis Group Implementation Code
//===----------------------------------------------------------------------===//

// RegisterAGBase implementation
//
RegisterAGBase::RegisterAGBase(const char *Name, intptr_t InterfaceID,
                               intptr_t PassID, bool isDefault)
  : PassInfo(Name, InterfaceID) {

  PassInfo *InterfaceInfo =
    const_cast<PassInfo*>(Pass::lookupPassInfo(InterfaceID));
  if (InterfaceInfo == 0) {
    // First reference to Interface, register it now.
    registerPass();
    InterfaceInfo = this;
  }
  assert(isAnalysisGroup() &&
         "Trying to join an analysis group that is a normal pass!");

  if (PassID) {
    const PassInfo *ImplementationInfo = Pass::lookupPassInfo(PassID);
    assert(ImplementationInfo &&
           "Must register pass before adding to AnalysisGroup!");

    // Make sure we keep track of the fact that the implementation implements
    // the interface.
    PassInfo *IIPI = const_cast<PassInfo*>(ImplementationInfo);
    IIPI->addInterfaceImplemented(InterfaceInfo);
    
    getPassRegistry()->registerAnalysisGroup(InterfaceInfo, IIPI, isDefault);
  }
}


//===----------------------------------------------------------------------===//
// PassRegistrationListener implementation
//

// PassRegistrationListener ctor - Add the current object to the list of
// PassRegistrationListeners...
PassRegistrationListener::PassRegistrationListener() {
  sys::SmartScopedLock<true> Lock(ListenersLock);
  if (!Listeners) Listeners = new std::vector<PassRegistrationListener*>();
  Listeners->push_back(this);
}

// dtor - Remove object from list of listeners...
PassRegistrationListener::~PassRegistrationListener() {
  sys::SmartScopedLock<true> Lock(ListenersLock);
  std::vector<PassRegistrationListener*>::iterator I =
    std::find(Listeners->begin(), Listeners->end(), this);
  assert(Listeners && I != Listeners->end() &&
         "PassRegistrationListener not registered!");
  Listeners->erase(I);

  if (Listeners->empty()) {
    delete Listeners;
    Listeners = 0;
  }
}

// enumeratePasses - Iterate over the registered passes, calling the
// passEnumerate callback on each PassInfo object.
//
void PassRegistrationListener::enumeratePasses() {
  getPassRegistry()->enumerateWith(this);
}

PassNameParser::~PassNameParser() {}

//===----------------------------------------------------------------------===//
//   AnalysisUsage Class Implementation
//

namespace {
  struct GetCFGOnlyPasses : public PassRegistrationListener {
    typedef AnalysisUsage::VectorType VectorType;
    VectorType &CFGOnlyList;
    GetCFGOnlyPasses(VectorType &L) : CFGOnlyList(L) {}
    
    void passEnumerate(const PassInfo *P) {
      if (P->isCFGOnlyPass())
        CFGOnlyList.push_back(P);
    }
  };
}

// setPreservesCFG - This function should be called to by the pass, iff they do
// not:
//
//  1. Add or remove basic blocks from the function
//  2. Modify terminator instructions in any way.
//
// This function annotates the AnalysisUsage info object to say that analyses
// that only depend on the CFG are preserved by this pass.
//
void AnalysisUsage::setPreservesCFG() {
  // Since this transformation doesn't modify the CFG, it preserves all analyses
  // that only depend on the CFG (like dominators, loop info, etc...)
  GetCFGOnlyPasses(Preserved).enumeratePasses();
}

AnalysisUsage &AnalysisUsage::addRequiredID(AnalysisID ID) {
  assert(ID && "Pass class not registered!");
  Required.push_back(ID);
  return *this;
}

AnalysisUsage &AnalysisUsage::addRequiredTransitiveID(AnalysisID ID) {
  assert(ID && "Pass class not registered!");
  Required.push_back(ID);
  RequiredTransitive.push_back(ID);
  return *this;
}
