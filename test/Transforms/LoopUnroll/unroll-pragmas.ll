; RUN: opt < %s -loop-unroll -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; loop4 contains a small loop which should be completely unrolled by
; the default unrolling heuristics.  It serves as a control for the
; unroll(disable) pragma test loop4_with_disable.
;
; CHECK-LABEL: @loop4(
; CHECK-NOT: br i1
define void @loop4(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 4
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret void
}

; #pragma clang loop unroll(disable)
;
; CHECK-LABEL: @loop4_with_disable(
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @loop4_with_disable(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 4
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !1

for.end:                                          ; preds = %for.body
  ret void
}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loopunroll.enable", i1 false}

; loop64 has a high enough count that it should *not* be unrolled by
; the default unrolling heuristic.  It serves as the control for the
; unroll(enable) pragma test loop64_with_.* tests below.
;
; CHECK-LABEL: @loop64(
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @loop64(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 64
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret void
}

; #pragma clang loop unroll(enable)
; Loop should be fully unrolled.
;
; CHECK-LABEL: @loop64_with_enable(
; CHECK-NOT: br i1
define void @loop64_with_enable(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 64
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !3

for.end:                                          ; preds = %for.body
  ret void
}
!3 = metadata !{metadata !3, metadata !4}
!4 = metadata !{metadata !"llvm.loopunroll.enable", i1 true}

; #pragma clang loop unroll_count(4)
; Loop should be unrolled 4 times.
;
; CHECK-LABEL: @loop64_with_count4(
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @loop64_with_count4(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 64
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !5

for.end:                                          ; preds = %for.body
  ret void
}
!5 = metadata !{metadata !5, metadata !6}
!6 = metadata !{metadata !"llvm.loopunroll.count", i32 4}


; #pragma clang loop unroll_count(enable) unroll_count(4)
; Loop should be unrolled 4 times.
;
; CHECK-LABEL: @loop64_with_enable_and_count4(
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @loop64_with_enable_and_count4(i32* nocapture %a) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 64
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !7

for.end:                                          ; preds = %for.body
  ret void
}
!7 = metadata !{metadata !7, metadata !6, metadata !4}

; #pragma clang loop unroll_count(enable)
; Full unrolling is requested, but loop has a dynamic trip count so
; no unrolling should occur.
;
; CHECK-LABEL: @dynamic_loop_with_enable(
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @dynamic_loop_with_enable(i32* nocapture %a, i32 %b) {
entry:
  %cmp3 = icmp sgt i32 %b, 0
  br i1 %cmp3, label %for.body, label %for.end, !llvm.loop !8

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %b
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !8

for.end:                                          ; preds = %for.body, %entry
  ret void
}
!8 = metadata !{metadata !8, metadata !4}

; #pragma clang loop unroll_count(4)
; Loop has a dynamic trip count.  Unrolling should occur, but no
; conditional branches can be removed.
;
; CHECK-LABEL: @dynamic_loop_with_count4(
; CHECK-NOT: store
; CHECK: br i1
; CHECK: store
; CHECK: br i1
; CHECK: store
; CHECK: br i1
; CHECK: store
; CHECK: br i1
; CHECK: store
; CHECK: br i1
; CHECK-NOT: br i1
define void @dynamic_loop_with_count4(i32* nocapture %a, i32 %b) {
entry:
  %cmp3 = icmp sgt i32 %b, 0
  br i1 %cmp3, label %for.body, label %for.end, !llvm.loop !9

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %b
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !9

for.end:                                          ; preds = %for.body, %entry
  ret void
}
!9 = metadata !{metadata !9, metadata !6}

; #pragma clang loop unroll_count(1)
; Loop should not be unrolled
;
; CHECK-LABEL: @unroll_1(
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @unroll_1(i32* nocapture %a, i32 %b) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 4
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !10

for.end:                                          ; preds = %for.body
  ret void
}
!10 = metadata !{metadata !10, metadata !11}
!11 = metadata !{metadata !"llvm.loopunroll.count", i32 1}

; #pragma clang loop unroll(enable)
; Loop has very high loop count (1 million) and full unrolling was requested.
; Loop should not be unrolled.
;
; CHECK-LABEL: @unroll_1M(
; CHECK: store i32
; CHECK-NOT: store i32
; CHECK: br i1
define void @unroll_1M(i32* nocapture %a, i32 %b) {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32* %a, i64 %indvars.iv
  %0 = load i32* %arrayidx, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 1000000
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !12

for.end:                                          ; preds = %for.body
  ret void
}
!12 = metadata !{metadata !12, metadata !4}
