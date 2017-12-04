; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+sse4a | FileCheck %s --check-prefix=X32 --check-prefix=X32-SSE
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+sse4a,+avx | FileCheck %s --check-prefix=X32 --check-prefix=X32-AVX
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4a | FileCheck %s --check-prefix=X64 --check-prefix=X64-SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4a,+avx | FileCheck %s --check-prefix=X64 --check-prefix=X64-AVX

define <2 x i64> @test_extrqi(<2 x i64> %x) nounwind uwtable ssp {
; X32-LABEL: test_extrqi:
; X32:       # %bb.0:
; X32-NEXT:    extrq $2, $3, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_extrqi:
; X64:       # %bb.0:
; X64-NEXT:    extrq $2, $3, %xmm0
; X64-NEXT:    retq
  %1 = tail call <2 x i64> @llvm.x86.sse4a.extrqi(<2 x i64> %x, i8 3, i8 2)
  ret <2 x i64> %1
}

define <2 x i64> @test_extrqi_domain(<2 x i64> *%p) nounwind uwtable ssp {
; X32-SSE-LABEL: test_extrqi_domain:
; X32-SSE:       # %bb.0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    movdqa (%eax), %xmm0
; X32-SSE-NEXT:    extrq $2, $3, %xmm0
; X32-SSE-NEXT:    retl
;
; X32-AVX-LABEL: test_extrqi_domain:
; X32-AVX:       # %bb.0:
; X32-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-AVX-NEXT:    vmovdqa (%eax), %xmm0
; X32-AVX-NEXT:    extrq $2, $3, %xmm0
; X32-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_extrqi_domain:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movdqa (%rdi), %xmm0
; X64-SSE-NEXT:    extrq $2, $3, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_extrqi_domain:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovdqa (%rdi), %xmm0
; X64-AVX-NEXT:    extrq $2, $3, %xmm0
; X64-AVX-NEXT:    retq
  %1 = load <2 x i64>, <2 x i64> *%p
  %2 = tail call <2 x i64> @llvm.x86.sse4a.extrqi(<2 x i64> %1, i8 3, i8 2)
  ret <2 x i64> %2
}

declare <2 x i64> @llvm.x86.sse4a.extrqi(<2 x i64>, i8, i8) nounwind

define <2 x i64> @test_extrq(<2 x i64> %x, <2 x i64> %y) nounwind uwtable ssp {
; X32-LABEL: test_extrq:
; X32:       # %bb.0:
; X32-NEXT:    extrq %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_extrq:
; X64:       # %bb.0:
; X64-NEXT:    extrq %xmm1, %xmm0
; X64-NEXT:    retq
  %1 = bitcast <2 x i64> %y to <16 x i8>
  %2 = tail call <2 x i64> @llvm.x86.sse4a.extrq(<2 x i64> %x, <16 x i8> %1) nounwind
  ret <2 x i64> %2
}

define <2 x i64> @test_extrq_domain(<2 x i64> *%p, <2 x i64> %y) nounwind uwtable ssp {
; X32-SSE-LABEL: test_extrq_domain:
; X32-SSE:       # %bb.0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    movdqa (%eax), %xmm1
; X32-SSE-NEXT:    extrq %xmm0, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X32-AVX-LABEL: test_extrq_domain:
; X32-AVX:       # %bb.0:
; X32-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-AVX-NEXT:    vmovdqa (%eax), %xmm1
; X32-AVX-NEXT:    extrq %xmm0, %xmm1
; X32-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X32-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_extrq_domain:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movdqa (%rdi), %xmm1
; X64-SSE-NEXT:    extrq %xmm0, %xmm1
; X64-SSE-NEXT:    movdqa %xmm1, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_extrq_domain:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovdqa (%rdi), %xmm1
; X64-AVX-NEXT:    extrq %xmm0, %xmm1
; X64-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X64-AVX-NEXT:    retq
  %1 = load <2 x i64>, <2 x i64> *%p
  %2 = bitcast <2 x i64> %y to <16 x i8>
  %3 = tail call <2 x i64> @llvm.x86.sse4a.extrq(<2 x i64> %1, <16 x i8> %2) nounwind
  ret <2 x i64> %3
}

