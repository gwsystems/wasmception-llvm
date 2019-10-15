; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- | FileCheck %s

define i8 @isnonneg_i8(i8 %x) {
; CHECK-LABEL: isnonneg_i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    sarb $7, %al
; CHECK-NEXT:    orb $42, %al
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %cond = icmp sgt i8 %x, -1
  %r = select i1 %cond, i8 42, i8 -1
  ret i8 %r
}

define i16 @isnonneg_i16(i16 %x) {
; CHECK-LABEL: isnonneg_i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movswl %di, %eax
; CHECK-NEXT:    sarl $15, %eax
; CHECK-NEXT:    orl $542, %eax # imm = 0x21E
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
  %cond = icmp sgt i16 %x, -1
  %r = select i1 %cond, i16 542, i16 -1
  ret i16 %r
}

define i32 @isnonneg_i32(i32 %x) {
; CHECK-LABEL: isnonneg_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    sarl $31, %eax
; CHECK-NEXT:    orl $-42, %eax
; CHECK-NEXT:    retq
  %cond = icmp sgt i32 %x, -1
  %r = select i1 %cond, i32 -42, i32 -1
  ret i32 %r
}

define i64 @isnonneg_i64(i64 %x) {
; CHECK-LABEL: isnonneg_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    sarq $63, %rax
; CHECK-NEXT:    orq $2342342, %rax # imm = 0x23BDC6
; CHECK-NEXT:    retq
  %cond = icmp sgt i64 %x, -1
  %r = select i1 %cond, i64 2342342, i64 -1
  ret i64 %r
}

define <16 x i8> @isnonneg_v16i8(<16 x i8> %x) {
; CHECK-LABEL: isnonneg_v16i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pxor %xmm1, %xmm1
; CHECK-NEXT:    pcmpgtb %xmm0, %xmm1
; CHECK-NEXT:    por {{.*}}(%rip), %xmm1
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %cond = icmp sgt <16 x i8> %x, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %r = select <16 x i1> %cond, <16 x i8> <i8 12, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42>, <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  ret <16 x i8> %r
}

define <8 x i16> @isnonneg_v8i16(<8 x i16> %x) {
; CHECK-LABEL: isnonneg_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psraw $15, %xmm0
; CHECK-NEXT:    por {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp sgt <8 x i16> %x, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %r = select <8 x i1> %cond, <8 x i16> <i16 1, i16 542, i16 542, i16 542, i16 542, i16 542, i16 542, i16 1>, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  ret <8 x i16> %r
}

define <4 x i32> @isnonneg_v4i32(<4 x i32> %x) {
; CHECK-LABEL: isnonneg_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psrad $31, %xmm0
; CHECK-NEXT:    por {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp sgt <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  %r = select <4 x i1> %cond, <4 x i32> <i32 0, i32 42, i32 -42, i32 1>, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>
  ret <4 x i32> %r
}

define <2 x i64> @isnonneg_v2i64(<2 x i64> %x) {
; CHECK-LABEL: isnonneg_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psrad $31, %xmm0
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; CHECK-NEXT:    por {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp sgt <2 x i64> %x, <i64 -1, i64 -1>
  %r = select <2 x i1> %cond, <2 x i64> <i64 2342342, i64 12>, <2 x i64> <i64 -1, i64 -1>
  ret <2 x i64> %r
}

define i8 @isneg_i8(i8 %x) {
; CHECK-LABEL: isneg_i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    sarb $7, %al
; CHECK-NEXT:    andb $42, %al
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %cond = icmp slt i8 %x, 0
  %r = select i1 %cond, i8 42, i8 0
  ret i8 %r
}

define i16 @isneg_i16(i16 %x) {
; CHECK-LABEL: isneg_i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movswl %di, %eax
; CHECK-NEXT:    shrl $15, %eax
; CHECK-NEXT:    andl $542, %eax # imm = 0x21E
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
  %cond = icmp slt i16 %x, 0
  %r = select i1 %cond, i16 542, i16 0
  ret i16 %r
}

define i32 @isneg_i32(i32 %x) {
; CHECK-LABEL: isneg_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    sarl $31, %eax
; CHECK-NEXT:    andl $-42, %eax
; CHECK-NEXT:    retq
  %cond = icmp slt i32 %x, 0
  %r = select i1 %cond, i32 -42, i32 0
  ret i32 %r
}

define i64 @isneg_i64(i64 %x) {
; CHECK-LABEL: isneg_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    sarq $63, %rax
; CHECK-NEXT:    andl $2342342, %eax # imm = 0x23BDC6
; CHECK-NEXT:    retq
  %cond = icmp slt i64 %x, 0
  %r = select i1 %cond, i64 2342342, i64 0
  ret i64 %r
}

define <16 x i8> @isneg_v16i8(<16 x i8> %x) {
; CHECK-LABEL: isneg_v16i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pxor %xmm1, %xmm1
; CHECK-NEXT:    pcmpgtb %xmm0, %xmm1
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm1
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %cond = icmp slt <16 x i8> %x, zeroinitializer
  %r = select <16 x i1> %cond, <16 x i8> <i8 12, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42>, <16 x i8> zeroinitializer
  ret <16 x i8> %r
}

define <8 x i16> @isneg_v8i16(<8 x i16> %x) {
; CHECK-LABEL: isneg_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psraw $15, %xmm0
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp slt <8 x i16> %x, zeroinitializer
  %r = select <8 x i1> %cond, <8 x i16> <i16 1, i16 542, i16 542, i16 542, i16 542, i16 542, i16 542, i16 1>, <8 x i16> zeroinitializer
  ret <8 x i16> %r
}

define <4 x i32> @isneg_v4i32(<4 x i32> %x) {
; CHECK-LABEL: isneg_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psrad $31, %xmm0
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp slt <4 x i32> %x, zeroinitializer
  %r = select <4 x i1> %cond, <4 x i32> <i32 0, i32 42, i32 -42, i32 1>, <4 x i32> zeroinitializer
  ret <4 x i32> %r
}

define <2 x i64> @isneg_v2i64(<2 x i64> %x) {
; CHECK-LABEL: isneg_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    psrad $31, %xmm0
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %cond = icmp slt <2 x i64> %x, zeroinitializer
  %r = select <2 x i1> %cond, <2 x i64> <i64 2342342, i64 12>, <2 x i64> zeroinitializer
  ret <2 x i64> %r
}
