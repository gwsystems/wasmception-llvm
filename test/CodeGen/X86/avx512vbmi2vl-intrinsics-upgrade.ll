; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512vbmi2,+avx512vl --show-mc-encoding | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vbmi2,+avx512vl --show-mc-encoding | FileCheck %s --check-prefixes=CHECK,X64

define <8 x i16> @test_mask_expand_load_w_128(i8* %addr, <8 x i16> %data, i8 %mask) {
; X86-LABEL: test_mask_expand_load_w_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %ecx # encoding: [0x0f,0xb6,0x4c,0x24,0x08]
; X86-NEXT:    kmovd %ecx, %k1 # encoding: [0xc5,0xfb,0x92,0xc9]
; X86-NEXT:    vpexpandw (%eax), %xmm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_expand_load_w_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandw (%rdi), %xmm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.avx512.mask.expand.load.w.128(i8* %addr, <8 x i16> %data, i8 %mask)
  ret <8 x i16> %res
}

define <8 x i16> @test_maskz_expand_load_w_128(i8* %addr, i8 %mask) {
; X86-LABEL: test_maskz_expand_load_w_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %ecx # encoding: [0x0f,0xb6,0x4c,0x24,0x08]
; X86-NEXT:    kmovd %ecx, %k1 # encoding: [0xc5,0xfb,0x92,0xc9]
; X86-NEXT:    vpexpandw (%eax), %xmm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0x89,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_maskz_expand_load_w_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandw (%rdi), %xmm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0x89,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.avx512.mask.expand.load.w.128(i8* %addr, <8 x i16> zeroinitializer, i8 %mask)
  ret <8 x i16> %res
}

declare <8 x i16> @llvm.x86.avx512.mask.expand.load.w.128(i8* %addr, <8 x i16> %data, i8 %mask)

define <8 x i16> @test_expand_load_w_128(i8* %addr, <8 x i16> %data) {
; X86-LABEL: test_expand_load_w_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpexpandw (%eax), %xmm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_expand_load_w_128:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpexpandw (%rdi), %xmm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.avx512.mask.expand.load.w.128(i8* %addr, <8 x i16> %data, i8 -1)
  ret <8 x i16> %res
}

define <16 x i8> @test_mask_expand_load_b_128(i8* %addr, <16 x i8> %data, i16 %mask) {
; X86-LABEL: test_mask_expand_load_b_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandb (%eax), %xmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_expand_load_b_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandb (%rdi), %xmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.avx512.mask.expand.load.b.128(i8* %addr, <16 x i8> %data, i16 %mask)
  ret <16 x i8> %res
}

define <16 x i8> @test_maskz_expand_load_b_128(i8* %addr, i16 %mask) {
; X86-LABEL: test_maskz_expand_load_b_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandb (%eax), %xmm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0x89,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_maskz_expand_load_b_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandb (%rdi), %xmm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0x89,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.avx512.mask.expand.load.b.128(i8* %addr, <16 x i8> zeroinitializer, i16 %mask)
  ret <16 x i8> %res
}

declare <16 x i8> @llvm.x86.avx512.mask.expand.load.b.128(i8* %addr, <16 x i8> %data, i16 %mask)

define <16 x i8> @test_expand_load_b_128(i8* %addr, <16 x i8> %data) {
; X86-LABEL: test_expand_load_b_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpexpandb (%eax), %xmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_expand_load_b_128:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpexpandb (%rdi), %xmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.avx512.mask.expand.load.b.128(i8* %addr, <16 x i8> %data, i16 -1)
  ret <16 x i8> %res
}

