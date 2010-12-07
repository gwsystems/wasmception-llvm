//===- lib/MC/MachObjectWriter.cpp - Mach-O File Writer -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/Twine.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCAsmLayout.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSectionMachO.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCMachOSymbolFlags.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Object/MachOFormat.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetAsmBackend.h"

// FIXME: Gross.
#include "../Target/X86/X86FixupKinds.h"

#include <vector>
using namespace llvm;
using namespace llvm::object;

// FIXME: this has been copied from (or to) X86AsmBackend.cpp
static unsigned getFixupKindLog2Size(unsigned Kind) {
  switch (Kind) {
  // FIXME: Until ARM has it's own relocation stuff spun off, it comes
  // through here and we don't want it to puke all over. Any reasonable
  // values will only come when ARM relocation support gets added, at which
  // point this will be X86 only again and the llvm_unreachable can be
  // re-enabled.
  default: return 0;// llvm_unreachable("invalid fixup kind!");
  case FK_PCRel_1:
  case FK_Data_1: return 0;
  case FK_PCRel_2:
  case FK_Data_2: return 1;
  case FK_PCRel_4:
  case X86::reloc_riprel_4byte:
  case X86::reloc_riprel_4byte_movq_load:
  case X86::reloc_signed_4byte:
  case FK_Data_4: return 2;
  case FK_Data_8: return 3;
  }
}

static bool isFixupKindPCRel(unsigned Kind) {
  switch (Kind) {
  default:
    return false;
  case FK_PCRel_1:
  case FK_PCRel_2:
  case FK_PCRel_4:
  case X86::reloc_riprel_4byte:
  case X86::reloc_riprel_4byte_movq_load:
    return true;
  }
}

static bool isFixupKindRIPRel(unsigned Kind) {
  return Kind == X86::reloc_riprel_4byte ||
    Kind == X86::reloc_riprel_4byte_movq_load;
}

static bool doesSymbolRequireExternRelocation(MCSymbolData *SD) {
  // Undefined symbols are always extern.
  if (SD->Symbol->isUndefined())
    return true;

  // References to weak definitions require external relocation entries; the
  // definition may not always be the one in the same object file.
  if (SD->getFlags() & SF_WeakDefinition)
    return true;

  // Otherwise, we can use an internal relocation.
  return false;
}

static bool isScatteredFixupFullyResolved(const MCAssembler &Asm,
                                          const MCValue Target,
                                          const MCSymbolData *BaseSymbol) {
  // The effective fixup address is
  //     addr(atom(A)) + offset(A)
  //   - addr(atom(B)) - offset(B)
  //   - addr(BaseSymbol) + <fixup offset from base symbol>
  // and the offsets are not relocatable, so the fixup is fully resolved when
  //  addr(atom(A)) - addr(atom(B)) - addr(BaseSymbol) == 0.
  //
  // Note that "false" is almost always conservatively correct (it means we emit
  // a relocation which is unnecessary), except when it would force us to emit a
  // relocation which the target cannot encode.

  const MCSymbolData *A_Base = 0, *B_Base = 0;
  if (const MCSymbolRefExpr *A = Target.getSymA()) {
    // Modified symbol references cannot be resolved.
    if (A->getKind() != MCSymbolRefExpr::VK_None)
      return false;

    A_Base = Asm.getAtom(&Asm.getSymbolData(A->getSymbol()));
    if (!A_Base)
      return false;
  }

  if (const MCSymbolRefExpr *B = Target.getSymB()) {
    // Modified symbol references cannot be resolved.
    if (B->getKind() != MCSymbolRefExpr::VK_None)
      return false;

    B_Base = Asm.getAtom(&Asm.getSymbolData(B->getSymbol()));
    if (!B_Base)
      return false;
  }

  // If there is no base, A and B have to be the same atom for this fixup to be
  // fully resolved.
  if (!BaseSymbol)
    return A_Base == B_Base;

  // Otherwise, B must be missing and A must be the base.
  return !B_Base && BaseSymbol == A_Base;
}

static bool isScatteredFixupFullyResolvedSimple(const MCAssembler &Asm,
                                                const MCValue Target,
                                                const MCSection *BaseSection) {
  // The effective fixup address is
  //     addr(atom(A)) + offset(A)
  //   - addr(atom(B)) - offset(B)
  //   - addr(<base symbol>) + <fixup offset from base symbol>
  // and the offsets are not relocatable, so the fixup is fully resolved when
  //  addr(atom(A)) - addr(atom(B)) - addr(<base symbol>)) == 0.
  //
  // The simple (Darwin, except on x86_64) way of dealing with this was to
  // assume that any reference to a temporary symbol *must* be a temporary
  // symbol in the same atom, unless the sections differ. Therefore, any PCrel
  // relocation to a temporary symbol (in the same section) is fully
  // resolved. This also works in conjunction with absolutized .set, which
  // requires the compiler to use .set to absolutize the differences between
  // symbols which the compiler knows to be assembly time constants, so we don't
  // need to worry about considering symbol differences fully resolved.

  // Non-relative fixups are only resolved if constant.
  if (!BaseSection)
    return Target.isAbsolute();

  // Otherwise, relative fixups are only resolved if not a difference and the
  // target is a temporary in the same section.
  if (Target.isAbsolute() || Target.getSymB())
    return false;

  const MCSymbol *A = &Target.getSymA()->getSymbol();
  if (!A->isTemporary() || !A->isInSection() ||
      &A->getSection() != BaseSection)
    return false;

  return true;
}

namespace {

class MachObjectWriter : public MCObjectWriter {
  /// MachSymbolData - Helper struct for containing some precomputed information
  /// on symbols.
  struct MachSymbolData {
    MCSymbolData *SymbolData;
    uint64_t StringIndex;
    uint8_t SectionIndex;

    // Support lexicographic sorting.
    bool operator<(const MachSymbolData &RHS) const {
      return SymbolData->getSymbol().getName() <
             RHS.SymbolData->getSymbol().getName();
    }
  };

  /// @name Relocation Data
  /// @{

  llvm::DenseMap<const MCSectionData*,
                 std::vector<macho::RelocationEntry> > Relocations;
  llvm::DenseMap<const MCSectionData*, unsigned> IndirectSymBase;

  /// @}
  /// @name Symbol Table Data
  /// @{

  SmallString<256> StringTable;
  std::vector<MachSymbolData> LocalSymbolData;
  std::vector<MachSymbolData> ExternalSymbolData;
  std::vector<MachSymbolData> UndefinedSymbolData;

  /// @}

