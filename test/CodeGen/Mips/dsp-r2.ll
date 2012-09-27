; RUN: llc -march=mipsel -mattr=+dspr2 < %s | FileCheck %s

define i64 @test__builtin_mips_dpa_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpa.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpa.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpa.w.ph(i64, <2 x i16>, <2 x i16>) nounwind readnone

define i64 @test__builtin_mips_dps_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dps.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dps.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dps.w.ph(i64, <2 x i16>, <2 x i16>) nounwind readnone

define i64 @test__builtin_mips_mulsa_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: mulsa.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.mulsa.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.mulsa.w.ph(i64, <2 x i16>, <2 x i16>) nounwind readnone

define i64 @test__builtin_mips_dpax_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpax.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpax.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpax.w.ph(i64, <2 x i16>, <2 x i16>) nounwind readnone

define i64 @test__builtin_mips_dpsx_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind readnone {
entry:
; CHECK: dpsx.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpsx.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsx.w.ph(i64, <2 x i16>, <2 x i16>) nounwind readnone

define i64 @test__builtin_mips_dpaqx_s_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpaqx_s.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpaqx.s.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpaqx.s.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_dpaqx_sa_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpaqx_sa.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpaqx.sa.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpaqx.sa.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_dpsqx_s_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpsqx_s.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpsqx.s.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsqx.s.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define i64 @test__builtin_mips_dpsqx_sa_w_ph1(i32 %i0, i32, i64 %a0, i32 %a1.coerce, i32 %a2.coerce) nounwind {
entry:
; CHECK: dpsqx_sa.w.ph

  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = bitcast i32 %a2.coerce to <2 x i16>
  %3 = tail call i64 @llvm.mips.dpsqx.sa.w.ph(i64 %a0, <2 x i16> %1, <2 x i16> %2)
  ret i64 %3
}

declare i64 @llvm.mips.dpsqx.sa.w.ph(i64, <2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_addu_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addu.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.addu.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.addu.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_addu_s_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: addu_s.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.addu.s.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.addu.s.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_mulq_s_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: mulq_s.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.mulq.s.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.mulq.s.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_subu_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subu.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.subu.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.subu.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_subu_s_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: subu_s.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <2 x i16> @llvm.mips.subu.s.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <2 x i16> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.subu.s.ph(<2 x i16>, <2 x i16>) nounwind

define i32 @test__builtin_mips_cmpgdu_eq_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: cmpgdu.eq.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call i32 @llvm.mips.cmpgdu.eq.qb(<4 x i8> %0, <4 x i8> %1)
  ret i32 %2
}

declare i32 @llvm.mips.cmpgdu.eq.qb(<4 x i8>, <4 x i8>) nounwind

define i32 @test__builtin_mips_cmpgdu_lt_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: cmpgdu.lt.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call i32 @llvm.mips.cmpgdu.lt.qb(<4 x i8> %0, <4 x i8> %1)
  ret i32 %2
}

declare i32 @llvm.mips.cmpgdu.lt.qb(<4 x i8>, <4 x i8>) nounwind

define i32 @test__builtin_mips_cmpgdu_le_qb1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: cmpgdu.le.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = bitcast i32 %a1.coerce to <4 x i8>
  %2 = tail call i32 @llvm.mips.cmpgdu.le.qb(<4 x i8> %0, <4 x i8> %1)
  ret i32 %2
}

declare i32 @llvm.mips.cmpgdu.le.qb(<4 x i8>, <4 x i8>) nounwind

define { i32 } @test__builtin_mips_precr_qb_ph1(i32 %i0, i32 %a0.coerce, i32 %a1.coerce) nounwind {
entry:
; CHECK: precr.qb.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = bitcast i32 %a1.coerce to <2 x i16>
  %2 = tail call <4 x i8> @llvm.mips.precr.qb.ph(<2 x i16> %0, <2 x i16> %1)
  %3 = bitcast <4 x i8> %2 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %3, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.precr.qb.ph(<2 x i16>, <2 x i16>) nounwind

define { i32 } @test__builtin_mips_precr_sra_ph_w1(i32 %i0, i32 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: precr_sra.ph.w

  %0 = tail call <2 x i16> @llvm.mips.precr.sra.ph.w(i32 %a0, i32 %a1, i32 15)
  %1 = bitcast <2 x i16> %0 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %1, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.precr.sra.ph.w(i32, i32, i32) nounwind readnone

define { i32 } @test__builtin_mips_precr_sra_r_ph_w1(i32 %i0, i32 %a0, i32 %a1) nounwind readnone {
entry:
; CHECK: precr_sra_r.ph.w

  %0 = tail call <2 x i16> @llvm.mips.precr.sra.r.ph.w(i32 %a0, i32 %a1, i32 15)
  %1 = bitcast <2 x i16> %0 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %1, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.precr.sra.r.ph.w(i32, i32, i32) nounwind readnone

define { i32 } @test__builtin_mips_shra_qb1(i32 %i0, i32 %a0.coerce) nounwind readnone {
entry:
; CHECK: shra.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = tail call <4 x i8> @llvm.mips.shra.qb(<4 x i8> %0, i32 3)
  %2 = bitcast <4 x i8> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.shra.qb(<4 x i8>, i32) nounwind readnone

define { i32 } @test__builtin_mips_shra_r_qb1(i32 %i0, i32 %a0.coerce) nounwind readnone {
entry:
; CHECK: shra_r.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = tail call <4 x i8> @llvm.mips.shra.r.qb(<4 x i8> %0, i32 3)
  %2 = bitcast <4 x i8> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}

declare <4 x i8> @llvm.mips.shra.r.qb(<4 x i8>, i32) nounwind readnone

define { i32 } @test__builtin_mips_shra_qb2(i32 %i0, i32 %a0.coerce, i32 %a1) nounwind readnone {
entry:
; CHECK: shrav.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = tail call <4 x i8> @llvm.mips.shra.qb(<4 x i8> %0, i32 %a1)
  %2 = bitcast <4 x i8> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}

define { i32 } @test__builtin_mips_shra_r_qb2(i32 %i0, i32 %a0.coerce, i32 %a1) nounwind readnone {
entry:
; CHECK: shrav_r.qb

  %0 = bitcast i32 %a0.coerce to <4 x i8>
  %1 = tail call <4 x i8> @llvm.mips.shra.r.qb(<4 x i8> %0, i32 %a1)
  %2 = bitcast <4 x i8> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}

define { i32 } @test__builtin_mips_shrl_ph1(i32 %i0, i32 %a0.coerce) nounwind readnone {
entry:
; CHECK: shrl.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = tail call <2 x i16> @llvm.mips.shrl.ph(<2 x i16> %0, i32 7)
  %2 = bitcast <2 x i16> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}

declare <2 x i16> @llvm.mips.shrl.ph(<2 x i16>, i32) nounwind readnone

define { i32 } @test__builtin_mips_shrl_ph2(i32 %i0, i32 %a0.coerce, i32 %a1) nounwind readnone {
entry:
; CHECK: shrlv.ph

  %0 = bitcast i32 %a0.coerce to <2 x i16>
  %1 = tail call <2 x i16> @llvm.mips.shrl.ph(<2 x i16> %0, i32 %a1)
  %2 = bitcast <2 x i16> %1 to i32
  %.fca.0.insert = insertvalue { i32 } undef, i32 %2, 0
  ret { i32 } %.fca.0.insert
}
