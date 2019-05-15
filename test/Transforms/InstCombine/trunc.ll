; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

; Instcombine should be able to eliminate all of these ext casts.

declare void @use(i32)

define i64 @test1(i64 %a) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[B:%.*]] = trunc i64 [[A:%.*]] to i32
; CHECK-NEXT:    [[C:%.*]] = and i64 [[A]], 15
; CHECK-NEXT:    call void @use(i32 [[B]])
; CHECK-NEXT:    ret i64 [[C]]
;
  %b = trunc i64 %a to i32
  %c = and i32 %b, 15
  %d = zext i32 %c to i64
  call void @use(i32 %b)
  ret i64 %d
}

define i64 @test2(i64 %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[B:%.*]] = trunc i64 [[A:%.*]] to i32
; CHECK-NEXT:    [[D1:%.*]] = shl i64 [[A]], 36
; CHECK-NEXT:    [[D:%.*]] = ashr exact i64 [[D1]], 36
; CHECK-NEXT:    call void @use(i32 [[B]])
; CHECK-NEXT:    ret i64 [[D]]
;
  %b = trunc i64 %a to i32
  %c = shl i32 %b, 4
  %q = ashr i32 %c, 4
  %d = sext i32 %q to i64
  call void @use(i32 %b)
  ret i64 %d
}

define i64 @test3(i64 %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[B:%.*]] = trunc i64 [[A:%.*]] to i32
; CHECK-NEXT:    [[C:%.*]] = and i64 [[A]], 8
; CHECK-NEXT:    call void @use(i32 [[B]])
; CHECK-NEXT:    ret i64 [[C]]
;
  %b = trunc i64 %a to i32
  %c = and i32 %b, 8
  %d = zext i32 %c to i64
  call void @use(i32 %b)
  ret i64 %d
}

define i64 @test4(i64 %a) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[B:%.*]] = trunc i64 [[A:%.*]] to i32
; CHECK-NEXT:    [[C:%.*]] = and i64 [[A]], 8
; CHECK-NEXT:    [[X:%.*]] = xor i64 [[C]], 8
; CHECK-NEXT:    call void @use(i32 [[B]])
; CHECK-NEXT:    ret i64 [[X]]
;
  %b = trunc i64 %a to i32
  %c = and i32 %b, 8
  %x = xor i32 %c, 8
  %d = zext i32 %x to i64
  call void @use(i32 %b)
  ret i64 %d
}

define i32 @test5(i32 %A) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[A:%.*]], 16
; CHECK-NEXT:    ret i32 [[TMP1]]
;
  %B = zext i32 %A to i128
  %C = lshr i128 %B, 16
  %D = trunc i128 %C to i32
  ret i32 %D
}

define i32 @test6(i64 %A) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i64 [[A:%.*]], 32
; CHECK-NEXT:    [[D:%.*]] = trunc i64 [[TMP1]] to i32
; CHECK-NEXT:    ret i32 [[D]]
;
  %B = zext i64 %A to i128
  %C = lshr i128 %B, 32
  %D = trunc i128 %C to i32
  ret i32 %D
}

