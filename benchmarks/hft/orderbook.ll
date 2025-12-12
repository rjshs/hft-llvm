; ModuleID = 'orderbook.cpp'
source_filename = "orderbook.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%struct.OrderBookLevel = type { double, i32, i32, i64, i32, i32, double, double, double, double, [1024 x i64], [1024 x double] }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i64 }
%"class.std::basic_ostream" = type { ptr, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", ptr, i8, i8, ptr, ptr, ptr, ptr }
%"class.std::ios_base" = type { ptr, i64, i64, i32, i32, i32, ptr, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, ptr, %"class.std::locale" }
%"struct.std::ios_base::_Words" = type { ptr, i64 }
%"class.std::locale" = type { ptr }
%struct.Engine = type { double }
%"class.std::mersenne_twister_engine" = type { [312 x i64], i64 }
%struct.Message = type { i8, i8, i32, i32, double }

$_ZN6Engine10on_messageERK7Message = comdat any

$_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@bids = dso_local local_unnamed_addr global [4096 x %struct.OrderBookLevel] zeroinitializer, align 16
@asks = dso_local local_unnamed_addr global [4096 x %struct.OrderBookLevel] zeroinitializer, align 16
@seq_no = dso_local global %"struct.std::atomic" zeroinitializer, align 8
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str = private unnamed_addr constant [11 x i8] c"Processed \00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c" messages in \00", align 1
@.str.2 = private unnamed_addr constant [5 x i8] c" s (\00", align 1
@.str.3 = private unnamed_addr constant [9 x i8] c" msg/s)\0A\00", align 1
@.str.4 = private unnamed_addr constant [16 x i8] c"Final seq_no = \00", align 1
@.str.5 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@.str.7 = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_orderbook.cpp, ptr null }]

declare void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #0

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) local_unnamed_addr #2

; Function Attrs: mustprogress norecurse uwtable
define dso_local noundef i32 @main() local_unnamed_addr #3 personality ptr @__gxx_personality_v0 {
  %1 = alloca %struct.Engine, align 8
  %2 = alloca %"class.std::mersenne_twister_engine", align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %1) #16
  store double 0.000000e+00, ptr %1, align 8, !tbaa !5
  store atomic i64 0, ptr @seq_no monotonic, align 8
  br label %3

3:                                                ; preds = %3, %0
  %4 = phi i64 [ 0, %0 ], [ %30, %3 ]
  %5 = mul nuw nsw i64 %4, 16448
  %6 = add nuw nsw i64 %5, 64
  %7 = getelementptr nuw i8, ptr @asks, i64 %6
  %8 = getelementptr nuw i8, ptr @bids, i64 %6
  %9 = trunc nuw nsw i64 %4 to i32
  %10 = uitofp nneg i32 %9 to double
  %11 = fneg double %10
  %12 = tail call double @llvm.fmuladd.f64(double %11, double 1.000000e-02, double 1.000000e+02)
  %13 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @bids, i64 0, i64 %4
  store double %12, ptr %13, align 16, !tbaa !10
  %14 = tail call double @llvm.fmuladd.f64(double %10, double 1.000000e-02, double 1.000000e+02)
  %15 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %4
  store double %14, ptr %15, align 16, !tbaa !10
  %16 = getelementptr inbounds nuw i8, ptr %13, i64 8
  store i32 0, ptr %16, align 8, !tbaa !14
  %17 = getelementptr inbounds nuw i8, ptr %15, i64 8
  store i32 0, ptr %17, align 8, !tbaa !14
  %18 = getelementptr inbounds nuw i8, ptr %13, i64 12
  store i32 0, ptr %18, align 4, !tbaa !15
  %19 = getelementptr inbounds nuw i8, ptr %15, i64 12
  store i32 0, ptr %19, align 4, !tbaa !15
  %20 = getelementptr inbounds nuw i8, ptr %13, i64 16
  store i64 0, ptr %20, align 16, !tbaa !16
  %21 = getelementptr inbounds nuw i8, ptr %15, i64 16
  store i64 0, ptr %21, align 16, !tbaa !16
  %22 = getelementptr inbounds nuw i8, ptr %13, i64 24
  store i32 1, ptr %22, align 8, !tbaa !17
  %23 = getelementptr inbounds nuw i8, ptr %15, i64 24
  store i32 2, ptr %23, align 8, !tbaa !17
  %24 = getelementptr inbounds nuw i8, ptr %13, i64 28
  store i32 0, ptr %24, align 4, !tbaa !18
  %25 = getelementptr inbounds nuw i8, ptr %15, i64 28
  store i32 0, ptr %25, align 4, !tbaa !18
  %26 = getelementptr inbounds nuw i8, ptr %13, i64 32
  %27 = getelementptr inbounds nuw i8, ptr %15, i64 32
  store <2 x double> zeroinitializer, ptr %26, align 16, !tbaa !19
  store <2 x double> zeroinitializer, ptr %27, align 16, !tbaa !19
  %28 = getelementptr inbounds nuw i8, ptr %13, i64 48
  %29 = getelementptr inbounds nuw i8, ptr %15, i64 48
  store <2 x double> zeroinitializer, ptr %28, align 16, !tbaa !19
  store <2 x double> zeroinitializer, ptr %29, align 16, !tbaa !19
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(8192) %8, i8 0, i64 8192, i1 false), !tbaa !20
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(8192) %7, i8 0, i64 8192, i1 false), !tbaa !20
  %30 = add nuw nsw i64 %4, 1
  %31 = icmp eq i64 %30, 4096
  br i1 %31, label %32, label %3, !llvm.loop !21

32:                                               ; preds = %3
  %33 = tail call noalias noundef nonnull dereferenceable(120000000) ptr @_Znwm(i64 noundef 120000000) #17
  call void @llvm.lifetime.start.p0(i64 2504, ptr nonnull %2) #16
  store i64 12345, ptr %2, align 8, !tbaa !20
  br label %34

34:                                               ; preds = %44, %32
  %35 = phi i64 [ 12345, %32 ], [ %48, %44 ]
  %36 = phi i64 [ 1, %32 ], [ %50, %44 ]
  %37 = lshr i64 %35, 62
  %38 = xor i64 %37, %35
  %39 = mul i64 %38, 6364136223846793005
  %40 = add i64 %39, %36
  %41 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %36
  store i64 %40, ptr %41, align 8, !tbaa !20
  %42 = add nuw nsw i64 %36, 1
  %43 = icmp eq i64 %42, 312
  br i1 %43, label %51, label %44, !llvm.loop !23

44:                                               ; preds = %34
  %45 = lshr i64 %40, 62
  %46 = xor i64 %45, %40
  %47 = mul i64 %46, 6364136223846793005
  %48 = add i64 %47, %42
  %49 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %42
  store i64 %48, ptr %49, align 8, !tbaa !20
  %50 = add nuw nsw i64 %36, 2
  br label %34

51:                                               ; preds = %34
  %52 = getelementptr inbounds nuw i8, ptr %33, i64 120000000
  %53 = getelementptr inbounds nuw i8, ptr %2, i64 2496
  store i64 312, ptr %53, align 8, !tbaa !24
  %54 = getelementptr inbounds nuw i8, ptr %2, i64 1248
  %55 = getelementptr inbounds nuw i8, ptr %2, i64 2488
  %56 = getelementptr inbounds nuw i8, ptr %2, i64 1240
  %57 = tail call x86_fp80 @llvm.log.f80(x86_fp80 0xK403F8000000000000000)
  %58 = tail call x86_fp80 @llvm.log.f80(x86_fp80 0xK40008000000000000000)
  %59 = fdiv x86_fp80 %57, %58
  %60 = fptoui x86_fp80 %59 to i64
  %61 = add i64 %60, 52
  %62 = getelementptr inbounds nuw i8, ptr %2, i64 2480
  %63 = getelementptr inbounds nuw i8, ptr %2, i64 2488
  %64 = getelementptr inbounds nuw i8, ptr %2, i64 1232
  %65 = getelementptr inbounds nuw i8, ptr %2, i64 2480
  %66 = getelementptr inbounds nuw i8, ptr %2, i64 2488
  %67 = getelementptr inbounds nuw i8, ptr %2, i64 1232
  %68 = getelementptr inbounds nuw i8, ptr %2, i64 2480
  %69 = getelementptr inbounds nuw i8, ptr %2, i64 2488
  %70 = getelementptr inbounds nuw i8, ptr %2, i64 1232
  %71 = getelementptr inbounds nuw i8, ptr %2, i64 2480
  %72 = getelementptr inbounds nuw i8, ptr %2, i64 2488
  %73 = getelementptr inbounds nuw i8, ptr %2, i64 1232
  br label %76