  SectionAddrMap SectionAddress;
  uint64_t getSectionAddress(const MCSectionData* SD) const {
    return SectionAddress.lookup(SD);
  }
  uint64_t getSymbolAddress(const MCSymbolData* SD,
                            const MCAsmLayout &Layout) const {
    return getSectionAddress(SD->getFragment()->getParent()) +
      Layout.getSymbolOffset(SD);
  }
  uint64_t getFragmentAddress(const MCFragment *Fragment,
                            const MCAsmLayout &Layout) const {
    return getSectionAddress(Fragment->getParent()) +
      Layout.getFragmentOffset(Fragment);
  }

  uint64_t getPaddingSize(const MCSectionData *SD,
                          const MCAsmLayout &Layout) const {
    uint64_t EndAddr = getSectionAddress(SD) + Layout.getSectionAddressSize(SD);
    unsigned Next = SD->getLayoutOrder() + 1;
    if (Next >= Layout.getSectionOrder().size())
      return 0;

    const MCSectionData &NextSD = *Layout.getSectionOrder()[Next];
    if (NextSD.getSection().isVirtualSection())
      return 0;
    return OffsetToAlignment(EndAddr, NextSD.getAlignment());
  }

  unsigned Is64Bit : 1;

  uint32_t CPUType;
  uint32_t CPUSubtype;

public:
  MachObjectWriter(raw_ostream &_OS,
                   bool _Is64Bit, uint32_t _CPUType, uint32_t _CPUSubtype,
                   bool _IsLittleEndian)
    : MCObjectWriter(_OS, _IsLittleEndian),
      Is64Bit(_Is64Bit), CPUType(_CPUType), CPUSubtype(_CPUSubtype) {
  }

  void WriteHeader(unsigned NumLoadCommands, unsigned LoadCommandsSize,
                   bool SubsectionsViaSymbols) {
    uint32_t Flags = 0;

    if (SubsectionsViaSymbols)
      Flags |= macho::HF_SubsectionsViaSymbols;

    // struct mach_header (28 bytes) or
    // struct mach_header_64 (32 bytes)

    uint64_t Start = OS.tell();
    (void) Start;

    Write32(Is64Bit ? macho::HM_Object64 : macho::HM_Object32);

    Write32(CPUType);
    Write32(CPUSubtype);

    Write32(macho::HFT_Object);
    Write32(NumLoadCommands);
    Write32(LoadCommandsSize);
    Write32(Flags);
    if (Is64Bit)
      Write32(0); // reserved

    assert(OS.tell() - Start == Is64Bit ? 
           macho::Header64Size : macho::Header32Size);
  }

  /// WriteSegmentLoadCommand - Write a segment load command.
  ///
  /// \arg NumSections - The number of sections in this segment.
  /// \arg SectionDataSize - The total size of the sections.
  void WriteSegmentLoadCommand(unsigned NumSections,
                               uint64_t VMSize,
                               uint64_t SectionDataStartOffset,
                               uint64_t SectionDataSize) {
    // struct segment_command (56 bytes) or
    // struct segment_command_64 (72 bytes)

    uint64_t Start = OS.tell();
    (void) Start;

    unsigned SegmentLoadCommandSize = Is64Bit ? macho::SegmentLoadCommand64Size:
      macho::SegmentLoadCommand32Size;
    Write32(Is64Bit ? macho::LCT_Segment64 : macho::LCT_Segment);
    Write32(SegmentLoadCommandSize +
            NumSections * (Is64Bit ? macho::Section64Size :
                           macho::Section32Size));

    WriteBytes("", 16);
    if (Is64Bit) {
      Write64(0); // vmaddr
      Write64(VMSize); // vmsize
      Write64(SectionDataStartOffset); // file offset
      Write64(SectionDataSize); // file size
    } else {
      Write32(0); // vmaddr
      Write32(VMSize); // vmsize
      Write32(SectionDataStartOffset); // file offset
      Write32(SectionDataSize); // file size
    }
    Write32(0x7); // maxprot
    Write32(0x7); // initprot
    Write32(NumSections);
    Write32(0); // flags

    assert(OS.tell() - Start == SegmentLoadCommandSize);
  }

  void WriteSection(const MCAssembler &Asm, const MCAsmLayout &Layout,
                    const MCSectionData &SD, uint64_t FileOffset,
                    uint64_t RelocationsStart, unsigned NumRelocations) {
    uint64_t SectionSize = Layout.getSectionAddressSize(&SD);

    // The offset is unused for virtual sections.
    if (SD.getSection().isVirtualSection()) {
      assert(Layout.getSectionFileSize(&SD) == 0 && "Invalid file size!");
      FileOffset = 0;
    }

    // struct section (68 bytes) or
    // struct section_64 (80 bytes)

    uint64_t Start = OS.tell();
    (void) Start;

    const MCSectionMachO &Section = cast<MCSectionMachO>(SD.getSection());
    WriteBytes(Section.getSectionName(), 16);
    WriteBytes(Section.getSegmentName(), 16);
    if (Is64Bit) {
      Write64(getSectionAddress(&SD)); // address
      Write64(SectionSize); // size
    } else {
      Write32(getSectionAddress(&SD)); // address
      Write32(SectionSize); // size
    }
    Write32(FileOffset);

    unsigned Flags = Section.getTypeAndAttributes();
    if (SD.hasInstructions())
      Flags |= MCSectionMachO::S_ATTR_SOME_INSTRUCTIONS;

    assert(isPowerOf2_32(SD.getAlignment()) && "Invalid alignment!");
    Write32(Log2_32(SD.getAlignment()));
    Write32(NumRelocations ? RelocationsStart : 0);
    Write32(NumRelocations);
    Write32(Flags);
    Write32(IndirectSymBase.lookup(&SD)); // reserved1
    Write32(Section.getStubSize()); // reserved2
    if (Is64Bit)
      Write32(0); // reserved3

    assert(OS.tell() - Start == Is64Bit ? macho::Section64Size :
           macho::Section32Size);
  }

  void WriteSymtabLoadCommand(uint32_t SymbolOffset, uint32_t NumSymbols,
                              uint32_t StringTableOffset,
                              uint32_t StringTableSize) {
    // struct symtab_command (24 bytes)

    uint64_t Start = OS.tell();
    (void) Start;

    Write32(macho::LCT_Symtab);
    Write32(macho::SymtabLoadCommandSize);
    Write32(SymbolOffset);
    Write32(NumSymbols);
    Write32(StringTableOffset);
    Write32(StringTableSize);

    assert(OS.tell() - Start == macho::SymtabLoadCommandSize);
  }

