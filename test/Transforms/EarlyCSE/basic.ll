; RUN: opt < %s -S -early-cse | FileCheck %s


; CHECK: @test1
define void @test1(i8 %V, i32 *%P) {
  %A = bitcast i64 42 to double  ;; dead
  %B = add i32 4, 19             ;; constant folds
  store i32 %B, i32* %P
  
  ; CHECK-NEXT: store i32 23, i32* %P
  
  %C = zext i8 %V to i32
  %D = zext i8 %V to i32  ;; CSE
  volatile store i32 %C, i32* %P
  volatile store i32 %D, i32* %P
  
  ; CHECK-NEXT: %C = zext i8 %V to i32
  ; CHECK-NEXT: volatile store i32 %C
  ; CHECK-NEXT: volatile store i32 %C
  ret void
}
