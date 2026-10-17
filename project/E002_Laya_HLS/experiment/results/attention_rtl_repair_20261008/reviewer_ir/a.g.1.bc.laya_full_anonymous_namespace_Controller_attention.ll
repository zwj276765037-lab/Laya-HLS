define internal fastcc void @"laya::full::(anonymous namespace)::Controller::attention"(i16* noalias nocapture align 512 %agg.result_code, i32* noalias nocapture align 512 %agg.result_detail, i64* noalias nocapture align 512 %agg.result_bad_element, i8 addrspace(1)* noalias nocapture %embedding, i64 %this_memory.0, i8 addrspace(1)* noalias nocapture %io, i64 %this_memory.2, i8 addrspace(1)* noalias nocapture %w_q0, i64 %this_memory.4, i8 addrspace(1)* noalias nocapture %w_q1, i64 %this_memory.6, i8 addrspace(1)* noalias nocapture %w_scale, i64 %this_memory.8, i8 addrspace(1)* noalias nocapture %aux, i64 %this_memory.10, i8 addrspace(1)* noalias nocapture %state0, i64 %this_memory.12, i8 addrspace(1)* noalias nocapture %state1, i64 %this_memory.14, i8 addrspace(1)* noalias nocapture %qkv0, i64 %this_memory.16, i8 addrspace(1)* noalias nocapture %qkv1, i64 %this_memory.18, i8 addrspace(1)* noalias nocapture %ff0, i64 %this_memory.20, i8 addrspace(1)* noalias nocapture %ff1, i64 %this_memory.22, i8 addrspace(1)* noalias nocapture %att_out, i64 %this_memory.24, i8* noalias nocapture align 512 %this_error_stage, i8* noalias nocapture align 512 %this_error_op, i32* noalias nocapture align 512 %this_error_task_id, i8* noalias nocapture align 512 %this_current_stage, i8* noalias nocapture align 512 %this_current_op, i8 zeroext %stage, i8 zeroext %layer, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, [2 x i32]* noalias nocapture align 512 %produced_ref_epoch, [2 x i8]* noalias nocapture align 512 %produced_region, [2 x i8]* noalias nocapture align 512 %produced_stage, [2 x i8]* noalias nocapture align 512 %produced_layer, [2 x i8]* noalias nocapture align 512 %produced_batch, [2 x i8]* noalias nocapture align 512 %produced_row_space, [2 x i16]* noalias nocapture align 512 %produced_row0, [2 x i16]* noalias nocapture align 512 %produced_rows, [2 x i16]* noalias nocapture align 512 %produced_width, i8 %produced_content.0.0.val, i8 %produced_content.0.1.val, i8* noalias nocapture align 512 %output_ref_id, i8* noalias nocapture align 512 %output_ref_bank, i32* noalias nocapture align 512 %output_ref_epoch, i8* noalias nocapture align 512 %output_region, i8* noalias nocapture align 512 %output_stage, i8* noalias nocapture align 512 %output_layer, i8* noalias nocapture align 512 %output_batch, i8* noalias nocapture align 512 %output_row_space, i16* noalias nocapture align 512 %output_row0, i16* noalias nocapture align 512 %output_rows, i16* noalias nocapture align 512 %output_width, i8* noalias nocapture align 512 %output_content) unnamed_addr #1 align 2 {
entry:
  %final.ref.id = alloca [2 x i8], i64 1, align 512
  %final.ref.bank = alloca [2 x i8], i64 1, align 512
  %final.ref.epoch = alloca [2 x i32], i64 1, align 512
  %final.region = alloca [2 x i8], i64 1, align 512
  %final.stage = alloca [2 x i8], i64 1, align 512
  %final.layer = alloca [2 x i8], i64 1, align 512
  %final.batch = alloca [2 x i8], i64 1, align 512
  %final.row_space = alloca [2 x i8], i64 1, align 512
  %final.row0 = alloca [2 x i16], i64 1, align 512
  %final.rows = alloca [2 x i16], i64 1, align 512
  %final.width = alloca [2 x i16], i64 1, align 512
  %final.content = alloca [2 x i8], i64 1, align 512
  %load.ctx.task_id = alloca i32, i64 1, align 512
  %load.ctx.op = alloca i8, i64 1, align 512
  %load.byte_count = alloca i32, i64 1, align 512
  %ref.tmp9.0510 = alloca i8, i64 1, align 512
  %ref.tmp9.1511 = alloca i8, i64 1, align 512
  %ref.tmp9.2512 = alloca i32, i64 1, align 512
  %ref.tmp12.0504 = alloca i16, i64 1, align 512
  %ref.tmp12.1505 = alloca i32, i64 1, align 512
  %ref.tmp12.2506 = alloca i64, i64 1, align 512
  %ref.tmp23.0498 = alloca i16, i64 1, align 512
  %ref.tmp23.1499 = alloca i32, i64 1, align 512
  %ref.tmp23.2500 = alloca i64, i64 1, align 512
  %t.src_qkv_ref.id = alloca [2 x i8], i64 1, align 512
  %t.src_qkv_ref.bank = alloca [2 x i8], i64 1, align 512
  %t.src_qkv_ref.epoch = alloca [2 x i32], i64 1, align 512
  %t.dst_qkv_ref.id = alloca [2 x i8], i64 1, align 512
  %t.dst_qkv_ref.bank = alloca [2 x i8], i64 1, align 512
  %t.dst_qkv_ref.epoch = alloca [2 x i32], i64 1, align 512
  %ref.tmp72.0449 = alloca i16, i64 1, align 512
  %ref.tmp72.1450 = alloca i32, i64 1, align 512
  %ref.tmp72.2451 = alloca i64, i64 1, align 512
  %ref.tmp90.0443 = alloca i16, i64 1, align 512
  %ref.tmp90.1444 = alloca i32, i64 1, align 512
  %ref.tmp90.2445 = alloca i64, i64 1, align 512
  %agg.tmp.0 = alloca i8, i64 1, align 512
  %agg.tmp.1 = alloca i8, i64 1, align 512
  %agg.tmp.2 = alloca i32, i64 1, align 512
  %ref.tmp102.0420 = alloca i16, i64 1, align 512
  %ref.tmp102.1421 = alloca i32, i64 1, align 512
  %ref.tmp102.2422 = alloca i64, i64 1, align 512
  %load.ctx.task_id.2 = alloca i32, i64 1, align 512
  %load.ctx.op.1 = alloca i8, i64 1, align 512
  %load.byte_count.1 = alloca i32, i64 1, align 512
  %ref.tmp119.0399 = alloca i8, i64 1, align 512
  %ref.tmp119.1400 = alloca i8, i64 1, align 512
  %ref.tmp119.2401 = alloca i32, i64 1, align 512
  %ref.tmp141.0393 = alloca i16, i64 1, align 512
  %ref.tmp141.1394 = alloca i32, i64 1, align 512
  %ref.tmp141.2395 = alloca i64, i64 1, align 512
  %qk.qkv_ref.id = alloca [2 x i8], i64 1, align 512
  %qk.qkv_ref.bank = alloca [2 x i8], i64 1, align 512
  %qk.qkv_ref.epoch = alloca [2 x i32], i64 1, align 512
  %ref.tmp182.0355 = alloca i8, i64 1, align 512
  %ref.tmp182.1356 = alloca i8, i64 1, align 512
  %ref.tmp182.2357 = alloca i32, i64 1, align 512
  %ref.tmp199.0349 = alloca i16, i64 1, align 512
  %ref.tmp199.1350 = alloca i32, i64 1, align 512
  %ref.tmp199.2351 = alloca i64, i64 1, align 512
  %ref.tmp218.0333 = alloca i16, i64 1, align 512
  %ref.tmp218.1334 = alloca i32, i64 1, align 512
  %ref.tmp218.2335 = alloca i64, i64 1, align 512
  %ref.tmp232.0309 = alloca i16, i64 1, align 512
  %ref.tmp232.1310 = alloca i32, i64 1, align 512
  %ref.tmp232.2311 = alloca i64, i64 1, align 512
  %ref.tmp247.0283 = alloca i8, i64 1, align 512
  %ref.tmp247.1284 = alloca i8, i64 1, align 512
  %ref.tmp247.2285 = alloca i32, i64 1, align 512
  %ref.tmp254.0277 = alloca i16, i64 1, align 512
  %ref.tmp254.1278 = alloca i32, i64 1, align 512
  %ref.tmp254.2279 = alloca i64, i64 1, align 512
  %ref.tmp282.0271 = alloca i16, i64 1, align 512
  %ref.tmp282.1272 = alloca i32, i64 1, align 512
  %ref.tmp282.2273 = alloca i64, i64 1, align 512
  %ref.tmp287.0265 = alloca i16, i64 1, align 512
  %ref.tmp287.1266 = alloca i32, i64 1, align 512
  %ref.tmp287.2267 = alloca i64, i64 1, align 512
  %ref.tmp292.0259 = alloca i16, i64 1, align 512
  %ref.tmp292.1260 = alloca i32, i64 1, align 512
  %ref.tmp292.2261 = alloca i64, i64 1, align 512
  %icmp.ln258 = icmp eq i8 %stage, 2
  %op = select i1 %icmp.ln258, i8 64, i8 80
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !19913, !noalias !19916
  store i8 %op, i8* %this_current_op, align 512, !alias.scope !19916, !noalias !19913
  %final.ref.id.addr = getelementptr [2 x i8], [2 x i8]* %final.ref.id, i64 0, i64 0
  %final.ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %final.ref.bank, i64 0, i64 0
  %final.ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 0
  %final.region.addr = getelementptr [2 x i8], [2 x i8]* %final.region, i64 0, i64 0
  %final.stage.addr = getelementptr [2 x i8], [2 x i8]* %final.stage, i64 0, i64 0
  %final.layer.addr = getelementptr [2 x i8], [2 x i8]* %final.layer, i64 0, i64 0
  %final.batch.addr = getelementptr [2 x i8], [2 x i8]* %final.batch, i64 0, i64 0
  %final.row_space.addr = getelementptr [2 x i8], [2 x i8]* %final.row_space, i64 0, i64 0
  %final.row0.addr = getelementptr [2 x i16], [2 x i16]* %final.row0, i64 0, i64 0
  %final.rows.addr = getelementptr [2 x i16], [2 x i16]* %final.rows, i64 0, i64 0
  %final.width.addr = getelementptr [2 x i16], [2 x i16]* %final.width, i64 0, i64 0
  %final.content.addr = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 0
  %produced_ref_epoch.addr = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 0
  %produced_region.addr = getelementptr [2 x i8], [2 x i8]* %produced_region, i64 0, i64 0
  %produced_stage.addr = getelementptr [2 x i8], [2 x i8]* %produced_stage, i64 0, i64 0
  %produced_layer.addr = getelementptr [2 x i8], [2 x i8]* %produced_layer, i64 0, i64 0
  %produced_batch.addr = getelementptr [2 x i8], [2 x i8]* %produced_batch, i64 0, i64 0
  %produced_row_space.addr = getelementptr [2 x i8], [2 x i8]* %produced_row_space, i64 0, i64 0
  %produced_row0.addr = getelementptr [2 x i16], [2 x i16]* %produced_row0, i64 0, i64 0
  %produced_rows.addr = getelementptr [2 x i16], [2 x i16]* %produced_rows, i64 0, i64 0
  %produced_width.addr = getelementptr [2 x i16], [2 x i16]* %produced_width, i64 0, i64 0
  %produced_ref_epoch.load = load i32, i32* %produced_ref_epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %produced_ref_epoch.load) #1
  %produced_region.load = load i8, i8* %produced_region.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_region.load) #1
  %produced_stage.load = load i8, i8* %produced_stage.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_stage.load) #1
  %produced_layer.load = load i8, i8* %produced_layer.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_layer.load) #1
  %produced_batch.load = load i8, i8* %produced_batch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_batch.load) #1
  %produced_row_space.load = load i8, i8* %produced_row_space.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_row_space.load) #1
  %produced_row0.load = load i16, i16* %produced_row0.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_row0.load) #1
  %produced_rows.load = load i16, i16* %produced_rows.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_rows.load) #1
  %produced_width.load = load i16, i16* %produced_width.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_width.load) #1
  store i8 %produced_ref_id.0.0.val, i8* %final.ref.id.addr, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %final.ref.bank.addr, align 512
  store i32 %produced_ref_epoch.load, i32* %final.ref.epoch.addr, align 512
  store i8 %produced_region.load, i8* %final.region.addr, align 512
  store i8 %produced_stage.load, i8* %final.stage.addr, align 512
  store i8 %produced_layer.load, i8* %final.layer.addr, align 512
  store i8 %produced_batch.load, i8* %final.batch.addr, align 512
  store i8 %produced_row_space.load, i8* %final.row_space.addr, align 512
  store i16 %produced_row0.load, i16* %final.row0.addr, align 512
  store i16 %produced_rows.load, i16* %final.rows.addr, align 512
  store i16 %produced_width.load, i16* %final.width.addr, align 512
  store i8 %produced_content.0.0.val, i8* %final.content.addr, align 512
  %final.ref.id.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.ref.id, i64 0, i64 1
  %final.ref.bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.ref.bank, i64 0, i64 1
  %final.ref.epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 1
  %final.region.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.region, i64 0, i64 1
  %final.stage.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.stage, i64 0, i64 1
  %final.layer.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.layer, i64 0, i64 1
  %final.batch.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.batch, i64 0, i64 1
  %final.row_space.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.row_space, i64 0, i64 1
  %final.row0.addr.1 = getelementptr [2 x i16], [2 x i16]* %final.row0, i64 0, i64 1
  %final.rows.addr.1 = getelementptr [2 x i16], [2 x i16]* %final.rows, i64 0, i64 1
  %final.width.addr.1 = getelementptr [2 x i16], [2 x i16]* %final.width, i64 0, i64 1
  %final.content.addr.1 = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 1
  %produced_ref_epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 1
  %produced_region.addr.1 = getelementptr [2 x i8], [2 x i8]* %produced_region, i64 0, i64 1
  %produced_stage.addr.1 = getelementptr [2 x i8], [2 x i8]* %produced_stage, i64 0, i64 1
  %produced_layer.addr.1 = getelementptr [2 x i8], [2 x i8]* %produced_layer, i64 0, i64 1
  %produced_batch.addr.1 = getelementptr [2 x i8], [2 x i8]* %produced_batch, i64 0, i64 1
  %produced_row_space.addr.1 = getelementptr [2 x i8], [2 x i8]* %produced_row_space, i64 0, i64 1
  %produced_row0.addr.1 = getelementptr [2 x i16], [2 x i16]* %produced_row0, i64 0, i64 1
  %produced_rows.addr.1 = getelementptr [2 x i16], [2 x i16]* %produced_rows, i64 0, i64 1
  %produced_width.addr.1 = getelementptr [2 x i16], [2 x i16]* %produced_width, i64 0, i64 1
  %produced_ref_epoch.load.1 = load i32, i32* %produced_ref_epoch.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %produced_ref_epoch.load.1) #1
  %produced_region.load.1 = load i8, i8* %produced_region.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_region.load.1) #1
  %produced_stage.load.1 = load i8, i8* %produced_stage.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_stage.load.1) #1
  %produced_layer.load.1 = load i8, i8* %produced_layer.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_layer.load.1) #1
  %produced_batch.load.1 = load i8, i8* %produced_batch.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_batch.load.1) #1
  %produced_row_space.load.1 = load i8, i8* %produced_row_space.addr.1, align 1
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %produced_row_space.load.1) #1
  %produced_row0.load.1 = load i16, i16* %produced_row0.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_row0.load.1) #1
  %produced_rows.load.1 = load i16, i16* %produced_rows.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_rows.load.1) #1
  %produced_width.load.1 = load i16, i16* %produced_width.addr.1, align 2
  call void (...) @_ssdm_SpecKeepArrayLoad(i16 %produced_width.load.1) #1
  store i8 %produced_ref_id.0.1.val, i8* %final.ref.id.addr.1, align 1
  store i8 %produced_ref_bank.0.1.val, i8* %final.ref.bank.addr.1, align 1
  store i32 %produced_ref_epoch.load.1, i32* %final.ref.epoch.addr.1, align 4
  store i8 %produced_region.load.1, i8* %final.region.addr.1, align 1
  store i8 %produced_stage.load.1, i8* %final.stage.addr.1, align 1
  store i8 %produced_layer.load.1, i8* %final.layer.addr.1, align 1
  store i8 %produced_batch.load.1, i8* %final.batch.addr.1, align 1
  store i8 %produced_row_space.load.1, i8* %final.row_space.addr.1, align 1
  store i16 %produced_row0.load.1, i16* %final.row0.addr.1, align 2
  store i16 %produced_rows.load.1, i16* %final.rows.addr.1, align 2
  store i16 %produced_width.load.1, i16* %final.width.addr.1, align 2
  store i8 %produced_content.0.1.val, i8* %final.content.addr.1, align 1
  store i16 0, i16* %agg.result_code, align 512, !alias.scope !19918, !noalias !19921
  store i32 0, i32* %agg.result_detail, align 512, !alias.scope !19924, !noalias !19925
  store i64 -1, i64* %agg.result_bad_element, align 512, !alias.scope !19926, !noalias !19927
  br i1 %icmp.ln258, label %if.then, label %if.end100

