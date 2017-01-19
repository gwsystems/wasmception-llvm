; RUN: llc -mtriple=aarch64 -global-isel -global-isel-abort=2 %s -o - | FileCheck %s

; CHECK-LABEL: test_asm:
; CHECK: {{APP|InlineAsm Start}}
; CHECK: mov x0, x0
; CHECK: {{NO_APP|InlineAsm End}}
define void @test_asm() {
  call void asm sideeffect "mov x0, x0", ""()
  ret void
}
