# Instructions that are valid
#
# FIXME: Test MIPS-III instead of MIPS-IV
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
	dsll   $zero,18             # CHECK: dsll $zero, $zero, 18       # encoding: [0x00,0x00,0x04,0xb8]
	dsll   $zero,$s4,18         # CHECK: dsll $zero, $20, 18         # encoding: [0x00,0x14,0x04,0xb8]
	dsll32 $zero,18             # CHECK: dsll32 $zero, $zero, 18     # encoding: [0x00,0x00,0x04,0xbc]
	dsll32 $zero,$zero,18       # CHECK: dsll32 $zero, $zero, 18     # encoding: [0x00,0x00,0x04,0xbc]
	dsllv  $zero,$t4            # CHECK: dsllv $zero, $zero, $12     # encoding: [0x01,0x80,0x00,0x14]
	dsllv  $zero,$s4,$t4        # CHECK: dsllv $zero, $20, $12       # encoding: [0x01,0x94,0x00,0x14]
	dsra   $gp,10               # CHECK: dsra $gp, $gp, 10           # encoding: [0x00,0x1c,0xe2,0xbb]
	dsra   $gp,$s2,10           # CHECK: dsra $gp, $18, 10           # encoding: [0x00,0x12,0xe2,0xbb]
	dsra32 $gp,10               # CHECK: dsra32 $gp, $gp, 10         # encoding: [0x00,0x1c,0xe2,0xbf]
	dsra32 $gp,$s2,10           # CHECK: dsra32 $gp, $18, 10         # encoding: [0x00,0x12,0xe2,0xbf]
	dsrav  $gp,$s3              # CHECK: dsrav $gp, $gp, $19         # encoding: [0x02,0x7c,0xe0,0x17]
	dsrav  $gp,$s2,$s3          # CHECK: dsrav $gp, $18, $19         # encoding: [0x02,0x72,0xe0,0x17]
	dsrl   $s3,23               # CHECK: dsrl $19, $19, 23           # encoding: [0x00,0x13,0x9d,0xfa]
	dsrl   $s3,$6,23            # CHECK: dsrl $19, $6, 23            # encoding: [0x00,0x06,0x9d,0xfa]
	dsrl32 $s3,23               # CHECK: dsrl32 $19, $19, 23         # encoding: [0x00,0x13,0x9d,0xfe]
	dsrl32 $s3,$6,23            # CHECK: dsrl32 $19, $6, 23          # encoding: [0x00,0x06,0x9d,0xfe]
	dsrlv  $s3,$s4              # CHECK: dsrlv $19, $19, $20         # encoding: [0x02,0x93,0x98,0x16]
	dsrlv  $s3,$6,$s4           # CHECK: dsrlv $19, $6, $20          # encoding: [0x02,0x86,0x98,0x16]
	dsub	$a3,$s6,$t0
	dsubu	$a1,$a1,$k0
	ehb                         # CHECK: ehb # encoding:  [0x00,0x00,0x00,0xc0]
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
	sh	$t6,-6704($t7)
	sll   $a3,18               # CHECK: sll $7, $7, 18         # encoding: [0x00,0x07,0x3c,0x80]
	sll   $a3,$zero,18         # CHECK: sll $7, $zero, 18      # encoding: [0x00,0x00,0x3c,0x80]
	sllv  $a3,$9               # CHECK: sllv $7, $7, $9        # encoding: [0x01,0x27,0x38,0x04]
	sllv  $a3,$zero,$9         # CHECK: sllv $7, $zero, $9     # encoding: [0x01,0x20,0x38,0x04]
	slt	$s7,$t3,$k1
	slti	$s1,$t2,9489
	sltiu	$t9,$t9,-15531
	sltu	$s4,$s5,$t3
	sqrt.d	$f17,$f22
	sqrt.s	$f0,$f1
	sra   $s1,15               # CHECK: sra $17, $17, 15       # encoding: [0x00,0x11,0x8b,0xc3]
	sra   $s1,$s7,15           # CHECK: sra $17, $23, 15       # encoding: [0x00,0x17,0x8b,0xc3]
	srav  $s1,$sp              # CHECK: srav $17, $17, $sp     # encoding: [0x03,0xb1,0x88,0x07]
	srav  $s1,$s7,$sp          # CHECK: srav $17, $23, $sp     # encoding: [0x03,0xb7,0x88,0x07]
	srl   $2,7                 # CHECK: srl $2, $2, 7          # encoding: [0x00,0x02,0x11,0xc2]
	srl   $2,$2,7              # CHECK: srl $2, $2, 7          # encoding: [0x00,0x02,0x11,0xc2]
	srlv  $t9,$a0              # CHECK: srlv $25, $25, $4      # encoding: [0x00,0x99,0xc8,0x06]
	srlv  $t9,$s4,$a0          # CHECK: srlv $25, $20, $4      # encoding: [0x00,0x94,0xc8,0x06]
	ssnop                      # CHECK: ssnop                  # encoding: [0x00,0x00,0x00,0x40]
	sub	$s6,$s3,$t4
	sub.d	$f18,$f3,$f17
	sub.s	$f23,$f22,$f22
	subu	$sp,$s6,$s6
	sw	$ra,-10160($sp)
	swc1	$f6,-8465($t8)
	swc2	$25,24880($s0)
	swl	$t7,13694($s3)
	swr	$s1,-26590($t6)
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