if.then:                                          ; preds = %entry
  %urem.ln262 = urem i8 %layer, 3
  %icmp.ln262 = icmp eq i8 %urem.ln262, 0
  %mode = select i1 %icmp.ln262, i8 0, i8 1
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !19928, !noalias !19931
  %load.ctx.task_id.1 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  store i32 %load.ctx.task_id.1, i32* %load.ctx.task_id, align 512
  store i8 -125, i8* @load.ctx.op.constprop, align 512
  store i8 -125, i8* @load.ctx.op.constprop169, align 512
  store i8 -125, i8* @load.ctx.op.constprop192, align 512
  store i8 -125, i8* %load.ctx.op, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp9.0510, i8* %ref.tmp9.1511, i32* %ref.tmp9.2512, i8 43, i8 %mode, i8 0)
  %load.dst.id = load i8, i8* %ref.tmp9.0510, align 512
  %load.dst.bank = load i8, i8* %ref.tmp9.1511, align 512
  %load.dst.epoch = load i32, i32* %ref.tmp9.2512, align 512
  store i32 524800, i32* %load.byte_count, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LoadTask>"(i16* %ref.tmp12.0504, i32* %ref.tmp12.1505, i64* %ref.tmp12.2506, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32* %load.ctx.task_id, i8* %load.ctx.op, i8 2, i8 %layer, i8 3, i8 %load.dst.id, i8 %load.dst.bank, i32 %load.dst.epoch, i8 0, i8 -1, i8 -1, i8 0, i32* %load.byte_count, i32 524800)
  %ref.tmp12.0504.load = load i16, i16* %ref.tmp12.0504, align 512
  %ref.tmp12.1505.load = load i32, i32* %ref.tmp12.1505, align 512
  %ref.tmp12.2506.load = load i64, i64* %ref.tmp12.2506, align 512
  store i16 %ref.tmp12.0504.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp12.1505.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp12.2506.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9 = icmp eq i16 %ref.tmp12.0504.load, 0
  br i1 %icmp.ln9, label %if.end, label %cleanup297

