	#RUN: llvm-mc -preserve-comments -n -triple i386-linux-gnu < %s > %t
	#RUN: diff %s %t
	.text

	nop
	#if DIRECTIVE COMMENT
	## WHOLE LINE COMMENT
	cmpl	$196, %eax	## EOL COMMENT
	#endif
