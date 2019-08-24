; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -mtriple=amdgcn-- -mcpu=tahiti -amdgpu-codegenprepare %s | FileCheck -check-prefix=SI %s
; RUN: opt -S -mtriple=amdgcn-- -mcpu=fiji -amdgpu-codegenprepare %s | FileCheck -check-prefix=VI %s
; RUN: opt -S -mtriple=amdgcn-- -mcpu=fiji -amdgpu-codegenprepare-mul24=0 -amdgpu-codegenprepare %s | FileCheck -check-prefix=DISABLED %s

define i16 @mul_i16(i16 %lhs, i16 %rhs) {
; SI-LABEL: @mul_i16(
; SI-NEXT:    [[TMP1:%.*]] = zext i16 [[LHS:%.*]] to i32
; SI-NEXT:    [[TMP2:%.*]] = zext i16 [[RHS:%.*]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = trunc i32 [[TMP3]] to i16
; SI-NEXT:    ret i16 [[MUL]]
;
; VI-LABEL: @mul_i16(
; VI-NEXT:    [[MUL:%.*]] = mul i16 [[LHS:%.*]], [[RHS:%.*]]
; VI-NEXT:    ret i16 [[MUL]]
;
; DISABLED-LABEL: @mul_i16(
; DISABLED-NEXT:    [[MUL:%.*]] = mul i16 [[LHS:%.*]], [[RHS:%.*]]
; DISABLED-NEXT:    ret i16 [[MUL]]
;
  %mul = mul i16 %lhs, %rhs
  ret i16 %mul
}

define i32 @smul24_i32(i32 %lhs, i32 %rhs) {
; SI-LABEL: @smul24_i32(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 8
; SI-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 8
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 8
; SI-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 8
; SI-NEXT:    [[MUL:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[LHS24]], i32 [[RHS24]])
; SI-NEXT:    ret i32 [[MUL]]
;
; VI-LABEL: @smul24_i32(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 8
; VI-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 8
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 8
; VI-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 8
; VI-NEXT:    [[MUL:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[LHS24]], i32 [[RHS24]])
; VI-NEXT:    ret i32 [[MUL]]
;
; DISABLED-LABEL: @smul24_i32(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 8
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 8
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 8
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 8
; DISABLED-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i32 [[MUL]]
;
  %shl.lhs = shl i32 %lhs, 8
  %lhs24 = ashr i32 %shl.lhs, 8
  %lshr.rhs = shl i32 %rhs, 8
  %rhs24 = ashr i32 %lhs, 8
  %mul = mul i32 %lhs24, %rhs24
  ret i32 %mul
}

define <2 x i32> @smul24_v2i32(<2 x i32> %lhs, <2 x i32> %rhs) {
; SI-LABEL: @smul24_v2i32(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i32> [[LHS:%.*]], <i32 8, i32 8>
; SI-NEXT:    [[LHS24:%.*]] = ashr <2 x i32> [[SHL_LHS]], <i32 8, i32 8>
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i32> [[RHS:%.*]], <i32 8, i32 8>
; SI-NEXT:    [[RHS24:%.*]] = ashr <2 x i32> [[LHS]], <i32 8, i32 8>
; SI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i32> [[LHS24]], i64 0
; SI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i32> [[LHS24]], i64 1
; SI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i32> [[RHS24]], i64 0
; SI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i32> [[RHS24]], i64 1
; SI-NEXT:    [[TMP5:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP3]])
; SI-NEXT:    [[TMP6:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP2]], i32 [[TMP4]])
; SI-NEXT:    [[TMP7:%.*]] = insertelement <2 x i32> undef, i32 [[TMP5]], i64 0
; SI-NEXT:    [[MUL:%.*]] = insertelement <2 x i32> [[TMP7]], i32 [[TMP6]], i64 1
; SI-NEXT:    ret <2 x i32> [[MUL]]
;
; VI-LABEL: @smul24_v2i32(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i32> [[LHS:%.*]], <i32 8, i32 8>
; VI-NEXT:    [[LHS24:%.*]] = ashr <2 x i32> [[SHL_LHS]], <i32 8, i32 8>
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i32> [[RHS:%.*]], <i32 8, i32 8>
; VI-NEXT:    [[RHS24:%.*]] = ashr <2 x i32> [[LHS]], <i32 8, i32 8>
; VI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i32> [[LHS24]], i64 0
; VI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i32> [[LHS24]], i64 1
; VI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i32> [[RHS24]], i64 0
; VI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i32> [[RHS24]], i64 1
; VI-NEXT:    [[TMP5:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP3]])
; VI-NEXT:    [[TMP6:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP2]], i32 [[TMP4]])
; VI-NEXT:    [[TMP7:%.*]] = insertelement <2 x i32> undef, i32 [[TMP5]], i64 0
; VI-NEXT:    [[MUL:%.*]] = insertelement <2 x i32> [[TMP7]], i32 [[TMP6]], i64 1
; VI-NEXT:    ret <2 x i32> [[MUL]]
;
; DISABLED-LABEL: @smul24_v2i32(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i32> [[LHS:%.*]], <i32 8, i32 8>
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr <2 x i32> [[SHL_LHS]], <i32 8, i32 8>
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i32> [[RHS:%.*]], <i32 8, i32 8>
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr <2 x i32> [[LHS]], <i32 8, i32 8>
; DISABLED-NEXT:    [[MUL:%.*]] = mul <2 x i32> [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret <2 x i32> [[MUL]]
;
  %shl.lhs = shl <2 x i32> %lhs, <i32 8, i32 8>
  %lhs24 = ashr <2 x i32> %shl.lhs, <i32 8, i32 8>
  %lshr.rhs = shl <2 x i32> %rhs, <i32 8, i32 8>
  %rhs24 = ashr <2 x i32> %lhs, <i32 8, i32 8>
  %mul = mul <2 x i32> %lhs24, %rhs24
  ret <2 x i32> %mul
}

define i32 @umul24_i32(i32 %lhs, i32 %rhs) {
; SI-LABEL: @umul24_i32(
; SI-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 16777215
; SI-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 16777215
; SI-NEXT:    [[MUL:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[LHS24]], i32 [[RHS24]])
; SI-NEXT:    ret i32 [[MUL]]
;
; VI-LABEL: @umul24_i32(
; VI-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 16777215
; VI-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 16777215
; VI-NEXT:    [[MUL:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[LHS24]], i32 [[RHS24]])
; VI-NEXT:    ret i32 [[MUL]]
;
; DISABLED-LABEL: @umul24_i32(
; DISABLED-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 16777215
; DISABLED-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 16777215
; DISABLED-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i32 [[MUL]]
;
  %lhs24 = and i32 %lhs, 16777215
  %rhs24 = and i32 %rhs, 16777215
  %mul = mul i32 %lhs24, %rhs24
  ret i32 %mul
}

define <2 x i32> @umul24_v2i32(<2 x i32> %lhs, <2 x i32> %rhs) {
; SI-LABEL: @umul24_v2i32(
; SI-NEXT:    [[LHS24:%.*]] = and <2 x i32> [[LHS:%.*]], <i32 16777215, i32 16777215>
; SI-NEXT:    [[RHS24:%.*]] = and <2 x i32> [[RHS:%.*]], <i32 16777215, i32 16777215>
; SI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i32> [[LHS24]], i64 0
; SI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i32> [[LHS24]], i64 1
; SI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i32> [[RHS24]], i64 0
; SI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i32> [[RHS24]], i64 1
; SI-NEXT:    [[TMP5:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP3]])
; SI-NEXT:    [[TMP6:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP2]], i32 [[TMP4]])
; SI-NEXT:    [[TMP7:%.*]] = insertelement <2 x i32> undef, i32 [[TMP5]], i64 0
; SI-NEXT:    [[MUL:%.*]] = insertelement <2 x i32> [[TMP7]], i32 [[TMP6]], i64 1
; SI-NEXT:    ret <2 x i32> [[MUL]]
;
; VI-LABEL: @umul24_v2i32(
; VI-NEXT:    [[LHS24:%.*]] = and <2 x i32> [[LHS:%.*]], <i32 16777215, i32 16777215>
; VI-NEXT:    [[RHS24:%.*]] = and <2 x i32> [[RHS:%.*]], <i32 16777215, i32 16777215>
; VI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i32> [[LHS24]], i64 0
; VI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i32> [[LHS24]], i64 1
; VI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i32> [[RHS24]], i64 0
; VI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i32> [[RHS24]], i64 1
; VI-NEXT:    [[TMP5:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP3]])
; VI-NEXT:    [[TMP6:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP2]], i32 [[TMP4]])
; VI-NEXT:    [[TMP7:%.*]] = insertelement <2 x i32> undef, i32 [[TMP5]], i64 0
; VI-NEXT:    [[MUL:%.*]] = insertelement <2 x i32> [[TMP7]], i32 [[TMP6]], i64 1
; VI-NEXT:    ret <2 x i32> [[MUL]]
;
; DISABLED-LABEL: @umul24_v2i32(
; DISABLED-NEXT:    [[LHS24:%.*]] = and <2 x i32> [[LHS:%.*]], <i32 16777215, i32 16777215>
; DISABLED-NEXT:    [[RHS24:%.*]] = and <2 x i32> [[RHS:%.*]], <i32 16777215, i32 16777215>
; DISABLED-NEXT:    [[MUL:%.*]] = mul <2 x i32> [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret <2 x i32> [[MUL]]
;
  %lhs24 = and <2 x i32> %lhs, <i32 16777215, i32 16777215>
  %rhs24 = and <2 x i32> %rhs, <i32 16777215, i32 16777215>
  %mul = mul <2 x i32> %lhs24, %rhs24
  ret <2 x i32> %mul
}

define i64 @smul24_i64(i64 %lhs, i64 %rhs) {
; SI-LABEL: @smul24_i64(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl i64 [[LHS:%.*]], 40
; SI-NEXT:    [[LHS24:%.*]] = ashr i64 [[SHL_LHS]], 40
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl i64 [[RHS:%.*]], 40
; SI-NEXT:    [[RHS24:%.*]] = ashr i64 [[LHS]], 40
; SI-NEXT:    [[TMP1:%.*]] = trunc i64 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = trunc i64 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = sext i32 [[TMP3]] to i64
; SI-NEXT:    ret i64 [[MUL]]
;
; VI-LABEL: @smul24_i64(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl i64 [[LHS:%.*]], 40
; VI-NEXT:    [[LHS24:%.*]] = ashr i64 [[SHL_LHS]], 40
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl i64 [[RHS:%.*]], 40
; VI-NEXT:    [[RHS24:%.*]] = ashr i64 [[LHS]], 40
; VI-NEXT:    [[TMP1:%.*]] = trunc i64 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = trunc i64 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = sext i32 [[TMP3]] to i64
; VI-NEXT:    ret i64 [[MUL]]
;
; DISABLED-LABEL: @smul24_i64(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl i64 [[LHS:%.*]], 40
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr i64 [[SHL_LHS]], 40
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl i64 [[RHS:%.*]], 40
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr i64 [[LHS]], 40
; DISABLED-NEXT:    [[MUL:%.*]] = mul i64 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i64 [[MUL]]
;
  %shl.lhs = shl i64 %lhs, 40
  %lhs24 = ashr i64 %shl.lhs, 40
  %lshr.rhs = shl i64 %rhs, 40
  %rhs24 = ashr i64 %lhs, 40
  %mul = mul i64 %lhs24, %rhs24
  ret i64 %mul
}

define i64 @umul24_i64(i64 %lhs, i64 %rhs) {
; SI-LABEL: @umul24_i64(
; SI-NEXT:    [[LHS24:%.*]] = and i64 [[LHS:%.*]], 16777215
; SI-NEXT:    [[RHS24:%.*]] = and i64 [[RHS:%.*]], 16777215
; SI-NEXT:    [[TMP1:%.*]] = trunc i64 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = trunc i64 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = zext i32 [[TMP3]] to i64
; SI-NEXT:    ret i64 [[MUL]]
;
; VI-LABEL: @umul24_i64(
; VI-NEXT:    [[LHS24:%.*]] = and i64 [[LHS:%.*]], 16777215
; VI-NEXT:    [[RHS24:%.*]] = and i64 [[RHS:%.*]], 16777215
; VI-NEXT:    [[TMP1:%.*]] = trunc i64 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = trunc i64 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = zext i32 [[TMP3]] to i64
; VI-NEXT:    ret i64 [[MUL]]
;
; DISABLED-LABEL: @umul24_i64(
; DISABLED-NEXT:    [[LHS24:%.*]] = and i64 [[LHS:%.*]], 16777215
; DISABLED-NEXT:    [[RHS24:%.*]] = and i64 [[RHS:%.*]], 16777215
; DISABLED-NEXT:    [[MUL:%.*]] = mul i64 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i64 [[MUL]]
;
  %lhs24 = and i64 %lhs, 16777215
  %rhs24 = and i64 %rhs, 16777215
  %mul = mul i64 %lhs24, %rhs24
  ret i64 %mul
}

define i31 @smul24_i31(i31 %lhs, i31 %rhs) {
; SI-LABEL: @smul24_i31(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl i31 [[LHS:%.*]], 7
; SI-NEXT:    [[LHS24:%.*]] = ashr i31 [[SHL_LHS]], 7
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl i31 [[RHS:%.*]], 7
; SI-NEXT:    [[RHS24:%.*]] = ashr i31 [[LHS]], 7
; SI-NEXT:    [[TMP1:%.*]] = sext i31 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = sext i31 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = trunc i32 [[TMP3]] to i31
; SI-NEXT:    ret i31 [[MUL]]
;
; VI-LABEL: @smul24_i31(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl i31 [[LHS:%.*]], 7
; VI-NEXT:    [[LHS24:%.*]] = ashr i31 [[SHL_LHS]], 7
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl i31 [[RHS:%.*]], 7
; VI-NEXT:    [[RHS24:%.*]] = ashr i31 [[LHS]], 7
; VI-NEXT:    [[TMP1:%.*]] = sext i31 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = sext i31 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = trunc i32 [[TMP3]] to i31
; VI-NEXT:    ret i31 [[MUL]]
;
; DISABLED-LABEL: @smul24_i31(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl i31 [[LHS:%.*]], 7
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr i31 [[SHL_LHS]], 7
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl i31 [[RHS:%.*]], 7
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr i31 [[LHS]], 7
; DISABLED-NEXT:    [[MUL:%.*]] = mul i31 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i31 [[MUL]]
;
  %shl.lhs = shl i31 %lhs, 7
  %lhs24 = ashr i31 %shl.lhs, 7
  %lshr.rhs = shl i31 %rhs, 7
  %rhs24 = ashr i31 %lhs, 7
  %mul = mul i31 %lhs24, %rhs24
  ret i31 %mul
}

define i31 @umul24_i31(i31 %lhs, i31 %rhs) {
; SI-LABEL: @umul24_i31(
; SI-NEXT:    [[LHS24:%.*]] = and i31 [[LHS:%.*]], 16777215
; SI-NEXT:    [[RHS24:%.*]] = and i31 [[RHS:%.*]], 16777215
; SI-NEXT:    [[TMP1:%.*]] = zext i31 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = zext i31 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = trunc i32 [[TMP3]] to i31
; SI-NEXT:    ret i31 [[MUL]]
;
; VI-LABEL: @umul24_i31(
; VI-NEXT:    [[LHS24:%.*]] = and i31 [[LHS:%.*]], 16777215
; VI-NEXT:    [[RHS24:%.*]] = and i31 [[RHS:%.*]], 16777215
; VI-NEXT:    [[TMP1:%.*]] = zext i31 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = zext i31 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = trunc i32 [[TMP3]] to i31
; VI-NEXT:    ret i31 [[MUL]]
;
; DISABLED-LABEL: @umul24_i31(
; DISABLED-NEXT:    [[LHS24:%.*]] = and i31 [[LHS:%.*]], 16777215
; DISABLED-NEXT:    [[RHS24:%.*]] = and i31 [[RHS:%.*]], 16777215
; DISABLED-NEXT:    [[MUL:%.*]] = mul i31 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i31 [[MUL]]
;
  %lhs24 = and i31 %lhs, 16777215
  %rhs24 = and i31 %rhs, 16777215
  %mul = mul i31 %lhs24, %rhs24
  ret i31 %mul
}

define <2 x i31> @umul24_v2i31(<2 x i31> %lhs, <2 x i31> %rhs) {
; SI-LABEL: @umul24_v2i31(
; SI-NEXT:    [[LHS24:%.*]] = and <2 x i31> [[LHS:%.*]], <i31 16777215, i31 16777215>
; SI-NEXT:    [[RHS24:%.*]] = and <2 x i31> [[RHS:%.*]], <i31 16777215, i31 16777215>
; SI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i31> [[LHS24]], i64 0
; SI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i31> [[LHS24]], i64 1
; SI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i31> [[RHS24]], i64 0
; SI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i31> [[RHS24]], i64 1
; SI-NEXT:    [[TMP5:%.*]] = zext i31 [[TMP1]] to i32
; SI-NEXT:    [[TMP6:%.*]] = zext i31 [[TMP3]] to i32
; SI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP5]], i32 [[TMP6]])
; SI-NEXT:    [[TMP8:%.*]] = trunc i32 [[TMP7]] to i31
; SI-NEXT:    [[TMP9:%.*]] = zext i31 [[TMP2]] to i32
; SI-NEXT:    [[TMP10:%.*]] = zext i31 [[TMP4]] to i32
; SI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP9]], i32 [[TMP10]])
; SI-NEXT:    [[TMP12:%.*]] = trunc i32 [[TMP11]] to i31
; SI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i31> undef, i31 [[TMP8]], i64 0
; SI-NEXT:    [[MUL:%.*]] = insertelement <2 x i31> [[TMP13]], i31 [[TMP12]], i64 1
; SI-NEXT:    ret <2 x i31> [[MUL]]
;
; VI-LABEL: @umul24_v2i31(
; VI-NEXT:    [[LHS24:%.*]] = and <2 x i31> [[LHS:%.*]], <i31 16777215, i31 16777215>
; VI-NEXT:    [[RHS24:%.*]] = and <2 x i31> [[RHS:%.*]], <i31 16777215, i31 16777215>
; VI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i31> [[LHS24]], i64 0
; VI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i31> [[LHS24]], i64 1
; VI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i31> [[RHS24]], i64 0
; VI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i31> [[RHS24]], i64 1
; VI-NEXT:    [[TMP5:%.*]] = zext i31 [[TMP1]] to i32
; VI-NEXT:    [[TMP6:%.*]] = zext i31 [[TMP3]] to i32
; VI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP5]], i32 [[TMP6]])
; VI-NEXT:    [[TMP8:%.*]] = trunc i32 [[TMP7]] to i31
; VI-NEXT:    [[TMP9:%.*]] = zext i31 [[TMP2]] to i32
; VI-NEXT:    [[TMP10:%.*]] = zext i31 [[TMP4]] to i32
; VI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP9]], i32 [[TMP10]])
; VI-NEXT:    [[TMP12:%.*]] = trunc i32 [[TMP11]] to i31
; VI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i31> undef, i31 [[TMP8]], i64 0
; VI-NEXT:    [[MUL:%.*]] = insertelement <2 x i31> [[TMP13]], i31 [[TMP12]], i64 1
; VI-NEXT:    ret <2 x i31> [[MUL]]
;
; DISABLED-LABEL: @umul24_v2i31(
; DISABLED-NEXT:    [[LHS24:%.*]] = and <2 x i31> [[LHS:%.*]], <i31 16777215, i31 16777215>
; DISABLED-NEXT:    [[RHS24:%.*]] = and <2 x i31> [[RHS:%.*]], <i31 16777215, i31 16777215>
; DISABLED-NEXT:    [[MUL:%.*]] = mul <2 x i31> [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret <2 x i31> [[MUL]]
;
  %lhs24 = and <2 x i31> %lhs, <i31 16777215, i31 16777215>
  %rhs24 = and <2 x i31> %rhs, <i31 16777215, i31 16777215>
  %mul = mul <2 x i31> %lhs24, %rhs24
  ret <2 x i31> %mul
}

define <2 x i31> @smul24_v2i31(<2 x i31> %lhs, <2 x i31> %rhs) {
; SI-LABEL: @smul24_v2i31(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i31> [[LHS:%.*]], <i31 8, i31 8>
; SI-NEXT:    [[LHS24:%.*]] = ashr <2 x i31> [[SHL_LHS]], <i31 8, i31 8>
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i31> [[RHS:%.*]], <i31 8, i31 8>
; SI-NEXT:    [[RHS24:%.*]] = ashr <2 x i31> [[LHS]], <i31 8, i31 8>
; SI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i31> [[LHS24]], i64 0
; SI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i31> [[LHS24]], i64 1
; SI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i31> [[RHS24]], i64 0
; SI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i31> [[RHS24]], i64 1
; SI-NEXT:    [[TMP5:%.*]] = sext i31 [[TMP1]] to i32
; SI-NEXT:    [[TMP6:%.*]] = sext i31 [[TMP3]] to i32
; SI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP5]], i32 [[TMP6]])
; SI-NEXT:    [[TMP8:%.*]] = trunc i32 [[TMP7]] to i31
; SI-NEXT:    [[TMP9:%.*]] = sext i31 [[TMP2]] to i32
; SI-NEXT:    [[TMP10:%.*]] = sext i31 [[TMP4]] to i32
; SI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP9]], i32 [[TMP10]])
; SI-NEXT:    [[TMP12:%.*]] = trunc i32 [[TMP11]] to i31
; SI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i31> undef, i31 [[TMP8]], i64 0
; SI-NEXT:    [[MUL:%.*]] = insertelement <2 x i31> [[TMP13]], i31 [[TMP12]], i64 1
; SI-NEXT:    ret <2 x i31> [[MUL]]
;
; VI-LABEL: @smul24_v2i31(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i31> [[LHS:%.*]], <i31 8, i31 8>
; VI-NEXT:    [[LHS24:%.*]] = ashr <2 x i31> [[SHL_LHS]], <i31 8, i31 8>
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i31> [[RHS:%.*]], <i31 8, i31 8>
; VI-NEXT:    [[RHS24:%.*]] = ashr <2 x i31> [[LHS]], <i31 8, i31 8>
; VI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i31> [[LHS24]], i64 0
; VI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i31> [[LHS24]], i64 1
; VI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i31> [[RHS24]], i64 0
; VI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i31> [[RHS24]], i64 1
; VI-NEXT:    [[TMP5:%.*]] = sext i31 [[TMP1]] to i32
; VI-NEXT:    [[TMP6:%.*]] = sext i31 [[TMP3]] to i32
; VI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP5]], i32 [[TMP6]])
; VI-NEXT:    [[TMP8:%.*]] = trunc i32 [[TMP7]] to i31
; VI-NEXT:    [[TMP9:%.*]] = sext i31 [[TMP2]] to i32
; VI-NEXT:    [[TMP10:%.*]] = sext i31 [[TMP4]] to i32
; VI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP9]], i32 [[TMP10]])
; VI-NEXT:    [[TMP12:%.*]] = trunc i32 [[TMP11]] to i31
; VI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i31> undef, i31 [[TMP8]], i64 0
; VI-NEXT:    [[MUL:%.*]] = insertelement <2 x i31> [[TMP13]], i31 [[TMP12]], i64 1
; VI-NEXT:    ret <2 x i31> [[MUL]]
;
; DISABLED-LABEL: @smul24_v2i31(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i31> [[LHS:%.*]], <i31 8, i31 8>
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr <2 x i31> [[SHL_LHS]], <i31 8, i31 8>
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i31> [[RHS:%.*]], <i31 8, i31 8>
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr <2 x i31> [[LHS]], <i31 8, i31 8>
; DISABLED-NEXT:    [[MUL:%.*]] = mul <2 x i31> [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret <2 x i31> [[MUL]]
;
  %shl.lhs = shl <2 x i31> %lhs, <i31 8, i31 8>
  %lhs24 = ashr <2 x i31> %shl.lhs, <i31 8, i31 8>
  %lshr.rhs = shl <2 x i31> %rhs, <i31 8, i31 8>
  %rhs24 = ashr <2 x i31> %lhs, <i31 8, i31 8>
  %mul = mul <2 x i31> %lhs24, %rhs24
  ret <2 x i31> %mul
}

define i33 @smul24_i33(i33 %lhs, i33 %rhs) {
; SI-LABEL: @smul24_i33(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl i33 [[LHS:%.*]], 9
; SI-NEXT:    [[LHS24:%.*]] = ashr i33 [[SHL_LHS]], 9
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl i33 [[RHS:%.*]], 9
; SI-NEXT:    [[RHS24:%.*]] = ashr i33 [[LHS]], 9
; SI-NEXT:    [[TMP1:%.*]] = trunc i33 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = trunc i33 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = sext i32 [[TMP3]] to i33
; SI-NEXT:    ret i33 [[MUL]]
;
; VI-LABEL: @smul24_i33(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl i33 [[LHS:%.*]], 9
; VI-NEXT:    [[LHS24:%.*]] = ashr i33 [[SHL_LHS]], 9
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl i33 [[RHS:%.*]], 9
; VI-NEXT:    [[RHS24:%.*]] = ashr i33 [[LHS]], 9
; VI-NEXT:    [[TMP1:%.*]] = trunc i33 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = trunc i33 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = sext i32 [[TMP3]] to i33
; VI-NEXT:    ret i33 [[MUL]]
;
; DISABLED-LABEL: @smul24_i33(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl i33 [[LHS:%.*]], 9
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr i33 [[SHL_LHS]], 9
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl i33 [[RHS:%.*]], 9
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr i33 [[LHS]], 9
; DISABLED-NEXT:    [[MUL:%.*]] = mul i33 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i33 [[MUL]]
;
  %shl.lhs = shl i33 %lhs, 9
  %lhs24 = ashr i33 %shl.lhs, 9
  %lshr.rhs = shl i33 %rhs, 9
  %rhs24 = ashr i33 %lhs, 9
  %mul = mul i33 %lhs24, %rhs24
  ret i33 %mul
}

define i33 @umul24_i33(i33 %lhs, i33 %rhs) {
; SI-LABEL: @umul24_i33(
; SI-NEXT:    [[LHS24:%.*]] = and i33 [[LHS:%.*]], 16777215
; SI-NEXT:    [[RHS24:%.*]] = and i33 [[RHS:%.*]], 16777215
; SI-NEXT:    [[TMP1:%.*]] = trunc i33 [[LHS24]] to i32
; SI-NEXT:    [[TMP2:%.*]] = trunc i33 [[RHS24]] to i32
; SI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; SI-NEXT:    [[MUL:%.*]] = zext i32 [[TMP3]] to i33
; SI-NEXT:    ret i33 [[MUL]]
;
; VI-LABEL: @umul24_i33(
; VI-NEXT:    [[LHS24:%.*]] = and i33 [[LHS:%.*]], 16777215
; VI-NEXT:    [[RHS24:%.*]] = and i33 [[RHS:%.*]], 16777215
; VI-NEXT:    [[TMP1:%.*]] = trunc i33 [[LHS24]] to i32
; VI-NEXT:    [[TMP2:%.*]] = trunc i33 [[RHS24]] to i32
; VI-NEXT:    [[TMP3:%.*]] = call i32 @llvm.amdgcn.mul.u24(i32 [[TMP1]], i32 [[TMP2]])
; VI-NEXT:    [[MUL:%.*]] = zext i32 [[TMP3]] to i33
; VI-NEXT:    ret i33 [[MUL]]
;
; DISABLED-LABEL: @umul24_i33(
; DISABLED-NEXT:    [[LHS24:%.*]] = and i33 [[LHS:%.*]], 16777215
; DISABLED-NEXT:    [[RHS24:%.*]] = and i33 [[RHS:%.*]], 16777215
; DISABLED-NEXT:    [[MUL:%.*]] = mul i33 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i33 [[MUL]]
;
  %lhs24 = and i33 %lhs, 16777215
  %rhs24 = and i33 %rhs, 16777215
  %mul = mul i33 %lhs24, %rhs24
  ret i33 %mul
}

define i32 @smul25_i32(i32 %lhs, i32 %rhs) {
; SI-LABEL: @smul25_i32(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 7
; SI-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 7
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 7
; SI-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 7
; SI-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; SI-NEXT:    ret i32 [[MUL]]
;
; VI-LABEL: @smul25_i32(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 7
; VI-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 7
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 7
; VI-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 7
; VI-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; VI-NEXT:    ret i32 [[MUL]]
;
; DISABLED-LABEL: @smul25_i32(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl i32 [[LHS:%.*]], 7
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr i32 [[SHL_LHS]], 7
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl i32 [[RHS:%.*]], 7
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr i32 [[LHS]], 7
; DISABLED-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i32 [[MUL]]
;
  %shl.lhs = shl i32 %lhs, 7
  %lhs24 = ashr i32 %shl.lhs, 7
  %lshr.rhs = shl i32 %rhs, 7
  %rhs24 = ashr i32 %lhs, 7
  %mul = mul i32 %lhs24, %rhs24
  ret i32 %mul
}

define i32 @umul25_i32(i32 %lhs, i32 %rhs) {
; SI-LABEL: @umul25_i32(
; SI-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 33554431
; SI-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 33554431
; SI-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; SI-NEXT:    ret i32 [[MUL]]
;
; VI-LABEL: @umul25_i32(
; VI-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 33554431
; VI-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 33554431
; VI-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; VI-NEXT:    ret i32 [[MUL]]
;
; DISABLED-LABEL: @umul25_i32(
; DISABLED-NEXT:    [[LHS24:%.*]] = and i32 [[LHS:%.*]], 33554431
; DISABLED-NEXT:    [[RHS24:%.*]] = and i32 [[RHS:%.*]], 33554431
; DISABLED-NEXT:    [[MUL:%.*]] = mul i32 [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret i32 [[MUL]]
;
  %lhs24 = and i32 %lhs, 33554431
  %rhs24 = and i32 %rhs, 33554431
  %mul = mul i32 %lhs24, %rhs24
  ret i32 %mul
}

define <2 x i33> @smul24_v2i33(<2 x i33> %lhs, <2 x i33> %rhs) {
; SI-LABEL: @smul24_v2i33(
; SI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i33> [[LHS:%.*]], <i33 9, i33 9>
; SI-NEXT:    [[LHS24:%.*]] = ashr <2 x i33> [[SHL_LHS]], <i33 9, i33 9>
; SI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i33> [[RHS:%.*]], <i33 9, i33 9>
; SI-NEXT:    [[RHS24:%.*]] = ashr <2 x i33> [[LHS]], <i33 9, i33 9>
; SI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i33> [[LHS24]], i64 0
; SI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i33> [[LHS24]], i64 1
; SI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i33> [[RHS24]], i64 0
; SI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i33> [[RHS24]], i64 1
; SI-NEXT:    [[TMP5:%.*]] = trunc i33 [[TMP1]] to i32
; SI-NEXT:    [[TMP6:%.*]] = trunc i33 [[TMP3]] to i32
; SI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP5]], i32 [[TMP6]])
; SI-NEXT:    [[TMP8:%.*]] = sext i32 [[TMP7]] to i33
; SI-NEXT:    [[TMP9:%.*]] = trunc i33 [[TMP2]] to i32
; SI-NEXT:    [[TMP10:%.*]] = trunc i33 [[TMP4]] to i32
; SI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP9]], i32 [[TMP10]])
; SI-NEXT:    [[TMP12:%.*]] = sext i32 [[TMP11]] to i33
; SI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i33> undef, i33 [[TMP8]], i64 0
; SI-NEXT:    [[MUL:%.*]] = insertelement <2 x i33> [[TMP13]], i33 [[TMP12]], i64 1
; SI-NEXT:    ret <2 x i33> [[MUL]]
;
; VI-LABEL: @smul24_v2i33(
; VI-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i33> [[LHS:%.*]], <i33 9, i33 9>
; VI-NEXT:    [[LHS24:%.*]] = ashr <2 x i33> [[SHL_LHS]], <i33 9, i33 9>
; VI-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i33> [[RHS:%.*]], <i33 9, i33 9>
; VI-NEXT:    [[RHS24:%.*]] = ashr <2 x i33> [[LHS]], <i33 9, i33 9>
; VI-NEXT:    [[TMP1:%.*]] = extractelement <2 x i33> [[LHS24]], i64 0
; VI-NEXT:    [[TMP2:%.*]] = extractelement <2 x i33> [[LHS24]], i64 1
; VI-NEXT:    [[TMP3:%.*]] = extractelement <2 x i33> [[RHS24]], i64 0
; VI-NEXT:    [[TMP4:%.*]] = extractelement <2 x i33> [[RHS24]], i64 1
; VI-NEXT:    [[TMP5:%.*]] = trunc i33 [[TMP1]] to i32
; VI-NEXT:    [[TMP6:%.*]] = trunc i33 [[TMP3]] to i32
; VI-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP5]], i32 [[TMP6]])
; VI-NEXT:    [[TMP8:%.*]] = sext i32 [[TMP7]] to i33
; VI-NEXT:    [[TMP9:%.*]] = trunc i33 [[TMP2]] to i32
; VI-NEXT:    [[TMP10:%.*]] = trunc i33 [[TMP4]] to i32
; VI-NEXT:    [[TMP11:%.*]] = call i32 @llvm.amdgcn.mul.i24(i32 [[TMP9]], i32 [[TMP10]])
; VI-NEXT:    [[TMP12:%.*]] = sext i32 [[TMP11]] to i33
; VI-NEXT:    [[TMP13:%.*]] = insertelement <2 x i33> undef, i33 [[TMP8]], i64 0
; VI-NEXT:    [[MUL:%.*]] = insertelement <2 x i33> [[TMP13]], i33 [[TMP12]], i64 1
; VI-NEXT:    ret <2 x i33> [[MUL]]
;
; DISABLED-LABEL: @smul24_v2i33(
; DISABLED-NEXT:    [[SHL_LHS:%.*]] = shl <2 x i33> [[LHS:%.*]], <i33 9, i33 9>
; DISABLED-NEXT:    [[LHS24:%.*]] = ashr <2 x i33> [[SHL_LHS]], <i33 9, i33 9>
; DISABLED-NEXT:    [[LSHR_RHS:%.*]] = shl <2 x i33> [[RHS:%.*]], <i33 9, i33 9>
; DISABLED-NEXT:    [[RHS24:%.*]] = ashr <2 x i33> [[LHS]], <i33 9, i33 9>
; DISABLED-NEXT:    [[MUL:%.*]] = mul <2 x i33> [[LHS24]], [[RHS24]]
; DISABLED-NEXT:    ret <2 x i33> [[MUL]]
;
  %shl.lhs = shl <2 x i33> %lhs, <i33 9, i33 9>
  %lhs24 = ashr <2 x i33> %shl.lhs, <i33 9, i33 9>
  %lshr.rhs = shl <2 x i33> %rhs, <i33 9, i33 9>
  %rhs24 = ashr <2 x i33> %lhs, <i33 9, i33 9>
  %mul = mul <2 x i33> %lhs24, %rhs24
  ret <2 x i33> %mul
}
