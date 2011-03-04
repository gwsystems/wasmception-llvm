//===-- SlotIndexes.cpp - Slot Indexes Pass  ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "slotindexes"

#include "llvm/CodeGen/SlotIndexes.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"

using namespace llvm;

char SlotIndexes::ID = 0;
INITIALIZE_PASS(SlotIndexes, "slotindexes",
                "Slot index numbering", false, false)

STATISTIC(NumRenumPasses, "Number of slot index renumber passes");

void SlotIndexes::getAnalysisUsage(AnalysisUsage &au) const {
  au.setPreservesAll();
  MachineFunctionPass::getAnalysisUsage(au);
}

void SlotIndexes::releaseMemory() {
  mi2iMap.clear();
  mbb2IdxMap.clear();
  idx2MBBMap.clear();
  clearList();
}

bool SlotIndexes::runOnMachineFunction(MachineFunction &fn) {

  // Compute numbering as follows:
  // Grab an iterator to the start of the index list.
  // Iterate over all MBBs, and within each MBB all MIs, keeping the MI
  // iterator in lock-step (though skipping it over indexes which have
  // null pointers in the instruction field).
  // At each iteration assert that the instruction pointed to in the index
  // is the same one pointed to by the MI iterator. This 

  // FIXME: This can be simplified. The mi2iMap_, Idx2MBBMap, etc. should
  // only need to be set up once after the first numbering is computed.

  mf = &fn;
  initList();

  // Check that the list contains only the sentinal.
  assert(indexListHead->getNext() == 0 &&
         "Index list non-empty at initial numbering?");
  assert(idx2MBBMap.empty() &&
         "Index -> MBB mapping non-empty at initial numbering?");
  assert(mbb2IdxMap.empty() &&
         "MBB -> Index mapping non-empty at initial numbering?");
  assert(mi2iMap.empty() &&
         "MachineInstr -> Index mapping non-empty at initial numbering?");

  functionSize = 0;
  unsigned index = 0;

  push_back(createEntry(0, index));

  // Iterate over the function.
  for (MachineFunction::iterator mbbItr = mf->begin(), mbbEnd = mf->end();
       mbbItr != mbbEnd; ++mbbItr) {
    MachineBasicBlock *mbb = &*mbbItr;

    // Insert an index for the MBB start.
    SlotIndex blockStartIndex(back(), SlotIndex::LOAD);

    for (MachineBasicBlock::iterator miItr = mbb->begin(), miEnd = mbb->end();
         miItr != miEnd; ++miItr) {
      MachineInstr *mi = miItr;
      if (mi->isDebugValue())
        continue;

      // Insert a store index for the instr.
      push_back(createEntry(mi, index += SlotIndex::InstrDist));

      // Save this base index in the maps.
      mi2iMap.insert(std::make_pair(mi, SlotIndex(back(), SlotIndex::LOAD)));
 
      ++functionSize;
    }

    // We insert one blank instructions between basic blocks.
    push_back(createEntry(0, index += SlotIndex::InstrDist));

    SlotIndex blockEndIndex(back(), SlotIndex::LOAD);
    mbb2IdxMap.insert(
      std::make_pair(mbb, std::make_pair(blockStartIndex, blockEndIndex)));

    idx2MBBMap.push_back(IdxMBBPair(blockStartIndex, mbb));
  }

  // Sort the Idx2MBBMap
  std::sort(idx2MBBMap.begin(), idx2MBBMap.end(), Idx2MBBCompare());

  DEBUG(dump());

  // And we're done!
  return false;
}

void SlotIndexes::renumberIndexes() {
  // Renumber updates the index of every element of the index list.
  DEBUG(dbgs() << "\n*** Renumbering SlotIndexes ***\n");
  ++NumRenumPasses;

  unsigned index = 0;

  for (IndexListEntry *curEntry = front(); curEntry != getTail();
       curEntry = curEntry->getNext()) {
    curEntry->setIndex(index);
    index += SlotIndex::InstrDist;
  }
}

void SlotIndexes::dump() const {
  for (const IndexListEntry *itr = front(); itr != getTail();
       itr = itr->getNext()) {
    dbgs() << itr->getIndex() << " ";

    if (itr->getInstr() != 0) {
      dbgs() << *itr->getInstr();
    } else {
      dbgs() << "\n";
    }
  }

  for (MBB2IdxMap::const_iterator itr = mbb2IdxMap.begin();
       itr != mbb2IdxMap.end(); ++itr) {
    dbgs() << "MBB " << itr->first->getNumber() << " (" << itr->first << ") - ["
           << itr->second.first << ", " << itr->second.second << "]\n";
  }
}

// Print a SlotIndex to a raw_ostream.
void SlotIndex::print(raw_ostream &os) const {
  if (isValid())
    os << entry().getIndex() << "LudS"[getSlot()];
  else
    os << "invalid";
}

// Dump a SlotIndex to stderr.
void SlotIndex::dump() const {
  print(dbgs());
  dbgs() << "\n";
}

