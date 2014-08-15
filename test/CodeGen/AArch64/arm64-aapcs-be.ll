; RUN: llc -mtriple=aarch64_be-none-eabi -fast-isel=false < %s | FileCheck %s
; RUN: llc -mtriple=aarch64_be-none-eabi -fast-isel=true < %s | FileCheck %s

; Check narrow argument passing via stack - callee end
define i32 @test_narrow_args_callee(i64 %x0, i64 %x1, i64 %x2, i64 %x3, i64 %x4, i64 %x5, i64 %x6, i64 %x7, i8 %c, i16 %s) #0 {
entry:
  %conv = zext i8 %c to i32
  %conv1 = sext i16 %s to i32
  %add = add nsw i32 %conv1, %conv
; CHECK-LABEL: test_narrow_args_callee:
; CHECK-DAG: ldrb w{{[0-9]}}, [sp, #7]
; CHECK-DAG: ldr{{s?}}h w{{[0-9]}}, [sp, #14]
  ret i32 %add
}

; Check narrow argument passing via stack - caller end
define i32 @test_narrow_args_caller() #0 {
entry:
  %call = tail call i32 @test_narrow_args_callee(i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i8 8, i16 9)
; CHECK-LABEL: test_narrow_args_caller:
; CHECK-DAG: strh w{{[0-9]}}, [sp, #14]
; CHECK-DAG: strb w{{[0-9]}}, [sp, #7]
  ret i32 %call
}