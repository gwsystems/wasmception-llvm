; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X64

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/sse2-builtins.c

define i64 @test_mm_cvtsd_si64(<2 x double> %a0) nounwind {
; X64-LABEL: test_mm_cvtsd_si64:
; X64:       # %bb.0:
; X64-NEXT:    cvtsd2si %xmm0, %rax
; X64-NEXT:    retq
  %res = call i64 @llvm.x86.sse2.cvtsd2si64(<2 x double> %a0)
  ret i64 %res
}
declare i64 @llvm.x86.sse2.cvtsd2si64(<2 x double>) nounwind readnone

define i64 @test_mm_cvtsi128_si64(<2 x i64> %a0) nounwind {
; X64-LABEL: test_mm_cvtsi128_si64:
; X64:       # %bb.0:
; X64-NEXT:    movq %xmm0, %rax
; X64-NEXT:    retq
  %res = extractelement <2 x i64> %a0, i32 0
  ret i64 %res
}

define <2 x double> @test_mm_cvtsi64_sd(<2 x double> %a0, i64 %a1) nounwind {
; X64-LABEL: test_mm_cvtsi64_sd:
; X64:       # %bb.0:
; X64-NEXT:    cvtsi2sdq %rdi, %xmm0
; X64-NEXT:    retq
  %res = call <2 x double> @llvm.x86.sse2.cvtsi642sd(<2 x double> %a0, i64 %a1)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse2.cvtsi642sd(<2 x double>, i64) nounwind readnone

define <2 x i64> @test_mm_cvtsi64_si128(i64 %a0) nounwind {
; X64-LABEL: test_mm_cvtsi64_si128:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdi, %xmm0
; X64-NEXT:    retq
  %res0 = insertelement <2 x i64> undef, i64 %a0, i32 0
  %res1 = insertelement <2 x i64> %res0, i64 0, i32 1
  ret <2 x i64> %res1
}

define i64 @test_mm_cvttsd_si64(<2 x double> %a0) nounwind {
; X64-LABEL: test_mm_cvttsd_si64:
; X64:       # %bb.0:
; X64-NEXT:    cvttsd2si %xmm0, %rax
; X64-NEXT:    retq
  %res = call i64 @llvm.x86.sse2.cvttsd2si64(<2 x double> %a0)
  ret i64 %res
}
declare i64 @llvm.x86.sse2.cvttsd2si64(<2 x double>) nounwind readnone

define <2 x i64> @test_mm_loadu_si64(i64* %a0) nounwind {
; X64-LABEL: test_mm_loadu_si64:
; X64:       # %bb.0:
; X64-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    retq
  %ld = load i64, i64* %a0, align 1
  %res0 = insertelement <2 x i64> undef, i64 %ld, i32 0
  %res1 = insertelement <2 x i64> %res0, i64 0, i32 1
  ret <2 x i64> %res1
}

define void @test_mm_stream_si64(i64 *%a0, i64 %a1) {
; X64-LABEL: test_mm_stream_si64:
; X64:       # %bb.0:
; X64-NEXT:    movntiq %rsi, (%rdi)
; X64-NEXT:    retq
  store i64 %a1, i64* %a0, align 1, !nontemporal !0
  ret void
}

!0 = !{i64 1}