if.end:                                           ; preds = %if.then
  store i8 2, i8* %this_current_stage, align 512, !alias.scope !19940, !noalias !19943
  store i8 64, i8* %this_current_op, align 512, !alias.scope !19943, !noalias !19940
  br label %for.inc

for.inc:                                          ; preds = %for.inc.split, %if.end
  %shard = phi i64 [ 0, %if.end ], [ %add.ln272, %for.inc.split ]
  %icmp.ln272 = icmp eq i64 %shard, 2
  br i1 %icmp.ln272, label %for.end, label %for.inc.split, !llvm.loop !19945

for.inc.split:                                    ; preds = %for.inc
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @88)
  %produced_ref_epoch.addr.2 = getelementptr [2 x i32], [2 x i32]* %produced_ref_epoch, i64 0, i64 %shard
  %produced_ref_epoch.load.2 = load i32, i32* %produced_ref_epoch.addr.2, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %produced_ref_epoch.load.2) #1
  %add.ln273 = add i32 %produced_ref_epoch.load.2, 1
  %final.ref.epoch.addr.2 = getelementptr [2 x i32], [2 x i32]* %final.ref.epoch, i64 0, i64 %shard
  store i32 %add.ln273, i32* %final.ref.epoch.addr.2, align 4
  %final.content.addr.2 = getelementptr [2 x i8], [2 x i8]* %final.content, i64 0, i64 %shard
  store i8 3, i8* %final.content.addr.2, align 4
  %add.ln272 = add nuw nsw i64 %shard, 1
  br label %for.inc, !llvm.loop !19945

