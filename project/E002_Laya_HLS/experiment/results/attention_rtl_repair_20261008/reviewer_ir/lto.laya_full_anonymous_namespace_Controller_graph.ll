define internal fastcc void @"laya::full::(anonymous namespace)::Controller::graph"(i16* noalias align 512 %agg.result_code, i32* noalias align 512 %agg.result_detail, i64* noalias align 512 %agg.result_bad_element, i8 addrspace(1)* noalias %embedding, i64 %this_memory.0, i64* noalias align 512 %this_memory.1, i8 addrspace(1)* noalias %io, i64 %this_memory.2, i64* noalias align 512 %this_memory.3, i8 addrspace(1)* noalias %w_q0, i64 %this_memory.4, i64* noalias align 512 %this_memory.5, i8 addrspace(1)* noalias %w_q1, i64 %this_memory.6, i64* noalias align 512 %this_memory.7, i8 addrspace(1)* noalias %w_scale, i64 %this_memory.8, i64* noalias align 512 %this_memory.9, i8 addrspace(1)* noalias %aux, i64 %this_memory.10, i64* noalias align 512 %this_memory.11, i8 addrspace(1)* noalias %state0, i64 %this_memory.12, i64* noalias align 512 %this_memory.13, i8 addrspace(1)* noalias %state1, i64 %this_memory.14, i64* noalias align 512 %this_memory.15, i8 addrspace(1)* noalias %qkv0, i64 %this_memory.16, i64* noalias align 512 %this_memory.17, i8 addrspace(1)* noalias %qkv1, i64 %this_memory.18, i64* noalias align 512 %this_memory.19, i8 addrspace(1)* noalias %ff0, i64 %this_memory.20, i64* noalias align 512 %this_memory.21, i8 addrspace(1)* noalias %ff1, i64 %this_memory.22, i64* noalias align 512 %this_memory.23, i8 addrspace(1)* noalias %att_out, i64 %this_memory.24, i64* noalias align 512 %this_memory.25, i8* noalias align 512 %this_error_stage, i8* noalias align 512 %this_error_op, i32* noalias align 512 %this_error_task_id, i8* noalias align 512 %this_current_stage, i8* noalias align 512 %this_current_op, i8* noalias nocapture align 512 %candidate_ref_id, i8* noalias nocapture align 512 %candidate_ref_bank, i32* noalias nocapture align 512 %candidate_ref_epoch, i8* noalias nocapture align 512 %candidate_region, i8* noalias nocapture align 512 %candidate_stage, i8* noalias nocapture align 512 %candidate_layer, i8* noalias nocapture align 512 %candidate_batch, i8* noalias nocapture align 512 %candidate_row_space, i16* noalias nocapture align 512 %candidate_row0, i16* noalias nocapture align 512 %candidate_rows, i16* noalias nocapture align 512 %candidate_width, i8* noalias nocapture align 512 %candidate_content, i8* noalias nocapture align 512 %act_ref_id, i8* noalias nocapture align 512 %act_ref_bank, i32* noalias nocapture align 512 %act_ref_epoch, i8* noalias nocapture align 512 %act_region, i8* noalias nocapture align 512 %act_stage, i8* noalias nocapture align 512 %act_layer, i8* noalias nocapture align 512 %act_batch, i8* noalias nocapture align 512 %act_row_space, i16* noalias nocapture align 512 %act_row0, i16* noalias nocapture align 512 %act_rows, i16* noalias nocapture align 512 %act_width, i8* noalias nocapture align 512 %act_content) unnamed_addr #0 align 2 {
entry:
  %hidden = alloca [23 x i192], align 1024
  call void (...) @_ssdm_op_SpecBRAMWithByteEnable([23 x i192]* %hidden)
  call void (...) @_ssdm_SpecStream([23 x i192]* %hidden, i32 -1, i32 0, [1 x i8]* @1)
  %ref.tmp.0849 = alloca i16, align 512
  %ref.tmp.1850 = alloca i32, align 512
  %ref.tmp.2851 = alloca i64, align 512
  %normed.ref.id = alloca i8, align 512
  %normed.ref.bank = alloca i8, align 512
  %normed.ref.epoch = alloca i32, align 512
  %normed.region = alloca i8, align 512
  %normed.stage = alloca i8, align 512
  %normed.layer = alloca i8, align 512
  %normed.batch = alloca i8, align 512
  %normed.row_space = alloca i8, align 512
  %normed.row0 = alloca i16, align 512
  %normed.rows = alloca i16, align 512
  %normed.width = alloca i16, align 512
  %normed.content = alloca i8, align 512
  %ref.tmp5.0838 = alloca i16, align 512
  %ref.tmp5.1839 = alloca i32, align 512
  %ref.tmp5.2840 = alloca i64, align 512
  %agg.tmp.0 = alloca i8, align 512
  %agg.tmp.1 = alloca i8, align 512
  %agg.tmp.2 = alloca i32, align 512
  %ref.tmp10.0832 = alloca i16, align 512
  %ref.tmp10.1833 = alloca i32, align 512
  %ref.tmp10.2834 = alloca i64, align 512
  %ref.tmp16.0826 = alloca i16, align 512
  %ref.tmp16.1827 = alloca i32, align 512
  %ref.tmp16.2828 = alloca i64, align 512
  %agg.tmp17.0 = alloca i8, align 512
  %agg.tmp17.1 = alloca i8, align 512
  %agg.tmp17.2 = alloca i32, align 512
  %qkv.ref.id = alloca [2 x i8], align 512
  %qkv.ref.bank = alloca [2 x i8], align 512
  %qkv.ref.epoch = alloca [2 x i32], align 512
  %qkv.region = alloca [2 x i8], align 512
  %qkv.stage = alloca [2 x i8], align 512
  %qkv.layer = alloca [2 x i8], align 512
  %qkv.batch = alloca [2 x i8], align 512
  %qkv.row_space = alloca [2 x i8], align 512
  %qkv.row0 = alloca [2 x i16], align 512
  %qkv.rows = alloca [2 x i16], align 512
  %qkv.width = alloca [2 x i16], align 512
  %qkv.content = alloca [2 x i8], align 512
  %qkv_primary.ref.id = alloca i8, align 512
  %qkv_primary.ref.bank = alloca i8, align 512
  %qkv_primary.ref.epoch = alloca i32, align 512
  %qkv_primary.region = alloca i8, align 512
  %qkv_primary.stage = alloca i8, align 512
  %qkv_primary.layer = alloca i8, align 512
  %qkv_primary.batch = alloca i8, align 512
  %qkv_primary.row_space = alloca i8, align 512
  %qkv_primary.row0 = alloca i16, align 512
  %qkv_primary.rows = alloca i16, align 512
  %qkv_primary.width = alloca i16, align 512
  %qkv_primary.content = alloca i8, align 512
  %ref.tmp24.0802 = alloca i16, align 512
  %ref.tmp24.1803 = alloca i32, align 512
  %ref.tmp24.2804 = alloca i64, align 512
  %agg.tmp27.0 = alloca i8, align 512
  %agg.tmp27.1 = alloca i8, align 512
  %agg.tmp27.2 = alloca i32, align 512
  %ref.tmp33.0796 = alloca i16, align 512
  %ref.tmp33.1797 = alloca i32, align 512
  %ref.tmp33.2798 = alloca i64, align 512
  %attended.ref.id = alloca i8, align 512
  %attended.ref.bank = alloca i8, align 512
  %attended.ref.epoch = alloca i32, align 512
  %attended.region = alloca i8, align 512
  %attended.stage = alloca i8, align 512
  %attended.layer = alloca i8, align 512
  %attended.batch = alloca i8, align 512
  %attended.row_space = alloca i8, align 512
  %attended.row0 = alloca i16, align 512
  %attended.rows = alloca i16, align 512
  %attended.width = alloca i16, align 512
  %attended.content = alloca i8, align 512
  %ref.tmp39.0785 = alloca i16, align 512
  %ref.tmp39.1786 = alloca i32, align 512
  %ref.tmp39.2787 = alloca i64, align 512
  %projected.ref.id = alloca i8, align 512
  %projected.ref.bank = alloca i8, align 512
  %projected.ref.epoch = alloca i32, align 512
  %projected.region = alloca i8, align 512
  %projected.stage = alloca i8, align 512
  %projected.layer = alloca i8, align 512
  %projected.batch = alloca i8, align 512
  %projected.row_space = alloca i8, align 512
  %projected.row0 = alloca i16, align 512
  %projected.rows = alloca i16, align 512
  %projected.width = alloca i16, align 512
  %projected.content = alloca i8, align 512
  %ref.tmp43.0774 = alloca i16, align 512
  %ref.tmp43.1775 = alloca i32, align 512
  %ref.tmp43.2776 = alloca i64, align 512
  %agg.tmp47.0 = alloca i8, align 512
  %agg.tmp47.1 = alloca i8, align 512
  %agg.tmp47.2 = alloca i32, align 512
  %ref.tmp51.0768 = alloca i16, align 512
  %ref.tmp51.1769 = alloca i32, align 512
  %ref.tmp51.2770 = alloca i64, align 512
  %ref.tmp56.0762 = alloca i16, align 512
  %ref.tmp56.1763 = alloca i32, align 512
  %ref.tmp56.2764 = alloca i64, align 512
  %ref.tmp60.0756 = alloca i16, align 512
  %ref.tmp60.1757 = alloca i32, align 512
  %ref.tmp60.2758 = alloca i64, align 512
  %agg.tmp61.0 = alloca i8, align 512
  %agg.tmp61.1 = alloca i8, align 512
  %agg.tmp61.2 = alloca i32, align 512
  %wide.ref.id = alloca i8, align 512
  %wide.ref.bank = alloca i8, align 512
  %wide.ref.epoch = alloca i32, align 512
  %wide.region = alloca i8, align 512
  %wide.stage = alloca i8, align 512
  %wide.layer = alloca i8, align 512
  %wide.batch = alloca i8, align 512
  %wide.row_space = alloca i8, align 512
  %wide.row0 = alloca i16, align 512
  %wide.rows = alloca i16, align 512
  %wide.width = alloca i16, align 512
  %wide.content = alloca i8, align 512
  %ref.tmp65.0745 = alloca i16, align 512
  %ref.tmp65.1746 = alloca i32, align 512
  %ref.tmp65.2747 = alloca i64, align 512
  %agg.tmp69.0 = alloca i8, align 512
  %agg.tmp69.1 = alloca i8, align 512
  %agg.tmp69.2 = alloca i32, align 512
  %ref.tmp73.0739 = alloca i16, align 512
  %ref.tmp73.1740 = alloca i32, align 512
  %ref.tmp73.2741 = alloca i64, align 512
  %gated.ref.id = alloca i8, align 512
  %gated.ref.bank = alloca i8, align 512
  %gated.ref.epoch = alloca i32, align 512
  %gated.region = alloca i8, align 512
  %gated.stage = alloca i8, align 512
  %gated.layer = alloca i8, align 512
  %gated.batch = alloca i8, align 512
  %gated.row_space = alloca i8, align 512
  %gated.row0 = alloca i16, align 512
  %gated.rows = alloca i16, align 512
  %gated.width = alloca i16, align 512
  %gated.content = alloca i8, align 512
  %ref.tmp78.0728 = alloca i16, align 512
  %ref.tmp78.1729 = alloca i32, align 512
  %ref.tmp78.2730 = alloca i64, align 512
  %agg.tmp79.0 = alloca i8, align 512
  %agg.tmp79.1 = alloca i8, align 512
  %agg.tmp79.2 = alloca i32, align 512
  %ref.tmp83.0722 = alloca i16, align 512
  %ref.tmp83.1723 = alloca i32, align 512
  %ref.tmp83.2724 = alloca i64, align 512
  %down.ref.id = alloca i8, align 512
  %down.ref.bank = alloca i8, align 512
  %down.ref.epoch = alloca i32, align 512
  %down.region = alloca i8, align 512
  %down.stage = alloca i8, align 512
  %down.layer = alloca i8, align 512
  %down.batch = alloca i8, align 512
  %down.row_space = alloca i8, align 512
  %down.row0 = alloca i16, align 512
  %down.rows = alloca i16, align 512
  %down.width = alloca i16, align 512
  %down.content = alloca i8, align 512
  %ref.tmp88.0711 = alloca i16, align 512
  %ref.tmp88.1712 = alloca i32, align 512
  %ref.tmp88.2713 = alloca i64, align 512
  %agg.tmp92.0 = alloca i8, align 512
  %agg.tmp92.1 = alloca i8, align 512
  %agg.tmp92.2 = alloca i32, align 512
  %ref.tmp96.0705 = alloca i16, align 512
  %ref.tmp96.1706 = alloca i32, align 512
  %ref.tmp96.2707 = alloca i64, align 512
  %ref.tmp101.0699 = alloca i16, align 512
  %ref.tmp101.1700 = alloca i32, align 512
  %ref.tmp101.2701 = alloca i64, align 512
  %ref.tmp117.0693 = alloca i16, align 512
  %ref.tmp117.1694 = alloca i32, align 512
  %ref.tmp117.2695 = alloca i64, align 512
  %final_norm.ref.id = alloca i8, align 512
  %final_norm.ref.bank = alloca i8, align 512
  %final_norm.ref.epoch = alloca i32, align 512
  %final_norm.region = alloca i8, align 512
  %final_norm.stage = alloca i8, align 512
  %final_norm.layer = alloca i8, align 512
  %final_norm.batch = alloca i8, align 512
  %final_norm.row_space = alloca i8, align 512
  %final_norm.row0 = alloca i16, align 512
  %final_norm.rows = alloca i16, align 512
  %final_norm.width = alloca i16, align 512
  %final_norm.content = alloca i8, align 512
  %ref.tmp121.0682 = alloca i16, align 512
  %ref.tmp121.1683 = alloca i32, align 512
  %ref.tmp121.2684 = alloca i64, align 512
  %agg.tmp122.0 = alloca i8, align 512
  %agg.tmp122.1 = alloca i8, align 512
  %agg.tmp122.2 = alloca i32, align 512
  %ref.tmp131.0676 = alloca i16, align 512
  %ref.tmp131.1677 = alloca i32, align 512
  %ref.tmp131.2678 = alloca i64, align 512
  %ref.tmp136.0670 = alloca i16, align 512
  %ref.tmp136.1671 = alloca i32, align 512
  %ref.tmp136.2672 = alloca i64, align 512
  %normalized146.ref.id = alloca i8, align 512
  %normalized146.ref.bank = alloca i8, align 512
  %normalized146.ref.epoch = alloca i32, align 512
  %normalized146.region = alloca i8, align 512
  %normalized146.stage = alloca i8, align 512
  %normalized146.layer = alloca i8, align 512
  %normalized146.batch = alloca i8, align 512
  %normalized146.row_space = alloca i8, align 512
  %normalized146.row0 = alloca i16, align 512
  %normalized146.rows = alloca i16, align 512
  %normalized146.width = alloca i16, align 512
  %normalized146.content = alloca i8, align 512
  %ref.tmp147.0659 = alloca i16, align 512
  %ref.tmp147.1660 = alloca i32, align 512
  %ref.tmp147.2661 = alloca i64, align 512
  %agg.tmp148.0 = alloca i8, align 512
  %agg.tmp148.1 = alloca i8, align 512
  %agg.tmp148.2 = alloca i32, align 512
  %qkv152.ref.id = alloca [2 x i8], align 512
  %qkv152.ref.bank = alloca [2 x i8], align 512
  %qkv152.ref.epoch = alloca [2 x i32], align 512
  %qkv152.region = alloca [2 x i8], align 512
  %qkv152.stage = alloca [2 x i8], align 512
  %qkv152.layer = alloca [2 x i8], align 512
  %qkv152.batch = alloca [2 x i8], align 512
  %qkv152.row_space = alloca [2 x i8], align 512
  %qkv152.row0 = alloca [2 x i16], align 512
  %qkv152.rows = alloca [2 x i16], align 512
  %qkv152.width = alloca [2 x i16], align 512
  %qkv152.content = alloca [2 x i8], align 512
  %qkv_primary160.ref.id = alloca i8, align 512
  %qkv_primary160.ref.bank = alloca i8, align 512
  %qkv_primary160.ref.epoch = alloca i32, align 512
  %qkv_primary160.region = alloca i8, align 512
  %qkv_primary160.stage = alloca i8, align 512
  %qkv_primary160.layer = alloca i8, align 512
  %qkv_primary160.batch = alloca i8, align 512
  %qkv_primary160.row_space = alloca i8, align 512
  %qkv_primary160.row0 = alloca i16, align 512
  %qkv_primary160.rows = alloca i16, align 512
  %qkv_primary160.width = alloca i16, align 512
  %qkv_primary160.content = alloca i8, align 512
  %ref.tmp161.0635 = alloca i16, align 512
  %ref.tmp161.1636 = alloca i32, align 512
  %ref.tmp161.2637 = alloca i64, align 512
  %agg.tmp165.0 = alloca i8, align 512
  %agg.tmp165.1 = alloca i8, align 512
  %agg.tmp165.2 = alloca i32, align 512
  %ref.tmp170.0629 = alloca i16, align 512
  %ref.tmp170.1630 = alloca i32, align 512
  %ref.tmp170.2631 = alloca i64, align 512
  %attended175.ref.id = alloca i8, align 512
  %attended175.ref.bank = alloca i8, align 512
  %attended175.ref.epoch = alloca i32, align 512
  %attended175.region = alloca i8, align 512
  %attended175.stage = alloca i8, align 512
  %attended175.layer = alloca i8, align 512
  %attended175.batch = alloca i8, align 512
  %attended175.row_space = alloca i8, align 512
  %attended175.row0 = alloca i16, align 512
  %attended175.rows = alloca i16, align 512
  %attended175.width = alloca i16, align 512
  %attended175.content = alloca i8, align 512
  %ref.tmp176.0618 = alloca i16, align 512
  %ref.tmp176.1619 = alloca i32, align 512
  %ref.tmp176.2620 = alloca i64, align 512
  %projected180.ref.id = alloca i8, align 512
  %projected180.ref.bank = alloca i8, align 512
  %projected180.ref.epoch = alloca i32, align 512
  %projected180.region = alloca i8, align 512
  %projected180.stage = alloca i8, align 512
  %projected180.layer = alloca i8, align 512
  %projected180.batch = alloca i8, align 512
  %projected180.row_space = alloca i8, align 512
  %projected180.row0 = alloca i16, align 512
  %projected180.rows = alloca i16, align 512
  %projected180.width = alloca i16, align 512
  %projected180.content = alloca i8, align 512
  %ref.tmp181.0607 = alloca i16, align 512
  %ref.tmp181.1608 = alloca i32, align 512
  %ref.tmp181.2609 = alloca i64, align 512
  %agg.tmp185.0 = alloca i8, align 512
  %agg.tmp185.1 = alloca i8, align 512
  %agg.tmp185.2 = alloca i32, align 512
  %ref.tmp189.0601 = alloca i16, align 512
  %ref.tmp189.1602 = alloca i32, align 512
  %ref.tmp189.2603 = alloca i64, align 512
  %ref.tmp194.0595 = alloca i16, align 512
  %ref.tmp194.1596 = alloca i32, align 512
  %ref.tmp194.2597 = alloca i64, align 512
  %ref.tmp198.0589 = alloca i16, align 512
  %ref.tmp198.1590 = alloca i32, align 512
  %ref.tmp198.2591 = alloca i64, align 512
  %agg.tmp199.0 = alloca i8, align 512
  %agg.tmp199.1 = alloca i8, align 512
  %agg.tmp199.2 = alloca i32, align 512
  %fc1.ref.id = alloca i8, align 512
  %fc1.ref.bank = alloca i8, align 512
  %fc1.ref.epoch = alloca i32, align 512
  %fc1.region = alloca i8, align 512
  %fc1.stage = alloca i8, align 512
  %fc1.layer = alloca i8, align 512
  %fc1.batch = alloca i8, align 512
  %fc1.row_space = alloca i8, align 512
  %fc1.row0 = alloca i16, align 512
  %fc1.rows = alloca i16, align 512
  %fc1.width = alloca i16, align 512
  %fc1.content = alloca i8, align 512
  %ref.tmp203.0578 = alloca i16, align 512
  %ref.tmp203.1579 = alloca i32, align 512
  %ref.tmp203.2580 = alloca i64, align 512
  %agg.tmp207.0 = alloca i8, align 512
  %agg.tmp207.1 = alloca i8, align 512
  %agg.tmp207.2 = alloca i32, align 512
  %ref.tmp211.0572 = alloca i16, align 512
  %ref.tmp211.1573 = alloca i32, align 512
  %ref.tmp211.2574 = alloca i64, align 512
  %relu.ref.id = alloca i8, align 512
  %relu.ref.bank = alloca i8, align 512
  %relu.ref.epoch = alloca i32, align 512
  %relu.region = alloca i8, align 512
  %relu.stage = alloca i8, align 512
  %relu.layer = alloca i8, align 512
  %relu.batch = alloca i8, align 512
  %relu.row_space = alloca i8, align 512
  %relu.row0 = alloca i16, align 512
  %relu.rows = alloca i16, align 512
  %relu.width = alloca i16, align 512
  %relu.content = alloca i8, align 512
  %ref.tmp216.0561 = alloca i16, align 512
  %ref.tmp216.1562 = alloca i32, align 512
  %ref.tmp216.2563 = alloca i64, align 512
  %fc2.ref.id = alloca i8, align 512
  %fc2.ref.bank = alloca i8, align 512
  %fc2.ref.epoch = alloca i32, align 512
  %fc2.region = alloca i8, align 512
  %fc2.stage = alloca i8, align 512
  %fc2.layer = alloca i8, align 512
  %fc2.batch = alloca i8, align 512
  %fc2.row_space = alloca i8, align 512
  %fc2.row0 = alloca i16, align 512
  %fc2.rows = alloca i16, align 512
  %fc2.width = alloca i16, align 512
  %fc2.content = alloca i8, align 512
  %ref.tmp220.0550 = alloca i16, align 512
  %ref.tmp220.1551 = alloca i32, align 512
  %ref.tmp220.2552 = alloca i64, align 512
  %agg.tmp224.0 = alloca i8, align 512
  %agg.tmp224.1 = alloca i8, align 512
  %agg.tmp224.2 = alloca i32, align 512
  %ref.tmp228.0544 = alloca i16, align 512
  %ref.tmp228.1545 = alloca i32, align 512
  %ref.tmp228.2546 = alloca i64, align 512
  %ref.tmp233.0538 = alloca i16, align 512
  %ref.tmp233.1539 = alloca i32, align 512
  %ref.tmp233.2540 = alloca i64, align 512
  %markers.ref.id = alloca i8, align 512
  %markers.ref.bank = alloca i8, align 512
  %markers.ref.epoch = alloca i32, align 512
  %markers.region = alloca i8, align 512
  %markers.stage = alloca i8, align 512
  %markers.layer = alloca i8, align 512
  %markers.batch = alloca i8, align 512
  %markers.row_space = alloca i8, align 512
  %markers.row0 = alloca i16, align 512
  %markers.rows = alloca i16, align 512
  %markers.width = alloca i16, align 512
  %markers.content = alloca i8, align 512
  %ref.tmp254.0527 = alloca i16, align 512
  %ref.tmp254.1528 = alloca i32, align 512
  %ref.tmp254.2529 = alloca i64, align 512
  %marker_norm.ref.id = alloca i8, align 512
  %marker_norm.ref.bank = alloca i8, align 512
  %marker_norm.ref.epoch = alloca i32, align 512
  %marker_norm.region = alloca i8, align 512
  %marker_norm.stage = alloca i8, align 512
  %marker_norm.layer = alloca i8, align 512
  %marker_norm.batch = alloca i8, align 512
  %marker_norm.row_space = alloca i8, align 512
  %marker_norm.row0 = alloca i16, align 512
  %marker_norm.rows = alloca i16, align 512
  %marker_norm.width = alloca i16, align 512
  %marker_norm.content = alloca i8, align 512
  %ref.tmp258.0516 = alloca i16, align 512
  %ref.tmp258.1517 = alloca i32, align 512
  %ref.tmp258.2518 = alloca i64, align 512
  %agg.tmp259.0 = alloca i8, align 512
  %agg.tmp259.1 = alloca i8, align 512
  %agg.tmp259.2 = alloca i32, align 512
  %ref.tmp263.0510 = alloca i16, align 512
  %ref.tmp263.1511 = alloca i32, align 512
  %ref.tmp263.2512 = alloca i64, align 512
  %scorer_baked.ref.id = alloca i8, align 512
  %scorer_baked.ref.bank = alloca i8, align 512
  %scorer_baked.ref.epoch = alloca i32, align 512
  %scorer_baked.region = alloca i8, align 512
  %scorer_baked.stage = alloca i8, align 512
  %scorer_baked.layer = alloca i8, align 512
  %scorer_baked.batch = alloca i8, align 512
  %scorer_baked.row_space = alloca i8, align 512
  %scorer_baked.row0 = alloca i16, align 512
  %scorer_baked.rows = alloca i16, align 512
  %scorer_baked.width = alloca i16, align 512
  %scorer_baked.content = alloca i8, align 512
  %ref.tmp269.0499 = alloca i16, align 512
  %ref.tmp269.1500 = alloca i32, align 512
  %ref.tmp269.2501 = alloca i64, align 512
  %ref.tmp274.0493 = alloca i16, align 512
  %ref.tmp274.1494 = alloca i32, align 512
  %ref.tmp274.2495 = alloca i64, align 512
  %ref.tmp282.0484 = alloca i16, align 512
  %ref.tmp282.1485 = alloca i32, align 512
  %ref.tmp282.2486 = alloca i64, align 512
  %tmp.0 = alloca i16, align 512
  %tmp.1 = alloca i32, align 512
  %tmp.2 = alloca i64, align 512
  %scorer_bias.name = alloca [48 x i8], align 512
  %scorer_bias.ggml_type_id = alloca i8, align 512
  %scorer_bias.bo = alloca i8, align 512
  %scorer_bias.omitted = alloca i8, align 512
  %scorer_bias.reserved = alloca i8, align 512
  %scorer_bias.ne = alloca [4 x i32], align 512
  %scorer_bias.source_offset = alloca i32, align 512
  %scorer_bias.source_bytes = alloca i32, align 512
  %scorer_bias.base = alloca i32, align 512
  %scorer_bias.span = alloca i32, align 512
  %scorer_bias.source_sha256 = alloca [32 x i8], align 512
  %scorer_bias_id = alloca i16, align 512
  %ref.tmp291.0465 = alloca i16, align 512
  %ref.tmp291.1466 = alloca i32, align 512
  %ref.tmp291.2467 = alloca i64, align 512
  %scorer_hidden.ref.id = alloca i8, align 512
  %scorer_hidden.ref.bank = alloca i8, align 512
  %scorer_hidden.ref.epoch = alloca i32, align 512
  %scorer_hidden.region = alloca i8, align 512
  %scorer_hidden.stage = alloca i8, align 512
  %scorer_hidden.layer = alloca i8, align 512
  %scorer_hidden.batch = alloca i8, align 512
  %scorer_hidden.row_space = alloca i8, align 512
  %scorer_hidden.row0 = alloca i16, align 512
  %scorer_hidden.rows = alloca i16, align 512
  %scorer_hidden.width = alloca i16, align 512
  %scorer_hidden.content = alloca i8, align 512
  %ref.tmp295.0454 = alloca i16, align 512
  %ref.tmp295.1455 = alloca i32, align 512
  %ref.tmp295.2456 = alloca i64, align 512
  %raw.ref.id = alloca i8, align 512
  %raw.ref.bank = alloca i8, align 512
  %raw.ref.epoch = alloca i32, align 512
  %raw.region = alloca i8, align 512
  %raw.stage = alloca i8, align 512
  %raw.layer = alloca i8, align 512
  %raw.batch = alloca i8, align 512
  %raw.row_space = alloca i8, align 512
  %raw.row0 = alloca i16, align 512
  %raw.rows = alloca i16, align 512
  %raw.width = alloca i16, align 512
  %raw.content = alloca i8, align 512
  %ref.tmp299.0443 = alloca i16, align 512
  %ref.tmp299.1444 = alloca i32, align 512
  %ref.tmp299.2445 = alloca i64, align 512
  %ref.tmp307.0437 = alloca i16, align 512
  %ref.tmp307.1438 = alloca i32, align 512
  %ref.tmp307.2439 = alloca i64, align 512
  %prob.ref.id = alloca i8, align 512
  %prob.ref.bank = alloca i8, align 512
  %prob.ref.epoch = alloca i32, align 512
  %prob.region = alloca i8, align 512
  %prob.stage = alloca i8, align 512
  %prob.layer = alloca i8, align 512
  %prob.batch = alloca i8, align 512
  %prob.row_space = alloca i8, align 512
  %prob.row0 = alloca i16, align 512
  %prob.rows = alloca i16, align 512
  %prob.width = alloca i16, align 512
  %prob.content = alloca i8, align 512
  %ref.tmp311.0426 = alloca i16, align 512
  %ref.tmp311.1427 = alloca i32, align 512
  %ref.tmp311.2428 = alloca i64, align 512
  %stats.ref.id = alloca i8, align 512
  %stats.ref.bank = alloca i8, align 512
  %stats.ref.epoch = alloca i32, align 512
  %stats.region = alloca i8, align 512
  %stats.stage = alloca i8, align 512
  %stats.layer = alloca i8, align 512
  %stats.batch = alloca i8, align 512
  %stats.row_space = alloca i8, align 512
  %stats.row0 = alloca i16, align 512
  %stats.rows = alloca i16, align 512
  %stats.width = alloca i16, align 512
  %stats.content = alloca i8, align 512
  %ref.tmp315.0415 = alloca i16, align 512
  %ref.tmp315.1416 = alloca i32, align 512
  %ref.tmp315.2417 = alloca i64, align 512
  %act_input.ref.id = alloca i8, align 512
  %act_input.ref.bank = alloca i8, align 512
  %act_input.ref.epoch = alloca i32, align 512
  %act_input.region = alloca i8, align 512
  %act_input.stage = alloca i8, align 512
  %act_input.layer = alloca i8, align 512
  %act_input.batch = alloca i8, align 512
  %act_input.row_space = alloca i8, align 512
  %act_input.row0 = alloca i16, align 512
  %act_input.rows = alloca i16, align 512
  %act_input.width = alloca i16, align 512
  %act_input.content = alloca i8, align 512
  %ref.tmp319.0404 = alloca i16, align 512
  %ref.tmp319.1405 = alloca i32, align 512
  %ref.tmp319.2406 = alloca i64, align 512
  %act_dot.ref.id = alloca i8, align 512
  %act_dot.ref.bank = alloca i8, align 512
  %act_dot.ref.epoch = alloca i32, align 512
  %act_dot.region = alloca i8, align 512
  %act_dot.stage = alloca i8, align 512
  %act_dot.layer = alloca i8, align 512
  %act_dot.batch = alloca i8, align 512
  %act_dot.row_space = alloca i8, align 512
  %act_dot.row0 = alloca i16, align 512
  %act_dot.rows = alloca i16, align 512
  %act_dot.width = alloca i16, align 512
  %act_dot.content = alloca i8, align 512
  %ref.tmp323.0393 = alloca i16, align 512
  %ref.tmp323.1394 = alloca i32, align 512
  %ref.tmp323.2395 = alloca i64, align 512
  %act_bias.name = alloca [48 x i8], align 512
  %act_bias.ggml_type_id = alloca i8, align 512
  %act_bias.bo = alloca i8, align 512
  %act_bias.omitted = alloca i8, align 512
  %act_bias.reserved = alloca i8, align 512
  %act_bias.ne = alloca [4 x i32], align 512
  %act_bias.source_offset = alloca i32, align 512
  %act_bias.source_bytes = alloca i32, align 512
  %act_bias.base = alloca i32, align 512
  %act_bias.span = alloca i32, align 512
  %act_bias.source_sha256 = alloca [32 x i8], align 512
  %act_bias_id = alloca i16, align 512
  %ref.tmp331.0380 = alloca i16, align 512
  %ref.tmp331.1381 = alloca i32, align 512
  %ref.tmp331.2382 = alloca i64, align 512
  %act_hidden.ref.id = alloca i8, align 512
  %act_hidden.ref.bank = alloca i8, align 512
  %act_hidden.ref.epoch = alloca i32, align 512
  %act_hidden.region = alloca i8, align 512
  %act_hidden.stage = alloca i8, align 512
  %act_hidden.layer = alloca i8, align 512
  %act_hidden.batch = alloca i8, align 512
  %act_hidden.row_space = alloca i8, align 512
  %act_hidden.row0 = alloca i16, align 512
  %act_hidden.rows = alloca i16, align 512
  %act_hidden.width = alloca i16, align 512
  %act_hidden.content = alloca i8, align 512
  %ref.tmp335.0369 = alloca i16, align 512
  %ref.tmp335.1370 = alloca i32, align 512
  %ref.tmp335.2371 = alloca i64, align 512
  %ref.tmp339.0363 = alloca i16, align 512
  %ref.tmp339.1364 = alloca i32, align 512
  %ref.tmp339.2365 = alloca i64, align 512
  %agg.tmp343.0 = alloca i8, align 512
  %agg.tmp343.1 = alloca i8, align 512
  %agg.tmp343.2 = alloca i32, align 512
  %0 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 0
  call void @_ssdm_op_Write.bram.p0L_a6i32packedL(i192* %0, i192 79226953588444722964369244160, i24 2088947)
  call fastcc void @"laya::full::(anonymous namespace)::Controller::embed_tokens"(i16* %agg.result_code, i32* %agg.result_detail, i64* %agg.result_bad_element, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i64* %this_memory.5, i64* %this_memory.7, i64* %this_memory.9, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, [23 x i192]* %hidden)
  %agg.result_code.val55 = load i16, i16* %agg.result_code, align 512
  %1 = call fastcc i1 @"laya::Check::operator bool"(i16 %agg.result_code.val55)
  br i1 %1, label %if.end, label %cleanup363

