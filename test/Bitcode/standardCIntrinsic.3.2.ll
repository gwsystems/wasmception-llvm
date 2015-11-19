; RUN:  llvm-dis < %s.bc| FileCheck %s

; standardCIntrinsic.3.2.ll.bc was generated by passing this file to llvm-as-3.2.
; The test checks that LLVM does not misread standard C library intrinsic functions
; of older bitcode files.

define void @memcpyintrinsic(i8* %dest, i8* %src, i32 %len) {
entry:

; CHECK: call void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src, i32 %len, i32 1, i1 true)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src, i32 %len, i32 1, i1 true)
  
  ret void
}

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src, i32 %len, i32 %align, i1 %isvolatile)