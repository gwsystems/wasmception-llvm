//===- llvm/unittest/ADT/SmallStringTest.cpp ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// SmallString unit tests.
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"
#include "llvm/ADT/SmallString.h"
#include <stdarg.h>
#include <climits>
#include <cstring>

using namespace llvm;

namespace {

// Test fixture class
class SmallStringTest : public testing::Test {
protected:
  typedef SmallString<40> StringType;

  StringType theString;

  void assertEmpty(StringType & v) {
    // Size tests
    EXPECT_EQ(0u, v.size());
    EXPECT_TRUE(v.empty());
    // Iterator tests
    EXPECT_TRUE(v.begin() == v.end());
  }
};

// New string test.
TEST_F(SmallStringTest, EmptyStringTest) {
  SCOPED_TRACE("EmptyStringTest");
  assertEmpty(theString);
  EXPECT_TRUE(theString.rbegin() == theString.rend());
}

TEST_F(SmallStringTest, AppendUINT64_MAX) {
  SCOPED_TRACE("AppendUINT64_MAX");
  theString.clear();
  assertEmpty(theString);
  theString.append_uint(UINT64_MAX);
  EXPECT_TRUE(0 == strcmp(theString.c_str(),"18446744073709551615"));
}

TEST_F(SmallStringTest, AppendINT64_MIN) {
  SCOPED_TRACE("AppendINT64_MIN");
  theString.clear();
  assertEmpty(theString);
  theString.append_sint(INT64_MIN);
  EXPECT_TRUE(0 == strcmp(theString.c_str(),"-9223372036854775808"));
}

}

