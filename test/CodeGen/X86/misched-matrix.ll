; RUN: llc < %s -march=x86-64 -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched-topdown -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=TOPDOWN
; RUN: llc < %s -march=x86-64 -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched=ilpmin -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=ILPMIN
; RUN: llc < %s -march=x86-64 -mcpu=core2 -pre-RA-sched=source -enable-misched \
; RUN:          -misched=ilpmax -verify-machineinstrs \
; RUN:     | FileCheck %s -check-prefix=ILPMAX
;
; Verify that the MI scheduler minimizes register pressure for a
; uniform set of bottom-up subtrees (unrolled matrix multiply).
;
; For current top-down heuristics, ensure that some folded imulls have
; been reordered with the stores. This tests the scheduler's cheap
; alias analysis ability (that doesn't require any AliasAnalysis pass).
;
; TOPDOWN: %for.body
; TOPDOWN: movl %{{.*}}, (
; TOPDOWN: imull {{[0-9]*}}(
; TOPDOWN: movl %{{.*}}, 4(
; TOPDOWN: imull {{[0-9]*}}(
; TOPDOWN: movl %{{.*}}, 8(
; TOPDOWN: movl %{{.*}}, 12(
; TOPDOWN: %for.end
;
; For -misched=ilpmin, verify that each expression subtree is
; scheduled independently, and that the imull/adds are interleaved.
;
; ILPMIN: %for.body
; ILPMIN: movl %{{.*}}, (
; ILPMIN: imull
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: movl %{{.*}}, 4(
; ILPMIN: imull
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: movl %{{.*}}, 8(
; ILPMIN: imull
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: imull
; ILPMIN: addl
; ILPMIN: movl %{{.*}}, 12(
; ILPMIN: %for.end
;
; For -misched=ilpmax, verify that each expression subtree is
; scheduled independently, and that the imull/adds are clustered.
;
; ILPMAX: %for.body
; ILPMAX: movl %{{.*}}, (
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: movl %{{.*}}, 4(
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: movl %{{.*}}, 8(
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: imull
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: addl
; ILPMAX: movl %{{.*}}, 12(
; ILPMAX: %for.end

define void @mmult([4 x i32]* noalias nocapture %m1, [4 x i32]* noalias nocapture %m2,
[4 x i32]* noalias nocapture %m3) nounwind uwtable ssp {
entry:
  br label %for.body

for.body:                              ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx8 = getelementptr inbounds [4 x i32]* %m1, i64 %indvars.iv, i64 0
  %tmp = load i32* %arrayidx8, align 4, !tbaa !0
  %arrayidx12 = getelementptr inbounds [4 x i32]* %m2, i64 0, i64 0
  %tmp1 = load i32* %arrayidx12, align 4, !tbaa !0
  %arrayidx8.1 = getelementptr inbounds [4 x i32]* %m1, i64 %indvars.iv, i64 1
  %tmp2 = load i32* %arrayidx8.1, align 4, !tbaa !0
  %arrayidx12.1 = getelementptr inbounds [4 x i32]* %m2, i64 1, i64 0
  %tmp3 = load i32* %arrayidx12.1, align 4, !tbaa !0
  %arrayidx8.2 = getelementptr inbounds [4 x i32]* %m1, i64 %indvars.iv, i64 2
  %tmp4 = load i32* %arrayidx8.2, align 4, !tbaa !0
  %arrayidx12.2 = getelementptr inbounds [4 x i32]* %m2, i64 2, i64 0
  %tmp5 = load i32* %arrayidx12.2, align 4, !tbaa !0
  %arrayidx8.3 = getelementptr inbounds [4 x i32]* %m1, i64 %indvars.iv, i64 3
  %tmp6 = load i32* %arrayidx8.3, align 4, !tbaa !0
  %arrayidx12.3 = getelementptr inbounds [4 x i32]* %m2, i64 3, i64 0
  %tmp8 = load i32* %arrayidx8, align 4, !tbaa !0
  %arrayidx12.137 = getelementptr inbounds [4 x i32]* %m2, i64 0, i64 1
  %tmp9 = load i32* %arrayidx12.137, align 4, !tbaa !0
  %tmp10 = load i32* %arrayidx8.1, align 4, !tbaa !0
  %arrayidx12.1.1 = getelementptr inbounds [4 x i32]* %m2, i64 1, i64 1
  %tmp11 = load i32* %arrayidx12.1.1, align 4, !tbaa !0
  %tmp12 = load i32* %arrayidx8.2, align 4, !tbaa !0
  %arrayidx12.2.1 = getelementptr inbounds [4 x i32]* %m2, i64 2, i64 1
  %tmp13 = load i32* %arrayidx12.2.1, align 4, !tbaa !0
  %tmp14 = load i32* %arrayidx8.3, align 4, !tbaa !0
  %arrayidx12.3.1 = getelementptr inbounds [4 x i32]* %m2, i64 3, i64 1
  %tmp15 = load i32* %arrayidx12.3.1, align 4, !tbaa !0
  %tmp16 = load i32* %arrayidx8, align 4, !tbaa !0
  %arrayidx12.239 = getelementptr inbounds [4 x i32]* %m2, i64 0, i64 2
  %tmp17 = load i32* %arrayidx12.239, align 4, !tbaa !0
  %tmp18 = load i32* %arrayidx8.1, align 4, !tbaa !0
  %arrayidx12.1.2 = getelementptr inbounds [4 x i32]* %m2, i64 1, i64 2
  %tmp19 = load i32* %arrayidx12.1.2, align 4, !tbaa !0
  %tmp20 = load i32* %arrayidx8.2, align 4, !tbaa !0
  %arrayidx12.2.2 = getelementptr inbounds [4 x i32]* %m2, i64 2, i64 2
  %tmp21 = load i32* %arrayidx12.2.2, align 4, !tbaa !0
  %tmp22 = load i32* %arrayidx8.3, align 4, !tbaa !0
  %arrayidx12.3.2 = getelementptr inbounds [4 x i32]* %m2, i64 3, i64 2
  %tmp23 = load i32* %arrayidx12.3.2, align 4, !tbaa !0
  %tmp24 = load i32* %arrayidx8, align 4, !tbaa !0
  %arrayidx12.341 = getelementptr inbounds [4 x i32]* %m2, i64 0, i64 3
  %tmp25 = load i32* %arrayidx12.341, align 4, !tbaa !0
  %tmp26 = load i32* %arrayidx8.1, align 4, !tbaa !0
  %arrayidx12.1.3 = getelementptr inbounds [4 x i32]* %m2, i64 1, i64 3
  %tmp27 = load i32* %arrayidx12.1.3, align 4, !tbaa !0
  %tmp28 = load i32* %arrayidx8.2, align 4, !tbaa !0
  %arrayidx12.2.3 = getelementptr inbounds [4 x i32]* %m2, i64 2, i64 3
  %tmp29 = load i32* %arrayidx12.2.3, align 4, !tbaa !0
  %tmp30 = load i32* %arrayidx8.3, align 4, !tbaa !0
  %arrayidx12.3.3 = getelementptr inbounds [4 x i32]* %m2, i64 3, i64 3
  %tmp31 = load i32* %arrayidx12.3.3, align 4, !tbaa !0
  %tmp7 = load i32* %arrayidx12.3, align 4, !tbaa !0
  %mul = mul nsw i32 %tmp1, %tmp
  %mul.1 = mul nsw i32 %tmp3, %tmp2
  %mul.2 = mul nsw i32 %tmp5, %tmp4
  %mul.3 = mul nsw i32 %tmp7, %tmp6
  %mul.138 = mul nsw i32 %tmp9, %tmp8
  %mul.1.1 = mul nsw i32 %tmp11, %tmp10
  %mul.2.1 = mul nsw i32 %tmp13, %tmp12
  %mul.3.1 = mul nsw i32 %tmp15, %tmp14
  %mul.240 = mul nsw i32 %tmp17, %tmp16
  %mul.1.2 = mul nsw i32 %tmp19, %tmp18
  %mul.2.2 = mul nsw i32 %tmp21, %tmp20
  %mul.3.2 = mul nsw i32 %tmp23, %tmp22
  %mul.342 = mul nsw i32 %tmp25, %tmp24
  %mul.1.3 = mul nsw i32 %tmp27, %tmp26
  %mul.2.3 = mul nsw i32 %tmp29, %tmp28
  %mul.3.3 = mul nsw i32 %tmp31, %tmp30
  %add.1 = add nsw i32 %mul.1, %mul
  %add.2 = add nsw i32 %mul.2, %add.1
  %add.3 = add nsw i32 %mul.3, %add.2
  %add.1.1 = add nsw i32 %mul.1.1, %mul.138
  %add.2.1 = add nsw i32 %mul.2.1, %add.1.1
  %add.3.1 = add nsw i32 %mul.3.1, %add.2.1
  %add.1.2 = add nsw i32 %mul.1.2, %mul.240
  %add.2.2 = add nsw i32 %mul.2.2, %add.1.2
  %add.3.2 = add nsw i32 %mul.3.2, %add.2.2
  %add.1.3 = add nsw i32 %mul.1.3, %mul.342
  %add.2.3 = add nsw i32 %mul.2.3, %add.1.3
  %add.3.3 = add nsw i32 %mul.3.3, %add.2.3
  %arrayidx16 = getelementptr inbounds [4 x i32]* %m3, i64 %indvars.iv, i64 0
  store i32 %add.3, i32* %arrayidx16, align 4, !tbaa !0
  %arrayidx16.1 = getelementptr inbounds [4 x i32]* %m3, i64 %indvars.iv, i64 1
  store i32 %add.3.1, i32* %arrayidx16.1, align 4, !tbaa !0
  %arrayidx16.2 = getelementptr inbounds [4 x i32]* %m3, i64 %indvars.iv, i64 2
  store i32 %add.3.2, i32* %arrayidx16.2, align 4, !tbaa !0
  %arrayidx16.3 = getelementptr inbounds [4 x i32]* %m3, i64 %indvars.iv, i64 3
  store i32 %add.3.3, i32* %arrayidx16.3, align 4, !tbaa !0
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 4
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                        ; preds = %for.body
  ret void
}

!0 = metadata !{metadata !"int", metadata !1}
!1 = metadata !{metadata !"omnipotent char", metadata !2}
!2 = metadata !{metadata !"Simple C/C++ TBAA"}
