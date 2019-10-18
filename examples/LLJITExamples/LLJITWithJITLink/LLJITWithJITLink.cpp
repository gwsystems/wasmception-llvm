//===-- LLJITWithJITLink.cpp - Configure LLJIT to use ObjectLinkingLayer --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file shows how to switch LLJIT to use ObjectLinkingLayer (which is
// backed by JITLink) rather than RTDyldObjectLinkingLayer (which is backed by
// RuntimeDyld). Using JITLink as the underlying allocator enables use of
// small code model in JIT'd code.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringMap.h"
#include "llvm/ExecutionEngine/JITLink/JITLinkMemoryManager.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/ExecutionEngine/Orc/ObjectLinkingLayer.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"

#include "../ExampleModules.h"

using namespace llvm;
using namespace llvm::orc;

ExitOnError ExitOnErr;

int main(int argc, char *argv[]) {
  // Initialize LLVM.
  InitLLVM X(argc, argv);

  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  cl::ParseCommandLineOptions(argc, argv, "HowToUseLLJIT");
  ExitOnErr.setBanner(std::string(argv[0]) + ": ");

  // Define an in-process JITLink memory manager.
  jitlink::InProcessMemoryManager MemMgr;

  // Detect the host and set code model to small.
  auto JTMB = ExitOnErr(JITTargetMachineBuilder::detectHost());
  JTMB.setCodeModel(CodeModel::Small);

  // Create an LLJIT instance with an ObjectLinkingLayer as the base layer.
  auto J =
      ExitOnErr(LLJITBuilder()
                    .setJITTargetMachineBuilder(std::move(JTMB))
                    .setObjectLinkingLayerCreator([&](ExecutionSession &ES,
                                                      const Triple &TT) {
                      return std::make_unique<ObjectLinkingLayer>(ES, MemMgr);
                    })
                    .create());

  auto M = ExitOnErr(parseExampleModule(Add1Example, "add1"));

  ExitOnErr(J->addIRModule(std::move(M)));

  // Look up the JIT'd function, cast it to a function pointer, then call it.
  auto Add1Sym = ExitOnErr(J->lookup("add1"));
  int (*Add1)(int) = (int (*)(int))Add1Sym.getAddress();

  int Result = Add1(42);
  outs() << "add1(42) = " << Result << "\n";

  return 0;
}