74:                                               ; preds = %572
  %75 = call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #16
  br label %584

76:                                               ; preds = %51, %572
  %77 = phi i32 [ 0, %51 ], [ %577, %572 ]
  %78 = phi ptr [ %33, %51 ], [ %575, %572 ]
  %79 = phi ptr [ %33, %51 ], [ %576, %572 ]
  %80 = phi ptr [ %52, %51 ], [ %573, %572 ]
  %81 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %2)
          to label %82 unwind label %579

82:                                               ; preds = %76
  %83 = zext i64 %81 to i128
  %84 = mul nuw nsw i128 %83, 3
  %85 = trunc i128 %84 to i64
  %86 = lshr i128 %84, 64
  %87 = trunc nuw nsw i128 %86 to i8
  %88 = icmp eq i64 %85, 0
  %89 = load i64, ptr %53, align 8, !tbaa !24
  br i1 %88, label %90, label %191

90:                                               ; preds = %82, %168
  %91 = phi i64 [ %170, %168 ], [ %89, %82 ]
  %92 = icmp ugt i64 %91, 311
  br i1 %92, label %93, label %168

93:                                               ; preds = %90
  %94 = load i64, ptr %2, align 8, !tbaa !20
  %95 = insertelement <2 x i64> poison, i64 %94, i64 1
  br label %96

96:                                               ; preds = %96, %93
  %97 = phi i64 [ 0, %93 ], [ %116, %96 ]
  %98 = phi <2 x i64> [ %95, %93 ], [ %102, %96 ]
  %99 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %97
  %100 = or disjoint i64 %97, 1
  %101 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %100
  %102 = load <2 x i64>, ptr %101, align 8, !tbaa !20
  %103 = shufflevector <2 x i64> %98, <2 x i64> %102, <2 x i32> <i32 1, i32 2>
  %104 = and <2 x i64> %103, splat (i64 -2147483648)
  %105 = and <2 x i64> %102, splat (i64 2147483646)
  %106 = or disjoint <2 x i64> %105, %104
  %107 = add nuw nsw i64 %97, 156
  %108 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %107
  %109 = load <2 x i64>, ptr %108, align 8, !tbaa !20
  %110 = lshr exact <2 x i64> %106, splat (i64 1)
  %111 = xor <2 x i64> %110, %109
  %112 = and <2 x i64> %102, splat (i64 1)
  %113 = icmp eq <2 x i64> %112, zeroinitializer
  %114 = select <2 x i1> %113, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %115 = xor <2 x i64> %111, %114
  store <2 x i64> %115, ptr %99, align 8, !tbaa !20
  %116 = add nuw i64 %97, 2
  %117 = icmp eq i64 %116, 156
  br i1 %117, label %118, label %96, !llvm.loop !26

118:                                              ; preds = %96
  %119 = load i64, ptr %54, align 8, !tbaa !20
  %120 = insertelement <2 x i64> poison, i64 %119, i64 1
  br label %121

121:                                              ; preds = %121, %118
  %122 = phi i64 [ 0, %118 ], [ %141, %121 ]
  %123 = phi <2 x i64> [ %120, %118 ], [ %128, %121 ]
  %124 = add i64 %122, 156
  %125 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %124
  %126 = add i64 %122, 157
  %127 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %126
  %128 = load <2 x i64>, ptr %127, align 8, !tbaa !20
  %129 = shufflevector <2 x i64> %123, <2 x i64> %128, <2 x i32> <i32 1, i32 2>
  %130 = and <2 x i64> %129, splat (i64 -2147483648)
  %131 = and <2 x i64> %128, splat (i64 2147483646)
  %132 = or disjoint <2 x i64> %131, %130
  %133 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %122
  %134 = load <2 x i64>, ptr %133, align 8, !tbaa !20
  %135 = lshr exact <2 x i64> %132, splat (i64 1)
  %136 = xor <2 x i64> %135, %134
  %137 = and <2 x i64> %128, splat (i64 1)
  %138 = icmp eq <2 x i64> %137, zeroinitializer
  %139 = select <2 x i1> %138, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %140 = xor <2 x i64> %136, %139
  store <2 x i64> %140, ptr %125, align 8, !tbaa !20
  %141 = add nuw i64 %122, 2
  %142 = icmp eq i64 %141, 154
  br i1 %142, label %143, label %121, !llvm.loop !29

143:                                              ; preds = %121
  %144 = extractelement <2 x i64> %128, i64 1
  %145 = and i64 %144, -2147483648
  %146 = load i64, ptr %63, align 8, !tbaa !20
  %147 = and i64 %146, 2147483646
  %148 = or disjoint i64 %147, %145
  %149 = load i64, ptr %64, align 8, !tbaa !20
  %150 = lshr exact i64 %148, 1
  %151 = xor i64 %150, %149
  %152 = and i64 %146, 1
  %153 = icmp eq i64 %152, 0
  %154 = select i1 %153, i64 0, i64 -5403634167711393303
  %155 = xor i64 %151, %154
  store i64 %155, ptr %62, align 8, !tbaa !20
  %156 = load i64, ptr %55, align 8, !tbaa !20
  %157 = and i64 %156, -2147483648
  %158 = load i64, ptr %2, align 8, !tbaa !20
  %159 = and i64 %158, 2147483646
  %160 = or disjoint i64 %159, %157
  %161 = load i64, ptr %56, align 8, !tbaa !20
  %162 = lshr exact i64 %160, 1
  %163 = xor i64 %162, %161
  %164 = and i64 %158, 1
  %165 = icmp eq i64 %164, 0
  %166 = select i1 %165, i64 0, i64 -5403634167711393303
  %167 = xor i64 %163, %166
  store i64 %167, ptr %55, align 8, !tbaa !20
  br label %168

168:                                              ; preds = %143, %90
  %169 = phi i64 [ 0, %143 ], [ %91, %90 ]
  %170 = add nuw nsw i64 %169, 1
  store i64 %170, ptr %53, align 8, !tbaa !24
  %171 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %169
  %172 = load i64, ptr %171, align 8, !tbaa !20
  %173 = lshr i64 %172, 29
  %174 = and i64 %173, 22906492245
  %175 = xor i64 %174, %172
  %176 = shl i64 %175, 17
  %177 = and i64 %176, 8202884508482404352
  %178 = xor i64 %177, %175
  %179 = shl i64 %178, 37
  %180 = and i64 %179, -2270628950310912
  %181 = xor i64 %180, %178
  %182 = lshr i64 %181, 43
  %183 = xor i64 %182, %181
  %184 = zext i64 %183 to i128
  %185 = mul nuw nsw i128 %184, 3
  %186 = trunc i128 %185 to i64
  %187 = icmp eq i64 %186, 0
  br i1 %187, label %90, label %188, !llvm.loop !30

188:                                              ; preds = %168
  %189 = lshr i128 %185, 64
  %190 = trunc nuw nsw i128 %189 to i8
  br label %191

191:                                              ; preds = %188, %82
  %192 = phi i64 [ %89, %82 ], [ %170, %188 ]
  %193 = phi i8 [ %87, %82 ], [ %190, %188 ]
  %194 = udiv i64 %61, %60
  %195 = call i64 @llvm.umax.i64(i64 %194, i64 1)
  br label %199

