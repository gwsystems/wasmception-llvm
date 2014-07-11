; RUN: llc -mtriple=arm64-linux-gnu -enable-misched=false < %s | FileCheck %s

@var = global i32 0, align 4

define i128 @test_i128_align(i32, i128 %arg, i32 %after) {
  store i32 %after, i32* @var, align 4
; CHECK: str w4, [{{x[0-9]+}}, :lo12:var]

  ret i128 %arg
; CHECK: mov x0, x2
; CHECK: mov x1, x3
}

@var64 = global i64 0, align 8

  ; Check stack slots are 64-bit at all times.
define void @test_stack_slots([8 x i32], i1 %bool, i8 %char, i16 %short,
                                i32 %int, i64 %long) {
  ; Part of last store. Blasted scheduler.
; CHECK: ldr [[LONG:x[0-9]+]], [sp, #32]

  %ext_bool = zext i1 %bool to i64
  store volatile i64 %ext_bool, i64* @var64, align 8
; CHECK: ldrb w[[EXT:[0-9]+]], [sp]
; CHECK: and x[[EXTED:[0-9]+]], x[[EXT]], #0x1
; CHECK: str x[[EXTED]], [{{x[0-9]+}}, :lo12:var64]

  %ext_char = zext i8 %char to i64
  store volatile i64 %ext_char, i64* @var64, align 8
; CHECK: ldrb w[[EXT:[0-9]+]], [sp, #8]
; CHECK: str x[[EXT]], [{{x[0-9]+}}, :lo12:var64]

  %ext_short = zext i16 %short to i64
  store volatile i64 %ext_short, i64* @var64, align 8
; CHECK: ldrh w[[EXT:[0-9]+]], [sp, #16]
; CHECK: str x[[EXT]], [{{x[0-9]+}}, :lo12:var64]

  %ext_int = zext i32 %int to i64
  store volatile i64 %ext_int, i64* @var64, align 8
; CHECK: ldr{{b?}} w[[EXT:[0-9]+]], [sp, #24]
; CHECK: str x[[EXT]], [{{x[0-9]+}}, :lo12:var64]

  store volatile i64 %long, i64* @var64, align 8
; CHECK: str [[LONG]], [{{x[0-9]+}}, :lo12:var64]

  ret void
}

; Make sure the callee does extensions (in the absence of zext/sext
; keyword on args) while we're here.

define void @test_extension(i1 %bool, i8 %char, i16 %short, i32 %int) {
  %ext_bool = zext i1 %bool to i64
  store volatile i64 %ext_bool, i64* @var64
; CHECK: and [[EXT:x[0-9]+]], x0, #0x1
; CHECK: str [[EXT]], [{{x[0-9]+}}, :lo12:var64]

  %ext_char = sext i8 %char to i64
  store volatile i64 %ext_char, i64* @var64
; CHECK: sxtb [[EXT:x[0-9]+]], w1
; CHECK: str [[EXT]], [{{x[0-9]+}}, :lo12:var64]

  %ext_short = zext i16 %short to i64
  store volatile i64 %ext_short, i64* @var64
; CHECK: and [[EXT:x[0-9]+]], x2, #0xffff
; CHECK: str [[EXT]], [{{x[0-9]+}}, :lo12:var64]

  %ext_int = zext i32 %int to i64
  store volatile i64 %ext_int, i64* @var64
; CHECK: ubfx [[EXT:x[0-9]+]], x3, #0, #32
; CHECK: str [[EXT]], [{{x[0-9]+}}, :lo12:var64]

  ret void
}

declare void @variadic(i32 %a, ...)

  ; Under AAPCS variadic functions have the same calling convention as
  ; others. The extra arguments should go in registers rather than on the stack.
define void @test_variadic() {
  call void(i32, ...)* @variadic(i32 0, i64 1, double 2.0)
; CHECK: fmov d0, #2.0
; CHECK: orr w1, wzr, #0x1
; CHECK: bl variadic
  ret void
}

; We weren't marking x7 as used after deciding that the i128 didn't fit into
; registers and putting the first half on the stack, so the *second* half went
; into x7. Yuck!
define i128 @test_i128_shadow([7 x i64] %x0_x6, i128 %sp) {
; CHECK-LABEL: test_i128_shadow:
; CHECK: ldp x0, x1, [sp]

  ret i128 %sp
}

; This test is to check if fp128 can be correctly handled on stack.
define fp128 @test_fp128([8 x float] %arg0, fp128 %arg1) {
; CHECK-LABEL: test_fp128:
; CHECK: ldr {{q[0-9]+}}, [sp]
  ret fp128 %arg1
}

; Check if VPR can be correctly pass by stack.
define <2 x double> @test_vreg_stack([8 x <2 x double>], <2 x double> %varg_stack) {
entry:
; CHECK-LABEL: test_vreg_stack:
; CHECK: ldr {{q[0-9]+}}, [sp]
  ret <2 x double> %varg_stack;
}

; Check that f16 can be passed and returned (ACLE 2.0 extension)
define half @test_half(float, half %arg) {
; CHECK-LABEL: test_half:
; CHECK: mov v0.16b, v{{[0-9]+}}.16b
  ret half %arg;
}

; Check that f16 constants are materialized correctly
define half @test_half_const() {
; CHECK-LABEL: test_half_const:
; CHECK: ldr h0, [x{{[0-9]+}}, :lo12:{{.*}}]
  ret half 0xH4248
}
