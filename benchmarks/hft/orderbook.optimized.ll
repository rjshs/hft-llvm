; ModuleID = 'orderbook.bc'
source_filename = "orderbook.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%"class.std::basic_ostream" = type { ptr, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", ptr, i8, i8, ptr, ptr, ptr, ptr }
%"class.std::ios_base" = type { ptr, i64, i64, i32, i32, i32, ptr, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, ptr, %"class.std::locale" }
%"struct.std::ios_base::_Words" = type { ptr, i64 }
%"class.std::locale" = type { ptr }
%class.MarketDataHandler = type { %class.OrderBook, [48 x i8], %struct.BookStatistics }
%class.OrderBook = type { %class.BookSide, %class.BookSide }
%class.BookSide = type { i8, i32, %"struct.std::array" }
%"struct.std::array" = type { [256 x %struct.PriceLevel] }
%struct.PriceLevel = type { i64, i32, i32, %"struct.std::array.2" }
%"struct.std::array.2" = type { [64 x %struct.Order] }
%struct.Order = type { i64, i32, i64 }
%struct.BookStatistics = type { %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic.0", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic", %"struct.std::atomic.0", %"struct.std::atomic.0", %"struct.std::atomic.0", [48 x i8] }
%"struct.std::atomic" = type { %"struct.std::__atomic_base" }
%"struct.std::__atomic_base" = type { i64 }
%"struct.std::atomic.0" = type { %"struct.std::__atomic_base.1" }
%"struct.std::__atomic_base.1" = type { i64 }
%class.MessageGenerator = type { %"class.std::mersenne_twister_engine" }
%"class.std::mersenne_twister_engine" = type { [312 x i64], i64 }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<MarketDataMessage, std::allocator<MarketDataMessage>>::_Vector_impl" }
%"struct.std::_Vector_base<MarketDataMessage, std::allocator<MarketDataMessage>>::_Vector_impl" = type { %"struct.std::_Vector_base<MarketDataMessage, std::allocator<MarketDataMessage>>::_Vector_impl_data" }
%"struct.std::_Vector_base<MarketDataMessage, std::allocator<MarketDataMessage>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%"class.std::discrete_distribution" = type { %"struct.std::discrete_distribution<>::param_type" }
%"struct.std::discrete_distribution<>::param_type" = type { %"class.std::vector.4", %"class.std::vector.4" }
%"class.std::vector.4" = type { %"struct.std::_Vector_base.5" }
%"struct.std::_Vector_base.5" = type { %"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl" }
%"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl" = type { %"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl_data" }
%"struct.std::_Vector_base<double, std::allocator<double>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%struct.MarketDataMessage = type <{ i8, i8, i16, i64, i64, i32, i64, i64 }>

$_ZN17MarketDataHandlerC2Ev = comdat any

$_ZN16MessageGenerator8generateEi = comdat any

$_ZN17MarketDataHandler9onMessageERK17MarketDataMessage = comdat any

$_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv = comdat any

$_ZNSt21discrete_distributionIiED2Ev = comdat any

$_ZNSt21discrete_distributionIiE10param_typeC2ESt16initializer_listIdE = comdat any

$_ZNSt21discrete_distributionIiE10param_type13_M_initializeEv = comdat any

$_ZSt11partial_sumIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEESt20back_insert_iteratorIS5_EET0_T_SA_S9_ = comdat any

$_ZN17MarketDataHandler9handleAddERK17MarketDataMessage = comdat any

$_ZN17MarketDataHandler12handleModifyERK17MarketDataMessage = comdat any

$_ZN8BookSide11removeOrderElmi = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@.str = private unnamed_addr constant [26 x i8] c"\0A=== Book Statistics ===\0A\00", align 1
@.str.1 = private unnamed_addr constant [21 x i8] c"Messages processed: \00", align 1
@.str.2 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@.str.3 = private unnamed_addr constant [13 x i8] c"  Adds:     \00", align 1
@.str.4 = private unnamed_addr constant [13 x i8] c"  Cancels:  \00", align 1
@.str.5 = private unnamed_addr constant [13 x i8] c"  Modifies: \00", align 1
@.str.6 = private unnamed_addr constant [13 x i8] c"  Executes: \00", align 1
@.str.7 = private unnamed_addr constant [9 x i8] c"Errors:\0A\00", align 1
@.str.8 = private unnamed_addr constant [15 x i8] c"  Invalid:    \00", align 1
@.str.9 = private unnamed_addr constant [15 x i8] c"  Book full:  \00", align 1
@.str.10 = private unnamed_addr constant [15 x i8] c"  Not found:  \00", align 1
@.str.11 = private unnamed_addr constant [10 x i8] c"Trading:\0A\00", align 1
@.str.12 = private unnamed_addr constant [17 x i8] c"  Total volume: \00", align 1
@.str.13 = private unnamed_addr constant [17 x i8] c"  Net volume:   \00", align 1
@.str.14 = private unnamed_addr constant [13 x i8] c"Book state:\0A\00", align 1
@.str.15 = private unnamed_addr constant [14 x i8] c"  Best bid:  \00", align 1
@.str.16 = private unnamed_addr constant [14 x i8] c"  Best ask:  \00", align 1
@.str.17 = private unnamed_addr constant [14 x i8] c"  Spread:    \00", align 1
@.str.18 = private unnamed_addr constant [8 x i8] c" ticks\0A\00", align 1
@.str.19 = private unnamed_addr constant [10 x i8] c"Latency:\0A\00", align 1
@.str.20 = private unnamed_addr constant [8 x i8] c"  Avg: \00", align 1
@.str.21 = private unnamed_addr constant [5 x i8] c" ns\0A\00", align 1
@.str.22 = private unnamed_addr constant [8 x i8] c"  Max: \00", align 1
@.str.23 = private unnamed_addr constant [45 x i8] c"===========================================\0A\00", align 1
@.str.24 = private unnamed_addr constant [45 x i8] c"HFT Order Book Engine - Atomic Elision Demo\0A\00", align 1
@.str.25 = private unnamed_addr constant [16 x i8] c"Configuration:\0A\00", align 1
@.str.26 = private unnamed_addr constant [17 x i8] c"  Messages:     \00", align 1
@.str.27 = private unnamed_addr constant [17 x i8] c"  Price levels: \00", align 1
@.str.28 = private unnamed_addr constant [18 x i8] c"  Tick size:    $\00", align 1
@.str.29 = private unnamed_addr constant [36 x i8] c"Generating market data messages...\0A\00", align 1
@.str.30 = private unnamed_addr constant [24 x i8] c"Processing messages...\0A\00", align 1
@.str.31 = private unnamed_addr constant [30 x i8] c"\0A=== Performance Results ===\0A\00", align 1
@.str.32 = private unnamed_addr constant [13 x i8] c"Time:       \00", align 1
@.str.33 = private unnamed_addr constant [5 x i8] c" ms\0A\00", align 1
@.str.34 = private unnamed_addr constant [13 x i8] c"Throughput: \00", align 1
@.str.35 = private unnamed_addr constant [13 x i8] c" M msgs/sec\0A\00", align 1
@.str.36 = private unnamed_addr constant [13 x i8] c"Latency:    \00", align 1
@.str.37 = private unnamed_addr constant [9 x i8] c" ns/msg\0A\00", align 1
@constinit = private unnamed_addr constant [4 x double] [double 6.000000e+01, double 2.500000e+01, double 1.000000e+01, double 5.000000e+00], align 8
@.str.38 = private unnamed_addr constant [16 x i8] c"vector::reserve\00", align 1
@.str.40 = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_orderbook.cpp, ptr null }]

declare void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #0

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) local_unnamed_addr #2

; Function Attrs: mustprogress uwtable
define dso_local void @_Z15printStatisticsRK14BookStatistics(ptr nocapture noundef nonnull readonly align 64 dereferenceable(144) %0) local_unnamed_addr #3 {
  %2 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str, i64 noundef 25)
  %3 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.1, i64 noundef 20)
  %4 = load i64, ptr %0, align 64
  %5 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %4)
  %6 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %5, ptr noundef nonnull @.str.2, i64 noundef 1)
  %7 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.3, i64 noundef 12)
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %9 = load i64, ptr %8, align 8
  %10 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %9)
  %11 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %10, ptr noundef nonnull @.str.2, i64 noundef 1)
  %12 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.4, i64 noundef 12)
  %13 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %14 = load i64, ptr %13, align 16
  %15 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %14)
  %16 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %15, ptr noundef nonnull @.str.2, i64 noundef 1)
  %17 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.5, i64 noundef 12)
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %19 = load i64, ptr %18, align 8
  %20 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %19)
  %21 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %20, ptr noundef nonnull @.str.2, i64 noundef 1)
  %22 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.6, i64 noundef 12)
  %23 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %24 = load i64, ptr %23, align 32
  %25 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %24)
  %26 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %25, ptr noundef nonnull @.str.2, i64 noundef 1)
  %27 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  %28 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.7, i64 noundef 8)
  %29 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.8, i64 noundef 14)
  %30 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %31 = load i64, ptr %30, align 8
  %32 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %31)
  %33 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %32, ptr noundef nonnull @.str.2, i64 noundef 1)
  %34 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.9, i64 noundef 14)
  %35 = getelementptr inbounds nuw i8, ptr %0, i64 48
  %36 = load i64, ptr %35, align 16
  %37 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %36)
  %38 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %37, ptr noundef nonnull @.str.2, i64 noundef 1)
  %39 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.10, i64 noundef 14)
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 56
  %41 = load i64, ptr %40, align 8
  %42 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %41)
  %43 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %42, ptr noundef nonnull @.str.2, i64 noundef 1)
  %44 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  %45 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.11, i64 noundef 9)
  %46 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.12, i64 noundef 16)
  %47 = getelementptr inbounds nuw i8, ptr %0, i64 64
  %48 = load i64, ptr %47, align 64
  %49 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %48)
  %50 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %49, ptr noundef nonnull @.str.2, i64 noundef 1)
  %51 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.13, i64 noundef 16)
  %52 = getelementptr inbounds nuw i8, ptr %0, i64 72
  %53 = load i64, ptr %52, align 8
  %54 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %53)
  %55 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %54, ptr noundef nonnull @.str.2, i64 noundef 1)
  %56 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  %57 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.14, i64 noundef 12)
  %58 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.15, i64 noundef 13)
  %59 = getelementptr inbounds nuw i8, ptr %0, i64 120
  %60 = load i64, ptr %59, align 8
  %61 = sitofp i64 %60 to double
  %62 = fmul double %61, 1.000000e-02
  %63 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %62)
  %64 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %63, ptr noundef nonnull @.str.2, i64 noundef 1)
  %65 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.16, i64 noundef 13)
  %66 = getelementptr inbounds nuw i8, ptr %0, i64 128
  %67 = load i64, ptr %66, align 64
  %68 = sitofp i64 %67 to double
  %69 = fmul double %68, 1.000000e-02
  %70 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %69)
  %71 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %70, ptr noundef nonnull @.str.2, i64 noundef 1)
  %72 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.17, i64 noundef 13)
  %73 = getelementptr inbounds nuw i8, ptr %0, i64 136
  %74 = load i64, ptr %73, align 8
  %75 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %74)
  %76 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %75, ptr noundef nonnull @.str.18, i64 noundef 7)
  %77 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  %78 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.19, i64 noundef 9)
  %79 = load i64, ptr %0, align 64
  %80 = icmp eq i64 %79, 0
  br i1 %80, label %88, label %81

81:                                               ; preds = %1
  %82 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.20, i64 noundef 7)
  %83 = getelementptr inbounds nuw i8, ptr %0, i64 112
  %84 = load i64, ptr %83, align 16
  %85 = udiv i64 %84, %79
  %86 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %85)
  %87 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %86, ptr noundef nonnull @.str.21, i64 noundef 4)
  br label %88

88:                                               ; preds = %81, %1
  %89 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.22, i64 noundef 7)
  %90 = getelementptr inbounds nuw i8, ptr %0, i64 104
  %91 = load i64, ptr %90, align 8
  %92 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %91)
  %93 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %92, ptr noundef nonnull @.str.21, i64 noundef 4)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: mustprogress norecurse uwtable