declare <2 x i64> @llvm.x86.sse4a.extrq(<2 x i64>, <16 x i8>) nounwind

define <2 x i64> @test_insertqi(<2 x i64> %x, <2 x i64> %y) nounwind uwtable ssp {
; X32-LABEL: test_insertqi:
; X32:       # %bb.0:
; X32-NEXT:    insertq $6, $5, %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_insertqi:
; X64:       # %bb.0:
; X64-NEXT:    insertq $6, $5, %xmm1, %xmm0
; X64-NEXT:    retq
  %1 = tail call <2 x i64> @llvm.x86.sse4a.insertqi(<2 x i64> %x, <2 x i64> %y, i8 5, i8 6)
  ret <2 x i64> %1
}

define <2 x i64> @test_insertqi_domain(<2 x i64> *%p, <2 x i64> %y) nounwind uwtable ssp {
; X32-SSE-LABEL: test_insertqi_domain:
; X32-SSE:       # %bb.0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    movdqa (%eax), %xmm1
; X32-SSE-NEXT:    insertq $6, $5, %xmm0, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X32-AVX-LABEL: test_insertqi_domain:
; X32-AVX:       # %bb.0:
; X32-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-AVX-NEXT:    vmovdqa (%eax), %xmm1
; X32-AVX-NEXT:    insertq $6, $5, %xmm0, %xmm1
; X32-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X32-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_insertqi_domain:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movdqa (%rdi), %xmm1
; X64-SSE-NEXT:    insertq $6, $5, %xmm0, %xmm1
; X64-SSE-NEXT:    movdqa %xmm1, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_insertqi_domain:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovdqa (%rdi), %xmm1
; X64-AVX-NEXT:    insertq $6, $5, %xmm0, %xmm1
; X64-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X64-AVX-NEXT:    retq
  %1 = load <2 x i64>, <2 x i64> *%p
  %2 = tail call <2 x i64> @llvm.x86.sse4a.insertqi(<2 x i64> %1, <2 x i64> %y, i8 5, i8 6)
  ret <2 x i64> %2
}

declare <2 x i64> @llvm.x86.sse4a.insertqi(<2 x i64>, <2 x i64>, i8, i8) nounwind

define <2 x i64> @test_insertq(<2 x i64> %x, <2 x i64> %y) nounwind uwtable ssp {
; X32-LABEL: test_insertq:
; X32:       # %bb.0:
; X32-NEXT:    insertq %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_insertq:
; X64:       # %bb.0:
; X64-NEXT:    insertq %xmm1, %xmm0
; X64-NEXT:    retq
  %1 = tail call <2 x i64> @llvm.x86.sse4a.insertq(<2 x i64> %x, <2 x i64> %y) nounwind
  ret <2 x i64> %1
}

define <2 x i64> @test_insertq_domain(<2 x i64> *%p, <2 x i64> %y) nounwind uwtable ssp {
; X32-SSE-LABEL: test_insertq_domain:
; X32-SSE:       # %bb.0:
; X32-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE-NEXT:    movdqa (%eax), %xmm1
; X32-SSE-NEXT:    insertq %xmm0, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm0
; X32-SSE-NEXT:    retl
;
; X32-AVX-LABEL: test_insertq_domain:
; X32-AVX:       # %bb.0:
; X32-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-AVX-NEXT:    vmovdqa (%eax), %xmm1
; X32-AVX-NEXT:    insertq %xmm0, %xmm1
; X32-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X32-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_insertq_domain:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movdqa (%rdi), %xmm1
; X64-SSE-NEXT:    insertq %xmm0, %xmm1
; X64-SSE-NEXT:    movdqa %xmm1, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_insertq_domain:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovdqa (%rdi), %xmm1
; X64-AVX-NEXT:    insertq %xmm0, %xmm1
; X64-AVX-NEXT:    vmovdqa %xmm1, %xmm0
; X64-AVX-NEXT:    retq
  %1 = load <2 x i64>, <2 x i64> *%p
  %2 = tail call <2 x i64> @llvm.x86.sse4a.insertq(<2 x i64> %1, <2 x i64> %y) nounwind
  ret <2 x i64> %2
}

declare <2 x i64> @llvm.x86.sse4a.insertq(<2 x i64>, <2 x i64>) nounwind
