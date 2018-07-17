// RUN: not llvm-mc -triple=aarch64 -show-encoding -mattr=+sve  2>&1 < %s| FileCheck %s


// ------------------------------------------------------------------------- //
// Invalid predicate

mla z0.h, p8/m, z1.h, z2.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: restricted predicate has range [0, 7].
// CHECK-NEXT: mla z0.h, p8/m, z1.h, z2.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:


// ------------------------------------------------------------------------- //
// Invalid element width

mla z0.s, p7/m, z1.h, z2.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: mla z0.s, p7/m, z1.h, z2.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:
