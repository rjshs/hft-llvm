; ModuleID = 'benchmarks/hft/orderbook.cpp'
source_filename = "benchmarks/hft/orderbook.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%struct.OrderBookLevel = type { double, i32, i32, i64, i32, i32, double, double, double, double, i64, i64, i64, i64, [64 x i8], [32 x i8] }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { ptr, ptr }
%"struct.std::atomic.0" = type { double }
%"class.std::basic_ostream" = type { ptr, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", ptr, i8, i8, ptr, ptr, ptr, ptr }
%"class.std::ios_base" = type { ptr, i64, i64, i32, i32, i32, ptr, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, ptr, %"class.std::locale" }
%"struct.std::ios_base::_Words" = type { ptr, i64 }
%"class.std::locale" = type { ptr }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<Message, std::allocator<Message>>::_Vector_impl" }
%"struct.std::_Vector_base<Message, std::allocator<Message>>::_Vector_impl" = type { %"struct.std::_Vector_base<Message, std::allocator<Message>>::_Vector_impl_data" }
%"struct.std::_Vector_base<Message, std::allocator<Message>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%"class.std::mersenne_twister_engine" = type { [312 x i64], i64 }
%struct.Message = type { i8, i8, i16, i32, double, i64 }

$_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@bids = dso_local local_unnamed_addr global [1024 x %struct.OrderBookLevel] zeroinitializer, align 64
@asks = dso_local local_unnamed_addr global [1024 x %struct.OrderBookLevel] zeroinitializer, align 64
@g_sequence_number = dso_local global { i64 } zeroinitializer, align 8
@g_messages_processed = dso_local global { i64 } zeroinitializer, align 8
@g_total_volume = dso_local global { i64 } zeroinitializer, align 8
@g_stats_mutex = dso_local local_unnamed_addr global { %union.pthread_mutex_t } zeroinitializer, align 8
@g_cumulative_spread = dso_local local_unnamed_addr global %"struct.std::atomic.0" zeroinitializer, align 8
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str = private unnamed_addr constant [12 x i8] c"Generating \00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c" messages...\0A\00", align 1
@.str.2 = private unnamed_addr constant [24 x i8] c"Processing messages...\0A\00", align 1
@.str.3 = private unnamed_addr constant [18 x i8] c"\0A=== RESULTS ===\0A\00", align 1
@.str.4 = private unnamed_addr constant [7 x i8] c"Time: \00", align 1
@.str.5 = private unnamed_addr constant [5 x i8] c" ms\0A\00", align 1
@.str.6 = private unnamed_addr constant [13 x i8] c"Throughput: \00", align 1
@.str.7 = private unnamed_addr constant [13 x i8] c" M msgs/sec\0A\00", align 1
@.str.8 = private unnamed_addr constant [10 x i8] c"Latency: \00", align 1
@.str.9 = private unnamed_addr constant [9 x i8] c" ns/msg\0A\00", align 1
@.str.10 = private unnamed_addr constant [33 x i8] c"\0A=== COUNTERS (prevent DCE) ===\0A\00", align 1
@.str.11 = private unnamed_addr constant [11 x i8] c"Sequence: \00", align 1
@.str.12 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@.str.13 = private unnamed_addr constant [12 x i8] c"Processed: \00", align 1
@.str.14 = private unnamed_addr constant [9 x i8] c"Volume: \00", align 1
@.str.15 = private unnamed_addr constant [14 x i8] c"Accumulated: \00", align 1
@.str.16 = private unnamed_addr constant [16 x i8] c"vector::reserve\00", align 1
@.str.17 = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_orderbook.cpp, ptr null }]

declare void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #0

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) local_unnamed_addr #2

; Function Attrs: mustprogress uwtable
define dso_local void @_Z17generate_messagesi(ptr dead_on_unwind noalias nocapture writable sret(%"class.std::vector") align 8 initializes((0, 24)) %0, i32 noundef %1) local_unnamed_addr #3 personality ptr @__gxx_personality_v0 {
  %3 = alloca %"class.std::mersenne_twister_engine", align 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  %4 = sext i32 %1 to i64
  %5 = icmp slt i32 %1, 0
  br i1 %5, label %6, label %8

6:                                                ; preds = %2
  invoke void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.16) #15
          to label %7 unwind label %62

7:                                                ; preds = %6
  unreachable

8:                                                ; preds = %2
  %9 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %10 = load ptr, ptr %9, align 8, !tbaa !5
  %11 = load ptr, ptr %0, align 8, !tbaa !11
  %12 = ptrtoint ptr %10 to i64
  %13 = ptrtoint ptr %11 to i64
  %14 = sub i64 %12, %13
  %15 = sdiv exact i64 %14, 24
  %16 = icmp ult i64 %15, %4
  br i1 %16, label %17, label %33

17:                                               ; preds = %8
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %19 = load ptr, ptr %18, align 8, !tbaa !12
  %20 = ptrtoint ptr %19 to i64
  %21 = sub i64 %20, %13
  %22 = mul nuw nsw i64 %4, 24
  %23 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %22) #16
          to label %24 unwind label %62

24:                                               ; preds = %17
  %25 = icmp sgt i64 %21, 0
  br i1 %25, label %26, label %27

26:                                               ; preds = %24
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %23, ptr align 1 %11, i64 %21, i1 false)
  br label %27

27:                                               ; preds = %26, %24
  %28 = icmp eq ptr %11, null
  br i1 %28, label %30, label %29

