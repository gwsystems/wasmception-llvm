; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu    -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=X64

; TODO merge with ext.ll after i64 sext supported on 32bit platform

define i64 @test_zext_i1(i8 %a) {
; X64-LABEL: test_zext_i1:
; X64:       # BB#0:
; X64-NEXT:    # kill: %edi<def> %edi<kill> %rdi<def>
; X64-NEXT:    andq $1, %rdi
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %val = trunc i8 %a to i1
  %r = zext i1 %val to i64
  ret i64 %r
}

define i64 @test_sext_i8(i8 %val) {
; X64-LABEL: test_sext_i8:
; X64:       # BB#0:
; X64-NEXT:    movsbq %dil, %rax
; X64-NEXT:    retq
  %r = sext i8 %val to i64
  ret i64 %r
}

define i64 @test_sext_i16(i16 %val) {
; X64-LABEL: test_sext_i16:
; X64:       # BB#0:
; X64-NEXT:    movswq %di, %rax
; X64-NEXT:    retq
  %r = sext i16 %val to i64
  ret i64 %r
}

; TODO enable after selection supported
;define i64 @test_sext_i32(i32 %val) {
;  %r = sext i32 %val to i64
;  ret i64 %r
;}