196:                                              ; preds = %280
  %197 = fdiv double %297, %300
  %198 = fcmp ult double %197, 1.000000e+00
  br i1 %198, label %305, label %303, !prof !31

199:                                              ; preds = %280, %191
  %200 = phi i64 [ %192, %191 ], [ %282, %280 ]
  %201 = phi i64 [ %195, %191 ], [ %301, %280 ]
  %202 = phi double [ 1.000000e+00, %191 ], [ %300, %280 ]
  %203 = phi double [ 0.000000e+00, %191 ], [ %297, %280 ]
  %204 = icmp ugt i64 %200, 311
  br i1 %204, label %205, label %280

205:                                              ; preds = %199
  %206 = load i64, ptr %2, align 8, !tbaa !20
  %207 = insertelement <2 x i64> poison, i64 %206, i64 1
  br label %208

208:                                              ; preds = %208, %205
  %209 = phi i64 [ 0, %205 ], [ %228, %208 ]
  %210 = phi <2 x i64> [ %207, %205 ], [ %214, %208 ]
  %211 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %209
  %212 = or disjoint i64 %209, 1
  %213 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %212
  %214 = load <2 x i64>, ptr %213, align 8, !tbaa !20
  %215 = shufflevector <2 x i64> %210, <2 x i64> %214, <2 x i32> <i32 1, i32 2>
  %216 = and <2 x i64> %215, splat (i64 -2147483648)
  %217 = and <2 x i64> %214, splat (i64 2147483646)
  %218 = or disjoint <2 x i64> %217, %216
  %219 = add nuw nsw i64 %209, 156
  %220 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %219
  %221 = load <2 x i64>, ptr %220, align 8, !tbaa !20
  %222 = lshr exact <2 x i64> %218, splat (i64 1)
  %223 = xor <2 x i64> %222, %221
  %224 = and <2 x i64> %214, splat (i64 1)
  %225 = icmp eq <2 x i64> %224, zeroinitializer
  %226 = select <2 x i1> %225, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %227 = xor <2 x i64> %223, %226
  store <2 x i64> %227, ptr %211, align 8, !tbaa !20
  %228 = add nuw i64 %209, 2
  %229 = icmp eq i64 %228, 156
  br i1 %229, label %230, label %208, !llvm.loop !32

230:                                              ; preds = %208
  %231 = load i64, ptr %54, align 8, !tbaa !20
  %232 = insertelement <2 x i64> poison, i64 %231, i64 1
  br label %233

233:                                              ; preds = %233, %230
  %234 = phi i64 [ 0, %230 ], [ %253, %233 ]
  %235 = phi <2 x i64> [ %232, %230 ], [ %240, %233 ]
  %236 = add i64 %234, 156
  %237 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %236
  %238 = add i64 %234, 157
  %239 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %238
  %240 = load <2 x i64>, ptr %239, align 8, !tbaa !20
  %241 = shufflevector <2 x i64> %235, <2 x i64> %240, <2 x i32> <i32 1, i32 2>
  %242 = and <2 x i64> %241, splat (i64 -2147483648)
  %243 = and <2 x i64> %240, splat (i64 2147483646)
  %244 = or disjoint <2 x i64> %243, %242
  %245 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %234
  %246 = load <2 x i64>, ptr %245, align 8, !tbaa !20
  %247 = lshr exact <2 x i64> %244, splat (i64 1)
  %248 = xor <2 x i64> %247, %246
  %249 = and <2 x i64> %240, splat (i64 1)
  %250 = icmp eq <2 x i64> %249, zeroinitializer
  %251 = select <2 x i1> %250, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %252 = xor <2 x i64> %248, %251
  store <2 x i64> %252, ptr %237, align 8, !tbaa !20
  %253 = add nuw i64 %234, 2
  %254 = icmp eq i64 %253, 154
  br i1 %254, label %255, label %233, !llvm.loop !33

255:                                              ; preds = %233
  %256 = extractelement <2 x i64> %240, i64 1
  %257 = and i64 %256, -2147483648
  %258 = load i64, ptr %66, align 8, !tbaa !20
  %259 = and i64 %258, 2147483646
  %260 = or disjoint i64 %259, %257
  %261 = load i64, ptr %67, align 8, !tbaa !20
  %262 = lshr exact i64 %260, 1
  %263 = xor i64 %262, %261
  %264 = and i64 %258, 1
  %265 = icmp eq i64 %264, 0
  %266 = select i1 %265, i64 0, i64 -5403634167711393303
  %267 = xor i64 %263, %266
  store i64 %267, ptr %65, align 8, !tbaa !20
  %268 = load i64, ptr %55, align 8, !tbaa !20
  %269 = and i64 %268, -2147483648
  %270 = load i64, ptr %2, align 8, !tbaa !20
  %271 = and i64 %270, 2147483646
  %272 = or disjoint i64 %271, %269
  %273 = load i64, ptr %56, align 8, !tbaa !20
  %274 = lshr exact i64 %272, 1
  %275 = xor i64 %274, %273
  %276 = and i64 %270, 1
  %277 = icmp eq i64 %276, 0
  %278 = select i1 %277, i64 0, i64 -5403634167711393303
  %279 = xor i64 %275, %278
  store i64 %279, ptr %55, align 8, !tbaa !20
  br label %280

280:                                              ; preds = %255, %199
  %281 = phi i64 [ 0, %255 ], [ %200, %199 ]
  %282 = add nuw nsw i64 %281, 1
  store i64 %282, ptr %53, align 8, !tbaa !24
  %283 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %281
  %284 = load i64, ptr %283, align 8, !tbaa !20
  %285 = lshr i64 %284, 29
  %286 = and i64 %285, 22906492245
  %287 = xor i64 %286, %284
  %288 = shl i64 %287, 17
  %289 = and i64 %288, 8202884508482404352
  %290 = xor i64 %289, %287
  %291 = shl i64 %290, 37
  %292 = and i64 %291, -2270628950310912
  %293 = xor i64 %292, %290
  %294 = lshr i64 %293, 43
  %295 = xor i64 %294, %293
  %296 = uitofp i64 %295 to double
  %297 = call double @llvm.fmuladd.f64(double %296, double %202, double %203)
  %298 = fpext double %202 to x86_fp80
  %299 = fmul x86_fp80 %298, 0xK403F8000000000000000
  %300 = fptrunc x86_fp80 %299 to double
  %301 = add i64 %201, -1
  %302 = icmp eq i64 %301, 0
  br i1 %302, label %196, label %199, !llvm.loop !34

303:                                              ; preds = %196
  %304 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #16, !tbaa !35
  br label %305

305:                                              ; preds = %196, %303
  %306 = phi double [ %304, %303 ], [ %197, %196 ]
  %307 = fcmp olt double %306, 5.000000e-01
  %308 = zext i1 %307 to i8
  %309 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %2)
          to label %310 unwind label %579

310:                                              ; preds = %305
  %311 = lshr i64 %309, 52
  %312 = trunc nuw nsw i64 %311 to i32
  %313 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %2)
          to label %314 unwind label %579

314:                                              ; preds = %310
  %315 = zext i64 %313 to i128
  %316 = mul nuw nsw i128 %315, 100
  %317 = lshr i128 %316, 64
  %318 = trunc nuw nsw i128 %317 to i32
  %319 = and i128 %316, 18446744073709551600
  %320 = icmp eq i128 %319, 0
  %321 = load i64, ptr %53, align 8, !tbaa !24
  br i1 %320, label %322, label %423

322:                                              ; preds = %314, %400
  %323 = phi i64 [ %402, %400 ], [ %321, %314 ]
  %324 = icmp ugt i64 %323, 311
  br i1 %324, label %325, label %400

325:                                              ; preds = %322
  %326 = load i64, ptr %2, align 8, !tbaa !20
  %327 = insertelement <2 x i64> poison, i64 %326, i64 1
  br label %328

