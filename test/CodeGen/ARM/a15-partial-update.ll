; RUN: llc -O1 -mcpu=cortex-a15 -mtriple=armv7-linux-gnueabi -verify-machineinstrs < %s  | FileCheck %s

; CHECK-LABEL: t1:
define <2 x float> @t1(float* %A, <2 x float> %B) {
; The generated code for this test uses a vld1.32 instruction
; to write the lane 1 of a D register containing the value of
; <2 x float> %B. Since the D register is defined, it would
; be incorrect to fully write it (with a vmov.f64) before the
; vld1.32 instruction. The test checks that a vmov.f64 was not
; generated.

; CHECK-NOT: vmov.{{.*}} d{{[0-9]+}},
  %tmp2 = load float* %A, align 4
  %tmp3 = insertelement <2 x float> %B, float %tmp2, i32 1
  ret <2 x float> %tmp3
}

; CHECK-LABEL: t2:
define void @t2(<4 x i8> *%in, <4 x i8> *%out, i32 %n) {
entry:
  br label %loop
loop:
; The code generated by this test uses a vld1.32 instruction.
; We check that a dependency breaking vmov* instruction was
; generated.

; CHECK: vmov.{{.*}} d{{[0-9]+}},
  %oldcount = phi i32 [0, %entry], [%newcount, %loop]
  %newcount = add i32 %oldcount, 1
  %p1 = getelementptr <4 x i8>, <4 x i8> *%in, i32 %newcount
  %p2 = getelementptr <4 x i8>, <4 x i8> *%out, i32 %newcount
  %tmp1 = load <4 x i8> *%p1, align 4
  store <4 x i8> %tmp1, <4 x i8> *%p2
  %cmp = icmp eq i32 %newcount, %n
  br i1 %cmp, label %loop, label %ret
ret:
  ret void
}
