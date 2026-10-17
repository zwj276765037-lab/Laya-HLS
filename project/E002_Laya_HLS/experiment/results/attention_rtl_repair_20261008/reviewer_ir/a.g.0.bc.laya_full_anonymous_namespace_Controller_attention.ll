define internal fastcc void @"laya::full::(anonymous namespace)::Controller::attention"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i64* noalias nocapture align 512 %this_memory.1, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i64* noalias nocapture align 512 %this_memory.3, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i64* noalias nocapture align 512 %this_memory.5, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i64* noalias nocapture align 512 %this_memory.7, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i64* noalias nocapture align 512 %this_memory.9, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i64* noalias nocapture align 512 %this_memory.11, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i64* noalias nocapture align 512 %this_memory.13, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i64* noalias nocapture align 512 %this_memory.15, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i64* noalias nocapture align 512 %this_memory.17, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i64* noalias nocapture align 512 %this_memory.19, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i64* noalias nocapture align 512 %this_memory.21, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i64* noalias nocapture align 512 %this_memory.23, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i64* noalias nocapture align 512 %this_memory.25, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 zeroext %stage, i8 zeroext %layer, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %produced_ref_epoch, [2 x i8]* noalias nocapture align 512 %produced_region, [2 x i8]* noalias nocapture align 512 %produced_stage, [2 x i8]* noalias nocapture align 512 %produced_layer, [2 x i8]* noalias nocapture align 512 %produced_batch, [2 x i8]* noalias nocapture align 512 %produced_row_space, [2 x i16]* noalias nocapture align 512 %produced_row0, [2 x i16]* noalias nocapture align 512 %produced_rows, [2 x i16]* noalias nocapture align 512 %produced_width, i8 %produced_content.0.0.val, i8 %produced_content.0.1.val, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #0 align 2 {
entry:
  %final.ref.id = alloca [2 x i8], align 512
  %final.ref.bank = alloca [2 x i8], align 512
  %final.ref.epoch = alloca [2 x i32], align 512
  %final.region = alloca [2 x i8], align 512
  %final.stage = alloca [2 x i8], align 512
  %final.layer = alloca [2 x i8], align 512
  %final.batch = alloca [2 x i8], align 512
  %final.row_space = alloca [2 x i8], align 512
  %final.row0 = alloca [2 x i16], align 512
  %final.rows = alloca [2 x i16], align 512
  %final.width = alloca [2 x i16], align 512
  %final.content = alloca [2 x i8], align 512
  %load.ctx.task_id = alloca i32, align 512
  %load.ctx.op = alloca i8, align 512
  %load.byte_count = alloca i32, align 512
  %ref.tmp9.0510 = alloca i8, align 512
  %ref.tmp9.1511 = alloca i8, align 512
  %ref.tmp9.2512 = alloca i32, align 512
  %ref.tmp12.0504 = alloca i16, align 512
  %ref.tmp12.1505 = alloca i32, align 512
  %ref.tmp12.2506 = alloca i64, align 512
  %ref.tmp23.0498 = alloca i16, align 512
  %ref.tmp23.1499 = alloca i32, align 512
  %ref.tmp23.2500 = alloca i64, align 512
  %t.src_qkv_ref.id = alloca [2 x i8], align 512
  %t.src_qkv_ref.bank = alloca [2 x i8], align 512
  %t.src_qkv_ref.epoch = alloca [2 x i32], align 512
  %t.dst_qkv_ref.id = alloca [2 x i8], align 512
  %t.dst_qkv_ref.bank = alloca [2 x i8], align 512
  %t.dst_qkv_ref.epoch = alloca [2 x i32], align 512
  %ref.tmp72.0449 = alloca i16, align 512
  %ref.tmp72.1450 = alloca i32, align 512
  %ref.tmp72.2451 = alloca i64, align 512
  %ref.tmp90.0443 = alloca i16, align 512
  %ref.tmp90.1444 = alloca i32, align 512
  %ref.tmp90.2445 = alloca i64, align 512
  %agg.tmp.0 = alloca i8, align 512
  %agg.tmp.1 = alloca i8, align 512
  %agg.tmp.2 = alloca i32, align 512
  %ref.tmp102.0420 = alloca i16, align 512
  %ref.tmp102.1421 = alloca i32, align 512
  %ref.tmp102.2422 = alloca i64, align 512
  %load115.ctx.task_id = alloca i32, align 512
  %load115.ctx.op = alloca i8, align 512
  %load115.byte_count = alloca i32, align 512
  %ref.tmp119.0399 = alloca i8, align 512
  %ref.tmp119.1400 = alloca i8, align 512
  %ref.tmp119.2401 = alloca i32, align 512
  %ref.tmp141.0393 = alloca i16, align 512
  %ref.tmp141.1394 = alloca i32, align 512
  %ref.tmp141.2395 = alloca i64, align 512
  %qk.qkv_ref.id = alloca [2 x i8], align 512
  %qk.qkv_ref.bank = alloca [2 x i8], align 512
  %qk.qkv_ref.epoch = alloca [2 x i32], align 512
  %ref.tmp182.0355 = alloca i8, align 512
  %ref.tmp182.1356 = alloca i8, align 512
  %ref.tmp182.2357 = alloca i32, align 512
  %ref.tmp199.0349 = alloca i16, align 512
  %ref.tmp199.1350 = alloca i32, align 512
  %ref.tmp199.2351 = alloca i64, align 512
  %ref.tmp218.0333 = alloca i16, align 512
  %ref.tmp218.1334 = alloca i32, align 512
  %ref.tmp218.2335 = alloca i64, align 512
  %ref.tmp232.0309 = alloca i16, align 512
  %ref.tmp232.1310 = alloca i32, align 512
  %ref.tmp232.2311 = alloca i64, align 512
  %ref.tmp247.0283 = alloca i8, align 512
  %ref.tmp247.1284 = alloca i8, align 512
  %ref.tmp247.2285 = alloca i32, align 512
  %ref.tmp254.0277 = alloca i16, align 512
  %ref.tmp254.1278 = alloca i32, align 512
  %ref.tmp254.2279 = alloca i64, align 512
  %ref.tmp282.0271 = alloca i16, align 512
  %ref.tmp282.1272 = alloca i32, align 512
  %ref.tmp282.2273 = alloca i64, align 512
  %ref.tmp287.0265 = alloca i16, align 512
  %ref.tmp287.1266 = alloca i32, align 512
  %ref.tmp287.2267 = alloca i64, align 512
  %ref.tmp292.0259 = alloca i16, align 512
  %ref.tmp292.1260 = alloca i32, align 512
  %ref.tmp292.2261 = alloca i64, align 512
  %cmp = icmp eq i8 %stage, 2
  %cond = select i1 %cmp, i8 64, i8 80
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !10307, !noalias !10310
  store i8 %cond, i8* %this_current_op, align 512, !alias.scope !10310, !noalias !10307
  %arrayinit.begin.0.0549 = getelementptr [2 x i8], [2 x i8]* %final.ref.id, i64 0, i64 0
  %arrayinit.begin.0.1550 = getelementptr [2 x i8], [2 x i8]* %final.ref.bank, i64 0, i64 0
  %arrayinit.begin.0.2551 = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 0
  %arrayinit.begin.1540 = getelementptr [2 x i8], [2 x i8]* %final.region, i64 0, i64 0
  %arrayinit.begin.2541 = getelementptr [2 x i8], [2 x i8]* %final.stage, i64 0, i64 0
  %arrayinit.begin.3542 = getelementptr [2 x i8], [2 x i8]* %final.layer, i64 0, i64 0
  %arrayinit.begin.4543 = getelementptr [2 x i8], [2 x i8]* %final.batch, i64 0, i64 0
  %arrayinit.begin.5544 = getelementptr [2 x i8], [2 x i8]* %final.row_space, i64 0, i64 0
  %arrayinit.begin.6545 = getelementptr [2 x i16], [2 x i16]* %final.row0, i64 0, i64 0
  %arrayinit.begin.7546 = getelementptr [2 x i16], [2 x i16]* %final.rows, i64 0, i64 0
  %arrayinit.begin.8547 = getelementptr [2 x i16], [2 x i16]* %final.width, i64 0, i64 0
  %arrayinit.begin.9548 = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 0
  %arrayidx.0.212 = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 0
  %arrayidx.110 = getelementptr [2 x i8], [2 x i8]* %produced_region, i64 0, i64 0
  %arrayidx.211 = getelementptr [2 x i8], [2 x i8]* %produced_stage, i64 0, i64 0
  %arrayidx.312 = getelementptr [2 x i8], [2 x i8]* %produced_layer, i64 0, i64 0
  %arrayidx.413 = getelementptr [2 x i8], [2 x i8]* %produced_batch, i64 0, i64 0
  %arrayidx.514 = getelementptr [2 x i8], [2 x i8]* %produced_row_space, i64 0, i64 0
  %arrayidx.615 = getelementptr [2 x i16], [2 x i16]* %produced_row0, i64 0, i64 0
  %arrayidx.716 = getelementptr [2 x i16], [2 x i16]* %produced_rows, i64 0, i64 0
  %arrayidx.817 = getelementptr [2 x i16], [2 x i16]* %produced_width, i64 0, i64 0
  %.0.2249 = load i32, i32* %arrayidx.0.212, align 512
  %.1250 = load i8, i8* %arrayidx.110, align 512
  %.2251 = load i8, i8* %arrayidx.211, align 512
  %.3252 = load i8, i8* %arrayidx.312, align 512
  %.4253 = load i8, i8* %arrayidx.413, align 512
  %.5254 = load i8, i8* %arrayidx.514, align 512
  %.6255 = load i16, i16* %arrayidx.615, align 512
  %.7256 = load i16, i16* %arrayidx.716, align 512
  %.8257 = load i16, i16* %arrayidx.817, align 512
  store i8 %produced_ref_id.0.0.val, i8* %arrayinit.begin.0.0549, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %arrayinit.begin.0.1550, align 512
  store i32 %.0.2249, i32* %arrayinit.begin.0.2551, align 512
  store i8 %.1250, i8* %arrayinit.begin.1540, align 512
  store i8 %.2251, i8* %arrayinit.begin.2541, align 512
  store i8 %.3252, i8* %arrayinit.begin.3542, align 512
  store i8 %.4253, i8* %arrayinit.begin.4543, align 512
  store i8 %.5254, i8* %arrayinit.begin.5544, align 512
  store i16 %.6255, i16* %arrayinit.begin.6545, align 512
  store i16 %.7256, i16* %arrayinit.begin.7546, align 512
  store i16 %.8257, i16* %arrayinit.begin.8547, align 512
  store i8 %produced_content.0.0.val, i8* %arrayinit.begin.9548, align 512
  %arrayinit.element1.0.0552 = getelementptr [2 x i8], [2 x i8]* %final.ref.id, i64 0, i64 1
  %arrayinit.element1.0.1553 = getelementptr [2 x i8], [2 x i8]* %final.ref.bank, i64 0, i64 1
  %arrayinit.element1.0.2554 = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 1
  %arrayinit.element1.1531 = getelementptr [2 x i8], [2 x i8]* %final.region, i64 0, i64 1
  %arrayinit.element1.2532 = getelementptr [2 x i8], [2 x i8]* %final.stage, i64 0, i64 1
  %arrayinit.element1.3533 = getelementptr [2 x i8], [2 x i8]* %final.layer, i64 0, i64 1
  %arrayinit.element1.4534 = getelementptr [2 x i8], [2 x i8]* %final.batch, i64 0, i64 1
  %arrayinit.element1.5535 = getelementptr [2 x i8], [2 x i8]* %final.row_space, i64 0, i64 1
  %arrayinit.element1.6536 = getelementptr [2 x i16], [2 x i16]* %final.row0, i64 0, i64 1
  %arrayinit.element1.7537 = getelementptr [2 x i16], [2 x i16]* %final.rows, i64 0, i64 1
  %arrayinit.element1.8538 = getelementptr [2 x i16], [2 x i16]* %final.width, i64 0, i64 1
  %arrayinit.element1.9539 = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 1
  %arrayidx2.0.29 = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 1
  %arrayidx2.11 = getelementptr [2 x i8], [2 x i8]* %produced_region, i64 0, i64 1
  %arrayidx2.22 = getelementptr [2 x i8], [2 x i8]* %produced_stage, i64 0, i64 1
  %arrayidx2.33 = getelementptr [2 x i8], [2 x i8]* %produced_layer, i64 0, i64 1
  %arrayidx2.44 = getelementptr [2 x i8], [2 x i8]* %produced_batch, i64 0, i64 1
  %arrayidx2.55 = getelementptr [2 x i8], [2 x i8]* %produced_row_space, i64 0, i64 1
  %arrayidx2.66 = getelementptr [2 x i16], [2 x i16]* %produced_row0, i64 0, i64 1
  %arrayidx2.77 = getelementptr [2 x i16], [2 x i16]* %produced_rows, i64 0, i64 1
  %arrayidx2.88 = getelementptr [2 x i16], [2 x i16]* %produced_width, i64 0, i64 1
  %.0.2237 = load i32, i32* %arrayidx2.0.29, align 4
  %.1238 = load i8, i8* %arrayidx2.11, align 1
  %.2239 = load i8, i8* %arrayidx2.22, align 1
  %.3240 = load i8, i8* %arrayidx2.33, align 1
  %.4241 = load i8, i8* %arrayidx2.44, align 1
  %.5242 = load i8, i8* %arrayidx2.55, align 1
  %.6243 = load i16, i16* %arrayidx2.66, align 2
  %.7244 = load i16, i16* %arrayidx2.77, align 2
  %.8245 = load i16, i16* %arrayidx2.88, align 2
  store i8 %produced_ref_id.0.1.val, i8* %arrayinit.element1.0.0552, align 1
  store i8 %produced_ref_bank.0.1.val, i8* %arrayinit.element1.0.1553, align 1
  store i32 %.0.2237, i32* %arrayinit.element1.0.2554, align 4
  store i8 %.1238, i8* %arrayinit.element1.1531, align 1
  store i8 %.2239, i8* %arrayinit.element1.2532, align 1
  store i8 %.3240, i8* %arrayinit.element1.3533, align 1
  store i8 %.4241, i8* %arrayinit.element1.4534, align 1
  store i8 %.5242, i8* %arrayinit.element1.5535, align 1
  store i16 %.6243, i16* %arrayinit.element1.6536, align 2
  store i16 %.7244, i16* %arrayinit.element1.7537, align 2
  store i16 %.8245, i16* %arrayinit.element1.8538, align 2
  store i8 %produced_content.0.1.val, i8* %arrayinit.element1.9539, align 1
  store i16 0, i16* %agg.result_code, align 512, !alias.scope !10312, !noalias !10315
  store i32 0, i32* %agg.result_detail, align 512, !alias.scope !10318, !noalias !10319
  store i64 -1, i64* %agg.result_bad_element, align 512, !alias.scope !10320, !noalias !10321
  br i1 %cmp, label %if.then, label %if.end100

