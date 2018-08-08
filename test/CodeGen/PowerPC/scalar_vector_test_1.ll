; RUN: llc -mcpu=pwr9 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:		-mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P9LE
; RUN: llc -mcpu=pwr9 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P9BE
; RUN: llc -mcpu=pwr8 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P8LE
; RUN: llc -mcpu=pwr8 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P8BE

; Function Attrs: norecurse nounwind readonly
define <2 x i64> @s2v_test1(i64* nocapture readonly %int64, <2 x i64> %vec) {
; P9LE-LABEL: s2v_test1:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 0(r3)
; P9LE-NEXT:    xxpermdi v3, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, v3, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test1:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 0(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr
entry:
  %0 = load i64, i64* %int64, align 8
  %vecins = insertelement <2 x i64> %vec, i64 %0, i32 0
  ret <2 x i64> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x i64> @s2v_test2(i64* nocapture readonly %int64, <2 x i64> %vec)  {
; P9LE-LABEL: s2v_test2:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 8(r3)
; P9LE-NEXT:    xxpermdi v3, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, v3, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test2:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 8(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i64, i64* %int64, i64 1
  %0 = load i64, i64* %arrayidx, align 8
  %vecins = insertelement <2 x i64> %vec, i64 %0, i32 0
  ret <2 x i64> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x i64> @s2v_test3(i64* nocapture readonly %int64, <2 x i64> %vec, i32 signext %Idx)  {
; P9LE-LABEL: s2v_test3:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    sldi r4, r7, 3
; P9LE-NEXT:    lfdx f0, r3, r4
; P9LE-NEXT:    xxpermdi v3, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, v3, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test3
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    sldi r4, r7, 3
; P9BE-NEXT:    lfdx f0, r3, r4
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr
entry:
  %idxprom = sext i32 %Idx to i64
  %arrayidx = getelementptr inbounds i64, i64* %int64, i64 %idxprom
  %0 = load i64, i64* %arrayidx, align 8
  %vecins = insertelement <2 x i64> %vec, i64 %0, i32 0
  ret <2 x i64> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x i64> @s2v_test4(i64* nocapture readonly %int64, <2 x i64> %vec)  {
; P9LE-LABEL: s2v_test4:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 8(r3)
; P9LE-NEXT:    xxpermdi v3, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, v3, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test4:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 8(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i64, i64* %int64, i64 1
  %0 = load i64, i64* %arrayidx, align 8
  %vecins = insertelement <2 x i64> %vec, i64 %0, i32 0
  ret <2 x i64> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x i64> @s2v_test5(<2 x i64> %vec, i64* nocapture readonly %ptr1)  {
; P9LE-LABEL: s2v_test5:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 0(r5)
; P9LE-NEXT:    xxpermdi v3, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, v3, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test5:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 0(r5)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr
entry:
  %0 = load i64, i64* %ptr1, align 8
  %vecins = insertelement <2 x i64> %vec, i64 %0, i32 0
  ret <2 x i64> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x double> @s2v_test_f1(double* nocapture readonly %f64, <2 x double> %vec)  {
; P9LE-LABEL: s2v_test_f1:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 0(r3)
; P9LE-NEXT:    xxpermdi vs0, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test_f1:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 0(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr

; P8LE-LABEL: s2v_test_f1:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    lfdx f0, 0, r3
; P8LE-NEXT:    xxspltd vs0, vs0, 0
; P8LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P8LE-NEXT:    blr

; P8BE-LABEL: s2v_test_f1:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lfdx f0, 0, r3
; P8BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P8BE-NEXT:    blr
entry:
  %0 = load double, double* %f64, align 8
  %vecins = insertelement <2 x double> %vec, double %0, i32 0
  ret <2 x double> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x double> @s2v_test_f2(double* nocapture readonly %f64, <2 x double> %vec)  {
; P9LE-LABEL: s2v_test_f2:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 8(r3)
; P9LE-NEXT:    xxpermdi vs0, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test_f2:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 8(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr

; P8LE-LABEL: s2v_test_f2:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addi r3, r3, 8
; P8LE-NEXT:    lfdx f0, 0, r3
; P8LE-NEXT:    xxspltd vs0, vs0, 0
; P8LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P8LE-NEXT:    blr

; P8BE-LABEL: s2v_test_f2:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 8
; P8BE-NEXT:    lfdx f0, 0, r3
; P8BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds double, double* %f64, i64 1
  %0 = load double, double* %arrayidx, align 8
  %vecins = insertelement <2 x double> %vec, double %0, i32 0
  ret <2 x double> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x double> @s2v_test_f3(double* nocapture readonly %f64, <2 x double> %vec, i32 signext %Idx)  {
; P9LE-LABEL: s2v_test_f3:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    sldi r4, r7, 3
; P9LE-NEXT:    lfdx f0, r3, r4
; P9LE-NEXT:    xxpermdi vs0, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test_f3:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    sldi r4, r7, 3
; P9BE-NEXT:    lfdx f0, r3, r4
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr

; P8LE-LABEL: s2v_test_f3:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    sldi r4, r7, 3
; P8LE-NEXT:    lfdx f0, r3, r4
; P8LE-NEXT:    xxspltd vs0, vs0, 0
; P8LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P8LE-NEXT:    blr

; P8BE-LABEL: s2v_test_f3:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    sldi r4, r7, 3
; P8BE-NEXT:    lfdx f0, r3, r4
; P8BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P8BE-NEXT:    blr
entry:
  %idxprom = sext i32 %Idx to i64
  %arrayidx = getelementptr inbounds double, double* %f64, i64 %idxprom
  %0 = load double, double* %arrayidx, align 8
  %vecins = insertelement <2 x double> %vec, double %0, i32 0
  ret <2 x double> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x double> @s2v_test_f4(double* nocapture readonly %f64, <2 x double> %vec)  {
; P9LE-LABEL: s2v_test_f4:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 8(r3)
; P9LE-NEXT:    xxpermdi vs0, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test_f4:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 8(r3)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr

; P8LE-LABEL: s2v_test_f4:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addi r3, r3, 8
; P8LE-NEXT:    lfdx f0, 0, r3
; P8LE-NEXT:    xxspltd vs0, vs0, 0
; P8LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P8LE-NEXT:    blr

; P8BE-LABEL: s2v_test_f4:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 8
; P8BE-NEXT:    lfdx f0, 0, r3
; P8BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds double, double* %f64, i64 1
  %0 = load double, double* %arrayidx, align 8
  %vecins = insertelement <2 x double> %vec, double %0, i32 0
  ret <2 x double> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x double> @s2v_test_f5(<2 x double> %vec, double* nocapture readonly %ptr1)  {
; P9LE-LABEL: s2v_test_f5:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfd f0, 0(r5)
; P9LE-NEXT:    xxpermdi vs0, f0, f0, 2
; P9LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P9LE-NEXT:    blr

; P9BE-LABEL: s2v_test_f5:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lfd f0, 0(r5)
; P9BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P9BE-NEXT:    blr

; P8LE-LABEL: s2v_test_f5:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    lfdx f0, 0, r5
; P8LE-NEXT:    xxspltd vs0, vs0, 0
; P8LE-NEXT:    xxpermdi v2, v2, vs0, 1
; P8LE-NEXT:    blr

; P8BE-LABEL: s2v_test_f5:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lfdx f0, 0, r5
; P8BE-NEXT:    xxpermdi v2, vs0, v2, 1
; P8BE-NEXT:    blr
entry:
  %0 = load double, double* %ptr1, align 8
  %vecins = insertelement <2 x double> %vec, double %0, i32 0
  ret <2 x double> %vecins
}

