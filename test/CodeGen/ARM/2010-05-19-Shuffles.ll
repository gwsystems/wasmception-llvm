; RUN: llc < %s -mtriple=armv7-eabi -mcpu=cortex-a8
; pr7167

define <8 x i8> @f1(<8 x i8> %x) nounwind {
  %y = shufflevector <8 x i8> %x, <8 x i8> undef,
       <8 x i32> <i32 2, i32 3, i32 0, i32 1, i32 6, i32 7, i32 4, i32 5>
  ret <8 x i8> %y
}

define <8 x i8> @f2(<8 x i8> %x) nounwind {
  %y = shufflevector <8 x i8> %x, <8 x i8> undef,
       <8 x i32> <i32 1, i32 2, i32 0, i32 5, i32 3, i32 6, i32 7, i32 4>
  ret <8 x i8> %y
}