for.end:                                          ; preds = %for.inc
  call fastcc void @"laya::full::full_begin_qkv_rope_pair"(i16* %ref.tmp23.0498, i32* %ref.tmp23.1499, i64* %ref.tmp23.2500, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, [2 x i32]* %produced_ref_epoch, [2 x i8]* %produced_region, [2 x i8]* %produced_stage, [2 x i8]* %produced_layer, [2 x i8]* %produced_batch, [2 x i8]* %produced_row_space, [2 x i16]* %produced_row0, [2 x i16]* %produced_rows, [2 x i16]* %produced_width, i8 %produced_content.0.0.val, i8 %produced_content.0.1.val, [2 x i8]* %final.ref.id, [2 x i8]* %final.ref.bank, [2 x i32]* %final.ref.epoch, [2 x i8]* %final.region, [2 x i8]* %final.stage, [2 x i8]* %final.layer, [2 x i8]* %final.batch, [2 x i8]* %final.row_space, [2 x i16]* %final.row0, [2 x i16]* %final.rows, [2 x i16]* %final.width, [2 x i8]* %final.content)
  %ref.tmp23.0498.load = load i16, i16* %ref.tmp23.0498, align 512
  %ref.tmp23.1499.load = load i32, i32* %ref.tmp23.1499, align 512
  %ref.tmp23.2500.load = load i64, i64* %ref.tmp23.2500, align 512
  store i16 %ref.tmp23.0498.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp23.1499.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp23.2500.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.292 = icmp eq i16 %ref.tmp23.0498.load, 0
  br i1 %icmp.ln9.292, label %VITIS_LOOP_278_2, label %cleanup297

VITIS_LOOP_278_2:                                 ; preds = %for.end
  %t.src_qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 0
  %t.dst_qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 0
  %t.src_qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 0
  %t.src_qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 0
  %t.src_qkv_ref.id.addr.1 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 1
  %t.src_qkv_ref.bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 1
  %t.src_qkv_ref.epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 1
  %final.ref.epoch.load = load i32, i32* %final.ref.epoch.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %final.ref.epoch.load) #1
  %final.ref.epoch.load.1 = load i32, i32* %final.ref.epoch.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i32 %final.ref.epoch.load.1) #1
  %t.dst_qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 0
  %t.dst_qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 0
  %t.dst_qkv_ref.id.addr.1 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 1
  %t.dst_qkv_ref.bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 1
  %t.dst_qkv_ref.epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 1
  br label %for.cond28

for.cond28:                                       ; preds = %for.inc84, %VITIS_LOOP_278_2
  %0 = phi i16 [ 0, %VITIS_LOOP_278_2 ], [ %.lcssa11, %for.inc84 ]
  %1 = phi i16 [ 0, %VITIS_LOOP_278_2 ], [ %5, %for.inc84 ]
  %head = phi i32 [ 0, %VITIS_LOOP_278_2 ], [ %head.2, %for.inc84 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %icmp.ln278 = icmp ugt i32 %head, 15
  %icmp.ln9.293 = icmp eq i16 %1, 0
  %xor.ln278 = xor i1 %icmp.ln9.293, true
  %or.ln278 = or i1 %icmp.ln278, %xor.ln278
  br i1 %or.ln278, label %for.end87, label %VITIS_LOOP_279_3

VITIS_LOOP_279_3:                                 ; preds = %for.cond28
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @89)
  %t.head = trunc i32 %head to i8
  br label %for.cond33

for.cond33:                                       ; preds = %for.inc80, %VITIS_LOOP_279_3
  %2 = phi i16 [ %0, %VITIS_LOOP_279_3 ], [ %4, %for.inc80 ]
  %3 = phi i16 [ 0, %VITIS_LOOP_279_3 ], [ %4, %for.inc80 ]
  %b = phi i32 [ 0, %VITIS_LOOP_279_3 ], [ %b.27, %for.inc80 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln279 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load" to i32
  %icmp.ln279 = icmp ult i32 %b, %zext.ln279
  br i1 %icmp.ln279, label %land.rhs37, label %for.inc84

land.rhs37:                                       ; preds = %for.cond33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @90)
  %icmp.ln9.296 = icmp eq i16 %2, 0
  br i1 %icmp.ln9.296, label %VITIS_LOOP_280_4, label %for.inc84

VITIS_LOOP_280_4:                                 ; preds = %land.rhs37
  %batch = trunc i32 %b to i8
  br label %for.cond42

