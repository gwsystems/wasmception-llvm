; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL

define i32 @test_or_i1(i32 %arg1, i32 %arg2) {
; ALL-LABEL: test_or_i1:
; ALL:       # %bb.0:
; ALL-NEXT:    cmpl %esi, %edi
; ALL-NEXT:    sete %al
; ALL-NEXT:    orb %al, %al
; ALL-NEXT:    movzbl %al, %eax
; ALL-NEXT:    andl $1, %eax
; ALL-NEXT:    retq
  %c = icmp eq i32 %arg1, %arg2
  %x = or i1 %c , %c
  %ret = zext i1 %x to i32
  ret i32 %ret
}

define i8 @test_or_i8(i8 %arg1, i8 %arg2) {
; ALL-LABEL: test_or_i8:
; ALL:       # %bb.0:
; ALL-NEXT:    orb %dil, %sil
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = or i8 %arg1, %arg2
  ret i8 %ret
}

define i16 @test_or_i16(i16 %arg1, i16 %arg2) {
; ALL-LABEL: test_or_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    orw %di, %si
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = or i16 %arg1, %arg2
  ret i16 %ret
}

define i32 @test_or_i32(i32 %arg1, i32 %arg2) {
; ALL-LABEL: test_or_i32:
; ALL:       # %bb.0:
; ALL-NEXT:    orl %edi, %esi
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = or i32 %arg1, %arg2
  ret i32 %ret
}

define i64 @test_or_i64(i64 %arg1, i64 %arg2) {
; ALL-LABEL: test_or_i64:
; ALL:       # %bb.0:
; ALL-NEXT:    orq %rdi, %rsi
; ALL-NEXT:    movq %rsi, %rax
; ALL-NEXT:    retq
  %ret = or i64 %arg1, %arg2
  ret i64 %ret
}

