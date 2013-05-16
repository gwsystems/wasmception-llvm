; RUN: llc < %s -mcpu=generic | FileCheck %s

target datalayout = "E-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v128:128:128-n32"
target triple = "powerpc-unknown-linux-gnu"

define i64 @foo(double* nocapture %n) nounwind readonly {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.06 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %x.05 = phi i64 [ 0, %entry ], [ %conv1, %for.body ]
  %arrayidx = getelementptr inbounds double* %n, i32 %i.06
  %0 = load double* %arrayidx, align 8
  %conv = sitofp i64 %x.05 to double
  %add = fadd double %conv, %0
  %conv1 = fptosi double %add to i64
  %inc = add nsw i32 %i.06, 1
  %exitcond = icmp eq i32 %inc, 2048
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret i64 %conv1
}

; CHECK: @foo
; CHECK-NOT: mtctr

