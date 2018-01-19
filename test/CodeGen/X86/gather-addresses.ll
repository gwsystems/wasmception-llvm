; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux -mattr=+sse2 < %s | FileCheck %s --check-prefixes=LIN,LIN-SSE2
; RUN: llc -mtriple=x86_64-linux -mcpu=nehalem < %s | FileCheck %s --check-prefixes=LIN,LIN-SSE4
; RUN: llc -mtriple=x86_64-win32 -mattr=+sse2 < %s | FileCheck %s --check-prefixes=WIN,WIN-SSE2
; RUN: llc -mtriple=x86_64-win32 -mcpu=nehalem < %s | FileCheck %s --check-prefixes=WIN,WIN-SSE4
; RUN: llc -mtriple=i686-win32 -mcpu=nehalem < %s | FileCheck %s --check-prefix=LIN32
; rdar://7398554

; When doing vector gather-scatter index calculation with 32-bit indices,
; use an efficient mov/shift sequence rather than shuffling each individual
; element out of the index vector.

define <4 x double> @foo(double* %p, <4 x i32>* %i, <4 x i32>* %h) nounwind {
; LIN-SSE2-LABEL: foo:
; LIN-SSE2:       # %bb.0:
; LIN-SSE2-NEXT:    movdqa (%rsi), %xmm0
; LIN-SSE2-NEXT:    pand (%rdx), %xmm0
; LIN-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; LIN-SSE2-NEXT:    movq %xmm1, %rax
; LIN-SSE2-NEXT:    movq %xmm0, %rcx
; LIN-SSE2-NEXT:    movslq %ecx, %rdx
; LIN-SSE2-NEXT:    sarq $32, %rcx
; LIN-SSE2-NEXT:    movslq %eax, %rsi
; LIN-SSE2-NEXT:    sarq $32, %rax
; LIN-SSE2-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; LIN-SSE2-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; LIN-SSE2-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; LIN-SSE2-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; LIN-SSE2-NEXT:    retq
;
; LIN-SSE4-LABEL: foo:
; LIN-SSE4:       # %bb.0:
; LIN-SSE4-NEXT:    movdqa (%rsi), %xmm0
; LIN-SSE4-NEXT:    pand (%rdx), %xmm0
; LIN-SSE4-NEXT:    pextrq $1, %xmm0, %rax
; LIN-SSE4-NEXT:    movq %xmm0, %rcx
; LIN-SSE4-NEXT:    movslq %ecx, %rdx
; LIN-SSE4-NEXT:    sarq $32, %rcx
; LIN-SSE4-NEXT:    movslq %eax, %rsi
; LIN-SSE4-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; LIN-SSE4-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; LIN-SSE4-NEXT:    sarq $32, %rax
; LIN-SSE4-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; LIN-SSE4-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; LIN-SSE4-NEXT:    retq
;
; WIN-SSE2-LABEL: foo:
; WIN-SSE2:       # %bb.0:
; WIN-SSE2-NEXT:    movdqa (%rdx), %xmm0
; WIN-SSE2-NEXT:    pand (%r8), %xmm0
; WIN-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; WIN-SSE2-NEXT:    movq %xmm1, %rax
; WIN-SSE2-NEXT:    movq %xmm0, %rdx
; WIN-SSE2-NEXT:    movslq %edx, %r8
; WIN-SSE2-NEXT:    sarq $32, %rdx
; WIN-SSE2-NEXT:    movslq %eax, %r9
; WIN-SSE2-NEXT:    sarq $32, %rax
; WIN-SSE2-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; WIN-SSE2-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; WIN-SSE2-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; WIN-SSE2-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; WIN-SSE2-NEXT:    retq
;
; WIN-SSE4-LABEL: foo:
; WIN-SSE4:       # %bb.0:
; WIN-SSE4-NEXT:    movdqa (%rdx), %xmm0
; WIN-SSE4-NEXT:    pand (%r8), %xmm0
; WIN-SSE4-NEXT:    pextrq $1, %xmm0, %rax
; WIN-SSE4-NEXT:    movq %xmm0, %rdx
; WIN-SSE4-NEXT:    movslq %edx, %r8
; WIN-SSE4-NEXT:    sarq $32, %rdx
; WIN-SSE4-NEXT:    movslq %eax, %r9
; WIN-SSE4-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; WIN-SSE4-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; WIN-SSE4-NEXT:    sarq $32, %rax
; WIN-SSE4-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; WIN-SSE4-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; WIN-SSE4-NEXT:    retq
;
; LIN32-LABEL: foo:
; LIN32:       # %bb.0:
; LIN32-NEXT:    pushl %edi
; LIN32-NEXT:    pushl %esi
; LIN32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; LIN32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; LIN32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; LIN32-NEXT:    movdqa (%edx), %xmm0
; LIN32-NEXT:    pand (%ecx), %xmm0
; LIN32-NEXT:    pextrd $1, %xmm0, %ecx
; LIN32-NEXT:    pextrd $2, %xmm0, %edx
; LIN32-NEXT:    pextrd $3, %xmm0, %esi
; LIN32-NEXT:    movd %xmm0, %edi
; LIN32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; LIN32-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; LIN32-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; LIN32-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; LIN32-NEXT:    popl %esi
; LIN32-NEXT:    popl %edi
; LIN32-NEXT:    retl
  %a = load <4 x i32>, <4 x i32>* %i
  %b = load <4 x i32>, <4 x i32>* %h
  %j = and <4 x i32> %a, %b
  %d0 = extractelement <4 x i32> %j, i32 0
  %d1 = extractelement <4 x i32> %j, i32 1
  %d2 = extractelement <4 x i32> %j, i32 2
  %d3 = extractelement <4 x i32> %j, i32 3
  %q0 = getelementptr double, double* %p, i32 %d0
  %q1 = getelementptr double, double* %p, i32 %d1
  %q2 = getelementptr double, double* %p, i32 %d2
  %q3 = getelementptr double, double* %p, i32 %d3
  %r0 = load double, double* %q0
  %r1 = load double, double* %q1
  %r2 = load double, double* %q2
  %r3 = load double, double* %q3
  %v0 = insertelement <4 x double> undef, double %r0, i32 0
  %v1 = insertelement <4 x double> %v0, double %r1, i32 1
  %v2 = insertelement <4 x double> %v1, double %r2, i32 2
  %v3 = insertelement <4 x double> %v2, double %r3, i32 3
  ret <4 x double> %v3
}

