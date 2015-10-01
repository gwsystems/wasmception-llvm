//===- FuzzerInternal.h - Internal header for the Fuzzer --------*- C++ -* ===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Define the main class fuzzer::Fuzzer and most functions.
//===----------------------------------------------------------------------===//

#ifndef LLVM_FUZZER_INTERNAL_H
#define LLVM_FUZZER_INTERNAL_H

#include <cassert>
#include <climits>
#include <chrono>
#include <cstddef>
#include <cstdlib>
#include <string>
#include <vector>
#include <unordered_set>

#include "FuzzerInterface.h"

namespace fuzzer {
typedef std::vector<uint8_t> Unit;
using namespace std::chrono;

std::string FileToString(const std::string &Path);
Unit FileToVector(const std::string &Path);
void ReadDirToVectorOfUnits(const char *Path, std::vector<Unit> *V,
                            long *Epoch);
void WriteToFile(const Unit &U, const std::string &Path);
void CopyFileToErr(const std::string &Path);
// Returns "Dir/FileName" or equivalent for the current OS.
std::string DirPlusFile(const std::string &DirPath,
                        const std::string &FileName);

void Printf(const char *Fmt, ...);
void Print(const Unit &U, const char *PrintAfter = "");
void PrintASCII(const Unit &U, const char *PrintAfter = "");
std::string Hash(const Unit &U);
void SetTimer(int Seconds);
void PrintFileAsBase64(const std::string &Path);
void ExecuteCommand(const std::string &Command);

// Private copy of SHA1 implementation.
static const int kSHA1NumBytes = 20;
// Computes SHA1 hash of 'Len' bytes in 'Data', writes kSHA1NumBytes to 'Out'.
void ComputeSHA1(const uint8_t *Data, size_t Len, uint8_t *Out);

// Changes U to contain only ASCII (isprint+isspace) characters.
// Returns true iff U has been changed.
bool ToASCII(Unit &U);
bool IsASCII(const Unit &U);

int NumberOfCpuCores();

// Dictionary.

// Parses one dictionary entry.
// If successfull, write the enty to Unit and returns true,
// otherwise returns false.
bool ParseOneDictionaryEntry(const std::string &Str, Unit *U);
// Parses the dictionary file, fills Units, returns true iff all lines
// were parsed succesfully.
bool ParseDictionaryFile(const std::string &Text, std::vector<Unit> *Units);

class Fuzzer {
 public:
  struct FuzzingOptions {
    int Verbosity = 1;
    int MaxLen = 0;
    int UnitTimeoutSec = 300;
    bool DoCrossOver = true;
    int  MutateDepth = 5;
    bool ExitOnFirst = false;
    bool UseCounters = false;
    bool UseTraces = false;
    bool UseFullCoverageSet  = false;
    bool Reload = true;
    int PreferSmallDuringInitialShuffle = -1;
    size_t MaxNumberOfRuns = ULONG_MAX;
    int SyncTimeout = 600;
    int ReportSlowUnits = 10;
    bool OnlyASCII = false;
    int TBMDepth = 10;
    int TBMWidth = 10;
    std::string OutputCorpus;
    std::string SyncCommand;
    std::vector<std::string> Tokens;
    std::vector<Unit> Dictionary;
  };
  Fuzzer(UserSuppliedFuzzer &USF, FuzzingOptions Options);
  void AddToCorpus(const Unit &U) { Corpus.push_back(U); }
  void Loop();
  void ShuffleAndMinimize();
  void InitializeTraceState();
  size_t CorpusSize() const { return Corpus.size(); }
  void ReadDir(const std::string &Path, long *Epoch) {
    ReadDirToVectorOfUnits(Path.c_str(), &Corpus, Epoch);
  }
  void RereadOutputCorpus();
  // Save the current corpus to OutputCorpus.
  void SaveCorpus();

  size_t secondsSinceProcessStartUp() {
    return duration_cast<seconds>(system_clock::now() - ProcessStartTime)
        .count();
  }

  size_t getTotalNumberOfRuns() { return TotalNumberOfRuns; }

  static void StaticAlarmCallback();

  Unit SubstituteTokens(const Unit &U) const;
  void ExecuteCallback(const Unit &U);

 private:
  void AlarmCallback();
  void MutateAndTestOne(Unit *U);
  void ReportNewCoverage(size_t NewCoverage, const Unit &U);
  size_t RunOne(const Unit &U);
  void RunOneAndUpdateCorpus(Unit &U);
  size_t RunOneMaximizeTotalCoverage(const Unit &U);
  size_t RunOneMaximizeFullCoverageSet(const Unit &U);
  size_t RunOneMaximizeCoveragePairs(const Unit &U);
  void WriteToOutputCorpus(const Unit &U);
  void WriteUnitToFileWithPrefix(const Unit &U, const char *Prefix);
  void PrintStats(const char *Where, size_t Cov, const char *End = "\n");
  void PrintUnitInASCIIOrTokens(const Unit &U, const char *PrintAfter = "");

  void SyncCorpus();

  // Trace-based fuzzing: we run a unit with some kind of tracing
  // enabled and record potentially useful mutations. Then
  // We apply these mutations one by one to the unit and run it again.

  // Start tracing; forget all previously proposed mutations.
  void StartTraceRecording();
  // Stop tracing and return the number of proposed mutations.
  size_t StopTraceRecording();
  // Apply Idx-th trace-based mutation to U.
  void ApplyTraceBasedMutation(size_t Idx, Unit *U);

  void SetDeathCallback();
  static void StaticDeathCallback();
  void DeathCallback();
  Unit CurrentUnit;

  size_t TotalNumberOfRuns = 0;
  size_t TotalNumberOfExecutedTraceBasedMutations = 0;

  std::vector<Unit> Corpus;
  std::unordered_set<std::string> UnitHashesAddedToCorpus;
  std::unordered_set<uintptr_t> FullCoverageSets;

  // For UseCounters
  std::vector<uint8_t> CounterBitmap;
  size_t TotalBits() {  // Slow. Call it only for printing stats.
    size_t Res = 0;
    for (auto x : CounterBitmap) Res += __builtin_popcount(x);
    return Res;
  }

  UserSuppliedFuzzer &USF;
  FuzzingOptions Options;
  system_clock::time_point ProcessStartTime = system_clock::now();
  system_clock::time_point LastExternalSync = system_clock::now();
  system_clock::time_point UnitStartTime;
  long TimeOfLongestUnitInSeconds = 0;
  long EpochOfLastReadOfOutputCorpus = 0;
};

class SimpleUserSuppliedFuzzer: public UserSuppliedFuzzer {
 public:
  SimpleUserSuppliedFuzzer(FuzzerRandomBase *Rand, UserCallback Callback)
      : UserSuppliedFuzzer(Rand), Callback(Callback) {}
  virtual void TargetFunction(const uint8_t *Data, size_t Size) {
    return Callback(Data, Size);
  }

 private:
  UserCallback Callback;
};

};  // namespace fuzzer

#endif // LLVM_FUZZER_INTERNAL_H