if.end:                                           ; preds = %entry
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_gamma"(i16* %ref.tmp.0849, i32* %ref.tmp.1850, i64* %ref.tmp.2851, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 1)
  %.0357 = load i16, i16* %ref.tmp.0849, align 512
  %.1359 = load i32, i32* %ref.tmp.1850, align 512
  %.2361 = load i64, i64* %ref.tmp.2851, align 512
  store i16 %.0357, i16* %agg.result_code, align 512
  store i32 %.1359, i32* %agg.result_detail, align 512
  store i64 %.2361, i64* %agg.result_bad_element, align 512
  %2 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0357)
  br i1 %2, label %if.end4, label %cleanup363

if.end4:                                          ; preds = %if.end
  store i8 0, i8* %normed.ref.id, align 512, !alias.scope !7183, !noalias !7188
  store i8 0, i8* %normed.ref.bank, align 512, !alias.scope !7202, !noalias !7203
  store i32 0, i32* %normed.ref.epoch, align 512, !alias.scope !7204, !noalias !7205
  store i8 0, i8* %normed.region, align 512, !alias.scope !7206, !noalias !7207
  store i8 0, i8* %normed.stage, align 512, !alias.scope !7208, !noalias !7209
  store i8 -1, i8* %normed.layer, align 512, !alias.scope !7210, !noalias !7211
  store i8 -1, i8* %normed.batch, align 512, !alias.scope !7212, !noalias !7213
  store i8 0, i8* %normed.row_space, align 512, !alias.scope !7214, !noalias !7215
  store i16 0, i16* %normed.row0, align 512, !alias.scope !7216, !noalias !7217
  store i16 0, i16* %normed.rows, align 512, !alias.scope !7218, !noalias !7219
  store i16 0, i16* %normed.width, align 512, !alias.scope !7220, !noalias !7221
  store i8 0, i8* %normed.content, align 512, !alias.scope !7222, !noalias !7223
  %3 = load i192, i192* %0
  %4 = lshr i192 %3, 8
  %5 = trunc i192 %4 to i8
  %sub = sub i8 1, %5
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp.0, i8* %agg.tmp.1, i32* %agg.tmp.2, i8 1, i8 %sub, i8 0)
  %6 = load i8, i8* %agg.tmp.0, align 512
  %7 = load i8, i8* %agg.tmp.1, align 512
  %8 = load i32, i32* %agg.tmp.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm"(i16* %ref.tmp5.0838, i32* %ref.tmp5.1839, i64* %ref.tmp5.2840, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 16, [23 x i192]* %hidden, i8 1, i8 -1, i8 %6, i8 %7, i32 %8, i8 1, i8* %normed.ref.id, i8* %normed.ref.bank, i32* %normed.ref.epoch, i8* %normed.region, i8* %normed.stage, i8* %normed.layer, i8* %normed.batch, i8* %normed.row_space, i16* %normed.row0, i16* %normed.rows, i16* %normed.width, i8* %normed.content)
  %.0351 = load i16, i16* %ref.tmp5.0838, align 512
  %.1353 = load i32, i32* %ref.tmp5.1839, align 512
  %.2355 = load i64, i64* %ref.tmp5.2840, align 512
  store i16 %.0351, i16* %agg.result_code, align 512
  store i32 %.1353, i32* %agg.result_detail, align 512
  store i64 %.2355, i64* %agg.result_bad_element, align 512
  %9 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0351)
  br i1 %9, label %if.end9, label %cleanup362

if.end9:                                          ; preds = %if.end4
  call fastcc void @"laya::full::full_release_owner.12"(i16* %ref.tmp10.0832, i32* %ref.tmp10.1833, i64* %ref.tmp10.2834, [23 x i192]* %hidden)
  %.0345 = load i16, i16* %ref.tmp10.0832, align 512
  %.1347 = load i32, i32* %ref.tmp10.1833, align 512
  %.2349 = load i64, i64* %ref.tmp10.2834, align 512
  store i16 %.0345, i16* %agg.result_code, align 512
  store i32 %.1347, i32* %agg.result_detail, align 512
  store i64 %.2349, i64* %agg.result_bad_element, align 512
  %10 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0345)
  br i1 %10, label %if.end13, label %cleanup362

if.end13:                                         ; preds = %if.end9
  %.0.0321 = load i8, i8* %normed.ref.id, align 512
  %.0.1323 = load i8, i8* %normed.ref.bank, align 512
  %.0.2325 = load i32, i32* %normed.ref.epoch, align 512
  %.1327 = load i8, i8* %normed.region, align 512
  %.2329 = load i8, i8* %normed.stage, align 512
  %.3331 = load i8, i8* %normed.layer, align 512
  %.4333 = load i8, i8* %normed.batch, align 512
  %.5335 = load i8, i8* %normed.row_space, align 512
  %.6337 = load i16, i16* %normed.row0, align 512
  %.7339 = load i16, i16* %normed.rows, align 512
  %.8341 = load i16, i16* %normed.width, align 512
  %.9343 = load i8, i8* %normed.content, align 512
  %11 = zext i8 %.0.0321 to i192
  %12 = zext i8 %.0.1323 to i192
  %13 = shl nuw nsw i192 %12, 8
  %14 = zext i32 %.0.2325 to i192
  %15 = shl nuw nsw i192 %14, 32
  %16 = zext i8 %.1327 to i192
  %17 = shl nuw nsw i192 %16, 64
  %18 = zext i8 %.2329 to i192
  %19 = shl nuw nsw i192 %18, 72
  %20 = zext i8 %.3331 to i192
  %21 = shl nuw nsw i192 %20, 80
  %22 = zext i8 %.4333 to i192
  %23 = shl nuw nsw i192 %22, 88
  %24 = zext i8 %.5335 to i192
  %25 = shl nuw nsw i192 %24, 96
  %26 = zext i16 %.6337 to i192
  %27 = shl nuw nsw i192 %26, 112
  %28 = zext i16 %.7339 to i192
  %29 = shl nuw nsw i192 %28, 128
  %30 = zext i16 %.8341 to i192
  %31 = shl nuw nsw i192 %30, 144
  %32 = zext i8 %.9343 to i192
  %33 = shl nuw nsw i192 %32, 160
  %34 = or i192 %13, %11
  %35 = and i192 %15, 1095216660480
  %36 = or i192 %34, %35
  %37 = and i192 %15, 280375465082880
  %38 = or i192 %36, %37
  %39 = and i192 %15, 71776119061217280
  %40 = or i192 %38, %39
  %41 = and i192 %15, 18374686479671623680
  %42 = or i192 %40, %41
  %43 = or i192 %42, %17
  %44 = or i192 %43, %19
  %45 = or i192 %44, %21
  %46 = or i192 %45, %23
  %47 = or i192 %46, %25
  %48 = and i192 %27, 1324035698926381045275276563951124480
  %49 = or i192 %47, %48
  %50 = and i192 %27, 338953138925153547590470800371487866880
  %51 = or i192 %49, %50
  %52 = and i192 %29, 86772003564839308183160524895100893921280
  %53 = or i192 %51, %52
  %54 = and i192 %29, 22213632912598862894889094373145828843847680
  %55 = or i192 %53, %54
  %56 = and i192 %31, 5686690025625308901091608159525332184025006080
  %57 = or i192 %55, %56
  %58 = and i192 %31, 1455792646560079078679451688838485039110401556480
  %59 = or i192 %57, %58
  %60 = or i192 %59, %33
  call void @_ssdm_op_Write.bram.p0L_a6i32packedL(i192* %0, i192 %60, i24 2088947)
  %qkv.ref.id.cast = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 0
  %qkv.ref.bank.cast = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 0
  %qkv.content.cast822 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 0
  %qkv.ref.id.idx80 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 1
  %qkv.ref.bank.idx81 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 1
  %qkv.content.idx82 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 1
  %61 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 21
  %62 = getelementptr [23 x i192], [23 x i192]* %hidden, i64 0, i64 22
  br label %for.body

for.cond:                                         ; preds = %cleanup112
  br label %for.body, !llvm.loop !7224

for.body:                                         ; preds = %for.cond, %if.end13
  %layer.03 = phi i8 [ 0, %if.end13 ], [ %inc114, %for.cond ]
  %cmp3 = icmp ult i8 %layer.03, 28
  br i1 %cmp3, label %for.body.split, label %for.end, !llvm.loop !7224

for.body.split:                                   ; preds = %for.body
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 28, i64 14), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @177)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.content, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv.width, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv.rows, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv.row0, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.row_space, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.batch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.layer, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.stage, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.region, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qkv.ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv.ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void @_ssdm_op_Write.bram.p0L_a6i32packedL(i192* %61, i192 1461479336585704387580543296998010371294426562560, i24 -2100480)
  call void @_ssdm_op_Write.bram.p0L_a6i32packedL(i192* %62, i192 0, i24 31)
  %tobool = icmp ne i8 %layer.03, 0
  br i1 %tobool, label %if.then15, label %if.end21

if.then15:                                        ; preds = %for.body.split
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp17.0, i8* %agg.tmp17.1, i32* %agg.tmp17.2, i8 2, i8 0, i8 0)
  %63 = load i8, i8* %agg.tmp17.0, align 512
  %64 = load i8, i8* %agg.tmp17.1, align 512
  %65 = load i32, i32* %agg.tmp17.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm.13"(i16* %ref.tmp16.0826, i32* %ref.tmp16.1827, i64* %ref.tmp16.2828, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 17, [23 x i192]* %hidden, i8 %layer.03, i8 %63, i8 %64, i32 %65)
  %.0315 = load i16, i16* %ref.tmp16.0826, align 512
  %.1317 = load i32, i32* %ref.tmp16.1827, align 512
  %.2319 = load i64, i64* %ref.tmp16.2828, align 512
  store i16 %.0315, i16* %agg.result_code, align 512
  store i32 %.1317, i32* %agg.result_detail, align 512
  store i64 %.2319, i64* %agg.result_bad_element, align 512
  %66 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0315)
  br i1 %66, label %if.end21, label %cleanup112

if.end21:                                         ; preds = %if.then15, %for.body.split
  %att_source.0 = phi i64 [ 0, %for.body.split ], [ 512, %if.then15 ]
  br label %arrayctor.loop

arrayctor.loop:                                   ; preds = %arrayctor.loop, %if.end21
  %indvars.iv6 = phi i64 [ %indvars.iv.next7, %arrayctor.loop ], [ 0, %if.end21 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %indvars.iv.next7 = add nuw nsw i64 %indvars.iv6, 1
  %array.src.0.0 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.id, i64 0, i64 %indvars.iv6
  %array.src.0.1 = getelementptr [2 x i8], [2 x i8]* %qkv.ref.bank, i64 0, i64 %indvars.iv6
  %array.src.0.2 = getelementptr [2 x i32], [2 x i32]* %qkv.ref.epoch, i64 0, i64 %indvars.iv6
  %array.src.1 = getelementptr [2 x i8], [2 x i8]* %qkv.region, i64 0, i64 %indvars.iv6
  %array.src.2 = getelementptr [2 x i8], [2 x i8]* %qkv.stage, i64 0, i64 %indvars.iv6
  %array.src.3 = getelementptr [2 x i8], [2 x i8]* %qkv.layer, i64 0, i64 %indvars.iv6
  %array.src.4 = getelementptr [2 x i8], [2 x i8]* %qkv.batch, i64 0, i64 %indvars.iv6
  %array.src.5 = getelementptr [2 x i8], [2 x i8]* %qkv.row_space, i64 0, i64 %indvars.iv6
  %array.src.6 = getelementptr [2 x i16], [2 x i16]* %qkv.row0, i64 0, i64 %indvars.iv6
  %array.src.7 = getelementptr [2 x i16], [2 x i16]* %qkv.rows, i64 0, i64 %indvars.iv6
  %array.src.8 = getelementptr [2 x i16], [2 x i16]* %qkv.width, i64 0, i64 %indvars.iv6
  %array.src.9 = getelementptr [2 x i8], [2 x i8]* %qkv.content, i64 0, i64 %indvars.iv6
  store i8 0, i8* %array.src.0.0, align 4, !alias.scope !7352, !noalias !7357
  store i8 0, i8* %array.src.0.1, align 1, !alias.scope !7371, !noalias !7372
  store i32 0, i32* %array.src.0.2, align 4, !alias.scope !7373, !noalias !7374
  store i8 0, i8* %array.src.1, align 4, !alias.scope !7375, !noalias !7376
  store i8 0, i8* %array.src.2, align 1, !alias.scope !7377, !noalias !7378
  store i8 -1, i8* %array.src.3, align 2, !alias.scope !7379, !noalias !7380
  store i8 -1, i8* %array.src.4, align 1, !alias.scope !7381, !noalias !7382
  store i8 0, i8* %array.src.5, align 4, !alias.scope !7383, !noalias !7384
  store i16 0, i16* %array.src.6, align 2, !alias.scope !7385, !noalias !7386
  store i16 0, i16* %array.src.7, align 4, !alias.scope !7387, !noalias !7388
  store i16 0, i16* %array.src.8, align 2, !alias.scope !7389, !noalias !7390
  store i8 0, i8* %array.src.9, align 4, !alias.scope !7391, !noalias !7392
  %67 = icmp eq i64 %indvars.iv6, 1
  br i1 %67, label %if.end2122, label %arrayctor.loop, !llvm.loop !7393

if.end2122:                                       ; preds = %arrayctor.loop
  store i8 0, i8* %qkv_primary.ref.id, align 512, !alias.scope !7395, !noalias !7400
  store i8 0, i8* %qkv_primary.ref.bank, align 512, !alias.scope !7414, !noalias !7415
  store i32 0, i32* %qkv_primary.ref.epoch, align 512, !alias.scope !7416, !noalias !7417
  store i8 0, i8* %qkv_primary.region, align 512, !alias.scope !7418, !noalias !7419
  store i8 0, i8* %qkv_primary.stage, align 512, !alias.scope !7420, !noalias !7421
  store i8 -1, i8* %qkv_primary.layer, align 512, !alias.scope !7422, !noalias !7423
  store i8 -1, i8* %qkv_primary.batch, align 512, !alias.scope !7424, !noalias !7425
  store i8 0, i8* %qkv_primary.row_space, align 512, !alias.scope !7426, !noalias !7427
  store i16 0, i16* %qkv_primary.row0, align 512, !alias.scope !7428, !noalias !7429
  store i16 0, i16* %qkv_primary.rows, align 512, !alias.scope !7430, !noalias !7431
  store i16 0, i16* %qkv_primary.width, align 512, !alias.scope !7432, !noalias !7433
  store i8 0, i8* %qkv_primary.content, align 512, !alias.scope !7434, !noalias !7435
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp27.0, i8* %agg.tmp27.1, i32* %agg.tmp27.2, i8 5, i8 0, i8 0)
  %68 = load i8, i8* %agg.tmp27.0, align 512
  %69 = load i8, i8* %agg.tmp27.1, align 512
  %70 = load i32, i32* %agg.tmp27.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear"(i16* %ref.tmp24.0802, i32* %ref.tmp24.1803, i64* %ref.tmp24.2804, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %layer.03, [23 x i192]* %hidden, i64 %att_source.0, i8 %layer.03, i8 %68, i8 %69, i32 %70, i8* %qkv_primary.ref.id, i8* %qkv_primary.ref.bank, i32* %qkv_primary.ref.epoch, i8* %qkv_primary.region, i8* %qkv_primary.stage, i8* %qkv_primary.layer, i8* %qkv_primary.batch, i8* %qkv_primary.row_space, i16* %qkv_primary.row0, i16* %qkv_primary.rows, i16* %qkv_primary.width, i8* %qkv_primary.content)
  %.0309 = load i16, i16* %ref.tmp24.0802, align 512
  %.1311 = load i32, i32* %ref.tmp24.1803, align 512
  %.2313 = load i64, i64* %ref.tmp24.2804, align 512
  store i16 %.0309, i16* %agg.result_code, align 512
  store i32 %.1311, i32* %agg.result_detail, align 512
  store i64 %.2313, i64* %agg.result_bad_element, align 512
  %71 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0309)
  br i1 %71, label %if.end30, label %cleanup110

