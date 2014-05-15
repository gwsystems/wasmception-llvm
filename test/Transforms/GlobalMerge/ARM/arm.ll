; RUN: opt %s -mtriple=arm-linux-gnuabi -global-merge -S -o - | FileCheck %s

target datalayout = "e-p:32:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:32:64-v128:32:128-a0:0:32-n32-S32"
target triple = "thumbv7-apple-ios3.0.0"

@bar = internal global [5 x i32] zeroinitializer, align 4
@baz = internal global [5 x i32] zeroinitializer, align 4
@foo = internal global [5 x i32] zeroinitializer, align 4

; CHECK: @_MergedGlobals = internal global { [5 x i32], [5 x i32], [5 x i32] } zeroinitializer

; Function Attrs: nounwind ssp
define internal void @initialize() #0 {
  %1 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %1, i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 0), align 4, !tbaa !1
  %2 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %2, i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 0), align 4, !tbaa !1
  %3 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %3, i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 1), align 4, !tbaa !1
  %4 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %4, i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 1), align 4, !tbaa !1
  %5 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %5, i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 2), align 4, !tbaa !1
  %6 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %6, i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 2), align 4, !tbaa !1
  %7 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %7, i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 3), align 4, !tbaa !1
  %8 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %8, i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 3), align 4, !tbaa !1
  %9 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %9, i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 4), align 4, !tbaa !1
  %10 = tail call i32 bitcast (i32 (...)* @calc to i32 ()*)() #3
  store i32 %10, i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 4), align 4, !tbaa !1
  ret void
}

declare i32 @calc(...) #1

; Function Attrs: nounwind ssp
define internal void @calculate() #0 {
  %1 = load <4 x i32>* bitcast ([5 x i32]* @bar to <4 x i32>*), align 4
  %2 = load <4 x i32>* bitcast ([5 x i32]* @baz to <4 x i32>*), align 4
  %3 = mul <4 x i32> %2, %1
  store <4 x i32> %3, <4 x i32>* bitcast ([5 x i32]* @foo to <4 x i32>*), align 4
  %4 = load i32* getelementptr inbounds ([5 x i32]* @bar, i32 0, i32 4), align 4, !tbaa !1
  %5 = load i32* getelementptr inbounds ([5 x i32]* @baz, i32 0, i32 4), align 4, !tbaa !1
  %6 = mul nsw i32 %5, %4
  store i32 %6, i32* getelementptr inbounds ([5 x i32]* @foo, i32 0, i32 4), align 4, !tbaa !1
  ret void
}

; Function Attrs: nounwind readnone ssp
define internal i32* @returnFoo() #2 {
  ret i32* getelementptr inbounds ([5 x i32]* @foo, i32 0, i32 0)
}

attributes #0 = { nounwind ssp "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone ssp "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"LLVM version 3.4 "}
!1 = metadata !{metadata !2, metadata !2, i64 0}
!2 = metadata !{metadata !"int", metadata !3, i64 0}
!3 = metadata !{metadata !"omnipotent char", metadata !4, i64 0}
!4 = metadata !{metadata !"Simple C/C++ TBAA"}
