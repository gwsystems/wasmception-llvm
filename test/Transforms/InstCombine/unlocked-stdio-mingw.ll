; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S -mtriple=x86_64-w64-mingw32 | FileCheck %s

%struct._iobuf = type { i8*, i32, i8*, i32, i32, i32, i32, i8* }

@.str = private unnamed_addr constant [5 x i8] c"file\00", align 1
@.str.1 = private unnamed_addr constant [2 x i8] c"w\00", align 1

; Check that this still uses the plain fputc instead of fputc_unlocked
; for MinGW targets.
define void @external_fputc_test() {
; CHECK-LABEL: @external_fputc_test(
; CHECK-NEXT:    [[CALL:%.*]] = call %struct._iobuf* @fopen(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.1, i64 0, i64 0))
; CHECK-NEXT:    [[CALL1:%.*]] = call i32 @fputc(i32 99, %struct._iobuf* [[CALL]])
; CHECK-NEXT:    ret void
;
  %call = call %struct._iobuf* @fopen(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.1, i64 0, i64 0))
  %call1 = call i32 @fputc(i32 99, %struct._iobuf* %call)
  ret void
}

declare %struct._iobuf* @fopen(i8*, i8*)
declare i32 @fputc(i32, %struct._iobuf* nocapture)
