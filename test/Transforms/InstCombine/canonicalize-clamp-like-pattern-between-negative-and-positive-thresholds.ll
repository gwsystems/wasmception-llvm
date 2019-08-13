; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; Given a pattern like:
;   %old_cmp1 = icmp slt i32 %x, C2
;   %old_replacement = select i1 %old_cmp1, i32 %target_low, i32 %target_high
;   %old_x_offseted = add i32 %x, C1
;   %old_cmp0 = icmp ult i32 %old_x_offseted, C0
;   %r = select i1 %old_cmp0, i32 %x, i32 %old_replacement
; it can be rewriten as more canonical pattern:
;   %new_cmp1 = icmp slt i32 %x, -C1
;   %new_cmp2 = icmp sge i32 %x, C0-C1
;   %new_clamped_low = select i1 %new_cmp1, i32 %target_low, i32 %x
;   %r = select i1 %new_cmp2, i32 %target_high, i32 %new_clamped_low
; Iff -C1 s<= C2 s<= C0-C1
; Also, ULT predicate can also be UGE; or UGT iff C0 != -1 (+invert result)
; Also, SLT predicate can also be SGE; or SGT iff C2 != INT_MAX (+invert res.)

;-------------------------------------------------------------------------------

; Basic pattern. There is no 'and', so lower threshold is 0 (inclusive).
; The upper threshold is 127 (inclusive).
; There are 2 icmp's so for scalars there are 4 possible combinations.
; The constant in %t0 has to be between the thresholds, i.e 128 <= Ct0 <= 0.

