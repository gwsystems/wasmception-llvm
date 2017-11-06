; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=AVX,AVX512,AVXNOVLBW,AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512,AVXNOVLBW,AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512,AVX512VLBW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,+avx512vbmi | FileCheck %s --check-prefixes=AVX,AVX512,AVX512VLBW,VBMI

define <2 x i64> @var_shuffle_v2i64(<2 x i64> %v, <2 x i64> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v2i64:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movq %xmm1, %rax
; SSSE3-NEXT:    andl $1, %eax
; SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm1, %rcx
; SSSE3-NEXT:    andl $1, %ecx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovq %xmm1, %rax
; AVX-NEXT:    andl $1, %eax
; AVX-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX-NEXT:    andl $1, %ecx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    retq
  %index0 = extractelement <2 x i64> %indices, i32 0
  %index1 = extractelement <2 x i64> %indices, i32 1
  %v0 = extractelement <2 x i64> %v, i64 %index0
  %v1 = extractelement <2 x i64> %v, i64 %index1
  %ret0 = insertelement <2 x i64> undef, i64 %v0, i32 0
  %ret1 = insertelement <2 x i64> %ret0, i64 %v1, i32 1
  ret <2 x i64> %ret1
}

define <4 x i32> @var_shuffle_v4i32(<4 x i32> %v, <4 x i32> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v4i32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm2, %rax
; SSSE3-NEXT:    movq %rax, %rcx
; SSSE3-NEXT:    sarq $32, %rcx
; SSSE3-NEXT:    movq %xmm1, %rdx
; SSSE3-NEXT:    movq %rdx, %rsi
; SSSE3-NEXT:    sarq $32, %rsi
; SSSE3-NEXT:    andl $3, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $3, %esi
; SSSE3-NEXT:    andl $3, %eax
; SSSE3-NEXT:    andl $3, %ecx
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrq $1, %xmm1, %rax
; AVX-NEXT:    movq %rax, %rcx
; AVX-NEXT:    sarq $32, %rcx
; AVX-NEXT:    vmovq %xmm1, %rdx
; AVX-NEXT:    movq %rdx, %rsi
; AVX-NEXT:    sarq $32, %rsi
; AVX-NEXT:    andl $3, %edx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    andl $3, %eax
; AVX-NEXT:    andl $3, %ecx
; AVX-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vpinsrd $1, -24(%rsp,%rsi,4), %xmm0, %xmm0
; AVX-NEXT:    vpinsrd $2, -24(%rsp,%rax,4), %xmm0, %xmm0
; AVX-NEXT:    vpinsrd $3, -24(%rsp,%rcx,4), %xmm0, %xmm0
; AVX-NEXT:    retq
  %index0 = extractelement <4 x i32> %indices, i32 0
  %index1 = extractelement <4 x i32> %indices, i32 1
  %index2 = extractelement <4 x i32> %indices, i32 2
  %index3 = extractelement <4 x i32> %indices, i32 3
  %v0 = extractelement <4 x i32> %v, i32 %index0
  %v1 = extractelement <4 x i32> %v, i32 %index1
  %v2 = extractelement <4 x i32> %v, i32 %index2
  %v3 = extractelement <4 x i32> %v, i32 %index3
  %ret0 = insertelement <4 x i32> undef, i32 %v0, i32 0
  %ret1 = insertelement <4 x i32> %ret0, i32 %v1, i32 1
  %ret2 = insertelement <4 x i32> %ret1, i32 %v2, i32 2
  %ret3 = insertelement <4 x i32> %ret2, i32 %v3, i32 3
  ret <4 x i32> %ret3
}

