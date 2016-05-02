; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S -default-data-layout="p:32:32:32-p1:16:16:16-n8:16:32:64" < %s | FileCheck %s

@G16 = internal constant [10 x i16] [i16 35, i16 82, i16 69, i16 81, i16 85,
                                     i16 73, i16 82, i16 69, i16 68, i16 0]

@G16_as1 = internal addrspace(1) constant [10 x i16] [i16 35, i16 82, i16 69, i16 81, i16 85,
                                                      i16 73, i16 82, i16 69, i16 68, i16 0]

@GD = internal constant [6 x double]
   [double -10.0, double 1.0, double 4.0, double 2.0, double -20.0, double -40.0]

%Foo = type { i32, i32, i32, i32 }

@GS = internal constant %Foo { i32 1, i32 4, i32 9, i32 14 }

@GStructArr = internal constant [4 x %Foo] [ %Foo { i32 1, i32 4, i32 9, i32 14 },
                                             %Foo { i32 5, i32 4, i32 6, i32 11 },
                                             %Foo { i32 6, i32 5, i32 9, i32 20 },
                                             %Foo { i32 12, i32 3, i32 9, i32 8 } ]


define i1 @test1(i32 %X) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 %X, 9
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = icmp eq i16 %Q, 0
  ret i1 %R
}

define i1 @test1_noinbounds(i32 %X) {
; CHECK-LABEL: @test1_noinbounds(
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 %X, 9
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = icmp eq i16 %Q, 0
  ret i1 %R
}

define i1 @test1_noinbounds_i64(i64 %X) {
; CHECK-LABEL: @test1_noinbounds_i64(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 %X to i32
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 [[TMP1]], 9
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr [10 x i16], [10 x i16]* @G16, i64 0, i64 %X
  %Q = load i16, i16* %P
  %R = icmp eq i16 %Q, 0
  ret i1 %R
}

define i1 @test1_noinbounds_as1(i32 %x) {
; CHECK-LABEL: @test1_noinbounds_as1(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 %x to i16
; CHECK-NEXT:    [[R:%.*]] = icmp eq i16 [[TMP1]], 9
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr [10 x i16], [10 x i16] addrspace(1)* @G16_as1, i16 0, i32 %x
  %q = load i16, i16 addrspace(1)* %p
  %r = icmp eq i16 %q, 0
  ret i1 %r

}

define i1 @test2(i32 %X) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 %X, 4
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = icmp slt i16 %Q, 85
  ret i1 %R
}

define i1 @test3(i32 %X) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 %X, 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [6 x double], [6 x double]* @GD, i32 0, i32 %X
  %Q = load double, double* %P
  %R = fcmp oeq double %Q, 1.0
  ret i1 %R

}

define i1 @test4(i32 %X) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 933, %X
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 1
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = icmp sle i16 %Q, 73
  ret i1 %R
}

define i1 @test4_i16(i16 %X) {
; CHECK-LABEL: @test4_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i16 %X to i32
; CHECK-NEXT:    [[TMP2:%.*]] = lshr i32 933, [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = and i32 [[TMP2]], 1
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 [[TMP3]], 0
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i16 %X
  %Q = load i16, i16* %P
  %R = icmp sle i16 %Q, 73
  ret i1 %R
}

define i1 @test5(i32 %X) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32 %X, 2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 %X, 7
; CHECK-NEXT:    [[R:%.*]] = or i1 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = icmp eq i16 %Q, 69
  ret i1 %R
}

define i1 @test6(i32 %X) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 %X, -1
; CHECK-NEXT:    [[R:%.*]] = icmp ult i32 [[TMP1]], 3
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [6 x double], [6 x double]* @GD, i32 0, i32 %X
  %Q = load double, double* %P
  %R = fcmp ogt double %Q, 0.0
  ret i1 %R
}

define i1 @test7(i32 %X) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 %X, -1
; CHECK-NEXT:    [[R:%.*]] = icmp ugt i32 [[TMP1]], 2
; CHECK-NEXT:    ret i1 [[R]]
;
  %P = getelementptr inbounds [6 x double], [6 x double]* @GD, i32 0, i32 %X
  %Q = load double, double* %P
  %R = fcmp olt double %Q, 0.0
  ret i1 %R
}

define i1 @test8(i32 %X) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %X, 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 9
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %P = getelementptr inbounds [10 x i16], [10 x i16]* @G16, i32 0, i32 %X
  %Q = load i16, i16* %P
  %R = and i16 %Q, 3
  %S = icmp eq i16 %R, 0
  ret i1 %S
}

