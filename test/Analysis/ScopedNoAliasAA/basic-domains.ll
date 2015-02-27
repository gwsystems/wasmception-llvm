; RUN: opt < %s -basicaa -scoped-noalias -aa-eval -evaluate-aa-metadata -print-all-alias-modref-info -disable-output 2>&1 | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @foo1(float* nocapture %a, float* nocapture readonly %c) #0 {
entry:
; CHECK-LABEL: Function: foo1
  %0 = load float, float* %c, align 4, !alias.scope !9
  %arrayidx.i = getelementptr inbounds float, float* %a, i64 5
  store float %0, float* %arrayidx.i, align 4, !noalias !6

  %1 = load float, float* %c, align 4, !alias.scope !5
  %arrayidx.i2 = getelementptr inbounds float, float* %a, i64 15
  store float %1, float* %arrayidx.i2, align 4, !noalias !6

  %2 = load float, float* %c, align 4, !alias.scope !6
  %arrayidx.i3 = getelementptr inbounds float, float* %a, i64 16
  store float %2, float* %arrayidx.i3, align 4, !noalias !5

  ret void
}

attributes #0 = { nounwind uwtable }

!0 = !{!0, !"some domain"}
!1 = !{!1, !"some other domain"}

; Two scopes (which must be self-referential to avoid being "uniqued"):
!2 = !{!2, !0, !"a scope in dom0"}
!3 = !{!2}

!4 = !{!4, !0, !"another scope in dom0"}
!5 = !{!4}

; A list of the two scopes.
!6 = !{!2, !4}

; Another scope in the second domain
!7 = !{!7, !1, !"another scope in dom1"}
!8 = !{!7}

; A list of scopes from both domains.
!9 = !{!2, !4, !7}

; CHECK: NoAlias:   %0 = load float, float* %c, align 4, !alias.scope !0 <->   store float %0, float* %arrayidx.i, align 4, !noalias !6
; CHECK: NoAlias:   %0 = load float, float* %c, align 4, !alias.scope !0 <->   store float %1, float* %arrayidx.i2, align 4, !noalias !6
; CHECK: MayAlias:   %0 = load float, float* %c, align 4, !alias.scope !0 <->   store float %2, float* %arrayidx.i3, align 4, !noalias !7
; CHECK: NoAlias:   %1 = load float, float* %c, align 4, !alias.scope !7 <->   store float %0, float* %arrayidx.i, align 4, !noalias !6
; CHECK: NoAlias:   %1 = load float, float* %c, align 4, !alias.scope !7 <->   store float %1, float* %arrayidx.i2, align 4, !noalias !6
; CHECK: NoAlias:   %1 = load float, float* %c, align 4, !alias.scope !7 <->   store float %2, float* %arrayidx.i3, align 4, !noalias !7
; CHECK: NoAlias:   %2 = load float, float* %c, align 4, !alias.scope !6 <->   store float %0, float* %arrayidx.i, align 4, !noalias !6
; CHECK: NoAlias:   %2 = load float, float* %c, align 4, !alias.scope !6 <->   store float %1, float* %arrayidx.i2, align 4, !noalias !6
; CHECK: MayAlias:   %2 = load float, float* %c, align 4, !alias.scope !6 <->   store float %2, float* %arrayidx.i3, align 4, !noalias !7
; CHECK: NoAlias:   store float %1, float* %arrayidx.i2, align 4, !noalias !6 <->   store float %0, float* %arrayidx.i, align 4, !noalias !6
; CHECK: NoAlias:   store float %2, float* %arrayidx.i3, align 4, !noalias !7 <->   store float %0, float* %arrayidx.i, align 4, !noalias !6
; CHECK: NoAlias:   store float %2, float* %arrayidx.i3, align 4, !noalias !7 <->   store float %1, float* %arrayidx.i2, align 4, !noalias !6

