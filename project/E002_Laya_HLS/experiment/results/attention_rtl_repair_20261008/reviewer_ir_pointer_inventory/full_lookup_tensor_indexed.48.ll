define internal fastcc void @"laya::full::full_lookup_tensor_indexed.48"(i16* noalias nocapture align 512 %agg.result.0, i32* noalias nocapture align 512 %agg.result.1, i64* noalias nocapture align 512 %agg.result.2, i64 %name, [48 x i8]* noalias nocapture align 512 %result_name, i8* noalias nocapture align 512 %result_ggml_type_id, i8* noalias nocapture align 512 %result_bo, i8* noalias nocapture align 512 %result_omitted, i8* noalias nocapture align 512 %result_reserved, [4 x i32]* noalias nocapture align 512 %result_ne, i32* noalias nocapture align 512 %result_source_offset, i32* noalias nocapture align 512 %result_source_bytes, i32* noalias nocapture align 512 %result_base, i32* noalias nocapture align 512 %result_span, [32 x i8]* noalias nocapture align 512 %result_source_sha256, i16* noalias nocapture align 512 %index) unnamed_addr #0 {
entry:
  %tobool = icmp ne i64 %name, 0
  br i1 %tobool, label %VITIS_LOOP_259_1, label %if.then

if.then:                                          ; preds = %entry
  store i16 2, i16* %agg.result.0, align 512, !alias.scope !21394, !noalias !21397
  store i32 67108868, i32* %agg.result.1, align 512, !alias.scope !21400, !noalias !21401
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !21402, !noalias !21403
  br label %return

VITIS_LOOP_259_1:                                 ; preds = %entry
  %result.0.0 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 0
  %result.0.1 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 1
  %result.0.2 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 2
  %result.0.3 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 3
  %result.0.4 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 4
  %result.0.5 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 5
  %result.0.6 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 6
  %result.0.7 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 7
  %result.0.8 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 8
  %result.0.9 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 9
  %result.0.10 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 10
  %result.0.11 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 11
  %result.0.12 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 12
  %result.0.13 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 13
  %result.0.14 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 14
  %result.0.15 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 15
  %result.0.16 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 16
  %result.0.17 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 17
  %result.0.18 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 18
  %result.0.19 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 19
  %result.0.20 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 20
  %result.0.21 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 21
  %result.0.22 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 22
  %result.0.23 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 23
  %result.0.24 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 24
  %result.0.25 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 25
  %result.0.26 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 26
  %result.0.27 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 27
  %result.0.28 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 28
  %result.0.29 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 29
  %result.0.30 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 30
  %result.0.31 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 31
  %result.0.32 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 32
  %result.0.33 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 33
  %result.0.34 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 34
  %result.0.35 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 35
  %result.0.36 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 36
  %result.0.37 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 37
  %result.0.38 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 38
  %result.0.39 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 39
  %result.0.40 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 40
  %result.0.41 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 41
  %result.0.42 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 42
  %result.0.43 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 43
  %result.0.44 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 44
  %result.0.45 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 45
  %result.0.46 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 46
  %result.0.47 = getelementptr [48 x i8], [48 x i8]* %result_name, i64 0, i64 47
  %result.5.0 = getelementptr [4 x i32], [4 x i32]* %result_ne, i64 0, i64 0
  %result.5.1 = getelementptr [4 x i32], [4 x i32]* %result_ne, i64 0, i64 1
  %result.5.2 = getelementptr [4 x i32], [4 x i32]* %result_ne, i64 0, i64 2
  %result.5.3 = getelementptr [4 x i32], [4 x i32]* %result_ne, i64 0, i64 3
  %result.10.0 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 0
  %result.10.1 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 1
  %result.10.2 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 2
  %result.10.3 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 3
  %result.10.4 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 4
  %result.10.5 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 5
  %result.10.6 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 6
  %result.10.7 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 7
  %result.10.8 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 8
  %result.10.9 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 9
  %result.10.10 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 10
  %result.10.11 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 11
  %result.10.12 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 12
  %result.10.13 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 13
  %result.10.14 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 14
  %result.10.15 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 15
  %result.10.16 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 16
  %result.10.17 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 17
  %result.10.18 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 18
  %result.10.19 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 19
  %result.10.20 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 20
  %result.10.21 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 21
  %result.10.22 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 22
  %result.10.23 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 23
  %result.10.24 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 24
  %result.10.25 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 25
  %result.10.26 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 26
  %result.10.27 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 27
  %result.10.28 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 28
  %result.10.29 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 29
  %result.10.30 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 30
  %result.10.31 = getelementptr [32 x i8], [32 x i8]* %result_source_sha256, i64 0, i64 31
  br label %VITIS_LOOP_261_2

