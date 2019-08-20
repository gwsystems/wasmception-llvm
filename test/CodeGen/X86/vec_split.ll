; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-- -mattr=sse4.1 < %s | FileCheck %s -check-prefix=SSE4
; RUN: llc -mtriple=x86_64-- -mattr=avx < %s | FileCheck %s -check-prefix=AVX1
; RUN: llc -mtriple=x86_64-- -mattr=avx2 < %s | FileCheck %s -check-prefix=AVX2

define <16 x i16> @split16(<16 x i16> %a, <16 x i16> %b, <16 x i8> %__mask) {
; SSE4-LABEL: split16:
; SSE4:       # %bb.0:
; SSE4-NEXT:    pminuw %xmm2, %xmm0
; SSE4-NEXT:    pminuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: split16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: split16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %1 = icmp ult <16 x i16> %a, %b
  %2 = select <16 x i1> %1, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %2
}

define <32 x i16> @split32(<32 x i16> %a, <32 x i16> %b, <32 x i8> %__mask) {
; SSE4-LABEL: split32:
; SSE4:       # %bb.0:
; SSE4-NEXT:    pminuw %xmm4, %xmm0
; SSE4-NEXT:    pminuw %xmm5, %xmm1
; SSE4-NEXT:    pminuw %xmm6, %xmm2
; SSE4-NEXT:    pminuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: split32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: split32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpminuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
  %1 = icmp ult <32 x i16> %a, %b
  %2 = select <32 x i1> %1, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %2
}

; PR19492
define i128 @split128(<2 x i128> %a, <2 x i128> %b) {
; SSE4-LABEL: split128:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movq %rdx, %rax
; SSE4-NEXT:    addq %r8, %rdi
; SSE4-NEXT:    adcq %r9, %rsi
; SSE4-NEXT:    addq {{[0-9]+}}(%rsp), %rax
; SSE4-NEXT:    adcq {{[0-9]+}}(%rsp), %rcx
; SSE4-NEXT:    addq %rdi, %rax
; SSE4-NEXT:    adcq %rsi, %rcx
; SSE4-NEXT:    movq %rcx, %rdx
; SSE4-NEXT:    retq
;
; AVX1-LABEL: split128:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movq %rdx, %rax
; AVX1-NEXT:    addq %r8, %rdi
; AVX1-NEXT:    adcq %r9, %rsi
; AVX1-NEXT:    addq {{[0-9]+}}(%rsp), %rax
; AVX1-NEXT:    adcq {{[0-9]+}}(%rsp), %rcx
; AVX1-NEXT:    addq %rdi, %rax
; AVX1-NEXT:    adcq %rsi, %rcx
; AVX1-NEXT:    movq %rcx, %rdx
; AVX1-NEXT:    retq
;
; AVX2-LABEL: split128:
; AVX2:       # %bb.0:
; AVX2-NEXT:    movq %rdx, %rax
; AVX2-NEXT:    addq %r8, %rdi
; AVX2-NEXT:    adcq %r9, %rsi
; AVX2-NEXT:    addq {{[0-9]+}}(%rsp), %rax
; AVX2-NEXT:    adcq {{[0-9]+}}(%rsp), %rcx
; AVX2-NEXT:    addq %rdi, %rax
; AVX2-NEXT:    adcq %rsi, %rcx
; AVX2-NEXT:    movq %rcx, %rdx
; AVX2-NEXT:    retq
  %add = add nsw <2 x i128> %a, %b
  %rdx.shuf = shufflevector <2 x i128> %add, <2 x i128> undef, <2 x i32> <i32 undef, i32 0>
  %bin.rdx = add <2 x i128> %add, %rdx.shuf
  %e = extractelement <2 x i128> %bin.rdx, i32 1
  ret i128 %e
}