  void WriteDysymtabLoadCommand(uint32_t FirstLocalSymbol,
                                uint32_t NumLocalSymbols,
                                uint32_t FirstExternalSymbol,
                                uint32_t NumExternalSymbols,
                                uint32_t FirstUndefinedSymbol,
                                uint32_t NumUndefinedSymbols,
                                uint32_t IndirectSymbolOffset,
                                uint32_t NumIndirectSymbols) {
    // struct dysymtab_command (80 bytes)

    uint64_t Start = OS.tell();
    (void) Start;

    Write32(macho::LCT_Dysymtab);
    Write32(macho::DysymtabLoadCommandSize);
    Write32(FirstLocalSymbol);
    Write32(NumLocalSymbols);
    Write32(FirstExternalSymbol);
    Write32(NumExternalSymbols);
    Write32(FirstUndefinedSymbol);
    Write32(NumUndefinedSymbols);
    Write32(0); // tocoff
    Write32(0); // ntoc
    Write32(0); // modtaboff
    Write32(0); // nmodtab
    Write32(0); // extrefsymoff
    Write32(0); // nextrefsyms
    Write32(IndirectSymbolOffset);
    Write32(NumIndirectSymbols);
    Write32(0); // extreloff
    Write32(0); // nextrel
    Write32(0); // locreloff
    Write32(0); // nlocrel

    assert(OS.tell() - Start == macho::DysymtabLoadCommandSize);
  }

  void WriteNlist(MachSymbolData &MSD, const MCAsmLayout &Layout) {
    MCSymbolData &Data = *MSD.SymbolData;
    const MCSymbol &Symbol = Data.getSymbol();
    uint8_t Type = 0;
    uint16_t Flags = Data.getFlags();
    uint32_t Address = 0;

    // Set the N_TYPE bits. See <mach-o/nlist.h>.
    //
    // FIXME: Are the prebound or indirect fields possible here?
    if (Symbol.isUndefined())
      Type = macho::STT_Undefined;
    else if (Symbol.isAbsolute())
      Type = macho::STT_Absolute;
    else
      Type = macho::STT_Section;

    // FIXME: Set STAB bits.

    if (Data.isPrivateExtern())
      Type |= macho::STF_PrivateExtern;

    // Set external bit.
    if (Data.isExternal() || Symbol.isUndefined())
      Type |= macho::STF_External;

    // Compute the symbol address.
    if (Symbol.isDefined()) {
      if (Symbol.isAbsolute()) {
        Address = cast<MCConstantExpr>(Symbol.getVariableValue())->getValue();
      } else {
        Address = getSymbolAddress(&Data, Layout);
      }
    } else if (Data.isCommon()) {
      // Common symbols are encoded with the size in the address
      // field, and their alignment in the flags.
      Address = Data.getCommonSize();

      // Common alignment is packed into the 'desc' bits.
      if (unsigned Align = Data.getCommonAlignment()) {
        unsigned Log2Size = Log2_32(Align);
        assert((1U << Log2Size) == Align && "Invalid 'common' alignment!");
        if (Log2Size > 15)
          report_fatal_error("invalid 'common' alignment '" +
                            Twine(Align) + "'");
        // FIXME: Keep this mask with the SymbolFlags enumeration.
        Flags = (Flags & 0xF0FF) | (Log2Size << 8);
      }
    }

    // struct nlist (12 bytes)

    Write32(MSD.StringIndex);
    Write8(Type);
    Write8(MSD.SectionIndex);

    // The Mach-O streamer uses the lowest 16-bits of the flags for the 'desc'
    // value.
    Write16(Flags);
    if (Is64Bit)
      Write64(Address);
    else
      Write32(Address);
  }

  // FIXME: We really need to improve the relocation validation. Basically, we
  // want to implement a separate computation which evaluates the relocation
  // entry as the linker would, and verifies that the resultant fixup value is
  // exactly what the encoder wanted. This will catch several classes of
  // problems:
  //
  //  - Relocation entry bugs, the two algorithms are unlikely to have the same
  //    exact bug.
  //
  //  - Relaxation issues, where we forget to relax something.
  //
  //  - Input errors, where something cannot be correctly encoded. 'as' allows
  //    these through in many cases.

