; RUN: llc < %s -march=x86-64 | FileCheck %s
; CHECK: addl

; The two additions are the same , but have different flags.
; In theory this code should never be generated by the frontend, but this 
; tries to test that two identical instructions with two different flags
; actually generate two different nodes.
;
; Normally the combiner would see this condition without the flags 
; and optimize the result of the sub into a register clear
; (the final result would be 0). With the different flags though the combiner 
; needs to keep the add + sub nodes, because the two nodes result as different
; nodes and so cannot assume that the subtraction of the two nodes
; generates 0 as result
define i32 @foo(i32 %a, i32 %b) {
  %1 = add i32 %a, %b
  %2 = add nsw i32 %a, %b
  %3 = sub i32 %1, %2
  ret i32 %3
}