; Check that the sequence previously used above, which bounces the vector off the
; cache works for x86-32. Note that in this case it will not be used for index
; calculation, since indexes are 32-bit, not 64.
define <4 x i64> @old(double* %p, <4 x i32>* %i, <4 x i32>* %h, i64 %f) nounwind {
; LIN-SSE2-LABEL: old:
; LIN-SSE2:       # %bb.0:
; LIN-SSE2-NEXT:    movdqa (%rsi), %xmm0
; LIN-SSE2-NEXT:    pand (%rdx), %xmm0
; LIN-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; LIN-SSE2-NEXT:    movq %xmm1, %rax
; LIN-SSE2-NEXT:    movq %rax, %rdx
; LIN-SSE2-NEXT:    shrq $32, %rdx
; LIN-SSE2-NEXT:    movq %xmm0, %rsi
; LIN-SSE2-NEXT:    movq %rsi, %rdi
; LIN-SSE2-NEXT:    shrq $32, %rdi
; LIN-SSE2-NEXT:    andl %ecx, %esi
; LIN-SSE2-NEXT:    andl %ecx, %eax
; LIN-SSE2-NEXT:    andq %rcx, %rdi
; LIN-SSE2-NEXT:    andq %rcx, %rdx
; LIN-SSE2-NEXT:    movq %rdi, %xmm1
; LIN-SSE2-NEXT:    movq %rsi, %xmm0
; LIN-SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; LIN-SSE2-NEXT:    movq %rdx, %xmm2
; LIN-SSE2-NEXT:    movq %rax, %xmm1
; LIN-SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; LIN-SSE2-NEXT:    retq
;
; LIN-SSE4-LABEL: old:
; LIN-SSE4:       # %bb.0:
; LIN-SSE4-NEXT:    movdqa (%rsi), %xmm0
; LIN-SSE4-NEXT:    pand (%rdx), %xmm0
; LIN-SSE4-NEXT:    pextrq $1, %xmm0, %rax
; LIN-SSE4-NEXT:    movq %rax, %rdx
; LIN-SSE4-NEXT:    shrq $32, %rdx
; LIN-SSE4-NEXT:    movq %xmm0, %rsi
; LIN-SSE4-NEXT:    movq %rsi, %rdi
; LIN-SSE4-NEXT:    shrq $32, %rdi
; LIN-SSE4-NEXT:    andl %ecx, %esi
; LIN-SSE4-NEXT:    andl %ecx, %eax
; LIN-SSE4-NEXT:    andq %rcx, %rdi
; LIN-SSE4-NEXT:    andq %rcx, %rdx
; LIN-SSE4-NEXT:    movq %rdi, %xmm1
; LIN-SSE4-NEXT:    movq %rsi, %xmm0
; LIN-SSE4-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; LIN-SSE4-NEXT:    movq %rdx, %xmm2
; LIN-SSE4-NEXT:    movq %rax, %xmm1
; LIN-SSE4-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; LIN-SSE4-NEXT:    retq
;
; WIN-SSE2-LABEL: old:
; WIN-SSE2:       # %bb.0:
; WIN-SSE2-NEXT:    movdqa (%rdx), %xmm0
; WIN-SSE2-NEXT:    pand (%r8), %xmm0
; WIN-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; WIN-SSE2-NEXT:    movq %xmm1, %r8
; WIN-SSE2-NEXT:    movq %r8, %rcx
; WIN-SSE2-NEXT:    shrq $32, %rcx
; WIN-SSE2-NEXT:    movq %xmm0, %rax
; WIN-SSE2-NEXT:    movq %rax, %rdx
; WIN-SSE2-NEXT:    shrq $32, %rdx
; WIN-SSE2-NEXT:    andl %r9d, %eax
; WIN-SSE2-NEXT:    andl %r9d, %r8d
; WIN-SSE2-NEXT:    andq %r9, %rdx
; WIN-SSE2-NEXT:    andq %r9, %rcx
; WIN-SSE2-NEXT:    movq %rdx, %xmm1
; WIN-SSE2-NEXT:    movq %rax, %xmm0
; WIN-SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; WIN-SSE2-NEXT:    movq %rcx, %xmm2
; WIN-SSE2-NEXT:    movq %r8, %xmm1
; WIN-SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; WIN-SSE2-NEXT:    retq
;
; WIN-SSE4-LABEL: old:
; WIN-SSE4:       # %bb.0:
; WIN-SSE4-NEXT:    movdqa (%rdx), %xmm0
; WIN-SSE4-NEXT:    pand (%r8), %xmm0
; WIN-SSE4-NEXT:    pextrq $1, %xmm0, %r8
; WIN-SSE4-NEXT:    movq %r8, %rcx
; WIN-SSE4-NEXT:    shrq $32, %rcx
; WIN-SSE4-NEXT:    movq %xmm0, %rax
; WIN-SSE4-NEXT:    movq %rax, %rdx
; WIN-SSE4-NEXT:    shrq $32, %rdx
; WIN-SSE4-NEXT:    andl %r9d, %eax
; WIN-SSE4-NEXT:    andl %r9d, %r8d
; WIN-SSE4-NEXT:    andq %r9, %rdx
; WIN-SSE4-NEXT:    andq %r9, %rcx
; WIN-SSE4-NEXT:    movq %rdx, %xmm1
; WIN-SSE4-NEXT:    movq %rax, %xmm0
; WIN-SSE4-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; WIN-SSE4-NEXT:    movq %rcx, %xmm2
; WIN-SSE4-NEXT:    movq %r8, %xmm1
; WIN-SSE4-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; WIN-SSE4-NEXT:    retq
;
; LIN32-LABEL: old:
; LIN32:       # %bb.0:
; LIN32-NEXT:    pushl %ebp
; LIN32-NEXT:    movl %esp, %ebp
; LIN32-NEXT:    pushl %esi
; LIN32-NEXT:    andl $-16, %esp
; LIN32-NEXT:    subl $32, %esp
; LIN32-NEXT:    movl 20(%ebp), %eax
; LIN32-NEXT:    movl 16(%ebp), %ecx
; LIN32-NEXT:    movl 12(%ebp), %edx
; LIN32-NEXT:    movaps (%edx), %xmm0
; LIN32-NEXT:    andps (%ecx), %xmm0
; LIN32-NEXT:    movaps %xmm0, (%esp)
; LIN32-NEXT:    movl (%esp), %ecx
; LIN32-NEXT:    andl %eax, %ecx
; LIN32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; LIN32-NEXT:    andl %eax, %edx
; LIN32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; LIN32-NEXT:    andl %eax, %esi
; LIN32-NEXT:    andl {{[0-9]+}}(%esp), %eax
; LIN32-NEXT:    movd %edx, %xmm1
; LIN32-NEXT:    movd %ecx, %xmm0
; LIN32-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; LIN32-NEXT:    movd %eax, %xmm2
; LIN32-NEXT:    movd %esi, %xmm1
; LIN32-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; LIN32-NEXT:    leal -4(%ebp), %esp
; LIN32-NEXT:    popl %esi
; LIN32-NEXT:    popl %ebp
; LIN32-NEXT:    retl
  %a = load <4 x i32>, <4 x i32>* %i
  %b = load <4 x i32>, <4 x i32>* %h
  %j = and <4 x i32> %a, %b
  %d0 = extractelement <4 x i32> %j, i32 0
  %d1 = extractelement <4 x i32> %j, i32 1
  %d2 = extractelement <4 x i32> %j, i32 2
  %d3 = extractelement <4 x i32> %j, i32 3
  %q0 = zext i32 %d0 to i64
  %q1 = zext i32 %d1 to i64
  %q2 = zext i32 %d2 to i64
  %q3 = zext i32 %d3 to i64
  %r0 = and i64 %q0, %f
  %r1 = and i64 %q1, %f
  %r2 = and i64 %q2, %f
  %r3 = and i64 %q3, %f
  %v0 = insertelement <4 x i64> undef, i64 %r0, i32 0
  %v1 = insertelement <4 x i64> %v0, i64 %r1, i32 1
  %v2 = insertelement <4 x i64> %v1, i64 %r2, i32 2
  %v3 = insertelement <4 x i64> %v2, i64 %r3, i32 3
  ret <4 x i64> %v3
}
