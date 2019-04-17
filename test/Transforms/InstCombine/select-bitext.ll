; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; Widen a select of constants to eliminate an extend.

define i16 @sel_sext_constants(i1 %cmp) {
; CHECK-LABEL: @sel_sext_constants(
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i16 -1, i16 42
; CHECK-NEXT:    ret i16 [[EXT]]
;
  %sel = select i1 %cmp, i8 255, i8 42
  %ext = sext i8 %sel to i16
  ret i16 %ext
}

define i16 @sel_zext_constants(i1 %cmp) {
; CHECK-LABEL: @sel_zext_constants(
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i16 255, i16 42
; CHECK-NEXT:    ret i16 [[EXT]]
;
  %sel = select i1 %cmp, i8 255, i8 42
  %ext = zext i8 %sel to i16
  ret i16 %ext
}

define double @sel_fpext_constants(i1 %cmp) {
; CHECK-LABEL: @sel_fpext_constants(
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], double -2.550000e+02, double 4.200000e+01
; CHECK-NEXT:    ret double [[EXT]]
;
  %sel = select i1 %cmp, float -255.0, float 42.0
  %ext = fpext float %sel to double
  ret double %ext
}

; FIXME: We should not grow the size of the select in the next 4 cases.

define i64 @sel_sext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @sel_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %sel = select i1 %cmp, i32 %a, i32 42
  %ext = sext i32 %sel to i64
  ret i64 %ext
}

define <4 x i64> @sel_sext_vec(<4 x i32> %a, <4 x i1> %cmp) {
; CHECK-LABEL: @sel_sext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = sext <4 x i32> [[A:%.*]] to <4 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <4 x i1> [[CMP:%.*]], <4 x i64> [[TMP1]], <4 x i64> <i64 42, i64 42, i64 42, i64 42>
; CHECK-NEXT:    ret <4 x i64> [[EXT]]
;
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> <i32 42, i32 42, i32 42, i32 42>
  %ext = sext <4 x i32> %sel to <4 x i64>
  ret <4 x i64> %ext
}

define i64 @sel_zext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @sel_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %sel = select i1 %cmp, i32 %a, i32 42
  %ext = zext i32 %sel to i64
  ret i64 %ext
}

define <4 x i64> @sel_zext_vec(<4 x i32> %a, <4 x i1> %cmp) {
; CHECK-LABEL: @sel_zext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <4 x i32> [[A:%.*]] to <4 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <4 x i1> [[CMP:%.*]], <4 x i64> [[TMP1]], <4 x i64> <i64 42, i64 42, i64 42, i64 42>
; CHECK-NEXT:    ret <4 x i64> [[EXT]]
;
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> <i32 42, i32 42, i32 42, i32 42>
  %ext = zext <4 x i32> %sel to <4 x i64>
  ret <4 x i64> %ext
}

; FIXME: The next 18 tests cycle through trunc+select and {larger,smaller,equal} {sext,zext,fpext} {scalar,vector}.
; The only cases where we eliminate an instruction are equal zext with scalar/vector, so that's probably the only
; way to justify widening the select.

define i64 @trunc_sel_larger_sext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_larger_sext(
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc i32 [[A:%.*]] to i16
; CHECK-NEXT:    [[TMP1:%.*]] = sext i16 [[TRUNC]] to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %trunc = trunc i32 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = sext i16 %sel to i64
  ret i64 %ext
}

