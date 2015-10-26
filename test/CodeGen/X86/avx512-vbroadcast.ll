; RUN: llc < %s -mcpu=x86-64 -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mcpu=x86-64 -mattr=+avx512bw | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512BW

define   <16 x i32> @_inreg16xi32(i32 %a) {
; ALL-LABEL: _inreg16xi32:
; ALL:       # BB#0:
; ALL-NEXT:    vpbroadcastd %edi, %zmm0
; ALL-NEXT:    retq
  %b = insertelement <16 x i32> undef, i32 %a, i32 0
  %c = shufflevector <16 x i32> %b, <16 x i32> undef, <16 x i32> zeroinitializer
  ret <16 x i32> %c
}

define   <8 x i64> @_inreg8xi64(i64 %a) {
; ALL-LABEL: _inreg8xi64:
; ALL:       # BB#0:
; ALL-NEXT:    vpbroadcastq %rdi, %zmm0
; ALL-NEXT:    retq
  %b = insertelement <8 x i64> undef, i64 %a, i32 0
  %c = shufflevector <8 x i64> %b, <8 x i64> undef, <8 x i32> zeroinitializer
  ret <8 x i64> %c
}

define   <16 x float> @_ss16xfloat_v4(<4 x float> %a) {
; ALL-LABEL: _ss16xfloat_v4:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0
; ALL-NEXT:    retq
  %b = shufflevector <4 x float> %a, <4 x float> undef, <16 x i32> zeroinitializer
  ret <16 x float> %b
}

define   <16 x float> @_inreg16xfloat(float %a) {
; ALL-LABEL: _inreg16xfloat:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0
; ALL-NEXT:    retq
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  ret <16 x float> %c
}

define   <16 x float> @_ss16xfloat_mask(float %a, <16 x float> %i, <16 x i32> %mask1) {
; ALL-LABEL: _ss16xfloat_mask:
; ALL:       # BB#0:
; ALL-NEXT:    vpxord %zmm3, %zmm3, %zmm3
; ALL-NEXT:    vpcmpneqd %zmm3, %zmm2, %k1
; ALL-NEXT:    vbroadcastss %xmm0, %zmm1 {%k1}
; ALL-NEXT:    vmovaps %zmm1, %zmm0
; ALL-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  %r = select <16 x i1> %mask, <16 x float> %c, <16 x float> %i
  ret <16 x float> %r
}

define   <16 x float> @_ss16xfloat_maskz(float %a, <16 x i32> %mask1) {
; ALL-LABEL: _ss16xfloat_maskz:
; ALL:       # BB#0:
; ALL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; ALL-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0 {%k1} {z}
; ALL-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  %r = select <16 x i1> %mask, <16 x float> %c, <16 x float> zeroinitializer
  ret <16 x float> %r
}

define   <16 x float> @_ss16xfloat_load(float* %a.ptr) {
; ALL-LABEL: _ss16xfloat_load:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastss (%rdi), %zmm0
; ALL-NEXT:    retq
  %a = load float, float* %a.ptr
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  ret <16 x float> %c
}

define   <16 x float> @_ss16xfloat_mask_load(float* %a.ptr, <16 x float> %i, <16 x i32> %mask1) {
; ALL-LABEL: _ss16xfloat_mask_load:
; ALL:       # BB#0:
; ALL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; ALL-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; ALL-NEXT:    vbroadcastss (%rdi), %zmm0 {%k1}
; ALL-NEXT:    retq
  %a = load float, float* %a.ptr
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  %r = select <16 x i1> %mask, <16 x float> %c, <16 x float> %i
  ret <16 x float> %r
}

define   <16 x float> @_ss16xfloat_maskz_load(float* %a.ptr, <16 x i32> %mask1) {
; ALL-LABEL: _ss16xfloat_maskz_load:
; ALL:       # BB#0:
; ALL-NEXT:    vpxord %zmm1, %zmm1, %zmm1
; ALL-NEXT:    vpcmpneqd %zmm1, %zmm0, %k1
; ALL-NEXT:    vbroadcastss (%rdi), %zmm0 {%k1} {z}
; ALL-NEXT:    retq
  %a = load float, float* %a.ptr
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %b = insertelement <16 x float> undef, float %a, i32 0
  %c = shufflevector <16 x float> %b, <16 x float> undef, <16 x i32> zeroinitializer
  %r = select <16 x i1> %mask, <16 x float> %c, <16 x float> zeroinitializer
  ret <16 x float> %r
}

define   <8 x double> @_inreg8xdouble(double %a) {
; ALL-LABEL: _inreg8xdouble:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm0
; ALL-NEXT:    retq
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  ret <8 x double> %c
}

