; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu | FileCheck %s

define i32 @a() nounwind {
; CHECK-LABEL: a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    subl $8, %esp
; CHECK-NEXT:    leal {{[0-9]+}}(%esp), %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    subl $a, %eax
; CHECK-NEXT:    calll d@PLT
; CHECK-NEXT:    cmpl $a, %esi
; CHECK-NEXT:    jbe .LBB0_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB0_1: # %for.cond
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    jmp .LBB0_1
; CHECK-NEXT:  .LBB0_2: # %for.end.split
; CHECK-NEXT:    addl $8, %esp
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    retl
entry:
  %b = alloca i32, align 4
  %0 = bitcast i32* %b to i8*
  %1 = ptrtoint i32* %b to i32
  %sub = sub nsw i32 %1, ptrtoint (i32 ()* @a to i32)
  %call = call i32 bitcast (i32 (...)* @d to i32 (i32)*)(i32 inreg %sub)
  %cmp = icmp ugt i32* %b, bitcast (i32 ()* @a to i32*)
  br i1 %cmp, label %for.cond, label %for.end.split

for.cond:                                         ; preds = %entry, %for.cond
  br label %for.cond

for.end.split:                                    ; preds = %entry
  ret i32 undef
}

declare i32 @d(...)
