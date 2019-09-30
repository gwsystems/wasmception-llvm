; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=thumbv7k-linux-gnu | FileCheck %s

declare {<2 x i64>, <2 x i1>} @llvm.uadd.with.overflow.v2i64(<2 x i64>, <2 x i64>)
declare {<2 x i64>, <2 x i1>} @llvm.usub.with.overflow.v2i64(<2 x i64>, <2 x i64>)
declare {<2 x i64>, <2 x i1>} @llvm.sadd.with.overflow.v2i64(<2 x i64>, <2 x i64>)
declare {<2 x i64>, <2 x i1>} @llvm.ssub.with.overflow.v2i64(<2 x i64>, <2 x i64>)

define <2 x i1> @uaddo(<2 x i64> *%ptr, <2 x i64> *%ptr2) {
; CHECK-LABEL: uaddo:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-NEXT:    vld1.64 {d18, d19}, [r0]
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1]
; CHECK-NEXT:    movs r1, #0
; CHECK-NEXT:    vadd.i64 q8, q9, q8
; CHECK-NEXT:    vmov.32 r3, d18[0]
; CHECK-NEXT:    vmov.32 r2, d18[1]
; CHECK-NEXT:    vmov.32 r12, d16[0]
; CHECK-NEXT:    vmov.32 lr, d16[1]
; CHECK-NEXT:    vmov.32 r4, d17[0]
; CHECK-NEXT:    vmov.32 r5, d19[0]
; CHECK-NEXT:    vmov.32 r6, d17[1]
; CHECK-NEXT:    vmov.32 r7, d19[1]
; CHECK-NEXT:    subs.w r3, r12, r3
; CHECK-NEXT:    sbcs.w r2, lr, r2
; CHECK-NEXT:    mov.w r2, #0
; CHECK-NEXT:    it lo
; CHECK-NEXT:    movlo r2, #1
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r2, #-1
; CHECK-NEXT:    subs r3, r4, r5
; CHECK-NEXT:    sbcs.w r3, r6, r7
; CHECK-NEXT:    it lo
; CHECK-NEXT:    movlo r1, #1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    pop {r4, r5, r6, r7, pc}
  %x = load <2 x i64>, <2 x i64>* %ptr, align 8
  %y = load <2 x i64>, <2 x i64>* %ptr2, align 8
  %s = call {<2 x i64>, <2 x i1>} @llvm.uadd.with.overflow.v2i64(<2 x i64> %x, <2 x i64> %y)
  %m = extractvalue {<2 x i64>, <2 x i1>} %s, 0
  %o = extractvalue {<2 x i64>, <2 x i1>} %s, 1
  store <2 x i64> %m, <2 x i64>* %ptr
  ret <2 x i1> %o
}

define <2 x i1> @usubo(<2 x i64> *%ptr, <2 x i64> *%ptr2) {
; CHECK-LABEL: usubo:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1]
; CHECK-NEXT:    movs r1, #0
; CHECK-NEXT:    vld1.64 {d18, d19}, [r0]
; CHECK-NEXT:    vsub.i64 q8, q9, q8
; CHECK-NEXT:    vmov.32 r12, d18[0]
; CHECK-NEXT:    vmov.32 lr, d18[1]
; CHECK-NEXT:    vmov.32 r3, d16[0]
; CHECK-NEXT:    vmov.32 r2, d16[1]
; CHECK-NEXT:    vmov.32 r4, d19[0]
; CHECK-NEXT:    vmov.32 r5, d17[0]
; CHECK-NEXT:    vmov.32 r6, d19[1]
; CHECK-NEXT:    vmov.32 r7, d17[1]
; CHECK-NEXT:    subs.w r3, r12, r3
; CHECK-NEXT:    sbcs.w r2, lr, r2
; CHECK-NEXT:    mov.w r2, #0
; CHECK-NEXT:    it lo
; CHECK-NEXT:    movlo r2, #1
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r2, #-1
; CHECK-NEXT:    subs r3, r4, r5
; CHECK-NEXT:    sbcs.w r3, r6, r7
; CHECK-NEXT:    it lo
; CHECK-NEXT:    movlo r1, #1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    pop {r4, r5, r6, r7, pc}
  %x = load <2 x i64>, <2 x i64>* %ptr, align 8
  %y = load <2 x i64>, <2 x i64>* %ptr2, align 8
  %s = call {<2 x i64>, <2 x i1>} @llvm.usub.with.overflow.v2i64(<2 x i64> %x, <2 x i64> %y)
  %m = extractvalue {<2 x i64>, <2 x i1>} %s, 0
  %o = extractvalue {<2 x i64>, <2 x i1>} %s, 1
  store <2 x i64> %m, <2 x i64>* %ptr
  ret <2 x i1> %o
}

