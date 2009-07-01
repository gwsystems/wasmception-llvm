//===-LTOModule.h - LLVM Link Time Optimizer ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This file declares the LTOModule class. 
//
//===----------------------------------------------------------------------===//

#ifndef LTO_MODULE_H
#define LTO_MODULE_H

#include "llvm/Module.h"
#include "llvm/ADT/OwningPtr.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/ADT/StringMap.h"

#include "llvm-c/lto.h"

#include <vector>
#include <string>


// forward references to llvm classes
namespace llvm {
    class Mangler;
    class MemoryBuffer;
    class GlobalValue;
    class Value;
    class Function;
    class LLVMContext;
}


//
// C++ class which implements the opaque lto_module_t
//
class LTOModule {
public:

    static bool              isBitcodeFile(const void* mem, size_t length);
    static bool              isBitcodeFile(const char* path);

    static bool              isBitcodeFileForTarget(const void* mem, 
                                    size_t length, const char* triplePrefix);

    static bool              isBitcodeFileForTarget(const char* path, 
                                                    const char* triplePrefix);

    static LTOModule*        makeLTOModule(const char* path,
                                          llvm::LLVMContext* Context,
                                          std::string& errMsg);
    static LTOModule*        makeLTOModule(const void* mem, size_t length,
                                           llvm::LLVMContext* Context,
                                           std::string& errMsg);

    const char*              getTargetTriple();
    uint32_t                 getSymbolCount();
    lto_symbol_attributes    getSymbolAttributes(uint32_t index);
    const char*              getSymbolName(uint32_t index);
    
    llvm::Module *           getLLVVMModule() { return _module.get(); }

private:
                            LTOModule(llvm::Module* m, llvm::TargetMachine* t);

    void                    lazyParseSymbols();
    void                    addDefinedSymbol(llvm::GlobalValue* def, 
                                                    llvm::Mangler& mangler, 
                                                    bool isFunction);
    void                    addPotentialUndefinedSymbol(llvm::GlobalValue* decl, 
                                                        llvm::Mangler &mangler);
    void                    findExternalRefs(llvm::Value* value, 
                                                llvm::Mangler& mangler);
    void                    addDefinedFunctionSymbol(llvm::Function* f, 
                                                        llvm::Mangler &mangler);
    void                    addDefinedDataSymbol(llvm::GlobalValue* v, 
                                                        llvm::Mangler &mangler);
    void                    addAsmGlobalSymbol(const char *);
    void                    addObjCClass(llvm::GlobalVariable* clgv);
    void                    addObjCCategory(llvm::GlobalVariable* clgv);
    void                    addObjCClassRef(llvm::GlobalVariable* clgv);
    bool                    objcClassNameFromExpression(llvm::Constant* c, 
                                                    std::string& name);

    static bool             isTargetMatch(llvm::MemoryBuffer* memBuffer,
                                                    const char* triplePrefix);

    static LTOModule*       makeLTOModule(llvm::MemoryBuffer* buffer,
                                          llvm::LLVMContext* Context,
                                                        std::string& errMsg);
    static llvm::MemoryBuffer* makeBuffer(const void* mem, size_t length);

    typedef llvm::StringMap<uint8_t> StringSet;
    
    struct NameAndAttributes { 
        const char*            name; 
        lto_symbol_attributes  attributes; 
    };

    llvm::OwningPtr<llvm::Module>           _module;
    llvm::OwningPtr<llvm::TargetMachine>    _target;
    bool                                    _symbolsParsed;
    std::vector<NameAndAttributes>          _symbols;
    // _defines and _undefines only needed to disambiguate tentative definitions
    StringSet                               _defines;    
    llvm::StringMap<NameAndAttributes>      _undefines;
};

extern std::string getFeatureString(const char *TargetTriple);

#endif // LTO_MODULE_H

