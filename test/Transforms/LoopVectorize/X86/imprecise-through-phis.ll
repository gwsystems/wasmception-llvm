; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-vectorize -mtriple=x86_64-apple-darwin %s | FileCheck %s

; FIXME: The intent is that we should be able to vectorize this on x86
; because that would be profitable, but the cost model says it is not.

; Two mostly identical functions. The only difference is the presence of
; fast-math flags on the second. The loop is a pretty simple reduction:

; for (int i = 0; i < 32; ++i)
;   if (arr[i] != 42.0)
;     tot += arr[i];

define double @sumIfScalar(double* nocapture readonly %arr) {
; CHECK-LABEL: @sumIfScalar(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[NEXT_ITER:%.*]] ]
; CHECK-NEXT:    [[TOT:%.*]] = phi double [ 0.000000e+00, [[ENTRY]] ], [ [[TOT_NEXT:%.*]], [[NEXT_ITER]] ]
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr double, double* [[ARR:%.*]], i32 [[I]]
; CHECK-NEXT:    [[NEXTVAL:%.*]] = load double, double* [[ADDR]]
; CHECK-NEXT:    [[TST:%.*]] = fcmp une double [[NEXTVAL]], 4.200000e+01
; CHECK-NEXT:    br i1 [[TST]], label [[DO_ADD:%.*]], label [[NO_ADD:%.*]]
; CHECK:       do.add:
; CHECK-NEXT:    [[TOT_NEW:%.*]] = fadd double [[TOT]], [[NEXTVAL]]
; CHECK-NEXT:    br label [[NEXT_ITER]]
; CHECK:       no.add:
; CHECK-NEXT:    br label [[NEXT_ITER]]
; CHECK:       next.iter:
; CHECK-NEXT:    [[TOT_NEXT]] = phi double [ [[TOT]], [[NO_ADD]] ], [ [[TOT_NEW]], [[DO_ADD]] ]
; CHECK-NEXT:    [[I_NEXT]] = add i32 [[I]], 1
; CHECK-NEXT:    [[AGAIN:%.*]] = icmp ult i32 [[I_NEXT]], 32
; CHECK-NEXT:    br i1 [[AGAIN]], label [[LOOP]], label [[DONE:%.*]]
; CHECK:       done:
; CHECK-NEXT:    [[TOT_NEXT_LCSSA:%.*]] = phi double [ [[TOT_NEXT]], [[NEXT_ITER]] ]
; CHECK-NEXT:    ret double [[TOT_NEXT_LCSSA]]
;
entry:
  br label %loop

loop:
  %i = phi i32 [0, %entry], [%i.next, %next.iter]
  %tot = phi double [0.0, %entry], [%tot.next, %next.iter]

  %addr = getelementptr double, double* %arr, i32 %i
  %nextval = load double, double* %addr

  %tst = fcmp une double %nextval, 42.0
  br i1 %tst, label %do.add, label %no.add

do.add:
  %tot.new = fadd double %tot, %nextval
  br label %next.iter

no.add:
  br label %next.iter

next.iter:
  %tot.next = phi double [%tot, %no.add], [%tot.new, %do.add]
  %i.next = add i32 %i, 1
  %again = icmp ult i32 %i.next, 32
  br i1 %again, label %loop, label %done

done:
  ret double %tot.next
}

define double @sumIfVector(double* nocapture readonly %arr) {
; CHECK-LABEL: @sumIfVector(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[NEXT_ITER:%.*]] ]
; CHECK-NEXT:    [[TOT:%.*]] = phi double [ 0.000000e+00, [[ENTRY]] ], [ [[TOT_NEXT:%.*]], [[NEXT_ITER]] ]
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr double, double* [[ARR:%.*]], i32 [[I]]
; CHECK-NEXT:    [[NEXTVAL:%.*]] = load double, double* [[ADDR]]
; CHECK-NEXT:    [[TST:%.*]] = fcmp fast une double [[NEXTVAL]], 4.200000e+01
; CHECK-NEXT:    br i1 [[TST]], label [[DO_ADD:%.*]], label [[NO_ADD:%.*]]
; CHECK:       do.add:
; CHECK-NEXT:    [[TOT_NEW:%.*]] = fadd fast double [[TOT]], [[NEXTVAL]]
; CHECK-NEXT:    br label [[NEXT_ITER]]
; CHECK:       no.add:
; CHECK-NEXT:    br label [[NEXT_ITER]]
; CHECK:       next.iter:
; CHECK-NEXT:    [[TOT_NEXT]] = phi double [ [[TOT]], [[NO_ADD]] ], [ [[TOT_NEW]], [[DO_ADD]] ]
; CHECK-NEXT:    [[I_NEXT]] = add i32 [[I]], 1
; CHECK-NEXT:    [[AGAIN:%.*]] = icmp ult i32 [[I_NEXT]], 32
; CHECK-NEXT:    br i1 [[AGAIN]], label [[LOOP]], label [[DONE:%.*]]
; CHECK:       done:
; CHECK-NEXT:    [[TOT_NEXT_LCSSA:%.*]] = phi double [ [[TOT_NEXT]], [[NEXT_ITER]] ]
; CHECK-NEXT:    ret double [[TOT_NEXT_LCSSA]]
;
entry:
  br label %loop

loop:
  %i = phi i32 [0, %entry], [%i.next, %next.iter]
  %tot = phi double [0.0, %entry], [%tot.next, %next.iter]

  %addr = getelementptr double, double* %arr, i32 %i
  %nextval = load double, double* %addr

  %tst = fcmp fast une double %nextval, 42.0
  br i1 %tst, label %do.add, label %no.add

do.add:
  %tot.new = fadd fast double %tot, %nextval
  br label %next.iter

no.add:
  br label %next.iter

next.iter:
  %tot.next = phi double [%tot, %no.add], [%tot.new, %do.add]
  %i.next = add i32 %i, 1
  %again = icmp ult i32 %i.next, 32
  br i1 %again, label %loop, label %done

done:
  ret double %tot.next
}

