; RUN: llc < %s -march=ptx | FileCheck %s

define ptx_device void @t1() {
;CHECK: ret;
	ret void
}