328:                                              ; preds = %328, %325
  %329 = phi i64 [ 0, %325 ], [ %348, %328 ]
  %330 = phi <2 x i64> [ %327, %325 ], [ %334, %328 ]
  %331 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %329
  %332 = or disjoint i64 %329, 1
  %333 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %332
  %334 = load <2 x i64>, ptr %333, align 8, !tbaa !20
  %335 = shufflevector <2 x i64> %330, <2 x i64> %334, <2 x i32> <i32 1, i32 2>
  %336 = and <2 x i64> %335, splat (i64 -2147483648)
  %337 = and <2 x i64> %334, splat (i64 2147483646)
  %338 = or disjoint <2 x i64> %337, %336
  %339 = add nuw nsw i64 %329, 156
  %340 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %339
  %341 = load <2 x i64>, ptr %340, align 8, !tbaa !20
  %342 = lshr exact <2 x i64> %338, splat (i64 1)
  %343 = xor <2 x i64> %342, %341
  %344 = and <2 x i64> %334, splat (i64 1)
  %345 = icmp eq <2 x i64> %344, zeroinitializer
  %346 = select <2 x i1> %345, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %347 = xor <2 x i64> %343, %346
  store <2 x i64> %347, ptr %331, align 8, !tbaa !20
  %348 = add nuw i64 %329, 2
  %349 = icmp eq i64 %348, 156
  br i1 %349, label %350, label %328, !llvm.loop !36

350:                                              ; preds = %328
  %351 = load i64, ptr %54, align 8, !tbaa !20
  %352 = insertelement <2 x i64> poison, i64 %351, i64 1
  br label %353

353:                                              ; preds = %353, %350
  %354 = phi i64 [ 0, %350 ], [ %373, %353 ]
  %355 = phi <2 x i64> [ %352, %350 ], [ %360, %353 ]
  %356 = add i64 %354, 156
  %357 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %356
  %358 = add i64 %354, 157
  %359 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %358
  %360 = load <2 x i64>, ptr %359, align 8, !tbaa !20
  %361 = shufflevector <2 x i64> %355, <2 x i64> %360, <2 x i32> <i32 1, i32 2>
  %362 = and <2 x i64> %361, splat (i64 -2147483648)
  %363 = and <2 x i64> %360, splat (i64 2147483646)
  %364 = or disjoint <2 x i64> %363, %362
  %365 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %354
  %366 = load <2 x i64>, ptr %365, align 8, !tbaa !20
  %367 = lshr exact <2 x i64> %364, splat (i64 1)
  %368 = xor <2 x i64> %367, %366
  %369 = and <2 x i64> %360, splat (i64 1)
  %370 = icmp eq <2 x i64> %369, zeroinitializer
  %371 = select <2 x i1> %370, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %372 = xor <2 x i64> %368, %371
  store <2 x i64> %372, ptr %357, align 8, !tbaa !20
  %373 = add nuw i64 %354, 2
  %374 = icmp eq i64 %373, 154
  br i1 %374, label %375, label %353, !llvm.loop !37

375:                                              ; preds = %353
  %376 = extractelement <2 x i64> %360, i64 1
  %377 = and i64 %376, -2147483648
  %378 = load i64, ptr %69, align 8, !tbaa !20
  %379 = and i64 %378, 2147483646
  %380 = or disjoint i64 %379, %377
  %381 = load i64, ptr %70, align 8, !tbaa !20
  %382 = lshr exact i64 %380, 1
  %383 = xor i64 %382, %381
  %384 = and i64 %378, 1
  %385 = icmp eq i64 %384, 0
  %386 = select i1 %385, i64 0, i64 -5403634167711393303
  %387 = xor i64 %383, %386
  store i64 %387, ptr %68, align 8, !tbaa !20
  %388 = load i64, ptr %55, align 8, !tbaa !20
  %389 = and i64 %388, -2147483648
  %390 = load i64, ptr %2, align 8, !tbaa !20
  %391 = and i64 %390, 2147483646
  %392 = or disjoint i64 %391, %389
  %393 = load i64, ptr %56, align 8, !tbaa !20
  %394 = lshr exact i64 %392, 1
  %395 = xor i64 %394, %393
  %396 = and i64 %390, 1
  %397 = icmp eq i64 %396, 0
  %398 = select i1 %397, i64 0, i64 -5403634167711393303
  %399 = xor i64 %395, %398
  store i64 %399, ptr %55, align 8, !tbaa !20
  br label %400

400:                                              ; preds = %375, %322
  %401 = phi i64 [ 0, %375 ], [ %323, %322 ]
  %402 = add nuw nsw i64 %401, 1
  store i64 %402, ptr %53, align 8, !tbaa !24
  %403 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %401
  %404 = load i64, ptr %403, align 8, !tbaa !20
  %405 = lshr i64 %404, 29
  %406 = and i64 %405, 22906492245
  %407 = xor i64 %406, %404
  %408 = shl i64 %407, 17
  %409 = and i64 %408, 8202884508482404352
  %410 = xor i64 %409, %407
  %411 = shl i64 %410, 37
  %412 = and i64 %411, -2270628950310912
  %413 = xor i64 %412, %410
  %414 = lshr i64 %413, 43
  %415 = xor i64 %414, %413
  %416 = zext i64 %415 to i128
  %417 = mul nuw nsw i128 %416, 100
  %418 = and i128 %417, 18446744073709551600
  %419 = icmp eq i128 %418, 0
  br i1 %419, label %322, label %420, !llvm.loop !30

420:                                              ; preds = %400
  %421 = lshr i128 %417, 64
  %422 = trunc nuw nsw i128 %421 to i32
  br label %423

423:                                              ; preds = %420, %314
  %424 = phi i64 [ %321, %314 ], [ %402, %420 ]
  %425 = phi i32 [ %318, %314 ], [ %422, %420 ]
  br label %430

426:                                              ; preds = %511
  %427 = add nuw nsw i32 %425, 1
  %428 = fdiv double %528, %531
  %429 = fcmp ult double %428, 1.000000e+00
  br i1 %429, label %536, label %534, !prof !31

430:                                              ; preds = %511, %423
  %431 = phi i64 [ %424, %423 ], [ %513, %511 ]
  %432 = phi i64 [ %195, %423 ], [ %532, %511 ]
  %433 = phi double [ 1.000000e+00, %423 ], [ %531, %511 ]
  %434 = phi double [ 0.000000e+00, %423 ], [ %528, %511 ]
  %435 = icmp ugt i64 %431, 311
  br i1 %435, label %436, label %511

436:                                              ; preds = %430
  %437 = load i64, ptr %2, align 8, !tbaa !20
  %438 = insertelement <2 x i64> poison, i64 %437, i64 1
  br label %439

439:                                              ; preds = %439, %436
  %440 = phi i64 [ 0, %436 ], [ %459, %439 ]
  %441 = phi <2 x i64> [ %438, %436 ], [ %445, %439 ]
  %442 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %440
  %443 = or disjoint i64 %440, 1
  %444 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %443
  %445 = load <2 x i64>, ptr %444, align 8, !tbaa !20
  %446 = shufflevector <2 x i64> %441, <2 x i64> %445, <2 x i32> <i32 1, i32 2>
  %447 = and <2 x i64> %446, splat (i64 -2147483648)
  %448 = and <2 x i64> %445, splat (i64 2147483646)
  %449 = or disjoint <2 x i64> %448, %447
  %450 = add nuw nsw i64 %440, 156
  %451 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %450
  %452 = load <2 x i64>, ptr %451, align 8, !tbaa !20
  %453 = lshr exact <2 x i64> %449, splat (i64 1)
  %454 = xor <2 x i64> %453, %452
  %455 = and <2 x i64> %445, splat (i64 1)
  %456 = icmp eq <2 x i64> %455, zeroinitializer
  %457 = select <2 x i1> %456, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %458 = xor <2 x i64> %454, %457
  store <2 x i64> %458, ptr %442, align 8, !tbaa !20
  %459 = add nuw i64 %440, 2
  %460 = icmp eq i64 %459, 156
  br i1 %460, label %461, label %439, !llvm.loop !38

