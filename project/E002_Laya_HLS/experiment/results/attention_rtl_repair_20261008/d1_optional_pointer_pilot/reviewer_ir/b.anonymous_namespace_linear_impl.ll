define internal fastcc void @"(anonymous namespace)::linear_impl"(i16* noalias nocapture align 512 %agg.result.01, i32* noalias nocapture align 512 %agg.result.12, i64* noalias nocapture align 512 %agg.result.23, i8 zeroext %op, i8 zeroext %stage, i8 zeroext %layer, i32 %epoch, i8 zeroext %load_ok, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content, i1 zeroext %pair_present, [2 x i8]* noalias nocapture align 512 %pair_output_ref_id, [2 x i8]* noalias nocapture align 512 %pair_output_ref_bank, [2 x i32]* noalias nocapture align 512 %pair_output_ref_epoch, [2 x i8]* noalias nocapture align 512 %pair_output_region, [2 x i8]* noalias nocapture align 512 %pair_output_stage, [2 x i8]* noalias nocapture align 512 %pair_output_layer, [2 x i8]* noalias nocapture align 512 %pair_output_batch, [2 x i8]* noalias nocapture align 512 %pair_output_row_space, [2 x i16]* noalias nocapture align 512 %pair_output_row0, [2 x i16]* noalias nocapture align 512 %pair_output_rows, [2 x i16]* noalias nocapture align 512 %pair_output_width, [2 x i8]* noalias nocapture align 512 %pair_output_content, i8* noalias nocapture align 512 %probe_output_ref_id, i8* noalias nocapture align 512 %probe_output_ref_bank, i32* noalias nocapture align 512 %probe_output_ref_epoch, i8* noalias nocapture align 512 %probe_output_region, i8* noalias nocapture align 512 %probe_output_stage, i8* noalias nocapture align 512 %probe_output_layer, i8* noalias nocapture align 512 %probe_output_batch, i8* noalias nocapture align 512 %probe_output_row_space, i16* noalias nocapture align 512 %probe_output_row0, i16* noalias nocapture align 512 %probe_output_rows, i16* noalias nocapture align 512 %probe_output_width, i8* noalias nocapture align 512 %probe_output_content, [2 x i8]* noalias nocapture align 512 %probe_pair_ref_id, [2 x i8]* noalias nocapture align 512 %probe_pair_ref_bank, [2 x i32]* noalias nocapture align 512 %probe_pair_ref_epoch, [2 x i8]* noalias nocapture align 512 %probe_pair_region, [2 x i8]* noalias nocapture align 512 %probe_pair_stage, [2 x i8]* noalias nocapture align 512 %probe_pair_layer, [2 x i8]* noalias nocapture align 512 %probe_pair_batch, [2 x i8]* noalias nocapture align 512 %probe_pair_row_space, [2 x i16]* noalias nocapture align 512 %probe_pair_row0, [2 x i16]* noalias nocapture align 512 %probe_pair_rows, [2 x i16]* noalias nocapture align 512 %probe_pair_width, [2 x i8]* noalias nocapture align 512 %probe_pair_content) unnamed_addr #0 {
entry:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1), !fpga.pragma.source !7
  %tobool.i = icmp ne i8 %load_ok, 0
  %c.detail.0 = select i1 %tobool.i, i32 0, i32 67108881
  %c.code.0 = select i1 %tobool.i, i16 0, i16 5
  br i1 %tobool.i, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  store i16 %c.code.0, i16* %agg.result.01, align 512
  store i32 %c.detail.0, i32* %agg.result.12, align 512
  store i64 -1, i64* %agg.result.23, align 512
  br label %cleanup29

