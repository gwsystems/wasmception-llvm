; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc64le-unknown-unknown | FileCheck %s

; First, check the generic pattern for any 2 vector constants. Then, check special cases where
; the constants are all off-by-one. Finally, check the extra special cases where the constants
; include 0 or -1.
; Each minimal select test is repeated with a more typical pattern that includes a compare to
; generate the condition value.

define <4 x i32> @sel_C1_or_C2_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_C1_or_C2_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, -16
; CHECK-NEXT:    vspltisw 4, 15
; CHECK-NEXT:    addis 3, 2, .LCPI0_0@toc@ha
; CHECK-NEXT:    addis 4, 2, .LCPI0_1@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI0_0@toc@l
; CHECK-NEXT:    addi 4, 4, .LCPI0_1@toc@l
; CHECK-NEXT:    lvx 18, 0, 3
; CHECK-NEXT:    lvx 19, 0, 4
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vslw 2, 2, 3
; CHECK-NEXT:    vsraw 2, 2, 3
; CHECK-NEXT:    xxsel 34, 51, 50, 34
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 3000, i32 1, i32 -1, i32 0>, <4 x i32> <i32 42, i32 0, i32 -2, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_C1_or_C2_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_C1_or_C2_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    addis 3, 2, .LCPI1_0@toc@ha
; CHECK-NEXT:    addis 4, 2, .LCPI1_1@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI1_0@toc@l
; CHECK-NEXT:    addi 4, 4, .LCPI1_1@toc@l
; CHECK-NEXT:    lvx 19, 0, 3
; CHECK-NEXT:    lvx 4, 0, 4
; CHECK-NEXT:    xxsel 34, 36, 51, 34
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 3000, i32 1, i32 -1, i32 0>, <4 x i32> <i32 42, i32 0, i32 -2, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @sel_Cplus1_or_C_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_Cplus1_or_C_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, 1
; CHECK-NEXT:    addis 3, 2, .LCPI2_0@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI2_0@toc@l
; CHECK-NEXT:    lvx 19, 0, 3
; CHECK-NEXT:    xxland 34, 34, 35
; CHECK-NEXT:    vadduwm 2, 2, 19
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 43, i32 1, i32 -1, i32 0>, <4 x i32> <i32 42, i32 0, i32 -2, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_Cplus1_or_C_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_Cplus1_or_C_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    addis 3, 2, .LCPI3_0@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI3_0@toc@l
; CHECK-NEXT:    lvx 19, 0, 3
; CHECK-NEXT:    vsubuwm 2, 19, 2
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 43, i32 1, i32 -1, i32 0>, <4 x i32> <i32 42, i32 0, i32 -2, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @sel_Cminus1_or_C_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_Cminus1_or_C_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, -16
; CHECK-NEXT:    vspltisw 4, 15
; CHECK-NEXT:    addis 3, 2, .LCPI4_0@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI4_0@toc@l
; CHECK-NEXT:    lvx 19, 0, 3
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vslw 2, 2, 3
; CHECK-NEXT:    vsraw 2, 2, 3
; CHECK-NEXT:    vadduwm 2, 2, 19
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 43, i32 1, i32 -1, i32 0>, <4 x i32> <i32 44, i32 2, i32 0, i32 1>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_Cminus1_or_C_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_Cminus1_or_C_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    addis 3, 2, .LCPI5_0@toc@ha
; CHECK-NEXT:    addi 3, 3, .LCPI5_0@toc@l
; CHECK-NEXT:    lvx 19, 0, 3
; CHECK-NEXT:    vadduwm 2, 2, 19
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 43, i32 1, i32 -1, i32 0>, <4 x i32> <i32 44, i32 2, i32 0, i32 1>
  ret <4 x i32> %add
}

define <4 x i32> @sel_minus1_or_0_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_minus1_or_0_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, -16
; CHECK-NEXT:    vspltisw 4, 15
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vslw 2, 2, 3
; CHECK-NEXT:    vsraw 2, 2, 3
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_minus1_or_0_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_minus1_or_0_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>
  ret <4 x i32> %add
}

define <4 x i32> @sel_0_or_minus1_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_0_or_minus1_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, 1
; CHECK-NEXT:    vspltisb 4, -1
; CHECK-NEXT:    xxland 34, 34, 35
; CHECK-NEXT:    vadduwm 2, 2, 4
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_0_or_minus1_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_0_or_minus1_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    xxlnor 34, 34, 34
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>
  ret <4 x i32> %add
}

define <4 x i32> @sel_1_or_0_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_1_or_0_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, 1
; CHECK-NEXT:    xxland 34, 34, 35
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_1_or_0_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_1_or_0_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    vspltisw 19, 1
; CHECK-NEXT:    xxland 34, 34, 51
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, <4 x i32> <i32 0, i32 0, i32 0, i32 0>
  ret <4 x i32> %add
}

define <4 x i32> @sel_0_or_1_vec(<4 x i1> %cond) {
; CHECK-LABEL: sel_0_or_1_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, 1
; CHECK-NEXT:    xxlandc 34, 35, 34
; CHECK-NEXT:    blr
  %add = select <4 x i1> %cond, <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %add
}

define <4 x i32> @cmp_sel_0_or_1_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: cmp_sel_0_or_1_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    vcmpequw 2, 2, 3
; CHECK-NEXT:    vspltisw 19, 1
; CHECK-NEXT:    xxlnor 0, 34, 34
; CHECK-NEXT:    xxland 34, 0, 51
; CHECK-NEXT:    blr
  %cond = icmp eq <4 x i32> %x, %y
  %add = select <4 x i1> %cond, <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %add
}

