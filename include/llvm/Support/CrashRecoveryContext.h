//===--- CrashRecoveryContext.h - Crash Recovery ----------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_CRASHRECOVERYCONTEXT_H
#define LLVM_SUPPORT_CRASHRECOVERYCONTEXT_H

#include <string>

namespace llvm {
class StringRef;

class CrashRecoveryContextCleanup;
  
/// \brief Crash recovery helper object.
///
/// This class implements support for running operations in a safe context so
/// that crashes (memory errors, stack overflow, assertion violations) can be
/// detected and control restored to the crashing thread. Crash detection is
/// purely "best effort", the exact set of failures which can be recovered from
/// is platform dependent.
///
/// Clients make use of this code by first calling
/// CrashRecoveryContext::Enable(), and then executing unsafe operations via a
/// CrashRecoveryContext object. For example:
///
///    void actual_work(void *);
///
///    void foo() {
///      CrashRecoveryContext CRC;
///
///      if (!CRC.RunSafely(actual_work, 0)) {
///         ... a crash was detected, report error to user ...
///      }
///
///      ... no crash was detected ...
///    }
///
/// Crash recovery contexts may not be nested.
class CrashRecoveryContext {
  void *Impl;
  CrashRecoveryContextCleanup *head;

public:
  CrashRecoveryContext() : Impl(0), head(0) {}
  ~CrashRecoveryContext();
  
  void registerCleanup(CrashRecoveryContextCleanup *cleanup);
  void unregisterCleanup(CrashRecoveryContextCleanup *cleanup);

  /// \brief Enable crash recovery.
  static void Enable();

  /// \brief Disable crash recovery.
  static void Disable();

  /// \brief Return the active context, if the code is currently executing in a
  /// thread which is in a protected context.
  static CrashRecoveryContext *GetCurrent();

  /// \brief Return true if the current thread is recovering from a
  /// crash.
  static bool isRecoveringFromCrash();

  /// \brief Execute the provide callback function (with the given arguments) in
  /// a protected context.
  ///
  /// \return True if the function completed successfully, and false if the
  /// function crashed (or HandleCrash was called explicitly). Clients should
  /// make as little assumptions as possible about the program state when
  /// RunSafely has returned false. Clients can use getBacktrace() to retrieve
  /// the backtrace of the crash on failures.
  bool RunSafely(void (*Fn)(void*), void *UserData);

  /// \brief Execute the provide callback function (with the given arguments) in
  /// a protected context which is run in another thread (optionally with a
  /// requested stack size).
  ///
  /// See RunSafely() and llvm_execute_on_thread().
  bool RunSafelyOnThread(void (*Fn)(void*), void *UserData,
                         unsigned RequestedStackSize = 0);

  /// \brief Explicitly trigger a crash recovery in the current process, and
  /// return failure from RunSafely(). This function does not return.
  void HandleCrash();

  /// \brief Return a string containing the backtrace where the crash was
  /// detected; or empty if the backtrace wasn't recovered.
  ///
  /// This function is only valid when a crash has been detected (i.e.,
  /// RunSafely() has returned false.
  const std::string &getBacktrace() const;
};

class CrashRecoveryContextCleanup {
public:
  bool cleanupFired;
  enum ProvidedCleanups { DeleteCleanup, DestructorCleanup };
  
  CrashRecoveryContextCleanup() : cleanupFired(false) {}
  virtual ~CrashRecoveryContextCleanup();
  virtual void recoverResources() = 0;
  
  template <typename T> static CrashRecoveryContextCleanup *create(T *,
                          ProvidedCleanups cleanupKind =
                            CrashRecoveryContextCleanup::DeleteCleanup);
  
private:
  friend class CrashRecoveryContext;
  CrashRecoveryContextCleanup *prev, *next;
};

template <typename T>
class CrashRecoveryContextDestructorCleanup 
  : public CrashRecoveryContextCleanup
{
  T *resource;
public:
  CrashRecoveryContextDestructorCleanup(T *resource) : resource(resource) {}
  virtual void recoverResources() {
    resource->~T();
  }
};

template <typename T>
class CrashRecoveryContextDeleteCleanup
  : public CrashRecoveryContextCleanup
{
  T *resource;
public:
  CrashRecoveryContextDeleteCleanup(T *resource) : resource(resource) {}
  virtual void recoverResources() {
    delete resource;
  }
};

template <typename T>
struct CrashRecoveryContextTrait {
  static inline CrashRecoveryContextCleanup *
  createCleanup(T *resource,
                CrashRecoveryContextCleanup::ProvidedCleanups cleanup) {
    switch (cleanup) {
      case CrashRecoveryContextCleanup::DeleteCleanup:
        return new CrashRecoveryContextDeleteCleanup<T>(resource);
      case CrashRecoveryContextCleanup::DestructorCleanup:
        return new CrashRecoveryContextDestructorCleanup<T>(resource);
    }
    return 0;
  }
};

template<typename T>
inline CrashRecoveryContextCleanup*
CrashRecoveryContextCleanup::create(T *x,
          CrashRecoveryContextCleanup::ProvidedCleanups cleanupKind) {
  return CrashRecoveryContext::GetCurrent() ?
          CrashRecoveryContextTrait<T>::createCleanup(x, cleanupKind) : 
          0;
}

class CrashRecoveryContextCleanupRegistrar {
  CrashRecoveryContext *context;
  CrashRecoveryContextCleanup *cleanup;
public:
  CrashRecoveryContextCleanupRegistrar(CrashRecoveryContextCleanup *cleanup)
    : context(CrashRecoveryContext::GetCurrent()),
      cleanup(cleanup) 
  {
    if (context && cleanup)
      context->registerCleanup(cleanup);
  }
  ~CrashRecoveryContextCleanupRegistrar() {
    if (cleanup && !cleanup->cleanupFired) {
      if (context)
        context->unregisterCleanup(cleanup);
      else
        delete cleanup;
    }
  }
};
}

#endif
