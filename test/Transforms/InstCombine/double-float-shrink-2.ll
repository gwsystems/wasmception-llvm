; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S -mtriple "i386-pc-linux" | FileCheck -check-prefix=ALL -check-prefix=DO-SIMPLIFY %s
; RUN: opt < %s -instcombine -S -mtriple "i386-pc-win32" | FileCheck -check-prefix=ALL -check-prefix=DONT-SIMPLIFY %s
; RUN: opt < %s -instcombine -S -mtriple "x86_64-pc-win32" | FileCheck -check-prefix=ALL -check-prefix=C89-SIMPLIFY %s
; RUN: opt < %s -instcombine -S -mtriple "i386-pc-mingw32" | FileCheck -check-prefix=ALL -check-prefix=DO-SIMPLIFY %s
; RUN: opt < %s -instcombine -S -mtriple "x86_64-pc-mingw32" | FileCheck -check-prefix=ALL -check-prefix=DO-SIMPLIFY %s
; RUN: opt < %s -instcombine -S -mtriple "sparc-sun-solaris" | FileCheck -check-prefix=ALL -check-prefix=DO-SIMPLIFY %s

declare double @floor(double)
declare double @ceil(double)
declare double @round(double)
declare double @nearbyint(double)
declare double @trunc(double)
declare double @fabs(double)

declare double @llvm.floor.f64(double)
declare double @llvm.ceil.f64(double)
declare double @llvm.round.f64(double)
declare double @llvm.nearbyint.f64(double)
declare double @llvm.trunc.f64(double)
declare double @llvm.fabs.f64(double)

