//===- Interpreter.cpp - Top-Level LLVM Interpreter Implementation --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the top-level functionality for the LLVM interpreter.
// This interpreter is designed to be a very simple, portable, inefficient
// interpreter.
//
//===----------------------------------------------------------------------===//

#include "Interpreter.h"
#include "llvm/CodeGen/IntrinsicLowering.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/ModuleProvider.h"
#include <iostream>
using namespace llvm;

static struct RegisterInterp {
  RegisterInterp() { Interpreter::Register(); }
} InterpRegistrator;

namespace llvm {
  void LinkInInterpreter() {
  }
}

/// create - Create a new interpreter object.  This can never fail.
///
ExecutionEngine *Interpreter::create(ModuleProvider *MP, std::string* ErrStr) {
  // Tell this ModuleProvide to materialize and release the module
  Module *M = MP->releaseModule(ErrStr);
  if (!M)
    // We got an error, just return 0
    return 0;

  // This is a bit nasty, but the ExecutionEngine won't be able to delete the
  // module due to use/def issues if we don't delete this MP here. Below we
  // construct a new Interpreter with the Module we just got. This creates a
  // new ExistingModuleProvider in the EE instance. Consequently, MP is left
  // dangling and it contains references into the module which cause problems
  // when the module is deleted via the ExistingModuleProvide via EE.
  delete MP;
  
  // FIXME: This should probably compute the entire data layout
  std::string DataLayout;
  int Test = 0;
  *(char*)&Test = 1;    // Return true if the host is little endian
  bool isLittleEndian = (Test == 1);
  DataLayout.append(isLittleEndian ? "e" : "E");

  bool Ptr64 = sizeof(void*) == 8;
  DataLayout.append(Ptr64 ? "-p:64:64" : "-p:32:32");
	
  M->setDataLayout(DataLayout);

  return new Interpreter(M);
}

//===----------------------------------------------------------------------===//
// Interpreter ctor - Initialize stuff
//
Interpreter::Interpreter(Module *M) : ExecutionEngine(M), TD(M) {
      
  memset(&ExitValue, 0, sizeof(ExitValue));
  setTargetData(&TD);
  // Initialize the "backend"
  initializeExecutionEngine();
  initializeExternalFunctions();
  emitGlobals();

  IL = new IntrinsicLowering(TD);
}

Interpreter::~Interpreter() {
  delete IL;
}

void Interpreter::runAtExitHandlers () {
  while (!AtExitHandlers.empty()) {
    callFunction(AtExitHandlers.back(), std::vector<GenericValue>());
    AtExitHandlers.pop_back();
    run();
  }
}

/// run - Start execution with the specified function and arguments.
///
GenericValue
Interpreter::runFunction(Function *F,
                         const std::vector<GenericValue> &ArgValues) {
  assert (F && "Function *F was null at entry to run()");

  // Try extra hard not to pass extra args to a function that isn't
  // expecting them.  C programmers frequently bend the rules and
  // declare main() with fewer parameters than it actually gets
  // passed, and the interpreter barfs if you pass a function more
  // parameters than it is declared to take. This does not attempt to
  // take into account gratuitous differences in declared types,
  // though.
  std::vector<GenericValue> ActualArgs;
  const unsigned ArgCount = F->getFunctionType()->getNumParams();
  for (unsigned i = 0; i < ArgCount; ++i)
    ActualArgs.push_back(ArgValues[i]);

  // Set up the function call.
  callFunction(F, ActualArgs);

  // Start executing the function.
  run();

  return ExitValue;
}

