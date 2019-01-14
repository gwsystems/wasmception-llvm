; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,SSE,SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE42
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX,AVX512,AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw | FileCheck %s --check-prefixes=CHECK,AVX,AVX512,AVX512BW

declare  i32 @llvm.usub.sat.i32  (i32, i32)
declare  i64 @llvm.usub.sat.i64  (i64, i64)
declare  <8 x i16> @llvm.usub.sat.v8i16(<8 x i16>, <8 x i16>)

; fold (usub_sat x, undef) -> 0
define i32 @combine_undef_i32(i32 %a0) {
; CHECK-LABEL: combine_undef_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
  %res = call i32 @llvm.usub.sat.i32(i32 %a0, i32 undef)
  ret i32 %res
}

define <8 x i16> @combine_undef_v8i16(<8 x i16> %a0) {
; SSE-LABEL: combine_undef_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_undef_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> undef, <8 x i16> %a0)
  ret <8 x i16> %res
}

; fold (usub_sat c1, c2) -> c3
define i32 @combine_constfold_i32() {
; CHECK-LABEL: combine_constfold_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    movl $100, %eax
; CHECK-NEXT:    subl $-1, %eax
; CHECK-NEXT:    cmovbl %ecx, %eax
; CHECK-NEXT:    retq
  %res = call i32 @llvm.usub.sat.i32(i32 100, i32 4294967295)
  ret i32 %res
}

define <8 x i16> @combine_constfold_v8i16() {
; SSE-LABEL: combine_constfold_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,255,65535,65535,65281,1,1]
; SSE-NEXT:    psubusw {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_constfold_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = [0,1,255,65535,65535,65281,1,1]
; AVX-NEXT:    vpsubusw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> <i16 0, i16 1, i16 255, i16 65535, i16 -1, i16 -255, i16 -65535, i16 1>, <8 x i16> <i16 1, i16 65535, i16 1, i16 65535, i16 1, i16 65535, i16 1, i16 65535>)
  ret <8 x i16> %res
}

define <8 x i16> @combine_constfold_undef_v8i16() {
; SSE-LABEL: combine_constfold_undef_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa {{.*#+}} xmm0 = <u,1,u,65535,65535,65281,1,1>
; SSE-NEXT:    psubusw {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_constfold_undef_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <u,1,u,65535,65535,65281,1,1>
; AVX-NEXT:    vpsubusw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> <i16 undef, i16 1, i16 undef, i16 65535, i16 -1, i16 -255, i16 -65535, i16 1>, <8 x i16> <i16 1, i16 undef, i16 undef, i16 65535, i16 1, i16 65535, i16 1, i16 65535>)
  ret <8 x i16> %res
}

; fold (usub_sat x, 0) -> x
define i32 @combine_zero_i32(i32 %a0) {
; CHECK-LABEL: combine_zero_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %1 = call i32 @llvm.usub.sat.i32(i32 %a0, i32 0)
  ret i32 %1
}

define <8 x i16> @combine_zero_v8i16(<8 x i16> %a0) {
; CHECK-LABEL: combine_zero_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %a0, <8 x i16> zeroinitializer)
  ret <8 x i16> %1
}

; fold (usub_sat x, x) -> 0
define i32 @combine_self_i32(i32 %a0) {
; CHECK-LABEL: combine_self_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    subl %edi, %edi
; CHECK-NEXT:    cmovael %edi, %eax
; CHECK-NEXT:    retq
  %1 = call i32 @llvm.usub.sat.i32(i32 %a0, i32 %a0)
  ret i32 %1
}

define <8 x i16> @combine_self_v8i16(<8 x i16> %a0) {
; SSE-LABEL: combine_self_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    psubusw %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_self_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubusw %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %a0, <8 x i16> %a0)
  ret <8 x i16> %1
}
