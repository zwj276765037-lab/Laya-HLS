; ModuleID = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d1_optional_pointer_pilot/runs/vitis_b_csynth_work/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: inaccessiblemem_or_argmemonly noinline willreturn
define void @apatb_optional_pointer_pilot_ir(i8 zeroext %mode, i8 zeroext %layer, i8 zeroext %src_bank, i32 %epoch, i8 zeroext %second_id, i8 zeroext %second_bank, i32 %second_epoch, i8 zeroext %second_region, i8 zeroext %load_ok, i32* noalias nonnull "fpga.decayed.dim.hint"="36" "maxi" %out) local_unnamed_addr #0 {
entry:
  %0 = bitcast i32* %out to [36 x i32]*
  %out_copy = alloca [36 x i32], align 512
  call fastcc void @copy_in([36 x i32]* nonnull %0, [36 x i32]* nonnull align 512 %out_copy)
  call void @apatb_optional_pointer_pilot_hw(i8 %mode, i8 %layer, i8 %src_bank, i32 %epoch, i8 %second_id, i8 %second_bank, i32 %second_epoch, i8 %second_region, i8 %load_ok, [36 x i32]* %out_copy)
  call void @copy_back([36 x i32]* %0, [36 x i32]* %out_copy)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in([36 x i32]* noalias readonly, [36 x i32]* noalias align 512) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a36i32([36 x i32]* align 512 %1, [36 x i32]* %0)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a36i32([36 x i32]* noalias align 512 %dst, [36 x i32]* noalias readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [36 x i32]* %dst, null
  %1 = icmp eq [36 x i32]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a36i32([36 x i32]* nonnull %dst, [36 x i32]* nonnull %src, i64 36)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a36i32([36 x i32]* %dst, [36 x i32]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [36 x i32]* %src, null
  %1 = icmp eq [36 x i32]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [36 x i32], [36 x i32]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [36 x i32], [36 x i32]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i32, i32* %src.addr, align 4
  store i32 %3, i32* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_out([36 x i32]* noalias, [36 x i32]* noalias readonly align 512) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a36i32([36 x i32]* %0, [36 x i32]* align 512 %1)
  ret void
}

declare void @apatb_optional_pointer_pilot_hw(i8, i8, i8, i32, i8, i8, i32, i8, i8, [36 x i32]*)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back([36 x i32]* noalias, [36 x i32]* noalias readonly align 512) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a36i32([36 x i32]* %0, [36 x i32]* align 512 %1)
  ret void
}

declare void @optional_pointer_pilot_hw_stub(i8 zeroext, i8 zeroext, i8 zeroext, i32, i8 zeroext, i8 zeroext, i32, i8 zeroext, i8 zeroext, i32* noalias nonnull)

define void @optional_pointer_pilot_hw_stub_wrapper(i8, i8, i8, i32, i8, i8, i32, i8, i8, [36 x i32]*) #5 {
entry:
  call void @copy_out([36 x i32]* null, [36 x i32]* %9)
  %10 = bitcast [36 x i32]* %9 to i32*
  call void @optional_pointer_pilot_hw_stub(i8 %0, i8 %1, i8 %2, i32 %3, i8 %4, i8 %5, i32 %6, i8 %7, i8 %8, i32* %10)
  call void @copy_in([36 x i32]* null, [36 x i32]* %9)
  ret void
}

attributes #0 = { inaccessiblemem_or_argmemonly noinline willreturn "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