for.cond:                                         ; preds = %for.body4
  br label %VITIS_LOOP_261_2, !llvm.loop !21404

VITIS_LOOP_261_2:                                 ; preds = %for.cond, %VITIS_LOOP_259_1
  %indvars.iv96 = phi i64 [ 0, %VITIS_LOOP_259_1 ], [ %indvars.iv.next97, %for.cond ]
  %i.094 = phi i32 [ 0, %VITIS_LOOP_259_1 ], [ %inc26, %for.cond ]
  %cmp5 = icmp ult i64 %indvars.iv96, 153
  br i1 %cmp5, label %VITIS_LOOP_261_2.split, label %for.end29, !llvm.loop !21404

VITIS_LOOP_261_2.split:                           ; preds = %VITIS_LOOP_261_2
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 153, i64 76), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @127)
  %indvars.iv.next97 = add nuw nsw i64 %indvars.iv96, 1
  %inc26 = add nuw nsw i32 %i.094, 1
  br label %for.body4

for.body4:                                        ; preds = %if.end13, %VITIS_LOOP_261_2.split
  %indvars.iv = phi i64 [ %indvars.iv.next, %if.end13 ], [ 0, %VITIS_LOOP_261_2.split ]
  %arrayidx72 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 %indvars.iv
  %0 = load i8, i8* %arrayidx72, align 1
  %1 = add i64 %name, %indvars.iv
  %2 = getelementptr [525 x i8], [525 x i8]* @.str.20, i64 0, i64 %1
  %3 = load i8, i8* %2, align 1
  %cmp11 = icmp ne i8 %0, %3
  br i1 %cmp11, label %for.cond, label %if.end13

if.end13:                                         ; preds = %for.body4
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 48, i64 24), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @126)
  %tobool16 = icmp ne i8 %0, 0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %cmp2 = icmp ult i64 %indvars.iv.next, 48
  %or.cond = and i1 %tobool16, %cmp2
  br i1 %or.cond, label %for.body4, label %cleanup27, !llvm.loop !21409

