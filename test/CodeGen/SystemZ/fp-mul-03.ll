; Test multiplication of two f64s, producing an f64 result.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

declare double @foo()

; Check register multiplication.
define double @f1(double %f1, double %f2) {
; CHECK: f1:
; CHECK: mdbr %f0, %f2
; CHECK: br %r14
  %res = fmul double %f1, %f2
  ret double %res
}

; Check the low end of the MDB range.
define double @f2(double %f1, double *%ptr) {
; CHECK: f2:
; CHECK: mdb %f0, 0(%r2)
; CHECK: br %r14
  %f2 = load double *%ptr
  %res = fmul double %f1, %f2
  ret double %res
}

; Check the high end of the aligned MDB range.
define double @f3(double %f1, double *%base) {
; CHECK: f3:
; CHECK: mdb %f0, 4088(%r2)
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 511
  %f2 = load double *%ptr
  %res = fmul double %f1, %f2
  ret double %res
}

; Check the next doubleword up, which needs separate address logic.
; Other sequences besides this one would be OK.
define double @f4(double %f1, double *%base) {
; CHECK: f4:
; CHECK: aghi %r2, 4096
; CHECK: mdb %f0, 0(%r2)
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 512
  %f2 = load double *%ptr
  %res = fmul double %f1, %f2
  ret double %res
}

; Check negative displacements, which also need separate address logic.
define double @f5(double %f1, double *%base) {
; CHECK: f5:
; CHECK: aghi %r2, -8
; CHECK: mdb %f0, 0(%r2)
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 -1
  %f2 = load double *%ptr
  %res = fmul double %f1, %f2
  ret double %res
}

; Check that MDB allows indices.
define double @f6(double %f1, double *%base, i64 %index) {
; CHECK: f6:
; CHECK: sllg %r1, %r3, 3
; CHECK: mdb %f0, 800(%r1,%r2)
; CHECK: br %r14
  %ptr1 = getelementptr double *%base, i64 %index
  %ptr2 = getelementptr double *%ptr1, i64 100
  %f2 = load double *%ptr2
  %res = fmul double %f1, %f2
  ret double %res
}

; Check that multiplications of spilled values can use MDB rather than MDBR.
define double @f7(double *%ptr0) {
; CHECK: f7:
; CHECK: brasl %r14, foo@PLT
; CHECK: mdb %f0, 160(%r15)
; CHECK: br %r14
  %ptr1 = getelementptr double *%ptr0, i64 2
  %ptr2 = getelementptr double *%ptr0, i64 4
  %ptr3 = getelementptr double *%ptr0, i64 6
  %ptr4 = getelementptr double *%ptr0, i64 8
  %ptr5 = getelementptr double *%ptr0, i64 10
  %ptr6 = getelementptr double *%ptr0, i64 12
  %ptr7 = getelementptr double *%ptr0, i64 14
  %ptr8 = getelementptr double *%ptr0, i64 16
  %ptr9 = getelementptr double *%ptr0, i64 18
  %ptr10 = getelementptr double *%ptr0, i64 20

  %val0 = load double *%ptr0
  %val1 = load double *%ptr1
  %val2 = load double *%ptr2
  %val3 = load double *%ptr3
  %val4 = load double *%ptr4
  %val5 = load double *%ptr5
  %val6 = load double *%ptr6
  %val7 = load double *%ptr7
  %val8 = load double *%ptr8
  %val9 = load double *%ptr9
  %val10 = load double *%ptr10

  %ret = call double @foo()

  %mul0 = fmul double %ret, %val0
  %mul1 = fmul double %mul0, %val1
  %mul2 = fmul double %mul1, %val2
  %mul3 = fmul double %mul2, %val3
  %mul4 = fmul double %mul3, %val4
  %mul5 = fmul double %mul4, %val5
  %mul6 = fmul double %mul5, %val6
  %mul7 = fmul double %mul6, %val7
  %mul8 = fmul double %mul7, %val8
  %mul9 = fmul double %mul8, %val9
  %mul10 = fmul double %mul9, %val10

  ret double %mul10
}