  void RecordX86_64Relocation(const MCAssembler &Asm, const MCAsmLayout &Layout,
                              const MCFragment *Fragment,
                              const MCFixup &Fixup, MCValue Target,
                              uint64_t &FixedValue) {
    unsigned IsPCRel = isFixupKindPCRel(Fixup.getKind());
    unsigned IsRIPRel = isFixupKindRIPRel(Fixup.getKind());
    unsigned Log2Size = getFixupKindLog2Size(Fixup.getKind());

    // See <reloc.h>.
    uint32_t FixupOffset =
      Layout.getFragmentOffset(Fragment) + Fixup.getOffset();
    uint32_t FixupAddress =
      getFragmentAddress(Fragment, Layout) + Fixup.getOffset();
    int64_t Value = 0;
    unsigned Index = 0;
    unsigned IsExtern = 0;
    unsigned Type = 0;

    Value = Target.getConstant();

    if (IsPCRel) {
      // Compensate for the relocation offset, Darwin x86_64 relocations only
      // have the addend and appear to have attempted to define it to be the
      // actual expression addend without the PCrel bias. However, instructions
      // with data following the relocation are not accomodated for (see comment
      // below regarding SIGNED{1,2,4}), so it isn't exactly that either.
      Value += 1LL << Log2Size;
    }

    if (Target.isAbsolute()) { // constant
      // SymbolNum of 0 indicates the absolute section.
      Type = macho::RIT_X86_64_Unsigned;
      Index = 0;

      // FIXME: I believe this is broken, I don't think the linker can
      // understand it. I think it would require a local relocation, but I'm not
      // sure if that would work either. The official way to get an absolute
      // PCrel relocation is to use an absolute symbol (which we don't support
      // yet).
      if (IsPCRel) {
        IsExtern = 1;
        Type = macho::RIT_X86_64_Branch;
      }
    } else if (Target.getSymB()) { // A - B + constant
      const MCSymbol *A = &Target.getSymA()->getSymbol();
      MCSymbolData &A_SD = Asm.getSymbolData(*A);
      const MCSymbolData *A_Base = Asm.getAtom(&A_SD);

      const MCSymbol *B = &Target.getSymB()->getSymbol();
      MCSymbolData &B_SD = Asm.getSymbolData(*B);
      const MCSymbolData *B_Base = Asm.getAtom(&B_SD);

      // Neither symbol can be modified.
      if (Target.getSymA()->getKind() != MCSymbolRefExpr::VK_None ||
          Target.getSymB()->getKind() != MCSymbolRefExpr::VK_None)
        report_fatal_error("unsupported relocation of modified symbol");

      // We don't support PCrel relocations of differences. Darwin 'as' doesn't
      // implement most of these correctly.
      if (IsPCRel)
        report_fatal_error("unsupported pc-relative relocation of difference");

      // The support for the situation where one or both of the symbols would
      // require a local relocation is handled just like if the symbols were
      // external.  This is certainly used in the case of debug sections where
      // the section has only temporary symbols and thus the symbols don't have
      // base symbols.  This is encoded using the section ordinal and
      // non-extern relocation entries.

      // Darwin 'as' doesn't emit correct relocations for this (it ends up with
      // a single SIGNED relocation); reject it for now.  Except the case where
      // both symbols don't have a base, equal but both NULL.
      if (A_Base == B_Base && A_Base)
        report_fatal_error("unsupported relocation with identical base");

      assert((A_Base == NULL) == (B_Base == NULL));
      assert(A_SD.getFragment()->getParent() ==
             B_SD.getFragment()->getParent());

      Value += Layout.getSymbolOffset(&A_SD) -
               (A_Base == NULL ? 0 : Layout.getSymbolOffset(A_Base));
      Value -= Layout.getSymbolOffset(&B_SD) -
               (B_Base == NULL ? 0 : Layout.getSymbolOffset(B_Base));

      if (A_Base) {
        Index = A_Base->getIndex();
        IsExtern = 1;
      }
      else {
        Index = A_SD.getFragment()->getParent()->getOrdinal() + 1;
        IsExtern = 0;
      }
      Type = macho::RIT_X86_64_Unsigned;

      macho::RelocationEntry MRE;
      MRE.Word0 = FixupOffset;
      MRE.Word1 = ((Index     <<  0) |
                   (IsPCRel   << 24) |
                   (Log2Size  << 25) |
                   (IsExtern  << 27) |
                   (Type      << 28));
      Relocations[Fragment->getParent()].push_back(MRE);

      if (B_Base) {
        Index = B_Base->getIndex();
        IsExtern = 1;
      }
      else {
        Index = B_SD.getFragment()->getParent()->getOrdinal() + 1;
        IsExtern = 0;
      }
      Type = macho::RIT_X86_64_Subtractor;
    } else {
      const MCSymbol *Symbol = &Target.getSymA()->getSymbol();
      MCSymbolData &SD = Asm.getSymbolData(*Symbol);
      const MCSymbolData *Base = Asm.getAtom(&SD);

      // Relocations inside debug sections always use local relocations when
      // possible. This seems to be done because the debugger doesn't fully
      // understand x86_64 relocation entries, and expects to find values that
      // have already been fixed up.
      if (Symbol->isInSection()) {
        const MCSectionMachO &Section = static_cast<const MCSectionMachO&>(
          Fragment->getParent()->getSection());
        if (Section.hasAttribute(MCSectionMachO::S_ATTR_DEBUG))
          Base = 0;
      }

      // x86_64 almost always uses external relocations, except when there is no
      // symbol to use as a base address (a local symbol with no preceeding
      // non-local symbol).
      if (Base) {
        Index = Base->getIndex();
        IsExtern = 1;

        // Add the local offset, if needed.
        if (Base != &SD)
          Value += Layout.getSymbolOffset(&SD) - Layout.getSymbolOffset(Base);
      } else if (Symbol->isInSection()) {
        // The index is the section ordinal (1-based).
        Index = SD.getFragment()->getParent()->getOrdinal() + 1;
        IsExtern = 0;
        Value += getSymbolAddress(&SD, Layout);

        if (IsPCRel)
          Value -= FixupAddress + (1 << Log2Size);
      } else if (Symbol->isVariable()) {
        const MCExpr *Value = Symbol->getVariableValue();
        int64_t Res;
        bool isAbs = Value->EvaluateAsAbsolute(Res, Layout, SectionAddress);
        if (isAbs) {
          FixedValue = Res;
          return;
        } else {
          report_fatal_error("unsupported relocation of variable '" +
                             Symbol->getName() + "'");
        }
      } else {
        report_fatal_error("unsupported relocation of undefined symbol '" +
                           Symbol->getName() + "'");
      }

      MCSymbolRefExpr::VariantKind Modifier = Target.getSymA()->getKind();
      if (IsPCRel) {
        if (IsRIPRel) {
          if (Modifier == MCSymbolRefExpr::VK_GOTPCREL) {
            // x86_64 distinguishes movq foo@GOTPCREL so that the linker can
            // rewrite the movq to an leaq at link time if the symbol ends up in
            // the same linkage unit.
            if (unsigned(Fixup.getKind()) == X86::reloc_riprel_4byte_movq_load)
              Type = macho::RIT_X86_64_GOTLoad;
            else
              Type = macho::RIT_X86_64_GOT;
          }  else if (Modifier == MCSymbolRefExpr::VK_TLVP) {
            Type = macho::RIT_X86_64_TLV;
          }  else if (Modifier != MCSymbolRefExpr::VK_None) {
            report_fatal_error("unsupported symbol modifier in relocation");
          } else {
            Type = macho::RIT_X86_64_Signed;

            // The Darwin x86_64 relocation format has a problem where it cannot
            // encode an address (L<foo> + <constant>) which is outside the atom
            // containing L<foo>. Generally, this shouldn't occur but it does
            // happen when we have a RIPrel instruction with data following the
            // relocation entry (e.g., movb $012, L0(%rip)). Even with the PCrel
            // adjustment Darwin x86_64 uses, the offset is still negative and
            // the linker has no way to recognize this.
            //
            // To work around this, Darwin uses several special relocation types
            // to indicate the offsets. However, the specification or
            // implementation of these seems to also be incomplete; they should
            // adjust the addend as well based on the actual encoded instruction
            // (the additional bias), but instead appear to just look at the
            // final offset.
            switch (-(Target.getConstant() + (1LL << Log2Size))) {
            case 1: Type = macho::RIT_X86_64_Signed1; break;
            case 2: Type = macho::RIT_X86_64_Signed2; break;
            case 4: Type = macho::RIT_X86_64_Signed4; break;
            }
          }
        } else {
          if (Modifier != MCSymbolRefExpr::VK_None)
            report_fatal_error("unsupported symbol modifier in branch "
                              "relocation");

          Type = macho::RIT_X86_64_Branch;
        }
      } else {
        if (Modifier == MCSymbolRefExpr::VK_GOT) {
          Type = macho::RIT_X86_64_GOT;
        } else if (Modifier == MCSymbolRefExpr::VK_GOTPCREL) {
          // GOTPCREL is allowed as a modifier on non-PCrel instructions, in
          // which case all we do is set the PCrel bit in the relocation entry;
          // this is used with exception handling, for example. The source is
          // required to include any necessary offset directly.
          Type = macho::RIT_X86_64_GOT;
          IsPCRel = 1;
        } else if (Modifier == MCSymbolRefExpr::VK_TLVP) {
          report_fatal_error("TLVP symbol modifier should have been rip-rel");
        } else if (Modifier != MCSymbolRefExpr::VK_None)
          report_fatal_error("unsupported symbol modifier in relocation");
        else
          Type = macho::RIT_X86_64_Unsigned;
      }
    }

    // x86_64 always writes custom values into the fixups.
    FixedValue = Value;

    // struct relocation_info (8 bytes)
    macho::RelocationEntry MRE;
    MRE.Word0 = FixupOffset;
    MRE.Word1 = ((Index     <<  0) |
                 (IsPCRel   << 24) |
                 (Log2Size  << 25) |
                 (IsExtern  << 27) |
                 (Type      << 28));
    Relocations[Fragment->getParent()].push_back(MRE);
  }

