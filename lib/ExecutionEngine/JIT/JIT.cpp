//===-- JIT.cpp - LLVM Just in Time Compiler ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This tool implements a just-in-time compiler for LLVM, allowing direct
// execution of LLVM bitcode in an efficient manner.
//
//===----------------------------------------------------------------------===//

#include "JIT.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Function.h"
#include "llvm/GlobalVariable.h"
#include "llvm/Instructions.h"
#include "llvm/ModuleProvider.h"
#include "llvm/CodeGen/MachineCodeEmitter.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetJITInfo.h"
#include "llvm/Support/Dwarf.h"
#include "llvm/Support/MutexGuard.h"
#include "llvm/System/DynamicLibrary.h"
#include "llvm/Config/config.h"

using namespace llvm;

#ifdef __APPLE__ 
// Apple gcc defaults to -fuse-cxa-atexit (i.e. calls __cxa_atexit instead
// of atexit). It passes the address of linker generated symbol __dso_handle
// to the function.
// This configuration change happened at version 5330.
# include <AvailabilityMacros.h>
# if defined(MAC_OS_X_VERSION_10_4) && \
     ((MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4) || \
      (MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_4 && \
       __APPLE_CC__ >= 5330))
#  ifndef HAVE___DSO_HANDLE
#   define HAVE___DSO_HANDLE 1
#  endif
# endif
#endif

#if HAVE___DSO_HANDLE
extern void *__dso_handle __attribute__ ((__visibility__ ("hidden")));
#endif

namespace {

static struct RegisterJIT {
  RegisterJIT() { JIT::Register(); }
} JITRegistrator;

}

namespace llvm {
  void LinkInJIT() {
  }
}


#if defined(__GNUC__) && !defined(__ARM__EABI__)
 
// libgcc defines the __register_frame function to dynamically register new
// dwarf frames for exception handling. This functionality is not portable
// across compilers and is only provided by GCC. We use the __register_frame
// function here so that code generated by the JIT cooperates with the unwinding
// runtime of libgcc. When JITting with exception handling enable, LLVM
// generates dwarf frames and registers it to libgcc with __register_frame.
//
// The __register_frame function works with Linux.
//
// Unfortunately, this functionality seems to be in libgcc after the unwinding
// library of libgcc for darwin was written. The code for darwin overwrites the
// value updated by __register_frame with a value fetched with "keymgr".
// "keymgr" is an obsolete functionality, which should be rewritten some day.
// In the meantime, since "keymgr" is on all libgccs shipped with apple-gcc, we
// need a workaround in LLVM which uses the "keymgr" to dynamically modify the
// values of an opaque key, used by libgcc to find dwarf tables.

extern "C" void __register_frame(void*);

#if defined(__APPLE__) && MAC_OS_X_VERSION_MAX_ALLOWED <= 1050
# define USE_KEYMGR 1
#else
# define USE_KEYMGR 0
#endif

#if USE_KEYMGR

namespace {

// LibgccObject - This is the structure defined in libgcc. There is no #include
// provided for this structure, so we also define it here. libgcc calls it
// "struct object". The structure is undocumented in libgcc.
struct LibgccObject {
  void *unused1;
  void *unused2;
  void *unused3;
  
  /// frame - Pointer to the exception table.
  void *frame;
  
  /// encoding -  The encoding of the object?
  union {
    struct {
      unsigned long sorted : 1;
      unsigned long from_array : 1;
      unsigned long mixed_encoding : 1;
      unsigned long encoding : 8;
      unsigned long count : 21; 
    } b;
    size_t i;
  } encoding;
  
  /// fde_end - libgcc defines this field only if some macro is defined. We
  /// include this field even if it may not there, to make libgcc happy.
  char *fde_end;
  
  /// next - At least we know it's a chained list!
  struct LibgccObject *next;
};

// "kemgr" stuff. Apparently, all frame tables are stored there.
extern "C" void _keymgr_set_and_unlock_processwide_ptr(int, void *);
extern "C" void *_keymgr_get_and_lock_processwide_ptr(int);
#define KEYMGR_GCC3_DW2_OBJ_LIST        302     /* Dwarf2 object list  */

/// LibgccObjectInfo - libgcc defines this struct as km_object_info. It
/// probably contains all dwarf tables that are loaded.
struct LibgccObjectInfo {