29:                                               ; preds = %27
  tail call void @_ZdlPvm(ptr noundef nonnull %11, i64 noundef %14) #17
  br label %30

30:                                               ; preds = %29, %27
  store ptr %23, ptr %0, align 8, !tbaa !11
  %31 = getelementptr inbounds nuw i8, ptr %23, i64 %21
  store ptr %31, ptr %18, align 8, !tbaa !12
  %32 = getelementptr inbounds nuw %struct.Message, ptr %23, i64 %4
  store ptr %32, ptr %9, align 8, !tbaa !5
  br label %33

33:                                               ; preds = %30, %8
  call void @llvm.lifetime.start.p0(i64 2504, ptr nonnull %3) #18
  store i64 42, ptr %3, align 8, !tbaa !13
  br label %34

34:                                               ; preds = %34, %33
  %35 = phi i64 [ 42, %33 ], [ %40, %34 ]
  %36 = phi i64 [ 1, %33 ], [ %42, %34 ]
  %37 = lshr i64 %35, 62
  %38 = xor i64 %37, %35
  %39 = mul i64 %38, 6364136223846793005
  %40 = add i64 %39, %36
  %41 = getelementptr inbounds nuw [312 x i64], ptr %3, i64 0, i64 %36
  store i64 %40, ptr %41, align 8, !tbaa !13
  %42 = add nuw nsw i64 %36, 1
  %43 = icmp eq i64 %42, 312
  br i1 %43, label %44, label %34, !llvm.loop !15

44:                                               ; preds = %34
  %45 = getelementptr inbounds nuw i8, ptr %3, i64 2496
  store i64 312, ptr %45, align 8, !tbaa !18
  %46 = load ptr, ptr %9, align 8
  %47 = load ptr, ptr %0, align 8
  %48 = icmp eq i32 %1, 0
  br i1 %48, label %59, label %49

49:                                               ; preds = %44
  %50 = tail call x86_fp80 @llvm.log.f80(x86_fp80 0xK403F8000000000000000)
  %51 = tail call x86_fp80 @llvm.log.f80(x86_fp80 0xK40008000000000000000)
  %52 = fdiv x86_fp80 %50, %51
  %53 = fptoui x86_fp80 %52 to i64
  %54 = add i64 %53, 52
  %55 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %56 = tail call i32 @llvm.smax.i32(i32 %1, i32 1)
  %57 = add nuw i32 %56, 1000000000
  %58 = zext i32 %57 to i64
  br label %64

59:                                               ; preds = %201, %44
  %60 = phi ptr [ %47, %44 ], [ %202, %201 ]
  %61 = phi ptr [ %46, %44 ], [ %203, %201 ]
  store ptr %61, ptr %9, align 8
  store ptr %60, ptr %0, align 8
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %3) #18
  ret void

62:                                               ; preds = %17, %6
  %63 = landingpad { ptr, i32 }
          cleanup
  br label %220

64:                                               ; preds = %49, %201
  %65 = phi i64 [ 1000000000, %49 ], [ %204, %201 ]
  %66 = phi ptr [ %46, %49 ], [ %203, %201 ]
  %67 = phi ptr [ %47, %49 ], [ %202, %201 ]
  %68 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %69 unwind label %214

69:                                               ; preds = %64
  %70 = zext i64 %68 to i128
  %71 = mul nuw nsw i128 %70, 3
  %72 = trunc i128 %71 to i64
  %73 = lshr i128 %71, 64
  %74 = trunc nuw nsw i128 %73 to i8
  %75 = icmp eq i64 %72, 0
  br i1 %75, label %76, label %86

76:                                               ; preds = %69, %78
  %77 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %78 unwind label %212

78:                                               ; preds = %76
  %79 = zext i64 %77 to i128
  %80 = mul nuw nsw i128 %79, 3
  %81 = trunc i128 %80 to i64
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %76, label %83, !llvm.loop !20

83:                                               ; preds = %78
  %84 = lshr i128 %80, 64
  %85 = trunc nuw nsw i128 %84 to i8
  br label %86

86:                                               ; preds = %69, %83
  %87 = phi i8 [ %74, %69 ], [ %85, %83 ]
  %88 = udiv i64 %54, %53
  %89 = call i64 @llvm.umax.i64(i64 %88, i64 1)
  br label %93

90:                                               ; preds = %98
  %91 = fdiv double %100, %103
  %92 = fcmp ult double %91, 1.000000e+00
  br i1 %92, label %108, label %106, !prof !21

93:                                               ; preds = %98, %86
  %94 = phi i64 [ %89, %86 ], [ %104, %98 ]
  %95 = phi double [ 1.000000e+00, %86 ], [ %103, %98 ]
  %96 = phi double [ 0.000000e+00, %86 ], [ %100, %98 ]
  %97 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %98 unwind label %210

98:                                               ; preds = %93
  %99 = uitofp i64 %97 to double
  %100 = call double @llvm.fmuladd.f64(double %99, double %95, double %96)
  %101 = fpext double %95 to x86_fp80
  %102 = fmul x86_fp80 %101, 0xK403F8000000000000000
  %103 = fptrunc x86_fp80 %102 to double
  %104 = add i64 %94, -1
  %105 = icmp eq i64 %104, 0
  br i1 %105, label %90, label %93, !llvm.loop !22

106:                                              ; preds = %90
  %107 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #18, !tbaa !23
  br label %108

108:                                              ; preds = %90, %106
  %109 = phi double [ %107, %106 ], [ %91, %90 ]
  %110 = fcmp olt double %109, 5.000000e-01
  %111 = zext i1 %110 to i8
  %112 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %113 unwind label %214

