; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -indvars < %s | FileCheck %s
target datalayout = "n8:16:32:64"
@G = external global i32

; Basic case where we know the value of an induction variable along one
; exit edge, but not another.
define i32 @test(i32 %n) {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load volatile i32, i32* @G
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[LATCH]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[HEADER]], label [[EXIT2:%.*]]
; CHECK:       exit1:
; CHECK-NEXT:    [[IV_LCSSA:%.*]] = phi i32 [ [[IV]], [[HEADER]] ]
; CHECK-NEXT:    ret i32 [[IV_LCSSA]]
; CHECK:       exit2:
; CHECK-NEXT:    ret i32 [[N]]
;
entry:
  br label %header
header:
  %iv = phi i32 [0, %entry], [%iv.next, %latch]
  %v = load volatile i32, i32* @G
  %cmp1 = icmp eq i32 %v, 0
  br i1 %cmp1, label %latch, label %exit1

latch:
  %iv.next = add i32 %iv, 1
  %cmp2 = icmp ult i32 %iv, %n
  br i1 %cmp2, label %header, label %exit2
exit1:
  ret i32 %iv
exit2:
  ret i32 %iv
}

define i32 @test2(i32 %n) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load volatile i32, i32* @G
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[LATCH]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[HEADER]], label [[EXIT2:%.*]]
; CHECK:       exit1:
; CHECK-NEXT:    [[IV_LCSSA:%.*]] = phi i32 [ [[IV]], [[HEADER]] ]
; CHECK-NEXT:    ret i32 [[IV_LCSSA]]
; CHECK:       exit2:
; CHECK-NEXT:    ret i32 [[TMP0]]
;
entry:
  br label %header
header:
  %iv = phi i32 [0, %entry], [%iv.next, %latch]
  %v = load volatile i32, i32* @G
  %cmp1 = icmp eq i32 %v, 0
  br i1 %cmp1, label %latch, label %exit1

latch:
  %iv.next = add i32 %iv, 1
  %cmp2 = icmp ult i32 %iv, %n
  br i1 %cmp2, label %header, label %exit2
exit1:
  ret i32 %iv
exit2:
  ret i32 %iv.next
}

define i32 @neg_wrong_loop(i32 %n) {
; CHECK-LABEL: @neg_wrong_loop(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[WRONG_LOOP:%.*]]
; CHECK:       wrong_loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV2_NEXT:%.*]], [[WRONG_LOOP]] ]
; CHECK-NEXT:    [[IV2_NEXT]] = add i32 [[IV2]], 1
; CHECK-NEXT:    [[UNKNOWN:%.*]] = load volatile i32, i32* @G
; CHECK-NEXT:    [[CMP_UNK:%.*]] = icmp eq i32 [[UNKNOWN]], 0
; CHECK-NEXT:    br i1 [[CMP_UNK]], label [[HEADER_PREHEADER:%.*]], label [[WRONG_LOOP]]
; CHECK:       header.preheader:
; CHECK-NEXT:    [[IV2_LCSSA:%.*]] = phi i32 [ [[IV2]], [[WRONG_LOOP]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[HEADER_PREHEADER]] ], [ [[IV_NEXT:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load volatile i32, i32* @G
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[LATCH]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[HEADER]], label [[EXIT2:%.*]]
; CHECK:       exit1:
; CHECK-NEXT:    [[IV_LCSSA:%.*]] = phi i32 [ [[IV]], [[HEADER]] ]
; CHECK-NEXT:    ret i32 [[IV_LCSSA]]
; CHECK:       exit2:
; CHECK-NEXT:    [[EXITVAL:%.*]] = phi i32 [ [[IV2_LCSSA]], [[LATCH]] ]
; CHECK-NEXT:    ret i32 [[EXITVAL]]
;
entry:
  br label %wrong_loop

wrong_loop:
  %iv2 = phi i32 [0, %entry], [%iv2.next, %wrong_loop]
  %iv2.next = add i32 %iv2, 1
  %unknown = load volatile i32, i32* @G
  %cmp_unk = icmp eq i32 %unknown, 0
  br i1 %cmp_unk, label %header.preheader, label %wrong_loop

header.preheader:
  %iv2.lcssa = phi i32 [%iv2, %wrong_loop]
  br label %header

header:
  %iv = phi i32 [0, %header.preheader], [%iv.next, %latch]
  %v = load volatile i32, i32* @G
  %cmp1 = icmp eq i32 %v, 0
  br i1 %cmp1, label %latch, label %exit1

latch:
  %iv.next = add i32 %iv, 1
  %cmp2 = icmp ult i32 %iv, %n
  br i1 %cmp2, label %header, label %exit2
exit1:
  ret i32 %iv
exit2:
  %exitval = phi i32 [%iv2.lcssa, %latch]
  ret i32 %exitval
}

; TODO: Generalize the code to handle other SCEV expressions
define i32 @test3(i32 %n) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[EXPR:%.*]] = udiv i32 [[IV]], 5
; CHECK-NEXT:    [[V:%.*]] = load volatile i32, i32* @G
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[LATCH]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[HEADER]], label [[EXIT2:%.*]]
; CHECK:       exit1:
; CHECK-NEXT:    [[EXPR_LCSSA:%.*]] = phi i32 [ [[EXPR]], [[HEADER]] ]
; CHECK-NEXT:    ret i32 [[EXPR_LCSSA]]
; CHECK:       exit2:
; CHECK-NEXT:    [[EXPR_LCSSA1:%.*]] = phi i32 [ [[EXPR]], [[LATCH]] ]
; CHECK-NEXT:    ret i32 [[EXPR_LCSSA1]]
;
entry:
  br label %header
header:
  %iv = phi i32 [0, %entry], [%iv.next, %latch]
  %expr = udiv i32 %iv, 5
  %v = load volatile i32, i32* @G
  %cmp1 = icmp eq i32 %v, 0
  br i1 %cmp1, label %latch, label %exit1

latch:
  %iv.next = add i32 %iv, 1
  %cmp2 = icmp ult i32 %iv, %n
  br i1 %cmp2, label %header, label %exit2
exit1:
  ret i32 %expr
exit2:
  ret i32 %expr
}


; A slightly more real example where we're searching for either a) the first
; non-zero element, or b) the end of a memory region.
define i32 @bounded_find(i32 %n) {
; CHECK-LABEL: @bounded_find(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       header:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr i32, i32* @G, i32 [[IV]]
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[ADDR]]
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1]], label [[LATCH]], label [[EXIT1:%.*]]
; CHECK:       latch:
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[HEADER]], label [[EXIT2:%.*]]
; CHECK:       exit1:
; CHECK-NEXT:    [[IV_LCSSA:%.*]] = phi i32 [ [[IV]], [[HEADER]] ]
; CHECK-NEXT:    ret i32 [[IV_LCSSA]]
; CHECK:       exit2:
; CHECK-NEXT:    ret i32 [[N]]
;
entry:
  br label %header
header:
  %iv = phi i32 [0, %entry], [%iv.next, %latch]
  %addr = getelementptr i32, i32* @G, i32 %iv
  %v = load i32, i32* %addr
  %cmp1 = icmp eq i32 %v, 0
  br i1 %cmp1, label %latch, label %exit1

latch:
  %iv.next = add i32 %iv, 1
  %cmp2 = icmp ult i32 %iv, %n
  br i1 %cmp2, label %header, label %exit2
exit1:
  ret i32 %iv
exit2:
  ret i32 %iv
}
