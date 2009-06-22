; RUN: llvm-as < %s | llc -march=arm -mattr=+neon > %t
; RUN: grep {vabal\\.s8} %t | count 1
; RUN: grep {vabal\\.s16} %t | count 1
; RUN: grep {vabal\\.s32} %t | count 1
; RUN: grep {vabal\\.u8} %t | count 1
; RUN: grep {vabal\\.u16} %t | count 1
; RUN: grep {vabal\\.u32} %t | count 1

define <8 x i16> @vabals8(<8 x i16>* %A, <8 x i8>* %B, <8 x i8>* %C) nounwind {
	%tmp1 = load <8 x i16>* %A
	%tmp2 = load <8 x i8>* %B
	%tmp3 = load <8 x i8>* %C
	%tmp4 = call <8 x i16> @llvm.arm.neon.vabals.v8i16(<8 x i16> %tmp1, <8 x i8> %tmp2, <8 x i8> %tmp3)
	ret <8 x i16> %tmp4
}

define <4 x i32> @vabals16(<4 x i32>* %A, <4 x i16>* %B, <4 x i16>* %C) nounwind {
	%tmp1 = load <4 x i32>* %A
	%tmp2 = load <4 x i16>* %B
	%tmp3 = load <4 x i16>* %C
	%tmp4 = call <4 x i32> @llvm.arm.neon.vabals.v4i32(<4 x i32> %tmp1, <4 x i16> %tmp2, <4 x i16> %tmp3)
	ret <4 x i32> %tmp4
}

define <2 x i64> @vabals32(<2 x i64>* %A, <2 x i32>* %B, <2 x i32>* %C) nounwind {
	%tmp1 = load <2 x i64>* %A
	%tmp2 = load <2 x i32>* %B
	%tmp3 = load <2 x i32>* %C
	%tmp4 = call <2 x i64> @llvm.arm.neon.vabals.v2i64(<2 x i64> %tmp1, <2 x i32> %tmp2, <2 x i32> %tmp3)
	ret <2 x i64> %tmp4
}

define <8 x i16> @vabalu8(<8 x i16>* %A, <8 x i8>* %B, <8 x i8>* %C) nounwind {
	%tmp1 = load <8 x i16>* %A
	%tmp2 = load <8 x i8>* %B
	%tmp3 = load <8 x i8>* %C
	%tmp4 = call <8 x i16> @llvm.arm.neon.vabalu.v8i16(<8 x i16> %tmp1, <8 x i8> %tmp2, <8 x i8> %tmp3)
	ret <8 x i16> %tmp4
}

define <4 x i32> @vabalu16(<4 x i32>* %A, <4 x i16>* %B, <4 x i16>* %C) nounwind {
	%tmp1 = load <4 x i32>* %A
	%tmp2 = load <4 x i16>* %B
	%tmp3 = load <4 x i16>* %C
	%tmp4 = call <4 x i32> @llvm.arm.neon.vabalu.v4i32(<4 x i32> %tmp1, <4 x i16> %tmp2, <4 x i16> %tmp3)
	ret <4 x i32> %tmp4
}

define <2 x i64> @vabalu32(<2 x i64>* %A, <2 x i32>* %B, <2 x i32>* %C) nounwind {
	%tmp1 = load <2 x i64>* %A
	%tmp2 = load <2 x i32>* %B
	%tmp3 = load <2 x i32>* %C
	%tmp4 = call <2 x i64> @llvm.arm.neon.vabalu.v2i64(<2 x i64> %tmp1, <2 x i32> %tmp2, <2 x i32> %tmp3)
	ret <2 x i64> %tmp4
}

declare <8 x i16> @llvm.arm.neon.vabals.v8i16(<8 x i16>, <8 x i8>, <8 x i8>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vabals.v4i32(<4 x i32>, <4 x i16>, <4 x i16>) nounwind readnone
declare <2 x i64> @llvm.arm.neon.vabals.v2i64(<2 x i64>, <2 x i32>, <2 x i32>) nounwind readnone

declare <8 x i16> @llvm.arm.neon.vabalu.v8i16(<8 x i16>, <8 x i8>, <8 x i8>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vabalu.v4i32(<4 x i32>, <4 x i16>, <4 x i16>) nounwind readnone
declare <2 x i64> @llvm.arm.neon.vabalu.v2i64(<2 x i64>, <2 x i32>, <2 x i32>) nounwind readnone