define   <8 x double> @_sd8xdouble_mask(double %a, <8 x double> %i, <8 x i32> %mask1) {
; ALL-LABEL: _sd8xdouble_mask:
; ALL:       # BB#0:
; ALL-NEXT:    vpxor %ymm3, %ymm3, %ymm3
; ALL-NEXT:    vpcmpneqd %zmm3, %zmm2, %k1
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm1 {%k1}
; ALL-NEXT:    vmovaps %zmm1, %zmm0
; ALL-NEXT:    retq
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  %r = select <8 x i1> %mask, <8 x double> %c, <8 x double> %i
  ret <8 x double> %r
}

define   <8 x double> @_sd8xdouble_maskz(double %a, <8 x i32> %mask1) {
; ALL-LABEL: _sd8xdouble_maskz:
; ALL:       # BB#0:
; ALL-NEXT:    vpxor %ymm2, %ymm2, %ymm2
; ALL-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm0 {%k1} {z}
; ALL-NEXT:    retq
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  %r = select <8 x i1> %mask, <8 x double> %c, <8 x double> zeroinitializer
  ret <8 x double> %r
}

define   <8 x double> @_sd8xdouble_load(double* %a.ptr) {
; ALL-LABEL: _sd8xdouble_load:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastsd (%rdi), %zmm0
; ALL-NEXT:    retq
  %a = load double, double* %a.ptr
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  ret <8 x double> %c
}

define   <8 x double> @_sd8xdouble_mask_load(double* %a.ptr, <8 x double> %i, <8 x i32> %mask1) {
; ALL-LABEL: _sd8xdouble_mask_load:
; ALL:       # BB#0:
; ALL-NEXT:    vpxor %ymm2, %ymm2, %ymm2
; ALL-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; ALL-NEXT:    vbroadcastsd (%rdi), %zmm0 {%k1}
; ALL-NEXT:    retq
  %a = load double, double* %a.ptr
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  %r = select <8 x i1> %mask, <8 x double> %c, <8 x double> %i
  ret <8 x double> %r
}

define   <8 x double> @_sd8xdouble_maskz_load(double* %a.ptr, <8 x i32> %mask1) {
; ALL-LABEL: _sd8xdouble_maskz_load:
; ALL:       # BB#0:
; ALL-NEXT:    vpxor %ymm1, %ymm1, %ymm1
; ALL-NEXT:    vpcmpneqd %zmm1, %zmm0, %k1
; ALL-NEXT:    vbroadcastsd (%rdi), %zmm0 {%k1} {z}
; ALL-NEXT:    retq
  %a = load double, double* %a.ptr
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %b = insertelement <8 x double> undef, double %a, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef, <8 x i32> zeroinitializer
  %r = select <8 x i1> %mask, <8 x double> %c, <8 x double> zeroinitializer
  ret <8 x double> %r
}

define   <16 x i32> @_xmm16xi32(<16 x i32> %a) {
; ALL-LABEL: _xmm16xi32:
; ALL:       # BB#0:
; ALL-NEXT:    vpbroadcastd %xmm0, %zmm0
; ALL-NEXT:    retq
  %b = shufflevector <16 x i32> %a, <16 x i32> undef, <16 x i32> zeroinitializer
  ret <16 x i32> %b
}

define   <16 x float> @_xmm16xfloat(<16 x float> %a) {
; ALL-LABEL: _xmm16xfloat:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0
; ALL-NEXT:    retq
  %b = shufflevector <16 x float> %a, <16 x float> undef, <16 x i32> zeroinitializer
  ret <16 x float> %b
}

define <16 x i32> @test_vbroadcast() {
; ALL-LABEL: test_vbroadcast:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vpxord %zmm0, %zmm0, %zmm0
; ALL-NEXT:    vcmpunordps %zmm0, %zmm0, %k1
; ALL-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; ALL-NEXT:    knotw %k1, %k1
; ALL-NEXT:    vmovdqu32 %zmm0, %zmm0 {%k1} {z}
; ALL-NEXT:    retq
entry:
  %0 = sext <16 x i1> zeroinitializer to <16 x i32>
  %1 = fcmp uno <16 x float> undef, zeroinitializer
  %2 = sext <16 x i1> %1 to <16 x i32>
  %3 = select <16 x i1> %1, <16 x i32> %0, <16 x i32> %2
  ret <16 x i32> %3
}

