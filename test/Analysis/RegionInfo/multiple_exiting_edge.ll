; RUN: opt -regions -print-region-style=bb  -analyze < %s |& FileCheck -check-prefix=BBIT %s
; RUN: opt -regions -print-region-style=rn  -analyze < %s |& FileCheck -check-prefix=RNIT %s

define void @normal_condition_0() nounwind {
bb38:                                             ; preds = %bb34, %bb34, %bb37
  switch i32 undef, label %bb42 [
    i32 67, label %bb42
    i32 90, label %bb41
  ]
bb41:                                             ; preds = %bb38
  br label %bb42
bb42:                                             ; preds = %bb38, %bb38, %bb41
  ret void
}

; BBIT: bb38, bb42, bb41,
; BBIT: bb38, bb41,

; RNIT: bb38 => bb42, bb42,
; RNIT: bb38, bb41,

define void @normal_condition_1() nounwind {
bb38:                                             ; preds = %bb34, %bb34, %bb37
  switch i32 undef, label %bb41 [
    i32 67, label %bb42
    i32 90, label %bb42
  ]
bb41:                                             ; preds = %bb38
  br label %bb42
bb42:                                             ; preds = %bb38, %bb38, %bb41
  ret void
}

; BBIT: bb38, bb41, bb42,
; BBIT: bb38, bb41,

; RNIT: bb38 => bb42, bb42,
; RNIT: bb38, bb41,
