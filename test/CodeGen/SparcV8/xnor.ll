; RUN: llvm-as < %s | llc -march=sparcv8 -enable-v8-dag-isel=true &&
; RUN: llvm-as < %s | llc -march=sparcv8 -enable-v8-dag-isel=true | grep xnor | wc -l | grep 2

int %test1(int %X, int %Y) {
	%A = xor int %X, %Y
	%B = xor int %A, -1
	ret int %B
}

int %test2(int %X, int %Y) {
	%A = xor int %X, -1
	%B = xor int %A, %Y
	ret int %B
}
