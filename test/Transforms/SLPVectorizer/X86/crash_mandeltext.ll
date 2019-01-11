; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7 | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

define void @main() {
; CHECK-LABEL: @main(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br label [[FOR_COND4_PREHEADER:%.*]]
; CHECK:       for.cond4.preheader:
; CHECK-NEXT:    br label [[FOR_BODY6:%.*]]
; CHECK:       for.body6:
; CHECK-NEXT:    br label [[FOR_BODY12:%.*]]
; CHECK:       for.body12:
; CHECK-NEXT:    [[FZIMG_069:%.*]] = phi double [ undef, [[FOR_BODY6]] ], [ [[ADD19:%.*]], [[IF_END:%.*]] ]
; CHECK-NEXT:    [[FZREAL_068:%.*]] = phi double [ undef, [[FOR_BODY6]] ], [ [[ADD20:%.*]], [[IF_END]] ]
; CHECK-NEXT:    [[MUL13:%.*]] = fmul double [[FZREAL_068]], [[FZREAL_068]]
; CHECK-NEXT:    [[MUL14:%.*]] = fmul double [[FZIMG_069]], [[FZIMG_069]]
; CHECK-NEXT:    [[ADD15:%.*]] = fadd double [[MUL13]], [[MUL14]]
; CHECK-NEXT:    [[CMP16:%.*]] = fcmp ogt double [[ADD15]], 4.000000e+00
; CHECK-NEXT:    br i1 [[CMP16]], label [[FOR_INC21:%.*]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[MUL18:%.*]] = fmul double undef, [[FZIMG_069]]
; CHECK-NEXT:    [[ADD19]] = fadd double undef, [[MUL18]]
; CHECK-NEXT:    [[SUB:%.*]] = fsub double [[MUL13]], [[MUL14]]
; CHECK-NEXT:    [[ADD20]] = fadd double undef, [[SUB]]
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY12]], label [[FOR_INC21]]
; CHECK:       for.inc21:
; CHECK-NEXT:    br i1 undef, label [[FOR_END23:%.*]], label [[FOR_BODY6]]
; CHECK:       for.end23:
; CHECK-NEXT:    br i1 undef, label [[IF_THEN25:%.*]], label [[IF_THEN26:%.*]]
; CHECK:       if.then25:
; CHECK-NEXT:    br i1 undef, label [[FOR_END44:%.*]], label [[FOR_COND4_PREHEADER]]
; CHECK:       if.then26:
; CHECK-NEXT:    unreachable
; CHECK:       for.end44:
; CHECK-NEXT:    br i1 undef, label [[FOR_END48:%.*]], label [[FOR_BODY]]
; CHECK:       for.end48:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.end44, %entry
  br label %for.cond4.preheader

for.cond4.preheader:                              ; preds = %if.then25, %for.body
  br label %for.body6

for.body6:                                        ; preds = %for.inc21, %for.cond4.preheader
  br label %for.body12

for.body12:                                       ; preds = %if.end, %for.body6
  %fZImg.069 = phi double [ undef, %for.body6 ], [ %add19, %if.end ]
  %fZReal.068 = phi double [ undef, %for.body6 ], [ %add20, %if.end ]
  %mul13 = fmul double %fZReal.068, %fZReal.068
  %mul14 = fmul double %fZImg.069, %fZImg.069
  %add15 = fadd double %mul13, %mul14
  %cmp16 = fcmp ogt double %add15, 4.000000e+00
  br i1 %cmp16, label %for.inc21, label %if.end

if.end:                                           ; preds = %for.body12
  %mul18 = fmul double undef, %fZImg.069
  %add19 = fadd double undef, %mul18
  %sub = fsub double %mul13, %mul14
  %add20 = fadd double undef, %sub
  br i1 undef, label %for.body12, label %for.inc21

for.inc21:                                        ; preds = %if.end, %for.body12
  br i1 undef, label %for.end23, label %for.body6

for.end23:                                        ; preds = %for.inc21
  br i1 undef, label %if.then25, label %if.then26

if.then25:                                        ; preds = %for.end23
  br i1 undef, label %for.end44, label %for.cond4.preheader

if.then26:                                        ; preds = %for.end23
  unreachable

for.end44:                                        ; preds = %if.then25
  br i1 undef, label %for.end48, label %for.body

for.end48:                                        ; preds = %for.end44
  ret void
}

%struct.hoge = type { double, double, double}

