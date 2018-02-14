; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mcpu=core-avx2 -stop-after expand-isel-pseudos -o - %s | FileCheck %s

declare void @llvm.masked.store.v16f32.p0v16f32(<16 x float>, <16 x float>*, i32, <16 x i1>)
declare <16 x float> @llvm.masked.load.v16f32.p0v16f32(<16 x float>*, i32, <16 x i1>, <16 x float>)

define void @test_v16f() local_unnamed_addr {
  ; CHECK-LABEL: name: test_v16f
  ; CHECK: bb.0.bb:
  ; CHECK:   [[AVX_SET0_:%[0-9]+]]:vr256 = AVX_SET0
  ; CHECK:   [[VMASKMOVPSYrm:%[0-9]+]]:vr256 = VMASKMOVPSYrm [[AVX_SET0_]], %stack.0.stack_input_vec, 1, $noreg, 0, $noreg :: (load 32 from %ir.stack_input_vec, align 4)
  ; CHECK:   [[VMASKMOVPSYrm1:%[0-9]+]]:vr256 = VMASKMOVPSYrm [[AVX_SET0_]], %stack.0.stack_input_vec, 1, $noreg, 32, $noreg :: (load 32 from %ir.stack_input_vec + 32, align 4)
  ; CHECK:   VMASKMOVPSYmr %stack.1.stack_output_vec, 1, $noreg, 32, $noreg, [[AVX_SET0_]], killed [[VMASKMOVPSYrm1]] :: (store 32 into %ir.stack_output_vec + 32, align 4)
  ; CHECK:   VMASKMOVPSYmr %stack.1.stack_output_vec, 1, $noreg, 0, $noreg, [[AVX_SET0_]], killed [[VMASKMOVPSYrm]] :: (store 32 into %ir.stack_output_vec, align 4)
  ; CHECK:   RET 0
bb:
  %stack_input_vec = alloca <16 x float>, align 64
  %stack_output_vec = alloca <16 x float>, align 64
  %masked_loaded_vec = call <16 x float> @llvm.masked.load.v16f32.p0v16f32(<16 x float>* nonnull %stack_input_vec, i32 4, <16 x i1> undef, <16 x float> undef)
  call void @llvm.masked.store.v16f32.p0v16f32(<16 x float> %masked_loaded_vec, <16 x float>* nonnull %stack_output_vec, i32 4, <16 x i1> undef)
  ret void
}

declare void @llvm.masked.store.v8f64.p0v8f64(<8 x double>, <8 x double>*, i32, <8 x i1>)
declare <8 x double> @llvm.masked.load.v8f64.p0v8f64(<8 x double>*, i32, <8 x i1>, <8 x double>)

define void @test_v8d() local_unnamed_addr {
  ; CHECK-LABEL: name: test_v8d
  ; CHECK: bb.0.bb:
  ; CHECK:   [[AVX_SET0_:%[0-9]+]]:vr256 = AVX_SET0
  ; CHECK:   [[VMASKMOVPDYrm:%[0-9]+]]:vr256 = VMASKMOVPDYrm [[AVX_SET0_]], %stack.0.stack_input_vec, 1, $noreg, 0, $noreg :: (load 32 from %ir.stack_input_vec, align 4)
  ; CHECK:   [[VMASKMOVPDYrm1:%[0-9]+]]:vr256 = VMASKMOVPDYrm [[AVX_SET0_]], %stack.0.stack_input_vec, 1, $noreg, 32, $noreg :: (load 32 from %ir.stack_input_vec + 32, align 4)
  ; CHECK:   VMASKMOVPDYmr %stack.1.stack_output_vec, 1, $noreg, 32, $noreg, [[AVX_SET0_]], killed [[VMASKMOVPDYrm1]] :: (store 32 into %ir.stack_output_vec + 32, align 4)
  ; CHECK:   VMASKMOVPDYmr %stack.1.stack_output_vec, 1, $noreg, 0, $noreg, [[AVX_SET0_]], killed [[VMASKMOVPDYrm]] :: (store 32 into %ir.stack_output_vec, align 4)
  ; CHECK:   RET 0
bb:
  %stack_input_vec = alloca <8 x double>, align 64
  %stack_output_vec = alloca <8 x double>, align 64
  %masked_loaded_vec = call <8 x double> @llvm.masked.load.v8f64.p0v8f64(<8 x double>* nonnull %stack_input_vec, i32 4, <8 x i1> undef, <8 x double> undef)
  call void @llvm.masked.store.v8f64.p0v8f64(<8 x double> %masked_loaded_vec, <8 x double>* nonnull %stack_output_vec, i32 4, <8 x i1> undef)
  ret void
}
