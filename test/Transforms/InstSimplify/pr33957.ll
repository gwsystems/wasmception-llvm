; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -loop-unroll -S %s | FileCheck %s

%struct.bar = type { i32 }

@global = external constant [78 x %struct.bar], align 4

define void @patatino(i32 %x) {
; CHECK-LABEL: @patatino(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br i1 true, label [[BB1_PREHEADER:%.*]], label [[BB3:%.*]]
; CHECK:       bb1.preheader:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    ret void
;
bb:
  br i1 true, label %bb1, label %bb3

bb1:
  %tmp = getelementptr inbounds [78 x %struct.bar], [78 x %struct.bar]* @global, i32 0, <4 x i32> undef
  %tmp2 = getelementptr inbounds %struct.bar, <4 x %struct.bar*> %tmp, i32 1
  br i1 true, label %bb3, label %bb1

bb3:
  ret void
}
