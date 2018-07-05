// RUN: llvm-mc -triple=aarch64 -show-encoding -mattr=+sve < %s \
// RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
// RUN: not llvm-mc -triple=aarch64 -show-encoding < %s 2>&1 \
// RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d -mattr=+sve - | FileCheck %s --check-prefix=CHECK-INST
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d - | FileCheck %s --check-prefix=CHECK-UNKNOWN

frintn   z31.h, p7/m, z31.h
// CHECK-INST: frintn	z31.h, p7/m, z31.h
// CHECK-ENCODING: [0xff,0xbf,0x40,0x65]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf 40 65 <unknown>

frintn   z31.s, p7/m, z31.s
// CHECK-INST: frintn	z31.s, p7/m, z31.s
// CHECK-ENCODING: [0xff,0xbf,0x80,0x65]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf 80 65 <unknown>

frintn   z31.d, p7/m, z31.d
// CHECK-INST: frintn	z31.d, p7/m, z31.d
// CHECK-ENCODING: [0xff,0xbf,0xc0,0x65]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf c0 65 <unknown>
