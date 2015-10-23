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

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MD5.h"
#include <cstdint>
#include <list>
#include <system_error>
#include <vector>

namespace llvm {

/// Return the name of data section containing profile counter variables.
inline StringRef getInstrProfCountersSectionName(bool AddSegment) {
  return AddSegment ? "__DATA,__llvm_prf_cnts" : "__llvm_prf_cnts";
}

/// Return the name of data section containing names of instrumented
/// functions.
inline StringRef getInstrProfNameSectionName(bool AddSegment) {
  return AddSegment ? "__DATA,__llvm_prf_names" : "__llvm_prf_names";
}

/// Return the name of the data section containing per-function control
/// data.
inline StringRef getInstrProfDataSectionName(bool AddSegment) {
  return AddSegment ? "__DATA,__llvm_prf_data" : "__llvm_prf_data";
}

/// Return the name of the section containing function coverage mapping
/// data.
inline StringRef getInstrProfCoverageSectionName(bool AddSegment) {
  return AddSegment ? "__DATA,__llvm_covmap" : "__llvm_covmap";
}

/// Return the name prefix of variables containing instrumented function names.
inline StringRef getInstrProfNameVarPrefix() { return "__llvm_profile_name_"; }

/// Return the name prefix of variables containing per-function control data.
inline StringRef getInstrProfDataVarPrefix() { return "__llvm_profile_data_"; }

/// Return the name prefix of profile counter variables.
inline StringRef getInstrProfCountersVarPrefix() {
  return "__llvm_profile_counters_";
}

/// Return the name prefix of the COMDAT group for instrumentation variables
/// associated with a COMDAT function.
inline StringRef getInstrProfComdatPrefix() { return "__llvm_profile_vars_"; }

/// Return the name of a covarage mapping variable (internal linkage) 
/// for each instrumented source module. Such variables are allocated
/// in the __llvm_covmap section.
inline StringRef getCoverageMappingVarName() {
  return "__llvm_coverage_mapping";
}

/// Return the name of function that registers all the per-function control
/// data at program startup time by calling __llvm_register_function. This
/// function has internal linkage and is called by  __llvm_profile_init
/// runtime method. This function is not generated for these platforms:
/// Darwin, Linux, and FreeBSD.
inline StringRef getInstrProfRegFuncsName() {
  return "__llvm_profile_register_functions";
}

/// Return the name of the runtime interface that registers per-function control
/// data for one instrumented function.
inline StringRef getInstrProfRegFuncName() {
  return "__llvm_profile_register_function";
}

/// Return the name of the runtime initialization method that is generated by
/// the compiler. The function calls __llvm_profile_register_functions and
/// __llvm_profile_override_default_filename functions if needed. This function
/// has internal linkage and invoked at startup time via init_array.
inline StringRef getInstrProfInitFuncName() { return "__llvm_profile_init"; }

/// Return the name of the hook variable defined in profile runtime library.
/// A reference to the variable causes the linker to link in the runtime
/// initialization module (which defines the hook variable).
inline StringRef getInstrProfRuntimeHookVarName() {
  return "__llvm_profile_runtime";
}

/// Return the name of the compiler generated function that references the
/// runtime hook variable. The function is a weak global.
inline StringRef getInstrProfRuntimeHookVarUseFuncName() {
  return "__llvm_profile_runtime_user";
}

/// Return the name of the profile runtime interface that overrides the default
/// profile data file name.
inline StringRef getInstrProfFileOverriderFuncName() {
  return "__llvm_profile_override_default_filename";
}

const std::error_category &instrprof_category();

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
  counter_overflow,
  value_site_count_mismatch
};

inline std::error_code make_error_code(instrprof_error E) {
  return std::error_code(static_cast<int>(E), instrprof_category());
}

enum InstrProfValueKind : uint32_t {
  IPVK_IndirectCallTarget = 0,

  IPVK_First = IPVK_IndirectCallTarget,
  IPVK_Last = IPVK_IndirectCallTarget
};

struct InstrProfStringTable {
  // Set of string values in profiling data.
  StringSet<> StringValueSet;
  InstrProfStringTable() { StringValueSet.clear(); }
  // Get a pointer to internal storage of a string in set
  const char *getStringData(StringRef Str) {
    auto Result = StringValueSet.find(Str);
    return (Result == StringValueSet.end()) ? nullptr : Result->first().data();
  }
  // Insert a string to StringTable
  const char *insertString(StringRef Str) {
    auto Result = StringValueSet.insert(Str);
    return Result.first->first().data();
  }
};

struct InstrProfValueSiteRecord {
  /// Typedef for a single TargetValue-NumTaken pair.
  typedef std::pair<uint64_t, uint64_t> ValueDataPair;
  /// Value profiling data pairs at a given value site.
  std::list<ValueDataPair> ValueData;

  InstrProfValueSiteRecord() { ValueData.clear(); }

  /// Sort ValueData ascending by TargetValue
  void sortByTargetValues() {
    ValueData.sort([](const ValueDataPair &left, const ValueDataPair &right) {
      return left.first < right.first;
    });
  }

