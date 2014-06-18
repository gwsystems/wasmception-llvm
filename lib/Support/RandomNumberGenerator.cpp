//===-- RandomNumberGenerator.cpp - Implement RNG class -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements random number generation (RNG).
// The current implementation is NOT cryptographically secure as it uses
// the C++11 <random> facilities.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "rng"
#include "llvm/Support/RandomNumberGenerator.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

// Tracking BUG: 19665
// http://llvm.org/bugs/show_bug.cgi?id=19665
//
// Do not change to cl::opt<uint64_t> since this silently breaks argument parsing.
static cl::opt<unsigned long long>
Seed("rng-seed", cl::value_desc("seed"),
     cl::desc("Seed for the random number generator"), cl::init(0));

RandomNumberGenerator::RandomNumberGenerator(StringRef Salt) {
  DEBUG(
    if (Seed == 0)
      errs() << "Warning! Using unseeded random number generator.\n"
  );

  // Combine seed and salt using std::seed_seq.
  // Entropy: Seed-low, Seed-high, Salt...
  size_t Size = Salt.size() + 2;
  uint32_t Data[Size];
  Data[0] = Seed;
  Data[1] = Seed >> 32;
  std::copy_n(Salt.begin(), Salt.size(), Data + 2);

  std::seed_seq SeedSeq(Data, Data + Size);
  Generator.seed(SeedSeq);
}

uint64_t RandomNumberGenerator::next(uint64_t Max) {
  std::uniform_int_distribution<uint64_t> distribution(0, Max - 1);
  return distribution(Generator);
}
