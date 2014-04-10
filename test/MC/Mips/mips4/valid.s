# Instructions that are valid
#
# RUN: llvm-mc %s -triple=mips64-unknown-linux -show-encoding -mcpu=mips4 | FileCheck %s

	.set noat
	abs.d	$f7,$f25 # CHECK: encoding
	abs.s	$f9,$f16
	add	$s7,$s2,$a1
	add.d	$f1,$f7,$f29
	add.s	$f8,$f21,$f24
	addi	$t5,$t1,26322
	addu	$t1,$a0,$a2
	and	$s7,$v0,$t4
	c.ngl.d	$f29,$f29
	c.ngle.d	$f0,$f16
	c.sf.d	$f30,$f0
	c.sf.s	$f14,$f22
	ceil.l.d	$f1,$f3
	ceil.l.s	$f18,$f13
	ceil.w.d	$f11,$f25
	ceil.w.s	$f6,$f20
	cfc1	$s1,$21
	ctc1	$a2,$26
	cvt.d.l	$f4,$f16
	cvt.d.s	$f22,$f28
	cvt.d.w	$f26,$f11
	cvt.l.d	$f24,$f15
	cvt.l.s	$f11,$f29
	cvt.s.d	$f26,$f8
	cvt.s.l	$f15,$f30
	cvt.s.w	$f22,$f15
	cvt.w.d	$f20,$f14
	cvt.w.s	$f20,$f24
	dadd	$s3,$at,$ra
	daddi	$sp,$s4,-27705
	daddiu	$k0,$s6,-4586
	ddiv	$zero,$k0,$s3
	ddivu	$zero,$s0,$s1
	div	$zero,$t9,$t3
	div.d	$f29,$f20,$f27
	div.s	$f4,$f5,$f15
	divu	$zero,$t9,$t7
	dmfc1	$t4,$f13
	dmtc1	$s0,$f14
	dmult	$s7,$t1
	dmultu	$a1,$a2
	dsllv	$zero,$s4,$t4
	dsrav	$gp,$s2,$s3
	dsrlv	$s3,$t6,$s4
	dsub	$a3,$s6,$t0
	dsubu	$a1,$a1,$k0
	ehb                      # CHECK: ehb # encoding:  [0x00,0x00,0x00,0xc0]
	eret
	floor.l.d	$f26,$f7
	floor.l.s	$f12,$f5
	floor.w.d	$f14,$f11
	floor.w.s	$f8,$f9
	lb	$t8,-14515($t2)
	lbu	$t0,30195($v1)
	ld	$sp,-28645($s1)
	ldc1	$f11,16391($s0)
	ldc2	$8,-21181($at)
	ldl	$t8,-4167($t8)
	ldr	$t6,-30358($s4)
	ldxc1	$f8,$s7($t7)
	lh	$t3,-8556($s5)
	lhu	$s3,-22851($v0)
	li	$at,-29773
	li	$zero,-29889
	ll	$v0,-7321($s2)
	lld	$zero,-14736($ra)
	lw	$t0,5674($a1)
	lwc1	$f16,10225($k0)
	lwc2	$18,-841($a2)
	lwl	$s4,-4231($t7)
	lwr	$zero,-19147($gp)
	lwu	$s3,-24086($v1)
	lwxc1	$f12,$s1($s8)
	mfc1	$a3,$f27
	mfhi	$s3
	mfhi	$sp
	mflo	$s1
	mov.d	$f20,$f14
	mov.s	$f2,$f27
	move	$a0,$a3
	move	$s5,$a0
	move	$s8,$a0
	move	$t9,$a2
	movf	$gp,$t0,$fcc7
	movf.d	$f6,$f11,$fcc5
	movf.s	$f23,$f5,$fcc6
	movn	$v1,$s1,$s0
	movn.d	$f27,$f21,$k0
	movn.s	$f12,$f0,$s7
	movt	$zero,$s4,$fcc5
	movt.d	$f0,$f2,$fcc0
	movt.s	$f30,$f2,$fcc1
	movz	$a1,$s6,$t1
	movz.d	$f12,$f29,$t1
	movz.s	$f25,$f7,$v1
	mtc1	$s8,$f9
	mthi	$s1
	mtlo	$sp
	mtlo	$t9
	mul.d	$f20,$f20,$f16
	mul.s	$f30,$f10,$f2
	mult	$sp,$s4
	mult	$sp,$v0
	multu	$gp,$k0
	multu	$t1,$s2
	neg.d	$f27,$f18
	neg.s	$f1,$f15
	nop
	nor	$a3,$zero,$a3
	or	$t4,$s0,$sp
	round.l.d	$f12,$f1
	round.l.s	$f25,$f5
	round.w.d	$f6,$f4
	round.w.s	$f27,$f28
	sb	$s6,-19857($t6)
	sc	$t7,18904($s3)
	scd	$t7,-8243($sp)
	sd	$t4,5835($t2)
	sdc1	$f31,30574($t5)
	sdc2	$20,23157($s2)
	sdl	$a3,-20961($s8)
	sdr	$t3,-20423($t4)
	sdxc1	$f11,$t2($t6)
	sh	$t6,-6704($t7)
	sllv	$a3,$zero,$t1
	slt	$s7,$t3,$k1
	slti	$s1,$t2,9489
	sltiu	$t9,$t9,-15531
	sltu	$s4,$s5,$t3
	sqrt.d	$f17,$f22
	sqrt.s	$f0,$f1
	srav	$s1,$s7,$sp
	srlv	$t9,$s4,$a0
	ssnop                    # CHECK: ssnop # encoding:  [0x00,0x00,0x00,0x40]
	sub	$s6,$s3,$t4
	sub.d	$f18,$f3,$f17
	sub.s	$f23,$f22,$f22
	subu	$sp,$s6,$s6
	sw	$ra,-10160($sp)
	swc1	$f6,-8465($t8)
	swc2	$25,24880($s0)
	swl	$t7,13694($s3)
	swr	$s1,-26590($t6)
	swxc1	$f19,$t4($k0)
	teqi	$s5,-17504
	tgei	$s1,5025
	tgeiu	$sp,-28621
	tlti	$t6,-21059
	tltiu	$ra,-5076
	tnei	$t4,-29647
	trunc.l.d	$f23,$f23
	trunc.l.s	$f28,$f31
	trunc.w.d	$f22,$f15
	trunc.w.s	$f28,$f30
	xor	$s2,$a0,$s8
