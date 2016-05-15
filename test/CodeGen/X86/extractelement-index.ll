; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+sse2   | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+avx    | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-pc-linux -mattr=+avx2   | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

define i8 @extractelement_index_1(<32 x i8> %a) nounwind {
; SSE2-LABEL: extractelement_index_1:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_index_1:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrb $1, %xmm0, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: extractelement_index_1:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrb $1, %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 1
  ret i8 %b
}

define i32 @extractelement_index_2(<8 x i32> %a) nounwind {
; SSE2-LABEL: extractelement_index_2:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[3,1,2,3]
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extractelement_index_2:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrd $3, %xmm1, %eax
; SSE41-NEXT:    retq
;
; AVX1-LABEL: extractelement_index_2:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpextrd $3, %xmm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: extractelement_index_2:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX2-NEXT:    vpextrd $3, %xmm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %b = extractelement <8 x i32> %a, i64 7
  ret i32 %b
}

define i32 @extractelement_index_3(<8 x i32> %a) nounwind {
; SSE-LABEL: extractelement_index_3:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_index_3:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <8 x i32> %a, i64 15
  ret i32 %b
}

define i32 @extractelement_index_4(<8 x i32> %a) nounwind {
; SSE-LABEL: extractelement_index_4:
; SSE:       # BB#0:
; SSE-NEXT:    movd %xmm1, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_index_4:
; AVX:       # BB#0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <8 x i32> %a, i256 4
  ret i32 %b
}

define i8 @extractelement_index_5(<32 x i8> %a, i256 %i) nounwind {
; SSE-LABEL: extractelement_index_5:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; SSE-NEXT:    movaps %xmm0, (%rsp)
; SSE-NEXT:    leaq (%rsp), %rax
; SSE-NEXT:    movb (%rdi,%rax), %al
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_index_5:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    vmovaps %ymm0, (%rsp)
; AVX-NEXT:    leaq (%rsp), %rax
; AVX-NEXT:    movb (%rdi,%rax), %al
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 %i
  ret i8 %b
}

define i8 @extractelement_index_6(<32 x i8> %a) nounwind {
; SSE-LABEL: extractelement_index_6:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extractelement_index_6:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %b = extractelement <32 x i8> %a, i256 -1
  ret i8 %b
}
