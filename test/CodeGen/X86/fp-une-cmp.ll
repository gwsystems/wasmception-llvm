; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

; <rdar://problem/7859988>

; Make sure we don't generate more jumps than we need to. We used to generate
; something like this:
;
;       jne  LBB0_1
;       jnp  LBB0_2
;   LBB0_1:
;       jmp  LBB0_3
;   LBB0_2:
;       addsd ...
;   LBB0_3:
;
; Now we generate this:
;
;       jne  LBB0_2
;       jp   LBB0_2
;       addsd ...
;   LBB0_2:

define double @rdar_7859988(double %x, double %y) nounwind readnone optsize ssp {
; CHECK-LABEL: rdar_7859988:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    mulsd %xmm1, %xmm0
; CHECK-NEXT:    xorpd %xmm1, %xmm1
; CHECK-NEXT:    ucomisd %xmm1, %xmm0
; CHECK-NEXT:    jne .LBB0_2
; CHECK-NEXT:    jp .LBB0_2
; CHECK-NEXT:  # BB#1: # %bb1
; CHECK-NEXT:    addsd {{.*}}(%rip), %xmm0
; CHECK-NEXT:  .LBB0_2: # %bb2
; CHECK-NEXT:    retq

entry:
  %mul = fmul double %x, %y
  %cmp = fcmp une double %mul, 0.000000e+00
  br i1 %cmp, label %bb2, label %bb1

bb1:
  %add = fadd double %mul, -1.000000e+00
  br label %bb2

bb2:
  %phi = phi double [ %add, %bb1 ], [ %mul, %entry ]
  ret double %phi
}

define double @profile_metadata(double %x, double %y) {
; CHECK-LABEL: profile_metadata:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    mulsd %xmm1, %xmm0
; CHECK-NEXT:    xorpd %xmm1, %xmm1
; CHECK-NEXT:    ucomisd %xmm1, %xmm0
; CHECK-NEXT:    jne .LBB1_1
; CHECK-NEXT:    jp .LBB1_1
; CHECK-NEXT:  .LBB1_2: # %bb2
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB1_1: # %bb1
; CHECK-NEXT:    addsd {{.*}}(%rip), %xmm0
; CHECK-NEXT:    jmp .LBB1_2

entry:
  %mul = fmul double %x, %y
  %cmp = fcmp une double %mul, 0.000000e+00
  br i1 %cmp, label %bb1, label %bb2, !prof !1

bb1:
  %add = fadd double %mul, -1.000000e+00
  br label %bb2

bb2:
  %phi = phi double [ %add, %bb1 ], [ %mul, %entry ]
  ret double %phi
}

; Test if the negation of the non-equality check between floating points are
; translated to jnp followed by jne.

define void @foo(float %f) {
; CHECK-LABEL: foo:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-NEXT:    jne .LBB2_2
; CHECK-NEXT:    jnp .LBB2_1
; CHECK-NEXT:  .LBB2_2: # %if.then
; CHECK-NEXT:    jmp a # TAILCALL
; CHECK-NEXT:  .LBB2_1: # %if.end
; CHECK-NEXT:    retq
entry:
  %cmp = fcmp une float %f, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.end

if.then:
  tail call void @a()
  br label %if.end

if.end:
  ret void
}

; Test that an FP oeq/une conditional branch can be inverted successfully even
; when the true and false targets are the same (PR27750).
; 
; CHECK-LABEL: pr27750
; CHECK: ucomiss
; CHECK-NEXT: jne [[TARGET:.*]]
; CHECK-NEXT: jp [[TARGET]]
define void @pr27750(i32* %b, float %x, i1 %y) {
entry:
  br label %for.cond

for.cond:
  br label %for.cond1

for.cond1:
  br i1 %y, label %for.body3.lr.ph, label %for.end

for.body3.lr.ph:
  store i32 0, i32* %b, align 4
  br label %for.end

for.end:
; After block %for.cond gets eliminated, the two target blocks of this
; conditional block are the same.
  %tobool = fcmp une float %x, 0.000000e+00
  br i1 %tobool, label %for.cond, label %for.cond1
}

declare void @a()

!1 = !{!"branch_weights", i32 1, i32 1000}
