; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumb-eabi -mcpu=cortex-a8 %s -o - | FileCheck %s -check-prefixes=CHECK,CHECK-DSP
; RUN: llc -mtriple=thumb-eabi -mcpu=cortex-m3 %s -o - | FileCheck %s -check-prefixes=CHECK,CHECK-NO-DSP
; RUN: llc -mtriple=thumbv7em-eabi %s -o - | FileCheck %s -check-prefixes=CHECK,CHECK-DSP
; RUN: llc -mtriple=thumbv8m.main-none-eabi %s -o - | FileCheck %s -check-prefixes=CHECK,CHECK-NO-DSP
; RUN: llc -mtriple=thumbv8m.main-none-eabi -mattr=+dsp %s -o - | FileCheck %s -check-prefixes=CHECK,CHECK-DSP

define i32 @test1(i32 %x) {
; CHECK-DSP-LABEL: test1:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test1:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    bic r0, r0, #-16711936
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = and i32 %x, 16711935		; <i32> [#uses=1]
	ret i32 %tmp1
}

; PR7503
define i32 @test2(i32 %x) {
; CHECK-DSP-LABEL: test2:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #8
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test2:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, lsr #8
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 8		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 16711935		; <i32> [#uses=1]
	ret i32 %tmp2
}

define i32 @test3(i32 %x) {
; CHECK-DSP-LABEL: test3:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #8
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test3:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, lsr #8
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 8		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 16711935		; <i32> [#uses=1]
	ret i32 %tmp2
}

define i32 @test4(i32 %x) {
; CHECK-DSP-LABEL: test4:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #8
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test4:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, lsr #8
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 8		; <i32> [#uses=1]
	%tmp6 = and i32 %tmp1, 16711935		; <i32> [#uses=1]
	ret i32 %tmp6
}

define i32 @test5(i32 %x) {
; CHECK-DSP-LABEL: test5:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #8
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test5:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, lsr #8
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 8		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 16711935		; <i32> [#uses=1]
	ret i32 %tmp2
}

define i32 @test6(i32 %x) {
; CHECK-DSP-LABEL: test6:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #16
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test6:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, ror #16
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 16		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 255		; <i32> [#uses=1]
	%tmp4 = shl i32 %x, 16		; <i32> [#uses=1]
	%tmp5 = and i32 %tmp4, 16711680		; <i32> [#uses=1]
	%tmp6 = or i32 %tmp2, %tmp5		; <i32> [#uses=1]
	ret i32 %tmp6
}

define i32 @test7(i32 %x) {
; CHECK-DSP-LABEL: test7:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #16
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test7:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, ror #16
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 16		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 255		; <i32> [#uses=1]
	%tmp4 = shl i32 %x, 16		; <i32> [#uses=1]
	%tmp5 = and i32 %tmp4, 16711680		; <i32> [#uses=1]
	%tmp6 = or i32 %tmp2, %tmp5		; <i32> [#uses=1]
	ret i32 %tmp6
}

define i32 @test8(i32 %x) {
; CHECK-DSP-LABEL: test8:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #24
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test8:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, ror #24
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = shl i32 %x, 8		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 16711680		; <i32> [#uses=1]
	%tmp5 = lshr i32 %x, 24		; <i32> [#uses=1]
	%tmp6 = or i32 %tmp2, %tmp5		; <i32> [#uses=1]
	ret i32 %tmp6
}

define i32 @test9(i32 %x) {
; CHECK-DSP-LABEL: test9:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    uxtb16 r0, r0, ror #24
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test9:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16711935
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, ror #24
; CHECK-NO-DSP-NEXT:    bx lr
	%tmp1 = lshr i32 %x, 24		; <i32> [#uses=1]
	%tmp4 = shl i32 %x, 8		; <i32> [#uses=1]
	%tmp5 = and i32 %tmp4, 16711680		; <i32> [#uses=1]
	%tmp6 = or i32 %tmp5, %tmp1		; <i32> [#uses=1]
	ret i32 %tmp6
}

define i32 @test10(i32 %p0) {
; CHECK-DSP-LABEL: test10:
; CHECK-DSP:       @ %bb.0:
; CHECK-DSP-NEXT:    mov.w r1, #16253176
; CHECK-DSP-NEXT:    and.w r0, r1, r0, lsr #7
; CHECK-DSP-NEXT:    lsrs r1, r0, #5
; CHECK-DSP-NEXT:    uxtb16 r1, r1
; CHECK-DSP-NEXT:    add r0, r1
; CHECK-DSP-NEXT:    bx lr
;
; CHECK-NO-DSP-LABEL: test10:
; CHECK-NO-DSP:       @ %bb.0:
; CHECK-NO-DSP-NEXT:    mov.w r1, #16253176
; CHECK-NO-DSP-NEXT:    and.w r0, r1, r0, lsr #7
; CHECK-NO-DSP-NEXT:    mov.w r1, #458759
; CHECK-NO-DSP-NEXT:    and.w r1, r1, r0, lsr #5
; CHECK-NO-DSP-NEXT:    add r0, r1
; CHECK-NO-DSP-NEXT:    bx lr

	%tmp1 = lshr i32 %p0, 7		; <i32> [#uses=1]
	%tmp2 = and i32 %tmp1, 16253176		; <i32> [#uses=2]
	%tmp4 = lshr i32 %tmp2, 5		; <i32> [#uses=1]
	%tmp5 = and i32 %tmp4, 458759		; <i32> [#uses=1]
	%tmp7 = or i32 %tmp5, %tmp2		; <i32> [#uses=1]
	ret i32 %tmp7
}
