; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

declare i32 @passthru_i32(i32 returned)
declare i8* @passthru_p8(i8* returned)
declare i8* @passthru_p8_from_p32(i32* returned)
declare <8 x i8> @passthru_8i8v_from_2i32v(<2 x i32> returned)

define i32 @returned_const_int_arg() {
; CHECK-LABEL: @returned_const_int_arg(
; CHECK-NEXT:    [[X:%.*]] = call i32 @passthru_i32(i32 42)
; CHECK-NEXT:    ret i32 42
;
  %x = call i32 @passthru_i32(i32 42)
  ret i32 %x
}

define i8* @returned_const_ptr_arg() {
; CHECK-LABEL: @returned_const_ptr_arg(
; CHECK-NEXT:    [[X:%.*]] = call i8* @passthru_p8(i8* null)
; CHECK-NEXT:    ret i8* null
;
  %x = call i8* @passthru_p8(i8* null)
  ret i8* %x
}

define i8* @returned_const_ptr_arg_casted() {
; CHECK-LABEL: @returned_const_ptr_arg_casted(
; CHECK-NEXT:    [[X:%.*]] = call i8* @passthru_p8_from_p32(i32* null)
; CHECK-NEXT:    ret i8* null
;
  %x = call i8* @passthru_p8_from_p32(i32* null)
  ret i8* %x
}

define i8* @returned_ptr_arg_casted(i32* %a) {
; CHECK-LABEL: @returned_ptr_arg_casted(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i32* [[A:%.*]] to i8*
; CHECK-NEXT:    [[X:%.*]] = call i8* @passthru_p8_from_p32(i32* [[A]])
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %x = call i8* @passthru_p8_from_p32(i32* %a)
  ret i8* %x
}

@GV = constant <2 x i32> zeroinitializer
define <8 x i8> @returned_const_vec_arg_casted() {
; CHECK-LABEL: @returned_const_vec_arg_casted(
; CHECK-NEXT:    [[X:%.*]] = call <8 x i8> @passthru_8i8v_from_2i32v(<2 x i32> zeroinitializer)
; CHECK-NEXT:    ret <8 x i8> zeroinitializer
;
  %v = load <2 x i32>, <2 x i32>* @GV
  %x = call <8 x i8> @passthru_8i8v_from_2i32v(<2 x i32> %v)
  ret <8 x i8> %x
}

define <8 x i8> @returned_vec_arg_casted(<2 x i32> %a) {
; CHECK-LABEL: @returned_vec_arg_casted(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <2 x i32> [[A:%.*]] to <8 x i8>
; CHECK-NEXT:    [[X:%.*]] = call <8 x i8> @passthru_8i8v_from_2i32v(<2 x i32> [[A]])
; CHECK-NEXT:    ret <8 x i8> [[TMP1]]
;
  %x = call <8 x i8> @passthru_8i8v_from_2i32v(<2 x i32> %a)
  ret <8 x i8> %x
}

define i32 @returned_var_arg(i32 %arg) {
; CHECK-LABEL: @returned_var_arg(
; CHECK-NEXT:    [[X:%.*]] = call i32 @passthru_i32(i32 [[ARG:%.*]])
; CHECK-NEXT:    ret i32 [[ARG]]
;
  %x = call i32 @passthru_i32(i32 %arg)
  ret i32 %x
}

define i32 @returned_const_int_arg_musttail(i32 %arg) {
; CHECK-LABEL: @returned_const_int_arg_musttail(
; CHECK-NEXT:    [[X:%.*]] = musttail call i32 @passthru_i32(i32 42)
; CHECK-NEXT:    ret i32 [[X]]
;
  %x = musttail call i32 @passthru_i32(i32 42)
  ret i32 %x
}

define i32 @returned_var_arg_musttail(i32 %arg) {
; CHECK-LABEL: @returned_var_arg_musttail(
; CHECK-NEXT:    [[X:%.*]] = musttail call i32 @passthru_i32(i32 [[ARG:%.*]])
; CHECK-NEXT:    ret i32 [[X]]
;
  %x = musttail call i32 @passthru_i32(i32 %arg)
  ret i32 %x
}

