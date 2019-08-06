; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-linux -mcpu=corei7 | FileCheck %s
; RUN: opt -instsimplify -disable-output < %s

define <8 x i32*> @SHUFF0(<4 x i32*> %ptrv) nounwind {
; CHECK-LABEL: SHUFF0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[2,3,1,2]
; CHECK-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,1,1,1]
; CHECK-NEXT:    movdqa %xmm2, %xmm0
; CHECK-NEXT:    retl
entry:
  %G = shufflevector <4 x i32*> %ptrv, <4 x i32*> %ptrv, <8 x i32> <i32 2, i32 7, i32 1, i32 2, i32 4, i32 5, i32 1, i32 1>
  ret <8 x i32*> %G
}

define <4 x i32*> @SHUFF1(<4 x i32*> %ptrv) nounwind {
; CHECK-LABEL: SHUFF1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,3,2]
; CHECK-NEXT:    retl
entry:
  %G = shufflevector <4 x i32*> %ptrv, <4 x i32*> %ptrv, <4 x i32> <i32 2, i32 7, i32 7, i32 2>
  ret <4 x i32*> %G
}

define <4 x i8*> @SHUFF3(<4 x i8*> %ptrv) nounwind {
; CHECK-LABEL: SHUFF3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,1,1,2]
; CHECK-NEXT:    retl
entry:
  %G = shufflevector <4 x i8*> %ptrv, <4 x i8*> undef, <4 x i32> <i32 2, i32 7, i32 1, i32 2>
  ret <4 x i8*> %G
}

define <4 x i8*> @LOAD0(<4 x i8*>* %p) nounwind {
; CHECK-LABEL: LOAD0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm0
; CHECK-NEXT:    retl
entry:
  %G = load <4 x i8*>, <4 x i8*>* %p
  ret <4 x i8*> %G
}

define <4 x i8*> @LOAD1(<4 x i8*>* %p) nounwind {
; CHECK-LABEL: LOAD1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movdqa (%eax), %xmm0
; CHECK-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[3,1,0,3]
; CHECK-NEXT:    movdqa %xmm1, (%eax)
; CHECK-NEXT:    retl
entry:
  %G = load <4 x i8*>, <4 x i8*>* %p
  %T = shufflevector <4 x i8*> %G, <4 x i8*> %G, <4 x i32> <i32 7, i32 1, i32 4, i32 3>
  store <4 x i8*> %T, <4 x i8*>* %p
  ret <4 x i8*> %G
}

define <4 x i8*> @LOAD2(<4 x i8*>* %p) nounwind {
; CHECK-LABEL: LOAD2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $28, %esp
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm0
; CHECK-NEXT:    movaps %xmm0, (%esp)
; CHECK-NEXT:    addl $28, %esp
; CHECK-NEXT:    retl
entry:
  %I = alloca <4 x i8*>
  %G = load <4 x i8*>, <4 x i8*>* %p
  store <4 x i8*> %G, <4 x i8*>* %I
  %Z = load <4 x i8*>, <4 x i8*>* %I
  ret <4 x i8*> %Z
}

define <4 x i32> @INT2PTR0(<4 x i8*>* %p) nounwind {
; CHECK-LABEL: INT2PTR0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm0
; CHECK-NEXT:    retl
entry:
  %G = load <4 x i8*>, <4 x i8*>* %p
  %K = ptrtoint <4 x i8*> %G to <4 x i32>
  ret <4 x i32> %K
}

define <4 x i32*> @INT2PTR1(<4 x i8>* %p) nounwind {
; CHECK-LABEL: INT2PTR1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; CHECK-NEXT:    retl
entry:
  %G = load <4 x i8>, <4 x i8>* %p
  %K = inttoptr <4 x i8> %G to <4 x i32*>
  ret <4 x i32*> %K
}

define <4 x i32*> @BITCAST0(<4 x i8*>* %p) nounwind {
; CHECK-LABEL: BITCAST0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm0
; CHECK-NEXT:    retl
entry:
  %G = load <4 x i8*>, <4 x i8*>* %p
  %T = bitcast <4 x i8*> %G to <4 x i32*>
  ret <4 x i32*> %T
}

define <2 x i32*> @BITCAST1(<2 x i8*>* %p) nounwind {
; CHECK-LABEL: BITCAST1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    pmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; CHECK-NEXT:    retl
entry:
  %G = load <2 x i8*>, <2 x i8*>* %p
  %T = bitcast <2 x i8*> %G to <2 x i32*>
  ret <2 x i32*> %T
}

define <4 x i32> @ICMP0(<4 x i8*>* %p0, <4 x i8*>* %p1) nounwind {
; CHECK-LABEL: ICMP0:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movdqa (%ecx), %xmm0
; CHECK-NEXT:    pcmpgtd (%eax), %xmm0
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = [9,8,7,6]
; CHECK-NEXT:    blendvps %xmm0, {{\.LCPI.*}}, %xmm1
; CHECK-NEXT:    movaps %xmm1, %xmm0
; CHECK-NEXT:    retl
entry:
  %g0 = load <4 x i8*>, <4 x i8*>* %p0
  %g1 = load <4 x i8*>, <4 x i8*>* %p1
  %k = icmp sgt <4 x i8*> %g0, %g1
  %j = select <4 x i1> %k, <4 x i32> <i32 0, i32 1, i32 2, i32 4>, <4 x i32> <i32 9, i32 8, i32 7, i32 6>
  ret <4 x i32> %j
}

define <4 x i32> @ICMP1(<4 x i8*>* %p0, <4 x i8*>* %p1) nounwind {
; CHECK-LABEL: ICMP1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movdqa (%ecx), %xmm0
; CHECK-NEXT:    pcmpeqd (%eax), %xmm0
; CHECK-NEXT:    movaps {{.*#+}} xmm1 = [9,8,7,6]
; CHECK-NEXT:    blendvps %xmm0, {{\.LCPI.*}}, %xmm1
; CHECK-NEXT:    movaps %xmm1, %xmm0
; CHECK-NEXT:    retl
entry:
  %g0 = load <4 x i8*>, <4 x i8*>* %p0
  %g1 = load <4 x i8*>, <4 x i8*>* %p1
  %k = icmp eq <4 x i8*> %g0, %g1
  %j = select <4 x i1> %k, <4 x i32> <i32 0, i32 1, i32 2, i32 4>, <4 x i32> <i32 9, i32 8, i32 7, i32 6>
  ret <4 x i32> %j
}

