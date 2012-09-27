; RUN: llc -march=mipsel -mattr=+dsp < %s | FileCheck %s

define i32 @test__builtin_mips_extr_w1(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extr.w

  %1 = tail call i32 @llvm.mips.extr.w(i64 %a0, i32 15)
  ret i32 %1
}

declare i32 @llvm.mips.extr.w(i64, i32) nounwind

define i32 @test__builtin_mips_extr_w2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extrv.w

  %1 = tail call i32 @llvm.mips.extr.w(i64 %a0, i32 %a1)
  ret i32 %1
}

define i32 @test__builtin_mips_extr_r_w1(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extr_r.w

  %1 = tail call i32 @llvm.mips.extr.r.w(i64 %a0, i32 15)
  ret i32 %1
}

declare i32 @llvm.mips.extr.r.w(i64, i32) nounwind

define i32 @test__builtin_mips_extr_s_h1(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extrv_s.h

  %1 = tail call i32 @llvm.mips.extr.s.h(i64 %a0, i32 %a1)
  ret i32 %1
}

declare i32 @llvm.mips.extr.s.h(i64, i32) nounwind

define i32 @test__builtin_mips_extr_rs_w1(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extr_rs.w

  %1 = tail call i32 @llvm.mips.extr.rs.w(i64 %a0, i32 15)
  ret i32 %1
}

declare i32 @llvm.mips.extr.rs.w(i64, i32) nounwind

define i32 @test__builtin_mips_extr_rs_w2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extrv_rs.w

  %1 = tail call i32 @llvm.mips.extr.rs.w(i64 %a0, i32 %a1)
  ret i32 %1
}

define i32 @test__builtin_mips_extr_s_h2(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extr_s.h

  %1 = tail call i32 @llvm.mips.extr.s.h(i64 %a0, i32 15)
  ret i32 %1
}

define i32 @test__builtin_mips_extr_r_w2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extrv_r.w

  %1 = tail call i32 @llvm.mips.extr.r.w(i64 %a0, i32 %a1)
  ret i32 %1
}

define i32 @test__builtin_mips_extp1(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extp

  %1 = tail call i32 @llvm.mips.extp(i64 %a0, i32 15)
  ret i32 %1
}

declare i32 @llvm.mips.extp(i64, i32) nounwind

define i32 @test__builtin_mips_extp2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extpv

  %1 = tail call i32 @llvm.mips.extp(i64 %a0, i32 %a1)
  ret i32 %1
}

define i32 @test__builtin_mips_extpdp1(i32 %i0, i32, i64 %a0) nounwind {
entry:
; CHECK: extpdp

  %1 = tail call i32 @llvm.mips.extpdp(i64 %a0, i32 15)
  ret i32 %1
}

declare i32 @llvm.mips.extpdp(i64, i32) nounwind

define i32 @test__builtin_mips_extpdp2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: extpdpv

  %1 = tail call i32 @llvm.mips.extpdp(i64 %a0, i32 %a1)
  ret i32 %1
}

