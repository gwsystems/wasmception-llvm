; RUN: llc < %s -march=x86 -x86-asm-syntax=intel -mcpu=i486 | FileCheck %s
; Test that the load of the constant is folded into the operation.


define double @foo_add(double %P) {
	%tmp.1 = fadd double %P, 1.230000e+02		; <double> [#uses=1]
	ret double %tmp.1
}
; CHECK: fadd {{[^sS][^tT]}}
; CHECK: fadd {{[^sS][^tT]}}

define double @foo_mul(double %P) {
	%tmp.1 = fmul double %P, 1.230000e+02		; <double> [#uses=1]
	ret double %tmp.1
}
; CHECK: fmul {{[^sS][^tT]}}

define double @foo_sub(double %P) {
	%tmp.1 = fsub double %P, 1.230000e+02		; <double> [#uses=1]
	ret double %tmp.1
}

define double @foo_subr(double %P) {
	%tmp.1 = fsub double 1.230000e+02, %P		; <double> [#uses=1]
	ret double %tmp.1
}

define double @foo_div(double %P) {
	%tmp.1 = fdiv double %P, 1.230000e+02		; <double> [#uses=1]
	ret double %tmp.1
}

define double @foo_divr(double %P) {
	%tmp.1 = fdiv double 1.230000e+02, %P		; <double> [#uses=1]
	ret double %tmp.1
}


; CHECK: fsub {{[^sS][^tT]}}
; CHECK: fdiv {{[^sS][^tT]}}
; CHECK: fdiv {{[^sS][^tT]}}