if.end30:                                         ; preds = %if.end2122
  br i1 %tobool, label %if.then32, label %if.end38

if.then32:                                        ; preds = %if.end30
  call fastcc void @"laya::full::full_release_owner.14"(i16* %ref.tmp33.0796, i32* %ref.tmp33.1797, i64* %ref.tmp33.2798, [23 x i192]* %hidden)
  %.0303 = load i16, i16* %ref.tmp33.0796, align 512
  %.1305 = load i32, i32* %ref.tmp33.1797, align 512
  %.2307 = load i64, i64* %ref.tmp33.2798, align 512
  store i16 %.0303, i16* %agg.result_code, align 512
  store i32 %.1305, i32* %agg.result_detail, align 512
  store i64 %.2307, i64* %agg.result_bad_element, align 512
  %72 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0303)
  br i1 %72, label %if.end38, label %cleanup110

if.end38:                                         ; preds = %if.then32, %if.end30
  store i8 0, i8* %attended.ref.id, align 512, !alias.scope !7436, !noalias !7441
  store i8 0, i8* %attended.ref.bank, align 512, !alias.scope !7455, !noalias !7456
  store i32 0, i32* %attended.ref.epoch, align 512, !alias.scope !7457, !noalias !7458
  store i8 0, i8* %attended.region, align 512, !alias.scope !7459, !noalias !7460
  store i8 0, i8* %attended.stage, align 512, !alias.scope !7461, !noalias !7462
  store i8 -1, i8* %attended.layer, align 512, !alias.scope !7463, !noalias !7464
  store i8 -1, i8* %attended.batch, align 512, !alias.scope !7465, !noalias !7466
  store i8 0, i8* %attended.row_space, align 512, !alias.scope !7467, !noalias !7468
  store i16 0, i16* %attended.row0, align 512, !alias.scope !7469, !noalias !7470
  store i16 0, i16* %attended.rows, align 512, !alias.scope !7471, !noalias !7472
  store i16 0, i16* %attended.width, align 512, !alias.scope !7473, !noalias !7474
  store i8 0, i8* %attended.content, align 512, !alias.scope !7475, !noalias !7476
  %qkv.ref.id.idx.val = load i8, i8* %qkv.ref.id.cast, align 512
  %qkv.ref.id.idx80.val = load i8, i8* %qkv.ref.id.idx80, align 1
  %qkv.ref.bank.idx.val = load i8, i8* %qkv.ref.bank.cast, align 512
  %qkv.ref.bank.idx81.val = load i8, i8* %qkv.ref.bank.idx81, align 1
  %qkv.content.idx.val = load i8, i8* %qkv.content.cast822, align 512
  %qkv.content.idx82.val = load i8, i8* %qkv.content.idx82, align 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::attention"(i16* %ref.tmp39.0785, i32* %ref.tmp39.1786, i64* %ref.tmp39.2787, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 2, i8 %layer.03, i8 %qkv.ref.id.idx.val, i8 %qkv.ref.id.idx80.val, i8 %qkv.ref.bank.idx.val, i8 %qkv.ref.bank.idx81.val, [2 x i32]* %qkv.ref.epoch, [2 x i8]* %qkv.region, [2 x i8]* %qkv.stage, [2 x i8]* %qkv.layer, [2 x i8]* %qkv.batch, [2 x i8]* %qkv.row_space, [2 x i16]* %qkv.row0, [2 x i16]* %qkv.rows, [2 x i16]* %qkv.width, i8 %qkv.content.idx.val, i8 %qkv.content.idx82.val, i8* %attended.ref.id, i8* %attended.ref.bank, i32* %attended.ref.epoch, i8* %attended.region, i8* %attended.stage, i8* %attended.layer, i8* %attended.batch, i8* %attended.row_space, i16* %attended.row0, i16* %attended.rows, i16* %attended.width, i8* %attended.content)
  %.0297 = load i16, i16* %ref.tmp39.0785, align 512
  %.1299 = load i32, i32* %ref.tmp39.1786, align 512
  %.2301 = load i64, i64* %ref.tmp39.2787, align 512
  store i16 %.0297, i16* %agg.result_code, align 512
  store i32 %.1299, i32* %agg.result_detail, align 512
  store i64 %.2301, i64* %agg.result_bad_element, align 512
  %73 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0297)
  br i1 %73, label %if.end42, label %cleanup109

if.end42:                                         ; preds = %if.end38
  store i8 0, i8* %projected.ref.id, align 512, !alias.scope !7477, !noalias !7482
  store i8 0, i8* %projected.ref.bank, align 512, !alias.scope !7496, !noalias !7497
  store i32 0, i32* %projected.ref.epoch, align 512, !alias.scope !7498, !noalias !7499
  store i8 0, i8* %projected.region, align 512, !alias.scope !7500, !noalias !7501
  store i8 0, i8* %projected.stage, align 512, !alias.scope !7502, !noalias !7503
  store i8 -1, i8* %projected.layer, align 512, !alias.scope !7504, !noalias !7505
  store i8 -1, i8* %projected.batch, align 512, !alias.scope !7506, !noalias !7507
  store i8 0, i8* %projected.row_space, align 512, !alias.scope !7508, !noalias !7509
  store i16 0, i16* %projected.row0, align 512, !alias.scope !7510, !noalias !7511
  store i16 0, i16* %projected.rows, align 512, !alias.scope !7512, !noalias !7513
  store i16 0, i16* %projected.width, align 512, !alias.scope !7514, !noalias !7515
  store i8 0, i8* %projected.content, align 512, !alias.scope !7516, !noalias !7517
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp47.0, i8* %agg.tmp47.1, i32* %agg.tmp47.2, i8 3, i8 0, i8 0)
  %74 = load i8, i8* %agg.tmp47.0, align 512
  %75 = load i8, i8* %agg.tmp47.1, align 512
  %76 = load i32, i32* %agg.tmp47.2, align 512
  %attended.ref.id.val146 = load i8, i8* %attended.ref.id, align 512
  %attended.ref.bank.val147 = load i8, i8* %attended.ref.bank, align 512
  %attended.ref.epoch.val148 = load i32, i32* %attended.ref.epoch, align 512
  %attended.region.val149 = load i8, i8* %attended.region, align 512
  %attended.stage.val150 = load i8, i8* %attended.stage, align 512, !alias.scope !7518, !noalias !7521
  %attended.layer.val151 = load i8, i8* %attended.layer, align 512
  %attended.batch.val152 = load i8, i8* %attended.batch, align 512, !alias.scope !7537, !noalias !7538
  %attended.row_space.val153 = load i8, i8* %attended.row_space, align 512
  %attended.row0.val154 = load i16, i16* %attended.row0, align 512, !alias.scope !7539, !noalias !7540
  %attended.rows.val155 = load i16, i16* %attended.rows, align 512
  %attended.width.val156 = load i16, i16* %attended.width, align 512, !alias.scope !7541, !noalias !7542
  %attended.content.val157 = load i8, i8* %attended.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp43.0774, i32* %ref.tmp43.1775, i64* %ref.tmp43.2776, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 49, i8 2, i8 %layer.03, i8 %attended.ref.id.val146, i8 %attended.ref.bank.val147, i32 %attended.ref.epoch.val148, i8 %attended.region.val149, i8 %attended.stage.val150, i8 %attended.layer.val151, i8 %attended.batch.val152, i8 %attended.row_space.val153, i16 %attended.row0.val154, i16 %attended.rows.val155, i16 %attended.width.val156, i8 %attended.content.val157, i8 2, i8 %layer.03, i8 %74, i8 %75, i32 %76, i8 0, i8* %projected.ref.id, i8* %projected.ref.bank, i32* %projected.ref.epoch, i8* %projected.region, i8* %projected.stage, i8* %projected.layer, i8* %projected.batch, i8* %projected.row_space, i16* %projected.row0, i16* %projected.rows, i16* %projected.width, i8* %projected.content)
  %.0291 = load i16, i16* %ref.tmp43.0774, align 512
  %.1293 = load i32, i32* %ref.tmp43.1775, align 512
  %.2295 = load i64, i64* %ref.tmp43.2776, align 512
  store i16 %.0291, i16* %agg.result_code, align 512
  store i32 %.1293, i32* %agg.result_detail, align 512
  store i64 %.2295, i64* %agg.result_bad_element, align 512
  %77 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0291)
  br i1 %77, label %if.end50, label %cleanup108

if.end50:                                         ; preds = %if.end42
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp51.0768, i32* %ref.tmp51.1769, i64* %ref.tmp51.2770, i8 %attended.ref.id.val146, i8 %attended.ref.bank.val147, i32 %attended.ref.epoch.val148, i8 %attended.region.val149, i8 %attended.stage.val150, i8 %attended.layer.val151, i8 %attended.batch.val152, i8 %attended.row_space.val153, i16 %attended.row0.val154, i16 %attended.rows.val155, i16 %attended.width.val156, i8 %attended.content.val157)
  %.0285 = load i16, i16* %ref.tmp51.0768, align 512
  %.1287 = load i32, i32* %ref.tmp51.1769, align 512
  %.2289 = load i64, i64* %ref.tmp51.2770, align 512
  store i16 %.0285, i16* %agg.result_code, align 512
  store i32 %.1287, i32* %agg.result_detail, align 512
  store i64 %.2289, i64* %agg.result_bad_element, align 512
  %78 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0285)
  br i1 %78, label %if.end55, label %cleanup108

if.end55:                                         ; preds = %if.end50
  %projected.ref.id.val = load i8, i8* %projected.ref.id, align 512
  %projected.ref.bank.val = load i8, i8* %projected.ref.bank, align 512
  %projected.ref.epoch.val = load i32, i32* %projected.ref.epoch, align 512, !alias.scope !7543, !noalias !7546
  %projected.region.val = load i8, i8* %projected.region, align 512
  %projected.stage.val = load i8, i8* %projected.stage, align 512, !alias.scope !7559, !noalias !7560
  %projected.layer.val = load i8, i8* %projected.layer, align 512, !alias.scope !7561, !noalias !7562
  %projected.batch.val = load i8, i8* %projected.batch, align 512, !alias.scope !7563, !noalias !7564
  %projected.row_space.val = load i8, i8* %projected.row_space, align 512, !alias.scope !7565, !noalias !7566
  %projected.row0.val = load i16, i16* %projected.row0, align 512, !alias.scope !7567, !noalias !7568
  %projected.rows.val = load i16, i16* %projected.rows, align 512, !alias.scope !7569, !noalias !7570
  %projected.width.val = load i16, i16* %projected.width, align 512, !alias.scope !7571, !noalias !7572
  %projected.content.val = load i8, i8* %projected.content, align 512, !alias.scope !7573, !noalias !7574
  call fastcc void @"laya::full::(anonymous namespace)::Controller::residual"(i16* %ref.tmp56.0762, i32* %ref.tmp56.1763, i64* %ref.tmp56.2764, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 2, i8 %layer.03, i8 %projected.ref.id.val, i8 %projected.ref.bank.val, i32 %projected.ref.epoch.val, i8 %projected.region.val, i8 %projected.stage.val, i8 %projected.layer.val, i8 %projected.batch.val, i8 %projected.row_space.val, i16 %projected.row0.val, i16 %projected.rows.val, i16 %projected.width.val, i8 %projected.content.val, [23 x i192]* %hidden)
  %.0279 = load i16, i16* %ref.tmp56.0762, align 512
  %.1281 = load i32, i32* %ref.tmp56.1763, align 512
  %.2283 = load i64, i64* %ref.tmp56.2764, align 512
  store i16 %.0279, i16* %agg.result_code, align 512
  store i32 %.1281, i32* %agg.result_detail, align 512
  store i64 %.2283, i64* %agg.result_bad_element, align 512
  %79 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0279)
  br i1 %79, label %if.end59, label %cleanup108

if.end59:                                         ; preds = %if.end55
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp61.0, i8* %agg.tmp61.1, i32* %agg.tmp61.2, i8 2, i8 0, i8 0)
  %80 = load i8, i8* %agg.tmp61.0, align 512
  %81 = load i8, i8* %agg.tmp61.1, align 512
  %82 = load i32, i32* %agg.tmp61.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm.13"(i16* %ref.tmp60.0756, i32* %ref.tmp60.1757, i64* %ref.tmp60.2758, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 18, [23 x i192]* %hidden, i8 %layer.03, i8 %80, i8 %81, i32 %82)
  %.0273 = load i16, i16* %ref.tmp60.0756, align 512
  %.1275 = load i32, i32* %ref.tmp60.1757, align 512
  %.2277 = load i64, i64* %ref.tmp60.2758, align 512
  store i16 %.0273, i16* %agg.result_code, align 512
  store i32 %.1275, i32* %agg.result_detail, align 512
  store i64 %.2277, i64* %agg.result_bad_element, align 512
  %83 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0273)
  br i1 %83, label %if.end64, label %cleanup108

if.end64:                                         ; preds = %if.end59
  store i8 0, i8* %wide.ref.id, align 512, !alias.scope !7575, !noalias !7580
  store i8 0, i8* %wide.ref.bank, align 512, !alias.scope !7594, !noalias !7595
  store i32 0, i32* %wide.ref.epoch, align 512, !alias.scope !7596, !noalias !7597
  store i8 0, i8* %wide.region, align 512, !alias.scope !7598, !noalias !7599
  store i8 0, i8* %wide.stage, align 512, !alias.scope !7600, !noalias !7601
  store i8 -1, i8* %wide.layer, align 512, !alias.scope !7602, !noalias !7603
  store i8 -1, i8* %wide.batch, align 512, !alias.scope !7604, !noalias !7605
  store i8 0, i8* %wide.row_space, align 512, !alias.scope !7606, !noalias !7607
  store i16 0, i16* %wide.row0, align 512, !alias.scope !7608, !noalias !7609
  store i16 0, i16* %wide.rows, align 512, !alias.scope !7610, !noalias !7611
  store i16 0, i16* %wide.width, align 512, !alias.scope !7612, !noalias !7613
  store i8 0, i8* %wide.content, align 512, !alias.scope !7614, !noalias !7615
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp69.0, i8* %agg.tmp69.1, i32* %agg.tmp69.2, i8 6, i8 0, i8 0)
  %84 = load i8, i8* %agg.tmp69.0, align 512
  %85 = load i8, i8* %agg.tmp69.1, align 512
  %86 = load i32, i32* %agg.tmp69.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.16"(i16* %ref.tmp65.0745, i32* %ref.tmp65.1746, i64* %ref.tmp65.2747, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %layer.03, [23 x i192]* %hidden, i8 %layer.03, i8 %84, i8 %85, i32 %86, i8* %wide.ref.id, i8* %wide.ref.bank, i32* %wide.ref.epoch, i8* %wide.region, i8* %wide.stage, i8* %wide.layer, i8* %wide.batch, i8* %wide.row_space, i16* %wide.row0, i16* %wide.rows, i16* %wide.width, i8* %wide.content)
  %.0267 = load i16, i16* %ref.tmp65.0745, align 512
  %.1269 = load i32, i32* %ref.tmp65.1746, align 512
  %.2271 = load i64, i64* %ref.tmp65.2747, align 512
  store i16 %.0267, i16* %agg.result_code, align 512
  store i32 %.1269, i32* %agg.result_detail, align 512
  store i64 %.2271, i64* %agg.result_bad_element, align 512
  %87 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0267)
  br i1 %87, label %if.end72, label %cleanup107

if.end72:                                         ; preds = %if.end64
  call fastcc void @"laya::full::full_release_owner.14"(i16* %ref.tmp73.0739, i32* %ref.tmp73.1740, i64* %ref.tmp73.2741, [23 x i192]* %hidden)
  %.0261 = load i16, i16* %ref.tmp73.0739, align 512
  %.1263 = load i32, i32* %ref.tmp73.1740, align 512
  %.2265 = load i64, i64* %ref.tmp73.2741, align 512
  store i16 %.0261, i16* %agg.result_code, align 512
  store i32 %.1263, i32* %agg.result_detail, align 512
  store i64 %.2265, i64* %agg.result_bad_element, align 512
  %88 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0261)
  br i1 %88, label %if.end77, label %cleanup107

if.end77:                                         ; preds = %if.end72
  store i8 0, i8* %gated.ref.id, align 512, !alias.scope !7616, !noalias !7621
  store i8 0, i8* %gated.ref.bank, align 512, !alias.scope !7635, !noalias !7636
  store i32 0, i32* %gated.ref.epoch, align 512, !alias.scope !7637, !noalias !7638
  store i8 0, i8* %gated.region, align 512, !alias.scope !7639, !noalias !7640
  store i8 0, i8* %gated.stage, align 512, !alias.scope !7641, !noalias !7642
  store i8 -1, i8* %gated.layer, align 512, !alias.scope !7643, !noalias !7644
  store i8 -1, i8* %gated.batch, align 512, !alias.scope !7645, !noalias !7646
  store i8 0, i8* %gated.row_space, align 512, !alias.scope !7647, !noalias !7648
  store i16 0, i16* %gated.row0, align 512, !alias.scope !7649, !noalias !7650
  store i16 0, i16* %gated.rows, align 512, !alias.scope !7651, !noalias !7652
  store i16 0, i16* %gated.width, align 512, !alias.scope !7653, !noalias !7654
  store i8 0, i8* %gated.content, align 512, !alias.scope !7655, !noalias !7656
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp79.0, i8* %agg.tmp79.1, i32* %agg.tmp79.2, i8 7, i8 0, i8 0)
  %89 = load i8, i8* %agg.tmp79.0, align 512
  %90 = load i8, i8* %agg.tmp79.1, align 512
  %91 = load i32, i32* %agg.tmp79.2, align 512
  %wide.ref.id.val158 = load i8, i8* %wide.ref.id, align 512
  %wide.ref.bank.val159 = load i8, i8* %wide.ref.bank, align 512
  %wide.ref.epoch.val160 = load i32, i32* %wide.ref.epoch, align 512
  %wide.region.val161 = load i8, i8* %wide.region, align 512
  %wide.stage.val162 = load i8, i8* %wide.stage, align 512, !alias.scope !7657, !noalias !7662
  %wide.layer.val163 = load i8, i8* %wide.layer, align 512
  %wide.batch.val164 = load i8, i8* %wide.batch, align 512, !alias.scope !7693, !noalias !7694
  %wide.row_space.val165 = load i8, i8* %wide.row_space, align 512
  %wide.row0.val166 = load i16, i16* %wide.row0, align 512, !alias.scope !7695, !noalias !7696
  %wide.rows.val167 = load i16, i16* %wide.rows, align 512, !alias.scope !7697, !noalias !7698
  %wide.width.val168 = load i16, i16* %wide.width, align 512, !alias.scope !7699, !noalias !7700
  %wide.content.val169 = load i8, i8* %wide.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::vector"(i16* %ref.tmp78.0728, i32* %ref.tmp78.1729, i64* %ref.tmp78.2730, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 96, i8 %wide.ref.id.val158, i8 %wide.ref.bank.val159, i32 %wide.ref.epoch.val160, i8 %wide.region.val161, i8 %wide.stage.val162, i8 %wide.layer.val163, i8 %wide.batch.val164, i8 %wide.row_space.val165, i16 %wide.row0.val166, i16 %wide.rows.val167, i16 %wide.width.val168, i8 %wide.content.val169, i8 2, i8 %layer.03, i8 %89, i8 %90, i32 %91, i8 0, i16 2624, i8* %gated.ref.id, i8* %gated.ref.bank, i32* %gated.ref.epoch, i8* %gated.region, i8* %gated.stage, i8* %gated.layer, i8* %gated.batch, i8* %gated.row_space, i16* %gated.row0, i16* %gated.rows, i16* %gated.width, i8* %gated.content)
  %.0255 = load i16, i16* %ref.tmp78.0728, align 512
  %.1257 = load i32, i32* %ref.tmp78.1729, align 512
  %.2259 = load i64, i64* %ref.tmp78.2730, align 512
  store i16 %.0255, i16* %agg.result_code, align 512
  store i32 %.1257, i32* %agg.result_detail, align 512
  store i64 %.2259, i64* %agg.result_bad_element, align 512
  %92 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0255)
  br i1 %92, label %if.end82, label %cleanup106

if.end82:                                         ; preds = %if.end77
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp83.0722, i32* %ref.tmp83.1723, i64* %ref.tmp83.2724, i8 %wide.ref.id.val158, i8 %wide.ref.bank.val159, i32 %wide.ref.epoch.val160, i8 %wide.region.val161, i8 %wide.stage.val162, i8 %wide.layer.val163, i8 %wide.batch.val164, i8 %wide.row_space.val165, i16 %wide.row0.val166, i16 %wide.rows.val167, i16 %wide.width.val168, i8 %wide.content.val169)
  %.0249 = load i16, i16* %ref.tmp83.0722, align 512
  %.1251 = load i32, i32* %ref.tmp83.1723, align 512
  %.2253 = load i64, i64* %ref.tmp83.2724, align 512
  store i16 %.0249, i16* %agg.result_code, align 512
  store i32 %.1251, i32* %agg.result_detail, align 512
  store i64 %.2253, i64* %agg.result_bad_element, align 512
  %93 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0249)
  br i1 %93, label %if.end87, label %cleanup106

if.end87:                                         ; preds = %if.end82
  store i8 0, i8* %down.ref.id, align 512, !alias.scope !7701, !noalias !7706
  store i8 0, i8* %down.ref.bank, align 512, !alias.scope !7720, !noalias !7721
  store i32 0, i32* %down.ref.epoch, align 512, !alias.scope !7722, !noalias !7723
  store i8 0, i8* %down.region, align 512, !alias.scope !7724, !noalias !7725
  store i8 0, i8* %down.stage, align 512, !alias.scope !7726, !noalias !7727
  store i8 -1, i8* %down.layer, align 512, !alias.scope !7728, !noalias !7729
  store i8 -1, i8* %down.batch, align 512, !alias.scope !7730, !noalias !7731
  store i8 0, i8* %down.row_space, align 512, !alias.scope !7732, !noalias !7733
  store i16 0, i16* %down.row0, align 512, !alias.scope !7734, !noalias !7735
  store i16 0, i16* %down.rows, align 512, !alias.scope !7736, !noalias !7737
  store i16 0, i16* %down.width, align 512, !alias.scope !7738, !noalias !7739
  store i8 0, i8* %down.content, align 512, !alias.scope !7740, !noalias !7741
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp92.0, i8* %agg.tmp92.1, i32* %agg.tmp92.2, i8 3, i8 0, i8 0)
  %94 = load i8, i8* %agg.tmp92.0, align 512
  %95 = load i8, i8* %agg.tmp92.1, align 512
  %96 = load i32, i32* %agg.tmp92.2, align 512
  %gated.ref.id.val134 = load i8, i8* %gated.ref.id, align 512
  %gated.ref.bank.val135 = load i8, i8* %gated.ref.bank, align 512
  %gated.ref.epoch.val136 = load i32, i32* %gated.ref.epoch, align 512
  %gated.region.val137 = load i8, i8* %gated.region, align 512
  %gated.stage.val138 = load i8, i8* %gated.stage, align 512, !alias.scope !7518, !noalias !7521
  %gated.layer.val139 = load i8, i8* %gated.layer, align 512
  %gated.batch.val140 = load i8, i8* %gated.batch, align 512, !alias.scope !7537, !noalias !7538
  %gated.row_space.val141 = load i8, i8* %gated.row_space, align 512
  %gated.row0.val142 = load i16, i16* %gated.row0, align 512, !alias.scope !7539, !noalias !7540
  %gated.rows.val143 = load i16, i16* %gated.rows, align 512
  %gated.width.val144 = load i16, i16* %gated.width, align 512, !alias.scope !7541, !noalias !7542
  %gated.content.val145 = load i8, i8* %gated.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp88.0711, i32* %ref.tmp88.1712, i64* %ref.tmp88.2713, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 51, i8 4, i8 %layer.03, i8 %gated.ref.id.val134, i8 %gated.ref.bank.val135, i32 %gated.ref.epoch.val136, i8 %gated.region.val137, i8 %gated.stage.val138, i8 %gated.layer.val139, i8 %gated.batch.val140, i8 %gated.row_space.val141, i16 %gated.row0.val142, i16 %gated.rows.val143, i16 %gated.width.val144, i8 %gated.content.val145, i8 2, i8 %layer.03, i8 %94, i8 %95, i32 %96, i8 0, i8* %down.ref.id, i8* %down.ref.bank, i32* %down.ref.epoch, i8* %down.region, i8* %down.stage, i8* %down.layer, i8* %down.batch, i8* %down.row_space, i16* %down.row0, i16* %down.rows, i16* %down.width, i8* %down.content)
  %.0243 = load i16, i16* %ref.tmp88.0711, align 512
  %.1245 = load i32, i32* %ref.tmp88.1712, align 512
  %.2247 = load i64, i64* %ref.tmp88.2713, align 512
  store i16 %.0243, i16* %agg.result_code, align 512
  store i32 %.1245, i32* %agg.result_detail, align 512
  store i64 %.2247, i64* %agg.result_bad_element, align 512
  %97 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0243)
  br i1 %97, label %if.end95, label %cleanup