cleanup27:                                        ; preds = %if.end13
  %arrayidx21.11 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.ggml_type_id", i64 0, i64 %indvars.iv96
  %arrayidx21.22 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.bo", i64 0, i64 %indvars.iv96
  %arrayidx21.33 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.omitted", i64 0, i64 %indvars.iv96
  %arrayidx21.44 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.reserved", i64 0, i64 %indvars.iv96
  %arrayidx21.65 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.source_offset", i64 0, i64 %indvars.iv96
  %arrayidx21.76 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.source_bytes", i64 0, i64 %indvars.iv96
  %arrayidx21.87 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.base", i64 0, i64 %indvars.iv96
  %arrayidx21.98 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.span", i64 0, i64 %indvars.iv96
  %arrayidx21.0.09 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 0
  %.0.0 = load i8, i8* %arrayidx21.0.09, align 16
  %arrayidx21.0.110 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 1
  %.0.1 = load i8, i8* %arrayidx21.0.110, align 1
  %arrayidx21.0.211 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 2
  %.0.2 = load i8, i8* %arrayidx21.0.211, align 2
  %arrayidx21.0.312 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 3
  %.0.3 = load i8, i8* %arrayidx21.0.312, align 1
  %arrayidx21.0.413 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 4
  %.0.4 = load i8, i8* %arrayidx21.0.413, align 4
  %arrayidx21.0.514 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 5
  %.0.5 = load i8, i8* %arrayidx21.0.514, align 1
  %arrayidx21.0.615 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 6
  %.0.6 = load i8, i8* %arrayidx21.0.615, align 2
  %arrayidx21.0.716 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 7
  %.0.7 = load i8, i8* %arrayidx21.0.716, align 1
  %arrayidx21.0.817 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 8
  %.0.8 = load i8, i8* %arrayidx21.0.817, align 8
  %arrayidx21.0.918 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 9
  %.0.9 = load i8, i8* %arrayidx21.0.918, align 1
  %arrayidx21.0.1019 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 10
  %.0.10 = load i8, i8* %arrayidx21.0.1019, align 2
  %arrayidx21.0.1120 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 11
  %.0.11 = load i8, i8* %arrayidx21.0.1120, align 1
  %arrayidx21.0.1221 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 12
  %.0.12 = load i8, i8* %arrayidx21.0.1221, align 4
  %arrayidx21.0.1322 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 13
  %.0.13 = load i8, i8* %arrayidx21.0.1322, align 1
  %arrayidx21.0.1423 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 14
  %.0.14 = load i8, i8* %arrayidx21.0.1423, align 2
  %arrayidx21.0.1524 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 15
  %.0.15 = load i8, i8* %arrayidx21.0.1524, align 1
  %arrayidx21.0.1625 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 16
  %.0.16 = load i8, i8* %arrayidx21.0.1625, align 16
  %arrayidx21.0.1726 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 17
  %.0.17 = load i8, i8* %arrayidx21.0.1726, align 1
  %arrayidx21.0.1827 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 18
  %.0.18 = load i8, i8* %arrayidx21.0.1827, align 2
  %arrayidx21.0.1928 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 19
  %.0.19 = load i8, i8* %arrayidx21.0.1928, align 1
  %arrayidx21.0.2029 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 20
  %.0.20 = load i8, i8* %arrayidx21.0.2029, align 4
  %arrayidx21.0.2130 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 21
  %.0.21 = load i8, i8* %arrayidx21.0.2130, align 1
  %arrayidx21.0.2231 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 22
  %.0.22 = load i8, i8* %arrayidx21.0.2231, align 2
  %arrayidx21.0.2332 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 23
  %.0.23 = load i8, i8* %arrayidx21.0.2332, align 1
  %arrayidx21.0.2433 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 24
  %.0.24 = load i8, i8* %arrayidx21.0.2433, align 8
  %arrayidx21.0.2534 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 25
  %.0.25 = load i8, i8* %arrayidx21.0.2534, align 1
  %arrayidx21.0.2635 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 26
  %.0.26 = load i8, i8* %arrayidx21.0.2635, align 2
  %arrayidx21.0.2736 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 27
  %.0.27 = load i8, i8* %arrayidx21.0.2736, align 1
  %arrayidx21.0.2837 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 28
  %.0.28 = load i8, i8* %arrayidx21.0.2837, align 4
  %arrayidx21.0.2938 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 29
  %.0.29 = load i8, i8* %arrayidx21.0.2938, align 1
  %arrayidx21.0.3039 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 30
  %.0.30 = load i8, i8* %arrayidx21.0.3039, align 2
  %arrayidx21.0.3140 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 31
  %.0.31 = load i8, i8* %arrayidx21.0.3140, align 1
  %arrayidx21.0.3241 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 32
  %.0.32 = load i8, i8* %arrayidx21.0.3241, align 16
  %arrayidx21.0.3342 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 33
  %.0.33 = load i8, i8* %arrayidx21.0.3342, align 1
  %arrayidx21.0.3443 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 34
  %.0.34 = load i8, i8* %arrayidx21.0.3443, align 2
  %arrayidx21.0.3544 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 35
  %.0.35 = load i8, i8* %arrayidx21.0.3544, align 1
  %arrayidx21.0.3645 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 36
  %.0.36 = load i8, i8* %arrayidx21.0.3645, align 4
  %arrayidx21.0.3746 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 37
  %.0.37 = load i8, i8* %arrayidx21.0.3746, align 1
  %arrayidx21.0.3847 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 38
  %.0.38 = load i8, i8* %arrayidx21.0.3847, align 2
  %arrayidx21.0.3948 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 39
  %.0.39 = load i8, i8* %arrayidx21.0.3948, align 1
  %arrayidx21.0.4049 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 40
  %.0.40 = load i8, i8* %arrayidx21.0.4049, align 8
  %arrayidx21.0.4150 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 41
  %.0.41 = load i8, i8* %arrayidx21.0.4150, align 1
  %arrayidx21.0.4251 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 42
  %.0.42 = load i8, i8* %arrayidx21.0.4251, align 2
  %arrayidx21.0.4352 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 43
  %.0.43 = load i8, i8* %arrayidx21.0.4352, align 1
  %arrayidx21.0.4453 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 44
  %.0.44 = load i8, i8* %arrayidx21.0.4453, align 4
  %arrayidx21.0.4554 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 45
  %.0.45 = load i8, i8* %arrayidx21.0.4554, align 1
  %arrayidx21.0.4655 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 46
  %.0.46 = load i8, i8* %arrayidx21.0.4655, align 2
  %arrayidx21.0.4756 = getelementptr [153 x [48 x i8]], [153 x [48 x i8]]* @"laya::full::kFullTensors.name", i64 0, i64 %indvars.iv96, i64 47
  %.0.47 = load i8, i8* %arrayidx21.0.4756, align 1
  %.1 = load i8, i8* %arrayidx21.11, align 1
  %.2 = load i8, i8* %arrayidx21.22, align 1
  %.3 = load i8, i8* %arrayidx21.33, align 1
  %.4 = load i8, i8* %arrayidx21.44, align 1
  %arrayidx21.5.057_0 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.ne_0", i64 0, i64 %indvars.iv96
  %.5.0 = load i32, i32* %arrayidx21.5.057_0, align 4
  %arrayidx21.5.158_1 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.ne_1", i64 0, i64 %indvars.iv96
  %.5.1 = load i32, i32* %arrayidx21.5.158_1, align 4
  %arrayidx21.5.259_2 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.ne_2", i64 0, i64 %indvars.iv96
  %.5.2 = load i32, i32* %arrayidx21.5.259_2, align 4
  %arrayidx21.5.360_3 = getelementptr [153 x i32], [153 x i32]* @"laya::full::kFullTensors.ne_3", i64 0, i64 %indvars.iv96
  %.5.3 = load i32, i32* %arrayidx21.5.360_3, align 4
  %.6 = load i32, i32* %arrayidx21.65, align 4
  %.7 = load i32, i32* %arrayidx21.76, align 4
  %.8 = load i32, i32* %arrayidx21.87, align 4
  %.9 = load i32, i32* %arrayidx21.98, align 4
  %arrayidx21.10.061_0 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_0", i64 0, i64 %indvars.iv96
  %.10.0 = load i8, i8* %arrayidx21.10.061_0, align 1
  %arrayidx21.10.162_1 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_1", i64 0, i64 %indvars.iv96
  %.10.1 = load i8, i8* %arrayidx21.10.162_1, align 1
  %arrayidx21.10.263_2 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_2", i64 0, i64 %indvars.iv96
  %.10.2 = load i8, i8* %arrayidx21.10.263_2, align 1
  %arrayidx21.10.364_3 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_3", i64 0, i64 %indvars.iv96
  %.10.3 = load i8, i8* %arrayidx21.10.364_3, align 1
  %arrayidx21.10.465_4 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_4", i64 0, i64 %indvars.iv96
  %.10.4 = load i8, i8* %arrayidx21.10.465_4, align 1
  %arrayidx21.10.566_5 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_5", i64 0, i64 %indvars.iv96
  %.10.5 = load i8, i8* %arrayidx21.10.566_5, align 1
  %arrayidx21.10.667_6 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_6", i64 0, i64 %indvars.iv96
  %.10.6 = load i8, i8* %arrayidx21.10.667_6, align 1
  %arrayidx21.10.768_7 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_7", i64 0, i64 %indvars.iv96
  %.10.7 = load i8, i8* %arrayidx21.10.768_7, align 1
  %arrayidx21.10.869_8 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_8", i64 0, i64 %indvars.iv96
  %.10.8 = load i8, i8* %arrayidx21.10.869_8, align 1
  %arrayidx21.10.970_9 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_9", i64 0, i64 %indvars.iv96
  %.10.9 = load i8, i8* %arrayidx21.10.970_9, align 1
  %arrayidx21.10.1071_10 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_10", i64 0, i64 %indvars.iv96
  %.10.10 = load i8, i8* %arrayidx21.10.1071_10, align 1
  %arrayidx21.10.1172_11 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_11", i64 0, i64 %indvars.iv96
  %.10.11 = load i8, i8* %arrayidx21.10.1172_11, align 1
  %arrayidx21.10.1273_12 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_12", i64 0, i64 %indvars.iv96
  %.10.12 = load i8, i8* %arrayidx21.10.1273_12, align 1
  %arrayidx21.10.1374_13 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_13", i64 0, i64 %indvars.iv96
  %.10.13 = load i8, i8* %arrayidx21.10.1374_13, align 1
  %arrayidx21.10.1475_14 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_14", i64 0, i64 %indvars.iv96
  %.10.14 = load i8, i8* %arrayidx21.10.1475_14, align 1
  %arrayidx21.10.1576_15 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_15", i64 0, i64 %indvars.iv96
  %.10.15 = load i8, i8* %arrayidx21.10.1576_15, align 1
  %arrayidx21.10.1677_16 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_16", i64 0, i64 %indvars.iv96
  %.10.16 = load i8, i8* %arrayidx21.10.1677_16, align 1
  %arrayidx21.10.1778_17 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_17", i64 0, i64 %indvars.iv96
  %.10.17 = load i8, i8* %arrayidx21.10.1778_17, align 1
  %arrayidx21.10.1879_18 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_18", i64 0, i64 %indvars.iv96
  %.10.18 = load i8, i8* %arrayidx21.10.1879_18, align 1
  %arrayidx21.10.1980_19 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_19", i64 0, i64 %indvars.iv96
  %.10.19 = load i8, i8* %arrayidx21.10.1980_19, align 1
  %arrayidx21.10.2081_20 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_20", i64 0, i64 %indvars.iv96
  %.10.20 = load i8, i8* %arrayidx21.10.2081_20, align 1
  %arrayidx21.10.2182_21 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_21", i64 0, i64 %indvars.iv96
  %.10.21 = load i8, i8* %arrayidx21.10.2182_21, align 1
  %arrayidx21.10.2283_22 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_22", i64 0, i64 %indvars.iv96
  %.10.22 = load i8, i8* %arrayidx21.10.2283_22, align 1
  %arrayidx21.10.2384_23 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_23", i64 0, i64 %indvars.iv96
  %.10.23 = load i8, i8* %arrayidx21.10.2384_23, align 1
  %arrayidx21.10.2485_24 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_24", i64 0, i64 %indvars.iv96
  %.10.24 = load i8, i8* %arrayidx21.10.2485_24, align 1
  %arrayidx21.10.2586_25 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_25", i64 0, i64 %indvars.iv96
  %.10.25 = load i8, i8* %arrayidx21.10.2586_25, align 1
  %arrayidx21.10.2687_26 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_26", i64 0, i64 %indvars.iv96
  %.10.26 = load i8, i8* %arrayidx21.10.2687_26, align 1
  %arrayidx21.10.2788_27 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_27", i64 0, i64 %indvars.iv96
  %.10.27 = load i8, i8* %arrayidx21.10.2788_27, align 1
  %arrayidx21.10.2889_28 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_28", i64 0, i64 %indvars.iv96
  %.10.28 = load i8, i8* %arrayidx21.10.2889_28, align 1
  %arrayidx21.10.2990_29 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_29", i64 0, i64 %indvars.iv96
  %.10.29 = load i8, i8* %arrayidx21.10.2990_29, align 1
  %arrayidx21.10.3091_30 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_30", i64 0, i64 %indvars.iv96
  %.10.30 = load i8, i8* %arrayidx21.10.3091_30, align 1
  %arrayidx21.10.3192_31 = getelementptr [153 x i8], [153 x i8]* @"laya::full::kFullTensors.source_sha256_31", i64 0, i64 %indvars.iv96
  %.10.31 = load i8, i8* %arrayidx21.10.3192_31, align 1
  store i8 %.0.0, i8* %result.0.0, align 512
  store i8 %.0.1, i8* %result.0.1, align 1
  store i8 %.0.2, i8* %result.0.2, align 2
  store i8 %.0.3, i8* %result.0.3, align 1
  store i8 %.0.4, i8* %result.0.4, align 4
  store i8 %.0.5, i8* %result.0.5, align 1
  store i8 %.0.6, i8* %result.0.6, align 2
  store i8 %.0.7, i8* %result.0.7, align 1
  store i8 %.0.8, i8* %result.0.8, align 8
  store i8 %.0.9, i8* %result.0.9, align 1
  store i8 %.0.10, i8* %result.0.10, align 2
  store i8 %.0.11, i8* %result.0.11, align 1
  store i8 %.0.12, i8* %result.0.12, align 4
  store i8 %.0.13, i8* %result.0.13, align 1
  store i8 %.0.14, i8* %result.0.14, align 2
  store i8 %.0.15, i8* %result.0.15, align 1
  store i8 %.0.16, i8* %result.0.16, align 16
  store i8 %.0.17, i8* %result.0.17, align 1
  store i8 %.0.18, i8* %result.0.18, align 2
  store i8 %.0.19, i8* %result.0.19, align 1
  store i8 %.0.20, i8* %result.0.20, align 4
  store i8 %.0.21, i8* %result.0.21, align 1
  store i8 %.0.22, i8* %result.0.22, align 2
  store i8 %.0.23, i8* %result.0.23, align 1
  store i8 %.0.24, i8* %result.0.24, align 8
  store i8 %.0.25, i8* %result.0.25, align 1
  store i8 %.0.26, i8* %result.0.26, align 2
  store i8 %.0.27, i8* %result.0.27, align 1
  store i8 %.0.28, i8* %result.0.28, align 4
  store i8 %.0.29, i8* %result.0.29, align 1
  store i8 %.0.30, i8* %result.0.30, align 2
  store i8 %.0.31, i8* %result.0.31, align 1
  store i8 %.0.32, i8* %result.0.32, align 32
  store i8 %.0.33, i8* %result.0.33, align 1
  store i8 %.0.34, i8* %result.0.34, align 2
  store i8 %.0.35, i8* %result.0.35, align 1
  store i8 %.0.36, i8* %result.0.36, align 4
  store i8 %.0.37, i8* %result.0.37, align 1
  store i8 %.0.38, i8* %result.0.38, align 2
  store i8 %.0.39, i8* %result.0.39, align 1
  store i8 %.0.40, i8* %result.0.40, align 8
  store i8 %.0.41, i8* %result.0.41, align 1
  store i8 %.0.42, i8* %result.0.42, align 2
  store i8 %.0.43, i8* %result.0.43, align 1
  store i8 %.0.44, i8* %result.0.44, align 4
  store i8 %.0.45, i8* %result.0.45, align 1
  store i8 %.0.46, i8* %result.0.46, align 2
  store i8 %.0.47, i8* %result.0.47, align 1
  store i8 %.1, i8* %result_ggml_type_id, align 512
  store i8 %.2, i8* %result_bo, align 512
  store i8 %.3, i8* %result_omitted, align 512
  store i8 %.4, i8* %result_reserved, align 512
  store i32 %.5.0, i32* %result.5.0, align 512
  store i32 %.5.1, i32* %result.5.1, align 4
  store i32 %.5.2, i32* %result.5.2, align 8
  store i32 %.5.3, i32* %result.5.3, align 4
  store i32 %.6, i32* %result_source_offset, align 512
  store i32 %.7, i32* %result_source_bytes, align 512
  store i32 %.8, i32* %result_base, align 512
  store i32 %.9, i32* %result_span, align 512
  store i8 %.10.0, i8* %result.10.0, align 512
  store i8 %.10.1, i8* %result.10.1, align 1
  store i8 %.10.2, i8* %result.10.2, align 2
  store i8 %.10.3, i8* %result.10.3, align 1
  store i8 %.10.4, i8* %result.10.4, align 4
  store i8 %.10.5, i8* %result.10.5, align 1
  store i8 %.10.6, i8* %result.10.6, align 2
  store i8 %.10.7, i8* %result.10.7, align 1
  store i8 %.10.8, i8* %result.10.8, align 8
  store i8 %.10.9, i8* %result.10.9, align 1
  store i8 %.10.10, i8* %result.10.10, align 2
  store i8 %.10.11, i8* %result.10.11, align 1
  store i8 %.10.12, i8* %result.10.12, align 4
  store i8 %.10.13, i8* %result.10.13, align 1
  store i8 %.10.14, i8* %result.10.14, align 2
  store i8 %.10.15, i8* %result.10.15, align 1
  store i8 %.10.16, i8* %result.10.16, align 16
  store i8 %.10.17, i8* %result.10.17, align 1
  store i8 %.10.18, i8* %result.10.18, align 2
  store i8 %.10.19, i8* %result.10.19, align 1
  store i8 %.10.20, i8* %result.10.20, align 4
  store i8 %.10.21, i8* %result.10.21, align 1
  store i8 %.10.22, i8* %result.10.22, align 2
  store i8 %.10.23, i8* %result.10.23, align 1
  store i8 %.10.24, i8* %result.10.24, align 8
  store i8 %.10.25, i8* %result.10.25, align 1
  store i8 %.10.26, i8* %result.10.26, align 2
  store i8 %.10.27, i8* %result.10.27, align 1
  store i8 %.10.28, i8* %result.10.28, align 4
  store i8 %.10.29, i8* %result.10.29, align 1
  store i8 %.10.30, i8* %result.10.30, align 2
  store i8 %.10.31, i8* %result.10.31, align 1
  %conv22 = trunc i32 %i.094 to i16
  store i16 %conv22, i16* %index, align 512
  store i16 0, i16* %agg.result.0, align 512, !alias.scope !21415, !noalias !21418
  store i32 0, i32* %agg.result.1, align 512, !alias.scope !21421, !noalias !21422
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !21423, !noalias !21424
  br label %return

for.end29:                                        ; preds = %VITIS_LOOP_261_2
  store i16 2, i16* %agg.result.0, align 512, !alias.scope !21425, !noalias !21428
  store i32 67108868, i32* %agg.result.1, align 512, !alias.scope !21431, !noalias !21432
  store i64 -1, i64* %agg.result.2, align 512, !alias.scope !21433, !noalias !21434
  br label %return

return:                                           ; preds = %for.end29, %cleanup27, %if.then
  ret void
}