  /// seenObjects - LibgccObjects already parsed by the unwinding runtime.
  ///
  struct LibgccObject* seenObjects;

  /// unseenObjects - LibgccObjects not parsed yet by the unwinding runtime.
  ///
  struct LibgccObject* unseenObjects;
  
  unsigned unused[2];
};

/// darwin_register_frame - Since __register_frame does not work with darwin's
/// libgcc,we provide our own function, which "tricks" libgcc by modifying the
/// "Dwarf2 object list" key.
void DarwinRegisterFrame(void* FrameBegin) {
  // Get the key.
  LibgccObjectInfo* LOI = (struct LibgccObjectInfo*)
    _keymgr_get_and_lock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST);
  assert(LOI && "This should be preallocated by the runtime");
  
  // Allocate a new LibgccObject to represent this frame. Deallocation of this
  // object may be impossible: since darwin code in libgcc was written after
  // the ability to dynamically register frames, things may crash if we
  // deallocate it.
  struct LibgccObject* ob = (struct LibgccObject*)
    malloc(sizeof(struct LibgccObject));
  
  // Do like libgcc for the values of the field.
  ob->unused1 = (void *)-1;
  ob->unused2 = 0;
  ob->unused3 = 0;
  ob->frame = FrameBegin;
  ob->encoding.i = 0; 
  ob->encoding.b.encoding = llvm::dwarf::DW_EH_PE_omit;
  
  // Put the info on both places, as libgcc uses the first or the the second
  // field. Note that we rely on having two pointers here. If fde_end was a
  // char, things would get complicated.
  ob->fde_end = (char*)LOI->unseenObjects;
  ob->next = LOI->unseenObjects;
  
  // Update the key's unseenObjects list.
  LOI->unseenObjects = ob;
  
  // Finally update the "key". Apparently, libgcc requires it. 
  _keymgr_set_and_unlock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST,
                                         LOI);

}

}
#endif // __APPLE__
#endif // __GNUC__

/// createJIT - This is the factory method for creating a JIT for the current
/// machine, it does not fall back to the interpreter.  This takes ownership
/// of the module provider.
ExecutionEngine *ExecutionEngine::createJIT(ModuleProvider *MP,
                                            std::string *ErrorStr,
                                            JITMemoryManager *JMM,
                                            unsigned OptLevel) {
  ExecutionEngine *EE = JIT::createJIT(MP, ErrorStr, JMM, OptLevel);
  if (!EE) return 0;
  
  // Make sure we can resolve symbols in the program as well. The zero arg
  // to the function tells DynamicLibrary to load the program, not a library.
  sys::DynamicLibrary::LoadLibraryPermanently(0, ErrorStr);
  return EE;
}

JIT::JIT(ModuleProvider *MP, TargetMachine &tm, TargetJITInfo &tji,
         JITMemoryManager *JMM, unsigned OptLevel)
  : ExecutionEngine(MP), TM(tm), TJI(tji) {
  setTargetData(TM.getTargetData());

  jitstate = new JITState(MP);

  // Initialize MCE
  MCE = createEmitter(*this, JMM);

  // Add target data
  MutexGuard locked(lock);
  FunctionPassManager &PM = jitstate->getPM(locked);
  PM.add(new TargetData(*TM.getTargetData()));

  // Turn the machine code intermediate representation into bytes in memory that
  // may be executed.
  if (TM.addPassesToEmitMachineCode(PM, *MCE, OptLevel)) {
    cerr << "Target does not support machine code emission!\n";
    abort();
  }
  
  // Register routine for informing unwinding runtime about new EH frames
#if defined(__GNUC__) && !defined(__ARM_EABI__)
#if USE_KEYMGR
  struct LibgccObjectInfo* LOI = (struct LibgccObjectInfo*)
    _keymgr_get_and_lock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST);
  
  // The key is created on demand, and libgcc creates it the first time an
  // exception occurs. Since we need the key to register frames, we create
  // it now.
  if (!LOI)
    LOI = (LibgccObjectInfo*)calloc(sizeof(struct LibgccObjectInfo), 1); 
  _keymgr_set_and_unlock_processwide_ptr(KEYMGR_GCC3_DW2_OBJ_LIST, LOI);
  InstallExceptionTableRegister(DarwinRegisterFrame);
#else
  InstallExceptionTableRegister(__register_frame);
