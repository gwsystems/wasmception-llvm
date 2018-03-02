; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512vl,+avx512dq -O2 | FileCheck %s --check-prefix=AVX512-ALL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f -O2| FileCheck %s --check-prefix=AVX512-ONLY

define void @load_v1i2_trunc_v1i1_store(<1 x i2>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i2_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i2_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i2>, <1 x i2>* %a0
    %d1 = trunc <1 x i2> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i3_trunc_v1i1_store(<1 x i3>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i3_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i3_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i3>, <1 x i3>* %a0
    %d1 = trunc <1 x i3> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i4_trunc_v1i1_store(<1 x i4>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i4_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i4_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i4>, <1 x i4>* %a0
    %d1 = trunc <1 x i4> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i8_trunc_v1i1_store(<1 x i8>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i8_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i8_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i8>, <1 x i8>* %a0
    %d1 = trunc <1 x i8> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i16_trunc_v1i1_store(<1 x i16>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i16_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i16_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i16>, <1 x i16>* %a0
    %d1 = trunc <1 x i16> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i32_trunc_v1i1_store(<1 x i32>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i32_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i32_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i32>, <1 x i32>* %a0
    %d1 = trunc <1 x i32> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}
define void @load_v1i64_trunc_v1i1_store(<1 x i64>* %a0,<1 x i1>* %a1) {
; AVX512-ALL-LABEL: load_v1i64_trunc_v1i1_store:
; AVX512-ALL:       # %bb.0:
; AVX512-ALL-NEXT:    kmovb (%rdi), %k0
; AVX512-ALL-NEXT:    kmovb %k0, (%rsi)
; AVX512-ALL-NEXT:    retq
;
; AVX512-ONLY-LABEL: load_v1i64_trunc_v1i1_store:
; AVX512-ONLY:       # %bb.0:
; AVX512-ONLY-NEXT:    movb (%rdi), %al
; AVX512-ONLY-NEXT:    movb %al, (%rsi)
; AVX512-ONLY-NEXT:    retq
    %d0 = load <1 x i64>, <1 x i64>* %a0
    %d1 = trunc <1 x i64> %d0 to <1 x i1>
    store <1 x i1> %d1, <1 x i1>* %a1
    ret void
}

