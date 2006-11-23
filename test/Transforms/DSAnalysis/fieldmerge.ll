;
; RUN: llvm-as < %s | opt -analyze -tddatastructure

%str = type { int*, int* }

implementation

void %bar(%str* %S, bool %C) {
	br bool %C, label %T, label %F
T:
	%A = getelementptr %str* %S, long 0, uint 0
	br label %Out
F:
	%B = getelementptr %str* %S, long 0, uint 1
	br label %Out
Out:
	%P = phi int** [%A, %T], [%B, %F]
	store int* null, int** %P
	ret void
}