define dso_local noundef i32 @main() local_unnamed_addr #5 personality ptr @__gxx_personality_v0 {
  %1 = alloca %class.MarketDataHandler, align 64
  %2 = alloca %class.MessageGenerator, align 8
  %3 = alloca %"class.std::vector", align 8
  %4 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.23, i64 noundef 44)
  %5 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.24, i64 noundef 44)
  %6 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.23, i64 noundef 44)
  %7 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  %8 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.25, i64 noundef 15)
  %9 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.26, i64 noundef 16)
  %10 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i32 noundef 10000000)
  %11 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %10, ptr noundef nonnull @.str.2, i64 noundef 1)
  %12 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.27, i64 noundef 16)
  %13 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i32 noundef 256)
  %14 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %13, ptr noundef nonnull @.str.2, i64 noundef 1)
  %15 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.28, i64 noundef 17)
  %16 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef 1.000000e-02)
  %17 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %16, ptr noundef nonnull @.str.2, i64 noundef 1)
  %18 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.2, i64 noundef 1)
  call void @llvm.lifetime.start.p0(i64 794880, ptr nonnull %1) #16
  call void @_ZN17MarketDataHandlerC2Ev(ptr noundef nonnull align 64 dereferenceable(794880) %1)
  call void @llvm.lifetime.start.p0(i64 2504, ptr nonnull %2) #16
  store i64 42, ptr %2, align 8, !tbaa !5
  br label %19

19:                                               ; preds = %19, %0
  %20 = phi i64 [ 42, %0 ], [ %25, %19 ]
  %21 = phi i64 [ 1, %0 ], [ %27, %19 ]
  %22 = lshr i64 %20, 62
  %23 = xor i64 %22, %20
  %24 = mul i64 %23, 6364136223846793005
  %25 = add i64 %24, %21
  %26 = getelementptr inbounds nuw [312 x i64], ptr %2, i64 0, i64 %21
  store i64 %25, ptr %26, align 8, !tbaa !5
  %27 = add nuw nsw i64 %21, 1
  %28 = icmp eq i64 %27, 312
  br i1 %28, label %29, label %19, !llvm.loop !9

29:                                               ; preds = %19
  %30 = getelementptr inbounds nuw i8, ptr %2, i64 2496
  store i64 312, ptr %30, align 8, !tbaa !12
  %31 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.29, i64 noundef 35)
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %3) #16
  call void @_ZN16MessageGenerator8generateEi(ptr dead_on_unwind nonnull writable sret(%"class.std::vector") align 8 %3, ptr noundef nonnull align 8 dereferenceable(2504) %2, i32 noundef 10000000)
  %32 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.30, i64 noundef 23)
          to label %33 unwind label %49

33:                                               ; preds = %29
  %34 = call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #16
  %35 = load ptr, ptr %3, align 8, !tbaa !14
  %36 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %37 = load ptr, ptr %36, align 8, !tbaa !14
  %38 = icmp eq ptr %35, %37
  br i1 %38, label %39, label %51

39:                                               ; preds = %53, %33
  %40 = call i64 @_ZNSt6chrono3_V212system_clock3nowEv() #16
  %41 = sub nsw i64 %40, %34
  %42 = sdiv i64 %41, 1000000
  %43 = sitofp i64 %42 to double
  %44 = fdiv double %43, 1.000000e+03
  %45 = fdiv double 1.000000e+07, %44
  %46 = fmul double %43, 1.000000e+06
  %47 = fdiv double %46, 1.000000e+07
  %48 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.31, i64 noundef 29)
          to label %58 unwind label %89

49:                                               ; preds = %29
  %50 = landingpad { ptr, i32 }
          cleanup
  br label %91

51:                                               ; preds = %53, %33
  %52 = phi ptr [ %54, %53 ], [ %35, %33 ]
  invoke void @_ZN17MarketDataHandler9onMessageERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %1, ptr noundef nonnull align 1 dereferenceable(40) %52)
          to label %53 unwind label %56

53:                                               ; preds = %51
  %54 = getelementptr inbounds nuw i8, ptr %52, i64 40
  %55 = icmp eq ptr %54, %37
  br i1 %55, label %39, label %51, !llvm.loop !17

56:                                               ; preds = %51
  %57 = landingpad { ptr, i32 }
          cleanup
  br label %91

58:                                               ; preds = %39
  %59 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.32, i64 noundef 12)
          to label %60 unwind label %89

60:                                               ; preds = %58
  %61 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %42)
          to label %62 unwind label %89

62:                                               ; preds = %60
  %63 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %61, ptr noundef nonnull @.str.33, i64 noundef 4)
          to label %64 unwind label %89

64:                                               ; preds = %62
  %65 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.34, i64 noundef 12)
          to label %66 unwind label %89

66:                                               ; preds = %64
  %67 = fdiv double %45, 1.000000e+06
  %68 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %67)
          to label %69 unwind label %89

69:                                               ; preds = %66
  %70 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %68, ptr noundef nonnull @.str.35, i64 noundef 12)
          to label %71 unwind label %89

71:                                               ; preds = %69
  %72 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, ptr noundef nonnull @.str.36, i64 noundef 12)
          to label %73 unwind label %89

73:                                               ; preds = %71
  %74 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, double noundef %47)
          to label %75 unwind label %89

75:                                               ; preds = %73
  %76 = invoke noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %74, ptr noundef nonnull @.str.37, i64 noundef 8)
          to label %77 unwind label %89

77:                                               ; preds = %75
  %78 = getelementptr inbounds nuw i8, ptr %1, i64 794688
  invoke void @_Z15printStatisticsRK14BookStatistics(ptr noundef nonnull align 64 dereferenceable(144) %78)
          to label %79 unwind label %89

79:                                               ; preds = %77
  %80 = load ptr, ptr %3, align 8, !tbaa !18
  %81 = icmp eq ptr %80, null
  br i1 %81, label %88, label %82

82:                                               ; preds = %79
  %83 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %84 = load ptr, ptr %83, align 8, !tbaa !20
  %85 = ptrtoint ptr %84 to i64
  %86 = ptrtoint ptr %80 to i64
  %87 = sub i64 %85, %86
  call void @_ZdlPvm(ptr noundef nonnull %80, i64 noundef %87) #17
  br label %88

88:                                               ; preds = %82, %79
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3) #16
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %2) #16
  call void @llvm.lifetime.end.p0(i64 794880, ptr nonnull %1) #16
  ret i32 0

89:                                               ; preds = %77, %75, %73, %71, %69, %66, %64, %62, %60, %58, %39
  %90 = landingpad { ptr, i32 }
          cleanup
  br label %91

91:                                               ; preds = %89, %56, %49
  %92 = phi { ptr, i32 } [ %50, %49 ], [ %57, %56 ], [ %90, %89 ]
  %93 = load ptr, ptr %3, align 8, !tbaa !18
  %94 = icmp eq ptr %93, null
  br i1 %94, label %101, label %95

95:                                               ; preds = %91
  %96 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %97 = load ptr, ptr %96, align 8, !tbaa !20
  %98 = ptrtoint ptr %97 to i64
  %99 = ptrtoint ptr %93 to i64
  %100 = sub i64 %98, %99
  call void @_ZdlPvm(ptr noundef nonnull %93, i64 noundef %100) #17
  br label %101

101:                                              ; preds = %95, %91
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %3) #16
  call void @llvm.lifetime.end.p0(i64 2504, ptr nonnull %2) #16
  call void @llvm.lifetime.end.p0(i64 794880, ptr nonnull %1) #16
  resume { ptr, i32 } %92
}

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8), i32 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN17MarketDataHandlerC2Ev(ptr noundef nonnull align 64 dereferenceable(794880) %0) unnamed_addr #3 comdat align 2 personality ptr @__gxx_personality_v0 {
  store i8 1, ptr %0, align 64, !tbaa !21
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i32 0, ptr %2, align 4, !tbaa !26
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 8
  br label %4

4:                                                ; preds = %15, %1
  %5 = phi i64 [ 0, %1 ], [ %16, %15 ]
  %6 = getelementptr inbounds nuw i8, ptr %3, i64 %5
  %7 = getelementptr inbounds nuw i8, ptr %6, i64 16
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %6, i8 0, i64 16, i1 false)
  br label %8

8:                                                ; preds = %8, %4
  %9 = phi i64 [ 0, %4 ], [ %13, %8 ]
  %10 = getelementptr inbounds nuw i8, ptr %7, i64 %9
  store i64 0, ptr %10, align 8, !tbaa !27
  %11 = getelementptr inbounds nuw i8, ptr %10, i64 8
  store i32 0, ptr %11, align 8, !tbaa !29
  %12 = getelementptr inbounds nuw i8, ptr %10, i64 16
  store i64 0, ptr %12, align 8, !tbaa !30
  %13 = add nuw nsw i64 %9, 24
  %14 = icmp eq i64 %13, 1536
  br i1 %14, label %15, label %8

15:                                               ; preds = %8
  %16 = add nuw nsw i64 %5, 1552
  %17 = icmp eq i64 %16, 397312
  br i1 %17, label %18, label %4

18:                                               ; preds = %15
  %19 = getelementptr inbounds nuw i8, ptr %0, i64 397320
  store i8 0, ptr %19, align 8, !tbaa !21
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 397324
  store i32 0, ptr %20, align 4, !tbaa !26
  %21 = getelementptr inbounds nuw i8, ptr %0, i64 397328
  br label %22

22:                                               ; preds = %33, %18
  %23 = phi i64 [ 0, %18 ], [ %34, %33 ]
  %24 = getelementptr inbounds nuw i8, ptr %21, i64 %23
  %25 = getelementptr inbounds nuw i8, ptr %24, i64 16
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(1552) %24, i8 0, i64 16, i1 false)
  br label %26

26:                                               ; preds = %26, %22
  %27 = phi i64 [ 0, %22 ], [ %31, %26 ]
  %28 = getelementptr inbounds nuw i8, ptr %25, i64 %27
  store i64 0, ptr %28, align 8, !tbaa !27
  %29 = getelementptr inbounds nuw i8, ptr %28, i64 8
  store i32 0, ptr %29, align 8, !tbaa !29
  %30 = getelementptr inbounds nuw i8, ptr %28, i64 16
  store i64 0, ptr %30, align 8, !tbaa !30
  %31 = add nuw nsw i64 %27, 24
  %32 = icmp eq i64 %31, 1536
  br i1 %32, label %33, label %26

33:                                               ; preds = %26
  %34 = add nuw nsw i64 %23, 1552
  %35 = icmp eq i64 %34, 397312
  br i1 %35, label %36, label %22

36:                                               ; preds = %33
  %37 = getelementptr inbounds nuw i8, ptr %0, i64 794688
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 64 dereferenceable(144) %37, i8 0, i64 144, i1 false)
  store i64 0, ptr %37, align 64
  %38 = getelementptr inbounds nuw i8, ptr %0, i64 794696
  store i64 0, ptr %38, align 8
  %39 = getelementptr inbounds nuw i8, ptr %0, i64 794704
  store i64 0, ptr %39, align 16
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 794712
  store i64 0, ptr %40, align 8
  %41 = getelementptr inbounds nuw i8, ptr %0, i64 794720
  store i64 0, ptr %41, align 32
  %42 = getelementptr inbounds nuw i8, ptr %0, i64 794728
  store i64 0, ptr %42, align 8
  %43 = getelementptr inbounds nuw i8, ptr %0, i64 794736
  store i64 0, ptr %43, align 16
  %44 = getelementptr inbounds nuw i8, ptr %0, i64 794744
  store i64 0, ptr %44, align 8
  %45 = getelementptr inbounds nuw i8, ptr %0, i64 794752
  store i64 0, ptr %45, align 64
  %46 = getelementptr inbounds nuw i8, ptr %0, i64 794760
  store i64 0, ptr %46, align 8
  %47 = getelementptr inbounds nuw i8, ptr %0, i64 794768
  store i64 0, ptr %47, align 16
  %48 = getelementptr inbounds nuw i8, ptr %0, i64 794776
  store i64 0, ptr %48, align 8
  %49 = getelementptr inbounds nuw i8, ptr %0, i64 794784
  store i64 0, ptr %49, align 32
  %50 = getelementptr inbounds nuw i8, ptr %0, i64 794792
  store i64 0, ptr %50, align 8
  %51 = getelementptr inbounds nuw i8, ptr %0, i64 794800
  store i64 0, ptr %51, align 16
  %52 = getelementptr inbounds nuw i8, ptr %0, i64 794808
  store i64 0, ptr %52, align 8
  %53 = getelementptr inbounds nuw i8, ptr %0, i64 794816
  store i64 0, ptr %53, align 64
  %54 = getelementptr inbounds nuw i8, ptr %0, i64 794824
  store i64 0, ptr %54, align 8
  store i32 0, ptr %2, align 4, !tbaa !26
  br label %55

