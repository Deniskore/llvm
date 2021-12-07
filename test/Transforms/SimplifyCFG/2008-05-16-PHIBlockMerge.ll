; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s

; ModuleID = '<stdin>'
declare i1 @foo()

declare i1 @bar(i32)

; This function can't be merged
define void @a() {
; CHECK-LABEL: @a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_NOMERGE:%.*]]
; CHECK:       BB.nomerge:
; CHECK-NEXT:    [[A:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ 0, [[COMMON:%.*]] ]
; CHECK-NEXT:    br label [[SUCC:%.*]]
; CHECK:       Succ:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ [[A]], [[BB_NOMERGE]] ], [ 2, [[COMMON]] ]
; CHECK-NEXT:    [[CONDE:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[CONDE]], label [[COMMON]], label [[EXIT:%.*]]
; CHECK:       Common:
; CHECK-NEXT:    [[COND:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[COND]], label [[BB_NOMERGE]], label [[SUCC]]
; CHECK:       Exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %BB.nomerge

BB.nomerge:		; preds = %Common, %entry
  ; This phi has a conflicting value (0) with below phi (2), so blocks
  ; can't be merged.
  %a = phi i32 [ 1, %entry ], [ 0, %Common ]		; <i32> [#uses=1]
  br label %Succ

Succ:		; preds = %Common, %BB.nomerge
  %b = phi i32 [ %a, %BB.nomerge ], [ 2, %Common ]		; <i32> [#uses=0]
  %conde = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %conde, label %Common, label %Exit

Common:		; preds = %Succ
  %cond = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %cond, label %BB.nomerge, label %Succ

Exit:		; preds = %Succ
  ret void
}

; This function can't be merged
define void @b() {
; CHECK-LABEL: @b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_NOMERGE:%.*]]
; CHECK:       BB.nomerge:
; CHECK-NEXT:    br label [[SUCC:%.*]]
; CHECK:       Succ:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ 1, [[BB_NOMERGE]] ], [ 2, [[COMMON:%.*]] ]
; CHECK-NEXT:    [[CONDE:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[CONDE]], label [[COMMON]], label [[EXIT:%.*]]
; CHECK:       Common:
; CHECK-NEXT:    [[COND:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[COND]], label [[BB_NOMERGE]], label [[SUCC]]
; CHECK:       Exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %BB.nomerge

BB.nomerge:		; preds = %Common, %entry
  br label %Succ

Succ:		; preds = %Common, %BB.nomerge
  ; This phi has confliction values for Common and (through BB) Common,
  ; blocks can't be merged
  %b = phi i32 [ 1, %BB.nomerge ], [ 2, %Common ]		; <i32> [#uses=0]
  %conde = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %conde, label %Common, label %Exit

Common:		; preds = %Succ
  %cond = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %cond, label %BB.nomerge, label %Succ

Exit:		; preds = %Succ
  ret void
}

; This function can't be merged (for keeping canonical loop structures)
define void @c() {
; CHECK-LABEL: @c(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_NOMERGE:%.*]]
; CHECK:       BB.nomerge:
; CHECK-NEXT:    br label [[SUCC:%.*]]
; CHECK:       Succ:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ 1, [[BB_NOMERGE]] ], [ 1, [[COMMON:%.*]] ], [ 2, [[PRE_EXIT:%.*]] ]
; CHECK-NEXT:    [[CONDE:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[CONDE]], label [[COMMON]], label [[PRE_EXIT]]
; CHECK:       Common:
; CHECK-NEXT:    [[COND:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[COND]], label [[BB_NOMERGE]], label [[SUCC]]
; CHECK:       Pre-Exit:
; CHECK-NEXT:    [[COND2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[COND2]], label [[SUCC]], label [[EXIT:%.*]]
; CHECK:       Exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %BB.nomerge

BB.nomerge:		; preds = %Common, %entry
  br label %Succ

Succ:		; preds = %Common, %BB.tomerge, %Pre-Exit
  ; This phi has identical values for Common and (through BB) Common,
  ; blocks can't be merged
  %b = phi i32 [ 1, %BB.nomerge ], [ 1, %Common ], [ 2, %Pre-Exit ]
  %conde = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %conde, label %Common, label %Pre-Exit

Common:		; preds = %Succ
  %cond = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %cond, label %BB.nomerge, label %Succ

Pre-Exit:       ; preds = %Succ
  ; This adds a backedge, so the %b phi node gets a third branch and is
  ; not completely trivial
  %cond2 = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %cond2, label %Succ, label %Exit

Exit:		; preds = %Pre-Exit
  ret void
}

; This function can't be merged (for keeping canonical loop structures)
define void @d() {
; CHECK-LABEL: @d(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_NOMERGE:%.*]]
; CHECK:       BB.nomerge:
; CHECK-NEXT:    [[A:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ 0, [[COMMON:%.*]] ]
; CHECK-NEXT:    br label [[SUCC:%.*]]
; CHECK:       Succ:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ [[A]], [[BB_NOMERGE]] ], [ 0, [[COMMON]] ]
; CHECK-NEXT:    [[CONDE:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[CONDE]], label [[COMMON]], label [[EXIT:%.*]]
; CHECK:       Common:
; CHECK-NEXT:    [[COND:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[COND]], label [[BB_NOMERGE]], label [[SUCC]]
; CHECK:       Exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %BB.nomerge

BB.nomerge:		; preds = %Common, %entry
  ; This phi has a matching value (0) with below phi (0), so blocks
  ; can be merged.
  %a = phi i32 [ 1, %entry ], [ 0, %Common ]		; <i32> [#uses=1]
  br label %Succ

Succ:		; preds = %Common, %BB.tomerge
  %b = phi i32 [ %a, %BB.nomerge ], [ 0, %Common ]		; <i32> [#uses=0]
  %conde = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %conde, label %Common, label %Exit

Common:		; preds = %Succ
  %cond = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %cond, label %BB.nomerge, label %Succ

Exit:		; preds = %Succ
  ret void
}

; This function can be merged
define void @e() {
; CHECK-LABEL: @e(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[SUCC:%.*]]
; CHECK:       Succ:
; CHECK-NEXT:    [[A:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ 0, [[USE:%.*]] ]
; CHECK-NEXT:    [[CONDE:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[CONDE]], label [[USE]], label [[EXIT:%.*]]
; CHECK:       Use:
; CHECK-NEXT:    [[COND:%.*]] = call i1 @bar(i32 [[A]])
; CHECK-NEXT:    br i1 [[COND]], label [[SUCC]], label [[EXIT]]
; CHECK:       Exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %Succ

Succ:		; preds = %Use, %entry
  ; This phi is used somewhere else than Succ, but this should not prevent
  ; merging this block
  %a = phi i32 [ 1, %entry ], [ 0, %Use ]		; <i32> [#uses=1]
  br label %BB.tomerge

BB.tomerge:		; preds = %BB.tomerge
  %conde = call i1 @foo( )		; <i1> [#uses=1]
  br i1 %conde, label %Use, label %Exit

Use:		; preds = %Succ
  %cond = call i1 @bar( i32 %a )		; <i1> [#uses=1]
  br i1 %cond, label %Succ, label %Exit

Exit:		; preds = %Use, %Succ
  ret void
}
