; RUN: opt -S -instcombine < %s | FileCheck %s

declare float @llvm.fma.f32(float, float, float) #1
declare float @llvm.fmuladd.f32(float, float, float) #1
declare float @llvm.fabs.f32(float) #1

@external = external global i32

; CHECK-LABEL: @fma_fneg_x_fneg_y(
; CHECK: %fma = call float @llvm.fma.f32(float %x, float %y, float %z)
define float @fma_fneg_x_fneg_y(float %x, float %y, float %z) {
  %x.fneg = fsub float -0.0, %x
  %y.fneg = fsub float -0.0, %y
  %fma = call float @llvm.fma.f32(float %x.fneg, float %y.fneg, float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fneg_x_fneg_y_fast(
; CHECK: %fma = call fast float @llvm.fma.f32(float %x, float %y, float %z)
define float @fma_fneg_x_fneg_y_fast(float %x, float %y, float %z) {
  %x.fneg = fsub float -0.0, %x
  %y.fneg = fsub float -0.0, %y
  %fma = call fast float @llvm.fma.f32(float %x.fneg, float %y.fneg, float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fneg_const_fneg_y(
; CHECK: %fma = call float @llvm.fma.f32(float bitcast (i32 ptrtoint (i32* @external to i32) to float), float %y, float %z)
define float @fma_fneg_const_fneg_y(float %y, float %z) {
  %y.fneg = fsub float -0.0, %y
  %fma = call float @llvm.fma.f32(float fsub (float -0.0, float bitcast (i32 ptrtoint (i32* @external to i32) to float)), float %y.fneg, float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fneg_x_fneg_const(
; CHECK: %fma = call float @llvm.fma.f32(float %x, float bitcast (i32 ptrtoint (i32* @external to i32) to float), float %z)
define float @fma_fneg_x_fneg_const(float %x, float %z) {
  %x.fneg = fsub float -0.0, %x
  %fma = call float @llvm.fma.f32(float %x.fneg, float fsub (float -0.0, float bitcast (i32 ptrtoint (i32* @external to i32) to float)), float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fabs_x_fabs_y(
; CHECK: %x.fabs = call float @llvm.fabs.f32(float %x)
; CHECK: %y.fabs = call float @llvm.fabs.f32(float %y)
; CHECK: %fma = call float @llvm.fma.f32(float %x.fabs, float %y.fabs, float %z)
define float @fma_fabs_x_fabs_y(float %x, float %y, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %y.fabs = call float @llvm.fabs.f32(float %y)
  %fma = call float @llvm.fma.f32(float %x.fabs, float %y.fabs, float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fabs_x_fabs_x(
; CHECK: %fma = call float @llvm.fma.f32(float %x, float %x, float %z)
define float @fma_fabs_x_fabs_x(float %x, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %fma = call float @llvm.fma.f32(float %x.fabs, float %x.fabs, float %z)
  ret float %fma
}

; CHECK-LABEL: @fma_fabs_x_fabs_x_fast(
; CHECK: %fma = call fast float @llvm.fma.f32(float %x, float %x, float %z)
define float @fma_fabs_x_fabs_x_fast(float %x, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %fma = call fast float @llvm.fma.f32(float %x.fabs, float %x.fabs, float %z)
  ret float %fma
}

; CHECK-LABEL: @fmuladd_fneg_x_fneg_y(
; CHECK: %fmuladd = call float @llvm.fmuladd.f32(float %x, float %y, float %z)
define float @fmuladd_fneg_x_fneg_y(float %x, float %y, float %z) {
  %x.fneg = fsub float -0.0, %x
  %y.fneg = fsub float -0.0, %y
  %fmuladd = call float @llvm.fmuladd.f32(float %x.fneg, float %y.fneg, float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fneg_x_fneg_y_fast(
; CHECK: %fmuladd = call fast float @llvm.fmuladd.f32(float %x, float %y, float %z)
define float @fmuladd_fneg_x_fneg_y_fast(float %x, float %y, float %z) {
  %x.fneg = fsub float -0.0, %x
  %y.fneg = fsub float -0.0, %y
  %fmuladd = call fast float @llvm.fmuladd.f32(float %x.fneg, float %y.fneg, float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fneg_const_fneg_y(
; CHECK: %fmuladd = call float @llvm.fmuladd.f32(float bitcast (i32 ptrtoint (i32* @external to i32) to float), float %y, float %z)
define float @fmuladd_fneg_const_fneg_y(float %y, float %z) {
  %y.fneg = fsub float -0.0, %y
  %fmuladd = call float @llvm.fmuladd.f32(float fsub (float -0.0, float bitcast (i32 ptrtoint (i32* @external to i32) to float)), float %y.fneg, float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fneg_x_fneg_const(
; CHECK: %fmuladd = call float @llvm.fmuladd.f32(float %x, float bitcast (i32 ptrtoint (i32* @external to i32) to float), float %z)
define float @fmuladd_fneg_x_fneg_const(float %x, float %z) {
  %x.fneg = fsub float -0.0, %x
  %fmuladd = call float @llvm.fmuladd.f32(float %x.fneg, float fsub (float -0.0, float bitcast (i32 ptrtoint (i32* @external to i32) to float)), float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fabs_x_fabs_y(
; CHECK: %x.fabs = call float @llvm.fabs.f32(float %x)
; CHECK: %y.fabs = call float @llvm.fabs.f32(float %y)
; CHECK: %fmuladd = call float @llvm.fmuladd.f32(float %x.fabs, float %y.fabs, float %z)
define float @fmuladd_fabs_x_fabs_y(float %x, float %y, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %y.fabs = call float @llvm.fabs.f32(float %y)
  %fmuladd = call float @llvm.fmuladd.f32(float %x.fabs, float %y.fabs, float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fabs_x_fabs_x(
; CHECK: %fmuladd = call float @llvm.fmuladd.f32(float %x, float %x, float %z)
define float @fmuladd_fabs_x_fabs_x(float %x, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %fmuladd = call float @llvm.fmuladd.f32(float %x.fabs, float %x.fabs, float %z)
  ret float %fmuladd
}

; CHECK-LABEL: @fmuladd_fabs_x_fabs_x_fast(
; CHECK: %fmuladd = call fast float @llvm.fmuladd.f32(float %x, float %x, float %z)
define float @fmuladd_fabs_x_fabs_x_fast(float %x, float %z) {
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %fmuladd = call fast float @llvm.fmuladd.f32(float %x.fabs, float %x.fabs, float %z)
  ret float %fmuladd
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
