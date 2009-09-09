; RUN: llc < %s -asm-verbose=0 -mtriple=i686-unknown-linux-gnu -march=x86 -relocation-model=static -code-model=small | FileCheck %s -check-prefix=LINUX-32-STATIC
; RUN: llc < %s -asm-verbose=0 -mtriple=i686-unknown-linux-gnu -march=x86 -relocation-model=static -code-model=small | FileCheck %s -check-prefix=LINUX-32-PIC

; RUN: llc < %s -asm-verbose=0 -mtriple=x86_64-unknown-linux-gnu -march=x86-64 -relocation-model=static -code-model=small | FileCheck %s -check-prefix=LINUX-64-STATIC
; RUN: llc < %s -asm-verbose=0 -mtriple=x86_64-unknown-linux-gnu -march=x86-64 -relocation-model=pic -code-model=small | FileCheck %s -check-prefix=LINUX-64-PIC

; RUN: llc < %s -asm-verbose=0 -mtriple=i686-apple-darwin -march=x86 -relocation-model=static -code-model=small | FileCheck %s -check-prefix=DARWIN-32-STATIC
; RUN: llc < %s -asm-verbose=0 -mtriple=i686-apple-darwin -march=x86 -relocation-model=dynamic-no-pic -code-model=small | FileCheck %s -check-prefix=DARWIN-32-DYNAMIC
; RUN: llc < %s -asm-verbose=0 -mtriple=i686-apple-darwin -march=x86 -relocation-model=pic -code-model=small | FileCheck %s -check-prefix=DARWIN-32-PIC

; RUN: llc < %s -asm-verbose=0 -mtriple=x86_64-apple-darwin -march=x86-64 -relocation-model=static -code-model=small | FileCheck %s -check-prefix=DARWIN-64-STATIC
; RUN: llc < %s -asm-verbose=0 -mtriple=x86_64-apple-darwin -march=x86-64 -relocation-model=dynamic-no-pic -code-model=small | FileCheck %s -check-prefix=DARWIN-64-DYNAMIC
; RUN: llc < %s -asm-verbose=0 -mtriple=x86_64-apple-darwin -march=x86-64 -relocation-model=pic -code-model=small | FileCheck %s -check-prefix=DARWIN-64-PIC

@src = external global [131072 x i32]
@dst = external global [131072 x i32]
@xsrc = external global [32 x i32]
@xdst = external global [32 x i32]
@ptr = external global i32*
@dsrc = global [131072 x i32] zeroinitializer, align 32
@ddst = global [131072 x i32] zeroinitializer, align 32
@dptr = global i32* null
@lsrc = internal global [131072 x i32] zeroinitializer
@ldst = internal global [131072 x i32] zeroinitializer
@lptr = internal global i32* null
@ifunc = external global void ()*
@difunc = global void ()* null
@lifunc = internal global void ()* null
@lxsrc = internal global [32 x i32] zeroinitializer, align 32
@lxdst = internal global [32 x i32] zeroinitializer, align 32
@dxsrc = global [32 x i32] zeroinitializer, align 32
@dxdst = global [32 x i32] zeroinitializer, align 32

define void @foo00() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 0), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 0), align 4
	ret void

; LINUX-64-STATIC: foo00:
; LINUX-64-STATIC: movl	src(%rip), %eax
; LINUX-64-STATIC: movl	%eax, dst
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo00:
; LINUX-32-STATIC: 	movl	src, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dst
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo00:
; LINUX-32-PIC: 	movl	src, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dst
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo00:
; DARWIN-32-STATIC: 	movl	_src, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dst
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo00:
; DARWIN-32-PIC: 	call	L1$pb
; DARWIN-32-PIC-NEXT: L1$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L1$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L1$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @fxo00() nounwind {
entry:
	%0 = load i32* getelementptr ([32 x i32]* @xsrc, i32 0, i64 0), align 4
	store i32 %0, i32* getelementptr ([32 x i32]* @xdst, i32 0, i64 0), align 4
	ret void

; LINUX-64-STATIC: fxo00:
; LINUX-64-STATIC: movl	xsrc(%rip), %eax
; LINUX-64-STATIC: movl	%eax, xdst
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: fxo00:
; LINUX-32-STATIC: 	movl	xsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, xdst
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: fxo00:
; LINUX-32-PIC: 	movl	xsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, xdst
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: fxo00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	xdst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _fxo00:
; DARWIN-32-STATIC: 	movl	_xsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _xdst
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _fxo00:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _fxo00:
; DARWIN-32-PIC: 	call	L2$pb
; DARWIN-32-PIC-NEXT: L2$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L2$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L2$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _fxo00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _fxo00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _fxo00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo01() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @dst, i32 0, i32 0), i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: foo01:
; LINUX-64-STATIC: movq	$dst, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo01:
; LINUX-32-STATIC: 	movl	$dst, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo01:
; LINUX-32-PIC: 	movl	$dst, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo01:
; DARWIN-32-STATIC: 	movl	$_dst, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo01:
; DARWIN-32-DYNAMIC: 	movl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo01:
; DARWIN-32-PIC: 	call	L3$pb
; DARWIN-32-PIC-NEXT: L3$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L3$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L3$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @fxo01() nounwind {
entry:
	store i32* getelementptr ([32 x i32]* @xdst, i32 0, i32 0), i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: fxo01:
; LINUX-64-STATIC: movq	$xdst, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: fxo01:
; LINUX-32-STATIC: 	movl	$xdst, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: fxo01:
; LINUX-32-PIC: 	movl	$xdst, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: fxo01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _fxo01:
; DARWIN-32-STATIC: 	movl	$_xdst, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _fxo01:
; DARWIN-32-DYNAMIC: 	movl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _fxo01:
; DARWIN-32-PIC: 	call	L4$pb
; DARWIN-32-PIC-NEXT: L4$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L4$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L4$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _fxo01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _fxo01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _fxo01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 0), align 4
	store i32 %1, i32* %0, align 4
	ret void
; LINUX-64-STATIC: foo02:
; LINUX-64-STATIC: movl    src(%rip), %
; LINUX-64-STATIC: movq    ptr(%rip), %
; LINUX-64-STATIC: movl
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo02:
; LINUX-32-STATIC: 	movl	src, %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo02:
; LINUX-32-PIC: 	movl	src, %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo02:
; DARWIN-32-STATIC: 	movl	_src, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo02:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo02:
; DARWIN-32-PIC: 	call	L5$pb
; DARWIN-32-PIC-NEXT: L5$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L5$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L5$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @fxo02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = load i32* getelementptr ([32 x i32]* @xsrc, i32 0, i64 0), align 4
	store i32 %1, i32* %0, align 4
; LINUX-64-STATIC: fxo02:
; LINUX-64-STATIC: movl    xsrc(%rip), %
; LINUX-64-STATIC: movq    ptr(%rip), %
; LINUX-64-STATIC: movl
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: fxo02:
; LINUX-32-STATIC: 	movl	xsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-STATIC-NEXT: 	ret
	ret void

; LINUX-32-PIC: fxo02:
; LINUX-32-PIC: 	movl	xsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: fxo02:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _fxo02:
; DARWIN-32-STATIC: 	movl	_xsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _fxo02:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _fxo02:
; DARWIN-32-PIC: 	call	L6$pb
; DARWIN-32-PIC-NEXT: L6$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L6$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L6$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _fxo02:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _fxo02:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _fxo02:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo03() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 0), align 32
	store i32 %0, i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 0), align 32
	ret void