113:                                              ; preds = %108
  %114 = lshr i64 %112, 54
  %115 = trunc nuw nsw i64 %114 to i16
  %116 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %117 unwind label %214

117:                                              ; preds = %113
  %118 = zext i64 %116 to i128
  %119 = mul nuw nsw i128 %118, 100
  %120 = lshr i128 %119, 64
  %121 = trunc nuw nsw i128 %120 to i32
  %122 = and i128 %119, 18446744073709551600
  %123 = icmp eq i128 %122, 0
  br i1 %123, label %124, label %134

124:                                              ; preds = %117, %126
  %125 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %126 unwind label %208

126:                                              ; preds = %124
  %127 = zext i64 %125 to i128
  %128 = mul nuw nsw i128 %127, 100
  %129 = and i128 %128, 18446744073709551600
  %130 = icmp eq i128 %129, 0
  br i1 %130, label %124, label %131, !llvm.loop !20

131:                                              ; preds = %126
  %132 = lshr i128 %128, 64
  %133 = trunc nuw nsw i128 %132 to i32
  br label %134

134:                                              ; preds = %117, %131
  %135 = phi i32 [ %121, %117 ], [ %133, %131 ]
  %136 = add nuw nsw i32 %135, 1
  br label %140

137:                                              ; preds = %145
  %138 = fdiv double %147, %150
  %139 = fcmp ult double %138, 1.000000e+00
  br i1 %139, label %155, label %153, !prof !21

140:                                              ; preds = %145, %134
  %141 = phi i64 [ %89, %134 ], [ %151, %145 ]
  %142 = phi double [ 1.000000e+00, %134 ], [ %150, %145 ]
  %143 = phi double [ 0.000000e+00, %134 ], [ %147, %145 ]
  %144 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %3)
          to label %145 unwind label %206

145:                                              ; preds = %140
  %146 = uitofp i64 %144 to double
  %147 = call double @llvm.fmuladd.f64(double %146, double %142, double %143)
  %148 = fpext double %142 to x86_fp80
  %149 = fmul x86_fp80 %148, 0xK403F8000000000000000
  %150 = fptrunc x86_fp80 %149 to double
  %151 = add i64 %141, -1
  %152 = icmp eq i64 %151, 0
  br i1 %152, label %137, label %140, !llvm.loop !22

153:                                              ; preds = %137
  %154 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #18, !tbaa !23
  br label %155

155:                                              ; preds = %137, %153
  %156 = phi double [ %154, %153 ], [ %138, %137 ]
  %157 = call noundef double @llvm.fmuladd.f64(double %156, double 2.000000e+00, double 9.900000e+01)
  %158 = load ptr, ptr %55, align 8, !tbaa !12
  %159 = icmp eq ptr %158, %66
  br i1 %159, label %167, label %160

160:                                              ; preds = %155
  store i8 %87, ptr %158, align 1, !tbaa !25
  %161 = getelementptr inbounds nuw i8, ptr %158, i64 1
  store i8 %111, ptr %161, align 1, !tbaa !27
  %162 = getelementptr inbounds nuw i8, ptr %158, i64 2
  store i16 %115, ptr %162, align 1, !tbaa !28
  %163 = getelementptr inbounds nuw i8, ptr %158, i64 4
  store i32 %136, ptr %163, align 1, !tbaa !23
  %164 = getelementptr inbounds nuw i8, ptr %158, i64 8
  store double %157, ptr %164, align 1, !tbaa !30
  %165 = getelementptr inbounds nuw i8, ptr %158, i64 16
  store i64 %65, ptr %165, align 1, !tbaa !13
  %166 = getelementptr inbounds nuw i8, ptr %158, i64 24
  store ptr %166, ptr %55, align 8, !tbaa !12
  br label %201

167:                                              ; preds = %155
  %168 = ptrtoint ptr %158 to i64
  %169 = ptrtoint ptr %67 to i64
  %170 = sub i64 %168, %169
  %171 = icmp eq i64 %170, 9223372036854775800
  br i1 %171, label %172, label %174

172:                                              ; preds = %167
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  invoke void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.17) #15
          to label %173 unwind label %216

173:                                              ; preds = %172
  unreachable

174:                                              ; preds = %167
  %175 = sdiv exact i64 %170, 24
  %176 = call i64 @llvm.umax.i64(i64 %175, i64 1)
  %177 = add i64 %176, %175
  %178 = icmp ult i64 %177, %175
  %179 = call i64 @llvm.umin.i64(i64 %177, i64 384307168202282325)
  %180 = select i1 %178, i64 384307168202282325, i64 %179
  %181 = icmp ne i64 %180, 0
  call void @llvm.assume(i1 %181)
  %182 = mul nuw nsw i64 %180, 24
  %183 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %182) #16
          to label %184 unwind label %214

184:                                              ; preds = %174
  %185 = getelementptr inbounds nuw i8, ptr %183, i64 %170
  store i8 %87, ptr %185, align 1, !tbaa !25
  %186 = getelementptr inbounds nuw i8, ptr %185, i64 1
  store i8 %111, ptr %186, align 1, !tbaa !27
  %187 = getelementptr inbounds nuw i8, ptr %185, i64 2
  store i16 %115, ptr %187, align 1, !tbaa !28
  %188 = getelementptr inbounds nuw i8, ptr %185, i64 4
  store i32 %136, ptr %188, align 1, !tbaa !23
  %189 = getelementptr inbounds nuw i8, ptr %185, i64 8
  store double %157, ptr %189, align 1, !tbaa !30
  %190 = getelementptr inbounds nuw i8, ptr %185, i64 16
  store i64 %65, ptr %190, align 1, !tbaa !13
  %191 = icmp sgt i64 %170, 0
  br i1 %191, label %192, label %193

