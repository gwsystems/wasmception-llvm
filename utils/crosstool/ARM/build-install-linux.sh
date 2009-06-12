#!/bin/bash
#
# Compiles and installs a Linux/x86_64 -> Linux/ARM crosstool based on LLVM and
# LLVM-GCC-4.2 using SVN snapshots in provided tarballs.

set -o nounset
set -o errexit

echo -n "Welcome to LLVM Linux/X86_64 -> Linux/ARM crosstool "
echo "builder/installer; some steps will require sudo privileges."

readonly INSTALL_ROOT="${INSTALL_ROOT:-/usr/local}"
# Both $USER and root *must* have read/write access to this dir.
readonly SCRATCH_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/llvm-project.XXXXXX")
readonly SRC_ROOT="${SCRATCH_ROOT}/src"
readonly OBJ_ROOT="${SCRATCH_ROOT}/obj"

readonly CROSS_HOST="x86_64-unknown-linux-gnu"
readonly CROSS_TARGET="arm-none-linux-gnueabi"

readonly CODE_SOURCERY="${INSTALL_ROOT}/codesourcery"
readonly CODE_SOURCERY_PKG_PATH="${CODE_SOURCERY_PKG_PATH:-${HOME}/codesourcery}"
readonly CODE_SOURCERY_PKG="arm-2007q3-51-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2"
readonly CODE_SOURCERY_ROOT="${CODE_SOURCERY}/arm-2007q3"
readonly CODE_SOURCERY_BIN="${CODE_SOURCERY_ROOT}/bin"
# Make sure ${CROSS_TARGET}-* binutils are in command path
export PATH="${CODE_SOURCERY_BIN}:${PATH}"

readonly CROSS_TARGET_AS="${CODE_SOURCERY_BIN}/${CROSS_TARGET}-as"
readonly CROSS_TARGET_LD="${CODE_SOURCERY_BIN}/${CROSS_TARGET}-ld"

readonly SYSROOT="${CODE_SOURCERY_ROOT}/${CROSS_TARGET}/libc"

readonly LLVM_PROJECT="${INSTALL_ROOT}/llvm-project"
readonly LLVM_INSTALL_ROOT="${LLVM_PROJECT}/${CROSS_HOST}/${CROSS_TARGET}"
readonly LLVM_PKG_PATH="${LLVM_PKG_PATH:-${HOME}/llvm-project/snapshots}"

# Latest SVN revision known to be working in this configuration.
readonly LLVM_DEFAULT_REV="70786"

readonly LLVM_PKG="llvm-${LLVM_SVN_REV:-${LLVM_DEFAULT_REV}}.tar.bz2"
readonly LLVM_SRC_DIR="${SRC_ROOT}/llvm"
readonly LLVM_OBJ_DIR="${OBJ_ROOT}/llvm"
readonly LLVM_INSTALL_DIR="${LLVM_INSTALL_ROOT}/llvm"

readonly LLVMGCC_PKG="llvm-gcc-4.2-${LLVMGCC_SVN_REV:-${LLVM_DEFAULT_REV}}.tar.bz2"
readonly LLVMGCC_SRC_DIR="${SRC_ROOT}/llvm-gcc-4.2"
readonly LLVMGCC_OBJ_DIR="${OBJ_ROOT}/llvm-gcc-4.2"
readonly LLVMGCC_INSTALL_DIR="${LLVM_INSTALL_ROOT}/llvm-gcc-4.2"

readonly MAKE_OPTS="-j2"

# Verify we aren't going to install into an existing directory as this might
# create problems as we won't have a clean install.
verifyNotDir() {
  if [[ -d $1 ]]; then
    echo "Install dir $1 already exists; remove it to continue."
    exit
  fi
}

# Params:
#   $1: directory to be created
#   $2: optional mkdir command prefix, e.g. "sudo"
createDir() {
  if [[ ! -e $1 ]]; then
    ${2:-} mkdir -p $1
  elif [[ -e $1 && ! -d $1 ]]; then
    echo "$1 exists but is not a directory; exiting."
    exit 3
  fi
}

sudoCreateDir() {
  createDir $1 sudo
  sudo chown ${USER} $1
}

# Prints out and runs the command, but without logging -- intended for use with
# lightweight commands that don't have useful output to parse, e.g. mkdir, tar,
# etc.
runCommand() {
  local message="$1"
  shift
  echo "=> $message"
  echo "==> Running: $*"
  $*
}

