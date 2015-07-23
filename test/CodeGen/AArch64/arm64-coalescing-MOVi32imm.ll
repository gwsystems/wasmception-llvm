; RUN: llc < %s | FileCheck %s

; CHECK:        orr     w0, wzr, #0x1
; CHECK-NEXT :  bl      foo
; CHECK-NEXT :  orr     w0, wzr, #0x1
; CHECK-NEXT :  bl      foo

target triple = "aarch64--linux-android"
declare i32 @foo(i32)

; Function Attrs: nounwind uwtable
define i32 @main() {
entry:
  %call = tail call i32 @foo(i32 1)
  %call1 = tail call i32 @foo(i32 1)
  ret i32 0
}