if.then:                                          ; preds = %entry
  %conv5 = zext i8 %layer to i32
  %rem = urem i32 %conv5, 3
  %cmp6 = icmp eq i32 %rem, 0
  %conv8 = select i1 %cmp6, i8 0, i8 1
  %0 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10322, !noalias !10325
  %add.i = add i32 %0, 1
  store i32 %add.i, i32* %load.ctx.task_id, align 512
  store i8 -125, i8* %load.ctx.op, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp9.0510, i8* %ref.tmp9.1511, i32* %ref.tmp9.2512, i8 43, i8 %conv8, i8 0)
  %.0224 = load i8, i8* %ref.tmp9.0510, align 512
  %.1225 = load i8, i8* %ref.tmp9.1511, align 512
  %.2226 = load i32, i32* %ref.tmp9.2512, align 512
  store i32 524800, i32* %load.byte_count, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LoadTask>"(i16* %ref.tmp12.0504, i32* %ref.tmp12.1505, i64* %ref.tmp12.2506, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32* %load.ctx.task_id, i8* %load.ctx.op, i8 2, i8 %layer, i8 3, i8 %.0224, i8 %.1225, i32 %.2226, i8 0, i8 -1, i8 -1, i8 0, i32* %load.byte_count, i32 524800)
  %.0218 = load i16, i16* %ref.tmp12.0504, align 512
  %.1220 = load i32, i32* %ref.tmp12.1505, align 512
  %.2222 = load i64, i64* %ref.tmp12.2506, align 512
  store i16 %.0218, i16* %agg.result_code, align 512
  store i32 %.1220, i32* %agg.result_detail, align 512
  store i64 %.2222, i64* %agg.result_bad_element, align 512
  %cmp.i = icmp eq i16 %.0218, 0
  br i1 %cmp.i, label %if.end, label %cleanup297.critedge

