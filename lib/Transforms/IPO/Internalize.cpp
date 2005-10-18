//===-- Internalize.cpp - Mark functions internal -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass loops over all of the functions in the input module, looking for a
// main function.  If a main function is found, all other functions and all
// global variables with initializers are marked as internal.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/IPO.h"
#include "llvm/Pass.h"
#include "llvm/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/ADT/Statistic.h"
#include <fstream>
#include <set>
using namespace llvm;

namespace {
  Statistic<> NumFunctions("internalize", "Number of functions internalized");
  Statistic<> NumGlobals  ("internalize", "Number of global vars internalized");

  // APIFile - A file which contains a list of symbols that should not be marked
  // external.
  cl::opt<std::string>
  APIFile("internalize-public-api-file", cl::value_desc("filename"),
          cl::desc("A file containing list of symbol names to preserve"));

  // APIList - A list of symbols that should not be marked internal.
  cl::list<std::string>
  APIList("internalize-public-api-list", cl::value_desc("list"),
          cl::desc("A list of symbol names to preserve"),
          cl::CommaSeparated);

  class InternalizePass : public ModulePass {
    std::set<std::string> ExternalNames;
    bool DontInternalize;
  public:
    InternalizePass(bool InternalizeEverything = true) : DontInternalize(false){
      if (!APIFile.empty())           // If a filename is specified, use it
        LoadFile(APIFile.c_str());
      else if (!APIList.empty())      // Else, if a list is specified, use it.
        ExternalNames.insert(APIList.begin(), APIList.end());
      else if (!InternalizeEverything)
        // Finally, if we're allowed to, internalize all but main.
        DontInternalize = true;
    }

    void LoadFile(const char *Filename) {
      // Load the APIFile...
      std::ifstream In(Filename);
      if (!In.good()) {
        std::cerr << "WARNING: Internalize couldn't load file '" << Filename
                  << "'!\n";
        return;   // Do not internalize anything...
      }
      while (In) {
        std::string Symbol;
        In >> Symbol;
        if (!Symbol.empty())
          ExternalNames.insert(Symbol);
      }
    }

    virtual bool runOnModule(Module &M) {
      if (DontInternalize) return false;
      
      // If no list or file of symbols was specified, check to see if there is a
      // "main" symbol defined in the module.  If so, use it, otherwise do not
      // internalize the module, it must be a library or something.
      //
      if (ExternalNames.empty()) {
        Function *MainFunc = M.getMainFunction();
        if (MainFunc == 0 || MainFunc->isExternal())
          return false;  // No main found, must be a library...

        // Preserve main, internalize all else.
        ExternalNames.insert(MainFunc->getName());
      }

      bool Changed = false;

      // Found a main function, mark all functions not named main as internal.
      for (Module::iterator I = M.begin(), E = M.end(); I != E; ++I)
        if (!I->isExternal() &&         // Function must be defined here
            !I->hasInternalLinkage() &&  // Can't already have internal linkage
            !ExternalNames.count(I->getName())) {// Not marked to keep external?
          I->setLinkage(GlobalValue::InternalLinkage);
          Changed = true;
          ++NumFunctions;
          DEBUG(std::cerr << "Internalizing func " << I->getName() << "\n");
        }

      // Mark all global variables with initializers as internal as well...
      for (Module::global_iterator I = M.global_begin(), E = M.global_end(); I != E; ++I)
        if (!I->isExternal() && !I->hasInternalLinkage() &&
            !ExternalNames.count(I->getName())) {
          // Special case handling of the global ctor and dtor list.  When we
          // internalize it, we mark it constant, which allows elimination of
          // the list if it's empty.
          //
          if (I->hasAppendingLinkage() && (I->getName() == "llvm.global_ctors"||
                                           I->getName() == "llvm.global_dtors"))
            I->setConstant(true);

          I->setLinkage(GlobalValue::InternalLinkage);
          Changed = true;
          ++NumGlobals;
          DEBUG(std::cerr << "Internalizing gvar " << I->getName() << "\n");
        }

      return Changed;
    }
  };

  RegisterOpt<InternalizePass> X("internalize", "Internalize Global Symbols");
} // end anonymous namespace

ModulePass *llvm::createInternalizePass(bool InternalizeEverything) {
  return new InternalizePass(InternalizeEverything);
}
