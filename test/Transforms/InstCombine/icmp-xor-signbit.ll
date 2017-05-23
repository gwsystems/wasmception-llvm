; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; icmp u/s (a ^ signmask), (b ^ signmask) --> icmp s/u a, b

define i1 @slt_to_ult(i8 %x, i8 %y) {
; CHECK-LABEL: @slt_to_ult(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 %x, %y
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 128
  %b = xor i8 %y, 128
  %cmp = icmp slt i8 %a, %b
  ret i1 %cmp
}

; PR33138 - https://bugs.llvm.org/show_bug.cgi?id=33138

define <2 x i1> @slt_to_ult_splat(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @slt_to_ult_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i8> %x, %y
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 128, i8 128>
  %b = xor <2 x i8> %y, <i8 128, i8 128>
  %cmp = icmp slt <2 x i8> %a, %b
  ret <2 x i1> %cmp
}

; Make sure that unsigned -> signed works too.

define i1 @ult_to_slt(i8 %x, i8 %y) {
; CHECK-LABEL: @ult_to_slt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 %x, %y
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 128
  %b = xor i8 %y, 128
  %cmp = icmp ult i8 %a, %b
  ret i1 %cmp
}

define <2 x i1> @ult_to_slt_splat(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @ult_to_slt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> %x, %y
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 128, i8 128>
  %b = xor <2 x i8> %y, <i8 128, i8 128>
  %cmp = icmp ult <2 x i8> %a, %b
  ret <2 x i1> %cmp
}

; icmp u/s (a ^ maxsignval), (b ^ maxsignval) --> icmp s/u' a, b

define i1 @slt_to_ugt(i8 %x, i8 %y) {
; CHECK-LABEL: @slt_to_ugt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i8 %x, %y
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 127
  %b = xor i8 %y, 127
  %cmp = icmp slt i8 %a, %b
  ret i1 %cmp
}

define <2 x i1> @slt_to_ugt_splat(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @slt_to_ugt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <2 x i8> %x, %y
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 127, i8 127>
  %b = xor <2 x i8> %y, <i8 127, i8 127>
  %cmp = icmp slt <2 x i8> %a, %b
  ret <2 x i1> %cmp
}

; Make sure that unsigned -> signed works too.

define i1 @ult_to_sgt(i8 %x, i8 %y) {
; CHECK-LABEL: @ult_to_sgt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i8 %x, %y
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 127
  %b = xor i8 %y, 127
  %cmp = icmp ult i8 %a, %b
  ret i1 %cmp
}

define <2 x i1> @ult_to_sgt_splat(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @ult_to_sgt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i8> %x, %y
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 127, i8 127>
  %b = xor <2 x i8> %y, <i8 127, i8 127>
  %cmp = icmp ult <2 x i8> %a, %b
  ret <2 x i1> %cmp
}

; icmp u/s (a ^ signmask), C --> icmp s/u a, C'

define i1 @sge_to_ugt(i8 %x) {
; CHECK-LABEL: @sge_to_ugt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i8 %x, -114
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 128
  %cmp = icmp sge i8 %a, 15
  ret i1 %cmp
}

define <2 x i1> @sge_to_ugt_splat(<2 x i8> %x) {
; CHECK-LABEL: @sge_to_ugt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <2 x i8> %x, <i8 -114, i8 -114>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 128, i8 128>
  %cmp = icmp sge <2 x i8> %a, <i8 15, i8 15>
  ret <2 x i1> %cmp
}

; Make sure that unsigned -> signed works too.

define i1 @uge_to_sgt(i8 %x) {
; CHECK-LABEL: @uge_to_sgt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i8 %x, -114
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 128
  %cmp = icmp uge i8 %a, 15
  ret i1 %cmp
}

define <2 x i1> @uge_to_sgt_splat(<2 x i8> %x) {
; CHECK-LABEL: @uge_to_sgt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <2 x i8> %x, <i8 -114, i8 -114>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 128, i8 128>
  %cmp = icmp uge <2 x i8> %a, <i8 15, i8 15>
  ret <2 x i1> %cmp
}

; icmp u/s (a ^ maxsignval), C --> icmp s/u' a, C'

define i1 @sge_to_ult(i8 %x) {
; CHECK-LABEL: @sge_to_ult(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 %x, 113
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 127
  %cmp = icmp sge i8 %a, 15
  ret i1 %cmp
}

define <2 x i1> @sge_to_ult_splat(<2 x i8> %x) {
; CHECK-LABEL: @sge_to_ult_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <2 x i8> %x, <i8 113, i8 113>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 127, i8 127>
  %cmp = icmp sge <2 x i8> %a, <i8 15, i8 15>
  ret <2 x i1> %cmp
}

; Make sure that unsigned -> signed works too.

define i1 @uge_to_slt(i8 %x) {
; CHECK-LABEL: @uge_to_slt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 %x, 113
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %a = xor i8 %x, 127
  %cmp = icmp uge i8 %a, 15
  ret i1 %cmp
}

define <2 x i1> @uge_to_slt_splat(<2 x i8> %x) {
; CHECK-LABEL: @uge_to_slt_splat(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> %x, <i8 113, i8 113>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %a = xor <2 x i8> %x, <i8 127, i8 127>
  %cmp = icmp uge <2 x i8> %a, <i8 15, i8 15>
  ret <2 x i1> %cmp
}