192:                                              ; preds = %184
  call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %183, ptr align 1 %67, i64 %170, i1 false)
  br label %193

193:                                              ; preds = %192, %184
  %194 = getelementptr inbounds nuw i8, ptr %185, i64 24
  %195 = icmp eq ptr %67, null
  br i1 %195, label %199, label %196

196:                                              ; preds = %193
  %197 = ptrtoint ptr %66 to i64
  %198 = sub i64 %197, %169
  call void @_ZdlPvm(ptr noundef nonnull %67, i64 noundef %198) #17
  br label %199

199:                                              ; preds = %196, %193
  store ptr %194, ptr %55, align 8, !tbaa !12
  %200 = getelementptr inbounds nuw %struct.Message, ptr %183, i64 %180
  br label %201

201:                                              ; preds = %199, %160
  %202 = phi ptr [ %183, %199 ], [ %67, %160 ]
  %203 = phi ptr [ %200, %199 ], [ %66, %160 ]
  %204 = add nuw nsw i64 %65, 1
  %205 = icmp eq i64 %204, %58
  br i1 %205, label %59, label %64, !llvm.loop !32

206:                                              ; preds = %140
  %207 = landingpad { ptr, i32 }
          cleanup
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  br label %218

208:                                              ; preds = %124
  %209 = landingpad { ptr, i32 }
          cleanup
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  br label %218

210:                                              ; preds = %93
  %211 = landingpad { ptr, i32 }
          cleanup
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  br label %218

212:                                              ; preds = %76
  %213 = landingpad { ptr, i32 }
          cleanup
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  br label %218

214:                                              ; preds = %64, %108, %113, %174
  %215 = landingpad { ptr, i32 }
          cleanup
  store ptr %66, ptr %9, align 8
  store ptr %67, ptr %0, align 8
  br label %218

216:                                              ; preds = %172
  %217 = landingpad { ptr, i32 }
          cleanup
  br label %218

218:                                              ; preds = %208, %212, %216, %214, %210, %206
  %219 = phi { ptr, i32 } [ %207, %206 ], [ %209, %208 ], [ %211, %210 ], [ %213, %212 ], [ %215, %214 ], [ %217, %216 ]
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %3) #18
  br label %220

220:                                              ; preds = %218, %62
  %221 = phi { ptr, i32 } [ %219, %218 ], [ %63, %62 ]
  %222 = load ptr, ptr %0, align 8, !tbaa !11
  %223 = icmp eq ptr %222, null
  br i1 %223, label %230, label %224

224:                                              ; preds = %220
  %225 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %226 = load ptr, ptr %225, align 8, !tbaa !5
  %227 = ptrtoint ptr %226 to i64
  %228 = ptrtoint ptr %222 to i64
  %229 = sub i64 %227, %228
  call void @_ZdlPvm(ptr noundef nonnull %222, i64 noundef %229) #17
  br label %230

230:                                              ; preds = %220, %224
  resume { ptr, i32 } %221
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: mustprogress norecurse uwtable
define dso_local noundef i32 @main() local_unnamed_addr #5 personality ptr @__gxx_personality_v0 {
  %1 = alloca %"class.std::vector", align 8
  store atomic i64 0, ptr @g_sequence_number monotonic, align 8
  store atomic i64 0, ptr @g_messages_processed monotonic, align 8
  store atomic i64 0, ptr @g_total_volume monotonic, align 8
  br label %2

2:                                                ; preds = %2, %0
  %3 = phi i64 [ 0, %0 ], [ %11, %2 ]
  %4 = getelementptr inbounds nuw [1024 x %struct.OrderBookLevel], ptr @bids, i64 0, i64 %3
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 64 dereferenceable(192) %4, i8 0, i64 192, i1 false)
  %5 = getelementptr inbounds nuw [1024 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %3
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 64 dereferenceable(192) %5, i8 0, i64 192, i1 false)
  %6 = trunc nuw nsw i64 %3 to i32
  %7 = uitofp nneg i32 %6 to double
  %8 = fneg double %7
  %9 = tail call double @llvm.fmuladd.f64(double %8, double 1.000000e-02, double 1.000000e+02)
  store double %9, ptr %4, align 64, !tbaa !33
  %10 = tail call double @llvm.fmuladd.f64(double %7, double 1.000000e-02, double 1.000000e+02)
  store double %10, ptr %5, align 64, !tbaa !33
  %11 = add nuw nsw i64 %3, 1
  %12 = icmp eq i64 %11, 1024
  br i1 %12, label %13, label %2, !llvm.loop !35

13:                                               ; preds = %2
  %14 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str, i64 noundef 11)
  %15 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i32 noundef 10000000)
  %16 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %15, ptr noundef nonnull @.str.1, i64 noundef 13)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %1) #18
  call void @_Z17generate_messagesi(ptr dead_on_unwind nonnull writable sret(%"class.std::vector") align 8 %1, i32 noundef 10000000)
  %17 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 23)
          to label %18 unwind label %31

18:                                               ; preds = %13
  %19 = tail call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #18
  %20 = load ptr, ptr %1, align 8, !tbaa !11
  br label %33

