; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+d,+experimental-zfh,+experimental-v -target-abi=ilp32d \
; RUN:     -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+d,+experimental-zfh,+experimental-v -target-abi=lp64d \
; RUN:     -verify-machineinstrs < %s | FileCheck %s

declare <vscale x 1 x half> @llvm.sqrt.nxv1f16(<vscale x 1 x half>)

define <vscale x 1 x half> @vfsqrt_nxv1f16(<vscale x 1 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv1f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, mf4, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 1 x half> @llvm.sqrt.nxv1f16(<vscale x 1 x half> %v)
  ret <vscale x 1 x half> %r
}

declare <vscale x 2 x half> @llvm.sqrt.nxv2f16(<vscale x 2 x half>)

define <vscale x 2 x half> @vfsqrt_nxv2f16(<vscale x 2 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv2f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, mf2, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x half> @llvm.sqrt.nxv2f16(<vscale x 2 x half> %v)
  ret <vscale x 2 x half> %r
}

declare <vscale x 4 x half> @llvm.sqrt.nxv4f16(<vscale x 4 x half>)

define <vscale x 4 x half> @vfsqrt_nxv4f16(<vscale x 4 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv4f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, m1, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 4 x half> @llvm.sqrt.nxv4f16(<vscale x 4 x half> %v)
  ret <vscale x 4 x half> %r
}

declare <vscale x 8 x half> @llvm.sqrt.nxv8f16(<vscale x 8 x half>)

define <vscale x 8 x half> @vfsqrt_nxv8f16(<vscale x 8 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv8f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, m2, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 8 x half> @llvm.sqrt.nxv8f16(<vscale x 8 x half> %v)
  ret <vscale x 8 x half> %r
}

declare <vscale x 16 x half> @llvm.sqrt.nxv16f16(<vscale x 16 x half>)

define <vscale x 16 x half> @vfsqrt_nxv16f16(<vscale x 16 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv16f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, m4, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 16 x half> @llvm.sqrt.nxv16f16(<vscale x 16 x half> %v)
  ret <vscale x 16 x half> %r
}

declare <vscale x 32 x half> @llvm.sqrt.nxv32f16(<vscale x 32 x half>)

define <vscale x 32 x half> @vfsqrt_nxv32f16(<vscale x 32 x half> %v) {
; CHECK-LABEL: vfsqrt_nxv32f16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e16, m8, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 32 x half> @llvm.sqrt.nxv32f16(<vscale x 32 x half> %v)
  ret <vscale x 32 x half> %r
}

declare <vscale x 1 x float> @llvm.sqrt.nxv1f32(<vscale x 1 x float>)

define <vscale x 1 x float> @vfsqrt_nxv1f32(<vscale x 1 x float> %v) {
; CHECK-LABEL: vfsqrt_nxv1f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e32, mf2, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 1 x float> @llvm.sqrt.nxv1f32(<vscale x 1 x float> %v)
  ret <vscale x 1 x float> %r
}

declare <vscale x 2 x float> @llvm.sqrt.nxv2f32(<vscale x 2 x float>)

define <vscale x 2 x float> @vfsqrt_nxv2f32(<vscale x 2 x float> %v) {
; CHECK-LABEL: vfsqrt_nxv2f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e32, m1, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x float> @llvm.sqrt.nxv2f32(<vscale x 2 x float> %v)
  ret <vscale x 2 x float> %r
}

declare <vscale x 4 x float> @llvm.sqrt.nxv4f32(<vscale x 4 x float>)

define <vscale x 4 x float> @vfsqrt_nxv4f32(<vscale x 4 x float> %v) {
; CHECK-LABEL: vfsqrt_nxv4f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e32, m2, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 4 x float> @llvm.sqrt.nxv4f32(<vscale x 4 x float> %v)
  ret <vscale x 4 x float> %r
}

declare <vscale x 8 x float> @llvm.sqrt.nxv8f32(<vscale x 8 x float>)

define <vscale x 8 x float> @vfsqrt_nxv8f32(<vscale x 8 x float> %v) {
; CHECK-LABEL: vfsqrt_nxv8f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e32, m4, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 8 x float> @llvm.sqrt.nxv8f32(<vscale x 8 x float> %v)
  ret <vscale x 8 x float> %r
}

declare <vscale x 16 x float> @llvm.sqrt.nxv16f32(<vscale x 16 x float>)

define <vscale x 16 x float> @vfsqrt_nxv16f32(<vscale x 16 x float> %v) {
; CHECK-LABEL: vfsqrt_nxv16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e32, m8, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 16 x float> @llvm.sqrt.nxv16f32(<vscale x 16 x float> %v)
  ret <vscale x 16 x float> %r
}

declare <vscale x 1 x double> @llvm.sqrt.nxv1f64(<vscale x 1 x double>)

define <vscale x 1 x double> @vfsqrt_nxv1f64(<vscale x 1 x double> %v) {
; CHECK-LABEL: vfsqrt_nxv1f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e64, m1, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 1 x double> @llvm.sqrt.nxv1f64(<vscale x 1 x double> %v)
  ret <vscale x 1 x double> %r
}

declare <vscale x 2 x double> @llvm.sqrt.nxv2f64(<vscale x 2 x double>)

define <vscale x 2 x double> @vfsqrt_nxv2f64(<vscale x 2 x double> %v) {
; CHECK-LABEL: vfsqrt_nxv2f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e64, m2, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x double> @llvm.sqrt.nxv2f64(<vscale x 2 x double> %v)
  ret <vscale x 2 x double> %r
}

declare <vscale x 4 x double> @llvm.sqrt.nxv4f64(<vscale x 4 x double>)

define <vscale x 4 x double> @vfsqrt_nxv4f64(<vscale x 4 x double> %v) {
; CHECK-LABEL: vfsqrt_nxv4f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e64, m4, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 4 x double> @llvm.sqrt.nxv4f64(<vscale x 4 x double> %v)
  ret <vscale x 4 x double> %r
}

declare <vscale x 8 x double> @llvm.sqrt.nxv8f64(<vscale x 8 x double>)

define <vscale x 8 x double> @vfsqrt_nxv8f64(<vscale x 8 x double> %v) {
; CHECK-LABEL: vfsqrt_nxv8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a0, zero, e64, m8, ta, mu
; CHECK-NEXT:    vfsqrt.v v8, v8
; CHECK-NEXT:    ret
  %r = call <vscale x 8 x double> @llvm.sqrt.nxv8f64(<vscale x 8 x double> %v)
  ret <vscale x 8 x double> %r
}
