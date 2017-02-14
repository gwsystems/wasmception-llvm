; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -slp-vectorizer -S -mtriple=x86_64-unknown-linux -march=core-avx2 | FileCheck %s
; RUN: opt < %s -slp-vectorizer -S -mtriple=x86_64-unknown-linux -march=core-avx2 -slp-threshold=-1 -slp-vectorize-hor-store | FileCheck %s --check-prefix=THRESH1
; RUN: opt < %s -slp-vectorizer -S -mtriple=x86_64-unknown-linux -march=core-avx2 -slp-threshold=-2 -slp-vectorize-hor-store | FileCheck %s --check-prefix=THRESH2

@a = global float 0.000000e+00, align 4

define float @f(<2 x float> %x) {
; CHECK-LABEL: @f(
; CHECK-NEXT:    [[X0:%.*]] = extractelement <2 x float> [[X:%.*]], i32 0
; CHECK-NEXT:    [[X1:%.*]] = extractelement <2 x float> [[X]], i32 1
; CHECK-NEXT:    [[X0X0:%.*]] = fmul float [[X0]], [[X0]]
; CHECK-NEXT:    [[X1X1:%.*]] = fmul float [[X1]], [[X1]]
; CHECK-NEXT:    [[ADD:%.*]] = fadd float [[X0X0]], [[X1X1]]
; CHECK-NEXT:    ret float [[ADD]]
;
  %x0 = extractelement <2 x float> %x, i32 0
  %x1 = extractelement <2 x float> %x, i32 1
  %x0x0 = fmul float %x0, %x0
  %x1x1 = fmul float %x1, %x1
  %add = fadd float %x0x0, %x1x1
  ret float %add
}

define float @f_used_out_of_tree(<2 x float> %x) {
; THRESH2-LABEL: @f_used_out_of_tree(
; THRESH2-NEXT:    [[X0:%.*]] = extractelement <2 x float> [[X:%.*]], i32 0
; THRESH2-NEXT:    [[X1:%.*]] = extractelement <2 x float> [[X]], i32 1
; THRESH2-NEXT:    [[X0X0:%.*]] = fmul float [[X0]], [[X0]]
; THRESH2-NEXT:    [[X1X1:%.*]] = fmul float [[X1]], [[X1]]
; THRESH2-NEXT:    [[ADD:%.*]] = fadd float [[X0X0]], [[X1X1]]
; THRESH2-NEXT:    store float [[ADD]], float* @a
; THRESH2-NEXT:    ret float [[X0]]
;
  %x0 = extractelement <2 x float> %x, i32 0
  %x1 = extractelement <2 x float> %x, i32 1
  %x0x0 = fmul float %x0, %x0
  %x1x1 = fmul float %x1, %x1
  %add = fadd float %x0x0, %x1x1
  store float %add, float* @a
  ret float %x0
}

define float @f_used_twice_in_tree(<2 x float> %x) {
; THRESH1-LABEL: @f_used_twice_in_tree(
; THRESH1-NEXT:    [[X0:%.*]] = extractelement <2 x float> [[X:%.*]], i32 0
; THRESH1-NEXT:    [[X1:%.*]] = extractelement <2 x float> [[X]], i32 1
; THRESH1-NEXT:    [[X0X0:%.*]] = fmul float [[X0]], [[X1]]
; THRESH1-NEXT:    [[X1X1:%.*]] = fmul float [[X1]], [[X1]]
; THRESH1-NEXT:    [[ADD:%.*]] = fadd float [[X0X0]], [[X1X1]]
; THRESH1-NEXT:    ret float [[ADD]]
  %x0 = extractelement <2 x float> %x, i32 0
  %x1 = extractelement <2 x float> %x, i32 1
  %x0x0 = fmul float %x0, %x1
  %x1x1 = fmul float %x1, %x1
  %add = fadd float %x0x0, %x1x1
  ret float %add
}

