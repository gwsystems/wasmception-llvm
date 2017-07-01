; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mcpu=core-avx-i -mattr=+rdrnd | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=core-avx-i -mattr=+rdrnd | FileCheck %s --check-prefix=X64

declare {i16, i32} @llvm.x86.rdrand.16()
declare {i32, i32} @llvm.x86.rdrand.32()

define i32 @_rdrand16_step(i16* %random_val) {
; X86-LABEL: _rdrand16_step:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    rdrandw %ax
; X86-NEXT:    movzwl %ax, %edx
; X86-NEXT:    movl $1, %eax
; X86-NEXT:    cmovael %edx, %eax
; X86-NEXT:    movw %dx, (%ecx)
; X86-NEXT:    retl
;
; X64-LABEL: _rdrand16_step:
; X64:       # BB#0:
; X64-NEXT:    rdrandw %ax
; X64-NEXT:    movzwl %ax, %ecx
; X64-NEXT:    movl $1, %eax
; X64-NEXT:    cmovael %ecx, %eax
; X64-NEXT:    movw %cx, (%rdi)
; X64-NEXT:    retq
  %call = call {i16, i32} @llvm.x86.rdrand.16()
  %randval = extractvalue {i16, i32} %call, 0
  store i16 %randval, i16* %random_val
  %isvalid = extractvalue {i16, i32} %call, 1
  ret i32 %isvalid
}

define i32 @_rdrand32_step(i32* %random_val) {
; X86-LABEL: _rdrand32_step:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    rdrandl %edx
; X86-NEXT:    movl $1, %eax
; X86-NEXT:    cmovael %edx, %eax
; X86-NEXT:    movl %edx, (%ecx)
; X86-NEXT:    retl
;
; X64-LABEL: _rdrand32_step:
; X64:       # BB#0:
; X64-NEXT:    rdrandl %ecx
; X64-NEXT:    movl $1, %eax
; X64-NEXT:    cmovael %ecx, %eax
; X64-NEXT:    movl %ecx, (%rdi)
; X64-NEXT:    retq
  %call = call {i32, i32} @llvm.x86.rdrand.32()
  %randval = extractvalue {i32, i32} %call, 0
  store i32 %randval, i32* %random_val
  %isvalid = extractvalue {i32, i32} %call, 1
  ret i32 %isvalid
}

; Check that MachineCSE doesn't eliminate duplicate rdrand instructions.
define i32 @CSE() nounwind {
; X86-LABEL: CSE:
; X86:       # BB#0:
; X86-NEXT:    rdrandl %ecx
; X86-NEXT:    rdrandl %eax
; X86-NEXT:    addl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: CSE:
; X64:       # BB#0:
; X64-NEXT:    rdrandl %ecx
; X64-NEXT:    rdrandl %eax
; X64-NEXT:    addl %ecx, %eax
; X64-NEXT:    retq
 %rand1 = tail call { i32, i32 } @llvm.x86.rdrand.32() nounwind
 %v1 = extractvalue { i32, i32 } %rand1, 0
 %rand2 = tail call { i32, i32 } @llvm.x86.rdrand.32() nounwind
 %v2 = extractvalue { i32, i32 } %rand2, 0
 %add = add i32 %v2, %v1
 ret i32 %add
}

; Check that MachineLICM doesn't hoist rdrand instructions.
define void @loop(i32* %p, i32 %n) nounwind {
; X86-LABEL: loop:
; X86:       # BB#0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    je .LBB3_3
; X86-NEXT:  # BB#1: # %while.body.preheader
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB3_2: # %while.body
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    rdrandl %edx
; X86-NEXT:    movl %edx, (%ecx)
; X86-NEXT:    leal 4(%ecx), %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB3_2
; X86-NEXT:  .LBB3_3: # %while.end
; X86-NEXT:    retl
;
; X64-LABEL: loop:
; X64:       # BB#0: # %entry
; X64-NEXT:    testl %esi, %esi
; X64-NEXT:    je .LBB3_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB3_1: # %while.body
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    rdrandl %eax
; X64-NEXT:    movl %eax, (%rdi)
; X64-NEXT:    leaq 4(%rdi), %rdi
; X64-NEXT:    decl %esi
; X64-NEXT:    jne .LBB3_1
; X64-NEXT:  .LBB3_2: # %while.end
; X64-NEXT:    retq
entry:
  %tobool1 = icmp eq i32 %n, 0
  br i1 %tobool1, label %while.end, label %while.body

while.body:                                       ; preds = %entry, %while.body
  %p.addr.03 = phi i32* [ %incdec.ptr, %while.body ], [ %p, %entry ]
  %n.addr.02 = phi i32 [ %dec, %while.body ], [ %n, %entry ]
  %dec = add nsw i32 %n.addr.02, -1
  %incdec.ptr = getelementptr inbounds i32, i32* %p.addr.03, i64 1
  %rand = tail call { i32, i32 } @llvm.x86.rdrand.32() nounwind
  %v1 = extractvalue { i32, i32 } %rand, 0
  store i32 %v1, i32* %p.addr.03, align 4
  %tobool = icmp eq i32 %dec, 0
  br i1 %tobool, label %while.end, label %while.body

while.end:                                        ; preds = %while.body, %entry
  ret void
}
