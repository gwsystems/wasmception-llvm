; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -o - -structurizecfg < %s | FileCheck %s

define void @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       Flow:
; CHECK-NEXT:    br label [[FLOW1:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[CTR:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[CTR_NEXT:%.*]], [[FLOW1]] ]
; CHECK-NEXT:    [[CTR_NEXT]] = add i32 [[CTR]], 1
; CHECK-NEXT:    br i1 undef, label [[LOOP_A:%.*]], label [[FLOW1]]
; CHECK:       loop.a:
; CHECK-NEXT:    br i1 undef, label [[LOOP_B:%.*]], label [[FLOW:%.*]]
; CHECK:       loop.b:
; CHECK-NEXT:    br label [[FLOW]]
; CHECK:       Flow1:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i1 [ false, [[FLOW]] ], [ true, [[LOOP]] ]
; CHECK-NEXT:    br i1 [[TMP0]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %ctr = phi i32 [ 0, %entry ], [ %ctr.next, %loop.a ], [ %ctr.next, %loop.b ]
  %ctr.next = add i32 %ctr, 1
  br i1 undef, label %exit, label %loop.a

loop.a:
  br i1 undef, label %loop, label %loop.b

loop.b:
  br label %loop

exit:
  ret void
}
