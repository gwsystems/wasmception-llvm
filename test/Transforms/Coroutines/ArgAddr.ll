; Need to move users of allocas that were moved into the coroutine frame after
; coro.begin.
; RUN: opt < %s -O2 -enable-coroutines -S | FileCheck %s

define nonnull i8* @f(i32 %n) {
entry:
  %id = call token @llvm.coro.id(i32 0, i8* null, i8* null, i8* null);
  %n.addr = alloca i32
  store i32 %n, i32* %n.addr ; this needs to go after coro.begin
  %0 = tail call i32 @llvm.coro.size.i32()
  %call = tail call i8* @malloc(i32 %0)
  %1 = tail call noalias nonnull i8* @llvm.coro.begin(token %id, i8* %call)
  %2 = bitcast i32* %n.addr to i8*
  call void @ctor(i8* %2)
  br label %for.cond

for.cond:
  %3 = load i32, i32* %n.addr
  %dec = add nsw i32 %3, -1
  store i32 %dec, i32* %n.addr
  call void @print(i32 %3)
  %4 = call i8 @llvm.coro.suspend(token none, i1 false)
  %conv = sext i8 %4 to i32
  switch i32 %conv, label %coro_Suspend [
    i32 0, label %for.cond
    i32 1, label %coro_Cleanup
  ]

coro_Cleanup:
  %5 = call i8* @llvm.coro.free(token %id, i8* nonnull %1)
  call void @free(i8* %5)
  br label %coro_Suspend

coro_Suspend:
  call void @llvm.coro.end(i8* null, i1 false)
  ret i8* %1
}

; CHECK-LABEL: @main
define i32 @main() {
entry:
  %hdl = call i8* @f(i32 4)
  call void @llvm.coro.resume(i8* %hdl)
  call void @llvm.coro.resume(i8* %hdl)
  call void @llvm.coro.destroy(i8* %hdl)
  ret i32 0
; CHECK:      call void @ctor
; CHECK-NEXT: call void @print(i32 4)
; CHECK-NEXT: call void @print(i32 3)
; CHECK-NEXT: call void @print(i32 2)
; CHECK:      ret i32 0
}

declare i8* @malloc(i32)
declare void @free(i8*)
declare void @print(i32)
declare void @ctor(i8* nocapture readonly)

declare token @llvm.coro.id(i32, i8*, i8*, i8*)
declare i32 @llvm.coro.size.i32()
declare i8* @llvm.coro.begin(token, i8*)
declare i8 @llvm.coro.suspend(token, i1)
declare i8* @llvm.coro.free(token, i8*)
declare void @llvm.coro.end(i8*, i1)

declare void @llvm.coro.resume(i8*)
declare void @llvm.coro.destroy(i8*)