461:                                              ; preds = %439
  %462 = load i64, ptr %54, align 8, !tbaa !20
  %463 = insertelement <2 x i64> poison, i64 %462, i64 1
  br label %464

464:                                              ; preds = %464, %461
  %465 = phi i64 [ 0, %461 ], [ %484, %464 ]
  %466 = phi <2 x i64> [ %463, %461 ], [ %471, %464 ]
  %467 = add i64 %465, 156
  %468 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %467
  %469 = add i64 %465, 157
  %470 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %469
  %471 = load <2 x i64>, ptr %470, align 8, !tbaa !20
  %472 = shufflevector <2 x i64> %466, <2 x i64> %471, <2 x i32> <i32 1, i32 2>
  %473 = and <2 x i64> %472, splat (i64 -2147483648)
  %474 = and <2 x i64> %471, splat (i64 2147483646)
  %475 = or disjoint <2 x i64> %474, %473
  %476 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %465
  %477 = load <2 x i64>, ptr %476, align 8, !tbaa !20
  %478 = lshr exact <2 x i64> %475, splat (i64 1)
  %479 = xor <2 x i64> %478, %477
  %480 = and <2 x i64> %471, splat (i64 1)
  %481 = icmp eq <2 x i64> %480, zeroinitializer
  %482 = select <2 x i1> %481, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %483 = xor <2 x i64> %479, %482
  store <2 x i64> %483, ptr %468, align 8, !tbaa !20
  %484 = add nuw i64 %465, 2
  %485 = icmp eq i64 %484, 154
  br i1 %485, label %486, label %464, !llvm.loop !39

486:                                              ; preds = %464
  %487 = extractelement <2 x i64> %471, i64 1
  %488 = and i64 %487, -2147483648
  %489 = load i64, ptr %72, align 8, !tbaa !20
  %490 = and i64 %489, 2147483646
  %491 = or disjoint i64 %490, %488
  %492 = load i64, ptr %73, align 8, !tbaa !20
  %493 = lshr exact i64 %491, 1
  %494 = xor i64 %493, %492
  %495 = and i64 %489, 1
  %496 = icmp eq i64 %495, 0
  %497 = select i1 %496, i64 0, i64 -5403634167711393303
  %498 = xor i64 %494, %497
  store i64 %498, ptr %71, align 8, !tbaa !20
  %499 = load i64, ptr %55, align 8, !tbaa !20
  %500 = and i64 %499, -2147483648
  %501 = load i64, ptr %2, align 8, !tbaa !20
  %502 = and i64 %501, 2147483646
  %503 = or disjoint i64 %502, %500
  %504 = load i64, ptr %56, align 8, !tbaa !20
  %505 = lshr exact i64 %503, 1
  %506 = xor i64 %505, %504
  %507 = and i64 %501, 1
  %508 = icmp eq i64 %507, 0
  %509 = select i1 %508, i64 0, i64 -5403634167711393303
  %510 = xor i64 %506, %509
  store i64 %510, ptr %55, align 8, !tbaa !20
  br label %511

511:                                              ; preds = %486, %430
  %512 = phi i64 [ 0, %486 ], [ %431, %430 ]
  %513 = add nuw nsw i64 %512, 1
  store i64 %513, ptr %53, align 8, !tbaa !24
  %514 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %512
  %515 = load i64, ptr %514, align 8, !tbaa !20
  %516 = lshr i64 %515, 29
  %517 = and i64 %516, 22906492245
  %518 = xor i64 %517, %515
  %519 = shl i64 %518, 17
  %520 = and i64 %519, 8202884508482404352
  %521 = xor i64 %520, %518
  %522 = shl i64 %521, 37
  %523 = and i64 %522, -2270628950310912
  %524 = xor i64 %523, %521
  %525 = lshr i64 %524, 43
  %526 = xor i64 %525, %524
  %527 = uitofp i64 %526 to double
  %528 = call double @llvm.fmuladd.f64(double %527, double %433, double %434)
  %529 = fpext double %433 to x86_fp80
  %530 = fmul x86_fp80 %529, 0xK403F8000000000000000
  %531 = fptrunc x86_fp80 %530 to double
  %532 = add i64 %432, -1
  %533 = icmp eq i64 %532, 0
  br i1 %533, label %426, label %430, !llvm.loop !34

534:                                              ; preds = %426
  %535 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #16, !tbaa !35
  br label %536

536:                                              ; preds = %534, %426
  %537 = phi double [ %535, %534 ], [ %428, %426 ]
  %538 = fadd double %537, 9.950000e+01
  %539 = icmp eq ptr %79, %80
  br i1 %539, label %545, label %540

540:                                              ; preds = %536
  store i8 %193, ptr %79, align 8, !tbaa !40
  %541 = getelementptr inbounds nuw i8, ptr %79, i64 1
  store i8 %308, ptr %541, align 1, !tbaa !42
  %542 = getelementptr inbounds nuw i8, ptr %79, i64 4
  store i32 %312, ptr %542, align 4, !tbaa !35
  %543 = getelementptr inbounds nuw i8, ptr %79, i64 8
  store i32 %427, ptr %543, align 8, !tbaa !35
  %544 = getelementptr inbounds nuw i8, ptr %79, i64 16
  store double %538, ptr %544, align 8, !tbaa !19
  br label %572

545:                                              ; preds = %536
  %546 = ptrtoint ptr %79 to i64
  %547 = ptrtoint ptr %78 to i64
  %548 = sub i64 %546, %547
  %549 = icmp eq i64 %548, 9223372036854775800
  br i1 %549, label %550, label %552

550:                                              ; preds = %545
  invoke void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.7) #18
          to label %551 unwind label %582

551:                                              ; preds = %550
  unreachable

552:                                              ; preds = %545
  %553 = sdiv exact i64 %548, 24
  %554 = call i64 @llvm.umax.i64(i64 %553, i64 1)
  %555 = add nsw i64 %554, %553
  %556 = icmp ult i64 %555, %553
  %557 = call i64 @llvm.umin.i64(i64 %555, i64 384307168202282325)
  %558 = select i1 %556, i64 384307168202282325, i64 %557
  %559 = icmp ne i64 %558, 0
  call void @llvm.assume(i1 %559)
  %560 = mul nuw nsw i64 %558, 24
  %561 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %560) #17
          to label %562 unwind label %579

562:                                              ; preds = %552
  %563 = getelementptr inbounds i8, ptr %561, i64 %548
  store i8 %193, ptr %563, align 8, !tbaa !40
  %564 = getelementptr inbounds nuw i8, ptr %563, i64 1
  store i8 %308, ptr %564, align 1, !tbaa !42
  %565 = getelementptr inbounds nuw i8, ptr %563, i64 4
  store i32 %312, ptr %565, align 4, !tbaa !35
  %566 = getelementptr inbounds nuw i8, ptr %563, i64 8
  store i32 %427, ptr %566, align 8, !tbaa !35
  %567 = getelementptr inbounds nuw i8, ptr %563, i64 16
  store double %538, ptr %567, align 8, !tbaa !19
  %568 = icmp sgt i64 %548, 0
  br i1 %568, label %569, label %570

569:                                              ; preds = %562
  call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %561, ptr align 8 %78, i64 %548, i1 false)
  br label %570

570:                                              ; preds = %569, %562
  call void @_ZdlPvm(ptr noundef nonnull %78, i64 noundef %548) #19
  %571 = getelementptr inbounds nuw %struct.Message, ptr %561, i64 %558
  br label %572

572:                                              ; preds = %570, %540
  %573 = phi ptr [ %571, %570 ], [ %80, %540 ]
  %574 = phi ptr [ %563, %570 ], [ %79, %540 ]
  %575 = phi ptr [ %561, %570 ], [ %78, %540 ]
  %576 = getelementptr inbounds nuw i8, ptr %574, i64 24
  %577 = add nuw nsw i32 %77, 1
  %578 = icmp eq i32 %577, 5000000
  br i1 %578, label %74, label %76, !llvm.loop !44

