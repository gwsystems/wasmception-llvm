; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s

define i128 @add128(i128 %a, i128 %b) nounwind {
; CHECK-LABEL: add128:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    addq %rdx, %rax
; CHECK-NEXT:    adcq %rcx, %rsi
; CHECK-NEXT:    movq %rsi, %rdx
; CHECK-NEXT:    retq
entry:
  %0 = add i128 %a, %b
  ret i128 %0
}

define void @add128_rmw(i128* %a, i128 %b) nounwind {
; CHECK-LABEL: add128_rmw:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rsi, (%rdi)
; CHECK-NEXT:    adcq %rdx, 8(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = load i128, i128* %a
  %1 = add i128 %0, %b
  store i128 %1, i128* %a
  ret void
}

define void @add128_rmw2(i128 %a, i128* %b) nounwind {
; CHECK-LABEL: add128_rmw2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rdi, (%rdx)
; CHECK-NEXT:    adcq %rsi, 8(%rdx)
; CHECK-NEXT:    retq
entry:
  %0 = load i128, i128* %b
  %1 = add i128 %a, %0
  store i128 %1, i128* %b
  ret void
}

define i256 @add256(i256 %a, i256 %b) nounwind {
; CHECK-LABEL: add256:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    addq %r9, %rsi
; CHECK-NEXT:    adcq {{[0-9]+}}(%rsp), %rdx
; CHECK-NEXT:    adcq {{[0-9]+}}(%rsp), %rcx
; CHECK-NEXT:    adcq {{[0-9]+}}(%rsp), %r8
; CHECK-NEXT:    movq %rdx, 8(%rdi)
; CHECK-NEXT:    movq %rsi, (%rdi)
; CHECK-NEXT:    movq %rcx, 16(%rdi)
; CHECK-NEXT:    movq %r8, 24(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = add i256 %a, %b
  ret i256 %0
}

define void @add256_rmw(i256* %a, i256 %b) nounwind {
; CHECK-LABEL: add256_rmw:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rsi, (%rdi)
; CHECK-NEXT:    adcq %rdx, 8(%rdi)
; CHECK-NEXT:    adcq %rcx, 16(%rdi)
; CHECK-NEXT:    adcq %r8, 24(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = load i256, i256* %a
  %1 = add i256 %0, %b
  store i256 %1, i256* %a
  ret void
}

define void @add256_rmw2(i256 %a, i256* %b) nounwind {
; CHECK-LABEL: add256_rmw2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rdi, (%r8)
; CHECK-NEXT:    adcq %rsi, 8(%r8)
; CHECK-NEXT:    adcq %rdx, 16(%r8)
; CHECK-NEXT:    adcq %rcx, 24(%r8)
; CHECK-NEXT:    retq
entry:
  %0 = load i256, i256* %b
  %1 = add i256 %a, %0
  store i256 %1, i256* %b
  ret void
}

define void @a(i64* nocapture %s, i64* nocapture %t, i64 %a, i64 %b, i64 %c) nounwind {
; CHECK-LABEL: a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rcx, %rdx
; CHECK-NEXT:    adcq $0, %r8
; CHECK-NEXT:    movq %r8, (%rdi)
; CHECK-NEXT:    movq %rdx, (%rsi)
; CHECK-NEXT:    retq
entry:
 %0 = zext i64 %a to i128
 %1 = zext i64 %b to i128
 %2 = add i128 %1, %0
 %3 = zext i64 %c to i128
 %4 = shl i128 %3, 64
 %5 = add i128 %4, %2
 %6 = lshr i128 %5, 64
 %7 = trunc i128 %6 to i64
 store i64 %7, i64* %s, align 8
 %8 = trunc i128 %2 to i64
 store i64 %8, i64* %t, align 8
 ret void
}

define void @b(i32* nocapture %r, i64 %a, i64 %b, i32 %c) nounwind {
; CHECK-LABEL: b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rdx, %rsi
; CHECK-NEXT:    adcl $0, %ecx
; CHECK-NEXT:    movl %ecx, (%rdi)
; CHECK-NEXT:    retq
entry:
 %0 = zext i64 %a to i128
 %1 = zext i64 %b to i128
 %2 = zext i32 %c to i128
 %3 = add i128 %1, %0
 %4 = lshr i128 %3, 64
 %5 = add i128 %4, %2
 %6 = trunc i128 %5 to i32
 store i32 %6, i32* %r, align 4
 ret void
}

define void @c(i16* nocapture %r, i64 %a, i64 %b, i16 %c) nounwind {
; CHECK-LABEL: c:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rdx, %rsi
; CHECK-NEXT:    adcw $0, %cx
; CHECK-NEXT:    movw %cx, (%rdi)
; CHECK-NEXT:    retq
entry:
 %0 = zext i64 %a to i128
 %1 = zext i64 %b to i128
 %2 = zext i16 %c to i128
 %3 = add i128 %1, %0
 %4 = lshr i128 %3, 64
 %5 = add i128 %4, %2
 %6 = trunc i128 %5 to i16
 store i16 %6, i16* %r, align 4
 ret void
}

define void @d(i8* nocapture %r, i64 %a, i64 %b, i8 %c) nounwind {
; CHECK-LABEL: d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addq %rdx, %rsi
; CHECK-NEXT:    adcb $0, %cl
; CHECK-NEXT:    movb %cl, (%rdi)
; CHECK-NEXT:    retq
entry:
 %0 = zext i64 %a to i128
 %1 = zext i64 %b to i128
 %2 = zext i8 %c to i128
 %3 = add i128 %1, %0
 %4 = lshr i128 %3, 64
 %5 = add i128 %4, %2
 %6 = trunc i128 %5 to i8
 store i8 %6, i8* %r, align 4
 ret void
}

define i8 @e(i32* nocapture %a, i32 %b) nounwind {
; CHECK-LABEL: e:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $esi killed $esi def $rsi
; CHECK-NEXT:    movl (%rdi), %ecx
; CHECK-NEXT:    leal (%rsi,%rcx), %edx
; CHECK-NEXT:    addl %esi, %edx
; CHECK-NEXT:    setb %al
; CHECK-NEXT:    addl %esi, %ecx
; CHECK-NEXT:    movl %edx, (%rdi)
; CHECK-NEXT:    adcb $0, %al
; CHECK-NEXT:    retq
  %1 = load i32, i32* %a, align 4
  %2 = add i32 %1, %b
  %3 = icmp ult i32 %2, %b
  %4 = zext i1 %3 to i8
  %5 = add i32 %2, %b
  store i32 %5, i32* %a, align 4
  %6 = icmp ult i32 %5, %b
  %7 = zext i1 %6 to i8
  %8 = add nuw nsw i8 %7, %4
  ret i8 %8
}

%scalar = type { [4 x i64] }

define %scalar @pr31719(%scalar* nocapture readonly %this, %scalar %arg.b) {
; CHECK-LABEL: pr31719:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    addq (%rsi), %rdx
; CHECK-NEXT:    adcq 8(%rsi), %rcx
; CHECK-NEXT:    adcq 16(%rsi), %r8
; CHECK-NEXT:    adcq 24(%rsi), %r9
; CHECK-NEXT:    movq %rdx, (%rdi)
; CHECK-NEXT:    movq %rcx, 8(%rdi)
; CHECK-NEXT:    movq %r8, 16(%rdi)
; CHECK-NEXT:    movq %r9, 24(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = extractvalue %scalar %arg.b, 0
  %.elt = extractvalue [4 x i64] %0, 0
  %.elt24 = extractvalue [4 x i64] %0, 1
  %.elt26 = extractvalue [4 x i64] %0, 2
  %.elt28 = extractvalue [4 x i64] %0, 3
  %1 = getelementptr inbounds %scalar , %scalar* %this, i64 0, i32 0, i64 0
  %2 = load i64, i64* %1, align 8
  %3 = zext i64 %2 to i128
  %4 = zext i64 %.elt to i128
  %5 = add nuw nsw i128 %3, %4
  %6 = trunc i128 %5 to i64
  %7 = lshr i128 %5, 64
  %8 = getelementptr inbounds %scalar , %scalar * %this, i64 0, i32 0, i64 1
  %9 = load i64, i64* %8, align 8
  %10 = zext i64 %9 to i128
  %11 = zext i64 %.elt24 to i128
  %12 = add nuw nsw i128 %10, %11
  %13 = add nuw nsw i128 %12, %7
  %14 = trunc i128 %13 to i64
  %15 = lshr i128 %13, 64
  %16 = getelementptr inbounds %scalar , %scalar* %this, i64 0, i32 0, i64 2
  %17 = load i64, i64* %16, align 8
  %18 = zext i64 %17 to i128
  %19 = zext i64 %.elt26 to i128
  %20 = add nuw nsw i128 %18, %19
  %21 = add nuw nsw i128 %20, %15
  %22 = trunc i128 %21 to i64
  %23 = lshr i128 %21, 64
  %24 = getelementptr inbounds %scalar , %scalar* %this, i64 0, i32 0, i64 3
  %25 = load i64, i64* %24, align 8
  %26 = zext i64 %25 to i128
  %27 = zext i64 %.elt28 to i128
  %28 = add nuw nsw i128 %26, %27
  %29 = add nuw nsw i128 %28, %23
  %30 = trunc i128 %29 to i64
  %31 = insertvalue [4 x i64] undef, i64 %6, 0
  %32 = insertvalue [4 x i64] %31, i64 %14, 1
  %33 = insertvalue [4 x i64] %32, i64 %22, 2
  %34 = insertvalue [4 x i64] %33, i64 %30, 3
  %35 = insertvalue %scalar undef, [4 x i64] %34, 0
  ret %scalar %35
}

%accumulator= type { i64, i64, i32 }

define void @muladd(%accumulator* nocapture %this, i64 %arg.a, i64 %arg.b) {
; CHECK-LABEL: muladd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdx, %rax
; CHECK-NEXT:    mulq %rsi
; CHECK-NEXT:    addq %rax, (%rdi)
; CHECK-NEXT:    adcq %rdx, 8(%rdi)
; CHECK-NEXT:    adcl $0, 16(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = zext i64 %arg.a to i128
  %1 = zext i64 %arg.b to i128
  %2 = mul nuw i128 %1, %0
  %3 = getelementptr inbounds %accumulator, %accumulator* %this, i64 0, i32 0
  %4 = load i64, i64* %3, align 8
  %5 = zext i64 %4 to i128
  %6 = add i128 %5, %2
  %7 = trunc i128 %6 to i64
  store i64 %7, i64* %3, align 8
  %8 = lshr i128 %6, 64
  %9 = getelementptr inbounds %accumulator, %accumulator* %this, i64 0, i32 1
  %10 = load i64, i64* %9, align 8
  %11 = zext i64 %10 to i128
  %12 = add nuw nsw i128 %8, %11
  %13 = trunc i128 %12 to i64
  store i64 %13, i64* %9, align 8
  %14 = lshr i128 %12, 64
  %15 = getelementptr inbounds %accumulator, %accumulator* %this, i64 0, i32 2
  %16 = load i32, i32* %15, align 4
  %17 = zext i32 %16 to i128
  %18 = add nuw nsw i128 %14, %17
  %19 = trunc i128 %18 to i32
  store i32 %19, i32* %15, align 4
  ret void
}

define i64 @shiftadd(i64 %a, i64 %b, i64 %c, i64 %d) {
; CHECK-LABEL: shiftadd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdx, %rax
; CHECK-NEXT:    addq %rsi, %rdi
; CHECK-NEXT:    adcq %rcx, %rax
; CHECK-NEXT:    retq
entry:
  %0 = zext i64 %a to i128
  %1 = zext i64 %b to i128
  %2 = add i128 %0, %1
  %3 = lshr i128 %2, 64
  %4 = trunc i128 %3 to i64
  %5 = add i64 %c, %d
  %6 = add i64 %4, %5
  ret i64 %6
}

%S = type { [4 x i64] }

define %S @readd(%S* nocapture readonly %this, %S %arg.b) {
; CHECK-LABEL: readd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    addq (%rsi), %rdx
; CHECK-NEXT:    movq 8(%rsi), %r11
; CHECK-NEXT:    adcq $0, %r11
; CHECK-NEXT:    setb %r10b
; CHECK-NEXT:    movzbl %r10b, %edi
; CHECK-NEXT:    addq %rcx, %r11
; CHECK-NEXT:    adcq 16(%rsi), %rdi
; CHECK-NEXT:    setb %cl
; CHECK-NEXT:    movzbl %cl, %ecx
; CHECK-NEXT:    addq %r8, %rdi
; CHECK-NEXT:    adcq 24(%rsi), %rcx
; CHECK-NEXT:    addq %r9, %rcx
; CHECK-NEXT:    movq %rdx, (%rax)
; CHECK-NEXT:    movq %r11, 8(%rax)
; CHECK-NEXT:    movq %rdi, 16(%rax)
; CHECK-NEXT:    movq %rcx, 24(%rax)
; CHECK-NEXT:    retq
entry:
  %0 = extractvalue %S %arg.b, 0
  %.elt6 = extractvalue [4 x i64] %0, 1
  %.elt8 = extractvalue [4 x i64] %0, 2
  %.elt10 = extractvalue [4 x i64] %0, 3
  %.elt = extractvalue [4 x i64] %0, 0
  %1 = getelementptr inbounds %S, %S* %this, i64 0, i32 0, i64 0
  %2 = load i64, i64* %1, align 8
  %3 = zext i64 %2 to i128
  %4 = zext i64 %.elt to i128
  %5 = add nuw nsw i128 %3, %4
  %6 = trunc i128 %5 to i64
  %7 = lshr i128 %5, 64
  %8 = getelementptr inbounds %S, %S* %this, i64 0, i32 0, i64 1
  %9 = load i64, i64* %8, align 8
  %10 = zext i64 %9 to i128
  %11 = add nuw nsw i128 %7, %10
  %12 = zext i64 %.elt6 to i128
  %13 = add nuw nsw i128 %11, %12
  %14 = trunc i128 %13 to i64
  %15 = lshr i128 %13, 64
  %16 = getelementptr inbounds %S, %S* %this, i64 0, i32 0, i64 2
  %17 = load i64, i64* %16, align 8
  %18 = zext i64 %17 to i128
  %19 = add nuw nsw i128 %15, %18
  %20 = zext i64 %.elt8 to i128
  %21 = add nuw nsw i128 %19, %20
  %22 = lshr i128 %21, 64
  %23 = trunc i128 %21 to i64
  %24 = getelementptr inbounds %S, %S* %this, i64 0,i32 0, i64 3
  %25 = load i64, i64* %24, align 8
  %26 = zext i64 %25 to i128
  %27 = add nuw nsw i128 %22, %26
  %28 = zext i64 %.elt10 to i128
  %29 = add nuw nsw i128 %27, %28
  %30 = trunc i128 %29 to i64
  %31 = insertvalue [4 x i64] undef, i64 %6, 0
  %32 = insertvalue [4 x i64] %31, i64 %14, 1
  %33 = insertvalue [4 x i64] %32, i64 %23, 2
  %34 = insertvalue [4 x i64] %33, i64 %30, 3
  %35 = insertvalue %S undef, [4 x i64] %34, 0
  ret %S %35
}

define i128 @addcarry1_not(i128 %n) {
; CHECK-LABEL: addcarry1_not:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    negq %rax
; CHECK-NEXT:    sbbq %rsi, %rdx
; CHECK-NEXT:    retq
  %1 = xor i128 %n, -1
  %2 = add i128 %1, 1
  ret i128 %2
}

define i128 @addcarry_to_subcarry(i64 %a, i64 %b) {
; CHECK-LABEL: addcarry_to_subcarry:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    notq %rsi
; CHECK-NEXT:    movb $1, %cl
; CHECK-NEXT:    addb $-1, %cl
; CHECK-NEXT:    movq %rdi, %rcx
; CHECK-NEXT:    adcq %rsi, %rcx
; CHECK-NEXT:    adcq $0, %rax
; CHECK-NEXT:    setb %cl
; CHECK-NEXT:    movzbl %cl, %edx
; CHECK-NEXT:    addq %rsi, %rax
; CHECK-NEXT:    adcq $0, %rdx
; CHECK-NEXT:    retq
  %notb = xor i64 %b, -1
  %notb128 = zext i64 %notb to i128
  %a128 = zext i64 %a to i128
  %sum1 = add i128 %a128, 1
  %sub1 = add i128 %sum1, %notb128
  %hi = lshr i128 %sub1, 64
  %sum2 = add i128 %hi, %a128
  %sub2 = add i128 %sum2, %notb128
  ret i128 %sub2
}
