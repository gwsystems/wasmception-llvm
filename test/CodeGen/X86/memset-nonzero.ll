; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=sse | FileCheck %s --check-prefix=SSE
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=sse2 | FileCheck %s --check-prefix=SSE
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=sse2,-slow-unaligned-mem-16 | FileCheck %s --check-prefix=SSE2FAST
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc -mtriple=x86_64-unknown-unknown < %s -mattr=avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

; https://llvm.org/bugs/show_bug.cgi?id=27100

define void @memset_16_nonzero_bytes(i8* %x) {
; SSE-LABEL: memset_16_nonzero_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE-NEXT:    movq %rax, 8(%rdi)
; SSE-NEXT:    movq %rax, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_16_nonzero_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; SSE2FAST-NEXT:    movups %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX-LABEL: memset_16_nonzero_bytes:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %xmm0, (%rdi)
; AVX-NEXT:    retq
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 16, i64 -1)
  ret void
}

define void @memset_32_nonzero_bytes(i8* %x) {
; SSE-LABEL: memset_32_nonzero_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE-NEXT:    movq %rax, 24(%rdi)
; SSE-NEXT:    movq %rax, 16(%rdi)
; SSE-NEXT:    movq %rax, 8(%rdi)
; SSE-NEXT:    movq %rax, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_32_nonzero_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; SSE2FAST-NEXT:    movups %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX-LABEL: memset_32_nonzero_bytes:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 32, i64 -1)
  ret void
}

define void @memset_64_nonzero_bytes(i8* %x) {
; SSE-LABEL: memset_64_nonzero_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE-NEXT:    movq %rax, 56(%rdi)
; SSE-NEXT:    movq %rax, 48(%rdi)
; SSE-NEXT:    movq %rax, 40(%rdi)
; SSE-NEXT:    movq %rax, 32(%rdi)
; SSE-NEXT:    movq %rax, 24(%rdi)
; SSE-NEXT:    movq %rax, 16(%rdi)
; SSE-NEXT:    movq %rax, 8(%rdi)
; SSE-NEXT:    movq %rax, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_64_nonzero_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; SSE2FAST-NEXT:    movups %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX-LABEL: memset_64_nonzero_bytes:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 64, i64 -1)
  ret void
}

define void @memset_128_nonzero_bytes(i8* %x) {
; SSE-LABEL: memset_128_nonzero_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    movabsq $3038287259199220266, %rax # imm = 0x2A2A2A2A2A2A2A2A
; SSE-NEXT:    movq %rax, 120(%rdi)
; SSE-NEXT:    movq %rax, 112(%rdi)
; SSE-NEXT:    movq %rax, 104(%rdi)
; SSE-NEXT:    movq %rax, 96(%rdi)
; SSE-NEXT:    movq %rax, 88(%rdi)
; SSE-NEXT:    movq %rax, 80(%rdi)
; SSE-NEXT:    movq %rax, 72(%rdi)
; SSE-NEXT:    movq %rax, 64(%rdi)
; SSE-NEXT:    movq %rax, 56(%rdi)
; SSE-NEXT:    movq %rax, 48(%rdi)
; SSE-NEXT:    movq %rax, 40(%rdi)
; SSE-NEXT:    movq %rax, 32(%rdi)
; SSE-NEXT:    movq %rax, 24(%rdi)
; SSE-NEXT:    movq %rax, 16(%rdi)
; SSE-NEXT:    movq %rax, 8(%rdi)
; SSE-NEXT:    movq %rax, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_128_nonzero_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; SSE2FAST-NEXT:    movups %xmm0, 112(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 96(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 80(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 64(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX-LABEL: memset_128_nonzero_bytes:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 128, i64 -1)
  ret void
}

define void @memset_256_nonzero_bytes(i8* %x) {
; SSE-LABEL: memset_256_nonzero_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 16
; SSE-NEXT:    movl $256, %edx # imm = 0x100
; SSE-NEXT:    movl $42, %esi
; SSE-NEXT:    callq memset
; SSE-NEXT:    popq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 8
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_256_nonzero_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movaps {{.*#+}} xmm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; SSE2FAST-NEXT:    movups %xmm0, 240(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 224(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 208(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 192(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 176(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 160(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 144(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 128(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 112(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 96(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 80(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 64(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movups %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX-LABEL: memset_256_nonzero_bytes:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42]
; AVX-NEXT:    vmovups %ymm0, 224(%rdi)
; AVX-NEXT:    vmovups %ymm0, 192(%rdi)
; AVX-NEXT:    vmovups %ymm0, 160(%rdi)
; AVX-NEXT:    vmovups %ymm0, 128(%rdi)
; AVX-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX-NEXT:    vmovups %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %call = tail call i8* @__memset_chk(i8* %x, i32 42, i64 256, i64 -1)
  ret void
}

declare i8* @__memset_chk(i8*, i32, i64, i64)

; Repeat with a non-constant value for the stores.

define void @memset_16_nonconst_bytes(i8* %x, i8 %c) {
; SSE-LABEL: memset_16_nonconst_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzbl %sil, %eax
; SSE-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE-NEXT:    imulq %rax, %rcx
; SSE-NEXT:    movq %rcx, 8(%rdi)
; SSE-NEXT:    movq %rcx, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_16_nonconst_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movd %esi, %xmm0
; SSE2FAST-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2FAST-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,3,4,5,6,7]
; SSE2FAST-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2FAST-NEXT:    movdqu %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX1-LABEL: memset_16_nonconst_bytes:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_16_nonconst_bytes:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX2-NEXT:    retq
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 16, i1 false)
  ret void
}

define void @memset_32_nonconst_bytes(i8* %x, i8 %c) {
; SSE-LABEL: memset_32_nonconst_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzbl %sil, %eax
; SSE-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE-NEXT:    imulq %rax, %rcx
; SSE-NEXT:    movq %rcx, 24(%rdi)
; SSE-NEXT:    movq %rcx, 16(%rdi)
; SSE-NEXT:    movq %rcx, 8(%rdi)
; SSE-NEXT:    movq %rcx, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_32_nonconst_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movd %esi, %xmm0
; SSE2FAST-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2FAST-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,3,4,5,6,7]
; SSE2FAST-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2FAST-NEXT:    movdqu %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX1-LABEL: memset_32_nonconst_bytes:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovdqu %xmm0, 16(%rdi)
; AVX1-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_32_nonconst_bytes:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 32, i1 false)
  ret void
}

define void @memset_64_nonconst_bytes(i8* %x, i8 %c) {
; SSE-LABEL: memset_64_nonconst_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzbl %sil, %eax
; SSE-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE-NEXT:    imulq %rax, %rcx
; SSE-NEXT:    movq %rcx, 56(%rdi)
; SSE-NEXT:    movq %rcx, 48(%rdi)
; SSE-NEXT:    movq %rcx, 40(%rdi)
; SSE-NEXT:    movq %rcx, 32(%rdi)
; SSE-NEXT:    movq %rcx, 24(%rdi)
; SSE-NEXT:    movq %rcx, 16(%rdi)
; SSE-NEXT:    movq %rcx, 8(%rdi)
; SSE-NEXT:    movq %rcx, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_64_nonconst_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movd %esi, %xmm0
; SSE2FAST-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2FAST-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,3,4,5,6,7]
; SSE2FAST-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2FAST-NEXT:    movdqu %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX1-LABEL: memset_64_nonconst_bytes:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_64_nonconst_bytes:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 64, i1 false)
  ret void
}

