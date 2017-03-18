; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -newgvn -S | FileCheck %s


;; Block 6 is reachable, but edge 6->4 is not
;; This means the phi value is undef, not 0
; Function Attrs: ssp uwtable
define i16 @hoge() local_unnamed_addr #0 align 2 {
; CHECK-LABEL: @hoge(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    switch i8 undef, label [[BB7:%.*]] [
; CHECK-NEXT:    i8 0, label [[BB1:%.*]]
; CHECK-NEXT:    i8 12, label [[BB2:%.*]]
; CHECK-NEXT:    ]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB6:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB4:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    unreachable
; CHECK:       bb4:
; CHECK-NEXT:    ret i16 undef
; CHECK:       bb6:
; CHECK-NEXT:    br i1 true, label [[BB3:%.*]], label [[BB4]], !llvm.loop !1
; CHECK:       bb7:
; CHECK-NEXT:    unreachable
;
bb:
  switch i8 undef, label %bb7 [
  i8 0, label %bb1
  i8 12, label %bb2
  ]

bb1:                                              ; preds = %bb
  br label %bb6

bb2:                                              ; preds = %bb
  br label %bb4

bb3:                                              ; preds = %bb6
  unreachable

bb4:                                              ; preds = %bb6, %bb2
  %tmp = phi i16 [ 0, %bb6 ], [ undef, %bb2 ]
  ret i16 %tmp

bb6:                                              ; preds = %bb4
  br i1 true, label %bb3, label %bb4, !llvm.loop !1

bb7:                                              ; preds = %bb
  unreachable
}

attributes #0 = { ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 5.0.0 (http://llvm.org/git/clang.git a8b933d4d1d133594fdaed35ee5814514b738f6d) (/Users/dannyb/sources/llvm-clean fc630a9b5613f544c07a8f16abcc173793df62cf)"}
!1 = distinct !{!1, !2}
!2 = !{!"llvm.loop.unroll.disable"}