; Test case where 'ashr' demanded bits does not contain any of the high bits,
; but does contain sign bits, where the sign bit is not known to be zero.
define i16 @ashr_mul_sign_bits(i8 %X, i8 %Y) {
; CHECK-LABEL: @ashr_mul_sign_bits(
; CHECK-NEXT:    [[A:%.*]] = sext i8 [[X:%.*]] to i16
; CHECK-NEXT:    [[B:%.*]] = sext i8 [[Y:%.*]] to i16
; CHECK-NEXT:    [[C:%.*]] = mul nsw i16 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = ashr i16 [[C]], 3
; CHECK-NEXT:    ret i16 [[D]]
;
  %A = sext i8 %X to i32
  %B = sext i8 %Y to i32
  %C = mul i32 %A, %B
  %D = ashr i32 %C, 3
  %E = trunc i32 %D to i16
  ret i16 %E
}

define i16 @ashr_mul(i8 %X, i8 %Y) {
; CHECK-LABEL: @ashr_mul(
; CHECK-NEXT:    [[A:%.*]] = sext i8 [[X:%.*]] to i16
; CHECK-NEXT:    [[B:%.*]] = sext i8 [[Y:%.*]] to i16
; CHECK-NEXT:    [[C:%.*]] = mul nsw i16 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = ashr i16 [[C]], 8
; CHECK-NEXT:    ret i16 [[D]]
;
  %A = sext i8 %X to i20
  %B = sext i8 %Y to i20
  %C = mul i20 %A, %B
  %D = ashr i20 %C, 8
  %E = trunc i20 %D to i16
  ret i16 %E
}

define i32 @trunc_ashr(i32 %X) {
; CHECK-LABEL: @trunc_ashr(
; CHECK-NEXT:    [[B:%.*]] = or i32 [[X:%.*]], -2147483648
; CHECK-NEXT:    [[C:%.*]] = ashr i32 [[B]], 8
; CHECK-NEXT:    ret i32 [[C]]
;
  %A = zext i32 %X to i36
  %B = or i36 %A, -2147483648 ; 0xF80000000
  %C = ashr i36 %B, 8
  %T = trunc i36 %C to i32
  ret i32  %T
}

define <2 x i32> @trunc_ashr_vec(<2 x i32> %X) {
; CHECK-LABEL: @trunc_ashr_vec(
; CHECK-NEXT:    [[B:%.*]] = or <2 x i32> [[X:%.*]], <i32 -2147483648, i32 -2147483648>
; CHECK-NEXT:    [[C:%.*]] = ashr <2 x i32> [[B]], <i32 8, i32 8>
; CHECK-NEXT:    ret <2 x i32> [[C]]
;
  %A = zext <2 x i32> %X to <2 x i36>
  %B = or <2 x i36> %A, <i36 -2147483648, i36 -2147483648> ; 0xF80000000
  %C = ashr <2 x i36> %B, <i36 8, i36 8>
  %T = trunc <2 x i36> %C to <2 x i32>
  ret <2 x i32>  %T
}

define i92 @test7(i64 %A) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i64 [[A:%.*]], 32
; CHECK-NEXT:    [[D:%.*]] = zext i64 [[TMP1]] to i92
; CHECK-NEXT:    ret i92 [[D]]
;
  %B = zext i64 %A to i128
  %C = lshr i128 %B, 32
  %D = trunc i128 %C to i92
  ret i92 %D
}

define i64 @test8(i32 %A, i32 %B) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[TMP38:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[TMP32:%.*]] = zext i32 [[B:%.*]] to i64
; CHECK-NEXT:    [[TMP33:%.*]] = shl nuw i64 [[TMP32]], 32
; CHECK-NEXT:    [[INS35:%.*]] = or i64 [[TMP33]], [[TMP38]]
; CHECK-NEXT:    ret i64 [[INS35]]
;
  %tmp38 = zext i32 %A to i128
  %tmp32 = zext i32 %B to i128
  %tmp33 = shl i128 %tmp32, 32
  %ins35 = or i128 %tmp33, %tmp38
  %tmp42 = trunc i128 %ins35 to i64
  ret i64 %tmp42
}

define i8 @test9(i32 %X) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 [[X:%.*]] to i8
; CHECK-NEXT:    [[Z:%.*]] = and i8 [[TMP1]], 42
; CHECK-NEXT:    ret i8 [[Z]]
;
  %Y = and i32 %X, 42
  %Z = trunc i32 %Y to i8
  ret i8 %Z
}

; rdar://8808586
define i8 @test10(i32 %X) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[Y:%.*]] = trunc i32 [[X:%.*]] to i8
; CHECK-NEXT:    [[Z:%.*]] = and i8 [[Y]], 42
; CHECK-NEXT:    ret i8 [[Z]]
;
  %Y = trunc i32 %X to i8
  %Z = and i8 %Y, 42
  ret i8 %Z
}

; PR25543
; https://llvm.org/bugs/show_bug.cgi?id=25543
; This is an extractelement.