; LINUX-64-STATIC: foo03:
; LINUX-64-STATIC: movl    dsrc(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ddst
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo03:
; LINUX-32-STATIC: 	movl	dsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ddst
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo03:
; LINUX-32-PIC: 	movl	dsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ddst
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo03:
; DARWIN-32-STATIC: 	movl	_dsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ddst
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo03:
; DARWIN-32-DYNAMIC: 	movl	_dsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ddst
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo03:
; DARWIN-32-PIC: 	call	L7$pb
; DARWIN-32-PIC-NEXT: L7$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_dsrc-L7$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _ddst-L7$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo03:
; DARWIN-64-STATIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ddst(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo03:
; DARWIN-64-DYNAMIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ddst(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo03:
; DARWIN-64-PIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ddst(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo04() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ddst, i32 0, i32 0), i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: foo04:
; LINUX-64-STATIC: movq    $ddst, dptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo04:
; LINUX-32-STATIC: 	movl	$ddst, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo04:
; LINUX-32-PIC: 	movl	$ddst, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo04:
; DARWIN-32-STATIC: 	movl	$_ddst, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo04:
; DARWIN-32-PIC: 	call	L8$pb
; DARWIN-32-PIC-NEXT: L8$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ddst-L8$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L8$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo05() nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 0), align 32
	store i32 %1, i32* %0, align 4
	ret void
; LINUX-64-STATIC: foo05:
; LINUX-64-STATIC: movl    dsrc(%rip), %
; LINUX-64-STATIC: movq    dptr(%rip), %
; LINUX-64-STATIC: movl
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo05:
; LINUX-32-STATIC: 	movl	dsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo05:
; LINUX-32-PIC: 	movl	dsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo05:
; DARWIN-32-STATIC: 	movl	_dsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo05:
; DARWIN-32-DYNAMIC: 	movl	_dsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo05:
; DARWIN-32-PIC: 	call	L9$pb
; DARWIN-32-PIC-NEXT: L9$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_dsrc-L9$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L9$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo05:
; DARWIN-64-STATIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo05:
; DARWIN-64-DYNAMIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo05:
; DARWIN-64-PIC: 	movl	_dsrc(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo06() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 0), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 0), align 4
	ret void
; LINUX-64-STATIC: foo06:
; LINUX-64-STATIC: movl    lsrc(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ldst(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo06:
; LINUX-32-STATIC: 	movl	lsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ldst
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo06:
; LINUX-32-PIC: 	movl	lsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ldst
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo06:
; LINUX-64-PIC: 	movl	lsrc(%rip), %eax
; LINUX-64-PIC-NEXT: 	movl	%eax, ldst(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo06:
; DARWIN-32-STATIC: 	movl	_lsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ldst
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo06:
; DARWIN-32-DYNAMIC: 	movl	_lsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ldst
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo06:
; DARWIN-32-PIC: 	call	L10$pb
; DARWIN-32-PIC-NEXT: L10$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_lsrc-L10$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _ldst-L10$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo06:
; DARWIN-64-STATIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ldst(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo06:
; DARWIN-64-DYNAMIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ldst(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo06:
; DARWIN-64-PIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ldst(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo07() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ldst, i32 0, i32 0), i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: foo07:
; LINUX-64-STATIC: movq    $ldst, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo07:
; LINUX-32-STATIC: 	movl	$ldst, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo07:
; LINUX-32-PIC: 	movl	$ldst, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo07:
; DARWIN-32-STATIC: 	movl	$_ldst, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo07:
; DARWIN-32-PIC: 	call	L11$pb
; DARWIN-32-PIC-NEXT: L11$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ldst-L11$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L11$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @foo08() nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 0), align 4
	store i32 %1, i32* %0, align 4
	ret void
; LINUX-64-STATIC: foo08:
; LINUX-64-STATIC: movl    lsrc(%rip), %
; LINUX-64-STATIC: movq    lptr(%rip), %
; LINUX-64-STATIC: movl
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: foo08:
; LINUX-32-STATIC: 	movl	lsrc, %eax
; LINUX-32-STATIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: foo08:
; LINUX-32-PIC: 	movl	lsrc, %eax
; LINUX-32-PIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, (%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: foo08:
; LINUX-64-PIC: 	movl	lsrc(%rip), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _foo08:
; DARWIN-32-STATIC: 	movl	_lsrc, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _foo08:
; DARWIN-32-DYNAMIC: 	movl	_lsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _foo08:
; DARWIN-32-PIC: 	call	L12$pb
; DARWIN-32-PIC-NEXT: L12$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_lsrc-L12$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L12$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _foo08:
; DARWIN-64-STATIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _foo08:
; DARWIN-64-DYNAMIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _foo08:
; DARWIN-64-PIC: 	movl	_lsrc(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux00() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 16), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 16), align 4
	ret void
; LINUX-64-STATIC: qux00:
; LINUX-64-STATIC: movl    src+64(%rip), %eax
; LINUX-64-STATIC: movl    %eax, dst+64(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux00:
; LINUX-32-STATIC: 	movl	src+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dst+64
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux00:
; LINUX-32-PIC: 	movl	src+64, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dst+64
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux00:
; DARWIN-32-STATIC: 	movl	_src+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dst+64
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux00:
; DARWIN-32-PIC: 	call	L13$pb
; DARWIN-32-PIC-NEXT: L13$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L13$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	64(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L13$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qxx00() nounwind {
entry:
	%0 = load i32* getelementptr ([32 x i32]* @xsrc, i32 0, i64 16), align 4
	store i32 %0, i32* getelementptr ([32 x i32]* @xdst, i32 0, i64 16), align 4
	ret void
; LINUX-64-STATIC: qxx00:
; LINUX-64-STATIC: movl    xsrc+64(%rip), %eax
; LINUX-64-STATIC: movl    %eax, xdst+64(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qxx00:
; LINUX-32-STATIC: 	movl	xsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, xdst+64
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qxx00:
; LINUX-32-PIC: 	movl	xsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, xdst+64
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qxx00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	xdst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qxx00:
; DARWIN-32-STATIC: 	movl	_xsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _xdst+64
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qxx00:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qxx00:
; DARWIN-32-PIC: 	call	L14$pb
; DARWIN-32-PIC-NEXT: L14$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L14$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	64(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L14$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qxx00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qxx00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qxx00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux01() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 16), i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: qux01:
; LINUX-64-STATIC: movq    $dst+64, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux01:
; LINUX-32-STATIC: 	movl	$dst+64, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux01:
; LINUX-32-PIC: 	movl	$dst+64, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux01:
; DARWIN-32-STATIC: 	movl	$_dst+64, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux01:
; DARWIN-32-DYNAMIC: 	movl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux01:
; DARWIN-32-PIC: 	call	L15$pb
; DARWIN-32-PIC-NEXT: L15$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L15$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	addl	$64, %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L15$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qxx01() nounwind {
entry:
	store i32* getelementptr ([32 x i32]* @xdst, i32 0, i64 16), i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: qxx01:
; LINUX-64-STATIC: movq    $xdst+64, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qxx01:
; LINUX-32-STATIC: 	movl	$xdst+64, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qxx01:
; LINUX-32-PIC: 	movl	$xdst+64, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qxx01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qxx01:
; DARWIN-32-STATIC: 	movl	$_xdst+64, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qxx01:
; DARWIN-32-DYNAMIC: 	movl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qxx01:
; DARWIN-32-PIC: 	call	L16$pb
; DARWIN-32-PIC-NEXT: L16$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L16$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	addl	$64, %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L16$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qxx01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qxx01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qxx01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 16), align 4
	%2 = getelementptr i32* %0, i64 16
	store i32 %1, i32* %2, align 4
; LINUX-64-STATIC: qux02:
; LINUX-64-STATIC: movl    src+64(%rip), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux02:
; LINUX-32-STATIC: 	movl	src+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-STATIC-NEXT: 	ret
	ret void

; LINUX-32-PIC: qux02:
; LINUX-32-PIC: 	movl	src+64, %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux02:
; DARWIN-32-STATIC: 	movl	_src+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux02:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux02:
; DARWIN-32-PIC: 	call	L17$pb
; DARWIN-32-PIC-NEXT: L17$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L17$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	64(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L17$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qxx02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = load i32* getelementptr ([32 x i32]* @xsrc, i32 0, i64 16), align 4
	%2 = getelementptr i32* %0, i64 16
	store i32 %1, i32* %2, align 4
; LINUX-64-STATIC: qxx02:
; LINUX-64-STATIC: movl    xsrc+64(%rip), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qxx02:
; LINUX-32-STATIC: 	movl	xsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-STATIC-NEXT: 	ret
	ret void

; LINUX-32-PIC: qxx02:
; LINUX-32-PIC: 	movl	xsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qxx02:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qxx02:
; DARWIN-32-STATIC: 	movl	_xsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qxx02:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qxx02:
; DARWIN-32-PIC: 	call	L18$pb
; DARWIN-32-PIC-NEXT: L18$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L18$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	64(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L18$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qxx02:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qxx02:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qxx02:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux03() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 16), align 32
	store i32 %0, i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 16), align 32
	ret void
; LINUX-64-STATIC: qux03:
; LINUX-64-STATIC: movl    dsrc+64(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ddst+64(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux03:
; LINUX-32-STATIC: 	movl	dsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ddst+64
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux03:
; LINUX-32-PIC: 	movl	dsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ddst+64
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux03:
; DARWIN-32-STATIC: 	movl	_dsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ddst+64
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux03:
; DARWIN-32-DYNAMIC: 	movl	_dsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ddst+64
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux03:
; DARWIN-32-PIC: 	call	L19$pb
; DARWIN-32-PIC-NEXT: L19$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L19$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (_ddst-L19$pb)+64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux03:
; DARWIN-64-STATIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ddst+64(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux03:
; DARWIN-64-DYNAMIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ddst+64(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux03:
; DARWIN-64-PIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ddst+64(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux04() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 16), i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: qux04:
; LINUX-64-STATIC: movq    $ddst+64, dptr(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux04:
; LINUX-32-STATIC: 	movl	$ddst+64, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux04:
; LINUX-32-PIC: 	movl	$ddst+64, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux04:
; DARWIN-32-STATIC: 	movl	$_ddst+64, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst+64, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux04:
; DARWIN-32-PIC: 	call	L20$pb
; DARWIN-32-PIC-NEXT: L20$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L20$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L20$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux04:
; DARWIN-64-STATIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux04:
; DARWIN-64-PIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux05() nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 16), align 32
	%2 = getelementptr i32* %0, i64 16
	store i32 %1, i32* %2, align 4
; LINUX-64-STATIC: qux05:
; LINUX-64-STATIC: movl    dsrc+64(%rip), %eax
; LINUX-64-STATIC: movq    dptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux05:
; LINUX-32-STATIC: 	movl	dsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-STATIC-NEXT: 	ret
	ret void

; LINUX-32-PIC: qux05:
; LINUX-32-PIC: 	movl	dsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux05:
; DARWIN-32-STATIC: 	movl	_dsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux05:
; DARWIN-32-DYNAMIC: 	movl	_dsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux05:
; DARWIN-32-PIC: 	call	L21$pb
; DARWIN-32-PIC-NEXT: L21$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L21$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L21$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux05:
; DARWIN-64-STATIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux05:
; DARWIN-64-DYNAMIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux05:
; DARWIN-64-PIC: 	movl	_dsrc+64(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux06() nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 16), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 16), align 4
	ret void
; LINUX-64-STATIC: qux06:
; LINUX-64-STATIC: movl    lsrc+64(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ldst+64
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux06:
; LINUX-32-STATIC: 	movl	lsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ldst+64
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux06:
; LINUX-32-PIC: 	movl	lsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ldst+64
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux06:
; LINUX-64-PIC: 	movl	lsrc+64(%rip), %eax
; LINUX-64-PIC-NEXT: 	movl	%eax, ldst+64(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux06:
; DARWIN-32-STATIC: 	movl	_lsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ldst+64
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux06:
; DARWIN-32-DYNAMIC: 	movl	_lsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ldst+64
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux06:
; DARWIN-32-PIC: 	call	L22$pb
; DARWIN-32-PIC-NEXT: L22$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L22$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (_ldst-L22$pb)+64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux06:
; DARWIN-64-STATIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ldst+64(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux06:
; DARWIN-64-DYNAMIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ldst+64(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux06:
; DARWIN-64-PIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ldst+64(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux07() nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 16), i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: qux07:
; LINUX-64-STATIC: movq    $ldst+64, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux07:
; LINUX-32-STATIC: 	movl	$ldst+64, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: qux07:
; LINUX-32-PIC: 	movl	$ldst+64, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux07:
; LINUX-64-PIC: 	leaq	ldst+64(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux07:
; DARWIN-32-STATIC: 	movl	$_ldst+64, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst+64, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux07:
; DARWIN-32-PIC: 	call	L23$pb
; DARWIN-32-PIC-NEXT: L23$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L23$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L23$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux07:
; DARWIN-64-STATIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux07:
; DARWIN-64-PIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @qux08() nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 16), align 4
	%2 = getelementptr i32* %0, i64 16
	store i32 %1, i32* %2, align 4
; LINUX-64-STATIC: qux08:
; LINUX-64-STATIC: movl    lsrc+64(%rip), %eax
; LINUX-64-STATIC: movq    lptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: qux08:
; LINUX-32-STATIC: 	movl	lsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-STATIC-NEXT: 	ret
	ret void

; LINUX-32-PIC: qux08:
; LINUX-32-PIC: 	movl	lsrc+64, %eax
; LINUX-32-PIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 64(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: qux08:
; LINUX-64-PIC: 	movl	lsrc+64(%rip), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _qux08:
; DARWIN-32-STATIC: 	movl	_lsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _qux08:
; DARWIN-32-DYNAMIC: 	movl	_lsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 64(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _qux08:
; DARWIN-32-PIC: 	call	L24$pb
; DARWIN-32-PIC-NEXT: L24$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L24$pb)+64(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L24$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 64(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _qux08:
; DARWIN-64-STATIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _qux08:
; DARWIN-64-DYNAMIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _qux08:
; DARWIN-64-PIC: 	movl	_lsrc+64(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind00(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @src, i64 0, i64 %i
	%1 = load i32* %0, align 4
	%2 = getelementptr [131072 x i32]* @dst, i64 0, i64 %i
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: ind00:
; LINUX-64-STATIC: movl    src(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, dst(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, dst(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, dst(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _dst(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind00:
; DARWIN-32-PIC: 	call	L25$pb
; DARWIN-32-PIC-NEXT: L25$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L25$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L25$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ixd00(i64 %i) nounwind {
entry:
	%0 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %i
	%1 = load i32* %0, align 4
	%2 = getelementptr [32 x i32]* @xdst, i64 0, i64 %i
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: ixd00:
; LINUX-64-STATIC: movl    xsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, xdst(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ixd00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	xsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, xdst(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ixd00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	xsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, xdst(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ixd00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	xdst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ixd00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_xsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _xdst(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ixd00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ixd00:
; DARWIN-32-PIC: 	call	L26$pb
; DARWIN-32-PIC-NEXT: L26$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L26$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L26$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ixd00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ixd00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ixd00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind01(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @dst, i64 0, i64 %i
	store i32* %0, i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: ind01:
; LINUX-64-STATIC: leaq    dst(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dst(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dst(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind01:
; LINUX-64-PIC: 	shlq	$2, %rdi
; LINUX-64-PIC-NEXT: 	addq	dst@GOTPCREL(%rip), %rdi
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rdi, (%rax)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dst(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	shll	$2, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind01:
; DARWIN-32-PIC: 	call	L27$pb
; DARWIN-32-PIC-NEXT: L27$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	shll	$2, %ecx
; DARWIN-32-PIC-NEXT: 	addl	L_dst$non_lazy_ptr-L27$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L27$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind01:
; DARWIN-64-STATIC: 	shlq	$2, %rdi
; DARWIN-64-STATIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rdi
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind01:
; DARWIN-64-DYNAMIC: 	shlq	$2, %rdi
; DARWIN-64-DYNAMIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rdi
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind01:
; DARWIN-64-PIC: 	shlq	$2, %rdi
; DARWIN-64-PIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rdi
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ixd01(i64 %i) nounwind {
entry:
	%0 = getelementptr [32 x i32]* @xdst, i64 0, i64 %i
	store i32* %0, i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: ixd01:
; LINUX-64-STATIC: leaq    xdst(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ixd01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xdst(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ixd01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xdst(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ixd01:
; LINUX-64-PIC: 	shlq	$2, %rdi
; LINUX-64-PIC-NEXT: 	addq	xdst@GOTPCREL(%rip), %rdi
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rdi, (%rax)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ixd01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xdst(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ixd01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	shll	$2, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ixd01:
; DARWIN-32-PIC: 	call	L28$pb
; DARWIN-32-PIC-NEXT: L28$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	shll	$2, %ecx
; DARWIN-32-PIC-NEXT: 	addl	L_xdst$non_lazy_ptr-L28$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L28$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ixd01:
; DARWIN-64-STATIC: 	shlq	$2, %rdi
; DARWIN-64-STATIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rdi
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ixd01:
; DARWIN-64-DYNAMIC: 	shlq	$2, %rdi
; DARWIN-64-DYNAMIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rdi
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ixd01:
; DARWIN-64-PIC: 	shlq	$2, %rdi
; DARWIN-64-PIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rdi
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rdi, (%rax)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = getelementptr [131072 x i32]* @src, i64 0, i64 %i
	%2 = load i32* %1, align 4
	%3 = getelementptr i32* %0, i64 %i
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: ind02:
; LINUX-64-STATIC: movl    src(,%rdi,4), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, (%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	ptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	ptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind02:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%edx), %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind02:
; DARWIN-32-PIC: 	call	L29$pb
; DARWIN-32-PIC-NEXT: L29$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L29$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L29$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ixd02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %i
	%2 = load i32* %1, align 4
	%3 = getelementptr i32* %0, i64 %i
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: ixd02:
; LINUX-64-STATIC: movl    xsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, (%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ixd02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	xsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	ptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ixd02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	xsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	ptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ixd02:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ixd02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_xsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ixd02:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%edx), %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ixd02:
; DARWIN-32-PIC: 	call	L30$pb
; DARWIN-32-PIC-NEXT: L30$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L30$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L30$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ixd02:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ixd02:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ixd02:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind03(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %i
	%1 = load i32* %0, align 4
	%2 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %i
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: ind03:
; LINUX-64-STATIC: movl    dsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ddst(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind03:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ddst(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind03:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ddst(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind03:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ddst(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind03:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ddst(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind03:
; DARWIN-32-PIC: 	call	L31$pb
; DARWIN-32-PIC-NEXT: L31$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dsrc-L31$pb(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, _ddst-L31$pb(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind04(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %i
	store i32* %0, i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: ind04:
; LINUX-64-STATIC: leaq    ddst(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, dptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind04:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ddst(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind04:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ddst(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind04:
; LINUX-64-PIC: 	shlq	$2, %rdi
; LINUX-64-PIC-NEXT: 	addq	ddst@GOTPCREL(%rip), %rdi
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rdi, (%rax)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind04:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ddst(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind04:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ddst(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind04:
; DARWIN-32-PIC: 	call	L32$pb
; DARWIN-32-PIC-NEXT: L32$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	_ddst-L32$pb(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L32$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %i
	%2 = load i32* %1, align 4
	%3 = getelementptr i32* %0, i64 %i
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: ind05:
; LINUX-64-STATIC: movl    dsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movq    dptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, (%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind05:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	dptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind05:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	dptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind05:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind05:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind05:
; DARWIN-32-PIC: 	call	L33$pb
; DARWIN-32-PIC-NEXT: L33$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dsrc-L33$pb(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L33$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind05:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind05:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind05:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind06(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %i
	%1 = load i32* %0, align 4
	%2 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %i
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: ind06:
; LINUX-64-STATIC: movl    lsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ldst(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind06:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ldst(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind06:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ldst(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	leaq	ldst(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind06:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ldst(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind06:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ldst(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind06:
; DARWIN-32-PIC: 	call	L34$pb
; DARWIN-32-PIC-NEXT: L34$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lsrc-L34$pb(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, _ldst-L34$pb(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind07(i64 %i) nounwind {
entry:
	%0 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %i
	store i32* %0, i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: ind07:
; LINUX-64-STATIC: leaq    ldst(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind07:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ldst(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind07:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ldst(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind07:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ldst(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind07:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ldst(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind07:
; DARWIN-32-PIC: 	call	L35$pb
; DARWIN-32-PIC-NEXT: L35$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	_ldst-L35$pb(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L35$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ind08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %i
	%2 = load i32* %1, align 4
	%3 = getelementptr i32* %0, i64 %i
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: ind08:
; LINUX-64-STATIC: movl    lsrc(,%rdi,4), %eax
; LINUX-64-STATIC: movq    lptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, (%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ind08:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	lptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ind08:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	lptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ind08:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ind08:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ind08:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, (%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ind08:
; DARWIN-32-PIC: 	call	L36$pb
; DARWIN-32-PIC-NEXT: L36$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lsrc-L36$pb(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L36$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, (%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ind08:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ind08:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ind08:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, (%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @src, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @dst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: off00:
; LINUX-64-STATIC: movl    src+64(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, dst+64(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, dst+64(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, dst+64(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _dst+64(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off00:
; DARWIN-32-PIC: 	call	L37$pb
; DARWIN-32-PIC-NEXT: L37$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L37$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	64(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L37$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @oxf00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [32 x i32]* @xdst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: oxf00:
; LINUX-64-STATIC: movl    xsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, xdst+64(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: oxf00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	xsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, xdst+64(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: oxf00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	xsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, xdst+64(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: oxf00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	xdst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _oxf00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_xsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _xdst+64(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _oxf00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _oxf00:
; DARWIN-32-PIC: 	call	L38$pb
; DARWIN-32-PIC-NEXT: L38$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L38$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	64(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L38$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _oxf00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _oxf00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _oxf00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_xdst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off01(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 16
	%0 = getelementptr [131072 x i32]* @dst, i64 0, i64 %.sum
	store i32* %0, i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: off01:
; LINUX-64-STATIC: leaq    dst+64(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off01:
; DARWIN-32-PIC: 	call	L39$pb
; DARWIN-32-PIC-NEXT: L39$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L39$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	leal	64(%edx,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L39$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @oxf01(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 16
	%0 = getelementptr [32 x i32]* @xdst, i64 0, i64 %.sum
	store i32* %0, i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: oxf01:
; LINUX-64-STATIC: leaq    xdst+64(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, ptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: oxf01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xdst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: oxf01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xdst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: oxf01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _oxf01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xdst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _oxf01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _oxf01:
; DARWIN-32-PIC: 	call	L40$pb
; DARWIN-32-PIC-NEXT: L40$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L40$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	leal	64(%edx,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L40$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _oxf01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _oxf01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _oxf01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr [131072 x i32]* @src, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: off02:
; LINUX-64-STATIC: movl    src+64(,%rdi,4), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	ptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	ptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off02:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%edx), %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off02:
; DARWIN-32-PIC: 	call	L41$pb
; DARWIN-32-PIC-NEXT: L41$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L41$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	64(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L41$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @oxf02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: oxf02:
; LINUX-64-STATIC: movl    xsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: oxf02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	xsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	ptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: oxf02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	xsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	ptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: oxf02:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _oxf02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_xsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _oxf02:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	64(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%edx), %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _oxf02:
; DARWIN-32-PIC: 	call	L42$pb
; DARWIN-32-PIC-NEXT: L42$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L42$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	64(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L42$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _oxf02:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _oxf02:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _oxf02:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off03(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: off03:
; LINUX-64-STATIC: movl    dsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ddst+64(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off03:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ddst+64(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off03:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ddst+64(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off03:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ddst+64(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off03:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc+64(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ddst+64(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off03:
; DARWIN-32-PIC: 	call	L43$pb
; DARWIN-32-PIC-NEXT: L43$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L43$pb)+64(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, (_ddst-L43$pb)+64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off04(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 16
	%0 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %.sum
	store i32* %0, i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: off04:
; LINUX-64-STATIC: leaq    ddst+64(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, dptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off04:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ddst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off04:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ddst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off04:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ddst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off04:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ddst+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off04:
; DARWIN-32-PIC: 	call	L44$pb
; DARWIN-32-PIC-NEXT: L44$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L44$pb)+64(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L44$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: off05:
; LINUX-64-STATIC: movl    dsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movq    dptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off05:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	dptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off05:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	dptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off05:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off05:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc+64(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off05:
; DARWIN-32-PIC: 	call	L45$pb
; DARWIN-32-PIC-NEXT: L45$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L45$pb)+64(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L45$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off05:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off05:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off05:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off06(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: off06:
; LINUX-64-STATIC: movl    lsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ldst+64(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off06:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ldst+64(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off06:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ldst+64(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	leaq	ldst(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off06:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ldst+64(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off06:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc+64(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ldst+64(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off06:
; DARWIN-32-PIC: 	call	L46$pb
; DARWIN-32-PIC-NEXT: L46$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L46$pb)+64(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, (_ldst-L46$pb)+64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off07(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 16
	%0 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %.sum
	store i32* %0, i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: off07:
; LINUX-64-STATIC: leaq    ldst+64(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off07:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ldst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off07:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ldst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off07:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ldst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off07:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ldst+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off07:
; DARWIN-32-PIC: 	call	L47$pb
; DARWIN-32-PIC-NEXT: L47$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L47$pb)+64(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L47$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @off08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: off08:
; LINUX-64-STATIC: movl    lsrc+64(,%rdi,4), %eax
; LINUX-64-STATIC: movq    lptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 64(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: off08:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc+64(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	lptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: off08:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc+64(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	lptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: off08:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _off08:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc+64(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _off08:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc+64(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 64(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _off08:
; DARWIN-32-PIC: 	call	L48$pb
; DARWIN-32-PIC-NEXT: L48$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L48$pb)+64(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L48$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 64(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _off08:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _off08:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _off08:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	64(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 64(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo00(i64 %i) nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 65536), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 65536), align 4
	ret void
; LINUX-64-STATIC: moo00:
; LINUX-64-STATIC: movl    src+262144(%rip), %eax
; LINUX-64-STATIC: movl    %eax, dst+262144(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo00:
; LINUX-32-STATIC: 	movl	src+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dst+262144
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo00:
; LINUX-32-PIC: 	movl	src+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dst+262144
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo00:
; DARWIN-32-STATIC: 	movl	_src+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dst+262144
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	262144(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo00:
; DARWIN-32-PIC: 	call	L49$pb
; DARWIN-32-PIC-NEXT: L49$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L49$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	262144(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L49$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo01(i64 %i) nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 65536), i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: moo01:
; LINUX-64-STATIC: movq    $dst+262144, ptr(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo01:
; LINUX-32-STATIC: 	movl	$dst+262144, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo01:
; LINUX-32-PIC: 	movl	$dst+262144, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo01:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo01:
; DARWIN-32-STATIC: 	movl	$_dst+262144, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo01:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo01:
; DARWIN-32-PIC: 	call	L50$pb
; DARWIN-32-PIC-NEXT: L50$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	$262144, %ecx
; DARWIN-32-PIC-NEXT: 	addl	L_dst$non_lazy_ptr-L50$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L50$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo01:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo01:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo01:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @src, i32 0, i64 65536), align 4
	%2 = getelementptr i32* %0, i64 65536
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: moo02:
; LINUX-64-STATIC: movl    src+262144(%rip), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo02:
; LINUX-32-STATIC: 	movl	src+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo02:
; LINUX-32-PIC: 	movl	src+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo02:
; DARWIN-32-STATIC: 	movl	_src+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo02:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	262144(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%ecx), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo02:
; DARWIN-32-PIC: 	call	L51$pb
; DARWIN-32-PIC-NEXT: L51$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L51$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	262144(%ecx), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L51$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo03(i64 %i) nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 65536), align 32
	store i32 %0, i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 65536), align 32
	ret void
; LINUX-64-STATIC: moo03:
; LINUX-64-STATIC: movl    dsrc+262144(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ddst+262144(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo03:
; LINUX-32-STATIC: 	movl	dsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ddst+262144
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo03:
; LINUX-32-PIC: 	movl	dsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ddst+262144
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo03:
; DARWIN-32-STATIC: 	movl	_dsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ddst+262144
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo03:
; DARWIN-32-DYNAMIC: 	movl	_dsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ddst+262144
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo03:
; DARWIN-32-PIC: 	call	L52$pb
; DARWIN-32-PIC-NEXT: L52$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L52$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (_ddst-L52$pb)+262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo03:
; DARWIN-64-STATIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ddst+262144(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo03:
; DARWIN-64-DYNAMIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ddst+262144(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo03:
; DARWIN-64-PIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ddst+262144(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo04(i64 %i) nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 65536), i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: moo04:
; LINUX-64-STATIC: movq    $ddst+262144, dptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo04:
; LINUX-32-STATIC: 	movl	$ddst+262144, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo04:
; LINUX-32-PIC: 	movl	$ddst+262144, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo04:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo04:
; DARWIN-32-STATIC: 	movl	$_ddst+262144, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst+262144, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo04:
; DARWIN-32-PIC: 	call	L53$pb
; DARWIN-32-PIC-NEXT: L53$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L53$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L53$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo04:
; DARWIN-64-STATIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo04:
; DARWIN-64-PIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 65536), align 32
	%2 = getelementptr i32* %0, i64 65536
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: moo05:
; LINUX-64-STATIC: movl    dsrc+262144(%rip), %eax
; LINUX-64-STATIC: movq    dptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo05:
; LINUX-32-STATIC: 	movl	dsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo05:
; LINUX-32-PIC: 	movl	dsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo05:
; DARWIN-32-STATIC: 	movl	_dsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo05:
; DARWIN-32-DYNAMIC: 	movl	_dsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo05:
; DARWIN-32-PIC: 	call	L54$pb
; DARWIN-32-PIC-NEXT: L54$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L54$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L54$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo05:
; DARWIN-64-STATIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo05:
; DARWIN-64-DYNAMIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo05:
; DARWIN-64-PIC: 	movl	_dsrc+262144(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo06(i64 %i) nounwind {
entry:
	%0 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 65536), align 4
	store i32 %0, i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 65536), align 4
	ret void
; LINUX-64-STATIC: moo06:
; LINUX-64-STATIC: movl    lsrc+262144(%rip), %eax
; LINUX-64-STATIC: movl    %eax, ldst+262144(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo06:
; LINUX-32-STATIC: 	movl	lsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ldst+262144
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo06:
; LINUX-32-PIC: 	movl	lsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ldst+262144
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo06:
; LINUX-64-PIC: 	movl	lsrc+262144(%rip), %eax
; LINUX-64-PIC-NEXT: 	movl	%eax, ldst+262144(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo06:
; DARWIN-32-STATIC: 	movl	_lsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ldst+262144
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo06:
; DARWIN-32-DYNAMIC: 	movl	_lsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _ldst+262144
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo06:
; DARWIN-32-PIC: 	call	L55$pb
; DARWIN-32-PIC-NEXT: L55$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L55$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (_ldst-L55$pb)+262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo06:
; DARWIN-64-STATIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movl	%eax, _ldst+262144(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo06:
; DARWIN-64-DYNAMIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, _ldst+262144(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo06:
; DARWIN-64-PIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movl	%eax, _ldst+262144(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo07(i64 %i) nounwind {
entry:
	store i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 65536), i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: moo07:
; LINUX-64-STATIC: movq    $ldst+262144, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo07:
; LINUX-32-STATIC: 	movl	$ldst+262144, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo07:
; LINUX-32-PIC: 	movl	$ldst+262144, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo07:
; LINUX-64-PIC: 	leaq	ldst+262144(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo07:
; DARWIN-32-STATIC: 	movl	$_ldst+262144, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst+262144, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo07:
; DARWIN-32-PIC: 	call	L56$pb
; DARWIN-32-PIC-NEXT: L56$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L56$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L56$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo07:
; DARWIN-64-STATIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo07:
; DARWIN-64-PIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @moo08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = load i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 65536), align 4
	%2 = getelementptr i32* %0, i64 65536
	store i32 %1, i32* %2, align 4
	ret void
; LINUX-64-STATIC: moo08:
; LINUX-64-STATIC: movl    lsrc+262144(%rip), %eax
; LINUX-64-STATIC: movq    lptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: moo08:
; LINUX-32-STATIC: 	movl	lsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: moo08:
; LINUX-32-PIC: 	movl	lsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-PIC-NEXT: 	movl	%eax, 262144(%ecx)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: moo08:
; LINUX-64-PIC: 	movl	lsrc+262144(%rip), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _moo08:
; DARWIN-32-STATIC: 	movl	_lsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _moo08:
; DARWIN-32-DYNAMIC: 	movl	_lsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, 262144(%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _moo08:
; DARWIN-32-PIC: 	call	L57$pb
; DARWIN-32-PIC-NEXT: L57$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L57$pb)+262144(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L57$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, 262144(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _moo08:
; DARWIN-64-STATIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _moo08:
; DARWIN-64-DYNAMIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _moo08:
; DARWIN-64-PIC: 	movl	_lsrc+262144(%rip), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @src, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @dst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: big00:
; LINUX-64-STATIC: movl    src+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, dst+262144(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, dst+262144(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, dst+262144(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _dst+262144(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	262144(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big00:
; DARWIN-32-PIC: 	call	L58$pb
; DARWIN-32-PIC-NEXT: L58$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L58$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	262144(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L58$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dst@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big01(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 65536
	%0 = getelementptr [131072 x i32]* @dst, i64 0, i64 %.sum
	store i32* %0, i32** @ptr, align 8
	ret void
; LINUX-64-STATIC: big01:
; LINUX-64-STATIC: leaq    dst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, ptr(%rip)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, ptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, ptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _ptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, (%ecx)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big01:
; DARWIN-32-PIC: 	call	L59$pb
; DARWIN-32-PIC-NEXT: L59$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L59$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	leal	262144(%edx,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L59$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%ecx, (%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	%rax, (%rcx)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr [131072 x i32]* @src, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: big02:
; LINUX-64-STATIC: movl    src+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movq    ptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	src+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	ptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	src+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	ptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big02:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_src+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big02:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	262144(%ecx,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ptr$non_lazy_ptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%edx), %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big02:
; DARWIN-32-PIC: 	call	L60$pb
; DARWIN-32-PIC-NEXT: L60$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L60$pb(%eax), %edx
; DARWIN-32-PIC-NEXT: 	movl	262144(%edx,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L60$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big02:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big02:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big02:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movq	(%rcx), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big03(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: big03:
; LINUX-64-STATIC: movl    dsrc+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ddst+262144(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big03:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ddst+262144(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big03:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ddst+262144(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	ddst@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big03:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ddst+262144(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big03:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc+262144(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ddst+262144(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big03:
; DARWIN-32-PIC: 	call	L61$pb
; DARWIN-32-PIC-NEXT: L61$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L61$pb)+262144(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, (_ddst-L61$pb)+262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ddst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big04(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 65536
	%0 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %.sum
	store i32* %0, i32** @dptr, align 8
	ret void
; LINUX-64-STATIC: big04:
; LINUX-64-STATIC: leaq    ddst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, dptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big04:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ddst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, dptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big04:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ddst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, dptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	%rax, (%rcx)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big04:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ddst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big04:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ddst+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _dptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big04:
; DARWIN-32-PIC: 	call	L62$pb
; DARWIN-32-PIC-NEXT: L62$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L62$pb)+262144(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _dptr-L62$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _dptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: big05:
; LINUX-64-STATIC: movl    dsrc+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movq    dptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big05:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dsrc+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	dptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big05:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dsrc+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	dptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big05:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movq	(%rcx), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big05:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dsrc+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big05:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dsrc+262144(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big05:
; DARWIN-32-PIC: 	call	L63$pb
; DARWIN-32-PIC-NEXT: L63$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_dsrc-L63$pb)+262144(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L63$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big05:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big05:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big05:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_dptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big06(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %0
	%2 = load i32* %1, align 4
	%3 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %0
	store i32 %2, i32* %3, align 4
	ret void
; LINUX-64-STATIC: big06:
; LINUX-64-STATIC: movl    lsrc+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movl    %eax, ldst+262144(,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big06:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, ldst+262144(,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big06:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	%ecx, ldst+262144(,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	leaq	ldst(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big06:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, _ldst+262144(,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big06:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc+262144(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, _ldst+262144(,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big06:
; DARWIN-32-PIC: 	call	L64$pb
; DARWIN-32-PIC-NEXT: L64$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L64$pb)+262144(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	%edx, (_ldst-L64$pb)+262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	leaq	_ldst(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big07(i64 %i) nounwind {
entry:
	%.sum = add i64 %i, 65536
	%0 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %.sum
	store i32* %0, i32** @lptr, align 8
	ret void
; LINUX-64-STATIC: big07:
; LINUX-64-STATIC: leaq    ldst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: movq    %rax, lptr
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big07:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ldst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	movl	%eax, lptr
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big07:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ldst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	movl	%eax, lptr
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	movq	%rax, lptr(%rip)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big07:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ldst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big07:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ldst+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	%eax, _lptr
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big07:
; DARWIN-32-PIC: 	call	L65$pb
; DARWIN-32-PIC-NEXT: L65$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L65$pb)+262144(%eax,%ecx,4), %ecx
; DARWIN-32-PIC-NEXT: 	movl	%ecx, _lptr-L65$pb(%eax)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	movq	%rax, _lptr(%rip)
; DARWIN-64-PIC-NEXT: 	ret
}

define void @big08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %1
	%3 = load i32* %2, align 4
	%4 = getelementptr i32* %0, i64 %1
	store i32 %3, i32* %4, align 4
	ret void
; LINUX-64-STATIC: big08:
; LINUX-64-STATIC: movl    lsrc+262144(,%rdi,4), %eax
; LINUX-64-STATIC: movq    lptr(%rip), %rcx
; LINUX-64-STATIC: movl    %eax, 262144(%rcx,%rdi,4)
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: big08:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lsrc+262144(,%eax,4), %ecx
; LINUX-32-STATIC-NEXT: 	movl	lptr, %edx
; LINUX-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: big08:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lsrc+262144(,%eax,4), %ecx
; LINUX-32-PIC-NEXT: 	movl	lptr, %edx
; LINUX-32-PIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: big08:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; LINUX-64-PIC-NEXT: 	movq	lptr(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _big08:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lsrc+262144(,%eax,4), %ecx
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-STATIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _big08:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lsrc+262144(,%eax,4), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %edx
; DARWIN-32-DYNAMIC-NEXT: 	movl	%ecx, 262144(%edx,%eax,4)
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _big08:
; DARWIN-32-PIC: 	call	L66$pb
; DARWIN-32-PIC-NEXT: L66$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	(_lsrc-L66$pb)+262144(%eax,%ecx,4), %edx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L66$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	%edx, 262144(%eax,%ecx,4)
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _big08:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-STATIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _big08:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-DYNAMIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _big08:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movl	262144(%rax,%rdi,4), %eax
; DARWIN-64-PIC-NEXT: 	movq	_lptr(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	%eax, 262144(%rcx,%rdi,4)
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar00() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @src to i8*)
; LINUX-64-STATIC: bar00:
; LINUX-64-STATIC: movl    $src, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar00:
; LINUX-32-STATIC: 	movl	$src, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar00:
; LINUX-32-PIC: 	movl	$src, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar00:
; DARWIN-32-STATIC: 	movl	$_src, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar00:
; DARWIN-32-PIC: 	call	L67$pb
; DARWIN-32-PIC-NEXT: L67$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L67$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bxr00() nounwind {
entry:
	ret i8* bitcast ([32 x i32]* @xsrc to i8*)
; LINUX-64-STATIC: bxr00:
; LINUX-64-STATIC: movl    $xsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bxr00:
; LINUX-32-STATIC: 	movl	$xsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bxr00:
; LINUX-32-PIC: 	movl	$xsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bxr00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bxr00:
; DARWIN-32-STATIC: 	movl	$_xsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bxr00:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bxr00:
; DARWIN-32-PIC: 	call	L68$pb
; DARWIN-32-PIC-NEXT: L68$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L68$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bxr00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bxr00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bxr00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar01() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @dst to i8*)
; LINUX-64-STATIC: bar01:
; LINUX-64-STATIC: movl    $dst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar01:
; LINUX-32-STATIC: 	movl	$dst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar01:
; LINUX-32-PIC: 	movl	$dst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar01:
; DARWIN-32-STATIC: 	movl	$_dst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar01:
; DARWIN-32-DYNAMIC: 	movl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar01:
; DARWIN-32-PIC: 	call	L69$pb
; DARWIN-32-PIC-NEXT: L69$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L69$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bxr01() nounwind {
entry:
	ret i8* bitcast ([32 x i32]* @xdst to i8*)
; LINUX-64-STATIC: bxr01:
; LINUX-64-STATIC: movl    $xdst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bxr01:
; LINUX-32-STATIC: 	movl	$xdst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bxr01:
; LINUX-32-PIC: 	movl	$xdst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bxr01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bxr01:
; DARWIN-32-STATIC: 	movl	$_xdst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bxr01:
; DARWIN-32-DYNAMIC: 	movl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bxr01:
; DARWIN-32-PIC: 	call	L70$pb
; DARWIN-32-PIC-NEXT: L70$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L70$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bxr01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bxr01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bxr01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar02() nounwind {
entry:
	ret i8* bitcast (i32** @ptr to i8*)
; LINUX-64-STATIC: bar02:
; LINUX-64-STATIC: movl    $ptr, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar02:
; LINUX-32-STATIC: 	movl	$ptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar02:
; LINUX-32-PIC: 	movl	$ptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar02:
; DARWIN-32-STATIC: 	movl	$_ptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar02:
; DARWIN-32-PIC: 	call	L71$pb
; DARWIN-32-PIC-NEXT: L71$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L71$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar03() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @dsrc to i8*)
; LINUX-64-STATIC: bar03:
; LINUX-64-STATIC: movl    $dsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar03:
; LINUX-32-STATIC: 	movl	$dsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar03:
; LINUX-32-PIC: 	movl	$dsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar03:
; DARWIN-32-STATIC: 	movl	$_dsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar03:
; DARWIN-32-DYNAMIC: 	movl	$_dsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar03:
; DARWIN-32-PIC: 	call	L72$pb
; DARWIN-32-PIC-NEXT: L72$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_dsrc-L72$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar04() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @ddst to i8*)
; LINUX-64-STATIC: bar04:
; LINUX-64-STATIC: movl    $ddst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar04:
; LINUX-32-STATIC: 	movl	$ddst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar04:
; LINUX-32-PIC: 	movl	$ddst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar04:
; DARWIN-32-STATIC: 	movl	$_ddst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar04:
; DARWIN-32-PIC: 	call	L73$pb
; DARWIN-32-PIC-NEXT: L73$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ddst-L73$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar05() nounwind {
entry:
	ret i8* bitcast (i32** @dptr to i8*)
; LINUX-64-STATIC: bar05:
; LINUX-64-STATIC: movl    $dptr, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar05:
; LINUX-32-STATIC: 	movl	$dptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar05:
; LINUX-32-PIC: 	movl	$dptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar05:
; DARWIN-32-STATIC: 	movl	$_dptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar05:
; DARWIN-32-DYNAMIC: 	movl	$_dptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar05:
; DARWIN-32-PIC: 	call	L74$pb
; DARWIN-32-PIC-NEXT: L74$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_dptr-L74$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar05:
; DARWIN-64-STATIC: 	leaq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar05:
; DARWIN-64-DYNAMIC: 	leaq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar05:
; DARWIN-64-PIC: 	leaq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar06() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @lsrc to i8*)
; LINUX-64-STATIC: bar06:
; LINUX-64-STATIC: movl    $lsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar06:
; LINUX-32-STATIC: 	movl	$lsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar06:
; LINUX-32-PIC: 	movl	$lsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar06:
; DARWIN-32-STATIC: 	movl	$_lsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar06:
; DARWIN-32-DYNAMIC: 	movl	$_lsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar06:
; DARWIN-32-PIC: 	call	L75$pb
; DARWIN-32-PIC-NEXT: L75$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_lsrc-L75$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar07() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @ldst to i8*)
; LINUX-64-STATIC: bar07:
; LINUX-64-STATIC: movl    $ldst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar07:
; LINUX-32-STATIC: 	movl	$ldst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar07:
; LINUX-32-PIC: 	movl	$ldst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar07:
; DARWIN-32-STATIC: 	movl	$_ldst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar07:
; DARWIN-32-PIC: 	call	L76$pb
; DARWIN-32-PIC-NEXT: L76$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ldst-L76$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bar08() nounwind {
entry:
	ret i8* bitcast (i32** @lptr to i8*)
; LINUX-64-STATIC: bar08:
; LINUX-64-STATIC: movl    $lptr, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bar08:
; LINUX-32-STATIC: 	movl	$lptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bar08:
; LINUX-32-PIC: 	movl	$lptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bar08:
; LINUX-64-PIC: 	leaq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bar08:
; DARWIN-32-STATIC: 	movl	$_lptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bar08:
; DARWIN-32-DYNAMIC: 	movl	$_lptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bar08:
; DARWIN-32-PIC: 	call	L77$pb
; DARWIN-32-PIC-NEXT: L77$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_lptr-L77$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bar08:
; DARWIN-64-STATIC: 	leaq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bar08:
; DARWIN-64-DYNAMIC: 	leaq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bar08:
; DARWIN-64-PIC: 	leaq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har00() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @src to i8*)
; LINUX-64-STATIC: har00:
; LINUX-64-STATIC: movl    $src, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har00:
; LINUX-32-STATIC: 	movl	$src, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har00:
; LINUX-32-PIC: 	movl	$src, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har00:
; DARWIN-32-STATIC: 	movl	$_src, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har00:
; DARWIN-32-PIC: 	call	L78$pb
; DARWIN-32-PIC-NEXT: L78$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L78$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @hxr00() nounwind {
entry:
	ret i8* bitcast ([32 x i32]* @xsrc to i8*)
; LINUX-64-STATIC: hxr00:
; LINUX-64-STATIC: movl    $xsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: hxr00:
; LINUX-32-STATIC: 	movl	$xsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: hxr00:
; LINUX-32-PIC: 	movl	$xsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: hxr00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _hxr00:
; DARWIN-32-STATIC: 	movl	$_xsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _hxr00:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _hxr00:
; DARWIN-32-PIC: 	call	L79$pb
; DARWIN-32-PIC-NEXT: L79$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L79$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _hxr00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _hxr00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _hxr00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har01() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @dst to i8*)
; LINUX-64-STATIC: har01:
; LINUX-64-STATIC: movl    $dst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har01:
; LINUX-32-STATIC: 	movl	$dst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har01:
; LINUX-32-PIC: 	movl	$dst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har01:
; DARWIN-32-STATIC: 	movl	$_dst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har01:
; DARWIN-32-DYNAMIC: 	movl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har01:
; DARWIN-32-PIC: 	call	L80$pb
; DARWIN-32-PIC-NEXT: L80$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L80$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @hxr01() nounwind {
entry:
	ret i8* bitcast ([32 x i32]* @xdst to i8*)
; LINUX-64-STATIC: hxr01:
; LINUX-64-STATIC: movl    $xdst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: hxr01:
; LINUX-32-STATIC: 	movl	$xdst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: hxr01:
; LINUX-32-PIC: 	movl	$xdst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: hxr01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _hxr01:
; DARWIN-32-STATIC: 	movl	$_xdst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _hxr01:
; DARWIN-32-DYNAMIC: 	movl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _hxr01:
; DARWIN-32-PIC: 	call	L81$pb
; DARWIN-32-PIC-NEXT: L81$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L81$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _hxr01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _hxr01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _hxr01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = bitcast i32* %0 to i8*
	ret i8* %1
; LINUX-64-STATIC: har02:
; LINUX-64-STATIC: movq    ptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har02:
; LINUX-32-STATIC: 	movl	ptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har02:
; LINUX-32-PIC: 	movl	ptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har02:
; DARWIN-32-STATIC: 	movl	_ptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har02:
; DARWIN-32-PIC: 	call	L82$pb
; DARWIN-32-PIC-NEXT: L82$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L82$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har03() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @dsrc to i8*)
; LINUX-64-STATIC: har03:
; LINUX-64-STATIC: movl    $dsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har03:
; LINUX-32-STATIC: 	movl	$dsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har03:
; LINUX-32-PIC: 	movl	$dsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har03:
; DARWIN-32-STATIC: 	movl	$_dsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har03:
; DARWIN-32-DYNAMIC: 	movl	$_dsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har03:
; DARWIN-32-PIC: 	call	L83$pb
; DARWIN-32-PIC-NEXT: L83$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_dsrc-L83$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har04() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @ddst to i8*)
; LINUX-64-STATIC: har04:
; LINUX-64-STATIC: movl    $ddst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har04:
; LINUX-32-STATIC: 	movl	$ddst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har04:
; LINUX-32-PIC: 	movl	$ddst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har04:
; DARWIN-32-STATIC: 	movl	$_ddst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har04:
; DARWIN-32-PIC: 	call	L84$pb
; DARWIN-32-PIC-NEXT: L84$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ddst-L84$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har05() nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = bitcast i32* %0 to i8*
	ret i8* %1
; LINUX-64-STATIC: har05:
; LINUX-64-STATIC: movq    dptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har05:
; LINUX-32-STATIC: 	movl	dptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har05:
; LINUX-32-PIC: 	movl	dptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har05:
; DARWIN-32-STATIC: 	movl	_dptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har05:
; DARWIN-32-DYNAMIC: 	movl	_dptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har05:
; DARWIN-32-PIC: 	call	L85$pb
; DARWIN-32-PIC-NEXT: L85$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L85$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har05:
; DARWIN-64-STATIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har05:
; DARWIN-64-DYNAMIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har05:
; DARWIN-64-PIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har06() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @lsrc to i8*)
; LINUX-64-STATIC: har06:
; LINUX-64-STATIC: movl    $lsrc, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har06:
; LINUX-32-STATIC: 	movl	$lsrc, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har06:
; LINUX-32-PIC: 	movl	$lsrc, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har06:
; DARWIN-32-STATIC: 	movl	$_lsrc, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har06:
; DARWIN-32-DYNAMIC: 	movl	$_lsrc, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har06:
; DARWIN-32-PIC: 	call	L86$pb
; DARWIN-32-PIC-NEXT: L86$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_lsrc-L86$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har07() nounwind {
entry:
	ret i8* bitcast ([131072 x i32]* @ldst to i8*)
; LINUX-64-STATIC: har07:
; LINUX-64-STATIC: movl    $ldst, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har07:
; LINUX-32-STATIC: 	movl	$ldst, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har07:
; LINUX-32-PIC: 	movl	$ldst, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har07:
; DARWIN-32-STATIC: 	movl	$_ldst, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har07:
; DARWIN-32-PIC: 	call	L87$pb
; DARWIN-32-PIC-NEXT: L87$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_ldst-L87$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @har08() nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = bitcast i32* %0 to i8*
	ret i8* %1
; LINUX-64-STATIC: har08:
; LINUX-64-STATIC: movq    lptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: har08:
; LINUX-32-STATIC: 	movl	lptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: har08:
; LINUX-32-PIC: 	movl	lptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: har08:
; LINUX-64-PIC: 	movq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _har08:
; DARWIN-32-STATIC: 	movl	_lptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _har08:
; DARWIN-32-DYNAMIC: 	movl	_lptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _har08:
; DARWIN-32-PIC: 	call	L88$pb
; DARWIN-32-PIC-NEXT: L88$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L88$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _har08:
; DARWIN-64-STATIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _har08:
; DARWIN-64-DYNAMIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _har08:
; DARWIN-64-PIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat00() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @src, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat00:
; LINUX-64-STATIC: movl    $src+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat00:
; LINUX-32-STATIC: 	movl	$src+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat00:
; LINUX-32-PIC: 	movl	$src+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat00:
; DARWIN-32-STATIC: 	movl	$_src+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat00:
; DARWIN-32-DYNAMIC: 	movl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat00:
; DARWIN-32-PIC: 	call	L89$pb
; DARWIN-32-PIC-NEXT: L89$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L89$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bxt00() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([32 x i32]* @xsrc, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bxt00:
; LINUX-64-STATIC: movl    $xsrc+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bxt00:
; LINUX-32-STATIC: 	movl	$xsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bxt00:
; LINUX-32-PIC: 	movl	$xsrc+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bxt00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bxt00:
; DARWIN-32-STATIC: 	movl	$_xsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bxt00:
; DARWIN-32-DYNAMIC: 	movl	L_xsrc$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bxt00:
; DARWIN-32-PIC: 	call	L90$pb
; DARWIN-32-PIC-NEXT: L90$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L90$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bxt00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bxt00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bxt00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat01() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat01:
; LINUX-64-STATIC: movl    $dst+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat01:
; LINUX-32-STATIC: 	movl	$dst+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat01:
; LINUX-32-PIC: 	movl	$dst+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat01:
; DARWIN-32-STATIC: 	movl	$_dst+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat01:
; DARWIN-32-DYNAMIC: 	movl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat01:
; DARWIN-32-PIC: 	call	L91$pb
; DARWIN-32-PIC-NEXT: L91$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L91$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bxt01() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([32 x i32]* @xdst, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bxt01:
; LINUX-64-STATIC: movl    $xdst+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bxt01:
; LINUX-32-STATIC: 	movl	$xdst+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bxt01:
; LINUX-32-PIC: 	movl	$xdst+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bxt01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bxt01:
; DARWIN-32-STATIC: 	movl	$_xdst+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bxt01:
; DARWIN-32-DYNAMIC: 	movl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bxt01:
; DARWIN-32-PIC: 	call	L92$pb
; DARWIN-32-PIC-NEXT: L92$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L92$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bxt01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bxt01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bxt01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = getelementptr i32* %0, i64 16
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bat02:
; LINUX-64-STATIC: movq    ptr(%rip), %rax
; LINUX-64-STATIC: addq    $64, %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat02:
; LINUX-32-STATIC: 	movl	ptr, %eax
; LINUX-32-STATIC-NEXT: 	addl	$64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat02:
; LINUX-32-PIC: 	movl	ptr, %eax
; LINUX-32-PIC-NEXT: 	addl	$64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat02:
; DARWIN-32-STATIC: 	movl	_ptr, %eax
; DARWIN-32-STATIC-NEXT: 	addl	$64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat02:
; DARWIN-32-PIC: 	call	L93$pb
; DARWIN-32-PIC-NEXT: L93$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L93$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat03() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat03:
; LINUX-64-STATIC: movl    $dsrc+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat03:
; LINUX-32-STATIC: 	movl	$dsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat03:
; LINUX-32-PIC: 	movl	$dsrc+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat03:
; DARWIN-32-STATIC: 	movl	$_dsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat03:
; DARWIN-32-DYNAMIC: 	movl	$_dsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat03:
; DARWIN-32-PIC: 	call	L94$pb
; DARWIN-32-PIC-NEXT: L94$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_dsrc-L94$pb)+64(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat03:
; DARWIN-64-STATIC: 	leaq	_dsrc+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat03:
; DARWIN-64-PIC: 	leaq	_dsrc+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat04() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat04:
; LINUX-64-STATIC: movl    $ddst+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat04:
; LINUX-32-STATIC: 	movl	$ddst+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat04:
; LINUX-32-PIC: 	movl	$ddst+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat04:
; DARWIN-32-STATIC: 	movl	$_ddst+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat04:
; DARWIN-32-PIC: 	call	L95$pb
; DARWIN-32-PIC-NEXT: L95$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L95$pb)+64(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat04:
; DARWIN-64-STATIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat04:
; DARWIN-64-PIC: 	leaq	_ddst+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat05() nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = getelementptr i32* %0, i64 16
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bat05:
; LINUX-64-STATIC: movq    dptr(%rip), %rax
; LINUX-64-STATIC: addq    $64, %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat05:
; LINUX-32-STATIC: 	movl	dptr, %eax
; LINUX-32-STATIC-NEXT: 	addl	$64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat05:
; LINUX-32-PIC: 	movl	dptr, %eax
; LINUX-32-PIC-NEXT: 	addl	$64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat05:
; DARWIN-32-STATIC: 	movl	_dptr, %eax
; DARWIN-32-STATIC-NEXT: 	addl	$64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat05:
; DARWIN-32-DYNAMIC: 	movl	_dptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat05:
; DARWIN-32-PIC: 	call	L96$pb
; DARWIN-32-PIC-NEXT: L96$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L96$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat05:
; DARWIN-64-STATIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat05:
; DARWIN-64-DYNAMIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat05:
; DARWIN-64-PIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat06() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat06:
; LINUX-64-STATIC: movl    $lsrc+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat06:
; LINUX-32-STATIC: 	movl	$lsrc+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat06:
; LINUX-32-PIC: 	movl	$lsrc+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat06:
; LINUX-64-PIC: 	leaq	lsrc+64(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat06:
; DARWIN-32-STATIC: 	movl	$_lsrc+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat06:
; DARWIN-32-DYNAMIC: 	movl	$_lsrc+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat06:
; DARWIN-32-PIC: 	call	L97$pb
; DARWIN-32-PIC-NEXT: L97$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_lsrc-L97$pb)+64(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat06:
; DARWIN-64-STATIC: 	leaq	_lsrc+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat06:
; DARWIN-64-PIC: 	leaq	_lsrc+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat07() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 16) to i8*)
; LINUX-64-STATIC: bat07:
; LINUX-64-STATIC: movl    $ldst+64, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat07:
; LINUX-32-STATIC: 	movl	$ldst+64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat07:
; LINUX-32-PIC: 	movl	$ldst+64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat07:
; LINUX-64-PIC: 	leaq	ldst+64(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat07:
; DARWIN-32-STATIC: 	movl	$_ldst+64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst+64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat07:
; DARWIN-32-PIC: 	call	L98$pb
; DARWIN-32-PIC-NEXT: L98$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L98$pb)+64(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat07:
; DARWIN-64-STATIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat07:
; DARWIN-64-PIC: 	leaq	_ldst+64(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bat08() nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = getelementptr i32* %0, i64 16
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bat08:
; LINUX-64-STATIC: movq    lptr(%rip), %rax
; LINUX-64-STATIC: addq    $64, %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bat08:
; LINUX-32-STATIC: 	movl	lptr, %eax
; LINUX-32-STATIC-NEXT: 	addl	$64, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bat08:
; LINUX-32-PIC: 	movl	lptr, %eax
; LINUX-32-PIC-NEXT: 	addl	$64, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bat08:
; LINUX-64-PIC: 	movq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	addq	$64, %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bat08:
; DARWIN-32-STATIC: 	movl	_lptr, %eax
; DARWIN-32-STATIC-NEXT: 	addl	$64, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bat08:
; DARWIN-32-DYNAMIC: 	movl	_lptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	$64, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bat08:
; DARWIN-32-PIC: 	call	L99$pb
; DARWIN-32-PIC-NEXT: L99$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L99$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	addl	$64, %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bat08:
; DARWIN-64-STATIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	addq	$64, %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bat08:
; DARWIN-64-DYNAMIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	addq	$64, %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bat08:
; DARWIN-64-PIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	addq	$64, %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam00() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @src, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam00:
; LINUX-64-STATIC: movl    $src+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam00:
; LINUX-32-STATIC: 	movl	$src+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam00:
; LINUX-32-PIC: 	movl	$src+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam00:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam00:
; DARWIN-32-STATIC: 	movl	$_src+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam00:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_src$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam00:
; DARWIN-32-PIC: 	call	L100$pb
; DARWIN-32-PIC-NEXT: L100$pb:
; DARWIN-32-PIC-NEXT: 	popl	%ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	L_src$non_lazy_ptr-L100$pb(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam00:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam00:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam00:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam01() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @dst, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam01:
; LINUX-64-STATIC: movl    $dst+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam01:
; LINUX-32-STATIC: 	movl	$dst+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam01:
; LINUX-32-PIC: 	movl	$dst+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam01:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam01:
; DARWIN-32-STATIC: 	movl	$_dst+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam01:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_dst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam01:
; DARWIN-32-PIC: 	call	L101$pb
; DARWIN-32-PIC-NEXT: L101$pb:
; DARWIN-32-PIC-NEXT: 	popl	%ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	L_dst$non_lazy_ptr-L101$pb(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam01:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam01:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam01:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bxm01() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([32 x i32]* @xdst, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bxm01:
; LINUX-64-STATIC: movl    $xdst+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bxm01:
; LINUX-32-STATIC: 	movl	$xdst+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bxm01:
; LINUX-32-PIC: 	movl	$xdst+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bxm01:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bxm01:
; DARWIN-32-STATIC: 	movl	$_xdst+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bxm01:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	L_xdst$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bxm01:
; DARWIN-32-PIC: 	call	L102$pb
; DARWIN-32-PIC-NEXT: L102$pb:
; DARWIN-32-PIC-NEXT: 	popl	%ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	L_xdst$non_lazy_ptr-L102$pb(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bxm01:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bxm01:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bxm01:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam02() nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = getelementptr i32* %0, i64 65536
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bam02:
; LINUX-64-STATIC: movl    $262144, %eax
; LINUX-64-STATIC: addq    ptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam02:
; LINUX-32-STATIC: 	movl	$262144, %eax
; LINUX-32-STATIC-NEXT: 	addl	ptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam02:
; LINUX-32-PIC: 	movl	$262144, %eax
; LINUX-32-PIC-NEXT: 	addl	ptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	(%rcx), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam02:
; DARWIN-32-STATIC: 	movl	$262144, %eax
; DARWIN-32-STATIC-NEXT: 	addl	_ptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	(%ecx), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam02:
; DARWIN-32-PIC: 	call	L103$pb
; DARWIN-32-PIC-NEXT: L103$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L103$pb(%eax), %ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-STATIC-NEXT: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	(%rcx), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-DYNAMIC-NEXT: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	(%rcx), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rcx
; DARWIN-64-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	(%rcx), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam03() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @dsrc, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam03:
; LINUX-64-STATIC: movl    $dsrc+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam03:
; LINUX-32-STATIC: 	movl	$dsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam03:
; LINUX-32-PIC: 	movl	$dsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam03:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam03:
; DARWIN-32-STATIC: 	movl	$_dsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam03:
; DARWIN-32-DYNAMIC: 	movl	$_dsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam03:
; DARWIN-32-PIC: 	call	L104$pb
; DARWIN-32-PIC-NEXT: L104$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_dsrc-L104$pb)+262144(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam03:
; DARWIN-64-STATIC: 	leaq	_dsrc+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam03:
; DARWIN-64-PIC: 	leaq	_dsrc+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam04() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @ddst, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam04:
; LINUX-64-STATIC: movl    $ddst+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam04:
; LINUX-32-STATIC: 	movl	$ddst+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam04:
; LINUX-32-PIC: 	movl	$ddst+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam04:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam04:
; DARWIN-32-STATIC: 	movl	$_ddst+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam04:
; DARWIN-32-DYNAMIC: 	movl	$_ddst+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam04:
; DARWIN-32-PIC: 	call	L105$pb
; DARWIN-32-PIC-NEXT: L105$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L105$pb)+262144(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam04:
; DARWIN-64-STATIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam04:
; DARWIN-64-PIC: 	leaq	_ddst+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam05() nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = getelementptr i32* %0, i64 65536
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bam05:
; LINUX-64-STATIC: movl    $262144, %eax
; LINUX-64-STATIC: addq    dptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam05:
; LINUX-32-STATIC: 	movl	$262144, %eax
; LINUX-32-STATIC-NEXT: 	addl	dptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam05:
; LINUX-32-PIC: 	movl	$262144, %eax
; LINUX-32-PIC-NEXT: 	addl	dptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rcx
; LINUX-64-PIC-NEXT: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	(%rcx), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam05:
; DARWIN-32-STATIC: 	movl	$262144, %eax
; DARWIN-32-STATIC-NEXT: 	addl	_dptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam05:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	_dptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam05:
; DARWIN-32-PIC: 	call	L106$pb
; DARWIN-32-PIC-NEXT: L106$pb:
; DARWIN-32-PIC-NEXT: 	popl	%ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	_dptr-L106$pb(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam05:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam05:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam05:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam06() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @lsrc, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam06:
; LINUX-64-STATIC: movl    $lsrc+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam06:
; LINUX-32-STATIC: 	movl	$lsrc+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam06:
; LINUX-32-PIC: 	movl	$lsrc+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam06:
; LINUX-64-PIC: 	leaq	lsrc+262144(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam06:
; DARWIN-32-STATIC: 	movl	$_lsrc+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam06:
; DARWIN-32-DYNAMIC: 	movl	$_lsrc+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam06:
; DARWIN-32-PIC: 	call	L107$pb
; DARWIN-32-PIC-NEXT: L107$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_lsrc-L107$pb)+262144(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam06:
; DARWIN-64-STATIC: 	leaq	_lsrc+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam06:
; DARWIN-64-PIC: 	leaq	_lsrc+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam07() nounwind {
entry:
	ret i8* bitcast (i32* getelementptr ([131072 x i32]* @ldst, i32 0, i64 65536) to i8*)
; LINUX-64-STATIC: bam07:
; LINUX-64-STATIC: movl    $ldst+262144, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam07:
; LINUX-32-STATIC: 	movl	$ldst+262144, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam07:
; LINUX-32-PIC: 	movl	$ldst+262144, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam07:
; LINUX-64-PIC: 	leaq	ldst+262144(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam07:
; DARWIN-32-STATIC: 	movl	$_ldst+262144, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam07:
; DARWIN-32-DYNAMIC: 	movl	$_ldst+262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam07:
; DARWIN-32-PIC: 	call	L108$pb
; DARWIN-32-PIC-NEXT: L108$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L108$pb)+262144(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam07:
; DARWIN-64-STATIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam07:
; DARWIN-64-PIC: 	leaq	_ldst+262144(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @bam08() nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = getelementptr i32* %0, i64 65536
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: bam08:
; LINUX-64-STATIC: movl    $262144, %eax
; LINUX-64-STATIC: addq    lptr(%rip), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: bam08:
; LINUX-32-STATIC: 	movl	$262144, %eax
; LINUX-32-STATIC-NEXT: 	addl	lptr, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: bam08:
; LINUX-32-PIC: 	movl	$262144, %eax
; LINUX-32-PIC-NEXT: 	addl	lptr, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: bam08:
; LINUX-64-PIC: 	movl	$262144, %eax
; LINUX-64-PIC-NEXT: 	addq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _bam08:
; DARWIN-32-STATIC: 	movl	$262144, %eax
; DARWIN-32-STATIC-NEXT: 	addl	_lptr, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _bam08:
; DARWIN-32-DYNAMIC: 	movl	$262144, %eax
; DARWIN-32-DYNAMIC-NEXT: 	addl	_lptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _bam08:
; DARWIN-32-PIC: 	call	L109$pb
; DARWIN-32-PIC-NEXT: L109$pb:
; DARWIN-32-PIC-NEXT: 	popl	%ecx
; DARWIN-32-PIC-NEXT: 	movl	$262144, %eax
; DARWIN-32-PIC-NEXT: 	addl	_lptr-L109$pb(%ecx), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _bam08:
; DARWIN-64-STATIC: 	movl	$262144, %eax
; DARWIN-64-STATIC-NEXT: 	addq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _bam08:
; DARWIN-64-DYNAMIC: 	movl	$262144, %eax
; DARWIN-64-DYNAMIC-NEXT: 	addq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _bam08:
; DARWIN-64-PIC: 	movl	$262144, %eax
; DARWIN-64-PIC-NEXT: 	addq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @src, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat00:
; LINUX-64-STATIC: leaq    src+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	src+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	src+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_src+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat00:
; DARWIN-32-PIC: 	call	L110$pb
; DARWIN-32-PIC-NEXT: L110$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L110$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cxt00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cxt00:
; LINUX-64-STATIC: leaq    xsrc+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cxt00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xsrc+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cxt00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xsrc+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cxt00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cxt00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xsrc+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cxt00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cxt00:
; DARWIN-32-PIC: 	call	L111$pb
; DARWIN-32-PIC-NEXT: L111$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L111$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cxt00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cxt00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cxt00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat01(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @dst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat01:
; LINUX-64-STATIC: leaq    dst+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat01:
; DARWIN-32-PIC: 	call	L112$pb
; DARWIN-32-PIC-NEXT: L112$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L112$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cxt01(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [32 x i32]* @xdst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cxt01:
; LINUX-64-STATIC: leaq    xdst+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cxt01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xdst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cxt01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xdst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cxt01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cxt01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xdst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cxt01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cxt01:
; DARWIN-32-PIC: 	call	L113$pb
; DARWIN-32-PIC-NEXT: L113$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L113$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cxt01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cxt01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cxt01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cat02:
; LINUX-64-STATIC: movq    ptr(%rip), %rax
; LINUX-64-STATIC: leaq    64(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat02:
; DARWIN-32-PIC: 	call	L114$pb
; DARWIN-32-PIC-NEXT: L114$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L114$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat03(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat03:
; LINUX-64-STATIC: leaq    dsrc+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat03:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dsrc+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat03:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dsrc+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat03:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dsrc+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat03:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_dsrc+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat03:
; DARWIN-32-PIC: 	call	L115$pb
; DARWIN-32-PIC-NEXT: L115$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_dsrc-L115$pb)+64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat04(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat04:
; LINUX-64-STATIC: leaq    ddst+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat04:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ddst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat04:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ddst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat04:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ddst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat04:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ddst+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat04:
; DARWIN-32-PIC: 	call	L116$pb
; DARWIN-32-PIC-NEXT: L116$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L116$pb)+64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cat05:
; LINUX-64-STATIC: movq    dptr(%rip), %rax
; LINUX-64-STATIC: leaq    64(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat05:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat05:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat05:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat05:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat05:
; DARWIN-32-PIC: 	call	L117$pb
; DARWIN-32-PIC-NEXT: L117$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L117$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat05:
; DARWIN-64-STATIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat05:
; DARWIN-64-DYNAMIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat05:
; DARWIN-64-PIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat06(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat06:
; LINUX-64-STATIC: leaq    lsrc+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat06:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	lsrc+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat06:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	lsrc+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat06:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_lsrc+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat06:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_lsrc+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat06:
; DARWIN-32-PIC: 	call	L118$pb
; DARWIN-32-PIC-NEXT: L118$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_lsrc-L118$pb)+64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat07(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 16
	%1 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cat07:
; LINUX-64-STATIC: leaq    ldst+64(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat07:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ldst+64(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat07:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ldst+64(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat07:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ldst+64(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat07:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ldst+64(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat07:
; DARWIN-32-PIC: 	call	L119$pb
; DARWIN-32-PIC-NEXT: L119$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L119$pb)+64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cat08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = add i64 %i, 16
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cat08:
; LINUX-64-STATIC: movq    lptr(%rip), %rax
; LINUX-64-STATIC: leaq    64(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cat08:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cat08:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cat08:
; LINUX-64-PIC: 	movq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cat08:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cat08:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	64(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cat08:
; DARWIN-32-PIC: 	call	L120$pb
; DARWIN-32-PIC-NEXT: L120$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L120$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	64(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cat08:
; DARWIN-64-STATIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cat08:
; DARWIN-64-DYNAMIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cat08:
; DARWIN-64-PIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	64(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @src, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam00:
; LINUX-64-STATIC: leaq    src+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	src+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	src+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam00:
; LINUX-64-PIC: 	movq	src@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_src+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_src$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam00:
; DARWIN-32-PIC: 	call	L121$pb
; DARWIN-32-PIC-NEXT: L121$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_src$non_lazy_ptr-L121$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam00:
; DARWIN-64-STATIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam00:
; DARWIN-64-DYNAMIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam00:
; DARWIN-64-PIC: 	movq	_src@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cxm00(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [32 x i32]* @xsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cxm00:
; LINUX-64-STATIC: leaq    xsrc+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cxm00:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xsrc+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cxm00:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xsrc+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cxm00:
; LINUX-64-PIC: 	movq	xsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cxm00:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xsrc+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cxm00:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xsrc$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cxm00:
; DARWIN-32-PIC: 	call	L122$pb
; DARWIN-32-PIC-NEXT: L122$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xsrc$non_lazy_ptr-L122$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cxm00:
; DARWIN-64-STATIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cxm00:
; DARWIN-64-DYNAMIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cxm00:
; DARWIN-64-PIC: 	movq	_xsrc@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam01(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @dst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam01:
; LINUX-64-STATIC: leaq    dst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam01:
; LINUX-64-PIC: 	movq	dst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_dst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam01:
; DARWIN-32-PIC: 	call	L123$pb
; DARWIN-32-PIC-NEXT: L123$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_dst$non_lazy_ptr-L123$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam01:
; DARWIN-64-STATIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam01:
; DARWIN-64-DYNAMIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam01:
; DARWIN-64-PIC: 	movq	_dst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cxm01(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [32 x i32]* @xdst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cxm01:
; LINUX-64-STATIC: leaq    xdst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cxm01:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	xdst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cxm01:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	xdst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cxm01:
; LINUX-64-PIC: 	movq	xdst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cxm01:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_xdst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cxm01:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_xdst$non_lazy_ptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cxm01:
; DARWIN-32-PIC: 	call	L124$pb
; DARWIN-32-PIC-NEXT: L124$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	L_xdst$non_lazy_ptr-L124$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cxm01:
; DARWIN-64-STATIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cxm01:
; DARWIN-64-DYNAMIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cxm01:
; DARWIN-64-PIC: 	movq	_xdst@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam02(i64 %i) nounwind {
entry:
	%0 = load i32** @ptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cam02:
; LINUX-64-STATIC: movq    ptr(%rip), %rax
; LINUX-64-STATIC: leaq    262144(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam02:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam02:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	ptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam02:
; LINUX-64-PIC: 	movq	ptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam02:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_ptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam02:
; DARWIN-32-DYNAMIC: 	movl	L_ptr$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam02:
; DARWIN-32-PIC: 	call	L125$pb
; DARWIN-32-PIC-NEXT: L125$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ptr$non_lazy_ptr-L125$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	(%eax), %eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam02:
; DARWIN-64-STATIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam02:
; DARWIN-64-DYNAMIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam02:
; DARWIN-64-PIC: 	movq	_ptr@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	movq	(%rax), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam03(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @dsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam03:
; LINUX-64-STATIC: leaq    dsrc+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam03:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	dsrc+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam03:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	dsrc+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam03:
; LINUX-64-PIC: 	movq	dsrc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam03:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_dsrc+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam03:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_dsrc+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam03:
; DARWIN-32-PIC: 	call	L126$pb
; DARWIN-32-PIC-NEXT: L126$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_dsrc-L126$pb)+262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam03:
; DARWIN-64-STATIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam03:
; DARWIN-64-DYNAMIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam03:
; DARWIN-64-PIC: 	leaq	_dsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam04(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @ddst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam04:
; LINUX-64-STATIC: leaq    ddst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam04:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ddst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam04:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ddst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam04:
; LINUX-64-PIC: 	movq	ddst@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam04:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ddst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam04:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ddst+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam04:
; DARWIN-32-PIC: 	call	L127$pb
; DARWIN-32-PIC-NEXT: L127$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ddst-L127$pb)+262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam04:
; DARWIN-64-STATIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam04:
; DARWIN-64-DYNAMIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam04:
; DARWIN-64-PIC: 	leaq	_ddst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam05(i64 %i) nounwind {
entry:
	%0 = load i32** @dptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cam05:
; LINUX-64-STATIC: movq    dptr(%rip), %rax
; LINUX-64-STATIC: leaq    262144(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam05:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam05:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	dptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam05:
; LINUX-64-PIC: 	movq	dptr@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	movq	(%rax), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam05:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam05:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_dptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam05:
; DARWIN-32-PIC: 	call	L128$pb
; DARWIN-32-PIC-NEXT: L128$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_dptr-L128$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam05:
; DARWIN-64-STATIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam05:
; DARWIN-64-DYNAMIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam05:
; DARWIN-64-PIC: 	movq	_dptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam06(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @lsrc, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam06:
; LINUX-64-STATIC: leaq    lsrc+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam06:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	lsrc+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam06:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	lsrc+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam06:
; LINUX-64-PIC: 	leaq	lsrc(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam06:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_lsrc+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam06:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_lsrc+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam06:
; DARWIN-32-PIC: 	call	L129$pb
; DARWIN-32-PIC-NEXT: L129$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_lsrc-L129$pb)+262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam06:
; DARWIN-64-STATIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam06:
; DARWIN-64-DYNAMIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam06:
; DARWIN-64-PIC: 	leaq	_lsrc(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam07(i64 %i) nounwind {
entry:
	%0 = add i64 %i, 65536
	%1 = getelementptr [131072 x i32]* @ldst, i64 0, i64 %0
	%2 = bitcast i32* %1 to i8*
	ret i8* %2
; LINUX-64-STATIC: cam07:
; LINUX-64-STATIC: leaq    ldst+262144(,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam07:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	leal	ldst+262144(,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam07:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	leal	ldst+262144(,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam07:
; LINUX-64-PIC: 	leaq	ldst(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam07:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	leal	_ldst+262144(,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam07:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	leal	_ldst+262144(,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam07:
; DARWIN-32-PIC: 	call	L130$pb
; DARWIN-32-PIC-NEXT: L130$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	leal	(_ldst-L130$pb)+262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam07:
; DARWIN-64-STATIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam07:
; DARWIN-64-DYNAMIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam07:
; DARWIN-64-PIC: 	leaq	_ldst(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define i8* @cam08(i64 %i) nounwind {
entry:
	%0 = load i32** @lptr, align 8
	%1 = add i64 %i, 65536
	%2 = getelementptr i32* %0, i64 %1
	%3 = bitcast i32* %2 to i8*
	ret i8* %3
; LINUX-64-STATIC: cam08:
; LINUX-64-STATIC: movq    lptr(%rip), %rax
; LINUX-64-STATIC: leaq    262144(%rax,%rdi,4), %rax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: cam08:
; LINUX-32-STATIC: 	movl	4(%esp), %eax
; LINUX-32-STATIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: cam08:
; LINUX-32-PIC: 	movl	4(%esp), %eax
; LINUX-32-PIC-NEXT: 	movl	lptr, %ecx
; LINUX-32-PIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: cam08:
; LINUX-64-PIC: 	movq	lptr(%rip), %rax
; LINUX-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _cam08:
; DARWIN-32-STATIC: 	movl	4(%esp), %eax
; DARWIN-32-STATIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-STATIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _cam08:
; DARWIN-32-DYNAMIC: 	movl	4(%esp), %eax
; DARWIN-32-DYNAMIC-NEXT: 	movl	_lptr, %ecx
; DARWIN-32-DYNAMIC-NEXT: 	leal	262144(%ecx,%eax,4), %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _cam08:
; DARWIN-32-PIC: 	call	L131$pb
; DARWIN-32-PIC-NEXT: L131$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	4(%esp), %ecx
; DARWIN-32-PIC-NEXT: 	movl	_lptr-L131$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	leal	262144(%eax,%ecx,4), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _cam08:
; DARWIN-64-STATIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _cam08:
; DARWIN-64-DYNAMIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _cam08:
; DARWIN-64-PIC: 	movq	_lptr(%rip), %rax
; DARWIN-64-PIC-NEXT: 	leaq	262144(%rax,%rdi,4), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define void @lcallee() nounwind {
entry:
	tail call void @x() nounwind
	tail call void @x() nounwind
	tail call void @x() nounwind
	tail call void @x() nounwind
	tail call void @x() nounwind
	tail call void @x() nounwind
	tail call void @x() nounwind
	ret void
; LINUX-64-STATIC: lcallee:
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: call    x
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: lcallee:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	call	x
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: lcallee:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	call	x
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: lcallee:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	call	x@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _lcallee:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	call	_x
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _lcallee:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_x$stub
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _lcallee:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	call	L_x$stub
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _lcallee:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	call	_x
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _lcallee:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	call	_x
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _lcallee:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	call	_x
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

declare void @x()

define internal void @dcallee() nounwind {
entry:
	tail call void @y() nounwind
	tail call void @y() nounwind
	tail call void @y() nounwind
	tail call void @y() nounwind
	tail call void @y() nounwind
	tail call void @y() nounwind
	tail call void @y() nounwind
	ret void
; LINUX-64-STATIC: dcallee:
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: call    y
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: dcallee:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	call	y
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: dcallee:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	call	y
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: dcallee:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	call	y@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _dcallee:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	call	_y
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _dcallee:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_y$stub
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _dcallee:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	call	L_y$stub
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _dcallee:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	call	_y
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _dcallee:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	call	_y
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _dcallee:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	call	_y
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

declare void @y()

define void ()* @address() nounwind {
entry:
	ret void ()* @callee
; LINUX-64-STATIC: address:
; LINUX-64-STATIC: movl    $callee, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: address:
; LINUX-32-STATIC: 	movl	$callee, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: address:
; LINUX-32-PIC: 	movl	$callee, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: address:
; LINUX-64-PIC: 	movq	callee@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _address:
; DARWIN-32-STATIC: 	movl	$_callee, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _address:
; DARWIN-32-DYNAMIC: 	movl	L_callee$non_lazy_ptr, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _address:
; DARWIN-32-PIC: 	call	L134$pb
; DARWIN-32-PIC-NEXT: L134$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_callee$non_lazy_ptr-L134$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _address:
; DARWIN-64-STATIC: 	movq	_callee@GOTPCREL(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _address:
; DARWIN-64-DYNAMIC: 	movq	_callee@GOTPCREL(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _address:
; DARWIN-64-PIC: 	movq	_callee@GOTPCREL(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

declare void @callee()

define void ()* @laddress() nounwind {
entry:
	ret void ()* @lcallee
; LINUX-64-STATIC: laddress:
; LINUX-64-STATIC: movl    $lcallee, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: laddress:
; LINUX-32-STATIC: 	movl	$lcallee, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: laddress:
; LINUX-32-PIC: 	movl	$lcallee, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: laddress:
; LINUX-64-PIC: 	movq	lcallee@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _laddress:
; DARWIN-32-STATIC: 	movl	$_lcallee, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _laddress:
; DARWIN-32-DYNAMIC: 	movl	$_lcallee, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _laddress:
; DARWIN-32-PIC: 	call	L135$pb
; DARWIN-32-PIC-NEXT: L135$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_lcallee-L135$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _laddress:
; DARWIN-64-STATIC: 	leaq	_lcallee(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _laddress:
; DARWIN-64-DYNAMIC: 	leaq	_lcallee(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _laddress:
; DARWIN-64-PIC: 	leaq	_lcallee(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define void ()* @daddress() nounwind {
entry:
	ret void ()* @dcallee
; LINUX-64-STATIC: daddress:
; LINUX-64-STATIC: movl    $dcallee, %eax
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: daddress:
; LINUX-32-STATIC: 	movl	$dcallee, %eax
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: daddress:
; LINUX-32-PIC: 	movl	$dcallee, %eax
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: daddress:
; LINUX-64-PIC: 	leaq	dcallee(%rip), %rax
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _daddress:
; DARWIN-32-STATIC: 	movl	$_dcallee, %eax
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _daddress:
; DARWIN-32-DYNAMIC: 	movl	$_dcallee, %eax
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _daddress:
; DARWIN-32-PIC: 	call	L136$pb
; DARWIN-32-PIC-NEXT: L136$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	leal	_dcallee-L136$pb(%eax), %eax
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _daddress:
; DARWIN-64-STATIC: 	leaq	_dcallee(%rip), %rax
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _daddress:
; DARWIN-64-DYNAMIC: 	leaq	_dcallee(%rip), %rax
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _daddress:
; DARWIN-64-PIC: 	leaq	_dcallee(%rip), %rax
; DARWIN-64-PIC-NEXT: 	ret
}

define void @caller() nounwind {
entry:
	tail call void @callee() nounwind
	tail call void @callee() nounwind
	ret void
; LINUX-64-STATIC: caller:
; LINUX-64-STATIC: call    callee
; LINUX-64-STATIC: call    callee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: caller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	callee
; LINUX-32-STATIC-NEXT: 	call	callee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: caller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	callee
; LINUX-32-PIC-NEXT: 	call	callee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: caller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	callee@PLT
; LINUX-64-PIC-NEXT: 	call	callee@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _caller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_callee
; DARWIN-32-STATIC-NEXT: 	call	_callee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _caller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	L_callee$stub
; DARWIN-32-DYNAMIC-NEXT: 	call	L_callee$stub
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _caller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L_callee$stub
; DARWIN-32-PIC-NEXT: 	call	L_callee$stub
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _caller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_callee
; DARWIN-64-STATIC-NEXT: 	call	_callee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _caller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_callee
; DARWIN-64-DYNAMIC-NEXT: 	call	_callee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _caller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_callee
; DARWIN-64-PIC-NEXT: 	call	_callee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @dcaller() nounwind {
entry:
	tail call void @dcallee() nounwind
	tail call void @dcallee() nounwind
	ret void
; LINUX-64-STATIC: dcaller:
; LINUX-64-STATIC: call    dcallee
; LINUX-64-STATIC: call    dcallee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: dcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	dcallee
; LINUX-32-STATIC-NEXT: 	call	dcallee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: dcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	dcallee
; LINUX-32-PIC-NEXT: 	call	dcallee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: dcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	dcallee
; LINUX-64-PIC-NEXT: 	call	dcallee
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _dcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_dcallee
; DARWIN-32-STATIC-NEXT: 	call	_dcallee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _dcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-32-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _dcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	_dcallee
; DARWIN-32-PIC-NEXT: 	call	_dcallee
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _dcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_dcallee
; DARWIN-64-STATIC-NEXT: 	call	_dcallee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _dcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-64-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _dcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_dcallee
; DARWIN-64-PIC-NEXT: 	call	_dcallee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @lcaller() nounwind {
entry:
	tail call void @lcallee() nounwind
	tail call void @lcallee() nounwind
	ret void
; LINUX-64-STATIC: lcaller:
; LINUX-64-STATIC: call    lcallee
; LINUX-64-STATIC: call    lcallee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: lcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	lcallee
; LINUX-32-STATIC-NEXT: 	call	lcallee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: lcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	lcallee
; LINUX-32-PIC-NEXT: 	call	lcallee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: lcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	lcallee@PLT
; LINUX-64-PIC-NEXT: 	call	lcallee@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _lcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_lcallee
; DARWIN-32-STATIC-NEXT: 	call	_lcallee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _lcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-32-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _lcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	_lcallee
; DARWIN-32-PIC-NEXT: 	call	_lcallee
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _lcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_lcallee
; DARWIN-64-STATIC-NEXT: 	call	_lcallee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _lcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-64-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _lcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_lcallee
; DARWIN-64-PIC-NEXT: 	call	_lcallee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @tailcaller() nounwind {
entry:
	tail call void @callee() nounwind
	ret void
; LINUX-64-STATIC: tailcaller:
; LINUX-64-STATIC: call    callee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: tailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	callee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: tailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	callee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: tailcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	callee@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _tailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_callee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _tailcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	L_callee$stub
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _tailcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L_callee$stub
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _tailcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_callee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _tailcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_callee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _tailcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_callee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @dtailcaller() nounwind {
entry:
	tail call void @dcallee() nounwind
	ret void
; LINUX-64-STATIC: dtailcaller:
; LINUX-64-STATIC: call    dcallee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: dtailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	dcallee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: dtailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	dcallee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: dtailcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	dcallee
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _dtailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_dcallee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _dtailcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _dtailcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	_dcallee
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _dtailcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_dcallee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _dtailcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_dcallee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _dtailcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_dcallee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ltailcaller() nounwind {
entry:
	tail call void @lcallee() nounwind
	ret void
; LINUX-64-STATIC: ltailcaller:
; LINUX-64-STATIC: call    lcallee
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ltailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	lcallee
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ltailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	lcallee
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ltailcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	lcallee@PLT
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ltailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	_lcallee
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ltailcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ltailcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	_lcallee
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ltailcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	_lcallee
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ltailcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	_lcallee
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ltailcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	_lcallee
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @icaller() nounwind {
entry:
	%0 = load void ()** @ifunc, align 8
	tail call void %0() nounwind
	%1 = load void ()** @ifunc, align 8
	tail call void %1() nounwind
	ret void
; LINUX-64-STATIC: icaller:
; LINUX-64-STATIC: call    *ifunc
; LINUX-64-STATIC: call    *ifunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: icaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*ifunc
; LINUX-32-STATIC-NEXT: 	call	*ifunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: icaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*ifunc
; LINUX-32-PIC-NEXT: 	call	*ifunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: icaller:
; LINUX-64-PIC: 	pushq	%rbx
; LINUX-64-PIC-NEXT: 	movq	ifunc@GOTPCREL(%rip), %rbx
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	popq	%rbx
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _icaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_ifunc
; DARWIN-32-STATIC-NEXT: 	call	*_ifunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _icaller:
; DARWIN-32-DYNAMIC: 	pushl	%esi
; DARWIN-32-DYNAMIC-NEXT: 	subl	$8, %esp
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ifunc$non_lazy_ptr, %esi
; DARWIN-32-DYNAMIC-NEXT: 	call	*(%esi)
; DARWIN-32-DYNAMIC-NEXT: 	call	*(%esi)
; DARWIN-32-DYNAMIC-NEXT: 	addl	$8, %esp
; DARWIN-32-DYNAMIC-NEXT: 	popl	%esi
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _icaller:
; DARWIN-32-PIC: 	pushl	%esi
; DARWIN-32-PIC-NEXT: 	subl	$8, %esp
; DARWIN-32-PIC-NEXT: 	call	L143$pb
; DARWIN-32-PIC-NEXT: L143$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ifunc$non_lazy_ptr-L143$pb(%eax), %esi
; DARWIN-32-PIC-NEXT: 	call	*(%esi)
; DARWIN-32-PIC-NEXT: 	call	*(%esi)
; DARWIN-32-PIC-NEXT: 	addl	$8, %esp
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _icaller:
; DARWIN-64-STATIC: 	pushq	%rbx
; DARWIN-64-STATIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-STATIC-NEXT: 	call	*(%rbx)
; DARWIN-64-STATIC-NEXT: 	call	*(%rbx)
; DARWIN-64-STATIC-NEXT: 	popq	%rbx
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _icaller:
; DARWIN-64-DYNAMIC: 	pushq	%rbx
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-DYNAMIC-NEXT: 	call	*(%rbx)
; DARWIN-64-DYNAMIC-NEXT: 	call	*(%rbx)
; DARWIN-64-DYNAMIC-NEXT: 	popq	%rbx
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _icaller:
; DARWIN-64-PIC: 	pushq	%rbx
; DARWIN-64-PIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-PIC-NEXT: 	call	*(%rbx)
; DARWIN-64-PIC-NEXT: 	call	*(%rbx)
; DARWIN-64-PIC-NEXT: 	popq	%rbx
; DARWIN-64-PIC-NEXT: 	ret
}

define void @dicaller() nounwind {
entry:
	%0 = load void ()** @difunc, align 8
	tail call void %0() nounwind
	%1 = load void ()** @difunc, align 8
	tail call void %1() nounwind
	ret void
; LINUX-64-STATIC: dicaller:
; LINUX-64-STATIC: call    *difunc
; LINUX-64-STATIC: call    *difunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: dicaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*difunc
; LINUX-32-STATIC-NEXT: 	call	*difunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: dicaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*difunc
; LINUX-32-PIC-NEXT: 	call	*difunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: dicaller:
; LINUX-64-PIC: 	pushq	%rbx
; LINUX-64-PIC-NEXT: 	movq	difunc@GOTPCREL(%rip), %rbx
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	popq	%rbx
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _dicaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_difunc
; DARWIN-32-STATIC-NEXT: 	call	*_difunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _dicaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	*_difunc
; DARWIN-32-DYNAMIC-NEXT: 	call	*_difunc
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _dicaller:
; DARWIN-32-PIC: 	pushl	%esi
; DARWIN-32-PIC-NEXT: 	subl	$8, %esp
; DARWIN-32-PIC-NEXT: 	call	L144$pb
; DARWIN-32-PIC-NEXT: L144$pb:
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	call	*_difunc-L144$pb(%esi)
; DARWIN-32-PIC-NEXT: 	call	*_difunc-L144$pb(%esi)
; DARWIN-32-PIC-NEXT: 	addl	$8, %esp
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _dicaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-STATIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _dicaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _dicaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-PIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @licaller() nounwind {
entry:
	%0 = load void ()** @lifunc, align 8
	tail call void %0() nounwind
	%1 = load void ()** @lifunc, align 8
	tail call void %1() nounwind
	ret void
; LINUX-64-STATIC: licaller:
; LINUX-64-STATIC: call    *lifunc
; LINUX-64-STATIC: call    *lifunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: licaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*lifunc
; LINUX-32-STATIC-NEXT: 	call	*lifunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: licaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*lifunc
; LINUX-32-PIC-NEXT: 	call	*lifunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: licaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	*lifunc(%rip)
; LINUX-64-PIC-NEXT: 	call	*lifunc(%rip)
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _licaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_lifunc
; DARWIN-32-STATIC-NEXT: 	call	*_lifunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _licaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	*_lifunc
; DARWIN-32-DYNAMIC-NEXT: 	call	*_lifunc
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _licaller:
; DARWIN-32-PIC: 	pushl	%esi
; DARWIN-32-PIC-NEXT: 	subl	$8, %esp
; DARWIN-32-PIC-NEXT: 	call	L145$pb
; DARWIN-32-PIC-NEXT: L145$pb:
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	call	*_lifunc-L145$pb(%esi)
; DARWIN-32-PIC-NEXT: 	call	*_lifunc-L145$pb(%esi)
; DARWIN-32-PIC-NEXT: 	addl	$8, %esp
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _licaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-STATIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _licaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _licaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-PIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @itailcaller() nounwind {
entry:
	%0 = load void ()** @ifunc, align 8
	tail call void %0() nounwind
	%1 = load void ()** @ifunc, align 8
	tail call void %1() nounwind
	ret void
; LINUX-64-STATIC: itailcaller:
; LINUX-64-STATIC: call    *ifunc
; LINUX-64-STATIC: call    *ifunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: itailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*ifunc
; LINUX-32-STATIC-NEXT: 	call	*ifunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: itailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*ifunc
; LINUX-32-PIC-NEXT: 	call	*ifunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: itailcaller:
; LINUX-64-PIC: 	pushq	%rbx
; LINUX-64-PIC-NEXT: 	movq	ifunc@GOTPCREL(%rip), %rbx
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	call	*(%rbx)
; LINUX-64-PIC-NEXT: 	popq	%rbx
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _itailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_ifunc
; DARWIN-32-STATIC-NEXT: 	call	*_ifunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _itailcaller:
; DARWIN-32-DYNAMIC: 	pushl	%esi
; DARWIN-32-DYNAMIC-NEXT: 	subl	$8, %esp
; DARWIN-32-DYNAMIC-NEXT: 	movl	L_ifunc$non_lazy_ptr, %esi
; DARWIN-32-DYNAMIC-NEXT: 	call	*(%esi)
; DARWIN-32-DYNAMIC-NEXT: 	call	*(%esi)
; DARWIN-32-DYNAMIC-NEXT: 	addl	$8, %esp
; DARWIN-32-DYNAMIC-NEXT: 	popl	%esi
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _itailcaller:
; DARWIN-32-PIC: 	pushl	%esi
; DARWIN-32-PIC-NEXT: 	subl	$8, %esp
; DARWIN-32-PIC-NEXT: 	call	L146$pb
; DARWIN-32-PIC-NEXT: L146$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	movl	L_ifunc$non_lazy_ptr-L146$pb(%eax), %esi
; DARWIN-32-PIC-NEXT: 	call	*(%esi)
; DARWIN-32-PIC-NEXT: 	call	*(%esi)
; DARWIN-32-PIC-NEXT: 	addl	$8, %esp
; DARWIN-32-PIC-NEXT: 	popl	%esi
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _itailcaller:
; DARWIN-64-STATIC: 	pushq	%rbx
; DARWIN-64-STATIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-STATIC-NEXT: 	call	*(%rbx)
; DARWIN-64-STATIC-NEXT: 	call	*(%rbx)
; DARWIN-64-STATIC-NEXT: 	popq	%rbx
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _itailcaller:
; DARWIN-64-DYNAMIC: 	pushq	%rbx
; DARWIN-64-DYNAMIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-DYNAMIC-NEXT: 	call	*(%rbx)
; DARWIN-64-DYNAMIC-NEXT: 	call	*(%rbx)
; DARWIN-64-DYNAMIC-NEXT: 	popq	%rbx
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _itailcaller:
; DARWIN-64-PIC: 	pushq	%rbx
; DARWIN-64-PIC-NEXT: 	movq	_ifunc@GOTPCREL(%rip), %rbx
; DARWIN-64-PIC-NEXT: 	call	*(%rbx)
; DARWIN-64-PIC-NEXT: 	call	*(%rbx)
; DARWIN-64-PIC-NEXT: 	popq	%rbx
; DARWIN-64-PIC-NEXT: 	ret
}

define void @ditailcaller() nounwind {
entry:
	%0 = load void ()** @difunc, align 8
	tail call void %0() nounwind
	ret void
; LINUX-64-STATIC: ditailcaller:
; LINUX-64-STATIC: call    *difunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: ditailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*difunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: ditailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*difunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: ditailcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	movq	difunc@GOTPCREL(%rip), %rax
; LINUX-64-PIC-NEXT: 	call	*(%rax)
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _ditailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_difunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _ditailcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	*_difunc
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _ditailcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L147$pb
; DARWIN-32-PIC-NEXT: L147$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	call	*_difunc-L147$pb(%eax)
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _ditailcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _ditailcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	*_difunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _ditailcaller:
; DARWIN-64-PIC: 	call	*_difunc(%rip)
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}

define void @litailcaller() nounwind {
entry:
	%0 = load void ()** @lifunc, align 8
	tail call void %0() nounwind
	ret void
; LINUX-64-STATIC: litailcaller:
; LINUX-64-STATIC: call    *lifunc
; LINUX-64-STATIC: ret

; LINUX-32-STATIC: litailcaller:
; LINUX-32-STATIC: 	subl	$4, %esp
; LINUX-32-STATIC-NEXT: 	call	*lifunc
; LINUX-32-STATIC-NEXT: 	addl	$4, %esp
; LINUX-32-STATIC-NEXT: 	ret

; LINUX-32-PIC: litailcaller:
; LINUX-32-PIC: 	subl	$4, %esp
; LINUX-32-PIC-NEXT: 	call	*lifunc
; LINUX-32-PIC-NEXT: 	addl	$4, %esp
; LINUX-32-PIC-NEXT: 	ret

; LINUX-64-PIC: litailcaller:
; LINUX-64-PIC: 	subq	$8, %rsp
; LINUX-64-PIC-NEXT: 	call	*lifunc(%rip)
; LINUX-64-PIC-NEXT: 	addq	$8, %rsp
; LINUX-64-PIC-NEXT: 	ret

; DARWIN-32-STATIC: _litailcaller:
; DARWIN-32-STATIC: 	subl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	call	*_lifunc
; DARWIN-32-STATIC-NEXT: 	addl	$12, %esp
; DARWIN-32-STATIC-NEXT: 	ret

; DARWIN-32-DYNAMIC: _litailcaller:
; DARWIN-32-DYNAMIC: 	subl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	call	*_lifunc
; DARWIN-32-DYNAMIC-NEXT: 	addl	$12, %esp
; DARWIN-32-DYNAMIC-NEXT: 	ret

; DARWIN-32-PIC: _litailcaller:
; DARWIN-32-PIC: 	subl	$12, %esp
; DARWIN-32-PIC-NEXT: 	call	L148$pb
; DARWIN-32-PIC-NEXT: L148$pb:
; DARWIN-32-PIC-NEXT: 	popl	%eax
; DARWIN-32-PIC-NEXT: 	call	*_lifunc-L148$pb(%eax)
; DARWIN-32-PIC-NEXT: 	addl	$12, %esp
; DARWIN-32-PIC-NEXT: 	ret

; DARWIN-64-STATIC: _litailcaller:
; DARWIN-64-STATIC: 	subq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-STATIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-STATIC-NEXT: 	ret

; DARWIN-64-DYNAMIC: _litailcaller:
; DARWIN-64-DYNAMIC: 	subq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-DYNAMIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-DYNAMIC-NEXT: 	ret

; DARWIN-64-PIC: _litailcaller:
; DARWIN-64-PIC: 	subq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	call	*_lifunc(%rip)
; DARWIN-64-PIC-NEXT: 	addq	$8, %rsp
; DARWIN-64-PIC-NEXT: 	ret
}