define i64 @test__builtin_mips_dpau_h_qbl1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpau.h.qbl

  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = bitcast i32 %a2.coerce to <4 x i8>
  %3 = tail call i64 @llvm.mips.dpau.h.qbl(i64 %a0, <4 x i8> %1, <4 x i8> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpau.h.qbl(i64, <4 x i8>, <4 x i8>) nounwind readnone

define i64 @test__builtin_mips_dpau_h_qbr1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpau.h.qbr

  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = bitcast i32 %a2.coerce to <4 x i8>
  %3 = tail call i64 @llvm.mips.dpau.h.qbr(i64 %a0, <4 x i8> %1, <4 x i8> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpau.h.qbr(i64, <4 x i8>, <4 x i8>) nounwind readnone

define i64 @test__builtin_mips_dpsu_h_qbl1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpsu.h.qbl

  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = bitcast i32 %a2.coerce to <4 x i8>
  %3 = tail call i64 @llvm.mips.dpsu.h.qbl(i64 %a0, <4 x i8> %1, <4 x i8> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsu.h.qbl(i64, <4 x i8>, <4 x i8>) nounwind readnone

define i64 @test__builtin_mips_dpsu_h_qbr1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpsu.h.qbr

  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = bitcast i32 %a2.coerce to <4 x i8>
  %3 = tail call i64 @llvm.mips.dpsu.h.qbr(i64 %a0, <4 x i8> %1, <4 x i8> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsu.h.qbr(i64, <4 x i8>, <4 x i8>) nounwind readnone

define i64 @test__builtin_mips_dpaq_s_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpaq_s.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpaq.s.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpaq.s.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_dpaq_sa_l_w1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind {
entry:
; CHECK: dpaq_sa.l.w

  %1 = tail call i64 @llvm.mips.dpaq.sa.l.w(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.dpaq.sa.l.w(i64, i32, i32) nounwind

define i64 @test__builtin_mips_dpsq_s_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpsq_s.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpsq.s.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsq.s.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_dpsq_sa_l_w1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind {
entry:
; CHECK: dpsq_sa.l.w

  %1 = tail call i64 @llvm.mips.dpsq.sa.l.w(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.dpsq.sa.l.w(i64, i32, i32) nounwind

define i64 @test__builtin_mips_mulsaq_s_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: mulsaq_s.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.mulsaq.s.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.mulsaq.s.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_maq_s_w_phl1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: maq_s.w.phl

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.maq.s.w.phl(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.maq.s.w.phl(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_maq_s_w_phr1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: maq_s.w.phr

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.maq.s.w.phr(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.maq.s.w.phr(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_maq_sa_w_phl1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: maq_sa.w.phl

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.maq.sa.w.phl(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.maq.sa.w.phl(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_maq_sa_w_phr1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: maq_sa.w.phr

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.maq.sa.w.phr(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.maq.sa.w.phr(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_shilo1(i32 %i0, i32, i64 %a0) nounwind readnone {
entry:
; CHECK: shilo

  %1 = tail call i64 @llvm.mips.shilo(i64 %a0, i32 0)
  ret i64 %1
}

declare i64 @llvm.mips.shilo(i64, i32) nounwind readnone

define i64 @test__builtin_mips_shilo2(i32 %i0, i32, i64 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: shilov

  %1 = tail call i64 @llvm.mips.shilo(i64 %a0, i32 %a1)
  ret i64 %1
}

define i64 @test__builtin_mips_mthlip1(i32 %i0, i32, i64 %a0, i32 %a1) nounwind {
entry:
; CHECK: mthlip

  %1 = tail call i64 @llvm.mips.mthlip(i64 %a0, i32 %a1)
  ret i64 %1
}

declare i64 @llvm.mips.mthlip(i64, i32) nounwind

define i32 @test__builtin_mips_bposge321(i32 %i0) nounwind readonly {
entry:
; CHECK: bposge32

  %0 = tail call i32 @llvm.mips.bposge32()
  ret i32 %0
}

declare i32 @llvm.mips.bposge32() nounwind readonly

define i64 @test__builtin_mips_madd1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind readnone {
entry:
; CHECK: madd

  %1 = tail call i64 @llvm.mips.madd(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.madd(i64, i32, i32) nounwind readnone

define i64 @test__builtin_mips_maddu1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind readnone {
entry:
; CHECK: maddu

  %1 = tail call i64 @llvm.mips.maddu(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.maddu(i64, i32, i32) nounwind readnone

define i64 @test__builtin_mips_msub1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind readnone {
entry:
; CHECK: msub

  %1 = tail call i64 @llvm.mips.msub(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.msub(i64, i32, i32) nounwind readnone

define i64 @test__builtin_mips_msubu1(i32 %i0, i32, i64 %a0, i32 %a1, i32 %a2) nounwind readnone {
entry:
; CHECK: msubu

  %1 = tail call i64 @llvm.mips.msubu(i64 %a0, i32 %a1, i32 %a2)
  ret i64 %1
}

declare i64 @llvm.mips.msubu(i64, i32, i32) nounwind readnone

define i64 @test__builtin_mips_mult1(i32 %i0, i32 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: mult

  %0 = tail call i64 @llvm.mips.mult(i32 %a0, i32 %a1)
  ret i64 %0
}

declare i64 @llvm.mips.mult(i32, i32) nounwind readnone

define i64 @test__builtin_mips_multu1(i32 %i0, i32 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: multu

  %0 = tail call i64 @llvm.mips.multu(i32 %a0, i32 %a1)
  ret i64 %0
}

declare i64 @llvm.mips.multu(i32, i32) nounwind readnone

define { i32 } @test__builtin_mips_addq_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addq.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.addq.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.addq.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_addq_s_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addq_s.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.addq.s.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.addq.s.ph(<2 x i16>, <2 x i16>) nounwind

define i32 @test__builtin_mips_addq_s_w1(i32 %i0, i32 %a0, i32 %a1) nounwind {
entry:
; CHECK: addq_s.w

  %0 = tail call i32 @llvm.mips.addq.s.w(i32 %a0, i32 %a1)
  ret i32 %0
}

declare i32 @llvm.mips.addq.s.w(i32, i32) nounwind

define { i32 } @test__builtin_mips_addu_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addu.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call <4 x i8> @llvm.mips.addu.qb(<4 x i8> %0, <4 x i8> %1)
  %3 = bitcast <4 x i8> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.addu.qb(<4 x i8>, <4 x i8>) nounwind

define { i32 } @test__builtin_mips_addu_s_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addu_s.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call <4 x i8> @llvm.mips.addu.s.qb(<4 x i8> %0, <4 x i8> %1)
  %3 = bitcast <4 x i8> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.addu.s.qb(<4 x i8>, <4 x i8>) nounwind

define { i32 } @test__builtin_mips_subq_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subq.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.subq.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.subq.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_subq_s_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subq_s.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.subq.s.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.subq.s.ph(<2 x i16>, <2 x i16>) nounwind

define i32 @test__builtin_mips_subq_s_w1(i32 %i0, i32 %a0, i32 %a1) nounwind {
entry:
; CHECK: subq_s.w

  %0 = tail call i32 @llvm.mips.subq.s.w(i32 %a0, i32 %a1)
  ret i32 %0
}

declare i32 @llvm.mips.subq.s.w(i32, i32) nounwind

define { i32 } @test__builtin_mips_subu_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subu.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call <4 x i8> @llvm.mips.subu.qb(<4 x i8> %0, <4 x i8> %1)
  %3 = bitcast <4 x i8> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.subu.qb(<4 x i8>, <4 x i8>) nounwind

define { i32 } @test__builtin_mips_subu_s_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subu_s.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call <4 x i8> @llvm.mips.subu.s.qb(<4 x i8> %0, <4 x i8> %1)
  %3 = bitcast <4 x i8> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.subu.s.qb(<4 x i8>, <4 x i8>) nounwind

define i32 @test__builtin_mips_addsc1(i32 %i0, i32 %a0, i32 %a1) nounwind {
entry:
; CHECK: addsc

  %0 = tail call i32 @llvm.mips.addsc(i32 %a0, i32 %a1)
  ret i32 %0
}

declare i32 @llvm.mips.addsc(i32, i32) nounwind

define i32 @test__builtin_mips_addwc1(i32 %i0, i32 %a0, i32 %a1) nounwind {
entry:
; CHECK: addwc

  %0 = tail call i32 @llvm.mips.addwc(i32 %a0, i32 %a1)
  ret i32 %0
}

declare i32 @llvm.mips.addwc(i32, i32) nounwind

define i32 @test__builtin_mips_modsub1(i32 %i0, i32 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: modsub

  %0 = tail call i32 @llvm.mips.modsub(i32 %a0, i32 %a1)
  ret i32 %0
}

declare i32 @llvm.mips.modsub(i32, i32) nounwind readnone

define i32 @test__builtin_mips_raddu_w_qb1(i32 %i0, i32 %a0.coerce) nounwind readnone {
entry:
; CHECK: raddu.w.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = tail call i32 @llvm.mips.raddu.w.qb(<4 x i8> %0)
  ret i32 %1
}

declare i32 @llvm.mips.raddu.w.qb(<4 x i8>) nounwind readnone

define { i32 } @test__builtin_mips_muleu_s_ph_qbl1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: muleu_s.ph.qbl

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.muleu.s.ph.qbl(<4 x i8> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.muleu.s.ph.qbl(<4 x i8>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_muleu_s_ph_qbr1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: muleu_s.ph.qbr

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.muleu.s.ph.qbr(<4 x i8> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.muleu.s.ph.qbr(<4 x i8>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_mulq_rs_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: mulq_rs.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.mulq.rs.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.mulq.rs.ph(<2 x i16>, <2 x i16>) nounwind

define i32 @test__builtin_mips_muleq_s_w_phl1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: muleq_s.w.phl

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call i32 @llvm.mips.muleq.s.w.phl(<2 x i16> %0, <2 x i16> %1)
  ret i32 %2
}

declare i32 @llvm.mips.muleq.s.w.phl(<2 x i16>, <2 x i16>) nounwind

define i32 @test__builtin_mips_muleq_s_w_phr1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: muleq_s.w.phr

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call i32 @llvm.mips.muleq.s.w.phr(<2 x i16> %0, <2 x i16> %1)
  ret i32 %2
}

declare i32 @llvm.mips.muleq.s.w.phr(<2 x i16>, <2 x i16>) nounwind
