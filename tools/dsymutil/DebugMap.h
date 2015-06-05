//===- tools/dsymutil/DebugMap.h - Generic debug map representation -------===//
//
//                             The LLVM Linker
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
///
/// This file contains the class declaration of the DebugMap
/// entity. A DebugMap lists all the object files linked together to
/// produce an executable along with the linked address of all the
/// atoms used in these object files.
/// The DebugMap is an input to the DwarfLinker class that will
/// extract the Dwarf debug information from the referenced object
/// files and link their usefull debug info together.
///
//===----------------------------------------------------------------------===//
#ifndef LLVM_TOOLS_DSYMUTIL_DEBUGMAP_H
#define LLVM_TOOLS_DSYMUTIL_DEBUGMAP_H

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/Triple.h"
#include "llvm/ADT/iterator_range.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/Support/ErrorOr.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/YAMLTraits.h"
#include <vector>

namespace llvm {
class raw_ostream;

namespace dsymutil {
class DebugMapObject;

/// \brief The DebugMap object stores the list of object files to
/// query for debug information along with the mapping between the
/// symbols' addresses in the object file to their linked address in
/// the linked binary.
///
/// A DebugMap producer could look like this:
/// DebugMap *DM = new DebugMap();
/// for (const auto &Obj: LinkedObjects) {
///     DebugMapObject &DMO = DM->addDebugMapObject(Obj.getPath());
///     for (const auto &Sym: Obj.getLinkedSymbols())
///         DMO.addSymbol(Sym.getName(), Sym.getObjectFileAddress(),
///                       Sym.getBinaryAddress());
/// }
///
/// A DebugMap consumer can then use the map to link the debug
/// information. For example something along the lines of:
/// for (const auto &DMO: DM->objects()) {
///     auto Obj = createBinary(DMO.getObjectFilename());
///     for (auto &DIE: Obj.getDwarfDIEs()) {
///         if (SymbolMapping *Sym = DMO.lookup(DIE.getName()))
///             DIE.relocate(Sym->ObjectAddress, Sym->BinaryAddress);
///         else
///             DIE.discardSubtree();
///     }
/// }
class DebugMap {
  Triple BinaryTriple;
  typedef std::vector<std::unique_ptr<DebugMapObject>> ObjectContainer;
  ObjectContainer Objects;

  /// For YAML IO support.
  ///@{
  friend yaml::MappingTraits<std::unique_ptr<DebugMap>>;
  friend yaml::MappingTraits<DebugMap>;
  DebugMap() = default;
  ///@}
public:
  DebugMap(const Triple &BinaryTriple) : BinaryTriple(BinaryTriple) {}

  typedef ObjectContainer::const_iterator const_iterator;

  iterator_range<const_iterator> objects() const {
    return make_range(begin(), end());
  }

  const_iterator begin() const { return Objects.begin(); }

  const_iterator end() const { return Objects.end(); }

  /// This function adds an DebugMapObject to the list owned by this
  /// debug map.
  DebugMapObject &addDebugMapObject(StringRef ObjectFilePath);

  const Triple &getTriple() const { return BinaryTriple; }

  void print(raw_ostream &OS) const;

#ifndef NDEBUG
  void dump() const;
#endif
};

/// \brief The DebugMapObject represents one object file described by
/// the DebugMap. It contains a list of mappings between addresses in
/// the object file and in the linked binary for all the linked atoms
/// in this object file.
class DebugMapObject {
public:
  struct SymbolMapping {
    yaml::Hex64 ObjectAddress;
    yaml::Hex64 BinaryAddress;
    yaml::Hex32 Size;
    SymbolMapping(uint64_t ObjectAddress, uint64_t BinaryAddress, uint32_t Size)
        : ObjectAddress(ObjectAddress), BinaryAddress(BinaryAddress),
          Size(Size) {}
    /// For YAML IO support
    SymbolMapping() = default;
  };

  typedef StringMapEntry<SymbolMapping> DebugMapEntry;

  /// \brief Adds a symbol mapping to this DebugMapObject.
  /// \returns false if the symbol was already registered. The request
  /// is discarded in this case.
  bool addSymbol(llvm::StringRef SymName, uint64_t ObjectAddress,
                 uint64_t LinkedAddress, uint32_t Size);

  /// \brief Lookup a symbol mapping.
  /// \returns null if the symbol isn't found.
  const DebugMapEntry *lookupSymbol(StringRef SymbolName) const;

  /// \brief Lookup an objectfile address.
  /// \returns null if the address isn't found.
  const DebugMapEntry *lookupObjectAddress(uint64_t Address) const;

  llvm::StringRef getObjectFilename() const { return Filename; }

  iterator_range<StringMap<SymbolMapping>::const_iterator> symbols() const {
    return make_range(Symbols.begin(), Symbols.end());
  }

  void print(raw_ostream &OS) const;
#ifndef NDEBUG
  void dump() const;
#endif
private:
  friend class DebugMap;
  /// DebugMapObjects can only be constructed by the owning DebugMap.
  DebugMapObject(StringRef ObjectFilename);

