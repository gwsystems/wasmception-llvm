; RUN: llc < %s -march=x86 | FileCheck %s

declare {i32, i1} @llvm.umul.with.overflow.i32(i32 %a, i32 %b)
define i1 @a(i32 %x) zeroext nounwind {
  %res = call {i32, i1} @llvm.umul.with.overflow.i32(i32 %x, i32 3)
  %obil = extractvalue {i32, i1} %res, 1
  ret i1 %obil
  
; CHECK: a:
; CHECK: mull
; CHECK: seto %al
; CHECK: movzx	%al, %eax
; CHECK: ret
}
