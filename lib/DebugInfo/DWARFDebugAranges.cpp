//===-- DWARFDebugAranges.cpp -----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "DWARFDebugAranges.h"
#include "DWARFCompileUnit.h"
#include "DWARFContext.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>
#include <cassert>
using namespace llvm;

// Compare function DWARFDebugAranges::Range structures
static bool RangeLessThan(const DWARFDebugAranges::Range &range1,
                          const DWARFDebugAranges::Range &range2) {
  return range1.LoPC < range2.LoPC;
}

namespace {
  class CountArangeDescriptors {
  public:
    CountArangeDescriptors(uint32_t &count_ref) : Count(count_ref) {}
    void operator()(const DWARFDebugArangeSet &Set) {
      Count += Set.getNumDescriptors();
    }
    uint32_t &Count;
  };

  class AddArangeDescriptors {
  public:
    AddArangeDescriptors(DWARFDebugAranges::RangeColl &Ranges,
                         DWARFDebugAranges::ParsedCUOffsetColl &CUOffsets)
      : RangeCollection(Ranges),
        CUOffsetCollection(CUOffsets) {}
    void operator()(const DWARFDebugArangeSet &Set) {
      DWARFDebugAranges::Range Range;
      Range.Offset = Set.getCompileUnitDIEOffset();
      CUOffsetCollection.insert(Range.Offset);

      for (uint32_t i = 0, n = Set.getNumDescriptors(); i < n; ++i) {
        const DWARFDebugArangeSet::Descriptor *ArangeDescPtr =
            Set.getDescriptor(i);
        Range.LoPC = ArangeDescPtr->Address;
        Range.Length = ArangeDescPtr->Length;

        // Insert each item in increasing address order so binary searching
        // can later be done!
        DWARFDebugAranges::RangeColl::iterator InsertPos =
          std::lower_bound(RangeCollection.begin(), RangeCollection.end(),
                           Range, RangeLessThan);
        RangeCollection.insert(InsertPos, Range);
      }

    }
    DWARFDebugAranges::RangeColl &RangeCollection;
    DWARFDebugAranges::ParsedCUOffsetColl &CUOffsetCollection;
  };
}

void DWARFDebugAranges::extract(DataExtractor DebugArangesData) {
  if (!DebugArangesData.isValidOffset(0))
    return;
  uint32_t offset = 0;

  typedef std::vector<DWARFDebugArangeSet> SetCollection;
  SetCollection sets;

  DWARFDebugArangeSet set;
  Range range;
  while (set.extract(DebugArangesData, &offset))
    sets.push_back(set);

  uint32_t count = 0;

  std::for_each(sets.begin(), sets.end(), CountArangeDescriptors(count));

  if (count > 0) {
    Aranges.reserve(count);
    AddArangeDescriptors range_adder(Aranges, ParsedCUOffsets);
    std::for_each(sets.begin(), sets.end(), range_adder);
  }
}

void DWARFDebugAranges::generate(DWARFContext *CTX) {
  if (CTX) {
    const uint32_t num_compile_units = CTX->getNumCompileUnits();
    for (uint32_t cu_idx = 0; cu_idx < num_compile_units; ++cu_idx) {
      if (DWARFCompileUnit *cu = CTX->getCompileUnitAtIndex(cu_idx)) {
        uint32_t CUOffset = cu->getOffset();
        if (ParsedCUOffsets.insert(CUOffset).second)
          cu->buildAddressRangeTable(this, true, CUOffset);
      }
    }
  }
  sort(true, /* overlap size */ 0);
}

void DWARFDebugAranges::dump(raw_ostream &OS) const {
  for (RangeCollIterator I = Aranges.begin(), E = Aranges.end(); I != E; ++I) {
    I->dump(OS);
  }
}

void DWARFDebugAranges::Range::dump(raw_ostream &OS) const {
  OS << format("{0x%8.8x}: [0x%8.8" PRIx64 " - 0x%8.8" PRIx64 ")\n",
               Offset, LoPC, HiPC());
}

void DWARFDebugAranges::appendRange(uint32_t CUOffset, uint64_t LowPC,
                                    uint64_t HighPC) {
  if (!Aranges.empty()) {
    if (Aranges.back().Offset == CUOffset && Aranges.back().HiPC() == LowPC) {
      Aranges.back().setHiPC(HighPC);
      return;
    }
  }
  Aranges.push_back(Range(LowPC, HighPC, CUOffset));
}

void DWARFDebugAranges::sort(bool Minimize, uint32_t OverlapSize) {
  const size_t orig_arange_size = Aranges.size();
  // Size of one? If so, no sorting is needed
  if (orig_arange_size <= 1)
    return;
  // Sort our address range entries
  std::stable_sort(Aranges.begin(), Aranges.end(), RangeLessThan);

  if (!Minimize)
    return;

  // Most address ranges are contiguous from function to function
  // so our new ranges will likely be smaller. We calculate the size
  // of the new ranges since although std::vector objects can be resized,
  // the will never reduce their allocated block size and free any excesss
  // memory, so we might as well start a brand new collection so it is as
  // small as possible.

  // First calculate the size of the new minimal arange vector
  // so we don't have to do a bunch of re-allocations as we
  // copy the new minimal stuff over to the new collection.
  size_t minimal_size = 1;
  for (size_t i = 1; i < orig_arange_size; ++i) {
    if (!Range::SortedOverlapCheck(Aranges[i-1], Aranges[i], OverlapSize))
      ++minimal_size;
  }

  // If the sizes are the same, then no consecutive aranges can be
  // combined, we are done.
  if (minimal_size == orig_arange_size)
    return;

  // Else, make a new RangeColl that _only_ contains what we need.
  RangeColl minimal_aranges;
  minimal_aranges.resize(minimal_size);
  uint32_t j = 0;
  minimal_aranges[j] = Aranges[0];
  for (size_t i = 1; i < orig_arange_size; ++i) {
    if (Range::SortedOverlapCheck(minimal_aranges[j], Aranges[i],
                                  OverlapSize)) {
      minimal_aranges[j].setHiPC (Aranges[i].HiPC());
    } else {
      // Only increment j if we aren't merging
      minimal_aranges[++j] = Aranges[i];
    }
  }
  assert (j+1 == minimal_size);

  // Now swap our new minimal aranges into place. The local
  // minimal_aranges will then contian the old big collection
  // which will get freed.
  minimal_aranges.swap(Aranges);
}

uint32_t DWARFDebugAranges::findAddress(uint64_t Address) const {
  if (!Aranges.empty()) {
    Range range(Address);
    RangeCollIterator begin = Aranges.begin();
    RangeCollIterator end = Aranges.end();
    RangeCollIterator pos = std::lower_bound(begin, end, range, RangeLessThan);

    if (pos != end && pos->LoPC <= Address && Address < pos->HiPC()) {
      return pos->Offset;
    } else if (pos != begin) {
      --pos;
      if (pos->LoPC <= Address && Address < pos->HiPC())
        return (*pos).Offset;
    }
  }
  return -1U;
}