#endif // __APPLE__
#endif // __GNUC__
  
  // Initialize passes.
  PM.doInitialization();
}

JIT::~JIT() {
  delete jitstate;
  delete MCE;
  delete &TM;
}

/// addModuleProvider - Add a new ModuleProvider to the JIT.  If we previously
/// removed the last ModuleProvider, we need re-initialize jitstate with a valid
/// ModuleProvider.
void JIT::addModuleProvider(ModuleProvider *MP) {
  MutexGuard locked(lock);

  if (Modules.empty()) {
    assert(!jitstate && "jitstate should be NULL if Modules vector is empty!");

    jitstate = new JITState(MP);

    FunctionPassManager &PM = jitstate->getPM(locked);
    PM.add(new TargetData(*TM.getTargetData()));

    // Turn the machine code intermediate representation into bytes in memory
    // that may be executed.
    if (TM.addPassesToEmitMachineCode(PM, *MCE, 3 /* OptLevel */)) {
      cerr << "Target does not support machine code emission!\n";
      abort();
    }
    
    // Initialize passes.
    PM.doInitialization();
  }
  
  ExecutionEngine::addModuleProvider(MP);
}

/// removeModuleProvider - If we are removing the last ModuleProvider, 
/// invalidate the jitstate since the PassManager it contains references a
/// released ModuleProvider.
Module *JIT::removeModuleProvider(ModuleProvider *MP, std::string *E) {
  Module *result = ExecutionEngine::removeModuleProvider(MP, E);
  
  MutexGuard locked(lock);
  
  if (jitstate->getMP() == MP) {
    delete jitstate;
    jitstate = 0;
  }
  
  if (!jitstate && !Modules.empty()) {
    jitstate = new JITState(Modules[0]);

    FunctionPassManager &PM = jitstate->getPM(locked);
    PM.add(new TargetData(*TM.getTargetData()));
    
    // Turn the machine code intermediate representation into bytes in memory
    // that may be executed.
    if (TM.addPassesToEmitMachineCode(PM, *MCE, 3 /* OptLevel */)) {
      cerr << "Target does not support machine code emission!\n";
      abort();
    }
    
    // Initialize passes.
    PM.doInitialization();
  }    
  return result;
}

/// deleteModuleProvider - Remove a ModuleProvider from the list of modules,
/// and deletes the ModuleProvider and owned Module.  Avoids materializing 
/// the underlying module.
void JIT::deleteModuleProvider(ModuleProvider *MP, std::string *E) {
  ExecutionEngine::deleteModuleProvider(MP, E);
  
  MutexGuard locked(lock);
  
  if (jitstate->getMP() == MP) {
    delete jitstate;
    jitstate = 0;
  }

  if (!jitstate && !Modules.empty()) {
    jitstate = new JITState(Modules[0]);
    
    FunctionPassManager &PM = jitstate->getPM(locked);
    PM.add(new TargetData(*TM.getTargetData()));
    
    // Turn the machine code intermediate representation into bytes in memory
    // that may be executed.
    if (TM.addPassesToEmitMachineCode(PM, *MCE, 3 /* OptLevel */)) {
      cerr << "Target does not support machine code emission!\n";
      abort();
    }
    
    // Initialize passes.
    PM.doInitialization();
  }    
}

