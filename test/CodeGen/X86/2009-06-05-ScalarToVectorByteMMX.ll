; RUN: llvm-as < %s | llc -march=x86 -mattr=+mmx | not grep movl

define <8 x i8> @a(i8 zeroext %x) nounwind {
  %r = insertelement <8 x i8> undef, i8 %x, i32 0
  ret <8 x i8> %r
}

