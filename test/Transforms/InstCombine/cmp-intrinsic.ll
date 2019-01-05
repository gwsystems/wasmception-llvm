; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare i16 @llvm.bswap.i16(i16)
declare i32 @llvm.bswap.i32(i32)
declare <2 x i64> @llvm.bswap.v2i64(<2 x i64>)
declare i33 @llvm.cttz.i33(i33, i1)
declare i32 @llvm.ctlz.i32(i32, i1)
declare i8 @llvm.ctpop.i8(i8)
declare i11 @llvm.ctpop.i11(i11)
declare <2 x i32> @llvm.cttz.v2i32(<2 x i32>, i1)
declare <2 x i32> @llvm.ctlz.v2i32(<2 x i32>, i1)
declare <2 x i32> @llvm.ctpop.v2i32(<2 x i32>)

define i1 @bswap_eq_i16(i16 %x) {
; CHECK-LABEL: @bswap_eq_i16(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i16 [[X:%.*]], 256
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %bs = call i16 @llvm.bswap.i16(i16 %x)
  %cmp = icmp eq i16 %bs, 1
  ret i1 %cmp
}

define i1 @bswap_ne_i32(i32 %x) {
; CHECK-LABEL: @bswap_ne_i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[X:%.*]], 33554432
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %bs = tail call i32 @llvm.bswap.i32(i32 %x)
  %cmp = icmp ne i32 %bs, 2
  ret i1 %cmp
}

define <2 x i1> @bswap_eq_v2i64(<2 x i64> %x) {
; CHECK-LABEL: @bswap_eq_v2i64(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <2 x i64> [[X:%.*]], <i64 216172782113783808, i64 216172782113783808>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %bs = tail call <2 x i64> @llvm.bswap.v2i64(<2 x i64> %x)
  %cmp = icmp eq <2 x i64> %bs, <i64 3, i64 3>
  ret <2 x i1> %cmp
}

define i1 @ctlz_eq_bitwidth_i32(i32 %x) {
; CHECK-LABEL: @ctlz_eq_bitwidth_i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X:%.*]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp eq i32 %lz, 32
  ret i1 %cmp
}

define i1 @ctlz_eq_zero_i32(i32 %x) {
; CHECK-LABEL: @ctlz_eq_zero_i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[X:%.*]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp eq i32 %lz, 0
  ret i1 %cmp
}

define <2 x i1> @ctlz_ne_zero_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @ctlz_ne_zero_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i32> [[A:%.*]], <i32 -1, i32 -1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, zeroinitializer
  ret <2 x i1> %cmp
}

define i1 @ctlz_eq_bw_minus_1_i32(i32 %x) {
; CHECK-LABEL: @ctlz_eq_bw_minus_1_i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X:%.*]], 1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp eq i32 %lz, 31
  ret i1 %cmp
}

define <2 x i1> @ctlz_ne_bw_minus_1_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @ctlz_ne_bw_minus_1_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[A:%.*]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, <i32 31, i32 31>
  ret <2 x i1> %cmp
}

define i1 @ctlz_eq_other_i32(i32 %x) {
; CHECK-LABEL: @ctlz_eq_other_i32(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -128
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[TMP1]], 128
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp eq i32 %lz, 24
  ret i1 %cmp
}

define <2 x i1> @ctlz_ne_other_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @ctlz_ne_other_v2i32(
; CHECK-NEXT:    [[TMP1:%.*]] = and <2 x i32> [[A:%.*]], <i32 -128, i32 -128>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[TMP1]], <i32 128, i32 128>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, <i32 24, i32 24>
  ret <2 x i1> %cmp
}

define i1 @ctlz_eq_other_i32_multiuse(i32 %x, i32* %p) {
; CHECK-LABEL: @ctlz_eq_other_i32_multiuse(
; CHECK-NEXT:    [[LZ:%.*]] = tail call i32 @llvm.ctlz.i32(i32 [[X:%.*]], i1 false), !range !0
; CHECK-NEXT:    store i32 [[LZ]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[LZ]], 24
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  store i32 %lz, i32* %p
  %cmp = icmp eq i32 %lz, 24
  ret i1 %cmp
}

define <2 x i1> @ctlz_ne_bitwidth_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @ctlz_ne_bitwidth_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, <i32 32, i32 32>
  ret <2 x i1> %cmp
}

