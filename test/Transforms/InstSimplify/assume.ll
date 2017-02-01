; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt -instsimplify -S < %s | FileCheck %s

define void @test1() {
; CHECK-LABEL: @test1(
; CHECK:         ret void
;
  call void @llvm.assume(i1 1)
  ret void

}

; The alloca guarantees that the low bits of %a are zero because of alignment.
; The assume says the opposite. The assume is processed last, so that's the 
; return value. There's no way to win (we can't undo transforms that happened
; based on half-truths), so just don't crash.

define i64 @PR31809() {
; CHECK-LABEL: @PR31809(
; CHECK-NEXT:    ret i64 3
;
  %a = alloca i32
  %t1 = ptrtoint i32* %a to i64
  %cond = icmp eq i64 %t1, 3
  call void @llvm.assume(i1 %cond)
  ret i64 %t1
}

; Similar to above: there's no way to know which assumption is truthful,
; so just don't crash. The second icmp+assume gets processed later, so that
; determines the return value. This can be improved by permanently invalidating
; the cached assumptions for this function. 

define i8 @conflicting_assumptions(i8 %x) {
; CHECK-LABEL: @conflicting_assumptions(
; CHECK-NEXT:    call void @llvm.assume(i1 false)
; CHECK-NEXT:    [[COND2:%.*]] = icmp eq i8 %x, 4
; CHECK-NEXT:    call void @llvm.assume(i1 [[COND2]])
; CHECK-NEXT:    ret i8 5
;
  %add = add i8 %x, 1
  %cond1 = icmp eq i8 %x, 3
  call void @llvm.assume(i1 %cond1)
  %cond2 = icmp eq i8 %x, 4
  call void @llvm.assume(i1 %cond2)
  ret i8 %add
}

declare void @llvm.assume(i1) nounwind

