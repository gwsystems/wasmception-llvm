;; A very basic test to make sure that splitting the backedge keeps working
;; RUN: opt -place-safepoints -spp-split-backedge=1 -S %s | FileCheck %s

define void @test(i32, i1 %cond) gc "statepoint-example" {
; CHECK-LABEL: @test
; CHECK-LABEL: loop.loop_crit_edge
; CHECK: gc.statepoint
; CHECK-NEXT: br label %loop
entry:
  br label %loop

loop:
  br i1 %cond, label %loop, label %exit

exit:
  ret void
}

; Test for the case where a single conditional branch jumps to two
; different loop header blocks.  Since we're currently using LoopSimplfy
; this doesn't hit the interesting case, but once we remove that, we need
; to be sure this keeps working.
define void @test2(i32, i1 %cond) gc "statepoint-example" {
; CHECK-LABEL: @test2
; CHECK-LABE: loop.loopexit.split
; CHECK: gc.statepoint
; CHECK-NEXT: br label %loop
; CHECK-LABEL: loop2.loop2_crit_edge
; CHECK: gc.statepoint
; CHECK-NEXT: br label %loop2
entry:
  br label %loop

loop:
  br label %loop2

loop2:
  br i1 %cond, label %loop, label %loop2
}

declare void @do_safepoint()
define void @gc.safepoint_poll() {
entry:
  call void @do_safepoint()
  ret void
}
