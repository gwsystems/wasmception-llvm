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

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/ilist.h"
#include "llvm/ADT/ilist_node.h"
#include "llvm/MC/SectionKind.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
class MCAssembler;
class MCAsmInfo;
class MCContext;
class MCExpr;
class MCFragment;
class MCSection;
class MCSymbol;
class raw_ostream;

class MCSectionData {
  friend class MCAsmLayout;

  MCSectionData(const MCSectionData &) = delete;
  void operator=(const MCSectionData &) = delete;

public:
  typedef iplist<MCFragment> FragmentListType;

  typedef FragmentListType::const_iterator const_iterator;
  typedef FragmentListType::iterator iterator;

  typedef FragmentListType::const_reverse_iterator const_reverse_iterator;
  typedef FragmentListType::reverse_iterator reverse_iterator;

private:
  FragmentListType Fragments;
  MCSection *Section;

  /// \name Assembler Backend Data
  /// @{
  //
  // FIXME: This could all be kept private to the assembler implementation.

  /// Mapping from subsection number to insertion point for subsection numbers
  /// below that number.
  SmallVector<std::pair<unsigned, MCFragment *>, 1> SubsectionFragmentMap;

  /// @}

public:
  explicit MCSectionData(MCSection &Section);

  MCSection &getSection() const { return *Section; }

  /// \name Fragment Access
  /// @{

  const FragmentListType &getFragmentList() const { return Fragments; }
  FragmentListType &getFragmentList() { return Fragments; }

  iterator begin();
  const_iterator begin() const {
    return const_cast<MCSectionData *>(this)->begin();
  }

  iterator end();
  const_iterator end() const {
    return const_cast<MCSectionData *>(this)->end();
  }

  reverse_iterator rbegin();
  const_reverse_iterator rbegin() const {
    return const_cast<MCSectionData *>(this)->rbegin();
  }

  reverse_iterator rend();
  const_reverse_iterator rend() const {
    return const_cast<MCSectionData *>(this)->rend();
  }

  size_t size() const;

  bool empty() const;

  iterator getSubsectionInsertionPoint(unsigned Subsection);

  void dump();

  /// @}
};

/// Instances of this class represent a uniqued identifier for a section in the
/// current translation unit.  The MCContext class uniques and creates these.
class MCSection {
public:
  enum SectionVariant { SV_COFF = 0, SV_ELF, SV_MachO };

  /// \brief Express the state of bundle locked groups while emitting code.
  enum BundleLockStateType {
    NotBundleLocked,
    BundleLocked,
    BundleLockedAlignToEnd
  };

private:
  MCSection(const MCSection &) = delete;
  void operator=(const MCSection &) = delete;

  MCSymbol *Begin;
  MCSymbol *End = nullptr;
  /// The alignment requirement of this section.
  unsigned Alignment = 1;
  /// The section index in the assemblers section list.
  unsigned Ordinal = 0;
  /// The index of this section in the layout order.
  unsigned LayoutOrder;

  /// \brief Keeping track of bundle-locked state.
  BundleLockStateType BundleLockState = NotBundleLocked;

  /// \brief Current nesting depth of bundle_lock directives.
  unsigned BundleLockNestingDepth = 0;

  /// \brief We've seen a bundle_lock directive but not its first instruction
  /// yet.
  bool BundleGroupBeforeFirstInst = false;

  /// Whether this section has had instructions emitted into it.
  unsigned HasInstructions : 1;

  MCSectionData Data;

protected:
  MCSection(SectionVariant V, SectionKind K, MCSymbol *Begin);
  SectionVariant Variant;
  SectionKind Kind;

public:
  virtual ~MCSection();

  SectionKind getKind() const { return Kind; }

  SectionVariant getVariant() const { return Variant; }

  MCSymbol *getBeginSymbol() { return Begin; }
  const MCSymbol *getBeginSymbol() const {
    return const_cast<MCSection *>(this)->getBeginSymbol();
  }
  void setBeginSymbol(MCSymbol *Sym) {
    assert(!Begin);
    Begin = Sym;
  }
  MCSymbol *getEndSymbol(MCContext &Ctx);
  bool hasEnded() const;

  unsigned getAlignment() const { return Alignment; }
  void setAlignment(unsigned Value) { Alignment = Value; }

  unsigned getOrdinal() const { return Ordinal; }
  void setOrdinal(unsigned Value) { Ordinal = Value; }

  unsigned getLayoutOrder() const { return LayoutOrder; }
  void setLayoutOrder(unsigned Value) { LayoutOrder = Value; }

  BundleLockStateType getBundleLockState() const { return BundleLockState; }
  void setBundleLockState(BundleLockStateType NewState);
  bool isBundleLocked() const { return BundleLockState != NotBundleLocked; }

  bool isBundleGroupBeforeFirstInst() const {
    return BundleGroupBeforeFirstInst;
  }
  void setBundleGroupBeforeFirstInst(bool IsFirst) {
    BundleGroupBeforeFirstInst = IsFirst;
  }

  bool hasInstructions() const { return HasInstructions; }
  void setHasInstructions(bool Value) { HasInstructions = Value; }

  MCSectionData &getSectionData() { return Data; }
  const MCSectionData &getSectionData() const {
    return const_cast<MCSection *>(this)->getSectionData();
  }

  MCSectionData::FragmentListType &getFragmentList();
  const MCSectionData::FragmentListType &getFragmentList() const {
    return const_cast<MCSection *>(this)->getFragmentList();
  }

  MCSectionData::iterator begin();
  MCSectionData::const_iterator begin() const {
    return const_cast<MCSection *>(this)->begin();
  }

  MCSectionData::iterator end();
  MCSectionData::const_iterator end() const {
    return const_cast<MCSection *>(this)->end();
  }

  MCSectionData::reverse_iterator rend();
  MCSectionData::const_reverse_iterator rend() const {
    return const_cast<MCSection *>(this)->rend();
  }

  virtual void PrintSwitchToSection(const MCAsmInfo &MAI, raw_ostream &OS,
                                    const MCExpr *Subsection) const = 0;

  /// Return true if a .align directive should use "optimized nops" to fill
  /// instead of 0s.
  virtual bool UseCodeAlign() const = 0;

  /// Check whether this section is "virtual", that is has no actual object
  /// file contents.
  virtual bool isVirtualSection() const = 0;
};

} // end namespace llvm

#endif