if.end:                                           ; preds = %if.then
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !10334, !noalias !10337
  store i8 64, i8* %this_current_op, align 512, !alias.scope !10337, !noalias !10334
  br label %for.inc

for.inc:                                          ; preds = %for.inc.split, %if.end
  %indvars.iv = phi i64 [ 0, %if.end ], [ %indvars.iv.next, %for.inc.split ]
  %exitcond8 = icmp ne i64 %indvars.iv, 2
  br i1 %exitcond8, label %for.inc.split, label %for.end, !llvm.loop !10339

for.inc.split:                                    ; preds = %for.inc
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @197)
  %epoch30 = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 %indvars.iv
  %1 = load i32, i32* %epoch30, align 4
  %add = add i32 %1, 1
  %epoch2032 = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 %indvars.iv
  store i32 %add, i32* %epoch2032, align 4
  %content33 = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 %indvars.iv
  store i8 3, i8* %content33, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.inc, !llvm.loop !10339

for.end:                                          ; preds = %for.inc
  call fastcc void @"laya::full::full_begin_qkv_rope_pair"(i16* %ref.tmp23.0498, i32* %ref.tmp23.1499, i64* %ref.tmp23.2500, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, [2 x i32]* %produced_ref_epoch, [2 x i8]* %produced_region, [2 x i8]* %produced_stage, [2 x i8]* %produced_layer, [2 x i8]* %produced_batch, [2 x i8]* %produced_row_space, [2 x i16]* %produced_row0, [2 x i16]* %produced_rows, [2 x i16]* %produced_width, i8 %produced_content.0.0.val, i8 %produced_content.0.1.val, [2 x i8]* %final.ref.id, [2 x i8]* %final.ref.bank, [2 x i32]* %final.ref.epoch, [2 x i8]* %final.region, [2 x i8]* %final.stage, [2 x i8]* %final.layer, [2 x i8]* %final.batch, [2 x i8]* %final.row_space, [2 x i16]* %final.row0, [2 x i16]* %final.rows, [2 x i16]* %final.width, [2 x i8]* %final.content)
  %.0212 = load i16, i16* %ref.tmp23.0498, align 512
  %.1214 = load i32, i32* %ref.tmp23.1499, align 512
  %.2216 = load i64, i64* %ref.tmp23.2500, align 512
  store i16 %.0212, i16* %agg.result_code, align 512
  store i32 %.1214, i32* %agg.result_detail, align 512
  store i64 %.2216, i64* %agg.result_bad_element, align 512
  %cmp.i9 = icmp eq i16 %.0212, 0
  br i1 %cmp.i9, label %VITIS_LOOP_278_2, label %cleanup297.critedge13