define void @memset_128_nonconst_bytes(i8* %x, i8 %c) {
; SSE-LABEL: memset_128_nonconst_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzbl %sil, %eax
; SSE-NEXT:    movabsq $72340172838076673, %rcx # imm = 0x101010101010101
; SSE-NEXT:    imulq %rax, %rcx
; SSE-NEXT:    movq %rcx, 120(%rdi)
; SSE-NEXT:    movq %rcx, 112(%rdi)
; SSE-NEXT:    movq %rcx, 104(%rdi)
; SSE-NEXT:    movq %rcx, 96(%rdi)
; SSE-NEXT:    movq %rcx, 88(%rdi)
; SSE-NEXT:    movq %rcx, 80(%rdi)
; SSE-NEXT:    movq %rcx, 72(%rdi)
; SSE-NEXT:    movq %rcx, 64(%rdi)
; SSE-NEXT:    movq %rcx, 56(%rdi)
; SSE-NEXT:    movq %rcx, 48(%rdi)
; SSE-NEXT:    movq %rcx, 40(%rdi)
; SSE-NEXT:    movq %rcx, 32(%rdi)
; SSE-NEXT:    movq %rcx, 24(%rdi)
; SSE-NEXT:    movq %rcx, 16(%rdi)
; SSE-NEXT:    movq %rcx, 8(%rdi)
; SSE-NEXT:    movq %rcx, (%rdi)
; SSE-NEXT:    retq
;
; SSE2FAST-LABEL: memset_128_nonconst_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movd %esi, %xmm0
; SSE2FAST-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2FAST-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,3,4,5,6,7]
; SSE2FAST-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2FAST-NEXT:    movdqu %xmm0, 112(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 96(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 80(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 64(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX1-LABEL: memset_128_nonconst_bytes:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_128_nonconst_bytes:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 96(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 64(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 128, i1 false)
  ret void
}

define void @memset_256_nonconst_bytes(i8* %x, i8 %c) {
; SSE-LABEL: memset_256_nonconst_bytes:
; SSE:       # %bb.0:
; SSE-NEXT:    movl $256, %edx # imm = 0x100
; SSE-NEXT:    jmp memset # TAILCALL
;
; SSE2FAST-LABEL: memset_256_nonconst_bytes:
; SSE2FAST:       # %bb.0:
; SSE2FAST-NEXT:    movd %esi, %xmm0
; SSE2FAST-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2FAST-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,3,4,5,6,7]
; SSE2FAST-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2FAST-NEXT:    movdqu %xmm0, 240(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 224(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 208(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 192(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 176(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 160(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 144(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 128(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 112(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 96(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 80(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 64(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 48(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 32(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, 16(%rdi)
; SSE2FAST-NEXT:    movdqu %xmm0, (%rdi)
; SSE2FAST-NEXT:    retq
;
; AVX1-LABEL: memset_256_nonconst_bytes:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovd %esi, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovups %ymm0, 224(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 192(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 160(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 128(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 96(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 64(%rdi)
; AVX1-NEXT:    vmovups %ymm0, 32(%rdi)
; AVX1-NEXT:    vmovups %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: memset_256_nonconst_bytes:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd %esi, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX2-NEXT:    vmovdqu %ymm0, 224(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 192(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 160(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 128(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 96(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 64(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX2-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  tail call void @llvm.memset.p0i8.i64(i8* %x, i8 %c, i64 256, i1 false)
  ret void
}

declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i1) #1