define i32 @t0_ult_slt_128(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t0_ult_slt_128(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 128
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 128
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @t1_ult_slt_0(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t1_ult_slt_0(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], -16
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, -16
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @t2_ult_sgt_128(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t2_ult_sgt_128(
; CHECK-NEXT:    [[T0:%.*]] = icmp sgt i32 [[X:%.*]], 127
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_HIGH:%.*]], i32 [[REPLACEMENT_LOW:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp sgt i32 %x, 127
  %t1 = select i1 %t0, i32 %replacement_high, i32 %replacement_low
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @t3_ult_sgt_neg1(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t3_ult_sgt_neg1(
; CHECK-NEXT:    [[T0:%.*]] = icmp sgt i32 [[X:%.*]], -17
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_HIGH:%.*]], i32 [[REPLACEMENT_LOW:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp sgt i32 %x, -17
  %t1 = select i1 %t0, i32 %replacement_high, i32 %replacement_low
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @t4_ugt_slt_128(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t4_ugt_slt_128(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 128
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ugt i32 [[T2]], 143
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[T1]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 128
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ugt i32 %t2, 143
  %r = select i1 %t3, i32 %t1, i32 %x
  ret i32 %r
}
define i32 @t5_ugt_slt_0(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t5_ugt_slt_0(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], -16
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ugt i32 [[T2]], 143
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[T1]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, -16
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ugt i32 %t2, 143
  %r = select i1 %t3, i32 %t1, i32 %x
  ret i32 %r
}

define i32 @t6_ugt_sgt_128(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t6_ugt_sgt_128(
; CHECK-NEXT:    [[T0:%.*]] = icmp sgt i32 [[X:%.*]], 127
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_HIGH:%.*]], i32 [[REPLACEMENT_LOW:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ugt i32 [[T2]], 143
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[T1]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp sgt i32 %x, 127
  %t1 = select i1 %t0, i32 %replacement_high, i32 %replacement_low
  %t2 = add i32 %x, 16
  %t3 = icmp ugt i32 %t2, 143
  %r = select i1 %t3, i32 %t1, i32 %x
  ret i32 %r
}
define i32 @t7_ugt_sgt_neg1(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t7_ugt_sgt_neg1(
; CHECK-NEXT:    [[T0:%.*]] = icmp sgt i32 [[X:%.*]], -17
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_HIGH:%.*]], i32 [[REPLACEMENT_LOW:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ugt i32 [[T2]], 143
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[T1]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp sgt i32 %x, -17
  %t1 = select i1 %t0, i32 %replacement_high, i32 %replacement_low
  %t2 = add i32 %x, 16
  %t3 = icmp ugt i32 %t2, 143
  %r = select i1 %t3, i32 %t1, i32 %x
  ret i32 %r
}

;-------------------------------------------------------------------------------

; So Ct0 can not be s> 128, or s< -16

define i32 @n8_ult_slt_129(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n8_ult_slt_129(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 129
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 129
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @n9_ult_slt_neg17(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n9_ult_slt_neg17(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], -17
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, -17
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

;-------------------------------------------------------------------------------

declare void @use32(i32)
declare void @use1(i1)

; One-use restrictions: here the entire pattern needs to be one-use.
; FIXME: if %t0 could be reused then it's less restrictive.

; This one is ok.
define i32 @t10_oneuse0(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t10_oneuse0(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @n11_oneuse1(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n11_oneuse1(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  call void @use32(i32 %t1)
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

; This one is ok.
define i32 @t12_oneuse2(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @t12_oneuse2(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  call void @use32(i32 %t2)
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @n13_oneuse3(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n13_oneuse3(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    call void @use1(i1 [[T3]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  call void @use1(i1 %t3)
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @n14_oneuse4(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n14_oneuse4(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  call void @use32(i32 %t1)
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @n15_oneuse5(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n15_oneuse5(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  call void @use32(i32 %t2)
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @n16_oneuse6(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n16_oneuse6(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    call void @use1(i1 [[T3]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  call void @use1(i1 %t3)
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @n17_oneuse7(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n17_oneuse7(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  call void @use32(i32 %t1)
  %t2 = add i32 %x, 16
  call void @use32(i32 %t2)
  %t3 = icmp ult i32 %t2, 144
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}
define i32 @n18_oneuse8(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n18_oneuse8(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    call void @use1(i1 [[T3]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  call void @use32(i32 %t1)
  %t2 = add i32 %x, 16
  %t3 = icmp ult i32 %t2, 144
  call void @use1(i1 %t3)
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

define i32 @n19_oneuse9(i32 %x, i32 %replacement_low, i32 %replacement_high) {
; CHECK-LABEL: @n19_oneuse9(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt i32 [[X:%.*]], 64
; CHECK-NEXT:    call void @use1(i1 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[T0]], i32 [[REPLACEMENT_LOW:%.*]], i32 [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[X]], 16
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i32 [[T2]], 144
; CHECK-NEXT:    call void @use1(i1 [[T3]])
; CHECK-NEXT:    [[R:%.*]] = select i1 [[T3]], i32 [[X]], i32 [[T1]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %t0 = icmp slt i32 %x, 64
  call void @use1(i1 %t0)
  %t1 = select i1 %t0, i32 %replacement_low, i32 %replacement_high
  call void @use32(i32 %t1)
  %t2 = add i32 %x, 16
  call void @use32(i32 %t2)
  %t3 = icmp ult i32 %t2, 144
  call void @use1(i1 %t3)
  %r = select i1 %t3, i32 %x, i32 %t1
  ret i32 %r
}

;-------------------------------------------------------------------------------

; Vectors

define <2 x i32> @t20_ult_slt_vec_splat(<2 x i32> %x, <2 x i32> %replacement_low, <2 x i32> %replacement_high) {
; CHECK-LABEL: @t20_ult_slt_vec_splat(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt <2 x i32> [[X:%.*]], <i32 128, i32 128>
; CHECK-NEXT:    [[T1:%.*]] = select <2 x i1> [[T0]], <2 x i32> [[REPLACEMENT_LOW:%.*]], <2 x i32> [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i32> [[X]], <i32 16, i32 16>
; CHECK-NEXT:    [[T3:%.*]] = icmp ult <2 x i32> [[T2]], <i32 144, i32 144>
; CHECK-NEXT:    [[R:%.*]] = select <2 x i1> [[T3]], <2 x i32> [[X]], <2 x i32> [[T1]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t0 = icmp slt <2 x i32> %x, <i32 128, i32 128>
  %t1 = select <2 x i1> %t0, <2 x i32> %replacement_low, <2 x i32> %replacement_high
  %t2 = add <2 x i32> %x, <i32 16, i32 16>
  %t3 = icmp ult <2 x i32> %t2, <i32 144, i32 144>
  %r = select <2 x i1> %t3, <2 x i32> %x, <2 x i32> %t1
  ret <2 x i32> %r
}
define <2 x i32> @t21_ult_slt_vec_nonsplat(<2 x i32> %x, <2 x i32> %replacement_low, <2 x i32> %replacement_high) {
; CHECK-LABEL: @t21_ult_slt_vec_nonsplat(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt <2 x i32> [[X:%.*]], <i32 128, i32 64>
; CHECK-NEXT:    [[T1:%.*]] = select <2 x i1> [[T0]], <2 x i32> [[REPLACEMENT_LOW:%.*]], <2 x i32> [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i32> [[X]], <i32 16, i32 8>
; CHECK-NEXT:    [[T3:%.*]] = icmp ult <2 x i32> [[T2]], <i32 144, i32 264>
; CHECK-NEXT:    [[R:%.*]] = select <2 x i1> [[T3]], <2 x i32> [[X]], <2 x i32> [[T1]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t0 = icmp slt <2 x i32> %x, <i32 128, i32 64>
  %t1 = select <2 x i1> %t0, <2 x i32> %replacement_low, <2 x i32> %replacement_high
  %t2 = add <2 x i32> %x, <i32 16, i32 8>
  %t3 = icmp ult <2 x i32> %t2, <i32 144, i32 264>
  %r = select <2 x i1> %t3, <2 x i32> %x, <2 x i32> %t1
  ret <2 x i32> %r
}

; Non-canonical predicates

declare void @use2xi1(<2 x i1>)

declare void @use(<2 x i1>)
define <2 x i32> @t22_uge_slt(<2 x i32> %x, <2 x i32> %replacement_low, <2 x i32> %replacement_high) {
; CHECK-LABEL: @t22_uge_slt(
; CHECK-NEXT:    [[T0:%.*]] = icmp slt <2 x i32> [[X:%.*]], <i32 128, i32 128>
; CHECK-NEXT:    [[T1:%.*]] = select <2 x i1> [[T0]], <2 x i32> [[REPLACEMENT_LOW:%.*]], <2 x i32> [[REPLACEMENT_HIGH:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i32> [[X]], <i32 16, i32 16>
; CHECK-NEXT:    [[T3:%.*]] = icmp uge <2 x i32> [[T2]], <i32 144, i32 0>
; CHECK-NEXT:    call void @use2xi1(<2 x i1> [[T3]])
; CHECK-NEXT:    [[R:%.*]] = select <2 x i1> [[T3]], <2 x i32> [[T1]], <2 x i32> [[X]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t0 = icmp slt <2 x i32> %x, <i32 128, i32 128>
  %t1 = select <2 x i1> %t0, <2 x i32> %replacement_low, <2 x i32> %replacement_high
  %t2 = add <2 x i32> %x, <i32 16, i32 16>
  %t3 = icmp uge <2 x i32> %t2, <i32 144, i32 0>
  call void @use2xi1(<2 x i1> %t3)
  %r = select <2 x i1> %t3, <2 x i32> %t1, <2 x i32> %x
  ret <2 x i32> %r
}

define <2 x i32> @t23_ult_sge(<2 x i32> %x, <2 x i32> %replacement_low, <2 x i32> %replacement_high) {
; CHECK-LABEL: @t23_ult_sge(
; CHECK-NEXT:    [[T0:%.*]] = icmp sge <2 x i32> [[X:%.*]], <i32 128, i32 -2147483648>
; CHECK-NEXT:    call void @use2xi1(<2 x i1> [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select <2 x i1> [[T0]], <2 x i32> [[REPLACEMENT_HIGH:%.*]], <2 x i32> [[REPLACEMENT_LOW:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i32> [[X]], <i32 16, i32 -2147483648>
; CHECK-NEXT:    [[T3:%.*]] = icmp ult <2 x i32> [[T2]], <i32 144, i32 -1>
; CHECK-NEXT:    [[R:%.*]] = select <2 x i1> [[T3]], <2 x i32> [[X]], <2 x i32> [[T1]]
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t0 = icmp sge <2 x i32> %x, <i32 128, i32 -2147483648>
  call void @use2xi1(<2 x i1> %t0)
  %t1 = select <2 x i1> %t0, <2 x i32> %replacement_high, <2 x i32> %replacement_low
  %t2 = add <2 x i32> %x, <i32 16, i32 -2147483648>
  %t3 = icmp ult <2 x i32> %t2, <i32 144, i32 -1>
  %r = select <2 x i1> %t3, <2 x i32> %x, <2 x i32> %t1
  ret <2 x i32> %r
}
