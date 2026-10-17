define internal fastcc void @"(anonymous namespace)::linear_impl"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 zeroext %op, i8 zeroext %layer, i32 %epoch, i8 zeroext %load_ok, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content, i8* noalias nocapture align 512 %probe_output_ref_id, i8* noalias nocapture align 512 %probe_output_ref_bank, i32* noalias nocapture align 512 %probe_output_ref_epoch, i8* noalias nocapture align 512 %probe_output_region, i8* noalias nocapture align 512 %probe_output_stage, i8* noalias nocapture align 512 %probe_output_layer, i8* noalias nocapture align 512 %probe_output_batch, i8* noalias nocapture align 512 %probe_output_row_space, i16* noalias nocapture align 512 %probe_output_row0, i16* noalias nocapture align 512 %probe_output_rows, i16* noalias nocapture align 512 %probe_output_width, i8* noalias nocapture align 512 %probe_output_content) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1), !fpga.pragma.source !7
  %tobool.i = icmp ne i8 %load_ok, 0
  br i1 %tobool.i, label %if.end, label %cleanup29

if.end:                                           ; preds = %entry
  %cmp = icmp eq i8 %op, 48
  %cond = select i1 %cmp, i8 5, i8 3
  %cond3 = select i1 %cmp, i8 2, i8 1
  store i8 %cond, i8* %output_ref_id, align 512
  store i8 0, i8* %output_ref_bank, align 512
  store i32 %epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 2, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 0, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 128, i16* %output_rows, align 512
  store i16 64, i16* %output_width, align 512
  store i8 %cond3, i8* %output_content, align 512
  store i8 %cond, i8* %probe_output_ref_id, align 512
  store i8 0, i8* %probe_output_ref_bank, align 512
  store i32 %epoch, i32* %probe_output_ref_epoch, align 512
  store i8 0, i8* %probe_output_region, align 512
  store i8 2, i8* %probe_output_stage, align 512
  store i8 %layer, i8* %probe_output_layer, align 512
  store i8 -1, i8* %probe_output_batch, align 512
  store i8 0, i8* %probe_output_row_space, align 512
  store i16 0, i16* %probe_output_row0, align 512
  store i16 128, i16* %probe_output_rows, align 512
  store i16 64, i16* %probe_output_width, align 512
  store i8 %cond3, i8* %probe_output_content, align 512
  %storemerge2 = select i1 %cmp, i16 8, i16 0
  %storemerge = select i1 %cmp, i32 117440516, i32 0
  br label %cleanup29

cleanup29:                                        ; preds = %if.end, %entry
  %storemerge3 = phi i16 [ %storemerge2, %if.end ], [ 5, %entry ]
  %storemerge1 = phi i32 [ %storemerge, %if.end ], [ 67108881, %entry ]
  store i16 %storemerge3, i16* %agg.result.01, align 512
  store i32 %storemerge1, i32* %agg.result.12, align 512
  store i64 -1, i64* %agg.result.23, align 512
  ret void
}