if.end:                                           ; preds = %entry
  %cmp = icmp eq i8 %op, 48
  %cond = select i1 %cmp, i8 5, i8 3
  %cmp1 = icmp eq i8 %stage, 4
  %cond2 = select i1 %cmp1, i8 3, i8 2
  %cond3 = select i1 %cmp, i8 %cond2, i8 1
  store i8 %cond, i8* %output_ref_id, align 512
  store i8 0, i8* %output_ref_bank, align 512
  store i32 %epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
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
  store i8 %stage, i8* %probe_output_stage, align 512
  store i8 %layer, i8* %probe_output_layer, align 512
  store i8 -1, i8* %probe_output_batch, align 512
  store i8 0, i8* %probe_output_row_space, align 512
  store i16 0, i16* %probe_output_row0, align 512
  store i16 128, i16* %probe_output_rows, align 512
  store i16 64, i16* %probe_output_width, align 512
  store i8 %cond3, i8* %probe_output_content, align 512
  br i1 %cmp, label %if.then7, label %if.end27

if.then7:                                         ; preds = %if.end
  br i1 %pair_present, label %if.end10, label %if.then8

if.then8:                                         ; preds = %if.then7
  store i16 8, i16* %agg.result.01, align 512
  store i32 117440516, i32* %agg.result.12, align 512
  store i64 -1, i64* %agg.result.23, align 512
  br label %cleanup

if.end10:                                         ; preds = %if.then7
  %cmp.i1 = icmp ne i8 %cond, 5
  %cmp18.i = icmp eq i32 %epoch, 0
  %or.cond = or i1 %cmp.i1, %cmp18.i
  %ref.tmp13.0146.0 = select i1 %or.cond, i16 5, i16 0
  %ref.tmp13.1147.0 = select i1 %or.cond, i32 67436549, i32 0
  %cmp.i2 = icmp eq i16 %ref.tmp13.0146.0, 0
  br i1 %cmp.i2, label %if.then18, label %if.then15

if.then15:                                        ; preds = %if.end10
  store i16 %ref.tmp13.0146.0, i16* %agg.result.01, align 512
  store i32 %ref.tmp13.1147.0, i32* %agg.result.12, align 512
  store i64 -1, i64* %agg.result.23, align 512
  br label %cleanup