579:                                              ; preds = %76, %305, %310, %552
  %580 = phi ptr [ %80, %76 ], [ %80, %305 ], [ %80, %310 ], [ %79, %552 ]
  %581 = landingpad { ptr, i32 }
          cleanup
  br label %645

582:                                              ; preds = %550
  %583 = landingpad { ptr, i32 }
          cleanup
  br label %645

584:                                              ; preds = %74, %610
  %585 = phi i64 [ 0, %74 ], [ %611, %610 ]
  %586 = getelementptr inbounds nuw %struct.Message, ptr %575, i64 %585
  call void @_ZN6Engine10on_messageERK7Message(ptr noundef nonnull align 8 dereferenceable(8) %1, ptr noundef nonnull align 8 dereferenceable(24) %586)
  %587 = and i64 %585, 4095
  %588 = icmp eq i64 %587, 0
  br i1 %588, label %589, label %610

589:                                              ; preds = %584
  %590 = getelementptr inbounds nuw i8, ptr %586, i64 4
  %591 = load i32, ptr %590, align 4, !tbaa !45
  %592 = getelementptr inbounds nuw i8, ptr %586, i64 1
  %593 = load i8, ptr %592, align 1, !tbaa !47, !range !48, !noundef !49
  %594 = trunc nuw i8 %593 to i1
  %595 = select i1 %594, ptr @bids, ptr @asks
  %596 = sext i32 %591 to i64
  %597 = getelementptr inbounds %struct.OrderBookLevel, ptr %595, i64 %596
  %598 = getelementptr inbounds nuw i8, ptr %597, i64 32
  %599 = load <2 x double>, ptr %598, align 16, !tbaa !19
  %600 = fadd <2 x double> %599, <double 1.000000e-04, double 2.000000e-04>
  store <2 x double> %600, ptr %598, align 16, !tbaa !19
  %601 = getelementptr inbounds nuw i8, ptr %597, i64 48
  %602 = load <2 x double>, ptr %601, align 16, !tbaa !19
  %603 = fadd <2 x double> %602, <double 5.000000e-05, double 1.000000e-05>
  store <2 x double> %603, ptr %601, align 16, !tbaa !19
  %604 = getelementptr inbounds nuw i8, ptr %597, i64 64
  %605 = srem i32 %591, 8
  %606 = sext i32 %605 to i64
  %607 = getelementptr inbounds [1024 x i64], ptr %604, i64 0, i64 %606
  %608 = load i64, ptr %607, align 8, !tbaa !20
  %609 = add i64 %608, 1
  store i64 %609, ptr %607, align 8, !tbaa !20
  br label %610

610:                                              ; preds = %589, %584
  %611 = add nuw nsw i64 %585, 1
  %612 = icmp eq i64 %611, 5000000
  br i1 %612, label %613, label %584, !llvm.loop !50

613:                                              ; preds = %610
  %614 = call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #16
  %615 = sub nsw i64 %614, %75
  %616 = sitofp i64 %615 to double
  %617 = fdiv double %616, 1.000000e+09
  %618 = fdiv double 5.000000e+06, %617
  %619 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str, i64 noundef 10)
          to label %620 unwind label %643

620:                                              ; preds = %613
  %621 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i32 noundef 5000000)
          to label %622 unwind label %643

622:                                              ; preds = %620
  %623 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %621, ptr noundef nonnull @.str.1, i64 noundef 13)
          to label %624 unwind label %643

624:                                              ; preds = %622
  %625 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %621, double noundef %617)
          to label %626 unwind label %643

626:                                              ; preds = %624
  %627 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %625, ptr noundef nonnull @.str.2, i64 noundef 4)
          to label %628 unwind label %643

628:                                              ; preds = %626
  %629 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %625, double noundef %618)
          to label %630 unwind label %643

630:                                              ; preds = %628
  %631 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %629, ptr noundef nonnull @.str.3, i64 noundef 8)
          to label %632 unwind label %643

632:                                              ; preds = %630
  %633 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.4, i64 noundef 15)
          to label %634 unwind label %643

634:                                              ; preds = %632
  %635 = load atomic i64, ptr @seq_no seq_cst, align 8
  %636 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %635)
          to label %637 unwind label %643

637:                                              ; preds = %634
  %638 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %636, ptr noundef nonnull @.str.5, i64 noundef 1)
          to label %639 unwind label %643

639:                                              ; preds = %637
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %2) #16
  %640 = ptrtoint ptr %573 to i64
  %641 = ptrtoint ptr %575 to i64
  %642 = sub i64 %640, %641
  call void @_ZdlPvm(ptr noundef nonnull %575, i64 noundef %642) #19
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %1) #16
  ret i32 0

643:                                              ; preds = %637, %634, %632, %630, %628, %626, %624, %622, %613, %620
  %644 = landingpad { ptr, i32 }
          cleanup
  br label %645

645:                                              ; preds = %579, %582, %643
  %646 = phi ptr [ %573, %643 ], [ %580, %579 ], [ %79, %582 ]
  %647 = phi ptr [ %575, %643 ], [ %78, %579 ], [ %78, %582 ]
  %648 = phi { ptr, i32 } [ %644, %643 ], [ %581, %579 ], [ %583, %582 ]
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %2) #16
  %649 = ptrtoint ptr %646 to i64
  %650 = ptrtoint ptr %647 to i64
  %651 = sub i64 %649, %650
  call void @_ZdlPvm(ptr noundef nonnull %647, i64 noundef %651) #19
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %1) #16
  resume { ptr, i32 } %648
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #4

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: nounwind
declare i64 @_ZNSt6chrono3_V212system_clock3nowEv() local_unnamed_addr #1

; Function Attrs: inlinehint mustprogress nounwind uwtable
define linkonce_odr dso_local void @_ZN6Engine10on_messageERK7Message(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(24) %1) local_unnamed_addr #5 comdat align 2 {
  %3 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %4 = load i32, ptr %3, align 4, !tbaa !45
  %5 = getelementptr inbounds nuw i8, ptr %1, i64 1
  %6 = load i8, ptr %5, align 1, !tbaa !47, !range !48, !noundef !49
  %7 = trunc nuw i8 %6 to i1
  %8 = sext i32 %4 to i64
  %9 = load i8, ptr %1, align 8, !tbaa !51
  br i1 %7, label %10, label %62

10:                                               ; preds = %2
  %11 = getelementptr inbounds [4096 x %struct.OrderBookLevel], ptr @bids, i64 0, i64 %8
  switch i8 %9, label %41 [
    i8 0, label %12
    i8 1, label %21
    i8 2, label %33
  ]

12:                                               ; preds = %10
  %13 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %14 = load double, ptr %13, align 8, !tbaa !52
  store double %14, ptr %11, align 16, !tbaa !10
  %15 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %16 = load i32, ptr %15, align 8, !tbaa !53
  %17 = getelementptr inbounds nuw i8, ptr %11, i64 8
  %18 = load <2 x i32>, ptr %17, align 8, !tbaa !35
  %19 = insertelement <2 x i32> <i32 poison, i32 1>, i32 %16, i64 0
  %20 = add nsw <2 x i32> %18, %19
  store <2 x i32> %20, ptr %17, align 8, !tbaa !35
  br label %41

21:                                               ; preds = %10
  %22 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %23 = load i32, ptr %22, align 8, !tbaa !53
  %24 = getelementptr inbounds nuw i8, ptr %11, i64 8
  %25 = load i32, ptr %24, align 8, !tbaa !14
  %26 = sub nsw i32 %25, %23
  %27 = tail call i32 @llvm.smax.i32(i32 %26, i32 0)
  store i32 %27, ptr %24, align 8, !tbaa !14
  %28 = getelementptr inbounds nuw i8, ptr %11, i64 12
  %29 = load i32, ptr %28, align 4, !tbaa !15
  %30 = icmp sgt i32 %29, 0
  br i1 %30, label %31, label %41

