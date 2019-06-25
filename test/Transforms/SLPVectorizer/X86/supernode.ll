; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -S < %s -mtriple=x86_64-unknown-linux -mcpu=corei7-avx -verify | FileCheck %s -check-prefix=ENABLED
;
; Without supernode operand reordering, this does not get fully vectorized.
; S[0] = (A[0] + B[0]) + C[0]
; S[1] = (B[1] + C[1]) + A[1]
define void @test_supernode_add(double* %Aarray, double* %Barray, double *%Carray, double *%Sarray) {
; ENABLED-LABEL: @test_supernode_add(
; ENABLED-NEXT:  entry:
; ENABLED-NEXT:    [[IDXA0:%.*]] = getelementptr inbounds double, double* [[AARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXA1:%.*]] = getelementptr inbounds double, double* [[AARRAY]], i64 1
; ENABLED-NEXT:    [[IDXB0:%.*]] = getelementptr inbounds double, double* [[BARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXB1:%.*]] = getelementptr inbounds double, double* [[BARRAY]], i64 1
; ENABLED-NEXT:    [[IDXC0:%.*]] = getelementptr inbounds double, double* [[CARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXC1:%.*]] = getelementptr inbounds double, double* [[CARRAY]], i64 1
; ENABLED-NEXT:    [[IDXS0:%.*]] = getelementptr inbounds double, double* [[SARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS1:%.*]] = getelementptr inbounds double, double* [[SARRAY]], i64 1
; ENABLED-NEXT:    [[A0:%.*]] = load double, double* [[IDXA0]], align 8
; ENABLED-NEXT:    [[A1:%.*]] = load double, double* [[IDXA1]], align 8
; ENABLED-NEXT:    [[TMP0:%.*]] = bitcast double* [[IDXB0]] to <2 x double>*
; ENABLED-NEXT:    [[TMP1:%.*]] = load <2 x double>, <2 x double>* [[TMP0]], align 8
; ENABLED-NEXT:    [[C0:%.*]] = load double, double* [[IDXC0]], align 8
; ENABLED-NEXT:    [[C1:%.*]] = load double, double* [[IDXC1]], align 8
; ENABLED-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> undef, double [[A0]], i32 0
; ENABLED-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> [[TMP2]], double [[C1]], i32 1
; ENABLED-NEXT:    [[TMP4:%.*]] = fadd fast <2 x double> [[TMP3]], [[TMP1]]
; ENABLED-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> undef, double [[C0]], i32 0
; ENABLED-NEXT:    [[TMP6:%.*]] = insertelement <2 x double> [[TMP5]], double [[A1]], i32 1
; ENABLED-NEXT:    [[TMP7:%.*]] = fadd fast <2 x double> [[TMP4]], [[TMP6]]
; ENABLED-NEXT:    [[TMP8:%.*]] = bitcast double* [[IDXS0]] to <2 x double>*
; ENABLED-NEXT:    store <2 x double> [[TMP7]], <2 x double>* [[TMP8]], align 8
; ENABLED-NEXT:    ret void
;
entry:
  %idxA0 = getelementptr inbounds double, double* %Aarray, i64 0
  %idxA1 = getelementptr inbounds double, double* %Aarray, i64 1
  %idxB0 = getelementptr inbounds double, double* %Barray, i64 0
  %idxB1 = getelementptr inbounds double, double* %Barray, i64 1
  %idxC0 = getelementptr inbounds double, double* %Carray, i64 0
  %idxC1 = getelementptr inbounds double, double* %Carray, i64 1
  %idxS0 = getelementptr inbounds double, double* %Sarray, i64 0
  %idxS1 = getelementptr inbounds double, double* %Sarray, i64 1

  %A0 = load double, double *%idxA0, align 8
  %A1 = load double, double *%idxA1, align 8

  %B0 = load double, double *%idxB0, align 8
  %B1 = load double, double *%idxB1, align 8

  %C0 = load double, double *%idxC0, align 8
  %C1 = load double, double *%idxC1, align 8

  %addA0B0 = fadd fast double %A0, %B0
  %addB1C1 = fadd fast double %B1, %C1
  %add0 = fadd fast double %addA0B0, %C0
  %add1 = fadd fast double %addB1C1, %A1
  store double %add0, double *%idxS0, align 8
  store double %add1, double *%idxS1, align 8
  ret void
}


; Without supernode operand reordering, this does not get fully vectorized.
; S[0] = (A[0] - B[0]) + C[0]
; S[1] = (C[1] - B[1]) + A[1]
define void @test_supernode_addsub(double* %Aarray, double* %Barray, double *%Carray, double *%Sarray) {
; ENABLED-LABEL: @test_supernode_addsub(
; ENABLED-NEXT:  entry:
; ENABLED-NEXT:    [[IDXA0:%.*]] = getelementptr inbounds double, double* [[AARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXA1:%.*]] = getelementptr inbounds double, double* [[AARRAY]], i64 1
; ENABLED-NEXT:    [[IDXB0:%.*]] = getelementptr inbounds double, double* [[BARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXB1:%.*]] = getelementptr inbounds double, double* [[BARRAY]], i64 1
; ENABLED-NEXT:    [[IDXC0:%.*]] = getelementptr inbounds double, double* [[CARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXC1:%.*]] = getelementptr inbounds double, double* [[CARRAY]], i64 1
; ENABLED-NEXT:    [[IDXS0:%.*]] = getelementptr inbounds double, double* [[SARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS1:%.*]] = getelementptr inbounds double, double* [[SARRAY]], i64 1
; ENABLED-NEXT:    [[A0:%.*]] = load double, double* [[IDXA0]], align 8
; ENABLED-NEXT:    [[A1:%.*]] = load double, double* [[IDXA1]], align 8
; ENABLED-NEXT:    [[TMP0:%.*]] = bitcast double* [[IDXB0]] to <2 x double>*
; ENABLED-NEXT:    [[TMP1:%.*]] = load <2 x double>, <2 x double>* [[TMP0]], align 8
; ENABLED-NEXT:    [[C0:%.*]] = load double, double* [[IDXC0]], align 8
; ENABLED-NEXT:    [[C1:%.*]] = load double, double* [[IDXC1]], align 8
; ENABLED-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> undef, double [[A0]], i32 0
; ENABLED-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> [[TMP2]], double [[C1]], i32 1
; ENABLED-NEXT:    [[TMP4:%.*]] = fsub fast <2 x double> [[TMP3]], [[TMP1]]
; ENABLED-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> undef, double [[C0]], i32 0
; ENABLED-NEXT:    [[TMP6:%.*]] = insertelement <2 x double> [[TMP5]], double [[A1]], i32 1
; ENABLED-NEXT:    [[TMP7:%.*]] = fadd fast <2 x double> [[TMP4]], [[TMP6]]
; ENABLED-NEXT:    [[TMP8:%.*]] = bitcast double* [[IDXS0]] to <2 x double>*
; ENABLED-NEXT:    store <2 x double> [[TMP7]], <2 x double>* [[TMP8]], align 8
; ENABLED-NEXT:    ret void
;
entry:
  %idxA0 = getelementptr inbounds double, double* %Aarray, i64 0
  %idxA1 = getelementptr inbounds double, double* %Aarray, i64 1
  %idxB0 = getelementptr inbounds double, double* %Barray, i64 0
  %idxB1 = getelementptr inbounds double, double* %Barray, i64 1
  %idxC0 = getelementptr inbounds double, double* %Carray, i64 0
  %idxC1 = getelementptr inbounds double, double* %Carray, i64 1
  %idxS0 = getelementptr inbounds double, double* %Sarray, i64 0
  %idxS1 = getelementptr inbounds double, double* %Sarray, i64 1

  %A0 = load double, double *%idxA0, align 8
  %A1 = load double, double *%idxA1, align 8

  %B0 = load double, double *%idxB0, align 8
  %B1 = load double, double *%idxB1, align 8

  %C0 = load double, double *%idxC0, align 8
  %C1 = load double, double *%idxC1, align 8

  %subA0B0 = fsub fast double %A0, %B0
  %subC1B1 = fsub fast double %C1, %B1
  %add0 = fadd fast double %subA0B0, %C0
  %add1 = fadd fast double %subC1B1, %A1
  store double %add0, double *%idxS0, align 8
  store double %add1, double *%idxS1, align 8
  ret void
}

; Without supernode operand reordering, this does not get fully vectorized.
; This checks that the super-node works with alternate sequences.
;
; S[0] = (A[0] - B[0]) - C[0]
; S[1] = (B[1] + C[1]) + A[1]
define void @test_supernode_addsub_alt(double* %Aarray, double* %Barray, double *%Carray, double *%Sarray) {
; ENABLED-LABEL: @test_supernode_addsub_alt(
; ENABLED-NEXT:  entry:
; ENABLED-NEXT:    [[IDXA0:%.*]] = getelementptr inbounds double, double* [[AARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXA1:%.*]] = getelementptr inbounds double, double* [[AARRAY]], i64 1
; ENABLED-NEXT:    [[IDXB0:%.*]] = getelementptr inbounds double, double* [[BARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXB1:%.*]] = getelementptr inbounds double, double* [[BARRAY]], i64 1
; ENABLED-NEXT:    [[IDXC0:%.*]] = getelementptr inbounds double, double* [[CARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXC1:%.*]] = getelementptr inbounds double, double* [[CARRAY]], i64 1
; ENABLED-NEXT:    [[IDXS0:%.*]] = getelementptr inbounds double, double* [[SARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS1:%.*]] = getelementptr inbounds double, double* [[SARRAY]], i64 1
; ENABLED-NEXT:    [[A0:%.*]] = load double, double* [[IDXA0]], align 8
; ENABLED-NEXT:    [[A1:%.*]] = load double, double* [[IDXA1]], align 8
; ENABLED-NEXT:    [[B0:%.*]] = load double, double* [[IDXB0]], align 8
; ENABLED-NEXT:    [[B1:%.*]] = load double, double* [[IDXB1]], align 8
; ENABLED-NEXT:    [[C0:%.*]] = load double, double* [[IDXC0]], align 8
; ENABLED-NEXT:    [[C1:%.*]] = load double, double* [[IDXC1]], align 8
; ENABLED-NEXT:    [[SUBA0B0:%.*]] = fsub fast double [[A0]], [[B0]]
; ENABLED-NEXT:    [[ADDB1C1:%.*]] = fadd fast double [[B1]], [[C1]]
; ENABLED-NEXT:    [[SUB0:%.*]] = fsub fast double [[SUBA0B0]], [[C0]]
; ENABLED-NEXT:    [[ADD1:%.*]] = fadd fast double [[ADDB1C1]], [[A1]]
; ENABLED-NEXT:    store double [[SUB0]], double* [[IDXS0]], align 8
; ENABLED-NEXT:    store double [[ADD1]], double* [[IDXS1]], align 8
; ENABLED-NEXT:    ret void
;
entry:
  %idxA0 = getelementptr inbounds double, double* %Aarray, i64 0
  %idxA1 = getelementptr inbounds double, double* %Aarray, i64 1
  %idxB0 = getelementptr inbounds double, double* %Barray, i64 0
  %idxB1 = getelementptr inbounds double, double* %Barray, i64 1
  %idxC0 = getelementptr inbounds double, double* %Carray, i64 0
  %idxC1 = getelementptr inbounds double, double* %Carray, i64 1
  %idxS0 = getelementptr inbounds double, double* %Sarray, i64 0
  %idxS1 = getelementptr inbounds double, double* %Sarray, i64 1

  %A0 = load double, double *%idxA0, align 8
  %A1 = load double, double *%idxA1, align 8

  %B0 = load double, double *%idxB0, align 8
  %B1 = load double, double *%idxB1, align 8

  %C0 = load double, double *%idxC0, align 8
  %C1 = load double, double *%idxC1, align 8

  %subA0B0 = fsub fast double %A0, %B0
  %addB1C1 = fadd fast double %B1, %C1
  %sub0 = fsub fast double %subA0B0, %C0
  %add1 = fadd fast double %addB1C1, %A1
  store double %sub0, double *%idxS0, align 8
  store double %add1, double *%idxS1, align 8
  ret void
}

; This checks that vectorizeTree() works correctly with the supernode
; and does not generate uses before defs.
; If all of the operands of the supernode are vectorizable, then the scheduler
; will fix their position in the program. If not, then the scheduler may not
; touch them, leading to uses before defs.
;
; A0 = ...
; C = ...
; t1 = A0 + C
; B0 = ...
; t2 = t1 + B0
; A1 = ...
; B1 = ...
; t3 = A1 + B1
; D = ...
; t4 = t3 + D
;
;
;  A0  C   A1  B1              A0  C    A1  D            A0:1  C,D
;   \ /      \ /    Reorder      \ /      \ /    Bundles     \ /
; t1 + B0  t3 + D   ------->   t1 + B0  t3 + B1  ------> t1:3 + B0:1
;    |/       |/                  |/       |/                 |/
; t2 +     t4 +                t2 +     t4 +             t2:4 +
;
; After reordering, 'D' conceptually becomes an operand of t3:
; t3 = A1 + D
; But D is defined *after* its use.
;
define void @supernode_scheduling(double* %Aarray, double* %Barray, double *%Carray, double *%Darray, double *%Sarray) {
; ENABLED-LABEL: @supernode_scheduling(
; ENABLED-NEXT:  entry:
; ENABLED-NEXT:    [[IDXA0:%.*]] = getelementptr inbounds double, double* [[AARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXA1:%.*]] = getelementptr inbounds double, double* [[AARRAY]], i64 1
; ENABLED-NEXT:    [[IDXB0:%.*]] = getelementptr inbounds double, double* [[BARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXB1:%.*]] = getelementptr inbounds double, double* [[BARRAY]], i64 1
; ENABLED-NEXT:    [[IDXC:%.*]] = getelementptr inbounds double, double* [[CARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXD:%.*]] = getelementptr inbounds double, double* [[DARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS0:%.*]] = getelementptr inbounds double, double* [[SARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS1:%.*]] = getelementptr inbounds double, double* [[SARRAY]], i64 1
; ENABLED-NEXT:    [[C:%.*]] = load double, double* [[IDXC]], align 8
; ENABLED-NEXT:    [[B0:%.*]] = load double, double* [[IDXB0]], align 8
; ENABLED-NEXT:    [[TMP0:%.*]] = bitcast double* [[IDXA0]] to <2 x double>*
; ENABLED-NEXT:    [[TMP1:%.*]] = load <2 x double>, <2 x double>* [[TMP0]], align 8
; ENABLED-NEXT:    [[B1:%.*]] = load double, double* [[IDXB1]], align 8
; ENABLED-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> undef, double [[C]], i32 0
; ENABLED-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> [[TMP2]], double [[B1]], i32 1
; ENABLED-NEXT:    [[TMP4:%.*]] = fadd fast <2 x double> [[TMP1]], [[TMP3]]
; ENABLED-NEXT:    [[D:%.*]] = load double, double* [[IDXD]], align 8
; ENABLED-NEXT:    [[TMP5:%.*]] = insertelement <2 x double> undef, double [[B0]], i32 0
; ENABLED-NEXT:    [[TMP6:%.*]] = insertelement <2 x double> [[TMP5]], double [[D]], i32 1
; ENABLED-NEXT:    [[TMP7:%.*]] = fadd fast <2 x double> [[TMP4]], [[TMP6]]
; ENABLED-NEXT:    [[TMP8:%.*]] = bitcast double* [[IDXS0]] to <2 x double>*
; ENABLED-NEXT:    store <2 x double> [[TMP7]], <2 x double>* [[TMP8]], align 8
; ENABLED-NEXT:    ret void
;
entry:
  %idxA0 = getelementptr inbounds double, double* %Aarray, i64 0
  %idxA1 = getelementptr inbounds double, double* %Aarray, i64 1
  %idxB0 = getelementptr inbounds double, double* %Barray, i64 0
  %idxB1 = getelementptr inbounds double, double* %Barray, i64 1
  %idxC = getelementptr inbounds double, double* %Carray, i64 0
  %idxD = getelementptr inbounds double, double* %Darray, i64 0
  %idxS0 = getelementptr inbounds double, double* %Sarray, i64 0
  %idxS1 = getelementptr inbounds double, double* %Sarray, i64 1


  %A0 = load double, double *%idxA0, align 8
  %C = load double, double *%idxC, align 8
  %t1 = fadd fast double %A0, %C
  %B0 = load double, double *%idxB0, align 8
  %t2 = fadd fast double %t1, %B0
  %A1 = load double, double *%idxA1, align 8
  %B1 = load double, double *%idxB1, align 8
  %t3 = fadd fast double %A1, %B1
  %D = load double, double *%idxD, align 8
  %t4 = fadd fast double %t3, %D

  store double %t2, double *%idxS0, align 8
  store double %t4, double *%idxS1, align 8
  ret void
}


; The SLP scheduler has trouble moving instructions across blocks.
; Even though we can build a SuperNode for this example, we should not because the scheduler
; cannot handle the cross-block instruction motion that is required once the operands of the
; SuperNode are reordered.
;
; bb1:
;  A0 = ...
;  B1 = ...
;  Tmp0 = A0 + 2.0
;  Tmp1 = B1 + 2.0
;
; bb2:
;  A1 = ...
;  B0 = ...
;  S[0] = Tmp0 + B0
;  S[1] = Tmp1 + A1
define void @supernode_scheduling_cross_block(double* %Aarray, double* %Barray, double *%Sarray) {
; ENABLED-LABEL: @supernode_scheduling_cross_block(
; ENABLED-NEXT:  entry:
; ENABLED-NEXT:    [[IDXA0:%.*]] = getelementptr inbounds double, double* [[AARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXA1:%.*]] = getelementptr inbounds double, double* [[AARRAY]], i64 1
; ENABLED-NEXT:    [[IDXB0:%.*]] = getelementptr inbounds double, double* [[BARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXB1:%.*]] = getelementptr inbounds double, double* [[BARRAY]], i64 1
; ENABLED-NEXT:    [[IDXS0:%.*]] = getelementptr inbounds double, double* [[SARRAY:%.*]], i64 0
; ENABLED-NEXT:    [[IDXS1:%.*]] = getelementptr inbounds double, double* [[SARRAY]], i64 1
; ENABLED-NEXT:    [[A0:%.*]] = load double, double* [[IDXA0]], align 8
; ENABLED-NEXT:    [[B1:%.*]] = load double, double* [[IDXB1]], align 8
; ENABLED-NEXT:    [[TMP0:%.*]] = insertelement <2 x double> undef, double [[A0]], i32 0
; ENABLED-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> [[TMP0]], double [[B1]], i32 1
; ENABLED-NEXT:    [[TMP2:%.*]] = fadd fast <2 x double> [[TMP1]], <double 2.000000e+00, double 2.000000e+00>
; ENABLED-NEXT:    br label [[BB:%.*]]
; ENABLED:       bb:
; ENABLED-NEXT:    [[A1:%.*]] = load double, double* [[IDXA1]], align 8
; ENABLED-NEXT:    [[B0:%.*]] = load double, double* [[IDXB0]], align 8
; ENABLED-NEXT:    [[TMP3:%.*]] = insertelement <2 x double> undef, double [[B0]], i32 0
; ENABLED-NEXT:    [[TMP4:%.*]] = insertelement <2 x double> [[TMP3]], double [[A1]], i32 1
; ENABLED-NEXT:    [[TMP5:%.*]] = fadd fast <2 x double> [[TMP2]], [[TMP4]]
; ENABLED-NEXT:    [[TMP6:%.*]] = bitcast double* [[IDXS0]] to <2 x double>*
; ENABLED-NEXT:    store <2 x double> [[TMP5]], <2 x double>* [[TMP6]], align 8
; ENABLED-NEXT:    ret void
;
entry:
  %idxA0 = getelementptr inbounds double, double* %Aarray, i64 0
  %idxA1 = getelementptr inbounds double, double* %Aarray, i64 1
  %idxB0 = getelementptr inbounds double, double* %Barray, i64 0
  %idxB1 = getelementptr inbounds double, double* %Barray, i64 1
  %idxS0 = getelementptr inbounds double, double* %Sarray, i64 0
  %idxS1 = getelementptr inbounds double, double* %Sarray, i64 1

  %A0 = load double, double *%idxA0, align 8
  %B1 = load double, double *%idxB1, align 8
  %Tmp0 = fadd fast double %A0, 2.0
  %Tmp1 = fadd fast double %B1, 2.0
br label %bb

bb:
  %A1 = load double, double *%idxA1, align 8
  %B0 = load double, double *%idxB0, align 8

  %Sum0 = fadd fast double %Tmp0, %B0
  %Sum1 = fadd fast double %Tmp1, %A1

  store double %Sum0, double *%idxS0, align 8
  store double %Sum1, double *%idxS1, align 8
  ret void
}
