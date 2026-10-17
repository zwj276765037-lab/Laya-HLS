define internal fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::full_run_task.35"(i8 addrspace(1)* noalias nocapture %io, i64 %memory_io, i8 addrspace(1)* noalias nocapture %state0, i64 %memory_state0, i8 addrspace(1)* noalias nocapture %state1, i64 %memory_state1, i8 addrspace(1)* noalias nocapture %qkv0, i64 %memory_qkv0, i8 addrspace(1)* noalias nocapture %qkv1, i64 %memory_qkv1, i8 addrspace(1)* noalias nocapture %ff0, i64 %memory_ff0, i8 addrspace(1)* noalias nocapture %ff1, i64 %memory_ff1, i8 addrspace(1)* noalias nocapture %att_out, i64 %memory_att_out, i32 %t_ctx_task_id.val, i3 %t_ctx_stage.val, i5 %t_ctx_layer.val, i8 %t_ctx_batch.val, i16 %t_ctx_row0.val, i8 %t_prob_id.val, i8 %t_prob_bank.val, i32 %t_prob_epoch.val, i8 %t_kv_id.val, i8 %t_kv_bank.val, i32 %t_kv_epoch.val, i8 %t_partial_id.val, i8 %t_partial_bank.val, i32 %t_partial_epoch.val, i8 %t_dst_id.val, i8 %t_dst_bank.val, i32 %t_dst_epoch.val, i4 %t_head.val, i16 %t_S.val) #1 {
entry:
  %t_ctx_layer.val.cast = zext i5 %t_ctx_layer.val to i8
  %t_ctx_stage.val.cast = zext i3 %t_ctx_stage.val to i8
  %cond1 = icmp ugt i3 %t_ctx_stage.val, 2
  %cond2 = icmp ult i3 %t_ctx_stage.val, -3
  %cond3 = and i1 %cond2, %cond1
  call void (...) @_ssdm_Assume(i1 %cond3) #1
  %cond = icmp ugt i3 %t_ctx_stage.val, 1
  %cond21 = and i1 %cond2, %cond
  call void (...) @_ssdm_Assume(i1 %cond21) #1
  %cond22 = icmp ult i5 %t_ctx_layer.val, -4
  call void (...) @_ssdm_Assume(i1 %cond22) #1
  %cond23 = icmp ult i16 %t_ctx_row0.val, -15
  call void (...) @_ssdm_Assume(i1 %cond23) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_Assume(i1 true) #1
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %att_out, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [8 x i8]* @163, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @117, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %ff0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [4 x i8]* @218, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @99, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %qkv0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [5 x i8]* @108, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state1, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @114, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %state0, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [7 x i8]* @113, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  call void (...) @_ssdm_op_SpecInterface(i8 addrspace(1)* %io, [6 x i8]* @26, i32 0, i32 0, [1 x i8]* @38, i32 0, i32 0, [3 x i8]* @116, [6 x i8]* @100, [1 x i8]* @38, i32 1, i32 1, i32 16, i32 16, [1 x i8]* @38, [1 x i8]* @38, i32 -1, i32 0, i32 0, i32 1)
  %"(anonymous namespace)::runtime.request_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.request_valid", align 512, !alias.scope !2788, !noalias !2791
  br i1 %"(anonymous namespace)::runtime.request_valid.load", label %lor.lhs.false.i, label %if.then.i

lor.lhs.false.i:                                  ; preds = %entry
  %"(anonymous namespace)::runtime.model_header_valid.load" = load i1, i1* @"(anonymous namespace)::runtime.model_header_valid", align 512, !alias.scope !2788, !noalias !2791
  br i1 %"(anonymous namespace)::runtime.model_header_valid.load", label %lor.lhs.false1.i, label %if.then.i

lor.lhs.false1.i:                                 ; preds = %lor.lhs.false.i
  %"(anonymous namespace)::runtime.last_task_id.load" = load i32, i32* @"(anonymous namespace)::runtime.last_task_id", align 512, !alias.scope !2788, !noalias !2791
  %add.ln22 = add i32 %"(anonymous namespace)::runtime.last_task_id.load", 1
  %icmp.ln22 = icmp ne i32 %add.ln22, %t_ctx_task_id.val
  %icmp.ln22.8 = icmp eq i32 %t_ctx_task_id.val, -1
  %or.ln22 = or i1 %icmp.ln22, %icmp.ln22.8
  br i1 %or.ln22, label %if.then.i, label %if.end.i

if.then.i:                                        ; preds = %lor.lhs.false1.i, %lor.lhs.false.i, %entry
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

