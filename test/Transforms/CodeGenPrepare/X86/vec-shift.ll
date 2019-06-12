; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -codegenprepare -mtriple=x86_64-- -mattr=avx -S < %s | FileCheck %s --check-prefixes=ALL,AVX
; RUN: opt -codegenprepare -mtriple=x86_64-- -mattr=avx2 -S < %s | FileCheck %s --check-prefixes=ALL,AVX2

; PR37428 - https://bugs.llvm.org/show_bug.cgi?id=37428

define void @vector_variable_shift_left_loop(i32* nocapture %arr, i8* nocapture readonly %control, i32 %count, i32 %amt0, i32 %amt1, i32 %x) {
; AVX-LABEL: @vector_variable_shift_left_loop(
; AVX-NEXT:  entry:
; AVX-NEXT:    [[CMP16:%.*]] = icmp sgt i32 [[COUNT:%.*]], 0
; AVX-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[COUNT]] to i64
; AVX-NEXT:    br i1 [[CMP16]], label [[VECTOR_PH:%.*]], label [[EXIT:%.*]]
; AVX:       vector.ph:
; AVX-NEXT:    [[N_VEC:%.*]] = and i64 [[WIDE_TRIP_COUNT]], 4294967292
; AVX-NEXT:    [[SPLATINSERT18:%.*]] = insertelement <4 x i32> undef, i32 [[AMT0:%.*]], i32 0
; AVX-NEXT:    [[SPLAT1:%.*]] = shufflevector <4 x i32> [[SPLATINSERT18]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX-NEXT:    [[SPLATINSERT20:%.*]] = insertelement <4 x i32> undef, i32 [[AMT1:%.*]], i32 0
; AVX-NEXT:    [[SPLAT2:%.*]] = shufflevector <4 x i32> [[SPLATINSERT20]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX-NEXT:    [[SPLATINSERT22:%.*]] = insertelement <4 x i32> undef, i32 [[X:%.*]], i32 0
; AVX-NEXT:    br label [[VECTOR_BODY:%.*]]
; AVX:       vector.body:
; AVX-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; AVX-NEXT:    [[TMP0:%.*]] = shufflevector <4 x i32> [[SPLATINSERT22]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, i8* [[CONTROL:%.*]], i64 [[INDEX]]
; AVX-NEXT:    [[TMP2:%.*]] = bitcast i8* [[TMP1]] to <4 x i8>*
; AVX-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i8>, <4 x i8>* [[TMP2]], align 1
; AVX-NEXT:    [[TMP3:%.*]] = icmp eq <4 x i8> [[WIDE_LOAD]], zeroinitializer
; AVX-NEXT:    [[TMP4:%.*]] = select <4 x i1> [[TMP3]], <4 x i32> [[SPLAT1]], <4 x i32> [[SPLAT2]]
; AVX-NEXT:    [[TMP5:%.*]] = shl <4 x i32> [[TMP0]], [[TMP4]]
; AVX-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, i32* [[ARR:%.*]], i64 [[INDEX]]
; AVX-NEXT:    [[TMP7:%.*]] = bitcast i32* [[TMP6]] to <4 x i32>*
; AVX-NEXT:    store <4 x i32> [[TMP5]], <4 x i32>* [[TMP7]], align 4
; AVX-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 4
; AVX-NEXT:    [[TMP8:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; AVX-NEXT:    br i1 [[TMP8]], label [[EXIT]], label [[VECTOR_BODY]]
; AVX:       exit:
; AVX-NEXT:    ret void
;
; AVX2-LABEL: @vector_variable_shift_left_loop(
; AVX2-NEXT:  entry:
; AVX2-NEXT:    [[CMP16:%.*]] = icmp sgt i32 [[COUNT:%.*]], 0
; AVX2-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[COUNT]] to i64
; AVX2-NEXT:    br i1 [[CMP16]], label [[VECTOR_PH:%.*]], label [[EXIT:%.*]]
; AVX2:       vector.ph:
; AVX2-NEXT:    [[N_VEC:%.*]] = and i64 [[WIDE_TRIP_COUNT]], 4294967292
; AVX2-NEXT:    [[SPLATINSERT18:%.*]] = insertelement <4 x i32> undef, i32 [[AMT0:%.*]], i32 0
; AVX2-NEXT:    [[SPLAT1:%.*]] = shufflevector <4 x i32> [[SPLATINSERT18]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX2-NEXT:    [[SPLATINSERT20:%.*]] = insertelement <4 x i32> undef, i32 [[AMT1:%.*]], i32 0
; AVX2-NEXT:    [[SPLAT2:%.*]] = shufflevector <4 x i32> [[SPLATINSERT20]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX2-NEXT:    [[SPLATINSERT22:%.*]] = insertelement <4 x i32> undef, i32 [[X:%.*]], i32 0
; AVX2-NEXT:    [[SPLAT3:%.*]] = shufflevector <4 x i32> [[SPLATINSERT22]], <4 x i32> undef, <4 x i32> zeroinitializer
; AVX2-NEXT:    br label [[VECTOR_BODY:%.*]]
; AVX2:       vector.body:
; AVX2-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; AVX2-NEXT:    [[TMP0:%.*]] = getelementptr inbounds i8, i8* [[CONTROL:%.*]], i64 [[INDEX]]
; AVX2-NEXT:    [[TMP1:%.*]] = bitcast i8* [[TMP0]] to <4 x i8>*
; AVX2-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i8>, <4 x i8>* [[TMP1]], align 1
; AVX2-NEXT:    [[TMP2:%.*]] = icmp eq <4 x i8> [[WIDE_LOAD]], zeroinitializer
; AVX2-NEXT:    [[TMP3:%.*]] = select <4 x i1> [[TMP2]], <4 x i32> [[SPLAT1]], <4 x i32> [[SPLAT2]]
; AVX2-NEXT:    [[TMP4:%.*]] = shl <4 x i32> [[SPLAT3]], [[TMP3]]
; AVX2-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[ARR:%.*]], i64 [[INDEX]]
; AVX2-NEXT:    [[TMP6:%.*]] = bitcast i32* [[TMP5]] to <4 x i32>*
; AVX2-NEXT:    store <4 x i32> [[TMP4]], <4 x i32>* [[TMP6]], align 4
; AVX2-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 4
; AVX2-NEXT:    [[TMP7:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; AVX2-NEXT:    br i1 [[TMP7]], label [[EXIT]], label [[VECTOR_BODY]]
; AVX2:       exit:
; AVX2-NEXT:    ret void
;
entry:
  %cmp16 = icmp sgt i32 %count, 0
  %wide.trip.count = zext i32 %count to i64
  br i1 %cmp16, label %vector.ph, label %exit

vector.ph:
  %n.vec = and i64 %wide.trip.count, 4294967292
  %splatinsert18 = insertelement <4 x i32> undef, i32 %amt0, i32 0
  %splat1 = shufflevector <4 x i32> %splatinsert18, <4 x i32> undef, <4 x i32> zeroinitializer
  %splatinsert20 = insertelement <4 x i32> undef, i32 %amt1, i32 0
  %splat2 = shufflevector <4 x i32> %splatinsert20, <4 x i32> undef, <4 x i32> zeroinitializer
  %splatinsert22 = insertelement <4 x i32> undef, i32 %x, i32 0
  %splat3 = shufflevector <4 x i32> %splatinsert22, <4 x i32> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i8, i8* %control, i64 %index
  %1 = bitcast i8* %0 to <4 x i8>*
  %wide.load = load <4 x i8>, <4 x i8>* %1, align 1
  %2 = icmp eq <4 x i8> %wide.load, zeroinitializer
  %3 = select <4 x i1> %2, <4 x i32> %splat1, <4 x i32> %splat2
  %4 = shl <4 x i32> %splat3, %3
  %5 = getelementptr inbounds i32, i32* %arr, i64 %index
  %6 = bitcast i32* %5 to <4 x i32>*
  store <4 x i32> %4, <4 x i32>* %6, align 4
  %index.next = add i64 %index, 4
  %7 = icmp eq i64 %index.next, %n.vec
  br i1 %7, label %exit, label %vector.body

exit:
  ret void
}

define <4 x i32> @vector_variable_shift_right(<4 x i1> %cond, <4 x i32> %x, <4 x i32> %y, <4 x i32> %z) {
; ALL-LABEL: @vector_variable_shift_right(
; ALL-NEXT:    [[SPLAT1:%.*]] = shufflevector <4 x i32> [[X:%.*]], <4 x i32> undef, <4 x i32> zeroinitializer
; ALL-NEXT:    [[SPLAT2:%.*]] = shufflevector <4 x i32> [[Y:%.*]], <4 x i32> undef, <4 x i32> zeroinitializer
; ALL-NEXT:    [[SEL:%.*]] = select <4 x i1> [[COND:%.*]], <4 x i32> [[SPLAT1]], <4 x i32> [[SPLAT2]]
; ALL-NEXT:    [[SH:%.*]] = lshr <4 x i32> [[Z:%.*]], [[SEL]]
; ALL-NEXT:    ret <4 x i32> [[SH]]
;
  %splat1 = shufflevector <4 x i32> %x, <4 x i32> undef, <4 x i32> zeroinitializer
  %splat2 = shufflevector <4 x i32> %y, <4 x i32> undef, <4 x i32> zeroinitializer
  %sel = select <4 x i1> %cond, <4 x i32> %splat1, <4 x i32> %splat2
  %sh = lshr <4 x i32> %z, %sel
  ret <4 x i32> %sh
}
