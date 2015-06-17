; RUN: llc -march=hexagon < %s | FileCheck %s
; CHECK: min

define i32 @f(i32 %src, i32 %maxval) nounwind readnone {
entry:
  %cmp = icmp sgt i32 %maxval, %src
  %cond = select i1 %cmp, i32 %src, i32 %maxval
  ret i32 %cond
}
