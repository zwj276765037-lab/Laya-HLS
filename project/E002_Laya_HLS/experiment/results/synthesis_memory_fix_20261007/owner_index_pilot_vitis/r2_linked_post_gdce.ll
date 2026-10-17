; ModuleID = 'build/owner-index-pilot-vitis/csynth_r2/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.laya::full::FullRuntime" = type { %"struct.laya::full::FullInputs", %"struct.laya::full::FullOwners", %"struct.laya::full::FullCache", %"struct.laya::full::FullWeightDescriptor", %"struct.laya::BufferRef", [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"], %"struct.laya::BufferRef", %"struct.laya::BufferRef", %"struct.laya::BufferRef", %"struct.laya::BufferRef", [2 x %"struct.laya::BufferRef"], i8, i8, i8, i8, i8, i16, i1, %"struct.laya::full::FullOwnerSpec", [4 x %"struct.laya::full::FullOwnerSpec"], i8, i8, i8, i32, i32, [256 x i32], i32, i32, i8, i8, i64, i64, i64, i64, i16, i16, i1, i1, %"struct.laya::Check", %"struct.laya::Check", %"struct.laya::Check", i1, i1, i1 }
%"struct.laya::full::FullInputs" = type { %"struct.laya::NumericIdentity", [2 x [1024 x i32]], [2 x [16 x i32]], [2 x [1024 x i8]], [2 x [16 x i8]], [2 x i8] }
%"struct.laya::NumericIdentity" = type { i64, i64, i16, i16, [16 x i8], [16 x i8], [16 x i8], [16 x i8] }
%"struct.laya::full::FullOwners" = type { [32 x %"struct.laya::full::FullOwnerRecord"], [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]], [16 x [2 x [32 x i32]]], [2 x i16], [2 x i16], [3 x i1] }
%"struct.laya::full::FullOwnerRecord" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", %"struct.laya::BufferRef", i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i8, [64 x i32], [64 x i32], i1 }
%"struct.laya::full::FullCache" = type { %"struct.laya::F32TileMeta", %"struct.laya::A8TileMeta" }
%"struct.laya::F32TileMeta" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", i8, i8, i8, i16, i8, i16, i8, i8, i8, [16 x [4 x i32]], i1 }
%"struct.laya::A8TileMeta" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", %"struct.laya::F32TileMeta", i32, i8, i8, i8, i8, i16, i8, i16, [16 x [4 x i32]], i8, i8, i8, i1 }
%"struct.laya::full::FullWeightDescriptor" = type { [48 x i8], %"struct.laya::WeightKey", i16, i16, i8, i8, [2 x i32], [2 x i32], i32, i32, i32, i32, i32, i32, [32 x i8], [32 x i8] }
%"struct.laya::WeightKey" = type { i8, i8 }
%"struct.laya::BufferRef" = type { i8, i8, i32 }
%"struct.laya::full::FullOwnerSpec" = type { %"struct.laya::BufferRef", i8, i8, i8, i8, i8, i16, i16, i16, i8 }
%"struct.laya::Check" = type { i16, i32, i64 }

$_ZN4laya2okEv = comdat any

$_ZN4laya6detailEhht = comdat any

$_ZN4laya4noneEv = comdat any

$_ZNK4laya5CheckcvbEv = comdat any

$_ZN4layaneENS_9BufferRefES0_ = comdat any

$_ZN4layaeqENS_9BufferRefES0_ = comdat any

@llvm.global_ctors = appending global [0 x { i32, void ()*, i8* }] zeroinitializer
@_ZZN4laya4full12_GLOBAL__N_111legal_widthENS_6BufferEhE6widths = internal constant [8 x i16] [i16 1024, i16 1028, i16 256, i16 16, i16 2, i16 4, i16 16, i16 16], align 2, !dbg !0
@_ZN12_GLOBAL__N_17runtimeE = internal global %"struct.laya::full::FullRuntime" { %"struct.laya::full::FullInputs" zeroinitializer, %"struct.laya::full::FullOwners" { [32 x %"struct.laya::full::FullOwnerRecord"] [%"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }], [2 x [3 x [16 x [2 x [32 x i32]]]]] zeroinitializer, [2 x [2 x [16 x [2 x [32 x i32]]]]] zeroinitializer, [16 x [2 x [32 x i32]]] zeroinitializer, [2 x i16] zeroinitializer, [2 x i16] zeroinitializer, [3 x i1] zeroinitializer }, %"struct.laya::full::FullCache" { %"struct.laya::F32TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 0, i16 0, i8 0, i16 0, i8 6, i8 0, i8 0, [16 x [4 x i32]] zeroinitializer, i1 false }, %"struct.laya::A8TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::F32TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 0, i16 0, i8 0, i16 0, i8 6, i8 0, i8 0, [16 x [4 x i32]] zeroinitializer, i1 false }, i32 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i8 0, i16 0, [16 x [4 x i32]] zeroinitializer, i8 6, i8 0, i8 0, i1 false } }, %"struct.laya::full::FullWeightDescriptor" { [48 x i8] zeroinitializer, %"struct.laya::WeightKey" { i8 0, i8 -1 }, i16 0, i16 0, i8 0, i8 0, [2 x i32] zeroinitializer, [2 x i32] zeroinitializer, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, [32 x i8] zeroinitializer, [32 x i8] zeroinitializer }, %"struct.laya::BufferRef" zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, i8 -1, i8 0, i8 -1, i8 -1, i8 0, i16 0, i1 false, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, [4 x %"struct.laya::full::FullOwnerSpec"] [%"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }], i8 0, i8 -1, i8 -1, i32 0, i32 0, [256 x i32] zeroinitializer, i32 0, i32 0, i8 0, i8 0, i64 0, i64 0, i64 0, i64 0, i16 0, i16 0, i1 false, i1 false, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, i1 false, i1 false, i1 false }, align 8, !dbg !995

; Function Attrs: nounwind
define dso_local void @_ZN4laya9check_refENS_9BufferRefEh(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %r, i8 zeroext %region) #0 !dbg !1527 {
entry:
  %region.addr = alloca i8, align 1
  %id17 = alloca i8, align 1
  %valid = alloca i1, align 1
  %cleanup.dest.slot = alloca i32, align 4
  %dual = alloca i1, align 1
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %r, metadata !1531, metadata !DIExpression()), !dbg !1532
  store i8 %region, i8* %region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %region.addr, metadata !1533, metadata !DIExpression()), !dbg !1534
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 0, !dbg !1535
  %0 = load i8, i8* %id, align 4, !dbg !1535
  %cmp = icmp eq i8 %0, 0, !dbg !1537
  br i1 %cmp, label %if.then, label %if.end, !dbg !1538

if.then:                                          ; preds = %entry
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 1, !dbg !1539
  %1 = load i8, i8* %bank, align 1, !dbg !1539
  %conv = zext i8 %1 to i32, !dbg !1540
  %cmp1 = icmp eq i32 %conv, 0, !dbg !1541
  br i1 %cmp1, label %land.lhs.true, label %cond.false, !dbg !1542

land.lhs.true:                                    ; preds = %if.then
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 2, !dbg !1543
  %2 = load i32, i32* %epoch, align 4, !dbg !1543
  %cmp2 = icmp eq i32 %2, 0, !dbg !1544
  br i1 %cmp2, label %land.lhs.true3, label %cond.false, !dbg !1545

land.lhs.true3:                                   ; preds = %land.lhs.true
  %3 = load i8, i8* %region.addr, align 1, !dbg !1546
  %conv4 = zext i8 %3 to i32, !dbg !1546
  %cmp5 = icmp eq i32 %conv4, 0, !dbg !1547
  br i1 %cmp5, label %cond.true, label %cond.false, !dbg !1540

cond.true:                                        ; preds = %land.lhs.true3
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !1548
  br label %cond.end, !dbg !1540

cond.false:                                       ; preds = %land.lhs.true3, %land.lhs.true, %if.then
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1549
  store i16 5, i16* %code, align 8, !dbg !1549
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1549
  %call = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext 0, i16 zeroext 9), !dbg !1550
  store i32 %call, i32* %detail, align 4, !dbg !1549
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1549
  store i64 -1, i64* %bad_element, align 8, !dbg !1549
  br label %cond.end, !dbg !1540

cond.end:                                         ; preds = %cond.false, %cond.true
  br label %return, !dbg !1551

if.end:                                           ; preds = %entry
  %epoch6 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 2, !dbg !1552
  %4 = load i32, i32* %epoch6, align 4, !dbg !1552
  %cmp7 = icmp eq i32 %4, 0, !dbg !1554
  br i1 %cmp7, label %if.then10, label %lor.lhs.false, !dbg !1555

lor.lhs.false:                                    ; preds = %if.end
  %epoch8 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 2, !dbg !1556
  %5 = load i32, i32* %epoch8, align 4, !dbg !1556
  %cmp9 = icmp ugt i32 %5, -2, !dbg !1557
  br i1 %cmp9, label %if.then10, label %if.end16, !dbg !1558

if.then10:                                        ; preds = %lor.lhs.false, %if.end
  %code11 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1559
  store i16 5, i16* %code11, align 8, !dbg !1559
  %detail12 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1559
  %id13 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 0, !dbg !1560
  %6 = load i8, i8* %id13, align 4, !dbg !1560
  %call14 = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %6, i16 zeroext 9), !dbg !1561
  store i32 %call14, i32* %detail12, align 4, !dbg !1559
  %bad_element15 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1559
  store i64 -1, i64* %bad_element15, align 8, !dbg !1559
  br label %return, !dbg !1562

if.end16:                                         ; preds = %lor.lhs.false
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %id17) #31, !dbg !1563
  call void @llvm.dbg.declare(metadata i8* %id17, metadata !1564, metadata !DIExpression()), !dbg !1565
  %id18 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 0, !dbg !1566
  %7 = load i8, i8* %id18, align 4, !dbg !1566
  store i8 %7, i8* %id17, align 1, !dbg !1565
  %8 = bitcast i1* %valid to i8*, !dbg !1567
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %8) #31, !dbg !1567
  call void @llvm.dbg.declare(metadata i1* %valid, metadata !1568, metadata !DIExpression()), !dbg !1569
  %9 = load i8, i8* %id17, align 1, !dbg !1570
  %conv19 = zext i8 %9 to i32, !dbg !1570
  %cmp20 = icmp sge i32 %conv19, 1, !dbg !1571
  br i1 %cmp20, label %land.lhs.true21, label %lor.rhs, !dbg !1572

land.lhs.true21:                                  ; preds = %if.end16
  %10 = load i8, i8* %id17, align 1, !dbg !1573
  %conv22 = zext i8 %10 to i32, !dbg !1573
  %cmp23 = icmp sle i32 %conv22, 11, !dbg !1574
  br i1 %cmp23, label %lor.end, label %lor.rhs, !dbg !1575

lor.rhs:                                          ; preds = %land.lhs.true21, %if.end16
  %11 = load i8, i8* %id17, align 1, !dbg !1576
  %conv24 = zext i8 %11 to i32, !dbg !1576
  %cmp25 = icmp sge i32 %conv24, 32, !dbg !1577
  br i1 %cmp25, label %land.rhs, label %land.end, !dbg !1578

land.rhs:                                         ; preds = %lor.rhs
  %12 = load i8, i8* %id17, align 1, !dbg !1579
  %conv26 = zext i8 %12 to i32, !dbg !1579
  %cmp27 = icmp sle i32 %conv26, 43, !dbg !1580
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %13 = phi i1 [ false, %lor.rhs ], [ %cmp27, %land.rhs ], !dbg !1581
  br label %lor.end, !dbg !1575

lor.end:                                          ; preds = %land.end, %land.lhs.true21
  %14 = phi i1 [ true, %land.lhs.true21 ], [ %13, %land.end ]
  store i1 %14, i1* %valid, align 1, !dbg !1569
  %15 = load i1, i1* %valid, align 1, !dbg !1582
  br i1 %15, label %if.end33, label %if.then28, !dbg !1584

if.then28:                                        ; preds = %lor.end
  %code29 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1585
  store i16 5, i16* %code29, align 8, !dbg !1585
  %detail30 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1585
  %16 = load i8, i8* %id17, align 1, !dbg !1586
  %call31 = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %16, i16 zeroext 4), !dbg !1587
  store i32 %call31, i32* %detail30, align 4, !dbg !1585
  %bad_element32 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1585
  store i64 -1, i64* %bad_element32, align 8, !dbg !1585
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup87, !dbg !1588

if.end33:                                         ; preds = %lor.end
  %17 = bitcast i1* %dual to i8*, !dbg !1589
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %17) #31, !dbg !1589
  call void @llvm.dbg.declare(metadata i1* %dual, metadata !1590, metadata !DIExpression()), !dbg !1591
  %18 = load i8, i8* %id17, align 1, !dbg !1592
  %conv34 = zext i8 %18 to i32, !dbg !1592
  %cmp35 = icmp eq i32 %conv34, 1, !dbg !1593
  br i1 %cmp35, label %lor.end52, label %lor.lhs.false36, !dbg !1594

lor.lhs.false36:                                  ; preds = %if.end33
  %19 = load i8, i8* %id17, align 1, !dbg !1595
  %conv37 = zext i8 %19 to i32, !dbg !1595
  %cmp38 = icmp eq i32 %conv37, 5, !dbg !1596
  br i1 %cmp38, label %lor.end52, label %lor.rhs39, !dbg !1597

lor.rhs39:                                        ; preds = %lor.lhs.false36
  %20 = load i8, i8* %id17, align 1, !dbg !1598
  %conv40 = zext i8 %20 to i32, !dbg !1598
  %cmp41 = icmp sge i32 %conv40, 32, !dbg !1599
  br i1 %cmp41, label %land.lhs.true42, label %land.end51, !dbg !1600

land.lhs.true42:                                  ; preds = %lor.rhs39
  %21 = load i8, i8* %id17, align 1, !dbg !1601
  %conv43 = zext i8 %21 to i32, !dbg !1601
  %cmp44 = icmp sle i32 %conv43, 43, !dbg !1602
  br i1 %cmp44, label %land.lhs.true45, label %land.end51, !dbg !1603

land.lhs.true45:                                  ; preds = %land.lhs.true42
  %22 = load i8, i8* %id17, align 1, !dbg !1604
  %conv46 = zext i8 %22 to i32, !dbg !1604
  %cmp47 = icmp ne i32 %conv46, 42, !dbg !1605
  br i1 %cmp47, label %land.rhs48, label %land.end51, !dbg !1606

land.rhs48:                                       ; preds = %land.lhs.true45
  %23 = load i8, i8* %id17, align 1, !dbg !1607
  %conv49 = zext i8 %23 to i32, !dbg !1607
  %cmp50 = icmp ne i32 %conv49, 43, !dbg !1608
  br label %land.end51

land.end51:                                       ; preds = %land.rhs48, %land.lhs.true45, %land.lhs.true42, %lor.rhs39
  %24 = phi i1 [ false, %land.lhs.true45 ], [ false, %land.lhs.true42 ], [ false, %lor.rhs39 ], [ %cmp50, %land.rhs48 ], !dbg !1581
  br label %lor.end52, !dbg !1597

lor.end52:                                        ; preds = %land.end51, %lor.lhs.false36, %if.end33
  %25 = phi i1 [ true, %lor.lhs.false36 ], [ true, %if.end33 ], [ %24, %land.end51 ]
  store i1 %25, i1* %dual, align 1, !dbg !1591
  %26 = load i8, i8* %id17, align 1, !dbg !1609
  %conv53 = zext i8 %26 to i32, !dbg !1609
  %cmp54 = icmp eq i32 %conv53, 42, !dbg !1611
  br i1 %cmp54, label %if.then58, label %lor.lhs.false55, !dbg !1612

lor.lhs.false55:                                  ; preds = %lor.end52
  %27 = load i8, i8* %id17, align 1, !dbg !1613
  %conv56 = zext i8 %27 to i32, !dbg !1613
  %cmp57 = icmp eq i32 %conv56, 43, !dbg !1614
  br i1 %cmp57, label %if.then58, label %if.end59, !dbg !1615

if.then58:                                        ; preds = %lor.lhs.false55, %lor.end52
  store i1 true, i1* %dual, align 1, !dbg !1616
  br label %if.end59, !dbg !1617

if.end59:                                         ; preds = %if.then58, %lor.lhs.false55
  %bank60 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %r, i32 0, i32 1, !dbg !1618
  %28 = load i8, i8* %bank60, align 1, !dbg !1618
  %conv61 = zext i8 %28 to i32, !dbg !1620
  %29 = load i1, i1* %dual, align 1, !dbg !1621
  %30 = zext i1 %29 to i64, !dbg !1621
  %cond = select i1 %29, i32 1, i32 0, !dbg !1621
  %cmp62 = icmp sgt i32 %conv61, %cond, !dbg !1622
  br i1 %cmp62, label %if.then63, label %if.end68, !dbg !1623

if.then63:                                        ; preds = %if.end59
  %code64 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1624
  store i16 5, i16* %code64, align 8, !dbg !1624
  %detail65 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1624
  %31 = load i8, i8* %id17, align 1, !dbg !1625
  %call66 = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %31, i16 zeroext 4), !dbg !1626
  store i32 %call66, i32* %detail65, align 4, !dbg !1624
  %bad_element67 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1624
  store i64 -1, i64* %bad_element67, align 8, !dbg !1624
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1627

if.end68:                                         ; preds = %if.end59
  %32 = load i8, i8* %id17, align 1, !dbg !1628
  %conv69 = zext i8 %32 to i32, !dbg !1628
  %cmp70 = icmp eq i32 %conv69, 10, !dbg !1630
  br i1 %cmp70, label %if.then71, label %if.else, !dbg !1631

if.then71:                                        ; preds = %if.end68
  %33 = load i8, i8* %region.addr, align 1, !dbg !1632
  %conv72 = zext i8 %33 to i32, !dbg !1632
  %cmp73 = icmp sgt i32 %conv72, 7, !dbg !1635
  br i1 %cmp73, label %if.then74, label %if.end79, !dbg !1636

if.then74:                                        ; preds = %if.then71
  %code75 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1637
  store i16 5, i16* %code75, align 8, !dbg !1637
  %detail76 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1637
  %34 = load i8, i8* %id17, align 1, !dbg !1638
  %call77 = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %34, i16 zeroext 4), !dbg !1639
  store i32 %call77, i32* %detail76, align 4, !dbg !1637
  %bad_element78 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1637
  store i64 -1, i64* %bad_element78, align 8, !dbg !1637
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1640

if.end79:                                         ; preds = %if.then71
  br label %if.end86, !dbg !1641

if.else:                                          ; preds = %if.end68
  %35 = load i8, i8* %region.addr, align 1, !dbg !1642
  %tobool = icmp ne i8 %35, 0, !dbg !1642
  br i1 %tobool, label %if.then80, label %if.end85, !dbg !1644

if.then80:                                        ; preds = %if.else
  %code81 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1645
  store i16 5, i16* %code81, align 8, !dbg !1645
  %detail82 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1645
  %36 = load i8, i8* %id17, align 1, !dbg !1646
  %call83 = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %36, i16 zeroext 4), !dbg !1647
  store i32 %call83, i32* %detail82, align 4, !dbg !1645
  %bad_element84 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1645
  store i64 -1, i64* %bad_element84, align 8, !dbg !1645
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1648

if.end85:                                         ; preds = %if.else
  br label %if.end86

if.end86:                                         ; preds = %if.end85, %if.end79
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !1649
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1650

cleanup:                                          ; preds = %if.end86, %if.then80, %if.then74, %if.then63
  %37 = bitcast i1* %dual to i8*, !dbg !1651
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %37) #31, !dbg !1651
  br label %cleanup87

cleanup87:                                        ; preds = %cleanup, %if.then28
  %38 = bitcast i1* %valid to i8*, !dbg !1651
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %38) #31, !dbg !1651
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %id17) #31, !dbg !1651
  br label %return

return:                                           ; preds = %cleanup87, %if.then10, %cond.end
  ret void, !dbg !1651
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nounwind
define linkonce_odr dso_local void @_ZN4laya2okEv(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result) #2 comdat !dbg !1652 {
entry:
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !1655
  store i16 0, i16* %code, align 8, !dbg !1655
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !1655
  store i32 0, i32* %detail, align 4, !dbg !1655
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !1655
  store i64 -1, i64* %bad_element, align 8, !dbg !1655
  ret void, !dbg !1656
}

; Function Attrs: nounwind
define linkonce_odr dso_local i32 @_ZN4laya6detailEhht(i8 zeroext %domain, i8 zeroext %object, i16 zeroext %reason) #3 comdat !dbg !1657 {
entry:
  %domain.addr = alloca i8, align 1
  %object.addr = alloca i8, align 1
  %reason.addr = alloca i16, align 2
  store i8 %domain, i8* %domain.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %domain.addr, metadata !1660, metadata !DIExpression()), !dbg !1661
  store i8 %object, i8* %object.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %object.addr, metadata !1662, metadata !DIExpression()), !dbg !1663
  store i16 %reason, i16* %reason.addr, align 2
  call void @llvm.dbg.declare(metadata i16* %reason.addr, metadata !1664, metadata !DIExpression()), !dbg !1665
  %0 = load i8, i8* %domain.addr, align 1, !dbg !1666
  %conv = zext i8 %0 to i32, !dbg !1666
  %shl = shl i32 %conv, 24, !dbg !1667
  %1 = load i8, i8* %object.addr, align 1, !dbg !1668
  %conv1 = zext i8 %1 to i32, !dbg !1668
  %shl2 = shl i32 %conv1, 16, !dbg !1669
  %or = or i32 %shl, %shl2, !dbg !1670
  %2 = load i16, i16* %reason.addr, align 2, !dbg !1671
  %conv3 = zext i16 %2 to i32, !dbg !1671
  %or4 = or i32 %or, %conv3, !dbg !1672
  ret i32 %or4, !dbg !1673
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: nounwind
define dso_local zeroext i1 @_ZN4laya22numeric_identity_validERKNS_15NumericIdentityE(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %x) #5 !dbg !1674 {
entry:
  %x.addr = alloca %"struct.laya::NumericIdentity"*, align 8
  %legal_s = alloca i1, align 1
  store %"struct.laya::NumericIdentity"* %x, %"struct.laya::NumericIdentity"** %x.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::NumericIdentity"** %x.addr, metadata !1680, metadata !DIExpression()), !dbg !1681
  %0 = bitcast i1* %legal_s to i8*, !dbg !1682
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %0) #31, !dbg !1682
  call void @llvm.dbg.declare(metadata i1* %legal_s, metadata !1683, metadata !DIExpression()), !dbg !1685
  %1 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1686
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %1, i32 0, i32 3, !dbg !1687
  %2 = load i16, i16* %S, align 2, !dbg !1687
  %conv = zext i16 %2 to i32, !dbg !1686
  %cmp = icmp eq i32 %conv, 64, !dbg !1688
  br i1 %cmp, label %lor.end, label %lor.lhs.false, !dbg !1689

lor.lhs.false:                                    ; preds = %entry
  %3 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1690
  %S1 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %3, i32 0, i32 3, !dbg !1691
  %4 = load i16, i16* %S1, align 2, !dbg !1691
  %conv2 = zext i16 %4 to i32, !dbg !1690
  %cmp3 = icmp eq i32 %conv2, 128, !dbg !1692
  br i1 %cmp3, label %lor.end, label %lor.lhs.false4, !dbg !1693

lor.lhs.false4:                                   ; preds = %lor.lhs.false
  %5 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1694
  %S5 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %5, i32 0, i32 3, !dbg !1695
  %6 = load i16, i16* %S5, align 2, !dbg !1695
  %conv6 = zext i16 %6 to i32, !dbg !1694
  %cmp7 = icmp eq i32 %conv6, 256, !dbg !1696
  br i1 %cmp7, label %lor.end, label %lor.lhs.false8, !dbg !1697

lor.lhs.false8:                                   ; preds = %lor.lhs.false4
  %7 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1698
  %S9 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %7, i32 0, i32 3, !dbg !1699
  %8 = load i16, i16* %S9, align 2, !dbg !1699
  %conv10 = zext i16 %8 to i32, !dbg !1698
  %cmp11 = icmp eq i32 %conv10, 512, !dbg !1700
  br i1 %cmp11, label %lor.end, label %lor.rhs, !dbg !1701

lor.rhs:                                          ; preds = %lor.lhs.false8
  %9 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1702
  %S12 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %9, i32 0, i32 3, !dbg !1703
  %10 = load i16, i16* %S12, align 2, !dbg !1703
  %conv13 = zext i16 %10 to i32, !dbg !1702
  %cmp14 = icmp eq i32 %conv13, 1024, !dbg !1704
  br label %lor.end, !dbg !1701

lor.end:                                          ; preds = %lor.rhs, %lor.lhs.false8, %lor.lhs.false4, %lor.lhs.false, %entry
  %11 = phi i1 [ true, %lor.lhs.false8 ], [ true, %lor.lhs.false4 ], [ true, %lor.lhs.false ], [ true, %entry ], [ %cmp14, %lor.rhs ]
  store i1 %11, i1* %legal_s, align 1, !dbg !1685
  %12 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1705
  %request_id = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %12, i32 0, i32 0, !dbg !1706
  %13 = load i64, i64* %request_id, align 8, !dbg !1706
  %tobool = icmp ne i64 %13, 0, !dbg !1705
  br i1 %tobool, label %land.lhs.true, label %land.end, !dbg !1707

land.lhs.true:                                    ; preds = %lor.end
  %14 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1708
  %generation = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %14, i32 0, i32 1, !dbg !1709
  %15 = load i64, i64* %generation, align 8, !dbg !1709
  %tobool15 = icmp ne i64 %15, 0, !dbg !1708
  br i1 %tobool15, label %land.lhs.true16, label %land.end, !dbg !1710

land.lhs.true16:                                  ; preds = %land.lhs.true
  %16 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1711
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %16, i32 0, i32 2, !dbg !1712
  %17 = load i16, i16* %B, align 8, !dbg !1712
  %conv17 = zext i16 %17 to i32, !dbg !1711
  %cmp18 = icmp sge i32 %conv17, 1, !dbg !1713
  br i1 %cmp18, label %land.lhs.true19, label %land.end, !dbg !1714

land.lhs.true19:                                  ; preds = %land.lhs.true16
  %18 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1715
  %B20 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %18, i32 0, i32 2, !dbg !1716
  %19 = load i16, i16* %B20, align 8, !dbg !1716
  %conv21 = zext i16 %19 to i32, !dbg !1715
  %cmp22 = icmp sle i32 %conv21, 2, !dbg !1717
  br i1 %cmp22, label %land.lhs.true23, label %land.end, !dbg !1718

land.lhs.true23:                                  ; preds = %land.lhs.true19
  %20 = load i1, i1* %legal_s, align 1, !dbg !1719
  br i1 %20, label %land.lhs.true24, label %land.end, !dbg !1720

land.lhs.true24:                                  ; preds = %land.lhs.true23
  %21 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1721
  %model_tag = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %21, i32 0, i32 4, !dbg !1722
  %arraydecay = getelementptr inbounds [16 x i8], [16 x i8]* %model_tag, i64 0, i64 0, !dbg !1721
  %call = call zeroext i1 @_ZN4laya12_GLOBAL__N_17nonzeroEPKhj(i8* %arraydecay, i32 16), !dbg !1723
  br i1 %call, label %land.lhs.true25, label %land.end, !dbg !1724

land.lhs.true25:                                  ; preds = %land.lhs.true24
  %22 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1725
  %numeric_tag = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %22, i32 0, i32 5, !dbg !1726
  %arraydecay26 = getelementptr inbounds [16 x i8], [16 x i8]* %numeric_tag, i64 0, i64 0, !dbg !1725
  %call27 = call zeroext i1 @_ZN4laya12_GLOBAL__N_17nonzeroEPKhj(i8* %arraydecay26, i32 16), !dbg !1727
  br i1 %call27, label %land.lhs.true28, label %land.end, !dbg !1728

land.lhs.true28:                                  ; preds = %land.lhs.true25
  %23 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1729
  %layout_tag = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %23, i32 0, i32 6, !dbg !1730
  %arraydecay29 = getelementptr inbounds [16 x i8], [16 x i8]* %layout_tag, i64 0, i64 0, !dbg !1729
  %call30 = call zeroext i1 @_ZN4laya12_GLOBAL__N_17nonzeroEPKhj(i8* %arraydecay29, i32 16), !dbg !1731
  br i1 %call30, label %land.rhs, label %land.end, !dbg !1732

land.rhs:                                         ; preds = %land.lhs.true28
  %24 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %x.addr, align 8, !dbg !1733
  %build_tag = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %24, i32 0, i32 7, !dbg !1734
  %arraydecay31 = getelementptr inbounds [16 x i8], [16 x i8]* %build_tag, i64 0, i64 0, !dbg !1733
  %call32 = call zeroext i1 @_ZN4laya12_GLOBAL__N_17nonzeroEPKhj(i8* %arraydecay31, i32 16), !dbg !1735
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.lhs.true28, %land.lhs.true25, %land.lhs.true24, %land.lhs.true23, %land.lhs.true19, %land.lhs.true16, %land.lhs.true, %lor.end
  %25 = phi i1 [ false, %land.lhs.true28 ], [ false, %land.lhs.true25 ], [ false, %land.lhs.true24 ], [ false, %land.lhs.true23 ], [ false, %land.lhs.true19 ], [ false, %land.lhs.true16 ], [ false, %land.lhs.true ], [ false, %lor.end ], [ %call32, %land.rhs ], !dbg !1736
  %26 = bitcast i1* %legal_s to i8*, !dbg !1737
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %26) #31, !dbg !1737
  ret i1 %25, !dbg !1738
}

; Function Attrs: nounwind
define internal zeroext i1 @_ZN4laya12_GLOBAL__N_17nonzeroEPKhj(i8* %a, i32 %n) #6 !dbg !1739 {
entry:
  %retval = alloca i1, align 1
  %a.addr = alloca i8*, align 8
  %n.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  store i8* %a, i8** %a.addr, align 8
  call void @llvm.dbg.declare(metadata i8** %a.addr, metadata !1745, metadata !DIExpression()), !dbg !1746
  store i32 %n, i32* %n.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %n.addr, metadata !1747, metadata !DIExpression()), !dbg !1748
  br label %VITIS_LOOP_12_1, !dbg !1749

VITIS_LOOP_12_1:                                  ; preds = %entry
  %0 = bitcast i32* %i to i8*, !dbg !1750
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !1750
  call void @llvm.dbg.declare(metadata i32* %i, metadata !1752, metadata !DIExpression()), !dbg !1753
  store i32 0, i32* %i, align 4, !dbg !1753
  br label %for.cond, !dbg !1750

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_12_1
  %1 = load i32, i32* %i, align 4, !dbg !1754
  %2 = load i32, i32* %n.addr, align 4, !dbg !1756
  %cmp = icmp ult i32 %1, %2, !dbg !1757
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !1758

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1758

for.body:                                         ; preds = %for.cond
  %3 = load i8*, i8** %a.addr, align 8, !dbg !1759
  %4 = load i32, i32* %i, align 4, !dbg !1761
  %idxprom = zext i32 %4 to i64, !dbg !1759
  %arrayidx = getelementptr inbounds i8, i8* %3, i64 %idxprom, !dbg !1759
  %5 = load i8, i8* %arrayidx, align 1, !dbg !1759
  %tobool = icmp ne i8 %5, 0, !dbg !1759
  br i1 %tobool, label %if.then, label %if.end, !dbg !1762

if.then:                                          ; preds = %for.body
  store i1 true, i1* %retval, align 1, !dbg !1763
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1763

if.end:                                           ; preds = %for.body
  br label %for.inc, !dbg !1764

for.inc:                                          ; preds = %if.end
  %6 = load i32, i32* %i, align 4, !dbg !1765
  %inc = add i32 %6, 1, !dbg !1765
  store i32 %inc, i32* %i, align 4, !dbg !1765
  br label %for.cond, !dbg !1766, !llvm.loop !1767

cleanup:                                          ; preds = %if.then, %for.cond.cleanup
  %7 = bitcast i32* %i to i8*, !dbg !1766
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %7) #31, !dbg !1766
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 3, label %for.end
    i32 1, label %return
  ]

for.end:                                          ; preds = %cleanup
  store i1 false, i1* %retval, align 1, !dbg !1771
  br label %return, !dbg !1771

return:                                           ; preds = %for.end, %cleanup
  %8 = load i1, i1* %retval, align 1, !dbg !1772
  ret i1 %8, !dbg !1772

unreachable:                                      ; preds = %cleanup
  unreachable
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya17numeric_reset_f32ERNS_11F32TileMetaE(%"struct.laya::F32TileMeta"* nonnull align 8 dereferenceable(376) %owner) #7 !dbg !1773 {
entry:
  %owner.addr = alloca %"struct.laya::F32TileMeta"*, align 8
  %r = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %word = alloca i32, align 4
  store %"struct.laya::F32TileMeta"* %owner, %"struct.laya::F32TileMeta"** %owner.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::F32TileMeta"** %owner.addr, metadata !1777, metadata !DIExpression()), !dbg !1778
  %0 = load %"struct.laya::F32TileMeta"*, %"struct.laya::F32TileMeta"** %owner.addr, align 8, !dbg !1779
  %state = getelementptr inbounds %"struct.laya::F32TileMeta", %"struct.laya::F32TileMeta"* %0, i32 0, i32 8, !dbg !1780
  store i8 6, i8* %state, align 2, !dbg !1781
  %1 = load %"struct.laya::F32TileMeta"*, %"struct.laya::F32TileMeta"** %owner.addr, align 8, !dbg !1782
  %valid = getelementptr inbounds %"struct.laya::F32TileMeta", %"struct.laya::F32TileMeta"* %1, i32 0, i32 12, !dbg !1783
  store i1 false, i1* %valid, align 8, !dbg !1784
  %2 = load %"struct.laya::F32TileMeta"*, %"struct.laya::F32TileMeta"** %owner.addr, align 8, !dbg !1785
  %readers = getelementptr inbounds %"struct.laya::F32TileMeta", %"struct.laya::F32TileMeta"* %2, i32 0, i32 10, !dbg !1786
  store i8 0, i8* %readers, align 4, !dbg !1787
  br label %VITIS_LOOP_303_1, !dbg !1785

VITIS_LOOP_303_1:                                 ; preds = %entry
  %3 = bitcast i32* %r to i8*, !dbg !1788
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %3) #31, !dbg !1788
  call void @llvm.dbg.declare(metadata i32* %r, metadata !1790, metadata !DIExpression()), !dbg !1791
  store i32 0, i32* %r, align 4, !dbg !1791
  br label %for.cond, !dbg !1788

for.cond:                                         ; preds = %for.inc7, %VITIS_LOOP_303_1
  %4 = load i32, i32* %r, align 4, !dbg !1792
  %cmp = icmp ult i32 %4, 16, !dbg !1794
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !1795

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %5 = bitcast i32* %r to i8*, !dbg !1796
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %5) #31, !dbg !1796
  br label %for.end9

for.body:                                         ; preds = %for.cond
  br label %VITIS_LOOP_304_2, !dbg !1795

VITIS_LOOP_304_2:                                 ; preds = %for.body
  %6 = bitcast i32* %word to i8*, !dbg !1797
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #31, !dbg !1797
  call void @llvm.dbg.declare(metadata i32* %word, metadata !1799, metadata !DIExpression()), !dbg !1800
  store i32 0, i32* %word, align 4, !dbg !1800
  br label %for.cond1, !dbg !1797

for.cond1:                                        ; preds = %for.inc, %VITIS_LOOP_304_2
  %7 = load i32, i32* %word, align 4, !dbg !1801
  %cmp2 = icmp ult i32 %7, 4, !dbg !1803
  br i1 %cmp2, label %for.body4, label %for.cond.cleanup3, !dbg !1804

for.cond.cleanup3:                                ; preds = %for.cond1
  store i32 7, i32* %cleanup.dest.slot, align 4
  %8 = bitcast i32* %word to i8*, !dbg !1805
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %8) #31, !dbg !1805
  br label %for.end

for.body4:                                        ; preds = %for.cond1
  %9 = load %"struct.laya::F32TileMeta"*, %"struct.laya::F32TileMeta"** %owner.addr, align 8, !dbg !1806
  %covered_groups = getelementptr inbounds %"struct.laya::F32TileMeta", %"struct.laya::F32TileMeta"* %9, i32 0, i32 11, !dbg !1807
  %10 = load i32, i32* %r, align 4, !dbg !1808
  %idxprom = zext i32 %10 to i64, !dbg !1806
  %arrayidx = getelementptr inbounds [16 x [4 x i32]], [16 x [4 x i32]]* %covered_groups, i64 0, i64 %idxprom, !dbg !1806
  %11 = load i32, i32* %word, align 4, !dbg !1809
  %idxprom5 = zext i32 %11 to i64, !dbg !1806
  %arrayidx6 = getelementptr inbounds [4 x i32], [4 x i32]* %arrayidx, i64 0, i64 %idxprom5, !dbg !1806
  store i32 0, i32* %arrayidx6, align 4, !dbg !1810
  br label %for.inc, !dbg !1806

for.inc:                                          ; preds = %for.body4
  %12 = load i32, i32* %word, align 4, !dbg !1811
  %inc = add i32 %12, 1, !dbg !1811
  store i32 %inc, i32* %word, align 4, !dbg !1811
  br label %for.cond1, !dbg !1805, !llvm.loop !1812

for.end:                                          ; preds = %for.cond.cleanup3
  br label %for.inc7, !dbg !1813

for.inc7:                                         ; preds = %for.end
  %13 = load i32, i32* %r, align 4, !dbg !1815
  %inc8 = add i32 %13, 1, !dbg !1815
  store i32 %inc8, i32* %r, align 4, !dbg !1815
  br label %for.cond, !dbg !1796, !llvm.loop !1816

for.end9:                                         ; preds = %for.cond.cleanup
  ret void, !dbg !1819
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya16numeric_reset_a8ERNS_10A8TileMetaE(%"struct.laya::A8TileMeta"* nonnull align 8 dereferenceable(752) %owner) #8 !dbg !1820 {
entry:
  %owner.addr = alloca %"struct.laya::A8TileMeta"*, align 8
  %r = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %word = alloca i32, align 4
  store %"struct.laya::A8TileMeta"* %owner, %"struct.laya::A8TileMeta"** %owner.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::A8TileMeta"** %owner.addr, metadata !1824, metadata !DIExpression()), !dbg !1825
  %0 = load %"struct.laya::A8TileMeta"*, %"struct.laya::A8TileMeta"** %owner.addr, align 8, !dbg !1826
  %state = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %0, i32 0, i32 12, !dbg !1827
  store i8 6, i8* %state, align 8, !dbg !1828
  %1 = load %"struct.laya::A8TileMeta"*, %"struct.laya::A8TileMeta"** %owner.addr, align 8, !dbg !1829
  %valid = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %1, i32 0, i32 15, !dbg !1830
  store i1 false, i1* %valid, align 1, !dbg !1831
  %2 = load %"struct.laya::A8TileMeta"*, %"struct.laya::A8TileMeta"** %owner.addr, align 8, !dbg !1832
  %readers = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %2, i32 0, i32 14, !dbg !1833
  store i8 0, i8* %readers, align 2, !dbg !1834
  br label %VITIS_LOOP_309_1, !dbg !1832

VITIS_LOOP_309_1:                                 ; preds = %entry
  %3 = bitcast i32* %r to i8*, !dbg !1835
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %3) #31, !dbg !1835
  call void @llvm.dbg.declare(metadata i32* %r, metadata !1837, metadata !DIExpression()), !dbg !1838
  store i32 0, i32* %r, align 4, !dbg !1838
  br label %for.cond, !dbg !1835

for.cond:                                         ; preds = %for.inc7, %VITIS_LOOP_309_1
  %4 = load i32, i32* %r, align 4, !dbg !1839
  %cmp = icmp ult i32 %4, 16, !dbg !1841
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !1842

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %5 = bitcast i32* %r to i8*, !dbg !1843
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %5) #31, !dbg !1843
  br label %for.end9

for.body:                                         ; preds = %for.cond
  br label %VITIS_LOOP_310_2, !dbg !1842

VITIS_LOOP_310_2:                                 ; preds = %for.body
  %6 = bitcast i32* %word to i8*, !dbg !1844
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #31, !dbg !1844
  call void @llvm.dbg.declare(metadata i32* %word, metadata !1846, metadata !DIExpression()), !dbg !1847
  store i32 0, i32* %word, align 4, !dbg !1847
  br label %for.cond1, !dbg !1844

for.cond1:                                        ; preds = %for.inc, %VITIS_LOOP_310_2
  %7 = load i32, i32* %word, align 4, !dbg !1848
  %cmp2 = icmp ult i32 %7, 4, !dbg !1850
  br i1 %cmp2, label %for.body4, label %for.cond.cleanup3, !dbg !1851

for.cond.cleanup3:                                ; preds = %for.cond1
  store i32 7, i32* %cleanup.dest.slot, align 4
  %8 = bitcast i32* %word to i8*, !dbg !1852
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %8) #31, !dbg !1852
  br label %for.end

for.body4:                                        ; preds = %for.cond1
  %9 = load %"struct.laya::A8TileMeta"*, %"struct.laya::A8TileMeta"** %owner.addr, align 8, !dbg !1853
  %covered_groups = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %9, i32 0, i32 11, !dbg !1854
  %10 = load i32, i32* %r, align 4, !dbg !1855
  %idxprom = zext i32 %10 to i64, !dbg !1853
  %arrayidx = getelementptr inbounds [16 x [4 x i32]], [16 x [4 x i32]]* %covered_groups, i64 0, i64 %idxprom, !dbg !1853
  %11 = load i32, i32* %word, align 4, !dbg !1856
  %idxprom5 = zext i32 %11 to i64, !dbg !1853
  %arrayidx6 = getelementptr inbounds [4 x i32], [4 x i32]* %arrayidx, i64 0, i64 %idxprom5, !dbg !1853
  store i32 0, i32* %arrayidx6, align 4, !dbg !1857
  br label %for.inc, !dbg !1853

for.inc:                                          ; preds = %for.body4
  %12 = load i32, i32* %word, align 4, !dbg !1858
  %inc = add i32 %12, 1, !dbg !1858
  store i32 %inc, i32* %word, align 4, !dbg !1858
  br label %for.cond1, !dbg !1852, !llvm.loop !1859

for.end:                                          ; preds = %for.cond.cleanup3
  br label %for.inc7, !dbg !1860

for.inc7:                                         ; preds = %for.end
  %13 = load i32, i32* %r, align 4, !dbg !1862
  %inc8 = add i32 %13, 1, !dbg !1862
  store i32 %inc8, i32* %r, align 4, !dbg !1862
  br label %for.cond, !dbg !1843, !llvm.loop !1863

for.end9:                                         ; preds = %for.cond.cleanup
  ret void, !dbg !1866
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %s) #9 !dbg !1867 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %index = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__range3 = alloca [3 x i1]*, align 8
  %__begin3 = alloca i1*, align 8
  %__end3 = alloca i1*, align 8
  %v = alloca i1*, align 8
  %__range324 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin326 = alloca [2 x [32 x i32]]*, align 8
  %__end328 = alloca [2 x [32 x i32]]*, align 8
  %head = alloca [2 x [32 x i32]]*, align 8
  %__range4 = alloca [2 x [32 x i32]]*, align 8
  %__begin4 = alloca [32 x i32]*, align 8
  %__end4 = alloca [32 x i32]*, align 8
  %batch = alloca [32 x i32]*, align 8
  %__range5 = alloca [32 x i32]*, align 8
  %__begin5 = alloca i32*, align 8
  %__end5 = alloca i32*, align 8
  %word = alloca i32*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !1873, metadata !DIExpression()), !dbg !1874
  store %"struct.laya::full::FullOwnerSpec"* %s, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %s.addr, metadata !1875, metadata !DIExpression()), !dbg !1876
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1877
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !1879
  %1 = load i1, i1* %request_valid, align 8, !dbg !1879
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !1880

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1881
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !1882
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !1882
  br i1 %3, label %if.end, label %if.then, !dbg !1883

if.then:                                          ; preds = %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_18protocolEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i16 zeroext 4), !dbg !1884
  br label %return, !dbg !1885

if.end:                                           ; preds = %lor.lhs.false
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1886
  %5 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1888
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %4, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %5), !dbg !1889
  br i1 %call, label %lor.lhs.false1, label %if.then2, !dbg !1890

lor.lhs.false1:                                   ; preds = %if.end
  %6 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1891
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %6, i32 0, i32 0, !dbg !1892
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !1893
  %7 = load i8, i8* %id, align 4, !dbg !1893
  %cmp = icmp eq i8 %7, 5, !dbg !1894
  br i1 %cmp, label %if.then2, label %if.end5, !dbg !1895

if.then2:                                         ; preds = %lor.lhs.false1, %if.end
  %8 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1896
  %ref3 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %8, i32 0, i32 0, !dbg !1897
  %id4 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref3, i32 0, i32 0, !dbg !1898
  %9 = load i8, i8* %id4, align 4, !dbg !1898
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %9, i16 zeroext 5), !dbg !1899
  br label %return, !dbg !1900

if.end5:                                          ; preds = %lor.lhs.false1
  %10 = bitcast i32* %index to i8*, !dbg !1901
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %10) #31, !dbg !1901
  call void @llvm.dbg.declare(metadata i32* %index, metadata !1902, metadata !DIExpression()), !dbg !1903
  %11 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1904
  %12 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1905
  %call6 = call i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %11, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %12), !dbg !1906
  store i32 %call6, i32* %index, align 4, !dbg !1903
  %13 = load i32, i32* %index, align 4, !dbg !1907
  %cmp7 = icmp eq i32 %13, 32, !dbg !1909
  br i1 %cmp7, label %if.then8, label %if.end11, !dbg !1910

if.then8:                                         ; preds = %if.end5
  %14 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1911
  %ref9 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %14, i32 0, i32 0, !dbg !1912
  %id10 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref9, i32 0, i32 0, !dbg !1913
  %15 = load i8, i8* %id10, align 4, !dbg !1913
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %15, i16 zeroext 9), !dbg !1914
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !1915

if.end11:                                         ; preds = %if.end5
  %16 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1916
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %16, i32 0, i32 1, !dbg !1917
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !1918
  %17 = load i32, i32* %index, align 4, !dbg !1919
  %idxprom = zext i32 %17 to i64, !dbg !1916
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !1916
  %18 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1920
  %19 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1921
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %19, i32 0, i32 0, !dbg !1922
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !1923
  call void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %arrayidx, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %18, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity), !dbg !1924
  %20 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1925
  %owner_claims = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %20, i32 0, i32 27, !dbg !1926
  %21 = load i32, i32* %owner_claims, align 8, !dbg !1927
  %inc = add i32 %21, 1, !dbg !1927
  store i32 %inc, i32* %owner_claims, align 8, !dbg !1927
  %22 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1928
  %ref12 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %22, i32 0, i32 0, !dbg !1930
  %id13 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref12, i32 0, i32 0, !dbg !1931
  %23 = load i8, i8* %id13, align 4, !dbg !1931
  %cmp14 = icmp eq i8 %23, 11, !dbg !1932
  br i1 %cmp14, label %if.then15, label %if.end19, !dbg !1933

if.then15:                                        ; preds = %if.end11
  br label %VITIS_LOOP_206_1, !dbg !1933

VITIS_LOOP_206_1:                                 ; preds = %if.then15
  %24 = bitcast [3 x i1]** %__range3 to i8*, !dbg !1934
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %24) #31, !dbg !1934
  call void @llvm.dbg.declare(metadata [3 x i1]** %__range3, metadata !1936, metadata !DIExpression()), !dbg !1938
  %25 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1934
  %owners16 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %25, i32 0, i32 1, !dbg !1939
  %type_valid = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners16, i32 0, i32 6, !dbg !1940
  store [3 x i1]* %type_valid, [3 x i1]** %__range3, align 8, !dbg !1934
  %26 = bitcast i1** %__begin3 to i8*, !dbg !1941
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %26) #31, !dbg !1941
  call void @llvm.dbg.declare(metadata i1** %__begin3, metadata !1942, metadata !DIExpression()), !dbg !1938
  %27 = load [3 x i1]*, [3 x i1]** %__range3, align 8, !dbg !1941
  %arraydecay = getelementptr inbounds [3 x i1], [3 x i1]* %27, i64 0, i64 0, !dbg !1941
  store i1* %arraydecay, i1** %__begin3, align 8, !dbg !1941
  %28 = bitcast i1** %__end3 to i8*, !dbg !1941
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %28) #31, !dbg !1941
  call void @llvm.dbg.declare(metadata i1** %__end3, metadata !1944, metadata !DIExpression()), !dbg !1938
  %29 = load [3 x i1]*, [3 x i1]** %__range3, align 8, !dbg !1941
  %arraydecay17 = getelementptr inbounds [3 x i1], [3 x i1]* %29, i64 0, i64 0, !dbg !1941
  %add.ptr = getelementptr inbounds i1, i1* %arraydecay17, i64 3, !dbg !1941
  store i1* %add.ptr, i1** %__end3, align 8, !dbg !1941
  br label %for.cond, !dbg !1941

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_206_1
  %30 = load i1*, i1** %__begin3, align 8, !dbg !1941
  %31 = load i1*, i1** %__end3, align 8, !dbg !1941
  %cmp18 = icmp ne i1* %30, %31, !dbg !1941
  br i1 %cmp18, label %for.body, label %for.cond.cleanup, !dbg !1941

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %32 = bitcast i1** %__end3 to i8*, !dbg !1941
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %32) #31, !dbg !1941
  %33 = bitcast i1** %__begin3 to i8*, !dbg !1941
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %33) #31, !dbg !1941
  %34 = bitcast [3 x i1]** %__range3 to i8*, !dbg !1941
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %34) #31, !dbg !1941
  br label %for.end

for.body:                                         ; preds = %for.cond
  %35 = bitcast i1** %v to i8*, !dbg !1945
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %35) #31, !dbg !1945
  call void @llvm.dbg.declare(metadata i1** %v, metadata !1947, metadata !DIExpression()), !dbg !1949
  %36 = load i1*, i1** %__begin3, align 8, !dbg !1950
  store i1* %36, i1** %v, align 8, !dbg !1949
  %37 = load i1*, i1** %v, align 8, !dbg !1951
  store i1 false, i1* %37, align 1, !dbg !1952
  %38 = bitcast i1** %v to i8*, !dbg !1953
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %38) #31, !dbg !1953
  br label %for.inc, !dbg !1954

for.inc:                                          ; preds = %for.body
  %39 = load i1*, i1** %__begin3, align 8, !dbg !1941
  %incdec.ptr = getelementptr inbounds i1, i1* %39, i32 1, !dbg !1941
  store i1* %incdec.ptr, i1** %__begin3, align 8, !dbg !1941
  br label %for.cond, !dbg !1941, !llvm.loop !1955

for.end:                                          ; preds = %for.cond.cleanup
  br label %if.end19, !dbg !1953

if.end19:                                         ; preds = %for.end, %if.end11
  %40 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !1957
  %ref20 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %40, i32 0, i32 0, !dbg !1959
  %id21 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref20, i32 0, i32 0, !dbg !1960
  %41 = load i8, i8* %id21, align 4, !dbg !1960
  %cmp22 = icmp eq i8 %41, 8, !dbg !1961
  br i1 %cmp22, label %if.then23, label %if.end58, !dbg !1962

if.then23:                                        ; preds = %if.end19
  br label %VITIS_LOOP_208_2, !dbg !1962

VITIS_LOOP_208_2:                                 ; preds = %if.then23
  %42 = bitcast [16 x [2 x [32 x i32]]]** %__range324 to i8*, !dbg !1963
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %42) #31, !dbg !1963
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range324, metadata !1965, metadata !DIExpression()), !dbg !1967
  %43 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !1963
  %owners25 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %43, i32 0, i32 1, !dbg !1968
  %att_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners25, i32 0, i32 3, !dbg !1969
  store [16 x [2 x [32 x i32]]]* %att_head_rows, [16 x [2 x [32 x i32]]]** %__range324, align 8, !dbg !1963
  %44 = bitcast [2 x [32 x i32]]** %__begin326 to i8*, !dbg !1970
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %44) #31, !dbg !1970
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin326, metadata !1971, metadata !DIExpression()), !dbg !1967
  %45 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range324, align 8, !dbg !1970
  %arraydecay27 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %45, i64 0, i64 0, !dbg !1970
  store [2 x [32 x i32]]* %arraydecay27, [2 x [32 x i32]]** %__begin326, align 8, !dbg !1970
  %46 = bitcast [2 x [32 x i32]]** %__end328 to i8*, !dbg !1970
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %46) #31, !dbg !1970
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end328, metadata !1975, metadata !DIExpression()), !dbg !1967
  %47 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range324, align 8, !dbg !1970
  %arraydecay29 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %47, i64 0, i64 0, !dbg !1970
  %add.ptr30 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay29, i64 16, !dbg !1970
  store [2 x [32 x i32]]* %add.ptr30, [2 x [32 x i32]]** %__end328, align 8, !dbg !1970
  br label %for.cond31, !dbg !1970

for.cond31:                                       ; preds = %for.inc55, %VITIS_LOOP_208_2
  %48 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin326, align 8, !dbg !1970
  %49 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end328, align 8, !dbg !1970
  %cmp32 = icmp ne [2 x [32 x i32]]* %48, %49, !dbg !1970
  br i1 %cmp32, label %for.body34, label %for.cond.cleanup33, !dbg !1970

for.cond.cleanup33:                               ; preds = %for.cond31
  store i32 6, i32* %cleanup.dest.slot, align 4
  %50 = bitcast [2 x [32 x i32]]** %__end328 to i8*, !dbg !1970
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %50) #31, !dbg !1970
  %51 = bitcast [2 x [32 x i32]]** %__begin326 to i8*, !dbg !1970
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %51) #31, !dbg !1970
  %52 = bitcast [16 x [2 x [32 x i32]]]** %__range324 to i8*, !dbg !1970
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %52) #31, !dbg !1970
  br label %for.end57

for.body34:                                       ; preds = %for.cond31
  %53 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !1976
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %53) #31, !dbg !1976
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head, metadata !1978, metadata !DIExpression()), !dbg !1980
  %54 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin326, align 8, !dbg !1981
  store [2 x [32 x i32]]* %54, [2 x [32 x i32]]** %head, align 8, !dbg !1980
  br label %VITIS_LOOP_209_3, !dbg !1976

VITIS_LOOP_209_3:                                 ; preds = %for.body34
  %55 = bitcast [2 x [32 x i32]]** %__range4 to i8*, !dbg !1982
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %55) #31, !dbg !1982
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range4, metadata !1984, metadata !DIExpression()), !dbg !1985
  %56 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head, align 8, !dbg !1982
  store [2 x [32 x i32]]* %56, [2 x [32 x i32]]** %__range4, align 8, !dbg !1982
  %57 = bitcast [32 x i32]** %__begin4 to i8*, !dbg !1986
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %57) #31, !dbg !1986
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin4, metadata !1987, metadata !DIExpression()), !dbg !1985
  %58 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range4, align 8, !dbg !1986
  %arraydecay35 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %58, i64 0, i64 0, !dbg !1986
  store [32 x i32]* %arraydecay35, [32 x i32]** %__begin4, align 8, !dbg !1986
  %59 = bitcast [32 x i32]** %__end4 to i8*, !dbg !1986
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %59) #31, !dbg !1986
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end4, metadata !1990, metadata !DIExpression()), !dbg !1985
  %60 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range4, align 8, !dbg !1986
  %arraydecay36 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %60, i64 0, i64 0, !dbg !1986
  %add.ptr37 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay36, i64 2, !dbg !1986
  store [32 x i32]* %add.ptr37, [32 x i32]** %__end4, align 8, !dbg !1986
  br label %for.cond38, !dbg !1986

for.cond38:                                       ; preds = %for.inc52, %VITIS_LOOP_209_3
  %61 = load [32 x i32]*, [32 x i32]** %__begin4, align 8, !dbg !1986
  %62 = load [32 x i32]*, [32 x i32]** %__end4, align 8, !dbg !1986
  %cmp39 = icmp ne [32 x i32]* %61, %62, !dbg !1986
  br i1 %cmp39, label %for.body41, label %for.cond.cleanup40, !dbg !1986

for.cond.cleanup40:                               ; preds = %for.cond38
  store i32 9, i32* %cleanup.dest.slot, align 4
  %63 = bitcast [32 x i32]** %__end4 to i8*, !dbg !1986
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %63) #31, !dbg !1986
  %64 = bitcast [32 x i32]** %__begin4 to i8*, !dbg !1986
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %64) #31, !dbg !1986
  %65 = bitcast [2 x [32 x i32]]** %__range4 to i8*, !dbg !1986
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %65) #31, !dbg !1986
  br label %for.end54

for.body41:                                       ; preds = %for.cond38
  %66 = bitcast [32 x i32]** %batch to i8*, !dbg !1991
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %66) #31, !dbg !1991
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch, metadata !1993, metadata !DIExpression()), !dbg !1995
  %67 = load [32 x i32]*, [32 x i32]** %__begin4, align 8, !dbg !1996
  store [32 x i32]* %67, [32 x i32]** %batch, align 8, !dbg !1995
  br label %VITIS_LOOP_210_4, !dbg !1991

VITIS_LOOP_210_4:                                 ; preds = %for.body41
  %68 = bitcast [32 x i32]** %__range5 to i8*, !dbg !1997
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %68) #31, !dbg !1997
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range5, metadata !1999, metadata !DIExpression()), !dbg !2000
  %69 = load [32 x i32]*, [32 x i32]** %batch, align 8, !dbg !1997
  store [32 x i32]* %69, [32 x i32]** %__range5, align 8, !dbg !1997
  %70 = bitcast i32** %__begin5 to i8*, !dbg !2001
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %70) #31, !dbg !2001
  call void @llvm.dbg.declare(metadata i32** %__begin5, metadata !2002, metadata !DIExpression()), !dbg !2000
  %71 = load [32 x i32]*, [32 x i32]** %__range5, align 8, !dbg !2001
  %arraydecay42 = getelementptr inbounds [32 x i32], [32 x i32]* %71, i64 0, i64 0, !dbg !2001
  store i32* %arraydecay42, i32** %__begin5, align 8, !dbg !2001
  %72 = bitcast i32** %__end5 to i8*, !dbg !2001
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %72) #31, !dbg !2001
  call void @llvm.dbg.declare(metadata i32** %__end5, metadata !2004, metadata !DIExpression()), !dbg !2000
  %73 = load [32 x i32]*, [32 x i32]** %__range5, align 8, !dbg !2001
  %arraydecay43 = getelementptr inbounds [32 x i32], [32 x i32]* %73, i64 0, i64 0, !dbg !2001
  %add.ptr44 = getelementptr inbounds i32, i32* %arraydecay43, i64 32, !dbg !2001
  store i32* %add.ptr44, i32** %__end5, align 8, !dbg !2001
  br label %for.cond45, !dbg !2001

for.cond45:                                       ; preds = %for.inc49, %VITIS_LOOP_210_4
  %74 = load i32*, i32** %__begin5, align 8, !dbg !2001
  %75 = load i32*, i32** %__end5, align 8, !dbg !2001
  %cmp46 = icmp ne i32* %74, %75, !dbg !2001
  br i1 %cmp46, label %for.body48, label %for.cond.cleanup47, !dbg !2001

for.cond.cleanup47:                               ; preds = %for.cond45
  store i32 12, i32* %cleanup.dest.slot, align 4
  %76 = bitcast i32** %__end5 to i8*, !dbg !2001
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %76) #31, !dbg !2001
  %77 = bitcast i32** %__begin5 to i8*, !dbg !2001
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %77) #31, !dbg !2001
  %78 = bitcast [32 x i32]** %__range5 to i8*, !dbg !2001
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %78) #31, !dbg !2001
  br label %for.end51

for.body48:                                       ; preds = %for.cond45
  %79 = bitcast i32** %word to i8*, !dbg !2005
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %79) #31, !dbg !2005
  call void @llvm.dbg.declare(metadata i32** %word, metadata !2007, metadata !DIExpression()), !dbg !2009
  %80 = load i32*, i32** %__begin5, align 8, !dbg !2010
  store i32* %80, i32** %word, align 8, !dbg !2009
  %81 = load i32*, i32** %word, align 8, !dbg !2011
  store i32 0, i32* %81, align 4, !dbg !2012
  %82 = bitcast i32** %word to i8*, !dbg !2013
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %82) #31, !dbg !2013
  br label %for.inc49, !dbg !2014

for.inc49:                                        ; preds = %for.body48
  %83 = load i32*, i32** %__begin5, align 8, !dbg !2001
  %incdec.ptr50 = getelementptr inbounds i32, i32* %83, i32 1, !dbg !2001
  store i32* %incdec.ptr50, i32** %__begin5, align 8, !dbg !2001
  br label %for.cond45, !dbg !2001, !llvm.loop !2015

for.end51:                                        ; preds = %for.cond.cleanup47
  %84 = bitcast [32 x i32]** %batch to i8*, !dbg !2017
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %84) #31, !dbg !2017
  br label %for.inc52, !dbg !2018

for.inc52:                                        ; preds = %for.end51
  %85 = load [32 x i32]*, [32 x i32]** %__begin4, align 8, !dbg !1986
  %incdec.ptr53 = getelementptr inbounds [32 x i32], [32 x i32]* %85, i32 1, !dbg !1986
  store [32 x i32]* %incdec.ptr53, [32 x i32]** %__begin4, align 8, !dbg !1986
  br label %for.cond38, !dbg !1986, !llvm.loop !2019

for.end54:                                        ; preds = %for.cond.cleanup40
  %86 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !2021
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %86) #31, !dbg !2021
  br label %for.inc55, !dbg !2022

for.inc55:                                        ; preds = %for.end54
  %87 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin326, align 8, !dbg !1970
  %incdec.ptr56 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %87, i32 1, !dbg !1970
  store [2 x [32 x i32]]* %incdec.ptr56, [2 x [32 x i32]]** %__begin326, align 8, !dbg !1970
  br label %for.cond31, !dbg !1970, !llvm.loop !2023

for.end57:                                        ; preds = %for.cond.cleanup33
  br label %if.end58, !dbg !2021

if.end58:                                         ; preds = %for.end57, %if.end19
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !2025
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2026

cleanup:                                          ; preds = %if.end58, %if.then8
  %88 = bitcast i32* %index to i8*, !dbg !2027
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %88) #31, !dbg !2027
  br label %return

return:                                           ; preds = %cleanup, %if.then2, %if.then
  ret void, !dbg !2027
}

; Function Attrs: nounwind
define internal void @_ZN4laya4full12_GLOBAL__N_18protocolEt(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, i16 zeroext %reason) #10 !dbg !2028 {
entry:
  %reason.addr = alloca i16, align 2
  store i16 %reason, i16* %reason.addr, align 2
  call void @llvm.dbg.declare(metadata i16* %reason.addr, metadata !2031, metadata !DIExpression()), !dbg !2032
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !2033
  store i16 7, i16* %code, align 8, !dbg !2033
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !2033
  %0 = load i16, i16* %reason.addr, align 2, !dbg !2034
  %call = call i32 @_ZN4laya6detailEhht(i8 zeroext 7, i8 zeroext 0, i16 zeroext %0), !dbg !2035
  store i32 %call, i32* %detail, align 4, !dbg !2033
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !2033
  store i64 -1, i64* %bad_element, align 8, !dbg !2033
  ret void, !dbg !2036
}

; Function Attrs: nounwind
define internal zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %s) #11 !dbg !2037 {
entry:
  %retval = alloca i1, align 1
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %ref.tmp = alloca %"struct.laya::Check", align 8
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %id15 = alloca i8, align 1
  %cleanup.dest.slot = alloca i32, align 4
  %fixed = alloca i16, align 2
  %extent = alloca i16, align 2
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2042, metadata !DIExpression()), !dbg !2043
  store %"struct.laya::full::FullOwnerSpec"* %s, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %s.addr, metadata !2044, metadata !DIExpression()), !dbg !2045
  %0 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !2046
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %0) #31, !dbg !2046
  %1 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2048
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %1, i32 0, i32 0, !dbg !2049
  %2 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !2048
  store %"struct.laya::BufferRef" %2, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !2048
  %3 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2050
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %3, i32 0, i32 1, !dbg !2051
  %4 = load i8, i8* %region, align 4, !dbg !2051
  call void @_ZN4laya9check_refENS_9BufferRefEh(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext %4), !dbg !2046
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %ref.tmp), !dbg !2046
  br i1 %call, label %lor.lhs.false, label %lor.end, !dbg !2052

lor.lhs.false:                                    ; preds = %entry
  %5 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2053
  %ref1 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %5, i32 0, i32 0, !dbg !2054
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref1, i32 0, i32 0, !dbg !2055
  %6 = load i8, i8* %id, align 4, !dbg !2055
  %cmp = icmp eq i8 %6, 0, !dbg !2056
  br i1 %cmp, label %lor.end, label %lor.lhs.false2, !dbg !2057

lor.lhs.false2:                                   ; preds = %lor.lhs.false
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2058
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %7, i32 0, i32 0, !dbg !2059
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !2060
  %call3 = call zeroext i1 @_ZN4laya22numeric_identity_validERKNS_15NumericIdentityE(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity), !dbg !2061
  br i1 %call3, label %lor.lhs.false4, label %lor.end, !dbg !2062

lor.lhs.false4:                                   ; preds = %lor.lhs.false2
  %8 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2063
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %8, i32 0, i32 2, !dbg !2064
  %9 = load i8, i8* %stage, align 1, !dbg !2064
  %conv = zext i8 %9 to i32, !dbg !2063
  %cmp5 = icmp sgt i32 %conv, 7, !dbg !2065
  br i1 %cmp5, label %lor.end, label %lor.lhs.false6, !dbg !2066

lor.lhs.false6:                                   ; preds = %lor.lhs.false4
  %10 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2067
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %10, i32 0, i32 7, !dbg !2068
  %11 = load i16, i16* %rows, align 4, !dbg !2068
  %conv7 = zext i16 %11 to i32, !dbg !2067
  %cmp8 = icmp eq i32 %conv7, 0, !dbg !2069
  br i1 %cmp8, label %lor.end, label %lor.lhs.false9, !dbg !2070

lor.lhs.false9:                                   ; preds = %lor.lhs.false6
  %12 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2071
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %12, i32 0, i32 8, !dbg !2072
  %13 = load i16, i16* %width, align 2, !dbg !2072
  %conv10 = zext i16 %13 to i32, !dbg !2071
  %cmp11 = icmp eq i32 %conv10, 0, !dbg !2073
  br i1 %cmp11, label %lor.end, label %lor.rhs, !dbg !2074

lor.rhs:                                          ; preds = %lor.lhs.false9
  %14 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2075
  %width12 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %14, i32 0, i32 8, !dbg !2076
  %15 = load i16, i16* %width12, align 2, !dbg !2076
  %conv13 = zext i16 %15 to i32, !dbg !2075
  %cmp14 = icmp sgt i32 %conv13, 5248, !dbg !2077
  br label %lor.end, !dbg !2074

lor.end:                                          ; preds = %lor.rhs, %lor.lhs.false9, %lor.lhs.false6, %lor.lhs.false4, %lor.lhs.false2, %lor.lhs.false, %entry
  %16 = phi i1 [ true, %lor.lhs.false9 ], [ true, %lor.lhs.false6 ], [ true, %lor.lhs.false4 ], [ true, %lor.lhs.false2 ], [ true, %lor.lhs.false ], [ true, %entry ], [ %cmp14, %lor.rhs ]
  %17 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !2078
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %17) #31, !dbg !2078
  br i1 %16, label %if.then, label %if.end, !dbg !2079

if.then:                                          ; preds = %lor.end
  store i1 false, i1* %retval, align 1, !dbg !2080
  br label %return, !dbg !2080

if.end:                                           ; preds = %lor.end
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %id15) #31, !dbg !2081
  call void @llvm.dbg.declare(metadata i8* %id15, metadata !2082, metadata !DIExpression()), !dbg !2083
  %18 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2084
  %ref16 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %18, i32 0, i32 0, !dbg !2085
  %id17 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref16, i32 0, i32 0, !dbg !2086
  %19 = load i8, i8* %id17, align 4, !dbg !2086
  store i8 %19, i8* %id15, align 1, !dbg !2083
  %20 = load i8, i8* %id15, align 1, !dbg !2087
  %conv18 = zext i8 %20 to i32, !dbg !2087
  %cmp19 = icmp sge i32 %conv18, 32, !dbg !2089
  br i1 %cmp19, label %land.lhs.true, label %if.end27, !dbg !2090

land.lhs.true:                                    ; preds = %if.end
  %21 = load i8, i8* %id15, align 1, !dbg !2091
  %conv20 = zext i8 %21 to i32, !dbg !2091
  %cmp21 = icmp sle i32 %conv20, 41, !dbg !2092
  br i1 %cmp21, label %land.lhs.true22, label %if.end27, !dbg !2093

land.lhs.true22:                                  ; preds = %land.lhs.true
  %22 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2094
  %ref23 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %22, i32 0, i32 0, !dbg !2095
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref23, i32 0, i32 1, !dbg !2096
  %23 = load i8, i8* %bank, align 1, !dbg !2096
  %conv24 = zext i8 %23 to i32, !dbg !2094
  %cmp25 = icmp ne i32 %conv24, 0, !dbg !2097
  br i1 %cmp25, label %if.then26, label %if.end27, !dbg !2098

if.then26:                                        ; preds = %land.lhs.true22
  store i1 false, i1* %retval, align 1, !dbg !2099
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup192, !dbg !2099

if.end27:                                         ; preds = %land.lhs.true22, %land.lhs.true, %if.end
  %24 = bitcast i16* %fixed to i8*, !dbg !2100
  call void @llvm.lifetime.start.p0i8(i64 2, i8* %24) #31, !dbg !2100
  call void @llvm.dbg.declare(metadata i16* %fixed, metadata !2101, metadata !DIExpression()), !dbg !2103
  %25 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2104
  %ref28 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %25, i32 0, i32 0, !dbg !2105
  %id29 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref28, i32 0, i32 0, !dbg !2106
  %26 = load i8, i8* %id29, align 4, !dbg !2106
  %27 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2107
  %region30 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %27, i32 0, i32 1, !dbg !2108
  %28 = load i8, i8* %region30, align 4, !dbg !2108
  %call31 = call zeroext i16 @_ZN4laya4full12_GLOBAL__N_111legal_widthENS_6BufferEh(i8 zeroext %26, i8 zeroext %28), !dbg !2109
  store i16 %call31, i16* %fixed, align 2, !dbg !2103
  %29 = load i16, i16* %fixed, align 2, !dbg !2110
  %tobool = icmp ne i16 %29, 0, !dbg !2110
  br i1 %tobool, label %land.lhs.true32, label %if.end38, !dbg !2112

land.lhs.true32:                                  ; preds = %if.end27
  %30 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2113
  %width33 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %30, i32 0, i32 8, !dbg !2114
  %31 = load i16, i16* %width33, align 2, !dbg !2114
  %conv34 = zext i16 %31 to i32, !dbg !2113
  %32 = load i16, i16* %fixed, align 2, !dbg !2115
  %conv35 = zext i16 %32 to i32, !dbg !2115
  %cmp36 = icmp ne i32 %conv34, %conv35, !dbg !2116
  br i1 %cmp36, label %if.then37, label %if.end38, !dbg !2117

if.then37:                                        ; preds = %land.lhs.true32
  store i1 false, i1* %retval, align 1, !dbg !2118
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup191, !dbg !2118

if.end38:                                         ; preds = %land.lhs.true32, %if.end27
  %33 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2119
  %ref39 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %33, i32 0, i32 0, !dbg !2121
  %id40 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref39, i32 0, i32 0, !dbg !2122
  %34 = load i8, i8* %id40, align 4, !dbg !2122
  %cmp41 = icmp eq i8 %34, 38, !dbg !2123
  br i1 %cmp41, label %land.lhs.true42, label %if.end50, !dbg !2124

land.lhs.true42:                                  ; preds = %if.end38
  %35 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2125
  %width43 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %35, i32 0, i32 8, !dbg !2126
  %36 = load i16, i16* %width43, align 2, !dbg !2126
  %conv44 = zext i16 %36 to i32, !dbg !2125
  %37 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2127
  %inputs45 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %37, i32 0, i32 0, !dbg !2128
  %identity46 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs45, i32 0, i32 0, !dbg !2129
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity46, i32 0, i32 3, !dbg !2130
  %38 = load i16, i16* %S, align 2, !dbg !2130
  %conv47 = zext i16 %38 to i32, !dbg !2127
  %cmp48 = icmp ne i32 %conv44, %conv47, !dbg !2131
  br i1 %cmp48, label %if.then49, label %if.end50, !dbg !2132

if.then49:                                        ; preds = %land.lhs.true42
  store i1 false, i1* %retval, align 1, !dbg !2133
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup191, !dbg !2133

if.end50:                                         ; preds = %land.lhs.true42, %if.end38
  %39 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2134
  %ref51 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %39, i32 0, i32 0, !dbg !2136
  %id52 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref51, i32 0, i32 0, !dbg !2137
  %40 = load i8, i8* %id52, align 4, !dbg !2137
  %cmp53 = icmp eq i8 %40, 10, !dbg !2138
  br i1 %cmp53, label %land.lhs.true54, label %if.end72, !dbg !2139

land.lhs.true54:                                  ; preds = %if.end50
  %41 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2140
  %region55 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %41, i32 0, i32 1, !dbg !2141
  %42 = load i8, i8* %region55, align 4, !dbg !2141
  %conv56 = zext i8 %42 to i32, !dbg !2140
  %cmp57 = icmp eq i32 %conv56, 7, !dbg !2142
  br i1 %cmp57, label %land.lhs.true58, label %if.end72, !dbg !2143

land.lhs.true58:                                  ; preds = %land.lhs.true54
  %43 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2144
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %43, i32 0, i32 5, !dbg !2145
  %44 = load i8, i8* %row_space, align 4, !dbg !2145
  %cmp59 = icmp eq i8 %44, 1, !dbg !2146
  br i1 %cmp59, label %land.lhs.true60, label %if.then71, !dbg !2147

land.lhs.true60:                                  ; preds = %land.lhs.true58
  %45 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2148
  %width61 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %45, i32 0, i32 8, !dbg !2149
  %46 = load i16, i16* %width61, align 2, !dbg !2149
  %conv62 = zext i16 %46 to i32, !dbg !2148
  %cmp63 = icmp eq i32 %conv62, 1, !dbg !2150
  br i1 %cmp63, label %land.lhs.true64, label %if.then71, !dbg !2151

land.lhs.true64:                                  ; preds = %land.lhs.true60
  %47 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2152
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %47, i32 0, i32 6, !dbg !2153
  %48 = load i16, i16* %row0, align 2, !dbg !2153
  %conv65 = zext i16 %48 to i32, !dbg !2152
  %cmp66 = icmp eq i32 %conv65, 0, !dbg !2154
  br i1 %cmp66, label %land.lhs.true67, label %if.then71, !dbg !2155

land.lhs.true67:                                  ; preds = %land.lhs.true64
  %49 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2156
  %rows68 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %49, i32 0, i32 7, !dbg !2157
  %50 = load i16, i16* %rows68, align 4, !dbg !2157
  %conv69 = zext i16 %50 to i32, !dbg !2156
  %cmp70 = icmp eq i32 %conv69, 16, !dbg !2158
  br i1 %cmp70, label %if.end72, label %if.then71, !dbg !2159

if.then71:                                        ; preds = %land.lhs.true67, %land.lhs.true64, %land.lhs.true60, %land.lhs.true58
  store i1 false, i1* %retval, align 1, !dbg !2160
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup191, !dbg !2160

if.end72:                                         ; preds = %land.lhs.true67, %land.lhs.true54, %if.end50
  %51 = bitcast i16* %extent to i8*, !dbg !2161
  call void @llvm.lifetime.start.p0i8(i64 2, i8* %51) #31, !dbg !2161
  call void @llvm.dbg.declare(metadata i16* %extent, metadata !2162, metadata !DIExpression()), !dbg !2163
  %52 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2164
  %row_space73 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %52, i32 0, i32 5, !dbg !2165
  %53 = load i8, i8* %row_space73, align 4, !dbg !2165
  %cmp74 = icmp eq i8 %53, 0, !dbg !2166
  br i1 %cmp74, label %cond.true, label %cond.false, !dbg !2164

cond.true:                                        ; preds = %if.end72
  %54 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2167
  %inputs75 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %54, i32 0, i32 0, !dbg !2168
  %identity76 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs75, i32 0, i32 0, !dbg !2169
  %S77 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity76, i32 0, i32 3, !dbg !2170
  %55 = load i16, i16* %S77, align 2, !dbg !2170
  %conv78 = zext i16 %55 to i32, !dbg !2167
  br label %cond.end86, !dbg !2164

cond.false:                                       ; preds = %if.end72
  %56 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2171
  %row_space79 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %56, i32 0, i32 5, !dbg !2172
  %57 = load i8, i8* %row_space79, align 4, !dbg !2172
  %cmp80 = icmp eq i8 %57, 1, !dbg !2173
  br i1 %cmp80, label %cond.true81, label %cond.false82, !dbg !2171

cond.true81:                                      ; preds = %cond.false
  br label %cond.end, !dbg !2171

cond.false82:                                     ; preds = %cond.false
  %58 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2174
  %row_space83 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %58, i32 0, i32 5, !dbg !2175
  %59 = load i8, i8* %row_space83, align 4, !dbg !2175
  %cmp84 = icmp eq i8 %59, 2, !dbg !2176
  %60 = zext i1 %cmp84 to i64, !dbg !2174
  %cond = select i1 %cmp84, i32 3, i32 0, !dbg !2174
  br label %cond.end, !dbg !2171

cond.end:                                         ; preds = %cond.false82, %cond.true81
  %cond85 = phi i32 [ 16, %cond.true81 ], [ %cond, %cond.false82 ], !dbg !2171
  br label %cond.end86, !dbg !2164

cond.end86:                                       ; preds = %cond.end, %cond.true
  %cond87 = phi i32 [ %conv78, %cond.true ], [ %cond85, %cond.end ], !dbg !2164
  %conv88 = trunc i32 %cond87 to i16, !dbg !2164
  store i16 %conv88, i16* %extent, align 2, !dbg !2163
  %61 = load i16, i16* %extent, align 2, !dbg !2177
  %tobool89 = icmp ne i16 %61, 0, !dbg !2177
  br i1 %tobool89, label %lor.lhs.false90, label %if.then107, !dbg !2179

lor.lhs.false90:                                  ; preds = %cond.end86
  %62 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2180
  %row091 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %62, i32 0, i32 6, !dbg !2181
  %63 = load i16, i16* %row091, align 2, !dbg !2181
  %conv92 = zext i16 %63 to i32, !dbg !2180
  %64 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2182
  %rows93 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %64, i32 0, i32 7, !dbg !2183
  %65 = load i16, i16* %rows93, align 4, !dbg !2183
  %conv94 = zext i16 %65 to i32, !dbg !2182
  %add = add i32 %conv92, %conv94, !dbg !2184
  %66 = load i16, i16* %extent, align 2, !dbg !2185
  %conv95 = zext i16 %66 to i32, !dbg !2185
  %cmp96 = icmp ugt i32 %add, %conv95, !dbg !2186
  br i1 %cmp96, label %if.then107, label %lor.lhs.false97, !dbg !2187

lor.lhs.false97:                                  ; preds = %lor.lhs.false90
  %67 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2188
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %67, i32 0, i32 4, !dbg !2189
  %68 = load i8, i8* %batch, align 1, !dbg !2189
  %conv98 = zext i8 %68 to i32, !dbg !2188
  %cmp99 = icmp ne i32 %conv98, 255, !dbg !2190
  br i1 %cmp99, label %land.lhs.true100, label %if.end108, !dbg !2191

land.lhs.true100:                                 ; preds = %lor.lhs.false97
  %69 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2192
  %batch101 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %69, i32 0, i32 4, !dbg !2193
  %70 = load i8, i8* %batch101, align 1, !dbg !2193
  %conv102 = zext i8 %70 to i32, !dbg !2192
  %71 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2194
  %inputs103 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %71, i32 0, i32 0, !dbg !2195
  %identity104 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs103, i32 0, i32 0, !dbg !2196
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity104, i32 0, i32 2, !dbg !2197
  %72 = load i16, i16* %B, align 8, !dbg !2197
  %conv105 = zext i16 %72 to i32, !dbg !2194
  %cmp106 = icmp sge i32 %conv102, %conv105, !dbg !2198
  br i1 %cmp106, label %if.then107, label %if.end108, !dbg !2199

if.then107:                                       ; preds = %land.lhs.true100, %lor.lhs.false90, %cond.end86
  store i1 false, i1* %retval, align 1, !dbg !2200
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2200

if.end108:                                        ; preds = %land.lhs.true100, %lor.lhs.false97
  %73 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2201
  %ref109 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %73, i32 0, i32 0, !dbg !2203
  %id110 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref109, i32 0, i32 0, !dbg !2204
  %74 = load i8, i8* %id110, align 4, !dbg !2204
  %cmp111 = icmp eq i8 %74, 11, !dbg !2205
  br i1 %cmp111, label %if.then112, label %if.end126, !dbg !2206

if.then112:                                       ; preds = %if.end108
  %75 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2207
  %batch113 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %75, i32 0, i32 4, !dbg !2208
  %76 = load i8, i8* %batch113, align 1, !dbg !2208
  %conv114 = zext i8 %76 to i32, !dbg !2207
  %cmp115 = icmp eq i32 %conv114, 0, !dbg !2209
  br i1 %cmp115, label %land.lhs.true116, label %land.end, !dbg !2210

land.lhs.true116:                                 ; preds = %if.then112
  %77 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2211
  %row_space117 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %77, i32 0, i32 5, !dbg !2212
  %78 = load i8, i8* %row_space117, align 4, !dbg !2212
  %cmp118 = icmp eq i8 %78, 2, !dbg !2213
  br i1 %cmp118, label %land.lhs.true119, label %land.end, !dbg !2214

land.lhs.true119:                                 ; preds = %land.lhs.true116
  %79 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2215
  %row0120 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %79, i32 0, i32 6, !dbg !2216
  %80 = load i16, i16* %row0120, align 2, !dbg !2216
  %conv121 = zext i16 %80 to i32, !dbg !2215
  %cmp122 = icmp eq i32 %conv121, 0, !dbg !2217
  br i1 %cmp122, label %land.rhs, label %land.end, !dbg !2218

land.rhs:                                         ; preds = %land.lhs.true119
  %81 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2219
  %rows123 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %81, i32 0, i32 7, !dbg !2220
  %82 = load i16, i16* %rows123, align 4, !dbg !2220
  %conv124 = zext i16 %82 to i32, !dbg !2219
  %cmp125 = icmp eq i32 %conv124, 3, !dbg !2221
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.lhs.true119, %land.lhs.true116, %if.then112
  %83 = phi i1 [ false, %land.lhs.true119 ], [ false, %land.lhs.true116 ], [ false, %if.then112 ], [ %cmp125, %land.rhs ], !dbg !2222
  store i1 %83, i1* %retval, align 1, !dbg !2223
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2223

if.end126:                                        ; preds = %if.end108
  %84 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2224
  %ref127 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %84, i32 0, i32 0, !dbg !2226
  %id128 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref127, i32 0, i32 0, !dbg !2227
  %85 = load i8, i8* %id128, align 4, !dbg !2227
  %cmp129 = icmp eq i8 %85, 8, !dbg !2228
  br i1 %cmp129, label %if.then130, label %if.end150, !dbg !2229

if.then130:                                       ; preds = %if.end126
  %86 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2230
  %batch131 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %86, i32 0, i32 4, !dbg !2231
  %87 = load i8, i8* %batch131, align 1, !dbg !2231
  %conv132 = zext i8 %87 to i32, !dbg !2230
  %cmp133 = icmp eq i32 %conv132, 255, !dbg !2232
  br i1 %cmp133, label %land.lhs.true134, label %land.end149, !dbg !2233

land.lhs.true134:                                 ; preds = %if.then130
  %88 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2234
  %row_space135 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %88, i32 0, i32 5, !dbg !2235
  %89 = load i8, i8* %row_space135, align 4, !dbg !2235
  %cmp136 = icmp eq i8 %89, 0, !dbg !2236
  br i1 %cmp136, label %land.lhs.true137, label %land.end149, !dbg !2237

land.lhs.true137:                                 ; preds = %land.lhs.true134
  %90 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2238
  %row0138 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %90, i32 0, i32 6, !dbg !2239
  %91 = load i16, i16* %row0138, align 2, !dbg !2239
  %conv139 = zext i16 %91 to i32, !dbg !2238
  %cmp140 = icmp eq i32 %conv139, 0, !dbg !2240
  br i1 %cmp140, label %land.rhs141, label %land.end149, !dbg !2241

land.rhs141:                                      ; preds = %land.lhs.true137
  %92 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2242
  %rows142 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %92, i32 0, i32 7, !dbg !2243
  %93 = load i16, i16* %rows142, align 4, !dbg !2243
  %conv143 = zext i16 %93 to i32, !dbg !2242
  %94 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2244
  %inputs144 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %94, i32 0, i32 0, !dbg !2245
  %identity145 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs144, i32 0, i32 0, !dbg !2246
  %S146 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity145, i32 0, i32 3, !dbg !2247
  %95 = load i16, i16* %S146, align 2, !dbg !2247
  %conv147 = zext i16 %95 to i32, !dbg !2244
  %cmp148 = icmp eq i32 %conv143, %conv147, !dbg !2248
  br label %land.end149

land.end149:                                      ; preds = %land.rhs141, %land.lhs.true137, %land.lhs.true134, %if.then130
  %96 = phi i1 [ false, %land.lhs.true137 ], [ false, %land.lhs.true134 ], [ false, %if.then130 ], [ %cmp148, %land.rhs141 ], !dbg !2249
  store i1 %96, i1* %retval, align 1, !dbg !2250
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2250

if.end150:                                        ; preds = %if.end126
  %97 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2251
  %ref151 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %97, i32 0, i32 0, !dbg !2253
  %id152 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref151, i32 0, i32 0, !dbg !2254
  %98 = load i8, i8* %id152, align 4, !dbg !2254
  %cmp153 = icmp eq i8 %98, 35, !dbg !2255
  br i1 %cmp153, label %if.then162, label %lor.lhs.false154, !dbg !2256

lor.lhs.false154:                                 ; preds = %if.end150
  %99 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2257
  %ref155 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %99, i32 0, i32 0, !dbg !2258
  %id156 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref155, i32 0, i32 0, !dbg !2259
  %100 = load i8, i8* %id156, align 4, !dbg !2259
  %cmp157 = icmp eq i8 %100, 42, !dbg !2260
  br i1 %cmp157, label %if.then162, label %lor.lhs.false158, !dbg !2261

lor.lhs.false158:                                 ; preds = %lor.lhs.false154
  %101 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2262
  %ref159 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %101, i32 0, i32 0, !dbg !2263
  %id160 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref159, i32 0, i32 0, !dbg !2264
  %102 = load i8, i8* %id160, align 4, !dbg !2264
  %cmp161 = icmp eq i8 %102, 43, !dbg !2265
  br i1 %cmp161, label %if.then162, label %if.end178, !dbg !2266

if.then162:                                       ; preds = %lor.lhs.false158, %lor.lhs.false154, %if.end150
  %103 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2267
  %batch163 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %103, i32 0, i32 4, !dbg !2268
  %104 = load i8, i8* %batch163, align 1, !dbg !2268
  %conv164 = zext i8 %104 to i32, !dbg !2267
  %cmp165 = icmp eq i32 %conv164, 0, !dbg !2269
  br i1 %cmp165, label %land.lhs.true166, label %land.end177, !dbg !2270

land.lhs.true166:                                 ; preds = %if.then162
  %105 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2271
  %row_space167 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %105, i32 0, i32 5, !dbg !2272
  %106 = load i8, i8* %row_space167, align 4, !dbg !2272
  %cmp168 = icmp eq i8 %106, 2, !dbg !2273
  br i1 %cmp168, label %land.lhs.true169, label %land.end177, !dbg !2274

land.lhs.true169:                                 ; preds = %land.lhs.true166
  %107 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2275
  %row0170 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %107, i32 0, i32 6, !dbg !2276
  %108 = load i16, i16* %row0170, align 2, !dbg !2276
  %conv171 = zext i16 %108 to i32, !dbg !2275
  %cmp172 = icmp eq i32 %conv171, 0, !dbg !2277
  br i1 %cmp172, label %land.rhs173, label %land.end177, !dbg !2278

land.rhs173:                                      ; preds = %land.lhs.true169
  %109 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2279
  %rows174 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %109, i32 0, i32 7, !dbg !2280
  %110 = load i16, i16* %rows174, align 4, !dbg !2280
  %conv175 = zext i16 %110 to i32, !dbg !2279
  %cmp176 = icmp eq i32 %conv175, 1, !dbg !2281
  br label %land.end177

land.end177:                                      ; preds = %land.rhs173, %land.lhs.true169, %land.lhs.true166, %if.then162
  %111 = phi i1 [ false, %land.lhs.true169 ], [ false, %land.lhs.true166 ], [ false, %if.then162 ], [ %cmp176, %land.rhs173 ], !dbg !2282
  store i1 %111, i1* %retval, align 1, !dbg !2283
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2283

if.end178:                                        ; preds = %lor.lhs.false158
  %112 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2284
  %row_space179 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %112, i32 0, i32 5, !dbg !2286
  %113 = load i8, i8* %row_space179, align 4, !dbg !2286
  %cmp180 = icmp eq i8 %113, 2, !dbg !2287
  br i1 %cmp180, label %if.then181, label %if.end190, !dbg !2288

if.then181:                                       ; preds = %if.end178
  %114 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2289
  %row0182 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %114, i32 0, i32 6, !dbg !2290
  %115 = load i16, i16* %row0182, align 2, !dbg !2290
  %conv183 = zext i16 %115 to i32, !dbg !2289
  %cmp184 = icmp eq i32 %conv183, 0, !dbg !2291
  br i1 %cmp184, label %land.rhs185, label %land.end189, !dbg !2292

land.rhs185:                                      ; preds = %if.then181
  %116 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2293
  %rows186 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %116, i32 0, i32 7, !dbg !2294
  %117 = load i16, i16* %rows186, align 4, !dbg !2294
  %conv187 = zext i16 %117 to i32, !dbg !2293
  %cmp188 = icmp eq i32 %conv187, 1, !dbg !2295
  br label %land.end189

land.end189:                                      ; preds = %land.rhs185, %if.then181
  %118 = phi i1 [ false, %if.then181 ], [ %cmp188, %land.rhs185 ], !dbg !2296
  store i1 %118, i1* %retval, align 1, !dbg !2297
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2297

if.end190:                                        ; preds = %if.end178
  store i1 true, i1* %retval, align 1, !dbg !2298
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2298

cleanup:                                          ; preds = %if.end190, %land.end189, %land.end177, %land.end149, %land.end, %if.then107
  %119 = bitcast i16* %extent to i8*, !dbg !2299
  call void @llvm.lifetime.end.p0i8(i64 2, i8* %119) #31, !dbg !2299
  br label %cleanup191

cleanup191:                                       ; preds = %cleanup, %if.then71, %if.then49, %if.then37
  %120 = bitcast i16* %fixed to i8*, !dbg !2299
  call void @llvm.lifetime.end.p0i8(i64 2, i8* %120) #31, !dbg !2299
  br label %cleanup192

cleanup192:                                       ; preds = %cleanup191, %if.then26
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %id15) #31, !dbg !2299
  br label %return

return:                                           ; preds = %cleanup192, %if.then
  %121 = load i1, i1* %retval, align 1, !dbg !2299
  ret i1 %121, !dbg !2299
}

; Function Attrs: nounwind
define internal void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %id, i16 zeroext %reason) #12 !dbg !2300 {
entry:
  %id.addr = alloca i8, align 1
  %reason.addr = alloca i16, align 2
  store i8 %id, i8* %id.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %id.addr, metadata !2303, metadata !DIExpression()), !dbg !2304
  store i16 %reason, i16* %reason.addr, align 2
  call void @llvm.dbg.declare(metadata i16* %reason.addr, metadata !2305, metadata !DIExpression()), !dbg !2306
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !2307
  store i16 5, i16* %code, align 8, !dbg !2307
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !2307
  %0 = load i8, i8* %id.addr, align 1, !dbg !2308
  %1 = load i16, i16* %reason.addr, align 2, !dbg !2309
  %call = call i32 @_ZN4laya6detailEhht(i8 zeroext 4, i8 zeroext %0, i16 zeroext %1), !dbg !2310
  store i32 %call, i32* %detail, align 4, !dbg !2307
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !2307
  store i64 -1, i64* %bad_element, align 8, !dbg !2307
  ret void, !dbg !2311
}

; Function Attrs: nounwind
define internal i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %s) #13 !dbg !2312 {
entry:
  %retval = alloca i32, align 4
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %r = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2315, metadata !DIExpression()), !dbg !2316
  store %"struct.laya::full::FullOwnerSpec"* %s, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %s.addr, metadata !2317, metadata !DIExpression()), !dbg !2318
  %0 = bitcast i32* %index to i8*, !dbg !2319
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !2319
  call void @llvm.dbg.declare(metadata i32* %index, metadata !2320, metadata !DIExpression()), !dbg !2321
  %1 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2322
  %2 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2323
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %2, i32 0, i32 0, !dbg !2324
  %3 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !2323
  store %"struct.laya::BufferRef" %3, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !2323
  %4 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2325
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %4, i32 0, i32 1, !dbg !2326
  %5 = load i8, i8* %region, align 4, !dbg !2326
  %call = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %1, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext %5), !dbg !2327
  store i32 %call, i32* %index, align 4, !dbg !2321
  %6 = load i32, i32* %index, align 4, !dbg !2328
  %cmp = icmp eq i32 %6, 32, !dbg !2330
  br i1 %cmp, label %if.then, label %if.end, !dbg !2331

if.then:                                          ; preds = %entry
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2332
  %call1 = call i32 @_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %7, i32 32), !dbg !2333
  store i32 %call1, i32* %index, align 4, !dbg !2334
  br label %if.end, !dbg !2335

if.end:                                           ; preds = %if.then, %entry
  %8 = load i32, i32* %index, align 4, !dbg !2336
  %cmp2 = icmp eq i32 %8, 32, !dbg !2338
  br i1 %cmp2, label %if.then3, label %if.end4, !dbg !2339

if.then3:                                         ; preds = %if.end
  store i32 32, i32* %retval, align 4, !dbg !2340
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup17, !dbg !2340

if.end4:                                          ; preds = %if.end
  %9 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !2341
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %9) #31, !dbg !2341
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r, metadata !2342, metadata !DIExpression()), !dbg !2345
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2346
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %10, i32 0, i32 1, !dbg !2347
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !2348
  %11 = load i32, i32* %index, align 4, !dbg !2349
  %idxprom = zext i32 %11 to i64, !dbg !2346
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !2346
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2345
  %12 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2350
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %12, i32 0, i32 17, !dbg !2352
  %13 = load i1, i1* %valid, align 4, !dbg !2352
  br i1 %13, label %if.then15, label %lor.lhs.false, !dbg !2353

lor.lhs.false:                                    ; preds = %if.end4
  %14 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2354
  %readers = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %14, i32 0, i32 14, !dbg !2355
  %15 = load i8, i8* %readers, align 2, !dbg !2355
  %tobool = icmp ne i8 %15, 0, !dbg !2354
  br i1 %tobool, label %if.then15, label %lor.lhs.false5, !dbg !2356

lor.lhs.false5:                                   ; preds = %lor.lhs.false
  %16 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2357
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %16, i32 0, i32 13, !dbg !2358
  %17 = load i8, i8* %state, align 1, !dbg !2358
  %cmp6 = icmp ne i8 %17, 0, !dbg !2359
  br i1 %cmp6, label %land.lhs.true, label %lor.lhs.false9, !dbg !2360

land.lhs.true:                                    ; preds = %lor.lhs.false5
  %18 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2361
  %state7 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %18, i32 0, i32 13, !dbg !2362
  %19 = load i8, i8* %state7, align 1, !dbg !2362
  %cmp8 = icmp ne i8 %19, 6, !dbg !2363
  br i1 %cmp8, label %if.then15, label %lor.lhs.false9, !dbg !2364

lor.lhs.false9:                                   ; preds = %land.lhs.true, %lor.lhs.false5
  %20 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2365
  %max_claimed_epoch = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %20, i32 0, i32 3, !dbg !2366
  %21 = load i32, i32* %max_claimed_epoch, align 8, !dbg !2366
  %cmp10 = icmp uge i32 %21, -2, !dbg !2367
  br i1 %cmp10, label %if.then15, label %lor.lhs.false11, !dbg !2368

lor.lhs.false11:                                  ; preds = %lor.lhs.false9
  %22 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2369
  %ref12 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %22, i32 0, i32 0, !dbg !2370
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref12, i32 0, i32 2, !dbg !2371
  %23 = load i32, i32* %epoch, align 4, !dbg !2371
  %24 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2372
  %max_claimed_epoch13 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %24, i32 0, i32 3, !dbg !2373
  %25 = load i32, i32* %max_claimed_epoch13, align 8, !dbg !2373
  %add = add i32 %25, 1, !dbg !2374
  %cmp14 = icmp ne i32 %23, %add, !dbg !2375
  br i1 %cmp14, label %if.then15, label %if.end16, !dbg !2376

if.then15:                                        ; preds = %lor.lhs.false11, %lor.lhs.false9, %land.lhs.true, %lor.lhs.false, %if.end4
  store i32 32, i32* %retval, align 4, !dbg !2377
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2377

if.end16:                                         ; preds = %lor.lhs.false11
  %26 = load i32, i32* %index, align 4, !dbg !2378
  store i32 %26, i32* %retval, align 4, !dbg !2379
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2379

cleanup:                                          ; preds = %if.end16, %if.then15
  %27 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !2380
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %27) #31, !dbg !2380
  br label %cleanup17

cleanup17:                                        ; preds = %cleanup, %if.then3
  %28 = bitcast i32* %index to i8*, !dbg !2380
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %28) #31, !dbg !2380
  %29 = load i32, i32* %retval, align 4, !dbg !2380
  ret i32 %29, !dbg !2380
}

; Function Attrs: nounwind
define internal void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %r, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %s, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity) #14 !dbg !2381 {
entry:
  %r.addr = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %s.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %identity.addr = alloca %"struct.laya::NumericIdentity"*, align 8
  %ref.tmp = alloca %"struct.laya::BufferRef", align 4
  store %"struct.laya::full::FullOwnerRecord"* %r, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r.addr, metadata !2385, metadata !DIExpression()), !dbg !2386
  store %"struct.laya::full::FullOwnerSpec"* %s, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %s.addr, metadata !2387, metadata !DIExpression()), !dbg !2388
  store %"struct.laya::NumericIdentity"* %identity, %"struct.laya::NumericIdentity"** %identity.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::NumericIdentity"** %identity.addr, metadata !2389, metadata !DIExpression()), !dbg !2390
  %0 = load %"struct.laya::NumericIdentity"*, %"struct.laya::NumericIdentity"** %identity.addr, align 8, !dbg !2391
  %1 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2392
  %identity1 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %1, i32 0, i32 0, !dbg !2393
  %2 = load %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %0, align 8, !dbg !2394
  store %"struct.laya::NumericIdentity" %2, %"struct.laya::NumericIdentity"* %identity1, align 8, !dbg !2394
  %3 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2395
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %3, i32 0, i32 0, !dbg !2396
  %4 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2397
  %ref2 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %4, i32 0, i32 1, !dbg !2398
  %5 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !2399
  store %"struct.laya::BufferRef" %5, %"struct.laya::BufferRef"* %ref2, align 8, !dbg !2399
  %6 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !2400
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %6) #31, !dbg !2400
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp), !dbg !2400
  %7 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2401
  %lease_old_ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %7, i32 0, i32 2, !dbg !2402
  %8 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, align 4, !dbg !2403
  store %"struct.laya::BufferRef" %8, %"struct.laya::BufferRef"* %lease_old_ref, align 8, !dbg !2403
  %9 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !2401
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %9) #31, !dbg !2401
  %10 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2404
  %ref3 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %10, i32 0, i32 0, !dbg !2405
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref3, i32 0, i32 2, !dbg !2406
  %11 = load i32, i32* %epoch, align 4, !dbg !2406
  %12 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2407
  %max_claimed_epoch = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %12, i32 0, i32 3, !dbg !2408
  store i32 %11, i32* %max_claimed_epoch, align 8, !dbg !2409
  %13 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2410
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %13, i32 0, i32 1, !dbg !2411
  %14 = load i8, i8* %region, align 4, !dbg !2411
  %15 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2412
  %region4 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %15, i32 0, i32 4, !dbg !2413
  store i8 %14, i8* %region4, align 4, !dbg !2414
  %16 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2415
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %16, i32 0, i32 2, !dbg !2416
  %17 = load i8, i8* %stage, align 1, !dbg !2416
  %18 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2417
  %stage5 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %18, i32 0, i32 5, !dbg !2418
  store i8 %17, i8* %stage5, align 1, !dbg !2419
  %19 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2420
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %19, i32 0, i32 3, !dbg !2421
  %20 = load i8, i8* %layer, align 2, !dbg !2421
  %21 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2422
  %layer6 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %21, i32 0, i32 6, !dbg !2423
  store i8 %20, i8* %layer6, align 2, !dbg !2424
  %22 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2425
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %22, i32 0, i32 4, !dbg !2426
  %23 = load i8, i8* %batch, align 1, !dbg !2426
  %24 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2427
  %batch7 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %24, i32 0, i32 7, !dbg !2428
  store i8 %23, i8* %batch7, align 1, !dbg !2429
  %25 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2430
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %25, i32 0, i32 5, !dbg !2431
  %26 = load i8, i8* %row_space, align 4, !dbg !2431
  %27 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2432
  %row_space8 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %27, i32 0, i32 8, !dbg !2433
  store i8 %26, i8* %row_space8, align 8, !dbg !2434
  %28 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2435
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %28, i32 0, i32 6, !dbg !2436
  %29 = load i16, i16* %row0, align 2, !dbg !2436
  %30 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2437
  %row09 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %30, i32 0, i32 9, !dbg !2438
  store i16 %29, i16* %row09, align 2, !dbg !2439
  %31 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2440
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %31, i32 0, i32 7, !dbg !2441
  %32 = load i16, i16* %rows, align 4, !dbg !2441
  %33 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2442
  %rows10 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %33, i32 0, i32 10, !dbg !2443
  store i16 %32, i16* %rows10, align 4, !dbg !2444
  %34 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2445
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %34, i32 0, i32 8, !dbg !2446
  %35 = load i16, i16* %width, align 2, !dbg !2446
  %36 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2447
  %width11 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %36, i32 0, i32 11, !dbg !2448
  store i16 %35, i16* %width11, align 2, !dbg !2449
  %37 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %s.addr, align 8, !dbg !2450
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %37, i32 0, i32 9, !dbg !2451
  %38 = load i8, i8* %content, align 4, !dbg !2451
  %39 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2452
  %content12 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %39, i32 0, i32 12, !dbg !2453
  store i8 %38, i8* %content12, align 8, !dbg !2454
  %40 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2455
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %40, i32 0, i32 13, !dbg !2456
  store i8 1, i8* %state, align 1, !dbg !2457
  %41 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2458
  %readers = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %41, i32 0, i32 14, !dbg !2459
  store i8 0, i8* %readers, align 2, !dbg !2460
  %42 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2461
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %42, i32 0, i32 17, !dbg !2462
  store i1 false, i1* %valid, align 4, !dbg !2463
  %43 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2464
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %43, i32 0, i32 15, !dbg !2465
  %arraydecay = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !2464
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay), !dbg !2466
  %44 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r.addr, align 8, !dbg !2467
  %old_consumed_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %44, i32 0, i32 16, !dbg !2468
  %arraydecay13 = getelementptr inbounds [64 x i32], [64 x i32]* %old_consumed_rows, i64 0, i64 0, !dbg !2467
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay13), !dbg !2469
  ret void, !dbg !2470
}

; Function Attrs: nounwind
define linkonce_odr dso_local void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* noalias sret(%"struct.laya::BufferRef") align 4 %agg.result) #15 comdat !dbg !2471 {
entry:
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.result, i32 0, i32 0, !dbg !2474
  store i8 0, i8* %id, align 4, !dbg !2474
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.result, i32 0, i32 1, !dbg !2474
  store i8 0, i8* %bank, align 1, !dbg !2474
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.result, i32 0, i32 2, !dbg !2474
  store i32 0, i32* %epoch, align 4, !dbg !2474
  ret void, !dbg !2475
}

; Function Attrs: nounwind
define internal void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* "fpga.decayed.dim.hint"="64" %bits) #16 !dbg !2476 {
entry:
  %bits.addr = alloca i32*, align 8
  %i = alloca i32, align 4
  store i32* %bits, i32** %bits.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %bits.addr, metadata !2479, metadata !DIExpression()), !dbg !2480
  br label %VITIS_LOOP_129_1, !dbg !2481

VITIS_LOOP_129_1:                                 ; preds = %entry
  %0 = bitcast i32* %i to i8*, !dbg !2482
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !2482
  call void @llvm.dbg.declare(metadata i32* %i, metadata !2484, metadata !DIExpression()), !dbg !2485
  store i32 0, i32* %i, align 4, !dbg !2485
  br label %for.cond, !dbg !2482

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_129_1
  %1 = load i32, i32* %i, align 4, !dbg !2486
  %cmp = icmp ult i32 %1, 64, !dbg !2488
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !2489

for.cond.cleanup:                                 ; preds = %for.cond
  %2 = bitcast i32* %i to i8*, !dbg !2490
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %2) #31, !dbg !2490
  br label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load i32*, i32** %bits.addr, align 8, !dbg !2491
  %4 = load i32, i32* %i, align 4, !dbg !2492
  %idxprom = zext i32 %4 to i64, !dbg !2491
  %arrayidx = getelementptr inbounds i32, i32* %3, i64 %idxprom, !dbg !2491
  store i32 0, i32* %arrayidx, align 4, !dbg !2493
  br label %for.inc, !dbg !2491

for.inc:                                          ; preds = %for.body
  %5 = load i32, i32* %i, align 4, !dbg !2494
  %inc = add i32 %5, 1, !dbg !2494
  store i32 %inc, i32* %i, align 4, !dbg !2494
  br label %for.cond, !dbg !2490, !llvm.loop !2495

for.end:                                          ; preds = %for.cond.cleanup
  ret void, !dbg !2498
}

; Function Attrs: nounwind
define internal i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %ref, i8 zeroext %region) #17 !dbg !2499 {
entry:
  %retval = alloca i32, align 4
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %region.addr = alloca i8, align 1
  %i = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %r = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %agg.tmp5 = alloca %"struct.laya::BufferRef", align 4
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2502, metadata !DIExpression()), !dbg !2503
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %ref, metadata !2504, metadata !DIExpression()), !dbg !2505
  store i8 %region, i8* %region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %region.addr, metadata !2506, metadata !DIExpression()), !dbg !2507
  br label %VITIS_LOOP_116_1, !dbg !2508

VITIS_LOOP_116_1:                                 ; preds = %entry
  %0 = bitcast i32* %i to i8*, !dbg !2509
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !2509
  call void @llvm.dbg.declare(metadata i32* %i, metadata !2511, metadata !DIExpression()), !dbg !2512
  store i32 0, i32* %i, align 4, !dbg !2512
  br label %for.cond, !dbg !2509

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_116_1
  %1 = load i32, i32* %i, align 4, !dbg !2513
  %cmp = icmp ult i32 %1, 32, !dbg !2515
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !2516

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup6, !dbg !2516

for.body:                                         ; preds = %for.cond
  %2 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !2517
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #31, !dbg !2517
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r, metadata !2519, metadata !DIExpression()), !dbg !2520
  %3 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2521
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %3, i32 0, i32 1, !dbg !2522
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !2523
  %4 = load i32, i32* %i, align 4, !dbg !2524
  %idxprom = zext i32 %4 to i64, !dbg !2521
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !2521
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2520
  %5 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2525
  %ref1 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %5, i32 0, i32 1, !dbg !2527
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref1, i32 0, i32 0, !dbg !2528
  %6 = load i8, i8* %id, align 8, !dbg !2528
  %cmp2 = icmp ne i8 %6, 0, !dbg !2529
  br i1 %cmp2, label %land.lhs.true, label %if.end, !dbg !2530

land.lhs.true:                                    ; preds = %for.body
  %7 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2531
  %ref3 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %7, i32 0, i32 1, !dbg !2532
  %8 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref3, align 8, !dbg !2531
  store %"struct.laya::BufferRef" %8, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !2531
  %9 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !2533
  %region4 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %9, i32 0, i32 4, !dbg !2534
  %10 = load i8, i8* %region4, align 4, !dbg !2534
  %11 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !2535
  store %"struct.laya::BufferRef" %11, %"struct.laya::BufferRef"* %agg.tmp5, align 4, !dbg !2535
  %12 = load i8, i8* %region.addr, align 1, !dbg !2536
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext %10, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp5, i8 zeroext %12), !dbg !2537
  br i1 %call, label %if.then, label %if.end, !dbg !2538

if.then:                                          ; preds = %land.lhs.true
  %13 = load i32, i32* %i, align 4, !dbg !2539
  store i32 %13, i32* %retval, align 4, !dbg !2540
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2540

if.end:                                           ; preds = %land.lhs.true, %for.body
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !2541
  br label %cleanup, !dbg !2541

cleanup:                                          ; preds = %if.end, %if.then
  %14 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !2541
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %14) #31, !dbg !2541
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup6 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %for.inc, !dbg !2542

for.inc:                                          ; preds = %cleanup.cont
  %15 = load i32, i32* %i, align 4, !dbg !2543
  %inc = add i32 %15, 1, !dbg !2543
  store i32 %inc, i32* %i, align 4, !dbg !2543
  br label %for.cond, !dbg !2544, !llvm.loop !2545

cleanup6:                                         ; preds = %cleanup, %for.cond.cleanup
  %16 = bitcast i32* %i to i8*, !dbg !2544
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #31, !dbg !2544
  %cleanup.dest7 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest7, label %unreachable [
    i32 3, label %for.end
    i32 1, label %return
  ]

for.end:                                          ; preds = %cleanup6
  store i32 32, i32* %retval, align 4, !dbg !2548
  br label %return, !dbg !2548

return:                                           ; preds = %for.end, %cleanup6
  %17 = load i32, i32* %retval, align 4, !dbg !2549
  ret i32 %17, !dbg !2549

unreachable:                                      ; preds = %cleanup6
  unreachable
}

; Function Attrs: nounwind
define internal i32 @_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, i32 %excluded) #18 !dbg !2550 {
entry:
  %retval = alloca i32, align 4
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %excluded.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2553, metadata !DIExpression()), !dbg !2554
  store i32 %excluded, i32* %excluded.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %excluded.addr, metadata !2555, metadata !DIExpression()), !dbg !2556
  br label %VITIS_LOOP_124_1, !dbg !2557

VITIS_LOOP_124_1:                                 ; preds = %entry
  %0 = bitcast i32* %i to i8*, !dbg !2558
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !2558
  call void @llvm.dbg.declare(metadata i32* %i, metadata !2560, metadata !DIExpression()), !dbg !2561
  store i32 0, i32* %i, align 4, !dbg !2561
  br label %for.cond, !dbg !2558

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_124_1
  %1 = load i32, i32* %i, align 4, !dbg !2562
  %cmp = icmp ult i32 %1, 32, !dbg !2564
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !2565

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2565

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* %i, align 4, !dbg !2566
  %3 = load i32, i32* %excluded.addr, align 4, !dbg !2568
  %cmp1 = icmp ne i32 %2, %3, !dbg !2569
  br i1 %cmp1, label %land.lhs.true, label %if.end, !dbg !2570

land.lhs.true:                                    ; preds = %for.body
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2571
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %4, i32 0, i32 1, !dbg !2572
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !2573
  %5 = load i32, i32* %i, align 4, !dbg !2574
  %idxprom = zext i32 %5 to i64, !dbg !2571
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !2571
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx, i32 0, i32 1, !dbg !2575
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !2576
  %6 = load i8, i8* %id, align 8, !dbg !2576
  %cmp2 = icmp eq i8 %6, 0, !dbg !2577
  br i1 %cmp2, label %if.then, label %if.end, !dbg !2578

if.then:                                          ; preds = %land.lhs.true
  %7 = load i32, i32* %i, align 4, !dbg !2579
  store i32 %7, i32* %retval, align 4, !dbg !2580
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2580

if.end:                                           ; preds = %land.lhs.true, %for.body
  br label %for.inc, !dbg !2581

for.inc:                                          ; preds = %if.end
  %8 = load i32, i32* %i, align 4, !dbg !2582
  %inc = add i32 %8, 1, !dbg !2582
  store i32 %inc, i32* %i, align 4, !dbg !2582
  br label %for.cond, !dbg !2583, !llvm.loop !2584

cleanup:                                          ; preds = %if.then, %for.cond.cleanup
  %9 = bitcast i32* %i to i8*, !dbg !2583
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %9) #31, !dbg !2583
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 3, label %for.end
    i32 1, label %return
  ]

for.end:                                          ; preds = %cleanup
  store i32 32, i32* %retval, align 4, !dbg !2587
  br label %return, !dbg !2587

return:                                           ; preds = %for.end, %cleanup
  %10 = load i32, i32* %retval, align 4, !dbg !2588
  ret i32 %10, !dbg !2588

unreachable:                                      ; preds = %cleanup
  unreachable
}

; Function Attrs: nounwind
define internal zeroext i1 @_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %a, i8 zeroext %ar, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %b, i8 zeroext %br) #19 !dbg !2589 {
entry:
  %retval = alloca i1, align 1
  %ar.addr = alloca i8, align 1
  %br.addr = alloca i8, align 1
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %a, metadata !2592, metadata !DIExpression()), !dbg !2593
  store i8 %ar, i8* %ar.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %ar.addr, metadata !2594, metadata !DIExpression()), !dbg !2595
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %b, metadata !2596, metadata !DIExpression()), !dbg !2597
  store i8 %br, i8* %br.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %br.addr, metadata !2598, metadata !DIExpression()), !dbg !2599
  %0 = load i8, i8* %ar.addr, align 1, !dbg !2600
  %conv = zext i8 %0 to i32, !dbg !2600
  %1 = load i8, i8* %br.addr, align 1, !dbg !2602
  %conv1 = zext i8 %1 to i32, !dbg !2602
  %cmp = icmp ne i32 %conv, %conv1, !dbg !2603
  br i1 %cmp, label %if.then, label %if.end, !dbg !2604

if.then:                                          ; preds = %entry
  store i1 false, i1* %retval, align 1, !dbg !2605
  br label %return, !dbg !2605

if.end:                                           ; preds = %entry
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 0, !dbg !2606
  %2 = load i8, i8* %id, align 4, !dbg !2606
  %cmp2 = icmp eq i8 %2, 43, !dbg !2608
  br i1 %cmp2, label %land.lhs.true, label %if.end6, !dbg !2609

land.lhs.true:                                    ; preds = %if.end
  %id3 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 0, !dbg !2610
  %3 = load i8, i8* %id3, align 4, !dbg !2610
  %cmp4 = icmp eq i8 %3, 43, !dbg !2611
  br i1 %cmp4, label %if.then5, label %if.end6, !dbg !2612

if.then5:                                         ; preds = %land.lhs.true
  store i1 true, i1* %retval, align 1, !dbg !2613
  br label %return, !dbg !2613

if.end6:                                          ; preds = %land.lhs.true, %if.end
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 1, !dbg !2614
  %4 = load i8, i8* %bank, align 1, !dbg !2614
  %conv7 = zext i8 %4 to i32, !dbg !2616
  %bank8 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 1, !dbg !2617
  %5 = load i8, i8* %bank8, align 1, !dbg !2617
  %conv9 = zext i8 %5 to i32, !dbg !2618
  %cmp10 = icmp ne i32 %conv7, %conv9, !dbg !2619
  br i1 %cmp10, label %if.then11, label %if.end12, !dbg !2620

if.then11:                                        ; preds = %if.end6
  store i1 false, i1* %retval, align 1, !dbg !2621
  br label %return, !dbg !2621

if.end12:                                         ; preds = %if.end6
  %id13 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 0, !dbg !2622
  %6 = load i8, i8* %id13, align 4, !dbg !2622
  %id14 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 0, !dbg !2624
  %7 = load i8, i8* %id14, align 4, !dbg !2624
  %cmp15 = icmp eq i8 %6, %7, !dbg !2625
  br i1 %cmp15, label %if.then16, label %if.end17, !dbg !2626

if.then16:                                        ; preds = %if.end12
  store i1 true, i1* %retval, align 1, !dbg !2627
  br label %return, !dbg !2627

if.end17:                                         ; preds = %if.end12
  %id18 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 0, !dbg !2628
  %8 = load i8, i8* %id18, align 4, !dbg !2628
  %cmp19 = icmp eq i8 %8, 6, !dbg !2629
  br i1 %cmp19, label %land.lhs.true20, label %lor.rhs, !dbg !2630

land.lhs.true20:                                  ; preds = %if.end17
  %id21 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 0, !dbg !2631
  %9 = load i8, i8* %id21, align 4, !dbg !2631
  %cmp22 = icmp eq i8 %9, 9, !dbg !2632
  br i1 %cmp22, label %lor.end, label %lor.rhs, !dbg !2633

lor.rhs:                                          ; preds = %land.lhs.true20, %if.end17
  %id23 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 0, !dbg !2634
  %10 = load i8, i8* %id23, align 4, !dbg !2634
  %cmp24 = icmp eq i8 %10, 9, !dbg !2635
  br i1 %cmp24, label %land.rhs, label %land.end, !dbg !2636

land.rhs:                                         ; preds = %lor.rhs
  %id25 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 0, !dbg !2637
  %11 = load i8, i8* %id25, align 4, !dbg !2637
  %cmp26 = icmp eq i8 %11, 6, !dbg !2638
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %12 = phi i1 [ false, %lor.rhs ], [ %cmp26, %land.rhs ], !dbg !2639
  br label %lor.end, !dbg !2633

lor.end:                                          ; preds = %land.end, %land.lhs.true20
  %13 = phi i1 [ true, %land.lhs.true20 ], [ %12, %land.end ]
  store i1 %13, i1* %retval, align 1, !dbg !2640
  br label %return, !dbg !2640

return:                                           ; preds = %lor.end, %if.then16, %if.then11, %if.then5, %if.then
  %14 = load i1, i1* %retval, align 1, !dbg !2641
  ret i1 %14, !dbg !2641
}

; Function Attrs: nounwind
define linkonce_odr dso_local zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %this) #20 comdat align 2 !dbg !2642 {
entry:
  %this.addr = alloca %"struct.laya::Check"*, align 8
  store %"struct.laya::Check"* %this, %"struct.laya::Check"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"** %this.addr, metadata !2643, metadata !DIExpression()), !dbg !2645
  %this1 = load %"struct.laya::Check"*, %"struct.laya::Check"** %this.addr, align 8
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %this1, i32 0, i32 0, !dbg !2646
  %0 = load i16, i16* %code, align 8, !dbg !2646
  %cmp = icmp eq i16 %0, 0, !dbg !2647
  ret i1 %cmp, !dbg !2648
}

; Function Attrs: nounwind
define internal zeroext i16 @_ZN4laya4full12_GLOBAL__N_111legal_widthENS_6BufferEh(i8 zeroext %id, i8 zeroext %region) #21 !dbg !2 {
entry:
  %retval = alloca i16, align 2
  %id.addr = alloca i8, align 1
  %region.addr = alloca i8, align 1
  store i8 %id, i8* %id.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %id.addr, metadata !2649, metadata !DIExpression()), !dbg !2650
  store i8 %region, i8* %region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %region.addr, metadata !2651, metadata !DIExpression()), !dbg !2652
  %0 = load i8, i8* %id.addr, align 1, !dbg !2653
  switch i8 %0, label %sw.default [
    i8 1, label %sw.bb
    i8 2, label %sw.bb
    i8 3, label %sw.bb
    i8 4, label %sw.bb
    i8 8, label %sw.bb
    i8 11, label %sw.bb
    i8 32, label %sw.bb
    i8 42, label %sw.bb
    i8 6, label %sw.bb1
    i8 7, label %sw.bb2
    i8 9, label %sw.bb3
    i8 5, label %sw.bb4
    i8 37, label %sw.bb4
    i8 39, label %sw.bb4
    i8 40, label %sw.bb4
    i8 41, label %sw.bb4
    i8 10, label %sw.bb5
    i8 38, label %sw.bb10
    i8 43, label %sw.bb11
  ], !dbg !2654

sw.bb:                                            ; preds = %entry, %entry, %entry, %entry, %entry, %entry, %entry, %entry
  store i16 1024, i16* %retval, align 2, !dbg !2655
  br label %return, !dbg !2655

sw.bb1:                                           ; preds = %entry
  store i16 5248, i16* %retval, align 2, !dbg !2657
  br label %return, !dbg !2657

sw.bb2:                                           ; preds = %entry
  store i16 2624, i16* %retval, align 2, !dbg !2658
  br label %return, !dbg !2658

sw.bb3:                                           ; preds = %entry
  store i16 4096, i16* %retval, align 2, !dbg !2659
  br label %return, !dbg !2659

sw.bb4:                                           ; preds = %entry, %entry, %entry, %entry, %entry
  store i16 64, i16* %retval, align 2, !dbg !2660
  br label %return, !dbg !2660

sw.bb5:                                           ; preds = %entry
  %1 = load i8, i8* %region.addr, align 1, !dbg !2661
  %conv = zext i8 %1 to i32, !dbg !2661
  %cmp = icmp eq i32 %conv, 7, !dbg !2664
  br i1 %cmp, label %if.then, label %if.end, !dbg !2665

if.then:                                          ; preds = %sw.bb5
  store i16 0, i16* %retval, align 2, !dbg !2666
  br label %return, !dbg !2666

if.end:                                           ; preds = %sw.bb5
  %2 = load i8, i8* %region.addr, align 1, !dbg !2667
  %conv6 = zext i8 %2 to i32, !dbg !2667
  %cmp7 = icmp slt i32 %conv6, 8, !dbg !2668
  br i1 %cmp7, label %cond.true, label %cond.false, !dbg !2667

cond.true:                                        ; preds = %if.end
  %3 = load i8, i8* %region.addr, align 1, !dbg !2669
  %idxprom = zext i8 %3 to i64, !dbg !2670
  %arrayidx = getelementptr inbounds [8 x i16], [8 x i16]* @_ZZN4laya4full12_GLOBAL__N_111legal_widthENS_6BufferEhE6widths, i64 0, i64 %idxprom, !dbg !2670
  %4 = load i16, i16* %arrayidx, align 2, !dbg !2670
  %conv8 = zext i16 %4 to i32, !dbg !2670
  br label %cond.end, !dbg !2667

cond.false:                                       ; preds = %if.end
  br label %cond.end, !dbg !2667

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %conv8, %cond.true ], [ 0, %cond.false ], !dbg !2667
  %conv9 = trunc i32 %cond to i16, !dbg !2667
  store i16 %conv9, i16* %retval, align 2, !dbg !2671
  br label %return, !dbg !2671

sw.bb10:                                          ; preds = %entry
  store i16 0, i16* %retval, align 2, !dbg !2672
  br label %return, !dbg !2672

sw.bb11:                                          ; preds = %entry
  store i16 64, i16* %retval, align 2, !dbg !2673
  br label %return, !dbg !2673

sw.default:                                       ; preds = %entry
  store i16 0, i16* %retval, align 2, !dbg !2674
  br label %return, !dbg !2674

return:                                           ; preds = %sw.default, %sw.bb11, %sw.bb10, %cond.end, %if.then, %sw.bb4, %sw.bb3, %sw.bb2, %sw.bb1, %sw.bb
  %5 = load i16, i16* %retval, align 2, !dbg !2675
  ret i16 %5, !dbg !2675
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %s) #22 !dbg !2676 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__range2 = alloca [2 x [3 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range3 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range4 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin4 = alloca [2 x [32 x i32]]*, align 8
  %__end4 = alloca [2 x [32 x i32]]*, align 8
  %head = alloca [2 x [32 x i32]]*, align 8
  %__range5 = alloca [2 x [32 x i32]]*, align 8
  %__begin5 = alloca [32 x i32]*, align 8
  %__end5 = alloca [32 x i32]*, align 8
  %batch = alloca [32 x i32]*, align 8
  %__range6 = alloca [32 x i32]*, align 8
  %__begin6 = alloca i32*, align 8
  %__end6 = alloca i32*, align 8
  %word = alloca i32*, align 8
  %__range274 = alloca [2 x [2 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin276 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end278 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard85 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range386 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin387 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end389 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane96 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range497 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin498 = alloca [2 x [32 x i32]]*, align 8
  %__end4100 = alloca [2 x [32 x i32]]*, align 8
  %head107 = alloca [2 x [32 x i32]]*, align 8
  %__range5108 = alloca [2 x [32 x i32]]*, align 8
  %__begin5109 = alloca [32 x i32]*, align 8
  %__end5111 = alloca [32 x i32]*, align 8
  %batch118 = alloca [32 x i32]*, align 8
  %__range6119 = alloca [32 x i32]*, align 8
  %__begin6120 = alloca i32*, align 8
  %__end6122 = alloca i32*, align 8
  %word129 = alloca i32*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2681, metadata !DIExpression()), !dbg !2682
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %s, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, metadata !2683, metadata !DIExpression()), !dbg !2684
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2685
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !2687
  %1 = load i1, i1* %request_valid, align 8, !dbg !2687
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !2688

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2689
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !2690
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !2690
  br i1 %3, label %lor.lhs.false1, label %if.then, !dbg !2691

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2692
  %5 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2693
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %4, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %5), !dbg !2694
  br i1 %call, label %if.end, label %if.then, !dbg !2695

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext 5, i16 zeroext 5), !dbg !2696
  br label %return, !dbg !2697

if.end:                                           ; preds = %lor.lhs.false1
  %6 = bitcast i32* %first to i8*, !dbg !2698
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #31, !dbg !2698
  call void @llvm.dbg.declare(metadata i32* %first, metadata !2699, metadata !DIExpression()), !dbg !2700
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2701
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2702
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !2702
  %call2 = call i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %7, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx), !dbg !2703
  store i32 %call2, i32* %first, align 4, !dbg !2700
  %9 = bitcast i32* %second to i8*, !dbg !2704
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %9) #31, !dbg !2704
  call void @llvm.dbg.declare(metadata i32* %second, metadata !2705, metadata !DIExpression()), !dbg !2706
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2707
  %11 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2708
  %arrayidx3 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %11, i64 0, i64 1, !dbg !2708
  %call4 = call i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %10, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx3), !dbg !2709
  store i32 %call4, i32* %second, align 4, !dbg !2706
  %12 = load i32, i32* %first, align 4, !dbg !2710
  %cmp = icmp ne i32 %12, 32, !dbg !2712
  br i1 %cmp, label %land.lhs.true, label %if.end11, !dbg !2713

land.lhs.true:                                    ; preds = %if.end
  %13 = load i32, i32* %second, align 4, !dbg !2714
  %14 = load i32, i32* %first, align 4, !dbg !2715
  %cmp5 = icmp eq i32 %13, %14, !dbg !2716
  br i1 %cmp5, label %land.lhs.true6, label %if.end11, !dbg !2717

land.lhs.true6:                                   ; preds = %land.lhs.true
  %15 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2718
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %15, i32 0, i32 1, !dbg !2719
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !2720
  %16 = load i32, i32* %first, align 4, !dbg !2721
  %idxprom = zext i32 %16 to i64, !dbg !2718
  %arrayidx7 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !2718
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx7, i32 0, i32 1, !dbg !2722
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !2723
  %17 = load i8, i8* %id, align 8, !dbg !2723
  %cmp8 = icmp eq i8 %17, 0, !dbg !2724
  br i1 %cmp8, label %if.then9, label %if.end11, !dbg !2725

if.then9:                                         ; preds = %land.lhs.true6
  %18 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2726
  %19 = load i32, i32* %first, align 4, !dbg !2727
  %call10 = call i32 @_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %18, i32 %19), !dbg !2728
  store i32 %call10, i32* %second, align 4, !dbg !2729
  br label %if.end11, !dbg !2730

if.end11:                                         ; preds = %if.then9, %land.lhs.true6, %land.lhs.true, %if.end
  %20 = load i32, i32* %first, align 4, !dbg !2731
  %cmp12 = icmp eq i32 %20, 32, !dbg !2733
  br i1 %cmp12, label %if.then17, label %lor.lhs.false13, !dbg !2734

lor.lhs.false13:                                  ; preds = %if.end11
  %21 = load i32, i32* %second, align 4, !dbg !2735
  %cmp14 = icmp eq i32 %21, 32, !dbg !2736
  br i1 %cmp14, label %if.then17, label %lor.lhs.false15, !dbg !2737

lor.lhs.false15:                                  ; preds = %lor.lhs.false13
  %22 = load i32, i32* %first, align 4, !dbg !2738
  %23 = load i32, i32* %second, align 4, !dbg !2739
  %cmp16 = icmp eq i32 %22, %23, !dbg !2740
  br i1 %cmp16, label %if.then17, label %if.end18, !dbg !2741

if.then17:                                        ; preds = %lor.lhs.false15, %lor.lhs.false13, %if.end11
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !2742
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2743

if.end18:                                         ; preds = %lor.lhs.false15
  %24 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2744
  %owners19 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %24, i32 0, i32 1, !dbg !2745
  %record20 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners19, i32 0, i32 0, !dbg !2746
  %25 = load i32, i32* %first, align 4, !dbg !2747
  %idxprom21 = zext i32 %25 to i64, !dbg !2744
  %arrayidx22 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record20, i64 0, i64 %idxprom21, !dbg !2744
  %26 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2748
  %arrayidx23 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %26, i64 0, i64 0, !dbg !2748
  %27 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2749
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %27, i32 0, i32 0, !dbg !2750
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !2751
  call void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %arrayidx22, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx23, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity), !dbg !2752
  %28 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2753
  %owners24 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %28, i32 0, i32 1, !dbg !2754
  %record25 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners24, i32 0, i32 0, !dbg !2755
  %29 = load i32, i32* %second, align 4, !dbg !2756
  %idxprom26 = zext i32 %29 to i64, !dbg !2753
  %arrayidx27 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record25, i64 0, i64 %idxprom26, !dbg !2753
  %30 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2757
  %arrayidx28 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %30, i64 0, i64 1, !dbg !2757
  %31 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2758
  %inputs29 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %31, i32 0, i32 0, !dbg !2759
  %identity30 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs29, i32 0, i32 0, !dbg !2760
  call void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %arrayidx27, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx28, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity30), !dbg !2761
  %32 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2762
  %owner_claims = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %32, i32 0, i32 27, !dbg !2763
  %33 = load i32, i32* %owner_claims, align 8, !dbg !2764
  %add = add i32 %33, 2, !dbg !2764
  store i32 %add, i32* %owner_claims, align 8, !dbg !2764
  br label %VITIS_LOOP_272_1, !dbg !2762

VITIS_LOOP_272_1:                                 ; preds = %if.end18
  %34 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !2765
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %34) #31, !dbg !2765
  call void @llvm.dbg.declare(metadata [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, metadata !2767, metadata !DIExpression()), !dbg !2769
  %35 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2765
  %owners31 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %35, i32 0, i32 1, !dbg !2770
  %qkv_plane_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners31, i32 0, i32 1, !dbg !2771
  store [2 x [3 x [16 x [2 x [32 x i32]]]]]* %qkv_plane_head_rows, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !2765
  %36 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !2772
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %36) #31, !dbg !2772
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__begin2, metadata !2773, metadata !DIExpression()), !dbg !2769
  %37 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !2772
  %arraydecay = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %37, i64 0, i64 0, !dbg !2772
  store [3 x [16 x [2 x [32 x i32]]]]* %arraydecay, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !2772
  %38 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !2772
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %38) #31, !dbg !2772
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__end2, metadata !2777, metadata !DIExpression()), !dbg !2769
  %39 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !2772
  %arraydecay32 = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %39, i64 0, i64 0, !dbg !2772
  %add.ptr = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %arraydecay32, i64 2, !dbg !2772
  store [3 x [16 x [2 x [32 x i32]]]]* %add.ptr, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !2772
  br label %for.cond, !dbg !2772

for.cond:                                         ; preds = %for.inc71, %VITIS_LOOP_272_1
  %40 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !2772
  %41 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !2772
  %cmp33 = icmp ne [3 x [16 x [2 x [32 x i32]]]]* %40, %41, !dbg !2772
  br i1 %cmp33, label %for.body, label %for.cond.cleanup, !dbg !2772

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %42 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !2772
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %42) #31, !dbg !2772
  %43 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !2772
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %43) #31, !dbg !2772
  %44 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !2772
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %44) #31, !dbg !2772
  br label %for.end73

for.body:                                         ; preds = %for.cond
  %45 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !2778
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %45) #31, !dbg !2778
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %shard, metadata !2780, metadata !DIExpression()), !dbg !2782
  %46 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !2783
  store [3 x [16 x [2 x [32 x i32]]]]* %46, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !2782
  br label %VITIS_LOOP_273_2, !dbg !2778

VITIS_LOOP_273_2:                                 ; preds = %for.body
  %47 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !2784
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %47) #31, !dbg !2784
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__range3, metadata !2786, metadata !DIExpression()), !dbg !2787
  %48 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !2784
  store [3 x [16 x [2 x [32 x i32]]]]* %48, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !2784
  %49 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !2788
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %49) #31, !dbg !2788
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin3, metadata !2789, metadata !DIExpression()), !dbg !2787
  %50 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !2788
  %arraydecay34 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %50, i64 0, i64 0, !dbg !2788
  store [16 x [2 x [32 x i32]]]* %arraydecay34, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !2788
  %51 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !2788
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %51) #31, !dbg !2788
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end3, metadata !2791, metadata !DIExpression()), !dbg !2787
  %52 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !2788
  %arraydecay35 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %52, i64 0, i64 0, !dbg !2788
  %add.ptr36 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay35, i64 3, !dbg !2788
  store [16 x [2 x [32 x i32]]]* %add.ptr36, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !2788
  br label %for.cond37, !dbg !2788

for.cond37:                                       ; preds = %for.inc68, %VITIS_LOOP_273_2
  %53 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !2788
  %54 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !2788
  %cmp38 = icmp ne [16 x [2 x [32 x i32]]]* %53, %54, !dbg !2788
  br i1 %cmp38, label %for.body40, label %for.cond.cleanup39, !dbg !2788

for.cond.cleanup39:                               ; preds = %for.cond37
  store i32 6, i32* %cleanup.dest.slot, align 4
  %55 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !2788
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %55) #31, !dbg !2788
  %56 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !2788
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %56) #31, !dbg !2788
  %57 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !2788
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %57) #31, !dbg !2788
  br label %for.end70

for.body40:                                       ; preds = %for.cond37
  %58 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !2792
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %58) #31, !dbg !2792
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane, metadata !2794, metadata !DIExpression()), !dbg !2795
  %59 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !2796
  store [16 x [2 x [32 x i32]]]* %59, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !2795
  br label %VITIS_LOOP_274_3, !dbg !2792

VITIS_LOOP_274_3:                                 ; preds = %for.body40
  %60 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !2797
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %60) #31, !dbg !2797
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range4, metadata !2799, metadata !DIExpression()), !dbg !2800
  %61 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !2797
  store [16 x [2 x [32 x i32]]]* %61, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !2797
  %62 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !2801
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %62) #31, !dbg !2801
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin4, metadata !2802, metadata !DIExpression()), !dbg !2800
  %63 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !2801
  %arraydecay41 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %63, i64 0, i64 0, !dbg !2801
  store [2 x [32 x i32]]* %arraydecay41, [2 x [32 x i32]]** %__begin4, align 8, !dbg !2801
  %64 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !2801
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %64) #31, !dbg !2801
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4, metadata !2803, metadata !DIExpression()), !dbg !2800
  %65 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !2801
  %arraydecay42 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %65, i64 0, i64 0, !dbg !2801
  %add.ptr43 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay42, i64 16, !dbg !2801
  store [2 x [32 x i32]]* %add.ptr43, [2 x [32 x i32]]** %__end4, align 8, !dbg !2801
  br label %for.cond44, !dbg !2801

for.cond44:                                       ; preds = %for.inc65, %VITIS_LOOP_274_3
  %66 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !2801
  %67 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4, align 8, !dbg !2801
  %cmp45 = icmp ne [2 x [32 x i32]]* %66, %67, !dbg !2801
  br i1 %cmp45, label %for.body47, label %for.cond.cleanup46, !dbg !2801

for.cond.cleanup46:                               ; preds = %for.cond44
  store i32 9, i32* %cleanup.dest.slot, align 4
  %68 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !2801
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %68) #31, !dbg !2801
  %69 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !2801
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %69) #31, !dbg !2801
  %70 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !2801
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %70) #31, !dbg !2801
  br label %for.end67

for.body47:                                       ; preds = %for.cond44
  %71 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !2804
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %71) #31, !dbg !2804
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head, metadata !2806, metadata !DIExpression()), !dbg !2807
  %72 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !2808
  store [2 x [32 x i32]]* %72, [2 x [32 x i32]]** %head, align 8, !dbg !2807
  br label %VITIS_LOOP_275_4, !dbg !2804

VITIS_LOOP_275_4:                                 ; preds = %for.body47
  %73 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !2809
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %73) #31, !dbg !2809
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5, metadata !2811, metadata !DIExpression()), !dbg !2812
  %74 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head, align 8, !dbg !2809
  store [2 x [32 x i32]]* %74, [2 x [32 x i32]]** %__range5, align 8, !dbg !2809
  %75 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !2813
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %75) #31, !dbg !2813
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5, metadata !2814, metadata !DIExpression()), !dbg !2812
  %76 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !2813
  %arraydecay48 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %76, i64 0, i64 0, !dbg !2813
  store [32 x i32]* %arraydecay48, [32 x i32]** %__begin5, align 8, !dbg !2813
  %77 = bitcast [32 x i32]** %__end5 to i8*, !dbg !2813
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %77) #31, !dbg !2813
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5, metadata !2815, metadata !DIExpression()), !dbg !2812
  %78 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !2813
  %arraydecay49 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %78, i64 0, i64 0, !dbg !2813
  %add.ptr50 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay49, i64 2, !dbg !2813
  store [32 x i32]* %add.ptr50, [32 x i32]** %__end5, align 8, !dbg !2813
  br label %for.cond51, !dbg !2813

for.cond51:                                       ; preds = %for.inc62, %VITIS_LOOP_275_4
  %79 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !2813
  %80 = load [32 x i32]*, [32 x i32]** %__end5, align 8, !dbg !2813
  %cmp52 = icmp ne [32 x i32]* %79, %80, !dbg !2813
  br i1 %cmp52, label %for.body54, label %for.cond.cleanup53, !dbg !2813

for.cond.cleanup53:                               ; preds = %for.cond51
  store i32 12, i32* %cleanup.dest.slot, align 4
  %81 = bitcast [32 x i32]** %__end5 to i8*, !dbg !2813
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %81) #31, !dbg !2813
  %82 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !2813
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %82) #31, !dbg !2813
  %83 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !2813
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %83) #31, !dbg !2813
  br label %for.end64

for.body54:                                       ; preds = %for.cond51
  %84 = bitcast [32 x i32]** %batch to i8*, !dbg !2816
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %84) #31, !dbg !2816
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch, metadata !2818, metadata !DIExpression()), !dbg !2819
  %85 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !2820
  store [32 x i32]* %85, [32 x i32]** %batch, align 8, !dbg !2819
  br label %VITIS_LOOP_276_5, !dbg !2816

VITIS_LOOP_276_5:                                 ; preds = %for.body54
  %86 = bitcast [32 x i32]** %__range6 to i8*, !dbg !2821
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %86) #31, !dbg !2821
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6, metadata !2823, metadata !DIExpression()), !dbg !2824
  %87 = load [32 x i32]*, [32 x i32]** %batch, align 8, !dbg !2821
  store [32 x i32]* %87, [32 x i32]** %__range6, align 8, !dbg !2821
  %88 = bitcast i32** %__begin6 to i8*, !dbg !2825
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %88) #31, !dbg !2825
  call void @llvm.dbg.declare(metadata i32** %__begin6, metadata !2826, metadata !DIExpression()), !dbg !2824
  %89 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !2825
  %arraydecay55 = getelementptr inbounds [32 x i32], [32 x i32]* %89, i64 0, i64 0, !dbg !2825
  store i32* %arraydecay55, i32** %__begin6, align 8, !dbg !2825
  %90 = bitcast i32** %__end6 to i8*, !dbg !2825
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %90) #31, !dbg !2825
  call void @llvm.dbg.declare(metadata i32** %__end6, metadata !2827, metadata !DIExpression()), !dbg !2824
  %91 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !2825
  %arraydecay56 = getelementptr inbounds [32 x i32], [32 x i32]* %91, i64 0, i64 0, !dbg !2825
  %add.ptr57 = getelementptr inbounds i32, i32* %arraydecay56, i64 32, !dbg !2825
  store i32* %add.ptr57, i32** %__end6, align 8, !dbg !2825
  br label %for.cond58, !dbg !2825

for.cond58:                                       ; preds = %for.inc, %VITIS_LOOP_276_5
  %92 = load i32*, i32** %__begin6, align 8, !dbg !2825
  %93 = load i32*, i32** %__end6, align 8, !dbg !2825
  %cmp59 = icmp ne i32* %92, %93, !dbg !2825
  br i1 %cmp59, label %for.body61, label %for.cond.cleanup60, !dbg !2825

for.cond.cleanup60:                               ; preds = %for.cond58
  store i32 15, i32* %cleanup.dest.slot, align 4
  %94 = bitcast i32** %__end6 to i8*, !dbg !2825
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %94) #31, !dbg !2825
  %95 = bitcast i32** %__begin6 to i8*, !dbg !2825
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %95) #31, !dbg !2825
  %96 = bitcast [32 x i32]** %__range6 to i8*, !dbg !2825
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %96) #31, !dbg !2825
  br label %for.end

for.body61:                                       ; preds = %for.cond58
  %97 = bitcast i32** %word to i8*, !dbg !2828
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %97) #31, !dbg !2828
  call void @llvm.dbg.declare(metadata i32** %word, metadata !2830, metadata !DIExpression()), !dbg !2831
  %98 = load i32*, i32** %__begin6, align 8, !dbg !2832
  store i32* %98, i32** %word, align 8, !dbg !2831
  %99 = load i32*, i32** %word, align 8, !dbg !2833
  store i32 0, i32* %99, align 4, !dbg !2834
  %100 = bitcast i32** %word to i8*, !dbg !2835
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %100) #31, !dbg !2835
  br label %for.inc, !dbg !2836

for.inc:                                          ; preds = %for.body61
  %101 = load i32*, i32** %__begin6, align 8, !dbg !2825
  %incdec.ptr = getelementptr inbounds i32, i32* %101, i32 1, !dbg !2825
  store i32* %incdec.ptr, i32** %__begin6, align 8, !dbg !2825
  br label %for.cond58, !dbg !2825, !llvm.loop !2837

for.end:                                          ; preds = %for.cond.cleanup60
  %102 = bitcast [32 x i32]** %batch to i8*, !dbg !2839
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %102) #31, !dbg !2839
  br label %for.inc62, !dbg !2840

for.inc62:                                        ; preds = %for.end
  %103 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !2813
  %incdec.ptr63 = getelementptr inbounds [32 x i32], [32 x i32]* %103, i32 1, !dbg !2813
  store [32 x i32]* %incdec.ptr63, [32 x i32]** %__begin5, align 8, !dbg !2813
  br label %for.cond51, !dbg !2813, !llvm.loop !2841

for.end64:                                        ; preds = %for.cond.cleanup53
  %104 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !2843
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %104) #31, !dbg !2843
  br label %for.inc65, !dbg !2844

for.inc65:                                        ; preds = %for.end64
  %105 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !2801
  %incdec.ptr66 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %105, i32 1, !dbg !2801
  store [2 x [32 x i32]]* %incdec.ptr66, [2 x [32 x i32]]** %__begin4, align 8, !dbg !2801
  br label %for.cond44, !dbg !2801, !llvm.loop !2845

for.end67:                                        ; preds = %for.cond.cleanup46
  %106 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !2847
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %106) #31, !dbg !2847
  br label %for.inc68, !dbg !2848

for.inc68:                                        ; preds = %for.end67
  %107 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !2788
  %incdec.ptr69 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %107, i32 1, !dbg !2788
  store [16 x [2 x [32 x i32]]]* %incdec.ptr69, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !2788
  br label %for.cond37, !dbg !2788, !llvm.loop !2849

for.end70:                                        ; preds = %for.cond.cleanup39
  %108 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !2851
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %108) #31, !dbg !2851
  br label %for.inc71, !dbg !2852

for.inc71:                                        ; preds = %for.end70
  %109 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !2772
  %incdec.ptr72 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %109, i32 1, !dbg !2772
  store [3 x [16 x [2 x [32 x i32]]]]* %incdec.ptr72, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !2772
  br label %for.cond, !dbg !2772, !llvm.loop !2853

for.end73:                                        ; preds = %for.cond.cleanup
  br label %VITIS_LOOP_277_6, !dbg !2851

VITIS_LOOP_277_6:                                 ; preds = %for.end73
  %110 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274 to i8*, !dbg !2855
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %110) #31, !dbg !2855
  call void @llvm.dbg.declare(metadata [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, metadata !2857, metadata !DIExpression()), !dbg !2859
  %111 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2855
  %owners75 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %111, i32 0, i32 1, !dbg !2860
  %qkv_rope_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners75, i32 0, i32 2, !dbg !2861
  store [2 x [2 x [16 x [2 x [32 x i32]]]]]* %qkv_rope_rows, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !2855
  %112 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin276 to i8*, !dbg !2862
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %112) #31, !dbg !2862
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__begin276, metadata !2863, metadata !DIExpression()), !dbg !2859
  %113 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !2862
  %arraydecay77 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %113, i64 0, i64 0, !dbg !2862
  store [2 x [16 x [2 x [32 x i32]]]]* %arraydecay77, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !2862
  %114 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end278 to i8*, !dbg !2862
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %114) #31, !dbg !2862
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__end278, metadata !2867, metadata !DIExpression()), !dbg !2859
  %115 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !2862
  %arraydecay79 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %115, i64 0, i64 0, !dbg !2862
  %add.ptr80 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %arraydecay79, i64 2, !dbg !2862
  store [2 x [16 x [2 x [32 x i32]]]]* %add.ptr80, [2 x [16 x [2 x [32 x i32]]]]** %__end278, align 8, !dbg !2862
  br label %for.cond81, !dbg !2862

for.cond81:                                       ; preds = %for.inc142, %VITIS_LOOP_277_6
  %116 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !2862
  %117 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__end278, align 8, !dbg !2862
  %cmp82 = icmp ne [2 x [16 x [2 x [32 x i32]]]]* %116, %117, !dbg !2862
  br i1 %cmp82, label %for.body84, label %for.cond.cleanup83, !dbg !2862

for.cond.cleanup83:                               ; preds = %for.cond81
  store i32 18, i32* %cleanup.dest.slot, align 4
  %118 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end278 to i8*, !dbg !2862
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %118) #31, !dbg !2862
  %119 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin276 to i8*, !dbg !2862
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %119) #31, !dbg !2862
  %120 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274 to i8*, !dbg !2862
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %120) #31, !dbg !2862
  br label %for.end144

for.body84:                                       ; preds = %for.cond81
  %121 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard85 to i8*, !dbg !2868
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %121) #31, !dbg !2868
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %shard85, metadata !2870, metadata !DIExpression()), !dbg !2872
  %122 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !2873
  store [2 x [16 x [2 x [32 x i32]]]]* %122, [2 x [16 x [2 x [32 x i32]]]]** %shard85, align 8, !dbg !2872
  br label %VITIS_LOOP_278_7, !dbg !2868

VITIS_LOOP_278_7:                                 ; preds = %for.body84
  %123 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range386 to i8*, !dbg !2874
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %123) #31, !dbg !2874
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__range386, metadata !2876, metadata !DIExpression()), !dbg !2877
  %124 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %shard85, align 8, !dbg !2874
  store [2 x [16 x [2 x [32 x i32]]]]* %124, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !2874
  %125 = bitcast [16 x [2 x [32 x i32]]]** %__begin387 to i8*, !dbg !2878
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %125) #31, !dbg !2878
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin387, metadata !2879, metadata !DIExpression()), !dbg !2877
  %126 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !2878
  %arraydecay88 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %126, i64 0, i64 0, !dbg !2878
  store [16 x [2 x [32 x i32]]]* %arraydecay88, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !2878
  %127 = bitcast [16 x [2 x [32 x i32]]]** %__end389 to i8*, !dbg !2878
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %127) #31, !dbg !2878
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end389, metadata !2880, metadata !DIExpression()), !dbg !2877
  %128 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !2878
  %arraydecay90 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %128, i64 0, i64 0, !dbg !2878
  %add.ptr91 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay90, i64 2, !dbg !2878
  store [16 x [2 x [32 x i32]]]* %add.ptr91, [16 x [2 x [32 x i32]]]** %__end389, align 8, !dbg !2878
  br label %for.cond92, !dbg !2878

for.cond92:                                       ; preds = %for.inc139, %VITIS_LOOP_278_7
  %129 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !2878
  %130 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end389, align 8, !dbg !2878
  %cmp93 = icmp ne [16 x [2 x [32 x i32]]]* %129, %130, !dbg !2878
  br i1 %cmp93, label %for.body95, label %for.cond.cleanup94, !dbg !2878

for.cond.cleanup94:                               ; preds = %for.cond92
  store i32 21, i32* %cleanup.dest.slot, align 4
  %131 = bitcast [16 x [2 x [32 x i32]]]** %__end389 to i8*, !dbg !2878
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %131) #31, !dbg !2878
  %132 = bitcast [16 x [2 x [32 x i32]]]** %__begin387 to i8*, !dbg !2878
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %132) #31, !dbg !2878
  %133 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range386 to i8*, !dbg !2878
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %133) #31, !dbg !2878
  br label %for.end141

for.body95:                                       ; preds = %for.cond92
  %134 = bitcast [16 x [2 x [32 x i32]]]** %plane96 to i8*, !dbg !2881
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %134) #31, !dbg !2881
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane96, metadata !2883, metadata !DIExpression()), !dbg !2884
  %135 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !2885
  store [16 x [2 x [32 x i32]]]* %135, [16 x [2 x [32 x i32]]]** %plane96, align 8, !dbg !2884
  br label %VITIS_LOOP_279_8, !dbg !2881

VITIS_LOOP_279_8:                                 ; preds = %for.body95
  %136 = bitcast [16 x [2 x [32 x i32]]]** %__range497 to i8*, !dbg !2886
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %136) #31, !dbg !2886
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range497, metadata !2888, metadata !DIExpression()), !dbg !2889
  %137 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane96, align 8, !dbg !2886
  store [16 x [2 x [32 x i32]]]* %137, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !2886
  %138 = bitcast [2 x [32 x i32]]** %__begin498 to i8*, !dbg !2890
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %138) #31, !dbg !2890
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin498, metadata !2891, metadata !DIExpression()), !dbg !2889
  %139 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !2890
  %arraydecay99 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %139, i64 0, i64 0, !dbg !2890
  store [2 x [32 x i32]]* %arraydecay99, [2 x [32 x i32]]** %__begin498, align 8, !dbg !2890
  %140 = bitcast [2 x [32 x i32]]** %__end4100 to i8*, !dbg !2890
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %140) #31, !dbg !2890
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4100, metadata !2892, metadata !DIExpression()), !dbg !2889
  %141 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !2890
  %arraydecay101 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %141, i64 0, i64 0, !dbg !2890
  %add.ptr102 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay101, i64 16, !dbg !2890
  store [2 x [32 x i32]]* %add.ptr102, [2 x [32 x i32]]** %__end4100, align 8, !dbg !2890
  br label %for.cond103, !dbg !2890

for.cond103:                                      ; preds = %for.inc136, %VITIS_LOOP_279_8
  %142 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !2890
  %143 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4100, align 8, !dbg !2890
  %cmp104 = icmp ne [2 x [32 x i32]]* %142, %143, !dbg !2890
  br i1 %cmp104, label %for.body106, label %for.cond.cleanup105, !dbg !2890

for.cond.cleanup105:                              ; preds = %for.cond103
  store i32 24, i32* %cleanup.dest.slot, align 4
  %144 = bitcast [2 x [32 x i32]]** %__end4100 to i8*, !dbg !2890
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %144) #31, !dbg !2890
  %145 = bitcast [2 x [32 x i32]]** %__begin498 to i8*, !dbg !2890
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %145) #31, !dbg !2890
  %146 = bitcast [16 x [2 x [32 x i32]]]** %__range497 to i8*, !dbg !2890
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %146) #31, !dbg !2890
  br label %for.end138

for.body106:                                      ; preds = %for.cond103
  %147 = bitcast [2 x [32 x i32]]** %head107 to i8*, !dbg !2893
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %147) #31, !dbg !2893
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head107, metadata !2895, metadata !DIExpression()), !dbg !2896
  %148 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !2897
  store [2 x [32 x i32]]* %148, [2 x [32 x i32]]** %head107, align 8, !dbg !2896
  br label %VITIS_LOOP_280_9, !dbg !2893

VITIS_LOOP_280_9:                                 ; preds = %for.body106
  %149 = bitcast [2 x [32 x i32]]** %__range5108 to i8*, !dbg !2898
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %149) #31, !dbg !2898
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5108, metadata !2900, metadata !DIExpression()), !dbg !2901
  %150 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head107, align 8, !dbg !2898
  store [2 x [32 x i32]]* %150, [2 x [32 x i32]]** %__range5108, align 8, !dbg !2898
  %151 = bitcast [32 x i32]** %__begin5109 to i8*, !dbg !2902
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %151) #31, !dbg !2902
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5109, metadata !2903, metadata !DIExpression()), !dbg !2901
  %152 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5108, align 8, !dbg !2902
  %arraydecay110 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %152, i64 0, i64 0, !dbg !2902
  store [32 x i32]* %arraydecay110, [32 x i32]** %__begin5109, align 8, !dbg !2902
  %153 = bitcast [32 x i32]** %__end5111 to i8*, !dbg !2902
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %153) #31, !dbg !2902
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5111, metadata !2904, metadata !DIExpression()), !dbg !2901
  %154 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5108, align 8, !dbg !2902
  %arraydecay112 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %154, i64 0, i64 0, !dbg !2902
  %add.ptr113 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay112, i64 2, !dbg !2902
  store [32 x i32]* %add.ptr113, [32 x i32]** %__end5111, align 8, !dbg !2902
  br label %for.cond114, !dbg !2902

for.cond114:                                      ; preds = %for.inc133, %VITIS_LOOP_280_9
  %155 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !2902
  %156 = load [32 x i32]*, [32 x i32]** %__end5111, align 8, !dbg !2902
  %cmp115 = icmp ne [32 x i32]* %155, %156, !dbg !2902
  br i1 %cmp115, label %for.body117, label %for.cond.cleanup116, !dbg !2902

for.cond.cleanup116:                              ; preds = %for.cond114
  store i32 27, i32* %cleanup.dest.slot, align 4
  %157 = bitcast [32 x i32]** %__end5111 to i8*, !dbg !2902
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %157) #31, !dbg !2902
  %158 = bitcast [32 x i32]** %__begin5109 to i8*, !dbg !2902
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %158) #31, !dbg !2902
  %159 = bitcast [2 x [32 x i32]]** %__range5108 to i8*, !dbg !2902
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %159) #31, !dbg !2902
  br label %for.end135

for.body117:                                      ; preds = %for.cond114
  %160 = bitcast [32 x i32]** %batch118 to i8*, !dbg !2905
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %160) #31, !dbg !2905
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch118, metadata !2907, metadata !DIExpression()), !dbg !2908
  %161 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !2909
  store [32 x i32]* %161, [32 x i32]** %batch118, align 8, !dbg !2908
  br label %VITIS_LOOP_281_10, !dbg !2905

VITIS_LOOP_281_10:                                ; preds = %for.body117
  %162 = bitcast [32 x i32]** %__range6119 to i8*, !dbg !2910
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %162) #31, !dbg !2910
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6119, metadata !2912, metadata !DIExpression()), !dbg !2913
  %163 = load [32 x i32]*, [32 x i32]** %batch118, align 8, !dbg !2910
  store [32 x i32]* %163, [32 x i32]** %__range6119, align 8, !dbg !2910
  %164 = bitcast i32** %__begin6120 to i8*, !dbg !2914
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %164) #31, !dbg !2914
  call void @llvm.dbg.declare(metadata i32** %__begin6120, metadata !2915, metadata !DIExpression()), !dbg !2913
  %165 = load [32 x i32]*, [32 x i32]** %__range6119, align 8, !dbg !2914
  %arraydecay121 = getelementptr inbounds [32 x i32], [32 x i32]* %165, i64 0, i64 0, !dbg !2914
  store i32* %arraydecay121, i32** %__begin6120, align 8, !dbg !2914
  %166 = bitcast i32** %__end6122 to i8*, !dbg !2914
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %166) #31, !dbg !2914
  call void @llvm.dbg.declare(metadata i32** %__end6122, metadata !2916, metadata !DIExpression()), !dbg !2913
  %167 = load [32 x i32]*, [32 x i32]** %__range6119, align 8, !dbg !2914
  %arraydecay123 = getelementptr inbounds [32 x i32], [32 x i32]* %167, i64 0, i64 0, !dbg !2914
  %add.ptr124 = getelementptr inbounds i32, i32* %arraydecay123, i64 32, !dbg !2914
  store i32* %add.ptr124, i32** %__end6122, align 8, !dbg !2914
  br label %for.cond125, !dbg !2914

for.cond125:                                      ; preds = %for.inc130, %VITIS_LOOP_281_10
  %168 = load i32*, i32** %__begin6120, align 8, !dbg !2914
  %169 = load i32*, i32** %__end6122, align 8, !dbg !2914
  %cmp126 = icmp ne i32* %168, %169, !dbg !2914
  br i1 %cmp126, label %for.body128, label %for.cond.cleanup127, !dbg !2914

for.cond.cleanup127:                              ; preds = %for.cond125
  store i32 30, i32* %cleanup.dest.slot, align 4
  %170 = bitcast i32** %__end6122 to i8*, !dbg !2914
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %170) #31, !dbg !2914
  %171 = bitcast i32** %__begin6120 to i8*, !dbg !2914
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %171) #31, !dbg !2914
  %172 = bitcast [32 x i32]** %__range6119 to i8*, !dbg !2914
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %172) #31, !dbg !2914
  br label %for.end132

for.body128:                                      ; preds = %for.cond125
  %173 = bitcast i32** %word129 to i8*, !dbg !2917
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %173) #31, !dbg !2917
  call void @llvm.dbg.declare(metadata i32** %word129, metadata !2919, metadata !DIExpression()), !dbg !2920
  %174 = load i32*, i32** %__begin6120, align 8, !dbg !2921
  store i32* %174, i32** %word129, align 8, !dbg !2920
  %175 = load i32*, i32** %word129, align 8, !dbg !2922
  store i32 0, i32* %175, align 4, !dbg !2923
  %176 = bitcast i32** %word129 to i8*, !dbg !2924
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %176) #31, !dbg !2924
  br label %for.inc130, !dbg !2925

for.inc130:                                       ; preds = %for.body128
  %177 = load i32*, i32** %__begin6120, align 8, !dbg !2914
  %incdec.ptr131 = getelementptr inbounds i32, i32* %177, i32 1, !dbg !2914
  store i32* %incdec.ptr131, i32** %__begin6120, align 8, !dbg !2914
  br label %for.cond125, !dbg !2914, !llvm.loop !2926

for.end132:                                       ; preds = %for.cond.cleanup127
  %178 = bitcast [32 x i32]** %batch118 to i8*, !dbg !2928
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %178) #31, !dbg !2928
  br label %for.inc133, !dbg !2929

for.inc133:                                       ; preds = %for.end132
  %179 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !2902
  %incdec.ptr134 = getelementptr inbounds [32 x i32], [32 x i32]* %179, i32 1, !dbg !2902
  store [32 x i32]* %incdec.ptr134, [32 x i32]** %__begin5109, align 8, !dbg !2902
  br label %for.cond114, !dbg !2902, !llvm.loop !2930

for.end135:                                       ; preds = %for.cond.cleanup116
  %180 = bitcast [2 x [32 x i32]]** %head107 to i8*, !dbg !2932
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %180) #31, !dbg !2932
  br label %for.inc136, !dbg !2933

for.inc136:                                       ; preds = %for.end135
  %181 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !2890
  %incdec.ptr137 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %181, i32 1, !dbg !2890
  store [2 x [32 x i32]]* %incdec.ptr137, [2 x [32 x i32]]** %__begin498, align 8, !dbg !2890
  br label %for.cond103, !dbg !2890, !llvm.loop !2934

for.end138:                                       ; preds = %for.cond.cleanup105
  %182 = bitcast [16 x [2 x [32 x i32]]]** %plane96 to i8*, !dbg !2936
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %182) #31, !dbg !2936
  br label %for.inc139, !dbg !2937

for.inc139:                                       ; preds = %for.end138
  %183 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !2878
  %incdec.ptr140 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %183, i32 1, !dbg !2878
  store [16 x [2 x [32 x i32]]]* %incdec.ptr140, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !2878
  br label %for.cond92, !dbg !2878, !llvm.loop !2938

for.end141:                                       ; preds = %for.cond.cleanup94
  %184 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard85 to i8*, !dbg !2940
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %184) #31, !dbg !2940
  br label %for.inc142, !dbg !2941

for.inc142:                                       ; preds = %for.end141
  %185 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !2862
  %incdec.ptr143 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %185, i32 1, !dbg !2862
  store [2 x [16 x [2 x [32 x i32]]]]* %incdec.ptr143, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !2862
  br label %for.cond81, !dbg !2862, !llvm.loop !2942

for.end144:                                       ; preds = %for.cond.cleanup83
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !2944
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !2945

cleanup:                                          ; preds = %for.end144, %if.then17
  %186 = bitcast i32* %second to i8*, !dbg !2946
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %186) #31, !dbg !2946
  %187 = bitcast i32* %first to i8*, !dbg !2946
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %187) #31, !dbg !2946
  br label %return

return:                                           ; preds = %cleanup, %if.then
  ret void, !dbg !2946
}

; Function Attrs: nounwind
define internal zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %s) #23 !dbg !2947 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !2950, metadata !DIExpression()), !dbg !2951
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %s, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, metadata !2952, metadata !DIExpression()), !dbg !2953
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2954
  %1 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2955
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %1, i64 0, i64 0, !dbg !2955
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx), !dbg !2956
  br i1 %call, label %land.lhs.true, label %land.end112, !dbg !2957

land.lhs.true:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !2958
  %3 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2959
  %arrayidx1 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %3, i64 0, i64 1, !dbg !2959
  %call2 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %2, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx1), !dbg !2960
  br i1 %call2, label %land.lhs.true3, label %land.end112, !dbg !2961

land.lhs.true3:                                   ; preds = %land.lhs.true
  %4 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2962
  %arrayidx4 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %4, i64 0, i64 0, !dbg !2962
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx4, i32 0, i32 0, !dbg !2963
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !2964
  %5 = load i8, i8* %id, align 4, !dbg !2964
  %cmp = icmp eq i8 %5, 5, !dbg !2965
  br i1 %cmp, label %land.lhs.true5, label %land.end112, !dbg !2966

land.lhs.true5:                                   ; preds = %land.lhs.true3
  %6 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2967
  %arrayidx6 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %6, i64 0, i64 1, !dbg !2967
  %ref7 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx6, i32 0, i32 0, !dbg !2968
  %id8 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref7, i32 0, i32 0, !dbg !2969
  %7 = load i8, i8* %id8, align 4, !dbg !2969
  %cmp9 = icmp eq i8 %7, 5, !dbg !2970
  br i1 %cmp9, label %land.lhs.true10, label %land.end112, !dbg !2971

land.lhs.true10:                                  ; preds = %land.lhs.true5
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2972
  %arrayidx11 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !2972
  %ref12 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx11, i32 0, i32 0, !dbg !2973
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref12, i32 0, i32 1, !dbg !2974
  %9 = load i8, i8* %bank, align 1, !dbg !2974
  %conv = zext i8 %9 to i32, !dbg !2972
  %cmp13 = icmp eq i32 %conv, 0, !dbg !2975
  br i1 %cmp13, label %land.lhs.true14, label %land.end112, !dbg !2976

land.lhs.true14:                                  ; preds = %land.lhs.true10
  %10 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2977
  %arrayidx15 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %10, i64 0, i64 1, !dbg !2977
  %ref16 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx15, i32 0, i32 0, !dbg !2978
  %bank17 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref16, i32 0, i32 1, !dbg !2979
  %11 = load i8, i8* %bank17, align 1, !dbg !2979
  %conv18 = zext i8 %11 to i32, !dbg !2977
  %cmp19 = icmp eq i32 %conv18, 1, !dbg !2980
  br i1 %cmp19, label %land.lhs.true20, label %land.end112, !dbg !2981

land.lhs.true20:                                  ; preds = %land.lhs.true14
  %12 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2982
  %arrayidx21 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %12, i64 0, i64 0, !dbg !2982
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx21, i32 0, i32 1, !dbg !2983
  %13 = load i8, i8* %region, align 4, !dbg !2983
  %conv22 = zext i8 %13 to i32, !dbg !2982
  %cmp23 = icmp eq i32 %conv22, 0, !dbg !2984
  br i1 %cmp23, label %land.lhs.true24, label %land.end112, !dbg !2985

land.lhs.true24:                                  ; preds = %land.lhs.true20
  %14 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2986
  %arrayidx25 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %14, i64 0, i64 1, !dbg !2986
  %region26 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx25, i32 0, i32 1, !dbg !2987
  %15 = load i8, i8* %region26, align 4, !dbg !2987
  %conv27 = zext i8 %15 to i32, !dbg !2986
  %cmp28 = icmp eq i32 %conv27, 0, !dbg !2988
  br i1 %cmp28, label %land.lhs.true29, label %land.end112, !dbg !2989

land.lhs.true29:                                  ; preds = %land.lhs.true24
  %16 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2990
  %arrayidx30 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %16, i64 0, i64 0, !dbg !2990
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx30, i32 0, i32 4, !dbg !2991
  %17 = load i8, i8* %batch, align 1, !dbg !2991
  %conv31 = zext i8 %17 to i32, !dbg !2990
  %cmp32 = icmp eq i32 %conv31, 255, !dbg !2992
  br i1 %cmp32, label %land.lhs.true33, label %land.end112, !dbg !2993

land.lhs.true33:                                  ; preds = %land.lhs.true29
  %18 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2994
  %arrayidx34 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %18, i64 0, i64 1, !dbg !2994
  %batch35 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx34, i32 0, i32 4, !dbg !2995
  %19 = load i8, i8* %batch35, align 1, !dbg !2995
  %conv36 = zext i8 %19 to i32, !dbg !2994
  %cmp37 = icmp eq i32 %conv36, 255, !dbg !2996
  br i1 %cmp37, label %land.lhs.true38, label %land.end112, !dbg !2997

land.lhs.true38:                                  ; preds = %land.lhs.true33
  %20 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !2998
  %arrayidx39 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %20, i64 0, i64 0, !dbg !2998
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx39, i32 0, i32 5, !dbg !2999
  %21 = load i8, i8* %row_space, align 4, !dbg !2999
  %cmp40 = icmp eq i8 %21, 0, !dbg !3000
  br i1 %cmp40, label %land.lhs.true41, label %land.end112, !dbg !3001

land.lhs.true41:                                  ; preds = %land.lhs.true38
  %22 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3002
  %arrayidx42 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %22, i64 0, i64 1, !dbg !3002
  %row_space43 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx42, i32 0, i32 5, !dbg !3003
  %23 = load i8, i8* %row_space43, align 4, !dbg !3003
  %cmp44 = icmp eq i8 %23, 0, !dbg !3004
  br i1 %cmp44, label %land.lhs.true45, label %land.end112, !dbg !3005

land.lhs.true45:                                  ; preds = %land.lhs.true41
  %24 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3006
  %arrayidx46 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %24, i64 0, i64 0, !dbg !3006
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx46, i32 0, i32 6, !dbg !3007
  %25 = load i16, i16* %row0, align 2, !dbg !3007
  %conv47 = zext i16 %25 to i32, !dbg !3006
  %cmp48 = icmp eq i32 %conv47, 0, !dbg !3008
  br i1 %cmp48, label %land.lhs.true49, label %land.end112, !dbg !3009

land.lhs.true49:                                  ; preds = %land.lhs.true45
  %26 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3010
  %arrayidx50 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %26, i64 0, i64 1, !dbg !3010
  %row051 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx50, i32 0, i32 6, !dbg !3011
  %27 = load i16, i16* %row051, align 2, !dbg !3011
  %conv52 = zext i16 %27 to i32, !dbg !3010
  %cmp53 = icmp eq i32 %conv52, 0, !dbg !3012
  br i1 %cmp53, label %land.lhs.true54, label %land.end112, !dbg !3013

land.lhs.true54:                                  ; preds = %land.lhs.true49
  %28 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3014
  %arrayidx55 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %28, i64 0, i64 0, !dbg !3014
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx55, i32 0, i32 7, !dbg !3015
  %29 = load i16, i16* %rows, align 4, !dbg !3015
  %conv56 = zext i16 %29 to i32, !dbg !3014
  %30 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3016
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %30, i32 0, i32 0, !dbg !3017
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !3018
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 3, !dbg !3019
  %31 = load i16, i16* %S, align 2, !dbg !3019
  %conv57 = zext i16 %31 to i32, !dbg !3016
  %cmp58 = icmp eq i32 %conv56, %conv57, !dbg !3020
  br i1 %cmp58, label %land.lhs.true59, label %land.end112, !dbg !3021

land.lhs.true59:                                  ; preds = %land.lhs.true54
  %32 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3022
  %arrayidx60 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %32, i64 0, i64 1, !dbg !3022
  %rows61 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx60, i32 0, i32 7, !dbg !3023
  %33 = load i16, i16* %rows61, align 4, !dbg !3023
  %conv62 = zext i16 %33 to i32, !dbg !3022
  %34 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3024
  %inputs63 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %34, i32 0, i32 0, !dbg !3025
  %identity64 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs63, i32 0, i32 0, !dbg !3026
  %S65 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity64, i32 0, i32 3, !dbg !3027
  %35 = load i16, i16* %S65, align 2, !dbg !3027
  %conv66 = zext i16 %35 to i32, !dbg !3024
  %cmp67 = icmp eq i32 %conv62, %conv66, !dbg !3028
  br i1 %cmp67, label %land.lhs.true68, label %land.end112, !dbg !3029

land.lhs.true68:                                  ; preds = %land.lhs.true59
  %36 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3030
  %arrayidx69 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %36, i64 0, i64 0, !dbg !3030
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx69, i32 0, i32 2, !dbg !3031
  %37 = load i8, i8* %stage, align 1, !dbg !3031
  %conv70 = zext i8 %37 to i32, !dbg !3030
  %38 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3032
  %arrayidx71 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %38, i64 0, i64 1, !dbg !3032
  %stage72 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx71, i32 0, i32 2, !dbg !3033
  %39 = load i8, i8* %stage72, align 1, !dbg !3033
  %conv73 = zext i8 %39 to i32, !dbg !3032
  %cmp74 = icmp eq i32 %conv70, %conv73, !dbg !3034
  br i1 %cmp74, label %land.lhs.true75, label %land.end112, !dbg !3035

land.lhs.true75:                                  ; preds = %land.lhs.true68
  %40 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3036
  %arrayidx76 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %40, i64 0, i64 0, !dbg !3036
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx76, i32 0, i32 3, !dbg !3037
  %41 = load i8, i8* %layer, align 2, !dbg !3037
  %conv77 = zext i8 %41 to i32, !dbg !3036
  %42 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3038
  %arrayidx78 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %42, i64 0, i64 1, !dbg !3038
  %layer79 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx78, i32 0, i32 3, !dbg !3039
  %43 = load i8, i8* %layer79, align 2, !dbg !3039
  %conv80 = zext i8 %43 to i32, !dbg !3038
  %cmp81 = icmp eq i32 %conv77, %conv80, !dbg !3040
  br i1 %cmp81, label %land.lhs.true82, label %land.end112, !dbg !3041

land.lhs.true82:                                  ; preds = %land.lhs.true75
  %44 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3042
  %arrayidx83 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %44, i64 0, i64 0, !dbg !3042
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx83, i32 0, i32 8, !dbg !3043
  %45 = load i16, i16* %width, align 2, !dbg !3043
  %conv84 = zext i16 %45 to i32, !dbg !3042
  %cmp85 = icmp eq i32 %conv84, 64, !dbg !3044
  br i1 %cmp85, label %land.lhs.true86, label %land.end112, !dbg !3045

land.lhs.true86:                                  ; preds = %land.lhs.true82
  %46 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3046
  %arrayidx87 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %46, i64 0, i64 1, !dbg !3046
  %width88 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx87, i32 0, i32 8, !dbg !3047
  %47 = load i16, i16* %width88, align 2, !dbg !3047
  %conv89 = zext i16 %47 to i32, !dbg !3046
  %cmp90 = icmp eq i32 %conv89, 64, !dbg !3048
  br i1 %cmp90, label %land.lhs.true91, label %land.end112, !dbg !3049

land.lhs.true91:                                  ; preds = %land.lhs.true86
  %48 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3050
  %arrayidx92 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %48, i64 0, i64 0, !dbg !3050
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx92, i32 0, i32 9, !dbg !3051
  %49 = load i8, i8* %content, align 4, !dbg !3051
  %50 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3052
  %arrayidx93 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %50, i64 0, i64 1, !dbg !3052
  %content94 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx93, i32 0, i32 9, !dbg !3053
  %51 = load i8, i8* %content94, align 4, !dbg !3053
  %cmp95 = icmp eq i8 %49, %51, !dbg !3054
  br i1 %cmp95, label %land.rhs, label %land.end112, !dbg !3055

land.rhs:                                         ; preds = %land.lhs.true91
  %52 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3056
  %arrayidx96 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %52, i64 0, i64 0, !dbg !3056
  %stage97 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx96, i32 0, i32 2, !dbg !3057
  %53 = load i8, i8* %stage97, align 1, !dbg !3057
  %conv98 = zext i8 %53 to i32, !dbg !3056
  %cmp99 = icmp eq i32 %conv98, 2, !dbg !3058
  br i1 %cmp99, label %land.lhs.true100, label %lor.rhs, !dbg !3059

land.lhs.true100:                                 ; preds = %land.rhs
  %54 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3060
  %arrayidx101 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %54, i64 0, i64 0, !dbg !3060
  %content102 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx101, i32 0, i32 9, !dbg !3061
  %55 = load i8, i8* %content102, align 4, !dbg !3061
  %cmp103 = icmp eq i8 %55, 2, !dbg !3062
  br i1 %cmp103, label %lor.end, label %lor.rhs, !dbg !3063

lor.rhs:                                          ; preds = %land.lhs.true100, %land.rhs
  %56 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3064
  %arrayidx104 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %56, i64 0, i64 0, !dbg !3064
  %stage105 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx104, i32 0, i32 2, !dbg !3065
  %57 = load i8, i8* %stage105, align 1, !dbg !3065
  %conv106 = zext i8 %57 to i32, !dbg !3064
  %cmp107 = icmp eq i32 %conv106, 4, !dbg !3066
  br i1 %cmp107, label %land.rhs108, label %land.end, !dbg !3067

land.rhs108:                                      ; preds = %lor.rhs
  %58 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !3068
  %arrayidx109 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %58, i64 0, i64 0, !dbg !3068
  %content110 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx109, i32 0, i32 9, !dbg !3069
  %59 = load i8, i8* %content110, align 4, !dbg !3069
  %cmp111 = icmp eq i8 %59, 3, !dbg !3070
  br label %land.end

land.end:                                         ; preds = %land.rhs108, %lor.rhs
  %60 = phi i1 [ false, %lor.rhs ], [ %cmp111, %land.rhs108 ], !dbg !3071
  br label %lor.end, !dbg !3063

lor.end:                                          ; preds = %land.end, %land.lhs.true100
  %61 = phi i1 [ true, %land.lhs.true100 ], [ %60, %land.end ]
  br label %land.end112

land.end112:                                      ; preds = %lor.end, %land.lhs.true91, %land.lhs.true86, %land.lhs.true82, %land.lhs.true75, %land.lhs.true68, %land.lhs.true59, %land.lhs.true54, %land.lhs.true49, %land.lhs.true45, %land.lhs.true41, %land.lhs.true38, %land.lhs.true33, %land.lhs.true29, %land.lhs.true24, %land.lhs.true20, %land.lhs.true14, %land.lhs.true10, %land.lhs.true5, %land.lhs.true3, %land.lhs.true, %entry
  %62 = phi i1 [ false, %land.lhs.true91 ], [ false, %land.lhs.true86 ], [ false, %land.lhs.true82 ], [ false, %land.lhs.true75 ], [ false, %land.lhs.true68 ], [ false, %land.lhs.true59 ], [ false, %land.lhs.true54 ], [ false, %land.lhs.true49 ], [ false, %land.lhs.true45 ], [ false, %land.lhs.true41 ], [ false, %land.lhs.true38 ], [ false, %land.lhs.true33 ], [ false, %land.lhs.true29 ], [ false, %land.lhs.true24 ], [ false, %land.lhs.true20 ], [ false, %land.lhs.true14 ], [ false, %land.lhs.true10 ], [ false, %land.lhs.true5 ], [ false, %land.lhs.true3 ], [ false, %land.lhs.true ], [ false, %entry ], [ %61, %lor.end ], !dbg !3071
  ret i1 %62, !dbg !3072
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %ref, i8 zeroext %region) #24 !dbg !3073 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %region.addr = alloca i8, align 1
  %index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %r = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %agg.tmp1 = alloca %"struct.laya::BufferRef", align 4
  %agg.tmp3 = alloca %"struct.laya::BufferRef", align 4
  %agg.tmp5 = alloca %"struct.laya::BufferRef", align 4
  %agg.tmp6 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp = alloca %"struct.laya::BufferRef", align 4
  %__range3 = alloca [3 x i1]*, align 8
  %__begin3 = alloca i1*, align 8
  %__end3 = alloca i1*, align 8
  %v = alloca i1*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !3076, metadata !DIExpression()), !dbg !3077
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %ref, metadata !3078, metadata !DIExpression()), !dbg !3079
  store i8 %region, i8* %region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %region.addr, metadata !3080, metadata !DIExpression()), !dbg !3081
  %0 = bitcast i32* %index to i8*, !dbg !3082
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !3082
  call void @llvm.dbg.declare(metadata i32* %index, metadata !3083, metadata !DIExpression()), !dbg !3084
  %1 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3085
  %2 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !3086
  store %"struct.laya::BufferRef" %2, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !3086
  %3 = load i8, i8* %region.addr, align 1, !dbg !3087
  %call = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %1, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext %3), !dbg !3088
  store i32 %call, i32* %index, align 4, !dbg !3084
  %4 = load i32, i32* %index, align 4, !dbg !3089
  %cmp = icmp eq i32 %4, 32, !dbg !3091
  br i1 %cmp, label %if.then, label %if.end, !dbg !3092

if.then:                                          ; preds = %entry
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !3093
  %5 = load i8, i8* %id, align 4, !dbg !3093
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %5, i16 zeroext 9), !dbg !3094
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup27, !dbg !3095

if.end:                                           ; preds = %entry
  %6 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !3096
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %6) #31, !dbg !3096
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r, metadata !3097, metadata !DIExpression()), !dbg !3098
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3099
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %7, i32 0, i32 1, !dbg !3100
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !3101
  %8 = load i32, i32* %index, align 4, !dbg !3102
  %idxprom = zext i32 %8 to i64, !dbg !3099
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !3099
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3098
  %9 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3103
  %ref2 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %9, i32 0, i32 1, !dbg !3105
  %10 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref2, align 8, !dbg !3103
  store %"struct.laya::BufferRef" %10, %"struct.laya::BufferRef"* %agg.tmp1, align 4, !dbg !3103
  %11 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !3106
  store %"struct.laya::BufferRef" %11, %"struct.laya::BufferRef"* %agg.tmp3, align 4, !dbg !3106
  %call4 = call zeroext i1 @_ZN4layaneENS_9BufferRefES0_(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp1, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp3), !dbg !3107
  br i1 %call4, label %land.lhs.true, label %if.end10, !dbg !3108

land.lhs.true:                                    ; preds = %if.end
  %12 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3109
  %lease_old_ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %12, i32 0, i32 2, !dbg !3110
  %13 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %lease_old_ref, align 8, !dbg !3109
  store %"struct.laya::BufferRef" %13, %"struct.laya::BufferRef"* %agg.tmp5, align 4, !dbg !3109
  %14 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !3111
  store %"struct.laya::BufferRef" %14, %"struct.laya::BufferRef"* %agg.tmp6, align 4, !dbg !3111
  %call7 = call zeroext i1 @_ZN4layaneENS_9BufferRefES0_(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp5, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp6), !dbg !3112
  br i1 %call7, label %if.then8, label %if.end10, !dbg !3113

if.then8:                                         ; preds = %land.lhs.true
  %id9 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !3114
  %15 = load i8, i8* %id9, align 4, !dbg !3114
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %15, i16 zeroext 9), !dbg !3115
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3116

if.end10:                                         ; preds = %land.lhs.true, %if.end
  %16 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3117
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %16, i32 0, i32 13, !dbg !3119
  %17 = load i8, i8* %state, align 1, !dbg !3119
  %cmp11 = icmp eq i8 %17, 3, !dbg !3120
  br i1 %cmp11, label %if.then12, label %lor.lhs.false, !dbg !3121

lor.lhs.false:                                    ; preds = %if.end10
  %18 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3122
  %readers = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %18, i32 0, i32 14, !dbg !3123
  %19 = load i8, i8* %readers, align 2, !dbg !3123
  %tobool = icmp ne i8 %19, 0, !dbg !3122
  br i1 %tobool, label %if.then12, label %if.end14, !dbg !3124

if.then12:                                        ; preds = %lor.lhs.false, %if.end10
  %id13 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !3125
  %20 = load i8, i8* %id13, align 4, !dbg !3125
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i8 zeroext %20, i16 zeroext 9), !dbg !3126
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3127

if.end14:                                         ; preds = %lor.lhs.false
  %21 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3128
  %state15 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %21, i32 0, i32 13, !dbg !3129
  store i8 6, i8* %state15, align 1, !dbg !3130
  %22 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3131
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %22, i32 0, i32 17, !dbg !3132
  store i1 false, i1* %valid, align 4, !dbg !3133
  %23 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !3134
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %23) #31, !dbg !3134
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp), !dbg !3134
  %24 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3135
  %lease_old_ref16 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %24, i32 0, i32 2, !dbg !3136
  %25 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, align 4, !dbg !3137
  store %"struct.laya::BufferRef" %25, %"struct.laya::BufferRef"* %lease_old_ref16, align 8, !dbg !3137
  %26 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !3135
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %26) #31, !dbg !3135
  %27 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3138
  %ref17 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %27, i32 0, i32 1, !dbg !3140
  %id18 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref17, i32 0, i32 0, !dbg !3141
  %28 = load i8, i8* %id18, align 8, !dbg !3141
  %cmp19 = icmp eq i8 %28, 11, !dbg !3142
  br i1 %cmp19, label %if.then20, label %if.end24, !dbg !3143

if.then20:                                        ; preds = %if.end14
  br label %VITIS_LOOP_633_1, !dbg !3143

VITIS_LOOP_633_1:                                 ; preds = %if.then20
  %29 = bitcast [3 x i1]** %__range3 to i8*, !dbg !3144
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %29) #31, !dbg !3144
  call void @llvm.dbg.declare(metadata [3 x i1]** %__range3, metadata !3146, metadata !DIExpression()), !dbg !3147
  %30 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3144
  %owners21 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %30, i32 0, i32 1, !dbg !3148
  %type_valid = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners21, i32 0, i32 6, !dbg !3149
  store [3 x i1]* %type_valid, [3 x i1]** %__range3, align 8, !dbg !3144
  %31 = bitcast i1** %__begin3 to i8*, !dbg !3150
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %31) #31, !dbg !3150
  call void @llvm.dbg.declare(metadata i1** %__begin3, metadata !3151, metadata !DIExpression()), !dbg !3147
  %32 = load [3 x i1]*, [3 x i1]** %__range3, align 8, !dbg !3150
  %arraydecay = getelementptr inbounds [3 x i1], [3 x i1]* %32, i64 0, i64 0, !dbg !3150
  store i1* %arraydecay, i1** %__begin3, align 8, !dbg !3150
  %33 = bitcast i1** %__end3 to i8*, !dbg !3150
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %33) #31, !dbg !3150
  call void @llvm.dbg.declare(metadata i1** %__end3, metadata !3152, metadata !DIExpression()), !dbg !3147
  %34 = load [3 x i1]*, [3 x i1]** %__range3, align 8, !dbg !3150
  %arraydecay22 = getelementptr inbounds [3 x i1], [3 x i1]* %34, i64 0, i64 0, !dbg !3150
  %add.ptr = getelementptr inbounds i1, i1* %arraydecay22, i64 3, !dbg !3150
  store i1* %add.ptr, i1** %__end3, align 8, !dbg !3150
  br label %for.cond, !dbg !3150

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_633_1
  %35 = load i1*, i1** %__begin3, align 8, !dbg !3150
  %36 = load i1*, i1** %__end3, align 8, !dbg !3150
  %cmp23 = icmp ne i1* %35, %36, !dbg !3150
  br i1 %cmp23, label %for.body, label %for.cond.cleanup, !dbg !3150

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %37 = bitcast i1** %__end3 to i8*, !dbg !3150
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %37) #31, !dbg !3150
  %38 = bitcast i1** %__begin3 to i8*, !dbg !3150
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %38) #31, !dbg !3150
  %39 = bitcast [3 x i1]** %__range3 to i8*, !dbg !3150
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %39) #31, !dbg !3150
  br label %for.end

for.body:                                         ; preds = %for.cond
  %40 = bitcast i1** %v to i8*, !dbg !3153
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %40) #31, !dbg !3153
  call void @llvm.dbg.declare(metadata i1** %v, metadata !3155, metadata !DIExpression()), !dbg !3156
  %41 = load i1*, i1** %__begin3, align 8, !dbg !3157
  store i1* %41, i1** %v, align 8, !dbg !3156
  %42 = load i1*, i1** %v, align 8, !dbg !3158
  store i1 false, i1* %42, align 1, !dbg !3159
  %43 = bitcast i1** %v to i8*, !dbg !3160
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %43) #31, !dbg !3160
  br label %for.inc, !dbg !3161

for.inc:                                          ; preds = %for.body
  %44 = load i1*, i1** %__begin3, align 8, !dbg !3150
  %incdec.ptr = getelementptr inbounds i1, i1* %44, i32 1, !dbg !3150
  store i1* %incdec.ptr, i1** %__begin3, align 8, !dbg !3150
  br label %for.cond, !dbg !3150, !llvm.loop !3162

for.end:                                          ; preds = %for.cond.cleanup
  br label %if.end24, !dbg !3160

if.end24:                                         ; preds = %for.end, %if.end14
  %45 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3164
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %45, i32 0, i32 15, !dbg !3165
  %arraydecay25 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !3164
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay25), !dbg !3166
  %46 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3167
  %old_consumed_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %46, i32 0, i32 16, !dbg !3168
  %arraydecay26 = getelementptr inbounds [64 x i32], [64 x i32]* %old_consumed_rows, i64 0, i64 0, !dbg !3167
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay26), !dbg !3169
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !3170
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3171

cleanup:                                          ; preds = %if.end24, %if.then12, %if.then8
  %47 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !3172
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %47) #31, !dbg !3172
  br label %cleanup27

cleanup27:                                        ; preds = %cleanup, %if.then
  %48 = bitcast i32* %index to i8*, !dbg !3172
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %48) #31, !dbg !3172
  ret void, !dbg !3172
}

; Function Attrs: nounwind
define linkonce_odr dso_local zeroext i1 @_ZN4layaneENS_9BufferRefES0_(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %a, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %b) #20 comdat !dbg !3173 {
entry:
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %agg.tmp1 = alloca %"struct.laya::BufferRef", align 4
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %a, metadata !3176, metadata !DIExpression()), !dbg !3177
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %b, metadata !3178, metadata !DIExpression()), !dbg !3179
  %0 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, align 4, !dbg !3180
  store %"struct.laya::BufferRef" %0, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !3180
  %1 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, align 4, !dbg !3181
  store %"struct.laya::BufferRef" %1, %"struct.laya::BufferRef"* %agg.tmp1, align 4, !dbg !3181
  %call = call zeroext i1 @_ZN4layaeqENS_9BufferRefES0_(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp1), !dbg !3182
  %lnot = xor i1 %call, true, !dbg !3183
  ret i1 %lnot, !dbg !3184
}

; Function Attrs: nounwind
define linkonce_odr dso_local zeroext i1 @_ZN4layaeqENS_9BufferRefES0_(%"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %a, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %b) #20 comdat !dbg !3185 {
entry:
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %a, metadata !3186, metadata !DIExpression()), !dbg !3187
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %b, metadata !3188, metadata !DIExpression()), !dbg !3189
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 0, !dbg !3190
  %0 = load i8, i8* %id, align 4, !dbg !3190
  %id1 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 0, !dbg !3191
  %1 = load i8, i8* %id1, align 4, !dbg !3191
  %cmp = icmp eq i8 %0, %1, !dbg !3192
  br i1 %cmp, label %land.lhs.true, label %land.end, !dbg !3193

land.lhs.true:                                    ; preds = %entry
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 1, !dbg !3194
  %2 = load i8, i8* %bank, align 1, !dbg !3194
  %conv = zext i8 %2 to i32, !dbg !3195
  %bank2 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 1, !dbg !3196
  %3 = load i8, i8* %bank2, align 1, !dbg !3196
  %conv3 = zext i8 %3 to i32, !dbg !3197
  %cmp4 = icmp eq i32 %conv, %conv3, !dbg !3198
  br i1 %cmp4, label %land.rhs, label %land.end, !dbg !3199

land.rhs:                                         ; preds = %land.lhs.true
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a, i32 0, i32 2, !dbg !3200
  %4 = load i32, i32* %epoch, align 4, !dbg !3200
  %epoch5 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %b, i32 0, i32 2, !dbg !3201
  %5 = load i32, i32* %epoch5, align 4, !dbg !3201
  %cmp6 = icmp eq i32 %4, %5, !dbg !3202
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.lhs.true, %entry
  %6 = phi i1 [ false, %land.lhs.true ], [ false, %entry ], [ %cmp6, %land.rhs ], !dbg !3203
  ret i1 %6, !dbg !3204
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt) #25 !dbg !3205 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %i = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %r = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %a8_index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %numeric_ref = alloca %"struct.laya::BufferRef", align 4
  %a8 = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %a837 = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %high = alloca i32, align 4
  %ref.tmp = alloca %"struct.laya::BufferRef", align 4
  %i65 = alloca i32, align 4
  %r70 = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %ref.tmp77 = alloca %"struct.laya::BufferRef", align 4
  %__range2 = alloca [2 x [3 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range3 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range4 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin4 = alloca [2 x [32 x i32]]*, align 8
  %__end4 = alloca [2 x [32 x i32]]*, align 8
  %head = alloca [2 x [32 x i32]]*, align 8
  %__range5 = alloca [2 x [32 x i32]]*, align 8
  %__begin5 = alloca [32 x i32]*, align 8
  %__end5 = alloca [32 x i32]*, align 8
  %batch = alloca [32 x i32]*, align 8
  %__range6 = alloca [32 x i32]*, align 8
  %__begin6 = alloca i32*, align 8
  %__end6 = alloca i32*, align 8
  %word = alloca i32*, align 8
  %__range2147 = alloca [2 x [2 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin2149 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end2151 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard158 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range3159 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin3160 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end3162 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane169 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range4170 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin4171 = alloca [2 x [32 x i32]]*, align 8
  %__end4173 = alloca [2 x [32 x i32]]*, align 8
  %head180 = alloca [2 x [32 x i32]]*, align 8
  %__range5181 = alloca [2 x [32 x i32]]*, align 8
  %__begin5182 = alloca [32 x i32]*, align 8
  %__end5184 = alloca [32 x i32]*, align 8
  %batch191 = alloca [32 x i32]*, align 8
  %__range6192 = alloca [32 x i32]*, align 8
  %__begin6193 = alloca i32*, align 8
  %__end6195 = alloca i32*, align 8
  %word202 = alloca i32*, align 8
  %__range2233 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin2235 = alloca [2 x [32 x i32]]*, align 8
  %__end2237 = alloca [2 x [32 x i32]]*, align 8
  %head244 = alloca [2 x [32 x i32]]*, align 8
  %__range3245 = alloca [2 x [32 x i32]]*, align 8
  %__begin3246 = alloca [32 x i32]*, align 8
  %__end3248 = alloca [32 x i32]*, align 8
  %batch255 = alloca [32 x i32]*, align 8
  %__range4256 = alloca [32 x i32]*, align 8
  %__begin4257 = alloca i32*, align 8
  %__end4259 = alloca i32*, align 8
  %word266 = alloca i32*, align 8
  %b = alloca i32, align 4
  %__range2299 = alloca [3 x i1]*, align 8
  %__begin2301 = alloca i1*, align 8
  %__end2303 = alloca i1*, align 8
  %v = alloca i1*, align 8
  %ref.tmp316 = alloca %"struct.laya::full::FullWeightDescriptor", align 4
  %ref.tmp345 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp346 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp348 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp351 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp353 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp356 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp357 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp358 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp359 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp360 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp362 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp368 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %__range2375 = alloca [256 x i32]*, align 8
  %__begin2376 = alloca i32*, align 8
  %__end2378 = alloca i32*, align 8
  %count = alloca i32*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !3208, metadata !DIExpression()), !dbg !3209
  br label %VITIS_LOOP_747_1, !dbg !3210

VITIS_LOOP_747_1:                                 ; preds = %entry
  %0 = bitcast i32* %i to i8*, !dbg !3211
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #31, !dbg !3211
  call void @llvm.dbg.declare(metadata i32* %i, metadata !3213, metadata !DIExpression()), !dbg !3214
  store i32 0, i32* %i, align 4, !dbg !3214
  br label %for.cond, !dbg !3211

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_747_1
  %1 = load i32, i32* %i, align 4, !dbg !3215
  %cmp = icmp ult i32 %1, 32, !dbg !3217
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !3218

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup11, !dbg !3218

for.body:                                         ; preds = %for.cond
  %2 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !3219
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #31, !dbg !3219
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r, metadata !3221, metadata !DIExpression()), !dbg !3222
  %3 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3223
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %3, i32 0, i32 1, !dbg !3224
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !3225
  %4 = load i32, i32* %i, align 4, !dbg !3226
  %idxprom = zext i32 %4 to i64, !dbg !3223
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !3223
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3222
  %5 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3227
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %5, i32 0, i32 13, !dbg !3229
  %6 = load i8, i8* %state, align 1, !dbg !3229
  %cmp1 = icmp eq i8 %6, 1, !dbg !3230
  br i1 %cmp1, label %if.then, label %lor.lhs.false, !dbg !3231

lor.lhs.false:                                    ; preds = %for.body
  %7 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3232
  %state2 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %7, i32 0, i32 13, !dbg !3233
  %8 = load i8, i8* %state2, align 1, !dbg !3233
  %cmp3 = icmp eq i8 %8, 3, !dbg !3234
  br i1 %cmp3, label %if.then, label %lor.lhs.false4, !dbg !3235

lor.lhs.false4:                                   ; preds = %lor.lhs.false
  %9 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3236
  %state5 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %9, i32 0, i32 13, !dbg !3237
  %10 = load i8, i8* %state5, align 1, !dbg !3237
  %cmp6 = icmp eq i8 %10, 4, !dbg !3238
  br i1 %cmp6, label %if.then, label %lor.lhs.false7, !dbg !3239

lor.lhs.false7:                                   ; preds = %lor.lhs.false4
  %11 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3240
  %state8 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %11, i32 0, i32 13, !dbg !3241
  %12 = load i8, i8* %state8, align 1, !dbg !3241
  %cmp9 = icmp eq i8 %12, 5, !dbg !3242
  br i1 %cmp9, label %if.then, label %lor.lhs.false10, !dbg !3243

lor.lhs.false10:                                  ; preds = %lor.lhs.false7
  %13 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r, align 8, !dbg !3244
  %readers = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %13, i32 0, i32 14, !dbg !3245
  %14 = load i8, i8* %readers, align 2, !dbg !3245
  %tobool = icmp ne i8 %14, 0, !dbg !3244
  br i1 %tobool, label %if.then, label %if.end, !dbg !3246

if.then:                                          ; preds = %lor.lhs.false10, %lor.lhs.false7, %lor.lhs.false4, %lor.lhs.false, %for.body
  call void @_ZN4laya4full12_GLOBAL__N_18protocolEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i16 zeroext 4), !dbg !3247
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3248

if.end:                                           ; preds = %lor.lhs.false10
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !3249
  br label %cleanup, !dbg !3249

cleanup:                                          ; preds = %if.end, %if.then
  %15 = bitcast %"struct.laya::full::FullOwnerRecord"** %r to i8*, !dbg !3249
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %15) #31, !dbg !3249
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup11 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %for.inc, !dbg !3250

for.inc:                                          ; preds = %cleanup.cont
  %16 = load i32, i32* %i, align 4, !dbg !3251
  %inc = add i32 %16, 1, !dbg !3251
  store i32 %inc, i32* %i, align 4, !dbg !3251
  br label %for.cond, !dbg !3252, !llvm.loop !3253

cleanup11:                                        ; preds = %cleanup, %for.cond.cleanup
  %17 = bitcast i32* %i to i8*, !dbg !3252
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %17) #31, !dbg !3252
  %cleanup.dest12 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest12, label %unreachable [
    i32 3, label %for.end
    i32 1, label %return
  ]

for.end:                                          ; preds = %cleanup11
  %18 = bitcast i32* %a8_index to i8*, !dbg !3256
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %18) #31, !dbg !3256
  call void @llvm.dbg.declare(metadata i32* %a8_index, metadata !3257, metadata !DIExpression()), !dbg !3258
  %19 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3259
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 0, !dbg !3260
  store i8 34, i8* %id, align 4, !dbg !3260
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 1, !dbg !3260
  store i8 0, i8* %bank, align 1, !dbg !3260
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 2, !dbg !3260
  store i32 1, i32* %epoch, align 4, !dbg !3260
  %call = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %19, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext 0), !dbg !3261
  store i32 %call, i32* %a8_index, align 4, !dbg !3258
  %20 = bitcast %"struct.laya::BufferRef"* %numeric_ref to i8*, !dbg !3262
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %20) #31, !dbg !3262
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %numeric_ref, metadata !3263, metadata !DIExpression()), !dbg !3265
  %21 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3266
  %cache = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %21, i32 0, i32 2, !dbg !3267
  %activation_meta = getelementptr inbounds %"struct.laya::full::FullCache", %"struct.laya::full::FullCache"* %cache, i32 0, i32 1, !dbg !3268
  %ref = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %activation_meta, i32 0, i32 1, !dbg !3269
  %22 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 8, !dbg !3266
  store %"struct.laya::BufferRef" %22, %"struct.laya::BufferRef"* %numeric_ref, align 4, !dbg !3266
  %id13 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 0, !dbg !3270
  %23 = load i8, i8* %id13, align 4, !dbg !3270
  %cmp14 = icmp eq i8 %23, 34, !dbg !3272
  br i1 %cmp14, label %land.lhs.true, label %if.end34, !dbg !3273

land.lhs.true:                                    ; preds = %for.end
  %bank15 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 1, !dbg !3274
  %24 = load i8, i8* %bank15, align 1, !dbg !3274
  %conv = zext i8 %24 to i32, !dbg !3275
  %cmp16 = icmp eq i32 %conv, 0, !dbg !3276
  br i1 %cmp16, label %land.lhs.true17, label %if.end34, !dbg !3277

land.lhs.true17:                                  ; preds = %land.lhs.true
  %epoch18 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 2, !dbg !3278
  %25 = load i32, i32* %epoch18, align 4, !dbg !3278
  %tobool19 = icmp ne i32 %25, 0, !dbg !3279
  br i1 %tobool19, label %land.lhs.true20, label %if.end34, !dbg !3280

land.lhs.true20:                                  ; preds = %land.lhs.true17
  %26 = load i32, i32* %a8_index, align 4, !dbg !3281
  %cmp21 = icmp eq i32 %26, 32, !dbg !3282
  br i1 %cmp21, label %if.then22, label %if.end34, !dbg !3283

if.then22:                                        ; preds = %land.lhs.true20
  %27 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3284
  %call23 = call i32 @_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %27, i32 32), !dbg !3286
  store i32 %call23, i32* %a8_index, align 4, !dbg !3287
  %28 = load i32, i32* %a8_index, align 4, !dbg !3288
  %cmp24 = icmp eq i32 %28, 32, !dbg !3290
  br i1 %cmp24, label %if.then25, label %if.end26, !dbg !3291

if.then25:                                        ; preds = %if.then22
  call void @_ZN4laya4full12_GLOBAL__N_18protocolEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i16 zeroext 4), !dbg !3292
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup391, !dbg !3293

if.end26:                                         ; preds = %if.then22
  %29 = bitcast %"struct.laya::full::FullOwnerRecord"** %a8 to i8*, !dbg !3294
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %29) #31, !dbg !3294
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %a8, metadata !3295, metadata !DIExpression()), !dbg !3296
  %30 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3297
  %owners27 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %30, i32 0, i32 1, !dbg !3298
  %record28 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners27, i32 0, i32 0, !dbg !3299
  %31 = load i32, i32* %a8_index, align 4, !dbg !3300
  %idxprom29 = zext i32 %31 to i64, !dbg !3297
  %arrayidx30 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record28, i64 0, i64 %idxprom29, !dbg !3297
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx30, %"struct.laya::full::FullOwnerRecord"** %a8, align 8, !dbg !3296
  %32 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a8, align 8, !dbg !3301
  %ref31 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %32, i32 0, i32 1, !dbg !3302
  %33 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, align 4, !dbg !3303
  store %"struct.laya::BufferRef" %33, %"struct.laya::BufferRef"* %ref31, align 8, !dbg !3303
  %epoch32 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 2, !dbg !3304
  %34 = load i32, i32* %epoch32, align 4, !dbg !3304
  %35 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a8, align 8, !dbg !3305
  %max_claimed_epoch = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %35, i32 0, i32 3, !dbg !3306
  store i32 %34, i32* %max_claimed_epoch, align 8, !dbg !3307
  %36 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a8, align 8, !dbg !3308
  %state33 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %36, i32 0, i32 13, !dbg !3309
  store i8 6, i8* %state33, align 1, !dbg !3310
  %37 = bitcast %"struct.laya::full::FullOwnerRecord"** %a8 to i8*, !dbg !3311
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %37) #31, !dbg !3311
  br label %if.end34, !dbg !3312

if.end34:                                         ; preds = %if.end26, %land.lhs.true20, %land.lhs.true17, %land.lhs.true, %for.end
  %38 = load i32, i32* %a8_index, align 4, !dbg !3313
  %cmp35 = icmp ne i32 %38, 32, !dbg !3315
  br i1 %cmp35, label %if.then36, label %if.end64, !dbg !3316

if.then36:                                        ; preds = %if.end34
  %39 = bitcast %"struct.laya::full::FullOwnerRecord"** %a837 to i8*, !dbg !3317
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %39) #31, !dbg !3317
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %a837, metadata !3319, metadata !DIExpression()), !dbg !3320
  %40 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3321
  %owners38 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %40, i32 0, i32 1, !dbg !3322
  %record39 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners38, i32 0, i32 0, !dbg !3323
  %41 = load i32, i32* %a8_index, align 4, !dbg !3324
  %idxprom40 = zext i32 %41 to i64, !dbg !3321
  %arrayidx41 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record39, i64 0, i64 %idxprom40, !dbg !3321
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx41, %"struct.laya::full::FullOwnerRecord"** %a837, align 8, !dbg !3320
  %42 = bitcast i32* %high to i8*, !dbg !3325
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %42) #31, !dbg !3325
  call void @llvm.dbg.declare(metadata i32* %high, metadata !3326, metadata !DIExpression()), !dbg !3327
  %43 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a837, align 8, !dbg !3328
  %max_claimed_epoch42 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %43, i32 0, i32 3, !dbg !3329
  %44 = load i32, i32* %max_claimed_epoch42, align 8, !dbg !3329
  store i32 %44, i32* %high, align 4, !dbg !3327
  %id43 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 0, !dbg !3330
  %45 = load i8, i8* %id43, align 4, !dbg !3330
  %cmp44 = icmp eq i8 %45, 34, !dbg !3332
  br i1 %cmp44, label %land.lhs.true45, label %if.end54, !dbg !3333

land.lhs.true45:                                  ; preds = %if.then36
  %bank46 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 1, !dbg !3334
  %46 = load i8, i8* %bank46, align 1, !dbg !3334
  %conv47 = zext i8 %46 to i32, !dbg !3335
  %cmp48 = icmp eq i32 %conv47, 0, !dbg !3336
  br i1 %cmp48, label %land.lhs.true49, label %if.end54, !dbg !3337

land.lhs.true49:                                  ; preds = %land.lhs.true45
  %epoch50 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 2, !dbg !3338
  %47 = load i32, i32* %epoch50, align 4, !dbg !3338
  %48 = load i32, i32* %high, align 4, !dbg !3339
  %cmp51 = icmp ugt i32 %47, %48, !dbg !3340
  br i1 %cmp51, label %if.then52, label %if.end54, !dbg !3341

if.then52:                                        ; preds = %land.lhs.true49
  %epoch53 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %numeric_ref, i32 0, i32 2, !dbg !3342
  %49 = load i32, i32* %epoch53, align 4, !dbg !3342
  store i32 %49, i32* %high, align 4, !dbg !3343
  br label %if.end54, !dbg !3344

if.end54:                                         ; preds = %if.then52, %land.lhs.true49, %land.lhs.true45, %if.then36
  %50 = load i32, i32* %high, align 4, !dbg !3345
  %51 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a837, align 8, !dbg !3346
  %ref55 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %51, i32 0, i32 1, !dbg !3347
  %epoch56 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref55, i32 0, i32 2, !dbg !3348
  store i32 %50, i32* %epoch56, align 4, !dbg !3349
  %52 = load i32, i32* %high, align 4, !dbg !3350
  %53 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %a837, align 8, !dbg !3351
  %max_claimed_epoch57 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %53, i32 0, i32 3, !dbg !3352
  store i32 %52, i32* %max_claimed_epoch57, align 8, !dbg !3353
  %54 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !3354
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %54) #31, !dbg !3354
  %id58 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, i32 0, i32 0, !dbg !3354
  store i8 34, i8* %id58, align 4, !dbg !3354
  %bank59 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, i32 0, i32 1, !dbg !3354
  store i8 0, i8* %bank59, align 1, !dbg !3354
  %epoch60 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, i32 0, i32 2, !dbg !3354
  %55 = load i32, i32* %high, align 4, !dbg !3355
  store i32 %55, i32* %epoch60, align 4, !dbg !3354
  %56 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3356
  %cache61 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %56, i32 0, i32 2, !dbg !3357
  %activation_meta62 = getelementptr inbounds %"struct.laya::full::FullCache", %"struct.laya::full::FullCache"* %cache61, i32 0, i32 1, !dbg !3358
  %ref63 = getelementptr inbounds %"struct.laya::A8TileMeta", %"struct.laya::A8TileMeta"* %activation_meta62, i32 0, i32 1, !dbg !3359
  %57 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, align 4, !dbg !3360
  store %"struct.laya::BufferRef" %57, %"struct.laya::BufferRef"* %ref63, align 8, !dbg !3360
  %58 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !3356
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %58) #31, !dbg !3356
  %59 = bitcast i32* %high to i8*, !dbg !3361
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %59) #31, !dbg !3361
  %60 = bitcast %"struct.laya::full::FullOwnerRecord"** %a837 to i8*, !dbg !3361
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %60) #31, !dbg !3361
  br label %if.end64, !dbg !3362

if.end64:                                         ; preds = %if.end54, %if.end34
  br label %VITIS_LOOP_773_2, !dbg !3363

VITIS_LOOP_773_2:                                 ; preds = %if.end64
  %61 = bitcast i32* %i65 to i8*, !dbg !3364
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %61) #31, !dbg !3364
  call void @llvm.dbg.declare(metadata i32* %i65, metadata !3366, metadata !DIExpression()), !dbg !3367
  store i32 0, i32* %i65, align 4, !dbg !3367
  br label %for.cond66, !dbg !3364

for.cond66:                                       ; preds = %for.inc79, %VITIS_LOOP_773_2
  %62 = load i32, i32* %i65, align 4, !dbg !3368
  %cmp67 = icmp ult i32 %62, 32, !dbg !3370
  br i1 %cmp67, label %for.body69, label %for.cond.cleanup68, !dbg !3371

for.cond.cleanup68:                               ; preds = %for.cond66
  store i32 7, i32* %cleanup.dest.slot, align 4
  %63 = bitcast i32* %i65 to i8*, !dbg !3372
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %63) #31, !dbg !3372
  br label %for.end82

for.body69:                                       ; preds = %for.cond66
  %64 = bitcast %"struct.laya::full::FullOwnerRecord"** %r70 to i8*, !dbg !3373
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %64) #31, !dbg !3373
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %r70, metadata !3375, metadata !DIExpression()), !dbg !3376
  %65 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3377
  %owners71 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %65, i32 0, i32 1, !dbg !3378
  %record72 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners71, i32 0, i32 0, !dbg !3379
  %66 = load i32, i32* %i65, align 4, !dbg !3380
  %idxprom73 = zext i32 %66 to i64, !dbg !3377
  %arrayidx74 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record72, i64 0, i64 %idxprom73, !dbg !3377
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx74, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3376
  %67 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3381
  %state75 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %67, i32 0, i32 13, !dbg !3382
  store i8 6, i8* %state75, align 1, !dbg !3383
  %68 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3384
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %68, i32 0, i32 17, !dbg !3385
  store i1 false, i1* %valid, align 4, !dbg !3386
  %69 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3387
  %readers76 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %69, i32 0, i32 14, !dbg !3388
  store i8 0, i8* %readers76, align 2, !dbg !3389
  %70 = bitcast %"struct.laya::BufferRef"* %ref.tmp77 to i8*, !dbg !3390
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %70) #31, !dbg !3390
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp77), !dbg !3390
  %71 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3391
  %lease_old_ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %71, i32 0, i32 2, !dbg !3392
  %72 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp77, align 4, !dbg !3393
  store %"struct.laya::BufferRef" %72, %"struct.laya::BufferRef"* %lease_old_ref, align 8, !dbg !3393
  %73 = bitcast %"struct.laya::BufferRef"* %ref.tmp77 to i8*, !dbg !3391
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %73) #31, !dbg !3391
  %74 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3394
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %74, i32 0, i32 15, !dbg !3395
  %arraydecay = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !3394
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay), !dbg !3396
  %75 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %r70, align 8, !dbg !3397
  %old_consumed_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %75, i32 0, i32 16, !dbg !3398
  %arraydecay78 = getelementptr inbounds [64 x i32], [64 x i32]* %old_consumed_rows, i64 0, i64 0, !dbg !3397
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay78), !dbg !3399
  %76 = bitcast %"struct.laya::full::FullOwnerRecord"** %r70 to i8*, !dbg !3400
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %76) #31, !dbg !3400
  br label %for.inc79, !dbg !3401

for.inc79:                                        ; preds = %for.body69
  %77 = load i32, i32* %i65, align 4, !dbg !3402
  %inc80 = add i32 %77, 1, !dbg !3402
  store i32 %inc80, i32* %i65, align 4, !dbg !3402
  br label %for.cond66, !dbg !3372, !llvm.loop !3403

for.end82:                                        ; preds = %for.cond.cleanup68
  br label %VITIS_LOOP_782_3, !dbg !3404

VITIS_LOOP_782_3:                                 ; preds = %for.end82
  %78 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !3406
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %78) #31, !dbg !3406
  call void @llvm.dbg.declare(metadata [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, metadata !3408, metadata !DIExpression()), !dbg !3409
  %79 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3406
  %owners83 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %79, i32 0, i32 1, !dbg !3410
  %qkv_plane_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners83, i32 0, i32 1, !dbg !3411
  store [2 x [3 x [16 x [2 x [32 x i32]]]]]* %qkv_plane_head_rows, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !3406
  %80 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !3412
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %80) #31, !dbg !3412
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__begin2, metadata !3413, metadata !DIExpression()), !dbg !3409
  %81 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !3412
  %arraydecay84 = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %81, i64 0, i64 0, !dbg !3412
  store [3 x [16 x [2 x [32 x i32]]]]* %arraydecay84, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !3412
  %82 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !3412
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %82) #31, !dbg !3412
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__end2, metadata !3414, metadata !DIExpression()), !dbg !3409
  %83 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !3412
  %arraydecay85 = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %83, i64 0, i64 0, !dbg !3412
  %add.ptr = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %arraydecay85, i64 2, !dbg !3412
  store [3 x [16 x [2 x [32 x i32]]]]* %add.ptr, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !3412
  br label %for.cond86, !dbg !3412

for.cond86:                                       ; preds = %for.inc141, %VITIS_LOOP_782_3
  %84 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !3412
  %85 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !3412
  %cmp87 = icmp ne [3 x [16 x [2 x [32 x i32]]]]* %84, %85, !dbg !3412
  br i1 %cmp87, label %for.body89, label %for.cond.cleanup88, !dbg !3412

for.cond.cleanup88:                               ; preds = %for.cond86
  store i32 11, i32* %cleanup.dest.slot, align 4
  %86 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !3412
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %86) #31, !dbg !3412
  %87 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !3412
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %87) #31, !dbg !3412
  %88 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !3412
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %88) #31, !dbg !3412
  br label %for.end146

for.body89:                                       ; preds = %for.cond86
  %89 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !3415
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %89) #31, !dbg !3415
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %shard, metadata !3417, metadata !DIExpression()), !dbg !3418
  %90 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !3419
  store [3 x [16 x [2 x [32 x i32]]]]* %90, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !3418
  br label %VITIS_LOOP_783_4, !dbg !3415

VITIS_LOOP_783_4:                                 ; preds = %for.body89
  %91 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !3420
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %91) #31, !dbg !3420
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__range3, metadata !3422, metadata !DIExpression()), !dbg !3423
  %92 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !3420
  store [3 x [16 x [2 x [32 x i32]]]]* %92, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !3420
  %93 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !3424
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %93) #31, !dbg !3424
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin3, metadata !3425, metadata !DIExpression()), !dbg !3423
  %94 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !3424
  %arraydecay90 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %94, i64 0, i64 0, !dbg !3424
  store [16 x [2 x [32 x i32]]]* %arraydecay90, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !3424
  %95 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !3424
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %95) #31, !dbg !3424
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end3, metadata !3426, metadata !DIExpression()), !dbg !3423
  %96 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !3424
  %arraydecay91 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %96, i64 0, i64 0, !dbg !3424
  %add.ptr92 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay91, i64 3, !dbg !3424
  store [16 x [2 x [32 x i32]]]* %add.ptr92, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !3424
  br label %for.cond93, !dbg !3424

for.cond93:                                       ; preds = %for.inc135, %VITIS_LOOP_783_4
  %97 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !3424
  %98 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !3424
  %cmp94 = icmp ne [16 x [2 x [32 x i32]]]* %97, %98, !dbg !3424
  br i1 %cmp94, label %for.body96, label %for.cond.cleanup95, !dbg !3424

for.cond.cleanup95:                               ; preds = %for.cond93
  store i32 14, i32* %cleanup.dest.slot, align 4
  %99 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !3424
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %99) #31, !dbg !3424
  %100 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !3424
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %100) #31, !dbg !3424
  %101 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !3424
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %101) #31, !dbg !3424
  br label %for.end140

for.body96:                                       ; preds = %for.cond93
  %102 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !3427
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %102) #31, !dbg !3427
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane, metadata !3429, metadata !DIExpression()), !dbg !3430
  %103 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !3431
  store [16 x [2 x [32 x i32]]]* %103, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !3430
  br label %VITIS_LOOP_784_5, !dbg !3427

VITIS_LOOP_784_5:                                 ; preds = %for.body96
  %104 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !3432
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %104) #31, !dbg !3432
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range4, metadata !3434, metadata !DIExpression()), !dbg !3435
  %105 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !3432
  store [16 x [2 x [32 x i32]]]* %105, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !3432
  %106 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !3436
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %106) #31, !dbg !3436
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin4, metadata !3437, metadata !DIExpression()), !dbg !3435
  %107 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !3436
  %arraydecay97 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %107, i64 0, i64 0, !dbg !3436
  store [2 x [32 x i32]]* %arraydecay97, [2 x [32 x i32]]** %__begin4, align 8, !dbg !3436
  %108 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !3436
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %108) #31, !dbg !3436
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4, metadata !3438, metadata !DIExpression()), !dbg !3435
  %109 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !3436
  %arraydecay98 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %109, i64 0, i64 0, !dbg !3436
  %add.ptr99 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay98, i64 16, !dbg !3436
  store [2 x [32 x i32]]* %add.ptr99, [2 x [32 x i32]]** %__end4, align 8, !dbg !3436
  br label %for.cond100, !dbg !3436

for.cond100:                                      ; preds = %for.inc129, %VITIS_LOOP_784_5
  %110 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !3436
  %111 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4, align 8, !dbg !3436
  %cmp101 = icmp ne [2 x [32 x i32]]* %110, %111, !dbg !3436
  br i1 %cmp101, label %for.body103, label %for.cond.cleanup102, !dbg !3436

for.cond.cleanup102:                              ; preds = %for.cond100
  store i32 17, i32* %cleanup.dest.slot, align 4
  %112 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !3436
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %112) #31, !dbg !3436
  %113 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !3436
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %113) #31, !dbg !3436
  %114 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !3436
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %114) #31, !dbg !3436
  br label %for.end134

for.body103:                                      ; preds = %for.cond100
  %115 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !3439
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %115) #31, !dbg !3439
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head, metadata !3441, metadata !DIExpression()), !dbg !3442
  %116 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !3443
  store [2 x [32 x i32]]* %116, [2 x [32 x i32]]** %head, align 8, !dbg !3442
  br label %VITIS_LOOP_785_6, !dbg !3439

VITIS_LOOP_785_6:                                 ; preds = %for.body103
  %117 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !3444
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %117) #31, !dbg !3444
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5, metadata !3446, metadata !DIExpression()), !dbg !3447
  %118 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head, align 8, !dbg !3444
  store [2 x [32 x i32]]* %118, [2 x [32 x i32]]** %__range5, align 8, !dbg !3444
  %119 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !3448
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %119) #31, !dbg !3448
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5, metadata !3449, metadata !DIExpression()), !dbg !3447
  %120 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !3448
  %arraydecay104 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %120, i64 0, i64 0, !dbg !3448
  store [32 x i32]* %arraydecay104, [32 x i32]** %__begin5, align 8, !dbg !3448
  %121 = bitcast [32 x i32]** %__end5 to i8*, !dbg !3448
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %121) #31, !dbg !3448
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5, metadata !3450, metadata !DIExpression()), !dbg !3447
  %122 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !3448
  %arraydecay105 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %122, i64 0, i64 0, !dbg !3448
  %add.ptr106 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay105, i64 2, !dbg !3448
  store [32 x i32]* %add.ptr106, [32 x i32]** %__end5, align 8, !dbg !3448
  br label %for.cond107, !dbg !3448

for.cond107:                                      ; preds = %for.inc123, %VITIS_LOOP_785_6
  %123 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !3448
  %124 = load [32 x i32]*, [32 x i32]** %__end5, align 8, !dbg !3448
  %cmp108 = icmp ne [32 x i32]* %123, %124, !dbg !3448
  br i1 %cmp108, label %for.body110, label %for.cond.cleanup109, !dbg !3448

for.cond.cleanup109:                              ; preds = %for.cond107
  store i32 20, i32* %cleanup.dest.slot, align 4
  %125 = bitcast [32 x i32]** %__end5 to i8*, !dbg !3448
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %125) #31, !dbg !3448
  %126 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !3448
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %126) #31, !dbg !3448
  %127 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !3448
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %127) #31, !dbg !3448
  br label %for.end128

for.body110:                                      ; preds = %for.cond107
  %128 = bitcast [32 x i32]** %batch to i8*, !dbg !3451
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %128) #31, !dbg !3451
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch, metadata !3453, metadata !DIExpression()), !dbg !3454
  %129 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !3455
  store [32 x i32]* %129, [32 x i32]** %batch, align 8, !dbg !3454
  br label %VITIS_LOOP_786_7, !dbg !3451

VITIS_LOOP_786_7:                                 ; preds = %for.body110
  %130 = bitcast [32 x i32]** %__range6 to i8*, !dbg !3456
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %130) #31, !dbg !3456
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6, metadata !3458, metadata !DIExpression()), !dbg !3459
  %131 = load [32 x i32]*, [32 x i32]** %batch, align 8, !dbg !3456
  store [32 x i32]* %131, [32 x i32]** %__range6, align 8, !dbg !3456
  %132 = bitcast i32** %__begin6 to i8*, !dbg !3460
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %132) #31, !dbg !3460
  call void @llvm.dbg.declare(metadata i32** %__begin6, metadata !3461, metadata !DIExpression()), !dbg !3459
  %133 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !3460
  %arraydecay111 = getelementptr inbounds [32 x i32], [32 x i32]* %133, i64 0, i64 0, !dbg !3460
  store i32* %arraydecay111, i32** %__begin6, align 8, !dbg !3460
  %134 = bitcast i32** %__end6 to i8*, !dbg !3460
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %134) #31, !dbg !3460
  call void @llvm.dbg.declare(metadata i32** %__end6, metadata !3462, metadata !DIExpression()), !dbg !3459
  %135 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !3460
  %arraydecay112 = getelementptr inbounds [32 x i32], [32 x i32]* %135, i64 0, i64 0, !dbg !3460
  %add.ptr113 = getelementptr inbounds i32, i32* %arraydecay112, i64 32, !dbg !3460
  store i32* %add.ptr113, i32** %__end6, align 8, !dbg !3460
  br label %for.cond114, !dbg !3460

for.cond114:                                      ; preds = %for.inc118, %VITIS_LOOP_786_7
  %136 = load i32*, i32** %__begin6, align 8, !dbg !3460
  %137 = load i32*, i32** %__end6, align 8, !dbg !3460
  %cmp115 = icmp ne i32* %136, %137, !dbg !3460
  br i1 %cmp115, label %for.body117, label %for.cond.cleanup116, !dbg !3460

for.cond.cleanup116:                              ; preds = %for.cond114
  store i32 23, i32* %cleanup.dest.slot, align 4
  %138 = bitcast i32** %__end6 to i8*, !dbg !3460
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %138) #31, !dbg !3460
  %139 = bitcast i32** %__begin6 to i8*, !dbg !3460
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %139) #31, !dbg !3460
  %140 = bitcast [32 x i32]** %__range6 to i8*, !dbg !3460
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %140) #31, !dbg !3460
  br label %for.end122

for.body117:                                      ; preds = %for.cond114
  %141 = bitcast i32** %word to i8*, !dbg !3463
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %141) #31, !dbg !3463
  call void @llvm.dbg.declare(metadata i32** %word, metadata !3465, metadata !DIExpression()), !dbg !3466
  %142 = load i32*, i32** %__begin6, align 8, !dbg !3467
  store i32* %142, i32** %word, align 8, !dbg !3466
  %143 = load i32*, i32** %word, align 8, !dbg !3468
  store i32 0, i32* %143, align 4, !dbg !3469
  %144 = bitcast i32** %word to i8*, !dbg !3470
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %144) #31, !dbg !3470
  br label %for.inc118, !dbg !3471

for.inc118:                                       ; preds = %for.body117
  %145 = load i32*, i32** %__begin6, align 8, !dbg !3460
  %incdec.ptr = getelementptr inbounds i32, i32* %145, i32 1, !dbg !3460
  store i32* %incdec.ptr, i32** %__begin6, align 8, !dbg !3460
  br label %for.cond114, !dbg !3460, !llvm.loop !3472

for.end122:                                       ; preds = %for.cond.cleanup116
  %146 = bitcast [32 x i32]** %batch to i8*, !dbg !3474
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %146) #31, !dbg !3474
  br label %for.inc123, !dbg !3475

for.inc123:                                       ; preds = %for.end122
  %147 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !3448
  %incdec.ptr124 = getelementptr inbounds [32 x i32], [32 x i32]* %147, i32 1, !dbg !3448
  store [32 x i32]* %incdec.ptr124, [32 x i32]** %__begin5, align 8, !dbg !3448
  br label %for.cond107, !dbg !3448, !llvm.loop !3476

for.end128:                                       ; preds = %for.cond.cleanup109
  %148 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !3478
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %148) #31, !dbg !3478
  br label %for.inc129, !dbg !3479

for.inc129:                                       ; preds = %for.end128
  %149 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !3436
  %incdec.ptr130 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %149, i32 1, !dbg !3436
  store [2 x [32 x i32]]* %incdec.ptr130, [2 x [32 x i32]]** %__begin4, align 8, !dbg !3436
  br label %for.cond100, !dbg !3436, !llvm.loop !3480

for.end134:                                       ; preds = %for.cond.cleanup102
  %150 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !3482
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %150) #31, !dbg !3482
  br label %for.inc135, !dbg !3483

for.inc135:                                       ; preds = %for.end134
  %151 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !3424
  %incdec.ptr136 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %151, i32 1, !dbg !3424
  store [16 x [2 x [32 x i32]]]* %incdec.ptr136, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !3424
  br label %for.cond93, !dbg !3424, !llvm.loop !3484

for.end140:                                       ; preds = %for.cond.cleanup95
  %152 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !3486
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %152) #31, !dbg !3486
  br label %for.inc141, !dbg !3487

for.inc141:                                       ; preds = %for.end140
  %153 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !3412
  %incdec.ptr142 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %153, i32 1, !dbg !3412
  store [3 x [16 x [2 x [32 x i32]]]]* %incdec.ptr142, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !3412
  br label %for.cond86, !dbg !3412, !llvm.loop !3488

for.end146:                                       ; preds = %for.cond.cleanup88
  br label %VITIS_LOOP_787_8, !dbg !3486

VITIS_LOOP_787_8:                                 ; preds = %for.end146
  %154 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147 to i8*, !dbg !3490
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %154) #31, !dbg !3490
  call void @llvm.dbg.declare(metadata [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147, metadata !3492, metadata !DIExpression()), !dbg !3493
  %155 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3490
  %owners148 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %155, i32 0, i32 1, !dbg !3494
  %qkv_rope_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners148, i32 0, i32 2, !dbg !3495
  store [2 x [2 x [16 x [2 x [32 x i32]]]]]* %qkv_rope_rows, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147, align 8, !dbg !3490
  %156 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin2149 to i8*, !dbg !3496
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %156) #31, !dbg !3496
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, metadata !3497, metadata !DIExpression()), !dbg !3493
  %157 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147, align 8, !dbg !3496
  %arraydecay150 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %157, i64 0, i64 0, !dbg !3496
  store [2 x [16 x [2 x [32 x i32]]]]* %arraydecay150, [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, align 8, !dbg !3496
  %158 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end2151 to i8*, !dbg !3496
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %158) #31, !dbg !3496
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__end2151, metadata !3498, metadata !DIExpression()), !dbg !3493
  %159 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147, align 8, !dbg !3496
  %arraydecay152 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %159, i64 0, i64 0, !dbg !3496
  %add.ptr153 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %arraydecay152, i64 2, !dbg !3496
  store [2 x [16 x [2 x [32 x i32]]]]* %add.ptr153, [2 x [16 x [2 x [32 x i32]]]]** %__end2151, align 8, !dbg !3496
  br label %for.cond154, !dbg !3496

for.cond154:                                      ; preds = %for.inc227, %VITIS_LOOP_787_8
  %160 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, align 8, !dbg !3496
  %161 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__end2151, align 8, !dbg !3496
  %cmp155 = icmp ne [2 x [16 x [2 x [32 x i32]]]]* %160, %161, !dbg !3496
  br i1 %cmp155, label %for.body157, label %for.cond.cleanup156, !dbg !3496

for.cond.cleanup156:                              ; preds = %for.cond154
  store i32 26, i32* %cleanup.dest.slot, align 4
  %162 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end2151 to i8*, !dbg !3496
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %162) #31, !dbg !3496
  %163 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin2149 to i8*, !dbg !3496
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %163) #31, !dbg !3496
  %164 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2147 to i8*, !dbg !3496
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %164) #31, !dbg !3496
  br label %for.end232

for.body157:                                      ; preds = %for.cond154
  %165 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard158 to i8*, !dbg !3499
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %165) #31, !dbg !3499
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %shard158, metadata !3501, metadata !DIExpression()), !dbg !3502
  %166 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, align 8, !dbg !3503
  store [2 x [16 x [2 x [32 x i32]]]]* %166, [2 x [16 x [2 x [32 x i32]]]]** %shard158, align 8, !dbg !3502
  br label %VITIS_LOOP_788_9, !dbg !3499

VITIS_LOOP_788_9:                                 ; preds = %for.body157
  %167 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range3159 to i8*, !dbg !3504
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %167) #31, !dbg !3504
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__range3159, metadata !3506, metadata !DIExpression()), !dbg !3507
  %168 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %shard158, align 8, !dbg !3504
  store [2 x [16 x [2 x [32 x i32]]]]* %168, [2 x [16 x [2 x [32 x i32]]]]** %__range3159, align 8, !dbg !3504
  %169 = bitcast [16 x [2 x [32 x i32]]]** %__begin3160 to i8*, !dbg !3508
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %169) #31, !dbg !3508
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin3160, metadata !3509, metadata !DIExpression()), !dbg !3507
  %170 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range3159, align 8, !dbg !3508
  %arraydecay161 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %170, i64 0, i64 0, !dbg !3508
  store [16 x [2 x [32 x i32]]]* %arraydecay161, [16 x [2 x [32 x i32]]]** %__begin3160, align 8, !dbg !3508
  %171 = bitcast [16 x [2 x [32 x i32]]]** %__end3162 to i8*, !dbg !3508
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %171) #31, !dbg !3508
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end3162, metadata !3510, metadata !DIExpression()), !dbg !3507
  %172 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range3159, align 8, !dbg !3508
  %arraydecay163 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %172, i64 0, i64 0, !dbg !3508
  %add.ptr164 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay163, i64 2, !dbg !3508
  store [16 x [2 x [32 x i32]]]* %add.ptr164, [16 x [2 x [32 x i32]]]** %__end3162, align 8, !dbg !3508
  br label %for.cond165, !dbg !3508

for.cond165:                                      ; preds = %for.inc221, %VITIS_LOOP_788_9
  %173 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3160, align 8, !dbg !3508
  %174 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end3162, align 8, !dbg !3508
  %cmp166 = icmp ne [16 x [2 x [32 x i32]]]* %173, %174, !dbg !3508
  br i1 %cmp166, label %for.body168, label %for.cond.cleanup167, !dbg !3508

for.cond.cleanup167:                              ; preds = %for.cond165
  store i32 29, i32* %cleanup.dest.slot, align 4
  %175 = bitcast [16 x [2 x [32 x i32]]]** %__end3162 to i8*, !dbg !3508
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %175) #31, !dbg !3508
  %176 = bitcast [16 x [2 x [32 x i32]]]** %__begin3160 to i8*, !dbg !3508
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %176) #31, !dbg !3508
  %177 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range3159 to i8*, !dbg !3508
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %177) #31, !dbg !3508
  br label %for.end226

for.body168:                                      ; preds = %for.cond165
  %178 = bitcast [16 x [2 x [32 x i32]]]** %plane169 to i8*, !dbg !3511
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %178) #31, !dbg !3511
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane169, metadata !3513, metadata !DIExpression()), !dbg !3514
  %179 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3160, align 8, !dbg !3515
  store [16 x [2 x [32 x i32]]]* %179, [16 x [2 x [32 x i32]]]** %plane169, align 8, !dbg !3514
  br label %VITIS_LOOP_789_10, !dbg !3511

VITIS_LOOP_789_10:                                ; preds = %for.body168
  %180 = bitcast [16 x [2 x [32 x i32]]]** %__range4170 to i8*, !dbg !3516
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %180) #31, !dbg !3516
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range4170, metadata !3518, metadata !DIExpression()), !dbg !3519
  %181 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane169, align 8, !dbg !3516
  store [16 x [2 x [32 x i32]]]* %181, [16 x [2 x [32 x i32]]]** %__range4170, align 8, !dbg !3516
  %182 = bitcast [2 x [32 x i32]]** %__begin4171 to i8*, !dbg !3520
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %182) #31, !dbg !3520
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin4171, metadata !3521, metadata !DIExpression()), !dbg !3519
  %183 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4170, align 8, !dbg !3520
  %arraydecay172 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %183, i64 0, i64 0, !dbg !3520
  store [2 x [32 x i32]]* %arraydecay172, [2 x [32 x i32]]** %__begin4171, align 8, !dbg !3520
  %184 = bitcast [2 x [32 x i32]]** %__end4173 to i8*, !dbg !3520
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %184) #31, !dbg !3520
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4173, metadata !3522, metadata !DIExpression()), !dbg !3519
  %185 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4170, align 8, !dbg !3520
  %arraydecay174 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %185, i64 0, i64 0, !dbg !3520
  %add.ptr175 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay174, i64 16, !dbg !3520
  store [2 x [32 x i32]]* %add.ptr175, [2 x [32 x i32]]** %__end4173, align 8, !dbg !3520
  br label %for.cond176, !dbg !3520

for.cond176:                                      ; preds = %for.inc215, %VITIS_LOOP_789_10
  %186 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4171, align 8, !dbg !3520
  %187 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4173, align 8, !dbg !3520
  %cmp177 = icmp ne [2 x [32 x i32]]* %186, %187, !dbg !3520
  br i1 %cmp177, label %for.body179, label %for.cond.cleanup178, !dbg !3520

for.cond.cleanup178:                              ; preds = %for.cond176
  store i32 32, i32* %cleanup.dest.slot, align 4
  %188 = bitcast [2 x [32 x i32]]** %__end4173 to i8*, !dbg !3520
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %188) #31, !dbg !3520
  %189 = bitcast [2 x [32 x i32]]** %__begin4171 to i8*, !dbg !3520
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %189) #31, !dbg !3520
  %190 = bitcast [16 x [2 x [32 x i32]]]** %__range4170 to i8*, !dbg !3520
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %190) #31, !dbg !3520
  br label %for.end220

for.body179:                                      ; preds = %for.cond176
  %191 = bitcast [2 x [32 x i32]]** %head180 to i8*, !dbg !3523
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %191) #31, !dbg !3523
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head180, metadata !3525, metadata !DIExpression()), !dbg !3526
  %192 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4171, align 8, !dbg !3527
  store [2 x [32 x i32]]* %192, [2 x [32 x i32]]** %head180, align 8, !dbg !3526
  br label %VITIS_LOOP_790_11, !dbg !3523

VITIS_LOOP_790_11:                                ; preds = %for.body179
  %193 = bitcast [2 x [32 x i32]]** %__range5181 to i8*, !dbg !3528
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %193) #31, !dbg !3528
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5181, metadata !3530, metadata !DIExpression()), !dbg !3531
  %194 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head180, align 8, !dbg !3528
  store [2 x [32 x i32]]* %194, [2 x [32 x i32]]** %__range5181, align 8, !dbg !3528
  %195 = bitcast [32 x i32]** %__begin5182 to i8*, !dbg !3532
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %195) #31, !dbg !3532
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5182, metadata !3533, metadata !DIExpression()), !dbg !3531
  %196 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5181, align 8, !dbg !3532
  %arraydecay183 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %196, i64 0, i64 0, !dbg !3532
  store [32 x i32]* %arraydecay183, [32 x i32]** %__begin5182, align 8, !dbg !3532
  %197 = bitcast [32 x i32]** %__end5184 to i8*, !dbg !3532
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %197) #31, !dbg !3532
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5184, metadata !3534, metadata !DIExpression()), !dbg !3531
  %198 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5181, align 8, !dbg !3532
  %arraydecay185 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %198, i64 0, i64 0, !dbg !3532
  %add.ptr186 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay185, i64 2, !dbg !3532
  store [32 x i32]* %add.ptr186, [32 x i32]** %__end5184, align 8, !dbg !3532
  br label %for.cond187, !dbg !3532

for.cond187:                                      ; preds = %for.inc209, %VITIS_LOOP_790_11
  %199 = load [32 x i32]*, [32 x i32]** %__begin5182, align 8, !dbg !3532
  %200 = load [32 x i32]*, [32 x i32]** %__end5184, align 8, !dbg !3532
  %cmp188 = icmp ne [32 x i32]* %199, %200, !dbg !3532
  br i1 %cmp188, label %for.body190, label %for.cond.cleanup189, !dbg !3532

for.cond.cleanup189:                              ; preds = %for.cond187
  store i32 35, i32* %cleanup.dest.slot, align 4
  %201 = bitcast [32 x i32]** %__end5184 to i8*, !dbg !3532
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %201) #31, !dbg !3532
  %202 = bitcast [32 x i32]** %__begin5182 to i8*, !dbg !3532
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %202) #31, !dbg !3532
  %203 = bitcast [2 x [32 x i32]]** %__range5181 to i8*, !dbg !3532
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %203) #31, !dbg !3532
  br label %for.end214

for.body190:                                      ; preds = %for.cond187
  %204 = bitcast [32 x i32]** %batch191 to i8*, !dbg !3535
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %204) #31, !dbg !3535
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch191, metadata !3537, metadata !DIExpression()), !dbg !3538
  %205 = load [32 x i32]*, [32 x i32]** %__begin5182, align 8, !dbg !3539
  store [32 x i32]* %205, [32 x i32]** %batch191, align 8, !dbg !3538
  br label %VITIS_LOOP_791_12, !dbg !3535

VITIS_LOOP_791_12:                                ; preds = %for.body190
  %206 = bitcast [32 x i32]** %__range6192 to i8*, !dbg !3540
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %206) #31, !dbg !3540
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6192, metadata !3542, metadata !DIExpression()), !dbg !3543
  %207 = load [32 x i32]*, [32 x i32]** %batch191, align 8, !dbg !3540
  store [32 x i32]* %207, [32 x i32]** %__range6192, align 8, !dbg !3540
  %208 = bitcast i32** %__begin6193 to i8*, !dbg !3544
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %208) #31, !dbg !3544
  call void @llvm.dbg.declare(metadata i32** %__begin6193, metadata !3545, metadata !DIExpression()), !dbg !3543
  %209 = load [32 x i32]*, [32 x i32]** %__range6192, align 8, !dbg !3544
  %arraydecay194 = getelementptr inbounds [32 x i32], [32 x i32]* %209, i64 0, i64 0, !dbg !3544
  store i32* %arraydecay194, i32** %__begin6193, align 8, !dbg !3544
  %210 = bitcast i32** %__end6195 to i8*, !dbg !3544
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %210) #31, !dbg !3544
  call void @llvm.dbg.declare(metadata i32** %__end6195, metadata !3546, metadata !DIExpression()), !dbg !3543
  %211 = load [32 x i32]*, [32 x i32]** %__range6192, align 8, !dbg !3544
  %arraydecay196 = getelementptr inbounds [32 x i32], [32 x i32]* %211, i64 0, i64 0, !dbg !3544
  %add.ptr197 = getelementptr inbounds i32, i32* %arraydecay196, i64 32, !dbg !3544
  store i32* %add.ptr197, i32** %__end6195, align 8, !dbg !3544
  br label %for.cond198, !dbg !3544

for.cond198:                                      ; preds = %for.inc203, %VITIS_LOOP_791_12
  %212 = load i32*, i32** %__begin6193, align 8, !dbg !3544
  %213 = load i32*, i32** %__end6195, align 8, !dbg !3544
  %cmp199 = icmp ne i32* %212, %213, !dbg !3544
  br i1 %cmp199, label %for.body201, label %for.cond.cleanup200, !dbg !3544

for.cond.cleanup200:                              ; preds = %for.cond198
  store i32 38, i32* %cleanup.dest.slot, align 4
  %214 = bitcast i32** %__end6195 to i8*, !dbg !3544
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %214) #31, !dbg !3544
  %215 = bitcast i32** %__begin6193 to i8*, !dbg !3544
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %215) #31, !dbg !3544
  %216 = bitcast [32 x i32]** %__range6192 to i8*, !dbg !3544
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %216) #31, !dbg !3544
  br label %for.end208

for.body201:                                      ; preds = %for.cond198
  %217 = bitcast i32** %word202 to i8*, !dbg !3547
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %217) #31, !dbg !3547
  call void @llvm.dbg.declare(metadata i32** %word202, metadata !3549, metadata !DIExpression()), !dbg !3550
  %218 = load i32*, i32** %__begin6193, align 8, !dbg !3551
  store i32* %218, i32** %word202, align 8, !dbg !3550
  %219 = load i32*, i32** %word202, align 8, !dbg !3552
  store i32 0, i32* %219, align 4, !dbg !3553
  %220 = bitcast i32** %word202 to i8*, !dbg !3554
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %220) #31, !dbg !3554
  br label %for.inc203, !dbg !3555

for.inc203:                                       ; preds = %for.body201
  %221 = load i32*, i32** %__begin6193, align 8, !dbg !3544
  %incdec.ptr204 = getelementptr inbounds i32, i32* %221, i32 1, !dbg !3544
  store i32* %incdec.ptr204, i32** %__begin6193, align 8, !dbg !3544
  br label %for.cond198, !dbg !3544, !llvm.loop !3556

for.end208:                                       ; preds = %for.cond.cleanup200
  %222 = bitcast [32 x i32]** %batch191 to i8*, !dbg !3558
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %222) #31, !dbg !3558
  br label %for.inc209, !dbg !3559

for.inc209:                                       ; preds = %for.end208
  %223 = load [32 x i32]*, [32 x i32]** %__begin5182, align 8, !dbg !3532
  %incdec.ptr210 = getelementptr inbounds [32 x i32], [32 x i32]* %223, i32 1, !dbg !3532
  store [32 x i32]* %incdec.ptr210, [32 x i32]** %__begin5182, align 8, !dbg !3532
  br label %for.cond187, !dbg !3532, !llvm.loop !3560

for.end214:                                       ; preds = %for.cond.cleanup189
  %224 = bitcast [2 x [32 x i32]]** %head180 to i8*, !dbg !3562
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %224) #31, !dbg !3562
  br label %for.inc215, !dbg !3563

for.inc215:                                       ; preds = %for.end214
  %225 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4171, align 8, !dbg !3520
  %incdec.ptr216 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %225, i32 1, !dbg !3520
  store [2 x [32 x i32]]* %incdec.ptr216, [2 x [32 x i32]]** %__begin4171, align 8, !dbg !3520
  br label %for.cond176, !dbg !3520, !llvm.loop !3564

for.end220:                                       ; preds = %for.cond.cleanup178
  %226 = bitcast [16 x [2 x [32 x i32]]]** %plane169 to i8*, !dbg !3566
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %226) #31, !dbg !3566
  br label %for.inc221, !dbg !3567

for.inc221:                                       ; preds = %for.end220
  %227 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3160, align 8, !dbg !3508
  %incdec.ptr222 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %227, i32 1, !dbg !3508
  store [16 x [2 x [32 x i32]]]* %incdec.ptr222, [16 x [2 x [32 x i32]]]** %__begin3160, align 8, !dbg !3508
  br label %for.cond165, !dbg !3508, !llvm.loop !3568

for.end226:                                       ; preds = %for.cond.cleanup167
  %228 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard158 to i8*, !dbg !3570
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %228) #31, !dbg !3570
  br label %for.inc227, !dbg !3571

for.inc227:                                       ; preds = %for.end226
  %229 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, align 8, !dbg !3496
  %incdec.ptr228 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %229, i32 1, !dbg !3496
  store [2 x [16 x [2 x [32 x i32]]]]* %incdec.ptr228, [2 x [16 x [2 x [32 x i32]]]]** %__begin2149, align 8, !dbg !3496
  br label %for.cond154, !dbg !3496, !llvm.loop !3572

for.end232:                                       ; preds = %for.cond.cleanup156
  br label %VITIS_LOOP_792_13, !dbg !3570

VITIS_LOOP_792_13:                                ; preds = %for.end232
  %230 = bitcast [16 x [2 x [32 x i32]]]** %__range2233 to i8*, !dbg !3574
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %230) #31, !dbg !3574
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range2233, metadata !3576, metadata !DIExpression()), !dbg !3577
  %231 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3574
  %owners234 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %231, i32 0, i32 1, !dbg !3578
  %att_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners234, i32 0, i32 3, !dbg !3579
  store [16 x [2 x [32 x i32]]]* %att_head_rows, [16 x [2 x [32 x i32]]]** %__range2233, align 8, !dbg !3574
  %232 = bitcast [2 x [32 x i32]]** %__begin2235 to i8*, !dbg !3580
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %232) #31, !dbg !3580
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin2235, metadata !3581, metadata !DIExpression()), !dbg !3577
  %233 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range2233, align 8, !dbg !3580
  %arraydecay236 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %233, i64 0, i64 0, !dbg !3580
  store [2 x [32 x i32]]* %arraydecay236, [2 x [32 x i32]]** %__begin2235, align 8, !dbg !3580
  %234 = bitcast [2 x [32 x i32]]** %__end2237 to i8*, !dbg !3580
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %234) #31, !dbg !3580
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end2237, metadata !3582, metadata !DIExpression()), !dbg !3577
  %235 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range2233, align 8, !dbg !3580
  %arraydecay238 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %235, i64 0, i64 0, !dbg !3580
  %add.ptr239 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay238, i64 16, !dbg !3580
  store [2 x [32 x i32]]* %add.ptr239, [2 x [32 x i32]]** %__end2237, align 8, !dbg !3580
  br label %for.cond240, !dbg !3580

for.cond240:                                      ; preds = %for.inc279, %VITIS_LOOP_792_13
  %236 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin2235, align 8, !dbg !3580
  %237 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end2237, align 8, !dbg !3580
  %cmp241 = icmp ne [2 x [32 x i32]]* %236, %237, !dbg !3580
  br i1 %cmp241, label %for.body243, label %for.cond.cleanup242, !dbg !3580

for.cond.cleanup242:                              ; preds = %for.cond240
  store i32 41, i32* %cleanup.dest.slot, align 4
  %238 = bitcast [2 x [32 x i32]]** %__end2237 to i8*, !dbg !3580
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %238) #31, !dbg !3580
  %239 = bitcast [2 x [32 x i32]]** %__begin2235 to i8*, !dbg !3580
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %239) #31, !dbg !3580
  %240 = bitcast [16 x [2 x [32 x i32]]]** %__range2233 to i8*, !dbg !3580
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %240) #31, !dbg !3580
  br label %for.end284

for.body243:                                      ; preds = %for.cond240
  %241 = bitcast [2 x [32 x i32]]** %head244 to i8*, !dbg !3583
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %241) #31, !dbg !3583
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head244, metadata !3585, metadata !DIExpression()), !dbg !3586
  %242 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin2235, align 8, !dbg !3587
  store [2 x [32 x i32]]* %242, [2 x [32 x i32]]** %head244, align 8, !dbg !3586
  br label %VITIS_LOOP_793_14, !dbg !3583

VITIS_LOOP_793_14:                                ; preds = %for.body243
  %243 = bitcast [2 x [32 x i32]]** %__range3245 to i8*, !dbg !3588
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %243) #31, !dbg !3588
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range3245, metadata !3590, metadata !DIExpression()), !dbg !3591
  %244 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head244, align 8, !dbg !3588
  store [2 x [32 x i32]]* %244, [2 x [32 x i32]]** %__range3245, align 8, !dbg !3588
  %245 = bitcast [32 x i32]** %__begin3246 to i8*, !dbg !3592
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %245) #31, !dbg !3592
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin3246, metadata !3593, metadata !DIExpression()), !dbg !3591
  %246 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range3245, align 8, !dbg !3592
  %arraydecay247 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %246, i64 0, i64 0, !dbg !3592
  store [32 x i32]* %arraydecay247, [32 x i32]** %__begin3246, align 8, !dbg !3592
  %247 = bitcast [32 x i32]** %__end3248 to i8*, !dbg !3592
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %247) #31, !dbg !3592
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end3248, metadata !3594, metadata !DIExpression()), !dbg !3591
  %248 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range3245, align 8, !dbg !3592
  %arraydecay249 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %248, i64 0, i64 0, !dbg !3592
  %add.ptr250 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay249, i64 2, !dbg !3592
  store [32 x i32]* %add.ptr250, [32 x i32]** %__end3248, align 8, !dbg !3592
  br label %for.cond251, !dbg !3592

for.cond251:                                      ; preds = %for.inc273, %VITIS_LOOP_793_14
  %249 = load [32 x i32]*, [32 x i32]** %__begin3246, align 8, !dbg !3592
  %250 = load [32 x i32]*, [32 x i32]** %__end3248, align 8, !dbg !3592
  %cmp252 = icmp ne [32 x i32]* %249, %250, !dbg !3592
  br i1 %cmp252, label %for.body254, label %for.cond.cleanup253, !dbg !3592

for.cond.cleanup253:                              ; preds = %for.cond251
  store i32 44, i32* %cleanup.dest.slot, align 4
  %251 = bitcast [32 x i32]** %__end3248 to i8*, !dbg !3592
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %251) #31, !dbg !3592
  %252 = bitcast [32 x i32]** %__begin3246 to i8*, !dbg !3592
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %252) #31, !dbg !3592
  %253 = bitcast [2 x [32 x i32]]** %__range3245 to i8*, !dbg !3592
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %253) #31, !dbg !3592
  br label %for.end278

for.body254:                                      ; preds = %for.cond251
  %254 = bitcast [32 x i32]** %batch255 to i8*, !dbg !3595
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %254) #31, !dbg !3595
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch255, metadata !3597, metadata !DIExpression()), !dbg !3598
  %255 = load [32 x i32]*, [32 x i32]** %__begin3246, align 8, !dbg !3599
  store [32 x i32]* %255, [32 x i32]** %batch255, align 8, !dbg !3598
  br label %VITIS_LOOP_794_15, !dbg !3595

VITIS_LOOP_794_15:                                ; preds = %for.body254
  %256 = bitcast [32 x i32]** %__range4256 to i8*, !dbg !3600
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %256) #31, !dbg !3600
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range4256, metadata !3602, metadata !DIExpression()), !dbg !3603
  %257 = load [32 x i32]*, [32 x i32]** %batch255, align 8, !dbg !3600
  store [32 x i32]* %257, [32 x i32]** %__range4256, align 8, !dbg !3600
  %258 = bitcast i32** %__begin4257 to i8*, !dbg !3604
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %258) #31, !dbg !3604
  call void @llvm.dbg.declare(metadata i32** %__begin4257, metadata !3605, metadata !DIExpression()), !dbg !3603
  %259 = load [32 x i32]*, [32 x i32]** %__range4256, align 8, !dbg !3604
  %arraydecay258 = getelementptr inbounds [32 x i32], [32 x i32]* %259, i64 0, i64 0, !dbg !3604
  store i32* %arraydecay258, i32** %__begin4257, align 8, !dbg !3604
  %260 = bitcast i32** %__end4259 to i8*, !dbg !3604
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %260) #31, !dbg !3604
  call void @llvm.dbg.declare(metadata i32** %__end4259, metadata !3606, metadata !DIExpression()), !dbg !3603
  %261 = load [32 x i32]*, [32 x i32]** %__range4256, align 8, !dbg !3604
  %arraydecay260 = getelementptr inbounds [32 x i32], [32 x i32]* %261, i64 0, i64 0, !dbg !3604
  %add.ptr261 = getelementptr inbounds i32, i32* %arraydecay260, i64 32, !dbg !3604
  store i32* %add.ptr261, i32** %__end4259, align 8, !dbg !3604
  br label %for.cond262, !dbg !3604

for.cond262:                                      ; preds = %for.inc267, %VITIS_LOOP_794_15
  %262 = load i32*, i32** %__begin4257, align 8, !dbg !3604
  %263 = load i32*, i32** %__end4259, align 8, !dbg !3604
  %cmp263 = icmp ne i32* %262, %263, !dbg !3604
  br i1 %cmp263, label %for.body265, label %for.cond.cleanup264, !dbg !3604

for.cond.cleanup264:                              ; preds = %for.cond262
  store i32 47, i32* %cleanup.dest.slot, align 4
  %264 = bitcast i32** %__end4259 to i8*, !dbg !3604
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %264) #31, !dbg !3604
  %265 = bitcast i32** %__begin4257 to i8*, !dbg !3604
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %265) #31, !dbg !3604
  %266 = bitcast [32 x i32]** %__range4256 to i8*, !dbg !3604
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %266) #31, !dbg !3604
  br label %for.end272

for.body265:                                      ; preds = %for.cond262
  %267 = bitcast i32** %word266 to i8*, !dbg !3607
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %267) #31, !dbg !3607
  call void @llvm.dbg.declare(metadata i32** %word266, metadata !3609, metadata !DIExpression()), !dbg !3610
  %268 = load i32*, i32** %__begin4257, align 8, !dbg !3611
  store i32* %268, i32** %word266, align 8, !dbg !3610
  %269 = load i32*, i32** %word266, align 8, !dbg !3612
  store i32 0, i32* %269, align 4, !dbg !3613
  %270 = bitcast i32** %word266 to i8*, !dbg !3614
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %270) #31, !dbg !3614
  br label %for.inc267, !dbg !3615

for.inc267:                                       ; preds = %for.body265
  %271 = load i32*, i32** %__begin4257, align 8, !dbg !3604
  %incdec.ptr268 = getelementptr inbounds i32, i32* %271, i32 1, !dbg !3604
  store i32* %incdec.ptr268, i32** %__begin4257, align 8, !dbg !3604
  br label %for.cond262, !dbg !3604, !llvm.loop !3616

for.end272:                                       ; preds = %for.cond.cleanup264
  %272 = bitcast [32 x i32]** %batch255 to i8*, !dbg !3618
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %272) #31, !dbg !3618
  br label %for.inc273, !dbg !3619

for.inc273:                                       ; preds = %for.end272
  %273 = load [32 x i32]*, [32 x i32]** %__begin3246, align 8, !dbg !3592
  %incdec.ptr274 = getelementptr inbounds [32 x i32], [32 x i32]* %273, i32 1, !dbg !3592
  store [32 x i32]* %incdec.ptr274, [32 x i32]** %__begin3246, align 8, !dbg !3592
  br label %for.cond251, !dbg !3592, !llvm.loop !3620

for.end278:                                       ; preds = %for.cond.cleanup253
  %274 = bitcast [2 x [32 x i32]]** %head244 to i8*, !dbg !3622
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %274) #31, !dbg !3622
  br label %for.inc279, !dbg !3623

for.inc279:                                       ; preds = %for.end278
  %275 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin2235, align 8, !dbg !3580
  %incdec.ptr280 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %275, i32 1, !dbg !3580
  store [2 x [32 x i32]]* %incdec.ptr280, [2 x [32 x i32]]** %__begin2235, align 8, !dbg !3580
  br label %for.cond240, !dbg !3580, !llvm.loop !3624

for.end284:                                       ; preds = %for.cond.cleanup242
  br label %VITIS_LOOP_795_16, !dbg !3622

VITIS_LOOP_795_16:                                ; preds = %for.end284
  %276 = bitcast i32* %b to i8*, !dbg !3626
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %276) #31, !dbg !3626
  call void @llvm.dbg.declare(metadata i32* %b, metadata !3628, metadata !DIExpression()), !dbg !3629
  store i32 0, i32* %b, align 4, !dbg !3629
  br label %for.cond285, !dbg !3626

for.cond285:                                      ; preds = %for.inc295, %VITIS_LOOP_795_16
  %277 = load i32, i32* %b, align 4, !dbg !3630
  %cmp286 = icmp ult i32 %277, 2, !dbg !3632
  br i1 %cmp286, label %for.body288, label %for.cond.cleanup287, !dbg !3633

for.cond.cleanup287:                              ; preds = %for.cond285
  store i32 50, i32* %cleanup.dest.slot, align 4
  %278 = bitcast i32* %b to i8*, !dbg !3634
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %278) #31, !dbg !3634
  br label %for.end298

for.body288:                                      ; preds = %for.cond285
  %279 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3635
  %owners289 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %279, i32 0, i32 1, !dbg !3637
  %scorer_old_consumed = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners289, i32 0, i32 4, !dbg !3638
  %280 = load i32, i32* %b, align 4, !dbg !3639
  %idxprom290 = zext i32 %280 to i64, !dbg !3635
  %arrayidx291 = getelementptr inbounds [2 x i16], [2 x i16]* %scorer_old_consumed, i64 0, i64 %idxprom290, !dbg !3635
  store i16 0, i16* %arrayidx291, align 2, !dbg !3640
  %281 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3641
  %owners292 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %281, i32 0, i32 1, !dbg !3642
  %scorer_new_written = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners292, i32 0, i32 5, !dbg !3643
  %282 = load i32, i32* %b, align 4, !dbg !3644
  %idxprom293 = zext i32 %282 to i64, !dbg !3641
  %arrayidx294 = getelementptr inbounds [2 x i16], [2 x i16]* %scorer_new_written, i64 0, i64 %idxprom293, !dbg !3641
  store i16 0, i16* %arrayidx294, align 2, !dbg !3645
  br label %for.inc295, !dbg !3646

for.inc295:                                       ; preds = %for.body288
  %283 = load i32, i32* %b, align 4, !dbg !3647
  %inc296 = add i32 %283, 1, !dbg !3647
  store i32 %inc296, i32* %b, align 4, !dbg !3647
  br label %for.cond285, !dbg !3634, !llvm.loop !3648

for.end298:                                       ; preds = %for.cond.cleanup287
  br label %VITIS_LOOP_799_17, !dbg !3649

VITIS_LOOP_799_17:                                ; preds = %for.end298
  %284 = bitcast [3 x i1]** %__range2299 to i8*, !dbg !3651
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %284) #31, !dbg !3651
  call void @llvm.dbg.declare(metadata [3 x i1]** %__range2299, metadata !3653, metadata !DIExpression()), !dbg !3654
  %285 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3651
  %owners300 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %285, i32 0, i32 1, !dbg !3655
  %type_valid = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners300, i32 0, i32 6, !dbg !3656
  store [3 x i1]* %type_valid, [3 x i1]** %__range2299, align 8, !dbg !3651
  %286 = bitcast i1** %__begin2301 to i8*, !dbg !3657
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %286) #31, !dbg !3657
  call void @llvm.dbg.declare(metadata i1** %__begin2301, metadata !3658, metadata !DIExpression()), !dbg !3654
  %287 = load [3 x i1]*, [3 x i1]** %__range2299, align 8, !dbg !3657
  %arraydecay302 = getelementptr inbounds [3 x i1], [3 x i1]* %287, i64 0, i64 0, !dbg !3657
  store i1* %arraydecay302, i1** %__begin2301, align 8, !dbg !3657
  %288 = bitcast i1** %__end2303 to i8*, !dbg !3657
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %288) #31, !dbg !3657
  call void @llvm.dbg.declare(metadata i1** %__end2303, metadata !3659, metadata !DIExpression()), !dbg !3654
  %289 = load [3 x i1]*, [3 x i1]** %__range2299, align 8, !dbg !3657
  %arraydecay304 = getelementptr inbounds [3 x i1], [3 x i1]* %289, i64 0, i64 0, !dbg !3657
  %add.ptr305 = getelementptr inbounds i1, i1* %arraydecay304, i64 3, !dbg !3657
  store i1* %add.ptr305, i1** %__end2303, align 8, !dbg !3657
  br label %for.cond306, !dbg !3657

for.cond306:                                      ; preds = %for.inc310, %VITIS_LOOP_799_17
  %290 = load i1*, i1** %__begin2301, align 8, !dbg !3657
  %291 = load i1*, i1** %__end2303, align 8, !dbg !3657
  %cmp307 = icmp ne i1* %290, %291, !dbg !3657
  br i1 %cmp307, label %for.body309, label %for.cond.cleanup308, !dbg !3657

for.cond.cleanup308:                              ; preds = %for.cond306
  store i32 54, i32* %cleanup.dest.slot, align 4
  %292 = bitcast i1** %__end2303 to i8*, !dbg !3657
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %292) #31, !dbg !3657
  %293 = bitcast i1** %__begin2301 to i8*, !dbg !3657
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %293) #31, !dbg !3657
  %294 = bitcast [3 x i1]** %__range2299 to i8*, !dbg !3657
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %294) #31, !dbg !3657
  br label %for.end315

for.body309:                                      ; preds = %for.cond306
  %295 = bitcast i1** %v to i8*, !dbg !3660
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %295) #31, !dbg !3660
  call void @llvm.dbg.declare(metadata i1** %v, metadata !3662, metadata !DIExpression()), !dbg !3663
  %296 = load i1*, i1** %__begin2301, align 8, !dbg !3664
  store i1* %296, i1** %v, align 8, !dbg !3663
  %297 = load i1*, i1** %v, align 8, !dbg !3665
  store i1 false, i1* %297, align 1, !dbg !3666
  %298 = bitcast i1** %v to i8*, !dbg !3667
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %298) #31, !dbg !3667
  br label %for.inc310, !dbg !3668

for.inc310:                                       ; preds = %for.body309
  %299 = load i1*, i1** %__begin2301, align 8, !dbg !3657
  %incdec.ptr311 = getelementptr inbounds i1, i1* %299, i32 1, !dbg !3657
  store i1* %incdec.ptr311, i1** %__begin2301, align 8, !dbg !3657
  br label %for.cond306, !dbg !3657, !llvm.loop !3669

for.end315:                                       ; preds = %for.cond.cleanup308
  %300 = bitcast %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316 to i8*, !dbg !3671
  call void @llvm.lifetime.start.p0i8(i64 160, i8* %300) #31, !dbg !3671
  %name = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 0, !dbg !3672
  %arrayinit.begin = getelementptr inbounds [48 x i8], [48 x i8]* %name, i64 0, i64 0, !dbg !3673
  br label %arrayinit.body, !dbg !3673

arrayinit.body:                                   ; preds = %arrayinit.body, %for.end315
  %arrayinit.curidx = phi i64 [ 0, %for.end315 ], [ %arrayinit.nextidx, %arrayinit.body ], !dbg !3673
  %arrayinit.cur = getelementptr inbounds [48 x i8], [48 x i8]* %name, i64 0, i64 %arrayinit.curidx, !dbg !3673
  %arrayinit.nextidx = add i64 %arrayinit.curidx, 1, !dbg !3673
  store i8 0, i8* %arrayinit.cur, align 1, !dbg !3673
  %arrayinit.done = icmp eq i64 %arrayinit.curidx, 47, !dbg !3673
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body, !dbg !3673

arrayinit.end:                                    ; preds = %arrayinit.body
  %key = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 1, !dbg !3672
  %family = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %key, i32 0, i32 0, !dbg !3675
  store i8 0, i8* %family, align 4, !dbg !3675
  %layer = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %key, i32 0, i32 1, !dbg !3675
  store i8 -1, i8* %layer, align 1, !dbg !3675
  %K = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 2, !dbg !3672
  store i16 0, i16* %K, align 2, !dbg !3672
  %N = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 3, !dbg !3672
  store i16 0, i16* %N, align 4, !dbg !3672
  %dtype = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 4, !dbg !3672
  store i8 0, i8* %dtype, align 2, !dbg !3672
  %bias_kind = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 5, !dbg !3672
  store i8 0, i8* %bias_kind, align 1, !dbg !3672
  %q_base = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 6, !dbg !3672
  %arrayinit.begin317 = getelementptr inbounds [2 x i32], [2 x i32]* %q_base, i64 0, i64 0, !dbg !3677
  br label %arrayinit.body318, !dbg !3677

arrayinit.body318:                                ; preds = %arrayinit.body318, %arrayinit.end
  %arrayinit.curidx319 = phi i64 [ 0, %arrayinit.end ], [ %arrayinit.nextidx321, %arrayinit.body318 ], !dbg !3677
  %arrayinit.cur320 = getelementptr inbounds [2 x i32], [2 x i32]* %q_base, i64 0, i64 %arrayinit.curidx319, !dbg !3677
  %arrayinit.nextidx321 = add i64 %arrayinit.curidx319, 1, !dbg !3677
  store i32 0, i32* %arrayinit.cur320, align 4, !dbg !3677
  %arrayinit.done322 = icmp eq i64 %arrayinit.curidx319, 1, !dbg !3677
  br i1 %arrayinit.done322, label %arrayinit.end323, label %arrayinit.body318, !dbg !3677

arrayinit.end323:                                 ; preds = %arrayinit.body318
  %q_span = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 7, !dbg !3672
  %arrayinit.begin324 = getelementptr inbounds [2 x i32], [2 x i32]* %q_span, i64 0, i64 0, !dbg !3678
  br label %arrayinit.body325, !dbg !3678

arrayinit.body325:                                ; preds = %arrayinit.body325, %arrayinit.end323
  %arrayinit.curidx326 = phi i64 [ 0, %arrayinit.end323 ], [ %arrayinit.nextidx328, %arrayinit.body325 ], !dbg !3678
  %arrayinit.cur327 = getelementptr inbounds [2 x i32], [2 x i32]* %q_span, i64 0, i64 %arrayinit.curidx326, !dbg !3678
  %arrayinit.nextidx328 = add i64 %arrayinit.curidx326, 1, !dbg !3678
  store i32 0, i32* %arrayinit.cur327, align 4, !dbg !3678
  %arrayinit.done329 = icmp eq i64 %arrayinit.curidx326, 1, !dbg !3678
  br i1 %arrayinit.done329, label %arrayinit.end330, label %arrayinit.body325, !dbg !3678

arrayinit.end330:                                 ; preds = %arrayinit.body325
  %scale_base = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 8, !dbg !3672
  store i32 0, i32* %scale_base, align 4, !dbg !3672
  %scale_span = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 9, !dbg !3672
  store i32 0, i32* %scale_span, align 4, !dbg !3672
  %aux_base = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 10, !dbg !3672
  store i32 0, i32* %aux_base, align 4, !dbg !3672
  %aux_span = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 11, !dbg !3672
  store i32 0, i32* %aux_span, align 4, !dbg !3672
  %bias_base = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 12, !dbg !3672
  store i32 0, i32* %bias_base, align 4, !dbg !3672
  %bias_span = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 13, !dbg !3672
  store i32 0, i32* %bias_span, align 4, !dbg !3672
  %source_sha256 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 14, !dbg !3672
  %arrayinit.begin331 = getelementptr inbounds [32 x i8], [32 x i8]* %source_sha256, i64 0, i64 0, !dbg !3679
  br label %arrayinit.body332, !dbg !3679

arrayinit.body332:                                ; preds = %arrayinit.body332, %arrayinit.end330
  %arrayinit.curidx333 = phi i64 [ 0, %arrayinit.end330 ], [ %arrayinit.nextidx335, %arrayinit.body332 ], !dbg !3679
  %arrayinit.cur334 = getelementptr inbounds [32 x i8], [32 x i8]* %source_sha256, i64 0, i64 %arrayinit.curidx333, !dbg !3679
  %arrayinit.nextidx335 = add i64 %arrayinit.curidx333, 1, !dbg !3679
  store i8 0, i8* %arrayinit.cur334, align 1, !dbg !3679
  %arrayinit.done336 = icmp eq i64 %arrayinit.curidx333, 31, !dbg !3679
  br i1 %arrayinit.done336, label %arrayinit.end337, label %arrayinit.body332, !dbg !3679

arrayinit.end337:                                 ; preds = %arrayinit.body332
  %bias_sha256 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, i32 0, i32 15, !dbg !3672
  %arrayinit.begin338 = getelementptr inbounds [32 x i8], [32 x i8]* %bias_sha256, i64 0, i64 0, !dbg !3680
  br label %arrayinit.body339, !dbg !3680

arrayinit.body339:                                ; preds = %arrayinit.body339, %arrayinit.end337
  %arrayinit.curidx340 = phi i64 [ 0, %arrayinit.end337 ], [ %arrayinit.nextidx342, %arrayinit.body339 ], !dbg !3680
  %arrayinit.cur341 = getelementptr inbounds [32 x i8], [32 x i8]* %bias_sha256, i64 0, i64 %arrayinit.curidx340, !dbg !3680
  %arrayinit.nextidx342 = add i64 %arrayinit.curidx340, 1, !dbg !3680
  store i8 0, i8* %arrayinit.cur341, align 1, !dbg !3680
  %arrayinit.done343 = icmp eq i64 %arrayinit.curidx340, 31, !dbg !3680
  br i1 %arrayinit.done343, label %arrayinit.end344, label %arrayinit.body339, !dbg !3680

arrayinit.end344:                                 ; preds = %arrayinit.body339
  %301 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3681
  %current_weight = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %301, i32 0, i32 3, !dbg !3682
  %302 = load %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316, align 4, !dbg !3683
  store %"struct.laya::full::FullWeightDescriptor" %302, %"struct.laya::full::FullWeightDescriptor"* %current_weight, align 8, !dbg !3683
  %303 = bitcast %"struct.laya::full::FullWeightDescriptor"* %ref.tmp316 to i8*, !dbg !3684
  call void @llvm.lifetime.end.p0i8(i64 160, i8* %303) #31, !dbg !3684
  %304 = bitcast %"struct.laya::BufferRef"* %ref.tmp345 to i8*, !dbg !3685
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %304) #31, !dbg !3685
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp345), !dbg !3685
  %305 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3686
  %current_weight_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %305, i32 0, i32 4, !dbg !3687
  %306 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp345, align 4, !dbg !3688
  store %"struct.laya::BufferRef" %306, %"struct.laya::BufferRef"* %current_weight_ref, align 8, !dbg !3688
  %307 = bitcast %"struct.laya::BufferRef"* %ref.tmp345 to i8*, !dbg !3686
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %307) #31, !dbg !3686
  %308 = bitcast %"struct.laya::BufferRef"* %ref.tmp346 to i8*, !dbg !3689
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %308) #31, !dbg !3689
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp346), !dbg !3689
  %309 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3690
  %loaded_gamma_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %309, i32 0, i32 5, !dbg !3691
  %arrayidx347 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %loaded_gamma_ref, i64 0, i64 0, !dbg !3690
  %310 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp346, align 4, !dbg !3692
  store %"struct.laya::BufferRef" %310, %"struct.laya::BufferRef"* %arrayidx347, align 8, !dbg !3692
  %311 = bitcast %"struct.laya::BufferRef"* %ref.tmp346 to i8*, !dbg !3690
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %311) #31, !dbg !3690
  %312 = bitcast %"struct.laya::BufferRef"* %ref.tmp348 to i8*, !dbg !3693
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %312) #31, !dbg !3693
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp348), !dbg !3693
  %313 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3694
  %loaded_gamma_ref349 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %313, i32 0, i32 5, !dbg !3695
  %arrayidx350 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %loaded_gamma_ref349, i64 0, i64 1, !dbg !3694
  %314 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp348, align 4, !dbg !3696
  store %"struct.laya::BufferRef" %314, %"struct.laya::BufferRef"* %arrayidx350, align 8, !dbg !3696
  %315 = bitcast %"struct.laya::BufferRef"* %ref.tmp348 to i8*, !dbg !3694
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %315) #31, !dbg !3694
  %316 = bitcast %"struct.laya::BufferRef"* %ref.tmp351 to i8*, !dbg !3697
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %316) #31, !dbg !3697
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp351), !dbg !3697
  %317 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3698
  %final_qkv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %317, i32 0, i32 6, !dbg !3699
  %arrayidx352 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref, i64 0, i64 0, !dbg !3698
  %318 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp351, align 4, !dbg !3700
  store %"struct.laya::BufferRef" %318, %"struct.laya::BufferRef"* %arrayidx352, align 8, !dbg !3700
  %319 = bitcast %"struct.laya::BufferRef"* %ref.tmp351 to i8*, !dbg !3698
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %319) #31, !dbg !3698
  %320 = bitcast %"struct.laya::BufferRef"* %ref.tmp353 to i8*, !dbg !3701
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %320) #31, !dbg !3701
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp353), !dbg !3701
  %321 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3702
  %final_qkv_ref354 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %321, i32 0, i32 6, !dbg !3703
  %arrayidx355 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref354, i64 0, i64 1, !dbg !3702
  %322 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp353, align 4, !dbg !3704
  store %"struct.laya::BufferRef" %322, %"struct.laya::BufferRef"* %arrayidx355, align 8, !dbg !3704
  %323 = bitcast %"struct.laya::BufferRef"* %ref.tmp353 to i8*, !dbg !3702
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %323) #31, !dbg !3702
  %324 = bitcast %"struct.laya::BufferRef"* %ref.tmp356 to i8*, !dbg !3705
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %324) #31, !dbg !3705
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp356), !dbg !3705
  %325 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3706
  %loaded_kv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %325, i32 0, i32 7, !dbg !3707
  %326 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp356, align 4, !dbg !3708
  store %"struct.laya::BufferRef" %326, %"struct.laya::BufferRef"* %loaded_kv_ref, align 8, !dbg !3708
  %327 = bitcast %"struct.laya::BufferRef"* %ref.tmp356 to i8*, !dbg !3706
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %327) #31, !dbg !3706
  %328 = bitcast %"struct.laya::BufferRef"* %ref.tmp357 to i8*, !dbg !3709
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %328) #31, !dbg !3709
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp357), !dbg !3709
  %329 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3710
  %loaded_rope_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %329, i32 0, i32 8, !dbg !3711
  %330 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp357, align 4, !dbg !3712
  store %"struct.laya::BufferRef" %330, %"struct.laya::BufferRef"* %loaded_rope_ref, align 8, !dbg !3712
  %331 = bitcast %"struct.laya::BufferRef"* %ref.tmp357 to i8*, !dbg !3710
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %331) #31, !dbg !3710
  %332 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3713
  %loaded_rope_mode = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %332, i32 0, i32 22, !dbg !3714
  store i8 -1, i8* %loaded_rope_mode, align 1, !dbg !3715
  %333 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3716
  %loaded_kv_head = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %333, i32 0, i32 23, !dbg !3717
  store i8 -1, i8* %loaded_kv_head, align 2, !dbg !3718
  %334 = bitcast %"struct.laya::BufferRef"* %ref.tmp358 to i8*, !dbg !3719
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %334) #31, !dbg !3719
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp358), !dbg !3719
  %335 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3720
  %score_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %335, i32 0, i32 9, !dbg !3721
  %336 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp358, align 4, !dbg !3722
  store %"struct.laya::BufferRef" %336, %"struct.laya::BufferRef"* %score_ref, align 8, !dbg !3722
  %337 = bitcast %"struct.laya::BufferRef"* %ref.tmp358 to i8*, !dbg !3720
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %337) #31, !dbg !3720
  %338 = bitcast %"struct.laya::BufferRef"* %ref.tmp359 to i8*, !dbg !3723
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %338) #31, !dbg !3723
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp359), !dbg !3723
  %339 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3724
  %score_kv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %339, i32 0, i32 10, !dbg !3725
  %340 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp359, align 4, !dbg !3726
  store %"struct.laya::BufferRef" %340, %"struct.laya::BufferRef"* %score_kv_ref, align 8, !dbg !3726
  %341 = bitcast %"struct.laya::BufferRef"* %ref.tmp359 to i8*, !dbg !3724
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %341) #31, !dbg !3724
  %342 = bitcast %"struct.laya::BufferRef"* %ref.tmp360 to i8*, !dbg !3727
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %342) #31, !dbg !3727
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp360), !dbg !3727
  %343 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3728
  %score_qkv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %343, i32 0, i32 11, !dbg !3729
  %arrayidx361 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %score_qkv_ref, i64 0, i64 0, !dbg !3728
  %344 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp360, align 4, !dbg !3730
  store %"struct.laya::BufferRef" %344, %"struct.laya::BufferRef"* %arrayidx361, align 8, !dbg !3730
  %345 = bitcast %"struct.laya::BufferRef"* %ref.tmp360 to i8*, !dbg !3728
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %345) #31, !dbg !3728
  %346 = bitcast %"struct.laya::BufferRef"* %ref.tmp362 to i8*, !dbg !3731
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %346) #31, !dbg !3731
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp362), !dbg !3731
  %347 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3732
  %score_qkv_ref363 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %347, i32 0, i32 11, !dbg !3733
  %arrayidx364 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %score_qkv_ref363, i64 0, i64 1, !dbg !3732
  %348 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp362, align 4, !dbg !3734
  store %"struct.laya::BufferRef" %348, %"struct.laya::BufferRef"* %arrayidx364, align 8, !dbg !3734
  %349 = bitcast %"struct.laya::BufferRef"* %ref.tmp362 to i8*, !dbg !3732
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %349) #31, !dbg !3732
  %350 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3735
  %score_head = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %350, i32 0, i32 12, !dbg !3736
  store i8 -1, i8* %score_head, align 8, !dbg !3737
  %351 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3738
  %score_batch = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %351, i32 0, i32 15, !dbg !3739
  store i8 -1, i8* %score_batch, align 1, !dbg !3740
  %352 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3741
  %score_rows = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %352, i32 0, i32 16, !dbg !3742
  store i8 0, i8* %score_rows, align 4, !dbg !3743
  %353 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3744
  %score_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %353, i32 0, i32 18, !dbg !3745
  store i1 false, i1* %score_valid, align 8, !dbg !3746
  %354 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3747
  %cache365 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %354, i32 0, i32 2, !dbg !3748
  %activation_meta366 = getelementptr inbounds %"struct.laya::full::FullCache", %"struct.laya::full::FullCache"* %cache365, i32 0, i32 1, !dbg !3749
  call void @_ZN4laya16numeric_reset_a8ERNS_10A8TileMetaE(%"struct.laya::A8TileMeta"* nonnull align 8 dereferenceable(752) %activation_meta366), !dbg !3750
  %355 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3751
  %cache367 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %355, i32 0, i32 2, !dbg !3752
  %activation_source_ledger = getelementptr inbounds %"struct.laya::full::FullCache", %"struct.laya::full::FullCache"* %cache367, i32 0, i32 0, !dbg !3753
  call void @_ZN4laya17numeric_reset_f32ERNS_11F32TileMetaE(%"struct.laya::F32TileMeta"* nonnull align 8 dereferenceable(376) %activation_source_ledger), !dbg !3754
  %356 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3755
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %356, i32 0, i32 42, !dbg !3756
  store i1 false, i1* %request_valid, align 8, !dbg !3757
  %357 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3758
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %357, i32 0, i32 43, !dbg !3759
  store i1 false, i1* %model_header_valid, align 1, !dbg !3760
  %358 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp368 to i8*, !dbg !3761
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %358) #31, !dbg !3761
  %ref369 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 0, !dbg !3762
  %id370 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref369, i32 0, i32 0, !dbg !3763
  store i8 0, i8* %id370, align 4, !dbg !3763
  %bank371 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref369, i32 0, i32 1, !dbg !3763
  store i8 0, i8* %bank371, align 1, !dbg !3763
  %epoch372 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref369, i32 0, i32 2, !dbg !3763
  store i32 0, i32* %epoch372, align 4, !dbg !3763
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 1, !dbg !3762
  store i8 0, i8* %region, align 4, !dbg !3762
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 2, !dbg !3762
  store i8 0, i8* %stage, align 1, !dbg !3762
  %layer373 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 3, !dbg !3762
  store i8 -1, i8* %layer373, align 2, !dbg !3762
  %batch374 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 4, !dbg !3762
  store i8 -1, i8* %batch374, align 1, !dbg !3762
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 5, !dbg !3762
  store i8 0, i8* %row_space, align 4, !dbg !3762
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 6, !dbg !3762
  store i16 0, i16* %row0, align 2, !dbg !3762
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 7, !dbg !3762
  store i16 0, i16* %rows, align 4, !dbg !3762
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 8, !dbg !3762
  store i16 0, i16* %width, align 2, !dbg !3762
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, i32 0, i32 9, !dbg !3762
  store i8 0, i8* %content, align 4, !dbg !3762
  %359 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3764
  %expected_quant_source = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %359, i32 0, i32 19, !dbg !3765
  %360 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp368, align 4, !dbg !3766
  store %"struct.laya::full::FullOwnerSpec" %360, %"struct.laya::full::FullOwnerSpec"* %expected_quant_source, align 4, !dbg !3766
  %361 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp368 to i8*, !dbg !3764
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %361) #31, !dbg !3764
  %362 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3767
  %expected_quant_source_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %362, i32 0, i32 44, !dbg !3768
  store i1 false, i1* %expected_quant_source_valid, align 2, !dbg !3769
  %363 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3770
  %expected_task_source_count = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %363, i32 0, i32 21, !dbg !3771
  store i8 0, i8* %expected_task_source_count, align 4, !dbg !3772
  %364 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3773
  %last_task_id = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %364, i32 0, i32 24, !dbg !3774
  store i32 0, i32* %last_task_id, align 8, !dbg !3775
  %365 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3776
  %tasks_retired = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %365, i32 0, i32 25, !dbg !3777
  store i32 0, i32* %tasks_retired, align 4, !dbg !3778
  br label %VITIS_LOOP_827_18, !dbg !3776

VITIS_LOOP_827_18:                                ; preds = %arrayinit.end344
  %366 = bitcast [256 x i32]** %__range2375 to i8*, !dbg !3779
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %366) #31, !dbg !3779
  call void @llvm.dbg.declare(metadata [256 x i32]** %__range2375, metadata !3781, metadata !DIExpression()), !dbg !3783
  %367 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3779
  %op_calls = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %367, i32 0, i32 26, !dbg !3784
  store [256 x i32]* %op_calls, [256 x i32]** %__range2375, align 8, !dbg !3779
  %368 = bitcast i32** %__begin2376 to i8*, !dbg !3785
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %368) #31, !dbg !3785
  call void @llvm.dbg.declare(metadata i32** %__begin2376, metadata !3786, metadata !DIExpression()), !dbg !3783
  %369 = load [256 x i32]*, [256 x i32]** %__range2375, align 8, !dbg !3785
  %arraydecay377 = getelementptr inbounds [256 x i32], [256 x i32]* %369, i64 0, i64 0, !dbg !3785
  store i32* %arraydecay377, i32** %__begin2376, align 8, !dbg !3785
  %370 = bitcast i32** %__end2378 to i8*, !dbg !3785
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %370) #31, !dbg !3785
  call void @llvm.dbg.declare(metadata i32** %__end2378, metadata !3787, metadata !DIExpression()), !dbg !3783
  %371 = load [256 x i32]*, [256 x i32]** %__range2375, align 8, !dbg !3785
  %arraydecay379 = getelementptr inbounds [256 x i32], [256 x i32]* %371, i64 0, i64 0, !dbg !3785
  %add.ptr380 = getelementptr inbounds i32, i32* %arraydecay379, i64 256, !dbg !3785
  store i32* %add.ptr380, i32** %__end2378, align 8, !dbg !3785
  br label %for.cond381, !dbg !3785

for.cond381:                                      ; preds = %for.inc385, %VITIS_LOOP_827_18
  %372 = load i32*, i32** %__begin2376, align 8, !dbg !3785
  %373 = load i32*, i32** %__end2378, align 8, !dbg !3785
  %cmp382 = icmp ne i32* %372, %373, !dbg !3785
  br i1 %cmp382, label %for.body384, label %for.cond.cleanup383, !dbg !3785

for.cond.cleanup383:                              ; preds = %for.cond381
  store i32 57, i32* %cleanup.dest.slot, align 4
  %374 = bitcast i32** %__end2378 to i8*, !dbg !3785
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %374) #31, !dbg !3785
  %375 = bitcast i32** %__begin2376 to i8*, !dbg !3785
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %375) #31, !dbg !3785
  %376 = bitcast [256 x i32]** %__range2375 to i8*, !dbg !3785
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %376) #31, !dbg !3785
  br label %for.end390

for.body384:                                      ; preds = %for.cond381
  %377 = bitcast i32** %count to i8*, !dbg !3788
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %377) #31, !dbg !3788
  call void @llvm.dbg.declare(metadata i32** %count, metadata !3790, metadata !DIExpression()), !dbg !3791
  %378 = load i32*, i32** %__begin2376, align 8, !dbg !3792
  store i32* %378, i32** %count, align 8, !dbg !3791
  %379 = load i32*, i32** %count, align 8, !dbg !3793
  store i32 0, i32* %379, align 4, !dbg !3794
  %380 = bitcast i32** %count to i8*, !dbg !3795
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %380) #31, !dbg !3795
  br label %for.inc385, !dbg !3796

for.inc385:                                       ; preds = %for.body384
  %381 = load i32*, i32** %__begin2376, align 8, !dbg !3785
  %incdec.ptr386 = getelementptr inbounds i32, i32* %381, i32 1, !dbg !3785
  store i32* %incdec.ptr386, i32** %__begin2376, align 8, !dbg !3785
  br label %for.cond381, !dbg !3785, !llvm.loop !3797

for.end390:                                       ; preds = %for.cond.cleanup383
  %382 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3799
  %owner_claims = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %382, i32 0, i32 27, !dbg !3800
  store i32 0, i32* %owner_claims, align 8, !dbg !3801
  %383 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3802
  %owner_leases = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %383, i32 0, i32 28, !dbg !3803
  store i32 0, i32* %owner_leases, align 4, !dbg !3804
  %384 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3805
  %encoder_layers_completed = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %384, i32 0, i32 29, !dbg !3806
  store i8 0, i8* %encoder_layers_completed, align 8, !dbg !3807
  %385 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3808
  %decision_layers_completed = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %385, i32 0, i32 30, !dbg !3809
  store i8 0, i8* %decision_layers_completed, align 1, !dbg !3810
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !3811
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup391, !dbg !3812

cleanup391:                                       ; preds = %for.end390, %if.then25
  %386 = bitcast %"struct.laya::BufferRef"* %numeric_ref to i8*, !dbg !3813
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %386) #31, !dbg !3813
  %387 = bitcast i32* %a8_index to i8*, !dbg !3813
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %387) #31, !dbg !3813
  br label %return

return:                                           ; preds = %cleanup391, %cleanup11
  ret void, !dbg !3813

unreachable:                                      ; preds = %cleanup11
  unreachable
}

; Function Attrs: nounwind
define dso_local void @_ZN4laya4full15full_soft_resetERNS0_11FullRuntimeEm(%"struct.laya::Check"* noalias sret(%"struct.laya::Check") align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, i64 %new_generation) #26 !dbg !3814 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %new_generation.addr = alloca i64, align 8
  %c = alloca %"struct.laya::Check", align 8
  %cleanup.dest.slot = alloca i32, align 4
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !3817, metadata !DIExpression()), !dbg !3818
  store i64 %new_generation, i64* %new_generation.addr, align 8
  call void @llvm.dbg.declare(metadata i64* %new_generation.addr, metadata !3819, metadata !DIExpression()), !dbg !3820
  %0 = load i64, i64* %new_generation.addr, align 8, !dbg !3821
  %tobool = icmp ne i64 %0, 0, !dbg !3821
  br i1 %tobool, label %lor.lhs.false, label %if.then, !dbg !3823

lor.lhs.false:                                    ; preds = %entry
  %1 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3824
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %1, i32 0, i32 0, !dbg !3825
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !3826
  %generation = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 1, !dbg !3827
  %2 = load i64, i64* %generation, align 8, !dbg !3827
  %tobool1 = icmp ne i64 %2, 0, !dbg !3824
  br i1 %tobool1, label %land.lhs.true, label %if.end, !dbg !3828

land.lhs.true:                                    ; preds = %lor.lhs.false
  %3 = load i64, i64* %new_generation.addr, align 8, !dbg !3829
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3830
  %inputs2 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %4, i32 0, i32 0, !dbg !3831
  %identity3 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs2, i32 0, i32 0, !dbg !3832
  %generation4 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity3, i32 0, i32 1, !dbg !3833
  %5 = load i64, i64* %generation4, align 8, !dbg !3833
  %cmp = icmp ule i64 %3, %5, !dbg !3834
  br i1 %cmp, label %if.then, label %if.end, !dbg !3835

if.then:                                          ; preds = %land.lhs.true, %entry
  call void @_ZN4laya4full12_GLOBAL__N_18protocolEt(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result, i16 zeroext 4), !dbg !3836
  br label %return, !dbg !3837

if.end:                                           ; preds = %land.lhs.true, %lor.lhs.false
  %6 = bitcast %"struct.laya::Check"* %c to i8*, !dbg !3838
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %6) #31, !dbg !3838
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %c, metadata !3839, metadata !DIExpression()), !dbg !3840
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3841
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %c, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %7), !dbg !3842
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !3843
  br i1 %call, label %if.end6, label %if.then5, !dbg !3845

if.then5:                                         ; preds = %if.end
  %8 = load %"struct.laya::Check", %"struct.laya::Check"* %c, align 8, !dbg !3846
  store %"struct.laya::Check" %8, %"struct.laya::Check"* %agg.result, align 8, !dbg !3846
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3847

if.end6:                                          ; preds = %if.end
  %9 = load i64, i64* %new_generation.addr, align 8, !dbg !3848
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3849
  %inputs7 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %10, i32 0, i32 0, !dbg !3850
  %identity8 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs7, i32 0, i32 0, !dbg !3851
  %generation9 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity8, i32 0, i32 1, !dbg !3852
  store i64 %9, i64* %generation9, align 8, !dbg !3853
  %11 = load i64, i64* %new_generation.addr, align 8, !dbg !3854
  %12 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3855
  %session_generation = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %12, i32 0, i32 31, !dbg !3856
  store i64 %11, i64* %session_generation, align 8, !dbg !3857
  %13 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !3858
  %last_accepted_request_id = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %13, i32 0, i32 32, !dbg !3859
  store i64 0, i64* %last_accepted_request_id, align 8, !dbg !3860
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %agg.result), !dbg !3861
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !3862

cleanup:                                          ; preds = %if.end6, %if.then5
  %14 = bitcast %"struct.laya::Check"* %c to i8*, !dbg !3863
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %14) #31, !dbg !3863
  br label %return

return:                                           ; preds = %cleanup, %if.then
  ret void, !dbg !3863
}

; Function Attrs: nounwind
define dso_local void @full_owner_index_pilot(i8 zeroext %operation, i32* %status, i32* %slot0_epoch, i32* %slot1_epoch, i32* %slot2_epoch, i32* %numeric_epoch, i32* %claims, i32* %slot0_coverage, i32* %slot2_id, i32* %request_high, i32* %generation) #27 !dbg !3864 !fpga.function.pragma !3867 {
entry:
  %operation.addr = alloca i8, align 1
  %status.addr = alloca i32*, align 8
  %slot0_epoch.addr = alloca i32*, align 8
  %slot1_epoch.addr = alloca i32*, align 8
  %slot2_epoch.addr = alloca i32*, align 8
  %numeric_epoch.addr = alloca i32*, align 8
  %claims.addr = alloca i32*, align 8
  %slot0_coverage.addr = alloca i32*, align 8
  %slot2_id.addr = alloca i32*, align 8
  %request_high.addr = alloca i32*, align 8
  %generation.addr = alloca i32*, align 8
  %result = alloca %"struct.laya::Check", align 8
  %pair = alloca [2 x %"struct.laya::full::FullOwnerSpec"], align 4
  %ref.tmp = alloca %"struct.laya::Check", align 8
  %ref.tmp3 = alloca %"struct.laya::Check", align 8
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %pair5 = alloca [2 x %"struct.laya::full::FullOwnerSpec"], align 4
  %ref.tmp8 = alloca %"struct.laya::Check", align 8
  %ref.tmp10 = alloca %"struct.laya::Check", align 8
  %ref.tmp12 = alloca %"struct.laya::Check", align 8
  %agg.tmp13 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp18 = alloca %"struct.laya::Check", align 8
  %i = alloca i32, align 4
  %ref.tmp20 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp24 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp28 = alloca %"struct.laya::Check", align 8
  %i30 = alloca i32, align 4
  %ref.tmp35 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp42 = alloca %"struct.laya::Check", align 8
  %ref.tmp44 = alloca %"struct.laya::Check", align 8
  %ref.tmp45 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp47 = alloca %"struct.laya::Check", align 8
  %agg.tmp48 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp52 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp53 = alloca %"struct.laya::Check", align 8
  %ref.tmp55 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp59 = alloca %"struct.laya::Check", align 8
  %ref.tmp61 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp65 = alloca %"struct.laya::Check", align 8
  %ref.tmp67 = alloca %"struct.laya::Check", align 8
  %ref.tmp68 = alloca %"struct.laya::Check", align 8
  store i8 %operation, i8* %operation.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %operation.addr, metadata !3870, metadata !DIExpression()), !dbg !3871
  store i32* %status, i32** %status.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %status.addr, metadata !3872, metadata !DIExpression()), !dbg !3873
  store i32* %slot0_epoch, i32** %slot0_epoch.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %slot0_epoch.addr, metadata !3874, metadata !DIExpression()), !dbg !3875
  store i32* %slot1_epoch, i32** %slot1_epoch.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %slot1_epoch.addr, metadata !3876, metadata !DIExpression()), !dbg !3877
  store i32* %slot2_epoch, i32** %slot2_epoch.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %slot2_epoch.addr, metadata !3878, metadata !DIExpression()), !dbg !3879
  store i32* %numeric_epoch, i32** %numeric_epoch.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %numeric_epoch.addr, metadata !3880, metadata !DIExpression()), !dbg !3881
  store i32* %claims, i32** %claims.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %claims.addr, metadata !3882, metadata !DIExpression()), !dbg !3883
  store i32* %slot0_coverage, i32** %slot0_coverage.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %slot0_coverage.addr, metadata !3884, metadata !DIExpression()), !dbg !3885
  store i32* %slot2_id, i32** %slot2_id.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %slot2_id.addr, metadata !3886, metadata !DIExpression()), !dbg !3887
  store i32* %request_high, i32** %request_high.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %request_high.addr, metadata !3888, metadata !DIExpression()), !dbg !3889
  store i32* %generation, i32** %generation.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %generation.addr, metadata !3890, metadata !DIExpression()), !dbg !3891
  call void @llvm.sideeffect() #32 [ "xlx_s_axilite"(i8 %operation, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3892
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %status, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3893
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %slot0_epoch, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3894
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %slot1_epoch, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3895
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %slot2_epoch, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3896
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %numeric_epoch, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3897
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %claims, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3898
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %slot0_coverage, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3899
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %slot2_id, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3900
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %request_high, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3901
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i32* %generation, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3902
  call void @llvm.sideeffect() #33 [ "xlx_s_axilite"(i8* null, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3903
  %0 = bitcast %"struct.laya::Check"* %result to i8*, !dbg !3904
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %0) #31, !dbg !3904
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %result, metadata !3905, metadata !DIExpression()), !dbg !3906
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %result), !dbg !3907
  %1 = load i8, i8* %operation.addr, align 1, !dbg !3908
  %conv = zext i8 %1 to i32, !dbg !3908
  switch i32 %conv, label %sw.default [
    i32 0, label %sw.bb
    i32 1, label %sw.bb1
    i32 2, label %sw.bb2
    i32 3, label %sw.bb4
    i32 4, label %sw.bb9
    i32 5, label %sw.bb11
    i32 6, label %sw.bb17
    i32 7, label %sw.bb19
    i32 8, label %sw.bb29
    i32 9, label %sw.bb43
    i32 10, label %sw.bb46
    i32 11, label %sw.bb54
    i32 12, label %sw.bb60
    i32 13, label %sw.bb66
  ], !dbg !3909

sw.bb:                                            ; preds = %entry
  store i64 10, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 0), align 8, !dbg !3910
  store i64 1, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 1), align 8, !dbg !3912
  store i16 1, i16* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 2), align 8, !dbg !3913
  store i16 64, i16* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 3), align 2, !dbg !3914
  store i8 1, i8* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 4, i64 0), align 4, !dbg !3915
  store i8 2, i8* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 5, i64 0), align 4, !dbg !3916
  store i8 3, i8* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 6, i64 0), align 4, !dbg !3917
  store i8 4, i8* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 0, i32 0, i32 7, i64 0), align 4, !dbg !3918
  store i64 1, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 31), align 8, !dbg !3919
  store i64 10, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 32), align 8, !dbg !3920
  store i1 true, i1* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 42), align 8, !dbg !3921
  store i1 true, i1* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 43), align 1, !dbg !3922
  br label %sw.epilog, !dbg !3923

sw.bb1:                                           ; preds = %entry
  %2 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair to i8*, !dbg !3924
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %2) #31, !dbg !3924
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, metadata !3926, metadata !DIExpression()), !dbg !3927
  %arrayinit.begin = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 0, !dbg !3928
  call void @_ZN12_GLOBAL__N_18qkv_specEhj(%"struct.laya::full::FullOwnerSpec"* sret(%"struct.laya::full::FullOwnerSpec") align 4 %arrayinit.begin, i8 zeroext 0, i32 1), !dbg !3929
  %arrayinit.element = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayinit.begin, i64 1, !dbg !3928
  call void @_ZN12_GLOBAL__N_18qkv_specEhj(%"struct.laya::full::FullOwnerSpec"* sret(%"struct.laya::full::FullOwnerSpec") align 4 %arrayinit.element, i8 zeroext 1, i32 1), !dbg !3930
  %3 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !3931
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %3) #31, !dbg !3931
  call void @_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %pair), !dbg !3931
  %4 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp, align 8, !dbg !3932
  store %"struct.laya::Check" %4, %"struct.laya::Check"* %result, align 8, !dbg !3932
  %5 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !3933
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %5) #31, !dbg !3933
  %6 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair to i8*, !dbg !3934
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %6) #31, !dbg !3934
  br label %sw.epilog

sw.bb2:                                           ; preds = %entry
  %7 = bitcast %"struct.laya::Check"* %ref.tmp3 to i8*, !dbg !3935
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %7) #31, !dbg !3935
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 0, !dbg !3936
  store i8 5, i8* %id, align 4, !dbg !3936
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 1, !dbg !3936
  store i8 0, i8* %bank, align 1, !dbg !3936
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp, i32 0, i32 2, !dbg !3936
  store i32 1, i32* %epoch, align 4, !dbg !3936
  call void @_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp3, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp, i8 zeroext 0), !dbg !3935
  %8 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp3, align 8, !dbg !3937
  store %"struct.laya::Check" %8, %"struct.laya::Check"* %result, align 8, !dbg !3937
  %9 = bitcast %"struct.laya::Check"* %ref.tmp3 to i8*, !dbg !3938
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %9) #31, !dbg !3938
  br label %sw.epilog, !dbg !3939

sw.bb4:                                           ; preds = %entry
  %10 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair5 to i8*, !dbg !3940
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %10) #31, !dbg !3940
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]* %pair5, metadata !3942, metadata !DIExpression()), !dbg !3943
  %arrayinit.begin6 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair5, i64 0, i64 0, !dbg !3944
  call void @_ZN12_GLOBAL__N_18qkv_specEhj(%"struct.laya::full::FullOwnerSpec"* sret(%"struct.laya::full::FullOwnerSpec") align 4 %arrayinit.begin6, i8 zeroext 0, i32 2), !dbg !3945
  %arrayinit.element7 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayinit.begin6, i64 1, !dbg !3944
  call void @_ZN12_GLOBAL__N_18qkv_specEhj(%"struct.laya::full::FullOwnerSpec"* sret(%"struct.laya::full::FullOwnerSpec") align 4 %arrayinit.element7, i8 zeroext 1, i32 2), !dbg !3946
  %11 = bitcast %"struct.laya::Check"* %ref.tmp8 to i8*, !dbg !3947
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %11) #31, !dbg !3947
  call void @_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp8, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %pair5), !dbg !3947
  %12 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp8, align 8, !dbg !3948
  store %"struct.laya::Check" %12, %"struct.laya::Check"* %result, align 8, !dbg !3948
  %13 = bitcast %"struct.laya::Check"* %ref.tmp8 to i8*, !dbg !3949
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %13) #31, !dbg !3949
  %14 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair5 to i8*, !dbg !3950
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %14) #31, !dbg !3950
  br label %sw.epilog

sw.bb9:                                           ; preds = %entry
  %15 = bitcast %"struct.laya::Check"* %ref.tmp10 to i8*, !dbg !3951
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %15) #31, !dbg !3951
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp10, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !3951
  %16 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp10, align 8, !dbg !3952
  store %"struct.laya::Check" %16, %"struct.laya::Check"* %result, align 8, !dbg !3952
  %17 = bitcast %"struct.laya::Check"* %ref.tmp10 to i8*, !dbg !3953
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %17) #31, !dbg !3953
  br label %sw.epilog, !dbg !3954

sw.bb11:                                          ; preds = %entry
  %18 = bitcast %"struct.laya::Check"* %ref.tmp12 to i8*, !dbg !3955
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %18) #31, !dbg !3955
  %id14 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp13, i32 0, i32 0, !dbg !3956
  store i8 5, i8* %id14, align 4, !dbg !3956
  %bank15 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp13, i32 0, i32 1, !dbg !3956
  store i8 1, i8* %bank15, align 1, !dbg !3956
  %epoch16 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp13, i32 0, i32 2, !dbg !3956
  store i32 1, i32* %epoch16, align 4, !dbg !3956
  call void @_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp12, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp13, i8 zeroext 0), !dbg !3955
  %19 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp12, align 8, !dbg !3957
  store %"struct.laya::Check" %19, %"struct.laya::Check"* %result, align 8, !dbg !3957
  %20 = bitcast %"struct.laya::Check"* %ref.tmp12 to i8*, !dbg !3958
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %20) #31, !dbg !3958
  br label %sw.epilog, !dbg !3959

sw.bb17:                                          ; preds = %entry
  %21 = bitcast %"struct.laya::Check"* %ref.tmp18 to i8*, !dbg !3960
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %21) #31, !dbg !3960
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp18, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !3960
  %22 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp18, align 8, !dbg !3961
  store %"struct.laya::Check" %22, %"struct.laya::Check"* %result, align 8, !dbg !3961
  %23 = bitcast %"struct.laya::Check"* %ref.tmp18 to i8*, !dbg !3962
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %23) #31, !dbg !3962
  br label %sw.epilog, !dbg !3963

sw.bb19:                                          ; preds = %entry
  br label %VITIS_LOOP_78_1, !dbg !3963

VITIS_LOOP_78_1:                                  ; preds = %sw.bb19
  %24 = bitcast i32* %i to i8*, !dbg !3964
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %24) #31, !dbg !3964
  call void @llvm.dbg.declare(metadata i32* %i, metadata !3966, metadata !DIExpression()), !dbg !3967
  store i32 2, i32* %i, align 4, !dbg !3967
  br label %for.cond, !dbg !3964

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_78_1
  %25 = load i32, i32* %i, align 4, !dbg !3968
  %cmp = icmp ult i32 %25, 32, !dbg !3970
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !3971

for.cond.cleanup:                                 ; preds = %for.cond
  %26 = bitcast i32* %i to i8*, !dbg !3972
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %26) #31, !dbg !3972
  br label %for.end

for.body:                                         ; preds = %for.cond
  %27 = bitcast %"struct.laya::BufferRef"* %ref.tmp20 to i8*, !dbg !3973
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %27) #31, !dbg !3973
  %id21 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp20, i32 0, i32 0, !dbg !3973
  store i8 1, i8* %id21, align 4, !dbg !3973
  %bank22 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp20, i32 0, i32 1, !dbg !3973
  store i8 0, i8* %bank22, align 1, !dbg !3973
  %epoch23 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp20, i32 0, i32 2, !dbg !3973
  store i32 1, i32* %epoch23, align 4, !dbg !3973
  %28 = load i32, i32* %i, align 4, !dbg !3974
  %idxprom = zext i32 %28 to i64, !dbg !3975
  %arrayidx = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0), i64 0, i64 %idxprom, !dbg !3975
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx, i32 0, i32 1, !dbg !3976
  %29 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp20, align 4, !dbg !3977
  store %"struct.laya::BufferRef" %29, %"struct.laya::BufferRef"* %ref, align 8, !dbg !3977
  %30 = bitcast %"struct.laya::BufferRef"* %ref.tmp20 to i8*, !dbg !3975
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %30) #31, !dbg !3975
  br label %for.inc, !dbg !3975

for.inc:                                          ; preds = %for.body
  %31 = load i32, i32* %i, align 4, !dbg !3978
  %inc = add i32 %31, 1, !dbg !3978
  store i32 %inc, i32* %i, align 4, !dbg !3978
  br label %for.cond, !dbg !3972, !llvm.loop !3979

for.end:                                          ; preds = %for.cond.cleanup
  store i32 85, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 0, i32 15, i64 0), align 4, !dbg !3982
  store i32 7, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 27), align 8, !dbg !3983
  %32 = bitcast %"struct.laya::BufferRef"* %ref.tmp24 to i8*, !dbg !3984
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %32) #31, !dbg !3984
  %id25 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp24, i32 0, i32 0, !dbg !3984
  store i8 34, i8* %id25, align 4, !dbg !3984
  %bank26 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp24, i32 0, i32 1, !dbg !3984
  store i8 0, i8* %bank26, align 1, !dbg !3984
  %epoch27 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp24, i32 0, i32 2, !dbg !3984
  store i32 3, i32* %epoch27, align 4, !dbg !3984
  %33 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp24, align 4, !dbg !3985
  store %"struct.laya::BufferRef" %33, %"struct.laya::BufferRef"* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 2, i32 1, i32 1), align 8, !dbg !3985
  %34 = bitcast %"struct.laya::BufferRef"* %ref.tmp24 to i8*, !dbg !3986
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %34) #31, !dbg !3986
  %35 = bitcast %"struct.laya::Check"* %ref.tmp28 to i8*, !dbg !3987
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %35) #31, !dbg !3987
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp28, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !3987
  %36 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp28, align 8, !dbg !3988
  store %"struct.laya::Check" %36, %"struct.laya::Check"* %result, align 8, !dbg !3988
  %37 = bitcast %"struct.laya::Check"* %ref.tmp28 to i8*, !dbg !3989
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %37) #31, !dbg !3989
  br label %sw.epilog, !dbg !3990

sw.bb29:                                          ; preds = %entry
  br label %VITIS_LOOP_86_2, !dbg !3990

VITIS_LOOP_86_2:                                  ; preds = %sw.bb29
  %38 = bitcast i32* %i30 to i8*, !dbg !3991
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %38) #31, !dbg !3991
  call void @llvm.dbg.declare(metadata i32* %i30, metadata !3993, metadata !DIExpression()), !dbg !3994
  store i32 2, i32* %i30, align 4, !dbg !3994
  br label %for.cond31, !dbg !3991

for.cond31:                                       ; preds = %for.inc39, %VITIS_LOOP_86_2
  %39 = load i32, i32* %i30, align 4, !dbg !3995
  %cmp32 = icmp ult i32 %39, 32, !dbg !3997
  br i1 %cmp32, label %for.body34, label %for.cond.cleanup33, !dbg !3998

for.cond.cleanup33:                               ; preds = %for.cond31
  %40 = bitcast i32* %i30 to i8*, !dbg !3999
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %40) #31, !dbg !3999
  br label %for.end41

for.body34:                                       ; preds = %for.cond31
  %41 = bitcast %"struct.laya::BufferRef"* %ref.tmp35 to i8*, !dbg !4000
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %41) #31, !dbg !4000
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp35), !dbg !4000
  %42 = load i32, i32* %i30, align 4, !dbg !4001
  %idxprom36 = zext i32 %42 to i64, !dbg !4002
  %arrayidx37 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0), i64 0, i64 %idxprom36, !dbg !4002
  %ref38 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx37, i32 0, i32 1, !dbg !4003
  %43 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp35, align 4, !dbg !4004
  store %"struct.laya::BufferRef" %43, %"struct.laya::BufferRef"* %ref38, align 8, !dbg !4004
  %44 = bitcast %"struct.laya::BufferRef"* %ref.tmp35 to i8*, !dbg !4002
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %44) #31, !dbg !4002
  br label %for.inc39, !dbg !4002

for.inc39:                                        ; preds = %for.body34
  %45 = load i32, i32* %i30, align 4, !dbg !4005
  %inc40 = add i32 %45, 1, !dbg !4005
  store i32 %inc40, i32* %i30, align 4, !dbg !4005
  br label %for.cond31, !dbg !3999, !llvm.loop !4006

for.end41:                                        ; preds = %for.cond.cleanup33
  %46 = bitcast %"struct.laya::Check"* %ref.tmp42 to i8*, !dbg !4009
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %46) #31, !dbg !4009
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp42, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !4009
  %47 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp42, align 8, !dbg !4010
  store %"struct.laya::Check" %47, %"struct.laya::Check"* %result, align 8, !dbg !4010
  %48 = bitcast %"struct.laya::Check"* %ref.tmp42 to i8*, !dbg !4011
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %48) #31, !dbg !4011
  br label %sw.epilog, !dbg !4012

sw.bb43:                                          ; preds = %entry
  store i1 true, i1* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 42), align 8, !dbg !4013
  store i1 true, i1* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 43), align 1, !dbg !4014
  %49 = bitcast %"struct.laya::Check"* %ref.tmp44 to i8*, !dbg !4015
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %49) #31, !dbg !4015
  %50 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp45 to i8*, !dbg !4016
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %50) #31, !dbg !4016
  call void @_ZN12_GLOBAL__N_17a8_specEj(%"struct.laya::full::FullOwnerSpec"* sret(%"struct.laya::full::FullOwnerSpec") align 4 %ref.tmp45, i32 4), !dbg !4016
  call void @_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp44, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %ref.tmp45), !dbg !4015
  %51 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp44, align 8, !dbg !4017
  store %"struct.laya::Check" %51, %"struct.laya::Check"* %result, align 8, !dbg !4017
  %52 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp45 to i8*, !dbg !4018
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %52) #31, !dbg !4018
  %53 = bitcast %"struct.laya::Check"* %ref.tmp44 to i8*, !dbg !4018
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %53) #31, !dbg !4018
  br label %sw.epilog, !dbg !4019

sw.bb46:                                          ; preds = %entry
  %54 = bitcast %"struct.laya::Check"* %ref.tmp47 to i8*, !dbg !4020
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %54) #31, !dbg !4020
  %id49 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp48, i32 0, i32 0, !dbg !4021
  store i8 34, i8* %id49, align 4, !dbg !4021
  %bank50 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp48, i32 0, i32 1, !dbg !4021
  store i8 0, i8* %bank50, align 1, !dbg !4021
  %epoch51 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %agg.tmp48, i32 0, i32 2, !dbg !4021
  store i32 4, i32* %epoch51, align 4, !dbg !4021
  call void @_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp47, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, %"struct.laya::BufferRef"* byval(%"struct.laya::BufferRef") align 4 %agg.tmp48, i8 zeroext 0), !dbg !4020
  %55 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp47, align 8, !dbg !4022
  store %"struct.laya::Check" %55, %"struct.laya::Check"* %result, align 8, !dbg !4022
  %56 = bitcast %"struct.laya::Check"* %ref.tmp47 to i8*, !dbg !4023
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %56) #31, !dbg !4023
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %result), !dbg !4024
  br i1 %call, label %if.then, label %if.end, !dbg !4026

if.then:                                          ; preds = %sw.bb46
  %57 = bitcast %"struct.laya::BufferRef"* %ref.tmp52 to i8*, !dbg !4027
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %57) #31, !dbg !4027
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret(%"struct.laya::BufferRef") align 4 %ref.tmp52), !dbg !4027
  %58 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp52, align 4, !dbg !4029
  store %"struct.laya::BufferRef" %58, %"struct.laya::BufferRef"* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 2, i32 1, i32 1), align 8, !dbg !4029
  %59 = bitcast %"struct.laya::BufferRef"* %ref.tmp52 to i8*, !dbg !4030
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %59) #31, !dbg !4030
  %60 = bitcast %"struct.laya::Check"* %ref.tmp53 to i8*, !dbg !4031
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %60) #31, !dbg !4031
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp53, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !4031
  %61 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp53, align 8, !dbg !4032
  store %"struct.laya::Check" %61, %"struct.laya::Check"* %result, align 8, !dbg !4032
  %62 = bitcast %"struct.laya::Check"* %ref.tmp53 to i8*, !dbg !4033
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %62) #31, !dbg !4033
  br label %if.end, !dbg !4034

if.end:                                           ; preds = %if.then, %sw.bb46
  br label %sw.epilog, !dbg !4035

sw.bb54:                                          ; preds = %entry
  %63 = bitcast %"struct.laya::BufferRef"* %ref.tmp55 to i8*, !dbg !4036
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %63) #31, !dbg !4036
  %id56 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp55, i32 0, i32 0, !dbg !4036
  store i8 34, i8* %id56, align 4, !dbg !4036
  %bank57 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp55, i32 0, i32 1, !dbg !4036
  store i8 0, i8* %bank57, align 1, !dbg !4036
  %epoch58 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp55, i32 0, i32 2, !dbg !4036
  store i32 2, i32* %epoch58, align 4, !dbg !4036
  %64 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp55, align 4, !dbg !4037
  store %"struct.laya::BufferRef" %64, %"struct.laya::BufferRef"* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 2, i32 1, i32 1), align 8, !dbg !4037
  %65 = bitcast %"struct.laya::BufferRef"* %ref.tmp55 to i8*, !dbg !4038
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %65) #31, !dbg !4038
  %66 = bitcast %"struct.laya::Check"* %ref.tmp59 to i8*, !dbg !4039
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %66) #31, !dbg !4039
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp59, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !4039
  %67 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp59, align 8, !dbg !4040
  store %"struct.laya::Check" %67, %"struct.laya::Check"* %result, align 8, !dbg !4040
  %68 = bitcast %"struct.laya::Check"* %ref.tmp59 to i8*, !dbg !4041
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %68) #31, !dbg !4041
  br label %sw.epilog, !dbg !4042

sw.bb60:                                          ; preds = %entry
  %69 = bitcast %"struct.laya::BufferRef"* %ref.tmp61 to i8*, !dbg !4043
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %69) #31, !dbg !4043
  %id62 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp61, i32 0, i32 0, !dbg !4043
  store i8 34, i8* %id62, align 4, !dbg !4043
  %bank63 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp61, i32 0, i32 1, !dbg !4043
  store i8 0, i8* %bank63, align 1, !dbg !4043
  %epoch64 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp61, i32 0, i32 2, !dbg !4043
  store i32 6, i32* %epoch64, align 4, !dbg !4043
  %70 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp61, align 4, !dbg !4044
  store %"struct.laya::BufferRef" %70, %"struct.laya::BufferRef"* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 2, i32 1, i32 1), align 8, !dbg !4044
  %71 = bitcast %"struct.laya::BufferRef"* %ref.tmp61 to i8*, !dbg !4045
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %71) #31, !dbg !4045
  %72 = bitcast %"struct.laya::Check"* %ref.tmp65 to i8*, !dbg !4046
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %72) #31, !dbg !4046
  call void @_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp65, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE), !dbg !4046
  %73 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp65, align 8, !dbg !4047
  store %"struct.laya::Check" %73, %"struct.laya::Check"* %result, align 8, !dbg !4047
  %74 = bitcast %"struct.laya::Check"* %ref.tmp65 to i8*, !dbg !4048
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %74) #31, !dbg !4048
  br label %sw.epilog, !dbg !4049

sw.bb66:                                          ; preds = %entry
  %75 = bitcast %"struct.laya::Check"* %ref.tmp67 to i8*, !dbg !4050
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %75) #31, !dbg !4050
  call void @_ZN4laya4full15full_soft_resetERNS0_11FullRuntimeEm(%"struct.laya::Check"* sret(%"struct.laya::Check") align 8 %ref.tmp67, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZN12_GLOBAL__N_17runtimeE, i64 2), !dbg !4050
  %76 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp67, align 8, !dbg !4051
  store %"struct.laya::Check" %76, %"struct.laya::Check"* %result, align 8, !dbg !4051
  %77 = bitcast %"struct.laya::Check"* %ref.tmp67 to i8*, !dbg !4052
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %77) #31, !dbg !4052
  br label %sw.epilog, !dbg !4053

sw.default:                                       ; preds = %entry
  %78 = bitcast %"struct.laya::Check"* %ref.tmp68 to i8*, !dbg !4054
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %78) #31, !dbg !4054
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp68, i32 0, i32 0, !dbg !4054
  store i16 7, i16* %code, align 8, !dbg !4054
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp68, i32 0, i32 1, !dbg !4054
  store i32 0, i32* %detail, align 4, !dbg !4054
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp68, i32 0, i32 2, !dbg !4054
  store i64 -1, i64* %bad_element, align 8, !dbg !4054
  %79 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp68, align 8, !dbg !4055
  store %"struct.laya::Check" %79, %"struct.laya::Check"* %result, align 8, !dbg !4055
  %80 = bitcast %"struct.laya::Check"* %ref.tmp68 to i8*, !dbg !4056
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %80) #31, !dbg !4056
  br label %sw.epilog, !dbg !4057

sw.epilog:                                        ; preds = %sw.default, %sw.bb66, %sw.bb60, %sw.bb54, %if.end, %sw.bb43, %for.end41, %for.end, %sw.bb17, %sw.bb11, %sw.bb9, %sw.bb4, %sw.bb2, %sw.bb1, %sw.bb
  %code69 = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %result, i32 0, i32 0, !dbg !4059
  %81 = load i16, i16* %code69, align 8, !dbg !4059
  %conv70 = zext i16 %81 to i32, !dbg !4060
  %82 = load i32*, i32** %status.addr, align 8, !dbg !4061
  store i32 %conv70, i32* %82, align 4, !dbg !4062
  %83 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 0, i32 1, i32 2), align 4, !dbg !4063
  %84 = load i32*, i32** %slot0_epoch.addr, align 8, !dbg !4064
  store i32 %83, i32* %84, align 4, !dbg !4065
  %85 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 1, i32 1, i32 2), align 4, !dbg !4066
  %86 = load i32*, i32** %slot1_epoch.addr, align 8, !dbg !4067
  store i32 %85, i32* %86, align 4, !dbg !4068
  %87 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 2, i32 1, i32 2), align 4, !dbg !4069
  %88 = load i32*, i32** %slot2_epoch.addr, align 8, !dbg !4070
  store i32 %87, i32* %88, align 4, !dbg !4071
  %89 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 2, i32 1, i32 1, i32 2), align 4, !dbg !4072
  %90 = load i32*, i32** %numeric_epoch.addr, align 8, !dbg !4073
  store i32 %89, i32* %90, align 4, !dbg !4074
  %91 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 27), align 8, !dbg !4075
  %92 = load i32*, i32** %claims.addr, align 8, !dbg !4076
  store i32 %91, i32* %92, align 4, !dbg !4077
  %93 = load i32, i32* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 0, i32 15, i64 0), align 4, !dbg !4078
  %94 = load i32*, i32** %slot0_coverage.addr, align 8, !dbg !4079
  store i32 %93, i32* %94, align 4, !dbg !4080
  %95 = load i8, i8* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 1, i32 0, i64 2, i32 1, i32 0), align 8, !dbg !4081
  %conv71 = zext i8 %95 to i32, !dbg !4082
  %96 = load i32*, i32** %slot2_id.addr, align 8, !dbg !4083
  store i32 %conv71, i32* %96, align 4, !dbg !4084
  %97 = load i64, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 32), align 8, !dbg !4085
  %conv72 = trunc i64 %97 to i32, !dbg !4086
  %98 = load i32*, i32** %request_high.addr, align 8, !dbg !4087
  store i32 %conv72, i32* %98, align 4, !dbg !4088
  %99 = load i64, i64* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZN12_GLOBAL__N_17runtimeE, i32 0, i32 31), align 8, !dbg !4089
  %conv73 = trunc i64 %99 to i32, !dbg !4090
  %100 = load i32*, i32** %generation.addr, align 8, !dbg !4091
  store i32 %conv73, i32* %100, align 4, !dbg !4092
  %101 = bitcast %"struct.laya::Check"* %result to i8*, !dbg !4093
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %101) #31, !dbg !4093
  ret void, !dbg !4093
}

; Function Attrs: inaccessiblememonly nofree nosync nounwind willreturn
declare void @llvm.sideeffect() #28

; Function Attrs: nounwind
define internal void @_ZN12_GLOBAL__N_18qkv_specEhj(%"struct.laya::full::FullOwnerSpec"* noalias sret(%"struct.laya::full::FullOwnerSpec") align 4 %agg.result, i8 zeroext %bank, i32 %epoch) #29 !dbg !4094 {
entry:
  %bank.addr = alloca i8, align 1
  %epoch.addr = alloca i32, align 4
  store i8 %bank, i8* %bank.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %bank.addr, metadata !4097, metadata !DIExpression()), !dbg !4098
  store i32 %epoch, i32* %epoch.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %epoch.addr, metadata !4099, metadata !DIExpression()), !dbg !4100
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 0, !dbg !4101
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !4102
  store i8 5, i8* %id, align 4, !dbg !4102
  %bank1 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 1, !dbg !4102
  %0 = load i8, i8* %bank.addr, align 1, !dbg !4103
  store i8 %0, i8* %bank1, align 1, !dbg !4102
  %epoch2 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 2, !dbg !4102
  %1 = load i32, i32* %epoch.addr, align 4, !dbg !4104
  store i32 %1, i32* %epoch2, align 4, !dbg !4102
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 1, !dbg !4101
  store i8 0, i8* %region, align 4, !dbg !4101
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 2, !dbg !4101
  store i8 2, i8* %stage, align 1, !dbg !4101
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 3, !dbg !4101
  store i8 0, i8* %layer, align 2, !dbg !4101
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 4, !dbg !4101
  store i8 -1, i8* %batch, align 1, !dbg !4101
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 5, !dbg !4101
  store i8 0, i8* %row_space, align 4, !dbg !4101
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 6, !dbg !4101
  store i16 0, i16* %row0, align 2, !dbg !4101
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 7, !dbg !4101
  store i16 64, i16* %rows, align 4, !dbg !4101
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 8, !dbg !4101
  store i16 64, i16* %width, align 2, !dbg !4101
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 9, !dbg !4101
  store i8 2, i8* %content, align 4, !dbg !4101
  ret void, !dbg !4105
}

; Function Attrs: nounwind
define internal void @_ZN12_GLOBAL__N_17a8_specEj(%"struct.laya::full::FullOwnerSpec"* noalias sret(%"struct.laya::full::FullOwnerSpec") align 4 %agg.result, i32 %epoch) #30 !dbg !4106 {
entry:
  %epoch.addr = alloca i32, align 4
  store i32 %epoch, i32* %epoch.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %epoch.addr, metadata !4109, metadata !DIExpression()), !dbg !4110
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 0, !dbg !4111
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !4112
  store i8 34, i8* %id, align 4, !dbg !4112
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 1, !dbg !4112
  store i8 0, i8* %bank, align 1, !dbg !4112
  %epoch1 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 2, !dbg !4112
  %0 = load i32, i32* %epoch.addr, align 4, !dbg !4113
  store i32 %0, i32* %epoch1, align 4, !dbg !4112
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 1, !dbg !4111
  store i8 0, i8* %region, align 4, !dbg !4111
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 2, !dbg !4111
  store i8 2, i8* %stage, align 1, !dbg !4111
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 3, !dbg !4111
  store i8 0, i8* %layer, align 2, !dbg !4111
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 4, !dbg !4111
  store i8 0, i8* %batch, align 1, !dbg !4111
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 5, !dbg !4111
  store i8 0, i8* %row_space, align 4, !dbg !4111
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 6, !dbg !4111
  store i16 0, i16* %row0, align 2, !dbg !4111
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 7, !dbg !4111
  store i16 1, i16* %rows, align 4, !dbg !4111
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 8, !dbg !4111
  store i16 1024, i16* %width, align 2, !dbg !4111
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %agg.result, i32 0, i32 9, !dbg !4111
  store i8 4, i8* %content, align 4, !dbg !4111
  ret void, !dbg !4114
}

attributes #0 = { nounwind "fpga.demangled.name"="check_ref" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind "fpga.demangled.name"="ok" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #3 = { nounwind "fpga.demangled.name"="detail" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #4 = { argmemonly nofree nosync nounwind willreturn }
attributes #5 = { nounwind "fpga.demangled.name"="numeric_identity_valid" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #6 = { nounwind "fpga.demangled.name"="nonzero" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #7 = { nounwind "fpga.demangled.name"="numeric_reset_f32" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #8 = { nounwind "fpga.demangled.name"="numeric_reset_a8" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #9 = { nounwind "fpga.demangled.name"="full_claim_owner" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #10 = { nounwind "fpga.demangled.name"="protocol" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #11 = { nounwind "fpga.demangled.name"="legal_spec" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #12 = { nounwind "fpga.demangled.name"="error" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #13 = { nounwind "fpga.demangled.name"="claim_index" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #14 = { nounwind "fpga.demangled.name"="fill_record" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #15 = { nounwind "fpga.demangled.name"="none" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #16 = { nounwind "fpga.demangled.name"="clear_bits" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #17 = { nounwind "fpga.demangled.name"="find_index" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #18 = { nounwind "fpga.demangled.name"="empty_index" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #19 = { nounwind "fpga.demangled.name"="same_physical" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #20 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #21 = { nounwind "fpga.demangled.name"="legal_width" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #22 = { nounwind "fpga.demangled.name"="full_claim_qkv_pair" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #23 = { nounwind "fpga.demangled.name"="qkv_pair_specs" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #24 = { nounwind "fpga.demangled.name"="full_invalidate_owner" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #25 = { nounwind "fpga.demangled.name"="full_recycle_request" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #26 = { nounwind "fpga.demangled.name"="full_soft_reset" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #27 = { nounwind "fpga.demangled.name"="full_owner_index_pilot" "fpga.top.func"="full_owner_index_pilot" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #28 = { inaccessiblememonly nofree nosync nounwind willreturn }
attributes #29 = { nounwind "fpga.demangled.name"="qkv_spec" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #30 = { nounwind "fpga.demangled.name"="a8_spec" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #31 = { nounwind }
attributes #32 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="8" "xlx.source"="user" }
attributes #33 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="0" "xlx.source"="user" }

!llvm.dbg.cu = !{!1217, !1395, !44, !1461}
!llvm.ident = !{!1522, !1522, !1522, !1522, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523, !1523}
!llvm.module.flags = !{!1524, !1525, !1526}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "widths", scope: !2, file: !3, line: 37, type: !991, isLocal: true, isDefinition: true)
!2 = distinct !DISubprogram(name: "legal_width", linkageName: "_ZN4laya4full12_GLOBAL__N_111legal_widthENS_6BufferEh", scope: !4, file: !3, line: 26, type: !7, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!3 = !DIFile(filename: "hls/common/laya_full_owner.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!4 = !DINamespace(scope: !5)
!5 = !DINamespace(name: "full", scope: !6)
!6 = !DINamespace(name: "laya", scope: null)
!7 = !DISubroutineType(types: !8)
!8 = !{!9, !14, !16}
!9 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !10, line: 25, baseType: !11)
!10 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !12, line: 40, baseType: !13)
!12 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!13 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!14 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Buffer", scope: !6, file: !15, line: 13, baseType: !16, size: 8, elements: !19, identifier: "_ZTSN4laya6BufferE")
!15 = !DIFile(filename: "include/laya_types.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!16 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !10, line: 24, baseType: !17)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !12, line: 38, baseType: !18)
!18 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!19 = !{!20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43}
!20 = !DIEnumerator(name: "NONE", value: 0)
!21 = !DIEnumerator(name: "HIDDEN", value: 1)
!22 = !DIEnumerator(name: "NORM", value: 2)
!23 = !DIEnumerator(name: "TMP", value: 3)
!24 = !DIEnumerator(name: "MARKER", value: 4)
!25 = !DIEnumerator(name: "QKV", value: 5)
!26 = !DIEnumerator(name: "WI", value: 6)
!27 = !DIEnumerator(name: "GATE", value: 7)
!28 = !DIEnumerator(name: "ATT_OUT", value: 8)
!29 = !DIEnumerator(name: "DEC_FF", value: 9)
!30 = !DIEnumerator(name: "HEAD_WORK", value: 10)
!31 = !DIEnumerator(name: "TYPE_ROWS", value: 11)
!32 = !DIEnumerator(name: "LN_ROW", value: 32)
!33 = !DIEnumerator(name: "QUANT_INPUT", value: 33)
!34 = !DIEnumerator(name: "A8", value: 34)
!35 = !DIEnumerator(name: "WEIGHT", value: 35)
!36 = !DIEnumerator(name: "PS", value: 36)
!37 = !DIEnumerator(name: "KV", value: 37)
!38 = !DIEnumerator(name: "SCORE_PROB", value: 38)
!39 = !DIEnumerator(name: "Q_TILE", value: 39)
!40 = !DIEnumerator(name: "AV_PARTIAL", value: 40)
!41 = !DIEnumerator(name: "ROPE_HEAD", value: 41)
!42 = !DIEnumerator(name: "LN_GAMMA", value: 42)
!43 = !DIEnumerator(name: "ROPE_TABLE", value: 43)
!44 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !45, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !46, retainedTypes: !92, globals: !101, imports: !109, splitDebugInlining: false, nameTableKind: GNU)
!45 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis/csynth_r2/hls/.autopilot/db/laya_full_owner.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis", checksumkind: CSK_MD5, checksum: "33315d479ec78bdad80e38aed388db31")
!46 = !{!47, !14, !58, !63, !73, !82}
!47 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Status", scope: !6, file: !15, line: 8, baseType: !9, size: 16, elements: !48, identifier: "_ZTSN4laya6StatusE")
!48 = !{!49, !50, !51, !52, !53, !54, !55, !56, !57}
!49 = !DIEnumerator(name: "OK", value: 0)
!50 = !DIEnumerator(name: "E_ABI", value: 1)
!51 = !DIEnumerator(name: "E_MODEL", value: 2)
!52 = !DIEnumerator(name: "E_SHAPE", value: 3)
!53 = !DIEnumerator(name: "E_INDEX", value: 4)
!54 = !DIEnumerator(name: "E_BUFFER", value: 5)
!55 = !DIEnumerator(name: "E_NUMERICAL", value: 6)
!56 = !DIEnumerator(name: "E_PROTOCOL", value: 7)
!57 = !DIEnumerator(name: "E_INTERNAL", value: 8)
!58 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "RowSpace", scope: !6, file: !15, line: 15, baseType: !16, size: 8, elements: !59, identifier: "_ZTSN4laya8RowSpaceE")
!59 = !{!60, !61, !62}
!60 = !DIEnumerator(name: "TOKEN", value: 0)
!61 = !DIEnumerator(name: "MARKER", value: 1)
!62 = !DIEnumerator(name: "BATCH", value: 2)
!63 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Content", scope: !6, file: !15, line: 17, baseType: !16, size: 8, elements: !64, identifier: "_ZTSN4laya7ContentE")
!64 = !{!65, !66, !67, !68, !69, !70, !71, !72}
!65 = !DIEnumerator(name: "UNDEFINED", value: 0)
!66 = !DIEnumerator(name: "F32", value: 1)
!67 = !DIEnumerator(name: "QKV_RAW", value: 2)
!68 = !DIEnumerator(name: "QKV_FINAL", value: 3)
!69 = !DIEnumerator(name: "Q8_TILE", value: 4)
!70 = !DIEnumerator(name: "Q8_WEIGHT", value: 5)
!71 = !DIEnumerator(name: "SCORE", value: 6)
!72 = !DIEnumerator(name: "PROB", value: 7)
!73 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "CacheState", scope: !6, file: !15, line: 16, baseType: !16, size: 8, elements: !74, identifier: "_ZTSN4laya10CacheStateE")
!74 = !{!75, !76, !77, !78, !79, !80, !81}
!75 = !DIEnumerator(name: "FREE", value: 0)
!76 = !DIEnumerator(name: "FILL", value: 1)
!77 = !DIEnumerator(name: "READY", value: 2)
!78 = !DIEnumerator(name: "READ", value: 3)
!79 = !DIEnumerator(name: "EXCLUSIVE_RW", value: 4)
!80 = !DIEnumerator(name: "DRAIN", value: 5)
!81 = !DIEnumerator(name: "INVALID", value: 6)
!82 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Region", scope: !6, file: !15, line: 14, baseType: !16, size: 8, elements: !83, identifier: "_ZTSN4laya6RegionE")
!83 = !{!84, !85, !86, !87, !88, !89, !90, !91}
!84 = !DIEnumerator(name: "SCORER_ACT", value: 0)
!85 = !DIEnumerator(name: "ACT_INPUT", value: 1)
!86 = !DIEnumerator(name: "ACT_HIDDEN", value: 2)
!87 = !DIEnumerator(name: "CAND_MASKED", value: 3)
!88 = !DIEnumerator(name: "ACT_LOGITS", value: 4)
!89 = !DIEnumerator(name: "STATS", value: 5)
!90 = !DIEnumerator(name: "CAND_PROB", value: 6)
!91 = !DIEnumerator(name: "CAND_RAW", value: 7)
!92 = !{!93, !16, !96, !95}
!93 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !10, line: 26, baseType: !94)
!94 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !12, line: 42, baseType: !95)
!95 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!96 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "BufferRef", scope: !6, file: !15, line: 19, size: 64, flags: DIFlagTypePassByValue, elements: !97, identifier: "_ZTSN4laya9BufferRefE")
!97 = !{!98, !99, !100}
!98 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !96, file: !15, line: 19, baseType: !14, size: 8)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "bank", scope: !96, file: !15, line: 19, baseType: !16, size: 8, offset: 8)
!100 = !DIDerivedType(tag: DW_TAG_member, name: "epoch", scope: !96, file: !15, line: 19, baseType: !93, size: 32, offset: 32)
!101 = !{!102, !105, !0}
!102 = !DIGlobalVariableExpression(var: !103, expr: !DIExpression(DW_OP_constu, 32, DW_OP_stack_value))
!103 = distinct !DIGlobalVariable(name: "kNoOwnerIndex", scope: !4, file: !3, line: 114, type: !104, isLocal: true, isDefinition: true)
!104 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !95)
!105 = !DIGlobalVariableExpression(var: !106, expr: !DIExpression(DW_OP_constu, 4294967294, DW_OP_stack_value))
!106 = distinct !DIGlobalVariable(name: "kMaxEpoch", scope: !6, file: !107, line: 13, type: !108, isLocal: true, isDefinition: true)
!107 = !DIFile(filename: "include/laya_config.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!108 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !93)
!109 = !{!110, !117, !121, !125, !129, !132, !134, !136, !138, !142, !145, !148, !151, !154, !156, !157, !158, !159, !163, !165, !167, !169, !171, !174, !177, !180, !183, !186, !188, !298, !302, !306, !323, !326, !331, !339, !347, !351, !358, !362, !366, !368, !370, !374, !383, !387, !393, !399, !401, !405, !409, !413, !417, !425, !427, !431, !435, !439, !441, !447, !451, !455, !457, !459, !463, !471, !475, !479, !483, !485, !491, !493, !500, !505, !509, !513, !517, !521, !525, !527, !529, !533, !537, !541, !543, !547, !551, !553, !555, !559, !565, !570, !575, !576, !577, !578, !579, !580, !581, !582, !583, !584, !585, !587, !589, !593, !597, !602, !608, !610, !612, !614, !616, !618, !620, !622, !624, !626, !628, !630, !632, !634, !638, !642, !648, !652, !656, !661, !663, !667, !671, !675, !685, !687, !691, !695, !699, !703, !707, !711, !715, !719, !723, !727, !731, !733, !735, !739, !743, !749, !753, !757, !759, !763, !767, !773, !775, !779, !783, !787, !791, !795, !799, !803, !804, !805, !806, !808, !809, !810, !811, !812, !813, !814, !818, !824, !829, !833, !835, !837, !839, !841, !848, !852, !856, !860, !864, !868, !873, !877, !879, !883, !889, !893, !898, !900, !902, !906, !910, !912, !914, !916, !918, !922, !924, !926, !930, !934, !938, !942, !946, !950, !952, !956, !960, !964, !968, !970, !972, !976, !980, !981, !982, !983, !984, !985}
!110 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !112, file: !116, line: 48)
!111 = !DINamespace(name: "std", scope: null)
!112 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !113, line: 24, baseType: !114)
!113 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h", directory: "")
!114 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int8_t", file: !12, line: 37, baseType: !115)
!115 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!116 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdint", directory: "/home/user/EDA-202")
!117 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !118, file: !116, line: 49)
!118 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !113, line: 25, baseType: !119)
!119 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int16_t", file: !12, line: 39, baseType: !120)
!120 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!121 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !122, file: !116, line: 50)
!122 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !113, line: 26, baseType: !123)
!123 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int32_t", file: !12, line: 41, baseType: !124)
!124 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!125 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !126, file: !116, line: 51)
!126 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !113, line: 27, baseType: !127)
!127 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !12, line: 44, baseType: !128)
!128 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!129 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !130, file: !116, line: 53)
!130 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast8_t", file: !131, line: 47, baseType: !115)
!131 = !DIFile(filename: "/usr/include/stdint.h", directory: "")
!132 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !133, file: !116, line: 54)
!133 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast16_t", file: !131, line: 49, baseType: !128)
!134 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !135, file: !116, line: 55)
!135 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast32_t", file: !131, line: 50, baseType: !128)
!136 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !137, file: !116, line: 56)
!137 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast64_t", file: !131, line: 51, baseType: !128)
!138 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !139, file: !116, line: 58)
!139 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least8_t", file: !140, line: 25, baseType: !141)
!140 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-least.h", directory: "")
!141 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least8_t", file: !12, line: 52, baseType: !114)
!142 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !143, file: !116, line: 59)
!143 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least16_t", file: !140, line: 26, baseType: !144)
!144 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least16_t", file: !12, line: 54, baseType: !119)
!145 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !146, file: !116, line: 60)
!146 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least32_t", file: !140, line: 27, baseType: !147)
!147 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least32_t", file: !12, line: 56, baseType: !123)
!148 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !149, file: !116, line: 61)
!149 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least64_t", file: !140, line: 28, baseType: !150)
!150 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least64_t", file: !12, line: 58, baseType: !127)
!151 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !152, file: !116, line: 63)
!152 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !131, line: 90, baseType: !153)
!153 = !DIDerivedType(tag: DW_TAG_typedef, name: "__intmax_t", file: !12, line: 72, baseType: !128)
!154 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !155, file: !116, line: 64)
!155 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !131, line: 76, baseType: !128)
!156 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !16, file: !116, line: 66)
!157 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !9, file: !116, line: 67)
!158 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !93, file: !116, line: 68)
!159 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !160, file: !116, line: 69)
!160 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !10, line: 27, baseType: !161)
!161 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !12, line: 45, baseType: !162)
!162 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!163 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !164, file: !116, line: 71)
!164 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast8_t", file: !131, line: 60, baseType: !18)
!165 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !166, file: !116, line: 72)
!166 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast16_t", file: !131, line: 62, baseType: !162)
!167 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !168, file: !116, line: 73)
!168 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast32_t", file: !131, line: 63, baseType: !162)
!169 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !170, file: !116, line: 74)
!170 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast64_t", file: !131, line: 64, baseType: !162)
!171 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !172, file: !116, line: 76)
!172 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least8_t", file: !140, line: 31, baseType: !173)
!173 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least8_t", file: !12, line: 53, baseType: !17)
!174 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !175, file: !116, line: 77)
!175 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least16_t", file: !140, line: 32, baseType: !176)
!176 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least16_t", file: !12, line: 55, baseType: !11)
!177 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !178, file: !116, line: 78)
!178 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least32_t", file: !140, line: 33, baseType: !179)
!179 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least32_t", file: !12, line: 57, baseType: !94)
!180 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !181, file: !116, line: 79)
!181 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least64_t", file: !140, line: 34, baseType: !182)
!182 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least64_t", file: !12, line: 59, baseType: !161)
!183 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !184, file: !116, line: 81)
!184 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintmax_t", file: !131, line: 91, baseType: !185)
!185 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintmax_t", file: !12, line: 73, baseType: !162)
!186 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !187, file: !116, line: 82)
!187 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !131, line: 79, baseType: !162)
!188 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !189, file: !190, line: 57)
!189 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "exception_ptr", scope: !191, file: !190, line: 79, size: 64, flags: DIFlagTypePassByReference, elements: !192, identifier: "_ZTSNSt15__exception_ptr13exception_ptrE")
!190 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/exception_ptr.h", directory: "/home/user/EDA-202")
!191 = !DINamespace(name: "__exception_ptr", scope: !111)
!192 = !{!193, !195, !199, !202, !203, !208, !209, !213, !219, !223, !227, !230, !231, !234, !238}
!193 = !DIDerivedType(tag: DW_TAG_member, name: "_M_exception_object", scope: !189, file: !190, line: 81, baseType: !194, size: 64)
!194 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!195 = !DISubprogram(name: "exception_ptr", scope: !189, file: !190, line: 83, type: !196, scopeLine: 83, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!196 = !DISubroutineType(types: !197)
!197 = !{null, !198, !194}
!198 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !189, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!199 = !DISubprogram(name: "_M_addref", linkageName: "_ZNSt15__exception_ptr13exception_ptr9_M_addrefEv", scope: !189, file: !190, line: 85, type: !200, scopeLine: 85, flags: DIFlagPrototyped, spFlags: 0)
!200 = !DISubroutineType(types: !201)
!201 = !{null, !198}
!202 = !DISubprogram(name: "_M_release", linkageName: "_ZNSt15__exception_ptr13exception_ptr10_M_releaseEv", scope: !189, file: !190, line: 86, type: !200, scopeLine: 86, flags: DIFlagPrototyped, spFlags: 0)
!203 = !DISubprogram(name: "_M_get", linkageName: "_ZNKSt15__exception_ptr13exception_ptr6_M_getEv", scope: !189, file: !190, line: 88, type: !204, scopeLine: 88, flags: DIFlagPrototyped, spFlags: 0)
!204 = !DISubroutineType(types: !205)
!205 = !{!194, !206}
!206 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !207, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!207 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !189)
!208 = !DISubprogram(name: "exception_ptr", scope: !189, file: !190, line: 96, type: !200, scopeLine: 96, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!209 = !DISubprogram(name: "exception_ptr", scope: !189, file: !190, line: 98, type: !210, scopeLine: 98, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!210 = !DISubroutineType(types: !211)
!211 = !{null, !198, !212}
!212 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !207, size: 64)
!213 = !DISubprogram(name: "exception_ptr", scope: !189, file: !190, line: 101, type: !214, scopeLine: 101, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!214 = !DISubroutineType(types: !215)
!215 = !{null, !198, !216}
!216 = !DIDerivedType(tag: DW_TAG_typedef, name: "nullptr_t", scope: !111, file: !217, line: 242, baseType: !218)
!217 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h", directory: "/home/user/EDA-202")
!218 = !DIBasicType(tag: DW_TAG_unspecified_type, name: "decltype(nullptr)")
!219 = !DISubprogram(name: "exception_ptr", scope: !189, file: !190, line: 105, type: !220, scopeLine: 105, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!220 = !DISubroutineType(types: !221)
!221 = !{null, !198, !222}
!222 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !189, size: 64)
!223 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSERKS0_", scope: !189, file: !190, line: 118, type: !224, scopeLine: 118, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!224 = !DISubroutineType(types: !225)
!225 = !{!226, !198, !212}
!226 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !189, size: 64)
!227 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSEOS0_", scope: !189, file: !190, line: 122, type: !228, scopeLine: 122, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!228 = !DISubroutineType(types: !229)
!229 = !{!226, !198, !222}
!230 = !DISubprogram(name: "~exception_ptr", scope: !189, file: !190, line: 129, type: !200, scopeLine: 129, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!231 = !DISubprogram(name: "swap", linkageName: "_ZNSt15__exception_ptr13exception_ptr4swapERS0_", scope: !189, file: !190, line: 132, type: !232, scopeLine: 132, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!232 = !DISubroutineType(types: !233)
!233 = !{null, !198, !226}
!234 = !DISubprogram(name: "operator bool", linkageName: "_ZNKSt15__exception_ptr13exception_ptrcvbEv", scope: !189, file: !190, line: 144, type: !235, scopeLine: 144, flags: DIFlagPublic | DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!235 = !DISubroutineType(types: !236)
!236 = !{!237, !206}
!237 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!238 = !DISubprogram(name: "__cxa_exception_type", linkageName: "_ZNKSt15__exception_ptr13exception_ptr20__cxa_exception_typeEv", scope: !189, file: !190, line: 153, type: !239, scopeLine: 153, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!239 = !DISubroutineType(types: !240)
!240 = !{!241, !206}
!241 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !242, size: 64)
!242 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !243)
!243 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "type_info", scope: !111, file: !244, line: 88, size: 128, flags: DIFlagTypePassByReference, elements: !245, vtableHolder: !243)
!244 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/typeinfo", directory: "/home/user/EDA-202")
!245 = !{!246, !251, !255, !259, !263, !267, !268, !269, !273, !276, !277, !281, !288, !291, !295}
!246 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$type_info", scope: !244, file: !244, baseType: !247, size: 64, flags: DIFlagArtificial)
!247 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !248, size: 64)
!248 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !249, size: 64)
!249 = !DISubroutineType(types: !250)
!250 = !{!124}
!251 = !DIDerivedType(tag: DW_TAG_member, name: "__name", scope: !243, file: !244, line: 171, baseType: !252, size: 64, offset: 64, flags: DIFlagProtected)
!252 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !253, size: 64)
!253 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !254)
!254 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!255 = !DISubprogram(name: "~type_info", scope: !243, file: !244, line: 95, type: !256, scopeLine: 95, containingType: !243, virtualIndex: 0, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!256 = !DISubroutineType(types: !257)
!257 = !{null, !258}
!258 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !243, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!259 = !DISubprogram(name: "name", linkageName: "_ZNKSt9type_info4nameEv", scope: !243, file: !244, line: 99, type: !260, scopeLine: 99, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!260 = !DISubroutineType(types: !261)
!261 = !{!252, !262}
!262 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !242, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!263 = !DISubprogram(name: "before", linkageName: "_ZNKSt9type_info6beforeERKS_", scope: !243, file: !244, line: 115, type: !264, scopeLine: 115, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!264 = !DISubroutineType(types: !265)
!265 = !{!237, !262, !266}
!266 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !242, size: 64)
!267 = !DISubprogram(name: "operator==", linkageName: "_ZNKSt9type_infoeqERKS_", scope: !243, file: !244, line: 120, type: !264, scopeLine: 120, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!268 = !DISubprogram(name: "operator!=", linkageName: "_ZNKSt9type_infoneERKS_", scope: !243, file: !244, line: 136, type: !264, scopeLine: 136, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!269 = !DISubprogram(name: "hash_code", linkageName: "_ZNKSt9type_info9hash_codeEv", scope: !243, file: !244, line: 140, type: !270, scopeLine: 140, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!270 = !DISubroutineType(types: !271)
!271 = !{!272, !262}
!272 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", scope: !111, file: !217, line: 238, baseType: !162)
!273 = !DISubprogram(name: "__is_pointer_p", linkageName: "_ZNKSt9type_info14__is_pointer_pEv", scope: !243, file: !244, line: 152, type: !274, scopeLine: 152, containingType: !243, virtualIndex: 2, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!274 = !DISubroutineType(types: !275)
!275 = !{!237, !262}
!276 = !DISubprogram(name: "__is_function_p", linkageName: "_ZNKSt9type_info15__is_function_pEv", scope: !243, file: !244, line: 155, type: !274, scopeLine: 155, containingType: !243, virtualIndex: 3, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!277 = !DISubprogram(name: "__do_catch", linkageName: "_ZNKSt9type_info10__do_catchEPKS_PPvj", scope: !243, file: !244, line: 163, type: !278, scopeLine: 163, containingType: !243, virtualIndex: 4, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!278 = !DISubroutineType(types: !279)
!279 = !{!237, !262, !241, !280, !95}
!280 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !194, size: 64)
!281 = !DISubprogram(name: "__do_upcast", linkageName: "_ZNKSt9type_info11__do_upcastEPKN10__cxxabiv117__class_type_infoEPPv", scope: !243, file: !244, line: 167, type: !282, scopeLine: 167, containingType: !243, virtualIndex: 5, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!282 = !DISubroutineType(types: !283)
!283 = !{!237, !262, !284, !280}
!284 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !285, size: 64)
!285 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !286)
!286 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "__class_type_info", scope: !287, file: !244, line: 45, flags: DIFlagFwdDecl, identifier: "_ZTSN10__cxxabiv117__class_type_infoE")
!287 = !DINamespace(name: "__cxxabiv1", scope: null)
!288 = !DISubprogram(name: "type_info", scope: !243, file: !244, line: 173, type: !289, scopeLine: 173, flags: DIFlagProtected | DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!289 = !DISubroutineType(types: !290)
!290 = !{null, !258, !252}
!291 = !DISubprogram(name: "operator=", linkageName: "_ZNSt9type_infoaSERKS_", scope: !243, file: !244, line: 177, type: !292, scopeLine: 177, flags: DIFlagPrototyped, spFlags: 0)
!292 = !DISubroutineType(types: !293)
!293 = !{!294, !258, !266}
!294 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !243, size: 64)
!295 = !DISubprogram(name: "type_info", scope: !243, file: !244, line: 178, type: !296, scopeLine: 178, flags: DIFlagPrototyped, spFlags: 0)
!296 = !DISubroutineType(types: !297)
!297 = !{null, !258, !266}
!298 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !191, entity: !299, file: !190, line: 73)
!299 = !DISubprogram(name: "rethrow_exception", linkageName: "_ZSt17rethrow_exceptionNSt15__exception_ptr13exception_ptrE", scope: !111, file: !190, line: 69, type: !300, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!300 = !DISubroutineType(types: !301)
!301 = !{null, !189}
!302 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !303, entity: !304, file: !305, line: 58)
!303 = !DINamespace(name: "__gnu_debug", scope: null)
!304 = !DINamespace(name: "__debug", scope: !111)
!305 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/debug/debug.h", directory: "/home/user/EDA-202")
!306 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !307, file: !322, line: 64)
!307 = !DIDerivedType(tag: DW_TAG_typedef, name: "mbstate_t", file: !308, line: 6, baseType: !309)
!308 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/mbstate_t.h", directory: "")
!309 = !DIDerivedType(tag: DW_TAG_typedef, name: "__mbstate_t", file: !310, line: 21, baseType: !311)
!310 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h", directory: "")
!311 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !310, line: 13, size: 64, flags: DIFlagTypePassByValue, elements: !312, identifier: "_ZTS11__mbstate_t")
!312 = !{!313, !314}
!313 = !DIDerivedType(tag: DW_TAG_member, name: "__count", scope: !311, file: !310, line: 15, baseType: !124, size: 32)
!314 = !DIDerivedType(tag: DW_TAG_member, name: "__value", scope: !311, file: !310, line: 20, baseType: !315, size: 32, offset: 32)
!315 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !311, file: !310, line: 16, size: 32, flags: DIFlagTypePassByValue, elements: !316, identifier: "_ZTSN11__mbstate_tUt_E")
!316 = !{!317, !318}
!317 = !DIDerivedType(tag: DW_TAG_member, name: "__wch", scope: !315, file: !310, line: 18, baseType: !95, size: 32)
!318 = !DIDerivedType(tag: DW_TAG_member, name: "__wchb", scope: !315, file: !310, line: 19, baseType: !319, size: 32)
!319 = !DICompositeType(tag: DW_TAG_array_type, baseType: !254, size: 32, elements: !320)
!320 = !{!321}
!321 = !DISubrange(count: 4, lowerBound: 0)
!322 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cwchar", directory: "/home/user/EDA-202")
!323 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !324, file: !322, line: 139)
!324 = !DIDerivedType(tag: DW_TAG_typedef, name: "wint_t", file: !325, line: 20, baseType: !95)
!325 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/wint_t.h", directory: "")
!326 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !327, file: !322, line: 141)
!327 = !DISubprogram(name: "btowc", scope: !328, file: !328, line: 309, type: !329, flags: DIFlagPrototyped, spFlags: 0)
!328 = !DIFile(filename: "/usr/include/wchar.h", directory: "")
!329 = !DISubroutineType(types: !330)
!330 = !{!324, !124}
!331 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !332, file: !322, line: 142)
!332 = !DISubprogram(name: "fgetwc", scope: !328, file: !328, line: 935, type: !333, flags: DIFlagPrototyped, spFlags: 0)
!333 = !DISubroutineType(types: !334)
!334 = !{!324, !335}
!335 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !336, size: 64)
!336 = !DIDerivedType(tag: DW_TAG_typedef, name: "__FILE", file: !337, line: 5, baseType: !338)
!337 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__FILE.h", directory: "")
!338 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !337, line: 4, flags: DIFlagFwdDecl, identifier: "_ZTS8_IO_FILE")
!339 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !340, file: !322, line: 143)
!340 = !DISubprogram(name: "fgetws", scope: !328, file: !328, line: 964, type: !341, flags: DIFlagPrototyped, spFlags: 0)
!341 = !DISubroutineType(types: !342)
!342 = !{!343, !345, !124, !346}
!343 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !344, size: 64)
!344 = !DIBasicType(name: "wchar_t", size: 32, encoding: DW_ATE_signed)
!345 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !343)
!346 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !335)
!347 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !348, file: !322, line: 144)
!348 = !DISubprogram(name: "fputwc", scope: !328, file: !328, line: 949, type: !349, flags: DIFlagPrototyped, spFlags: 0)
!349 = !DISubroutineType(types: !350)
!350 = !{!324, !344, !335}
!351 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !352, file: !322, line: 145)
!352 = !DISubprogram(name: "fputws", scope: !328, file: !328, line: 971, type: !353, flags: DIFlagPrototyped, spFlags: 0)
!353 = !DISubroutineType(types: !354)
!354 = !{!124, !355, !346}
!355 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !356)
!356 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !357, size: 64)
!357 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !344)
!358 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !359, file: !322, line: 146)
!359 = !DISubprogram(name: "fwide", scope: !328, file: !328, line: 725, type: !360, flags: DIFlagPrototyped, spFlags: 0)
!360 = !DISubroutineType(types: !361)
!361 = !{!124, !335, !124}
!362 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !363, file: !322, line: 147)
!363 = !DISubprogram(name: "fwprintf", scope: !328, file: !328, line: 732, type: !364, flags: DIFlagPrototyped, spFlags: 0)
!364 = !DISubroutineType(types: !365)
!365 = !{!124, !346, !355, null}
!366 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !367, file: !322, line: 148)
!367 = !DISubprogram(name: "fwscanf", linkageName: "__isoc23_fwscanf", scope: !328, file: !328, line: 795, type: !364, flags: DIFlagPrototyped, spFlags: 0)
!368 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !369, file: !322, line: 149)
!369 = !DISubprogram(name: "getwc", scope: !328, file: !328, line: 936, type: !333, flags: DIFlagPrototyped, spFlags: 0)
!370 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !371, file: !322, line: 150)
!371 = !DISubprogram(name: "getwchar", scope: !328, file: !328, line: 942, type: !372, flags: DIFlagPrototyped, spFlags: 0)
!372 = !DISubroutineType(types: !373)
!373 = !{!324}
!374 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !375, file: !322, line: 151)
!375 = !DISubprogram(name: "mbrlen", scope: !328, file: !328, line: 332, type: !376, flags: DIFlagPrototyped, spFlags: 0)
!376 = !DISubroutineType(types: !377)
!377 = !{!378, !380, !378, !381}
!378 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !379, line: 46, baseType: !162)
!379 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/stddef.h", directory: "/home/user/EDA-202")
!380 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !252)
!381 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !382)
!382 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !307, size: 64)
!383 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !384, file: !322, line: 152)
!384 = !DISubprogram(name: "mbrtowc", scope: !328, file: !328, line: 321, type: !385, flags: DIFlagPrototyped, spFlags: 0)
!385 = !DISubroutineType(types: !386)
!386 = !{!378, !345, !380, !378, !381}
!387 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !388, file: !322, line: 153)
!388 = !DISubprogram(name: "mbsinit", scope: !328, file: !328, line: 317, type: !389, flags: DIFlagPrototyped, spFlags: 0)
!389 = !DISubroutineType(types: !390)
!390 = !{!124, !391}
!391 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !392, size: 64)
!392 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !307)
!393 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !394, file: !322, line: 154)
!394 = !DISubprogram(name: "mbsrtowcs", scope: !328, file: !328, line: 362, type: !395, flags: DIFlagPrototyped, spFlags: 0)
!395 = !DISubroutineType(types: !396)
!396 = !{!378, !345, !397, !378, !381}
!397 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !398)
!398 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !252, size: 64)
!399 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !400, file: !322, line: 155)
!400 = !DISubprogram(name: "putwc", scope: !328, file: !328, line: 950, type: !349, flags: DIFlagPrototyped, spFlags: 0)
!401 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !402, file: !322, line: 156)
!402 = !DISubprogram(name: "putwchar", scope: !328, file: !328, line: 956, type: !403, flags: DIFlagPrototyped, spFlags: 0)
!403 = !DISubroutineType(types: !404)
!404 = !{!324, !344}
!405 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !406, file: !322, line: 158)
!406 = !DISubprogram(name: "swprintf", scope: !328, file: !328, line: 742, type: !407, flags: DIFlagPrototyped, spFlags: 0)
!407 = !DISubroutineType(types: !408)
!408 = !{!124, !345, !378, !355, null}
!409 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !410, file: !322, line: 160)
!410 = !DISubprogram(name: "swscanf", linkageName: "__isoc23_swscanf", scope: !328, file: !328, line: 802, type: !411, flags: DIFlagPrototyped, spFlags: 0)
!411 = !DISubroutineType(types: !412)
!412 = !{!124, !355, !355, null}
!413 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !414, file: !322, line: 161)
!414 = !DISubprogram(name: "ungetwc", scope: !328, file: !328, line: 979, type: !415, flags: DIFlagPrototyped, spFlags: 0)
!415 = !DISubroutineType(types: !416)
!416 = !{!324, !324, !335}
!417 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !418, file: !322, line: 162)
!418 = !DISubprogram(name: "vfwprintf", scope: !328, file: !328, line: 750, type: !419, flags: DIFlagPrototyped, spFlags: 0)
!419 = !DISubroutineType(types: !420)
!420 = !{!124, !346, !355, !421}
!421 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !422, line: 14, baseType: !423)
!422 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/stdarg.h", directory: "/home/user/EDA-202")
!423 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !424, baseType: !194)
!424 = !DIFile(filename: "csynth_r2/hls/.autopilot/db/laya_full_owner.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis")
!425 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !426, file: !322, line: 164)
!426 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc23_vfwscanf", scope: !328, file: !328, line: 875, type: !419, flags: DIFlagPrototyped, spFlags: 0)
!427 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !428, file: !322, line: 167)
!428 = !DISubprogram(name: "vswprintf", scope: !328, file: !328, line: 763, type: !429, flags: DIFlagPrototyped, spFlags: 0)
!429 = !DISubroutineType(types: !430)
!430 = !{!124, !345, !378, !355, !421}
!431 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !432, file: !322, line: 170)
!432 = !DISubprogram(name: "vswscanf", linkageName: "__isoc23_vswscanf", scope: !328, file: !328, line: 882, type: !433, flags: DIFlagPrototyped, spFlags: 0)
!433 = !DISubroutineType(types: !434)
!434 = !{!124, !355, !355, !421}
!435 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !436, file: !322, line: 172)
!436 = !DISubprogram(name: "vwprintf", scope: !328, file: !328, line: 758, type: !437, flags: DIFlagPrototyped, spFlags: 0)
!437 = !DISubroutineType(types: !438)
!438 = !{!124, !355, !421}
!439 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !440, file: !322, line: 174)
!440 = !DISubprogram(name: "vwscanf", linkageName: "__isoc23_vwscanf", scope: !328, file: !328, line: 879, type: !437, flags: DIFlagPrototyped, spFlags: 0)
!441 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !442, file: !322, line: 176)
!442 = !DISubprogram(name: "wcrtomb", scope: !328, file: !328, line: 326, type: !443, flags: DIFlagPrototyped, spFlags: 0)
!443 = !DISubroutineType(types: !444)
!444 = !{!378, !445, !344, !381}
!445 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !446)
!446 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !254, size: 64)
!447 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !448, file: !322, line: 177)
!448 = !DISubprogram(name: "wcscat", scope: !328, file: !328, line: 121, type: !449, flags: DIFlagPrototyped, spFlags: 0)
!449 = !DISubroutineType(types: !450)
!450 = !{!343, !345, !355}
!451 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !452, file: !322, line: 178)
!452 = !DISubprogram(name: "wcscmp", scope: !328, file: !328, line: 130, type: !453, flags: DIFlagPrototyped, spFlags: 0)
!453 = !DISubroutineType(types: !454)
!454 = !{!124, !356, !356}
!455 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !456, file: !322, line: 179)
!456 = !DISubprogram(name: "wcscoll", scope: !328, file: !328, line: 155, type: !453, flags: DIFlagPrototyped, spFlags: 0)
!457 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !458, file: !322, line: 180)
!458 = !DISubprogram(name: "wcscpy", scope: !328, file: !328, line: 98, type: !449, flags: DIFlagPrototyped, spFlags: 0)
!459 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !460, file: !322, line: 181)
!460 = !DISubprogram(name: "wcscspn", scope: !328, file: !328, line: 212, type: !461, flags: DIFlagPrototyped, spFlags: 0)
!461 = !DISubroutineType(types: !462)
!462 = !{!378, !356, !356}
!463 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !464, file: !322, line: 182)
!464 = !DISubprogram(name: "wcsftime", scope: !328, file: !328, line: 1043, type: !465, flags: DIFlagPrototyped, spFlags: 0)
!465 = !DISubroutineType(types: !466)
!466 = !{!378, !345, !378, !355, !467}
!467 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !468)
!468 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !469, size: 64)
!469 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !470)
!470 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tm", file: !328, line: 94, flags: DIFlagFwdDecl, identifier: "_ZTS2tm")
!471 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !472, file: !322, line: 183)
!472 = !DISubprogram(name: "wcslen", scope: !328, file: !328, line: 247, type: !473, flags: DIFlagPrototyped, spFlags: 0)
!473 = !DISubroutineType(types: !474)
!474 = !{!378, !356}
!475 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !476, file: !322, line: 184)
!476 = !DISubprogram(name: "wcsncat", scope: !328, file: !328, line: 125, type: !477, flags: DIFlagPrototyped, spFlags: 0)
!477 = !DISubroutineType(types: !478)
!478 = !{!343, !345, !355, !378}
!479 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !480, file: !322, line: 185)
!480 = !DISubprogram(name: "wcsncmp", scope: !328, file: !328, line: 133, type: !481, flags: DIFlagPrototyped, spFlags: 0)
!481 = !DISubroutineType(types: !482)
!482 = !{!124, !356, !356, !378}
!483 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !484, file: !322, line: 186)
!484 = !DISubprogram(name: "wcsncpy", scope: !328, file: !328, line: 103, type: !477, flags: DIFlagPrototyped, spFlags: 0)
!485 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !486, file: !322, line: 187)
!486 = !DISubprogram(name: "wcsrtombs", scope: !328, file: !328, line: 368, type: !487, flags: DIFlagPrototyped, spFlags: 0)
!487 = !DISubroutineType(types: !488)
!488 = !{!378, !445, !489, !378, !381}
!489 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !490)
!490 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !356, size: 64)
!491 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !492, file: !322, line: 188)
!492 = !DISubprogram(name: "wcsspn", scope: !328, file: !328, line: 216, type: !461, flags: DIFlagPrototyped, spFlags: 0)
!493 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !494, file: !322, line: 189)
!494 = !DISubprogram(name: "wcstod", scope: !328, file: !328, line: 402, type: !495, flags: DIFlagPrototyped, spFlags: 0)
!495 = !DISubroutineType(types: !496)
!496 = !{!497, !355, !498}
!497 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!498 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !499)
!499 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !343, size: 64)
!500 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !501, file: !322, line: 191)
!501 = !DISubprogram(name: "wcstof", scope: !328, file: !328, line: 407, type: !502, flags: DIFlagPrototyped, spFlags: 0)
!502 = !DISubroutineType(types: !503)
!503 = !{!504, !355, !498}
!504 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!505 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !506, file: !322, line: 193)
!506 = !DISubprogram(name: "wcstok", scope: !328, file: !328, line: 242, type: !507, flags: DIFlagPrototyped, spFlags: 0)
!507 = !DISubroutineType(types: !508)
!508 = !{!343, !345, !355, !498}
!509 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !510, file: !322, line: 194)
!510 = !DISubprogram(name: "wcstol", linkageName: "__isoc23_wcstol", scope: !328, file: !328, line: 500, type: !511, flags: DIFlagPrototyped, spFlags: 0)
!511 = !DISubroutineType(types: !512)
!512 = !{!128, !355, !498, !124}
!513 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !514, file: !322, line: 195)
!514 = !DISubprogram(name: "wcstoul", linkageName: "__isoc23_wcstoul", scope: !328, file: !328, line: 503, type: !515, flags: DIFlagPrototyped, spFlags: 0)
!515 = !DISubroutineType(types: !516)
!516 = !{!162, !355, !498, !124}
!517 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !518, file: !322, line: 196)
!518 = !DISubprogram(name: "wcsxfrm", scope: !328, file: !328, line: 159, type: !519, flags: DIFlagPrototyped, spFlags: 0)
!519 = !DISubroutineType(types: !520)
!520 = !{!378, !345, !355, !378}
!521 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !522, file: !322, line: 197)
!522 = !DISubprogram(name: "wctob", scope: !328, file: !328, line: 313, type: !523, flags: DIFlagPrototyped, spFlags: 0)
!523 = !DISubroutineType(types: !524)
!524 = !{!124, !324}
!525 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !526, file: !322, line: 198)
!526 = !DISubprogram(name: "wmemcmp", scope: !328, file: !328, line: 283, type: !481, flags: DIFlagPrototyped, spFlags: 0)
!527 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !528, file: !322, line: 199)
!528 = !DISubprogram(name: "wmemcpy", scope: !328, file: !328, line: 287, type: !477, flags: DIFlagPrototyped, spFlags: 0)
!529 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !530, file: !322, line: 200)
!530 = !DISubprogram(name: "wmemmove", scope: !328, file: !328, line: 292, type: !531, flags: DIFlagPrototyped, spFlags: 0)
!531 = !DISubroutineType(types: !532)
!532 = !{!343, !343, !356, !378}
!533 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !534, file: !322, line: 201)
!534 = !DISubprogram(name: "wmemset", scope: !328, file: !328, line: 296, type: !535, flags: DIFlagPrototyped, spFlags: 0)
!535 = !DISubroutineType(types: !536)
!536 = !{!343, !343, !344, !378}
!537 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !538, file: !322, line: 202)
!538 = !DISubprogram(name: "wprintf", scope: !328, file: !328, line: 739, type: !539, flags: DIFlagPrototyped, spFlags: 0)
!539 = !DISubroutineType(types: !540)
!540 = !{!124, !355, null}
!541 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !542, file: !322, line: 203)
!542 = !DISubprogram(name: "wscanf", linkageName: "__isoc23_wscanf", scope: !328, file: !328, line: 799, type: !539, flags: DIFlagPrototyped, spFlags: 0)
!543 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !544, file: !322, line: 204)
!544 = !DISubprogram(name: "wcschr", scope: !328, file: !328, line: 189, type: !545, flags: DIFlagPrototyped, spFlags: 0)
!545 = !DISubroutineType(types: !546)
!546 = !{!343, !356, !344}
!547 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !548, file: !322, line: 205)
!548 = !DISubprogram(name: "wcspbrk", scope: !328, file: !328, line: 226, type: !549, flags: DIFlagPrototyped, spFlags: 0)
!549 = !DISubroutineType(types: !550)
!550 = !{!343, !356, !356}
!551 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !552, file: !322, line: 206)
!552 = !DISubprogram(name: "wcsrchr", scope: !328, file: !328, line: 199, type: !545, flags: DIFlagPrototyped, spFlags: 0)
!553 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !554, file: !322, line: 207)
!554 = !DISubprogram(name: "wcsstr", scope: !328, file: !328, line: 237, type: !549, flags: DIFlagPrototyped, spFlags: 0)
!555 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !556, file: !322, line: 208)
!556 = !DISubprogram(name: "wmemchr", scope: !328, file: !328, line: 278, type: !557, flags: DIFlagPrototyped, spFlags: 0)
!557 = !DISubroutineType(types: !558)
!558 = !{!343, !356, !344, !378}
!559 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !561, file: !322, line: 248)
!560 = !DINamespace(name: "__gnu_cxx", scope: null)
!561 = !DISubprogram(name: "wcstold", scope: !328, file: !328, line: 409, type: !562, flags: DIFlagPrototyped, spFlags: 0)
!562 = !DISubroutineType(types: !563)
!563 = !{!564, !355, !498}
!564 = !DIBasicType(name: "long double", size: 64, encoding: DW_ATE_float)
!565 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !566, file: !322, line: 257)
!566 = !DISubprogram(name: "wcstoll", linkageName: "__isoc23_wcstoll", scope: !328, file: !328, line: 508, type: !567, flags: DIFlagPrototyped, spFlags: 0)
!567 = !DISubroutineType(types: !568)
!568 = !{!569, !355, !498, !124}
!569 = !DIBasicType(name: "long long", size: 64, encoding: DW_ATE_signed)
!570 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !571, file: !322, line: 258)
!571 = !DISubprogram(name: "wcstoull", linkageName: "__isoc23_wcstoull", scope: !328, file: !328, line: 513, type: !572, flags: DIFlagPrototyped, spFlags: 0)
!572 = !DISubroutineType(types: !573)
!573 = !{!574, !355, !498, !124}
!574 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!575 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !561, file: !322, line: 264)
!576 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !566, file: !322, line: 265)
!577 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !571, file: !322, line: 266)
!578 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !501, file: !322, line: 280)
!579 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !426, file: !322, line: 283)
!580 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !432, file: !322, line: 286)
!581 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !440, file: !322, line: 289)
!582 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !561, file: !322, line: 293)
!583 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !566, file: !322, line: 294)
!584 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !571, file: !322, line: 295)
!585 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !272, file: !586, line: 44)
!586 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/ext/new_allocator.h", directory: "/home/user/EDA-202")
!587 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !588, file: !586, line: 45)
!588 = !DIDerivedType(tag: DW_TAG_typedef, name: "ptrdiff_t", scope: !111, file: !217, line: 239, baseType: !128)
!589 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !590, file: !592, line: 53)
!590 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "lconv", file: !591, line: 51, size: 768, flags: DIFlagFwdDecl, identifier: "_ZTS5lconv")
!591 = !DIFile(filename: "/usr/include/locale.h", directory: "")
!592 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/clocale", directory: "/home/user/EDA-202")
!593 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !594, file: !592, line: 54)
!594 = !DISubprogram(name: "setlocale", scope: !591, file: !591, line: 122, type: !595, flags: DIFlagPrototyped, spFlags: 0)
!595 = !DISubroutineType(types: !596)
!596 = !{!446, !124, !252}
!597 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !598, file: !592, line: 55)
!598 = !DISubprogram(name: "localeconv", scope: !591, file: !591, line: 125, type: !599, flags: DIFlagPrototyped, spFlags: 0)
!599 = !DISubroutineType(types: !600)
!600 = !{!601}
!601 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !590, size: 64)
!602 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !603, file: !607, line: 64)
!603 = !DISubprogram(name: "isalnum", scope: !604, file: !604, line: 108, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!604 = !DIFile(filename: "/usr/include/ctype.h", directory: "")
!605 = !DISubroutineType(types: !606)
!606 = !{!124, !124}
!607 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cctype", directory: "/home/user/EDA-202")
!608 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !609, file: !607, line: 65)
!609 = !DISubprogram(name: "isalpha", scope: !604, file: !604, line: 109, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!610 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !611, file: !607, line: 66)
!611 = !DISubprogram(name: "iscntrl", scope: !604, file: !604, line: 110, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!612 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !613, file: !607, line: 67)
!613 = !DISubprogram(name: "isdigit", scope: !604, file: !604, line: 111, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!614 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !615, file: !607, line: 68)
!615 = !DISubprogram(name: "isgraph", scope: !604, file: !604, line: 113, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!616 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !617, file: !607, line: 69)
!617 = !DISubprogram(name: "islower", scope: !604, file: !604, line: 112, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!618 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !619, file: !607, line: 70)
!619 = !DISubprogram(name: "isprint", scope: !604, file: !604, line: 114, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!620 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !621, file: !607, line: 71)
!621 = !DISubprogram(name: "ispunct", scope: !604, file: !604, line: 115, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!622 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !623, file: !607, line: 72)
!623 = !DISubprogram(name: "isspace", scope: !604, file: !604, line: 116, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!624 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !625, file: !607, line: 73)
!625 = !DISubprogram(name: "isupper", scope: !604, file: !604, line: 117, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!626 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !627, file: !607, line: 74)
!627 = !DISubprogram(name: "isxdigit", scope: !604, file: !604, line: 118, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!628 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !629, file: !607, line: 75)
!629 = !DISubprogram(name: "tolower", scope: !604, file: !604, line: 122, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!630 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !631, file: !607, line: 76)
!631 = !DISubprogram(name: "toupper", scope: !604, file: !604, line: 125, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!632 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !633, file: !607, line: 87)
!633 = !DISubprogram(name: "isblank", scope: !604, file: !604, line: 130, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!634 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !635, file: !637, line: 52)
!635 = !DISubprogram(name: "abs", scope: !636, file: !636, line: 980, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!636 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!637 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/std_abs.h", directory: "/home/user/EDA-202")
!638 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !639, file: !641, line: 127)
!639 = !DIDerivedType(tag: DW_TAG_typedef, name: "div_t", file: !636, line: 63, baseType: !640)
!640 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !636, line: 59, size: 64, flags: DIFlagFwdDecl, identifier: "_ZTS5div_t")
!641 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdlib", directory: "/home/user/EDA-202")
!642 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !643, file: !641, line: 128)
!643 = !DIDerivedType(tag: DW_TAG_typedef, name: "ldiv_t", file: !636, line: 71, baseType: !644)
!644 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !636, line: 67, size: 128, flags: DIFlagTypePassByValue, elements: !645, identifier: "_ZTS6ldiv_t")
!645 = !{!646, !647}
!646 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !644, file: !636, line: 69, baseType: !128, size: 64)
!647 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !644, file: !636, line: 70, baseType: !128, size: 64, offset: 64)
!648 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !649, file: !641, line: 130)
!649 = !DISubprogram(name: "abort", scope: !636, file: !636, line: 730, type: !650, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!650 = !DISubroutineType(types: !651)
!651 = !{null}
!652 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !653, file: !641, line: 132)
!653 = !DISubprogram(name: "aligned_alloc", scope: !636, file: !636, line: 724, type: !654, flags: DIFlagPrototyped, spFlags: 0)
!654 = !DISubroutineType(types: !655)
!655 = !{!194, !378, !378}
!656 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !657, file: !641, line: 134)
!657 = !DISubprogram(name: "atexit", scope: !636, file: !636, line: 734, type: !658, flags: DIFlagPrototyped, spFlags: 0)
!658 = !DISubroutineType(types: !659)
!659 = !{!124, !660}
!660 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !650, size: 64)
!661 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !662, file: !641, line: 137)
!662 = !DISubprogram(name: "at_quick_exit", scope: !636, file: !636, line: 739, type: !658, flags: DIFlagPrototyped, spFlags: 0)
!663 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !664, file: !641, line: 140)
!664 = !DISubprogram(name: "atof", scope: !636, file: !636, line: 102, type: !665, flags: DIFlagPrototyped, spFlags: 0)
!665 = !DISubroutineType(types: !666)
!666 = !{!497, !252}
!667 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !668, file: !641, line: 141)
!668 = !DISubprogram(name: "atoi", scope: !636, file: !636, line: 105, type: !669, flags: DIFlagPrototyped, spFlags: 0)
!669 = !DISubroutineType(types: !670)
!670 = !{!124, !252}
!671 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !672, file: !641, line: 142)
!672 = !DISubprogram(name: "atol", scope: !636, file: !636, line: 108, type: !673, flags: DIFlagPrototyped, spFlags: 0)
!673 = !DISubroutineType(types: !674)
!674 = !{!128, !252}
!675 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !676, file: !641, line: 143)
!676 = !DISubprogram(name: "bsearch", scope: !636, file: !636, line: 960, type: !677, flags: DIFlagPrototyped, spFlags: 0)
!677 = !DISubroutineType(types: !678)
!678 = !{!194, !679, !679, !378, !378, !681}
!679 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !680, size: 64)
!680 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!681 = !DIDerivedType(tag: DW_TAG_typedef, name: "__compar_fn_t", file: !636, line: 948, baseType: !682)
!682 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !683, size: 64)
!683 = !DISubroutineType(types: !684)
!684 = !{!124, !679, !679}
!685 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !686, file: !641, line: 144)
!686 = !DISubprogram(name: "calloc", scope: !636, file: !636, line: 675, type: !654, flags: DIFlagPrototyped, spFlags: 0)
!687 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !688, file: !641, line: 145)
!688 = !DISubprogram(name: "div", scope: !636, file: !636, line: 992, type: !689, flags: DIFlagPrototyped, spFlags: 0)
!689 = !DISubroutineType(types: !690)
!690 = !{!639, !124, !124}
!691 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !692, file: !641, line: 146)
!692 = !DISubprogram(name: "exit", scope: !636, file: !636, line: 756, type: !693, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!693 = !DISubroutineType(types: !694)
!694 = !{null, !124}
!695 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !696, file: !641, line: 147)
!696 = !DISubprogram(name: "free", scope: !636, file: !636, line: 687, type: !697, flags: DIFlagPrototyped, spFlags: 0)
!697 = !DISubroutineType(types: !698)
!698 = !{null, !194}
!699 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !700, file: !641, line: 148)
!700 = !DISubprogram(name: "getenv", scope: !636, file: !636, line: 773, type: !701, flags: DIFlagPrototyped, spFlags: 0)
!701 = !DISubroutineType(types: !702)
!702 = !{!446, !252}
!703 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !704, file: !641, line: 149)
!704 = !DISubprogram(name: "labs", scope: !636, file: !636, line: 981, type: !705, flags: DIFlagPrototyped, spFlags: 0)
!705 = !DISubroutineType(types: !706)
!706 = !{!128, !128}
!707 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !708, file: !641, line: 150)
!708 = !DISubprogram(name: "ldiv", scope: !636, file: !636, line: 994, type: !709, flags: DIFlagPrototyped, spFlags: 0)
!709 = !DISubroutineType(types: !710)
!710 = !{!643, !128, !128}
!711 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !712, file: !641, line: 151)
!712 = !DISubprogram(name: "malloc", scope: !636, file: !636, line: 672, type: !713, flags: DIFlagPrototyped, spFlags: 0)
!713 = !DISubroutineType(types: !714)
!714 = !{!194, !378}
!715 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !716, file: !641, line: 153)
!716 = !DISubprogram(name: "mblen", scope: !636, file: !636, line: 1062, type: !717, flags: DIFlagPrototyped, spFlags: 0)
!717 = !DISubroutineType(types: !718)
!718 = !{!124, !252, !378}
!719 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !720, file: !641, line: 154)
!720 = !DISubprogram(name: "mbstowcs", scope: !636, file: !636, line: 1073, type: !721, flags: DIFlagPrototyped, spFlags: 0)
!721 = !DISubroutineType(types: !722)
!722 = !{!378, !345, !380, !378}
!723 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !724, file: !641, line: 155)
!724 = !DISubprogram(name: "mbtowc", scope: !636, file: !636, line: 1065, type: !725, flags: DIFlagPrototyped, spFlags: 0)
!725 = !DISubroutineType(types: !726)
!726 = !{!124, !345, !380, !378}
!727 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !728, file: !641, line: 157)
!728 = !DISubprogram(name: "qsort", scope: !636, file: !636, line: 970, type: !729, flags: DIFlagPrototyped, spFlags: 0)
!729 = !DISubroutineType(types: !730)
!730 = !{null, !194, !378, !378, !681}
!731 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !732, file: !641, line: 160)
!732 = !DISubprogram(name: "quick_exit", scope: !636, file: !636, line: 762, type: !693, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!733 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !734, file: !641, line: 163)
!734 = !DISubprogram(name: "rand", scope: !636, file: !636, line: 573, type: !249, flags: DIFlagPrototyped, spFlags: 0)
!735 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !736, file: !641, line: 164)
!736 = !DISubprogram(name: "realloc", scope: !636, file: !636, line: 683, type: !737, flags: DIFlagPrototyped, spFlags: 0)
!737 = !DISubroutineType(types: !738)
!738 = !{!194, !194, !378}
!739 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !740, file: !641, line: 165)
!740 = !DISubprogram(name: "srand", scope: !636, file: !636, line: 575, type: !741, flags: DIFlagPrototyped, spFlags: 0)
!741 = !DISubroutineType(types: !742)
!742 = !{null, !95}
!743 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !744, file: !641, line: 166)
!744 = !DISubprogram(name: "strtod", scope: !636, file: !636, line: 118, type: !745, flags: DIFlagPrototyped, spFlags: 0)
!745 = !DISubroutineType(types: !746)
!746 = !{!497, !380, !747}
!747 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !748)
!748 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !446, size: 64)
!749 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !750, file: !641, line: 167)
!750 = !DISubprogram(name: "strtol", linkageName: "__isoc23_strtol", scope: !636, file: !636, line: 215, type: !751, flags: DIFlagPrototyped, spFlags: 0)
!751 = !DISubroutineType(types: !752)
!752 = !{!128, !380, !747, !124}
!753 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !754, file: !641, line: 168)
!754 = !DISubprogram(name: "strtoul", linkageName: "__isoc23_strtoul", scope: !636, file: !636, line: 219, type: !755, flags: DIFlagPrototyped, spFlags: 0)
!755 = !DISubroutineType(types: !756)
!756 = !{!162, !380, !747, !124}
!757 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !758, file: !641, line: 169)
!758 = !DISubprogram(name: "system", scope: !636, file: !636, line: 923, type: !669, flags: DIFlagPrototyped, spFlags: 0)
!759 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !760, file: !641, line: 171)
!760 = !DISubprogram(name: "wcstombs", scope: !636, file: !636, line: 1077, type: !761, flags: DIFlagPrototyped, spFlags: 0)
!761 = !DISubroutineType(types: !762)
!762 = !{!378, !445, !355, !378}
!763 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !764, file: !641, line: 172)
!764 = !DISubprogram(name: "wctomb", scope: !636, file: !636, line: 1069, type: !765, flags: DIFlagPrototyped, spFlags: 0)
!765 = !DISubroutineType(types: !766)
!766 = !{!124, !446, !344}
!767 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !768, file: !641, line: 200)
!768 = !DIDerivedType(tag: DW_TAG_typedef, name: "lldiv_t", file: !636, line: 81, baseType: !769)
!769 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !636, line: 77, size: 128, flags: DIFlagTypePassByValue, elements: !770, identifier: "_ZTS7lldiv_t")
!770 = !{!771, !772}
!771 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !769, file: !636, line: 79, baseType: !569, size: 64)
!772 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !769, file: !636, line: 80, baseType: !569, size: 64, offset: 64)
!773 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !774, file: !641, line: 206)
!774 = !DISubprogram(name: "_Exit", scope: !636, file: !636, line: 768, type: !693, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!775 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !776, file: !641, line: 210)
!776 = !DISubprogram(name: "llabs", scope: !636, file: !636, line: 984, type: !777, flags: DIFlagPrototyped, spFlags: 0)
!777 = !DISubroutineType(types: !778)
!778 = !{!569, !569}
!779 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !780, file: !641, line: 216)
!780 = !DISubprogram(name: "lldiv", scope: !636, file: !636, line: 998, type: !781, flags: DIFlagPrototyped, spFlags: 0)
!781 = !DISubroutineType(types: !782)
!782 = !{!768, !569, !569}
!783 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !784, file: !641, line: 227)
!784 = !DISubprogram(name: "atoll", scope: !636, file: !636, line: 113, type: !785, flags: DIFlagPrototyped, spFlags: 0)
!785 = !DISubroutineType(types: !786)
!786 = !{!569, !252}
!787 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !788, file: !641, line: 228)
!788 = !DISubprogram(name: "strtoll", linkageName: "__isoc23_strtoll", scope: !636, file: !636, line: 238, type: !789, flags: DIFlagPrototyped, spFlags: 0)
!789 = !DISubroutineType(types: !790)
!790 = !{!569, !380, !747, !124}
!791 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !792, file: !641, line: 229)
!792 = !DISubprogram(name: "strtoull", linkageName: "__isoc23_strtoull", scope: !636, file: !636, line: 243, type: !793, flags: DIFlagPrototyped, spFlags: 0)
!793 = !DISubroutineType(types: !794)
!794 = !{!574, !380, !747, !124}
!795 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !796, file: !641, line: 231)
!796 = !DISubprogram(name: "strtof", scope: !636, file: !636, line: 124, type: !797, flags: DIFlagPrototyped, spFlags: 0)
!797 = !DISubroutineType(types: !798)
!798 = !{!504, !380, !747}
!799 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !800, file: !641, line: 232)
!800 = !DISubprogram(name: "strtold", scope: !636, file: !636, line: 127, type: !801, flags: DIFlagPrototyped, spFlags: 0)
!801 = !DISubroutineType(types: !802)
!802 = !{!564, !380, !747}
!803 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !768, file: !641, line: 240)
!804 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !774, file: !641, line: 242)
!805 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !776, file: !641, line: 244)
!806 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !807, file: !641, line: 245)
!807 = !DISubprogram(name: "div", linkageName: "_ZN9__gnu_cxx3divExx", scope: !560, file: !641, line: 213, type: !781, flags: DIFlagPrototyped, spFlags: 0)
!808 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !780, file: !641, line: 246)
!809 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !784, file: !641, line: 248)
!810 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !796, file: !641, line: 249)
!811 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !788, file: !641, line: 250)
!812 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !792, file: !641, line: 251)
!813 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !800, file: !641, line: 252)
!814 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !815, file: !817, line: 98)
!815 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !816, line: 7, baseType: !338)
!816 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/FILE.h", directory: "")
!817 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdio", directory: "/home/user/EDA-202")
!818 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !819, file: !817, line: 99)
!819 = !DIDerivedType(tag: DW_TAG_typedef, name: "fpos_t", file: !820, line: 85, baseType: !821)
!820 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!821 = !DIDerivedType(tag: DW_TAG_typedef, name: "__fpos_t", file: !822, line: 14, baseType: !823)
!822 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h", directory: "")
!823 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_G_fpos_t", file: !822, line: 10, size: 128, flags: DIFlagFwdDecl, identifier: "_ZTS9_G_fpos_t")
!824 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !825, file: !817, line: 101)
!825 = !DISubprogram(name: "clearerr", scope: !820, file: !820, line: 860, type: !826, flags: DIFlagPrototyped, spFlags: 0)
!826 = !DISubroutineType(types: !827)
!827 = !{null, !828}
!828 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !815, size: 64)
!829 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !830, file: !817, line: 102)
!830 = !DISubprogram(name: "fclose", scope: !820, file: !820, line: 184, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!831 = !DISubroutineType(types: !832)
!832 = !{!124, !828}
!833 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !834, file: !817, line: 103)
!834 = !DISubprogram(name: "feof", scope: !820, file: !820, line: 862, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!835 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !836, file: !817, line: 104)
!836 = !DISubprogram(name: "ferror", scope: !820, file: !820, line: 864, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!837 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !838, file: !817, line: 105)
!838 = !DISubprogram(name: "fflush", scope: !820, file: !820, line: 236, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!839 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !840, file: !817, line: 106)
!840 = !DISubprogram(name: "fgetc", scope: !820, file: !820, line: 575, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!841 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !842, file: !817, line: 107)
!842 = !DISubprogram(name: "fgetpos", scope: !820, file: !820, line: 829, type: !843, flags: DIFlagPrototyped, spFlags: 0)
!843 = !DISubroutineType(types: !844)
!844 = !{!124, !845, !846}
!845 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !828)
!846 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !847)
!847 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !819, size: 64)
!848 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !849, file: !817, line: 108)
!849 = !DISubprogram(name: "fgets", scope: !820, file: !820, line: 654, type: !850, flags: DIFlagPrototyped, spFlags: 0)
!850 = !DISubroutineType(types: !851)
!851 = !{!446, !445, !124, !845}
!852 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !853, file: !817, line: 109)
!853 = !DISubprogram(name: "fopen", scope: !820, file: !820, line: 264, type: !854, flags: DIFlagPrototyped, spFlags: 0)
!854 = !DISubroutineType(types: !855)
!855 = !{!828, !380, !380}
!856 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !857, file: !817, line: 110)
!857 = !DISubprogram(name: "fprintf", scope: !820, file: !820, line: 357, type: !858, flags: DIFlagPrototyped, spFlags: 0)
!858 = !DISubroutineType(types: !859)
!859 = !{!124, !845, !380, null}
!860 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !861, file: !817, line: 111)
!861 = !DISubprogram(name: "fputc", scope: !820, file: !820, line: 611, type: !862, flags: DIFlagPrototyped, spFlags: 0)
!862 = !DISubroutineType(types: !863)
!863 = !{!124, !124, !828}
!864 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !865, file: !817, line: 112)
!865 = !DISubprogram(name: "fputs", scope: !820, file: !820, line: 717, type: !866, flags: DIFlagPrototyped, spFlags: 0)
!866 = !DISubroutineType(types: !867)
!867 = !{!124, !380, !845}
!868 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !869, file: !817, line: 113)
!869 = !DISubprogram(name: "fread", scope: !820, file: !820, line: 738, type: !870, flags: DIFlagPrototyped, spFlags: 0)
!870 = !DISubroutineType(types: !871)
!871 = !{!378, !872, !378, !378, !845}
!872 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !194)
!873 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !874, file: !817, line: 114)
!874 = !DISubprogram(name: "freopen", scope: !820, file: !820, line: 271, type: !875, flags: DIFlagPrototyped, spFlags: 0)
!875 = !DISubroutineType(types: !876)
!876 = !{!828, !380, !380, !845}
!877 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !878, file: !817, line: 115)
!878 = !DISubprogram(name: "fscanf", linkageName: "__isoc23_fscanf", scope: !820, file: !820, line: 442, type: !858, flags: DIFlagPrototyped, spFlags: 0)
!879 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !880, file: !817, line: 116)
!880 = !DISubprogram(name: "fseek", scope: !820, file: !820, line: 779, type: !881, flags: DIFlagPrototyped, spFlags: 0)
!881 = !DISubroutineType(types: !882)
!882 = !{!124, !828, !128, !124}
!883 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !884, file: !817, line: 117)
!884 = !DISubprogram(name: "fsetpos", scope: !820, file: !820, line: 835, type: !885, flags: DIFlagPrototyped, spFlags: 0)
!885 = !DISubroutineType(types: !886)
!886 = !{!124, !828, !887}
!887 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !888, size: 64)
!888 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !819)
!889 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !890, file: !817, line: 118)
!890 = !DISubprogram(name: "ftell", scope: !820, file: !820, line: 785, type: !891, flags: DIFlagPrototyped, spFlags: 0)
!891 = !DISubroutineType(types: !892)
!892 = !{!128, !828}
!893 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !894, file: !817, line: 119)
!894 = !DISubprogram(name: "fwrite", scope: !820, file: !820, line: 745, type: !895, flags: DIFlagPrototyped, spFlags: 0)
!895 = !DISubroutineType(types: !896)
!896 = !{!378, !897, !378, !378, !845}
!897 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !679)
!898 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !899, file: !817, line: 120)
!899 = !DISubprogram(name: "getc", scope: !820, file: !820, line: 576, type: !831, flags: DIFlagPrototyped, spFlags: 0)
!900 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !901, file: !817, line: 121)
!901 = !DISubprogram(name: "getchar", scope: !820, file: !820, line: 582, type: !249, flags: DIFlagPrototyped, spFlags: 0)
!902 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !903, file: !817, line: 126)
!903 = !DISubprogram(name: "perror", scope: !820, file: !820, line: 878, type: !904, flags: DIFlagPrototyped, spFlags: 0)
!904 = !DISubroutineType(types: !905)
!905 = !{null, !252}
!906 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !907, file: !817, line: 127)
!907 = !DISubprogram(name: "printf", scope: !820, file: !820, line: 363, type: !908, flags: DIFlagPrototyped, spFlags: 0)
!908 = !DISubroutineType(types: !909)
!909 = !{!124, !380, null}
!910 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !911, file: !817, line: 128)
!911 = !DISubprogram(name: "putc", scope: !820, file: !820, line: 612, type: !862, flags: DIFlagPrototyped, spFlags: 0)
!912 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !913, file: !817, line: 129)
!913 = !DISubprogram(name: "putchar", scope: !820, file: !820, line: 618, type: !605, flags: DIFlagPrototyped, spFlags: 0)
!914 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !915, file: !817, line: 130)
!915 = !DISubprogram(name: "puts", scope: !820, file: !820, line: 724, type: !669, flags: DIFlagPrototyped, spFlags: 0)
!916 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !917, file: !817, line: 131)
!917 = !DISubprogram(name: "remove", scope: !820, file: !820, line: 158, type: !669, flags: DIFlagPrototyped, spFlags: 0)
!918 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !919, file: !817, line: 132)
!919 = !DISubprogram(name: "rename", scope: !820, file: !820, line: 160, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!920 = !DISubroutineType(types: !921)
!921 = !{!124, !252, !252}
!922 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !923, file: !817, line: 133)
!923 = !DISubprogram(name: "rewind", scope: !820, file: !820, line: 790, type: !826, flags: DIFlagPrototyped, spFlags: 0)
!924 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !925, file: !817, line: 134)
!925 = !DISubprogram(name: "scanf", linkageName: "__isoc23_scanf", scope: !820, file: !820, line: 445, type: !908, flags: DIFlagPrototyped, spFlags: 0)
!926 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !927, file: !817, line: 135)
!927 = !DISubprogram(name: "setbuf", scope: !820, file: !820, line: 334, type: !928, flags: DIFlagPrototyped, spFlags: 0)
!928 = !DISubroutineType(types: !929)
!929 = !{null, !845, !445}
!930 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !931, file: !817, line: 136)
!931 = !DISubprogram(name: "setvbuf", scope: !820, file: !820, line: 339, type: !932, flags: DIFlagPrototyped, spFlags: 0)
!932 = !DISubroutineType(types: !933)
!933 = !{!124, !845, !445, !124, !378}
!934 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !935, file: !817, line: 137)
!935 = !DISubprogram(name: "sprintf", scope: !820, file: !820, line: 365, type: !936, flags: DIFlagPrototyped, spFlags: 0)
!936 = !DISubroutineType(types: !937)
!937 = !{!124, !445, !380, null}
!938 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !939, file: !817, line: 138)
!939 = !DISubprogram(name: "sscanf", linkageName: "__isoc23_sscanf", scope: !820, file: !820, line: 447, type: !940, flags: DIFlagPrototyped, spFlags: 0)
!940 = !DISubroutineType(types: !941)
!941 = !{!124, !380, !380, null}
!942 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !943, file: !817, line: 139)
!943 = !DISubprogram(name: "tmpfile", scope: !820, file: !820, line: 194, type: !944, flags: DIFlagPrototyped, spFlags: 0)
!944 = !DISubroutineType(types: !945)
!945 = !{!828}
!946 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !947, file: !817, line: 141)
!947 = !DISubprogram(name: "tmpnam", scope: !820, file: !820, line: 211, type: !948, flags: DIFlagPrototyped, spFlags: 0)
!948 = !DISubroutineType(types: !949)
!949 = !{!446, !446}
!950 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !951, file: !817, line: 143)
!951 = !DISubprogram(name: "ungetc", scope: !820, file: !820, line: 731, type: !862, flags: DIFlagPrototyped, spFlags: 0)
!952 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !953, file: !817, line: 144)
!953 = !DISubprogram(name: "vfprintf", scope: !820, file: !820, line: 372, type: !954, flags: DIFlagPrototyped, spFlags: 0)
!954 = !DISubroutineType(types: !955)
!955 = !{!124, !845, !380, !421}
!956 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !957, file: !817, line: 145)
!957 = !DISubprogram(name: "vprintf", scope: !820, file: !820, line: 378, type: !958, flags: DIFlagPrototyped, spFlags: 0)
!958 = !DISubroutineType(types: !959)
!959 = !{!124, !380, !421}
!960 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !961, file: !817, line: 146)
!961 = !DISubprogram(name: "vsprintf", scope: !820, file: !820, line: 380, type: !962, flags: DIFlagPrototyped, spFlags: 0)
!962 = !DISubroutineType(types: !963)
!963 = !{!124, !445, !380, !421}
!964 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !965, file: !817, line: 175)
!965 = !DISubprogram(name: "snprintf", scope: !820, file: !820, line: 385, type: !966, flags: DIFlagPrototyped, spFlags: 0)
!966 = !DISubroutineType(types: !967)
!967 = !{!124, !445, !378, !380, null}
!968 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !969, file: !817, line: 176)
!969 = !DISubprogram(name: "vfscanf", linkageName: "__isoc23_vfscanf", scope: !820, file: !820, line: 511, type: !954, flags: DIFlagPrototyped, spFlags: 0)
!970 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !971, file: !817, line: 177)
!971 = !DISubprogram(name: "vscanf", linkageName: "__isoc23_vscanf", scope: !820, file: !820, line: 516, type: !958, flags: DIFlagPrototyped, spFlags: 0)
!972 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !973, file: !817, line: 178)
!973 = !DISubprogram(name: "vsnprintf", scope: !820, file: !820, line: 389, type: !974, flags: DIFlagPrototyped, spFlags: 0)
!974 = !DISubroutineType(types: !975)
!975 = !{!124, !445, !378, !380, !421}
!976 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !977, file: !817, line: 179)
!977 = !DISubprogram(name: "vsscanf", linkageName: "__isoc23_vsscanf", scope: !820, file: !820, line: 519, type: !978, flags: DIFlagPrototyped, spFlags: 0)
!978 = !DISubroutineType(types: !979)
!979 = !{!124, !380, !380, !421}
!980 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !965, file: !817, line: 185)
!981 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !969, file: !817, line: 186)
!982 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !971, file: !817, line: 187)
!983 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !973, file: !817, line: 188)
!984 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !977, file: !817, line: 189)
!985 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !986, file: !989, line: 56)
!986 = !DIDerivedType(tag: DW_TAG_typedef, name: "max_align_t", file: !987, line: 24, baseType: !988)
!987 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/__stddef_max_align_t.h", directory: "/home/user/EDA-202")
!988 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !987, line: 19, size: 128, flags: DIFlagFwdDecl, identifier: "_ZTS11max_align_t")
!989 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstddef", directory: "/home/user/EDA-202")
!990 = !{}
!991 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !992)
!992 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 128, elements: !993)
!993 = !{!994}
!994 = !DISubrange(count: 8, lowerBound: 0)
!995 = !DIGlobalVariableExpression(var: !996, expr: !DIExpression())
!996 = distinct !DIGlobalVariable(name: "runtime", linkageName: "_ZN12_GLOBAL__N_17runtimeE", scope: !997, file: !998, line: 6, type: !999, isLocal: true, isDefinition: true)
!997 = !DINamespace(scope: null)
!998 = !DIFile(filename: "tests/full_owner_index_pilot.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!999 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullRuntime", scope: !5, file: !1000, line: 122, size: 629632, flags: DIFlagTypePassByValue, elements: !1001, identifier: "_ZTSN4laya4full11FullRuntimeE")
!1000 = !DIFile(filename: "include/laya_full_runtime.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1001 = !{!1002, !1035, !1081, !1121, !1149, !1150, !1152, !1153, !1154, !1155, !1156, !1157, !1158, !1159, !1160, !1161, !1162, !1163, !1164, !1165, !1178, !1180, !1181, !1182, !1183, !1184, !1185, !1189, !1190, !1191, !1192, !1193, !1194, !1195, !1196, !1197, !1198, !1199, !1200, !1201, !1212, !1213, !1214, !1215, !1216}
!1002 = !DIDerivedType(tag: DW_TAG_member, name: "inputs", scope: !999, file: !1000, line: 128, baseType: !1003, size: 83968)
!1003 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullInputs", scope: !5, file: !1000, line: 29, size: 83968, flags: DIFlagTypePassByValue, elements: !1004, identifier: "_ZTSN4laya4full10FullInputsE")
!1004 = !{!1005, !1020, !1025, !1028, !1030, !1032}
!1005 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1003, file: !1000, line: 30, baseType: !1006, size: 704)
!1006 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "NumericIdentity", scope: !6, file: !1007, line: 10, size: 704, flags: DIFlagTypePassByValue, elements: !1008, identifier: "_ZTSN4laya15NumericIdentityE")
!1007 = !DIFile(filename: "include/laya_numeric_tasks.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1008 = !{!1009, !1010, !1011, !1012, !1013, !1017, !1018, !1019}
!1009 = !DIDerivedType(tag: DW_TAG_member, name: "request_id", scope: !1006, file: !1007, line: 11, baseType: !160, size: 64)
!1010 = !DIDerivedType(tag: DW_TAG_member, name: "generation", scope: !1006, file: !1007, line: 12, baseType: !160, size: 64, offset: 64)
!1011 = !DIDerivedType(tag: DW_TAG_member, name: "B", scope: !1006, file: !1007, line: 13, baseType: !9, size: 16, offset: 128)
!1012 = !DIDerivedType(tag: DW_TAG_member, name: "S", scope: !1006, file: !1007, line: 13, baseType: !9, size: 16, offset: 144)
!1013 = !DIDerivedType(tag: DW_TAG_member, name: "model_tag", scope: !1006, file: !1007, line: 14, baseType: !1014, size: 128, offset: 160)
!1014 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 128, elements: !1015)
!1015 = !{!1016}
!1016 = !DISubrange(count: 16, lowerBound: 0)
!1017 = !DIDerivedType(tag: DW_TAG_member, name: "numeric_tag", scope: !1006, file: !1007, line: 15, baseType: !1014, size: 128, offset: 288)
!1018 = !DIDerivedType(tag: DW_TAG_member, name: "layout_tag", scope: !1006, file: !1007, line: 16, baseType: !1014, size: 128, offset: 416)
!1019 = !DIDerivedType(tag: DW_TAG_member, name: "build_tag", scope: !1006, file: !1007, line: 17, baseType: !1014, size: 128, offset: 544)
!1020 = !DIDerivedType(tag: DW_TAG_member, name: "token_ids", scope: !1003, file: !1000, line: 31, baseType: !1021, size: 65536, offset: 704)
!1021 = !DICompositeType(tag: DW_TAG_array_type, baseType: !122, size: 65536, elements: !1022)
!1022 = !{!1023, !1024}
!1023 = !DISubrange(count: 2, lowerBound: 0)
!1024 = !DISubrange(count: 1024, lowerBound: 0)
!1025 = !DIDerivedType(tag: DW_TAG_member, name: "marker_positions", scope: !1003, file: !1000, line: 32, baseType: !1026, size: 1024, offset: 66240)
!1026 = !DICompositeType(tag: DW_TAG_array_type, baseType: !122, size: 1024, elements: !1027)
!1027 = !{!1023, !1016}
!1028 = !DIDerivedType(tag: DW_TAG_member, name: "attention_mask", scope: !1003, file: !1000, line: 33, baseType: !1029, size: 16384, offset: 67264)
!1029 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 16384, elements: !1022)
!1030 = !DIDerivedType(tag: DW_TAG_member, name: "marker_mask", scope: !1003, file: !1000, line: 34, baseType: !1031, size: 256, offset: 83648)
!1031 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 256, elements: !1027)
!1032 = !DIDerivedType(tag: DW_TAG_member, name: "qtype", scope: !1003, file: !1000, line: 35, baseType: !1033, size: 16, offset: 83904)
!1033 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 16, elements: !1034)
!1034 = !{!1023}
!1035 = !DIDerivedType(tag: DW_TAG_member, name: "owners", scope: !999, file: !1000, line: 129, baseType: !1036, size: 524416, offset: 83968)
!1036 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwners", scope: !5, file: !1000, line: 90, size: 524416, flags: DIFlagTypePassByValue, elements: !1037, identifier: "_ZTSN4laya4full10FullOwnersE")
!1037 = !{!1038, !1065, !1069, !1072, !1075, !1077, !1078}
!1038 = !DIDerivedType(tag: DW_TAG_member, name: "record", scope: !1036, file: !1000, line: 91, baseType: !1039, size: 163840)
!1039 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1040, size: 163840, elements: !1063)
!1040 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwnerRecord", scope: !5, file: !1000, line: 64, size: 5120, flags: DIFlagTypePassByValue, elements: !1041, identifier: "_ZTSN4laya4full15FullOwnerRecordE")
!1041 = !{!1042, !1043, !1044, !1045, !1046, !1047, !1048, !1049, !1050, !1051, !1052, !1053, !1054, !1055, !1056, !1057, !1061, !1062}
!1042 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1040, file: !1000, line: 65, baseType: !1006, size: 704)
!1043 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1040, file: !1000, line: 66, baseType: !96, size: 64, offset: 704)
!1044 = !DIDerivedType(tag: DW_TAG_member, name: "lease_old_ref", scope: !1040, file: !1000, line: 67, baseType: !96, size: 64, offset: 768)
!1045 = !DIDerivedType(tag: DW_TAG_member, name: "max_claimed_epoch", scope: !1040, file: !1000, line: 68, baseType: !93, size: 32, offset: 832)
!1046 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1040, file: !1000, line: 69, baseType: !16, size: 8, offset: 864)
!1047 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1040, file: !1000, line: 69, baseType: !16, size: 8, offset: 872)
!1048 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1040, file: !1000, line: 69, baseType: !16, size: 8, offset: 880)
!1049 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1040, file: !1000, line: 69, baseType: !16, size: 8, offset: 888)
!1050 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1040, file: !1000, line: 70, baseType: !58, size: 8, offset: 896)
!1051 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1040, file: !1000, line: 71, baseType: !9, size: 16, offset: 912)
!1052 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1040, file: !1000, line: 71, baseType: !9, size: 16, offset: 928)
!1053 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1040, file: !1000, line: 71, baseType: !9, size: 16, offset: 944)
!1054 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1040, file: !1000, line: 72, baseType: !63, size: 8, offset: 960)
!1055 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1040, file: !1000, line: 73, baseType: !73, size: 8, offset: 968)
!1056 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1040, file: !1000, line: 74, baseType: !16, size: 8, offset: 976)
!1057 = !DIDerivedType(tag: DW_TAG_member, name: "covered_rows", scope: !1040, file: !1000, line: 75, baseType: !1058, size: 2048, offset: 992)
!1058 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 2048, elements: !1059)
!1059 = !{!1060}
!1060 = !DISubrange(count: 64, lowerBound: 0)
!1061 = !DIDerivedType(tag: DW_TAG_member, name: "old_consumed_rows", scope: !1040, file: !1000, line: 76, baseType: !1058, size: 2048, offset: 3040)
!1062 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1040, file: !1000, line: 77, baseType: !237, size: 8, offset: 5088)
!1063 = !{!1064}
!1064 = !DISubrange(count: 32, lowerBound: 0)
!1065 = !DIDerivedType(tag: DW_TAG_member, name: "qkv_plane_head_rows", scope: !1036, file: !1000, line: 92, baseType: !1066, size: 196608, offset: 163840)
!1066 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 196608, elements: !1067)
!1067 = !{!1023, !1068, !1016, !1023, !1064}
!1068 = !DISubrange(count: 3, lowerBound: 0)
!1069 = !DIDerivedType(tag: DW_TAG_member, name: "qkv_rope_rows", scope: !1036, file: !1000, line: 93, baseType: !1070, size: 131072, offset: 360448)
!1070 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 131072, elements: !1071)
!1071 = !{!1023, !1023, !1016, !1023, !1064}
!1072 = !DIDerivedType(tag: DW_TAG_member, name: "att_head_rows", scope: !1036, file: !1000, line: 94, baseType: !1073, size: 32768, offset: 491520)
!1073 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 32768, elements: !1074)
!1074 = !{!1016, !1023, !1064}
!1075 = !DIDerivedType(tag: DW_TAG_member, name: "scorer_old_consumed", scope: !1036, file: !1000, line: 95, baseType: !1076, size: 32, offset: 524288)
!1076 = !DICompositeType(tag: DW_TAG_array_type, baseType: !9, size: 32, elements: !1034)
!1077 = !DIDerivedType(tag: DW_TAG_member, name: "scorer_new_written", scope: !1036, file: !1000, line: 96, baseType: !1076, size: 32, offset: 524320)
!1078 = !DIDerivedType(tag: DW_TAG_member, name: "type_valid", scope: !1036, file: !1000, line: 97, baseType: !1079, size: 24, offset: 524352)
!1079 = !DICompositeType(tag: DW_TAG_array_type, baseType: !237, size: 24, elements: !1080)
!1080 = !{!1068}
!1081 = !DIDerivedType(tag: DW_TAG_member, name: "cache", scope: !999, file: !1000, line: 130, baseType: !1082, size: 9024, offset: 608384)
!1082 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullCache", scope: !5, file: !1000, line: 102, size: 9024, flags: DIFlagTypePassByValue, elements: !1083, identifier: "_ZTSN4laya4full9FullCacheE")
!1083 = !{!1084, !1102}
!1084 = !DIDerivedType(tag: DW_TAG_member, name: "activation_source_ledger", scope: !1082, file: !1000, line: 118, baseType: !1085, size: 3008)
!1085 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "F32TileMeta", scope: !6, file: !1007, line: 20, size: 3008, flags: DIFlagTypePassByValue, elements: !1086, identifier: "_ZTSN4laya11F32TileMetaE")
!1086 = !{!1087, !1088, !1089, !1090, !1091, !1092, !1093, !1094, !1095, !1096, !1097, !1098, !1101}
!1087 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1085, file: !1007, line: 21, baseType: !1006, size: 704)
!1088 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1085, file: !1007, line: 22, baseType: !96, size: 64, offset: 704)
!1089 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1085, file: !1007, line: 23, baseType: !16, size: 8, offset: 768)
!1090 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1085, file: !1007, line: 24, baseType: !58, size: 8, offset: 776)
!1091 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1085, file: !1007, line: 25, baseType: !16, size: 8, offset: 784)
!1092 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1085, file: !1007, line: 26, baseType: !9, size: 16, offset: 800)
!1093 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1085, file: !1007, line: 27, baseType: !16, size: 8, offset: 816)
!1094 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1085, file: !1007, line: 28, baseType: !9, size: 16, offset: 832)
!1095 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1085, file: !1007, line: 29, baseType: !73, size: 8, offset: 848)
!1096 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1085, file: !1007, line: 30, baseType: !63, size: 8, offset: 856)
!1097 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1085, file: !1007, line: 31, baseType: !16, size: 8, offset: 864)
!1098 = !DIDerivedType(tag: DW_TAG_member, name: "covered_groups", scope: !1085, file: !1007, line: 33, baseType: !1099, size: 2048, offset: 896)
!1099 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 2048, elements: !1100)
!1100 = !{!1016, !321}
!1101 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1085, file: !1007, line: 34, baseType: !237, size: 8, offset: 2944)
!1102 = !DIDerivedType(tag: DW_TAG_member, name: "activation_meta", scope: !1082, file: !1000, line: 119, baseType: !1103, size: 6016, offset: 3008)
!1103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "A8TileMeta", scope: !6, file: !1007, line: 47, size: 6016, flags: DIFlagTypePassByValue, elements: !1104, identifier: "_ZTSN4laya10A8TileMetaE")
!1104 = !{!1105, !1106, !1107, !1108, !1109, !1110, !1111, !1112, !1113, !1114, !1115, !1116, !1117, !1118, !1119, !1120}
!1105 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1103, file: !1007, line: 48, baseType: !1006, size: 704)
!1106 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1103, file: !1007, line: 49, baseType: !96, size: 64, offset: 704)
!1107 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !1103, file: !1007, line: 50, baseType: !1085, size: 3008, offset: 768)
!1108 = !DIDerivedType(tag: DW_TAG_member, name: "producer_task_id", scope: !1103, file: !1007, line: 51, baseType: !93, size: 32, offset: 3776)
!1109 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1103, file: !1007, line: 52, baseType: !16, size: 8, offset: 3808)
!1110 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1103, file: !1007, line: 52, baseType: !16, size: 8, offset: 3816)
!1111 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1103, file: !1007, line: 53, baseType: !58, size: 8, offset: 3824)
!1112 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1103, file: !1007, line: 54, baseType: !16, size: 8, offset: 3832)
!1113 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1103, file: !1007, line: 55, baseType: !9, size: 16, offset: 3840)
!1114 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1103, file: !1007, line: 56, baseType: !16, size: 8, offset: 3856)
!1115 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1103, file: !1007, line: 57, baseType: !9, size: 16, offset: 3872)
!1116 = !DIDerivedType(tag: DW_TAG_member, name: "covered_groups", scope: !1103, file: !1007, line: 58, baseType: !1099, size: 2048, offset: 3904)
!1117 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1103, file: !1007, line: 59, baseType: !73, size: 8, offset: 5952)
!1118 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1103, file: !1007, line: 60, baseType: !63, size: 8, offset: 5960)
!1119 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1103, file: !1007, line: 61, baseType: !16, size: 8, offset: 5968)
!1120 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1103, file: !1007, line: 62, baseType: !237, size: 8, offset: 5976)
!1121 = !DIDerivedType(tag: DW_TAG_member, name: "current_weight", scope: !999, file: !1000, line: 131, baseType: !1122, size: 1280, offset: 617408)
!1122 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullWeightDescriptor", scope: !5, file: !1000, line: 51, size: 1280, flags: DIFlagTypePassByValue, elements: !1123, identifier: "_ZTSN4laya4full20FullWeightDescriptorE")
!1123 = !{!1124, !1128, !1133, !1134, !1135, !1136, !1137, !1139, !1140, !1141, !1142, !1143, !1144, !1145, !1146, !1148}
!1124 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !1122, file: !1000, line: 52, baseType: !1125, size: 384)
!1125 = !DICompositeType(tag: DW_TAG_array_type, baseType: !254, size: 384, elements: !1126)
!1126 = !{!1127}
!1127 = !DISubrange(count: 48, lowerBound: 0)
!1128 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !1122, file: !1000, line: 53, baseType: !1129, size: 16, offset: 384)
!1129 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "WeightKey", scope: !6, file: !15, line: 23, size: 16, flags: DIFlagTypePassByValue, elements: !1130, identifier: "_ZTSN4laya9WeightKeyE")
!1130 = !{!1131, !1132}
!1131 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !1129, file: !15, line: 23, baseType: !16, size: 8)
!1132 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1129, file: !15, line: 23, baseType: !16, size: 8, offset: 8)
!1133 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1122, file: !1000, line: 54, baseType: !9, size: 16, offset: 400)
!1134 = !DIDerivedType(tag: DW_TAG_member, name: "N", scope: !1122, file: !1000, line: 54, baseType: !9, size: 16, offset: 416)
!1135 = !DIDerivedType(tag: DW_TAG_member, name: "dtype", scope: !1122, file: !1000, line: 55, baseType: !16, size: 8, offset: 432)
!1136 = !DIDerivedType(tag: DW_TAG_member, name: "bias_kind", scope: !1122, file: !1000, line: 55, baseType: !16, size: 8, offset: 440)
!1137 = !DIDerivedType(tag: DW_TAG_member, name: "q_base", scope: !1122, file: !1000, line: 56, baseType: !1138, size: 64, offset: 448)
!1138 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 64, elements: !1034)
!1139 = !DIDerivedType(tag: DW_TAG_member, name: "q_span", scope: !1122, file: !1000, line: 56, baseType: !1138, size: 64, offset: 512)
!1140 = !DIDerivedType(tag: DW_TAG_member, name: "scale_base", scope: !1122, file: !1000, line: 57, baseType: !93, size: 32, offset: 576)
!1141 = !DIDerivedType(tag: DW_TAG_member, name: "scale_span", scope: !1122, file: !1000, line: 57, baseType: !93, size: 32, offset: 608)
!1142 = !DIDerivedType(tag: DW_TAG_member, name: "aux_base", scope: !1122, file: !1000, line: 58, baseType: !93, size: 32, offset: 640)
!1143 = !DIDerivedType(tag: DW_TAG_member, name: "aux_span", scope: !1122, file: !1000, line: 58, baseType: !93, size: 32, offset: 672)
!1144 = !DIDerivedType(tag: DW_TAG_member, name: "bias_base", scope: !1122, file: !1000, line: 59, baseType: !93, size: 32, offset: 704)
!1145 = !DIDerivedType(tag: DW_TAG_member, name: "bias_span", scope: !1122, file: !1000, line: 59, baseType: !93, size: 32, offset: 736)
!1146 = !DIDerivedType(tag: DW_TAG_member, name: "source_sha256", scope: !1122, file: !1000, line: 60, baseType: !1147, size: 256, offset: 768)
!1147 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 256, elements: !1063)
!1148 = !DIDerivedType(tag: DW_TAG_member, name: "bias_sha256", scope: !1122, file: !1000, line: 61, baseType: !1147, size: 256, offset: 1024)
!1149 = !DIDerivedType(tag: DW_TAG_member, name: "current_weight_ref", scope: !999, file: !1000, line: 132, baseType: !96, size: 64, offset: 618688)
!1150 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_gamma_ref", scope: !999, file: !1000, line: 133, baseType: !1151, size: 128, offset: 618752)
!1151 = !DICompositeType(tag: DW_TAG_array_type, baseType: !96, size: 128, elements: !1034)
!1152 = !DIDerivedType(tag: DW_TAG_member, name: "final_qkv_ref", scope: !999, file: !1000, line: 134, baseType: !1151, size: 128, offset: 618880)
!1153 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_kv_ref", scope: !999, file: !1000, line: 135, baseType: !96, size: 64, offset: 619008)
!1154 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_rope_ref", scope: !999, file: !1000, line: 135, baseType: !96, size: 64, offset: 619072)
!1155 = !DIDerivedType(tag: DW_TAG_member, name: "score_ref", scope: !999, file: !1000, line: 136, baseType: !96, size: 64, offset: 619136)
!1156 = !DIDerivedType(tag: DW_TAG_member, name: "score_kv_ref", scope: !999, file: !1000, line: 136, baseType: !96, size: 64, offset: 619200)
!1157 = !DIDerivedType(tag: DW_TAG_member, name: "score_qkv_ref", scope: !999, file: !1000, line: 136, baseType: !1151, size: 128, offset: 619264)
!1158 = !DIDerivedType(tag: DW_TAG_member, name: "score_head", scope: !999, file: !1000, line: 137, baseType: !16, size: 8, offset: 619392)
!1159 = !DIDerivedType(tag: DW_TAG_member, name: "score_stage", scope: !999, file: !1000, line: 137, baseType: !16, size: 8, offset: 619400)
!1160 = !DIDerivedType(tag: DW_TAG_member, name: "score_layer", scope: !999, file: !1000, line: 137, baseType: !16, size: 8, offset: 619408)
!1161 = !DIDerivedType(tag: DW_TAG_member, name: "score_batch", scope: !999, file: !1000, line: 138, baseType: !16, size: 8, offset: 619416)
!1162 = !DIDerivedType(tag: DW_TAG_member, name: "score_rows", scope: !999, file: !1000, line: 138, baseType: !16, size: 8, offset: 619424)
!1163 = !DIDerivedType(tag: DW_TAG_member, name: "score_row0", scope: !999, file: !1000, line: 139, baseType: !9, size: 16, offset: 619440)
!1164 = !DIDerivedType(tag: DW_TAG_member, name: "score_valid", scope: !999, file: !1000, line: 140, baseType: !237, size: 8, offset: 619456)
!1165 = !DIDerivedType(tag: DW_TAG_member, name: "expected_quant_source", scope: !999, file: !1000, line: 141, baseType: !1166, size: 192, offset: 619488)
!1166 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwnerSpec", scope: !5, file: !1000, line: 80, size: 192, flags: DIFlagTypePassByValue, elements: !1167, identifier: "_ZTSN4laya4full13FullOwnerSpecE")
!1167 = !{!1168, !1169, !1170, !1171, !1172, !1173, !1174, !1175, !1176, !1177}
!1168 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1166, file: !1000, line: 81, baseType: !96, size: 64)
!1169 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1166, file: !1000, line: 82, baseType: !16, size: 8, offset: 64)
!1170 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1166, file: !1000, line: 82, baseType: !16, size: 8, offset: 72)
!1171 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1166, file: !1000, line: 82, baseType: !16, size: 8, offset: 80)
!1172 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1166, file: !1000, line: 83, baseType: !16, size: 8, offset: 88)
!1173 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1166, file: !1000, line: 84, baseType: !58, size: 8, offset: 96)
!1174 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1166, file: !1000, line: 85, baseType: !9, size: 16, offset: 112)
!1175 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1166, file: !1000, line: 85, baseType: !9, size: 16, offset: 128)
!1176 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1166, file: !1000, line: 86, baseType: !9, size: 16, offset: 144)
!1177 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1166, file: !1000, line: 87, baseType: !63, size: 8, offset: 160)
!1178 = !DIDerivedType(tag: DW_TAG_member, name: "expected_task_source", scope: !999, file: !1000, line: 142, baseType: !1179, size: 768, offset: 619680)
!1179 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1166, size: 768, elements: !320)
!1180 = !DIDerivedType(tag: DW_TAG_member, name: "expected_task_source_count", scope: !999, file: !1000, line: 143, baseType: !16, size: 8, offset: 620448)
!1181 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_rope_mode", scope: !999, file: !1000, line: 144, baseType: !16, size: 8, offset: 620456)
!1182 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_kv_head", scope: !999, file: !1000, line: 144, baseType: !16, size: 8, offset: 620464)
!1183 = !DIDerivedType(tag: DW_TAG_member, name: "last_task_id", scope: !999, file: !1000, line: 145, baseType: !93, size: 32, offset: 620480)
!1184 = !DIDerivedType(tag: DW_TAG_member, name: "tasks_retired", scope: !999, file: !1000, line: 145, baseType: !93, size: 32, offset: 620512)
!1185 = !DIDerivedType(tag: DW_TAG_member, name: "op_calls", scope: !999, file: !1000, line: 146, baseType: !1186, size: 8192, offset: 620544)
!1186 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 8192, elements: !1187)
!1187 = !{!1188}
!1188 = !DISubrange(count: 256, lowerBound: 0)
!1189 = !DIDerivedType(tag: DW_TAG_member, name: "owner_claims", scope: !999, file: !1000, line: 147, baseType: !93, size: 32, offset: 628736)
!1190 = !DIDerivedType(tag: DW_TAG_member, name: "owner_leases", scope: !999, file: !1000, line: 147, baseType: !93, size: 32, offset: 628768)
!1191 = !DIDerivedType(tag: DW_TAG_member, name: "encoder_layers_completed", scope: !999, file: !1000, line: 148, baseType: !16, size: 8, offset: 628800)
!1192 = !DIDerivedType(tag: DW_TAG_member, name: "decision_layers_completed", scope: !999, file: !1000, line: 148, baseType: !16, size: 8, offset: 628808)
!1193 = !DIDerivedType(tag: DW_TAG_member, name: "session_generation", scope: !999, file: !1000, line: 149, baseType: !160, size: 64, offset: 628864)
!1194 = !DIDerivedType(tag: DW_TAG_member, name: "last_accepted_request_id", scope: !999, file: !1000, line: 149, baseType: !160, size: 64, offset: 628928)
!1195 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_request_id", scope: !999, file: !1000, line: 150, baseType: !160, size: 64, offset: 628992)
!1196 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_generation", scope: !999, file: !1000, line: 150, baseType: !160, size: 64, offset: 629056)
!1197 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_B", scope: !999, file: !1000, line: 151, baseType: !9, size: 16, offset: 629120)
!1198 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_S", scope: !999, file: !1000, line: 151, baseType: !9, size: 16, offset: 629136)
!1199 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_identity_valid", scope: !999, file: !1000, line: 152, baseType: !237, size: 8, offset: 629152)
!1200 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_shape_valid", scope: !999, file: !1000, line: 152, baseType: !237, size: 8, offset: 629160)
!1201 = !DIDerivedType(tag: DW_TAG_member, name: "last_execution_error", scope: !999, file: !1000, line: 153, baseType: !1202, size: 128, offset: 629184)
!1202 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "Check", scope: !6, file: !15, line: 9, size: 128, flags: DIFlagTypePassByValue, elements: !1203, identifier: "_ZTSN4laya5CheckE")
!1203 = !{!1204, !1205, !1206, !1207}
!1204 = !DIDerivedType(tag: DW_TAG_member, name: "code", scope: !1202, file: !15, line: 9, baseType: !47, size: 16)
!1205 = !DIDerivedType(tag: DW_TAG_member, name: "detail", scope: !1202, file: !15, line: 9, baseType: !93, size: 32, offset: 32)
!1206 = !DIDerivedType(tag: DW_TAG_member, name: "bad_element", scope: !1202, file: !15, line: 9, baseType: !160, size: 64, offset: 64)
!1207 = !DISubprogram(name: "operator bool", linkageName: "_ZNK4laya5CheckcvbEv", scope: !1202, file: !15, line: 9, type: !1208, scopeLine: 9, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!1208 = !DISubroutineType(types: !1209)
!1209 = !{!237, !1210}
!1210 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1211, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1211 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1202)
!1212 = !DIDerivedType(tag: DW_TAG_member, name: "last_cleanup_error", scope: !999, file: !1000, line: 153, baseType: !1202, size: 128, offset: 629312)
!1213 = !DIDerivedType(tag: DW_TAG_member, name: "last_commit_error", scope: !999, file: !1000, line: 154, baseType: !1202, size: 128, offset: 629440)
!1214 = !DIDerivedType(tag: DW_TAG_member, name: "request_valid", scope: !999, file: !1000, line: 155, baseType: !237, size: 8, offset: 629568)
!1215 = !DIDerivedType(tag: DW_TAG_member, name: "model_header_valid", scope: !999, file: !1000, line: 155, baseType: !237, size: 8, offset: 629576)
!1216 = !DIDerivedType(tag: DW_TAG_member, name: "expected_quant_source_valid", scope: !999, file: !1000, line: 156, baseType: !237, size: 8, offset: 629584)
!1217 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1218, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !1219, retainedTypes: !1262, globals: !1263, imports: !1266, splitDebugInlining: false, nameTableKind: GNU)
!1218 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis/csynth_r2/hls/.autopilot/db/laya_numeric.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis", checksumkind: CSK_MD5, checksum: "0ad647ce1f3caa889d55a13a44800f92")
!1219 = !{!14, !58, !73, !63, !47, !1220}
!1220 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Op", scope: !6, file: !1221, line: 6, baseType: !16, size: 8, elements: !1222, identifier: "_ZTSN4laya2OpE")
!1221 = !DIFile(filename: "include/laya_tasks.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1222 = !{!1223, !1224, !1225, !1226, !1227, !1228, !1229, !1230, !1231, !1232, !1233, !1234, !1235, !1236, !1237, !1238, !1239, !1240, !1241, !1242, !1243, !1244, !1245, !1246, !1247, !1248, !1249, !1250, !1251, !1252, !1253, !1254, !1255, !1256, !1257, !1258, !1259, !1260, !1261}
!1223 = !DIEnumerator(name: "EMB_TOKEN", value: 1)
!1224 = !DIEnumerator(name: "EMB_TYPE", value: 2)
!1225 = !DIEnumerator(name: "LN_EMB", value: 16)
!1226 = !DIEnumerator(name: "LN_ATTN", value: 17)
!1227 = !DIEnumerator(name: "LN_FFN", value: 18)
!1228 = !DIEnumerator(name: "LN_FINAL", value: 19)
!1229 = !DIEnumerator(name: "LN_MARKER", value: 20)
!1230 = !DIEnumerator(name: "QUANT", value: 32)
!1231 = !DIEnumerator(name: "LIN_QKV", value: 48)
!1232 = !DIEnumerator(name: "LIN_WO", value: 49)
!1233 = !DIEnumerator(name: "LIN_WI", value: 50)
!1234 = !DIEnumerator(name: "LIN_DOWN", value: 51)
!1235 = !DIEnumerator(name: "LIN_DEC_FC1", value: 52)
!1236 = !DIEnumerator(name: "LIN_DEC_FC2", value: 53)
!1237 = !DIEnumerator(name: "LIN_SCORER_FC1", value: 54)
!1238 = !DIEnumerator(name: "LIN_ACT_FC2", value: 55)
!1239 = !DIEnumerator(name: "ROPE", value: 64)
!1240 = !DIEnumerator(name: "QK", value: 80)
!1241 = !DIEnumerator(name: "SOFTMAX_ATT", value: 81)
!1242 = !DIEnumerator(name: "AV", value: 82)
!1243 = !DIEnumerator(name: "FP_SCORER_FC2", value: 83)
!1244 = !DIEnumerator(name: "FP_ACT_FC1", value: 84)
!1245 = !DIEnumerator(name: "SOFTMAX_CAND", value: 85)
!1246 = !DIEnumerator(name: "GEGLU", value: 96)
!1247 = !DIEnumerator(name: "RELU", value: 97)
!1248 = !DIEnumerator(name: "ADD_RESIDUAL", value: 98)
!1249 = !DIEnumerator(name: "ADD_TYPE", value: 99)
!1250 = !DIEnumerator(name: "BIAS_GELU_SCORER", value: 100)
!1251 = !DIEnumerator(name: "BIAS_GELU_ACT", value: 101)
!1252 = !DIEnumerator(name: "APPLY_CAND_MASK", value: 102)
!1253 = !DIEnumerator(name: "GATHER_MARKER", value: 112)
!1254 = !DIEnumerator(name: "CAND_STATS", value: 113)
!1255 = !DIEnumerator(name: "CONCAT_ACT", value: 114)
!1256 = !DIEnumerator(name: "LOAD_W", value: -128)
!1257 = !DIEnumerator(name: "LOAD_KV", value: -127)
!1258 = !DIEnumerator(name: "LOAD_LN_PARAMS", value: -126)
!1259 = !DIEnumerator(name: "LOAD_ROPE", value: -125)
!1260 = !DIEnumerator(name: "IO_VALIDATE", value: -124)
!1261 = !DIEnumerator(name: "RESULT_COMMIT", value: -123)
!1262 = !{!93, !16, !9, !124, !95}
!1263 = !{!1264}
!1264 = !DIGlobalVariableExpression(var: !1265, expr: !DIExpression(DW_OP_constu, 4294967294, DW_OP_stack_value))
!1265 = distinct !DIGlobalVariable(name: "kMaxEpoch", scope: !6, file: !107, line: 13, type: !108, isLocal: true, isDefinition: true)
!1266 = !{!110, !117, !121, !125, !129, !132, !134, !136, !138, !142, !145, !148, !151, !154, !156, !157, !158, !159, !163, !165, !167, !169, !171, !174, !177, !180, !183, !186, !188, !298, !302, !306, !323, !326, !331, !339, !347, !351, !358, !362, !366, !368, !370, !374, !383, !387, !393, !399, !401, !405, !409, !413, !1267, !1274, !1276, !1280, !1284, !1288, !441, !447, !451, !455, !457, !459, !463, !471, !475, !479, !483, !485, !491, !493, !500, !505, !509, !513, !517, !521, !525, !527, !529, !533, !537, !541, !543, !547, !551, !553, !555, !559, !565, !570, !575, !576, !577, !578, !1290, !1291, !1292, !582, !583, !584, !585, !587, !589, !593, !597, !602, !608, !610, !612, !614, !616, !618, !620, !622, !624, !626, !628, !630, !632, !634, !638, !642, !648, !652, !656, !661, !663, !667, !671, !675, !685, !687, !691, !695, !699, !703, !707, !711, !715, !719, !723, !727, !731, !733, !735, !739, !743, !749, !753, !757, !759, !763, !767, !773, !775, !779, !783, !787, !791, !795, !799, !803, !804, !805, !806, !808, !809, !810, !811, !812, !813, !814, !818, !824, !829, !833, !835, !837, !839, !841, !848, !852, !856, !860, !864, !868, !873, !877, !879, !883, !889, !893, !898, !900, !902, !906, !910, !912, !914, !916, !918, !922, !924, !926, !930, !934, !938, !942, !946, !950, !1293, !1297, !1301, !964, !1305, !1307, !1309, !1313, !980, !1317, !1318, !1319, !1320, !985, !1321, !1327, !1331, !1335, !1339, !1343, !1347, !1349, !1351, !1353, !1357, !1361, !1365, !1369, !1373, !1375, !1377, !1379, !1383, !1387, !1391, !1393}
!1267 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1268, file: !322, line: 162)
!1268 = !DISubprogram(name: "vfwprintf", scope: !328, file: !328, line: 750, type: !1269, flags: DIFlagPrototyped, spFlags: 0)
!1269 = !DISubroutineType(types: !1270)
!1270 = !{!124, !346, !355, !1271}
!1271 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !422, line: 14, baseType: !1272)
!1272 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !1273, baseType: !194)
!1273 = !DIFile(filename: "csynth_r2/hls/.autopilot/db/laya_numeric.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis")
!1274 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1275, file: !322, line: 164)
!1275 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc23_vfwscanf", scope: !328, file: !328, line: 875, type: !1269, flags: DIFlagPrototyped, spFlags: 0)
!1276 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1277, file: !322, line: 167)
!1277 = !DISubprogram(name: "vswprintf", scope: !328, file: !328, line: 763, type: !1278, flags: DIFlagPrototyped, spFlags: 0)
!1278 = !DISubroutineType(types: !1279)
!1279 = !{!124, !345, !378, !355, !1271}
!1280 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1281, file: !322, line: 170)
!1281 = !DISubprogram(name: "vswscanf", linkageName: "__isoc23_vswscanf", scope: !328, file: !328, line: 882, type: !1282, flags: DIFlagPrototyped, spFlags: 0)
!1282 = !DISubroutineType(types: !1283)
!1283 = !{!124, !355, !355, !1271}
!1284 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1285, file: !322, line: 172)
!1285 = !DISubprogram(name: "vwprintf", scope: !328, file: !328, line: 758, type: !1286, flags: DIFlagPrototyped, spFlags: 0)
!1286 = !DISubroutineType(types: !1287)
!1287 = !{!124, !355, !1271}
!1288 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1289, file: !322, line: 174)
!1289 = !DISubprogram(name: "vwscanf", linkageName: "__isoc23_vwscanf", scope: !328, file: !328, line: 879, type: !1286, flags: DIFlagPrototyped, spFlags: 0)
!1290 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1275, file: !322, line: 283)
!1291 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1281, file: !322, line: 286)
!1292 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1289, file: !322, line: 289)
!1293 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1294, file: !817, line: 144)
!1294 = !DISubprogram(name: "vfprintf", scope: !820, file: !820, line: 372, type: !1295, flags: DIFlagPrototyped, spFlags: 0)
!1295 = !DISubroutineType(types: !1296)
!1296 = !{!124, !845, !380, !1271}
!1297 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1298, file: !817, line: 145)
!1298 = !DISubprogram(name: "vprintf", scope: !820, file: !820, line: 378, type: !1299, flags: DIFlagPrototyped, spFlags: 0)
!1299 = !DISubroutineType(types: !1300)
!1300 = !{!124, !380, !1271}
!1301 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1302, file: !817, line: 146)
!1302 = !DISubprogram(name: "vsprintf", scope: !820, file: !820, line: 380, type: !1303, flags: DIFlagPrototyped, spFlags: 0)
!1303 = !DISubroutineType(types: !1304)
!1304 = !{!124, !445, !380, !1271}
!1305 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1306, file: !817, line: 176)
!1306 = !DISubprogram(name: "vfscanf", linkageName: "__isoc23_vfscanf", scope: !820, file: !820, line: 511, type: !1295, flags: DIFlagPrototyped, spFlags: 0)
!1307 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1308, file: !817, line: 177)
!1308 = !DISubprogram(name: "vscanf", linkageName: "__isoc23_vscanf", scope: !820, file: !820, line: 516, type: !1299, flags: DIFlagPrototyped, spFlags: 0)
!1309 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1310, file: !817, line: 178)
!1310 = !DISubprogram(name: "vsnprintf", scope: !820, file: !820, line: 389, type: !1311, flags: DIFlagPrototyped, spFlags: 0)
!1311 = !DISubroutineType(types: !1312)
!1312 = !{!124, !445, !378, !380, !1271}
!1313 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1314, file: !817, line: 179)
!1314 = !DISubprogram(name: "vsscanf", linkageName: "__isoc23_vsscanf", scope: !820, file: !820, line: 519, type: !1315, flags: DIFlagPrototyped, spFlags: 0)
!1315 = !DISubroutineType(types: !1316)
!1316 = !{!124, !380, !380, !1271}
!1317 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1306, file: !817, line: 186)
!1318 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1308, file: !817, line: 187)
!1319 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1310, file: !817, line: 188)
!1320 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1314, file: !817, line: 189)
!1321 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1322, file: !1326, line: 75)
!1322 = !DISubprogram(name: "memchr", scope: !1323, file: !1323, line: 89, type: !1324, flags: DIFlagPrototyped, spFlags: 0)
!1323 = !DIFile(filename: "/usr/include/string.h", directory: "")
!1324 = !DISubroutineType(types: !1325)
!1325 = !{!679, !679, !124, !378}
!1326 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstring", directory: "/home/user/EDA-202")
!1327 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1328, file: !1326, line: 76)
!1328 = !DISubprogram(name: "memcmp", scope: !1323, file: !1323, line: 64, type: !1329, flags: DIFlagPrototyped, spFlags: 0)
!1329 = !DISubroutineType(types: !1330)
!1330 = !{!124, !679, !679, !378}
!1331 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1332, file: !1326, line: 77)
!1332 = !DISubprogram(name: "memcpy", scope: !1323, file: !1323, line: 43, type: !1333, flags: DIFlagPrototyped, spFlags: 0)
!1333 = !DISubroutineType(types: !1334)
!1334 = !{!194, !872, !897, !378}
!1335 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1336, file: !1326, line: 78)
!1336 = !DISubprogram(name: "memmove", scope: !1323, file: !1323, line: 47, type: !1337, flags: DIFlagPrototyped, spFlags: 0)
!1337 = !DISubroutineType(types: !1338)
!1338 = !{!194, !194, !679, !378}
!1339 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1340, file: !1326, line: 79)
!1340 = !DISubprogram(name: "memset", scope: !1323, file: !1323, line: 61, type: !1341, flags: DIFlagPrototyped, spFlags: 0)
!1341 = !DISubroutineType(types: !1342)
!1342 = !{!194, !194, !124, !378}
!1343 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1344, file: !1326, line: 80)
!1344 = !DISubprogram(name: "strcat", scope: !1323, file: !1323, line: 149, type: !1345, flags: DIFlagPrototyped, spFlags: 0)
!1345 = !DISubroutineType(types: !1346)
!1346 = !{!446, !445, !380}
!1347 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1348, file: !1326, line: 81)
!1348 = !DISubprogram(name: "strcmp", scope: !1323, file: !1323, line: 156, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!1349 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1350, file: !1326, line: 82)
!1350 = !DISubprogram(name: "strcoll", scope: !1323, file: !1323, line: 163, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!1351 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1352, file: !1326, line: 83)
!1352 = !DISubprogram(name: "strcpy", scope: !1323, file: !1323, line: 141, type: !1345, flags: DIFlagPrototyped, spFlags: 0)
!1353 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1354, file: !1326, line: 84)
!1354 = !DISubprogram(name: "strcspn", scope: !1323, file: !1323, line: 293, type: !1355, flags: DIFlagPrototyped, spFlags: 0)
!1355 = !DISubroutineType(types: !1356)
!1356 = !{!378, !252, !252}
!1357 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1358, file: !1326, line: 85)
!1358 = !DISubprogram(name: "strerror", scope: !1323, file: !1323, line: 419, type: !1359, flags: DIFlagPrototyped, spFlags: 0)
!1359 = !DISubroutineType(types: !1360)
!1360 = !{!446, !124}
!1361 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1362, file: !1326, line: 86)
!1362 = !DISubprogram(name: "strlen", scope: !1323, file: !1323, line: 407, type: !1363, flags: DIFlagPrototyped, spFlags: 0)
!1363 = !DISubroutineType(types: !1364)
!1364 = !{!378, !252}
!1365 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1366, file: !1326, line: 87)
!1366 = !DISubprogram(name: "strncat", scope: !1323, file: !1323, line: 152, type: !1367, flags: DIFlagPrototyped, spFlags: 0)
!1367 = !DISubroutineType(types: !1368)
!1368 = !{!446, !445, !380, !378}
!1369 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1370, file: !1326, line: 88)
!1370 = !DISubprogram(name: "strncmp", scope: !1323, file: !1323, line: 159, type: !1371, flags: DIFlagPrototyped, spFlags: 0)
!1371 = !DISubroutineType(types: !1372)
!1372 = !{!124, !252, !252, !378}
!1373 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1374, file: !1326, line: 89)
!1374 = !DISubprogram(name: "strncpy", scope: !1323, file: !1323, line: 144, type: !1367, flags: DIFlagPrototyped, spFlags: 0)
!1375 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1376, file: !1326, line: 90)
!1376 = !DISubprogram(name: "strspn", scope: !1323, file: !1323, line: 297, type: !1355, flags: DIFlagPrototyped, spFlags: 0)
!1377 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1378, file: !1326, line: 91)
!1378 = !DISubprogram(name: "strtok", scope: !1323, file: !1323, line: 356, type: !1345, flags: DIFlagPrototyped, spFlags: 0)
!1379 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1380, file: !1326, line: 92)
!1380 = !DISubprogram(name: "strxfrm", scope: !1323, file: !1323, line: 166, type: !1381, flags: DIFlagPrototyped, spFlags: 0)
!1381 = !DISubroutineType(types: !1382)
!1382 = !{!378, !445, !380, !378}
!1383 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1384, file: !1326, line: 93)
!1384 = !DISubprogram(name: "strchr", scope: !1323, file: !1323, line: 228, type: !1385, flags: DIFlagPrototyped, spFlags: 0)
!1385 = !DISubroutineType(types: !1386)
!1386 = !{!252, !252, !124}
!1387 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1388, file: !1326, line: 94)
!1388 = !DISubprogram(name: "strpbrk", scope: !1323, file: !1323, line: 305, type: !1389, flags: DIFlagPrototyped, spFlags: 0)
!1389 = !DISubroutineType(types: !1390)
!1390 = !{!252, !252, !252}
!1391 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1392, file: !1326, line: 95)
!1392 = !DISubprogram(name: "strrchr", scope: !1323, file: !1323, line: 255, type: !1385, flags: DIFlagPrototyped, spFlags: 0)
!1393 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1394, file: !1326, line: 96)
!1394 = !DISubprogram(name: "strstr", scope: !1323, file: !1323, line: 332, type: !1389, flags: DIFlagPrototyped, spFlags: 0)
!1395 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1396, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !1397, retainedTypes: !1402, globals: !1403, imports: !1406, splitDebugInlining: false, nameTableKind: GNU)
!1396 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis/csynth_r2/hls/.autopilot/db/laya_tasks.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis", checksumkind: CSK_MD5, checksum: "13ee9e96f4c842464cfbe9b85ed2a746")
!1397 = !{!47, !1220, !58, !14, !1398}
!1398 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "OutputUnit", scope: !6, file: !15, line: 18, baseType: !16, size: 8, elements: !1399, identifier: "_ZTSN4laya10OutputUnitE")
!1399 = !{!20, !66, !1400, !1401}
!1400 = !DIEnumerator(name: "Q8_GROUP", value: 2)
!1401 = !DIEnumerator(name: "BYTES", value: 3)
!1402 = !{!93, !1202, !16, !9}
!1403 = !{!1404}
!1404 = !DIGlobalVariableExpression(var: !1405, expr: !DIExpression(DW_OP_constu, 4294967294, DW_OP_stack_value))
!1405 = distinct !DIGlobalVariable(name: "kMaxEpoch", scope: !6, file: !107, line: 13, type: !108, isLocal: true, isDefinition: true)
!1406 = !{!110, !117, !121, !125, !129, !132, !134, !136, !138, !142, !145, !148, !151, !154, !156, !157, !158, !159, !163, !165, !167, !169, !171, !174, !177, !180, !183, !186, !188, !298, !302, !306, !323, !326, !331, !339, !347, !351, !358, !362, !366, !368, !370, !374, !383, !387, !393, !399, !401, !405, !409, !413, !1407, !1414, !1416, !1420, !1424, !1428, !441, !447, !451, !455, !457, !459, !463, !471, !475, !479, !483, !485, !491, !493, !500, !505, !509, !513, !517, !521, !525, !527, !529, !533, !537, !541, !543, !547, !551, !553, !555, !559, !565, !570, !575, !576, !577, !578, !1430, !1431, !1432, !582, !583, !584, !585, !587, !589, !593, !597, !602, !608, !610, !612, !614, !616, !618, !620, !622, !624, !626, !628, !630, !632, !634, !638, !642, !648, !652, !656, !661, !663, !667, !671, !675, !685, !687, !691, !695, !699, !703, !707, !711, !715, !719, !723, !727, !731, !733, !735, !739, !743, !749, !753, !757, !759, !763, !767, !773, !775, !779, !783, !787, !791, !795, !799, !803, !804, !805, !806, !808, !809, !810, !811, !812, !813, !814, !818, !824, !829, !833, !835, !837, !839, !841, !848, !852, !856, !860, !864, !868, !873, !877, !879, !883, !889, !893, !898, !900, !902, !906, !910, !912, !914, !916, !918, !922, !924, !926, !930, !934, !938, !942, !946, !950, !1433, !1437, !1441, !964, !1445, !1447, !1449, !1453, !980, !1457, !1458, !1459, !1460, !985}
!1407 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1408, file: !322, line: 162)
!1408 = !DISubprogram(name: "vfwprintf", scope: !328, file: !328, line: 750, type: !1409, flags: DIFlagPrototyped, spFlags: 0)
!1409 = !DISubroutineType(types: !1410)
!1410 = !{!124, !346, !355, !1411}
!1411 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !422, line: 14, baseType: !1412)
!1412 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !1413, baseType: !194)
!1413 = !DIFile(filename: "csynth_r2/hls/.autopilot/db/laya_tasks.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis")
!1414 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1415, file: !322, line: 164)
!1415 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc23_vfwscanf", scope: !328, file: !328, line: 875, type: !1409, flags: DIFlagPrototyped, spFlags: 0)
!1416 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1417, file: !322, line: 167)
!1417 = !DISubprogram(name: "vswprintf", scope: !328, file: !328, line: 763, type: !1418, flags: DIFlagPrototyped, spFlags: 0)
!1418 = !DISubroutineType(types: !1419)
!1419 = !{!124, !345, !378, !355, !1411}
!1420 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1421, file: !322, line: 170)
!1421 = !DISubprogram(name: "vswscanf", linkageName: "__isoc23_vswscanf", scope: !328, file: !328, line: 882, type: !1422, flags: DIFlagPrototyped, spFlags: 0)
!1422 = !DISubroutineType(types: !1423)
!1423 = !{!124, !355, !355, !1411}
!1424 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1425, file: !322, line: 172)
!1425 = !DISubprogram(name: "vwprintf", scope: !328, file: !328, line: 758, type: !1426, flags: DIFlagPrototyped, spFlags: 0)
!1426 = !DISubroutineType(types: !1427)
!1427 = !{!124, !355, !1411}
!1428 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1429, file: !322, line: 174)
!1429 = !DISubprogram(name: "vwscanf", linkageName: "__isoc23_vwscanf", scope: !328, file: !328, line: 879, type: !1426, flags: DIFlagPrototyped, spFlags: 0)
!1430 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1415, file: !322, line: 283)
!1431 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1421, file: !322, line: 286)
!1432 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1429, file: !322, line: 289)
!1433 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1434, file: !817, line: 144)
!1434 = !DISubprogram(name: "vfprintf", scope: !820, file: !820, line: 372, type: !1435, flags: DIFlagPrototyped, spFlags: 0)
!1435 = !DISubroutineType(types: !1436)
!1436 = !{!124, !845, !380, !1411}
!1437 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1438, file: !817, line: 145)
!1438 = !DISubprogram(name: "vprintf", scope: !820, file: !820, line: 378, type: !1439, flags: DIFlagPrototyped, spFlags: 0)
!1439 = !DISubroutineType(types: !1440)
!1440 = !{!124, !380, !1411}
!1441 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1442, file: !817, line: 146)
!1442 = !DISubprogram(name: "vsprintf", scope: !820, file: !820, line: 380, type: !1443, flags: DIFlagPrototyped, spFlags: 0)
!1443 = !DISubroutineType(types: !1444)
!1444 = !{!124, !445, !380, !1411}
!1445 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1446, file: !817, line: 176)
!1446 = !DISubprogram(name: "vfscanf", linkageName: "__isoc23_vfscanf", scope: !820, file: !820, line: 511, type: !1435, flags: DIFlagPrototyped, spFlags: 0)
!1447 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1448, file: !817, line: 177)
!1448 = !DISubprogram(name: "vscanf", linkageName: "__isoc23_vscanf", scope: !820, file: !820, line: 516, type: !1439, flags: DIFlagPrototyped, spFlags: 0)
!1449 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1450, file: !817, line: 178)
!1450 = !DISubprogram(name: "vsnprintf", scope: !820, file: !820, line: 389, type: !1451, flags: DIFlagPrototyped, spFlags: 0)
!1451 = !DISubroutineType(types: !1452)
!1452 = !{!124, !445, !378, !380, !1411}
!1453 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1454, file: !817, line: 179)
!1454 = !DISubprogram(name: "vsscanf", linkageName: "__isoc23_vsscanf", scope: !820, file: !820, line: 519, type: !1455, flags: DIFlagPrototyped, spFlags: 0)
!1455 = !DISubroutineType(types: !1456)
!1456 = !{!124, !380, !380, !1411}
!1457 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1446, file: !817, line: 186)
!1458 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1448, file: !817, line: 187)
!1459 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1450, file: !817, line: 188)
!1460 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1454, file: !817, line: 189)
!1461 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1462, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !1463, retainedTypes: !1464, globals: !1465, imports: !1466, splitDebugInlining: false, nameTableKind: GNU)
!1462 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis/csynth_r2/hls/.autopilot/db/full_owner_index_pilot.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis", checksumkind: CSK_MD5, checksum: "c3aad135c38d3db9608d0a08d29dc286")
!1463 = !{!47, !14, !58, !63, !73}
!1464 = !{!93}
!1465 = !{!995}
!1466 = !{!110, !117, !121, !125, !129, !132, !134, !136, !138, !142, !145, !148, !151, !154, !156, !157, !158, !159, !163, !165, !167, !169, !171, !174, !177, !180, !183, !186, !188, !298, !302, !306, !323, !326, !331, !339, !347, !351, !358, !362, !366, !368, !370, !374, !383, !387, !393, !399, !401, !405, !409, !413, !1467, !1474, !1476, !1480, !1484, !1488, !441, !447, !451, !455, !457, !459, !463, !471, !475, !479, !483, !485, !491, !493, !500, !505, !509, !513, !517, !521, !525, !527, !529, !533, !537, !541, !543, !547, !551, !553, !555, !559, !565, !570, !575, !576, !577, !578, !1490, !1491, !1492, !582, !583, !584, !585, !587, !589, !593, !597, !602, !608, !610, !612, !614, !616, !618, !620, !622, !624, !626, !628, !630, !632, !634, !638, !642, !648, !652, !656, !661, !663, !667, !671, !675, !685, !687, !691, !695, !699, !703, !707, !711, !715, !719, !723, !727, !731, !733, !735, !739, !743, !749, !753, !757, !759, !763, !767, !773, !775, !779, !783, !787, !791, !795, !799, !803, !804, !805, !806, !808, !809, !810, !811, !812, !813, !814, !818, !824, !829, !833, !835, !837, !839, !841, !848, !852, !856, !860, !864, !868, !873, !877, !879, !883, !889, !893, !898, !900, !902, !906, !910, !912, !914, !916, !918, !922, !924, !926, !930, !934, !938, !942, !946, !950, !1493, !1497, !1501, !964, !1505, !1507, !1509, !1513, !980, !1517, !1518, !1519, !1520, !985, !1521}
!1467 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1468, file: !322, line: 162)
!1468 = !DISubprogram(name: "vfwprintf", scope: !328, file: !328, line: 750, type: !1469, flags: DIFlagPrototyped, spFlags: 0)
!1469 = !DISubroutineType(types: !1470)
!1470 = !{!124, !346, !355, !1471}
!1471 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !422, line: 14, baseType: !1472)
!1472 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !1473, baseType: !194)
!1473 = !DIFile(filename: "csynth_r2/hls/.autopilot/db/full_owner_index_pilot.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/owner-index-pilot-vitis")
!1474 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1475, file: !322, line: 164)
!1475 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc23_vfwscanf", scope: !328, file: !328, line: 875, type: !1469, flags: DIFlagPrototyped, spFlags: 0)
!1476 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1477, file: !322, line: 167)
!1477 = !DISubprogram(name: "vswprintf", scope: !328, file: !328, line: 763, type: !1478, flags: DIFlagPrototyped, spFlags: 0)
!1478 = !DISubroutineType(types: !1479)
!1479 = !{!124, !345, !378, !355, !1471}
!1480 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1481, file: !322, line: 170)
!1481 = !DISubprogram(name: "vswscanf", linkageName: "__isoc23_vswscanf", scope: !328, file: !328, line: 882, type: !1482, flags: DIFlagPrototyped, spFlags: 0)
!1482 = !DISubroutineType(types: !1483)
!1483 = !{!124, !355, !355, !1471}
!1484 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1485, file: !322, line: 172)
!1485 = !DISubprogram(name: "vwprintf", scope: !328, file: !328, line: 758, type: !1486, flags: DIFlagPrototyped, spFlags: 0)
!1486 = !DISubroutineType(types: !1487)
!1487 = !{!124, !355, !1471}
!1488 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1489, file: !322, line: 174)
!1489 = !DISubprogram(name: "vwscanf", linkageName: "__isoc23_vwscanf", scope: !328, file: !328, line: 879, type: !1486, flags: DIFlagPrototyped, spFlags: 0)
!1490 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1475, file: !322, line: 283)
!1491 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1481, file: !322, line: 286)
!1492 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1489, file: !322, line: 289)
!1493 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1494, file: !817, line: 144)
!1494 = !DISubprogram(name: "vfprintf", scope: !820, file: !820, line: 372, type: !1495, flags: DIFlagPrototyped, spFlags: 0)
!1495 = !DISubroutineType(types: !1496)
!1496 = !{!124, !845, !380, !1471}
!1497 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1498, file: !817, line: 145)
!1498 = !DISubprogram(name: "vprintf", scope: !820, file: !820, line: 378, type: !1499, flags: DIFlagPrototyped, spFlags: 0)
!1499 = !DISubroutineType(types: !1500)
!1500 = !{!124, !380, !1471}
!1501 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1502, file: !817, line: 146)
!1502 = !DISubprogram(name: "vsprintf", scope: !820, file: !820, line: 380, type: !1503, flags: DIFlagPrototyped, spFlags: 0)
!1503 = !DISubroutineType(types: !1504)
!1504 = !{!124, !445, !380, !1471}
!1505 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1506, file: !817, line: 176)
!1506 = !DISubprogram(name: "vfscanf", linkageName: "__isoc23_vfscanf", scope: !820, file: !820, line: 511, type: !1495, flags: DIFlagPrototyped, spFlags: 0)
!1507 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1508, file: !817, line: 177)
!1508 = !DISubprogram(name: "vscanf", linkageName: "__isoc23_vscanf", scope: !820, file: !820, line: 516, type: !1499, flags: DIFlagPrototyped, spFlags: 0)
!1509 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1510, file: !817, line: 178)
!1510 = !DISubprogram(name: "vsnprintf", scope: !820, file: !820, line: 389, type: !1511, flags: DIFlagPrototyped, spFlags: 0)
!1511 = !DISubroutineType(types: !1512)
!1512 = !{!124, !445, !378, !380, !1471}
!1513 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !560, entity: !1514, file: !817, line: 179)
!1514 = !DISubprogram(name: "vsscanf", linkageName: "__isoc23_vsscanf", scope: !820, file: !820, line: 519, type: !1515, flags: DIFlagPrototyped, spFlags: 0)
!1515 = !DISubroutineType(types: !1516)
!1516 = !{!124, !380, !380, !1471}
!1517 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1506, file: !817, line: 186)
!1518 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1508, file: !817, line: 187)
!1519 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1510, file: !817, line: 188)
!1520 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !111, entity: !1514, file: !817, line: 189)
!1521 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !1461, entity: !6, file: !998, line: 3)
!1522 = !{!"AMD/Xilinx clang version 16.0.6"}
!1523 = !{!"clang version 7.0.0 "}
!1524 = !{i32 2, !"Dwarf Version", i32 4}
!1525 = !{i32 2, !"Debug Info Version", i32 3}
!1526 = !{i32 1, !"wchar_size", i32 4}
!1527 = distinct !DISubprogram(name: "check_ref", linkageName: "_ZN4laya9check_refENS_9BufferRefEh", scope: !6, file: !1528, line: 34, type: !1529, scopeLine: 34, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1395, retainedNodes: !990)
!1528 = !DIFile(filename: "hls/common/laya_tasks.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1529 = !DISubroutineType(types: !1530)
!1530 = !{!1202, !96, !16}
!1531 = !DILocalVariable(name: "r", arg: 1, scope: !1527, file: !1528, line: 34, type: !96)
!1532 = !DILocation(line: 34, column: 27, scope: !1527)
!1533 = !DILocalVariable(name: "region", arg: 2, scope: !1527, file: !1528, line: 34, type: !16)
!1534 = !DILocation(line: 34, column: 37, scope: !1527)
!1535 = !DILocation(line: 35, column: 8, scope: !1536)
!1536 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 35, column: 6)
!1537 = !DILocation(line: 35, column: 10, scope: !1536)
!1538 = !DILocation(line: 35, column: 6, scope: !1527)
!1539 = !DILocation(line: 35, column: 34, scope: !1536)
!1540 = !DILocation(line: 35, column: 32, scope: !1536)
!1541 = !DILocation(line: 35, column: 38, scope: !1536)
!1542 = !DILocation(line: 35, column: 41, scope: !1536)
!1543 = !DILocation(line: 35, column: 45, scope: !1536)
!1544 = !DILocation(line: 35, column: 50, scope: !1536)
!1545 = !DILocation(line: 35, column: 53, scope: !1536)
!1546 = !DILocation(line: 35, column: 55, scope: !1536)
!1547 = !DILocation(line: 35, column: 61, scope: !1536)
!1548 = !DILocation(line: 35, column: 65, scope: !1536)
!1549 = !DILocation(line: 35, column: 75, scope: !1536)
!1550 = !DILocation(line: 35, column: 93, scope: !1536)
!1551 = !DILocation(line: 35, column: 25, scope: !1536)
!1552 = !DILocation(line: 36, column: 8, scope: !1553)
!1553 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 36, column: 6)
!1554 = !DILocation(line: 36, column: 13, scope: !1553)
!1555 = !DILocation(line: 36, column: 16, scope: !1553)
!1556 = !DILocation(line: 36, column: 20, scope: !1553)
!1557 = !DILocation(line: 36, column: 25, scope: !1553)
!1558 = !DILocation(line: 36, column: 6, scope: !1527)
!1559 = !DILocation(line: 36, column: 43, scope: !1553)
!1560 = !DILocation(line: 36, column: 80, scope: !1553)
!1561 = !DILocation(line: 36, column: 61, scope: !1553)
!1562 = !DILocation(line: 36, column: 36, scope: !1553)
!1563 = !DILocation(line: 37, column: 3, scope: !1527)
!1564 = !DILocalVariable(name: "id", scope: !1527, file: !1528, line: 37, type: !16)
!1565 = !DILocation(line: 37, column: 11, scope: !1527)
!1566 = !DILocation(line: 37, column: 24, scope: !1527)
!1567 = !DILocation(line: 37, column: 28, scope: !1527)
!1568 = !DILocalVariable(name: "valid", scope: !1527, file: !1528, line: 37, type: !237)
!1569 = !DILocation(line: 37, column: 33, scope: !1527)
!1570 = !DILocation(line: 37, column: 40, scope: !1527)
!1571 = !DILocation(line: 37, column: 42, scope: !1527)
!1572 = !DILocation(line: 37, column: 45, scope: !1527)
!1573 = !DILocation(line: 37, column: 47, scope: !1527)
!1574 = !DILocation(line: 37, column: 49, scope: !1527)
!1575 = !DILocation(line: 37, column: 54, scope: !1527)
!1576 = !DILocation(line: 37, column: 57, scope: !1527)
!1577 = !DILocation(line: 37, column: 59, scope: !1527)
!1578 = !DILocation(line: 37, column: 65, scope: !1527)
!1579 = !DILocation(line: 37, column: 67, scope: !1527)
!1580 = !DILocation(line: 37, column: 69, scope: !1527)
!1581 = !DILocation(line: 0, scope: !1527)
!1582 = !DILocation(line: 38, column: 7, scope: !1583)
!1583 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 38, column: 6)
!1584 = !DILocation(line: 38, column: 6, scope: !1527)
!1585 = !DILocation(line: 38, column: 20, scope: !1583)
!1586 = !DILocation(line: 38, column: 47, scope: !1583)
!1587 = !DILocation(line: 38, column: 38, scope: !1583)
!1588 = !DILocation(line: 38, column: 13, scope: !1583)
!1589 = !DILocation(line: 39, column: 3, scope: !1527)
!1590 = !DILocalVariable(name: "dual", scope: !1527, file: !1528, line: 39, type: !237)
!1591 = !DILocation(line: 39, column: 8, scope: !1527)
!1592 = !DILocation(line: 39, column: 13, scope: !1527)
!1593 = !DILocation(line: 39, column: 15, scope: !1527)
!1594 = !DILocation(line: 39, column: 18, scope: !1527)
!1595 = !DILocation(line: 39, column: 20, scope: !1527)
!1596 = !DILocation(line: 39, column: 22, scope: !1527)
!1597 = !DILocation(line: 39, column: 25, scope: !1527)
!1598 = !DILocation(line: 39, column: 28, scope: !1527)
!1599 = !DILocation(line: 39, column: 30, scope: !1527)
!1600 = !DILocation(line: 39, column: 36, scope: !1527)
!1601 = !DILocation(line: 39, column: 38, scope: !1527)
!1602 = !DILocation(line: 39, column: 40, scope: !1527)
!1603 = !DILocation(line: 39, column: 46, scope: !1527)
!1604 = !DILocation(line: 39, column: 48, scope: !1527)
!1605 = !DILocation(line: 39, column: 50, scope: !1527)
!1606 = !DILocation(line: 39, column: 56, scope: !1527)
!1607 = !DILocation(line: 39, column: 58, scope: !1527)
!1608 = !DILocation(line: 39, column: 60, scope: !1527)
!1609 = !DILocation(line: 40, column: 6, scope: !1610)
!1610 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 40, column: 6)
!1611 = !DILocation(line: 40, column: 8, scope: !1610)
!1612 = !DILocation(line: 40, column: 14, scope: !1610)
!1613 = !DILocation(line: 40, column: 16, scope: !1610)
!1614 = !DILocation(line: 40, column: 18, scope: !1610)
!1615 = !DILocation(line: 40, column: 6, scope: !1527)
!1616 = !DILocation(line: 40, column: 29, scope: !1610)
!1617 = !DILocation(line: 40, column: 25, scope: !1610)
!1618 = !DILocation(line: 41, column: 8, scope: !1619)
!1619 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 41, column: 6)
!1620 = !DILocation(line: 41, column: 6, scope: !1619)
!1621 = !DILocation(line: 41, column: 14, scope: !1619)
!1622 = !DILocation(line: 41, column: 12, scope: !1619)
!1623 = !DILocation(line: 41, column: 6, scope: !1527)
!1624 = !DILocation(line: 41, column: 31, scope: !1619)
!1625 = !DILocation(line: 41, column: 58, scope: !1619)
!1626 = !DILocation(line: 41, column: 49, scope: !1619)
!1627 = !DILocation(line: 41, column: 24, scope: !1619)
!1628 = !DILocation(line: 42, column: 6, scope: !1629)
!1629 = distinct !DILexicalBlock(scope: !1527, file: !1528, line: 42, column: 6)
!1630 = !DILocation(line: 42, column: 8, scope: !1629)
!1631 = !DILocation(line: 42, column: 6, scope: !1527)
!1632 = !DILocation(line: 42, column: 17, scope: !1633)
!1633 = distinct !DILexicalBlock(scope: !1634, file: !1528, line: 42, column: 17)
!1634 = distinct !DILexicalBlock(scope: !1629, file: !1528, line: 42, column: 13)
!1635 = !DILocation(line: 42, column: 23, scope: !1633)
!1636 = !DILocation(line: 42, column: 17, scope: !1634)
!1637 = !DILocation(line: 42, column: 33, scope: !1633)
!1638 = !DILocation(line: 42, column: 60, scope: !1633)
!1639 = !DILocation(line: 42, column: 51, scope: !1633)
!1640 = !DILocation(line: 42, column: 26, scope: !1633)
!1641 = !DILocation(line: 42, column: 67, scope: !1634)
!1642 = !DILocation(line: 43, column: 11, scope: !1643)
!1643 = distinct !DILexicalBlock(scope: !1629, file: !1528, line: 43, column: 11)
!1644 = !DILocation(line: 43, column: 11, scope: !1629)
!1645 = !DILocation(line: 43, column: 25, scope: !1643)
!1646 = !DILocation(line: 43, column: 52, scope: !1643)
!1647 = !DILocation(line: 43, column: 43, scope: !1643)
!1648 = !DILocation(line: 43, column: 18, scope: !1643)
!1649 = !DILocation(line: 44, column: 10, scope: !1527)
!1650 = !DILocation(line: 44, column: 3, scope: !1527)
!1651 = !DILocation(line: 45, column: 1, scope: !1527)
!1652 = distinct !DISubprogram(name: "ok", linkageName: "_ZN4laya2okEv", scope: !6, file: !15, line: 10, type: !1653, scopeLine: 10, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1395, retainedNodes: !990)
!1653 = !DISubroutineType(types: !1654)
!1654 = !{!1202}
!1655 = !DILocation(line: 10, column: 31, scope: !1652)
!1656 = !DILocation(line: 10, column: 24, scope: !1652)
!1657 = distinct !DISubprogram(name: "detail", linkageName: "_ZN4laya6detailEhht", scope: !6, file: !15, line: 11, type: !1658, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1395, retainedNodes: !990)
!1658 = !DISubroutineType(types: !1659)
!1659 = !{!93, !16, !16, !9}
!1660 = !DILocalVariable(name: "domain", arg: 1, scope: !1657, file: !15, line: 11, type: !16)
!1661 = !DILocation(line: 11, column: 35, scope: !1657)
!1662 = !DILocalVariable(name: "object", arg: 2, scope: !1657, file: !15, line: 11, type: !16)
!1663 = !DILocation(line: 11, column: 50, scope: !1657)
!1664 = !DILocalVariable(name: "reason", arg: 3, scope: !1657, file: !15, line: 11, type: !9)
!1665 = !DILocation(line: 11, column: 66, scope: !1657)
!1666 = !DILocation(line: 11, column: 93, scope: !1657)
!1667 = !DILocation(line: 11, column: 100, scope: !1657)
!1668 = !DILocation(line: 11, column: 116, scope: !1657)
!1669 = !DILocation(line: 11, column: 123, scope: !1657)
!1670 = !DILocation(line: 11, column: 105, scope: !1657)
!1671 = !DILocation(line: 11, column: 129, scope: !1657)
!1672 = !DILocation(line: 11, column: 128, scope: !1657)
!1673 = !DILocation(line: 11, column: 76, scope: !1657)
!1674 = distinct !DISubprogram(name: "numeric_identity_valid", linkageName: "_ZN4laya22numeric_identity_validERKNS_15NumericIdentityE", scope: !6, file: !1675, line: 43, type: !1676, scopeLine: 43, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!1675 = !DIFile(filename: "hls/common/laya_numeric.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1676 = !DISubroutineType(types: !1677)
!1677 = !{!237, !1678}
!1678 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1679, size: 64)
!1679 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1006)
!1680 = !DILocalVariable(name: "x", arg: 1, scope: !1674, file: !1675, line: 43, type: !1678)
!1681 = !DILocation(line: 43, column: 52, scope: !1674)
!1682 = !DILocation(line: 44, column: 3, scope: !1674)
!1683 = !DILocalVariable(name: "legal_s", scope: !1674, file: !1675, line: 44, type: !1684)
!1684 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !237)
!1685 = !DILocation(line: 44, column: 14, scope: !1674)
!1686 = !DILocation(line: 44, column: 24, scope: !1674)
!1687 = !DILocation(line: 44, column: 26, scope: !1674)
!1688 = !DILocation(line: 44, column: 28, scope: !1674)
!1689 = !DILocation(line: 44, column: 34, scope: !1674)
!1690 = !DILocation(line: 44, column: 37, scope: !1674)
!1691 = !DILocation(line: 44, column: 39, scope: !1674)
!1692 = !DILocation(line: 44, column: 41, scope: !1674)
!1693 = !DILocation(line: 44, column: 48, scope: !1674)
!1694 = !DILocation(line: 44, column: 51, scope: !1674)
!1695 = !DILocation(line: 44, column: 53, scope: !1674)
!1696 = !DILocation(line: 44, column: 55, scope: !1674)
!1697 = !DILocation(line: 44, column: 62, scope: !1674)
!1698 = !DILocation(line: 45, column: 24, scope: !1674)
!1699 = !DILocation(line: 45, column: 26, scope: !1674)
!1700 = !DILocation(line: 45, column: 28, scope: !1674)
!1701 = !DILocation(line: 45, column: 35, scope: !1674)
!1702 = !DILocation(line: 45, column: 38, scope: !1674)
!1703 = !DILocation(line: 45, column: 40, scope: !1674)
!1704 = !DILocation(line: 45, column: 42, scope: !1674)
!1705 = !DILocation(line: 46, column: 10, scope: !1674)
!1706 = !DILocation(line: 46, column: 12, scope: !1674)
!1707 = !DILocation(line: 46, column: 23, scope: !1674)
!1708 = !DILocation(line: 46, column: 26, scope: !1674)
!1709 = !DILocation(line: 46, column: 28, scope: !1674)
!1710 = !DILocation(line: 46, column: 39, scope: !1674)
!1711 = !DILocation(line: 46, column: 42, scope: !1674)
!1712 = !DILocation(line: 46, column: 44, scope: !1674)
!1713 = !DILocation(line: 46, column: 46, scope: !1674)
!1714 = !DILocation(line: 46, column: 51, scope: !1674)
!1715 = !DILocation(line: 46, column: 54, scope: !1674)
!1716 = !DILocation(line: 46, column: 56, scope: !1674)
!1717 = !DILocation(line: 46, column: 58, scope: !1674)
!1718 = !DILocation(line: 46, column: 63, scope: !1674)
!1719 = !DILocation(line: 46, column: 66, scope: !1674)
!1720 = !DILocation(line: 46, column: 74, scope: !1674)
!1721 = !DILocation(line: 47, column: 18, scope: !1674)
!1722 = !DILocation(line: 47, column: 20, scope: !1674)
!1723 = !DILocation(line: 47, column: 10, scope: !1674)
!1724 = !DILocation(line: 47, column: 35, scope: !1674)
!1725 = !DILocation(line: 47, column: 46, scope: !1674)
!1726 = !DILocation(line: 47, column: 48, scope: !1674)
!1727 = !DILocation(line: 47, column: 38, scope: !1674)
!1728 = !DILocation(line: 47, column: 65, scope: !1674)
!1729 = !DILocation(line: 48, column: 18, scope: !1674)
!1730 = !DILocation(line: 48, column: 20, scope: !1674)
!1731 = !DILocation(line: 48, column: 10, scope: !1674)
!1732 = !DILocation(line: 48, column: 36, scope: !1674)
!1733 = !DILocation(line: 48, column: 47, scope: !1674)
!1734 = !DILocation(line: 48, column: 49, scope: !1674)
!1735 = !DILocation(line: 48, column: 39, scope: !1674)
!1736 = !DILocation(line: 0, scope: !1674)
!1737 = !DILocation(line: 49, column: 1, scope: !1674)
!1738 = !DILocation(line: 46, column: 3, scope: !1674)
!1739 = distinct !DISubprogram(name: "nonzero", linkageName: "_ZN4laya12_GLOBAL__N_17nonzeroEPKhj", scope: !1740, file: !1675, line: 11, type: !1741, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!1740 = !DINamespace(scope: !6)
!1741 = !DISubroutineType(types: !1742)
!1742 = !{!237, !1743, !95}
!1743 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1744, size: 64)
!1744 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !16)
!1745 = !DILocalVariable(name: "a", arg: 1, scope: !1739, file: !1675, line: 11, type: !1743)
!1746 = !DILocation(line: 11, column: 29, scope: !1739)
!1747 = !DILocalVariable(name: "n", arg: 2, scope: !1739, file: !1675, line: 11, type: !95)
!1748 = !DILocation(line: 11, column: 41, scope: !1739)
!1749 = !DILocation(line: 11, column: 44, scope: !1739)
!1750 = !DILocation(line: 12, column: 25, scope: !1751)
!1751 = distinct !DILexicalBlock(scope: !1739, file: !1675, line: 12, column: 20)
!1752 = !DILocalVariable(name: "i", scope: !1751, file: !1675, line: 12, type: !95)
!1753 = !DILocation(line: 12, column: 34, scope: !1751)
!1754 = !DILocation(line: 12, column: 41, scope: !1755)
!1755 = distinct !DILexicalBlock(scope: !1751, file: !1675, line: 12, column: 20)
!1756 = !DILocation(line: 12, column: 45, scope: !1755)
!1757 = !DILocation(line: 12, column: 43, scope: !1755)
!1758 = !DILocation(line: 12, column: 20, scope: !1751)
!1759 = !DILocation(line: 12, column: 57, scope: !1760)
!1760 = distinct !DILexicalBlock(scope: !1755, file: !1675, line: 12, column: 57)
!1761 = !DILocation(line: 12, column: 59, scope: !1760)
!1762 = !DILocation(line: 12, column: 57, scope: !1755)
!1763 = !DILocation(line: 12, column: 63, scope: !1760)
!1764 = !DILocation(line: 12, column: 60, scope: !1760)
!1765 = !DILocation(line: 12, column: 48, scope: !1755)
!1766 = !DILocation(line: 12, column: 20, scope: !1755)
!1767 = distinct !{!1767, !1758, !1768, !1769, !1770}
!1768 = !DILocation(line: 12, column: 70, scope: !1751)
!1769 = !{!"llvm.loop.mustprogress"}
!1770 = !{!"llvm.loop.name", !"VITIS_LOOP_12_1"}
!1771 = !DILocation(line: 13, column: 3, scope: !1739)
!1772 = !DILocation(line: 14, column: 1, scope: !1739)
!1773 = distinct !DISubprogram(name: "numeric_reset_f32", linkageName: "_ZN4laya17numeric_reset_f32ERNS_11F32TileMetaE", scope: !6, file: !1675, line: 301, type: !1774, scopeLine: 301, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!1774 = !DISubroutineType(types: !1775)
!1775 = !{null, !1776}
!1776 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1085, size: 64)
!1777 = !DILocalVariable(name: "owner", arg: 1, scope: !1773, file: !1675, line: 301, type: !1776)
!1778 = !DILocation(line: 301, column: 37, scope: !1773)
!1779 = !DILocation(line: 302, column: 3, scope: !1773)
!1780 = !DILocation(line: 302, column: 9, scope: !1773)
!1781 = !DILocation(line: 302, column: 15, scope: !1773)
!1782 = !DILocation(line: 302, column: 38, scope: !1773)
!1783 = !DILocation(line: 302, column: 44, scope: !1773)
!1784 = !DILocation(line: 302, column: 50, scope: !1773)
!1785 = !DILocation(line: 302, column: 59, scope: !1773)
!1786 = !DILocation(line: 302, column: 65, scope: !1773)
!1787 = !DILocation(line: 302, column: 73, scope: !1773)
!1788 = !DILocation(line: 303, column: 26, scope: !1789)
!1789 = distinct !DILexicalBlock(scope: !1773, file: !1675, line: 303, column: 21)
!1790 = !DILocalVariable(name: "r", scope: !1789, file: !1675, line: 303, type: !95)
!1791 = !DILocation(line: 303, column: 35, scope: !1789)
!1792 = !DILocation(line: 303, column: 42, scope: !1793)
!1793 = distinct !DILexicalBlock(scope: !1789, file: !1675, line: 303, column: 21)
!1794 = !DILocation(line: 303, column: 44, scope: !1793)
!1795 = !DILocation(line: 303, column: 21, scope: !1789)
!1796 = !DILocation(line: 303, column: 21, scope: !1793)
!1797 = !DILocation(line: 304, column: 28, scope: !1798)
!1798 = distinct !DILexicalBlock(scope: !1793, file: !1675, line: 304, column: 23)
!1799 = !DILocalVariable(name: "word", scope: !1798, file: !1675, line: 304, type: !95)
!1800 = !DILocation(line: 304, column: 37, scope: !1798)
!1801 = !DILocation(line: 304, column: 47, scope: !1802)
!1802 = distinct !DILexicalBlock(scope: !1798, file: !1675, line: 304, column: 23)
!1803 = !DILocation(line: 304, column: 52, scope: !1802)
!1804 = !DILocation(line: 304, column: 23, scope: !1798)
!1805 = !DILocation(line: 304, column: 23, scope: !1802)
!1806 = !DILocation(line: 305, column: 7, scope: !1802)
!1807 = !DILocation(line: 305, column: 13, scope: !1802)
!1808 = !DILocation(line: 305, column: 28, scope: !1802)
!1809 = !DILocation(line: 305, column: 31, scope: !1802)
!1810 = !DILocation(line: 305, column: 37, scope: !1802)
!1811 = !DILocation(line: 304, column: 57, scope: !1802)
!1812 = distinct !{!1812, !1804, !1813, !1769, !1814}
!1813 = !DILocation(line: 305, column: 39, scope: !1798)
!1814 = !{!"llvm.loop.name", !"VITIS_LOOP_304_2"}
!1815 = !DILocation(line: 303, column: 50, scope: !1793)
!1816 = distinct !{!1816, !1795, !1817, !1769, !1818}
!1817 = !DILocation(line: 305, column: 39, scope: !1789)
!1818 = !{!"llvm.loop.name", !"VITIS_LOOP_303_1"}
!1819 = !DILocation(line: 306, column: 1, scope: !1773)
!1820 = distinct !DISubprogram(name: "numeric_reset_a8", linkageName: "_ZN4laya16numeric_reset_a8ERNS_10A8TileMetaE", scope: !6, file: !1675, line: 307, type: !1821, scopeLine: 307, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!1821 = !DISubroutineType(types: !1822)
!1822 = !{null, !1823}
!1823 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1103, size: 64)
!1824 = !DILocalVariable(name: "owner", arg: 1, scope: !1820, file: !1675, line: 307, type: !1823)
!1825 = !DILocation(line: 307, column: 35, scope: !1820)
!1826 = !DILocation(line: 308, column: 3, scope: !1820)
!1827 = !DILocation(line: 308, column: 9, scope: !1820)
!1828 = !DILocation(line: 308, column: 15, scope: !1820)
!1829 = !DILocation(line: 308, column: 38, scope: !1820)
!1830 = !DILocation(line: 308, column: 44, scope: !1820)
!1831 = !DILocation(line: 308, column: 50, scope: !1820)
!1832 = !DILocation(line: 308, column: 59, scope: !1820)
!1833 = !DILocation(line: 308, column: 65, scope: !1820)
!1834 = !DILocation(line: 308, column: 73, scope: !1820)
!1835 = !DILocation(line: 309, column: 26, scope: !1836)
!1836 = distinct !DILexicalBlock(scope: !1820, file: !1675, line: 309, column: 21)
!1837 = !DILocalVariable(name: "r", scope: !1836, file: !1675, line: 309, type: !95)
!1838 = !DILocation(line: 309, column: 35, scope: !1836)
!1839 = !DILocation(line: 309, column: 42, scope: !1840)
!1840 = distinct !DILexicalBlock(scope: !1836, file: !1675, line: 309, column: 21)
!1841 = !DILocation(line: 309, column: 44, scope: !1840)
!1842 = !DILocation(line: 309, column: 21, scope: !1836)
!1843 = !DILocation(line: 309, column: 21, scope: !1840)
!1844 = !DILocation(line: 310, column: 28, scope: !1845)
!1845 = distinct !DILexicalBlock(scope: !1840, file: !1675, line: 310, column: 23)
!1846 = !DILocalVariable(name: "word", scope: !1845, file: !1675, line: 310, type: !95)
!1847 = !DILocation(line: 310, column: 37, scope: !1845)
!1848 = !DILocation(line: 310, column: 47, scope: !1849)
!1849 = distinct !DILexicalBlock(scope: !1845, file: !1675, line: 310, column: 23)
!1850 = !DILocation(line: 310, column: 52, scope: !1849)
!1851 = !DILocation(line: 310, column: 23, scope: !1845)
!1852 = !DILocation(line: 310, column: 23, scope: !1849)
!1853 = !DILocation(line: 311, column: 7, scope: !1849)
!1854 = !DILocation(line: 311, column: 13, scope: !1849)
!1855 = !DILocation(line: 311, column: 28, scope: !1849)
!1856 = !DILocation(line: 311, column: 31, scope: !1849)
!1857 = !DILocation(line: 311, column: 37, scope: !1849)
!1858 = !DILocation(line: 310, column: 57, scope: !1849)
!1859 = distinct !{!1859, !1851, !1860, !1769, !1861}
!1860 = !DILocation(line: 311, column: 39, scope: !1845)
!1861 = !{!"llvm.loop.name", !"VITIS_LOOP_310_2"}
!1862 = !DILocation(line: 309, column: 50, scope: !1840)
!1863 = distinct !{!1863, !1842, !1864, !1769, !1865}
!1864 = !DILocation(line: 311, column: 39, scope: !1836)
!1865 = !{!"llvm.loop.name", !"VITIS_LOOP_309_1"}
!1866 = !DILocation(line: 312, column: 1, scope: !1820)
!1867 = distinct !DISubprogram(name: "full_claim_owner", linkageName: "_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE", scope: !5, file: !3, line: 197, type: !1868, scopeLine: 197, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!1868 = !DISubroutineType(types: !1869)
!1869 = !{!1202, !1870, !1871}
!1870 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !999, size: 64)
!1871 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1872, size: 64)
!1872 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1166)
!1873 = !DILocalVariable(name: "rt", arg: 1, scope: !1867, file: !3, line: 197, type: !1870)
!1874 = !DILocation(line: 197, column: 37, scope: !1867)
!1875 = !DILocalVariable(name: "s", arg: 2, scope: !1867, file: !3, line: 197, type: !1871)
!1876 = !DILocation(line: 197, column: 62, scope: !1867)
!1877 = !DILocation(line: 198, column: 8, scope: !1878)
!1878 = distinct !DILexicalBlock(scope: !1867, file: !3, line: 198, column: 7)
!1879 = !DILocation(line: 198, column: 11, scope: !1878)
!1880 = !DILocation(line: 198, column: 25, scope: !1878)
!1881 = !DILocation(line: 198, column: 29, scope: !1878)
!1882 = !DILocation(line: 198, column: 32, scope: !1878)
!1883 = !DILocation(line: 198, column: 7, scope: !1867)
!1884 = !DILocation(line: 198, column: 59, scope: !1878)
!1885 = !DILocation(line: 198, column: 52, scope: !1878)
!1886 = !DILocation(line: 199, column: 19, scope: !1887)
!1887 = distinct !DILexicalBlock(scope: !1867, file: !3, line: 199, column: 7)
!1888 = !DILocation(line: 199, column: 23, scope: !1887)
!1889 = !DILocation(line: 199, column: 8, scope: !1887)
!1890 = !DILocation(line: 199, column: 26, scope: !1887)
!1891 = !DILocation(line: 199, column: 29, scope: !1887)
!1892 = !DILocation(line: 199, column: 31, scope: !1887)
!1893 = !DILocation(line: 199, column: 35, scope: !1887)
!1894 = !DILocation(line: 199, column: 38, scope: !1887)
!1895 = !DILocation(line: 199, column: 7, scope: !1867)
!1896 = !DILocation(line: 200, column: 18, scope: !1887)
!1897 = !DILocation(line: 200, column: 20, scope: !1887)
!1898 = !DILocation(line: 200, column: 24, scope: !1887)
!1899 = !DILocation(line: 200, column: 12, scope: !1887)
!1900 = !DILocation(line: 200, column: 5, scope: !1887)
!1901 = !DILocation(line: 201, column: 3, scope: !1867)
!1902 = !DILocalVariable(name: "index", scope: !1867, file: !3, line: 201, type: !104)
!1903 = !DILocation(line: 201, column: 18, scope: !1867)
!1904 = !DILocation(line: 201, column: 38, scope: !1867)
!1905 = !DILocation(line: 201, column: 42, scope: !1867)
!1906 = !DILocation(line: 201, column: 26, scope: !1867)
!1907 = !DILocation(line: 202, column: 7, scope: !1908)
!1908 = distinct !DILexicalBlock(scope: !1867, file: !3, line: 202, column: 7)
!1909 = !DILocation(line: 202, column: 13, scope: !1908)
!1910 = !DILocation(line: 202, column: 7, scope: !1867)
!1911 = !DILocation(line: 202, column: 44, scope: !1908)
!1912 = !DILocation(line: 202, column: 46, scope: !1908)
!1913 = !DILocation(line: 202, column: 50, scope: !1908)
!1914 = !DILocation(line: 202, column: 38, scope: !1908)
!1915 = !DILocation(line: 202, column: 31, scope: !1908)
!1916 = !DILocation(line: 203, column: 15, scope: !1867)
!1917 = !DILocation(line: 203, column: 18, scope: !1867)
!1918 = !DILocation(line: 203, column: 25, scope: !1867)
!1919 = !DILocation(line: 203, column: 32, scope: !1867)
!1920 = !DILocation(line: 203, column: 40, scope: !1867)
!1921 = !DILocation(line: 203, column: 43, scope: !1867)
!1922 = !DILocation(line: 203, column: 46, scope: !1867)
!1923 = !DILocation(line: 203, column: 53, scope: !1867)
!1924 = !DILocation(line: 203, column: 3, scope: !1867)
!1925 = !DILocation(line: 204, column: 5, scope: !1867)
!1926 = !DILocation(line: 204, column: 8, scope: !1867)
!1927 = !DILocation(line: 204, column: 3, scope: !1867)
!1928 = !DILocation(line: 205, column: 7, scope: !1929)
!1929 = distinct !DILexicalBlock(scope: !1867, file: !3, line: 205, column: 7)
!1930 = !DILocation(line: 205, column: 9, scope: !1929)
!1931 = !DILocation(line: 205, column: 13, scope: !1929)
!1932 = !DILocation(line: 205, column: 16, scope: !1929)
!1933 = !DILocation(line: 205, column: 7, scope: !1867)
!1934 = !DILocation(line: 206, column: 38, scope: !1935)
!1935 = distinct !DILexicalBlock(scope: !1929, file: !3, line: 206, column: 23)
!1936 = !DILocalVariable(name: "__range3", scope: !1935, type: !1937, flags: DIFlagArtificial)
!1937 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1079, size: 64)
!1938 = !DILocation(line: 0, scope: !1935)
!1939 = !DILocation(line: 206, column: 41, scope: !1935)
!1940 = !DILocation(line: 206, column: 48, scope: !1935)
!1941 = !DILocation(line: 206, column: 36, scope: !1935)
!1942 = !DILocalVariable(name: "__begin3", scope: !1935, type: !1943, flags: DIFlagArtificial)
!1943 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !237, size: 64)
!1944 = !DILocalVariable(name: "__end3", scope: !1935, type: !1943, flags: DIFlagArtificial)
!1945 = !DILocation(line: 206, column: 28, scope: !1946)
!1946 = distinct !DILexicalBlock(scope: !1935, file: !3, line: 206, column: 23)
!1947 = !DILocalVariable(name: "v", scope: !1946, file: !3, line: 206, type: !1948)
!1948 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !237, size: 64)
!1949 = !DILocation(line: 206, column: 34, scope: !1946)
!1950 = !DILocation(line: 206, column: 36, scope: !1946)
!1951 = !DILocation(line: 206, column: 60, scope: !1946)
!1952 = !DILocation(line: 206, column: 62, scope: !1946)
!1953 = !DILocation(line: 206, column: 64, scope: !1935)
!1954 = !DILocation(line: 206, column: 23, scope: !1935)
!1955 = distinct !{!1955, !1954, !1953, !1956}
!1956 = !{!"llvm.loop.name", !"VITIS_LOOP_206_1"}
!1957 = !DILocation(line: 207, column: 7, scope: !1958)
!1958 = distinct !DILexicalBlock(scope: !1867, file: !3, line: 207, column: 7)
!1959 = !DILocation(line: 207, column: 9, scope: !1958)
!1960 = !DILocation(line: 207, column: 13, scope: !1958)
!1961 = !DILocation(line: 207, column: 16, scope: !1958)
!1962 = !DILocation(line: 207, column: 7, scope: !1867)
!1963 = !DILocation(line: 208, column: 41, scope: !1964)
!1964 = distinct !DILexicalBlock(scope: !1958, file: !3, line: 208, column: 23)
!1965 = !DILocalVariable(name: "__range3", scope: !1964, type: !1966, flags: DIFlagArtificial)
!1966 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1073, size: 64)
!1967 = !DILocation(line: 0, scope: !1964)
!1968 = !DILocation(line: 208, column: 44, scope: !1964)
!1969 = !DILocation(line: 208, column: 51, scope: !1964)
!1970 = !DILocation(line: 208, column: 39, scope: !1964)
!1971 = !DILocalVariable(name: "__begin3", scope: !1964, type: !1972, flags: DIFlagArtificial)
!1972 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1973, size: 64)
!1973 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 2048, elements: !1974)
!1974 = !{!1023, !1064}
!1975 = !DILocalVariable(name: "__end3", scope: !1964, type: !1972, flags: DIFlagArtificial)
!1976 = !DILocation(line: 208, column: 28, scope: !1977)
!1977 = distinct !DILexicalBlock(scope: !1964, file: !3, line: 208, column: 23)
!1978 = !DILocalVariable(name: "head", scope: !1977, file: !3, line: 208, type: !1979)
!1979 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1973, size: 64)
!1980 = !DILocation(line: 208, column: 34, scope: !1977)
!1981 = !DILocation(line: 208, column: 39, scope: !1977)
!1982 = !DILocation(line: 209, column: 44, scope: !1983)
!1983 = distinct !DILexicalBlock(scope: !1977, file: !3, line: 209, column: 25)
!1984 = !DILocalVariable(name: "__range4", scope: !1983, type: !1979, flags: DIFlagArtificial)
!1985 = !DILocation(line: 0, scope: !1983)
!1986 = !DILocation(line: 209, column: 42, scope: !1983)
!1987 = !DILocalVariable(name: "__begin4", scope: !1983, type: !1988, flags: DIFlagArtificial)
!1988 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1989, size: 64)
!1989 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 1024, elements: !1063)
!1990 = !DILocalVariable(name: "__end4", scope: !1983, type: !1988, flags: DIFlagArtificial)
!1991 = !DILocation(line: 209, column: 30, scope: !1992)
!1992 = distinct !DILexicalBlock(scope: !1983, file: !3, line: 209, column: 25)
!1993 = !DILocalVariable(name: "batch", scope: !1992, file: !3, line: 209, type: !1994)
!1994 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1989, size: 64)
!1995 = !DILocation(line: 209, column: 36, scope: !1992)
!1996 = !DILocation(line: 209, column: 42, scope: !1992)
!1997 = !DILocation(line: 210, column: 49, scope: !1998)
!1998 = distinct !DILexicalBlock(scope: !1992, file: !3, line: 210, column: 27)
!1999 = !DILocalVariable(name: "__range5", scope: !1998, type: !1994, flags: DIFlagArtificial)
!2000 = !DILocation(line: 0, scope: !1998)
!2001 = !DILocation(line: 210, column: 47, scope: !1998)
!2002 = !DILocalVariable(name: "__begin5", scope: !1998, type: !2003, flags: DIFlagArtificial)
!2003 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !93, size: 64)
!2004 = !DILocalVariable(name: "__end5", scope: !1998, type: !2003, flags: DIFlagArtificial)
!2005 = !DILocation(line: 210, column: 32, scope: !2006)
!2006 = distinct !DILexicalBlock(scope: !1998, file: !3, line: 210, column: 27)
!2007 = !DILocalVariable(name: "word", scope: !2006, file: !3, line: 210, type: !2008)
!2008 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !93, size: 64)
!2009 = !DILocation(line: 210, column: 42, scope: !2006)
!2010 = !DILocation(line: 210, column: 47, scope: !2006)
!2011 = !DILocation(line: 210, column: 56, scope: !2006)
!2012 = !DILocation(line: 210, column: 61, scope: !2006)
!2013 = !DILocation(line: 210, column: 63, scope: !1998)
!2014 = !DILocation(line: 210, column: 27, scope: !1998)
!2015 = distinct !{!2015, !2014, !2013, !2016}
!2016 = !{!"llvm.loop.name", !"VITIS_LOOP_210_4"}
!2017 = !DILocation(line: 210, column: 63, scope: !1983)
!2018 = !DILocation(line: 209, column: 25, scope: !1983)
!2019 = distinct !{!2019, !2018, !2017, !2020}
!2020 = !{!"llvm.loop.name", !"VITIS_LOOP_209_3"}
!2021 = !DILocation(line: 210, column: 63, scope: !1964)
!2022 = !DILocation(line: 208, column: 23, scope: !1964)
!2023 = distinct !{!2023, !2022, !2021, !2024}
!2024 = !{!"llvm.loop.name", !"VITIS_LOOP_208_2"}
!2025 = !DILocation(line: 211, column: 10, scope: !1867)
!2026 = !DILocation(line: 211, column: 3, scope: !1867)
!2027 = !DILocation(line: 212, column: 1, scope: !1867)
!2028 = distinct !DISubprogram(name: "protocol", linkageName: "_ZN4laya4full12_GLOBAL__N_18protocolEt", scope: !4, file: !3, line: 8, type: !2029, scopeLine: 8, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2029 = !DISubroutineType(types: !2030)
!2030 = !{!1202, !9}
!2031 = !DILocalVariable(name: "reason", arg: 1, scope: !2028, file: !3, line: 8, type: !9)
!2032 = !DILocation(line: 8, column: 25, scope: !2028)
!2033 = !DILocation(line: 9, column: 10, scope: !2028)
!2034 = !DILocation(line: 9, column: 44, scope: !2028)
!2035 = !DILocation(line: 9, column: 31, scope: !2028)
!2036 = !DILocation(line: 9, column: 3, scope: !2028)
!2037 = distinct !DISubprogram(name: "legal_spec", linkageName: "_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE", scope: !4, file: !3, line: 46, type: !2038, scopeLine: 46, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2038 = !DISubroutineType(types: !2039)
!2039 = !{!237, !2040, !1871}
!2040 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2041, size: 64)
!2041 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !999)
!2042 = !DILocalVariable(name: "rt", arg: 1, scope: !2037, file: !3, line: 46, type: !2040)
!2043 = !DILocation(line: 46, column: 36, scope: !2037)
!2044 = !DILocalVariable(name: "s", arg: 2, scope: !2037, file: !3, line: 46, type: !1871)
!2045 = !DILocation(line: 46, column: 61, scope: !2037)
!2046 = !DILocation(line: 47, column: 8, scope: !2047)
!2047 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 47, column: 7)
!2048 = !DILocation(line: 47, column: 18, scope: !2047)
!2049 = !DILocation(line: 47, column: 20, scope: !2047)
!2050 = !DILocation(line: 47, column: 25, scope: !2047)
!2051 = !DILocation(line: 47, column: 27, scope: !2047)
!2052 = !DILocation(line: 47, column: 35, scope: !2047)
!2053 = !DILocation(line: 47, column: 38, scope: !2047)
!2054 = !DILocation(line: 47, column: 40, scope: !2047)
!2055 = !DILocation(line: 47, column: 44, scope: !2047)
!2056 = !DILocation(line: 47, column: 47, scope: !2047)
!2057 = !DILocation(line: 47, column: 63, scope: !2047)
!2058 = !DILocation(line: 48, column: 31, scope: !2047)
!2059 = !DILocation(line: 48, column: 34, scope: !2047)
!2060 = !DILocation(line: 48, column: 41, scope: !2047)
!2061 = !DILocation(line: 48, column: 8, scope: !2047)
!2062 = !DILocation(line: 48, column: 51, scope: !2047)
!2063 = !DILocation(line: 49, column: 7, scope: !2047)
!2064 = !DILocation(line: 49, column: 9, scope: !2047)
!2065 = !DILocation(line: 49, column: 15, scope: !2047)
!2066 = !DILocation(line: 49, column: 19, scope: !2047)
!2067 = !DILocation(line: 49, column: 22, scope: !2047)
!2068 = !DILocation(line: 49, column: 24, scope: !2047)
!2069 = !DILocation(line: 49, column: 29, scope: !2047)
!2070 = !DILocation(line: 49, column: 34, scope: !2047)
!2071 = !DILocation(line: 49, column: 37, scope: !2047)
!2072 = !DILocation(line: 49, column: 39, scope: !2047)
!2073 = !DILocation(line: 49, column: 45, scope: !2047)
!2074 = !DILocation(line: 49, column: 50, scope: !2047)
!2075 = !DILocation(line: 49, column: 53, scope: !2047)
!2076 = !DILocation(line: 49, column: 55, scope: !2047)
!2077 = !DILocation(line: 49, column: 61, scope: !2047)
!2078 = !DILocation(line: 47, column: 7, scope: !2047)
!2079 = !DILocation(line: 47, column: 7, scope: !2037)
!2080 = !DILocation(line: 50, column: 5, scope: !2047)
!2081 = !DILocation(line: 51, column: 3, scope: !2037)
!2082 = !DILocalVariable(name: "id", scope: !2037, file: !3, line: 51, type: !1744)
!2083 = !DILocation(line: 51, column: 17, scope: !2037)
!2084 = !DILocation(line: 51, column: 30, scope: !2037)
!2085 = !DILocation(line: 51, column: 32, scope: !2037)
!2086 = !DILocation(line: 51, column: 36, scope: !2037)
!2087 = !DILocation(line: 52, column: 7, scope: !2088)
!2088 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 52, column: 7)
!2089 = !DILocation(line: 52, column: 10, scope: !2088)
!2090 = !DILocation(line: 52, column: 37, scope: !2088)
!2091 = !DILocation(line: 53, column: 7, scope: !2088)
!2092 = !DILocation(line: 53, column: 10, scope: !2088)
!2093 = !DILocation(line: 53, column: 40, scope: !2088)
!2094 = !DILocation(line: 53, column: 43, scope: !2088)
!2095 = !DILocation(line: 53, column: 45, scope: !2088)
!2096 = !DILocation(line: 53, column: 49, scope: !2088)
!2097 = !DILocation(line: 53, column: 54, scope: !2088)
!2098 = !DILocation(line: 52, column: 7, scope: !2037)
!2099 = !DILocation(line: 54, column: 5, scope: !2088)
!2100 = !DILocation(line: 55, column: 3, scope: !2037)
!2101 = !DILocalVariable(name: "fixed", scope: !2037, file: !3, line: 55, type: !2102)
!2102 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !9)
!2103 = !DILocation(line: 55, column: 18, scope: !2037)
!2104 = !DILocation(line: 55, column: 38, scope: !2037)
!2105 = !DILocation(line: 55, column: 40, scope: !2037)
!2106 = !DILocation(line: 55, column: 44, scope: !2037)
!2107 = !DILocation(line: 55, column: 48, scope: !2037)
!2108 = !DILocation(line: 55, column: 50, scope: !2037)
!2109 = !DILocation(line: 55, column: 26, scope: !2037)
!2110 = !DILocation(line: 56, column: 7, scope: !2111)
!2111 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 56, column: 7)
!2112 = !DILocation(line: 56, column: 13, scope: !2111)
!2113 = !DILocation(line: 56, column: 16, scope: !2111)
!2114 = !DILocation(line: 56, column: 18, scope: !2111)
!2115 = !DILocation(line: 56, column: 27, scope: !2111)
!2116 = !DILocation(line: 56, column: 24, scope: !2111)
!2117 = !DILocation(line: 56, column: 7, scope: !2037)
!2118 = !DILocation(line: 56, column: 34, scope: !2111)
!2119 = !DILocation(line: 57, column: 7, scope: !2120)
!2120 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 57, column: 7)
!2121 = !DILocation(line: 57, column: 9, scope: !2120)
!2122 = !DILocation(line: 57, column: 13, scope: !2120)
!2123 = !DILocation(line: 57, column: 16, scope: !2120)
!2124 = !DILocation(line: 57, column: 38, scope: !2120)
!2125 = !DILocation(line: 57, column: 41, scope: !2120)
!2126 = !DILocation(line: 57, column: 43, scope: !2120)
!2127 = !DILocation(line: 57, column: 52, scope: !2120)
!2128 = !DILocation(line: 57, column: 55, scope: !2120)
!2129 = !DILocation(line: 57, column: 62, scope: !2120)
!2130 = !DILocation(line: 57, column: 71, scope: !2120)
!2131 = !DILocation(line: 57, column: 49, scope: !2120)
!2132 = !DILocation(line: 57, column: 7, scope: !2037)
!2133 = !DILocation(line: 58, column: 5, scope: !2120)
!2134 = !DILocation(line: 59, column: 7, scope: !2135)
!2135 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 59, column: 7)
!2136 = !DILocation(line: 59, column: 9, scope: !2135)
!2137 = !DILocation(line: 59, column: 13, scope: !2135)
!2138 = !DILocation(line: 59, column: 16, scope: !2135)
!2139 = !DILocation(line: 59, column: 37, scope: !2135)
!2140 = !DILocation(line: 60, column: 7, scope: !2135)
!2141 = !DILocation(line: 60, column: 9, scope: !2135)
!2142 = !DILocation(line: 60, column: 16, scope: !2135)
!2143 = !DILocation(line: 60, column: 45, scope: !2135)
!2144 = !DILocation(line: 61, column: 9, scope: !2135)
!2145 = !DILocation(line: 61, column: 11, scope: !2135)
!2146 = !DILocation(line: 61, column: 21, scope: !2135)
!2147 = !DILocation(line: 61, column: 41, scope: !2135)
!2148 = !DILocation(line: 61, column: 44, scope: !2135)
!2149 = !DILocation(line: 61, column: 46, scope: !2135)
!2150 = !DILocation(line: 61, column: 52, scope: !2135)
!2151 = !DILocation(line: 61, column: 57, scope: !2135)
!2152 = !DILocation(line: 62, column: 9, scope: !2135)
!2153 = !DILocation(line: 62, column: 11, scope: !2135)
!2154 = !DILocation(line: 62, column: 16, scope: !2135)
!2155 = !DILocation(line: 62, column: 21, scope: !2135)
!2156 = !DILocation(line: 62, column: 24, scope: !2135)
!2157 = !DILocation(line: 62, column: 26, scope: !2135)
!2158 = !DILocation(line: 62, column: 31, scope: !2135)
!2159 = !DILocation(line: 59, column: 7, scope: !2037)
!2160 = !DILocation(line: 62, column: 39, scope: !2135)
!2161 = !DILocation(line: 63, column: 3, scope: !2037)
!2162 = !DILocalVariable(name: "extent", scope: !2037, file: !3, line: 63, type: !2102)
!2163 = !DILocation(line: 63, column: 18, scope: !2037)
!2164 = !DILocation(line: 63, column: 27, scope: !2037)
!2165 = !DILocation(line: 63, column: 29, scope: !2037)
!2166 = !DILocation(line: 63, column: 39, scope: !2037)
!2167 = !DILocation(line: 63, column: 60, scope: !2037)
!2168 = !DILocation(line: 63, column: 63, scope: !2037)
!2169 = !DILocation(line: 63, column: 70, scope: !2037)
!2170 = !DILocation(line: 63, column: 79, scope: !2037)
!2171 = !DILocation(line: 64, column: 27, scope: !2037)
!2172 = !DILocation(line: 64, column: 29, scope: !2037)
!2173 = !DILocation(line: 64, column: 39, scope: !2037)
!2174 = !DILocation(line: 65, column: 27, scope: !2037)
!2175 = !DILocation(line: 65, column: 29, scope: !2037)
!2176 = !DILocation(line: 65, column: 39, scope: !2037)
!2177 = !DILocation(line: 66, column: 8, scope: !2178)
!2178 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 66, column: 7)
!2179 = !DILocation(line: 66, column: 15, scope: !2178)
!2180 = !DILocation(line: 66, column: 27, scope: !2178)
!2181 = !DILocation(line: 66, column: 29, scope: !2178)
!2182 = !DILocation(line: 66, column: 37, scope: !2178)
!2183 = !DILocation(line: 66, column: 39, scope: !2178)
!2184 = !DILocation(line: 66, column: 35, scope: !2178)
!2185 = !DILocation(line: 66, column: 46, scope: !2178)
!2186 = !DILocation(line: 66, column: 44, scope: !2178)
!2187 = !DILocation(line: 66, column: 53, scope: !2178)
!2188 = !DILocation(line: 67, column: 8, scope: !2178)
!2189 = !DILocation(line: 67, column: 10, scope: !2178)
!2190 = !DILocation(line: 67, column: 16, scope: !2178)
!2191 = !DILocation(line: 67, column: 23, scope: !2178)
!2192 = !DILocation(line: 67, column: 26, scope: !2178)
!2193 = !DILocation(line: 67, column: 28, scope: !2178)
!2194 = !DILocation(line: 67, column: 37, scope: !2178)
!2195 = !DILocation(line: 67, column: 40, scope: !2178)
!2196 = !DILocation(line: 67, column: 47, scope: !2178)
!2197 = !DILocation(line: 67, column: 56, scope: !2178)
!2198 = !DILocation(line: 67, column: 34, scope: !2178)
!2199 = !DILocation(line: 66, column: 7, scope: !2037)
!2200 = !DILocation(line: 67, column: 60, scope: !2178)
!2201 = !DILocation(line: 68, column: 7, scope: !2202)
!2202 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 68, column: 7)
!2203 = !DILocation(line: 68, column: 9, scope: !2202)
!2204 = !DILocation(line: 68, column: 13, scope: !2202)
!2205 = !DILocation(line: 68, column: 16, scope: !2202)
!2206 = !DILocation(line: 68, column: 7, scope: !2037)
!2207 = !DILocation(line: 69, column: 12, scope: !2202)
!2208 = !DILocation(line: 69, column: 14, scope: !2202)
!2209 = !DILocation(line: 69, column: 20, scope: !2202)
!2210 = !DILocation(line: 69, column: 25, scope: !2202)
!2211 = !DILocation(line: 69, column: 28, scope: !2202)
!2212 = !DILocation(line: 69, column: 30, scope: !2202)
!2213 = !DILocation(line: 69, column: 40, scope: !2202)
!2214 = !DILocation(line: 69, column: 59, scope: !2202)
!2215 = !DILocation(line: 70, column: 12, scope: !2202)
!2216 = !DILocation(line: 70, column: 14, scope: !2202)
!2217 = !DILocation(line: 70, column: 19, scope: !2202)
!2218 = !DILocation(line: 70, column: 24, scope: !2202)
!2219 = !DILocation(line: 70, column: 27, scope: !2202)
!2220 = !DILocation(line: 70, column: 29, scope: !2202)
!2221 = !DILocation(line: 70, column: 34, scope: !2202)
!2222 = !DILocation(line: 0, scope: !2202)
!2223 = !DILocation(line: 69, column: 5, scope: !2202)
!2224 = !DILocation(line: 71, column: 7, scope: !2225)
!2225 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 71, column: 7)
!2226 = !DILocation(line: 71, column: 9, scope: !2225)
!2227 = !DILocation(line: 71, column: 13, scope: !2225)
!2228 = !DILocation(line: 71, column: 16, scope: !2225)
!2229 = !DILocation(line: 71, column: 7, scope: !2037)
!2230 = !DILocation(line: 72, column: 12, scope: !2225)
!2231 = !DILocation(line: 72, column: 14, scope: !2225)
!2232 = !DILocation(line: 72, column: 20, scope: !2225)
!2233 = !DILocation(line: 72, column: 27, scope: !2225)
!2234 = !DILocation(line: 72, column: 30, scope: !2225)
!2235 = !DILocation(line: 72, column: 32, scope: !2225)
!2236 = !DILocation(line: 72, column: 42, scope: !2225)
!2237 = !DILocation(line: 72, column: 61, scope: !2225)
!2238 = !DILocation(line: 73, column: 12, scope: !2225)
!2239 = !DILocation(line: 73, column: 14, scope: !2225)
!2240 = !DILocation(line: 73, column: 19, scope: !2225)
!2241 = !DILocation(line: 73, column: 24, scope: !2225)
!2242 = !DILocation(line: 73, column: 27, scope: !2225)
!2243 = !DILocation(line: 73, column: 29, scope: !2225)
!2244 = !DILocation(line: 73, column: 37, scope: !2225)
!2245 = !DILocation(line: 73, column: 40, scope: !2225)
!2246 = !DILocation(line: 73, column: 47, scope: !2225)
!2247 = !DILocation(line: 73, column: 56, scope: !2225)
!2248 = !DILocation(line: 73, column: 34, scope: !2225)
!2249 = !DILocation(line: 0, scope: !2225)
!2250 = !DILocation(line: 72, column: 5, scope: !2225)
!2251 = !DILocation(line: 74, column: 7, scope: !2252)
!2252 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 74, column: 7)
!2253 = !DILocation(line: 74, column: 9, scope: !2252)
!2254 = !DILocation(line: 74, column: 13, scope: !2252)
!2255 = !DILocation(line: 74, column: 16, scope: !2252)
!2256 = !DILocation(line: 74, column: 34, scope: !2252)
!2257 = !DILocation(line: 74, column: 37, scope: !2252)
!2258 = !DILocation(line: 74, column: 39, scope: !2252)
!2259 = !DILocation(line: 74, column: 43, scope: !2252)
!2260 = !DILocation(line: 74, column: 46, scope: !2252)
!2261 = !DILocation(line: 74, column: 66, scope: !2252)
!2262 = !DILocation(line: 75, column: 7, scope: !2252)
!2263 = !DILocation(line: 75, column: 9, scope: !2252)
!2264 = !DILocation(line: 75, column: 13, scope: !2252)
!2265 = !DILocation(line: 75, column: 16, scope: !2252)
!2266 = !DILocation(line: 74, column: 7, scope: !2037)
!2267 = !DILocation(line: 76, column: 12, scope: !2252)
!2268 = !DILocation(line: 76, column: 14, scope: !2252)
!2269 = !DILocation(line: 76, column: 20, scope: !2252)
!2270 = !DILocation(line: 76, column: 25, scope: !2252)
!2271 = !DILocation(line: 76, column: 28, scope: !2252)
!2272 = !DILocation(line: 76, column: 30, scope: !2252)
!2273 = !DILocation(line: 76, column: 40, scope: !2252)
!2274 = !DILocation(line: 76, column: 59, scope: !2252)
!2275 = !DILocation(line: 77, column: 12, scope: !2252)
!2276 = !DILocation(line: 77, column: 14, scope: !2252)
!2277 = !DILocation(line: 77, column: 19, scope: !2252)
!2278 = !DILocation(line: 77, column: 24, scope: !2252)
!2279 = !DILocation(line: 77, column: 27, scope: !2252)
!2280 = !DILocation(line: 77, column: 29, scope: !2252)
!2281 = !DILocation(line: 77, column: 34, scope: !2252)
!2282 = !DILocation(line: 0, scope: !2252)
!2283 = !DILocation(line: 76, column: 5, scope: !2252)
!2284 = !DILocation(line: 78, column: 7, scope: !2285)
!2285 = distinct !DILexicalBlock(scope: !2037, file: !3, line: 78, column: 7)
!2286 = !DILocation(line: 78, column: 9, scope: !2285)
!2287 = !DILocation(line: 78, column: 19, scope: !2285)
!2288 = !DILocation(line: 78, column: 7, scope: !2037)
!2289 = !DILocation(line: 79, column: 12, scope: !2285)
!2290 = !DILocation(line: 79, column: 14, scope: !2285)
!2291 = !DILocation(line: 79, column: 19, scope: !2285)
!2292 = !DILocation(line: 79, column: 24, scope: !2285)
!2293 = !DILocation(line: 79, column: 27, scope: !2285)
!2294 = !DILocation(line: 79, column: 29, scope: !2285)
!2295 = !DILocation(line: 79, column: 34, scope: !2285)
!2296 = !DILocation(line: 0, scope: !2285)
!2297 = !DILocation(line: 79, column: 5, scope: !2285)
!2298 = !DILocation(line: 80, column: 3, scope: !2037)
!2299 = !DILocation(line: 81, column: 1, scope: !2037)
!2300 = distinct !DISubprogram(name: "error", linkageName: "_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt", scope: !4, file: !3, line: 5, type: !2301, scopeLine: 5, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2301 = !DISubroutineType(types: !2302)
!2302 = !{!1202, !14, !9}
!2303 = !DILocalVariable(name: "id", arg: 1, scope: !2300, file: !3, line: 5, type: !14)
!2304 = !DILocation(line: 5, column: 20, scope: !2300)
!2305 = !DILocalVariable(name: "reason", arg: 2, scope: !2300, file: !3, line: 5, type: !9)
!2306 = !DILocation(line: 5, column: 33, scope: !2300)
!2307 = !DILocation(line: 6, column: 10, scope: !2300)
!2308 = !DILocation(line: 6, column: 47, scope: !2300)
!2309 = !DILocation(line: 6, column: 52, scope: !2300)
!2310 = !DILocation(line: 6, column: 29, scope: !2300)
!2311 = !DILocation(line: 6, column: 3, scope: !2300)
!2312 = distinct !DISubprogram(name: "claim_index", linkageName: "_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE", scope: !4, file: !3, line: 131, type: !2313, scopeLine: 131, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2313 = !DISubroutineType(types: !2314)
!2314 = !{!95, !2040, !1871}
!2315 = !DILocalVariable(name: "rt", arg: 1, scope: !2312, file: !3, line: 131, type: !2040)
!2316 = !DILocation(line: 131, column: 41, scope: !2312)
!2317 = !DILocalVariable(name: "s", arg: 2, scope: !2312, file: !3, line: 131, type: !1871)
!2318 = !DILocation(line: 131, column: 66, scope: !2312)
!2319 = !DILocation(line: 132, column: 3, scope: !2312)
!2320 = !DILocalVariable(name: "index", scope: !2312, file: !3, line: 132, type: !95)
!2321 = !DILocation(line: 132, column: 12, scope: !2312)
!2322 = !DILocation(line: 132, column: 31, scope: !2312)
!2323 = !DILocation(line: 132, column: 35, scope: !2312)
!2324 = !DILocation(line: 132, column: 37, scope: !2312)
!2325 = !DILocation(line: 132, column: 42, scope: !2312)
!2326 = !DILocation(line: 132, column: 44, scope: !2312)
!2327 = !DILocation(line: 132, column: 20, scope: !2312)
!2328 = !DILocation(line: 133, column: 7, scope: !2329)
!2329 = distinct !DILexicalBlock(scope: !2312, file: !3, line: 133, column: 7)
!2330 = !DILocation(line: 133, column: 13, scope: !2329)
!2331 = !DILocation(line: 133, column: 7, scope: !2312)
!2332 = !DILocation(line: 133, column: 51, scope: !2329)
!2333 = !DILocation(line: 133, column: 39, scope: !2329)
!2334 = !DILocation(line: 133, column: 37, scope: !2329)
!2335 = !DILocation(line: 133, column: 31, scope: !2329)
!2336 = !DILocation(line: 134, column: 7, scope: !2337)
!2337 = distinct !DILexicalBlock(scope: !2312, file: !3, line: 134, column: 7)
!2338 = !DILocation(line: 134, column: 13, scope: !2337)
!2339 = !DILocation(line: 134, column: 7, scope: !2312)
!2340 = !DILocation(line: 134, column: 31, scope: !2337)
!2341 = !DILocation(line: 135, column: 3, scope: !2312)
!2342 = !DILocalVariable(name: "r", scope: !2312, file: !3, line: 135, type: !2343)
!2343 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2344, size: 64)
!2344 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1040)
!2345 = !DILocation(line: 135, column: 26, scope: !2312)
!2346 = !DILocation(line: 135, column: 30, scope: !2312)
!2347 = !DILocation(line: 135, column: 33, scope: !2312)
!2348 = !DILocation(line: 135, column: 40, scope: !2312)
!2349 = !DILocation(line: 135, column: 47, scope: !2312)
!2350 = !DILocation(line: 136, column: 7, scope: !2351)
!2351 = distinct !DILexicalBlock(scope: !2312, file: !3, line: 136, column: 7)
!2352 = !DILocation(line: 136, column: 9, scope: !2351)
!2353 = !DILocation(line: 136, column: 15, scope: !2351)
!2354 = !DILocation(line: 136, column: 18, scope: !2351)
!2355 = !DILocation(line: 136, column: 20, scope: !2351)
!2356 = !DILocation(line: 136, column: 28, scope: !2351)
!2357 = !DILocation(line: 137, column: 8, scope: !2351)
!2358 = !DILocation(line: 137, column: 10, scope: !2351)
!2359 = !DILocation(line: 137, column: 16, scope: !2351)
!2360 = !DILocation(line: 137, column: 36, scope: !2351)
!2361 = !DILocation(line: 137, column: 39, scope: !2351)
!2362 = !DILocation(line: 137, column: 41, scope: !2351)
!2363 = !DILocation(line: 137, column: 47, scope: !2351)
!2364 = !DILocation(line: 137, column: 71, scope: !2351)
!2365 = !DILocation(line: 138, column: 7, scope: !2351)
!2366 = !DILocation(line: 138, column: 9, scope: !2351)
!2367 = !DILocation(line: 138, column: 27, scope: !2351)
!2368 = !DILocation(line: 138, column: 40, scope: !2351)
!2369 = !DILocation(line: 139, column: 7, scope: !2351)
!2370 = !DILocation(line: 139, column: 9, scope: !2351)
!2371 = !DILocation(line: 139, column: 13, scope: !2351)
!2372 = !DILocation(line: 139, column: 22, scope: !2351)
!2373 = !DILocation(line: 139, column: 24, scope: !2351)
!2374 = !DILocation(line: 139, column: 42, scope: !2351)
!2375 = !DILocation(line: 139, column: 19, scope: !2351)
!2376 = !DILocation(line: 136, column: 7, scope: !2312)
!2377 = !DILocation(line: 139, column: 47, scope: !2351)
!2378 = !DILocation(line: 140, column: 10, scope: !2312)
!2379 = !DILocation(line: 140, column: 3, scope: !2312)
!2380 = !DILocation(line: 141, column: 1, scope: !2312)
!2381 = distinct !DISubprogram(name: "fill_record", linkageName: "_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE", scope: !4, file: !3, line: 142, type: !2382, scopeLine: 143, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2382 = !DISubroutineType(types: !2383)
!2383 = !{null, !2384, !1871, !1678}
!2384 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1040, size: 64)
!2385 = !DILocalVariable(name: "r", arg: 1, scope: !2381, file: !3, line: 142, type: !2384)
!2386 = !DILocation(line: 142, column: 35, scope: !2381)
!2387 = !DILocalVariable(name: "s", arg: 2, scope: !2381, file: !3, line: 142, type: !1871)
!2388 = !DILocation(line: 142, column: 59, scope: !2381)
!2389 = !DILocalVariable(name: "identity", arg: 3, scope: !2381, file: !3, line: 143, type: !1678)
!2390 = !DILocation(line: 143, column: 41, scope: !2381)
!2391 = !DILocation(line: 144, column: 16, scope: !2381)
!2392 = !DILocation(line: 144, column: 3, scope: !2381)
!2393 = !DILocation(line: 144, column: 5, scope: !2381)
!2394 = !DILocation(line: 144, column: 14, scope: !2381)
!2395 = !DILocation(line: 145, column: 11, scope: !2381)
!2396 = !DILocation(line: 145, column: 13, scope: !2381)
!2397 = !DILocation(line: 145, column: 3, scope: !2381)
!2398 = !DILocation(line: 145, column: 5, scope: !2381)
!2399 = !DILocation(line: 145, column: 9, scope: !2381)
!2400 = !DILocation(line: 146, column: 21, scope: !2381)
!2401 = !DILocation(line: 146, column: 3, scope: !2381)
!2402 = !DILocation(line: 146, column: 5, scope: !2381)
!2403 = !DILocation(line: 146, column: 19, scope: !2381)
!2404 = !DILocation(line: 147, column: 25, scope: !2381)
!2405 = !DILocation(line: 147, column: 27, scope: !2381)
!2406 = !DILocation(line: 147, column: 31, scope: !2381)
!2407 = !DILocation(line: 147, column: 3, scope: !2381)
!2408 = !DILocation(line: 147, column: 5, scope: !2381)
!2409 = !DILocation(line: 147, column: 23, scope: !2381)
!2410 = !DILocation(line: 148, column: 14, scope: !2381)
!2411 = !DILocation(line: 148, column: 16, scope: !2381)
!2412 = !DILocation(line: 148, column: 3, scope: !2381)
!2413 = !DILocation(line: 148, column: 5, scope: !2381)
!2414 = !DILocation(line: 148, column: 12, scope: !2381)
!2415 = !DILocation(line: 148, column: 34, scope: !2381)
!2416 = !DILocation(line: 148, column: 36, scope: !2381)
!2417 = !DILocation(line: 148, column: 24, scope: !2381)
!2418 = !DILocation(line: 148, column: 26, scope: !2381)
!2419 = !DILocation(line: 148, column: 32, scope: !2381)
!2420 = !DILocation(line: 148, column: 53, scope: !2381)
!2421 = !DILocation(line: 148, column: 55, scope: !2381)
!2422 = !DILocation(line: 148, column: 43, scope: !2381)
!2423 = !DILocation(line: 148, column: 45, scope: !2381)
!2424 = !DILocation(line: 148, column: 51, scope: !2381)
!2425 = !DILocation(line: 149, column: 13, scope: !2381)
!2426 = !DILocation(line: 149, column: 15, scope: !2381)
!2427 = !DILocation(line: 149, column: 3, scope: !2381)
!2428 = !DILocation(line: 149, column: 5, scope: !2381)
!2429 = !DILocation(line: 149, column: 11, scope: !2381)
!2430 = !DILocation(line: 149, column: 36, scope: !2381)
!2431 = !DILocation(line: 149, column: 38, scope: !2381)
!2432 = !DILocation(line: 149, column: 22, scope: !2381)
!2433 = !DILocation(line: 149, column: 24, scope: !2381)
!2434 = !DILocation(line: 149, column: 34, scope: !2381)
!2435 = !DILocation(line: 150, column: 12, scope: !2381)
!2436 = !DILocation(line: 150, column: 14, scope: !2381)
!2437 = !DILocation(line: 150, column: 3, scope: !2381)
!2438 = !DILocation(line: 150, column: 5, scope: !2381)
!2439 = !DILocation(line: 150, column: 10, scope: !2381)
!2440 = !DILocation(line: 150, column: 29, scope: !2381)
!2441 = !DILocation(line: 150, column: 31, scope: !2381)
!2442 = !DILocation(line: 150, column: 20, scope: !2381)
!2443 = !DILocation(line: 150, column: 22, scope: !2381)
!2444 = !DILocation(line: 150, column: 27, scope: !2381)
!2445 = !DILocation(line: 150, column: 47, scope: !2381)
!2446 = !DILocation(line: 150, column: 49, scope: !2381)
!2447 = !DILocation(line: 150, column: 37, scope: !2381)
!2448 = !DILocation(line: 150, column: 39, scope: !2381)
!2449 = !DILocation(line: 150, column: 45, scope: !2381)
!2450 = !DILocation(line: 151, column: 15, scope: !2381)
!2451 = !DILocation(line: 151, column: 17, scope: !2381)
!2452 = !DILocation(line: 151, column: 3, scope: !2381)
!2453 = !DILocation(line: 151, column: 5, scope: !2381)
!2454 = !DILocation(line: 151, column: 13, scope: !2381)
!2455 = !DILocation(line: 151, column: 26, scope: !2381)
!2456 = !DILocation(line: 151, column: 28, scope: !2381)
!2457 = !DILocation(line: 151, column: 34, scope: !2381)
!2458 = !DILocation(line: 152, column: 3, scope: !2381)
!2459 = !DILocation(line: 152, column: 5, scope: !2381)
!2460 = !DILocation(line: 152, column: 13, scope: !2381)
!2461 = !DILocation(line: 152, column: 18, scope: !2381)
!2462 = !DILocation(line: 152, column: 20, scope: !2381)
!2463 = !DILocation(line: 152, column: 26, scope: !2381)
!2464 = !DILocation(line: 153, column: 14, scope: !2381)
!2465 = !DILocation(line: 153, column: 16, scope: !2381)
!2466 = !DILocation(line: 153, column: 3, scope: !2381)
!2467 = !DILocation(line: 154, column: 14, scope: !2381)
!2468 = !DILocation(line: 154, column: 16, scope: !2381)
!2469 = !DILocation(line: 154, column: 3, scope: !2381)
!2470 = !DILocation(line: 155, column: 1, scope: !2381)
!2471 = distinct !DISubprogram(name: "none", linkageName: "_ZN4laya4noneEv", scope: !6, file: !15, line: 22, type: !2472, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2472 = !DISubroutineType(types: !2473)
!2473 = !{!96}
!2474 = !DILocation(line: 22, column: 37, scope: !2471)
!2475 = !DILocation(line: 22, column: 30, scope: !2471)
!2476 = distinct !DISubprogram(name: "clear_bits", linkageName: "_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj", scope: !4, file: !3, line: 128, type: !2477, scopeLine: 128, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2477 = !DISubroutineType(types: !2478)
!2478 = !{null, !2003}
!2479 = !DILocalVariable(name: "bits", arg: 1, scope: !2476, file: !3, line: 128, type: !2003)
!2480 = !DILocation(line: 128, column: 26, scope: !2476)
!2481 = !DILocation(line: 128, column: 36, scope: !2476)
!2482 = !DILocation(line: 129, column: 26, scope: !2483)
!2483 = distinct !DILexicalBlock(scope: !2476, file: !3, line: 129, column: 21)
!2484 = !DILocalVariable(name: "i", scope: !2483, file: !3, line: 129, type: !95)
!2485 = !DILocation(line: 129, column: 35, scope: !2483)
!2486 = !DILocation(line: 129, column: 42, scope: !2487)
!2487 = distinct !DILexicalBlock(scope: !2483, file: !3, line: 129, column: 21)
!2488 = !DILocation(line: 129, column: 44, scope: !2487)
!2489 = !DILocation(line: 129, column: 21, scope: !2483)
!2490 = !DILocation(line: 129, column: 21, scope: !2487)
!2491 = !DILocation(line: 129, column: 55, scope: !2487)
!2492 = !DILocation(line: 129, column: 60, scope: !2487)
!2493 = !DILocation(line: 129, column: 63, scope: !2487)
!2494 = !DILocation(line: 129, column: 50, scope: !2487)
!2495 = distinct !{!2495, !2489, !2496, !1769, !2497}
!2496 = !DILocation(line: 129, column: 65, scope: !2483)
!2497 = !{!"llvm.loop.name", !"VITIS_LOOP_129_1"}
!2498 = !DILocation(line: 130, column: 1, scope: !2476)
!2499 = distinct !DISubprogram(name: "find_index", linkageName: "_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh", scope: !4, file: !3, line: 115, type: !2500, scopeLine: 115, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2500 = !DISubroutineType(types: !2501)
!2501 = !{!95, !2040, !96, !16}
!2502 = !DILocalVariable(name: "rt", arg: 1, scope: !2499, file: !3, line: 115, type: !2040)
!2503 = !DILocation(line: 115, column: 40, scope: !2499)
!2504 = !DILocalVariable(name: "ref", arg: 2, scope: !2499, file: !3, line: 115, type: !96)
!2505 = !DILocation(line: 115, column: 54, scope: !2499)
!2506 = !DILocalVariable(name: "region", arg: 3, scope: !2499, file: !3, line: 115, type: !16)
!2507 = !DILocation(line: 115, column: 67, scope: !2499)
!2508 = !DILocation(line: 115, column: 75, scope: !2499)
!2509 = !DILocation(line: 116, column: 26, scope: !2510)
!2510 = distinct !DILexicalBlock(scope: !2499, file: !3, line: 116, column: 21)
!2511 = !DILocalVariable(name: "i", scope: !2510, file: !3, line: 116, type: !95)
!2512 = !DILocation(line: 116, column: 35, scope: !2510)
!2513 = !DILocation(line: 116, column: 42, scope: !2514)
!2514 = distinct !DILexicalBlock(scope: !2510, file: !3, line: 116, column: 21)
!2515 = !DILocation(line: 116, column: 44, scope: !2514)
!2516 = !DILocation(line: 116, column: 21, scope: !2510)
!2517 = !DILocation(line: 117, column: 5, scope: !2518)
!2518 = distinct !DILexicalBlock(scope: !2514, file: !3, line: 116, column: 66)
!2519 = !DILocalVariable(name: "r", scope: !2518, file: !3, line: 117, type: !2343)
!2520 = !DILocation(line: 117, column: 28, scope: !2518)
!2521 = !DILocation(line: 117, column: 32, scope: !2518)
!2522 = !DILocation(line: 117, column: 35, scope: !2518)
!2523 = !DILocation(line: 117, column: 42, scope: !2518)
!2524 = !DILocation(line: 117, column: 49, scope: !2518)
!2525 = !DILocation(line: 118, column: 9, scope: !2526)
!2526 = distinct !DILexicalBlock(scope: !2518, file: !3, line: 118, column: 9)
!2527 = !DILocation(line: 118, column: 11, scope: !2526)
!2528 = !DILocation(line: 118, column: 15, scope: !2526)
!2529 = !DILocation(line: 118, column: 18, scope: !2526)
!2530 = !DILocation(line: 118, column: 34, scope: !2526)
!2531 = !DILocation(line: 118, column: 51, scope: !2526)
!2532 = !DILocation(line: 118, column: 53, scope: !2526)
!2533 = !DILocation(line: 118, column: 58, scope: !2526)
!2534 = !DILocation(line: 118, column: 60, scope: !2526)
!2535 = !DILocation(line: 118, column: 68, scope: !2526)
!2536 = !DILocation(line: 118, column: 73, scope: !2526)
!2537 = !DILocation(line: 118, column: 37, scope: !2526)
!2538 = !DILocation(line: 118, column: 9, scope: !2518)
!2539 = !DILocation(line: 119, column: 14, scope: !2526)
!2540 = !DILocation(line: 119, column: 7, scope: !2526)
!2541 = !DILocation(line: 120, column: 3, scope: !2514)
!2542 = !DILocation(line: 120, column: 3, scope: !2518)
!2543 = !DILocation(line: 116, column: 61, scope: !2514)
!2544 = !DILocation(line: 116, column: 21, scope: !2514)
!2545 = distinct !{!2545, !2516, !2546, !1769, !2547}
!2546 = !DILocation(line: 120, column: 3, scope: !2510)
!2547 = !{!"llvm.loop.name", !"VITIS_LOOP_116_1"}
!2548 = !DILocation(line: 121, column: 3, scope: !2499)
!2549 = !DILocation(line: 122, column: 1, scope: !2499)
!2550 = distinct !DISubprogram(name: "empty_index", linkageName: "_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj", scope: !4, file: !3, line: 123, type: !2551, scopeLine: 123, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2551 = !DISubroutineType(types: !2552)
!2552 = !{!95, !2040, !95}
!2553 = !DILocalVariable(name: "rt", arg: 1, scope: !2550, file: !3, line: 123, type: !2040)
!2554 = !DILocation(line: 123, column: 41, scope: !2550)
!2555 = !DILocalVariable(name: "excluded", arg: 2, scope: !2550, file: !3, line: 123, type: !95)
!2556 = !DILocation(line: 123, column: 54, scope: !2550)
!2557 = !DILocation(line: 123, column: 80, scope: !2550)
!2558 = !DILocation(line: 124, column: 26, scope: !2559)
!2559 = distinct !DILexicalBlock(scope: !2550, file: !3, line: 124, column: 21)
!2560 = !DILocalVariable(name: "i", scope: !2559, file: !3, line: 124, type: !95)
!2561 = !DILocation(line: 124, column: 35, scope: !2559)
!2562 = !DILocation(line: 124, column: 42, scope: !2563)
!2563 = distinct !DILexicalBlock(scope: !2559, file: !3, line: 124, column: 21)
!2564 = !DILocation(line: 124, column: 44, scope: !2563)
!2565 = !DILocation(line: 124, column: 21, scope: !2559)
!2566 = !DILocation(line: 125, column: 9, scope: !2567)
!2567 = distinct !DILexicalBlock(scope: !2563, file: !3, line: 125, column: 9)
!2568 = !DILocation(line: 125, column: 14, scope: !2567)
!2569 = !DILocation(line: 125, column: 11, scope: !2567)
!2570 = !DILocation(line: 125, column: 23, scope: !2567)
!2571 = !DILocation(line: 125, column: 26, scope: !2567)
!2572 = !DILocation(line: 125, column: 29, scope: !2567)
!2573 = !DILocation(line: 125, column: 36, scope: !2567)
!2574 = !DILocation(line: 125, column: 43, scope: !2567)
!2575 = !DILocation(line: 125, column: 46, scope: !2567)
!2576 = !DILocation(line: 125, column: 50, scope: !2567)
!2577 = !DILocation(line: 125, column: 53, scope: !2567)
!2578 = !DILocation(line: 125, column: 9, scope: !2563)
!2579 = !DILocation(line: 125, column: 77, scope: !2567)
!2580 = !DILocation(line: 125, column: 70, scope: !2567)
!2581 = !DILocation(line: 125, column: 64, scope: !2567)
!2582 = !DILocation(line: 124, column: 61, scope: !2563)
!2583 = !DILocation(line: 124, column: 21, scope: !2563)
!2584 = distinct !{!2584, !2565, !2585, !1769, !2586}
!2585 = !DILocation(line: 125, column: 77, scope: !2559)
!2586 = !{!"llvm.loop.name", !"VITIS_LOOP_124_1"}
!2587 = !DILocation(line: 126, column: 3, scope: !2550)
!2588 = !DILocation(line: 127, column: 1, scope: !2550)
!2589 = distinct !DISubprogram(name: "same_physical", linkageName: "_ZN4laya4full12_GLOBAL__N_113same_physicalENS_9BufferRefEhS2_h", scope: !4, file: !3, line: 11, type: !2590, scopeLine: 11, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2590 = !DISubroutineType(types: !2591)
!2591 = !{!237, !96, !16, !96, !16}
!2592 = !DILocalVariable(name: "a", arg: 1, scope: !2589, file: !3, line: 11, type: !96)
!2593 = !DILocation(line: 11, column: 30, scope: !2589)
!2594 = !DILocalVariable(name: "ar", arg: 2, scope: !2589, file: !3, line: 11, type: !16)
!2595 = !DILocation(line: 11, column: 41, scope: !2589)
!2596 = !DILocalVariable(name: "b", arg: 3, scope: !2589, file: !3, line: 11, type: !96)
!2597 = !DILocation(line: 11, column: 55, scope: !2589)
!2598 = !DILocalVariable(name: "br", arg: 4, scope: !2589, file: !3, line: 11, type: !16)
!2599 = !DILocation(line: 11, column: 66, scope: !2589)
!2600 = !DILocation(line: 12, column: 7, scope: !2601)
!2601 = distinct !DILexicalBlock(scope: !2589, file: !3, line: 12, column: 7)
!2602 = !DILocation(line: 12, column: 13, scope: !2601)
!2603 = !DILocation(line: 12, column: 10, scope: !2601)
!2604 = !DILocation(line: 12, column: 7, scope: !2589)
!2605 = !DILocation(line: 12, column: 17, scope: !2601)
!2606 = !DILocation(line: 13, column: 9, scope: !2607)
!2607 = distinct !DILexicalBlock(scope: !2589, file: !3, line: 13, column: 7)
!2608 = !DILocation(line: 13, column: 12, scope: !2607)
!2609 = !DILocation(line: 13, column: 34, scope: !2607)
!2610 = !DILocation(line: 13, column: 39, scope: !2607)
!2611 = !DILocation(line: 13, column: 42, scope: !2607)
!2612 = !DILocation(line: 13, column: 7, scope: !2589)
!2613 = !DILocation(line: 14, column: 5, scope: !2607)
!2614 = !DILocation(line: 15, column: 9, scope: !2615)
!2615 = distinct !DILexicalBlock(scope: !2589, file: !3, line: 15, column: 7)
!2616 = !DILocation(line: 15, column: 7, scope: !2615)
!2617 = !DILocation(line: 15, column: 19, scope: !2615)
!2618 = !DILocation(line: 15, column: 17, scope: !2615)
!2619 = !DILocation(line: 15, column: 14, scope: !2615)
!2620 = !DILocation(line: 15, column: 7, scope: !2589)
!2621 = !DILocation(line: 15, column: 25, scope: !2615)
!2622 = !DILocation(line: 16, column: 9, scope: !2623)
!2623 = distinct !DILexicalBlock(scope: !2589, file: !3, line: 16, column: 7)
!2624 = !DILocation(line: 16, column: 17, scope: !2623)
!2625 = !DILocation(line: 16, column: 12, scope: !2623)
!2626 = !DILocation(line: 16, column: 7, scope: !2589)
!2627 = !DILocation(line: 16, column: 21, scope: !2623)
!2628 = !DILocation(line: 17, column: 13, scope: !2589)
!2629 = !DILocation(line: 17, column: 16, scope: !2589)
!2630 = !DILocation(line: 17, column: 30, scope: !2589)
!2631 = !DILocation(line: 17, column: 35, scope: !2589)
!2632 = !DILocation(line: 17, column: 38, scope: !2589)
!2633 = !DILocation(line: 17, column: 57, scope: !2589)
!2634 = !DILocation(line: 18, column: 13, scope: !2589)
!2635 = !DILocation(line: 18, column: 16, scope: !2589)
!2636 = !DILocation(line: 18, column: 34, scope: !2589)
!2637 = !DILocation(line: 18, column: 39, scope: !2589)
!2638 = !DILocation(line: 18, column: 42, scope: !2589)
!2639 = !DILocation(line: 0, scope: !2589)
!2640 = !DILocation(line: 17, column: 3, scope: !2589)
!2641 = !DILocation(line: 19, column: 1, scope: !2589)
!2642 = distinct !DISubprogram(name: "operator bool", linkageName: "_ZNK4laya5CheckcvbEv", scope: !1202, file: !15, line: 9, type: !1208, scopeLine: 9, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, declaration: !1207, retainedNodes: !990)
!2643 = !DILocalVariable(name: "this", arg: 1, scope: !2642, type: !2644, flags: DIFlagArtificial | DIFlagObjectPointer)
!2644 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1211, size: 64)
!2645 = !DILocation(line: 0, scope: !2642)
!2646 = !DILocation(line: 9, column: 145, scope: !2642)
!2647 = !DILocation(line: 9, column: 149, scope: !2642)
!2648 = !DILocation(line: 9, column: 138, scope: !2642)
!2649 = !DILocalVariable(name: "id", arg: 1, scope: !2, file: !3, line: 26, type: !14)
!2650 = !DILocation(line: 26, column: 29, scope: !2)
!2651 = !DILocalVariable(name: "region", arg: 2, scope: !2, file: !3, line: 26, type: !16)
!2652 = !DILocation(line: 26, column: 41, scope: !2)
!2653 = !DILocation(line: 27, column: 11, scope: !2)
!2654 = !DILocation(line: 27, column: 3, scope: !2)
!2655 = !DILocation(line: 30, column: 49, scope: !2656)
!2656 = distinct !DILexicalBlock(scope: !2, file: !3, line: 27, column: 15)
!2657 = !DILocation(line: 31, column: 22, scope: !2656)
!2658 = !DILocation(line: 32, column: 24, scope: !2656)
!2659 = !DILocation(line: 33, column: 26, scope: !2656)
!2660 = !DILocation(line: 35, column: 54, scope: !2656)
!2661 = !DILocation(line: 38, column: 11, scope: !2662)
!2662 = distinct !DILexicalBlock(scope: !2663, file: !3, line: 38, column: 11)
!2663 = distinct !DILexicalBlock(scope: !2656, file: !3, line: 36, column: 29)
!2664 = !DILocation(line: 38, column: 18, scope: !2662)
!2665 = !DILocation(line: 38, column: 11, scope: !2663)
!2666 = !DILocation(line: 38, column: 48, scope: !2662)
!2667 = !DILocation(line: 39, column: 14, scope: !2663)
!2668 = !DILocation(line: 39, column: 21, scope: !2663)
!2669 = !DILocation(line: 39, column: 34, scope: !2663)
!2670 = !DILocation(line: 39, column: 27, scope: !2663)
!2671 = !DILocation(line: 39, column: 7, scope: !2663)
!2672 = !DILocation(line: 41, column: 30, scope: !2656)
!2673 = !DILocation(line: 42, column: 30, scope: !2656)
!2674 = !DILocation(line: 43, column: 14, scope: !2656)
!2675 = !DILocation(line: 45, column: 1, scope: !2)
!2676 = distinct !DISubprogram(name: "full_claim_qkv_pair", linkageName: "_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE", scope: !5, file: !3, line: 259, type: !2677, scopeLine: 259, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2677 = !DISubroutineType(types: !2678)
!2678 = !{!1202, !1870, !2679}
!2679 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2680, size: 64)
!2680 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1872, size: 384, elements: !1034)
!2681 = !DILocalVariable(name: "rt", arg: 1, scope: !2676, file: !3, line: 259, type: !1870)
!2682 = !DILocation(line: 259, column: 40, scope: !2676)
!2683 = !DILocalVariable(name: "s", arg: 2, scope: !2676, file: !3, line: 259, type: !2679)
!2684 = !DILocation(line: 259, column: 66, scope: !2676)
!2685 = !DILocation(line: 260, column: 8, scope: !2686)
!2686 = distinct !DILexicalBlock(scope: !2676, file: !3, line: 260, column: 7)
!2687 = !DILocation(line: 260, column: 11, scope: !2686)
!2688 = !DILocation(line: 260, column: 25, scope: !2686)
!2689 = !DILocation(line: 260, column: 29, scope: !2686)
!2690 = !DILocation(line: 260, column: 32, scope: !2686)
!2691 = !DILocation(line: 260, column: 51, scope: !2686)
!2692 = !DILocation(line: 261, column: 23, scope: !2686)
!2693 = !DILocation(line: 261, column: 27, scope: !2686)
!2694 = !DILocation(line: 261, column: 8, scope: !2686)
!2695 = !DILocation(line: 260, column: 7, scope: !2676)
!2696 = !DILocation(line: 261, column: 38, scope: !2686)
!2697 = !DILocation(line: 261, column: 31, scope: !2686)
!2698 = !DILocation(line: 262, column: 3, scope: !2676)
!2699 = !DILocalVariable(name: "first", scope: !2676, file: !3, line: 262, type: !104)
!2700 = !DILocation(line: 262, column: 18, scope: !2676)
!2701 = !DILocation(line: 262, column: 38, scope: !2676)
!2702 = !DILocation(line: 262, column: 42, scope: !2676)
!2703 = !DILocation(line: 262, column: 26, scope: !2676)
!2704 = !DILocation(line: 263, column: 3, scope: !2676)
!2705 = !DILocalVariable(name: "second", scope: !2676, file: !3, line: 263, type: !95)
!2706 = !DILocation(line: 263, column: 12, scope: !2676)
!2707 = !DILocation(line: 263, column: 33, scope: !2676)
!2708 = !DILocation(line: 263, column: 37, scope: !2676)
!2709 = !DILocation(line: 263, column: 21, scope: !2676)
!2710 = !DILocation(line: 264, column: 7, scope: !2711)
!2711 = distinct !DILexicalBlock(scope: !2676, file: !3, line: 264, column: 7)
!2712 = !DILocation(line: 264, column: 13, scope: !2711)
!2713 = !DILocation(line: 264, column: 30, scope: !2711)
!2714 = !DILocation(line: 264, column: 33, scope: !2711)
!2715 = !DILocation(line: 264, column: 43, scope: !2711)
!2716 = !DILocation(line: 264, column: 40, scope: !2711)
!2717 = !DILocation(line: 264, column: 49, scope: !2711)
!2718 = !DILocation(line: 265, column: 7, scope: !2711)
!2719 = !DILocation(line: 265, column: 10, scope: !2711)
!2720 = !DILocation(line: 265, column: 17, scope: !2711)
!2721 = !DILocation(line: 265, column: 24, scope: !2711)
!2722 = !DILocation(line: 265, column: 31, scope: !2711)
!2723 = !DILocation(line: 265, column: 35, scope: !2711)
!2724 = !DILocation(line: 265, column: 38, scope: !2711)
!2725 = !DILocation(line: 264, column: 7, scope: !2676)
!2726 = !DILocation(line: 266, column: 26, scope: !2711)
!2727 = !DILocation(line: 266, column: 30, scope: !2711)
!2728 = !DILocation(line: 266, column: 14, scope: !2711)
!2729 = !DILocation(line: 266, column: 12, scope: !2711)
!2730 = !DILocation(line: 266, column: 5, scope: !2711)
!2731 = !DILocation(line: 267, column: 7, scope: !2732)
!2732 = distinct !DILexicalBlock(scope: !2676, file: !3, line: 267, column: 7)
!2733 = !DILocation(line: 267, column: 13, scope: !2732)
!2734 = !DILocation(line: 267, column: 30, scope: !2732)
!2735 = !DILocation(line: 267, column: 33, scope: !2732)
!2736 = !DILocation(line: 267, column: 40, scope: !2732)
!2737 = !DILocation(line: 267, column: 57, scope: !2732)
!2738 = !DILocation(line: 267, column: 60, scope: !2732)
!2739 = !DILocation(line: 267, column: 69, scope: !2732)
!2740 = !DILocation(line: 267, column: 66, scope: !2732)
!2741 = !DILocation(line: 267, column: 7, scope: !2676)
!2742 = !DILocation(line: 268, column: 12, scope: !2732)
!2743 = !DILocation(line: 268, column: 5, scope: !2732)
!2744 = !DILocation(line: 269, column: 15, scope: !2676)
!2745 = !DILocation(line: 269, column: 18, scope: !2676)
!2746 = !DILocation(line: 269, column: 25, scope: !2676)
!2747 = !DILocation(line: 269, column: 32, scope: !2676)
!2748 = !DILocation(line: 269, column: 40, scope: !2676)
!2749 = !DILocation(line: 269, column: 46, scope: !2676)
!2750 = !DILocation(line: 269, column: 49, scope: !2676)
!2751 = !DILocation(line: 269, column: 56, scope: !2676)
!2752 = !DILocation(line: 269, column: 3, scope: !2676)
!2753 = !DILocation(line: 270, column: 15, scope: !2676)
!2754 = !DILocation(line: 270, column: 18, scope: !2676)
!2755 = !DILocation(line: 270, column: 25, scope: !2676)
!2756 = !DILocation(line: 270, column: 32, scope: !2676)
!2757 = !DILocation(line: 270, column: 41, scope: !2676)
!2758 = !DILocation(line: 270, column: 47, scope: !2676)
!2759 = !DILocation(line: 270, column: 50, scope: !2676)
!2760 = !DILocation(line: 270, column: 57, scope: !2676)
!2761 = !DILocation(line: 270, column: 3, scope: !2676)
!2762 = !DILocation(line: 271, column: 3, scope: !2676)
!2763 = !DILocation(line: 271, column: 6, scope: !2676)
!2764 = !DILocation(line: 271, column: 19, scope: !2676)
!2765 = !DILocation(line: 272, column: 40, scope: !2766)
!2766 = distinct !DILexicalBlock(scope: !2676, file: !3, line: 272, column: 21)
!2767 = !DILocalVariable(name: "__range2", scope: !2766, type: !2768, flags: DIFlagArtificial)
!2768 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1066, size: 64)
!2769 = !DILocation(line: 0, scope: !2766)
!2770 = !DILocation(line: 272, column: 43, scope: !2766)
!2771 = !DILocation(line: 272, column: 50, scope: !2766)
!2772 = !DILocation(line: 272, column: 38, scope: !2766)
!2773 = !DILocalVariable(name: "__begin2", scope: !2766, type: !2774, flags: DIFlagArtificial)
!2774 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2775, size: 64)
!2775 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 98304, elements: !2776)
!2776 = !{!1068, !1016, !1023, !1064}
!2777 = !DILocalVariable(name: "__end2", scope: !2766, type: !2774, flags: DIFlagArtificial)
!2778 = !DILocation(line: 272, column: 26, scope: !2779)
!2779 = distinct !DILexicalBlock(scope: !2766, file: !3, line: 272, column: 21)
!2780 = !DILocalVariable(name: "shard", scope: !2779, file: !3, line: 272, type: !2781)
!2781 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2775, size: 64)
!2782 = !DILocation(line: 272, column: 32, scope: !2779)
!2783 = !DILocation(line: 272, column: 38, scope: !2779)
!2784 = !DILocation(line: 273, column: 42, scope: !2785)
!2785 = distinct !DILexicalBlock(scope: !2779, file: !3, line: 273, column: 23)
!2786 = !DILocalVariable(name: "__range3", scope: !2785, type: !2781, flags: DIFlagArtificial)
!2787 = !DILocation(line: 0, scope: !2785)
!2788 = !DILocation(line: 273, column: 40, scope: !2785)
!2789 = !DILocalVariable(name: "__begin3", scope: !2785, type: !2790, flags: DIFlagArtificial)
!2790 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1073, size: 64)
!2791 = !DILocalVariable(name: "__end3", scope: !2785, type: !2790, flags: DIFlagArtificial)
!2792 = !DILocation(line: 273, column: 28, scope: !2793)
!2793 = distinct !DILexicalBlock(scope: !2785, file: !3, line: 273, column: 23)
!2794 = !DILocalVariable(name: "plane", scope: !2793, file: !3, line: 273, type: !1966)
!2795 = !DILocation(line: 273, column: 34, scope: !2793)
!2796 = !DILocation(line: 273, column: 40, scope: !2793)
!2797 = !DILocation(line: 274, column: 43, scope: !2798)
!2798 = distinct !DILexicalBlock(scope: !2793, file: !3, line: 274, column: 25)
!2799 = !DILocalVariable(name: "__range4", scope: !2798, type: !1966, flags: DIFlagArtificial)
!2800 = !DILocation(line: 0, scope: !2798)
!2801 = !DILocation(line: 274, column: 41, scope: !2798)
!2802 = !DILocalVariable(name: "__begin4", scope: !2798, type: !1972, flags: DIFlagArtificial)
!2803 = !DILocalVariable(name: "__end4", scope: !2798, type: !1972, flags: DIFlagArtificial)
!2804 = !DILocation(line: 274, column: 30, scope: !2805)
!2805 = distinct !DILexicalBlock(scope: !2798, file: !3, line: 274, column: 25)
!2806 = !DILocalVariable(name: "head", scope: !2805, file: !3, line: 274, type: !1979)
!2807 = !DILocation(line: 274, column: 36, scope: !2805)
!2808 = !DILocation(line: 274, column: 41, scope: !2805)
!2809 = !DILocation(line: 275, column: 46, scope: !2810)
!2810 = distinct !DILexicalBlock(scope: !2805, file: !3, line: 275, column: 27)
!2811 = !DILocalVariable(name: "__range5", scope: !2810, type: !1979, flags: DIFlagArtificial)
!2812 = !DILocation(line: 0, scope: !2810)
!2813 = !DILocation(line: 275, column: 44, scope: !2810)
!2814 = !DILocalVariable(name: "__begin5", scope: !2810, type: !1988, flags: DIFlagArtificial)
!2815 = !DILocalVariable(name: "__end5", scope: !2810, type: !1988, flags: DIFlagArtificial)
!2816 = !DILocation(line: 275, column: 32, scope: !2817)
!2817 = distinct !DILexicalBlock(scope: !2810, file: !3, line: 275, column: 27)
!2818 = !DILocalVariable(name: "batch", scope: !2817, file: !3, line: 275, type: !1994)
!2819 = !DILocation(line: 275, column: 38, scope: !2817)
!2820 = !DILocation(line: 275, column: 44, scope: !2817)
!2821 = !DILocation(line: 276, column: 51, scope: !2822)
!2822 = distinct !DILexicalBlock(scope: !2817, file: !3, line: 276, column: 29)
!2823 = !DILocalVariable(name: "__range6", scope: !2822, type: !1994, flags: DIFlagArtificial)
!2824 = !DILocation(line: 0, scope: !2822)
!2825 = !DILocation(line: 276, column: 49, scope: !2822)
!2826 = !DILocalVariable(name: "__begin6", scope: !2822, type: !2003, flags: DIFlagArtificial)
!2827 = !DILocalVariable(name: "__end6", scope: !2822, type: !2003, flags: DIFlagArtificial)
!2828 = !DILocation(line: 276, column: 34, scope: !2829)
!2829 = distinct !DILexicalBlock(scope: !2822, file: !3, line: 276, column: 29)
!2830 = !DILocalVariable(name: "word", scope: !2829, file: !3, line: 276, type: !2008)
!2831 = !DILocation(line: 276, column: 44, scope: !2829)
!2832 = !DILocation(line: 276, column: 49, scope: !2829)
!2833 = !DILocation(line: 276, column: 58, scope: !2829)
!2834 = !DILocation(line: 276, column: 63, scope: !2829)
!2835 = !DILocation(line: 276, column: 65, scope: !2822)
!2836 = !DILocation(line: 276, column: 29, scope: !2822)
!2837 = distinct !{!2837, !2836, !2835, !2838}
!2838 = !{!"llvm.loop.name", !"VITIS_LOOP_276_5"}
!2839 = !DILocation(line: 276, column: 65, scope: !2810)
!2840 = !DILocation(line: 275, column: 27, scope: !2810)
!2841 = distinct !{!2841, !2840, !2839, !2842}
!2842 = !{!"llvm.loop.name", !"VITIS_LOOP_275_4"}
!2843 = !DILocation(line: 276, column: 65, scope: !2798)
!2844 = !DILocation(line: 274, column: 25, scope: !2798)
!2845 = distinct !{!2845, !2844, !2843, !2846}
!2846 = !{!"llvm.loop.name", !"VITIS_LOOP_274_3"}
!2847 = !DILocation(line: 276, column: 65, scope: !2785)
!2848 = !DILocation(line: 273, column: 23, scope: !2785)
!2849 = distinct !{!2849, !2848, !2847, !2850}
!2850 = !{!"llvm.loop.name", !"VITIS_LOOP_273_2"}
!2851 = !DILocation(line: 276, column: 65, scope: !2766)
!2852 = !DILocation(line: 272, column: 21, scope: !2766)
!2853 = distinct !{!2853, !2852, !2851, !2854}
!2854 = !{!"llvm.loop.name", !"VITIS_LOOP_272_1"}
!2855 = !DILocation(line: 277, column: 40, scope: !2856)
!2856 = distinct !DILexicalBlock(scope: !2676, file: !3, line: 277, column: 21)
!2857 = !DILocalVariable(name: "__range2", scope: !2856, type: !2858, flags: DIFlagArtificial)
!2858 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1070, size: 64)
!2859 = !DILocation(line: 0, scope: !2856)
!2860 = !DILocation(line: 277, column: 43, scope: !2856)
!2861 = !DILocation(line: 277, column: 50, scope: !2856)
!2862 = !DILocation(line: 277, column: 38, scope: !2856)
!2863 = !DILocalVariable(name: "__begin2", scope: !2856, type: !2864, flags: DIFlagArtificial)
!2864 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2865, size: 64)
!2865 = !DICompositeType(tag: DW_TAG_array_type, baseType: !93, size: 65536, elements: !2866)
!2866 = !{!1023, !1016, !1023, !1064}
!2867 = !DILocalVariable(name: "__end2", scope: !2856, type: !2864, flags: DIFlagArtificial)
!2868 = !DILocation(line: 277, column: 26, scope: !2869)
!2869 = distinct !DILexicalBlock(scope: !2856, file: !3, line: 277, column: 21)
!2870 = !DILocalVariable(name: "shard", scope: !2869, file: !3, line: 277, type: !2871)
!2871 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2865, size: 64)
!2872 = !DILocation(line: 277, column: 32, scope: !2869)
!2873 = !DILocation(line: 277, column: 38, scope: !2869)
!2874 = !DILocation(line: 278, column: 42, scope: !2875)
!2875 = distinct !DILexicalBlock(scope: !2869, file: !3, line: 278, column: 23)
!2876 = !DILocalVariable(name: "__range3", scope: !2875, type: !2871, flags: DIFlagArtificial)
!2877 = !DILocation(line: 0, scope: !2875)
!2878 = !DILocation(line: 278, column: 40, scope: !2875)
!2879 = !DILocalVariable(name: "__begin3", scope: !2875, type: !2790, flags: DIFlagArtificial)
!2880 = !DILocalVariable(name: "__end3", scope: !2875, type: !2790, flags: DIFlagArtificial)
!2881 = !DILocation(line: 278, column: 28, scope: !2882)
!2882 = distinct !DILexicalBlock(scope: !2875, file: !3, line: 278, column: 23)
!2883 = !DILocalVariable(name: "plane", scope: !2882, file: !3, line: 278, type: !1966)
!2884 = !DILocation(line: 278, column: 34, scope: !2882)
!2885 = !DILocation(line: 278, column: 40, scope: !2882)
!2886 = !DILocation(line: 279, column: 43, scope: !2887)
!2887 = distinct !DILexicalBlock(scope: !2882, file: !3, line: 279, column: 25)
!2888 = !DILocalVariable(name: "__range4", scope: !2887, type: !1966, flags: DIFlagArtificial)
!2889 = !DILocation(line: 0, scope: !2887)
!2890 = !DILocation(line: 279, column: 41, scope: !2887)
!2891 = !DILocalVariable(name: "__begin4", scope: !2887, type: !1972, flags: DIFlagArtificial)
!2892 = !DILocalVariable(name: "__end4", scope: !2887, type: !1972, flags: DIFlagArtificial)
!2893 = !DILocation(line: 279, column: 30, scope: !2894)
!2894 = distinct !DILexicalBlock(scope: !2887, file: !3, line: 279, column: 25)
!2895 = !DILocalVariable(name: "head", scope: !2894, file: !3, line: 279, type: !1979)
!2896 = !DILocation(line: 279, column: 36, scope: !2894)
!2897 = !DILocation(line: 279, column: 41, scope: !2894)
!2898 = !DILocation(line: 280, column: 46, scope: !2899)
!2899 = distinct !DILexicalBlock(scope: !2894, file: !3, line: 280, column: 27)
!2900 = !DILocalVariable(name: "__range5", scope: !2899, type: !1979, flags: DIFlagArtificial)
!2901 = !DILocation(line: 0, scope: !2899)
!2902 = !DILocation(line: 280, column: 44, scope: !2899)
!2903 = !DILocalVariable(name: "__begin5", scope: !2899, type: !1988, flags: DIFlagArtificial)
!2904 = !DILocalVariable(name: "__end5", scope: !2899, type: !1988, flags: DIFlagArtificial)
!2905 = !DILocation(line: 280, column: 32, scope: !2906)
!2906 = distinct !DILexicalBlock(scope: !2899, file: !3, line: 280, column: 27)
!2907 = !DILocalVariable(name: "batch", scope: !2906, file: !3, line: 280, type: !1994)
!2908 = !DILocation(line: 280, column: 38, scope: !2906)
!2909 = !DILocation(line: 280, column: 44, scope: !2906)
!2910 = !DILocation(line: 281, column: 52, scope: !2911)
!2911 = distinct !DILexicalBlock(scope: !2906, file: !3, line: 281, column: 30)
!2912 = !DILocalVariable(name: "__range6", scope: !2911, type: !1994, flags: DIFlagArtificial)
!2913 = !DILocation(line: 0, scope: !2911)
!2914 = !DILocation(line: 281, column: 50, scope: !2911)
!2915 = !DILocalVariable(name: "__begin6", scope: !2911, type: !2003, flags: DIFlagArtificial)
!2916 = !DILocalVariable(name: "__end6", scope: !2911, type: !2003, flags: DIFlagArtificial)
!2917 = !DILocation(line: 281, column: 35, scope: !2918)
!2918 = distinct !DILexicalBlock(scope: !2911, file: !3, line: 281, column: 30)
!2919 = !DILocalVariable(name: "word", scope: !2918, file: !3, line: 281, type: !2008)
!2920 = !DILocation(line: 281, column: 45, scope: !2918)
!2921 = !DILocation(line: 281, column: 50, scope: !2918)
!2922 = !DILocation(line: 281, column: 59, scope: !2918)
!2923 = !DILocation(line: 281, column: 64, scope: !2918)
!2924 = !DILocation(line: 281, column: 66, scope: !2911)
!2925 = !DILocation(line: 281, column: 30, scope: !2911)
!2926 = distinct !{!2926, !2925, !2924, !2927}
!2927 = !{!"llvm.loop.name", !"VITIS_LOOP_281_10"}
!2928 = !DILocation(line: 281, column: 66, scope: !2899)
!2929 = !DILocation(line: 280, column: 27, scope: !2899)
!2930 = distinct !{!2930, !2929, !2928, !2931}
!2931 = !{!"llvm.loop.name", !"VITIS_LOOP_280_9"}
!2932 = !DILocation(line: 281, column: 66, scope: !2887)
!2933 = !DILocation(line: 279, column: 25, scope: !2887)
!2934 = distinct !{!2934, !2933, !2932, !2935}
!2935 = !{!"llvm.loop.name", !"VITIS_LOOP_279_8"}
!2936 = !DILocation(line: 281, column: 66, scope: !2875)
!2937 = !DILocation(line: 278, column: 23, scope: !2875)
!2938 = distinct !{!2938, !2937, !2936, !2939}
!2939 = !{!"llvm.loop.name", !"VITIS_LOOP_278_7"}
!2940 = !DILocation(line: 281, column: 66, scope: !2856)
!2941 = !DILocation(line: 277, column: 21, scope: !2856)
!2942 = distinct !{!2942, !2941, !2940, !2943}
!2943 = !{!"llvm.loop.name", !"VITIS_LOOP_277_6"}
!2944 = !DILocation(line: 282, column: 10, scope: !2676)
!2945 = !DILocation(line: 282, column: 3, scope: !2676)
!2946 = !DILocation(line: 283, column: 1, scope: !2676)
!2947 = distinct !DISubprogram(name: "qkv_pair_specs", linkageName: "_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE", scope: !4, file: !3, line: 161, type: !2948, scopeLine: 161, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !44, retainedNodes: !990)
!2948 = !DISubroutineType(types: !2949)
!2949 = !{!237, !2040, !2679}
!2950 = !DILocalVariable(name: "rt", arg: 1, scope: !2947, file: !3, line: 161, type: !2040)
!2951 = !DILocation(line: 161, column: 40, scope: !2947)
!2952 = !DILocalVariable(name: "s", arg: 2, scope: !2947, file: !3, line: 161, type: !2679)
!2953 = !DILocation(line: 161, column: 66, scope: !2947)
!2954 = !DILocation(line: 162, column: 21, scope: !2947)
!2955 = !DILocation(line: 162, column: 25, scope: !2947)
!2956 = !DILocation(line: 162, column: 10, scope: !2947)
!2957 = !DILocation(line: 162, column: 31, scope: !2947)
!2958 = !DILocation(line: 162, column: 45, scope: !2947)
!2959 = !DILocation(line: 162, column: 49, scope: !2947)
!2960 = !DILocation(line: 162, column: 34, scope: !2947)
!2961 = !DILocation(line: 162, column: 55, scope: !2947)
!2962 = !DILocation(line: 163, column: 10, scope: !2947)
!2963 = !DILocation(line: 163, column: 15, scope: !2947)
!2964 = !DILocation(line: 163, column: 19, scope: !2947)
!2965 = !DILocation(line: 163, column: 22, scope: !2947)
!2966 = !DILocation(line: 163, column: 37, scope: !2947)
!2967 = !DILocation(line: 163, column: 40, scope: !2947)
!2968 = !DILocation(line: 163, column: 45, scope: !2947)
!2969 = !DILocation(line: 163, column: 49, scope: !2947)
!2970 = !DILocation(line: 163, column: 52, scope: !2947)
!2971 = !DILocation(line: 163, column: 67, scope: !2947)
!2972 = !DILocation(line: 164, column: 10, scope: !2947)
!2973 = !DILocation(line: 164, column: 15, scope: !2947)
!2974 = !DILocation(line: 164, column: 19, scope: !2947)
!2975 = !DILocation(line: 164, column: 24, scope: !2947)
!2976 = !DILocation(line: 164, column: 29, scope: !2947)
!2977 = !DILocation(line: 164, column: 32, scope: !2947)
!2978 = !DILocation(line: 164, column: 37, scope: !2947)
!2979 = !DILocation(line: 164, column: 41, scope: !2947)
!2980 = !DILocation(line: 164, column: 46, scope: !2947)
!2981 = !DILocation(line: 164, column: 51, scope: !2947)
!2982 = !DILocation(line: 165, column: 10, scope: !2947)
!2983 = !DILocation(line: 165, column: 15, scope: !2947)
!2984 = !DILocation(line: 165, column: 22, scope: !2947)
!2985 = !DILocation(line: 165, column: 27, scope: !2947)
!2986 = !DILocation(line: 165, column: 30, scope: !2947)
!2987 = !DILocation(line: 165, column: 35, scope: !2947)
!2988 = !DILocation(line: 165, column: 42, scope: !2947)
!2989 = !DILocation(line: 165, column: 47, scope: !2947)
!2990 = !DILocation(line: 166, column: 10, scope: !2947)
!2991 = !DILocation(line: 166, column: 15, scope: !2947)
!2992 = !DILocation(line: 166, column: 21, scope: !2947)
!2993 = !DILocation(line: 166, column: 28, scope: !2947)
!2994 = !DILocation(line: 166, column: 31, scope: !2947)
!2995 = !DILocation(line: 166, column: 36, scope: !2947)
!2996 = !DILocation(line: 166, column: 42, scope: !2947)
!2997 = !DILocation(line: 166, column: 49, scope: !2947)
!2998 = !DILocation(line: 167, column: 10, scope: !2947)
!2999 = !DILocation(line: 167, column: 15, scope: !2947)
!3000 = !DILocation(line: 167, column: 25, scope: !2947)
!3001 = !DILocation(line: 167, column: 44, scope: !2947)
!3002 = !DILocation(line: 168, column: 10, scope: !2947)
!3003 = !DILocation(line: 168, column: 15, scope: !2947)
!3004 = !DILocation(line: 168, column: 25, scope: !2947)
!3005 = !DILocation(line: 168, column: 44, scope: !2947)
!3006 = !DILocation(line: 169, column: 10, scope: !2947)
!3007 = !DILocation(line: 169, column: 15, scope: !2947)
!3008 = !DILocation(line: 169, column: 20, scope: !2947)
!3009 = !DILocation(line: 169, column: 25, scope: !2947)
!3010 = !DILocation(line: 169, column: 28, scope: !2947)
!3011 = !DILocation(line: 169, column: 33, scope: !2947)
!3012 = !DILocation(line: 169, column: 38, scope: !2947)
!3013 = !DILocation(line: 169, column: 43, scope: !2947)
!3014 = !DILocation(line: 170, column: 10, scope: !2947)
!3015 = !DILocation(line: 170, column: 15, scope: !2947)
!3016 = !DILocation(line: 170, column: 23, scope: !2947)
!3017 = !DILocation(line: 170, column: 26, scope: !2947)
!3018 = !DILocation(line: 170, column: 33, scope: !2947)
!3019 = !DILocation(line: 170, column: 42, scope: !2947)
!3020 = !DILocation(line: 170, column: 20, scope: !2947)
!3021 = !DILocation(line: 170, column: 44, scope: !2947)
!3022 = !DILocation(line: 171, column: 10, scope: !2947)
!3023 = !DILocation(line: 171, column: 15, scope: !2947)
!3024 = !DILocation(line: 171, column: 23, scope: !2947)
!3025 = !DILocation(line: 171, column: 26, scope: !2947)
!3026 = !DILocation(line: 171, column: 33, scope: !2947)
!3027 = !DILocation(line: 171, column: 42, scope: !2947)
!3028 = !DILocation(line: 171, column: 20, scope: !2947)
!3029 = !DILocation(line: 171, column: 44, scope: !2947)
!3030 = !DILocation(line: 172, column: 10, scope: !2947)
!3031 = !DILocation(line: 172, column: 15, scope: !2947)
!3032 = !DILocation(line: 172, column: 24, scope: !2947)
!3033 = !DILocation(line: 172, column: 29, scope: !2947)
!3034 = !DILocation(line: 172, column: 21, scope: !2947)
!3035 = !DILocation(line: 172, column: 35, scope: !2947)
!3036 = !DILocation(line: 172, column: 38, scope: !2947)
!3037 = !DILocation(line: 172, column: 43, scope: !2947)
!3038 = !DILocation(line: 172, column: 52, scope: !2947)
!3039 = !DILocation(line: 172, column: 57, scope: !2947)
!3040 = !DILocation(line: 172, column: 49, scope: !2947)
!3041 = !DILocation(line: 172, column: 63, scope: !2947)
!3042 = !DILocation(line: 173, column: 10, scope: !2947)
!3043 = !DILocation(line: 173, column: 15, scope: !2947)
!3044 = !DILocation(line: 173, column: 21, scope: !2947)
!3045 = !DILocation(line: 173, column: 27, scope: !2947)
!3046 = !DILocation(line: 173, column: 30, scope: !2947)
!3047 = !DILocation(line: 173, column: 35, scope: !2947)
!3048 = !DILocation(line: 173, column: 41, scope: !2947)
!3049 = !DILocation(line: 173, column: 47, scope: !2947)
!3050 = !DILocation(line: 174, column: 10, scope: !2947)
!3051 = !DILocation(line: 174, column: 15, scope: !2947)
!3052 = !DILocation(line: 174, column: 26, scope: !2947)
!3053 = !DILocation(line: 174, column: 31, scope: !2947)
!3054 = !DILocation(line: 174, column: 23, scope: !2947)
!3055 = !DILocation(line: 174, column: 39, scope: !2947)
!3056 = !DILocation(line: 175, column: 12, scope: !2947)
!3057 = !DILocation(line: 175, column: 17, scope: !2947)
!3058 = !DILocation(line: 175, column: 23, scope: !2947)
!3059 = !DILocation(line: 175, column: 28, scope: !2947)
!3060 = !DILocation(line: 175, column: 31, scope: !2947)
!3061 = !DILocation(line: 175, column: 36, scope: !2947)
!3062 = !DILocation(line: 175, column: 44, scope: !2947)
!3063 = !DILocation(line: 175, column: 65, scope: !2947)
!3064 = !DILocation(line: 176, column: 12, scope: !2947)
!3065 = !DILocation(line: 176, column: 17, scope: !2947)
!3066 = !DILocation(line: 176, column: 23, scope: !2947)
!3067 = !DILocation(line: 176, column: 28, scope: !2947)
!3068 = !DILocation(line: 176, column: 31, scope: !2947)
!3069 = !DILocation(line: 176, column: 36, scope: !2947)
!3070 = !DILocation(line: 176, column: 44, scope: !2947)
!3071 = !DILocation(line: 0, scope: !2947)
!3072 = !DILocation(line: 162, column: 3, scope: !2947)
!3073 = distinct !DISubprogram(name: "full_invalidate_owner", linkageName: "_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh", scope: !5, file: !3, line: 623, type: !3074, scopeLine: 623, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!3074 = !DISubroutineType(types: !3075)
!3075 = !{!1202, !1870, !96, !16}
!3076 = !DILocalVariable(name: "rt", arg: 1, scope: !3073, file: !3, line: 623, type: !1870)
!3077 = !DILocation(line: 623, column: 42, scope: !3073)
!3078 = !DILocalVariable(name: "ref", arg: 2, scope: !3073, file: !3, line: 623, type: !96)
!3079 = !DILocation(line: 623, column: 56, scope: !3073)
!3080 = !DILocalVariable(name: "region", arg: 3, scope: !3073, file: !3, line: 623, type: !16)
!3081 = !DILocation(line: 623, column: 69, scope: !3073)
!3082 = !DILocation(line: 624, column: 3, scope: !3073)
!3083 = !DILocalVariable(name: "index", scope: !3073, file: !3, line: 624, type: !104)
!3084 = !DILocation(line: 624, column: 18, scope: !3073)
!3085 = !DILocation(line: 624, column: 37, scope: !3073)
!3086 = !DILocation(line: 624, column: 41, scope: !3073)
!3087 = !DILocation(line: 624, column: 46, scope: !3073)
!3088 = !DILocation(line: 624, column: 26, scope: !3073)
!3089 = !DILocation(line: 625, column: 7, scope: !3090)
!3090 = distinct !DILexicalBlock(scope: !3073, file: !3, line: 625, column: 7)
!3091 = !DILocation(line: 625, column: 13, scope: !3090)
!3092 = !DILocation(line: 625, column: 7, scope: !3073)
!3093 = !DILocation(line: 625, column: 48, scope: !3090)
!3094 = !DILocation(line: 625, column: 38, scope: !3090)
!3095 = !DILocation(line: 625, column: 31, scope: !3090)
!3096 = !DILocation(line: 626, column: 3, scope: !3073)
!3097 = !DILocalVariable(name: "r", scope: !3073, file: !3, line: 626, type: !2384)
!3098 = !DILocation(line: 626, column: 20, scope: !3073)
!3099 = !DILocation(line: 626, column: 24, scope: !3073)
!3100 = !DILocation(line: 626, column: 27, scope: !3073)
!3101 = !DILocation(line: 626, column: 34, scope: !3073)
!3102 = !DILocation(line: 626, column: 41, scope: !3073)
!3103 = !DILocation(line: 627, column: 7, scope: !3104)
!3104 = distinct !DILexicalBlock(scope: !3073, file: !3, line: 627, column: 7)
!3105 = !DILocation(line: 627, column: 9, scope: !3104)
!3106 = !DILocation(line: 627, column: 16, scope: !3104)
!3107 = !DILocation(line: 627, column: 13, scope: !3104)
!3108 = !DILocation(line: 627, column: 20, scope: !3104)
!3109 = !DILocation(line: 627, column: 23, scope: !3104)
!3110 = !DILocation(line: 627, column: 25, scope: !3104)
!3111 = !DILocation(line: 627, column: 42, scope: !3104)
!3112 = !DILocation(line: 627, column: 39, scope: !3104)
!3113 = !DILocation(line: 627, column: 7, scope: !3073)
!3114 = !DILocation(line: 627, column: 64, scope: !3104)
!3115 = !DILocation(line: 627, column: 54, scope: !3104)
!3116 = !DILocation(line: 627, column: 47, scope: !3104)
!3117 = !DILocation(line: 628, column: 7, scope: !3118)
!3118 = distinct !DILexicalBlock(scope: !3073, file: !3, line: 628, column: 7)
!3119 = !DILocation(line: 628, column: 9, scope: !3118)
!3120 = !DILocation(line: 628, column: 15, scope: !3118)
!3121 = !DILocation(line: 628, column: 35, scope: !3118)
!3122 = !DILocation(line: 628, column: 38, scope: !3118)
!3123 = !DILocation(line: 628, column: 40, scope: !3118)
!3124 = !DILocation(line: 628, column: 7, scope: !3073)
!3125 = !DILocation(line: 628, column: 66, scope: !3118)
!3126 = !DILocation(line: 628, column: 56, scope: !3118)
!3127 = !DILocation(line: 628, column: 49, scope: !3118)
!3128 = !DILocation(line: 629, column: 3, scope: !3073)
!3129 = !DILocation(line: 629, column: 5, scope: !3073)
!3130 = !DILocation(line: 629, column: 11, scope: !3073)
!3131 = !DILocation(line: 630, column: 3, scope: !3073)
!3132 = !DILocation(line: 630, column: 5, scope: !3073)
!3133 = !DILocation(line: 630, column: 11, scope: !3073)
!3134 = !DILocation(line: 631, column: 21, scope: !3073)
!3135 = !DILocation(line: 631, column: 3, scope: !3073)
!3136 = !DILocation(line: 631, column: 5, scope: !3073)
!3137 = !DILocation(line: 631, column: 19, scope: !3073)
!3138 = !DILocation(line: 632, column: 7, scope: !3139)
!3139 = distinct !DILexicalBlock(scope: !3073, file: !3, line: 632, column: 7)
!3140 = !DILocation(line: 632, column: 9, scope: !3139)
!3141 = !DILocation(line: 632, column: 13, scope: !3139)
!3142 = !DILocation(line: 632, column: 16, scope: !3139)
!3143 = !DILocation(line: 632, column: 7, scope: !3073)
!3144 = !DILocation(line: 633, column: 38, scope: !3145)
!3145 = distinct !DILexicalBlock(scope: !3139, file: !3, line: 633, column: 23)
!3146 = !DILocalVariable(name: "__range3", scope: !3145, type: !1937, flags: DIFlagArtificial)
!3147 = !DILocation(line: 0, scope: !3145)
!3148 = !DILocation(line: 633, column: 41, scope: !3145)
!3149 = !DILocation(line: 633, column: 48, scope: !3145)
!3150 = !DILocation(line: 633, column: 36, scope: !3145)
!3151 = !DILocalVariable(name: "__begin3", scope: !3145, type: !1943, flags: DIFlagArtificial)
!3152 = !DILocalVariable(name: "__end3", scope: !3145, type: !1943, flags: DIFlagArtificial)
!3153 = !DILocation(line: 633, column: 28, scope: !3154)
!3154 = distinct !DILexicalBlock(scope: !3145, file: !3, line: 633, column: 23)
!3155 = !DILocalVariable(name: "v", scope: !3154, file: !3, line: 633, type: !1948)
!3156 = !DILocation(line: 633, column: 34, scope: !3154)
!3157 = !DILocation(line: 633, column: 36, scope: !3154)
!3158 = !DILocation(line: 633, column: 60, scope: !3154)
!3159 = !DILocation(line: 633, column: 62, scope: !3154)
!3160 = !DILocation(line: 633, column: 64, scope: !3145)
!3161 = !DILocation(line: 633, column: 23, scope: !3145)
!3162 = distinct !{!3162, !3161, !3160, !3163}
!3163 = !{!"llvm.loop.name", !"VITIS_LOOP_633_1"}
!3164 = !DILocation(line: 634, column: 14, scope: !3073)
!3165 = !DILocation(line: 634, column: 16, scope: !3073)
!3166 = !DILocation(line: 634, column: 3, scope: !3073)
!3167 = !DILocation(line: 635, column: 14, scope: !3073)
!3168 = !DILocation(line: 635, column: 16, scope: !3073)
!3169 = !DILocation(line: 635, column: 3, scope: !3073)
!3170 = !DILocation(line: 636, column: 10, scope: !3073)
!3171 = !DILocation(line: 636, column: 3, scope: !3073)
!3172 = !DILocation(line: 637, column: 1, scope: !3073)
!3173 = distinct !DISubprogram(name: "operator!=", linkageName: "_ZN4layaneENS_9BufferRefES0_", scope: !6, file: !15, line: 21, type: !3174, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!3174 = !DISubroutineType(types: !3175)
!3175 = !{!237, !96, !96}
!3176 = !DILocalVariable(name: "a", arg: 1, scope: !3173, file: !15, line: 21, type: !96)
!3177 = !DILocation(line: 21, column: 37, scope: !3173)
!3178 = !DILocalVariable(name: "b", arg: 2, scope: !3173, file: !15, line: 21, type: !96)
!3179 = !DILocation(line: 21, column: 49, scope: !3173)
!3180 = !DILocation(line: 21, column: 63, scope: !3173)
!3181 = !DILocation(line: 21, column: 66, scope: !3173)
!3182 = !DILocation(line: 21, column: 64, scope: !3173)
!3183 = !DILocation(line: 21, column: 61, scope: !3173)
!3184 = !DILocation(line: 21, column: 54, scope: !3173)
!3185 = distinct !DISubprogram(name: "operator==", linkageName: "_ZN4layaeqENS_9BufferRefES0_", scope: !6, file: !15, line: 20, type: !3174, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1217, retainedNodes: !990)
!3186 = !DILocalVariable(name: "a", arg: 1, scope: !3185, file: !15, line: 20, type: !96)
!3187 = !DILocation(line: 20, column: 37, scope: !3185)
!3188 = !DILocalVariable(name: "b", arg: 2, scope: !3185, file: !15, line: 20, type: !96)
!3189 = !DILocation(line: 20, column: 49, scope: !3185)
!3190 = !DILocation(line: 20, column: 63, scope: !3185)
!3191 = !DILocation(line: 20, column: 69, scope: !3185)
!3192 = !DILocation(line: 20, column: 65, scope: !3185)
!3193 = !DILocation(line: 20, column: 72, scope: !3185)
!3194 = !DILocation(line: 20, column: 77, scope: !3185)
!3195 = !DILocation(line: 20, column: 75, scope: !3185)
!3196 = !DILocation(line: 20, column: 85, scope: !3185)
!3197 = !DILocation(line: 20, column: 83, scope: !3185)
!3198 = !DILocation(line: 20, column: 81, scope: !3185)
!3199 = !DILocation(line: 20, column: 90, scope: !3185)
!3200 = !DILocation(line: 20, column: 95, scope: !3185)
!3201 = !DILocation(line: 20, column: 104, scope: !3185)
!3202 = !DILocation(line: 20, column: 100, scope: !3185)
!3203 = !DILocation(line: 0, scope: !3185)
!3204 = !DILocation(line: 20, column: 54, scope: !3185)
!3205 = distinct !DISubprogram(name: "full_recycle_request", linkageName: "_ZN4laya4full20full_recycle_requestERNS0_11FullRuntimeE", scope: !5, file: !3, line: 746, type: !3206, scopeLine: 746, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!3206 = !DISubroutineType(types: !3207)
!3207 = !{!1202, !1870}
!3208 = !DILocalVariable(name: "rt", arg: 1, scope: !3205, file: !3, line: 746, type: !1870)
!3209 = !DILocation(line: 746, column: 41, scope: !3205)
!3210 = !DILocation(line: 746, column: 45, scope: !3205)
!3211 = !DILocation(line: 747, column: 26, scope: !3212)
!3212 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 747, column: 21)
!3213 = !DILocalVariable(name: "i", scope: !3212, file: !3, line: 747, type: !95)
!3214 = !DILocation(line: 747, column: 35, scope: !3212)
!3215 = !DILocation(line: 747, column: 42, scope: !3216)
!3216 = distinct !DILexicalBlock(scope: !3212, file: !3, line: 747, column: 21)
!3217 = !DILocation(line: 747, column: 44, scope: !3216)
!3218 = !DILocation(line: 747, column: 21, scope: !3212)
!3219 = !DILocation(line: 748, column: 5, scope: !3220)
!3220 = distinct !DILexicalBlock(scope: !3216, file: !3, line: 747, column: 66)
!3221 = !DILocalVariable(name: "r", scope: !3220, file: !3, line: 748, type: !2343)
!3222 = !DILocation(line: 748, column: 28, scope: !3220)
!3223 = !DILocation(line: 748, column: 32, scope: !3220)
!3224 = !DILocation(line: 748, column: 35, scope: !3220)
!3225 = !DILocation(line: 748, column: 42, scope: !3220)
!3226 = !DILocation(line: 748, column: 49, scope: !3220)
!3227 = !DILocation(line: 749, column: 9, scope: !3228)
!3228 = distinct !DILexicalBlock(scope: !3220, file: !3, line: 749, column: 9)
!3229 = !DILocation(line: 749, column: 11, scope: !3228)
!3230 = !DILocation(line: 749, column: 17, scope: !3228)
!3231 = !DILocation(line: 749, column: 37, scope: !3228)
!3232 = !DILocation(line: 749, column: 40, scope: !3228)
!3233 = !DILocation(line: 749, column: 42, scope: !3228)
!3234 = !DILocation(line: 749, column: 48, scope: !3228)
!3235 = !DILocation(line: 749, column: 68, scope: !3228)
!3236 = !DILocation(line: 750, column: 9, scope: !3228)
!3237 = !DILocation(line: 750, column: 11, scope: !3228)
!3238 = !DILocation(line: 750, column: 17, scope: !3228)
!3239 = !DILocation(line: 750, column: 45, scope: !3228)
!3240 = !DILocation(line: 750, column: 48, scope: !3228)
!3241 = !DILocation(line: 750, column: 50, scope: !3228)
!3242 = !DILocation(line: 750, column: 56, scope: !3228)
!3243 = !DILocation(line: 750, column: 77, scope: !3228)
!3244 = !DILocation(line: 751, column: 9, scope: !3228)
!3245 = !DILocation(line: 751, column: 11, scope: !3228)
!3246 = !DILocation(line: 749, column: 9, scope: !3220)
!3247 = !DILocation(line: 751, column: 27, scope: !3228)
!3248 = !DILocation(line: 751, column: 20, scope: !3228)
!3249 = !DILocation(line: 752, column: 3, scope: !3216)
!3250 = !DILocation(line: 752, column: 3, scope: !3220)
!3251 = !DILocation(line: 747, column: 61, scope: !3216)
!3252 = !DILocation(line: 747, column: 21, scope: !3216)
!3253 = distinct !{!3253, !3218, !3254, !1769, !3255}
!3254 = !DILocation(line: 752, column: 3, scope: !3212)
!3255 = !{!"llvm.loop.name", !"VITIS_LOOP_747_1"}
!3256 = !DILocation(line: 753, column: 3, scope: !3205)
!3257 = !DILocalVariable(name: "a8_index", scope: !3205, file: !3, line: 753, type: !95)
!3258 = !DILocation(line: 753, column: 12, scope: !3205)
!3259 = !DILocation(line: 753, column: 34, scope: !3205)
!3260 = !DILocation(line: 753, column: 47, scope: !3205)
!3261 = !DILocation(line: 753, column: 23, scope: !3205)
!3262 = !DILocation(line: 754, column: 3, scope: !3205)
!3263 = !DILocalVariable(name: "numeric_ref", scope: !3205, file: !3, line: 754, type: !3264)
!3264 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !96)
!3265 = !DILocation(line: 754, column: 19, scope: !3205)
!3266 = !DILocation(line: 754, column: 33, scope: !3205)
!3267 = !DILocation(line: 754, column: 36, scope: !3205)
!3268 = !DILocation(line: 754, column: 42, scope: !3205)
!3269 = !DILocation(line: 754, column: 58, scope: !3205)
!3270 = !DILocation(line: 755, column: 19, scope: !3271)
!3271 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 755, column: 7)
!3272 = !DILocation(line: 755, column: 22, scope: !3271)
!3273 = !DILocation(line: 755, column: 36, scope: !3271)
!3274 = !DILocation(line: 755, column: 51, scope: !3271)
!3275 = !DILocation(line: 755, column: 39, scope: !3271)
!3276 = !DILocation(line: 755, column: 56, scope: !3271)
!3277 = !DILocation(line: 755, column: 61, scope: !3271)
!3278 = !DILocation(line: 756, column: 19, scope: !3271)
!3279 = !DILocation(line: 756, column: 7, scope: !3271)
!3280 = !DILocation(line: 756, column: 25, scope: !3271)
!3281 = !DILocation(line: 756, column: 28, scope: !3271)
!3282 = !DILocation(line: 756, column: 37, scope: !3271)
!3283 = !DILocation(line: 755, column: 7, scope: !3205)
!3284 = !DILocation(line: 757, column: 28, scope: !3285)
!3285 = distinct !DILexicalBlock(scope: !3271, file: !3, line: 756, column: 55)
!3286 = !DILocation(line: 757, column: 16, scope: !3285)
!3287 = !DILocation(line: 757, column: 14, scope: !3285)
!3288 = !DILocation(line: 758, column: 9, scope: !3289)
!3289 = distinct !DILexicalBlock(scope: !3285, file: !3, line: 758, column: 9)
!3290 = !DILocation(line: 758, column: 18, scope: !3289)
!3291 = !DILocation(line: 758, column: 9, scope: !3285)
!3292 = !DILocation(line: 758, column: 43, scope: !3289)
!3293 = !DILocation(line: 758, column: 36, scope: !3289)
!3294 = !DILocation(line: 759, column: 5, scope: !3285)
!3295 = !DILocalVariable(name: "a8", scope: !3285, file: !3, line: 759, type: !2384)
!3296 = !DILocation(line: 759, column: 22, scope: !3285)
!3297 = !DILocation(line: 759, column: 27, scope: !3285)
!3298 = !DILocation(line: 759, column: 30, scope: !3285)
!3299 = !DILocation(line: 759, column: 37, scope: !3285)
!3300 = !DILocation(line: 759, column: 44, scope: !3285)
!3301 = !DILocation(line: 760, column: 5, scope: !3285)
!3302 = !DILocation(line: 760, column: 8, scope: !3285)
!3303 = !DILocation(line: 760, column: 12, scope: !3285)
!3304 = !DILocation(line: 761, column: 40, scope: !3285)
!3305 = !DILocation(line: 761, column: 5, scope: !3285)
!3306 = !DILocation(line: 761, column: 8, scope: !3285)
!3307 = !DILocation(line: 761, column: 26, scope: !3285)
!3308 = !DILocation(line: 762, column: 5, scope: !3285)
!3309 = !DILocation(line: 762, column: 8, scope: !3285)
!3310 = !DILocation(line: 762, column: 14, scope: !3285)
!3311 = !DILocation(line: 763, column: 3, scope: !3271)
!3312 = !DILocation(line: 763, column: 3, scope: !3285)
!3313 = !DILocation(line: 764, column: 7, scope: !3314)
!3314 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 764, column: 7)
!3315 = !DILocation(line: 764, column: 16, scope: !3314)
!3316 = !DILocation(line: 764, column: 7, scope: !3205)
!3317 = !DILocation(line: 765, column: 5, scope: !3318)
!3318 = distinct !DILexicalBlock(scope: !3314, file: !3, line: 764, column: 34)
!3319 = !DILocalVariable(name: "a8", scope: !3318, file: !3, line: 765, type: !2384)
!3320 = !DILocation(line: 765, column: 22, scope: !3318)
!3321 = !DILocation(line: 765, column: 27, scope: !3318)
!3322 = !DILocation(line: 765, column: 30, scope: !3318)
!3323 = !DILocation(line: 765, column: 37, scope: !3318)
!3324 = !DILocation(line: 765, column: 44, scope: !3318)
!3325 = !DILocation(line: 766, column: 5, scope: !3318)
!3326 = !DILocalVariable(name: "high", scope: !3318, file: !3, line: 766, type: !93)
!3327 = !DILocation(line: 766, column: 14, scope: !3318)
!3328 = !DILocation(line: 766, column: 21, scope: !3318)
!3329 = !DILocation(line: 766, column: 24, scope: !3318)
!3330 = !DILocation(line: 767, column: 21, scope: !3331)
!3331 = distinct !DILexicalBlock(scope: !3318, file: !3, line: 767, column: 9)
!3332 = !DILocation(line: 767, column: 24, scope: !3331)
!3333 = !DILocation(line: 767, column: 38, scope: !3331)
!3334 = !DILocation(line: 767, column: 53, scope: !3331)
!3335 = !DILocation(line: 767, column: 41, scope: !3331)
!3336 = !DILocation(line: 767, column: 58, scope: !3331)
!3337 = !DILocation(line: 767, column: 63, scope: !3331)
!3338 = !DILocation(line: 768, column: 21, scope: !3331)
!3339 = !DILocation(line: 768, column: 29, scope: !3331)
!3340 = !DILocation(line: 768, column: 27, scope: !3331)
!3341 = !DILocation(line: 767, column: 9, scope: !3318)
!3342 = !DILocation(line: 768, column: 54, scope: !3331)
!3343 = !DILocation(line: 768, column: 40, scope: !3331)
!3344 = !DILocation(line: 768, column: 35, scope: !3331)
!3345 = !DILocation(line: 769, column: 20, scope: !3318)
!3346 = !DILocation(line: 769, column: 5, scope: !3318)
!3347 = !DILocation(line: 769, column: 8, scope: !3318)
!3348 = !DILocation(line: 769, column: 12, scope: !3318)
!3349 = !DILocation(line: 769, column: 18, scope: !3318)
!3350 = !DILocation(line: 770, column: 28, scope: !3318)
!3351 = !DILocation(line: 770, column: 5, scope: !3318)
!3352 = !DILocation(line: 770, column: 8, scope: !3318)
!3353 = !DILocation(line: 770, column: 26, scope: !3318)
!3354 = !DILocation(line: 771, column: 36, scope: !3318)
!3355 = !DILocation(line: 771, column: 52, scope: !3318)
!3356 = !DILocation(line: 771, column: 5, scope: !3318)
!3357 = !DILocation(line: 771, column: 8, scope: !3318)
!3358 = !DILocation(line: 771, column: 14, scope: !3318)
!3359 = !DILocation(line: 771, column: 30, scope: !3318)
!3360 = !DILocation(line: 771, column: 34, scope: !3318)
!3361 = !DILocation(line: 772, column: 3, scope: !3314)
!3362 = !DILocation(line: 772, column: 3, scope: !3318)
!3363 = !DILocation(line: 764, column: 19, scope: !3314)
!3364 = !DILocation(line: 773, column: 26, scope: !3365)
!3365 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 773, column: 21)
!3366 = !DILocalVariable(name: "i", scope: !3365, file: !3, line: 773, type: !95)
!3367 = !DILocation(line: 773, column: 35, scope: !3365)
!3368 = !DILocation(line: 773, column: 42, scope: !3369)
!3369 = distinct !DILexicalBlock(scope: !3365, file: !3, line: 773, column: 21)
!3370 = !DILocation(line: 773, column: 44, scope: !3369)
!3371 = !DILocation(line: 773, column: 21, scope: !3365)
!3372 = !DILocation(line: 773, column: 21, scope: !3369)
!3373 = !DILocation(line: 774, column: 5, scope: !3374)
!3374 = distinct !DILexicalBlock(scope: !3369, file: !3, line: 773, column: 66)
!3375 = !DILocalVariable(name: "r", scope: !3374, file: !3, line: 774, type: !2384)
!3376 = !DILocation(line: 774, column: 22, scope: !3374)
!3377 = !DILocation(line: 774, column: 26, scope: !3374)
!3378 = !DILocation(line: 774, column: 29, scope: !3374)
!3379 = !DILocation(line: 774, column: 36, scope: !3374)
!3380 = !DILocation(line: 774, column: 43, scope: !3374)
!3381 = !DILocation(line: 775, column: 5, scope: !3374)
!3382 = !DILocation(line: 775, column: 7, scope: !3374)
!3383 = !DILocation(line: 775, column: 13, scope: !3374)
!3384 = !DILocation(line: 776, column: 5, scope: !3374)
!3385 = !DILocation(line: 776, column: 7, scope: !3374)
!3386 = !DILocation(line: 776, column: 13, scope: !3374)
!3387 = !DILocation(line: 777, column: 5, scope: !3374)
!3388 = !DILocation(line: 777, column: 7, scope: !3374)
!3389 = !DILocation(line: 777, column: 15, scope: !3374)
!3390 = !DILocation(line: 778, column: 23, scope: !3374)
!3391 = !DILocation(line: 778, column: 5, scope: !3374)
!3392 = !DILocation(line: 778, column: 7, scope: !3374)
!3393 = !DILocation(line: 778, column: 21, scope: !3374)
!3394 = !DILocation(line: 779, column: 16, scope: !3374)
!3395 = !DILocation(line: 779, column: 18, scope: !3374)
!3396 = !DILocation(line: 779, column: 5, scope: !3374)
!3397 = !DILocation(line: 780, column: 16, scope: !3374)
!3398 = !DILocation(line: 780, column: 18, scope: !3374)
!3399 = !DILocation(line: 780, column: 5, scope: !3374)
!3400 = !DILocation(line: 781, column: 3, scope: !3369)
!3401 = !DILocation(line: 781, column: 3, scope: !3374)
!3402 = !DILocation(line: 773, column: 61, scope: !3369)
!3403 = distinct !{!3403, !3371, !3404, !1769, !3405}
!3404 = !DILocation(line: 781, column: 3, scope: !3365)
!3405 = !{!"llvm.loop.name", !"VITIS_LOOP_773_2"}
!3406 = !DILocation(line: 782, column: 40, scope: !3407)
!3407 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 782, column: 21)
!3408 = !DILocalVariable(name: "__range2", scope: !3407, type: !2768, flags: DIFlagArtificial)
!3409 = !DILocation(line: 0, scope: !3407)
!3410 = !DILocation(line: 782, column: 43, scope: !3407)
!3411 = !DILocation(line: 782, column: 50, scope: !3407)
!3412 = !DILocation(line: 782, column: 38, scope: !3407)
!3413 = !DILocalVariable(name: "__begin2", scope: !3407, type: !2774, flags: DIFlagArtificial)
!3414 = !DILocalVariable(name: "__end2", scope: !3407, type: !2774, flags: DIFlagArtificial)
!3415 = !DILocation(line: 782, column: 26, scope: !3416)
!3416 = distinct !DILexicalBlock(scope: !3407, file: !3, line: 782, column: 21)
!3417 = !DILocalVariable(name: "shard", scope: !3416, file: !3, line: 782, type: !2781)
!3418 = !DILocation(line: 782, column: 32, scope: !3416)
!3419 = !DILocation(line: 782, column: 38, scope: !3416)
!3420 = !DILocation(line: 783, column: 42, scope: !3421)
!3421 = distinct !DILexicalBlock(scope: !3416, file: !3, line: 783, column: 23)
!3422 = !DILocalVariable(name: "__range3", scope: !3421, type: !2781, flags: DIFlagArtificial)
!3423 = !DILocation(line: 0, scope: !3421)
!3424 = !DILocation(line: 783, column: 40, scope: !3421)
!3425 = !DILocalVariable(name: "__begin3", scope: !3421, type: !2790, flags: DIFlagArtificial)
!3426 = !DILocalVariable(name: "__end3", scope: !3421, type: !2790, flags: DIFlagArtificial)
!3427 = !DILocation(line: 783, column: 28, scope: !3428)
!3428 = distinct !DILexicalBlock(scope: !3421, file: !3, line: 783, column: 23)
!3429 = !DILocalVariable(name: "plane", scope: !3428, file: !3, line: 783, type: !1966)
!3430 = !DILocation(line: 783, column: 34, scope: !3428)
!3431 = !DILocation(line: 783, column: 40, scope: !3428)
!3432 = !DILocation(line: 784, column: 43, scope: !3433)
!3433 = distinct !DILexicalBlock(scope: !3428, file: !3, line: 784, column: 25)
!3434 = !DILocalVariable(name: "__range4", scope: !3433, type: !1966, flags: DIFlagArtificial)
!3435 = !DILocation(line: 0, scope: !3433)
!3436 = !DILocation(line: 784, column: 41, scope: !3433)
!3437 = !DILocalVariable(name: "__begin4", scope: !3433, type: !1972, flags: DIFlagArtificial)
!3438 = !DILocalVariable(name: "__end4", scope: !3433, type: !1972, flags: DIFlagArtificial)
!3439 = !DILocation(line: 784, column: 30, scope: !3440)
!3440 = distinct !DILexicalBlock(scope: !3433, file: !3, line: 784, column: 25)
!3441 = !DILocalVariable(name: "head", scope: !3440, file: !3, line: 784, type: !1979)
!3442 = !DILocation(line: 784, column: 36, scope: !3440)
!3443 = !DILocation(line: 784, column: 41, scope: !3440)
!3444 = !DILocation(line: 785, column: 46, scope: !3445)
!3445 = distinct !DILexicalBlock(scope: !3440, file: !3, line: 785, column: 27)
!3446 = !DILocalVariable(name: "__range5", scope: !3445, type: !1979, flags: DIFlagArtificial)
!3447 = !DILocation(line: 0, scope: !3445)
!3448 = !DILocation(line: 785, column: 44, scope: !3445)
!3449 = !DILocalVariable(name: "__begin5", scope: !3445, type: !1988, flags: DIFlagArtificial)
!3450 = !DILocalVariable(name: "__end5", scope: !3445, type: !1988, flags: DIFlagArtificial)
!3451 = !DILocation(line: 785, column: 32, scope: !3452)
!3452 = distinct !DILexicalBlock(scope: !3445, file: !3, line: 785, column: 27)
!3453 = !DILocalVariable(name: "batch", scope: !3452, file: !3, line: 785, type: !1994)
!3454 = !DILocation(line: 785, column: 38, scope: !3452)
!3455 = !DILocation(line: 785, column: 44, scope: !3452)
!3456 = !DILocation(line: 786, column: 51, scope: !3457)
!3457 = distinct !DILexicalBlock(scope: !3452, file: !3, line: 786, column: 29)
!3458 = !DILocalVariable(name: "__range6", scope: !3457, type: !1994, flags: DIFlagArtificial)
!3459 = !DILocation(line: 0, scope: !3457)
!3460 = !DILocation(line: 786, column: 49, scope: !3457)
!3461 = !DILocalVariable(name: "__begin6", scope: !3457, type: !2003, flags: DIFlagArtificial)
!3462 = !DILocalVariable(name: "__end6", scope: !3457, type: !2003, flags: DIFlagArtificial)
!3463 = !DILocation(line: 786, column: 34, scope: !3464)
!3464 = distinct !DILexicalBlock(scope: !3457, file: !3, line: 786, column: 29)
!3465 = !DILocalVariable(name: "word", scope: !3464, file: !3, line: 786, type: !2008)
!3466 = !DILocation(line: 786, column: 44, scope: !3464)
!3467 = !DILocation(line: 786, column: 49, scope: !3464)
!3468 = !DILocation(line: 786, column: 58, scope: !3464)
!3469 = !DILocation(line: 786, column: 63, scope: !3464)
!3470 = !DILocation(line: 786, column: 65, scope: !3457)
!3471 = !DILocation(line: 786, column: 29, scope: !3457)
!3472 = distinct !{!3472, !3471, !3470, !3473}
!3473 = !{!"llvm.loop.name", !"VITIS_LOOP_786_7"}
!3474 = !DILocation(line: 786, column: 65, scope: !3445)
!3475 = !DILocation(line: 785, column: 27, scope: !3445)
!3476 = distinct !{!3476, !3475, !3474, !3477}
!3477 = !{!"llvm.loop.name", !"VITIS_LOOP_785_6"}
!3478 = !DILocation(line: 786, column: 65, scope: !3433)
!3479 = !DILocation(line: 784, column: 25, scope: !3433)
!3480 = distinct !{!3480, !3479, !3478, !3481}
!3481 = !{!"llvm.loop.name", !"VITIS_LOOP_784_5"}
!3482 = !DILocation(line: 786, column: 65, scope: !3421)
!3483 = !DILocation(line: 783, column: 23, scope: !3421)
!3484 = distinct !{!3484, !3483, !3482, !3485}
!3485 = !{!"llvm.loop.name", !"VITIS_LOOP_783_4"}
!3486 = !DILocation(line: 786, column: 65, scope: !3407)
!3487 = !DILocation(line: 782, column: 21, scope: !3407)
!3488 = distinct !{!3488, !3487, !3486, !3489}
!3489 = !{!"llvm.loop.name", !"VITIS_LOOP_782_3"}
!3490 = !DILocation(line: 787, column: 40, scope: !3491)
!3491 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 787, column: 21)
!3492 = !DILocalVariable(name: "__range2", scope: !3491, type: !2858, flags: DIFlagArtificial)
!3493 = !DILocation(line: 0, scope: !3491)
!3494 = !DILocation(line: 787, column: 43, scope: !3491)
!3495 = !DILocation(line: 787, column: 50, scope: !3491)
!3496 = !DILocation(line: 787, column: 38, scope: !3491)
!3497 = !DILocalVariable(name: "__begin2", scope: !3491, type: !2864, flags: DIFlagArtificial)
!3498 = !DILocalVariable(name: "__end2", scope: !3491, type: !2864, flags: DIFlagArtificial)
!3499 = !DILocation(line: 787, column: 26, scope: !3500)
!3500 = distinct !DILexicalBlock(scope: !3491, file: !3, line: 787, column: 21)
!3501 = !DILocalVariable(name: "shard", scope: !3500, file: !3, line: 787, type: !2871)
!3502 = !DILocation(line: 787, column: 32, scope: !3500)
!3503 = !DILocation(line: 787, column: 38, scope: !3500)
!3504 = !DILocation(line: 788, column: 42, scope: !3505)
!3505 = distinct !DILexicalBlock(scope: !3500, file: !3, line: 788, column: 23)
!3506 = !DILocalVariable(name: "__range3", scope: !3505, type: !2871, flags: DIFlagArtificial)
!3507 = !DILocation(line: 0, scope: !3505)
!3508 = !DILocation(line: 788, column: 40, scope: !3505)
!3509 = !DILocalVariable(name: "__begin3", scope: !3505, type: !2790, flags: DIFlagArtificial)
!3510 = !DILocalVariable(name: "__end3", scope: !3505, type: !2790, flags: DIFlagArtificial)
!3511 = !DILocation(line: 788, column: 28, scope: !3512)
!3512 = distinct !DILexicalBlock(scope: !3505, file: !3, line: 788, column: 23)
!3513 = !DILocalVariable(name: "plane", scope: !3512, file: !3, line: 788, type: !1966)
!3514 = !DILocation(line: 788, column: 34, scope: !3512)
!3515 = !DILocation(line: 788, column: 40, scope: !3512)
!3516 = !DILocation(line: 789, column: 44, scope: !3517)
!3517 = distinct !DILexicalBlock(scope: !3512, file: !3, line: 789, column: 26)
!3518 = !DILocalVariable(name: "__range4", scope: !3517, type: !1966, flags: DIFlagArtificial)
!3519 = !DILocation(line: 0, scope: !3517)
!3520 = !DILocation(line: 789, column: 42, scope: !3517)
!3521 = !DILocalVariable(name: "__begin4", scope: !3517, type: !1972, flags: DIFlagArtificial)
!3522 = !DILocalVariable(name: "__end4", scope: !3517, type: !1972, flags: DIFlagArtificial)
!3523 = !DILocation(line: 789, column: 31, scope: !3524)
!3524 = distinct !DILexicalBlock(scope: !3517, file: !3, line: 789, column: 26)
!3525 = !DILocalVariable(name: "head", scope: !3524, file: !3, line: 789, type: !1979)
!3526 = !DILocation(line: 789, column: 37, scope: !3524)
!3527 = !DILocation(line: 789, column: 42, scope: !3524)
!3528 = !DILocation(line: 790, column: 47, scope: !3529)
!3529 = distinct !DILexicalBlock(scope: !3524, file: !3, line: 790, column: 28)
!3530 = !DILocalVariable(name: "__range5", scope: !3529, type: !1979, flags: DIFlagArtificial)
!3531 = !DILocation(line: 0, scope: !3529)
!3532 = !DILocation(line: 790, column: 45, scope: !3529)
!3533 = !DILocalVariable(name: "__begin5", scope: !3529, type: !1988, flags: DIFlagArtificial)
!3534 = !DILocalVariable(name: "__end5", scope: !3529, type: !1988, flags: DIFlagArtificial)
!3535 = !DILocation(line: 790, column: 33, scope: !3536)
!3536 = distinct !DILexicalBlock(scope: !3529, file: !3, line: 790, column: 28)
!3537 = !DILocalVariable(name: "batch", scope: !3536, file: !3, line: 790, type: !1994)
!3538 = !DILocation(line: 790, column: 39, scope: !3536)
!3539 = !DILocation(line: 790, column: 45, scope: !3536)
!3540 = !DILocation(line: 791, column: 52, scope: !3541)
!3541 = distinct !DILexicalBlock(scope: !3536, file: !3, line: 791, column: 30)
!3542 = !DILocalVariable(name: "__range6", scope: !3541, type: !1994, flags: DIFlagArtificial)
!3543 = !DILocation(line: 0, scope: !3541)
!3544 = !DILocation(line: 791, column: 50, scope: !3541)
!3545 = !DILocalVariable(name: "__begin6", scope: !3541, type: !2003, flags: DIFlagArtificial)
!3546 = !DILocalVariable(name: "__end6", scope: !3541, type: !2003, flags: DIFlagArtificial)
!3547 = !DILocation(line: 791, column: 35, scope: !3548)
!3548 = distinct !DILexicalBlock(scope: !3541, file: !3, line: 791, column: 30)
!3549 = !DILocalVariable(name: "word", scope: !3548, file: !3, line: 791, type: !2008)
!3550 = !DILocation(line: 791, column: 45, scope: !3548)
!3551 = !DILocation(line: 791, column: 50, scope: !3548)
!3552 = !DILocation(line: 791, column: 59, scope: !3548)
!3553 = !DILocation(line: 791, column: 64, scope: !3548)
!3554 = !DILocation(line: 791, column: 66, scope: !3541)
!3555 = !DILocation(line: 791, column: 30, scope: !3541)
!3556 = distinct !{!3556, !3555, !3554, !3557}
!3557 = !{!"llvm.loop.name", !"VITIS_LOOP_791_12"}
!3558 = !DILocation(line: 791, column: 66, scope: !3529)
!3559 = !DILocation(line: 790, column: 28, scope: !3529)
!3560 = distinct !{!3560, !3559, !3558, !3561}
!3561 = !{!"llvm.loop.name", !"VITIS_LOOP_790_11"}
!3562 = !DILocation(line: 791, column: 66, scope: !3517)
!3563 = !DILocation(line: 789, column: 26, scope: !3517)
!3564 = distinct !{!3564, !3563, !3562, !3565}
!3565 = !{!"llvm.loop.name", !"VITIS_LOOP_789_10"}
!3566 = !DILocation(line: 791, column: 66, scope: !3505)
!3567 = !DILocation(line: 788, column: 23, scope: !3505)
!3568 = distinct !{!3568, !3567, !3566, !3569}
!3569 = !{!"llvm.loop.name", !"VITIS_LOOP_788_9"}
!3570 = !DILocation(line: 791, column: 66, scope: !3491)
!3571 = !DILocation(line: 787, column: 21, scope: !3491)
!3572 = distinct !{!3572, !3571, !3570, !3573}
!3573 = !{!"llvm.loop.name", !"VITIS_LOOP_787_8"}
!3574 = !DILocation(line: 792, column: 40, scope: !3575)
!3575 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 792, column: 22)
!3576 = !DILocalVariable(name: "__range2", scope: !3575, type: !1966, flags: DIFlagArtificial)
!3577 = !DILocation(line: 0, scope: !3575)
!3578 = !DILocation(line: 792, column: 43, scope: !3575)
!3579 = !DILocation(line: 792, column: 50, scope: !3575)
!3580 = !DILocation(line: 792, column: 38, scope: !3575)
!3581 = !DILocalVariable(name: "__begin2", scope: !3575, type: !1972, flags: DIFlagArtificial)
!3582 = !DILocalVariable(name: "__end2", scope: !3575, type: !1972, flags: DIFlagArtificial)
!3583 = !DILocation(line: 792, column: 27, scope: !3584)
!3584 = distinct !DILexicalBlock(scope: !3575, file: !3, line: 792, column: 22)
!3585 = !DILocalVariable(name: "head", scope: !3584, file: !3, line: 792, type: !1979)
!3586 = !DILocation(line: 792, column: 33, scope: !3584)
!3587 = !DILocation(line: 792, column: 38, scope: !3584)
!3588 = !DILocation(line: 793, column: 43, scope: !3589)
!3589 = distinct !DILexicalBlock(scope: !3584, file: !3, line: 793, column: 24)
!3590 = !DILocalVariable(name: "__range3", scope: !3589, type: !1979, flags: DIFlagArtificial)
!3591 = !DILocation(line: 0, scope: !3589)
!3592 = !DILocation(line: 793, column: 41, scope: !3589)
!3593 = !DILocalVariable(name: "__begin3", scope: !3589, type: !1988, flags: DIFlagArtificial)
!3594 = !DILocalVariable(name: "__end3", scope: !3589, type: !1988, flags: DIFlagArtificial)
!3595 = !DILocation(line: 793, column: 29, scope: !3596)
!3596 = distinct !DILexicalBlock(scope: !3589, file: !3, line: 793, column: 24)
!3597 = !DILocalVariable(name: "batch", scope: !3596, file: !3, line: 793, type: !1994)
!3598 = !DILocation(line: 793, column: 35, scope: !3596)
!3599 = !DILocation(line: 793, column: 41, scope: !3596)
!3600 = !DILocation(line: 794, column: 48, scope: !3601)
!3601 = distinct !DILexicalBlock(scope: !3596, file: !3, line: 794, column: 26)
!3602 = !DILocalVariable(name: "__range4", scope: !3601, type: !1994, flags: DIFlagArtificial)
!3603 = !DILocation(line: 0, scope: !3601)
!3604 = !DILocation(line: 794, column: 46, scope: !3601)
!3605 = !DILocalVariable(name: "__begin4", scope: !3601, type: !2003, flags: DIFlagArtificial)
!3606 = !DILocalVariable(name: "__end4", scope: !3601, type: !2003, flags: DIFlagArtificial)
!3607 = !DILocation(line: 794, column: 31, scope: !3608)
!3608 = distinct !DILexicalBlock(scope: !3601, file: !3, line: 794, column: 26)
!3609 = !DILocalVariable(name: "word", scope: !3608, file: !3, line: 794, type: !2008)
!3610 = !DILocation(line: 794, column: 41, scope: !3608)
!3611 = !DILocation(line: 794, column: 46, scope: !3608)
!3612 = !DILocation(line: 794, column: 55, scope: !3608)
!3613 = !DILocation(line: 794, column: 60, scope: !3608)
!3614 = !DILocation(line: 794, column: 62, scope: !3601)
!3615 = !DILocation(line: 794, column: 26, scope: !3601)
!3616 = distinct !{!3616, !3615, !3614, !3617}
!3617 = !{!"llvm.loop.name", !"VITIS_LOOP_794_15"}
!3618 = !DILocation(line: 794, column: 62, scope: !3589)
!3619 = !DILocation(line: 793, column: 24, scope: !3589)
!3620 = distinct !{!3620, !3619, !3618, !3621}
!3621 = !{!"llvm.loop.name", !"VITIS_LOOP_793_14"}
!3622 = !DILocation(line: 794, column: 62, scope: !3575)
!3623 = !DILocation(line: 792, column: 22, scope: !3575)
!3624 = distinct !{!3624, !3623, !3622, !3625}
!3625 = !{!"llvm.loop.name", !"VITIS_LOOP_792_13"}
!3626 = !DILocation(line: 795, column: 27, scope: !3627)
!3627 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 795, column: 22)
!3628 = !DILocalVariable(name: "b", scope: !3627, file: !3, line: 795, type: !95)
!3629 = !DILocation(line: 795, column: 36, scope: !3627)
!3630 = !DILocation(line: 795, column: 43, scope: !3631)
!3631 = distinct !DILexicalBlock(scope: !3627, file: !3, line: 795, column: 22)
!3632 = !DILocation(line: 795, column: 45, scope: !3631)
!3633 = !DILocation(line: 795, column: 22, scope: !3627)
!3634 = !DILocation(line: 795, column: 22, scope: !3631)
!3635 = !DILocation(line: 796, column: 5, scope: !3636)
!3636 = distinct !DILexicalBlock(scope: !3631, file: !3, line: 795, column: 55)
!3637 = !DILocation(line: 796, column: 8, scope: !3636)
!3638 = !DILocation(line: 796, column: 15, scope: !3636)
!3639 = !DILocation(line: 796, column: 35, scope: !3636)
!3640 = !DILocation(line: 796, column: 38, scope: !3636)
!3641 = !DILocation(line: 797, column: 5, scope: !3636)
!3642 = !DILocation(line: 797, column: 8, scope: !3636)
!3643 = !DILocation(line: 797, column: 15, scope: !3636)
!3644 = !DILocation(line: 797, column: 34, scope: !3636)
!3645 = !DILocation(line: 797, column: 37, scope: !3636)
!3646 = !DILocation(line: 798, column: 3, scope: !3636)
!3647 = !DILocation(line: 795, column: 50, scope: !3631)
!3648 = distinct !{!3648, !3633, !3649, !1769, !3650}
!3649 = !DILocation(line: 798, column: 3, scope: !3627)
!3650 = !{!"llvm.loop.name", !"VITIS_LOOP_795_16"}
!3651 = !DILocation(line: 799, column: 37, scope: !3652)
!3652 = distinct !DILexicalBlock(scope: !3205, file: !3, line: 799, column: 22)
!3653 = !DILocalVariable(name: "__range2", scope: !3652, type: !1937, flags: DIFlagArtificial)
!3654 = !DILocation(line: 0, scope: !3652)
!3655 = !DILocation(line: 799, column: 40, scope: !3652)
!3656 = !DILocation(line: 799, column: 47, scope: !3652)
!3657 = !DILocation(line: 799, column: 35, scope: !3652)
!3658 = !DILocalVariable(name: "__begin2", scope: !3652, type: !1943, flags: DIFlagArtificial)
!3659 = !DILocalVariable(name: "__end2", scope: !3652, type: !1943, flags: DIFlagArtificial)
!3660 = !DILocation(line: 799, column: 27, scope: !3661)
!3661 = distinct !DILexicalBlock(scope: !3652, file: !3, line: 799, column: 22)
!3662 = !DILocalVariable(name: "v", scope: !3661, file: !3, line: 799, type: !1948)
!3663 = !DILocation(line: 799, column: 33, scope: !3661)
!3664 = !DILocation(line: 799, column: 35, scope: !3661)
!3665 = !DILocation(line: 799, column: 59, scope: !3661)
!3666 = !DILocation(line: 799, column: 61, scope: !3661)
!3667 = !DILocation(line: 799, column: 63, scope: !3652)
!3668 = !DILocation(line: 799, column: 22, scope: !3652)
!3669 = distinct !{!3669, !3668, !3667, !3670}
!3670 = !{!"llvm.loop.name", !"VITIS_LOOP_799_17"}
!3671 = !DILocation(line: 800, column: 23, scope: !3205)
!3672 = !DILocation(line: 800, column: 43, scope: !3205)
!3673 = !DILocation(line: 52, column: 19, scope: !3674)
!3674 = !DILexicalBlockFile(scope: !3205, file: !1000, discriminator: 0)
!3675 = !DILocation(line: 800, column: 44, scope: !3676)
!3676 = !DILexicalBlockFile(scope: !3205, file: !3, discriminator: 0)
!3677 = !DILocation(line: 56, column: 24, scope: !3674)
!3678 = !DILocation(line: 56, column: 40, scope: !3674)
!3679 = !DILocation(line: 60, column: 31, scope: !3674)
!3680 = !DILocation(line: 61, column: 29, scope: !3674)
!3681 = !DILocation(line: 800, column: 3, scope: !3676)
!3682 = !DILocation(line: 800, column: 6, scope: !3676)
!3683 = !DILocation(line: 800, column: 21, scope: !3205)
!3684 = !DILocation(line: 800, column: 3, scope: !3205)
!3685 = !DILocation(line: 801, column: 27, scope: !3676)
!3686 = !DILocation(line: 801, column: 3, scope: !3676)
!3687 = !DILocation(line: 801, column: 6, scope: !3676)
!3688 = !DILocation(line: 801, column: 25, scope: !3676)
!3689 = !DILocation(line: 802, column: 28, scope: !3676)
!3690 = !DILocation(line: 802, column: 3, scope: !3676)
!3691 = !DILocation(line: 802, column: 6, scope: !3676)
!3692 = !DILocation(line: 802, column: 26, scope: !3676)
!3693 = !DILocation(line: 803, column: 28, scope: !3676)
!3694 = !DILocation(line: 803, column: 3, scope: !3676)
!3695 = !DILocation(line: 803, column: 6, scope: !3676)
!3696 = !DILocation(line: 803, column: 26, scope: !3676)
!3697 = !DILocation(line: 804, column: 25, scope: !3676)
!3698 = !DILocation(line: 804, column: 3, scope: !3676)
!3699 = !DILocation(line: 804, column: 6, scope: !3676)
!3700 = !DILocation(line: 804, column: 23, scope: !3676)
!3701 = !DILocation(line: 805, column: 25, scope: !3676)
!3702 = !DILocation(line: 805, column: 3, scope: !3676)
!3703 = !DILocation(line: 805, column: 6, scope: !3676)
!3704 = !DILocation(line: 805, column: 23, scope: !3676)
!3705 = !DILocation(line: 806, column: 22, scope: !3676)
!3706 = !DILocation(line: 806, column: 3, scope: !3676)
!3707 = !DILocation(line: 806, column: 6, scope: !3676)
!3708 = !DILocation(line: 806, column: 20, scope: !3676)
!3709 = !DILocation(line: 807, column: 24, scope: !3676)
!3710 = !DILocation(line: 807, column: 3, scope: !3676)
!3711 = !DILocation(line: 807, column: 6, scope: !3676)
!3712 = !DILocation(line: 807, column: 22, scope: !3676)
!3713 = !DILocation(line: 808, column: 3, scope: !3676)
!3714 = !DILocation(line: 808, column: 6, scope: !3676)
!3715 = !DILocation(line: 808, column: 23, scope: !3676)
!3716 = !DILocation(line: 809, column: 3, scope: !3676)
!3717 = !DILocation(line: 809, column: 6, scope: !3676)
!3718 = !DILocation(line: 809, column: 21, scope: !3676)
!3719 = !DILocation(line: 810, column: 18, scope: !3676)
!3720 = !DILocation(line: 810, column: 3, scope: !3676)
!3721 = !DILocation(line: 810, column: 6, scope: !3676)
!3722 = !DILocation(line: 810, column: 16, scope: !3676)
!3723 = !DILocation(line: 811, column: 21, scope: !3676)
!3724 = !DILocation(line: 811, column: 3, scope: !3676)
!3725 = !DILocation(line: 811, column: 6, scope: !3676)
!3726 = !DILocation(line: 811, column: 19, scope: !3676)
!3727 = !DILocation(line: 812, column: 25, scope: !3676)
!3728 = !DILocation(line: 812, column: 3, scope: !3676)
!3729 = !DILocation(line: 812, column: 6, scope: !3676)
!3730 = !DILocation(line: 812, column: 23, scope: !3676)
!3731 = !DILocation(line: 813, column: 25, scope: !3676)
!3732 = !DILocation(line: 813, column: 3, scope: !3676)
!3733 = !DILocation(line: 813, column: 6, scope: !3676)
!3734 = !DILocation(line: 813, column: 23, scope: !3676)
!3735 = !DILocation(line: 814, column: 3, scope: !3676)
!3736 = !DILocation(line: 814, column: 6, scope: !3676)
!3737 = !DILocation(line: 814, column: 17, scope: !3676)
!3738 = !DILocation(line: 815, column: 3, scope: !3676)
!3739 = !DILocation(line: 815, column: 6, scope: !3676)
!3740 = !DILocation(line: 815, column: 18, scope: !3676)
!3741 = !DILocation(line: 816, column: 3, scope: !3676)
!3742 = !DILocation(line: 816, column: 6, scope: !3676)
!3743 = !DILocation(line: 816, column: 17, scope: !3676)
!3744 = !DILocation(line: 817, column: 3, scope: !3676)
!3745 = !DILocation(line: 817, column: 6, scope: !3676)
!3746 = !DILocation(line: 817, column: 18, scope: !3676)
!3747 = !DILocation(line: 818, column: 20, scope: !3676)
!3748 = !DILocation(line: 818, column: 23, scope: !3676)
!3749 = !DILocation(line: 818, column: 29, scope: !3676)
!3750 = !DILocation(line: 818, column: 3, scope: !3676)
!3751 = !DILocation(line: 819, column: 21, scope: !3676)
!3752 = !DILocation(line: 819, column: 24, scope: !3676)
!3753 = !DILocation(line: 819, column: 30, scope: !3676)
!3754 = !DILocation(line: 819, column: 3, scope: !3676)
!3755 = !DILocation(line: 820, column: 3, scope: !3676)
!3756 = !DILocation(line: 820, column: 6, scope: !3676)
!3757 = !DILocation(line: 820, column: 20, scope: !3676)
!3758 = !DILocation(line: 821, column: 3, scope: !3676)
!3759 = !DILocation(line: 821, column: 6, scope: !3676)
!3760 = !DILocation(line: 821, column: 25, scope: !3676)
!3761 = !DILocation(line: 822, column: 30, scope: !3676)
!3762 = !DILocation(line: 822, column: 43, scope: !3676)
!3763 = !DILocation(line: 822, column: 44, scope: !3676)
!3764 = !DILocation(line: 822, column: 3, scope: !3676)
!3765 = !DILocation(line: 822, column: 6, scope: !3676)
!3766 = !DILocation(line: 822, column: 28, scope: !3676)
!3767 = !DILocation(line: 823, column: 3, scope: !3676)
!3768 = !DILocation(line: 823, column: 6, scope: !3676)
!3769 = !DILocation(line: 823, column: 34, scope: !3676)
!3770 = !DILocation(line: 824, column: 3, scope: !3676)
!3771 = !DILocation(line: 824, column: 6, scope: !3676)
!3772 = !DILocation(line: 824, column: 33, scope: !3676)
!3773 = !DILocation(line: 825, column: 3, scope: !3676)
!3774 = !DILocation(line: 825, column: 6, scope: !3676)
!3775 = !DILocation(line: 825, column: 19, scope: !3676)
!3776 = !DILocation(line: 826, column: 3, scope: !3676)
!3777 = !DILocation(line: 826, column: 6, scope: !3676)
!3778 = !DILocation(line: 826, column: 20, scope: !3676)
!3779 = !DILocation(line: 827, column: 45, scope: !3780)
!3780 = distinct !DILexicalBlock(scope: !3676, file: !3, line: 827, column: 22)
!3781 = !DILocalVariable(name: "__range2", scope: !3780, type: !3782, flags: DIFlagArtificial)
!3782 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1186, size: 64)
!3783 = !DILocation(line: 0, scope: !3780)
!3784 = !DILocation(line: 827, column: 48, scope: !3780)
!3785 = !DILocation(line: 827, column: 43, scope: !3780)
!3786 = !DILocalVariable(name: "__begin2", scope: !3780, type: !2003, flags: DIFlagArtificial)
!3787 = !DILocalVariable(name: "__end2", scope: !3780, type: !2003, flags: DIFlagArtificial)
!3788 = !DILocation(line: 827, column: 27, scope: !3789)
!3789 = distinct !DILexicalBlock(scope: !3780, file: !3, line: 827, column: 22)
!3790 = !DILocalVariable(name: "count", scope: !3789, file: !3, line: 827, type: !2008)
!3791 = !DILocation(line: 827, column: 37, scope: !3789)
!3792 = !DILocation(line: 827, column: 43, scope: !3789)
!3793 = !DILocation(line: 827, column: 58, scope: !3789)
!3794 = !DILocation(line: 827, column: 64, scope: !3789)
!3795 = !DILocation(line: 827, column: 66, scope: !3780)
!3796 = !DILocation(line: 827, column: 22, scope: !3780)
!3797 = distinct !{!3797, !3796, !3795, !3798}
!3798 = !{!"llvm.loop.name", !"VITIS_LOOP_827_18"}
!3799 = !DILocation(line: 828, column: 3, scope: !3676)
!3800 = !DILocation(line: 828, column: 6, scope: !3676)
!3801 = !DILocation(line: 828, column: 19, scope: !3676)
!3802 = !DILocation(line: 829, column: 3, scope: !3676)
!3803 = !DILocation(line: 829, column: 6, scope: !3676)
!3804 = !DILocation(line: 829, column: 19, scope: !3676)
!3805 = !DILocation(line: 830, column: 3, scope: !3676)
!3806 = !DILocation(line: 830, column: 6, scope: !3676)
!3807 = !DILocation(line: 830, column: 31, scope: !3676)
!3808 = !DILocation(line: 831, column: 3, scope: !3676)
!3809 = !DILocation(line: 831, column: 6, scope: !3676)
!3810 = !DILocation(line: 831, column: 32, scope: !3676)
!3811 = !DILocation(line: 832, column: 10, scope: !3676)
!3812 = !DILocation(line: 832, column: 3, scope: !3676)
!3813 = !DILocation(line: 833, column: 1, scope: !3676)
!3814 = distinct !DISubprogram(name: "full_soft_reset", linkageName: "_ZN4laya4full15full_soft_resetERNS0_11FullRuntimeEm", scope: !5, file: !3, line: 835, type: !3815, scopeLine: 835, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !44, retainedNodes: !990)
!3815 = !DISubroutineType(types: !3816)
!3816 = !{!1202, !1870, !160}
!3817 = !DILocalVariable(name: "rt", arg: 1, scope: !3814, file: !3, line: 835, type: !1870)
!3818 = !DILocation(line: 835, column: 36, scope: !3814)
!3819 = !DILocalVariable(name: "new_generation", arg: 2, scope: !3814, file: !3, line: 835, type: !160)
!3820 = !DILocation(line: 835, column: 49, scope: !3814)
!3821 = !DILocation(line: 836, column: 8, scope: !3822)
!3822 = distinct !DILexicalBlock(scope: !3814, file: !3, line: 836, column: 7)
!3823 = !DILocation(line: 836, column: 23, scope: !3822)
!3824 = !DILocation(line: 837, column: 8, scope: !3822)
!3825 = !DILocation(line: 837, column: 11, scope: !3822)
!3826 = !DILocation(line: 837, column: 18, scope: !3822)
!3827 = !DILocation(line: 837, column: 27, scope: !3822)
!3828 = !DILocation(line: 837, column: 38, scope: !3822)
!3829 = !DILocation(line: 838, column: 8, scope: !3822)
!3830 = !DILocation(line: 838, column: 26, scope: !3822)
!3831 = !DILocation(line: 838, column: 29, scope: !3822)
!3832 = !DILocation(line: 838, column: 36, scope: !3822)
!3833 = !DILocation(line: 838, column: 45, scope: !3822)
!3834 = !DILocation(line: 838, column: 23, scope: !3822)
!3835 = !DILocation(line: 836, column: 7, scope: !3814)
!3836 = !DILocation(line: 838, column: 65, scope: !3822)
!3837 = !DILocation(line: 838, column: 58, scope: !3822)
!3838 = !DILocation(line: 839, column: 3, scope: !3814)
!3839 = !DILocalVariable(name: "c", scope: !3814, file: !3, line: 839, type: !1202)
!3840 = !DILocation(line: 839, column: 9, scope: !3814)
!3841 = !DILocation(line: 839, column: 34, scope: !3814)
!3842 = !DILocation(line: 839, column: 13, scope: !3814)
!3843 = !DILocation(line: 840, column: 8, scope: !3844)
!3844 = distinct !DILexicalBlock(scope: !3814, file: !3, line: 840, column: 7)
!3845 = !DILocation(line: 840, column: 7, scope: !3814)
!3846 = !DILocation(line: 840, column: 18, scope: !3844)
!3847 = !DILocation(line: 840, column: 11, scope: !3844)
!3848 = !DILocation(line: 841, column: 35, scope: !3814)
!3849 = !DILocation(line: 841, column: 3, scope: !3814)
!3850 = !DILocation(line: 841, column: 6, scope: !3814)
!3851 = !DILocation(line: 841, column: 13, scope: !3814)
!3852 = !DILocation(line: 841, column: 22, scope: !3814)
!3853 = !DILocation(line: 841, column: 33, scope: !3814)
!3854 = !DILocation(line: 842, column: 27, scope: !3814)
!3855 = !DILocation(line: 842, column: 3, scope: !3814)
!3856 = !DILocation(line: 842, column: 6, scope: !3814)
!3857 = !DILocation(line: 842, column: 25, scope: !3814)
!3858 = !DILocation(line: 843, column: 3, scope: !3814)
!3859 = !DILocation(line: 843, column: 6, scope: !3814)
!3860 = !DILocation(line: 843, column: 31, scope: !3814)
!3861 = !DILocation(line: 844, column: 10, scope: !3814)
!3862 = !DILocation(line: 844, column: 3, scope: !3814)
!3863 = !DILocation(line: 845, column: 1, scope: !3814)
!3864 = distinct !DISubprogram(name: "full_owner_index_pilot", scope: !998, file: !998, line: 18, type: !3865, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1461, retainedNodes: !990)
!3865 = !DISubroutineType(types: !3866)
!3866 = !{null, !16, !2003, !2003, !2003, !2003, !2003, !2003, !2003, !2003, !2003, !2003}
!3867 = !{!3868}
!3868 = !{!"fpga.top", !"user", !3869}
!3869 = !DILocation(line: 18, column: 27, scope: !3864)
!3870 = !DILocalVariable(name: "operation", arg: 1, scope: !3864, file: !998, line: 19, type: !16)
!3871 = !DILocation(line: 19, column: 13, scope: !3864)
!3872 = !DILocalVariable(name: "status", arg: 2, scope: !3864, file: !998, line: 19, type: !2003)
!3873 = !DILocation(line: 19, column: 34, scope: !3864)
!3874 = !DILocalVariable(name: "slot0_epoch", arg: 3, scope: !3864, file: !998, line: 19, type: !2003)
!3875 = !DILocation(line: 19, column: 52, scope: !3864)
!3876 = !DILocalVariable(name: "slot1_epoch", arg: 4, scope: !3864, file: !998, line: 20, type: !2003)
!3877 = !DILocation(line: 20, column: 15, scope: !3864)
!3878 = !DILocalVariable(name: "slot2_epoch", arg: 5, scope: !3864, file: !998, line: 20, type: !2003)
!3879 = !DILocation(line: 20, column: 38, scope: !3864)
!3880 = !DILocalVariable(name: "numeric_epoch", arg: 6, scope: !3864, file: !998, line: 20, type: !2003)
!3881 = !DILocation(line: 20, column: 61, scope: !3864)
!3882 = !DILocalVariable(name: "claims", arg: 7, scope: !3864, file: !998, line: 21, type: !2003)
!3883 = !DILocation(line: 21, column: 15, scope: !3864)
!3884 = !DILocalVariable(name: "slot0_coverage", arg: 8, scope: !3864, file: !998, line: 21, type: !2003)
!3885 = !DILocation(line: 21, column: 33, scope: !3864)
!3886 = !DILocalVariable(name: "slot2_id", arg: 9, scope: !3864, file: !998, line: 22, type: !2003)
!3887 = !DILocation(line: 22, column: 15, scope: !3864)
!3888 = !DILocalVariable(name: "request_high", arg: 10, scope: !3864, file: !998, line: 22, type: !2003)
!3889 = !DILocation(line: 22, column: 35, scope: !3864)
!3890 = !DILocalVariable(name: "generation", arg: 11, scope: !3864, file: !998, line: 22, type: !2003)
!3891 = !DILocation(line: 22, column: 59, scope: !3864)
!3892 = !DILocation(line: 24, column: 1, scope: !3864)
!3893 = !DILocation(line: 25, column: 1, scope: !3864)
!3894 = !DILocation(line: 26, column: 1, scope: !3864)
!3895 = !DILocation(line: 27, column: 1, scope: !3864)
!3896 = !DILocation(line: 28, column: 1, scope: !3864)
!3897 = !DILocation(line: 29, column: 1, scope: !3864)
!3898 = !DILocation(line: 30, column: 1, scope: !3864)
!3899 = !DILocation(line: 31, column: 1, scope: !3864)
!3900 = !DILocation(line: 32, column: 1, scope: !3864)
!3901 = !DILocation(line: 33, column: 1, scope: !3864)
!3902 = !DILocation(line: 34, column: 1, scope: !3864)
!3903 = !DILocation(line: 35, column: 1, scope: !3864)
!3904 = !DILocation(line: 37, column: 3, scope: !3864)
!3905 = !DILocalVariable(name: "result", scope: !3864, file: !998, line: 37, type: !1202)
!3906 = !DILocation(line: 37, column: 9, scope: !3864)
!3907 = !DILocation(line: 37, column: 18, scope: !3864)
!3908 = !DILocation(line: 38, column: 11, scope: !3864)
!3909 = !DILocation(line: 38, column: 3, scope: !3864)
!3910 = !DILocation(line: 40, column: 40, scope: !3911)
!3911 = distinct !DILexicalBlock(scope: !3864, file: !998, line: 38, column: 22)
!3912 = !DILocation(line: 41, column: 40, scope: !3911)
!3913 = !DILocation(line: 42, column: 31, scope: !3911)
!3914 = !DILocation(line: 43, column: 31, scope: !3911)
!3915 = !DILocation(line: 44, column: 42, scope: !3911)
!3916 = !DILocation(line: 45, column: 44, scope: !3911)
!3917 = !DILocation(line: 46, column: 43, scope: !3911)
!3918 = !DILocation(line: 47, column: 42, scope: !3911)
!3919 = !DILocation(line: 48, column: 32, scope: !3911)
!3920 = !DILocation(line: 49, column: 38, scope: !3911)
!3921 = !DILocation(line: 50, column: 27, scope: !3911)
!3922 = !DILocation(line: 51, column: 32, scope: !3911)
!3923 = !DILocation(line: 52, column: 5, scope: !3911)
!3924 = !DILocation(line: 54, column: 5, scope: !3925)
!3925 = distinct !DILexicalBlock(scope: !3911, file: !998, line: 53, column: 11)
!3926 = !DILocalVariable(name: "pair", scope: !3925, file: !998, line: 54, type: !2680)
!3927 = !DILocation(line: 54, column: 31, scope: !3925)
!3928 = !DILocation(line: 54, column: 41, scope: !3925)
!3929 = !DILocation(line: 54, column: 42, scope: !3925)
!3930 = !DILocation(line: 54, column: 58, scope: !3925)
!3931 = !DILocation(line: 55, column: 14, scope: !3925)
!3932 = !DILocation(line: 55, column: 12, scope: !3925)
!3933 = !DILocation(line: 55, column: 5, scope: !3925)
!3934 = !DILocation(line: 57, column: 3, scope: !3911)
!3935 = !DILocation(line: 59, column: 14, scope: !3911)
!3936 = !DILocation(line: 59, column: 51, scope: !3911)
!3937 = !DILocation(line: 59, column: 12, scope: !3911)
!3938 = !DILocation(line: 59, column: 5, scope: !3911)
!3939 = !DILocation(line: 60, column: 5, scope: !3911)
!3940 = !DILocation(line: 62, column: 5, scope: !3941)
!3941 = distinct !DILexicalBlock(scope: !3911, file: !998, line: 61, column: 11)
!3942 = !DILocalVariable(name: "pair", scope: !3941, file: !998, line: 62, type: !2680)
!3943 = !DILocation(line: 62, column: 31, scope: !3941)
!3944 = !DILocation(line: 62, column: 41, scope: !3941)
!3945 = !DILocation(line: 62, column: 42, scope: !3941)
!3946 = !DILocation(line: 62, column: 58, scope: !3941)
!3947 = !DILocation(line: 63, column: 14, scope: !3941)
!3948 = !DILocation(line: 63, column: 12, scope: !3941)
!3949 = !DILocation(line: 63, column: 5, scope: !3941)
!3950 = !DILocation(line: 65, column: 3, scope: !3911)
!3951 = !DILocation(line: 67, column: 14, scope: !3911)
!3952 = !DILocation(line: 67, column: 12, scope: !3911)
!3953 = !DILocation(line: 67, column: 5, scope: !3911)
!3954 = !DILocation(line: 68, column: 5, scope: !3911)
!3955 = !DILocation(line: 70, column: 14, scope: !3911)
!3956 = !DILocation(line: 70, column: 51, scope: !3911)
!3957 = !DILocation(line: 70, column: 12, scope: !3911)
!3958 = !DILocation(line: 70, column: 5, scope: !3911)
!3959 = !DILocation(line: 71, column: 5, scope: !3911)
!3960 = !DILocation(line: 73, column: 14, scope: !3911)
!3961 = !DILocation(line: 73, column: 12, scope: !3911)
!3962 = !DILocation(line: 73, column: 5, scope: !3911)
!3963 = !DILocation(line: 74, column: 5, scope: !3911)
!3964 = !DILocation(line: 78, column: 27, scope: !3965)
!3965 = distinct !DILexicalBlock(scope: !3911, file: !998, line: 78, column: 22)
!3966 = !DILocalVariable(name: "i", scope: !3965, file: !998, line: 78, type: !95)
!3967 = !DILocation(line: 78, column: 36, scope: !3965)
!3968 = !DILocation(line: 78, column: 43, scope: !3969)
!3969 = distinct !DILexicalBlock(scope: !3965, file: !998, line: 78, column: 22)
!3970 = !DILocation(line: 78, column: 45, scope: !3969)
!3971 = !DILocation(line: 78, column: 22, scope: !3965)
!3972 = !DILocation(line: 78, column: 22, scope: !3969)
!3973 = !DILocation(line: 79, column: 38, scope: !3969)
!3974 = !DILocation(line: 79, column: 29, scope: !3969)
!3975 = !DILocation(line: 79, column: 7, scope: !3969)
!3976 = !DILocation(line: 79, column: 32, scope: !3969)
!3977 = !DILocation(line: 79, column: 36, scope: !3969)
!3978 = !DILocation(line: 78, column: 51, scope: !3969)
!3979 = distinct !{!3979, !3971, !3980, !1769, !3981}
!3980 = !DILocation(line: 79, column: 59, scope: !3965)
!3981 = !{!"llvm.loop.name", !"VITIS_LOOP_78_1"}
!3982 = !DILocation(line: 80, column: 46, scope: !3911)
!3983 = !DILocation(line: 81, column: 26, scope: !3911)
!3984 = !DILocation(line: 82, column: 41, scope: !3911)
!3985 = !DILocation(line: 82, column: 39, scope: !3911)
!3986 = !DILocation(line: 82, column: 5, scope: !3911)
!3987 = !DILocation(line: 83, column: 14, scope: !3911)
!3988 = !DILocation(line: 83, column: 12, scope: !3911)
!3989 = !DILocation(line: 83, column: 5, scope: !3911)
!3990 = !DILocation(line: 84, column: 5, scope: !3911)
!3991 = !DILocation(line: 86, column: 27, scope: !3992)
!3992 = distinct !DILexicalBlock(scope: !3911, file: !998, line: 86, column: 22)
!3993 = !DILocalVariable(name: "i", scope: !3992, file: !998, line: 86, type: !95)
!3994 = !DILocation(line: 86, column: 36, scope: !3992)
!3995 = !DILocation(line: 86, column: 43, scope: !3996)
!3996 = distinct !DILexicalBlock(scope: !3992, file: !998, line: 86, column: 22)
!3997 = !DILocation(line: 86, column: 45, scope: !3996)
!3998 = !DILocation(line: 86, column: 22, scope: !3992)
!3999 = !DILocation(line: 86, column: 22, scope: !3996)
!4000 = !DILocation(line: 87, column: 38, scope: !3996)
!4001 = !DILocation(line: 87, column: 29, scope: !3996)
!4002 = !DILocation(line: 87, column: 7, scope: !3996)
!4003 = !DILocation(line: 87, column: 32, scope: !3996)
!4004 = !DILocation(line: 87, column: 36, scope: !3996)
!4005 = !DILocation(line: 86, column: 51, scope: !3996)
!4006 = distinct !{!4006, !3998, !4007, !1769, !4008}
!4007 = !DILocation(line: 87, column: 43, scope: !3992)
!4008 = !{!"llvm.loop.name", !"VITIS_LOOP_86_2"}
!4009 = !DILocation(line: 88, column: 14, scope: !3911)
!4010 = !DILocation(line: 88, column: 12, scope: !3911)
!4011 = !DILocation(line: 88, column: 5, scope: !3911)
!4012 = !DILocation(line: 89, column: 5, scope: !3911)
!4013 = !DILocation(line: 91, column: 27, scope: !3911)
!4014 = !DILocation(line: 92, column: 32, scope: !3911)
!4015 = !DILocation(line: 93, column: 14, scope: !3911)
!4016 = !DILocation(line: 93, column: 46, scope: !3911)
!4017 = !DILocation(line: 93, column: 12, scope: !3911)
!4018 = !DILocation(line: 93, column: 5, scope: !3911)
!4019 = !DILocation(line: 94, column: 5, scope: !3911)
!4020 = !DILocation(line: 96, column: 14, scope: !3911)
!4021 = !DILocation(line: 96, column: 51, scope: !3911)
!4022 = !DILocation(line: 96, column: 12, scope: !3911)
!4023 = !DILocation(line: 96, column: 5, scope: !3911)
!4024 = !DILocation(line: 97, column: 9, scope: !4025)
!4025 = distinct !DILexicalBlock(scope: !3911, file: !998, line: 97, column: 9)
!4026 = !DILocation(line: 97, column: 9, scope: !3911)
!4027 = !DILocation(line: 98, column: 43, scope: !4028)
!4028 = distinct !DILexicalBlock(scope: !4025, file: !998, line: 97, column: 17)
!4029 = !DILocation(line: 98, column: 41, scope: !4028)
!4030 = !DILocation(line: 98, column: 7, scope: !4028)
!4031 = !DILocation(line: 99, column: 16, scope: !4028)
!4032 = !DILocation(line: 99, column: 14, scope: !4028)
!4033 = !DILocation(line: 99, column: 7, scope: !4028)
!4034 = !DILocation(line: 100, column: 5, scope: !4028)
!4035 = !DILocation(line: 101, column: 5, scope: !3911)
!4036 = !DILocation(line: 103, column: 41, scope: !3911)
!4037 = !DILocation(line: 103, column: 39, scope: !3911)
!4038 = !DILocation(line: 103, column: 5, scope: !3911)
!4039 = !DILocation(line: 104, column: 14, scope: !3911)
!4040 = !DILocation(line: 104, column: 12, scope: !3911)
!4041 = !DILocation(line: 104, column: 5, scope: !3911)
!4042 = !DILocation(line: 105, column: 5, scope: !3911)
!4043 = !DILocation(line: 107, column: 41, scope: !3911)
!4044 = !DILocation(line: 107, column: 39, scope: !3911)
!4045 = !DILocation(line: 107, column: 5, scope: !3911)
!4046 = !DILocation(line: 108, column: 14, scope: !3911)
!4047 = !DILocation(line: 108, column: 12, scope: !3911)
!4048 = !DILocation(line: 108, column: 5, scope: !3911)
!4049 = !DILocation(line: 109, column: 5, scope: !3911)
!4050 = !DILocation(line: 111, column: 14, scope: !3911)
!4051 = !DILocation(line: 111, column: 12, scope: !3911)
!4052 = !DILocation(line: 111, column: 5, scope: !3911)
!4053 = !DILocation(line: 112, column: 5, scope: !3911)
!4054 = !DILocation(line: 114, column: 14, scope: !3911)
!4055 = !DILocation(line: 114, column: 12, scope: !3911)
!4056 = !DILocation(line: 114, column: 5, scope: !3911)
!4057 = !DILocation(line: 115, column: 5, scope: !4058)
!4058 = !DILexicalBlockFile(scope: !3911, file: !998, discriminator: 0)
!4059 = !DILocation(line: 117, column: 29, scope: !3864)
!4060 = !DILocation(line: 117, column: 13, scope: !3864)
!4061 = !DILocation(line: 117, column: 4, scope: !3864)
!4062 = !DILocation(line: 117, column: 11, scope: !3864)
!4063 = !DILocation(line: 118, column: 47, scope: !3864)
!4064 = !DILocation(line: 118, column: 4, scope: !3864)
!4065 = !DILocation(line: 118, column: 16, scope: !3864)
!4066 = !DILocation(line: 119, column: 47, scope: !3864)
!4067 = !DILocation(line: 119, column: 4, scope: !3864)
!4068 = !DILocation(line: 119, column: 16, scope: !3864)
!4069 = !DILocation(line: 120, column: 47, scope: !3864)
!4070 = !DILocation(line: 120, column: 4, scope: !3864)
!4071 = !DILocation(line: 120, column: 16, scope: !3864)
!4072 = !DILocation(line: 121, column: 54, scope: !3864)
!4073 = !DILocation(line: 121, column: 4, scope: !3864)
!4074 = !DILocation(line: 121, column: 18, scope: !3864)
!4075 = !DILocation(line: 122, column: 21, scope: !3864)
!4076 = !DILocation(line: 122, column: 4, scope: !3864)
!4077 = !DILocation(line: 122, column: 11, scope: !3864)
!4078 = !DILocation(line: 123, column: 21, scope: !3864)
!4079 = !DILocation(line: 123, column: 4, scope: !3864)
!4080 = !DILocation(line: 123, column: 19, scope: !3864)
!4081 = !DILocation(line: 124, column: 53, scope: !3864)
!4082 = !DILocation(line: 124, column: 15, scope: !3864)
!4083 = !DILocation(line: 124, column: 4, scope: !3864)
!4084 = !DILocation(line: 124, column: 13, scope: !3864)
!4085 = !DILocation(line: 125, column: 36, scope: !3864)
!4086 = !DILocation(line: 125, column: 28, scope: !3864)
!4087 = !DILocation(line: 125, column: 4, scope: !3864)
!4088 = !DILocation(line: 125, column: 17, scope: !3864)
!4089 = !DILocation(line: 126, column: 34, scope: !3864)
!4090 = !DILocation(line: 126, column: 26, scope: !3864)
!4091 = !DILocation(line: 126, column: 4, scope: !3864)
!4092 = !DILocation(line: 126, column: 15, scope: !3864)
!4093 = !DILocation(line: 127, column: 1, scope: !3864)
!4094 = distinct !DISubprogram(name: "qkv_spec", linkageName: "_ZN12_GLOBAL__N_18qkv_specEhj", scope: !997, file: !998, line: 8, type: !4095, scopeLine: 8, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !1461, retainedNodes: !990)
!4095 = !DISubroutineType(types: !4096)
!4096 = !{!1166, !16, !93}
!4097 = !DILocalVariable(name: "bank", arg: 1, scope: !4094, file: !998, line: 8, type: !16)
!4098 = !DILocation(line: 8, column: 38, scope: !4094)
!4099 = !DILocalVariable(name: "epoch", arg: 2, scope: !4094, file: !998, line: 8, type: !93)
!4100 = !DILocation(line: 8, column: 53, scope: !4094)
!4101 = !DILocation(line: 9, column: 10, scope: !4094)
!4102 = !DILocation(line: 9, column: 11, scope: !4094)
!4103 = !DILocation(line: 9, column: 25, scope: !4094)
!4104 = !DILocation(line: 9, column: 31, scope: !4094)
!4105 = !DILocation(line: 9, column: 3, scope: !4094)
!4106 = distinct !DISubprogram(name: "a8_spec", linkageName: "_ZN12_GLOBAL__N_17a8_specEj", scope: !997, file: !998, line: 12, type: !4107, scopeLine: 12, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !1461, retainedNodes: !990)
!4107 = !DISubroutineType(types: !4108)
!4108 = !{!1166, !93}
!4109 = !DILocalVariable(name: "epoch", arg: 1, scope: !4106, file: !998, line: 12, type: !93)
!4110 = !DILocation(line: 12, column: 38, scope: !4106)
!4111 = !DILocation(line: 13, column: 10, scope: !4106)
!4112 = !DILocation(line: 13, column: 11, scope: !4106)
!4113 = !DILocation(line: 13, column: 27, scope: !4106)
!4114 = !DILocation(line: 13, column: 3, scope: !4106)
