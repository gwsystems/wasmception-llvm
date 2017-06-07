; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py

@glob = common local_unnamed_addr global i16 0, align 2

define signext i32 @test_iness(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_iness:
; CHECK:    xor r3, r3, r4
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, %b
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

define signext i32 @test_iness_sext(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_iness_sext:
; CHECK:    xor r3, r3, r4
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, %b
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define signext i32 @test_iness_z(i16 signext %a) {
; CHECK-LABEL: test_iness_z:
; CHECK:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

define signext i32 @test_iness_sext_z(i16 signext %a) {
; CHECK-LABEL: test_iness_sext_z:
; CHECK:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, 0
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define void @test_iness_store(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_iness_store:
; CHECK:    xor r3, r3, r4
; CHECK:    cntlzw r3, r3
; CHECK:    srwi r3, r3, 5
; CHECK:    xori r3, r3, 1
; CHECK:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, %b
  %conv3 = zext i1 %cmp to i16
  store i16 %conv3, i16* @glob, align 2
  ret void
}

define void @test_iness_sext_store(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_iness_sext_store:
; CHECK:    xor r3, r3, r4
; CHECK:    cntlzw r3, r3
; CHECK:    srwi r3, r3, 5
; CHECK:    xori r3, r3, 1
; CHECK:    neg r3, r3
; CHECK:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, %b
  %conv3 = sext i1 %cmp to i16
  store i16 %conv3, i16* @glob, align 2
  ret void
}

define void @test_iness_z_store(i16 signext %a) {
; CHECK-LABEL: test_iness_z_store:
; CHECK:    cntlzw r3, r3
; CHECK:    srwi r3, r3, 5
; CHECK:    xori r3, r3, 1
; CHECK:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, 0
  %conv2 = zext i1 %cmp to i16
  store i16 %conv2, i16* @glob, align 2
  ret void
}

define void @test_iness_sext_z_store(i16 signext %a) {
; CHECK-LABEL: test_iness_sext_z_store:
; CHECK:    cntlzw r3, r3
; CHECK:    srwi r3, r3, 5
; CHECK:    xori r3, r3, 1
; CHECK:    neg r3, r3
; CHECK:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ne i16 %a, 0
  %conv2 = sext i1 %cmp to i16
  store i16 %conv2, i16* @glob, align 2
  ret void
}