31:                                               ; preds = %21
  %32 = add nsw i32 %29, -1
  store i32 %32, ptr %28, align 4, !tbaa !15
  br label %41

33:                                               ; preds = %10
  %34 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %35 = load i32, ptr %34, align 8, !tbaa !53
  %36 = getelementptr inbounds nuw i8, ptr %11, i64 8
  %37 = load i32, ptr %36, align 8, !tbaa !14
  %38 = add nsw i32 %37, %35
  store i32 %38, ptr %36, align 8, !tbaa !14
  %39 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %40 = load double, ptr %39, align 8, !tbaa !52
  store double %40, ptr %11, align 16, !tbaa !10
  br label %41

41:                                               ; preds = %21, %31, %10, %33, %12
  br label %42

42:                                               ; preds = %42, %41
  %43 = phi double [ 0.000000e+00, %41 ], [ %59, %42 ]
  %44 = phi i32 [ 0, %41 ], [ %60, %42 ]
  %45 = add nsw i32 %44, %4
  %46 = and i32 %45, 4095
  %47 = zext nneg i32 %46 to i64
  %48 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %47, i32 1
  %49 = load i32, ptr %48, align 8, !tbaa !14
  %50 = sitofp i32 %49 to double
  %51 = fadd double %43, %50
  %52 = or disjoint i32 %44, 1
  %53 = add nsw i32 %52, %4
  %54 = and i32 %53, 4095
  %55 = zext nneg i32 %54 to i64
  %56 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %55, i32 1
  %57 = load i32, ptr %56, align 8, !tbaa !14
  %58 = sitofp i32 %57 to double
  %59 = fadd double %51, %58
  %60 = add nuw nsw i32 %44, 2
  %61 = icmp eq i32 %60, 256
  br i1 %61, label %114, label %42, !llvm.loop !54

62:                                               ; preds = %2
  %63 = getelementptr inbounds [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %8
  switch i8 %9, label %93 [
    i8 0, label %64
    i8 1, label %73
    i8 2, label %85
  ]

64:                                               ; preds = %62
  %65 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %66 = load double, ptr %65, align 8, !tbaa !52
  store double %66, ptr %63, align 16, !tbaa !10
  %67 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %68 = load i32, ptr %67, align 8, !tbaa !53
  %69 = getelementptr inbounds nuw i8, ptr %63, i64 8
  %70 = load <2 x i32>, ptr %69, align 8, !tbaa !35
  %71 = insertelement <2 x i32> <i32 poison, i32 1>, i32 %68, i64 0
  %72 = add nsw <2 x i32> %70, %71
  store <2 x i32> %72, ptr %69, align 8, !tbaa !35
  br label %93

73:                                               ; preds = %62
  %74 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %75 = load i32, ptr %74, align 8, !tbaa !53
  %76 = getelementptr inbounds nuw i8, ptr %63, i64 8
  %77 = load i32, ptr %76, align 8, !tbaa !14
  %78 = sub nsw i32 %77, %75
  %79 = tail call i32 @llvm.smax.i32(i32 %78, i32 0)
  store i32 %79, ptr %76, align 8, !tbaa !14
  %80 = getelementptr inbounds nuw i8, ptr %63, i64 12
  %81 = load i32, ptr %80, align 4, !tbaa !15
  %82 = icmp sgt i32 %81, 0
  br i1 %82, label %83, label %93

83:                                               ; preds = %73
  %84 = add nsw i32 %81, -1
  store i32 %84, ptr %80, align 4, !tbaa !15
  br label %93

85:                                               ; preds = %62
  %86 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %87 = load i32, ptr %86, align 8, !tbaa !53
  %88 = getelementptr inbounds nuw i8, ptr %63, i64 8
  %89 = load i32, ptr %88, align 8, !tbaa !14
  %90 = add nsw i32 %89, %87
  store i32 %90, ptr %88, align 8, !tbaa !14
  %91 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %92 = load double, ptr %91, align 8, !tbaa !52
  store double %92, ptr %63, align 16, !tbaa !10
  br label %93

93:                                               ; preds = %73, %83, %62, %85, %64
  br label %94

94:                                               ; preds = %94, %93
  %95 = phi double [ 0.000000e+00, %93 ], [ %111, %94 ]
  %96 = phi i32 [ 0, %93 ], [ %112, %94 ]
  %97 = add nsw i32 %96, %4
  %98 = and i32 %97, 4095
  %99 = zext nneg i32 %98 to i64
  %100 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %99, i32 1
  %101 = load i32, ptr %100, align 8, !tbaa !14
  %102 = sitofp i32 %101 to double
  %103 = fadd double %95, %102
  %104 = or disjoint i32 %96, 1
  %105 = add nsw i32 %104, %4
  %106 = and i32 %105, 4095
  %107 = zext nneg i32 %106 to i64
  %108 = getelementptr inbounds nuw [4096 x %struct.OrderBookLevel], ptr @asks, i64 0, i64 %107, i32 1
  %109 = load i32, ptr %108, align 8, !tbaa !14
  %110 = sitofp i32 %109 to double
  %111 = fadd double %103, %110
  %112 = add nuw nsw i32 %96, 2
  %113 = icmp eq i32 %112, 256
  br i1 %113, label %114, label %94, !llvm.loop !55

114:                                              ; preds = %94, %42
  %115 = phi double [ %59, %42 ], [ %111, %94 ]
  %116 = load double, ptr %0, align 8, !tbaa !5
  %117 = tail call double @llvm.fmuladd.f64(double %115, double 1.000000e-10, double %116)
  store double %117, ptr %0, align 8, !tbaa !5
  %118 = atomicrmw add ptr @seq_no, i64 1 monotonic, align 8
  ret void
}

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8), i32 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #6

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #7

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(ptr noundef) local_unnamed_addr #8

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #9

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #10

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %0) local_unnamed_addr #11 comdat align 2 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 2496
  %3 = load i64, ptr %2, align 8, !tbaa !24
  %4 = icmp ugt i64 %3, 311
  br i1 %4, label %5, label %86

5:                                                ; preds = %1
  %6 = load i64, ptr %0, align 8, !tbaa !20
  %7 = insertelement <2 x i64> poison, i64 %6, i64 1
  br label %8

8:                                                ; preds = %8, %5
  %9 = phi i64 [ 0, %5 ], [ %28, %8 ]
  %10 = phi <2 x i64> [ %7, %5 ], [ %14, %8 ]
  %11 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %9
  %12 = or disjoint i64 %9, 1
  %13 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %12
  %14 = load <2 x i64>, ptr %13, align 8, !tbaa !20
  %15 = shufflevector <2 x i64> %10, <2 x i64> %14, <2 x i32> <i32 1, i32 2>
  %16 = and <2 x i64> %15, splat (i64 -2147483648)
  %17 = and <2 x i64> %14, splat (i64 2147483646)
  %18 = or disjoint <2 x i64> %17, %16
  %19 = add nuw nsw i64 %9, 156
  %20 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %19
  %21 = load <2 x i64>, ptr %20, align 8, !tbaa !20
  %22 = lshr exact <2 x i64> %18, splat (i64 1)
  %23 = xor <2 x i64> %22, %21
  %24 = and <2 x i64> %14, splat (i64 1)
  %25 = icmp eq <2 x i64> %24, zeroinitializer
  %26 = select <2 x i1> %25, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %27 = xor <2 x i64> %23, %26
  store <2 x i64> %27, ptr %11, align 8, !tbaa !20
  %28 = add nuw i64 %9, 2
  %29 = icmp eq i64 %28, 156
  br i1 %29, label %30, label %8, !llvm.loop !56

30:                                               ; preds = %8
  %31 = getelementptr inbounds nuw i8, ptr %0, i64 1248
  %32 = load i64, ptr %31, align 8, !tbaa !20
  %33 = insertelement <2 x i64> poison, i64 %32, i64 1
  br label %34

