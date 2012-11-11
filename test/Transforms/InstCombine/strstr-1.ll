; Test that the strstr library call simplifier works correctly.
;
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

@.str = private constant [1 x i8] zeroinitializer
@.str1 = private constant [2 x i8] c"a\00"
@.str2 = private constant [6 x i8] c"abcde\00"
@.str3 = private constant [4 x i8] c"bcd\00"

declare i8* @strstr(i8*, i8*)

; Check strstr(str, "") -> str.

define i8* @test_simplify1(i8* %str) {
; CHECK: @test_simplify1
  %pat = getelementptr inbounds [1 x i8]* @.str, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
; CHECK-NEXT: ret i8* %str
}

; Check strstr(str, "a") -> strchr(str, 'a').

define i8* @test_simplify2(i8* %str) {
; CHECK: @test_simplify2
  %pat = getelementptr inbounds [2 x i8]* @.str1, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
; CHECK-NEXT: @strchr(i8* %str, i32 97)
}

; Check strstr("abcde", "bcd") -> "abcde" + 1.

define i8* @test_simplify3() {
; CHECK: @test_simplify3
  %str = getelementptr inbounds [6 x i8]* @.str2, i32 0, i32 0
  %pat = getelementptr inbounds [4 x i8]* @.str3, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
; CHECK-NEXT: getelementptr inbounds ([6 x i8]* @.str2, i64 0, i64 1)
}

; Check strstr(str, str) -> str.

define i8* @test_simplify4(i8* %str) {
; CHECK: @test_simplify4
  %ret = call i8* @strstr(i8* %str, i8* %str)
  ret i8* %ret
; CHECK-NEXT: ret i8* %str
}

; Check strstr(str, pat) == str -> strncmp(str, pat, strlen(str)) == 0.

define i1 @test_simplify5(i8* %str, i8* %pat) {
; CHECK: @test_simplify5
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  %cmp = icmp eq i8* %ret, %str
  ret i1 %cmp
; CHECK: [[LEN:%[a-z]+]] = call {{i[0-9]+}} @strlen(i8* %pat)
; CHECK: [[NCMP:%[a-z]+]] = call {{i[0-9]+}} @strncmp(i8* %str, i8* %pat, {{i[0-9]+}} [[LEN]])
; CHECK: icmp eq {{i[0-9]+}} [[NCMP]], 0
; CHECK: ret i1
}