21:                                               ; preds = %140
  %22 = tail call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #18
  %23 = sub nsw i64 %22, %19
  %24 = sdiv i64 %23, 1000000
  %25 = sitofp i64 %24 to double
  %26 = fdiv double 1.000000e+07, %25
  %27 = fmul double %26, 1.000000e+03
  %28 = fmul double %25, 1.000000e+06
  %29 = fdiv double %28, 1.000000e+07
  %30 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.3, i64 noundef 17)
          to label %143 unwind label %201

31:                                               ; preds = %13
  %32 = landingpad { ptr, i32 }
          cleanup
  br label %203

33:                                               ; preds = %18, %140
  %34 = phi i64 [ 0, %18 ], [ %141, %140 ]
  %35 = phi double [ 0.000000e+00, %18 ], [ %94, %140 ]
  %36 = getelementptr inbounds nuw %struct.Message, ptr %20, i64 %34
  %37 = atomicrmw add ptr @g_sequence_number, i64 1 monotonic, align 8
  %38 = getelementptr inbounds nuw i8, ptr %36, i64 1
  %39 = load i8, ptr %38, align 1, !tbaa !36
  %40 = icmp eq i8 %39, 0
  %41 = select i1 %40, ptr @asks, ptr @bids
  %42 = getelementptr inbounds nuw i8, ptr %36, i64 2
  %43 = load i16, ptr %42, align 1, !tbaa !38
  %44 = zext i16 %43 to i64
  %45 = getelementptr inbounds nuw %struct.OrderBookLevel, ptr %41, i64 %44
  %46 = load i8, ptr %36, align 1, !tbaa !39
  switch i8 %46, label %93 [
    i8 0, label %47
    i8 1, label %61
    i8 2, label %77
    i8 3, label %88
  ]

47:                                               ; preds = %33
  %48 = getelementptr inbounds nuw i8, ptr %36, i64 8
  %49 = load double, ptr %48, align 1, !tbaa !40
  store double %49, ptr %45, align 64, !tbaa !33
  %50 = getelementptr inbounds nuw i8, ptr %36, i64 4
  %51 = load i32, ptr %50, align 1, !tbaa !41
  %52 = getelementptr inbounds nuw i8, ptr %45, i64 8
  %53 = load i32, ptr %52, align 8, !tbaa !42
  %54 = add nsw i32 %53, %51
  store i32 %54, ptr %52, align 8, !tbaa !42
  %55 = getelementptr inbounds nuw i8, ptr %45, i64 12
  %56 = load i32, ptr %55, align 4, !tbaa !43
  %57 = add nsw i32 %56, 1
  store i32 %57, ptr %55, align 4, !tbaa !43
  %58 = getelementptr inbounds nuw i8, ptr %45, i64 72
  %59 = load i64, ptr %58, align 8, !tbaa !44
  %60 = add i64 %59, 1
  store i64 %60, ptr %58, align 8, !tbaa !44
  br label %93

61:                                               ; preds = %33
  %62 = getelementptr inbounds nuw i8, ptr %36, i64 4
  %63 = load i32, ptr %62, align 1, !tbaa !41
  %64 = getelementptr inbounds nuw i8, ptr %45, i64 8
  %65 = load i32, ptr %64, align 8, !tbaa !42
  %66 = sub nsw i32 %65, %63
  %67 = tail call i32 @llvm.smax.i32(i32 %66, i32 0)
  store i32 %67, ptr %64, align 8, !tbaa !42
  %68 = getelementptr inbounds nuw i8, ptr %45, i64 12
  %69 = load i32, ptr %68, align 4, !tbaa !43
  %70 = icmp sgt i32 %69, 0
  br i1 %70, label %71, label %73

71:                                               ; preds = %61
  %72 = add nsw i32 %69, -1
  store i32 %72, ptr %68, align 4, !tbaa !43
  br label %73

73:                                               ; preds = %71, %61
  %74 = getelementptr inbounds nuw i8, ptr %45, i64 80
  %75 = load i64, ptr %74, align 16, !tbaa !45
  %76 = add i64 %75, 1
  store i64 %76, ptr %74, align 16, !tbaa !45
  br label %93

77:                                               ; preds = %33
  %78 = getelementptr inbounds nuw i8, ptr %36, i64 8
  %79 = load double, ptr %78, align 1, !tbaa !40
  store double %79, ptr %45, align 64, !tbaa !33
  %80 = getelementptr inbounds nuw i8, ptr %36, i64 4
  %81 = load i32, ptr %80, align 1, !tbaa !41
  %82 = getelementptr inbounds nuw i8, ptr %45, i64 8
  %83 = load i32, ptr %82, align 8, !tbaa !42
  %84 = add nsw i32 %83, %81
  store i32 %84, ptr %82, align 8, !tbaa !42
  %85 = getelementptr inbounds nuw i8, ptr %45, i64 88
  %86 = load i64, ptr %85, align 8, !tbaa !46
  %87 = add i64 %86, 1
  store i64 %87, ptr %85, align 8, !tbaa !46
  br label %93

88:                                               ; preds = %33
  %89 = load double, ptr @bids, align 64, !tbaa !33
  %90 = load double, ptr @asks, align 64, !tbaa !33
  %91 = fsub double %90, %89
  %92 = fadd double %35, %91
  br label %93