  void RecordScatteredRelocation(const MCAssembler &Asm,
                                 const MCAsmLayout &Layout,
                                 const MCFragment *Fragment,
                                 const MCFixup &Fixup, MCValue Target,
                                 uint64_t &FixedValue) {
    uint32_t FixupOffset = Layout.getFragmentOffset(Fragment)+Fixup.getOffset();
    unsigned IsPCRel = isFixupKindPCRel(Fixup.getKind());
    unsigned Log2Size = getFixupKindLog2Size(Fixup.getKind());
    unsigned Type = macho::RIT_Vanilla;

    // See <reloc.h>.
    const MCSymbol *A = &Target.getSymA()->getSymbol();
    MCSymbolData *A_SD = &Asm.getSymbolData(*A);

    if (!A_SD->getFragment())
      report_fatal_error("symbol '" + A->getName() +
                        "' can not be undefined in a subtraction expression");

    uint32_t Value = getSymbolAddress(A_SD, Layout);
    uint64_t SecAddr = getSectionAddress(A_SD->getFragment()->getParent());
    FixedValue += SecAddr;
    uint32_t Value2 = 0;

    if (const MCSymbolRefExpr *B = Target.getSymB()) {
      MCSymbolData *B_SD = &Asm.getSymbolData(B->getSymbol());

      if (!B_SD->getFragment())
        report_fatal_error("symbol '" + B->getSymbol().getName() +
                          "' can not be undefined in a subtraction expression");

      // Select the appropriate difference relocation type.
      //
      // Note that there is no longer any semantic difference between these two
      // relocation types from the linkers point of view, this is done solely
      // for pedantic compatibility with 'as'.
      Type = A_SD->isExternal() ? macho::RIT_Difference :
        macho::RIT_LocalDifference;
      Value2 = getSymbolAddress(B_SD, Layout);
      FixedValue -= getSectionAddress(B_SD->getFragment()->getParent());
    }

    // Relocations are written out in reverse order, so the PAIR comes first.
    if (Type == macho::RIT_Difference || Type == macho::RIT_LocalDifference) {
      macho::RelocationEntry MRE;
      MRE.Word0 = ((0         <<  0) |
                   (macho::RIT_Pair  << 24) |
                   (Log2Size  << 28) |
                   (IsPCRel   << 30) |
                   macho::RF_Scattered);
      MRE.Word1 = Value2;
      Relocations[Fragment->getParent()].push_back(MRE);
    }

    macho::RelocationEntry MRE;
    MRE.Word0 = ((FixupOffset <<  0) |
                 (Type        << 24) |
                 (Log2Size    << 28) |
                 (IsPCRel     << 30) |
                 macho::RF_Scattered);
    MRE.Word1 = Value;
    Relocations[Fragment->getParent()].push_back(MRE);
  }

  void RecordTLVPRelocation(const MCAssembler &Asm,
                            const MCAsmLayout &Layout,
                            const MCFragment *Fragment,
                            const MCFixup &Fixup, MCValue Target,
                            uint64_t &FixedValue) {
    assert(Target.getSymA()->getKind() == MCSymbolRefExpr::VK_TLVP &&
           !Is64Bit &&
           "Should only be called with a 32-bit TLVP relocation!");

    unsigned Log2Size = getFixupKindLog2Size(Fixup.getKind());
    uint32_t Value = Layout.getFragmentOffset(Fragment)+Fixup.getOffset();
    unsigned IsPCRel = 0;

    // Get the symbol data.
    MCSymbolData *SD_A = &Asm.getSymbolData(Target.getSymA()->getSymbol());
    unsigned Index = SD_A->getIndex();

    // We're only going to have a second symbol in pic mode and it'll be a
    // subtraction from the picbase. For 32-bit pic the addend is the difference
    // between the picbase and the next address.  For 32-bit static the addend
    // is zero.
    if (Target.getSymB()) {
      // If this is a subtraction then we're pcrel.
      uint32_t FixupAddress =
        getFragmentAddress(Fragment, Layout) + Fixup.getOffset();
      MCSymbolData *SD_B = &Asm.getSymbolData(Target.getSymB()->getSymbol());
      IsPCRel = 1;
      FixedValue = (FixupAddress - getSymbolAddress(SD_B, Layout) +
                    Target.getConstant());
      FixedValue += 1ULL << Log2Size;
    } else {
      FixedValue = 0;
    }

    // struct relocation_info (8 bytes)
    macho::RelocationEntry MRE;
    MRE.Word0 = Value;
    MRE.Word1 = ((Index     <<  0) |
                 (IsPCRel   << 24) |
                 (Log2Size  << 25) |
                 (1         << 27) | // Extern
                 (macho::RIT_TLV   << 28)); // Type
    Relocations[Fragment->getParent()].push_back(MRE);
  }