if.then18:                                        ; preds = %if.end10
  %arrayidx21.0.04.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_ref_id, i64 0, i64 0
  %arrayidx21.0.15.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_ref_bank, i64 0, i64 0
  %arrayidx21.0.26.i = getelementptr [2 x i32], [2 x i32]* %probe_pair_ref_epoch, i64 0, i64 0
  %arrayidx21.110.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_region, i64 0, i64 0
  %arrayidx21.211.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_stage, i64 0, i64 0
  %arrayidx21.312.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_layer, i64 0, i64 0
  %arrayidx21.413.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_batch, i64 0, i64 0
  %arrayidx21.514.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_row_space, i64 0, i64 0
  %arrayidx21.615.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_row0, i64 0, i64 0
  %arrayidx21.716.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_rows, i64 0, i64 0
  %arrayidx21.817.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_width, i64 0, i64 0
  %arrayidx21.918.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_content, i64 0, i64 0
  store i8 %cond, i8* %arrayidx21.0.04.i, align 512, !alias.scope !23, !noalias !26
  store i8 0, i8* %arrayidx21.0.15.i, align 512, !alias.scope !53, !noalias !54
  store i32 %epoch, i32* %arrayidx21.0.26.i, align 512, !alias.scope !55, !noalias !56
  store i8 0, i8* %arrayidx21.110.i, align 512, !alias.scope !57, !noalias !58
  store i8 %stage, i8* %arrayidx21.211.i, align 512, !alias.scope !59, !noalias !60
  store i8 %layer, i8* %arrayidx21.312.i, align 512, !alias.scope !61, !noalias !62
  store i8 -1, i8* %arrayidx21.413.i, align 512, !alias.scope !63, !noalias !64
  store i8 0, i8* %arrayidx21.514.i, align 512, !alias.scope !65, !noalias !66
  store i16 0, i16* %arrayidx21.615.i, align 512, !alias.scope !67, !noalias !68
  store i16 128, i16* %arrayidx21.716.i, align 512, !alias.scope !69, !noalias !70
  store i16 64, i16* %arrayidx21.817.i, align 512, !alias.scope !71, !noalias !72
  store i8 %cond3, i8* %arrayidx21.918.i, align 512, !alias.scope !73, !noalias !74
  %arrayidx52.0.01.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_ref_id, i64 0, i64 1
  %arrayidx52.0.12.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_ref_bank, i64 0, i64 1
  %arrayidx52.0.23.i = getelementptr [2 x i32], [2 x i32]* %probe_pair_ref_epoch, i64 0, i64 1
  %arrayidx52.11.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_region, i64 0, i64 1
  %arrayidx52.22.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_stage, i64 0, i64 1
  %arrayidx52.33.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_layer, i64 0, i64 1
  %arrayidx52.44.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_batch, i64 0, i64 1
  %arrayidx52.55.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_row_space, i64 0, i64 1
  %arrayidx52.66.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_row0, i64 0, i64 1
  %arrayidx52.77.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_rows, i64 0, i64 1
  %arrayidx52.88.i = getelementptr [2 x i16], [2 x i16]* %probe_pair_width, i64 0, i64 1
  %arrayidx52.99.i = getelementptr [2 x i8], [2 x i8]* %probe_pair_content, i64 0, i64 1
  store i8 %cond, i8* %arrayidx52.0.01.i, align 1, !alias.scope !23, !noalias !26
  store i8 1, i8* %arrayidx52.0.12.i, align 1, !alias.scope !53, !noalias !54
  store i32 %epoch, i32* %arrayidx52.0.23.i, align 4, !alias.scope !55, !noalias !56
  store i8 0, i8* %arrayidx52.11.i, align 1, !alias.scope !57, !noalias !58
  store i8 %stage, i8* %arrayidx52.22.i, align 1, !alias.scope !59, !noalias !60
  store i8 %layer, i8* %arrayidx52.33.i, align 1, !alias.scope !61, !noalias !62
  store i8 -1, i8* %arrayidx52.44.i, align 1, !alias.scope !63, !noalias !64
  store i8 0, i8* %arrayidx52.55.i, align 1, !alias.scope !65, !noalias !66
  store i16 0, i16* %arrayidx52.66.i, align 2, !alias.scope !67, !noalias !68
  store i16 128, i16* %arrayidx52.77.i, align 2, !alias.scope !69, !noalias !70
  store i16 64, i16* %arrayidx52.88.i, align 2, !alias.scope !71, !noalias !72
  store i8 %cond3, i8* %arrayidx52.99.i, align 1, !alias.scope !73, !noalias !74
  %arrayidx24.0.04 = getelementptr [2 x i8], [2 x i8]* %pair_output_ref_id, i64 0, i64 0
  %arrayidx24.0.15 = getelementptr [2 x i8], [2 x i8]* %pair_output_ref_bank, i64 0, i64 0
  %arrayidx24.0.26 = getelementptr [2 x i32], [2 x i32]* %pair_output_ref_epoch, i64 0, i64 0
  %arrayidx24.110 = getelementptr [2 x i8], [2 x i8]* %pair_output_region, i64 0, i64 0
  %arrayidx24.211 = getelementptr [2 x i8], [2 x i8]* %pair_output_stage, i64 0, i64 0
  %arrayidx24.312 = getelementptr [2 x i8], [2 x i8]* %pair_output_layer, i64 0, i64 0
  %arrayidx24.413 = getelementptr [2 x i8], [2 x i8]* %pair_output_batch, i64 0, i64 0
  %arrayidx24.514 = getelementptr [2 x i8], [2 x i8]* %pair_output_row_space, i64 0, i64 0
  %arrayidx24.615 = getelementptr [2 x i16], [2 x i16]* %pair_output_row0, i64 0, i64 0
  %arrayidx24.716 = getelementptr [2 x i16], [2 x i16]* %pair_output_rows, i64 0, i64 0
  %arrayidx24.817 = getelementptr [2 x i16], [2 x i16]* %pair_output_width, i64 0, i64 0
  %arrayidx24.918 = getelementptr [2 x i8], [2 x i8]* %pair_output_content, i64 0, i64 0
  store i8 %cond, i8* %arrayidx24.0.04, align 512
  store i8 0, i8* %arrayidx24.0.15, align 512
  store i32 %epoch, i32* %arrayidx24.0.26, align 512
  store i8 0, i8* %arrayidx24.110, align 512
  store i8 %stage, i8* %arrayidx24.211, align 512
  store i8 %layer, i8* %arrayidx24.312, align 512
  store i8 -1, i8* %arrayidx24.413, align 512
  store i8 0, i8* %arrayidx24.514, align 512
  store i16 0, i16* %arrayidx24.615, align 512
  store i16 128, i16* %arrayidx24.716, align 512
  store i16 64, i16* %arrayidx24.817, align 512
  store i8 %cond3, i8* %arrayidx24.918, align 512
  %arrayidx26.0.01 = getelementptr [2 x i8], [2 x i8]* %pair_output_ref_id, i64 0, i64 1
  %arrayidx26.0.12 = getelementptr [2 x i8], [2 x i8]* %pair_output_ref_bank, i64 0, i64 1
  %arrayidx26.0.23 = getelementptr [2 x i32], [2 x i32]* %pair_output_ref_epoch, i64 0, i64 1
  %arrayidx26.11 = getelementptr [2 x i8], [2 x i8]* %pair_output_region, i64 0, i64 1
  %arrayidx26.22 = getelementptr [2 x i8], [2 x i8]* %pair_output_stage, i64 0, i64 1
  %arrayidx26.33 = getelementptr [2 x i8], [2 x i8]* %pair_output_layer, i64 0, i64 1
  %arrayidx26.44 = getelementptr [2 x i8], [2 x i8]* %pair_output_batch, i64 0, i64 1
  %arrayidx26.55 = getelementptr [2 x i8], [2 x i8]* %pair_output_row_space, i64 0, i64 1
  %arrayidx26.66 = getelementptr [2 x i16], [2 x i16]* %pair_output_row0, i64 0, i64 1
  %arrayidx26.77 = getelementptr [2 x i16], [2 x i16]* %pair_output_rows, i64 0, i64 1
  %arrayidx26.88 = getelementptr [2 x i16], [2 x i16]* %pair_output_width, i64 0, i64 1
  %arrayidx26.99 = getelementptr [2 x i8], [2 x i8]* %pair_output_content, i64 0, i64 1
  store i8 %cond, i8* %arrayidx26.0.01, align 1
  store i8 1, i8* %arrayidx26.0.12, align 1
  store i32 %epoch, i32* %arrayidx26.0.23, align 4
  store i8 0, i8* %arrayidx26.11, align 1
  store i8 %stage, i8* %arrayidx26.22, align 1
  store i8 %layer, i8* %arrayidx26.33, align 1
  store i8 -1, i8* %arrayidx26.44, align 1
  store i8 0, i8* %arrayidx26.55, align 1
  store i16 0, i16* %arrayidx26.66, align 2
  store i16 128, i16* %arrayidx26.77, align 2
  store i16 64, i16* %arrayidx26.88, align 2
  store i8 %cond3, i8* %arrayidx26.99, align 1
  br label %if.end27

if.end27:                                         ; preds = %if.then18, %if.end
  store i16 0, i16* %agg.result.01, align 512
  store i32 0, i32* %agg.result.12, align 512
  store i64 -1, i64* %agg.result.23, align 512
  br label %cleanup

cleanup:                                          ; preds = %if.end27, %if.then15, %if.then8
  br label %cleanup29

cleanup29:                                        ; preds = %cleanup, %if.then
  ret void
}