define i1 @ctlz_ugt_zero_i32(i32 %x) {
; CHECK-LABEL: @ctlz_ugt_zero_i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[X:%.*]], -1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp ugt i32 %lz, 0
  ret i1 %cmp
}

define i1 @ctlz_ugt_one_i32(i32 %x) {
; CHECK-LABEL: @ctlz_ugt_one_i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call i32 @llvm.ctlz.i32(i32 [[X:%.*]], i1 false), !range !0
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[LZ]], 1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp ugt i32 %lz, 1
  ret i1 %cmp
}

define i1 @ctlz_ugt_other_i32(i32 %x) {
; CHECK-LABEL: @ctlz_ugt_other_i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call i32 @llvm.ctlz.i32(i32 [[X:%.*]], i1 false), !range !0
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[LZ]], 16
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp ugt i32 %lz, 16
  ret i1 %cmp
}

define i1 @ctlz_ugt_other_multiuse_i32(i32 %x, i32* %p) {
; CHECK-LABEL: @ctlz_ugt_other_multiuse_i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call i32 @llvm.ctlz.i32(i32 [[X:%.*]], i1 false), !range !0
; CHECK-NEXT:    store i32 [[LZ]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[LZ]], 16
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  store i32 %lz, i32* %p
  %cmp = icmp ugt i32 %lz, 16
  ret i1 %cmp
}

define i1 @ctlz_ugt_bw_minus_one_i32(i32 %x) {
; CHECK-LABEL: @ctlz_ugt_bw_minus_one_i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call i32 @llvm.ctlz.i32(i32 [[X:%.*]], i1 false), !range !0
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[LZ]], 31
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %lz = tail call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  %cmp = icmp ugt i32 %lz, 31
  ret i1 %cmp
}

define <2 x i1> @ctlz_ult_one_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctlz_ult_one_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i32> [[X:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %lz = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %lz, <i32 1, i32 1>
  ret <2 x i1> %cmp
}

define <2 x i1> @ctlz_ult_other_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctlz_ult_other_v2i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[LZ]], <i32 16, i32 16>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %lz = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %lz, <i32 16, i32 16>
  ret <2 x i1> %cmp
}

define <2 x i1> @ctlz_ult_other_multiuse_v2i32(<2 x i32> %x, <2 x i32>* %p) {
; CHECK-LABEL: @ctlz_ult_other_multiuse_v2i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    store <2 x i32> [[LZ]], <2 x i32>* [[P:%.*]], align 8
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[LZ]], <i32 16, i32 16>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %lz = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %x, i1 false)
  store <2 x i32> %lz, <2 x i32>* %p
  %cmp = icmp ult <2 x i32> %lz, <i32 16, i32 16>
  ret <2 x i1> %cmp
}

define <2 x i1> @ctlz_ult_bw_minus_one_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctlz_ult_bw_minus_one_v2i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[LZ]], <i32 31, i32 31>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %lz = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %lz, <i32 31, i32 31>
  ret <2 x i1> %cmp
}

define <2 x i1> @ctlz_ult_bitwidth_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctlz_ult_bitwidth_v2i32(
; CHECK-NEXT:    [[LZ:%.*]] = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[LZ]], <i32 32, i32 32>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %lz = tail call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %lz, <i32 32, i32 32>
  ret <2 x i1> %cmp
}

