; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=-sse < %s | FileCheck %s

%struct.interrupt_frame = type { i64, i64, i64, i64, i64 }

@llvm.used = appending global [1 x i8*] [i8* bitcast (void (%struct.interrupt_frame*, i64)* @test_isr_sse_clobbers to i8*)], section "llvm.metadata"

; Clobbered SSE must not be saved when the target doesn't support SSE
define x86_intrcc void @test_isr_sse_clobbers(%struct.interrupt_frame* %frame, i64 %ecode) {
  ; CHECK-LABEL: test_isr_sse_clobbers:
  ; CHECK:       # BB#0:
  ; CHECK-NEXT:    cld
  ; CHECK-NEXT:    #APP
  ; CHECK-NEXT:    #NO_APP
  ; CHECK-NEXT:    addq $8, %rsp
  ; CHECK-NEXT:    iretq
  call void asm sideeffect "", "~{xmm0},~{xmm6}"()
  ret void
}