  void RecordRelocation(const MCAssembler &Asm, const MCAsmLayout &Layout,
                        const MCFragment *Fragment, const MCFixup &Fixup,
                        MCValue Target, uint64_t &FixedValue) {
    if (Is64Bit) {
      RecordX86_64Relocation(Asm, Layout, Fragment, Fixup, Target, FixedValue);
      return;
    }

    unsigned IsPCRel = isFixupKindPCRel(Fixup.getKind());
    unsigned Log2Size = getFixupKindLog2Size(Fixup.getKind());

    // If this is a 32-bit TLVP reloc it's handled a bit differently.
    if (Target.getSymA() &&
        Target.getSymA()->getKind() == MCSymbolRefExpr::VK_TLVP) {
      RecordTLVPRelocation(Asm, Layout, Fragment, Fixup, Target, FixedValue);
      return;
    }

    // If this is a difference or a defined symbol plus an offset, then we need
    // a scattered relocation entry.
    // Differences always require scattered relocations.
    if (Target.getSymB())
        return RecordScatteredRelocation(Asm, Layout, Fragment, Fixup,
                                         Target, FixedValue);

    // Get the symbol data, if any.
    MCSymbolData *SD = 0;
    if (Target.getSymA())
      SD = &Asm.getSymbolData(Target.getSymA()->getSymbol());

    // If this is an internal relocation with an offset, it also needs a
    // scattered relocation entry.
    uint32_t Offset = Target.getConstant();
    if (IsPCRel)
      Offset += 1 << Log2Size;
    if (Offset && SD && !doesSymbolRequireExternRelocation(SD))
      return RecordScatteredRelocation(Asm, Layout, Fragment, Fixup,
                                       Target, FixedValue);

    // See <reloc.h>.
    uint32_t FixupOffset = Layout.getFragmentOffset(Fragment)+Fixup.getOffset();
    unsigned Index = 0;
    unsigned IsExtern = 0;
    unsigned Type = 0;

    if (Target.isAbsolute()) { // constant
      // SymbolNum of 0 indicates the absolute section.
      //
      // FIXME: Currently, these are never generated (see code below). I cannot
      // find a case where they are actually emitted.
      Type = macho::RIT_Vanilla;
    } else {
      // Check whether we need an external or internal relocation.
      if (doesSymbolRequireExternRelocation(SD)) {
        IsExtern = 1;
        Index = SD->getIndex();
        // For external relocations, make sure to offset the fixup value to
        // compensate for the addend of the symbol address, if it was
        // undefined. This occurs with weak definitions, for example.
        if (!SD->Symbol->isUndefined())
          FixedValue -= getSymbolAddress(SD, Layout);
      } else {
        // The index is the section ordinal (1-based).
        Index = SD->getFragment()->getParent()->getOrdinal() + 1;
        FixedValue += getSectionAddress(SD->getFragment()->getParent());
        if (IsPCRel)
          FixedValue -= getSectionAddress(Fragment->getParent());
      }

      Type = macho::RIT_Vanilla;
    }

    // struct relocation_info (8 bytes)
    macho::RelocationEntry MRE;
    MRE.Word0 = FixupOffset;
    MRE.Word1 = ((Index     <<  0) |
                 (IsPCRel   << 24) |
                 (Log2Size  << 25) |
                 (IsExtern  << 27) |
                 (Type      << 28));
    Relocations[Fragment->getParent()].push_back(MRE);
  }

  void BindIndirectSymbols(MCAssembler &Asm) {
    // This is the point where 'as' creates actual symbols for indirect symbols
    // (in the following two passes). It would be easier for us to do this
    // sooner when we see the attribute, but that makes getting the order in the
    // symbol table much more complicated than it is worth.
    //
    // FIXME: Revisit this when the dust settles.

    // Bind non lazy symbol pointers first.
    unsigned IndirectIndex = 0;
    for (MCAssembler::indirect_symbol_iterator it = Asm.indirect_symbol_begin(),
           ie = Asm.indirect_symbol_end(); it != ie; ++it, ++IndirectIndex) {
      const MCSectionMachO &Section =
        cast<MCSectionMachO>(it->SectionData->getSection());

      if (Section.getType() != MCSectionMachO::S_NON_LAZY_SYMBOL_POINTERS)
        continue;

      // Initialize the section indirect symbol base, if necessary.
      if (!IndirectSymBase.count(it->SectionData))
        IndirectSymBase[it->SectionData] = IndirectIndex;

      Asm.getOrCreateSymbolData(*it->Symbol);
    }

    // Then lazy symbol pointers and symbol stubs.
    IndirectIndex = 0;
    for (MCAssembler::indirect_symbol_iterator it = Asm.indirect_symbol_begin(),
           ie = Asm.indirect_symbol_end(); it != ie; ++it, ++IndirectIndex) {
      const MCSectionMachO &Section =
        cast<MCSectionMachO>(it->SectionData->getSection());

      if (Section.getType() != MCSectionMachO::S_LAZY_SYMBOL_POINTERS &&
          Section.getType() != MCSectionMachO::S_SYMBOL_STUBS)
        continue;

      // Initialize the section indirect symbol base, if necessary.
      if (!IndirectSymBase.count(it->SectionData))
        IndirectSymBase[it->SectionData] = IndirectIndex;

      // Set the symbol type to undefined lazy, but only on construction.
      //
      // FIXME: Do not hardcode.
      bool Created;
      MCSymbolData &Entry = Asm.getOrCreateSymbolData(*it->Symbol, &Created);
      if (Created)
        Entry.setFlags(Entry.getFlags() | 0x0001);
    }
  }

