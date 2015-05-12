//===- FuzzerUtil.cpp - Misc utils ----------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Misc utils.
//===----------------------------------------------------------------------===//

#include "FuzzerInternal.h"
#include <iostream>
#include <sys/time.h>
#include <cassert>
#include <cstring>
#include <signal.h>
#include <unistd.h>

namespace fuzzer {

void Print(const Unit &v, const char *PrintAfter) {
  for (auto x : v)
    std::cerr << "0x" << std::hex << (unsigned) x << std::dec << ",";
  std::cerr << PrintAfter;
}

void PrintASCII(const Unit &U, const char *PrintAfter) {
  for (auto X : U) {
    if (isprint(X))
      std::cerr << X;
    else
      std::cerr << "\\x" << std::hex << (int)(unsigned)X << std::dec;
  }
  std::cerr << PrintAfter;
}

// Try to compute a SHA1 sum of this Unit using an external 'sha1sum' command.
// We can not use the SHA1 function from openssl directly because
//  a) openssl may not be available,
//  b) we may be fuzzing openssl itself.
// This is all very sad, suggestions are welcome.
static std::string TrySha1(const Unit &in) {
  char TempPath[] = "/tmp/fuzzer-tmp-XXXXXX";
  int FD = mkstemp(TempPath);
  if (FD < 0) return "";
  ssize_t Written = write(FD, in.data(), in.size());
  close(FD);
  if (static_cast<size_t>(Written) != in.size()) return "";

  std::string Cmd = "sha1sum < ";
  Cmd += TempPath;
  FILE *F = popen(Cmd.c_str(), "r");
  if (!F) return "";
  char Sha1[41];
  fgets(Sha1, sizeof(Sha1), F);
  fclose(F);

  unlink(TempPath);
  return Sha1;
}

std::string Hash(const Unit &in) {
  std::string Sha1 = TrySha1(in);
  if (!Sha1.empty())
    return Sha1;

  size_t h1 = 0, h2 = 0;
  for (auto x : in) {
    h1 += x;
    h1 *= 5;
    h2 += x;
    h2 *= 7;
  }
  return std::to_string(h1) + std::to_string(h2);
}

static void AlarmHandler(int, siginfo_t *, void *) {
  Fuzzer::StaticAlarmCallback();
}

void SetTimer(int Seconds) {
  struct itimerval T {{Seconds, 0}, {Seconds, 0}};
  std::cerr << "SetTimer " << Seconds << "\n";
  int Res = setitimer(ITIMER_REAL, &T, nullptr);
  assert(Res == 0);
  struct sigaction sigact;
  memset(&sigact, 0, sizeof(sigact));
  sigact.sa_sigaction = AlarmHandler;
  Res = sigaction(SIGALRM, &sigact, 0);
  assert(Res == 0);
}

int NumberOfCpuCores() {
  FILE *F = popen("nproc", "r");
  int N = 0;
  fscanf(F, "%d", &N);
  fclose(F);
  return N;
}

}  // namespace fuzzer
