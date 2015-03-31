//===- FuzzerDriver.cpp - FuzzerDriver function and flags -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// FuzzerDriver and flag parsing.
//===----------------------------------------------------------------------===//

#include "FuzzerInterface.h"
#include "FuzzerInternal.h"

#include <cstring>
#include <unistd.h>
#include <iostream>
#include <thread>
#include <atomic>
#include <mutex>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>

namespace fuzzer {

// Program arguments.
struct FlagDescription {
  const char *Name;
  const char *Description;
  int   Default;
  int   *IntFlag;
  const char **StrFlag;
};

struct {
#define FUZZER_FLAG_INT(Name, Default, Description) int Name;
#define FUZZER_FLAG_STRING(Name, Description) const char *Name;
#include "FuzzerFlags.def"
#undef FUZZER_FLAG_INT
#undef FUZZER_FLAG_STRING
} Flags;

static FlagDescription FlagDescriptions [] {
#define FUZZER_FLAG_INT(Name, Default, Description)                            \
  { #Name, Description, Default, &Flags.Name, nullptr},
#define FUZZER_FLAG_STRING(Name, Description)                                  \
  { #Name, Description, 0, nullptr, &Flags.Name },
#include "FuzzerFlags.def"
#undef FUZZER_FLAG_INT
#undef FUZZER_FLAG_STRING
};

static const size_t kNumFlags =
    sizeof(FlagDescriptions) / sizeof(FlagDescriptions[0]);

static std::vector<std::string> inputs;
static const char *ProgName;

static void PrintHelp() {
  std::cerr << "Usage: " << ProgName
            << " [-flag1=val1 [-flag2=val2 ...] ] [dir1 [dir2 ...] ]\n";
  std::cerr << "\nFlags: (strictly in form -flag=value)\n";
  size_t MaxFlagLen = 0;
  for (size_t F = 0; F < kNumFlags; F++)
    MaxFlagLen = std::max(strlen(FlagDescriptions[F].Name), MaxFlagLen);

  for (size_t F = 0; F < kNumFlags; F++) {
    const auto &D = FlagDescriptions[F];
    std::cerr << "  " << D.Name;
    for (size_t i = 0, n = MaxFlagLen - strlen(D.Name); i < n; i++)
      std::cerr << " ";
    std::cerr << "\t";
    std::cerr << D.Default << "\t" << D.Description << "\n";
  }
}

static const char *FlagValue(const char *Param, const char *Name) {
  size_t Len = strlen(Name);
  if (Param[0] == '-' && strstr(Param + 1, Name) == Param + 1 &&
      Param[Len + 1] == '=')
      return &Param[Len + 2];
  return nullptr;
}

static bool ParseOneFlag(const char *Param) {
  if (Param[0] != '-') return false;
  for (size_t F = 0; F < kNumFlags; F++) {
    const char *Name = FlagDescriptions[F].Name;
    const char *Str = FlagValue(Param, Name);
    if (Str)  {
      if (FlagDescriptions[F].IntFlag) {
        int Val = std::stol(Str);
        *FlagDescriptions[F].IntFlag = Val;
        if (Flags.verbosity >= 2)
          std::cerr << "Flag: " << Name << " " << Val << "\n";
        return true;
      } else if (FlagDescriptions[F].StrFlag) {
        *FlagDescriptions[F].StrFlag = Str;
        if (Flags.verbosity >= 2)
          std::cerr << "Flag: " << Name << " " << Str << "\n";
        return true;
      }
    }
  }
  PrintHelp();
  exit(1);
}

// We don't use any library to minimize dependencies.
static void ParseFlags(int argc, char **argv) {
  for (size_t F = 0; F < kNumFlags; F++) {
    if (FlagDescriptions[F].IntFlag)
      *FlagDescriptions[F].IntFlag = FlagDescriptions[F].Default;
    if (FlagDescriptions[F].StrFlag)
      *FlagDescriptions[F].StrFlag = nullptr;
  }
  for (int A = 1; A < argc; A++) {
    if (ParseOneFlag(argv[A])) continue;
    inputs.push_back(argv[A]);
  }
}

static void WorkerThread(const std::string &Cmd, std::atomic<int> *Counter,
                        int NumJobs, std::atomic<bool> *HasErrors) {
  static std::mutex CerrMutex;
  while (true) {
    int C = (*Counter)++;
    if (C >= NumJobs) break;
    std::string Log = "fuzz-" + std::to_string(C) + ".log";
    std::string ToRun = Cmd + " > " + Log + " 2>&1\n";
    if (Flags.verbosity)
      std::cerr << ToRun;
    int ExitCode = system(ToRun.c_str());
    if (ExitCode != 0)
      *HasErrors = true;
    std::lock_guard<std::mutex> Lock(CerrMutex);
    std::cerr << "================== Job " << C
              << " exited with exit code " << ExitCode
              << " =================\n";
    fuzzer::CopyFileToErr(Log);
  }
}

static int RunInMultipleProcesses(int argc, char **argv, int NumWorkers,
                                  int NumJobs) {
  std::atomic<int> Counter(0);
  std::atomic<bool> HasErrors(false);
  std::string Cmd;
  for (int i = 0; i < argc; i++) {
    if (FlagValue(argv[i], "jobs") || FlagValue(argv[i], "workers")) continue;
    Cmd += argv[i];
    Cmd += " ";
  }
  std::vector<std::thread> V;
  for (int i = 0; i < NumWorkers; i++)
    V.push_back(std::thread(WorkerThread, Cmd, &Counter, NumJobs, &HasErrors));
  for (auto &T : V)
    T.join();
  return HasErrors ? 1 : 0;
}

std::vector<std::string> ReadTokensFile(const char *TokensFilePath) {
  if (!TokensFilePath) return {};
  std::string TokensFileContents = FileToString(TokensFilePath);
  std::istringstream ISS(TokensFileContents);
  std::vector<std::string> Res = {std::istream_iterator<std::string>{ISS},
                                  std::istream_iterator<std::string>{}};
  Res.push_back(" ");
  Res.push_back("\t");
  Res.push_back("\n");
  return Res;
}

int ApplyTokens(const Fuzzer &F, const char *InputFilePath) {
  Unit U = FileToVector(InputFilePath);
  auto T = F.SubstituteTokens(U);
  T.push_back(0);
  std::cout << T.data();
  return 0;
}

int FuzzerDriver(int argc, char **argv, UserCallback Callback) {
  using namespace fuzzer;

  ProgName = argv[0];
  ParseFlags(argc, argv);
  if (Flags.help) {
    PrintHelp();
    return 0;
  }

  if (Flags.workers > 0 && Flags.jobs > 0)
    return RunInMultipleProcesses(argc, argv, Flags.workers, Flags.jobs);

  Fuzzer::FuzzingOptions Options;
  Options.Verbosity = Flags.verbosity;
  Options.MaxLen = Flags.max_len;
  Options.DoCrossOver = Flags.cross_over;
  Options.MutateDepth = Flags.mutate_depth;
  Options.ExitOnFirst = Flags.exit_on_first;
  Options.UseCounters = Flags.use_counters;
  Options.UseFullCoverageSet = Flags.use_full_coverage_set;
  Options.UseCoveragePairs = Flags.use_coverage_pairs;
  Options.UseDFSan = Flags.dfsan;
  Options.PreferSmallDuringInitialShuffle =
      Flags.prefer_small_during_initial_shuffle;
  Options.Tokens = ReadTokensFile(Flags.tokens);
  if (Flags.runs >= 0)
    Options.MaxNumberOfRuns = Flags.runs;
  if (!inputs.empty())
    Options.OutputCorpus = inputs[0];
  Fuzzer F(Callback, Options);

  unsigned seed = Flags.seed;
  // Initialize seed.
  if (seed == 0)
    seed = time(0) * 10000 + getpid();
  if (Flags.verbosity)
    std::cerr << "Seed: " << seed << "\n";
  srand(seed);

  // Timer
  if (Flags.timeout > 0)
    SetTimer(Flags.timeout);

  if (Flags.verbosity >= 2) {
    std::cerr << "Tokens: {";
    for (auto &T : Options.Tokens)
      std::cerr << T << ",";
    std::cerr << "}\n";
  }

  if (Flags.apply_tokens)
    return ApplyTokens(F, Flags.apply_tokens);

  for (auto &inp : inputs)
    F.ReadDir(inp);

  if (F.CorpusSize() == 0)
    F.AddToCorpus(Unit());  // Can't fuzz empty corpus, so add an empty input.
  F.ShuffleAndMinimize();
  if (Flags.save_minimized_corpus)
    F.SaveCorpus();
  F.Loop(Flags.iterations < 0 ? INT_MAX : Flags.iterations);
  if (Flags.verbosity)
    std::cerr << "Done " << F.getTotalNumberOfRuns()
              << " runs in " << F.secondsSinceProcessStartUp()
              << " seconds\n";
  return 0;
}

}  // namespace fuzzer
