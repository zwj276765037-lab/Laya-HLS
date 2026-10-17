define internal fastcc void @"(anonymous namespace)::vector_impl"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 zeroext %op, i8* noalias nocapture align 512 %src0_ref_id, i8* noalias nocapture align 512 %src0_ref_bank, i32* noalias nocapture align 512 %src0_ref_epoch, i8* noalias nocapture align 512 %src0_region, i8 zeroext %layer, i32* noalias nocapture align 512 %probe_issued_ctx_task_id, i8* noalias nocapture align 512 %probe_issued_ctx_op, i8* noalias nocapture align 512 %probe_issued_ctx_stage, i8* noalias nocapture align 512 %probe_issued_ctx_layer, i8* noalias nocapture align 512 %probe_issued_ctx_batch, i8* noalias nocapture align 512 %probe_issued_ctx_row_space, i16* noalias nocapture align 512 %probe_issued_ctx_row0, i8* noalias nocapture align 512 %probe_issued_ctx_rows, i8* noalias nocapture align 512 %probe_issued_src0_id, i8* noalias nocapture align 512 %probe_issued_src0_bank, i32* noalias nocapture align 512 %probe_issued_src0_epoch, i8* noalias nocapture align 512 %probe_issued_src1_id, i8* noalias nocapture align 512 %probe_issued_src1_bank, i32* noalias nocapture align 512 %probe_issued_src1_epoch, i8* noalias nocapture align 512 %probe_issued_dst_id, i8* noalias nocapture align 512 %probe_issued_dst_bank, i32* noalias nocapture align 512 %probe_issued_dst_epoch, i16* noalias nocapture align 512 %probe_issued_length, i8* noalias nocapture align 512 %probe_issued_src0_region, i8* noalias nocapture align 512 %probe_issued_src1_region, i8* noalias nocapture align 512 %probe_issued_dst_region, i16* noalias nocapture align 512 %probe_issued_bias_id) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1), !fpga.pragma.source !7
  %.026 = load i8, i8* %src0_ref_id, align 512
  %.127 = load i8, i8* %src0_ref_bank, align 512
  %.228 = load i32, i32* %src0_ref_epoch, align 512
  %0 = load i8, i8* %src0_region, align 512
  %add = add i32 %.228, 1
  %cmp.i = icmp eq i8 %.026, 0
  %storemerge17 = select i1 %cmp.i, i16 5, i16 0
  %storemerge = select i1 %cmp.i, i32 67108870, i32 0
  store i16 %storemerge17, i16* %agg.result_code, align 512, !alias.scope !321, !noalias !326
  store i32 %storemerge, i32* %agg.result_detail, align 512, !alias.scope !330, !noalias !332
  store i64 -1, i64* %agg.result_bad_element, align 512, !alias.scope !333, !noalias !335
  store i32 0, i32* %probe_issued_ctx_task_id, align 512
  store i8 %op, i8* %probe_issued_ctx_op, align 512
  store i8 2, i8* %probe_issued_ctx_stage, align 512
  store i8 %layer, i8* %probe_issued_ctx_layer, align 512
  store i8 0, i8* %probe_issued_ctx_batch, align 512
  store i8 0, i8* %probe_issued_ctx_row_space, align 512
  store i16 0, i16* %probe_issued_ctx_row0, align 512
  store i8 0, i8* %probe_issued_ctx_rows, align 512
  store i8 %.026, i8* %probe_issued_src0_id, align 512
  store i8 %.127, i8* %probe_issued_src0_bank, align 512
  store i32 %.228, i32* %probe_issued_src0_epoch, align 512
  store i8 0, i8* %probe_issued_src1_id, align 512
  store i8 0, i8* %probe_issued_src1_bank, align 512
  store i32 0, i32* %probe_issued_src1_epoch, align 512
  store i8 1, i8* %probe_issued_dst_id, align 512
  store i8 1, i8* %probe_issued_dst_bank, align 512
  store i32 %add, i32* %probe_issued_dst_epoch, align 512
  store i16 1024, i16* %probe_issued_length, align 512
  store i8 %0, i8* %probe_issued_src0_region, align 512
  store i8 0, i8* %probe_issued_src1_region, align 512
  store i8 0, i8* %probe_issued_dst_region, align 512
  store i16 -1, i16* %probe_issued_bias_id, align 512
  %cmp.i16 = icmp eq i16 %storemerge17, 0
  br i1 %cmp.i16, label %if.then23, label %if.end25

if.then23:                                        ; preds = %entry
  %.off.i = add i8 %op, -98
  %switch.i = icmp ult i8 %.off.i, 2
  %ref.tmp24.029.0 = select i1 %switch.i, i16 3, i16 0
  %ref.tmp24.130.0 = select i1 %switch.i, i32 117637121, i32 0
  store i16 %ref.tmp24.029.0, i16* %agg.result_code, align 512
  store i32 %ref.tmp24.130.0, i32* %agg.result_detail, align 512
  store i64 -1, i64* %agg.result_bad_element, align 512
  br label %if.end25

if.end25:                                         ; preds = %if.then23, %entry
  ret void
}
