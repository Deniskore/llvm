; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr8 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -ppc-asm-full-reg-names -verify-machineinstrs -O2 < %s | FileCheck %s
; RUN: llc -mcpu=pwr8 -mtriple=powerpc64-unknown-unknown \
; RUN:   -ppc-asm-full-reg-names -verify-machineinstrs -O2 < %s | FileCheck %s \
; RUN:   --check-prefix=CHECK-BE
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -ppc-asm-full-reg-names -verify-machineinstrs -O2 < %s | FileCheck %s \
; RUN:   --check-prefix=CHECK-P9
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64-unknown-unknown \
; RUN:   -ppc-asm-full-reg-names -verify-machineinstrs -O2 < %s | FileCheck %s \
; RUN:   --check-prefix=CHECK-P9-BE
define dso_local i32 @poc(i32* %base, i32 %index, i1 %flag, i32 %default) {
; CHECK-LABEL: poc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r5, r5, 1
; CHECK-NEXT:    bc 4, gt, .LBB0_2
; CHECK-NEXT:  # %bb.1: # %true
; CHECK-NEXT:    extsw r4, r4
; CHECK-NEXT:    sldi r4, r4, 2
; CHECK-NEXT:    lwzx r3, r3, r4
; CHECK-NEXT:    blr
; CHECK-NEXT:  .LBB0_2: # %false
; CHECK-NEXT:    mr r3, r6
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: poc:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    andi. r5, r5, 1
; CHECK-BE-NEXT:    bc 4, gt, .LBB0_2
; CHECK-BE-NEXT:  # %bb.1: # %true
; CHECK-BE-NEXT:    extsw r4, r4
; CHECK-BE-NEXT:    sldi r4, r4, 2
; CHECK-BE-NEXT:    lwzx r3, r3, r4
; CHECK-BE-NEXT:    blr
; CHECK-BE-NEXT:  .LBB0_2: # %false
; CHECK-BE-NEXT:    mr r3, r6
; CHECK-BE-NEXT:    blr
;
; CHECK-P9-LABEL: poc:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    andi. r5, r5, 1
; CHECK-P9-NEXT:    bc 4, gt, .LBB0_2
; CHECK-P9-NEXT:  # %bb.1: # %true
; CHECK-P9-NEXT:    extswsli r4, r4, 2
; CHECK-P9-NEXT:    lwzx r3, r3, r4
; CHECK-P9-NEXT:    blr
; CHECK-P9-NEXT:  .LBB0_2: # %false
; CHECK-P9-NEXT:    mr r3, r6
; CHECK-P9-NEXT:    blr
;
; CHECK-P9-BE-LABEL: poc:
; CHECK-P9-BE:       # %bb.0: # %entry
; CHECK-P9-BE-NEXT:    andi. r5, r5, 1
; CHECK-P9-BE-NEXT:    bc 4, gt, .LBB0_2
; CHECK-P9-BE-NEXT:  # %bb.1: # %true
; CHECK-P9-BE-NEXT:    extswsli r4, r4, 2
; CHECK-P9-BE-NEXT:    lwzx r3, r3, r4
; CHECK-P9-BE-NEXT:    blr
; CHECK-P9-BE-NEXT:  .LBB0_2: # %false
; CHECK-P9-BE-NEXT:    mr r3, r6
; CHECK-P9-BE-NEXT:    blr
entry:
  %iconv = sext i32 %index to i64
  br i1 %flag, label %true, label %false

true:
  %ptr = getelementptr inbounds i32, i32* %base, i64 %iconv
  %value = load i32, i32* %ptr, align 4
  ret i32 %value

false:
  ret i32 %default
}