if.end95:                                         ; preds = %if.end87
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp96.0705, i32* %ref.tmp96.1706, i64* %ref.tmp96.2707, i8 %gated.ref.id.val134, i8 %gated.ref.bank.val135, i32 %gated.ref.epoch.val136, i8 %gated.region.val137, i8 %gated.stage.val138, i8 %gated.layer.val139, i8 %gated.batch.val140, i8 %gated.row_space.val141, i16 %gated.row0.val142, i16 %gated.rows.val143, i16 %gated.width.val144, i8 %gated.content.val145)
  %.0237 = load i16, i16* %ref.tmp96.0705, align 512
  %.1239 = load i32, i32* %ref.tmp96.1706, align 512
  %.2241 = load i64, i64* %ref.tmp96.2707, align 512
  store i16 %.0237, i16* %agg.result_code, align 512
  store i32 %.1239, i32* %agg.result_detail, align 512
  store i64 %.2241, i64* %agg.result_bad_element, align 512
  %98 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0237)
  br i1 %98, label %if.end100, label %cleanup

if.end100:                                        ; preds = %if.end95
  %down.ref.id.val = load i8, i8* %down.ref.id, align 512
  %down.ref.bank.val = load i8, i8* %down.ref.bank, align 512
  %down.ref.epoch.val = load i32, i32* %down.ref.epoch, align 512, !alias.scope !7543, !noalias !7546
  %down.region.val = load i8, i8* %down.region, align 512
  %down.stage.val = load i8, i8* %down.stage, align 512, !alias.scope !7559, !noalias !7560
  %down.layer.val = load i8, i8* %down.layer, align 512, !alias.scope !7561, !noalias !7562
  %down.batch.val = load i8, i8* %down.batch, align 512, !alias.scope !7563, !noalias !7564
  %down.row_space.val = load i8, i8* %down.row_space, align 512, !alias.scope !7565, !noalias !7566
  %down.row0.val = load i16, i16* %down.row0, align 512, !alias.scope !7567, !noalias !7568
  %down.rows.val = load i16, i16* %down.rows, align 512, !alias.scope !7569, !noalias !7570
  %down.width.val = load i16, i16* %down.width, align 512, !alias.scope !7571, !noalias !7572
  %down.content.val = load i8, i8* %down.content, align 512, !alias.scope !7573, !noalias !7574
  call fastcc void @"laya::full::(anonymous namespace)::Controller::residual"(i16* %ref.tmp101.0699, i32* %ref.tmp101.1700, i64* %ref.tmp101.2701, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 2, i8 %layer.03, i8 %down.ref.id.val, i8 %down.ref.bank.val, i32 %down.ref.epoch.val, i8 %down.region.val, i8 %down.stage.val, i8 %down.layer.val, i8 %down.batch.val, i8 %down.row_space.val, i16 %down.row0.val, i16 %down.rows.val, i16 %down.width.val, i8 %down.content.val, [23 x i192]* %hidden)
  %.0231 = load i16, i16* %ref.tmp101.0699, align 512
  %.1233 = load i32, i32* %ref.tmp101.1700, align 512
  %.2235 = load i64, i64* %ref.tmp101.2701, align 512
  store i16 %.0231, i16* %agg.result_code, align 512
  store i32 %.1233, i32* %agg.result_detail, align 512
  store i64 %.2235, i64* %agg.result_bad_element, align 512
  %99 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0231)
  br i1 %99, label %if.end104, label %cleanup

if.end104:                                        ; preds = %if.end100
  %100 = load i8, i8* @"(anonymous namespace)::runtime.encoder_layers_completed", align 512
  %inc = add i8 %100, 1
  store i8 %inc, i8* @"(anonymous namespace)::runtime.encoder_layers_completed", align 512
  br label %cleanup

cleanup:                                          ; preds = %if.end104, %if.end100, %if.end95, %if.end87
  %cleanup.dest.slot.0 = phi i32 [ 0, %if.end104 ], [ 1, %if.end87 ], [ 1, %if.end95 ], [ 1, %if.end100 ]
  br label %cleanup106

cleanup106:                                       ; preds = %cleanup, %if.end82, %if.end77
  %cleanup.dest.slot.1 = phi i32 [ %cleanup.dest.slot.0, %cleanup ], [ 1, %if.end77 ], [ 1, %if.end82 ]
  br label %cleanup107

cleanup107:                                       ; preds = %cleanup106, %if.end72, %if.end64
  %cleanup.dest.slot.2 = phi i32 [ %cleanup.dest.slot.1, %cleanup106 ], [ 1, %if.end64 ], [ 1, %if.end72 ]
  br label %cleanup108

cleanup108:                                       ; preds = %cleanup107, %if.end59, %if.end55, %if.end50, %if.end42
  %cleanup.dest.slot.3 = phi i32 [ %cleanup.dest.slot.2, %cleanup107 ], [ 1, %if.end42 ], [ 1, %if.end50 ], [ 1, %if.end55 ], [ 1, %if.end59 ]
  br label %cleanup109

cleanup109:                                       ; preds = %cleanup108, %if.end38
  %cleanup.dest.slot.4 = phi i32 [ %cleanup.dest.slot.3, %cleanup108 ], [ 1, %if.end38 ]
  br label %cleanup110

cleanup110:                                       ; preds = %cleanup109, %if.then32, %if.end2122
  %cleanup.dest.slot.5 = phi i32 [ %cleanup.dest.slot.4, %cleanup109 ], [ 1, %if.end2122 ], [ 1, %if.then32 ]
  br label %cleanup112

cleanup112:                                       ; preds = %cleanup110, %if.then15
  %cleanup.dest.slot.6 = phi i32 [ %cleanup.dest.slot.5, %cleanup110 ], [ 1, %if.then15 ]
  %cond6 = icmp eq i32 %cleanup.dest.slot.6, 0
  %inc114 = add nuw nsw i8 %layer.03, 1
  br i1 %cond6, label %for.cond, label %cleanup362.loopexit

for.end:                                          ; preds = %for.body
  call fastcc void @"laya::full::(anonymous namespace)::Controller::load_gamma"(i16* %ref.tmp117.0693, i32* %ref.tmp117.1694, i64* %ref.tmp117.2695, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 2)
  %.0225 = load i16, i16* %ref.tmp117.0693, align 512
  %.1227 = load i32, i32* %ref.tmp117.1694, align 512
  %.2229 = load i64, i64* %ref.tmp117.2695, align 512
  store i16 %.0225, i16* %agg.result_code, align 512
  store i32 %.1227, i32* %agg.result_detail, align 512
  store i64 %.2229, i64* %agg.result_bad_element, align 512
  %101 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0225)
  br i1 %101, label %if.end120, label %cleanup362

if.end120:                                        ; preds = %for.end
  store i8 0, i8* %final_norm.ref.id, align 512, !alias.scope !7742, !noalias !7747
  store i8 0, i8* %final_norm.ref.bank, align 512, !alias.scope !7761, !noalias !7762
  store i32 0, i32* %final_norm.ref.epoch, align 512, !alias.scope !7763, !noalias !7764
  store i8 0, i8* %final_norm.region, align 512, !alias.scope !7765, !noalias !7766
  store i8 0, i8* %final_norm.stage, align 512, !alias.scope !7767, !noalias !7768
  store i8 -1, i8* %final_norm.layer, align 512, !alias.scope !7769, !noalias !7770
  store i8 -1, i8* %final_norm.batch, align 512, !alias.scope !7771, !noalias !7772
  store i8 0, i8* %final_norm.row_space, align 512, !alias.scope !7773, !noalias !7774
  store i16 0, i16* %final_norm.row0, align 512, !alias.scope !7775, !noalias !7776
  store i16 0, i16* %final_norm.rows, align 512, !alias.scope !7777, !noalias !7778
  store i16 0, i16* %final_norm.width, align 512, !alias.scope !7779, !noalias !7780
  store i8 0, i8* %final_norm.content, align 512, !alias.scope !7781, !noalias !7782
  %102 = load i192, i192* %0
  %103 = lshr i192 %102, 8
  %104 = trunc i192 %103 to i8
  %sub126 = sub i8 1, %104
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp122.0, i8* %agg.tmp122.1, i32* %agg.tmp122.2, i8 1, i8 %sub126, i8 0)
  %105 = load i8, i8* %agg.tmp122.0, align 512
  %106 = load i8, i8* %agg.tmp122.1, align 512
  %107 = load i32, i32* %agg.tmp122.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm"(i16* %ref.tmp121.0682, i32* %ref.tmp121.1683, i64* %ref.tmp121.2684, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 19, [23 x i192]* %hidden, i8 3, i8 -1, i8 %105, i8 %106, i32 %107, i8 2, i8* %final_norm.ref.id, i8* %final_norm.ref.bank, i32* %final_norm.ref.epoch, i8* %final_norm.region, i8* %final_norm.stage, i8* %final_norm.layer, i8* %final_norm.batch, i8* %final_norm.row_space, i16* %final_norm.row0, i16* %final_norm.rows, i16* %final_norm.width, i8* %final_norm.content)
  %.0219 = load i16, i16* %ref.tmp121.0682, align 512
  %.1221 = load i32, i32* %ref.tmp121.1683, align 512
  %.2223 = load i64, i64* %ref.tmp121.2684, align 512
  store i16 %.0219, i16* %agg.result_code, align 512
  store i32 %.1221, i32* %agg.result_detail, align 512
  store i64 %.2223, i64* %agg.result_bad_element, align 512
  %108 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0219)
  br i1 %108, label %if.end130, label %cleanup361

if.end130:                                        ; preds = %if.end120
  call fastcc void @"laya::full::full_release_owner.12"(i16* %ref.tmp131.0676, i32* %ref.tmp131.1677, i64* %ref.tmp131.2678, [23 x i192]* %hidden)
  %.0213 = load i16, i16* %ref.tmp131.0676, align 512
  %.1215 = load i32, i32* %ref.tmp131.1677, align 512
  %.2217 = load i64, i64* %ref.tmp131.2678, align 512
  store i16 %.0213, i16* %agg.result_code, align 512
  store i32 %.1215, i32* %agg.result_detail, align 512
  store i64 %.2217, i64* %agg.result_bad_element, align 512
  %109 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0213)
  br i1 %109, label %if.end135, label %cleanup361

if.end135:                                        ; preds = %if.end130
  %.0.0201 = load i8, i8* %final_norm.ref.id, align 512
  %.0.1202 = load i8, i8* %final_norm.ref.bank, align 512
  %.0.2203 = load i32, i32* %final_norm.ref.epoch, align 512
  %.1204 = load i8, i8* %final_norm.region, align 512
  %.2205 = load i8, i8* %final_norm.stage, align 512
  %.3206 = load i8, i8* %final_norm.layer, align 512
  %.4207 = load i8, i8* %final_norm.batch, align 512
  %.5208 = load i8, i8* %final_norm.row_space, align 512
  %.6209 = load i16, i16* %final_norm.row0, align 512
  %.7210 = load i16, i16* %final_norm.rows, align 512
  %.8211 = load i16, i16* %final_norm.width, align 512
  %.9212 = load i8, i8* %final_norm.content, align 512
  %110 = zext i8 %.0.0201 to i192
  %111 = zext i8 %.0.1202 to i192
  %112 = shl nuw nsw i192 %111, 8
  %113 = zext i32 %.0.2203 to i192
  %114 = shl nuw nsw i192 %113, 32
  %115 = zext i8 %.1204 to i192
  %116 = shl nuw nsw i192 %115, 64
  %117 = zext i8 %.2205 to i192
  %118 = shl nuw nsw i192 %117, 72
  %119 = zext i8 %.3206 to i192
  %120 = shl nuw nsw i192 %119, 80
  %121 = zext i8 %.4207 to i192
  %122 = shl nuw nsw i192 %121, 88
  %123 = zext i8 %.5208 to i192
  %124 = shl nuw nsw i192 %123, 96
  %125 = zext i16 %.6209 to i192
  %126 = shl nuw nsw i192 %125, 112
  %127 = zext i16 %.7210 to i192
  %128 = shl nuw nsw i192 %127, 128
  %129 = zext i16 %.8211 to i192
  %130 = shl nuw nsw i192 %129, 144
  %131 = zext i8 %.9212 to i192
  %132 = shl nuw nsw i192 %131, 160
  %133 = or i192 %112, %110
  %134 = and i192 %114, 1095216660480
  %135 = or i192 %133, %134
  %136 = and i192 %114, 280375465082880
  %137 = or i192 %135, %136
  %138 = and i192 %114, 71776119061217280
  %139 = or i192 %137, %138
  %140 = and i192 %114, 18374686479671623680
  %141 = or i192 %139, %140
  %142 = or i192 %141, %116
  %143 = or i192 %142, %118
  %144 = or i192 %143, %120
  %145 = or i192 %144, %122
  %146 = or i192 %145, %124
  %147 = and i192 %126, 1324035698926381045275276563951124480
  %148 = or i192 %146, %147
  %149 = and i192 %126, 338953138925153547590470800371487866880
  %150 = or i192 %148, %149
  %151 = and i192 %128, 86772003564839308183160524895100893921280
  %152 = or i192 %150, %151
  %153 = and i192 %128, 22213632912598862894889094373145828843847680
  %154 = or i192 %152, %153
  %155 = and i192 %130, 5686690025625308901091608159525332184025006080
  %156 = or i192 %154, %155
  %157 = and i192 %130, 1455792646560079078679451688838485039110401556480
  %158 = or i192 %156, %157
  %159 = or i192 %158, %132
  call void @_ssdm_op_Write.bram.p0L_a6i32packedL(i192* %0, i192 %159, i24 2088947)
  call fastcc void @"laya::full::(anonymous namespace)::Controller::type_add"(i16* %ref.tmp136.0670, i32* %ref.tmp136.1671, i64* %ref.tmp136.2672, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, [23 x i192]* %hidden)
  %.0195 = load i16, i16* %ref.tmp136.0670, align 512
  %.1197 = load i32, i32* %ref.tmp136.1671, align 512
  %.2199 = load i64, i64* %ref.tmp136.2672, align 512
  store i16 %.0195, i16* %agg.result_code, align 512
  store i32 %.1197, i32* %agg.result_detail, align 512
  store i64 %.2199, i64* %agg.result_bad_element, align 512
  %160 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0195)
  br i1 %160, label %VITIS_LOOP_636_2, label %cleanup361

VITIS_LOOP_636_2:                                 ; preds = %if.end135
  %qkv152.ref.id.cast = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.id, i64 0, i64 0
  %qkv152.ref.bank.cast = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.bank, i64 0, i64 0
  %qkv152.content.cast655 = getelementptr [2 x i8], [2 x i8]* %qkv152.content, i64 0, i64 0
  %qkv152.ref.id.idx83 = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.id, i64 0, i64 1
  %qkv152.ref.bank.idx84 = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.bank, i64 0, i64 1
  %qkv152.content.idx85 = getelementptr [2 x i8], [2 x i8]* %qkv152.content, i64 0, i64 1
  br label %for.body145

for.cond141:                                      ; preds = %cleanup246
  br label %for.body145, !llvm.loop !7783

for.body145:                                      ; preds = %for.cond141, %VITIS_LOOP_636_2
  %layer140.01 = phi i8 [ 0, %VITIS_LOOP_636_2 ], [ %inc250, %for.cond141 ]
  %cmp1434 = icmp ult i8 %layer140.01, 2
  br i1 %cmp1434, label %for.body145.split, label %for.end253, !llvm.loop !7783

for.body145.split:                                ; preds = %for.body145
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 2, i64 1), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([17 x i8]* @176)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.content, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv152.width, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv152.rows, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i16]* %qkv152.row0, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.row_space, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.batch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.layer, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.stage, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.region, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i32]* %qkv152.ref.epoch, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.ref.bank, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  call void (...) @_ssdm_SpecDependence([2 x i8]* %qkv152.ref.id, i32 0, i32 0, i32 0, i32 0, i32 1, i1 false)
  store i8 0, i8* %normalized146.ref.id, align 512, !alias.scope !7788, !noalias !7793
  store i8 0, i8* %normalized146.ref.bank, align 512, !alias.scope !7807, !noalias !7808
  store i32 0, i32* %normalized146.ref.epoch, align 512, !alias.scope !7809, !noalias !7810
  store i8 0, i8* %normalized146.region, align 512, !alias.scope !7811, !noalias !7812
  store i8 0, i8* %normalized146.stage, align 512, !alias.scope !7813, !noalias !7814
  store i8 -1, i8* %normalized146.layer, align 512, !alias.scope !7815, !noalias !7816
  store i8 -1, i8* %normalized146.batch, align 512, !alias.scope !7817, !noalias !7818
  store i8 0, i8* %normalized146.row_space, align 512, !alias.scope !7819, !noalias !7820
  store i16 0, i16* %normalized146.row0, align 512, !alias.scope !7821, !noalias !7822
  store i16 0, i16* %normalized146.rows, align 512, !alias.scope !7823, !noalias !7824
  store i16 0, i16* %normalized146.width, align 512, !alias.scope !7825, !noalias !7826
  store i8 0, i8* %normalized146.content, align 512, !alias.scope !7827, !noalias !7828
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp148.0, i8* %agg.tmp148.1, i32* %agg.tmp148.2, i8 2, i8 0, i8 0)
  %161 = load i8, i8* %agg.tmp148.0, align 512
  %162 = load i8, i8* %agg.tmp148.1, align 512
  %163 = load i32, i32* %agg.tmp148.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm"(i16* %ref.tmp147.0659, i32* %ref.tmp147.1660, i64* %ref.tmp147.2661, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 17, [23 x i192]* %hidden, i8 4, i8 %layer140.01, i8 %161, i8 %162, i32 %163, i8 0, i8* %normalized146.ref.id, i8* %normalized146.ref.bank, i32* %normalized146.ref.epoch, i8* %normalized146.region, i8* %normalized146.stage, i8* %normalized146.layer, i8* %normalized146.batch, i8* %normalized146.row_space, i16* %normalized146.row0, i16* %normalized146.rows, i16* %normalized146.width, i8* %normalized146.content)
  %.0189 = load i16, i16* %ref.tmp147.0659, align 512
  %.1191 = load i32, i32* %ref.tmp147.1660, align 512
  %.2193 = load i64, i64* %ref.tmp147.2661, align 512
  store i16 %.0189, i16* %agg.result_code, align 512
  store i32 %.1191, i32* %agg.result_detail, align 512
  store i64 %.2193, i64* %agg.result_bad_element, align 512
  %164 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0189)
  br i1 %164, label %if.end151, label %cleanup246

if.end151:                                        ; preds = %for.body145.split
  br label %arrayctor.loop156

arrayctor.loop156:                                ; preds = %arrayctor.loop156, %if.end151
  %indvars.iv = phi i64 [ %indvars.iv.next, %arrayctor.loop156 ], [ 0, %if.end151 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 2, i64 2, i64 2), !fpga.pragma.source !33
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %array.src159.0.0 = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.id, i64 0, i64 %indvars.iv
  %array.src159.0.1 = getelementptr [2 x i8], [2 x i8]* %qkv152.ref.bank, i64 0, i64 %indvars.iv
  %array.src159.0.2 = getelementptr [2 x i32], [2 x i32]* %qkv152.ref.epoch, i64 0, i64 %indvars.iv
  %array.src159.1 = getelementptr [2 x i8], [2 x i8]* %qkv152.region, i64 0, i64 %indvars.iv
  %array.src159.2 = getelementptr [2 x i8], [2 x i8]* %qkv152.stage, i64 0, i64 %indvars.iv
  %array.src159.3 = getelementptr [2 x i8], [2 x i8]* %qkv152.layer, i64 0, i64 %indvars.iv
  %array.src159.4 = getelementptr [2 x i8], [2 x i8]* %qkv152.batch, i64 0, i64 %indvars.iv
  %array.src159.5 = getelementptr [2 x i8], [2 x i8]* %qkv152.row_space, i64 0, i64 %indvars.iv
  %array.src159.6 = getelementptr [2 x i16], [2 x i16]* %qkv152.row0, i64 0, i64 %indvars.iv
  %array.src159.7 = getelementptr [2 x i16], [2 x i16]* %qkv152.rows, i64 0, i64 %indvars.iv
  %array.src159.8 = getelementptr [2 x i16], [2 x i16]* %qkv152.width, i64 0, i64 %indvars.iv
  %array.src159.9 = getelementptr [2 x i8], [2 x i8]* %qkv152.content, i64 0, i64 %indvars.iv
  store i8 0, i8* %array.src159.0.0, align 4, !alias.scope !7829, !noalias !7834
  store i8 0, i8* %array.src159.0.1, align 1, !alias.scope !7848, !noalias !7849
  store i32 0, i32* %array.src159.0.2, align 4, !alias.scope !7850, !noalias !7851
  store i8 0, i8* %array.src159.1, align 4, !alias.scope !7852, !noalias !7853
  store i8 0, i8* %array.src159.2, align 1, !alias.scope !7854, !noalias !7855
  store i8 -1, i8* %array.src159.3, align 2, !alias.scope !7856, !noalias !7857
  store i8 -1, i8* %array.src159.4, align 1, !alias.scope !7858, !noalias !7859
  store i8 0, i8* %array.src159.5, align 4, !alias.scope !7860, !noalias !7861
  store i16 0, i16* %array.src159.6, align 2, !alias.scope !7862, !noalias !7863
  store i16 0, i16* %array.src159.7, align 4, !alias.scope !7864, !noalias !7865
  store i16 0, i16* %array.src159.8, align 2, !alias.scope !7866, !noalias !7867
  store i8 0, i8* %array.src159.9, align 4, !alias.scope !7868, !noalias !7869
  %165 = icmp eq i64 %indvars.iv, 1
  br i1 %165, label %if.end151154, label %arrayctor.loop156, !llvm.loop !7870

if.end151154:                                     ; preds = %arrayctor.loop156
  store i8 0, i8* %qkv_primary160.ref.id, align 512, !alias.scope !7871, !noalias !7876
  store i8 0, i8* %qkv_primary160.ref.bank, align 512, !alias.scope !7890, !noalias !7891
  store i32 0, i32* %qkv_primary160.ref.epoch, align 512, !alias.scope !7892, !noalias !7893
  store i8 0, i8* %qkv_primary160.region, align 512, !alias.scope !7894, !noalias !7895
  store i8 0, i8* %qkv_primary160.stage, align 512, !alias.scope !7896, !noalias !7897
  store i8 -1, i8* %qkv_primary160.layer, align 512, !alias.scope !7898, !noalias !7899
  store i8 -1, i8* %qkv_primary160.batch, align 512, !alias.scope !7900, !noalias !7901
  store i8 0, i8* %qkv_primary160.row_space, align 512, !alias.scope !7902, !noalias !7903
  store i16 0, i16* %qkv_primary160.row0, align 512, !alias.scope !7904, !noalias !7905
  store i16 0, i16* %qkv_primary160.rows, align 512, !alias.scope !7906, !noalias !7907
  store i16 0, i16* %qkv_primary160.width, align 512, !alias.scope !7908, !noalias !7909
  store i8 0, i8* %qkv_primary160.content, align 512, !alias.scope !7910, !noalias !7911
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp165.0, i8* %agg.tmp165.1, i32* %agg.tmp165.2, i8 5, i8 0, i8 0)
  %166 = load i8, i8* %agg.tmp165.0, align 512
  %167 = load i8, i8* %agg.tmp165.1, align 512
  %168 = load i32, i32* %agg.tmp165.2, align 512
  %normalized146.row_space.val170 = load i8, i8* %normalized146.row_space, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.17"(i16* %ref.tmp161.0635, i32* %ref.tmp161.1636, i64* %ref.tmp161.2637, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %layer140.01, i8 %normalized146.row_space.val170, i8 %layer140.01, i8 %166, i8 %167, i32 %168, i8* %qkv_primary160.ref.id, i8* %qkv_primary160.ref.bank, i32* %qkv_primary160.ref.epoch, i8* %qkv_primary160.region, i8* %qkv_primary160.stage, i8* %qkv_primary160.layer, i8* %qkv_primary160.batch, i8* %qkv_primary160.row_space, i16* %qkv_primary160.row0, i16* %qkv_primary160.rows, i16* %qkv_primary160.width, i8* %qkv_primary160.content)
  %.0183 = load i16, i16* %ref.tmp161.0635, align 512
  %.1185 = load i32, i32* %ref.tmp161.1636, align 512
  %.2187 = load i64, i64* %ref.tmp161.2637, align 512
  store i16 %.0183, i16* %agg.result_code, align 512
  store i32 %.1185, i32* %agg.result_detail, align 512
  store i64 %.2187, i64* %agg.result_bad_element, align 512
  %169 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0183)
  br i1 %169, label %if.end169, label %cleanup244

