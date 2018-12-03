//===- llvm/unittests/TextAPI/YAMLTest.cpp --------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===-----------------------------------------------------------------------===/

#include "llvm/ADT/StringRef.h"
#include "llvm/TextAPI/ELF/ELFStub.h"
#include "llvm/TextAPI/ELF/TBEHandler.h"
#include "llvm/Support/Error.h"
#include "gtest/gtest.h"
#include <string>

using namespace llvm;
using namespace llvm::ELF;
using namespace llvm::elfabi;

std::unique_ptr<ELFStub> readFromBuffer(const char Data[]) {
  TBEHandler Handler;

  StringRef Buf(Data);

  std::unique_ptr<ELFStub> Stub = Handler.readFile(Buf);
  EXPECT_NE(Stub.get(), nullptr);
  return Stub;
}

void compareByLine(StringRef LHS, StringRef RHS) {
  StringRef Line1;
  StringRef Line2;
  while (LHS.size() > 0 && RHS.size() > 0) {
    std::tie(Line1, LHS) = LHS.split('\n');
    std::tie(Line2, RHS) = RHS.split('\n');
    // Comparing StringRef objects works, but has messy output when not equal.
    // Using STREQ on StringRef.data() doesn't work since these substrings are
    // not null terminated.
    // This is inefficient, but forces null terminated strings that can be
    // cleanly compared.
    EXPECT_STREQ(Line1.str().data(), Line2.str().data());
  }
}

TEST(ElfYamlTextAPI, YAMLReadableTBE) {
  const char Data[] = "--- !tapi-tbe\n"
                      "TbeVersion: 1.0\n"
                      "SoName: test.so\n"
                      "Arch: x86_64\n"
                      "NeededLibs: [libc.so, libfoo.so, libbar.so]\n"
                      "Symbols:\n"
                      "  foo: { Type: Func, Undefined: true }\n"
                      "...\n";
  StringRef Buf = StringRef(Data);
  TBEHandler Handler;
  std::unique_ptr<ELFStub> Stub = Handler.readFile(Buf);
  EXPECT_NE(Stub.get(), nullptr);
  EXPECT_EQ(Stub->Arch, (uint16_t)llvm::ELF::EM_X86_64);
  EXPECT_STREQ(Stub->SoName.c_str(), "test.so");
  EXPECT_EQ(Stub->NeededLibs.size(), 3u);
  EXPECT_STREQ(Stub->NeededLibs[0].c_str(), "libc.so");
  EXPECT_STREQ(Stub->NeededLibs[1].c_str(), "libfoo.so");
  EXPECT_STREQ(Stub->NeededLibs[2].c_str(), "libbar.so");
}

TEST(ElfYamlTextAPI, YAMLReadsTBESymbols) {
  const char Data[] = "--- !tapi-tbe\n"
                      "TbeVersion: 1.0\n"
                      "SoName: test.so\n"
                      "Arch: x86_64\n"
                      "Symbols:\n"
                      "  bar: { Type: Object, Size: 42 }\n"
                      "  baz: { Type: TLS, Size: 3 }\n"
                      "  foo: { Type: Func, Warning: \"Deprecated!\" }\n"
                      "  nor: { Type: NoType, Undefined: true }\n"
                      "  not: { Type: File, Undefined: true, Size: 111, "
                      "Warning: \'All fields populated!\' }\n"
                      "...\n";
  std::unique_ptr<ELFStub> Stub = readFromBuffer(Data);
  EXPECT_EQ(Stub->Symbols.size(), 5u);

  auto Iterator = Stub->Symbols.begin();
  ELFSymbol const &SymBar = *Iterator++;
  EXPECT_STREQ(SymBar.Name.c_str(), "bar");
  EXPECT_EQ(SymBar.Size, 42u);
  EXPECT_EQ(SymBar.Type, ELFSymbolType::Object);
  EXPECT_FALSE(SymBar.Undefined);
  EXPECT_FALSE(SymBar.Warning.hasValue());

  ELFSymbol const &SymBaz = *Iterator++;
  EXPECT_STREQ(SymBaz.Name.c_str(), "baz");
  EXPECT_EQ(SymBaz.Size, 3u);
  EXPECT_EQ(SymBaz.Type, ELFSymbolType::TLS);
  EXPECT_FALSE(SymBaz.Undefined);
  EXPECT_FALSE(SymBaz.Warning.hasValue());

  ELFSymbol const &SymFoo = *Iterator++;
  EXPECT_STREQ(SymFoo.Name.c_str(), "foo");
  EXPECT_EQ(SymFoo.Size, 0u);
  EXPECT_EQ(SymFoo.Type, ELFSymbolType::Func);
  EXPECT_FALSE(SymFoo.Undefined);
  EXPECT_TRUE(SymFoo.Warning.hasValue());
  EXPECT_STREQ(SymFoo.Warning->c_str(), "Deprecated!");

  ELFSymbol const &SymNor = *Iterator++;
  EXPECT_STREQ(SymNor.Name.c_str(), "nor");
  EXPECT_EQ(SymNor.Size, 0u);
  EXPECT_EQ(SymNor.Type, ELFSymbolType::NoType);
  EXPECT_TRUE(SymNor.Undefined);
  EXPECT_FALSE(SymNor.Warning.hasValue());

  ELFSymbol const &SymNot = *Iterator++;
  EXPECT_STREQ(SymNot.Name.c_str(), "not");
  EXPECT_EQ(SymNot.Size, 111u);
  EXPECT_EQ(SymNot.Type, ELFSymbolType::Unknown);
  EXPECT_TRUE(SymNot.Undefined);
  EXPECT_TRUE(SymNot.Warning.hasValue());
  EXPECT_STREQ(SymNot.Warning->c_str(), "All fields populated!");
}

