; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -gvn -S < %s | FileCheck %s

; Memdep had funny bug related to invariant.groups - because it did not
; invalidated cache, in some very rare cases it was possible to show memory
; dependence of the instruction that was deleted, but because other instruction
; took it's place it resulted in call to vtable! Removing any of the branch
; hides the bug.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-grtev4-linux-gnu"

%0 = type { i32 (...)**, %1 }
%1 = type { %2 }
%2 = type { %3 }
%3 = type { %4, i64, %5 }
%4 = type { i8* }
%5 = type { i64, [8 x i8] }

define void @fail(i1* noalias sret, %0*, %1*, i8*) local_unnamed_addr #0 {
; CHECK-LABEL: @fail(
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast %0* [[TMP1:%.*]] to i64 (%0*)***
; CHECK-NEXT:    [[TMP6:%.*]] = load i64 (%0*)**, i64 (%0*)*** [[TMP5]], align 8, !invariant.group !6
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i64 (%0*)*, i64 (%0*)** [[TMP6]], i64 6
; CHECK-NEXT:    [[TMP8:%.*]] = load i64 (%0*)*, i64 (%0*)** [[TMP7]], align 8, !invariant.load !6
; CHECK-NEXT:    [[TMP9:%.*]] = tail call i64 [[TMP8]](%0* [[TMP1]]) #1
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [[TMP1]], %1* [[TMP2:%.*]], i64 0, i32 0, i32 0, i32 0, i32 0
; CHECK-NEXT:    [[TMP11:%.*]] = load i8*, i8** [[TMP10]], align 8
; CHECK-NEXT:    store i8 0, i8* [[TMP11]], align 1
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast i64 (%0*)** [[TMP6]] to i64 (%0*, i8*, i64)**
; CHECK-NEXT:    br i1 undef
; CHECK:         [[TMP14:%.*]] = bitcast %0* [[TMP1]] to i64 (%0*, i8*, i64)***
; CHECK-NEXT:    [[DOTPHI_TRANS_INSERT:%.*]] = getelementptr inbounds i64 (%0*, i8*, i64)*, i64 (%0*, i8*, i64)** [[TMP12]], i64 22
; CHECK-NEXT:    [[DOTPRE:%.*]] = load i64 (%0*, i8*, i64)*, i64 (%0*, i8*, i64)** [[DOTPHI_TRANS_INSERT]], align 8, !invariant.load !6
; CHECK-NEXT:    br label [[TMP15:%.*]]
; CHECK:         [[TMP16:%.*]] = call i64 [[DOTPRE]](%0* nonnull [[TMP1]], i8* null, i64 0) #1

  %5 = bitcast %0* %1 to i64 (%0*)***
  %6 = load i64 (%0*)**, i64 (%0*)*** %5, align 8, !invariant.group !6
  %7 = getelementptr inbounds i64 (%0*)*, i64 (%0*)** %6, i64 6
  %8 = load i64 (%0*)*, i64 (%0*)** %7, align 8, !invariant.load !6
  %9 = tail call i64 %8(%0* %1) #1
  %10 = getelementptr inbounds %1, %1* %2, i64 0, i32 0, i32 0, i32 0, i32 0
  %11 = load i8*, i8** %10, align 8
  store i8 0, i8* %11, align 1
  br i1 undef, label %12, label %31

; <label>:12:                                     ; preds = %4
  %13 = bitcast %0* %1 to i64 (%0*, i8*, i64)***
  br label %14

; <label>:14:                                     ; preds = %30, %12
  %15 = load i64 (%0*, i8*, i64)**, i64 (%0*, i8*, i64)*** %13, align 8, !invariant.group !6
  %16 = getelementptr inbounds i64 (%0*, i8*, i64)*, i64 (%0*, i8*, i64)** %15, i64 22
  %17 = load i64 (%0*, i8*, i64)*, i64 (%0*, i8*, i64)** %16, align 8, !invariant.load !6
  %18 = call i64 %17(%0* nonnull %1, i8* null, i64 0) #1
  br i1 undef, label %30, label %19

; <label>:19:                                     ; preds = %14
  br i1 undef, label %20, label %23

; <label>:20:                                     ; preds = %19
  br label %21

; <label>:21:                                     ; preds = %20
  br label %22

; <label>:22:                                     ; preds = %21
  br label %30

; <label>:23:                                     ; preds = %19
  br label %24

; <label>:24:                                     ; preds = %23
  br label %25

; <label>:25:                                     ; preds = %24
  br label %26

; <label>:26:                                     ; preds = %25
  br i1 undef, label %27, label %28

; <label>:27:                                     ; preds = %26
  br label %30

; <label>:28:                                     ; preds = %26
  br label %29

; <label>:29:                                     ; preds = %28
  br label %30

; <label>:30:                                     ; preds = %29, %27, %22, %14
  br i1 undef, label %14, label %31

; <label>:31:                                     ; preds = %30, %4
  ret void
}

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0, !1, !3, !4, !5}

!0 = !{i32 1, !"StrictVTablePointers", i32 1}
!1 = !{i32 3, !"StrictVTablePointersRequirement", !2}
!2 = !{!"StrictVTablePointers", i32 1}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"PIC Level", i32 2}
!5 = !{i32 7, !"PIE Level", i32 2}
!6 = !{}