55:                                               ; preds = %55, %36
  %56 = phi i64 [ 8, %36 ], [ %58, %55 ]
  %57 = getelementptr inbounds nuw i8, ptr %0, i64 %56
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %57, i8 0, i64 16, i1 false)
  %58 = add nuw nsw i64 %56, 1552
  %59 = icmp eq i64 %58, 397320
  br i1 %59, label %60, label %55, !llvm.loop !31

60:                                               ; preds = %55
  store i32 0, ptr %20, align 4, !tbaa !26
  br label %61

61:                                               ; preds = %61, %60
  %62 = phi i64 [ 8, %60 ], [ %64, %61 ]
  %63 = getelementptr inbounds nuw i8, ptr %19, i64 %62
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %63, i8 0, i64 16, i1 false)
  %64 = add nuw nsw i64 %62, 1552
  %65 = icmp eq i64 %64, 397320
  br i1 %65, label %66, label %61, !llvm.loop !31

66:                                               ; preds = %61
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN16MessageGenerator8generateEi(ptr dead_on_unwind noalias writable sret(%"class.std::vector") align 8 %0, ptr noundef nonnull align 8 dereferenceable(2504) %1, i32 noundef %2) local_unnamed_addr #3 comdat align 2 personality ptr @__gxx_personality_v0 {
  %4 = alloca %"class.std::discrete_distribution", align 8
  %5 = alloca [4 x double], align 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  %6 = sext i32 %2 to i64
  %7 = icmp slt i32 %2, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %3
  invoke void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.38) #18
          to label %9 unwind label %79

9:                                                ; preds = %8
  unreachable

10:                                               ; preds = %3
  %11 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %12 = load ptr, ptr %11, align 8, !tbaa !20
  %13 = load ptr, ptr %0, align 8, !tbaa !18
  %14 = ptrtoint ptr %12 to i64
  %15 = ptrtoint ptr %13 to i64
  %16 = sub i64 %14, %15
  %17 = sdiv exact i64 %16, 40
  %18 = icmp ult i64 %17, %6
  br i1 %18, label %19, label %35

19:                                               ; preds = %10
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %21 = load ptr, ptr %20, align 8, !tbaa !32
  %22 = ptrtoint ptr %21 to i64
  %23 = sub i64 %22, %15
  %24 = mul nuw nsw i64 %6, 40
  %25 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %24) #19
          to label %26 unwind label %79

26:                                               ; preds = %19
  %27 = icmp sgt i64 %23, 0
  br i1 %27, label %28, label %29

28:                                               ; preds = %26
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %25, ptr align 1 %13, i64 %23, i1 false)
  br label %29

29:                                               ; preds = %28, %26
  %30 = icmp eq ptr %13, null
  br i1 %30, label %32, label %31

31:                                               ; preds = %29
  tail call void @_ZdlPvm(ptr noundef nonnull %13, i64 noundef %16) #17
  br label %32

32:                                               ; preds = %31, %29
  store ptr %25, ptr %0, align 8, !tbaa !18
  %33 = getelementptr inbounds nuw i8, ptr %25, i64 %23
  store ptr %33, ptr %20, align 8, !tbaa !32
  %34 = getelementptr inbounds nuw %struct.MarketDataMessage, ptr %25, i64 %6
  store ptr %34, ptr %11, align 8, !tbaa !20
  br label %35

35:                                               ; preds = %32, %10
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %4) #16
  call void @llvm.lifetime.start.p0(i64 32, ptr nonnull %5) #16
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(32) %5, ptr noundef nonnull align 8 dereferenceable(32) @constinit, i64 32, i1 false), !tbaa.struct !33
  invoke void @_ZNSt21discrete_distributionIiE10param_typeC2ESt16initializer_listIdE(ptr noundef nonnull align 8 dereferenceable(48) %4, ptr nonnull %5, i64 4)
          to label %36 unwind label %81

36:                                               ; preds = %35
  call void @llvm.lifetime.end.p0(i64 32, ptr nonnull %5) #16
  %37 = load ptr, ptr %11, align 8
  %38 = load ptr, ptr %0, align 8
  %39 = icmp eq i32 %2, 0
  br i1 %39, label %57, label %40

40:                                               ; preds = %36
  %41 = getelementptr inbounds nuw i8, ptr %4, i64 24
  %42 = getelementptr inbounds nuw i8, ptr %4, i64 32
  %43 = call x86_fp80 @llvm.log.f80(x86_fp80 0xK403F8000000000000000)
  %44 = call x86_fp80 @llvm.log.f80(x86_fp80 0xK40008000000000000000)
  %45 = fdiv x86_fp80 %43, %44
  %46 = fptoui x86_fp80 %45 to i64
  %47 = add i64 %46, 52
  %48 = call x86_fp80 @llvm.log.f80(x86_fp80 0xK403F8000000000000000)
  %49 = call x86_fp80 @llvm.log.f80(x86_fp80 0xK40008000000000000000)
  %50 = fdiv x86_fp80 %48, %49
  %51 = fptoui x86_fp80 %50 to i64
  %52 = add i64 %51, 52
  %53 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %54 = call i32 @llvm.smax.i32(i32 %2, i32 1)
  %55 = add nuw i32 %54, 1
  %56 = zext i32 %55 to i64
  br label %83

57:                                               ; preds = %284, %36
  %58 = phi ptr [ %38, %36 ], [ %285, %284 ]
  %59 = phi ptr [ %37, %36 ], [ %286, %284 ]
  store ptr %59, ptr %11, align 8
  store ptr %58, ptr %0, align 8
  %60 = getelementptr inbounds nuw i8, ptr %4, i64 24
  %61 = load ptr, ptr %60, align 8, !tbaa !35
  %62 = icmp eq ptr %61, null
  br i1 %62, label %69, label %63

63:                                               ; preds = %57
  %64 = getelementptr inbounds nuw i8, ptr %4, i64 40
  %65 = load ptr, ptr %64, align 8, !tbaa !38
  %66 = ptrtoint ptr %65 to i64
  %67 = ptrtoint ptr %61 to i64
  %68 = sub i64 %66, %67
  call void @_ZdlPvm(ptr noundef nonnull %61, i64 noundef %68) #17
  br label %69

69:                                               ; preds = %63, %57
  %70 = load ptr, ptr %4, align 8, !tbaa !35
  %71 = icmp eq ptr %70, null
  br i1 %71, label %78, label %72

72:                                               ; preds = %69
  %73 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %74 = load ptr, ptr %73, align 8, !tbaa !38
  %75 = ptrtoint ptr %74 to i64
  %76 = ptrtoint ptr %70 to i64
  %77 = sub i64 %75, %76
  call void @_ZdlPvm(ptr noundef nonnull %70, i64 noundef %77) #17
  br label %78

78:                                               ; preds = %72, %69
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %4) #16
  ret void

79:                                               ; preds = %19, %8
  %80 = landingpad { ptr, i32 }
          cleanup
  br label %293

81:                                               ; preds = %35
  %82 = landingpad { ptr, i32 }
          cleanup
  call void @llvm.lifetime.end.p0(i64 32, ptr nonnull %5) #16
  br label %291

83:                                               ; preds = %284, %40
  %84 = phi i64 [ 1, %40 ], [ %231, %284 ]
  %85 = phi i64 [ 1000000000000, %40 ], [ %287, %284 ]
  %86 = phi ptr [ %37, %40 ], [ %286, %284 ]
  %87 = phi ptr [ %38, %40 ], [ %285, %284 ]
  %88 = load ptr, ptr %41, align 8, !tbaa !39
  %89 = load ptr, ptr %42, align 8, !tbaa !39
  %90 = icmp eq ptr %88, %89
  br i1 %90, label %140, label %91

91:                                               ; preds = %83
  %92 = udiv i64 %47, %46
  %93 = call i64 @llvm.umax.i64(i64 %92, i64 1)
  br label %97

94:                                               ; preds = %102
  %95 = fdiv double %104, %107
  %96 = fcmp ult double %95, 1.000000e+00
  br i1 %96, label %112, label %110, !prof !40

97:                                               ; preds = %102, %91
  %98 = phi i64 [ %93, %91 ], [ %108, %102 ]
  %99 = phi double [ 1.000000e+00, %91 ], [ %107, %102 ]
  %100 = phi double [ 0.000000e+00, %91 ], [ %104, %102 ]
  %101 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %102 unwind label %151

102:                                              ; preds = %97
  %103 = uitofp i64 %101 to double
  %104 = call double @llvm.fmuladd.f64(double %103, double %99, double %100)
  %105 = fpext double %99 to x86_fp80
  %106 = fmul x86_fp80 %105, 0xK403F8000000000000000
  %107 = fptrunc x86_fp80 %106 to double
  %108 = add i64 %98, -1
  %109 = icmp eq i64 %108, 0
  br i1 %109, label %94, label %97, !llvm.loop !41

110:                                              ; preds = %94
  %111 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #16, !tbaa !42
  br label %112

112:                                              ; preds = %110, %94
  %113 = phi double [ %111, %110 ], [ %95, %94 ]
  %114 = load ptr, ptr %41, align 8, !tbaa !39
  %115 = load ptr, ptr %42, align 8, !tbaa !39
  %116 = ptrtoint ptr %115 to i64
  %117 = ptrtoint ptr %114 to i64
  %118 = sub i64 %116, %117
  %119 = ashr exact i64 %118, 3
  %120 = icmp sgt i64 %119, 0
  br i1 %120, label %121, label %134

121:                                              ; preds = %121, %112
  %122 = phi i64 [ %132, %121 ], [ %119, %112 ]
  %123 = phi ptr [ %131, %121 ], [ %114, %112 ]
  %124 = lshr i64 %122, 1
  %125 = getelementptr inbounds nuw double, ptr %123, i64 %124
  %126 = load double, ptr %125, align 8, !tbaa !43
  %127 = fcmp olt double %126, %113
  %128 = getelementptr inbounds nuw i8, ptr %125, i64 8
  %129 = xor i64 %124, -1
  %130 = add nsw i64 %122, %129
  %131 = select i1 %127, ptr %128, ptr %123
  %132 = select i1 %127, i64 %130, i64 %124
  %133 = icmp sgt i64 %132, 0
  br i1 %133, label %121, label %134, !llvm.loop !45

134:                                              ; preds = %121, %112
  %135 = phi ptr [ %114, %112 ], [ %131, %121 ]
  %136 = ptrtoint ptr %135 to i64
  %137 = sub i64 %136, %117
  %138 = lshr exact i64 %137, 3
  %139 = trunc i64 %138 to i32
  br label %140

140:                                              ; preds = %134, %83
  %141 = phi i32 [ %139, %134 ], [ 0, %83 ]
  %142 = icmp ult i32 %141, 4
  %143 = shl nuw nsw i32 %141, 3
  %144 = lshr i32 1162696769, %143
  %145 = trunc i32 %144 to i8
  %146 = select i1 %142, i8 %145, i8 0
  %147 = udiv i64 %52, %51
  %148 = call i64 @llvm.umax.i64(i64 %147, i64 1)
  br label %156

149:                                              ; preds = %156
  %150 = landingpad { ptr, i32 }
          cleanup
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  br label %289

151:                                              ; preds = %97
  %152 = landingpad { ptr, i32 }
          cleanup
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  br label %289

153:                                              ; preds = %161
  %154 = fdiv double %163, %166
  %155 = fcmp ult double %154, 1.000000e+00
  br i1 %155, label %171, label %169, !prof !40

156:                                              ; preds = %161, %140
  %157 = phi i64 [ %148, %140 ], [ %167, %161 ]
  %158 = phi double [ 1.000000e+00, %140 ], [ %166, %161 ]
  %159 = phi double [ 0.000000e+00, %140 ], [ %163, %161 ]
  %160 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %161 unwind label %149

161:                                              ; preds = %156
  %162 = uitofp i64 %160 to double
  %163 = call double @llvm.fmuladd.f64(double %162, double %158, double %159)
  %164 = fpext double %158 to x86_fp80
  %165 = fmul x86_fp80 %164, 0xK403F8000000000000000
  %166 = fptrunc x86_fp80 %165 to double
  %167 = add i64 %157, -1
  %168 = icmp eq i64 %167, 0
  br i1 %168, label %153, label %156, !llvm.loop !41

169:                                              ; preds = %153
  %170 = call double @nextafter(double noundef 1.000000e+00, double noundef 0.000000e+00) #16, !tbaa !42
  br label %171

171:                                              ; preds = %169, %153
  %172 = phi double [ %170, %169 ], [ %154, %153 ]
  %173 = fcmp olt double %172, 5.000000e-01
  %174 = select i1 %173, i8 66, i8 83
  %175 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %176 unwind label %207

