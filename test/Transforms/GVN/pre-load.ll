; RUN: opt < %s -gvn -enable-load-pre -S | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

define i32 @test1(i32* %p, i1 %C) {
; CHECK: @test1
block1:
	br i1 %C, label %block2, label %block3

block2:
 br label %block4
; CHECK: block2:
; CHECK-NEXT: load i32* %p

block3:
  store i32 0, i32* %p
  br label %block4

block4:
  %PRE = load i32* %p
  ret i32 %PRE
; CHECK: block4:
; CHECK-NEXT: phi i32
; CHECK-NEXT: ret i32
}

; This is a simple phi translation case.
define i32 @test2(i32* %p, i32* %q, i1 %C) {
; CHECK: @test2
block1:
	br i1 %C, label %block2, label %block3

block2:
 br label %block4
; CHECK: block2:
; CHECK-NEXT: load i32* %q

block3:
  store i32 0, i32* %p
  br label %block4

block4:
  %P2 = phi i32* [%p, %block3], [%q, %block2]
  %PRE = load i32* %P2
  ret i32 %PRE
; CHECK: block4:
; CHECK-NEXT: phi i32 [
; CHECK-NOT: load
; CHECK: ret i32
}

; This is a PRE case that requires phi translation through a GEP.
define i32 @test3(i32* %p, i32* %q, i32** %Hack, i1 %C) {
; CHECK: @test3
block1:
  %B = getelementptr i32* %q, i32 1
  store i32* %B, i32** %Hack
	br i1 %C, label %block2, label %block3

block2:
 br label %block4
; CHECK: block2:
; CHECK-NEXT: load i32* %B

block3:
  %A = getelementptr i32* %p, i32 1
  store i32 0, i32* %A
  br label %block4

block4:
  %P2 = phi i32* [%p, %block3], [%q, %block2]
  %P3 = getelementptr i32* %P2, i32 1
  %PRE = load i32* %P3
  ret i32 %PRE
; CHECK: block4:
; CHECK-NEXT: phi i32 [
; CHECK-NOT: load
; CHECK: ret i32
}

;; Here the loaded address is available, but the computation is in 'block3'
;; which does not dominate 'block2'.
define i32 @test4(i32* %p, i32* %q, i32** %Hack, i1 %C) {
; CHECK: @test4
block1:
	br i1 %C, label %block2, label %block3

block2:
 br label %block4
; HECK: block2:
; HECK:   load i32*
; HECK:   br label %block4

block3:
  %B = getelementptr i32* %q, i32 1
  store i32* %B, i32** %Hack

  %A = getelementptr i32* %p, i32 1
  store i32 0, i32* %A
  br label %block4

block4:
  %P2 = phi i32* [%p, %block3], [%q, %block2]
  %P3 = getelementptr i32* %P2, i32 1
  %PRE = load i32* %P3
  ret i32 %PRE
; HECK: block4:
; HECK-NEXT: phi i32 [
; HECK-NOT: load
; HECK: ret i32
}

;void test5(int N, double *G) {
;  int j;
;  for (j = 0; j < N - 1; j++)
;    G[j] = G[j] + G[j+1];
;}

define void @test5(i32 %N, double* nocapture %G) nounwind ssp {
; CHECK: @test5
entry:
  %0 = add i32 %N, -1           
  %1 = icmp sgt i32 %0, 0       
  br i1 %1, label %bb.nph, label %return

bb.nph:                         
  %tmp = zext i32 %0 to i64     
  br label %bb

; CHECK: bb.nph:
; CHECK: load double*
; CHECK: br label %bb

bb:             
  %indvar = phi i64 [ 0, %bb.nph ], [ %tmp6, %bb ]
  %tmp6 = add i64 %indvar, 1                    
  %scevgep = getelementptr double* %G, i64 %tmp6
  %scevgep7 = getelementptr double* %G, i64 %indvar
  %2 = load double* %scevgep7, align 8
  %3 = load double* %scevgep, align 8 
  %4 = fadd double %2, %3             
  store double %4, double* %scevgep7, align 8
  %exitcond = icmp eq i64 %tmp6, %tmp 
  br i1 %exitcond, label %return, label %bb

; Should only be one load in the loop.
; CHECK: bb:
; CHECK: load double*
; CHECK-NOT: load double*
; CHECK: br i1 %exitcond

return:                               
  ret void
}

;void test6(int N, double *G) {
;  int j;
;  for (j = 0; j < N - 1; j++)
;    G[j+1] = G[j] + G[j+1];
;}

define void @test6(i32 %N, double* nocapture %G) nounwind ssp {
; CHECK: @test6
entry:
  %0 = add i32 %N, -1           
  %1 = icmp sgt i32 %0, 0       
  br i1 %1, label %bb.nph, label %return

bb.nph:                         
  %tmp = zext i32 %0 to i64     
  br label %bb

; CHECK: bb.nph:
; CHECK: load double*
; CHECK: br label %bb

bb:             
  %indvar = phi i64 [ 0, %bb.nph ], [ %tmp6, %bb ]
  %tmp6 = add i64 %indvar, 1                    
  %scevgep = getelementptr double* %G, i64 %tmp6
  %scevgep7 = getelementptr double* %G, i64 %indvar
  %2 = load double* %scevgep7, align 8
  %3 = load double* %scevgep, align 8 
  %4 = fadd double %2, %3             
  store double %4, double* %scevgep, align 8
  %exitcond = icmp eq i64 %tmp6, %tmp 
  br i1 %exitcond, label %return, label %bb

; Should only be one load in the loop.
; CHECK: bb:
; CHECK: load double*
; CHECK-NOT: load double*
; CHECK: br i1 %exitcond

return:                               
  ret void
}

;void test7(int N, double* G) {
;  long j;
;  G[1] = 1;
;  for (j = 1; j < N - 1; j++)
;      G[j+1] = G[j] + G[j+1];
;}

; This requires phi translation of the adds.
define void @test7(i32 %N, double* nocapture %G) nounwind ssp {
entry:
  %0 = getelementptr inbounds double* %G, i64 1   
  store double 1.000000e+00, double* %0, align 8
  %1 = add i32 %N, -1                             
  %2 = icmp sgt i32 %1, 1                         
  br i1 %2, label %bb.nph, label %return

bb.nph:                                           
  %tmp = sext i32 %1 to i64                       
  %tmp7 = add i64 %tmp, -1                        
  br label %bb

bb:                                               
  %indvar = phi i64 [ 0, %bb.nph ], [ %tmp9, %bb ] 
  %tmp8 = add i64 %indvar, 2                      
  %scevgep = getelementptr double* %G, i64 %tmp8  
  %tmp9 = add i64 %indvar, 1                      
  %scevgep10 = getelementptr double* %G, i64 %tmp9 
  %3 = load double* %scevgep10, align 8           
  %4 = load double* %scevgep, align 8             
  %5 = fadd double %3, %4                         
  store double %5, double* %scevgep, align 8
  %exitcond = icmp eq i64 %tmp9, %tmp7            
  br i1 %exitcond, label %return, label %bb

; Should only be one load in the loop.
; CHECK: bb:
; CHECK: load double*
; CHECK-NOT: load double*
; CHECK: br i1 %exitcond

return:                                           
  ret void
}

;; Here the loaded address isn't available in 'block2' at all, requiring a new
;; GEP to be inserted into it.
define i32 @test8(i32* %p, i32* %q, i32** %Hack, i1 %C) {
; CHECK: @test8
block1:
	br i1 %C, label %block2, label %block3

block2:
 br label %block4
; HECK: block2:
; HECK:   load i32*
; HECK:   br label %block4

block3:
  %A = getelementptr i32* %p, i32 1
  store i32 0, i32* %A
  br label %block4

block4:
  %P2 = phi i32* [%p, %block3], [%q, %block2]
  %P3 = getelementptr i32* %P2, i32 1
  %PRE = load i32* %P3
  ret i32 %PRE
; HECK: block4:
; HECK-NEXT: phi i32 [
; HECK-NOT: load
; HECK: ret i32
}


