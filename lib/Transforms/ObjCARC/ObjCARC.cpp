//===-- ObjCARC.cpp --------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements common infrastructure for libLLVMObjCARCOpts.a, which
// implements several scalar transformations over the LLVM intermediate
// representation, including the C bindings for that library.
//
//===----------------------------------------------------------------------===//

#include "ObjCARC.h"

#include "llvm-c/Initialization.h"
#include "llvm/Analysis/Passes.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/InitializePasses.h"
#include "llvm/PassManager.h"
#include "llvm/Support/Commandline.h"

using namespace llvm;
using namespace llvm::objcarc;

/// \brief A handy option to enable/disable all ARC Optimizations.
bool llvm::objcarc::EnableARCOpts;
static cl::opt<bool, true>
EnableARCOptimizations("enable-objc-arc-opts",
                       cl::location(EnableARCOpts),
                       cl::init(true));

/// initializeObjCARCOptsPasses - Initialize all passes linked into the
/// ObjCARCOpts library.
void llvm::initializeObjCARCOpts(PassRegistry &Registry) {
  initializeObjCARCAliasAnalysisPass(Registry);
  initializeObjCARCAPElimPass(Registry);
  initializeObjCARCExpandPass(Registry);
  initializeObjCARCContractPass(Registry);
  initializeObjCARCOptPass(Registry);
}

void LLVMInitializeObjCARCOpts(LLVMPassRegistryRef R) {
  initializeObjCARCOpts(*unwrap(R));
}
