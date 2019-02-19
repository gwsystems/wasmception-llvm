; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse2 | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=sse2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=avx2 | FileCheck %s --check-prefix=X32AVX

; Use movq or movsd to load / store i64 values if sse2 is available.
; rdar://6659858

define void @foo(i64* %x, i64* %y) {
; X64-LABEL: foo:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rsi), %rax
; X64-NEXT:    movq %rax, (%rdi)
; X64-NEXT:    retq
;
; X32-LABEL: foo:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    movsd %xmm0, (%eax)
; X32-NEXT:    retl
;
; X32AVX-LABEL: foo:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32AVX-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X32AVX-NEXT:    vmovsd %xmm0, (%eax)
; X32AVX-NEXT:    retl
  %tmp1 = load i64, i64* %y, align 8
  store i64 %tmp1, i64* %x, align 8
  ret void
}

; Verify that a 64-bit chunk extracted from a vector is stored with a movq
; regardless of whether the system is 64-bit.

define void @store_i64_from_vector(<8 x i16> %x, <8 x i16> %y, i64* %i) {
; X64-LABEL: store_i64_from_vector:
; X64:       # %bb.0:
; X64-NEXT:    paddw %xmm1, %xmm0
; X64-NEXT:    movq %xmm0, (%rdi)
; X64-NEXT:    retq
;
; X32-LABEL: store_i64_from_vector:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    paddw %xmm1, %xmm0
; X32-NEXT:    movq %xmm0, (%eax)
; X32-NEXT:    retl
;
; X32AVX-LABEL: store_i64_from_vector:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; X32AVX-NEXT:    vmovq %xmm0, (%eax)
; X32AVX-NEXT:    retl
  %z = add <8 x i16> %x, %y                          ; force execution domain
  %bc = bitcast <8 x i16> %z to <2 x i64>
  %vecext = extractelement <2 x i64> %bc, i32 0
  store i64 %vecext, i64* %i, align 8
  ret void
}

define void @store_i64_from_vector256(<16 x i16> %x, <16 x i16> %y, i64* %i) {
; X64-LABEL: store_i64_from_vector256:
; X64:       # %bb.0:
; X64-NEXT:    paddw %xmm3, %xmm1
; X64-NEXT:    movq %xmm1, (%rdi)
; X64-NEXT:    retq
;
; X32-LABEL: store_i64_from_vector256:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    .cfi_offset %ebp, -8
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    .cfi_def_cfa_register %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    movl 24(%ebp), %eax
; X32-NEXT:    paddw 8(%ebp), %xmm1
; X32-NEXT:    movq %xmm1, (%eax)
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    .cfi_def_cfa %esp, 4
; X32-NEXT:    retl
;
; X32AVX-LABEL: store_i64_from_vector256:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32AVX-NEXT:    vextracti128 $1, %ymm1, %xmm1
; X32AVX-NEXT:    vextracti128 $1, %ymm0, %xmm0
; X32AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; X32AVX-NEXT:    vmovq %xmm0, (%eax)
; X32AVX-NEXT:    vzeroupper
; X32AVX-NEXT:    retl
  %z = add <16 x i16> %x, %y                          ; force execution domain
  %bc = bitcast <16 x i16> %z to <4 x i64>
  %vecext = extractelement <4 x i64> %bc, i32 2
  store i64 %vecext, i64* %i, align 8
  ret void
}

; PR23476
; Handle extraction from a non-simple / pre-legalization type.

define void @PR23476(<5 x i64> %in, i64* %out, i32 %index) nounwind {
; X64-LABEL: PR23476:
; X64:       # %bb.0:
; X64-NEXT:    pushq %rbp
; X64-NEXT:    movq %rsp, %rbp
; X64-NEXT:    andq $-64, %rsp
; X64-NEXT:    subq $128, %rsp
; X64-NEXT:    movq %rsi, %xmm0
; X64-NEXT:    movq %rdi, %xmm1
; X64-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; X64-NEXT:    movq %rcx, %xmm0
; X64-NEXT:    movq %rdx, %xmm2
; X64-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; X64-NEXT:    movl 16(%rbp), %eax
; X64-NEXT:    andl $7, %eax
; X64-NEXT:    movq %r8, %xmm0
; X64-NEXT:    movdqa %xmm0, {{[0-9]+}}(%rsp)
; X64-NEXT:    movdqa %xmm2, {{[0-9]+}}(%rsp)
; X64-NEXT:    movdqa %xmm1, (%rsp)
; X64-NEXT:    movq (%rsp,%rax,8), %rax
; X64-NEXT:    movq %rax, (%r9)
; X64-NEXT:    movq %rbp, %rsp
; X64-NEXT:    popq %rbp
; X64-NEXT:    retq
;
; X32-LABEL: PR23476:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-64, %esp
; X32-NEXT:    subl $128, %esp
; X32-NEXT:    movl 52(%ebp), %eax
; X32-NEXT:    andl $7, %eax
; X32-NEXT:    movl 48(%ebp), %ecx
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    movups 8(%ebp), %xmm1
; X32-NEXT:    movups 24(%ebp), %xmm2
; X32-NEXT:    movaps %xmm2, {{[0-9]+}}(%esp)
; X32-NEXT:    movaps %xmm1, (%esp)
; X32-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp)
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    movsd %xmm0, (%ecx)
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X32AVX-LABEL: PR23476:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    pushl %ebp
; X32AVX-NEXT:    movl %esp, %ebp
; X32AVX-NEXT:    andl $-64, %esp
; X32AVX-NEXT:    subl $128, %esp
; X32AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X32AVX-NEXT:    movl 52(%ebp), %eax
; X32AVX-NEXT:    andl $7, %eax
; X32AVX-NEXT:    movl 48(%ebp), %ecx
; X32AVX-NEXT:    vmovups 8(%ebp), %ymm1
; X32AVX-NEXT:    vmovaps %ymm1, (%esp)
; X32AVX-NEXT:    vmovaps %ymm0, {{[0-9]+}}(%esp)
; X32AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X32AVX-NEXT:    vmovsd %xmm0, (%ecx)
; X32AVX-NEXT:    movl %ebp, %esp
; X32AVX-NEXT:    popl %ebp
; X32AVX-NEXT:    vzeroupper
; X32AVX-NEXT:    retl
  %ext = extractelement <5 x i64> %in, i32 %index
  store i64 %ext, i64* %out, align 8
  ret void
}

