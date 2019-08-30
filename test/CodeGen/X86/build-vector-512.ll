; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX-32 --check-prefix=AVX512F-32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX-64 --check-prefix=AVX512F-64
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512f,+avx512bw | FileCheck %s --check-prefix=AVX-32 --check-prefix=AVX512BW-32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw | FileCheck %s --check-prefix=AVX-64 --check-prefix=AVX512BW-64

define <8 x double> @test_buildvector_v8f64(double %a0, double %a1, double %a2, double %a3, double %a4, double %a5, double %a6, double %a7) {
; AVX-32-LABEL: test_buildvector_v8f64:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovups {{[0-9]+}}(%esp), %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v8f64:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vmovlhps {{.*#+}} xmm6 = xmm6[0],xmm7[0]
; AVX-64-NEXT:    vmovlhps {{.*#+}} xmm4 = xmm4[0],xmm5[0]
; AVX-64-NEXT:    vinsertf128 $1, %xmm6, %ymm4, %ymm4
; AVX-64-NEXT:    vmovlhps {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; AVX-64-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-64-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX-64-NEXT:    vinsertf64x4 $1, %ymm4, %zmm0, %zmm0
; AVX-64-NEXT:    retq
  %ins0 = insertelement <8 x double> undef, double %a0, i32 0
  %ins1 = insertelement <8 x double> %ins0, double %a1, i32 1
  %ins2 = insertelement <8 x double> %ins1, double %a2, i32 2
  %ins3 = insertelement <8 x double> %ins2, double %a3, i32 3
  %ins4 = insertelement <8 x double> %ins3, double %a4, i32 4
  %ins5 = insertelement <8 x double> %ins4, double %a5, i32 5
  %ins6 = insertelement <8 x double> %ins5, double %a6, i32 6
  %ins7 = insertelement <8 x double> %ins6, double %a7, i32 7
  ret <8 x double> %ins7
}

define <16 x float> @test_buildvector_v16f32(float %a0, float %a1, float %a2, float %a3, float %a4, float %a5, float %a6, float %a7, float %a8, float %a9, float %a10, float %a11, float %a12, float %a13, float %a14, float %a15) {
; AVX-32-LABEL: test_buildvector_v16f32:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovups {{[0-9]+}}(%esp), %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v16f32:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0],xmm5[0],xmm4[2,3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1],xmm6[0],xmm4[3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm4 = xmm4[0,1,2],xmm7[0]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],xmm3[0]
; AVX-64-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX-64-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[2,3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],mem[0]
; AVX-64-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0],mem[0],xmm2[2,3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1],mem[0],xmm2[3]
; AVX-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1,2],mem[0]
; AVX-64-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX-64-NEXT:    vinsertf64x4 $1, %ymm1, %zmm0, %zmm0
; AVX-64-NEXT:    retq
  %ins0  = insertelement <16 x float> undef,  float %a0,  i32 0
  %ins1  = insertelement <16 x float> %ins0,  float %a1,  i32 1
  %ins2  = insertelement <16 x float> %ins1,  float %a2,  i32 2
  %ins3  = insertelement <16 x float> %ins2,  float %a3,  i32 3
  %ins4  = insertelement <16 x float> %ins3,  float %a4,  i32 4
  %ins5  = insertelement <16 x float> %ins4,  float %a5,  i32 5
  %ins6  = insertelement <16 x float> %ins5,  float %a6,  i32 6
  %ins7  = insertelement <16 x float> %ins6,  float %a7,  i32 7
  %ins8  = insertelement <16 x float> %ins7,  float %a8,  i32 8
  %ins9  = insertelement <16 x float> %ins8,  float %a9,  i32 9
  %ins10 = insertelement <16 x float> %ins9,  float %a10, i32 10
  %ins11 = insertelement <16 x float> %ins10, float %a11, i32 11
  %ins12 = insertelement <16 x float> %ins11, float %a12, i32 12
  %ins13 = insertelement <16 x float> %ins12, float %a13, i32 13
  %ins14 = insertelement <16 x float> %ins13, float %a14, i32 14
  %ins15 = insertelement <16 x float> %ins14, float %a15, i32 15
  ret <16 x float> %ins15
}

define <8 x i64> @test_buildvector_v8i64(i64 %a0, i64 %a1, i64 %a2, i64 %a3, i64 %a4, i64 %a5, i64 %a6, i64 %a7) {
; AVX-32-LABEL: test_buildvector_v8i64:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovups {{[0-9]+}}(%esp), %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v8i64:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vmovq %rcx, %xmm0
; AVX-64-NEXT:    vmovq %rdx, %xmm1
; AVX-64-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-64-NEXT:    vmovq %rsi, %xmm1
; AVX-64-NEXT:    vmovq %rdi, %xmm2
; AVX-64-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX-64-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX-64-NEXT:    vmovq %r9, %xmm1
; AVX-64-NEXT:    vmovq %r8, %xmm2
; AVX-64-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX-64-NEXT:    vinserti128 $1, {{[0-9]+}}(%rsp), %ymm1, %ymm1
; AVX-64-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; AVX-64-NEXT:    retq
  %ins0 = insertelement <8 x i64> undef, i64 %a0, i32 0
  %ins1 = insertelement <8 x i64> %ins0, i64 %a1, i32 1
  %ins2 = insertelement <8 x i64> %ins1, i64 %a2, i32 2
  %ins3 = insertelement <8 x i64> %ins2, i64 %a3, i32 3
  %ins4 = insertelement <8 x i64> %ins3, i64 %a4, i32 4
  %ins5 = insertelement <8 x i64> %ins4, i64 %a5, i32 5
  %ins6 = insertelement <8 x i64> %ins5, i64 %a6, i32 6
  %ins7 = insertelement <8 x i64> %ins6, i64 %a7, i32 7
  ret <8 x i64> %ins7
}

define <16 x i32> @test_buildvector_v16i32(i32 %a0, i32 %a1, i32 %a2, i32 %a3, i32 %a4, i32 %a5, i32 %a6, i32 %a7, i32 %a8, i32 %a9, i32 %a10, i32 %a11, i32 %a12, i32 %a13, i32 %a14, i32 %a15) {
; AVX-32-LABEL: test_buildvector_v16i32:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovups {{[0-9]+}}(%esp), %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v16i32:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vmovd %edi, %xmm0
; AVX-64-NEXT:    vpinsrd $1, %esi, %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrd $2, %edx, %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrd $3, %ecx, %xmm0, %xmm0
; AVX-64-NEXT:    vmovd %r8d, %xmm1
; AVX-64-NEXT:    vpinsrd $1, %r9d, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX-64-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrd $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrd $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrd $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX-64-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; AVX-64-NEXT:    retq
  %ins0  = insertelement <16 x i32> undef,  i32 %a0,  i32 0
  %ins1  = insertelement <16 x i32> %ins0,  i32 %a1,  i32 1
  %ins2  = insertelement <16 x i32> %ins1,  i32 %a2,  i32 2
  %ins3  = insertelement <16 x i32> %ins2,  i32 %a3,  i32 3
  %ins4  = insertelement <16 x i32> %ins3,  i32 %a4,  i32 4
  %ins5  = insertelement <16 x i32> %ins4,  i32 %a5,  i32 5
  %ins6  = insertelement <16 x i32> %ins5,  i32 %a6,  i32 6
  %ins7  = insertelement <16 x i32> %ins6,  i32 %a7,  i32 7
  %ins8  = insertelement <16 x i32> %ins7,  i32 %a8,  i32 8
  %ins9  = insertelement <16 x i32> %ins8,  i32 %a9,  i32 9
  %ins10 = insertelement <16 x i32> %ins9,  i32 %a10, i32 10
  %ins11 = insertelement <16 x i32> %ins10, i32 %a11, i32 11
  %ins12 = insertelement <16 x i32> %ins11, i32 %a12, i32 12
  %ins13 = insertelement <16 x i32> %ins12, i32 %a13, i32 13
  %ins14 = insertelement <16 x i32> %ins13, i32 %a14, i32 14
  %ins15 = insertelement <16 x i32> %ins14, i32 %a15, i32 15
  ret <16 x i32> %ins15
}

define <32 x i16> @test_buildvector_v32i16(i16 %a0, i16 %a1, i16 %a2, i16 %a3, i16 %a4, i16 %a5, i16 %a6, i16 %a7, i16 %a8, i16 %a9, i16 %a10, i16 %a11, i16 %a12, i16 %a13, i16 %a14, i16 %a15, i16 %a16, i16 %a17, i16 %a18, i16 %a19, i16 %a20, i16 %a21, i16 %a22, i16 %a23, i16 %a24, i16 %a25, i16 %a26, i16 %a27, i16 %a28, i16 %a29, i16 %a30, i16 %a31) {
; AVX-32-LABEL: test_buildvector_v32i16:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrw $1, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $2, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $3, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $4, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $5, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $6, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrw $7, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrw $1, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $2, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $3, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $4, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $5, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $6, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $7, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX-32-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrw $1, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $2, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $3, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $4, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $5, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $6, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrw $7, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrw $1, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $2, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $3, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $4, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $5, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $6, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrw $7, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX-32-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v32i16:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrw $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $4, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $5, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $6, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrw $7, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrw $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $4, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $5, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $6, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $7, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX-64-NEXT:    vmovd %edi, %xmm1
; AVX-64-NEXT:    vpinsrw $1, %esi, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $2, %edx, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $3, %ecx, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $4, %r8d, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $5, %r9d, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $6, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrw $7, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrw $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $4, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $5, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $6, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrw $7, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX-64-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; AVX-64-NEXT:    retq
  %ins0  = insertelement <32 x i16> undef,  i16 %a0,  i32 0
  %ins1  = insertelement <32 x i16> %ins0,  i16 %a1,  i32 1
  %ins2  = insertelement <32 x i16> %ins1,  i16 %a2,  i32 2
  %ins3  = insertelement <32 x i16> %ins2,  i16 %a3,  i32 3
  %ins4  = insertelement <32 x i16> %ins3,  i16 %a4,  i32 4
  %ins5  = insertelement <32 x i16> %ins4,  i16 %a5,  i32 5
  %ins6  = insertelement <32 x i16> %ins5,  i16 %a6,  i32 6
  %ins7  = insertelement <32 x i16> %ins6,  i16 %a7,  i32 7
  %ins8  = insertelement <32 x i16> %ins7,  i16 %a8,  i32 8
  %ins9  = insertelement <32 x i16> %ins8,  i16 %a9,  i32 9
  %ins10 = insertelement <32 x i16> %ins9,  i16 %a10, i32 10
  %ins11 = insertelement <32 x i16> %ins10, i16 %a11, i32 11
  %ins12 = insertelement <32 x i16> %ins11, i16 %a12, i32 12
  %ins13 = insertelement <32 x i16> %ins12, i16 %a13, i32 13
  %ins14 = insertelement <32 x i16> %ins13, i16 %a14, i32 14
  %ins15 = insertelement <32 x i16> %ins14, i16 %a15, i32 15
  %ins16 = insertelement <32 x i16> %ins15, i16 %a16, i32 16
  %ins17 = insertelement <32 x i16> %ins16, i16 %a17, i32 17
  %ins18 = insertelement <32 x i16> %ins17, i16 %a18, i32 18
  %ins19 = insertelement <32 x i16> %ins18, i16 %a19, i32 19
  %ins20 = insertelement <32 x i16> %ins19, i16 %a20, i32 20
  %ins21 = insertelement <32 x i16> %ins20, i16 %a21, i32 21
  %ins22 = insertelement <32 x i16> %ins21, i16 %a22, i32 22
  %ins23 = insertelement <32 x i16> %ins22, i16 %a23, i32 23
  %ins24 = insertelement <32 x i16> %ins23, i16 %a24, i32 24
  %ins25 = insertelement <32 x i16> %ins24, i16 %a25, i32 25
  %ins26 = insertelement <32 x i16> %ins25, i16 %a26, i32 26
  %ins27 = insertelement <32 x i16> %ins26, i16 %a27, i32 27
  %ins28 = insertelement <32 x i16> %ins27, i16 %a28, i32 28
  %ins29 = insertelement <32 x i16> %ins28, i16 %a29, i32 29
  %ins30 = insertelement <32 x i16> %ins29, i16 %a30, i32 30
  %ins31 = insertelement <32 x i16> %ins30, i16 %a31, i32 31
  ret <32 x i16> %ins31
}

define <64 x i8> @test_buildvector_v64i8(i8 %a0, i8 %a1, i8 %a2, i8 %a3, i8 %a4, i8 %a5, i8 %a6, i8 %a7, i8 %a8, i8 %a9, i8 %a10, i8 %a11, i8 %a12, i8 %a13, i8 %a14, i8 %a15, i8 %a16, i8 %a17, i8 %a18, i8 %a19, i8 %a20, i8 %a21, i8 %a22, i8 %a23, i8 %a24, i8 %a25, i8 %a26, i8 %a27, i8 %a28, i8 %a29, i8 %a30, i8 %a31, i8 %a32, i8 %a33, i8 %a34, i8 %a35, i8 %a36, i8 %a37, i8 %a38, i8 %a39, i8 %a40, i8 %a41, i8 %a42, i8 %a43, i8 %a44, i8 %a45, i8 %a46, i8 %a47, i8 %a48, i8 %a49, i8 %a50, i8 %a51, i8 %a52, i8 %a53, i8 %a54, i8 %a55, i8 %a56, i8 %a57, i8 %a58, i8 %a59, i8 %a60, i8 %a61, i8 %a62, i8 %a63) {
; AVX-32-LABEL: test_buildvector_v64i8:
; AVX-32:       # %bb.0:
; AVX-32-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrb $1, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $2, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $3, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $4, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $5, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $6, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $7, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $8, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $9, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $10, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $11, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $12, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $13, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $14, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vpinsrb $15, {{[0-9]+}}(%esp), %xmm0, %xmm0
; AVX-32-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrb $1, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $2, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $3, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $4, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $5, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $6, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $7, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $8, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $9, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $10, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $11, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $12, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $13, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $14, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $15, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX-32-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrb $1, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $2, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $3, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $4, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $5, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $6, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $7, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $8, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $9, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $10, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $11, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $12, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $13, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $14, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vpinsrb $15, {{[0-9]+}}(%esp), %xmm1, %xmm1
; AVX-32-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-32-NEXT:    vpinsrb $1, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $2, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $3, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $4, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $5, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $6, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $7, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $8, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $9, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $10, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $11, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $12, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $13, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $14, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vpinsrb $15, {{[0-9]+}}(%esp), %xmm2, %xmm2
; AVX-32-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX-32-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; AVX-32-NEXT:    retl
;
; AVX-64-LABEL: test_buildvector_v64i8:
; AVX-64:       # %bb.0:
; AVX-64-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrb $1, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $2, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $3, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $4, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $5, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $6, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $7, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $8, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $9, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $10, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $11, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $12, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $13, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $14, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vpinsrb $15, {{[0-9]+}}(%rsp), %xmm0, %xmm0
; AVX-64-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrb $1, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $2, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $3, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $4, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $5, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $6, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $7, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $8, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $9, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $10, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $11, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $12, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $13, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $14, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $15, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX-64-NEXT:    vmovd %edi, %xmm1
; AVX-64-NEXT:    vpinsrb $1, %esi, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $2, %edx, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $3, %ecx, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $4, %r8d, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $5, %r9d, %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $6, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $7, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $8, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $9, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $10, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $11, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $12, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $13, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $14, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vpinsrb $15, {{[0-9]+}}(%rsp), %xmm1, %xmm1
; AVX-64-NEXT:    vmovd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-64-NEXT:    vpinsrb $1, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $2, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $3, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $4, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $5, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $6, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $7, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $8, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $9, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $10, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $11, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $12, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $13, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $14, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vpinsrb $15, {{[0-9]+}}(%rsp), %xmm2, %xmm2
; AVX-64-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX-64-NEXT:    vinserti64x4 $1, %ymm0, %zmm1, %zmm0
; AVX-64-NEXT:    retq
  %ins0  = insertelement <64 x i8> undef,  i8 %a0,  i32 0
  %ins1  = insertelement <64 x i8> %ins0,  i8 %a1,  i32 1
  %ins2  = insertelement <64 x i8> %ins1,  i8 %a2,  i32 2
  %ins3  = insertelement <64 x i8> %ins2,  i8 %a3,  i32 3
  %ins4  = insertelement <64 x i8> %ins3,  i8 %a4,  i32 4
  %ins5  = insertelement <64 x i8> %ins4,  i8 %a5,  i32 5
  %ins6  = insertelement <64 x i8> %ins5,  i8 %a6,  i32 6
  %ins7  = insertelement <64 x i8> %ins6,  i8 %a7,  i32 7
  %ins8  = insertelement <64 x i8> %ins7,  i8 %a8,  i32 8
  %ins9  = insertelement <64 x i8> %ins8,  i8 %a9,  i32 9
  %ins10 = insertelement <64 x i8> %ins9,  i8 %a10, i32 10
  %ins11 = insertelement <64 x i8> %ins10, i8 %a11, i32 11
  %ins12 = insertelement <64 x i8> %ins11, i8 %a12, i32 12
  %ins13 = insertelement <64 x i8> %ins12, i8 %a13, i32 13
  %ins14 = insertelement <64 x i8> %ins13, i8 %a14, i32 14
  %ins15 = insertelement <64 x i8> %ins14, i8 %a15, i32 15
  %ins16 = insertelement <64 x i8> %ins15, i8 %a16, i32 16
  %ins17 = insertelement <64 x i8> %ins16, i8 %a17, i32 17
  %ins18 = insertelement <64 x i8> %ins17, i8 %a18, i32 18
  %ins19 = insertelement <64 x i8> %ins18, i8 %a19, i32 19
  %ins20 = insertelement <64 x i8> %ins19, i8 %a20, i32 20
  %ins21 = insertelement <64 x i8> %ins20, i8 %a21, i32 21
  %ins22 = insertelement <64 x i8> %ins21, i8 %a22, i32 22
  %ins23 = insertelement <64 x i8> %ins22, i8 %a23, i32 23
  %ins24 = insertelement <64 x i8> %ins23, i8 %a24, i32 24
  %ins25 = insertelement <64 x i8> %ins24, i8 %a25, i32 25
  %ins26 = insertelement <64 x i8> %ins25, i8 %a26, i32 26
  %ins27 = insertelement <64 x i8> %ins26, i8 %a27, i32 27
  %ins28 = insertelement <64 x i8> %ins27, i8 %a28, i32 28
  %ins29 = insertelement <64 x i8> %ins28, i8 %a29, i32 29
  %ins30 = insertelement <64 x i8> %ins29, i8 %a30, i32 30
  %ins31 = insertelement <64 x i8> %ins30, i8 %a31, i32 31
  %ins32 = insertelement <64 x i8> %ins31, i8 %a32, i32 32
  %ins33 = insertelement <64 x i8> %ins32, i8 %a33, i32 33
  %ins34 = insertelement <64 x i8> %ins33, i8 %a34, i32 34
  %ins35 = insertelement <64 x i8> %ins34, i8 %a35, i32 35
  %ins36 = insertelement <64 x i8> %ins35, i8 %a36, i32 36
  %ins37 = insertelement <64 x i8> %ins36, i8 %a37, i32 37
  %ins38 = insertelement <64 x i8> %ins37, i8 %a38, i32 38
  %ins39 = insertelement <64 x i8> %ins38, i8 %a39, i32 39
  %ins40 = insertelement <64 x i8> %ins39, i8 %a40, i32 40
  %ins41 = insertelement <64 x i8> %ins40, i8 %a41, i32 41
  %ins42 = insertelement <64 x i8> %ins41, i8 %a42, i32 42
  %ins43 = insertelement <64 x i8> %ins42, i8 %a43, i32 43
  %ins44 = insertelement <64 x i8> %ins43, i8 %a44, i32 44
  %ins45 = insertelement <64 x i8> %ins44, i8 %a45, i32 45
  %ins46 = insertelement <64 x i8> %ins45, i8 %a46, i32 46
  %ins47 = insertelement <64 x i8> %ins46, i8 %a47, i32 47
  %ins48 = insertelement <64 x i8> %ins47, i8 %a48, i32 48
  %ins49 = insertelement <64 x i8> %ins48, i8 %a49, i32 49
  %ins50 = insertelement <64 x i8> %ins49, i8 %a50, i32 50
  %ins51 = insertelement <64 x i8> %ins50, i8 %a51, i32 51
  %ins52 = insertelement <64 x i8> %ins51, i8 %a52, i32 52
  %ins53 = insertelement <64 x i8> %ins52, i8 %a53, i32 53
  %ins54 = insertelement <64 x i8> %ins53, i8 %a54, i32 54
  %ins55 = insertelement <64 x i8> %ins54, i8 %a55, i32 55
  %ins56 = insertelement <64 x i8> %ins55, i8 %a56, i32 56
  %ins57 = insertelement <64 x i8> %ins56, i8 %a57, i32 57
  %ins58 = insertelement <64 x i8> %ins57, i8 %a58, i32 58
  %ins59 = insertelement <64 x i8> %ins58, i8 %a59, i32 59
  %ins60 = insertelement <64 x i8> %ins59, i8 %a60, i32 60
  %ins61 = insertelement <64 x i8> %ins60, i8 %a61, i32 61
  %ins62 = insertelement <64 x i8> %ins61, i8 %a62, i32 62
  %ins63 = insertelement <64 x i8> %ins62, i8 %a63, i32 63
  ret <64 x i8> %ins63
}
