//===- MCDirectives.h - Enums for directives on various targets -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines various enums that represent target-specific directives.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCDIRECTIVES_H
#define LLVM_MC_MCDIRECTIVES_H

namespace llvm {

enum MCSymbolAttr {
  MCSA_Invalid = 0,    /// Not a valid directive.

  // Various directives in alphabetical order.
  MCSA_Global,         /// .globl
  MCSA_Hidden,         /// .hidden (ELF)
  MCSA_IndirectSymbol, /// .indirect_symbol (MachO)
  MCSA_Internal,       /// .internal (ELF)
  MCSA_LazyReference,  /// .lazy_reference (MachO)
  MCSA_Local,          /// .local (ELF)
  MCSA_NoDeadStrip,    /// .no_dead_strip (MachO)
  MCSA_PrivateExtern,  /// .private_extern (MachO)
  MCSA_Protected,      /// .protected (ELF)
  MCSA_Reference,      /// .reference (MachO)
  MCSA_Weak,           /// .weak
  MCSA_WeakDefinition, /// .weak_definition (MachO)
  MCSA_WeakReference   /// .weak_reference (MachO)
};

enum MCAssemblerFlag {
  MCAF_SubsectionsViaSymbols  /// .subsections_via_symbols (MachO)
};
  
} // end namespace llvm

#endif