176:                                              ; preds = %171
  %177 = zext i64 %175 to i128
  %178 = mul nuw nsw i128 %177, 101
  %179 = trunc i128 %178 to i64
  %180 = lshr i128 %178, 64
  %181 = trunc nuw nsw i128 %180 to i32
  %182 = icmp ult i64 %179, 79
  br i1 %182, label %183, label %193

183:                                              ; preds = %185, %176
  %184 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %185 unwind label %205

185:                                              ; preds = %183
  %186 = zext i64 %184 to i128
  %187 = mul nuw nsw i128 %186, 101
  %188 = trunc i128 %187 to i64
  %189 = icmp ult i64 %188, 79
  br i1 %189, label %183, label %190, !llvm.loop !46

190:                                              ; preds = %185
  %191 = lshr i128 %187, 64
  %192 = trunc nuw nsw i128 %191 to i32
  br label %193

193:                                              ; preds = %190, %176
  %194 = phi i32 [ %181, %176 ], [ %192, %190 ]
  %195 = add nsw i32 %194, -50
  %196 = call i32 @llvm.abs.i32(i32 %195, i1 true)
  %197 = zext nneg i32 %196 to i64
  %198 = sub nuw nsw i64 10000, %197
  %199 = add nuw nsw i32 %196, 10000
  %200 = zext nneg i32 %199 to i64
  %201 = select i1 %173, i64 %198, i64 %200
  %202 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %211 unwind label %207

203:                                              ; preds = %218
  %204 = landingpad { ptr, i32 }
          cleanup
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  br label %289

205:                                              ; preds = %183
  %206 = landingpad { ptr, i32 }
          cleanup
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  br label %289

207:                                              ; preds = %255, %228, %193, %171
  %208 = landingpad { ptr, i32 }
          cleanup
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  br label %289

209:                                              ; preds = %253
  %210 = landingpad { ptr, i32 }
          cleanup
  br label %289

211:                                              ; preds = %193
  %212 = zext i64 %202 to i128
  %213 = mul nuw nsw i128 %212, 1000
  %214 = trunc i128 %213 to i64
  %215 = lshr i128 %213, 64
  %216 = trunc nuw nsw i128 %215 to i32
  %217 = icmp ult i64 %214, 616
  br i1 %217, label %218, label %228

218:                                              ; preds = %220, %211
  %219 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %220 unwind label %203

220:                                              ; preds = %218
  %221 = zext i64 %219 to i128
  %222 = mul nuw nsw i128 %221, 1000
  %223 = trunc i128 %222 to i64
  %224 = icmp ult i64 %223, 616
  br i1 %224, label %218, label %225, !llvm.loop !46

225:                                              ; preds = %220
  %226 = lshr i128 %222, 64
  %227 = trunc nuw nsw i128 %226 to i32
  br label %228

228:                                              ; preds = %225, %211
  %229 = phi i32 [ %216, %211 ], [ %227, %225 ]
  %230 = add nuw nsw i32 %229, 1
  %231 = add nuw nsw i64 %84, 1
  %232 = invoke noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %1)
          to label %233 unwind label %207

233:                                              ; preds = %228
  %234 = add nuw nsw i64 %85, 50
  %235 = urem i64 %232, 100
  %236 = add nuw i64 %234, %235
  %237 = load ptr, ptr %53, align 8, !tbaa !32
  %238 = icmp eq ptr %237, %86
  br i1 %238, label %248, label %239

239:                                              ; preds = %233
  store i8 %146, ptr %237, align 1, !tbaa !47
  %240 = getelementptr inbounds nuw i8, ptr %237, i64 1
  store i8 %174, ptr %240, align 1, !tbaa !49
  %241 = getelementptr inbounds nuw i8, ptr %237, i64 2
  store i16 0, ptr %241, align 1, !tbaa !51
  %242 = getelementptr inbounds nuw i8, ptr %237, i64 4
  store i64 %84, ptr %242, align 1, !tbaa !5
  %243 = getelementptr inbounds nuw i8, ptr %237, i64 12
  store i64 %201, ptr %243, align 1, !tbaa !5
  %244 = getelementptr inbounds nuw i8, ptr %237, i64 20
  store i32 %230, ptr %244, align 1, !tbaa !42
  %245 = getelementptr inbounds nuw i8, ptr %237, i64 24
  store i64 %85, ptr %245, align 1, !tbaa !5
  %246 = getelementptr inbounds nuw i8, ptr %237, i64 32
  store i64 %236, ptr %246, align 1, !tbaa !5
  %247 = getelementptr inbounds nuw i8, ptr %237, i64 40
  store ptr %247, ptr %53, align 8, !tbaa !32
  br label %284

248:                                              ; preds = %233
  %249 = ptrtoint ptr %237 to i64
  %250 = ptrtoint ptr %87 to i64
  %251 = sub i64 %249, %250
  %252 = icmp eq i64 %251, 9223372036854775800
  br i1 %252, label %253, label %255

253:                                              ; preds = %248
  store ptr %86, ptr %11, align 8
  store ptr %87, ptr %0, align 8
  invoke void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.40) #18
          to label %254 unwind label %209

254:                                              ; preds = %253
  unreachable

255:                                              ; preds = %248
  %256 = sdiv exact i64 %251, 40
  %257 = call i64 @llvm.umax.i64(i64 %256, i64 1)
  %258 = add i64 %257, %256
  %259 = icmp ult i64 %258, %256
  %260 = call i64 @llvm.umin.i64(i64 %258, i64 230584300921369395)
  %261 = select i1 %259, i64 230584300921369395, i64 %260
  %262 = icmp ne i64 %261, 0
  call void @llvm.assume(i1 %262)
  %263 = mul nuw nsw i64 %261, 40
  %264 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %263) #19
          to label %265 unwind label %207

265:                                              ; preds = %255
  %266 = getelementptr inbounds nuw i8, ptr %264, i64 %251
  store i8 %146, ptr %266, align 1, !tbaa !47
  %267 = getelementptr inbounds nuw i8, ptr %266, i64 1
  store i8 %174, ptr %267, align 1, !tbaa !49
  %268 = getelementptr inbounds nuw i8, ptr %266, i64 2
  store i16 0, ptr %268, align 1, !tbaa !51
  %269 = getelementptr inbounds nuw i8, ptr %266, i64 4
  store i64 %84, ptr %269, align 1, !tbaa !5
  %270 = getelementptr inbounds nuw i8, ptr %266, i64 12
  store i64 %201, ptr %270, align 1, !tbaa !5
  %271 = getelementptr inbounds nuw i8, ptr %266, i64 20
  store i32 %230, ptr %271, align 1, !tbaa !42
  %272 = getelementptr inbounds nuw i8, ptr %266, i64 24
  store i64 %85, ptr %272, align 1, !tbaa !5
  %273 = getelementptr inbounds nuw i8, ptr %266, i64 32
  store i64 %236, ptr %273, align 1, !tbaa !5
  %274 = icmp sgt i64 %251, 0
  br i1 %274, label %275, label %276

275:                                              ; preds = %265
  call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %264, ptr align 1 %87, i64 %251, i1 false)
  br label %276

276:                                              ; preds = %275, %265
  %277 = getelementptr inbounds nuw i8, ptr %266, i64 40
  %278 = icmp eq ptr %87, null
  br i1 %278, label %282, label %279

279:                                              ; preds = %276
  %280 = ptrtoint ptr %86 to i64
  %281 = sub i64 %280, %250
  call void @_ZdlPvm(ptr noundef nonnull %87, i64 noundef %281) #17
  br label %282

282:                                              ; preds = %279, %276
  store ptr %277, ptr %53, align 8, !tbaa !32
  %283 = getelementptr inbounds nuw %struct.MarketDataMessage, ptr %264, i64 %261
  br label %284

284:                                              ; preds = %282, %239
  %285 = phi ptr [ %264, %282 ], [ %87, %239 ]
  %286 = phi ptr [ %283, %282 ], [ %86, %239 ]
  %287 = add nuw nsw i64 %85, 100
  %288 = icmp eq i64 %231, %56
  br i1 %288, label %57, label %83, !llvm.loop !53

289:                                              ; preds = %209, %207, %205, %203, %151, %149
  %290 = phi { ptr, i32 } [ %150, %149 ], [ %152, %151 ], [ %204, %203 ], [ %206, %205 ], [ %208, %207 ], [ %210, %209 ]
  call void @_ZNSt21discrete_distributionIiED2Ev(ptr noundef nonnull align 8 dereferenceable(48) %4) #16
  br label %291

291:                                              ; preds = %289, %81
  %292 = phi { ptr, i32 } [ %290, %289 ], [ %82, %81 ]
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %4) #16
  br label %293

293:                                              ; preds = %291, %79
  %294 = phi { ptr, i32 } [ %292, %291 ], [ %80, %79 ]
  %295 = load ptr, ptr %0, align 8, !tbaa !18
  %296 = icmp eq ptr %295, null
  br i1 %296, label %303, label %297

297:                                              ; preds = %293
  %298 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %299 = load ptr, ptr %298, align 8, !tbaa !20
  %300 = ptrtoint ptr %299 to i64
  %301 = ptrtoint ptr %295 to i64
  %302 = sub i64 %300, %301
  call void @_ZdlPvm(ptr noundef nonnull %295, i64 noundef %302) #17
  br label %303

303:                                              ; preds = %297, %293
  resume { ptr, i32 } %294
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind
declare i64 @_ZNSt6chrono3_V212system_clock3nowEv() local_unnamed_addr #1

; Function Attrs: mustprogress noinline uwtable
define linkonce_odr dso_local void @_ZN17MarketDataHandler9onMessageERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %0, ptr noundef nonnull align 1 dereferenceable(40) %1) local_unnamed_addr #6 comdat align 2 personality ptr @__gxx_personality_v0 {
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 794688
  %4 = getelementptr inbounds nuw i8, ptr %0, i64 794768
  %rmw.old = load i64, ptr %4, align 8
  %rmw.new = add i64 %rmw.old, 1
  store i64 %rmw.new, ptr %4, align 8
  %5 = getelementptr inbounds nuw i8, ptr %0, i64 794776
  %6 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %7 = load i64, ptr %6, align 1, !tbaa !54
  store i64 %7, ptr %5, align 8
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 794784
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %10 = load i64, ptr %9, align 1, !tbaa !56
  store i64 %10, ptr %8, align 32
  %11 = load i64, ptr %9, align 1, !tbaa !56
  %12 = load i64, ptr %6, align 1, !tbaa !54
  %13 = icmp ugt i64 %11, %12
  br i1 %13, label %14, label %26

14:                                               ; preds = %2
  %15 = sub nuw i64 %11, %12
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 794800
  %rmw.old1 = load i64, ptr %16, align 8
  %rmw.new2 = add i64 %rmw.old1, %15
  store i64 %rmw.new2, ptr %16, align 8
  %17 = getelementptr inbounds nuw i8, ptr %0, i64 794792
  %18 = load i64, ptr %17, align 8
  %19 = icmp ugt i64 %15, %18
  br i1 %19, label %20, label %26

20:                                               ; preds = %20, %14
  %21 = phi i64 [ %23, %20 ], [ %18, %14 ]
  %cx.old = load i64, ptr %17, align 8
  %cx.success = icmp eq i64 %cx.old, %21
  %cx.tostore = select i1 %cx.success, i64 %15, i64 %cx.old
  store i64 %cx.tostore, ptr %17, align 8
  %cx.res.val = insertvalue { i64, i1 } undef, i64 %cx.old, 0
  %cx.res.succ = insertvalue { i64, i1 } %cx.res.val, i1 %cx.success, 1
  %22 = extractvalue { i64, i1 } %cx.res.succ, 1
  %23 = extractvalue { i64, i1 } %cx.res.succ, 0
  %24 = icmp ule i64 %15, %23
  %25 = select i1 %22, i1 true, i1 %24
  br i1 %25, label %26, label %20, !llvm.loop !57

26:                                               ; preds = %20, %14, %2
  %27 = load i8, ptr %1, align 1, !tbaa !58
  switch i8 %27, label %91 [
    i8 65, label %28
    i8 88, label %32
    i8 77, label %47
    i8 69, label %51
    i8 67, label %76
  ]

28:                                               ; preds = %26
  %29 = tail call noundef zeroext i1 @_ZN17MarketDataHandler9handleAddERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %0, ptr noundef nonnull align 1 dereferenceable(40) %1)
  br i1 %29, label %30, label %93