if.end.i:                                         ; preds = %lor.lhs.false1.i
  %"(anonymous namespace)::runtime.inputs.identity.B.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.B", align 512, !alias.scope !2788, !noalias !2791
  %"(anonymous namespace)::runtime.inputs.identity.S.load" = load i16, i16* @"(anonymous namespace)::runtime.inputs.identity.S", align 512, !alias.scope !2788, !noalias !2791
  %call.ret96 = call fastcc { i16, i32 } @"laya::check_context"(i32 %t_ctx_task_id.val, i8 82, i8 %t_ctx_stage.val.cast, i8 %t_ctx_layer.val.cast, i8 %t_ctx_batch.val, i8 0, i16 %t_ctx_row0.val, i8 16, i16 %"(anonymous namespace)::runtime.inputs.identity.B.load", i16 %"(anonymous namespace)::runtime.inputs.identity.S.load")
  %c.code = extractvalue { i16, i32 } %call.ret96, 0
  %c.detail = extractvalue { i16, i32 } %call.ret96, 1
  br label %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit

_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit: ; preds = %if.end.i, %if.then.i
  %c.detail.199.0 = phi i32 [ 122814468, %if.then.i ], [ %c.detail, %if.end.i ]
  %0 = phi i16 [ 7, %if.then.i ], [ %c.code, %if.end.i ]
  %trunc.ln9 = trunc i16 %0 to i4
  %icmp.ln9 = icmp eq i16 %0, 0
  br i1 %icmp.ln9, label %lor.lhs.false, label %if.then

if.then:                                          ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %call.ret93 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i7 -46, i4 %trunc.ln9, i32 %c.detail.199.0, i64 -1, i20 0, i4 0, i2 0)
  %newret = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 0
  %newret1 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 1
  %newret3 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 2
  %newret5 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 3
  %newret7 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 4
  %newret9 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 5
  %newret11 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 6
  %newret13 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 7
  %newret15 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret93, 8
  br label %cleanup370

lor.lhs.false:                                    ; preds = %_ZN4laya4full4task7contextERKNS0_11FullRuntimeERKNS_11TaskContextE.302.355.exit
  %icmp.ln310 = icmp eq i3 %t_ctx_stage.val, -4
  %call.ret105 = call fastcc { i16, i32, i64, i32, i16, i32, i64, i32, i8 } @"laya::full::task::finish"(i32 %t_ctx_task_id.val, i7 -46, i4 3, i32 122814469, i64 -1, i20 0, i4 0, i2 0)
  %newret17 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 0
  %newret19 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 1
  %newret21 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 2
  %newret23 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 3
  %newret25 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 4
  %newret27 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 5
  %newret29 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 6
  %newret31 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 7
  %newret33 = extractvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %call.ret105, 8
  br label %cleanup370

cleanup370:                                       ; preds = %lor.lhs.false, %if.then
  %agg.result.0.2 = phi i16 [ %newret17, %lor.lhs.false ], [ %newret, %if.then ]
  %agg.result.1.2 = phi i32 [ %newret19, %lor.lhs.false ], [ %newret1, %if.then ]
  %agg.result.2.2 = phi i64 [ %newret21, %lor.lhs.false ], [ %newret3, %if.then ]
  %done_task_id.2 = phi i32 [ %newret23, %lor.lhs.false ], [ %newret5, %if.then ]
  %done_status.2 = phi i16 [ %newret25, %lor.lhs.false ], [ %newret7, %if.then ]
  %done_error_detail.2 = phi i32 [ %newret27, %lor.lhs.false ], [ %newret9, %if.then ]
  %done_bad_element.2 = phi i64 [ %newret29, %lor.lhs.false ], [ %newret11, %if.then ]
  %done_output_elements.2 = phi i32 [ %newret31, %lor.lhs.false ], [ %newret13, %if.then ]
  %done_output_unit.2 = phi i8 [ %newret33, %lor.lhs.false ], [ %newret15, %if.then ]
  %newret2 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } undef, i16 %agg.result.0.2, 0
  %newret4 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret2, i32 %agg.result.1.2, 1
  %newret6 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret4, i64 %agg.result.2.2, 2
  %newret8 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret6, i32 %done_task_id.2, 3
  %newret10 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret8, i16 %done_status.2, 4
  %newret12 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret10, i32 %done_error_detail.2, 5
  %newret14 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret12, i64 %done_bad_element.2, 6
  %newret16 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret14, i32 %done_output_elements.2, 7
  %newret18 = insertvalue { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret16, i8 %done_output_unit.2, 8
  ret { i16, i32, i64, i32, i16, i32, i64, i32, i8 } %newret18
}