define <8 x i16> @var_shuffle_v8i16(<8 x i16> %v, <8 x i16> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v8i16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %xmm1, %r8d
; SSSE3-NEXT:    pextrw $1, %xmm1, %r9d
; SSSE3-NEXT:    pextrw $2, %xmm1, %r10d
; SSSE3-NEXT:    pextrw $3, %xmm1, %esi
; SSSE3-NEXT:    pextrw $4, %xmm1, %edi
; SSSE3-NEXT:    pextrw $5, %xmm1, %eax
; SSSE3-NEXT:    pextrw $6, %xmm1, %ecx
; SSSE3-NEXT:    pextrw $7, %xmm1, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $7, %r8d
; SSSE3-NEXT:    andl $7, %r9d
; SSSE3-NEXT:    andl $7, %r10d
; SSSE3-NEXT:    andl $7, %esi
; SSSE3-NEXT:    andl $7, %edi
; SSSE3-NEXT:    andl $7, %eax
; SSSE3-NEXT:    andl $7, %ecx
; SSSE3-NEXT:    andl $7, %edx
; SSSE3-NEXT:    movzwl -24(%rsp,%rdx,2), %edx
; SSSE3-NEXT:    movd %edx, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%rcx,2), %ecx
; SSSE3-NEXT:    movd %ecx, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movzwl -24(%rsp,%rax,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%rdi,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm2
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1],xmm2[2],xmm0[2],xmm2[3],xmm0[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; SSSE3-NEXT:    movzwl -24(%rsp,%rsi,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    movzwl -24(%rsp,%r10,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm1
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3]
; SSSE3-NEXT:    movzwl -24(%rsp,%r9,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm3
; SSSE3-NEXT:    movzwl -24(%rsp,%r8,2), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSSE3-NEXT:    retq
;
; AVXNOVLBW-LABEL: var_shuffle_v8i16:
; AVXNOVLBW:       # BB#0:
; AVXNOVLBW-NEXT:    vmovd %xmm1, %eax
; AVXNOVLBW-NEXT:    vpextrw $1, %xmm1, %r10d
; AVXNOVLBW-NEXT:    vpextrw $2, %xmm1, %ecx
; AVXNOVLBW-NEXT:    vpextrw $3, %xmm1, %edx
; AVXNOVLBW-NEXT:    vpextrw $4, %xmm1, %esi
; AVXNOVLBW-NEXT:    vpextrw $5, %xmm1, %edi
; AVXNOVLBW-NEXT:    vpextrw $6, %xmm1, %r8d
; AVXNOVLBW-NEXT:    vpextrw $7, %xmm1, %r9d
; AVXNOVLBW-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVXNOVLBW-NEXT:    andl $7, %eax
; AVXNOVLBW-NEXT:    andl $7, %r10d
; AVXNOVLBW-NEXT:    andl $7, %ecx
; AVXNOVLBW-NEXT:    andl $7, %edx
; AVXNOVLBW-NEXT:    andl $7, %esi
; AVXNOVLBW-NEXT:    andl $7, %edi
; AVXNOVLBW-NEXT:    andl $7, %r8d
; AVXNOVLBW-NEXT:    andl $7, %r9d
; AVXNOVLBW-NEXT:    movzwl -24(%rsp,%rax,2), %eax
; AVXNOVLBW-NEXT:    vmovd %eax, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $1, -24(%rsp,%r10,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $2, -24(%rsp,%rcx,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $3, -24(%rsp,%rdx,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $4, -24(%rsp,%rsi,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $5, -24(%rsp,%rdi,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $6, -24(%rsp,%r8,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    vpinsrw $7, -24(%rsp,%r9,2), %xmm0, %xmm0
; AVXNOVLBW-NEXT:    retq
;
; AVX512VLBW-LABEL: var_shuffle_v8i16:
; AVX512VLBW:       # BB#0:
; AVX512VLBW-NEXT:    vpermw %xmm0, %xmm1, %xmm0
; AVX512VLBW-NEXT:    retq
  %index0 = extractelement <8 x i16> %indices, i32 0
  %index1 = extractelement <8 x i16> %indices, i32 1
  %index2 = extractelement <8 x i16> %indices, i32 2
  %index3 = extractelement <8 x i16> %indices, i32 3
  %index4 = extractelement <8 x i16> %indices, i32 4
  %index5 = extractelement <8 x i16> %indices, i32 5
  %index6 = extractelement <8 x i16> %indices, i32 6
  %index7 = extractelement <8 x i16> %indices, i32 7
  %v0 = extractelement <8 x i16> %v, i16 %index0
  %v1 = extractelement <8 x i16> %v, i16 %index1
  %v2 = extractelement <8 x i16> %v, i16 %index2
  %v3 = extractelement <8 x i16> %v, i16 %index3
  %v4 = extractelement <8 x i16> %v, i16 %index4
  %v5 = extractelement <8 x i16> %v, i16 %index5
  %v6 = extractelement <8 x i16> %v, i16 %index6
  %v7 = extractelement <8 x i16> %v, i16 %index7
  %ret0 = insertelement <8 x i16> undef, i16 %v0, i32 0
  %ret1 = insertelement <8 x i16> %ret0, i16 %v1, i32 1
  %ret2 = insertelement <8 x i16> %ret1, i16 %v2, i32 2
  %ret3 = insertelement <8 x i16> %ret2, i16 %v3, i32 3
  %ret4 = insertelement <8 x i16> %ret3, i16 %v4, i32 4
  %ret5 = insertelement <8 x i16> %ret4, i16 %v5, i32 5
  %ret6 = insertelement <8 x i16> %ret5, i16 %v6, i32 6
  %ret7 = insertelement <8 x i16> %ret6, i16 %v7, i32 7
  ret <8 x i16> %ret7
}

define <16 x i8> @var_shuffle_v16i8(<16 x i8> %v, <16 x i8> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v16i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb %xmm0, %xmm1
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %index0 = extractelement <16 x i8> %indices, i32 0
  %index1 = extractelement <16 x i8> %indices, i32 1
  %index2 = extractelement <16 x i8> %indices, i32 2
  %index3 = extractelement <16 x i8> %indices, i32 3
  %index4 = extractelement <16 x i8> %indices, i32 4
  %index5 = extractelement <16 x i8> %indices, i32 5
  %index6 = extractelement <16 x i8> %indices, i32 6
  %index7 = extractelement <16 x i8> %indices, i32 7
  %index8 = extractelement <16 x i8> %indices, i32 8
  %index9 = extractelement <16 x i8> %indices, i32 9
  %index10 = extractelement <16 x i8> %indices, i32 10
  %index11 = extractelement <16 x i8> %indices, i32 11
  %index12 = extractelement <16 x i8> %indices, i32 12
  %index13 = extractelement <16 x i8> %indices, i32 13
  %index14 = extractelement <16 x i8> %indices, i32 14
  %index15 = extractelement <16 x i8> %indices, i32 15
  %v0 = extractelement <16 x i8> %v, i8 %index0
  %v1 = extractelement <16 x i8> %v, i8 %index1
  %v2 = extractelement <16 x i8> %v, i8 %index2
  %v3 = extractelement <16 x i8> %v, i8 %index3
  %v4 = extractelement <16 x i8> %v, i8 %index4
  %v5 = extractelement <16 x i8> %v, i8 %index5
  %v6 = extractelement <16 x i8> %v, i8 %index6
  %v7 = extractelement <16 x i8> %v, i8 %index7
  %v8 = extractelement <16 x i8> %v, i8 %index8
  %v9 = extractelement <16 x i8> %v, i8 %index9
  %v10 = extractelement <16 x i8> %v, i8 %index10
  %v11 = extractelement <16 x i8> %v, i8 %index11
  %v12 = extractelement <16 x i8> %v, i8 %index12
  %v13 = extractelement <16 x i8> %v, i8 %index13
  %v14 = extractelement <16 x i8> %v, i8 %index14
  %v15 = extractelement <16 x i8> %v, i8 %index15
  %ret0 = insertelement <16 x i8> undef, i8 %v0, i32 0
  %ret1 = insertelement <16 x i8> %ret0, i8 %v1, i32 1
  %ret2 = insertelement <16 x i8> %ret1, i8 %v2, i32 2
  %ret3 = insertelement <16 x i8> %ret2, i8 %v3, i32 3
  %ret4 = insertelement <16 x i8> %ret3, i8 %v4, i32 4
  %ret5 = insertelement <16 x i8> %ret4, i8 %v5, i32 5
  %ret6 = insertelement <16 x i8> %ret5, i8 %v6, i32 6
  %ret7 = insertelement <16 x i8> %ret6, i8 %v7, i32 7
  %ret8 = insertelement <16 x i8> %ret7, i8 %v8, i32 8
  %ret9 = insertelement <16 x i8> %ret8, i8 %v9, i32 9
  %ret10 = insertelement <16 x i8> %ret9, i8 %v10, i32 10
  %ret11 = insertelement <16 x i8> %ret10, i8 %v11, i32 11
  %ret12 = insertelement <16 x i8> %ret11, i8 %v12, i32 12
  %ret13 = insertelement <16 x i8> %ret12, i8 %v13, i32 13
  %ret14 = insertelement <16 x i8> %ret13, i8 %v14, i32 14
  %ret15 = insertelement <16 x i8> %ret14, i8 %v15, i32 15
  ret <16 x i8> %ret15
}

define <2 x double> @var_shuffle_v2f64(<2 x double> %v, <2 x i64> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v2f64:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movq %xmm1, %rax
; SSSE3-NEXT:    andl $1, %eax
; SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm1, %rcx
; SSSE3-NEXT:    andl $1, %ecx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSSE3-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v2f64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovq %xmm1, %rax
; AVX-NEXT:    andl $1, %eax
; AVX-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX-NEXT:    andl $1, %ecx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; AVX-NEXT:    retq
  %index0 = extractelement <2 x i64> %indices, i32 0
  %index1 = extractelement <2 x i64> %indices, i32 1
  %v0 = extractelement <2 x double> %v, i64 %index0
  %v1 = extractelement <2 x double> %v, i64 %index1
  %ret0 = insertelement <2 x double> undef, double %v0, i32 0
  %ret1 = insertelement <2 x double> %ret0, double %v1, i32 1
  ret <2 x double> %ret1
}

define <4 x float> @var_shuffle_v4f32(<4 x float> %v, <4 x i32> %indices) nounwind {
; SSSE3-LABEL: var_shuffle_v4f32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSSE3-NEXT:    movq %xmm2, %rax
; SSSE3-NEXT:    movq %rax, %rcx
; SSSE3-NEXT:    sarq $32, %rcx
; SSSE3-NEXT:    movq %xmm1, %rdx
; SSSE3-NEXT:    movq %rdx, %rsi
; SSSE3-NEXT:    sarq $32, %rsi
; SSSE3-NEXT:    andl $3, %edx
; SSSE3-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    andl $3, %esi
; SSSE3-NEXT:    andl $3, %eax
; SSSE3-NEXT:    andl $3, %ecx
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSSE3-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSSE3-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSSE3-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; AVX-LABEL: var_shuffle_v4f32:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrq $1, %xmm1, %rax
; AVX-NEXT:    movq %rax, %rcx
; AVX-NEXT:    sarq $32, %rcx
; AVX-NEXT:    vmovq %xmm1, %rdx
; AVX-NEXT:    movq %rdx, %rsi
; AVX-NEXT:    sarq $32, %rsi
; AVX-NEXT:    andl $3, %edx
; AVX-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    andl $3, %eax
; AVX-NEXT:    andl $3, %ecx
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],mem[0],xmm0[3]
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],mem[0]
; AVX-NEXT:    retq
  %index0 = extractelement <4 x i32> %indices, i32 0
  %index1 = extractelement <4 x i32> %indices, i32 1
  %index2 = extractelement <4 x i32> %indices, i32 2
  %index3 = extractelement <4 x i32> %indices, i32 3
  %v0 = extractelement <4 x float> %v, i32 %index0
  %v1 = extractelement <4 x float> %v, i32 %index1
  %v2 = extractelement <4 x float> %v, i32 %index2
  %v3 = extractelement <4 x float> %v, i32 %index3
  %ret0 = insertelement <4 x float> undef, float %v0, i32 0
  %ret1 = insertelement <4 x float> %ret0, float %v1, i32 1
  %ret2 = insertelement <4 x float> %ret1, float %v2, i32 2
  %ret3 = insertelement <4 x float> %ret2, float %v3, i32 3
  ret <4 x float> %ret3
}
