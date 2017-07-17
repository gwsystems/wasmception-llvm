; Test vector negative multiply-and-add on z14.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu -mcpu=z14 | FileCheck %s

declare <2 x double> @llvm.fma.v2f64(<2 x double>, <2 x double>, <2 x double>)

; Test a v2f64 negative multiply-and-add.
define <2 x double> @f1(<2 x double> %dummy, <2 x double> %val1,
                        <2 x double> %val2, <2 x double> %val3) {
; CHECK-LABEL: f1:
; CHECK: vfnmadb %v24, %v26, %v28, %v30
; CHECK: br %r14
  %ret = call <2 x double> @llvm.fma.v2f64 (<2 x double> %val1,
                                            <2 x double> %val2,
                                            <2 x double> %val3)
  %negret = fsub <2 x double> <double -0.0, double -0.0>, %ret
  ret <2 x double> %negret
}

; Test a v2f64 negative multiply-and-subtract.
define <2 x double> @f2(<2 x double> %dummy, <2 x double> %val1,
                        <2 x double> %val2, <2 x double> %val3) {
; CHECK-LABEL: f2:
; CHECK: vfnmsdb %v24, %v26, %v28, %v30
; CHECK: br %r14
  %negval3 = fsub <2 x double> <double -0.0, double -0.0>, %val3
  %ret = call <2 x double> @llvm.fma.v2f64 (<2 x double> %val1,
                                            <2 x double> %val2,
                                            <2 x double> %negval3)
  %negret = fsub <2 x double> <double -0.0, double -0.0>, %ret
  ret <2 x double> %negret
}
