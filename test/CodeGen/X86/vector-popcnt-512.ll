; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512cd | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512CD

define <8 x i64> @testv8i64(<8 x i64> %in) nounwind {
; ALL-LABEL: testv8i64:
; ALL:       ## BB#0:
; ALL-NEXT:    vextracti32x4 $3, %zmm0, %xmm1
; ALL-NEXT:    vpextrq $1, %xmm1, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm2
; ALL-NEXT:    vmovq %xmm1, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm1
; ALL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; ALL-NEXT:    vextracti32x4 $2, %zmm0, %xmm2
; ALL-NEXT:    vpextrq $1, %xmm2, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm3
; ALL-NEXT:    vmovq %xmm2, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm2
; ALL-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; ALL-NEXT:    vinserti128 $1, %xmm1, %ymm2, %ymm1
; ALL-NEXT:    vextracti32x4 $1, %zmm0, %xmm2
; ALL-NEXT:    vpextrq $1, %xmm2, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm3
; ALL-NEXT:    vmovq %xmm2, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm2
; ALL-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; ALL-NEXT:    vpextrq $1, %xmm0, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm3
; ALL-NEXT:    vmovq %xmm0, %rax
; ALL-NEXT:    popcntq %rax, %rax
; ALL-NEXT:    vmovq %rax, %xmm0
; ALL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm3[0]
; ALL-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; ALL-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; ALL-NEXT:    retq
  %out = call <8 x i64> @llvm.ctpop.v8i64(<8 x i64> %in)
  ret <8 x i64> %out
}

define <16 x i32> @testv16i32(<16 x i32> %in) nounwind {
; ALL-LABEL: testv16i32:
; ALL:       ## BB#0:
; ALL-NEXT:    vextracti32x4 $3, %zmm0, %xmm1
; ALL-NEXT:    vpextrd $1, %xmm1, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vmovd %xmm1, %ecx
; ALL-NEXT:    popcntl %ecx, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm2
; ALL-NEXT:    vpinsrd $1, %eax, %xmm2, %xmm2
; ALL-NEXT:    vpextrd $2, %xmm1, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $2, %eax, %xmm2, %xmm2
; ALL-NEXT:    vpextrd $3, %xmm1, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $3, %eax, %xmm2, %xmm1
; ALL-NEXT:    vextracti32x4 $2, %zmm0, %xmm2
; ALL-NEXT:    vpextrd $1, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vmovd %xmm2, %ecx
; ALL-NEXT:    popcntl %ecx, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm3
; ALL-NEXT:    vpinsrd $1, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $2, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $2, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $3, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $3, %eax, %xmm3, %xmm2
; ALL-NEXT:    vinserti128 $1, %xmm1, %ymm2, %ymm1
; ALL-NEXT:    vextracti32x4 $1, %zmm0, %xmm2
; ALL-NEXT:    vpextrd $1, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vmovd %xmm2, %ecx
; ALL-NEXT:    popcntl %ecx, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm3
; ALL-NEXT:    vpinsrd $1, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $2, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $2, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $3, %xmm2, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $3, %eax, %xmm3, %xmm2
; ALL-NEXT:    vpextrd $1, %xmm0, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vmovd %xmm0, %ecx
; ALL-NEXT:    popcntl %ecx, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm3
; ALL-NEXT:    vpinsrd $1, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $2, %xmm0, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $2, %eax, %xmm3, %xmm3
; ALL-NEXT:    vpextrd $3, %xmm0, %eax
; ALL-NEXT:    popcntl %eax, %eax
; ALL-NEXT:    vpinsrd $3, %eax, %xmm3, %xmm0
; ALL-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; ALL-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; ALL-NEXT:    retq
  %out = call <16 x i32> @llvm.ctpop.v16i32(<16 x i32> %in)
  ret <16 x i32> %out
}

define <32 x i16> @testv32i16(<32 x i16> %in) nounwind {
; ALL-LABEL: testv32i16:
; ALL:       ## BB#0:
; ALL-NEXT:    vmovdqa {{.*#+}} ymm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; ALL-NEXT:    vpand %ymm2, %ymm0, %ymm3
; ALL-NEXT:    vmovdqa {{.*#+}} ymm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; ALL-NEXT:    vpshufb %ymm3, %ymm4, %ymm3
; ALL-NEXT:    vpsrlw $4, %ymm0, %ymm0
; ALL-NEXT:    vpand %ymm2, %ymm0, %ymm0
; ALL-NEXT:    vpshufb %ymm0, %ymm4, %ymm0
; ALL-NEXT:    vpaddb %ymm3, %ymm0, %ymm0
; ALL-NEXT:    vpsllw $8, %ymm0, %ymm3
; ALL-NEXT:    vpaddb %ymm0, %ymm3, %ymm0
; ALL-NEXT:    vpsrlw $8, %ymm0, %ymm0
; ALL-NEXT:    vpand %ymm2, %ymm1, %ymm3
; ALL-NEXT:    vpshufb %ymm3, %ymm4, %ymm3
; ALL-NEXT:    vpsrlw $4, %ymm1, %ymm1
; ALL-NEXT:    vpand %ymm2, %ymm1, %ymm1
; ALL-NEXT:    vpshufb %ymm1, %ymm4, %ymm1
; ALL-NEXT:    vpaddb %ymm3, %ymm1, %ymm1
; ALL-NEXT:    vpsllw $8, %ymm1, %ymm2
; ALL-NEXT:    vpaddb %ymm1, %ymm2, %ymm1
; ALL-NEXT:    vpsrlw $8, %ymm1, %ymm1
; ALL-NEXT:    retq
  %out = call <32 x i16> @llvm.ctpop.v32i16(<32 x i16> %in)
  ret <32 x i16> %out
}

define <64 x i8> @testv64i8(<64 x i8> %in) nounwind {
; ALL-LABEL: testv64i8:
; ALL:       ## BB#0:
; ALL-NEXT:    vmovdqa {{.*#+}} ymm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; ALL-NEXT:    vpand %ymm2, %ymm0, %ymm3
; ALL-NEXT:    vmovdqa {{.*#+}} ymm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; ALL-NEXT:    vpshufb %ymm3, %ymm4, %ymm3
; ALL-NEXT:    vpsrlw $4, %ymm0, %ymm0
; ALL-NEXT:    vpand %ymm2, %ymm0, %ymm0
; ALL-NEXT:    vpshufb %ymm0, %ymm4, %ymm0
; ALL-NEXT:    vpaddb %ymm3, %ymm0, %ymm0
; ALL-NEXT:    vpand %ymm2, %ymm1, %ymm3
; ALL-NEXT:    vpshufb %ymm3, %ymm4, %ymm3
; ALL-NEXT:    vpsrlw $4, %ymm1, %ymm1
; ALL-NEXT:    vpand %ymm2, %ymm1, %ymm1
; ALL-NEXT:    vpshufb %ymm1, %ymm4, %ymm1
; ALL-NEXT:    vpaddb %ymm3, %ymm1, %ymm1
; ALL-NEXT:    retq
  %out = call <64 x i8> @llvm.ctpop.v64i8(<64 x i8> %in)
  ret <64 x i8> %out
}

declare <8 x i64> @llvm.ctpop.v8i64(<8 x i64>)
declare <16 x i32> @llvm.ctpop.v16i32(<16 x i32>)
declare <32 x i16> @llvm.ctpop.v32i16(<32 x i16>)
declare <64 x i8> @llvm.ctpop.v64i8(<64 x i8>)
