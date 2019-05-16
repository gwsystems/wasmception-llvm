; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -dce -S | FileCheck %s

; LFTR should eliminate the need for the computation of i*i completely.  It
; is only used to compute the exit value.

; Provide legal integer types.
target datalayout = "n8:16:32:64"

@A = external global i32

define i32 @quadratic_setlt() {
; CHECK-LABEL: @quadratic_setlt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 7, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[I_NEXT]], 33
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret i32 32
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 7, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %i2 = mul i32 %i, %i
  %c = icmp slt i32 %i2, 1000
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret i32 %i
}


@data = common global [240 x i8] zeroinitializer, align 16

define void @test_zext(i8* %a) #0 {
; CHECK-LABEL: @test_zext(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[P_0:%.*]] = phi i8* [ getelementptr inbounds ([240 x i8], [240 x i8]* @data, i64 0, i64 0), [[ENTRY:%.*]] ], [ [[TMP3:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[DOT0:%.*]] = phi i8* [ [[A:%.*]], [[ENTRY]] ], [ [[TMP:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[TMP]] = getelementptr inbounds i8, i8* [[DOT0]], i64 1
; CHECK-NEXT:    [[TMP2:%.*]] = load i8, i8* [[DOT0]], align 1
; CHECK-NEXT:    [[TMP3]] = getelementptr inbounds i8, i8* [[P_0]], i64 1
; CHECK-NEXT:    store i8 [[TMP2]], i8* [[P_0]], align 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[TMP3]], getelementptr (i8, i8* getelementptr inbounds ([240 x i8], [240 x i8]* @data, i64 0, i64 0), i64 240)
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i.0 = phi i8 [ 0, %entry ], [ %tmp4, %loop ]
  %p.0 = phi i8* [ getelementptr inbounds ([240 x i8], [240 x i8]* @data, i64 0, i64 0), %entry ], [ %tmp3, %loop ]
  %.0 = phi i8* [ %a, %entry ], [ %tmp, %loop ]
  %tmp = getelementptr inbounds i8, i8* %.0, i64 1
  %tmp2 = load i8, i8* %.0, align 1
  %tmp3 = getelementptr inbounds i8, i8* %p.0, i64 1
  store i8 %tmp2, i8* %p.0, align 1
  %tmp4 = add i8 %i.0, 1
  %tmp5 = icmp ult i8 %tmp4, -16
  br i1 %tmp5, label %loop, label %exit

exit:
  ret void
}

; It is okay to do LFTR on this loop even though the trip count is a
; division because in this case the division can be optimized to a
; shift.
define void @test_udiv_as_shift(i8* %a, i8 %n) nounwind uwtable ssp {
; CHECK-LABEL: @test_udiv_as_shift(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[E:%.*]] = icmp sgt i8 [[N:%.*]], 3
; CHECK-NEXT:    br i1 [[E]], label [[LOOP_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = add i8 [[N]], 3
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i8 [[TMP0]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = add i8 [[TMP1]], 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I1:%.*]] = phi i8 [ [[I1_INC:%.*]], [[LOOP]] ], [ 0, [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[I1_INC]] = add nuw nsw i8 [[I1]], 1
; CHECK-NEXT:    store volatile i8 0, i8* [[A:%.*]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i8 [[I1_INC]], [[TMP2]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %e = icmp sgt i8 %n, 3
  br i1 %e, label %loop, label %exit

loop:
  %i = phi i8 [ 0, %entry ], [ %i.inc, %loop ]
  %i1 = phi i8 [ 0, %entry ], [ %i1.inc, %loop ]
  %i.inc = add nsw i8 %i, 4
  %i1.inc = add i8 %i1, 1
  store volatile i8 0, i8* %a
  %c = icmp slt i8 %i, %n
  br i1 %c, label %loop, label %exit

exit:
  ret void
}

; Don't RAUW the loop's original comparison instruction if it has other uses
; which aren't dominated by the new comparison instruction (which we insert
; at the branch user).
define void @use_before_branch() {
; CHECK-LABEL: @use_before_branch(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOPENTRY_0:%.*]]
; CHECK:       loopentry.0:
; CHECK-NEXT:    [[MB_Y_0:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[TMP_152:%.*]], [[LOOPENTRY_1:%.*]] ]
; CHECK-NEXT:    [[TMP_14:%.*]] = icmp ule i32 [[MB_Y_0]], 3
; CHECK-NEXT:    br i1 [[TMP_14]], label [[LOOPENTRY_1]], label [[LOOPEXIT_0:%.*]]
; CHECK:       loopentry.1:
; CHECK-NEXT:    [[TMP_152]] = add nuw nsw i32 [[MB_Y_0]], 2
; CHECK-NEXT:    br label [[LOOPENTRY_0]]
; CHECK:       loopexit.0:
; CHECK-NEXT:    unreachable
;
entry:
  br label %loopentry.0

loopentry.0:
  %mb_y.0 = phi i32 [ 0, %entry ], [ %tmp.152, %loopentry.1 ]
  %tmp.14 = icmp sle i32 %mb_y.0, 3
  %tmp.15 = zext i1 %tmp.14 to i32
  br i1 %tmp.14, label %loopentry.1, label %loopexit.0

loopentry.1:
  %tmp.152 = add i32 %mb_y.0, 2
  br label %loopentry.0

loopexit.0:		; preds = %loopentry.0
  unreachable
}

@.str3 = private constant [6 x i8] c"%lld\0A\00", align 1
declare i32 @printf(i8* noalias nocapture, ...) nounwind

; PR13371: indvars pass incorrectly substitutes 'undef' values
;
; LFTR should not user %undef as the loop counter.
define i64 @no_undef_counter() nounwind {
; CHECK-LABEL: @no_undef_counter(
; CHECK-NEXT:  func_start:
; CHECK-NEXT:    br label [[BLOCK9:%.*]]
; CHECK:       block9:
; CHECK-NEXT:    [[UNDEF:%.*]] = phi i64 [ [[NEXT_UNDEF:%.*]], [[BLOCK9]] ], [ undef, [[FUNC_START:%.*]] ]
; CHECK-NEXT:    [[ITER:%.*]] = phi i64 [ [[NEXT_ITER:%.*]], [[BLOCK9]] ], [ 1, [[FUNC_START]] ]
; CHECK-NEXT:    [[NEXT_ITER]] = add nuw nsw i64 [[ITER]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = tail call i32 (i8*, ...) @printf(i8* noalias nocapture getelementptr inbounds ([6 x i8], [6 x i8]* @.str3, i64 0, i64 0), i64 [[NEXT_ITER]], i64 [[UNDEF]])
; CHECK-NEXT:    [[NEXT_UNDEF]] = add nsw i64 [[UNDEF]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[NEXT_ITER]], 100
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[BLOCK9]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret i64 0
;
func_start:
  br label %block9
block9:                                           ; preds = %block9,%func_start
  %undef = phi i64 [ %next_undef, %block9 ], [ undef, %func_start ]
  %iter = phi i64 [ %next_iter, %block9 ], [ 1, %func_start ]
  %next_iter = add nsw i64 %iter, 1
  %0 = tail call i32 (i8*, ...) @printf(i8* noalias nocapture getelementptr inbounds ([6 x i8], [6 x i8]* @.str3, i64 0, i64 0), i64 %next_iter, i64 %undef)
  %next_undef = add nsw i64 %undef, 1
  %_tmp_3 = icmp slt i64 %next_iter, 100
  br i1 %_tmp_3, label %block9, label %exit
exit:                                             ; preds = %block9
  ret i64 0
}