  /// ComputeSymbolTable - Compute the symbol table data
  ///
  /// \param StringTable [out] - The string table data.
  /// \param StringIndexMap [out] - Map from symbol names to offsets in the
  /// string table.
  void ComputeSymbolTable(MCAssembler &Asm, SmallString<256> &StringTable,
                          std::vector<MachSymbolData> &LocalSymbolData,
                          std::vector<MachSymbolData> &ExternalSymbolData,
                          std::vector<MachSymbolData> &UndefinedSymbolData) {
    // Build section lookup table.
    DenseMap<const MCSection*, uint8_t> SectionIndexMap;
    unsigned Index = 1;
    for (MCAssembler::iterator it = Asm.begin(),
           ie = Asm.end(); it != ie; ++it, ++Index)
      SectionIndexMap[&it->getSection()] = Index;
    assert(Index <= 256 && "Too many sections!");

    // Index 0 is always the empty string.
    StringMap<uint64_t> StringIndexMap;
    StringTable += '\x00';

    // Build the symbol arrays and the string table, but only for non-local
    // symbols.
    //
    // The particular order that we collect the symbols and create the string
    // table, then sort the symbols is chosen to match 'as'. Even though it
    // doesn't matter for correctness, this is important for letting us diff .o
    // files.
    for (MCAssembler::symbol_iterator it = Asm.symbol_begin(),
           ie = Asm.symbol_end(); it != ie; ++it) {
      const MCSymbol &Symbol = it->getSymbol();

      // Ignore non-linker visible symbols.
      if (!Asm.isSymbolLinkerVisible(it->getSymbol()))
        continue;

      if (!it->isExternal() && !Symbol.isUndefined())
        continue;

      uint64_t &Entry = StringIndexMap[Symbol.getName()];
      if (!Entry) {
        Entry = StringTable.size();
        StringTable += Symbol.getName();
        StringTable += '\x00';
      }

      MachSymbolData MSD;
      MSD.SymbolData = it;
      MSD.StringIndex = Entry;

      if (Symbol.isUndefined()) {
        MSD.SectionIndex = 0;
        UndefinedSymbolData.push_back(MSD);
      } else if (Symbol.isAbsolute()) {
        MSD.SectionIndex = 0;
        ExternalSymbolData.push_back(MSD);
      } else {
        MSD.SectionIndex = SectionIndexMap.lookup(&Symbol.getSection());
        assert(MSD.SectionIndex && "Invalid section index!");
        ExternalSymbolData.push_back(MSD);
      }
    }

    // Now add the data for local symbols.
    for (MCAssembler::symbol_iterator it = Asm.symbol_begin(),
           ie = Asm.symbol_end(); it != ie; ++it) {
      const MCSymbol &Symbol = it->getSymbol();

      // Ignore non-linker visible symbols.
      if (!Asm.isSymbolLinkerVisible(it->getSymbol()))
        continue;

      if (it->isExternal() || Symbol.isUndefined())
        continue;

      uint64_t &Entry = StringIndexMap[Symbol.getName()];
      if (!Entry) {
        Entry = StringTable.size();
        StringTable += Symbol.getName();
        StringTable += '\x00';
      }

      MachSymbolData MSD;
      MSD.SymbolData = it;
      MSD.StringIndex = Entry;

      if (Symbol.isAbsolute()) {
        MSD.SectionIndex = 0;
        LocalSymbolData.push_back(MSD);
      } else {
        MSD.SectionIndex = SectionIndexMap.lookup(&Symbol.getSection());
        assert(MSD.SectionIndex && "Invalid section index!");
        LocalSymbolData.push_back(MSD);
      }
    }

    // External and undefined symbols are required to be in lexicographic order.
    std::sort(ExternalSymbolData.begin(), ExternalSymbolData.end());
    std::sort(UndefinedSymbolData.begin(), UndefinedSymbolData.end());

    // Set the symbol indices.
    Index = 0;
    for (unsigned i = 0, e = LocalSymbolData.size(); i != e; ++i)
      LocalSymbolData[i].SymbolData->setIndex(Index++);
    for (unsigned i = 0, e = ExternalSymbolData.size(); i != e; ++i)
      ExternalSymbolData[i].SymbolData->setIndex(Index++);
    for (unsigned i = 0, e = UndefinedSymbolData.size(); i != e; ++i)
      UndefinedSymbolData[i].SymbolData->setIndex(Index++);

    // The string table is padded to a multiple of 4.
    while (StringTable.size() % 4)
      StringTable += '\x00';
  }

  void computeSectionAddresses(const MCAssembler &Asm,
                               const MCAsmLayout &Layout) {
    uint64_t StartAddress = 0;
    const SmallVectorImpl<MCSectionData*> &Order = Layout.getSectionOrder();
    for (int i = 0, n = Order.size(); i != n ; ++i) {
      const MCSectionData *SD = Order[i];
      StartAddress = RoundUpToAlignment(StartAddress, SD->getAlignment());
      SectionAddress[SD] = StartAddress;
      StartAddress += Layout.getSectionAddressSize(SD);
      // Explicitly pad the section to match the alignment requirements of the
      // following one. This is for 'gas' compatibility, it shouldn't
      /// strictly be necessary.
      StartAddress += getPaddingSize(SD, Layout);
    }
  }

  void ExecutePostLayoutBinding(MCAssembler &Asm, const MCAsmLayout &Layout) {
    computeSectionAddresses(Asm, Layout);

    // Create symbol data for any indirect symbols.
    BindIndirectSymbols(Asm);

    // Compute symbol table information and bind symbol indices.
    ComputeSymbolTable(Asm, StringTable, LocalSymbolData, ExternalSymbolData,
                       UndefinedSymbolData);
  }


  bool IsFixupFullyResolved(const MCAssembler &Asm,
                            const MCValue Target,
                            bool IsPCRel,
                            const MCFragment *DF) const {
    // If we aren't using scattered symbols, the fixup is fully resolved.
    if (!Asm.getBackend().hasScatteredSymbols())
      return true;

    // Otherwise, determine whether this value is actually resolved; scattering
    // may cause atoms to move.

    // Check if we are using the "simple" resolution algorithm (e.g.,
    // i386).
    if (!Asm.getBackend().hasReliableSymbolDifference()) {
      const MCSection *BaseSection = 0;
      if (IsPCRel)
        BaseSection = &DF->getParent()->getSection();

      return isScatteredFixupFullyResolvedSimple(Asm, Target, BaseSection);
    }

    // Otherwise, compute the proper answer as reliably as possible.

    // If this is a PCrel relocation, find the base atom (identified by its
    // symbol) that the fixup value is relative to.
    const MCSymbolData *BaseSymbol = 0;
    if (IsPCRel) {
      BaseSymbol = DF->getAtom();
      if (!BaseSymbol)
        return false;
    }

    return isScatteredFixupFullyResolved(Asm, Target, BaseSymbol);
  }

