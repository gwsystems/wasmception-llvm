//===-- llvm/Analysis/Passes.h - Constructors for analyses ------*- C++ -*-===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This header file defines prototypes for accessor functions that expose passes
// in the analysis libraries.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ANALYSIS_PASSES_H
#define LLVM_ANALYSIS_PASSES_H

namespace llvm {
  class FunctionPass;
  class ImmutablePass;
  class ModulePass;
  class Pass;

  //===--------------------------------------------------------------------===//
  //
  // createGlobalsModRefPass - This pass provides alias and mod/ref info for
  // global values that do not have their addresses taken.
  //
  Pass *createGlobalsModRefPass();

  //===--------------------------------------------------------------------===//
  //
  // createAliasAnalysisCounterPass - This pass counts alias queries and how the
  // alias analysis implementation responds.
  //
  ModulePass *createAliasAnalysisCounterPass();

  //===--------------------------------------------------------------------===//
  //
  // createAAEvalPass - This pass implements a simple N^2 alias analysis
  // accuracy evaluator.
  //
  FunctionPass *createAAEvalPass();

  //===--------------------------------------------------------------------===//
  //
  // createNoAAPass - This pass implements a "I don't know" alias analysis.
  //
  ImmutablePass *createNoAAPass();
 
  //===--------------------------------------------------------------------===//
  //
  // createBasicAliasAnalysisPass - This pass implements the default alias
  // analysis.
  //
  ImmutablePass *createBasicAliasAnalysisPass();
 
  //===--------------------------------------------------------------------===//
  //
  // createAndersensPass - This pass implements Andersen's interprocedural alias
  // analysis.
  //
  ModulePass *createAndersensPass();
 
  //===--------------------------------------------------------------------===//
  //
  // createBasicVNPass - This pass walks SSA def-use chains to trivially
  // identify lexically identical expressions.
  //
  ImmutablePass *createBasicVNPass();
 
  //===--------------------------------------------------------------------===//
  //
  // createLoaderPass - This pass loads information from a profile dump file.
  //
  ModulePass *createLoaderPass();
 
  //===--------------------------------------------------------------------===//
  //
  // createNoProfileInfoPass - This pass implements the default "no profile".
  //
  ImmutablePass *createNoProfileInfoPass();
}

#endif
