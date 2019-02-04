; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv6m-eabi -asm-verbose=false %s -o - | FileCheck %s --check-prefix=V6M

define i32 @uxth(i32 %x) {
; V6M-LABEL: uxth:
; V6M:         uxth r0, r0
; V6M-NEXT:    bx lr
  %xn = and i32 %x, 65535
  ret i32 %xn
}

define i32 @uxtb(i32 %x) {
; V6M-LABEL: uxtb:
; V6M:         uxtb r0, r0
; V6M-NEXT:    bx lr
  %xn = and i32 %x, 255
  ret i32 %xn
}

define i32 @uxth_2(i32 %x, i32 %y) {
; V6M-LABEL: uxth_2:
; V6M:         uxth r1, r1
; V6M-NEXT:    uxth r0, r0
; V6M-NEXT:    muls r0, r1, r0
; V6M-NEXT:    bx lr
  %xn = and i32 %x, 65535
  %yn = and i32 %y, 65535
  %r = mul nuw i32 %xn, %yn
  ret i32 %r
}

define i32 @uxtb_2(i32 %x, i32 %y) {
; V6M-LABEL: uxtb_2:
; V6M:         uxtb r1, r1
; V6M-NEXT:    uxtb r0, r0
; V6M-NEXT:    muls r0, r1, r0
; V6M-NEXT:    bx lr
  %xn = and i32 %x, 255
  %yn = and i32 %y, 255
  %r = mul nuw nsw i32 %xn, %yn
  ret i32 %r
}

define void @uxth_loop(i32* %a, i32 %n) {
; V6M-LABEL: uxth_loop:
; V6M:       .LBB4_1:
; V6M-NEXT:    ldrh r2, [r0]
; V6M-NEXT:    stm r0!, {r2}
; V6M-NEXT:    subs r1, r1, #1
; V6M-NEXT:    bne .LBB4_1
; V6M-NEXT:    bx lr
entry:
  br label %for.body

for.body:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %a, i32 %i
  %x = load i32, i32* %arrayidx
  %xn = and i32 %x, 65535
  store i32 %xn, i32* %arrayidx
  %inc = add nuw nsw i32 %i, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}

define void @uxth_loop_2(i32* %a, i32 %n) {
; V6M-LABEL: uxth_loop_2:
; V6M:         .save {r4, lr}
; V6M-NEXT:    push {r4, lr}
; V6M-NEXT:    movs r2, #0
; V6M-NEXT:  .LBB5_1:
; V6M-NEXT:    uxth r3, r2
; V6M-NEXT:    ldrh r4, [r0]
; V6M-NEXT:    muls r4, r3, r4
; V6M-NEXT:    stm r0!, {r4}
; V6M-NEXT:    adds r2, r2, #1
; V6M-NEXT:    cmp r1, r2
; V6M-NEXT:    bne .LBB5_1
; V6M-NEXT:    pop {r4, pc}
entry:
  br label %for.body

for.body:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %a, i32 %i
  %x = load i32, i32* %arrayidx
  %xn = and i32 %x, 65535
  %in = and i32 %i, 65535
  %s = mul i32 %xn, %in
  store i32 %s, i32* %arrayidx
  %inc = add nuw nsw i32 %i, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}

define void @uxtb_loop(i32* %a, i32 %n) {
; V6M-LABEL: uxtb_loop:
; V6M:       .LBB6_1:
; V6M-NEXT:    ldrb r2, [r0]
; V6M-NEXT:    stm r0!, {r2}
; V6M-NEXT:    subs r1, r1, #1
; V6M-NEXT:    bne .LBB6_1
; V6M-NEXT:    bx lr
entry:
  br label %for.body

for.body:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %a, i32 %i
  %x = load i32, i32* %arrayidx
  %xn = and i32 %x, 255
  store i32 %xn, i32* %arrayidx
  %inc = add nuw nsw i32 %i, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}

define void @uxtb_loop_2(i32* %a, i32 %n) {
; V6M-LABEL: uxtb_loop_2:
; V6M:         .save {r4, lr}
; V6M-NEXT:    push {r4, lr}
; V6M-NEXT:    movs r2, #0
; V6M-NEXT:  .LBB7_1:
; V6M-NEXT:    uxtb r3, r2
; V6M-NEXT:    ldrb r4, [r0]
; V6M-NEXT:    muls r4, r3, r4
; V6M-NEXT:    stm r0!, {r4}
; V6M-NEXT:    adds r2, r2, #1
; V6M-NEXT:    cmp r1, r2
; V6M-NEXT:    bne .LBB7_1
; V6M-NEXT:    pop {r4, pc}
entry:
  br label %for.body

for.body:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %a, i32 %i
  %x = load i32, i32* %arrayidx
  %xn = and i32 %x, 255
  %in = and i32 %i, 255
  %s = mul i32 %xn, %in
  store i32 %s, i32* %arrayidx
  %inc = add nuw nsw i32 %i, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body

for.cond.cleanup:
  ret void
}

