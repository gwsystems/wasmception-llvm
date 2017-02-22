; RUN: opt < %s  -loop-vectorize -force-vector-interleave=1 -force-vector-width=4 -dce -instcombine -S | FileCheck --check-prefix VEC4_INTERL1 %s
; RUN: opt < %s  -loop-vectorize -force-vector-interleave=2 -force-vector-width=4 -dce -instcombine -S | FileCheck --check-prefix VEC4_INTERL2 %s
; RUN: opt < %s  -loop-vectorize -force-vector-interleave=2 -force-vector-width=1 -dce -instcombine -S | FileCheck --check-prefix VEC1_INTERL2 %s
; RUN: opt < %s  -loop-vectorize -force-vector-interleave=1 -force-vector-width=2 -dce -simplifycfg -instcombine -S | FileCheck --check-prefix VEC2_INTERL1_PRED_STORE %s

; VEC4_INTERL1-LABEL: @fp_iv_loop1(
; VEC4_INTERL1:       %[[FP_INC:.*]] = load float, float* @fp_inc
; VEC4_INTERL1: vector.body:
; VEC4_INTERL1:       %[[FP_INDEX:.*]] = sitofp i64 {{.*}} to float
; VEC4_INTERL1:       %[[VEC_INCR:.*]] = fmul fast float {{.*}}, %[[FP_INDEX]]
; VEC4_INTERL1:       %[[FP_OFFSET_IDX:.*]] = fsub fast float %init, %[[VEC_INCR]]
; VEC4_INTERL1:       %[[BRCT_INSERT:.*]] = insertelement <4 x float> undef, float %[[FP_OFFSET_IDX]], i32 0
; VEC4_INTERL1-NEXT:  %[[BRCT_SPLAT:.*]] = shufflevector <4 x float> %[[BRCT_INSERT]], <4 x float> undef, <4 x i32> zeroinitializer
; VEC4_INTERL1:       %[[BRCT_INSERT:.*]] = insertelement {{.*}} %[[FP_INC]]
; VEC4_INTERL1-NEXT:  %[[FP_INC_BCST:.*]] = shufflevector <4 x float> %[[BRCT_INSERT]], {{.*}} zeroinitializer
; VEC4_INTERL1:       %[[VSTEP:.*]] = fmul fast <4 x float> %[[FP_INC_BCST]], <float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00>
; VEC4_INTERL1-NEXT:  %[[VEC_INDUCTION:.*]] = fsub fast <4 x float> %[[BRCT_SPLAT]], %[[VSTEP]]
; VEC4_INTERL1:       store <4 x float> %[[VEC_INDUCTION]]

; VEC4_INTERL2-LABEL: @fp_iv_loop1(
; VEC4_INTERL2:       %[[FP_INC:.*]] = load float, float* @fp_inc
; VEC4_INTERL2: vector.body:
; VEC4_INTERL2:       %[[INDEX:.*]] = sitofp i64 {{.*}} to float
; VEC4_INTERL2:       %[[VEC_INCR:.*]] = fmul fast float %{{.*}}, %[[INDEX]]
; VEC4_INTERL2:       fsub fast float %init, %[[VEC_INCR]]
; VEC4_INTERL2:       %[[VSTEP1:.*]] = fmul fast <4 x float> %{{.*}}, <float 0.000000e+00, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00>
; VEC4_INTERL2-NEXT:  %[[VEC_INDUCTION1:.*]] = fsub fast <4 x float> {{.*}}, %[[VSTEP1]]
; VEC4_INTERL2:       %[[VSTEP2:.*]] = fmul fast <4 x float> %{{.*}}, <float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00>
; VEC4_INTERL2-NEXT:  %[[VEC_INDUCTION2:.*]] = fsub fast <4 x float> {{.*}}, %[[VSTEP2]]
; VEC4_INTERL2:       store <4 x float> %[[VEC_INDUCTION1]]
; VEC4_INTERL2:       store <4 x float> %[[VEC_INDUCTION2]]

; VEC1_INTERL2-LABEL: @fp_iv_loop1(
; VEC1_INTERL2:       %[[FP_INC:.*]] = load float, float* @fp_inc
; VEC1_INTERL2: vector.body:
; VEC1_INTERL2:         %[[INDEX:.*]] = sitofp i64 {{.*}} to float
; VEC1_INTERL2:         %[[STEP:.*]] = fmul fast float %{{.*}}, %[[INDEX]]
; VEC1_INTERL2:         %[[FP_OFFSET_IDX:.*]] = fsub fast float %init, %[[STEP]]
; VEC1_INTERL2:         %[[SCALAR_INDUCTION2:.*]] = fsub fast float %[[FP_OFFSET_IDX]], %[[FP_INC]]
; VEC1_INTERL2:         store float %[[FP_OFFSET_IDX]]
; VEC1_INTERL2:         store float %[[SCALAR_INDUCTION2]]

@fp_inc = common global float 0.000000e+00, align 4

;void fp_iv_loop1(float init, float * __restrict__ A, int N) {
;  float x = init;
;  for (int i=0; i < N; ++i) {
;    A[i] = x;
;    x -= fp_inc;
;  }
;}

define void @fp_iv_loop1(float %init, float* noalias nocapture %A, i32 %N) #1 {
entry:
  %cmp4 = icmp sgt i32 %N, 0
  br i1 %cmp4, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  %fpinc = load float, float* @fp_inc, align 4
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %x.05 = phi float [ %init, %for.body.lr.ph ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds float, float* %A, i64 %indvars.iv
  store float %x.05, float* %arrayidx, align 4
  %add = fsub fast float %x.05, %fpinc
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %for.end.loopexit, label %for.body

for.end.loopexit:                                 ; preds = %for.body
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %entry
  ret void
}

;void fp_iv_loop2(float init, float * __restrict__ A, int N) {
;  float x = init;
;  for (int i=0; i < N; ++i) {
;    A[i] = x;
;    x += 0.5;
;  }
;}

; VEC4_INTERL1-LABEL: @fp_iv_loop2(
; VEC4_INTERL1: vector.body
; VEC4_INTERL1:  %[[index:.*]] = phi i64 [ 0, %vector.ph ]
; VEC4_INTERL1: sitofp i64 %[[index]] to float
; VEC4_INTERL1: %[[VAR1:.*]] = fmul fast float {{.*}}, 5.000000e-01
; VEC4_INTERL1: %[[VAR2:.*]] = fadd fast float %[[VAR1]]
; VEC4_INTERL1:  insertelement <4 x float> undef, float %[[VAR2]], i32 0
; VEC4_INTERL1:  shufflevector <4 x float> {{.*}}, <4 x float> undef, <4 x i32> zeroinitializer
; VEC4_INTERL1:  fadd fast <4 x float> {{.*}}, <float 0.000000e+00, float 5.000000e-01, float 1.000000e+00, float 1.500000e+00>
; VEC4_INTERL1:  store <4 x float> 

define void @fp_iv_loop2(float %init, float* noalias nocapture %A, i32 %N) #0 {
entry:
  %cmp4 = icmp sgt i32 %N, 0
  br i1 %cmp4, label %for.body.preheader, label %for.end

for.body.preheader:                               ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %for.body.preheader ]
  %x.06 = phi float [ %conv1, %for.body ], [ %init, %for.body.preheader ]
  %arrayidx = getelementptr inbounds float, float* %A, i64 %indvars.iv
  store float %x.06, float* %arrayidx, align 4
  %conv1 = fadd fast float %x.06, 5.000000e-01
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %for.end.loopexit, label %for.body

for.end.loopexit:                                 ; preds = %for.body
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %entry
  ret void
}

;void fp_iv_loop3(float init, float * __restrict__ A, float * __restrict__ B, float * __restrict__ C, int N) {
;  int i = 0;
;  float x = init;
;  float y = 0.1;
;  for (; i < N; ++i) {
;    A[i] = x;
;    x += fp_inc;
;    y -= 0.5;
;    B[i] = x + y;
;    C[i] = y;
;  }
;}
; VEC4_INTERL1-LABEL: @fp_iv_loop3(
; VEC4_INTERL1: vector.body
; VEC4_INTERL1:  %[[index:.*]] = phi i64 [ 0, %vector.ph ]
; VEC4_INTERL1: sitofp i64 %[[index]] to float
; VEC4_INTERL1: %[[VAR1:.*]] = fmul fast float {{.*}}, -5.000000e-01
; VEC4_INTERL1:  fadd fast float %[[VAR1]]
; VEC4_INTERL1:  fadd fast <4 x float> {{.*}}, <float -5.000000e-01, float -1.000000e+00, float -1.500000e+00, float -2.000000e+00>
; VEC4_INTERL1:  store <4 x float>

define void @fp_iv_loop3(float %init, float* noalias nocapture %A, float* noalias nocapture %B, float* noalias nocapture %C, i32 %N) #1 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  %0 = load float, float* @fp_inc, align 4
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %y.012 = phi float [ 0x3FB99999A0000000, %for.body.lr.ph ], [ %conv1, %for.body ]
  %x.011 = phi float [ %init, %for.body.lr.ph ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds float, float* %A, i64 %indvars.iv
  store float %x.011, float* %arrayidx, align 4
  %add = fadd fast float %x.011, %0
  %conv1 = fadd fast float %y.012, -5.000000e-01
  %add2 = fadd fast float %conv1, %add
  %arrayidx4 = getelementptr inbounds float, float* %B, i64 %indvars.iv
  store float %add2, float* %arrayidx4, align 4
  %arrayidx6 = getelementptr inbounds float, float* %C, i64 %indvars.iv
  store float %conv1, float* %arrayidx6, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %for.end.loopexit, label %for.body

for.end.loopexit:                                 
  br label %for.end

for.end: 
  ret void
}

; Start and step values are constants. There is no 'fmul' operation in this case
;void fp_iv_loop4(float * __restrict__ A, int N) {
;  float x = 1.0;
;  for (int i=0; i < N; ++i) {
;    A[i] = x;
;    x += 0.5;
;  }
;}

; VEC4_INTERL1-LABEL: @fp_iv_loop4(
; VEC4_INTERL1: vector.body
; VEC4_INTERL1-NOT: fmul fast <4 x float>
; VEC4_INTERL1:  %[[induction:.*]] = fadd fast <4 x float> %{{.*}}, <float 0.000000e+00, float 5.000000e-01, float 1.000000e+00, float 1.500000e+00>
; VEC4_INTERL1: store <4 x float> %[[induction]]

define void @fp_iv_loop4(float* noalias nocapture %A, i32 %N) {
entry:
  %cmp4 = icmp sgt i32 %N, 0
  br i1 %cmp4, label %for.body.preheader, label %for.end

for.body.preheader:                               ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %for.body.preheader ]
  %x.06 = phi float [ %conv1, %for.body ], [ 1.000000e+00, %for.body.preheader ]
  %arrayidx = getelementptr inbounds float, float* %A, i64 %indvars.iv
  store float %x.06, float* %arrayidx, align 4
  %conv1 = fadd fast float %x.06, 5.000000e-01
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %N
  br i1 %exitcond, label %for.end.loopexit, label %for.body

for.end.loopexit:                                 ; preds = %for.body
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %entry
  ret void
}

; VEC2_INTERL1_PRED_STORE-LABEL: @non_primary_iv_float_scalar(
; VEC2_INTERL1_PRED_STORE:       vector.body:
; VEC2_INTERL1_PRED_STORE-NEXT:    [[INDEX:%.*]] = phi i64 [ [[INDEX_NEXT:%.*]], %[[PRED_STORE_CONTINUE7:.*]] ], [ 0, %min.iters.checked ]
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP1:%.*]] = sitofp i64 [[INDEX]] to float
; VEC2_INTERL1_PRED_STORE-NEXT:    [[BROADCAST_SPLATINSERT3:%.*]] = insertelement <2 x float> undef, float [[TMP1]], i32 0
; VEC2_INTERL1_PRED_STORE-NEXT:    [[BROADCAST_SPLAT4:%.*]] = shufflevector <2 x float> [[BROADCAST_SPLATINSERT3]], <2 x float> undef, <2 x i32> zeroinitializer
; VEC2_INTERL1_PRED_STORE-NEXT:    [[INDUCTION5:%.*]] = fadd fast <2 x float> [[BROADCAST_SPLAT4]], <float 0.000000e+00, float 1.000000e+00>
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP2:%.*]] = getelementptr inbounds float, float* %A, i64 [[INDEX]]
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP3:%.*]] = bitcast float* [[TMP2]] to <2 x float>*
; VEC2_INTERL1_PRED_STORE-NEXT:    [[WIDE_LOAD:%.*]] = load <2 x float>, <2 x float>* [[TMP3]], align 4
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP4:%.*]] = fcmp fast oeq <2 x float> [[WIDE_LOAD]], zeroinitializer
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP5:%.*]] = extractelement <2 x i1> [[TMP4]], i32 0
; VEC2_INTERL1_PRED_STORE-NEXT:    br i1 [[TMP5]], label %[[PRED_STORE_IF:.*]], label %[[PRED_STORE_CONTINUE:.*]]
; VEC2_INTERL1_PRED_STORE:       [[PRED_STORE_IF]]:
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP6:%.*]] = extractelement <2 x float> [[INDUCTION5]], i32 0
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP7:%.*]] = getelementptr inbounds float, float* %A, i64 [[INDEX]]
; VEC2_INTERL1_PRED_STORE-NEXT:    store float [[TMP6]], float* [[TMP7]], align 4
; VEC2_INTERL1_PRED_STORE-NEXT:    br label %[[PRED_STORE_CONTINUE]]
; VEC2_INTERL1_PRED_STORE:       [[PRED_STORE_CONTINUE]]:
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP8:%.*]] = extractelement <2 x i1> [[TMP4]], i32 1
; VEC2_INTERL1_PRED_STORE-NEXT:    br i1 [[TMP8]], label %[[PRED_STORE_IF6:.*]], label %[[PRED_STORE_CONTINUE7]]
; VEC2_INTERL1_PRED_STORE:       [[PRED_STORE_IF6]]:
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP9:%.*]] = extractelement <2 x float> [[INDUCTION5]], i32 1
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP10:%.*]] = or i64 [[INDEX]], 1
; VEC2_INTERL1_PRED_STORE-NEXT:    [[TMP11:%.*]] = getelementptr inbounds float, float* %A, i64 [[TMP10]]
; VEC2_INTERL1_PRED_STORE-NEXT:    store float [[TMP9]], float* [[TMP11]], align 4
; VEC2_INTERL1_PRED_STORE-NEXT:    br label %[[PRED_STORE_CONTINUE7]]
; VEC2_INTERL1_PRED_STORE:       [[PRED_STORE_CONTINUE7]]:
; VEC2_INTERL1_PRED_STORE-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 2
; VEC2_INTERL1_PRED_STORE:         br i1 {{.*}}, label %middle.block, label %vector.body

define void @non_primary_iv_float_scalar(float* %A, i64 %N) {
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.inc ], [ 0, %entry ]
  %j = phi float [ %j.next, %for.inc ], [ 0.0, %entry ]
  %tmp0 = getelementptr inbounds float, float* %A, i64 %i
  %tmp1 = load float, float* %tmp0, align 4
  %tmp2 = fcmp fast oeq float %tmp1, 0.0
  br i1 %tmp2, label %if.pred, label %for.inc

if.pred:
  store float %j, float* %tmp0, align 4
  br label %for.inc

for.inc:
  %i.next = add nuw nsw i64 %i, 1
  %j.next = fadd fast float %j, 1.0
  %cond = icmp slt i64 %i.next, %N
  br i1 %cond, label %for.body, label %for.end

for.end:
  ret void
}
