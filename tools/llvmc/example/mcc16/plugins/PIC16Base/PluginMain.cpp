#include "AutoGenerated.inc"

#include "llvm/System/Path.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace llvmc {
  extern char *ProgramName;
}

// Returns the platform specific directory separator via #ifdefs.
static std::string GetDirSeparator(void) {
#ifdef __linux__
  return "/";
#else
  return "\\";
#endif
}

namespace hooks {
// Get the dir where c16 executables reside.
std::string GetBinDir (void) {
  // Construct a Path object from the program name.  
  void *P = (void*) (intptr_t) GetBinDir;
  sys::Path ProgramFullPath 
    = sys::Path::GetMainExecutable(llvmc::ProgramName, P);

  // Get the dir name for the program. It's last component should be 'bin'.
  std::string BinDir = ProgramFullPath.getDirname();

  // llvm::errs() << "BinDir: " << BinDir << '\n';
  return BinDir + GetDirSeparator();
}

// Get the Top-level Installation dir for c16.
std::string GetInstallDir (void) {
  sys::Path BinDirPath = sys::Path(GetBinDir());

  // Go one more level up to get the install dir.
  std::string InstallDir  = BinDirPath.getDirname();
  
  return InstallDir + GetDirSeparator();
}

// Get the dir where the c16 header files reside.
std::string GetStdHeadersDir (void) {
  return GetInstallDir() + "include";
}

// Get the dir where the assembler header files reside.
std::string GetStdAsmHeadersDir (void) {
  return GetInstallDir() + "inc";
}

// Get the dir where the linker scripts reside.
std::string GetStdLinkerScriptsDir (void) {
  return GetInstallDir() + "lkr";
}

// Get the dir where startup code, intrinsics and lib reside.
std::string GetStdLibsDir (void) {
  return GetInstallDir() + "lib";
}
}
