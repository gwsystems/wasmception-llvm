; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -bb-vectorize -bb-vectorize-req-chain-depth=3 -bb-vectorize-vector-bits=192 -bb-vectorize-ignore-target-info -instcombine -gvn -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128"

; Basic depth-3 chain
define double @test1(double %A1, double %A2, double %A3, double %B1, double %B2, double %B3) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[X1_V_I1_11:%.*]] = insertelement <3 x double> undef, double [[B1:%.*]], i32 0
; CHECK-NEXT:    [[X1_V_I1_22:%.*]] = insertelement <3 x double> [[X1_V_I1_11]], double [[B2:%.*]], i32 1
; CHECK-NEXT:    [[X1_V_I1:%.*]] = insertelement <3 x double> [[X1_V_I1_22]], double [[B3:%.*]], i32 2
; CHECK-NEXT:    [[X1_V_I0_13:%.*]] = insertelement <3 x double> undef, double [[A1:%.*]], i32 0
; CHECK-NEXT:    [[X1_V_I0_24:%.*]] = insertelement <3 x double> [[X1_V_I0_13]], double [[A2:%.*]], i32 1
; CHECK-NEXT:    [[X1_V_I0:%.*]] = insertelement <3 x double> [[X1_V_I0_24]], double [[A3:%.*]], i32 2
; CHECK-NEXT:    [[X1:%.*]] = fsub <3 x double> [[X1_V_I0]], [[X1_V_I1]]
; CHECK-NEXT:    [[Y1:%.*]] = fmul <3 x double> [[X1]], [[X1_V_I0]]
; CHECK-NEXT:    [[Z1:%.*]] = fadd <3 x double> [[Y1]], [[X1_V_I1]]
; CHECK-NEXT:    [[Z1_V_R210:%.*]] = extractelement <3 x double> [[Z1]], i32 2
; CHECK-NEXT:    [[Z1_V_R1:%.*]] = extractelement <3 x double> [[Z1]], i32 0
; CHECK-NEXT:    [[Z1_V_R2:%.*]] = extractelement <3 x double> [[Z1]], i32 1
; CHECK-NEXT:    [[R1:%.*]] = fmul double [[Z1_V_R1]], [[Z1_V_R2]]
; CHECK-NEXT:    [[R:%.*]] = fmul double [[R1]], [[Z1_V_R210]]
; CHECK-NEXT:    ret double [[R]]
;
  %X1 = fsub double %A1, %B1
  %X2 = fsub double %A2, %B2
  %X3 = fsub double %A3, %B3
  %Y1 = fmul double %X1, %A1
  %Y2 = fmul double %X2, %A2
  %Y3 = fmul double %X3, %A3
  %Z1 = fadd double %Y1, %B1
  %Z2 = fadd double %Y2, %B2
  %Z3 = fadd double %Y3, %B3
  %R1 = fmul double %Z1, %Z2
  %R  = fmul double %R1, %Z3
  ret double %R
}

