; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl

@glob = common local_unnamed_addr global i64 0, align 8

; Function Attrs: norecurse nounwind readnone
define i64 @test_llgeull(i64 %a, i64 %b) {
entry:
  %cmp = icmp uge i64 %a, %b
  %conv1 = zext i1 %cmp to i64
  ret i64 %conv1
; CHECK-LABEL: test_llgeull:
; CHECK: subfc {{r[0-9]+}}, r4, r3
; CHECK-NEXT: subfe [[REG1:r[0-9]+]], r4, r4
; CHECK-NEXT: addi r3, [[REG1]], 1
; CHECK: blr
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llgeull_sext(i64 %a, i64 %b) {
entry:
  %cmp = icmp uge i64 %a, %b
  %conv1 = sext i1 %cmp to i64
  ret i64 %conv1
; CHECK-LABEL: @test_llgeull_sext
; CHECK: subfc [[REG1:r[0-9]+]], r4, r3
; CHECK: subfe [[REG2:r[0-9]+]], {{r[0-9]+}}, {{r[0-9]+}}
; CHECK: not [[REG3:r[0-9]+]], [[REG2]]
; CHECK: blr
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llgeull_z(i64 %a) {
entry:
  %cmp = icmp uge i64 %a, 0
  %conv1 = zext i1 %cmp to i64
  ret i64 %conv1
; CHECK-LABEL: @test_llgeull_z
; CHECK: li r3, 1
; CHECK-NEXT: blr
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llgeull_sext_z(i64 %a) {
entry:
  %cmp = icmp uge i64 %a, 0
  %conv1 = sext i1 %cmp to i64
  ret i64 %conv1
; CHECK-LABEL: @test_llgeull_sext_z
; CHECK: li r3, -1
; CHECK-NEXT: blr
}

; Function Attrs: norecurse nounwind
define void @test_llgeull_store(i64 %a, i64 %b) {
entry:
  %cmp = icmp uge i64 %a, %b
  %conv1 = zext i1 %cmp to i64
  store i64 %conv1, i64* @glob
  ret void
; CHECK-LABEL: test_llgeull_store:
; CHECK: subfc {{r[0-9]+}}, r4, r3
; CHECK: subfe [[REG1:r[0-9]+]], r4, r4
; CHECK: addi {{r[0-9]+}}, [[REG1]], 1
; CHECK: blr
}

; Function Attrs: norecurse nounwind
define void @test_llgeull_sext_store(i64 %a, i64 %b) {
entry:
  %cmp = icmp uge i64 %a, %b
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @glob
  ret void
; CHECK-LABEL: @test_llgeull_sext_store
; CHECK: subfc [[REG1:r[0-9]+]], r4, r3
; CHECK: subfe [[REG2:r[0-9]+]], {{r[0-9]+}}, {{r[0-9]+}}
; CHECK: not [[REG3:r[0-9]+]], [[REG2]]
; CHECK: std [[REG3]]
; CHECK: blr
}

; Function Attrs: norecurse nounwind
define void @test_llgeull_z_store(i64 %a) {
entry:
  %cmp = icmp uge i64 %a, 0
  %conv1 = zext i1 %cmp to i64
  store i64 %conv1, i64* @glob
  ret void
; CHECK-LABEL: @test_llgeull_z_store
; CHECK: li [[REG1:r[0-9]+]], 1
; CHECK: std [[REG1]]
; CHECK: blr
}

; Function Attrs: norecurse nounwind
define void @test_llgeull_sext_z_store(i64 %a) {
entry:
  store i64 -1, i64* @glob
  ret void
; CHECK-LABEL: @test_llgeull_sext_z_store
; CHECK: li [[REG1:r[0-9]+]], -1
; CHECK: std [[REG1]]
; CHECK: blr
}

