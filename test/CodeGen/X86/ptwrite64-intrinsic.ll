; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ptwrite | FileCheck %s

define void @test_ptwrite64(i64 %value) {
; CHECK-LABEL: test_ptwrite64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ptwriteq %rdi
; CHECK-NEXT:    retq
entry:
  call void @llvm.x86.ptwrite64(i64 %value)
  ret void
}

define void @test_ptwrite64p(i64* %pointer) {
; CHECK-LABEL: test_ptwrite64p:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ptwriteq (%rdi)
; CHECK-NEXT:    retq
entry:
  %value = load i64, i64* %pointer, align 8
  call void @llvm.x86.ptwrite64(i64 %value)
  ret void
}

declare void @llvm.x86.ptwrite64(i64)
