; RUN: llc < %s -mcpu=x86-64 | FileCheck %s --check-prefix=CHECK-NOSSSE3
; RUN: llc < %s -mcpu=core2 | FileCheck %s --check-prefix=CHECK-SSSE3
; RUN: llc < %s -mcpu=core-avx2 | FileCheck %s --check-prefix=CHECK-AVX2
; RUN: llc < %s -mcpu=core-avx2 -x86-experimental-vector-widening-legalization | FileCheck %s --check-prefix=CHECK-WIDE-AVX2

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare <8 x i16> @llvm.bswap.v8i16(<8 x i16>)
declare <4 x i32> @llvm.bswap.v4i32(<4 x i32>)
declare <2 x i64> @llvm.bswap.v2i64(<2 x i64>)

define <8 x i16> @test1(<8 x i16> %v) {
; CHECK-NOSSSE3-LABEL: test1:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    pextrw $7, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    pextrw $3, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1],xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; CHECK-NOSSSE3-NEXT:    pextrw $5, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    pextrw $1, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm3[0],xmm1[1],xmm3[1],xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    pextrw $6, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    pextrw $2, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    pextrw $4, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test1:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14]
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test1:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test1:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %v)
  ret <8 x i16> %r
}

define <4 x i32> @test2(<4 x i32> %v) {
; CHECK-NOSSSE3-LABEL: test2:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[3,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm2, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; CHECK-NOSSSE3-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test2:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test2:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test2:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <4 x i32> @llvm.bswap.v4i32(<4 x i32> %v)
  ret <4 x i32> %r
}

define <2 x i64> @test3(<2 x i64> %v) {
; CHECK-NOSSSE3-LABEL: test3:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm1
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; CHECK-NOSSSE3-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test3:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test3:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test3:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %v)
  ret <2 x i64> %r
}

declare <16 x i16> @llvm.bswap.v16i16(<16 x i16>)
declare <8 x i32> @llvm.bswap.v8i32(<8 x i32>)
declare <4 x i64> @llvm.bswap.v4i64(<4 x i64>)

define <16 x i16> @test4(<16 x i16> %v) {
; CHECK-NOSSSE3-LABEL: test4:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    pextrw $7, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    pextrw $3, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    pextrw $5, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm4
; CHECK-NOSSSE3-NEXT:    pextrw $1, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm4[0],xmm2[1],xmm4[1],xmm2[2],xmm4[2],xmm2[3],xmm4[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1],xmm2[2],xmm3[2],xmm2[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    pextrw $6, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    pextrw $2, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm4
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm4 = xmm4[0],xmm3[0],xmm4[1],xmm3[1],xmm4[2],xmm3[2],xmm4[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    pextrw $4, %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm4[0],xmm0[1],xmm4[1],xmm0[2],xmm4[2],xmm0[3],xmm4[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    pextrw $7, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    pextrw $3, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1],xmm3[2],xmm2[2],xmm3[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    pextrw $5, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm4
; CHECK-NOSSSE3-NEXT:    pextrw $1, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm4[0],xmm2[1],xmm4[1],xmm2[2],xmm4[2],xmm2[3],xmm4[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1],xmm2[2],xmm3[2],xmm2[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    pextrw $6, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    pextrw $2, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm4
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm4 = xmm4[0],xmm3[0],xmm4[1],xmm3[1],xmm4[2],xmm3[2],xmm4[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    pextrw $4, %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    rolw $8, %ax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm3[0],xmm1[1],xmm3[1],xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm4[0],xmm1[1],xmm4[1],xmm1[2],xmm4[2],xmm1[3],xmm4[3]
; CHECK-NOSSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test4:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14]
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm0
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm1
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test4:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,17,16,19,18,21,20,23,22,25,24,27,26,29,28,31,30]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test4:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,17,16,19,18,21,20,23,22,25,24,27,26,29,28,31,30]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <16 x i16> @llvm.bswap.v16i16(<16 x i16> %v)
  ret <16 x i16> %r
}

define <8 x i32> @test5(<8 x i32> %v) {
; CHECK-NOSSSE3-LABEL: test5:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    movdqa %xmm0, %xmm2
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[3,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[1,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm3, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm3 = xmm3[0],xmm0[0],xmm3[1],xmm0[1]
; CHECK-NOSSSE3-NEXT:    movd %xmm2, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm2, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1]
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[3,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm2, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[1,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm3, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm3
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1]
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; CHECK-NOSSSE3-NEXT:    movdqa %xmm2, %xmm1
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test5:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm0
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm1
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test5:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,19,18,17,16,23,22,21,20,27,26,25,24,31,30,29,28]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test5:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12,19,18,17,16,23,22,21,20,27,26,25,24,31,30,29,28]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <8 x i32> @llvm.bswap.v8i32(<8 x i32> %v)
  ret <8 x i32> %r
}

define <4 x i64> @test6(<4 x i64> %v) {
; CHECK-NOSSSE3-LABEL: test6:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm2
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm3
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %rax
; CHECK-NOSSSE3-NEXT:    bswapq %rax
; CHECK-NOSSSE3-NEXT:    movd %rax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm0[0]
; CHECK-NOSSSE3-NEXT:    movdqa %xmm2, %xmm0
; CHECK-NOSSSE3-NEXT:    movdqa %xmm3, %xmm1
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test6:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm0
; CHECK-SSSE3-NEXT:    pshufb %xmm2, %xmm1
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test6:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,23,22,21,20,19,18,17,16,31,30,29,28,27,26,25,24]
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test6:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,23,22,21,20,19,18,17,16,31,30,29,28,27,26,25,24]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <4 x i64> @llvm.bswap.v4i64(<4 x i64> %v)
  ret <4 x i64> %r
}

declare <4 x i16> @llvm.bswap.v4i16(<4 x i16>)

define <4 x i16> @test7(<4 x i16> %v) {
; CHECK-NOSSSE3-LABEL: test7:
; CHECK-NOSSSE3:       # BB#0: # %entry
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[3,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm1, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,2,3]
; CHECK-NOSSSE3-NEXT:    movd %xmm2, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm2
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm1
; CHECK-NOSSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NOSSSE3-NEXT:    movd %xmm0, %eax
; CHECK-NOSSSE3-NEXT:    bswapl %eax
; CHECK-NOSSSE3-NEXT:    movd %eax, %xmm0
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; CHECK-NOSSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; CHECK-NOSSSE3-NEXT:    psrld $16, %xmm1
; CHECK-NOSSSE3-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NOSSSE3-NEXT:    retq
;
; CHECK-SSSE3-LABEL: test7:
; CHECK-SSSE3:       # BB#0: # %entry
; CHECK-SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-SSSE3-NEXT:    psrld $16, %xmm0
; CHECK-SSSE3-NEXT:    retq
;
; CHECK-AVX2-LABEL: test7:
; CHECK-AVX2:       # BB#0: # %entry
; CHECK-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; CHECK-AVX2-NEXT:    vpsrld $16, %xmm0, %xmm0
; CHECK-AVX2-NEXT:    retq
;
; CHECK-WIDE-AVX2-LABEL: test7:
; CHECK-WIDE-AVX2:       # BB#0: # %entry
; CHECK-WIDE-AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14]
; CHECK-WIDE-AVX2-NEXT:    retq
entry:
  %r = call <4 x i16> @llvm.bswap.v4i16(<4 x i16> %v)
  ret <4 x i16> %r
}
