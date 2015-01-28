//===- PrettyStackTrace.cpp - Pretty Crash Handling -----------------------===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This file defines some helpful functions for dealing with the possibility of
// Unix signals occurring while your program is running.
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/PrettyStackTrace.h"
#include "llvm-c/Core.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Config/config.h"     // Get autoconf configuration settings
#include "llvm/Support/Signals.h"
#include "llvm/Support/Watchdog.h"
#include "llvm/Support/raw_ostream.h"

#ifdef HAVE_CRASHREPORTERCLIENT_H
#include <CrashReporterClient.h>
#endif

using namespace llvm;

// We need a thread local pointer to manage the stack of our stack trace
// objects, but we *really* cannot tolerate destructors running and do not want
// to pay any overhead of synchronizing. As a consequence, we use a raw
// thread-local variable. Some day, we should be able to use a limited subset
// of C++11's thread_local, but compilers aren't up for it today.
// FIXME: This should be moved to a Compiler.h abstraction.
#ifdef _MSC_VER
// MSVC supports this with a __declspec.
#define LLVM_THREAD_LOCAL __declspec(thread)
#else
// Clang, GCC, and all compatible compilers tend to use __thread. But we need
// to work aronud a bug in the combination of Clang's compilation of
// local-dynamic TLS and the ppc64 linker relocations which we do by forcing to
// general-dynamic.
// FIXME: Make this conditional on the Clang version once this is fixed in
// top-of-tree.
#if defined(__clang__) && defined(__powerpc64__)
#define LLVM_THREAD_LOCAL __thread __attribute__((tls_model("general-dynamic")))
#else
#define LLVM_THREAD_LOCAL __thread
#endif
#endif

static LLVM_THREAD_LOCAL const PrettyStackTraceEntry *PrettyStackTraceHead =
    nullptr;

static unsigned PrintStack(const PrettyStackTraceEntry *Entry, raw_ostream &OS){
  unsigned NextID = 0;
  if (Entry->getNextEntry())
    NextID = PrintStack(Entry->getNextEntry(), OS);
  OS << NextID << ".\t";
  {
    sys::Watchdog W(5);
    Entry->print(OS);
  }
  
  return NextID+1;
}

/// PrintCurStackTrace - Print the current stack trace to the specified stream.
static void PrintCurStackTrace(raw_ostream &OS) {
  // Don't print an empty trace.
  if (!PrettyStackTraceHead) return;
  
  // If there are pretty stack frames registered, walk and emit them.
  OS << "Stack dump:\n";
  
  PrintStack(PrettyStackTraceHead, OS);
  OS.flush();
}

// Integrate with crash reporter libraries.
#if defined (__APPLE__) && HAVE_CRASHREPORTERCLIENT_H
//  If any clients of llvm try to link to libCrashReporterClient.a themselves,
//  only one crash info struct will be used.
extern "C" {
CRASH_REPORTER_CLIENT_HIDDEN 
struct crashreporter_annotations_t gCRAnnotations 
        __attribute__((section("__DATA," CRASHREPORTER_ANNOTATIONS_SECTION))) 
        = { CRASHREPORTER_ANNOTATIONS_VERSION, 0, 0, 0, 0, 0, 0 };
}
#elif defined (__APPLE__) && HAVE_CRASHREPORTER_INFO
static const char *__crashreporter_info__ = 0;
asm(".desc ___crashreporter_info__, 0x10");
#endif


/// CrashHandler - This callback is run if a fatal signal is delivered to the
/// process, it prints the pretty stack trace.
static void CrashHandler(void *) {
#ifndef __APPLE__
  // On non-apple systems, just emit the crash stack trace to stderr.
  PrintCurStackTrace(errs());
#else
  // Otherwise, emit to a smallvector of chars, send *that* to stderr, but also
  // put it into __crashreporter_info__.
  SmallString<2048> TmpStr;
  {
    raw_svector_ostream Stream(TmpStr);
    PrintCurStackTrace(Stream);
  }
  
  if (!TmpStr.empty()) {
#ifdef HAVE_CRASHREPORTERCLIENT_H
    // Cast to void to avoid warning.
    (void)CRSetCrashLogMessage(std::string(TmpStr.str()).c_str());
#elif HAVE_CRASHREPORTER_INFO 
    __crashreporter_info__ = strdup(std::string(TmpStr.str()).c_str());
#endif
    errs() << TmpStr.str();
  }
  
#endif
}

PrettyStackTraceEntry::PrettyStackTraceEntry() {
  // Link ourselves.
  NextEntry = PrettyStackTraceHead;
  PrettyStackTraceHead = this;
}

PrettyStackTraceEntry::~PrettyStackTraceEntry() {
  assert(PrettyStackTraceHead == this &&
         "Pretty stack trace entry destruction is out of order");
  PrettyStackTraceHead = getNextEntry();
}

void PrettyStackTraceString::print(raw_ostream &OS) const {
  OS << Str << "\n";
}

void PrettyStackTraceProgram::print(raw_ostream &OS) const {
  OS << "Program arguments: ";
  // Print the argument list.
  for (unsigned i = 0, e = ArgC; i != e; ++i)
    OS << ArgV[i] << ' ';
  OS << '\n';
}

static bool RegisterCrashPrinter() {
  sys::AddSignalHandler(CrashHandler, nullptr);
  return false;
}

void llvm::EnablePrettyStackTrace() {
  // The first time this is called, we register the crash printer.
  static bool HandlerRegistered = RegisterCrashPrinter();
  (void)HandlerRegistered;
}

void LLVMEnablePrettyStackTrace() {
  EnablePrettyStackTrace();
}