define i32 @trunc_bitcast1(<4 x i32> %v) {
; CHECK-LABEL: @trunc_bitcast1(
; CHECK-NEXT:    [[EXT:%.*]] = extractelement <4 x i32> [[V:%.*]], i32 1
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %bc = bitcast <4 x i32> %v to i128
  %shr = lshr i128 %bc, 32
  %ext = trunc i128 %shr to i32
  ret i32 %ext
}

; A bitcast may still be required.

define i32 @trunc_bitcast2(<2 x i64> %v) {
; CHECK-LABEL: @trunc_bitcast2(
; CHECK-NEXT:    [[BC1:%.*]] = bitcast <2 x i64> [[V:%.*]] to <4 x i32>
; CHECK-NEXT:    [[EXT:%.*]] = extractelement <4 x i32> [[BC1]], i32 2
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %bc = bitcast <2 x i64> %v to i128
  %shr = lshr i128 %bc, 64
  %ext = trunc i128 %shr to i32
  ret i32 %ext
}

; The right shift is optional.

define i32 @trunc_bitcast3(<4 x i32> %v) {
; CHECK-LABEL: @trunc_bitcast3(
; CHECK-NEXT:    [[EXT:%.*]] = extractelement <4 x i32> [[V:%.*]], i32 0
; CHECK-NEXT:    ret i32 [[EXT]]
;
  %bc = bitcast <4 x i32> %v to i128
  %ext = trunc i128 %bc to i32
  ret i32 %ext
}

define i32 @trunc_shl_31_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_31_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 31
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl i64 %val, 31
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_nsw_31_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_nsw_31_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 31
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl nsw i64 %val, 31
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_nuw_31_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_nuw_31_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 31
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl nuw i64 %val, 31
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_nsw_nuw_31_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_nsw_nuw_31_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 31
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl nsw nuw i64 %val, 31
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i16 @trunc_shl_15_i16_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_15_i16_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i16
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i16 [[VAL_TR]], 15
; CHECK-NEXT:    ret i16 [[TRUNC]]
;
  %shl = shl i64 %val, 15
  %trunc = trunc i64 %shl to i16
  ret i16 %trunc
}

define i16 @trunc_shl_15_i16_i32(i32 %val) {
; CHECK-LABEL: @trunc_shl_15_i16_i32(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i32 [[VAL:%.*]] to i16
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i16 [[VAL_TR]], 15
; CHECK-NEXT:    ret i16 [[TRUNC]]
;
  %shl = shl i32 %val, 15
  %trunc = trunc i32 %shl to i16
  ret i16 %trunc
}

define i8 @trunc_shl_7_i8_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_7_i8_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i8
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i8 [[VAL_TR]], 7
; CHECK-NEXT:    ret i8 [[TRUNC]]
;
  %shl = shl i64 %val, 7
  %trunc = trunc i64 %shl to i8
  ret i8 %trunc
}

define i2 @trunc_shl_1_i2_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_1_i2_i64(
; CHECK-NEXT:    [[SHL:%.*]] = shl i64 [[VAL:%.*]], 1
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc i64 [[SHL]] to i2
; CHECK-NEXT:    ret i2 [[TRUNC]]
;
  %shl = shl i64 %val, 1
  %trunc = trunc i64 %shl to i2
  ret i2 %trunc
}

define i32 @trunc_shl_1_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_1_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 1
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl i64 %val, 1
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_16_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_16_i32_i64(
; CHECK-NEXT:    [[VAL_TR:%.*]] = trunc i64 [[VAL:%.*]] to i32
; CHECK-NEXT:    [[TRUNC:%.*]] = shl i32 [[VAL_TR]], 16
; CHECK-NEXT:    ret i32 [[TRUNC]]
;
  %shl = shl i64 %val, 16
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_33_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_33_i32_i64(
; CHECK-NEXT:    ret i32 0
;
  %shl = shl i64 %val, 33
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

define i32 @trunc_shl_32_i32_i64(i64 %val) {
; CHECK-LABEL: @trunc_shl_32_i32_i64(
; CHECK-NEXT:    ret i32 0
;
  %shl = shl i64 %val, 32
  %trunc = trunc i64 %shl to i32
  ret i32 %trunc
}

; TODO: Should be able to handle vectors
define <2 x i32> @trunc_shl_16_v2i32_v2i64(<2 x i64> %val) {
; CHECK-LABEL: @trunc_shl_16_v2i32_v2i64(
; CHECK-NEXT:    [[SHL:%.*]] = shl <2 x i64> [[VAL:%.*]], <i64 16, i64 16>
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <2 x i64> [[SHL]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[TRUNC]]
;
  %shl = shl <2 x i64> %val, <i64 16, i64 16>
  %trunc = trunc <2 x i64> %shl to <2 x i32>
  ret <2 x i32> %trunc
}

define <2 x i32> @trunc_shl_nosplat_v2i32_v2i64(<2 x i64> %val) {
; CHECK-LABEL: @trunc_shl_nosplat_v2i32_v2i64(
; CHECK-NEXT:    [[SHL:%.*]] = shl <2 x i64> [[VAL:%.*]], <i64 15, i64 16>
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <2 x i64> [[SHL]] to <2 x i32>
; CHECK-NEXT:    ret <2 x i32> [[TRUNC]]
;
  %shl = shl <2 x i64> %val, <i64 15, i64 16>
  %trunc = trunc <2 x i64> %shl to <2 x i32>
  ret <2 x i32> %trunc
}

define void @trunc_shl_31_i32_i64_multi_use(i64 %val, i32 addrspace(1)* %ptr0, i64 addrspace(1)* %ptr1) {
; CHECK-LABEL: @trunc_shl_31_i32_i64_multi_use(
; CHECK-NEXT:    [[SHL:%.*]] = shl i64 [[VAL:%.*]], 31
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc i64 [[SHL]] to i32
; CHECK-NEXT:    store volatile i32 [[TRUNC]], i32 addrspace(1)* [[PTR0:%.*]], align 4
; CHECK-NEXT:    store volatile i64 [[SHL]], i64 addrspace(1)* [[PTR1:%.*]], align 8
; CHECK-NEXT:    ret void
;
  %shl = shl i64 %val, 31
  %trunc = trunc i64 %shl to i32
  store volatile i32 %trunc, i32 addrspace(1)* %ptr0
  store volatile i64 %shl, i64 addrspace(1)* %ptr1
  ret void
}

define i32 @trunc_shl_lshr_infloop(i64 %arg) {
; CHECK-LABEL: @trunc_shl_lshr_infloop(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i64 [[ARG:%.*]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = shl i64 [[TMP0]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = trunc i64 [[TMP1]] to i32
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = lshr i64 %arg, 1
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define i32 @trunc_shl_ashr_infloop(i64 %arg) {
; CHECK-LABEL: @trunc_shl_ashr_infloop(
; CHECK-NEXT:    [[TMP0:%.*]] = ashr i64 [[ARG:%.*]], 3
; CHECK-NEXT:    [[TMP1:%.*]] = shl nsw i64 [[TMP0]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = trunc i64 [[TMP1]] to i32
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = ashr i64 %arg, 3
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define i32 @trunc_shl_shl_infloop(i64 %arg) {
; CHECK-LABEL: @trunc_shl_shl_infloop(
; CHECK-NEXT:    [[ARG_TR:%.*]] = trunc i64 [[ARG:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = shl i32 [[ARG_TR]], 3
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = shl i64 %arg, 1
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define i32 @trunc_shl_lshr_var(i64 %arg, i64 %val) {
; CHECK-LABEL: @trunc_shl_lshr_var(
; CHECK-NEXT:    [[TMP0:%.*]] = lshr i64 [[ARG:%.*]], [[VAL:%.*]]
; CHECK-NEXT:    [[TMP0_TR:%.*]] = trunc i64 [[TMP0]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = shl i32 [[TMP0_TR]], 2
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = lshr i64 %arg, %val
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define i32 @trunc_shl_ashr_var(i64 %arg, i64 %val) {
; CHECK-LABEL: @trunc_shl_ashr_var(
; CHECK-NEXT:    [[TMP0:%.*]] = ashr i64 [[ARG:%.*]], [[VAL:%.*]]
; CHECK-NEXT:    [[TMP0_TR:%.*]] = trunc i64 [[TMP0]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = shl i32 [[TMP0_TR]], 2
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = ashr i64 %arg, %val
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define i32 @trunc_shl_shl_var(i64 %arg, i64 %val) {
; CHECK-LABEL: @trunc_shl_shl_var(
; CHECK-NEXT:    [[TMP0:%.*]] = shl i64 [[ARG:%.*]], [[VAL:%.*]]
; CHECK-NEXT:    [[TMP0_TR:%.*]] = trunc i64 [[TMP0]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = shl i32 [[TMP0_TR]], 2
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %tmp0 = shl i64 %arg, %val
  %tmp1 = shl i64 %tmp0, 2
  %tmp2 = trunc i64 %tmp1 to i32
  ret i32 %tmp2
}

define <8 x i16> @trunc_shl_v8i15_v8i32_15(<8 x i32> %a) {
; CHECK-LABEL: @trunc_shl_v8i15_v8i32_15(
; CHECK-NEXT:    [[SHL:%.*]] = shl <8 x i32> [[A:%.*]], <i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15>
; CHECK-NEXT:    [[CONV:%.*]] = trunc <8 x i32> [[SHL]] to <8 x i16>
; CHECK-NEXT:    ret <8 x i16> [[CONV]]
;
  %shl = shl <8 x i32> %a, <i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15>
  %conv = trunc <8 x i32> %shl to <8 x i16>
  ret <8 x i16> %conv
}

define <8 x i16> @trunc_shl_v8i16_v8i32_16(<8 x i32> %a) {
; CHECK-LABEL: @trunc_shl_v8i16_v8i32_16(
; CHECK-NEXT:    ret <8 x i16> zeroinitializer
;
  %shl = shl <8 x i32> %a, <i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16>
  %conv = trunc <8 x i32> %shl to <8 x i16>
  ret <8 x i16> %conv
}

define <8 x i16> @trunc_shl_v8i16_v8i32_17(<8 x i32> %a) {
; CHECK-LABEL: @trunc_shl_v8i16_v8i32_17(
; CHECK-NEXT:    ret <8 x i16> zeroinitializer
;
  %shl = shl <8 x i32> %a, <i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17, i32 17>
  %conv = trunc <8 x i32> %shl to <8 x i16>
  ret <8 x i16> %conv
}

define <8 x i16> @trunc_shl_v8i16_v8i32_4(<8 x i32> %a) {
; CHECK-LABEL: @trunc_shl_v8i16_v8i32_4(
; CHECK-NEXT:    [[SHL:%.*]] = shl <8 x i32> [[A:%.*]], <i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4>
; CHECK-NEXT:    [[CONV:%.*]] = trunc <8 x i32> [[SHL]] to <8 x i16>
; CHECK-NEXT:    ret <8 x i16> [[CONV]]
;
  %shl = shl <8 x i32> %a, <i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4, i32 4>
  %conv = trunc <8 x i32> %shl to <8 x i16>
  ret <8 x i16> %conv
}

; Although the mask is the same value, we don't create a shuffle for types that the backend may not be able to handle:
; trunc (shuffle X, C, Mask) --> shuffle (trunc X), C', Mask

define <4 x i8> @wide_shuf(<4 x i32> %x) {
; CHECK-LABEL: @wide_shuf(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i32> [[X:%.*]], <4 x i32> <i32 undef, i32 3634, i32 90, i32 undef>, <4 x i32> <i32 1, i32 5, i32 6, i32 2>
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <4 x i32> [[SHUF]] to <4 x i8>
; CHECK-NEXT:    ret <4 x i8> [[TRUNC]]
;
  %shuf = shufflevector <4 x i32> %x, <4 x i32> <i32 35, i32 3634, i32 90, i32 -1>, <4 x i32> <i32 1, i32 5, i32 6, i32 2>
  %trunc = trunc <4 x i32> %shuf to <4 x i8>
  ret <4 x i8> %trunc
}

; trunc (shuffle X, undef, SplatMask) --> shuffle (trunc X), undef, SplatMask

define <4 x i8> @wide_splat1(<4 x i32> %x) {
; CHECK-LABEL: @wide_splat1(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <4 x i32> [[X:%.*]] to <4 x i8>
; CHECK-NEXT:    [[TRUNC:%.*]] = shufflevector <4 x i8> [[TMP1]], <4 x i8> undef, <4 x i32> <i32 2, i32 2, i32 2, i32 2>
; CHECK-NEXT:    ret <4 x i8> [[TRUNC]]
;
  %shuf = shufflevector <4 x i32> %x, <4 x i32> undef, <4 x i32> <i32 2, i32 2, i32 2, i32 2>
  %trunc = trunc <4 x i32> %shuf to <4 x i8>
  ret <4 x i8> %trunc
}

; Test weird types.
; trunc (shuffle X, undef, SplatMask) --> shuffle (trunc X), undef, SplatMask

define <3 x i31> @wide_splat2(<3 x i33> %x) {
; CHECK-LABEL: @wide_splat2(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <3 x i33> [[X:%.*]] to <3 x i31>
; CHECK-NEXT:    [[TRUNC:%.*]] = shufflevector <3 x i31> [[TMP1]], <3 x i31> undef, <3 x i32> <i32 1, i32 1, i32 1>
; CHECK-NEXT:    ret <3 x i31> [[TRUNC]]
;
  %shuf = shufflevector <3 x i33> %x, <3 x i33> undef, <3 x i32> <i32 1, i32 1, i32 1>
  %trunc = trunc <3 x i33> %shuf to <3 x i31>
  ret <3 x i31> %trunc
}

; FIXME:
; trunc (shuffle X, undef, SplatMask) --> shuffle (trunc X), undef, SplatMask
; A mask with undef elements should still be considered a splat mask.

define <3 x i31> @wide_splat3(<3 x i33> %x) {
; CHECK-LABEL: @wide_splat3(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <3 x i33> [[X:%.*]], <3 x i33> undef, <3 x i32> <i32 undef, i32 1, i32 1>
; CHECK-NEXT:    [[TRUNC:%.*]] = trunc <3 x i33> [[SHUF]] to <3 x i31>
; CHECK-NEXT:    ret <3 x i31> [[TRUNC]]
;
  %shuf = shufflevector <3 x i33> %x, <3 x i33> undef, <3 x i32> <i32 undef, i32 1, i32 1>
  %trunc = trunc <3 x i33> %shuf to <3 x i31>
  ret <3 x i31> %trunc
}

; TODO: The shuffle extends the length of the input vector. Should we shrink this?

define <8 x i8> @wide_lengthening_splat(<4 x i16> %v) {
; CHECK-LABEL: @wide_lengthening_splat(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i16> [[V:%.*]], <4 x i16> undef, <8 x i32> zeroinitializer
; CHECK-NEXT:    [[TR:%.*]] = trunc <8 x i16> [[SHUF]] to <8 x i8>
; CHECK-NEXT:    ret <8 x i8> [[TR]]
;
  %shuf = shufflevector <4 x i16> %v, <4 x i16> %v, <8 x i32> zeroinitializer
  %tr = trunc <8 x i16> %shuf to <8 x i8>
  ret <8 x i8> %tr
}

define <2 x i8> @narrow_add_vec_constant(<2 x i32> %x) {
; CHECK-LABEL: @narrow_add_vec_constant(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <2 x i32> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[TR:%.*]] = add <2 x i8> [[TMP1]], <i8 0, i8 127>
; CHECK-NEXT:    ret <2 x i8> [[TR]]
;
  %add = add <2 x i32> %x, <i32 256, i32 -129>
  %tr = trunc <2 x i32> %add to <2 x i8>
  ret <2 x i8> %tr
}

define <2 x i8> @narrow_mul_vec_constant(<2 x i32> %x) {
; CHECK-LABEL: @narrow_mul_vec_constant(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <2 x i32> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[TR:%.*]] = mul <2 x i8> [[TMP1]], <i8 0, i8 127>
; CHECK-NEXT:    ret <2 x i8> [[TR]]
;
  %add = mul <2 x i32> %x, <i32 256, i32 -129>
  %tr = trunc <2 x i32> %add to <2 x i8>
  ret <2 x i8> %tr
}

define <2 x i8> @narrow_sub_vec_constant(<2 x i32> %x) {
; CHECK-LABEL: @narrow_sub_vec_constant(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc <2 x i32> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[TR:%.*]] = sub <2 x i8> <i8 0, i8 127>, [[TMP1]]
; CHECK-NEXT:    ret <2 x i8> [[TR]]
;
  %sub = sub <2 x i32> <i32 256, i32 -129>, %x
  %tr = trunc <2 x i32> %sub to <2 x i8>
  ret <2 x i8> %tr
}