define i1 @cttz_ne_bitwidth_i33(i33 %x) {
; CHECK-LABEL: @cttz_ne_bitwidth_i33(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i33 [[X:%.*]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp ne i33 %tz, 33
  ret i1 %cmp
}

define <2 x i1> @cttz_eq_bitwidth_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @cttz_eq_bitwidth_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <2 x i32> [[A:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp eq <2 x i32> %x, <i32 32, i32 32>
  ret <2 x i1> %cmp
}

define i1 @cttz_eq_zero_i33(i33 %x) {
; CHECK-LABEL: @cttz_eq_zero_i33(
; CHECK-NEXT:    [[TMP1:%.*]] = and i33 [[X:%.*]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i33 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp eq i33 %tz, 0
  ret i1 %cmp
}

define <2 x i1> @cttz_ne_zero_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @cttz_ne_zero_v2i32(
; CHECK-NEXT:    [[TMP1:%.*]] = and <2 x i32> [[A:%.*]], <i32 1, i32 1>
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <2 x i32> [[TMP1]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, zeroinitializer
  ret <2 x i1> %cmp
}

define i1 @cttz_eq_bw_minus_1_i33(i33 %x) {
; CHECK-LABEL: @cttz_eq_bw_minus_1_i33(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i33 [[X:%.*]], -4294967296
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp eq i33 %tz, 32
  ret i1 %cmp
}

define <2 x i1> @cttz_ne_bw_minus_1_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @cttz_ne_bw_minus_1_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[A:%.*]], <i32 -2147483648, i32 -2147483648>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, <i32 31, i32 31>
  ret <2 x i1> %cmp
}

define i1 @cttz_eq_other_i33(i33 %x) {
; CHECK-LABEL: @cttz_eq_other_i33(
; CHECK-NEXT:    [[TMP1:%.*]] = and i33 [[X:%.*]], 31
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i33 [[TMP1]], 16
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp eq i33 %tz, 4
  ret i1 %cmp
}

define <2 x i1> @cttz_ne_other_v2i32(<2 x i32> %a) {
; CHECK-LABEL: @cttz_ne_other_v2i32(
; CHECK-NEXT:    [[TMP1:%.*]] = and <2 x i32> [[A:%.*]], <i32 31, i32 31>
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[TMP1]], <i32 16, i32 16>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %x = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a, i1 false)
  %cmp = icmp ne <2 x i32> %x, <i32 4, i32 4>
  ret <2 x i1> %cmp
}

define i1 @cttz_eq_other_i33_multiuse(i33 %x, i33* %p) {
; CHECK-LABEL: @cttz_eq_other_i33_multiuse(
; CHECK-NEXT:    [[TZ:%.*]] = tail call i33 @llvm.cttz.i33(i33 [[X:%.*]], i1 false), !range !1
; CHECK-NEXT:    store i33 [[TZ]], i33* [[P:%.*]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i33 [[TZ]], 4
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  store i33 %tz, i33* %p
  %cmp = icmp eq i33 %tz, 4
  ret i1 %cmp
}

define i1 @cttz_ugt_zero_i33(i33 %x) {
; CHECK-LABEL: @cttz_ugt_zero_i33(
; CHECK-NEXT:    [[TMP1:%.*]] = and i33 [[X:%.*]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i33 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp ugt i33 %tz, 0
  ret i1 %cmp
}

define i1 @cttz_ugt_one_i33(i33 %x) {
; CHECK-LABEL: @cttz_ugt_one_i33(
; CHECK-NEXT:    [[TZ:%.*]] = tail call i33 @llvm.cttz.i33(i33 [[X:%.*]], i1 false), !range !1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i33 [[TZ]], 1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp ugt i33 %tz, 1
  ret i1 %cmp
}

define i1 @cttz_ugt_other_i33(i33 %x) {
; CHECK-LABEL: @cttz_ugt_other_i33(
; CHECK-NEXT:    [[TZ:%.*]] = tail call i33 @llvm.cttz.i33(i33 [[X:%.*]], i1 false), !range !1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i33 [[TZ]], 16
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp ugt i33 %tz, 16
  ret i1 %cmp
}

define i1 @cttz_ugt_other_multiuse_i33(i33 %x, i33* %p) {
; CHECK-LABEL: @cttz_ugt_other_multiuse_i33(
; CHECK-NEXT:    [[TZ:%.*]] = tail call i33 @llvm.cttz.i33(i33 [[X:%.*]], i1 false), !range !1
; CHECK-NEXT:    store i33 [[TZ]], i33* [[P:%.*]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i33 [[TZ]], 16
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  store i33 %tz, i33* %p
  %cmp = icmp ugt i33 %tz, 16
  ret i1 %cmp
}

define i1 @cttz_ugt_bw_minus_one_i33(i33 %x) {
; CHECK-LABEL: @cttz_ugt_bw_minus_one_i33(
; CHECK-NEXT:    [[TZ:%.*]] = tail call i33 @llvm.cttz.i33(i33 [[X:%.*]], i1 false), !range !1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i33 [[TZ]], 32
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %tz = tail call i33 @llvm.cttz.i33(i33 %x, i1 false)
  %cmp = icmp ugt i33 %tz, 32
  ret i1 %cmp
}

define <2 x i1> @cttz_ult_one_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @cttz_ult_one_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = trunc <2 x i32> [[X:%.*]] to <2 x i1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %tz = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %tz, <i32 1, i32 1>
  ret <2 x i1> %cmp
}

define <2 x i1> @cttz_ult_other_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @cttz_ult_other_v2i32(
; CHECK-NEXT:    [[TZ:%.*]] = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[TZ]], <i32 16, i32 16>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %tz = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %tz, <i32 16, i32 16>
  ret <2 x i1> %cmp
}

define <2 x i1> @cttz_ult_other_multiuse_v2i32(<2 x i32> %x, <2 x i32>* %p) {
; CHECK-LABEL: @cttz_ult_other_multiuse_v2i32(
; CHECK-NEXT:    [[TZ:%.*]] = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    store <2 x i32> [[TZ]], <2 x i32>* [[P:%.*]], align 8
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[TZ]], <i32 16, i32 16>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %tz = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %x, i1 false)
  store <2 x i32> %tz, <2 x i32>* %p
  %cmp = icmp ult <2 x i32> %tz, <i32 16, i32 16>
  ret <2 x i1> %cmp
}

define <2 x i1> @cttz_ult_bw_minus_one_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @cttz_ult_bw_minus_one_v2i32(
; CHECK-NEXT:    [[TZ:%.*]] = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[TZ]], <i32 31, i32 31>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %tz = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %tz, <i32 31, i32 31>
  ret <2 x i1> %cmp
}

define <2 x i1> @cttz_ult_bitwidth_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @cttz_ult_bitwidth_v2i32(
; CHECK-NEXT:    [[TZ:%.*]] = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> [[X:%.*]], i1 false)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i32> [[TZ]], <i32 32, i32 32>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %tz = tail call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %x, i1 false)
  %cmp = icmp ult <2 x i32> %tz, <i32 32, i32 32>
  ret <2 x i1> %cmp
}

define i1 @ctpop_eq_zero_i11(i11 %x) {
; CHECK-LABEL: @ctpop_eq_zero_i11(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i11 [[X:%.*]], 0
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %pop = tail call i11 @llvm.ctpop.i11(i11 %x)
  %cmp = icmp eq i11 %pop, 0
  ret i1 %cmp
}

define <2 x i1> @ctpop_ne_zero_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctpop_ne_zero_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[X:%.*]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %pop = tail call <2 x i32> @llvm.ctpop.v2i32(<2 x i32> %x)
  %cmp = icmp ne <2 x i32> %pop, zeroinitializer
  ret <2 x i1> %cmp
}

define i1 @ctpop_eq_bitwidth_i8(i8 %x) {
; CHECK-LABEL: @ctpop_eq_bitwidth_i8(
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[X:%.*]], -1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %pop = tail call i8 @llvm.ctpop.i8(i8 %x)
  %cmp = icmp eq i8 %pop, 8
  ret i1 %cmp
}

define <2 x i1> @ctpop_ne_bitwidth_v2i32(<2 x i32> %x) {
; CHECK-LABEL: @ctpop_ne_bitwidth_v2i32(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne <2 x i32> [[X:%.*]], <i32 -1, i32 -1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %pop = tail call <2 x i32> @llvm.ctpop.v2i32(<2 x i32> %x)
  %cmp = icmp ne <2 x i32> %pop, <i32 32, i32 32>
  ret <2 x i1> %cmp
}

