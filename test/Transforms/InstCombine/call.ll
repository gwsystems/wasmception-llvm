; Ignore stderr, we expect warnings there
; RUN: opt < %s -instcombine 2> /dev/null -S | FileCheck %s

target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

; Simple case, argument translatable without changing the value
declare void @test1a(i8*)

define void @test1(i32* %A) {
; CHECK-LABEL: @test1(
; CHECK: %1 = bitcast i32* %A to i8*
; CHECK: call void @test1a(i8* %1)
; CHECK: ret void
  call void bitcast (void (i8*)* @test1a to void (i32*)*)( i32* %A )
  ret void
}

; More complex case, translate argument because of resolution.  This is safe
; because we have the body of the function
define void @test2a(i8 %A) {
; CHECK-LABEL: @test2a(
; CHECK: ret void
  ret void
}

define i32 @test2(i32 %A) {
; CHECK-LABEL: @test2(
; CHECK: call void bitcast
; CHECK: ret i32 %A
  call void bitcast (void (i8)* @test2a to void (i32)*)( i32 %A )
  ret i32 %A
}


; Resolving this should insert a cast from sbyte to int, following the C
; promotion rules.
define void @test3a(i8, ...) {unreachable }

define void @test3(i8 %A, i8 %B) {
; CHECK-LABEL: @test3(
; CHECK: %1 = zext i8 %B to i32
; CHECK: call void (i8, ...)* @test3a(i8 %A, i32 %1)
; CHECK: ret void
  call void bitcast (void (i8, ...)* @test3a to void (i8, i8)*)( i8 %A, i8 %B)
  ret void
}

; test conversion of return value...
define i8 @test4a() {
; CHECK-LABEL: @test4a(
; CHECK: ret i8 0
  ret i8 0
}

define i32 @test4() {
; CHECK-LABEL: @test4(
; CHECK: call i32 bitcast
  %X = call i32 bitcast (i8 ()* @test4a to i32 ()*)( )            ; <i32> [#uses=1]
  ret i32 %X
}

; test conversion of return value... no value conversion occurs so we can do
; this with just a prototype...
declare i32 @test5a()

define i32 @test5() {
; CHECK-LABEL: @test5(
; CHECK: %X = call i32 @test5a()
; CHECK: ret i32 %X
  %X = call i32 @test5a( )                ; <i32> [#uses=1]
  ret i32 %X
}

; test addition of new arguments...
declare i32 @test6a(i32)

define i32 @test6() {
; CHECK-LABEL: @test6(
; CHECK: %X = call i32 @test6a(i32 0)
; CHECK: ret i32 %X
  %X = call i32 bitcast (i32 (i32)* @test6a to i32 ()*)( )
  ret i32 %X
}

; test removal of arguments, only can happen with a function body
define void @test7a() {
; CHECK-LABEL: @test7a(
; CHECK: ret void
  ret void
}

define void @test7() {
; CHECK-LABEL: @test7(
; CHECK: call void @test7a()
; CHECK: ret void
  call void bitcast (void ()* @test7a to void (i32)*)( i32 5 )
  ret void
}


; rdar://7590304
declare void @test8a()

define i8* @test8() {
; CHECK-LABEL: @test8(
; CHECK-NEXT: invoke void @test8a()
; Don't turn this into "unreachable": the callee and caller don't agree in
; calling conv, but the implementation of test8a may actually end up using the
; right calling conv.
  invoke void @test8a()
          to label %invoke.cont unwind label %try.handler

invoke.cont:                                      ; preds = %entry
  unreachable

try.handler:                                      ; preds = %entry
  %exn = landingpad {i8*, i32} personality i32 (...)* @__gxx_personality_v0
            cleanup
  ret i8* null
}

declare i32 @__gxx_personality_v0(...)


; Don't turn this into a direct call, because test9x is just a prototype and
; doing so will make it varargs.
; rdar://9038601
declare i8* @test9x(i8*, i8*, ...) noredzone
define i8* @test9(i8* %arg, i8* %tmp3) nounwind ssp noredzone {
; CHECK-LABEL: @test9
entry:
  %call = call i8* bitcast (i8* (i8*, i8*, ...)* @test9x to i8* (i8*, i8*)*)(i8* %arg, i8* %tmp3) noredzone
  ret i8* %call
; CHECK-LABEL: @test9(
; CHECK: call i8* bitcast
}

