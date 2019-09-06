; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve.fp %s -o - | FileCheck %s

define arm_aapcs_vfpcc <4 x i32> @vmlau32(<4 x i32> %A, <4 x i32> %B, i32 %X) nounwind {
; CHECK-LABEL: vmlau32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u32 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <4 x i32> undef, i32 %X, i32 0
  %1 = shufflevector <4 x i32> %0, <4 x i32> undef, <4 x i32> zeroinitializer
  %2 = mul nsw <4 x i32> %B, %1
  %3 = add nsw <4 x i32> %A, %2
  ret <4 x i32> %3
}

define arm_aapcs_vfpcc <4 x i32> @vmlau32b(<4 x i32> %A, <4 x i32> %B, i32 %X) nounwind {
; CHECK-LABEL: vmlau32b:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u32 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <4 x i32> undef, i32 %X, i32 0
  %1 = shufflevector <4 x i32> %0, <4 x i32> undef, <4 x i32> zeroinitializer
  %2 = mul nsw <4 x i32> %1, %B
  %3 = add nsw <4 x i32> %2, %A
  ret <4 x i32> %3
}

define arm_aapcs_vfpcc <8 x i16> @vmlau16(<8 x i16> %A, <8 x i16> %B, i16 %X) nounwind {
; CHECK-LABEL: vmlau16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u16 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <8 x i16> undef, i16 %X, i32 0
  %1 = shufflevector <8 x i16> %0, <8 x i16> undef, <8 x i32> zeroinitializer
  %2 = mul nsw <8 x i16> %B, %1
  %3 = add nsw <8 x i16> %A, %2
  ret <8 x i16> %3
}

define arm_aapcs_vfpcc <8 x i16> @vmlau16b(<8 x i16> %A, <8 x i16> %B, i16 %X) nounwind {
; CHECK-LABEL: vmlau16b:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u16 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <8 x i16> undef, i16 %X, i32 0
  %1 = shufflevector <8 x i16> %0, <8 x i16> undef, <8 x i32> zeroinitializer
  %2 = mul nsw <8 x i16> %1, %B
  %3 = add nsw <8 x i16> %2, %A
  ret <8 x i16> %3
}

define arm_aapcs_vfpcc <16 x i8> @vmlau8(<16 x i8> %A, <16 x i8> %B, i8 %X) nounwind {
; CHECK-LABEL: vmlau8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u8 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <16 x i8> undef, i8 %X, i32 0
  %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> zeroinitializer
  %2 = mul nsw <16 x i8> %B, %1
  %3 = add nsw <16 x i8> %A, %2
  ret <16 x i8> %3
}

define arm_aapcs_vfpcc <16 x i8> @vmlau8b(<16 x i8> %A, <16 x i8> %B, i8 %X) nounwind {
; CHECK-LABEL: vmlau8b:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmla.u8 q0, q1, r0
; CHECK-NEXT:    bx lr
entry:
  %0 = insertelement <16 x i8> undef, i8 %X, i32 0
  %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> zeroinitializer
  %2 = mul nsw <16 x i8> %1, %B
  %3 = add nsw <16 x i8> %2, %A
  ret <16 x i8> %3
}