if.end169:                                        ; preds = %if.end151154
  %normalized146.ref.id.val56 = load i8, i8* %normalized146.ref.id, align 512
  %normalized146.ref.bank.val57 = load i8, i8* %normalized146.ref.bank, align 512
  %normalized146.ref.epoch.val58 = load i32, i32* %normalized146.ref.epoch, align 512, !alias.scope !7543, !noalias !7546
  %normalized146.region.val59 = load i8, i8* %normalized146.region, align 512
  %normalized146.stage.val60 = load i8, i8* %normalized146.stage, align 512, !alias.scope !7559, !noalias !7560
  %normalized146.layer.val61 = load i8, i8* %normalized146.layer, align 512, !alias.scope !7561, !noalias !7562
  %normalized146.batch.val62 = load i8, i8* %normalized146.batch, align 512, !alias.scope !7563, !noalias !7564
  %normalized146.row0.val64 = load i16, i16* %normalized146.row0, align 512, !alias.scope !7567, !noalias !7568
  %normalized146.rows.val65 = load i16, i16* %normalized146.rows, align 512, !alias.scope !7569, !noalias !7570
  %normalized146.width.val66 = load i16, i16* %normalized146.width, align 512, !alias.scope !7571, !noalias !7572
  %normalized146.content.val67 = load i8, i8* %normalized146.content, align 512, !alias.scope !7573, !noalias !7574
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp170.0629, i32* %ref.tmp170.1630, i64* %ref.tmp170.2631, i8 %normalized146.ref.id.val56, i8 %normalized146.ref.bank.val57, i32 %normalized146.ref.epoch.val58, i8 %normalized146.region.val59, i8 %normalized146.stage.val60, i8 %normalized146.layer.val61, i8 %normalized146.batch.val62, i8 %normalized146.row_space.val170, i16 %normalized146.row0.val64, i16 %normalized146.rows.val65, i16 %normalized146.width.val66, i8 %normalized146.content.val67)
  %.0177 = load i16, i16* %ref.tmp170.0629, align 512
  %.1179 = load i32, i32* %ref.tmp170.1630, align 512
  %.2181 = load i64, i64* %ref.tmp170.2631, align 512
  store i16 %.0177, i16* %agg.result_code, align 512
  store i32 %.1179, i32* %agg.result_detail, align 512
  store i64 %.2181, i64* %agg.result_bad_element, align 512
  %170 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0177)
  br i1 %170, label %if.end174, label %cleanup244

if.end174:                                        ; preds = %if.end169
  store i8 0, i8* %attended175.ref.id, align 512, !alias.scope !7912, !noalias !7917
  store i8 0, i8* %attended175.ref.bank, align 512, !alias.scope !7931, !noalias !7932
  store i32 0, i32* %attended175.ref.epoch, align 512, !alias.scope !7933, !noalias !7934
  store i8 0, i8* %attended175.region, align 512, !alias.scope !7935, !noalias !7936
  store i8 0, i8* %attended175.stage, align 512, !alias.scope !7937, !noalias !7938
  store i8 -1, i8* %attended175.layer, align 512, !alias.scope !7939, !noalias !7940
  store i8 -1, i8* %attended175.batch, align 512, !alias.scope !7941, !noalias !7942
  store i8 0, i8* %attended175.row_space, align 512, !alias.scope !7943, !noalias !7944
  store i16 0, i16* %attended175.row0, align 512, !alias.scope !7945, !noalias !7946
  store i16 0, i16* %attended175.rows, align 512, !alias.scope !7947, !noalias !7948
  store i16 0, i16* %attended175.width, align 512, !alias.scope !7949, !noalias !7950
  store i8 0, i8* %attended175.content, align 512, !alias.scope !7951, !noalias !7952
  %qkv152.ref.id.idx.val = load i8, i8* %qkv152.ref.id.cast, align 512
  %qkv152.ref.id.idx83.val = load i8, i8* %qkv152.ref.id.idx83, align 1
  %qkv152.ref.bank.idx.val = load i8, i8* %qkv152.ref.bank.cast, align 512
  %qkv152.ref.bank.idx84.val = load i8, i8* %qkv152.ref.bank.idx84, align 1
  %qkv152.content.idx.val = load i8, i8* %qkv152.content.cast655, align 512
  %qkv152.content.idx85.val = load i8, i8* %qkv152.content.idx85, align 1
  call fastcc void @"laya::full::(anonymous namespace)::Controller::attention"(i16* %ref.tmp176.0618, i32* %ref.tmp176.1619, i64* %ref.tmp176.2620, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 4, i8 %layer140.01, i8 %qkv152.ref.id.idx.val, i8 %qkv152.ref.id.idx83.val, i8 %qkv152.ref.bank.idx.val, i8 %qkv152.ref.bank.idx84.val, [2 x i32]* %qkv152.ref.epoch, [2 x i8]* %qkv152.region, [2 x i8]* %qkv152.stage, [2 x i8]* %qkv152.layer, [2 x i8]* %qkv152.batch, [2 x i8]* %qkv152.row_space, [2 x i16]* %qkv152.row0, [2 x i16]* %qkv152.rows, [2 x i16]* %qkv152.width, i8 %qkv152.content.idx.val, i8 %qkv152.content.idx85.val, i8* %attended175.ref.id, i8* %attended175.ref.bank, i32* %attended175.ref.epoch, i8* %attended175.region, i8* %attended175.stage, i8* %attended175.layer, i8* %attended175.batch, i8* %attended175.row_space, i16* %attended175.row0, i16* %attended175.rows, i16* %attended175.width, i8* %attended175.content)
  %.0171 = load i16, i16* %ref.tmp176.0618, align 512
  %.1173 = load i32, i32* %ref.tmp176.1619, align 512
  %.2175 = load i64, i64* %ref.tmp176.2620, align 512
  store i16 %.0171, i16* %agg.result_code, align 512
  store i32 %.1173, i32* %agg.result_detail, align 512
  store i64 %.2175, i64* %agg.result_bad_element, align 512
  %171 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0171)
  br i1 %171, label %if.end179, label %cleanup243

if.end179:                                        ; preds = %if.end174
  store i8 0, i8* %projected180.ref.id, align 512, !alias.scope !7953, !noalias !7958
  store i8 0, i8* %projected180.ref.bank, align 512, !alias.scope !7972, !noalias !7973
  store i32 0, i32* %projected180.ref.epoch, align 512, !alias.scope !7974, !noalias !7975
  store i8 0, i8* %projected180.region, align 512, !alias.scope !7976, !noalias !7977
  store i8 0, i8* %projected180.stage, align 512, !alias.scope !7978, !noalias !7979
  store i8 -1, i8* %projected180.layer, align 512, !alias.scope !7980, !noalias !7981
  store i8 -1, i8* %projected180.batch, align 512, !alias.scope !7982, !noalias !7983
  store i8 0, i8* %projected180.row_space, align 512, !alias.scope !7984, !noalias !7985
  store i16 0, i16* %projected180.row0, align 512, !alias.scope !7986, !noalias !7987
  store i16 0, i16* %projected180.rows, align 512, !alias.scope !7988, !noalias !7989
  store i16 0, i16* %projected180.width, align 512, !alias.scope !7990, !noalias !7991
  store i8 0, i8* %projected180.content, align 512, !alias.scope !7992, !noalias !7993
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp185.0, i8* %agg.tmp185.1, i32* %agg.tmp185.2, i8 3, i8 0, i8 0)
  %172 = load i8, i8* %agg.tmp185.0, align 512
  %173 = load i8, i8* %agg.tmp185.1, align 512
  %174 = load i32, i32* %agg.tmp185.2, align 512
  %attended175.ref.id.val110 = load i8, i8* %attended175.ref.id, align 512
  %attended175.ref.bank.val111 = load i8, i8* %attended175.ref.bank, align 512
  %attended175.ref.epoch.val112 = load i32, i32* %attended175.ref.epoch, align 512
  %attended175.region.val113 = load i8, i8* %attended175.region, align 512
  %attended175.stage.val114 = load i8, i8* %attended175.stage, align 512, !alias.scope !7518, !noalias !7521
  %attended175.layer.val115 = load i8, i8* %attended175.layer, align 512
  %attended175.batch.val116 = load i8, i8* %attended175.batch, align 512, !alias.scope !7537, !noalias !7538
  %attended175.row_space.val117 = load i8, i8* %attended175.row_space, align 512
  %attended175.row0.val118 = load i16, i16* %attended175.row0, align 512, !alias.scope !7539, !noalias !7540
  %attended175.rows.val119 = load i16, i16* %attended175.rows, align 512
  %attended175.width.val120 = load i16, i16* %attended175.width, align 512, !alias.scope !7541, !noalias !7542
  %attended175.content.val121 = load i8, i8* %attended175.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp181.0607, i32* %ref.tmp181.1608, i64* %ref.tmp181.2609, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 49, i8 6, i8 %layer140.01, i8 %attended175.ref.id.val110, i8 %attended175.ref.bank.val111, i32 %attended175.ref.epoch.val112, i8 %attended175.region.val113, i8 %attended175.stage.val114, i8 %attended175.layer.val115, i8 %attended175.batch.val116, i8 %attended175.row_space.val117, i16 %attended175.row0.val118, i16 %attended175.rows.val119, i16 %attended175.width.val120, i8 %attended175.content.val121, i8 4, i8 %layer140.01, i8 %172, i8 %173, i32 %174, i8 0, i8* %projected180.ref.id, i8* %projected180.ref.bank, i32* %projected180.ref.epoch, i8* %projected180.region, i8* %projected180.stage, i8* %projected180.layer, i8* %projected180.batch, i8* %projected180.row_space, i16* %projected180.row0, i16* %projected180.rows, i16* %projected180.width, i8* %projected180.content)
  %.0165 = load i16, i16* %ref.tmp181.0607, align 512
  %.1167 = load i32, i32* %ref.tmp181.1608, align 512
  %.2169 = load i64, i64* %ref.tmp181.2609, align 512
  store i16 %.0165, i16* %agg.result_code, align 512
  store i32 %.1167, i32* %agg.result_detail, align 512
  store i64 %.2169, i64* %agg.result_bad_element, align 512
  %175 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0165)
  br i1 %175, label %if.end188, label %cleanup242

if.end188:                                        ; preds = %if.end179
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp189.0601, i32* %ref.tmp189.1602, i64* %ref.tmp189.2603, i8 %attended175.ref.id.val110, i8 %attended175.ref.bank.val111, i32 %attended175.ref.epoch.val112, i8 %attended175.region.val113, i8 %attended175.stage.val114, i8 %attended175.layer.val115, i8 %attended175.batch.val116, i8 %attended175.row_space.val117, i16 %attended175.row0.val118, i16 %attended175.rows.val119, i16 %attended175.width.val120, i8 %attended175.content.val121)
  %.0159 = load i16, i16* %ref.tmp189.0601, align 512
  %.1161 = load i32, i32* %ref.tmp189.1602, align 512
  %.2163 = load i64, i64* %ref.tmp189.2603, align 512
  store i16 %.0159, i16* %agg.result_code, align 512
  store i32 %.1161, i32* %agg.result_detail, align 512
  store i64 %.2163, i64* %agg.result_bad_element, align 512
  %176 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0159)
  br i1 %176, label %if.end193, label %cleanup242

if.end193:                                        ; preds = %if.end188
  %projected180.ref.id.val = load i8, i8* %projected180.ref.id, align 512
  %projected180.ref.bank.val = load i8, i8* %projected180.ref.bank, align 512
  %projected180.ref.epoch.val = load i32, i32* %projected180.ref.epoch, align 512, !alias.scope !7543, !noalias !7546
  %projected180.region.val = load i8, i8* %projected180.region, align 512
  %projected180.stage.val = load i8, i8* %projected180.stage, align 512, !alias.scope !7559, !noalias !7560
  %projected180.layer.val = load i8, i8* %projected180.layer, align 512, !alias.scope !7561, !noalias !7562
  %projected180.batch.val = load i8, i8* %projected180.batch, align 512, !alias.scope !7563, !noalias !7564
  %projected180.row_space.val = load i8, i8* %projected180.row_space, align 512, !alias.scope !7565, !noalias !7566
  %projected180.row0.val = load i16, i16* %projected180.row0, align 512, !alias.scope !7567, !noalias !7568
  %projected180.rows.val = load i16, i16* %projected180.rows, align 512, !alias.scope !7569, !noalias !7570
  %projected180.width.val = load i16, i16* %projected180.width, align 512, !alias.scope !7571, !noalias !7572
  %projected180.content.val = load i8, i8* %projected180.content, align 512, !alias.scope !7573, !noalias !7574
  call fastcc void @"laya::full::(anonymous namespace)::Controller::residual"(i16* %ref.tmp194.0595, i32* %ref.tmp194.1596, i64* %ref.tmp194.2597, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 4, i8 %layer140.01, i8 %projected180.ref.id.val, i8 %projected180.ref.bank.val, i32 %projected180.ref.epoch.val, i8 %projected180.region.val, i8 %projected180.stage.val, i8 %projected180.layer.val, i8 %projected180.batch.val, i8 %projected180.row_space.val, i16 %projected180.row0.val, i16 %projected180.rows.val, i16 %projected180.width.val, i8 %projected180.content.val, [23 x i192]* %hidden)
  %.0153 = load i16, i16* %ref.tmp194.0595, align 512
  %.1155 = load i32, i32* %ref.tmp194.1596, align 512
  %.2157 = load i64, i64* %ref.tmp194.2597, align 512
  store i16 %.0153, i16* %agg.result_code, align 512
  store i32 %.1155, i32* %agg.result_detail, align 512
  store i64 %.2157, i64* %agg.result_bad_element, align 512
  %177 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0153)
  br i1 %177, label %if.end197, label %cleanup242

if.end197:                                        ; preds = %if.end193
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp199.0, i8* %agg.tmp199.1, i32* %agg.tmp199.2, i8 2, i8 0, i8 0)
  %178 = load i8, i8* %agg.tmp199.0, align 512
  %179 = load i8, i8* %agg.tmp199.1, align 512
  %180 = load i32, i32* %agg.tmp199.2, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm"(i16* %ref.tmp198.0589, i32* %ref.tmp198.1590, i64* %ref.tmp198.2591, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 18, [23 x i192]* %hidden, i8 4, i8 %layer140.01, i8 %178, i8 %179, i32 %180, i8 0, i8* %normalized146.ref.id, i8* %normalized146.ref.bank, i32* %normalized146.ref.epoch, i8* %normalized146.region, i8* %normalized146.stage, i8* %normalized146.layer, i8* %normalized146.batch, i8* %normalized146.row_space, i16* %normalized146.row0, i16* %normalized146.rows, i16* %normalized146.width, i8* %normalized146.content)
  %.0147 = load i16, i16* %ref.tmp198.0589, align 512
  %.1149 = load i32, i32* %ref.tmp198.1590, align 512
  %.2151 = load i64, i64* %ref.tmp198.2591, align 512
  store i16 %.0147, i16* %agg.result_code, align 512
  store i32 %.1149, i32* %agg.result_detail, align 512
  store i64 %.2151, i64* %agg.result_bad_element, align 512
  %181 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0147)
  br i1 %181, label %if.end202, label %cleanup242

if.end202:                                        ; preds = %if.end197
  store i8 0, i8* %fc1.ref.id, align 512, !alias.scope !7994, !noalias !7999
  store i8 0, i8* %fc1.ref.bank, align 512, !alias.scope !8013, !noalias !8014
  store i32 0, i32* %fc1.ref.epoch, align 512, !alias.scope !8015, !noalias !8016
  store i8 0, i8* %fc1.region, align 512, !alias.scope !8017, !noalias !8018
  store i8 0, i8* %fc1.stage, align 512, !alias.scope !8019, !noalias !8020
  store i8 -1, i8* %fc1.layer, align 512, !alias.scope !8021, !noalias !8022
  store i8 -1, i8* %fc1.batch, align 512, !alias.scope !8023, !noalias !8024
  store i8 0, i8* %fc1.row_space, align 512, !alias.scope !8025, !noalias !8026
  store i16 0, i16* %fc1.row0, align 512, !alias.scope !8027, !noalias !8028
  store i16 0, i16* %fc1.rows, align 512, !alias.scope !8029, !noalias !8030
  store i16 0, i16* %fc1.width, align 512, !alias.scope !8031, !noalias !8032
  store i8 0, i8* %fc1.content, align 512, !alias.scope !8033, !noalias !8034
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp207.0, i8* %agg.tmp207.1, i32* %agg.tmp207.2, i8 9, i8 0, i8 0)
  %182 = load i8, i8* %agg.tmp207.0, align 512
  %183 = load i8, i8* %agg.tmp207.1, align 512
  %184 = load i32, i32* %agg.tmp207.2, align 512
  %normalized146.ref.id.val122 = load i8, i8* %normalized146.ref.id, align 512
  %normalized146.ref.bank.val123 = load i8, i8* %normalized146.ref.bank, align 512
  %normalized146.ref.epoch.val124 = load i32, i32* %normalized146.ref.epoch, align 512
  %normalized146.region.val125 = load i8, i8* %normalized146.region, align 512
  %normalized146.stage.val126 = load i8, i8* %normalized146.stage, align 512, !alias.scope !7518, !noalias !7521
  %normalized146.layer.val127 = load i8, i8* %normalized146.layer, align 512
  %normalized146.batch.val128 = load i8, i8* %normalized146.batch, align 512, !alias.scope !7537, !noalias !7538
  %normalized146.row_space.val129 = load i8, i8* %normalized146.row_space, align 512
  %normalized146.row0.val130 = load i16, i16* %normalized146.row0, align 512, !alias.scope !7539, !noalias !7540
  %normalized146.rows.val131 = load i16, i16* %normalized146.rows, align 512
  %normalized146.width.val132 = load i16, i16* %normalized146.width, align 512, !alias.scope !7541, !noalias !7542
  %normalized146.content.val133 = load i8, i8* %normalized146.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp203.0578, i32* %ref.tmp203.1579, i64* %ref.tmp203.2580, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 52, i8 7, i8 %layer140.01, i8 %normalized146.ref.id.val122, i8 %normalized146.ref.bank.val123, i32 %normalized146.ref.epoch.val124, i8 %normalized146.region.val125, i8 %normalized146.stage.val126, i8 %normalized146.layer.val127, i8 %normalized146.batch.val128, i8 %normalized146.row_space.val129, i16 %normalized146.row0.val130, i16 %normalized146.rows.val131, i16 %normalized146.width.val132, i8 %normalized146.content.val133, i8 4, i8 %layer140.01, i8 %182, i8 %183, i32 %184, i8 0, i8* %fc1.ref.id, i8* %fc1.ref.bank, i32* %fc1.ref.epoch, i8* %fc1.region, i8* %fc1.stage, i8* %fc1.layer, i8* %fc1.batch, i8* %fc1.row_space, i16* %fc1.row0, i16* %fc1.rows, i16* %fc1.width, i8* %fc1.content)
  %.0141 = load i16, i16* %ref.tmp203.0578, align 512
  %.1143 = load i32, i32* %ref.tmp203.1579, align 512
  %.2145 = load i64, i64* %ref.tmp203.2580, align 512
  store i16 %.0141, i16* %agg.result_code, align 512
  store i32 %.1143, i32* %agg.result_detail, align 512
  store i64 %.2145, i64* %agg.result_bad_element, align 512
  %185 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0141)
  br i1 %185, label %if.end210, label %cleanup241

if.end210:                                        ; preds = %if.end202
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp211.0572, i32* %ref.tmp211.1573, i64* %ref.tmp211.2574, i8 %normalized146.ref.id.val122, i8 %normalized146.ref.bank.val123, i32 %normalized146.ref.epoch.val124, i8 %normalized146.region.val125, i8 %normalized146.stage.val126, i8 %normalized146.layer.val127, i8 %normalized146.batch.val128, i8 %normalized146.row_space.val129, i16 %normalized146.row0.val130, i16 %normalized146.rows.val131, i16 %normalized146.width.val132, i8 %normalized146.content.val133)
  %.0135 = load i16, i16* %ref.tmp211.0572, align 512
  %.1137 = load i32, i32* %ref.tmp211.1573, align 512
  %.2139 = load i64, i64* %ref.tmp211.2574, align 512
  store i16 %.0135, i16* %agg.result_code, align 512
  store i32 %.1137, i32* %agg.result_detail, align 512
  store i64 %.2139, i64* %agg.result_bad_element, align 512
  %186 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0135)
  br i1 %186, label %if.end215, label %cleanup241

if.end215:                                        ; preds = %if.end210
  store i8 0, i8* %relu.ref.id, align 512, !alias.scope !8035, !noalias !8040
  store i8 0, i8* %relu.ref.bank, align 512, !alias.scope !8054, !noalias !8055
  store i32 0, i32* %relu.ref.epoch, align 512, !alias.scope !8056, !noalias !8057
  store i8 0, i8* %relu.region, align 512, !alias.scope !8058, !noalias !8059
  store i8 0, i8* %relu.stage, align 512, !alias.scope !8060, !noalias !8061
  store i8 -1, i8* %relu.layer, align 512, !alias.scope !8062, !noalias !8063
  store i8 -1, i8* %relu.batch, align 512, !alias.scope !8064, !noalias !8065
  store i8 0, i8* %relu.row_space, align 512, !alias.scope !8066, !noalias !8067
  store i16 0, i16* %relu.row0, align 512, !alias.scope !8068, !noalias !8069
  store i16 0, i16* %relu.rows, align 512, !alias.scope !8070, !noalias !8071
  store i16 0, i16* %relu.width, align 512, !alias.scope !8072, !noalias !8073
  store i8 0, i8* %relu.content, align 512, !alias.scope !8074, !noalias !8075
  %fc1.ref.id.val = load i8, i8* %fc1.ref.id, align 512
  %fc1.ref.bank.val = load i8, i8* %fc1.ref.bank, align 512
  %fc1.ref.epoch.val = load i32, i32* %fc1.ref.epoch, align 512
  %fc1.region.val = load i8, i8* %fc1.region, align 512
  %fc1.stage.val = load i8, i8* %fc1.stage, align 512
  %fc1.layer.val = load i8, i8* %fc1.layer, align 512
  %fc1.batch.val = load i8, i8* %fc1.batch, align 512
  %fc1.row_space.val = load i8, i8* %fc1.row_space, align 512
  %fc1.row0.val = load i16, i16* %fc1.row0, align 512
  %fc1.rows.val = load i16, i16* %fc1.rows, align 512
  %fc1.width.val = load i16, i16* %fc1.width, align 512
  %fc1.content.val = load i8, i8* %fc1.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::transform"(i16* %ref.tmp216.0561, i32* %ref.tmp216.1562, i64* %ref.tmp216.2563, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 97, i8 %fc1.ref.id.val, i8 %fc1.ref.bank.val, i32 %fc1.ref.epoch.val, i8 %fc1.region.val, i8 %fc1.stage.val, i8 %fc1.layer.val, i8 %fc1.batch.val, i8 %fc1.row_space.val, i16 %fc1.row0.val, i16 %fc1.rows.val, i16 %fc1.width.val, i8 %fc1.content.val, i16 4096, i16 -1, i8* %relu.ref.id, i8* %relu.ref.bank, i32* %relu.ref.epoch, i8* %relu.region, i8* %relu.stage, i8* %relu.layer, i8* %relu.batch, i8* %relu.row_space, i16* %relu.row0, i16* %relu.rows, i16* %relu.width, i8* %relu.content)
  %.0129 = load i16, i16* %ref.tmp216.0561, align 512
  %.1131 = load i32, i32* %ref.tmp216.1562, align 512
  %.2133 = load i64, i64* %ref.tmp216.2563, align 512
  store i16 %.0129, i16* %agg.result_code, align 512
  store i32 %.1131, i32* %agg.result_detail, align 512
  store i64 %.2133, i64* %agg.result_bad_element, align 512
  %187 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0129)
  br i1 %187, label %if.end219, label %cleanup240

