; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -tailcallelim -verify-dom-info -S | FileCheck %s

; This test checks that TRE would be done for only one recursive call.
; The test_multiple_exits function has three recursive calls.
; First recursive call could not be eliminated because there is
; escaped pointer to local variable. Second recursive call could
; be eliminated. Thrid recursive call could not be eliminated since
; this is not last call. Thus, test checks that TRE would be done
; for only second recursive call.

; IR for that test was generated from the following C++ source:
;
; void capture_arg (int*);
; void test_multiple_exits (int param);
;   if (param >= 0 && param < 10) {
;     int temp;
;     capture_arg(&temp);
;     // TRE could not be done because pointer to local
;     // variable "temp" is escaped.
;     test_multiple_exits(param + 1);
;   } else if (param >=10 && param < 20) {
;     // TRE should be done.
;     test_multiple_exits(param + 1);
;   } else if (param >= 20 && param < 22) {
;     // TRE could not be done since recursive
;     // call is not last call.
;     test_multiple_exits(param + 1);
;     func();
;   }
;
;   return;
; }

; Function Attrs: noinline optnone uwtable
declare void @_Z11capture_argPi(i32* %param) #0

; Function Attrs: noinline optnone uwtable
declare void @_Z4funcv() #0

; Function Attrs: noinline nounwind uwtable
define dso_local void @_Z19test_multiple_exitsi(i32 %param) local_unnamed_addr #2 {
; CHECK-LABEL: @_Z19test_multiple_exitsi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TEMP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    br label [[TAILRECURSE:%.*]]
; CHECK:       tailrecurse:
; CHECK-NEXT:    [[PARAM_TR:%.*]] = phi i32 [ [[PARAM:%.*]], [[ENTRY:%.*]] ], [ [[ADD6:%.*]], [[IF_THEN5:%.*]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i32 [[PARAM_TR]], 10
; CHECK-NEXT:    br i1 [[TMP0]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i32* [[TEMP]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull [[TMP1]]) #1
; CHECK-NEXT:    call void @_Z11capture_argPi(i32* nonnull [[TEMP]])
; CHECK-NEXT:    [[ADD:%.*]] = add nuw nsw i32 [[PARAM_TR]], 1
; CHECK-NEXT:    call void @_Z19test_multiple_exitsi(i32 [[ADD]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull [[TMP1]]) #1
; CHECK-NEXT:    br label [[IF_END14:%.*]]
; CHECK:       if.else:
; CHECK-NEXT:    [[PARAM_OFF:%.*]] = add i32 [[PARAM_TR]], -10
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i32 [[PARAM_OFF]], 10
; CHECK-NEXT:    br i1 [[TMP2]], label [[IF_THEN5]], label [[IF_ELSE7:%.*]]
; CHECK:       if.then5:
; CHECK-NEXT:    [[ADD6]] = add nuw nsw i32 [[PARAM_TR]], 1
; CHECK-NEXT:    br label [[TAILRECURSE]]
; CHECK:       if.else7:
; CHECK-NEXT:    [[TMP3:%.*]] = and i32 [[PARAM_TR]], -2
; CHECK-NEXT:    [[TMP4:%.*]] = icmp eq i32 [[TMP3]], 20
; CHECK-NEXT:    br i1 [[TMP4]], label [[IF_THEN11:%.*]], label [[IF_END14]]
; CHECK:       if.then11:
; CHECK-NEXT:    [[ADD12:%.*]] = add nsw i32 [[PARAM_TR]], 1
; CHECK-NEXT:    tail call void @_Z19test_multiple_exitsi(i32 [[ADD12]])
; CHECK-NEXT:    tail call void @_Z4funcv()
; CHECK-NEXT:    ret void
; CHECK:       if.end14:
; CHECK-NEXT:    ret void
;
entry:
  %temp = alloca i32, align 4
  %0 = icmp ult i32 %param, 10
  br i1 %0, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = bitcast i32* %temp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %1) #2
  call void @_Z11capture_argPi(i32* nonnull %temp)
  %add = add nuw nsw i32 %param, 1
  call void @_Z19test_multiple_exitsi(i32 %add)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %1) #2
  br label %if.end14

if.else:                                          ; preds = %entry
  %param.off = add i32 %param, -10
  %2 = icmp ult i32 %param.off, 10
  br i1 %2, label %if.then5, label %if.else7

if.then5:                                         ; preds = %if.else
  %add6 = add nuw nsw i32 %param, 1
  call void @_Z19test_multiple_exitsi(i32 %add6)
  br label %if.end14

if.else7:                                         ; preds = %if.else
  %3 = and i32 %param, -2
  %4 = icmp eq i32 %3, 20
  br i1 %4, label %if.then11, label %if.end14

if.then11:                                        ; preds = %if.else7
  %add12 = add nsw i32 %param, 1
  call void @_Z19test_multiple_exitsi(i32 %add12)
  call void @_Z4funcv()
  br label %if.end14

if.end14:                                         ; preds = %if.then5, %if.then11, %if.else7, %if.then
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

attributes #0 = { nofree noinline norecurse nounwind uwtable }
attributes #1 = { nounwind uwtable }
attributes #2 = { argmemonly nounwind willreturn }
