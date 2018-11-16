; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
@glob = common local_unnamed_addr global i64 0, align 8

define signext i32 @test_ilesll(i64 %a, i64 %b) {
; CHECK-LABEL: test_ilesll:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sradi r5, r4, 63
; CHECK-NEXT:    rldicl r6, r3, 1, 63
; CHECK-NEXT:    subfc r3, r3, r4
; CHECK-NEXT:    adde r3, r5, r6
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i64 %a, %b
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @test_ilesll_sext(i64 %a, i64 %b) {
; CHECK-LABEL: test_ilesll_sext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sradi r5, r4, 63
; CHECK-NEXT:    rldicl r6, r3, 1, 63
; CHECK-NEXT:    subfc r3, r3, r4
; CHECK-NEXT:    adde r3, r5, r6
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i64 %a, %b
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define signext i32 @test_ilesll_z(i64 %a) {
; CHECK-LABEL: test_ilesll_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r4, r3, -1
; CHECK-NEXT:    or r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @test_ilesll_sext_z(i64 %a) {
; CHECK-LABEL: test_ilesll_sext_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r4, r3, -1
; CHECK-NEXT:    or r3, r4, r3
; CHECK-NEXT:    sradi r3, r3, 63
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define void @test_ilesll_store(i64 %a, i64 %b) {
; CHECK-LABEL: test_ilesll_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sradi r6, r4, 63
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    subfc r4, r3, r4
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    adde r3, r6, r3
; CHECK-NEXT:    std r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i64 %a, %b
  %conv1 = zext i1 %cmp to i64
  store i64 %conv1, i64* @glob, align 8
  ret void
}

define void @test_ilesll_sext_store(i64 %a, i64 %b) {
; CHECK-LABEL: test_ilesll_sext_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sradi r6, r4, 63
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    subfc r4, r3, r4
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    adde r3, r6, r3
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    std r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i64 %a, %b
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @glob, align 8
  ret void
}

define void @test_ilesll_z_store(i64 %a) {
; CHECK-LABEL: test_ilesll_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r5, r3, -1
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    or r3, r5, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    std r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv1 = zext i1 %cmp to i64
  store i64 %conv1, i64* @glob, align 8
  ret void
}

define void @test_ilesll_sext_z_store(i64 %a) {
; CHECK-LABEL: test_ilesll_sext_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r5, r3, -1
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    or r3, r5, r3
; CHECK-NEXT:    sradi r3, r3, 63
; CHECK-NEXT:    std r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @glob, align 8
  ret void
}