for.cond42:                                       ; preds = %for.inc76, %VITIS_LOOP_280_4
  %row = phi i32 [ 0, %VITIS_LOOP_280_4 ], [ %row.29, %for.inc76 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.dst_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.dst_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %t.src_qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %t.src_qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %"(anonymous namespace)::runtime.inputs.identity.S.load.25" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %zext.ln280 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.25" to i32
  %icmp.ln280 = icmp ult i32 %row, %zext.ln280
  br i1 %icmp.ln280, label %for.body49, label %for.inc80

for.body49:                                       ; preds = %for.cond42
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @112)
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %for.body49
  %arrayinit.curidx.i = phi i64 [ 0, %for.body49 ], [ %add.ln12, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %add.ln12 = add nuw nsw i64 %arrayinit.curidx.i, 1
  %this.src_qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.id, i64 0, i64 %arrayinit.curidx.i
  store i8 0, i8* %this.src_qkv_ref.id.addr, align 8, !alias.scope !20074, !noalias !20077
  %this.src_qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %t.src_qkv_ref.bank, i64 0, i64 %arrayinit.curidx.i
  store i8 0, i8* %this.src_qkv_ref.bank.addr, align 1, !alias.scope !20074, !noalias !20077
  %this.src_qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %t.src_qkv_ref.epoch, i64 0, i64 %arrayinit.curidx.i
  store i32 0, i32* %this.src_qkv_ref.epoch.addr, align 4, !alias.scope !20074, !noalias !20077
  %icmp.ln12 = icmp eq i64 %arrayinit.curidx.i, 1
  br i1 %icmp.ln12, label %arrayinit.body4.i.preheader, label %arrayinit.body.i, !llvm.loop !20090

arrayinit.body4.i.preheader:                      ; preds = %arrayinit.body.i
  br label %arrayinit.body4.i

arrayinit.body4.i:                                ; preds = %arrayinit.body4.i, %arrayinit.body4.i.preheader
  %arrayinit.curidx5.i = phi i64 [ %add.ln12.25, %arrayinit.body4.i ], [ 0, %arrayinit.body4.i.preheader ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %add.ln12.25 = add nuw nsw i64 %arrayinit.curidx5.i, 1
  %this.dst_qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.id, i64 0, i64 %arrayinit.curidx5.i
  store i8 0, i8* %this.dst_qkv_ref.id.addr, align 8, !alias.scope !20091, !noalias !20092
  %this.dst_qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %t.dst_qkv_ref.bank, i64 0, i64 %arrayinit.curidx5.i
  store i8 0, i8* %this.dst_qkv_ref.bank.addr, align 1, !alias.scope !20091, !noalias !20092
  %this.dst_qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %t.dst_qkv_ref.epoch, i64 0, i64 %arrayinit.curidx5.i
  store i32 0, i32* %this.dst_qkv_ref.epoch.addr, align 4, !alias.scope !20091, !noalias !20092
  %icmp.ln12.63 = icmp eq i64 %arrayinit.curidx5.i, 1
  br i1 %icmp.ln12.63, label %_ZN4laya8RopeTaskC2Ev.exit, label %arrayinit.body4.i, !llvm.loop !20093

_ZN4laya8RopeTaskC2Ev.exit:                       ; preds = %arrayinit.body4.i
  %row0 = trunc i32 %row to i16
  %"(anonymous namespace)::runtime.last_task_id.load.4" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !20094, !noalias !20097
  %t.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.4", 1
  store i8 %produced_ref_id.0.0.val, i8* %t.src_qkv_ref.id.addr, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %t.src_qkv_ref.bank.addr, align 512
  store i32 %produced_ref_epoch.load, i32* %t.src_qkv_ref.epoch.addr, align 512
  store i8 %produced_ref_id.0.1.val, i8* %t.src_qkv_ref.id.addr.1, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %t.src_qkv_ref.bank.addr.1, align 1
  store i32 %produced_ref_epoch.load.1, i32* %t.src_qkv_ref.epoch.addr.1, align 4
  store i8 %produced_ref_id.0.0.val, i8* %t.dst_qkv_ref.id.addr, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %t.dst_qkv_ref.bank.addr, align 512
  store i32 %final.ref.epoch.load, i32* %t.dst_qkv_ref.epoch.addr, align 512
  store i8 %produced_ref_id.0.1.val, i8* %t.dst_qkv_ref.id.addr.1, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %t.dst_qkv_ref.bank.addr.1, align 1
  store i32 %final.ref.epoch.load.1, i32* %t.dst_qkv_ref.epoch.addr.1, align 4
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::RopeTask>"(i16* %ref.tmp72.0449, i32* %ref.tmp72.1450, i64* %ref.tmp72.2451, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %t.ctx.task_id, i8 %layer, i8 %batch, i16 %row0, [2 x i8]* %t.src_qkv_ref.id, [2 x i8]* %t.src_qkv_ref.bank, [2 x i32]* %t.src_qkv_ref.epoch, [2 x i8]* %t.dst_qkv_ref.id, [2 x i8]* %t.dst_qkv_ref.bank, [2 x i32]* %t.dst_qkv_ref.epoch, i8 %t.head, i8 %mode, i8 %mode)
  %ref.tmp72.0449.load = load i16, i16* %ref.tmp72.0449, align 512
  %ref.tmp72.1450.load = load i32, i32* %ref.tmp72.1450, align 512
  %ref.tmp72.2451.load = load i64, i64* %ref.tmp72.2451, align 512
  store i16 %ref.tmp72.0449.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp72.1450.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp72.2451.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.303 = icmp eq i16 %ref.tmp72.0449.load, 0
  br i1 %icmp.ln9.303, label %for.inc76, label %for.inc80

for.inc76:                                        ; preds = %_ZN4laya8RopeTaskC2Ev.exit
  %row.29 = add nuw nsw i32 %row, 16
  br label %for.cond42, !llvm.loop !20106

for.inc80:                                        ; preds = %_ZN4laya8RopeTaskC2Ev.exit, %for.cond42
  %4 = phi i16 [ 0, %for.cond42 ], [ %ref.tmp72.0449.load, %_ZN4laya8RopeTaskC2Ev.exit ]
  %b.27 = add nuw nsw i32 %b, 1
  br label %for.cond33, !llvm.loop !20115

for.inc84:                                        ; preds = %land.rhs37, %for.cond33
  %.lcssa11 = phi i16 [ %2, %land.rhs37 ], [ %2, %for.cond33 ]
  %5 = phi i16 [ %3, %for.cond33 ], [ %2, %land.rhs37 ]
  %head.2 = add nuw nsw i32 %head, 1
  br label %for.cond28, !llvm.loop !20119

for.end87:                                        ; preds = %for.cond28
  %cmp.i15.lcssa = phi i1 [ %icmp.ln9.293, %for.cond28 ]
  %.lcssa12 = phi i16 [ %0, %for.cond28 ]
  br i1 %cmp.i15.lcssa, label %if.then89, label %if.end92

if.then89:                                        ; preds = %for.end87
  %final.content.load = load i8, i8* %final.content.addr, align 512
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %final.content.load) #1
  %final.content.load.1 = load i8, i8* %final.content.addr.1, align 4
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %final.content.load.1) #1
  call fastcc void @"laya::full::full_commit_qkv_rope_pair"(i16* %ref.tmp90.0443, i32* %ref.tmp90.1444, i64* %ref.tmp90.2445, i8 %produced_ref_id.0.0.val, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.0.val, i8 %produced_ref_bank.0.1.val, i32 %final.ref.epoch.load, i32 %final.ref.epoch.load.1, i8 %produced_region.load, i8 %produced_region.load.1, i8 %produced_stage.load, i8 %produced_stage.load.1, i8 %produced_layer.load, i8 %produced_layer.load.1, i8 %produced_batch.load, i8 %produced_batch.load.1, i8 %produced_row_space.load, i8 %produced_row_space.load.1, i16 %produced_row0.load, i16 %produced_row0.load.1, i16 %produced_rows.load, i16 %produced_rows.load.1, i16 %produced_width.load, i16 %produced_width.load.1, i8 %final.content.load, i8 %final.content.load.1)
  %ref.tmp90.0443.load = load i16, i16* %ref.tmp90.0443, align 512
  %ref.tmp90.1444.load = load i32, i32* %ref.tmp90.1444, align 512
  %ref.tmp90.2445.load = load i64, i64* %ref.tmp90.2445, align 512
  store i16 %ref.tmp90.0443.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp90.1444.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp90.2445.load, i64* %agg.result_bad_element, align 512
  br label %if.end92

if.end92:                                         ; preds = %if.then89, %for.end87
  %6 = phi i16 [ %ref.tmp90.0443.load, %if.then89 ], [ %.lcssa12, %for.end87 ]
  %icmp.ln9.294 = icmp eq i16 %6, 0
  br i1 %icmp.ln9.294, label %if.end100, label %cleanup297

