//===- unittest/Support/YAMLRemarksSerializerTest.cpp --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Remarks/Remark.h"
#include "llvm/Remarks/RemarkSerializer.h"
#include "gtest/gtest.h"

using namespace llvm;

static void check(const remarks::Remark &R, StringRef Expected,
                  Optional<StringRef> ExpectedStrTab = None) {
  std::string Buf;
  raw_string_ostream OS(Buf);
  remarks::UseStringTable UseStrTab = ExpectedStrTab.hasValue()
                                          ? remarks::UseStringTable::Yes
                                          : remarks::UseStringTable::No;
  remarks::YAMLSerializer S(OS, UseStrTab);
  S.emit(R);
  EXPECT_EQ(OS.str(), Expected);
  if (ExpectedStrTab) {
    Buf.clear();
    EXPECT_TRUE(S.StrTab);
    S.StrTab->serialize(OS);
    EXPECT_EQ(OS.str(), *ExpectedStrTab);
  }
}

TEST(YAMLRemarks, SerializerRemark) {
  remarks::Remark R;
  R.RemarkType = remarks::Type::Missed;
  R.PassName = "pass";
  R.RemarkName = "name";
  R.FunctionName = "func";
  R.Loc = remarks::RemarkLocation{"path", 3, 4};
  R.Hotness = 5;
  R.Args.emplace_back();
  R.Args.back().Key = "key";
  R.Args.back().Val = "value";
  R.Args.emplace_back();
  R.Args.back().Key = "keydebug";
  R.Args.back().Val = "valuedebug";
  R.Args.back().Loc = remarks::RemarkLocation{"argpath", 6, 7};
  check(R, "--- !Missed\n"
           "Pass:            pass\n"
           "Name:            name\n"
           "DebugLoc:        { File: path, Line: 3, Column: 4 }\n"
           "Function:        func\n"
           "Hotness:         5\n"
           "Args:\n"
           "  - key:             value\n"
           "  - keydebug:        valuedebug\n"
           "    DebugLoc:        { File: argpath, Line: 6, Column: 7 }\n"
           "...\n");
}

TEST(YAMLRemarks, SerializerRemarkStrTab) {
  remarks::Remark R;
  R.RemarkType = remarks::Type::Missed;
  R.PassName = "pass";
  R.RemarkName = "name";
  R.FunctionName = "func";
  R.Loc = remarks::RemarkLocation{"path", 3, 4};
  R.Hotness = 5;
  R.Args.emplace_back();
  R.Args.back().Key = "key";
  R.Args.back().Val = "value";
  R.Args.emplace_back();
  R.Args.back().Key = "keydebug";
  R.Args.back().Val = "valuedebug";
  R.Args.back().Loc = remarks::RemarkLocation{"argpath", 6, 7};
  check(R,
        "--- !Missed\n"
        "Pass:            0\n"
        "Name:            1\n"
        "DebugLoc:        { File: 3, Line: 3, Column: 4 }\n"
        "Function:        2\n"
        "Hotness:         5\n"
        "Args:\n"
        "  - key:             4\n"
        "  - keydebug:        5\n"
        "    DebugLoc:        { File: 6, Line: 6, Column: 7 }\n"
        "...\n",
        StringRef("pass\0name\0func\0path\0value\0valuedebug\0argpath\0", 45));
}
