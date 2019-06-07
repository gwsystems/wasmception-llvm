// RUN: not llvm-mc -triple=aarch64 -show-encoding -mattr=+sve  2>&1 < %s| FileCheck %s


// ------------------------------------------------------------------------- //
// Tied operands must match

fabd    z0.h, p7/m, z1.h, z31.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: operand must match destination register
// CHECK-NEXT: fabd    z0.h, p7/m, z1.h, z31.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:


// ------------------------------------------------------------------------- //
// Invalid element widths.

fabd    z0.b, p7/m, z0.b, z31.b
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: fabd    z0.b, p7/m, z0.b, z31.b
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:

fabd    z0.h, p7/m, z0.h, z31.s
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid element width
// CHECK-NEXT: fabd    z0.h, p7/m, z0.h, z31.s
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:


// ------------------------------------------------------------------------- //
// Invalid predicate

fabd    z0.h, p8/m, z0.h, z31.h
// CHECK: [[@LINE-1]]:{{[0-9]+}}: error: invalid restricted predicate register, expected p0..p7 (without element suffix)
// CHECK-NEXT: fabd    z0.h, p8/m, z0.h, z31.h
// CHECK-NOT: [[@LINE-1]]:{{[0-9]+}}:
