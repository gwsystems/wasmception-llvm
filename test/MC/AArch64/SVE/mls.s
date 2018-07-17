// RUN: llvm-mc -triple=aarch64 -show-encoding -mattr=+sve < %s \
// RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
// RUN: not llvm-mc -triple=aarch64 -show-encoding < %s 2>&1 \
// RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d -mattr=+sve - | FileCheck %s --check-prefix=CHECK-INST
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d - | FileCheck %s --check-prefix=CHECK-UNKNOWN

mls z0.b, p7/m, z1.b, z31.b
// CHECK-INST: mls	z0.b, p7/m, z1.b, z31.b
// CHECK-ENCODING: [0x20,0x7c,0x1f,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: 20 7c 1f 04 <unknown>

mls z0.h, p7/m, z1.h, z31.h
// CHECK-INST: mls	z0.h, p7/m, z1.h, z31.h
// CHECK-ENCODING: [0x20,0x7c,0x5f,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: 20 7c 5f 04 <unknown>

mls z0.s, p7/m, z1.s, z31.s
// CHECK-INST: mls	z0.s, p7/m, z1.s, z31.s
// CHECK-ENCODING: [0x20,0x7c,0x9f,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: 20 7c 9f 04 <unknown>

mls z0.d, p7/m, z1.d, z31.d
// CHECK-INST: mls	z0.d, p7/m, z1.d, z31.d
// CHECK-ENCODING: [0x20,0x7c,0xdf,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: 20 7c df 04 <unknown>
