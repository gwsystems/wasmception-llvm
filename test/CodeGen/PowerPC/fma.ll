; RUN: llvm-as < %s | llc -march=ppc32 | grep 'fn\?madd\|fn\?msub' | wc -l | grep 7

double %test_FMADD1(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = add double %D, %C
	ret double %E
}
double %test_FMADD2(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = add double %D, %C
	ret double %E
}
double %test_FMSUB(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = sub double %D, %C
	ret double %E
}
double %test_FNMADD1(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = add double %D, %C
	%F = sub double -0.0, %E
	ret double %F
}
double %test_FNMADD2(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = add double %C, %D
	%F = sub double -0.0, %E
	ret double %F
}
double %test_FNMSUB1(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = sub double %C, %D
	ret double %E
}
double %test_FNMSUB2(double %A, double %B, double %C) {
	%D = mul double %A, %B
	%E = sub double %D, %C
	%F = sub double -0.0, %E
	ret double %F
}