define void @zot(%struct.hoge* %arg) {
; CHECK-LABEL: @zot(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = load double, double* undef, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = load double, double* undef, align 8
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x double> undef, double [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> [[TMP0]], double [[TMP]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = fsub <2 x double> [[TMP1]], undef
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [[STRUCT_HOGE:%.*]], %struct.hoge* [[ARG:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = fmul <2 x double> undef, [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = fsub <2 x double> [[TMP3]], undef
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast double* [[TMP7]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP4]], <2 x double>* [[TMP5]], align 8
; CHECK-NEXT:    br i1 undef, label [[BB11:%.*]], label [[BB12:%.*]]
; CHECK:       bb11:
; CHECK-NEXT:    br label [[BB14:%.*]]
; CHECK:       bb12:
; CHECK-NEXT:    br label [[BB14]]
; CHECK:       bb14:
; CHECK-NEXT:    ret void
;
bb:
  %tmp = load double, double* undef, align 8
  %tmp1 = fsub double %tmp, undef
  %tmp2 = load double, double* undef, align 8
  %tmp3 = fsub double %tmp2, undef
  %tmp4 = fmul double %tmp3, undef
  %tmp5 = fmul double %tmp3, undef
  %tmp6 = fsub double %tmp5, undef
  %tmp7 = getelementptr inbounds %struct.hoge, %struct.hoge* %arg, i64 0, i32 1
  store double %tmp6, double* %tmp7, align 8
  %tmp8 = fmul double %tmp1, undef
  %tmp9 = fsub double %tmp8, undef
  %tmp10 = getelementptr inbounds %struct.hoge, %struct.hoge* %arg, i64 0, i32 2
  store double %tmp9, double* %tmp10, align 8
  br i1 undef, label %bb11, label %bb12

bb11:                                             ; preds = %bb
  br label %bb14

bb12:                                             ; preds = %bb
  %tmp13 = fmul double undef, %tmp2
  br label %bb14

bb14:                                             ; preds = %bb12, %bb11
  ret void
}


%struct.rc4_state.0.24 = type { i32, i32, [256 x i32] }

define void @rc4_crypt(%struct.rc4_state.0.24* nocapture %s) {
; CHECK-LABEL: @rc4_crypt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X1:%.*]] = getelementptr inbounds [[STRUCT_RC4_STATE_0_24:%.*]], %struct.rc4_state.0.24* [[S:%.*]], i64 0, i32 0
; CHECK-NEXT:    [[Y2:%.*]] = getelementptr inbounds [[STRUCT_RC4_STATE_0_24]], %struct.rc4_state.0.24* [[S]], i64 0, i32 1
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[CONV4:%.*]] = and i32 undef, 255
; CHECK-NEXT:    [[CONV7:%.*]] = and i32 undef, 255
; CHECK-NEXT:    br i1 undef, label [[FOR_END]], label [[FOR_BODY]]
; CHECK:       for.end:
; CHECK-NEXT:    [[X_0_LCSSA:%.*]] = phi i32 [ undef, [[ENTRY:%.*]] ], [ [[CONV4]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[Y_0_LCSSA:%.*]] = phi i32 [ undef, [[ENTRY]] ], [ [[CONV7]], [[FOR_BODY]] ]
; CHECK-NEXT:    store i32 [[X_0_LCSSA]], i32* [[X1]], align 4
; CHECK-NEXT:    store i32 [[Y_0_LCSSA]], i32* [[Y2]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %x1 = getelementptr inbounds %struct.rc4_state.0.24, %struct.rc4_state.0.24* %s, i64 0, i32 0
  %y2 = getelementptr inbounds %struct.rc4_state.0.24, %struct.rc4_state.0.24* %s, i64 0, i32 1
  br i1 undef, label %for.body, label %for.end

for.body:                                         ; preds = %for.body, %entry
  %x.045 = phi i32 [ %conv4, %for.body ], [ undef, %entry ]
  %conv4 = and i32 undef, 255
  %conv7 = and i32 undef, 255
  %idxprom842 = zext i32 %conv7 to i64
  br i1 undef, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  %x.0.lcssa = phi i32 [ undef, %entry ], [ %conv4, %for.body ]
  %y.0.lcssa = phi i32 [ undef, %entry ], [ %conv7, %for.body ]
  store i32 %x.0.lcssa, i32* %x1, align 4
  store i32 %y.0.lcssa, i32* %y2, align 4
  ret void
}

