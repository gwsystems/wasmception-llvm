; RUN: llc -mtriple=arm64-apple-ios -O0 %s -o - | FileCheck %s

; Fast-isel can't do vector conversions yet, but it was emitting some highly
; suspect UCVTFUWDri MachineInstrs.
define <4 x float> @test_uitofp(<4 x i32> %in) {
; CHECK-LABEL: test_uitofp:
; CHECK: ucvtf.4s v0, v0

  %res = uitofp <4 x i32> %in to <4 x float>
  ret <4 x float> %res
}

define <2 x double> @test_sitofp(<2 x i32> %in) {
; CHECK-LABEL: test_sitofp:
; CHECK: sshll.2d [[EXT:v[0-9]+]], v0, #0
; CHECK: scvtf.2d v0, [[EXT]]

  %res = sitofp <2 x i32> %in to <2 x double>
  ret <2 x double> %res
}

define <2 x i32> @test_fptoui(<2 x float> %in) {
; CHECK-LABEL: test_fptoui:
; CHECK: fcvtzu.2s v0, v0

  %res = fptoui <2 x float> %in to <2 x i32>
  ret <2 x i32> %res
}

define <2 x i64> @test_fptosi(<2 x double> %in) {
; CHECK-LABEL: test_fptosi:
; CHECK: fcvtzs.2d v0, v0

  %res = fptosi <2 x double> %in to <2 x i64>
  ret <2 x i64> %res
}