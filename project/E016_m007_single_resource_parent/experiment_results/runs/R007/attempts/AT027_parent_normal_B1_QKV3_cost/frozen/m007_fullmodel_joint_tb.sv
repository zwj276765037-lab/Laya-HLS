`timescale 1ns/1ps
module m007_fullmodel_joint_tb #(parameter bit FORCE_CORE_CE=0);
 integer residual_total=0;
 logic  clk='0;
 logic  rst_n='0;
 logic  owner_req_valid='0;
 logic [1:0] owner_req='0;
 logic  owner_req_ready;
 logic [1:0] owner;
 logic  rearm;
 logic  a_enable;
 logic  g_enable;
 logic  ln_enable;
 logic  vector_enable;
 logic  resident_owner_valid='0;
 logic [63:0] resident_owner_request_id='0;
 logic [31:0] resident_owner_generation='0;
 logic [31:0] resident_owner_epoch='0;
 logic  resident_inputs_ready='0;
 logic  parent_matrix_retired='0;
 logic  parent_quant_retired='0;
 logic [63:0] resident_access_request_id='0;
 logic [31:0] resident_access_generation='0;
 logic [31:0] resident_access_epoch='0;
 logic  h_wr_valid='0;
 logic  h_wr_ready;
 logic  h_wr_commit;
 logic [11:0] h_wr_addr='0;
 logic [31:0][31:0] h_wr_data='0;
 logic  h_rd_valid='0;
 logic  h_rd_ready;
 logic [11:0] h_rd_addr='0;
 logic  h_rsp_valid;
 logic  h_rsp_ready='0;
 logic [11:0] h_rsp_addr;
 logic [31:0][31:0] h_rsp_data;
 logic  h_reject_valid;
 logic  q_wr_valid='0;
 logic  q_wr_ready;
 logic  q_wr_commit;
 logic [11:0] q_wr_addr='0;
 logic [31:0][31:0] q_wr_data='0;
 logic  q_rd_valid='0;
 logic  q_rd_ready;
 logic [11:0] q_rd_addr='0;
 logic  q_rsp_valid;
 logic  q_rsp_ready='0;
 logic [11:0] q_rsp_addr;
 logic [31:0][31:0] q_rsp_data;
 logic  q_reject_valid;
 logic  scratch_lease_valid='0;
 logic  scratch_release_valid='0;
 logic  scratch_lease_ready;
 logic  scratch_release_ready;
 logic  scratch_owner_active;
 logic  scratch_retired;
 logic  h_bank_idle;
 logic  resident_bank_idle;
 logic  shared_resources_idle;
 logic  ln_provider_idle;
 logic  a_prepare_valid='0;
 logic  a_prepare_ready;
 logic [63:0] a_prepare_request_id='0;
 logic [127:0] a_prepare_model_id='0;
 logic [31:0] a_prepare_generation='0;
 logic [31:0] a_prepare_epoch='0;
 logic [127:0] a_prepare_numeric_id='0;
 logic [127:0] a_prepare_table_key='0;
 logic [1:0] a_prepare_kind='0;
 logic [4:0] a_prepare_layer='0;
 logic [127:0] a_prepare_mask='0;
 logic  a_qkv_wr_valid='0;
 logic  a_qkv_wr_ready;
 logic [63:0] a_qkv_wr_request_id='0;
 logic [31:0] a_qkv_wr_generation='0;
 logic [31:0] a_qkv_wr_epoch='0;
 logic [1:0] a_qkv_wr_plane='0;
 logic [3:0] a_qkv_wr_head='0;
 logic [6:0] a_qkv_wr_token='0;
 logic  a_qkv_wr_half='0;
 logic [31:0][31:0] a_qkv_wr_data='0;
 logic  a_start_valid='0;
 logic  a_start_ready;
 logic [63:0] a_start_request_id='0;
 logic [31:0] a_start_generation='0;
 logic  a_reject_valid;
 logic [3:0] a_reject_code;
 logic  a_abort_valid='0;
 logic  a_abort_ready;
 logic [2:0] a_qkv_read_grant='0;
 logic  a_ps_grant='0;
 logic  a_g_grant='0;
 logic  a_context_grant='0;
 logic  a_fp_grant='0;
 logic  a_sfu_grant='0;
 logic  a_exp_grant='0;
 logic  a_div_grant='0;
 logic  a_rope_write_grant='0;
 logic  a_done_valid;
 logic  a_done_ready='0;
 logic [63:0] a_done_request_id;
 logic [31:0] a_done_generation;
 logic [7:0] a_done_status;
 logic [31:0] a_done_cycles;
 logic [31:0] a_rope_cycles;
 logic [15:0] a_head_completed;
 logic [15:0] a_head_context_valid;
 logic [3:0] a_active_head;
 logic  a_error_valid;
 logic [95:0] a_error_tuple;
 logic [25:0][15:0] a_check_completed;
 logic [25:0][15:0] a_check_unreachable;
 logic [25:0][15:0] a_check_dominated;
 logic [2047:0] a_av_check_completed;
 logic [2047:0] a_av_check_unreachable;
 logic [2047:0] a_av_check_dominated;
 logic  a_result_rd_valid='0;
 logic  a_result_rd_ready;
 logic [31:0] a_result_rd_generation='0;
 logic [31:0] a_result_rd_tag='0;
 logic [3:0] a_result_rd_head='0;
 logic [6:0] a_result_rd_query='0;
 logic  a_result_rd_half='0;
 logic  a_result_rsp_valid;
 logic  a_result_rsp_ready='0;
 logic [31:0] a_result_rsp_tag;
 logic [31:0][31:0] a_result_rsp_data;
 logic  a_result_discard_valid='0;
 logic  a_result_discard_ready;
 logic [31:0] a_result_discard_generation='0;
 logic  a_context_discarded;
 logic [31:0] a_producer_done_cycles;
 logic [31:0] a_context_release_cycles;
 logic  a_prepare_cancel_valid='0;
 logic  a_prepare_cancel_ready;
 logic [63:0] a_prepare_cancel_request_id='0;
 logic [31:0] a_prepare_cancel_generation='0;
 logic [31:0] a_prepare_cancel_epoch='0;
 logic  a_prepare_cancel_rsp_valid;
 logic  a_prepare_cancel_rsp_ready='0;
 logic [63:0] a_prepare_cancel_rsp_request_id;
 logic [31:0] a_prepare_cancel_rsp_generation;
 logic [31:0] a_prepare_cancel_rsp_epoch;
 logic [7:0] a_prepare_cancel_rsp_status;
 logic  a_layer_idle;
 logic  a_check_coverage_fault;
 logic [31:0] a_check_first_conflict;
 logic  g_producer_cancel_valid='0;
 logic  g_producer_cancel_ready;
 logic [63:0] g_producer_cancel_request_id='0;
 logic [31:0] g_producer_cancel_generation='0;
 logic [31:0] g_producer_cancel_epoch='0;
 logic  g_producer_cancel_reject_valid;
 logic  g_cmd_valid='0;
 logic  g_cmd_ready;
 logic [63:0] g_cmd_request_id='0;
 logic [31:0] g_cmd_generation='0;
 logic [31:0] g_cmd_epoch='0;
 logic  g_fill_valid='0;
 logic  g_fill_ready;
 logic [63:0] g_fill_request_id='0;
 logic [31:0] g_fill_generation='0;
 logic [31:0] g_fill_epoch='0;
 logic  g_fill_slot='0;
 logic  g_fill_half='0;
 logic [6:0] g_fill_s='0;
 logic [6:0] g_fill_row='0;
 logic [31:0][31:0] g_fill_data='0;
 logic  g_fill_reject_valid;
 logic [1:0] g_fill_reject_code;
 logic  g_out_valid;
 logic  g_out_ready='0;
 logic [7:0][31:0] g_out_data;
 logic [7:0][31:0] g_out_status;
 logic [95:0] g_out_tag;
 logic [6:0] g_out_s;
 logic [6:0] g_out_row;
 logic [1:0] g_out_chunk;
 logic  g_done_valid;
 logic  g_done_ready='0;
 logic  g_done_cancelled;
 logic [31:0] g_done_status;
 logic [2:0] g_done_error_rank;
 logic [6:0] g_done_error_row;
 logic [11:0] g_done_error_column;
 logic [63:0] g_rsp_request_id;
 logic [31:0] g_rsp_generation;
 logic [31:0] g_rsp_epoch;
 logic  g_discard_valid='0;
 logic  g_discard_ready;
 logic [63:0] g_discard_request_id='0;
 logic [31:0] g_discard_generation='0;
 logic [31:0] g_discard_epoch='0;
 logic  g_discard_reject_valid;
 logic  g_engine_idle;
 logic  g_active;
 logic  g_needs_discard;
 logic  g_protocol_fault;
 logic [1:0] g_slot_active;
 logic [1:0] g_slot_ready;
 logic [1:0][6:0] g_slot_s;
 logic [1:0][9:0] g_slot_consumed_vectors;
 logic [1:0][8:0] g_slot_math_pending;
 logic [1:0][8:0] g_slot_sfu_debt;
 logic [1:0][7:0] g_slot_fp_debt;
 logic [7:0][18:0] g_covered;
 logic [7:0][18:0] g_evaluated;
 logic  ln_gamma_begin_valid='0;
 logic  ln_gamma_begin_ready;
 logic [63:0] ln_gamma_model='0;
 logic [31:0] ln_gamma_key='0;
 logic  ln_gamma_valid='0;
 logic  ln_gamma_ready;
 logic [4:0] ln_gamma_chunk='0;
 logic [31:0][31:0] ln_gamma_data='0;
 logic  ln_gamma_done_valid;
 logic  ln_gamma_done_ready='0;
 logic  ln_gamma_done_error;
 logic  ln_gamma_loaded;
 logic  ln_done_valid;
 logic  ln_done_error;
 logic [4:0] ln_error_stage;
 logic [3:0] ln_error_level;
 logic [6:0] ln_error_row;
 logic [9:0] ln_error_node;
 logic  ln_reject_valid;
 logic [3:0] ln_reject_code;
 logic  ln_active;
 logic  ln_debt_clear;
 logic  ln_trace_add_valid;
 logic [175:0] ln_trace_add_meta;
 logic  ln_trace_mul_valid;
 logic [23:0] ln_trace_mul_meta;
 logic [6:0] ln_trace_scalar_valid;
 logic [6:0][1:0] ln_trace_scalar_ctx;
 logic [6:0][31:0] ln_trace_scalar_data;
 logic  ln_trace_row_start;
 logic [6:0] ln_trace_row;
 logic [3:0] ln_ctx_active;
 logic [3:0][6:0] ln_ctx_row;
 logic [3:0][31:0] ln_raw_coverage;
 logic [3:0][31:0] ln_delta_coverage;
 logic [31:0] ln_cycle_count;
 logic [6:0] ln_peak_add_pending;
 logic [6:0] ln_peak_mul_pending;
 logic  ln_reject_ready='0;
 logic  ln_cancel_valid='0;
 logic  ln_cancel_ready;
 logic [63:0] ln_cancel_request_id='0;
 logic [31:0] ln_cancel_generation='0;
 logic [31:0] ln_cancel_epoch='0;
 logic [1:0] ln_done_kind;
 logic  ln_cancel_rsp_valid;
 logic  ln_protocol_fault;
 logic [3:0] ln_protocol_code;
 logic [7:0] ln_protocol_location;
 logic [1:0] ln_error_class;
 logic [3:0] ln_error_check;
 logic  vector_start_valid='0;
 logic  vector_start_ready;
 logic [1:0] vector_start_op='0;
 logic [63:0] vector_start_request_id='0;
 logic [31:0] vector_start_generation='0;
 logic [31:0] vector_start_epoch='0;
 logic  vector_start_reject_valid;
 logic  vector_done_valid;
 logic  vector_done_ready='0;
 logic [31:0] vector_done_status;
 logic [6:0] vector_done_error_row;
 logic [9:0] vector_done_error_column;
 logic  vector_idle;
 logic [12:0] vector_issued_vectors;
 logic [12:0] vector_retired_vectors;
 logic  coeff_bind_valid='0;
 logic  coeff_bind_ready;
 logic [127:0] coeff_bind_model_id='0;
 logic [127:0] coeff_bind_numeric_id='0;
 logic [127:0] coeff_bind_table_key='0;
 logic  coeff_bound_valid;
 logic [127:0] coeff_bound_model_id;
 logic [127:0] coeff_bound_numeric_id;
 logic [127:0] coeff_bound_table_key;
 logic [1:0] coeff_family_complete;
 logic  coeff_wr_valid='0;
 logic  coeff_wr_ready;
 logic [127:0] coeff_wr_model_id='0;
 logic [127:0] coeff_wr_numeric_id='0;
 logic [127:0] coeff_wr_table_key='0;
 logic [1:0] coeff_wr_table='0;
 logic [6:0] coeff_wr_row='0;
 logic  coeff_wr_half='0;
 logic [31:0][31:0] coeff_wr_data='0;
 logic  coeff_wr_reject_valid;
 logic [2:0] coeff_wr_reject_code;
 logic [4:0] coeff_wr_nonfinite_lane;
 logic  resident_ln_start_valid='0;
 logic  resident_ln_start_ready;
 logic [7:0] resident_ln_rows='0;
 logic  resident_ln_use_gamma='0;
 logic [63:0] resident_ln_model='0;
 logic [31:0] resident_ln_key='0;
 logic  resident_ln_done_valid;
 logic  resident_ln_done_ready='0;
 logic [31:0] resident_ln_done_status;
 logic [1:0] resident_ln_done_kind;
 logic  resident_ln_source_qualified;
 logic [12:0] resident_ln_issued_vectors;
 logic [12:0] resident_ln_written_vectors;
 logic  ext_fp_select='0;
 logic  ext_div_select='0;
 logic  ext_bind_select='0;
 logic  ext_ps_select='0;
 logic  ext_context_select='0;
 logic  ext_res_st_bind_valid='0;
 logic  ext_res_st_bind_ready;
 logic [63:0] ext_res_st_bind_request_id='0;
 logic [31:0] ext_res_st_bind_generation='0;
 logic [31:0] ext_res_st_bind_epoch='0;
 logic [3:0] ext_res_st_bind_head='0;
 logic [2:0] ext_res_st_bind_phase='0;
 logic [63:0] ext_res_st_op_request_id='0;
 logic [31:0] ext_res_st_op_generation='0;
 logic [31:0] ext_res_st_op_epoch='0;
 logic [2:0] ext_res_st_op_phase='0;
 logic [63:0] ext_res_st_rsp_request_id;
 logic [31:0] ext_res_st_rsp_generation;
 logic [31:0] ext_res_st_rsp_epoch;
 logic [3:0] ext_res_st_rsp_head;
 logic [2:0] ext_res_st_rsp_phase;
 logic  ext_res_st_ps_wr_valid='0;
 logic  ext_res_st_ps_wr_ready;
 logic [1023:0] ext_res_st_ps_wr_mask='0;
 logic [1023:0][3:0] ext_res_st_ps_wr_addr='0;
 logic [1023:0][31:0] ext_res_st_ps_wr_data='0;
 logic [95:0] ext_res_st_ps_wr_tag='0;
 logic  ext_res_st_ps_wr_rsp_valid;
 logic  ext_res_st_ps_wr_rsp_ready='0;
 logic [95:0] ext_res_st_ps_wr_rsp_tag;
 logic  ext_res_st_ps_rd_valid='0;
 logic  ext_res_st_ps_rd_ready;
 logic [1023:0] ext_res_st_ps_rd_mask='0;
 logic [1023:0][3:0] ext_res_st_ps_rd_addr='0;
 logic [95:0] ext_res_st_ps_rd_tag='0;
 logic  ext_res_st_ps_rd_rsp_valid;
 logic  ext_res_st_ps_rd_rsp_ready='0;
 logic [1023:0][31:0] ext_res_st_ps_rd_rsp_data;
 logic [1023:0] ext_res_st_ps_rd_rsp_mask;
 logic [95:0] ext_res_st_ps_rd_rsp_tag;
 logic  ext_res_st_context_wr_valid='0;
 logic  ext_res_st_context_wr_ready;
 logic [63:0] ext_res_st_context_wr_mask='0;
 logic [63:0][10:0] ext_res_st_context_wr_addr='0;
 logic [63:0][31:0] ext_res_st_context_wr_data='0;
 logic [95:0] ext_res_st_context_wr_tag='0;
 logic  ext_res_st_context_wr_rsp_valid;
 logic  ext_res_st_context_wr_rsp_ready='0;
 logic [95:0] ext_res_st_context_wr_rsp_tag;
 logic  ext_res_st_context_rd_valid='0;
 logic  ext_res_st_context_rd_ready;
 logic [63:0] ext_res_st_context_rd_mask='0;
 logic [63:0][10:0] ext_res_st_context_rd_addr='0;
 logic [95:0] ext_res_st_context_rd_tag='0;
 logic  ext_res_st_context_rd_rsp_valid;
 logic  ext_res_st_context_rd_rsp_ready='0;
 logic [63:0][31:0] ext_res_st_context_rd_rsp_data;
 logic [63:0] ext_res_st_context_rd_rsp_mask;
 logic [95:0] ext_res_st_context_rd_rsp_tag;
 logic  ext_res_st_idle;
 logic  ext_res_fp_lease_valid='0;
 logic  ext_res_fp_lease_ready;
 logic [63:0] ext_res_fp_lease_request_id='0;
 logic [31:0] ext_res_fp_lease_generation='0;
 logic [31:0] ext_res_fp_lease_epoch='0;
 logic [3:0] ext_res_fp_lease_head='0;
 logic [2:0] ext_res_fp_lease_phase='0;
 logic  ext_res_fp_release_valid='0;
 logic  ext_res_fp_release_ready;
 logic [2:0] ext_res_fp_release_phase='0;
 logic [31:0] ext_res_fp_release_epoch='0;
 logic  ext_res_fp_phase_debt_clear='0;
 logic  ext_res_fp_lease_active;
 logic  ext_res_fp_draining;
 logic [63:0] ext_res_fp_rsp_request_id;
 logic [31:0] ext_res_fp_rsp_generation;
 logic [31:0] ext_res_fp_rsp_epoch;
 logic [3:0] ext_res_fp_rsp_head;
 logic [2:0] ext_res_fp_rsp_phase;
 logic  ext_res_fp_mul_req_valid='0;
 logic  ext_res_fp_mul_req_ready;
 logic [2:0] ext_res_fp_mul_req_phase='0;
 logic [31:0] ext_res_fp_mul_req_epoch='0;
 logic [95:0] ext_res_fp_mul_req_tag='0;
 logic [255:0][31:0] ext_res_fp_mul_a='0;
 logic [255:0][31:0] ext_res_fp_mul_b='0;
 logic  ext_res_fp_mul_rsp_valid;
 logic  ext_res_fp_mul_rsp_ready='0;
 logic [95:0] ext_res_fp_mul_rsp_tag;
 logic [255:0][31:0] ext_res_fp_mul_rsp_data;
 logic [6:0] ext_res_fp_add_req_valid='0;
 logic [6:0] ext_res_fp_add_req_is_root='0;
 logic [6:0] ext_res_fp_add_req_ready;
 logic [6:0][2:0] ext_res_fp_add_req_phase='0;
 logic [6:0][31:0] ext_res_fp_add_req_epoch='0;
 logic [6:0][95:0] ext_res_fp_add_req_tag='0;
 logic [255:0][31:0] ext_res_fp_add_a='0;
 logic [255:0][31:0] ext_res_fp_add_b='0;
 logic [6:0] ext_res_fp_add_rsp_valid;
 logic [6:0] ext_res_fp_add_rsp_ready='0;
 logic [6:0][95:0] ext_res_fp_add_rsp_tag;
 logic [255:0][31:0] ext_res_fp_add_rsp_data;
 logic [6:0] ext_res_fp_mul_pending;
 logic [6:0][6:0] ext_res_fp_add_pending;
 logic  ext_res_fp_protocol_fault;
 logic  ext_res_div_lease_valid='0;
 logic  ext_res_div_lease_ready;
 logic [63:0] ext_res_div_lease_request_id='0;
 logic [31:0] ext_res_div_lease_generation='0;
 logic [31:0] ext_res_div_lease_epoch='0;
 logic [3:0] ext_res_div_lease_head='0;
 logic [2:0] ext_res_div_lease_phase='0;
 logic  ext_res_div_release_ready;
 logic  ext_res_div_draining;
 logic [63:0] ext_res_div_rsp_request_id;
 logic [31:0] ext_res_div_rsp_generation;
 logic [31:0] ext_res_div_rsp_epoch;
 logic [3:0] ext_res_div_rsp_head;
 logic [2:0] ext_res_div_rsp_phase;
 logic [3:0] ext_res_div_protocol_reject_code;
 logic [7:0] ext_res_div_rsp_lane_mask;
 logic  ext_res_div_release_valid='0;
 logic [2:0] ext_res_div_release_phase='0;
 logic [31:0] ext_res_div_release_epoch='0;
 logic  ext_res_div_phase_debt_clear='0;
 logic  ext_res_div_lease_active;
 logic  ext_res_div_req_valid='0;
 logic  ext_res_div_req_ready;
 logic [31:0] ext_res_div_req_generation='0;
 logic [31:0] ext_res_div_req_epoch='0;
 logic [2:0] ext_res_div_req_phase='0;
 logic [7:0] ext_res_div_req_lane_mask='0;
 logic [95:0] ext_res_div_req_tag='0;
 logic [7:0][31:0] ext_res_div_req_a='0;
 logic [7:0][31:0] ext_res_div_req_b='0;
 logic  ext_res_div_protocol_reject_valid;
 logic  ext_res_div_rsp_valid;
 logic  ext_res_div_rsp_ready='0;
 logic [95:0] ext_res_div_rsp_tag;
 logic [7:0] ext_res_div_rsp_numeric_error;
 logic [7:0][31:0] ext_res_div_rsp_data;
 logic [5:0] ext_res_div_pending_vectors;
 logic [5:0] ext_res_div_in_flight_vectors;
 logic [8:0] ext_res_div_in_flight_scalars;
 logic  ext_res_div_protocol_fault;
 logic  g_tanh_lease_valid='0;
 logic  g_tanh_lease_ready;
 logic [63:0] g_tanh_lease_request_id='0;
 logic [31:0] g_tanh_lease_generation='0;
 logic [31:0] g_tanh_lease_epoch='0;
 logic [2:0] g_tanh_lease_phase='0;
 logic  g_tanh_release_valid='0;
 logic  g_tanh_release_ready;
 logic [2:0] g_tanh_release_phase='0;
 logic [31:0] g_tanh_release_epoch='0;
 logic  g_tanh_phase_debt_clear='0;
 logic  g_tanh_lease_active;
 logic  g_tanh_draining;
 logic [8:0] g_tanh_pending_vectors;
 logic [8:0] g_tanh_in_flight_vectors;
 always #1 clk=~clk;
 laya_m007_resident_joint_v3 #(.TANH_FORCE_CORE_CE(FORCE_CORE_CE)) dut(.type_model_committed(1'b0),.type_qtype(2'b0),.type_wr_valid(1'b0),.type_wr_ready(),.type_wr_index(7'b0),.type_wr_data('0),.type_wr_commit(),.type_bank_idle(),.type_reject_valid(),.h_load_success_valid(1'b0),.*);

 integer trace_fd,ce0_cycles=0,ce1_cycles=0;string trace_path;
 integer mode_arg=0,stage=0,cycle=0,phase=0,checked=0,node_checks=0,returned=0,fd,rows_arg=16,vector_writes=0,ln_writes=0,g_outputs=0,g_fp_nodes=0,g_tanh_nodes=0,g_bank_ops=0;
 integer vector_start_cycle,vector_done_cycle,vector_first_write,ln_start_cycle,ln_done_cycle;
 integer switches=0,rearm_cycles=0,last_progress=0,g_cancelled=0;
 bit check_residual=0,check_norm=0,check_g=0,gamma_case=0;
 logic[31:0]hf[0:131071],qf[0:131071],rf[0:131071],nf[0:131071];
 logic[1023:0]gamma_raw[0:4095],gamma_gold[0:4095],gamma_values[0:31];
 logic[383:0]gv[0:335871];
 string hf_path,qf_path,rf_path,nf_path,graw_path,ggold_path,gvalue_path,gv_path,pf;
 function automatic int si(input int vi,l);return ((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;endfunction
 task automatic tick;@(posedge clk);#0.01;endtask
 task automatic progress;
  if(checked>last_progress)begin
   $fdisplay(fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":%0d,\"returned\":%0d}",checked,node_checks,cycle,phase,returned);$fflush(fd);last_progress=checked;$display("M007_PARENT_CHECKED checked=%0d phase=JOINT cycle=%0d",checked,cycle);$fflush();
  end
 endtask
 task automatic switch_to(input logic[1:0]target);
  @(negedge clk);owner_req=target;owner_req_valid=1;#0.001;
  begin int waited;waited=0;while(!owner_req_ready)begin
   @(negedge clk);#0.001;waited++;
   if(waited==128)$fatal(1,"SWITCH_BLOCKED owner=%0d target=%0d reqvalid=%0d scratch_release=%0d/%0d scratch_retired=%0d private=%b admission=%b retired=%b physical=%0d banks=%0d",owner,target,owner_req_valid,scratch_release_valid,scratch_release_ready,scratch_retired,dut.joint.workspace.private_idle,dut.joint.admission_quiet,dut.joint.workspace.retired,shared_resources_idle,resident_bank_idle);
  end end
  tick();if(!rearm||{a_enable,g_enable,ln_enable,vector_enable}!==0||owner!==target||dut.joint.state_q!==0)$fatal(1,"REARM_FIRST target=%0d",target);
  @(negedge clk);owner_req_valid=0;tick();if(rearm||owner!==target||dut.joint.state_q!==0)$fatal(1,"REARM_LENGTH");
  switches++;
 endtask
 task automatic update_epoch;
  @(negedge clk);resident_owner_epoch++;resident_access_epoch=resident_owner_epoch;
 endtask
 task automatic scratch_acquire;
  @(negedge clk);scratch_lease_valid=1;#0.001;while(!scratch_lease_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);scratch_lease_valid=0;if(!scratch_owner_active)$fatal(1,"SCRATCH_ACQUIRE");
 endtask
 task automatic scratch_release;
  @(negedge clk);scratch_release_valid=1;#0.001;while(!scratch_release_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);scratch_release_valid=0;if(scratch_owner_active)$fatal(1,"SCRATCH_RELEASE");
 endtask
 task automatic a_partial(input bit test_held);
  @(negedge clk);a_prepare_valid=1;a_prepare_request_id=resident_owner_request_id;a_prepare_generation=resident_owner_generation;a_prepare_epoch=resident_owner_epoch;a_prepare_kind=0;a_prepare_layer=0;
  #0.001;while(!a_prepare_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);a_prepare_valid=0;a_qkv_wr_valid=1;a_qkv_wr_request_id=resident_owner_request_id;a_qkv_wr_generation=resident_owner_generation;a_qkv_wr_epoch=resident_owner_epoch;a_qkv_wr_data='0;
  #0.001;while(!a_qkv_wr_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);a_qkv_wr_valid=0;
  begin logic[12287:0]saved;saved=dut.joint.state_q;owner_req_valid=1;owner_req=0;tick();if(rearm||dut.joint.state_q!==saved)$fatal(1,"SAME_OWNER_CLEARED");end
  @(negedge clk);owner_req=1;repeat(3)begin tick();if(owner_req_ready||rearm)$fatal(1,"ACTIVE_A_SWITCH");end
  @(negedge clk);a_prepare_cancel_valid=1;a_prepare_cancel_request_id=resident_owner_request_id;a_prepare_cancel_generation=resident_owner_generation;a_prepare_cancel_epoch=resident_owner_epoch;
  #0.001;while(!a_prepare_cancel_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);a_prepare_cancel_valid=0;while(!a_prepare_cancel_rsp_valid)@(negedge clk);
  repeat(test_held?17:1)begin tick();if(!a_prepare_cancel_rsp_valid||owner_req_ready||rearm)$fatal(1,"HELD_A_CANCEL_SWITCH");end
  @(negedge clk);owner_req_valid=0;a_prepare_cancel_rsp_ready=1;tick();@(negedge clk);a_prepare_cancel_rsp_ready=0;
  while(!a_layer_idle)@(negedge clk);
 endtask
 task automatic g_partial;
  phase=1;check_g=1;ext_fp_select=1;ext_bind_select=1;ext_ps_select=1;
  ext_res_fp_lease_request_id=resident_owner_request_id;ext_res_fp_lease_generation=resident_owner_generation;ext_res_fp_lease_epoch=resident_owner_epoch;ext_res_fp_lease_phase=1;
  ext_res_st_bind_request_id=resident_owner_request_id;ext_res_st_bind_generation=resident_owner_generation;ext_res_st_bind_epoch=resident_owner_epoch;ext_res_st_bind_phase=1;
  ext_res_st_op_request_id=resident_owner_request_id;ext_res_st_op_generation=resident_owner_generation;ext_res_st_op_epoch=resident_owner_epoch;ext_res_st_op_phase=1;
  g_tanh_lease_request_id=resident_owner_request_id;g_tanh_lease_generation=resident_owner_generation;g_tanh_lease_epoch=resident_owner_epoch;g_tanh_lease_phase=1;
  @(negedge clk);ext_res_fp_lease_valid=1;#0.001;while(!ext_res_fp_lease_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ext_res_fp_lease_valid=0;ext_res_st_bind_valid=1;#0.001;while(!ext_res_st_bind_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ext_res_st_bind_valid=0;g_tanh_lease_valid=1;#0.001;while(!g_tanh_lease_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);g_tanh_lease_valid=0;g_cmd_valid=1;g_cmd_request_id=resident_owner_request_id;g_cmd_generation=resident_owner_generation;g_cmd_epoch=resident_owner_epoch;
  #0.001;while(!g_cmd_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);g_cmd_valid=0;g_out_ready=1;
  for(int i=0;i<256;i++)begin
   g_fill_valid=1;g_fill_request_id=resident_owner_request_id;g_fill_generation=resident_owner_generation;g_fill_epoch=resident_owner_epoch;g_fill_slot=0;g_fill_s=0;g_fill_half=1'(i/128);g_fill_row=7'(i%128);
   for(int l=0;l<32;l++)g_fill_data[l]=gv[(i%128)*2624+l][383-(i/128)*32-:32];
   #0.001;while(!g_fill_ready)begin @(negedge clk);#0.001;end
   tick();@(negedge clk);
  end
  g_fill_valid=0;while(g_outputs<8)@(negedge clk);
  g_producer_cancel_valid=1;g_producer_cancel_request_id=resident_owner_request_id;g_producer_cancel_generation=resident_owner_generation;g_producer_cancel_epoch=resident_owner_epoch;
  #0.001;while(!g_producer_cancel_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);g_producer_cancel_valid=0;owner_req_valid=1;owner_req=3;
  while(!g_done_valid)@(negedge clk);
  if(!g_done_cancelled||g_done_status!=0)$fatal(1,"G_CANCEL_KIND status=%0d",g_done_status);
  repeat(17)begin tick();if(owner_req_ready||rearm||!g_done_valid)$fatal(1,"G_HELD_DONE_SWITCH");end
  @(negedge clk);owner_req_valid=0;g_done_ready=1;tick();@(negedge clk);g_done_ready=0;
  if(g_needs_discard)begin
   g_discard_valid=1;g_discard_request_id=resident_owner_request_id;g_discard_generation=resident_owner_generation;g_discard_epoch=resident_owner_epoch;
   #0.001;while(!g_discard_ready)begin @(negedge clk);#0.001;end
   tick();@(negedge clk);g_discard_valid=0;
  end
  while(!g_engine_idle)@(negedge clk);
  ext_res_fp_phase_debt_clear=1;ext_res_fp_release_phase=1;ext_res_fp_release_epoch=resident_owner_epoch;ext_res_fp_release_valid=1;
  #0.001;while(!ext_res_fp_release_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ext_res_fp_release_valid=0;ext_res_fp_phase_debt_clear=0;
  g_tanh_phase_debt_clear=1;g_tanh_release_phase=1;g_tanh_release_epoch=resident_owner_epoch;g_tanh_release_valid=1;
  #0.001;while(!g_tanh_release_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);g_tanh_release_valid=0;g_tanh_phase_debt_clear=0;
  if(g_fp_nodes==0||g_tanh_nodes==0||g_bank_ops==0||g_outputs<8)$fatal(1,"G_NOT_REAL");
  ext_fp_select=0;ext_bind_select=0;ext_ps_select=0;check_g=0;g_cancelled=1;progress();
 endtask
 task automatic load_gamma;
  @(negedge clk);ln_gamma_begin_valid=1;ln_gamma_model=64'h1234;ln_gamma_key=32'h5678;#0.001;
  while(!ln_gamma_begin_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ln_gamma_begin_valid=0;
  for(int c=0;c<32;c++)begin
   ln_gamma_valid=1;ln_gamma_chunk=5'(c);ln_gamma_data=gamma_values[c];#0.001;
   while(!ln_gamma_ready)begin @(negedge clk);#0.001;end
   tick();@(negedge clk);
  end
  ln_gamma_valid=0;while(!ln_gamma_done_valid)@(negedge clk);
  owner_req_valid=1;owner_req=3;repeat(17)begin tick();if(owner_req_ready||rearm||!ln_gamma_done_valid)$fatal(1,"GAMMA_HELD_SWITCH");end
  @(negedge clk);owner_req_valid=0;ln_gamma_done_ready=1;tick();@(negedge clk);ln_gamma_done_ready=0;if(!ln_gamma_loaded||ln_gamma_done_error)$fatal(1,"GAMMA_LOAD");
 endtask
 task automatic load_hq(input bit use_gamma_fixture,input bit nan_input);
  phase=2;
  for(int a=0;a<4096;a++)begin
   @(negedge clk);h_wr_valid=1;q_wr_valid=1;h_wr_addr=12'(a);q_wr_addr=12'(a);
   for(int l=0;l<32;l++)begin
    h_wr_data[l]=use_gamma_fixture?gamma_raw[a][l*32+:32]:hf[a*32+l];
    q_wr_data[l]=use_gamma_fixture?32'h80000000:qf[a*32+l];
   end
   if(nan_input&&a==3)h_wr_data[5]=32'h7fc00001;
   #0.001;if(!h_wr_ready||!q_wr_ready)$fatal(1,"LOAD_NOT_READY a=%0d",a);
   tick();if(!h_wr_commit||!q_wr_commit)$fatal(1,"LOAD_WITHOUT_COMMIT");
  end
  @(negedge clk);h_wr_valid=0;q_wr_valid=0;
  if(resident_ln_source_qualified)$fatal(1,"INPUT_LOAD_PSEUDO_QUALIFIED");
 endtask
 task automatic run_vector(input bit gamma_fixture,input bit expect_nan);
  phase=2;gamma_case=gamma_fixture;vector_writes=0;check_residual=!expect_nan;
  @(negedge clk);resident_inputs_ready=1;vector_start_valid=1;vector_start_op=0;vector_start_request_id=resident_owner_request_id;vector_start_generation=resident_owner_generation;vector_start_epoch=resident_owner_epoch;owner_req_valid=1;owner_req=2;
  #0.001;while(!vector_start_ready)begin @(negedge clk);#0.001;end
  if(owner_req_ready)$fatal(1,"VECTOR_START_SWITCH_RACE");vector_start_cycle=cycle;tick();@(negedge clk);vector_start_valid=0;owner_req_valid=1;owner_req=2;
  while(!vector_done_valid)begin tick();if(owner_req_ready||rearm)$fatal(1,"VECTOR_EARLY_SWITCH");end
  vector_done_cycle=cycle-vector_start_cycle;
  if(expect_nan)begin if(vector_done_status!=6||vector_done_error_row!=0||vector_done_error_column!=101)$fatal(1,"VECTOR_NAN_FIRST");end
  else if(vector_done_status!=0||vector_issued_vectors!=4096||vector_retired_vectors!=4096||vector_writes!=4096||vector_done_cycle>4160||vector_first_write>32)$fatal(1,"VECTOR_COMPLETION status=%0d issued=%0d retired=%0d writes=%0d cycles=%0d",vector_done_status,vector_issued_vectors,vector_retired_vectors,vector_writes,vector_done_cycle);
  repeat(17)begin tick();if(!vector_done_valid||owner_req_ready||rearm||resident_ln_source_qualified)$fatal(1,"VECTOR_DONE_WITNESS_EARLY");end
  @(negedge clk);owner_req_valid=0;vector_done_ready=1;tick();@(negedge clk);vector_done_ready=0;check_residual=0;
  if(resident_ln_source_qualified===expect_nan)$fatal(1,"FINITE_WITNESS_WRONG");
 endtask
 task automatic run_ln(input bit use_gamma_fixture,input int rows);
  phase=4;gamma_case=use_gamma_fixture;check_norm=1;ln_writes=0;
  @(negedge clk);resident_ln_start_valid=1;resident_ln_rows=8'(rows);resident_ln_use_gamma=use_gamma_fixture;resident_ln_model=64'h1234;resident_ln_key=32'h5678;owner_req_valid=1;owner_req=0;
  #0.001;while(!resident_ln_start_ready)begin @(negedge clk);#0.001;end
  if(owner_req_ready)$fatal(1,"LN_START_SWITCH_RACE");
  ln_start_cycle=cycle;$display("JOINT23_LN_BEGIN gamma=%0d rows=%0d cycle=%0d",use_gamma_fixture,rows,cycle);
  tick();@(negedge clk);resident_ln_start_valid=0;owner_req_valid=1;owner_req=0;
  while(!resident_ln_done_valid)begin tick();if(owner_req_ready||rearm)$fatal(1,"LN_EARLY_SWITCH");end
  ln_done_cycle=cycle-ln_start_cycle;
  if(resident_ln_done_status!=0||resident_ln_done_kind!=0||ln_writes!=rows*32||resident_ln_issued_vectors!=rows*32||resident_ln_written_vectors!=rows*32)$fatal(1,"LN_COMPLETION status=%0d kind=%0d writes=%0d issued=%0d stored=%0d",resident_ln_done_status,resident_ln_done_kind,ln_writes,resident_ln_issued_vectors,resident_ln_written_vectors);
  $display("JOINT23_LN_END gamma=%0d rows=%0d cycle=%0d outputs=%0d",use_gamma_fixture,rows,cycle,ln_writes);
  repeat(17)begin tick();if(owner_req_ready||rearm||!resident_ln_done_valid)$fatal(1,"LN_HELD_DONE_SWITCH");end
  @(negedge clk);owner_req_valid=0;resident_ln_done_ready=1;tick();@(negedge clk);resident_ln_done_ready=0;check_norm=0;
  if(resident_ln_source_qualified)$fatal(1,"WITNESS_NOT_RETIRED");
 endtask
 initial begin
  $display("JOINT27_START force=%0d cycle=%0d",FORCE_CORE_CE,cycle);
  if(!$value$plusargs("H=%s",hf_path)||!$value$plusargs("Q=%s",qf_path)||!$value$plusargs("GOLD=%s",rf_path)||!$value$plusargs("NORM=%s",nf_path)||!$value$plusargs("GRAW=%s",graw_path)||!$value$plusargs("GGOLD=%s",ggold_path)||!$value$plusargs("GAMMA=%s",gvalue_path)||!$value$plusargs("GV=%s",gv_path)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  if($value$plusargs("ROWS=%d",rows_arg))begin end
  if($value$plusargs("MODE=%d",mode_arg))begin end
  if(rows_arg!=16&&rows_arg!=128)$fatal(1,"ROWS");
  $readmemh(hf_path,hf);$readmemh(qf_path,qf);$readmemh(rf_path,rf);$readmemh(nf_path,nf);$readmemh(graw_path,gamma_raw);$readmemh(ggold_path,gamma_gold);$readmemh(gvalue_path,gamma_values);$readmemh(gv_path,gv);
  fd=$fopen(pf,"w");if(!fd)$fatal(1,"PROGRESS_OPEN");
  if(!$value$plusargs("TRACE_FILE=%s",trace_path))$fatal(1,"TRACE_ARGS");
  trace_fd=$fopen(trace_path,"w");if(!trace_fd)$fatal(1,"TRACE_OPEN");
  if(dut.TANH_FORCE_CORE_CE!==FORCE_CORE_CE||dut.g_tanh.FORCE_CORE_CE!==FORCE_CORE_CE)$fatal(1,"ACTUAL_FORCE_CONFIG");
  repeat(3)tick();@(negedge clk);rst_n=1;resident_owner_valid=1;resident_owner_request_id=64'h12345678;resident_owner_generation=11;resident_owner_epoch=21;resident_access_request_id=resident_owner_request_id;resident_access_generation=resident_owner_generation;resident_access_epoch=resident_owner_epoch;parent_matrix_retired=1;parent_quant_retired=1;
  a_qkv_read_grant=7;a_ps_grant=1;a_g_grant=1;a_context_grant=1;a_fp_grant=1;a_sfu_grant=1;a_exp_grant=1;a_div_grant=1;a_rope_write_grant=1;ln_reject_ready=1;
  tick();
  if(mode_arg==0)begin
   stage=1;$display("JOINT23_STAGE A_PARTIAL cycle=%0d",cycle);a_partial(1);switch_to(1);
   stage=2;$display("JOINT23_STAGE G_PARTIAL cycle=%0d",cycle);g_partial();switch_to(2);load_gamma();switch_to(3);scratch_acquire();
   stage=3;load_hq(0,0);run_vector(0,0);scratch_release();update_epoch();switch_to(2);
   // The real VECTOR witness exists, but lack of scratch or owner denies public handshake.
   stage=4;resident_ln_rows=8'(rows_arg);resident_ln_start_valid=1;
   repeat(3)begin tick();if(resident_ln_start_ready)$fatal(1,"LN_NO_SCRATCH_READY");end
   @(negedge clk);resident_owner_valid=0;
   repeat(3)begin tick();if(resident_ln_start_ready)$fatal(1,"LN_NO_OWNER_READY");end
   @(negedge clk);resident_ln_start_valid=0;resident_owner_valid=1;
   if(resident_ln_source_qualified)$fatal(1,"OWNER_LOSS_FAILED_TO_INVALIDATE_WITNESS");
   // D29 owner-loss invalidates source qualification: recreate it using real
   // public H/Q commits and finite VECTOR output, then acquire a new LN lease.
   switch_to(3);scratch_acquire();load_hq(0,0);run_vector(0,0);scratch_release();update_epoch();switch_to(2);scratch_acquire();
   stage=5;run_ln(0,rows_arg);
   stage=6;$display("JOINT23_STAGE LN_RETIRED cycle=%0d",cycle);scratch_release();switch_to(0);
   @(negedge clk);resident_owner_generation++;resident_access_generation=resident_owner_generation;resident_owner_epoch++;resident_access_epoch=resident_owner_epoch;
   stage=7;a_partial(0);
  end else if(mode_arg==1)begin
   switch_to(2);load_gamma();switch_to(0);a_partial(0);switch_to(3);scratch_acquire();load_hq(1,0);run_vector(1,0);scratch_release();update_epoch();switch_to(2);scratch_acquire();
   if(!ln_gamma_loaded)$fatal(1,"GAMMA_CROSS_OWNER_LOST");run_ln(1,4);scratch_release();switch_to(0);
  end else if(mode_arg==2)begin
   switch_to(3);scratch_acquire();load_hq(0,1);run_vector(0,1);scratch_release();switch_to(0);
   @(negedge clk);resident_owner_generation++;resident_access_generation=resident_owner_generation;resident_owner_epoch++;resident_access_epoch=resident_owner_epoch;
   a_partial(0);switch_to(3);scratch_acquire();load_hq(0,0);run_vector(0,0);scratch_release();switch_to(0);
  end else $fatal(1,"MODE");
  if(!shared_resources_idle||!resident_bank_idle||!ln_provider_idle||(mode_arg==0&&!g_cancelled))$fatal(1,"FINAL_DEBT");
  $display("JOINT27_CYCLES total=%0d vector_first=%0d vector_done=%0d ln_start=%0d ln_done=%0d rearm=%0d",cycle,vector_first_write,vector_done_cycle,ln_start_cycle,ln_done_cycle,rearm_cycles);
  $display("JOINT27_CE force=%0d ce0=%0d ce1=%0d",FORCE_CORE_CE,ce0_cycles,ce1_cycles);$fclose(trace_fd);
  progress();$fclose(fd);$display("HARDWARE_AGENT_SIM_PASS JOINT23 mode=%0d rows=%0d checked=%0d node_checks=%0d switches=%0d g_outputs=%0d g_fp_nodes=%0d g_tanh_nodes=%0d g_bank_ops=%0d residual_vectors=%0d ln_vectors=%0d gamma_reused=%0d nan_recovered=%0d control_arena_bits=12288",mode_arg,rows_arg,checked,node_checks,switches,g_outputs,g_fp_nodes,g_tanh_nodes,g_bank_ops,residual_total,mode_arg==0?rows_arg*32:mode_arg==1?128:0,mode_arg==1,mode_arg==2);$finish;
 end
 always@(posedge clk)begin
  cycle++;
  if(rst_n&&cycle%4096==0)$display("JOINT23_DIAGNOSTIC cycle=%0d mode=%0d stage=%0d owner=%0d req=%0d ready=%0d rearm=%0d provider_state=%0d witness=%0d a_idle=%0d ln_ret=%0d physical=%0d banks=%0d reqvalid=%0d scratch_release=%0d/%0d scratch_retired=%0d private=%b admission=%b",cycle,mode_arg,stage,owner,owner_req,owner_req_ready,rearm,dut.ln_provider.state,resident_ln_source_qualified,a_layer_idle,dut.joint.ln_retired_raw,shared_resources_idle,resident_bank_idle,owner_req_valid,scratch_release_valid,scratch_release_ready,scratch_retired,dut.joint.workspace.private_idle,dut.joint.admission_quiet);
  if(cycle>60000)$fatal(1,"TIMEOUT phase=%0d owner=%0d",phase,owner);
  if(rst_n)begin
   $fdisplay(trace_fd,"%0d %h",cycle,{owner_req_ready,owner,rearm,a_enable,g_enable,ln_enable,vector_enable,h_wr_ready,h_wr_commit,h_rd_ready,h_rsp_valid,h_reject_valid,q_wr_ready,q_wr_commit,q_rd_ready,q_rsp_valid,q_reject_valid,scratch_lease_ready,scratch_release_ready,scratch_owner_active,scratch_retired,h_bank_idle,resident_bank_idle,shared_resources_idle,ln_provider_idle,a_prepare_ready,a_qkv_wr_ready,a_start_ready,a_reject_valid,a_abort_ready,a_done_valid,a_head_context_valid,a_active_head,a_error_valid,a_result_rd_ready,a_result_rsp_valid,a_result_discard_ready,a_prepare_cancel_ready,a_prepare_cancel_rsp_valid,a_layer_idle,g_producer_cancel_ready,g_producer_cancel_reject_valid,g_cmd_ready,g_fill_ready,g_fill_reject_valid,g_out_valid,g_done_valid,g_discard_ready,g_discard_reject_valid,g_engine_idle,g_active,g_slot_active,g_slot_ready,g_slot_math_pending,ln_gamma_begin_ready,ln_gamma_ready,ln_gamma_done_valid,ln_done_valid,ln_reject_valid,ln_active,ln_trace_add_valid,ln_trace_mul_valid,ln_trace_scalar_valid,ln_ctx_active,ln_peak_add_pending,ln_peak_mul_pending,ln_cancel_ready,ln_cancel_rsp_valid,vector_start_ready,vector_start_reject_valid,vector_done_valid,vector_idle,vector_issued_vectors,vector_retired_vectors,coeff_bind_ready,coeff_bound_valid,coeff_wr_ready,coeff_wr_reject_valid,resident_ln_start_ready,resident_ln_done_valid,resident_ln_issued_vectors,resident_ln_written_vectors,ext_res_st_bind_ready,ext_res_st_ps_wr_ready,ext_res_st_ps_wr_rsp_valid,ext_res_st_ps_rd_ready,ext_res_st_ps_rd_rsp_valid,ext_res_st_context_wr_ready,ext_res_st_context_wr_rsp_valid,ext_res_st_context_rd_ready,ext_res_st_context_rd_rsp_valid,ext_res_st_idle,ext_res_fp_lease_ready,ext_res_fp_release_ready,ext_res_fp_lease_active,ext_res_fp_mul_req_ready,ext_res_fp_mul_rsp_valid,ext_res_fp_add_req_ready,ext_res_fp_add_rsp_valid,ext_res_fp_mul_pending,ext_res_fp_add_pending,ext_res_div_lease_ready,ext_res_div_release_ready,ext_res_div_lease_active,ext_res_div_req_ready,ext_res_div_protocol_reject_valid,ext_res_div_rsp_valid,ext_res_div_pending_vectors,ext_res_div_in_flight_vectors,ext_res_div_in_flight_scalars,g_tanh_lease_ready,g_tanh_release_ready,g_tanh_lease_active,g_tanh_pending_vectors,g_tanh_in_flight_vectors,dut.r_res_qkv_wr_valid,dut.r_res_qkv_wr_ready,dut.r_res_qkv_rd_valid,dut.r_res_qkv_rd_ready,dut.r_res_qkv_rd_rsp_valid,dut.r_res_qkv_rd_rsp_ready,dut.r_res_st_bind_valid,dut.r_res_st_bind_ready,dut.r_res_st_ps_wr_valid,dut.r_res_st_ps_wr_ready,dut.r_res_st_ps_wr_rsp_valid,dut.r_res_st_ps_wr_rsp_ready,dut.r_res_st_ps_rd_valid,dut.r_res_st_ps_rd_ready,dut.r_res_st_ps_rd_rsp_valid,dut.r_res_st_ps_rd_rsp_ready,dut.r_res_st_g_wr_valid,dut.r_res_st_g_wr_ready,dut.r_res_st_g_wr_rsp_valid,dut.r_res_st_g_wr_rsp_ready,dut.r_res_st_g_rd_valid,dut.r_res_st_g_rd_ready,dut.r_res_st_g_rd_rsp_valid,dut.r_res_st_g_rd_rsp_ready,dut.r_res_st_context_wr_valid,dut.r_res_st_context_wr_ready,dut.r_res_st_context_wr_rsp_valid,dut.r_res_st_context_wr_rsp_ready,dut.r_res_st_context_rd_valid,dut.r_res_st_context_rd_ready,dut.r_res_st_context_rd_rsp_valid,dut.r_res_st_context_rd_rsp_ready,dut.r_res_st_idle,dut.r_res_fp_lease_valid,dut.r_res_fp_lease_ready,dut.r_res_fp_release_valid,dut.r_res_fp_release_ready,dut.r_res_fp_lease_active,dut.r_res_fp_draining,dut.r_res_fp_mul_req_valid,dut.r_res_fp_mul_req_ready,dut.r_res_fp_mul_rsp_valid,dut.r_res_fp_mul_rsp_ready,dut.r_res_fp_add_req_valid,dut.r_res_fp_add_req_ready,dut.r_res_fp_add_rsp_valid,dut.r_res_fp_add_rsp_ready,dut.r_res_fp_mul_pending,dut.r_res_fp_add_pending,dut.r_res_ln_bind_valid,dut.r_res_ln_bind_ready,dut.r_res_ln_wr_valid,dut.r_res_ln_wr_ready,dut.r_res_ln_wr_rsp_valid,dut.r_res_ln_wr_rsp_ready,dut.r_res_ln_rd_valid,dut.r_res_ln_rd_ready,dut.r_res_ln_rd_rsp_valid,dut.r_res_ln_rd_rsp_ready,dut.r_res_ln_idle,dut.r_res_sfu_lease_valid,dut.r_res_sfu_lease_ready,dut.r_res_sfu_release_valid,dut.r_res_sfu_lease_active,dut.r_res_sfu_context_valid,dut.r_res_sfu_req_valid,dut.r_res_sfu_req_ready,dut.r_res_sfu_reject_valid,dut.r_res_sfu_rsp_valid,dut.r_res_sfu_rsp_ready,dut.r_res_sfu_pending_vectors,dut.r_res_sfu_in_flight_vectors,dut.r_res_div_lease_valid,dut.r_res_div_lease_ready,dut.r_res_div_release_ready,dut.r_res_div_draining,dut.r_res_div_release_valid,dut.r_res_div_lease_active,dut.r_res_div_req_valid,dut.r_res_div_req_ready,dut.r_res_div_protocol_reject_valid,dut.r_res_div_rsp_valid,dut.r_res_div_rsp_ready,dut.r_res_div_pending_vectors,dut.r_res_div_in_flight_vectors,dut.r_res_div_in_flight_scalars,dut.r_res_scale_valid,dut.r_res_scale_ready,dut.r_res_scale_rsp_valid,dut.r_res_scale_rsp_ready,dut.r_res_scale_pending,dut.g_fp_req_valid,dut.g_fp_rsp_valid,dut.g_sfu_req_valid,dut.g_sfu_req_ready,dut.g_sfu_rsp_valid,dut.g_sfu_rsp_ready,dut.ln_in_ready,dut.ln_add_req_valid,dut.ln_div_req_valid,dut.vector_h_rd_valid,dut.vector_q_rd_valid,dut.vector_h_wr_valid,dut.p_q_wr_valid,dut.p_q_wr_ready,dut.p_q_wr_commit});
   if(dut.g_tanh.core_ce)ce1_cycles++;else ce0_cycles++;
   if(g_tanh_lease_active&&!dut.g_tanh.core_ce)$fatal(1,"ACTIVE_TANH_CE_PAUSED");
   if(rearm)begin rearm_cycles++;if({a_enable,g_enable,ln_enable,vector_enable}!==0)$fatal(1,"REARM_ENABLED");end
   if(ln_enable&&dut.r_res_fp_lease_active&&(dut.joint.a_private_idle||owner_req_ready))$fatal(1,"ACTUAL_LN_FP_DEBT_PROBE");
   if(!a_enable&&(dut.a_res_qkv_wr_valid||(|dut.a_res_qkv_rd_valid)||dut.a_res_fp_lease_valid||dut.a_res_st_bind_valid))$fatal(1,"A_INACTIVE_HANDSHAKE");
   if(!g_enable&&(g_cmd_ready||g_fill_ready||dut.g_sfu_req_valid||(|dut.g_fp_req_valid)))$fatal(1,"G_INACTIVE_HANDSHAKE");
   if(!ln_enable&&(ln_gamma_begin_ready||ln_gamma_ready||dut.ln_in_ready||dut.ln_add_req_valid||dut.ln_div_req_valid))$fatal(1,"LN_INACTIVE_HANDSHAKE");
   if(!vector_enable&&(vector_start_ready||dut.vector_h_rd_valid||dut.vector_q_rd_valid||dut.vector_h_wr_valid))$fatal(1,"VECTOR_INACTIVE_HANDSHAKE");
   if(check_g)begin
    if(dut.g_g_wr_valid&&dut.g_g_wr_ready)g_bank_ops++;
    for(int n=0;n<9;n++)if(dut.g_fp_rsp_valid[n])begin
     int vi,w;vi=int'(dut.g_fp_rsp_tag[n][15:0]);w=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;
     for(int l=0;l<8;l++)begin if(dut.g_fp_rsp_data[n][l]!==gv[si(vi,l)][383-w*32-:32]||dut.g_fp_rsp_status[n][l]!==0)$fatal(1,"G_FP_NODE");g_fp_nodes++;node_checks++;end
    end
    if(dut.g_sfu_rsp_valid&&dut.g_sfu_rsp_ready)for(int l=0;l<8;l++)begin if(dut.g_sfu_rsp_data[l]!==gv[si(int'(dut.g_sfu_rsp_tag[15:0]),l)][159:128]||dut.g_sfu_rsp_status[l]!==0)$fatal(1,"G_TANH_NODE");g_tanh_nodes++;node_checks++;end
    if(g_out_valid&&g_out_ready)begin
     for(int l=0;l<8;l++)if(g_out_data[l]!==gv[si(g_outputs,l)][31:0]||g_out_status[l]!==0)$fatal(1,"G_OUTPUT");
     g_outputs++;checked+=8;returned++;if(g_outputs%8==0)progress();
    end
   end
   if(check_residual&&dut.vector_h_wr_valid&&dut.vector_h_wr_ready)begin
    int a;a=int'(dut.vector_h_wr_addr);if(a!=vector_writes)$fatal(1,"VECTOR_COMMIT_ORDER");
    for(int l=0;l<32;l++)if(dut.vector_h_wr_data[l]!==(gamma_case?gamma_raw[a][l*32+:32]:rf[a*32+l]))$fatal(1,"RESIDUAL_BITS a=%0d lane=%0d",a,l);
    if(!dut.vector_h_wr_commit)$fatal(1,"VECTOR_WITHOUT_COMMIT");if(vector_writes==0)vector_first_write=cycle-vector_start_cycle;
    vector_writes++;residual_total++;checked+=32;returned++;if(vector_writes%128==0)progress();
   end
   if(check_norm&&dut.p_q_wr_valid&&dut.p_q_wr_ready)begin
    int a;a=int'(dut.p_q_wr_addr);if(a!=ln_writes)$fatal(1,"LN_OUTPUT_ORDER a=%0d expected=%0d",a,ln_writes);
    for(int l=0;l<32;l++)if(dut.p_q_wr_data[l]!==(gamma_case?gamma_gold[a][l*32+:32]:nf[a*32+l]))$fatal(1,"LN_BITS a=%0d lane=%0d actual=%h expected=%h",a,l,dut.p_q_wr_data[l],gamma_case?gamma_gold[a][l*32+:32]:nf[a*32+l]);
    if(!dut.p_q_wr_commit)$fatal(1,"LN_WITHOUT_Q_COMMIT");ln_writes++;checked+=32;returned++;if(ln_writes%32==0)progress();
   end
  end
 end
endmodule
