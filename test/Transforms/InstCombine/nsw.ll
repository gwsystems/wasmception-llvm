; RUN: opt < %s -instcombine -S | FileCheck %s

; CHECK: @sub1
; CHECK: %y = sub i32 0, %x
; CHECK: %z = sdiv i32 %y, 337
; CHECK: ret i32 %z
define i32 @sub1(i32 %x) {
  %y = sub i32 0, %x
  %z = sdiv i32 %y, 337
  ret i32 %z
}

; CHECK: @sub2
; CHECK: %z = sdiv i32 %x, -337
; CHECK: ret i32 %z
define i32 @sub2(i32 %x) {
  %y = sub nsw i32 0, %x
  %z = sdiv i32 %y, 337
  ret i32 %z
}

; CHECK: @shl_icmp
; CHECK: %B = icmp eq i64 %X, 0
; CHECK: ret i1 %B
define i1 @shl_icmp(i64 %X) nounwind {
  %A = shl nuw i64 %X, 2   ; X/4
  %B = icmp eq i64 %A, 0
  ret i1 %B
}