; We implement the set1 intrinsics with vector initializers.  Verify that the
; IR generated will produce broadcasts at the end.
define <8 x double> @test_set1_pd(double %d) #2 {
; ALL-LABEL: test_set1_pd:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm0
; ALL-NEXT:    retq
entry:
  %vecinit.i = insertelement <8 x double> undef, double %d, i32 0
  %vecinit1.i = insertelement <8 x double> %vecinit.i, double %d, i32 1
  %vecinit2.i = insertelement <8 x double> %vecinit1.i, double %d, i32 2
  %vecinit3.i = insertelement <8 x double> %vecinit2.i, double %d, i32 3
  %vecinit4.i = insertelement <8 x double> %vecinit3.i, double %d, i32 4
  %vecinit5.i = insertelement <8 x double> %vecinit4.i, double %d, i32 5
  %vecinit6.i = insertelement <8 x double> %vecinit5.i, double %d, i32 6
  %vecinit7.i = insertelement <8 x double> %vecinit6.i, double %d, i32 7
  ret <8 x double> %vecinit7.i
}

define <8 x i64> @test_set1_epi64(i64 %d) #2 {
; ALL-LABEL: test_set1_epi64:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vpbroadcastq %rdi, %zmm0
; ALL-NEXT:    retq
entry:
  %vecinit.i = insertelement <8 x i64> undef, i64 %d, i32 0
  %vecinit1.i = insertelement <8 x i64> %vecinit.i, i64 %d, i32 1
  %vecinit2.i = insertelement <8 x i64> %vecinit1.i, i64 %d, i32 2
  %vecinit3.i = insertelement <8 x i64> %vecinit2.i, i64 %d, i32 3
  %vecinit4.i = insertelement <8 x i64> %vecinit3.i, i64 %d, i32 4
  %vecinit5.i = insertelement <8 x i64> %vecinit4.i, i64 %d, i32 5
  %vecinit6.i = insertelement <8 x i64> %vecinit5.i, i64 %d, i32 6
  %vecinit7.i = insertelement <8 x i64> %vecinit6.i, i64 %d, i32 7
  ret <8 x i64> %vecinit7.i
}

define <16 x float> @test_set1_ps(float %f) #2 {
; ALL-LABEL: test_set1_ps:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0
; ALL-NEXT:    retq
entry:
  %vecinit.i = insertelement <16 x float> undef, float %f, i32 0
  %vecinit1.i = insertelement <16 x float> %vecinit.i, float %f, i32 1
  %vecinit2.i = insertelement <16 x float> %vecinit1.i, float %f, i32 2
  %vecinit3.i = insertelement <16 x float> %vecinit2.i, float %f, i32 3
  %vecinit4.i = insertelement <16 x float> %vecinit3.i, float %f, i32 4
  %vecinit5.i = insertelement <16 x float> %vecinit4.i, float %f, i32 5
  %vecinit6.i = insertelement <16 x float> %vecinit5.i, float %f, i32 6
  %vecinit7.i = insertelement <16 x float> %vecinit6.i, float %f, i32 7
  %vecinit8.i = insertelement <16 x float> %vecinit7.i, float %f, i32 8
  %vecinit9.i = insertelement <16 x float> %vecinit8.i, float %f, i32 9
  %vecinit10.i = insertelement <16 x float> %vecinit9.i, float %f, i32 10
  %vecinit11.i = insertelement <16 x float> %vecinit10.i, float %f, i32 11
  %vecinit12.i = insertelement <16 x float> %vecinit11.i, float %f, i32 12
  %vecinit13.i = insertelement <16 x float> %vecinit12.i, float %f, i32 13
  %vecinit14.i = insertelement <16 x float> %vecinit13.i, float %f, i32 14
  %vecinit15.i = insertelement <16 x float> %vecinit14.i, float %f, i32 15
  ret <16 x float> %vecinit15.i
}

define <16 x i32> @test_set1_epi32(i32 %f) #2 {
; ALL-LABEL: test_set1_epi32:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vpbroadcastd %edi, %zmm0
; ALL-NEXT:    retq
entry:
  %vecinit.i = insertelement <16 x i32> undef, i32 %f, i32 0
  %vecinit1.i = insertelement <16 x i32> %vecinit.i, i32 %f, i32 1
  %vecinit2.i = insertelement <16 x i32> %vecinit1.i, i32 %f, i32 2
  %vecinit3.i = insertelement <16 x i32> %vecinit2.i, i32 %f, i32 3
  %vecinit4.i = insertelement <16 x i32> %vecinit3.i, i32 %f, i32 4
  %vecinit5.i = insertelement <16 x i32> %vecinit4.i, i32 %f, i32 5
  %vecinit6.i = insertelement <16 x i32> %vecinit5.i, i32 %f, i32 6
  %vecinit7.i = insertelement <16 x i32> %vecinit6.i, i32 %f, i32 7
  %vecinit8.i = insertelement <16 x i32> %vecinit7.i, i32 %f, i32 8
  %vecinit9.i = insertelement <16 x i32> %vecinit8.i, i32 %f, i32 9
  %vecinit10.i = insertelement <16 x i32> %vecinit9.i, i32 %f, i32 10
  %vecinit11.i = insertelement <16 x i32> %vecinit10.i, i32 %f, i32 11
  %vecinit12.i = insertelement <16 x i32> %vecinit11.i, i32 %f, i32 12
  %vecinit13.i = insertelement <16 x i32> %vecinit12.i, i32 %f, i32 13
  %vecinit14.i = insertelement <16 x i32> %vecinit13.i, i32 %f, i32 14
  %vecinit15.i = insertelement <16 x i32> %vecinit14.i, i32 %f, i32 15
  ret <16 x i32> %vecinit15.i
}