define void @vmla32_in_loop(i32* %s1, i32 %x, i32* %d, i32 %n) {
; CHECK-LABEL: vmla32_in_loop:
; CHECK:      .LBB6_1: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q0, [r0, #16]!
; CHECK-NEXT:    vldrw.u32 q1, [r2, #16]!
; CHECK-NEXT:    vmla.u32 q1, q0, r1
; CHECK-NEXT:    vstrw.32 q1, [r2]
; CHECK-NEXT:    le lr, .LBB6_1
; CHECK-NEXT:  @ %bb.2: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %cmp6 = icmp sgt i32 %n, 0
  br i1 %cmp6, label %vector.ph, label %for.cond.cleanup

vector.ph:                                        ; preds = %for.body.preheader
  %n.vec = and i32 %n, -4
  %broadcast.splatinsert8 = insertelement <4 x i32> undef, i32 %x, i32 0
  %broadcast.splat9 = shufflevector <4 x i32> %broadcast.splatinsert8, <4 x i32> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i32, i32* %s1, i32 %index
  %1 = bitcast i32* %0 to <4 x i32>*
  %wide.load = load <4 x i32>, <4 x i32>* %1, align 4
  %2 = mul nsw <4 x i32> %wide.load, %broadcast.splat9
  %3 = getelementptr inbounds i32, i32* %d, i32 %index
  %4 = bitcast i32* %3 to <4 x i32>*
  %wide.load10 = load <4 x i32>, <4 x i32>* %4, align 4
  %5 = add nsw <4 x i32> %wide.load10, %2
  %6 = bitcast i32* %3 to <4 x i32>*
  store <4 x i32> %5, <4 x i32>* %6, align 4
  %index.next = add i32 %index, 4
  %7 = icmp eq i32 %index.next, %n.vec
  br i1 %7, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void
}

define void @vmla16_in_loop(i16* %s1, i16 %x, i16* %d, i32 %n) {
; CHECK-LABEL: vmla16_in_loop:
; CHECK:  .LBB7_1: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q0, [r0, #16]!
; CHECK-NEXT:    vldrh.u16 q1, [r2, #16]!
; CHECK-NEXT:    vmla.u16 q1, q0, r1
; CHECK-NEXT:    vstrh.16 q1, [r2]
; CHECK-NEXT:    le lr, .LBB7_1
; CHECK-NEXT:  @ %bb.2: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %cmp6 = icmp sgt i32 %n, 0
  br i1 %cmp6, label %vector.ph, label %for.cond.cleanup

vector.ph:                                        ; preds = %for.body.preheader
  %n.vec = and i32 %n, -8
  %broadcast.splatinsert11 = insertelement <8 x i16> undef, i16 %x, i32 0
  %broadcast.splat12 = shufflevector <8 x i16> %broadcast.splatinsert11, <8 x i16> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i16, i16* %s1, i32 %index
  %1 = bitcast i16* %0 to <8 x i16>*
  %wide.load = load <8 x i16>, <8 x i16>* %1, align 2
  %2 = mul <8 x i16> %wide.load, %broadcast.splat12
  %3 = getelementptr inbounds i16, i16* %d, i32 %index
  %4 = bitcast i16* %3 to <8 x i16>*
  %wide.load13 = load <8 x i16>, <8 x i16>* %4, align 2
  %5 = add <8 x i16> %2, %wide.load13
  %6 = bitcast i16* %3 to <8 x i16>*
  store <8 x i16> %5, <8 x i16>* %6, align 2
  %index.next = add i32 %index, 8
  %7 = icmp eq i32 %index.next, %n.vec
  br i1 %7, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void
}

define void @vmla8_in_loop(i8* %s1, i8 %x, i8* %d, i32 %n) {
; CHECK-LABEL: vmla8_in_loop:
; CHECK:  .LBB8_1: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q0, [r0, #8]!
; CHECK-NEXT:    vldrh.u16 q1, [r2, #8]!
; CHECK-NEXT:    vmla.u8 q1, q0, r1
; CHECK-NEXT:    vstrh.16 q1, [r2]
; CHECK-NEXT:    le lr, .LBB8_1
; CHECK-NEXT:  @ %bb.2: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %cmp6 = icmp sgt i32 %n, 0
  br i1 %cmp6, label %vector.ph, label %for.cond.cleanup

vector.ph:                                        ; preds = %for.body.preheader
  %n.vec = and i32 %n, -8
  %broadcast.splatinsert11 = insertelement <16 x i8> undef, i8 %x, i32 0
  %broadcast.splat12 = shufflevector <16 x i8> %broadcast.splatinsert11, <16 x i8> undef, <16 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i8, i8* %s1, i32 %index
  %1 = bitcast i8* %0 to <16 x i8>*
  %wide.load = load <16 x i8>, <16 x i8>* %1, align 2
  %2 = mul <16 x i8> %wide.load, %broadcast.splat12
  %3 = getelementptr inbounds i8, i8* %d, i32 %index
  %4 = bitcast i8* %3 to <16 x i8>*
  %wide.load13 = load <16 x i8>, <16 x i8>* %4, align 2
  %5 = add <16 x i8> %2, %wide.load13
  %6 = bitcast i8* %3 to <16 x i8>*
  store <16 x i8> %5, <16 x i8>* %6, align 2
  %index.next = add i32 %index, 8
  %7 = icmp eq i32 %index.next, %n.vec
  br i1 %7, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %for.body, %middle.block, %entry
  ret void
}
