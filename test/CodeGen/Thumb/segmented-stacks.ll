; RUN: llc < %s -mtriple=thumb-linux-androideabi -segmented-stacks -verify-machineinstrs | FileCheck %s -check-prefix=Thumb-android
; RUN: llc < %s -mtriple=thumb-linux-unknown-gnueabi -segmented-stacks -verify-machineinstrs | FileCheck %s -check-prefix=Thumb-linux
; RUN: llc < %s -mtriple=thumb-linux-androideabi -segmented-stacks -filetype=obj
; RUN: llc < %s -mtriple=thumb-linux-unknown-gnueabi -segmented-stacks -filetype=obj


; Just to prevent the alloca from being optimized away
declare void @dummy_use(i32*, i32)

define void @test_basic() {
        %mem = alloca i32, i32 10
        call void @dummy_use (i32* %mem, i32 10)
	ret void

; Thumb-android:      test_basic:

; Thumb-android:      push    {r4, r5}
; Thumb-android-NEXT: mov     r5, sp
; Thumb-android-NEXT: ldr     r4, .LCPI0_0
; Thumb-android-NEXT: ldr     r4, [r4]
; Thumb-android-NEXT: cmp     r4, r5
; Thumb-android-NEXT: blo     .LBB0_2

; Thumb-android:      mov     r4, #48
; Thumb-android-NEXT: mov     r5, #0
; Thumb-android-NEXT: push    {lr}
; Thumb-android-NEXT: bl      __morestack
; Thumb-android-NEXT: pop     {r4}
; Thumb-android-NEXT: mov     lr, r4
; Thumb-android-NEXT: pop     {r4, r5}
; Thumb-android-NEXT: bx      lr

; Thumb-android:      pop     {r4, r5}

; Thumb-linux:      test_basic:

; Thumb-linux:      push    {r4, r5}
; Thumb-linux-NEXT: mov     r5, sp
; Thumb-linux-NEXT: ldr     r4, .LCPI0_0
; Thumb-linux-NEXT: ldr     r4, [r4]
; Thumb-linux-NEXT: cmp     r4, r5
; Thumb-linux-NEXT: blo     .LBB0_2

; Thumb-linux:      mov     r4, #48
; Thumb-linux-NEXT: mov     r5, #0
; Thumb-linux-NEXT: push    {lr}
; Thumb-linux-NEXT: bl      __morestack
; Thumb-linux-NEXT: pop     {r4}
; Thumb-linux-NEXT: mov     lr, r4
; Thumb-linux-NEXT: pop     {r4, r5}
; Thumb-linux-NEXT: bx      lr

; Thumb-linux:      pop     {r4, r5}

}

define i32 @test_nested(i32 * nest %closure, i32 %other) {
       %addend = load i32 * %closure
       %result = add i32 %other, %addend
       ret i32 %result

; Thumb-android:      test_nested:

; Thumb-android:      push  {r4, r5}
; Thumb-android-NEXT: mov     r5, sp
; Thumb-android-NEXT: ldr     r4, .LCPI1_0
; Thumb-android-NEXT: ldr     r4, [r4]
; Thumb-android-NEXT: cmp     r4, r5
; Thumb-android-NEXT: blo     .LBB1_2

; Thumb-android:      mov     r4, #0
; Thumb-android-NEXT: mov     r5, #0
; Thumb-android-NEXT: push    {lr}
; Thumb-android-NEXT: bl      __morestack
; Thumb-android-NEXT: pop     {r4}
; Thumb-android-NEXT: mov     lr, r4
; Thumb-android-NEXT: pop     {r4, r5}
; Thumb-android-NEXT: bx      lr

; Thumb-android:      pop     {r4, r5}

; Thumb-linux:      test_nested:

; Thumb-linux:      push    {r4, r5}
; Thumb-linux-NEXT: mov     r5, sp
; Thumb-linux-NEXT: ldr     r4, .LCPI1_0
; Thumb-linux-NEXT: ldr     r4, [r4]
; Thumb-linux-NEXT: cmp     r4, r5
; Thumb-linux-NEXT: blo     .LBB1_2

; Thumb-linux:      mov     r4, #0
; Thumb-linux-NEXT: mov     r5, #0
; Thumb-linux-NEXT: push    {lr}
; Thumb-linux-NEXT: bl      __morestack
; Thumb-linux-NEXT: pop     {r4}
; Thumb-linux-NEXT: mov     lr, r4
; Thumb-linux-NEXT: pop     {r4, r5}
; Thumb-linux-NEXT: bx      lr

; Thumb-linux:      pop     {r4, r5}

}

