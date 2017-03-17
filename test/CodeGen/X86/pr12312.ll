; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+sse4.1,-avx < %s | FileCheck %s --check-prefix=SSE41
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx,-avx2 < %s   | FileCheck %s --check-prefix=AVX

define i32 @veccond128(<4 x i32> %input) {
; SSE41-LABEL: veccond128:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    je .LBB0_2
; SSE41-NEXT:  # BB#1: # %if-true-block
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    retq
; SSE41-NEXT:  .LBB0_2: # %endif-block
; SSE41-NEXT:    movl $1, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: veccond128:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    je .LBB0_2
; AVX-NEXT:  # BB#1: # %if-true-block
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    retq
; AVX-NEXT:  .LBB0_2: # %endif-block
; AVX-NEXT:    movl $1, %eax
; AVX-NEXT:    retq
entry:
  %0 = bitcast <4 x i32> %input to i128
  %1 = icmp ne i128 %0, 0
  br i1 %1, label %if-true-block, label %endif-block
if-true-block:
  ret i32 0
endif-block:
  ret i32 1
}

define i32 @veccond256(<8 x i32> %input) {
; SSE41-LABEL: veccond256:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    je .LBB1_2
; SSE41-NEXT:  # BB#1: # %if-true-block
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    retq
; SSE41-NEXT:  .LBB1_2: # %endif-block
; SSE41-NEXT:    movl $1, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: veccond256:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    je .LBB1_2
; AVX-NEXT:  # BB#1: # %if-true-block
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
; AVX-NEXT:  .LBB1_2: # %endif-block
; AVX-NEXT:    movl $1, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
entry:
  %0 = bitcast <8 x i32> %input to i256
  %1 = icmp ne i256 %0, 0
  br i1 %1, label %if-true-block, label %endif-block
if-true-block:
  ret i32 0
endif-block:
  ret i32 1
}

define i32 @veccond512(<16 x i32> %input) {
; SSE41-LABEL: veccond512:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    je .LBB2_2
; SSE41-NEXT:  # BB#1: # %if-true-block
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    retq
; SSE41-NEXT:  .LBB2_2: # %endif-block
; SSE41-NEXT:    movl $1, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: veccond512:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    je .LBB2_2
; AVX-NEXT:  # BB#1: # %if-true-block
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
; AVX-NEXT:  .LBB2_2: # %endif-block
; AVX-NEXT:    movl $1, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
entry:
  %0 = bitcast <16 x i32> %input to i512
  %1 = icmp ne i512 %0, 0
  br i1 %1, label %if-true-block, label %endif-block
if-true-block:
  ret i32 0
endif-block:
  ret i32 1
}

define i32 @vectest128(<4 x i32> %input) {
; SSE41-LABEL: vectest128:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: vectest128:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    retq
  %t0 = bitcast <4 x i32> %input to i128
  %t1 = icmp ne i128 %t0, 0
  %t2 = zext i1 %t1 to i32
  ret i32 %t2
}

define i32 @vectest256(<8 x i32> %input) {
; SSE41-LABEL: vectest256:
; SSE41:       # BB#0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: vectest256:
; AVX:       # BB#0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %t0 = bitcast <8 x i32> %input to i256
  %t1 = icmp ne i256 %t0, 0
  %t2 = zext i1 %t1 to i32
  ret i32 %t2
}

define i32 @vectest512(<16 x i32> %input) {
; SSE41-LABEL: vectest512:
; SSE41:       # BB#0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    xorl %eax, %eax
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    setne %al
; SSE41-NEXT:    retq
;
; AVX-LABEL: vectest512:
; AVX:       # BB#0:
; AVX-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    setne %al
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %t0 = bitcast <16 x i32> %input to i512
  %t1 = icmp ne i512 %t0, 0
  %t2 = zext i1 %t1 to i32
  ret i32 %t2
}

define i32 @vecsel128(<4 x i32> %input, i32 %a, i32 %b) {
; SSE41-LABEL: vecsel128:
; SSE41:       # BB#0:
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    cmovel %esi, %edi
; SSE41-NEXT:    movl %edi, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: vecsel128:
; AVX:       # BB#0:
; AVX-NEXT:    vptest %xmm0, %xmm0
; AVX-NEXT:    cmovel %esi, %edi
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    retq
  %t0 = bitcast <4 x i32> %input to i128
  %t1 = icmp ne i128 %t0, 0
  %t2 = select i1 %t1, i32 %a, i32 %b
  ret i32 %t2
}

define i32 @vecsel256(<8 x i32> %input, i32 %a, i32 %b) {
; SSE41-LABEL: vecsel256:
; SSE41:       # BB#0:
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    ptest %xmm0, %xmm0
; SSE41-NEXT:    cmovel %esi, %edi
; SSE41-NEXT:    movl %edi, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: vecsel256:
; AVX:       # BB#0:
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    cmovel %esi, %edi
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %t0 = bitcast <8 x i32> %input to i256
  %t1 = icmp ne i256 %t0, 0
  %t2 = select i1 %t1, i32 %a, i32 %b
  ret i32 %t2
}

define i32 @vecsel512(<16 x i32> %input, i32 %a, i32 %b) {
; SSE41-LABEL: vecsel512:
; SSE41:       # BB#0:
; SSE41-NEXT:    por %xmm3, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    ptest %xmm1, %xmm1
; SSE41-NEXT:    cmovel %esi, %edi
; SSE41-NEXT:    movl %edi, %eax
; SSE41-NEXT:    retq
;
; AVX-LABEL: vecsel512:
; AVX:       # BB#0:
; AVX-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vptest %ymm0, %ymm0
; AVX-NEXT:    cmovel %esi, %edi
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %t0 = bitcast <16 x i32> %input to i512
  %t1 = icmp ne i512 %t0, 0
  %t2 = select i1 %t1, i32 %a, i32 %b
  ret i32 %t2
}

