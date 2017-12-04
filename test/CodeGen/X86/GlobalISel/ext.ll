; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu    -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=X64
; RUN: llc -mtriple=i386-linux-gnu      -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=X32

define i8 @test_zext_i1toi8(i32 %a) {
; X64-LABEL: test_zext_i1toi8:
; X64:       # %bb.0:
; X64-NEXT:    andb $1, %dil
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_zext_i1toi8:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    andb $1, %al
; X32-NEXT:    # kill: %al<def> %al<kill> %eax<kill>
; X32-NEXT:    retl
  %val = trunc i32 %a to i1
  %r = zext i1 %val to i8
  ret i8 %r
}

define i16 @test_zext_i1toi16(i32 %a) {
; X64-LABEL: test_zext_i1toi16:
; X64:       # %bb.0:
; X64-NEXT:    andw $1, %di
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_zext_i1toi16:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    andw $1, %ax
; X32-NEXT:    # kill: %ax<def> %ax<kill> %eax<kill>
; X32-NEXT:    retl
  %val = trunc i32 %a to i1
  %r = zext i1 %val to i16
  ret i16 %r
}

define i32 @test_zext_i1(i32 %a) {
; X64-LABEL: test_zext_i1:
; X64:       # %bb.0:
; X64-NEXT:    andl $1, %edi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_zext_i1:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    andl $1, %eax
; X32-NEXT:    retl
  %val = trunc i32 %a to i1
  %r = zext i1 %val to i32
  ret i32 %r
}

define i32 @test_zext_i8(i8 %val) {
; X64-LABEL: test_zext_i8:
; X64:       # %bb.0:
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_zext_i8:
; X32:       # %bb.0:
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    retl
  %r = zext i8 %val to i32
  ret i32 %r
}

define i32 @test_zext_i16(i16 %val) {
; X64-LABEL: test_zext_i16:
; X64:       # %bb.0:
; X64-NEXT:    movzwl %di, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_zext_i16:
; X32:       # %bb.0:
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    retl
  %r = zext i16 %val to i32
  ret i32 %r
}

define i32 @test_sext_i8(i8 %val) {
; X64-LABEL: test_sext_i8:
; X64:       # %bb.0:
; X64-NEXT:    movsbl %dil, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_sext_i8:
; X32:       # %bb.0:
; X32-NEXT:    movsbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    retl
  %r = sext i8 %val to i32
  ret i32 %r
}

define i32 @test_sext_i16(i16 %val) {
; X64-LABEL: test_sext_i16:
; X64:       # %bb.0:
; X64-NEXT:    movswl %di, %eax
; X64-NEXT:    retq
;
; X32-LABEL: test_sext_i16:
; X32:       # %bb.0:
; X32-NEXT:    movswl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    retl
  %r = sext i16 %val to i32
  ret i32 %r
}