; We implement the scalar broadcast intrinsics with vector initializers.
; Verify that the IR generated will produce the broadcast at the end.
define <8 x double> @test_mm512_broadcastsd_pd(<2 x double> %a) {
; ALL-LABEL: test_mm512_broadcastsd_pd:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm0
; ALL-NEXT:    retq
entry:
  %0 = extractelement <2 x double> %a, i32 0
  %vecinit.i = insertelement <8 x double> undef, double %0, i32 0
  %vecinit1.i = insertelement <8 x double> %vecinit.i, double %0, i32 1
  %vecinit2.i = insertelement <8 x double> %vecinit1.i, double %0, i32 2
  %vecinit3.i = insertelement <8 x double> %vecinit2.i, double %0, i32 3
  %vecinit4.i = insertelement <8 x double> %vecinit3.i, double %0, i32 4
  %vecinit5.i = insertelement <8 x double> %vecinit4.i, double %0, i32 5
  %vecinit6.i = insertelement <8 x double> %vecinit5.i, double %0, i32 6
  %vecinit7.i = insertelement <8 x double> %vecinit6.i, double %0, i32 7
  ret <8 x double> %vecinit7.i
}

define <16 x float> @test1(<8 x float>%a)  {
; ALL-LABEL: test1:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastss %xmm0, %zmm0
; ALL-NEXT:    retq
  %res = shufflevector <8 x float> %a, <8 x float> undef, <16 x i32> zeroinitializer
  ret <16 x float>%res
}

define <8 x double> @test2(<4 x double>%a)  {
; ALL-LABEL: test2:
; ALL:       # BB#0:
; ALL-NEXT:    vbroadcastsd %xmm0, %zmm0
; ALL-NEXT:    retq
  %res = shufflevector <4 x double> %a, <4 x double> undef, <8 x i32> zeroinitializer
  ret <8 x double>%res
}

define <64 x i8> @_invec32xi8(<32 x i8>%a)  {
; AVX512F-LABEL: _invec32xi8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpbroadcastb %xmm0, %ymm0
; AVX512F-NEXT:    vmovaps %zmm0, %zmm1
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: _invec32xi8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpbroadcastb %xmm0, %zmm0
; AVX512BW-NEXT:    retq
  %res = shufflevector <32 x i8> %a, <32 x i8> undef, <64 x i32> zeroinitializer
  ret <64 x i8>%res
}

define <32 x i16> @_invec16xi16(<16 x i16>%a)  {
; AVX512F-LABEL: _invec16xi16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpbroadcastw %xmm0, %ymm0
; AVX512F-NEXT:    vmovaps %zmm0, %zmm1
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: _invec16xi16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpbroadcastw %xmm0, %zmm0
; AVX512BW-NEXT:    retq
  %res = shufflevector <16 x i16> %a, <16 x i16> undef, <32 x i32> zeroinitializer
  ret <32 x i16>%res
}

define <16 x i32> @_invec8xi32(<8 x i32>%a)  {
; ALL-LABEL: _invec8xi32:
; ALL:       # BB#0:
; ALL-NEXT:    vpbroadcastd %xmm0, %zmm0
; ALL-NEXT:    retq
  %res = shufflevector <8 x i32> %a, <8 x i32> undef, <16 x i32> zeroinitializer
  ret <16 x i32>%res
}

define <8 x i64> @_invec4xi64(<4 x i64>%a)  {
; ALL-LABEL: _invec4xi64:
; ALL:       # BB#0:
; ALL-NEXT:    vpbroadcastq %xmm0, %zmm0
; ALL-NEXT:    retq
  %res = shufflevector <4 x i64> %a, <4 x i64> undef, <8 x i32> zeroinitializer
  ret <8 x i64>%res
}