VITIS_LOOP_278_2:                                 ; preds = %for.end
  %t.src_qkv_ref.cast494 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 0
  %t.dst_qkv_ref.cast491 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 0
  %src_qkv_ref.0.0.1 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 0
  %src_qkv_ref.0.0.2 = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 0
  %src_qkv_ref.0.1.0 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 1
  %src_qkv_ref.0.1.1 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 1
  %src_qkv_ref.0.1.2 = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 1
  %.2191 = load i32, i32* %arrayinit.begin.0.2551, align 512
  %.2188 = load i32, i32* %arrayinit.element1.0.2554, align 4
  %dst_qkv_ref.0.0.1 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 0
  %dst_qkv_ref.0.0.2 = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 0
  %dst_qkv_ref.0.1.0 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 1
  %dst_qkv_ref.0.1.1 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 1
  %dst_qkv_ref.0.1.2 = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 1
  br label %for.cond28

for.cond28:                                       ; preds = %for.inc84, %VITIS_LOOP_278_2
  %2 = phi i16 [ 0, %VITIS_LOOP_278_2 ], [ %4, %for.inc84 ]
  %3 = phi i16 [ 0, %VITIS_LOOP_278_2 ], [ %11, %for.inc84 ]
  %head27.0 = phi i32 [ 0, %VITIS_LOOP_278_2 ], [ %inc85, %for.inc84 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %cmp29 = icmp uge i32 %head27.0, 16
  %cmp.i15 = icmp eq i16 %3, 0
  %cmp.i15.not = xor i1 %cmp.i15, true
  %brmerge = or i1 %cmp29, %cmp.i15.not
  br i1 %brmerge, label %for.end87, label %VITIS_LOOP_279_3

VITIS_LOOP_279_3:                                 ; preds = %for.cond28
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @196)
  %conv69 = trunc i32 %head27.0 to i8
  br label %for.cond33

for.cond33:                                       ; preds = %for.inc80, %VITIS_LOOP_279_3
  %4 = phi i16 [ %2, %VITIS_LOOP_279_3 ], [ %10, %for.inc80 ]
  %5 = phi i16 [ 0, %VITIS_LOOP_279_3 ], [ %10, %for.inc80 ]
  %b.0 = phi i32 [ 0, %VITIS_LOOP_279_3 ], [ %inc81, %for.inc80 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %6 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv35 = zext i16 %6 to i32
  %cmp36 = icmp ult i32 %b.0, %conv35
  br i1 %cmp36, label %land.rhs37, label %for.inc84

land.rhs37:                                       ; preds = %for.cond33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @195)
  %cmp.i11 = icmp eq i16 %4, 0
  br i1 %cmp.i11, label %VITIS_LOOP_280_4, label %for.inc84

VITIS_LOOP_280_4:                                 ; preds = %land.rhs37
  %conv51 = trunc i32 %b.0 to i8
  br label %for.cond42

