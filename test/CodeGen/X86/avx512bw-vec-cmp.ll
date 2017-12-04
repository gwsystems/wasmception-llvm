; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck %s

define <64 x i8> @test1(<64 x i8> %x, <64 x i8> %y) nounwind {
; CHECK-LABEL: test1:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpeqb %zmm1, %zmm0, %k1
; CHECK-NEXT:    vpblendmb %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp eq <64 x i8> %x, %y
  %max = select <64 x i1> %mask, <64 x i8> %x, <64 x i8> %y
  ret <64 x i8> %max
}

define <64 x i8> @test2(<64 x i8> %x, <64 x i8> %y, <64 x i8> %x1) nounwind {
; CHECK-LABEL: test2:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpgtb %zmm1, %zmm0, %k1
; CHECK-NEXT:    vpblendmb %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sgt <64 x i8> %x, %y
  %max = select <64 x i1> %mask, <64 x i8> %x1, <64 x i8> %y
  ret <64 x i8> %max
}

define <32 x i16> @test3(<32 x i16> %x, <32 x i16> %y, <32 x i16> %x1) nounwind {
; CHECK-LABEL: test3:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmplew %zmm0, %zmm1, %k1
; CHECK-NEXT:    vpblendmw %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sge <32 x i16> %x, %y
  %max = select <32 x i1> %mask, <32 x i16> %x1, <32 x i16> %y
  ret <32 x i16> %max
}

define <64 x i8> @test4(<64 x i8> %x, <64 x i8> %y, <64 x i8> %x1) nounwind {
; CHECK-LABEL: test4:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpnleub %zmm1, %zmm0, %k1
; CHECK-NEXT:    vpblendmb %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ugt <64 x i8> %x, %y
  %max = select <64 x i1> %mask, <64 x i8> %x1, <64 x i8> %y
  ret <64 x i8> %max
}

define <32 x i16> @test5(<32 x i16> %x, <32 x i16> %x1, <32 x i16>* %yp) nounwind {
; CHECK-LABEL: test5:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpeqw (%rdi), %zmm0, %k1
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <32 x i16>, <32 x i16>* %yp, align 4
  %mask = icmp eq <32 x i16> %x, %y
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %x1
  ret <32 x i16> %max
}

define <32 x i16> @test6(<32 x i16> %x, <32 x i16> %x1, <32 x i16>* %y.ptr) nounwind {
; CHECK-LABEL: test6:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpgtw (%rdi), %zmm0, %k1
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <32 x i16>, <32 x i16>* %y.ptr, align 4
  %mask = icmp sgt <32 x i16> %x, %y
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %x1
  ret <32 x i16> %max
}

define <32 x i16> @test7(<32 x i16> %x, <32 x i16> %x1, <32 x i16>* %y.ptr) nounwind {
; CHECK-LABEL: test7:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmplew (%rdi), %zmm0, %k1
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <32 x i16>, <32 x i16>* %y.ptr, align 4
  %mask = icmp sle <32 x i16> %x, %y
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %x1
  ret <32 x i16> %max
}

define <32 x i16> @test8(<32 x i16> %x, <32 x i16> %x1, <32 x i16>* %y.ptr) nounwind {
; CHECK-LABEL: test8:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpleuw (%rdi), %zmm0, %k1
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <32 x i16>, <32 x i16>* %y.ptr, align 4
  %mask = icmp ule <32 x i16> %x, %y
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %x1
  ret <32 x i16> %max
}

define <32 x i16> @test9(<32 x i16> %x, <32 x i16> %y, <32 x i16> %x1, <32 x i16> %y1) nounwind {
; CHECK-LABEL: test9:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpeqw %zmm1, %zmm0, %k1
; CHECK-NEXT:    vpcmpeqw %zmm3, %zmm2, %k1 {%k1}
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp eq <32 x i16> %x1, %y1
  %mask0 = icmp eq <32 x i16> %x, %y
  %mask = select <32 x i1> %mask0, <32 x i1> %mask1, <32 x i1> zeroinitializer
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %y
  ret <32 x i16> %max
}

define <64 x i8> @test10(<64 x i8> %x, <64 x i8> %y, <64 x i8> %x1, <64 x i8> %y1) nounwind {
; CHECK-LABEL: test10:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpleb %zmm1, %zmm0, %k1
; CHECK-NEXT:    vpcmpleb %zmm2, %zmm3, %k1 {%k1}
; CHECK-NEXT:    vpblendmb %zmm0, %zmm2, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <64 x i8> %x1, %y1
  %mask0 = icmp sle <64 x i8> %x, %y
  %mask = select <64 x i1> %mask0, <64 x i1> %mask1, <64 x i1> zeroinitializer
  %max = select <64 x i1> %mask, <64 x i8> %x, <64 x i8> %x1
  ret <64 x i8> %max
}

define <64 x i8> @test11(<64 x i8> %x, <64 x i8>* %y.ptr, <64 x i8> %x1, <64 x i8> %y1) nounwind {
; CHECK-LABEL: test11:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmpgtb %zmm2, %zmm1, %k1
; CHECK-NEXT:    vpcmpgtb (%rdi), %zmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmb %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sgt <64 x i8> %x1, %y1
  %y = load <64 x i8>, <64 x i8>* %y.ptr, align 4
  %mask0 = icmp sgt <64 x i8> %x, %y
  %mask = select <64 x i1> %mask0, <64 x i1> %mask1, <64 x i1> zeroinitializer
  %max = select <64 x i1> %mask, <64 x i8> %x, <64 x i8> %x1
  ret <64 x i8> %max
}

define <32 x i16> @test12(<32 x i16> %x, <32 x i16>* %y.ptr, <32 x i16> %x1, <32 x i16> %y1) nounwind {
; CHECK-LABEL: test12:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vpcmplew %zmm1, %zmm2, %k1
; CHECK-NEXT:    vpcmpleuw (%rdi), %zmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmw %zmm0, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <32 x i16> %x1, %y1
  %y = load <32 x i16>, <32 x i16>* %y.ptr, align 4
  %mask0 = icmp ule <32 x i16> %x, %y
  %mask = select <32 x i1> %mask0, <32 x i1> %mask1, <32 x i1> zeroinitializer
  %max = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> %x1
  ret <32 x i16> %max
}
