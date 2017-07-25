; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s

define <16 x i32> @test() {
; CHECK-LABEL: test:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpxord %zmm0, %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %0 = icmp slt <16 x i32> undef, undef
  %1 = select <16 x i1> %0, <16 x i32> undef, <16 x i32> zeroinitializer
  ret <16 x i32> %1
}