for.cond42:                                       ; preds = %for.inc76, %VITIS_LOOP_280_4
  %7 = phi i16 [ 0, %VITIS_LOOP_280_4 ], [ %.0174, %for.inc76 ]
  %row.0 = phi i32 [ 0, %VITIS_LOOP_280_4 ], [ %add77, %for.inc76 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %8 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %conv46 = zext i16 %8 to i32
  %cmp47 = icmp ult i32 %row.0, %conv46
  br i1 %cmp47, label %for.body49, label %for.inc80

for.body49:                                       ; preds = %for.cond42
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @194)
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %for.body49
  %arrayinit.curidx.i = phi i64 [ 0, %for.body49 ], [ %arrayinit.nextidx.i, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.nextidx.i = add nuw nsw i64 %arrayinit.curidx.i, 1
  %id3.i = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 %arrayinit.curidx.i
  store i8 0, i8* %id3.i, align 8, !alias.scope !10468, !noalias !10471
  %bank4.i = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 %arrayinit.curidx.i
  store i8 0, i8* %bank4.i, align 1, !alias.scope !10468, !noalias !10471
  %epoch5.i = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 %arrayinit.curidx.i
  store i32 0, i32* %epoch5.i, align 4, !alias.scope !10468, !noalias !10471
  %arrayinit.done.i = icmp eq i64 %arrayinit.curidx.i, 1
  br i1 %arrayinit.done.i, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !10484

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  br label %arrayinit.body4.i

arrayinit.body4.i:                                ; preds = %arrayinit.body4.i, %arrayinit.end.i
  %arrayinit.curidx5.i = phi i64 [ 0, %arrayinit.end.i ], [ %arrayinit.nextidx7.i, %arrayinit.body4.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.nextidx7.i = add nuw nsw i64 %arrayinit.curidx5.i, 1
  %id88.i = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 %arrayinit.curidx5.i
  store i8 0, i8* %id88.i, align 8, !alias.scope !10486, !noalias !10487
  %bank99.i = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 %arrayinit.curidx5.i
  store i8 0, i8* %bank99.i, align 1, !alias.scope !10486, !noalias !10487
  %epoch1010.i = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 %arrayinit.curidx5.i
  store i32 0, i32* %epoch1010.i, align 4, !alias.scope !10486, !noalias !10487
  %arrayinit.done11.i = icmp eq i64 %arrayinit.curidx5.i, 1
  br i1 %arrayinit.done11.i, label %_ZN4laya8RopeTaskC2Ev.exit, label %arrayinit.body4.i, !llvm.loop !10488

_ZN4laya8RopeTaskC2Ev.exit:                       ; preds = %arrayinit.body4.i
  %conv52 = trunc i32 %row.0 to i16
  %9 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10490, !noalias !10493
  %add.i13 = add i32 %9, 1
  store i8 %produced_ref_id.0.0.val, i8* %t.src_qkv_ref.cast494, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %src_qkv_ref.0.0.1, align 512
  store i32 %.0.2249, i32* %src_qkv_ref.0.0.2, align 512
  store i8 %produced_ref_id.0.1.val, i8* %src_qkv_ref.0.1.0, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %src_qkv_ref.0.1.1, align 1
  store i32 %.0.2237, i32* %src_qkv_ref.0.1.2, align 4
  store i8 %produced_ref_id.0.0.val, i8* %t.dst_qkv_ref.cast491, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %dst_qkv_ref.0.0.1, align 512
  store i32 %.2191, i32* %dst_qkv_ref.0.0.2, align 512
  store i8 %produced_ref_id.0.1.val, i8* %dst_qkv_ref.0.1.0, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %dst_qkv_ref.0.1.1, align 1
  store i32 %.2188, i32* %dst_qkv_ref.0.1.2, align 4
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::RopeTask>"(i16* %ref.tmp72.0449, i32* %ref.tmp72.1450, i64* %ref.tmp72.2451, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i13, i8 %layer, i8 %conv51, i16 %conv52, [2 x i8]* %t.src_qkv_ref.id, [2 x i8]* %t.src_qkv_ref.bank, [2 x i32]* %t.src_qkv_ref.epoch, [2 x i8]* %t.dst_qkv_ref.id, [2 x i8]* %t.dst_qkv_ref.bank, [2 x i32]* %t.dst_qkv_ref.epoch, i8 %conv69, i8 %conv8, i8 %conv8)
  %.0174 = load i16, i16* %ref.tmp72.0449, align 512
  %.1176 = load i32, i32* %ref.tmp72.1450, align 512
  %.2178 = load i64, i64* %ref.tmp72.2451, align 512
  store i16 %.0174, i16* %agg.result_code, align 512
  store i32 %.1176, i32* %agg.result_detail, align 512
  store i64 %.2178, i64* %agg.result_bad_element, align 512
  %cmp.i14 = icmp eq i16 %.0174, 0
  %cleanup.dest.slot.0 = select i1 %cmp.i14, i1 true, i1 false
  br i1 %cleanup.dest.slot.0, label %for.inc76, label %for.inc80

for.inc76:                                        ; preds = %_ZN4laya8RopeTaskC2Ev.exit
  %add77 = add nuw nsw i32 %row.0, 16
  br label %for.cond42, !llvm.loop !10502

for.inc80:                                        ; preds = %_ZN4laya8RopeTaskC2Ev.exit, %for.cond42
  %10 = phi i16 [ %.0174, %_ZN4laya8RopeTaskC2Ev.exit ], [ %7, %for.cond42 ]
  %inc81 = add nuw nsw i32 %b.0, 1
  br label %for.cond33, !llvm.loop !10512

for.inc84:                                        ; preds = %land.rhs37, %for.cond33
  %11 = phi i16 [ %5, %for.cond33 ], [ %4, %land.rhs37 ]
  %inc85 = add nuw nsw i32 %head27.0, 1
  br label %for.cond28, !llvm.loop !10516

for.end87:                                        ; preds = %for.cond28
  br i1 %cmp.i15, label %if.then89, label %if.end92

if.then89:                                        ; preds = %for.end87
  %final.content.idx.val = load i8, i8* %arrayinit.begin.9548, align 512
  %final.content.idx26.val = load i8, i8* %arrayinit.element1.9539, align 4
  call fastcc void @"laya::full::full_commit_qkv_rope_pair"(i16* %ref.tmp90.0443, i32* %ref.tmp90.1444, i64* %ref.tmp90.2445, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, i32 %.2191, i32 %.2188, i8 %.1250, i8 %.1238, i8 %.2251, i8 %.2239, i8 %.3252, i8 %.3240, i8 %.4253, i8 %.4241, i8 %.5254, i8 %.5242, i16 %.6255, i16 %.6243, i16 %.7256, i16 %.7244, i16 %.8257, i16 %.8245, i8 %final.content.idx.val, i8 %final.content.idx26.val)
  %.0168 = load i16, i16* %ref.tmp90.0443, align 512
  %.1170 = load i32, i32* %ref.tmp90.1444, align 512
  %.2172 = load i64, i64* %ref.tmp90.2445, align 512
  store i16 %.0168, i16* %agg.result_code, align 512
  store i32 %.1170, i32* %agg.result_detail, align 512
  store i64 %.2172, i64* %agg.result_bad_element, align 512
  br label %if.end92

if.end92:                                         ; preds = %if.then89, %for.end87
  %12 = phi i16 [ %.0168, %if.then89 ], [ %2, %for.end87 ]
  %cmp.i16 = icmp eq i16 %12, 0
  %spec.select8 = select i1 %cmp.i16, i1 true, i1 false
  br i1 %spec.select8, label %if.end100, label %cleanup297

if.end100:                                        ; preds = %if.end92, %entry
  %arrayinit.element1.0.2554.val = phi i32 [ %.2188, %if.end92 ], [ %.0.2237, %entry ]
  %arrayinit.begin.0.2551.val = phi i32 [ %.2191, %if.end92 ], [ %.0.2249, %entry ]
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp.0, i8* %agg.tmp.1, i32* %agg.tmp.2, i8 8, i8 0, i8 0)
  %13 = load i8, i8* %agg.tmp.0, align 512
  %14 = load i8, i8* %agg.tmp.1, align 512
  %15 = load i32, i32* %agg.tmp.2, align 512
  %16 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  store i8 %13, i8* %output_ref_id, align 512
  store i8 %14, i8* %output_ref_bank, align 512
  store i32 %15, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 0, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %16, i16* %output_rows, align 512
  store i16 1024, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !10520, !noalias !10523
  store i8 82, i8* %this_current_op, align 512, !alias.scope !10523, !noalias !10520
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp102.0420, i32* %ref.tmp102.1421, i64* %ref.tmp102.2422, i8 %13, i8 %14, i32 %15, i8 0, i8 %stage, i8 %layer, i8 -1, i8 0, i16 0, i16 %16, i16 1024, i8 1)
  %.0150 = load i16, i16* %ref.tmp102.0420, align 512
  %.1152 = load i32, i32* %ref.tmp102.1421, align 512
  %.2154 = load i64, i64* %ref.tmp102.2422, align 512
  store i16 %.0150, i16* %agg.result_code, align 512
  store i32 %.1152, i32* %agg.result_detail, align 512
  store i64 %.2154, i64* %agg.result_bad_element, align 512
  %cmp.i17 = icmp eq i16 %.0150, 0
  br i1 %cmp.i17, label %VITIS_LOOP_298_5, label %cleanup297

