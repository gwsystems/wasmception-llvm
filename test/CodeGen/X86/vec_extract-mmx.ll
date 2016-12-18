; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+mmx,+sse2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+mmx,+sse2 | FileCheck %s --check-prefix=X64

define i32 @test0(<1 x i64>* %v4) nounwind {
; X32-LABEL: test0:
; X32:       # BB#0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-8, %esp
; X32-NEXT:    subl $24, %esp
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    movl (%eax), %ecx
; X32-NEXT:    movl 4(%eax), %eax
; X32-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X32-NEXT:    movl %ecx, (%esp)
; X32-NEXT:    pshufw $238, (%esp), %mm0 # mm0 = mem[2,3,2,3]
; X32-NEXT:    movq %mm0, {{[0-9]+}}(%esp)
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X32-NEXT:    movd %xmm0, %eax
; X32-NEXT:    addl $32, %eax
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: test0:
; X64:       # BB#0: # %entry
; X64-NEXT:    pshufw $238, (%rdi), %mm0 # mm0 = mem[2,3,2,3]
; X64-NEXT:    movd %mm0, %eax
; X64-NEXT:    addl $32, %eax
; X64-NEXT:    retq
entry:
  %v5 = load <1 x i64>, <1 x i64>* %v4, align 8
  %v12 = bitcast <1 x i64> %v5 to <4 x i16>
  %v13 = bitcast <4 x i16> %v12 to x86_mmx
  %v14 = tail call x86_mmx @llvm.x86.sse.pshuf.w(x86_mmx %v13, i8 -18)
  %v15 = bitcast x86_mmx %v14 to <4 x i16>
  %v16 = bitcast <4 x i16> %v15 to <1 x i64>
  %v17 = extractelement <1 x i64> %v16, i32 0
  %v18 = bitcast i64 %v17 to <2 x i32>
  %v19 = extractelement <2 x i32> %v18, i32 0
  %v20 = add i32 %v19, 32
  ret i32 %v20
}

define i32 @test1(i32* nocapture readonly %ptr) nounwind {
; X32-LABEL: test1:
; X32:       # BB#0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-8, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    movd (%eax), %mm0
; X32-NEXT:    pshufw $232, %mm0, %mm0 # mm0 = mm0[0,2,2,3]
; X32-NEXT:    movq %mm0, (%esp)
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X32-NEXT:    movd %xmm0, %eax
; X32-NEXT:    emms
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: test1:
; X64:       # BB#0: # %entry
; X64-NEXT:    movd (%rdi), %mm0
; X64-NEXT:    pshufw $232, %mm0, %mm0 # mm0 = mm0[0,2,2,3]
; X64-NEXT:    movd %mm0, %eax
; X64-NEXT:    emms
; X64-NEXT:    retq
entry:
  %0 = load i32, i32* %ptr, align 4
  %1 = insertelement <2 x i32> undef, i32 %0, i32 0
  %2 = insertelement <2 x i32> %1, i32 0, i32 1
  %3 = bitcast <2 x i32> %2 to x86_mmx
  %4 = bitcast x86_mmx %3 to i64
  %5 = bitcast i64 %4 to <4 x i16>
  %6 = bitcast <4 x i16> %5 to x86_mmx
  %7 = tail call x86_mmx @llvm.x86.sse.pshuf.w(x86_mmx %6, i8 -24)
  %8 = bitcast x86_mmx %7 to <4 x i16>
  %9 = bitcast <4 x i16> %8 to <1 x i64>
  %10 = extractelement <1 x i64> %9, i32 0
  %11 = bitcast i64 %10 to <2 x i32>
  %12 = extractelement <2 x i32> %11, i32 0
  tail call void @llvm.x86.mmx.emms()
  ret i32 %12
}

define i32 @test2(i32* nocapture readonly %ptr) nounwind {
; X32-LABEL: test2:
; X32:       # BB#0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-8, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    pshufw $232, (%eax), %mm0 # mm0 = mem[0,2,2,3]
; X32-NEXT:    movq %mm0, (%esp)
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X32-NEXT:    movd %xmm0, %eax
; X32-NEXT:    emms
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # BB#0: # %entry
; X64-NEXT:    pshufw $232, (%rdi), %mm0 # mm0 = mem[0,2,2,3]
; X64-NEXT:    movd %mm0, %eax
; X64-NEXT:    emms
; X64-NEXT:    retq
entry:
  %0 = bitcast i32* %ptr to x86_mmx*
  %1 = load x86_mmx, x86_mmx* %0, align 8
  %2 = tail call x86_mmx @llvm.x86.sse.pshuf.w(x86_mmx %1, i8 -24)
  %3 = bitcast x86_mmx %2 to <4 x i16>
  %4 = bitcast <4 x i16> %3 to <1 x i64>
  %5 = extractelement <1 x i64> %4, i32 0
  %6 = bitcast i64 %5 to <2 x i32>
  %7 = extractelement <2 x i32> %6, i32 0
  tail call void @llvm.x86.mmx.emms()
  ret i32 %7
}

define i32 @test3(x86_mmx %a) nounwind {
; X32-LABEL: test3:
; X32:       # BB#0:
; X32-NEXT:    movd %mm0, %eax
; X32-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # BB#0:
; X64-NEXT:    movd %mm0, %eax
; X64-NEXT:    retq
  %tmp0 = bitcast x86_mmx %a to <2 x i32>
  %tmp1 = extractelement <2 x i32> %tmp0, i32 0
  ret i32 %tmp1
}

; Verify we don't muck with extractelts from the upper lane.
define i32 @test4(x86_mmx %a) nounwind {
; X32-LABEL: test4:
; X32:       # BB#0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-8, %esp
; X32-NEXT:    subl $8, %esp
; X32-NEXT:    movq %mm0, (%esp)
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,3,0,1]
; X32-NEXT:    movd %xmm0, %eax
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: test4:
; X64:       # BB#0:
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,0,1]
; X64-NEXT:    movd %xmm0, %eax
; X64-NEXT:    retq
  %tmp0 = bitcast x86_mmx %a to <2 x i32>
  %tmp1 = extractelement <2 x i32> %tmp0, i32 1
  ret i32 %tmp1
}

declare x86_mmx @llvm.x86.sse.pshuf.w(x86_mmx, i8)
declare void @llvm.x86.mmx.emms()
