; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare i8* @realloc(i8*, i64) #1
declare noalias i8* @malloc(i64) #1


define i8* @realloc_null_ptr() #0 {
; CHECK-LABEL: @realloc_null_ptr(
; CHECK-NEXT:    [[MALLOC:%.*]] = call i8* @malloc(i64 100)
; CHECK-NEXT:    ret i8* [[MALLOC]]
;
  %call = call i8* @realloc(i8* null, i64 100) #2
  ret i8* %call
}

define i8* @realloc_unknown_ptr(i8* %ptr) #0 {
; CHECK-LABEL: @realloc_unknown_ptr(
; CHECK-NEXT:    [[CALL:%.*]] = call i8* @realloc(i8* [[PTR:%.*]], i64 100)
; CHECK-NEXT:    ret i8* [[CALL]]
;
  %call = call i8* @realloc(i8* %ptr, i64 100) #2
  ret i8* %call
}
