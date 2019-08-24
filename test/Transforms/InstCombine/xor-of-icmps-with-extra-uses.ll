; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; These xor-of-icmps could be replaced with and-of-icmps, but %cond0 has extra
; uses, so we don't consider it, even though some cases are freely invertible.

; %cond0 is extra-used in select, which is freely invertible.
define i1 @v0_select_of_consts(i32 %X, i32* %selected) {
; CHECK-LABEL: @v0_select_of_consts(
; CHECK-NEXT:    [[COND0_INV:%.*]] = icmp sgt i32 [[X:%.*]], 32767
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[COND0_INV]], i32 32767, i32 -32768
; CHECK-NEXT:    store i32 [[SELECT]], i32* [[SELECTED:%.*]], align 4
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 -32768
  store i32 %select, i32* %selected
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}
define i1 @v1_select_of_var_and_const(i32 %X, i32 %Y, i32* %selected) {
; CHECK-LABEL: @v1_select_of_var_and_const(
; CHECK-NEXT:    [[COND0:%.*]] = icmp slt i32 [[X:%.*]], 32768
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[COND0]], i32 -32768, i32 [[Y:%.*]]
; CHECK-NEXT:    store i32 [[SELECT]], i32* [[SELECTED:%.*]], align 4
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 %Y, i32 -32768
  store i32 %select, i32* %selected
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}
define i1 @v2_select_of_const_and_var(i32 %X, i32 %Y, i32* %selected) {
; CHECK-LABEL: @v2_select_of_const_and_var(
; CHECK-NEXT:    [[COND0_INV:%.*]] = icmp sgt i32 [[X:%.*]], 32767
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[COND0_INV]], i32 32767, i32 [[Y:%.*]]
; CHECK-NEXT:    store i32 [[SELECT]], i32* [[SELECTED:%.*]], align 4
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 %Y
  store i32 %select, i32* %selected
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}

; Branch is also freely invertible
define i1 @v3_branch(i32 %X, i32* %dst0, i32* %dst1) {
; CHECK-LABEL: @v3_branch(
; CHECK-NEXT:  begin:
; CHECK-NEXT:    [[COND0:%.*]] = icmp slt i32 [[X:%.*]], 32768
; CHECK-NEXT:    br i1 [[COND0]], label [[BB1:%.*]], label [[BB0:%.*]]
; CHECK:       bb0:
; CHECK-NEXT:    store i32 0, i32* [[DST0:%.*]], align 4
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 0, i32* [[DST1:%.*]], align 4
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP0]]
;
begin:
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  br i1 %cond0, label %bb0, label %bb1
bb0:
  store i32 0, i32* %dst0
  br label %end
bb1:
  store i32 0, i32* %dst1
  br label %end
end:
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}

; Can invert 'not'.
define i1 @v4_not_store(i32 %X, i1* %not_cond) {
; CHECK-LABEL: @v4_not_store(
; CHECK-NEXT:    [[COND0:%.*]] = icmp slt i32 [[X:%.*]], 32768
; CHECK-NEXT:    store i1 [[COND0]], i1* [[NOT_COND:%.*]], align 1
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %not_cond0 = xor i1 %cond0, -1
  store i1 %not_cond0, i1* %not_cond
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 -32768
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}

; All extra uses are invertible.
define i1 @v5_select_and_not(i32 %X, i32 %Y, i32* %selected, i1* %not_cond) {
; CHECK-LABEL: @v5_select_and_not(
; CHECK-NEXT:    [[COND0:%.*]] = icmp slt i32 [[X:%.*]], 32768
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[COND0]], i32 [[Y:%.*]], i32 32767
; CHECK-NEXT:    store i1 [[COND0]], i1* [[NOT_COND:%.*]], align 1
; CHECK-NEXT:    store i32 [[SELECT]], i32* [[SELECTED:%.*]], align 4
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X]], 32767
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 65535
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 %Y
  %not_cond0 = xor i1 %cond0, -1
  store i1 %not_cond0, i1* %not_cond
  store i32 %select, i32* %selected
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}

; Not all extra uses are invertible.
define i1 @n6_select_and_not(i32 %X, i32 %Y, i32* %selected, i1* %not_cond) {
; CHECK-LABEL: @n6_select_and_not(
; CHECK-NEXT:    [[COND0:%.*]] = icmp sgt i32 [[X:%.*]], 32767
; CHECK-NEXT:    [[COND1:%.*]] = icmp sgt i32 [[X]], -32768
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[COND0]], i32 32767, i32 [[Y:%.*]]
; CHECK-NEXT:    store i1 [[COND0]], i1* [[NOT_COND:%.*]], align 1
; CHECK-NEXT:    store i32 [[SELECT]], i32* [[SELECTED:%.*]], align 4
; CHECK-NEXT:    [[RES:%.*]] = xor i1 [[COND0]], [[COND1]]
; CHECK-NEXT:    ret i1 [[RES]]
;
  %cond0 = icmp sgt i32 %X, 32767
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 %Y
  store i1 %cond0, i1* %not_cond
  store i32 %select, i32* %selected
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}

; Not freely invertible, would require extra 'not' instruction.
define i1 @n7_store(i32 %X, i1* %cond) {
; CHECK-LABEL: @n7_store(
; CHECK-NEXT:    [[COND0:%.*]] = icmp sgt i32 [[X:%.*]], 32767
; CHECK-NEXT:    store i1 [[COND0]], i1* [[COND:%.*]], align 1
; CHECK-NEXT:    [[COND1:%.*]] = icmp sgt i32 [[X]], -32768
; CHECK-NEXT:    [[RES:%.*]] = xor i1 [[COND0]], [[COND1]]
; CHECK-NEXT:    ret i1 [[RES]]
;
  %cond0 = icmp sgt i32 %X, 32767
  store i1 %cond0, i1* %cond
  %cond1 = icmp sgt i32 %X, -32768
  %select = select i1 %cond0, i32 32767, i32 -32768
  %res = xor i1 %cond0, %cond1
  ret i1 %res
}
