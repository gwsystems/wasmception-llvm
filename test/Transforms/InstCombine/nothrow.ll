; RUN: opt %s -instcombine | llvm-dis | not grep call
; rdar://6880732
declare double @t1(i32) readonly

define void @t2() nounwind {
  call double @t1(i32 42)  ;; dead call even though callee is not nothrow.
  ret void
}
