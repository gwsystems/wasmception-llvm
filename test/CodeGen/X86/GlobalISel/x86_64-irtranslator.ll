; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -O0 -global-isel -stop-after=irtranslator -verify-machineinstrs %s -o - 2>&1 | FileCheck %s

define i8 @zext_i1_to_i8(i1 %val) {
  ; CHECK-LABEL: name: zext_i1_to_i8
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s1) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s8) = G_ZEXT [[TRUNC]](s1)
  ; CHECK:   $al = COPY [[ZEXT]](s8)
  ; CHECK:   RET 0, implicit $al
  %res = zext i1 %val to i8
  ret i8 %res
}

define i16 @zext_i1_to_i16(i1 %val) {
  ; CHECK-LABEL: name: zext_i1_to_i16
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s1) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s16) = G_ZEXT [[TRUNC]](s1)
  ; CHECK:   $ax = COPY [[ZEXT]](s16)
  ; CHECK:   RET 0, implicit $ax
  %res = zext i1 %val to i16
  ret i16 %res
}

define i32 @zext_i1_to_i32(i1 %val) {
  ; CHECK-LABEL: name: zext_i1_to_i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s1) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s1)
  ; CHECK:   $eax = COPY [[ZEXT]](s32)
  ; CHECK:   RET 0, implicit $eax
  %res = zext i1 %val to i32
  ret i32 %res
}

define i64 @zext_i1_to_i64(i1 %val) {
  ; CHECK-LABEL: name: zext_i1_to_i64
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s1) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s64) = G_ZEXT [[TRUNC]](s1)
  ; CHECK:   $rax = COPY [[ZEXT]](s64)
  ; CHECK:   RET 0, implicit $rax
  %res = zext i1 %val to i64
  ret i64 %res
}

define i16 @zext_i8_to_i16(i8 %val) {
  ; CHECK-LABEL: name: zext_i8_to_i16
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s8) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s16) = G_ZEXT [[TRUNC]](s8)
  ; CHECK:   $ax = COPY [[ZEXT]](s16)
  ; CHECK:   RET 0, implicit $ax
  %res = zext i8 %val to i16
  ret i16 %res
}

define i32 @zext_i8_to_i32(i8 %val) {
  ; CHECK-LABEL: name: zext_i8_to_i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s8) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s8)
  ; CHECK:   $eax = COPY [[ZEXT]](s32)
  ; CHECK:   RET 0, implicit $eax
  %res = zext i8 %val to i32
  ret i32 %res
}

define i64 @zext_i8_to_i64(i8 %val) {
  ; CHECK-LABEL: name: zext_i8_to_i64
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s8) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s64) = G_ZEXT [[TRUNC]](s8)
  ; CHECK:   $rax = COPY [[ZEXT]](s64)
  ; CHECK:   RET 0, implicit $rax
  %res = zext i8 %val to i64
  ret i64 %res
}

define i32 @zext_i16_to_i32(i16 %val) {
  ; CHECK-LABEL: name: zext_i16_to_i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s16)
  ; CHECK:   $eax = COPY [[ZEXT]](s32)
  ; CHECK:   RET 0, implicit $eax
  %res = zext i16 %val to i32
  ret i32 %res
}

define i64 @zext_i16_to_i64(i16 %val) {
  ; CHECK-LABEL: name: zext_i16_to_i64
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY]](s32)
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s64) = G_ZEXT [[TRUNC]](s16)
  ; CHECK:   $rax = COPY [[ZEXT]](s64)
  ; CHECK:   RET 0, implicit $rax
  %res = zext i16 %val to i64
  ret i64 %res
}

define i64 @zext_i32_to_i64(i32 %val) {
  ; CHECK-LABEL: name: zext_i32_to_i64
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK:   liveins: $edi
  ; CHECK:   [[COPY:%[0-9]+]]:_(s32) = COPY $edi
  ; CHECK:   [[ZEXT:%[0-9]+]]:_(s64) = G_ZEXT [[COPY]](s32)
  ; CHECK:   $rax = COPY [[ZEXT]](s64)
  ; CHECK:   RET 0, implicit $rax
  %res = zext i32 %val to i64
  ret i64 %res
}