TEST(ElfYamlTextAPI, YAMLReadsNoTBESyms) {
  const char Data[] = "--- !tapi-tbe\n"
                      "TbeVersion: 1.0\n"
                      "SoName: test.so\n"
                      "Arch: x86_64\n"
                      "Symbols: {}\n"
                      "...\n";
  std::unique_ptr<ELFStub> Stub = readFromBuffer(Data);
  EXPECT_EQ(0u, Stub->Symbols.size());
}

TEST(ElfYamlTextAPI, YAMLUnreadableTBE) {
  TBEHandler Handler;
  // Can't read: wrong format/version.
  const char Data[] = "--- !tapi-tbz\n"
                      "TbeVersion: z.3\n"
                      "SoName: test.so\n"
                      "Arch: x86_64\n"
                      "Symbols:\n"
                      "  foo: { Type: Func, Undefined: true }\n";
  StringRef Buf = StringRef(Data);
  std::unique_ptr<ELFStub> Stub = Handler.readFile(Buf);
  EXPECT_EQ(Stub.get(), nullptr);
}

TEST(ElfYamlTextAPI, YAMLWritesTBESymbols) {
  const char Expected[] =
      "--- !tapi-tbe\n"
      "TbeVersion:      1.0\n"
      "SoName:          test.so\n"
      "Arch:            AArch64\n"
      "Symbols:         \n"
      "  foo:             { Type: NoType, Size: 99, Warning: Does nothing }\n"
      "  nor:             { Type: Func, Undefined: true }\n"
      "  not:             { Type: Unknown, Size: 12345678901234 }\n"
      "...\n";
  ELFStub Stub;
  Stub.TbeVersion = VersionTuple(1, 0);
  Stub.SoName = "test.so";
  Stub.Arch = ELF::EM_AARCH64;

  ELFSymbol SymFoo("foo");
  SymFoo.Size = 99u;
  SymFoo.Type = ELFSymbolType::NoType;
  SymFoo.Undefined = false;
  SymFoo.Warning = "Does nothing";

  ELFSymbol SymNor("nor");
  SymNor.Type = ELFSymbolType::Func;
  SymNor.Undefined = true;

  ELFSymbol SymNot("not");
  SymNot.Size = 12345678901234u;
  SymNot.Type = ELFSymbolType::Unknown;
  SymNot.Undefined = false;

  // Deliberately not in order to check that result is sorted.
  Stub.Symbols.insert(SymNot);
  Stub.Symbols.insert(SymFoo);
  Stub.Symbols.insert(SymNor);

  // Ensure move constructor works as expected.
  ELFStub Moved = std::move(Stub);

  std::string Result;
  raw_string_ostream OS(Result);
  TBEHandler Handler;
  EXPECT_FALSE(Handler.writeFile(OS, Moved));
  Result = OS.str();
  compareByLine(Result.c_str(), Expected);
}

TEST(ElfYamlTextAPI, YAMLWritesNoTBESyms) {
  const char Expected[] = "--- !tapi-tbe\n"
                          "TbeVersion:      1.0\n"
                          "SoName:          nosyms.so\n"
                          "Arch:            x86_64\n"
                          "NeededLibs:      [ libc.so, libfoo.so, libbar.so ]\n"
                          "Symbols:         {}\n"
                          "...\n";
  ELFStub Stub;
  Stub.TbeVersion = VersionTuple(1, 0);
  Stub.SoName = "nosyms.so";
  Stub.Arch = ELF::EM_X86_64;
  Stub.NeededLibs.push_back("libc.so");
  Stub.NeededLibs.push_back("libfoo.so");
  Stub.NeededLibs.push_back("libbar.so");

  std::string Result;
  raw_string_ostream OS(Result);
  TBEHandler Handler;
  EXPECT_FALSE(Handler.writeFile(OS, Stub));
  Result = OS.str();
  compareByLine(Result.c_str(), Expected);
}
