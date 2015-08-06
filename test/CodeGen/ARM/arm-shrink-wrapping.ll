; RUN: llc %s -o - -enable-shrink-wrap=true -ifcvt-fn-start=1 -ifcvt-fn-stop=0 -mtriple=armv7-apple-ios \
; RUN:      | FileCheck %s --check-prefix=CHECK --check-prefix=ARM --check-prefix=ENABLE --check-prefix=ARM-ENABLE
; RUN: llc %s -o - -enable-shrink-wrap=false -ifcvt-fn-start=1 -ifcvt-fn-stop=0 -mtriple=armv7-apple-ios \
; RUN:      | FileCheck %s --check-prefix=CHECK --check-prefix=ARM --check-prefix=DISABLE --check-prefix=ARM-DISABLE
; RUN: llc %s -o - -enable-shrink-wrap=true -ifcvt-fn-start=1 -ifcvt-fn-stop=0 -mtriple=thumbv7-apple-ios \
; RUN:      | FileCheck %s --check-prefix=CHECK --check-prefix=THUMB --check-prefix=ENABLE --check-prefix=THUMB-ENABLE
; RUN: llc %s -o - -enable-shrink-wrap=false -ifcvt-fn-start=1 -ifcvt-fn-stop=0 -mtriple=thumbv7-apple-ios \
; RUN:      | FileCheck %s --check-prefix=CHECK --check-prefix=THUMB --check-prefix=DISABLE --check-prefix=THUMB-DISABLE

;
; Note: Lots of tests use inline asm instead of regular calls.
; This allows to have a better control on what the allocation will do.
; Otherwise, we may have spill right in the entry block, defeating
; shrink-wrapping. Moreover, some of the inline asm statements (nop)
; are here to ensure that the related paths do not end up as critical
; edges.
; Also disable the late if-converter as it makes harder to reason on
; the diffs.

