; Test some floating point casting cases
; RUN: opt < %s -instcombine -S | FileCheck %s

define i8 @test1() {
        %x = fptoui float 2.550000e+02 to i8            ; <i8> [#uses=1]
        ret i8 %x
; CHECK: ret i8 -1
}

define i8 @test2() {
        %x = fptosi float -1.000000e+00 to i8           ; <i8> [#uses=1]
        ret i8 %x
; CHECK: ret i8 -1
}

; CHECK: test3
define half @test3(float %a) {
; CHECK: fptrunc
; CHECK: llvm.fabs.f16
  %b = call float @llvm.fabs.f32(float %a)
  %c = fptrunc float %b to half
  ret half %c
}

; CHECK: test4
define half @test4(float %a) {
; CHECK: fptrunc
; CHECK: fsub
  %b = fsub float -0.0, %a
  %c = fptrunc float %b to half
  ret half %c
}

declare float @llvm.fabs.f32(float) nounwind readonly
