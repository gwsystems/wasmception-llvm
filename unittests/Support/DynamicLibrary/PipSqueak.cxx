//===- llvm/unittest/Support/DynamicLibrary/PipSqueak.cxx -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "PipSqueak.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#define PIPSQUEAK_TESTA_RETURN "LibCall"
#include "ExportedFuncs.cxx"

struct Global {
  std::string *Str;
  std::vector<std::string> *Vec;
  Global() : Str(nullptr), Vec(nullptr) {}
  ~Global() {
    if (Str) {
      if (Vec)
        Vec->push_back(*Str);
      *Str = "Global::~Global";
    }
  }
};

static Global Glb;

struct Local {
  std::string &Str;
  Local(std::string &S) : Str(S) {
    Str = "Local::Local";
    if (Glb.Str && !Glb.Str->empty())
      Str += std::string("(") + *Glb.Str + std::string(")");
  }
  ~Local() { Str = "Local::~Local"; }
};


extern "C" PIPSQUEAK_EXPORT void SetStrings(std::string &GStr,
                                            std::string &LStr) {
  Glb.Str = &GStr;
  static Local Lcl(LStr);
}

extern "C" PIPSQUEAK_EXPORT void TestOrder(std::vector<std::string> &V) {
  Glb.Vec = &V;
}


static void LibPassRegistration(const llvm::PassManagerBuilder &,
                                llvm::legacy::PassManagerBase &) {}

extern "C" PIPSQUEAK_EXPORT void TestPassReg(
    void (*addGlobalExtension)(llvm::PassManagerBuilder::ExtensionPointTy,
                               llvm::PassManagerBuilder::ExtensionProc)) {
  addGlobalExtension(llvm::PassManagerBuilder::EP_EarlyAsPossible,
                     LibPassRegistration);
}