define void @test_mask_compress_store_w_128(i8* %addr, <8 x i16> %data, i8 %mask) {
; X86-LABEL: test_mask_compress_store_w_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %ecx # encoding: [0x0f,0xb6,0x4c,0x24,0x08]
; X86-NEXT:    kmovd %ecx, %k1 # encoding: [0xc5,0xfb,0x92,0xc9]
; X86-NEXT:    vpcompressw %xmm0, (%eax) {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x63,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_compress_store_w_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpcompressw %xmm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x63,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.w.128(i8* %addr, <8 x i16> %data, i8 %mask)
  ret void
}

declare void @llvm.x86.avx512.mask.compress.store.w.128(i8* %addr, <8 x i16> %data, i8 %mask)

define void @test_compress_store_w_128(i8* %addr, <8 x i16> %data) {
; X86-LABEL: test_compress_store_w_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpcompressw %xmm0, (%eax) {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x63,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_compress_store_w_128:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpcompressw %xmm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0xfd,0x09,0x63,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.w.128(i8* %addr, <8 x i16> %data, i8 -1)
  ret void
}

define void @test_mask_compress_store_b_128(i8* %addr, <16 x i8> %data, i16 %mask) {
; X86-LABEL: test_mask_compress_store_b_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpcompressb %xmm0, (%eax) {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x63,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_compress_store_b_128:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpcompressb %xmm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x63,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.b.128(i8* %addr, <16 x i8> %data, i16 %mask)
  ret void
}

declare void @llvm.x86.avx512.mask.compress.store.b.128(i8* %addr, <16 x i8> %data, i16 %mask)

define void @test_compress_store_b_128(i8* %addr, <16 x i8> %data) {
; X86-LABEL: test_compress_store_b_128:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpcompressb %xmm0, (%eax) {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x63,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_compress_store_b_128:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpcompressb %xmm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0x7d,0x09,0x63,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.b.128(i8* %addr, <16 x i8> %data, i16 -1)
  ret void
}

define <16 x i16> @test_mask_expand_load_w_256(i8* %addr, <16 x i16> %data, i16 %mask) {
; X86-LABEL: test_mask_expand_load_w_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandw (%eax), %ymm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_expand_load_w_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandw (%rdi), %ymm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i16> @llvm.x86.avx512.mask.expand.load.w.256(i8* %addr, <16 x i16> %data, i16 %mask)
  ret <16 x i16> %res
}

define <16 x i16> @test_maskz_expand_load_w_256(i8* %addr, i16 %mask) {
; X86-LABEL: test_maskz_expand_load_w_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandw (%eax), %ymm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0xa9,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_maskz_expand_load_w_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandw (%rdi), %ymm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0xa9,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i16> @llvm.x86.avx512.mask.expand.load.w.256(i8* %addr, <16 x i16> zeroinitializer, i16 %mask)
  ret <16 x i16> %res
}

declare <16 x i16> @llvm.x86.avx512.mask.expand.load.w.256(i8* %addr, <16 x i16> %data, i16 %mask)

define <16 x i16> @test_expand_load_w_256(i8* %addr, <16 x i16> %data) {
; X86-LABEL: test_expand_load_w_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpexpandw (%eax), %ymm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_expand_load_w_256:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpexpandw (%rdi), %ymm0 {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <16 x i16> @llvm.x86.avx512.mask.expand.load.w.256(i8* %addr, <16 x i16> %data, i16 -1)
  ret <16 x i16> %res
}

define <32 x i8> @test_mask_expand_load_b_256(i8* %addr, <32 x i8> %data, i32 %mask) {
; X86-LABEL: test_mask_expand_load_b_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovd {{[0-9]+}}(%esp), %k1 # encoding: [0xc4,0xe1,0xf9,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandb (%eax), %ymm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_expand_load_b_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandb (%rdi), %ymm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <32 x i8> @llvm.x86.avx512.mask.expand.load.b.256(i8* %addr, <32 x i8> %data, i32 %mask)
  ret <32 x i8> %res
}

define <32 x i8> @test_maskz_expand_load_b_256(i8* %addr, i32 %mask) {
; X86-LABEL: test_maskz_expand_load_b_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovd {{[0-9]+}}(%esp), %k1 # encoding: [0xc4,0xe1,0xf9,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpexpandb (%eax), %ymm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0xa9,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_maskz_expand_load_b_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpexpandb (%rdi), %ymm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0xa9,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <32 x i8> @llvm.x86.avx512.mask.expand.load.b.256(i8* %addr, <32 x i8> zeroinitializer, i32 %mask)
  ret <32 x i8> %res
}

declare <32 x i8> @llvm.x86.avx512.mask.expand.load.b.256(i8* %addr, <32 x i8> %data, i32 %mask)

define <32 x i8> @test_expand_load_b_256(i8* %addr, <32 x i8> %data) {
; X86-LABEL: test_expand_load_b_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnord %k0, %k0, %k1 # encoding: [0xc4,0xe1,0xfd,0x46,0xc8]
; X86-NEXT:    vpexpandb (%eax), %ymm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x62,0x00]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_expand_load_b_256:
; X64:       # %bb.0:
; X64-NEXT:    kxnord %k0, %k0, %k1 # encoding: [0xc4,0xe1,0xfd,0x46,0xc8]
; X64-NEXT:    vpexpandb (%rdi), %ymm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x62,0x07]
; X64-NEXT:    retq # encoding: [0xc3]
  %res = call <32 x i8> @llvm.x86.avx512.mask.expand.load.b.256(i8* %addr, <32 x i8> %data, i32 -1)
  ret <32 x i8> %res
}

define void @test_mask_compress_store_w_256(i8* %addr, <16 x i16> %data, i16 %mask) {
; X86-LABEL: test_mask_compress_store_w_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpcompressw %ymm0, (%eax) {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x63,0x00]
; X86-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_compress_store_w_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpcompressw %ymm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x63,0x07]
; X64-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.w.256(i8* %addr, <16 x i16> %data, i16 %mask)
  ret void
}

declare void @llvm.x86.avx512.mask.compress.store.w.256(i8* %addr, <16 x i16> %data, i16 %mask)

define void @test_compress_store_w_256(i8* %addr, <16 x i16> %data) {
; X86-LABEL: test_compress_store_w_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X86-NEXT:    vpcompressw %ymm0, (%eax) {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x63,0x00]
; X86-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_compress_store_w_256:
; X64:       # %bb.0:
; X64-NEXT:    kxnorw %k0, %k0, %k1 # encoding: [0xc5,0xfc,0x46,0xc8]
; X64-NEXT:    vpcompressw %ymm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0xfd,0x29,0x63,0x07]
; X64-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.w.256(i8* %addr, <16 x i16> %data, i16 -1)
  ret void
}

define void @test_mask_compress_store_b_256(i8* %addr, <32 x i8> %data, i32 %mask) {
; X86-LABEL: test_mask_compress_store_b_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kmovd {{[0-9]+}}(%esp), %k1 # encoding: [0xc4,0xe1,0xf9,0x90,0x4c,0x24,0x08]
; X86-NEXT:    vpcompressb %ymm0, (%eax) {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x63,0x00]
; X86-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_mask_compress_store_b_256:
; X64:       # %bb.0:
; X64-NEXT:    kmovd %esi, %k1 # encoding: [0xc5,0xfb,0x92,0xce]
; X64-NEXT:    vpcompressb %ymm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x63,0x07]
; X64-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.b.256(i8* %addr, <32 x i8> %data, i32 %mask)
  ret void
}

