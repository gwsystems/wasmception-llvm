//=-- InstrProf.h - Instrumented profiling format support ---------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Instrumentation-based profiling data is generated by instrumented
// binaries through library functions in compiler-rt, and read by the clang
// frontend to feed PGO.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PROFILEDATA_INSTRPROF_H_
#define LLVM_PROFILEDATA_INSTRPROF_H_

#include "llvm/Support/system_error.h"

namespace llvm {

const error_category &instrprof_category();

enum class instrprof_error {
    success = 0,
    eof,
    bad_magic,
    bad_header,
    unsupported_version,
    unsupported_hash_type,
    too_large,
    truncated,
    malformed,
    unknown_function,
    hash_mismatch,
    count_mismatch,
    counter_overflow
};

inline error_code make_error_code(instrprof_error E) {
  return error_code(static_cast<int>(E), instrprof_category());
}

template <> struct is_error_code_enum<instrprof_error> : std::true_type {};

} // end namespace llvm

#endif // LLVM_PROFILEDATA_INSTRPROF_H_
