//===- lib/Linker/Linker.cpp - Basic Linker functionality  ----------------===//
// 
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Reid Spencer and is distributed under the 
// University of Illinois Open Source License. See LICENSE.TXT for details.
// 
//===----------------------------------------------------------------------===//
//
// This file contains basic Linker functionality that all usages will need.
//
//===----------------------------------------------------------------------===//

#include "llvm/Linker.h"
#include "llvm/Module.h"
#include "llvm/Bytecode/Reader.h"
#include <iostream>

using namespace llvm;

Linker::Linker(const std::string& progname, unsigned flags)
  : Composite(0)
  , LibPaths()
  , Flags(flags)
  , Error()
  , ProgramName(progname)
{
  Composite = new Module(progname);
}

Linker::Linker(const std::string& progname, Module* aModule, unsigned flags)
  : Composite(aModule)
  , LibPaths()
  , Flags(flags)
  , Error()
  , ProgramName(progname)
{
}

Linker::~Linker() {
  delete Composite;
}

bool 
Linker::error(const std::string& message) {
  Error = message;
  if (!(Flags&QuietErrors)) {
    std::cerr << ProgramName << ": error: " << message << "\n";
  }
  return true;
}

bool
Linker::warning(const std::string& message) {
  Error = message;
  if (!(Flags&QuietErrors)) {
    std::cerr << ProgramName << ": warning: " << message << "\n";
  }
  return false;
}

void
Linker::verbose(const std::string& message) {
  if (Flags&Verbose) {
    std::cerr << "  " << message << "\n";
  }
}

void
Linker::addPath(const sys::Path& path) {
  assert(path.isDirectory() && "Can only insert directories into the path");
  LibPaths.push_back(path);
}

void
Linker::addPaths(const std::vector<std::string>& paths) {
  for (unsigned i = 0; i != paths.size(); ++i) {
    sys::Path aPath;
    aPath.setDirectory(paths[i]);
    LibPaths.push_back(aPath);
  }
}

void
Linker::addSystemPaths() {
  sys::Path::GetBytecodeLibraryPaths(LibPaths);
  LibPaths.insert(LibPaths.begin(),sys::Path("./"));
}

Module*
Linker::releaseModule() {
  Module* result = Composite;
  LibPaths.clear();
  Error.clear();
  Composite = 0;
  Flags = 0;
  return result;
}

// LoadObject - Read in and parse the bytecode file named by FN and return the
// module it contains (wrapped in an auto_ptr), or auto_ptr<Module>() and set 
// Error if an error occurs.
std::auto_ptr<Module> 
Linker::LoadObject(const sys::Path &FN) {
  std::string ParseErrorMessage;
  Module *Result = ParseBytecodeFile(FN.toString(), &ParseErrorMessage);
  if (Result) 
    return std::auto_ptr<Module>(Result);
  Error = "Bytecode file '" + FN.toString() + "' could not be loaded";
  if (ParseErrorMessage.size()) 
    Error += ": " + ParseErrorMessage;
  return std::auto_ptr<Module>();
}

// IsLibrary - Determine if "Name" is a library in "Directory". Return 
// a non-empty sys::Path if its found, an empty one otherwise.
static inline sys::Path IsLibrary(const std::string& Name, 
                                  const sys::Path& Directory) {

  assert(Directory.isDirectory() && "Need to specify a directory");
  sys::Path FullPath(Directory);
  FullPath.appendFile("lib" + Name);

  FullPath.appendSuffix("a");
  if (FullPath.isArchive())
    return FullPath;

  FullPath.elideSuffix();
  FullPath.appendSuffix("bca");
  if (FullPath.isArchive())
    return FullPath;

  FullPath.elideSuffix();
  FullPath.appendSuffix(&(LTDL_SHLIB_EXT[1]));
  if (FullPath.isDynamicLibrary())
    return FullPath;

  FullPath.clear();
  return FullPath;
}

/// FindLib - Try to convert Filename into the name of a file that we can open,
/// if it does not already name a file we can open, by first trying to open
/// Filename, then libFilename.[suffix] for each of a set of several common
/// library suffixes, in each of the directories in LibPaths. Returns an empty 
/// Path if no matching file can be found.
///
sys::Path 
Linker::FindLib(const std::string &Filename) 
{
  // Determine if the pathname can be found as it stands.
  sys::Path FilePath(Filename);
  if (FilePath.readable() && 
      (FilePath.isArchive() || FilePath.isDynamicLibrary()))
    return FilePath;

  // Iterate over the directories in Paths to see if we can find the library
  // there.
  for (unsigned Index = 0; Index != LibPaths.size(); ++Index) {
    sys::Path Directory(LibPaths[Index]);
    sys::Path FullPath = IsLibrary(Filename,Directory);
    if (!FullPath.isEmpty())
      return FullPath;
  }
  return sys::Path();
}