93:                                               ; preds = %88, %77, %73, %47, %33
  %94 = phi double [ %35, %33 ], [ %92, %88 ], [ %35, %77 ], [ %35, %73 ], [ %35, %47 ]
  %95 = getelementptr inbounds nuw i8, ptr %45, i64 64
  %96 = load i64, ptr %95, align 64, !tbaa !47
  %97 = add i64 %96, 1
  store i64 %97, ptr %95, align 64, !tbaa !47
  %98 = getelementptr inbounds nuw i8, ptr %36, i64 16
  %99 = load i64, ptr %98, align 1, !tbaa !48
  %100 = getelementptr inbounds nuw i8, ptr %45, i64 16
  store i64 %99, ptr %100, align 16, !tbaa !49
  %101 = atomicrmw add ptr @g_messages_processed, i64 1 monotonic, align 8
  %102 = getelementptr inbounds nuw i8, ptr %36, i64 4
  %103 = load i32, ptr %102, align 1, !tbaa !41
  %104 = icmp sgt i32 %103, 0
  br i1 %104, label %105, label %108

105:                                              ; preds = %93
  %106 = zext nneg i32 %103 to i64
  %107 = atomicrmw add ptr @g_total_volume, i64 %106 monotonic, align 8
  br label %108

108:                                              ; preds = %105, %93
  %109 = and i64 %34, 16383
  %110 = icmp eq i64 %109, 0
  br i1 %110, label %111, label %140

111:                                              ; preds = %108
  %112 = load i16, ptr %42, align 1, !tbaa !38
  %113 = zext i16 %112 to i64
  %114 = getelementptr inbounds nuw [1024 x %struct.OrderBookLevel], ptr @bids, i64 0, i64 %113
  %115 = getelementptr inbounds nuw [1024 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %113
  %116 = getelementptr inbounds nuw i8, ptr %114, i64 32
  %117 = load double, ptr %116, align 32, !tbaa !50
  %118 = load double, ptr @bids, align 64, !tbaa !33
  %119 = load double, ptr @asks, align 64, !tbaa !33
  %120 = fsub double %119, %118
  %121 = fmul double %120, 1.000000e-02
  %122 = tail call double @llvm.fmuladd.f64(double %117, double 0x3FEFAE147AE147AE, double %121)
  store double %122, ptr %116, align 32, !tbaa !50
  %123 = getelementptr inbounds nuw i8, ptr %115, i64 32
  %124 = load double, ptr %123, align 32, !tbaa !50
  %125 = tail call double @llvm.fmuladd.f64(double %124, double 0x3FEFAE147AE147AE, double %121)
  store double %125, ptr %123, align 32, !tbaa !50
  %126 = getelementptr inbounds nuw i8, ptr %114, i64 40
  %127 = load double, ptr %126, align 8, !tbaa !51
  %128 = getelementptr inbounds nuw i8, ptr %114, i64 8
  %129 = load i32, ptr %128, align 8, !tbaa !42
  %130 = sitofp i32 %129 to double
  %131 = fmul double %130, 1.000000e-02
  %132 = tail call double @llvm.fmuladd.f64(double %127, double 0x3FEFAE147AE147AE, double %131)
  store double %132, ptr %126, align 8, !tbaa !51
  %133 = getelementptr inbounds nuw i8, ptr %115, i64 40
  %134 = load double, ptr %133, align 8, !tbaa !51
  %135 = getelementptr inbounds nuw i8, ptr %115, i64 8
  %136 = load i32, ptr %135, align 8, !tbaa !42
  %137 = sitofp i32 %136 to double
  %138 = fmul double %137, 1.000000e-02
  %139 = tail call double @llvm.fmuladd.f64(double %134, double 0x3FEFAE147AE147AE, double %138)
  store double %139, ptr %133, align 8, !tbaa !51
  br label %140

140:                                              ; preds = %108, %111
  %141 = add nuw nsw i64 %34, 1
  %142 = icmp eq i64 %141, 10000000
  br i1 %142, label %21, label %33, !llvm.loop !52

143:                                              ; preds = %21
  %144 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.4, i64 noundef 6)
          to label %145 unwind label %201

145:                                              ; preds = %143
  %146 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %24)
          to label %147 unwind label %201

147:                                              ; preds = %145
  %148 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %146, ptr noundef nonnull @.str.5, i64 noundef 4)
          to label %149 unwind label %201

149:                                              ; preds = %147
  %150 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.6, i64 noundef 12)
          to label %151 unwind label %201

151:                                              ; preds = %149
  %152 = fdiv double %27, 1.000000e+06
  %153 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %152)
          to label %154 unwind label %201

154:                                              ; preds = %151
  %155 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %153, ptr noundef nonnull @.str.7, i64 noundef 12)
          to label %156 unwind label %201

156:                                              ; preds = %154
  %157 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.8, i64 noundef 9)
          to label %158 unwind label %201

158:                                              ; preds = %156
  %159 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %29)
          to label %160 unwind label %201

160:                                              ; preds = %158
  %161 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %159, ptr noundef nonnull @.str.9, i64 noundef 8)
          to label %162 unwind label %201

162:                                              ; preds = %160
  %163 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.10, i64 noundef 32)
          to label %164 unwind label %201

164:                                              ; preds = %162
  %165 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.11, i64 noundef 10)
          to label %166 unwind label %201

166:                                              ; preds = %164
  %167 = load atomic i64, ptr @g_sequence_number seq_cst, align 8
  %168 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %167)
          to label %169 unwind label %201

169:                                              ; preds = %166
  %170 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %168, ptr noundef nonnull @.str.12, i64 noundef 1)
          to label %171 unwind label %201

171:                                              ; preds = %169
  %172 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.13, i64 noundef 11)
          to label %173 unwind label %201

