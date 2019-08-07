; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X64

; widening shuffle v3float and then a add
define void @shuf(<3 x float>* %dst.addr, <3 x float> %src1,<3 x float> %src2) nounwind {
; X86-LABEL: shuf:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addps %xmm1, %xmm0
; X86-NEXT:    extractps $2, %xmm0, 8(%eax)
; X86-NEXT:    extractps $1, %xmm0, 4(%eax)
; X86-NEXT:    movss %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shuf:
; X64:       # %bb.0: # %entry
; X64-NEXT:    addps %xmm1, %xmm0
; X64-NEXT:    extractps $2, %xmm0, 8(%rdi)
; X64-NEXT:    movlps %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
	%x = shufflevector <3 x float> %src1, <3 x float> %src2, <3 x i32> < i32 0, i32 1, i32 2>
	%val = fadd <3 x float> %x, %src2
	store <3 x float> %val, <3 x float>* %dst.addr
	ret void
}


; widening shuffle v3float with a different mask and then a add
define void @shuf2(<3 x float>* %dst.addr, <3 x float> %src1,<3 x float> %src2) nounwind {
; X86-LABEL: shuf2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; X86-NEXT:    addps %xmm1, %xmm0
; X86-NEXT:    extractps $2, %xmm0, 8(%eax)
; X86-NEXT:    extractps $1, %xmm0, 4(%eax)
; X86-NEXT:    movss %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shuf2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; X64-NEXT:    addps %xmm1, %xmm0
; X64-NEXT:    extractps $2, %xmm0, 8(%rdi)
; X64-NEXT:    movlps %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
	%x = shufflevector <3 x float> %src1, <3 x float> %src2, <3 x i32> < i32 0, i32 4, i32 2>
	%val = fadd <3 x float> %x, %src2
	store <3 x float> %val, <3 x float>* %dst.addr
	ret void
}

; Example of when widening a v3float operation causes the DAG to replace a node
; with the operation that we are currently widening, i.e. when replacing
; opA with opB, the DAG will produce new operations with opA.
define void @shuf3(<4 x float> %tmp10, <4 x float> %vecinit15, <4 x float>* %dst) nounwind {
; X86-LABEL: shuf3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0,0,0]
; X86-NEXT:    movaps %xmm1, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shuf3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0,0,0]
; X64-NEXT:    movaps %xmm1, (%rdi)
; X64-NEXT:    retq
entry:
  %shuffle.i.i.i12 = shufflevector <4 x float> %tmp10, <4 x float> %vecinit15, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  %tmp25.i.i = shufflevector <4 x float> %shuffle.i.i.i12, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %tmp1.i.i = shufflevector <3 x float> %tmp25.i.i, <3 x float> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %tmp3.i13 = shufflevector <4 x float> %tmp1.i.i, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2> ; <<3 x float>>
  %tmp6.i14 = shufflevector <3 x float> %tmp3.i13, <3 x float> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %tmp97.i = shufflevector <4 x float> %tmp6.i14, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %tmp2.i18 = shufflevector <3 x float> %tmp97.i, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 2>
  %t5 = bitcast <4 x float> %tmp2.i18 to <4 x i32>
  %shr.i.i19 = lshr <4 x i32> %t5, <i32 19, i32 19, i32 19, i32 19>
  %and.i.i20 = and <4 x i32> %shr.i.i19, <i32 4080, i32 4080, i32 4080, i32 4080>
  %shuffle.i.i.i21 = shufflevector <4 x float> %tmp2.i18, <4 x float> undef, <4 x i32> <i32 2, i32 3, i32 2, i32 3>
  store <4 x float> %shuffle.i.i.i21, <4 x float>* %dst
  ret void
}

; PR10421: make sure we correctly handle extreme widening with CONCAT_VECTORS
define <8 x i8> @shuf4(<4 x i8> %a, <4 x i8> %b) nounwind readnone {
; X86-LABEL: shuf4:
; X86:       # %bb.0:
; X86-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X86-NEXT:    retl
;
; X64-LABEL: shuf4:
; X64:       # %bb.0:
; X64-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X64-NEXT:    retq
  %vshuf = shufflevector <4 x i8> %a, <4 x i8> %b, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i8> %vshuf
}

; PR11389: another CONCAT_VECTORS case
define void @shuf5(<8 x i8>* %p) nounwind {
; X86-LABEL: shuf5:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    movsd %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shuf5:
; X64:       # %bb.0:
; X64-NEXT:    movabsq $2387225703656530209, %rax # imm = 0x2121212121212121
; X64-NEXT:    movq %rax, (%rdi)
; X64-NEXT:    retq
  %v = shufflevector <2 x i8> <i8 4, i8 33>, <2 x i8> undef, <8 x i32> <i32 1, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  store <8 x i8> %v, <8 x i8>* %p, align 8
  ret void
}
