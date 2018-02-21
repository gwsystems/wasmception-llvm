; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; NOTE: clwb is available in Skylake Server, not available in the newer
; NOTE: Cannon Lake arch, but available again in the newer Ice Lake arch.
; RUN: llc < %s -mtriple=i686-apple-darwin -mattr=clwb | FileCheck %s
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=skx | FileCheck %s
; RUN: not llc < %s -mtriple=i686-apple-darwin -mcpu=cannonlake 2>&1 | FileCheck %s --check-prefix=CNL
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=icelake | FileCheck %s

; CNL: LLVM ERROR: Cannot select: intrinsic %llvm.x86.clwb

define void @clwb(i8* %p) nounwind {
; CHECK-LABEL: clwb:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    clwb (%eax)
; CHECK-NEXT:    retl
  tail call void @llvm.x86.clwb(i8* %p)
  ret void
}
declare void @llvm.x86.clwb(i8*) nounwind