/// run - Start execution with the specified function and arguments.
///
GenericValue JIT::runFunction(Function *F,
                              const std::vector<GenericValue> &ArgValues) {
  assert(F && "Function *F was null at entry to run()");

  void *FPtr = getPointerToFunction(F);
  assert(FPtr && "Pointer to fn's code was null after getPointerToFunction");
  const FunctionType *FTy = F->getFunctionType();
  const Type *RetTy = FTy->getReturnType();

  assert((FTy->getNumParams() == ArgValues.size() ||
          (FTy->isVarArg() && FTy->getNumParams() <= ArgValues.size())) &&
         "Wrong number of arguments passed into function!");
  assert(FTy->getNumParams() == ArgValues.size() &&
         "This doesn't support passing arguments through varargs (yet)!");

  // Handle some common cases first.  These cases correspond to common `main'
  // prototypes.
  if (RetTy == Type::Int32Ty || RetTy == Type::VoidTy) {
    switch (ArgValues.size()) {
    case 3:
      if (FTy->getParamType(0) == Type::Int32Ty &&
          isa<PointerType>(FTy->getParamType(1)) &&
          isa<PointerType>(FTy->getParamType(2))) {
        int (*PF)(int, char **, const char **) =
          (int(*)(int, char **, const char **))(intptr_t)FPtr;

        // Call the function.
        GenericValue rv;
        rv.IntVal = APInt(32, PF(ArgValues[0].IntVal.getZExtValue(), 
                                 (char **)GVTOP(ArgValues[1]),
                                 (const char **)GVTOP(ArgValues[2])));
        return rv;
      }
      break;
    case 2:
      if (FTy->getParamType(0) == Type::Int32Ty &&
          isa<PointerType>(FTy->getParamType(1))) {
        int (*PF)(int, char **) = (int(*)(int, char **))(intptr_t)FPtr;

        // Call the function.
        GenericValue rv;
        rv.IntVal = APInt(32, PF(ArgValues[0].IntVal.getZExtValue(), 
                                 (char **)GVTOP(ArgValues[1])));
        return rv;
      }
      break;
    case 1:
      if (FTy->getNumParams() == 1 &&
          FTy->getParamType(0) == Type::Int32Ty) {
        GenericValue rv;
        int (*PF)(int) = (int(*)(int))(intptr_t)FPtr;
        rv.IntVal = APInt(32, PF(ArgValues[0].IntVal.getZExtValue()));
        return rv;
      }
      break;
    }
  }

  // Handle cases where no arguments are passed first.
  if (ArgValues.empty()) {
    GenericValue rv;
    switch (RetTy->getTypeID()) {
    default: assert(0 && "Unknown return type for function call!");
    case Type::IntegerTyID: {
      unsigned BitWidth = cast<IntegerType>(RetTy)->getBitWidth();
      if (BitWidth == 1)
        rv.IntVal = APInt(BitWidth, ((bool(*)())(intptr_t)FPtr)());
      else if (BitWidth <= 8)
        rv.IntVal = APInt(BitWidth, ((char(*)())(intptr_t)FPtr)());
      else if (BitWidth <= 16)
        rv.IntVal = APInt(BitWidth, ((short(*)())(intptr_t)FPtr)());
      else if (BitWidth <= 32)
        rv.IntVal = APInt(BitWidth, ((int(*)())(intptr_t)FPtr)());
      else if (BitWidth <= 64)
        rv.IntVal = APInt(BitWidth, ((int64_t(*)())(intptr_t)FPtr)());
      else 
        assert(0 && "Integer types > 64 bits not supported");
      return rv;
    }
    case Type::VoidTyID:
      rv.IntVal = APInt(32, ((int(*)())(intptr_t)FPtr)());
      return rv;
    case Type::FloatTyID:
      rv.FloatVal = ((float(*)())(intptr_t)FPtr)();
      return rv;
    case Type::DoubleTyID:
      rv.DoubleVal = ((double(*)())(intptr_t)FPtr)();
      return rv;
    case Type::X86_FP80TyID:
    case Type::FP128TyID:
    case Type::PPC_FP128TyID:
      assert(0 && "long double not supported yet");
      return rv;
    case Type::PointerTyID:
      return PTOGV(((void*(*)())(intptr_t)FPtr)());
    }
  }

  // Okay, this is not one of our quick and easy cases.  Because we don't have a
  // full FFI, we have to codegen a nullary stub function that just calls the
  // function we are interested in, passing in constants for all of the
  // arguments.  Make this function and return.

  // First, create the function.
  FunctionType *STy=FunctionType::get(RetTy, std::vector<const Type*>(), false);
  Function *Stub = Function::Create(STy, Function::InternalLinkage, "",
                                    F->getParent());

  // Insert a basic block.
  BasicBlock *StubBB = BasicBlock::Create("", Stub);

  // Convert all of the GenericValue arguments over to constants.  Note that we
  // currently don't support varargs.
  SmallVector<Value*, 8> Args;
  for (unsigned i = 0, e = ArgValues.size(); i != e; ++i) {
    Constant *C = 0;
    const Type *ArgTy = FTy->getParamType(i);
    const GenericValue &AV = ArgValues[i];
    switch (ArgTy->getTypeID()) {
    default: assert(0 && "Unknown argument type for function call!");
    case Type::IntegerTyID:
        C = ConstantInt::get(AV.IntVal);
        break;
    case Type::FloatTyID:
        C = ConstantFP::get(APFloat(AV.FloatVal));
        break;
    case Type::DoubleTyID:
        C = ConstantFP::get(APFloat(AV.DoubleVal));
        break;
    case Type::PPC_FP128TyID:
    case Type::X86_FP80TyID:
    case Type::FP128TyID:
        C = ConstantFP::get(APFloat(AV.IntVal));
        break;
    case Type::PointerTyID:
      void *ArgPtr = GVTOP(AV);
      if (sizeof(void*) == 4)
        C = ConstantInt::get(Type::Int32Ty, (int)(intptr_t)ArgPtr);
      else
        C = ConstantInt::get(Type::Int64Ty, (intptr_t)ArgPtr);
      C = ConstantExpr::getIntToPtr(C, ArgTy);  // Cast the integer to pointer
      break;
    }
    Args.push_back(C);
  }

  CallInst *TheCall = CallInst::Create(F, Args.begin(), Args.end(),
                                       "", StubBB);
  TheCall->setCallingConv(F->getCallingConv());
  TheCall->setTailCall();
  if (TheCall->getType() != Type::VoidTy)
    ReturnInst::Create(TheCall, StubBB);    // Return result of the call.
  else
    ReturnInst::Create(StubBB);             // Just return void.

  // Finally, return the value returned by our nullary stub function.
  return runFunction(Stub, std::vector<GenericValue>());
}

