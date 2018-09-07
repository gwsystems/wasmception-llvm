; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32* @test1a(i32* %p, i32* %q) {
; CHECK-LABEL: @test1a(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32* [[P:%.*]], [[Q:%.*]]
; CHECK-NEXT:    [[SELECT_V:%.*]] = select i1 [[CMP]], i32* [[P]], i32* [[Q]]
; CHECK-NEXT:    [[SELECT:%.*]] = getelementptr i32, i32* [[SELECT_V]], i64 4
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr i32, i32* %p, i64 4
  %gep2 = getelementptr i32, i32* %q, i64 4
  %cmp = icmp ugt i32* %p, %q
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test1b(i32* %p, i32* %q) {
; CHECK-LABEL: @test1b(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32* [[P:%.*]], [[Q:%.*]]
; CHECK-NEXT:    [[SELECT_V:%.*]] = select i1 [[CMP]], i32* [[P]], i32* [[Q]]
; CHECK-NEXT:    [[SELECT:%.*]] = getelementptr i32, i32* [[SELECT_V]], i64 4
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds i32, i32* %p, i64 4
  %gep2 = getelementptr i32, i32* %q, i64 4
  %cmp = icmp ugt i32* %p, %q
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test1c(i32* %p, i32* %q) {
; CHECK-LABEL: @test1c(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32* [[P:%.*]], [[Q:%.*]]
; CHECK-NEXT:    [[SELECT_V:%.*]] = select i1 [[CMP]], i32* [[P]], i32* [[Q]]
; CHECK-NEXT:    [[SELECT:%.*]] = getelementptr i32, i32* [[SELECT_V]], i64 4
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr i32, i32* %p, i64 4
  %gep2 = getelementptr inbounds i32, i32* %q, i64 4
  %cmp = icmp ugt i32* %p, %q
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test1d(i32* %p, i32* %q) {
; CHECK-LABEL: @test1d(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32* [[P:%.*]], [[Q:%.*]]
; CHECK-NEXT:    [[SELECT_V:%.*]] = select i1 [[CMP]], i32* [[P]], i32* [[Q]]
; CHECK-NEXT:    [[SELECT:%.*]] = getelementptr inbounds i32, i32* [[SELECT_V]], i64 4
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds i32, i32* %p, i64 4
  %gep2 = getelementptr inbounds i32, i32* %q, i64 4
  %cmp = icmp ugt i32* %p, %q
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test2(i32* %p, i64 %x, i64 %y) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[SELECT_V:%.*]] = select i1 [[CMP]], i64 [[X]], i64 [[Y]]
; CHECK-NEXT:    [[SELECT:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 [[SELECT_V]]
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds i32, i32* %p, i64 %x
  %gep2 = getelementptr inbounds i32, i32* %p, i64 %y
  %cmp = icmp ugt i64 %x, %y
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

; Three (or more) operand GEPs are currently expected to not be optimised,
; though they could be in principle.

define i32* @test3a([4 x i32]* %p, i64 %x, i64 %y) {
; CHECK-LABEL: @test3a(
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds [4 x i32], [4 x i32]* [[P:%.*]], i64 2, i64 [[X:%.*]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds [4 x i32], [4 x i32]* [[P]], i64 2, i64 [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[X]], [[Y]]
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[CMP]], i32* [[GEP1]], i32* [[GEP2]]
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds [4 x i32], [4 x i32]* %p, i64 2, i64 %x
  %gep2 = getelementptr inbounds [4 x i32], [4 x i32]* %p, i64 2, i64 %y
  %cmp = icmp ugt i64 %x, %y
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test3b([4 x i32]* %p, i32* %q, i64 %x, i64 %y) {
; CHECK-LABEL: @test3b(
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds [4 x i32], [4 x i32]* [[P:%.*]], i64 [[X:%.*]], i64 2
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i32, i32* [[Q:%.*]], i64 [[X]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[X]], [[Y:%.*]]
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[CMP]], i32* [[GEP1]], i32* [[GEP2]]
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds [4 x i32], [4 x i32]* %p, i64 %x, i64 2
  %gep2 = getelementptr inbounds i32, i32* %q, i64 %x
  %cmp = icmp ugt i64 %x, %y
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

define i32* @test3c(i32* %p, [4 x i32]* %q, i64 %x, i64 %y) {
; CHECK-LABEL: @test3c(
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 [[X:%.*]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds [4 x i32], [4 x i32]* [[Q:%.*]], i64 [[X]], i64 2
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[X]], [[Y:%.*]]
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[CMP]], i32* [[GEP1]], i32* [[GEP2]]
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds i32, i32* %p, i64 %x
  %gep2 = getelementptr inbounds [4 x i32], [4 x i32]* %q, i64 %x, i64 2
  %cmp = icmp ugt i64 %x, %y
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

; Shouldn't be optimised as it would mean introducing an extra select

define i32* @test4(i32* %p, i32* %q, i64 %x, i64 %y) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 [[X:%.*]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i32, i32* [[Q:%.*]], i64 [[Y:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[X]], [[Y]]
; CHECK-NEXT:    [[SELECT:%.*]] = select i1 [[CMP]], i32* [[GEP1]], i32* [[GEP2]]
; CHECK-NEXT:    ret i32* [[SELECT]]
;
  %gep1 = getelementptr inbounds i32, i32* %p, i64 %x
  %gep2 = getelementptr inbounds i32, i32* %q, i64 %y
  %cmp = icmp ugt i64 %x, %y
  %select = select i1 %cmp, i32* %gep1, i32* %gep2
  ret i32* %select
}

; We cannot create a select with a vector condition but scalar operands.

define <2 x i64*> @test5(i64* %p1, i64* %p2, <2 x i64> %idx, <2 x i1> %cc) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i64, i64* %p1, <2 x i64> %idx
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i64, i64* %p2, <2 x i64> %idx
; CHECK-NEXT:    [[SELECT:%.*]] = select <2 x i1> %cc, <2 x i64*> [[GEP1]], <2 x i64*> [[GEP2]]
; CHECK-NEXT:    ret <2 x i64*> [[SELECT]]
;
  %gep1 = getelementptr i64, i64* %p1, <2 x i64> %idx
  %gep2 = getelementptr i64, i64* %p2, <2 x i64> %idx
  %select = select <2 x i1> %cc, <2 x i64*> %gep1, <2 x i64*> %gep2
  ret <2 x i64*> %select
}