if.end100:                                        ; preds = %if.end92, %entry
  %arrayinit.element1.0.2554.val = phi i32 [ %produced_ref_epoch.load.1, %entry ], [ %final.ref.epoch.load.1, %if.end92 ]
  %arrayinit.begin.0.2551.val = phi i32 [ %produced_ref_epoch.load, %entry ], [ %final.ref.epoch.load, %if.end92 ]
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp.0, i8* %agg.tmp.1, i32* %agg.tmp.2, i8 8, i8 0, i8 0)
  %ref.id = load i8, i8* %agg.tmp.0, align 512
  %ref.bank = load i8, i8* %agg.tmp.1, align 512
  %ref.epoch = load i32, i32* %agg.tmp.2, align 512
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  store i8 %ref.id, i8* %output_ref_id, align 512
  store i8 %ref.bank, i8* %output_ref_bank, align 512
  store i32 %ref.epoch, i32* %output_ref_epoch, align 512
  store i8 0, i8* %output_region, align 512
  store i8 %stage, i8* %output_stage, align 512
  store i8 %layer, i8* %output_layer, align 512
  store i8 -1, i8* %output_batch, align 512
  store i8 0, i8* %output_row_space, align 512
  store i16 0, i16* %output_row0, align 512
  store i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16* %output_rows, align 512
  store i16 1024, i16* %output_width, align 512
  store i8 1, i8* %output_content, align 512
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !20123, !noalias !20126
  store i8 82, i8* %this_current_op, align 512, !alias.scope !20126, !noalias !20123
  call fastcc void @"laya::full::full_claim_owner"(i16* %ref.tmp102.0420, i32* %ref.tmp102.1421, i64* %ref.tmp102.2422, i8 %ref.id, i8 %ref.bank, i32 %ref.epoch, i8 0, i8 %stage, i8 %layer, i8 -1, i8 0, i16 0, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load", i16 1024, i8 1)
  %ref.tmp102.0420.load = load i16, i16* %ref.tmp102.0420, align 512
  %ref.tmp102.1421.load = load i32, i32* %ref.tmp102.1421, align 512
  %ref.tmp102.2422.load = load i64, i64* %ref.tmp102.2422, align 512
  store i16 %ref.tmp102.0420.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp102.1421.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp102.2422.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.295 = icmp eq i16 %ref.tmp102.0420.load, 0
  br i1 %icmp.ln9.295, label %VITIS_LOOP_298_5, label %cleanup297

VITIS_LOOP_298_5:                                 ; preds = %if.end100
  %qk.qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 0
  %qk.qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 0
  %qk.qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 0
  %qk.qkv_ref.id.addr.1 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 1
  %qk.qkv_ref.bank.addr.1 = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 1
  %qk.qkv_ref.epoch.addr.1 = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 1
  %urem.ln319 = urem i8 %layer, 3
  %icmp.ln319 = icmp ne i8 %urem.ln319, 0
  %and.ln319 = and i1 %icmp.ln258, %icmp.ln319
  %qk.mask_mode = zext i1 %and.ln319 to i8
  br label %for.cond108

for.cond108:                                      ; preds = %for.inc276, %VITIS_LOOP_298_5
  %7 = phi i16 [ 0, %VITIS_LOOP_298_5 ], [ %.lcssa, %for.inc276 ]
  %8 = phi i16 [ 0, %VITIS_LOOP_298_5 ], [ %.lcssa10, %for.inc276 ]
  %head.3 = phi i32 [ 0, %VITIS_LOOP_298_5 ], [ %head.4, %for.inc276 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %icmp.ln298 = icmp ult i32 %head.3, 16
  %icmp.ln9.297 = icmp eq i16 %8, 0
  %and.ln298 = and i1 %icmp.ln298, %icmp.ln9.297
  br i1 %and.ln298, label %for.body114, label %for.end279

for.body114:                                      ; preds = %for.cond108
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @94)
  %"(anonymous namespace)::runtime.last_task_id.load.3" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !20128, !noalias !20131
  %load.ctx.task_id.3 = add i32 %"(anonymous namespace)::runtime.last_task_id.load.3", 1
  store i32 %load.ctx.task_id.3, i32* %load.ctx.task_id.2, align 512
  store i8 -127, i8* %load.ctx.op.1, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp119.0399, i8* %ref.tmp119.1400, i32* %ref.tmp119.2401, i8 37, i8 0, i8 0)
  %load.dst.id.2 = load i8, i8* %ref.tmp119.0399, align 512
  %load.dst.bank.2 = load i8, i8* %ref.tmp119.1400, align 512
  %load.dst.epoch.2 = load i32, i32* %ref.tmp119.2401, align 512
  %load.head = trunc i32 %head.3 to i8
  %"(anonymous namespace)::runtime.inputs.identity.B.load.14" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln305 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.14" to i32
  %"(anonymous namespace)::runtime.inputs.identity.S.load.26" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %zext.ln306 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.S.load.26" to i32
  %shl.ln306 = shl nuw nsw i32 %zext.ln305, 9
  %load.byte_count.2 = mul i32 %shl.ln306, %zext.ln306
  store i32 %load.byte_count.2, i32* %load.byte_count.1, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::LoadTask>"(i16* %ref.tmp141.0393, i32* %ref.tmp141.1394, i64* %ref.tmp141.2395, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32* %load.ctx.task_id.2, i8* %load.ctx.op.1, i8 %stage, i8 %layer, i8 1, i8 %load.dst.id.2, i8 %load.dst.bank.2, i32 %load.dst.epoch.2, i8 0, i8 -1, i8 %load.head, i8 3, i32* %load.byte_count.1, i32 %load.byte_count.2)
  %ref.tmp141.0393.load = load i16, i16* %ref.tmp141.0393, align 512
  %ref.tmp141.1394.load = load i32, i32* %ref.tmp141.1394, align 512
  %ref.tmp141.2395.load = load i64, i64* %ref.tmp141.2395, align 512
  store i16 %ref.tmp141.0393.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp141.1394.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp141.2395.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.298 = icmp eq i16 %ref.tmp141.0393.load, 0
  br i1 %icmp.ln9.298, label %VITIS_LOOP_310_6, label %for.end279

VITIS_LOOP_310_6:                                 ; preds = %for.body114
  store i8 %stage, i8* %this_current_stage, align 512, !alias.scope !20140, !noalias !20143
  store i8 80, i8* %this_current_op, align 512, !alias.scope !20143, !noalias !20140
  br label %for.cond147

for.cond147:                                      ; preds = %for.inc269, %VITIS_LOOP_310_6
  %9 = phi i16 [ 0, %VITIS_LOOP_310_6 ], [ %14, %for.inc269 ]
  %10 = phi i16 [ 0, %VITIS_LOOP_310_6 ], [ %15, %for.inc269 ]
  %b.26 = phi i32 [ 0, %VITIS_LOOP_310_6 ], [ %b.28, %for.inc269 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %"(anonymous namespace)::runtime.inputs.identity.B.load.15" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512
  %zext.ln310 = zext i16 %"(anonymous namespace)::runtime.inputs.identity.B.load.15" to i32
  %icmp.ln310 = icmp ult i32 %b.26, %zext.ln310
  %icmp.ln9.301 = icmp eq i16 %10, 0
  %and.ln310 = and i1 %icmp.ln310, %icmp.ln9.301
  br i1 %and.ln310, label %VITIS_LOOP_311_7, label %for.inc276

VITIS_LOOP_311_7:                                 ; preds = %for.cond147
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @95)
  %batch.6 = trunc i32 %b.26 to i8
  br label %for.cond160

for.cond160:                                      ; preds = %for.inc265, %VITIS_LOOP_311_7
  %11 = phi i16 [ %9, %VITIS_LOOP_311_7 ], [ %13, %for.inc265 ]
  %12 = phi i16 [ 0, %VITIS_LOOP_311_7 ], [ %13, %for.inc265 ]
  %row.28 = phi i32 [ 0, %VITIS_LOOP_311_7 ], [ %row.30, %for.inc265 ]
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qk.qkv_ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qk.qkv_ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false) #1
  %qk.S = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512
  %zext.ln311 = zext i16 %qk.S to i32
  %icmp.ln311 = icmp ult i32 %row.28, %zext.ln311
  br i1 %icmp.ln311, label %for.body168, label %for.inc269

for.body168:                                      ; preds = %for.cond160
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 4096, i64 2048), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @96)
  br label %arrayinit.body.i29

