; RUN: llc < %s -O2 -march=x86-64 -verify-machineinstrs | FileCheck %s

define void @pr21099(i64* %p) {
; CHECK-LABEL: pr21099
; CHECK: lock
; CHECK-NEXT: addq $-2147483648
; This number is INT32_MIN: 0x80000000UL
  %1 = atomicrmw add i64* %p, i64 -2147483648 seq_cst
  ret void
}