  std::string Filename;
  StringMap<SymbolMapping> Symbols;
  DenseMap<uint64_t, DebugMapEntry *> AddressToMapping;

  /// For YAMLIO support.
  ///@{
  typedef std::pair<std::string, SymbolMapping> YAMLSymbolMapping;
  friend yaml::MappingTraits<dsymutil::DebugMapObject>;
  friend yaml::SequenceTraits<std::vector<std::unique_ptr<DebugMapObject>>>;
  friend yaml::SequenceTraits<std::vector<YAMLSymbolMapping>>;
  DebugMapObject() = default;
 public:
  DebugMapObject &operator=(DebugMapObject RHS) {
    std::swap(Filename, RHS.Filename);
    std::swap(Symbols, RHS.Symbols);
    std::swap(AddressToMapping, RHS.AddressToMapping);
    return *this;
  }
  DebugMapObject(DebugMapObject &&RHS) {
    Filename = std::move(RHS.Filename);
    Symbols = std::move(RHS.Symbols);
    AddressToMapping = std::move(RHS.AddressToMapping);
  }
  ///@}
};
}
}

LLVM_YAML_IS_SEQUENCE_VECTOR(llvm::dsymutil::DebugMapObject::YAMLSymbolMapping)

namespace llvm {
namespace yaml {

using namespace llvm::dsymutil;

template <>
struct MappingTraits<std::pair<std::string, DebugMapObject::SymbolMapping>> {

  static void
  mapping(IO &io, std::pair<std::string, DebugMapObject::SymbolMapping> &s) {
    io.mapRequired("sym", s.first);
    io.mapRequired("objAddr", s.second.ObjectAddress);
    io.mapRequired("binAddr", s.second.BinaryAddress);
    io.mapOptional("size", s.second.Size);
  }

  static const bool flow = true;
};

template <> struct MappingTraits<dsymutil::DebugMapObject> {
  // Normalize/Denormalize between YAML and a DebugMapObject.
  struct YamlDMO {
    YamlDMO(IO &io) {}

    YamlDMO(IO &io, dsymutil::DebugMapObject &Obj) {
      Filename = Obj.Filename;
      Entries.reserve(Obj.Symbols.size());
      for (auto &Entry : Obj.Symbols)
        Entries.push_back(std::make_pair(Entry.getKey(), Entry.getValue()));
    }

    dsymutil::DebugMapObject denormalize(IO &IO) {
      void *Ctxt = IO.getContext();
      StringRef PrependPath = *reinterpret_cast<StringRef*>(Ctxt);
      SmallString<80> Path(PrependPath);
      sys::path::append(Path, Filename);
      dsymutil::DebugMapObject Res(Path);
      for (auto &Entry : Entries) {
        auto &Mapping = Entry.second;
        Res.addSymbol(Entry.first, Mapping.ObjectAddress, Mapping.BinaryAddress,
                      Mapping.Size);
      }
      return Res;
    }

    std::string Filename;
    std::vector<dsymutil::DebugMapObject::YAMLSymbolMapping> Entries;
  };

  static void mapping(IO &io, dsymutil::DebugMapObject &DMO) {
    MappingNormalization<YamlDMO, dsymutil::DebugMapObject> Norm(io, DMO);
    io.mapRequired("filename", Norm->Filename);
    io.mapRequired("symbols", Norm->Entries);
  }
};

template <> struct ScalarTraits<Triple> {

  static void output(const Triple &val, void *, llvm::raw_ostream &out) {
    out << val.str();
  }

  static StringRef input(StringRef scalar, void *, Triple &value) {
    value = Triple(scalar);
    return StringRef();
  }

  static bool mustQuote(StringRef) { return true; }
};

template <>
struct SequenceTraits<std::vector<std::unique_ptr<dsymutil::DebugMapObject>>> {

  static size_t
  size(IO &io, std::vector<std::unique_ptr<dsymutil::DebugMapObject>> &seq) {
    return seq.size();
  }

  static dsymutil::DebugMapObject &
  element(IO &, std::vector<std::unique_ptr<dsymutil::DebugMapObject>> &seq,
          size_t index) {
    if (index >= seq.size()) {
      seq.resize(index + 1);
      seq[index].reset(new dsymutil::DebugMapObject);
    }
    return *seq[index];
  }
};

template <> struct MappingTraits<dsymutil::DebugMap> {
  static void mapping(IO &io, dsymutil::DebugMap &DM) {
    io.mapRequired("triple", DM.BinaryTriple);
    io.mapOptional("objects", DM.Objects);
  }
};

 template <> struct MappingTraits<std::unique_ptr<dsymutil::DebugMap>> {
  static void mapping(IO &io, std::unique_ptr<dsymutil::DebugMap> &DM) {
    if (!DM)
      DM.reset(new DebugMap());
    io.mapRequired("triple", DM->BinaryTriple);
    io.mapOptional("objects", DM->Objects);
  }
};
}
}

#endif // LLVM_TOOLS_DSYMUTIL_DEBUGMAP_H