arrayinit.body.i29:                               ; preds = %arrayinit.body.i29, %for.body168
  %arrayinit.curidx.i23 = phi i64 [ 0, %for.body168 ], [ %add.ln13, %arrayinit.body.i29 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %add.ln13 = add nuw nsw i64 %arrayinit.curidx.i23, 1
  %this.qkv_ref.id.addr = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.id, i64 0, i64 %arrayinit.curidx.i23
  store i8 0, i8* %this.qkv_ref.id.addr, align 8, !alias.scope !20145, !noalias !20148
  %this.qkv_ref.bank.addr = getelementptr [2 x i8], [2 x i8]* %qk.qkv_ref.bank, i64 0, i64 %arrayinit.curidx.i23
  store i8 0, i8* %this.qkv_ref.bank.addr, align 1, !alias.scope !20145, !noalias !20148
  %this.qkv_ref.epoch.addr = getelementptr [2 x i32], [2 x i32]* %qk.qkv_ref.epoch, i64 0, i64 %arrayinit.curidx.i23
  store i32 0, i32* %this.qkv_ref.epoch.addr, align 4, !alias.scope !20145, !noalias !20148
  %icmp.ln13 = icmp eq i64 %arrayinit.curidx.i23, 1
  br i1 %icmp.ln13, label %_ZN4laya6QKTaskC2Ev.exit, label %arrayinit.body.i29, !llvm.loop !20167

_ZN4laya6QKTaskC2Ev.exit:                         ; preds = %arrayinit.body.i29
  %row0.1 = trunc i32 %row.28 to i16
  %"(anonymous namespace)::runtime.last_task_id.load.5" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !20169, !noalias !20172
  %qk.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.5", 1
  store i8 %produced_ref_id.0.0.val, i8* %qk.qkv_ref.id.addr, align 512
  store i8 %produced_ref_bank.0.0.val, i8* %qk.qkv_ref.bank.addr, align 512
  store i32 %arrayinit.begin.0.2551.val, i32* %qk.qkv_ref.epoch.addr, align 512
  store i8 %produced_ref_id.0.1.val, i8* %qk.qkv_ref.id.addr.1, align 8
  store i8 %produced_ref_bank.0.1.val, i8* %qk.qkv_ref.bank.addr.1, align 1
  store i32 %arrayinit.element1.0.2554.val, i32* %qk.qkv_ref.epoch.addr.1, align 4
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp182.0355, i8* %ref.tmp182.1356, i32* %ref.tmp182.2357, i8 38, i8 0, i8 0)
  %qk.score.id = load i8, i8* %ref.tmp182.0355, align 512
  %qk.score.bank = load i8, i8* %ref.tmp182.1356, align 512
  %qk.score.epoch = load i32, i32* %ref.tmp182.2357, align 512
  %shl.ln321 = shl nuw nsw i32 %zext.ln311, 4
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::QKTask>"(i16* %ref.tmp199.0349, i32* %ref.tmp199.1350, i64* %ref.tmp199.2351, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %qk.ctx.task_id, i8 %stage, i8 %layer, i8 %batch.6, i16 %row0.1, [2 x i8]* %qk.qkv_ref.id, [2 x i8]* %qk.qkv_ref.bank, [2 x i32]* %qk.qkv_ref.epoch, i8 %load.dst.id.2, i8 %load.dst.bank.2, i32 %load.dst.epoch.2, i8 %qk.score.id, i8 %qk.score.bank, i32 %qk.score.epoch, i8 %load.head, i8 %qk.mask_mode, i16 %qk.S, i32 %shl.ln321)
  %ref.tmp199.0349.load = load i16, i16* %ref.tmp199.0349, align 512
  %ref.tmp199.1350.load = load i32, i32* %ref.tmp199.1350, align 512
  %ref.tmp199.2351.load = load i64, i64* %ref.tmp199.2351, align 512
  store i16 %ref.tmp199.0349.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp199.1350.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp199.2351.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.304 = icmp eq i16 %ref.tmp199.0349.load, 0
  br i1 %icmp.ln9.304, label %if.end205, label %cleanup262

if.end205:                                        ; preds = %_ZN4laya6QKTaskC2Ev.exit
  %prob.ref.epoch = add i32 %qk.score.epoch, 1
  call fastcc void @"laya::full::full_begin_inplace_owner"(i16* %ref.tmp218.0333, i32* %ref.tmp218.1334, i64* %ref.tmp218.2335, i8 %qk.score.id, i8 %qk.score.bank, i32 %qk.score.epoch, i8 0, i8 %stage, i8 %layer, i8 %batch.6, i8 0, i16 %row0.1, i16 16, i16 %qk.S, i8 6, i8 %qk.score.id, i8 %qk.score.bank, i32 %prob.ref.epoch, i8 0, i8 %stage, i8 %layer, i8 %batch.6, i8 0, i16 %row0.1, i16 16, i16 %qk.S, i8 7)
  %ref.tmp218.0333.load = load i16, i16* %ref.tmp218.0333, align 512
  %ref.tmp218.1334.load = load i32, i32* %ref.tmp218.1334, align 512
  %ref.tmp218.2335.load = load i64, i64* %ref.tmp218.2335, align 512
  store i16 %ref.tmp218.0333.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp218.1334.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp218.2335.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.305 = icmp eq i16 %ref.tmp218.0333.load, 0
  br i1 %icmp.ln9.305, label %if.end222, label %cleanup262

if.end222:                                        ; preds = %if.end205
  %"(anonymous namespace)::runtime.last_task_id.load.6" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !20181, !noalias !20184
  %sm.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.6", 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::SoftmaxTask>"(i16* %ref.tmp232.0309, i32* %ref.tmp232.1310, i64* %ref.tmp232.2311, i8 addrspace(1)* %embedding, i64 %this_memory.0, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i8 addrspace(1)* %aux, i64 %this_memory.10, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %sm.ctx.task_id, i8 81, i8 %stage, i8 %layer, i8 %batch.6, i8 0, i16 %row0.1, i8 16, i8 %qk.score.id, i8 %qk.score.bank, i32 %qk.score.epoch, i8 %qk.score.id, i8 %qk.score.bank, i32 %prob.ref.epoch, i16 %qk.S, i8 0, i8 0, i8 0, i32 %shl.ln321)
  %ref.tmp232.0309.load = load i16, i16* %ref.tmp232.0309, align 512
  %ref.tmp232.1310.load = load i32, i32* %ref.tmp232.1310, align 512
  %ref.tmp232.2311.load = load i64, i64* %ref.tmp232.2311, align 512
  store i16 %ref.tmp232.0309.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp232.1310.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp232.2311.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.306 = icmp eq i16 %ref.tmp232.0309.load, 0
  br i1 %icmp.ln9.306, label %if.end238, label %cleanup262