define <2 x i64> @trunc_sel_larger_sext_vec(<2 x i32> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_larger_sext_vec(
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <2 x i32> [[A:%.*]] to <2 x i16>
; CHECK-NEXT:    [[TMP1:%.*]] = sext <2 x i16> [[TRUNC]] to <2 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i64> [[TMP1]], <2 x i64> <i64 42, i64 43>
; CHECK-NEXT:    ret <2 x i64> [[EXT]]
;
  %trunc = trunc <2 x i32> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = sext <2 x i16> %sel to <2 x i64>
  ret <2 x i64> %ext
}

define i32 @trunc_sel_smaller_sext(i64 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_sext(
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc i64 [[A:%.*]] to i16
; CHECK-NEXT:    [[TMP1:%.*]] = sext i16 [[TRUNC]] to i32
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i32 [[TMP1]], i32 42
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %trunc = trunc i64 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = sext i16 %sel to i32
  ret i32 %ext
}

define <2 x i32> @trunc_sel_smaller_sext_vec(<2 x i64> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_sext_vec(
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <2 x i64> [[A:%.*]] to <2 x i16>
; CHECK-NEXT:    [[TMP1:%.*]] = sext <2 x i16> [[TRUNC]] to <2 x i32>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i32> [[TMP1]], <2 x i32> <i32 42, i32 43>
; CHECK-NEXT:    ret <2 x i32> [[EXT]]
;
  %trunc = trunc <2 x i64> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = sext <2 x i16> %sel to <2 x i32>
  ret <2 x i32> %ext
}

define i32 @trunc_sel_equal_sext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_equal_sext(
; CHECK-NEXT:    [[TMP1:%.*]] = shl i32 [[A:%.*]], 16
; CHECK-NEXT:    [[TMP2:%.*]] = ashr exact i32 [[TMP1]], 16
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i32 [[TMP2]], i32 42
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %trunc = trunc i32 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = sext i16 %sel to i32
  ret i32 %ext
}

define <2 x i32> @trunc_sel_equal_sext_vec(<2 x i32> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_equal_sext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = shl <2 x i32> [[A:%.*]], <i32 16, i32 16>
; CHECK-NEXT:    [[TMP2:%.*]] = ashr exact <2 x i32> [[TMP1]], <i32 16, i32 16>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i32> [[TMP2]], <2 x i32> <i32 42, i32 43>
; CHECK-NEXT:    ret <2 x i32> [[EXT]]
;
  %trunc = trunc <2 x i32> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = sext <2 x i16> %sel to <2 x i32>
  ret <2 x i32> %ext
}

define i64 @trunc_sel_larger_zext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_larger_zext(
; CHECK-NEXT:    [[TRUNC_MASK:%.*]] = and i32 [[A:%.*]], 65535
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[TRUNC_MASK]] to i64
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i64 [[TMP1]], i64 42
; CHECK-NEXT:    ret i64 [[EXT]]
;
  %trunc = trunc i32 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = zext i16 %sel to i64
  ret i64 %ext
}

define <2 x i64> @trunc_sel_larger_zext_vec(<2 x i32> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_larger_zext_vec(
; CHECK-NEXT:    [[TRUNC_MASK:%.*]] = and <2 x i32> [[A:%.*]], <i32 65535, i32 65535>
; CHECK-NEXT:    [[TMP1:%.*]] = zext <2 x i32> [[TRUNC_MASK]] to <2 x i64>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i64> [[TMP1]], <2 x i64> <i64 42, i64 43>
; CHECK-NEXT:    ret <2 x i64> [[EXT]]
;
  %trunc = trunc <2 x i32> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = zext <2 x i16> %sel to <2 x i64>
  ret <2 x i64> %ext
}

define i32 @trunc_sel_smaller_zext(i64 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 [[A:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 65535
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i32 [[TMP2]], i32 42
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %trunc = trunc i64 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = zext i16 %sel to i32
  ret i32 %ext
}

define <2 x i32> @trunc_sel_smaller_zext_vec(<2 x i64> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_zext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <2 x i64> [[A:%.*]] to <2 x i32>
; CHECK-NEXT:    [[TMP2:%.*]] = and <2 x i32> [[TMP1]], <i32 65535, i32 65535>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i32> [[TMP2]], <2 x i32> <i32 42, i32 43>
; CHECK-NEXT:    ret <2 x i32> [[EXT]]
;
  %trunc = trunc <2 x i64> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = zext <2 x i16> %sel to <2 x i32>
  ret <2 x i32> %ext
}

define i32 @trunc_sel_equal_zext(i32 %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_equal_zext(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[A:%.*]], 65535
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], i32 [[TMP1]], i32 42
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %trunc = trunc i32 %a to i16
  %sel = select i1 %cmp, i16 %trunc, i16 42
  %ext = zext i16 %sel to i32
  ret i32 %ext
}

define <2 x i32> @trunc_sel_equal_zext_vec(<2 x i32> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_equal_zext_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = and <2 x i32> [[A:%.*]], <i32 65535, i32 65535>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x i32> [[TMP1]], <2 x i32> <i32 42, i32 43>
; CHECK-NEXT:    ret <2 x i32> [[EXT]]
;
  %trunc = trunc <2 x i32> %a to <2 x i16>
  %sel = select <2 x i1> %cmp, <2 x i16> %trunc, <2 x i16> <i16 42, i16 43>
  %ext = zext <2 x i16> %sel to <2 x i32>
  ret <2 x i32> %ext
}

define double @trunc_sel_larger_fpext(float %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_larger_fpext(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc float [[A:%.*]] to half
; CHECK-NEXT:    [[TMP1:%.*]] = fpext half [[TRUNC]] to double
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], double [[TMP1]], double 4.200000e+01
; CHECK-NEXT:    ret double [[EXT]]
;
  %trunc = fptrunc float %a to half
  %sel = select i1 %cmp, half %trunc, half 42.0
  %ext = fpext half %sel to double
  ret double %ext
}

define <2 x double> @trunc_sel_larger_fpext_vec(<2 x float> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_larger_fpext_vec(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc <2 x float> [[A:%.*]] to <2 x half>
; CHECK-NEXT:    [[TMP1:%.*]] = fpext <2 x half> [[TRUNC]] to <2 x double>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x double> [[TMP1]], <2 x double> <double 4.200000e+01, double 4.300000e+01>
; CHECK-NEXT:    ret <2 x double> [[EXT]]
;
  %trunc = fptrunc <2 x float> %a to <2 x half>
  %sel = select <2 x i1> %cmp, <2 x half> %trunc, <2 x half> <half 42.0, half 43.0>
  %ext = fpext <2 x half> %sel to <2 x double>
  ret <2 x double> %ext
}

define float @trunc_sel_smaller_fpext(double %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_fpext(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc double [[A:%.*]] to half
; CHECK-NEXT:    [[TMP1:%.*]] = fpext half [[TRUNC]] to float
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], float [[TMP1]], float 4.200000e+01
; CHECK-NEXT:    ret float [[EXT]]
;
  %trunc = fptrunc double %a to half
  %sel = select i1 %cmp, half %trunc, half 42.0
  %ext = fpext half %sel to float
  ret float %ext
}

define <2 x float> @trunc_sel_smaller_fpext_vec(<2 x double> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_smaller_fpext_vec(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc <2 x double> [[A:%.*]] to <2 x half>
; CHECK-NEXT:    [[TMP1:%.*]] = fpext <2 x half> [[TRUNC]] to <2 x float>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x float> [[TMP1]], <2 x float> <float 4.200000e+01, float 4.300000e+01>
; CHECK-NEXT:    ret <2 x float> [[EXT]]
;
  %trunc = fptrunc <2 x double> %a to <2 x half>
  %sel = select <2 x i1> %cmp, <2 x half> %trunc, <2 x half> <half 42.0, half 43.0>
  %ext = fpext <2 x half> %sel to <2 x float>
  ret <2 x float> %ext
}

define float @trunc_sel_equal_fpext(float %a, i1 %cmp) {
; CHECK-LABEL: @trunc_sel_equal_fpext(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc float [[A:%.*]] to half
; CHECK-NEXT:    [[TMP1:%.*]] = fpext half [[TRUNC]] to float
; CHECK-NEXT:    [[EXT:%.*]] = select i1 [[CMP:%.*]], float [[TMP1]], float 4.200000e+01
; CHECK-NEXT:    ret float [[EXT]]
;
  %trunc = fptrunc float %a to half
  %sel = select i1 %cmp, half %trunc, half 42.0
  %ext = fpext half %sel to float
  ret float %ext
}

define <2 x float> @trunc_sel_equal_fpext_vec(<2 x float> %a, <2 x i1> %cmp) {
; CHECK-LABEL: @trunc_sel_equal_fpext_vec(
; CHECK-NEXT:    [[TRUNC:%.*]] = fptrunc <2 x float> [[A:%.*]] to <2 x half>
; CHECK-NEXT:    [[TMP1:%.*]] = fpext <2 x half> [[TRUNC]] to <2 x float>
; CHECK-NEXT:    [[EXT:%.*]] = select <2 x i1> [[CMP:%.*]], <2 x float> [[TMP1]], <2 x float> <float 4.200000e+01, float 4.300000e+01>
; CHECK-NEXT:    ret <2 x float> [[EXT]]
;
  %trunc = fptrunc <2 x float> %a to <2 x half>
  %sel = select <2 x i1> %cmp, <2 x half> %trunc, <2 x half> <half 42.0, half 43.0>
  %ext = fpext <2 x half> %sel to <2 x float>
  ret <2 x float> %ext
}

define i32 @test_sext1(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext1(
; CHECK-NEXT:    [[NARROW:%.*]] = and i1 [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 0
  ret i32 %r
}

define i32 @test_sext2(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext2(
; CHECK-NEXT:    [[NARROW:%.*]] = or i1 [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 -1, i32 %ccax
  ret i32 %r
}

define i32 @test_sext3(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext3(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 [[CCB:%.*]], true
; CHECK-NEXT:    [[NARROW:%.*]] = and i1 [[NOT_CCB]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 0, i32 %ccax
  ret i32 %r
}

define i32 @test_sext4(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_sext4(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 [[CCB:%.*]], true
; CHECK-NEXT:    [[NARROW:%.*]] = or i1 [[NOT_CCB]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = sext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 -1
  ret i32 %r
}

define i32 @test_zext1(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext1(
; CHECK-NEXT:    [[NARROW:%.*]] = and i1 [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 0
  ret i32 %r
}

define i32 @test_zext2(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext2(
; CHECK-NEXT:    [[NARROW:%.*]] = or i1 [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 1, i32 %ccax
  ret i32 %r
}

define i32 @test_zext3(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext3(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 [[CCB:%.*]], true
; CHECK-NEXT:    [[NARROW:%.*]] = and i1 [[NOT_CCB]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 0, i32 %ccax
  ret i32 %r
}

define i32 @test_zext4(i1 %cca, i1 %ccb) {
; CHECK-LABEL: @test_zext4(
; CHECK-NEXT:    [[NOT_CCB:%.*]] = xor i1 [[CCB:%.*]], true
; CHECK-NEXT:    [[NARROW:%.*]] = or i1 [[NOT_CCB]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext i1 [[NARROW]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %ccax = zext i1 %cca to i32
  %r = select i1 %ccb, i32 %ccax, i32 1
  ret i32 %r
}

define i32 @test_negative_sext(i1 %a, i1 %cc) {
; CHECK-LABEL: @test_negative_sext(
; CHECK-NEXT:    [[A_EXT:%.*]] = sext i1 [[A:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 [[CC:%.*]], i32 [[A_EXT]], i32 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = sext i1 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 1
  ret i32 %r
}

define i32 @test_negative_zext(i1 %a, i1 %cc) {
; CHECK-LABEL: @test_negative_zext(
; CHECK-NEXT:    [[A_EXT:%.*]] = zext i1 [[A:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 [[CC:%.*]], i32 [[A_EXT]], i32 -1
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = zext i1 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 -1
  ret i32 %r
}

define i32 @test_bits_sext(i8 %a, i1 %cc) {
; CHECK-LABEL: @test_bits_sext(
; CHECK-NEXT:    [[A_EXT:%.*]] = sext i8 [[A:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 [[CC:%.*]], i32 [[A_EXT]], i32 -128
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = sext i8 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 -128
  ret i32 %r
}

define i32 @test_bits_zext(i8 %a, i1 %cc) {
; CHECK-LABEL: @test_bits_zext(
; CHECK-NEXT:    [[A_EXT:%.*]] = zext i8 [[A:%.*]] to i32
; CHECK-NEXT:    [[R:%.*]] = select i1 [[CC:%.*]], i32 [[A_EXT]], i32 255
; CHECK-NEXT:    ret i32 [[R]]
;
  %a.ext = zext i8 %a to i32
  %r = select i1 %cc, i32 %a.ext, i32 255
  ret i32 %r
}

define i32 @test_op_op(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @test_op_op(
; CHECK-NEXT:    [[CCA:%.*]] = icmp sgt i32 [[A:%.*]], 0
; CHECK-NEXT:    [[CCB:%.*]] = icmp sgt i32 [[B:%.*]], 0
; CHECK-NEXT:    [[CCC:%.*]] = icmp sgt i32 [[C:%.*]], 0
; CHECK-NEXT:    [[R_V:%.*]] = select i1 [[CCC]], i1 [[CCA]], i1 [[CCB]]
; CHECK-NEXT:    [[R:%.*]] = sext i1 [[R_V]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %cca = icmp sgt i32 %a, 0
  %ccax = sext i1 %cca to i32
  %ccb = icmp sgt i32 %b, 0
  %ccbx = sext i1 %ccb to i32
  %ccc = icmp sgt i32 %c, 0
  %r = select i1 %ccc, i32 %ccax, i32 %ccbx
  ret i32 %r
}

define <2 x i32> @test_vectors_sext(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_sext(
; CHECK-NEXT:    [[NARROW:%.*]] = and <2 x i1> [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_sext_nonsplat(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_sext_nonsplat(
; CHECK-NEXT:    [[NARROW:%.*]] = select <2 x i1> [[CCB:%.*]], <2 x i1> [[CCA:%.*]], <2 x i1> <i1 false, i1 true>
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 -1>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_zext(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_zext(
; CHECK-NEXT:    [[NARROW:%.*]] = and <2 x i1> [[CCB:%.*]], [[CCA:%.*]]
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @test_vectors_zext_nonsplat(<2 x i1> %cca, <2 x i1> %ccb) {
; CHECK-LABEL: @test_vectors_zext_nonsplat(
; CHECK-NEXT:    [[NARROW:%.*]] = select <2 x i1> [[CCB:%.*]], <2 x i1> [[CCA:%.*]], <2 x i1> <i1 true, i1 false>
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select <2 x i1> %ccb, <2 x i32> %ccax, <2 x i32> <i32 1, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @scalar_select_of_vectors_sext(<2 x i1> %cca, i1 %ccb) {
; CHECK-LABEL: @scalar_select_of_vectors_sext(
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 [[CCB:%.*]], <2 x i1> [[CCA:%.*]], <2 x i1> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = sext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = sext <2 x i1> %cca to <2 x i32>
  %r = select i1 %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define <2 x i32> @scalar_select_of_vectors_zext(<2 x i1> %cca, i1 %ccb) {
; CHECK-LABEL: @scalar_select_of_vectors_zext(
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 [[CCB:%.*]], <2 x i1> [[CCA:%.*]], <2 x i1> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = zext <2 x i1> [[NARROW]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %ccax = zext <2 x i1> %cca to <2 x i32>
  %r = select i1 %ccb, <2 x i32> %ccax, <2 x i32> <i32 0, i32 0>
  ret <2 x i32> %r
}

define i32 @sext_true_val_must_be_all_ones(i1 %x) {
; CHECK-LABEL: @sext_true_val_must_be_all_ones(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[X:%.*]], i32 -1, i32 42, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = sext i1 %x to i32
  %sel = select i1 %x, i32 %ext, i32 42, !prof !0
  ret i32 %sel
}

define <2 x i32> @sext_true_val_must_be_all_ones_vec(<2 x i1> %x) {
; CHECK-LABEL: @sext_true_val_must_be_all_ones_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> [[X:%.*]], <2 x i32> <i32 -1, i32 -1>, <2 x i32> <i32 42, i32 12>, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = sext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> %ext, <2 x i32> <i32 42, i32 12>, !prof !0
  ret <2 x i32> %sel
}

define i32 @zext_true_val_must_be_one(i1 %x) {
; CHECK-LABEL: @zext_true_val_must_be_one(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[X:%.*]], i32 1, i32 42, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = zext i1 %x to i32
  %sel = select i1 %x, i32 %ext, i32 42, !prof !0
  ret i32 %sel
}

define <2 x i32> @zext_true_val_must_be_one_vec(<2 x i1> %x) {
; CHECK-LABEL: @zext_true_val_must_be_one_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> [[X:%.*]], <2 x i32> <i32 1, i32 1>, <2 x i32> <i32 42, i32 12>, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = zext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> %ext, <2 x i32> <i32 42, i32 12>, !prof !0
  ret <2 x i32> %sel
}

define i32 @sext_false_val_must_be_zero(i1 %x) {
; CHECK-LABEL: @sext_false_val_must_be_zero(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[X:%.*]], i32 42, i32 0, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = sext i1 %x to i32
  %sel = select i1 %x, i32 42, i32 %ext, !prof !0
  ret i32 %sel
}

define <2 x i32> @sext_false_val_must_be_zero_vec(<2 x i1> %x) {
; CHECK-LABEL: @sext_false_val_must_be_zero_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> [[X:%.*]], <2 x i32> <i32 42, i32 12>, <2 x i32> zeroinitializer, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = sext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> %ext, !prof !0
  ret <2 x i32> %sel
}

define i32 @zext_false_val_must_be_zero(i1 %x) {
; CHECK-LABEL: @zext_false_val_must_be_zero(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[X:%.*]], i32 42, i32 0, !prof !0
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %ext = zext i1 %x to i32
  %sel = select i1 %x, i32 42, i32 %ext, !prof !0
  ret i32 %sel
}

define <2 x i32> @zext_false_val_must_be_zero_vec(<2 x i1> %x) {
; CHECK-LABEL: @zext_false_val_must_be_zero_vec(
; CHECK-NEXT:    [[SEL:%.*]] = select <2 x i1> [[X:%.*]], <2 x i32> <i32 42, i32 12>, <2 x i32> zeroinitializer, !prof !0
; CHECK-NEXT:    ret <2 x i32> [[SEL]]
;
  %ext = zext <2 x i1> %x to <2 x i32>
  %sel = select <2 x i1> %x, <2 x i32> <i32 42, i32 12>, <2 x i32> %ext, !prof !0
  ret <2 x i32> %sel
}

!0 = !{!"branch_weights", i32 3, i32 5}

