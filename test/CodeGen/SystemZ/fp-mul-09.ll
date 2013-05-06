; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

declare double @llvm.fma.f64(double %f1, double %f2, double %f3)

define double @f1(double %f1, double %f2, double %acc) {
; CHECK: f1:
; CHECK: msdbr %f4, %f0, %f2
; CHECK: ldr %f0, %f4
; CHECK: br %r14
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f2(double %f1, double *%ptr, double %acc) {
; CHECK: f2:
; CHECK: msdb %f2, %f0, 0(%r2)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f3(double %f1, double *%base, double %acc) {
; CHECK: f3:
; CHECK: msdb %f2, %f0, 4088(%r2)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 511
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f4(double %f1, double *%base, double %acc) {
; The important thing here is that we don't generate an out-of-range
; displacement.  Other sequences besides this one would be OK.
;
; CHECK: f4:
; CHECK: aghi %r2, 4096
; CHECK: msdb %f2, %f0, 0(%r2)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 512
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f5(double %f1, double *%base, double %acc) {
; Here too the important thing is that we don't generate an out-of-range
; displacement.  Other sequences besides this one would be OK.
;
; CHECK: f5:
; CHECK: aghi %r2, -8
; CHECK: msdb %f2, %f0, 0(%r2)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 -1
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f6(double %f1, double *%base, i64 %index, double %acc) {
; CHECK: f6:
; CHECK: sllg %r1, %r3, 3
; CHECK: msdb %f2, %f0, 0(%r1,%r2)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %ptr = getelementptr double *%base, i64 %index
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f7(double %f1, double *%base, i64 %index, double %acc) {
; CHECK: f7:
; CHECK: sllg %r1, %r3, 3
; CHECK: msdb %f2, %f0, 4088({{%r1,%r2|%r2,%r1}})
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %index2 = add i64 %index, 511
  %ptr = getelementptr double *%base, i64 %index2
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}

define double @f8(double %f1, double *%base, i64 %index, double %acc) {
; CHECK: f8:
; CHECK: sllg %r1, %r3, 3
; CHECK: lay %r1, 4096({{%r1,%r2|%r2,%r1}})
; CHECK: msdb %f2, %f0, 0(%r1)
; CHECK: ldr %f0, %f2
; CHECK: br %r14
  %index2 = add i64 %index, 512
  %ptr = getelementptr double *%base, i64 %index2
  %f2 = load double *%ptr
  %negacc = fsub double -0.0, %acc
  %res = call double @llvm.fma.f64 (double %f1, double %f2, double %negacc)
  ret double %res
}
