; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64_GISEL
; RUN: llc -mtriple=x86_64-linux-gnu              -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64

define i32* @test_gep_i8(i32 *%arr, i8 %ind) {
; X64_GISEL-LABEL: test_gep_i8:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    # kill: def $esi killed $esi def $rsi
; X64_GISEL-NEXT:    movq $56, %rcx
; X64_GISEL-NEXT:    # kill: def $cl killed $rcx
; X64_GISEL-NEXT:    shlq %cl, %rsi
; X64_GISEL-NEXT:    movq $56, %rcx
; X64_GISEL-NEXT:    # kill: def $cl killed $rcx
; X64_GISEL-NEXT:    movq $4, %rax
; X64_GISEL-NEXT:    sarq %cl, %rsi
; X64_GISEL-NEXT:    imulq %rax, %rsi
; X64_GISEL-NEXT:    leaq (%rdi,%rsi), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i8:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-NEXT:    movsbq %sil, %rax
; X64-NEXT:    leaq (%rdi,%rax,4), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i8 %ind
  ret i32* %arrayidx
}

define i32* @test_gep_i8_const(i32 *%arr) {
; X64_GISEL-LABEL: test_gep_i8_const:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $80, %rax
; X64_GISEL-NEXT:    leaq (%rdi,%rax), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i8_const:
; X64:       # %bb.0:
; X64-NEXT:    leaq 80(%rdi), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i8 20
  ret i32* %arrayidx
}

define i32* @test_gep_i16(i32 *%arr, i16 %ind) {
; X64_GISEL-LABEL: test_gep_i16:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    # kill: def $esi killed $esi def $rsi
; X64_GISEL-NEXT:    movq $48, %rcx
; X64_GISEL-NEXT:    # kill: def $cl killed $rcx
; X64_GISEL-NEXT:    shlq %cl, %rsi
; X64_GISEL-NEXT:    movq $48, %rcx
; X64_GISEL-NEXT:    # kill: def $cl killed $rcx
; X64_GISEL-NEXT:    movq $4, %rax
; X64_GISEL-NEXT:    sarq %cl, %rsi
; X64_GISEL-NEXT:    imulq %rax, %rsi
; X64_GISEL-NEXT:    leaq (%rdi,%rsi), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i16:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-NEXT:    movswq %si, %rax
; X64-NEXT:    leaq (%rdi,%rax,4), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i16 %ind
  ret i32* %arrayidx
}

define i32* @test_gep_i16_const(i32 *%arr) {
; X64_GISEL-LABEL: test_gep_i16_const:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $80, %rax
; X64_GISEL-NEXT:    leaq (%rdi,%rax), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i16_const:
; X64:       # %bb.0:
; X64-NEXT:    leaq 80(%rdi), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i16 20
  ret i32* %arrayidx
}

define i32* @test_gep_i32(i32 *%arr, i32 %ind) {
; X64_GISEL-LABEL: test_gep_i32:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $4, %rax
; X64_GISEL-NEXT:    movslq %esi, %rcx
; X64_GISEL-NEXT:    imulq %rax, %rcx
; X64_GISEL-NEXT:    leaq (%rdi,%rcx), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i32:
; X64:       # %bb.0:
; X64-NEXT:    movslq %esi, %rax
; X64-NEXT:    leaq (%rdi,%rax,4), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i32 %ind
  ret i32* %arrayidx
}

define i32* @test_gep_i32_const(i32 *%arr) {
; X64_GISEL-LABEL: test_gep_i32_const:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $20, %rax
; X64_GISEL-NEXT:    leaq (%rdi,%rax), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i32_const:
; X64:       # %bb.0:
; X64-NEXT:    leaq 20(%rdi), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i32 5
  ret i32* %arrayidx
}

define i32* @test_gep_i64(i32 *%arr, i64 %ind) {
; X64_GISEL-LABEL: test_gep_i64:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $4, %rax
; X64_GISEL-NEXT:    imulq %rsi, %rax
; X64_GISEL-NEXT:    leaq (%rdi,%rax), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i64:
; X64:       # %bb.0:
; X64-NEXT:    leaq (%rdi,%rsi,4), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i64 %ind
  ret i32* %arrayidx
}

define i32* @test_gep_i64_const(i32 *%arr) {
; X64_GISEL-LABEL: test_gep_i64_const:
; X64_GISEL:       # %bb.0:
; X64_GISEL-NEXT:    movq $20, %rax
; X64_GISEL-NEXT:    leaq (%rdi,%rax), %rax
; X64_GISEL-NEXT:    retq
;
; X64-LABEL: test_gep_i64_const:
; X64:       # %bb.0:
; X64-NEXT:    leaq 20(%rdi), %rax
; X64-NEXT:    retq
  %arrayidx = getelementptr i32, i32* %arr, i64 5
  ret i32* %arrayidx
}