declare void @llvm.x86.avx512.mask.compress.store.b.256(i8* %addr, <32 x i8> %data, i32 %mask)

define void @test_compress_store_b_256(i8* %addr, <32 x i8> %data) {
; X86-LABEL: test_compress_store_b_256:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax # encoding: [0x8b,0x44,0x24,0x04]
; X86-NEXT:    kxnord %k0, %k0, %k1 # encoding: [0xc4,0xe1,0xfd,0x46,0xc8]
; X86-NEXT:    vpcompressb %ymm0, (%eax) {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x63,0x00]
; X86-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X86-NEXT:    retl # encoding: [0xc3]
;
; X64-LABEL: test_compress_store_b_256:
; X64:       # %bb.0:
; X64-NEXT:    kxnord %k0, %k0, %k1 # encoding: [0xc4,0xe1,0xfd,0x46,0xc8]
; X64-NEXT:    vpcompressb %ymm0, (%rdi) {%k1} # encoding: [0x62,0xf2,0x7d,0x29,0x63,0x07]
; X64-NEXT:    vzeroupper # encoding: [0xc5,0xf8,0x77]
; X64-NEXT:    retq # encoding: [0xc3]
  call void @llvm.x86.avx512.mask.compress.store.b.256(i8* %addr, <32 x i8> %data, i32 -1)
  ret void
}
