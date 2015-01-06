; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:32:32"
target triple = "i686-pc-linux-gnu"

define i32 @main() {
; CHECK-LABEL: @main
; CHECK: %[[call:.*]] = call i8* @ctime(i32* null)
; CHECK: %[[cast:.*]] = ptrtoint i8* %[[call]] to i32
; CHECK: ret i32 %[[cast]]
entry:
  %tmp = call i32 bitcast (i8* (i32*)* @ctime to i32 (i32*)*)( i32* null )          ; <i32> [#uses=1]
  ret i32 %tmp
}

declare i8* @ctime(i32*)

define internal { i8 } @foo(i32*) {
entry:
  ret { i8 } { i8 0 }
}

define void @test_struct_ret() {
; CHECK-LABEL: @test_struct_ret
; CHECK-NOT: bitcast
entry:
  %0 = call { i8 } bitcast ({ i8 } (i32*)* @foo to { i8 } (i16*)*)(i16* null)
  ret void
}

declare i32 @fn1(i32)

define i32 @test1(i32* %a) {
; CHECK-LABEL: @test1
; CHECK:      %[[cast:.*]] = ptrtoint i32* %a to i32
; CHECK-NEXT: %[[call:.*]] = tail call i32 @fn1(i32 %[[cast]])
; CHECK-NEXT: ret i32 %[[call]]
entry:
  %call = tail call i32 bitcast (i32 (i32)* @fn1 to i32 (i32*)*)(i32* %a)
  ret i32 %call
}

declare i32 @fn2(i16)

define i32 @test2(i32* %a) {
; CHECK-LABEL: @test2
; CHECK:      %[[call:.*]] = tail call i32 bitcast (i32 (i16)* @fn2 to i32 (i32*)*)(i32* %a)
; CHECK-NEXT: ret i32 %[[call]]
entry:
  %call = tail call i32 bitcast (i32 (i16)* @fn2 to i32 (i32*)*)(i32* %a)
  ret i32 %call
}

declare i32 @fn3(i64)

define i32 @test3(i32* %a) {
; CHECK-LABEL: @test3
; CHECK:      %[[call:.*]] = tail call i32 bitcast (i32 (i64)* @fn3 to i32 (i32*)*)(i32* %a)
; CHECK-NEXT: ret i32 %[[call]]
entry:
  %call = tail call i32 bitcast (i32 (i64)* @fn3 to i32 (i32*)*)(i32* %a)
  ret i32 %call
}