  void WriteObject(MCAssembler &Asm, const MCAsmLayout &Layout) {
    unsigned NumSections = Asm.size();

    // The section data starts after the header, the segment load command (and
    // section headers) and the symbol table.
    unsigned NumLoadCommands = 1;
    uint64_t LoadCommandsSize = Is64Bit ?
      macho::SegmentLoadCommand64Size + NumSections * macho::Section64Size :
      macho::SegmentLoadCommand32Size + NumSections * macho::Section32Size;

    // Add the symbol table load command sizes, if used.
    unsigned NumSymbols = LocalSymbolData.size() + ExternalSymbolData.size() +
      UndefinedSymbolData.size();
    if (NumSymbols) {
      NumLoadCommands += 2;
      LoadCommandsSize += (macho::SymtabLoadCommandSize +
                           macho::DysymtabLoadCommandSize);
    }

    // Compute the total size of the section data, as well as its file size and
    // vm size.
    uint64_t SectionDataStart = (Is64Bit ? macho::Header64Size :
                                 macho::Header32Size) + LoadCommandsSize;
    uint64_t SectionDataSize = 0;
    uint64_t SectionDataFileSize = 0;
    uint64_t VMSize = 0;
    for (MCAssembler::const_iterator it = Asm.begin(),
           ie = Asm.end(); it != ie; ++it) {
      const MCSectionData &SD = *it;
      uint64_t Address = getSectionAddress(&SD);
      uint64_t Size = Layout.getSectionAddressSize(&SD);
      uint64_t FileSize = Layout.getSectionFileSize(&SD);
      FileSize += getPaddingSize(&SD, Layout);

      VMSize = std::max(VMSize, Address + Size);

      if (SD.getSection().isVirtualSection())
        continue;

      SectionDataSize = std::max(SectionDataSize, Address + Size);
      SectionDataFileSize = std::max(SectionDataFileSize, Address + FileSize);
    }

    // The section data is padded to 4 bytes.
    //
    // FIXME: Is this machine dependent?
    unsigned SectionDataPadding = OffsetToAlignment(SectionDataFileSize, 4);
    SectionDataFileSize += SectionDataPadding;

    // Write the prolog, starting with the header and load command...
    WriteHeader(NumLoadCommands, LoadCommandsSize,
                Asm.getSubsectionsViaSymbols());
    WriteSegmentLoadCommand(NumSections, VMSize,
                            SectionDataStart, SectionDataSize);

    // ... and then the section headers.
    uint64_t RelocTableEnd = SectionDataStart + SectionDataFileSize;
    for (MCAssembler::const_iterator it = Asm.begin(),
           ie = Asm.end(); it != ie; ++it) {
      std::vector<macho::RelocationEntry> &Relocs = Relocations[it];
      unsigned NumRelocs = Relocs.size();
      uint64_t SectionStart = SectionDataStart + getSectionAddress(it);
      WriteSection(Asm, Layout, *it, SectionStart, RelocTableEnd, NumRelocs);
      RelocTableEnd += NumRelocs * macho::RelocationInfoSize;
    }

    // Write the symbol table load command, if used.
    if (NumSymbols) {
      unsigned FirstLocalSymbol = 0;
      unsigned NumLocalSymbols = LocalSymbolData.size();
      unsigned FirstExternalSymbol = FirstLocalSymbol + NumLocalSymbols;
      unsigned NumExternalSymbols = ExternalSymbolData.size();
      unsigned FirstUndefinedSymbol = FirstExternalSymbol + NumExternalSymbols;
      unsigned NumUndefinedSymbols = UndefinedSymbolData.size();
      unsigned NumIndirectSymbols = Asm.indirect_symbol_size();
      unsigned NumSymTabSymbols =
        NumLocalSymbols + NumExternalSymbols + NumUndefinedSymbols;
      uint64_t IndirectSymbolSize = NumIndirectSymbols * 4;
      uint64_t IndirectSymbolOffset = 0;

      // If used, the indirect symbols are written after the section data.
      if (NumIndirectSymbols)
        IndirectSymbolOffset = RelocTableEnd;

      // The symbol table is written after the indirect symbol data.
      uint64_t SymbolTableOffset = RelocTableEnd + IndirectSymbolSize;

      // The string table is written after symbol table.
      uint64_t StringTableOffset =
        SymbolTableOffset + NumSymTabSymbols * (Is64Bit ? macho::Nlist64Size :
                                                macho::Nlist32Size);
      WriteSymtabLoadCommand(SymbolTableOffset, NumSymTabSymbols,
                             StringTableOffset, StringTable.size());

      WriteDysymtabLoadCommand(FirstLocalSymbol, NumLocalSymbols,
                               FirstExternalSymbol, NumExternalSymbols,
                               FirstUndefinedSymbol, NumUndefinedSymbols,
                               IndirectSymbolOffset, NumIndirectSymbols);
    }

    // Write the actual section data.
    for (MCAssembler::const_iterator it = Asm.begin(),
           ie = Asm.end(); it != ie; ++it) {
      Asm.WriteSectionData(it, Layout, this);

      uint64_t Pad = getPaddingSize(it, Layout);
      for (unsigned int i = 0; i < Pad; ++i)
        Write8(0);
    }

    // Write the extra padding.
    WriteZeros(SectionDataPadding);

    // Write the relocation entries.
    for (MCAssembler::const_iterator it = Asm.begin(),
           ie = Asm.end(); it != ie; ++it) {
      // Write the section relocation entries, in reverse order to match 'as'
      // (approximately, the exact algorithm is more complicated than this).
      std::vector<macho::RelocationEntry> &Relocs = Relocations[it];
      for (unsigned i = 0, e = Relocs.size(); i != e; ++i) {
        Write32(Relocs[e - i - 1].Word0);
        Write32(Relocs[e - i - 1].Word1);
      }
    }

    // Write the symbol table data, if used.
    if (NumSymbols) {
      // Write the indirect symbol entries.
      for (MCAssembler::const_indirect_symbol_iterator
             it = Asm.indirect_symbol_begin(),
             ie = Asm.indirect_symbol_end(); it != ie; ++it) {
        // Indirect symbols in the non lazy symbol pointer section have some
        // special handling.
        const MCSectionMachO &Section =
          static_cast<const MCSectionMachO&>(it->SectionData->getSection());
        if (Section.getType() == MCSectionMachO::S_NON_LAZY_SYMBOL_POINTERS) {
          // If this symbol is defined and internal, mark it as such.
          if (it->Symbol->isDefined() &&
              !Asm.getSymbolData(*it->Symbol).isExternal()) {
            uint32_t Flags = macho::ISF_Local;
            if (it->Symbol->isAbsolute())
              Flags |= macho::ISF_Absolute;
            Write32(Flags);
            continue;
          }
        }

        Write32(Asm.getSymbolData(*it->Symbol).getIndex());
      }

      // FIXME: Check that offsets match computed ones.

      // Write the symbol table entries.
      for (unsigned i = 0, e = LocalSymbolData.size(); i != e; ++i)
        WriteNlist(LocalSymbolData[i], Layout);
      for (unsigned i = 0, e = ExternalSymbolData.size(); i != e; ++i)
        WriteNlist(ExternalSymbolData[i], Layout);
      for (unsigned i = 0, e = UndefinedSymbolData.size(); i != e; ++i)
        WriteNlist(UndefinedSymbolData[i], Layout);

      // Write the string table.
      OS << StringTable.str();
    }
  }
};

}

MCObjectWriter *llvm::createMachObjectWriter(raw_ostream &OS, bool is64Bit,
                                             uint32_t CPUType,
                                             uint32_t CPUSubtype,
                                             bool IsLittleEndian) {
  return new MachObjectWriter(OS, is64Bit, CPUType, CPUSubtype, IsLittleEndian);
}