; Initial motivating example: Simple diamond with a call just on one side.
; CHECK-LABEL: foo:
;
; Compare the arguments and jump to exit.
; No prologue needed.
; ENABLE: cmp r0, r1
; ENABLE-NEXT: bge [[EXIT_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; CHECK: push {r7, lr}
; CHECK-NEXT: mov r7, sp
;;
; Compare the arguments and jump to exit.
; After the prologue is set.
; DISABLE: sub sp
; DISABLE: cmp r0, r1
; DISABLE-NEXT: bge [[EXIT_LABEL:LBB[0-9_]+]]
;
; Store %a in the alloca.
; ARM-ENABLE: push {r0}
; THUMB-ENABLE: str r0, [sp, #-4]
; DISABLE: str r0, [sp]
; Set the alloca address in the second argument.
; CHECK-NEXT: mov r1, sp
; Set the first argument to zero.
; CHECK-NEXT: mov{{s?}} r0, #0
; CHECK-NEXT: bl{{x?}} _doSomething
;
; With shrink-wrapping, epilogue is just after the call.
; ARM-ENABLE-NEXT: mov sp, r7
; THUMB-ENABLE-NEXT: add sp, #4
; ENABLE-NEXT: pop{{(\.w)?}} {r7, lr}
;
; CHECK: [[EXIT_LABEL]]:
;
; Without shrink-wrapping, epilogue is in the exit block.
; Epilogue code. (What we pop does not matter.)
; ARM-DISABLE: mov sp, r7
; THUMB-DISABLE: add sp, 
; DISABLE-NEXT: pop {r7, pc}
;
; ENABLE-NEXT: bx lr
define i32 @foo(i32 %a, i32 %b) {
  %tmp = alloca i32, align 4
  %tmp2 = icmp slt i32 %a, %b
  br i1 %tmp2, label %true, label %false

true:
  store i32 %a, i32* %tmp, align 4
  %tmp4 = call i32 @doSomething(i32 0, i32* %tmp)
  br label %false

false:
  %tmp.0 = phi i32 [ %tmp4, %true ], [ %a, %0 ]
  ret i32 %tmp.0
}

; Function Attrs: optsize
declare i32 @doSomething(i32, i32*)


; Check that we do not perform the restore inside the loop whereas the save
; is outside.
; CHECK-LABEL: freqSaveAndRestoreOutsideLoop:
;
; Shrink-wrapping allows to skip the prologue in the else case.
; ARM-ENABLE: cmp r0, #0
; ARM-ENABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-ENABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; Make sure we save the CSR used in the inline asm: r4.
; CHECK: push {r4, r7, lr}
; CHECK-NEXT: add r7, sp, #4
;
; ARM-DISABLE: cmp r0, #0
; ARM-DISABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-DISABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; SUM is in r0 because it is coalesced with the second
; argument on the else path.
; CHECK: mov{{s?}} [[SUM:r0]], #0
; CHECK-NEXT: mov{{s?}} [[IV:r[0-9]+]], #10
;
; Next BB.
; CHECK: [[LOOP:LBB[0-9_]+]]: @ %for.body
; CHECK: mov{{(\.w)?}} [[TMP:r[0-9]+]], #1
; ARM: subs [[IV]], [[IV]], #1
; THUMB: subs [[IV]], #1
; ARM-NEXT: add [[SUM]], [[TMP]], [[SUM]]
; THUMB-NEXT: add [[SUM]], [[TMP]]
; CHECK-NEXT: bne [[LOOP]]
;
; Next BB.
; SUM << 3.
; CHECK: lsl{{s?}} [[SUM]], [[SUM]], #3
; ENABLE-NEXT: pop {r4, r7, pc}
;
; Duplicated epilogue.
; DISABLE: pop {r4, r7, pc}
;
; CHECK: [[ELSE_LABEL]]: @ %if.else
; Shift second argument by one and store into returned register.
; CHECK: lsl{{s?}} r0, r1, #1
; DISABLE-NEXT: pop {r4, r7, pc}
;
; ENABLE-NEXT: bx lr
define i32 @freqSaveAndRestoreOutsideLoop(i32 %cond, i32 %N) {
entry:
  %tobool = icmp eq i32 %cond, 0
  br i1 %tobool, label %if.else, label %for.preheader

for.preheader:
  tail call void asm "nop", ""()
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.05 = phi i32 [ %inc, %for.body ], [ 0, %for.preheader ]
  %sum.04 = phi i32 [ %add, %for.body ], [ 0, %for.preheader ]
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  %add = add nsw i32 %call, %sum.04
  %inc = add nuw nsw i32 %i.05, 1
  %exitcond = icmp eq i32 %inc, 10
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  %shl = shl i32 %add, 3
  br label %if.end

if.else:                                          ; preds = %entry
  %mul = shl nsw i32 %N, 1
  br label %if.end

if.end:                                           ; preds = %if.else, %for.end
  %sum.1 = phi i32 [ %shl, %for.end ], [ %mul, %if.else ]
  ret i32 %sum.1
}

declare i32 @something(...)

; Check that we do not perform the shrink-wrapping inside the loop even
; though that would be legal. The cost model must prevent that.
; CHECK-LABEL: freqSaveAndRestoreOutsideLoop2:
; Prologue code.
; Make sure we save the CSR used in the inline asm: r4.
; CHECK: push {r4
; CHECK: mov{{s?}} [[SUM:r0]], #0
; CHECK-NEXT: mov{{s?}} [[IV:r[0-9]+]], #10
; CHECK: nop
; Next BB.
; CHECK: [[LOOP_LABEL:LBB[0-9_]+]]: @ %for.body
; CHECK: mov{{(\.w)?}} [[TMP:r[0-9]+]], #1
; ARM: subs [[IV]], [[IV]], #1
; THUMB: subs [[IV]], #1
; ARM: add [[SUM]], [[TMP]], [[SUM]]
; THUMB: add [[SUM]], [[TMP]]
; CHECK-NEXT: bne [[LOOP_LABEL]]
; Next BB.
; CHECK: @ %for.exit
; CHECK: nop
; CHECK: pop {r4
define i32 @freqSaveAndRestoreOutsideLoop2(i32 %cond) {
entry:
  br label %for.preheader

for.preheader:
  tail call void asm "nop", ""()
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.04 = phi i32 [ 0, %for.preheader ], [ %inc, %for.body ]
  %sum.03 = phi i32 [ 0, %for.preheader ], [ %add, %for.body ]
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  %add = add nsw i32 %call, %sum.03
  %inc = add nuw nsw i32 %i.04, 1
  %exitcond = icmp eq i32 %inc, 10
  br i1 %exitcond, label %for.exit, label %for.body

for.exit:
  tail call void asm "nop", ""()
  br label %for.end

for.end:                                          ; preds = %for.body
  ret i32 %add
}

; Check with a more complex case that we do not have save within the loop and
; restore outside.
; CHECK-LABEL: loopInfoSaveOutsideLoop:
;
; ARM-ENABLE: cmp r0, #0
; ARM-ENABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-ENABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; Make sure we save the CSR used in the inline asm: r4.
; CHECK: push {r4, r7, lr}
; CHECK-NEXT: add r7, sp, #4
;
; ARM-DISABLE: cmp r0, #0
; ARM-DISABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-DISABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; SUM is in r0 because it is coalesced with the second
; argument on the else path.
; CHECK: mov{{s?}} [[SUM:r0]], #0
; CHECK-NEXT: mov{{s?}} [[IV:r[0-9]+]], #10
;
; Next BB.
; CHECK: [[LOOP:LBB[0-9_]+]]: @ %for.body
; CHECK: mov{{(\.w)?}} [[TMP:r[0-9]+]], #1
; ARM: subs [[IV]], [[IV]], #1
; THUMB: subs [[IV]], #1
; ARM-NEXT: add [[SUM]], [[TMP]], [[SUM]]
; THUMB-NEXT: add [[SUM]], [[TMP]]
; CHECK-NEXT: bne [[LOOP]]
;
; Next BB.
; SUM << 3.
; CHECK: lsl{{s?}} [[SUM]], [[SUM]], #3
; ENABLE: pop {r4, r7, pc}
;
; Duplicated epilogue.
; DISABLE: pop {r4, r7, pc}
;
; CHECK: [[ELSE_LABEL]]: @ %if.else
; Shift second argument by one and store into returned register.
; CHECK: lsl{{s?}} r0, r1, #1
; DISABLE-NEXT: pop {r4, r7, pc}
;
; ENABLE-NEXT: bx lr
define i32 @loopInfoSaveOutsideLoop(i32 %cond, i32 %N) {
entry:
  %tobool = icmp eq i32 %cond, 0
  br i1 %tobool, label %if.else, label %for.preheader

for.preheader:
  tail call void asm "nop", ""()
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.05 = phi i32 [ %inc, %for.body ], [ 0, %for.preheader ]
  %sum.04 = phi i32 [ %add, %for.body ], [ 0, %for.preheader ]
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  %add = add nsw i32 %call, %sum.04
  %inc = add nuw nsw i32 %i.05, 1
  %exitcond = icmp eq i32 %inc, 10
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  tail call void asm "nop", "~{r4}"()
  %shl = shl i32 %add, 3
  br label %if.end

if.else:                                          ; preds = %entry
  %mul = shl nsw i32 %N, 1
  br label %if.end

if.end:                                           ; preds = %if.else, %for.end
  %sum.1 = phi i32 [ %shl, %for.end ], [ %mul, %if.else ]
  ret i32 %sum.1
}

declare void @somethingElse(...)

; Check with a more complex case that we do not have restore within the loop and
; save outside.
; CHECK-LABEL: loopInfoRestoreOutsideLoop:
;
; ARM-ENABLE: cmp r0, #0
; ARM-ENABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-ENABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; Make sure we save the CSR used in the inline asm: r4.
; CHECK: push {r4, r7, lr}
; CHECK-NEXT: add r7, sp, #4
;
; ARM-DISABLE: cmp r0, #0
; ARM-DISABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-DISABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; SUM is in r0 because it is coalesced with the second
; argument on the else path.
; CHECK: mov{{s?}} [[SUM:r0]], #0
; CHECK-NEXT: mov{{s?}} [[IV:r[0-9]+]], #10
;
; Next BB.
; CHECK: [[LOOP:LBB[0-9_]+]]: @ %for.body
; CHECK: mov{{(\.w)?}} [[TMP:r[0-9]+]], #1
; ARM: subs [[IV]], [[IV]], #1
; THUMB: subs [[IV]], #1
; ARM-NEXT: add [[SUM]], [[TMP]], [[SUM]]
; THUMB-NEXT: add [[SUM]], [[TMP]]
; CHECK-NEXT: bne [[LOOP]]
;
; Next BB.
; SUM << 3.
; CHECK: lsl{{s?}} [[SUM]], [[SUM]], #3
; ENABLE-NEXT: pop {r4, r7, pc}
;
; Duplicated epilogue.
; DISABLE: pop {r4, r7, pc}
;
; CHECK: [[ELSE_LABEL]]: @ %if.else
; Shift second argument by one and store into returned register.
; CHECK: lsl{{s?}} r0, r1, #1
; DISABLE-NEXT: pop {r4, r7, pc}
;
; ENABLE-NEXT: bx lr
define i32 @loopInfoRestoreOutsideLoop(i32 %cond, i32 %N) #0 {
entry:
  %tobool = icmp eq i32 %cond, 0
  br i1 %tobool, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  tail call void asm "nop", "~{r4}"()
  br label %for.body

for.body:                                         ; preds = %for.body, %if.then
  %i.05 = phi i32 [ 0, %if.then ], [ %inc, %for.body ]
  %sum.04 = phi i32 [ 0, %if.then ], [ %add, %for.body ]
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  %add = add nsw i32 %call, %sum.04
  %inc = add nuw nsw i32 %i.05, 1
  %exitcond = icmp eq i32 %inc, 10
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  %shl = shl i32 %add, 3
  br label %if.end

if.else:                                          ; preds = %entry
  %mul = shl nsw i32 %N, 1
  br label %if.end

if.end:                                           ; preds = %if.else, %for.end
  %sum.1 = phi i32 [ %shl, %for.end ], [ %mul, %if.else ]
  ret i32 %sum.1
}

; Check that we handle function with no frame information correctly.
; CHECK-LABEL: emptyFrame:
; CHECK: @ %entry
; CHECK-NEXT: mov{{s?}} r0, #0
; CHECK-NEXT: bx lr
define i32 @emptyFrame() {
entry:
  ret i32 0
}

; Check that we handle inline asm correctly.
; CHECK-LABEL: inlineAsm:
;
; ARM-ENABLE: cmp r0, #0
; ARM-ENABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-ENABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; Make sure we save the CSR used in the inline asm: r4.
; CHECK: push {r4, r7, lr}
; CHECK-NEXT: add r7, sp, #4
;
; ARM-DISABLE: cmp r0, #0
; ARM-DISABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-DISABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; CHECK: mov{{s?}} [[IV:r[0-9]+]], #10
;
; Next BB.
; CHECK: [[LOOP:LBB[0-9_]+]]: @ %for.body
; ARM: subs [[IV]], [[IV]], #1
; THUMB: subs [[IV]], #1
; CHECK: add{{(\.w)?}} r4, r4, #1
; CHECK: bne [[LOOP]]
;
; Next BB.
; CHECK: mov{{s?}} r0, #0
;
; Duplicated epilogue.
; DISABLE: pop {r4, r7, pc}
;
; CHECK: [[ELSE_LABEL]]: @ %if.else
; Shift second argument by one and store into returned register.
; CHECK: lsl{{s?}} r0, r1, #1
; DISABLE-NEXT: pop {r4, r7, pc}
;
; ENABLE-NEXT: bx lr
define i32 @inlineAsm(i32 %cond, i32 %N) {
entry:
  %tobool = icmp eq i32 %cond, 0
  br i1 %tobool, label %if.else, label %for.preheader

for.preheader:
  tail call void asm "nop", ""()
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.03 = phi i32 [ %inc, %for.body ], [ 0, %for.preheader ]
  tail call void asm sideeffect "add r4, #1", "~{r4}"()
  %inc = add nuw nsw i32 %i.03, 1
  %exitcond = icmp eq i32 %inc, 10
  br i1 %exitcond, label %for.exit, label %for.body

for.exit:
  tail call void asm "nop", ""()
  br label %if.end

if.else:                                          ; preds = %entry
  %mul = shl nsw i32 %N, 1
  br label %if.end

if.end:                                           ; preds = %for.body, %if.else
  %sum.0 = phi i32 [ %mul, %if.else ], [ 0, %for.exit ]
  ret i32 %sum.0
}

; Check that we handle calls to variadic functions correctly.
; CHECK-LABEL: callVariadicFunc:
;
; ARM-ENABLE: cmp r0, #0
; ARM-ENABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-ENABLE: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Prologue code.
; CHECK: push {r7, lr}
; CHECK-NEXT: mov r7, sp
; CHECK-NEXT: sub sp, {{(sp, )?}}#12
;
; ARM-DISABLE: cmp r0, #0
; ARM-DISABLE-NEXT: beq [[ELSE_LABEL:LBB[0-9_]+]]
; THUMB-DISABLE-NEXT: cbz r0, [[ELSE_LABEL:LBB[0-9_]+]]
;
; Setup of the varags.
; CHECK: mov r0, r1
; CHECK-NEXT: mov r2, r1
; CHECK-NEXT: mov r3, r1
; ARM-NEXT: str r1, [sp]
; ARM-NEXT: str r1, [sp, #4]
; THUMB-NEXT: strd r1, r1, [sp]
; CHECK-NEXT: str r1, [sp, #8]
; CHECK-NEXT: bl{{x?}} _someVariadicFunc
; CHECK-NEXT: lsl{{s?}} r0, r0, #3
; ARM-NEXT: mov sp, r7
; THUMB-NEXT: add sp, #12
; CHECK-NEXT: pop {r7, pc}
;
; CHECK: [[ELSE_LABEL]]: @ %if.else
; Shift second argument by one and store into returned register.
; CHECK: lsl{{s?}} r0, r1, #1
;
; Epilogue code.
; ENABLE-NEXT: bx lr
;
; ARM-DISABLE-NEXT: mov sp, r7
; THUMB-DISABLE-NEXT: add sp, #12
; DISABLE-NEXT: pop {r7, pc}
define i32 @callVariadicFunc(i32 %cond, i32 %N) {
entry:
  %tobool = icmp eq i32 %cond, 0
  br i1 %tobool, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  %call = tail call i32 (i32, ...) @someVariadicFunc(i32 %N, i32 %N, i32 %N, i32 %N, i32 %N, i32 %N, i32 %N)
  %shl = shl i32 %call, 3
  br label %if.end

if.else:                                          ; preds = %entry
  %mul = shl nsw i32 %N, 1
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %sum.0 = phi i32 [ %shl, %if.then ], [ %mul, %if.else ]
  ret i32 %sum.0
}

declare i32 @someVariadicFunc(i32, ...)

; Make sure we do not insert unreachable code after noreturn function.
; Although this is not incorrect to insert such code, it is useless
; and it hurts the binary size.
;
; CHECK-LABEL: noreturn:
; DISABLE: push
;
; CHECK: tst{{(\.w)?}}  r0, #255
; CHECK-NEXT: bne      [[ABORT:LBB[0-9_]+]]
;
; CHECK: mov{{s?}} r0, #42
;
; ENABLE-NEXT: bx lr
;
; DISABLE-NEXT: pop
;;
; CHECK: [[ABORT]]: @ %if.abort
;
; ENABLE: push
;
; CHECK: bl{{x?}} _abort
; ENABLE-NOT: pop
define i32 @noreturn(i8 signext %bad_thing) {
entry:
  %tobool = icmp eq i8 %bad_thing, 0
  br i1 %tobool, label %if.end, label %if.abort

if.abort:
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  tail call void @abort() #0
  unreachable

if.end:
  ret i32 42
}

declare void @abort() #0

attributes #0 = { noreturn nounwind }

; Make sure that we handle infinite loops properly When checking that the Save
; and Restore blocks are control flow equivalent, the loop searches for the
; immediate (post) dominator for the (restore) save blocks. When either the Save
; or Restore block is located in an infinite loop the only immediate (post)
; dominator is itself. In this case, we cannot perform shrink wrapping, but we
; should return gracefully and continue compilation.
; The only condition for this test is the compilation finishes correctly.
; CHECK-LABEL: infiniteloop
; CHECK: pop
define void @infiniteloop() {
entry:
  br i1 undef, label %if.then, label %if.end

if.then:
  %ptr = alloca i32, i32 4
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %sum.03 = phi i32 [ 0, %if.then ], [ %add, %for.body ]
  %call = tail call i32 asm sideeffect "mov $0, #1", "=r,~{r4}"()
  %add = add nsw i32 %call, %sum.03
  store i32 %add, i32* %ptr
  br label %for.body

if.end:
  ret void
}