30:                                               ; preds = %28
  %31 = getelementptr inbounds nuw i8, ptr %0, i64 794696
  %rmw.old3 = load i64, ptr %31, align 8
  %rmw.new4 = add i64 %rmw.old3, 1
  store i64 %rmw.new4, ptr %31, align 8
  br label %95

32:                                               ; preds = %26
  %33 = getelementptr inbounds nuw i8, ptr %1, i64 1
  %34 = load i8, ptr %33, align 1, !tbaa !59
  %35 = icmp eq i8 %34, 66
  %36 = select i1 %35, i64 0, i64 397320
  %37 = getelementptr inbounds nuw i8, ptr %0, i64 %36
  %38 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %39 = load i64, ptr %38, align 1, !tbaa !60
  %40 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %41 = load i64, ptr %40, align 1, !tbaa !61
  %42 = getelementptr inbounds nuw i8, ptr %1, i64 20
  %43 = load i32, ptr %42, align 1, !tbaa !62
  %44 = tail call noundef zeroext i1 @_ZN8BookSide11removeOrderElmi(ptr noundef nonnull align 8 dereferenceable(397320) %37, i64 noundef %39, i64 noundef %41, i32 noundef %43)
  br i1 %44, label %45, label %93

45:                                               ; preds = %32
  %46 = getelementptr inbounds nuw i8, ptr %0, i64 794704
  %rmw.old5 = load i64, ptr %46, align 8
  %rmw.new6 = add i64 %rmw.old5, 1
  store i64 %rmw.new6, ptr %46, align 8
  br label %95

47:                                               ; preds = %26
  %48 = tail call noundef zeroext i1 @_ZN17MarketDataHandler12handleModifyERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %0, ptr noundef nonnull align 1 dereferenceable(40) %1)
  br i1 %48, label %49, label %93

49:                                               ; preds = %47
  %50 = getelementptr inbounds nuw i8, ptr %0, i64 794712
  %rmw.old7 = load i64, ptr %50, align 8
  %rmw.new8 = add i64 %rmw.old7, 1
  store i64 %rmw.new8, ptr %50, align 8
  br label %95

51:                                               ; preds = %26
  %52 = getelementptr inbounds nuw i8, ptr %1, i64 1
  %53 = load i8, ptr %52, align 1, !tbaa !59
  %54 = icmp eq i8 %53, 66
  %55 = select i1 %54, i64 0, i64 397320
  %56 = getelementptr inbounds nuw i8, ptr %0, i64 %55
  %57 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %58 = load i64, ptr %57, align 1, !tbaa !60
  %59 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %60 = load i64, ptr %59, align 1, !tbaa !61
  %61 = getelementptr inbounds nuw i8, ptr %1, i64 20
  %62 = load i32, ptr %61, align 1, !tbaa !62
  %63 = tail call noundef zeroext i1 @_ZN8BookSide11removeOrderElmi(ptr noundef nonnull align 8 dereferenceable(397320) %56, i64 noundef %58, i64 noundef %60, i32 noundef %62)
  br i1 %63, label %64, label %93

64:                                               ; preds = %51
  %65 = getelementptr inbounds nuw i8, ptr %0, i64 794720
  %rmw.old9 = load i64, ptr %65, align 8
  %rmw.new10 = add i64 %rmw.old9, 1
  store i64 %rmw.new10, ptr %65, align 8
  %66 = getelementptr inbounds nuw i8, ptr %0, i64 794752
  %67 = load i32, ptr %61, align 1, !tbaa !62
  %68 = sext i32 %67 to i64
  %rmw.old11 = load i64, ptr %66, align 8
  %rmw.new12 = add i64 %rmw.old11, %68
  store i64 %rmw.new12, ptr %66, align 8
  %69 = load i8, ptr %52, align 1, !tbaa !59
  %70 = icmp eq i8 %69, 66
  %71 = getelementptr inbounds nuw i8, ptr %0, i64 794760
  %72 = load i32, ptr %61, align 1, !tbaa !62
  %73 = sext i32 %72 to i64
  br i1 %70, label %74, label %75

74:                                               ; preds = %64
  %rmw.old13 = load i64, ptr %71, align 8
  %rmw.new14 = add i64 %rmw.old13, %73
  store i64 %rmw.new14, ptr %71, align 8
  br label %95

75:                                               ; preds = %64
  %rmw.old15 = load i64, ptr %71, align 8
  %rmw.new16 = sub i64 %rmw.old15, %73
  store i64 %rmw.new16, ptr %71, align 8
  br label %95

76:                                               ; preds = %26
  %77 = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i32 0, ptr %77, align 4, !tbaa !26
  br label %78

78:                                               ; preds = %78, %76
  %79 = phi i64 [ 8, %76 ], [ %81, %78 ]
  %80 = getelementptr inbounds nuw i8, ptr %0, i64 %79
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %80, i8 0, i64 16, i1 false)
  %81 = add nuw nsw i64 %79, 1552
  %82 = icmp eq i64 %81, 397320
  br i1 %82, label %83, label %78, !llvm.loop !31

83:                                               ; preds = %78
  %84 = getelementptr inbounds nuw i8, ptr %0, i64 397320
  %85 = getelementptr inbounds nuw i8, ptr %0, i64 397324
  store i32 0, ptr %85, align 4, !tbaa !26
  br label %86

86:                                               ; preds = %86, %83
  %87 = phi i64 [ 8, %83 ], [ %89, %86 ]
  %88 = getelementptr inbounds nuw i8, ptr %84, i64 %87
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %88, i8 0, i64 16, i1 false)
  %89 = add nuw nsw i64 %87, 1552
  %90 = icmp eq i64 %89, 397320
  br i1 %90, label %95, label %86, !llvm.loop !31

91:                                               ; preds = %26
  %92 = getelementptr inbounds nuw i8, ptr %0, i64 794728
  br label %116

93:                                               ; preds = %51, %47, %32, %28
  %94 = getelementptr inbounds nuw i8, ptr %0, i64 794744
  %rmw.old17 = load i64, ptr %94, align 8
  %rmw.new18 = add i64 %rmw.old17, 1
  store i64 %rmw.new18, ptr %94, align 8
  br label %95

95:                                               ; preds = %93, %86, %75, %74, %49, %45, %30
  %96 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %97 = load i32, ptr %96, align 4, !tbaa !26
  %98 = icmp eq i32 %97, 0
  %99 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %100 = load i64, ptr %99, align 8
  %101 = select i1 %98, i64 0, i64 %100
  %102 = getelementptr inbounds nuw i8, ptr %0, i64 397324
  %103 = load i32, ptr %102, align 4, !tbaa !26
  %104 = icmp eq i32 %103, 0
  %105 = getelementptr inbounds nuw i8, ptr %0, i64 397328
  %106 = load i64, ptr %105, align 16
  %107 = select i1 %104, i64 0, i64 %106
  %108 = getelementptr inbounds nuw i8, ptr %0, i64 794808
  store i64 %101, ptr %108, align 8
  %109 = getelementptr inbounds nuw i8, ptr %0, i64 794816
  store i64 %107, ptr %109, align 64
  %110 = icmp sgt i64 %101, 0
  %111 = icmp sgt i64 %107, 0
  %112 = and i1 %110, %111
  br i1 %112, label %113, label %116

113:                                              ; preds = %95
  %114 = getelementptr inbounds nuw i8, ptr %0, i64 794824
  %115 = sub nsw i64 %107, %101
  store i64 %115, ptr %114, align 8
  br label %116

116:                                              ; preds = %113, %95, %91
  %117 = phi ptr [ %92, %91 ], [ %3, %95 ], [ %3, %113 ]
  %118 = atomicrmw add ptr %117, i64 1 seq_cst, align 8
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #7

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #8

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.abs.i32(i32, i1 immarg) #9

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef i64 @_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEclEv(ptr noundef nonnull align 8 dereferenceable(2504) %0) local_unnamed_addr #3 comdat align 2 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 2496
  %3 = load i64, ptr %2, align 8, !tbaa !12
  %4 = icmp ugt i64 %3, 311
  br i1 %4, label %5, label %60

5:                                                ; preds = %5, %1
  %6 = phi i64 [ %10, %5 ], [ 0, %1 ]
  %7 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %6
  %8 = load i64, ptr %7, align 8, !tbaa !5
  %9 = and i64 %8, -2147483648
  %10 = add nuw nsw i64 %6, 1
  %11 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %10
  %12 = load i64, ptr %11, align 8, !tbaa !5
  %13 = and i64 %12, 2147483646
  %14 = or disjoint i64 %13, %9
  %15 = add nuw nsw i64 %6, 156
  %16 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %15
  %17 = load i64, ptr %16, align 8, !tbaa !5
  %18 = lshr exact i64 %14, 1
  %19 = xor i64 %18, %17
  %20 = and i64 %12, 1
  %21 = icmp eq i64 %20, 0
  %22 = select i1 %21, i64 0, i64 -5403634167711393303
  %23 = xor i64 %19, %22
  store i64 %23, ptr %7, align 8, !tbaa !5
  %24 = icmp eq i64 %10, 156
  br i1 %24, label %25, label %5, !llvm.loop !63

25:                                               ; preds = %25, %5
  %26 = phi i64 [ %30, %25 ], [ 156, %5 ]
  %27 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %26
  %28 = load i64, ptr %27, align 8, !tbaa !5
  %29 = and i64 %28, -2147483648
  %30 = add nuw nsw i64 %26, 1
  %31 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %30
  %32 = load i64, ptr %31, align 8, !tbaa !5
  %33 = and i64 %32, 2147483646
  %34 = or disjoint i64 %33, %29
  %35 = add nsw i64 %26, -156
  %36 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %35
  %37 = load i64, ptr %36, align 8, !tbaa !5
  %38 = lshr exact i64 %34, 1
  %39 = xor i64 %38, %37
  %40 = and i64 %32, 1
  %41 = icmp eq i64 %40, 0
  %42 = select i1 %41, i64 0, i64 -5403634167711393303
  %43 = xor i64 %39, %42
  store i64 %43, ptr %27, align 8, !tbaa !5
  %44 = icmp eq i64 %30, 311
  br i1 %44, label %45, label %25, !llvm.loop !64

45:                                               ; preds = %25
  %46 = getelementptr inbounds nuw i8, ptr %0, i64 2488
  %47 = load i64, ptr %46, align 8, !tbaa !5
  %48 = and i64 %47, -2147483648
  %49 = load i64, ptr %0, align 8, !tbaa !5
  %50 = and i64 %49, 2147483646
  %51 = or disjoint i64 %50, %48
  %52 = getelementptr inbounds nuw i8, ptr %0, i64 1240
  %53 = load i64, ptr %52, align 8, !tbaa !5
  %54 = lshr exact i64 %51, 1
  %55 = xor i64 %54, %53
  %56 = and i64 %49, 1
  %57 = icmp eq i64 %56, 0
  %58 = select i1 %57, i64 0, i64 -5403634167711393303
  %59 = xor i64 %55, %58
  store i64 %59, ptr %46, align 8, !tbaa !5
  store i64 0, ptr %2, align 8, !tbaa !12
  br label %60

60:                                               ; preds = %45, %1
  %61 = load i64, ptr %2, align 8, !tbaa !12
  %62 = add i64 %61, 1
  store i64 %62, ptr %2, align 8, !tbaa !12
  %63 = getelementptr inbounds nuw [312 x i64], ptr %0, i64 0, i64 %61
  %64 = load i64, ptr %63, align 8, !tbaa !5
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

; Function Attrs: inlinehint mustprogress nounwind uwtable
define linkonce_odr dso_local void @_ZNSt21discrete_distributionIiED2Ev(ptr noundef nonnull align 8 dereferenceable(48) %0) unnamed_addr #10 comdat align 2 personality ptr @__gxx_personality_v0 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %3 = load ptr, ptr %2, align 8, !tbaa !35
  %4 = icmp eq ptr %3, null
  br i1 %4, label %11, label %5

5:                                                ; preds = %1
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %7 = load ptr, ptr %6, align 8, !tbaa !38
  %8 = ptrtoint ptr %7 to i64
  %9 = ptrtoint ptr %3 to i64
  %10 = sub i64 %8, %9
  tail call void @_ZdlPvm(ptr noundef nonnull %3, i64 noundef %10) #17
  br label %11

11:                                               ; preds = %5, %1
  %12 = load ptr, ptr %0, align 8, !tbaa !35
  %13 = icmp eq ptr %12, null
  br i1 %13, label %20, label %14