define dso_local i64 @poc_i64(i64* %base, i32 %index, i1 %flag, i64 %default) {
; CHECK-LABEL: poc_i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r5, r5, 1
; CHECK-NEXT:    bc 4, gt, .LBB1_2
; CHECK-NEXT:  # %bb.1: # %true
; CHECK-NEXT:    extsw r4, r4
; CHECK-NEXT:    sldi r4, r4, 3
; CHECK-NEXT:    ldx r3, r3, r4
; CHECK-NEXT:    blr
; CHECK-NEXT:  .LBB1_2: # %false
; CHECK-NEXT:    mr r3, r6
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: poc_i64:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    andi. r5, r5, 1
; CHECK-BE-NEXT:    bc 4, gt, .LBB1_2
; CHECK-BE-NEXT:  # %bb.1: # %true
; CHECK-BE-NEXT:    extsw r4, r4
; CHECK-BE-NEXT:    sldi r4, r4, 3
; CHECK-BE-NEXT:    ldx r3, r3, r4
; CHECK-BE-NEXT:    blr
; CHECK-BE-NEXT:  .LBB1_2: # %false
; CHECK-BE-NEXT:    mr r3, r6
; CHECK-BE-NEXT:    blr
;
; CHECK-P9-LABEL: poc_i64:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    andi. r5, r5, 1
; CHECK-P9-NEXT:    bc 4, gt, .LBB1_2
; CHECK-P9-NEXT:  # %bb.1: # %true
; CHECK-P9-NEXT:    extswsli r4, r4, 3
; CHECK-P9-NEXT:    ldx r3, r3, r4
; CHECK-P9-NEXT:    blr
; CHECK-P9-NEXT:  .LBB1_2: # %false
; CHECK-P9-NEXT:    mr r3, r6
; CHECK-P9-NEXT:    blr
;
; CHECK-P9-BE-LABEL: poc_i64:
; CHECK-P9-BE:       # %bb.0: # %entry
; CHECK-P9-BE-NEXT:    andi. r5, r5, 1
; CHECK-P9-BE-NEXT:    bc 4, gt, .LBB1_2
; CHECK-P9-BE-NEXT:  # %bb.1: # %true
; CHECK-P9-BE-NEXT:    extswsli r4, r4, 3
; CHECK-P9-BE-NEXT:    ldx r3, r3, r4
; CHECK-P9-BE-NEXT:    blr
; CHECK-P9-BE-NEXT:  .LBB1_2: # %false
; CHECK-P9-BE-NEXT:    mr r3, r6
; CHECK-P9-BE-NEXT:    blr
entry:
  %iconv = sext i32 %index to i64
  br i1 %flag, label %true, label %false

true:
  %ptr = getelementptr inbounds i64, i64* %base, i64 %iconv
  %value = load i64, i64* %ptr, align 8
  ret i64 %value

false:
  ret i64 %default
}

define dso_local i64 @no_extswsli(i64* %base, i32 %index, i1 %flag) {
; CHECK-LABEL: no_extswsli:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r5, r5, 1
; CHECK-NEXT:    extsw r4, r4
; CHECK-NEXT:    bc 4, gt, .LBB2_2
; CHECK-NEXT:  # %bb.1: # %true
; CHECK-NEXT:    sldi r4, r4, 3
; CHECK-NEXT:    ldx r3, r3, r4
; CHECK-NEXT:    blr
; CHECK-NEXT:  .LBB2_2: # %false
; CHECK-NEXT:    mr r3, r4
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: no_extswsli:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    andi. r5, r5, 1
; CHECK-BE-NEXT:    extsw r4, r4
; CHECK-BE-NEXT:    bc 4, gt, .LBB2_2
; CHECK-BE-NEXT:  # %bb.1: # %true
; CHECK-BE-NEXT:    sldi r4, r4, 3
; CHECK-BE-NEXT:    ldx r3, r3, r4
; CHECK-BE-NEXT:    blr
; CHECK-BE-NEXT:  .LBB2_2: # %false
; CHECK-BE-NEXT:    mr r3, r4
; CHECK-BE-NEXT:    blr
;
; CHECK-P9-LABEL: no_extswsli:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    extsw r4, r4
; CHECK-P9-NEXT:    andi. r5, r5, 1
; CHECK-P9-NEXT:    bc 4, gt, .LBB2_2
; CHECK-P9-NEXT:  # %bb.1: # %true
; CHECK-P9-NEXT:    sldi r4, r4, 3
; CHECK-P9-NEXT:    ldx r3, r3, r4
; CHECK-P9-NEXT:    blr
; CHECK-P9-NEXT:  .LBB2_2: # %false
; CHECK-P9-NEXT:    mr r3, r4
; CHECK-P9-NEXT:    blr
;
; CHECK-P9-BE-LABEL: no_extswsli:
; CHECK-P9-BE:       # %bb.0: # %entry
; CHECK-P9-BE-NEXT:    extsw r4, r4
; CHECK-P9-BE-NEXT:    andi. r5, r5, 1
; CHECK-P9-BE-NEXT:    bc 4, gt, .LBB2_2
; CHECK-P9-BE-NEXT:  # %bb.1: # %true
; CHECK-P9-BE-NEXT:    sldi r4, r4, 3
; CHECK-P9-BE-NEXT:    ldx r3, r3, r4
; CHECK-P9-BE-NEXT:    blr
; CHECK-P9-BE-NEXT:  .LBB2_2: # %false
; CHECK-P9-BE-NEXT:    mr r3, r4
; CHECK-P9-BE-NEXT:    blr
entry:
  %iconv = sext i32 %index to i64
  br i1 %flag, label %true, label %false

true:
  %ptr = getelementptr inbounds i64, i64* %base, i64 %iconv
  %value = load i64, i64* %ptr, align 8
  ret i64 %value

false:
  ret i64 %iconv
}
