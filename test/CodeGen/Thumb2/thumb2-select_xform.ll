; RUN: llc < %s -march=thumb -mattr=+thumb2 | grep mov | count 3
; RUN: llc < %s -march=thumb -mattr=+thumb2 | grep mvn | count 1
; RUN: llc < %s -march=thumb -mattr=+thumb2 | grep it  | count 3

define i32 @t1(i32 %a, i32 %b, i32 %c) nounwind {
        %tmp1 = icmp sgt i32 %c, 10
        %tmp2 = select i1 %tmp1, i32 0, i32 2147483647
        %tmp3 = add i32 %tmp2, %b
        ret i32 %tmp3
}

define i32 @t2(i32 %a, i32 %b, i32 %c) nounwind {
        %tmp1 = icmp sgt i32 %c, 10
        %tmp2 = select i1 %tmp1, i32 0, i32 2147483648
        %tmp3 = add i32 %tmp2, %b
        ret i32 %tmp3
}

define i32 @t3(i32 %a, i32 %b, i32 %c, i32 %d) nounwind {
        %tmp1 = icmp sgt i32 %c, 10
        %tmp2 = select i1 %tmp1, i32 0, i32 10
        %tmp3 = sub i32 %b, %tmp2
        ret i32 %tmp3
}