14:                                               ; preds = %11
  %15 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %16 = load ptr, ptr %15, align 8, !tbaa !38
  %17 = ptrtoint ptr %16 to i64
  %18 = ptrtoint ptr %12 to i64
  %19 = sub i64 %17, %18
  tail call void @_ZdlPvm(ptr noundef nonnull %12, i64 noundef %19) #17
  br label %20

20:                                               ; preds = %14, %11
  ret void
}

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(ptr noundef) local_unnamed_addr #11

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #12

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #7

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #13

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZNSt21discrete_distributionIiE10param_typeC2ESt16initializer_listIdE(ptr noundef nonnull align 8 dereferenceable(48) %0, ptr %1, i64 %2) unnamed_addr #3 comdat align 2 personality ptr @__gxx_personality_v0 {
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  %4 = shl nuw nsw i64 %2, 3
  %5 = icmp eq i64 %2, 0
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  %7 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %4) #19
          to label %8 unwind label %13

8:                                                ; preds = %6, %3
  %9 = phi ptr [ null, %3 ], [ %7, %6 ]
  store ptr %9, ptr %0, align 8, !tbaa !35
  %10 = getelementptr inbounds nuw i8, ptr %9, i64 %4
  %11 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store ptr %10, ptr %11, align 8, !tbaa !38
  br i1 %5, label %19, label %12

12:                                               ; preds = %8
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 8 %9, ptr align 8 %1, i64 %4, i1 false)
  br label %19

13:                                               ; preds = %6
  %14 = landingpad { ptr, i32 }
          cleanup
  %15 = load ptr, ptr %0, align 8, !tbaa !35
  %16 = icmp eq ptr %15, null
  br i1 %16, label %44, label %17

17:                                               ; preds = %13
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 16
  br label %36

19:                                               ; preds = %12, %8
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store ptr %10, ptr %20, align 8, !tbaa !65
  %21 = getelementptr inbounds nuw i8, ptr %0, i64 24
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %21, i8 0, i64 24, i1 false)
  invoke void @_ZNSt21discrete_distributionIiE10param_type13_M_initializeEv(ptr noundef nonnull align 8 dereferenceable(48) %0)
          to label %22 unwind label %23

22:                                               ; preds = %19
  ret void

23:                                               ; preds = %19
  %24 = landingpad { ptr, i32 }
          cleanup
  %25 = load ptr, ptr %21, align 8, !tbaa !35
  %26 = icmp eq ptr %25, null
  br i1 %26, label %33, label %27

27:                                               ; preds = %23
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %29 = load ptr, ptr %28, align 8, !tbaa !38
  %30 = ptrtoint ptr %29 to i64
  %31 = ptrtoint ptr %25 to i64
  %32 = sub i64 %30, %31
  tail call void @_ZdlPvm(ptr noundef nonnull %25, i64 noundef %32) #17
  br label %33

33:                                               ; preds = %27, %23
  %34 = load ptr, ptr %0, align 8, !tbaa !35
  %35 = icmp eq ptr %34, null
  br i1 %35, label %44, label %36

36:                                               ; preds = %33, %17
  %37 = phi ptr [ %18, %17 ], [ %11, %33 ]
  %38 = phi ptr [ %15, %17 ], [ %34, %33 ]
  %39 = phi { ptr, i32 } [ %14, %17 ], [ %24, %33 ]
  %40 = load ptr, ptr %37, align 8, !tbaa !38
  %41 = ptrtoint ptr %40 to i64
  %42 = ptrtoint ptr %38 to i64
  %43 = sub i64 %41, %42
  tail call void @_ZdlPvm(ptr noundef nonnull %38, i64 noundef %43) #17
  br label %44

44:                                               ; preds = %36, %33, %13
  %45 = phi { ptr, i32 } [ %14, %13 ], [ %24, %33 ], [ %39, %36 ]
  resume { ptr, i32 } %45
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZNSt21discrete_distributionIiE10param_type13_M_initializeEv(ptr noundef nonnull align 8 dereferenceable(48) %0) local_unnamed_addr #3 comdat align 2 personality ptr @__gxx_personality_v0 {
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %3 = load ptr, ptr %2, align 8, !tbaa !65
  %4 = load ptr, ptr %0, align 8, !tbaa !35
  %5 = ptrtoint ptr %3 to i64
  %6 = ptrtoint ptr %4 to i64
  %7 = sub i64 %5, %6
  %8 = ashr exact i64 %7, 3
  %9 = icmp ult i64 %8, 2
  %10 = icmp eq ptr %3, %4
  br i1 %9, label %11, label %13

11:                                               ; preds = %1
  br i1 %10, label %67, label %12

12:                                               ; preds = %11
  store ptr %4, ptr %2, align 8, !tbaa !65
  br label %67

13:                                               ; preds = %1
  br i1 %10, label %21, label %14

14:                                               ; preds = %14, %13
  %15 = phi double [ %18, %14 ], [ 0.000000e+00, %13 ]
  %16 = phi ptr [ %19, %14 ], [ %4, %13 ]
  %17 = load double, ptr %16, align 8, !tbaa !43
  %18 = fadd double %15, %17
  %19 = getelementptr inbounds nuw i8, ptr %16, i64 8
  %20 = icmp eq ptr %19, %3
  br i1 %20, label %21, label %14, !llvm.loop !66

21:                                               ; preds = %14, %13
  %22 = phi double [ 0.000000e+00, %13 ], [ %18, %14 ]
  br i1 %10, label %29, label %23

23:                                               ; preds = %23, %21
  %24 = phi ptr [ %27, %23 ], [ %4, %21 ]
  %25 = load double, ptr %24, align 8, !tbaa !43
  %26 = fdiv double %25, %22
  store double %26, ptr %24, align 8, !tbaa !43
  %27 = getelementptr i8, ptr %24, i64 8
  %28 = icmp eq ptr %27, %3
  br i1 %28, label %29, label %23, !llvm.loop !67

29:                                               ; preds = %23, %21
  %30 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %31 = icmp ugt i64 %8, 1152921504606846975
  br i1 %31, label %32, label %33

32:                                               ; preds = %29
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.38) #18
  unreachable

33:                                               ; preds = %29
  %34 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %35 = load ptr, ptr %34, align 8, !tbaa !38
  %36 = load ptr, ptr %30, align 8, !tbaa !35
  %37 = ptrtoint ptr %35 to i64
  %38 = ptrtoint ptr %36 to i64
  %39 = sub i64 %37, %38
  %40 = icmp ult i64 %39, %7
  br i1 %40, label %41, label %55

41:                                               ; preds = %33
  %42 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %43 = load ptr, ptr %42, align 8, !tbaa !65
  %44 = ptrtoint ptr %43 to i64
  %45 = sub i64 %44, %38
  %46 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %7) #19
  %47 = icmp sgt i64 %45, 0
  br i1 %47, label %48, label %49

48:                                               ; preds = %41
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %46, ptr align 8 %36, i64 %45, i1 false)
  br label %49

49:                                               ; preds = %48, %41
  %50 = icmp eq ptr %36, null
  br i1 %50, label %52, label %51

51:                                               ; preds = %49
  tail call void @_ZdlPvm(ptr noundef nonnull %36, i64 noundef %39) #17
  br label %52

52:                                               ; preds = %51, %49
  store ptr %46, ptr %30, align 8, !tbaa !35
  %53 = getelementptr inbounds nuw i8, ptr %46, i64 %45
  store ptr %53, ptr %42, align 8, !tbaa !65
  %54 = getelementptr inbounds nuw i8, ptr %46, i64 %7
  store ptr %54, ptr %34, align 8, !tbaa !38
  br label %55

55:                                               ; preds = %52, %33
  %56 = load ptr, ptr %0, align 8, !tbaa !39
  %57 = load ptr, ptr %2, align 8, !tbaa !39
  %58 = tail call ptr @_ZSt11partial_sumIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEESt20back_insert_iteratorIS5_EET0_T_SA_S9_(ptr %56, ptr %57, ptr nonnull %30)
  %59 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %60 = load ptr, ptr %59, align 8, !tbaa !65
  %61 = load ptr, ptr %30, align 8, !tbaa !35
  %62 = ptrtoint ptr %60 to i64
  %63 = ptrtoint ptr %61 to i64
  %64 = sub i64 %62, %63
  %65 = getelementptr i8, ptr %61, i64 %64
  %66 = getelementptr i8, ptr %65, i64 -8
  store double 1.000000e+00, ptr %66, align 8, !tbaa !43
  br label %67

67:                                               ; preds = %55, %12, %11
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local ptr @_ZSt11partial_sumIN9__gnu_cxx17__normal_iteratorIPdSt6vectorIdSaIdEEEESt20back_insert_iteratorIS5_EET0_T_SA_S9_(ptr %0, ptr %1, ptr %2) local_unnamed_addr #3 comdat {
  %4 = icmp eq ptr %0, %1
  br i1 %4, label %86, label %5

5:                                                ; preds = %3
  %6 = load double, ptr %0, align 8, !tbaa !43
  %7 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %8 = load ptr, ptr %7, align 8, !tbaa !65
  %9 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %10 = load ptr, ptr %9, align 8, !tbaa !38
  %11 = icmp eq ptr %8, %10
  br i1 %11, label %14, label %12

12:                                               ; preds = %5
  store double %6, ptr %8, align 8, !tbaa !43
  %13 = getelementptr inbounds nuw i8, ptr %8, i64 8
  store ptr %13, ptr %7, align 8, !tbaa !65
  br label %42

14:                                               ; preds = %5
  %15 = load ptr, ptr %2, align 8, !tbaa !35
  %16 = ptrtoint ptr %8 to i64
  %17 = ptrtoint ptr %15 to i64
  %18 = sub i64 %16, %17
  %19 = icmp eq i64 %18, 9223372036854775800
  br i1 %19, label %20, label %21

20:                                               ; preds = %14
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.40) #18
  unreachable

21:                                               ; preds = %14
  %22 = ashr exact i64 %18, 3
  %23 = tail call i64 @llvm.umax.i64(i64 %22, i64 1)
  %24 = add i64 %23, %22
  %25 = icmp ult i64 %24, %22
  %26 = tail call i64 @llvm.umin.i64(i64 %24, i64 1152921504606846975)
  %27 = select i1 %25, i64 1152921504606846975, i64 %26
  %28 = icmp ne i64 %27, 0
  tail call void @llvm.assume(i1 %28)
  %29 = shl nuw nsw i64 %27, 3
  %30 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %29) #19
  %31 = getelementptr inbounds nuw i8, ptr %30, i64 %18
  store double %6, ptr %31, align 8, !tbaa !43
  %32 = icmp sgt i64 %18, 0
  br i1 %32, label %33, label %34

33:                                               ; preds = %21
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %30, ptr align 8 %15, i64 %18, i1 false)
  br label %34

34:                                               ; preds = %33, %21
  %35 = getelementptr inbounds nuw i8, ptr %31, i64 8
  %36 = icmp eq ptr %15, null
  br i1 %36, label %40, label %37

37:                                               ; preds = %34
  %38 = ptrtoint ptr %10 to i64
  %39 = sub i64 %38, %17
  tail call void @_ZdlPvm(ptr noundef nonnull %15, i64 noundef %39) #17
  br label %40

40:                                               ; preds = %37, %34
  store ptr %30, ptr %2, align 8, !tbaa !35
  store ptr %35, ptr %7, align 8, !tbaa !65
  %41 = getelementptr inbounds nuw double, ptr %30, i64 %27
  store ptr %41, ptr %9, align 8, !tbaa !38
  br label %42

42:                                               ; preds = %40, %12
  %43 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %44 = icmp eq ptr %43, %1
  br i1 %44, label %86, label %45

45:                                               ; preds = %83, %42
  %46 = phi ptr [ %84, %83 ], [ %43, %42 ]
  %47 = phi double [ %49, %83 ], [ %6, %42 ]
  %48 = load double, ptr %46, align 8, !tbaa !43
  %49 = fadd double %47, %48
  %50 = load ptr, ptr %7, align 8, !tbaa !65
  %51 = load ptr, ptr %9, align 8, !tbaa !38
  %52 = icmp eq ptr %50, %51
  br i1 %52, label %55, label %53

53:                                               ; preds = %45
  store double %49, ptr %50, align 8, !tbaa !43
  %54 = getelementptr inbounds nuw i8, ptr %50, i64 8
  store ptr %54, ptr %7, align 8, !tbaa !65
  br label %83

55:                                               ; preds = %45
  %56 = load ptr, ptr %2, align 8, !tbaa !35
  %57 = ptrtoint ptr %50 to i64
  %58 = ptrtoint ptr %56 to i64
  %59 = sub i64 %57, %58
  %60 = icmp eq i64 %59, 9223372036854775800
  br i1 %60, label %61, label %62

