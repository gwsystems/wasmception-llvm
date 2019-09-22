; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi | FileCheck %s --check-prefixes=CHECK,BEXTR-SLOW,BMI1,BMI1-SLOW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi,+bmi2 | FileCheck %s --check-prefixes=CHECK,BEXTR-SLOW,BMI2,BMI2-SLOW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi,+fast-bextr | FileCheck %s --check-prefixes=CHECK,BEXTR-FAST,BMI1,BMI1-FAST
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi,+bmi2,+fast-bextr | FileCheck %s --check-prefixes=CHECK,BEXTR-FAST,BMI2,BMI2-FAST

declare i64 @llvm.x86.bmi.bextr.64(i64, i64)

define i64 @bextr64(i64 %x, i64 %y)   {
; CHECK-LABEL: bextr64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bextrq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.bextr.64(i64 %x, i64 %y)
  ret i64 %tmp
}

define i64 @bextr64b(i64 %x)  uwtable  ssp {
; BEXTR-SLOW-LABEL: bextr64b:
; BEXTR-SLOW:       # %bb.0:
; BEXTR-SLOW-NEXT:    movq %rdi, %rax
; BEXTR-SLOW-NEXT:    shrl $4, %eax
; BEXTR-SLOW-NEXT:    andl $4095, %eax # imm = 0xFFF
; BEXTR-SLOW-NEXT:    retq
;
; BEXTR-FAST-LABEL: bextr64b:
; BEXTR-FAST:       # %bb.0:
; BEXTR-FAST-NEXT:    movl $3076, %eax # imm = 0xC04
; BEXTR-FAST-NEXT:    bextrl %eax, %edi, %eax
; BEXTR-FAST-NEXT:    retq
  %1 = lshr i64 %x, 4
  %2 = and i64 %1, 4095
  ret i64 %2
}

; Make sure we still use the AH subreg trick to extract 15:8
define i64 @bextr64_subreg(i64 %x)  uwtable  ssp {
; CHECK-LABEL: bextr64_subreg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    movzbl %ah, %eax
; CHECK-NEXT:    retq
  %1 = lshr i64 %x, 8
  %2 = and i64 %1, 255
  ret i64 %2
}

define i64 @bextr64b_load(i64* %x) {
; BEXTR-SLOW-LABEL: bextr64b_load:
; BEXTR-SLOW:       # %bb.0:
; BEXTR-SLOW-NEXT:    movl (%rdi), %eax
; BEXTR-SLOW-NEXT:    shrl $4, %eax
; BEXTR-SLOW-NEXT:    andl $4095, %eax # imm = 0xFFF
; BEXTR-SLOW-NEXT:    retq
;
; BEXTR-FAST-LABEL: bextr64b_load:
; BEXTR-FAST:       # %bb.0:
; BEXTR-FAST-NEXT:    movl $3076, %eax # imm = 0xC04
; BEXTR-FAST-NEXT:    bextrl %eax, (%rdi), %eax
; BEXTR-FAST-NEXT:    retq
  %1 = load i64, i64* %x, align 8
  %2 = lshr i64 %1, 4
  %3 = and i64 %2, 4095
  ret i64 %3
}

; PR34042
define i64 @bextr64c(i64 %x, i32 %y) {
; CHECK-LABEL: bextr64c:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $esi killed $esi def $rsi
; CHECK-NEXT:    bextrq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp0 = sext i32 %y to i64
  %tmp1 = tail call i64 @llvm.x86.bmi.bextr.64(i64 %x, i64 %tmp0)
  ret i64 %tmp1
}

define i64 @bextr64d(i64 %a) {
; BMI1-SLOW-LABEL: bextr64d:
; BMI1-SLOW:       # %bb.0: # %entry
; BMI1-SLOW-NEXT:    shrq $2, %rdi
; BMI1-SLOW-NEXT:    movl $8448, %eax # imm = 0x2100
; BMI1-SLOW-NEXT:    bextrq %rax, %rdi, %rax
; BMI1-SLOW-NEXT:    retq
;
; BMI2-SLOW-LABEL: bextr64d:
; BMI2-SLOW:       # %bb.0: # %entry
; BMI2-SLOW-NEXT:    movl $35, %eax
; BMI2-SLOW-NEXT:    bzhiq %rax, %rdi, %rax
; BMI2-SLOW-NEXT:    shrq $2, %rax
; BMI2-SLOW-NEXT:    retq
;
; BEXTR-FAST-LABEL: bextr64d:
; BEXTR-FAST:       # %bb.0: # %entry
; BEXTR-FAST-NEXT:    movl $8450, %eax # imm = 0x2102
; BEXTR-FAST-NEXT:    bextrq %rax, %rdi, %rax
; BEXTR-FAST-NEXT:    retq
entry:
  %shr = lshr i64 %a, 2
  %and = and i64 %shr, 8589934591
  ret i64 %and
}

define i64 @bextr64d_load(i64* %aptr) {
; BMI1-SLOW-LABEL: bextr64d_load:
; BMI1-SLOW:       # %bb.0: # %entry
; BMI1-SLOW-NEXT:    movq (%rdi), %rax
; BMI1-SLOW-NEXT:    shrq $2, %rax
; BMI1-SLOW-NEXT:    movl $8448, %ecx # imm = 0x2100
; BMI1-SLOW-NEXT:    bextrq %rcx, %rax, %rax
; BMI1-SLOW-NEXT:    retq
;
; BMI2-SLOW-LABEL: bextr64d_load:
; BMI2-SLOW:       # %bb.0: # %entry
; BMI2-SLOW-NEXT:    movl $35, %eax
; BMI2-SLOW-NEXT:    bzhiq %rax, (%rdi), %rax
; BMI2-SLOW-NEXT:    shrq $2, %rax
; BMI2-SLOW-NEXT:    retq
;
; BEXTR-FAST-LABEL: bextr64d_load:
; BEXTR-FAST:       # %bb.0: # %entry
; BEXTR-FAST-NEXT:    movl $8450, %eax # imm = 0x2102
; BEXTR-FAST-NEXT:    bextrq %rax, (%rdi), %rax
; BEXTR-FAST-NEXT:    retq
entry:
  %a = load i64, i64* %aptr, align 8
  %shr = lshr i64 %a, 2
  %and = and i64 %shr, 8589934591
  ret i64 %and
}

define i64 @non_bextr64(i64 %x) {
; CHECK-LABEL: non_bextr64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    shrq $2, %rdi
; CHECK-NEXT:    movabsq $8589934590, %rax # imm = 0x1FFFFFFFE
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %shr = lshr i64 %x, 2
  %and = and i64 %shr, 8589934590
  ret i64 %and
}
