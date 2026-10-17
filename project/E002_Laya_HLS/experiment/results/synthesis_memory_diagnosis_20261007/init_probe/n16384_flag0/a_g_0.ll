; ModuleID = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n16384_flag0/work/hls/.autopilot/db/a.g.0.bc'
source_filename = "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n16384_flag0/work/hls/.autopilot/db/a.g.0.bc"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

@state.flag = internal unnamed_addr global i8 0, align 512
@state.data = internal unnamed_addr global [16384 x i8] zeroinitializer, align 512
@0 = private unnamed_addr constant [10 x i8] c"s_axilite\00"
@1 = private unnamed_addr constant [1 x i8] zeroinitializer
@2 = private unnamed_addr constant [8 x i8] c"control\00"
@3 = private unnamed_addr constant [3 x i8] c"24\00"
@4 = private unnamed_addr constant [8 x i8] c"ap_auto\00"
@5 = private unnamed_addr constant [3 x i8] c"32\00"
@6 = private unnamed_addr constant [3 x i8] c"16\00"
@7 = private unnamed_addr constant [15 x i8] c"init_probe_top\00"

; Function Attrs: nounwind
define zeroext i16 @init_probe_top(i32 %index, i8 zeroext %value_r) #0 {
entry:
  call void (...) @_ssdm_op_SpecTopModule([15 x i8]* @7), !fpga.pragma.source !5
  call void (...) @_ssdm_op_SpecBitsMap(i32 %index), !map !6
  call void (...) @_ssdm_op_SpecInterface(i32 %index, [10 x i8]* @0, i32 -1, i32 -1, [1 x i8]* @1, i32 0, i32 0, [8 x i8]* @2, [3 x i8]* @3, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, i32 -1, i32 0, i32 0, i32 0)
  call void (...) @_ssdm_op_SpecInterface(i32 %index, [8 x i8]* @4, i32 0, i32 0, [1 x i8]* @1, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, i32 -1, i32 0, i32 0, i32 0)
  call void (...) @_ssdm_op_SpecBitsMap(i8 %value_r), !map !6
  call void (...) @_ssdm_op_SpecInterface(i8 %value_r, [10 x i8]* @0, i32 -1, i32 -1, [1 x i8]* @1, i32 0, i32 0, [8 x i8]* @2, [3 x i8]* @5, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, i32 -1, i32 0, i32 0, i32 0)
  call void (...) @_ssdm_op_SpecInterface(i8 %value_r, [8 x i8]* @4, i32 0, i32 0, [1 x i8]* @1, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, i32 -1, i32 0, i32 0, i32 0)
  call void (...) @_ssdm_op_SpecInterface(i32 0, [10 x i8]* @0, i32 0, i32 0, [1 x i8]* @1, i32 0, i32 0, [8 x i8]* @2, [3 x i8]* @6, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0, [1 x i8]* @1, [1 x i8]* @1, i32 0, i32 0, i32 0, i32 0)
  call void (...) @_ssdm_op_SpecResource([16384 x i8]* @state.data, i64 666, i64 20, i64 -1, i1 false), !fpga.pragma.source !5
  %and = and i32 %index, 16383
  %idxprom = zext i32 %and to i64
  %arrayidx1 = getelementptr [16384 x i8], [16384 x i8]* @state.data, i64 0, i64 %idxprom
  %0 = load i8, i8* %arrayidx1, align 1
  %1 = load i8, i8* @state.flag, align 512
  store i8 %value_r, i8* %arrayidx1, align 1
  %xor = xor i8 %1, %value_r
  store i8 %xor, i8* @state.flag, align 512
  %conv5 = zext i8 %0 to i16
  %conv7 = zext i8 %1 to i16
  %shl = shl nuw i16 %conv7, 8
  %or = or i16 %shl, %conv5
  ret i16 %or
}

; Function Attrs: nounwind
declare void @_ssdm_op_SpecBitsMap(...) #0

; Function Attrs: nounwind
declare void @_ssdm_op_SpecInterface(...) #0

; Function Attrs: nounwind
declare void @_ssdm_op_SpecResource(...) #0

; Function Attrs: nounwind
declare void @_ssdm_op_SpecTopModule(...) #0

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, i64, metadata) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone speculatable willreturn }

!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!blackbox_cfg = !{!2}
!axi4.slave.bundlemap = !{}
!llvm.module.flags = !{!3, !4}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"reflow.full.lowering", i32 1}
!5 = !{!"user"}
!6 = !{!2}