define void @test_large() {
        %mem = alloca i32, i32 10000
        call void @dummy_use (i32* %mem, i32 0)
        ret void

; Thumb-android:      test_large:

; Thumb-android:      push    {r4, r5}
; Thumb-android-NEXT: mov     r5, sp
; Thumb-android-NEXT: sub     r5, #40192
; Thumb-android-NEXT: ldr     r4, .LCPI2_2
; Thumb-android-NEXT: ldr     r4, [r4]
; Thumb-android-NEXT: cmp     r4, r5
; Thumb-android-NEXT: blo     .LBB2_2

; Thumb-android:      mov     r4, #40192
; Thumb-android-NEXT: mov     r5, #0
; Thumb-android-NEXT: push    {lr}
; Thumb-android-NEXT: bl      __morestack
; Thumb-android-NEXT: pop     {r4}
; Thumb-android-NEXT: mov     lr, r4
; Thumb-android-NEXT: pop     {r4, r5}
; Thumb-android-NEXT: bx      lr

; Thumb-android:      pop     {r4, r5}

; Thumb-linux:      test_large:

; Thumb-linux:      push    {r4, r5}
; Thumb-linux-NEXT: mov     r5, sp
; Thumb-linux-NEXT: sub     r5, #40192
; Thumb-linux-NEXT: ldr     r4, .LCPI2_2
; Thumb-linux-NEXT: ldr     r4, [r4]
; Thumb-linux-NEXT: cmp     r4, r5
; Thumb-linux-NEXT: blo     .LBB2_2

; Thumb-linux:      mov     r4, #40192
; Thumb-linux-NEXT: mov     r5, #0
; Thumb-linux-NEXT: push    {lr}
; Thumb-linux-NEXT: bl      __morestack
; Thumb-linux-NEXT: pop     {r4}
; Thumb-linux-NEXT: mov     lr, r4
; Thumb-linux-NEXT: pop     {r4, r5}
; Thumb-linux-NEXT: bx      lr

; Thumb-linux:      pop     {r4, r5}

}

define fastcc void @test_fastcc() {
        %mem = alloca i32, i32 10
        call void @dummy_use (i32* %mem, i32 10)
        ret void

; Thumb-android:      test_fastcc:

; Thumb-android:      push    {r4, r5}
; Thumb-android-NEXT: mov     r5, sp
; Thumb-android-NEXT: ldr     r4, .LCPI3_0
; Thumb-android-NEXT: ldr     r4, [r4]
; Thumb-android-NEXT: cmp     r4, r5
; Thumb-android-NEXT: blo     .LBB3_2

; Thumb-android:      mov     r4, #48
; Thumb-android-NEXT: mov     r5, #0
; Thumb-android-NEXT: push    {lr}
; Thumb-android-NEXT: bl      __morestack
; Thumb-android-NEXT: pop     {r4}
; Thumb-android-NEXT: mov     lr, r4
; Thumb-android-NEXT: pop     {r4, r5}
; Thumb-android-NEXT: bx      lr

; Thumb-android:      pop     {r4, r5}

; Thumb-linux:      test_fastcc:

; Thumb-linux:      push    {r4, r5}
; Thumb-linux-NEXT: mov     r5, sp
; Thumb-linux-NEXT: ldr     r4, .LCPI3_0
; Thumb-linux-NEXT: ldr     r4, [r4]
; Thumb-linux-NEXT: cmp     r4, r5
; Thumb-linux-NEXT: blo     .LBB3_2

; Thumb-linux:      mov     r4, #48
; Thumb-linux-NEXT: mov     r5, #0
; Thumb-linux-NEXT: push    {lr}
; Thumb-linux-NEXT: bl      __morestack
; Thumb-linux-NEXT: pop     {r4}
; Thumb-linux-NEXT: mov     lr, r4
; Thumb-linux-NEXT: pop     {r4, r5}
; Thumb-linux-NEXT: bx      lr

; Thumb-linux:      pop     {r4, r5}

}

define fastcc void @test_fastcc_large() {
        %mem = alloca i32, i32 10000
        call void @dummy_use (i32* %mem, i32 0)
        ret void

; Thumb-android:      test_fastcc_large:

; Thumb-android:      push    {r4, r5}
; Thumb-android-NEXT: mov     r5, sp
; Thumb-android-NEXT: sub     r5, #40192
; Thumb-android-NEXT: ldr     r4, .LCPI4_2
; Thumb-android-NEXT: ldr     r4, [r4]
; Thumb-android-NEXT: cmp     r4, r5
; Thumb-android-NEXT: blo     .LBB4_2

; Thumb-android:      mov     r4, #40192
; Thumb-android-NEXT: mov     r5, #0
; Thumb-android-NEXT: push    {lr}
; Thumb-android-NEXT: bl      __morestack
; Thumb-android-NEXT: pop     {r4}
; Thumb-android-NEXT: mov     lr, r4
; Thumb-android-NEXT: pop     {r4, r5}
; Thumb-android-NEXT: bx      lr

; Thumb-android:      pop     {r4, r5}

; Thumb-linux:      test_fastcc_large:

; Thumb-linux:      push    {r4, r5}
; Thumb-linux-NEXT: mov     r5, sp
; Thumb-linux-NEXT: sub     r5, #40192
; Thumb-linux-NEXT: ldr     r4, .LCPI4_2
; Thumb-linux-NEXT: ldr     r4, [r4]
; Thumb-linux-NEXT: cmp     r4, r5
; Thumb-linux-NEXT: blo     .LBB4_2

; Thumb-linux:      mov     r4, #40192
; Thumb-linux-NEXT: mov     r5, #0
; Thumb-linux-NEXT: push    {lr}
; Thumb-linux-NEXT: bl      __morestack
; Thumb-linux-NEXT: pop     {r4}
; Thumb-linux-NEXT: mov     lr, r4
; Thumb-linux-NEXT: pop     {r4, r5}
; Thumb-linux-NEXT: bx      lr

; Thumb-linux:      pop     {r4, r5}

}
