; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -simplifycfg -phi-node-folding-threshold=2 -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @test1(i32 %a, i32 %b, i32 %c) nounwind  {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    [[TMP2:%.*]] = icmp sgt i32 [[C:%.*]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[A:%.*]], 1
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[TMP2]], i32 [[TMP3]], i32 [[A]]
; CHECK-NEXT:    [[TMP4:%.*]] = select i1 [[TMP1]], i32 [[SPEC_SELECT]], i32 [[B]]
; CHECK-NEXT:    [[TMP5:%.*]] = sub i32 [[TMP4]], 1
; CHECK-NEXT:    ret i32 [[TMP5]]
;
entry:
  %tmp1 = icmp eq i32 %b, 0
  br i1 %tmp1, label %bb1, label %bb3

bb1:            ; preds = %entry
  %tmp2 = icmp sgt i32 %c, 1
  br i1 %tmp2, label %bb2, label %bb3

bb2:		; preds = bb1
  %tmp3 = add i32 %a, 1
  br label %bb3

bb3:		; preds = %bb2, %entry
  %tmp4 = phi i32 [ %b, %entry ], [ %a, %bb1 ], [ %tmp3, %bb2 ]
  %tmp5 = sub i32 %tmp4, 1
  ret i32 %tmp5
}

define i8* @test4(i1* %dummy, i8* %a, i8* %b) {
; Test that we don't speculate an arbitrarily large number of unfolded constant
; expressions.
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1* [[DUMMY:%.*]]
; CHECK-NEXT:    br i1 [[COND1]], label [[IF:%.*]], label [[END:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1* [[DUMMY]]
; CHECK-NEXT:    br i1 [[COND2]], label [[THEN:%.*]], label [[END]]
; CHECK:       then:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[X1:%.*]] = phi i8* [ [[A:%.*]], [[ENTRY:%.*]] ], [ [[B:%.*]], [[IF]] ], [ inttoptr (i64 1 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X2:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 2 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X3:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 3 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X4:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 4 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X5:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 5 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X6:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 6 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X7:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 7 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X8:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 8 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X9:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 9 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X10:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 10 to i8*), [[THEN]] ]
; CHECK-NEXT:    ret i8* [[X10]]
;

entry:
  %cond1 = load volatile i1, i1* %dummy
  br i1 %cond1, label %if, label %end

if:
  %cond2 = load volatile i1, i1* %dummy
  br i1 %cond2, label %then, label %end

then:
  br label %end

end:
  %x1 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 1 to i8*), %then ]
  %x2 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 2 to i8*), %then ]
  %x3 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 3 to i8*), %then ]
  %x4 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 4 to i8*), %then ]
  %x5 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 5 to i8*), %then ]
  %x6 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 6 to i8*), %then ]
  %x7 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 7 to i8*), %then ]
  %x8 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 8 to i8*), %then ]
  %x9 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 9 to i8*), %then ]
  %x10 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 10 to i8*), %then ]

  ret i8* %x10
}

define i32* @test5(i32 %a, i32 %b, i32 %c, i32* dereferenceable(10) %ptr1,
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP1]], label [[BB1:%.*]], label [[BB3:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP2:%.*]] = icmp sgt i32 [[C:%.*]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = load i32*, i32** [[PTR3:%.*]]
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[TMP2]], i32* [[TMP3]], i32* [[PTR2:%.*]]
; CHECK-NEXT:    ret i32* [[SPEC_SELECT]]
; CHECK:       bb3:
; CHECK-NEXT:    ret i32* [[PTR1:%.*]]
;
  i32* dereferenceable(10) %ptr2, i32** dereferenceable(10) %ptr3) nounwind {
entry:
  %tmp1 = icmp eq i32 %b, 0
  br i1 %tmp1, label %bb1, label %bb3

bb1:            ; preds = %entry
  %tmp2 = icmp sgt i32 %c, 1
  br i1 %tmp2, label %bb2, label %bb3

bb2:		; preds = bb1
  %tmp3 = load i32*, i32** %ptr3, !dereferenceable !{i64 10}
  br label %bb3

bb3:		; preds = %bb2, %entry
  %tmp4 = phi i32* [ %ptr1, %entry ], [ %ptr2, %bb1 ], [ %tmp3, %bb2 ]
  ret i32* %tmp4
}
