//===-- Scalar.cpp --------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements common infrastructure for libLLVMScalarOpts.a, which 
// implements several scalar transformations over the LLVM intermediate
// representation, including the C bindings for that library.
//
//===----------------------------------------------------------------------===//

#include "llvm-c/Transforms/Scalar.h"
#include "llvm-c/Initialization.h"
#include "llvm/InitializePasses.h"
#include "llvm/PassManager.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

/// initializeScalarOptsPasses - Initialize all passes linked into the 
/// ScalarOpts library.
void llvm::initializeScalarOpts(PassRegistry &Registry) {
  initializeADCEPass(Registry);
  initializeBlockPlacementPass(Registry);
  initializeCodeGenPreparePass(Registry);
  initializeConstantPropagationPass(Registry);
  initializeCorrelatedValuePropagationPass(Registry);
  initializeDCEPass(Registry);
  initializeDeadInstEliminationPass(Registry);
  initializeDSEPass(Registry);
  initializeGEPSplitterPass(Registry);
  initializeGVNPass(Registry);
  initializeIndVarSimplifyPass(Registry);
  initializeJumpThreadingPass(Registry);
  initializeLICMPass(Registry);
  initializeLoopDeletionPass(Registry);
  initializeLoopRotatePass(Registry);
  initializeLoopStrengthReducePass(Registry);
  initializeLoopUnrollPass(Registry);
  initializeLoopUnswitchPass(Registry);
  initializeLoopIdiomRecognizePass(Registry);
  initializeLowerAtomicPass(Registry);
  initializeMemCpyOptPass(Registry);
  initializeReassociatePass(Registry);
  initializeRegToMemPass(Registry);
  initializeSCCPPass(Registry);
  initializeIPSCCPPass(Registry);
  initializeSROAPass(Registry);
  initializeCFGSimplifyPassPass(Registry);
  initializeSimplifyHalfPowrLibCallsPass(Registry);
  initializeSimplifyLibCallsPass(Registry);
  initializeSinkingPass(Registry);
  initializeTailDupPass(Registry);
  initializeTailCallElimPass(Registry);
}

void LLVMInitializeScalarOpts(LLVMPassRegistryRef R) {
  initializeScalarOpts(*unwrap(R));
}

void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createAggressiveDCEPass());
}

void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createCFGSimplificationPass());
}

void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createDeadStoreEliminationPass());
}

void LLVMAddGVNPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createGVNPass());
}

void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createIndVarSimplifyPass());
}

void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createInstructionCombiningPass());
}

void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createJumpThreadingPass());
}

void LLVMAddLICMPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createLICMPass());
}

void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createLoopDeletionPass());
}

void LLVMAddLoopRotatePass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createLoopRotatePass());
}

void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createLoopUnrollPass());
}

void LLVMAddLoopUnswitchPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createLoopUnswitchPass());
}

void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createMemCpyOptPass());
}

void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createPromoteMemoryToRegisterPass());
}

void LLVMAddReassociatePass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createReassociatePass());
}

void LLVMAddSCCPPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createSCCPPass());
}

void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createScalarReplAggregatesPass());
}

void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM,
                                                  int Threshold) {
  unwrap(PM)->add(createScalarReplAggregatesPass(Threshold));
}

void LLVMAddSimplifyLibCallsPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createSimplifyLibCallsPass());
}

void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createTailCallEliminationPass());
}

void LLVMAddConstantPropagationPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createConstantPropagationPass());
}

void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createDemoteRegisterToMemoryPass());
}

void LLVMAddVerifierPass(LLVMPassManagerRef PM) {
  unwrap(PM)->add(createVerifierPass());
}