/// runJITOnFunction - Run the FunctionPassManager full of
/// just-in-time compilation passes on F, hopefully filling in
/// GlobalAddress[F] with the address of F's machine code.
///
void JIT::runJITOnFunction(Function *F) {
  MutexGuard locked(lock);
  runJITOnFunctionUnlocked(F, locked);
}

void JIT::runJITOnFunctionUnlocked(Function *F, const MutexGuard &locked) {
  static bool isAlreadyCodeGenerating = false;
  assert(!isAlreadyCodeGenerating && "Error: Recursive compilation detected!");

  // JIT the function
  isAlreadyCodeGenerating = true;
  jitstate->getPM(locked).run(*F);
  isAlreadyCodeGenerating = false;

  // If the function referred to another function that had not yet been
  // read from bitcode, but we are jitting non-lazily, emit it now.
  while (!jitstate->getPendingFunctions(locked).empty()) {
    Function *PF = jitstate->getPendingFunctions(locked).back();
    jitstate->getPendingFunctions(locked).pop_back();

    // JIT the function
    isAlreadyCodeGenerating = true;
    jitstate->getPM(locked).run(*PF);
    isAlreadyCodeGenerating = false;
    
    // Now that the function has been jitted, ask the JITEmitter to rewrite
    // the stub with real address of the function.
    updateFunctionStub(PF);
  }
  
  // If the JIT is configured to emit info so that dlsym can be used to
  // rewrite stubs to external globals, do so now.
  if (areDlsymStubsEnabled() && isLazyCompilationDisabled())
    updateDlsymStubTable();
}

/// getPointerToFunction - This method is used to get the address of the
/// specified function, compiling it if neccesary.
///
void *JIT::getPointerToFunction(Function *F) {

  if (void *Addr = getPointerToGlobalIfAvailable(F))
    return Addr;   // Check if function already code gen'd

  MutexGuard locked(lock);

  // Make sure we read in the function if it exists in this Module.
  if (F->hasNotBeenReadFromBitcode()) {
    // Determine the module provider this function is provided by.
    Module *M = F->getParent();
    ModuleProvider *MP = 0;
    for (unsigned i = 0, e = Modules.size(); i != e; ++i) {
      if (Modules[i]->getModule() == M) {
        MP = Modules[i];
        break;
      }
    }
    assert(MP && "Function isn't in a module we know about!");
    
    std::string ErrorMsg;
    if (MP->materializeFunction(F, &ErrorMsg)) {
      cerr << "Error reading function '" << F->getName()
           << "' from bitcode file: " << ErrorMsg << "\n";
      abort();
    }

    // Now retry to get the address.
    if (void *Addr = getPointerToGlobalIfAvailable(F))
      return Addr;
  }

  if (F->isDeclaration()) {
    bool AbortOnFailure =
      !areDlsymStubsEnabled() && !F->hasExternalWeakLinkage();
    void *Addr = getPointerToNamedFunction(F->getName(), AbortOnFailure);
    addGlobalMapping(F, Addr);
    return Addr;
  }

  runJITOnFunctionUnlocked(F, locked);

  void *Addr = getPointerToGlobalIfAvailable(F);
  assert(Addr && "Code generation didn't add function to GlobalAddress table!");
  return Addr;
}

