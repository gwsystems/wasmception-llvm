// RUN: not llvm-mc -triple thumbv8 -show-encoding -mattr=+sb < %s 2>&1 | FileCheck %s

it eq
sbeq

// CHECK: instruction 'sb' is not predicable, but condition code specified
