; ModuleID = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_slice/runs/depth_v3/csynth_work/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: noinline
define void @apatb_attention_slice_ir(i8* noalias nocapture nonnull readonly "maxi" %fixture, i8* noalias nonnull "maxi" %io, i8* noalias nonnull "maxi" %aux, i8* noalias nonnull "maxi" %qkv0, i8* noalias nonnull "maxi" %qkv1, i8* noalias nonnull "maxi" %att_out, i32* noalias nonnull "maxi" %observed) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8* %fixture to [786432 x i8]*
  %1 = call i8* @malloc(i64 786432)
  %fixture_copy = bitcast i8* %1 to [786432 x i8]*
  %2 = bitcast i8* %io to [32768 x i8]*
  %3 = call i8* @malloc(i64 32768)
  %io_copy = bitcast i8* %3 to [32768 x i8]*
  %4 = bitcast i8* %aux to [128 x i8]*
  %aux_copy = alloca [128 x i8], align 512
  %5 = bitcast i8* %qkv0 to [10240064 x i8]*
  %6 = call i8* @malloc(i64 10240064)
  %qkv0_copy = bitcast i8* %6 to [10240064 x i8]*
  %7 = bitcast i8* %qkv1 to [10240064 x i8]*
  %8 = call i8* @malloc(i64 10240064)
  %qkv1_copy = bitcast i8* %8 to [10240064 x i8]*
  %9 = bitcast i8* %att_out to [4100 x i8]*
  %10 = call i8* @malloc(i64 4100)
  %att_out_copy = bitcast i8* %10 to [4100 x i8]*
  %11 = bitcast i32* %observed to [256 x i32]*
  %observed_copy = alloca [256 x i32], align 512
  call fastcc void @copy_in([786432 x i8]* nonnull %0, [786432 x i8]* %fixture_copy, [32768 x i8]* nonnull %2, [32768 x i8]* %io_copy, [128 x i8]* nonnull %4, [128 x i8]* nonnull align 512 %aux_copy, [10240064 x i8]* nonnull %5, [10240064 x i8]* %qkv0_copy, [10240064 x i8]* nonnull %7, [10240064 x i8]* %qkv1_copy, [4100 x i8]* nonnull %9, [4100 x i8]* %att_out_copy, [256 x i32]* nonnull %11, [256 x i32]* nonnull align 512 %observed_copy)
  call void @apatb_attention_slice_hw([786432 x i8]* %fixture_copy, [32768 x i8]* %io_copy, [128 x i8]* %aux_copy, [10240064 x i8]* %qkv0_copy, [10240064 x i8]* %qkv1_copy, [4100 x i8]* %att_out_copy, [256 x i32]* %observed_copy)
  call void @copy_back([786432 x i8]* %0, [786432 x i8]* %fixture_copy, [32768 x i8]* %2, [32768 x i8]* %io_copy, [128 x i8]* %4, [128 x i8]* %aux_copy, [10240064 x i8]* %5, [10240064 x i8]* %qkv0_copy, [10240064 x i8]* %7, [10240064 x i8]* %qkv1_copy, [4100 x i8]* %9, [4100 x i8]* %att_out_copy, [256 x i32]* %11, [256 x i32]* %observed_copy)
  tail call void @free(i8* %1)
  tail call void @free(i8* %3)
  tail call void @free(i8* %6)
  tail call void @free(i8* %8)
  tail call void @free(i8* %10)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in([786432 x i8]* readonly, [786432 x i8]*, [32768 x i8]* readonly, [32768 x i8]*, [128 x i8]* readonly, [128 x i8]* align 512, [10240064 x i8]* readonly, [10240064 x i8]*, [10240064 x i8]* readonly, [10240064 x i8]*, [4100 x i8]* readonly, [4100 x i8]*, [256 x i32]* readonly, [256 x i32]* align 512) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a786432i8([786432 x i8]* %1, [786432 x i8]* %0)
  call fastcc void @onebyonecpy_hls.p0a32768i8([32768 x i8]* %3, [32768 x i8]* %2)
  call fastcc void @onebyonecpy_hls.p0a128i8([128 x i8]* align 512 %5, [128 x i8]* %4)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %7, [10240064 x i8]* %6)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %9, [10240064 x i8]* %8)
  call fastcc void @onebyonecpy_hls.p0a4100i8([4100 x i8]* %11, [4100 x i8]* %10)
  call fastcc void @onebyonecpy_hls.p0a256i32([256 x i32]* align 512 %13, [256 x i32]* %12)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a786432i8([786432 x i8]* %dst, [786432 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [786432 x i8]* %dst, null
  %1 = icmp eq [786432 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a786432i8([786432 x i8]* nonnull %dst, [786432 x i8]* nonnull %src, i64 786432)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a786432i8([786432 x i8]* %dst, [786432 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [786432 x i8]* %src, null
  %1 = icmp eq [786432 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [786432 x i8], [786432 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [786432 x i8], [786432 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a32768i8([32768 x i8]* %dst, [32768 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [32768 x i8]* %dst, null
  %1 = icmp eq [32768 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a32768i8([32768 x i8]* nonnull %dst, [32768 x i8]* nonnull %src, i64 32768)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a32768i8([32768 x i8]* %dst, [32768 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [32768 x i8]* %src, null
  %1 = icmp eq [32768 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [32768 x i8], [32768 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [32768 x i8], [32768 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a128i8([128 x i8]* align 512 %dst, [128 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [128 x i8]* %dst, null
  %1 = icmp eq [128 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a128i8([128 x i8]* nonnull %dst, [128 x i8]* nonnull %src, i64 128)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a128i8([128 x i8]* %dst, [128 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [128 x i8]* %src, null
  %1 = icmp eq [128 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [128 x i8], [128 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [128 x i8], [128 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %dst, [10240064 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [10240064 x i8]* %dst, null
  %1 = icmp eq [10240064 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a10240064i8([10240064 x i8]* nonnull %dst, [10240064 x i8]* nonnull %src, i64 10240064)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a10240064i8([10240064 x i8]* %dst, [10240064 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [10240064 x i8]* %src, null
  %1 = icmp eq [10240064 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [10240064 x i8], [10240064 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [10240064 x i8], [10240064 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a4100i8([4100 x i8]* %dst, [4100 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [4100 x i8]* %dst, null
  %1 = icmp eq [4100 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a4100i8([4100 x i8]* nonnull %dst, [4100 x i8]* nonnull %src, i64 4100)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a4100i8([4100 x i8]* %dst, [4100 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [4100 x i8]* %src, null
  %1 = icmp eq [4100 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [4100 x i8], [4100 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [4100 x i8], [4100 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a256i32([256 x i32]* align 512 %dst, [256 x i32]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [256 x i32]* %dst, null
  %1 = icmp eq [256 x i32]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a256i32([256 x i32]* nonnull %dst, [256 x i32]* nonnull %src, i64 256)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a256i32([256 x i32]* %dst, [256 x i32]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [256 x i32]* %src, null
  %1 = icmp eq [256 x i32]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [256 x i32], [256 x i32]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [256 x i32], [256 x i32]* %src, i64 0, i64 %for.loop.idx2
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
define internal fastcc void @copy_out([786432 x i8]*, [786432 x i8]* readonly, [32768 x i8]*, [32768 x i8]* readonly, [128 x i8]*, [128 x i8]* readonly align 512, [10240064 x i8]*, [10240064 x i8]* readonly, [10240064 x i8]*, [10240064 x i8]* readonly, [4100 x i8]*, [4100 x i8]* readonly, [256 x i32]*, [256 x i32]* readonly align 512) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a786432i8([786432 x i8]* %0, [786432 x i8]* %1)
  call fastcc void @onebyonecpy_hls.p0a32768i8([32768 x i8]* %2, [32768 x i8]* %3)
  call fastcc void @onebyonecpy_hls.p0a128i8([128 x i8]* %4, [128 x i8]* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %6, [10240064 x i8]* %7)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %8, [10240064 x i8]* %9)
  call fastcc void @onebyonecpy_hls.p0a4100i8([4100 x i8]* %10, [4100 x i8]* %11)
  call fastcc void @onebyonecpy_hls.p0a256i32([256 x i32]* %12, [256 x i32]* align 512 %13)
  ret void
}

declare i8* @malloc(i64) local_unnamed_addr

declare void @free(i8*) local_unnamed_addr

declare void @apatb_attention_slice_hw([786432 x i8]*, [32768 x i8]*, [128 x i8]*, [10240064 x i8]*, [10240064 x i8]*, [4100 x i8]*, [256 x i32]*)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back([786432 x i8]*, [786432 x i8]* readonly, [32768 x i8]*, [32768 x i8]* readonly, [128 x i8]*, [128 x i8]* readonly align 512, [10240064 x i8]*, [10240064 x i8]* readonly, [10240064 x i8]*, [10240064 x i8]* readonly, [4100 x i8]*, [4100 x i8]* readonly, [256 x i32]*, [256 x i32]* readonly align 512) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a32768i8([32768 x i8]* %2, [32768 x i8]* %3)
  call fastcc void @onebyonecpy_hls.p0a128i8([128 x i8]* %4, [128 x i8]* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %6, [10240064 x i8]* %7)
  call fastcc void @onebyonecpy_hls.p0a10240064i8([10240064 x i8]* %8, [10240064 x i8]* %9)
  call fastcc void @onebyonecpy_hls.p0a4100i8([4100 x i8]* %10, [4100 x i8]* %11)
  call fastcc void @onebyonecpy_hls.p0a256i32([256 x i32]* %12, [256 x i32]* align 512 %13)
  ret void
}

declare void @attention_slice_hw_stub(i8* noalias nocapture nonnull readonly, i8* noalias nonnull, i8* noalias nonnull, i8* noalias nonnull, i8* noalias nonnull, i8* noalias nonnull, i32* noalias nonnull)

define void @attention_slice_hw_stub_wrapper([786432 x i8]*, [32768 x i8]*, [128 x i8]*, [10240064 x i8]*, [10240064 x i8]*, [4100 x i8]*, [256 x i32]*) #5 {
entry:
  call void @copy_out([786432 x i8]* null, [786432 x i8]* %0, [32768 x i8]* null, [32768 x i8]* %1, [128 x i8]* null, [128 x i8]* %2, [10240064 x i8]* null, [10240064 x i8]* %3, [10240064 x i8]* null, [10240064 x i8]* %4, [4100 x i8]* null, [4100 x i8]* %5, [256 x i32]* null, [256 x i32]* %6)
  %7 = bitcast [786432 x i8]* %0 to i8*
  %8 = bitcast [32768 x i8]* %1 to i8*
  %9 = bitcast [128 x i8]* %2 to i8*
  %10 = bitcast [10240064 x i8]* %3 to i8*
  %11 = bitcast [10240064 x i8]* %4 to i8*
  %12 = bitcast [4100 x i8]* %5 to i8*
  %13 = bitcast [256 x i32]* %6 to i32*
  call void @attention_slice_hw_stub(i8* %7, i8* %8, i8* %9, i8* %10, i8* %11, i8* %12, i32* %13)
  call void @copy_in([786432 x i8]* null, [786432 x i8]* %0, [32768 x i8]* null, [32768 x i8]* %1, [128 x i8]* null, [128 x i8]* %2, [10240064 x i8]* null, [10240064 x i8]* %3, [10240064 x i8]* null, [10240064 x i8]* %4, [4100 x i8]* null, [4100 x i8]* %5, [256 x i32]* null, [256 x i32]* %6)
  ret void
}

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
