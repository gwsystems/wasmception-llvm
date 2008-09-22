//===--- AutoGenerated.h - The LLVM Compiler Driver -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open
// Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//  Auto-generated tool descriptions - public interface.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVMC2_AUTOGENERATED_H
#define LLVM_TOOLS_LLVMC2_AUTOGENERATED_H

#include "llvm/ADT/StringMap.h"

#include <string>

namespace llvmc {

  class LanguageMap;
  class CompilationGraph;

  /// PopulateLanguageMap - The auto-generated function that fills in
  /// the language map (map from file extensions to language names).
  void PopulateLanguageMap(LanguageMap& langMap);
  /// PopulateCompilationGraph - The auto-generated function that
  /// populates the compilation graph with nodes and edges.
  void PopulateCompilationGraph(CompilationGraph& tools);
}

#endif // LLVM_TOOLS_LLVMC2_AUTOGENERATED_H