  /// Merge data from another InstrProfValueSiteRecord
  void mergeValueData(InstrProfValueSiteRecord &Input) {
    this->sortByTargetValues();
    Input.sortByTargetValues();
    auto I = ValueData.begin();
    auto IE = ValueData.end();
    for (auto J = Input.ValueData.begin(), JE = Input.ValueData.end(); J != JE;
         ++J) {
      while (I != IE && I->first < J->first)
        ++I;
      if (I != IE && I->first == J->first) {
        I->second += J->second;
        ++I;
        continue;
      }
      ValueData.insert(I, *J);
    }
  }
};

/// Profiling information for a single function.
struct InstrProfRecord {
  InstrProfRecord() {}
  InstrProfRecord(StringRef Name, uint64_t Hash, std::vector<uint64_t> Counts)
      : Name(Name), Hash(Hash), Counts(std::move(Counts)) {}
  StringRef Name;
  uint64_t Hash;
  std::vector<uint64_t> Counts;
  std::vector<InstrProfValueSiteRecord> IndirectCallSites;

  const std::vector<InstrProfValueSiteRecord> &
  getValueSitesForKind(uint32_t ValueKind) const {
    switch (ValueKind) {
    case IPVK_IndirectCallTarget:
      return IndirectCallSites;
    }
    llvm_unreachable("Unknown value kind!");
  }

  std::vector<InstrProfValueSiteRecord> &
  getValueSitesForKind(uint32_t ValueKind) {
    return const_cast<std::vector<InstrProfValueSiteRecord> &>(
        const_cast<const InstrProfRecord *>(this)
            ->getValueSitesForKind(ValueKind));
  }
};

namespace IndexedInstrProf {
enum class HashT : uint32_t {
  MD5,

  Last = MD5
};

static inline uint64_t MD5Hash(StringRef Str) {
  MD5 Hash;
  Hash.update(Str);
  llvm::MD5::MD5Result Result;
  Hash.final(Result);
  // Return the least significant 8 bytes. Our MD5 implementation returns the
  // result in little endian, so we may need to swap bytes.
  using namespace llvm::support;
  return endian::read<uint64_t, little, unaligned>(Result);
}

static inline uint64_t ComputeHash(HashT Type, StringRef K) {
  switch (Type) {
    case HashT::MD5:
      return IndexedInstrProf::MD5Hash(K);
  }
  llvm_unreachable("Unhandled hash type");
}

const uint64_t Magic = 0x8169666f72706cff;  // "\xfflprofi\x81"
const uint64_t Version = 3;
const HashT HashType = HashT::MD5;

struct Header {
  uint64_t Magic;
  uint64_t Version;
  uint64_t MaxFunctionCount;
  uint64_t HashType;
  uint64_t HashOffset;
};

}  // end namespace IndexedInstrProf

namespace RawInstrProf {

const uint64_t Version = 1;

// Magic number to detect file format and endianness.
// Use 255 at one end, since no UTF-8 file can use that character.  Avoid 0,
// so that utilities, like strings, don't grab it as a string.  129 is also
// invalid UTF-8, and high enough to be interesting.
// Use "lprofr" in the centre to stand for "LLVM Profile Raw", or "lprofR"
// for 32-bit platforms.
// The magic and version need to be kept in sync with
// projects/compiler-rt/lib/profile/InstrProfiling.c

template <class IntPtrT>
inline uint64_t getMagic();
template <>
inline uint64_t getMagic<uint64_t>() {
  return uint64_t(255) << 56 | uint64_t('l') << 48 | uint64_t('p') << 40 |
         uint64_t('r') << 32 | uint64_t('o') << 24 | uint64_t('f') << 16 |
         uint64_t('r') << 8 | uint64_t(129);
}

template <>
inline uint64_t getMagic<uint32_t>() {
  return uint64_t(255) << 56 | uint64_t('l') << 48 | uint64_t('p') << 40 |
         uint64_t('r') << 32 | uint64_t('o') << 24 | uint64_t('f') << 16 |
         uint64_t('R') << 8 | uint64_t(129);
}

// The definition should match the structure defined in
// compiler-rt/lib/profile/InstrProfiling.h.
// It should also match the synthesized type in
// Transforms/Instrumentation/InstrProfiling.cpp:getOrCreateRegionCounters.

template <class IntPtrT>
struct ProfileData {
  const uint32_t NameSize;
  const uint32_t NumCounters;
  const uint64_t FuncHash;
  const IntPtrT NamePtr;
  const IntPtrT CounterPtr;
};

// The definition should match the header referenced in
// compiler-rt/lib/profile/InstrProfilingFile.c  and
// InstrProfilingBuffer.c.

struct Header {
  const uint64_t Magic;
  const uint64_t Version;
  const uint64_t DataSize;
  const uint64_t CountersSize;
  const uint64_t NamesSize;
  const uint64_t CountersDelta;
  const uint64_t NamesDelta;
};

}  // end namespace RawInstrProf

} // end namespace llvm

namespace std {
template <>
struct is_error_code_enum<llvm::instrprof_error> : std::true_type {};
}

#endif // LLVM_PROFILEDATA_INSTRPROF_H_