61:                                               ; preds = %55
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str.40) #18
  unreachable

62:                                               ; preds = %55
  %63 = ashr exact i64 %59, 3
  %64 = tail call i64 @llvm.umax.i64(i64 %63, i64 1)
  %65 = add i64 %64, %63
  %66 = icmp ult i64 %65, %63
  %67 = tail call i64 @llvm.umin.i64(i64 %65, i64 1152921504606846975)
  %68 = select i1 %66, i64 1152921504606846975, i64 %67
  %69 = icmp ne i64 %68, 0
  tail call void @llvm.assume(i1 %69)
  %70 = shl nuw nsw i64 %68, 3
  %71 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %70) #19
  %72 = getelementptr inbounds nuw i8, ptr %71, i64 %59
  store double %49, ptr %72, align 8, !tbaa !43
  %73 = icmp sgt i64 %59, 0
  br i1 %73, label %74, label %75

74:                                               ; preds = %62
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %71, ptr align 8 %56, i64 %59, i1 false)
  br label %75

75:                                               ; preds = %74, %62
  %76 = getelementptr inbounds nuw i8, ptr %72, i64 8
  %77 = icmp eq ptr %56, null
  br i1 %77, label %81, label %78

78:                                               ; preds = %75
  %79 = ptrtoint ptr %51 to i64
  %80 = sub i64 %79, %58
  tail call void @_ZdlPvm(ptr noundef nonnull %56, i64 noundef %80) #17
  br label %81

81:                                               ; preds = %78, %75
  store ptr %71, ptr %2, align 8, !tbaa !35
  store ptr %76, ptr %7, align 8, !tbaa !65
  %82 = getelementptr inbounds nuw double, ptr %71, i64 %68
  store ptr %82, ptr %9, align 8, !tbaa !38
  br label %83

83:                                               ; preds = %81, %53
  %84 = getelementptr inbounds nuw i8, ptr %46, i64 8
  %85 = icmp eq ptr %84, %1
  br i1 %85, label %86, label %45, !llvm.loop !68

86:                                               ; preds = %83, %42, %3
  ret ptr %2
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #9

; Function Attrs: nounwind
declare double @nextafter(double noundef, double noundef) local_unnamed_addr #1

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZN17MarketDataHandler9handleAddERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %0, ptr noundef nonnull align 1 dereferenceable(40) %1) local_unnamed_addr #3 comdat align 2 {
  %3 = getelementptr inbounds nuw i8, ptr %1, i64 1
  %4 = load i8, ptr %3, align 1, !tbaa !59
  %5 = icmp eq i8 %4, 66
  %6 = select i1 %5, i64 0, i64 397320
  %7 = getelementptr inbounds nuw i8, ptr %0, i64 %6
  %8 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %9 = load i64, ptr %8, align 1, !tbaa !60
  %10 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %11 = load i64, ptr %10, align 1, !tbaa !61
  %12 = getelementptr inbounds nuw i8, ptr %1, i64 20
  %13 = load i32, ptr %12, align 1, !tbaa !62
  %14 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %15 = load i64, ptr %14, align 1, !tbaa !54
  %16 = getelementptr inbounds nuw i8, ptr %7, i64 4
  %17 = load i32, ptr %16, align 4, !tbaa !26
  %18 = icmp sgt i32 %17, 0
  br i1 %18, label %19, label %39

19:                                               ; preds = %2
  %20 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %21 = load i8, ptr %7, align 8, !range !69
  %22 = trunc nuw i8 %21 to i1
  %23 = zext nneg i32 %17 to i64
  br label %24

24:                                               ; preds = %31, %19
  %25 = phi i64 [ 0, %19 ], [ %37, %31 ]
  %26 = phi i32 [ 0, %19 ], [ %36, %31 ]
  %27 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %20, i64 0, i64 %25
  %28 = load i64, ptr %27, align 8, !tbaa !70
  %29 = icmp eq i64 %28, %9
  %30 = trunc i64 %25 to i32
  br i1 %29, label %59, label %31

31:                                               ; preds = %24
  %32 = add i32 %30, 1
  %33 = icmp slt i64 %28, %9
  %34 = icmp sgt i64 %28, %9
  %35 = select i1 %22, i1 %34, i1 %33
  %36 = select i1 %35, i32 %32, i32 %26
  %37 = add nuw nsw i64 %25, 1
  %38 = icmp eq i64 %37, %23
  br i1 %38, label %39, label %24, !llvm.loop !73

39:                                               ; preds = %31, %2
  %40 = phi i32 [ 0, %2 ], [ %36, %31 ]
  %41 = icmp sgt i32 %17, 255
  br i1 %41, label %59, label %42

42:                                               ; preds = %39
  %43 = icmp sgt i32 %17, %40
  br i1 %43, label %44, label %48

44:                                               ; preds = %42
  %45 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %46 = sext i32 %17 to i64
  %47 = sext i32 %40 to i64
  br label %53

48:                                               ; preds = %53, %42
  %49 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %50 = sext i32 %40 to i64
  %51 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %49, i64 0, i64 %50
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %51, i8 0, i64 16, i1 false)
  store i64 %9, ptr %51, align 8, !tbaa !70
  %52 = add nsw i32 %17, 1
  store i32 %52, ptr %16, align 4, !tbaa !26
  br label %59

53:                                               ; preds = %53, %44
  %54 = phi i64 [ %46, %44 ], [ %55, %53 ]
  %55 = add nsw i64 %54, -1
  %56 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %45, i64 0, i64 %55
  %57 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %45, i64 0, i64 %54
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %57, ptr noundef nonnull align 8 dereferenceable(1552) %56, i64 1552, i1 false), !tbaa.struct !74
  %58 = icmp sgt i64 %55, %47
  br i1 %58, label %53, label %48, !llvm.loop !75

59:                                               ; preds = %48, %39, %24
  %60 = phi i32 [ %40, %48 ], [ -1, %39 ], [ %30, %24 ]
  %61 = icmp slt i32 %60, 0
  br i1 %61, label %79, label %62

62:                                               ; preds = %59
  %63 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %64 = zext nneg i32 %60 to i64
  %65 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %63, i64 0, i64 %64
  %66 = getelementptr inbounds nuw i8, ptr %65, i64 12
  %67 = load i32, ptr %66, align 4, !tbaa !76
  %68 = icmp slt i32 %67, 64
  br i1 %68, label %69, label %79

69:                                               ; preds = %62
  %70 = getelementptr inbounds nuw i8, ptr %65, i64 16
  %71 = add nsw i32 %67, 1
  store i32 %71, ptr %66, align 4, !tbaa !76
  %72 = sext i32 %67 to i64
  %73 = getelementptr inbounds nuw [64 x %struct.Order], ptr %70, i64 0, i64 %72
  store i64 %11, ptr %73, align 8, !tbaa !5
  %74 = getelementptr inbounds nuw i8, ptr %73, i64 8
  store i32 %13, ptr %74, align 8, !tbaa !42
  %75 = getelementptr inbounds nuw i8, ptr %73, i64 16
  store i64 %15, ptr %75, align 8, !tbaa !5
  %76 = getelementptr inbounds nuw i8, ptr %65, i64 8
  %77 = load i32, ptr %76, align 8, !tbaa !77
  %78 = add nsw i32 %77, %13
  store i32 %78, ptr %76, align 8, !tbaa !77
  br label %79

79:                                               ; preds = %69, %62, %59
  %80 = phi i1 [ false, %59 ], [ false, %62 ], [ true, %69 ]
  br i1 %80, label %83, label %81

81:                                               ; preds = %79
  %82 = getelementptr inbounds nuw i8, ptr %0, i64 794736
  %rmw.old = load i64, ptr %82, align 8
  %rmw.new = add i64 %rmw.old, 1
  store i64 %rmw.new, ptr %82, align 8
  br label %83

83:                                               ; preds = %81, %79
  ret i1 %80
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZN17MarketDataHandler12handleModifyERK17MarketDataMessage(ptr noundef nonnull align 64 dereferenceable(794880) %0, ptr noundef nonnull align 1 dereferenceable(40) %1) local_unnamed_addr #3 comdat align 2 {
  %3 = getelementptr inbounds nuw i8, ptr %1, i64 1
  %4 = load i8, ptr %3, align 1, !tbaa !59
  %5 = icmp eq i8 %4, 66
  %6 = select i1 %5, i64 0, i64 397320
  %7 = getelementptr inbounds nuw i8, ptr %0, i64 %6
  %8 = getelementptr inbounds nuw i8, ptr %1, i64 12
  %9 = load i64, ptr %8, align 1, !tbaa !60
  %10 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %11 = load i64, ptr %10, align 1, !tbaa !61
  %12 = tail call noundef zeroext i1 @_ZN8BookSide11removeOrderElmi(ptr noundef nonnull align 8 dereferenceable(397320) %7, i64 noundef %9, i64 noundef %11, i32 noundef 0)
  br i1 %12, label %13, label %83

13:                                               ; preds = %2
  %14 = load i64, ptr %8, align 1, !tbaa !60
  %15 = load i64, ptr %10, align 1, !tbaa !61
  %16 = getelementptr inbounds nuw i8, ptr %1, i64 20
  %17 = load i32, ptr %16, align 1, !tbaa !62
  %18 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %19 = load i64, ptr %18, align 1, !tbaa !54
  %20 = getelementptr inbounds nuw i8, ptr %7, i64 4
  %21 = load i32, ptr %20, align 4, !tbaa !26
  %22 = icmp sgt i32 %21, 0
  br i1 %22, label %23, label %43

23:                                               ; preds = %13
  %24 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %25 = load i8, ptr %7, align 8, !range !69
  %26 = trunc nuw i8 %25 to i1
  %27 = zext nneg i32 %21 to i64
  br label %28

28:                                               ; preds = %35, %23
  %29 = phi i64 [ 0, %23 ], [ %41, %35 ]
  %30 = phi i32 [ 0, %23 ], [ %40, %35 ]
  %31 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %24, i64 0, i64 %29
  %32 = load i64, ptr %31, align 8, !tbaa !70
  %33 = icmp eq i64 %32, %14
  %34 = trunc i64 %29 to i32
  br i1 %33, label %63, label %35

35:                                               ; preds = %28
  %36 = add i32 %34, 1
  %37 = icmp slt i64 %32, %14
  %38 = icmp sgt i64 %32, %14
  %39 = select i1 %26, i1 %38, i1 %37
  %40 = select i1 %39, i32 %36, i32 %30
  %41 = add nuw nsw i64 %29, 1
  %42 = icmp eq i64 %41, %27
  br i1 %42, label %43, label %28, !llvm.loop !73

43:                                               ; preds = %35, %13
  %44 = phi i32 [ 0, %13 ], [ %40, %35 ]
  %45 = icmp sgt i32 %21, 255
  br i1 %45, label %63, label %46

46:                                               ; preds = %43
  %47 = icmp sgt i32 %21, %44
  br i1 %47, label %48, label %52

48:                                               ; preds = %46
  %49 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %50 = sext i32 %21 to i64
  %51 = sext i32 %44 to i64
  br label %57

52:                                               ; preds = %57, %46
  %53 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %54 = sext i32 %44 to i64
  %55 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %53, i64 0, i64 %54
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %55, i8 0, i64 16, i1 false)
  store i64 %14, ptr %55, align 8, !tbaa !70
  %56 = add nsw i32 %21, 1
  store i32 %56, ptr %20, align 4, !tbaa !26
  br label %63

57:                                               ; preds = %57, %48
  %58 = phi i64 [ %50, %48 ], [ %59, %57 ]
  %59 = add nsw i64 %58, -1
  %60 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %49, i64 0, i64 %59
  %61 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %49, i64 0, i64 %58
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %61, ptr noundef nonnull align 8 dereferenceable(1552) %60, i64 1552, i1 false), !tbaa.struct !74
  %62 = icmp sgt i64 %59, %51
  br i1 %62, label %57, label %52, !llvm.loop !75

63:                                               ; preds = %52, %43, %28
  %64 = phi i32 [ %44, %52 ], [ -1, %43 ], [ %34, %28 ]
  %65 = icmp slt i32 %64, 0
  br i1 %65, label %83, label %66

66:                                               ; preds = %63
  %67 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %68 = zext nneg i32 %64 to i64
  %69 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %67, i64 0, i64 %68
  %70 = getelementptr inbounds nuw i8, ptr %69, i64 12
  %71 = load i32, ptr %70, align 4, !tbaa !76
  %72 = icmp slt i32 %71, 64
  br i1 %72, label %73, label %83

