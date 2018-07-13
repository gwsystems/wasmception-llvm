// RUN: not llvm-mc -triple=aarch64 -show-encoding -mattr=+sve  2>&1 < %s| FileCheck %s


// ------------------------------------------------------------------------- //
// Invalid element widths.

uunpklo z0.b, z0.b
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: uunpklo z0.b, z0.b
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

uunpklo z0.s, z0.b
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: uunpklo z0.s, z0.b
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

uunpklo z0.d, z0.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: uunpklo z0.d, z0.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:
