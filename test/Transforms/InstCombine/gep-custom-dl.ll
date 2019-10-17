; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-m:m-p:40:64:64:32-i32:32-i16:16-i8:8-n32"

%struct.B = type { double }
%struct.A = type { %struct.B, i32, i32 }
%struct.C = type { [7 x i8] }


@Global = external global [10 x i8]

; Test that two array indexing geps fold
define i32* @test1(i32* %I) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[B:%.*]] = getelementptr i32, i32* [[I:%.*]], i32 21
; CHECK-NEXT:    ret i32* [[B]]
;
  %A = getelementptr i32, i32* %I, i8 17
  %B = getelementptr i32, i32* %A, i16 4
  ret i32* %B
}

; Test that two getelementptr insts fold
define i32* @test2({ i32 }* %I) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[B:%.*]] = getelementptr { i32 }, { i32 }* [[I:%.*]], i32 1, i32 0
; CHECK-NEXT:    ret i32* [[B]]
;
  %A = getelementptr { i32 }, { i32 }* %I, i32 1
  %B = getelementptr { i32 }, { i32 }* %A, i32 0, i32 0
  ret i32* %B
}

define void @test3(i8 %B) {
; This should be turned into a constexpr instead of being an instruction
; CHECK-LABEL: @test3(
; CHECK-NEXT:    store i8 [[B:%.*]], i8* getelementptr inbounds ([10 x i8], [10 x i8]* @Global, i32 0, i32 4), align 1
; CHECK-NEXT:    ret void
;
  %A = getelementptr [10 x i8], [10 x i8]* @Global, i32 0, i32 4
  store i8 %B, i8* %A
  ret void
}

%as1_ptr_struct = type { i32 addrspace(1)* }
%as2_ptr_struct = type { i32 addrspace(2)* }

@global_as2 = addrspace(2) global i32 zeroinitializer
@global_as1_as2_ptr = addrspace(1) global %as2_ptr_struct { i32 addrspace(2)* @global_as2 }

; This should be turned into a constexpr instead of being an instruction
define void @test_evaluate_gep_nested_as_ptrs(i32 addrspace(2)* %B) {
; CHECK-LABEL: @test_evaluate_gep_nested_as_ptrs(
; CHECK-NEXT:    store i32 addrspace(2)* [[B:%.*]], i32 addrspace(2)* addrspace(1)* getelementptr inbounds (%as2_ptr_struct, [[AS2_PTR_STRUCT:%.*]] addrspace(1)* @global_as1_as2_ptr, i32 0, i32 0), align 8
; CHECK-NEXT:    ret void
;
  %A = getelementptr %as2_ptr_struct, %as2_ptr_struct addrspace(1)* @global_as1_as2_ptr, i32 0, i32 0
  store i32 addrspace(2)* %B, i32 addrspace(2)* addrspace(1)* %A
  ret void
}

@arst = addrspace(1) global [4 x i8 addrspace(2)*] zeroinitializer

define void @test_evaluate_gep_as_ptrs_array(i8 addrspace(2)* %B) {
; CHECK-LABEL: @test_evaluate_gep_as_ptrs_array(
; CHECK-NEXT:    store i8 addrspace(2)* [[B:%.*]], i8 addrspace(2)* addrspace(1)* getelementptr inbounds ([4 x i8 addrspace(2)*], [4 x i8 addrspace(2)*] addrspace(1)* @arst, i32 0, i32 2), align 16
; CHECK-NEXT:    ret void
;

  %A = getelementptr [4 x i8 addrspace(2)*], [4 x i8 addrspace(2)*] addrspace(1)* @arst, i16 0, i16 2
  store i8 addrspace(2)* %B, i8 addrspace(2)* addrspace(1)* %A
  ret void
}

define i32* @test4(i32* %I, i32 %C, i32 %D) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[A:%.*]] = getelementptr i32, i32* [[I:%.*]], i32 [[C:%.*]]
; CHECK-NEXT:    [[B:%.*]] = getelementptr i32, i32* [[A]], i32 [[D:%.*]]
; CHECK-NEXT:    ret i32* [[B]]
;
  %A = getelementptr i32, i32* %I, i32 %C
  %B = getelementptr i32, i32* %A, i32 %D
  ret i32* %B
}


define i1 @test5({ i32, i32 }* %x, { i32, i32 }* %y) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[TMP_4:%.*]] = icmp eq { i32, i32 }* [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret i1 [[TMP_4]]
;
  %tmp.1 = getelementptr { i32, i32 }, { i32, i32 }* %x, i32 0, i32 1
  %tmp.3 = getelementptr { i32, i32 }, { i32, i32 }* %y, i32 0, i32 1
  ;; seteq x, y
  %tmp.4 = icmp eq i32* %tmp.1, %tmp.3
  ret i1 %tmp.4
}

%S = type { i32, [ 100 x i32] }

define <2 x i1> @test6(<2 x i32> %X, <2 x %S*> %P) nounwind {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[C:%.*]] = icmp eq <2 x i32> %X, <i32 -1, i32 -1>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %A = getelementptr inbounds %S, <2 x %S*> %P, <2 x i32> zeroinitializer, <2 x i32> <i32 1, i32 1>, <2 x i32> %X
  %B = getelementptr inbounds %S, <2 x %S*> %P, <2 x i32> <i32 0, i32 0>, <2 x i32> <i32 0, i32 0>
  %C = icmp eq <2 x i32*> %A, %B
  ret <2 x i1> %C
}

; Same as above, but indices scalarized.
define <2 x i1> @test6b(<2 x i32> %X, <2 x %S*> %P) nounwind {
; CHECK-LABEL: @test6b(
; CHECK-NEXT:    [[C:%.*]] = icmp eq <2 x i32> %X, <i32 -1, i32 -1>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %A = getelementptr inbounds %S, <2 x %S*> %P, i32 0, i32 1, <2 x i32> %X
  %B = getelementptr inbounds %S, <2 x %S*> %P, i32 0, i32 0
  %C = icmp eq <2 x i32*> %A, %B
  ret <2 x i1> %C
}

@G = external global [3 x i8]
define i8* @test7(i16 %Idx) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[ZE_IDX:%.*]] = zext i16 [[IDX:%.*]] to i32
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr [3 x i8], [3 x i8]* @G, i32 0, i32 [[ZE_IDX]]
; CHECK-NEXT:    ret i8* [[TMP]]
;
  %ZE_Idx = zext i16 %Idx to i32
  %tmp = getelementptr i8, i8* getelementptr ([3 x i8], [3 x i8]* @G, i32 0, i32 0), i32 %ZE_Idx
  ret i8* %tmp
}


; Test folding of constantexpr geps into normal geps.
@Array = external global [40 x i32]
define i32 *@test8(i32 %X) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[A:%.*]] = getelementptr [40 x i32], [40 x i32]* @Array, i32 0, i32 [[X:%.*]]
; CHECK-NEXT:    ret i32* [[A]]
;
  %A = getelementptr i32, i32* getelementptr ([40 x i32], [40 x i32]* @Array, i32 0, i32 0), i32 %X
  ret i32* %A
}

define i32 *@test9(i32 *%base, i8 %ind) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i8 [[IND:%.*]] to i32
; CHECK-NEXT:    [[RES:%.*]] = getelementptr i32, i32* [[BASE:%.*]], i32 [[TMP1]]
; CHECK-NEXT:    ret i32* [[RES]]
;
  %res = getelementptr i32, i32 *%base, i8 %ind
  ret i32* %res
}

define i32 @test10() {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    ret i32 8
;
  %A = getelementptr { i32, double }, { i32, double }* null, i32 0, i32 1
  %B = ptrtoint double* %A to i32
  ret i32 %B
}