define <2 x i1> @saddo(<2 x i64> *%ptr, <2 x i64> *%ptr2) {
; CHECK-LABEL: saddo:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    vld1.64 {d20, d21}, [r0]
; CHECK-NEXT:    movs r3, #0
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1]
; CHECK-NEXT:    vadd.i64 q8, q10, q9
; CHECK-NEXT:    vmov.32 r2, d20[0]
; CHECK-NEXT:    vmov.32 r1, d20[1]
; CHECK-NEXT:    vmov.32 r12, d16[0]
; CHECK-NEXT:    vmov.32 r8, d16[1]
; CHECK-NEXT:    vmov.32 lr, d17[0]
; CHECK-NEXT:    vmov.32 r4, d21[0]
; CHECK-NEXT:    vmov.32 r5, d17[1]
; CHECK-NEXT:    vmov.32 r6, d18[1]
; CHECK-NEXT:    vmov.32 r7, d21[1]
; CHECK-NEXT:    subs.w r2, r12, r2
; CHECK-NEXT:    vmov.32 r2, d19[1]
; CHECK-NEXT:    sbcs.w r1, r8, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r1, #1
; CHECK-NEXT:    subs.w r4, lr, r4
; CHECK-NEXT:    sbcs.w r7, r5, r7
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r3, #1
; CHECK-NEXT:    cmp r3, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r3, #-1
; CHECK-NEXT:    asrs r7, r6, #31
; CHECK-NEXT:    vdup.32 d21, r3
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vdup.32 d20, r1
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    asrs r2, r2, #31
; CHECK-NEXT:    vdup.32 d19, r2
; CHECK-NEXT:    vdup.32 d18, r7
; CHECK-NEXT:    veor q9, q9, q10
; CHECK-NEXT:    vmovn.i64 d18, q9
; CHECK-NEXT:    vmov r2, r1, d18
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, pc}
  %x = load <2 x i64>, <2 x i64>* %ptr, align 8
  %y = load <2 x i64>, <2 x i64>* %ptr2, align 8
  %s = call {<2 x i64>, <2 x i1>} @llvm.sadd.with.overflow.v2i64(<2 x i64> %x, <2 x i64> %y)
  %m = extractvalue {<2 x i64>, <2 x i1>} %s, 0
  %o = extractvalue {<2 x i64>, <2 x i1>} %s, 1
  store <2 x i64> %m, <2 x i64>* %ptr
  ret <2 x i1> %o
}

define <2 x i1> @ssubo(<2 x i64> *%ptr, <2 x i64> *%ptr2) {
; CHECK-LABEL: ssubo:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1]
; CHECK-NEXT:    movs r2, #0
; CHECK-NEXT:    vld1.64 {d20, d21}, [r0]
; CHECK-NEXT:    vsub.i64 q8, q10, q9
; CHECK-NEXT:    vmov.32 r1, d20[0]
; CHECK-NEXT:    vmov.32 r12, d20[1]
; CHECK-NEXT:    vmov.32 r3, d16[0]
; CHECK-NEXT:    vmov.32 lr, d16[1]
; CHECK-NEXT:    vmov.32 r4, d21[0]
; CHECK-NEXT:    vmov.32 r5, d17[0]
; CHECK-NEXT:    vmov.32 r6, d21[1]
; CHECK-NEXT:    vmov.32 r7, d17[1]
; CHECK-NEXT:    vmov.32 r8, d18[1]
; CHECK-NEXT:    subs r1, r3, r1
; CHECK-NEXT:    vmov.32 r3, d18[0]
; CHECK-NEXT:    sbcs.w r1, lr, r12
; CHECK-NEXT:    vmov.32 r12, d19[0]
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r1, #1
; CHECK-NEXT:    subs r5, r5, r4
; CHECK-NEXT:    vmov.32 r5, d19[1]
; CHECK-NEXT:    sbcs r7, r6
; CHECK-NEXT:    mov.w r7, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r7, #1
; CHECK-NEXT:    cmp r7, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r7, #-1
; CHECK-NEXT:    vdup.32 d21, r7
; CHECK-NEXT:    rsbs r3, r3, #0
; CHECK-NEXT:    sbcs.w r3, r2, r8
; CHECK-NEXT:    mov.w r3, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r3, #1
; CHECK-NEXT:    rsbs.w r6, r12, #0
; CHECK-NEXT:    sbcs.w r6, r2, r5
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r2, #1
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r2, #-1
; CHECK-NEXT:    cmp r3, #0
; CHECK-NEXT:    vdup.32 d19, r2
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r3, #-1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vdup.32 d18, r3
; CHECK-NEXT:    vdup.32 d20, r1
; CHECK-NEXT:    veor q9, q9, q10
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    vmovn.i64 d18, q9
; CHECK-NEXT:    vmov r2, r1, d18
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, pc}
  %x = load <2 x i64>, <2 x i64>* %ptr, align 8
  %y = load <2 x i64>, <2 x i64>* %ptr2, align 8
  %s = call {<2 x i64>, <2 x i1>} @llvm.ssub.with.overflow.v2i64(<2 x i64> %x, <2 x i64> %y)
  %m = extractvalue {<2 x i64>, <2 x i1>} %s, 0
  %o = extractvalue {<2 x i64>, <2 x i1>} %s, 1
  store <2 x i64> %m, <2 x i64>* %ptr
  ret <2 x i1> %o
}
