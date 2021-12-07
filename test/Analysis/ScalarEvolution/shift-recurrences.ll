; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -analyze -enable-new-pm=0 -scalar-evolution < %s | FileCheck %s
; RUN: opt -disable-output "-passes=print<scalar-evolution>" < %s 2>&1 | FileCheck %s

define void @test_lshr() {
; CHECK-LABEL: 'test_lshr'
; CHECK-NEXT:  Classifying expressions for: @test_lshr
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1023, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [0,1024) S: [0,1024) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 1
; CHECK-NEXT:    --> (%iv.lshr /u 2) U: [0,512) S: [0,512) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.lshr = phi i64 [1023, %entry], [%iv.lshr.next, %loop]
  %iv.lshr.next = lshr i64 %iv.lshr, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}

; Deliberate overflow doesn't change range
define void @test_lshr2() {
; CHECK-LABEL: 'test_lshr2'
; CHECK-NEXT:  Classifying expressions for: @test_lshr2
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1023, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [0,1024) S: [0,1024) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 4
; CHECK-NEXT:    --> (%iv.lshr /u 16) U: [0,64) S: [0,64) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr2
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.lshr = phi i64 [1023, %entry], [%iv.lshr.next, %loop]
  %iv.lshr.next = lshr i64 %iv.lshr, 4
  br i1 undef, label %exit, label %loop
exit:
  ret void
}


