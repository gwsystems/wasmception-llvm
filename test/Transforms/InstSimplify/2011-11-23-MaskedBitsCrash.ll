; RUN: opt < %s -instsimplify

; The mul can be proved to always overflow (turning a negative value
; into a positive one) and thus results in undefined behaviour.  At
; the same time we were deducing from the nsw flag that that mul could
; be assumed to have a negative value (since if not it has an undefined
; value, which can be taken to be negative).  We were reporting the mul
; as being both positive and negative, firing an assertion!
define i1 @test1(i32 %a) {
entry:
  %0 = or i32 %a, 1
  %1 = shl i32 %0, 31
  %2 = mul nsw i32 %1, 4
  %3 = and i32 %2, -4
  %4 = icmp ne i32 %3, 0
  ret i1 %4
}
