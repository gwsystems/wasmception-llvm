; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -loop-deletion -simplifycfg -S | FileCheck %s

; Testcase distilled from 256.bzip2
define i32 @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32 364
;
entry:
  br label %loopentry

loopentry:              ; preds = %loopentry, %entry
  %indvar1 = phi i32 [ 0, %entry ], [ %indvar.next2, %loopentry ]         ; <i32> [#uses=1]
  %h.0 = phi i32 [ %tmp.2, %loopentry ], [ 4, %entry ]            ; <i32> [#uses=1]
  %tmp.1 = mul i32 %h.0, 3                ; <i32> [#uses=1]
  %tmp.2 = add i32 %tmp.1, 1              ; <i32> [#uses=2]
  %indvar.next2 = add i32 %indvar1, 1             ; <i32> [#uses=2]
  %exitcond3 = icmp ne i32 %indvar.next2, 4               ; <i1> [#uses=1]
  br i1 %exitcond3, label %loopentry, label %loopexit

loopexit:               ; preds = %loopentry
  ret i32 %tmp.2
}

; PR12377
define i32 @test2(i32 %arg) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = icmp ugt i32 [[ARG:%.*]], 10
; CHECK-NEXT:    br i1 [[TMP]], label [[BB1_PREHEADER:%.*]], label [[BB7:%.*]]
; CHECK:       bb1.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[ARG]], -11
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw i32 [[TMP1]], 1
; CHECK-NEXT:    br label [[BB7]]
; CHECK:       bb7:
; CHECK-NEXT:    [[TMP8:%.*]] = phi i32 [ 0, [[BB:%.*]] ], [ [[TMP2]], [[BB1_PREHEADER]] ]
; CHECK-NEXT:    ret i32 [[TMP8]]
;
bb:
  %tmp = icmp ugt i32 %arg, 10
  br i1 %tmp, label %bb1, label %bb7

bb1:                                              ; preds = %bb1, %bb
  %tmp2 = phi i32 [ %tmp5, %bb1 ], [ 0, %bb ]
  %tmp3 = phi i32 [ %tmp4, %bb1 ], [ %arg, %bb ]
  %tmp4 = add i32 %tmp3, -2
  %tmp5 = add i32 %tmp2, 1
  %tmp6 = icmp ugt i32 %tmp4, 10
  br i1 %tmp6, label %bb1, label %bb7

bb7:                                              ; preds = %bb1, %bb
  %tmp8 = phi i32 [ 0, %bb ], [ %tmp5, %bb1 ]
  ret i32 %tmp8
}