@GA = internal constant [4 x { i32, i32 } ] [
  { i32, i32 } { i32 1, i32 0 },
  { i32, i32 } { i32 2, i32 1 },
  { i32, i32 } { i32 3, i32 1 },
  { i32, i32 } { i32 4, i32 0 }
]

define i1 @test9(i32 %X) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 %X, -1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 2
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %P = getelementptr inbounds [4 x { i32, i32 } ], [4 x { i32, i32 } ]* @GA, i32 0, i32 %X, i32 1
  %Q = load i32, i32* %P
  %R = icmp eq i32 %Q, 1
  ret i1 %R
}

define i1 @test10_struct(i32 %x) {
; CHECK-LABEL: @test10_struct(
; CHECK-NEXT:    ret i1 false
;
  %p = getelementptr inbounds %Foo, %Foo* @GS, i32 %x, i32 0
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_noinbounds(i32 %x) {
; CHECK-LABEL: @test10_struct_noinbounds(
; CHECK-NEXT:    [[P:%.*]] = getelementptr %Foo, %Foo* @GS, i32 %x, i32 0
; CHECK-NEXT:    [[Q:%.*]] = load i32, i32* [[P]], align 8
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 [[Q]], 9
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr %Foo, %Foo* @GS, i32 %x, i32 0
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

; Test that the GEP indices are converted before we ever get here
; Index < ptr size
define i1 @test10_struct_i16(i16 %x){
; CHECK-LABEL: @test10_struct_i16(
; CHECK-NEXT:    ret i1 false
;
  %p = getelementptr inbounds %Foo, %Foo* @GS, i16 %x, i32 0
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 0
  ret i1 %r
}

; Test that the GEP indices are converted before we ever get here
; Index > ptr size
define i1 @test10_struct_i64(i64 %x){
; CHECK-LABEL: @test10_struct_i64(
; CHECK-NEXT:    ret i1 false
;
  %p = getelementptr inbounds %Foo, %Foo* @GS, i64 %x, i32 0
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 0
  ret i1 %r
}

define i1 @test10_struct_noinbounds_i16(i16 %x) {
; CHECK-LABEL: @test10_struct_noinbounds_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i16 %x to i32
; CHECK-NEXT:    [[P:%.*]] = getelementptr %Foo, %Foo* @GS, i32 [[TMP1]], i32 0
; CHECK-NEXT:    [[Q:%.*]] = load i32, i32* [[P]], align 8
; CHECK-NEXT:    [[R:%.*]] = icmp eq i32 [[Q]], 0
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr %Foo, %Foo* @GS, i16 %x, i32 0
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 0
  ret i1 %r
}

define i1 @test10_struct_arr(i32 %x) {
; CHECK-LABEL: @test10_struct_arr(
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 %x, 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr inbounds [4 x %Foo], [4 x %Foo]* @GStructArr, i32 0, i32 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_arr_noinbounds(i32 %x) {
; CHECK-LABEL: @test10_struct_arr_noinbounds(
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 %x, 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr [4 x %Foo], [4 x %Foo]* @GStructArr, i32 0, i32 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_arr_i16(i16 %x) {
; CHECK-LABEL: @test10_struct_arr_i16(
; CHECK-NEXT:    [[R:%.*]] = icmp ne i16 %x, 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr inbounds [4 x %Foo], [4 x %Foo]* @GStructArr, i16 0, i16 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_arr_i64(i64 %x) {
; CHECK-LABEL: @test10_struct_arr_i64(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 %x to i32
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr inbounds [4 x %Foo], [4 x %Foo]* @GStructArr, i64 0, i64 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_arr_noinbounds_i16(i16 %x) {
; CHECK-LABEL: @test10_struct_arr_noinbounds_i16(
; CHECK-NEXT:    [[R:%.*]] = icmp ne i16 %x, 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr [4 x %Foo], [4 x %Foo]* @GStructArr, i32 0, i16 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}

define i1 @test10_struct_arr_noinbounds_i64(i64 %x) {
; CHECK-LABEL: @test10_struct_arr_noinbounds_i64(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 %x to i32
; CHECK-NEXT:    [[R:%.*]] = icmp ne i32 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[R]]
;
  %p = getelementptr [4 x %Foo], [4 x %Foo]* @GStructArr, i32 0, i64 %x, i32 2
  %q = load i32, i32* %p
  %r = icmp eq i32 %q, 9
  ret i1 %r
}
