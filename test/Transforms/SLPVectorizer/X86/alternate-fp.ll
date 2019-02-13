; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -mtriple=x86_64-unknown -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=SSE
; RUN: opt < %s -mtriple=x86_64-unknown -mcpu=slm -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=SLM
; RUN: opt < %s -mtriple=x86_64-unknown -mcpu=corei7-avx -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=AVX --check-prefix=AVX1
; RUN: opt < %s -mtriple=x86_64-unknown -mcpu=core-avx2 -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=AVX --check-prefix=AVX2
; RUN: opt < %s -mtriple=x86_64-unknown -mcpu=knl -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: opt < %s -mtriple=x86_64-unknown -mcpu=skx -basicaa -slp-vectorizer -instcombine -S | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512BW

define <8 x float> @fadd_fsub_v8f32(<8 x float> %a, <8 x float> %b) {
; CHECK-LABEL: @fadd_fsub_v8f32(
; CHECK-NEXT:    [[TMP1:%.*]] = fadd <8 x float> [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fsub <8 x float> [[A]], [[B]]
; CHECK-NEXT:    [[R7:%.*]] = shufflevector <8 x float> [[TMP2]], <8 x float> [[TMP1]], <8 x i32> <i32 8, i32 1, i32 2, i32 11, i32 12, i32 5, i32 6, i32 15>
; CHECK-NEXT:    ret <8 x float> [[R7]]
;
  %a0 = extractelement <8 x float> %a, i32 0
  %a1 = extractelement <8 x float> %a, i32 1
  %a2 = extractelement <8 x float> %a, i32 2
  %a3 = extractelement <8 x float> %a, i32 3
  %a4 = extractelement <8 x float> %a, i32 4
  %a5 = extractelement <8 x float> %a, i32 5
  %a6 = extractelement <8 x float> %a, i32 6
  %a7 = extractelement <8 x float> %a, i32 7
  %b0 = extractelement <8 x float> %b, i32 0
  %b1 = extractelement <8 x float> %b, i32 1
  %b2 = extractelement <8 x float> %b, i32 2
  %b3 = extractelement <8 x float> %b, i32 3
  %b4 = extractelement <8 x float> %b, i32 4
  %b5 = extractelement <8 x float> %b, i32 5
  %b6 = extractelement <8 x float> %b, i32 6
  %b7 = extractelement <8 x float> %b, i32 7
  %ab0 = fadd float %a0, %b0
  %ab1 = fsub float %a1, %b1
  %ab2 = fsub float %a2, %b2
  %ab3 = fadd float %a3, %b3
  %ab4 = fadd float %a4, %b4
  %ab5 = fsub float %a5, %b5
  %ab6 = fsub float %a6, %b6
  %ab7 = fadd float %a7, %b7
  %r0 = insertelement <8 x float> undef, float %ab0, i32 0
  %r1 = insertelement <8 x float>   %r0, float %ab1, i32 1
  %r2 = insertelement <8 x float>   %r1, float %ab2, i32 2
  %r3 = insertelement <8 x float>   %r2, float %ab3, i32 3
  %r4 = insertelement <8 x float>   %r3, float %ab4, i32 4
  %r5 = insertelement <8 x float>   %r4, float %ab5, i32 5
  %r6 = insertelement <8 x float>   %r5, float %ab6, i32 6
  %r7 = insertelement <8 x float>   %r6, float %ab7, i32 7
  ret <8 x float> %r7
}

define <8 x float> @fmul_fdiv_v8f32(<8 x float> %a, <8 x float> %b) {
; SSE-LABEL: @fmul_fdiv_v8f32(
; SSE-NEXT:    [[TMP1:%.*]] = fmul <8 x float> [[A:%.*]], [[B:%.*]]
; SSE-NEXT:    [[TMP2:%.*]] = fdiv <8 x float> [[A]], [[B]]
; SSE-NEXT:    [[R7:%.*]] = shufflevector <8 x float> [[TMP2]], <8 x float> [[TMP1]], <8 x i32> <i32 8, i32 1, i32 2, i32 11, i32 12, i32 5, i32 6, i32 15>
; SSE-NEXT:    ret <8 x float> [[R7]]
;
; SLM-LABEL: @fmul_fdiv_v8f32(
; SLM-NEXT:    [[TMP1:%.*]] = shufflevector <8 x float> [[A:%.*]], <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; SLM-NEXT:    [[TMP2:%.*]] = shufflevector <8 x float> [[B:%.*]], <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; SLM-NEXT:    [[TMP3:%.*]] = fmul <4 x float> [[TMP1]], [[TMP2]]
; SLM-NEXT:    [[TMP4:%.*]] = fdiv <4 x float> [[TMP1]], [[TMP2]]
; SLM-NEXT:    [[TMP5:%.*]] = shufflevector <8 x float> [[A]], <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
; SLM-NEXT:    [[TMP6:%.*]] = shufflevector <8 x float> [[B]], <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
; SLM-NEXT:    [[TMP7:%.*]] = fmul <4 x float> [[TMP5]], [[TMP6]]
; SLM-NEXT:    [[TMP8:%.*]] = shufflevector <4 x float> [[TMP7]], <4 x float> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef>
; SLM-NEXT:    [[TMP9:%.*]] = fdiv <4 x float> [[TMP5]], [[TMP6]]
; SLM-NEXT:    [[TMP10:%.*]] = shufflevector <4 x float> [[TMP9]], <4 x float> undef, <8 x i32> <i32 undef, i32 1, i32 2, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
; SLM-NEXT:    [[R3:%.*]] = shufflevector <4 x float> [[TMP4]], <4 x float> [[TMP3]], <8 x i32> <i32 4, i32 1, i32 2, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
; SLM-NEXT:    [[R4:%.*]] = shufflevector <8 x float> [[R3]], <8 x float> [[TMP8]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 8, i32 undef, i32 undef, i32 undef>
; SLM-NEXT:    [[R6:%.*]] = shufflevector <8 x float> [[R4]], <8 x float> [[TMP10]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 9, i32 10, i32 undef>
; SLM-NEXT:    [[R7:%.*]] = shufflevector <8 x float> [[R6]], <8 x float> [[TMP8]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 11>
; SLM-NEXT:    ret <8 x float> [[R7]]
;
; AVX-LABEL: @fmul_fdiv_v8f32(
; AVX-NEXT:    [[TMP1:%.*]] = fmul <8 x float> [[A:%.*]], [[B:%.*]]
; AVX-NEXT:    [[TMP2:%.*]] = fdiv <8 x float> [[A]], [[B]]
; AVX-NEXT:    [[R7:%.*]] = shufflevector <8 x float> [[TMP2]], <8 x float> [[TMP1]], <8 x i32> <i32 8, i32 1, i32 2, i32 11, i32 12, i32 5, i32 6, i32 15>
; AVX-NEXT:    ret <8 x float> [[R7]]
;
; AVX512-LABEL: @fmul_fdiv_v8f32(
; AVX512-NEXT:    [[TMP1:%.*]] = fmul <8 x float> [[A:%.*]], [[B:%.*]]
; AVX512-NEXT:    [[TMP2:%.*]] = fdiv <8 x float> [[A]], [[B]]
; AVX512-NEXT:    [[R7:%.*]] = shufflevector <8 x float> [[TMP2]], <8 x float> [[TMP1]], <8 x i32> <i32 8, i32 1, i32 2, i32 11, i32 12, i32 5, i32 6, i32 15>
; AVX512-NEXT:    ret <8 x float> [[R7]]
;
  %a0 = extractelement <8 x float> %a, i32 0
  %a1 = extractelement <8 x float> %a, i32 1
  %a2 = extractelement <8 x float> %a, i32 2
  %a3 = extractelement <8 x float> %a, i32 3
  %a4 = extractelement <8 x float> %a, i32 4
  %a5 = extractelement <8 x float> %a, i32 5
  %a6 = extractelement <8 x float> %a, i32 6
  %a7 = extractelement <8 x float> %a, i32 7
  %b0 = extractelement <8 x float> %b, i32 0
  %b1 = extractelement <8 x float> %b, i32 1
  %b2 = extractelement <8 x float> %b, i32 2
  %b3 = extractelement <8 x float> %b, i32 3
  %b4 = extractelement <8 x float> %b, i32 4
  %b5 = extractelement <8 x float> %b, i32 5
  %b6 = extractelement <8 x float> %b, i32 6
  %b7 = extractelement <8 x float> %b, i32 7
  %ab0 = fmul float %a0, %b0
  %ab1 = fdiv float %a1, %b1
  %ab2 = fdiv float %a2, %b2
  %ab3 = fmul float %a3, %b3
  %ab4 = fmul float %a4, %b4
  %ab5 = fdiv float %a5, %b5
  %ab6 = fdiv float %a6, %b6
  %ab7 = fmul float %a7, %b7
  %r0 = insertelement <8 x float> undef, float %ab0, i32 0
  %r1 = insertelement <8 x float>   %r0, float %ab1, i32 1
  %r2 = insertelement <8 x float>   %r1, float %ab2, i32 2
  %r3 = insertelement <8 x float>   %r2, float %ab3, i32 3
  %r4 = insertelement <8 x float>   %r3, float %ab4, i32 4
  %r5 = insertelement <8 x float>   %r4, float %ab5, i32 5
  %r6 = insertelement <8 x float>   %r5, float %ab6, i32 6
  %r7 = insertelement <8 x float>   %r6, float %ab7, i32 7
  ret <8 x float> %r7
}

define <4 x float> @fmul_fdiv_v4f32_const(<4 x float> %a) {
; SSE-LABEL: @fmul_fdiv_v4f32_const(
; SSE-NEXT:    [[TMP1:%.*]] = fmul <4 x float> [[A:%.*]], <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 2.000000e+00>
; SSE-NEXT:    ret <4 x float> [[TMP1]]
;
; SLM-LABEL: @fmul_fdiv_v4f32_const(
; SLM-NEXT:    [[A2:%.*]] = extractelement <4 x float> [[A:%.*]], i32 2
; SLM-NEXT:    [[A3:%.*]] = extractelement <4 x float> [[A]], i32 3
; SLM-NEXT:    [[TMP1:%.*]] = shufflevector <4 x float> [[A]], <4 x float> undef, <2 x i32> <i32 0, i32 1>
; SLM-NEXT:    [[TMP2:%.*]] = fmul <2 x float> [[TMP1]], <float 2.000000e+00, float 1.000000e+00>
; SLM-NEXT:    [[AB3:%.*]] = fmul float [[A3]], 2.000000e+00
; SLM-NEXT:    [[TMP3:%.*]] = extractelement <2 x float> [[TMP2]], i32 0
; SLM-NEXT:    [[R0:%.*]] = insertelement <4 x float> undef, float [[TMP3]], i32 0
; SLM-NEXT:    [[TMP4:%.*]] = extractelement <2 x float> [[TMP2]], i32 1
; SLM-NEXT:    [[R1:%.*]] = insertelement <4 x float> [[R0]], float [[TMP4]], i32 1
; SLM-NEXT:    [[R2:%.*]] = insertelement <4 x float> [[R1]], float [[A2]], i32 2
; SLM-NEXT:    [[R3:%.*]] = insertelement <4 x float> [[R2]], float [[AB3]], i32 3
; SLM-NEXT:    ret <4 x float> [[R3]]
;
; AVX-LABEL: @fmul_fdiv_v4f32_const(
; AVX-NEXT:    [[TMP1:%.*]] = fmul <4 x float> [[A:%.*]], <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 2.000000e+00>
; AVX-NEXT:    ret <4 x float> [[TMP1]]
;
; AVX512-LABEL: @fmul_fdiv_v4f32_const(
; AVX512-NEXT:    [[TMP1:%.*]] = fmul <4 x float> [[A:%.*]], <float 2.000000e+00, float 1.000000e+00, float 1.000000e+00, float 2.000000e+00>
; AVX512-NEXT:    ret <4 x float> [[TMP1]]
;
  %a0 = extractelement <4 x float> %a, i32 0
  %a1 = extractelement <4 x float> %a, i32 1
  %a2 = extractelement <4 x float> %a, i32 2
  %a3 = extractelement <4 x float> %a, i32 3
  %ab0 = fmul float %a0, 2.0
  %ab1 = fmul float %a1, 1.0
  %ab2 = fdiv float %a2, 1.0
  %ab3 = fdiv float %a3, 0.5
  %r0 = insertelement <4 x float> undef, float %ab0, i32 0
  %r1 = insertelement <4 x float>   %r0, float %ab1, i32 1
  %r2 = insertelement <4 x float>   %r1, float %ab2, i32 2
  %r3 = insertelement <4 x float>   %r2, float %ab3, i32 3
  ret <4 x float> %r3
}