runAndLog() {
  local message="$1"
  local log_file="$2"
  shift 2
  echo "=> $message; log in $log_file"
  echo "==> Running: $*"
  # Pop-up a terminal with the output of the current command?
  # e.g.: xterm -e /bin/bash -c "$* >| tee $log_file"
  $* &> $log_file
  if [[ $? != 0 ]]; then
    echo "Error occurred: see most recent log file for details."
    exit
  fi
}

installCodeSourcery() {
  # Create CodeSourcery dir, if necessary.
  verifyNotDir ${CODE_SOURCERY}
  sudoCreateDir ${CODE_SOURCERY}

  # Unpack the tarball.
  if [[ ! -d ${CODE_SOURCERY_ROOT} ]]; then
    cd ${CODE_SOURCERY}
    runCommand "Unpacking CodeSourcery in ${CODE_SOURCERY}" \
        tar jxf ${CODE_SOURCERY_PKG_PATH}/${CODE_SOURCERY_PKG}
  else
    echo "CodeSourcery install dir already exists."
  fi

  # Verify our CodeSourcery toolchain installation.
  if [[ ! -d "${SYSROOT}" ]]; then
    echo -n "Error: CodeSourcery does not contain libc for ${CROSS_TARGET}: "
    echo "${SYSROOT} not found."
    exit
  fi

  for tool in ${CROSS_TARGET_AS} ${CROSS_TARGET_LD}; do
    if [[ ! -e $tool ]]; then
      echo "${tool} not found; exiting."
      exit
    fi
  done
}

installLLVM() {
  verifyNotDir ${LLVM_INSTALL_DIR}
  sudoCreateDir ${LLVM_INSTALL_DIR}

  # Unpack LLVM tarball; should create the directory "llvm".
  cd ${SRC_ROOT}
  runCommand "Unpacking LLVM" tar jxf ${LLVM_PKG_PATH}/${LLVM_PKG}

  # Configure, build, and install LLVM.
  createDir ${LLVM_OBJ_DIR}
  cd ${LLVM_OBJ_DIR}
  runAndLog "Configuring LLVM" ${LLVM_OBJ_DIR}/llvm-configure.log \
      ${LLVM_SRC_DIR}/configure \
      --disable-jit \
      --enable-optimized \
      --prefix=${LLVM_INSTALL_DIR} \
      --target=${CROSS_TARGET} \
      --with-llvmgccdir=${LLVMGCC_INSTALL_DIR}
  runAndLog "Building LLVM" ${LLVM_OBJ_DIR}/llvm-build.log \
      make ${MAKE_OPTS}
  runAndLog "Installing LLVM" ${LLVM_OBJ_DIR}/llvm-install.log \
      make ${MAKE_OPTS} install
}

installLLVMGCC() {
  verifyNotDir ${LLVMGCC_INSTALL_DIR}
  sudoCreateDir ${LLVMGCC_INSTALL_DIR}

  # Unpack LLVM-GCC tarball; should create the directory "llvm-gcc-4.2".
  cd ${SRC_ROOT}
  runCommand "Unpacking LLVM-GCC" tar jxf ${LLVM_PKG_PATH}/${LLVMGCC_PKG}

  # Configure, build, and install LLVM-GCC.
  createDir ${LLVMGCC_OBJ_DIR}
  cd ${LLVMGCC_OBJ_DIR}
  runAndLog "Configuring LLVM-GCC" ${LLVMGCC_OBJ_DIR}/llvmgcc-configure.log \
      ${LLVMGCC_SRC_DIR}/configure \
      --enable-languages=c,c++ \
      --enable-llvm=${LLVM_INSTALL_DIR} \
      --prefix=${LLVMGCC_INSTALL_DIR} \
      --program-prefix=llvm- \
      --target=${CROSS_TARGET} \
      --with-gnu-as=${CROSS_TARGET_AS} \
      --with-gnu-ld=${CROSS_TARGET_LD} \
      --with-sysroot=${SYSROOT}
  runAndLog "Building LLVM-GCC" ${LLVMGCC_OBJ_DIR}/llvmgcc-build.log \
      make
  runAndLog "Installing LLVM-GCC" ${LLVMGCC_OBJ_DIR}/llvmgcc-install.log \
      make install
}

echo "Building in ${SCRATCH_ROOT}; installing in ${INSTALL_ROOT}"

createDir ${SRC_ROOT}
createDir ${OBJ_ROOT}

installCodeSourcery
installLLVM
installLLVMGCC

echo "Done."