if.end219:                                        ; preds = %if.end215
  store i8 0, i8* %fc2.ref.id, align 512, !alias.scope !8076, !noalias !8081
  store i8 0, i8* %fc2.ref.bank, align 512, !alias.scope !8095, !noalias !8096
  store i32 0, i32* %fc2.ref.epoch, align 512, !alias.scope !8097, !noalias !8098
  store i8 0, i8* %fc2.region, align 512, !alias.scope !8099, !noalias !8100
  store i8 0, i8* %fc2.stage, align 512, !alias.scope !8101, !noalias !8102
  store i8 -1, i8* %fc2.layer, align 512, !alias.scope !8103, !noalias !8104
  store i8 -1, i8* %fc2.batch, align 512, !alias.scope !8105, !noalias !8106
  store i8 0, i8* %fc2.row_space, align 512, !alias.scope !8107, !noalias !8108
  store i16 0, i16* %fc2.row0, align 512, !alias.scope !8109, !noalias !8110
  store i16 0, i16* %fc2.rows, align 512, !alias.scope !8111, !noalias !8112
  store i16 0, i16* %fc2.width, align 512, !alias.scope !8113, !noalias !8114
  store i8 0, i8* %fc2.content, align 512, !alias.scope !8115, !noalias !8116
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp224.0, i8* %agg.tmp224.1, i32* %agg.tmp224.2, i8 3, i8 0, i8 0)
  %188 = load i8, i8* %agg.tmp224.0, align 512
  %189 = load i8, i8* %agg.tmp224.1, align 512
  %190 = load i32, i32* %agg.tmp224.2, align 512
  %relu.ref.id.val98 = load i8, i8* %relu.ref.id, align 512
  %relu.ref.bank.val99 = load i8, i8* %relu.ref.bank, align 512
  %relu.ref.epoch.val100 = load i32, i32* %relu.ref.epoch, align 512
  %relu.region.val101 = load i8, i8* %relu.region, align 512
  %relu.stage.val102 = load i8, i8* %relu.stage, align 512, !alias.scope !7518, !noalias !7521
  %relu.layer.val103 = load i8, i8* %relu.layer, align 512
  %relu.batch.val104 = load i8, i8* %relu.batch, align 512, !alias.scope !7537, !noalias !7538
  %relu.row_space.val105 = load i8, i8* %relu.row_space, align 512
  %relu.row0.val106 = load i16, i16* %relu.row0, align 512, !alias.scope !7539, !noalias !7540
  %relu.rows.val107 = load i16, i16* %relu.rows, align 512
  %relu.width.val108 = load i16, i16* %relu.width, align 512, !alias.scope !7541, !noalias !7542
  %relu.content.val109 = load i8, i8* %relu.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp220.0550, i32* %ref.tmp220.1551, i64* %ref.tmp220.2552, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 53, i8 8, i8 %layer140.01, i8 %relu.ref.id.val98, i8 %relu.ref.bank.val99, i32 %relu.ref.epoch.val100, i8 %relu.region.val101, i8 %relu.stage.val102, i8 %relu.layer.val103, i8 %relu.batch.val104, i8 %relu.row_space.val105, i16 %relu.row0.val106, i16 %relu.rows.val107, i16 %relu.width.val108, i8 %relu.content.val109, i8 4, i8 %layer140.01, i8 %188, i8 %189, i32 %190, i8 0, i8* %fc2.ref.id, i8* %fc2.ref.bank, i32* %fc2.ref.epoch, i8* %fc2.region, i8* %fc2.stage, i8* %fc2.layer, i8* %fc2.batch, i8* %fc2.row_space, i16* %fc2.row0, i16* %fc2.rows, i16* %fc2.width, i8* %fc2.content)
  %.0123 = load i16, i16* %ref.tmp220.0550, align 512
  %.1125 = load i32, i32* %ref.tmp220.1551, align 512
  %.2127 = load i64, i64* %ref.tmp220.2552, align 512
  store i16 %.0123, i16* %agg.result_code, align 512
  store i32 %.1125, i32* %agg.result_detail, align 512
  store i64 %.2127, i64* %agg.result_bad_element, align 512
  %191 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0123)
  br i1 %191, label %if.end227, label %cleanup239

if.end227:                                        ; preds = %if.end219
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp228.0544, i32* %ref.tmp228.1545, i64* %ref.tmp228.2546, i8 %relu.ref.id.val98, i8 %relu.ref.bank.val99, i32 %relu.ref.epoch.val100, i8 %relu.region.val101, i8 %relu.stage.val102, i8 %relu.layer.val103, i8 %relu.batch.val104, i8 %relu.row_space.val105, i16 %relu.row0.val106, i16 %relu.rows.val107, i16 %relu.width.val108, i8 %relu.content.val109)
  %.0117 = load i16, i16* %ref.tmp228.0544, align 512
  %.1119 = load i32, i32* %ref.tmp228.1545, align 512
  %.2121 = load i64, i64* %ref.tmp228.2546, align 512
  store i16 %.0117, i16* %agg.result_code, align 512
  store i32 %.1119, i32* %agg.result_detail, align 512
  store i64 %.2121, i64* %agg.result_bad_element, align 512
  %192 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0117)
  br i1 %192, label %if.end232, label %cleanup239

if.end232:                                        ; preds = %if.end227
  %fc2.ref.id.val = load i8, i8* %fc2.ref.id, align 512
  %fc2.ref.bank.val = load i8, i8* %fc2.ref.bank, align 512
  %fc2.ref.epoch.val = load i32, i32* %fc2.ref.epoch, align 512, !alias.scope !7543, !noalias !7546
  %fc2.region.val = load i8, i8* %fc2.region, align 512
  %fc2.stage.val = load i8, i8* %fc2.stage, align 512, !alias.scope !7559, !noalias !7560
  %fc2.layer.val = load i8, i8* %fc2.layer, align 512, !alias.scope !7561, !noalias !7562
  %fc2.batch.val = load i8, i8* %fc2.batch, align 512, !alias.scope !7563, !noalias !7564
  %fc2.row_space.val = load i8, i8* %fc2.row_space, align 512, !alias.scope !7565, !noalias !7566
  %fc2.row0.val = load i16, i16* %fc2.row0, align 512, !alias.scope !7567, !noalias !7568
  %fc2.rows.val = load i16, i16* %fc2.rows, align 512, !alias.scope !7569, !noalias !7570
  %fc2.width.val = load i16, i16* %fc2.width, align 512, !alias.scope !7571, !noalias !7572
  %fc2.content.val = load i8, i8* %fc2.content, align 512, !alias.scope !7573, !noalias !7574
  call fastcc void @"laya::full::(anonymous namespace)::Controller::residual"(i16* %ref.tmp233.0538, i32* %ref.tmp233.1539, i64* %ref.tmp233.2540, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 4, i8 %layer140.01, i8 %fc2.ref.id.val, i8 %fc2.ref.bank.val, i32 %fc2.ref.epoch.val, i8 %fc2.region.val, i8 %fc2.stage.val, i8 %fc2.layer.val, i8 %fc2.batch.val, i8 %fc2.row_space.val, i16 %fc2.row0.val, i16 %fc2.rows.val, i16 %fc2.width.val, i8 %fc2.content.val, [23 x i192]* %hidden)
  %.0111 = load i16, i16* %ref.tmp233.0538, align 512
  %.1113 = load i32, i32* %ref.tmp233.1539, align 512
  %.2115 = load i64, i64* %ref.tmp233.2540, align 512
  store i16 %.0111, i16* %agg.result_code, align 512
  store i32 %.1113, i32* %agg.result_detail, align 512
  store i64 %.2115, i64* %agg.result_bad_element, align 512
  %193 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0111)
  br i1 %193, label %if.end236, label %cleanup239

if.end236:                                        ; preds = %if.end232
  %194 = load i8, i8* @"(anonymous namespace)::runtime.decision_layers_completed", align 512
  %inc238 = add i8 %194, 1
  store i8 %inc238, i8* @"(anonymous namespace)::runtime.decision_layers_completed", align 512
  br label %cleanup239

cleanup239:                                       ; preds = %if.end236, %if.end232, %if.end227, %if.end219
  %cleanup.dest.slot.8 = phi i32 [ 0, %if.end236 ], [ 1, %if.end219 ], [ 1, %if.end227 ], [ 1, %if.end232 ]
  br label %cleanup240

cleanup240:                                       ; preds = %cleanup239, %if.end215
  %cleanup.dest.slot.9 = phi i32 [ %cleanup.dest.slot.8, %cleanup239 ], [ 1, %if.end215 ]
  br label %cleanup241

cleanup241:                                       ; preds = %cleanup240, %if.end210, %if.end202
  %cleanup.dest.slot.10 = phi i32 [ %cleanup.dest.slot.9, %cleanup240 ], [ 1, %if.end202 ], [ 1, %if.end210 ]
  br label %cleanup242

cleanup242:                                       ; preds = %cleanup241, %if.end197, %if.end193, %if.end188, %if.end179
  %cleanup.dest.slot.11 = phi i32 [ %cleanup.dest.slot.10, %cleanup241 ], [ 1, %if.end179 ], [ 1, %if.end188 ], [ 1, %if.end193 ], [ 1, %if.end197 ]
  br label %cleanup243

cleanup243:                                       ; preds = %cleanup242, %if.end174
  %cleanup.dest.slot.12 = phi i32 [ %cleanup.dest.slot.11, %cleanup242 ], [ 1, %if.end174 ]
  br label %cleanup244

cleanup244:                                       ; preds = %cleanup243, %if.end169, %if.end151154
  %cleanup.dest.slot.13 = phi i32 [ %cleanup.dest.slot.12, %cleanup243 ], [ 1, %if.end151154 ], [ 1, %if.end169 ]
  br label %cleanup246

cleanup246:                                       ; preds = %cleanup244, %for.body145.split
  %cleanup.dest.slot.14 = phi i32 [ %cleanup.dest.slot.13, %cleanup244 ], [ 1, %for.body145.split ]
  %cond5 = icmp eq i32 %cleanup.dest.slot.14, 0
  %inc250 = add nuw nsw i8 %layer140.01, 1
  br i1 %cond5, label %for.cond141, label %cleanup361.loopexit

for.end253:                                       ; preds = %for.body145
  store i8 0, i8* %markers.ref.id, align 512, !alias.scope !8117, !noalias !8122
  store i8 0, i8* %markers.ref.bank, align 512, !alias.scope !8136, !noalias !8137
  store i32 0, i32* %markers.ref.epoch, align 512, !alias.scope !8138, !noalias !8139
  store i8 0, i8* %markers.region, align 512, !alias.scope !8140, !noalias !8141
  store i8 0, i8* %markers.stage, align 512, !alias.scope !8142, !noalias !8143
  store i8 -1, i8* %markers.layer, align 512, !alias.scope !8144, !noalias !8145
  store i8 -1, i8* %markers.batch, align 512, !alias.scope !8146, !noalias !8147
  store i8 0, i8* %markers.row_space, align 512, !alias.scope !8148, !noalias !8149
  store i16 0, i16* %markers.row0, align 512, !alias.scope !8150, !noalias !8151
  store i16 0, i16* %markers.rows, align 512, !alias.scope !8152, !noalias !8153
  store i16 0, i16* %markers.width, align 512, !alias.scope !8154, !noalias !8155
  store i8 0, i8* %markers.content, align 512, !alias.scope !8156, !noalias !8157
  call fastcc void @"laya::full::(anonymous namespace)::Controller::gather"(i16* %ref.tmp254.0527, i32* %ref.tmp254.1528, i64* %ref.tmp254.2529, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, [23 x i192]* %hidden, i8* %markers.ref.id, i8* %markers.ref.bank, i32* %markers.ref.epoch, i8* %markers.region, i8* %markers.stage, i8* %markers.layer, i8* %markers.batch, i8* %markers.row_space, i16* %markers.row0, i16* %markers.rows, i16* %markers.width, i8* %markers.content)
  %.0105 = load i16, i16* %ref.tmp254.0527, align 512
  %.1107 = load i32, i32* %ref.tmp254.1528, align 512
  %.2109 = load i64, i64* %ref.tmp254.2529, align 512
  store i16 %.0105, i16* %agg.result_code, align 512
  store i32 %.1107, i32* %agg.result_detail, align 512
  store i64 %.2109, i64* %agg.result_bad_element, align 512
  %195 = call fastcc i1 @"laya::Check::operator bool"(i16 %.0105)
  br i1 %195, label %if.end257, label %cleanup360

if.end257:                                        ; preds = %for.end253
  store i8 0, i8* %marker_norm.ref.id, align 512, !alias.scope !8158, !noalias !8163
  store i8 0, i8* %marker_norm.ref.bank, align 512, !alias.scope !8177, !noalias !8178
  store i32 0, i32* %marker_norm.ref.epoch, align 512, !alias.scope !8179, !noalias !8180
  store i8 0, i8* %marker_norm.region, align 512, !alias.scope !8181, !noalias !8182
  store i8 0, i8* %marker_norm.stage, align 512, !alias.scope !8183, !noalias !8184
  store i8 -1, i8* %marker_norm.layer, align 512, !alias.scope !8185, !noalias !8186
  store i8 -1, i8* %marker_norm.batch, align 512, !alias.scope !8187, !noalias !8188
  store i8 0, i8* %marker_norm.row_space, align 512, !alias.scope !8189, !noalias !8190
  store i16 0, i16* %marker_norm.row0, align 512, !alias.scope !8191, !noalias !8192
  store i16 0, i16* %marker_norm.rows, align 512, !alias.scope !8193, !noalias !8194
  store i16 0, i16* %marker_norm.width, align 512, !alias.scope !8195, !noalias !8196
  store i8 0, i8* %marker_norm.content, align 512, !alias.scope !8197, !noalias !8198
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp259.0, i8* %agg.tmp259.1, i32* %agg.tmp259.2, i8 10, i8 0, i8 0)
  %196 = load i8, i8* %agg.tmp259.0, align 512
  %197 = load i8, i8* %agg.tmp259.1, align 512
  %198 = load i32, i32* %agg.tmp259.2, align 512
  %markers.ref.id.val183 = load i8, i8* %markers.ref.id, align 512
  %markers.ref.bank.val184 = load i8, i8* %markers.ref.bank, align 512
  %markers.ref.epoch.val185 = load i32, i32* %markers.ref.epoch, align 512
  %markers.region.val186 = load i8, i8* %markers.region, align 512, !alias.scope !8199, !noalias !8204
  %markers.stage.val187 = load i8, i8* %markers.stage, align 512, !alias.scope !8235, !noalias !8236
  %markers.layer.val188 = load i8, i8* %markers.layer, align 512
  %markers.batch.val189 = load i8, i8* %markers.batch, align 512, !alias.scope !8237, !noalias !8238
  %markers.row_space.val190 = load i8, i8* %markers.row_space, align 512
  %markers.row0.val191 = load i16, i16* %markers.row0, align 512, !alias.scope !8239, !noalias !8240
  %markers.rows.val192 = load i16, i16* %markers.rows, align 512, !alias.scope !8241, !noalias !8242
  %markers.width.val193 = load i16, i16* %markers.width, align 512, !alias.scope !8243, !noalias !8244
  %markers.content.val194 = load i8, i8* %markers.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::norm.18"(i16* %ref.tmp258.0516, i32* %ref.tmp258.1517, i64* %ref.tmp258.2518, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %markers.ref.id.val183, i8 %markers.ref.bank.val184, i32 %markers.ref.epoch.val185, i8 %markers.region.val186, i8 %markers.stage.val187, i8 %markers.layer.val188, i8 %markers.batch.val189, i8 %markers.row_space.val190, i16 %markers.row0.val191, i16 %markers.rows.val192, i16 %markers.width.val193, i8 %markers.content.val194, i8 %196, i8 %197, i32 %198, i8* %marker_norm.ref.id, i8* %marker_norm.ref.bank, i32* %marker_norm.ref.epoch, i8* %marker_norm.region, i8* %marker_norm.stage, i8* %marker_norm.layer, i8* %marker_norm.batch, i8* %marker_norm.row_space, i16* %marker_norm.row0, i16* %marker_norm.rows, i16* %marker_norm.width, i8* %marker_norm.content)
  %.099 = load i16, i16* %ref.tmp258.0516, align 512
  %.1101 = load i32, i32* %ref.tmp258.1517, align 512
  %.2103 = load i64, i64* %ref.tmp258.2518, align 512
  store i16 %.099, i16* %agg.result_code, align 512
  store i32 %.1101, i32* %agg.result_detail, align 512
  store i64 %.2103, i64* %agg.result_bad_element, align 512
  %199 = call fastcc i1 @"laya::Check::operator bool"(i16 %.099)
  br i1 %199, label %if.end262, label %cleanup359

if.end262:                                        ; preds = %if.end257
  call fastcc void @"laya::full::full_release_owner"(i16* %ref.tmp263.0510, i32* %ref.tmp263.1511, i64* %ref.tmp263.2512, i8 %markers.ref.id.val183, i8 %markers.ref.bank.val184, i32 %markers.ref.epoch.val185, i8 %markers.region.val186, i8 %markers.stage.val187, i8 %markers.layer.val188, i8 %markers.batch.val189, i8 %markers.row_space.val190, i16 %markers.row0.val191, i16 %markers.rows.val192, i16 %markers.width.val193, i8 %markers.content.val194)
  %.093 = load i16, i16* %ref.tmp263.0510, align 512
  %.195 = load i32, i32* %ref.tmp263.1511, align 512
  %.297 = load i64, i64* %ref.tmp263.2512, align 512
  store i16 %.093, i16* %agg.result_code, align 512
  store i32 %.195, i32* %agg.result_detail, align 512
  store i64 %.297, i64* %agg.result_bad_element, align 512
  %200 = call fastcc i1 @"laya::Check::operator bool"(i16 %.093)
  br i1 %200, label %if.end267, label %cleanup359

if.end267:                                        ; preds = %if.end262
  %.0.0 = load i8, i8* %marker_norm.ref.id, align 512
  %.0.1 = load i8, i8* %marker_norm.ref.bank, align 512
  %.0.2 = load i32, i32* %marker_norm.ref.epoch, align 512
  %.191 = load i8, i8* %marker_norm.region, align 512
  %.292 = load i8, i8* %marker_norm.stage, align 512
  %.3 = load i8, i8* %marker_norm.layer, align 512
  %.4 = load i8, i8* %marker_norm.batch, align 512
  %.5 = load i8, i8* %marker_norm.row_space, align 512
  %.6 = load i16, i16* %marker_norm.row0, align 512
  %.7 = load i16, i16* %marker_norm.rows, align 512
  %.8 = load i16, i16* %marker_norm.width, align 512
  %.9 = load i8, i8* %marker_norm.content, align 512
  store i8 %.0.0, i8* %scorer_baked.ref.id, align 512
  store i8 %.0.1, i8* %scorer_baked.ref.bank, align 512
  store i8 %.191, i8* %scorer_baked.region, align 512
  store i8 %.292, i8* %scorer_baked.stage, align 512
  store i8 %.3, i8* %scorer_baked.layer, align 512
  store i8 %.4, i8* %scorer_baked.batch, align 512
  store i8 %.5, i8* %scorer_baked.row_space, align 512
  store i16 %.6, i16* %scorer_baked.row0, align 512
  store i16 %.7, i16* %scorer_baked.rows, align 512
  store i16 %.8, i16* %scorer_baked.width, align 512
  store i8 %.9, i8* %scorer_baked.content, align 512
  %add = add i32 %.0.2, 1
  store i32 %add, i32* %scorer_baked.ref.epoch, align 512
  store i8 5, i8* %this_current_stage, align 512, !alias.scope !8245, !noalias !8248
  store i8 54, i8* %this_current_op, align 512, !alias.scope !8248, !noalias !8245
  call fastcc void @"laya::full::full_begin_inplace_owner"(i16* %ref.tmp269.0499, i32* %ref.tmp269.1500, i64* %ref.tmp269.2501, i8 %.0.0, i8 %.0.1, i32 %.0.2, i8 %.191, i8 %.292, i8 %.3, i8 %.4, i8 %.5, i16 %.6, i16 %.7, i16 %.8, i8 %.9, i8 %.0.0, i8 %.0.1, i32 %add, i8 %.191, i8 %.292, i8 %.3, i8 %.4, i8 %.5, i16 %.6, i16 %.7, i16 %.8, i8 %.9)
  %.085 = load i16, i16* %ref.tmp269.0499, align 512
  %.187 = load i32, i32* %ref.tmp269.1500, align 512
  %.289 = load i64, i64* %ref.tmp269.2501, align 512
  store i16 %.085, i16* %agg.result_code, align 512
  store i32 %.187, i32* %agg.result_detail, align 512
  store i64 %.289, i64* %agg.result_bad_element, align 512
  %201 = call fastcc i1 @"laya::Check::operator bool"(i16 %.085)
  br i1 %201, label %if.end273, label %cleanup358

if.end273:                                        ; preds = %if.end267
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp274.0493, i32* %ref.tmp274.1494, i64* %ref.tmp274.2495, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 54, i8 9, i8 -1, i8 %.0.0, i8 %.0.1, i32 %.0.2, i8 %.191, i8 %.292, i8 %.3, i8 %.4, i8 %.5, i16 %.6, i16 %.7, i16 %.8, i8 %.9, i8 5, i8 -1, i8 %.0.0, i8 %.0.1, i32 %add, i8 0, i8* %scorer_baked.ref.id, i8* %scorer_baked.ref.bank, i32* %scorer_baked.ref.epoch, i8* %scorer_baked.region, i8* %scorer_baked.stage, i8* %scorer_baked.layer, i8* %scorer_baked.batch, i8* %scorer_baked.row_space, i16* %scorer_baked.row0, i16* %scorer_baked.rows, i16* %scorer_baked.width, i8* %scorer_baked.content)
  %.076 = load i16, i16* %ref.tmp274.0493, align 512
  %.178 = load i32, i32* %ref.tmp274.1494, align 512
  %.280 = load i64, i64* %ref.tmp274.2495, align 512
  store i16 %.076, i16* %agg.result_code, align 512
  store i32 %.178, i32* %agg.result_detail, align 512
  store i64 %.280, i64* %agg.result_bad_element, align 512
  %202 = call fastcc i1 @"laya::Check::operator bool"(i16 %.076)
  br i1 %202, label %if.then281, label %if.end284

if.then281:                                       ; preds = %if.end273
  %scorer_baked.ref.id.val68 = load i8, i8* %scorer_baked.ref.id, align 512
  %scorer_baked.ref.bank.val69 = load i8, i8* %scorer_baked.ref.bank, align 512
  %scorer_baked.ref.epoch.val70 = load i32, i32* %scorer_baked.ref.epoch, align 512, !alias.scope !8250, !noalias !8253
  %scorer_baked.region.val71 = load i8, i8* %scorer_baked.region, align 512
  %scorer_baked.stage.val72 = load i8, i8* %scorer_baked.stage, align 512, !alias.scope !8266, !noalias !8267
  %scorer_baked.layer.val73 = load i8, i8* %scorer_baked.layer, align 512, !alias.scope !8268, !noalias !8269
  %scorer_baked.batch.val74 = load i8, i8* %scorer_baked.batch, align 512, !alias.scope !8270, !noalias !8271
  %scorer_baked.row_space.val75 = load i8, i8* %scorer_baked.row_space, align 512, !alias.scope !8272, !noalias !8273
  %scorer_baked.row0.val76 = load i16, i16* %scorer_baked.row0, align 512, !alias.scope !8274, !noalias !8275
  %scorer_baked.rows.val77 = load i16, i16* %scorer_baked.rows, align 512, !alias.scope !8276, !noalias !8277
  %scorer_baked.width.val78 = load i16, i16* %scorer_baked.width, align 512, !alias.scope !8278, !noalias !8279
  %scorer_baked.content.val79 = load i8, i8* %scorer_baked.content, align 512, !alias.scope !8280, !noalias !8281
  call fastcc void @"laya::full::full_commit_inplace_owner"(i16* %ref.tmp282.0484, i32* %ref.tmp282.1485, i64* %ref.tmp282.2486, i8 %scorer_baked.ref.id.val68, i8 %scorer_baked.ref.bank.val69, i32 %scorer_baked.ref.epoch.val70, i8 %scorer_baked.region.val71, i8 %scorer_baked.stage.val72, i8 %scorer_baked.layer.val73, i8 %scorer_baked.batch.val74, i8 %scorer_baked.row_space.val75, i16 %scorer_baked.row0.val76, i16 %scorer_baked.rows.val77, i16 %scorer_baked.width.val78, i8 %scorer_baked.content.val79)
  %.070 = load i16, i16* %ref.tmp282.0484, align 512
  %.172 = load i32, i32* %ref.tmp282.1485, align 512
  %.274 = load i64, i64* %ref.tmp282.2486, align 512
  store i16 %.070, i16* %agg.result_code, align 512
  store i32 %.172, i32* %agg.result_detail, align 512
  store i64 %.274, i64* %agg.result_bad_element, align 512
  br label %if.end284

if.end284:                                        ; preds = %if.then281, %if.end273
  %agg.result_code.val13 = phi i16 [ %.070, %if.then281 ], [ %.076, %if.end273 ]
  %203 = call fastcc i1 @"laya::Check::operator bool"(i16 %agg.result_code.val13)
  br i1 %203, label %if.end290, label %if.then286

if.then286:                                       ; preds = %if.end284
  %.067 = load i8, i8* %scorer_baked.ref.id, align 512
  %.168 = load i8, i8* %scorer_baked.ref.bank, align 512
  %.269 = load i32, i32* %scorer_baked.ref.epoch, align 512
  %204 = load i8, i8* %scorer_baked.region, align 512
  call fastcc void @"laya::full::full_invalidate_owner"(i16* %tmp.0, i32* %tmp.1, i64* %tmp.2, i8 %.067, i8 %.168, i32 %.269, i8 %204)
  br label %cleanup358

if.end290:                                        ; preds = %if.end284
  br label %arrayinit.body.i

