; RUN: llc < %s -fast-isel

; Dont crash with gc intrinsics.

; gcrelocate call should not be an LLVM Machine Block by itself.
define i8 addrspace(1)* @test_gcrelocate(i8 addrspace(1)* %v) gc "statepoint-example" {
entry:
  %tok = call token (i64, i32, void ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_isVoidf(i64 0, i32 0, void ()* @foo, i32 0, i32 0, i32 0, i32 0, i8 addrspace(1)* %v)
  %vnew = call i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token %tok,  i32 7, i32 7)
  ret i8 addrspace(1)* %vnew
}

; gcresult calls are fine in their own blocks.
define i1 @test_gcresult() gc "statepoint-example" {
entry:
  %safepoint_token = tail call token (i64, i32, i1 ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_i1f(i64 0, i32 0, i1 ()* @return_i1, i32 0, i32 0, i32 0, i32 0)
  %call1 = call zeroext i1 @llvm.experimental.gc.result.i1(token %safepoint_token)
  ret i1 %call1
}

; we are okay here because we see the gcrelocate and avoid generating their own
; block.
define i1 @test_gcresult_gcrelocate(i8 addrspace(1)* %v) gc "statepoint-example" {
entry:
  %safepoint_token = tail call token (i64, i32, i1 ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_i1f(i64 0, i32 0, i1 ()* @return_i1, i32 0, i32 0, i32 0, i32 0, i8 addrspace(1)* %v)
  %call1 = call zeroext i1 @llvm.experimental.gc.result.i1(token %safepoint_token)
  %vnew = call i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token %safepoint_token,  i32 7, i32 7)
  ret i1 %call1
}

define i8 addrspace(1)*  @test_non_entry_block(i8 addrspace(1)* %v, i8 %val) gc "statepoint-example" {
entry:
 %load = load i8, i8 addrspace(1)* %v
 %cmp = icmp eq i8 %load, %val
 br i1 %cmp, label %func_call, label %exit

func_call:
 call void @dummy()
 %tok = call token (i64, i32, void ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_isVoidf(i64 0, i32 0, void ()* @foo, i32 0, i32 0, i32 0, i32 0, i8 addrspace(1)* %v)
 %vnew = call i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token %tok,  i32 7, i32 7)
 ret i8 addrspace(1)* %vnew

exit:
  ret i8 addrspace(1)* %v

}

declare void @dummy()
declare void @foo()

declare zeroext i1 @return_i1()
declare token @llvm.experimental.gc.statepoint.p0f_isVoidf(i64, i32, void ()*, i32, i32, ...)
declare token @llvm.experimental.gc.statepoint.p0f_i1f(i64, i32, i1 ()*, i32, i32, ...)
declare i1 @llvm.experimental.gc.result.i1(token)
declare i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token, i32, i32)
