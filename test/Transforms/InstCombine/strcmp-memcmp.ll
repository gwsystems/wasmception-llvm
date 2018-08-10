; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@key = constant [4 x i8] c"key\00", align 1
@abc = constant [8 x i8] c"abc\00de\00\00", align 1

declare void @use(i32)

define i32 @strcmp_memcmp([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

declare i32 @strcmp(i8* nocapture, i8* nocapture)

define i32 @strcmp_memcmp2([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp2(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp3([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp3(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp ne i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp4([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp4(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string)
  %cmp = icmp ne i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp5([5 x i8]* dereferenceable (5) %buf) {
; CHECK-LABEL: @strcmp_memcmp5(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [5 x i8], [5 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [5 x i8], [5 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull align 1 %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp6([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp6(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp sgt i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp7([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp7(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[MEMCMP_LOBIT:%.*]] = lshr i32 [[MEMCMP]], 31
; CHECK-NEXT:    ret i32 [[MEMCMP_LOBIT]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string)
  %cmp = icmp slt i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp8([4 x i8]* dereferenceable (4) %buf) {
; CHECK-LABEL: @strcmp_memcmp8(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [4 x i8], [4 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [4 x i8], [4 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp9([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp9(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0))
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}


define i32 @strncmp_memcmp([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 2)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 2)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

declare i32 @strncmp(i8* nocapture, i8* nocapture, i64)

define i32 @strncmp_memcmp2([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp2(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 11)
  %cmp = icmp ne i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp3([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp3(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 11)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp4([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp4(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 5)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp5([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp5(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}


define i32 @strncmp_memcmp6([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp6(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp ne i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp7([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp7(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 4)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp8([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp8(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 3)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 3)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp9([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp9(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp sgt i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp10([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp10(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[MEMCMP_LOBIT:%.*]] = lshr i32 [[MEMCMP]], 31
; CHECK-NEXT:    ret i32 [[MEMCMP_LOBIT]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp slt i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp11([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp11(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 12)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp12([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp12(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 12)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp13([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp13(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0), i64 2)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0), i64 2)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp14([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp14(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0), i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @abc, i64 0, i64 0), i64 12)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Negative tests
define i32 @strcmp_memcmp_bad([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[CALL]], 3
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp sgt i32 %call, 3
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp_bad2([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad2(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[CALL]], 3
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string)
  %cmp = icmp slt i32 %call, 3
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp_bad3([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad3(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
; CHECK-NEXT:    ret i32 [[CALL]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  ret i32 %call
}


define i32 @strcmp_memcmp_bad4(i8* nocapture readonly %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad4(
; CHECK-NEXT:    [[CALL:%.*]] = tail call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* [[BUF:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %call = tail call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* %buf)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}


define i32 @strcmp_memcmp_bad5([3 x i8]* dereferenceable (3) %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad5(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [3 x i8], [3 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [3 x i8], [3 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp_bad6([4 x i8]* dereferenceable (4) %buf, i8* nocapture readonly %k) {
; CHECK-LABEL: @strcmp_memcmp_bad6(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [4 x i8], [4 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* nonnull [[STRING]], i8* [[K:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [4 x i8], [4 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* %k)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp_bad7(i8* nocapture readonly %k) {
; CHECK-LABEL: @strcmp_memcmp_bad7(
; CHECK-NEXT:    [[CALL:%.*]] = tail call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* [[K:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %call = tail call i32 @strcmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* %k)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strcmp_memcmp_bad8([4 x i8]* dereferenceable (4) %buf) {
; CHECK-LABEL: @strcmp_memcmp_bad8(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [4 x i8], [4 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strcmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
; CHECK-NEXT:    tail call void @use(i32 [[CALL]])
; CHECK-NEXT:    ret i32 0
;
  %string = getelementptr inbounds [4 x i8], [4 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strcmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0))
  tail call void @use(i32 %call)
  ret i32 0
}

define i32 @strncmp_memcmp_bad([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp_bad(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 5)
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[CALL]], 3
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp sgt i32 %call, 3
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}


define i32 @strncmp_memcmp_bad1([12 x i8]* dereferenceable (12) %buf) {
; CHECK-LABEL: @strncmp_memcmp_bad1(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 5)
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[CALL]], 3
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 5)
  %cmp = icmp slt i32 %call, 3
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp_bad2([12 x i8]* dereferenceable (12) %buf, i64 %n) {
; CHECK-LABEL: @strncmp_memcmp_bad2(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [12 x i8], [12 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull [[STRING]], i64 [[N:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[CALL]], 1
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %string = getelementptr inbounds [12 x i8], [12 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* nonnull %string, i64 %n)
  %cmp = icmp slt i32 %call, 1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp_bad3(i8* nocapture readonly %k) {
; CHECK-LABEL: @strncmp_memcmp_bad3(
; CHECK-NEXT:    [[CALL:%.*]] = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* [[K:%.*]], i64 2)
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], 0
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
  %call = tail call i32 @strncmp(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i8* %k, i64 2)
  %cmp = icmp eq i32 %call, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

define i32 @strncmp_memcmp_bad4([4 x i8]* dereferenceable (4) %buf) {
; CHECK-LABEL: @strncmp_memcmp_bad4(
; CHECK-NEXT:    [[STRING:%.*]] = getelementptr inbounds [4 x i8], [4 x i8]* [[BUF:%.*]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @strncmp(i8* nonnull [[STRING]], i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 2)
; CHECK-NEXT:    tail call void @use(i32 [[CALL]])
; CHECK-NEXT:    ret i32 0
;
  %string = getelementptr inbounds [4 x i8], [4 x i8]* %buf, i64 0, i64 0
  %call = call i32 @strncmp(i8* nonnull %string, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @key, i64 0, i64 0), i64 2)
  tail call void @use(i32 %call)
  ret i32 0
}

declare i32 @memcmp(i8* nocapture, i8* nocapture, i64)
