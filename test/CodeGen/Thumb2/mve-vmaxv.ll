; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve.fp %s -o - | FileCheck %s

declare i8 @llvm.experimental.vector.reduce.smax.v16i8(<16 x i8>)
declare i16 @llvm.experimental.vector.reduce.smax.v8i16(<8 x i16>)
declare i32 @llvm.experimental.vector.reduce.smax.v4i32(<4 x i32>)
declare i8 @llvm.experimental.vector.reduce.umax.v16i8(<16 x i8>)
declare i16 @llvm.experimental.vector.reduce.umax.v8i16(<8 x i16>)
declare i32 @llvm.experimental.vector.reduce.umax.v4i32(<4 x i32>)
declare i8 @llvm.experimental.vector.reduce.smin.v16i8(<16 x i8>)
declare i16 @llvm.experimental.vector.reduce.smin.v8i16(<8 x i16>)
declare i32 @llvm.experimental.vector.reduce.smin.v4i32(<4 x i32>)
declare i8 @llvm.experimental.vector.reduce.umin.v16i8(<16 x i8>)
declare i16 @llvm.experimental.vector.reduce.umin.v8i16(<8 x i16>)
declare i32 @llvm.experimental.vector.reduce.umin.v4i32(<4 x i32>)

define arm_aapcs_vfpcc i8 @vmaxv_s_v16i8_i32(<16 x i8> %s1) {
; CHECK-LABEL: vmaxv_s_v16i8_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    mvn r0, #127
; CHECK-NEXT:    vmaxv.s8 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i8 @llvm.experimental.vector.reduce.smax.v16i8(<16 x i8> %s1)
  ret i8 %r
}

define arm_aapcs_vfpcc i16 @vmaxv_s_v8i16_i32(<8 x i16> %s1) {
; CHECK-LABEL: vmaxv_s_v8i16_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movw r0, #32768
; CHECK-NEXT:    movt r0, #65535
; CHECK-NEXT:    vmaxv.s16 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i16 @llvm.experimental.vector.reduce.smax.v8i16(<8 x i16> %s1)
  ret i16 %r
}

define arm_aapcs_vfpcc i32 @vmaxv_s_v4i32_i32(<4 x i32> %s1) {
; CHECK-LABEL: vmaxv_s_v4i32_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    mov.w r0, #-2147483648
; CHECK-NEXT:    vmaxv.s32 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i32 @llvm.experimental.vector.reduce.smax.v4i32(<4 x i32> %s1)
  ret i32 %r
}

define arm_aapcs_vfpcc i8 @vmaxv_u_v16i8_i32(<16 x i8> %s1) {
; CHECK-LABEL: vmaxv_u_v16i8_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    vmaxv.u8 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i8 @llvm.experimental.vector.reduce.umax.v16i8(<16 x i8> %s1)
  ret i8 %r
}

define arm_aapcs_vfpcc i16 @vmaxv_u_v8i16_i32(<8 x i16> %s1) {
; CHECK-LABEL: vmaxv_u_v8i16_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    vmaxv.u16 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i16 @llvm.experimental.vector.reduce.umax.v8i16(<8 x i16> %s1)
  ret i16 %r
}

define arm_aapcs_vfpcc i32 @vmaxv_u_v4i32_i32(<4 x i32> %s1) {
; CHECK-LABEL: vmaxv_u_v4i32_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    vmaxv.u32 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i32 @llvm.experimental.vector.reduce.umax.v4i32(<4 x i32> %s1)
  ret i32 %r
}

define arm_aapcs_vfpcc i8 @vminv_s_v16i8_i32(<16 x i8> %s1) {
; CHECK-LABEL: vminv_s_v16i8_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movs r0, #127
; CHECK-NEXT:    vminv.s8 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i8 @llvm.experimental.vector.reduce.smin.v16i8(<16 x i8> %s1)
  ret i8 %r
}

define arm_aapcs_vfpcc i16 @vminv_s_v8i16_i32(<8 x i16> %s1) {
; CHECK-LABEL: vminv_s_v8i16_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movw r0, #32767
; CHECK-NEXT:    vminv.s16 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i16 @llvm.experimental.vector.reduce.smin.v8i16(<8 x i16> %s1)
  ret i16 %r
}

define arm_aapcs_vfpcc i32 @vminv_s_v4i32_i32(<4 x i32> %s1) {
; CHECK-LABEL: vminv_s_v4i32_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    mvn r0, #-2147483648
; CHECK-NEXT:    vminv.s32 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i32 @llvm.experimental.vector.reduce.smin.v4i32(<4 x i32> %s1)
  ret i32 %r
}

define arm_aapcs_vfpcc i8 @vminv_u_v16i8_i32(<16 x i8> %s1) {
; CHECK-LABEL: vminv_u_v16i8_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movs r0, #255
; CHECK-NEXT:    vminv.u8 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i8 @llvm.experimental.vector.reduce.umin.v16i8(<16 x i8> %s1)
  ret i8 %r
}

define arm_aapcs_vfpcc i16 @vminv_u_v8i16_i32(<8 x i16> %s1) {
; CHECK-LABEL: vminv_u_v8i16_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    movw r0, #65535
; CHECK-NEXT:    vminv.u16 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i16 @llvm.experimental.vector.reduce.umin.v8i16(<8 x i16> %s1)
  ret i16 %r
}

define arm_aapcs_vfpcc i32 @vminv_u_v4i32_i32(<4 x i32> %s1) {
; CHECK-LABEL: vminv_u_v4i32_i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    mov.w r0, #-1
; CHECK-NEXT:    vminv.u32 r0, q0
; CHECK-NEXT:    bx lr
  %r = call i32 @llvm.experimental.vector.reduce.umin.v4i32(<4 x i32> %s1)
  ret i32 %r
}
