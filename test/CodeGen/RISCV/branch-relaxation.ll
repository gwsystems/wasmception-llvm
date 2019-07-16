; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs -filetype=obj < %s \
; RUN:   -o /dev/null 2>&1
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s | FileCheck %s

define void @relax_bcc(i1 %a) nounwind {
; CHECK-LABEL: relax_bcc:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andi a0, a0, 1
; CHECK-NEXT:    bnez a0, .LBB0_1
; CHECK-NEXT:    j .LBB0_2
; CHECK-NEXT:  .LBB0_1: # %iftrue
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .space 4096
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:  .LBB0_2: # %tail
; CHECK-NEXT:    ret
  br i1 %a, label %iftrue, label %tail

iftrue:
  call void asm sideeffect ".space 4096", ""()
  br label %tail

tail:
  ret void
}

; TODO: Extend simm12's MCOperandPredicate so the jalr zero is printed as a jr.
define i32 @relax_jal(i1 %a) nounwind {
; CHECK-LABEL: relax_jal:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andi a0, a0, 1
; CHECK-NEXT:    bnez a0, .LBB1_1
; CHECK-NEXT:  # %bb.3:
; CHECK-NEXT:    lui a0, %hi(.LBB1_2)
; CHECK-NEXT:    jalr zero, %lo(.LBB1_2)(a0)
; CHECK-NEXT:  .LBB1_1: # %iftrue
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    #APP
; CHECK-NEXT:    .space 1048576
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    addi a0, zero, 1
; CHECK-NEXT:    ret
; CHECK-NEXT:  .LBB1_2: # %jmp
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    addi a0, zero, 1
; CHECK-NEXT:    ret
  br i1 %a, label %iftrue, label %jmp

jmp:
  call void asm sideeffect "", ""()
  br label %tail

iftrue:
  call void asm sideeffect "", ""()
  br label %space

space:
  call void asm sideeffect ".space 1048576", ""()
  br label %tail

tail:
  ret i32 1
}