VITIS_LOOP_298_5:                                 ; preds = %if.end100
  %qk.qkv_ref.cast389 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 0
  %qkv_ref.0.0.1 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 0
  %qkv_ref.0.0.2 = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 0
  %qkv_ref.0.1.0 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 1
  %qkv_ref.0.1.1 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 1
  %qkv_ref.0.1.2 = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 1
  %conv188 = zext i8 %layer to i32
  %rem189 = urem i32 %conv188, 3
  %cmp190 = icmp ne i32 %rem189, 0
  %spec.select = select i1 %cmp, i1 %cmp190, i1 false
  %conv193 = select i1 %spec.select, i8 1, i8 0
  br label %for.cond108

for.cond108:                                      ; preds = %for.inc276, %VITIS_LOOP_298_5
  %17 = phi i16 [ 0, %VITIS_LOOP_298_5 ], [ %22, %for.inc276 ]
  %18 = phi i16 [ 0, %VITIS_LOOP_298_5 ], [ %23, %for.inc276 ]
  %head107.0 = phi i32 [ 0, %VITIS_LOOP_298_5 ], [ %inc277, %for.inc276 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %cmp109 = icmp ult i32 %head107.0, 16
  %cmp.i18 = icmp eq i16 %18, 0
  %or.cond = and i1 %cmp109, %cmp.i18
  br i1 %or.cond, label %for.body114, label %for.end279.loopexit

for.body114:                                      ; preds = %for.cond108
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @193)
  %19 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10525, !noalias !10528
  %add.i20 = add i32 %19, 1
  store i32 %add.i20, i32* %load115.ctx.task_id, align 512
  store i8 -127, i8* %load115.ctx.op, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp119.0399, i8* %ref.tmp119.1400, i32* %ref.tmp119.2401, i8 37, i8 0, i8 0)
  %.0139 = load i8, i8* %ref.tmp119.0399, align 512
  %.1140 = load i8, i8* %ref.tmp119.1400, align 512
  %.2141 = load i32, i32* %ref.tmp119.2401, align 512
  %conv125 = trunc i32 %head107.0 to i8
  %20 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv131 = zext i16 %20 to i32
  %21 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %conv136 = zext i16 %21 to i32
  %thr.mul18 = mul nuw nsw i32 256, %conv136
  %thr.mul19 = mul nuw nsw i32 2, %conv131
  %thr.mul20 = mul i32 %thr.mul18, %thr.mul19
  store i32 %thr.mul20, i32* %load115.byte_count, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LoadTask>"(i16* %ref.tmp141.0393, i32* %ref.tmp141.1394, i64* %ref.tmp141.2395, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32* %load115.ctx.task_id, i8* %load115.ctx.op, i8 %stage, i8 %layer, i8 1, i8 %.0139, i8 %.1140, i32 %.2141, i8 0, i8 -1, i8 %conv125, i8 3, i32* %load115.byte_count, i32 %thr.mul20)
  %.0133 = load i16, i16* %ref.tmp141.0393, align 512
  %.1135 = load i32, i32* %ref.tmp141.1394, align 512
  %.2137 = load i64, i64* %ref.tmp141.2395, align 512
  store i16 %.0133, i16* %agg.result_code, align 512
  store i32 %.1135, i32* %agg.result_detail, align 512
  store i64 %.2137, i64* %agg.result_bad_element, align 512
  %cmp.i21 = icmp eq i16 %.0133, 0
  br i1 %cmp.i21, label %VITIS_LOOP_310_6, label %cleanup273

VITIS_LOOP_310_6:                                 ; preds = %for.body114
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !10537, !noalias !10540
  store i8 80, i8* %this_current_op, align 512, !alias.scope !10540, !noalias !10537
  br label %for.cond147

for.cond147:                                      ; preds = %for.inc269, %VITIS_LOOP_310_6
  %22 = phi i16 [ 0, %VITIS_LOOP_310_6 ], [ %32, %for.inc269 ]
  %23 = phi i16 [ 0, %VITIS_LOOP_310_6 ], [ %33, %for.inc269 ]
  %b146.0 = phi i32 [ 0, %VITIS_LOOP_310_6 ], [ %inc270, %for.inc269 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %24 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %conv152 = zext i16 %24 to i32
  %cmp153 = icmp ult i32 %b146.0, %conv152
  %cmp.i22 = icmp eq i16 %23, 0
  %or.cond44 = and i1 %cmp153, %cmp.i22
  br i1 %or.cond44, label %VITIS_LOOP_311_7, label %for.inc276

VITIS_LOOP_311_7:                                 ; preds = %for.cond147
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @192)
  %conv170 = trunc i32 %b146.0 to i8
  br label %for.cond160

for.cond160:                                      ; preds = %for.inc265, %VITIS_LOOP_311_7
  %25 = phi i16 [ %22, %VITIS_LOOP_311_7 ], [ %31, %for.inc265 ]
  %26 = phi i16 [ 0, %VITIS_LOOP_311_7 ], [ %31, %for.inc265 ]
  %row159.0 = phi i32 [ 0, %VITIS_LOOP_311_7 ], [ %add266, %for.inc265 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  %27 = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %conv165 = zext i16 %27 to i32
  %cmp166 = icmp ult i32 %row159.0, %conv165
  br i1 %cmp166, label %for.body168, label %for.inc269

for.body168:                                      ; preds = %for.cond160
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @191)
  br label %arrayinit.body.i29

