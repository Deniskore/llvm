; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-deletion -enable-new-pm=0 < %s | FileCheck %s

; Make sure this does not crash due to incorrect SCEV invalidation (PR49967).

define void @test() {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[FOR_BODY63:%.*]]
; CHECK:       for.cond.cleanup62:
; CHECK-NEXT:    br i1 true, label [[FOR_BODY151_PREHEADER:%.*]], label [[VECTOR_PH]]
; CHECK:       for.body151.preheader:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP150_LOOPEXIT:%.*]]
; CHECK:       for.body63:
; CHECK-NEXT:    [[I58_010:%.*]] = phi i16 [ 32, [[VECTOR_PH]] ]
; CHECK-NEXT:    store i16 undef, i16* undef, align 1
; CHECK-NEXT:    [[INC89:%.*]] = add nuw nsw i16 [[I58_010]], 1
; CHECK-NEXT:    [[EXITCOND12_NOT:%.*]] = icmp eq i16 [[INC89]], 33
; CHECK-NEXT:    br i1 [[EXITCOND12_NOT]], label [[FOR_COND_CLEANUP62:%.*]], label [[FOR_BODY63_FOR_BODY63_CRIT_EDGE:%.*]]
; CHECK:       for.body63.for.body63_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       for.cond.cleanup150.loopexit:
; CHECK-NEXT:    unreachable
;
entry:
  br label %vector.ph

vector.ph:                                        ; preds = %for.cond.cleanup62, %entry
  br label %for.body63

for.cond.cleanup62:                               ; preds = %for.body63
  br i1 true, label %for.body151.preheader, label %vector.ph

for.body151.preheader:                            ; preds = %for.cond.cleanup62
  br label %for.body151

for.body63:                                       ; preds = %for.body63, %vector.ph
  %i58.010 = phi i16 [ 32, %vector.ph ], [ %inc89, %for.body63 ]
  store i16 undef, i16* undef, align 1
  %inc89 = add nuw nsw i16 %i58.010, 1
  %exitcond12.not = icmp eq i16 %inc89, 33
  br i1 %exitcond12.not, label %for.cond.cleanup62, label %for.body63

for.cond.cleanup150.loopexit:                     ; preds = %for.body151
  unreachable

for.body151:                                      ; preds = %for.body151.preheader, %for.body151
  %i146.29 = phi i16 [ %inc177, %for.body151 ], [ undef, %for.body151.preheader ]
  %inc177 = add nuw nsw i16 %i146.29, 1
  %exitcond.not = icmp eq i16 %inc177, 32
  br i1 %exitcond.not, label %for.cond.cleanup150.loopexit, label %for.body151
}
