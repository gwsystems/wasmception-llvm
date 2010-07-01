//===- MCSection.h - Machine Code Sections ----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the MCSection class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCSECTION_H
#define LLVM_MC_MCSECTION_H

#include <string>
#include "llvm/ADT/StringRef.h"
#include "llvm/MC/SectionKind.h"
#include "llvm/Support/Casting.h"

namespace llvm {
  class MCContext;
  class MCAsmInfo;
  class raw_ostream;

  /// MCSection - Instances of this class represent a uniqued identifier for a
  /// section in the current translation unit.  The MCContext class uniques and
  /// creates these.
  class MCSection {
  public:
    enum SectionVariant {
      SV_COFF = 0,
      SV_ELF,
      SV_MachO,
      SV_PIC16
    };

  private:
    MCSection(const MCSection&);      // DO NOT IMPLEMENT
    void operator=(const MCSection&); // DO NOT IMPLEMENT
  protected:
    MCSection(SectionVariant V, SectionKind K) : Variant(V), Kind(K) {}
    SectionVariant Variant;
    SectionKind Kind;
  public:
    virtual ~MCSection();

    SectionKind getKind() const { return Kind; }

    SectionVariant getVariant() const { return Variant; }

    virtual void PrintSwitchToSection(const MCAsmInfo &MAI,
                                      raw_ostream &OS) const = 0;

    /// isBaseAddressKnownZero - Return true if we know that this section will
    /// get a base address of zero.  In cases where we know that this is true we
    /// can emit section offsets as direct references to avoid a subtraction
    /// from the base of the section, saving a relocation.
    virtual bool isBaseAddressKnownZero() const {
      return false;
    }

    static bool classof(const MCSection *) { return true; }
  };

} // end namespace llvm

#endif