arrayinit.body.i29:                               ; preds = %arrayinit.body.i29, %for.body168
  %arrayinit.curidx.i23 = phi i64 [ 0, %for.body168 ], [ %arrayinit.nextidx.i24, %arrayinit.body.i29 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %arrayinit.nextidx.i24 = add nuw nsw i64 %arrayinit.curidx.i23, 1
  %id3.i25 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 %arrayinit.curidx.i23
  store i8 0, i8* %id3.i25, align 8, !alias.scope !10542, !noalias !10545
  %bank4.i26 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 %arrayinit.curidx.i23
  store i8 0, i8* %bank4.i26, align 1, !alias.scope !10542, !noalias !10545
  %epoch5.i27 = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 %arrayinit.curidx.i23
  store i32 0, i32* %epoch5.i27, align 4, !alias.scope !10542, !noalias !10545
  %arrayinit.done.i28 = icmp eq i64 %arrayinit.curidx.i23, 1
  br i1 %arrayinit.done.i28, label %_ZN4laya6QKTaskC2Ev.exit, label %arrayinit.body.i29, !llvm.loop !10564

_ZN4laya6QKTaskC2Ev.exit:                         ; preds = %arrayinit.body.i29
  %conv171 = trunc i32 %row159.0 to i16
  %28 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10566, !noalias !10569
  %add.i32 = add i32 %28, 1
  store i8 %produced_ref_id.0.0.val, i8* %qk.qkv_ref.cast389, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %qkv_ref.0.0.1, align 512
  store i32 %arrayinit.begin.0.2551.val, i32* %qkv_ref.0.0.2, align 512
  store i8 %produced_ref_id.0.1.val, i8* %qkv_ref.0.1.0, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %qkv_ref.0.1.1, align 1
  store i32 %arrayinit.element1.0.2554.val, i32* %qkv_ref.0.1.2, align 4
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp182.0355, i8* %ref.tmp182.1356, i32* %ref.tmp182.2357, i8 38, i8 0, i8 0)
  %.0113 = load i8, i8* %ref.tmp182.0355, align 512
  %.1114 = load i8, i8* %ref.tmp182.1356, align 512
  %.2115 = load i32, i32* %ref.tmp182.2357, align 512
  %mul202 = mul nuw nsw i32 16, %conv165
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QKTask>"(i16* %ref.tmp199.0349, i32* %ref.tmp199.1350, i64* %ref.tmp199.2351, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i32, i8 %stage, i8 %layer, i8 %conv170, i16 %conv171, [2 x i8]* %qk.qkv_ref.id, [2 x i8]* %qk.qkv_ref.bank, [2 x i32]* %qk.qkv_ref.epoch, i8 %.0139, i8 %.1140, i32 %.2141, i8 %.0113, i8 %.1114, i32 %.2115, i8 %conv125, i8 %conv193, i16 %27, i32 %mul202)
  %.0107 = load i16, i16* %ref.tmp199.0349, align 512
  %.1109 = load i32, i32* %ref.tmp199.1350, align 512
  %.2111 = load i64, i64* %ref.tmp199.2351, align 512
  store i16 %.0107, i16* %agg.result_code, align 512
  store i32 %.1109, i32* %agg.result_detail, align 512
  store i64 %.2111, i64* %agg.result_bad_element, align 512
  %cmp.i33 = icmp eq i16 %.0107, 0
  br i1 %cmp.i33, label %if.end205, label %cleanup262

if.end205:                                        ; preds = %_ZN4laya6QKTaskC2Ev.exit
  %add216 = add i32 %.2115, 1
  call fastcc void @"laya::full::full_begin_inplace_owner"(i16* %ref.tmp218.0333, i32* %ref.tmp218.1334, i64* %ref.tmp218.2335, i8 %.0113, i8 %.1114, i32 %.2115, i8 0, i8 %stage, i8 %layer, i8 %conv170, i8 0, i16 %conv171, i16 16, i16 %27, i8 6, i8 %.0113, i8 %.1114, i32 %add216, i8 0, i8 %stage, i8 %layer, i8 %conv170, i8 0, i16 %conv171, i16 16, i16 %27, i8 7)
  %.091 = load i16, i16* %ref.tmp218.0333, align 512
  %.193 = load i32, i32* %ref.tmp218.1334, align 512
  %.295 = load i64, i64* %ref.tmp218.2335, align 512
  store i16 %.091, i16* %agg.result_code, align 512
  store i32 %.193, i32* %agg.result_detail, align 512
  store i64 %.295, i64* %agg.result_bad_element, align 512
  %cmp.i34 = icmp eq i16 %.091, 0
  br i1 %cmp.i34, label %if.end222, label %cleanup262

if.end222:                                        ; preds = %if.end205
  %29 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10578, !noalias !10581
  %add.i36 = add i32 %29, 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::SoftmaxTask>"(i16* %ref.tmp232.0309, i32* %ref.tmp232.1310, i64* %ref.tmp232.2311, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i36, i8 81, i8 %stage, i8 %layer, i8 %conv170, i8 0, i16 %conv171, i8 16, i8 %.0113, i8 %.1114, i32 %.2115, i8 %.0113, i8 %.1114, i32 %add216, i16 %27, i8 0, i8 0, i8 0, i32 %mul202)
  %.071 = load i16, i16* %ref.tmp232.0309, align 512
  %.173 = load i32, i32* %ref.tmp232.1310, align 512
  %.275 = load i64, i64* %ref.tmp232.2311, align 512
  store i16 %.071, i16* %agg.result_code, align 512
  store i32 %.173, i32* %agg.result_detail, align 512
  store i64 %.275, i64* %agg.result_bad_element, align 512
  %cmp.i37 = icmp eq i16 %.071, 0
  br i1 %cmp.i37, label %if.end238, label %cleanup262

if.end238:                                        ; preds = %if.end222
  %30 = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !10590, !noalias !10593
  %add.i39 = add i32 %30, 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp247.0283, i8* %ref.tmp247.1284, i32* %ref.tmp247.2285, i8 40, i8 0, i8 0)
  %.059 = load i8, i8* %ref.tmp247.0283, align 512
  %.160 = load i8, i8* %ref.tmp247.1284, align 512
  %.261 = load i32, i32* %ref.tmp247.2285, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::AVTask>"(i16* %ref.tmp254.0277, i32* %ref.tmp254.1278, i64* %ref.tmp254.2279, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i64* %this_memory.5, i64* %this_memory.7, i64* %this_memory.9, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %add.i39, i8 %stage, i8 %layer, i8 %conv170, i16 %conv171, i8 %.0113, i8 %.1114, i32 %add216, i8 %.0139, i8 %.1140, i32 %.2141, i8 %.059, i8 %.160, i32 %.261, i8 %13, i8 %14, i32 %15, i8 %conv125, i16 %27)
  %.050 = load i16, i16* %ref.tmp254.0277, align 512
  %.152 = load i32, i32* %ref.tmp254.1278, align 512
  %.254 = load i64, i64* %ref.tmp254.2279, align 512
  store i16 %.050, i16* %agg.result_code, align 512
  store i32 %.152, i32* %agg.result_detail, align 512
  store i64 %.254, i64* %agg.result_bad_element, align 512
  %cmp.i40 = icmp eq i16 %.050, 0
  %spec.select17 = select i1 %cmp.i40, i1 true, i1 false
  br label %cleanup262

