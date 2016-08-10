; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Tests for SSE1 and below, without SSE2+.
; RUN: llc < %s -mtriple=i386-unknown-unknown -mcpu=pentium3 -O3 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=-sse2,+sse -O3 | FileCheck %s --check-prefix=X64

; PR7993
;define <4 x i32> @test3(<4 x i16> %a) nounwind {
;  %c = sext <4 x i16> %a to <4 x i32>             ; <<4 x i32>> [#uses=1]
;  ret <4 x i32> %c
;}

; This should not emit shuffles to populate the top 2 elements of the 4-element
; vector that this ends up returning.
; rdar://8368414
define <2 x float> @test4(<2 x float> %A, <2 x float> %B) nounwind {
; X32-LABEL: test4:
; X32:       # BB#0: # %entry
; X32-NEXT:    movaps %xmm0, %xmm2
; X32-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1,2,3]
; X32-NEXT:    addss %xmm1, %xmm0
; X32-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; X32-NEXT:    subss %xmm1, %xmm2
; X32-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; X32-NEXT:    retl
;
; X64-LABEL: test4:
; X64:       # BB#0: # %entry
; X64-NEXT:    movaps %xmm0, %xmm2
; X64-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1,2,3]
; X64-NEXT:    addss %xmm1, %xmm0
; X64-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; X64-NEXT:    subss %xmm1, %xmm2
; X64-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; X64-NEXT:    retq
entry:
  %tmp7 = extractelement <2 x float> %A, i32 0
  %tmp5 = extractelement <2 x float> %A, i32 1
  %tmp3 = extractelement <2 x float> %B, i32 0
  %tmp1 = extractelement <2 x float> %B, i32 1
  %add.r = fadd float %tmp7, %tmp3
  %add.i = fsub float %tmp5, %tmp1
  %tmp11 = insertelement <2 x float> undef, float %add.r, i32 0
  %tmp9 = insertelement <2 x float> %tmp11, float %add.i, i32 1
  ret <2 x float> %tmp9
}

; We used to get stuck in type legalization for this example when lowering the
; vselect. With SSE1 v4f32 is a legal type but v4i1 (or any vector integer type)
; is not. We used to ping pong between splitting the vselect for the v4i
; condition operand and widening the resulting vselect for the v4f32 result.
; PR18036

define <4 x float> @vselect(<4 x float>*%p, <4 x i32> %q) {
; X32-LABEL: vselect:
; X32:       # BB#0: # %entry
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    xorps %xmm0, %xmm0
; X32-NEXT:    je .LBB1_1
; X32-NEXT:  # BB#2: # %entry
; X32-NEXT:    xorps %xmm1, %xmm1
; X32-NEXT:    jmp .LBB1_3
; X32-NEXT:  .LBB1_1:
; X32-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X32-NEXT:  .LBB1_3: # %entry
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    je .LBB1_4
; X32-NEXT:  # BB#5: # %entry
; X32-NEXT:    xorps %xmm2, %xmm2
; X32-NEXT:    jmp .LBB1_6
; X32-NEXT:  .LBB1_4:
; X32-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; X32-NEXT:  .LBB1_6: # %entry
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    je .LBB1_7
; X32-NEXT:  # BB#8: # %entry
; X32-NEXT:    xorps %xmm3, %xmm3
; X32-NEXT:    jmp .LBB1_9
; X32-NEXT:  .LBB1_7:
; X32-NEXT:    movss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; X32-NEXT:  .LBB1_9: # %entry
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    unpcklps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; X32-NEXT:    jne .LBB1_11
; X32-NEXT:  # BB#10:
; X32-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32-NEXT:  .LBB1_11: # %entry
; X32-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X32-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; X32-NEXT:    retl
;
; X64-LABEL: vselect:
; X64:       # BB#0: # %entry
; X64-NEXT:    testl %ecx, %ecx
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    je .LBB1_1
; X64-NEXT:  # BB#2: # %entry
; X64-NEXT:    xorps %xmm1, %xmm1
; X64-NEXT:    jmp .LBB1_3
; X64-NEXT:  .LBB1_1:
; X64-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X64-NEXT:  .LBB1_3: # %entry
; X64-NEXT:    testl %edx, %edx
; X64-NEXT:    je .LBB1_4
; X64-NEXT:  # BB#5: # %entry
; X64-NEXT:    xorps %xmm2, %xmm2
; X64-NEXT:    jmp .LBB1_6
; X64-NEXT:  .LBB1_4:
; X64-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; X64-NEXT:  .LBB1_6: # %entry
; X64-NEXT:    testl %r8d, %r8d
; X64-NEXT:    je .LBB1_7
; X64-NEXT:  # BB#8: # %entry
; X64-NEXT:    xorps %xmm3, %xmm3
; X64-NEXT:    jmp .LBB1_9
; X64-NEXT:  .LBB1_7:
; X64-NEXT:    movss {{.*#+}} xmm3 = mem[0],zero,zero,zero
; X64-NEXT:  .LBB1_9: # %entry
; X64-NEXT:    testl %esi, %esi
; X64-NEXT:    unpcklps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; X64-NEXT:    jne .LBB1_11
; X64-NEXT:  # BB#10:
; X64-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:  .LBB1_11: # %entry
; X64-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X64-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; X64-NEXT:    retq
entry:
  %a1 = icmp eq <4 x i32> %q, zeroinitializer
  %a14 = select <4 x i1> %a1, <4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+0> , <4 x float> zeroinitializer
  ret <4 x float> %a14
}

; v4i32 isn't legal for SSE1, but this should be cmpps.

define <4 x float> @PR28044(<4 x float> %a0, <4 x float> %a1) nounwind {
; X32-LABEL: PR28044:
; X32:       # BB#0:
; X32-NEXT:    cmpeqps %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: PR28044:
; X64:       # BB#0:
; X64-NEXT:    cmpeqps %xmm1, %xmm0
; X64-NEXT:    retq
  %cmp = fcmp oeq <4 x float> %a0, %a1
  %sext = sext <4 x i1> %cmp to <4 x i32>
  %res = bitcast <4 x i32> %sext to <4 x float>
  ret <4 x float> %res
}

