; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -o - -S %s | FileCheck %s

; The constant at %v35 should be shrunk, but this must lead to the nsw flag of
; %v43 getting removed.

define i32 @foo(i32 %arg) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[V33:%.*]] = and i32 [[ARG:%.*]], 223
; CHECK-NEXT:    [[V34:%.*]] = xor i32 [[V33]], 29
; CHECK-NEXT:    [[V35:%.*]] = add nuw nsw i32 [[V34]], 1362915575
; CHECK-NEXT:    [[V40:%.*]] = shl nuw nsw i32 [[V34]], 1
; CHECK-NEXT:    [[V41:%.*]] = and i32 [[V40]], 290
; CHECK-NEXT:    [[V42:%.*]] = sub nuw nsw i32 [[V35]], [[V41]]
; CHECK-NEXT:    [[V43:%.*]] = add nuw i32 [[V42]], 1533579450
; CHECK-NEXT:    [[V45:%.*]] = xor i32 [[V43]], 749011377
; CHECK-NEXT:    ret i32 [[V45]]
;
  %v33 = and i32 %arg, 223
  %v34 = xor i32 %v33, 29
  %v35 = add nuw i32 %v34, 3510399223
  %v37 = or i32 %v34, 1874836915
  %v38 = and i32 %v34, 221
  %v39 = xor i32 %v38, 1874836915
  %v40 = xor i32 %v37, %v39
  %v41 = shl nsw nuw i32 %v40, 1
  %v42 = sub i32 %v35, %v41
  %v43 = add nsw i32 %v42, 1533579450
  %v44 = or i32 %v43, -2147483648
  %v45 = xor i32 %v44, 749011377
  ret i32 %v45
}

