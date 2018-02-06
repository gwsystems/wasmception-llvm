; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefix=X64

; This test makes sure we do not merge both load-op-store pairs here as it causes a cycle.

define i8* @fn(i32 %i.015.i,  [64 x i64]* %data.i) {
; X32-LABEL: fn:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl (%ecx,%eax,8), %edx
; X32-NEXT:    addl $1, %edx
; X32-NEXT:    adcl $0, 4(%ecx,%eax,8)
; X32-NEXT:    movl %edx, (%ecx,%eax,8)
; X32-NEXT:    xorl %eax, %eax
; X32-NEXT:    retl
;
; X64-LABEL: fn:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movslq %edi, %rax
; X64-NEXT:    incq (%rsi,%rax,8)
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    retq
entry:
  %arrayidx.i6 = getelementptr inbounds [64 x i64], [64 x i64]* %data.i, i32 0, i32 %i.015.i
  %x8 = load volatile i64, i64* %arrayidx.i6, align 8
  %inc.i7 = add i64 %x8, 1
  store volatile i64 %inc.i7, i64* %arrayidx.i6, align 8
  ret i8* null
}

