; RUN: llc -O1 -march=arm -mattr=+vfp2 < %s | FileCheck %s
; pr4939

define void @test(double* %x, double* %y) nounwind {
  %1 = load double* %x, align 4
  %2 = load double* %y, align 4
  %3 = fsub double -0.000000e+00, %1
  %4 = fcmp ugt double %2, %3
  br i1 %4, label %bb1, label %bb2

bb1:
;CHECK: vstrhi.64
  store double %1, double* %y, align 4
  br label %bb2

bb2:
  ret void
}
