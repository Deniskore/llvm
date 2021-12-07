; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -O0 -stop-after=irtranslator -global-isel -verify-machineinstrs %s -o - 2>&1 | FileCheck %s --check-prefix=O0
; RUN: llc -O3 -stop-after=irtranslator -global-isel -verify-machineinstrs %s -o - 2>&1 | FileCheck %s --check-prefix=O3
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "aarch64--"

define i32 @cse_gep([4 x i32]* %ptr, i32 %idx) {
  ; O0-LABEL: name: cse_gep
  ; O0: bb.1 (%ir-block.0):
  ; O0:   liveins: $w1, $x0
  ; O0:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; O0:   [[COPY1:%[0-9]+]]:_(s32) = COPY $w1
  ; O0:   [[SEXT:%[0-9]+]]:_(s64) = G_SEXT [[COPY1]](s32)
  ; O0:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 16
  ; O0:   [[MUL:%[0-9]+]]:_(s64) = G_MUL [[SEXT]], [[C]]
  ; O0:   [[PTR_ADD:%[0-9]+]]:_(p0) = G_PTR_ADD [[COPY]], [[MUL]](s64)
  ; O0:   [[COPY2:%[0-9]+]]:_(p0) = COPY [[PTR_ADD]](p0)
  ; O0:   [[LOAD:%[0-9]+]]:_(s32) = G_LOAD [[COPY2]](p0) :: (load (s32) from %ir.gep1)
  ; O0:   [[MUL1:%[0-9]+]]:_(s64) = G_MUL [[SEXT]], [[C]]
  ; O0:   [[PTR_ADD1:%[0-9]+]]:_(p0) = G_PTR_ADD [[COPY]], [[MUL1]](s64)
  ; O0:   [[C1:%[0-9]+]]:_(s64) = G_CONSTANT i64 4
  ; O0:   [[PTR_ADD2:%[0-9]+]]:_(p0) = G_PTR_ADD [[PTR_ADD1]], [[C1]](s64)
  ; O0:   [[LOAD1:%[0-9]+]]:_(s32) = G_LOAD [[PTR_ADD2]](p0) :: (load (s32) from %ir.gep2)
  ; O0:   [[ADD:%[0-9]+]]:_(s32) = G_ADD [[LOAD1]], [[LOAD1]]
  ; O0:   $w0 = COPY [[ADD]](s32)
  ; O0:   RET_ReallyLR implicit $w0
  ; O3-LABEL: name: cse_gep
  ; O3: bb.1 (%ir-block.0):
  ; O3:   liveins: $w1, $x0
  ; O3:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; O3:   [[COPY1:%[0-9]+]]:_(s32) = COPY $w1
  ; O3:   [[SEXT:%[0-9]+]]:_(s64) = G_SEXT [[COPY1]](s32)
  ; O3:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 16
  ; O3:   [[MUL:%[0-9]+]]:_(s64) = G_MUL [[SEXT]], [[C]]
  ; O3:   [[PTR_ADD:%[0-9]+]]:_(p0) = G_PTR_ADD [[COPY]], [[MUL]](s64)
  ; O3:   [[COPY2:%[0-9]+]]:_(p0) = COPY [[PTR_ADD]](p0)
  ; O3:   [[LOAD:%[0-9]+]]:_(s32) = G_LOAD [[COPY2]](p0) :: (load (s32) from %ir.gep1)
  ; O3:   [[C1:%[0-9]+]]:_(s64) = G_CONSTANT i64 4
  ; O3:   [[PTR_ADD1:%[0-9]+]]:_(p0) = G_PTR_ADD [[PTR_ADD]], [[C1]](s64)
  ; O3:   [[LOAD1:%[0-9]+]]:_(s32) = G_LOAD [[PTR_ADD1]](p0) :: (load (s32) from %ir.gep2)
  ; O3:   [[ADD:%[0-9]+]]:_(s32) = G_ADD [[LOAD1]], [[LOAD1]]
  ; O3:   $w0 = COPY [[ADD]](s32)
  ; O3:   RET_ReallyLR implicit $w0
  %sidx = sext i32 %idx to i64
  %gep1 = getelementptr inbounds [4 x i32], [4 x i32]* %ptr, i64 %sidx, i64 0
  %v1 = load i32, i32* %gep1
  %gep2 = getelementptr inbounds [4 x i32], [4 x i32]* %ptr, i64 %sidx, i64 1
  %v2 = load i32, i32* %gep2
  %res = add i32 %v2, %v2
  ret i32 %res
}
