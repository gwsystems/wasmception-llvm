//===- GUID.h ---------------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_CODEVIEW_GUID_H
#define LLVM_DEBUGINFO_CODEVIEW_GUID_H

#include <cstdint>
#include <cstring>

namespace llvm {
class raw_ostream;

namespace codeview {

/// This represents the 'GUID' type from windows.h.
struct GUID {
  uint8_t Guid[16];
};

inline bool operator==(const GUID &LHS, const GUID &RHS) {
  return 0 == ::memcmp(LHS.Guid, RHS.Guid, sizeof(LHS.Guid));
}

inline bool operator<(const GUID &LHS, const GUID &RHS) {
  return ::memcmp(LHS.Guid, RHS.Guid, sizeof(LHS.Guid)) < 0;
}

inline bool operator<=(const GUID &LHS, const GUID &RHS) {
  return ::memcmp(LHS.Guid, RHS.Guid, sizeof(LHS.Guid)) <= 0;
}

inline bool operator>(const GUID &LHS, const GUID &RHS) {
  return !(LHS <= RHS);
}

inline bool operator>=(const GUID &LHS, const GUID &RHS) {
  return !(LHS < RHS);
}

inline bool operator!=(const GUID &LHS, const GUID &RHS) {
  return !(LHS == RHS);
}

raw_ostream &operator<<(raw_ostream &OS, const GUID &Guid);

} // namespace codeview
} // namespace llvm

#endif
