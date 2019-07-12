//===- llvm/Support/Signals.h - Signal Handling support ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines some helpful functions for dealing with the possibility of
// unix signals occurring while your program is running.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_SIGNALS_H
#define LLVM_SUPPORT_SIGNALS_H

#include <string>

namespace llvm {
class StringRef;
class raw_ostream;

namespace sys {

  /// This function runs all the registered interrupt handlers, including the
  /// removal of files registered by RemoveFileOnSignal.
  void RunInterruptHandlers();

  /// This function registers signal handlers to ensure that if a signal gets
  /// delivered that the named file is removed.
  /// Remove a file if a fatal signal occurs.
  bool RemoveFileOnSignal(StringRef Filename, std::string* ErrMsg = nullptr);

  /// This function removes a file from the list of files to be removed on
  /// signal delivery.
  void DontRemoveFileOnSignal(StringRef Filename);

  /// When an error signal (such as SIGABRT or SIGSEGV) is delivered to the
  /// process, print a stack trace and then exit.
  /// Print a stack trace if a fatal signal occurs.
  /// \param Argv0 the current binary name, used to find the symbolizer
  ///        relative to the current binary before searching $PATH; can be
  ///        StringRef(), in which case we will only search $PATH.
  /// \param DisableCrashReporting if \c true, disable the normal crash
  ///        reporting mechanisms on the underlying operating system.
  void PrintStackTraceOnErrorSignal(StringRef Argv0,
                                    bool DisableCrashReporting = false);

  /// Disable all system dialog boxes that appear when the process crashes.
  void DisableSystemDialogsOnCrash();

  /// Print the stack trace using the given \c raw_ostream object.
  void PrintStackTrace(raw_ostream &OS);

  // Run all registered signal handlers.
  void RunSignalHandlers();

  using SignalHandlerCallback = void (*)(void *);

  /// Add a function to be called when an abort/kill signal is delivered to the
  /// process. The handler can have a cookie passed to it to identify what
  /// instance of the handler it is.
  void AddSignalHandler(SignalHandlerCallback FnPtr, void *Cookie);

  /// This function registers a function to be called when the user "interrupts"
  /// the program (typically by pressing ctrl-c).  When the user interrupts the
  /// program, the specified interrupt function is called instead of the program
  /// being killed, and the interrupt function automatically disabled.
  ///
  /// Note that interrupt functions are not allowed to call any non-reentrant
  /// functions.  An null interrupt function pointer disables the current
  /// installed function.  Note also that the handler may be executed on a
  /// different thread on some platforms.
  void SetInterruptFunction(void (*IF)());

  /// Registers a function to be called when an "info" signal is delivered to
  /// the process.
  ///
  /// On POSIX systems, this will be SIGUSR1; on systems that have it, SIGINFO
  /// will also be used (typically ctrl-t).
  ///
  /// Note that signal handlers are not allowed to call any non-reentrant
  /// functions.  An null function pointer disables the current installed
  /// function.  Note also that the handler may be executed on a different
  /// thread on some platforms.
  void SetInfoSignalFunction(void (*Handler)());
} // End sys namespace
} // End llvm namespace

#endif
