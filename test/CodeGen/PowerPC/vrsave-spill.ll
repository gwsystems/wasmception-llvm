; RUN: llc < %s -mtriple=powerpc64-unknown-linux-gnu -mcpu=g5 | FileCheck %s
target datalayout = "E-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v128:128:128-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

define <4 x float> @foo(<4 x float> %a, <4 x float> %b) nounwind {
entry:
  %c = fadd <4 x float> %a, %b
  call void asm sideeffect "", "~{VRsave}"() nounwind
  br label %return

; CHECK: @foo
; CHECK: mfspr {{[0-9]+}}, 256
; CHECK: mtspr 256, {{[0-9]+}}

return:                                           ; preds = %entry
  ret <4 x float> %c
}