if.end238:                                        ; preds = %if.end222
  %"(anonymous namespace)::runtime.last_task_id.load.7" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !20193, !noalias !20196
  %av.ctx.task_id = add i32 %"(anonymous namespace)::runtime.last_task_id.load.7", 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %ref.tmp247.0283, i8* %ref.tmp247.1284, i32* %ref.tmp247.2285, i8 40, i8 0, i8 0)
  %av.partial.id = load i8, i8* %ref.tmp247.0283, align 512
  %av.partial.bank = load i8, i8* %ref.tmp247.1284, align 512
  %av.partial.epoch = load i32, i32* %ref.tmp247.2285, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::issue<laya::AVTask>"(i16* %ref.tmp254.0277, i32* %ref.tmp254.1278, i64* %ref.tmp254.2279, i8 addrspace(1)* %io, i64 %this_memory.2, i8 addrspace(1)* %state0, i64 %this_memory.12, i8 addrspace(1)* %state1, i64 %this_memory.14, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i8 addrspace(1)* %ff0, i64 %this_memory.20, i8 addrspace(1)* %ff1, i64 %this_memory.22, i8 addrspace(1)* %att_out, i64 %this_memory.24, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i32 %av.ctx.task_id, i8 %stage, i8 %layer, i8 %batch.6, i16 %row0.1, i8 %qk.score.id, i8 %qk.score.bank, i32 %prob.ref.epoch, i8 %load.dst.id.2, i8 %load.dst.bank.2, i32 %load.dst.epoch.2, i8 %av.partial.id, i8 %av.partial.bank, i32 %av.partial.epoch, i8 %ref.id, i8 %ref.bank, i32 %ref.epoch, i8 %load.head, i16 %qk.S)
  %ref.tmp254.0277.load = load i16, i16* %ref.tmp254.0277, align 512
  %ref.tmp254.1278.load = load i32, i32* %ref.tmp254.1278, align 512
  %ref.tmp254.2279.load = load i64, i64* %ref.tmp254.2279, align 512
  store i16 %ref.tmp254.0277.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp254.1278.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp254.2279.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.307 = icmp eq i16 %ref.tmp254.0277.load, 0
  br label %cleanup262

cleanup262:                                       ; preds = %if.end238, %if.end222, %if.end205, %_ZN4laya6QKTaskC2Ev.exit
  %13 = phi i16 [ %ref.tmp254.0277.load, %if.end238 ], [ %ref.tmp199.0349.load, %_ZN4laya6QKTaskC2Ev.exit ], [ %ref.tmp218.0333.load, %if.end205 ], [ %ref.tmp232.0309.load, %if.end222 ]
  %cleanup.dest.slot.5 = phi i1 [ %icmp.ln9.307, %if.end238 ], [ false, %_ZN4laya6QKTaskC2Ev.exit ], [ false, %if.end205 ], [ false, %if.end222 ]
  br i1 %cleanup.dest.slot.5, label %for.inc265, label %for.inc269

for.inc265:                                       ; preds = %cleanup262
  %row.30 = add nuw nsw i32 %row.28, 16
  br label %for.cond160, !llvm.loop !20205

for.inc269:                                       ; preds = %cleanup262, %for.cond160
  %14 = phi i16 [ %11, %for.cond160 ], [ %13, %cleanup262 ]
  %15 = phi i16 [ %12, %for.cond160 ], [ %13, %cleanup262 ]
  %b.28 = add nuw nsw i32 %b.26, 1
  br label %for.cond147, !llvm.loop !20215

for.inc276:                                       ; preds = %for.cond147
  %.lcssa10 = phi i16 [ %10, %for.cond147 ]
  %.lcssa = phi i16 [ %9, %for.cond147 ]
  %head.4 = add nuw nsw i32 %head.3, 1
  br label %for.cond108, !llvm.loop !20219

for.end279:                                       ; preds = %for.body114, %for.cond108
  %16 = phi i16 [ %7, %for.cond108 ], [ %ref.tmp141.0393.load, %for.body114 ]
  %icmp.ln9.299 = icmp eq i16 %16, 0
  br i1 %icmp.ln9.299, label %if.then281, label %if.end284

if.then281:                                       ; preds = %for.end279
  call fastcc void @"laya::full::full_publish_att"(i16* %ref.tmp282.0271, i32* %ref.tmp282.1272, i64* %ref.tmp282.2273, i8 %ref.id, i8 %ref.bank, i32 %ref.epoch, i8 %stage, i8 %layer, i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %ref.tmp282.0271.load = load i16, i16* %ref.tmp282.0271, align 512
  %ref.tmp282.1272.load = load i32, i32* %ref.tmp282.1272, align 512
  %ref.tmp282.2273.load = load i64, i64* %ref.tmp282.2273, align 512
  store i16 %ref.tmp282.0271.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp282.1272.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp282.2273.load, i64* %agg.result_bad_element, align 512
  br label %if.end284

if.end284:                                        ; preds = %if.then281, %for.end279
  %17 = phi i16 [ %ref.tmp282.0271.load, %if.then281 ], [ %16, %for.end279 ]
  %icmp.ln9.300 = icmp eq i16 %17, 0
  br i1 %icmp.ln9.300, label %if.then286, label %if.end296

if.then286:                                       ; preds = %if.end284
  %final.content.load.2 = load i8, i8* %final.content.addr, align 512, !alias.scope !20223, !noalias !20226
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %final.content.load.2) #1
  call fastcc void @"laya::full::full_release_owner.7"(i16* %ref.tmp287.0265, i32* %ref.tmp287.1266, i64* %ref.tmp287.2267, i8 %produced_ref_id.0.0.val, i8 %produced_ref_bank.0.0.val, i32 %arrayinit.begin.0.2551.val, i8 %produced_region.load, i8 %produced_stage.load, i8 %produced_layer.load, i8 %produced_batch.load, i8 %produced_row_space.load, i16 %produced_row0.load, i16 %produced_rows.load, i16 %produced_width.load, i8 %final.content.load.2)
  %ref.tmp287.0265.load = load i16, i16* %ref.tmp287.0265, align 512
  %ref.tmp287.1266.load = load i32, i32* %ref.tmp287.1266, align 512
  %ref.tmp287.2267.load = load i64, i64* %ref.tmp287.2267, align 512
  store i16 %ref.tmp287.0265.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp287.1266.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp287.2267.load, i64* %agg.result_bad_element, align 512
  %icmp.ln9.302 = icmp eq i16 %ref.tmp287.0265.load, 0
  br i1 %icmp.ln9.302, label %if.then291, label %if.end295

if.then291:                                       ; preds = %if.then286
  %final.content.load.3 = load i8, i8* %final.content.addr.1, align 4, !alias.scope !20223, !noalias !20226
  call void (...) @_ssdm_SpecKeepArrayLoad(i8 %final.content.load.3) #1
  call fastcc void @"laya::full::full_release_owner.7"(i16* %ref.tmp292.0259, i32* %ref.tmp292.1260, i64* %ref.tmp292.2261, i8 %produced_ref_id.0.1.val, i8 %produced_ref_bank.0.1.val, i32 %arrayinit.element1.0.2554.val, i8 %produced_region.load.1, i8 %produced_stage.load.1, i8 %produced_layer.load.1, i8 %produced_batch.load.1, i8 %produced_row_space.load.1, i16 %produced_row0.load.1, i16 %produced_rows.load.1, i16 %produced_width.load.1, i8 %final.content.load.3)
  %ref.tmp292.0259.load = load i16, i16* %ref.tmp292.0259, align 512
  %ref.tmp292.1260.load = load i32, i32* %ref.tmp292.1260, align 512
  %ref.tmp292.2261.load = load i64, i64* %ref.tmp292.2261, align 512
  store i16 %ref.tmp292.0259.load, i16* %agg.result_code, align 512
  store i32 %ref.tmp292.1260.load, i32* %agg.result_detail, align 512
  store i64 %ref.tmp292.2261.load, i64* %agg.result_bad_element, align 512
  br label %if.end295

if.end295:                                        ; preds = %if.then291, %if.then286
  br label %if.end296

if.end296:                                        ; preds = %if.end295, %if.end284
  br label %cleanup297

cleanup297:                                       ; preds = %if.end296, %if.end100, %if.end92, %for.end, %if.then
  ret void
}
