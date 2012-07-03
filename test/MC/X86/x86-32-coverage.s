// RUN: llvm-mc -triple i386-unknown-unknown %s --show-encoding  | FileCheck %s

// CHECK: 	movb	$127, 3735928559(%ebx,%ecx,8)
        	movb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movw	$31438, 3735928559(%ebx,%ecx,8)
        	movw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movl	$2063514302, 3735928559(%ebx,%ecx,8)
        	movl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movl	$324478056, 3735928559(%ebx,%ecx,8)
        	movl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movsbl	3735928559(%ebx,%ecx,8), %ecx
        	movsbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movswl	3735928559(%ebx,%ecx,8), %ecx
        	movswl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movzbl	3735928559(%ebx,%ecx,8), %ecx
        	movzbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movzwl	3735928559(%ebx,%ecx,8), %ecx
        	movzwl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	pushl	3735928559(%ebx,%ecx,8)
        	pushl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	popl	3735928559(%ebx,%ecx,8)
        	popl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	lahf
        	lahf

// CHECK: 	sahf
        	sahf

// CHECK: 	addb	$254, 3735928559(%ebx,%ecx,8)
        	addb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addb	$127, 3735928559(%ebx,%ecx,8)
        	addb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addw	$31438, 3735928559(%ebx,%ecx,8)
        	addw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addl	$2063514302, 3735928559(%ebx,%ecx,8)
        	addl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addl	$324478056, 3735928559(%ebx,%ecx,8)
        	addl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	incl	3735928559(%ebx,%ecx,8)
        	incl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subb	$254, 3735928559(%ebx,%ecx,8)
        	subb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subb	$127, 3735928559(%ebx,%ecx,8)
        	subb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subw	$31438, 3735928559(%ebx,%ecx,8)
        	subw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subl	$2063514302, 3735928559(%ebx,%ecx,8)
        	subl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subl	$324478056, 3735928559(%ebx,%ecx,8)
        	subl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	decl	3735928559(%ebx,%ecx,8)
        	decl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbw	$31438, 3735928559(%ebx,%ecx,8)
        	sbbw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbl	$2063514302, 3735928559(%ebx,%ecx,8)
        	sbbl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbl	$324478056, 3735928559(%ebx,%ecx,8)
        	sbbl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpb	$254, 3735928559(%ebx,%ecx,8)
        	cmpb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpb	$127, 3735928559(%ebx,%ecx,8)
        	cmpb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpw	$31438, 3735928559(%ebx,%ecx,8)
        	cmpw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpl	$2063514302, 3735928559(%ebx,%ecx,8)
        	cmpl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpl	$324478056, 3735928559(%ebx,%ecx,8)
        	cmpl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testb	$127, 3735928559(%ebx,%ecx,8)
        	testb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testw	$31438, 3735928559(%ebx,%ecx,8)
        	testw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testl	$2063514302, 3735928559(%ebx,%ecx,8)
        	testl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testl	$324478056, 3735928559(%ebx,%ecx,8)
        	testl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andb	$254, 3735928559(%ebx,%ecx,8)
        	andb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andb	$127, 3735928559(%ebx,%ecx,8)
        	andb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andw	$31438, 3735928559(%ebx,%ecx,8)
        	andw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andl	$2063514302, 3735928559(%ebx,%ecx,8)
        	andl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andl	$324478056, 3735928559(%ebx,%ecx,8)
        	andl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orb	$254, 3735928559(%ebx,%ecx,8)
        	orb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orb	$127, 3735928559(%ebx,%ecx,8)
        	orb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orw	$31438, 3735928559(%ebx,%ecx,8)
        	orw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orl	$2063514302, 3735928559(%ebx,%ecx,8)
        	orl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orl	$324478056, 3735928559(%ebx,%ecx,8)
        	orl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorb	$254, 3735928559(%ebx,%ecx,8)
        	xorb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorb	$127, 3735928559(%ebx,%ecx,8)
        	xorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorw	$31438, 3735928559(%ebx,%ecx,8)
        	xorw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorl	$2063514302, 3735928559(%ebx,%ecx,8)
        	xorl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorl	$324478056, 3735928559(%ebx,%ecx,8)
        	xorl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcb	$254, 3735928559(%ebx,%ecx,8)
        	adcb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcb	$127, 3735928559(%ebx,%ecx,8)
        	adcb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcw	$31438, 3735928559(%ebx,%ecx,8)
        	adcw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcl	$2063514302, 3735928559(%ebx,%ecx,8)
        	adcl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcl	$324478056, 3735928559(%ebx,%ecx,8)
        	adcl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	negl	3735928559(%ebx,%ecx,8)
        	negl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	notl	3735928559(%ebx,%ecx,8)
        	notl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cbtw
        	cbtw

// CHECK: 	cwtl
        	cwtl

// CHECK: 	cwtd
        	cwtd

// CHECK: 	cltd
        	cltd

// CHECK: 	mull	3735928559(%ebx,%ecx,8)
        	mull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	imull	3735928559(%ebx,%ecx,8)
        	imull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	divl	3735928559(%ebx,%ecx,8)
        	divl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	idivl	3735928559(%ebx,%ecx,8)
        	idivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	roll	$0, 3735928559(%ebx,%ecx,8)
        	roll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rolb	$127, 3735928559(%ebx,%ecx,8)
        	rolb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	roll	3735928559(%ebx,%ecx,8)
        	roll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorl	$0, 3735928559(%ebx,%ecx,8)
        	rorl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorb	$127, 3735928559(%ebx,%ecx,8)
        	rorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorl	3735928559(%ebx,%ecx,8)
        	rorl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shll	$0, 3735928559(%ebx,%ecx,8)
        	shll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shlb	$127, 3735928559(%ebx,%ecx,8)
        	shlb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shll	3735928559(%ebx,%ecx,8)
        	shll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrl	$0, 3735928559(%ebx,%ecx,8)
        	shrl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrb	$127, 3735928559(%ebx,%ecx,8)
        	shrb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrl	3735928559(%ebx,%ecx,8)
        	shrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarl	$0, 3735928559(%ebx,%ecx,8)
        	sarl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarb	$127, 3735928559(%ebx,%ecx,8)
        	sarb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarl	3735928559(%ebx,%ecx,8)
        	sarl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	calll	*%ecx
        	call	*%ecx

// CHECK: 	calll	*3735928559(%ebx,%ecx,8)
        	call	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	calll	*3735928559(%ebx,%ecx,8)
        	call	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	jmpl	*3735928559(%ebx,%ecx,8)
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	jmpl	*3735928559(%ebx,%ecx,8)
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ljmpl	*3735928559(%ebx,%ecx,8)
        	ljmpl	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	lret
        	lret

// CHECK: 	leave
        	leave

// CHECK: 	leave
        	leavel

// CHECK: 	seto	%bl
        	seto	%bl

// CHECK: 	seto	3735928559(%ebx,%ecx,8)
        	seto	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setno	%bl
        	setno	%bl

// CHECK: 	setno	3735928559(%ebx,%ecx,8)
        	setno	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setb	%bl
        	setb	%bl

// CHECK: 	setb	3735928559(%ebx,%ecx,8)
        	setb	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setae	%bl
        	setae	%bl

// CHECK: 	setae	3735928559(%ebx,%ecx,8)
        	setae	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sete	%bl
        	sete	%bl

// CHECK: 	sete	3735928559(%ebx,%ecx,8)
        	sete	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setne	%bl
        	setne	%bl

// CHECK: 	setne	3735928559(%ebx,%ecx,8)
        	setne	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setbe	%bl
        	setbe	%bl

// CHECK: 	setbe	3735928559(%ebx,%ecx,8)
        	setbe	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	seta	%bl
        	seta	%bl

// CHECK: 	seta	3735928559(%ebx,%ecx,8)
        	seta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sets	%bl
        	sets	%bl

// CHECK: 	sets	3735928559(%ebx,%ecx,8)
        	sets	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setns	%bl
        	setns	%bl

// CHECK: 	setns	3735928559(%ebx,%ecx,8)
        	setns	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setp	%bl
        	setp	%bl

// CHECK: 	setp	3735928559(%ebx,%ecx,8)
        	setp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setnp	%bl
        	setnp	%bl

// CHECK: 	setnp	3735928559(%ebx,%ecx,8)
        	setnp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setl	%bl
        	setl	%bl

// CHECK: 	setl	3735928559(%ebx,%ecx,8)
        	setl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setge	%bl
        	setge	%bl

// CHECK: 	setge	3735928559(%ebx,%ecx,8)
        	setge	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setle	%bl
        	setle	%bl

// CHECK: 	setle	3735928559(%ebx,%ecx,8)
        	setle	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setg	%bl
        	setg	%bl

// CHECK: 	setg	3735928559(%ebx,%ecx,8)
        	setg	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	nopl	3735928559(%ebx,%ecx,8)
        	nopl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	nop
        	nop

// CHECK: flds	(%edi)
// CHECK:  encoding: [0xd9,0x07]
        	flds	(%edi)

// CHECK: filds	(%edi)
// CHECK:  encoding: [0xdf,0x07]
        	filds	(%edi)

// CHECK: 	fldl	3735928559(%ebx,%ecx,8)
        	fldl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fildl	3735928559(%ebx,%ecx,8)
        	fildl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fildll	3735928559(%ebx,%ecx,8)
        	fildll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fldt	3735928559(%ebx,%ecx,8)
        	fldt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fbld	3735928559(%ebx,%ecx,8)
        	fbld	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstl	3735928559(%ebx,%ecx,8)
        	fstl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistl	3735928559(%ebx,%ecx,8)
        	fistl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstpl	3735928559(%ebx,%ecx,8)
        	fstpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistpl	3735928559(%ebx,%ecx,8)
        	fistpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistpll	3735928559(%ebx,%ecx,8)
        	fistpll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstpt	3735928559(%ebx,%ecx,8)
        	fstpt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fbstp	3735928559(%ebx,%ecx,8)
        	fbstp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ficoml	3735928559(%ebx,%ecx,8)
        	ficoml	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ficompl	3735928559(%ebx,%ecx,8)
        	ficompl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fucompp
        	fucompp

// CHECK: 	ftst
        	ftst

// CHECK: 	fld1
        	fld1

// CHECK: 	fldz
        	fldz

// CHECK: 	faddl	3735928559(%ebx,%ecx,8)
        	faddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fiaddl	3735928559(%ebx,%ecx,8)
        	fiaddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fsubl	3735928559(%ebx,%ecx,8)
        	fsubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fisubl	3735928559(%ebx,%ecx,8)
        	fisubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fsubrl	3735928559(%ebx,%ecx,8)
        	fsubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fisubrl	3735928559(%ebx,%ecx,8)
        	fisubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fmull	3735928559(%ebx,%ecx,8)
        	fmull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fimull	3735928559(%ebx,%ecx,8)
        	fimull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fdivl	3735928559(%ebx,%ecx,8)
        	fdivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fidivl	3735928559(%ebx,%ecx,8)
        	fidivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fdivrl	3735928559(%ebx,%ecx,8)
        	fdivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fidivrl	3735928559(%ebx,%ecx,8)
        	fidivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fsqrt
        	fsqrt

// CHECK: 	fsin
        	fsin

// CHECK: 	fcos
        	fcos

// CHECK: 	fchs
        	fchs

// CHECK: 	fabs
        	fabs

// CHECK: 	fldcw	3735928559(%ebx,%ecx,8)
        	fldcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fnstcw	3735928559(%ebx,%ecx,8)
        	fnstcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rdtsc
        	rdtsc

// CHECK: 	sysenter
        	sysenter

// CHECK: 	sysexit
        	sysexit

// CHECK: 	sysexitl
        	sysexitl

// CHECK: 	ud2
        	ud2

// CHECK: 	movntil	%ecx, 3735928559(%ebx,%ecx,8)
        	movnti	%ecx,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	clflush	3735928559(%ebx,%ecx,8)
        	clflush	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	emms
        	emms

// CHECK: 	movd	%ecx, %mm3
        	movd	%ecx,%mm3

// CHECK: 	movd	3735928559(%ebx,%ecx,8), %mm3
        	movd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	movd	%ecx, %xmm5
        	movd	%ecx,%xmm5

// CHECK: 	movd	3735928559(%ebx,%ecx,8), %xmm5
        	movd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movd	%xmm5, %ecx
        	movd	%xmm5,%ecx

// CHECK: 	movd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movq	3735928559(%ebx,%ecx,8), %mm3
        	movq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	movq	%mm3, %mm3
        	movq	%mm3,%mm3

// CHECK: 	movq	%mm3, %mm3
        	movq	%mm3,%mm3

// CHECK: 	movq	%xmm5, %xmm5
        	movq	%xmm5,%xmm5

// CHECK: 	movq	%xmm5, %xmm5
        	movq	%xmm5,%xmm5

// CHECK: 	packssdw	%mm3, %mm3
        	packssdw	%mm3,%mm3

// CHECK: 	packssdw	%xmm5, %xmm5
        	packssdw	%xmm5,%xmm5

// CHECK: 	packsswb	%mm3, %mm3
        	packsswb	%mm3,%mm3

// CHECK: 	packsswb	%xmm5, %xmm5
        	packsswb	%xmm5,%xmm5

// CHECK: 	packuswb	%mm3, %mm3
        	packuswb	%mm3,%mm3

// CHECK: 	packuswb	%xmm5, %xmm5
        	packuswb	%xmm5,%xmm5

// CHECK: 	paddb	%mm3, %mm3
        	paddb	%mm3,%mm3

// CHECK: 	paddb	%xmm5, %xmm5
        	paddb	%xmm5,%xmm5

// CHECK: 	paddw	%mm3, %mm3
        	paddw	%mm3,%mm3

// CHECK: 	paddw	%xmm5, %xmm5
        	paddw	%xmm5,%xmm5

// CHECK: 	paddd	%mm3, %mm3
        	paddd	%mm3,%mm3

// CHECK: 	paddd	%xmm5, %xmm5
        	paddd	%xmm5,%xmm5

// CHECK: 	paddq	%mm3, %mm3
        	paddq	%mm3,%mm3

// CHECK: 	paddq	%xmm5, %xmm5
        	paddq	%xmm5,%xmm5

// CHECK: 	paddsb	%mm3, %mm3
        	paddsb	%mm3,%mm3

// CHECK: 	paddsb	%xmm5, %xmm5
        	paddsb	%xmm5,%xmm5

// CHECK: 	paddsw	%mm3, %mm3
        	paddsw	%mm3,%mm3

// CHECK: 	paddsw	%xmm5, %xmm5
        	paddsw	%xmm5,%xmm5

// CHECK: 	paddusb	%mm3, %mm3
        	paddusb	%mm3,%mm3

// CHECK: 	paddusb	%xmm5, %xmm5
        	paddusb	%xmm5,%xmm5

// CHECK: 	paddusw	%mm3, %mm3
        	paddusw	%mm3,%mm3

// CHECK: 	paddusw	%xmm5, %xmm5
        	paddusw	%xmm5,%xmm5

// CHECK: 	pand	%mm3, %mm3
        	pand	%mm3,%mm3

// CHECK: 	pand	%xmm5, %xmm5
        	pand	%xmm5,%xmm5

// CHECK: 	pandn	%mm3, %mm3
        	pandn	%mm3,%mm3

// CHECK: 	pandn	%xmm5, %xmm5
        	pandn	%xmm5,%xmm5

// CHECK: 	pcmpeqb	%mm3, %mm3
        	pcmpeqb	%mm3,%mm3

// CHECK: 	pcmpeqb	%xmm5, %xmm5
        	pcmpeqb	%xmm5,%xmm5

// CHECK: 	pcmpeqw	%mm3, %mm3
        	pcmpeqw	%mm3,%mm3

// CHECK: 	pcmpeqw	%xmm5, %xmm5
        	pcmpeqw	%xmm5,%xmm5

// CHECK: 	pcmpeqd	%mm3, %mm3
        	pcmpeqd	%mm3,%mm3

// CHECK: 	pcmpeqd	%xmm5, %xmm5
        	pcmpeqd	%xmm5,%xmm5

// CHECK: 	pcmpgtb	%mm3, %mm3
        	pcmpgtb	%mm3,%mm3

// CHECK: 	pcmpgtb	%xmm5, %xmm5
        	pcmpgtb	%xmm5,%xmm5

// CHECK: 	pcmpgtw	%mm3, %mm3
        	pcmpgtw	%mm3,%mm3

// CHECK: 	pcmpgtw	%xmm5, %xmm5
        	pcmpgtw	%xmm5,%xmm5

// CHECK: 	pcmpgtd	%mm3, %mm3
        	pcmpgtd	%mm3,%mm3

// CHECK: 	pcmpgtd	%xmm5, %xmm5
        	pcmpgtd	%xmm5,%xmm5

// CHECK: 	pmaddwd	%mm3, %mm3
        	pmaddwd	%mm3,%mm3

// CHECK: 	pmaddwd	%xmm5, %xmm5
        	pmaddwd	%xmm5,%xmm5

// CHECK: 	pmulhw	%mm3, %mm3
        	pmulhw	%mm3,%mm3

// CHECK: 	pmulhw	%xmm5, %xmm5
        	pmulhw	%xmm5,%xmm5

// CHECK: 	pmullw	%mm3, %mm3
        	pmullw	%mm3,%mm3

// CHECK: 	pmullw	%xmm5, %xmm5
        	pmullw	%xmm5,%xmm5

// CHECK: 	por	%mm3, %mm3
        	por	%mm3,%mm3

// CHECK: 	por	%xmm5, %xmm5
        	por	%xmm5,%xmm5

// CHECK: 	psllw	%mm3, %mm3
        	psllw	%mm3,%mm3

// CHECK: 	psllw	%xmm5, %xmm5
        	psllw	%xmm5,%xmm5

// CHECK: 	psllw	$127, %mm3
        	psllw	$0x7f,%mm3

// CHECK: 	psllw	$127, %xmm5
        	psllw	$0x7f,%xmm5

// CHECK: 	pslld	%mm3, %mm3
        	pslld	%mm3,%mm3

// CHECK: 	pslld	%xmm5, %xmm5
        	pslld	%xmm5,%xmm5

// CHECK: 	pslld	$127, %mm3
        	pslld	$0x7f,%mm3

// CHECK: 	pslld	$127, %xmm5
        	pslld	$0x7f,%xmm5

// CHECK: 	psllq	%mm3, %mm3
        	psllq	%mm3,%mm3

// CHECK: 	psllq	%xmm5, %xmm5
        	psllq	%xmm5,%xmm5

// CHECK: 	psllq	$127, %mm3
        	psllq	$0x7f,%mm3

// CHECK: 	psllq	$127, %xmm5
        	psllq	$0x7f,%xmm5

// CHECK: 	psraw	%mm3, %mm3
        	psraw	%mm3,%mm3

// CHECK: 	psraw	%xmm5, %xmm5
        	psraw	%xmm5,%xmm5

// CHECK: 	psraw	$127, %mm3
        	psraw	$0x7f,%mm3

// CHECK: 	psraw	$127, %xmm5
        	psraw	$0x7f,%xmm5

// CHECK: 	psrad	%mm3, %mm3
        	psrad	%mm3,%mm3

// CHECK: 	psrad	%xmm5, %xmm5
        	psrad	%xmm5,%xmm5

// CHECK: 	psrad	$127, %mm3
        	psrad	$0x7f,%mm3

// CHECK: 	psrad	$127, %xmm5
        	psrad	$0x7f,%xmm5

// CHECK: 	psrlw	%mm3, %mm3
        	psrlw	%mm3,%mm3

// CHECK: 	psrlw	%xmm5, %xmm5
        	psrlw	%xmm5,%xmm5

// CHECK: 	psrlw	$127, %mm3
        	psrlw	$0x7f,%mm3

// CHECK: 	psrlw	$127, %xmm5
        	psrlw	$0x7f,%xmm5

// CHECK: 	psrld	%mm3, %mm3
        	psrld	%mm3,%mm3

// CHECK: 	psrld	%xmm5, %xmm5
        	psrld	%xmm5,%xmm5

// CHECK: 	psrld	$127, %mm3
        	psrld	$0x7f,%mm3

// CHECK: 	psrld	$127, %xmm5
        	psrld	$0x7f,%xmm5

// CHECK: 	psrlq	%mm3, %mm3
        	psrlq	%mm3,%mm3

// CHECK: 	psrlq	%xmm5, %xmm5
        	psrlq	%xmm5,%xmm5

// CHECK: 	psrlq	$127, %mm3
        	psrlq	$0x7f,%mm3

// CHECK: 	psrlq	$127, %xmm5
        	psrlq	$0x7f,%xmm5

// CHECK: 	psubb	%mm3, %mm3
        	psubb	%mm3,%mm3

// CHECK: 	psubb	%xmm5, %xmm5
        	psubb	%xmm5,%xmm5

// CHECK: 	psubw	%mm3, %mm3
        	psubw	%mm3,%mm3

// CHECK: 	psubw	%xmm5, %xmm5
        	psubw	%xmm5,%xmm5

// CHECK: 	psubd	%mm3, %mm3
        	psubd	%mm3,%mm3

// CHECK: 	psubd	%xmm5, %xmm5
        	psubd	%xmm5,%xmm5

// CHECK: 	psubq	%mm3, %mm3
        	psubq	%mm3,%mm3

// CHECK: 	psubq	%xmm5, %xmm5
        	psubq	%xmm5,%xmm5

// CHECK: 	psubsb	%mm3, %mm3
        	psubsb	%mm3,%mm3

// CHECK: 	psubsb	%xmm5, %xmm5
        	psubsb	%xmm5,%xmm5

// CHECK: 	psubsw	%mm3, %mm3
        	psubsw	%mm3,%mm3

// CHECK: 	psubsw	%xmm5, %xmm5
        	psubsw	%xmm5,%xmm5

// CHECK: 	psubusb	%mm3, %mm3
        	psubusb	%mm3,%mm3

// CHECK: 	psubusb	%xmm5, %xmm5
        	psubusb	%xmm5,%xmm5

// CHECK: 	psubusw	%mm3, %mm3
        	psubusw	%mm3,%mm3

// CHECK: 	psubusw	%xmm5, %xmm5
        	psubusw	%xmm5,%xmm5

// CHECK: 	punpckhbw	%mm3, %mm3
        	punpckhbw	%mm3,%mm3

// CHECK: 	punpckhbw	%xmm5, %xmm5
        	punpckhbw	%xmm5,%xmm5

// CHECK: 	punpckhwd	%mm3, %mm3
        	punpckhwd	%mm3,%mm3

// CHECK: 	punpckhwd	%xmm5, %xmm5
        	punpckhwd	%xmm5,%xmm5

// CHECK: 	punpckhdq	%mm3, %mm3
        	punpckhdq	%mm3,%mm3

// CHECK: 	punpckhdq	%xmm5, %xmm5
        	punpckhdq	%xmm5,%xmm5

// CHECK: 	punpcklbw	%mm3, %mm3
        	punpcklbw	%mm3,%mm3

// CHECK: 	punpcklbw	%xmm5, %xmm5
        	punpcklbw	%xmm5,%xmm5

// CHECK: 	punpcklwd	%mm3, %mm3
        	punpcklwd	%mm3,%mm3

// CHECK: 	punpcklwd	%xmm5, %xmm5
        	punpcklwd	%xmm5,%xmm5

// CHECK: 	punpckldq	%mm3, %mm3
        	punpckldq	%mm3,%mm3

// CHECK: 	punpckldq	%xmm5, %xmm5
        	punpckldq	%xmm5,%xmm5

// CHECK: 	pxor	%mm3, %mm3
        	pxor	%mm3,%mm3

// CHECK: 	pxor	%xmm5, %xmm5
        	pxor	%xmm5,%xmm5

// CHECK: 	addps	%xmm5, %xmm5
        	addps	%xmm5,%xmm5

// CHECK: 	addss	%xmm5, %xmm5
        	addss	%xmm5,%xmm5

// CHECK: 	andnps	%xmm5, %xmm5
        	andnps	%xmm5,%xmm5

// CHECK: 	andps	%xmm5, %xmm5
        	andps	%xmm5,%xmm5

// CHECK: 	cvtpi2ps	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpi2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpi2ps	%mm3, %xmm5
        	cvtpi2ps	%mm3,%xmm5

// CHECK: 	cvtps2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvtps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvtps2pi	%xmm5, %mm3
        	cvtps2pi	%xmm5,%mm3

// CHECK: 	cvtsi2ss	%ecx, %xmm5
        	cvtsi2ss	%ecx,%xmm5

// CHECK: 	cvtsi2ss	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsi2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvttps2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvttps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvttps2pi	%xmm5, %mm3
        	cvttps2pi	%xmm5,%mm3

// CHECK: 	cvttss2si	3735928559(%ebx,%ecx,8), %ecx
        	cvttss2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	cvttss2si	%xmm5, %ecx
        	cvttss2si	%xmm5,%ecx

// CHECK: 	divps	%xmm5, %xmm5
        	divps	%xmm5,%xmm5

// CHECK: 	divss	%xmm5, %xmm5
        	divss	%xmm5,%xmm5

// CHECK: 	ldmxcsr	3735928559(%ebx,%ecx,8)
        	ldmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	maskmovq	%mm3, %mm3
        	maskmovq	%mm3,%mm3

// CHECK: 	maxps	%xmm5, %xmm5
        	maxps	%xmm5,%xmm5

// CHECK: 	maxss	%xmm5, %xmm5
        	maxss	%xmm5,%xmm5

// CHECK: 	minps	%xmm5, %xmm5
        	minps	%xmm5,%xmm5

// CHECK: 	minss	%xmm5, %xmm5
        	minss	%xmm5,%xmm5

// CHECK: 	movaps	3735928559(%ebx,%ecx,8), %xmm5
        	movaps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movaps	%xmm5, %xmm5
        	movaps	%xmm5,%xmm5

// CHECK: 	movaps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movaps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movaps	%xmm5, %xmm5
        	movaps	%xmm5,%xmm5

// CHECK: 	movhlps	%xmm5, %xmm5
        	movhlps	%xmm5,%xmm5

// CHECK: 	movhps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movhps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movlhps	%xmm5, %xmm5
        	movlhps	%xmm5,%xmm5

// CHECK: 	movlps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movlps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movmskps	%xmm5, %ecx
        	movmskps	%xmm5,%ecx

// CHECK: 	movntps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntq	%mm3, 3735928559(%ebx,%ecx,8)
        	movntq	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntdq	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntdq	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movss	3735928559(%ebx,%ecx,8), %xmm5
        	movss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movss	%xmm5, %xmm5
        	movss	%xmm5,%xmm5

// CHECK: 	movss	%xmm5, 3735928559(%ebx,%ecx,8)
        	movss	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movss	%xmm5, %xmm5
        	movss	%xmm5,%xmm5

// CHECK: 	movups	3735928559(%ebx,%ecx,8), %xmm5
        	movups	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movups	%xmm5, %xmm5
        	movups	%xmm5,%xmm5

// CHECK: 	movups	%xmm5, 3735928559(%ebx,%ecx,8)
        	movups	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movups	%xmm5, %xmm5
        	movups	%xmm5,%xmm5

// CHECK: 	mulps	%xmm5, %xmm5
        	mulps	%xmm5,%xmm5

// CHECK: 	mulss	%xmm5, %xmm5
        	mulss	%xmm5,%xmm5

// CHECK: 	orps	%xmm5, %xmm5
        	orps	%xmm5,%xmm5

// CHECK: 	pavgb	%mm3, %mm3
        	pavgb	%mm3,%mm3

// CHECK: 	pavgb	%xmm5, %xmm5
        	pavgb	%xmm5,%xmm5

// CHECK: 	pavgw	%mm3, %mm3
        	pavgw	%mm3,%mm3

// CHECK: 	pavgw	%xmm5, %xmm5
        	pavgw	%xmm5,%xmm5

// CHECK: 	pmaxsw	%mm3, %mm3
        	pmaxsw	%mm3,%mm3

// CHECK: 	pmaxsw	%xmm5, %xmm5
        	pmaxsw	%xmm5,%xmm5

// CHECK: 	pmaxub	%mm3, %mm3
        	pmaxub	%mm3,%mm3

// CHECK: 	pmaxub	%xmm5, %xmm5
        	pmaxub	%xmm5,%xmm5

// CHECK: 	pminsw	%mm3, %mm3
        	pminsw	%mm3,%mm3

// CHECK: 	pminsw	%xmm5, %xmm5
        	pminsw	%xmm5,%xmm5

// CHECK: 	pminub	%mm3, %mm3
        	pminub	%mm3,%mm3

// CHECK: 	pminub	%xmm5, %xmm5
        	pminub	%xmm5,%xmm5

// CHECK: 	pmovmskb	%mm3, %ecx
        	pmovmskb	%mm3,%ecx

// CHECK: 	pmovmskb	%xmm5, %ecx
        	pmovmskb	%xmm5,%ecx

// CHECK: 	pmulhuw	%mm3, %mm3
        	pmulhuw	%mm3,%mm3

// CHECK: 	pmulhuw	%xmm5, %xmm5
        	pmulhuw	%xmm5,%xmm5

// CHECK: 	prefetchnta	3735928559(%ebx,%ecx,8)
        	prefetchnta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht0	3735928559(%ebx,%ecx,8)
        	prefetcht0	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht1	3735928559(%ebx,%ecx,8)
        	prefetcht1	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht2	3735928559(%ebx,%ecx,8)
        	prefetcht2	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	psadbw	%mm3, %mm3
        	psadbw	%mm3,%mm3

// CHECK: 	psadbw	%xmm5, %xmm5
        	psadbw	%xmm5,%xmm5

// CHECK: 	rcpps	3735928559(%ebx,%ecx,8), %xmm5
        	rcpps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rcpps	%xmm5, %xmm5
        	rcpps	%xmm5,%xmm5

// CHECK: 	rcpss	3735928559(%ebx,%ecx,8), %xmm5
        	rcpss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rcpss	%xmm5, %xmm5
        	rcpss	%xmm5,%xmm5

// CHECK: 	rsqrtps	3735928559(%ebx,%ecx,8), %xmm5
        	rsqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rsqrtps	%xmm5, %xmm5
        	rsqrtps	%xmm5,%xmm5

// CHECK: 	rsqrtss	3735928559(%ebx,%ecx,8), %xmm5
        	rsqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rsqrtss	%xmm5, %xmm5
        	rsqrtss	%xmm5,%xmm5

// CHECK: 	sqrtps	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtps	%xmm5, %xmm5
        	sqrtps	%xmm5,%xmm5

// CHECK: 	sqrtss	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtss	%xmm5, %xmm5
        	sqrtss	%xmm5,%xmm5

// CHECK: 	stmxcsr	3735928559(%ebx,%ecx,8)
        	stmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subps	%xmm5, %xmm5
        	subps	%xmm5,%xmm5

// CHECK: 	subss	%xmm5, %xmm5
        	subss	%xmm5,%xmm5

// CHECK: 	ucomiss	3735928559(%ebx,%ecx,8), %xmm5
        	ucomiss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ucomiss	%xmm5, %xmm5
        	ucomiss	%xmm5,%xmm5

// CHECK: 	unpckhps	%xmm5, %xmm5
        	unpckhps	%xmm5,%xmm5

// CHECK: 	unpcklps	%xmm5, %xmm5
        	unpcklps	%xmm5,%xmm5

// CHECK: 	xorps	%xmm5, %xmm5
        	xorps	%xmm5,%xmm5

// CHECK: 	addpd	%xmm5, %xmm5
        	addpd	%xmm5,%xmm5

// CHECK: 	addsd	%xmm5, %xmm5
        	addsd	%xmm5,%xmm5

// CHECK: 	andnpd	%xmm5, %xmm5
        	andnpd	%xmm5,%xmm5

// CHECK: 	andpd	%xmm5, %xmm5
        	andpd	%xmm5,%xmm5

// CHECK: 	comisd	3735928559(%ebx,%ecx,8), %xmm5
        	comisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	comisd	%xmm5, %xmm5
        	comisd	%xmm5,%xmm5

// CHECK: 	cvtpi2pd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpi2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpi2pd	%mm3, %xmm5
        	cvtpi2pd	%mm3,%xmm5

// CHECK: 	cvtsi2sd	%ecx, %xmm5
        	cvtsi2sd	%ecx,%xmm5

// CHECK: 	cvtsi2sd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsi2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	divpd	%xmm5, %xmm5
        	divpd	%xmm5,%xmm5

// CHECK: 	divsd	%xmm5, %xmm5
        	divsd	%xmm5,%xmm5

// CHECK: 	maxpd	%xmm5, %xmm5
        	maxpd	%xmm5,%xmm5

// CHECK: 	maxsd	%xmm5, %xmm5
        	maxsd	%xmm5,%xmm5

// CHECK: 	minpd	%xmm5, %xmm5
        	minpd	%xmm5,%xmm5

// CHECK: 	minsd	%xmm5, %xmm5
        	minsd	%xmm5,%xmm5

// CHECK: 	movapd	3735928559(%ebx,%ecx,8), %xmm5
        	movapd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movapd	%xmm5, %xmm5
        	movapd	%xmm5,%xmm5

// CHECK: 	movapd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movapd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movapd	%xmm5, %xmm5
        	movapd	%xmm5,%xmm5

// CHECK: 	movhpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movhpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movlpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movlpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movmskpd	%xmm5, %ecx
        	movmskpd	%xmm5,%ecx

// CHECK: 	movntpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movsd	3735928559(%ebx,%ecx,8), %xmm5
        	movsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movsd	%xmm5, %xmm5
        	movsd	%xmm5,%xmm5

// CHECK: 	movsd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movsd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movsd	%xmm5, %xmm5
        	movsd	%xmm5,%xmm5

// CHECK: 	movupd	3735928559(%ebx,%ecx,8), %xmm5
        	movupd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movupd	%xmm5, %xmm5
        	movupd	%xmm5,%xmm5

// CHECK: 	movupd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movupd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movupd	%xmm5, %xmm5
        	movupd	%xmm5,%xmm5

// CHECK: 	mulpd	%xmm5, %xmm5
        	mulpd	%xmm5,%xmm5

// CHECK: 	mulsd	%xmm5, %xmm5
        	mulsd	%xmm5,%xmm5

// CHECK: 	orpd	%xmm5, %xmm5
        	orpd	%xmm5,%xmm5

// CHECK: 	sqrtpd	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtpd	%xmm5, %xmm5
        	sqrtpd	%xmm5,%xmm5

// CHECK: 	sqrtsd	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtsd	%xmm5, %xmm5
        	sqrtsd	%xmm5,%xmm5

// CHECK: 	subpd	%xmm5, %xmm5
        	subpd	%xmm5,%xmm5

// CHECK: 	subsd	%xmm5, %xmm5
        	subsd	%xmm5,%xmm5

// CHECK: 	ucomisd	3735928559(%ebx,%ecx,8), %xmm5
        	ucomisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ucomisd	%xmm5, %xmm5
        	ucomisd	%xmm5,%xmm5

// CHECK: 	unpckhpd	%xmm5, %xmm5
        	unpckhpd	%xmm5,%xmm5

// CHECK: 	unpcklpd	%xmm5, %xmm5
        	unpcklpd	%xmm5,%xmm5

// CHECK: 	xorpd	%xmm5, %xmm5
        	xorpd	%xmm5,%xmm5

// CHECK: 	cvtdq2pd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtdq2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtdq2pd	%xmm5, %xmm5
        	cvtdq2pd	%xmm5,%xmm5

// CHECK: 	cvtpd2dq	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpd2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpd2dq	%xmm5, %xmm5
        	cvtpd2dq	%xmm5,%xmm5

// CHECK: 	cvtdq2ps	3735928559(%ebx,%ecx,8), %xmm5
        	cvtdq2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtdq2ps	%xmm5, %xmm5
        	cvtdq2ps	%xmm5,%xmm5

// CHECK: 	cvtpd2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvtpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvtpd2pi	%xmm5, %mm3
        	cvtpd2pi	%xmm5,%mm3

// CHECK: 	cvtps2dq	3735928559(%ebx,%ecx,8), %xmm5
        	cvtps2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtps2dq	%xmm5, %xmm5
        	cvtps2dq	%xmm5,%xmm5

// CHECK: 	cvtsd2ss	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsd2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtsd2ss	%xmm5, %xmm5
        	cvtsd2ss	%xmm5,%xmm5

// CHECK: 	cvtss2sd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtss2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtss2sd	%xmm5, %xmm5
        	cvtss2sd	%xmm5,%xmm5

// CHECK: 	cvttpd2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvttpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvttpd2pi	%xmm5, %mm3
        	cvttpd2pi	%xmm5,%mm3

// CHECK: 	cvttsd2si	3735928559(%ebx,%ecx,8), %ecx
        	cvttsd2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	cvttsd2si	%xmm5, %ecx
        	cvttsd2si	%xmm5,%ecx

// CHECK: 	maskmovdqu	%xmm5, %xmm5
        	maskmovdqu	%xmm5,%xmm5

// CHECK: 	movdqa	3735928559(%ebx,%ecx,8), %xmm5
        	movdqa	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movdqa	%xmm5, %xmm5
        	movdqa	%xmm5,%xmm5

// CHECK: 	movdqa	%xmm5, 3735928559(%ebx,%ecx,8)
        	movdqa	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movdqa	%xmm5, %xmm5
        	movdqa	%xmm5,%xmm5

// CHECK: 	movdqu	3735928559(%ebx,%ecx,8), %xmm5
        	movdqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movdqu	%xmm5, 3735928559(%ebx,%ecx,8)
        	movdqu	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movdq2q	%xmm5, %mm3
        	movdq2q	%xmm5,%mm3

// CHECK: 	movq2dq	%mm3, %xmm5
        	movq2dq	%mm3,%xmm5

// CHECK: 	pmuludq	%mm3, %mm3
        	pmuludq	%mm3,%mm3

// CHECK: 	pmuludq	%xmm5, %xmm5
        	pmuludq	%xmm5,%xmm5

// CHECK: 	pslldq	$127, %xmm5
        	pslldq	$0x7f,%xmm5

// CHECK: 	psrldq	$127, %xmm5
        	psrldq	$0x7f,%xmm5

// CHECK: 	punpckhqdq	%xmm5, %xmm5
        	punpckhqdq	%xmm5,%xmm5

// CHECK: 	punpcklqdq	%xmm5, %xmm5
        	punpcklqdq	%xmm5,%xmm5

// CHECK: 	addsubpd	%xmm5, %xmm5
        	addsubpd	%xmm5,%xmm5

// CHECK: 	addsubps	%xmm5, %xmm5
        	addsubps	%xmm5,%xmm5

// CHECK: 	haddpd	%xmm5, %xmm5
        	haddpd	%xmm5,%xmm5

// CHECK: 	haddps	%xmm5, %xmm5
        	haddps	%xmm5,%xmm5

// CHECK: 	hsubpd	%xmm5, %xmm5
        	hsubpd	%xmm5,%xmm5

// CHECK: 	hsubps	%xmm5, %xmm5
        	hsubps	%xmm5,%xmm5

// CHECK: 	lddqu	3735928559(%ebx,%ecx,8), %xmm5
        	lddqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movddup	3735928559(%ebx,%ecx,8), %xmm5
        	movddup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movddup	%xmm5, %xmm5
        	movddup	%xmm5,%xmm5

// CHECK: 	movshdup	3735928559(%ebx,%ecx,8), %xmm5
        	movshdup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movshdup	%xmm5, %xmm5
        	movshdup	%xmm5,%xmm5

// CHECK: 	movsldup	3735928559(%ebx,%ecx,8), %xmm5
        	movsldup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movsldup	%xmm5, %xmm5
        	movsldup	%xmm5,%xmm5

// CHECK: 	phaddw	%mm3, %mm3
        	phaddw	%mm3,%mm3

// CHECK: 	phaddw	%xmm5, %xmm5
        	phaddw	%xmm5,%xmm5

// CHECK: 	phaddd	%mm3, %mm3
        	phaddd	%mm3,%mm3

// CHECK: 	phaddd	%xmm5, %xmm5
        	phaddd	%xmm5,%xmm5

// CHECK: 	phaddsw	%mm3, %mm3
        	phaddsw	%mm3,%mm3

// CHECK: 	phaddsw	%xmm5, %xmm5
        	phaddsw	%xmm5,%xmm5

// CHECK: 	phsubw	%mm3, %mm3
        	phsubw	%mm3,%mm3

// CHECK: 	phsubw	%xmm5, %xmm5
        	phsubw	%xmm5,%xmm5

// CHECK: 	phsubd	%mm3, %mm3
        	phsubd	%mm3,%mm3

// CHECK: 	phsubd	%xmm5, %xmm5
        	phsubd	%xmm5,%xmm5

// CHECK: 	phsubsw	%mm3, %mm3
        	phsubsw	%mm3,%mm3

// CHECK: 	phsubsw	%xmm5, %xmm5
        	phsubsw	%xmm5,%xmm5

// CHECK: 	pmaddubsw	%mm3, %mm3
        	pmaddubsw	%mm3,%mm3

// CHECK: 	pmaddubsw	%xmm5, %xmm5
        	pmaddubsw	%xmm5,%xmm5

// CHECK: 	pmulhrsw	%mm3, %mm3
        	pmulhrsw	%mm3,%mm3

// CHECK: 	pmulhrsw	%xmm5, %xmm5
        	pmulhrsw	%xmm5,%xmm5

// CHECK: 	pshufb	%mm3, %mm3
        	pshufb	%mm3,%mm3

// CHECK: 	pshufb	%xmm5, %xmm5
        	pshufb	%xmm5,%xmm5

// CHECK: 	psignb	%mm3, %mm3
        	psignb	%mm3,%mm3

// CHECK: 	psignb	%xmm5, %xmm5
        	psignb	%xmm5,%xmm5

// CHECK: 	psignw	%mm3, %mm3
        	psignw	%mm3,%mm3

// CHECK: 	psignw	%xmm5, %xmm5
        	psignw	%xmm5,%xmm5

// CHECK: 	psignd	%mm3, %mm3
        	psignd	%mm3,%mm3

// CHECK: 	psignd	%xmm5, %xmm5
        	psignd	%xmm5,%xmm5

// CHECK: 	pabsb	3735928559(%ebx,%ecx,8), %mm3
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsb	%mm3, %mm3
        	pabsb	%mm3,%mm3

// CHECK: 	pabsb	3735928559(%ebx,%ecx,8), %xmm5
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsb	%xmm5, %xmm5
        	pabsb	%xmm5,%xmm5

// CHECK: 	pabsw	3735928559(%ebx,%ecx,8), %mm3
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsw	%mm3, %mm3
        	pabsw	%mm3,%mm3

// CHECK: 	pabsw	3735928559(%ebx,%ecx,8), %xmm5
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsw	%xmm5, %xmm5
        	pabsw	%xmm5,%xmm5

// CHECK: 	pabsd	3735928559(%ebx,%ecx,8), %mm3
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsd	%mm3, %mm3
        	pabsd	%mm3,%mm3

// CHECK: 	pabsd	3735928559(%ebx,%ecx,8), %xmm5
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsd	%xmm5, %xmm5
        	pabsd	%xmm5,%xmm5

// CHECK: 	femms
        	femms

// CHECK: 	packusdw	%xmm5, %xmm5
        	packusdw	%xmm5,%xmm5

// CHECK: 	pcmpeqq	%xmm5, %xmm5
        	pcmpeqq	%xmm5,%xmm5

// CHECK: 	phminposuw	3735928559(%ebx,%ecx,8), %xmm5
        	phminposuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phminposuw	%xmm5, %xmm5
        	phminposuw	%xmm5,%xmm5

// CHECK: 	pmaxsb	%xmm5, %xmm5
        	pmaxsb	%xmm5,%xmm5

// CHECK: 	pmaxsd	%xmm5, %xmm5
        	pmaxsd	%xmm5,%xmm5

// CHECK: 	pmaxud	%xmm5, %xmm5
        	pmaxud	%xmm5,%xmm5

// CHECK: 	pmaxuw	%xmm5, %xmm5
        	pmaxuw	%xmm5,%xmm5

// CHECK: 	pminsb	%xmm5, %xmm5
        	pminsb	%xmm5,%xmm5

// CHECK: 	pminsd	%xmm5, %xmm5
        	pminsd	%xmm5,%xmm5

// CHECK: 	pminud	%xmm5, %xmm5
        	pminud	%xmm5,%xmm5

// CHECK: 	pminuw	%xmm5, %xmm5
        	pminuw	%xmm5,%xmm5

// CHECK: 	pmovsxbw	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbw	%xmm5, %xmm5
        	pmovsxbw	%xmm5,%xmm5

// CHECK: 	pmovsxbd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbd	%xmm5, %xmm5
        	pmovsxbd	%xmm5,%xmm5

// CHECK: 	pmovsxbq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbq	%xmm5, %xmm5
        	pmovsxbq	%xmm5,%xmm5

// CHECK: 	pmovsxwd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxwd	%xmm5, %xmm5
        	pmovsxwd	%xmm5,%xmm5

// CHECK: 	pmovsxwq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxwq	%xmm5, %xmm5
        	pmovsxwq	%xmm5,%xmm5

// CHECK: 	pmovsxdq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxdq	%xmm5, %xmm5
        	pmovsxdq	%xmm5,%xmm5

// CHECK: 	pmovzxbw	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbw	%xmm5, %xmm5
        	pmovzxbw	%xmm5,%xmm5

// CHECK: 	pmovzxbd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbd	%xmm5, %xmm5
        	pmovzxbd	%xmm5,%xmm5

// CHECK: 	pmovzxbq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbq	%xmm5, %xmm5
        	pmovzxbq	%xmm5,%xmm5

// CHECK: 	pmovzxwd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxwd	%xmm5, %xmm5
        	pmovzxwd	%xmm5,%xmm5

// CHECK: 	pmovzxwq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxwq	%xmm5, %xmm5
        	pmovzxwq	%xmm5,%xmm5

// CHECK: 	pmovzxdq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxdq	%xmm5, %xmm5
        	pmovzxdq	%xmm5,%xmm5

// CHECK: 	pmuldq	%xmm5, %xmm5
        	pmuldq	%xmm5,%xmm5

// CHECK: 	pmulld	%xmm5, %xmm5
        	pmulld	%xmm5,%xmm5

// CHECK: 	ptest 	3735928559(%ebx,%ecx,8), %xmm5
        	ptest	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ptest 	%xmm5, %xmm5
        	ptest	%xmm5,%xmm5

// CHECK: 	pcmpgtq	%xmm5, %xmm5
        	pcmpgtq	%xmm5,%xmm5


// CHECK: movb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc6,0x84,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	movb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movb	$127, 69
// CHECK:  encoding: [0xc6,0x05,0x45,0x00,0x00,0x00,0x7f]
        	movb	$0x7f,0x45

// CHECK: movb	$127, 32493
// CHECK:  encoding: [0xc6,0x05,0xed,0x7e,0x00,0x00,0x7f]
        	movb	$0x7f,0x7eed

// CHECK: movb	$127, 3133065982
// CHECK:  encoding: [0xc6,0x05,0xfe,0xca,0xbe,0xba,0x7f]
        	movb	$0x7f,0xbabecafe

// CHECK: movb	$127, 305419896
// CHECK:  encoding: [0xc6,0x05,0x78,0x56,0x34,0x12,0x7f]
        	movb	$0x7f,0x12345678

// CHECK: movw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0xc7,0x84,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	movw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movw	$31438, 69
// CHECK:  encoding: [0x66,0xc7,0x05,0x45,0x00,0x00,0x00,0xce,0x7a]
        	movw	$0x7ace,0x45

// CHECK: movw	$31438, 32493
// CHECK:  encoding: [0x66,0xc7,0x05,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	movw	$0x7ace,0x7eed

// CHECK: movw	$31438, 3133065982
// CHECK:  encoding: [0x66,0xc7,0x05,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	movw	$0x7ace,0xbabecafe

// CHECK: movw	$31438, 305419896
// CHECK:  encoding: [0x66,0xc7,0x05,0x78,0x56,0x34,0x12,0xce,0x7a]
        	movw	$0x7ace,0x12345678

// CHECK: movl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc7,0x84,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	movl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movl	$2063514302, 69
// CHECK:  encoding: [0xc7,0x05,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	movl	$0x7afebabe,0x45

// CHECK: movl	$2063514302, 32493
// CHECK:  encoding: [0xc7,0x05,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	movl	$0x7afebabe,0x7eed

// CHECK: movl	$2063514302, 3133065982
// CHECK:  encoding: [0xc7,0x05,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	movl	$0x7afebabe,0xbabecafe

// CHECK: movl	$2063514302, 305419896
// CHECK:  encoding: [0xc7,0x05,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	movl	$0x7afebabe,0x12345678

// CHECK: movl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc7,0x84,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	movl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movl	$324478056, 69
// CHECK:  encoding: [0xc7,0x05,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	movl	$0x13572468,0x45

// CHECK: movl	$324478056, 32493
// CHECK:  encoding: [0xc7,0x05,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	movl	$0x13572468,0x7eed

// CHECK: movl	$324478056, 3133065982
// CHECK:  encoding: [0xc7,0x05,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	movl	$0x13572468,0xbabecafe

// CHECK: movl	$324478056, 305419896
// CHECK:  encoding: [0xc7,0x05,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	movl	$0x13572468,0x12345678

// CHECK: movsbl	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0x0f,0xbe,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	movsbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: movsbl	69, %ecx
// CHECK:  encoding: [0x0f,0xbe,0x0d,0x45,0x00,0x00,0x00]
        	movsbl	0x45,%ecx

// CHECK: movsbl	32493, %ecx
// CHECK:  encoding: [0x0f,0xbe,0x0d,0xed,0x7e,0x00,0x00]
        	movsbl	0x7eed,%ecx

// CHECK: movsbl	3133065982, %ecx
// CHECK:  encoding: [0x0f,0xbe,0x0d,0xfe,0xca,0xbe,0xba]
        	movsbl	0xbabecafe,%ecx

// CHECK: movsbl	305419896, %ecx
// CHECK:  encoding: [0x0f,0xbe,0x0d,0x78,0x56,0x34,0x12]
        	movsbl	0x12345678,%ecx

// CHECK: movsbw	3735928559(%ebx,%ecx,8), %bx
// CHECK:  encoding: [0x66,0x0f,0xbe,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movsbw	0xdeadbeef(%ebx,%ecx,8),%bx

// CHECK: movsbw	69, %bx
// CHECK:  encoding: [0x66,0x0f,0xbe,0x1d,0x45,0x00,0x00,0x00]
        	movsbw	0x45,%bx

// CHECK: movsbw	32493, %bx
// CHECK:  encoding: [0x66,0x0f,0xbe,0x1d,0xed,0x7e,0x00,0x00]
        	movsbw	0x7eed,%bx

// CHECK: movsbw	3133065982, %bx
// CHECK:  encoding: [0x66,0x0f,0xbe,0x1d,0xfe,0xca,0xbe,0xba]
        	movsbw	0xbabecafe,%bx

// CHECK: movsbw	305419896, %bx
// CHECK:  encoding: [0x66,0x0f,0xbe,0x1d,0x78,0x56,0x34,0x12]
        	movsbw	0x12345678,%bx

// CHECK: movswl	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0x0f,0xbf,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	movswl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: movswl	69, %ecx
// CHECK:  encoding: [0x0f,0xbf,0x0d,0x45,0x00,0x00,0x00]
        	movswl	0x45,%ecx

// CHECK: movswl	32493, %ecx
// CHECK:  encoding: [0x0f,0xbf,0x0d,0xed,0x7e,0x00,0x00]
        	movswl	0x7eed,%ecx

// CHECK: movswl	3133065982, %ecx
// CHECK:  encoding: [0x0f,0xbf,0x0d,0xfe,0xca,0xbe,0xba]
        	movswl	0xbabecafe,%ecx

// CHECK: movswl	305419896, %ecx
// CHECK:  encoding: [0x0f,0xbf,0x0d,0x78,0x56,0x34,0x12]
        	movswl	0x12345678,%ecx

// CHECK: movzbl	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0x0f,0xb6,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	movzbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: movzbl	69, %ecx
// CHECK:  encoding: [0x0f,0xb6,0x0d,0x45,0x00,0x00,0x00]
        	movzbl	0x45,%ecx

// CHECK: movzbl	32493, %ecx
// CHECK:  encoding: [0x0f,0xb6,0x0d,0xed,0x7e,0x00,0x00]
        	movzbl	0x7eed,%ecx

// CHECK: movzbl	3133065982, %ecx
// CHECK:  encoding: [0x0f,0xb6,0x0d,0xfe,0xca,0xbe,0xba]
        	movzbl	0xbabecafe,%ecx

// CHECK: movzbl	305419896, %ecx
// CHECK:  encoding: [0x0f,0xb6,0x0d,0x78,0x56,0x34,0x12]
        	movzbl	0x12345678,%ecx

// CHECK: movzbw	3735928559(%ebx,%ecx,8), %bx
// CHECK:  encoding: [0x66,0x0f,0xb6,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movzbw	0xdeadbeef(%ebx,%ecx,8),%bx

// CHECK: movzbw	69, %bx
// CHECK:  encoding: [0x66,0x0f,0xb6,0x1d,0x45,0x00,0x00,0x00]
        	movzbw	0x45,%bx

// CHECK: movzbw	32493, %bx
// CHECK:  encoding: [0x66,0x0f,0xb6,0x1d,0xed,0x7e,0x00,0x00]
        	movzbw	0x7eed,%bx

// CHECK: movzbw	3133065982, %bx
// CHECK:  encoding: [0x66,0x0f,0xb6,0x1d,0xfe,0xca,0xbe,0xba]
        	movzbw	0xbabecafe,%bx

// CHECK: movzbw	305419896, %bx
// CHECK:  encoding: [0x66,0x0f,0xb6,0x1d,0x78,0x56,0x34,0x12]
        	movzbw	0x12345678,%bx

// CHECK: movzwl	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0x0f,0xb7,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	movzwl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: movzwl	69, %ecx
// CHECK:  encoding: [0x0f,0xb7,0x0d,0x45,0x00,0x00,0x00]
        	movzwl	0x45,%ecx

// CHECK: movzwl	32493, %ecx
// CHECK:  encoding: [0x0f,0xb7,0x0d,0xed,0x7e,0x00,0x00]
        	movzwl	0x7eed,%ecx

// CHECK: movzwl	3133065982, %ecx
// CHECK:  encoding: [0x0f,0xb7,0x0d,0xfe,0xca,0xbe,0xba]
        	movzwl	0xbabecafe,%ecx

// CHECK: movzwl	305419896, %ecx
// CHECK:  encoding: [0x0f,0xb7,0x0d,0x78,0x56,0x34,0x12]
        	movzwl	0x12345678,%ecx

// CHECK: pushl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	pushl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: pushw	32493
// CHECK:  encoding: [0x66,0xff,0x35,0xed,0x7e,0x00,0x00]
        	pushw	0x7eed

// CHECK: pushl	3133065982
// CHECK:  encoding: [0xff,0x35,0xfe,0xca,0xbe,0xba]
        	pushl	0xbabecafe

// CHECK: pushl	305419896
// CHECK:  encoding: [0xff,0x35,0x78,0x56,0x34,0x12]
        	pushl	0x12345678

// CHECK: popl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x8f,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	popl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: popw	32493
// CHECK:  encoding: [0x66,0x8f,0x05,0xed,0x7e,0x00,0x00]
        	popw	0x7eed

// CHECK: popl	3133065982
// CHECK:  encoding: [0x8f,0x05,0xfe,0xca,0xbe,0xba]
        	popl	0xbabecafe

// CHECK: popl	305419896
// CHECK:  encoding: [0x8f,0x05,0x78,0x56,0x34,0x12]
        	popl	0x12345678

// CHECK: clc
// CHECK:  encoding: [0xf8]
        	clc

// CHECK: cld
// CHECK:  encoding: [0xfc]
        	cld

// CHECK: cli
// CHECK:  encoding: [0xfa]
        	cli

// CHECK: clts
// CHECK:  encoding: [0x0f,0x06]
        	clts

// CHECK: cmc
// CHECK:  encoding: [0xf5]
        	cmc

// CHECK: lahf
// CHECK:  encoding: [0x9f]
        	lahf

// CHECK: sahf
// CHECK:  encoding: [0x9e]
        	sahf

// CHECK: stc
// CHECK:  encoding: [0xf9]
        	stc

// CHECK: std
// CHECK:  encoding: [0xfd]
        	std

// CHECK: sti
// CHECK:  encoding: [0xfb]
        	sti

// CHECK: addb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x84,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	addb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: addb	$254, 69
// CHECK:  encoding: [0x80,0x05,0x45,0x00,0x00,0x00,0xfe]
        	addb	$0xfe,0x45

// CHECK: addb	$254, 32493
// CHECK:  encoding: [0x80,0x05,0xed,0x7e,0x00,0x00,0xfe]
        	addb	$0xfe,0x7eed

// CHECK: addb	$254, 3133065982
// CHECK:  encoding: [0x80,0x05,0xfe,0xca,0xbe,0xba,0xfe]
        	addb	$0xfe,0xbabecafe

// CHECK: addb	$254, 305419896
// CHECK:  encoding: [0x80,0x05,0x78,0x56,0x34,0x12,0xfe]
        	addb	$0xfe,0x12345678

// CHECK: addb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x84,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	addb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: addb	$127, 69
// CHECK:  encoding: [0x80,0x05,0x45,0x00,0x00,0x00,0x7f]
        	addb	$0x7f,0x45

// CHECK: addb	$127, 32493
// CHECK:  encoding: [0x80,0x05,0xed,0x7e,0x00,0x00,0x7f]
        	addb	$0x7f,0x7eed

// CHECK: addb	$127, 3133065982
// CHECK:  encoding: [0x80,0x05,0xfe,0xca,0xbe,0xba,0x7f]
        	addb	$0x7f,0xbabecafe

// CHECK: addb	$127, 305419896
// CHECK:  encoding: [0x80,0x05,0x78,0x56,0x34,0x12,0x7f]
        	addb	$0x7f,0x12345678

// CHECK: addw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0x84,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	addw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: addw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x05,0x45,0x00,0x00,0x00,0xce,0x7a]
        	addw	$0x7ace,0x45

// CHECK: addw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x05,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	addw	$0x7ace,0x7eed

// CHECK: addw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x05,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	addw	$0x7ace,0xbabecafe

// CHECK: addw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x05,0x78,0x56,0x34,0x12,0xce,0x7a]
        	addw	$0x7ace,0x12345678

// CHECK: addl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x84,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	addl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: addl	$2063514302, 69
// CHECK:  encoding: [0x81,0x05,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	addl	$0x7afebabe,0x45

// CHECK: addl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x05,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	addl	$0x7afebabe,0x7eed

// CHECK: addl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x05,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	addl	$0x7afebabe,0xbabecafe

// CHECK: addl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x05,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	addl	$0x7afebabe,0x12345678

// CHECK: addl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x84,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	addl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: addl	$324478056, 69
// CHECK:  encoding: [0x81,0x05,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	addl	$0x13572468,0x45

// CHECK: addl	$324478056, 32493
// CHECK:  encoding: [0x81,0x05,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	addl	$0x13572468,0x7eed

// CHECK: addl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x05,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	addl	$0x13572468,0xbabecafe

// CHECK: addl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x05,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	addl	$0x13572468,0x12345678

// CHECK: incl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	incl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: incw	32493
// CHECK:  encoding: [0x66,0xff,0x05,0xed,0x7e,0x00,0x00]
        	incw	0x7eed

// CHECK: incl	3133065982
// CHECK:  encoding: [0xff,0x05,0xfe,0xca,0xbe,0xba]
        	incl	0xbabecafe

// CHECK: incl	305419896
// CHECK:  encoding: [0xff,0x05,0x78,0x56,0x34,0x12]
        	incl	0x12345678

// CHECK: subb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xac,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	subb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: subb	$254, 69
// CHECK:  encoding: [0x80,0x2d,0x45,0x00,0x00,0x00,0xfe]
        	subb	$0xfe,0x45

// CHECK: subb	$254, 32493
// CHECK:  encoding: [0x80,0x2d,0xed,0x7e,0x00,0x00,0xfe]
        	subb	$0xfe,0x7eed

// CHECK: subb	$254, 3133065982
// CHECK:  encoding: [0x80,0x2d,0xfe,0xca,0xbe,0xba,0xfe]
        	subb	$0xfe,0xbabecafe

// CHECK: subb	$254, 305419896
// CHECK:  encoding: [0x80,0x2d,0x78,0x56,0x34,0x12,0xfe]
        	subb	$0xfe,0x12345678

// CHECK: subb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xac,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	subb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: subb	$127, 69
// CHECK:  encoding: [0x80,0x2d,0x45,0x00,0x00,0x00,0x7f]
        	subb	$0x7f,0x45

// CHECK: subb	$127, 32493
// CHECK:  encoding: [0x80,0x2d,0xed,0x7e,0x00,0x00,0x7f]
        	subb	$0x7f,0x7eed

// CHECK: subb	$127, 3133065982
// CHECK:  encoding: [0x80,0x2d,0xfe,0xca,0xbe,0xba,0x7f]
        	subb	$0x7f,0xbabecafe

// CHECK: subb	$127, 305419896
// CHECK:  encoding: [0x80,0x2d,0x78,0x56,0x34,0x12,0x7f]
        	subb	$0x7f,0x12345678

// CHECK: subw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0xac,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	subw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: subw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x2d,0x45,0x00,0x00,0x00,0xce,0x7a]
        	subw	$0x7ace,0x45

// CHECK: subw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x2d,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	subw	$0x7ace,0x7eed

// CHECK: subw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x2d,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	subw	$0x7ace,0xbabecafe

// CHECK: subw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x2d,0x78,0x56,0x34,0x12,0xce,0x7a]
        	subw	$0x7ace,0x12345678

// CHECK: subl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xac,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	subl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: subl	$2063514302, 69
// CHECK:  encoding: [0x81,0x2d,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	subl	$0x7afebabe,0x45

// CHECK: subl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x2d,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	subl	$0x7afebabe,0x7eed

// CHECK: subl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x2d,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	subl	$0x7afebabe,0xbabecafe

// CHECK: subl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x2d,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	subl	$0x7afebabe,0x12345678

// CHECK: subl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xac,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	subl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: subl	$324478056, 69
// CHECK:  encoding: [0x81,0x2d,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	subl	$0x13572468,0x45

// CHECK: subl	$324478056, 32493
// CHECK:  encoding: [0x81,0x2d,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	subl	$0x13572468,0x7eed

// CHECK: subl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x2d,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	subl	$0x13572468,0xbabecafe

// CHECK: subl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x2d,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	subl	$0x13572468,0x12345678

// CHECK: decl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	decl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: decw	32493
// CHECK:  encoding: [0x66,0xff,0x0d,0xed,0x7e,0x00,0x00]
        	decw	0x7eed

// CHECK: decl	3133065982
// CHECK:  encoding: [0xff,0x0d,0xfe,0xca,0xbe,0xba]
        	decl	0xbabecafe

// CHECK: decl	305419896
// CHECK:  encoding: [0xff,0x0d,0x78,0x56,0x34,0x12]
        	decl	0x12345678

// CHECK: sbbb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x9c,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	sbbb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sbbb	$254, 69
// CHECK:  encoding: [0x80,0x1d,0x45,0x00,0x00,0x00,0xfe]
        	sbbb	$0xfe,0x45

// CHECK: sbbb	$254, 32493
// CHECK:  encoding: [0x80,0x1d,0xed,0x7e,0x00,0x00,0xfe]
        	sbbb	$0xfe,0x7eed

// CHECK: sbbb	$254, 3133065982
// CHECK:  encoding: [0x80,0x1d,0xfe,0xca,0xbe,0xba,0xfe]
        	sbbb	$0xfe,0xbabecafe

// CHECK: sbbb	$254, 305419896
// CHECK:  encoding: [0x80,0x1d,0x78,0x56,0x34,0x12,0xfe]
        	sbbb	$0xfe,0x12345678

// CHECK: sbbb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x9c,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	sbbb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sbbb	$127, 69
// CHECK:  encoding: [0x80,0x1d,0x45,0x00,0x00,0x00,0x7f]
        	sbbb	$0x7f,0x45

// CHECK: sbbb	$127, 32493
// CHECK:  encoding: [0x80,0x1d,0xed,0x7e,0x00,0x00,0x7f]
        	sbbb	$0x7f,0x7eed

// CHECK: sbbb	$127, 3133065982
// CHECK:  encoding: [0x80,0x1d,0xfe,0xca,0xbe,0xba,0x7f]
        	sbbb	$0x7f,0xbabecafe

// CHECK: sbbb	$127, 305419896
// CHECK:  encoding: [0x80,0x1d,0x78,0x56,0x34,0x12,0x7f]
        	sbbb	$0x7f,0x12345678

// CHECK: sbbw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0x9c,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	sbbw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sbbw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x1d,0x45,0x00,0x00,0x00,0xce,0x7a]
        	sbbw	$0x7ace,0x45

// CHECK: sbbw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x1d,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	sbbw	$0x7ace,0x7eed

// CHECK: sbbw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x1d,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	sbbw	$0x7ace,0xbabecafe

// CHECK: sbbw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x1d,0x78,0x56,0x34,0x12,0xce,0x7a]
        	sbbw	$0x7ace,0x12345678

// CHECK: sbbl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x9c,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	sbbl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sbbl	$2063514302, 69
// CHECK:  encoding: [0x81,0x1d,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	sbbl	$0x7afebabe,0x45

// CHECK: sbbl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x1d,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	sbbl	$0x7afebabe,0x7eed

// CHECK: sbbl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x1d,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	sbbl	$0x7afebabe,0xbabecafe

// CHECK: sbbl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x1d,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	sbbl	$0x7afebabe,0x12345678

// CHECK: sbbl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x9c,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	sbbl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sbbl	$324478056, 69
// CHECK:  encoding: [0x81,0x1d,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	sbbl	$0x13572468,0x45

// CHECK: sbbl	$324478056, 32493
// CHECK:  encoding: [0x81,0x1d,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	sbbl	$0x13572468,0x7eed

// CHECK: sbbl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x1d,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	sbbl	$0x13572468,0xbabecafe

// CHECK: sbbl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x1d,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	sbbl	$0x13572468,0x12345678

// CHECK: cmpb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xbc,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	cmpb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpb	$254, 69
// CHECK:  encoding: [0x80,0x3d,0x45,0x00,0x00,0x00,0xfe]
        	cmpb	$0xfe,0x45

// CHECK: cmpb	$254, 32493
// CHECK:  encoding: [0x80,0x3d,0xed,0x7e,0x00,0x00,0xfe]
        	cmpb	$0xfe,0x7eed

// CHECK: cmpb	$254, 3133065982
// CHECK:  encoding: [0x80,0x3d,0xfe,0xca,0xbe,0xba,0xfe]
        	cmpb	$0xfe,0xbabecafe

// CHECK: cmpb	$254, 305419896
// CHECK:  encoding: [0x80,0x3d,0x78,0x56,0x34,0x12,0xfe]
        	cmpb	$0xfe,0x12345678

// CHECK: cmpb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xbc,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	cmpb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpb	$127, 69
// CHECK:  encoding: [0x80,0x3d,0x45,0x00,0x00,0x00,0x7f]
        	cmpb	$0x7f,0x45

// CHECK: cmpb	$127, 32493
// CHECK:  encoding: [0x80,0x3d,0xed,0x7e,0x00,0x00,0x7f]
        	cmpb	$0x7f,0x7eed

// CHECK: cmpb	$127, 3133065982
// CHECK:  encoding: [0x80,0x3d,0xfe,0xca,0xbe,0xba,0x7f]
        	cmpb	$0x7f,0xbabecafe

// CHECK: cmpb	$127, 305419896
// CHECK:  encoding: [0x80,0x3d,0x78,0x56,0x34,0x12,0x7f]
        	cmpb	$0x7f,0x12345678

// CHECK: cmpw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0xbc,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	cmpw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x3d,0x45,0x00,0x00,0x00,0xce,0x7a]
        	cmpw	$0x7ace,0x45

// CHECK: cmpw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x3d,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	cmpw	$0x7ace,0x7eed

// CHECK: cmpw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x3d,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	cmpw	$0x7ace,0xbabecafe

// CHECK: cmpw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x3d,0x78,0x56,0x34,0x12,0xce,0x7a]
        	cmpw	$0x7ace,0x12345678

// CHECK: cmpl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xbc,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	cmpl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpl	$2063514302, 69
// CHECK:  encoding: [0x81,0x3d,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	cmpl	$0x7afebabe,0x45

// CHECK: cmpl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x3d,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	cmpl	$0x7afebabe,0x7eed

// CHECK: cmpl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x3d,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	cmpl	$0x7afebabe,0xbabecafe

// CHECK: cmpl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x3d,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	cmpl	$0x7afebabe,0x12345678

// CHECK: cmpl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xbc,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	cmpl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpl	$324478056, 69
// CHECK:  encoding: [0x81,0x3d,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	cmpl	$0x13572468,0x45

// CHECK: cmpl	$324478056, 32493
// CHECK:  encoding: [0x81,0x3d,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	cmpl	$0x13572468,0x7eed

// CHECK: cmpl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x3d,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	cmpl	$0x13572468,0xbabecafe

// CHECK: cmpl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x3d,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	cmpl	$0x13572468,0x12345678

// CHECK: testb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf6,0x84,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	testb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: testb	$127, 69
// CHECK:  encoding: [0xf6,0x05,0x45,0x00,0x00,0x00,0x7f]
        	testb	$0x7f,0x45

// CHECK: testb	$127, 32493
// CHECK:  encoding: [0xf6,0x05,0xed,0x7e,0x00,0x00,0x7f]
        	testb	$0x7f,0x7eed

// CHECK: testb	$127, 3133065982
// CHECK:  encoding: [0xf6,0x05,0xfe,0xca,0xbe,0xba,0x7f]
        	testb	$0x7f,0xbabecafe

// CHECK: testb	$127, 305419896
// CHECK:  encoding: [0xf6,0x05,0x78,0x56,0x34,0x12,0x7f]
        	testb	$0x7f,0x12345678

// CHECK: testw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0xf7,0x84,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	testw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: testw	$31438, 69
// CHECK:  encoding: [0x66,0xf7,0x05,0x45,0x00,0x00,0x00,0xce,0x7a]
        	testw	$0x7ace,0x45

// CHECK: testw	$31438, 32493
// CHECK:  encoding: [0x66,0xf7,0x05,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	testw	$0x7ace,0x7eed

// CHECK: testw	$31438, 3133065982
// CHECK:  encoding: [0x66,0xf7,0x05,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	testw	$0x7ace,0xbabecafe

// CHECK: testw	$31438, 305419896
// CHECK:  encoding: [0x66,0xf7,0x05,0x78,0x56,0x34,0x12,0xce,0x7a]
        	testw	$0x7ace,0x12345678

// CHECK: testl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0x84,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	testl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: testl	$2063514302, 69
// CHECK:  encoding: [0xf7,0x05,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	testl	$0x7afebabe,0x45

// CHECK: testl	$2063514302, 32493
// CHECK:  encoding: [0xf7,0x05,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	testl	$0x7afebabe,0x7eed

// CHECK: testl	$2063514302, 3133065982
// CHECK:  encoding: [0xf7,0x05,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	testl	$0x7afebabe,0xbabecafe

// CHECK: testl	$2063514302, 305419896
// CHECK:  encoding: [0xf7,0x05,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	testl	$0x7afebabe,0x12345678

// CHECK: testl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0x84,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	testl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: testl	$324478056, 69
// CHECK:  encoding: [0xf7,0x05,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	testl	$0x13572468,0x45

// CHECK: testl	$324478056, 32493
// CHECK:  encoding: [0xf7,0x05,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	testl	$0x13572468,0x7eed

// CHECK: testl	$324478056, 3133065982
// CHECK:  encoding: [0xf7,0x05,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	testl	$0x13572468,0xbabecafe

// CHECK: testl	$324478056, 305419896
// CHECK:  encoding: [0xf7,0x05,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	testl	$0x13572468,0x12345678

// CHECK: andb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xa4,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	andb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: andb	$254, 69
// CHECK:  encoding: [0x80,0x25,0x45,0x00,0x00,0x00,0xfe]
        	andb	$0xfe,0x45

// CHECK: andb	$254, 32493
// CHECK:  encoding: [0x80,0x25,0xed,0x7e,0x00,0x00,0xfe]
        	andb	$0xfe,0x7eed

// CHECK: andb	$254, 3133065982
// CHECK:  encoding: [0x80,0x25,0xfe,0xca,0xbe,0xba,0xfe]
        	andb	$0xfe,0xbabecafe

// CHECK: andb	$254, 305419896
// CHECK:  encoding: [0x80,0x25,0x78,0x56,0x34,0x12,0xfe]
        	andb	$0xfe,0x12345678

// CHECK: andb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	andb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: andb	$127, 69
// CHECK:  encoding: [0x80,0x25,0x45,0x00,0x00,0x00,0x7f]
        	andb	$0x7f,0x45

// CHECK: andb	$127, 32493
// CHECK:  encoding: [0x80,0x25,0xed,0x7e,0x00,0x00,0x7f]
        	andb	$0x7f,0x7eed

// CHECK: andb	$127, 3133065982
// CHECK:  encoding: [0x80,0x25,0xfe,0xca,0xbe,0xba,0x7f]
        	andb	$0x7f,0xbabecafe

// CHECK: andb	$127, 305419896
// CHECK:  encoding: [0x80,0x25,0x78,0x56,0x34,0x12,0x7f]
        	andb	$0x7f,0x12345678

// CHECK: andw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0xa4,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	andw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: andw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x25,0x45,0x00,0x00,0x00,0xce,0x7a]
        	andw	$0x7ace,0x45

// CHECK: andw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x25,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	andw	$0x7ace,0x7eed

// CHECK: andw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x25,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	andw	$0x7ace,0xbabecafe

// CHECK: andw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x25,0x78,0x56,0x34,0x12,0xce,0x7a]
        	andw	$0x7ace,0x12345678

// CHECK: andl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xa4,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	andl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: andl	$2063514302, 69
// CHECK:  encoding: [0x81,0x25,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	andl	$0x7afebabe,0x45

// CHECK: andl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x25,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	andl	$0x7afebabe,0x7eed

// CHECK: andl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x25,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	andl	$0x7afebabe,0xbabecafe

// CHECK: andl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x25,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	andl	$0x7afebabe,0x12345678

// CHECK: andl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	andl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: andl	$324478056, 69
// CHECK:  encoding: [0x81,0x25,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	andl	$0x13572468,0x45

// CHECK: andl	$324478056, 32493
// CHECK:  encoding: [0x81,0x25,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	andl	$0x13572468,0x7eed

// CHECK: andl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x25,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	andl	$0x13572468,0xbabecafe

// CHECK: andl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x25,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	andl	$0x13572468,0x12345678

// CHECK: orb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x8c,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	orb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: orb	$254, 69
// CHECK:  encoding: [0x80,0x0d,0x45,0x00,0x00,0x00,0xfe]
        	orb	$0xfe,0x45

// CHECK: orb	$254, 32493
// CHECK:  encoding: [0x80,0x0d,0xed,0x7e,0x00,0x00,0xfe]
        	orb	$0xfe,0x7eed

// CHECK: orb	$254, 3133065982
// CHECK:  encoding: [0x80,0x0d,0xfe,0xca,0xbe,0xba,0xfe]
        	orb	$0xfe,0xbabecafe

// CHECK: orb	$254, 305419896
// CHECK:  encoding: [0x80,0x0d,0x78,0x56,0x34,0x12,0xfe]
        	orb	$0xfe,0x12345678

// CHECK: orb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x8c,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	orb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: orb	$127, 69
// CHECK:  encoding: [0x80,0x0d,0x45,0x00,0x00,0x00,0x7f]
        	orb	$0x7f,0x45

// CHECK: orb	$127, 32493
// CHECK:  encoding: [0x80,0x0d,0xed,0x7e,0x00,0x00,0x7f]
        	orb	$0x7f,0x7eed

// CHECK: orb	$127, 3133065982
// CHECK:  encoding: [0x80,0x0d,0xfe,0xca,0xbe,0xba,0x7f]
        	orb	$0x7f,0xbabecafe

// CHECK: orb	$127, 305419896
// CHECK:  encoding: [0x80,0x0d,0x78,0x56,0x34,0x12,0x7f]
        	orb	$0x7f,0x12345678

// CHECK: orw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0x8c,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	orw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: orw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x0d,0x45,0x00,0x00,0x00,0xce,0x7a]
        	orw	$0x7ace,0x45

// CHECK: orw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x0d,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	orw	$0x7ace,0x7eed

// CHECK: orw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x0d,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	orw	$0x7ace,0xbabecafe

// CHECK: orw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x0d,0x78,0x56,0x34,0x12,0xce,0x7a]
        	orw	$0x7ace,0x12345678

// CHECK: orl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x8c,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	orl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: orl	$2063514302, 69
// CHECK:  encoding: [0x81,0x0d,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	orl	$0x7afebabe,0x45

// CHECK: orl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x0d,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	orl	$0x7afebabe,0x7eed

// CHECK: orl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x0d,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	orl	$0x7afebabe,0xbabecafe

// CHECK: orl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x0d,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	orl	$0x7afebabe,0x12345678

// CHECK: orl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x8c,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	orl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: orl	$324478056, 69
// CHECK:  encoding: [0x81,0x0d,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	orl	$0x13572468,0x45

// CHECK: orl	$324478056, 32493
// CHECK:  encoding: [0x81,0x0d,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	orl	$0x13572468,0x7eed

// CHECK: orl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x0d,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	orl	$0x13572468,0xbabecafe

// CHECK: orl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x0d,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	orl	$0x13572468,0x12345678

// CHECK: xorb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xb4,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	xorb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: xorb	$254, 69
// CHECK:  encoding: [0x80,0x35,0x45,0x00,0x00,0x00,0xfe]
        	xorb	$0xfe,0x45

// CHECK: xorb	$254, 32493
// CHECK:  encoding: [0x80,0x35,0xed,0x7e,0x00,0x00,0xfe]
        	xorb	$0xfe,0x7eed

// CHECK: xorb	$254, 3133065982
// CHECK:  encoding: [0x80,0x35,0xfe,0xca,0xbe,0xba,0xfe]
        	xorb	$0xfe,0xbabecafe

// CHECK: xorb	$254, 305419896
// CHECK:  encoding: [0x80,0x35,0x78,0x56,0x34,0x12,0xfe]
        	xorb	$0xfe,0x12345678

// CHECK: xorb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0xb4,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	xorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: xorb	$127, 69
// CHECK:  encoding: [0x80,0x35,0x45,0x00,0x00,0x00,0x7f]
        	xorb	$0x7f,0x45

// CHECK: xorb	$127, 32493
// CHECK:  encoding: [0x80,0x35,0xed,0x7e,0x00,0x00,0x7f]
        	xorb	$0x7f,0x7eed

// CHECK: xorb	$127, 3133065982
// CHECK:  encoding: [0x80,0x35,0xfe,0xca,0xbe,0xba,0x7f]
        	xorb	$0x7f,0xbabecafe

// CHECK: xorb	$127, 305419896
// CHECK:  encoding: [0x80,0x35,0x78,0x56,0x34,0x12,0x7f]
        	xorb	$0x7f,0x12345678

// CHECK: xorw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0xb4,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	xorw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: xorw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x35,0x45,0x00,0x00,0x00,0xce,0x7a]
        	xorw	$0x7ace,0x45

// CHECK: xorw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x35,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	xorw	$0x7ace,0x7eed

// CHECK: xorw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x35,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	xorw	$0x7ace,0xbabecafe

// CHECK: xorw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x35,0x78,0x56,0x34,0x12,0xce,0x7a]
        	xorw	$0x7ace,0x12345678

// CHECK: xorl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xb4,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	xorl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: xorl	$2063514302, 69
// CHECK:  encoding: [0x81,0x35,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	xorl	$0x7afebabe,0x45

// CHECK: xorl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x35,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	xorl	$0x7afebabe,0x7eed

// CHECK: xorl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x35,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	xorl	$0x7afebabe,0xbabecafe

// CHECK: xorl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x35,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	xorl	$0x7afebabe,0x12345678

// CHECK: xorl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0xb4,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	xorl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: xorl	$324478056, 69
// CHECK:  encoding: [0x81,0x35,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	xorl	$0x13572468,0x45

// CHECK: xorl	$324478056, 32493
// CHECK:  encoding: [0x81,0x35,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	xorl	$0x13572468,0x7eed

// CHECK: xorl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x35,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	xorl	$0x13572468,0xbabecafe

// CHECK: xorl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x35,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	xorl	$0x13572468,0x12345678

// CHECK: adcb	$254, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x94,0xcb,0xef,0xbe,0xad,0xde,0xfe]
        	adcb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: adcb	$254, 69
// CHECK:  encoding: [0x80,0x15,0x45,0x00,0x00,0x00,0xfe]
        	adcb	$0xfe,0x45

// CHECK: adcb	$254, 32493
// CHECK:  encoding: [0x80,0x15,0xed,0x7e,0x00,0x00,0xfe]
        	adcb	$0xfe,0x7eed

// CHECK: adcb	$254, 3133065982
// CHECK:  encoding: [0x80,0x15,0xfe,0xca,0xbe,0xba,0xfe]
        	adcb	$0xfe,0xbabecafe

// CHECK: adcb	$254, 305419896
// CHECK:  encoding: [0x80,0x15,0x78,0x56,0x34,0x12,0xfe]
        	adcb	$0xfe,0x12345678

// CHECK: adcb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x80,0x94,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	adcb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: adcb	$127, 69
// CHECK:  encoding: [0x80,0x15,0x45,0x00,0x00,0x00,0x7f]
        	adcb	$0x7f,0x45

// CHECK: adcb	$127, 32493
// CHECK:  encoding: [0x80,0x15,0xed,0x7e,0x00,0x00,0x7f]
        	adcb	$0x7f,0x7eed

// CHECK: adcb	$127, 3133065982
// CHECK:  encoding: [0x80,0x15,0xfe,0xca,0xbe,0xba,0x7f]
        	adcb	$0x7f,0xbabecafe

// CHECK: adcb	$127, 305419896
// CHECK:  encoding: [0x80,0x15,0x78,0x56,0x34,0x12,0x7f]
        	adcb	$0x7f,0x12345678

// CHECK: adcw	$31438, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x81,0x94,0xcb,0xef,0xbe,0xad,0xde,0xce,0x7a]
        	adcw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: adcw	$31438, 69
// CHECK:  encoding: [0x66,0x81,0x15,0x45,0x00,0x00,0x00,0xce,0x7a]
        	adcw	$0x7ace,0x45

// CHECK: adcw	$31438, 32493
// CHECK:  encoding: [0x66,0x81,0x15,0xed,0x7e,0x00,0x00,0xce,0x7a]
        	adcw	$0x7ace,0x7eed

// CHECK: adcw	$31438, 3133065982
// CHECK:  encoding: [0x66,0x81,0x15,0xfe,0xca,0xbe,0xba,0xce,0x7a]
        	adcw	$0x7ace,0xbabecafe

// CHECK: adcw	$31438, 305419896
// CHECK:  encoding: [0x66,0x81,0x15,0x78,0x56,0x34,0x12,0xce,0x7a]
        	adcw	$0x7ace,0x12345678

// CHECK: adcl	$2063514302, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x94,0xcb,0xef,0xbe,0xad,0xde,0xbe,0xba,0xfe,0x7a]
        	adcl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: adcl	$2063514302, 69
// CHECK:  encoding: [0x81,0x15,0x45,0x00,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	adcl	$0x7afebabe,0x45

// CHECK: adcl	$2063514302, 32493
// CHECK:  encoding: [0x81,0x15,0xed,0x7e,0x00,0x00,0xbe,0xba,0xfe,0x7a]
        	adcl	$0x7afebabe,0x7eed

// CHECK: adcl	$2063514302, 3133065982
// CHECK:  encoding: [0x81,0x15,0xfe,0xca,0xbe,0xba,0xbe,0xba,0xfe,0x7a]
        	adcl	$0x7afebabe,0xbabecafe

// CHECK: adcl	$2063514302, 305419896
// CHECK:  encoding: [0x81,0x15,0x78,0x56,0x34,0x12,0xbe,0xba,0xfe,0x7a]
        	adcl	$0x7afebabe,0x12345678

// CHECK: adcl	$324478056, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x81,0x94,0xcb,0xef,0xbe,0xad,0xde,0x68,0x24,0x57,0x13]
        	adcl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: adcl	$324478056, 69
// CHECK:  encoding: [0x81,0x15,0x45,0x00,0x00,0x00,0x68,0x24,0x57,0x13]
        	adcl	$0x13572468,0x45

// CHECK: adcl	$324478056, 32493
// CHECK:  encoding: [0x81,0x15,0xed,0x7e,0x00,0x00,0x68,0x24,0x57,0x13]
        	adcl	$0x13572468,0x7eed

// CHECK: adcl	$324478056, 3133065982
// CHECK:  encoding: [0x81,0x15,0xfe,0xca,0xbe,0xba,0x68,0x24,0x57,0x13]
        	adcl	$0x13572468,0xbabecafe

// CHECK: adcl	$324478056, 305419896
// CHECK:  encoding: [0x81,0x15,0x78,0x56,0x34,0x12,0x68,0x24,0x57,0x13]
        	adcl	$0x13572468,0x12345678

// CHECK: negl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	negl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: negw	32493
// CHECK:  encoding: [0x66,0xf7,0x1d,0xed,0x7e,0x00,0x00]
        	negw	0x7eed

// CHECK: negl	3133065982
// CHECK:  encoding: [0xf7,0x1d,0xfe,0xca,0xbe,0xba]
        	negl	0xbabecafe

// CHECK: negl	305419896
// CHECK:  encoding: [0xf7,0x1d,0x78,0x56,0x34,0x12]
        	negl	0x12345678

// CHECK: notl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	notl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: notw	32493
// CHECK:  encoding: [0x66,0xf7,0x15,0xed,0x7e,0x00,0x00]
        	notw	0x7eed

// CHECK: notl	3133065982
// CHECK:  encoding: [0xf7,0x15,0xfe,0xca,0xbe,0xba]
        	notl	0xbabecafe

// CHECK: notl	305419896
// CHECK:  encoding: [0xf7,0x15,0x78,0x56,0x34,0x12]
        	notl	0x12345678

// CHECK: cbtw
// CHECK:  encoding: [0x66,0x98]
        	cbtw

// CHECK: cwtl
// CHECK:  encoding: [0x98]
        	cwtl

// CHECK: cwtd
// CHECK:  encoding: [0x66,0x99]
        	cwtd

// CHECK: cltd
// CHECK:  encoding: [0x99]
        	cltd

// CHECK: mull	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	mull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: mulw	32493
// CHECK:  encoding: [0x66,0xf7,0x25,0xed,0x7e,0x00,0x00]
        	mulw	0x7eed

// CHECK: mull	3133065982
// CHECK:  encoding: [0xf7,0x25,0xfe,0xca,0xbe,0xba]
        	mull	0xbabecafe

// CHECK: mull	305419896
// CHECK:  encoding: [0xf7,0x25,0x78,0x56,0x34,0x12]
        	mull	0x12345678

// CHECK: imull	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	imull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: imulw	32493
// CHECK:  encoding: [0x66,0xf7,0x2d,0xed,0x7e,0x00,0x00]
        	imulw	0x7eed

// CHECK: imull	3133065982
// CHECK:  encoding: [0xf7,0x2d,0xfe,0xca,0xbe,0xba]
        	imull	0xbabecafe

// CHECK: imull	305419896
// CHECK:  encoding: [0xf7,0x2d,0x78,0x56,0x34,0x12]
        	imull	0x12345678

// CHECK: divl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	divl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: divw	32493
// CHECK:  encoding: [0x66,0xf7,0x35,0xed,0x7e,0x00,0x00]
        	divw	0x7eed

// CHECK: divl	3133065982
// CHECK:  encoding: [0xf7,0x35,0xfe,0xca,0xbe,0xba]
        	divl	0xbabecafe

// CHECK: divl	305419896
// CHECK:  encoding: [0xf7,0x35,0x78,0x56,0x34,0x12]
        	divl	0x12345678

// CHECK: idivl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf7,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	idivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: idivw	32493
// CHECK:  encoding: [0x66,0xf7,0x3d,0xed,0x7e,0x00,0x00]
        	idivw	0x7eed

// CHECK: idivl	3133065982
// CHECK:  encoding: [0xf7,0x3d,0xfe,0xca,0xbe,0xba]
        	idivl	0xbabecafe

// CHECK: idivl	305419896
// CHECK:  encoding: [0xf7,0x3d,0x78,0x56,0x34,0x12]
        	idivl	0x12345678

// CHECK: roll	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0x84,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	roll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: roll	$0, 69
// CHECK:  encoding: [0xc1,0x05,0x45,0x00,0x00,0x00,0x00]
        	roll	$0,0x45

// CHECK: roll	$0, 32493
// CHECK:  encoding: [0xc1,0x05,0xed,0x7e,0x00,0x00,0x00]
        	roll	$0,0x7eed

// CHECK: roll	$0, 3133065982
// CHECK:  encoding: [0xc1,0x05,0xfe,0xca,0xbe,0xba,0x00]
        	roll	$0,0xbabecafe

// CHECK: roll	$0, 305419896
// CHECK:  encoding: [0xc1,0x05,0x78,0x56,0x34,0x12,0x00]
        	roll	$0,0x12345678

// CHECK: rolb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0x84,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	rolb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: rolb	$127, 69
// CHECK:  encoding: [0xc0,0x05,0x45,0x00,0x00,0x00,0x7f]
        	rolb	$0x7f,0x45

// CHECK: rolb	$127, 32493
// CHECK:  encoding: [0xc0,0x05,0xed,0x7e,0x00,0x00,0x7f]
        	rolb	$0x7f,0x7eed

// CHECK: rolb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x05,0xfe,0xca,0xbe,0xba,0x7f]
        	rolb	$0x7f,0xbabecafe

// CHECK: rolb	$127, 305419896
// CHECK:  encoding: [0xc0,0x05,0x78,0x56,0x34,0x12,0x7f]
        	rolb	$0x7f,0x12345678

// CHECK: roll	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	roll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: rolw	32493
// CHECK:  encoding: [0x66,0xd1,0x05,0xed,0x7e,0x00,0x00]
        	rolw	0x7eed

// CHECK: roll	3133065982
// CHECK:  encoding: [0xd1,0x05,0xfe,0xca,0xbe,0xba]
        	roll	0xbabecafe

// CHECK: roll	305419896
// CHECK:  encoding: [0xd1,0x05,0x78,0x56,0x34,0x12]
        	roll	0x12345678

// CHECK: rorl	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0x8c,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	rorl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: rorl	$0, 69
// CHECK:  encoding: [0xc1,0x0d,0x45,0x00,0x00,0x00,0x00]
        	rorl	$0,0x45

// CHECK: rorl	$0, 32493
// CHECK:  encoding: [0xc1,0x0d,0xed,0x7e,0x00,0x00,0x00]
        	rorl	$0,0x7eed

// CHECK: rorl	$0, 3133065982
// CHECK:  encoding: [0xc1,0x0d,0xfe,0xca,0xbe,0xba,0x00]
        	rorl	$0,0xbabecafe

// CHECK: rorl	$0, 305419896
// CHECK:  encoding: [0xc1,0x0d,0x78,0x56,0x34,0x12,0x00]
        	rorl	$0,0x12345678

// CHECK: rorb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0x8c,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	rorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: rorb	$127, 69
// CHECK:  encoding: [0xc0,0x0d,0x45,0x00,0x00,0x00,0x7f]
        	rorb	$0x7f,0x45

// CHECK: rorb	$127, 32493
// CHECK:  encoding: [0xc0,0x0d,0xed,0x7e,0x00,0x00,0x7f]
        	rorb	$0x7f,0x7eed

// CHECK: rorb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x0d,0xfe,0xca,0xbe,0xba,0x7f]
        	rorb	$0x7f,0xbabecafe

// CHECK: rorb	$127, 305419896
// CHECK:  encoding: [0xc0,0x0d,0x78,0x56,0x34,0x12,0x7f]
        	rorb	$0x7f,0x12345678

// CHECK: rorl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	rorl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: rorw	32493
// CHECK:  encoding: [0x66,0xd1,0x0d,0xed,0x7e,0x00,0x00]
        	rorw	0x7eed

// CHECK: rorl	3133065982
// CHECK:  encoding: [0xd1,0x0d,0xfe,0xca,0xbe,0xba]
        	rorl	0xbabecafe

// CHECK: rorl	305419896
// CHECK:  encoding: [0xd1,0x0d,0x78,0x56,0x34,0x12]
        	rorl	0x12345678

// CHECK: shll	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	sall	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shll	$0, 69
// CHECK:  encoding: [0xc1,0x25,0x45,0x00,0x00,0x00,0x00]
        	sall	$0,0x45

// CHECK: shll	$0, 32493
// CHECK:  encoding: [0xc1,0x25,0xed,0x7e,0x00,0x00,0x00]
        	sall	$0,0x7eed

// CHECK: shll	$0, 3133065982
// CHECK:  encoding: [0xc1,0x25,0xfe,0xca,0xbe,0xba,0x00]
        	sall	$0,0xbabecafe

// CHECK: shll	$0, 305419896
// CHECK:  encoding: [0xc1,0x25,0x78,0x56,0x34,0x12,0x00]
        	sall	$0,0x12345678

// CHECK: shlb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	salb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shlb	$127, 69
// CHECK:  encoding: [0xc0,0x25,0x45,0x00,0x00,0x00,0x7f]
        	salb	$0x7f,0x45

// CHECK: shlb	$127, 32493
// CHECK:  encoding: [0xc0,0x25,0xed,0x7e,0x00,0x00,0x7f]
        	salb	$0x7f,0x7eed

// CHECK: shlb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x25,0xfe,0xca,0xbe,0xba,0x7f]
        	salb	$0x7f,0xbabecafe

// CHECK: shlb	$127, 305419896
// CHECK:  encoding: [0xc0,0x25,0x78,0x56,0x34,0x12,0x7f]
        	salb	$0x7f,0x12345678

// CHECK: shll	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	sall	0xdeadbeef(%ebx,%ecx,8)

// CHECK: shlw	32493
// CHECK:  encoding: [0x66,0xd1,0x25,0xed,0x7e,0x00,0x00]
        	salw	0x7eed

// CHECK: shll	3133065982
// CHECK:  encoding: [0xd1,0x25,0xfe,0xca,0xbe,0xba]
        	sall	0xbabecafe

// CHECK: shll	305419896
// CHECK:  encoding: [0xd1,0x25,0x78,0x56,0x34,0x12]
        	sall	0x12345678

// CHECK: shll	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	shll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shll	$0, 69
// CHECK:  encoding: [0xc1,0x25,0x45,0x00,0x00,0x00,0x00]
        	shll	$0,0x45

// CHECK: shll	$0, 32493
// CHECK:  encoding: [0xc1,0x25,0xed,0x7e,0x00,0x00,0x00]
        	shll	$0,0x7eed

// CHECK: shll	$0, 3133065982
// CHECK:  encoding: [0xc1,0x25,0xfe,0xca,0xbe,0xba,0x00]
        	shll	$0,0xbabecafe

// CHECK: shll	$0, 305419896
// CHECK:  encoding: [0xc1,0x25,0x78,0x56,0x34,0x12,0x00]
        	shll	$0,0x12345678

// CHECK: shlb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0xa4,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	shlb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shlb	$127, 69
// CHECK:  encoding: [0xc0,0x25,0x45,0x00,0x00,0x00,0x7f]
        	shlb	$0x7f,0x45

// CHECK: shlb	$127, 32493
// CHECK:  encoding: [0xc0,0x25,0xed,0x7e,0x00,0x00,0x7f]
        	shlb	$0x7f,0x7eed

// CHECK: shlb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x25,0xfe,0xca,0xbe,0xba,0x7f]
        	shlb	$0x7f,0xbabecafe

// CHECK: shlb	$127, 305419896
// CHECK:  encoding: [0xc0,0x25,0x78,0x56,0x34,0x12,0x7f]
        	shlb	$0x7f,0x12345678

// CHECK: shll	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	shll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: shlw	32493
// CHECK:  encoding: [0x66,0xd1,0x25,0xed,0x7e,0x00,0x00]
        	shlw	0x7eed

// CHECK: shll	3133065982
// CHECK:  encoding: [0xd1,0x25,0xfe,0xca,0xbe,0xba]
        	shll	0xbabecafe

// CHECK: shll	305419896
// CHECK:  encoding: [0xd1,0x25,0x78,0x56,0x34,0x12]
        	shll	0x12345678

// CHECK: shrl	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0xac,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	shrl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shrl	$0, 69
// CHECK:  encoding: [0xc1,0x2d,0x45,0x00,0x00,0x00,0x00]
        	shrl	$0,0x45

// CHECK: shrl	$0, 32493
// CHECK:  encoding: [0xc1,0x2d,0xed,0x7e,0x00,0x00,0x00]
        	shrl	$0,0x7eed

// CHECK: shrl	$0, 3133065982
// CHECK:  encoding: [0xc1,0x2d,0xfe,0xca,0xbe,0xba,0x00]
        	shrl	$0,0xbabecafe

// CHECK: shrl	$0, 305419896
// CHECK:  encoding: [0xc1,0x2d,0x78,0x56,0x34,0x12,0x00]
        	shrl	$0,0x12345678

// CHECK: shrb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0xac,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	shrb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: shrb	$127, 69
// CHECK:  encoding: [0xc0,0x2d,0x45,0x00,0x00,0x00,0x7f]
        	shrb	$0x7f,0x45

// CHECK: shrb	$127, 32493
// CHECK:  encoding: [0xc0,0x2d,0xed,0x7e,0x00,0x00,0x7f]
        	shrb	$0x7f,0x7eed

// CHECK: shrb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x2d,0xfe,0xca,0xbe,0xba,0x7f]
        	shrb	$0x7f,0xbabecafe

// CHECK: shrb	$127, 305419896
// CHECK:  encoding: [0xc0,0x2d,0x78,0x56,0x34,0x12,0x7f]
        	shrb	$0x7f,0x12345678

// CHECK: shrl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	shrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: shrw	32493
// CHECK:  encoding: [0x66,0xd1,0x2d,0xed,0x7e,0x00,0x00]
        	shrw	0x7eed

// CHECK: shrl	3133065982
// CHECK:  encoding: [0xd1,0x2d,0xfe,0xca,0xbe,0xba]
        	shrl	0xbabecafe

// CHECK: shrl	305419896
// CHECK:  encoding: [0xd1,0x2d,0x78,0x56,0x34,0x12]
        	shrl	0x12345678

// CHECK: sarl	$0, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc1,0xbc,0xcb,0xef,0xbe,0xad,0xde,0x00]
        	sarl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sarl	$0, 69
// CHECK:  encoding: [0xc1,0x3d,0x45,0x00,0x00,0x00,0x00]
        	sarl	$0,0x45

// CHECK: sarl	$0, 32493
// CHECK:  encoding: [0xc1,0x3d,0xed,0x7e,0x00,0x00,0x00]
        	sarl	$0,0x7eed

// CHECK: sarl	$0, 3133065982
// CHECK:  encoding: [0xc1,0x3d,0xfe,0xca,0xbe,0xba,0x00]
        	sarl	$0,0xbabecafe

// CHECK: sarl	$0, 305419896
// CHECK:  encoding: [0xc1,0x3d,0x78,0x56,0x34,0x12,0x00]
        	sarl	$0,0x12345678

// CHECK: sarb	$127, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xc0,0xbc,0xcb,0xef,0xbe,0xad,0xde,0x7f]
        	sarb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: sarb	$127, 69
// CHECK:  encoding: [0xc0,0x3d,0x45,0x00,0x00,0x00,0x7f]
        	sarb	$0x7f,0x45

// CHECK: sarb	$127, 32493
// CHECK:  encoding: [0xc0,0x3d,0xed,0x7e,0x00,0x00,0x7f]
        	sarb	$0x7f,0x7eed

// CHECK: sarb	$127, 3133065982
// CHECK:  encoding: [0xc0,0x3d,0xfe,0xca,0xbe,0xba,0x7f]
        	sarb	$0x7f,0xbabecafe

// CHECK: sarb	$127, 305419896
// CHECK:  encoding: [0xc0,0x3d,0x78,0x56,0x34,0x12,0x7f]
        	sarb	$0x7f,0x12345678

// CHECK: sarl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd1,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	sarl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: sarw	32493
// CHECK:  encoding: [0x66,0xd1,0x3d,0xed,0x7e,0x00,0x00]
        	sarw	0x7eed

// CHECK: sarl	3133065982
// CHECK:  encoding: [0xd1,0x3d,0xfe,0xca,0xbe,0xba]
        	sarl	0xbabecafe

// CHECK: sarl	305419896
// CHECK:  encoding: [0xd1,0x3d,0x78,0x56,0x34,0x12]
        	sarl	0x12345678

// CHECK: calll	*%ecx
// CHECK:  encoding: [0xff,0xd1]
        	call	*%ecx

// CHECK: calll	*3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	call	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: calll	*3135175374
// CHECK:  encoding: [0xff,0x15,0xce,0xfa,0xde,0xba]
        	call	*0xbadeface

// CHECK: calll	*3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	call	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: calll	*3135175374
// CHECK:  encoding: [0xff,0x15,0xce,0xfa,0xde,0xba]
        	call	*0xbadeface

// CHECK: lcallw	*32493
// CHECK:  encoding: [0x66,0xff,0x1d,0xed,0x7e,0x00,0x00]
        	lcallw	*0x7eed

// CHECK: jmpl	*3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: jmpl	*3135175374
// CHECK:  encoding: [0xff,0x25,0xce,0xfa,0xde,0xba]
        	jmp	*0xbadeface

// CHECK: jmpl	*3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: jmpl	*3135175374
// CHECK:  encoding: [0xff,0x25,0xce,0xfa,0xde,0xba]
        	jmp	*0xbadeface

// CHECK: ljmpl	*3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xff,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	ljmpl	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: ljmpw	*32493
// CHECK:  encoding: [0x66,0xff,0x2d,0xed,0x7e,0x00,0x00]
        	ljmpw	*0x7eed

// CHECK: ljmpl	*3133065982
// CHECK:  encoding: [0xff,0x2d,0xfe,0xca,0xbe,0xba]
        	ljmpl	*0xbabecafe

// CHECK: ljmpl	*305419896
// CHECK:  encoding: [0xff,0x2d,0x78,0x56,0x34,0x12]
        	ljmpl	*0x12345678

// CHECK: ret
// CHECK:  encoding: [0xc3]
        	ret

// CHECK: lret
// CHECK:  encoding: [0xcb]
        	lret

// CHECK: leave
// CHECK:  encoding: [0xc9]
        	leave

// CHECK: leave
// CHECK:  encoding: [0xc9]
        	leavel

// CHECK: seto	%bl
// CHECK:  encoding: [0x0f,0x90,0xc3]
        	seto	%bl

// CHECK: seto	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x90,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	seto	0xdeadbeef(%ebx,%ecx,8)

// CHECK: seto	32493
// CHECK:  encoding: [0x0f,0x90,0x05,0xed,0x7e,0x00,0x00]
        	seto	0x7eed

// CHECK: seto	3133065982
// CHECK:  encoding: [0x0f,0x90,0x05,0xfe,0xca,0xbe,0xba]
        	seto	0xbabecafe

// CHECK: seto	305419896
// CHECK:  encoding: [0x0f,0x90,0x05,0x78,0x56,0x34,0x12]
        	seto	0x12345678

// CHECK: setno	%bl
// CHECK:  encoding: [0x0f,0x91,0xc3]
        	setno	%bl

// CHECK: setno	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x91,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setno	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setno	32493
// CHECK:  encoding: [0x0f,0x91,0x05,0xed,0x7e,0x00,0x00]
        	setno	0x7eed

// CHECK: setno	3133065982
// CHECK:  encoding: [0x0f,0x91,0x05,0xfe,0xca,0xbe,0xba]
        	setno	0xbabecafe

// CHECK: setno	305419896
// CHECK:  encoding: [0x0f,0x91,0x05,0x78,0x56,0x34,0x12]
        	setno	0x12345678

// CHECK: setb	%bl
// CHECK:  encoding: [0x0f,0x92,0xc3]
        	setb	%bl

// CHECK: setb	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x92,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setb	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setb	32493
// CHECK:  encoding: [0x0f,0x92,0x05,0xed,0x7e,0x00,0x00]
        	setb	0x7eed

// CHECK: setb	3133065982
// CHECK:  encoding: [0x0f,0x92,0x05,0xfe,0xca,0xbe,0xba]
        	setb	0xbabecafe

// CHECK: setb	305419896
// CHECK:  encoding: [0x0f,0x92,0x05,0x78,0x56,0x34,0x12]
        	setb	0x12345678

// CHECK: setae	%bl
// CHECK:  encoding: [0x0f,0x93,0xc3]
        	setae	%bl

// CHECK: setae	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x93,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setae	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setae	32493
// CHECK:  encoding: [0x0f,0x93,0x05,0xed,0x7e,0x00,0x00]
        	setae	0x7eed

// CHECK: setae	3133065982
// CHECK:  encoding: [0x0f,0x93,0x05,0xfe,0xca,0xbe,0xba]
        	setae	0xbabecafe

// CHECK: setae	305419896
// CHECK:  encoding: [0x0f,0x93,0x05,0x78,0x56,0x34,0x12]
        	setae	0x12345678

// CHECK: sete	%bl
// CHECK:  encoding: [0x0f,0x94,0xc3]
        	sete	%bl

// CHECK: sete	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x94,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	sete	0xdeadbeef(%ebx,%ecx,8)

// CHECK: sete	32493
// CHECK:  encoding: [0x0f,0x94,0x05,0xed,0x7e,0x00,0x00]
        	sete	0x7eed

// CHECK: sete	3133065982
// CHECK:  encoding: [0x0f,0x94,0x05,0xfe,0xca,0xbe,0xba]
        	sete	0xbabecafe

// CHECK: sete	305419896
// CHECK:  encoding: [0x0f,0x94,0x05,0x78,0x56,0x34,0x12]
        	sete	0x12345678

// CHECK: setne	%bl
// CHECK:  encoding: [0x0f,0x95,0xc3]
        	setne	%bl

// CHECK: setne	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x95,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setne	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setne	32493
// CHECK:  encoding: [0x0f,0x95,0x05,0xed,0x7e,0x00,0x00]
        	setne	0x7eed

// CHECK: setne	3133065982
// CHECK:  encoding: [0x0f,0x95,0x05,0xfe,0xca,0xbe,0xba]
        	setne	0xbabecafe

// CHECK: setne	305419896
// CHECK:  encoding: [0x0f,0x95,0x05,0x78,0x56,0x34,0x12]
        	setne	0x12345678

// CHECK: setbe	%bl
// CHECK:  encoding: [0x0f,0x96,0xc3]
        	setbe	%bl

// CHECK: setbe	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x96,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setbe	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setbe	32493
// CHECK:  encoding: [0x0f,0x96,0x05,0xed,0x7e,0x00,0x00]
        	setbe	0x7eed

// CHECK: setbe	3133065982
// CHECK:  encoding: [0x0f,0x96,0x05,0xfe,0xca,0xbe,0xba]
        	setbe	0xbabecafe

// CHECK: setbe	305419896
// CHECK:  encoding: [0x0f,0x96,0x05,0x78,0x56,0x34,0x12]
        	setbe	0x12345678

// CHECK: seta	%bl
// CHECK:  encoding: [0x0f,0x97,0xc3]
        	seta	%bl

// CHECK: seta	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x97,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	seta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: seta	32493
// CHECK:  encoding: [0x0f,0x97,0x05,0xed,0x7e,0x00,0x00]
        	seta	0x7eed

// CHECK: seta	3133065982
// CHECK:  encoding: [0x0f,0x97,0x05,0xfe,0xca,0xbe,0xba]
        	seta	0xbabecafe

// CHECK: seta	305419896
// CHECK:  encoding: [0x0f,0x97,0x05,0x78,0x56,0x34,0x12]
        	seta	0x12345678

// CHECK: sets	%bl
// CHECK:  encoding: [0x0f,0x98,0xc3]
        	sets	%bl

// CHECK: sets	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x98,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	sets	0xdeadbeef(%ebx,%ecx,8)

// CHECK: sets	32493
// CHECK:  encoding: [0x0f,0x98,0x05,0xed,0x7e,0x00,0x00]
        	sets	0x7eed

// CHECK: sets	3133065982
// CHECK:  encoding: [0x0f,0x98,0x05,0xfe,0xca,0xbe,0xba]
        	sets	0xbabecafe

// CHECK: sets	305419896
// CHECK:  encoding: [0x0f,0x98,0x05,0x78,0x56,0x34,0x12]
        	sets	0x12345678

// CHECK: setns	%bl
// CHECK:  encoding: [0x0f,0x99,0xc3]
        	setns	%bl

// CHECK: setns	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x99,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setns	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setns	32493
// CHECK:  encoding: [0x0f,0x99,0x05,0xed,0x7e,0x00,0x00]
        	setns	0x7eed

// CHECK: setns	3133065982
// CHECK:  encoding: [0x0f,0x99,0x05,0xfe,0xca,0xbe,0xba]
        	setns	0xbabecafe

// CHECK: setns	305419896
// CHECK:  encoding: [0x0f,0x99,0x05,0x78,0x56,0x34,0x12]
        	setns	0x12345678

// CHECK: setp	%bl
// CHECK:  encoding: [0x0f,0x9a,0xc3]
        	setp	%bl

// CHECK: setp	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9a,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setp	32493
// CHECK:  encoding: [0x0f,0x9a,0x05,0xed,0x7e,0x00,0x00]
        	setp	0x7eed

// CHECK: setp	3133065982
// CHECK:  encoding: [0x0f,0x9a,0x05,0xfe,0xca,0xbe,0xba]
        	setp	0xbabecafe

// CHECK: setp	305419896
// CHECK:  encoding: [0x0f,0x9a,0x05,0x78,0x56,0x34,0x12]
        	setp	0x12345678

// CHECK: setnp	%bl
// CHECK:  encoding: [0x0f,0x9b,0xc3]
        	setnp	%bl

// CHECK: setnp	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9b,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setnp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setnp	32493
// CHECK:  encoding: [0x0f,0x9b,0x05,0xed,0x7e,0x00,0x00]
        	setnp	0x7eed

// CHECK: setnp	3133065982
// CHECK:  encoding: [0x0f,0x9b,0x05,0xfe,0xca,0xbe,0xba]
        	setnp	0xbabecafe

// CHECK: setnp	305419896
// CHECK:  encoding: [0x0f,0x9b,0x05,0x78,0x56,0x34,0x12]
        	setnp	0x12345678

// CHECK: setl	%bl
// CHECK:  encoding: [0x0f,0x9c,0xc3]
        	setl	%bl

// CHECK: setl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9c,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setl	32493
// CHECK:  encoding: [0x0f,0x9c,0x05,0xed,0x7e,0x00,0x00]
        	setl	0x7eed

// CHECK: setl	3133065982
// CHECK:  encoding: [0x0f,0x9c,0x05,0xfe,0xca,0xbe,0xba]
        	setl	0xbabecafe

// CHECK: setl	305419896
// CHECK:  encoding: [0x0f,0x9c,0x05,0x78,0x56,0x34,0x12]
        	setl	0x12345678

// CHECK: setge	%bl
// CHECK:  encoding: [0x0f,0x9d,0xc3]
        	setge	%bl

// CHECK: setge	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9d,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setge	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setge	32493
// CHECK:  encoding: [0x0f,0x9d,0x05,0xed,0x7e,0x00,0x00]
        	setge	0x7eed

// CHECK: setge	3133065982
// CHECK:  encoding: [0x0f,0x9d,0x05,0xfe,0xca,0xbe,0xba]
        	setge	0xbabecafe

// CHECK: setge	305419896
// CHECK:  encoding: [0x0f,0x9d,0x05,0x78,0x56,0x34,0x12]
        	setge	0x12345678

// CHECK: setle	%bl
// CHECK:  encoding: [0x0f,0x9e,0xc3]
        	setle	%bl

// CHECK: setle	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9e,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setle	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setle	32493
// CHECK:  encoding: [0x0f,0x9e,0x05,0xed,0x7e,0x00,0x00]
        	setle	0x7eed

// CHECK: setle	3133065982
// CHECK:  encoding: [0x0f,0x9e,0x05,0xfe,0xca,0xbe,0xba]
        	setle	0xbabecafe

// CHECK: setle	305419896
// CHECK:  encoding: [0x0f,0x9e,0x05,0x78,0x56,0x34,0x12]
        	setle	0x12345678

// CHECK: setg	%bl
// CHECK:  encoding: [0x0f,0x9f,0xc3]
        	setg	%bl

// CHECK: setg	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x9f,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	setg	0xdeadbeef(%ebx,%ecx,8)

// CHECK: setg	32493
// CHECK:  encoding: [0x0f,0x9f,0x05,0xed,0x7e,0x00,0x00]
        	setg	0x7eed

// CHECK: setg	3133065982
// CHECK:  encoding: [0x0f,0x9f,0x05,0xfe,0xca,0xbe,0xba]
        	setg	0xbabecafe

// CHECK: setg	305419896
// CHECK:  encoding: [0x0f,0x9f,0x05,0x78,0x56,0x34,0x12]
        	setg	0x12345678

// CHECK: rsm
// CHECK:  encoding: [0x0f,0xaa]
        	rsm

// CHECK: hlt
// CHECK:  encoding: [0xf4]
        	hlt

// CHECK: nopl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x1f,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	nopl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: nopw	32493
// CHECK:  encoding: [0x66,0x0f,0x1f,0x05,0xed,0x7e,0x00,0x00]
        	nopw	0x7eed

// CHECK: nopl	3133065982
// CHECK:  encoding: [0x0f,0x1f,0x05,0xfe,0xca,0xbe,0xba]
        	nopl	0xbabecafe

// CHECK: nopl	305419896
// CHECK:  encoding: [0x0f,0x1f,0x05,0x78,0x56,0x34,0x12]
        	nopl	0x12345678

// CHECK: nop
// CHECK:  encoding: [0x90]
        	nop

// CHECK: lldtw	32493
// CHECK:  encoding: [0x0f,0x00,0x15,0xed,0x7e,0x00,0x00]
        	lldtw	0x7eed

// CHECK: lmsww	32493
// CHECK:  encoding: [0x0f,0x01,0x35,0xed,0x7e,0x00,0x00]
        	lmsww	0x7eed

// CHECK: ltrw	32493
// CHECK:  encoding: [0x0f,0x00,0x1d,0xed,0x7e,0x00,0x00]
        	ltrw	0x7eed

// CHECK: sldtw	32493
// CHECK:  encoding: [0x0f,0x00,0x05,0xed,0x7e,0x00,0x00]
        	sldtw	0x7eed

// CHECK: smsww	32493
// CHECK:  encoding: [0x0f,0x01,0x25,0xed,0x7e,0x00,0x00]
        	smsww	0x7eed

// CHECK: strw	32493
// CHECK:  encoding: [0x0f,0x00,0x0d,0xed,0x7e,0x00,0x00]
        	strw	0x7eed

// CHECK: verr	%bx
// CHECK:  encoding: [0x0f,0x00,0xe3]
        	verr	%bx

// CHECK: verr	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x00,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	verr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: verr	3133065982
// CHECK:  encoding: [0x0f,0x00,0x25,0xfe,0xca,0xbe,0xba]
        	verr	0xbabecafe

// CHECK: verr	305419896
// CHECK:  encoding: [0x0f,0x00,0x25,0x78,0x56,0x34,0x12]
        	verr	0x12345678

// CHECK: verw	%bx
// CHECK:  encoding: [0x0f,0x00,0xeb]
        	verw	%bx

// CHECK: verw	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x00,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	verw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: verw	3133065982
// CHECK:  encoding: [0x0f,0x00,0x2d,0xfe,0xca,0xbe,0xba]
        	verw	0xbabecafe

// CHECK: verw	305419896
// CHECK:  encoding: [0x0f,0x00,0x2d,0x78,0x56,0x34,0x12]
        	verw	0x12345678

// CHECK: fld	%st(2)
// CHECK:  encoding: [0xd9,0xc2]
        	fld	%st(2)

// CHECK: fldl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdd,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	fldl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fldl	3133065982
// CHECK:  encoding: [0xdd,0x05,0xfe,0xca,0xbe,0xba]
        	fldl	0xbabecafe

// CHECK: fldl	305419896
// CHECK:  encoding: [0xdd,0x05,0x78,0x56,0x34,0x12]
        	fldl	0x12345678

// CHECK: fld	%st(2)
// CHECK:  encoding: [0xd9,0xc2]
        	fld	%st(2)

// CHECK: fildl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	fildl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fildl	3133065982
// CHECK:  encoding: [0xdb,0x05,0xfe,0xca,0xbe,0xba]
        	fildl	0xbabecafe

// CHECK: fildl	305419896
// CHECK:  encoding: [0xdb,0x05,0x78,0x56,0x34,0x12]
        	fildl	0x12345678

// CHECK: fildll	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdf,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	fildll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fildll	32493
// CHECK:  encoding: [0xdf,0x2d,0xed,0x7e,0x00,0x00]
        	fildll	0x7eed

// CHECK: fildll	3133065982
// CHECK:  encoding: [0xdf,0x2d,0xfe,0xca,0xbe,0xba]
        	fildll	0xbabecafe

// CHECK: fildll	305419896
// CHECK:  encoding: [0xdf,0x2d,0x78,0x56,0x34,0x12]
        	fildll	0x12345678

// CHECK: fldt	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	fldt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fldt	32493
// CHECK:  encoding: [0xdb,0x2d,0xed,0x7e,0x00,0x00]
        	fldt	0x7eed

// CHECK: fldt	3133065982
// CHECK:  encoding: [0xdb,0x2d,0xfe,0xca,0xbe,0xba]
        	fldt	0xbabecafe

// CHECK: fldt	305419896
// CHECK:  encoding: [0xdb,0x2d,0x78,0x56,0x34,0x12]
        	fldt	0x12345678

// CHECK: fbld	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdf,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	fbld	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fbld	32493
// CHECK:  encoding: [0xdf,0x25,0xed,0x7e,0x00,0x00]
        	fbld	0x7eed

// CHECK: fbld	3133065982
// CHECK:  encoding: [0xdf,0x25,0xfe,0xca,0xbe,0xba]
        	fbld	0xbabecafe

// CHECK: fbld	305419896
// CHECK:  encoding: [0xdf,0x25,0x78,0x56,0x34,0x12]
        	fbld	0x12345678

// CHECK: fst	%st(2)
// CHECK:  encoding: [0xdd,0xd2]
        	fst	%st(2)

// CHECK: fstl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdd,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	fstl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fstl	3133065982
// CHECK:  encoding: [0xdd,0x15,0xfe,0xca,0xbe,0xba]
        	fstl	0xbabecafe

// CHECK: fstl	305419896
// CHECK:  encoding: [0xdd,0x15,0x78,0x56,0x34,0x12]
        	fstl	0x12345678

// CHECK: fst	%st(2)
// CHECK:  encoding: [0xdd,0xd2]
        	fst	%st(2)

// CHECK: fistl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	fistl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fistl	3133065982
// CHECK:  encoding: [0xdb,0x15,0xfe,0xca,0xbe,0xba]
        	fistl	0xbabecafe

// CHECK: fistl	305419896
// CHECK:  encoding: [0xdb,0x15,0x78,0x56,0x34,0x12]
        	fistl	0x12345678

// CHECK: fstp	%st(2)
// CHECK:  encoding: [0xdd,0xda]
        	fstp	%st(2)

// CHECK: fstpl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdd,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	fstpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fstpl	3133065982
// CHECK:  encoding: [0xdd,0x1d,0xfe,0xca,0xbe,0xba]
        	fstpl	0xbabecafe

// CHECK: fstpl	305419896
// CHECK:  encoding: [0xdd,0x1d,0x78,0x56,0x34,0x12]
        	fstpl	0x12345678

// CHECK: fstp	%st(2)
// CHECK:  encoding: [0xdd,0xda]
        	fstp	%st(2)

// CHECK: fistpl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	fistpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fistpl	3133065982
// CHECK:  encoding: [0xdb,0x1d,0xfe,0xca,0xbe,0xba]
        	fistpl	0xbabecafe

// CHECK: fistpl	305419896
// CHECK:  encoding: [0xdb,0x1d,0x78,0x56,0x34,0x12]
        	fistpl	0x12345678

// CHECK: fistpll	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdf,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fistpll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fistpll	32493
// CHECK:  encoding: [0xdf,0x3d,0xed,0x7e,0x00,0x00]
        	fistpll	0x7eed

// CHECK: fistpll	3133065982
// CHECK:  encoding: [0xdf,0x3d,0xfe,0xca,0xbe,0xba]
        	fistpll	0xbabecafe

// CHECK: fistpll	305419896
// CHECK:  encoding: [0xdf,0x3d,0x78,0x56,0x34,0x12]
        	fistpll	0x12345678

// CHECK: fstpt	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fstpt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fstpt	32493
// CHECK:  encoding: [0xdb,0x3d,0xed,0x7e,0x00,0x00]
        	fstpt	0x7eed

// CHECK: fstpt	3133065982
// CHECK:  encoding: [0xdb,0x3d,0xfe,0xca,0xbe,0xba]
        	fstpt	0xbabecafe

// CHECK: fstpt	305419896
// CHECK:  encoding: [0xdb,0x3d,0x78,0x56,0x34,0x12]
        	fstpt	0x12345678

// CHECK: fbstp	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdf,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	fbstp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fbstp	32493
// CHECK:  encoding: [0xdf,0x35,0xed,0x7e,0x00,0x00]
        	fbstp	0x7eed

// CHECK: fbstp	3133065982
// CHECK:  encoding: [0xdf,0x35,0xfe,0xca,0xbe,0xba]
        	fbstp	0xbabecafe

// CHECK: fbstp	305419896
// CHECK:  encoding: [0xdf,0x35,0x78,0x56,0x34,0x12]
        	fbstp	0x12345678

// CHECK: fxch	%st(2)
// CHECK:  encoding: [0xd9,0xca]
        	fxch	%st(2)

// CHECK: fcom	%st(2)
// CHECK:  encoding: [0xd8,0xd2]
        	fcom	%st(2)

// CHECK: fcom	%st(2)
// CHECK:  encoding: [0xd8,0xd2]
        	fcom	%st(2)

// CHECK: ficoml	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	ficoml	0xdeadbeef(%ebx,%ecx,8)

// CHECK: ficoml	3133065982
// CHECK:  encoding: [0xda,0x15,0xfe,0xca,0xbe,0xba]
        	ficoml	0xbabecafe

// CHECK: ficoml	305419896
// CHECK:  encoding: [0xda,0x15,0x78,0x56,0x34,0x12]
        	ficoml	0x12345678

// CHECK: fcomp	%st(2)
// CHECK:  encoding: [0xd8,0xda]
        	fcomp	%st(2)

// CHECK: fcomp	%st(2)
// CHECK:  encoding: [0xd8,0xda]
        	fcomp	%st(2)

// CHECK: ficompl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	ficompl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: ficompl	3133065982
// CHECK:  encoding: [0xda,0x1d,0xfe,0xca,0xbe,0xba]
        	ficompl	0xbabecafe

// CHECK: ficompl	305419896
// CHECK:  encoding: [0xda,0x1d,0x78,0x56,0x34,0x12]
        	ficompl	0x12345678

// CHECK: fcompp
// CHECK:  encoding: [0xde,0xd9]
        	fcompp

// CHECK: fucom	%st(2)
// CHECK:  encoding: [0xdd,0xe2]
        	fucom	%st(2)

// CHECK: fucomp	%st(2)
// CHECK:  encoding: [0xdd,0xea]
        	fucomp	%st(2)

// CHECK: fucompp
// CHECK:  encoding: [0xda,0xe9]
        	fucompp

// CHECK: ftst
// CHECK:  encoding: [0xd9,0xe4]
        	ftst

// CHECK: fxam
// CHECK:  encoding: [0xd9,0xe5]
        	fxam

// CHECK: fld1
// CHECK:  encoding: [0xd9,0xe8]
        	fld1

// CHECK: fldl2t
// CHECK:  encoding: [0xd9,0xe9]
        	fldl2t

// CHECK: fldl2e
// CHECK:  encoding: [0xd9,0xea]
        	fldl2e

// CHECK: fldpi
// CHECK:  encoding: [0xd9,0xeb]
        	fldpi

// CHECK: fldlg2
// CHECK:  encoding: [0xd9,0xec]
        	fldlg2

// CHECK: fldln2
// CHECK:  encoding: [0xd9,0xed]
        	fldln2

// CHECK: fldz
// CHECK:  encoding: [0xd9,0xee]
        	fldz

// CHECK: fadd	%st(2)
// CHECK:  encoding: [0xd8,0xc2]
        	fadd	%st(2)

// CHECK: faddl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	faddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: faddl	3133065982
// CHECK:  encoding: [0xdc,0x05,0xfe,0xca,0xbe,0xba]
        	faddl	0xbabecafe

// CHECK: faddl	305419896
// CHECK:  encoding: [0xdc,0x05,0x78,0x56,0x34,0x12]
        	faddl	0x12345678

// CHECK: fiaddl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	fiaddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fiaddl	3133065982
// CHECK:  encoding: [0xda,0x05,0xfe,0xca,0xbe,0xba]
        	fiaddl	0xbabecafe

// CHECK: fiaddl	305419896
// CHECK:  encoding: [0xda,0x05,0x78,0x56,0x34,0x12]
        	fiaddl	0x12345678

// CHECK: faddp	%st(2)
// CHECK:  encoding: [0xde,0xc2]
        	faddp	%st(2)

// CHECK: fsub	%st(2)
// CHECK:  encoding: [0xd8,0xe2]
        	fsub	%st(2)

// CHECK: fsubl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	fsubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fsubl	3133065982
// CHECK:  encoding: [0xdc,0x25,0xfe,0xca,0xbe,0xba]
        	fsubl	0xbabecafe

// CHECK: fsubl	305419896
// CHECK:  encoding: [0xdc,0x25,0x78,0x56,0x34,0x12]
        	fsubl	0x12345678

// CHECK: fisubl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0xa4,0xcb,0xef,0xbe,0xad,0xde]
        	fisubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fisubl	3133065982
// CHECK:  encoding: [0xda,0x25,0xfe,0xca,0xbe,0xba]
        	fisubl	0xbabecafe

// CHECK: fisubl	305419896
// CHECK:  encoding: [0xda,0x25,0x78,0x56,0x34,0x12]
        	fisubl	0x12345678

// CHECK: fsubp	%st(2)
// CHECK:  encoding: [0xde,0xe2]
        	fsubp	%st(2)

// CHECK: fsubr	%st(2)
// CHECK:  encoding: [0xd8,0xea]
        	fsubr	%st(2)

// CHECK: fsubrl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	fsubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fsubrl	3133065982
// CHECK:  encoding: [0xdc,0x2d,0xfe,0xca,0xbe,0xba]
        	fsubrl	0xbabecafe

// CHECK: fsubrl	305419896
// CHECK:  encoding: [0xdc,0x2d,0x78,0x56,0x34,0x12]
        	fsubrl	0x12345678

// CHECK: fisubrl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	fisubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fisubrl	3133065982
// CHECK:  encoding: [0xda,0x2d,0xfe,0xca,0xbe,0xba]
        	fisubrl	0xbabecafe

// CHECK: fisubrl	305419896
// CHECK:  encoding: [0xda,0x2d,0x78,0x56,0x34,0x12]
        	fisubrl	0x12345678

// CHECK: fsubrp	%st(2)
// CHECK:  encoding: [0xde,0xea]
        	fsubrp	%st(2)

// CHECK: fmul	%st(2)
// CHECK:  encoding: [0xd8,0xca]
        	fmul	%st(2)

// CHECK: fmull	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	fmull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fmull	3133065982
// CHECK:  encoding: [0xdc,0x0d,0xfe,0xca,0xbe,0xba]
        	fmull	0xbabecafe

// CHECK: fmull	305419896
// CHECK:  encoding: [0xdc,0x0d,0x78,0x56,0x34,0x12]
        	fmull	0x12345678

// CHECK: fimull	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	fimull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fimull	3133065982
// CHECK:  encoding: [0xda,0x0d,0xfe,0xca,0xbe,0xba]
        	fimull	0xbabecafe

// CHECK: fimull	305419896
// CHECK:  encoding: [0xda,0x0d,0x78,0x56,0x34,0x12]
        	fimull	0x12345678

// CHECK: fmulp	%st(2)
// CHECK:  encoding: [0xde,0xca]
        	fmulp	%st(2)

// CHECK: fdiv	%st(2)
// CHECK:  encoding: [0xd8,0xf2]
        	fdiv	%st(2)

// CHECK: fdivl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	fdivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fdivl	3133065982
// CHECK:  encoding: [0xdc,0x35,0xfe,0xca,0xbe,0xba]
        	fdivl	0xbabecafe

// CHECK: fdivl	305419896
// CHECK:  encoding: [0xdc,0x35,0x78,0x56,0x34,0x12]
        	fdivl	0x12345678

// CHECK: fidivl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	fidivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fidivl	3133065982
// CHECK:  encoding: [0xda,0x35,0xfe,0xca,0xbe,0xba]
        	fidivl	0xbabecafe

// CHECK: fidivl	305419896
// CHECK:  encoding: [0xda,0x35,0x78,0x56,0x34,0x12]
        	fidivl	0x12345678

// CHECK: fdivp	%st(2)
// CHECK:  encoding: [0xde,0xf2]
        	fdivp	%st(2)

// CHECK: fdivr	%st(2)
// CHECK:  encoding: [0xd8,0xfa]
        	fdivr	%st(2)

// CHECK: fdivrl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fdivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fdivrl	3133065982
// CHECK:  encoding: [0xdc,0x3d,0xfe,0xca,0xbe,0xba]
        	fdivrl	0xbabecafe

// CHECK: fdivrl	305419896
// CHECK:  encoding: [0xdc,0x3d,0x78,0x56,0x34,0x12]
        	fdivrl	0x12345678

// CHECK: fidivrl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fidivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fidivrl	3133065982
// CHECK:  encoding: [0xda,0x3d,0xfe,0xca,0xbe,0xba]
        	fidivrl	0xbabecafe

// CHECK: fidivrl	305419896
// CHECK:  encoding: [0xda,0x3d,0x78,0x56,0x34,0x12]
        	fidivrl	0x12345678

// CHECK: fdivrp	%st(2)
// CHECK:  encoding: [0xde,0xfa]
        	fdivrp	%st(2)

// CHECK: f2xm1
// CHECK:  encoding: [0xd9,0xf0]
        	f2xm1

// CHECK: fyl2x
// CHECK:  encoding: [0xd9,0xf1]
        	fyl2x

// CHECK: fptan
// CHECK:  encoding: [0xd9,0xf2]
        	fptan

// CHECK: fpatan
// CHECK:  encoding: [0xd9,0xf3]
        	fpatan

// CHECK: fxtract
// CHECK:  encoding: [0xd9,0xf4]
        	fxtract

// CHECK: fprem1
// CHECK:  encoding: [0xd9,0xf5]
        	fprem1

// CHECK: fdecstp
// CHECK:  encoding: [0xd9,0xf6]
        	fdecstp

// CHECK: fincstp
// CHECK:  encoding: [0xd9,0xf7]
        	fincstp

// CHECK: fprem
// CHECK:  encoding: [0xd9,0xf8]
        	fprem

// CHECK: fyl2xp1
// CHECK:  encoding: [0xd9,0xf9]
        	fyl2xp1

// CHECK: fsqrt
// CHECK:  encoding: [0xd9,0xfa]
        	fsqrt

// CHECK: fsincos
// CHECK:  encoding: [0xd9,0xfb]
        	fsincos

// CHECK: frndint
// CHECK:  encoding: [0xd9,0xfc]
        	frndint

// CHECK: fscale
// CHECK:  encoding: [0xd9,0xfd]
        	fscale

// CHECK: fsin
// CHECK:  encoding: [0xd9,0xfe]
        	fsin

// CHECK: fcos
// CHECK:  encoding: [0xd9,0xff]
        	fcos

// CHECK: fchs
// CHECK:  encoding: [0xd9,0xe0]
        	fchs

// CHECK: fabs
// CHECK:  encoding: [0xd9,0xe1]
        	fabs

// CHECK: fninit
// CHECK:  encoding: [0xdb,0xe3]
        	fninit

// CHECK: fldcw	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd9,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	fldcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fldcw	3133065982
// CHECK:  encoding: [0xd9,0x2d,0xfe,0xca,0xbe,0xba]
        	fldcw	0xbabecafe

// CHECK: fldcw	305419896
// CHECK:  encoding: [0xd9,0x2d,0x78,0x56,0x34,0x12]
        	fldcw	0x12345678

// CHECK: fnstcw	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xd9,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fnstcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fnstcw	3133065982
// CHECK:  encoding: [0xd9,0x3d,0xfe,0xca,0xbe,0xba]
        	fnstcw	0xbabecafe

// CHECK: fnstcw	305419896
// CHECK:  encoding: [0xd9,0x3d,0x78,0x56,0x34,0x12]
        	fnstcw	0x12345678

// CHECK: fnstsw	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdd,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	fnstsw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fnstsw	3133065982
// CHECK:  encoding: [0xdd,0x3d,0xfe,0xca,0xbe,0xba]
        	fnstsw	0xbabecafe

// CHECK: fnstsw	305419896
// CHECK:  encoding: [0xdd,0x3d,0x78,0x56,0x34,0x12]
        	fnstsw	0x12345678

// CHECK: fnclex
// CHECK:  encoding: [0xdb,0xe2]
        	fnclex

// CHECK: fnstenv	32493
// CHECK:  encoding: [0xd9,0x35,0xed,0x7e,0x00,0x00]
        	fnstenv	0x7eed

// CHECK: fldenv	32493
// CHECK:  encoding: [0xd9,0x25,0xed,0x7e,0x00,0x00]
        	fldenv	0x7eed

// CHECK: fnsave	32493
// CHECK:  encoding: [0xdd,0x35,0xed,0x7e,0x00,0x00]
        	fnsave	0x7eed

// CHECK: frstor	32493
// CHECK:  encoding: [0xdd,0x25,0xed,0x7e,0x00,0x00]
        	frstor	0x7eed

// CHECK: ffree	%st(2)
// CHECK:  encoding: [0xdd,0xc2]
        	ffree	%st(2)

// CHECK: fnop
// CHECK:  encoding: [0xd9,0xd0]
        	fnop

// CHECK: invd
// CHECK:  encoding: [0x0f,0x08]
        	invd

// CHECK: wbinvd
// CHECK:  encoding: [0x0f,0x09]
        	wbinvd

// CHECK: cpuid
// CHECK:  encoding: [0x0f,0xa2]
        	cpuid

// CHECK: wrmsr
// CHECK:  encoding: [0x0f,0x30]
        	wrmsr

// CHECK: rdtsc
// CHECK:  encoding: [0x0f,0x31]
        	rdtsc

// CHECK: rdmsr
// CHECK:  encoding: [0x0f,0x32]
        	rdmsr

// CHECK: cmpxchg8b	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xc7,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	cmpxchg8b	0xdeadbeef(%ebx,%ecx,8)

// CHECK: cmpxchg8b	32493
// CHECK:  encoding: [0x0f,0xc7,0x0d,0xed,0x7e,0x00,0x00]
        	cmpxchg8b	0x7eed

// CHECK: cmpxchg8b	3133065982
// CHECK:  encoding: [0x0f,0xc7,0x0d,0xfe,0xca,0xbe,0xba]
        	cmpxchg8b	0xbabecafe

// CHECK: cmpxchg8b	305419896
// CHECK:  encoding: [0x0f,0xc7,0x0d,0x78,0x56,0x34,0x12]
        	cmpxchg8b	0x12345678

// CHECK: sysenter
// CHECK:  encoding: [0x0f,0x34]
        	sysenter

// CHECK: sysexit
// CHECK:  encoding: [0x0f,0x35]
        	sysexit

// CHECK: sysexitl
// CHECK:  encoding: [0x0f,0x35]
        	sysexitl

// CHECK: fxsave	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xae,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	fxsave	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fxsave	32493
// CHECK:  encoding: [0x0f,0xae,0x05,0xed,0x7e,0x00,0x00]
        	fxsave	0x7eed

// CHECK: fxsave	3133065982
// CHECK:  encoding: [0x0f,0xae,0x05,0xfe,0xca,0xbe,0xba]
        	fxsave	0xbabecafe

// CHECK: fxsave	305419896
// CHECK:  encoding: [0x0f,0xae,0x05,0x78,0x56,0x34,0x12]
        	fxsave	0x12345678

// CHECK: fxrstor	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xae,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	fxrstor	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fxrstor	32493
// CHECK:  encoding: [0x0f,0xae,0x0d,0xed,0x7e,0x00,0x00]
        	fxrstor	0x7eed

// CHECK: fxrstor	3133065982
// CHECK:  encoding: [0x0f,0xae,0x0d,0xfe,0xca,0xbe,0xba]
        	fxrstor	0xbabecafe

// CHECK: fxrstor	305419896
// CHECK:  encoding: [0x0f,0xae,0x0d,0x78,0x56,0x34,0x12]
        	fxrstor	0x12345678

// CHECK: rdpmc
// CHECK:  encoding: [0x0f,0x33]
        	rdpmc

// CHECK: ud2
// CHECK:  encoding: [0x0f,0x0b]
        	ud2

// CHECK: fcmovb	%st(2), %st(0)
// CHECK:  encoding: [0xda,0xc2]
        	fcmovb	%st(2),%st

// CHECK: fcmove	%st(2), %st(0)
// CHECK:  encoding: [0xda,0xca]
        	fcmove	%st(2),%st

// CHECK: fcmovbe	%st(2), %st(0)
// CHECK:  encoding: [0xda,0xd2]
        	fcmovbe	%st(2),%st

// CHECK: fcmovu	 %st(2), %st(0)
// CHECK:  encoding: [0xda,0xda]
        	fcmovu	%st(2),%st

// CHECK: fcmovnb	%st(2), %st(0)
// CHECK:  encoding: [0xdb,0xc2]
        	fcmovnb	%st(2),%st

// CHECK: fcmovne	%st(2), %st(0)
// CHECK:  encoding: [0xdb,0xca]
        	fcmovne	%st(2),%st

// CHECK: fcmovnbe	%st(2), %st(0)
// CHECK:  encoding: [0xdb,0xd2]
        	fcmovnbe	%st(2),%st

// CHECK: fcmovnu	%st(2), %st(0)
// CHECK:  encoding: [0xdb,0xda]
        	fcmovnu	%st(2),%st

// CHECK: fcomi	%st(2)
// CHECK:  encoding: [0xdb,0xf2]
        	fcomi	%st(2),%st

// CHECK: fucomi	%st(2)
// CHECK:  encoding: [0xdb,0xea]
        	fucomi	%st(2),%st

// CHECK: fcompi	%st(2)
// CHECK:  encoding: [0xdf,0xf2]
        	fcomip	%st(2),%st

// CHECK: fucompi	%st(2)
// CHECK:  encoding: [0xdf,0xea]
        	fucomip	%st(2),%st

// CHECK: movntil	%ecx, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xc3,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	movnti	%ecx,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movntil	%ecx, 69
// CHECK:  encoding: [0x0f,0xc3,0x0d,0x45,0x00,0x00,0x00]
        	movnti	%ecx,0x45

// CHECK: movntil	%ecx, 32493
// CHECK:  encoding: [0x0f,0xc3,0x0d,0xed,0x7e,0x00,0x00]
        	movnti	%ecx,0x7eed

// CHECK: movntil	%ecx, 3133065982
// CHECK:  encoding: [0x0f,0xc3,0x0d,0xfe,0xca,0xbe,0xba]
        	movnti	%ecx,0xbabecafe

// CHECK: movntil	%ecx, 305419896
// CHECK:  encoding: [0x0f,0xc3,0x0d,0x78,0x56,0x34,0x12]
        	movnti	%ecx,0x12345678

// CHECK: clflush	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xae,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	clflush	0xdeadbeef(%ebx,%ecx,8)

// CHECK: clflush	32493
// CHECK:  encoding: [0x0f,0xae,0x3d,0xed,0x7e,0x00,0x00]
        	clflush	0x7eed

// CHECK: clflush	3133065982
// CHECK:  encoding: [0x0f,0xae,0x3d,0xfe,0xca,0xbe,0xba]
        	clflush	0xbabecafe

// CHECK: clflush	305419896
// CHECK:  encoding: [0x0f,0xae,0x3d,0x78,0x56,0x34,0x12]
        	clflush	0x12345678

// CHECK: emms
// CHECK:  encoding: [0x0f,0x77]
        	emms

// CHECK: movd	%ecx, %mm3
// CHECK:  encoding: [0x0f,0x6e,0xd9]
        	movd	%ecx,%mm3

// CHECK: movd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x6e,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: movd	69, %mm3
// CHECK:  encoding: [0x0f,0x6e,0x1d,0x45,0x00,0x00,0x00]
        	movd	0x45,%mm3

// CHECK: movd	32493, %mm3
// CHECK:  encoding: [0x0f,0x6e,0x1d,0xed,0x7e,0x00,0x00]
        	movd	0x7eed,%mm3

// CHECK: movd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x6e,0x1d,0xfe,0xca,0xbe,0xba]
        	movd	0xbabecafe,%mm3

// CHECK: movd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x6e,0x1d,0x78,0x56,0x34,0x12]
        	movd	0x12345678,%mm3

// CHECK: movd	%mm3, %ecx
// CHECK:  encoding: [0x0f,0x7e,0xd9]
        	movd	%mm3,%ecx

// CHECK: movd	%mm3, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x7e,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movd	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movd	%mm3, 69
// CHECK:  encoding: [0x0f,0x7e,0x1d,0x45,0x00,0x00,0x00]
        	movd	%mm3,0x45

// CHECK: movd	%mm3, 32493
// CHECK:  encoding: [0x0f,0x7e,0x1d,0xed,0x7e,0x00,0x00]
        	movd	%mm3,0x7eed

// CHECK: movd	%mm3, 3133065982
// CHECK:  encoding: [0x0f,0x7e,0x1d,0xfe,0xca,0xbe,0xba]
        	movd	%mm3,0xbabecafe

// CHECK: movd	%mm3, 305419896
// CHECK:  encoding: [0x0f,0x7e,0x1d,0x78,0x56,0x34,0x12]
        	movd	%mm3,0x12345678

// CHECK: movd	%ecx, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0xe9]
        	movd	%ecx,%xmm5

// CHECK: movd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0x2d,0x45,0x00,0x00,0x00]
        	movd	0x45,%xmm5

// CHECK: movd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0x2d,0xed,0x7e,0x00,0x00]
        	movd	0x7eed,%xmm5

// CHECK: movd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0x2d,0xfe,0xca,0xbe,0xba]
        	movd	0xbabecafe,%xmm5

// CHECK: movd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0x2d,0x78,0x56,0x34,0x12]
        	movd	0x12345678,%xmm5

// CHECK: movd	%xmm5, %ecx
// CHECK:  encoding: [0x66,0x0f,0x7e,0xe9]
        	movd	%xmm5,%ecx

// CHECK: movd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x7e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x7e,0x2d,0x45,0x00,0x00,0x00]
        	movd	%xmm5,0x45

// CHECK: movd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x7e,0x2d,0xed,0x7e,0x00,0x00]
        	movd	%xmm5,0x7eed

// CHECK: movd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x7e,0x2d,0xfe,0xca,0xbe,0xba]
        	movd	%xmm5,0xbabecafe

// CHECK: movd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x7e,0x2d,0x78,0x56,0x34,0x12]
        	movd	%xmm5,0x12345678

// CHECK: movq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x6f,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: movq	69, %mm3
// CHECK:  encoding: [0x0f,0x6f,0x1d,0x45,0x00,0x00,0x00]
        	movq	0x45,%mm3

// CHECK: movq	32493, %mm3
// CHECK:  encoding: [0x0f,0x6f,0x1d,0xed,0x7e,0x00,0x00]
        	movq	0x7eed,%mm3

// CHECK: movq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x6f,0x1d,0xfe,0xca,0xbe,0xba]
        	movq	0xbabecafe,%mm3

// CHECK: movq	305419896, %mm3
// CHECK:  encoding: [0x0f,0x6f,0x1d,0x78,0x56,0x34,0x12]
        	movq	0x12345678,%mm3

// CHECK: movq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x6f,0xdb]
        	movq	%mm3,%mm3

// CHECK: movq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x6f,0xdb]
        	movq	%mm3,%mm3

// CHECK: movq	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x7e,0xed]
        	movq	%xmm5,%xmm5

// CHECK: movq	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0xd6,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movq	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movq	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0xd6,0x2d,0x45,0x00,0x00,0x00]
        	movq	%xmm5,0x45

// CHECK: movq	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0xd6,0x2d,0xed,0x7e,0x00,0x00]
        	movq	%xmm5,0x7eed

// CHECK: movq	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0xd6,0x2d,0xfe,0xca,0xbe,0xba]
        	movq	%xmm5,0xbabecafe

// CHECK: movq	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0xd6,0x2d,0x78,0x56,0x34,0x12]
        	movq	%xmm5,0x12345678

// CHECK: movq	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x7e,0xed]
        	movq	%xmm5,%xmm5

// CHECK: packssdw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x6b,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	packssdw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: packssdw	69, %mm3
// CHECK:  encoding: [0x0f,0x6b,0x1d,0x45,0x00,0x00,0x00]
        	packssdw	0x45,%mm3

// CHECK: packssdw	32493, %mm3
// CHECK:  encoding: [0x0f,0x6b,0x1d,0xed,0x7e,0x00,0x00]
        	packssdw	0x7eed,%mm3

// CHECK: packssdw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x6b,0x1d,0xfe,0xca,0xbe,0xba]
        	packssdw	0xbabecafe,%mm3

// CHECK: packssdw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x6b,0x1d,0x78,0x56,0x34,0x12]
        	packssdw	0x12345678,%mm3

// CHECK: packssdw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x6b,0xdb]
        	packssdw	%mm3,%mm3

// CHECK: packssdw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	packssdw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: packssdw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0x2d,0x45,0x00,0x00,0x00]
        	packssdw	0x45,%xmm5

// CHECK: packssdw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0x2d,0xed,0x7e,0x00,0x00]
        	packssdw	0x7eed,%xmm5

// CHECK: packssdw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0x2d,0xfe,0xca,0xbe,0xba]
        	packssdw	0xbabecafe,%xmm5

// CHECK: packssdw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0x2d,0x78,0x56,0x34,0x12]
        	packssdw	0x12345678,%xmm5

// CHECK: packssdw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6b,0xed]
        	packssdw	%xmm5,%xmm5

// CHECK: packsswb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x63,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	packsswb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: packsswb	69, %mm3
// CHECK:  encoding: [0x0f,0x63,0x1d,0x45,0x00,0x00,0x00]
        	packsswb	0x45,%mm3

// CHECK: packsswb	32493, %mm3
// CHECK:  encoding: [0x0f,0x63,0x1d,0xed,0x7e,0x00,0x00]
        	packsswb	0x7eed,%mm3

// CHECK: packsswb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x63,0x1d,0xfe,0xca,0xbe,0xba]
        	packsswb	0xbabecafe,%mm3

// CHECK: packsswb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x63,0x1d,0x78,0x56,0x34,0x12]
        	packsswb	0x12345678,%mm3

// CHECK: packsswb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x63,0xdb]
        	packsswb	%mm3,%mm3

// CHECK: packsswb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	packsswb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: packsswb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0x2d,0x45,0x00,0x00,0x00]
        	packsswb	0x45,%xmm5

// CHECK: packsswb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0x2d,0xed,0x7e,0x00,0x00]
        	packsswb	0x7eed,%xmm5

// CHECK: packsswb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0x2d,0xfe,0xca,0xbe,0xba]
        	packsswb	0xbabecafe,%xmm5

// CHECK: packsswb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0x2d,0x78,0x56,0x34,0x12]
        	packsswb	0x12345678,%xmm5

// CHECK: packsswb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x63,0xed]
        	packsswb	%xmm5,%xmm5

// CHECK: packuswb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x67,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	packuswb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: packuswb	69, %mm3
// CHECK:  encoding: [0x0f,0x67,0x1d,0x45,0x00,0x00,0x00]
        	packuswb	0x45,%mm3

// CHECK: packuswb	32493, %mm3
// CHECK:  encoding: [0x0f,0x67,0x1d,0xed,0x7e,0x00,0x00]
        	packuswb	0x7eed,%mm3

// CHECK: packuswb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x67,0x1d,0xfe,0xca,0xbe,0xba]
        	packuswb	0xbabecafe,%mm3

// CHECK: packuswb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x67,0x1d,0x78,0x56,0x34,0x12]
        	packuswb	0x12345678,%mm3

// CHECK: packuswb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x67,0xdb]
        	packuswb	%mm3,%mm3

// CHECK: packuswb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	packuswb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: packuswb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0x2d,0x45,0x00,0x00,0x00]
        	packuswb	0x45,%xmm5

// CHECK: packuswb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0x2d,0xed,0x7e,0x00,0x00]
        	packuswb	0x7eed,%xmm5

// CHECK: packuswb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0x2d,0xfe,0xca,0xbe,0xba]
        	packuswb	0xbabecafe,%xmm5

// CHECK: packuswb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0x2d,0x78,0x56,0x34,0x12]
        	packuswb	0x12345678,%xmm5

// CHECK: packuswb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x67,0xed]
        	packuswb	%xmm5,%xmm5

// CHECK: paddb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xfc,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddb	69, %mm3
// CHECK:  encoding: [0x0f,0xfc,0x1d,0x45,0x00,0x00,0x00]
        	paddb	0x45,%mm3

// CHECK: paddb	32493, %mm3
// CHECK:  encoding: [0x0f,0xfc,0x1d,0xed,0x7e,0x00,0x00]
        	paddb	0x7eed,%mm3

// CHECK: paddb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xfc,0x1d,0xfe,0xca,0xbe,0xba]
        	paddb	0xbabecafe,%mm3

// CHECK: paddb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xfc,0x1d,0x78,0x56,0x34,0x12]
        	paddb	0x12345678,%mm3

// CHECK: paddb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xfc,0xdb]
        	paddb	%mm3,%mm3

// CHECK: paddb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0x2d,0x45,0x00,0x00,0x00]
        	paddb	0x45,%xmm5

// CHECK: paddb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0x2d,0xed,0x7e,0x00,0x00]
        	paddb	0x7eed,%xmm5

// CHECK: paddb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0x2d,0xfe,0xca,0xbe,0xba]
        	paddb	0xbabecafe,%xmm5

// CHECK: paddb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0x2d,0x78,0x56,0x34,0x12]
        	paddb	0x12345678,%xmm5

// CHECK: paddb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfc,0xed]
        	paddb	%xmm5,%xmm5

// CHECK: paddw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xfd,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddw	69, %mm3
// CHECK:  encoding: [0x0f,0xfd,0x1d,0x45,0x00,0x00,0x00]
        	paddw	0x45,%mm3

// CHECK: paddw	32493, %mm3
// CHECK:  encoding: [0x0f,0xfd,0x1d,0xed,0x7e,0x00,0x00]
        	paddw	0x7eed,%mm3

// CHECK: paddw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xfd,0x1d,0xfe,0xca,0xbe,0xba]
        	paddw	0xbabecafe,%mm3

// CHECK: paddw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xfd,0x1d,0x78,0x56,0x34,0x12]
        	paddw	0x12345678,%mm3

// CHECK: paddw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xfd,0xdb]
        	paddw	%mm3,%mm3

// CHECK: paddw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0x2d,0x45,0x00,0x00,0x00]
        	paddw	0x45,%xmm5

// CHECK: paddw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0x2d,0xed,0x7e,0x00,0x00]
        	paddw	0x7eed,%xmm5

// CHECK: paddw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0x2d,0xfe,0xca,0xbe,0xba]
        	paddw	0xbabecafe,%xmm5

// CHECK: paddw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0x2d,0x78,0x56,0x34,0x12]
        	paddw	0x12345678,%xmm5

// CHECK: paddw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfd,0xed]
        	paddw	%xmm5,%xmm5

// CHECK: paddd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xfe,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddd	69, %mm3
// CHECK:  encoding: [0x0f,0xfe,0x1d,0x45,0x00,0x00,0x00]
        	paddd	0x45,%mm3

// CHECK: paddd	32493, %mm3
// CHECK:  encoding: [0x0f,0xfe,0x1d,0xed,0x7e,0x00,0x00]
        	paddd	0x7eed,%mm3

// CHECK: paddd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xfe,0x1d,0xfe,0xca,0xbe,0xba]
        	paddd	0xbabecafe,%mm3

// CHECK: paddd	305419896, %mm3
// CHECK:  encoding: [0x0f,0xfe,0x1d,0x78,0x56,0x34,0x12]
        	paddd	0x12345678,%mm3

// CHECK: paddd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xfe,0xdb]
        	paddd	%mm3,%mm3

// CHECK: paddd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0x2d,0x45,0x00,0x00,0x00]
        	paddd	0x45,%xmm5

// CHECK: paddd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0x2d,0xed,0x7e,0x00,0x00]
        	paddd	0x7eed,%xmm5

// CHECK: paddd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0x2d,0xfe,0xca,0xbe,0xba]
        	paddd	0xbabecafe,%xmm5

// CHECK: paddd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0x2d,0x78,0x56,0x34,0x12]
        	paddd	0x12345678,%xmm5

// CHECK: paddd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfe,0xed]
        	paddd	%xmm5,%xmm5

// CHECK: paddq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd4,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddq	69, %mm3
// CHECK:  encoding: [0x0f,0xd4,0x1d,0x45,0x00,0x00,0x00]
        	paddq	0x45,%mm3

// CHECK: paddq	32493, %mm3
// CHECK:  encoding: [0x0f,0xd4,0x1d,0xed,0x7e,0x00,0x00]
        	paddq	0x7eed,%mm3

// CHECK: paddq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd4,0x1d,0xfe,0xca,0xbe,0xba]
        	paddq	0xbabecafe,%mm3

// CHECK: paddq	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd4,0x1d,0x78,0x56,0x34,0x12]
        	paddq	0x12345678,%mm3

// CHECK: paddq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd4,0xdb]
        	paddq	%mm3,%mm3

// CHECK: paddq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0x2d,0x45,0x00,0x00,0x00]
        	paddq	0x45,%xmm5

// CHECK: paddq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0x2d,0xed,0x7e,0x00,0x00]
        	paddq	0x7eed,%xmm5

// CHECK: paddq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0x2d,0xfe,0xca,0xbe,0xba]
        	paddq	0xbabecafe,%xmm5

// CHECK: paddq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0x2d,0x78,0x56,0x34,0x12]
        	paddq	0x12345678,%xmm5

// CHECK: paddq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd4,0xed]
        	paddq	%xmm5,%xmm5

// CHECK: paddsb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xec,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddsb	69, %mm3
// CHECK:  encoding: [0x0f,0xec,0x1d,0x45,0x00,0x00,0x00]
        	paddsb	0x45,%mm3

// CHECK: paddsb	32493, %mm3
// CHECK:  encoding: [0x0f,0xec,0x1d,0xed,0x7e,0x00,0x00]
        	paddsb	0x7eed,%mm3

// CHECK: paddsb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xec,0x1d,0xfe,0xca,0xbe,0xba]
        	paddsb	0xbabecafe,%mm3

// CHECK: paddsb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xec,0x1d,0x78,0x56,0x34,0x12]
        	paddsb	0x12345678,%mm3

// CHECK: paddsb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xec,0xdb]
        	paddsb	%mm3,%mm3

// CHECK: paddsb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddsb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0x2d,0x45,0x00,0x00,0x00]
        	paddsb	0x45,%xmm5

// CHECK: paddsb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0x2d,0xed,0x7e,0x00,0x00]
        	paddsb	0x7eed,%xmm5

// CHECK: paddsb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0x2d,0xfe,0xca,0xbe,0xba]
        	paddsb	0xbabecafe,%xmm5

// CHECK: paddsb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0x2d,0x78,0x56,0x34,0x12]
        	paddsb	0x12345678,%xmm5

// CHECK: paddsb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xec,0xed]
        	paddsb	%xmm5,%xmm5

// CHECK: paddsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xed,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddsw	69, %mm3
// CHECK:  encoding: [0x0f,0xed,0x1d,0x45,0x00,0x00,0x00]
        	paddsw	0x45,%mm3

// CHECK: paddsw	32493, %mm3
// CHECK:  encoding: [0x0f,0xed,0x1d,0xed,0x7e,0x00,0x00]
        	paddsw	0x7eed,%mm3

// CHECK: paddsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xed,0x1d,0xfe,0xca,0xbe,0xba]
        	paddsw	0xbabecafe,%mm3

// CHECK: paddsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xed,0x1d,0x78,0x56,0x34,0x12]
        	paddsw	0x12345678,%mm3

// CHECK: paddsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xed,0xdb]
        	paddsw	%mm3,%mm3

// CHECK: paddsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0x2d,0x45,0x00,0x00,0x00]
        	paddsw	0x45,%xmm5

// CHECK: paddsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0x2d,0xed,0x7e,0x00,0x00]
        	paddsw	0x7eed,%xmm5

// CHECK: paddsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0x2d,0xfe,0xca,0xbe,0xba]
        	paddsw	0xbabecafe,%xmm5

// CHECK: paddsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0x2d,0x78,0x56,0x34,0x12]
        	paddsw	0x12345678,%xmm5

// CHECK: paddsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xed,0xed]
        	paddsw	%xmm5,%xmm5

// CHECK: paddusb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xdc,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddusb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddusb	69, %mm3
// CHECK:  encoding: [0x0f,0xdc,0x1d,0x45,0x00,0x00,0x00]
        	paddusb	0x45,%mm3

// CHECK: paddusb	32493, %mm3
// CHECK:  encoding: [0x0f,0xdc,0x1d,0xed,0x7e,0x00,0x00]
        	paddusb	0x7eed,%mm3

// CHECK: paddusb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xdc,0x1d,0xfe,0xca,0xbe,0xba]
        	paddusb	0xbabecafe,%mm3

// CHECK: paddusb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xdc,0x1d,0x78,0x56,0x34,0x12]
        	paddusb	0x12345678,%mm3

// CHECK: paddusb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xdc,0xdb]
        	paddusb	%mm3,%mm3

// CHECK: paddusb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddusb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddusb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0x2d,0x45,0x00,0x00,0x00]
        	paddusb	0x45,%xmm5

// CHECK: paddusb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0x2d,0xed,0x7e,0x00,0x00]
        	paddusb	0x7eed,%xmm5

// CHECK: paddusb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0x2d,0xfe,0xca,0xbe,0xba]
        	paddusb	0xbabecafe,%xmm5

// CHECK: paddusb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0x2d,0x78,0x56,0x34,0x12]
        	paddusb	0x12345678,%xmm5

// CHECK: paddusb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdc,0xed]
        	paddusb	%xmm5,%xmm5

// CHECK: paddusw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xdd,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	paddusw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: paddusw	69, %mm3
// CHECK:  encoding: [0x0f,0xdd,0x1d,0x45,0x00,0x00,0x00]
        	paddusw	0x45,%mm3

// CHECK: paddusw	32493, %mm3
// CHECK:  encoding: [0x0f,0xdd,0x1d,0xed,0x7e,0x00,0x00]
        	paddusw	0x7eed,%mm3

// CHECK: paddusw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xdd,0x1d,0xfe,0xca,0xbe,0xba]
        	paddusw	0xbabecafe,%mm3

// CHECK: paddusw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xdd,0x1d,0x78,0x56,0x34,0x12]
        	paddusw	0x12345678,%mm3

// CHECK: paddusw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xdd,0xdb]
        	paddusw	%mm3,%mm3

// CHECK: paddusw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	paddusw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: paddusw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0x2d,0x45,0x00,0x00,0x00]
        	paddusw	0x45,%xmm5

// CHECK: paddusw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0x2d,0xed,0x7e,0x00,0x00]
        	paddusw	0x7eed,%xmm5

// CHECK: paddusw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0x2d,0xfe,0xca,0xbe,0xba]
        	paddusw	0xbabecafe,%xmm5

// CHECK: paddusw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0x2d,0x78,0x56,0x34,0x12]
        	paddusw	0x12345678,%xmm5

// CHECK: paddusw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdd,0xed]
        	paddusw	%xmm5,%xmm5

// CHECK: pand	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xdb,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pand	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pand	69, %mm3
// CHECK:  encoding: [0x0f,0xdb,0x1d,0x45,0x00,0x00,0x00]
        	pand	0x45,%mm3

// CHECK: pand	32493, %mm3
// CHECK:  encoding: [0x0f,0xdb,0x1d,0xed,0x7e,0x00,0x00]
        	pand	0x7eed,%mm3

// CHECK: pand	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xdb,0x1d,0xfe,0xca,0xbe,0xba]
        	pand	0xbabecafe,%mm3

// CHECK: pand	305419896, %mm3
// CHECK:  encoding: [0x0f,0xdb,0x1d,0x78,0x56,0x34,0x12]
        	pand	0x12345678,%mm3

// CHECK: pand	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xdb,0xdb]
        	pand	%mm3,%mm3

// CHECK: pand	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pand	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pand	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0x2d,0x45,0x00,0x00,0x00]
        	pand	0x45,%xmm5

// CHECK: pand	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0x2d,0xed,0x7e,0x00,0x00]
        	pand	0x7eed,%xmm5

// CHECK: pand	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0x2d,0xfe,0xca,0xbe,0xba]
        	pand	0xbabecafe,%xmm5

// CHECK: pand	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0x2d,0x78,0x56,0x34,0x12]
        	pand	0x12345678,%xmm5

// CHECK: pand	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdb,0xed]
        	pand	%xmm5,%xmm5

// CHECK: pandn	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xdf,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pandn	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pandn	69, %mm3
// CHECK:  encoding: [0x0f,0xdf,0x1d,0x45,0x00,0x00,0x00]
        	pandn	0x45,%mm3

// CHECK: pandn	32493, %mm3
// CHECK:  encoding: [0x0f,0xdf,0x1d,0xed,0x7e,0x00,0x00]
        	pandn	0x7eed,%mm3

// CHECK: pandn	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xdf,0x1d,0xfe,0xca,0xbe,0xba]
        	pandn	0xbabecafe,%mm3

// CHECK: pandn	305419896, %mm3
// CHECK:  encoding: [0x0f,0xdf,0x1d,0x78,0x56,0x34,0x12]
        	pandn	0x12345678,%mm3

// CHECK: pandn	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xdf,0xdb]
        	pandn	%mm3,%mm3

// CHECK: pandn	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pandn	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pandn	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0x2d,0x45,0x00,0x00,0x00]
        	pandn	0x45,%xmm5

// CHECK: pandn	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0x2d,0xed,0x7e,0x00,0x00]
        	pandn	0x7eed,%xmm5

// CHECK: pandn	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0x2d,0xfe,0xca,0xbe,0xba]
        	pandn	0xbabecafe,%xmm5

// CHECK: pandn	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0x2d,0x78,0x56,0x34,0x12]
        	pandn	0x12345678,%xmm5

// CHECK: pandn	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xdf,0xed]
        	pandn	%xmm5,%xmm5

// CHECK: pcmpeqb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x74,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpeqb	69, %mm3
// CHECK:  encoding: [0x0f,0x74,0x1d,0x45,0x00,0x00,0x00]
        	pcmpeqb	0x45,%mm3

// CHECK: pcmpeqb	32493, %mm3
// CHECK:  encoding: [0x0f,0x74,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpeqb	0x7eed,%mm3

// CHECK: pcmpeqb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x74,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpeqb	0xbabecafe,%mm3

// CHECK: pcmpeqb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x74,0x1d,0x78,0x56,0x34,0x12]
        	pcmpeqb	0x12345678,%mm3

// CHECK: pcmpeqb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x74,0xdb]
        	pcmpeqb	%mm3,%mm3

// CHECK: pcmpeqb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpeqb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0x2d,0x45,0x00,0x00,0x00]
        	pcmpeqb	0x45,%xmm5

// CHECK: pcmpeqb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpeqb	0x7eed,%xmm5

// CHECK: pcmpeqb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpeqb	0xbabecafe,%xmm5

// CHECK: pcmpeqb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0x2d,0x78,0x56,0x34,0x12]
        	pcmpeqb	0x12345678,%xmm5

// CHECK: pcmpeqb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x74,0xed]
        	pcmpeqb	%xmm5,%xmm5

// CHECK: pcmpeqw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x75,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpeqw	69, %mm3
// CHECK:  encoding: [0x0f,0x75,0x1d,0x45,0x00,0x00,0x00]
        	pcmpeqw	0x45,%mm3

// CHECK: pcmpeqw	32493, %mm3
// CHECK:  encoding: [0x0f,0x75,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpeqw	0x7eed,%mm3

// CHECK: pcmpeqw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x75,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpeqw	0xbabecafe,%mm3

// CHECK: pcmpeqw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x75,0x1d,0x78,0x56,0x34,0x12]
        	pcmpeqw	0x12345678,%mm3

// CHECK: pcmpeqw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x75,0xdb]
        	pcmpeqw	%mm3,%mm3

// CHECK: pcmpeqw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpeqw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0x2d,0x45,0x00,0x00,0x00]
        	pcmpeqw	0x45,%xmm5

// CHECK: pcmpeqw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpeqw	0x7eed,%xmm5

// CHECK: pcmpeqw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpeqw	0xbabecafe,%xmm5

// CHECK: pcmpeqw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0x2d,0x78,0x56,0x34,0x12]
        	pcmpeqw	0x12345678,%xmm5

// CHECK: pcmpeqw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x75,0xed]
        	pcmpeqw	%xmm5,%xmm5

// CHECK: pcmpeqd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x76,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpeqd	69, %mm3
// CHECK:  encoding: [0x0f,0x76,0x1d,0x45,0x00,0x00,0x00]
        	pcmpeqd	0x45,%mm3

// CHECK: pcmpeqd	32493, %mm3
// CHECK:  encoding: [0x0f,0x76,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpeqd	0x7eed,%mm3

// CHECK: pcmpeqd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x76,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpeqd	0xbabecafe,%mm3

// CHECK: pcmpeqd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x76,0x1d,0x78,0x56,0x34,0x12]
        	pcmpeqd	0x12345678,%mm3

// CHECK: pcmpeqd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x76,0xdb]
        	pcmpeqd	%mm3,%mm3

// CHECK: pcmpeqd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpeqd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0x2d,0x45,0x00,0x00,0x00]
        	pcmpeqd	0x45,%xmm5

// CHECK: pcmpeqd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpeqd	0x7eed,%xmm5

// CHECK: pcmpeqd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpeqd	0xbabecafe,%xmm5

// CHECK: pcmpeqd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0x2d,0x78,0x56,0x34,0x12]
        	pcmpeqd	0x12345678,%xmm5

// CHECK: pcmpeqd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x76,0xed]
        	pcmpeqd	%xmm5,%xmm5

// CHECK: pcmpgtb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x64,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpgtb	69, %mm3
// CHECK:  encoding: [0x0f,0x64,0x1d,0x45,0x00,0x00,0x00]
        	pcmpgtb	0x45,%mm3

// CHECK: pcmpgtb	32493, %mm3
// CHECK:  encoding: [0x0f,0x64,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpgtb	0x7eed,%mm3

// CHECK: pcmpgtb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x64,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpgtb	0xbabecafe,%mm3

// CHECK: pcmpgtb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x64,0x1d,0x78,0x56,0x34,0x12]
        	pcmpgtb	0x12345678,%mm3

// CHECK: pcmpgtb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x64,0xdb]
        	pcmpgtb	%mm3,%mm3

// CHECK: pcmpgtb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpgtb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0x2d,0x45,0x00,0x00,0x00]
        	pcmpgtb	0x45,%xmm5

// CHECK: pcmpgtb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpgtb	0x7eed,%xmm5

// CHECK: pcmpgtb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpgtb	0xbabecafe,%xmm5

// CHECK: pcmpgtb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0x2d,0x78,0x56,0x34,0x12]
        	pcmpgtb	0x12345678,%xmm5

// CHECK: pcmpgtb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x64,0xed]
        	pcmpgtb	%xmm5,%xmm5

// CHECK: pcmpgtw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x65,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpgtw	69, %mm3
// CHECK:  encoding: [0x0f,0x65,0x1d,0x45,0x00,0x00,0x00]
        	pcmpgtw	0x45,%mm3

// CHECK: pcmpgtw	32493, %mm3
// CHECK:  encoding: [0x0f,0x65,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpgtw	0x7eed,%mm3

// CHECK: pcmpgtw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x65,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpgtw	0xbabecafe,%mm3

// CHECK: pcmpgtw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x65,0x1d,0x78,0x56,0x34,0x12]
        	pcmpgtw	0x12345678,%mm3

// CHECK: pcmpgtw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x65,0xdb]
        	pcmpgtw	%mm3,%mm3

// CHECK: pcmpgtw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpgtw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0x2d,0x45,0x00,0x00,0x00]
        	pcmpgtw	0x45,%xmm5

// CHECK: pcmpgtw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpgtw	0x7eed,%xmm5

// CHECK: pcmpgtw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpgtw	0xbabecafe,%xmm5

// CHECK: pcmpgtw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0x2d,0x78,0x56,0x34,0x12]
        	pcmpgtw	0x12345678,%xmm5

// CHECK: pcmpgtw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x65,0xed]
        	pcmpgtw	%xmm5,%xmm5

// CHECK: pcmpgtd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x66,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pcmpgtd	69, %mm3
// CHECK:  encoding: [0x0f,0x66,0x1d,0x45,0x00,0x00,0x00]
        	pcmpgtd	0x45,%mm3

// CHECK: pcmpgtd	32493, %mm3
// CHECK:  encoding: [0x0f,0x66,0x1d,0xed,0x7e,0x00,0x00]
        	pcmpgtd	0x7eed,%mm3

// CHECK: pcmpgtd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x66,0x1d,0xfe,0xca,0xbe,0xba]
        	pcmpgtd	0xbabecafe,%mm3

// CHECK: pcmpgtd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x66,0x1d,0x78,0x56,0x34,0x12]
        	pcmpgtd	0x12345678,%mm3

// CHECK: pcmpgtd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x66,0xdb]
        	pcmpgtd	%mm3,%mm3

// CHECK: pcmpgtd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpgtd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0x2d,0x45,0x00,0x00,0x00]
        	pcmpgtd	0x45,%xmm5

// CHECK: pcmpgtd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpgtd	0x7eed,%xmm5

// CHECK: pcmpgtd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpgtd	0xbabecafe,%xmm5

// CHECK: pcmpgtd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0x2d,0x78,0x56,0x34,0x12]
        	pcmpgtd	0x12345678,%xmm5

// CHECK: pcmpgtd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x66,0xed]
        	pcmpgtd	%xmm5,%xmm5

// CHECK: pmaddwd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf5,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmaddwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmaddwd	69, %mm3
// CHECK:  encoding: [0x0f,0xf5,0x1d,0x45,0x00,0x00,0x00]
        	pmaddwd	0x45,%mm3

// CHECK: pmaddwd	32493, %mm3
// CHECK:  encoding: [0x0f,0xf5,0x1d,0xed,0x7e,0x00,0x00]
        	pmaddwd	0x7eed,%mm3

// CHECK: pmaddwd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf5,0x1d,0xfe,0xca,0xbe,0xba]
        	pmaddwd	0xbabecafe,%mm3

// CHECK: pmaddwd	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf5,0x1d,0x78,0x56,0x34,0x12]
        	pmaddwd	0x12345678,%mm3

// CHECK: pmaddwd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf5,0xdb]
        	pmaddwd	%mm3,%mm3

// CHECK: pmaddwd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaddwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaddwd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0x2d,0x45,0x00,0x00,0x00]
        	pmaddwd	0x45,%xmm5

// CHECK: pmaddwd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0x2d,0xed,0x7e,0x00,0x00]
        	pmaddwd	0x7eed,%xmm5

// CHECK: pmaddwd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaddwd	0xbabecafe,%xmm5

// CHECK: pmaddwd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0x2d,0x78,0x56,0x34,0x12]
        	pmaddwd	0x12345678,%xmm5

// CHECK: pmaddwd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf5,0xed]
        	pmaddwd	%xmm5,%xmm5

// CHECK: pmulhw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe5,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmulhw	69, %mm3
// CHECK:  encoding: [0x0f,0xe5,0x1d,0x45,0x00,0x00,0x00]
        	pmulhw	0x45,%mm3

// CHECK: pmulhw	32493, %mm3
// CHECK:  encoding: [0x0f,0xe5,0x1d,0xed,0x7e,0x00,0x00]
        	pmulhw	0x7eed,%mm3

// CHECK: pmulhw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe5,0x1d,0xfe,0xca,0xbe,0xba]
        	pmulhw	0xbabecafe,%mm3

// CHECK: pmulhw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe5,0x1d,0x78,0x56,0x34,0x12]
        	pmulhw	0x12345678,%mm3

// CHECK: pmulhw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe5,0xdb]
        	pmulhw	%mm3,%mm3

// CHECK: pmulhw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmulhw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0x2d,0x45,0x00,0x00,0x00]
        	pmulhw	0x45,%xmm5

// CHECK: pmulhw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0x2d,0xed,0x7e,0x00,0x00]
        	pmulhw	0x7eed,%xmm5

// CHECK: pmulhw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0x2d,0xfe,0xca,0xbe,0xba]
        	pmulhw	0xbabecafe,%xmm5

// CHECK: pmulhw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0x2d,0x78,0x56,0x34,0x12]
        	pmulhw	0x12345678,%xmm5

// CHECK: pmulhw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe5,0xed]
        	pmulhw	%xmm5,%xmm5

// CHECK: pmullw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd5,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmullw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmullw	69, %mm3
// CHECK:  encoding: [0x0f,0xd5,0x1d,0x45,0x00,0x00,0x00]
        	pmullw	0x45,%mm3

// CHECK: pmullw	32493, %mm3
// CHECK:  encoding: [0x0f,0xd5,0x1d,0xed,0x7e,0x00,0x00]
        	pmullw	0x7eed,%mm3

// CHECK: pmullw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd5,0x1d,0xfe,0xca,0xbe,0xba]
        	pmullw	0xbabecafe,%mm3

// CHECK: pmullw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd5,0x1d,0x78,0x56,0x34,0x12]
        	pmullw	0x12345678,%mm3

// CHECK: pmullw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd5,0xdb]
        	pmullw	%mm3,%mm3

// CHECK: pmullw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmullw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmullw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0x2d,0x45,0x00,0x00,0x00]
        	pmullw	0x45,%xmm5

// CHECK: pmullw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0x2d,0xed,0x7e,0x00,0x00]
        	pmullw	0x7eed,%xmm5

// CHECK: pmullw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0x2d,0xfe,0xca,0xbe,0xba]
        	pmullw	0xbabecafe,%xmm5

// CHECK: pmullw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0x2d,0x78,0x56,0x34,0x12]
        	pmullw	0x12345678,%xmm5

// CHECK: pmullw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd5,0xed]
        	pmullw	%xmm5,%xmm5

// CHECK: por	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xeb,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	por	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: por	69, %mm3
// CHECK:  encoding: [0x0f,0xeb,0x1d,0x45,0x00,0x00,0x00]
        	por	0x45,%mm3

// CHECK: por	32493, %mm3
// CHECK:  encoding: [0x0f,0xeb,0x1d,0xed,0x7e,0x00,0x00]
        	por	0x7eed,%mm3

// CHECK: por	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xeb,0x1d,0xfe,0xca,0xbe,0xba]
        	por	0xbabecafe,%mm3

// CHECK: por	305419896, %mm3
// CHECK:  encoding: [0x0f,0xeb,0x1d,0x78,0x56,0x34,0x12]
        	por	0x12345678,%mm3

// CHECK: por	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xeb,0xdb]
        	por	%mm3,%mm3

// CHECK: por	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	por	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: por	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0x2d,0x45,0x00,0x00,0x00]
        	por	0x45,%xmm5

// CHECK: por	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0x2d,0xed,0x7e,0x00,0x00]
        	por	0x7eed,%xmm5

// CHECK: por	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0x2d,0xfe,0xca,0xbe,0xba]
        	por	0xbabecafe,%xmm5

// CHECK: por	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0x2d,0x78,0x56,0x34,0x12]
        	por	0x12345678,%xmm5

// CHECK: por	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xeb,0xed]
        	por	%xmm5,%xmm5

// CHECK: psllw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf1,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psllw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psllw	69, %mm3
// CHECK:  encoding: [0x0f,0xf1,0x1d,0x45,0x00,0x00,0x00]
        	psllw	0x45,%mm3

// CHECK: psllw	32493, %mm3
// CHECK:  encoding: [0x0f,0xf1,0x1d,0xed,0x7e,0x00,0x00]
        	psllw	0x7eed,%mm3

// CHECK: psllw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf1,0x1d,0xfe,0xca,0xbe,0xba]
        	psllw	0xbabecafe,%mm3

// CHECK: psllw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf1,0x1d,0x78,0x56,0x34,0x12]
        	psllw	0x12345678,%mm3

// CHECK: psllw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf1,0xdb]
        	psllw	%mm3,%mm3

// CHECK: psllw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psllw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psllw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0x2d,0x45,0x00,0x00,0x00]
        	psllw	0x45,%xmm5

// CHECK: psllw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0x2d,0xed,0x7e,0x00,0x00]
        	psllw	0x7eed,%xmm5

// CHECK: psllw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0x2d,0xfe,0xca,0xbe,0xba]
        	psllw	0xbabecafe,%xmm5

// CHECK: psllw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0x2d,0x78,0x56,0x34,0x12]
        	psllw	0x12345678,%xmm5

// CHECK: psllw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf1,0xed]
        	psllw	%xmm5,%xmm5

// CHECK: psllw	$127, %mm3
// CHECK:  encoding: [0x0f,0x71,0xf3,0x7f]
        	psllw	$0x7f,%mm3

// CHECK: psllw	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x71,0xf5,0x7f]
        	psllw	$0x7f,%xmm5

// CHECK: pslld	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf2,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pslld	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pslld	69, %mm3
// CHECK:  encoding: [0x0f,0xf2,0x1d,0x45,0x00,0x00,0x00]
        	pslld	0x45,%mm3

// CHECK: pslld	32493, %mm3
// CHECK:  encoding: [0x0f,0xf2,0x1d,0xed,0x7e,0x00,0x00]
        	pslld	0x7eed,%mm3

// CHECK: pslld	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf2,0x1d,0xfe,0xca,0xbe,0xba]
        	pslld	0xbabecafe,%mm3

// CHECK: pslld	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf2,0x1d,0x78,0x56,0x34,0x12]
        	pslld	0x12345678,%mm3

// CHECK: pslld	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf2,0xdb]
        	pslld	%mm3,%mm3

// CHECK: pslld	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pslld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pslld	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0x2d,0x45,0x00,0x00,0x00]
        	pslld	0x45,%xmm5

// CHECK: pslld	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0x2d,0xed,0x7e,0x00,0x00]
        	pslld	0x7eed,%xmm5

// CHECK: pslld	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0x2d,0xfe,0xca,0xbe,0xba]
        	pslld	0xbabecafe,%xmm5

// CHECK: pslld	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0x2d,0x78,0x56,0x34,0x12]
        	pslld	0x12345678,%xmm5

// CHECK: pslld	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf2,0xed]
        	pslld	%xmm5,%xmm5

// CHECK: pslld	$127, %mm3
// CHECK:  encoding: [0x0f,0x72,0xf3,0x7f]
        	pslld	$0x7f,%mm3

// CHECK: pslld	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x72,0xf5,0x7f]
        	pslld	$0x7f,%xmm5

// CHECK: psllq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf3,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psllq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psllq	69, %mm3
// CHECK:  encoding: [0x0f,0xf3,0x1d,0x45,0x00,0x00,0x00]
        	psllq	0x45,%mm3

// CHECK: psllq	32493, %mm3
// CHECK:  encoding: [0x0f,0xf3,0x1d,0xed,0x7e,0x00,0x00]
        	psllq	0x7eed,%mm3

// CHECK: psllq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf3,0x1d,0xfe,0xca,0xbe,0xba]
        	psllq	0xbabecafe,%mm3

// CHECK: psllq	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf3,0x1d,0x78,0x56,0x34,0x12]
        	psllq	0x12345678,%mm3

// CHECK: psllq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf3,0xdb]
        	psllq	%mm3,%mm3

// CHECK: psllq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psllq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psllq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0x2d,0x45,0x00,0x00,0x00]
        	psllq	0x45,%xmm5

// CHECK: psllq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0x2d,0xed,0x7e,0x00,0x00]
        	psllq	0x7eed,%xmm5

// CHECK: psllq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0x2d,0xfe,0xca,0xbe,0xba]
        	psllq	0xbabecafe,%xmm5

// CHECK: psllq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0x2d,0x78,0x56,0x34,0x12]
        	psllq	0x12345678,%xmm5

// CHECK: psllq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf3,0xed]
        	psllq	%xmm5,%xmm5

// CHECK: psllq	$127, %mm3
// CHECK:  encoding: [0x0f,0x73,0xf3,0x7f]
        	psllq	$0x7f,%mm3

// CHECK: psllq	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x73,0xf5,0x7f]
        	psllq	$0x7f,%xmm5

// CHECK: psraw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe1,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psraw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psraw	69, %mm3
// CHECK:  encoding: [0x0f,0xe1,0x1d,0x45,0x00,0x00,0x00]
        	psraw	0x45,%mm3

// CHECK: psraw	32493, %mm3
// CHECK:  encoding: [0x0f,0xe1,0x1d,0xed,0x7e,0x00,0x00]
        	psraw	0x7eed,%mm3

// CHECK: psraw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe1,0x1d,0xfe,0xca,0xbe,0xba]
        	psraw	0xbabecafe,%mm3

// CHECK: psraw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe1,0x1d,0x78,0x56,0x34,0x12]
        	psraw	0x12345678,%mm3

// CHECK: psraw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe1,0xdb]
        	psraw	%mm3,%mm3

// CHECK: psraw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psraw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psraw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0x2d,0x45,0x00,0x00,0x00]
        	psraw	0x45,%xmm5

// CHECK: psraw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0x2d,0xed,0x7e,0x00,0x00]
        	psraw	0x7eed,%xmm5

// CHECK: psraw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0x2d,0xfe,0xca,0xbe,0xba]
        	psraw	0xbabecafe,%xmm5

// CHECK: psraw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0x2d,0x78,0x56,0x34,0x12]
        	psraw	0x12345678,%xmm5

// CHECK: psraw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe1,0xed]
        	psraw	%xmm5,%xmm5

// CHECK: psraw	$127, %mm3
// CHECK:  encoding: [0x0f,0x71,0xe3,0x7f]
        	psraw	$0x7f,%mm3

// CHECK: psraw	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x71,0xe5,0x7f]
        	psraw	$0x7f,%xmm5

// CHECK: psrad	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe2,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psrad	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psrad	69, %mm3
// CHECK:  encoding: [0x0f,0xe2,0x1d,0x45,0x00,0x00,0x00]
        	psrad	0x45,%mm3

// CHECK: psrad	32493, %mm3
// CHECK:  encoding: [0x0f,0xe2,0x1d,0xed,0x7e,0x00,0x00]
        	psrad	0x7eed,%mm3

// CHECK: psrad	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe2,0x1d,0xfe,0xca,0xbe,0xba]
        	psrad	0xbabecafe,%mm3

// CHECK: psrad	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe2,0x1d,0x78,0x56,0x34,0x12]
        	psrad	0x12345678,%mm3

// CHECK: psrad	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe2,0xdb]
        	psrad	%mm3,%mm3

// CHECK: psrad	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psrad	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psrad	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0x2d,0x45,0x00,0x00,0x00]
        	psrad	0x45,%xmm5

// CHECK: psrad	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0x2d,0xed,0x7e,0x00,0x00]
        	psrad	0x7eed,%xmm5

// CHECK: psrad	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0x2d,0xfe,0xca,0xbe,0xba]
        	psrad	0xbabecafe,%xmm5

// CHECK: psrad	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0x2d,0x78,0x56,0x34,0x12]
        	psrad	0x12345678,%xmm5

// CHECK: psrad	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe2,0xed]
        	psrad	%xmm5,%xmm5

// CHECK: psrad	$127, %mm3
// CHECK:  encoding: [0x0f,0x72,0xe3,0x7f]
        	psrad	$0x7f,%mm3

// CHECK: psrad	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x72,0xe5,0x7f]
        	psrad	$0x7f,%xmm5

// CHECK: psrlw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd1,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psrlw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psrlw	69, %mm3
// CHECK:  encoding: [0x0f,0xd1,0x1d,0x45,0x00,0x00,0x00]
        	psrlw	0x45,%mm3

// CHECK: psrlw	32493, %mm3
// CHECK:  encoding: [0x0f,0xd1,0x1d,0xed,0x7e,0x00,0x00]
        	psrlw	0x7eed,%mm3

// CHECK: psrlw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd1,0x1d,0xfe,0xca,0xbe,0xba]
        	psrlw	0xbabecafe,%mm3

// CHECK: psrlw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd1,0x1d,0x78,0x56,0x34,0x12]
        	psrlw	0x12345678,%mm3

// CHECK: psrlw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd1,0xdb]
        	psrlw	%mm3,%mm3

// CHECK: psrlw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psrlw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psrlw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0x2d,0x45,0x00,0x00,0x00]
        	psrlw	0x45,%xmm5

// CHECK: psrlw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0x2d,0xed,0x7e,0x00,0x00]
        	psrlw	0x7eed,%xmm5

// CHECK: psrlw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0x2d,0xfe,0xca,0xbe,0xba]
        	psrlw	0xbabecafe,%xmm5

// CHECK: psrlw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0x2d,0x78,0x56,0x34,0x12]
        	psrlw	0x12345678,%xmm5

// CHECK: psrlw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd1,0xed]
        	psrlw	%xmm5,%xmm5

// CHECK: psrlw	$127, %mm3
// CHECK:  encoding: [0x0f,0x71,0xd3,0x7f]
        	psrlw	$0x7f,%mm3

// CHECK: psrlw	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x71,0xd5,0x7f]
        	psrlw	$0x7f,%xmm5

// CHECK: psrld	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd2,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psrld	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psrld	69, %mm3
// CHECK:  encoding: [0x0f,0xd2,0x1d,0x45,0x00,0x00,0x00]
        	psrld	0x45,%mm3

// CHECK: psrld	32493, %mm3
// CHECK:  encoding: [0x0f,0xd2,0x1d,0xed,0x7e,0x00,0x00]
        	psrld	0x7eed,%mm3

// CHECK: psrld	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd2,0x1d,0xfe,0xca,0xbe,0xba]
        	psrld	0xbabecafe,%mm3

// CHECK: psrld	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd2,0x1d,0x78,0x56,0x34,0x12]
        	psrld	0x12345678,%mm3

// CHECK: psrld	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd2,0xdb]
        	psrld	%mm3,%mm3

// CHECK: psrld	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psrld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psrld	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0x2d,0x45,0x00,0x00,0x00]
        	psrld	0x45,%xmm5

// CHECK: psrld	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0x2d,0xed,0x7e,0x00,0x00]
        	psrld	0x7eed,%xmm5

// CHECK: psrld	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0x2d,0xfe,0xca,0xbe,0xba]
        	psrld	0xbabecafe,%xmm5

// CHECK: psrld	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0x2d,0x78,0x56,0x34,0x12]
        	psrld	0x12345678,%xmm5

// CHECK: psrld	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd2,0xed]
        	psrld	%xmm5,%xmm5

// CHECK: psrld	$127, %mm3
// CHECK:  encoding: [0x0f,0x72,0xd3,0x7f]
        	psrld	$0x7f,%mm3

// CHECK: psrld	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x72,0xd5,0x7f]
        	psrld	$0x7f,%xmm5

// CHECK: psrlq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd3,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psrlq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psrlq	69, %mm3
// CHECK:  encoding: [0x0f,0xd3,0x1d,0x45,0x00,0x00,0x00]
        	psrlq	0x45,%mm3

// CHECK: psrlq	32493, %mm3
// CHECK:  encoding: [0x0f,0xd3,0x1d,0xed,0x7e,0x00,0x00]
        	psrlq	0x7eed,%mm3

// CHECK: psrlq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd3,0x1d,0xfe,0xca,0xbe,0xba]
        	psrlq	0xbabecafe,%mm3

// CHECK: psrlq	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd3,0x1d,0x78,0x56,0x34,0x12]
        	psrlq	0x12345678,%mm3

// CHECK: psrlq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd3,0xdb]
        	psrlq	%mm3,%mm3

// CHECK: psrlq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psrlq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psrlq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0x2d,0x45,0x00,0x00,0x00]
        	psrlq	0x45,%xmm5

// CHECK: psrlq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0x2d,0xed,0x7e,0x00,0x00]
        	psrlq	0x7eed,%xmm5

// CHECK: psrlq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0x2d,0xfe,0xca,0xbe,0xba]
        	psrlq	0xbabecafe,%xmm5

// CHECK: psrlq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0x2d,0x78,0x56,0x34,0x12]
        	psrlq	0x12345678,%xmm5

// CHECK: psrlq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd3,0xed]
        	psrlq	%xmm5,%xmm5

// CHECK: psrlq	$127, %mm3
// CHECK:  encoding: [0x0f,0x73,0xd3,0x7f]
        	psrlq	$0x7f,%mm3

// CHECK: psrlq	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x73,0xd5,0x7f]
        	psrlq	$0x7f,%xmm5

// CHECK: psubb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf8,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubb	69, %mm3
// CHECK:  encoding: [0x0f,0xf8,0x1d,0x45,0x00,0x00,0x00]
        	psubb	0x45,%mm3

// CHECK: psubb	32493, %mm3
// CHECK:  encoding: [0x0f,0xf8,0x1d,0xed,0x7e,0x00,0x00]
        	psubb	0x7eed,%mm3

// CHECK: psubb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf8,0x1d,0xfe,0xca,0xbe,0xba]
        	psubb	0xbabecafe,%mm3

// CHECK: psubb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf8,0x1d,0x78,0x56,0x34,0x12]
        	psubb	0x12345678,%mm3

// CHECK: psubb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf8,0xdb]
        	psubb	%mm3,%mm3

// CHECK: psubb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0x2d,0x45,0x00,0x00,0x00]
        	psubb	0x45,%xmm5

// CHECK: psubb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0x2d,0xed,0x7e,0x00,0x00]
        	psubb	0x7eed,%xmm5

// CHECK: psubb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0x2d,0xfe,0xca,0xbe,0xba]
        	psubb	0xbabecafe,%xmm5

// CHECK: psubb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0x2d,0x78,0x56,0x34,0x12]
        	psubb	0x12345678,%xmm5

// CHECK: psubb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf8,0xed]
        	psubb	%xmm5,%xmm5

// CHECK: psubw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf9,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubw	69, %mm3
// CHECK:  encoding: [0x0f,0xf9,0x1d,0x45,0x00,0x00,0x00]
        	psubw	0x45,%mm3

// CHECK: psubw	32493, %mm3
// CHECK:  encoding: [0x0f,0xf9,0x1d,0xed,0x7e,0x00,0x00]
        	psubw	0x7eed,%mm3

// CHECK: psubw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf9,0x1d,0xfe,0xca,0xbe,0xba]
        	psubw	0xbabecafe,%mm3

// CHECK: psubw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf9,0x1d,0x78,0x56,0x34,0x12]
        	psubw	0x12345678,%mm3

// CHECK: psubw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf9,0xdb]
        	psubw	%mm3,%mm3

// CHECK: psubw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0x2d,0x45,0x00,0x00,0x00]
        	psubw	0x45,%xmm5

// CHECK: psubw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0x2d,0xed,0x7e,0x00,0x00]
        	psubw	0x7eed,%xmm5

// CHECK: psubw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0x2d,0xfe,0xca,0xbe,0xba]
        	psubw	0xbabecafe,%xmm5

// CHECK: psubw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0x2d,0x78,0x56,0x34,0x12]
        	psubw	0x12345678,%xmm5

// CHECK: psubw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf9,0xed]
        	psubw	%xmm5,%xmm5

// CHECK: psubd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xfa,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubd	69, %mm3
// CHECK:  encoding: [0x0f,0xfa,0x1d,0x45,0x00,0x00,0x00]
        	psubd	0x45,%mm3

// CHECK: psubd	32493, %mm3
// CHECK:  encoding: [0x0f,0xfa,0x1d,0xed,0x7e,0x00,0x00]
        	psubd	0x7eed,%mm3

// CHECK: psubd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xfa,0x1d,0xfe,0xca,0xbe,0xba]
        	psubd	0xbabecafe,%mm3

// CHECK: psubd	305419896, %mm3
// CHECK:  encoding: [0x0f,0xfa,0x1d,0x78,0x56,0x34,0x12]
        	psubd	0x12345678,%mm3

// CHECK: psubd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xfa,0xdb]
        	psubd	%mm3,%mm3

// CHECK: psubd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0x2d,0x45,0x00,0x00,0x00]
        	psubd	0x45,%xmm5

// CHECK: psubd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0x2d,0xed,0x7e,0x00,0x00]
        	psubd	0x7eed,%xmm5

// CHECK: psubd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0x2d,0xfe,0xca,0xbe,0xba]
        	psubd	0xbabecafe,%xmm5

// CHECK: psubd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0x2d,0x78,0x56,0x34,0x12]
        	psubd	0x12345678,%xmm5

// CHECK: psubd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfa,0xed]
        	psubd	%xmm5,%xmm5

// CHECK: psubq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xfb,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubq	69, %mm3
// CHECK:  encoding: [0x0f,0xfb,0x1d,0x45,0x00,0x00,0x00]
        	psubq	0x45,%mm3

// CHECK: psubq	32493, %mm3
// CHECK:  encoding: [0x0f,0xfb,0x1d,0xed,0x7e,0x00,0x00]
        	psubq	0x7eed,%mm3

// CHECK: psubq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xfb,0x1d,0xfe,0xca,0xbe,0xba]
        	psubq	0xbabecafe,%mm3

// CHECK: psubq	305419896, %mm3
// CHECK:  encoding: [0x0f,0xfb,0x1d,0x78,0x56,0x34,0x12]
        	psubq	0x12345678,%mm3

// CHECK: psubq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xfb,0xdb]
        	psubq	%mm3,%mm3

// CHECK: psubq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0x2d,0x45,0x00,0x00,0x00]
        	psubq	0x45,%xmm5

// CHECK: psubq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0x2d,0xed,0x7e,0x00,0x00]
        	psubq	0x7eed,%xmm5

// CHECK: psubq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0x2d,0xfe,0xca,0xbe,0xba]
        	psubq	0xbabecafe,%xmm5

// CHECK: psubq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0x2d,0x78,0x56,0x34,0x12]
        	psubq	0x12345678,%xmm5

// CHECK: psubq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xfb,0xed]
        	psubq	%xmm5,%xmm5

// CHECK: psubsb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe8,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubsb	69, %mm3
// CHECK:  encoding: [0x0f,0xe8,0x1d,0x45,0x00,0x00,0x00]
        	psubsb	0x45,%mm3

// CHECK: psubsb	32493, %mm3
// CHECK:  encoding: [0x0f,0xe8,0x1d,0xed,0x7e,0x00,0x00]
        	psubsb	0x7eed,%mm3

// CHECK: psubsb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe8,0x1d,0xfe,0xca,0xbe,0xba]
        	psubsb	0xbabecafe,%mm3

// CHECK: psubsb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe8,0x1d,0x78,0x56,0x34,0x12]
        	psubsb	0x12345678,%mm3

// CHECK: psubsb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe8,0xdb]
        	psubsb	%mm3,%mm3

// CHECK: psubsb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubsb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0x2d,0x45,0x00,0x00,0x00]
        	psubsb	0x45,%xmm5

// CHECK: psubsb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0x2d,0xed,0x7e,0x00,0x00]
        	psubsb	0x7eed,%xmm5

// CHECK: psubsb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0x2d,0xfe,0xca,0xbe,0xba]
        	psubsb	0xbabecafe,%xmm5

// CHECK: psubsb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0x2d,0x78,0x56,0x34,0x12]
        	psubsb	0x12345678,%xmm5

// CHECK: psubsb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe8,0xed]
        	psubsb	%xmm5,%xmm5

// CHECK: psubsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe9,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubsw	69, %mm3
// CHECK:  encoding: [0x0f,0xe9,0x1d,0x45,0x00,0x00,0x00]
        	psubsw	0x45,%mm3

// CHECK: psubsw	32493, %mm3
// CHECK:  encoding: [0x0f,0xe9,0x1d,0xed,0x7e,0x00,0x00]
        	psubsw	0x7eed,%mm3

// CHECK: psubsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe9,0x1d,0xfe,0xca,0xbe,0xba]
        	psubsw	0xbabecafe,%mm3

// CHECK: psubsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe9,0x1d,0x78,0x56,0x34,0x12]
        	psubsw	0x12345678,%mm3

// CHECK: psubsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe9,0xdb]
        	psubsw	%mm3,%mm3

// CHECK: psubsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0x2d,0x45,0x00,0x00,0x00]
        	psubsw	0x45,%xmm5

// CHECK: psubsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0x2d,0xed,0x7e,0x00,0x00]
        	psubsw	0x7eed,%xmm5

// CHECK: psubsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0x2d,0xfe,0xca,0xbe,0xba]
        	psubsw	0xbabecafe,%xmm5

// CHECK: psubsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0x2d,0x78,0x56,0x34,0x12]
        	psubsw	0x12345678,%xmm5

// CHECK: psubsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe9,0xed]
        	psubsw	%xmm5,%xmm5

// CHECK: psubusb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd8,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubusb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubusb	69, %mm3
// CHECK:  encoding: [0x0f,0xd8,0x1d,0x45,0x00,0x00,0x00]
        	psubusb	0x45,%mm3

// CHECK: psubusb	32493, %mm3
// CHECK:  encoding: [0x0f,0xd8,0x1d,0xed,0x7e,0x00,0x00]
        	psubusb	0x7eed,%mm3

// CHECK: psubusb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd8,0x1d,0xfe,0xca,0xbe,0xba]
        	psubusb	0xbabecafe,%mm3

// CHECK: psubusb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd8,0x1d,0x78,0x56,0x34,0x12]
        	psubusb	0x12345678,%mm3

// CHECK: psubusb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd8,0xdb]
        	psubusb	%mm3,%mm3

// CHECK: psubusb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubusb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubusb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0x2d,0x45,0x00,0x00,0x00]
        	psubusb	0x45,%xmm5

// CHECK: psubusb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0x2d,0xed,0x7e,0x00,0x00]
        	psubusb	0x7eed,%xmm5

// CHECK: psubusb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0x2d,0xfe,0xca,0xbe,0xba]
        	psubusb	0xbabecafe,%xmm5

// CHECK: psubusb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0x2d,0x78,0x56,0x34,0x12]
        	psubusb	0x12345678,%xmm5

// CHECK: psubusb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd8,0xed]
        	psubusb	%xmm5,%xmm5

// CHECK: psubusw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xd9,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psubusw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psubusw	69, %mm3
// CHECK:  encoding: [0x0f,0xd9,0x1d,0x45,0x00,0x00,0x00]
        	psubusw	0x45,%mm3

// CHECK: psubusw	32493, %mm3
// CHECK:  encoding: [0x0f,0xd9,0x1d,0xed,0x7e,0x00,0x00]
        	psubusw	0x7eed,%mm3

// CHECK: psubusw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xd9,0x1d,0xfe,0xca,0xbe,0xba]
        	psubusw	0xbabecafe,%mm3

// CHECK: psubusw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xd9,0x1d,0x78,0x56,0x34,0x12]
        	psubusw	0x12345678,%mm3

// CHECK: psubusw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xd9,0xdb]
        	psubusw	%mm3,%mm3

// CHECK: psubusw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psubusw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psubusw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0x2d,0x45,0x00,0x00,0x00]
        	psubusw	0x45,%xmm5

// CHECK: psubusw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0x2d,0xed,0x7e,0x00,0x00]
        	psubusw	0x7eed,%xmm5

// CHECK: psubusw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0x2d,0xfe,0xca,0xbe,0xba]
        	psubusw	0xbabecafe,%xmm5

// CHECK: psubusw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0x2d,0x78,0x56,0x34,0x12]
        	psubusw	0x12345678,%xmm5

// CHECK: psubusw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd9,0xed]
        	psubusw	%xmm5,%xmm5

// CHECK: punpckhbw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x68,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpckhbw	69, %mm3
// CHECK:  encoding: [0x0f,0x68,0x1d,0x45,0x00,0x00,0x00]
        	punpckhbw	0x45,%mm3

// CHECK: punpckhbw	32493, %mm3
// CHECK:  encoding: [0x0f,0x68,0x1d,0xed,0x7e,0x00,0x00]
        	punpckhbw	0x7eed,%mm3

// CHECK: punpckhbw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x68,0x1d,0xfe,0xca,0xbe,0xba]
        	punpckhbw	0xbabecafe,%mm3

// CHECK: punpckhbw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x68,0x1d,0x78,0x56,0x34,0x12]
        	punpckhbw	0x12345678,%mm3

// CHECK: punpckhbw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x68,0xdb]
        	punpckhbw	%mm3,%mm3

// CHECK: punpckhbw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpckhbw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0x2d,0x45,0x00,0x00,0x00]
        	punpckhbw	0x45,%xmm5

// CHECK: punpckhbw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0x2d,0xed,0x7e,0x00,0x00]
        	punpckhbw	0x7eed,%xmm5

// CHECK: punpckhbw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0x2d,0xfe,0xca,0xbe,0xba]
        	punpckhbw	0xbabecafe,%xmm5

// CHECK: punpckhbw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0x2d,0x78,0x56,0x34,0x12]
        	punpckhbw	0x12345678,%xmm5

// CHECK: punpckhbw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x68,0xed]
        	punpckhbw	%xmm5,%xmm5

// CHECK: punpckhwd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x69,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpckhwd	69, %mm3
// CHECK:  encoding: [0x0f,0x69,0x1d,0x45,0x00,0x00,0x00]
        	punpckhwd	0x45,%mm3

// CHECK: punpckhwd	32493, %mm3
// CHECK:  encoding: [0x0f,0x69,0x1d,0xed,0x7e,0x00,0x00]
        	punpckhwd	0x7eed,%mm3

// CHECK: punpckhwd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x69,0x1d,0xfe,0xca,0xbe,0xba]
        	punpckhwd	0xbabecafe,%mm3

// CHECK: punpckhwd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x69,0x1d,0x78,0x56,0x34,0x12]
        	punpckhwd	0x12345678,%mm3

// CHECK: punpckhwd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x69,0xdb]
        	punpckhwd	%mm3,%mm3

// CHECK: punpckhwd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpckhwd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0x2d,0x45,0x00,0x00,0x00]
        	punpckhwd	0x45,%xmm5

// CHECK: punpckhwd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0x2d,0xed,0x7e,0x00,0x00]
        	punpckhwd	0x7eed,%xmm5

// CHECK: punpckhwd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0x2d,0xfe,0xca,0xbe,0xba]
        	punpckhwd	0xbabecafe,%xmm5

// CHECK: punpckhwd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0x2d,0x78,0x56,0x34,0x12]
        	punpckhwd	0x12345678,%xmm5

// CHECK: punpckhwd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x69,0xed]
        	punpckhwd	%xmm5,%xmm5

// CHECK: punpckhdq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x6a,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhdq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpckhdq	69, %mm3
// CHECK:  encoding: [0x0f,0x6a,0x1d,0x45,0x00,0x00,0x00]
        	punpckhdq	0x45,%mm3

// CHECK: punpckhdq	32493, %mm3
// CHECK:  encoding: [0x0f,0x6a,0x1d,0xed,0x7e,0x00,0x00]
        	punpckhdq	0x7eed,%mm3

// CHECK: punpckhdq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x6a,0x1d,0xfe,0xca,0xbe,0xba]
        	punpckhdq	0xbabecafe,%mm3

// CHECK: punpckhdq	305419896, %mm3
// CHECK:  encoding: [0x0f,0x6a,0x1d,0x78,0x56,0x34,0x12]
        	punpckhdq	0x12345678,%mm3

// CHECK: punpckhdq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x6a,0xdb]
        	punpckhdq	%mm3,%mm3

// CHECK: punpckhdq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpckhdq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0x2d,0x45,0x00,0x00,0x00]
        	punpckhdq	0x45,%xmm5

// CHECK: punpckhdq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0x2d,0xed,0x7e,0x00,0x00]
        	punpckhdq	0x7eed,%xmm5

// CHECK: punpckhdq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0x2d,0xfe,0xca,0xbe,0xba]
        	punpckhdq	0xbabecafe,%xmm5

// CHECK: punpckhdq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0x2d,0x78,0x56,0x34,0x12]
        	punpckhdq	0x12345678,%xmm5

// CHECK: punpckhdq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6a,0xed]
        	punpckhdq	%xmm5,%xmm5

// CHECK: punpcklbw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x60,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpcklbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpcklbw	69, %mm3
// CHECK:  encoding: [0x0f,0x60,0x1d,0x45,0x00,0x00,0x00]
        	punpcklbw	0x45,%mm3

// CHECK: punpcklbw	32493, %mm3
// CHECK:  encoding: [0x0f,0x60,0x1d,0xed,0x7e,0x00,0x00]
        	punpcklbw	0x7eed,%mm3

// CHECK: punpcklbw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x60,0x1d,0xfe,0xca,0xbe,0xba]
        	punpcklbw	0xbabecafe,%mm3

// CHECK: punpcklbw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x60,0x1d,0x78,0x56,0x34,0x12]
        	punpcklbw	0x12345678,%mm3

// CHECK: punpcklbw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x60,0xdb]
        	punpcklbw	%mm3,%mm3

// CHECK: punpcklbw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpcklbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpcklbw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0x2d,0x45,0x00,0x00,0x00]
        	punpcklbw	0x45,%xmm5

// CHECK: punpcklbw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0x2d,0xed,0x7e,0x00,0x00]
        	punpcklbw	0x7eed,%xmm5

// CHECK: punpcklbw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0x2d,0xfe,0xca,0xbe,0xba]
        	punpcklbw	0xbabecafe,%xmm5

// CHECK: punpcklbw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0x2d,0x78,0x56,0x34,0x12]
        	punpcklbw	0x12345678,%xmm5

// CHECK: punpcklbw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x60,0xed]
        	punpcklbw	%xmm5,%xmm5

// CHECK: punpcklwd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x61,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpcklwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpcklwd	69, %mm3
// CHECK:  encoding: [0x0f,0x61,0x1d,0x45,0x00,0x00,0x00]
        	punpcklwd	0x45,%mm3

// CHECK: punpcklwd	32493, %mm3
// CHECK:  encoding: [0x0f,0x61,0x1d,0xed,0x7e,0x00,0x00]
        	punpcklwd	0x7eed,%mm3

// CHECK: punpcklwd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x61,0x1d,0xfe,0xca,0xbe,0xba]
        	punpcklwd	0xbabecafe,%mm3

// CHECK: punpcklwd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x61,0x1d,0x78,0x56,0x34,0x12]
        	punpcklwd	0x12345678,%mm3

// CHECK: punpcklwd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x61,0xdb]
        	punpcklwd	%mm3,%mm3

// CHECK: punpcklwd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpcklwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpcklwd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0x2d,0x45,0x00,0x00,0x00]
        	punpcklwd	0x45,%xmm5

// CHECK: punpcklwd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0x2d,0xed,0x7e,0x00,0x00]
        	punpcklwd	0x7eed,%xmm5

// CHECK: punpcklwd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0x2d,0xfe,0xca,0xbe,0xba]
        	punpcklwd	0xbabecafe,%xmm5

// CHECK: punpcklwd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0x2d,0x78,0x56,0x34,0x12]
        	punpcklwd	0x12345678,%xmm5

// CHECK: punpcklwd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x61,0xed]
        	punpcklwd	%xmm5,%xmm5

// CHECK: punpckldq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x62,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	punpckldq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: punpckldq	69, %mm3
// CHECK:  encoding: [0x0f,0x62,0x1d,0x45,0x00,0x00,0x00]
        	punpckldq	0x45,%mm3

// CHECK: punpckldq	32493, %mm3
// CHECK:  encoding: [0x0f,0x62,0x1d,0xed,0x7e,0x00,0x00]
        	punpckldq	0x7eed,%mm3

// CHECK: punpckldq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x62,0x1d,0xfe,0xca,0xbe,0xba]
        	punpckldq	0xbabecafe,%mm3

// CHECK: punpckldq	305419896, %mm3
// CHECK:  encoding: [0x0f,0x62,0x1d,0x78,0x56,0x34,0x12]
        	punpckldq	0x12345678,%mm3

// CHECK: punpckldq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x62,0xdb]
        	punpckldq	%mm3,%mm3

// CHECK: punpckldq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpckldq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpckldq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0x2d,0x45,0x00,0x00,0x00]
        	punpckldq	0x45,%xmm5

// CHECK: punpckldq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0x2d,0xed,0x7e,0x00,0x00]
        	punpckldq	0x7eed,%xmm5

// CHECK: punpckldq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0x2d,0xfe,0xca,0xbe,0xba]
        	punpckldq	0xbabecafe,%xmm5

// CHECK: punpckldq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0x2d,0x78,0x56,0x34,0x12]
        	punpckldq	0x12345678,%xmm5

// CHECK: punpckldq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x62,0xed]
        	punpckldq	%xmm5,%xmm5

// CHECK: pxor	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xef,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pxor	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pxor	69, %mm3
// CHECK:  encoding: [0x0f,0xef,0x1d,0x45,0x00,0x00,0x00]
        	pxor	0x45,%mm3

// CHECK: pxor	32493, %mm3
// CHECK:  encoding: [0x0f,0xef,0x1d,0xed,0x7e,0x00,0x00]
        	pxor	0x7eed,%mm3

// CHECK: pxor	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xef,0x1d,0xfe,0xca,0xbe,0xba]
        	pxor	0xbabecafe,%mm3

// CHECK: pxor	305419896, %mm3
// CHECK:  encoding: [0x0f,0xef,0x1d,0x78,0x56,0x34,0x12]
        	pxor	0x12345678,%mm3

// CHECK: pxor	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xef,0xdb]
        	pxor	%mm3,%mm3

// CHECK: pxor	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pxor	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pxor	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0x2d,0x45,0x00,0x00,0x00]
        	pxor	0x45,%xmm5

// CHECK: pxor	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0x2d,0xed,0x7e,0x00,0x00]
        	pxor	0x7eed,%xmm5

// CHECK: pxor	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0x2d,0xfe,0xca,0xbe,0xba]
        	pxor	0xbabecafe,%xmm5

// CHECK: pxor	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0x2d,0x78,0x56,0x34,0x12]
        	pxor	0x12345678,%xmm5

// CHECK: pxor	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xef,0xed]
        	pxor	%xmm5,%xmm5

// CHECK: addps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x58,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addps	69, %xmm5
// CHECK:  encoding: [0x0f,0x58,0x2d,0x45,0x00,0x00,0x00]
        	addps	0x45,%xmm5

// CHECK: addps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x58,0x2d,0xed,0x7e,0x00,0x00]
        	addps	0x7eed,%xmm5

// CHECK: addps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x58,0x2d,0xfe,0xca,0xbe,0xba]
        	addps	0xbabecafe,%xmm5

// CHECK: addps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x58,0x2d,0x78,0x56,0x34,0x12]
        	addps	0x12345678,%xmm5

// CHECK: addps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x58,0xed]
        	addps	%xmm5,%xmm5

// CHECK: addss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0x2d,0x45,0x00,0x00,0x00]
        	addss	0x45,%xmm5

// CHECK: addss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0x2d,0xed,0x7e,0x00,0x00]
        	addss	0x7eed,%xmm5

// CHECK: addss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0x2d,0xfe,0xca,0xbe,0xba]
        	addss	0xbabecafe,%xmm5

// CHECK: addss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0x2d,0x78,0x56,0x34,0x12]
        	addss	0x12345678,%xmm5

// CHECK: addss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x58,0xed]
        	addss	%xmm5,%xmm5

// CHECK: andnps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x55,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	andnps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: andnps	69, %xmm5
// CHECK:  encoding: [0x0f,0x55,0x2d,0x45,0x00,0x00,0x00]
        	andnps	0x45,%xmm5

// CHECK: andnps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x55,0x2d,0xed,0x7e,0x00,0x00]
        	andnps	0x7eed,%xmm5

// CHECK: andnps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x55,0x2d,0xfe,0xca,0xbe,0xba]
        	andnps	0xbabecafe,%xmm5

// CHECK: andnps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x55,0x2d,0x78,0x56,0x34,0x12]
        	andnps	0x12345678,%xmm5

// CHECK: andnps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x55,0xed]
        	andnps	%xmm5,%xmm5

// CHECK: andps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x54,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	andps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: andps	69, %xmm5
// CHECK:  encoding: [0x0f,0x54,0x2d,0x45,0x00,0x00,0x00]
        	andps	0x45,%xmm5

// CHECK: andps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x54,0x2d,0xed,0x7e,0x00,0x00]
        	andps	0x7eed,%xmm5

// CHECK: andps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x54,0x2d,0xfe,0xca,0xbe,0xba]
        	andps	0xbabecafe,%xmm5

// CHECK: andps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x54,0x2d,0x78,0x56,0x34,0x12]
        	andps	0x12345678,%xmm5

// CHECK: andps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x54,0xed]
        	andps	%xmm5,%xmm5

// CHECK: comiss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x2f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	comiss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: comiss	69, %xmm5
// CHECK:  encoding: [0x0f,0x2f,0x2d,0x45,0x00,0x00,0x00]
        	comiss	0x45,%xmm5

// CHECK: comiss	32493, %xmm5
// CHECK:  encoding: [0x0f,0x2f,0x2d,0xed,0x7e,0x00,0x00]
        	comiss	0x7eed,%xmm5

// CHECK: comiss	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x2f,0x2d,0xfe,0xca,0xbe,0xba]
        	comiss	0xbabecafe,%xmm5

// CHECK: comiss	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x2f,0x2d,0x78,0x56,0x34,0x12]
        	comiss	0x12345678,%xmm5

// CHECK: comiss	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x2f,0xed]
        	comiss	%xmm5,%xmm5

// CHECK: cvtpi2ps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x2a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtpi2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtpi2ps	69, %xmm5
// CHECK:  encoding: [0x0f,0x2a,0x2d,0x45,0x00,0x00,0x00]
        	cvtpi2ps	0x45,%xmm5

// CHECK: cvtpi2ps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x2a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtpi2ps	0x7eed,%xmm5

// CHECK: cvtpi2ps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x2a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtpi2ps	0xbabecafe,%xmm5

// CHECK: cvtpi2ps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x2a,0x2d,0x78,0x56,0x34,0x12]
        	cvtpi2ps	0x12345678,%xmm5

// CHECK: cvtpi2ps	%mm3, %xmm5
// CHECK:  encoding: [0x0f,0x2a,0xeb]
        	cvtpi2ps	%mm3,%xmm5

// CHECK: cvtps2pi	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x2d,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	cvtps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: cvtps2pi	69, %mm3
// CHECK:  encoding: [0x0f,0x2d,0x1d,0x45,0x00,0x00,0x00]
        	cvtps2pi	0x45,%mm3

// CHECK: cvtps2pi	32493, %mm3
// CHECK:  encoding: [0x0f,0x2d,0x1d,0xed,0x7e,0x00,0x00]
        	cvtps2pi	0x7eed,%mm3

// CHECK: cvtps2pi	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x2d,0x1d,0xfe,0xca,0xbe,0xba]
        	cvtps2pi	0xbabecafe,%mm3

// CHECK: cvtps2pi	305419896, %mm3
// CHECK:  encoding: [0x0f,0x2d,0x1d,0x78,0x56,0x34,0x12]
        	cvtps2pi	0x12345678,%mm3

// CHECK: cvtps2pi	%xmm5, %mm3
// CHECK:  encoding: [0x0f,0x2d,0xdd]
        	cvtps2pi	%xmm5,%mm3

// CHECK: cvtsi2ss	%ecx, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0xe9]
        	cvtsi2ss	%ecx,%xmm5

// CHECK: cvtsi2ss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtsi2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtsi2ss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0x2d,0x45,0x00,0x00,0x00]
        	cvtsi2ss	0x45,%xmm5

// CHECK: cvtsi2ss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtsi2ss	0x7eed,%xmm5

// CHECK: cvtsi2ss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtsi2ss	0xbabecafe,%xmm5

// CHECK: cvtsi2ss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x2a,0x2d,0x78,0x56,0x34,0x12]
        	cvtsi2ss	0x12345678,%xmm5

// CHECK: cvttps2pi	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x2c,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	cvttps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: cvttps2pi	69, %mm3
// CHECK:  encoding: [0x0f,0x2c,0x1d,0x45,0x00,0x00,0x00]
        	cvttps2pi	0x45,%mm3

// CHECK: cvttps2pi	32493, %mm3
// CHECK:  encoding: [0x0f,0x2c,0x1d,0xed,0x7e,0x00,0x00]
        	cvttps2pi	0x7eed,%mm3

// CHECK: cvttps2pi	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x2c,0x1d,0xfe,0xca,0xbe,0xba]
        	cvttps2pi	0xbabecafe,%mm3

// CHECK: cvttps2pi	305419896, %mm3
// CHECK:  encoding: [0x0f,0x2c,0x1d,0x78,0x56,0x34,0x12]
        	cvttps2pi	0x12345678,%mm3

// CHECK: cvttps2pi	%xmm5, %mm3
// CHECK:  encoding: [0x0f,0x2c,0xdd]
        	cvttps2pi	%xmm5,%mm3

// CHECK: cvttss2si	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	cvttss2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: cvttss2si	69, %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0x0d,0x45,0x00,0x00,0x00]
        	cvttss2si	0x45,%ecx

// CHECK: cvttss2si	32493, %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0x0d,0xed,0x7e,0x00,0x00]
        	cvttss2si	0x7eed,%ecx

// CHECK: cvttss2si	3133065982, %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0x0d,0xfe,0xca,0xbe,0xba]
        	cvttss2si	0xbabecafe,%ecx

// CHECK: cvttss2si	305419896, %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0x0d,0x78,0x56,0x34,0x12]
        	cvttss2si	0x12345678,%ecx

// CHECK: cvttss2si	%xmm5, %ecx
// CHECK:  encoding: [0xf3,0x0f,0x2c,0xcd]
        	cvttss2si	%xmm5,%ecx

// CHECK: divps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	divps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: divps	69, %xmm5
// CHECK:  encoding: [0x0f,0x5e,0x2d,0x45,0x00,0x00,0x00]
        	divps	0x45,%xmm5

// CHECK: divps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5e,0x2d,0xed,0x7e,0x00,0x00]
        	divps	0x7eed,%xmm5

// CHECK: divps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5e,0x2d,0xfe,0xca,0xbe,0xba]
        	divps	0xbabecafe,%xmm5

// CHECK: divps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5e,0x2d,0x78,0x56,0x34,0x12]
        	divps	0x12345678,%xmm5

// CHECK: divps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5e,0xed]
        	divps	%xmm5,%xmm5

// CHECK: divss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	divss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: divss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0x2d,0x45,0x00,0x00,0x00]
        	divss	0x45,%xmm5

// CHECK: divss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0x2d,0xed,0x7e,0x00,0x00]
        	divss	0x7eed,%xmm5

// CHECK: divss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0x2d,0xfe,0xca,0xbe,0xba]
        	divss	0xbabecafe,%xmm5

// CHECK: divss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0x2d,0x78,0x56,0x34,0x12]
        	divss	0x12345678,%xmm5

// CHECK: divss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5e,0xed]
        	divss	%xmm5,%xmm5

// CHECK: ldmxcsr	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xae,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	ldmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: ldmxcsr	32493
// CHECK:  encoding: [0x0f,0xae,0x15,0xed,0x7e,0x00,0x00]
        	ldmxcsr	0x7eed

// CHECK: ldmxcsr	3133065982
// CHECK:  encoding: [0x0f,0xae,0x15,0xfe,0xca,0xbe,0xba]
        	ldmxcsr	0xbabecafe

// CHECK: ldmxcsr	305419896
// CHECK:  encoding: [0x0f,0xae,0x15,0x78,0x56,0x34,0x12]
        	ldmxcsr	0x12345678

// CHECK: maskmovq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf7,0xdb]
        	maskmovq	%mm3,%mm3

// CHECK: maxps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	maxps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: maxps	69, %xmm5
// CHECK:  encoding: [0x0f,0x5f,0x2d,0x45,0x00,0x00,0x00]
        	maxps	0x45,%xmm5

// CHECK: maxps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5f,0x2d,0xed,0x7e,0x00,0x00]
        	maxps	0x7eed,%xmm5

// CHECK: maxps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5f,0x2d,0xfe,0xca,0xbe,0xba]
        	maxps	0xbabecafe,%xmm5

// CHECK: maxps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5f,0x2d,0x78,0x56,0x34,0x12]
        	maxps	0x12345678,%xmm5

// CHECK: maxps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5f,0xed]
        	maxps	%xmm5,%xmm5

// CHECK: maxss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	maxss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: maxss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0x2d,0x45,0x00,0x00,0x00]
        	maxss	0x45,%xmm5

// CHECK: maxss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0x2d,0xed,0x7e,0x00,0x00]
        	maxss	0x7eed,%xmm5

// CHECK: maxss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0x2d,0xfe,0xca,0xbe,0xba]
        	maxss	0xbabecafe,%xmm5

// CHECK: maxss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0x2d,0x78,0x56,0x34,0x12]
        	maxss	0x12345678,%xmm5

// CHECK: maxss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5f,0xed]
        	maxss	%xmm5,%xmm5

// CHECK: minps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	minps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: minps	69, %xmm5
// CHECK:  encoding: [0x0f,0x5d,0x2d,0x45,0x00,0x00,0x00]
        	minps	0x45,%xmm5

// CHECK: minps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5d,0x2d,0xed,0x7e,0x00,0x00]
        	minps	0x7eed,%xmm5

// CHECK: minps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5d,0x2d,0xfe,0xca,0xbe,0xba]
        	minps	0xbabecafe,%xmm5

// CHECK: minps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5d,0x2d,0x78,0x56,0x34,0x12]
        	minps	0x12345678,%xmm5

// CHECK: minps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5d,0xed]
        	minps	%xmm5,%xmm5

// CHECK: minss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	minss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: minss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0x2d,0x45,0x00,0x00,0x00]
        	minss	0x45,%xmm5

// CHECK: minss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0x2d,0xed,0x7e,0x00,0x00]
        	minss	0x7eed,%xmm5

// CHECK: minss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0x2d,0xfe,0xca,0xbe,0xba]
        	minss	0xbabecafe,%xmm5

// CHECK: minss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0x2d,0x78,0x56,0x34,0x12]
        	minss	0x12345678,%xmm5

// CHECK: minss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5d,0xed]
        	minss	%xmm5,%xmm5

// CHECK: movaps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x28,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movaps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movaps	69, %xmm5
// CHECK:  encoding: [0x0f,0x28,0x2d,0x45,0x00,0x00,0x00]
        	movaps	0x45,%xmm5

// CHECK: movaps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x28,0x2d,0xed,0x7e,0x00,0x00]
        	movaps	0x7eed,%xmm5

// CHECK: movaps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x28,0x2d,0xfe,0xca,0xbe,0xba]
        	movaps	0xbabecafe,%xmm5

// CHECK: movaps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x28,0x2d,0x78,0x56,0x34,0x12]
        	movaps	0x12345678,%xmm5

// CHECK: movaps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x28,0xed]
        	movaps	%xmm5,%xmm5

// CHECK: movaps	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x29,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movaps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movaps	%xmm5, 69
// CHECK:  encoding: [0x0f,0x29,0x2d,0x45,0x00,0x00,0x00]
        	movaps	%xmm5,0x45

// CHECK: movaps	%xmm5, 32493
// CHECK:  encoding: [0x0f,0x29,0x2d,0xed,0x7e,0x00,0x00]
        	movaps	%xmm5,0x7eed

// CHECK: movaps	%xmm5, 3133065982
// CHECK:  encoding: [0x0f,0x29,0x2d,0xfe,0xca,0xbe,0xba]
        	movaps	%xmm5,0xbabecafe

// CHECK: movaps	%xmm5, 305419896
// CHECK:  encoding: [0x0f,0x29,0x2d,0x78,0x56,0x34,0x12]
        	movaps	%xmm5,0x12345678

// CHECK: movaps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x28,0xed]
        	movaps	%xmm5,%xmm5

// CHECK: movhlps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x12,0xed]
        	movhlps	%xmm5,%xmm5

// CHECK: movhps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x16,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movhps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movhps	69, %xmm5
// CHECK:  encoding: [0x0f,0x16,0x2d,0x45,0x00,0x00,0x00]
        	movhps	0x45,%xmm5

// CHECK: movhps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x16,0x2d,0xed,0x7e,0x00,0x00]
        	movhps	0x7eed,%xmm5

// CHECK: movhps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x16,0x2d,0xfe,0xca,0xbe,0xba]
        	movhps	0xbabecafe,%xmm5

// CHECK: movhps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x16,0x2d,0x78,0x56,0x34,0x12]
        	movhps	0x12345678,%xmm5

// CHECK: movhps	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x17,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movhps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movhps	%xmm5, 69
// CHECK:  encoding: [0x0f,0x17,0x2d,0x45,0x00,0x00,0x00]
        	movhps	%xmm5,0x45

// CHECK: movhps	%xmm5, 32493
// CHECK:  encoding: [0x0f,0x17,0x2d,0xed,0x7e,0x00,0x00]
        	movhps	%xmm5,0x7eed

// CHECK: movhps	%xmm5, 3133065982
// CHECK:  encoding: [0x0f,0x17,0x2d,0xfe,0xca,0xbe,0xba]
        	movhps	%xmm5,0xbabecafe

// CHECK: movhps	%xmm5, 305419896
// CHECK:  encoding: [0x0f,0x17,0x2d,0x78,0x56,0x34,0x12]
        	movhps	%xmm5,0x12345678

// CHECK: movlhps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x16,0xed]
        	movlhps	%xmm5,%xmm5

// CHECK: movlps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x12,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movlps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movlps	69, %xmm5
// CHECK:  encoding: [0x0f,0x12,0x2d,0x45,0x00,0x00,0x00]
        	movlps	0x45,%xmm5

// CHECK: movlps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x12,0x2d,0xed,0x7e,0x00,0x00]
        	movlps	0x7eed,%xmm5

// CHECK: movlps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x12,0x2d,0xfe,0xca,0xbe,0xba]
        	movlps	0xbabecafe,%xmm5

// CHECK: movlps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x12,0x2d,0x78,0x56,0x34,0x12]
        	movlps	0x12345678,%xmm5

// CHECK: movlps	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x13,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movlps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movlps	%xmm5, 69
// CHECK:  encoding: [0x0f,0x13,0x2d,0x45,0x00,0x00,0x00]
        	movlps	%xmm5,0x45

// CHECK: movlps	%xmm5, 32493
// CHECK:  encoding: [0x0f,0x13,0x2d,0xed,0x7e,0x00,0x00]
        	movlps	%xmm5,0x7eed

// CHECK: movlps	%xmm5, 3133065982
// CHECK:  encoding: [0x0f,0x13,0x2d,0xfe,0xca,0xbe,0xba]
        	movlps	%xmm5,0xbabecafe

// CHECK: movlps	%xmm5, 305419896
// CHECK:  encoding: [0x0f,0x13,0x2d,0x78,0x56,0x34,0x12]
        	movlps	%xmm5,0x12345678

// CHECK: movmskps	%xmm5, %ecx
// CHECK:  encoding: [0x0f,0x50,0xcd]
        	movmskps	%xmm5,%ecx

// CHECK: movntps	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x2b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movntps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movntps	%xmm5, 69
// CHECK:  encoding: [0x0f,0x2b,0x2d,0x45,0x00,0x00,0x00]
        	movntps	%xmm5,0x45

// CHECK: movntps	%xmm5, 32493
// CHECK:  encoding: [0x0f,0x2b,0x2d,0xed,0x7e,0x00,0x00]
        	movntps	%xmm5,0x7eed

// CHECK: movntps	%xmm5, 3133065982
// CHECK:  encoding: [0x0f,0x2b,0x2d,0xfe,0xca,0xbe,0xba]
        	movntps	%xmm5,0xbabecafe

// CHECK: movntps	%xmm5, 305419896
// CHECK:  encoding: [0x0f,0x2b,0x2d,0x78,0x56,0x34,0x12]
        	movntps	%xmm5,0x12345678

// CHECK: movntq	%mm3, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xe7,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	movntq	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movntq	%mm3, 69
// CHECK:  encoding: [0x0f,0xe7,0x1d,0x45,0x00,0x00,0x00]
        	movntq	%mm3,0x45

// CHECK: movntq	%mm3, 32493
// CHECK:  encoding: [0x0f,0xe7,0x1d,0xed,0x7e,0x00,0x00]
        	movntq	%mm3,0x7eed

// CHECK: movntq	%mm3, 3133065982
// CHECK:  encoding: [0x0f,0xe7,0x1d,0xfe,0xca,0xbe,0xba]
        	movntq	%mm3,0xbabecafe

// CHECK: movntq	%mm3, 305419896
// CHECK:  encoding: [0x0f,0xe7,0x1d,0x78,0x56,0x34,0x12]
        	movntq	%mm3,0x12345678

// CHECK: movntdq	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0xe7,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movntdq	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movntdq	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0xe7,0x2d,0x45,0x00,0x00,0x00]
        	movntdq	%xmm5,0x45

// CHECK: movntdq	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0xe7,0x2d,0xed,0x7e,0x00,0x00]
        	movntdq	%xmm5,0x7eed

// CHECK: movntdq	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0xe7,0x2d,0xfe,0xca,0xbe,0xba]
        	movntdq	%xmm5,0xbabecafe

// CHECK: movntdq	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0xe7,0x2d,0x78,0x56,0x34,0x12]
        	movntdq	%xmm5,0x12345678

// CHECK: movss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0x2d,0x45,0x00,0x00,0x00]
        	movss	0x45,%xmm5

// CHECK: movss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0x2d,0xed,0x7e,0x00,0x00]
        	movss	0x7eed,%xmm5

// CHECK: movss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0x2d,0xfe,0xca,0xbe,0xba]
        	movss	0xbabecafe,%xmm5

// CHECK: movss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0x2d,0x78,0x56,0x34,0x12]
        	movss	0x12345678,%xmm5

// CHECK: movss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0xed]
        	movss	%xmm5,%xmm5

// CHECK: movss	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf3,0x0f,0x11,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movss	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movss	%xmm5, 69
// CHECK:  encoding: [0xf3,0x0f,0x11,0x2d,0x45,0x00,0x00,0x00]
        	movss	%xmm5,0x45

// CHECK: movss	%xmm5, 32493
// CHECK:  encoding: [0xf3,0x0f,0x11,0x2d,0xed,0x7e,0x00,0x00]
        	movss	%xmm5,0x7eed

// CHECK: movss	%xmm5, 3133065982
// CHECK:  encoding: [0xf3,0x0f,0x11,0x2d,0xfe,0xca,0xbe,0xba]
        	movss	%xmm5,0xbabecafe

// CHECK: movss	%xmm5, 305419896
// CHECK:  encoding: [0xf3,0x0f,0x11,0x2d,0x78,0x56,0x34,0x12]
        	movss	%xmm5,0x12345678

// CHECK: movss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x10,0xed]
        	movss	%xmm5,%xmm5

// CHECK: movups	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x10,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movups	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movups	69, %xmm5
// CHECK:  encoding: [0x0f,0x10,0x2d,0x45,0x00,0x00,0x00]
        	movups	0x45,%xmm5

// CHECK: movups	32493, %xmm5
// CHECK:  encoding: [0x0f,0x10,0x2d,0xed,0x7e,0x00,0x00]
        	movups	0x7eed,%xmm5

// CHECK: movups	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x10,0x2d,0xfe,0xca,0xbe,0xba]
        	movups	0xbabecafe,%xmm5

// CHECK: movups	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x10,0x2d,0x78,0x56,0x34,0x12]
        	movups	0x12345678,%xmm5

// CHECK: movups	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x10,0xed]
        	movups	%xmm5,%xmm5

// CHECK: movups	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x11,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movups	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movups	%xmm5, 69
// CHECK:  encoding: [0x0f,0x11,0x2d,0x45,0x00,0x00,0x00]
        	movups	%xmm5,0x45

// CHECK: movups	%xmm5, 32493
// CHECK:  encoding: [0x0f,0x11,0x2d,0xed,0x7e,0x00,0x00]
        	movups	%xmm5,0x7eed

// CHECK: movups	%xmm5, 3133065982
// CHECK:  encoding: [0x0f,0x11,0x2d,0xfe,0xca,0xbe,0xba]
        	movups	%xmm5,0xbabecafe

// CHECK: movups	%xmm5, 305419896
// CHECK:  encoding: [0x0f,0x11,0x2d,0x78,0x56,0x34,0x12]
        	movups	%xmm5,0x12345678

// CHECK: movups	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x10,0xed]
        	movups	%xmm5,%xmm5

// CHECK: mulps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x59,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	mulps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: mulps	69, %xmm5
// CHECK:  encoding: [0x0f,0x59,0x2d,0x45,0x00,0x00,0x00]
        	mulps	0x45,%xmm5

// CHECK: mulps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x59,0x2d,0xed,0x7e,0x00,0x00]
        	mulps	0x7eed,%xmm5

// CHECK: mulps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x59,0x2d,0xfe,0xca,0xbe,0xba]
        	mulps	0xbabecafe,%xmm5

// CHECK: mulps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x59,0x2d,0x78,0x56,0x34,0x12]
        	mulps	0x12345678,%xmm5

// CHECK: mulps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x59,0xed]
        	mulps	%xmm5,%xmm5

// CHECK: mulss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	mulss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: mulss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0x2d,0x45,0x00,0x00,0x00]
        	mulss	0x45,%xmm5

// CHECK: mulss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0x2d,0xed,0x7e,0x00,0x00]
        	mulss	0x7eed,%xmm5

// CHECK: mulss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0x2d,0xfe,0xca,0xbe,0xba]
        	mulss	0xbabecafe,%xmm5

// CHECK: mulss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0x2d,0x78,0x56,0x34,0x12]
        	mulss	0x12345678,%xmm5

// CHECK: mulss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x59,0xed]
        	mulss	%xmm5,%xmm5

// CHECK: orps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x56,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	orps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: orps	69, %xmm5
// CHECK:  encoding: [0x0f,0x56,0x2d,0x45,0x00,0x00,0x00]
        	orps	0x45,%xmm5

// CHECK: orps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x56,0x2d,0xed,0x7e,0x00,0x00]
        	orps	0x7eed,%xmm5

// CHECK: orps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x56,0x2d,0xfe,0xca,0xbe,0xba]
        	orps	0xbabecafe,%xmm5

// CHECK: orps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x56,0x2d,0x78,0x56,0x34,0x12]
        	orps	0x12345678,%xmm5

// CHECK: orps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x56,0xed]
        	orps	%xmm5,%xmm5

// CHECK: pavgb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe0,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pavgb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pavgb	69, %mm3
// CHECK:  encoding: [0x0f,0xe0,0x1d,0x45,0x00,0x00,0x00]
        	pavgb	0x45,%mm3

// CHECK: pavgb	32493, %mm3
// CHECK:  encoding: [0x0f,0xe0,0x1d,0xed,0x7e,0x00,0x00]
        	pavgb	0x7eed,%mm3

// CHECK: pavgb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe0,0x1d,0xfe,0xca,0xbe,0xba]
        	pavgb	0xbabecafe,%mm3

// CHECK: pavgb	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe0,0x1d,0x78,0x56,0x34,0x12]
        	pavgb	0x12345678,%mm3

// CHECK: pavgb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe0,0xdb]
        	pavgb	%mm3,%mm3

// CHECK: pavgb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pavgb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pavgb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0x2d,0x45,0x00,0x00,0x00]
        	pavgb	0x45,%xmm5

// CHECK: pavgb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0x2d,0xed,0x7e,0x00,0x00]
        	pavgb	0x7eed,%xmm5

// CHECK: pavgb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0x2d,0xfe,0xca,0xbe,0xba]
        	pavgb	0xbabecafe,%xmm5

// CHECK: pavgb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0x2d,0x78,0x56,0x34,0x12]
        	pavgb	0x12345678,%xmm5

// CHECK: pavgb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe0,0xed]
        	pavgb	%xmm5,%xmm5

// CHECK: pavgw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe3,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pavgw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pavgw	69, %mm3
// CHECK:  encoding: [0x0f,0xe3,0x1d,0x45,0x00,0x00,0x00]
        	pavgw	0x45,%mm3

// CHECK: pavgw	32493, %mm3
// CHECK:  encoding: [0x0f,0xe3,0x1d,0xed,0x7e,0x00,0x00]
        	pavgw	0x7eed,%mm3

// CHECK: pavgw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe3,0x1d,0xfe,0xca,0xbe,0xba]
        	pavgw	0xbabecafe,%mm3

// CHECK: pavgw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe3,0x1d,0x78,0x56,0x34,0x12]
        	pavgw	0x12345678,%mm3

// CHECK: pavgw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe3,0xdb]
        	pavgw	%mm3,%mm3

// CHECK: pavgw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pavgw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pavgw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0x2d,0x45,0x00,0x00,0x00]
        	pavgw	0x45,%xmm5

// CHECK: pavgw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0x2d,0xed,0x7e,0x00,0x00]
        	pavgw	0x7eed,%xmm5

// CHECK: pavgw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0x2d,0xfe,0xca,0xbe,0xba]
        	pavgw	0xbabecafe,%xmm5

// CHECK: pavgw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0x2d,0x78,0x56,0x34,0x12]
        	pavgw	0x12345678,%xmm5

// CHECK: pavgw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe3,0xed]
        	pavgw	%xmm5,%xmm5

// CHECK: pmaxsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xee,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmaxsw	69, %mm3
// CHECK:  encoding: [0x0f,0xee,0x1d,0x45,0x00,0x00,0x00]
        	pmaxsw	0x45,%mm3

// CHECK: pmaxsw	32493, %mm3
// CHECK:  encoding: [0x0f,0xee,0x1d,0xed,0x7e,0x00,0x00]
        	pmaxsw	0x7eed,%mm3

// CHECK: pmaxsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xee,0x1d,0xfe,0xca,0xbe,0xba]
        	pmaxsw	0xbabecafe,%mm3

// CHECK: pmaxsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xee,0x1d,0x78,0x56,0x34,0x12]
        	pmaxsw	0x12345678,%mm3

// CHECK: pmaxsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xee,0xdb]
        	pmaxsw	%mm3,%mm3

// CHECK: pmaxsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0x2d,0x45,0x00,0x00,0x00]
        	pmaxsw	0x45,%xmm5

// CHECK: pmaxsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxsw	0x7eed,%xmm5

// CHECK: pmaxsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxsw	0xbabecafe,%xmm5

// CHECK: pmaxsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0x2d,0x78,0x56,0x34,0x12]
        	pmaxsw	0x12345678,%xmm5

// CHECK: pmaxsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xee,0xed]
        	pmaxsw	%xmm5,%xmm5

// CHECK: pmaxub	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xde,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxub	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmaxub	69, %mm3
// CHECK:  encoding: [0x0f,0xde,0x1d,0x45,0x00,0x00,0x00]
        	pmaxub	0x45,%mm3

// CHECK: pmaxub	32493, %mm3
// CHECK:  encoding: [0x0f,0xde,0x1d,0xed,0x7e,0x00,0x00]
        	pmaxub	0x7eed,%mm3

// CHECK: pmaxub	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xde,0x1d,0xfe,0xca,0xbe,0xba]
        	pmaxub	0xbabecafe,%mm3

// CHECK: pmaxub	305419896, %mm3
// CHECK:  encoding: [0x0f,0xde,0x1d,0x78,0x56,0x34,0x12]
        	pmaxub	0x12345678,%mm3

// CHECK: pmaxub	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xde,0xdb]
        	pmaxub	%mm3,%mm3

// CHECK: pmaxub	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxub	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxub	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0x2d,0x45,0x00,0x00,0x00]
        	pmaxub	0x45,%xmm5

// CHECK: pmaxub	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxub	0x7eed,%xmm5

// CHECK: pmaxub	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxub	0xbabecafe,%xmm5

// CHECK: pmaxub	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0x2d,0x78,0x56,0x34,0x12]
        	pmaxub	0x12345678,%xmm5

// CHECK: pmaxub	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xde,0xed]
        	pmaxub	%xmm5,%xmm5

// CHECK: pminsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xea,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pminsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pminsw	69, %mm3
// CHECK:  encoding: [0x0f,0xea,0x1d,0x45,0x00,0x00,0x00]
        	pminsw	0x45,%mm3

// CHECK: pminsw	32493, %mm3
// CHECK:  encoding: [0x0f,0xea,0x1d,0xed,0x7e,0x00,0x00]
        	pminsw	0x7eed,%mm3

// CHECK: pminsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xea,0x1d,0xfe,0xca,0xbe,0xba]
        	pminsw	0xbabecafe,%mm3

// CHECK: pminsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xea,0x1d,0x78,0x56,0x34,0x12]
        	pminsw	0x12345678,%mm3

// CHECK: pminsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xea,0xdb]
        	pminsw	%mm3,%mm3

// CHECK: pminsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0x2d,0x45,0x00,0x00,0x00]
        	pminsw	0x45,%xmm5

// CHECK: pminsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0x2d,0xed,0x7e,0x00,0x00]
        	pminsw	0x7eed,%xmm5

// CHECK: pminsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0x2d,0xfe,0xca,0xbe,0xba]
        	pminsw	0xbabecafe,%xmm5

// CHECK: pminsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0x2d,0x78,0x56,0x34,0x12]
        	pminsw	0x12345678,%xmm5

// CHECK: pminsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xea,0xed]
        	pminsw	%xmm5,%xmm5

// CHECK: pminub	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xda,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pminub	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pminub	69, %mm3
// CHECK:  encoding: [0x0f,0xda,0x1d,0x45,0x00,0x00,0x00]
        	pminub	0x45,%mm3

// CHECK: pminub	32493, %mm3
// CHECK:  encoding: [0x0f,0xda,0x1d,0xed,0x7e,0x00,0x00]
        	pminub	0x7eed,%mm3

// CHECK: pminub	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xda,0x1d,0xfe,0xca,0xbe,0xba]
        	pminub	0xbabecafe,%mm3

// CHECK: pminub	305419896, %mm3
// CHECK:  encoding: [0x0f,0xda,0x1d,0x78,0x56,0x34,0x12]
        	pminub	0x12345678,%mm3

// CHECK: pminub	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xda,0xdb]
        	pminub	%mm3,%mm3

// CHECK: pminub	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminub	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminub	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0x2d,0x45,0x00,0x00,0x00]
        	pminub	0x45,%xmm5

// CHECK: pminub	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0x2d,0xed,0x7e,0x00,0x00]
        	pminub	0x7eed,%xmm5

// CHECK: pminub	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0x2d,0xfe,0xca,0xbe,0xba]
        	pminub	0xbabecafe,%xmm5

// CHECK: pminub	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0x2d,0x78,0x56,0x34,0x12]
        	pminub	0x12345678,%xmm5

// CHECK: pminub	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xda,0xed]
        	pminub	%xmm5,%xmm5

// CHECK: pmovmskb	%mm3, %ecx
// CHECK:  encoding: [0x0f,0xd7,0xcb]
        	pmovmskb	%mm3,%ecx

// CHECK: pmovmskb	%xmm5, %ecx
// CHECK:  encoding: [0x66,0x0f,0xd7,0xcd]
        	pmovmskb	%xmm5,%ecx

// CHECK: pmulhuw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xe4,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhuw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmulhuw	69, %mm3
// CHECK:  encoding: [0x0f,0xe4,0x1d,0x45,0x00,0x00,0x00]
        	pmulhuw	0x45,%mm3

// CHECK: pmulhuw	32493, %mm3
// CHECK:  encoding: [0x0f,0xe4,0x1d,0xed,0x7e,0x00,0x00]
        	pmulhuw	0x7eed,%mm3

// CHECK: pmulhuw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xe4,0x1d,0xfe,0xca,0xbe,0xba]
        	pmulhuw	0xbabecafe,%mm3

// CHECK: pmulhuw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xe4,0x1d,0x78,0x56,0x34,0x12]
        	pmulhuw	0x12345678,%mm3

// CHECK: pmulhuw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xe4,0xdb]
        	pmulhuw	%mm3,%mm3

// CHECK: pmulhuw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmulhuw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0x2d,0x45,0x00,0x00,0x00]
        	pmulhuw	0x45,%xmm5

// CHECK: pmulhuw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0x2d,0xed,0x7e,0x00,0x00]
        	pmulhuw	0x7eed,%xmm5

// CHECK: pmulhuw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0x2d,0xfe,0xca,0xbe,0xba]
        	pmulhuw	0xbabecafe,%xmm5

// CHECK: pmulhuw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0x2d,0x78,0x56,0x34,0x12]
        	pmulhuw	0x12345678,%xmm5

// CHECK: pmulhuw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xe4,0xed]
        	pmulhuw	%xmm5,%xmm5

// CHECK: prefetchnta	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x18,0x84,0xcb,0xef,0xbe,0xad,0xde]
        	prefetchnta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: prefetchnta	32493
// CHECK:  encoding: [0x0f,0x18,0x05,0xed,0x7e,0x00,0x00]
        	prefetchnta	0x7eed

// CHECK: prefetchnta	3133065982
// CHECK:  encoding: [0x0f,0x18,0x05,0xfe,0xca,0xbe,0xba]
        	prefetchnta	0xbabecafe

// CHECK: prefetchnta	305419896
// CHECK:  encoding: [0x0f,0x18,0x05,0x78,0x56,0x34,0x12]
        	prefetchnta	0x12345678

// CHECK: prefetcht0	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x18,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	prefetcht0	0xdeadbeef(%ebx,%ecx,8)

// CHECK: prefetcht0	32493
// CHECK:  encoding: [0x0f,0x18,0x0d,0xed,0x7e,0x00,0x00]
        	prefetcht0	0x7eed

// CHECK: prefetcht0	3133065982
// CHECK:  encoding: [0x0f,0x18,0x0d,0xfe,0xca,0xbe,0xba]
        	prefetcht0	0xbabecafe

// CHECK: prefetcht0	305419896
// CHECK:  encoding: [0x0f,0x18,0x0d,0x78,0x56,0x34,0x12]
        	prefetcht0	0x12345678

// CHECK: prefetcht1	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x18,0x94,0xcb,0xef,0xbe,0xad,0xde]
        	prefetcht1	0xdeadbeef(%ebx,%ecx,8)

// CHECK: prefetcht1	32493
// CHECK:  encoding: [0x0f,0x18,0x15,0xed,0x7e,0x00,0x00]
        	prefetcht1	0x7eed

// CHECK: prefetcht1	3133065982
// CHECK:  encoding: [0x0f,0x18,0x15,0xfe,0xca,0xbe,0xba]
        	prefetcht1	0xbabecafe

// CHECK: prefetcht1	305419896
// CHECK:  encoding: [0x0f,0x18,0x15,0x78,0x56,0x34,0x12]
        	prefetcht1	0x12345678

// CHECK: prefetcht2	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x18,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	prefetcht2	0xdeadbeef(%ebx,%ecx,8)

// CHECK: prefetcht2	32493
// CHECK:  encoding: [0x0f,0x18,0x1d,0xed,0x7e,0x00,0x00]
        	prefetcht2	0x7eed

// CHECK: prefetcht2	3133065982
// CHECK:  encoding: [0x0f,0x18,0x1d,0xfe,0xca,0xbe,0xba]
        	prefetcht2	0xbabecafe

// CHECK: prefetcht2	305419896
// CHECK:  encoding: [0x0f,0x18,0x1d,0x78,0x56,0x34,0x12]
        	prefetcht2	0x12345678

// CHECK: psadbw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf6,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psadbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psadbw	69, %mm3
// CHECK:  encoding: [0x0f,0xf6,0x1d,0x45,0x00,0x00,0x00]
        	psadbw	0x45,%mm3

// CHECK: psadbw	32493, %mm3
// CHECK:  encoding: [0x0f,0xf6,0x1d,0xed,0x7e,0x00,0x00]
        	psadbw	0x7eed,%mm3

// CHECK: psadbw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf6,0x1d,0xfe,0xca,0xbe,0xba]
        	psadbw	0xbabecafe,%mm3

// CHECK: psadbw	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf6,0x1d,0x78,0x56,0x34,0x12]
        	psadbw	0x12345678,%mm3

// CHECK: psadbw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf6,0xdb]
        	psadbw	%mm3,%mm3

// CHECK: psadbw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psadbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psadbw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0x2d,0x45,0x00,0x00,0x00]
        	psadbw	0x45,%xmm5

// CHECK: psadbw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0x2d,0xed,0x7e,0x00,0x00]
        	psadbw	0x7eed,%xmm5

// CHECK: psadbw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0x2d,0xfe,0xca,0xbe,0xba]
        	psadbw	0xbabecafe,%xmm5

// CHECK: psadbw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0x2d,0x78,0x56,0x34,0x12]
        	psadbw	0x12345678,%xmm5

// CHECK: psadbw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf6,0xed]
        	psadbw	%xmm5,%xmm5

// CHECK: rcpps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x53,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	rcpps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: rcpps	69, %xmm5
// CHECK:  encoding: [0x0f,0x53,0x2d,0x45,0x00,0x00,0x00]
        	rcpps	0x45,%xmm5

// CHECK: rcpps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x53,0x2d,0xed,0x7e,0x00,0x00]
        	rcpps	0x7eed,%xmm5

// CHECK: rcpps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x53,0x2d,0xfe,0xca,0xbe,0xba]
        	rcpps	0xbabecafe,%xmm5

// CHECK: rcpps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x53,0x2d,0x78,0x56,0x34,0x12]
        	rcpps	0x12345678,%xmm5

// CHECK: rcpps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x53,0xed]
        	rcpps	%xmm5,%xmm5

// CHECK: rcpss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	rcpss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: rcpss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0x2d,0x45,0x00,0x00,0x00]
        	rcpss	0x45,%xmm5

// CHECK: rcpss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0x2d,0xed,0x7e,0x00,0x00]
        	rcpss	0x7eed,%xmm5

// CHECK: rcpss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0x2d,0xfe,0xca,0xbe,0xba]
        	rcpss	0xbabecafe,%xmm5

// CHECK: rcpss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0x2d,0x78,0x56,0x34,0x12]
        	rcpss	0x12345678,%xmm5

// CHECK: rcpss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x53,0xed]
        	rcpss	%xmm5,%xmm5

// CHECK: rsqrtps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x52,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	rsqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: rsqrtps	69, %xmm5
// CHECK:  encoding: [0x0f,0x52,0x2d,0x45,0x00,0x00,0x00]
        	rsqrtps	0x45,%xmm5

// CHECK: rsqrtps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x52,0x2d,0xed,0x7e,0x00,0x00]
        	rsqrtps	0x7eed,%xmm5

// CHECK: rsqrtps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x52,0x2d,0xfe,0xca,0xbe,0xba]
        	rsqrtps	0xbabecafe,%xmm5

// CHECK: rsqrtps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x52,0x2d,0x78,0x56,0x34,0x12]
        	rsqrtps	0x12345678,%xmm5

// CHECK: rsqrtps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x52,0xed]
        	rsqrtps	%xmm5,%xmm5

// CHECK: rsqrtss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	rsqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: rsqrtss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0x2d,0x45,0x00,0x00,0x00]
        	rsqrtss	0x45,%xmm5

// CHECK: rsqrtss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0x2d,0xed,0x7e,0x00,0x00]
        	rsqrtss	0x7eed,%xmm5

// CHECK: rsqrtss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0x2d,0xfe,0xca,0xbe,0xba]
        	rsqrtss	0xbabecafe,%xmm5

// CHECK: rsqrtss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0x2d,0x78,0x56,0x34,0x12]
        	rsqrtss	0x12345678,%xmm5

// CHECK: rsqrtss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x52,0xed]
        	rsqrtss	%xmm5,%xmm5

// CHECK: sqrtps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x51,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	sqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: sqrtps	69, %xmm5
// CHECK:  encoding: [0x0f,0x51,0x2d,0x45,0x00,0x00,0x00]
        	sqrtps	0x45,%xmm5

// CHECK: sqrtps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x51,0x2d,0xed,0x7e,0x00,0x00]
        	sqrtps	0x7eed,%xmm5

// CHECK: sqrtps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x51,0x2d,0xfe,0xca,0xbe,0xba]
        	sqrtps	0xbabecafe,%xmm5

// CHECK: sqrtps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x51,0x2d,0x78,0x56,0x34,0x12]
        	sqrtps	0x12345678,%xmm5

// CHECK: sqrtps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x51,0xed]
        	sqrtps	%xmm5,%xmm5

// CHECK: sqrtss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	sqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: sqrtss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0x2d,0x45,0x00,0x00,0x00]
        	sqrtss	0x45,%xmm5

// CHECK: sqrtss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0x2d,0xed,0x7e,0x00,0x00]
        	sqrtss	0x7eed,%xmm5

// CHECK: sqrtss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0x2d,0xfe,0xca,0xbe,0xba]
        	sqrtss	0xbabecafe,%xmm5

// CHECK: sqrtss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0x2d,0x78,0x56,0x34,0x12]
        	sqrtss	0x12345678,%xmm5

// CHECK: sqrtss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x51,0xed]
        	sqrtss	%xmm5,%xmm5

// CHECK: stmxcsr	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xae,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	stmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: stmxcsr	32493
// CHECK:  encoding: [0x0f,0xae,0x1d,0xed,0x7e,0x00,0x00]
        	stmxcsr	0x7eed

// CHECK: stmxcsr	3133065982
// CHECK:  encoding: [0x0f,0xae,0x1d,0xfe,0xca,0xbe,0xba]
        	stmxcsr	0xbabecafe

// CHECK: stmxcsr	305419896
// CHECK:  encoding: [0x0f,0xae,0x1d,0x78,0x56,0x34,0x12]
        	stmxcsr	0x12345678

// CHECK: subps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	subps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: subps	69, %xmm5
// CHECK:  encoding: [0x0f,0x5c,0x2d,0x45,0x00,0x00,0x00]
        	subps	0x45,%xmm5

// CHECK: subps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5c,0x2d,0xed,0x7e,0x00,0x00]
        	subps	0x7eed,%xmm5

// CHECK: subps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5c,0x2d,0xfe,0xca,0xbe,0xba]
        	subps	0xbabecafe,%xmm5

// CHECK: subps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5c,0x2d,0x78,0x56,0x34,0x12]
        	subps	0x12345678,%xmm5

// CHECK: subps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5c,0xed]
        	subps	%xmm5,%xmm5

// CHECK: subss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	subss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: subss	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0x2d,0x45,0x00,0x00,0x00]
        	subss	0x45,%xmm5

// CHECK: subss	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0x2d,0xed,0x7e,0x00,0x00]
        	subss	0x7eed,%xmm5

// CHECK: subss	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0x2d,0xfe,0xca,0xbe,0xba]
        	subss	0xbabecafe,%xmm5

// CHECK: subss	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0x2d,0x78,0x56,0x34,0x12]
        	subss	0x12345678,%xmm5

// CHECK: subss	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5c,0xed]
        	subss	%xmm5,%xmm5

// CHECK: ucomiss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x2e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	ucomiss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: ucomiss	69, %xmm5
// CHECK:  encoding: [0x0f,0x2e,0x2d,0x45,0x00,0x00,0x00]
        	ucomiss	0x45,%xmm5

// CHECK: ucomiss	32493, %xmm5
// CHECK:  encoding: [0x0f,0x2e,0x2d,0xed,0x7e,0x00,0x00]
        	ucomiss	0x7eed,%xmm5

// CHECK: ucomiss	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x2e,0x2d,0xfe,0xca,0xbe,0xba]
        	ucomiss	0xbabecafe,%xmm5

// CHECK: ucomiss	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x2e,0x2d,0x78,0x56,0x34,0x12]
        	ucomiss	0x12345678,%xmm5

// CHECK: ucomiss	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x2e,0xed]
        	ucomiss	%xmm5,%xmm5

// CHECK: unpckhps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x15,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	unpckhps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: unpckhps	69, %xmm5
// CHECK:  encoding: [0x0f,0x15,0x2d,0x45,0x00,0x00,0x00]
        	unpckhps	0x45,%xmm5

// CHECK: unpckhps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x15,0x2d,0xed,0x7e,0x00,0x00]
        	unpckhps	0x7eed,%xmm5

// CHECK: unpckhps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x15,0x2d,0xfe,0xca,0xbe,0xba]
        	unpckhps	0xbabecafe,%xmm5

// CHECK: unpckhps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x15,0x2d,0x78,0x56,0x34,0x12]
        	unpckhps	0x12345678,%xmm5

// CHECK: unpckhps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x15,0xed]
        	unpckhps	%xmm5,%xmm5

// CHECK: unpcklps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x14,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	unpcklps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: unpcklps	69, %xmm5
// CHECK:  encoding: [0x0f,0x14,0x2d,0x45,0x00,0x00,0x00]
        	unpcklps	0x45,%xmm5

// CHECK: unpcklps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x14,0x2d,0xed,0x7e,0x00,0x00]
        	unpcklps	0x7eed,%xmm5

// CHECK: unpcklps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x14,0x2d,0xfe,0xca,0xbe,0xba]
        	unpcklps	0xbabecafe,%xmm5

// CHECK: unpcklps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x14,0x2d,0x78,0x56,0x34,0x12]
        	unpcklps	0x12345678,%xmm5

// CHECK: unpcklps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x14,0xed]
        	unpcklps	%xmm5,%xmm5

// CHECK: xorps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x57,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	xorps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: xorps	69, %xmm5
// CHECK:  encoding: [0x0f,0x57,0x2d,0x45,0x00,0x00,0x00]
        	xorps	0x45,%xmm5

// CHECK: xorps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x57,0x2d,0xed,0x7e,0x00,0x00]
        	xorps	0x7eed,%xmm5

// CHECK: xorps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x57,0x2d,0xfe,0xca,0xbe,0xba]
        	xorps	0xbabecafe,%xmm5

// CHECK: xorps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x57,0x2d,0x78,0x56,0x34,0x12]
        	xorps	0x12345678,%xmm5

// CHECK: xorps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x57,0xed]
        	xorps	%xmm5,%xmm5

// CHECK: addpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0x2d,0x45,0x00,0x00,0x00]
        	addpd	0x45,%xmm5

// CHECK: addpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0x2d,0xed,0x7e,0x00,0x00]
        	addpd	0x7eed,%xmm5

// CHECK: addpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0x2d,0xfe,0xca,0xbe,0xba]
        	addpd	0xbabecafe,%xmm5

// CHECK: addpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0x2d,0x78,0x56,0x34,0x12]
        	addpd	0x12345678,%xmm5

// CHECK: addpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x58,0xed]
        	addpd	%xmm5,%xmm5

// CHECK: addsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0x2d,0x45,0x00,0x00,0x00]
        	addsd	0x45,%xmm5

// CHECK: addsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0x2d,0xed,0x7e,0x00,0x00]
        	addsd	0x7eed,%xmm5

// CHECK: addsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0x2d,0xfe,0xca,0xbe,0xba]
        	addsd	0xbabecafe,%xmm5

// CHECK: addsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0x2d,0x78,0x56,0x34,0x12]
        	addsd	0x12345678,%xmm5

// CHECK: addsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x58,0xed]
        	addsd	%xmm5,%xmm5

// CHECK: andnpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	andnpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: andnpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0x2d,0x45,0x00,0x00,0x00]
        	andnpd	0x45,%xmm5

// CHECK: andnpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0x2d,0xed,0x7e,0x00,0x00]
        	andnpd	0x7eed,%xmm5

// CHECK: andnpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0x2d,0xfe,0xca,0xbe,0xba]
        	andnpd	0xbabecafe,%xmm5

// CHECK: andnpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0x2d,0x78,0x56,0x34,0x12]
        	andnpd	0x12345678,%xmm5

// CHECK: andnpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x55,0xed]
        	andnpd	%xmm5,%xmm5

// CHECK: andpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	andpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: andpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0x2d,0x45,0x00,0x00,0x00]
        	andpd	0x45,%xmm5

// CHECK: andpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0x2d,0xed,0x7e,0x00,0x00]
        	andpd	0x7eed,%xmm5

// CHECK: andpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0x2d,0xfe,0xca,0xbe,0xba]
        	andpd	0xbabecafe,%xmm5

// CHECK: andpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0x2d,0x78,0x56,0x34,0x12]
        	andpd	0x12345678,%xmm5

// CHECK: andpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x54,0xed]
        	andpd	%xmm5,%xmm5

// CHECK: comisd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	comisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: comisd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0x2d,0x45,0x00,0x00,0x00]
        	comisd	0x45,%xmm5

// CHECK: comisd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0x2d,0xed,0x7e,0x00,0x00]
        	comisd	0x7eed,%xmm5

// CHECK: comisd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0x2d,0xfe,0xca,0xbe,0xba]
        	comisd	0xbabecafe,%xmm5

// CHECK: comisd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0x2d,0x78,0x56,0x34,0x12]
        	comisd	0x12345678,%xmm5

// CHECK: comisd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2f,0xed]
        	comisd	%xmm5,%xmm5

// CHECK: cvtpi2pd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtpi2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtpi2pd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0x2d,0x45,0x00,0x00,0x00]
        	cvtpi2pd	0x45,%xmm5

// CHECK: cvtpi2pd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtpi2pd	0x7eed,%xmm5

// CHECK: cvtpi2pd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtpi2pd	0xbabecafe,%xmm5

// CHECK: cvtpi2pd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0x2d,0x78,0x56,0x34,0x12]
        	cvtpi2pd	0x12345678,%xmm5

// CHECK: cvtpi2pd	%mm3, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2a,0xeb]
        	cvtpi2pd	%mm3,%xmm5

// CHECK: cvtsi2sd	%ecx, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0xe9]
        	cvtsi2sd	%ecx,%xmm5

// CHECK: cvtsi2sd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtsi2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtsi2sd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0x2d,0x45,0x00,0x00,0x00]
        	cvtsi2sd	0x45,%xmm5

// CHECK: cvtsi2sd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtsi2sd	0x7eed,%xmm5

// CHECK: cvtsi2sd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtsi2sd	0xbabecafe,%xmm5

// CHECK: cvtsi2sd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x2a,0x2d,0x78,0x56,0x34,0x12]
        	cvtsi2sd	0x12345678,%xmm5

// CHECK: divpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	divpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: divpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0x2d,0x45,0x00,0x00,0x00]
        	divpd	0x45,%xmm5

// CHECK: divpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0x2d,0xed,0x7e,0x00,0x00]
        	divpd	0x7eed,%xmm5

// CHECK: divpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0x2d,0xfe,0xca,0xbe,0xba]
        	divpd	0xbabecafe,%xmm5

// CHECK: divpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0x2d,0x78,0x56,0x34,0x12]
        	divpd	0x12345678,%xmm5

// CHECK: divpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5e,0xed]
        	divpd	%xmm5,%xmm5

// CHECK: divsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	divsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: divsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0x2d,0x45,0x00,0x00,0x00]
        	divsd	0x45,%xmm5

// CHECK: divsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0x2d,0xed,0x7e,0x00,0x00]
        	divsd	0x7eed,%xmm5

// CHECK: divsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0x2d,0xfe,0xca,0xbe,0xba]
        	divsd	0xbabecafe,%xmm5

// CHECK: divsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0x2d,0x78,0x56,0x34,0x12]
        	divsd	0x12345678,%xmm5

// CHECK: divsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5e,0xed]
        	divsd	%xmm5,%xmm5

// CHECK: maxpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	maxpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: maxpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0x2d,0x45,0x00,0x00,0x00]
        	maxpd	0x45,%xmm5

// CHECK: maxpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0x2d,0xed,0x7e,0x00,0x00]
        	maxpd	0x7eed,%xmm5

// CHECK: maxpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0x2d,0xfe,0xca,0xbe,0xba]
        	maxpd	0xbabecafe,%xmm5

// CHECK: maxpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0x2d,0x78,0x56,0x34,0x12]
        	maxpd	0x12345678,%xmm5

// CHECK: maxpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5f,0xed]
        	maxpd	%xmm5,%xmm5

// CHECK: maxsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	maxsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: maxsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0x2d,0x45,0x00,0x00,0x00]
        	maxsd	0x45,%xmm5

// CHECK: maxsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0x2d,0xed,0x7e,0x00,0x00]
        	maxsd	0x7eed,%xmm5

// CHECK: maxsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0x2d,0xfe,0xca,0xbe,0xba]
        	maxsd	0xbabecafe,%xmm5

// CHECK: maxsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0x2d,0x78,0x56,0x34,0x12]
        	maxsd	0x12345678,%xmm5

// CHECK: maxsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5f,0xed]
        	maxsd	%xmm5,%xmm5

// CHECK: minpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	minpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: minpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0x2d,0x45,0x00,0x00,0x00]
        	minpd	0x45,%xmm5

// CHECK: minpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0x2d,0xed,0x7e,0x00,0x00]
        	minpd	0x7eed,%xmm5

// CHECK: minpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0x2d,0xfe,0xca,0xbe,0xba]
        	minpd	0xbabecafe,%xmm5

// CHECK: minpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0x2d,0x78,0x56,0x34,0x12]
        	minpd	0x12345678,%xmm5

// CHECK: minpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5d,0xed]
        	minpd	%xmm5,%xmm5

// CHECK: minsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	minsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: minsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0x2d,0x45,0x00,0x00,0x00]
        	minsd	0x45,%xmm5

// CHECK: minsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0x2d,0xed,0x7e,0x00,0x00]
        	minsd	0x7eed,%xmm5

// CHECK: minsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0x2d,0xfe,0xca,0xbe,0xba]
        	minsd	0xbabecafe,%xmm5

// CHECK: minsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0x2d,0x78,0x56,0x34,0x12]
        	minsd	0x12345678,%xmm5

// CHECK: minsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5d,0xed]
        	minsd	%xmm5,%xmm5

// CHECK: movapd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movapd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movapd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0x2d,0x45,0x00,0x00,0x00]
        	movapd	0x45,%xmm5

// CHECK: movapd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0x2d,0xed,0x7e,0x00,0x00]
        	movapd	0x7eed,%xmm5

// CHECK: movapd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0x2d,0xfe,0xca,0xbe,0xba]
        	movapd	0xbabecafe,%xmm5

// CHECK: movapd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0x2d,0x78,0x56,0x34,0x12]
        	movapd	0x12345678,%xmm5

// CHECK: movapd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0xed]
        	movapd	%xmm5,%xmm5

// CHECK: movapd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x29,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movapd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movapd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x29,0x2d,0x45,0x00,0x00,0x00]
        	movapd	%xmm5,0x45

// CHECK: movapd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x29,0x2d,0xed,0x7e,0x00,0x00]
        	movapd	%xmm5,0x7eed

// CHECK: movapd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x29,0x2d,0xfe,0xca,0xbe,0xba]
        	movapd	%xmm5,0xbabecafe

// CHECK: movapd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x29,0x2d,0x78,0x56,0x34,0x12]
        	movapd	%xmm5,0x12345678

// CHECK: movapd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x28,0xed]
        	movapd	%xmm5,%xmm5

// CHECK: movhpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x16,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movhpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movhpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x16,0x2d,0x45,0x00,0x00,0x00]
        	movhpd	0x45,%xmm5

// CHECK: movhpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x16,0x2d,0xed,0x7e,0x00,0x00]
        	movhpd	0x7eed,%xmm5

// CHECK: movhpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x16,0x2d,0xfe,0xca,0xbe,0xba]
        	movhpd	0xbabecafe,%xmm5

// CHECK: movhpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x16,0x2d,0x78,0x56,0x34,0x12]
        	movhpd	0x12345678,%xmm5

// CHECK: movhpd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x17,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movhpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movhpd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x17,0x2d,0x45,0x00,0x00,0x00]
        	movhpd	%xmm5,0x45

// CHECK: movhpd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x17,0x2d,0xed,0x7e,0x00,0x00]
        	movhpd	%xmm5,0x7eed

// CHECK: movhpd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x17,0x2d,0xfe,0xca,0xbe,0xba]
        	movhpd	%xmm5,0xbabecafe

// CHECK: movhpd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x17,0x2d,0x78,0x56,0x34,0x12]
        	movhpd	%xmm5,0x12345678

// CHECK: movlpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x12,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movlpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movlpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x12,0x2d,0x45,0x00,0x00,0x00]
        	movlpd	0x45,%xmm5

// CHECK: movlpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x12,0x2d,0xed,0x7e,0x00,0x00]
        	movlpd	0x7eed,%xmm5

// CHECK: movlpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x12,0x2d,0xfe,0xca,0xbe,0xba]
        	movlpd	0xbabecafe,%xmm5

// CHECK: movlpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x12,0x2d,0x78,0x56,0x34,0x12]
        	movlpd	0x12345678,%xmm5

// CHECK: movlpd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x13,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movlpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movlpd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x13,0x2d,0x45,0x00,0x00,0x00]
        	movlpd	%xmm5,0x45

// CHECK: movlpd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x13,0x2d,0xed,0x7e,0x00,0x00]
        	movlpd	%xmm5,0x7eed

// CHECK: movlpd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x13,0x2d,0xfe,0xca,0xbe,0xba]
        	movlpd	%xmm5,0xbabecafe

// CHECK: movlpd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x13,0x2d,0x78,0x56,0x34,0x12]
        	movlpd	%xmm5,0x12345678

// CHECK: movmskpd	%xmm5, %ecx
// CHECK:  encoding: [0x66,0x0f,0x50,0xcd]
        	movmskpd	%xmm5,%ecx

// CHECK: movntpd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x2b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movntpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movntpd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x2b,0x2d,0x45,0x00,0x00,0x00]
        	movntpd	%xmm5,0x45

// CHECK: movntpd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x2b,0x2d,0xed,0x7e,0x00,0x00]
        	movntpd	%xmm5,0x7eed

// CHECK: movntpd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x2b,0x2d,0xfe,0xca,0xbe,0xba]
        	movntpd	%xmm5,0xbabecafe

// CHECK: movntpd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x2b,0x2d,0x78,0x56,0x34,0x12]
        	movntpd	%xmm5,0x12345678

// CHECK: movsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0x2d,0x45,0x00,0x00,0x00]
        	movsd	0x45,%xmm5

// CHECK: movsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0x2d,0xed,0x7e,0x00,0x00]
        	movsd	0x7eed,%xmm5

// CHECK: movsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0x2d,0xfe,0xca,0xbe,0xba]
        	movsd	0xbabecafe,%xmm5

// CHECK: movsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0x2d,0x78,0x56,0x34,0x12]
        	movsd	0x12345678,%xmm5

// CHECK: movsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0xed]
        	movsd	%xmm5,%xmm5

// CHECK: movsd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf2,0x0f,0x11,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movsd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movsd	%xmm5, 69
// CHECK:  encoding: [0xf2,0x0f,0x11,0x2d,0x45,0x00,0x00,0x00]
        	movsd	%xmm5,0x45

// CHECK: movsd	%xmm5, 32493
// CHECK:  encoding: [0xf2,0x0f,0x11,0x2d,0xed,0x7e,0x00,0x00]
        	movsd	%xmm5,0x7eed

// CHECK: movsd	%xmm5, 3133065982
// CHECK:  encoding: [0xf2,0x0f,0x11,0x2d,0xfe,0xca,0xbe,0xba]
        	movsd	%xmm5,0xbabecafe

// CHECK: movsd	%xmm5, 305419896
// CHECK:  encoding: [0xf2,0x0f,0x11,0x2d,0x78,0x56,0x34,0x12]
        	movsd	%xmm5,0x12345678

// CHECK: movsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x10,0xed]
        	movsd	%xmm5,%xmm5

// CHECK: movupd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movupd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movupd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0x2d,0x45,0x00,0x00,0x00]
        	movupd	0x45,%xmm5

// CHECK: movupd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0x2d,0xed,0x7e,0x00,0x00]
        	movupd	0x7eed,%xmm5

// CHECK: movupd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0x2d,0xfe,0xca,0xbe,0xba]
        	movupd	0xbabecafe,%xmm5

// CHECK: movupd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0x2d,0x78,0x56,0x34,0x12]
        	movupd	0x12345678,%xmm5

// CHECK: movupd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0xed]
        	movupd	%xmm5,%xmm5

// CHECK: movupd	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x11,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movupd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movupd	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x11,0x2d,0x45,0x00,0x00,0x00]
        	movupd	%xmm5,0x45

// CHECK: movupd	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x11,0x2d,0xed,0x7e,0x00,0x00]
        	movupd	%xmm5,0x7eed

// CHECK: movupd	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x11,0x2d,0xfe,0xca,0xbe,0xba]
        	movupd	%xmm5,0xbabecafe

// CHECK: movupd	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x11,0x2d,0x78,0x56,0x34,0x12]
        	movupd	%xmm5,0x12345678

// CHECK: movupd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x10,0xed]
        	movupd	%xmm5,%xmm5

// CHECK: mulpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	mulpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: mulpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0x2d,0x45,0x00,0x00,0x00]
        	mulpd	0x45,%xmm5

// CHECK: mulpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0x2d,0xed,0x7e,0x00,0x00]
        	mulpd	0x7eed,%xmm5

// CHECK: mulpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0x2d,0xfe,0xca,0xbe,0xba]
        	mulpd	0xbabecafe,%xmm5

// CHECK: mulpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0x2d,0x78,0x56,0x34,0x12]
        	mulpd	0x12345678,%xmm5

// CHECK: mulpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x59,0xed]
        	mulpd	%xmm5,%xmm5

// CHECK: mulsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	mulsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: mulsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0x2d,0x45,0x00,0x00,0x00]
        	mulsd	0x45,%xmm5

// CHECK: mulsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0x2d,0xed,0x7e,0x00,0x00]
        	mulsd	0x7eed,%xmm5

// CHECK: mulsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0x2d,0xfe,0xca,0xbe,0xba]
        	mulsd	0xbabecafe,%xmm5

// CHECK: mulsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0x2d,0x78,0x56,0x34,0x12]
        	mulsd	0x12345678,%xmm5

// CHECK: mulsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x59,0xed]
        	mulsd	%xmm5,%xmm5

// CHECK: orpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	orpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: orpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0x2d,0x45,0x00,0x00,0x00]
        	orpd	0x45,%xmm5

// CHECK: orpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0x2d,0xed,0x7e,0x00,0x00]
        	orpd	0x7eed,%xmm5

// CHECK: orpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0x2d,0xfe,0xca,0xbe,0xba]
        	orpd	0xbabecafe,%xmm5

// CHECK: orpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0x2d,0x78,0x56,0x34,0x12]
        	orpd	0x12345678,%xmm5

// CHECK: orpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x56,0xed]
        	orpd	%xmm5,%xmm5

// CHECK: sqrtpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	sqrtpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: sqrtpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0x2d,0x45,0x00,0x00,0x00]
        	sqrtpd	0x45,%xmm5

// CHECK: sqrtpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0x2d,0xed,0x7e,0x00,0x00]
        	sqrtpd	0x7eed,%xmm5

// CHECK: sqrtpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0x2d,0xfe,0xca,0xbe,0xba]
        	sqrtpd	0xbabecafe,%xmm5

// CHECK: sqrtpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0x2d,0x78,0x56,0x34,0x12]
        	sqrtpd	0x12345678,%xmm5

// CHECK: sqrtpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x51,0xed]
        	sqrtpd	%xmm5,%xmm5

// CHECK: sqrtsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	sqrtsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: sqrtsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0x2d,0x45,0x00,0x00,0x00]
        	sqrtsd	0x45,%xmm5

// CHECK: sqrtsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0x2d,0xed,0x7e,0x00,0x00]
        	sqrtsd	0x7eed,%xmm5

// CHECK: sqrtsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0x2d,0xfe,0xca,0xbe,0xba]
        	sqrtsd	0xbabecafe,%xmm5

// CHECK: sqrtsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0x2d,0x78,0x56,0x34,0x12]
        	sqrtsd	0x12345678,%xmm5

// CHECK: sqrtsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x51,0xed]
        	sqrtsd	%xmm5,%xmm5

// CHECK: subpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	subpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: subpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0x2d,0x45,0x00,0x00,0x00]
        	subpd	0x45,%xmm5

// CHECK: subpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0x2d,0xed,0x7e,0x00,0x00]
        	subpd	0x7eed,%xmm5

// CHECK: subpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0x2d,0xfe,0xca,0xbe,0xba]
        	subpd	0xbabecafe,%xmm5

// CHECK: subpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0x2d,0x78,0x56,0x34,0x12]
        	subpd	0x12345678,%xmm5

// CHECK: subpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5c,0xed]
        	subpd	%xmm5,%xmm5

// CHECK: subsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	subsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: subsd	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0x2d,0x45,0x00,0x00,0x00]
        	subsd	0x45,%xmm5

// CHECK: subsd	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0x2d,0xed,0x7e,0x00,0x00]
        	subsd	0x7eed,%xmm5

// CHECK: subsd	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0x2d,0xfe,0xca,0xbe,0xba]
        	subsd	0xbabecafe,%xmm5

// CHECK: subsd	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0x2d,0x78,0x56,0x34,0x12]
        	subsd	0x12345678,%xmm5

// CHECK: subsd	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5c,0xed]
        	subsd	%xmm5,%xmm5

// CHECK: ucomisd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	ucomisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: ucomisd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0x2d,0x45,0x00,0x00,0x00]
        	ucomisd	0x45,%xmm5

// CHECK: ucomisd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0x2d,0xed,0x7e,0x00,0x00]
        	ucomisd	0x7eed,%xmm5

// CHECK: ucomisd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0x2d,0xfe,0xca,0xbe,0xba]
        	ucomisd	0xbabecafe,%xmm5

// CHECK: ucomisd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0x2d,0x78,0x56,0x34,0x12]
        	ucomisd	0x12345678,%xmm5

// CHECK: ucomisd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x2e,0xed]
        	ucomisd	%xmm5,%xmm5

// CHECK: unpckhpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	unpckhpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: unpckhpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0x2d,0x45,0x00,0x00,0x00]
        	unpckhpd	0x45,%xmm5

// CHECK: unpckhpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0x2d,0xed,0x7e,0x00,0x00]
        	unpckhpd	0x7eed,%xmm5

// CHECK: unpckhpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0x2d,0xfe,0xca,0xbe,0xba]
        	unpckhpd	0xbabecafe,%xmm5

// CHECK: unpckhpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0x2d,0x78,0x56,0x34,0x12]
        	unpckhpd	0x12345678,%xmm5

// CHECK: unpckhpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x15,0xed]
        	unpckhpd	%xmm5,%xmm5

// CHECK: unpcklpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	unpcklpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: unpcklpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0x2d,0x45,0x00,0x00,0x00]
        	unpcklpd	0x45,%xmm5

// CHECK: unpcklpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0x2d,0xed,0x7e,0x00,0x00]
        	unpcklpd	0x7eed,%xmm5

// CHECK: unpcklpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0x2d,0xfe,0xca,0xbe,0xba]
        	unpcklpd	0xbabecafe,%xmm5

// CHECK: unpcklpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0x2d,0x78,0x56,0x34,0x12]
        	unpcklpd	0x12345678,%xmm5

// CHECK: unpcklpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x14,0xed]
        	unpcklpd	%xmm5,%xmm5

// CHECK: xorpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	xorpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: xorpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0x2d,0x45,0x00,0x00,0x00]
        	xorpd	0x45,%xmm5

// CHECK: xorpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0x2d,0xed,0x7e,0x00,0x00]
        	xorpd	0x7eed,%xmm5

// CHECK: xorpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0x2d,0xfe,0xca,0xbe,0xba]
        	xorpd	0xbabecafe,%xmm5

// CHECK: xorpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0x2d,0x78,0x56,0x34,0x12]
        	xorpd	0x12345678,%xmm5

// CHECK: xorpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x57,0xed]
        	xorpd	%xmm5,%xmm5

// CHECK: cvtdq2pd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtdq2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtdq2pd	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0x2d,0x45,0x00,0x00,0x00]
        	cvtdq2pd	0x45,%xmm5

// CHECK: cvtdq2pd	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0x2d,0xed,0x7e,0x00,0x00]
        	cvtdq2pd	0x7eed,%xmm5

// CHECK: cvtdq2pd	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtdq2pd	0xbabecafe,%xmm5

// CHECK: cvtdq2pd	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0x2d,0x78,0x56,0x34,0x12]
        	cvtdq2pd	0x12345678,%xmm5

// CHECK: cvtdq2pd	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xe6,0xed]
        	cvtdq2pd	%xmm5,%xmm5

// CHECK: cvtpd2dq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtpd2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtpd2dq	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0x2d,0x45,0x00,0x00,0x00]
        	cvtpd2dq	0x45,%xmm5

// CHECK: cvtpd2dq	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0x2d,0xed,0x7e,0x00,0x00]
        	cvtpd2dq	0x7eed,%xmm5

// CHECK: cvtpd2dq	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtpd2dq	0xbabecafe,%xmm5

// CHECK: cvtpd2dq	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0x2d,0x78,0x56,0x34,0x12]
        	cvtpd2dq	0x12345678,%xmm5

// CHECK: cvtpd2dq	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xe6,0xed]
        	cvtpd2dq	%xmm5,%xmm5

// CHECK: cvtdq2ps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtdq2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtdq2ps	69, %xmm5
// CHECK:  encoding: [0x0f,0x5b,0x2d,0x45,0x00,0x00,0x00]
        	cvtdq2ps	0x45,%xmm5

// CHECK: cvtdq2ps	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5b,0x2d,0xed,0x7e,0x00,0x00]
        	cvtdq2ps	0x7eed,%xmm5

// CHECK: cvtdq2ps	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5b,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtdq2ps	0xbabecafe,%xmm5

// CHECK: cvtdq2ps	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5b,0x2d,0x78,0x56,0x34,0x12]
        	cvtdq2ps	0x12345678,%xmm5

// CHECK: cvtdq2ps	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5b,0xed]
        	cvtdq2ps	%xmm5,%xmm5

// CHECK: cvtpd2pi	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	cvtpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: cvtpd2pi	69, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0x1d,0x45,0x00,0x00,0x00]
        	cvtpd2pi	0x45,%mm3

// CHECK: cvtpd2pi	32493, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0x1d,0xed,0x7e,0x00,0x00]
        	cvtpd2pi	0x7eed,%mm3

// CHECK: cvtpd2pi	3133065982, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0x1d,0xfe,0xca,0xbe,0xba]
        	cvtpd2pi	0xbabecafe,%mm3

// CHECK: cvtpd2pi	305419896, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0x1d,0x78,0x56,0x34,0x12]
        	cvtpd2pi	0x12345678,%mm3

// CHECK: cvtpd2pi	%xmm5, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2d,0xdd]
        	cvtpd2pi	%xmm5,%mm3

// CHECK: cvtpd2ps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtpd2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtpd2ps	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0x2d,0x45,0x00,0x00,0x00]
        	cvtpd2ps	0x45,%xmm5

// CHECK: cvtpd2ps	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtpd2ps	0x7eed,%xmm5

// CHECK: cvtpd2ps	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtpd2ps	0xbabecafe,%xmm5

// CHECK: cvtpd2ps	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0x2d,0x78,0x56,0x34,0x12]
        	cvtpd2ps	0x12345678,%xmm5

// CHECK: cvtpd2ps	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5a,0xed]
        	cvtpd2ps	%xmm5,%xmm5

// CHECK: cvtps2pd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x0f,0x5a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtps2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtps2pd	69, %xmm5
// CHECK:  encoding: [0x0f,0x5a,0x2d,0x45,0x00,0x00,0x00]
        	cvtps2pd	0x45,%xmm5

// CHECK: cvtps2pd	32493, %xmm5
// CHECK:  encoding: [0x0f,0x5a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtps2pd	0x7eed,%xmm5

// CHECK: cvtps2pd	3133065982, %xmm5
// CHECK:  encoding: [0x0f,0x5a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtps2pd	0xbabecafe,%xmm5

// CHECK: cvtps2pd	305419896, %xmm5
// CHECK:  encoding: [0x0f,0x5a,0x2d,0x78,0x56,0x34,0x12]
        	cvtps2pd	0x12345678,%xmm5

// CHECK: cvtps2pd	%xmm5, %xmm5
// CHECK:  encoding: [0x0f,0x5a,0xed]
        	cvtps2pd	%xmm5,%xmm5

// CHECK: cvtps2dq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtps2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtps2dq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0x2d,0x45,0x00,0x00,0x00]
        	cvtps2dq	0x45,%xmm5

// CHECK: cvtps2dq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0x2d,0xed,0x7e,0x00,0x00]
        	cvtps2dq	0x7eed,%xmm5

// CHECK: cvtps2dq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtps2dq	0xbabecafe,%xmm5

// CHECK: cvtps2dq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0x2d,0x78,0x56,0x34,0x12]
        	cvtps2dq	0x12345678,%xmm5

// CHECK: cvtps2dq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x5b,0xed]
        	cvtps2dq	%xmm5,%xmm5

// CHECK: cvtsd2ss	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtsd2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtsd2ss	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0x2d,0x45,0x00,0x00,0x00]
        	cvtsd2ss	0x45,%xmm5

// CHECK: cvtsd2ss	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtsd2ss	0x7eed,%xmm5

// CHECK: cvtsd2ss	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtsd2ss	0xbabecafe,%xmm5

// CHECK: cvtsd2ss	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0x2d,0x78,0x56,0x34,0x12]
        	cvtsd2ss	0x12345678,%xmm5

// CHECK: cvtsd2ss	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x5a,0xed]
        	cvtsd2ss	%xmm5,%xmm5

// CHECK: cvtss2sd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvtss2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvtss2sd	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0x2d,0x45,0x00,0x00,0x00]
        	cvtss2sd	0x45,%xmm5

// CHECK: cvtss2sd	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0x2d,0xed,0x7e,0x00,0x00]
        	cvtss2sd	0x7eed,%xmm5

// CHECK: cvtss2sd	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0x2d,0xfe,0xca,0xbe,0xba]
        	cvtss2sd	0xbabecafe,%xmm5

// CHECK: cvtss2sd	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0x2d,0x78,0x56,0x34,0x12]
        	cvtss2sd	0x12345678,%xmm5

// CHECK: cvtss2sd	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5a,0xed]
        	cvtss2sd	%xmm5,%xmm5

// CHECK: cvttpd2pi	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	cvttpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: cvttpd2pi	69, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0x1d,0x45,0x00,0x00,0x00]
        	cvttpd2pi	0x45,%mm3

// CHECK: cvttpd2pi	32493, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0x1d,0xed,0x7e,0x00,0x00]
        	cvttpd2pi	0x7eed,%mm3

// CHECK: cvttpd2pi	3133065982, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0x1d,0xfe,0xca,0xbe,0xba]
        	cvttpd2pi	0xbabecafe,%mm3

// CHECK: cvttpd2pi	305419896, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0x1d,0x78,0x56,0x34,0x12]
        	cvttpd2pi	0x12345678,%mm3

// CHECK: cvttpd2pi	%xmm5, %mm3
// CHECK:  encoding: [0x66,0x0f,0x2c,0xdd]
        	cvttpd2pi	%xmm5,%mm3

// CHECK: cvttsd2si	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	cvttsd2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: cvttsd2si	69, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0x0d,0x45,0x00,0x00,0x00]
        	cvttsd2si	0x45,%ecx

// CHECK: cvttsd2si	32493, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0x0d,0xed,0x7e,0x00,0x00]
        	cvttsd2si	0x7eed,%ecx

// CHECK: cvttsd2si	3133065982, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0x0d,0xfe,0xca,0xbe,0xba]
        	cvttsd2si	0xbabecafe,%ecx

// CHECK: cvttsd2si	305419896, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0x0d,0x78,0x56,0x34,0x12]
        	cvttsd2si	0x12345678,%ecx

// CHECK: cvttsd2si	%xmm5, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x2c,0xcd]
        	cvttsd2si	%xmm5,%ecx

// CHECK: cvttps2dq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	cvttps2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: cvttps2dq	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0x2d,0x45,0x00,0x00,0x00]
        	cvttps2dq	0x45,%xmm5

// CHECK: cvttps2dq	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0x2d,0xed,0x7e,0x00,0x00]
        	cvttps2dq	0x7eed,%xmm5

// CHECK: cvttps2dq	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0x2d,0xfe,0xca,0xbe,0xba]
        	cvttps2dq	0xbabecafe,%xmm5

// CHECK: cvttps2dq	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0x2d,0x78,0x56,0x34,0x12]
        	cvttps2dq	0x12345678,%xmm5

// CHECK: cvttps2dq	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x5b,0xed]
        	cvttps2dq	%xmm5,%xmm5

// CHECK: maskmovdqu	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf7,0xed]
        	maskmovdqu	%xmm5,%xmm5

// CHECK: movdqa	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movdqa	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movdqa	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0x2d,0x45,0x00,0x00,0x00]
        	movdqa	0x45,%xmm5

// CHECK: movdqa	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0x2d,0xed,0x7e,0x00,0x00]
        	movdqa	0x7eed,%xmm5

// CHECK: movdqa	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0x2d,0xfe,0xca,0xbe,0xba]
        	movdqa	0xbabecafe,%xmm5

// CHECK: movdqa	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0x2d,0x78,0x56,0x34,0x12]
        	movdqa	0x12345678,%xmm5

// CHECK: movdqa	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0xed]
        	movdqa	%xmm5,%xmm5

// CHECK: movdqa	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0x7f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movdqa	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movdqa	%xmm5, 69
// CHECK:  encoding: [0x66,0x0f,0x7f,0x2d,0x45,0x00,0x00,0x00]
        	movdqa	%xmm5,0x45

// CHECK: movdqa	%xmm5, 32493
// CHECK:  encoding: [0x66,0x0f,0x7f,0x2d,0xed,0x7e,0x00,0x00]
        	movdqa	%xmm5,0x7eed

// CHECK: movdqa	%xmm5, 3133065982
// CHECK:  encoding: [0x66,0x0f,0x7f,0x2d,0xfe,0xca,0xbe,0xba]
        	movdqa	%xmm5,0xbabecafe

// CHECK: movdqa	%xmm5, 305419896
// CHECK:  encoding: [0x66,0x0f,0x7f,0x2d,0x78,0x56,0x34,0x12]
        	movdqa	%xmm5,0x12345678

// CHECK: movdqa	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6f,0xed]
        	movdqa	%xmm5,%xmm5

// CHECK: movdqu	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x6f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movdqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movdqu	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x6f,0x2d,0x45,0x00,0x00,0x00]
        	movdqu	0x45,%xmm5

// CHECK: movdqu	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x6f,0x2d,0xed,0x7e,0x00,0x00]
        	movdqu	0x7eed,%xmm5

// CHECK: movdqu	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x6f,0x2d,0xfe,0xca,0xbe,0xba]
        	movdqu	0xbabecafe,%xmm5

// CHECK: movdqu	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x6f,0x2d,0x78,0x56,0x34,0x12]
        	movdqu	0x12345678,%xmm5

// CHECK: movdqu	%xmm5, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xf3,0x0f,0x7f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movdqu	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: movdqu	%xmm5, 69
// CHECK:  encoding: [0xf3,0x0f,0x7f,0x2d,0x45,0x00,0x00,0x00]
        	movdqu	%xmm5,0x45

// CHECK: movdqu	%xmm5, 32493
// CHECK:  encoding: [0xf3,0x0f,0x7f,0x2d,0xed,0x7e,0x00,0x00]
        	movdqu	%xmm5,0x7eed

// CHECK: movdqu	%xmm5, 3133065982
// CHECK:  encoding: [0xf3,0x0f,0x7f,0x2d,0xfe,0xca,0xbe,0xba]
        	movdqu	%xmm5,0xbabecafe

// CHECK: movdqu	%xmm5, 305419896
// CHECK:  encoding: [0xf3,0x0f,0x7f,0x2d,0x78,0x56,0x34,0x12]
        	movdqu	%xmm5,0x12345678

// CHECK: movdq2q	%xmm5, %mm3
// CHECK:  encoding: [0xf2,0x0f,0xd6,0xdd]
        	movdq2q	%xmm5,%mm3

// CHECK: movq2dq	%mm3, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0xd6,0xeb]
        	movq2dq	%mm3,%xmm5

// CHECK: pmuludq	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0xf4,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmuludq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmuludq	69, %mm3
// CHECK:  encoding: [0x0f,0xf4,0x1d,0x45,0x00,0x00,0x00]
        	pmuludq	0x45,%mm3

// CHECK: pmuludq	32493, %mm3
// CHECK:  encoding: [0x0f,0xf4,0x1d,0xed,0x7e,0x00,0x00]
        	pmuludq	0x7eed,%mm3

// CHECK: pmuludq	3133065982, %mm3
// CHECK:  encoding: [0x0f,0xf4,0x1d,0xfe,0xca,0xbe,0xba]
        	pmuludq	0xbabecafe,%mm3

// CHECK: pmuludq	305419896, %mm3
// CHECK:  encoding: [0x0f,0xf4,0x1d,0x78,0x56,0x34,0x12]
        	pmuludq	0x12345678,%mm3

// CHECK: pmuludq	%mm3, %mm3
// CHECK:  encoding: [0x0f,0xf4,0xdb]
        	pmuludq	%mm3,%mm3

// CHECK: pmuludq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmuludq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmuludq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0x2d,0x45,0x00,0x00,0x00]
        	pmuludq	0x45,%xmm5

// CHECK: pmuludq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0x2d,0xed,0x7e,0x00,0x00]
        	pmuludq	0x7eed,%xmm5

// CHECK: pmuludq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0x2d,0xfe,0xca,0xbe,0xba]
        	pmuludq	0xbabecafe,%xmm5

// CHECK: pmuludq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0x2d,0x78,0x56,0x34,0x12]
        	pmuludq	0x12345678,%xmm5

// CHECK: pmuludq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xf4,0xed]
        	pmuludq	%xmm5,%xmm5

// CHECK: pslldq	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x73,0xfd,0x7f]
        	pslldq	$0x7f,%xmm5

// CHECK: psrldq	$127, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x73,0xdd,0x7f]
        	psrldq	$0x7f,%xmm5

// CHECK: punpckhqdq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpckhqdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpckhqdq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0x2d,0x45,0x00,0x00,0x00]
        	punpckhqdq	0x45,%xmm5

// CHECK: punpckhqdq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0x2d,0xed,0x7e,0x00,0x00]
        	punpckhqdq	0x7eed,%xmm5

// CHECK: punpckhqdq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0x2d,0xfe,0xca,0xbe,0xba]
        	punpckhqdq	0xbabecafe,%xmm5

// CHECK: punpckhqdq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0x2d,0x78,0x56,0x34,0x12]
        	punpckhqdq	0x12345678,%xmm5

// CHECK: punpckhqdq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6d,0xed]
        	punpckhqdq	%xmm5,%xmm5

// CHECK: punpcklqdq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	punpcklqdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: punpcklqdq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0x2d,0x45,0x00,0x00,0x00]
        	punpcklqdq	0x45,%xmm5

// CHECK: punpcklqdq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0x2d,0xed,0x7e,0x00,0x00]
        	punpcklqdq	0x7eed,%xmm5

// CHECK: punpcklqdq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0x2d,0xfe,0xca,0xbe,0xba]
        	punpcklqdq	0xbabecafe,%xmm5

// CHECK: punpcklqdq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0x2d,0x78,0x56,0x34,0x12]
        	punpcklqdq	0x12345678,%xmm5

// CHECK: punpcklqdq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6c,0xed]
        	punpcklqdq	%xmm5,%xmm5

// CHECK: addsubpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addsubpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addsubpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0x2d,0x45,0x00,0x00,0x00]
        	addsubpd	0x45,%xmm5

// CHECK: addsubpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0x2d,0xed,0x7e,0x00,0x00]
        	addsubpd	0x7eed,%xmm5

// CHECK: addsubpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0x2d,0xfe,0xca,0xbe,0xba]
        	addsubpd	0xbabecafe,%xmm5

// CHECK: addsubpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0x2d,0x78,0x56,0x34,0x12]
        	addsubpd	0x12345678,%xmm5

// CHECK: addsubpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0xd0,0xed]
        	addsubpd	%xmm5,%xmm5

// CHECK: addsubps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	addsubps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: addsubps	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0x2d,0x45,0x00,0x00,0x00]
        	addsubps	0x45,%xmm5

// CHECK: addsubps	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0x2d,0xed,0x7e,0x00,0x00]
        	addsubps	0x7eed,%xmm5

// CHECK: addsubps	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0x2d,0xfe,0xca,0xbe,0xba]
        	addsubps	0xbabecafe,%xmm5

// CHECK: addsubps	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0x2d,0x78,0x56,0x34,0x12]
        	addsubps	0x12345678,%xmm5

// CHECK: addsubps	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xd0,0xed]
        	addsubps	%xmm5,%xmm5

// CHECK: fisttpl	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdb,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	fisttpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: fisttpl	3133065982
// CHECK:  encoding: [0xdb,0x0d,0xfe,0xca,0xbe,0xba]
        	fisttpl	0xbabecafe

// CHECK: fisttpl	305419896
// CHECK:  encoding: [0xdb,0x0d,0x78,0x56,0x34,0x12]
        	fisttpl	0x12345678

// CHECK: haddpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	haddpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: haddpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0x2d,0x45,0x00,0x00,0x00]
        	haddpd	0x45,%xmm5

// CHECK: haddpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0x2d,0xed,0x7e,0x00,0x00]
        	haddpd	0x7eed,%xmm5

// CHECK: haddpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0x2d,0xfe,0xca,0xbe,0xba]
        	haddpd	0xbabecafe,%xmm5

// CHECK: haddpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0x2d,0x78,0x56,0x34,0x12]
        	haddpd	0x12345678,%xmm5

// CHECK: haddpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7c,0xed]
        	haddpd	%xmm5,%xmm5

// CHECK: haddps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	haddps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: haddps	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0x2d,0x45,0x00,0x00,0x00]
        	haddps	0x45,%xmm5

// CHECK: haddps	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0x2d,0xed,0x7e,0x00,0x00]
        	haddps	0x7eed,%xmm5

// CHECK: haddps	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0x2d,0xfe,0xca,0xbe,0xba]
        	haddps	0xbabecafe,%xmm5

// CHECK: haddps	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0x2d,0x78,0x56,0x34,0x12]
        	haddps	0x12345678,%xmm5

// CHECK: haddps	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7c,0xed]
        	haddps	%xmm5,%xmm5

// CHECK: hsubpd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	hsubpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: hsubpd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0x2d,0x45,0x00,0x00,0x00]
        	hsubpd	0x45,%xmm5

// CHECK: hsubpd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0x2d,0xed,0x7e,0x00,0x00]
        	hsubpd	0x7eed,%xmm5

// CHECK: hsubpd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0x2d,0xfe,0xca,0xbe,0xba]
        	hsubpd	0xbabecafe,%xmm5

// CHECK: hsubpd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0x2d,0x78,0x56,0x34,0x12]
        	hsubpd	0x12345678,%xmm5

// CHECK: hsubpd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x7d,0xed]
        	hsubpd	%xmm5,%xmm5

// CHECK: hsubps	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	hsubps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: hsubps	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0x2d,0x45,0x00,0x00,0x00]
        	hsubps	0x45,%xmm5

// CHECK: hsubps	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0x2d,0xed,0x7e,0x00,0x00]
        	hsubps	0x7eed,%xmm5

// CHECK: hsubps	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0x2d,0xfe,0xca,0xbe,0xba]
        	hsubps	0xbabecafe,%xmm5

// CHECK: hsubps	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0x2d,0x78,0x56,0x34,0x12]
        	hsubps	0x12345678,%xmm5

// CHECK: hsubps	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x7d,0xed]
        	hsubps	%xmm5,%xmm5

// CHECK: lddqu	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xf0,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	lddqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: lddqu	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xf0,0x2d,0x45,0x00,0x00,0x00]
        	lddqu	0x45,%xmm5

// CHECK: lddqu	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xf0,0x2d,0xed,0x7e,0x00,0x00]
        	lddqu	0x7eed,%xmm5

// CHECK: lddqu	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xf0,0x2d,0xfe,0xca,0xbe,0xba]
        	lddqu	0xbabecafe,%xmm5

// CHECK: lddqu	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0xf0,0x2d,0x78,0x56,0x34,0x12]
        	lddqu	0x12345678,%xmm5

// CHECK: movddup	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movddup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movddup	69, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0x2d,0x45,0x00,0x00,0x00]
        	movddup	0x45,%xmm5

// CHECK: movddup	32493, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0x2d,0xed,0x7e,0x00,0x00]
        	movddup	0x7eed,%xmm5

// CHECK: movddup	3133065982, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0x2d,0xfe,0xca,0xbe,0xba]
        	movddup	0xbabecafe,%xmm5

// CHECK: movddup	305419896, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0x2d,0x78,0x56,0x34,0x12]
        	movddup	0x12345678,%xmm5

// CHECK: movddup	%xmm5, %xmm5
// CHECK:  encoding: [0xf2,0x0f,0x12,0xed]
        	movddup	%xmm5,%xmm5

// CHECK: movshdup	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movshdup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movshdup	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0x2d,0x45,0x00,0x00,0x00]
        	movshdup	0x45,%xmm5

// CHECK: movshdup	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0x2d,0xed,0x7e,0x00,0x00]
        	movshdup	0x7eed,%xmm5

// CHECK: movshdup	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0x2d,0xfe,0xca,0xbe,0xba]
        	movshdup	0xbabecafe,%xmm5

// CHECK: movshdup	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0x2d,0x78,0x56,0x34,0x12]
        	movshdup	0x12345678,%xmm5

// CHECK: movshdup	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x16,0xed]
        	movshdup	%xmm5,%xmm5

// CHECK: movsldup	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movsldup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movsldup	69, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0x2d,0x45,0x00,0x00,0x00]
        	movsldup	0x45,%xmm5

// CHECK: movsldup	32493, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0x2d,0xed,0x7e,0x00,0x00]
        	movsldup	0x7eed,%xmm5

// CHECK: movsldup	3133065982, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0x2d,0xfe,0xca,0xbe,0xba]
        	movsldup	0xbabecafe,%xmm5

// CHECK: movsldup	305419896, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0x2d,0x78,0x56,0x34,0x12]
        	movsldup	0x12345678,%xmm5

// CHECK: movsldup	%xmm5, %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x12,0xed]
        	movsldup	%xmm5,%xmm5

// CHECK: vmclear	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x66,0x0f,0xc7,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	vmclear	0xdeadbeef(%ebx,%ecx,8)

// CHECK: vmclear	32493
// CHECK:  encoding: [0x66,0x0f,0xc7,0x35,0xed,0x7e,0x00,0x00]
        	vmclear	0x7eed

// CHECK: vmclear	3133065982
// CHECK:  encoding: [0x66,0x0f,0xc7,0x35,0xfe,0xca,0xbe,0xba]
        	vmclear	0xbabecafe

// CHECK: vmclear	305419896
// CHECK:  encoding: [0x66,0x0f,0xc7,0x35,0x78,0x56,0x34,0x12]
        	vmclear	0x12345678

// CHECK: vmptrld	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xc7,0xb4,0xcb,0xef,0xbe,0xad,0xde]
        	vmptrld	0xdeadbeef(%ebx,%ecx,8)

// CHECK: vmptrld	32493
// CHECK:  encoding: [0x0f,0xc7,0x35,0xed,0x7e,0x00,0x00]
        	vmptrld	0x7eed

// CHECK: vmptrld	3133065982
// CHECK:  encoding: [0x0f,0xc7,0x35,0xfe,0xca,0xbe,0xba]
        	vmptrld	0xbabecafe

// CHECK: vmptrld	305419896
// CHECK:  encoding: [0x0f,0xc7,0x35,0x78,0x56,0x34,0x12]
        	vmptrld	0x12345678

// CHECK: vmptrst	3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0xc7,0xbc,0xcb,0xef,0xbe,0xad,0xde]
        	vmptrst	0xdeadbeef(%ebx,%ecx,8)

// CHECK: vmptrst	32493
// CHECK:  encoding: [0x0f,0xc7,0x3d,0xed,0x7e,0x00,0x00]
        	vmptrst	0x7eed

// CHECK: vmptrst	3133065982
// CHECK:  encoding: [0x0f,0xc7,0x3d,0xfe,0xca,0xbe,0xba]
        	vmptrst	0xbabecafe

// CHECK: vmptrst	305419896
// CHECK:  encoding: [0x0f,0xc7,0x3d,0x78,0x56,0x34,0x12]
        	vmptrst	0x12345678

// CHECK: phaddw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phaddw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phaddw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0x1d,0x45,0x00,0x00,0x00]
        	phaddw	0x45,%mm3

// CHECK: phaddw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0x1d,0xed,0x7e,0x00,0x00]
        	phaddw	0x7eed,%mm3

// CHECK: phaddw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0x1d,0xfe,0xca,0xbe,0xba]
        	phaddw	0xbabecafe,%mm3

// CHECK: phaddw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0x1d,0x78,0x56,0x34,0x12]
        	phaddw	0x12345678,%mm3

// CHECK: phaddw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x01,0xdb]
        	phaddw	%mm3,%mm3

// CHECK: phaddw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phaddw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phaddw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0x2d,0x45,0x00,0x00,0x00]
        	phaddw	0x45,%xmm5

// CHECK: phaddw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0x2d,0xed,0x7e,0x00,0x00]
        	phaddw	0x7eed,%xmm5

// CHECK: phaddw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0x2d,0xfe,0xca,0xbe,0xba]
        	phaddw	0xbabecafe,%xmm5

// CHECK: phaddw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0x2d,0x78,0x56,0x34,0x12]
        	phaddw	0x12345678,%xmm5

// CHECK: phaddw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x01,0xed]
        	phaddw	%xmm5,%xmm5

// CHECK: phaddd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phaddd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phaddd	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0x1d,0x45,0x00,0x00,0x00]
        	phaddd	0x45,%mm3

// CHECK: phaddd	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0x1d,0xed,0x7e,0x00,0x00]
        	phaddd	0x7eed,%mm3

// CHECK: phaddd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0x1d,0xfe,0xca,0xbe,0xba]
        	phaddd	0xbabecafe,%mm3

// CHECK: phaddd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0x1d,0x78,0x56,0x34,0x12]
        	phaddd	0x12345678,%mm3

// CHECK: phaddd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x02,0xdb]
        	phaddd	%mm3,%mm3

// CHECK: phaddd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phaddd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phaddd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0x2d,0x45,0x00,0x00,0x00]
        	phaddd	0x45,%xmm5

// CHECK: phaddd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0x2d,0xed,0x7e,0x00,0x00]
        	phaddd	0x7eed,%xmm5

// CHECK: phaddd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0x2d,0xfe,0xca,0xbe,0xba]
        	phaddd	0xbabecafe,%xmm5

// CHECK: phaddd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0x2d,0x78,0x56,0x34,0x12]
        	phaddd	0x12345678,%xmm5

// CHECK: phaddd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x02,0xed]
        	phaddd	%xmm5,%xmm5

// CHECK: phaddsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phaddsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phaddsw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0x1d,0x45,0x00,0x00,0x00]
        	phaddsw	0x45,%mm3

// CHECK: phaddsw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0x1d,0xed,0x7e,0x00,0x00]
        	phaddsw	0x7eed,%mm3

// CHECK: phaddsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0x1d,0xfe,0xca,0xbe,0xba]
        	phaddsw	0xbabecafe,%mm3

// CHECK: phaddsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0x1d,0x78,0x56,0x34,0x12]
        	phaddsw	0x12345678,%mm3

// CHECK: phaddsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x03,0xdb]
        	phaddsw	%mm3,%mm3

// CHECK: phaddsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phaddsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phaddsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0x2d,0x45,0x00,0x00,0x00]
        	phaddsw	0x45,%xmm5

// CHECK: phaddsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0x2d,0xed,0x7e,0x00,0x00]
        	phaddsw	0x7eed,%xmm5

// CHECK: phaddsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0x2d,0xfe,0xca,0xbe,0xba]
        	phaddsw	0xbabecafe,%xmm5

// CHECK: phaddsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0x2d,0x78,0x56,0x34,0x12]
        	phaddsw	0x12345678,%xmm5

// CHECK: phaddsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x03,0xed]
        	phaddsw	%xmm5,%xmm5

// CHECK: phsubw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phsubw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phsubw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0x1d,0x45,0x00,0x00,0x00]
        	phsubw	0x45,%mm3

// CHECK: phsubw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0x1d,0xed,0x7e,0x00,0x00]
        	phsubw	0x7eed,%mm3

// CHECK: phsubw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0x1d,0xfe,0xca,0xbe,0xba]
        	phsubw	0xbabecafe,%mm3

// CHECK: phsubw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0x1d,0x78,0x56,0x34,0x12]
        	phsubw	0x12345678,%mm3

// CHECK: phsubw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x05,0xdb]
        	phsubw	%mm3,%mm3

// CHECK: phsubw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phsubw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phsubw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0x2d,0x45,0x00,0x00,0x00]
        	phsubw	0x45,%xmm5

// CHECK: phsubw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0x2d,0xed,0x7e,0x00,0x00]
        	phsubw	0x7eed,%xmm5

// CHECK: phsubw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0x2d,0xfe,0xca,0xbe,0xba]
        	phsubw	0xbabecafe,%xmm5

// CHECK: phsubw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0x2d,0x78,0x56,0x34,0x12]
        	phsubw	0x12345678,%xmm5

// CHECK: phsubw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x05,0xed]
        	phsubw	%xmm5,%xmm5

// CHECK: phsubd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phsubd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phsubd	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0x1d,0x45,0x00,0x00,0x00]
        	phsubd	0x45,%mm3

// CHECK: phsubd	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0x1d,0xed,0x7e,0x00,0x00]
        	phsubd	0x7eed,%mm3

// CHECK: phsubd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0x1d,0xfe,0xca,0xbe,0xba]
        	phsubd	0xbabecafe,%mm3

// CHECK: phsubd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0x1d,0x78,0x56,0x34,0x12]
        	phsubd	0x12345678,%mm3

// CHECK: phsubd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x06,0xdb]
        	phsubd	%mm3,%mm3

// CHECK: phsubd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phsubd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phsubd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0x2d,0x45,0x00,0x00,0x00]
        	phsubd	0x45,%xmm5

// CHECK: phsubd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0x2d,0xed,0x7e,0x00,0x00]
        	phsubd	0x7eed,%xmm5

// CHECK: phsubd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0x2d,0xfe,0xca,0xbe,0xba]
        	phsubd	0xbabecafe,%xmm5

// CHECK: phsubd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0x2d,0x78,0x56,0x34,0x12]
        	phsubd	0x12345678,%xmm5

// CHECK: phsubd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x06,0xed]
        	phsubd	%xmm5,%xmm5

// CHECK: phsubsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	phsubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: phsubsw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0x1d,0x45,0x00,0x00,0x00]
        	phsubsw	0x45,%mm3

// CHECK: phsubsw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0x1d,0xed,0x7e,0x00,0x00]
        	phsubsw	0x7eed,%mm3

// CHECK: phsubsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0x1d,0xfe,0xca,0xbe,0xba]
        	phsubsw	0xbabecafe,%mm3

// CHECK: phsubsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0x1d,0x78,0x56,0x34,0x12]
        	phsubsw	0x12345678,%mm3

// CHECK: phsubsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x07,0xdb]
        	phsubsw	%mm3,%mm3

// CHECK: phsubsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phsubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phsubsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0x2d,0x45,0x00,0x00,0x00]
        	phsubsw	0x45,%xmm5

// CHECK: phsubsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0x2d,0xed,0x7e,0x00,0x00]
        	phsubsw	0x7eed,%xmm5

// CHECK: phsubsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0x2d,0xfe,0xca,0xbe,0xba]
        	phsubsw	0xbabecafe,%xmm5

// CHECK: phsubsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0x2d,0x78,0x56,0x34,0x12]
        	phsubsw	0x12345678,%xmm5

// CHECK: phsubsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x07,0xed]
        	phsubsw	%xmm5,%xmm5

// CHECK: pmaddubsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmaddubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmaddubsw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0x1d,0x45,0x00,0x00,0x00]
        	pmaddubsw	0x45,%mm3

// CHECK: pmaddubsw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0x1d,0xed,0x7e,0x00,0x00]
        	pmaddubsw	0x7eed,%mm3

// CHECK: pmaddubsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0x1d,0xfe,0xca,0xbe,0xba]
        	pmaddubsw	0xbabecafe,%mm3

// CHECK: pmaddubsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0x1d,0x78,0x56,0x34,0x12]
        	pmaddubsw	0x12345678,%mm3

// CHECK: pmaddubsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x04,0xdb]
        	pmaddubsw	%mm3,%mm3

// CHECK: pmaddubsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaddubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaddubsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0x2d,0x45,0x00,0x00,0x00]
        	pmaddubsw	0x45,%xmm5

// CHECK: pmaddubsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0x2d,0xed,0x7e,0x00,0x00]
        	pmaddubsw	0x7eed,%xmm5

// CHECK: pmaddubsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaddubsw	0xbabecafe,%xmm5

// CHECK: pmaddubsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0x2d,0x78,0x56,0x34,0x12]
        	pmaddubsw	0x12345678,%xmm5

// CHECK: pmaddubsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x04,0xed]
        	pmaddubsw	%xmm5,%xmm5

// CHECK: pmulhrsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhrsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pmulhrsw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0x1d,0x45,0x00,0x00,0x00]
        	pmulhrsw	0x45,%mm3

// CHECK: pmulhrsw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0x1d,0xed,0x7e,0x00,0x00]
        	pmulhrsw	0x7eed,%mm3

// CHECK: pmulhrsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0x1d,0xfe,0xca,0xbe,0xba]
        	pmulhrsw	0xbabecafe,%mm3

// CHECK: pmulhrsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0x1d,0x78,0x56,0x34,0x12]
        	pmulhrsw	0x12345678,%mm3

// CHECK: pmulhrsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0b,0xdb]
        	pmulhrsw	%mm3,%mm3

// CHECK: pmulhrsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmulhrsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmulhrsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0x2d,0x45,0x00,0x00,0x00]
        	pmulhrsw	0x45,%xmm5

// CHECK: pmulhrsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0x2d,0xed,0x7e,0x00,0x00]
        	pmulhrsw	0x7eed,%xmm5

// CHECK: pmulhrsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0x2d,0xfe,0xca,0xbe,0xba]
        	pmulhrsw	0xbabecafe,%xmm5

// CHECK: pmulhrsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0x2d,0x78,0x56,0x34,0x12]
        	pmulhrsw	0x12345678,%xmm5

// CHECK: pmulhrsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0b,0xed]
        	pmulhrsw	%xmm5,%xmm5

// CHECK: pshufb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pshufb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pshufb	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0x1d,0x45,0x00,0x00,0x00]
        	pshufb	0x45,%mm3

// CHECK: pshufb	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0x1d,0xed,0x7e,0x00,0x00]
        	pshufb	0x7eed,%mm3

// CHECK: pshufb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0x1d,0xfe,0xca,0xbe,0xba]
        	pshufb	0xbabecafe,%mm3

// CHECK: pshufb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0x1d,0x78,0x56,0x34,0x12]
        	pshufb	0x12345678,%mm3

// CHECK: pshufb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x00,0xdb]
        	pshufb	%mm3,%mm3

// CHECK: pshufb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pshufb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pshufb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0x2d,0x45,0x00,0x00,0x00]
        	pshufb	0x45,%xmm5

// CHECK: pshufb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0x2d,0xed,0x7e,0x00,0x00]
        	pshufb	0x7eed,%xmm5

// CHECK: pshufb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0x2d,0xfe,0xca,0xbe,0xba]
        	pshufb	0xbabecafe,%xmm5

// CHECK: pshufb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0x2d,0x78,0x56,0x34,0x12]
        	pshufb	0x12345678,%xmm5

// CHECK: pshufb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0xed]
        	pshufb	%xmm5,%xmm5

// CHECK: psignb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psignb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psignb	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0x1d,0x45,0x00,0x00,0x00]
        	psignb	0x45,%mm3

// CHECK: psignb	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0x1d,0xed,0x7e,0x00,0x00]
        	psignb	0x7eed,%mm3

// CHECK: psignb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0x1d,0xfe,0xca,0xbe,0xba]
        	psignb	0xbabecafe,%mm3

// CHECK: psignb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0x1d,0x78,0x56,0x34,0x12]
        	psignb	0x12345678,%mm3

// CHECK: psignb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x08,0xdb]
        	psignb	%mm3,%mm3

// CHECK: psignb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psignb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psignb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0x2d,0x45,0x00,0x00,0x00]
        	psignb	0x45,%xmm5

// CHECK: psignb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0x2d,0xed,0x7e,0x00,0x00]
        	psignb	0x7eed,%xmm5

// CHECK: psignb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0x2d,0xfe,0xca,0xbe,0xba]
        	psignb	0xbabecafe,%xmm5

// CHECK: psignb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0x2d,0x78,0x56,0x34,0x12]
        	psignb	0x12345678,%xmm5

// CHECK: psignb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x08,0xed]
        	psignb	%xmm5,%xmm5

// CHECK: psignw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psignw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psignw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0x1d,0x45,0x00,0x00,0x00]
        	psignw	0x45,%mm3

// CHECK: psignw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0x1d,0xed,0x7e,0x00,0x00]
        	psignw	0x7eed,%mm3

// CHECK: psignw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0x1d,0xfe,0xca,0xbe,0xba]
        	psignw	0xbabecafe,%mm3

// CHECK: psignw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0x1d,0x78,0x56,0x34,0x12]
        	psignw	0x12345678,%mm3

// CHECK: psignw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x09,0xdb]
        	psignw	%mm3,%mm3

// CHECK: psignw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psignw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psignw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0x2d,0x45,0x00,0x00,0x00]
        	psignw	0x45,%xmm5

// CHECK: psignw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0x2d,0xed,0x7e,0x00,0x00]
        	psignw	0x7eed,%xmm5

// CHECK: psignw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0x2d,0xfe,0xca,0xbe,0xba]
        	psignw	0xbabecafe,%xmm5

// CHECK: psignw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0x2d,0x78,0x56,0x34,0x12]
        	psignw	0x12345678,%xmm5

// CHECK: psignw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x09,0xed]
        	psignw	%xmm5,%xmm5

// CHECK: psignd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	psignd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: psignd	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0x1d,0x45,0x00,0x00,0x00]
        	psignd	0x45,%mm3

// CHECK: psignd	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0x1d,0xed,0x7e,0x00,0x00]
        	psignd	0x7eed,%mm3

// CHECK: psignd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0x1d,0xfe,0xca,0xbe,0xba]
        	psignd	0xbabecafe,%mm3

// CHECK: psignd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0x1d,0x78,0x56,0x34,0x12]
        	psignd	0x12345678,%mm3

// CHECK: psignd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x0a,0xdb]
        	psignd	%mm3,%mm3

// CHECK: psignd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	psignd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: psignd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0x2d,0x45,0x00,0x00,0x00]
        	psignd	0x45,%xmm5

// CHECK: psignd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0x2d,0xed,0x7e,0x00,0x00]
        	psignd	0x7eed,%xmm5

// CHECK: psignd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0x2d,0xfe,0xca,0xbe,0xba]
        	psignd	0xbabecafe,%xmm5

// CHECK: psignd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0x2d,0x78,0x56,0x34,0x12]
        	psignd	0x12345678,%xmm5

// CHECK: psignd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x0a,0xed]
        	psignd	%xmm5,%xmm5

// CHECK: pabsb	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pabsb	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0x1d,0x45,0x00,0x00,0x00]
        	pabsb	0x45,%mm3

// CHECK: pabsb	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0x1d,0xed,0x7e,0x00,0x00]
        	pabsb	0x7eed,%mm3

// CHECK: pabsb	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0x1d,0xfe,0xca,0xbe,0xba]
        	pabsb	0xbabecafe,%mm3

// CHECK: pabsb	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0x1d,0x78,0x56,0x34,0x12]
        	pabsb	0x12345678,%mm3

// CHECK: pabsb	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1c,0xdb]
        	pabsb	%mm3,%mm3

// CHECK: pabsb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pabsb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0x2d,0x45,0x00,0x00,0x00]
        	pabsb	0x45,%xmm5

// CHECK: pabsb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0x2d,0xed,0x7e,0x00,0x00]
        	pabsb	0x7eed,%xmm5

// CHECK: pabsb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0x2d,0xfe,0xca,0xbe,0xba]
        	pabsb	0xbabecafe,%xmm5

// CHECK: pabsb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0x2d,0x78,0x56,0x34,0x12]
        	pabsb	0x12345678,%xmm5

// CHECK: pabsb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1c,0xed]
        	pabsb	%xmm5,%xmm5

// CHECK: pabsw	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pabsw	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0x1d,0x45,0x00,0x00,0x00]
        	pabsw	0x45,%mm3

// CHECK: pabsw	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0x1d,0xed,0x7e,0x00,0x00]
        	pabsw	0x7eed,%mm3

// CHECK: pabsw	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0x1d,0xfe,0xca,0xbe,0xba]
        	pabsw	0xbabecafe,%mm3

// CHECK: pabsw	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0x1d,0x78,0x56,0x34,0x12]
        	pabsw	0x12345678,%mm3

// CHECK: pabsw	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1d,0xdb]
        	pabsw	%mm3,%mm3

// CHECK: pabsw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pabsw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0x2d,0x45,0x00,0x00,0x00]
        	pabsw	0x45,%xmm5

// CHECK: pabsw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0x2d,0xed,0x7e,0x00,0x00]
        	pabsw	0x7eed,%xmm5

// CHECK: pabsw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0x2d,0xfe,0xca,0xbe,0xba]
        	pabsw	0xbabecafe,%xmm5

// CHECK: pabsw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0x2d,0x78,0x56,0x34,0x12]
        	pabsw	0x12345678,%xmm5

// CHECK: pabsw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1d,0xed]
        	pabsw	%xmm5,%xmm5

// CHECK: pabsd	3735928559(%ebx,%ecx,8), %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0x9c,0xcb,0xef,0xbe,0xad,0xde]
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: pabsd	69, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0x1d,0x45,0x00,0x00,0x00]
        	pabsd	0x45,%mm3

// CHECK: pabsd	32493, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0x1d,0xed,0x7e,0x00,0x00]
        	pabsd	0x7eed,%mm3

// CHECK: pabsd	3133065982, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0x1d,0xfe,0xca,0xbe,0xba]
        	pabsd	0xbabecafe,%mm3

// CHECK: pabsd	305419896, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0x1d,0x78,0x56,0x34,0x12]
        	pabsd	0x12345678,%mm3

// CHECK: pabsd	%mm3, %mm3
// CHECK:  encoding: [0x0f,0x38,0x1e,0xdb]
        	pabsd	%mm3,%mm3

// CHECK: pabsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pabsd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0x2d,0x45,0x00,0x00,0x00]
        	pabsd	0x45,%xmm5

// CHECK: pabsd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0x2d,0xed,0x7e,0x00,0x00]
        	pabsd	0x7eed,%xmm5

// CHECK: pabsd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0x2d,0xfe,0xca,0xbe,0xba]
        	pabsd	0xbabecafe,%xmm5

// CHECK: pabsd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0x2d,0x78,0x56,0x34,0x12]
        	pabsd	0x12345678,%xmm5

// CHECK: pabsd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x1e,0xed]
        	pabsd	%xmm5,%xmm5

// CHECK: femms
// CHECK:  encoding: [0x0f,0x0e]
        	femms

// CHECK: movntdqa	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	movntdqa	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: movntdqa	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2a,0x2d,0x45,0x00,0x00,0x00]
        	movntdqa	0x45,%xmm5

// CHECK: movntdqa	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2a,0x2d,0xed,0x7e,0x00,0x00]
        	movntdqa	0x7eed,%xmm5

// CHECK: movntdqa	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2a,0x2d,0xfe,0xca,0xbe,0xba]
        	movntdqa	0xbabecafe,%xmm5

// CHECK: movntdqa	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2a,0x2d,0x78,0x56,0x34,0x12]
        	movntdqa	0x12345678,%xmm5

// CHECK: packusdw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	packusdw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: packusdw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0x2d,0x45,0x00,0x00,0x00]
        	packusdw	0x45,%xmm5

// CHECK: packusdw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0x2d,0xed,0x7e,0x00,0x00]
        	packusdw	0x7eed,%xmm5

// CHECK: packusdw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0x2d,0xfe,0xca,0xbe,0xba]
        	packusdw	0xbabecafe,%xmm5

// CHECK: packusdw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0x2d,0x78,0x56,0x34,0x12]
        	packusdw	0x12345678,%xmm5

// CHECK: packusdw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x2b,0xed]
        	packusdw	%xmm5,%xmm5

// CHECK: pcmpeqq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpeqq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpeqq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0x2d,0x45,0x00,0x00,0x00]
        	pcmpeqq	0x45,%xmm5

// CHECK: pcmpeqq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpeqq	0x7eed,%xmm5

// CHECK: pcmpeqq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpeqq	0xbabecafe,%xmm5

// CHECK: pcmpeqq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0x2d,0x78,0x56,0x34,0x12]
        	pcmpeqq	0x12345678,%xmm5

// CHECK: pcmpeqq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x29,0xed]
        	pcmpeqq	%xmm5,%xmm5

// CHECK: phminposuw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	phminposuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: phminposuw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0x2d,0x45,0x00,0x00,0x00]
        	phminposuw	0x45,%xmm5

// CHECK: phminposuw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0x2d,0xed,0x7e,0x00,0x00]
        	phminposuw	0x7eed,%xmm5

// CHECK: phminposuw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0x2d,0xfe,0xca,0xbe,0xba]
        	phminposuw	0xbabecafe,%xmm5

// CHECK: phminposuw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0x2d,0x78,0x56,0x34,0x12]
        	phminposuw	0x12345678,%xmm5

// CHECK: phminposuw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x41,0xed]
        	phminposuw	%xmm5,%xmm5

// CHECK: pmaxsb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxsb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0x2d,0x45,0x00,0x00,0x00]
        	pmaxsb	0x45,%xmm5

// CHECK: pmaxsb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxsb	0x7eed,%xmm5

// CHECK: pmaxsb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxsb	0xbabecafe,%xmm5

// CHECK: pmaxsb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0x2d,0x78,0x56,0x34,0x12]
        	pmaxsb	0x12345678,%xmm5

// CHECK: pmaxsb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3c,0xed]
        	pmaxsb	%xmm5,%xmm5

// CHECK: pmaxsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxsd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0x2d,0x45,0x00,0x00,0x00]
        	pmaxsd	0x45,%xmm5

// CHECK: pmaxsd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxsd	0x7eed,%xmm5

// CHECK: pmaxsd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxsd	0xbabecafe,%xmm5

// CHECK: pmaxsd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0x2d,0x78,0x56,0x34,0x12]
        	pmaxsd	0x12345678,%xmm5

// CHECK: pmaxsd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3d,0xed]
        	pmaxsd	%xmm5,%xmm5

// CHECK: pmaxud	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxud	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxud	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0x2d,0x45,0x00,0x00,0x00]
        	pmaxud	0x45,%xmm5

// CHECK: pmaxud	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxud	0x7eed,%xmm5

// CHECK: pmaxud	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxud	0xbabecafe,%xmm5

// CHECK: pmaxud	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0x2d,0x78,0x56,0x34,0x12]
        	pmaxud	0x12345678,%xmm5

// CHECK: pmaxud	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3f,0xed]
        	pmaxud	%xmm5,%xmm5

// CHECK: pmaxuw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmaxuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmaxuw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0x2d,0x45,0x00,0x00,0x00]
        	pmaxuw	0x45,%xmm5

// CHECK: pmaxuw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0x2d,0xed,0x7e,0x00,0x00]
        	pmaxuw	0x7eed,%xmm5

// CHECK: pmaxuw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0x2d,0xfe,0xca,0xbe,0xba]
        	pmaxuw	0xbabecafe,%xmm5

// CHECK: pmaxuw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0x2d,0x78,0x56,0x34,0x12]
        	pmaxuw	0x12345678,%xmm5

// CHECK: pmaxuw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3e,0xed]
        	pmaxuw	%xmm5,%xmm5

// CHECK: pminsb	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminsb	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0x2d,0x45,0x00,0x00,0x00]
        	pminsb	0x45,%xmm5

// CHECK: pminsb	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0x2d,0xed,0x7e,0x00,0x00]
        	pminsb	0x7eed,%xmm5

// CHECK: pminsb	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0x2d,0xfe,0xca,0xbe,0xba]
        	pminsb	0xbabecafe,%xmm5

// CHECK: pminsb	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0x2d,0x78,0x56,0x34,0x12]
        	pminsb	0x12345678,%xmm5

// CHECK: pminsb	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x38,0xed]
        	pminsb	%xmm5,%xmm5

// CHECK: pminsd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminsd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0x2d,0x45,0x00,0x00,0x00]
        	pminsd	0x45,%xmm5

// CHECK: pminsd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0x2d,0xed,0x7e,0x00,0x00]
        	pminsd	0x7eed,%xmm5

// CHECK: pminsd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0x2d,0xfe,0xca,0xbe,0xba]
        	pminsd	0xbabecafe,%xmm5

// CHECK: pminsd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0x2d,0x78,0x56,0x34,0x12]
        	pminsd	0x12345678,%xmm5

// CHECK: pminsd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x39,0xed]
        	pminsd	%xmm5,%xmm5

// CHECK: pminud	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminud	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminud	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0x2d,0x45,0x00,0x00,0x00]
        	pminud	0x45,%xmm5

// CHECK: pminud	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0x2d,0xed,0x7e,0x00,0x00]
        	pminud	0x7eed,%xmm5

// CHECK: pminud	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0x2d,0xfe,0xca,0xbe,0xba]
        	pminud	0xbabecafe,%xmm5

// CHECK: pminud	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0x2d,0x78,0x56,0x34,0x12]
        	pminud	0x12345678,%xmm5

// CHECK: pminud	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3b,0xed]
        	pminud	%xmm5,%xmm5

// CHECK: pminuw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pminuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pminuw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0x2d,0x45,0x00,0x00,0x00]
        	pminuw	0x45,%xmm5

// CHECK: pminuw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0x2d,0xed,0x7e,0x00,0x00]
        	pminuw	0x7eed,%xmm5

// CHECK: pminuw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0x2d,0xfe,0xca,0xbe,0xba]
        	pminuw	0xbabecafe,%xmm5

// CHECK: pminuw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0x2d,0x78,0x56,0x34,0x12]
        	pminuw	0x12345678,%xmm5

// CHECK: pminuw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x3a,0xed]
        	pminuw	%xmm5,%xmm5

// CHECK: pmovsxbw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxbw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxbw	0x45,%xmm5

// CHECK: pmovsxbw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxbw	0x7eed,%xmm5

// CHECK: pmovsxbw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxbw	0xbabecafe,%xmm5

// CHECK: pmovsxbw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxbw	0x12345678,%xmm5

// CHECK: pmovsxbw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x20,0xed]
        	pmovsxbw	%xmm5,%xmm5

// CHECK: pmovsxbd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxbd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxbd	0x45,%xmm5

// CHECK: pmovsxbd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxbd	0x7eed,%xmm5

// CHECK: pmovsxbd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxbd	0xbabecafe,%xmm5

// CHECK: pmovsxbd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxbd	0x12345678,%xmm5

// CHECK: pmovsxbd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x21,0xed]
        	pmovsxbd	%xmm5,%xmm5

// CHECK: pmovsxbq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxbq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxbq	0x45,%xmm5

// CHECK: pmovsxbq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxbq	0x7eed,%xmm5

// CHECK: pmovsxbq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxbq	0xbabecafe,%xmm5

// CHECK: pmovsxbq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxbq	0x12345678,%xmm5

// CHECK: pmovsxbq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x22,0xed]
        	pmovsxbq	%xmm5,%xmm5

// CHECK: pmovsxwd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxwd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxwd	0x45,%xmm5

// CHECK: pmovsxwd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxwd	0x7eed,%xmm5

// CHECK: pmovsxwd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxwd	0xbabecafe,%xmm5

// CHECK: pmovsxwd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxwd	0x12345678,%xmm5

// CHECK: pmovsxwd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x23,0xed]
        	pmovsxwd	%xmm5,%xmm5

// CHECK: pmovsxwq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxwq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxwq	0x45,%xmm5

// CHECK: pmovsxwq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxwq	0x7eed,%xmm5

// CHECK: pmovsxwq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxwq	0xbabecafe,%xmm5

// CHECK: pmovsxwq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxwq	0x12345678,%xmm5

// CHECK: pmovsxwq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x24,0xed]
        	pmovsxwq	%xmm5,%xmm5

// CHECK: pmovsxdq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovsxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovsxdq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0x2d,0x45,0x00,0x00,0x00]
        	pmovsxdq	0x45,%xmm5

// CHECK: pmovsxdq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0x2d,0xed,0x7e,0x00,0x00]
        	pmovsxdq	0x7eed,%xmm5

// CHECK: pmovsxdq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovsxdq	0xbabecafe,%xmm5

// CHECK: pmovsxdq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0x2d,0x78,0x56,0x34,0x12]
        	pmovsxdq	0x12345678,%xmm5

// CHECK: pmovsxdq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x25,0xed]
        	pmovsxdq	%xmm5,%xmm5

// CHECK: pmovzxbw	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxbw	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxbw	0x45,%xmm5

// CHECK: pmovzxbw	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxbw	0x7eed,%xmm5

// CHECK: pmovzxbw	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxbw	0xbabecafe,%xmm5

// CHECK: pmovzxbw	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxbw	0x12345678,%xmm5

// CHECK: pmovzxbw	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x30,0xed]
        	pmovzxbw	%xmm5,%xmm5

// CHECK: pmovzxbd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxbd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxbd	0x45,%xmm5

// CHECK: pmovzxbd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxbd	0x7eed,%xmm5

// CHECK: pmovzxbd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxbd	0xbabecafe,%xmm5

// CHECK: pmovzxbd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxbd	0x12345678,%xmm5

// CHECK: pmovzxbd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x31,0xed]
        	pmovzxbd	%xmm5,%xmm5

// CHECK: pmovzxbq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxbq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxbq	0x45,%xmm5

// CHECK: pmovzxbq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxbq	0x7eed,%xmm5

// CHECK: pmovzxbq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxbq	0xbabecafe,%xmm5

// CHECK: pmovzxbq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxbq	0x12345678,%xmm5

// CHECK: pmovzxbq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x32,0xed]
        	pmovzxbq	%xmm5,%xmm5

// CHECK: pmovzxwd	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxwd	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxwd	0x45,%xmm5

// CHECK: pmovzxwd	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxwd	0x7eed,%xmm5

// CHECK: pmovzxwd	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxwd	0xbabecafe,%xmm5

// CHECK: pmovzxwd	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxwd	0x12345678,%xmm5

// CHECK: pmovzxwd	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x33,0xed]
        	pmovzxwd	%xmm5,%xmm5

// CHECK: pmovzxwq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxwq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxwq	0x45,%xmm5

// CHECK: pmovzxwq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxwq	0x7eed,%xmm5

// CHECK: pmovzxwq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxwq	0xbabecafe,%xmm5

// CHECK: pmovzxwq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxwq	0x12345678,%xmm5

// CHECK: pmovzxwq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x34,0xed]
        	pmovzxwq	%xmm5,%xmm5

// CHECK: pmovzxdq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmovzxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmovzxdq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0x2d,0x45,0x00,0x00,0x00]
        	pmovzxdq	0x45,%xmm5

// CHECK: pmovzxdq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0x2d,0xed,0x7e,0x00,0x00]
        	pmovzxdq	0x7eed,%xmm5

// CHECK: pmovzxdq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0x2d,0xfe,0xca,0xbe,0xba]
        	pmovzxdq	0xbabecafe,%xmm5

// CHECK: pmovzxdq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0x2d,0x78,0x56,0x34,0x12]
        	pmovzxdq	0x12345678,%xmm5

// CHECK: pmovzxdq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x35,0xed]
        	pmovzxdq	%xmm5,%xmm5

// CHECK: pmuldq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmuldq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmuldq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0x2d,0x45,0x00,0x00,0x00]
        	pmuldq	0x45,%xmm5

// CHECK: pmuldq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0x2d,0xed,0x7e,0x00,0x00]
        	pmuldq	0x7eed,%xmm5

// CHECK: pmuldq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0x2d,0xfe,0xca,0xbe,0xba]
        	pmuldq	0xbabecafe,%xmm5

// CHECK: pmuldq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0x2d,0x78,0x56,0x34,0x12]
        	pmuldq	0x12345678,%xmm5

// CHECK: pmuldq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x28,0xed]
        	pmuldq	%xmm5,%xmm5

// CHECK: pmulld	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pmulld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pmulld	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0x2d,0x45,0x00,0x00,0x00]
        	pmulld	0x45,%xmm5

// CHECK: pmulld	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0x2d,0xed,0x7e,0x00,0x00]
        	pmulld	0x7eed,%xmm5

// CHECK: pmulld	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0x2d,0xfe,0xca,0xbe,0xba]
        	pmulld	0xbabecafe,%xmm5

// CHECK: pmulld	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0x2d,0x78,0x56,0x34,0x12]
        	pmulld	0x12345678,%xmm5

// CHECK: pmulld	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x40,0xed]
        	pmulld	%xmm5,%xmm5

// CHECK: ptest 	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	ptest	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: ptest 	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0x2d,0x45,0x00,0x00,0x00]
        	ptest	0x45,%xmm5

// CHECK: ptest 	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0x2d,0xed,0x7e,0x00,0x00]
        	ptest	0x7eed,%xmm5

// CHECK: ptest 	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0x2d,0xfe,0xca,0xbe,0xba]
        	ptest	0xbabecafe,%xmm5

// CHECK: ptest 	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0x2d,0x78,0x56,0x34,0x12]
        	ptest	0x12345678,%xmm5

// CHECK: ptest 	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x17,0xed]
        	ptest	%xmm5,%xmm5

// CHECK: pcmpgtq	3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0xac,0xcb,0xef,0xbe,0xad,0xde]
        	pcmpgtq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: pcmpgtq	69, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0x2d,0x45,0x00,0x00,0x00]
        	pcmpgtq	0x45,%xmm5

// CHECK: pcmpgtq	32493, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0x2d,0xed,0x7e,0x00,0x00]
        	pcmpgtq	0x7eed,%xmm5

// CHECK: pcmpgtq	3133065982, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0x2d,0xfe,0xca,0xbe,0xba]
        	pcmpgtq	0xbabecafe,%xmm5

// CHECK: pcmpgtq	305419896, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0x2d,0x78,0x56,0x34,0x12]
        	pcmpgtq	0x12345678,%xmm5

// CHECK: pcmpgtq	%xmm5, %xmm5
// CHECK:  encoding: [0x66,0x0f,0x38,0x37,0xed]
        	pcmpgtq	%xmm5,%xmm5

// CHECK: crc32b 	%bl, %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf0,0xc3]
                crc32b %bl, %eax

// CHECK: crc32b 	4(%ebx), %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf0,0x43,0x04]
                crc32b 4(%ebx), %eax

// CHECK: crc32w 	%bx, %eax
// CHECK:  encoding: [0x66,0xf2,0x0f,0x38,0xf1,0xc3]
                crc32w %bx, %eax

// CHECK: crc32w 	4(%ebx), %eax
// CHECK:  encoding: [0x66,0xf2,0x0f,0x38,0xf1,0x43,0x04]
                crc32w 4(%ebx), %eax

// CHECK: crc32l 	%ebx, %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0xc3]
                crc32l %ebx, %eax

// CHECK: crc32l 	4(%ebx), %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x43,0x04]
                crc32l 4(%ebx), %eax

// CHECK: crc32l 	3735928559(%ebx,%ecx,8), %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x8c,0xcb,0xef,0xbe,0xad,0xde]
                crc32l 0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: crc32l 	69, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0d,0x45,0x00,0x00,0x00]
                crc32l 0x45,%ecx

// CHECK: crc32l 	32493, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0d,0xed,0x7e,0x00,0x00]
                crc32l 0x7eed,%ecx

// CHECK: crc32l 	3133065982, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0d,0xfe,0xca,0xbe,0xba]
                crc32l 0xbabecafe,%ecx

// CHECK: crc32l 	%ecx, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0xc9]
                crc32l %ecx,%ecx

// CHECK: pcmpistrm	$125, %xmm1, %xmm2
// CHECK:  encoding: [0x66,0x0f,0x3a,0x62,0xd1,0x7d]
                pcmpistrm $125, %xmm1, %xmm2

// CHECK: pcmpistrm	$125, (%edx,%eax,4), %xmm2
// CHECK:  encoding: [0x66,0x0f,0x3a,0x62,0x14,0x82,0x7d]
                pcmpistrm $125, (%edx,%eax,4), %xmm2

// CHECK: aesimc	%xmm0, %xmm1
// CHECK:  encoding: [0x66,0x0f,0x38,0xdb,0xc8]
                aesimc %xmm0,%xmm1

// CHECK: aesimc	(%eax), %xmm1
// CHECK:  encoding: [0x66,0x0f,0x38,0xdb,0x08]
                aesimc (%eax),%xmm1

// CHECK: aesenc	%xmm1, %xmm2
// CHECK:  encoding: [0x66,0x0f,0x38,0xdc,0xd1]
                aesenc %xmm1,%xmm2

// CHECK: aesenc	4(%ebx), %xmm2
// CHECK:  encoding: [0x66,0x0f,0x38,0xdc,0x53,0x04]
                aesenc 4(%ebx),%xmm2

// CHECK: aesenclast	%xmm3, %xmm4
// CHECK:  encoding: [0x66,0x0f,0x38,0xdd,0xe3]
                aesenclast %xmm3,%xmm4

// CHECK: aesenclast	4(%edx,%edi), %xmm4
// CHECK:  encoding: [0x66,0x0f,0x38,0xdd,0x64,0x3a,0x04]
                aesenclast 4(%edx,%edi),%xmm4

// CHECK: aesdec	%xmm5, %xmm6
// CHECK:  encoding: [0x66,0x0f,0x38,0xde,0xf5]
                aesdec %xmm5,%xmm6

// CHECK: aesdec	4(%ecx,%eax,8), %xmm6
// CHECK:  encoding: [0x66,0x0f,0x38,0xde,0x74,0xc1,0x04]
                aesdec 4(%ecx,%eax,8),%xmm6

// CHECK: aesdeclast	%xmm7, %xmm0
// CHECK:  encoding: [0x66,0x0f,0x38,0xdf,0xc7]
                aesdeclast %xmm7,%xmm0

// CHECK: aesdeclast	3405691582, %xmm0
// CHECK:  encoding: [0x66,0x0f,0x38,0xdf,0x05,0xbe,0xba,0xfe,0xca]
                aesdeclast 0xcafebabe,%xmm0

// CHECK: aeskeygenassist	$125, %xmm1, %xmm2
// CHECK:  encoding: [0x66,0x0f,0x3a,0xdf,0xd1,0x7d]
                aeskeygenassist $125, %xmm1, %xmm2

// CHECK: aeskeygenassist	$125, (%edx,%eax,4), %xmm2
// CHECK:  encoding: [0x66,0x0f,0x3a,0xdf,0x14,0x82,0x7d]
                aeskeygenassist $125, (%edx,%eax,4), %xmm2

// rdar://8017638
// CHECK: aeskeygenassist	$128, %xmm1, %xmm2
// CHECK:  encoding: [0x66,0x0f,0x3a,0xdf,0xd1,0x80]
		aeskeygenassist $128, %xmm1, %xmm2

// rdar://7910087
// CHECK: bsfw	%bx, %bx
// CHECK:  encoding: [0x66,0x0f,0xbc,0xdb]
          bsfw  %bx, %bx

// CHECK: bsfw	3735928559(%ebx,%ecx,8), %bx
// CHECK:  encoding: [0x66,0x0f,0xbc,0x9c,0xcb,0xef,0xbe,0xad,0xde]
          bsfw  3735928559(%ebx,%ecx,8), %bx

// CHECK: bsrw	%bx, %bx
// CHECK:  encoding: [0x66,0x0f,0xbd,0xdb]
          bsrw  %bx, %bx

// CHECK: bsrw	305419896, %bx
// CHECK:  encoding: [0x66,0x0f,0xbd,0x1d,0x78,0x56,0x34,0x12]
          bsrw  305419896, %bx

// radr://7901779
// CHECK: pushl   $127
// CHECK:  encoding: [0x6a,0x7f]
          pushl   $127

// CHECK: pushw   $254
// CHECK:  encoding: [0x66,0x68,0xfe,0x00]
          pushw   $254

// CHECK: pushl   $254
// CHECK:  encoding: [0x68,0xfe,0x00,0x00,0x00]
          pushl   $254

// radr://7928400
// CHECK: movq    %mm3, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x7f,0x9c,0xcb,0xef,0xbe,0xad,0xde]
          movq    %mm3, 3735928559(%ebx,%ecx,8)

// CHECK: movd    %mm3, 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0x0f,0x7e,0x9c,0xcb,0xef,0xbe,0xad,0xde]
          movd    %mm3, 3735928559(%ebx,%ecx,8)

// CHECK: movq    3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0xf3,0x0f,0x7e,0xac,0xcb,0xef,0xbe,0xad,0xde]
          movq    3735928559(%ebx,%ecx,8), %xmm5

// CHECK: movd    3735928559(%ebx,%ecx,8), %xmm5
// CHECK:  encoding: [0x66,0x0f,0x6e,0xac,0xcb,0xef,0xbe,0xad,0xde]
          movd    3735928559(%ebx,%ecx,8), %xmm5

// radr://7914715
// CHECK: fcoml   3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0x94,0xcb,0xef,0xbe,0xad,0xde]
          fcoml   3735928559(%ebx,%ecx,8)

// CHECK: fcoms   32493
// CHECK:  encoding: [0xd8,0x15,0xed,0x7e,0x00,0x00]
          fcoms   32493

// CHECK: fcompl  3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xdc,0x9c,0xcb,0xef,0xbe,0xad,0xde]
          fcompl  3735928559(%ebx,%ecx,8)

// CHECK: fcomps  32493
// CHECK:  encoding: [0xd8,0x1d,0xed,0x7e,0x00,0x00]
          fcomps  32493

// CHECK: ficoml  3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x94,0xcb,0xef,0xbe,0xad,0xde]
          ficoml  3735928559(%ebx,%ecx,8)

// CHECK: ficoms  32493
// CHECK:  encoding: [0xde,0x15,0xed,0x7e,0x00,0x00]
          ficoms  32493

// CHECK: ficompl 3735928559(%ebx,%ecx,8)
// CHECK:  encoding: [0xda,0x9c,0xcb,0xef,0xbe,0xad,0xde]
          ficompl 3735928559(%ebx,%ecx,8)

// CHECK: ficomps 32493
// CHECK:  encoding: [0xde,0x1d,0xed,0x7e,0x00,0x00]
          ficomps 32493

// CHECK: movl  57005(,%eiz), %ebx
// CHECK: encoding: [0x8b,0x1c,0x25,0xad,0xde,0x00,0x00]
          movl  57005(,%eiz), %ebx

// CHECK: movl  48879(,%eiz), %eax
// CHECK: encoding: [0x8b,0x04,0x25,0xef,0xbe,0x00,0x00]
          movl  48879(,%eiz), %eax

// CHECK: movl  -4(,%eiz,8), %eax
// CHECK: encoding: [0x8b,0x04,0xe5,0xfc,0xff,0xff,0xff]
          movl  -4(,%eiz,8), %eax

// CHECK: movl  (%ecx,%eiz), %eax
// CHECK: encoding: [0x8b,0x04,0x21]
          movl  (%ecx,%eiz), %eax

// CHECK: movl  (%ecx,%eiz,8), %eax
// CHECK: encoding: [0x8b,0x04,0xe1]
          movl  (%ecx,%eiz,8), %eax

// CHECK: addl	$4294967295, %eax       # encoding: [0x83,0xc0,0xff]
        addl $0xFFFFFFFF, %eax

// CHECK: addw	$65535, %ax       # encoding: [0x66,0x83,0xc0,0xff]
        addw $0xFFFF, %ax


// CHECK: 	movb	$127, 3735928559(%ebx,%ecx,8)
        	movb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movb	$127, 69
        	movb	$0x7f,0x45

// CHECK: 	movb	$127, 32493
        	movb	$0x7f,0x7eed

// CHECK: 	movb	$127, 3133065982
        	movb	$0x7f,0xbabecafe

// CHECK: 	movb	$127, 305419896
        	movb	$0x7f,0x12345678

// CHECK: 	movw	$31438, 3735928559(%ebx,%ecx,8)
        	movw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movw	$31438, 69
        	movw	$0x7ace,0x45

// CHECK: 	movw	$31438, 32493
        	movw	$0x7ace,0x7eed

// CHECK: 	movw	$31438, 3133065982
        	movw	$0x7ace,0xbabecafe

// CHECK: 	movw	$31438, 305419896
        	movw	$0x7ace,0x12345678

// CHECK: 	movl	$2063514302, 3735928559(%ebx,%ecx,8)
        	movl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movl	$2063514302, 69
        	movl	$0x7afebabe,0x45

// CHECK: 	movl	$2063514302, 32493
        	movl	$0x7afebabe,0x7eed

// CHECK: 	movl	$2063514302, 3133065982
        	movl	$0x7afebabe,0xbabecafe

// CHECK: 	movl	$2063514302, 305419896
        	movl	$0x7afebabe,0x12345678

// CHECK: 	movl	$324478056, 3735928559(%ebx,%ecx,8)
        	movl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movl	$324478056, 69
        	movl	$0x13572468,0x45

// CHECK: 	movl	$324478056, 32493
        	movl	$0x13572468,0x7eed

// CHECK: 	movl	$324478056, 3133065982
        	movl	$0x13572468,0xbabecafe

// CHECK: 	movl	$324478056, 305419896
        	movl	$0x13572468,0x12345678

// CHECK: 	movsbl	3735928559(%ebx,%ecx,8), %ecx
        	movsbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movsbl	69, %ecx
        	movsbl	0x45,%ecx

// CHECK: 	movsbl	32493, %ecx
        	movsbl	0x7eed,%ecx

// CHECK: 	movsbl	3133065982, %ecx
        	movsbl	0xbabecafe,%ecx

// CHECK: 	movsbl	305419896, %ecx
        	movsbl	0x12345678,%ecx

// CHECK: 	movsbw	3735928559(%ebx,%ecx,8), %bx
        	movsbw	0xdeadbeef(%ebx,%ecx,8),%bx

// CHECK: 	movsbw	69, %bx
        	movsbw	0x45,%bx

// CHECK: 	movsbw	32493, %bx
        	movsbw	0x7eed,%bx

// CHECK: 	movsbw	3133065982, %bx
        	movsbw	0xbabecafe,%bx

// CHECK: 	movsbw	305419896, %bx
        	movsbw	0x12345678,%bx

// CHECK: 	movswl	3735928559(%ebx,%ecx,8), %ecx
        	movswl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movswl	69, %ecx
        	movswl	0x45,%ecx

// CHECK: 	movswl	32493, %ecx
        	movswl	0x7eed,%ecx

// CHECK: 	movswl	3133065982, %ecx
        	movswl	0xbabecafe,%ecx

// CHECK: 	movswl	305419896, %ecx
        	movswl	0x12345678,%ecx

// CHECK: 	movzbl	3735928559(%ebx,%ecx,8), %ecx
        	movzbl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movzbl	69, %ecx
        	movzbl	0x45,%ecx

// CHECK: 	movzbl	32493, %ecx
        	movzbl	0x7eed,%ecx

// CHECK: 	movzbl	3133065982, %ecx
        	movzbl	0xbabecafe,%ecx

// CHECK: 	movzbl	305419896, %ecx
        	movzbl	0x12345678,%ecx

// CHECK: 	movzbw	3735928559(%ebx,%ecx,8), %bx
        	movzbw	0xdeadbeef(%ebx,%ecx,8),%bx

// CHECK: 	movzbw	69, %bx
        	movzbw	0x45,%bx

// CHECK: 	movzbw	32493, %bx
        	movzbw	0x7eed,%bx

// CHECK: 	movzbw	3133065982, %bx
        	movzbw	0xbabecafe,%bx

// CHECK: 	movzbw	305419896, %bx
        	movzbw	0x12345678,%bx

// CHECK: 	movzwl	3735928559(%ebx,%ecx,8), %ecx
        	movzwl	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	movzwl	69, %ecx
        	movzwl	0x45,%ecx

// CHECK: 	movzwl	32493, %ecx
        	movzwl	0x7eed,%ecx

// CHECK: 	movzwl	3133065982, %ecx
        	movzwl	0xbabecafe,%ecx

// CHECK: 	movzwl	305419896, %ecx
        	movzwl	0x12345678,%ecx

// CHECK: 	pushw	32493
        	pushw	0x7eed

// CHECK: 	popw	32493
        	popw	0x7eed

// CHECK: 	pushf
        	pushfl

// CHECK: 	pushfl
        	pushfl

// CHECK: 	popf
        	popfl

// CHECK: 	popfl
        	popfl

// CHECK: 	clc
        	clc

// CHECK: 	cld
        	cld

// CHECK: 	cli
        	cli

// CHECK: 	clts
        	clts

// CHECK: 	cmc
        	cmc

// CHECK: 	lahf
        	lahf

// CHECK: 	sahf
        	sahf

// CHECK: 	stc
        	stc

// CHECK: 	std
        	std

// CHECK: 	sti
        	sti

// CHECK: 	addb	$254, 3735928559(%ebx,%ecx,8)
        	addb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addb	$254, 69
        	addb	$0xfe,0x45

// CHECK: 	addb	$254, 32493
        	addb	$0xfe,0x7eed

// CHECK: 	addb	$254, 3133065982
        	addb	$0xfe,0xbabecafe

// CHECK: 	addb	$254, 305419896
        	addb	$0xfe,0x12345678

// CHECK: 	addb	$127, 3735928559(%ebx,%ecx,8)
        	addb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addb	$127, 69
        	addb	$0x7f,0x45

// CHECK: 	addb	$127, 32493
        	addb	$0x7f,0x7eed

// CHECK: 	addb	$127, 3133065982
        	addb	$0x7f,0xbabecafe

// CHECK: 	addb	$127, 305419896
        	addb	$0x7f,0x12345678

// CHECK: 	addw	$31438, 3735928559(%ebx,%ecx,8)
        	addw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addw	$31438, 69
        	addw	$0x7ace,0x45

// CHECK: 	addw	$31438, 32493
        	addw	$0x7ace,0x7eed

// CHECK: 	addw	$31438, 3133065982
        	addw	$0x7ace,0xbabecafe

// CHECK: 	addw	$31438, 305419896
        	addw	$0x7ace,0x12345678

// CHECK: 	addl	$2063514302, 3735928559(%ebx,%ecx,8)
        	addl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addl	$2063514302, 69
        	addl	$0x7afebabe,0x45

// CHECK: 	addl	$2063514302, 32493
        	addl	$0x7afebabe,0x7eed

// CHECK: 	addl	$2063514302, 3133065982
        	addl	$0x7afebabe,0xbabecafe

// CHECK: 	addl	$2063514302, 305419896
        	addl	$0x7afebabe,0x12345678

// CHECK: 	addl	$324478056, 3735928559(%ebx,%ecx,8)
        	addl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	addl	$324478056, 69
        	addl	$0x13572468,0x45

// CHECK: 	addl	$324478056, 32493
        	addl	$0x13572468,0x7eed

// CHECK: 	addl	$324478056, 3133065982
        	addl	$0x13572468,0xbabecafe

// CHECK: 	addl	$324478056, 305419896
        	addl	$0x13572468,0x12345678

// CHECK: 	incl	3735928559(%ebx,%ecx,8)
        	incl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	incw	32493
        	incw	0x7eed

// CHECK: 	incl	3133065982
        	incl	0xbabecafe

// CHECK: 	incl	305419896
        	incl	0x12345678

// CHECK: 	subb	$254, 3735928559(%ebx,%ecx,8)
        	subb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subb	$254, 69
        	subb	$0xfe,0x45

// CHECK: 	subb	$254, 32493
        	subb	$0xfe,0x7eed

// CHECK: 	subb	$254, 3133065982
        	subb	$0xfe,0xbabecafe

// CHECK: 	subb	$254, 305419896
        	subb	$0xfe,0x12345678

// CHECK: 	subb	$127, 3735928559(%ebx,%ecx,8)
        	subb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subb	$127, 69
        	subb	$0x7f,0x45

// CHECK: 	subb	$127, 32493
        	subb	$0x7f,0x7eed

// CHECK: 	subb	$127, 3133065982
        	subb	$0x7f,0xbabecafe

// CHECK: 	subb	$127, 305419896
        	subb	$0x7f,0x12345678

// CHECK: 	subw	$31438, 3735928559(%ebx,%ecx,8)
        	subw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subw	$31438, 69
        	subw	$0x7ace,0x45

// CHECK: 	subw	$31438, 32493
        	subw	$0x7ace,0x7eed

// CHECK: 	subw	$31438, 3133065982
        	subw	$0x7ace,0xbabecafe

// CHECK: 	subw	$31438, 305419896
        	subw	$0x7ace,0x12345678

// CHECK: 	subl	$2063514302, 3735928559(%ebx,%ecx,8)
        	subl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subl	$2063514302, 69
        	subl	$0x7afebabe,0x45

// CHECK: 	subl	$2063514302, 32493
        	subl	$0x7afebabe,0x7eed

// CHECK: 	subl	$2063514302, 3133065982
        	subl	$0x7afebabe,0xbabecafe

// CHECK: 	subl	$2063514302, 305419896
        	subl	$0x7afebabe,0x12345678

// CHECK: 	subl	$324478056, 3735928559(%ebx,%ecx,8)
        	subl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	subl	$324478056, 69
        	subl	$0x13572468,0x45

// CHECK: 	subl	$324478056, 32493
        	subl	$0x13572468,0x7eed

// CHECK: 	subl	$324478056, 3133065982
        	subl	$0x13572468,0xbabecafe

// CHECK: 	subl	$324478056, 305419896
        	subl	$0x13572468,0x12345678

// CHECK: 	decl	3735928559(%ebx,%ecx,8)
        	decl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	decw	32493
        	decw	0x7eed

// CHECK: 	decl	3133065982
        	decl	0xbabecafe

// CHECK: 	decl	305419896
        	decl	0x12345678

// CHECK: 	sbbb	$254, 3735928559(%ebx,%ecx,8)
        	sbbb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbb	$254, 69
        	sbbb	$0xfe,0x45

// CHECK: 	sbbb	$254, 32493
        	sbbb	$0xfe,0x7eed

// CHECK: 	sbbb	$254, 3133065982
        	sbbb	$0xfe,0xbabecafe

// CHECK: 	sbbb	$254, 305419896
        	sbbb	$0xfe,0x12345678

// CHECK: 	sbbb	$127, 3735928559(%ebx,%ecx,8)
        	sbbb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbb	$127, 69
        	sbbb	$0x7f,0x45

// CHECK: 	sbbb	$127, 32493
        	sbbb	$0x7f,0x7eed

// CHECK: 	sbbb	$127, 3133065982
        	sbbb	$0x7f,0xbabecafe

// CHECK: 	sbbb	$127, 305419896
        	sbbb	$0x7f,0x12345678

// CHECK: 	sbbw	$31438, 3735928559(%ebx,%ecx,8)
        	sbbw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbw	$31438, 69
        	sbbw	$0x7ace,0x45

// CHECK: 	sbbw	$31438, 32493
        	sbbw	$0x7ace,0x7eed

// CHECK: 	sbbw	$31438, 3133065982
        	sbbw	$0x7ace,0xbabecafe

// CHECK: 	sbbw	$31438, 305419896
        	sbbw	$0x7ace,0x12345678

// CHECK: 	sbbl	$2063514302, 3735928559(%ebx,%ecx,8)
        	sbbl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbl	$2063514302, 69
        	sbbl	$0x7afebabe,0x45

// CHECK: 	sbbl	$2063514302, 32493
        	sbbl	$0x7afebabe,0x7eed

// CHECK: 	sbbl	$2063514302, 3133065982
        	sbbl	$0x7afebabe,0xbabecafe

// CHECK: 	sbbl	$2063514302, 305419896
        	sbbl	$0x7afebabe,0x12345678

// CHECK: 	sbbl	$324478056, 3735928559(%ebx,%ecx,8)
        	sbbl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sbbl	$324478056, 69
        	sbbl	$0x13572468,0x45

// CHECK: 	sbbl	$324478056, 32493
        	sbbl	$0x13572468,0x7eed

// CHECK: 	sbbl	$324478056, 3133065982
        	sbbl	$0x13572468,0xbabecafe

// CHECK: 	sbbl	$324478056, 305419896
        	sbbl	$0x13572468,0x12345678

// CHECK: 	cmpb	$254, 3735928559(%ebx,%ecx,8)
        	cmpb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpb	$254, 69
        	cmpb	$0xfe,0x45

// CHECK: 	cmpb	$254, 32493
        	cmpb	$0xfe,0x7eed

// CHECK: 	cmpb	$254, 3133065982
        	cmpb	$0xfe,0xbabecafe

// CHECK: 	cmpb	$254, 305419896
        	cmpb	$0xfe,0x12345678

// CHECK: 	cmpb	$127, 3735928559(%ebx,%ecx,8)
        	cmpb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpb	$127, 69
        	cmpb	$0x7f,0x45

// CHECK: 	cmpb	$127, 32493
        	cmpb	$0x7f,0x7eed

// CHECK: 	cmpb	$127, 3133065982
        	cmpb	$0x7f,0xbabecafe

// CHECK: 	cmpb	$127, 305419896
        	cmpb	$0x7f,0x12345678

// CHECK: 	cmpw	$31438, 3735928559(%ebx,%ecx,8)
        	cmpw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpw	$31438, 69
        	cmpw	$0x7ace,0x45

// CHECK: 	cmpw	$31438, 32493
        	cmpw	$0x7ace,0x7eed

// CHECK: 	cmpw	$31438, 3133065982
        	cmpw	$0x7ace,0xbabecafe

// CHECK: 	cmpw	$31438, 305419896
        	cmpw	$0x7ace,0x12345678

// CHECK: 	cmpl	$2063514302, 3735928559(%ebx,%ecx,8)
        	cmpl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpl	$2063514302, 69
        	cmpl	$0x7afebabe,0x45

// CHECK: 	cmpl	$2063514302, 32493
        	cmpl	$0x7afebabe,0x7eed

// CHECK: 	cmpl	$2063514302, 3133065982
        	cmpl	$0x7afebabe,0xbabecafe

// CHECK: 	cmpl	$2063514302, 305419896
        	cmpl	$0x7afebabe,0x12345678

// CHECK: 	cmpl	$324478056, 3735928559(%ebx,%ecx,8)
        	cmpl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpl	$324478056, 69
        	cmpl	$0x13572468,0x45

// CHECK: 	cmpl	$324478056, 32493
        	cmpl	$0x13572468,0x7eed

// CHECK: 	cmpl	$324478056, 3133065982
        	cmpl	$0x13572468,0xbabecafe

// CHECK: 	cmpl	$324478056, 305419896
        	cmpl	$0x13572468,0x12345678

// CHECK: 	testb	$127, 3735928559(%ebx,%ecx,8)
        	testb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testb	$127, 69
        	testb	$0x7f,0x45

// CHECK: 	testb	$127, 32493
        	testb	$0x7f,0x7eed

// CHECK: 	testb	$127, 3133065982
        	testb	$0x7f,0xbabecafe

// CHECK: 	testb	$127, 305419896
        	testb	$0x7f,0x12345678

// CHECK: 	testw	$31438, 3735928559(%ebx,%ecx,8)
        	testw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testw	$31438, 69
        	testw	$0x7ace,0x45

// CHECK: 	testw	$31438, 32493
        	testw	$0x7ace,0x7eed

// CHECK: 	testw	$31438, 3133065982
        	testw	$0x7ace,0xbabecafe

// CHECK: 	testw	$31438, 305419896
        	testw	$0x7ace,0x12345678

// CHECK: 	testl	$2063514302, 3735928559(%ebx,%ecx,8)
        	testl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testl	$2063514302, 69
        	testl	$0x7afebabe,0x45

// CHECK: 	testl	$2063514302, 32493
        	testl	$0x7afebabe,0x7eed

// CHECK: 	testl	$2063514302, 3133065982
        	testl	$0x7afebabe,0xbabecafe

// CHECK: 	testl	$2063514302, 305419896
        	testl	$0x7afebabe,0x12345678

// CHECK: 	testl	$324478056, 3735928559(%ebx,%ecx,8)
        	testl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	testl	$324478056, 69
        	testl	$0x13572468,0x45

// CHECK: 	testl	$324478056, 32493
        	testl	$0x13572468,0x7eed

// CHECK: 	testl	$324478056, 3133065982
        	testl	$0x13572468,0xbabecafe

// CHECK: 	testl	$324478056, 305419896
        	testl	$0x13572468,0x12345678

// CHECK: 	andb	$254, 3735928559(%ebx,%ecx,8)
        	andb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andb	$254, 69
        	andb	$0xfe,0x45

// CHECK: 	andb	$254, 32493
        	andb	$0xfe,0x7eed

// CHECK: 	andb	$254, 3133065982
        	andb	$0xfe,0xbabecafe

// CHECK: 	andb	$254, 305419896
        	andb	$0xfe,0x12345678

// CHECK: 	andb	$127, 3735928559(%ebx,%ecx,8)
        	andb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andb	$127, 69
        	andb	$0x7f,0x45

// CHECK: 	andb	$127, 32493
        	andb	$0x7f,0x7eed

// CHECK: 	andb	$127, 3133065982
        	andb	$0x7f,0xbabecafe

// CHECK: 	andb	$127, 305419896
        	andb	$0x7f,0x12345678

// CHECK: 	andw	$31438, 3735928559(%ebx,%ecx,8)
        	andw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andw	$31438, 69
        	andw	$0x7ace,0x45

// CHECK: 	andw	$31438, 32493
        	andw	$0x7ace,0x7eed

// CHECK: 	andw	$31438, 3133065982
        	andw	$0x7ace,0xbabecafe

// CHECK: 	andw	$31438, 305419896
        	andw	$0x7ace,0x12345678

// CHECK: 	andl	$2063514302, 3735928559(%ebx,%ecx,8)
        	andl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andl	$2063514302, 69
        	andl	$0x7afebabe,0x45

// CHECK: 	andl	$2063514302, 32493
        	andl	$0x7afebabe,0x7eed

// CHECK: 	andl	$2063514302, 3133065982
        	andl	$0x7afebabe,0xbabecafe

// CHECK: 	andl	$2063514302, 305419896
        	andl	$0x7afebabe,0x12345678

// CHECK: 	andl	$324478056, 3735928559(%ebx,%ecx,8)
        	andl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	andl	$324478056, 69
        	andl	$0x13572468,0x45

// CHECK: 	andl	$324478056, 32493
        	andl	$0x13572468,0x7eed

// CHECK: 	andl	$324478056, 3133065982
        	andl	$0x13572468,0xbabecafe

// CHECK: 	andl	$324478056, 305419896
        	andl	$0x13572468,0x12345678

// CHECK: 	orb	$254, 3735928559(%ebx,%ecx,8)
        	orb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orb	$254, 69
        	orb	$0xfe,0x45

// CHECK: 	orb	$254, 32493
        	orb	$0xfe,0x7eed

// CHECK: 	orb	$254, 3133065982
        	orb	$0xfe,0xbabecafe

// CHECK: 	orb	$254, 305419896
        	orb	$0xfe,0x12345678

// CHECK: 	orb	$127, 3735928559(%ebx,%ecx,8)
        	orb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orb	$127, 69
        	orb	$0x7f,0x45

// CHECK: 	orb	$127, 32493
        	orb	$0x7f,0x7eed

// CHECK: 	orb	$127, 3133065982
        	orb	$0x7f,0xbabecafe

// CHECK: 	orb	$127, 305419896
        	orb	$0x7f,0x12345678

// CHECK: 	orw	$31438, 3735928559(%ebx,%ecx,8)
        	orw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orw	$31438, 69
        	orw	$0x7ace,0x45

// CHECK: 	orw	$31438, 32493
        	orw	$0x7ace,0x7eed

// CHECK: 	orw	$31438, 3133065982
        	orw	$0x7ace,0xbabecafe

// CHECK: 	orw	$31438, 305419896
        	orw	$0x7ace,0x12345678

// CHECK: 	orl	$2063514302, 3735928559(%ebx,%ecx,8)
        	orl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orl	$2063514302, 69
        	orl	$0x7afebabe,0x45

// CHECK: 	orl	$2063514302, 32493
        	orl	$0x7afebabe,0x7eed

// CHECK: 	orl	$2063514302, 3133065982
        	orl	$0x7afebabe,0xbabecafe

// CHECK: 	orl	$2063514302, 305419896
        	orl	$0x7afebabe,0x12345678

// CHECK: 	orl	$324478056, 3735928559(%ebx,%ecx,8)
        	orl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	orl	$324478056, 69
        	orl	$0x13572468,0x45

// CHECK: 	orl	$324478056, 32493
        	orl	$0x13572468,0x7eed

// CHECK: 	orl	$324478056, 3133065982
        	orl	$0x13572468,0xbabecafe

// CHECK: 	orl	$324478056, 305419896
        	orl	$0x13572468,0x12345678

// CHECK: 	xorb	$254, 3735928559(%ebx,%ecx,8)
        	xorb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorb	$254, 69
        	xorb	$0xfe,0x45

// CHECK: 	xorb	$254, 32493
        	xorb	$0xfe,0x7eed

// CHECK: 	xorb	$254, 3133065982
        	xorb	$0xfe,0xbabecafe

// CHECK: 	xorb	$254, 305419896
        	xorb	$0xfe,0x12345678

// CHECK: 	xorb	$127, 3735928559(%ebx,%ecx,8)
        	xorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorb	$127, 69
        	xorb	$0x7f,0x45

// CHECK: 	xorb	$127, 32493
        	xorb	$0x7f,0x7eed

// CHECK: 	xorb	$127, 3133065982
        	xorb	$0x7f,0xbabecafe

// CHECK: 	xorb	$127, 305419896
        	xorb	$0x7f,0x12345678

// CHECK: 	xorw	$31438, 3735928559(%ebx,%ecx,8)
        	xorw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorw	$31438, 69
        	xorw	$0x7ace,0x45

// CHECK: 	xorw	$31438, 32493
        	xorw	$0x7ace,0x7eed

// CHECK: 	xorw	$31438, 3133065982
        	xorw	$0x7ace,0xbabecafe

// CHECK: 	xorw	$31438, 305419896
        	xorw	$0x7ace,0x12345678

// CHECK: 	xorl	$2063514302, 3735928559(%ebx,%ecx,8)
        	xorl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorl	$2063514302, 69
        	xorl	$0x7afebabe,0x45

// CHECK: 	xorl	$2063514302, 32493
        	xorl	$0x7afebabe,0x7eed

// CHECK: 	xorl	$2063514302, 3133065982
        	xorl	$0x7afebabe,0xbabecafe

// CHECK: 	xorl	$2063514302, 305419896
        	xorl	$0x7afebabe,0x12345678

// CHECK: 	xorl	$324478056, 3735928559(%ebx,%ecx,8)
        	xorl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	xorl	$324478056, 69
        	xorl	$0x13572468,0x45

// CHECK: 	xorl	$324478056, 32493
        	xorl	$0x13572468,0x7eed

// CHECK: 	xorl	$324478056, 3133065982
        	xorl	$0x13572468,0xbabecafe

// CHECK: 	xorl	$324478056, 305419896
        	xorl	$0x13572468,0x12345678

// CHECK: 	adcb	$254, 3735928559(%ebx,%ecx,8)
        	adcb	$0xfe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcb	$254, 69
        	adcb	$0xfe,0x45

// CHECK: 	adcb	$254, 32493
        	adcb	$0xfe,0x7eed

// CHECK: 	adcb	$254, 3133065982
        	adcb	$0xfe,0xbabecafe

// CHECK: 	adcb	$254, 305419896
        	adcb	$0xfe,0x12345678

// CHECK: 	adcb	$127, 3735928559(%ebx,%ecx,8)
        	adcb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcb	$127, 69
        	adcb	$0x7f,0x45

// CHECK: 	adcb	$127, 32493
        	adcb	$0x7f,0x7eed

// CHECK: 	adcb	$127, 3133065982
        	adcb	$0x7f,0xbabecafe

// CHECK: 	adcb	$127, 305419896
        	adcb	$0x7f,0x12345678

// CHECK: 	adcw	$31438, 3735928559(%ebx,%ecx,8)
        	adcw	$0x7ace,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcw	$31438, 69
        	adcw	$0x7ace,0x45

// CHECK: 	adcw	$31438, 32493
        	adcw	$0x7ace,0x7eed

// CHECK: 	adcw	$31438, 3133065982
        	adcw	$0x7ace,0xbabecafe

// CHECK: 	adcw	$31438, 305419896
        	adcw	$0x7ace,0x12345678

// CHECK: 	adcl	$2063514302, 3735928559(%ebx,%ecx,8)
        	adcl	$0x7afebabe,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcl	$2063514302, 69
        	adcl	$0x7afebabe,0x45

// CHECK: 	adcl	$2063514302, 32493
        	adcl	$0x7afebabe,0x7eed

// CHECK: 	adcl	$2063514302, 3133065982
        	adcl	$0x7afebabe,0xbabecafe

// CHECK: 	adcl	$2063514302, 305419896
        	adcl	$0x7afebabe,0x12345678

// CHECK: 	adcl	$324478056, 3735928559(%ebx,%ecx,8)
        	adcl	$0x13572468,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	adcl	$324478056, 69
        	adcl	$0x13572468,0x45

// CHECK: 	adcl	$324478056, 32493
        	adcl	$0x13572468,0x7eed

// CHECK: 	adcl	$324478056, 3133065982
        	adcl	$0x13572468,0xbabecafe

// CHECK: 	adcl	$324478056, 305419896
        	adcl	$0x13572468,0x12345678

// CHECK: 	negl	3735928559(%ebx,%ecx,8)
        	negl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	negw	32493
        	negw	0x7eed

// CHECK: 	negl	3133065982
        	negl	0xbabecafe

// CHECK: 	negl	305419896
        	negl	0x12345678

// CHECK: 	notl	3735928559(%ebx,%ecx,8)
        	notl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	notw	32493
        	notw	0x7eed

// CHECK: 	notl	3133065982
        	notl	0xbabecafe

// CHECK: 	notl	305419896
        	notl	0x12345678

// CHECK: 	cbtw
        	cbtw

// CHECK: 	cwtl
        	cwtl

// CHECK: 	cwtd
        	cwtd

// CHECK: 	cltd
        	cltd

// CHECK: 	mull	3735928559(%ebx,%ecx,8)
        	mull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	mulw	32493
        	mulw	0x7eed

// CHECK: 	mull	3133065982
        	mull	0xbabecafe

// CHECK: 	mull	305419896
        	mull	0x12345678

// CHECK: 	imull	3735928559(%ebx,%ecx,8)
        	imull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	imulw	32493
        	imulw	0x7eed

// CHECK: 	imull	3133065982
        	imull	0xbabecafe

// CHECK: 	imull	305419896
        	imull	0x12345678

// CHECK: 	divl	3735928559(%ebx,%ecx,8)
        	divl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	divw	32493
        	divw	0x7eed

// CHECK: 	divl	3133065982
        	divl	0xbabecafe

// CHECK: 	divl	305419896
        	divl	0x12345678

// CHECK: 	idivl	3735928559(%ebx,%ecx,8)
        	idivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	idivw	32493
        	idivw	0x7eed

// CHECK: 	idivl	3133065982
        	idivl	0xbabecafe

// CHECK: 	idivl	305419896
        	idivl	0x12345678

// CHECK: 	roll	$0, 3735928559(%ebx,%ecx,8)
        	roll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	roll	$0, 69
        	roll	$0,0x45

// CHECK: 	roll	$0, 32493
        	roll	$0,0x7eed

// CHECK: 	roll	$0, 3133065982
        	roll	$0,0xbabecafe

// CHECK: 	roll	$0, 305419896
        	roll	$0,0x12345678

// CHECK: 	rolb	$127, 3735928559(%ebx,%ecx,8)
        	rolb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rolb	$127, 69
        	rolb	$0x7f,0x45

// CHECK: 	rolb	$127, 32493
        	rolb	$0x7f,0x7eed

// CHECK: 	rolb	$127, 3133065982
        	rolb	$0x7f,0xbabecafe

// CHECK: 	rolb	$127, 305419896
        	rolb	$0x7f,0x12345678

// CHECK: 	roll	3735928559(%ebx,%ecx,8)
        	roll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rolw	32493
        	rolw	0x7eed

// CHECK: 	roll	3133065982
        	roll	0xbabecafe

// CHECK: 	roll	305419896
        	roll	0x12345678

// CHECK: 	rorl	$0, 3735928559(%ebx,%ecx,8)
        	rorl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorl	$0, 69
        	rorl	$0,0x45

// CHECK: 	rorl	$0, 32493
        	rorl	$0,0x7eed

// CHECK: 	rorl	$0, 3133065982
        	rorl	$0,0xbabecafe

// CHECK: 	rorl	$0, 305419896
        	rorl	$0,0x12345678

// CHECK: 	rorb	$127, 3735928559(%ebx,%ecx,8)
        	rorb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorb	$127, 69
        	rorb	$0x7f,0x45

// CHECK: 	rorb	$127, 32493
        	rorb	$0x7f,0x7eed

// CHECK: 	rorb	$127, 3133065982
        	rorb	$0x7f,0xbabecafe

// CHECK: 	rorb	$127, 305419896
        	rorb	$0x7f,0x12345678

// CHECK: 	rorl	3735928559(%ebx,%ecx,8)
        	rorl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rorw	32493
        	rorw	0x7eed

// CHECK: 	rorl	3133065982
        	rorl	0xbabecafe

// CHECK: 	rorl	305419896
        	rorl	0x12345678

// CHECK: 	rcll	$0, 3735928559(%ebx,%ecx,8)
        	rcll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rcll	$0, 69
        	rcll	$0,0x45

// CHECK: 	rcll	$0, 32493
        	rcll	$0,0x7eed

// CHECK: 	rcll	$0, 3133065982
        	rcll	$0,0xbabecafe

// CHECK: 	rcll	$0, 305419896
        	rcll	$0,0x12345678

// CHECK: 	rclb	$127, 3735928559(%ebx,%ecx,8)
        	rclb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rclb	$127, 69
        	rclb	$0x7f,0x45

// CHECK: 	rclb	$127, 32493
        	rclb	$0x7f,0x7eed

// CHECK: 	rclb	$127, 3133065982
        	rclb	$0x7f,0xbabecafe

// CHECK: 	rclb	$127, 305419896
        	rclb	$0x7f,0x12345678

// CHECK: 	rcrl	$0, 3735928559(%ebx,%ecx,8)
        	rcrl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rcrl	$0, 69
        	rcrl	$0,0x45

// CHECK: 	rcrl	$0, 32493
        	rcrl	$0,0x7eed

// CHECK: 	rcrl	$0, 3133065982
        	rcrl	$0,0xbabecafe

// CHECK: 	rcrl	$0, 305419896
        	rcrl	$0,0x12345678

// CHECK: 	rcrb	$127, 3735928559(%ebx,%ecx,8)
        	rcrb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	rcrb	$127, 69
        	rcrb	$0x7f,0x45

// CHECK: 	rcrb	$127, 32493
        	rcrb	$0x7f,0x7eed

// CHECK: 	rcrb	$127, 3133065982
        	rcrb	$0x7f,0xbabecafe

// CHECK: 	rcrb	$127, 305419896
        	rcrb	$0x7f,0x12345678

// CHECK: 	shll	$0, 3735928559(%ebx,%ecx,8)
        	sall	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shll	$0, 69
        	sall	$0,0x45

// CHECK: 	shll	$0, 32493
        	sall	$0,0x7eed

// CHECK: 	shll	$0, 3133065982
        	sall	$0,0xbabecafe

// CHECK: 	shll	$0, 305419896
        	sall	$0,0x12345678

// CHECK: 	shlb	$127, 3735928559(%ebx,%ecx,8)
        	salb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shlb	$127, 69
        	salb	$0x7f,0x45

// CHECK: 	shlb	$127, 32493
        	salb	$0x7f,0x7eed

// CHECK: 	shlb	$127, 3133065982
        	salb	$0x7f,0xbabecafe

// CHECK: 	shlb	$127, 305419896
        	salb	$0x7f,0x12345678

// CHECK: 	shll	3735928559(%ebx,%ecx,8)
        	sall	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shlw	32493
        	salw	0x7eed

// CHECK: 	shll	3133065982
        	sall	0xbabecafe

// CHECK: 	shll	305419896
        	sall	0x12345678

// CHECK: 	shll	$0, 3735928559(%ebx,%ecx,8)
        	shll	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shll	$0, 69
        	shll	$0,0x45

// CHECK: 	shll	$0, 32493
        	shll	$0,0x7eed

// CHECK: 	shll	$0, 3133065982
        	shll	$0,0xbabecafe

// CHECK: 	shll	$0, 305419896
        	shll	$0,0x12345678

// CHECK: 	shlb	$127, 3735928559(%ebx,%ecx,8)
        	shlb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shlb	$127, 69
        	shlb	$0x7f,0x45

// CHECK: 	shlb	$127, 32493
        	shlb	$0x7f,0x7eed

// CHECK: 	shlb	$127, 3133065982
        	shlb	$0x7f,0xbabecafe

// CHECK: 	shlb	$127, 305419896
        	shlb	$0x7f,0x12345678

// CHECK: 	shll	3735928559(%ebx,%ecx,8)
        	shll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shlw	32493
        	shlw	0x7eed

// CHECK: 	shll	3133065982
        	shll	0xbabecafe

// CHECK: 	shll	305419896
        	shll	0x12345678

// CHECK: 	shrl	$0, 3735928559(%ebx,%ecx,8)
        	shrl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrl	$0, 69
        	shrl	$0,0x45

// CHECK: 	shrl	$0, 32493
        	shrl	$0,0x7eed

// CHECK: 	shrl	$0, 3133065982
        	shrl	$0,0xbabecafe

// CHECK: 	shrl	$0, 305419896
        	shrl	$0,0x12345678

// CHECK: 	shrb	$127, 3735928559(%ebx,%ecx,8)
        	shrb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrb	$127, 69
        	shrb	$0x7f,0x45

// CHECK: 	shrb	$127, 32493
        	shrb	$0x7f,0x7eed

// CHECK: 	shrb	$127, 3133065982
        	shrb	$0x7f,0xbabecafe

// CHECK: 	shrb	$127, 305419896
        	shrb	$0x7f,0x12345678

// CHECK: 	shrl	3735928559(%ebx,%ecx,8)
        	shrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	shrw	32493
        	shrw	0x7eed

// CHECK: 	shrl	3133065982
        	shrl	0xbabecafe

// CHECK: 	shrl	305419896
        	shrl	0x12345678

// CHECK: 	sarl	$0, 3735928559(%ebx,%ecx,8)
        	sarl	$0,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarl	$0, 69
        	sarl	$0,0x45

// CHECK: 	sarl	$0, 32493
        	sarl	$0,0x7eed

// CHECK: 	sarl	$0, 3133065982
        	sarl	$0,0xbabecafe

// CHECK: 	sarl	$0, 305419896
        	sarl	$0,0x12345678

// CHECK: 	sarb	$127, 3735928559(%ebx,%ecx,8)
        	sarb	$0x7f,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarb	$127, 69
        	sarb	$0x7f,0x45

// CHECK: 	sarb	$127, 32493
        	sarb	$0x7f,0x7eed

// CHECK: 	sarb	$127, 3133065982
        	sarb	$0x7f,0xbabecafe

// CHECK: 	sarb	$127, 305419896
        	sarb	$0x7f,0x12345678

// CHECK: 	sarl	3735928559(%ebx,%ecx,8)
        	sarl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sarw	32493
        	sarw	0x7eed

// CHECK: 	sarl	3133065982
        	sarl	0xbabecafe

// CHECK: 	sarl	305419896
        	sarl	0x12345678

// CHECK: 	calll	3133065982
        	calll	0xbabecafe

// CHECK: 	calll	*3735928559(%ebx,%ecx,8)
        	calll	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	calll	3133065982
        	calll	0xbabecafe

// CHECK: 	calll	305419896
        	calll	0x12345678

// CHECK: 	calll	*3135175374
        	call	*0xbadeface

// CHECK: 	calll	*3735928559(%ebx,%ecx,8)
        	call	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	calll	32493
        	call	0x7eed

// CHECK: 	calll	3133065982
        	call	0xbabecafe

// CHECK: 	calll	305419896
        	call	0x12345678

// CHECK: 	calll	*3135175374
        	call	*0xbadeface

// CHECK: 	lcallw	*32493
        	lcallw	*0x7eed

// CHECK: 	jmp	32493
        	jmp	0x7eed

// CHECK: 	jmp	3133065982
        	jmp	0xbabecafe

// CHECK: 	jmp	305419896
        	jmp	0x12345678

// CHECK: 	jmp	-77129852792157442
        	jmp	0xfeedfacebabecafe

// CHECK: 	jmpl	*3735928559(%ebx,%ecx,8)
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	jmp	32493
        	jmp	0x7eed

// CHECK: 	jmp	3133065982
        	jmp	0xbabecafe

// CHECK: 	jmp	305419896
        	jmp	0x12345678

// CHECK: 	jmpl	*3135175374
        	jmp	*0xbadeface

// CHECK: 	jmpl	*3735928559(%ebx,%ecx,8)
        	jmp	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	jmp	32493
        	jmp	0x7eed

// CHECK: 	jmp	3133065982
        	jmp	0xbabecafe

// CHECK: 	jmp	305419896
        	jmp	0x12345678

// CHECK: 	jmpl	*3135175374
        	jmp	*0xbadeface

// CHECK: 	ljmpl	*3735928559(%ebx,%ecx,8)
        	ljmpl	*0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ljmpw	*32493
        	ljmpw	*0x7eed

// CHECK: 	ljmpl	*3133065982
        	ljmpl	*0xbabecafe

// CHECK: 	ljmpl	*305419896
        	ljmpl	*0x12345678

// CHECK: 	ret
        	ret

// CHECK: 	lret
        	lret

// CHECK: 	enter	$31438, $127
        	enter	$0x7ace,$0x7f

// CHECK: 	leave
        	leave

// CHECK: 	jo	32493
        	jo	0x7eed

// CHECK: 	jo	3133065982
        	jo	0xbabecafe

// CHECK: 	jo	305419896
        	jo	0x12345678

// CHECK: 	jo	-77129852792157442
        	jo	0xfeedfacebabecafe

// CHECK: 	jno	32493
        	jno	0x7eed

// CHECK: 	jno	3133065982
        	jno	0xbabecafe

// CHECK: 	jno	305419896
        	jno	0x12345678

// CHECK: 	jno	-77129852792157442
        	jno	0xfeedfacebabecafe

// CHECK: 	jb	32493
        	jb	0x7eed

// CHECK: 	jb	3133065982
        	jb	0xbabecafe

// CHECK: 	jb	305419896
        	jb	0x12345678

// CHECK: 	jb	-77129852792157442
        	jb	0xfeedfacebabecafe

// CHECK: 	jae	32493
        	jae	0x7eed

// CHECK: 	jae	3133065982
        	jae	0xbabecafe

// CHECK: 	jae	305419896
        	jae	0x12345678

// CHECK: 	jae	-77129852792157442
        	jae	0xfeedfacebabecafe

// CHECK: 	je	32493
        	je	0x7eed

// CHECK: 	je	3133065982
        	je	0xbabecafe

// CHECK: 	je	305419896
        	je	0x12345678

// CHECK: 	je	-77129852792157442
        	je	0xfeedfacebabecafe

// CHECK: 	jne	32493
        	jne	0x7eed

// CHECK: 	jne	3133065982
        	jne	0xbabecafe

// CHECK: 	jne	305419896
        	jne	0x12345678

// CHECK: 	jne	-77129852792157442
        	jne	0xfeedfacebabecafe

// CHECK: 	jbe	32493
        	jbe	0x7eed

// CHECK: 	jbe	3133065982
        	jbe	0xbabecafe

// CHECK: 	jbe	305419896
        	jbe	0x12345678

// CHECK: 	jbe	-77129852792157442
        	jbe	0xfeedfacebabecafe

// CHECK: 	ja	32493
        	ja	0x7eed

// CHECK: 	ja	3133065982
        	ja	0xbabecafe

// CHECK: 	ja	305419896
        	ja	0x12345678

// CHECK: 	ja	-77129852792157442
        	ja	0xfeedfacebabecafe

// CHECK: 	js	32493
        	js	0x7eed

// CHECK: 	js	3133065982
        	js	0xbabecafe

// CHECK: 	js	305419896
        	js	0x12345678

// CHECK: 	js	-77129852792157442
        	js	0xfeedfacebabecafe

// CHECK: 	jns	32493
        	jns	0x7eed

// CHECK: 	jns	3133065982
        	jns	0xbabecafe

// CHECK: 	jns	305419896
        	jns	0x12345678

// CHECK: 	jns	-77129852792157442
        	jns	0xfeedfacebabecafe

// CHECK: 	jp	32493
        	jp	0x7eed

// CHECK: 	jp	3133065982
        	jp	0xbabecafe

// CHECK: 	jp	305419896
        	jp	0x12345678

// CHECK: 	jp	-77129852792157442
        	jp	0xfeedfacebabecafe

// CHECK: 	jnp	32493
        	jnp	0x7eed

// CHECK: 	jnp	3133065982
        	jnp	0xbabecafe

// CHECK: 	jnp	305419896
        	jnp	0x12345678

// CHECK: 	jnp	-77129852792157442
        	jnp	0xfeedfacebabecafe

// CHECK: 	jl	32493
        	jl	0x7eed

// CHECK: 	jl	3133065982
        	jl	0xbabecafe

// CHECK: 	jl	305419896
        	jl	0x12345678

// CHECK: 	jl	-77129852792157442
        	jl	0xfeedfacebabecafe

// CHECK: 	jge	32493
        	jge	0x7eed

// CHECK: 	jge	3133065982
        	jge	0xbabecafe

// CHECK: 	jge	305419896
        	jge	0x12345678

// CHECK: 	jge	-77129852792157442
        	jge	0xfeedfacebabecafe

// CHECK: 	jle	32493
        	jle	0x7eed

// CHECK: 	jle	3133065982
        	jle	0xbabecafe

// CHECK: 	jle	305419896
        	jle	0x12345678

// CHECK: 	jle	-77129852792157442
        	jle	0xfeedfacebabecafe

// CHECK: 	jg	32493
        	jg	0x7eed

// CHECK: 	jg	3133065982
        	jg	0xbabecafe

// CHECK: 	jg	305419896
        	jg	0x12345678

// CHECK: 	jg	-77129852792157442
        	jg	0xfeedfacebabecafe

// CHECK: 	seto	%bl
        	seto	%bl

// CHECK: 	seto	3735928559(%ebx,%ecx,8)
        	seto	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	seto	32493
        	seto	0x7eed

// CHECK: 	seto	3133065982
        	seto	0xbabecafe

// CHECK: 	seto	305419896
        	seto	0x12345678

// CHECK: 	setno	%bl
        	setno	%bl

// CHECK: 	setno	3735928559(%ebx,%ecx,8)
        	setno	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setno	32493
        	setno	0x7eed

// CHECK: 	setno	3133065982
        	setno	0xbabecafe

// CHECK: 	setno	305419896
        	setno	0x12345678

// CHECK: 	setb	%bl
        	setb	%bl

// CHECK: 	setb	3735928559(%ebx,%ecx,8)
        	setb	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setb	32493
        	setb	0x7eed

// CHECK: 	setb	3133065982
        	setb	0xbabecafe

// CHECK: 	setb	305419896
        	setb	0x12345678

// CHECK: 	setae	%bl
        	setae	%bl

// CHECK: 	setae	3735928559(%ebx,%ecx,8)
        	setae	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setae	32493
        	setae	0x7eed

// CHECK: 	setae	3133065982
        	setae	0xbabecafe

// CHECK: 	setae	305419896
        	setae	0x12345678

// CHECK: 	sete	%bl
        	sete	%bl

// CHECK: 	sete	3735928559(%ebx,%ecx,8)
        	sete	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sete	32493
        	sete	0x7eed

// CHECK: 	sete	3133065982
        	sete	0xbabecafe

// CHECK: 	sete	305419896
        	sete	0x12345678

// CHECK: 	setne	%bl
        	setne	%bl

// CHECK: 	setne	3735928559(%ebx,%ecx,8)
        	setne	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setne	32493
        	setne	0x7eed

// CHECK: 	setne	3133065982
        	setne	0xbabecafe

// CHECK: 	setne	305419896
        	setne	0x12345678

// CHECK: 	setbe	%bl
        	setbe	%bl

// CHECK: 	setbe	3735928559(%ebx,%ecx,8)
        	setbe	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setbe	32493
        	setbe	0x7eed

// CHECK: 	setbe	3133065982
        	setbe	0xbabecafe

// CHECK: 	setbe	305419896
        	setbe	0x12345678

// CHECK: 	seta	%bl
        	seta	%bl

// CHECK: 	seta	3735928559(%ebx,%ecx,8)
        	seta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	seta	32493
        	seta	0x7eed

// CHECK: 	seta	3133065982
        	seta	0xbabecafe

// CHECK: 	seta	305419896
        	seta	0x12345678

// CHECK: 	sets	%bl
        	sets	%bl

// CHECK: 	sets	3735928559(%ebx,%ecx,8)
        	sets	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	sets	32493
        	sets	0x7eed

// CHECK: 	sets	3133065982
        	sets	0xbabecafe

// CHECK: 	sets	305419896
        	sets	0x12345678

// CHECK: 	setns	%bl
        	setns	%bl

// CHECK: 	setns	3735928559(%ebx,%ecx,8)
        	setns	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setns	32493
        	setns	0x7eed

// CHECK: 	setns	3133065982
        	setns	0xbabecafe

// CHECK: 	setns	305419896
        	setns	0x12345678

// CHECK: 	setp	%bl
        	setp	%bl

// CHECK: 	setp	3735928559(%ebx,%ecx,8)
        	setp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setp	32493
        	setp	0x7eed

// CHECK: 	setp	3133065982
        	setp	0xbabecafe

// CHECK: 	setp	305419896
        	setp	0x12345678

// CHECK: 	setnp	%bl
        	setnp	%bl

// CHECK: 	setnp	3735928559(%ebx,%ecx,8)
        	setnp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setnp	32493
        	setnp	0x7eed

// CHECK: 	setnp	3133065982
        	setnp	0xbabecafe

// CHECK: 	setnp	305419896
        	setnp	0x12345678

// CHECK: 	setl	%bl
        	setl	%bl

// CHECK: 	setl	3735928559(%ebx,%ecx,8)
        	setl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setl	32493
        	setl	0x7eed

// CHECK: 	setl	3133065982
        	setl	0xbabecafe

// CHECK: 	setl	305419896
        	setl	0x12345678

// CHECK: 	setge	%bl
        	setge	%bl

// CHECK: 	setge	3735928559(%ebx,%ecx,8)
        	setge	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setge	32493
        	setge	0x7eed

// CHECK: 	setge	3133065982
        	setge	0xbabecafe

// CHECK: 	setge	305419896
        	setge	0x12345678

// CHECK: 	setle	%bl
        	setle	%bl

// CHECK: 	setle	3735928559(%ebx,%ecx,8)
        	setle	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setle	32493
        	setle	0x7eed

// CHECK: 	setle	3133065982
        	setle	0xbabecafe

// CHECK: 	setle	305419896
        	setle	0x12345678

// CHECK: 	setg	%bl
        	setg	%bl

// CHECK: 	setg	3735928559(%ebx,%ecx,8)
        	setg	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	setg	32493
        	setg	0x7eed

// CHECK: 	setg	3133065982
        	setg	0xbabecafe

// CHECK: 	setg	305419896
        	setg	0x12345678

// CHECK: 	int	$127
        	int	$0x7f

// CHECK: 	rsm
        	rsm

// CHECK: 	hlt
        	hlt

// CHECK: 	nopl	3735928559(%ebx,%ecx,8)
        	nopl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	nopw	32493
        	nopw	0x7eed

// CHECK: 	nopl	3133065982
        	nopl	0xbabecafe

// CHECK: 	nopl	305419896
        	nopl	0x12345678

// CHECK: 	nop
        	nop

// CHECK: 	lldtw	32493
        	lldtw	0x7eed

// CHECK: 	lmsww	32493
        	lmsww	0x7eed

// CHECK: 	ltrw	32493
        	ltrw	0x7eed

// CHECK: 	sldtw	32493
        	sldtw	0x7eed

// CHECK: 	smsww	32493
        	smsww	0x7eed

// CHECK: 	strw	32493
        	strw	0x7eed

// CHECK: 	verr	%bx
        	verr	%bx

// CHECK: 	verr	3735928559(%ebx,%ecx,8)
        	verr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	verr	3133065982
        	verr	0xbabecafe

// CHECK: 	verr	305419896
        	verr	0x12345678

// CHECK: 	verw	%bx
        	verw	%bx

// CHECK: 	verw	3735928559(%ebx,%ecx,8)
        	verw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	verw	3133065982
        	verw	0xbabecafe

// CHECK: 	verw	305419896
        	verw	0x12345678

// CHECK: 	fld	%st(2)
        	fld	%st(2)

// CHECK: 	fldl	3735928559(%ebx,%ecx,8)
        	fldl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fldl	3133065982
        	fldl	0xbabecafe

// CHECK: 	fldl	305419896
        	fldl	0x12345678

// CHECK: 	fld	%st(2)
        	fld	%st(2)

// CHECK: 	fildl	3735928559(%ebx,%ecx,8)
        	fildl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fildl	3133065982
        	fildl	0xbabecafe

// CHECK: 	fildl	305419896
        	fildl	0x12345678

// CHECK: 	fildll	3735928559(%ebx,%ecx,8)
        	fildll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fildll	32493
        	fildll	0x7eed

// CHECK: 	fildll	3133065982
        	fildll	0xbabecafe

// CHECK: 	fildll	305419896
        	fildll	0x12345678

// CHECK: 	fldt	3735928559(%ebx,%ecx,8)
        	fldt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fldt	32493
        	fldt	0x7eed

// CHECK: 	fldt	3133065982
        	fldt	0xbabecafe

// CHECK: 	fldt	305419896
        	fldt	0x12345678

// CHECK: 	fbld	3735928559(%ebx,%ecx,8)
        	fbld	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fbld	32493
        	fbld	0x7eed

// CHECK: 	fbld	3133065982
        	fbld	0xbabecafe

// CHECK: 	fbld	305419896
        	fbld	0x12345678

// CHECK: 	fst	%st(2)
        	fst	%st(2)

// CHECK: 	fstl	3735928559(%ebx,%ecx,8)
        	fstl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstl	3133065982
        	fstl	0xbabecafe

// CHECK: 	fstl	305419896
        	fstl	0x12345678

// CHECK: 	fst	%st(2)
        	fst	%st(2)

// CHECK: 	fistl	3735928559(%ebx,%ecx,8)
        	fistl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistl	3133065982
        	fistl	0xbabecafe

// CHECK: 	fistl	305419896
        	fistl	0x12345678

// CHECK: 	fstp	%st(2)
        	fstp	%st(2)

// CHECK: 	fstpl	3735928559(%ebx,%ecx,8)
        	fstpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstpl	3133065982
        	fstpl	0xbabecafe

// CHECK: 	fstpl	305419896
        	fstpl	0x12345678

// CHECK: 	fstp	%st(2)
        	fstp	%st(2)

// CHECK: 	fistpl	3735928559(%ebx,%ecx,8)
        	fistpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistpl	3133065982
        	fistpl	0xbabecafe

// CHECK: 	fistpl	305419896
        	fistpl	0x12345678

// CHECK: 	fistpll	3735928559(%ebx,%ecx,8)
        	fistpll	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fistpll	32493
        	fistpll	0x7eed

// CHECK: 	fistpll	3133065982
        	fistpll	0xbabecafe

// CHECK: 	fistpll	305419896
        	fistpll	0x12345678

// CHECK: 	fstpt	3735928559(%ebx,%ecx,8)
        	fstpt	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fstpt	32493
        	fstpt	0x7eed

// CHECK: 	fstpt	3133065982
        	fstpt	0xbabecafe

// CHECK: 	fstpt	305419896
        	fstpt	0x12345678

// CHECK: 	fbstp	3735928559(%ebx,%ecx,8)
        	fbstp	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fbstp	32493
        	fbstp	0x7eed

// CHECK: 	fbstp	3133065982
        	fbstp	0xbabecafe

// CHECK: 	fbstp	305419896
        	fbstp	0x12345678

// CHECK: 	fxch	%st(2)
        	fxch	%st(2)

// CHECK: 	fcom	%st(2)
        	fcom	%st(2)

// CHECK: 	fcoml	3735928559(%ebx,%ecx,8)
        	fcoml	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fcoml	3133065982
        	fcoml	0xbabecafe

// CHECK: 	fcoml	305419896
        	fcoml	0x12345678

// CHECK: 	fcom	%st(2)
        	fcom	%st(2)

// CHECK: 	ficoml	3735928559(%ebx,%ecx,8)
        	ficoml	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ficoml	3133065982
        	ficoml	0xbabecafe

// CHECK: 	ficoml	305419896
        	ficoml	0x12345678

// CHECK: 	fcomp	%st(2)
        	fcomp	%st(2)

// CHECK: 	fcompl	3735928559(%ebx,%ecx,8)
        	fcompl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fcompl	3133065982
        	fcompl	0xbabecafe

// CHECK: 	fcompl	305419896
        	fcompl	0x12345678

// CHECK: 	fcomp	%st(2)
        	fcomp	%st(2)

// CHECK: 	ficompl	3735928559(%ebx,%ecx,8)
        	ficompl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ficompl	3133065982
        	ficompl	0xbabecafe

// CHECK: 	ficompl	305419896
        	ficompl	0x12345678

// CHECK: 	fcompp
        	fcompp

// CHECK: 	fucom	%st(2)
        	fucom	%st(2)

// CHECK: 	fucomp	%st(2)
        	fucomp	%st(2)

// CHECK: 	fucompp
        	fucompp

// CHECK: 	ftst
        	ftst

// CHECK: 	fxam
        	fxam

// CHECK: 	fld1
        	fld1

// CHECK: 	fldl2t
        	fldl2t

// CHECK: 	fldl2e
        	fldl2e

// CHECK: 	fldpi
        	fldpi

// CHECK: 	fldlg2
        	fldlg2

// CHECK: 	fldln2
        	fldln2

// CHECK: 	fldz
        	fldz

// CHECK: 	fadd	%st(2)
        	fadd	%st(2)

// CHECK: 	faddl	3735928559(%ebx,%ecx,8)
        	faddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	faddl	3133065982
        	faddl	0xbabecafe

// CHECK: 	faddl	305419896
        	faddl	0x12345678

// CHECK: 	fiaddl	3735928559(%ebx,%ecx,8)
        	fiaddl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fiaddl	3133065982
        	fiaddl	0xbabecafe

// CHECK: 	fiaddl	305419896
        	fiaddl	0x12345678

// CHECK: 	faddp	%st(2)
        	faddp	%st(2)

// CHECK: 	fsub	%st(2)
        	fsub	%st(2)

// CHECK: 	fsubl	3735928559(%ebx,%ecx,8)
        	fsubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fsubl	3133065982
        	fsubl	0xbabecafe

// CHECK: 	fsubl	305419896
        	fsubl	0x12345678

// CHECK: 	fisubl	3735928559(%ebx,%ecx,8)
        	fisubl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fisubl	3133065982
        	fisubl	0xbabecafe

// CHECK: 	fisubl	305419896
        	fisubl	0x12345678

// CHECK: 	fsubp	%st(2)
        	fsubp	%st(2)

// CHECK: 	fsubr	%st(2)
        	fsubr	%st(2)

// CHECK: 	fsubrl	3735928559(%ebx,%ecx,8)
        	fsubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fsubrl	3133065982
        	fsubrl	0xbabecafe

// CHECK: 	fsubrl	305419896
        	fsubrl	0x12345678

// CHECK: 	fisubrl	3735928559(%ebx,%ecx,8)
        	fisubrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fisubrl	3133065982
        	fisubrl	0xbabecafe

// CHECK: 	fisubrl	305419896
        	fisubrl	0x12345678

// CHECK: 	fsubrp	%st(2)
        	fsubrp	%st(2)

// CHECK: 	fmul	%st(2)
        	fmul	%st(2)

// CHECK: 	fmull	3735928559(%ebx,%ecx,8)
        	fmull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fmull	3133065982
        	fmull	0xbabecafe

// CHECK: 	fmull	305419896
        	fmull	0x12345678

// CHECK: 	fimull	3735928559(%ebx,%ecx,8)
        	fimull	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fimull	3133065982
        	fimull	0xbabecafe

// CHECK: 	fimull	305419896
        	fimull	0x12345678

// CHECK: 	fmulp	%st(2)
        	fmulp	%st(2)

// CHECK: 	fdiv	%st(2)
        	fdiv	%st(2)

// CHECK: 	fdivl	3735928559(%ebx,%ecx,8)
        	fdivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fdivl	3133065982
        	fdivl	0xbabecafe

// CHECK: 	fdivl	305419896
        	fdivl	0x12345678

// CHECK: 	fidivl	3735928559(%ebx,%ecx,8)
        	fidivl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fidivl	3133065982
        	fidivl	0xbabecafe

// CHECK: 	fidivl	305419896
        	fidivl	0x12345678

// CHECK: 	fdivp	%st(2)
        	fdivp	%st(2)

// CHECK: 	fdivr	%st(2)
        	fdivr	%st(2)

// CHECK: 	fdivrl	3735928559(%ebx,%ecx,8)
        	fdivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fdivrl	3133065982
        	fdivrl	0xbabecafe

// CHECK: 	fdivrl	305419896
        	fdivrl	0x12345678

// CHECK: 	fidivrl	3735928559(%ebx,%ecx,8)
        	fidivrl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fidivrl	3133065982
        	fidivrl	0xbabecafe

// CHECK: 	fidivrl	305419896
        	fidivrl	0x12345678

// CHECK: 	fdivrp	%st(2)
        	fdivrp	%st(2)

// CHECK: 	f2xm1
        	f2xm1

// CHECK: 	fyl2x
        	fyl2x

// CHECK: 	fptan
        	fptan

// CHECK: 	fpatan
        	fpatan

// CHECK: 	fxtract
        	fxtract

// CHECK: 	fprem1
        	fprem1

// CHECK: 	fdecstp
        	fdecstp

// CHECK: 	fincstp
        	fincstp

// CHECK: 	fprem
        	fprem

// CHECK: 	fyl2xp1
        	fyl2xp1

// CHECK: 	fsqrt
        	fsqrt

// CHECK: 	fsincos
        	fsincos

// CHECK: 	frndint
        	frndint

// CHECK: 	fscale
        	fscale

// CHECK: 	fsin
        	fsin

// CHECK: 	fcos
        	fcos

// CHECK: 	fchs
        	fchs

// CHECK: 	fabs
        	fabs

// CHECK: 	fninit
        	fninit

// CHECK: 	fldcw	3735928559(%ebx,%ecx,8)
        	fldcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fldcw	3133065982
        	fldcw	0xbabecafe

// CHECK: 	fldcw	305419896
        	fldcw	0x12345678

// CHECK: 	fnstcw	3735928559(%ebx,%ecx,8)
        	fnstcw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fnstcw	3133065982
        	fnstcw	0xbabecafe

// CHECK: 	fnstcw	305419896
        	fnstcw	0x12345678

// CHECK: 	fnstsw	3735928559(%ebx,%ecx,8)
        	fnstsw	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fnstsw	3133065982
        	fnstsw	0xbabecafe

// CHECK: 	fnstsw	305419896
        	fnstsw	0x12345678

// CHECK: 	fnclex
        	fnclex

// CHECK: 	fnstenv	32493
        	fnstenv	0x7eed

// CHECK: 	fldenv	32493
        	fldenv	0x7eed

// CHECK: 	fnsave	32493
        	fnsave	0x7eed

// CHECK: 	frstor	32493
        	frstor	0x7eed

// CHECK: 	ffree	%st(2)
        	ffree	%st(2)

// CHECK: 	fnop
        	fnop

// CHECK: 	invd
        	invd

// CHECK: 	wbinvd
        	wbinvd

// CHECK: 	cpuid
        	cpuid

// CHECK: 	wrmsr
        	wrmsr

// CHECK: 	rdtsc
        	rdtsc

// CHECK: 	rdmsr
        	rdmsr

// CHECK: 	cmpxchg8b	3735928559(%ebx,%ecx,8)
        	cmpxchg8b	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	cmpxchg8b	32493
        	cmpxchg8b	0x7eed

// CHECK: 	cmpxchg8b	3133065982
        	cmpxchg8b	0xbabecafe

// CHECK: 	cmpxchg8b	305419896
        	cmpxchg8b	0x12345678

// CHECK: 	sysenter
        	sysenter

// CHECK: 	sysexit
        	sysexit

// CHECK: 	fxsave	3735928559(%ebx,%ecx,8)
        	fxsave	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fxsave	32493
        	fxsave	0x7eed

// CHECK: 	fxsave	3133065982
        	fxsave	0xbabecafe

// CHECK: 	fxsave	305419896
        	fxsave	0x12345678

// CHECK: 	fxrstor	3735928559(%ebx,%ecx,8)
        	fxrstor	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fxrstor	32493
        	fxrstor	0x7eed

// CHECK: 	fxrstor	3133065982
        	fxrstor	0xbabecafe

// CHECK: 	fxrstor	305419896
        	fxrstor	0x12345678

// CHECK: 	rdpmc
        	rdpmc

// CHECK: 	ud2
        	ud2

// CHECK: 	fcmovb	%st(2), %st(0)
        	fcmovb	%st(2),%st

// CHECK: 	fcmove	%st(2), %st(0)
        	fcmove	%st(2),%st

// CHECK: 	fcmovbe	%st(2), %st(0)
        	fcmovbe	%st(2),%st

// CHECK: 	fcmovu	 %st(2), %st(0)
        	fcmovu	%st(2),%st

// CHECK: 	fcmovnb	%st(2), %st(0)
        	fcmovnb	%st(2),%st

// CHECK: 	fcmovne	%st(2), %st(0)
        	fcmovne	%st(2),%st

// CHECK: 	fcmovnbe	%st(2), %st(0)
        	fcmovnbe	%st(2),%st

// CHECK: 	fcmovnu	%st(2), %st(0)
        	fcmovnu	%st(2),%st

// CHECK: 	fcomi	%st(2)
        	fcomi	%st(2),%st

// CHECK: 	fucomi	%st(2)
        	fucomi	%st(2),%st

// CHECK: 	fcompi	%st(2)
        	fcomip	%st(2),%st

// CHECK: 	fucompi	%st(2)
        	fucomip	%st(2),%st

// CHECK: 	movntil	%ecx, 3735928559(%ebx,%ecx,8)
        	movnti	%ecx,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntil	%ecx, 69
        	movntil	%ecx,0x45

// CHECK: 	movntil	%ecx, 32493
        	movnti	%ecx,0x7eed

// CHECK: 	movntil	%ecx, 3133065982
        	movnti	%ecx,0xbabecafe

// CHECK: 	movntil	%ecx, 305419896
        	movnti	%ecx,0x12345678

// CHECK: 	clflush	3735928559(%ebx,%ecx,8)
        	clflush	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	clflush	32493
        	clflush	0x7eed

// CHECK: 	clflush	3133065982
        	clflush	0xbabecafe

// CHECK: 	clflush	305419896
        	clflush	0x12345678

// CHECK: 	pause
        	pause

// CHECK: 	sfence
        	sfence

// CHECK: 	lfence
        	lfence

// CHECK: 	mfence
        	mfence

// CHECK: 	emms
        	emms

// CHECK: 	movd	%ecx, %mm3
        	movd	%ecx,%mm3

// CHECK: 	movd	3735928559(%ebx,%ecx,8), %mm3
        	movd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	movd	69, %mm3
        	movd	0x45,%mm3

// CHECK: 	movd	32493, %mm3
        	movd	0x7eed,%mm3

// CHECK: 	movd	3133065982, %mm3
        	movd	0xbabecafe,%mm3

// CHECK: 	movd	305419896, %mm3
        	movd	0x12345678,%mm3

// CHECK: 	movd	%mm3, %ecx
        	movd	%mm3,%ecx

// CHECK: 	movd	%mm3, 3735928559(%ebx,%ecx,8)
        	movd	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movd	%mm3, 69
        	movd	%mm3,0x45

// CHECK: 	movd	%mm3, 32493
        	movd	%mm3,0x7eed

// CHECK: 	movd	%mm3, 3133065982
        	movd	%mm3,0xbabecafe

// CHECK: 	movd	%mm3, 305419896
        	movd	%mm3,0x12345678

// CHECK: 	movd	%ecx, %xmm5
        	movd	%ecx,%xmm5

// CHECK: 	movd	3735928559(%ebx,%ecx,8), %xmm5
        	movd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movd	69, %xmm5
        	movd	0x45,%xmm5

// CHECK: 	movd	32493, %xmm5
        	movd	0x7eed,%xmm5

// CHECK: 	movd	3133065982, %xmm5
        	movd	0xbabecafe,%xmm5

// CHECK: 	movd	305419896, %xmm5
        	movd	0x12345678,%xmm5

// CHECK: 	movd	%xmm5, %ecx
        	movd	%xmm5,%ecx

// CHECK: 	movd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movd	%xmm5, 69
        	movd	%xmm5,0x45

// CHECK: 	movd	%xmm5, 32493
        	movd	%xmm5,0x7eed

// CHECK: 	movd	%xmm5, 3133065982
        	movd	%xmm5,0xbabecafe

// CHECK: 	movd	%xmm5, 305419896
        	movd	%xmm5,0x12345678

// CHECK: 	movq	3735928559(%ebx,%ecx,8), %mm3
        	movq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	movq	69, %mm3
        	movq	0x45,%mm3

// CHECK: 	movq	32493, %mm3
        	movq	0x7eed,%mm3

// CHECK: 	movq	3133065982, %mm3
        	movq	0xbabecafe,%mm3

// CHECK: 	movq	305419896, %mm3
        	movq	0x12345678,%mm3

// CHECK: 	movq	%mm3, %mm3
        	movq	%mm3,%mm3

// CHECK: 	movq	%mm3, 3735928559(%ebx,%ecx,8)
        	movq	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movq	%mm3, 69
        	movq	%mm3,0x45

// CHECK: 	movq	%mm3, 32493
        	movq	%mm3,0x7eed

// CHECK: 	movq	%mm3, 3133065982
        	movq	%mm3,0xbabecafe

// CHECK: 	movq	%mm3, 305419896
        	movq	%mm3,0x12345678

// CHECK: 	movq	%mm3, %mm3
        	movq	%mm3,%mm3

// CHECK: 	movq	3735928559(%ebx,%ecx,8), %xmm5
        	movq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movq	69, %xmm5
        	movq	0x45,%xmm5

// CHECK: 	movq	32493, %xmm5
        	movq	0x7eed,%xmm5

// CHECK: 	movq	3133065982, %xmm5
        	movq	0xbabecafe,%xmm5

// CHECK: 	movq	305419896, %xmm5
        	movq	0x12345678,%xmm5

// CHECK: 	movq	%xmm5, %xmm5
        	movq	%xmm5,%xmm5

// CHECK: 	movq	%xmm5, 3735928559(%ebx,%ecx,8)
        	movq	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movq	%xmm5, 69
        	movq	%xmm5,0x45

// CHECK: 	movq	%xmm5, 32493
        	movq	%xmm5,0x7eed

// CHECK: 	movq	%xmm5, 3133065982
        	movq	%xmm5,0xbabecafe

// CHECK: 	movq	%xmm5, 305419896
        	movq	%xmm5,0x12345678

// CHECK: 	movq	%xmm5, %xmm5
        	movq	%xmm5,%xmm5

// CHECK: 	packssdw	3735928559(%ebx,%ecx,8), %mm3
        	packssdw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	packssdw	69, %mm3
        	packssdw	0x45,%mm3

// CHECK: 	packssdw	32493, %mm3
        	packssdw	0x7eed,%mm3

// CHECK: 	packssdw	3133065982, %mm3
        	packssdw	0xbabecafe,%mm3

// CHECK: 	packssdw	305419896, %mm3
        	packssdw	0x12345678,%mm3

// CHECK: 	packssdw	%mm3, %mm3
        	packssdw	%mm3,%mm3

// CHECK: 	packssdw	3735928559(%ebx,%ecx,8), %xmm5
        	packssdw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	packssdw	69, %xmm5
        	packssdw	0x45,%xmm5

// CHECK: 	packssdw	32493, %xmm5
        	packssdw	0x7eed,%xmm5

// CHECK: 	packssdw	3133065982, %xmm5
        	packssdw	0xbabecafe,%xmm5

// CHECK: 	packssdw	305419896, %xmm5
        	packssdw	0x12345678,%xmm5

// CHECK: 	packssdw	%xmm5, %xmm5
        	packssdw	%xmm5,%xmm5

// CHECK: 	packsswb	3735928559(%ebx,%ecx,8), %mm3
        	packsswb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	packsswb	69, %mm3
        	packsswb	0x45,%mm3

// CHECK: 	packsswb	32493, %mm3
        	packsswb	0x7eed,%mm3

// CHECK: 	packsswb	3133065982, %mm3
        	packsswb	0xbabecafe,%mm3

// CHECK: 	packsswb	305419896, %mm3
        	packsswb	0x12345678,%mm3

// CHECK: 	packsswb	%mm3, %mm3
        	packsswb	%mm3,%mm3

// CHECK: 	packsswb	3735928559(%ebx,%ecx,8), %xmm5
        	packsswb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	packsswb	69, %xmm5
        	packsswb	0x45,%xmm5

// CHECK: 	packsswb	32493, %xmm5
        	packsswb	0x7eed,%xmm5

// CHECK: 	packsswb	3133065982, %xmm5
        	packsswb	0xbabecafe,%xmm5

// CHECK: 	packsswb	305419896, %xmm5
        	packsswb	0x12345678,%xmm5

// CHECK: 	packsswb	%xmm5, %xmm5
        	packsswb	%xmm5,%xmm5

// CHECK: 	packuswb	3735928559(%ebx,%ecx,8), %mm3
        	packuswb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	packuswb	69, %mm3
        	packuswb	0x45,%mm3

// CHECK: 	packuswb	32493, %mm3
        	packuswb	0x7eed,%mm3

// CHECK: 	packuswb	3133065982, %mm3
        	packuswb	0xbabecafe,%mm3

// CHECK: 	packuswb	305419896, %mm3
        	packuswb	0x12345678,%mm3

// CHECK: 	packuswb	%mm3, %mm3
        	packuswb	%mm3,%mm3

// CHECK: 	packuswb	3735928559(%ebx,%ecx,8), %xmm5
        	packuswb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	packuswb	69, %xmm5
        	packuswb	0x45,%xmm5

// CHECK: 	packuswb	32493, %xmm5
        	packuswb	0x7eed,%xmm5

// CHECK: 	packuswb	3133065982, %xmm5
        	packuswb	0xbabecafe,%xmm5

// CHECK: 	packuswb	305419896, %xmm5
        	packuswb	0x12345678,%xmm5

// CHECK: 	packuswb	%xmm5, %xmm5
        	packuswb	%xmm5,%xmm5

// CHECK: 	paddb	3735928559(%ebx,%ecx,8), %mm3
        	paddb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddb	69, %mm3
        	paddb	0x45,%mm3

// CHECK: 	paddb	32493, %mm3
        	paddb	0x7eed,%mm3

// CHECK: 	paddb	3133065982, %mm3
        	paddb	0xbabecafe,%mm3

// CHECK: 	paddb	305419896, %mm3
        	paddb	0x12345678,%mm3

// CHECK: 	paddb	%mm3, %mm3
        	paddb	%mm3,%mm3

// CHECK: 	paddb	3735928559(%ebx,%ecx,8), %xmm5
        	paddb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddb	69, %xmm5
        	paddb	0x45,%xmm5

// CHECK: 	paddb	32493, %xmm5
        	paddb	0x7eed,%xmm5

// CHECK: 	paddb	3133065982, %xmm5
        	paddb	0xbabecafe,%xmm5

// CHECK: 	paddb	305419896, %xmm5
        	paddb	0x12345678,%xmm5

// CHECK: 	paddb	%xmm5, %xmm5
        	paddb	%xmm5,%xmm5

// CHECK: 	paddw	3735928559(%ebx,%ecx,8), %mm3
        	paddw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddw	69, %mm3
        	paddw	0x45,%mm3

// CHECK: 	paddw	32493, %mm3
        	paddw	0x7eed,%mm3

// CHECK: 	paddw	3133065982, %mm3
        	paddw	0xbabecafe,%mm3

// CHECK: 	paddw	305419896, %mm3
        	paddw	0x12345678,%mm3

// CHECK: 	paddw	%mm3, %mm3
        	paddw	%mm3,%mm3

// CHECK: 	paddw	3735928559(%ebx,%ecx,8), %xmm5
        	paddw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddw	69, %xmm5
        	paddw	0x45,%xmm5

// CHECK: 	paddw	32493, %xmm5
        	paddw	0x7eed,%xmm5

// CHECK: 	paddw	3133065982, %xmm5
        	paddw	0xbabecafe,%xmm5

// CHECK: 	paddw	305419896, %xmm5
        	paddw	0x12345678,%xmm5

// CHECK: 	paddw	%xmm5, %xmm5
        	paddw	%xmm5,%xmm5

// CHECK: 	paddd	3735928559(%ebx,%ecx,8), %mm3
        	paddd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddd	69, %mm3
        	paddd	0x45,%mm3

// CHECK: 	paddd	32493, %mm3
        	paddd	0x7eed,%mm3

// CHECK: 	paddd	3133065982, %mm3
        	paddd	0xbabecafe,%mm3

// CHECK: 	paddd	305419896, %mm3
        	paddd	0x12345678,%mm3

// CHECK: 	paddd	%mm3, %mm3
        	paddd	%mm3,%mm3

// CHECK: 	paddd	3735928559(%ebx,%ecx,8), %xmm5
        	paddd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddd	69, %xmm5
        	paddd	0x45,%xmm5

// CHECK: 	paddd	32493, %xmm5
        	paddd	0x7eed,%xmm5

// CHECK: 	paddd	3133065982, %xmm5
        	paddd	0xbabecafe,%xmm5

// CHECK: 	paddd	305419896, %xmm5
        	paddd	0x12345678,%xmm5

// CHECK: 	paddd	%xmm5, %xmm5
        	paddd	%xmm5,%xmm5

// CHECK: 	paddq	3735928559(%ebx,%ecx,8), %mm3
        	paddq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddq	69, %mm3
        	paddq	0x45,%mm3

// CHECK: 	paddq	32493, %mm3
        	paddq	0x7eed,%mm3

// CHECK: 	paddq	3133065982, %mm3
        	paddq	0xbabecafe,%mm3

// CHECK: 	paddq	305419896, %mm3
        	paddq	0x12345678,%mm3

// CHECK: 	paddq	%mm3, %mm3
        	paddq	%mm3,%mm3

// CHECK: 	paddq	3735928559(%ebx,%ecx,8), %xmm5
        	paddq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddq	69, %xmm5
        	paddq	0x45,%xmm5

// CHECK: 	paddq	32493, %xmm5
        	paddq	0x7eed,%xmm5

// CHECK: 	paddq	3133065982, %xmm5
        	paddq	0xbabecafe,%xmm5

// CHECK: 	paddq	305419896, %xmm5
        	paddq	0x12345678,%xmm5

// CHECK: 	paddq	%xmm5, %xmm5
        	paddq	%xmm5,%xmm5

// CHECK: 	paddsb	3735928559(%ebx,%ecx,8), %mm3
        	paddsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddsb	69, %mm3
        	paddsb	0x45,%mm3

// CHECK: 	paddsb	32493, %mm3
        	paddsb	0x7eed,%mm3

// CHECK: 	paddsb	3133065982, %mm3
        	paddsb	0xbabecafe,%mm3

// CHECK: 	paddsb	305419896, %mm3
        	paddsb	0x12345678,%mm3

// CHECK: 	paddsb	%mm3, %mm3
        	paddsb	%mm3,%mm3

// CHECK: 	paddsb	3735928559(%ebx,%ecx,8), %xmm5
        	paddsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddsb	69, %xmm5
        	paddsb	0x45,%xmm5

// CHECK: 	paddsb	32493, %xmm5
        	paddsb	0x7eed,%xmm5

// CHECK: 	paddsb	3133065982, %xmm5
        	paddsb	0xbabecafe,%xmm5

// CHECK: 	paddsb	305419896, %xmm5
        	paddsb	0x12345678,%xmm5

// CHECK: 	paddsb	%xmm5, %xmm5
        	paddsb	%xmm5,%xmm5

// CHECK: 	paddsw	3735928559(%ebx,%ecx,8), %mm3
        	paddsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddsw	69, %mm3
        	paddsw	0x45,%mm3

// CHECK: 	paddsw	32493, %mm3
        	paddsw	0x7eed,%mm3

// CHECK: 	paddsw	3133065982, %mm3
        	paddsw	0xbabecafe,%mm3

// CHECK: 	paddsw	305419896, %mm3
        	paddsw	0x12345678,%mm3

// CHECK: 	paddsw	%mm3, %mm3
        	paddsw	%mm3,%mm3

// CHECK: 	paddsw	3735928559(%ebx,%ecx,8), %xmm5
        	paddsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddsw	69, %xmm5
        	paddsw	0x45,%xmm5

// CHECK: 	paddsw	32493, %xmm5
        	paddsw	0x7eed,%xmm5

// CHECK: 	paddsw	3133065982, %xmm5
        	paddsw	0xbabecafe,%xmm5

// CHECK: 	paddsw	305419896, %xmm5
        	paddsw	0x12345678,%xmm5

// CHECK: 	paddsw	%xmm5, %xmm5
        	paddsw	%xmm5,%xmm5

// CHECK: 	paddusb	3735928559(%ebx,%ecx,8), %mm3
        	paddusb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddusb	69, %mm3
        	paddusb	0x45,%mm3

// CHECK: 	paddusb	32493, %mm3
        	paddusb	0x7eed,%mm3

// CHECK: 	paddusb	3133065982, %mm3
        	paddusb	0xbabecafe,%mm3

// CHECK: 	paddusb	305419896, %mm3
        	paddusb	0x12345678,%mm3

// CHECK: 	paddusb	%mm3, %mm3
        	paddusb	%mm3,%mm3

// CHECK: 	paddusb	3735928559(%ebx,%ecx,8), %xmm5
        	paddusb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddusb	69, %xmm5
        	paddusb	0x45,%xmm5

// CHECK: 	paddusb	32493, %xmm5
        	paddusb	0x7eed,%xmm5

// CHECK: 	paddusb	3133065982, %xmm5
        	paddusb	0xbabecafe,%xmm5

// CHECK: 	paddusb	305419896, %xmm5
        	paddusb	0x12345678,%xmm5

// CHECK: 	paddusb	%xmm5, %xmm5
        	paddusb	%xmm5,%xmm5

// CHECK: 	paddusw	3735928559(%ebx,%ecx,8), %mm3
        	paddusw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	paddusw	69, %mm3
        	paddusw	0x45,%mm3

// CHECK: 	paddusw	32493, %mm3
        	paddusw	0x7eed,%mm3

// CHECK: 	paddusw	3133065982, %mm3
        	paddusw	0xbabecafe,%mm3

// CHECK: 	paddusw	305419896, %mm3
        	paddusw	0x12345678,%mm3

// CHECK: 	paddusw	%mm3, %mm3
        	paddusw	%mm3,%mm3

// CHECK: 	paddusw	3735928559(%ebx,%ecx,8), %xmm5
        	paddusw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	paddusw	69, %xmm5
        	paddusw	0x45,%xmm5

// CHECK: 	paddusw	32493, %xmm5
        	paddusw	0x7eed,%xmm5

// CHECK: 	paddusw	3133065982, %xmm5
        	paddusw	0xbabecafe,%xmm5

// CHECK: 	paddusw	305419896, %xmm5
        	paddusw	0x12345678,%xmm5

// CHECK: 	paddusw	%xmm5, %xmm5
        	paddusw	%xmm5,%xmm5

// CHECK: 	pand	3735928559(%ebx,%ecx,8), %mm3
        	pand	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pand	69, %mm3
        	pand	0x45,%mm3

// CHECK: 	pand	32493, %mm3
        	pand	0x7eed,%mm3

// CHECK: 	pand	3133065982, %mm3
        	pand	0xbabecafe,%mm3

// CHECK: 	pand	305419896, %mm3
        	pand	0x12345678,%mm3

// CHECK: 	pand	%mm3, %mm3
        	pand	%mm3,%mm3

// CHECK: 	pand	3735928559(%ebx,%ecx,8), %xmm5
        	pand	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pand	69, %xmm5
        	pand	0x45,%xmm5

// CHECK: 	pand	32493, %xmm5
        	pand	0x7eed,%xmm5

// CHECK: 	pand	3133065982, %xmm5
        	pand	0xbabecafe,%xmm5

// CHECK: 	pand	305419896, %xmm5
        	pand	0x12345678,%xmm5

// CHECK: 	pand	%xmm5, %xmm5
        	pand	%xmm5,%xmm5

// CHECK: 	pandn	3735928559(%ebx,%ecx,8), %mm3
        	pandn	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pandn	69, %mm3
        	pandn	0x45,%mm3

// CHECK: 	pandn	32493, %mm3
        	pandn	0x7eed,%mm3

// CHECK: 	pandn	3133065982, %mm3
        	pandn	0xbabecafe,%mm3

// CHECK: 	pandn	305419896, %mm3
        	pandn	0x12345678,%mm3

// CHECK: 	pandn	%mm3, %mm3
        	pandn	%mm3,%mm3

// CHECK: 	pandn	3735928559(%ebx,%ecx,8), %xmm5
        	pandn	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pandn	69, %xmm5
        	pandn	0x45,%xmm5

// CHECK: 	pandn	32493, %xmm5
        	pandn	0x7eed,%xmm5

// CHECK: 	pandn	3133065982, %xmm5
        	pandn	0xbabecafe,%xmm5

// CHECK: 	pandn	305419896, %xmm5
        	pandn	0x12345678,%xmm5

// CHECK: 	pandn	%xmm5, %xmm5
        	pandn	%xmm5,%xmm5

// CHECK: 	pcmpeqb	3735928559(%ebx,%ecx,8), %mm3
        	pcmpeqb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpeqb	69, %mm3
        	pcmpeqb	0x45,%mm3

// CHECK: 	pcmpeqb	32493, %mm3
        	pcmpeqb	0x7eed,%mm3

// CHECK: 	pcmpeqb	3133065982, %mm3
        	pcmpeqb	0xbabecafe,%mm3

// CHECK: 	pcmpeqb	305419896, %mm3
        	pcmpeqb	0x12345678,%mm3

// CHECK: 	pcmpeqb	%mm3, %mm3
        	pcmpeqb	%mm3,%mm3

// CHECK: 	pcmpeqb	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpeqb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpeqb	69, %xmm5
        	pcmpeqb	0x45,%xmm5

// CHECK: 	pcmpeqb	32493, %xmm5
        	pcmpeqb	0x7eed,%xmm5

// CHECK: 	pcmpeqb	3133065982, %xmm5
        	pcmpeqb	0xbabecafe,%xmm5

// CHECK: 	pcmpeqb	305419896, %xmm5
        	pcmpeqb	0x12345678,%xmm5

// CHECK: 	pcmpeqb	%xmm5, %xmm5
        	pcmpeqb	%xmm5,%xmm5

// CHECK: 	pcmpeqw	3735928559(%ebx,%ecx,8), %mm3
        	pcmpeqw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpeqw	69, %mm3
        	pcmpeqw	0x45,%mm3

// CHECK: 	pcmpeqw	32493, %mm3
        	pcmpeqw	0x7eed,%mm3

// CHECK: 	pcmpeqw	3133065982, %mm3
        	pcmpeqw	0xbabecafe,%mm3

// CHECK: 	pcmpeqw	305419896, %mm3
        	pcmpeqw	0x12345678,%mm3

// CHECK: 	pcmpeqw	%mm3, %mm3
        	pcmpeqw	%mm3,%mm3

// CHECK: 	pcmpeqw	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpeqw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpeqw	69, %xmm5
        	pcmpeqw	0x45,%xmm5

// CHECK: 	pcmpeqw	32493, %xmm5
        	pcmpeqw	0x7eed,%xmm5

// CHECK: 	pcmpeqw	3133065982, %xmm5
        	pcmpeqw	0xbabecafe,%xmm5

// CHECK: 	pcmpeqw	305419896, %xmm5
        	pcmpeqw	0x12345678,%xmm5

// CHECK: 	pcmpeqw	%xmm5, %xmm5
        	pcmpeqw	%xmm5,%xmm5

// CHECK: 	pcmpeqd	3735928559(%ebx,%ecx,8), %mm3
        	pcmpeqd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpeqd	69, %mm3
        	pcmpeqd	0x45,%mm3

// CHECK: 	pcmpeqd	32493, %mm3
        	pcmpeqd	0x7eed,%mm3

// CHECK: 	pcmpeqd	3133065982, %mm3
        	pcmpeqd	0xbabecafe,%mm3

// CHECK: 	pcmpeqd	305419896, %mm3
        	pcmpeqd	0x12345678,%mm3

// CHECK: 	pcmpeqd	%mm3, %mm3
        	pcmpeqd	%mm3,%mm3

// CHECK: 	pcmpeqd	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpeqd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpeqd	69, %xmm5
        	pcmpeqd	0x45,%xmm5

// CHECK: 	pcmpeqd	32493, %xmm5
        	pcmpeqd	0x7eed,%xmm5

// CHECK: 	pcmpeqd	3133065982, %xmm5
        	pcmpeqd	0xbabecafe,%xmm5

// CHECK: 	pcmpeqd	305419896, %xmm5
        	pcmpeqd	0x12345678,%xmm5

// CHECK: 	pcmpeqd	%xmm5, %xmm5
        	pcmpeqd	%xmm5,%xmm5

// CHECK: 	pcmpgtb	3735928559(%ebx,%ecx,8), %mm3
        	pcmpgtb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpgtb	69, %mm3
        	pcmpgtb	0x45,%mm3

// CHECK: 	pcmpgtb	32493, %mm3
        	pcmpgtb	0x7eed,%mm3

// CHECK: 	pcmpgtb	3133065982, %mm3
        	pcmpgtb	0xbabecafe,%mm3

// CHECK: 	pcmpgtb	305419896, %mm3
        	pcmpgtb	0x12345678,%mm3

// CHECK: 	pcmpgtb	%mm3, %mm3
        	pcmpgtb	%mm3,%mm3

// CHECK: 	pcmpgtb	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpgtb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpgtb	69, %xmm5
        	pcmpgtb	0x45,%xmm5

// CHECK: 	pcmpgtb	32493, %xmm5
        	pcmpgtb	0x7eed,%xmm5

// CHECK: 	pcmpgtb	3133065982, %xmm5
        	pcmpgtb	0xbabecafe,%xmm5

// CHECK: 	pcmpgtb	305419896, %xmm5
        	pcmpgtb	0x12345678,%xmm5

// CHECK: 	pcmpgtb	%xmm5, %xmm5
        	pcmpgtb	%xmm5,%xmm5

// CHECK: 	pcmpgtw	3735928559(%ebx,%ecx,8), %mm3
        	pcmpgtw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpgtw	69, %mm3
        	pcmpgtw	0x45,%mm3

// CHECK: 	pcmpgtw	32493, %mm3
        	pcmpgtw	0x7eed,%mm3

// CHECK: 	pcmpgtw	3133065982, %mm3
        	pcmpgtw	0xbabecafe,%mm3

// CHECK: 	pcmpgtw	305419896, %mm3
        	pcmpgtw	0x12345678,%mm3

// CHECK: 	pcmpgtw	%mm3, %mm3
        	pcmpgtw	%mm3,%mm3

// CHECK: 	pcmpgtw	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpgtw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpgtw	69, %xmm5
        	pcmpgtw	0x45,%xmm5

// CHECK: 	pcmpgtw	32493, %xmm5
        	pcmpgtw	0x7eed,%xmm5

// CHECK: 	pcmpgtw	3133065982, %xmm5
        	pcmpgtw	0xbabecafe,%xmm5

// CHECK: 	pcmpgtw	305419896, %xmm5
        	pcmpgtw	0x12345678,%xmm5

// CHECK: 	pcmpgtw	%xmm5, %xmm5
        	pcmpgtw	%xmm5,%xmm5

// CHECK: 	pcmpgtd	3735928559(%ebx,%ecx,8), %mm3
        	pcmpgtd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pcmpgtd	69, %mm3
        	pcmpgtd	0x45,%mm3

// CHECK: 	pcmpgtd	32493, %mm3
        	pcmpgtd	0x7eed,%mm3

// CHECK: 	pcmpgtd	3133065982, %mm3
        	pcmpgtd	0xbabecafe,%mm3

// CHECK: 	pcmpgtd	305419896, %mm3
        	pcmpgtd	0x12345678,%mm3

// CHECK: 	pcmpgtd	%mm3, %mm3
        	pcmpgtd	%mm3,%mm3

// CHECK: 	pcmpgtd	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpgtd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpgtd	69, %xmm5
        	pcmpgtd	0x45,%xmm5

// CHECK: 	pcmpgtd	32493, %xmm5
        	pcmpgtd	0x7eed,%xmm5

// CHECK: 	pcmpgtd	3133065982, %xmm5
        	pcmpgtd	0xbabecafe,%xmm5

// CHECK: 	pcmpgtd	305419896, %xmm5
        	pcmpgtd	0x12345678,%xmm5

// CHECK: 	pcmpgtd	%xmm5, %xmm5
        	pcmpgtd	%xmm5,%xmm5

// CHECK: 	pmaddwd	3735928559(%ebx,%ecx,8), %mm3
        	pmaddwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmaddwd	69, %mm3
        	pmaddwd	0x45,%mm3

// CHECK: 	pmaddwd	32493, %mm3
        	pmaddwd	0x7eed,%mm3

// CHECK: 	pmaddwd	3133065982, %mm3
        	pmaddwd	0xbabecafe,%mm3

// CHECK: 	pmaddwd	305419896, %mm3
        	pmaddwd	0x12345678,%mm3

// CHECK: 	pmaddwd	%mm3, %mm3
        	pmaddwd	%mm3,%mm3

// CHECK: 	pmaddwd	3735928559(%ebx,%ecx,8), %xmm5
        	pmaddwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaddwd	69, %xmm5
        	pmaddwd	0x45,%xmm5

// CHECK: 	pmaddwd	32493, %xmm5
        	pmaddwd	0x7eed,%xmm5

// CHECK: 	pmaddwd	3133065982, %xmm5
        	pmaddwd	0xbabecafe,%xmm5

// CHECK: 	pmaddwd	305419896, %xmm5
        	pmaddwd	0x12345678,%xmm5

// CHECK: 	pmaddwd	%xmm5, %xmm5
        	pmaddwd	%xmm5,%xmm5

// CHECK: 	pmulhw	3735928559(%ebx,%ecx,8), %mm3
        	pmulhw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmulhw	69, %mm3
        	pmulhw	0x45,%mm3

// CHECK: 	pmulhw	32493, %mm3
        	pmulhw	0x7eed,%mm3

// CHECK: 	pmulhw	3133065982, %mm3
        	pmulhw	0xbabecafe,%mm3

// CHECK: 	pmulhw	305419896, %mm3
        	pmulhw	0x12345678,%mm3

// CHECK: 	pmulhw	%mm3, %mm3
        	pmulhw	%mm3,%mm3

// CHECK: 	pmulhw	3735928559(%ebx,%ecx,8), %xmm5
        	pmulhw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmulhw	69, %xmm5
        	pmulhw	0x45,%xmm5

// CHECK: 	pmulhw	32493, %xmm5
        	pmulhw	0x7eed,%xmm5

// CHECK: 	pmulhw	3133065982, %xmm5
        	pmulhw	0xbabecafe,%xmm5

// CHECK: 	pmulhw	305419896, %xmm5
        	pmulhw	0x12345678,%xmm5

// CHECK: 	pmulhw	%xmm5, %xmm5
        	pmulhw	%xmm5,%xmm5

// CHECK: 	pmullw	3735928559(%ebx,%ecx,8), %mm3
        	pmullw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmullw	69, %mm3
        	pmullw	0x45,%mm3

// CHECK: 	pmullw	32493, %mm3
        	pmullw	0x7eed,%mm3

// CHECK: 	pmullw	3133065982, %mm3
        	pmullw	0xbabecafe,%mm3

// CHECK: 	pmullw	305419896, %mm3
        	pmullw	0x12345678,%mm3

// CHECK: 	pmullw	%mm3, %mm3
        	pmullw	%mm3,%mm3

// CHECK: 	pmullw	3735928559(%ebx,%ecx,8), %xmm5
        	pmullw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmullw	69, %xmm5
        	pmullw	0x45,%xmm5

// CHECK: 	pmullw	32493, %xmm5
        	pmullw	0x7eed,%xmm5

// CHECK: 	pmullw	3133065982, %xmm5
        	pmullw	0xbabecafe,%xmm5

// CHECK: 	pmullw	305419896, %xmm5
        	pmullw	0x12345678,%xmm5

// CHECK: 	pmullw	%xmm5, %xmm5
        	pmullw	%xmm5,%xmm5

// CHECK: 	por	3735928559(%ebx,%ecx,8), %mm3
        	por	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	por	69, %mm3
        	por	0x45,%mm3

// CHECK: 	por	32493, %mm3
        	por	0x7eed,%mm3

// CHECK: 	por	3133065982, %mm3
        	por	0xbabecafe,%mm3

// CHECK: 	por	305419896, %mm3
        	por	0x12345678,%mm3

// CHECK: 	por	%mm3, %mm3
        	por	%mm3,%mm3

// CHECK: 	por	3735928559(%ebx,%ecx,8), %xmm5
        	por	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	por	69, %xmm5
        	por	0x45,%xmm5

// CHECK: 	por	32493, %xmm5
        	por	0x7eed,%xmm5

// CHECK: 	por	3133065982, %xmm5
        	por	0xbabecafe,%xmm5

// CHECK: 	por	305419896, %xmm5
        	por	0x12345678,%xmm5

// CHECK: 	por	%xmm5, %xmm5
        	por	%xmm5,%xmm5

// CHECK: 	psllw	3735928559(%ebx,%ecx,8), %mm3
        	psllw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psllw	69, %mm3
        	psllw	0x45,%mm3

// CHECK: 	psllw	32493, %mm3
        	psllw	0x7eed,%mm3

// CHECK: 	psllw	3133065982, %mm3
        	psllw	0xbabecafe,%mm3

// CHECK: 	psllw	305419896, %mm3
        	psllw	0x12345678,%mm3

// CHECK: 	psllw	%mm3, %mm3
        	psllw	%mm3,%mm3

// CHECK: 	psllw	3735928559(%ebx,%ecx,8), %xmm5
        	psllw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psllw	69, %xmm5
        	psllw	0x45,%xmm5

// CHECK: 	psllw	32493, %xmm5
        	psllw	0x7eed,%xmm5

// CHECK: 	psllw	3133065982, %xmm5
        	psllw	0xbabecafe,%xmm5

// CHECK: 	psllw	305419896, %xmm5
        	psllw	0x12345678,%xmm5

// CHECK: 	psllw	%xmm5, %xmm5
        	psllw	%xmm5,%xmm5

// CHECK: 	psllw	$127, %mm3
        	psllw	$0x7f,%mm3

// CHECK: 	psllw	$127, %xmm5
        	psllw	$0x7f,%xmm5

// CHECK: 	pslld	3735928559(%ebx,%ecx,8), %mm3
        	pslld	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pslld	69, %mm3
        	pslld	0x45,%mm3

// CHECK: 	pslld	32493, %mm3
        	pslld	0x7eed,%mm3

// CHECK: 	pslld	3133065982, %mm3
        	pslld	0xbabecafe,%mm3

// CHECK: 	pslld	305419896, %mm3
        	pslld	0x12345678,%mm3

// CHECK: 	pslld	%mm3, %mm3
        	pslld	%mm3,%mm3

// CHECK: 	pslld	3735928559(%ebx,%ecx,8), %xmm5
        	pslld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pslld	69, %xmm5
        	pslld	0x45,%xmm5

// CHECK: 	pslld	32493, %xmm5
        	pslld	0x7eed,%xmm5

// CHECK: 	pslld	3133065982, %xmm5
        	pslld	0xbabecafe,%xmm5

// CHECK: 	pslld	305419896, %xmm5
        	pslld	0x12345678,%xmm5

// CHECK: 	pslld	%xmm5, %xmm5
        	pslld	%xmm5,%xmm5

// CHECK: 	pslld	$127, %mm3
        	pslld	$0x7f,%mm3

// CHECK: 	pslld	$127, %xmm5
        	pslld	$0x7f,%xmm5

// CHECK: 	psllq	3735928559(%ebx,%ecx,8), %mm3
        	psllq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psllq	69, %mm3
        	psllq	0x45,%mm3

// CHECK: 	psllq	32493, %mm3
        	psllq	0x7eed,%mm3

// CHECK: 	psllq	3133065982, %mm3
        	psllq	0xbabecafe,%mm3

// CHECK: 	psllq	305419896, %mm3
        	psllq	0x12345678,%mm3

// CHECK: 	psllq	%mm3, %mm3
        	psllq	%mm3,%mm3

// CHECK: 	psllq	3735928559(%ebx,%ecx,8), %xmm5
        	psllq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psllq	69, %xmm5
        	psllq	0x45,%xmm5

// CHECK: 	psllq	32493, %xmm5
        	psllq	0x7eed,%xmm5

// CHECK: 	psllq	3133065982, %xmm5
        	psllq	0xbabecafe,%xmm5

// CHECK: 	psllq	305419896, %xmm5
        	psllq	0x12345678,%xmm5

// CHECK: 	psllq	%xmm5, %xmm5
        	psllq	%xmm5,%xmm5

// CHECK: 	psllq	$127, %mm3
        	psllq	$0x7f,%mm3

// CHECK: 	psllq	$127, %xmm5
        	psllq	$0x7f,%xmm5

// CHECK: 	psraw	3735928559(%ebx,%ecx,8), %mm3
        	psraw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psraw	69, %mm3
        	psraw	0x45,%mm3

// CHECK: 	psraw	32493, %mm3
        	psraw	0x7eed,%mm3

// CHECK: 	psraw	3133065982, %mm3
        	psraw	0xbabecafe,%mm3

// CHECK: 	psraw	305419896, %mm3
        	psraw	0x12345678,%mm3

// CHECK: 	psraw	%mm3, %mm3
        	psraw	%mm3,%mm3

// CHECK: 	psraw	3735928559(%ebx,%ecx,8), %xmm5
        	psraw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psraw	69, %xmm5
        	psraw	0x45,%xmm5

// CHECK: 	psraw	32493, %xmm5
        	psraw	0x7eed,%xmm5

// CHECK: 	psraw	3133065982, %xmm5
        	psraw	0xbabecafe,%xmm5

// CHECK: 	psraw	305419896, %xmm5
        	psraw	0x12345678,%xmm5

// CHECK: 	psraw	%xmm5, %xmm5
        	psraw	%xmm5,%xmm5

// CHECK: 	psraw	$127, %mm3
        	psraw	$0x7f,%mm3

// CHECK: 	psraw	$127, %xmm5
        	psraw	$0x7f,%xmm5

// CHECK: 	psrad	3735928559(%ebx,%ecx,8), %mm3
        	psrad	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psrad	69, %mm3
        	psrad	0x45,%mm3

// CHECK: 	psrad	32493, %mm3
        	psrad	0x7eed,%mm3

// CHECK: 	psrad	3133065982, %mm3
        	psrad	0xbabecafe,%mm3

// CHECK: 	psrad	305419896, %mm3
        	psrad	0x12345678,%mm3

// CHECK: 	psrad	%mm3, %mm3
        	psrad	%mm3,%mm3

// CHECK: 	psrad	3735928559(%ebx,%ecx,8), %xmm5
        	psrad	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psrad	69, %xmm5
        	psrad	0x45,%xmm5

// CHECK: 	psrad	32493, %xmm5
        	psrad	0x7eed,%xmm5

// CHECK: 	psrad	3133065982, %xmm5
        	psrad	0xbabecafe,%xmm5

// CHECK: 	psrad	305419896, %xmm5
        	psrad	0x12345678,%xmm5

// CHECK: 	psrad	%xmm5, %xmm5
        	psrad	%xmm5,%xmm5

// CHECK: 	psrad	$127, %mm3
        	psrad	$0x7f,%mm3

// CHECK: 	psrad	$127, %xmm5
        	psrad	$0x7f,%xmm5

// CHECK: 	psrlw	3735928559(%ebx,%ecx,8), %mm3
        	psrlw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psrlw	69, %mm3
        	psrlw	0x45,%mm3

// CHECK: 	psrlw	32493, %mm3
        	psrlw	0x7eed,%mm3

// CHECK: 	psrlw	3133065982, %mm3
        	psrlw	0xbabecafe,%mm3

// CHECK: 	psrlw	305419896, %mm3
        	psrlw	0x12345678,%mm3

// CHECK: 	psrlw	%mm3, %mm3
        	psrlw	%mm3,%mm3

// CHECK: 	psrlw	3735928559(%ebx,%ecx,8), %xmm5
        	psrlw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psrlw	69, %xmm5
        	psrlw	0x45,%xmm5

// CHECK: 	psrlw	32493, %xmm5
        	psrlw	0x7eed,%xmm5

// CHECK: 	psrlw	3133065982, %xmm5
        	psrlw	0xbabecafe,%xmm5

// CHECK: 	psrlw	305419896, %xmm5
        	psrlw	0x12345678,%xmm5

// CHECK: 	psrlw	%xmm5, %xmm5
        	psrlw	%xmm5,%xmm5

// CHECK: 	psrlw	$127, %mm3
        	psrlw	$0x7f,%mm3

// CHECK: 	psrlw	$127, %xmm5
        	psrlw	$0x7f,%xmm5

// CHECK: 	psrld	3735928559(%ebx,%ecx,8), %mm3
        	psrld	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psrld	69, %mm3
        	psrld	0x45,%mm3

// CHECK: 	psrld	32493, %mm3
        	psrld	0x7eed,%mm3

// CHECK: 	psrld	3133065982, %mm3
        	psrld	0xbabecafe,%mm3

// CHECK: 	psrld	305419896, %mm3
        	psrld	0x12345678,%mm3

// CHECK: 	psrld	%mm3, %mm3
        	psrld	%mm3,%mm3

// CHECK: 	psrld	3735928559(%ebx,%ecx,8), %xmm5
        	psrld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psrld	69, %xmm5
        	psrld	0x45,%xmm5

// CHECK: 	psrld	32493, %xmm5
        	psrld	0x7eed,%xmm5

// CHECK: 	psrld	3133065982, %xmm5
        	psrld	0xbabecafe,%xmm5

// CHECK: 	psrld	305419896, %xmm5
        	psrld	0x12345678,%xmm5

// CHECK: 	psrld	%xmm5, %xmm5
        	psrld	%xmm5,%xmm5

// CHECK: 	psrld	$127, %mm3
        	psrld	$0x7f,%mm3

// CHECK: 	psrld	$127, %xmm5
        	psrld	$0x7f,%xmm5

// CHECK: 	psrlq	3735928559(%ebx,%ecx,8), %mm3
        	psrlq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psrlq	69, %mm3
        	psrlq	0x45,%mm3

// CHECK: 	psrlq	32493, %mm3
        	psrlq	0x7eed,%mm3

// CHECK: 	psrlq	3133065982, %mm3
        	psrlq	0xbabecafe,%mm3

// CHECK: 	psrlq	305419896, %mm3
        	psrlq	0x12345678,%mm3

// CHECK: 	psrlq	%mm3, %mm3
        	psrlq	%mm3,%mm3

// CHECK: 	psrlq	3735928559(%ebx,%ecx,8), %xmm5
        	psrlq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psrlq	69, %xmm5
        	psrlq	0x45,%xmm5

// CHECK: 	psrlq	32493, %xmm5
        	psrlq	0x7eed,%xmm5

// CHECK: 	psrlq	3133065982, %xmm5
        	psrlq	0xbabecafe,%xmm5

// CHECK: 	psrlq	305419896, %xmm5
        	psrlq	0x12345678,%xmm5

// CHECK: 	psrlq	%xmm5, %xmm5
        	psrlq	%xmm5,%xmm5

// CHECK: 	psrlq	$127, %mm3
        	psrlq	$0x7f,%mm3

// CHECK: 	psrlq	$127, %xmm5
        	psrlq	$0x7f,%xmm5

// CHECK: 	psubb	3735928559(%ebx,%ecx,8), %mm3
        	psubb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubb	69, %mm3
        	psubb	0x45,%mm3

// CHECK: 	psubb	32493, %mm3
        	psubb	0x7eed,%mm3

// CHECK: 	psubb	3133065982, %mm3
        	psubb	0xbabecafe,%mm3

// CHECK: 	psubb	305419896, %mm3
        	psubb	0x12345678,%mm3

// CHECK: 	psubb	%mm3, %mm3
        	psubb	%mm3,%mm3

// CHECK: 	psubb	3735928559(%ebx,%ecx,8), %xmm5
        	psubb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubb	69, %xmm5
        	psubb	0x45,%xmm5

// CHECK: 	psubb	32493, %xmm5
        	psubb	0x7eed,%xmm5

// CHECK: 	psubb	3133065982, %xmm5
        	psubb	0xbabecafe,%xmm5

// CHECK: 	psubb	305419896, %xmm5
        	psubb	0x12345678,%xmm5

// CHECK: 	psubb	%xmm5, %xmm5
        	psubb	%xmm5,%xmm5

// CHECK: 	psubw	3735928559(%ebx,%ecx,8), %mm3
        	psubw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubw	69, %mm3
        	psubw	0x45,%mm3

// CHECK: 	psubw	32493, %mm3
        	psubw	0x7eed,%mm3

// CHECK: 	psubw	3133065982, %mm3
        	psubw	0xbabecafe,%mm3

// CHECK: 	psubw	305419896, %mm3
        	psubw	0x12345678,%mm3

// CHECK: 	psubw	%mm3, %mm3
        	psubw	%mm3,%mm3

// CHECK: 	psubw	3735928559(%ebx,%ecx,8), %xmm5
        	psubw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubw	69, %xmm5
        	psubw	0x45,%xmm5

// CHECK: 	psubw	32493, %xmm5
        	psubw	0x7eed,%xmm5

// CHECK: 	psubw	3133065982, %xmm5
        	psubw	0xbabecafe,%xmm5

// CHECK: 	psubw	305419896, %xmm5
        	psubw	0x12345678,%xmm5

// CHECK: 	psubw	%xmm5, %xmm5
        	psubw	%xmm5,%xmm5

// CHECK: 	psubd	3735928559(%ebx,%ecx,8), %mm3
        	psubd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubd	69, %mm3
        	psubd	0x45,%mm3

// CHECK: 	psubd	32493, %mm3
        	psubd	0x7eed,%mm3

// CHECK: 	psubd	3133065982, %mm3
        	psubd	0xbabecafe,%mm3

// CHECK: 	psubd	305419896, %mm3
        	psubd	0x12345678,%mm3

// CHECK: 	psubd	%mm3, %mm3
        	psubd	%mm3,%mm3

// CHECK: 	psubd	3735928559(%ebx,%ecx,8), %xmm5
        	psubd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubd	69, %xmm5
        	psubd	0x45,%xmm5

// CHECK: 	psubd	32493, %xmm5
        	psubd	0x7eed,%xmm5

// CHECK: 	psubd	3133065982, %xmm5
        	psubd	0xbabecafe,%xmm5

// CHECK: 	psubd	305419896, %xmm5
        	psubd	0x12345678,%xmm5

// CHECK: 	psubd	%xmm5, %xmm5
        	psubd	%xmm5,%xmm5

// CHECK: 	psubq	3735928559(%ebx,%ecx,8), %mm3
        	psubq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubq	69, %mm3
        	psubq	0x45,%mm3

// CHECK: 	psubq	32493, %mm3
        	psubq	0x7eed,%mm3

// CHECK: 	psubq	3133065982, %mm3
        	psubq	0xbabecafe,%mm3

// CHECK: 	psubq	305419896, %mm3
        	psubq	0x12345678,%mm3

// CHECK: 	psubq	%mm3, %mm3
        	psubq	%mm3,%mm3

// CHECK: 	psubq	3735928559(%ebx,%ecx,8), %xmm5
        	psubq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubq	69, %xmm5
        	psubq	0x45,%xmm5

// CHECK: 	psubq	32493, %xmm5
        	psubq	0x7eed,%xmm5

// CHECK: 	psubq	3133065982, %xmm5
        	psubq	0xbabecafe,%xmm5

// CHECK: 	psubq	305419896, %xmm5
        	psubq	0x12345678,%xmm5

// CHECK: 	psubq	%xmm5, %xmm5
        	psubq	%xmm5,%xmm5

// CHECK: 	psubsb	3735928559(%ebx,%ecx,8), %mm3
        	psubsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubsb	69, %mm3
        	psubsb	0x45,%mm3

// CHECK: 	psubsb	32493, %mm3
        	psubsb	0x7eed,%mm3

// CHECK: 	psubsb	3133065982, %mm3
        	psubsb	0xbabecafe,%mm3

// CHECK: 	psubsb	305419896, %mm3
        	psubsb	0x12345678,%mm3

// CHECK: 	psubsb	%mm3, %mm3
        	psubsb	%mm3,%mm3

// CHECK: 	psubsb	3735928559(%ebx,%ecx,8), %xmm5
        	psubsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubsb	69, %xmm5
        	psubsb	0x45,%xmm5

// CHECK: 	psubsb	32493, %xmm5
        	psubsb	0x7eed,%xmm5

// CHECK: 	psubsb	3133065982, %xmm5
        	psubsb	0xbabecafe,%xmm5

// CHECK: 	psubsb	305419896, %xmm5
        	psubsb	0x12345678,%xmm5

// CHECK: 	psubsb	%xmm5, %xmm5
        	psubsb	%xmm5,%xmm5

// CHECK: 	psubsw	3735928559(%ebx,%ecx,8), %mm3
        	psubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubsw	69, %mm3
        	psubsw	0x45,%mm3

// CHECK: 	psubsw	32493, %mm3
        	psubsw	0x7eed,%mm3

// CHECK: 	psubsw	3133065982, %mm3
        	psubsw	0xbabecafe,%mm3

// CHECK: 	psubsw	305419896, %mm3
        	psubsw	0x12345678,%mm3

// CHECK: 	psubsw	%mm3, %mm3
        	psubsw	%mm3,%mm3

// CHECK: 	psubsw	3735928559(%ebx,%ecx,8), %xmm5
        	psubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubsw	69, %xmm5
        	psubsw	0x45,%xmm5

// CHECK: 	psubsw	32493, %xmm5
        	psubsw	0x7eed,%xmm5

// CHECK: 	psubsw	3133065982, %xmm5
        	psubsw	0xbabecafe,%xmm5

// CHECK: 	psubsw	305419896, %xmm5
        	psubsw	0x12345678,%xmm5

// CHECK: 	psubsw	%xmm5, %xmm5
        	psubsw	%xmm5,%xmm5

// CHECK: 	psubusb	3735928559(%ebx,%ecx,8), %mm3
        	psubusb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubusb	69, %mm3
        	psubusb	0x45,%mm3

// CHECK: 	psubusb	32493, %mm3
        	psubusb	0x7eed,%mm3

// CHECK: 	psubusb	3133065982, %mm3
        	psubusb	0xbabecafe,%mm3

// CHECK: 	psubusb	305419896, %mm3
        	psubusb	0x12345678,%mm3

// CHECK: 	psubusb	%mm3, %mm3
        	psubusb	%mm3,%mm3

// CHECK: 	psubusb	3735928559(%ebx,%ecx,8), %xmm5
        	psubusb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubusb	69, %xmm5
        	psubusb	0x45,%xmm5

// CHECK: 	psubusb	32493, %xmm5
        	psubusb	0x7eed,%xmm5

// CHECK: 	psubusb	3133065982, %xmm5
        	psubusb	0xbabecafe,%xmm5

// CHECK: 	psubusb	305419896, %xmm5
        	psubusb	0x12345678,%xmm5

// CHECK: 	psubusb	%xmm5, %xmm5
        	psubusb	%xmm5,%xmm5

// CHECK: 	psubusw	3735928559(%ebx,%ecx,8), %mm3
        	psubusw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psubusw	69, %mm3
        	psubusw	0x45,%mm3

// CHECK: 	psubusw	32493, %mm3
        	psubusw	0x7eed,%mm3

// CHECK: 	psubusw	3133065982, %mm3
        	psubusw	0xbabecafe,%mm3

// CHECK: 	psubusw	305419896, %mm3
        	psubusw	0x12345678,%mm3

// CHECK: 	psubusw	%mm3, %mm3
        	psubusw	%mm3,%mm3

// CHECK: 	psubusw	3735928559(%ebx,%ecx,8), %xmm5
        	psubusw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psubusw	69, %xmm5
        	psubusw	0x45,%xmm5

// CHECK: 	psubusw	32493, %xmm5
        	psubusw	0x7eed,%xmm5

// CHECK: 	psubusw	3133065982, %xmm5
        	psubusw	0xbabecafe,%xmm5

// CHECK: 	psubusw	305419896, %xmm5
        	psubusw	0x12345678,%xmm5

// CHECK: 	psubusw	%xmm5, %xmm5
        	psubusw	%xmm5,%xmm5

// CHECK: 	punpckhbw	3735928559(%ebx,%ecx,8), %mm3
        	punpckhbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpckhbw	69, %mm3
        	punpckhbw	0x45,%mm3

// CHECK: 	punpckhbw	32493, %mm3
        	punpckhbw	0x7eed,%mm3

// CHECK: 	punpckhbw	3133065982, %mm3
        	punpckhbw	0xbabecafe,%mm3

// CHECK: 	punpckhbw	305419896, %mm3
        	punpckhbw	0x12345678,%mm3

// CHECK: 	punpckhbw	%mm3, %mm3
        	punpckhbw	%mm3,%mm3

// CHECK: 	punpckhbw	3735928559(%ebx,%ecx,8), %xmm5
        	punpckhbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpckhbw	69, %xmm5
        	punpckhbw	0x45,%xmm5

// CHECK: 	punpckhbw	32493, %xmm5
        	punpckhbw	0x7eed,%xmm5

// CHECK: 	punpckhbw	3133065982, %xmm5
        	punpckhbw	0xbabecafe,%xmm5

// CHECK: 	punpckhbw	305419896, %xmm5
        	punpckhbw	0x12345678,%xmm5

// CHECK: 	punpckhbw	%xmm5, %xmm5
        	punpckhbw	%xmm5,%xmm5

// CHECK: 	punpckhwd	3735928559(%ebx,%ecx,8), %mm3
        	punpckhwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpckhwd	69, %mm3
        	punpckhwd	0x45,%mm3

// CHECK: 	punpckhwd	32493, %mm3
        	punpckhwd	0x7eed,%mm3

// CHECK: 	punpckhwd	3133065982, %mm3
        	punpckhwd	0xbabecafe,%mm3

// CHECK: 	punpckhwd	305419896, %mm3
        	punpckhwd	0x12345678,%mm3

// CHECK: 	punpckhwd	%mm3, %mm3
        	punpckhwd	%mm3,%mm3

// CHECK: 	punpckhwd	3735928559(%ebx,%ecx,8), %xmm5
        	punpckhwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpckhwd	69, %xmm5
        	punpckhwd	0x45,%xmm5

// CHECK: 	punpckhwd	32493, %xmm5
        	punpckhwd	0x7eed,%xmm5

// CHECK: 	punpckhwd	3133065982, %xmm5
        	punpckhwd	0xbabecafe,%xmm5

// CHECK: 	punpckhwd	305419896, %xmm5
        	punpckhwd	0x12345678,%xmm5

// CHECK: 	punpckhwd	%xmm5, %xmm5
        	punpckhwd	%xmm5,%xmm5

// CHECK: 	punpckhdq	3735928559(%ebx,%ecx,8), %mm3
        	punpckhdq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpckhdq	69, %mm3
        	punpckhdq	0x45,%mm3

// CHECK: 	punpckhdq	32493, %mm3
        	punpckhdq	0x7eed,%mm3

// CHECK: 	punpckhdq	3133065982, %mm3
        	punpckhdq	0xbabecafe,%mm3

// CHECK: 	punpckhdq	305419896, %mm3
        	punpckhdq	0x12345678,%mm3

// CHECK: 	punpckhdq	%mm3, %mm3
        	punpckhdq	%mm3,%mm3

// CHECK: 	punpckhdq	3735928559(%ebx,%ecx,8), %xmm5
        	punpckhdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpckhdq	69, %xmm5
        	punpckhdq	0x45,%xmm5

// CHECK: 	punpckhdq	32493, %xmm5
        	punpckhdq	0x7eed,%xmm5

// CHECK: 	punpckhdq	3133065982, %xmm5
        	punpckhdq	0xbabecafe,%xmm5

// CHECK: 	punpckhdq	305419896, %xmm5
        	punpckhdq	0x12345678,%xmm5

// CHECK: 	punpckhdq	%xmm5, %xmm5
        	punpckhdq	%xmm5,%xmm5

// CHECK: 	punpcklbw	3735928559(%ebx,%ecx,8), %mm3
        	punpcklbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpcklbw	69, %mm3
        	punpcklbw	0x45,%mm3

// CHECK: 	punpcklbw	32493, %mm3
        	punpcklbw	0x7eed,%mm3

// CHECK: 	punpcklbw	3133065982, %mm3
        	punpcklbw	0xbabecafe,%mm3

// CHECK: 	punpcklbw	305419896, %mm3
        	punpcklbw	0x12345678,%mm3

// CHECK: 	punpcklbw	%mm3, %mm3
        	punpcklbw	%mm3,%mm3

// CHECK: 	punpcklbw	3735928559(%ebx,%ecx,8), %xmm5
        	punpcklbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpcklbw	69, %xmm5
        	punpcklbw	0x45,%xmm5

// CHECK: 	punpcklbw	32493, %xmm5
        	punpcklbw	0x7eed,%xmm5

// CHECK: 	punpcklbw	3133065982, %xmm5
        	punpcklbw	0xbabecafe,%xmm5

// CHECK: 	punpcklbw	305419896, %xmm5
        	punpcklbw	0x12345678,%xmm5

// CHECK: 	punpcklbw	%xmm5, %xmm5
        	punpcklbw	%xmm5,%xmm5

// CHECK: 	punpcklwd	3735928559(%ebx,%ecx,8), %mm3
        	punpcklwd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpcklwd	69, %mm3
        	punpcklwd	0x45,%mm3

// CHECK: 	punpcklwd	32493, %mm3
        	punpcklwd	0x7eed,%mm3

// CHECK: 	punpcklwd	3133065982, %mm3
        	punpcklwd	0xbabecafe,%mm3

// CHECK: 	punpcklwd	305419896, %mm3
        	punpcklwd	0x12345678,%mm3

// CHECK: 	punpcklwd	%mm3, %mm3
        	punpcklwd	%mm3,%mm3

// CHECK: 	punpcklwd	3735928559(%ebx,%ecx,8), %xmm5
        	punpcklwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpcklwd	69, %xmm5
        	punpcklwd	0x45,%xmm5

// CHECK: 	punpcklwd	32493, %xmm5
        	punpcklwd	0x7eed,%xmm5

// CHECK: 	punpcklwd	3133065982, %xmm5
        	punpcklwd	0xbabecafe,%xmm5

// CHECK: 	punpcklwd	305419896, %xmm5
        	punpcklwd	0x12345678,%xmm5

// CHECK: 	punpcklwd	%xmm5, %xmm5
        	punpcklwd	%xmm5,%xmm5

// CHECK: 	punpckldq	3735928559(%ebx,%ecx,8), %mm3
        	punpckldq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	punpckldq	69, %mm3
        	punpckldq	0x45,%mm3

// CHECK: 	punpckldq	32493, %mm3
        	punpckldq	0x7eed,%mm3

// CHECK: 	punpckldq	3133065982, %mm3
        	punpckldq	0xbabecafe,%mm3

// CHECK: 	punpckldq	305419896, %mm3
        	punpckldq	0x12345678,%mm3

// CHECK: 	punpckldq	%mm3, %mm3
        	punpckldq	%mm3,%mm3

// CHECK: 	punpckldq	3735928559(%ebx,%ecx,8), %xmm5
        	punpckldq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpckldq	69, %xmm5
        	punpckldq	0x45,%xmm5

// CHECK: 	punpckldq	32493, %xmm5
        	punpckldq	0x7eed,%xmm5

// CHECK: 	punpckldq	3133065982, %xmm5
        	punpckldq	0xbabecafe,%xmm5

// CHECK: 	punpckldq	305419896, %xmm5
        	punpckldq	0x12345678,%xmm5

// CHECK: 	punpckldq	%xmm5, %xmm5
        	punpckldq	%xmm5,%xmm5

// CHECK: 	pxor	3735928559(%ebx,%ecx,8), %mm3
        	pxor	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pxor	69, %mm3
        	pxor	0x45,%mm3

// CHECK: 	pxor	32493, %mm3
        	pxor	0x7eed,%mm3

// CHECK: 	pxor	3133065982, %mm3
        	pxor	0xbabecafe,%mm3

// CHECK: 	pxor	305419896, %mm3
        	pxor	0x12345678,%mm3

// CHECK: 	pxor	%mm3, %mm3
        	pxor	%mm3,%mm3

// CHECK: 	pxor	3735928559(%ebx,%ecx,8), %xmm5
        	pxor	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pxor	69, %xmm5
        	pxor	0x45,%xmm5

// CHECK: 	pxor	32493, %xmm5
        	pxor	0x7eed,%xmm5

// CHECK: 	pxor	3133065982, %xmm5
        	pxor	0xbabecafe,%xmm5

// CHECK: 	pxor	305419896, %xmm5
        	pxor	0x12345678,%xmm5

// CHECK: 	pxor	%xmm5, %xmm5
        	pxor	%xmm5,%xmm5

// CHECK: 	addps	3735928559(%ebx,%ecx,8), %xmm5
        	addps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addps	69, %xmm5
        	addps	0x45,%xmm5

// CHECK: 	addps	32493, %xmm5
        	addps	0x7eed,%xmm5

// CHECK: 	addps	3133065982, %xmm5
        	addps	0xbabecafe,%xmm5

// CHECK: 	addps	305419896, %xmm5
        	addps	0x12345678,%xmm5

// CHECK: 	addps	%xmm5, %xmm5
        	addps	%xmm5,%xmm5

// CHECK: 	addss	3735928559(%ebx,%ecx,8), %xmm5
        	addss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addss	69, %xmm5
        	addss	0x45,%xmm5

// CHECK: 	addss	32493, %xmm5
        	addss	0x7eed,%xmm5

// CHECK: 	addss	3133065982, %xmm5
        	addss	0xbabecafe,%xmm5

// CHECK: 	addss	305419896, %xmm5
        	addss	0x12345678,%xmm5

// CHECK: 	addss	%xmm5, %xmm5
        	addss	%xmm5,%xmm5

// CHECK: 	andnps	3735928559(%ebx,%ecx,8), %xmm5
        	andnps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	andnps	69, %xmm5
        	andnps	0x45,%xmm5

// CHECK: 	andnps	32493, %xmm5
        	andnps	0x7eed,%xmm5

// CHECK: 	andnps	3133065982, %xmm5
        	andnps	0xbabecafe,%xmm5

// CHECK: 	andnps	305419896, %xmm5
        	andnps	0x12345678,%xmm5

// CHECK: 	andnps	%xmm5, %xmm5
        	andnps	%xmm5,%xmm5

// CHECK: 	andps	3735928559(%ebx,%ecx,8), %xmm5
        	andps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	andps	69, %xmm5
        	andps	0x45,%xmm5

// CHECK: 	andps	32493, %xmm5
        	andps	0x7eed,%xmm5

// CHECK: 	andps	3133065982, %xmm5
        	andps	0xbabecafe,%xmm5

// CHECK: 	andps	305419896, %xmm5
        	andps	0x12345678,%xmm5

// CHECK: 	andps	%xmm5, %xmm5
        	andps	%xmm5,%xmm5

// CHECK: 	comiss	3735928559(%ebx,%ecx,8), %xmm5
        	comiss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	comiss	69, %xmm5
        	comiss	0x45,%xmm5

// CHECK: 	comiss	32493, %xmm5
        	comiss	0x7eed,%xmm5

// CHECK: 	comiss	3133065982, %xmm5
        	comiss	0xbabecafe,%xmm5

// CHECK: 	comiss	305419896, %xmm5
        	comiss	0x12345678,%xmm5

// CHECK: 	comiss	%xmm5, %xmm5
        	comiss	%xmm5,%xmm5

// CHECK: 	cvtpi2ps	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpi2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpi2ps	69, %xmm5
        	cvtpi2ps	0x45,%xmm5

// CHECK: 	cvtpi2ps	32493, %xmm5
        	cvtpi2ps	0x7eed,%xmm5

// CHECK: 	cvtpi2ps	3133065982, %xmm5
        	cvtpi2ps	0xbabecafe,%xmm5

// CHECK: 	cvtpi2ps	305419896, %xmm5
        	cvtpi2ps	0x12345678,%xmm5

// CHECK: 	cvtpi2ps	%mm3, %xmm5
        	cvtpi2ps	%mm3,%xmm5

// CHECK: 	cvtps2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvtps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvtps2pi	69, %mm3
        	cvtps2pi	0x45,%mm3

// CHECK: 	cvtps2pi	32493, %mm3
        	cvtps2pi	0x7eed,%mm3

// CHECK: 	cvtps2pi	3133065982, %mm3
        	cvtps2pi	0xbabecafe,%mm3

// CHECK: 	cvtps2pi	305419896, %mm3
        	cvtps2pi	0x12345678,%mm3

// CHECK: 	cvtps2pi	%xmm5, %mm3
        	cvtps2pi	%xmm5,%mm3

// CHECK: 	cvtsi2ss	%ecx, %xmm5
        	cvtsi2ss	%ecx,%xmm5

// CHECK: 	cvtsi2ss	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsi2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtsi2ss	69, %xmm5
        	cvtsi2ss	0x45,%xmm5

// CHECK: 	cvtsi2ss	32493, %xmm5
        	cvtsi2ss	0x7eed,%xmm5

// CHECK: 	cvtsi2ss	3133065982, %xmm5
        	cvtsi2ss	0xbabecafe,%xmm5

// CHECK: 	cvtsi2ss	305419896, %xmm5
        	cvtsi2ss	0x12345678,%xmm5

// CHECK: 	cvttps2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvttps2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvttps2pi	69, %mm3
        	cvttps2pi	0x45,%mm3

// CHECK: 	cvttps2pi	32493, %mm3
        	cvttps2pi	0x7eed,%mm3

// CHECK: 	cvttps2pi	3133065982, %mm3
        	cvttps2pi	0xbabecafe,%mm3

// CHECK: 	cvttps2pi	305419896, %mm3
        	cvttps2pi	0x12345678,%mm3

// CHECK: 	cvttps2pi	%xmm5, %mm3
        	cvttps2pi	%xmm5,%mm3

// CHECK: 	cvttss2si	3735928559(%ebx,%ecx,8), %ecx
        	cvttss2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	cvttss2si	69, %ecx
        	cvttss2si	0x45,%ecx

// CHECK: 	cvttss2si	32493, %ecx
        	cvttss2si	0x7eed,%ecx

// CHECK: 	cvttss2si	3133065982, %ecx
        	cvttss2si	0xbabecafe,%ecx

// CHECK: 	cvttss2si	305419896, %ecx
        	cvttss2si	0x12345678,%ecx

// CHECK: 	cvttss2si	%xmm5, %ecx
        	cvttss2si	%xmm5,%ecx

// CHECK: 	divps	3735928559(%ebx,%ecx,8), %xmm5
        	divps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	divps	69, %xmm5
        	divps	0x45,%xmm5

// CHECK: 	divps	32493, %xmm5
        	divps	0x7eed,%xmm5

// CHECK: 	divps	3133065982, %xmm5
        	divps	0xbabecafe,%xmm5

// CHECK: 	divps	305419896, %xmm5
        	divps	0x12345678,%xmm5

// CHECK: 	divps	%xmm5, %xmm5
        	divps	%xmm5,%xmm5

// CHECK: 	divss	3735928559(%ebx,%ecx,8), %xmm5
        	divss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	divss	69, %xmm5
        	divss	0x45,%xmm5

// CHECK: 	divss	32493, %xmm5
        	divss	0x7eed,%xmm5

// CHECK: 	divss	3133065982, %xmm5
        	divss	0xbabecafe,%xmm5

// CHECK: 	divss	305419896, %xmm5
        	divss	0x12345678,%xmm5

// CHECK: 	divss	%xmm5, %xmm5
        	divss	%xmm5,%xmm5

// CHECK: 	ldmxcsr	3735928559(%ebx,%ecx,8)
        	ldmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	ldmxcsr	32493
        	ldmxcsr	0x7eed

// CHECK: 	ldmxcsr	3133065982
        	ldmxcsr	0xbabecafe

// CHECK: 	ldmxcsr	305419896
        	ldmxcsr	0x12345678

// CHECK: 	maskmovq	%mm3, %mm3
        	maskmovq	%mm3,%mm3

// CHECK: 	maxps	3735928559(%ebx,%ecx,8), %xmm5
        	maxps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	maxps	69, %xmm5
        	maxps	0x45,%xmm5

// CHECK: 	maxps	32493, %xmm5
        	maxps	0x7eed,%xmm5

// CHECK: 	maxps	3133065982, %xmm5
        	maxps	0xbabecafe,%xmm5

// CHECK: 	maxps	305419896, %xmm5
        	maxps	0x12345678,%xmm5

// CHECK: 	maxps	%xmm5, %xmm5
        	maxps	%xmm5,%xmm5

// CHECK: 	maxss	3735928559(%ebx,%ecx,8), %xmm5
        	maxss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	maxss	69, %xmm5
        	maxss	0x45,%xmm5

// CHECK: 	maxss	32493, %xmm5
        	maxss	0x7eed,%xmm5

// CHECK: 	maxss	3133065982, %xmm5
        	maxss	0xbabecafe,%xmm5

// CHECK: 	maxss	305419896, %xmm5
        	maxss	0x12345678,%xmm5

// CHECK: 	maxss	%xmm5, %xmm5
        	maxss	%xmm5,%xmm5

// CHECK: 	minps	3735928559(%ebx,%ecx,8), %xmm5
        	minps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	minps	69, %xmm5
        	minps	0x45,%xmm5

// CHECK: 	minps	32493, %xmm5
        	minps	0x7eed,%xmm5

// CHECK: 	minps	3133065982, %xmm5
        	minps	0xbabecafe,%xmm5

// CHECK: 	minps	305419896, %xmm5
        	minps	0x12345678,%xmm5

// CHECK: 	minps	%xmm5, %xmm5
        	minps	%xmm5,%xmm5

// CHECK: 	minss	3735928559(%ebx,%ecx,8), %xmm5
        	minss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	minss	69, %xmm5
        	minss	0x45,%xmm5

// CHECK: 	minss	32493, %xmm5
        	minss	0x7eed,%xmm5

// CHECK: 	minss	3133065982, %xmm5
        	minss	0xbabecafe,%xmm5

// CHECK: 	minss	305419896, %xmm5
        	minss	0x12345678,%xmm5

// CHECK: 	minss	%xmm5, %xmm5
        	minss	%xmm5,%xmm5

// CHECK: 	movaps	3735928559(%ebx,%ecx,8), %xmm5
        	movaps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movaps	69, %xmm5
        	movaps	0x45,%xmm5

// CHECK: 	movaps	32493, %xmm5
        	movaps	0x7eed,%xmm5

// CHECK: 	movaps	3133065982, %xmm5
        	movaps	0xbabecafe,%xmm5

// CHECK: 	movaps	305419896, %xmm5
        	movaps	0x12345678,%xmm5

// CHECK: 	movaps	%xmm5, %xmm5
        	movaps	%xmm5,%xmm5

// CHECK: 	movaps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movaps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movaps	%xmm5, 69
        	movaps	%xmm5,0x45

// CHECK: 	movaps	%xmm5, 32493
        	movaps	%xmm5,0x7eed

// CHECK: 	movaps	%xmm5, 3133065982
        	movaps	%xmm5,0xbabecafe

// CHECK: 	movaps	%xmm5, 305419896
        	movaps	%xmm5,0x12345678

// CHECK: 	movaps	%xmm5, %xmm5
        	movaps	%xmm5,%xmm5

// CHECK: 	movhlps	%xmm5, %xmm5
        	movhlps	%xmm5,%xmm5

// CHECK: 	movhps	3735928559(%ebx,%ecx,8), %xmm5
        	movhps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movhps	69, %xmm5
        	movhps	0x45,%xmm5

// CHECK: 	movhps	32493, %xmm5
        	movhps	0x7eed,%xmm5

// CHECK: 	movhps	3133065982, %xmm5
        	movhps	0xbabecafe,%xmm5

// CHECK: 	movhps	305419896, %xmm5
        	movhps	0x12345678,%xmm5

// CHECK: 	movhps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movhps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movhps	%xmm5, 69
        	movhps	%xmm5,0x45

// CHECK: 	movhps	%xmm5, 32493
        	movhps	%xmm5,0x7eed

// CHECK: 	movhps	%xmm5, 3133065982
        	movhps	%xmm5,0xbabecafe

// CHECK: 	movhps	%xmm5, 305419896
        	movhps	%xmm5,0x12345678

// CHECK: 	movlhps	%xmm5, %xmm5
        	movlhps	%xmm5,%xmm5

// CHECK: 	movlps	3735928559(%ebx,%ecx,8), %xmm5
        	movlps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movlps	69, %xmm5
        	movlps	0x45,%xmm5

// CHECK: 	movlps	32493, %xmm5
        	movlps	0x7eed,%xmm5

// CHECK: 	movlps	3133065982, %xmm5
        	movlps	0xbabecafe,%xmm5

// CHECK: 	movlps	305419896, %xmm5
        	movlps	0x12345678,%xmm5

// CHECK: 	movlps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movlps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movlps	%xmm5, 69
        	movlps	%xmm5,0x45

// CHECK: 	movlps	%xmm5, 32493
        	movlps	%xmm5,0x7eed

// CHECK: 	movlps	%xmm5, 3133065982
        	movlps	%xmm5,0xbabecafe

// CHECK: 	movlps	%xmm5, 305419896
        	movlps	%xmm5,0x12345678

// CHECK: 	movmskps	%xmm5, %ecx
        	movmskps	%xmm5,%ecx

// CHECK: 	movntps	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntps	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntps	%xmm5, 69
        	movntps	%xmm5,0x45

// CHECK: 	movntps	%xmm5, 32493
        	movntps	%xmm5,0x7eed

// CHECK: 	movntps	%xmm5, 3133065982
        	movntps	%xmm5,0xbabecafe

// CHECK: 	movntps	%xmm5, 305419896
        	movntps	%xmm5,0x12345678

// CHECK: 	movntq	%mm3, 3735928559(%ebx,%ecx,8)
        	movntq	%mm3,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntq	%mm3, 69
        	movntq	%mm3,0x45

// CHECK: 	movntq	%mm3, 32493
        	movntq	%mm3,0x7eed

// CHECK: 	movntq	%mm3, 3133065982
        	movntq	%mm3,0xbabecafe

// CHECK: 	movntq	%mm3, 305419896
        	movntq	%mm3,0x12345678

// CHECK: 	movntdq	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntdq	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntdq	%xmm5, 69
        	movntdq	%xmm5,0x45

// CHECK: 	movntdq	%xmm5, 32493
        	movntdq	%xmm5,0x7eed

// CHECK: 	movntdq	%xmm5, 3133065982
        	movntdq	%xmm5,0xbabecafe

// CHECK: 	movntdq	%xmm5, 305419896
        	movntdq	%xmm5,0x12345678

// CHECK: 	movss	3735928559(%ebx,%ecx,8), %xmm5
        	movss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movss	69, %xmm5
        	movss	0x45,%xmm5

// CHECK: 	movss	32493, %xmm5
        	movss	0x7eed,%xmm5

// CHECK: 	movss	3133065982, %xmm5
        	movss	0xbabecafe,%xmm5

// CHECK: 	movss	305419896, %xmm5
        	movss	0x12345678,%xmm5

// CHECK: 	movss	%xmm5, %xmm5
        	movss	%xmm5,%xmm5

// CHECK: 	movss	%xmm5, 3735928559(%ebx,%ecx,8)
        	movss	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movss	%xmm5, 69
        	movss	%xmm5,0x45

// CHECK: 	movss	%xmm5, 32493
        	movss	%xmm5,0x7eed

// CHECK: 	movss	%xmm5, 3133065982
        	movss	%xmm5,0xbabecafe

// CHECK: 	movss	%xmm5, 305419896
        	movss	%xmm5,0x12345678

// CHECK: 	movss	%xmm5, %xmm5
        	movss	%xmm5,%xmm5

// CHECK: 	movups	3735928559(%ebx,%ecx,8), %xmm5
        	movups	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movups	69, %xmm5
        	movups	0x45,%xmm5

// CHECK: 	movups	32493, %xmm5
        	movups	0x7eed,%xmm5

// CHECK: 	movups	3133065982, %xmm5
        	movups	0xbabecafe,%xmm5

// CHECK: 	movups	305419896, %xmm5
        	movups	0x12345678,%xmm5

// CHECK: 	movups	%xmm5, %xmm5
        	movups	%xmm5,%xmm5

// CHECK: 	movups	%xmm5, 3735928559(%ebx,%ecx,8)
        	movups	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movups	%xmm5, 69
        	movups	%xmm5,0x45

// CHECK: 	movups	%xmm5, 32493
        	movups	%xmm5,0x7eed

// CHECK: 	movups	%xmm5, 3133065982
        	movups	%xmm5,0xbabecafe

// CHECK: 	movups	%xmm5, 305419896
        	movups	%xmm5,0x12345678

// CHECK: 	movups	%xmm5, %xmm5
        	movups	%xmm5,%xmm5

// CHECK: 	mulps	3735928559(%ebx,%ecx,8), %xmm5
        	mulps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	mulps	69, %xmm5
        	mulps	0x45,%xmm5

// CHECK: 	mulps	32493, %xmm5
        	mulps	0x7eed,%xmm5

// CHECK: 	mulps	3133065982, %xmm5
        	mulps	0xbabecafe,%xmm5

// CHECK: 	mulps	305419896, %xmm5
        	mulps	0x12345678,%xmm5

// CHECK: 	mulps	%xmm5, %xmm5
        	mulps	%xmm5,%xmm5

// CHECK: 	mulss	3735928559(%ebx,%ecx,8), %xmm5
        	mulss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	mulss	69, %xmm5
        	mulss	0x45,%xmm5

// CHECK: 	mulss	32493, %xmm5
        	mulss	0x7eed,%xmm5

// CHECK: 	mulss	3133065982, %xmm5
        	mulss	0xbabecafe,%xmm5

// CHECK: 	mulss	305419896, %xmm5
        	mulss	0x12345678,%xmm5

// CHECK: 	mulss	%xmm5, %xmm5
        	mulss	%xmm5,%xmm5

// CHECK: 	orps	3735928559(%ebx,%ecx,8), %xmm5
        	orps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	orps	69, %xmm5
        	orps	0x45,%xmm5

// CHECK: 	orps	32493, %xmm5
        	orps	0x7eed,%xmm5

// CHECK: 	orps	3133065982, %xmm5
        	orps	0xbabecafe,%xmm5

// CHECK: 	orps	305419896, %xmm5
        	orps	0x12345678,%xmm5

// CHECK: 	orps	%xmm5, %xmm5
        	orps	%xmm5,%xmm5

// CHECK: 	pavgb	3735928559(%ebx,%ecx,8), %mm3
        	pavgb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pavgb	69, %mm3
        	pavgb	0x45,%mm3

// CHECK: 	pavgb	32493, %mm3
        	pavgb	0x7eed,%mm3

// CHECK: 	pavgb	3133065982, %mm3
        	pavgb	0xbabecafe,%mm3

// CHECK: 	pavgb	305419896, %mm3
        	pavgb	0x12345678,%mm3

// CHECK: 	pavgb	%mm3, %mm3
        	pavgb	%mm3,%mm3

// CHECK: 	pavgb	3735928559(%ebx,%ecx,8), %xmm5
        	pavgb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pavgb	69, %xmm5
        	pavgb	0x45,%xmm5

// CHECK: 	pavgb	32493, %xmm5
        	pavgb	0x7eed,%xmm5

// CHECK: 	pavgb	3133065982, %xmm5
        	pavgb	0xbabecafe,%xmm5

// CHECK: 	pavgb	305419896, %xmm5
        	pavgb	0x12345678,%xmm5

// CHECK: 	pavgb	%xmm5, %xmm5
        	pavgb	%xmm5,%xmm5

// CHECK: 	pavgw	3735928559(%ebx,%ecx,8), %mm3
        	pavgw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pavgw	69, %mm3
        	pavgw	0x45,%mm3

// CHECK: 	pavgw	32493, %mm3
        	pavgw	0x7eed,%mm3

// CHECK: 	pavgw	3133065982, %mm3
        	pavgw	0xbabecafe,%mm3

// CHECK: 	pavgw	305419896, %mm3
        	pavgw	0x12345678,%mm3

// CHECK: 	pavgw	%mm3, %mm3
        	pavgw	%mm3,%mm3

// CHECK: 	pavgw	3735928559(%ebx,%ecx,8), %xmm5
        	pavgw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pavgw	69, %xmm5
        	pavgw	0x45,%xmm5

// CHECK: 	pavgw	32493, %xmm5
        	pavgw	0x7eed,%xmm5

// CHECK: 	pavgw	3133065982, %xmm5
        	pavgw	0xbabecafe,%xmm5

// CHECK: 	pavgw	305419896, %xmm5
        	pavgw	0x12345678,%xmm5

// CHECK: 	pavgw	%xmm5, %xmm5
        	pavgw	%xmm5,%xmm5

// CHECK: 	pmaxsw	3735928559(%ebx,%ecx,8), %mm3
        	pmaxsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmaxsw	69, %mm3
        	pmaxsw	0x45,%mm3

// CHECK: 	pmaxsw	32493, %mm3
        	pmaxsw	0x7eed,%mm3

// CHECK: 	pmaxsw	3133065982, %mm3
        	pmaxsw	0xbabecafe,%mm3

// CHECK: 	pmaxsw	305419896, %mm3
        	pmaxsw	0x12345678,%mm3

// CHECK: 	pmaxsw	%mm3, %mm3
        	pmaxsw	%mm3,%mm3

// CHECK: 	pmaxsw	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxsw	69, %xmm5
        	pmaxsw	0x45,%xmm5

// CHECK: 	pmaxsw	32493, %xmm5
        	pmaxsw	0x7eed,%xmm5

// CHECK: 	pmaxsw	3133065982, %xmm5
        	pmaxsw	0xbabecafe,%xmm5

// CHECK: 	pmaxsw	305419896, %xmm5
        	pmaxsw	0x12345678,%xmm5

// CHECK: 	pmaxsw	%xmm5, %xmm5
        	pmaxsw	%xmm5,%xmm5

// CHECK: 	pmaxub	3735928559(%ebx,%ecx,8), %mm3
        	pmaxub	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmaxub	69, %mm3
        	pmaxub	0x45,%mm3

// CHECK: 	pmaxub	32493, %mm3
        	pmaxub	0x7eed,%mm3

// CHECK: 	pmaxub	3133065982, %mm3
        	pmaxub	0xbabecafe,%mm3

// CHECK: 	pmaxub	305419896, %mm3
        	pmaxub	0x12345678,%mm3

// CHECK: 	pmaxub	%mm3, %mm3
        	pmaxub	%mm3,%mm3

// CHECK: 	pmaxub	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxub	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxub	69, %xmm5
        	pmaxub	0x45,%xmm5

// CHECK: 	pmaxub	32493, %xmm5
        	pmaxub	0x7eed,%xmm5

// CHECK: 	pmaxub	3133065982, %xmm5
        	pmaxub	0xbabecafe,%xmm5

// CHECK: 	pmaxub	305419896, %xmm5
        	pmaxub	0x12345678,%xmm5

// CHECK: 	pmaxub	%xmm5, %xmm5
        	pmaxub	%xmm5,%xmm5

// CHECK: 	pminsw	3735928559(%ebx,%ecx,8), %mm3
        	pminsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pminsw	69, %mm3
        	pminsw	0x45,%mm3

// CHECK: 	pminsw	32493, %mm3
        	pminsw	0x7eed,%mm3

// CHECK: 	pminsw	3133065982, %mm3
        	pminsw	0xbabecafe,%mm3

// CHECK: 	pminsw	305419896, %mm3
        	pminsw	0x12345678,%mm3

// CHECK: 	pminsw	%mm3, %mm3
        	pminsw	%mm3,%mm3

// CHECK: 	pminsw	3735928559(%ebx,%ecx,8), %xmm5
        	pminsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminsw	69, %xmm5
        	pminsw	0x45,%xmm5

// CHECK: 	pminsw	32493, %xmm5
        	pminsw	0x7eed,%xmm5

// CHECK: 	pminsw	3133065982, %xmm5
        	pminsw	0xbabecafe,%xmm5

// CHECK: 	pminsw	305419896, %xmm5
        	pminsw	0x12345678,%xmm5

// CHECK: 	pminsw	%xmm5, %xmm5
        	pminsw	%xmm5,%xmm5

// CHECK: 	pminub	3735928559(%ebx,%ecx,8), %mm3
        	pminub	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pminub	69, %mm3
        	pminub	0x45,%mm3

// CHECK: 	pminub	32493, %mm3
        	pminub	0x7eed,%mm3

// CHECK: 	pminub	3133065982, %mm3
        	pminub	0xbabecafe,%mm3

// CHECK: 	pminub	305419896, %mm3
        	pminub	0x12345678,%mm3

// CHECK: 	pminub	%mm3, %mm3
        	pminub	%mm3,%mm3

// CHECK: 	pminub	3735928559(%ebx,%ecx,8), %xmm5
        	pminub	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminub	69, %xmm5
        	pminub	0x45,%xmm5

// CHECK: 	pminub	32493, %xmm5
        	pminub	0x7eed,%xmm5

// CHECK: 	pminub	3133065982, %xmm5
        	pminub	0xbabecafe,%xmm5

// CHECK: 	pminub	305419896, %xmm5
        	pminub	0x12345678,%xmm5

// CHECK: 	pminub	%xmm5, %xmm5
        	pminub	%xmm5,%xmm5

// CHECK: 	pmovmskb	%mm3, %ecx
        	pmovmskb	%mm3,%ecx

// CHECK: 	pmovmskb	%xmm5, %ecx
        	pmovmskb	%xmm5,%ecx

// CHECK: 	pmulhuw	3735928559(%ebx,%ecx,8), %mm3
        	pmulhuw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmulhuw	69, %mm3
        	pmulhuw	0x45,%mm3

// CHECK: 	pmulhuw	32493, %mm3
        	pmulhuw	0x7eed,%mm3

// CHECK: 	pmulhuw	3133065982, %mm3
        	pmulhuw	0xbabecafe,%mm3

// CHECK: 	pmulhuw	305419896, %mm3
        	pmulhuw	0x12345678,%mm3

// CHECK: 	pmulhuw	%mm3, %mm3
        	pmulhuw	%mm3,%mm3

// CHECK: 	pmulhuw	3735928559(%ebx,%ecx,8), %xmm5
        	pmulhuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmulhuw	69, %xmm5
        	pmulhuw	0x45,%xmm5

// CHECK: 	pmulhuw	32493, %xmm5
        	pmulhuw	0x7eed,%xmm5

// CHECK: 	pmulhuw	3133065982, %xmm5
        	pmulhuw	0xbabecafe,%xmm5

// CHECK: 	pmulhuw	305419896, %xmm5
        	pmulhuw	0x12345678,%xmm5

// CHECK: 	pmulhuw	%xmm5, %xmm5
        	pmulhuw	%xmm5,%xmm5

// CHECK: 	prefetchnta	3735928559(%ebx,%ecx,8)
        	prefetchnta	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetchnta	32493
        	prefetchnta	0x7eed

// CHECK: 	prefetchnta	3133065982
        	prefetchnta	0xbabecafe

// CHECK: 	prefetchnta	305419896
        	prefetchnta	0x12345678

// CHECK: 	prefetcht0	3735928559(%ebx,%ecx,8)
        	prefetcht0	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht0	32493
        	prefetcht0	0x7eed

// CHECK: 	prefetcht0	3133065982
        	prefetcht0	0xbabecafe

// CHECK: 	prefetcht0	305419896
        	prefetcht0	0x12345678

// CHECK: 	prefetcht1	3735928559(%ebx,%ecx,8)
        	prefetcht1	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht1	32493
        	prefetcht1	0x7eed

// CHECK: 	prefetcht1	3133065982
        	prefetcht1	0xbabecafe

// CHECK: 	prefetcht1	305419896
        	prefetcht1	0x12345678

// CHECK: 	prefetcht2	3735928559(%ebx,%ecx,8)
        	prefetcht2	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	prefetcht2	32493
        	prefetcht2	0x7eed

// CHECK: 	prefetcht2	3133065982
        	prefetcht2	0xbabecafe

// CHECK: 	prefetcht2	305419896
        	prefetcht2	0x12345678

// CHECK: 	psadbw	3735928559(%ebx,%ecx,8), %mm3
        	psadbw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psadbw	69, %mm3
        	psadbw	0x45,%mm3

// CHECK: 	psadbw	32493, %mm3
        	psadbw	0x7eed,%mm3

// CHECK: 	psadbw	3133065982, %mm3
        	psadbw	0xbabecafe,%mm3

// CHECK: 	psadbw	305419896, %mm3
        	psadbw	0x12345678,%mm3

// CHECK: 	psadbw	%mm3, %mm3
        	psadbw	%mm3,%mm3

// CHECK: 	psadbw	3735928559(%ebx,%ecx,8), %xmm5
        	psadbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psadbw	69, %xmm5
        	psadbw	0x45,%xmm5

// CHECK: 	psadbw	32493, %xmm5
        	psadbw	0x7eed,%xmm5

// CHECK: 	psadbw	3133065982, %xmm5
        	psadbw	0xbabecafe,%xmm5

// CHECK: 	psadbw	305419896, %xmm5
        	psadbw	0x12345678,%xmm5

// CHECK: 	psadbw	%xmm5, %xmm5
        	psadbw	%xmm5,%xmm5

// CHECK: 	rcpps	3735928559(%ebx,%ecx,8), %xmm5
        	rcpps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rcpps	69, %xmm5
        	rcpps	0x45,%xmm5

// CHECK: 	rcpps	32493, %xmm5
        	rcpps	0x7eed,%xmm5

// CHECK: 	rcpps	3133065982, %xmm5
        	rcpps	0xbabecafe,%xmm5

// CHECK: 	rcpps	305419896, %xmm5
        	rcpps	0x12345678,%xmm5

// CHECK: 	rcpps	%xmm5, %xmm5
        	rcpps	%xmm5,%xmm5

// CHECK: 	rcpss	3735928559(%ebx,%ecx,8), %xmm5
        	rcpss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rcpss	69, %xmm5
        	rcpss	0x45,%xmm5

// CHECK: 	rcpss	32493, %xmm5
        	rcpss	0x7eed,%xmm5

// CHECK: 	rcpss	3133065982, %xmm5
        	rcpss	0xbabecafe,%xmm5

// CHECK: 	rcpss	305419896, %xmm5
        	rcpss	0x12345678,%xmm5

// CHECK: 	rcpss	%xmm5, %xmm5
        	rcpss	%xmm5,%xmm5

// CHECK: 	rsqrtps	3735928559(%ebx,%ecx,8), %xmm5
        	rsqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rsqrtps	69, %xmm5
        	rsqrtps	0x45,%xmm5

// CHECK: 	rsqrtps	32493, %xmm5
        	rsqrtps	0x7eed,%xmm5

// CHECK: 	rsqrtps	3133065982, %xmm5
        	rsqrtps	0xbabecafe,%xmm5

// CHECK: 	rsqrtps	305419896, %xmm5
        	rsqrtps	0x12345678,%xmm5

// CHECK: 	rsqrtps	%xmm5, %xmm5
        	rsqrtps	%xmm5,%xmm5

// CHECK: 	rsqrtss	3735928559(%ebx,%ecx,8), %xmm5
        	rsqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	rsqrtss	69, %xmm5
        	rsqrtss	0x45,%xmm5

// CHECK: 	rsqrtss	32493, %xmm5
        	rsqrtss	0x7eed,%xmm5

// CHECK: 	rsqrtss	3133065982, %xmm5
        	rsqrtss	0xbabecafe,%xmm5

// CHECK: 	rsqrtss	305419896, %xmm5
        	rsqrtss	0x12345678,%xmm5

// CHECK: 	rsqrtss	%xmm5, %xmm5
        	rsqrtss	%xmm5,%xmm5

// CHECK: 	sfence
        	sfence

// CHECK: 	sqrtps	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtps	69, %xmm5
        	sqrtps	0x45,%xmm5

// CHECK: 	sqrtps	32493, %xmm5
        	sqrtps	0x7eed,%xmm5

// CHECK: 	sqrtps	3133065982, %xmm5
        	sqrtps	0xbabecafe,%xmm5

// CHECK: 	sqrtps	305419896, %xmm5
        	sqrtps	0x12345678,%xmm5

// CHECK: 	sqrtps	%xmm5, %xmm5
        	sqrtps	%xmm5,%xmm5

// CHECK: 	sqrtss	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtss	69, %xmm5
        	sqrtss	0x45,%xmm5

// CHECK: 	sqrtss	32493, %xmm5
        	sqrtss	0x7eed,%xmm5

// CHECK: 	sqrtss	3133065982, %xmm5
        	sqrtss	0xbabecafe,%xmm5

// CHECK: 	sqrtss	305419896, %xmm5
        	sqrtss	0x12345678,%xmm5

// CHECK: 	sqrtss	%xmm5, %xmm5
        	sqrtss	%xmm5,%xmm5

// CHECK: 	stmxcsr	3735928559(%ebx,%ecx,8)
        	stmxcsr	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	stmxcsr	32493
        	stmxcsr	0x7eed

// CHECK: 	stmxcsr	3133065982
        	stmxcsr	0xbabecafe

// CHECK: 	stmxcsr	305419896
        	stmxcsr	0x12345678

// CHECK: 	subps	3735928559(%ebx,%ecx,8), %xmm5
        	subps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	subps	69, %xmm5
        	subps	0x45,%xmm5

// CHECK: 	subps	32493, %xmm5
        	subps	0x7eed,%xmm5

// CHECK: 	subps	3133065982, %xmm5
        	subps	0xbabecafe,%xmm5

// CHECK: 	subps	305419896, %xmm5
        	subps	0x12345678,%xmm5

// CHECK: 	subps	%xmm5, %xmm5
        	subps	%xmm5,%xmm5

// CHECK: 	subss	3735928559(%ebx,%ecx,8), %xmm5
        	subss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	subss	69, %xmm5
        	subss	0x45,%xmm5

// CHECK: 	subss	32493, %xmm5
        	subss	0x7eed,%xmm5

// CHECK: 	subss	3133065982, %xmm5
        	subss	0xbabecafe,%xmm5

// CHECK: 	subss	305419896, %xmm5
        	subss	0x12345678,%xmm5

// CHECK: 	subss	%xmm5, %xmm5
        	subss	%xmm5,%xmm5

// CHECK: 	ucomiss	3735928559(%ebx,%ecx,8), %xmm5
        	ucomiss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ucomiss	69, %xmm5
        	ucomiss	0x45,%xmm5

// CHECK: 	ucomiss	32493, %xmm5
        	ucomiss	0x7eed,%xmm5

// CHECK: 	ucomiss	3133065982, %xmm5
        	ucomiss	0xbabecafe,%xmm5

// CHECK: 	ucomiss	305419896, %xmm5
        	ucomiss	0x12345678,%xmm5

// CHECK: 	ucomiss	%xmm5, %xmm5
        	ucomiss	%xmm5,%xmm5

// CHECK: 	unpckhps	3735928559(%ebx,%ecx,8), %xmm5
        	unpckhps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	unpckhps	69, %xmm5
        	unpckhps	0x45,%xmm5

// CHECK: 	unpckhps	32493, %xmm5
        	unpckhps	0x7eed,%xmm5

// CHECK: 	unpckhps	3133065982, %xmm5
        	unpckhps	0xbabecafe,%xmm5

// CHECK: 	unpckhps	305419896, %xmm5
        	unpckhps	0x12345678,%xmm5

// CHECK: 	unpckhps	%xmm5, %xmm5
        	unpckhps	%xmm5,%xmm5

// CHECK: 	unpcklps	3735928559(%ebx,%ecx,8), %xmm5
        	unpcklps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	unpcklps	69, %xmm5
        	unpcklps	0x45,%xmm5

// CHECK: 	unpcklps	32493, %xmm5
        	unpcklps	0x7eed,%xmm5

// CHECK: 	unpcklps	3133065982, %xmm5
        	unpcklps	0xbabecafe,%xmm5

// CHECK: 	unpcklps	305419896, %xmm5
        	unpcklps	0x12345678,%xmm5

// CHECK: 	unpcklps	%xmm5, %xmm5
        	unpcklps	%xmm5,%xmm5

// CHECK: 	xorps	3735928559(%ebx,%ecx,8), %xmm5
        	xorps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	xorps	69, %xmm5
        	xorps	0x45,%xmm5

// CHECK: 	xorps	32493, %xmm5
        	xorps	0x7eed,%xmm5

// CHECK: 	xorps	3133065982, %xmm5
        	xorps	0xbabecafe,%xmm5

// CHECK: 	xorps	305419896, %xmm5
        	xorps	0x12345678,%xmm5

// CHECK: 	xorps	%xmm5, %xmm5
        	xorps	%xmm5,%xmm5

// CHECK: 	addpd	3735928559(%ebx,%ecx,8), %xmm5
        	addpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addpd	69, %xmm5
        	addpd	0x45,%xmm5

// CHECK: 	addpd	32493, %xmm5
        	addpd	0x7eed,%xmm5

// CHECK: 	addpd	3133065982, %xmm5
        	addpd	0xbabecafe,%xmm5

// CHECK: 	addpd	305419896, %xmm5
        	addpd	0x12345678,%xmm5

// CHECK: 	addpd	%xmm5, %xmm5
        	addpd	%xmm5,%xmm5

// CHECK: 	addsd	3735928559(%ebx,%ecx,8), %xmm5
        	addsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addsd	69, %xmm5
        	addsd	0x45,%xmm5

// CHECK: 	addsd	32493, %xmm5
        	addsd	0x7eed,%xmm5

// CHECK: 	addsd	3133065982, %xmm5
        	addsd	0xbabecafe,%xmm5

// CHECK: 	addsd	305419896, %xmm5
        	addsd	0x12345678,%xmm5

// CHECK: 	addsd	%xmm5, %xmm5
        	addsd	%xmm5,%xmm5

// CHECK: 	andnpd	3735928559(%ebx,%ecx,8), %xmm5
        	andnpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	andnpd	69, %xmm5
        	andnpd	0x45,%xmm5

// CHECK: 	andnpd	32493, %xmm5
        	andnpd	0x7eed,%xmm5

// CHECK: 	andnpd	3133065982, %xmm5
        	andnpd	0xbabecafe,%xmm5

// CHECK: 	andnpd	305419896, %xmm5
        	andnpd	0x12345678,%xmm5

// CHECK: 	andnpd	%xmm5, %xmm5
        	andnpd	%xmm5,%xmm5

// CHECK: 	andpd	3735928559(%ebx,%ecx,8), %xmm5
        	andpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	andpd	69, %xmm5
        	andpd	0x45,%xmm5

// CHECK: 	andpd	32493, %xmm5
        	andpd	0x7eed,%xmm5

// CHECK: 	andpd	3133065982, %xmm5
        	andpd	0xbabecafe,%xmm5

// CHECK: 	andpd	305419896, %xmm5
        	andpd	0x12345678,%xmm5

// CHECK: 	andpd	%xmm5, %xmm5
        	andpd	%xmm5,%xmm5

// CHECK: 	comisd	3735928559(%ebx,%ecx,8), %xmm5
        	comisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	comisd	69, %xmm5
        	comisd	0x45,%xmm5

// CHECK: 	comisd	32493, %xmm5
        	comisd	0x7eed,%xmm5

// CHECK: 	comisd	3133065982, %xmm5
        	comisd	0xbabecafe,%xmm5

// CHECK: 	comisd	305419896, %xmm5
        	comisd	0x12345678,%xmm5

// CHECK: 	comisd	%xmm5, %xmm5
        	comisd	%xmm5,%xmm5

// CHECK: 	cvtpi2pd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpi2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpi2pd	69, %xmm5
        	cvtpi2pd	0x45,%xmm5

// CHECK: 	cvtpi2pd	32493, %xmm5
        	cvtpi2pd	0x7eed,%xmm5

// CHECK: 	cvtpi2pd	3133065982, %xmm5
        	cvtpi2pd	0xbabecafe,%xmm5

// CHECK: 	cvtpi2pd	305419896, %xmm5
        	cvtpi2pd	0x12345678,%xmm5

// CHECK: 	cvtpi2pd	%mm3, %xmm5
        	cvtpi2pd	%mm3,%xmm5

// CHECK: 	cvtsi2sd	%ecx, %xmm5
        	cvtsi2sd	%ecx,%xmm5

// CHECK: 	cvtsi2sd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsi2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtsi2sd	69, %xmm5
        	cvtsi2sd	0x45,%xmm5

// CHECK: 	cvtsi2sd	32493, %xmm5
        	cvtsi2sd	0x7eed,%xmm5

// CHECK: 	cvtsi2sd	3133065982, %xmm5
        	cvtsi2sd	0xbabecafe,%xmm5

// CHECK: 	cvtsi2sd	305419896, %xmm5
        	cvtsi2sd	0x12345678,%xmm5

// CHECK: 	divpd	3735928559(%ebx,%ecx,8), %xmm5
        	divpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	divpd	69, %xmm5
        	divpd	0x45,%xmm5

// CHECK: 	divpd	32493, %xmm5
        	divpd	0x7eed,%xmm5

// CHECK: 	divpd	3133065982, %xmm5
        	divpd	0xbabecafe,%xmm5

// CHECK: 	divpd	305419896, %xmm5
        	divpd	0x12345678,%xmm5

// CHECK: 	divpd	%xmm5, %xmm5
        	divpd	%xmm5,%xmm5

// CHECK: 	divsd	3735928559(%ebx,%ecx,8), %xmm5
        	divsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	divsd	69, %xmm5
        	divsd	0x45,%xmm5

// CHECK: 	divsd	32493, %xmm5
        	divsd	0x7eed,%xmm5

// CHECK: 	divsd	3133065982, %xmm5
        	divsd	0xbabecafe,%xmm5

// CHECK: 	divsd	305419896, %xmm5
        	divsd	0x12345678,%xmm5

// CHECK: 	divsd	%xmm5, %xmm5
        	divsd	%xmm5,%xmm5

// CHECK: 	maxpd	3735928559(%ebx,%ecx,8), %xmm5
        	maxpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	maxpd	69, %xmm5
        	maxpd	0x45,%xmm5

// CHECK: 	maxpd	32493, %xmm5
        	maxpd	0x7eed,%xmm5

// CHECK: 	maxpd	3133065982, %xmm5
        	maxpd	0xbabecafe,%xmm5

// CHECK: 	maxpd	305419896, %xmm5
        	maxpd	0x12345678,%xmm5

// CHECK: 	maxpd	%xmm5, %xmm5
        	maxpd	%xmm5,%xmm5

// CHECK: 	maxsd	3735928559(%ebx,%ecx,8), %xmm5
        	maxsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	maxsd	69, %xmm5
        	maxsd	0x45,%xmm5

// CHECK: 	maxsd	32493, %xmm5
        	maxsd	0x7eed,%xmm5

// CHECK: 	maxsd	3133065982, %xmm5
        	maxsd	0xbabecafe,%xmm5

// CHECK: 	maxsd	305419896, %xmm5
        	maxsd	0x12345678,%xmm5

// CHECK: 	maxsd	%xmm5, %xmm5
        	maxsd	%xmm5,%xmm5

// CHECK: 	minpd	3735928559(%ebx,%ecx,8), %xmm5
        	minpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	minpd	69, %xmm5
        	minpd	0x45,%xmm5

// CHECK: 	minpd	32493, %xmm5
        	minpd	0x7eed,%xmm5

// CHECK: 	minpd	3133065982, %xmm5
        	minpd	0xbabecafe,%xmm5

// CHECK: 	minpd	305419896, %xmm5
        	minpd	0x12345678,%xmm5

// CHECK: 	minpd	%xmm5, %xmm5
        	minpd	%xmm5,%xmm5

// CHECK: 	minsd	3735928559(%ebx,%ecx,8), %xmm5
        	minsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	minsd	69, %xmm5
        	minsd	0x45,%xmm5

// CHECK: 	minsd	32493, %xmm5
        	minsd	0x7eed,%xmm5

// CHECK: 	minsd	3133065982, %xmm5
        	minsd	0xbabecafe,%xmm5

// CHECK: 	minsd	305419896, %xmm5
        	minsd	0x12345678,%xmm5

// CHECK: 	minsd	%xmm5, %xmm5
        	minsd	%xmm5,%xmm5

// CHECK: 	movapd	3735928559(%ebx,%ecx,8), %xmm5
        	movapd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movapd	69, %xmm5
        	movapd	0x45,%xmm5

// CHECK: 	movapd	32493, %xmm5
        	movapd	0x7eed,%xmm5

// CHECK: 	movapd	3133065982, %xmm5
        	movapd	0xbabecafe,%xmm5

// CHECK: 	movapd	305419896, %xmm5
        	movapd	0x12345678,%xmm5

// CHECK: 	movapd	%xmm5, %xmm5
        	movapd	%xmm5,%xmm5

// CHECK: 	movapd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movapd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movapd	%xmm5, 69
        	movapd	%xmm5,0x45

// CHECK: 	movapd	%xmm5, 32493
        	movapd	%xmm5,0x7eed

// CHECK: 	movapd	%xmm5, 3133065982
        	movapd	%xmm5,0xbabecafe

// CHECK: 	movapd	%xmm5, 305419896
        	movapd	%xmm5,0x12345678

// CHECK: 	movapd	%xmm5, %xmm5
        	movapd	%xmm5,%xmm5

// CHECK: 	movhpd	3735928559(%ebx,%ecx,8), %xmm5
        	movhpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movhpd	69, %xmm5
        	movhpd	0x45,%xmm5

// CHECK: 	movhpd	32493, %xmm5
        	movhpd	0x7eed,%xmm5

// CHECK: 	movhpd	3133065982, %xmm5
        	movhpd	0xbabecafe,%xmm5

// CHECK: 	movhpd	305419896, %xmm5
        	movhpd	0x12345678,%xmm5

// CHECK: 	movhpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movhpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movhpd	%xmm5, 69
        	movhpd	%xmm5,0x45

// CHECK: 	movhpd	%xmm5, 32493
        	movhpd	%xmm5,0x7eed

// CHECK: 	movhpd	%xmm5, 3133065982
        	movhpd	%xmm5,0xbabecafe

// CHECK: 	movhpd	%xmm5, 305419896
        	movhpd	%xmm5,0x12345678

// CHECK: 	movlpd	3735928559(%ebx,%ecx,8), %xmm5
        	movlpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movlpd	69, %xmm5
        	movlpd	0x45,%xmm5

// CHECK: 	movlpd	32493, %xmm5
        	movlpd	0x7eed,%xmm5

// CHECK: 	movlpd	3133065982, %xmm5
        	movlpd	0xbabecafe,%xmm5

// CHECK: 	movlpd	305419896, %xmm5
        	movlpd	0x12345678,%xmm5

// CHECK: 	movlpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movlpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movlpd	%xmm5, 69
        	movlpd	%xmm5,0x45

// CHECK: 	movlpd	%xmm5, 32493
        	movlpd	%xmm5,0x7eed

// CHECK: 	movlpd	%xmm5, 3133065982
        	movlpd	%xmm5,0xbabecafe

// CHECK: 	movlpd	%xmm5, 305419896
        	movlpd	%xmm5,0x12345678

// CHECK: 	movmskpd	%xmm5, %ecx
        	movmskpd	%xmm5,%ecx

// CHECK: 	movntpd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movntpd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movntpd	%xmm5, 69
        	movntpd	%xmm5,0x45

// CHECK: 	movntpd	%xmm5, 32493
        	movntpd	%xmm5,0x7eed

// CHECK: 	movntpd	%xmm5, 3133065982
        	movntpd	%xmm5,0xbabecafe

// CHECK: 	movntpd	%xmm5, 305419896
        	movntpd	%xmm5,0x12345678

// CHECK: 	movsd	3735928559(%ebx,%ecx,8), %xmm5
        	movsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movsd	69, %xmm5
        	movsd	0x45,%xmm5

// CHECK: 	movsd	32493, %xmm5
        	movsd	0x7eed,%xmm5

// CHECK: 	movsd	3133065982, %xmm5
        	movsd	0xbabecafe,%xmm5

// CHECK: 	movsd	305419896, %xmm5
        	movsd	0x12345678,%xmm5

// CHECK: 	movsd	%xmm5, %xmm5
        	movsd	%xmm5,%xmm5

// CHECK: 	movsd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movsd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movsd	%xmm5, 69
        	movsd	%xmm5,0x45

// CHECK: 	movsd	%xmm5, 32493
        	movsd	%xmm5,0x7eed

// CHECK: 	movsd	%xmm5, 3133065982
        	movsd	%xmm5,0xbabecafe

// CHECK: 	movsd	%xmm5, 305419896
        	movsd	%xmm5,0x12345678

// CHECK: 	movsd	%xmm5, %xmm5
        	movsd	%xmm5,%xmm5

// CHECK: 	movupd	3735928559(%ebx,%ecx,8), %xmm5
        	movupd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movupd	69, %xmm5
        	movupd	0x45,%xmm5

// CHECK: 	movupd	32493, %xmm5
        	movupd	0x7eed,%xmm5

// CHECK: 	movupd	3133065982, %xmm5
        	movupd	0xbabecafe,%xmm5

// CHECK: 	movupd	305419896, %xmm5
        	movupd	0x12345678,%xmm5

// CHECK: 	movupd	%xmm5, %xmm5
        	movupd	%xmm5,%xmm5

// CHECK: 	movupd	%xmm5, 3735928559(%ebx,%ecx,8)
        	movupd	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movupd	%xmm5, 69
        	movupd	%xmm5,0x45

// CHECK: 	movupd	%xmm5, 32493
        	movupd	%xmm5,0x7eed

// CHECK: 	movupd	%xmm5, 3133065982
        	movupd	%xmm5,0xbabecafe

// CHECK: 	movupd	%xmm5, 305419896
        	movupd	%xmm5,0x12345678

// CHECK: 	movupd	%xmm5, %xmm5
        	movupd	%xmm5,%xmm5

// CHECK: 	mulpd	3735928559(%ebx,%ecx,8), %xmm5
        	mulpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	mulpd	69, %xmm5
        	mulpd	0x45,%xmm5

// CHECK: 	mulpd	32493, %xmm5
        	mulpd	0x7eed,%xmm5

// CHECK: 	mulpd	3133065982, %xmm5
        	mulpd	0xbabecafe,%xmm5

// CHECK: 	mulpd	305419896, %xmm5
        	mulpd	0x12345678,%xmm5

// CHECK: 	mulpd	%xmm5, %xmm5
        	mulpd	%xmm5,%xmm5

// CHECK: 	mulsd	3735928559(%ebx,%ecx,8), %xmm5
        	mulsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	mulsd	69, %xmm5
        	mulsd	0x45,%xmm5

// CHECK: 	mulsd	32493, %xmm5
        	mulsd	0x7eed,%xmm5

// CHECK: 	mulsd	3133065982, %xmm5
        	mulsd	0xbabecafe,%xmm5

// CHECK: 	mulsd	305419896, %xmm5
        	mulsd	0x12345678,%xmm5

// CHECK: 	mulsd	%xmm5, %xmm5
        	mulsd	%xmm5,%xmm5

// CHECK: 	orpd	3735928559(%ebx,%ecx,8), %xmm5
        	orpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	orpd	69, %xmm5
        	orpd	0x45,%xmm5

// CHECK: 	orpd	32493, %xmm5
        	orpd	0x7eed,%xmm5

// CHECK: 	orpd	3133065982, %xmm5
        	orpd	0xbabecafe,%xmm5

// CHECK: 	orpd	305419896, %xmm5
        	orpd	0x12345678,%xmm5

// CHECK: 	orpd	%xmm5, %xmm5
        	orpd	%xmm5,%xmm5

// CHECK: 	sqrtpd	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtpd	69, %xmm5
        	sqrtpd	0x45,%xmm5

// CHECK: 	sqrtpd	32493, %xmm5
        	sqrtpd	0x7eed,%xmm5

// CHECK: 	sqrtpd	3133065982, %xmm5
        	sqrtpd	0xbabecafe,%xmm5

// CHECK: 	sqrtpd	305419896, %xmm5
        	sqrtpd	0x12345678,%xmm5

// CHECK: 	sqrtpd	%xmm5, %xmm5
        	sqrtpd	%xmm5,%xmm5

// CHECK: 	sqrtsd	3735928559(%ebx,%ecx,8), %xmm5
        	sqrtsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	sqrtsd	69, %xmm5
        	sqrtsd	0x45,%xmm5

// CHECK: 	sqrtsd	32493, %xmm5
        	sqrtsd	0x7eed,%xmm5

// CHECK: 	sqrtsd	3133065982, %xmm5
        	sqrtsd	0xbabecafe,%xmm5

// CHECK: 	sqrtsd	305419896, %xmm5
        	sqrtsd	0x12345678,%xmm5

// CHECK: 	sqrtsd	%xmm5, %xmm5
        	sqrtsd	%xmm5,%xmm5

// CHECK: 	subpd	3735928559(%ebx,%ecx,8), %xmm5
        	subpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	subpd	69, %xmm5
        	subpd	0x45,%xmm5

// CHECK: 	subpd	32493, %xmm5
        	subpd	0x7eed,%xmm5

// CHECK: 	subpd	3133065982, %xmm5
        	subpd	0xbabecafe,%xmm5

// CHECK: 	subpd	305419896, %xmm5
        	subpd	0x12345678,%xmm5

// CHECK: 	subpd	%xmm5, %xmm5
        	subpd	%xmm5,%xmm5

// CHECK: 	subsd	3735928559(%ebx,%ecx,8), %xmm5
        	subsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	subsd	69, %xmm5
        	subsd	0x45,%xmm5

// CHECK: 	subsd	32493, %xmm5
        	subsd	0x7eed,%xmm5

// CHECK: 	subsd	3133065982, %xmm5
        	subsd	0xbabecafe,%xmm5

// CHECK: 	subsd	305419896, %xmm5
        	subsd	0x12345678,%xmm5

// CHECK: 	subsd	%xmm5, %xmm5
        	subsd	%xmm5,%xmm5

// CHECK: 	ucomisd	3735928559(%ebx,%ecx,8), %xmm5
        	ucomisd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ucomisd	69, %xmm5
        	ucomisd	0x45,%xmm5

// CHECK: 	ucomisd	32493, %xmm5
        	ucomisd	0x7eed,%xmm5

// CHECK: 	ucomisd	3133065982, %xmm5
        	ucomisd	0xbabecafe,%xmm5

// CHECK: 	ucomisd	305419896, %xmm5
        	ucomisd	0x12345678,%xmm5

// CHECK: 	ucomisd	%xmm5, %xmm5
        	ucomisd	%xmm5,%xmm5

// CHECK: 	unpckhpd	3735928559(%ebx,%ecx,8), %xmm5
        	unpckhpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	unpckhpd	69, %xmm5
        	unpckhpd	0x45,%xmm5

// CHECK: 	unpckhpd	32493, %xmm5
        	unpckhpd	0x7eed,%xmm5

// CHECK: 	unpckhpd	3133065982, %xmm5
        	unpckhpd	0xbabecafe,%xmm5

// CHECK: 	unpckhpd	305419896, %xmm5
        	unpckhpd	0x12345678,%xmm5

// CHECK: 	unpckhpd	%xmm5, %xmm5
        	unpckhpd	%xmm5,%xmm5

// CHECK: 	unpcklpd	3735928559(%ebx,%ecx,8), %xmm5
        	unpcklpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	unpcklpd	69, %xmm5
        	unpcklpd	0x45,%xmm5

// CHECK: 	unpcklpd	32493, %xmm5
        	unpcklpd	0x7eed,%xmm5

// CHECK: 	unpcklpd	3133065982, %xmm5
        	unpcklpd	0xbabecafe,%xmm5

// CHECK: 	unpcklpd	305419896, %xmm5
        	unpcklpd	0x12345678,%xmm5

// CHECK: 	unpcklpd	%xmm5, %xmm5
        	unpcklpd	%xmm5,%xmm5

// CHECK: 	xorpd	3735928559(%ebx,%ecx,8), %xmm5
        	xorpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	xorpd	69, %xmm5
        	xorpd	0x45,%xmm5

// CHECK: 	xorpd	32493, %xmm5
        	xorpd	0x7eed,%xmm5

// CHECK: 	xorpd	3133065982, %xmm5
        	xorpd	0xbabecafe,%xmm5

// CHECK: 	xorpd	305419896, %xmm5
        	xorpd	0x12345678,%xmm5

// CHECK: 	xorpd	%xmm5, %xmm5
        	xorpd	%xmm5,%xmm5

// CHECK: 	cvtdq2pd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtdq2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtdq2pd	69, %xmm5
        	cvtdq2pd	0x45,%xmm5

// CHECK: 	cvtdq2pd	32493, %xmm5
        	cvtdq2pd	0x7eed,%xmm5

// CHECK: 	cvtdq2pd	3133065982, %xmm5
        	cvtdq2pd	0xbabecafe,%xmm5

// CHECK: 	cvtdq2pd	305419896, %xmm5
        	cvtdq2pd	0x12345678,%xmm5

// CHECK: 	cvtdq2pd	%xmm5, %xmm5
        	cvtdq2pd	%xmm5,%xmm5

// CHECK: 	cvtpd2dq	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpd2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpd2dq	69, %xmm5
        	cvtpd2dq	0x45,%xmm5

// CHECK: 	cvtpd2dq	32493, %xmm5
        	cvtpd2dq	0x7eed,%xmm5

// CHECK: 	cvtpd2dq	3133065982, %xmm5
        	cvtpd2dq	0xbabecafe,%xmm5

// CHECK: 	cvtpd2dq	305419896, %xmm5
        	cvtpd2dq	0x12345678,%xmm5

// CHECK: 	cvtpd2dq	%xmm5, %xmm5
        	cvtpd2dq	%xmm5,%xmm5

// CHECK: 	cvtdq2ps	3735928559(%ebx,%ecx,8), %xmm5
        	cvtdq2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtdq2ps	69, %xmm5
        	cvtdq2ps	0x45,%xmm5

// CHECK: 	cvtdq2ps	32493, %xmm5
        	cvtdq2ps	0x7eed,%xmm5

// CHECK: 	cvtdq2ps	3133065982, %xmm5
        	cvtdq2ps	0xbabecafe,%xmm5

// CHECK: 	cvtdq2ps	305419896, %xmm5
        	cvtdq2ps	0x12345678,%xmm5

// CHECK: 	cvtdq2ps	%xmm5, %xmm5
        	cvtdq2ps	%xmm5,%xmm5

// CHECK: 	cvtpd2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvtpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvtpd2pi	69, %mm3
        	cvtpd2pi	0x45,%mm3

// CHECK: 	cvtpd2pi	32493, %mm3
        	cvtpd2pi	0x7eed,%mm3

// CHECK: 	cvtpd2pi	3133065982, %mm3
        	cvtpd2pi	0xbabecafe,%mm3

// CHECK: 	cvtpd2pi	305419896, %mm3
        	cvtpd2pi	0x12345678,%mm3

// CHECK: 	cvtpd2pi	%xmm5, %mm3
        	cvtpd2pi	%xmm5,%mm3

// CHECK: 	cvtpd2ps	3735928559(%ebx,%ecx,8), %xmm5
        	cvtpd2ps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtpd2ps	69, %xmm5
        	cvtpd2ps	0x45,%xmm5

// CHECK: 	cvtpd2ps	32493, %xmm5
        	cvtpd2ps	0x7eed,%xmm5

// CHECK: 	cvtpd2ps	3133065982, %xmm5
        	cvtpd2ps	0xbabecafe,%xmm5

// CHECK: 	cvtpd2ps	305419896, %xmm5
        	cvtpd2ps	0x12345678,%xmm5

// CHECK: 	cvtpd2ps	%xmm5, %xmm5
        	cvtpd2ps	%xmm5,%xmm5

// CHECK: 	cvtps2pd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtps2pd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtps2pd	69, %xmm5
        	cvtps2pd	0x45,%xmm5

// CHECK: 	cvtps2pd	32493, %xmm5
        	cvtps2pd	0x7eed,%xmm5

// CHECK: 	cvtps2pd	3133065982, %xmm5
        	cvtps2pd	0xbabecafe,%xmm5

// CHECK: 	cvtps2pd	305419896, %xmm5
        	cvtps2pd	0x12345678,%xmm5

// CHECK: 	cvtps2pd	%xmm5, %xmm5
        	cvtps2pd	%xmm5,%xmm5

// CHECK: 	cvtps2dq	3735928559(%ebx,%ecx,8), %xmm5
        	cvtps2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtps2dq	69, %xmm5
        	cvtps2dq	0x45,%xmm5

// CHECK: 	cvtps2dq	32493, %xmm5
        	cvtps2dq	0x7eed,%xmm5

// CHECK: 	cvtps2dq	3133065982, %xmm5
        	cvtps2dq	0xbabecafe,%xmm5

// CHECK: 	cvtps2dq	305419896, %xmm5
        	cvtps2dq	0x12345678,%xmm5

// CHECK: 	cvtps2dq	%xmm5, %xmm5
        	cvtps2dq	%xmm5,%xmm5

// CHECK: 	cvtsd2ss	3735928559(%ebx,%ecx,8), %xmm5
        	cvtsd2ss	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtsd2ss	69, %xmm5
        	cvtsd2ss	0x45,%xmm5

// CHECK: 	cvtsd2ss	32493, %xmm5
        	cvtsd2ss	0x7eed,%xmm5

// CHECK: 	cvtsd2ss	3133065982, %xmm5
        	cvtsd2ss	0xbabecafe,%xmm5

// CHECK: 	cvtsd2ss	305419896, %xmm5
        	cvtsd2ss	0x12345678,%xmm5

// CHECK: 	cvtsd2ss	%xmm5, %xmm5
        	cvtsd2ss	%xmm5,%xmm5

// CHECK: 	cvtss2sd	3735928559(%ebx,%ecx,8), %xmm5
        	cvtss2sd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvtss2sd	69, %xmm5
        	cvtss2sd	0x45,%xmm5

// CHECK: 	cvtss2sd	32493, %xmm5
        	cvtss2sd	0x7eed,%xmm5

// CHECK: 	cvtss2sd	3133065982, %xmm5
        	cvtss2sd	0xbabecafe,%xmm5

// CHECK: 	cvtss2sd	305419896, %xmm5
        	cvtss2sd	0x12345678,%xmm5

// CHECK: 	cvtss2sd	%xmm5, %xmm5
        	cvtss2sd	%xmm5,%xmm5

// CHECK: 	cvttpd2pi	3735928559(%ebx,%ecx,8), %mm3
        	cvttpd2pi	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	cvttpd2pi	69, %mm3
        	cvttpd2pi	0x45,%mm3

// CHECK: 	cvttpd2pi	32493, %mm3
        	cvttpd2pi	0x7eed,%mm3

// CHECK: 	cvttpd2pi	3133065982, %mm3
        	cvttpd2pi	0xbabecafe,%mm3

// CHECK: 	cvttpd2pi	305419896, %mm3
        	cvttpd2pi	0x12345678,%mm3

// CHECK: 	cvttpd2pi	%xmm5, %mm3
        	cvttpd2pi	%xmm5,%mm3

// CHECK: 	cvttsd2si	3735928559(%ebx,%ecx,8), %ecx
        	cvttsd2si	0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	cvttsd2si	69, %ecx
        	cvttsd2si	0x45,%ecx

// CHECK: 	cvttsd2si	32493, %ecx
        	cvttsd2si	0x7eed,%ecx

// CHECK: 	cvttsd2si	3133065982, %ecx
        	cvttsd2si	0xbabecafe,%ecx

// CHECK: 	cvttsd2si	305419896, %ecx
        	cvttsd2si	0x12345678,%ecx

// CHECK: 	cvttsd2si	%xmm5, %ecx
        	cvttsd2si	%xmm5,%ecx

// CHECK: 	cvttps2dq	3735928559(%ebx,%ecx,8), %xmm5
        	cvttps2dq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	cvttps2dq	69, %xmm5
        	cvttps2dq	0x45,%xmm5

// CHECK: 	cvttps2dq	32493, %xmm5
        	cvttps2dq	0x7eed,%xmm5

// CHECK: 	cvttps2dq	3133065982, %xmm5
        	cvttps2dq	0xbabecafe,%xmm5

// CHECK: 	cvttps2dq	305419896, %xmm5
        	cvttps2dq	0x12345678,%xmm5

// CHECK: 	cvttps2dq	%xmm5, %xmm5
        	cvttps2dq	%xmm5,%xmm5

// CHECK: 	maskmovdqu	%xmm5, %xmm5
        	maskmovdqu	%xmm5,%xmm5

// CHECK: 	movdqa	3735928559(%ebx,%ecx,8), %xmm5
        	movdqa	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movdqa	69, %xmm5
        	movdqa	0x45,%xmm5

// CHECK: 	movdqa	32493, %xmm5
        	movdqa	0x7eed,%xmm5

// CHECK: 	movdqa	3133065982, %xmm5
        	movdqa	0xbabecafe,%xmm5

// CHECK: 	movdqa	305419896, %xmm5
        	movdqa	0x12345678,%xmm5

// CHECK: 	movdqa	%xmm5, %xmm5
        	movdqa	%xmm5,%xmm5

// CHECK: 	movdqa	%xmm5, 3735928559(%ebx,%ecx,8)
        	movdqa	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movdqa	%xmm5, 69
        	movdqa	%xmm5,0x45

// CHECK: 	movdqa	%xmm5, 32493
        	movdqa	%xmm5,0x7eed

// CHECK: 	movdqa	%xmm5, 3133065982
        	movdqa	%xmm5,0xbabecafe

// CHECK: 	movdqa	%xmm5, 305419896
        	movdqa	%xmm5,0x12345678

// CHECK: 	movdqa	%xmm5, %xmm5
        	movdqa	%xmm5,%xmm5

// CHECK: 	movdqu	3735928559(%ebx,%ecx,8), %xmm5
        	movdqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movdqu	69, %xmm5
        	movdqu	0x45,%xmm5

// CHECK: 	movdqu	32493, %xmm5
        	movdqu	0x7eed,%xmm5

// CHECK: 	movdqu	3133065982, %xmm5
        	movdqu	0xbabecafe,%xmm5

// CHECK: 	movdqu	305419896, %xmm5
        	movdqu	0x12345678,%xmm5

// CHECK: 	movdqu	%xmm5, 3735928559(%ebx,%ecx,8)
        	movdqu	%xmm5,0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	movdqu	%xmm5, 69
        	movdqu	%xmm5,0x45

// CHECK: 	movdqu	%xmm5, 32493
        	movdqu	%xmm5,0x7eed

// CHECK: 	movdqu	%xmm5, 3133065982
        	movdqu	%xmm5,0xbabecafe

// CHECK: 	movdqu	%xmm5, 305419896
        	movdqu	%xmm5,0x12345678

// CHECK: 	movdq2q	%xmm5, %mm3
        	movdq2q	%xmm5,%mm3

// CHECK: 	movq2dq	%mm3, %xmm5
        	movq2dq	%mm3,%xmm5

// CHECK: 	pmuludq	3735928559(%ebx,%ecx,8), %mm3
        	pmuludq	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmuludq	69, %mm3
        	pmuludq	0x45,%mm3

// CHECK: 	pmuludq	32493, %mm3
        	pmuludq	0x7eed,%mm3

// CHECK: 	pmuludq	3133065982, %mm3
        	pmuludq	0xbabecafe,%mm3

// CHECK: 	pmuludq	305419896, %mm3
        	pmuludq	0x12345678,%mm3

// CHECK: 	pmuludq	%mm3, %mm3
        	pmuludq	%mm3,%mm3

// CHECK: 	pmuludq	3735928559(%ebx,%ecx,8), %xmm5
        	pmuludq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmuludq	69, %xmm5
        	pmuludq	0x45,%xmm5

// CHECK: 	pmuludq	32493, %xmm5
        	pmuludq	0x7eed,%xmm5

// CHECK: 	pmuludq	3133065982, %xmm5
        	pmuludq	0xbabecafe,%xmm5

// CHECK: 	pmuludq	305419896, %xmm5
        	pmuludq	0x12345678,%xmm5

// CHECK: 	pmuludq	%xmm5, %xmm5
        	pmuludq	%xmm5,%xmm5

// CHECK: 	pslldq	$127, %xmm5
        	pslldq	$0x7f,%xmm5

// CHECK: 	psrldq	$127, %xmm5
        	psrldq	$0x7f,%xmm5

// CHECK: 	punpckhqdq	3735928559(%ebx,%ecx,8), %xmm5
        	punpckhqdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpckhqdq	69, %xmm5
        	punpckhqdq	0x45,%xmm5

// CHECK: 	punpckhqdq	32493, %xmm5
        	punpckhqdq	0x7eed,%xmm5

// CHECK: 	punpckhqdq	3133065982, %xmm5
        	punpckhqdq	0xbabecafe,%xmm5

// CHECK: 	punpckhqdq	305419896, %xmm5
        	punpckhqdq	0x12345678,%xmm5

// CHECK: 	punpckhqdq	%xmm5, %xmm5
        	punpckhqdq	%xmm5,%xmm5

// CHECK: 	punpcklqdq	3735928559(%ebx,%ecx,8), %xmm5
        	punpcklqdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	punpcklqdq	69, %xmm5
        	punpcklqdq	0x45,%xmm5

// CHECK: 	punpcklqdq	32493, %xmm5
        	punpcklqdq	0x7eed,%xmm5

// CHECK: 	punpcklqdq	3133065982, %xmm5
        	punpcklqdq	0xbabecafe,%xmm5

// CHECK: 	punpcklqdq	305419896, %xmm5
        	punpcklqdq	0x12345678,%xmm5

// CHECK: 	punpcklqdq	%xmm5, %xmm5
        	punpcklqdq	%xmm5,%xmm5

// CHECK: 	addsubpd	3735928559(%ebx,%ecx,8), %xmm5
        	addsubpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addsubpd	69, %xmm5
        	addsubpd	0x45,%xmm5

// CHECK: 	addsubpd	32493, %xmm5
        	addsubpd	0x7eed,%xmm5

// CHECK: 	addsubpd	3133065982, %xmm5
        	addsubpd	0xbabecafe,%xmm5

// CHECK: 	addsubpd	305419896, %xmm5
        	addsubpd	0x12345678,%xmm5

// CHECK: 	addsubpd	%xmm5, %xmm5
        	addsubpd	%xmm5,%xmm5

// CHECK: 	addsubps	3735928559(%ebx,%ecx,8), %xmm5
        	addsubps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	addsubps	69, %xmm5
        	addsubps	0x45,%xmm5

// CHECK: 	addsubps	32493, %xmm5
        	addsubps	0x7eed,%xmm5

// CHECK: 	addsubps	3133065982, %xmm5
        	addsubps	0xbabecafe,%xmm5

// CHECK: 	addsubps	305419896, %xmm5
        	addsubps	0x12345678,%xmm5

// CHECK: 	addsubps	%xmm5, %xmm5
        	addsubps	%xmm5,%xmm5

// CHECK: 	fisttpl	3735928559(%ebx,%ecx,8)
        	fisttpl	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	fisttpl	3133065982
        	fisttpl	0xbabecafe

// CHECK: 	fisttpl	305419896
        	fisttpl	0x12345678

// CHECK: 	haddpd	3735928559(%ebx,%ecx,8), %xmm5
        	haddpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	haddpd	69, %xmm5
        	haddpd	0x45,%xmm5

// CHECK: 	haddpd	32493, %xmm5
        	haddpd	0x7eed,%xmm5

// CHECK: 	haddpd	3133065982, %xmm5
        	haddpd	0xbabecafe,%xmm5

// CHECK: 	haddpd	305419896, %xmm5
        	haddpd	0x12345678,%xmm5

// CHECK: 	haddpd	%xmm5, %xmm5
        	haddpd	%xmm5,%xmm5

// CHECK: 	haddps	3735928559(%ebx,%ecx,8), %xmm5
        	haddps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	haddps	69, %xmm5
        	haddps	0x45,%xmm5

// CHECK: 	haddps	32493, %xmm5
        	haddps	0x7eed,%xmm5

// CHECK: 	haddps	3133065982, %xmm5
        	haddps	0xbabecafe,%xmm5

// CHECK: 	haddps	305419896, %xmm5
        	haddps	0x12345678,%xmm5

// CHECK: 	haddps	%xmm5, %xmm5
        	haddps	%xmm5,%xmm5

// CHECK: 	hsubpd	3735928559(%ebx,%ecx,8), %xmm5
        	hsubpd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	hsubpd	69, %xmm5
        	hsubpd	0x45,%xmm5

// CHECK: 	hsubpd	32493, %xmm5
        	hsubpd	0x7eed,%xmm5

// CHECK: 	hsubpd	3133065982, %xmm5
        	hsubpd	0xbabecafe,%xmm5

// CHECK: 	hsubpd	305419896, %xmm5
        	hsubpd	0x12345678,%xmm5

// CHECK: 	hsubpd	%xmm5, %xmm5
        	hsubpd	%xmm5,%xmm5

// CHECK: 	hsubps	3735928559(%ebx,%ecx,8), %xmm5
        	hsubps	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	hsubps	69, %xmm5
        	hsubps	0x45,%xmm5

// CHECK: 	hsubps	32493, %xmm5
        	hsubps	0x7eed,%xmm5

// CHECK: 	hsubps	3133065982, %xmm5
        	hsubps	0xbabecafe,%xmm5

// CHECK: 	hsubps	305419896, %xmm5
        	hsubps	0x12345678,%xmm5

// CHECK: 	hsubps	%xmm5, %xmm5
        	hsubps	%xmm5,%xmm5

// CHECK: 	lddqu	3735928559(%ebx,%ecx,8), %xmm5
        	lddqu	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	lddqu	69, %xmm5
        	lddqu	0x45,%xmm5

// CHECK: 	lddqu	32493, %xmm5
        	lddqu	0x7eed,%xmm5

// CHECK: 	lddqu	3133065982, %xmm5
        	lddqu	0xbabecafe,%xmm5

// CHECK: 	lddqu	305419896, %xmm5
        	lddqu	0x12345678,%xmm5

// CHECK: 	monitor
        	monitor

// CHECK: 	movddup	3735928559(%ebx,%ecx,8), %xmm5
        	movddup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movddup	69, %xmm5
        	movddup	0x45,%xmm5

// CHECK: 	movddup	32493, %xmm5
        	movddup	0x7eed,%xmm5

// CHECK: 	movddup	3133065982, %xmm5
        	movddup	0xbabecafe,%xmm5

// CHECK: 	movddup	305419896, %xmm5
        	movddup	0x12345678,%xmm5

// CHECK: 	movddup	%xmm5, %xmm5
        	movddup	%xmm5,%xmm5

// CHECK: 	movshdup	3735928559(%ebx,%ecx,8), %xmm5
        	movshdup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movshdup	69, %xmm5
        	movshdup	0x45,%xmm5

// CHECK: 	movshdup	32493, %xmm5
        	movshdup	0x7eed,%xmm5

// CHECK: 	movshdup	3133065982, %xmm5
        	movshdup	0xbabecafe,%xmm5

// CHECK: 	movshdup	305419896, %xmm5
        	movshdup	0x12345678,%xmm5

// CHECK: 	movshdup	%xmm5, %xmm5
        	movshdup	%xmm5,%xmm5

// CHECK: 	movsldup	3735928559(%ebx,%ecx,8), %xmm5
        	movsldup	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movsldup	69, %xmm5
        	movsldup	0x45,%xmm5

// CHECK: 	movsldup	32493, %xmm5
        	movsldup	0x7eed,%xmm5

// CHECK: 	movsldup	3133065982, %xmm5
        	movsldup	0xbabecafe,%xmm5

// CHECK: 	movsldup	305419896, %xmm5
        	movsldup	0x12345678,%xmm5

// CHECK: 	movsldup	%xmm5, %xmm5
        	movsldup	%xmm5,%xmm5

// CHECK: 	mwait
        	mwait

// CHECK: 	vmcall
        	vmcall

// CHECK: 	vmfunc
        	vmfunc

// CHECK: 	vmclear	3735928559(%ebx,%ecx,8)
        	vmclear	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	vmclear	32493
        	vmclear	0x7eed

// CHECK: 	vmclear	3133065982
        	vmclear	0xbabecafe

// CHECK: 	vmclear	305419896
        	vmclear	0x12345678

// CHECK: 	vmlaunch
        	vmlaunch

// CHECK: 	vmresume
        	vmresume

// CHECK: 	vmptrld	3735928559(%ebx,%ecx,8)
        	vmptrld	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	vmptrld	32493
        	vmptrld	0x7eed

// CHECK: 	vmptrld	3133065982
        	vmptrld	0xbabecafe

// CHECK: 	vmptrld	305419896
        	vmptrld	0x12345678

// CHECK: 	vmptrst	3735928559(%ebx,%ecx,8)
        	vmptrst	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	vmptrst	32493
        	vmptrst	0x7eed

// CHECK: 	vmptrst	3133065982
        	vmptrst	0xbabecafe

// CHECK: 	vmptrst	305419896
        	vmptrst	0x12345678

// CHECK: 	vmxoff
        	vmxoff

// CHECK: 	vmxon	3735928559(%ebx,%ecx,8)
        	vmxon	0xdeadbeef(%ebx,%ecx,8)

// CHECK: 	vmxon	32493
        	vmxon	0x7eed

// CHECK: 	vmxon	3133065982
        	vmxon	0xbabecafe

// CHECK: 	vmxon	305419896
        	vmxon	0x12345678

// CHECK: 	vmrun %eax
        	vmrun %eax

// CHECK: 	vmmcall
        	vmmcall

// CHECK: 	vmload %eax
        	vmload %eax

// CHECK: 	vmsave %eax
        	vmsave %eax

// CHECK: 	stgi
        	stgi

// CHECK: 	clgi
        	clgi

// CHECK: 	skinit %eax
        	skinit %eax

// CHECK: 	invlpga %ecx, %eax
        	invlpga %ecx, %eax

// CHECK: 	phaddw	3735928559(%ebx,%ecx,8), %mm3
        	phaddw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phaddw	69, %mm3
        	phaddw	0x45,%mm3

// CHECK: 	phaddw	32493, %mm3
        	phaddw	0x7eed,%mm3

// CHECK: 	phaddw	3133065982, %mm3
        	phaddw	0xbabecafe,%mm3

// CHECK: 	phaddw	305419896, %mm3
        	phaddw	0x12345678,%mm3

// CHECK: 	phaddw	%mm3, %mm3
        	phaddw	%mm3,%mm3

// CHECK: 	phaddw	3735928559(%ebx,%ecx,8), %xmm5
        	phaddw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phaddw	69, %xmm5
        	phaddw	0x45,%xmm5

// CHECK: 	phaddw	32493, %xmm5
        	phaddw	0x7eed,%xmm5

// CHECK: 	phaddw	3133065982, %xmm5
        	phaddw	0xbabecafe,%xmm5

// CHECK: 	phaddw	305419896, %xmm5
        	phaddw	0x12345678,%xmm5

// CHECK: 	phaddw	%xmm5, %xmm5
        	phaddw	%xmm5,%xmm5

// CHECK: 	phaddd	3735928559(%ebx,%ecx,8), %mm3
        	phaddd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phaddd	69, %mm3
        	phaddd	0x45,%mm3

// CHECK: 	phaddd	32493, %mm3
        	phaddd	0x7eed,%mm3

// CHECK: 	phaddd	3133065982, %mm3
        	phaddd	0xbabecafe,%mm3

// CHECK: 	phaddd	305419896, %mm3
        	phaddd	0x12345678,%mm3

// CHECK: 	phaddd	%mm3, %mm3
        	phaddd	%mm3,%mm3

// CHECK: 	phaddd	3735928559(%ebx,%ecx,8), %xmm5
        	phaddd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phaddd	69, %xmm5
        	phaddd	0x45,%xmm5

// CHECK: 	phaddd	32493, %xmm5
        	phaddd	0x7eed,%xmm5

// CHECK: 	phaddd	3133065982, %xmm5
        	phaddd	0xbabecafe,%xmm5

// CHECK: 	phaddd	305419896, %xmm5
        	phaddd	0x12345678,%xmm5

// CHECK: 	phaddd	%xmm5, %xmm5
        	phaddd	%xmm5,%xmm5

// CHECK: 	phaddsw	3735928559(%ebx,%ecx,8), %mm3
        	phaddsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phaddsw	69, %mm3
        	phaddsw	0x45,%mm3

// CHECK: 	phaddsw	32493, %mm3
        	phaddsw	0x7eed,%mm3

// CHECK: 	phaddsw	3133065982, %mm3
        	phaddsw	0xbabecafe,%mm3

// CHECK: 	phaddsw	305419896, %mm3
        	phaddsw	0x12345678,%mm3

// CHECK: 	phaddsw	%mm3, %mm3
        	phaddsw	%mm3,%mm3

// CHECK: 	phaddsw	3735928559(%ebx,%ecx,8), %xmm5
        	phaddsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phaddsw	69, %xmm5
        	phaddsw	0x45,%xmm5

// CHECK: 	phaddsw	32493, %xmm5
        	phaddsw	0x7eed,%xmm5

// CHECK: 	phaddsw	3133065982, %xmm5
        	phaddsw	0xbabecafe,%xmm5

// CHECK: 	phaddsw	305419896, %xmm5
        	phaddsw	0x12345678,%xmm5

// CHECK: 	phaddsw	%xmm5, %xmm5
        	phaddsw	%xmm5,%xmm5

// CHECK: 	phsubw	3735928559(%ebx,%ecx,8), %mm3
        	phsubw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phsubw	69, %mm3
        	phsubw	0x45,%mm3

// CHECK: 	phsubw	32493, %mm3
        	phsubw	0x7eed,%mm3

// CHECK: 	phsubw	3133065982, %mm3
        	phsubw	0xbabecafe,%mm3

// CHECK: 	phsubw	305419896, %mm3
        	phsubw	0x12345678,%mm3

// CHECK: 	phsubw	%mm3, %mm3
        	phsubw	%mm3,%mm3

// CHECK: 	phsubw	3735928559(%ebx,%ecx,8), %xmm5
        	phsubw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phsubw	69, %xmm5
        	phsubw	0x45,%xmm5

// CHECK: 	phsubw	32493, %xmm5
        	phsubw	0x7eed,%xmm5

// CHECK: 	phsubw	3133065982, %xmm5
        	phsubw	0xbabecafe,%xmm5

// CHECK: 	phsubw	305419896, %xmm5
        	phsubw	0x12345678,%xmm5

// CHECK: 	phsubw	%xmm5, %xmm5
        	phsubw	%xmm5,%xmm5

// CHECK: 	phsubd	3735928559(%ebx,%ecx,8), %mm3
        	phsubd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phsubd	69, %mm3
        	phsubd	0x45,%mm3

// CHECK: 	phsubd	32493, %mm3
        	phsubd	0x7eed,%mm3

// CHECK: 	phsubd	3133065982, %mm3
        	phsubd	0xbabecafe,%mm3

// CHECK: 	phsubd	305419896, %mm3
        	phsubd	0x12345678,%mm3

// CHECK: 	phsubd	%mm3, %mm3
        	phsubd	%mm3,%mm3

// CHECK: 	phsubd	3735928559(%ebx,%ecx,8), %xmm5
        	phsubd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phsubd	69, %xmm5
        	phsubd	0x45,%xmm5

// CHECK: 	phsubd	32493, %xmm5
        	phsubd	0x7eed,%xmm5

// CHECK: 	phsubd	3133065982, %xmm5
        	phsubd	0xbabecafe,%xmm5

// CHECK: 	phsubd	305419896, %xmm5
        	phsubd	0x12345678,%xmm5

// CHECK: 	phsubd	%xmm5, %xmm5
        	phsubd	%xmm5,%xmm5

// CHECK: 	phsubsw	3735928559(%ebx,%ecx,8), %mm3
        	phsubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	phsubsw	69, %mm3
        	phsubsw	0x45,%mm3

// CHECK: 	phsubsw	32493, %mm3
        	phsubsw	0x7eed,%mm3

// CHECK: 	phsubsw	3133065982, %mm3
        	phsubsw	0xbabecafe,%mm3

// CHECK: 	phsubsw	305419896, %mm3
        	phsubsw	0x12345678,%mm3

// CHECK: 	phsubsw	%mm3, %mm3
        	phsubsw	%mm3,%mm3

// CHECK: 	phsubsw	3735928559(%ebx,%ecx,8), %xmm5
        	phsubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phsubsw	69, %xmm5
        	phsubsw	0x45,%xmm5

// CHECK: 	phsubsw	32493, %xmm5
        	phsubsw	0x7eed,%xmm5

// CHECK: 	phsubsw	3133065982, %xmm5
        	phsubsw	0xbabecafe,%xmm5

// CHECK: 	phsubsw	305419896, %xmm5
        	phsubsw	0x12345678,%xmm5

// CHECK: 	phsubsw	%xmm5, %xmm5
        	phsubsw	%xmm5,%xmm5

// CHECK: 	pmaddubsw	3735928559(%ebx,%ecx,8), %mm3
        	pmaddubsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmaddubsw	69, %mm3
        	pmaddubsw	0x45,%mm3

// CHECK: 	pmaddubsw	32493, %mm3
        	pmaddubsw	0x7eed,%mm3

// CHECK: 	pmaddubsw	3133065982, %mm3
        	pmaddubsw	0xbabecafe,%mm3

// CHECK: 	pmaddubsw	305419896, %mm3
        	pmaddubsw	0x12345678,%mm3

// CHECK: 	pmaddubsw	%mm3, %mm3
        	pmaddubsw	%mm3,%mm3

// CHECK: 	pmaddubsw	3735928559(%ebx,%ecx,8), %xmm5
        	pmaddubsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaddubsw	69, %xmm5
        	pmaddubsw	0x45,%xmm5

// CHECK: 	pmaddubsw	32493, %xmm5
        	pmaddubsw	0x7eed,%xmm5

// CHECK: 	pmaddubsw	3133065982, %xmm5
        	pmaddubsw	0xbabecafe,%xmm5

// CHECK: 	pmaddubsw	305419896, %xmm5
        	pmaddubsw	0x12345678,%xmm5

// CHECK: 	pmaddubsw	%xmm5, %xmm5
        	pmaddubsw	%xmm5,%xmm5

// CHECK: 	pmulhrsw	3735928559(%ebx,%ecx,8), %mm3
        	pmulhrsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pmulhrsw	69, %mm3
        	pmulhrsw	0x45,%mm3

// CHECK: 	pmulhrsw	32493, %mm3
        	pmulhrsw	0x7eed,%mm3

// CHECK: 	pmulhrsw	3133065982, %mm3
        	pmulhrsw	0xbabecafe,%mm3

// CHECK: 	pmulhrsw	305419896, %mm3
        	pmulhrsw	0x12345678,%mm3

// CHECK: 	pmulhrsw	%mm3, %mm3
        	pmulhrsw	%mm3,%mm3

// CHECK: 	pmulhrsw	3735928559(%ebx,%ecx,8), %xmm5
        	pmulhrsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmulhrsw	69, %xmm5
        	pmulhrsw	0x45,%xmm5

// CHECK: 	pmulhrsw	32493, %xmm5
        	pmulhrsw	0x7eed,%xmm5

// CHECK: 	pmulhrsw	3133065982, %xmm5
        	pmulhrsw	0xbabecafe,%xmm5

// CHECK: 	pmulhrsw	305419896, %xmm5
        	pmulhrsw	0x12345678,%xmm5

// CHECK: 	pmulhrsw	%xmm5, %xmm5
        	pmulhrsw	%xmm5,%xmm5

// CHECK: 	pshufb	3735928559(%ebx,%ecx,8), %mm3
        	pshufb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pshufb	69, %mm3
        	pshufb	0x45,%mm3

// CHECK: 	pshufb	32493, %mm3
        	pshufb	0x7eed,%mm3

// CHECK: 	pshufb	3133065982, %mm3
        	pshufb	0xbabecafe,%mm3

// CHECK: 	pshufb	305419896, %mm3
        	pshufb	0x12345678,%mm3

// CHECK: 	pshufb	%mm3, %mm3
        	pshufb	%mm3,%mm3

// CHECK: 	pshufb	3735928559(%ebx,%ecx,8), %xmm5
        	pshufb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pshufb	69, %xmm5
        	pshufb	0x45,%xmm5

// CHECK: 	pshufb	32493, %xmm5
        	pshufb	0x7eed,%xmm5

// CHECK: 	pshufb	3133065982, %xmm5
        	pshufb	0xbabecafe,%xmm5

// CHECK: 	pshufb	305419896, %xmm5
        	pshufb	0x12345678,%xmm5

// CHECK: 	pshufb	%xmm5, %xmm5
        	pshufb	%xmm5,%xmm5

// CHECK: 	psignb	3735928559(%ebx,%ecx,8), %mm3
        	psignb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psignb	69, %mm3
        	psignb	0x45,%mm3

// CHECK: 	psignb	32493, %mm3
        	psignb	0x7eed,%mm3

// CHECK: 	psignb	3133065982, %mm3
        	psignb	0xbabecafe,%mm3

// CHECK: 	psignb	305419896, %mm3
        	psignb	0x12345678,%mm3

// CHECK: 	psignb	%mm3, %mm3
        	psignb	%mm3,%mm3

// CHECK: 	psignb	3735928559(%ebx,%ecx,8), %xmm5
        	psignb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psignb	69, %xmm5
        	psignb	0x45,%xmm5

// CHECK: 	psignb	32493, %xmm5
        	psignb	0x7eed,%xmm5

// CHECK: 	psignb	3133065982, %xmm5
        	psignb	0xbabecafe,%xmm5

// CHECK: 	psignb	305419896, %xmm5
        	psignb	0x12345678,%xmm5

// CHECK: 	psignb	%xmm5, %xmm5
        	psignb	%xmm5,%xmm5

// CHECK: 	psignw	3735928559(%ebx,%ecx,8), %mm3
        	psignw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psignw	69, %mm3
        	psignw	0x45,%mm3

// CHECK: 	psignw	32493, %mm3
        	psignw	0x7eed,%mm3

// CHECK: 	psignw	3133065982, %mm3
        	psignw	0xbabecafe,%mm3

// CHECK: 	psignw	305419896, %mm3
        	psignw	0x12345678,%mm3

// CHECK: 	psignw	%mm3, %mm3
        	psignw	%mm3,%mm3

// CHECK: 	psignw	3735928559(%ebx,%ecx,8), %xmm5
        	psignw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psignw	69, %xmm5
        	psignw	0x45,%xmm5

// CHECK: 	psignw	32493, %xmm5
        	psignw	0x7eed,%xmm5

// CHECK: 	psignw	3133065982, %xmm5
        	psignw	0xbabecafe,%xmm5

// CHECK: 	psignw	305419896, %xmm5
        	psignw	0x12345678,%xmm5

// CHECK: 	psignw	%xmm5, %xmm5
        	psignw	%xmm5,%xmm5

// CHECK: 	psignd	3735928559(%ebx,%ecx,8), %mm3
        	psignd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	psignd	69, %mm3
        	psignd	0x45,%mm3

// CHECK: 	psignd	32493, %mm3
        	psignd	0x7eed,%mm3

// CHECK: 	psignd	3133065982, %mm3
        	psignd	0xbabecafe,%mm3

// CHECK: 	psignd	305419896, %mm3
        	psignd	0x12345678,%mm3

// CHECK: 	psignd	%mm3, %mm3
        	psignd	%mm3,%mm3

// CHECK: 	psignd	3735928559(%ebx,%ecx,8), %xmm5
        	psignd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	psignd	69, %xmm5
        	psignd	0x45,%xmm5

// CHECK: 	psignd	32493, %xmm5
        	psignd	0x7eed,%xmm5

// CHECK: 	psignd	3133065982, %xmm5
        	psignd	0xbabecafe,%xmm5

// CHECK: 	psignd	305419896, %xmm5
        	psignd	0x12345678,%xmm5

// CHECK: 	psignd	%xmm5, %xmm5
        	psignd	%xmm5,%xmm5

// CHECK: 	pabsb	3735928559(%ebx,%ecx,8), %mm3
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsb	69, %mm3
        	pabsb	0x45,%mm3

// CHECK: 	pabsb	32493, %mm3
        	pabsb	0x7eed,%mm3

// CHECK: 	pabsb	3133065982, %mm3
        	pabsb	0xbabecafe,%mm3

// CHECK: 	pabsb	305419896, %mm3
        	pabsb	0x12345678,%mm3

// CHECK: 	pabsb	%mm3, %mm3
        	pabsb	%mm3,%mm3

// CHECK: 	pabsb	3735928559(%ebx,%ecx,8), %xmm5
        	pabsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsb	69, %xmm5
        	pabsb	0x45,%xmm5

// CHECK: 	pabsb	32493, %xmm5
        	pabsb	0x7eed,%xmm5

// CHECK: 	pabsb	3133065982, %xmm5
        	pabsb	0xbabecafe,%xmm5

// CHECK: 	pabsb	305419896, %xmm5
        	pabsb	0x12345678,%xmm5

// CHECK: 	pabsb	%xmm5, %xmm5
        	pabsb	%xmm5,%xmm5

// CHECK: 	pabsw	3735928559(%ebx,%ecx,8), %mm3
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsw	69, %mm3
        	pabsw	0x45,%mm3

// CHECK: 	pabsw	32493, %mm3
        	pabsw	0x7eed,%mm3

// CHECK: 	pabsw	3133065982, %mm3
        	pabsw	0xbabecafe,%mm3

// CHECK: 	pabsw	305419896, %mm3
        	pabsw	0x12345678,%mm3

// CHECK: 	pabsw	%mm3, %mm3
        	pabsw	%mm3,%mm3

// CHECK: 	pabsw	3735928559(%ebx,%ecx,8), %xmm5
        	pabsw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsw	69, %xmm5
        	pabsw	0x45,%xmm5

// CHECK: 	pabsw	32493, %xmm5
        	pabsw	0x7eed,%xmm5

// CHECK: 	pabsw	3133065982, %xmm5
        	pabsw	0xbabecafe,%xmm5

// CHECK: 	pabsw	305419896, %xmm5
        	pabsw	0x12345678,%xmm5

// CHECK: 	pabsw	%xmm5, %xmm5
        	pabsw	%xmm5,%xmm5

// CHECK: 	pabsd	3735928559(%ebx,%ecx,8), %mm3
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%mm3

// CHECK: 	pabsd	69, %mm3
        	pabsd	0x45,%mm3

// CHECK: 	pabsd	32493, %mm3
        	pabsd	0x7eed,%mm3

// CHECK: 	pabsd	3133065982, %mm3
        	pabsd	0xbabecafe,%mm3

// CHECK: 	pabsd	305419896, %mm3
        	pabsd	0x12345678,%mm3

// CHECK: 	pabsd	%mm3, %mm3
        	pabsd	%mm3,%mm3

// CHECK: 	pabsd	3735928559(%ebx,%ecx,8), %xmm5
        	pabsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pabsd	69, %xmm5
        	pabsd	0x45,%xmm5

// CHECK: 	pabsd	32493, %xmm5
        	pabsd	0x7eed,%xmm5

// CHECK: 	pabsd	3133065982, %xmm5
        	pabsd	0xbabecafe,%xmm5

// CHECK: 	pabsd	305419896, %xmm5
        	pabsd	0x12345678,%xmm5

// CHECK: 	pabsd	%xmm5, %xmm5
        	pabsd	%xmm5,%xmm5

// CHECK: 	femms
        	femms

// CHECK: 	movntdqa	3735928559(%ebx,%ecx,8), %xmm5
        	movntdqa	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	movntdqa	69, %xmm5
        	movntdqa	0x45,%xmm5

// CHECK: 	movntdqa	32493, %xmm5
        	movntdqa	0x7eed,%xmm5

// CHECK: 	movntdqa	3133065982, %xmm5
        	movntdqa	0xbabecafe,%xmm5

// CHECK: 	movntdqa	305419896, %xmm5
        	movntdqa	0x12345678,%xmm5

// CHECK: 	packusdw	3735928559(%ebx,%ecx,8), %xmm5
        	packusdw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	packusdw	69, %xmm5
        	packusdw	0x45,%xmm5

// CHECK: 	packusdw	32493, %xmm5
        	packusdw	0x7eed,%xmm5

// CHECK: 	packusdw	3133065982, %xmm5
        	packusdw	0xbabecafe,%xmm5

// CHECK: 	packusdw	305419896, %xmm5
        	packusdw	0x12345678,%xmm5

// CHECK: 	packusdw	%xmm5, %xmm5
        	packusdw	%xmm5,%xmm5

// CHECK: 	pcmpeqq	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpeqq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpeqq	69, %xmm5
        	pcmpeqq	0x45,%xmm5

// CHECK: 	pcmpeqq	32493, %xmm5
        	pcmpeqq	0x7eed,%xmm5

// CHECK: 	pcmpeqq	3133065982, %xmm5
        	pcmpeqq	0xbabecafe,%xmm5

// CHECK: 	pcmpeqq	305419896, %xmm5
        	pcmpeqq	0x12345678,%xmm5

// CHECK: 	pcmpeqq	%xmm5, %xmm5
        	pcmpeqq	%xmm5,%xmm5

// CHECK: 	phminposuw	3735928559(%ebx,%ecx,8), %xmm5
        	phminposuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	phminposuw	69, %xmm5
        	phminposuw	0x45,%xmm5

// CHECK: 	phminposuw	32493, %xmm5
        	phminposuw	0x7eed,%xmm5

// CHECK: 	phminposuw	3133065982, %xmm5
        	phminposuw	0xbabecafe,%xmm5

// CHECK: 	phminposuw	305419896, %xmm5
        	phminposuw	0x12345678,%xmm5

// CHECK: 	phminposuw	%xmm5, %xmm5
        	phminposuw	%xmm5,%xmm5

// CHECK: 	pmaxsb	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxsb	69, %xmm5
        	pmaxsb	0x45,%xmm5

// CHECK: 	pmaxsb	32493, %xmm5
        	pmaxsb	0x7eed,%xmm5

// CHECK: 	pmaxsb	3133065982, %xmm5
        	pmaxsb	0xbabecafe,%xmm5

// CHECK: 	pmaxsb	305419896, %xmm5
        	pmaxsb	0x12345678,%xmm5

// CHECK: 	pmaxsb	%xmm5, %xmm5
        	pmaxsb	%xmm5,%xmm5

// CHECK: 	pmaxsd	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxsd	69, %xmm5
        	pmaxsd	0x45,%xmm5

// CHECK: 	pmaxsd	32493, %xmm5
        	pmaxsd	0x7eed,%xmm5

// CHECK: 	pmaxsd	3133065982, %xmm5
        	pmaxsd	0xbabecafe,%xmm5

// CHECK: 	pmaxsd	305419896, %xmm5
        	pmaxsd	0x12345678,%xmm5

// CHECK: 	pmaxsd	%xmm5, %xmm5
        	pmaxsd	%xmm5,%xmm5

// CHECK: 	pmaxud	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxud	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxud	69, %xmm5
        	pmaxud	0x45,%xmm5

// CHECK: 	pmaxud	32493, %xmm5
        	pmaxud	0x7eed,%xmm5

// CHECK: 	pmaxud	3133065982, %xmm5
        	pmaxud	0xbabecafe,%xmm5

// CHECK: 	pmaxud	305419896, %xmm5
        	pmaxud	0x12345678,%xmm5

// CHECK: 	pmaxud	%xmm5, %xmm5
        	pmaxud	%xmm5,%xmm5

// CHECK: 	pmaxuw	3735928559(%ebx,%ecx,8), %xmm5
        	pmaxuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmaxuw	69, %xmm5
        	pmaxuw	0x45,%xmm5

// CHECK: 	pmaxuw	32493, %xmm5
        	pmaxuw	0x7eed,%xmm5

// CHECK: 	pmaxuw	3133065982, %xmm5
        	pmaxuw	0xbabecafe,%xmm5

// CHECK: 	pmaxuw	305419896, %xmm5
        	pmaxuw	0x12345678,%xmm5

// CHECK: 	pmaxuw	%xmm5, %xmm5
        	pmaxuw	%xmm5,%xmm5

// CHECK: 	pminsb	3735928559(%ebx,%ecx,8), %xmm5
        	pminsb	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminsb	69, %xmm5
        	pminsb	0x45,%xmm5

// CHECK: 	pminsb	32493, %xmm5
        	pminsb	0x7eed,%xmm5

// CHECK: 	pminsb	3133065982, %xmm5
        	pminsb	0xbabecafe,%xmm5

// CHECK: 	pminsb	305419896, %xmm5
        	pminsb	0x12345678,%xmm5

// CHECK: 	pminsb	%xmm5, %xmm5
        	pminsb	%xmm5,%xmm5

// CHECK: 	pminsd	3735928559(%ebx,%ecx,8), %xmm5
        	pminsd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminsd	69, %xmm5
        	pminsd	0x45,%xmm5

// CHECK: 	pminsd	32493, %xmm5
        	pminsd	0x7eed,%xmm5

// CHECK: 	pminsd	3133065982, %xmm5
        	pminsd	0xbabecafe,%xmm5

// CHECK: 	pminsd	305419896, %xmm5
        	pminsd	0x12345678,%xmm5

// CHECK: 	pminsd	%xmm5, %xmm5
        	pminsd	%xmm5,%xmm5

// CHECK: 	pminud	3735928559(%ebx,%ecx,8), %xmm5
        	pminud	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminud	69, %xmm5
        	pminud	0x45,%xmm5

// CHECK: 	pminud	32493, %xmm5
        	pminud	0x7eed,%xmm5

// CHECK: 	pminud	3133065982, %xmm5
        	pminud	0xbabecafe,%xmm5

// CHECK: 	pminud	305419896, %xmm5
        	pminud	0x12345678,%xmm5

// CHECK: 	pminud	%xmm5, %xmm5
        	pminud	%xmm5,%xmm5

// CHECK: 	pminuw	3735928559(%ebx,%ecx,8), %xmm5
        	pminuw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pminuw	69, %xmm5
        	pminuw	0x45,%xmm5

// CHECK: 	pminuw	32493, %xmm5
        	pminuw	0x7eed,%xmm5

// CHECK: 	pminuw	3133065982, %xmm5
        	pminuw	0xbabecafe,%xmm5

// CHECK: 	pminuw	305419896, %xmm5
        	pminuw	0x12345678,%xmm5

// CHECK: 	pminuw	%xmm5, %xmm5
        	pminuw	%xmm5,%xmm5

// CHECK: 	pmovsxbw	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbw	69, %xmm5
        	pmovsxbw	0x45,%xmm5

// CHECK: 	pmovsxbw	32493, %xmm5
        	pmovsxbw	0x7eed,%xmm5

// CHECK: 	pmovsxbw	3133065982, %xmm5
        	pmovsxbw	0xbabecafe,%xmm5

// CHECK: 	pmovsxbw	305419896, %xmm5
        	pmovsxbw	0x12345678,%xmm5

// CHECK: 	pmovsxbw	%xmm5, %xmm5
        	pmovsxbw	%xmm5,%xmm5

// CHECK: 	pmovsxbd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbd	69, %xmm5
        	pmovsxbd	0x45,%xmm5

// CHECK: 	pmovsxbd	32493, %xmm5
        	pmovsxbd	0x7eed,%xmm5

// CHECK: 	pmovsxbd	3133065982, %xmm5
        	pmovsxbd	0xbabecafe,%xmm5

// CHECK: 	pmovsxbd	305419896, %xmm5
        	pmovsxbd	0x12345678,%xmm5

// CHECK: 	pmovsxbd	%xmm5, %xmm5
        	pmovsxbd	%xmm5,%xmm5

// CHECK: 	pmovsxbq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxbq	69, %xmm5
        	pmovsxbq	0x45,%xmm5

// CHECK: 	pmovsxbq	32493, %xmm5
        	pmovsxbq	0x7eed,%xmm5

// CHECK: 	pmovsxbq	3133065982, %xmm5
        	pmovsxbq	0xbabecafe,%xmm5

// CHECK: 	pmovsxbq	305419896, %xmm5
        	pmovsxbq	0x12345678,%xmm5

// CHECK: 	pmovsxbq	%xmm5, %xmm5
        	pmovsxbq	%xmm5,%xmm5

// CHECK: 	pmovsxwd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxwd	69, %xmm5
        	pmovsxwd	0x45,%xmm5

// CHECK: 	pmovsxwd	32493, %xmm5
        	pmovsxwd	0x7eed,%xmm5

// CHECK: 	pmovsxwd	3133065982, %xmm5
        	pmovsxwd	0xbabecafe,%xmm5

// CHECK: 	pmovsxwd	305419896, %xmm5
        	pmovsxwd	0x12345678,%xmm5

// CHECK: 	pmovsxwd	%xmm5, %xmm5
        	pmovsxwd	%xmm5,%xmm5

// CHECK: 	pmovsxwq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxwq	69, %xmm5
        	pmovsxwq	0x45,%xmm5

// CHECK: 	pmovsxwq	32493, %xmm5
        	pmovsxwq	0x7eed,%xmm5

// CHECK: 	pmovsxwq	3133065982, %xmm5
        	pmovsxwq	0xbabecafe,%xmm5

// CHECK: 	pmovsxwq	305419896, %xmm5
        	pmovsxwq	0x12345678,%xmm5

// CHECK: 	pmovsxwq	%xmm5, %xmm5
        	pmovsxwq	%xmm5,%xmm5

// CHECK: 	pmovsxdq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovsxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovsxdq	69, %xmm5
        	pmovsxdq	0x45,%xmm5

// CHECK: 	pmovsxdq	32493, %xmm5
        	pmovsxdq	0x7eed,%xmm5

// CHECK: 	pmovsxdq	3133065982, %xmm5
        	pmovsxdq	0xbabecafe,%xmm5

// CHECK: 	pmovsxdq	305419896, %xmm5
        	pmovsxdq	0x12345678,%xmm5

// CHECK: 	pmovsxdq	%xmm5, %xmm5
        	pmovsxdq	%xmm5,%xmm5

// CHECK: 	pmovzxbw	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbw	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbw	69, %xmm5
        	pmovzxbw	0x45,%xmm5

// CHECK: 	pmovzxbw	32493, %xmm5
        	pmovzxbw	0x7eed,%xmm5

// CHECK: 	pmovzxbw	3133065982, %xmm5
        	pmovzxbw	0xbabecafe,%xmm5

// CHECK: 	pmovzxbw	305419896, %xmm5
        	pmovzxbw	0x12345678,%xmm5

// CHECK: 	pmovzxbw	%xmm5, %xmm5
        	pmovzxbw	%xmm5,%xmm5

// CHECK: 	pmovzxbd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbd	69, %xmm5
        	pmovzxbd	0x45,%xmm5

// CHECK: 	pmovzxbd	32493, %xmm5
        	pmovzxbd	0x7eed,%xmm5

// CHECK: 	pmovzxbd	3133065982, %xmm5
        	pmovzxbd	0xbabecafe,%xmm5

// CHECK: 	pmovzxbd	305419896, %xmm5
        	pmovzxbd	0x12345678,%xmm5

// CHECK: 	pmovzxbd	%xmm5, %xmm5
        	pmovzxbd	%xmm5,%xmm5

// CHECK: 	pmovzxbq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxbq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxbq	69, %xmm5
        	pmovzxbq	0x45,%xmm5

// CHECK: 	pmovzxbq	32493, %xmm5
        	pmovzxbq	0x7eed,%xmm5

// CHECK: 	pmovzxbq	3133065982, %xmm5
        	pmovzxbq	0xbabecafe,%xmm5

// CHECK: 	pmovzxbq	305419896, %xmm5
        	pmovzxbq	0x12345678,%xmm5

// CHECK: 	pmovzxbq	%xmm5, %xmm5
        	pmovzxbq	%xmm5,%xmm5

// CHECK: 	pmovzxwd	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxwd	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxwd	69, %xmm5
        	pmovzxwd	0x45,%xmm5

// CHECK: 	pmovzxwd	32493, %xmm5
        	pmovzxwd	0x7eed,%xmm5

// CHECK: 	pmovzxwd	3133065982, %xmm5
        	pmovzxwd	0xbabecafe,%xmm5

// CHECK: 	pmovzxwd	305419896, %xmm5
        	pmovzxwd	0x12345678,%xmm5

// CHECK: 	pmovzxwd	%xmm5, %xmm5
        	pmovzxwd	%xmm5,%xmm5

// CHECK: 	pmovzxwq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxwq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxwq	69, %xmm5
        	pmovzxwq	0x45,%xmm5

// CHECK: 	pmovzxwq	32493, %xmm5
        	pmovzxwq	0x7eed,%xmm5

// CHECK: 	pmovzxwq	3133065982, %xmm5
        	pmovzxwq	0xbabecafe,%xmm5

// CHECK: 	pmovzxwq	305419896, %xmm5
        	pmovzxwq	0x12345678,%xmm5

// CHECK: 	pmovzxwq	%xmm5, %xmm5
        	pmovzxwq	%xmm5,%xmm5

// CHECK: 	pmovzxdq	3735928559(%ebx,%ecx,8), %xmm5
        	pmovzxdq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmovzxdq	69, %xmm5
        	pmovzxdq	0x45,%xmm5

// CHECK: 	pmovzxdq	32493, %xmm5
        	pmovzxdq	0x7eed,%xmm5

// CHECK: 	pmovzxdq	3133065982, %xmm5
        	pmovzxdq	0xbabecafe,%xmm5

// CHECK: 	pmovzxdq	305419896, %xmm5
        	pmovzxdq	0x12345678,%xmm5

// CHECK: 	pmovzxdq	%xmm5, %xmm5
        	pmovzxdq	%xmm5,%xmm5

// CHECK: 	pmuldq	3735928559(%ebx,%ecx,8), %xmm5
        	pmuldq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmuldq	69, %xmm5
        	pmuldq	0x45,%xmm5

// CHECK: 	pmuldq	32493, %xmm5
        	pmuldq	0x7eed,%xmm5

// CHECK: 	pmuldq	3133065982, %xmm5
        	pmuldq	0xbabecafe,%xmm5

// CHECK: 	pmuldq	305419896, %xmm5
        	pmuldq	0x12345678,%xmm5

// CHECK: 	pmuldq	%xmm5, %xmm5
        	pmuldq	%xmm5,%xmm5

// CHECK: 	pmulld	3735928559(%ebx,%ecx,8), %xmm5
        	pmulld	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pmulld	69, %xmm5
        	pmulld	0x45,%xmm5

// CHECK: 	pmulld	32493, %xmm5
        	pmulld	0x7eed,%xmm5

// CHECK: 	pmulld	3133065982, %xmm5
        	pmulld	0xbabecafe,%xmm5

// CHECK: 	pmulld	305419896, %xmm5
        	pmulld	0x12345678,%xmm5

// CHECK: 	pmulld	%xmm5, %xmm5
        	pmulld	%xmm5,%xmm5

// CHECK: 	ptest 	3735928559(%ebx,%ecx,8), %xmm5
        	ptest	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	ptest 	69, %xmm5
        	ptest	0x45,%xmm5

// CHECK: 	ptest 	32493, %xmm5
        	ptest	0x7eed,%xmm5

// CHECK: 	ptest 	3133065982, %xmm5
        	ptest	0xbabecafe,%xmm5

// CHECK: 	ptest 	305419896, %xmm5
        	ptest	0x12345678,%xmm5

// CHECK: 	ptest 	%xmm5, %xmm5
        	ptest	%xmm5,%xmm5

// CHECK: 	crc32b 	%bl, %eax
                crc32b %bl, %eax

// CHECK: 	crc32b 	4(%ebx), %eax
                crc32b 4(%ebx), %eax

// CHECK: 	crc32w 	%bx, %eax
                crc32w %bx, %eax

// CHECK: 	crc32w 	4(%ebx), %eax
                crc32w 4(%ebx), %eax

// CHECK: 	crc32l 	%ebx, %eax
                crc32l %ebx, %eax

// CHECK: 	crc32l 	4(%ebx), %eax
                crc32l 4(%ebx), %eax

// CHECK: 	crc32l 	3735928559(%ebx,%ecx,8), %ecx
                crc32l 0xdeadbeef(%ebx,%ecx,8),%ecx

// CHECK: 	crc32l 	69, %ecx
                crc32l 0x45,%ecx

// CHECK: 	crc32l 	32493, %ecx
                crc32l 0x7eed,%ecx

// CHECK: 	crc32l 	3133065982, %ecx
                crc32l 0xbabecafe,%ecx

// CHECK: 	crc32l 	%ecx, %ecx
                crc32l %ecx,%ecx

// CHECK: 	pcmpgtq	3735928559(%ebx,%ecx,8), %xmm5
        	pcmpgtq	0xdeadbeef(%ebx,%ecx,8),%xmm5

// CHECK: 	pcmpgtq	69, %xmm5
        	pcmpgtq	0x45,%xmm5

// CHECK: 	pcmpgtq	32493, %xmm5
        	pcmpgtq	0x7eed,%xmm5

// CHECK: 	pcmpgtq	3133065982, %xmm5
        	pcmpgtq	0xbabecafe,%xmm5

// CHECK: 	pcmpgtq	305419896, %xmm5
        	pcmpgtq	0x12345678,%xmm5

// CHECK: 	pcmpgtq	%xmm5, %xmm5
        	pcmpgtq	%xmm5,%xmm5

// CHECK: 	aesimc	%xmm0, %xmm1
                aesimc %xmm0,%xmm1

// CHECK: 	aesimc	(%eax), %xmm1
                aesimc (%eax),%xmm1

// CHECK: 	aesenc	%xmm1, %xmm2
                aesenc %xmm1,%xmm2

// CHECK: 	aesenc	4(%ebx), %xmm2
                aesenc 4(%ebx),%xmm2

// CHECK: 	aesenclast	%xmm3, %xmm4
                aesenclast %xmm3,%xmm4

// CHECK: 	aesenclast	4(%edx,%edi), %xmm4
                aesenclast 4(%edx,%edi),%xmm4

// CHECK: 	aesdec	%xmm5, %xmm6
                aesdec %xmm5,%xmm6

// CHECK: 	aesdec	4(%ecx,%eax,8), %xmm6
                aesdec 4(%ecx,%eax,8),%xmm6

// CHECK: 	aesdeclast	%xmm7, %xmm0
                aesdeclast %xmm7,%xmm0

// CHECK: 	aesdeclast	3405691582, %xmm0
                aesdeclast 0xcafebabe,%xmm0

// CHECK: 	aeskeygenassist	$125, %xmm1, %xmm2
                aeskeygenassist $125, %xmm1, %xmm2

// CHECK: 	aeskeygenassist	$125, (%edx,%eax,4), %xmm2
                aeskeygenassist $125, (%edx,%eax,4), %xmm2

// CHECK:   blendvps	(%eax), %xmm1   # encoding: [0x66,0x0f,0x38,0x14,0x08]
            blendvps (%eax), %xmm1
// CHECK:   blendvps	%xmm2, %xmm1    # encoding: [0x66,0x0f,0x38,0x14,0xca]
            blendvps %xmm2, %xmm1

// rdar://9795008
// These instructions take a mask not an 8-bit sign extended value.
// CHECK: blendps $129, %xmm2, %xmm1
          blendps $0x81, %xmm2, %xmm1
// CHECK: blendpd $129, %xmm2, %xmm1
          blendpd $0x81, %xmm2, %xmm1
// CHECK: pblendw $129, %xmm2, %xmm1
          pblendw $0x81, %xmm2, %xmm1
// CHECK: mpsadbw $129, %xmm2, %xmm1
          mpsadbw $0x81, %xmm2, %xmm1
// CHECK: dpps $129, %xmm2, %xmm1
          dpps $0x81, %xmm2, %xmm1
// CHECK: dppd $129, %xmm2, %xmm1
          dppd $0x81, %xmm2, %xmm1
// CHECK: insertps $129, %xmm2, %xmm1
          insertps $0x81, %xmm2, %xmm1

// PR13253 handle implicit optional third argument that must always be xmm0
// CHECK: pblendvb %xmm2, %xmm1
pblendvb %xmm2, %xmm1
// CHECK: pblendvb %xmm2, %xmm1
pblendvb %xmm0, %xmm2, %xmm1
// CHECK: pblendvb (%eax), %xmm1
pblendvb (%eax), %xmm1
// CHECK: pblendvb (%eax), %xmm1
pblendvb %xmm0, (%eax), %xmm1
// CHECK: blendvpd %xmm2, %xmm1
blendvpd %xmm2, %xmm1
// CHECK: blendvpd %xmm2, %xmm1
blendvpd %xmm0, %xmm2, %xmm1
// CHECK: blendvpd (%eax), %xmm1
blendvpd (%eax), %xmm1
// CHECK: blendvpd (%eax), %xmm1
blendvpd %xmm0, (%eax), %xmm1
// CHECK: blendvps %xmm2, %xmm1
blendvps %xmm2, %xmm1
// CHECK: blendvps %xmm2, %xmm1
blendvps %xmm0, %xmm2, %xmm1
// CHECK: blendvps (%eax), %xmm1
blendvps (%eax), %xmm1
// CHECK: blendvps (%eax), %xmm1
blendvps %xmm0, (%eax), %xmm1
