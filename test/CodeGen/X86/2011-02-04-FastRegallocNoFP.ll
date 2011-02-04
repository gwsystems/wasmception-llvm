; RUN: llc -O0 < %s | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-unknown-linux-gnu"

declare i32 @foo()

define i32 @bar() nounwind {
; CHECK: bar
; CHECK-NOT: pop.*ax
  %call = call i32 @foo()
  ret i32 %call
}