/// getOrEmitGlobalVariable - Return the address of the specified global
/// variable, possibly emitting it to memory if needed.  This is used by the
/// Emitter.
void *JIT::getOrEmitGlobalVariable(const GlobalVariable *GV) {
  MutexGuard locked(lock);

  void *Ptr = getPointerToGlobalIfAvailable(GV);
  if (Ptr) return Ptr;

  // If the global is external, just remember the address.
  if (GV->isDeclaration()) {
#if HAVE___DSO_HANDLE
    if (GV->getName() == "__dso_handle")
      return (void*)&__dso_handle;
#endif
    Ptr = sys::DynamicLibrary::SearchForAddressOfSymbol(GV->getName().c_str());
    if (Ptr == 0 && !areDlsymStubsEnabled()) {
      cerr << "Could not resolve external global address: "
           << GV->getName() << "\n";
      abort();
    }
    addGlobalMapping(GV, Ptr);
  } else {
    // GlobalVariable's which are not "constant" will cause trouble in a server
    // situation. It's returned in the same block of memory as code which may
    // not be writable.
    if (isGVCompilationDisabled() && !GV->isConstant()) {
      cerr << "Compilation of non-internal GlobalValue is disabled!\n";
      abort();
    }
    // If the global hasn't been emitted to memory yet, allocate space and
    // emit it into memory.  It goes in the same array as the generated
    // code, jump tables, etc.
    const Type *GlobalType = GV->getType()->getElementType();
    size_t S = getTargetData()->getTypePaddedSize(GlobalType);
    size_t A = getTargetData()->getPreferredAlignment(GV);
    if (GV->isThreadLocal()) {
      MutexGuard locked(lock);
      Ptr = TJI.allocateThreadLocalMemory(S);
    } else if (TJI.allocateSeparateGVMemory()) {
      if (A <= 8) {
        Ptr = malloc(S);
      } else {
        // Allocate S+A bytes of memory, then use an aligned pointer within that
        // space.
        Ptr = malloc(S+A);
        unsigned MisAligned = ((intptr_t)Ptr & (A-1));
        Ptr = (char*)Ptr + (MisAligned ? (A-MisAligned) : 0);
      }
    } else {
      Ptr = MCE->allocateSpace(S, A);
    }
    addGlobalMapping(GV, Ptr);
    EmitGlobalVariable(GV);
  }
  return Ptr;
}

/// recompileAndRelinkFunction - This method is used to force a function
/// which has already been compiled, to be compiled again, possibly
/// after it has been modified. Then the entry to the old copy is overwritten
/// with a branch to the new copy. If there was no old copy, this acts
/// just like JIT::getPointerToFunction().
///
void *JIT::recompileAndRelinkFunction(Function *F) {
  void *OldAddr = getPointerToGlobalIfAvailable(F);

  // If it's not already compiled there is no reason to patch it up.
  if (OldAddr == 0) { return getPointerToFunction(F); }

  // Delete the old function mapping.
  addGlobalMapping(F, 0);

  // Recodegen the function
  runJITOnFunction(F);

  // Update state, forward the old function to the new function.
  void *Addr = getPointerToGlobalIfAvailable(F);
  assert(Addr && "Code generation didn't add function to GlobalAddress table!");
  TJI.replaceMachineCodeForFunction(OldAddr, Addr);
  return Addr;
}

/// getMemoryForGV - This method abstracts memory allocation of global
/// variable so that the JIT can allocate thread local variables depending
/// on the target.
///
char* JIT::getMemoryForGV(const GlobalVariable* GV) {
  const Type *ElTy = GV->getType()->getElementType();
  size_t GVSize = (size_t)getTargetData()->getTypePaddedSize(ElTy);
  if (GV->isThreadLocal()) {
    MutexGuard locked(lock);
    return TJI.allocateThreadLocalMemory(GVSize);
  } else {
    return new char[GVSize];
  }
}

void JIT::addPendingFunction(Function *F) {
  MutexGuard locked(lock);
  jitstate->getPendingFunctions(locked).push_back(F);
}
