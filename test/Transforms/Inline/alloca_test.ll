; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; This test ensures that alloca instructions in the entry block for an inlined
; function are moved to the top of the function they are inlined into.
;
; RUN: opt -S -inline < %s | FileCheck %s
; RUN: opt -S -passes='cgscc(inline)' < %s | FileCheck %s

define i32 @func(i32 %i) {
  %X = alloca i32
  store i32 %i, i32* %X
  ret i32 %i
}

declare void @bar()

define i32 @main(i32 %argc) {
; CHECK-LABEL: @main(
; CHECK-NEXT:  Entry:
; CHECK-NEXT:    [[X_I:%.*]] = alloca i32
;
Entry:
  call void @bar( )
  %X = call i32 @func( i32 7 )
  %Y = add i32 %X, %argc
  ret i32 %Y
}

; https://llvm.org/bugs/show_bug.cgi?id=27277
; Don't assume that the size is a ConstantInt (an undef value is also a constant).

define void @PR27277(i32 %p1) {
; CHECK-LABEL: @PR27277(
; CHECK-NEXT:    [[VLA:%.*]] = alloca double, i32 %p1
; CHECK-NEXT:    call void @PR27277(i32 undef)
; CHECK-NEXT:    ret void
;
  %vla = alloca double, i32 %p1
  call void @PR27277(i32 undef)
  ret void
}

; Don't assume that the size is a ConstantInt (a ConstExpr is also a constant).

@GV = common global i32* null

define void @PR27277_part2(i32 %p1) {
; CHECK-LABEL: @PR27277_part2(
; CHECK-NEXT:    [[VLA:%.*]] = alloca double, i32 %p1
; CHECK-NEXT:    call void @PR27277_part2(i32 ptrtoint (i32** @GV to i32))
; CHECK-NEXT:    ret void
;
  %vla = alloca double, i32 %p1
  call void @PR27277_part2(i32 ptrtoint (i32** @GV to i32))
  ret void
}

