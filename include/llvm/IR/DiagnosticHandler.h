//===- DiagnosticHandler.h - DiagnosticHandler class for LLVM -*- C++ ---*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Base DiagnosticHandler class declaration. Derive from this class to provide
// custom diagnostic reporting.
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringRef.h"

namespace llvm {
class DiagnosticInfo;

/// \brief This is the base class for diagnostic handling in LLVM.
/// The handleDiagnostics method must be overriden by the subclasses to handle
/// diagnostic. The *RemarkEnabled methods can be overriden to control
/// which remarks are enabled.
struct DiagnosticHandler {
  void *DiagnosticContext = nullptr;
  DiagnosticHandler(void *DiagContext = nullptr)
      : DiagnosticContext(DiagContext) {}
  virtual ~DiagnosticHandler() = default;

  using DiagnosticHandlerTy = void (*)(const DiagnosticInfo &DI, void *Context);

  /// DiagHandlerCallback is settable from the C API and base implementation
  /// of DiagnosticHandler will call it from handleDiagnostics(). Any derived
  /// class of DiagnosticHandler should not use callback but
  /// implement handleDiagnostics().
  DiagnosticHandlerTy DiagHandlerCallback = nullptr;

  /// Override handleDiagnostics to provide custom implementation.
  /// Return true if it handles diagnostics reporting properly otherwise
  /// return false to make LLVMContext::diagnose() to print the message
  /// with a prefix based on the severity.
  virtual bool handleDiagnostics(const DiagnosticInfo &DI) {
    if (DiagHandlerCallback) {
      DiagHandlerCallback(DI, DiagnosticContext);
      return true;
    }
    return false;
  }

  /// Return true if analysis remarks are enabled, override
  /// to provide different implementation.
  virtual bool isAnalysisRemarkEnabled(StringRef PassName) const;

  /// Return true if missed optimization remarks are enabled, override
  /// to provide different implementation.
  virtual bool isMissedOptRemarkEnabled(StringRef PassName) const;

  /// Return true if passed optimization remarks are enabled, override
  /// to provide different implementation.
  virtual bool isPassedOptRemarkEnabled(StringRef PassName) const;

  /// Return true if any type of remarks are enabled.
  bool isAnyRemarkEnabled(StringRef PassName) const {
    return (isMissedOptRemarkEnabled(PassName) ||
            isPassedOptRemarkEnabled(PassName) ||
            isAnalysisRemarkEnabled(PassName));
  }
};
}
