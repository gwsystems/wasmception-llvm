; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 -mattr=+clwb | FileCheck %s --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skx | FileCheck %s --check-prefix=SKX

define void @clwb(i8* %a0) nounwind {
; GENERIC-LABEL: clwb:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    clwb (%rdi) # sched: [4:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; SKX-LABEL: clwb:
; SKX:       # %bb.0:
; SKX-NEXT:    clwb (%rdi) # sched: [5:0.50]
; SKX-NEXT:    retq # sched: [7:1.00]
  tail call void @llvm.x86.clwb(i8* %a0)
  ret void
}
declare void @llvm.x86.clwb(i8*) nounwind
