; RUN: llc < %s -march=x86 -mtriple=i386-apple-darwin | FileCheck %s
; PR8297
;
; On i386, i64 cmpxchg is lowered during legalize types to extract the
; 64-bit result into a pair of fixed regs. So creation of the DAG node
; happens in a different place. See
; X86TargetLowering::ReplaceNodeResults, case ATOMIC_CMP_SWAP.
;
; Neither Atomic-xx.ll nor atomic_op.ll cover this. Those tests were
; autogenerated from C source before 64-bit variants were supported.
;
; Note that this case requires a loop around the cmpxchg to force
; machine licm to query alias anlysis, exposing a bad
; MachineMemOperand.
define void @foo(i64* %ptr) nounwind inlinehint {
entry:
  br label %loop
loop:
; CHECK: lock
; CHECK-NEXT: cmpxchg8b
  %r = call i64 @llvm.atomic.cmp.swap.i64.p0i64(i64* %ptr, i64 0, i64 1)
  %stored1  = icmp eq i64 %r, 0
  br i1 %stored1, label %loop, label %continue
continue:
  ret void
}

declare i64 @llvm.atomic.cmp.swap.i64.p0i64(i64* nocapture, i64, i64) nounwind
