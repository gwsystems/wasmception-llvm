//===- llvm/unittest/Support/IntegersSubsetTest.cpp - IntegersSubset tests ===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/APInt.h"
#include "llvm/Support/IntegersSubset.h" 
#include "llvm/Support/IntegersSubsetMapping.h"

#include "gtest/gtest.h"

#include <vector>

using namespace llvm;

namespace {
  
  class Int : public APInt {
  public:
    Int(uint64_t V) : APInt(64, V) {}
    bool operator < (const APInt& RHS) const { return ult(RHS); }
    bool operator > (const APInt& RHS) const { return ugt(RHS); }
    bool operator <= (const APInt& RHS) const { return ule(RHS); }
    bool operator >= (const APInt& RHS) const { return uge(RHS); }
  };
  
  typedef IntRange<Int> Range;
  typedef IntegersSubsetGeneric<Int> Subset;
  typedef IntegersSubsetMapping<unsigned,Subset,Int> Mapping;
  
  TEST(IntegersSubsetTest, GeneralTest) {
    
    // Test construction.

    std::vector<Range> Ranges;
    Ranges.reserve(3);

    // Initialize Subset as union of three pairs:
    // { {0, 8}, {10, 18}, {20, 28} }
    for (unsigned i = 0; i < 3; ++i)
      Ranges.push_back(Range(Int(i*10), Int(i*10 + 8)));

    Subset TheSubset(Ranges);
    
    for (unsigned i = 0; i < 3; ++i) {
      EXPECT_EQ(TheSubset.getItem(i).getLow(), Int(i*10));
      EXPECT_EQ(TheSubset.getItem(i).getHigh(), Int(i*10 + 8));
    }
    
    EXPECT_EQ(TheSubset.getNumItems(), 3ULL);
    
    // Test belonging to range.
    
    EXPECT_TRUE(TheSubset.isSatisfies(Int(5)));
    EXPECT_FALSE(TheSubset.isSatisfies(Int(9)));
    
    // Test when subset contains the only item.
    
    Ranges.clear();
    Ranges.push_back(Range(Int(10), Int(10)));
    
    Subset TheSingleNumber(Ranges);
    
    EXPECT_TRUE(TheSingleNumber.isSingleNumber());
    
    Ranges.push_back(Range(Int(12), Int(15)));
    
    Subset NotASingleNumber(Ranges);
    
    EXPECT_FALSE(NotASingleNumber.isSingleNumber());
    
    // Test when subset contains items that are not a ranges but
    // the single numbers.
    
    Ranges.clear();
    Ranges.push_back(Range(Int(10), Int(10)));
    Ranges.push_back(Range(Int(15), Int(19)));
    
    Subset WithSingleNumberItems(Ranges);
    
    EXPECT_TRUE(WithSingleNumberItems.isSingleNumber(0));
    EXPECT_FALSE(WithSingleNumberItems.isSingleNumber(1));
    
    // Test size of subset. Note subset itself may be not optimized (improper),
    // so it may contain duplicates, and the size of subset { {0, 9} {5, 9} }
    // will 15 instead of 10.
    
    Ranges.clear();
    Ranges.push_back(Range(Int(0), Int(9)));
    Ranges.push_back(Range(Int(5), Int(9)));
    
    Subset NotOptimizedSubset(Ranges);
    
    EXPECT_EQ(NotOptimizedSubset.getSize(), 15ULL);

    // Test access to a single value.
    // getSingleValue(idx) method represents subset as flat numbers collection,
    // so subset { {0, 3}, {8, 10} } will represented as array
    // { 0, 1, 2, 3, 8, 9, 10 }.
    
    Ranges.clear();
    Ranges.push_back(Range(Int(0), Int(3)));
    Ranges.push_back(Range(Int(8), Int(10)));
    
    Subset OneMoreSubset(Ranges);
    
    EXPECT_EQ(OneMoreSubset.getSingleValue(5), Int(9));
  }
  
  TEST(IntegersSubsetTest, MappingTest) {

    Mapping::Cases TheCases;
    
    unsigned Successors[3] = {0, 1, 2};
    
    // Test construction.
    
    Mapping TheMapping;
    for (unsigned i = 0; i < 3; ++i)
      TheMapping.add(Int(10*i), Int(10*i + 9), Successors + i);
    TheMapping.add(Int(111), Int(222), Successors);
    TheMapping.removeItem(--TheMapping.end());
    
    TheMapping.getCases(TheCases);
    
    EXPECT_EQ(TheCases.size(), 3ULL);
    
    for (unsigned i = 0; i < 3; ++i) {
      Mapping::Cases::iterator CaseIt = TheCases.begin();
      std::advance(CaseIt, i);  
      EXPECT_EQ(CaseIt->first, Successors + i);
      EXPECT_EQ(CaseIt->second.getNumItems(), 1ULL);
      EXPECT_EQ(CaseIt->second.getItem(0), Range(Int(10*i), Int(10*i + 9)));
    }
    
    // Test verification.
    
    Mapping ImproperMapping;
    ImproperMapping.add(Int(10), Int(11), Successors + 0);
    ImproperMapping.add(Int(11), Int(12), Successors + 1);
    
    Mapping::RangeIterator ErrItem;
    EXPECT_FALSE(ImproperMapping.verify(ErrItem));
    EXPECT_EQ(ErrItem, --ImproperMapping.end());
    
    Mapping ProperMapping;
    ProperMapping.add(Int(10), Int(11), Successors + 0);
    ProperMapping.add(Int(12), Int(13), Successors + 1);
    
    EXPECT_TRUE(ProperMapping.verify(ErrItem));
    
    // Test optimization.
    
    Mapping ToBeOptimized;
    
    for (unsigned i = 0; i < 3; ++i) {
      ToBeOptimized.add(Int(i * 10), Int(i * 10 + 1), Successors + i);
      ToBeOptimized.add(Int(i * 10 + 2), Int(i * 10 + 9), Successors + i);
    }
    
    ToBeOptimized.optimize();
    
    TheCases.clear();
    ToBeOptimized.getCases(TheCases);
    
    EXPECT_EQ(TheCases.size(), 3ULL);
    
    for (unsigned i = 0; i < 3; ++i) {
      Mapping::Cases::iterator CaseIt = TheCases.begin();
      std::advance(CaseIt, i);  
      EXPECT_EQ(CaseIt->first, Successors + i);
      EXPECT_EQ(CaseIt->second.getNumItems(), 1ULL);
      EXPECT_EQ(CaseIt->second.getItem(0), Range(Int(i * 10), Int(i * 10 + 9)));
    }
  }
}