173:                                              ; preds = %171
  %174 = load atomic i64, ptr @g_messages_processed seq_cst, align 8
  %175 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %174)
          to label %176 unwind label %201

176:                                              ; preds = %173
  %177 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %175, ptr noundef nonnull @.str.12, i64 noundef 1)
          to label %178 unwind label %201

178:                                              ; preds = %176
  %179 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.14, i64 noundef 8)
          to label %180 unwind label %201

180:                                              ; preds = %178
  %181 = load atomic i64, ptr @g_total_volume seq_cst, align 8
  %182 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %181)
          to label %183 unwind label %201

183:                                              ; preds = %180
  %184 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %182, ptr noundef nonnull @.str.12, i64 noundef 1)
          to label %185 unwind label %201

185:                                              ; preds = %183
  %186 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.15, i64 noundef 13)
          to label %187 unwind label %201

187:                                              ; preds = %185
  %188 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %94)
          to label %189 unwind label %201

189:                                              ; preds = %187
  %190 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %188, ptr noundef nonnull @.str.12, i64 noundef 1)
          to label %191 unwind label %201

191:                                              ; preds = %189
  %192 = load ptr, ptr %1, align 8, !tbaa !11
  %193 = icmp eq ptr %192, null
  br i1 %193, label %200, label %194

194:                                              ; preds = %191
  %195 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %196 = load ptr, ptr %195, align 8, !tbaa !5
  %197 = ptrtoint ptr %196 to i64
  %198 = ptrtoint ptr %192 to i64
  %199 = sub i64 %197, %198
  tail call void @_ZdlPvm(ptr noundef nonnull %192, i64 noundef %199) #17
  br label %200

200:                                              ; preds = %191, %194
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %1) #18
  ret i32 0

201:                                              ; preds = %189, %187, %185, %183, %180, %178, %176, %173, %171, %169, %166, %164, %162, %160, %158, %156, %154, %151, %149, %147, %145, %143, %21
  %202 = landingpad { ptr, i32 }
          cleanup
  br label %203

203:                                              ; preds = %201, %31
  %204 = phi { ptr, i32 } [ %202, %201 ], [ %32, %31 ]
  %205 = load ptr, ptr %1, align 8, !tbaa !11
  %206 = icmp eq ptr %205, null
  br i1 %206, label %213, label %207

207:                                              ; preds = %203
  %208 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %209 = load ptr, ptr %208, align 8, !tbaa !5
  %210 = ptrtoint ptr %209 to i64
  %211 = ptrtoint ptr %205 to i64
  %212 = sub i64 %210, %211
  tail call void @_ZdlPvm(ptr noundef nonnull %205, i64 noundef %212) #17
  br label %213

213:                                              ; preds = %203, %207
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %1) #18
  resume { ptr, i32 } %204
}

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8), i32 noundef) local_unnamed_addr #0

; Function Attrs: nounwind
declare i64 @_ZNSt6chrono3_V212system_clock3nowEv() local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #7

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #8

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(ptr noundef) local_unnamed_addr #9

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #10

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #11

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %0) local_unnamed_addr #3 comdat align 2 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 2496
  %3 = load i64, ptr %2, align 8, !tbaa !18
  %4 = icmp ugt i64 %3, 311
  br i1 %4, label %5, label %60

5:                                                ; preds = %1, %5
  %6 = phi i64 [ %10, %5 ], [ 0, %1 ]
  %7 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %6
  %8 = load i64, ptr %7, align 8, !tbaa !13
  %9 = and i64 %8, -2147483648
  %10 = add nuw nsw i64 %6, 1
  %11 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %10
  %12 = load i64, ptr %11, align 8, !tbaa !13
  %13 = and i64 %12, 2147483646
  %14 = or disjoint i64 %13, %9
  %15 = add nuw nsw i64 %6, 156
  %16 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %15
  %17 = load i64, ptr %16, align 8, !tbaa !13
  %18 = lshr exact i64 %14, 1
  %19 = xor i64 %18, %17
  %20 = and i64 %12, 1
  %21 = icmp eq i64 %20, 0
  %22 = select i1 %21, i64 0, i64 -5403634167711393303
  %23 = xor i64 %19, %22
  store i64 %23, ptr %7, align 8, !tbaa !13
  %24 = icmp eq i64 %10, 156
  br i1 %24, label %25, label %5, !llvm.loop !53

25:                                               ; preds = %5, %25
  %26 = phi i64 [ %30, %25 ], [ 156, %5 ]
  %27 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %26
  %28 = load i64, ptr %27, align 8, !tbaa !13
  %29 = and i64 %28, -2147483648
  %30 = add nuw nsw i64 %26, 1
  %31 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %30
  %32 = load i64, ptr %31, align 8, !tbaa !13
  %33 = and i64 %32, 2147483646
  %34 = or disjoint i64 %33, %29
  %35 = add nsw i64 %26, -156
  %36 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %35
  %37 = load i64, ptr %36, align 8, !tbaa !13
  %38 = lshr exact i64 %34, 1
  %39 = xor i64 %38, %37
  %40 = and i64 %32, 1
  %41 = icmp eq i64 %40, 0
  %42 = select i1 %41, i64 0, i64 -5403634167711393303
  %43 = xor i64 %39, %42
  store i64 %43, ptr %27, align 8, !tbaa !13
  %44 = icmp eq i64 %30, 311
  br i1 %44, label %45, label %25, !llvm.loop !54

