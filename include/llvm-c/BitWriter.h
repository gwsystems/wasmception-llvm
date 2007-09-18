/*===-- llvm-c/BitWriter.h - BitWriter Library C Interface ------*- C++ -*-===*\
|*                                                                            *|
|*                     The LLVM Compiler Infrastructure                       *|
|*                                                                            *|
|* This file was developed by Gordon Henriksen and is distributed under the   *|
|* University of Illinois Open Source License. See LICENSE.TXT for details.   *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header declares the C interface to libLLVMBitWriter.a, which          *|
|* implements output of the LLVM bitcode format.                              *|
|*                                                                            *|
|* Many exotic languages can interoperate with C code but have a harder time  *|
|* with C++ due to name mangling. So in addition to C, this interface enables *|
|* tools written in such languages.                                           *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/

#ifndef LLVM_C_BITCODEWRITER_H
#define LLVM_C_BITCODEWRITER_H

#include "llvm-c/Core.h"

#ifdef __cplusplus
extern "C" {
#endif


/*===-- Operations on modules ---------------------------------------------===*/

/* Writes a module to an open file descriptor. Returns 0 on success. */ 
int LLVMWriteBitcodeToFileHandle(LLVMModuleRef M, int Handle);

/* Writes a module to the specified path. Returns 0 on success. */ 
int LLVMWriteBitcodeToFile(LLVMModuleRef M, const char *Path);


#ifdef __cplusplus
}
#endif

#endif
