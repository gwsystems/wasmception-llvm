; RUN: llc < %s -march=x86 -mattr=+sse2  | FileCheck %s -check-prefix=X32
; RUN: llc < %s -march=x86-64 | FileCheck %s -check-prefix=X64

; Though it is undefined, we want xor undef,undef to produce zero.
define <4 x i32> @test1() nounwind {
	%tmp = xor <4 x i32> undef, undef
	ret <4 x i32> %tmp
        
; X32: test1:
; X32:	xorps	%xmm0, %xmm0
; X32:	ret
}

; Though it is undefined, we want xor undef,undef to produce zero.
define i32 @test2() nounwind{
	%tmp = xor i32 undef, undef
	ret i32 %tmp
; X32: test2:
; X32:	xorl	%eax, %eax
; X32:	ret
}

define i32 @test3(i32 %a, i32 %b) nounwind  {
entry:
        %tmp1not = xor i32 %b, -2
	%tmp3 = and i32 %tmp1not, %a
        %tmp4 = lshr i32 %tmp3, 1
        ret i32 %tmp4
        
; X64: test3:
; X64:	notl	%esi
; X64:	andl	%edi, %esi
; X64:	movl	%esi, %eax
; X64:	shrl	%eax
; X64:	ret

; X32: test3:
; X32: 	movl	8(%esp), %eax
; X32: 	notl	%eax
; X32: 	andl	4(%esp), %eax
; X32: 	shrl	%eax
; X32: 	ret
}

define i32 @test4(i32 %a, i32 %b) nounwind  {
entry:
        br label %bb
bb:
	%b_addr.0 = phi i32 [ %b, %entry ], [ %tmp8, %bb ]
        %a_addr.0 = phi i32 [ %a, %entry ], [ %tmp3, %bb ]
	%tmp3 = xor i32 %a_addr.0, %b_addr.0
        %tmp4not = xor i32 %tmp3, 2147483647
        %tmp6 = and i32 %tmp4not, %b_addr.0
        %tmp8 = shl i32 %tmp6, 1
        %tmp10 = icmp eq i32 %tmp8, 0
	br i1 %tmp10, label %bb12, label %bb
bb12:
	ret i32 %tmp3
        
; X64: test4:
; X64:    notl	%eax
; X64:    andl	{{.*}}%eax
; X32: test4:
; X32:    notl	%edx
; X32:    andl	{{.*}}%edx
}

define i16 @test5(i16 %a, i16 %b) nounwind  {
entry:
        br label %bb
bb:
	%b_addr.0 = phi i16 [ %b, %entry ], [ %tmp8, %bb ]
        %a_addr.0 = phi i16 [ %a, %entry ], [ %tmp3, %bb ]
	%tmp3 = xor i16 %a_addr.0, %b_addr.0
        %tmp4not = xor i16 %tmp3, 32767
        %tmp6 = and i16 %tmp4not, %b_addr.0
        %tmp8 = shl i16 %tmp6, 1
        %tmp10 = icmp eq i16 %tmp8, 0
	br i1 %tmp10, label %bb12, label %bb
bb12:
	ret i16 %tmp3
; X64: test5:
; X64:    notw	%ax
; X64:    andw	{{.*}}%ax
; X32: test5:
; X32:    notw	%dx
; X32:    andw	{{.*}}%dx
}

define i8 @test6(i8 %a, i8 %b) nounwind  {
entry:
        br label %bb
bb:
	%b_addr.0 = phi i8 [ %b, %entry ], [ %tmp8, %bb ]
        %a_addr.0 = phi i8 [ %a, %entry ], [ %tmp3, %bb ]
	%tmp3 = xor i8 %a_addr.0, %b_addr.0
        %tmp4not = xor i8 %tmp3, 127
        %tmp6 = and i8 %tmp4not, %b_addr.0
        %tmp8 = shl i8 %tmp6, 1
        %tmp10 = icmp eq i8 %tmp8, 0
	br i1 %tmp10, label %bb12, label %bb
bb12:
	ret i8 %tmp3
; X64: test6:
; X64:    notb	%al
; X64:    andb	{{.*}}%al
; X32: test6:
; X32:    notb	%dl
; X32:    andb	{{.*}}%dl
}

define i32 @test7(i32 %a, i32 %b) nounwind  {
entry:
        br label %bb
bb:
	%b_addr.0 = phi i32 [ %b, %entry ], [ %tmp8, %bb ]
        %a_addr.0 = phi i32 [ %a, %entry ], [ %tmp3, %bb ]
	%tmp3 = xor i32 %a_addr.0, %b_addr.0
        %tmp4not = xor i32 %tmp3, 2147483646
        %tmp6 = and i32 %tmp4not, %b_addr.0
        %tmp8 = shl i32 %tmp6, 1
        %tmp10 = icmp eq i32 %tmp8, 0
	br i1 %tmp10, label %bb12, label %bb
bb12:
	ret i32 %tmp3
; X64: test7:
; X64:    xorl	$2147483646, %eax
; X64:    andl	{{.*}}%eax
; X32: test7:
; X32:    xorl	$2147483646, %edx
; X32:    andl	{{.*}}%edx
}