45:                                               ; preds = %25
  %46 = getelementptr inbounds nuw i8, ptr %0, i64 2488
  %47 = load i64, ptr %46, align 8, !tbaa !13
  %48 = and i64 %47, -2147483648
  %49 = load i64, ptr %0, align 8, !tbaa !13
  %50 = and i64 %49, 2147483646
  %51 = or disjoint i64 %50, %48
  %52 = getelementptr inbounds nuw i8, ptr %0, i64 1240
  %53 = load i64, ptr %52, align 8, !tbaa !13
  %54 = lshr exact i64 %51, 1
  %55 = xor i64 %54, %53
  %56 = and i64 %49, 1
  %57 = icmp eq i64 %56, 0
  %58 = select i1 %57, i64 0, i64 -5403634167711393303
  %59 = xor i64 %55, %58
  store i64 %59, ptr %46, align 8, !tbaa !13
  store i64 0, ptr %2, align 8, !tbaa !18
  br label %60

60:                                               ; preds = %45, %1
  %61 = load i64, ptr %2, align 8, !tbaa !18
  %62 = add i64 %61, 1
  store i64 %62, ptr %2, align 8, !tbaa !18
  %63 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %61
  %64 = load i64, ptr %63, align 8, !tbaa !13
  %65 = lshr i64 %64, 29
  %66 = and i64 %65, 22906492245
  %67 = xor i64 %66, %64
  %68 = shl i64 %67, 17
  %69 = and i64 %68, 8202884508482404352
  %70 = xor i64 %69, %67
  %71 = shl i64 %70, 37
  %72 = and i64 %71, -2270628950310912
  %73 = xor i64 %72, %70
  %74 = lshr i64 %73, 43
  %75 = xor i64 %74, %73
  ret i64 %75
}

; Function Attrs: nounwind
declare double @nextafter(double noundef, double noundef) local_unnamed_addr #1

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8), ptr noundef, i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), double noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_orderbook.cpp() #12 section ".text.startup" {
  tail call void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %1 = tail call i32 @__cxa_atexit(ptr nonnull @_ZNSt8ios_base4InitD1Ev, ptr nonnull @_ZStL8__ioinit, ptr nonnull @__dso_handle) #18
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare x86_fp80 @llvm.log.f80(x86_fp80) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #13

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #13

attributes #0 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind }
attributes #3 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #7 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #12 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #14 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #15 = { noreturn }
attributes #16 = { builtin allocsize(0) }
attributes #17 = { builtin nounwind }
attributes #18 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 20.1.8 (https://github.com/llvm/llvm-project.git 87f0227cb60147a26a1eeb4fb06e3b505e9c7261)"}
!5 = !{!6, !7, i64 16}
!6 = !{!"_ZTSNSt12_Vector_baseI7MessageSaIS0_EE17_Vector_impl_dataE", !7, i64 0, !7, i64 8, !7, i64 16}
!7 = !{!"p1 _ZTS7Message", !8, i64 0}
!8 = !{!"any pointer", !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C++ TBAA"}
!11 = !{!6, !7, i64 0}
!12 = !{!6, !7, i64 8}
!13 = !{!14, !14, i64 0}
!14 = !{!"long", !9, i64 0}
!15 = distinct !{!15, !16, !17}
!16 = !{!"llvm.loop.mustprogress"}
!17 = !{!"llvm.loop.unroll.disable"}
!18 = !{!19, !14, i64 2496}
!19 = !{!"_ZTSSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE", !9, i64 0, !14, i64 2496}
!20 = distinct !{!20, !16, !17}
!21 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!22 = distinct !{!22, !16, !17}
!23 = !{!24, !24, i64 0}
!24 = !{!"int", !9, i64 0}
!25 = !{!26, !26, i64 0}
!26 = !{!"_ZTS7MsgType", !9, i64 0}
!27 = !{!9, !9, i64 0}
!28 = !{!29, !29, i64 0}
!29 = !{!"short", !9, i64 0}
!30 = !{!31, !31, i64 0}
!31 = !{!"double", !9, i64 0}
!32 = distinct !{!32, !16, !17}
!33 = !{!34, !31, i64 0}
!34 = !{!"_ZTS14OrderBookLevel", !31, i64 0, !24, i64 8, !24, i64 12, !14, i64 16, !24, i64 24, !24, i64 28, !31, i64 32, !31, i64 40, !31, i64 48, !31, i64 56, !14, i64 64, !14, i64 72, !14, i64 80, !14, i64 88, !9, i64 96}
!35 = distinct !{!35, !16, !17}
!36 = !{!37, !9, i64 1}
!37 = !{!"_ZTS7Message", !26, i64 0, !9, i64 1, !29, i64 2, !24, i64 4, !31, i64 8, !14, i64 16}
!38 = !{!37, !29, i64 2}
!39 = !{!37, !26, i64 0}
!40 = !{!37, !31, i64 8}
!41 = !{!37, !24, i64 4}
!42 = !{!34, !24, i64 8}
!43 = !{!34, !24, i64 12}
!44 = !{!34, !14, i64 72}
!45 = !{!34, !14, i64 80}
!46 = !{!34, !14, i64 88}
!47 = !{!34, !14, i64 64}
!48 = !{!37, !14, i64 16}
!49 = !{!34, !14, i64 16}
!50 = !{!34, !31, i64 32}
!51 = !{!34, !31, i64 40}
!52 = distinct !{!52, !16, !17}
!53 = distinct !{!53, !16, !17}
!54 = distinct !{!54, !16, !17}
