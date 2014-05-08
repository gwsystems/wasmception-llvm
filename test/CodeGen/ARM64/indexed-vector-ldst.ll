; RUN: llc -mtriple=arm64-apple-ios7.0 -o - %s | FileCheck %s

@ptr = global i8* null

define <8 x i8> @test_v8i8_pre_load(<8 x i8>* %addr) {
; CHECK-LABEL: test_v8i8_pre_load:
; CHECK: ldr d0, [x0, #40]!
  %newaddr = getelementptr <8 x i8>* %addr, i32 5
  %val = load <8 x i8>* %newaddr, align 8
  store <8 x i8>* %newaddr, <8 x i8>** bitcast(i8** @ptr to <8 x i8>**)
  ret <8 x i8> %val
}

define <8 x i8> @test_v8i8_post_load(<8 x i8>* %addr) {
; CHECK-LABEL: test_v8i8_post_load:
; CHECK: ldr d0, [x0], #40
  %newaddr = getelementptr <8 x i8>* %addr, i32 5
  %val = load <8 x i8>* %addr, align 8
  store <8 x i8>* %newaddr, <8 x i8>** bitcast(i8** @ptr to <8 x i8>**)
  ret <8 x i8> %val
}

define void @test_v8i8_pre_store(<8 x i8> %in, <8 x i8>* %addr) {
; CHECK-LABEL: test_v8i8_pre_store:
; CHECK: str d0, [x0, #40]!
  %newaddr = getelementptr <8 x i8>* %addr, i32 5
  store <8 x i8> %in, <8 x i8>* %newaddr, align 8
  store <8 x i8>* %newaddr, <8 x i8>** bitcast(i8** @ptr to <8 x i8>**)
  ret void
}

define void @test_v8i8_post_store(<8 x i8> %in, <8 x i8>* %addr) {
; CHECK-LABEL: test_v8i8_post_store:
; CHECK: str d0, [x0], #40
  %newaddr = getelementptr <8 x i8>* %addr, i32 5
  store <8 x i8> %in, <8 x i8>* %addr, align 8
  store <8 x i8>* %newaddr, <8 x i8>** bitcast(i8** @ptr to <8 x i8>**)
  ret void
}

define <4 x i16> @test_v4i16_pre_load(<4 x i16>* %addr) {
; CHECK-LABEL: test_v4i16_pre_load:
; CHECK: ldr d0, [x0, #40]!
  %newaddr = getelementptr <4 x i16>* %addr, i32 5
  %val = load <4 x i16>* %newaddr, align 8
  store <4 x i16>* %newaddr, <4 x i16>** bitcast(i8** @ptr to <4 x i16>**)
  ret <4 x i16> %val
}

define <4 x i16> @test_v4i16_post_load(<4 x i16>* %addr) {
; CHECK-LABEL: test_v4i16_post_load:
; CHECK: ldr d0, [x0], #40
  %newaddr = getelementptr <4 x i16>* %addr, i32 5
  %val = load <4 x i16>* %addr, align 8
  store <4 x i16>* %newaddr, <4 x i16>** bitcast(i8** @ptr to <4 x i16>**)
  ret <4 x i16> %val
}

define void @test_v4i16_pre_store(<4 x i16> %in, <4 x i16>* %addr) {
; CHECK-LABEL: test_v4i16_pre_store:
; CHECK: str d0, [x0, #40]!
  %newaddr = getelementptr <4 x i16>* %addr, i32 5
  store <4 x i16> %in, <4 x i16>* %newaddr, align 8
  store <4 x i16>* %newaddr, <4 x i16>** bitcast(i8** @ptr to <4 x i16>**)
  ret void
}

define void @test_v4i16_post_store(<4 x i16> %in, <4 x i16>* %addr) {
; CHECK-LABEL: test_v4i16_post_store:
; CHECK: str d0, [x0], #40
  %newaddr = getelementptr <4 x i16>* %addr, i32 5
  store <4 x i16> %in, <4 x i16>* %addr, align 8
  store <4 x i16>* %newaddr, <4 x i16>** bitcast(i8** @ptr to <4 x i16>**)
  ret void
}

define <2 x i32> @test_v2i32_pre_load(<2 x i32>* %addr) {
; CHECK-LABEL: test_v2i32_pre_load:
; CHECK: ldr d0, [x0, #40]!
  %newaddr = getelementptr <2 x i32>* %addr, i32 5
  %val = load <2 x i32>* %newaddr, align 8
  store <2 x i32>* %newaddr, <2 x i32>** bitcast(i8** @ptr to <2 x i32>**)
  ret <2 x i32> %val
}

define <2 x i32> @test_v2i32_post_load(<2 x i32>* %addr) {
; CHECK-LABEL: test_v2i32_post_load:
; CHECK: ldr d0, [x0], #40
  %newaddr = getelementptr <2 x i32>* %addr, i32 5
  %val = load <2 x i32>* %addr, align 8
  store <2 x i32>* %newaddr, <2 x i32>** bitcast(i8** @ptr to <2 x i32>**)
  ret <2 x i32> %val
}

define void @test_v2i32_pre_store(<2 x i32> %in, <2 x i32>* %addr) {
; CHECK-LABEL: test_v2i32_pre_store:
; CHECK: str d0, [x0, #40]!
  %newaddr = getelementptr <2 x i32>* %addr, i32 5
  store <2 x i32> %in, <2 x i32>* %newaddr, align 8
  store <2 x i32>* %newaddr, <2 x i32>** bitcast(i8** @ptr to <2 x i32>**)
  ret void
}

define void @test_v2i32_post_store(<2 x i32> %in, <2 x i32>* %addr) {
; CHECK-LABEL: test_v2i32_post_store:
; CHECK: str d0, [x0], #40
  %newaddr = getelementptr <2 x i32>* %addr, i32 5
  store <2 x i32> %in, <2 x i32>* %addr, align 8
  store <2 x i32>* %newaddr, <2 x i32>** bitcast(i8** @ptr to <2 x i32>**)
  ret void
}

define <2 x float> @test_v2f32_pre_load(<2 x float>* %addr) {
; CHECK-LABEL: test_v2f32_pre_load:
; CHECK: ldr d0, [x0, #40]!
  %newaddr = getelementptr <2 x float>* %addr, i32 5
  %val = load <2 x float>* %newaddr, align 8
  store <2 x float>* %newaddr, <2 x float>** bitcast(i8** @ptr to <2 x float>**)
  ret <2 x float> %val
}

define <2 x float> @test_v2f32_post_load(<2 x float>* %addr) {
; CHECK-LABEL: test_v2f32_post_load:
; CHECK: ldr d0, [x0], #40
  %newaddr = getelementptr <2 x float>* %addr, i32 5
  %val = load <2 x float>* %addr, align 8
  store <2 x float>* %newaddr, <2 x float>** bitcast(i8** @ptr to <2 x float>**)
  ret <2 x float> %val
}

define void @test_v2f32_pre_store(<2 x float> %in, <2 x float>* %addr) {
; CHECK-LABEL: test_v2f32_pre_store:
; CHECK: str d0, [x0, #40]!
  %newaddr = getelementptr <2 x float>* %addr, i32 5
  store <2 x float> %in, <2 x float>* %newaddr, align 8
  store <2 x float>* %newaddr, <2 x float>** bitcast(i8** @ptr to <2 x float>**)
  ret void
}

define void @test_v2f32_post_store(<2 x float> %in, <2 x float>* %addr) {
; CHECK-LABEL: test_v2f32_post_store:
; CHECK: str d0, [x0], #40
  %newaddr = getelementptr <2 x float>* %addr, i32 5
  store <2 x float> %in, <2 x float>* %addr, align 8
  store <2 x float>* %newaddr, <2 x float>** bitcast(i8** @ptr to <2 x float>**)
  ret void
}

define <1 x i64> @test_v1i64_pre_load(<1 x i64>* %addr) {
; CHECK-LABEL: test_v1i64_pre_load:
; CHECK: ldr d0, [x0, #40]!
  %newaddr = getelementptr <1 x i64>* %addr, i32 5
  %val = load <1 x i64>* %newaddr, align 8
  store <1 x i64>* %newaddr, <1 x i64>** bitcast(i8** @ptr to <1 x i64>**)
  ret <1 x i64> %val
}

define <1 x i64> @test_v1i64_post_load(<1 x i64>* %addr) {
; CHECK-LABEL: test_v1i64_post_load:
; CHECK: ldr d0, [x0], #40
  %newaddr = getelementptr <1 x i64>* %addr, i32 5
  %val = load <1 x i64>* %addr, align 8
  store <1 x i64>* %newaddr, <1 x i64>** bitcast(i8** @ptr to <1 x i64>**)
  ret <1 x i64> %val
}

define void @test_v1i64_pre_store(<1 x i64> %in, <1 x i64>* %addr) {
; CHECK-LABEL: test_v1i64_pre_store:
; CHECK: str d0, [x0, #40]!
  %newaddr = getelementptr <1 x i64>* %addr, i32 5
  store <1 x i64> %in, <1 x i64>* %newaddr, align 8
  store <1 x i64>* %newaddr, <1 x i64>** bitcast(i8** @ptr to <1 x i64>**)
  ret void
}

define void @test_v1i64_post_store(<1 x i64> %in, <1 x i64>* %addr) {
; CHECK-LABEL: test_v1i64_post_store:
; CHECK: str d0, [x0], #40
  %newaddr = getelementptr <1 x i64>* %addr, i32 5
  store <1 x i64> %in, <1 x i64>* %addr, align 8
  store <1 x i64>* %newaddr, <1 x i64>** bitcast(i8** @ptr to <1 x i64>**)
  ret void
}

define <16 x i8> @test_v16i8_pre_load(<16 x i8>* %addr) {
; CHECK-LABEL: test_v16i8_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <16 x i8>* %addr, i32 5
  %val = load <16 x i8>* %newaddr, align 8
  store <16 x i8>* %newaddr, <16 x i8>** bitcast(i8** @ptr to <16 x i8>**)
  ret <16 x i8> %val
}

define <16 x i8> @test_v16i8_post_load(<16 x i8>* %addr) {
; CHECK-LABEL: test_v16i8_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <16 x i8>* %addr, i32 5
  %val = load <16 x i8>* %addr, align 8
  store <16 x i8>* %newaddr, <16 x i8>** bitcast(i8** @ptr to <16 x i8>**)
  ret <16 x i8> %val
}

define void @test_v16i8_pre_store(<16 x i8> %in, <16 x i8>* %addr) {
; CHECK-LABEL: test_v16i8_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <16 x i8>* %addr, i32 5
  store <16 x i8> %in, <16 x i8>* %newaddr, align 8
  store <16 x i8>* %newaddr, <16 x i8>** bitcast(i8** @ptr to <16 x i8>**)
  ret void
}

define void @test_v16i8_post_store(<16 x i8> %in, <16 x i8>* %addr) {
; CHECK-LABEL: test_v16i8_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <16 x i8>* %addr, i32 5
  store <16 x i8> %in, <16 x i8>* %addr, align 8
  store <16 x i8>* %newaddr, <16 x i8>** bitcast(i8** @ptr to <16 x i8>**)
  ret void
}

define <8 x i16> @test_v8i16_pre_load(<8 x i16>* %addr) {
; CHECK-LABEL: test_v8i16_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <8 x i16>* %addr, i32 5
  %val = load <8 x i16>* %newaddr, align 8
  store <8 x i16>* %newaddr, <8 x i16>** bitcast(i8** @ptr to <8 x i16>**)
  ret <8 x i16> %val
}

define <8 x i16> @test_v8i16_post_load(<8 x i16>* %addr) {
; CHECK-LABEL: test_v8i16_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <8 x i16>* %addr, i32 5
  %val = load <8 x i16>* %addr, align 8
  store <8 x i16>* %newaddr, <8 x i16>** bitcast(i8** @ptr to <8 x i16>**)
  ret <8 x i16> %val
}

define void @test_v8i16_pre_store(<8 x i16> %in, <8 x i16>* %addr) {
; CHECK-LABEL: test_v8i16_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <8 x i16>* %addr, i32 5
  store <8 x i16> %in, <8 x i16>* %newaddr, align 8
  store <8 x i16>* %newaddr, <8 x i16>** bitcast(i8** @ptr to <8 x i16>**)
  ret void
}

define void @test_v8i16_post_store(<8 x i16> %in, <8 x i16>* %addr) {
; CHECK-LABEL: test_v8i16_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <8 x i16>* %addr, i32 5
  store <8 x i16> %in, <8 x i16>* %addr, align 8
  store <8 x i16>* %newaddr, <8 x i16>** bitcast(i8** @ptr to <8 x i16>**)
  ret void
}

define <4 x i32> @test_v4i32_pre_load(<4 x i32>* %addr) {
; CHECK-LABEL: test_v4i32_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <4 x i32>* %addr, i32 5
  %val = load <4 x i32>* %newaddr, align 8
  store <4 x i32>* %newaddr, <4 x i32>** bitcast(i8** @ptr to <4 x i32>**)
  ret <4 x i32> %val
}

define <4 x i32> @test_v4i32_post_load(<4 x i32>* %addr) {
; CHECK-LABEL: test_v4i32_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <4 x i32>* %addr, i32 5
  %val = load <4 x i32>* %addr, align 8
  store <4 x i32>* %newaddr, <4 x i32>** bitcast(i8** @ptr to <4 x i32>**)
  ret <4 x i32> %val
}

define void @test_v4i32_pre_store(<4 x i32> %in, <4 x i32>* %addr) {
; CHECK-LABEL: test_v4i32_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <4 x i32>* %addr, i32 5
  store <4 x i32> %in, <4 x i32>* %newaddr, align 8
  store <4 x i32>* %newaddr, <4 x i32>** bitcast(i8** @ptr to <4 x i32>**)
  ret void
}

define void @test_v4i32_post_store(<4 x i32> %in, <4 x i32>* %addr) {
; CHECK-LABEL: test_v4i32_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <4 x i32>* %addr, i32 5
  store <4 x i32> %in, <4 x i32>* %addr, align 8
  store <4 x i32>* %newaddr, <4 x i32>** bitcast(i8** @ptr to <4 x i32>**)
  ret void
}


define <4 x float> @test_v4f32_pre_load(<4 x float>* %addr) {
; CHECK-LABEL: test_v4f32_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <4 x float>* %addr, i32 5
  %val = load <4 x float>* %newaddr, align 8
  store <4 x float>* %newaddr, <4 x float>** bitcast(i8** @ptr to <4 x float>**)
  ret <4 x float> %val
}

define <4 x float> @test_v4f32_post_load(<4 x float>* %addr) {
; CHECK-LABEL: test_v4f32_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <4 x float>* %addr, i32 5
  %val = load <4 x float>* %addr, align 8
  store <4 x float>* %newaddr, <4 x float>** bitcast(i8** @ptr to <4 x float>**)
  ret <4 x float> %val
}

define void @test_v4f32_pre_store(<4 x float> %in, <4 x float>* %addr) {
; CHECK-LABEL: test_v4f32_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <4 x float>* %addr, i32 5
  store <4 x float> %in, <4 x float>* %newaddr, align 8
  store <4 x float>* %newaddr, <4 x float>** bitcast(i8** @ptr to <4 x float>**)
  ret void
}

define void @test_v4f32_post_store(<4 x float> %in, <4 x float>* %addr) {
; CHECK-LABEL: test_v4f32_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <4 x float>* %addr, i32 5
  store <4 x float> %in, <4 x float>* %addr, align 8
  store <4 x float>* %newaddr, <4 x float>** bitcast(i8** @ptr to <4 x float>**)
  ret void
}


define <2 x i64> @test_v2i64_pre_load(<2 x i64>* %addr) {
; CHECK-LABEL: test_v2i64_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <2 x i64>* %addr, i32 5
  %val = load <2 x i64>* %newaddr, align 8
  store <2 x i64>* %newaddr, <2 x i64>** bitcast(i8** @ptr to <2 x i64>**)
  ret <2 x i64> %val
}

define <2 x i64> @test_v2i64_post_load(<2 x i64>* %addr) {
; CHECK-LABEL: test_v2i64_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <2 x i64>* %addr, i32 5
  %val = load <2 x i64>* %addr, align 8
  store <2 x i64>* %newaddr, <2 x i64>** bitcast(i8** @ptr to <2 x i64>**)
  ret <2 x i64> %val
}

define void @test_v2i64_pre_store(<2 x i64> %in, <2 x i64>* %addr) {
; CHECK-LABEL: test_v2i64_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <2 x i64>* %addr, i32 5
  store <2 x i64> %in, <2 x i64>* %newaddr, align 8
  store <2 x i64>* %newaddr, <2 x i64>** bitcast(i8** @ptr to <2 x i64>**)
  ret void
}

define void @test_v2i64_post_store(<2 x i64> %in, <2 x i64>* %addr) {
; CHECK-LABEL: test_v2i64_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <2 x i64>* %addr, i32 5
  store <2 x i64> %in, <2 x i64>* %addr, align 8
  store <2 x i64>* %newaddr, <2 x i64>** bitcast(i8** @ptr to <2 x i64>**)
  ret void
}


define <2 x double> @test_v2f64_pre_load(<2 x double>* %addr) {
; CHECK-LABEL: test_v2f64_pre_load:
; CHECK: ldr q0, [x0, #80]!
  %newaddr = getelementptr <2 x double>* %addr, i32 5
  %val = load <2 x double>* %newaddr, align 8
  store <2 x double>* %newaddr, <2 x double>** bitcast(i8** @ptr to <2 x double>**)
  ret <2 x double> %val
}

define <2 x double> @test_v2f64_post_load(<2 x double>* %addr) {
; CHECK-LABEL: test_v2f64_post_load:
; CHECK: ldr q0, [x0], #80
  %newaddr = getelementptr <2 x double>* %addr, i32 5
  %val = load <2 x double>* %addr, align 8
  store <2 x double>* %newaddr, <2 x double>** bitcast(i8** @ptr to <2 x double>**)
  ret <2 x double> %val
}

define void @test_v2f64_pre_store(<2 x double> %in, <2 x double>* %addr) {
; CHECK-LABEL: test_v2f64_pre_store:
; CHECK: str q0, [x0, #80]!
  %newaddr = getelementptr <2 x double>* %addr, i32 5
  store <2 x double> %in, <2 x double>* %newaddr, align 8
  store <2 x double>* %newaddr, <2 x double>** bitcast(i8** @ptr to <2 x double>**)
  ret void
}

define void @test_v2f64_post_store(<2 x double> %in, <2 x double>* %addr) {
; CHECK-LABEL: test_v2f64_post_store:
; CHECK: str q0, [x0], #80
  %newaddr = getelementptr <2 x double>* %addr, i32 5
  store <2 x double> %in, <2 x double>* %addr, align 8
  store <2 x double>* %newaddr, <2 x double>** bitcast(i8** @ptr to <2 x double>**)
  ret void
}

define i8* @test_v16i8_post_imm_st1_lane(<16 x i8> %in, i8* %addr) {
; CHECK-LABEL: test_v16i8_post_imm_st1_lane:
; CHECK: st1.b { v0 }[3], [x0], #1
  %elt = extractelement <16 x i8> %in, i32 3
  store i8 %elt, i8* %addr

  %newaddr = getelementptr i8* %addr, i32 1
  ret i8* %newaddr
}

define i8* @test_v16i8_post_reg_st1_lane(<16 x i8> %in, i8* %addr) {
; CHECK-LABEL: test_v16i8_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x2
; CHECK: st1.b { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <16 x i8> %in, i32 3
  store i8 %elt, i8* %addr

  %newaddr = getelementptr i8* %addr, i32 2
  ret i8* %newaddr
}


define i16* @test_v8i16_post_imm_st1_lane(<8 x i16> %in, i16* %addr) {
; CHECK-LABEL: test_v8i16_post_imm_st1_lane:
; CHECK: st1.h { v0 }[3], [x0], #2
  %elt = extractelement <8 x i16> %in, i32 3
  store i16 %elt, i16* %addr

  %newaddr = getelementptr i16* %addr, i32 1
  ret i16* %newaddr
}

define i16* @test_v8i16_post_reg_st1_lane(<8 x i16> %in, i16* %addr) {
; CHECK-LABEL: test_v8i16_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x4
; CHECK: st1.h { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <8 x i16> %in, i32 3
  store i16 %elt, i16* %addr

  %newaddr = getelementptr i16* %addr, i32 2
  ret i16* %newaddr
}

define i32* @test_v4i32_post_imm_st1_lane(<4 x i32> %in, i32* %addr) {
; CHECK-LABEL: test_v4i32_post_imm_st1_lane:
; CHECK: st1.s { v0 }[3], [x0], #4
  %elt = extractelement <4 x i32> %in, i32 3
  store i32 %elt, i32* %addr

  %newaddr = getelementptr i32* %addr, i32 1
  ret i32* %newaddr
}

define i32* @test_v4i32_post_reg_st1_lane(<4 x i32> %in, i32* %addr) {
; CHECK-LABEL: test_v4i32_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x8
; CHECK: st1.s { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <4 x i32> %in, i32 3
  store i32 %elt, i32* %addr

  %newaddr = getelementptr i32* %addr, i32 2
  ret i32* %newaddr
}

define float* @test_v4f32_post_imm_st1_lane(<4 x float> %in, float* %addr) {
; CHECK-LABEL: test_v4f32_post_imm_st1_lane:
; CHECK: st1.s { v0 }[3], [x0], #4
  %elt = extractelement <4 x float> %in, i32 3
  store float %elt, float* %addr

  %newaddr = getelementptr float* %addr, i32 1
  ret float* %newaddr
}

define float* @test_v4f32_post_reg_st1_lane(<4 x float> %in, float* %addr) {
; CHECK-LABEL: test_v4f32_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x8
; CHECK: st1.s { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <4 x float> %in, i32 3
  store float %elt, float* %addr

  %newaddr = getelementptr float* %addr, i32 2
  ret float* %newaddr
}

define i64* @test_v2i64_post_imm_st1_lane(<2 x i64> %in, i64* %addr) {
; CHECK-LABEL: test_v2i64_post_imm_st1_lane:
; CHECK: st1.d { v0 }[1], [x0], #8
  %elt = extractelement <2 x i64> %in, i64 1
  store i64 %elt, i64* %addr

  %newaddr = getelementptr i64* %addr, i64 1
  ret i64* %newaddr
}

define i64* @test_v2i64_post_reg_st1_lane(<2 x i64> %in, i64* %addr) {
; CHECK-LABEL: test_v2i64_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x10
; CHECK: st1.d { v0 }[1], [x0], x[[OFFSET]]
  %elt = extractelement <2 x i64> %in, i64 1
  store i64 %elt, i64* %addr

  %newaddr = getelementptr i64* %addr, i64 2
  ret i64* %newaddr
}

define double* @test_v2f64_post_imm_st1_lane(<2 x double> %in, double* %addr) {
; CHECK-LABEL: test_v2f64_post_imm_st1_lane:
; CHECK: st1.d { v0 }[1], [x0], #8
  %elt = extractelement <2 x double> %in, i32 1
  store double %elt, double* %addr

  %newaddr = getelementptr double* %addr, i32 1
  ret double* %newaddr
}

define double* @test_v2f64_post_reg_st1_lane(<2 x double> %in, double* %addr) {
; CHECK-LABEL: test_v2f64_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x10
; CHECK: st1.d { v0 }[1], [x0], x[[OFFSET]]
  %elt = extractelement <2 x double> %in, i32 1
  store double %elt, double* %addr

  %newaddr = getelementptr double* %addr, i32 2
  ret double* %newaddr
}

define i8* @test_v8i8_post_imm_st1_lane(<8 x i8> %in, i8* %addr) {
; CHECK-LABEL: test_v8i8_post_imm_st1_lane:
; CHECK: st1.b { v0 }[3], [x0], #1
  %elt = extractelement <8 x i8> %in, i32 3
  store i8 %elt, i8* %addr

  %newaddr = getelementptr i8* %addr, i32 1
  ret i8* %newaddr
}

define i8* @test_v8i8_post_reg_st1_lane(<8 x i8> %in, i8* %addr) {
; CHECK-LABEL: test_v8i8_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x2
; CHECK: st1.b { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <8 x i8> %in, i32 3
  store i8 %elt, i8* %addr

  %newaddr = getelementptr i8* %addr, i32 2
  ret i8* %newaddr
}

define i16* @test_v4i16_post_imm_st1_lane(<4 x i16> %in, i16* %addr) {
; CHECK-LABEL: test_v4i16_post_imm_st1_lane:
; CHECK: st1.h { v0 }[3], [x0], #2
  %elt = extractelement <4 x i16> %in, i32 3
  store i16 %elt, i16* %addr

  %newaddr = getelementptr i16* %addr, i32 1
  ret i16* %newaddr
}

define i16* @test_v4i16_post_reg_st1_lane(<4 x i16> %in, i16* %addr) {
; CHECK-LABEL: test_v4i16_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x4
; CHECK: st1.h { v0 }[3], [x0], x[[OFFSET]]
  %elt = extractelement <4 x i16> %in, i32 3
  store i16 %elt, i16* %addr

  %newaddr = getelementptr i16* %addr, i32 2
  ret i16* %newaddr
}

define i32* @test_v2i32_post_imm_st1_lane(<2 x i32> %in, i32* %addr) {
; CHECK-LABEL: test_v2i32_post_imm_st1_lane:
; CHECK: st1.s { v0 }[1], [x0], #4
  %elt = extractelement <2 x i32> %in, i32 1
  store i32 %elt, i32* %addr

  %newaddr = getelementptr i32* %addr, i32 1
  ret i32* %newaddr
}

define i32* @test_v2i32_post_reg_st1_lane(<2 x i32> %in, i32* %addr) {
; CHECK-LABEL: test_v2i32_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x8
; CHECK: st1.s { v0 }[1], [x0], x[[OFFSET]]
  %elt = extractelement <2 x i32> %in, i32 1
  store i32 %elt, i32* %addr

  %newaddr = getelementptr i32* %addr, i32 2
  ret i32* %newaddr
}

define float* @test_v2f32_post_imm_st1_lane(<2 x float> %in, float* %addr) {
; CHECK-LABEL: test_v2f32_post_imm_st1_lane:
; CHECK: st1.s { v0 }[1], [x0], #4
  %elt = extractelement <2 x float> %in, i32 1
  store float %elt, float* %addr

  %newaddr = getelementptr float* %addr, i32 1
  ret float* %newaddr
}

define float* @test_v2f32_post_reg_st1_lane(<2 x float> %in, float* %addr) {
; CHECK-LABEL: test_v2f32_post_reg_st1_lane:
; CHECK: orr w[[OFFSET:[0-9]+]], wzr, #0x8
; CHECK: st1.s { v0 }[1], [x0], x[[OFFSET]]
  %elt = extractelement <2 x float> %in, i32 1
  store float %elt, float* %addr

  %newaddr = getelementptr float* %addr, i32 2
  ret float* %newaddr
}

define { <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld2(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld2:
;CHECK: ld2.16b { v0, v1 }, [x0], #32
  %ld2 = tail call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

define { <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld2(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld2:
;CHECK: ld2.16b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

declare { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld2(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld2:
;CHECK: ld2.8b { v0, v1 }, [x0], #16
  %ld2 = tail call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 16
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

define { <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld2(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld2:
;CHECK: ld2.8b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

declare { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld2(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld2:
;CHECK: ld2.8h { v0, v1 }, [x0], #32
  %ld2 = tail call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

define { <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld2(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld2:
;CHECK: ld2.8h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

declare { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld2(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld2:
;CHECK: ld2.4h { v0, v1 }, [x0], #16
  %ld2 = tail call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 8
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

define { <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld2(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld2:
;CHECK: ld2.4h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

declare { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld2(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld2:
;CHECK: ld2.4s { v0, v1 }, [x0], #32
  %ld2 = tail call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

define { <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld2(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld2:
;CHECK: ld2.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

declare { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld2(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld2:
;CHECK: ld2.2s { v0, v1 }, [x0], #16
  %ld2 = tail call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

define { <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld2(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld2:
;CHECK: ld2.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

declare { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld2(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld2:
;CHECK: ld2.2d { v0, v1 }, [x0], #32
  %ld2 = tail call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

define { <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld2(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld2:
;CHECK: ld2.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

declare { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld2(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld2:
;CHECK: ld1.1d { v0, v1 }, [x0], #16
  %ld2 = tail call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

define { <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld2(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld2:
;CHECK: ld1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

declare { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float> } @test_v4f32_post_imm_ld2(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld2:
;CHECK: ld2.4s { v0, v1 }, [x0], #32
  %ld2 = tail call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 8
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

define { <4 x float>, <4 x float> } @test_v4f32_post_reg_ld2(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld2:
;CHECK: ld2.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

declare { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2.v4f32.p0f32(float*)


define { <2 x float>, <2 x float> } @test_v2f32_post_imm_ld2(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld2:
;CHECK: ld2.2s { v0, v1 }, [x0], #16
  %ld2 = tail call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

define { <2 x float>, <2 x float> } @test_v2f32_post_reg_ld2(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld2:
;CHECK: ld2.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

declare { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2.v2f32.p0f32(float*)


define { <2 x double>, <2 x double> } @test_v2f64_post_imm_ld2(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld2:
;CHECK: ld2.2d { v0, v1 }, [x0], #32
  %ld2 = tail call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

define { <2 x double>, <2 x double> } @test_v2f64_post_reg_ld2(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld2:
;CHECK: ld2.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

declare { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2.v2f64.p0f64(double*)


define { <1 x double>, <1 x double> } @test_v1f64_post_imm_ld2(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld2:
;CHECK: ld1.1d { v0, v1 }, [x0], #16
  %ld2 = tail call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

define { <1 x double>, <1 x double> } @test_v1f64_post_reg_ld2(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld2:
;CHECK: ld1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = tail call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

declare { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2.v1f64.p0f64(double*)


define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld3(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld3:
;CHECK: ld3.16b { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 48
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld3(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld3:
;CHECK: ld3.16b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

declare { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld3(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld3:
;CHECK: ld3.8b { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 24
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld3(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld3:
;CHECK: ld3.8b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

declare { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld3(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld3:
;CHECK: ld3.8h { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 24
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld3(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld3:
;CHECK: ld3.8h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

declare { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld3(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld3:
;CHECK: ld3.4h { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 12
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld3(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld3:
;CHECK: ld3.4h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

declare { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld3(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld3:
;CHECK: ld3.4s { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 12
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld3(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld3:
;CHECK: ld3.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

declare { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld3(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld3:
;CHECK: ld3.2s { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 6
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld3(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld3:
;CHECK: ld3.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

declare { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld3(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld3:
;CHECK: ld3.2d { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 6
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld3(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld3:
;CHECK: ld3.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

declare { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld3(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld3(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

declare { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld3(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld3:
;CHECK: ld3.4s { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 12
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld3(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld3:
;CHECK: ld3.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

declare { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3.v4f32.p0f32(float*)


define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld3(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld3:
;CHECK: ld3.2s { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 6
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld3(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld3:
;CHECK: ld3.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

declare { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3.v2f32.p0f32(float*)


define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld3(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld3:
;CHECK: ld3.2d { v0, v1, v2 }, [x0], #48
  %ld3 = tail call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 6
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld3(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld3:
;CHECK: ld3.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

declare { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3.v2f64.p0f64(double*)


define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld3(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], #24
  %ld3 = tail call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld3(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = tail call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

declare { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3.v1f64.p0f64(double*)


define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld4(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld4:
;CHECK: ld4.16b { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 64
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld4(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld4:
;CHECK: ld4.16b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

declare { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld4(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld4:
;CHECK: ld4.8b { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld4(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld4:
;CHECK: ld4.8b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

declare { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld4(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld4:
;CHECK: ld4.8h { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 32
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld4(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld4:
;CHECK: ld4.8h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

declare { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld4(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld4:
;CHECK: ld4.4h { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld4(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld4:
;CHECK: ld4.4h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

declare { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld4(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld4:
;CHECK: ld4.4s { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 16
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld4(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld4:
;CHECK: ld4.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

declare { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld4(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld4:
;CHECK: ld4.2s { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld4(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld4:
;CHECK: ld4.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

declare { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld4(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld4:
;CHECK: ld4.2d { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 8
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld4(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld4:
;CHECK: ld4.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

declare { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld4(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld4(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

declare { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld4(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld4:
;CHECK: ld4.4s { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 16
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld4(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld4:
;CHECK: ld4.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

declare { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4.v4f32.p0f32(float*)


define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld4(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld4:
;CHECK: ld4.2s { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 8
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld4(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld4:
;CHECK: ld4.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

declare { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4.v2f32.p0f32(float*)


define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld4(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld4:
;CHECK: ld4.2d { v0, v1, v2, v3 }, [x0], #64
  %ld4 = tail call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 8
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld4(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld4:
;CHECK: ld4.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

declare { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4.v2f64.p0f64(double*)


define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld4(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = tail call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld4(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = tail call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

declare { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4.v1f64.p0f64(double*)

define { <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld1x2(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld1x2:
;CHECK: ld1.16b { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x2.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld1x2
}

define { <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld1x2(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld1x2:
;CHECK: ld1.16b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x2.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld1x2
}

declare { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x2.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld1x2(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld1x2:
;CHECK: ld1.8b { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x2.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 16
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld1x2
}

define { <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld1x2(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld1x2:
;CHECK: ld1.8b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x2.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld1x2
}

declare { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x2.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld1x2(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld1x2:
;CHECK: ld1.8h { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x2.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld1x2
}

define { <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld1x2(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld1x2:
;CHECK: ld1.8h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x2.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld1x2
}

declare { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x2.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld1x2(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld1x2:
;CHECK: ld1.4h { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x2.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 8
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld1x2
}

define { <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld1x2(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld1x2:
;CHECK: ld1.4h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x2.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld1x2
}

declare { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x2.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld1x2(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld1x2:
;CHECK: ld1.4s { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x2.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld1x2
}

define { <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld1x2(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld1x2:
;CHECK: ld1.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x2.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld1x2
}

declare { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x2.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld1x2(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld1x2:
;CHECK: ld1.2s { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x2.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld1x2
}

define { <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld1x2(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld1x2:
;CHECK: ld1.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x2.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld1x2
}

declare { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x2.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld1x2(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld1x2:
;CHECK: ld1.2d { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x2.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld1x2
}

define { <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld1x2(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld1x2:
;CHECK: ld1.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x2.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld1x2
}

declare { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x2.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld1x2(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld1x2:
;CHECK: ld1.1d { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x2.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld1x2
}

define { <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld1x2(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld1x2:
;CHECK: ld1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x2.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld1x2
}

declare { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x2.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float> } @test_v4f32_post_imm_ld1x2(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld1x2:
;CHECK: ld1.4s { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x2.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 8
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld1x2
}

define { <4 x float>, <4 x float> } @test_v4f32_post_reg_ld1x2(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld1x2:
;CHECK: ld1.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x2.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld1x2
}

declare { <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x2.v4f32.p0f32(float*)


define { <2 x float>, <2 x float> } @test_v2f32_post_imm_ld1x2(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld1x2:
;CHECK: ld1.2s { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x2.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld1x2
}

define { <2 x float>, <2 x float> } @test_v2f32_post_reg_ld1x2(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld1x2:
;CHECK: ld1.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x2.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld1x2
}

declare { <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x2.v2f32.p0f32(float*)


define { <2 x double>, <2 x double> } @test_v2f64_post_imm_ld1x2(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld1x2:
;CHECK: ld1.2d { v0, v1 }, [x0], #32
  %ld1x2 = tail call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x2.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld1x2
}

define { <2 x double>, <2 x double> } @test_v2f64_post_reg_ld1x2(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld1x2:
;CHECK: ld1.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x2.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld1x2
}

declare { <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x2.v2f64.p0f64(double*)


define { <1 x double>, <1 x double> } @test_v1f64_post_imm_ld1x2(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld1x2:
;CHECK: ld1.1d { v0, v1 }, [x0], #16
  %ld1x2 = tail call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x2.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld1x2
}

define { <1 x double>, <1 x double> } @test_v1f64_post_reg_ld1x2(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld1x2:
;CHECK: ld1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld1x2 = tail call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x2.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld1x2
}

declare { <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x2.v1f64.p0f64(double*)


define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld1x3(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld1x3:
;CHECK: ld1.16b { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x3.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 48
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld1x3
}

define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld1x3(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld1x3:
;CHECK: ld1.16b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x3.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld1x3
}

declare { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x3.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld1x3(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld1x3:
;CHECK: ld1.8b { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x3.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 24
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld1x3
}

define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld1x3(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld1x3:
;CHECK: ld1.8b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x3.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld1x3
}

declare { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x3.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld1x3(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld1x3:
;CHECK: ld1.8h { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x3.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 24
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld1x3
}

define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld1x3(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld1x3:
;CHECK: ld1.8h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x3.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld1x3
}

declare { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x3.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld1x3(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld1x3:
;CHECK: ld1.4h { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x3.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 12
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld1x3
}

define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld1x3(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld1x3:
;CHECK: ld1.4h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x3.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld1x3
}

declare { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x3.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld1x3(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld1x3:
;CHECK: ld1.4s { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x3.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 12
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld1x3
}

define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld1x3(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld1x3:
;CHECK: ld1.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x3.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld1x3
}

declare { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x3.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld1x3(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld1x3:
;CHECK: ld1.2s { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x3.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 6
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld1x3
}

define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld1x3(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld1x3:
;CHECK: ld1.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x3.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld1x3
}

declare { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x3.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld1x3(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld1x3:
;CHECK: ld1.2d { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x3.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 6
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld1x3
}

define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld1x3(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld1x3:
;CHECK: ld1.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x3.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld1x3
}

declare { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x3.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld1x3(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld1x3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x3.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld1x3
}

define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld1x3(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld1x3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x3.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld1x3
}

declare { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x3.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld1x3(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld1x3:
;CHECK: ld1.4s { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x3.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 12
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld1x3
}

define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld1x3(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld1x3:
;CHECK: ld1.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x3.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld1x3
}

declare { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x3.v4f32.p0f32(float*)


define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld1x3(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld1x3:
;CHECK: ld1.2s { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x3.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 6
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld1x3
}

define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld1x3(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld1x3:
;CHECK: ld1.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x3.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld1x3
}

declare { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x3.v2f32.p0f32(float*)


define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld1x3(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld1x3:
;CHECK: ld1.2d { v0, v1, v2 }, [x0], #48
  %ld1x3 = tail call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x3.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 6
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld1x3
}

define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld1x3(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld1x3:
;CHECK: ld1.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x3.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld1x3
}

declare { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x3.v2f64.p0f64(double*)


define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld1x3(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld1x3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], #24
  %ld1x3 = tail call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x3.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld1x3
}

define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld1x3(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld1x3:
;CHECK: ld1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld1x3 = tail call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x3.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld1x3
}

declare { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x3.v1f64.p0f64(double*)


define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld1x4(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v16i8_post_imm_ld1x4:
;CHECK: ld1.16b { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x4.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 64
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld1x4
}

define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld1x4(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v16i8_post_reg_ld1x4:
;CHECK: ld1.16b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x4.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld1x4
}

declare { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld1x4.v16i8.p0i8(i8*)


define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld1x4(i8* %A, i8** %ptr) {
;CHECK-LABEL: test_v8i8_post_imm_ld1x4:
;CHECK: ld1.8b { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x4.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld1x4
}

define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld1x4(i8* %A, i8** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i8_post_reg_ld1x4:
;CHECK: ld1.8b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x4.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld1x4
}

declare { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld1x4.v8i8.p0i8(i8*)


define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld1x4(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v8i16_post_imm_ld1x4:
;CHECK: ld1.8h { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x4.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 32
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld1x4
}

define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld1x4(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v8i16_post_reg_ld1x4:
;CHECK: ld1.8h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x4.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld1x4
}

declare { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld1x4.v8i16.p0i16(i16*)


define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld1x4(i16* %A, i16** %ptr) {
;CHECK-LABEL: test_v4i16_post_imm_ld1x4:
;CHECK: ld1.4h { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x4.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld1x4
}

define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld1x4(i16* %A, i16** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i16_post_reg_ld1x4:
;CHECK: ld1.4h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x4.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld1x4
}

declare { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld1x4.v4i16.p0i16(i16*)


define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld1x4(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v4i32_post_imm_ld1x4:
;CHECK: ld1.4s { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x4.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 16
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld1x4
}

define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld1x4(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4i32_post_reg_ld1x4:
;CHECK: ld1.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x4.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld1x4
}

declare { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld1x4.v4i32.p0i32(i32*)


define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld1x4(i32* %A, i32** %ptr) {
;CHECK-LABEL: test_v2i32_post_imm_ld1x4:
;CHECK: ld1.2s { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x4.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld1x4
}

define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld1x4(i32* %A, i32** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i32_post_reg_ld1x4:
;CHECK: ld1.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x4.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld1x4
}

declare { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld1x4.v2i32.p0i32(i32*)


define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld1x4(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v2i64_post_imm_ld1x4:
;CHECK: ld1.2d { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x4.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 8
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld1x4
}

define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld1x4(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2i64_post_reg_ld1x4:
;CHECK: ld1.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x4.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld1x4
}

declare { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld1x4.v2i64.p0i64(i64*)


define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld1x4(i64* %A, i64** %ptr) {
;CHECK-LABEL: test_v1i64_post_imm_ld1x4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x4.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld1x4
}

define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld1x4(i64* %A, i64** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1i64_post_reg_ld1x4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x4.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld1x4
}

declare { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld1x4.v1i64.p0i64(i64*)


define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld1x4(float* %A, float** %ptr) {
;CHECK-LABEL: test_v4f32_post_imm_ld1x4:
;CHECK: ld1.4s { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x4.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 16
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld1x4
}

define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld1x4(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v4f32_post_reg_ld1x4:
;CHECK: ld1.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x4.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld1x4
}

declare { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld1x4.v4f32.p0f32(float*)


define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld1x4(float* %A, float** %ptr) {
;CHECK-LABEL: test_v2f32_post_imm_ld1x4:
;CHECK: ld1.2s { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x4.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 8
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld1x4
}

define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld1x4(float* %A, float** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f32_post_reg_ld1x4:
;CHECK: ld1.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x4.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld1x4
}

declare { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld1x4.v2f32.p0f32(float*)


define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld1x4(double* %A, double** %ptr) {
;CHECK-LABEL: test_v2f64_post_imm_ld1x4:
;CHECK: ld1.2d { v0, v1, v2, v3 }, [x0], #64
  %ld1x4 = tail call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x4.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 8
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld1x4
}

define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld1x4(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v2f64_post_reg_ld1x4:
;CHECK: ld1.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x4.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld1x4
}

declare { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld1x4.v2f64.p0f64(double*)


define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld1x4(double* %A, double** %ptr) {
;CHECK-LABEL: test_v1f64_post_imm_ld1x4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], #32
  %ld1x4 = tail call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x4.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld1x4
}

define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld1x4(double* %A, double** %ptr, i64 %inc) {
;CHECK-LABEL: test_v1f64_post_reg_ld1x4:
;CHECK: ld1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld1x4 = tail call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x4.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld1x4
}

declare { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld1x4.v1f64.p0f64(double*)


define { <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld2r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld2r:
;CHECK: ld2r.16b { v0, v1 }, [x0], #2
  %ld2 = call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

define { <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld2r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld2r:
;CHECK: ld2r.16b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

declare { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2r.v16i8.p0i8(i8*) nounwind readonly


define { <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld2r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld2r:
;CHECK: ld2r.8b { v0, v1 }, [x0], #2
  %ld2 = call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

define { <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld2r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld2r:
;CHECK: ld2r.8b { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

declare { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2r.v8i8.p0i8(i8*) nounwind readonly


define { <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld2r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld2r:
;CHECK: ld2r.8h { v0, v1 }, [x0], #4
  %ld2 = call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

define { <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld2r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld2r:
;CHECK: ld2r.8h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

declare { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2r.v8i16.p0i16(i16*) nounwind readonly


define { <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld2r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld2r:
;CHECK: ld2r.4h { v0, v1 }, [x0], #4
  %ld2 = call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

define { <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld2r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld2r:
;CHECK: ld2r.4h { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

declare { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2r.v4i16.p0i16(i16*) nounwind readonly


define { <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld2r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld2r:
;CHECK: ld2r.4s { v0, v1 }, [x0], #8
  %ld2 = call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

define { <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld2r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld2r:
;CHECK: ld2r.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

declare { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2r.v4i32.p0i32(i32*) nounwind readonly

define { <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld2r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld2r:
;CHECK: ld2r.2s { v0, v1 }, [x0], #8
  %ld2 = call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

define { <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld2r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld2r:
;CHECK: ld2r.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

declare { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2r.v2i32.p0i32(i32*) nounwind readonly


define { <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld2r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld2r:
;CHECK: ld2r.2d { v0, v1 }, [x0], #16
  %ld2 = call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

define { <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld2r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld2r:
;CHECK: ld2r.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

declare { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2r.v2i64.p0i64(i64*) nounwind readonly

define { <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld2r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld2r:
;CHECK: ld2r.1d { v0, v1 }, [x0], #16
  %ld2 = call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

define { <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld2r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld2r:
;CHECK: ld2r.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

declare { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2r.v1i64.p0i64(i64*) nounwind readonly


define { <4 x float>, <4 x float> } @test_v4f32_post_imm_ld2r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld2r:
;CHECK: ld2r.4s { v0, v1 }, [x0], #8
  %ld2 = call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 2
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

define { <4 x float>, <4 x float> } @test_v4f32_post_reg_ld2r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld2r:
;CHECK: ld2r.4s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

declare { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2r.v4f32.p0f32(float*) nounwind readonly

define { <2 x float>, <2 x float> } @test_v2f32_post_imm_ld2r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld2r:
;CHECK: ld2r.2s { v0, v1 }, [x0], #8
  %ld2 = call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 2
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

define { <2 x float>, <2 x float> } @test_v2f32_post_reg_ld2r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld2r:
;CHECK: ld2r.2s { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

declare { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2r.v2f32.p0f32(float*) nounwind readonly


define { <2 x double>, <2 x double> } @test_v2f64_post_imm_ld2r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld2r:
;CHECK: ld2r.2d { v0, v1 }, [x0], #16
  %ld2 = call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

define { <2 x double>, <2 x double> } @test_v2f64_post_reg_ld2r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld2r:
;CHECK: ld2r.2d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

declare { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2r.v2f64.p0f64(double*) nounwind readonly

define { <1 x double>, <1 x double> } @test_v1f64_post_imm_ld2r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld2r:
;CHECK: ld2r.1d { v0, v1 }, [x0], #16
  %ld2 = call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

define { <1 x double>, <1 x double> } @test_v1f64_post_reg_ld2r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld2r:
;CHECK: ld2r.1d { v0, v1 }, [x0], x{{[0-9]+}}
  %ld2 = call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

declare { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2r.v1f64.p0f64(double*) nounwind readonly


define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld3r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld3r:
;CHECK: ld3r.16b { v0, v1, v2 }, [x0], #3
  %ld3 = call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld3r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld3r:
;CHECK: ld3r.16b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

declare { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3r.v16i8.p0i8(i8*) nounwind readonly


define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld3r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld3r:
;CHECK: ld3r.8b { v0, v1, v2 }, [x0], #3
  %ld3 = call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld3r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld3r:
;CHECK: ld3r.8b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

declare { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3r.v8i8.p0i8(i8*) nounwind readonly


define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld3r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld3r:
;CHECK: ld3r.8h { v0, v1, v2 }, [x0], #6
  %ld3 = call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld3r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld3r:
;CHECK: ld3r.8h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

declare { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3r.v8i16.p0i16(i16*) nounwind readonly


define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld3r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld3r:
;CHECK: ld3r.4h { v0, v1, v2 }, [x0], #6
  %ld3 = call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld3r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld3r:
;CHECK: ld3r.4h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

declare { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3r.v4i16.p0i16(i16*) nounwind readonly


define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld3r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld3r:
;CHECK: ld3r.4s { v0, v1, v2 }, [x0], #12
  %ld3 = call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld3r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld3r:
;CHECK: ld3r.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

declare { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3r.v4i32.p0i32(i32*) nounwind readonly

define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld3r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld3r:
;CHECK: ld3r.2s { v0, v1, v2 }, [x0], #12
  %ld3 = call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld3r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld3r:
;CHECK: ld3r.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

declare { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3r.v2i32.p0i32(i32*) nounwind readonly


define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld3r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld3r:
;CHECK: ld3r.2d { v0, v1, v2 }, [x0], #24
  %ld3 = call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld3r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld3r:
;CHECK: ld3r.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

declare { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3r.v2i64.p0i64(i64*) nounwind readonly

define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld3r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld3r:
;CHECK: ld3r.1d { v0, v1, v2 }, [x0], #24
  %ld3 = call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld3r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld3r:
;CHECK: ld3r.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

declare { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3r.v1i64.p0i64(i64*) nounwind readonly


define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld3r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld3r:
;CHECK: ld3r.4s { v0, v1, v2 }, [x0], #12
  %ld3 = call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 3
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld3r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld3r:
;CHECK: ld3r.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

declare { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3r.v4f32.p0f32(float*) nounwind readonly

define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld3r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld3r:
;CHECK: ld3r.2s { v0, v1, v2 }, [x0], #12
  %ld3 = call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 3
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld3r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld3r:
;CHECK: ld3r.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

declare { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3r.v2f32.p0f32(float*) nounwind readonly


define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld3r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld3r:
;CHECK: ld3r.2d { v0, v1, v2 }, [x0], #24
  %ld3 = call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld3r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld3r:
;CHECK: ld3r.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

declare { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3r.v2f64.p0f64(double*) nounwind readonly

define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld3r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld3r:
;CHECK: ld3r.1d { v0, v1, v2 }, [x0], #24
  %ld3 = call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld3r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld3r:
;CHECK: ld3r.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  %ld3 = call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

declare { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3r.v1f64.p0f64(double*) nounwind readonly


define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld4r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld4r:
;CHECK: ld4r.16b { v0, v1, v2, v3 }, [x0], #4
  %ld4 = call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld4r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld4r:
;CHECK: ld4r.16b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4r.v16i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

declare { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4r.v16i8.p0i8(i8*) nounwind readonly


define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld4r(i8* %A, i8** %ptr) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld4r:
;CHECK: ld4r.8b { v0, v1, v2, v3 }, [x0], #4
  %ld4 = call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld4r(i8* %A, i8** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld4r:
;CHECK: ld4r.8b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4r.v8i8.p0i8(i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

declare { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4r.v8i8.p0i8(i8*) nounwind readonly


define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld4r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld4r:
;CHECK: ld4r.8h { v0, v1, v2, v3 }, [x0], #8
  %ld4 = call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld4r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld4r:
;CHECK: ld4r.8h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4r.v8i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

declare { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4r.v8i16.p0i16(i16*) nounwind readonly


define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld4r(i16* %A, i16** %ptr) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld4r:
;CHECK: ld4r.4h { v0, v1, v2, v3 }, [x0], #8
  %ld4 = call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld4r(i16* %A, i16** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld4r:
;CHECK: ld4r.4h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4r.v4i16.p0i16(i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

declare { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4r.v4i16.p0i16(i16*) nounwind readonly


define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld4r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld4r:
;CHECK: ld4r.4s { v0, v1, v2, v3 }, [x0], #16
  %ld4 = call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld4r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld4r:
;CHECK: ld4r.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4r.v4i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

declare { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4r.v4i32.p0i32(i32*) nounwind readonly

define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld4r(i32* %A, i32** %ptr) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld4r:
;CHECK: ld4r.2s { v0, v1, v2, v3 }, [x0], #16
  %ld4 = call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld4r(i32* %A, i32** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld4r:
;CHECK: ld4r.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4r.v2i32.p0i32(i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

declare { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4r.v2i32.p0i32(i32*) nounwind readonly


define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld4r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld4r:
;CHECK: ld4r.2d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld4r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld4r:
;CHECK: ld4r.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4r.v2i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

declare { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4r.v2i64.p0i64(i64*) nounwind readonly

define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld4r(i64* %A, i64** %ptr) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld4r:
;CHECK: ld4r.1d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld4r(i64* %A, i64** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld4r:
;CHECK: ld4r.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4r.v1i64.p0i64(i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

declare { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4r.v1i64.p0i64(i64*) nounwind readonly


define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld4r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld4r:
;CHECK: ld4r.4s { v0, v1, v2, v3 }, [x0], #16
  %ld4 = call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld4r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld4r:
;CHECK: ld4r.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4r.v4f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

declare { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4r.v4f32.p0f32(float*) nounwind readonly

define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld4r(float* %A, float** %ptr) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld4r:
;CHECK: ld4r.2s { v0, v1, v2, v3 }, [x0], #16
  %ld4 = call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld4r(float* %A, float** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld4r:
;CHECK: ld4r.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4r.v2f32.p0f32(float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

declare { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4r.v2f32.p0f32(float*) nounwind readonly


define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld4r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld4r:
;CHECK: ld4r.2d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld4r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld4r:
;CHECK: ld4r.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4r.v2f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

declare { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4r.v2f64.p0f64(double*) nounwind readonly

define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld4r(double* %A, double** %ptr) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld4r:
;CHECK: ld4r.1d { v0, v1, v2, v3 }, [x0], #32
  %ld4 = call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld4r(double* %A, double** %ptr, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld4r:
;CHECK: ld4r.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  %ld4 = call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4r.v1f64.p0f64(double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

declare { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4r.v1f64.p0f64(double*) nounwind readonly


define { <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld2lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld2lane:
;CHECK: ld2.b { v0, v1 }[0], [x0], #2
  %ld2 = call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

define { <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld2lane(i8* %A, i8** %ptr, i64 %inc, <16 x i8> %B, <16 x i8> %C) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld2lane:
;CHECK: ld2.b { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8> } %ld2
}

declare { <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld2lane.v16i8.p0i8(<16 x i8>, <16 x i8>, i64, i8*) nounwind readonly


define { <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld2lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld2lane:
;CHECK: ld2.b { v0, v1 }[0], [x0], #2
  %ld2 = call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

define { <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld2lane(i8* %A, i8** %ptr, i64 %inc, <8 x i8> %B, <8 x i8> %C) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld2lane:
;CHECK: ld2.b { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8> } %ld2
}

declare { <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld2lane.v8i8.p0i8(<8 x i8>, <8 x i8>, i64, i8*) nounwind readonly


define { <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld2lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld2lane:
;CHECK: ld2.h { v0, v1 }[0], [x0], #4
  %ld2 = call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

define { <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld2lane(i16* %A, i16** %ptr, i64 %inc, <8 x i16> %B, <8 x i16> %C) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld2lane:
;CHECK: ld2.h { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16> } %ld2
}

declare { <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld2lane.v8i16.p0i16(<8 x i16>, <8 x i16>, i64, i16*) nounwind readonly


define { <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld2lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld2lane:
;CHECK: ld2.h { v0, v1 }[0], [x0], #4
  %ld2 = call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

define { <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld2lane(i16* %A, i16** %ptr, i64 %inc, <4 x i16> %B, <4 x i16> %C) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld2lane:
;CHECK: ld2.h { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16> } %ld2
}

declare { <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld2lane.v4i16.p0i16(<4 x i16>, <4 x i16>, i64, i16*) nounwind readonly


define { <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld2lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], #8
  %ld2 = call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

define { <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld2lane(i32* %A, i32** %ptr, i64 %inc, <4 x i32> %B, <4 x i32> %C) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32> } %ld2
}

declare { <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld2lane.v4i32.p0i32(<4 x i32>, <4 x i32>, i64, i32*) nounwind readonly


define { <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld2lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], #8
  %ld2 = call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

define { <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld2lane(i32* %A, i32** %ptr, i64 %inc, <2 x i32> %B, <2 x i32> %C) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32> } %ld2
}

declare { <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld2lane.v2i32.p0i32(<2 x i32>, <2 x i32>, i64, i32*) nounwind readonly


define { <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld2lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], #16
  %ld2 = call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

define { <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld2lane(i64* %A, i64** %ptr, i64 %inc, <2 x i64> %B, <2 x i64> %C) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64> } %ld2
}

declare { <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld2lane.v2i64.p0i64(<2 x i64>, <2 x i64>, i64, i64*) nounwind readonly


define { <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld2lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], #16
  %ld2 = call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 2
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

define { <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld2lane(i64* %A, i64** %ptr, i64 %inc, <1 x i64> %B, <1 x i64> %C) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64> } %ld2
}

declare { <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld2lane.v1i64.p0i64(<1 x i64>, <1 x i64>, i64, i64*) nounwind readonly


define { <4 x float>, <4 x float> } @test_v4f32_post_imm_ld2lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], #8
  %ld2 = call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 2
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

define { <4 x float>, <4 x float> } @test_v4f32_post_reg_ld2lane(float* %A, float** %ptr, i64 %inc, <4 x float> %B, <4 x float> %C) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float> } %ld2
}

declare { <4 x float>, <4 x float> } @llvm.arm64.neon.ld2lane.v4f32.p0f32(<4 x float>, <4 x float>, i64, float*) nounwind readonly


define { <2 x float>, <2 x float> } @test_v2f32_post_imm_ld2lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], #8
  %ld2 = call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 2
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

define { <2 x float>, <2 x float> } @test_v2f32_post_reg_ld2lane(float* %A, float** %ptr, i64 %inc, <2 x float> %B, <2 x float> %C) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld2lane:
;CHECK: ld2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float> } %ld2
}

declare { <2 x float>, <2 x float> } @llvm.arm64.neon.ld2lane.v2f32.p0f32(<2 x float>, <2 x float>, i64, float*) nounwind readonly


define { <2 x double>, <2 x double> } @test_v2f64_post_imm_ld2lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], #16
  %ld2 = call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

define { <2 x double>, <2 x double> } @test_v2f64_post_reg_ld2lane(double* %A, double** %ptr, i64 %inc, <2 x double> %B, <2 x double> %C) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double> } %ld2
}

declare { <2 x double>, <2 x double> } @llvm.arm64.neon.ld2lane.v2f64.p0f64(<2 x double>, <2 x double>, i64, double*) nounwind readonly


define { <1 x double>, <1 x double> } @test_v1f64_post_imm_ld2lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], #16
  %ld2 = call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 2
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

define { <1 x double>, <1 x double> } @test_v1f64_post_reg_ld2lane(double* %A, double** %ptr, i64 %inc, <1 x double> %B, <1 x double> %C) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld2lane:
;CHECK: ld2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  %ld2 = call { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double> } %ld2
}

declare { <1 x double>, <1 x double> } @llvm.arm64.neon.ld2lane.v1f64.p0f64(<1 x double>, <1 x double>, i64, double*) nounwind readonly


define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld3lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld3lane:
;CHECK: ld3.b { v0, v1, v2 }[0], [x0], #3
  %ld3 = call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

define { <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld3lane(i8* %A, i8** %ptr, i64 %inc, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld3lane:
;CHECK: ld3.b { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8> } %ld3
}

declare { <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld3lane.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, i64, i8*) nounwind readonly


define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld3lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld3lane:
;CHECK: ld3.b { v0, v1, v2 }[0], [x0], #3
  %ld3 = call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

define { <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld3lane(i8* %A, i8** %ptr, i64 %inc, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld3lane:
;CHECK: ld3.b { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8> } %ld3
}

declare { <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld3lane.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, i64, i8*) nounwind readonly


define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld3lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld3lane:
;CHECK: ld3.h { v0, v1, v2 }[0], [x0], #6
  %ld3 = call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

define { <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld3lane(i16* %A, i16** %ptr, i64 %inc, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld3lane:
;CHECK: ld3.h { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16> } %ld3
}

declare { <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld3lane.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, i64, i16*) nounwind readonly


define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld3lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld3lane:
;CHECK: ld3.h { v0, v1, v2 }[0], [x0], #6
  %ld3 = call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

define { <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld3lane(i16* %A, i16** %ptr, i64 %inc, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld3lane:
;CHECK: ld3.h { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16> } %ld3
}

declare { <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld3lane.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, i64, i16*) nounwind readonly


define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld3lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], #12
  %ld3 = call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

define { <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld3lane(i32* %A, i32** %ptr, i64 %inc, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32> } %ld3
}

declare { <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld3lane.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, i64, i32*) nounwind readonly


define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld3lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], #12
  %ld3 = call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

define { <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld3lane(i32* %A, i32** %ptr, i64 %inc, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32> } %ld3
}

declare { <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld3lane.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, i64, i32*) nounwind readonly


define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld3lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], #24
  %ld3 = call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

define { <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld3lane(i64* %A, i64** %ptr, i64 %inc, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64> } %ld3
}

declare { <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld3lane.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, i64, i64*) nounwind readonly


define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld3lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], #24
  %ld3 = call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 3
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

define { <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld3lane(i64* %A, i64** %ptr, i64 %inc, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64> } %ld3
}

declare { <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld3lane.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, i64, i64*) nounwind readonly


define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld3lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], #12
  %ld3 = call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 3
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

define { <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld3lane(float* %A, float** %ptr, i64 %inc, <4 x float> %B, <4 x float> %C, <4 x float> %D) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float> } %ld3
}

declare { <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld3lane.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, i64, float*) nounwind readonly


define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld3lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], #12
  %ld3 = call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 3
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

define { <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld3lane(float* %A, float** %ptr, i64 %inc, <2 x float> %B, <2 x float> %C, <2 x float> %D) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld3lane:
;CHECK: ld3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float> } %ld3
}

declare { <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld3lane.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, i64, float*) nounwind readonly


define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld3lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], #24
  %ld3 = call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

define { <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld3lane(double* %A, double** %ptr, i64 %inc, <2 x double> %B, <2 x double> %C, <2 x double> %D) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double> } %ld3
}

declare { <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld3lane.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, i64, double*) nounwind readonly


define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld3lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], #24
  %ld3 = call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 3
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

define { <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld3lane(double* %A, double** %ptr, i64 %inc, <1 x double> %B, <1 x double> %C, <1 x double> %D) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld3lane:
;CHECK: ld3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  %ld3 = call { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double> } %ld3
}

declare { <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld3lane.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, i64, double*) nounwind readonly


define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_imm_ld4lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_ld4lane:
;CHECK: ld4.b { v0, v1, v2, v3 }[0], [x0], #4
  %ld4 = call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

define { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @test_v16i8_post_reg_ld4lane(i8* %A, i8** %ptr, i64 %inc, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_ld4lane:
;CHECK: ld4.b { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } %ld4
}

declare { <16 x i8>, <16 x i8>, <16 x i8>, <16 x i8> } @llvm.arm64.neon.ld4lane.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, <16 x i8>, i64, i8*) nounwind readonly


define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_imm_ld4lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_ld4lane:
;CHECK: ld4.b { v0, v1, v2, v3 }[0], [x0], #4
  %ld4 = call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

define { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @test_v8i8_post_reg_ld4lane(i8* %A, i8** %ptr, i64 %inc, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_ld4lane:
;CHECK: ld4.b { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  store i8* %tmp, i8** %ptr
  ret { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } %ld4
}

declare { <8 x i8>, <8 x i8>, <8 x i8>, <8 x i8> } @llvm.arm64.neon.ld4lane.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, <8 x i8>, i64, i8*) nounwind readonly


define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_imm_ld4lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_ld4lane:
;CHECK: ld4.h { v0, v1, v2, v3 }[0], [x0], #8
  %ld4 = call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

define { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @test_v8i16_post_reg_ld4lane(i16* %A, i16** %ptr, i64 %inc, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_ld4lane:
;CHECK: ld4.h { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } %ld4
}

declare { <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16> } @llvm.arm64.neon.ld4lane.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, i64, i16*) nounwind readonly


define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_imm_ld4lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_ld4lane:
;CHECK: ld4.h { v0, v1, v2, v3 }[0], [x0], #8
  %ld4 = call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

define { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @test_v4i16_post_reg_ld4lane(i16* %A, i16** %ptr, i64 %inc, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_ld4lane:
;CHECK: ld4.h { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  store i16* %tmp, i16** %ptr
  ret { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } %ld4
}

declare { <4 x i16>, <4 x i16>, <4 x i16>, <4 x i16> } @llvm.arm64.neon.ld4lane.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, <4 x i16>, i64, i16*) nounwind readonly


define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_imm_ld4lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], #16
  %ld4 = call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

define { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @test_v4i32_post_reg_ld4lane(i32* %A, i32** %ptr, i64 %inc, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } %ld4
}

declare { <4 x i32>, <4 x i32>, <4 x i32>, <4 x i32> } @llvm.arm64.neon.ld4lane.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, <4 x i32>, i64, i32*) nounwind readonly


define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_imm_ld4lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], #16
  %ld4 = call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

define { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @test_v2i32_post_reg_ld4lane(i32* %A, i32** %ptr, i64 %inc, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  store i32* %tmp, i32** %ptr
  ret { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } %ld4
}

declare { <2 x i32>, <2 x i32>, <2 x i32>, <2 x i32> } @llvm.arm64.neon.ld4lane.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, <2 x i32>, i64, i32*) nounwind readonly


define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_imm_ld4lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], #32
  %ld4 = call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

define { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @test_v2i64_post_reg_ld4lane(i64* %A, i64** %ptr, i64 %inc, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %ld4
}

declare { <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.arm64.neon.ld4lane.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, i64, i64*) nounwind readonly


define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_imm_ld4lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], #32
  %ld4 = call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i32 4
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

define { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @test_v1i64_post_reg_ld4lane(i64* %A, i64** %ptr, i64 %inc, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  store i64* %tmp, i64** %ptr
  ret { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } %ld4
}

declare { <1 x i64>, <1 x i64>, <1 x i64>, <1 x i64> } @llvm.arm64.neon.ld4lane.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, <1 x i64>, i64, i64*) nounwind readonly


define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_imm_ld4lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], #16
  %ld4 = call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

define { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @test_v4f32_post_reg_ld4lane(float* %A, float** %ptr, i64 %inc, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <4 x float>, <4 x float>, <4 x float>, <4 x float> } %ld4
}

declare { <4 x float>, <4 x float>, <4 x float>, <4 x float> } @llvm.arm64.neon.ld4lane.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, <4 x float>, i64, float*) nounwind readonly


define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_imm_ld4lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], #16
  %ld4 = call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 4
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

define { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @test_v2f32_post_reg_ld4lane(float* %A, float** %ptr, i64 %inc, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_ld4lane:
;CHECK: ld4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  store float* %tmp, float** %ptr
  ret { <2 x float>, <2 x float>, <2 x float>, <2 x float> } %ld4
}

declare { <2 x float>, <2 x float>, <2 x float>, <2 x float> } @llvm.arm64.neon.ld4lane.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, <2 x float>, i64, float*) nounwind readonly


define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_imm_ld4lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], #32
  %ld4 = call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

define { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @test_v2f64_post_reg_ld4lane(double* %A, double** %ptr, i64 %inc, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <2 x double>, <2 x double>, <2 x double>, <2 x double> } %ld4
}

declare { <2 x double>, <2 x double>, <2 x double>, <2 x double> } @llvm.arm64.neon.ld4lane.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, <2 x double>, i64, double*) nounwind readonly


define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_imm_ld4lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], #32
  %ld4 = call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i32 4
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

define { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @test_v1f64_post_reg_ld4lane(double* %A, double** %ptr, i64 %inc, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_ld4lane:
;CHECK: ld4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  %ld4 = call { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  store double* %tmp, double** %ptr
  ret { <1 x double>, <1 x double>, <1 x double>, <1 x double> } %ld4
}

declare { <1 x double>, <1 x double>, <1 x double>, <1 x double> } @llvm.arm64.neon.ld4lane.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, <1 x double>, i64, double*) nounwind readonly


define i8* @test_v16i8_post_imm_st2(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st2:
;CHECK: st2.16b { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st2(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st2:
;CHECK: st2.16b { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st2.v16i8.p0i8(<16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st2(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st2:
;CHECK: st2.8b { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i32 16
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st2(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st2:
;CHECK: st2.8b { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st2.v8i8.p0i8(<8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st2(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st2:
;CHECK: st2.8h { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st2(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st2:
;CHECK: st2.8h { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st2.v8i16.p0i16(<8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st2(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st2:
;CHECK: st2.4h { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i32 8
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st2(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st2:
;CHECK: st2.4h { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st2.v4i16.p0i16(<4 x i16>, <4 x i16>, i16*)


define i32* @test_v4i32_post_imm_st2(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st2:
;CHECK: st2.4s { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st2(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st2:
;CHECK: st2.4s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st2.v4i32.p0i32(<4 x i32>, <4 x i32>, i32*)


define i32* @test_v2i32_post_imm_st2(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st2:
;CHECK: st2.2s { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st2(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st2:
;CHECK: st2.2s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st2.v2i32.p0i32(<2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st2(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st2:
;CHECK: st2.2d { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st2(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st2:
;CHECK: st2.2d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st2.v2i64.p0i64(<2 x i64>, <2 x i64>, i64*)


define i64* @test_v1i64_post_imm_st2(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st2:
;CHECK: st1.1d { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 2
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st2(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st2:
;CHECK: st1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st2.v1i64.p0i64(<1 x i64>, <1 x i64>, i64*)


define float* @test_v4f32_post_imm_st2(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st2:
;CHECK: st2.4s { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v4f32.p0f32(<4 x float> %B, <4 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i32 8
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st2(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st2:
;CHECK: st2.4s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v4f32.p0f32(<4 x float> %B, <4 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st2.v4f32.p0f32(<4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st2(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st2:
;CHECK: st2.2s { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v2f32.p0f32(<2 x float> %B, <2 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i32 4
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st2(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st2:
;CHECK: st2.2s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v2f32.p0f32(<2 x float> %B, <2 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st2.v2f32.p0f32(<2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st2(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st2:
;CHECK: st2.2d { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st2.v2f64.p0f64(<2 x double> %B, <2 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st2(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st2:
;CHECK: st2.2d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v2f64.p0f64(<2 x double> %B, <2 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st2.v2f64.p0f64(<2 x double>, <2 x double>, double*)


define double* @test_v1f64_post_imm_st2(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st2:
;CHECK: st1.1d { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st2.v1f64.p0f64(<1 x double> %B, <1 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 2
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st2(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st2:
;CHECK: st1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2.v1f64.p0f64(<1 x double> %B, <1 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st2.v1f64.p0f64(<1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st3(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st3:
;CHECK: st3.16b { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i32 48
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st3(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st3:
;CHECK: st3.16b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st3.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st3(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st3:
;CHECK: st3.8b { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i32 24
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st3(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st3:
;CHECK: st3.8b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st3.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st3(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st3:
;CHECK: st3.8h { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i32 24
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st3(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st3:
;CHECK: st3.8h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st3.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st3(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st3:
;CHECK: st3.4h { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i32 12
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st3(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st3:
;CHECK: st3.4h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st3.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, i16*)


define i32* @test_v4i32_post_imm_st3(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st3:
;CHECK: st3.4s { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i32 12
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st3(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st3:
;CHECK: st3.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st3.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, i32*)


define i32* @test_v2i32_post_imm_st3(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st3:
;CHECK: st3.2s { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i32 6
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st3(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st3:
;CHECK: st3.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st3.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st3(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st3:
;CHECK: st3.2d { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 6
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st3(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st3:
;CHECK: st3.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st3.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, i64*)


define i64* @test_v1i64_post_imm_st3(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 3
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st3(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st3.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, i64*)


define float* @test_v4f32_post_imm_st3(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st3:
;CHECK: st3.4s { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i32 12
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st3(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st3:
;CHECK: st3.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st3.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st3(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st3:
;CHECK: st3.2s { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i32 6
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st3(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st3:
;CHECK: st3.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st3.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st3(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st3:
;CHECK: st3.2d { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st3.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 6
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st3(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st3:
;CHECK: st3.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st3.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, double*)


define double* @test_v1f64_post_imm_st3(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st3.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 3
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st3(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st3.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st4(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st4:
;CHECK: st4.16b { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i32 64
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st4(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st4:
;CHECK: st4.16b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st4.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st4(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st4:
;CHECK: st4.8b { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st4(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st4:
;CHECK: st4.8b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st4.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st4(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st4:
;CHECK: st4.8h { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i32 32
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st4(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st4:
;CHECK: st4.8h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st4.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st4(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st4:
;CHECK: st4.4h { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st4(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st4:
;CHECK: st4.4h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st4.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>,<4 x i16>,  i16*)


define i32* @test_v4i32_post_imm_st4(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st4:
;CHECK: st4.4s { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i32 16
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st4(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st4:
;CHECK: st4.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st4.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>,<4 x i32>,  i32*)


define i32* @test_v2i32_post_imm_st4(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st4:
;CHECK: st4.2s { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st4(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st4:
;CHECK: st4.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st4.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st4(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st4:
;CHECK: st4.2d { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 8
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st4(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st4:
;CHECK: st4.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st4.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>,<2 x i64>,  i64*)


define i64* @test_v1i64_post_imm_st4(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st4(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st4.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>,<1 x i64>,  i64*)


define float* @test_v4f32_post_imm_st4(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st4:
;CHECK: st4.4s { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i32 16
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st4(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st4:
;CHECK: st4.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st4.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st4(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st4:
;CHECK: st4.2s { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i32 8
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st4(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st4:
;CHECK: st4.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st4.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st4(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st4:
;CHECK: st4.2d { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st4.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 8
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st4(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st4:
;CHECK: st4.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st4.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>,<2 x double>,  double*)


define double* @test_v1f64_post_imm_st4(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st4.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st4(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st4.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st1x2(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st1x2:
;CHECK: st1.16b { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st1x2(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st1x2:
;CHECK: st1.16b { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x2.v16i8.p0i8(<16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st1x2(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st1x2:
;CHECK: st1.8b { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i32 16
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st1x2(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st1x2:
;CHECK: st1.8b { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x2.v8i8.p0i8(<8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st1x2(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st1x2:
;CHECK: st1.8h { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st1x2(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st1x2:
;CHECK: st1.8h { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x2.v8i16.p0i16(<8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st1x2(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st1x2:
;CHECK: st1.4h { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i32 8
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st1x2(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st1x2:
;CHECK: st1.4h { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x2.v4i16.p0i16(<4 x i16>, <4 x i16>, i16*)


define i32* @test_v4i32_post_imm_st1x2(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st1x2:
;CHECK: st1.4s { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st1x2(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st1x2:
;CHECK: st1.4s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x2.v4i32.p0i32(<4 x i32>, <4 x i32>, i32*)


define i32* @test_v2i32_post_imm_st1x2(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st1x2:
;CHECK: st1.2s { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st1x2(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st1x2:
;CHECK: st1.2s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x2.v2i32.p0i32(<2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st1x2(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st1x2:
;CHECK: st1.2d { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st1x2(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st1x2:
;CHECK: st1.2d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x2.v2i64.p0i64(<2 x i64>, <2 x i64>, i64*)


define i64* @test_v1i64_post_imm_st1x2(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st1x2:
;CHECK: st1.1d { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 2
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st1x2(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st1x2:
;CHECK: st1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x2.v1i64.p0i64(<1 x i64>, <1 x i64>, i64*)


define float* @test_v4f32_post_imm_st1x2(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st1x2:
;CHECK: st1.4s { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v4f32.p0f32(<4 x float> %B, <4 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i32 8
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st1x2(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st1x2:
;CHECK: st1.4s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v4f32.p0f32(<4 x float> %B, <4 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x2.v4f32.p0f32(<4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st1x2(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st1x2:
;CHECK: st1.2s { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v2f32.p0f32(<2 x float> %B, <2 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i32 4
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st1x2(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st1x2:
;CHECK: st1.2s { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v2f32.p0f32(<2 x float> %B, <2 x float> %C, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x2.v2f32.p0f32(<2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st1x2(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st1x2:
;CHECK: st1.2d { v0, v1 }, [x0], #32
  call void @llvm.arm64.neon.st1x2.v2f64.p0f64(<2 x double> %B, <2 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st1x2(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st1x2:
;CHECK: st1.2d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v2f64.p0f64(<2 x double> %B, <2 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x2.v2f64.p0f64(<2 x double>, <2 x double>, double*)


define double* @test_v1f64_post_imm_st1x2(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st1x2:
;CHECK: st1.1d { v0, v1 }, [x0], #16
  call void @llvm.arm64.neon.st1x2.v1f64.p0f64(<1 x double> %B, <1 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 2
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st1x2(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st1x2:
;CHECK: st1.1d { v0, v1 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x2.v1f64.p0f64(<1 x double> %B, <1 x double> %C, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x2.v1f64.p0f64(<1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st1x3(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st1x3:
;CHECK: st1.16b { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i32 48
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st1x3(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st1x3:
;CHECK: st1.16b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x3.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st1x3(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st1x3:
;CHECK: st1.8b { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i32 24
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st1x3(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st1x3:
;CHECK: st1.8b { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x3.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st1x3(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st1x3:
;CHECK: st1.8h { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i32 24
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st1x3(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st1x3:
;CHECK: st1.8h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x3.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st1x3(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st1x3:
;CHECK: st1.4h { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i32 12
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st1x3(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st1x3:
;CHECK: st1.4h { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x3.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, i16*)


define i32* @test_v4i32_post_imm_st1x3(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st1x3:
;CHECK: st1.4s { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i32 12
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st1x3(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st1x3:
;CHECK: st1.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x3.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, i32*)


define i32* @test_v2i32_post_imm_st1x3(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st1x3:
;CHECK: st1.2s { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i32 6
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st1x3(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st1x3:
;CHECK: st1.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x3.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st1x3(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st1x3:
;CHECK: st1.2d { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 6
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st1x3(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st1x3:
;CHECK: st1.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x3.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, i64*)


define i64* @test_v1i64_post_imm_st1x3(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st1x3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 3
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st1x3(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st1x3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x3.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, i64*)


define float* @test_v4f32_post_imm_st1x3(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st1x3:
;CHECK: st1.4s { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i32 12
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st1x3(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st1x3:
;CHECK: st1.4s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x3.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st1x3(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st1x3:
;CHECK: st1.2s { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i32 6
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st1x3(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st1x3:
;CHECK: st1.2s { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x3.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st1x3(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st1x3:
;CHECK: st1.2d { v0, v1, v2 }, [x0], #48
  call void @llvm.arm64.neon.st1x3.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 6
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st1x3(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st1x3:
;CHECK: st1.2d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x3.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, double*)


define double* @test_v1f64_post_imm_st1x3(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st1x3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], #24
  call void @llvm.arm64.neon.st1x3.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 3
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st1x3(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st1x3:
;CHECK: st1.1d { v0, v1, v2 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x3.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x3.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st1x4(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st1x4:
;CHECK: st1.16b { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i32 64
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st1x4(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st1x4:
;CHECK: st1.16b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x4.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, <16 x i8>, i8*)


define i8* @test_v8i8_post_imm_st1x4(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st1x4:
;CHECK: st1.8b { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i32 32
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st1x4(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st1x4:
;CHECK: st1.8b { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st1x4.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, <8 x i8>, i8*)


define i16* @test_v8i16_post_imm_st1x4(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st1x4:
;CHECK: st1.8h { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i32 32
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st1x4(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st1x4:
;CHECK: st1.8h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x4.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, i16*)


define i16* @test_v4i16_post_imm_st1x4(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st1x4:
;CHECK: st1.4h { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i32 16
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st1x4(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st1x4:
;CHECK: st1.4h { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st1x4.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>,<4 x i16>,  i16*)


define i32* @test_v4i32_post_imm_st1x4(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st1x4:
;CHECK: st1.4s { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i32 16
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st1x4(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st1x4:
;CHECK: st1.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x4.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>,<4 x i32>,  i32*)


define i32* @test_v2i32_post_imm_st1x4(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st1x4:
;CHECK: st1.2s { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i32 8
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st1x4(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st1x4:
;CHECK: st1.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st1x4.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, <2 x i32>, i32*)


define i64* @test_v2i64_post_imm_st1x4(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st1x4:
;CHECK: st1.2d { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 8
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st1x4(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st1x4:
;CHECK: st1.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x4.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>,<2 x i64>,  i64*)


define i64* @test_v1i64_post_imm_st1x4(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st1x4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st1x4(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st1x4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st1x4.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>,<1 x i64>,  i64*)


define float* @test_v4f32_post_imm_st1x4(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st1x4:
;CHECK: st1.4s { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i32 16
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st1x4(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st1x4:
;CHECK: st1.4s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x4.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, <4 x float>, float*)


define float* @test_v2f32_post_imm_st1x4(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st1x4:
;CHECK: st1.2s { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i32 8
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st1x4(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st1x4:
;CHECK: st1.2s { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st1x4.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, <2 x float>, float*)


define double* @test_v2f64_post_imm_st1x4(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st1x4:
;CHECK: st1.2d { v0, v1, v2, v3 }, [x0], #64
  call void @llvm.arm64.neon.st1x4.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 8
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st1x4(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st1x4:
;CHECK: st1.2d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x4.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>,<2 x double>,  double*)


define double* @test_v1f64_post_imm_st1x4(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st1x4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], #32
  call void @llvm.arm64.neon.st1x4.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st1x4(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st1x4:
;CHECK: st1.1d { v0, v1, v2, v3 }, [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st1x4.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st1x4.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, <1 x double>, double*)


define i8* @test_v16i8_post_imm_st2lanelane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C) {
  call void @llvm.arm64.neon.st2lanelane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i64 1, i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st2lanelane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, i64 %inc) {
  call void @llvm.arm64.neon.st2lanelane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i64 1, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st2lanelane.v16i8.p0i8(<16 x i8>, <16 x i8>, i64, i64, i8*) nounwind readnone


define i8* @test_v16i8_post_imm_st2lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st2lane:
;CHECK: st2.b { v0, v1 }[0], [x0], #2
  call void @llvm.arm64.neon.st2lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st2lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st2lane:
;CHECK: st2.b { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st2lane.v16i8.p0i8(<16 x i8>, <16 x i8>, i64, i8*)


define i8* @test_v8i8_post_imm_st2lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st2lane:
;CHECK: st2.b { v0, v1 }[0], [x0], #2
  call void @llvm.arm64.neon.st2lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 2
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st2lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st2lane:
;CHECK: st2.b { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st2lane.v8i8.p0i8(<8 x i8>, <8 x i8>, i64, i8*)


define i16* @test_v8i16_post_imm_st2lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st2lane:
;CHECK: st2.h { v0, v1 }[0], [x0], #4
  call void @llvm.arm64.neon.st2lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st2lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st2lane:
;CHECK: st2.h { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st2lane.v8i16.p0i16(<8 x i16>, <8 x i16>, i64, i16*)


define i16* @test_v4i16_post_imm_st2lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st2lane:
;CHECK: st2.h { v0, v1 }[0], [x0], #4
  call void @llvm.arm64.neon.st2lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 2
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st2lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st2lane:
;CHECK: st2.h { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st2lane.v4i16.p0i16(<4 x i16>, <4 x i16>, i64, i16*)


define i32* @test_v4i32_post_imm_st2lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], #8
  call void @llvm.arm64.neon.st2lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st2lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st2lane.v4i32.p0i32(<4 x i32>, <4 x i32>, i64, i32*)


define i32* @test_v2i32_post_imm_st2lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], #8
  call void @llvm.arm64.neon.st2lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 2
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st2lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st2lane.v2i32.p0i32(<2 x i32>, <2 x i32>, i64, i32*)


define i64* @test_v2i64_post_imm_st2lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], #16
  call void @llvm.arm64.neon.st2lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 2
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st2lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st2lane.v2i64.p0i64(<2 x i64>, <2 x i64>, i64, i64*)


define i64* @test_v1i64_post_imm_st2lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], #16
  call void @llvm.arm64.neon.st2lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 2
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st2lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st2lane.v1i64.p0i64(<1 x i64>, <1 x i64>, i64, i64*)


define float* @test_v4f32_post_imm_st2lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], #8
  call void @llvm.arm64.neon.st2lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 2
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st2lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st2lane.v4f32.p0f32(<4 x float>, <4 x float>, i64, float*)


define float* @test_v2f32_post_imm_st2lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], #8
  call void @llvm.arm64.neon.st2lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 2
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st2lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st2lane:
;CHECK: st2.s { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st2lane.v2f32.p0f32(<2 x float>, <2 x float>, i64, float*)


define double* @test_v2f64_post_imm_st2lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], #16
  call void @llvm.arm64.neon.st2lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 2
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st2lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st2lane.v2f64.p0f64(<2 x double>, <2 x double>, i64, double*)


define double* @test_v1f64_post_imm_st2lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], #16
  call void @llvm.arm64.neon.st2lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 2
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st2lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st2lane:
;CHECK: st2.d { v0, v1 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st2lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st2lane.v1f64.p0f64(<1 x double>, <1 x double>, i64, double*)


define i8* @test_v16i8_post_imm_st3lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st3lane:
;CHECK: st3.b { v0, v1, v2 }[0], [x0], #3
  call void @llvm.arm64.neon.st3lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st3lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st3lane:
;CHECK: st3.b { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st3lane.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, i64, i8*)


define i8* @test_v8i8_post_imm_st3lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st3lane:
;CHECK: st3.b { v0, v1, v2 }[0], [x0], #3
  call void @llvm.arm64.neon.st3lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 3
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st3lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st3lane:
;CHECK: st3.b { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st3lane.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, i64, i8*)


define i16* @test_v8i16_post_imm_st3lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st3lane:
;CHECK: st3.h { v0, v1, v2 }[0], [x0], #6
  call void @llvm.arm64.neon.st3lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st3lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st3lane:
;CHECK: st3.h { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st3lane.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, i64, i16*)


define i16* @test_v4i16_post_imm_st3lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st3lane:
;CHECK: st3.h { v0, v1, v2 }[0], [x0], #6
  call void @llvm.arm64.neon.st3lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 3
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st3lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st3lane:
;CHECK: st3.h { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st3lane.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, i64, i16*)


define i32* @test_v4i32_post_imm_st3lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], #12
  call void @llvm.arm64.neon.st3lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st3lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st3lane.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, i64, i32*)


define i32* @test_v2i32_post_imm_st3lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], #12
  call void @llvm.arm64.neon.st3lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 3
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st3lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st3lane.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, i64, i32*)


define i64* @test_v2i64_post_imm_st3lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], #24
  call void @llvm.arm64.neon.st3lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 3
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st3lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st3lane.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, i64, i64*)


define i64* @test_v1i64_post_imm_st3lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], #24
  call void @llvm.arm64.neon.st3lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 3
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st3lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st3lane.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, i64, i64*)


define float* @test_v4f32_post_imm_st3lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], #12
  call void @llvm.arm64.neon.st3lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 3
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st3lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st3lane.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, i64, float*)


define float* @test_v2f32_post_imm_st3lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], #12
  call void @llvm.arm64.neon.st3lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 3
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st3lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st3lane:
;CHECK: st3.s { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st3lane.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, i64, float*)


define double* @test_v2f64_post_imm_st3lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], #24
  call void @llvm.arm64.neon.st3lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 3
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st3lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st3lane.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, i64, double*)


define double* @test_v1f64_post_imm_st3lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], #24
  call void @llvm.arm64.neon.st3lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 3
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st3lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st3lane:
;CHECK: st3.d { v0, v1, v2 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st3lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st3lane.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, i64, double*)


define i8* @test_v16i8_post_imm_st4lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E) nounwind {
;CHECK-LABEL: test_v16i8_post_imm_st4lane:
;CHECK: st4.b { v0, v1, v2, v3 }[0], [x0], #4
  call void @llvm.arm64.neon.st4lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  ret i8* %tmp
}

define i8* @test_v16i8_post_reg_st4lane(i8* %A, i8** %ptr, <16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v16i8_post_reg_st4lane:
;CHECK: st4.b { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v16i8.p0i8(<16 x i8> %B, <16 x i8> %C, <16 x i8> %D, <16 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st4lane.v16i8.p0i8(<16 x i8>, <16 x i8>, <16 x i8>, <16 x i8>, i64, i8*)


define i8* @test_v8i8_post_imm_st4lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E) nounwind {
;CHECK-LABEL: test_v8i8_post_imm_st4lane:
;CHECK: st4.b { v0, v1, v2, v3 }[0], [x0], #4
  call void @llvm.arm64.neon.st4lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i32 4
  ret i8* %tmp
}

define i8* @test_v8i8_post_reg_st4lane(i8* %A, i8** %ptr, <8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i8_post_reg_st4lane:
;CHECK: st4.b { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v8i8.p0i8(<8 x i8> %B, <8 x i8> %C, <8 x i8> %D, <8 x i8> %E, i64 0, i8* %A)
  %tmp = getelementptr i8* %A, i64 %inc
  ret i8* %tmp
}

declare void @llvm.arm64.neon.st4lane.v8i8.p0i8(<8 x i8>, <8 x i8>, <8 x i8>, <8 x i8>, i64, i8*)


define i16* @test_v8i16_post_imm_st4lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E) nounwind {
;CHECK-LABEL: test_v8i16_post_imm_st4lane:
;CHECK: st4.h { v0, v1, v2, v3 }[0], [x0], #8
  call void @llvm.arm64.neon.st4lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  ret i16* %tmp
}

define i16* @test_v8i16_post_reg_st4lane(i16* %A, i16** %ptr, <8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v8i16_post_reg_st4lane:
;CHECK: st4.h { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v8i16.p0i16(<8 x i16> %B, <8 x i16> %C, <8 x i16> %D, <8 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st4lane.v8i16.p0i16(<8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, i64, i16*)


define i16* @test_v4i16_post_imm_st4lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E) nounwind {
;CHECK-LABEL: test_v4i16_post_imm_st4lane:
;CHECK: st4.h { v0, v1, v2, v3 }[0], [x0], #8
  call void @llvm.arm64.neon.st4lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i32 4
  ret i16* %tmp
}

define i16* @test_v4i16_post_reg_st4lane(i16* %A, i16** %ptr, <4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i16_post_reg_st4lane:
;CHECK: st4.h { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v4i16.p0i16(<4 x i16> %B, <4 x i16> %C, <4 x i16> %D, <4 x i16> %E, i64 0, i16* %A)
  %tmp = getelementptr i16* %A, i64 %inc
  ret i16* %tmp
}

declare void @llvm.arm64.neon.st4lane.v4i16.p0i16(<4 x i16>, <4 x i16>, <4 x i16>, <4 x i16>, i64, i16*)


define i32* @test_v4i32_post_imm_st4lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E) nounwind {
;CHECK-LABEL: test_v4i32_post_imm_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], #16
  call void @llvm.arm64.neon.st4lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  ret i32* %tmp
}

define i32* @test_v4i32_post_reg_st4lane(i32* %A, i32** %ptr, <4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4i32_post_reg_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v4i32.p0i32(<4 x i32> %B, <4 x i32> %C, <4 x i32> %D, <4 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st4lane.v4i32.p0i32(<4 x i32>, <4 x i32>, <4 x i32>, <4 x i32>, i64, i32*)


define i32* @test_v2i32_post_imm_st4lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E) nounwind {
;CHECK-LABEL: test_v2i32_post_imm_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], #16
  call void @llvm.arm64.neon.st4lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i32 4
  ret i32* %tmp
}

define i32* @test_v2i32_post_reg_st4lane(i32* %A, i32** %ptr, <2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i32_post_reg_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v2i32.p0i32(<2 x i32> %B, <2 x i32> %C, <2 x i32> %D, <2 x i32> %E, i64 0, i32* %A)
  %tmp = getelementptr i32* %A, i64 %inc
  ret i32* %tmp
}

declare void @llvm.arm64.neon.st4lane.v2i32.p0i32(<2 x i32>, <2 x i32>, <2 x i32>, <2 x i32>, i64, i32*)


define i64* @test_v2i64_post_imm_st4lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E) nounwind {
;CHECK-LABEL: test_v2i64_post_imm_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], #32
  call void @llvm.arm64.neon.st4lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v2i64_post_reg_st4lane(i64* %A, i64** %ptr, <2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2i64_post_reg_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v2i64.p0i64(<2 x i64> %B, <2 x i64> %C, <2 x i64> %D, <2 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st4lane.v2i64.p0i64(<2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, i64, i64*)


define i64* @test_v1i64_post_imm_st4lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E) nounwind {
;CHECK-LABEL: test_v1i64_post_imm_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], #32
  call void @llvm.arm64.neon.st4lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 4
  ret i64* %tmp
}

define i64* @test_v1i64_post_reg_st4lane(i64* %A, i64** %ptr, <1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1i64_post_reg_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v1i64.p0i64(<1 x i64> %B, <1 x i64> %C, <1 x i64> %D, <1 x i64> %E, i64 0, i64* %A)
  %tmp = getelementptr i64* %A, i64 %inc
  ret i64* %tmp
}

declare void @llvm.arm64.neon.st4lane.v1i64.p0i64(<1 x i64>, <1 x i64>, <1 x i64>, <1 x i64>, i64, i64*)


define float* @test_v4f32_post_imm_st4lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E) nounwind {
;CHECK-LABEL: test_v4f32_post_imm_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], #16
  call void @llvm.arm64.neon.st4lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 4
  ret float* %tmp
}

define float* @test_v4f32_post_reg_st4lane(float* %A, float** %ptr, <4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v4f32_post_reg_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v4f32.p0f32(<4 x float> %B, <4 x float> %C, <4 x float> %D, <4 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st4lane.v4f32.p0f32(<4 x float>, <4 x float>, <4 x float>, <4 x float>, i64, float*)


define float* @test_v2f32_post_imm_st4lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E) nounwind {
;CHECK-LABEL: test_v2f32_post_imm_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], #16
  call void @llvm.arm64.neon.st4lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i32 4
  ret float* %tmp
}

define float* @test_v2f32_post_reg_st4lane(float* %A, float** %ptr, <2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f32_post_reg_st4lane:
;CHECK: st4.s { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v2f32.p0f32(<2 x float> %B, <2 x float> %C, <2 x float> %D, <2 x float> %E, i64 0, float* %A)
  %tmp = getelementptr float* %A, i64 %inc
  ret float* %tmp
}

declare void @llvm.arm64.neon.st4lane.v2f32.p0f32(<2 x float>, <2 x float>, <2 x float>, <2 x float>, i64, float*)


define double* @test_v2f64_post_imm_st4lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E) nounwind {
;CHECK-LABEL: test_v2f64_post_imm_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], #32
  call void @llvm.arm64.neon.st4lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v2f64_post_reg_st4lane(double* %A, double** %ptr, <2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v2f64_post_reg_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v2f64.p0f64(<2 x double> %B, <2 x double> %C, <2 x double> %D, <2 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st4lane.v2f64.p0f64(<2 x double>, <2 x double>, <2 x double>, <2 x double>, i64, double*)


define double* @test_v1f64_post_imm_st4lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E) nounwind {
;CHECK-LABEL: test_v1f64_post_imm_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], #32
  call void @llvm.arm64.neon.st4lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 4
  ret double* %tmp
}

define double* @test_v1f64_post_reg_st4lane(double* %A, double** %ptr, <1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 %inc) nounwind {
;CHECK-LABEL: test_v1f64_post_reg_st4lane:
;CHECK: st4.d { v0, v1, v2, v3 }[0], [x0], x{{[0-9]+}}
  call void @llvm.arm64.neon.st4lane.v1f64.p0f64(<1 x double> %B, <1 x double> %C, <1 x double> %D, <1 x double> %E, i64 0, double* %A)
  %tmp = getelementptr double* %A, i64 %inc
  ret double* %tmp
}

declare void @llvm.arm64.neon.st4lane.v1f64.p0f64(<1 x double>, <1 x double>, <1 x double>, <1 x double>, i64, double*)