define void @test_ashr_zeros() {
; CHECK-LABEL: 'test_ashr_zeros'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_zeros
; CHECK-NEXT:    %iv.ashr = phi i64 [ 1023, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [0,1024) S: [0,1024) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [0,512) S: [0,512) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_zeros
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.ashr = phi i64 [1023, %entry], [%iv.ashr.next, %loop]
  %iv.ashr.next = ashr i64 %iv.ashr, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}

define void @test_ashr_ones() {
; CHECK-LABEL: 'test_ashr_ones'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_ones
; CHECK-NEXT:    %iv.ashr = phi i64 [ -1023, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [-1023,0) S: [-1023,0) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [-512,0) S: [-512,0) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_ones
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.ashr = phi i64 [-1023, %entry], [%iv.ashr.next, %loop]
  %iv.ashr.next = ashr i64 %iv.ashr, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}

; Same as previous, but swapped operands to phi
define void @test_ashr_ones2() {
; CHECK-LABEL: 'test_ashr_ones2'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_ones2
; CHECK-NEXT:    %iv.ashr = phi i64 [ %iv.ashr.next, %loop ], [ -1023, %entry ]
; CHECK-NEXT:    --> %iv.ashr U: [-1023,0) S: [-1023,0) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [-512,0) S: [-512,0) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_ones2
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.ashr = phi i64 [%iv.ashr.next, %loop], [-1023, %entry]
  %iv.ashr.next = ashr i64 %iv.ashr, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}


; negative case for when start is unknown
define void @test_ashr_unknown(i64 %start) {
; CHECK-LABEL: 'test_ashr_unknown'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_unknown
; CHECK-NEXT:    %iv.ashr = phi i64 [ %start, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [-4611686018427387904,4611686018427387904) S: [-4611686018427387904,4611686018427387904) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_unknown
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.ashr = phi i64 [%start, %entry], [%iv.ashr.next, %loop]
  %iv.ashr.next = ashr i64 %iv.ashr, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}

; Negative case where we don't have a (shift) recurrence because the operands
; of the ashr are swapped.  (This does end up being a divide recurrence.)
define void @test_ashr_wrong_op(i64 %start) {
; CHECK-LABEL: 'test_ashr_wrong_op'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_wrong_op
; CHECK-NEXT:    %iv.ashr = phi i64 [ %start, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 1, %iv.ashr
; CHECK-NEXT:    --> %iv.ashr.next U: [-2,2) S: [-2,2) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_wrong_op
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.ashr = phi i64 [%start, %entry], [%iv.ashr.next, %loop]
  %iv.ashr.next = ashr i64 1, %iv.ashr
  br i1 undef, label %exit, label %loop
exit:
  ret void
}


define void @test_shl() {
; CHECK-LABEL: 'test_shl'
; CHECK-NEXT:  Classifying expressions for: @test_shl
; CHECK-NEXT:    %iv.shl = phi i64 [ 8, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [0,-7) S: [-9223372036854775808,9223372036854775793) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, 1
; CHECK-NEXT:    --> (2 * %iv.shl) U: [0,-15) S: [-9223372036854775808,9223372036854775793) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl
; CHECK-NEXT:  Loop %loop: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
entry:
  br label %loop
loop:
  %iv.shl = phi i64 [8, %entry], [%iv.shl.next, %loop]
  %iv.shl.next = shl i64 %iv.shl, 1
  br i1 undef, label %exit, label %loop
exit:
  ret void
}

; use trip count to refine
define void @test_shl2() {
; CHECK-LABEL: 'test_shl2'
; CHECK-NEXT:  Classifying expressions for: @test_shl2
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [4,65) S: [4,65) Exits: 64 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, 1
; CHECK-NEXT:    --> (2 * %iv.shl)<nuw><nsw> U: [8,129) S: [8,129) Exits: 128 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl2
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; Variable shift with a tight upper bound
define void @test_shl3(i1 %c) {
; CHECK-LABEL: 'test_shl3'
; CHECK-NEXT:  Classifying expressions for: @test_shl3
; CHECK-NEXT:    %shiftamt = select i1 %c, i64 1, i64 0
; CHECK-NEXT:    --> %shiftamt U: [0,2) S: [0,2)
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [4,65) S: [4,65) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, %shiftamt
; CHECK-NEXT:    --> %iv.shl.next U: [0,-3) S: [-9223372036854775808,9223372036854775805) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl3
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  %shiftamt = select i1 %c, i64 1, i64 0
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, %shiftamt
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; edge case on max value not overflowing
define void @test_shl4() {
; CHECK-LABEL: 'test_shl4'
; CHECK-NEXT:  Classifying expressions for: @test_shl4
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,61) S: [0,61) Exits: 60 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [4,4611686018427387905) S: [4,4611686018427387905) Exits: 4611686018427387904 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,62) S: [1,62) Exits: 61 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, 1
; CHECK-NEXT:    --> (2 * %iv.shl)<nuw> U: [8,-9223372036854775807) S: [-9223372036854775808,9223372036854775801) Exits: -9223372036854775808 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl4
; CHECK-NEXT:  Loop %loop: backedge-taken count is 60
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 60
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 60
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 61
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, 1
  %cmp = icmp eq i64 %iv, 60
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; other side of edge case from previous test
define void @test_shl5() {
; CHECK-LABEL: 'test_shl5'
; CHECK-NEXT:  Classifying expressions for: @test_shl5
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,62) S: [0,62) Exits: 61 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [0,-3) S: [-9223372036854775808,9223372036854775801) Exits: -9223372036854775808 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,63) S: [1,63) Exits: 62 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, 1
; CHECK-NEXT:    --> (2 * %iv.shl) U: [0,-7) S: [-9223372036854775808,9223372036854775801) Exits: 0 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl5
; CHECK-NEXT:  Loop %loop: backedge-taken count is 61
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 61
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 61
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 62
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, 1
  %cmp = icmp eq i64 %iv, 61
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; Loop varying (but tightly bounded) shift amount
define void @test_shl6(i1 %c) {
; CHECK-LABEL: 'test_shl6'
; CHECK-NEXT:  Classifying expressions for: @test_shl6
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [4,65) S: [4,65) Exits: 16 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %shiftamt = and i64 %iv, 1
; CHECK-NEXT:    --> (zext i1 {false,+,true}<%loop> to i64) U: [0,2) S: [0,2) Exits: 0 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, %shiftamt
; CHECK-NEXT:    --> %iv.shl.next U: [0,-3) S: [-9223372036854775808,9223372036854775805) Exits: 16 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl6
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %shiftamt = and i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, %shiftamt
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; Unanalyzeable shift amount
define void @test_shl7(i1 %c, i64 %shiftamt) {
; CHECK-LABEL: 'test_shl7'
; CHECK-NEXT:  Classifying expressions for: @test_shl7
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl = phi i64 [ 4, %entry ], [ %iv.shl.next, %loop ]
; CHECK-NEXT:    --> %iv.shl U: [0,-3) S: [-9223372036854775808,9223372036854775805) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.shl.next = shl i64 %iv.shl, %shiftamt
; CHECK-NEXT:    --> %iv.shl.next U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_shl7
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.shl = phi i64 [4, %entry], [%iv.shl.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.shl.next = shl i64 %iv.shl, %shiftamt
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; Corner case where phi is not in a loop because it is in unreachable
; code (which loopinfo ignores, but simple recurrence matching does not).
define void @unreachable_phi() {
; CHECK-LABEL: 'unreachable_phi'
; CHECK-NEXT:  Classifying expressions for: @unreachable_phi
; CHECK-NEXT:    %p_58.addr.1 = phi i32 [ undef, %unreachable1 ], [ %sub2629, %unreachable2 ]
; CHECK-NEXT:    --> undef U: full-set S: full-set
; CHECK-NEXT:    %sub2629 = sub i32 %p_58.addr.1, 1
; CHECK-NEXT:    --> undef U: full-set S: full-set
; CHECK-NEXT:  Determining loop execution counts for: @unreachable_phi
;
entry:
  ret void

unreachable1:
  br label %unreachable_nonloop
unreachable2:
  br label %unreachable_nonloop
unreachable_nonloop:
  %p_58.addr.1 = phi i32 [ undef, %unreachable1 ], [ %sub2629, %unreachable2 ]
  %sub2629 = sub i32 %p_58.addr.1, 1
  unreachable
}

; Corner case where phi is not in loop header because binop is in unreachable
; code (which loopinfo ignores, but simple recurrence matching does not).
define void @unreachable_binop() {
; CHECK-LABEL: 'unreachable_binop'
; CHECK-NEXT:  Classifying expressions for: @unreachable_binop
; CHECK-NEXT:    %p_58.addr.1 = phi i32 [ undef, %header ], [ %sub2629, %unreachable ]
; CHECK-NEXT:    --> %p_58.addr.1 U: full-set S: full-set Exits: <<Unknown>> LoopDispositions: { %header: Variant }
; CHECK-NEXT:    %sub2629 = sub i32 %p_58.addr.1, 1
; CHECK-NEXT:    --> undef U: full-set S: full-set
; CHECK-NEXT:  Determining loop execution counts for: @unreachable_binop
; CHECK-NEXT:  Loop %header: Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %header: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %header: Unpredictable predicated backedge-taken count.
;
entry:
  br label %header

header:
  br label %for.cond2295

for.cond2295:
  %p_58.addr.1 = phi i32 [ undef, %header ], [ %sub2629, %unreachable ]
  br i1 undef, label %if.then2321, label %header

if.then2321:
  ret void

unreachable:
  %sub2629 = sub i32 %p_58.addr.1, 1
  br label %for.cond2295
}

; Was pr49856.  We can match the recurrence without a loop
; since dominance collapses in unreachable code.  Conceptually,
; this is a recurrence which only executes one iteration.
define void @nonloop_recurrence() {
; CHECK-LABEL: 'nonloop_recurrence'
; CHECK-NEXT:  Classifying expressions for: @nonloop_recurrence
; CHECK-NEXT:    %tmp = phi i32 [ 2, %bb ], [ %tmp2, %bb3 ]
; CHECK-NEXT:    --> %tmp U: [1,-2147483648) S: [0,-2147483648)
; CHECK-NEXT:    %tmp2 = add nuw nsw i32 %tmp, 1
; CHECK-NEXT:    --> (1 + %tmp)<nuw> U: [1,-2147483647) S: [1,-2147483647)
; CHECK-NEXT:  Determining loop execution counts for: @nonloop_recurrence
;
bb:
  br label %bb1

bb1:                                              ; preds = %bb3, %bb
  %tmp = phi i32 [ 2, %bb ], [ %tmp2, %bb3 ]
  %tmp2 = add nuw nsw i32 %tmp, 1
  ret void

bb3:                                              ; No predecessors!
  br label %bb1
}

; Tweak of pr49856 test case - analogous, but there is a loop
; it's trip count simply doesn't relate to the single iteration
; "recurrence" we found.
define void @nonloop_recurrence_2() {
; CHECK-LABEL: 'nonloop_recurrence_2'
; CHECK-NEXT:  Classifying expressions for: @nonloop_recurrence_2
; CHECK-NEXT:    %tmp = phi i32 [ 2, %loop ], [ %tmp2, %bb3 ]
; CHECK-NEXT:    --> %tmp U: [1,-2147483648) S: [0,-2147483648) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %tmp2 = add nuw nsw i32 %tmp, 1
; CHECK-NEXT:    --> (1 + %tmp)<nuw> U: [1,-2147483647) S: [1,-2147483647) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @nonloop_recurrence_2
; CHECK-NEXT:  Loop %loop: <multiple exits> Unpredictable backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable max backedge-taken count.
; CHECK-NEXT:  Loop %loop: Unpredictable predicated backedge-taken count.
;
bb:
  br label %loop

loop:
  br label %bb1
bb1:                                              ; preds = %bb3, %loop
  %tmp = phi i32 [ 2, %loop ], [ %tmp2, %bb3 ]
  %tmp2 = add nuw nsw i32 %tmp, 1
  br label %loop

bb3:                                              ; No predecessors!
  br label %bb1
}


; Next batch of tests show where we can get tighter ranges on ashr/lshr
; by using the trip count information on the loop.

define void @test_ashr_tc_positive() {
; CHECK-LABEL: 'test_ashr_tc_positive'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_tc_positive
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr = phi i64 [ 1023, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [63,1024) S: [63,1024) Exits: 63 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [0,512) S: [0,512) Exits: 31 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_tc_positive
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.ashr = phi i64 [1023, %entry], [%iv.ashr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.ashr.next = ashr i64 %iv.ashr, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_ashr_tc_negative() {
; CHECK-LABEL: 'test_ashr_tc_negative'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_tc_negative
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr = phi i8 [ -128, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [-128,-7) S: [-128,-7) Exits: -8 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr.next = ashr i8 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [-64,0) S: [-64,0) Exits: -4 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_tc_negative
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.ashr = phi i8 [128, %entry], [%iv.ashr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.ashr.next = ashr i8 %iv.ashr, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_ashr_tc_either(i1 %a) {
; CHECK-LABEL: 'test_ashr_tc_either'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_tc_either
; CHECK-NEXT:    %start = sext i1 %a to i8
; CHECK-NEXT:    --> (sext i1 %a to i8) U: [-1,1) S: [-1,1)
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,61) S: [0,61) Exits: 60 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr = phi i8 [ %start, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [-16,16) S: [-16,16) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,62) S: [1,62) Exits: 61 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr.next = ashr i8 %iv.ashr, 1
; CHECK-NEXT:    --> %iv.ashr.next U: [-16,16) S: [-16,16) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_tc_either
; CHECK-NEXT:  Loop %loop: backedge-taken count is 60
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 60
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 60
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 61
;
entry:
  %start = sext i1 %a to i8
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.ashr = phi i8 [%start, %entry], [%iv.ashr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.ashr.next = ashr i8 %iv.ashr, 1
  %cmp = icmp eq i64 %iv, 60
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_ashr_zero_shift() {
; CHECK-LABEL: 'test_ashr_zero_shift'
; CHECK-NEXT:  Classifying expressions for: @test_ashr_zero_shift
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr = phi i64 [ 1023, %entry ], [ %iv.ashr.next, %loop ]
; CHECK-NEXT:    --> %iv.ashr U: [1023,1024) S: [1023,1024) Exits: 1023 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.ashr.next = ashr i64 %iv.ashr, 0
; CHECK-NEXT:    --> %iv.ashr U: [1023,1024) S: [1023,1024) Exits: 1023 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_ashr_zero_shift
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.ashr = phi i64 [1023, %entry], [%iv.ashr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.ashr.next = ashr i64 %iv.ashr, 0
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_lshr_tc_positive() {
; CHECK-LABEL: 'test_lshr_tc_positive'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_tc_positive
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1023, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [63,1024) S: [63,1024) Exits: 63 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 1
; CHECK-NEXT:    --> (%iv.lshr /u 2) U: [31,512) S: [31,512) Exits: 31 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_tc_positive
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i64 [1023, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i64 %iv.lshr, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_lshr_tc_negative() {
; CHECK-LABEL: 'test_lshr_tc_negative'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_tc_negative
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i8 [ -1, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [15,0) S: [-1,-128) Exits: 15 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i8 %iv.lshr, 1
; CHECK-NEXT:    --> (%iv.lshr /u 2) U: [7,-128) S: [7,-128) Exits: 7 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_tc_negative
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i8 [-1, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i8 %iv.lshr, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_lshr_tc_either(i1 %a) {
; CHECK-LABEL: 'test_lshr_tc_either'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_tc_either
; CHECK-NEXT:    %start = sext i1 %a to i8
; CHECK-NEXT:    --> (sext i1 %a to i8) U: [-1,1) S: [-1,1)
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i8 [ %start, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [-1,-128) S: [-1,-128) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i8 %iv.lshr, 1
; CHECK-NEXT:    --> (%iv.lshr /u 2) U: [0,-128) S: [0,-128) Exits: <<Unknown>> LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_tc_either
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  %start = sext i1 %a to i8
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i8 [%start, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i8 %iv.lshr, 1
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_lshr_zero_shift() {
; CHECK-LABEL: 'test_lshr_zero_shift'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_zero_shift
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1023, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [1023,1024) S: [1023,1024) Exits: 1023 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 0
; CHECK-NEXT:    --> %iv.lshr U: [1023,1024) S: [1023,1024) Exits: 1023 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_zero_shift
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i64 [1023, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i64 %iv.lshr, 0
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}


define void @test_lshr_power_of_2_start() {
; CHECK-LABEL: 'test_lshr_power_of_2_start'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_power_of_2_start
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1024, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [4,1025) S: [4,1025) Exits: 4 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 2
; CHECK-NEXT:    --> (%iv.lshr /u 4) U: [1,257) S: [1,257) Exits: 1 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_power_of_2_start
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i64 [1024, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i64 %iv.lshr, 2
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

; Starting value is chosen not to be near power of 2
define void @test_lshr_arbitrary_start() {
; CHECK-LABEL: 'test_lshr_arbitrary_start'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_arbitrary_start
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i64 [ 957, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [3,958) S: [3,958) Exits: 3 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 2
; CHECK-NEXT:    --> (%iv.lshr /u 4) U: [0,240) S: [0,240) Exits: 0 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_arbitrary_start
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i64 [957, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i64 %iv.lshr, 2
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}

define void @test_lshr_start_power_of_2_plus_one() {
; CHECK-LABEL: 'test_lshr_start_power_of_2_plus_one'
; CHECK-NEXT:  Classifying expressions for: @test_lshr_start_power_of_2_plus_one
; CHECK-NEXT:    %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-NEXT:    --> {0,+,1}<%loop> U: [0,5) S: [0,5) Exits: 4 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr = phi i64 [ 1025, %entry ], [ %iv.lshr.next, %loop ]
; CHECK-NEXT:    --> %iv.lshr U: [4,1026) S: [4,1026) Exits: 4 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:    %iv.next = add i64 %iv, 1
; CHECK-NEXT:    --> {1,+,1}<%loop> U: [1,6) S: [1,6) Exits: 5 LoopDispositions: { %loop: Computable }
; CHECK-NEXT:    %iv.lshr.next = lshr i64 %iv.lshr, 2
; CHECK-NEXT:    --> (%iv.lshr /u 4) U: [1,257) S: [1,257) Exits: 1 LoopDispositions: { %loop: Variant }
; CHECK-NEXT:  Determining loop execution counts for: @test_lshr_start_power_of_2_plus_one
; CHECK-NEXT:  Loop %loop: backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: max backedge-taken count is 4
; CHECK-NEXT:  Loop %loop: Predicated backedge-taken count is 4
; CHECK-NEXT:   Predicates:
; CHECK:       Loop %loop: Trip multiple is 5
;
entry:
  br label %loop
loop:
  %iv = phi i64 [0, %entry], [%iv.next, %loop]
  %iv.lshr = phi i64 [1025, %entry], [%iv.lshr.next, %loop]
  %iv.next = add i64 %iv, 1
  %iv.lshr.next = lshr i64 %iv.lshr, 2
  %cmp = icmp eq i64 %iv, 4
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}