define float @test_shrink_libcall_floor(float %C) {
; ALL-LABEL: @test_shrink_libcall_floor(
; ALL-NEXT:    [[F:%.*]] = call float @llvm.floor.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> floorf
  %E = call double @floor(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_libcall_ceil(float %C) {
; ALL-LABEL: @test_shrink_libcall_ceil(
; ALL-NEXT:    [[F:%.*]] = call float @llvm.ceil.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> ceilf
  %E = call double @ceil(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_libcall_round(float %C) {
; DO-SIMPLIFY-LABEL: @test_shrink_libcall_round(
; DO-SIMPLIFY-NEXT:    [[F:%.*]] = call float @llvm.round.f32(float [[C:%.*]])
; DO-SIMPLIFY-NEXT:    ret float [[F]]
;
; DONT-SIMPLIFY-LABEL: @test_shrink_libcall_round(
; DONT-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; DONT-SIMPLIFY-NEXT:    [[E:%.*]] = call double @round(double [[D]])
; DONT-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; DONT-SIMPLIFY-NEXT:    ret float [[F]]
;
; C89-SIMPLIFY-LABEL: @test_shrink_libcall_round(
; C89-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; C89-SIMPLIFY-NEXT:    [[E:%.*]] = call double @round(double [[D]])
; C89-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; C89-SIMPLIFY-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> roundf
  %E = call double @round(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_libcall_nearbyint(float %C) {
; DO-SIMPLIFY-LABEL: @test_shrink_libcall_nearbyint(
; DO-SIMPLIFY-NEXT:    [[F:%.*]] = call float @llvm.nearbyint.f32(float [[C:%.*]])
; DO-SIMPLIFY-NEXT:    ret float [[F]]
;
; DONT-SIMPLIFY-LABEL: @test_shrink_libcall_nearbyint(
; DONT-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; DONT-SIMPLIFY-NEXT:    [[E:%.*]] = call double @nearbyint(double [[D]])
; DONT-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; DONT-SIMPLIFY-NEXT:    ret float [[F]]
;
; C89-SIMPLIFY-LABEL: @test_shrink_libcall_nearbyint(
; C89-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; C89-SIMPLIFY-NEXT:    [[E:%.*]] = call double @nearbyint(double [[D]])
; C89-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; C89-SIMPLIFY-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> nearbyintf
  %E = call double @nearbyint(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_libcall_trunc(float %C) {
; DO-SIMPLIFY-LABEL: @test_shrink_libcall_trunc(
; DO-SIMPLIFY-NEXT:    [[F:%.*]] = call float @llvm.trunc.f32(float [[C:%.*]])
; DO-SIMPLIFY-NEXT:    ret float [[F]]
;
; DONT-SIMPLIFY-LABEL: @test_shrink_libcall_trunc(
; DONT-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; DONT-SIMPLIFY-NEXT:    [[E:%.*]] = call double @trunc(double [[D]])
; DONT-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; DONT-SIMPLIFY-NEXT:    ret float [[F]]
;
; C89-SIMPLIFY-LABEL: @test_shrink_libcall_trunc(
; C89-SIMPLIFY-NEXT:    [[D:%.*]] = fpext float [[C:%.*]] to double
; C89-SIMPLIFY-NEXT:    [[E:%.*]] = call double @trunc(double [[D]])
; C89-SIMPLIFY-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; C89-SIMPLIFY-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> truncf
  %E = call double @trunc(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

; This is replaced with the intrinsic, which does the right thing on
; all platforms.
define float @test_shrink_libcall_fabs(float %C) {
; ALL-LABEL: @test_shrink_libcall_fabs(
; ALL-NEXT:    [[F:%.*]] = call float @llvm.fabs.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> fabsf
  %E = call double @fabs(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

; Make sure fast math flags are preserved
define float @test_shrink_libcall_fabs_fast(float %C) {
; ALL-LABEL: @test_shrink_libcall_fabs_fast(
; ALL-NEXT:    [[F:%.*]] = call fast float @llvm.fabs.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext float %C to double
  ; --> fabsf
  %E = call fast double @fabs(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_floor(float %C) {
; ALL-LABEL: @test_shrink_intrin_floor(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.floor.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  ; --> floorf
  %E = call double @llvm.floor.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_ceil(float %C) {
; ALL-LABEL: @test_shrink_intrin_ceil(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.ceil.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  ; --> ceilf
  %E = call double @llvm.ceil.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_round(float %C) {
; ALL-LABEL: @test_shrink_intrin_round(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.round.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  ; --> roundf
  %E = call double @llvm.round.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_nearbyint(float %C) {
; ALL-LABEL: @test_shrink_intrin_nearbyint(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.nearbyint.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  ; --> nearbyintf
  %E = call double @llvm.nearbyint.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_trunc(float %C) {
; ALL-LABEL: @test_shrink_intrin_trunc(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.trunc.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  %E = call double @llvm.trunc.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_fabs(float %C) {
; ALL-LABEL: @test_shrink_intrin_fabs(
; ALL-NEXT:    [[E:%.*]] = call float @llvm.fabs.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  %E = call double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

; Make sure fast math flags are preserved
define float @test_shrink_intrin_fabs_fast(float %C) {
; ALL-LABEL: @test_shrink_intrin_fabs_fast(
; ALL-NEXT:    [[E:%.*]] = call fast float @llvm.fabs.f32(float [[C:%.*]])
; ALL-NEXT:    ret float [[E]]
;
  %D = fpext float %C to double
  %E = call fast double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_floor(double %D) {
; ALL-LABEL: @test_no_shrink_intrin_floor(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.floor.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.floor.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_ceil(double %D) {
; ALL-LABEL: @test_no_shrink_intrin_ceil(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.ceil.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.ceil.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_round(double %D) {
; ALL-LABEL: @test_no_shrink_intrin_round(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.round.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.round.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_nearbyint(double %D) {
; ALL-LABEL: @test_no_shrink_intrin_nearbyint(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.nearbyint.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.nearbyint.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_trunc(double %D) {
; ALL-LABEL: @test_no_shrink_intrin_trunc(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.trunc.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.trunc.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_fabs_double_src(double %D) {
; ALL-LABEL: @test_shrink_intrin_fabs_double_src(
; ALL-NEXT:    [[TMP1:%.*]] = fptrunc double [[D:%.*]] to float
; ALL-NEXT:    [[F:%.*]] = call float @llvm.fabs.f32(float [[TMP1]])
; ALL-NEXT:    ret float [[F]]
;
  %E = call double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

; Make sure fast math flags are preserved
define float @test_shrink_intrin_fabs_fast_double_src(double %D) {
; ALL-LABEL: @test_shrink_intrin_fabs_fast_double_src(
; ALL-NEXT:    [[TMP1:%.*]] = fptrunc double [[D:%.*]] to float
; ALL-NEXT:    [[F:%.*]] = call fast float @llvm.fabs.f32(float [[TMP1]])
; ALL-NEXT:    ret float [[F]]
;
  %E = call fast double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_floor() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_floor(
; ALL-NEXT:    ret float 2.000000e+00
;
  %E = call double @llvm.floor.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_ceil() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_ceil(
; ALL-NEXT:    ret float 3.000000e+00
;
  %E = call double @llvm.ceil.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_round() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_round(
; ALL-NEXT:    ret float 2.000000e+00
;
  %E = call double @llvm.round.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_nearbyint() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_nearbyint(
; ALL-NEXT:    ret float 2.000000e+00
;
  %E = call double @llvm.nearbyint.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_trunc() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_trunc(
; ALL-NEXT:    ret float 2.000000e+00
;
  %E = call double @llvm.trunc.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_float_convertible_constant_intrin_fabs() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_fabs(
; ALL-NEXT:    ret float 0x4000CCCCC0000000
;
  %E = call double @llvm.fabs.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

; Make sure fast math flags are preserved
define float @test_shrink_float_convertible_constant_intrin_fabs_fast() {
; ALL-LABEL: @test_shrink_float_convertible_constant_intrin_fabs_fast(
; ALL-NEXT:    ret float 0x4000CCCCC0000000
;
  %E = call fast double @llvm.fabs.f64(double 2.1)
  %F = fptrunc double %E to float
  ret float %F
}

define half @test_no_shrink_mismatched_type_intrin_floor(double %D) {
; ALL-LABEL: @test_no_shrink_mismatched_type_intrin_floor(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.floor.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to half
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.floor.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define half @test_no_shrink_mismatched_type_intrin_ceil(double %D) {
; ALL-LABEL: @test_no_shrink_mismatched_type_intrin_ceil(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.ceil.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to half
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.ceil.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define half @test_no_shrink_mismatched_type_intrin_round(double %D) {
; ALL-LABEL: @test_no_shrink_mismatched_type_intrin_round(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.round.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to half
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.round.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define half @test_no_shrink_mismatched_type_intrin_nearbyint(double %D) {
; ALL-LABEL: @test_no_shrink_mismatched_type_intrin_nearbyint(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.nearbyint.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to half
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.nearbyint.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define half @test_no_shrink_mismatched_type_intrin_trunc(double %D) {
; ALL-LABEL: @test_no_shrink_mismatched_type_intrin_trunc(
; ALL-NEXT:    [[E:%.*]] = call double @llvm.trunc.f64(double [[D:%.*]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to half
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.trunc.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define half @test_shrink_mismatched_type_intrin_fabs_double_src(double %D) {
; ALL-LABEL: @test_shrink_mismatched_type_intrin_fabs_double_src(
; ALL-NEXT:    [[TMP1:%.*]] = fptrunc double [[D:%.*]] to half
; ALL-NEXT:    [[F:%.*]] = call half @llvm.fabs.f16(half [[TMP1]])
; ALL-NEXT:    ret half [[F]]
;
  %E = call double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

; Make sure fast math flags are preserved
define half @test_mismatched_type_intrin_fabs_fast_double_src(double %D) {
; ALL-LABEL: @test_mismatched_type_intrin_fabs_fast_double_src(
; ALL-NEXT:    [[TMP1:%.*]] = fptrunc double [[D:%.*]] to half
; ALL-NEXT:    [[F:%.*]] = call fast half @llvm.fabs.f16(half [[TMP1]])
; ALL-NEXT:    ret half [[F]]
;
  %E = call fast double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to half
  ret half %F
}

define float @test_shrink_intrin_floor_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_floor_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.floor.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.floor.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_ceil_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_ceil_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.ceil.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.ceil.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_round_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_round_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.round.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.round.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_nearbyint_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_nearbyint_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.nearbyint.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.nearbyint.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_trunc_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_trunc_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.trunc.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.trunc.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_shrink_intrin_fabs_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_fabs_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call half @llvm.fabs.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

; Make sure fast math flags are preserved
define float @test_shrink_intrin_fabs_fast_fp16_src(half %C) {
; ALL-LABEL: @test_shrink_intrin_fabs_fast_fp16_src(
; ALL-NEXT:    [[E:%.*]] = call fast half @llvm.fabs.f16(half [[C:%.*]])
; ALL-NEXT:    [[F:%.*]] = fpext half [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  %E = call fast double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_floor_multi_use_fpext(half %C) {
; ALL-LABEL: @test_no_shrink_intrin_floor_multi_use_fpext(
; ALL-NEXT:    [[D:%.*]] = fpext half [[C:%.*]] to double
; ALL-NEXT:    store volatile double [[D]], double* undef, align 8
; ALL-NEXT:    [[E:%.*]] = call double @llvm.floor.f64(double [[D]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  store volatile double %D, double* undef
  %E = call double @llvm.floor.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}

define float @test_no_shrink_intrin_fabs_multi_use_fpext(half %C) {
; ALL-LABEL: @test_no_shrink_intrin_fabs_multi_use_fpext(
; ALL-NEXT:    [[D:%.*]] = fpext half [[C:%.*]] to double
; ALL-NEXT:    store volatile double [[D]], double* undef, align 8
; ALL-NEXT:    [[E:%.*]] = call double @llvm.fabs.f64(double [[D]])
; ALL-NEXT:    [[F:%.*]] = fptrunc double [[E]] to float
; ALL-NEXT:    ret float [[F]]
;
  %D = fpext half %C to double
  store volatile double %D, double* undef
  %E = call double @llvm.fabs.f64(double %D)
  %F = fptrunc double %E to float
  ret float %F
}