cleanup262:                                       ; preds = %if.end238, %if.end222, %if.end205, %_ZN4laya6QKTaskC2Ev.exit
  %31 = phi i16 [ %.0107, %_ZN4laya6QKTaskC2Ev.exit ], [ %.091, %if.end205 ], [ %.071, %if.end222 ], [ %.050, %if.end238 ]
  %cleanup.dest.slot.5 = phi i1 [ false, %_ZN4laya6QKTaskC2Ev.exit ], [ false, %if.end205 ], [ false, %if.end222 ], [ %spec.select17, %if.end238 ]
  br i1 %cleanup.dest.slot.5, label %for.inc265, label %for.inc269

for.inc265:                                       ; preds = %cleanup262
  %add266 = add nuw nsw i32 %row159.0, 16
  br label %for.cond160, !llvm.loop !10602

for.inc269:                                       ; preds = %cleanup262, %for.cond160
  %32 = phi i16 [ %31, %cleanup262 ], [ %25, %for.cond160 ]
  %33 = phi i16 [ %31, %cleanup262 ], [ %26, %for.cond160 ]
  %inc270 = add nuw nsw i32 %b146.0, 1
  br label %for.cond147, !llvm.loop !10612

cleanup273:                                       ; preds = %for.body114
  br label %for.end279

for.inc276:                                       ; preds = %for.cond147
  %inc277 = add nuw nsw i32 %head107.0, 1
  br label %for.cond108, !llvm.loop !10617

for.end279.loopexit:                              ; preds = %for.cond108
  br label %for.end279

for.end279:                                       ; preds = %for.end279.loopexit, %cleanup273
  %34 = phi i16 [ %.0133, %cleanup273 ], [ %17, %for.end279.loopexit ]
  %cmp.i41 = icmp eq i16 %34, 0
  br i1 %cmp.i41, label %if.then281, label %if.end284

if.then281:                                       ; preds = %for.end279
  call fastcc void @"laya::full::full_publish_att"(i16* %ref.tmp282.0271, i32* %ref.tmp282.1272, i64* %ref.tmp282.2273, i8 %13, i8 %14, i32 %15, i8 %stage, i8 %layer, i16 %16)
  %.044 = load i16, i16* %ref.tmp282.0271, align 512
  %.146 = load i32, i32* %ref.tmp282.1272, align 512
  %.248 = load i64, i64* %ref.tmp282.2273, align 512
  store i16 %.044, i16* %agg.result_code, align 512
  store i32 %.146, i32* %agg.result_detail, align 512
  store i64 %.248, i64* %agg.result_bad_element, align 512
  br label %if.end284

if.end284:                                        ; preds = %if.then281, %for.end279
  %35 = phi i16 [ %.044, %if.then281 ], [ %34, %for.end279 ]
  %cmp.i42 = icmp eq i16 %35, 0
  br i1 %cmp.i42, label %if.then286, label %if.end296

if.then286:                                       ; preds = %if.end284
  %arrayinit.begin.9548.val = load i8, i8* %arrayinit.begin.9548, align 512, !alias.scope !10621, !noalias !10624
  call fastcc void @"laya::full::full_release_owner.7"(i16* %ref.tmp287.0265, i32* %ref.tmp287.1266, i64* %ref.tmp287.2267, i8 %produced_ref_id.0.0.val, i8 %produced_ref_bank.0.0.val, i32 %arrayinit.begin.0.2551.val, i8 %.1250, i8 %.2251, i8 %.3252, i8 %.4253, i8 %.5254, i16 %.6255, i16 %.7256, i16 %.8257, i8 %arrayinit.begin.9548.val)
  %.038 = load i16, i16* %ref.tmp287.0265, align 512
  %.140 = load i32, i32* %ref.tmp287.1266, align 512
  %.242 = load i64, i64* %ref.tmp287.2267, align 512
  store i16 %.038, i16* %agg.result_code, align 512
  store i32 %.140, i32* %agg.result_detail, align 512
  store i64 %.242, i64* %agg.result_bad_element, align 512
  %cmp.i43 = icmp eq i16 %.038, 0
  br i1 %cmp.i43, label %if.then291, label %if.end295

if.then291:                                       ; preds = %if.then286
  %arrayinit.element1.9539.val = load i8, i8* %arrayinit.element1.9539, align 4, !alias.scope !10621, !noalias !10624
  call fastcc void @"laya::full::full_release_owner.7"(i16* %ref.tmp292.0259, i32* %ref.tmp292.1260, i64* %ref.tmp292.2261, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.1.val, i32 %arrayinit.element1.0.2554.val, i8 %.1238, i8 %.2239, i8 %.3240, i8 %.4241, i8 %.5242, i16 %.6243, i16 %.7244, i16 %.8245, i8 %arrayinit.element1.9539.val)
  %.0 = load i16, i16* %ref.tmp292.0259, align 512
  %.1 = load i32, i32* %ref.tmp292.1260, align 512
  %.2 = load i64, i64* %ref.tmp292.2261, align 512
  store i16 %.0, i16* %agg.result_code, align 512
  store i32 %.1, i32* %agg.result_detail, align 512
  store i64 %.2, i64* %agg.result_bad_element, align 512
  br label %if.end295

if.end295:                                        ; preds = %if.then291, %if.then286
  br label %if.end296

if.end296:                                        ; preds = %if.end295, %if.end284
  br label %cleanup297

cleanup297.critedge:                              ; preds = %if.then
  br label %cleanup297

cleanup297.critedge13:                            ; preds = %for.end
  br label %cleanup297

cleanup297:                                       ; preds = %cleanup297.critedge13, %cleanup297.critedge, %if.end296, %if.end100, %if.end92
  ret void
}
