; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-eabi -mattr=+mve --verify-machineinstrs %s -o - | FileCheck %s

define void @vctp8(i32 %arg, <16 x i8> *%in, <16 x i8>* %out) {
; CHECK-LABEL: vctp8:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vldrw.u32 q1, [r1]
; CHECK-NEXT:    vctp.8 r0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vstrw.32 q0, [r2]
; CHECK-NEXT:    bx lr
  %pred = call <16 x i1> @llvm.arm.vctp8(i32 %arg)
  %ld = load <16 x i8>, <16 x i8>* %in
  %res = select <16 x i1> %pred, <16 x i8> %ld, <16 x i8> zeroinitializer
  store <16 x i8> %res, <16 x i8>* %out
  ret void
}

define void @vctp16(i32 %arg, <8 x i16> *%in, <8 x i16>* %out) {
; CHECK-LABEL: vctp16:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vldrw.u32 q1, [r1]
; CHECK-NEXT:    vctp.16 r0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vstrw.32 q0, [r2]
; CHECK-NEXT:    bx lr
  %pred = call <8 x i1> @llvm.arm.vctp16(i32 %arg)
  %ld = load <8 x i16>, <8 x i16>* %in
  %res = select <8 x i1> %pred, <8 x i16> %ld, <8 x i16> zeroinitializer
  store <8 x i16> %res, <8 x i16>* %out
  ret void
}

define void @vctp32(i32 %arg, <4 x i32> *%in, <4 x i32>* %out) {
; CHECK-LABEL: vctp32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    vldrw.u32 q1, [r1]
; CHECK-NEXT:    vctp.32 r0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vstrw.32 q0, [r2]
; CHECK-NEXT:    bx lr
  %pred = call <4 x i1> @llvm.arm.vctp32(i32 %arg)
  %ld = load <4 x i32>, <4 x i32>* %in
  %res = select <4 x i1> %pred, <4 x i32> %ld, <4 x i32> zeroinitializer
  store <4 x i32> %res, <4 x i32>* %out
  ret void
}

declare <16 x i1> @llvm.arm.vctp8(i32)
declare <8 x i1> @llvm.arm.vctp16(i32)
declare <4 x i1> @llvm.arm.vctp32(i32)