34:                                               ; preds = %34, %30
  %35 = phi i64 [ 0, %30 ], [ %54, %34 ]
  %36 = phi <2 x i64> [ %33, %30 ], [ %41, %34 ]
  %37 = add i64 %35, 156
  %38 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %37
  %39 = add i64 %35, 157
  %40 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %39
  %41 = load <2 x i64>, ptr %40, align 8, !tbaa !20
  %42 = shufflevector <2 x i64> %36, <2 x i64> %41, <2 x i32> <i32 1, i32 2>
  %43 = and <2 x i64> %42, splat (i64 -2147483648)
  %44 = and <2 x i64> %41, splat (i64 2147483646)
  %45 = or disjoint <2 x i64> %44, %43
  %46 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %35
  %47 = load <2 x i64>, ptr %46, align 8, !tbaa !20
  %48 = lshr exact <2 x i64> %45, splat (i64 1)
  %49 = xor <2 x i64> %48, %47
  %50 = and <2 x i64> %41, splat (i64 1)
  %51 = icmp eq <2 x i64> %50, zeroinitializer
  %52 = select <2 x i1> %51, <2 x i64> zeroinitializer, <2 x i64> splat (i64 -5403634167711393303)
  %53 = xor <2 x i64> %49, %52
  store <2 x i64> %53, ptr %38, align 8, !tbaa !20
  %54 = add nuw i64 %35, 2
  %55 = icmp eq i64 %54, 154
  br i1 %55, label %56, label %34, !llvm.loop !57

56:                                               ; preds = %34
  %57 = extractelement <2 x i64> %41, i64 1
  %58 = getelementptr inbounds nuw i8, ptr %0, i64 2480
  %59 = and i64 %57, -2147483648
  %60 = getelementptr inbounds nuw i8, ptr %0, i64 2488
  %61 = load i64, ptr %60, align 8, !tbaa !20
  %62 = and i64 %61, 2147483646
  %63 = or disjoint i64 %62, %59
  %64 = getelementptr inbounds nuw i8, ptr %0, i64 1232
  %65 = load i64, ptr %64, align 8, !tbaa !20
  %66 = lshr exact i64 %63, 1
  %67 = xor i64 %66, %65
  %68 = and i64 %61, 1
  %69 = icmp eq i64 %68, 0
  %70 = select i1 %69, i64 0, i64 -5403634167711393303
  %71 = xor i64 %67, %70
  store i64 %71, ptr %58, align 8, !tbaa !20
  %72 = getelementptr inbounds nuw i8, ptr %0, i64 2488
  %73 = load i64, ptr %72, align 8, !tbaa !20
  %74 = and i64 %73, -2147483648
  %75 = load i64, ptr %0, align 8, !tbaa !20
  %76 = and i64 %75, 2147483646
  %77 = or disjoint i64 %76, %74
  %78 = getelementptr inbounds nuw i8, ptr %0, i64 1240
  %79 = load i64, ptr %78, align 8, !tbaa !20
  %80 = lshr exact i64 %77, 1
  %81 = xor i64 %80, %79
  %82 = and i64 %75, 1
  %83 = icmp eq i64 %82, 0
  %84 = select i1 %83, i64 0, i64 -5403634167711393303
  %85 = xor i64 %81, %84
  store i64 %85, ptr %72, align 8, !tbaa !20
  br label %86

86:                                               ; preds = %56, %1
  %87 = phi i64 [ 0, %56 ], [ %3, %1 ]
  %88 = add nuw nsw i64 %87, 1
  store i64 %88, ptr %2, align 8, !tbaa !24
  %89 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %87
  %90 = load i64, ptr %89, align 8, !tbaa !20
  %91 = lshr i64 %90, 29
  %92 = and i64 %91, 22906492245
  %93 = xor i64 %92, %90
  %94 = shl i64 %93, 17
  %95 = and i64 %94, 8202884508482404352
  %96 = xor i64 %95, %93
  %97 = shl i64 %96, 37
  %98 = and i64 %97, -2270628950310912
  %99 = xor i64 %98, %96
  %100 = lshr i64 %99, 43
  %101 = xor i64 %100, %99
  ret i64 %101
}

; Function Attrs: nounwind
declare double @nextafter(double noundef, double noundef) local_unnamed_addr #1

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8), ptr noundef, i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), double noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_orderbook.cpp() #12 section ".text.startup" {
  tail call void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %1 = tail call i32 @__cxa_atexit(ptr nonnull @_ZNSt8ios_base4InitD1Ev, ptr nonnull @_ZStL8__ioinit, ptr nonnull @__dso_handle) #16
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #13

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare x86_fp80 @llvm.log.f80(x86_fp80) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #14

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #15

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #14

attributes #0 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind }
attributes #3 = { mustprogress norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { inlinehint mustprogress nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #7 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #11 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #14 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #15 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #16 = { nounwind }
attributes #17 = { builtin allocsize(0) }
attributes #18 = { noreturn }
attributes #19 = { builtin nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 20.1.8 (https://github.com/llvm/llvm-project.git 87f0227cb60147a26a1eeb4fb06e3b505e9c7261)"}
!5 = !{!6, !7, i64 0}
!6 = !{!"_ZTS6Engine", !7, i64 0}
!7 = !{!"double", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!11, !7, i64 0}
!11 = !{!"_ZTS14OrderBookLevel", !7, i64 0, !12, i64 8, !12, i64 12, !13, i64 16, !12, i64 24, !12, i64 28, !7, i64 32, !7, i64 40, !7, i64 48, !7, i64 56, !8, i64 64, !8, i64 8256}
!12 = !{!"int", !8, i64 0}
!13 = !{!"long", !8, i64 0}
!14 = !{!11, !12, i64 8}
!15 = !{!11, !12, i64 12}
!16 = !{!11, !13, i64 16}
!17 = !{!11, !12, i64 24}
!18 = !{!11, !12, i64 28}
!19 = !{!7, !7, i64 0}
!20 = !{!13, !13, i64 0}
!21 = distinct !{!21, !22}
!22 = !{!"llvm.loop.mustprogress"}
!23 = distinct !{!23, !22}
!24 = !{!25, !13, i64 2496}
!25 = !{!"_ZTSSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE", !8, i64 0, !13, i64 2496}
!26 = distinct !{!26, !22, !27, !28}
!27 = !{!"llvm.loop.isvectorized", i32 1}
!28 = !{!"llvm.loop.unroll.runtime.disable"}
!29 = distinct !{!29, !22, !27, !28}
!30 = distinct !{!30, !22}
!31 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!32 = distinct !{!32, !22, !27, !28}
!33 = distinct !{!33, !22, !27, !28}
!34 = distinct !{!34, !22}
!35 = !{!12, !12, i64 0}
!36 = distinct !{!36, !22, !27, !28}
!37 = distinct !{!37, !22, !27, !28}
!38 = distinct !{!38, !22, !27, !28}
!39 = distinct !{!39, !22, !27, !28}
!40 = !{!41, !41, i64 0}
!41 = !{!"_ZTS7MsgType", !8, i64 0}
!42 = !{!43, !43, i64 0}
!43 = !{!"bool", !8, i64 0}
!44 = distinct !{!44, !22}
!45 = !{!46, !12, i64 4}
!46 = !{!"_ZTS7Message", !41, i64 0, !43, i64 1, !12, i64 4, !12, i64 8, !7, i64 16}
!47 = !{!46, !43, i64 1}
!48 = !{i8 0, i8 2}
!49 = !{}
!50 = distinct !{!50, !22}
!51 = !{!46, !41, i64 0}
!52 = !{!46, !7, i64 16}
!53 = !{!46, !12, i64 8}
!54 = distinct !{!54, !22}
!55 = distinct !{!55, !22}
!56 = distinct !{!56, !22, !27, !28}
!57 = distinct !{!57, !22, !27, !28}
