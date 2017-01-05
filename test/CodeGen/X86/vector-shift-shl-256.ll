; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+xop,+avx | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+xop,+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX2
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512bw | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512BW

;
; Variable Shifts
;

define <4 x i64> @var_shift_v4i64(<4 x i64> %a, <4 x i64> %b) nounwind {
; AVX1-LABEL: var_shift_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpsllq %xmm2, %xmm3, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[2,3,0,1]
; AVX1-NEXT:    vpsllq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm4[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm3[0,1,2,3],xmm0[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vpshlq %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vpshlq %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvq %ymm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: var_shift_v4i64:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllvq %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <4 x i64> %a, %b
  ret <4 x i64> %shift
}

define <8 x i32> @var_shift_v8i32(<8 x i32> %a, <8 x i32> %b) nounwind {
; AVX1-LABEL: var_shift_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpslld $23, %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [1065353216,1065353216,1065353216,1065353216]
; AVX1-NEXT:    vpaddd %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vcvttps2dq %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vpmulld %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpmulld %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vpshld %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: var_shift_v8i32:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllvd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <8 x i32> %a, %b
  ret <8 x i32> %shift
}

define <16 x i16> @var_shift_v16i16(<16 x i16> %a, <16 x i16> %b) nounwind {
; AVX1-LABEL: var_shift_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpsllw $12, %xmm2, %xmm3
; AVX1-NEXT:    vpsllw $4, %xmm2, %xmm2
; AVX1-NEXT:    vpor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpaddw %xmm2, %xmm2, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vpsllw $8, %xmm4, %xmm5
; AVX1-NEXT:    vpblendvb %xmm2, %xmm5, %xmm4, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm2, %xmm4
; AVX1-NEXT:    vpblendvb %xmm3, %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $2, %xmm2, %xmm4
; AVX1-NEXT:    vpaddw %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm3, %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $1, %xmm2, %xmm4
; AVX1-NEXT:    vpaddw %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm3, %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $12, %xmm1, %xmm3
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm1
; AVX1-NEXT:    vpor %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpaddw %xmm1, %xmm1, %xmm3
; AVX1-NEXT:    vpsllw $8, %xmm0, %xmm4
; AVX1-NEXT:    vpblendvb %xmm1, %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm1
; AVX1-NEXT:    vpblendvb %xmm3, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm1
; AVX1-NEXT:    vpaddw %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm3, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $1, %xmm0, %xmm1
; AVX1-NEXT:    vpaddw %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm3, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpxor %ymm2, %ymm2, %ymm2
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm3 = ymm1[4],ymm2[4],ymm1[5],ymm2[5],ymm1[6],ymm2[6],ymm1[7],ymm2[7],ymm1[12],ymm2[12],ymm1[13],ymm2[13],ymm1[14],ymm2[14],ymm1[15],ymm2[15]
; AVX2-NEXT:    vpunpckhwd {{.*#+}} ymm4 = ymm2[4],ymm0[4],ymm2[5],ymm0[5],ymm2[6],ymm0[6],ymm2[7],ymm0[7],ymm2[12],ymm0[12],ymm2[13],ymm0[13],ymm2[14],ymm0[14],ymm2[15],ymm0[15]
; AVX2-NEXT:    vpsllvd %ymm3, %ymm4, %ymm3
; AVX2-NEXT:    vpsrld $16, %ymm3, %ymm3
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm1 = ymm1[0],ymm2[0],ymm1[1],ymm2[1],ymm1[2],ymm2[2],ymm1[3],ymm2[3],ymm1[8],ymm2[8],ymm1[9],ymm2[9],ymm1[10],ymm2[10],ymm1[11],ymm2[11]
; AVX2-NEXT:    vpunpcklwd {{.*#+}} ymm0 = ymm2[0],ymm0[0],ymm2[1],ymm0[1],ymm2[2],ymm0[2],ymm2[3],ymm0[3],ymm2[8],ymm0[8],ymm2[9],ymm0[9],ymm2[10],ymm0[10],ymm2[11],ymm0[11]
; AVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $16, %ymm0, %ymm0
; AVX2-NEXT:    vpackusdw %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vpshlw %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vpshlw %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vpshlw %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vpshlw %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: var_shift_v16i16:
; AVX512:       ## BB#0:
; AVX512-NEXT:    ## kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; AVX512-NEXT:    ## kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; AVX512-NEXT:    vpsllvw %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    ## kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512-NEXT:    retq
  %shift = shl <16 x i16> %a, %b
  ret <16 x i16> %shift
}

define <32 x i8> @var_shift_v32i8(<32 x i8> %a, <32 x i8> %b) nounwind {
; AVX1-LABEL: var_shift_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vpsllw $5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $2, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = [252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252]
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpaddb %xmm2, %xmm2, %xmm3
; AVX1-NEXT:    vpaddb %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpblendvb %xmm5, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpaddb %xmm0, %xmm0, %xmm3
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; XOPAVX1-NEXT:    vpshlb %xmm2, %xmm3, %xmm2
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; XOPAVX2-NEXT:    vpshlb %xmm2, %xmm3, %xmm2
; XOPAVX2-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: var_shift_v32i8:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX512-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <32 x i8> %a, %b
  ret <32 x i8> %shift
}

;
; Uniform Variable Shifts
;

define <4 x i64> @splatvar_shift_v4i64(<4 x i64> %a, <4 x i64> %b) nounwind {
; AVX1-LABEL: splatvar_shift_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllq %xmm1, %xmm2, %xmm2
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatvar_shift_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllq %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatvar_shift_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpsllq %xmm1, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatvar_shift_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllq %xmm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatvar_shift_v4i64:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllq %xmm1, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %splat = shufflevector <4 x i64> %b, <4 x i64> undef, <4 x i32> zeroinitializer
  %shift = shl <4 x i64> %a, %splat
  ret <4 x i64> %shift
}

define <8 x i32> @splatvar_shift_v8i32(<8 x i32> %a, <8 x i32> %b) nounwind {
; AVX1-LABEL: splatvar_shift_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX1-NEXT:    vpslld %xmm1, %xmm2, %xmm2
; AVX1-NEXT:    vpslld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatvar_shift_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX2-NEXT:    vpslld %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatvar_shift_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; XOPAVX1-NEXT:    vpslld %xmm1, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpslld %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatvar_shift_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; XOPAVX2-NEXT:    vpslld %xmm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatvar_shift_v8i32:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX512-NEXT:    vpslld %xmm1, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %splat = shufflevector <8 x i32> %b, <8 x i32> undef, <8 x i32> zeroinitializer
  %shift = shl <8 x i32> %a, %splat
  ret <8 x i32> %shift
}

define <16 x i16> @splatvar_shift_v16i16(<16 x i16> %a, <16 x i16> %b) nounwind {
; AVX1-LABEL: splatvar_shift_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; AVX1-NEXT:    vpsllw %xmm1, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatvar_shift_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; AVX2-NEXT:    vpsllw %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatvar_shift_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; XOPAVX1-NEXT:    vpsllw %xmm1, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpsllw %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatvar_shift_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; XOPAVX2-NEXT:    vpsllw %xmm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatvar_shift_v16i16:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpmovzxwq {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero
; AVX512-NEXT:    vpsllw %xmm1, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %splat = shufflevector <16 x i16> %b, <16 x i16> undef, <16 x i32> zeroinitializer
  %shift = shl <16 x i16> %a, %splat
  ret <16 x i16> %shift
}

define <32 x i8> @splatvar_shift_v32i8(<32 x i8> %a, <32 x i8> %b) nounwind {
; AVX1-LABEL: splatvar_shift_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $2, %xmm2, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm5 = [252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252]
; AVX1-NEXT:    vpand %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpaddb %xmm2, %xmm2, %xmm3
; AVX1-NEXT:    vpaddb %xmm6, %xmm6, %xmm7
; AVX1-NEXT:    vpblendvb %xmm7, %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm3
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm1
; AVX1-NEXT:    vpand %xmm5, %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm6, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddb %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vpblendvb %xmm7, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatvar_shift_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm1, %ymm1
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatvar_shift_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatvar_shift_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpbroadcastb %xmm1, %ymm1
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm2
; XOPAVX2-NEXT:    vextracti128 $1, %ymm1, %xmm3
; XOPAVX2-NEXT:    vpshlb %xmm3, %xmm2, %xmm2
; XOPAVX2-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatvar_shift_v32i8:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpbroadcastb %xmm1, %ymm1
; AVX512-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %splat = shufflevector <32 x i8> %b, <32 x i8> undef, <32 x i32> zeroinitializer
  %shift = shl <32 x i8> %a, %splat
  ret <32 x i8> %shift
}

;
; Constant Shifts
;

define <4 x i64> @constant_shift_v4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: constant_shift_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllq $62, %xmm1, %xmm2
; AVX1-NEXT:    vpsllq $31, %xmm1, %xmm1
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpsllq $7, %xmm0, %xmm2
; AVX1-NEXT:    vpsllq $1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvq {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlq {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpshlq {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvq {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: constant_shift_v4i64:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllvq {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <4 x i64> %a, <i64 1, i64 7, i64 31, i64 62>
  ret <4 x i64> %shift
}

define <8 x i32> @constant_shift_v8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: constant_shift_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvd {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvd {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: constant_shift_v8i32:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllvd {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <8 x i32> %a, <i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 8, i32 7>
  ret <8 x i32> %shift
}

define <16 x i16> @constant_shift_v16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: constant_shift_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpmullw {{.*}}(%rip), %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmullw {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmullw {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpmullw {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: constant_shift_v16i16:
; AVX512:       ## BB#0:
; AVX512-NEXT:    ## kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; AVX512-NEXT:    vmovdqa {{.*#+}} ymm1 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
; AVX512-NEXT:    vpsllvw %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    ## kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512-NEXT:    retq
  %shift = shl <16 x i16> %a, <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7, i16 8, i16 9, i16 10, i16 11, i16 12, i16 13, i16 14, i16 15>
  ret <16 x i16> %shift
}

define <32 x i8> @constant_shift_v32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: constant_shift_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240]
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; AVX1-NEXT:    vpsllw $5, %xmm4, %xmm4
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $2, %xmm1, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm5 = [252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,252]
; AVX1-NEXT:    vpand %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpaddb %xmm4, %xmm4, %xmm6
; AVX1-NEXT:    vpblendvb %xmm6, %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm2
; AVX1-NEXT:    vpaddb %xmm6, %xmm6, %xmm7
; AVX1-NEXT:    vpblendvb %xmm7, %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm2
; AVX1-NEXT:    vpand %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpblendvb %xmm4, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm2
; AVX1-NEXT:    vpand %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpblendvb %xmm6, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpaddb %xmm0, %xmm0, %xmm2
; AVX1-NEXT:    vpblendvb %xmm7, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; AVX2-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX2-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX2-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; XOPAVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; XOPAVX1-NEXT:    vpshlb %xmm2, %xmm1, %xmm1
; XOPAVX1-NEXT:    vpshlb %xmm2, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; XOPAVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; XOPAVX2-NEXT:    vpshlb %xmm2, %xmm1, %xmm1
; XOPAVX2-NEXT:    vpshlb %xmm2, %xmm0, %xmm0
; XOPAVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: constant_shift_v32i8:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vmovdqa {{.*#+}} ymm1 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; AVX512-NEXT:    vpsllw $5, %ymm1, %ymm1
; AVX512-NEXT:    vpsllw $4, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpsllw $2, %ymm0, %ymm2
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    vpaddb %ymm0, %ymm0, %ymm2
; AVX512-NEXT:    vpaddb %ymm1, %ymm1, %ymm1
; AVX512-NEXT:    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <32 x i8> %a, <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0>
  ret <32 x i8> %shift
}

;
; Uniform Constant Shifts
;

define <4 x i64> @splatconstant_shift_v4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: splatconstant_shift_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllq $7, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpsllq $7, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_shift_v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllq $7, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_shift_v4i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpsllq $7, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpsllq $7, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_shift_v4i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllq $7, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatconstant_shift_v4i64:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllq $7, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <4 x i64> %a, <i64 7, i64 7, i64 7, i64 7>
  ret <4 x i64> %shift
}

define <8 x i32> @splatconstant_shift_v8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: splatconstant_shift_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $5, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpslld $5, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_shift_v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpslld $5, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_shift_v8i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpslld $5, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpslld $5, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_shift_v8i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpslld $5, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatconstant_shift_v8i32:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpslld $5, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <8 x i32> %a, <i32 5, i32 5, i32 5, i32 5, i32 5, i32 5, i32 5, i32 5>
  ret <8 x i32> %shift
}

define <16 x i16> @splatconstant_shift_v16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: splatconstant_shift_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllw $3, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpsllw $3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_shift_v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $3, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_shift_v16i16:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpsllw $3, %xmm0, %xmm1
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; XOPAVX1-NEXT:    vpsllw $3, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_shift_v16i16:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllw $3, %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatconstant_shift_v16i16:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllw $3, %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <16 x i16> %a, <i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3>
  ret <16 x i16> %shift
}

define <32 x i8> @splatconstant_shift_v32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: splatconstant_shift_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $3, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248]
; AVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $3, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatconstant_shift_v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllw $3, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatconstant_shift_v32i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; XOPAVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]
; XOPAVX1-NEXT:    vpshlb %xmm2, %xmm1, %xmm1
; XOPAVX1-NEXT:    vpshlb %xmm2, %xmm0, %xmm0
; XOPAVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatconstant_shift_v32i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllw $3, %ymm0, %ymm0
; XOPAVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; XOPAVX2-NEXT:    retq
;
; AVX512-LABEL: splatconstant_shift_v32i8:
; AVX512:       ## BB#0:
; AVX512-NEXT:    vpsllw $3, %ymm0, %ymm0
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    retq
  %shift = shl <32 x i8> %a, <i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3>
  ret <32 x i8> %shift
}