arrayinit.body.i:                                 ; preds = %arrayinit.body.i, %if.end290
  %arrayinit.curidx.i = phi i64 [ 0, %if.end290 ], [ %arrayinit.nextidx.i, %arrayinit.body.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %arrayinit.cur1.i = getelementptr [48 x i8], [48 x i8]* %scorer_bias.name, i64 0, i64 %arrayinit.curidx.i
  %arrayinit.nextidx.i = add nuw nsw i64 %arrayinit.curidx.i, 1
  store i8 0, i8* %arrayinit.cur1.i, align 1, !alias.scope !8282, !noalias !8285
  %arrayinit.done.i = icmp eq i64 %arrayinit.curidx.i, 47
  br i1 %arrayinit.done.i, label %arrayinit.end.i, label %arrayinit.body.i, !llvm.loop !8296

arrayinit.end.i:                                  ; preds = %arrayinit.body.i
  store i8 0, i8* %scorer_bias.ggml_type_id, align 512, !alias.scope !8298, !noalias !8299
  store i8 -1, i8* %scorer_bias.bo, align 512, !alias.scope !8300, !noalias !8301
  store i8 0, i8* %scorer_bias.omitted, align 512, !alias.scope !8302, !noalias !8303
  store i8 0, i8* %scorer_bias.reserved, align 512, !alias.scope !8304, !noalias !8305
  br label %arrayinit.body3.i

arrayinit.body3.i:                                ; preds = %arrayinit.body3.i, %arrayinit.end.i
  %arrayinit.curidx4.i = phi i64 [ 0, %arrayinit.end.i ], [ %arrayinit.nextidx6.i, %arrayinit.body3.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !33
  %arrayinit.cur52.i = getelementptr [4 x i32], [4 x i32]* %scorer_bias.ne, i64 0, i64 %arrayinit.curidx4.i
  %arrayinit.nextidx6.i = add nuw nsw i64 %arrayinit.curidx4.i, 1
  store i32 0, i32* %arrayinit.cur52.i, align 4, !alias.scope !8306, !noalias !8307
  %arrayinit.done7.i = icmp eq i64 %arrayinit.curidx4.i, 3
  br i1 %arrayinit.done7.i, label %arrayinit.end8.i, label %arrayinit.body3.i, !llvm.loop !8308

arrayinit.end8.i:                                 ; preds = %arrayinit.body3.i
  store i32 0, i32* %scorer_bias.source_offset, align 512, !alias.scope !8309, !noalias !8310
  store i32 0, i32* %scorer_bias.source_bytes, align 512, !alias.scope !8311, !noalias !8312
  store i32 0, i32* %scorer_bias.base, align 512, !alias.scope !8313, !noalias !8314
  store i32 0, i32* %scorer_bias.span, align 512, !alias.scope !8315, !noalias !8316
  br label %arrayinit.body10.i

arrayinit.body10.i:                               ; preds = %arrayinit.body10.i, %arrayinit.end8.i
  %arrayinit.curidx11.i = phi i64 [ 0, %arrayinit.end8.i ], [ %arrayinit.nextidx13.i, %arrayinit.body10.i ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur123.i = getelementptr [32 x i8], [32 x i8]* %scorer_bias.source_sha256, i64 0, i64 %arrayinit.curidx11.i
  %arrayinit.nextidx13.i = add nuw nsw i64 %arrayinit.curidx11.i, 1
  store i8 0, i8* %arrayinit.cur123.i, align 1, !alias.scope !8317, !noalias !8318
  %arrayinit.done14.i = icmp eq i64 %arrayinit.curidx11.i, 31
  br i1 %arrayinit.done14.i, label %_ZN4laya4full20FullTensorDescriptorC2Ev.exit, label %arrayinit.body10.i, !llvm.loop !8319

_ZN4laya4full20FullTensorDescriptorC2Ev.exit:     ; preds = %arrayinit.body10.i
  store i16 -1, i16* %scorer_bias_id, align 512
  call fastcc void @"laya::full::full_lookup_tensor_indexed"(i16* %ref.tmp291.0465, i32* %ref.tmp291.1466, i64* %ref.tmp291.2467, [48 x i8]* %scorer_bias.name, i8* %scorer_bias.ggml_type_id, i8* %scorer_bias.bo, i8* %scorer_bias.omitted, i8* %scorer_bias.reserved, [4 x i32]* %scorer_bias.ne, i32* %scorer_bias.source_offset, i32* %scorer_bias.source_bytes, i32* %scorer_bias.base, i32* %scorer_bias.span, [32 x i8]* %scorer_bias.source_sha256, i16* %scorer_bias_id)
  %.061 = load i16, i16* %ref.tmp291.0465, align 512
  %.163 = load i32, i32* %ref.tmp291.1466, align 512
  %.265 = load i64, i64* %ref.tmp291.2467, align 512
  store i16 %.061, i16* %agg.result_code, align 512
  store i32 %.163, i32* %agg.result_detail, align 512
  store i64 %.265, i64* %agg.result_bad_element, align 512
  %205 = call fastcc i1 @"laya::Check::operator bool"(i16 %.061)
  br i1 %205, label %if.end294, label %cleanup356

if.end294:                                        ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.exit
  store i8 0, i8* %scorer_hidden.ref.id, align 512, !alias.scope !8320, !noalias !8325
  store i8 0, i8* %scorer_hidden.ref.bank, align 512, !alias.scope !8339, !noalias !8340
  store i32 0, i32* %scorer_hidden.ref.epoch, align 512, !alias.scope !8341, !noalias !8342
  store i8 0, i8* %scorer_hidden.region, align 512, !alias.scope !8343, !noalias !8344
  store i8 0, i8* %scorer_hidden.stage, align 512, !alias.scope !8345, !noalias !8346
  store i8 -1, i8* %scorer_hidden.layer, align 512, !alias.scope !8347, !noalias !8348
  store i8 -1, i8* %scorer_hidden.batch, align 512, !alias.scope !8349, !noalias !8350
  store i8 0, i8* %scorer_hidden.row_space, align 512, !alias.scope !8351, !noalias !8352
  store i16 0, i16* %scorer_hidden.row0, align 512, !alias.scope !8353, !noalias !8354
  store i16 0, i16* %scorer_hidden.rows, align 512, !alias.scope !8355, !noalias !8356
  store i16 0, i16* %scorer_hidden.width, align 512, !alias.scope !8357, !noalias !8358
  store i8 0, i8* %scorer_hidden.content, align 512, !alias.scope !8359, !noalias !8360
  %206 = load i16, i16* %scorer_bias_id, align 512
  %scorer_baked.ref.id.val171 = load i8, i8* %scorer_baked.ref.id, align 512
  %scorer_baked.ref.bank.val172 = load i8, i8* %scorer_baked.ref.bank, align 512
  %scorer_baked.ref.epoch.val173 = load i32, i32* %scorer_baked.ref.epoch, align 512
  %scorer_baked.region.val174 = load i8, i8* %scorer_baked.region, align 512
  %scorer_baked.stage.val175 = load i8, i8* %scorer_baked.stage, align 512
  %scorer_baked.layer.val176 = load i8, i8* %scorer_baked.layer, align 512
  %scorer_baked.batch.val177 = load i8, i8* %scorer_baked.batch, align 512
  %scorer_baked.row_space.val178 = load i8, i8* %scorer_baked.row_space, align 512
  %scorer_baked.row0.val179 = load i16, i16* %scorer_baked.row0, align 512
  %scorer_baked.rows.val180 = load i16, i16* %scorer_baked.rows, align 512
  %scorer_baked.width.val181 = load i16, i16* %scorer_baked.width, align 512
  %scorer_baked.content.val182 = load i8, i8* %scorer_baked.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::transform"(i16* %ref.tmp295.0454, i32* %ref.tmp295.1455, i64* %ref.tmp295.2456, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 100, i8 %scorer_baked.ref.id.val171, i8 %scorer_baked.ref.bank.val172, i32 %scorer_baked.ref.epoch.val173, i8 %scorer_baked.region.val174, i8 %scorer_baked.stage.val175, i8 %scorer_baked.layer.val176, i8 %scorer_baked.batch.val177, i8 %scorer_baked.row_space.val178, i16 %scorer_baked.row0.val179, i16 %scorer_baked.rows.val180, i16 %scorer_baked.width.val181, i8 %scorer_baked.content.val182, i16 1024, i16 %206, i8* %scorer_hidden.ref.id, i8* %scorer_hidden.ref.bank, i32* %scorer_hidden.ref.epoch, i8* %scorer_hidden.region, i8* %scorer_hidden.stage, i8* %scorer_hidden.layer, i8* %scorer_hidden.batch, i8* %scorer_hidden.row_space, i16* %scorer_hidden.row0, i16* %scorer_hidden.rows, i16* %scorer_hidden.width, i8* %scorer_hidden.content)
  %.055 = load i16, i16* %ref.tmp295.0454, align 512
  %.157 = load i32, i32* %ref.tmp295.1455, align 512
  %.259 = load i64, i64* %ref.tmp295.2456, align 512
  store i16 %.055, i16* %agg.result_code, align 512
  store i32 %.157, i32* %agg.result_detail, align 512
  store i64 %.259, i64* %agg.result_bad_element, align 512
  %207 = call fastcc i1 @"laya::Check::operator bool"(i16 %.055)
  br i1 %207, label %if.end298, label %cleanup355

if.end298:                                        ; preds = %if.end294
  store i8 0, i8* %raw.ref.id, align 512, !alias.scope !8361, !noalias !8366
  store i8 0, i8* %raw.ref.bank, align 512, !alias.scope !8380, !noalias !8381
  store i32 0, i32* %raw.ref.epoch, align 512, !alias.scope !8382, !noalias !8383
  store i8 0, i8* %raw.region, align 512, !alias.scope !8384, !noalias !8385
  store i8 0, i8* %raw.stage, align 512, !alias.scope !8386, !noalias !8387
  store i8 -1, i8* %raw.layer, align 512, !alias.scope !8388, !noalias !8389
  store i8 -1, i8* %raw.batch, align 512, !alias.scope !8390, !noalias !8391
  store i8 0, i8* %raw.row_space, align 512, !alias.scope !8392, !noalias !8393
  store i16 0, i16* %raw.row0, align 512, !alias.scope !8394, !noalias !8395
  store i16 0, i16* %raw.rows, align 512, !alias.scope !8396, !noalias !8397
  store i16 0, i16* %raw.width, align 512, !alias.scope !8398, !noalias !8399
  store i8 0, i8* %raw.content, align 512, !alias.scope !8400, !noalias !8401
  %208 = load i8, i8* %scorer_hidden.region, align 512
  %scorer_hidden.ref.id.val = load i8, i8* %scorer_hidden.ref.id, align 512
  %scorer_hidden.ref.bank.val = load i8, i8* %scorer_hidden.ref.bank, align 512
  %scorer_hidden.ref.epoch.val = load i32, i32* %scorer_hidden.ref.epoch, align 512
  %scorer_hidden.stage.val = load i8, i8* %scorer_hidden.stage, align 512, !alias.scope !8402, !noalias !8407
  %scorer_hidden.layer.val = load i8, i8* %scorer_hidden.layer, align 512
  %scorer_hidden.batch.val = load i8, i8* %scorer_hidden.batch, align 512, !alias.scope !8438, !noalias !8439
  %scorer_hidden.row_space.val = load i8, i8* %scorer_hidden.row_space, align 512
  %scorer_hidden.row0.val = load i16, i16* %scorer_hidden.row0, align 512, !alias.scope !8440, !noalias !8441
  %scorer_hidden.rows.val = load i16, i16* %scorer_hidden.rows, align 512
  %scorer_hidden.width.val = load i16, i16* %scorer_hidden.width, align 512, !alias.scope !8442, !noalias !8443
  %scorer_hidden.content.val = load i8, i8* %scorer_hidden.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fp_linear"(i16* %ref.tmp299.0443, i32* %ref.tmp299.1444, i64* %ref.tmp299.2445, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 83, i8 10, i8 %scorer_hidden.ref.id.val, i8 %scorer_hidden.ref.bank.val, i32 %scorer_hidden.ref.epoch.val, i8 %208, i8 %scorer_hidden.stage.val, i8 %scorer_hidden.layer.val, i8 %scorer_hidden.batch.val, i8 %scorer_hidden.row_space.val, i16 %scorer_hidden.row0.val, i16 %scorer_hidden.rows.val, i16 %scorer_hidden.width.val, i8 %scorer_hidden.content.val, i8 5, i8 %208, i8 7, i16 1024, i16 1, i8* %raw.ref.id, i8* %raw.ref.bank, i32* %raw.ref.epoch, i8* %raw.region, i8* %raw.stage, i8* %raw.layer, i8* %raw.batch, i8* %raw.row_space, i16* %raw.row0, i16* %raw.rows, i16* %raw.width, i8* %raw.content)
  %.049 = load i16, i16* %ref.tmp299.0443, align 512
  %.151 = load i32, i32* %ref.tmp299.1444, align 512
  %.253 = load i64, i64* %ref.tmp299.2445, align 512
  store i16 %.049, i16* %agg.result_code, align 512
  store i32 %.151, i32* %agg.result_detail, align 512
  store i64 %.253, i64* %agg.result_bad_element, align 512
  %209 = call fastcc i1 @"laya::Check::operator bool"(i16 %.049)
  br i1 %209, label %if.end306, label %cleanup354

if.end306:                                        ; preds = %if.end298
  br label %for.body.i.i

for.cond.i.i:                                     ; preds = %cleanup.i.i.critedge, %if.end18.i.i.i, %if.end.i.i.i
  br label %for.body.i.i, !llvm.loop !8444

for.body.i.i:                                     ; preds = %for.cond.i.i, %if.end306
  %indvars.iv.i.i = phi i64 [ 0, %if.end306 ], [ %indvars.iv.next.i.i, %for.cond.i.i ]
  %cmp.i.i5 = icmp ult i64 %indvars.iv.i.i, 32
  br i1 %cmp.i.i5, label %for.body.i.i.split, label %cleanup7.i.i.loopexit, !llvm.loop !8444

for.body.i.i.split:                               ; preds = %for.body.i.i
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 0, i64 32, i64 16), !fpga.pragma.source !33
  call void (...) @_ssdm_op_SpecLoopName([16 x i8]* @123)
  %id21.i.i.i45 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.id", i64 0, i64 %indvars.iv.i.i
  %210 = load i8, i8* %id21.i.i.i45, align 8, !alias.scope !8452, !noalias !8459
  %cmp.i.i.i = icmp eq i8 %210, 0
  %indvars.iv.next.i.i = add nuw nsw i64 %indvars.iv.i.i, 1
  br i1 %cmp.i.i.i, label %cleanup.i.i.critedge, label %lor.lhs.false.i.i.i

lor.lhs.false.i.i.i:                              ; preds = %for.body.i.i.split
  %region3.i.i.i46 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.region", i64 0, i64 %indvars.iv.i.i
  %211 = load i8, i8* %region3.i.i.i46, align 4, !alias.scope !8452, !noalias !8459
  %cmp5.i.i.i = icmp ne i8 %211, 3
  br i1 %cmp5.i.i.i, label %cleanup.i.i.critedge, label %if.end.i.i.i

if.end.i.i.i:                                     ; preds = %lor.lhs.false.i.i.i
  %bank132.i.i.i47 = getelementptr [32 x i8], [32 x i8]* @"(anonymous namespace)::runtime.owners.record.ref.bank", i64 0, i64 %indvars.iv.i.i
  %212 = load i8, i8* %bank132.i.i.i47, align 1, !alias.scope !8452, !noalias !8459
  %cmp16.i.i.i = icmp ne i8 %212, 0
  br i1 %cmp16.i.i.i, label %for.cond.i.i, label %if.end18.i.i.i

if.end18.i.i.i:                                   ; preds = %if.end.i.i.i
  %cmp21.i.i.i = icmp eq i8 %210, 10
  %spec.select = select i1 %cmp21.i.i.i, i1 true, i1 false
  br i1 %spec.select, label %cleanup.i.i, label %for.cond.i.i

cleanup.i.i.critedge:                             ; preds = %lor.lhs.false.i.i.i, %for.body.i.i.split
  br label %for.cond.i.i

cleanup.i.i:                                      ; preds = %if.end18.i.i.i
  %max_claimed_epoch3.i.i = getelementptr [32 x i32], [32 x i32]* @"(anonymous namespace)::runtime.owners.record.max_claimed_epoch", i64 0, i64 %indvars.iv.i.i
  %213 = load i32, i32* %max_claimed_epoch3.i.i, align 8, !alias.scope !8521, !noalias !8459
  %cmp5.i.i = icmp ult i32 %213, -2
  %add.i.i = add i32 %213, 1
  %spec.select.i.i = select i1 %cmp5.i.i, i32 %add.i.i, i32 0
  br label %cleanup7.i.i

cleanup7.i.i.loopexit:                            ; preds = %for.body.i.i
  br label %cleanup7.i.i

cleanup7.i.i:                                     ; preds = %cleanup7.i.i.loopexit, %cleanup.i.i
  %agg.tmp.2.i.153 = phi i32 [ %spec.select.i.i, %cleanup.i.i ], [ undef, %cleanup7.i.i.loopexit ]
  %cleanup.dest.slot.1.i.i = phi i32 [ 1, %cleanup.i.i ], [ 3, %cleanup7.i.i.loopexit ]
  %cleanup.dest.slot.1.off.i.i = add nsw i32 %cleanup.dest.slot.1.i.i, -3
  %switch.i.i = icmp ult i32 %cleanup.dest.slot.1.off.i.i, 1
  %spec.select49 = select i1 %switch.i.i, i32 1, i32 %agg.tmp.2.i.153
  %raw.ref.id.val = load i8, i8* %raw.ref.id, align 512
  %raw.ref.bank.val = load i8, i8* %raw.ref.bank, align 512
  %raw.ref.epoch.val = load i32, i32* %raw.ref.epoch, align 512
  %raw.region.val = load i8, i8* %raw.region, align 512
  %raw.stage.val = load i8, i8* %raw.stage, align 512, !alias.scope !7657, !noalias !7662
  %raw.layer.val = load i8, i8* %raw.layer, align 512
  %raw.batch.val = load i8, i8* %raw.batch, align 512, !alias.scope !7693, !noalias !7694
  %raw.row_space.val = load i8, i8* %raw.row_space, align 512
  %raw.row0.val = load i16, i16* %raw.row0, align 512, !alias.scope !7695, !noalias !7696
  %raw.rows.val = load i16, i16* %raw.rows, align 512, !alias.scope !7697, !noalias !7698
  %raw.width.val = load i16, i16* %raw.width, align 512, !alias.scope !7699, !noalias !7700
  %raw.content.val = load i8, i8* %raw.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::vector"(i16* %ref.tmp307.0437, i32* %ref.tmp307.1438, i64* %ref.tmp307.2439, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 102, i8 %raw.ref.id.val, i8 %raw.ref.bank.val, i32 %raw.ref.epoch.val, i8 %raw.region.val, i8 %raw.stage.val, i8 %raw.layer.val, i8 %raw.batch.val, i8 %raw.row_space.val, i16 %raw.row0.val, i16 %raw.rows.val, i16 %raw.width.val, i8 %raw.content.val, i8 5, i8 -1, i8 10, i8 0, i32 %spec.select49, i8 3, i16 16, i8* %candidate_ref_id, i8* %candidate_ref_bank, i32* %candidate_ref_epoch, i8* %candidate_region, i8* %candidate_stage, i8* %candidate_layer, i8* %candidate_batch, i8* %candidate_row_space, i16* %candidate_row0, i16* %candidate_rows, i16* %candidate_width, i8* %candidate_content)
  %.043 = load i16, i16* %ref.tmp307.0437, align 512
  %.145 = load i32, i32* %ref.tmp307.1438, align 512
  %.247 = load i64, i64* %ref.tmp307.2439, align 512
  store i16 %.043, i16* %agg.result_code, align 512
  store i32 %.145, i32* %agg.result_detail, align 512
  store i64 %.247, i64* %agg.result_bad_element, align 512
  %214 = call fastcc i1 @"laya::Check::operator bool"(i16 %.043)
  br i1 %214, label %if.end310, label %cleanup354

if.end310:                                        ; preds = %cleanup7.i.i
  store i8 0, i8* %prob.ref.id, align 512, !alias.scope !8522, !noalias !8527
  store i8 0, i8* %prob.ref.bank, align 512, !alias.scope !8541, !noalias !8542
  store i32 0, i32* %prob.ref.epoch, align 512, !alias.scope !8543, !noalias !8544
  store i8 0, i8* %prob.region, align 512, !alias.scope !8545, !noalias !8546
  store i8 0, i8* %prob.stage, align 512, !alias.scope !8547, !noalias !8548
  store i8 -1, i8* %prob.layer, align 512, !alias.scope !8549, !noalias !8550
  store i8 -1, i8* %prob.batch, align 512, !alias.scope !8551, !noalias !8552
  store i8 0, i8* %prob.row_space, align 512, !alias.scope !8553, !noalias !8554
  store i16 0, i16* %prob.row0, align 512, !alias.scope !8555, !noalias !8556
  store i16 0, i16* %prob.rows, align 512, !alias.scope !8557, !noalias !8558
  store i16 0, i16* %prob.width, align 512, !alias.scope !8559, !noalias !8560
  store i8 0, i8* %prob.content, align 512, !alias.scope !8561, !noalias !8562
  %candidate_ref_id.val = load i8, i8* %candidate_ref_id, align 512
  %candidate_ref_bank.val = load i8, i8* %candidate_ref_bank, align 512
  %candidate_ref_epoch.val = load i32, i32* %candidate_ref_epoch, align 512
  %candidate_region.val = load i8, i8* %candidate_region, align 512
  %candidate_stage.val = load i8, i8* %candidate_stage, align 512, !alias.scope !8563, !noalias !8568
  %candidate_layer.val = load i8, i8* %candidate_layer, align 512
  %candidate_batch.val = load i8, i8* %candidate_batch, align 512, !alias.scope !8599, !noalias !8600
  %candidate_row_space.val = load i8, i8* %candidate_row_space, align 512, !alias.scope !8601, !noalias !8602
  %candidate_row0.val = load i16, i16* %candidate_row0, align 512, !alias.scope !8603, !noalias !8604
  %candidate_rows.val = load i16, i16* %candidate_rows, align 512, !alias.scope !8605, !noalias !8606
  %candidate_width.val = load i16, i16* %candidate_width, align 512, !alias.scope !8607, !noalias !8608
  %candidate_content.val = load i8, i8* %candidate_content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::candidate_probability"(i16* %ref.tmp311.0426, i32* %ref.tmp311.1427, i64* %ref.tmp311.2428, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %candidate_ref_id.val, i8 %candidate_ref_bank.val, i32 %candidate_ref_epoch.val, i8 %candidate_region.val, i8 %candidate_stage.val, i8 %candidate_layer.val, i8 %candidate_batch.val, i8 %candidate_row_space.val, i16 %candidate_row0.val, i16 %candidate_rows.val, i16 %candidate_width.val, i8 %candidate_content.val, i8* %prob.ref.id, i8* %prob.ref.bank, i32* %prob.ref.epoch, i8* %prob.region, i8* %prob.stage, i8* %prob.layer, i8* %prob.batch, i8* %prob.row_space, i16* %prob.row0, i16* %prob.rows, i16* %prob.width, i8* %prob.content)
  %.037 = load i16, i16* %ref.tmp311.0426, align 512
  %.139 = load i32, i32* %ref.tmp311.1427, align 512
  %.241 = load i64, i64* %ref.tmp311.2428, align 512
  store i16 %.037, i16* %agg.result_code, align 512
  store i32 %.139, i32* %agg.result_detail, align 512
  store i64 %.241, i64* %agg.result_bad_element, align 512
  %215 = call fastcc i1 @"laya::Check::operator bool"(i16 %.037)
  br i1 %215, label %if.end314, label %cleanup353

if.end314:                                        ; preds = %if.end310
  store i8 0, i8* %stats.ref.id, align 512, !alias.scope !8609, !noalias !8614
  store i8 0, i8* %stats.ref.bank, align 512, !alias.scope !8628, !noalias !8629
  store i32 0, i32* %stats.ref.epoch, align 512, !alias.scope !8630, !noalias !8631
  store i8 0, i8* %stats.region, align 512, !alias.scope !8632, !noalias !8633
  store i8 0, i8* %stats.stage, align 512, !alias.scope !8634, !noalias !8635
  store i8 -1, i8* %stats.layer, align 512, !alias.scope !8636, !noalias !8637
  store i8 -1, i8* %stats.batch, align 512, !alias.scope !8638, !noalias !8639
  store i8 0, i8* %stats.row_space, align 512, !alias.scope !8640, !noalias !8641
  store i16 0, i16* %stats.row0, align 512, !alias.scope !8642, !noalias !8643
  store i16 0, i16* %stats.rows, align 512, !alias.scope !8644, !noalias !8645
  store i16 0, i16* %stats.width, align 512, !alias.scope !8646, !noalias !8647
  store i8 0, i8* %stats.content, align 512, !alias.scope !8648, !noalias !8649
  %prob.ref.id.val = load i8, i8* %prob.ref.id, align 512
  %prob.ref.bank.val = load i8, i8* %prob.ref.bank, align 512
  %prob.ref.epoch.val = load i32, i32* %prob.ref.epoch, align 512
  %prob.region.val = load i8, i8* %prob.region, align 512
  %prob.stage.val = load i8, i8* %prob.stage, align 512, !alias.scope !8650, !noalias !8655
  %prob.layer.val = load i8, i8* %prob.layer, align 512
  %prob.batch.val = load i8, i8* %prob.batch, align 512, !alias.scope !8686, !noalias !8687
  %prob.row_space.val = load i8, i8* %prob.row_space, align 512, !alias.scope !8688, !noalias !8689
  %prob.row0.val = load i16, i16* %prob.row0, align 512, !alias.scope !8690, !noalias !8691
  %prob.rows.val = load i16, i16* %prob.rows, align 512, !alias.scope !8692, !noalias !8693
  %prob.width.val = load i16, i16* %prob.width, align 512, !alias.scope !8694, !noalias !8695
  %prob.content.val = load i8, i8* %prob.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::candidate_statistics"(i16* %ref.tmp315.0415, i32* %ref.tmp315.1416, i64* %ref.tmp315.2417, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 %prob.ref.id.val, i8 %prob.ref.bank.val, i32 %prob.ref.epoch.val, i8 %prob.region.val, i8 %prob.stage.val, i8 %prob.layer.val, i8 %prob.batch.val, i8 %prob.row_space.val, i16 %prob.row0.val, i16 %prob.rows.val, i16 %prob.width.val, i8 %prob.content.val, i8* %stats.ref.id, i8* %stats.ref.bank, i32* %stats.ref.epoch, i8* %stats.region, i8* %stats.stage, i8* %stats.layer, i8* %stats.batch, i8* %stats.row_space, i16* %stats.row0, i16* %stats.rows, i16* %stats.width, i8* %stats.content)
  %.031 = load i16, i16* %ref.tmp315.0415, align 512
  %.133 = load i32, i32* %ref.tmp315.1416, align 512
  %.235 = load i64, i64* %ref.tmp315.2417, align 512
  store i16 %.031, i16* %agg.result_code, align 512
  store i32 %.133, i32* %agg.result_detail, align 512
  store i64 %.235, i64* %agg.result_bad_element, align 512
  %216 = call fastcc i1 @"laya::Check::operator bool"(i16 %.031)
  br i1 %216, label %if.end318, label %cleanup352

if.end318:                                        ; preds = %if.end314
  store i8 0, i8* %act_input.ref.id, align 512, !alias.scope !8696, !noalias !8701
  store i8 0, i8* %act_input.ref.bank, align 512, !alias.scope !8715, !noalias !8716
  store i32 0, i32* %act_input.ref.epoch, align 512, !alias.scope !8717, !noalias !8718
  store i8 0, i8* %act_input.region, align 512, !alias.scope !8719, !noalias !8720
  store i8 0, i8* %act_input.stage, align 512, !alias.scope !8721, !noalias !8722
  store i8 -1, i8* %act_input.layer, align 512, !alias.scope !8723, !noalias !8724
  store i8 -1, i8* %act_input.batch, align 512, !alias.scope !8725, !noalias !8726
  store i8 0, i8* %act_input.row_space, align 512, !alias.scope !8727, !noalias !8728
  store i16 0, i16* %act_input.row0, align 512, !alias.scope !8729, !noalias !8730
  store i16 0, i16* %act_input.rows, align 512, !alias.scope !8731, !noalias !8732
  store i16 0, i16* %act_input.width, align 512, !alias.scope !8733, !noalias !8734
  store i8 0, i8* %act_input.content, align 512, !alias.scope !8735, !noalias !8736
  %stats.ref.id.val = load i8, i8* %stats.ref.id, align 512
  %stats.ref.bank.val = load i8, i8* %stats.ref.bank, align 512
  %stats.ref.epoch.val = load i32, i32* %stats.ref.epoch, align 512
  %stats.region.val = load i8, i8* %stats.region, align 512
  %stats.stage.val = load i8, i8* %stats.stage, align 512, !alias.scope !8737, !noalias !8742
  %stats.layer.val = load i8, i8* %stats.layer, align 512
  %stats.batch.val = load i8, i8* %stats.batch, align 512, !alias.scope !8773, !noalias !8774
  %stats.row_space.val = load i8, i8* %stats.row_space, align 512, !alias.scope !8775, !noalias !8776
  %stats.row0.val = load i16, i16* %stats.row0, align 512, !alias.scope !8777, !noalias !8778
  %stats.rows.val = load i16, i16* %stats.rows, align 512, !alias.scope !8779, !noalias !8780
  %stats.width.val = load i16, i16* %stats.width, align 512, !alias.scope !8781, !noalias !8782
  %stats.content.val = load i8, i8* %stats.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::act_concat"(i16* %ref.tmp319.0404, i32* %ref.tmp319.1405, i64* %ref.tmp319.2406, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, [23 x i192]* %hidden, i8 %stats.ref.id.val, i8 %stats.ref.bank.val, i32 %stats.ref.epoch.val, i8 %stats.region.val, i8 %stats.stage.val, i8 %stats.layer.val, i8 %stats.batch.val, i8 %stats.row_space.val, i16 %stats.row0.val, i16 %stats.rows.val, i16 %stats.width.val, i8 %stats.content.val, i8* %act_input.ref.id, i8* %act_input.ref.bank, i32* %act_input.ref.epoch, i8* %act_input.region, i8* %act_input.stage, i8* %act_input.layer, i8* %act_input.batch, i8* %act_input.row_space, i16* %act_input.row0, i16* %act_input.rows, i16* %act_input.width, i8* %act_input.content)
  %.025 = load i16, i16* %ref.tmp319.0404, align 512
  %.127 = load i32, i32* %ref.tmp319.1405, align 512
  %.229 = load i64, i64* %ref.tmp319.2406, align 512
  store i16 %.025, i16* %agg.result_code, align 512
  store i32 %.127, i32* %agg.result_detail, align 512
  store i64 %.229, i64* %agg.result_bad_element, align 512
  %217 = call fastcc i1 @"laya::Check::operator bool"(i16 %.025)
  br i1 %217, label %if.end322, label %cleanup351

if.end322:                                        ; preds = %if.end318
  store i8 0, i8* %act_dot.ref.id, align 512, !alias.scope !8783, !noalias !8788
  store i8 0, i8* %act_dot.ref.bank, align 512, !alias.scope !8802, !noalias !8803
  store i32 0, i32* %act_dot.ref.epoch, align 512, !alias.scope !8804, !noalias !8805
  store i8 0, i8* %act_dot.region, align 512, !alias.scope !8806, !noalias !8807
  store i8 0, i8* %act_dot.stage, align 512, !alias.scope !8808, !noalias !8809
  store i8 -1, i8* %act_dot.layer, align 512, !alias.scope !8810, !noalias !8811
  store i8 -1, i8* %act_dot.batch, align 512, !alias.scope !8812, !noalias !8813
  store i8 0, i8* %act_dot.row_space, align 512, !alias.scope !8814, !noalias !8815
  store i16 0, i16* %act_dot.row0, align 512, !alias.scope !8816, !noalias !8817
  store i16 0, i16* %act_dot.rows, align 512, !alias.scope !8818, !noalias !8819
  store i16 0, i16* %act_dot.width, align 512, !alias.scope !8820, !noalias !8821
  store i8 0, i8* %act_dot.content, align 512, !alias.scope !8822, !noalias !8823
  %218 = load i8, i8* %act_input.region, align 512
  %act_input.ref.id.val = load i8, i8* %act_input.ref.id, align 512
  %act_input.ref.bank.val = load i8, i8* %act_input.ref.bank, align 512
  %act_input.ref.epoch.val = load i32, i32* %act_input.ref.epoch, align 512
  %act_input.stage.val = load i8, i8* %act_input.stage, align 512, !alias.scope !8402, !noalias !8407
  %act_input.layer.val = load i8, i8* %act_input.layer, align 512
  %act_input.batch.val = load i8, i8* %act_input.batch, align 512, !alias.scope !8438, !noalias !8439
  %act_input.row_space.val = load i8, i8* %act_input.row_space, align 512
  %act_input.row0.val = load i16, i16* %act_input.row0, align 512, !alias.scope !8440, !noalias !8441
  %act_input.rows.val = load i16, i16* %act_input.rows, align 512
  %act_input.width.val = load i16, i16* %act_input.width, align 512, !alias.scope !8442, !noalias !8443
  %act_input.content.val = load i8, i8* %act_input.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fp_linear"(i16* %ref.tmp323.0393, i32* %ref.tmp323.1394, i64* %ref.tmp323.2395, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 84, i8 11, i8 %act_input.ref.id.val, i8 %act_input.ref.bank.val, i32 %act_input.ref.epoch.val, i8 %218, i8 %act_input.stage.val, i8 %act_input.layer.val, i8 %act_input.batch.val, i8 %act_input.row_space.val, i16 %act_input.row0.val, i16 %act_input.rows.val, i16 %act_input.width.val, i8 %act_input.content.val, i8 6, i8 %218, i8 2, i16 1028, i16 256, i8* %act_dot.ref.id, i8* %act_dot.ref.bank, i32* %act_dot.ref.epoch, i8* %act_dot.region, i8* %act_dot.stage, i8* %act_dot.layer, i8* %act_dot.batch, i8* %act_dot.row_space, i16* %act_dot.row0, i16* %act_dot.rows, i16* %act_dot.width, i8* %act_dot.content)
  %.019 = load i16, i16* %ref.tmp323.0393, align 512
  %.121 = load i32, i32* %ref.tmp323.1394, align 512
  %.223 = load i64, i64* %ref.tmp323.2395, align 512
  store i16 %.019, i16* %agg.result_code, align 512
  store i32 %.121, i32* %agg.result_detail, align 512
  store i64 %.223, i64* %agg.result_bad_element, align 512
  %219 = call fastcc i1 @"laya::Check::operator bool"(i16 %.019)
  br i1 %219, label %if.end330, label %cleanup350

if.end330:                                        ; preds = %if.end322
  br label %arrayinit.body.i25

arrayinit.body.i25:                               ; preds = %arrayinit.body.i25, %if.end330
  %arrayinit.curidx.i21 = phi i64 [ 0, %if.end330 ], [ %arrayinit.nextidx.i23, %arrayinit.body.i25 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 48, i64 48, i64 48), !fpga.pragma.source !33
  %arrayinit.cur1.i22 = getelementptr [48 x i8], [48 x i8]* %act_bias.name, i64 0, i64 %arrayinit.curidx.i21
  %arrayinit.nextidx.i23 = add nuw nsw i64 %arrayinit.curidx.i21, 1
  store i8 0, i8* %arrayinit.cur1.i22, align 1, !alias.scope !8824, !noalias !8827
  %arrayinit.done.i24 = icmp eq i64 %arrayinit.curidx.i21, 47
  br i1 %arrayinit.done.i24, label %arrayinit.end.i26, label %arrayinit.body.i25, !llvm.loop !8838

arrayinit.end.i26:                                ; preds = %arrayinit.body.i25
  store i8 0, i8* %act_bias.ggml_type_id, align 512, !alias.scope !8839, !noalias !8840
  store i8 -1, i8* %act_bias.bo, align 512, !alias.scope !8841, !noalias !8842
  store i8 0, i8* %act_bias.omitted, align 512, !alias.scope !8843, !noalias !8844
  store i8 0, i8* %act_bias.reserved, align 512, !alias.scope !8845, !noalias !8846
  br label %arrayinit.body3.i31

arrayinit.body3.i31:                              ; preds = %arrayinit.body3.i31, %arrayinit.end.i26
  %arrayinit.curidx4.i27 = phi i64 [ 0, %arrayinit.end.i26 ], [ %arrayinit.nextidx6.i29, %arrayinit.body3.i31 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 4, i64 4, i64 4), !fpga.pragma.source !33
  %arrayinit.cur52.i28 = getelementptr [4 x i32], [4 x i32]* %act_bias.ne, i64 0, i64 %arrayinit.curidx4.i27
  %arrayinit.nextidx6.i29 = add nuw nsw i64 %arrayinit.curidx4.i27, 1
  store i32 0, i32* %arrayinit.cur52.i28, align 4, !alias.scope !8847, !noalias !8848
  %arrayinit.done7.i30 = icmp eq i64 %arrayinit.curidx4.i27, 3
  br i1 %arrayinit.done7.i30, label %arrayinit.end8.i32, label %arrayinit.body3.i31, !llvm.loop !8849

arrayinit.end8.i32:                               ; preds = %arrayinit.body3.i31
  store i32 0, i32* %act_bias.source_offset, align 512, !alias.scope !8850, !noalias !8851
  store i32 0, i32* %act_bias.source_bytes, align 512, !alias.scope !8852, !noalias !8853
  store i32 0, i32* %act_bias.base, align 512, !alias.scope !8854, !noalias !8855
  store i32 0, i32* %act_bias.span, align 512, !alias.scope !8856, !noalias !8857
  br label %arrayinit.body10.i37

arrayinit.body10.i37:                             ; preds = %arrayinit.body10.i37, %arrayinit.end8.i32
  %arrayinit.curidx11.i33 = phi i64 [ 0, %arrayinit.end8.i32 ], [ %arrayinit.nextidx13.i35, %arrayinit.body10.i37 ]
  call void (...) @_ssdm_op_SpecLoopTripCount(i64 32, i64 32, i64 32), !fpga.pragma.source !33
  %arrayinit.cur123.i34 = getelementptr [32 x i8], [32 x i8]* %act_bias.source_sha256, i64 0, i64 %arrayinit.curidx11.i33
  %arrayinit.nextidx13.i35 = add nuw nsw i64 %arrayinit.curidx11.i33, 1
  store i8 0, i8* %arrayinit.cur123.i34, align 1, !alias.scope !8858, !noalias !8859
  %arrayinit.done14.i36 = icmp eq i64 %arrayinit.curidx11.i33, 31
  br i1 %arrayinit.done14.i36, label %_ZN4laya4full20FullTensorDescriptorC2Ev.exit38, label %arrayinit.body10.i37, !llvm.loop !8860

_ZN4laya4full20FullTensorDescriptorC2Ev.exit38:   ; preds = %arrayinit.body10.i37
  store i16 -1, i16* %act_bias_id, align 512
  call fastcc void @"laya::full::full_lookup_tensor_indexed.10"(i16* %ref.tmp331.0380, i32* %ref.tmp331.1381, i64* %ref.tmp331.2382, [48 x i8]* %act_bias.name, i8* %act_bias.ggml_type_id, i8* %act_bias.bo, i8* %act_bias.omitted, i8* %act_bias.reserved, [4 x i32]* %act_bias.ne, i32* %act_bias.source_offset, i32* %act_bias.source_bytes, i32* %act_bias.base, i32* %act_bias.span, [32 x i8]* %act_bias.source_sha256, i16* %act_bias_id)
  %.013 = load i16, i16* %ref.tmp331.0380, align 512
  %.115 = load i32, i32* %ref.tmp331.1381, align 512
  %.217 = load i64, i64* %ref.tmp331.2382, align 512
  store i16 %.013, i16* %agg.result_code, align 512
  store i32 %.115, i32* %agg.result_detail, align 512
  store i64 %.217, i64* %agg.result_bad_element, align 512
  %220 = call fastcc i1 @"laya::Check::operator bool"(i16 %.013)
  br i1 %220, label %if.end334, label %cleanup348

if.end334:                                        ; preds = %_ZN4laya4full20FullTensorDescriptorC2Ev.exit38
  store i8 0, i8* %act_hidden.ref.id, align 512, !alias.scope !8861, !noalias !8866
  store i8 0, i8* %act_hidden.ref.bank, align 512, !alias.scope !8880, !noalias !8881
  store i32 0, i32* %act_hidden.ref.epoch, align 512, !alias.scope !8882, !noalias !8883
  store i8 0, i8* %act_hidden.region, align 512, !alias.scope !8884, !noalias !8885
  store i8 0, i8* %act_hidden.stage, align 512, !alias.scope !8886, !noalias !8887
  store i8 -1, i8* %act_hidden.layer, align 512, !alias.scope !8888, !noalias !8889
  store i8 -1, i8* %act_hidden.batch, align 512, !alias.scope !8890, !noalias !8891
  store i8 0, i8* %act_hidden.row_space, align 512, !alias.scope !8892, !noalias !8893
  store i16 0, i16* %act_hidden.row0, align 512, !alias.scope !8894, !noalias !8895
  store i16 0, i16* %act_hidden.rows, align 512, !alias.scope !8896, !noalias !8897
  store i16 0, i16* %act_hidden.width, align 512, !alias.scope !8898, !noalias !8899
  store i8 0, i8* %act_hidden.content, align 512, !alias.scope !8900, !noalias !8901
  %221 = load i16, i16* %act_bias_id, align 512
  %act_dot.ref.id.val = load i8, i8* %act_dot.ref.id, align 512
  %act_dot.ref.bank.val = load i8, i8* %act_dot.ref.bank, align 512
  %act_dot.ref.epoch.val = load i32, i32* %act_dot.ref.epoch, align 512
  %act_dot.region.val = load i8, i8* %act_dot.region, align 512
  %act_dot.stage.val = load i8, i8* %act_dot.stage, align 512
  %act_dot.layer.val = load i8, i8* %act_dot.layer, align 512
  %act_dot.batch.val = load i8, i8* %act_dot.batch, align 512
  %act_dot.row_space.val = load i8, i8* %act_dot.row_space, align 512
  %act_dot.row0.val = load i16, i16* %act_dot.row0, align 512
  %act_dot.rows.val = load i16, i16* %act_dot.rows, align 512
  %act_dot.width.val = load i16, i16* %act_dot.width, align 512
  %act_dot.content.val = load i8, i8* %act_dot.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::transform"(i16* %ref.tmp335.0369, i32* %ref.tmp335.1370, i64* %ref.tmp335.2371, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 101, i8 %act_dot.ref.id.val, i8 %act_dot.ref.bank.val, i32 %act_dot.ref.epoch.val, i8 %act_dot.region.val, i8 %act_dot.stage.val, i8 %act_dot.layer.val, i8 %act_dot.batch.val, i8 %act_dot.row_space.val, i16 %act_dot.row0.val, i16 %act_dot.rows.val, i16 %act_dot.width.val, i8 %act_dot.content.val, i16 256, i16 %221, i8* %act_hidden.ref.id, i8* %act_hidden.ref.bank, i32* %act_hidden.ref.epoch, i8* %act_hidden.region, i8* %act_hidden.stage, i8* %act_hidden.layer, i8* %act_hidden.batch, i8* %act_hidden.row_space, i16* %act_hidden.row0, i16* %act_hidden.rows, i16* %act_hidden.width, i8* %act_hidden.content)
  %.07 = load i16, i16* %ref.tmp335.0369, align 512
  %.19 = load i32, i32* %ref.tmp335.1370, align 512
  %.211 = load i64, i64* %ref.tmp335.2371, align 512
  store i16 %.07, i16* %agg.result_code, align 512
  store i32 %.19, i32* %agg.result_detail, align 512
  store i64 %.211, i64* %agg.result_bad_element, align 512
  %222 = call fastcc i1 @"laya::Check::operator bool"(i16 %.07)
  br i1 %222, label %if.end338, label %cleanup347

if.end338:                                        ; preds = %if.end334
  call fastcc void @"laya::full::(anonymous namespace)::Controller::fresh"(i8* %agg.tmp343.0, i8* %agg.tmp343.1, i32* %agg.tmp343.2, i8 10, i8 0, i8 4)
  %223 = load i8, i8* %agg.tmp343.0, align 512
  %224 = load i8, i8* %agg.tmp343.1, align 512
  %225 = load i32, i32* %agg.tmp343.2, align 512
  %act_hidden.ref.id.val = load i8, i8* %act_hidden.ref.id, align 512
  %act_hidden.ref.bank.val = load i8, i8* %act_hidden.ref.bank, align 512
  %act_hidden.ref.epoch.val = load i32, i32* %act_hidden.ref.epoch, align 512
  %act_hidden.region.val = load i8, i8* %act_hidden.region, align 512
  %act_hidden.stage.val = load i8, i8* %act_hidden.stage, align 512, !alias.scope !7518, !noalias !7521
  %act_hidden.layer.val = load i8, i8* %act_hidden.layer, align 512
  %act_hidden.batch.val = load i8, i8* %act_hidden.batch, align 512, !alias.scope !7537, !noalias !7538
  %act_hidden.row_space.val = load i8, i8* %act_hidden.row_space, align 512
  %act_hidden.row0.val = load i16, i16* %act_hidden.row0, align 512, !alias.scope !7539, !noalias !7540
  %act_hidden.rows.val = load i16, i16* %act_hidden.rows, align 512
  %act_hidden.width.val = load i16, i16* %act_hidden.width, align 512, !alias.scope !7541, !noalias !7542
  %act_hidden.content.val = load i8, i8* %act_hidden.content, align 512
  call fastcc void @"laya::full::(anonymous namespace)::Controller::linear.15"(i16* %ref.tmp339.0363, i32* %ref.tmp339.1364, i64* %ref.tmp339.2365, i8 addrspace(1)* %embedding, i64 %this_memory.0, i64* %this_memory.1, i8 addrspace(1)* %io, i64 %this_memory.2, i64* %this_memory.3, i8 addrspace(1)* %w_q0, i64 %this_memory.4, i64* %this_memory.5, i8 addrspace(1)* %w_q1, i64 %this_memory.6, i64* %this_memory.7, i8 addrspace(1)* %w_scale, i64 %this_memory.8, i64* %this_memory.9, i8 addrspace(1)* %aux, i64 %this_memory.10, i64* %this_memory.11, i8 addrspace(1)* %state0, i64 %this_memory.12, i64* %this_memory.13, i8 addrspace(1)* %state1, i64 %this_memory.14, i64* %this_memory.15, i8 addrspace(1)* %qkv0, i64 %this_memory.16, i64* %this_memory.17, i8 addrspace(1)* %qkv1, i64 %this_memory.18, i64* %this_memory.19, i8 addrspace(1)* %ff0, i64 %this_memory.20, i64* %this_memory.21, i8 addrspace(1)* %ff1, i64 %this_memory.22, i64* %this_memory.23, i8 addrspace(1)* %att_out, i64 %this_memory.24, i64* %this_memory.25, i8* %this_error_stage, i8* %this_error_op, i32* %this_error_task_id, i8* %this_current_stage, i8* %this_current_op, i8 55, i8 12, i8 -1, i8 %act_hidden.ref.id.val, i8 %act_hidden.ref.bank.val, i32 %act_hidden.ref.epoch.val, i8 %act_hidden.region.val, i8 %act_hidden.stage.val, i8 %act_hidden.layer.val, i8 %act_hidden.batch.val, i8 %act_hidden.row_space.val, i16 %act_hidden.row0.val, i16 %act_hidden.rows.val, i16 %act_hidden.width.val, i8 %act_hidden.content.val, i8 6, i8 -1, i8 %223, i8 %224, i32 %225, i8 4, i8* %act_ref_id, i8* %act_ref_bank, i32* %act_ref_epoch, i8* %act_region, i8* %act_stage, i8* %act_layer, i8* %act_batch, i8* %act_row_space, i16* %act_row0, i16* %act_rows, i16* %act_width, i8* %act_content)
  %.0 = load i16, i16* %ref.tmp339.0363, align 512
  %.1 = load i32, i32* %ref.tmp339.1364, align 512
  %.2 = load i64, i64* %ref.tmp339.2365, align 512
  store i16 %.0, i16* %agg.result_code, align 512
  store i32 %.1, i32* %agg.result_detail, align 512
  store i64 %.2, i64* %agg.result_bad_element, align 512
  br label %cleanup347

cleanup347:                                       ; preds = %if.end338, %if.end334
  br label %cleanup348

cleanup348:                                       ; preds = %cleanup347, %_ZN4laya4full20FullTensorDescriptorC2Ev.exit38
  br label %cleanup350

cleanup350:                                       ; preds = %cleanup348, %if.end322
  br label %cleanup351

cleanup351:                                       ; preds = %cleanup350, %if.end318
  br label %cleanup352

cleanup352:                                       ; preds = %cleanup351, %if.end314
  br label %cleanup353

cleanup353:                                       ; preds = %cleanup352, %if.end310
  br label %cleanup354

cleanup354:                                       ; preds = %cleanup353, %cleanup7.i.i, %if.end298
  br label %cleanup355

cleanup355:                                       ; preds = %cleanup354, %if.end294
  br label %cleanup356

cleanup356:                                       ; preds = %cleanup355, %_ZN4laya4full20FullTensorDescriptorC2Ev.exit
  br label %cleanup358

cleanup358:                                       ; preds = %cleanup356, %if.then286, %if.end267
  br label %cleanup359

cleanup359:                                       ; preds = %cleanup358, %if.end262, %if.end257
  br label %cleanup360

cleanup360:                                       ; preds = %cleanup359, %for.end253
  br label %cleanup361

cleanup361.loopexit:                              ; preds = %cleanup246
  br label %cleanup361

cleanup361:                                       ; preds = %cleanup361.loopexit, %cleanup360, %if.end135, %if.end130, %if.end120
  br label %cleanup362

cleanup362.loopexit:                              ; preds = %cleanup112
  br label %cleanup362

cleanup362:                                       ; preds = %cleanup362.loopexit, %cleanup361, %for.end, %if.end9, %if.end4
  br label %cleanup363

cleanup363:                                       ; preds = %cleanup362, %if.end, %entry
  ret void
}
