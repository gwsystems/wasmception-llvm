// RUN: not llvm-mc -triple=aarch64 -show-encoding -mattr=+sve2  2>&1 < %s| FileCheck %s


// ------------------------------------------------------------------------- //
// z register out of range for index

mla z0.h, z1.h, z8.h[0]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: Invalid restricted vector register, expected z0.h..z7.h
// CHECK-NEXT: mla z0.h, z1.h, z8.h[0]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.s, z1.s, z8.s[0]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: Invalid restricted vector register, expected z0.s..z7.s
// CHECK-NEXT: mla z0.s, z1.s, z8.s[0]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.d, z1.d, z16.d[0]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: Invalid restricted vector register, expected z0.d..z15.d
// CHECK-NEXT: mla z0.d, z1.d, z16.d[0]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:


// ------------------------------------------------------------------------- //
// Invalid element index

mla z0.h, z1.h, z2.h[-1]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 7].
// CHECK-NEXT: mla z0.h, z1.h, z2.h[-1]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.h, z1.h, z2.h[8]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 7].
// CHECK-NEXT: mla z0.h, z1.h, z2.h[8]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.s, z1.s, z2.s[-1]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 3].
// CHECK-NEXT: mla z0.s, z1.s, z2.s[-1]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.s, z1.s, z2.s[4]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 3].
// CHECK-NEXT: mla z0.s, z1.s, z2.s[4]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.d, z1.d, z2.d[-1]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 1].
// CHECK-NEXT: mla z0.d, z1.d, z2.d[-1]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

mla z0.d, z1.d, z2.d[2]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: vector lane must be an integer in range [0, 1].
// CHECK-NEXT: mla z0.d, z1.d, z2.d[2]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:


// --------------------------------------------------------------------------//
// Negative tests for instructions that are incompatible with movprfx

movprfx z0.d, p0/z, z7.d
mla z0.d, z1.d, z7.d[1]
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: instruction is unpredictable when following a predicated movprfx, suggest using unpredicated movprfx
// CHECK-NEXT: mla z0.d, z1.d, z7.d[1]
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:
