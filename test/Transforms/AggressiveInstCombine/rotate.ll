; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -aggressive-instcombine -S | FileCheck %s

; https://bugs.llvm.org/show_bug.cgi?id=34924

define i32 @rotl(i32 %a, i32 %b) {
; CHECK-LABEL: @rotl(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[SHL]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[OR]], [[ROTBB]] ], [ [[A]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shr = lshr i32 %a, %sub
  %shl = shl i32 %a, %b
  %or = or i32 %shr, %shl
  br label %end

end:
  %cond = phi i32 [ %or, %rotbb ], [ %a, %entry ]
  ret i32 %cond
}

define i32 @rotl_commute_phi(i32 %a, i32 %b) {
; CHECK-LABEL: @rotl_commute_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[SHL]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[A]], [[ENTRY:%.*]] ], [ [[OR]], [[ROTBB]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shr = lshr i32 %a, %sub
  %shl = shl i32 %a, %b
  %or = or i32 %shr, %shl
  br label %end

end:
  %cond = phi i32 [ %a, %entry ], [ %or, %rotbb ]
  ret i32 %cond
}

define i32 @rotl_commute_or(i32 %a, i32 %b) {
; CHECK-LABEL: @rotl_commute_or(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHL]], [[SHR]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[A]], [[ENTRY:%.*]] ], [ [[OR]], [[ROTBB]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shr = lshr i32 %a, %sub
  %shl = shl i32 %a, %b
  %or = or i32 %shl, %shr
  br label %end

end:
  %cond = phi i32 [ %a, %entry ], [ %or, %rotbb ]
  ret i32 %cond
}

define i32 @rotr(i32 %a, i32 %b) {
; CHECK-LABEL: @rotr(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[SHL]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[OR]], [[ROTBB]] ], [ [[A]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shl = shl i32 %a, %sub
  %shr = lshr i32 %a, %b
  %or = or i32 %shr, %shl
  br label %end

end:
  %cond = phi i32 [ %or, %rotbb ], [ %a, %entry ]
  ret i32 %cond
}

define i32 @rotr_commute_phi(i32 %a, i32 %b) {
; CHECK-LABEL: @rotr_commute_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[SHL]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[A]], [[ENTRY:%.*]] ], [ [[OR]], [[ROTBB]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shl = shl i32 %a, %sub
  %shr = lshr i32 %a, %b
  %or = or i32 %shr, %shl
  br label %end

end:
  %cond = phi i32 [ %a, %entry ], [ %or, %rotbb ]
  ret i32 %cond
}

define i32 @rotr_commute_or(i32 %a, i32 %b) {
; CHECK-LABEL: @rotr_commute_or(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; CHECK:       rotbb:
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; CHECK-NEXT:    [[SHL:%.*]] = shl i32 [[A:%.*]], [[SUB]]
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 [[A]], [[B]]
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHL]], [[SHR]]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[COND:%.*]] = phi i32 [ [[A]], [[ENTRY:%.*]] ], [ [[OR]], [[ROTBB]] ]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shl = shl i32 %a, %sub
  %shr = lshr i32 %a, %b
  %or = or i32 %shl, %shr
  br label %end

end:
  %cond = phi i32 [ %a, %entry ], [ %or, %rotbb ]
  ret i32 %cond
}

