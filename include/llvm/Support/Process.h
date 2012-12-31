//===- llvm/Support/Process.h -----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// Provides a library for accessing information about this process and other
/// processes on the operating system. Also provides means of spawning
/// subprocess for commands. The design of this library is modeled after the
/// proposed design of the Boost.Process library, and is design specifically to
/// follow the style of standard libraries and potentially become a proposal
/// for a standard library.
///
/// This file declares the llvm::sys::Process class which contains a collection
/// of legacy static interfaces for extracting various information about the
/// current process. The goal is to migrate users of this API over to the new
/// interfaces.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_SYSTEM_PROCESS_H
#define LLVM_SYSTEM_PROCESS_H

#include "llvm/Support/TimeValue.h"

namespace llvm {
namespace sys {

/// \brief A collection of legacy interfaces for querying information about the
/// current executing process.
class Process {
public:
  /// \brief Get the virtual memory page size
  /// This static function will return the operating system's virtual memory
  /// page size.
  /// \returns The number of bytes in a virtual memory page.
  static unsigned GetPageSize();

  /// \brief Return process memory usage.
  /// This static function will return the total amount of memory allocated
  /// by the process. This only counts the memory allocated via the malloc,
  /// calloc and realloc functions and includes any "free" holes in the
  /// allocated space.
  static size_t GetMallocUsage();

  /// This static function will return the total memory usage of the
  /// process. This includes code, data, stack and mapped pages usage. Notei
  /// that the value returned here is not necessarily the Running Set Size,
  /// it is the total virtual memory usage, regardless of mapped state of
  /// that memory.
  static size_t GetTotalMemoryUsage();

  /// This static function will set \p user_time to the amount of CPU time
  /// spent in user (non-kernel) mode and \p sys_time to the amount of CPU
  /// time spent in system (kernel) mode.  If the operating system does not
  /// support collection of these metrics, a zero TimeValue will be for both
  /// values.
  /// \param elapsed Returns the TimeValue::now() giving current time
  /// \param user_time Returns the current amount of user time for the process
  /// \param sys_time Returns the current amount of system time for the process
  static void GetTimeUsage(TimeValue &elapsed, TimeValue &user_time,
                           TimeValue &sys_time);

  /// This static function will return the process' current user id number.
  /// Not all operating systems support this feature. Where it is not
  /// supported, the function should return 65536 as the value.
  static int GetCurrentUserId();

  /// This static function will return the process' current group id number.
  /// Not all operating systems support this feature. Where it is not
  /// supported, the function should return 65536 as the value.
  static int GetCurrentGroupId();

  /// This function makes the necessary calls to the operating system to
  /// prevent core files or any other kind of large memory dumps that can
  /// occur when a program fails.
  /// @brief Prevent core file generation.
  static void PreventCoreFiles();

  /// This function determines if the standard input is connected directly
  /// to a user's input (keyboard probably), rather than coming from a file
  /// or pipe.
  static bool StandardInIsUserInput();

  /// This function determines if the standard output is connected to a
  /// "tty" or "console" window. That is, the output would be displayed to
  /// the user rather than being put on a pipe or stored in a file.
  static bool StandardOutIsDisplayed();

  /// This function determines if the standard error is connected to a
  /// "tty" or "console" window. That is, the output would be displayed to
  /// the user rather than being put on a pipe or stored in a file.
  static bool StandardErrIsDisplayed();

  /// This function determines if the given file descriptor is connected to
  /// a "tty" or "console" window. That is, the output would be displayed to
  /// the user rather than being put on a pipe or stored in a file.
  static bool FileDescriptorIsDisplayed(int fd);

  /// This function determines if the given file descriptor is displayd and
  /// supports colors.
  static bool FileDescriptorHasColors(int fd);

  /// This function determines the number of columns in the window
  /// if standard output is connected to a "tty" or "console"
  /// window. If standard output is not connected to a tty or
  /// console, or if the number of columns cannot be determined,
  /// this routine returns zero.
  static unsigned StandardOutColumns();

  /// This function determines the number of columns in the window
  /// if standard error is connected to a "tty" or "console"
  /// window. If standard error is not connected to a tty or
  /// console, or if the number of columns cannot be determined,
  /// this routine returns zero.
  static unsigned StandardErrColumns();

  /// This function determines whether the terminal connected to standard
  /// output supports colors. If standard output is not connected to a
  /// terminal, this function returns false.
  static bool StandardOutHasColors();

  /// This function determines whether the terminal connected to standard
  /// error supports colors. If standard error is not connected to a
  /// terminal, this function returns false.
  static bool StandardErrHasColors();

  /// Whether changing colors requires the output to be flushed.
  /// This is needed on systems that don't support escape sequences for
  /// changing colors.
  static bool ColorNeedsFlush();

  /// This function returns the colorcode escape sequences.
  /// If ColorNeedsFlush() is true then this function will change the colors
  /// and return an empty escape sequence. In that case it is the
  /// responsibility of the client to flush the output stream prior to
  /// calling this function.
  static const char *OutputColor(char c, bool bold, bool bg);

  /// Same as OutputColor, but only enables the bold attribute.
  static const char *OutputBold(bool bg);

  /// This function returns the escape sequence to reverse forground and
  /// background colors.
  static const char *OutputReverse();

  /// Resets the terminals colors, or returns an escape sequence to do so.
  static const char *ResetColor();

  /// Get the result of a process wide random number generator. The
  /// generator will be automatically seeded in non-deterministic fashion.
  static unsigned GetRandomNumber();
};

}
}

#endif