73:                                               ; preds = %66
  %74 = getelementptr inbounds nuw i8, ptr %69, i64 16
  %75 = add nsw i32 %71, 1
  store i32 %75, ptr %70, align 4, !tbaa !76
  %76 = sext i32 %71 to i64
  %77 = getelementptr inbounds nuw [64 x %struct.Order], ptr %74, i64 0, i64 %76
  store i64 %15, ptr %77, align 8, !tbaa !5
  %78 = getelementptr inbounds nuw i8, ptr %77, i64 8
  store i32 %17, ptr %78, align 8, !tbaa !42
  %79 = getelementptr inbounds nuw i8, ptr %77, i64 16
  store i64 %19, ptr %79, align 8, !tbaa !5
  %80 = getelementptr inbounds nuw i8, ptr %69, i64 8
  %81 = load i32, ptr %80, align 8, !tbaa !77
  %82 = add nsw i32 %81, %17
  store i32 %82, ptr %80, align 8, !tbaa !77
  br label %83

83:                                               ; preds = %73, %66, %63, %2
  %84 = phi i1 [ false, %2 ], [ false, %63 ], [ false, %66 ], [ true, %73 ]
  ret i1 %84
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local noundef zeroext i1 @_ZN8BookSide11removeOrderElmi(ptr noundef nonnull align 8 dereferenceable(397320) %0, i64 noundef %1, i64 noundef %2, i32 noundef %3) local_unnamed_addr #3 comdat align 2 {
  %5 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %7 = load i32, ptr %6, align 4, !tbaa !26
  %8 = icmp sgt i32 %7, 0
  br i1 %8, label %9, label %21

9:                                                ; preds = %4
  %10 = zext nneg i32 %7 to i64
  br label %11

11:                                               ; preds = %16, %9
  %12 = phi i64 [ 0, %9 ], [ %17, %16 ]
  %13 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %5, i64 0, i64 %12
  %14 = load i64, ptr %13, align 8, !tbaa !70
  %15 = icmp eq i64 %14, %1
  br i1 %15, label %19, label %16

16:                                               ; preds = %11
  %17 = add nuw nsw i64 %12, 1
  %18 = icmp eq i64 %17, %10
  br i1 %18, label %21, label %11, !llvm.loop !78

19:                                               ; preds = %11
  %20 = trunc nuw nsw i64 %12 to i32
  br label %21

21:                                               ; preds = %19, %16, %4
  %22 = phi i32 [ -1, %4 ], [ %20, %19 ], [ -1, %16 ]
  %23 = icmp slt i32 %22, 0
  br i1 %23, label %84, label %24

24:                                               ; preds = %21
  %25 = zext nneg i32 %22 to i64
  %26 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %5, i64 0, i64 %25
  %27 = getelementptr inbounds nuw i8, ptr %26, i64 12
  %28 = load i32, ptr %27, align 4, !tbaa !76
  %29 = icmp sgt i32 %28, 0
  br i1 %29, label %30, label %63

30:                                               ; preds = %24
  %31 = getelementptr inbounds nuw i8, ptr %26, i64 16
  %32 = zext nneg i32 %28 to i64
  br label %33

33:                                               ; preds = %60, %30
  %34 = phi i64 [ 0, %30 ], [ %61, %60 ]
  %35 = getelementptr inbounds nuw [64 x %struct.Order], ptr %31, i64 0, i64 %34
  %36 = load i64, ptr %35, align 8, !tbaa !27
  %37 = icmp eq i64 %36, %2
  br i1 %37, label %38, label %60

38:                                               ; preds = %33
  %39 = getelementptr inbounds nuw i8, ptr %35, i64 8
  %40 = load i32, ptr %39, align 4, !tbaa !42
  %41 = tail call i32 @llvm.smin.i32(i32 %40, i32 %3)
  %42 = getelementptr inbounds nuw i8, ptr %26, i64 8
  %43 = load i32, ptr %42, align 8, !tbaa !77
  %44 = sub nsw i32 %43, %41
  store i32 %44, ptr %42, align 8, !tbaa !77
  %45 = sub nsw i32 %40, %3
  store i32 %45, ptr %39, align 8, !tbaa !29
  %46 = icmp slt i32 %45, 1
  br i1 %46, label %47, label %63

47:                                               ; preds = %38
  %48 = trunc nuw nsw i64 %34 to i32
  %49 = add nsw i32 %28, -1
  %50 = icmp sgt i32 %49, %48
  br i1 %50, label %51, label %53

51:                                               ; preds = %47
  %52 = zext i32 %49 to i64
  br label %54

53:                                               ; preds = %54, %47
  store i32 %49, ptr %27, align 4, !tbaa !76
  br label %63

54:                                               ; preds = %54, %51
  %55 = phi i64 [ %34, %51 ], [ %56, %54 ]
  %56 = add nuw nsw i64 %55, 1
  %57 = getelementptr inbounds nuw [64 x %struct.Order], ptr %31, i64 0, i64 %56
  %58 = getelementptr inbounds nuw [64 x %struct.Order], ptr %31, i64 0, i64 %55
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %58, ptr noundef nonnull align 8 dereferenceable(24) %57, i64 24, i1 false), !tbaa.struct !79
  %59 = icmp eq i64 %56, %52
  br i1 %59, label %53, label %54, !llvm.loop !80

60:                                               ; preds = %33
  %61 = add nuw nsw i64 %34, 1
  %62 = icmp eq i64 %61, %32
  br i1 %62, label %63, label %33, !llvm.loop !81

63:                                               ; preds = %60, %53, %38, %24
  %64 = phi i1 [ true, %38 ], [ true, %53 ], [ false, %24 ], [ false, %60 ]
  %65 = load i32, ptr %27, align 4, !tbaa !76
  %66 = icmp eq i32 %65, 0
  br i1 %66, label %67, label %84

67:                                               ; preds = %63
  %68 = add nsw i32 %7, -1
  %69 = icmp slt i32 %22, %68
  br i1 %69, label %70, label %79

70:                                               ; preds = %67
  %71 = zext nneg i32 %22 to i64
  %72 = sext i32 %68 to i64
  br label %73

73:                                               ; preds = %73, %70
  %74 = phi i64 [ %71, %70 ], [ %75, %73 ]
  %75 = add nuw nsw i64 %74, 1
  %76 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %5, i64 0, i64 %75
  %77 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %5, i64 0, i64 %74
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %77, ptr noundef nonnull align 8 dereferenceable(1552) %76, i64 1552, i1 false), !tbaa.struct !74
  %78 = icmp eq i64 %75, %72
  br i1 %78, label %79, label %73, !llvm.loop !82

79:                                               ; preds = %73, %67
  %80 = sext i32 %68 to i64
  %81 = getelementptr inbounds nuw [256 x %struct.PriceLevel], ptr %5, i64 0, i64 %80
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(1552) %81, i8 0, i64 16, i1 false)
  %82 = load i32, ptr %6, align 4, !tbaa !26
  %83 = add nsw i32 %82, -1
  store i32 %83, ptr %6, align 4, !tbaa !26
  br label %84

84:                                               ; preds = %79, %63, %21
  %85 = phi i1 [ false, %21 ], [ %64, %79 ], [ %64, %63 ]
  ret i1 %85
}

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8), ptr noundef, i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIlEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIdEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), double noundef) local_unnamed_addr #0

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_orderbook.cpp() #14 section ".text.startup" {
  tail call void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %1 = tail call i32 @__cxa_atexit(ptr nonnull @_ZNSt8ios_base4InitD1Ev, ptr nonnull @_ZStL8__ioinit, ptr nonnull @__dso_handle) #16
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #9

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #9

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #15

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare x86_fp80 @llvm.log.f80(x86_fp80) #9

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #9

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #9

attributes #0 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind }
attributes #3 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress norecurse uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress noinline uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #9 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #10 = { inlinehint mustprogress nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #14 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #15 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #16 = { nounwind }
attributes #17 = { builtin nounwind }
attributes #18 = { noreturn }
attributes #19 = { builtin allocsize(0) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 20.1.8 (https://github.com/llvm/llvm-project.git 87f0227cb60147a26a1eeb4fb06e3b505e9c7261)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"long", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.unroll.disable"}
!12 = !{!13, !6, i64 2496}
!13 = !{!"_ZTSSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE", !7, i64 0, !6, i64 2496}
!14 = !{!15, !15, i64 0}
!15 = !{!"p1 _ZTS17MarketDataMessage", !16, i64 0}
!16 = !{!"any pointer", !7, i64 0}
!17 = distinct !{!17, !11}
!18 = !{!19, !15, i64 0}
!19 = !{!"_ZTSNSt12_Vector_baseI17MarketDataMessageSaIS0_EE17_Vector_impl_dataE", !15, i64 0, !15, i64 8, !15, i64 16}
!20 = !{!19, !15, i64 16}
!21 = !{!22, !23, i64 0}
!22 = !{!"_ZTS8BookSide", !23, i64 0, !24, i64 4, !25, i64 8}
!23 = !{!"bool", !7, i64 0}
!24 = !{!"int", !7, i64 0}
!25 = !{!"_ZTSSt5arrayI10PriceLevelLm256EE", !7, i64 0}
!26 = !{!22, !24, i64 4}
!27 = !{!28, !6, i64 0}
!28 = !{!"_ZTS5Order", !6, i64 0, !24, i64 8, !6, i64 16}
!29 = !{!28, !24, i64 8}
!30 = !{!28, !6, i64 16}
!31 = distinct !{!31, !11}
!32 = !{!19, !15, i64 8}
!33 = !{i64 0, i64 32, !34}
!34 = !{!7, !7, i64 0}
!35 = !{!36, !37, i64 0}
!36 = !{!"_ZTSNSt12_Vector_baseIdSaIdEE17_Vector_impl_dataE", !37, i64 0, !37, i64 8, !37, i64 16}
!37 = !{!"p1 double", !16, i64 0}
!38 = !{!36, !37, i64 16}
!39 = !{!37, !37, i64 0}
!40 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!41 = distinct !{!41, !10, !11}
!42 = !{!24, !24, i64 0}
!43 = !{!44, !44, i64 0}
!44 = !{!"double", !7, i64 0}
!45 = distinct !{!45, !10, !11}
!46 = distinct !{!46, !10, !11}
!47 = !{!48, !48, i64 0}
!48 = !{!"_ZTS11MessageType", !7, i64 0}
!49 = !{!50, !50, i64 0}
!50 = !{!"_ZTS4Side", !7, i64 0}
!51 = !{!52, !52, i64 0}
!52 = !{!"short", !7, i64 0}
!53 = distinct !{!53, !10, !11}
!54 = !{!55, !6, i64 24}
!55 = !{!"_ZTS17MarketDataMessage", !48, i64 0, !50, i64 1, !52, i64 2, !6, i64 4, !6, i64 12, !24, i64 20, !6, i64 24, !6, i64 32}
!56 = !{!55, !6, i64 32}
!57 = distinct !{!57, !10, !11}
!58 = !{!55, !48, i64 0}
!59 = !{!55, !50, i64 1}
!60 = !{!55, !6, i64 12}
!61 = !{!55, !6, i64 4}
!62 = !{!55, !24, i64 20}
!63 = distinct !{!63, !10, !11}
!64 = distinct !{!64, !10, !11}
!65 = !{!36, !37, i64 8}
!66 = distinct !{!66, !10, !11}
!67 = distinct !{!67, !10, !11}
!68 = distinct !{!68, !10, !11}
!69 = !{i8 0, i8 2}
!70 = !{!71, !6, i64 0}
!71 = !{!"_ZTS10PriceLevel", !6, i64 0, !24, i64 8, !24, i64 12, !72, i64 16}
!72 = !{!"_ZTSSt5arrayI5OrderLm64EE", !7, i64 0}
!73 = distinct !{!73, !10, !11}
!74 = !{i64 0, i64 8, !5, i64 8, i64 4, !42, i64 12, i64 4, !42, i64 16, i64 1536, !34}
!75 = distinct !{!75, !10, !11}
!76 = !{!71, !24, i64 12}
!77 = !{!71, !24, i64 8}
!78 = distinct !{!78, !10, !11}
!79 = !{i64 0, i64 8, !5, i64 8, i64 4, !42, i64 16, i64 8, !5}
!80 = distinct !{!80, !10, !11}
!81 = distinct !{!81, !10, !11}
!82 = distinct !{!82, !10, !11}
