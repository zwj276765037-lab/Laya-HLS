`timescale 1ns/1ps
// Validation-only composition: exactly one existing native storage, one frozen
// TANH8 and one external 56mul/16add G pool. The production engine stays pure.
module m007_cancel17_normal_shell(
 input logic producer_cancel_valid,input logic [63:0]producer_cancel_request_id,
 input logic [31:0]producer_cancel_generation,producer_cancel_epoch,
 output logic producer_cancel_ready,producer_cancel_reject_valid,done_cancelled,
 input logic owner_req_valid,owner_req_g,output logic owner_req_ready,a_enable,g_enable,rearm,owner_g,
 input logic  a_prepare_valid,
 output logic  a_prepare_ready,
 input logic  a_qkv_wr_valid,
 output logic  a_qkv_wr_ready,
 input logic [1:0] a_qkv_wr_plane,
 input logic [3:0] a_qkv_wr_head,
 input logic [6:0] a_qkv_wr_token,
 input logic  a_qkv_wr_half,
 input logic [31:0][31:0] a_qkv_wr_data,
 input logic  a_prepare_cancel_valid,
 output logic  a_prepare_cancel_ready,
 output logic  a_prepare_cancel_rsp_valid,
 input logic  a_prepare_cancel_rsp_ready,
 output logic  a_layer_idle,
 input logic clk,rst_n,
 input logic bind_valid,output logic bind_ready,output logic resources_bound,
 input logic [63:0] request_id,input logic [31:0] generation,epoch,
 input logic release_valid,output logic release_ready,
 input logic cmd_valid,output logic cmd_ready,
 input logic fill_valid,output logic fill_ready,input logic fill_slot,fill_half,
 input logic [6:0] fill_s,fill_row,input logic [31:0][31:0] fill_data,
 output logic fill_reject_valid,output logic [1:0] fill_reject_code,
 output logic out_valid,input logic out_ready,output logic [7:0][31:0] out_data,out_status,
 output logic [95:0] out_tag,output logic [6:0] out_s,out_row,output logic [1:0] out_chunk,
 output logic done_valid,input logic done_ready,output logic [31:0] done_status,
 output logic [2:0] done_error_rank,output logic [6:0] done_error_row,output logic [11:0] done_error_column,
 output logic [63:0] rsp_request_id,output logic [31:0] rsp_generation,rsp_epoch,
 input logic discard_valid,output logic discard_ready,output logic discard_reject_valid,
 output logic engine_idle,active,needs_discard,protocol_fault,
 output logic [1:0] slot_active,slot_ready,output logic [1:0][6:0] slot_s,
 output logic [1:0][9:0] slot_consumed_vectors,
 output logic [1:0][8:0] slot_math_pending,slot_sfu_debt,output logic [1:0][7:0] slot_fp_debt,
 output logic [7:0][18:0] covered,evaluated,output logic [8:0] sfu_pending,sfu_flight,
 output logic slot_release_fire,slot_release_slot,output logic [6:0] slot_release_s,
 output logic g_wr_valid,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready,
 output logic [95:0] g_wr_rsp_tag,
 output logic g_rd_valid,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready,
 output logic [95:0] g_rd_tag,g_rd_rsp_tag,
 output logic [8:0] fp_rsp_valid,output logic [8:0][95:0] fp_rsp_tag,
 output logic [8:0][7:0][31:0] fp_rsp_data,fp_rsp_status,
 output logic sfu_rsp_valid,sfu_rsp_ready,output logic [95:0] sfu_rsp_tag,
 output logic [7:0] sfu_rsp_mask,output logic [7:0][31:0] sfu_rsp_data,sfu_rsp_status
);
 logic [63:0] a_prepare_request_id;
 logic [127:0] a_prepare_model_id;
 logic [31:0] a_prepare_generation;
 logic [31:0] a_prepare_epoch;
 logic [127:0] a_prepare_numeric_id;
 logic [127:0] a_prepare_table_key;
 logic [1:0] a_prepare_kind;
 logic [4:0] a_prepare_layer;
 logic [127:0] a_prepare_mask;
 logic [63:0] a_qkv_wr_request_id;
 logic [31:0] a_qkv_wr_generation;
 logic [31:0] a_qkv_wr_epoch;
 logic  a_start_valid;
 logic  a_start_ready;
 logic [63:0] a_start_request_id;
 logic [31:0] a_start_generation;
 logic  a_reject_valid;
 logic [3:0] a_reject_code;
 logic  a_abort_valid;
 logic  a_abort_ready;
 logic [2:0] a_qkv_read_grant;
 logic  a_ps_grant;
 logic  a_g_grant;
 logic  a_context_grant;
 logic  a_fp_grant;
 logic  a_sfu_grant;
 logic  a_exp_grant;
 logic  a_div_grant;
 logic  a_rope_write_grant;
 logic  a_done_valid;
 logic  a_done_ready;
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
 logic  a_result_rd_valid;
 logic  a_result_rd_ready;
 logic [31:0] a_result_rd_generation;
 logic [31:0] a_result_rd_tag;
 logic [3:0] a_result_rd_head;
 logic [6:0] a_result_rd_query;
 logic  a_result_rd_half;
 logic  a_result_rsp_valid;
 logic  a_result_rsp_ready;
 logic [31:0] a_result_rsp_tag;
 logic [31:0][31:0] a_result_rsp_data;
 logic  a_result_discard_valid;
 logic  a_result_discard_ready;
 logic [31:0] a_result_discard_generation;
 logic  a_context_discarded;
 logic [31:0] a_producer_done_cycles;
 logic [31:0] a_context_release_cycles;
 logic [63:0] a_prepare_cancel_request_id;
 logic [31:0] a_prepare_cancel_generation;
 logic [31:0] a_prepare_cancel_epoch;
 logic [63:0] a_prepare_cancel_rsp_request_id;
 logic [31:0] a_prepare_cancel_rsp_generation;
 logic [31:0] a_prepare_cancel_rsp_epoch;
 logic [7:0] a_prepare_cancel_rsp_status;
 logic  a_check_coverage_fault;
 logic [31:0] a_check_first_conflict;
 logic  a_res_qkv_wr_valid;
 logic  a_res_qkv_wr_ready;
 logic [1:0]  a_res_qkv_wr_plane;
 logic [3:0]  a_res_qkv_wr_head;
 logic [6:0]  a_res_qkv_wr_token;
 logic  a_res_qkv_wr_half;
 logic [31:0][31:0]  a_res_qkv_wr_data;
 logic [2:0]  a_res_qkv_rd_valid;
 logic [2:0]  a_res_qkv_rd_ready;
 logic [2:0][3:0]  a_res_qkv_rd_head;
 logic [2:0][6:0]  a_res_qkv_rd_token;
 logic [2:0][31:0]  a_res_qkv_rd_tag;
 logic [2:0]  a_res_qkv_rd_rsp_valid;
 logic [2:0]  a_res_qkv_rd_rsp_ready;
 logic [2:0][3:0]  a_res_qkv_rd_rsp_head;
 logic [2:0][6:0]  a_res_qkv_rd_rsp_token;
 logic [2:0][31:0]  a_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0]  a_res_qkv_rd_rsp_data;
 logic  a_res_st_bind_valid;
 logic  a_res_st_bind_ready;
 logic [63:0]  a_res_st_bind_request_id;
 logic [31:0]  a_res_st_bind_generation;
 logic [31:0]  a_res_st_bind_epoch;
 logic [3:0]  a_res_st_bind_head;
 logic [2:0]  a_res_st_bind_phase;
 logic [63:0]  a_res_st_op_request_id;
 logic [31:0]  a_res_st_op_generation;
 logic [31:0]  a_res_st_op_epoch;
 logic [2:0]  a_res_st_op_phase;
 logic [63:0]  a_res_st_rsp_request_id;
 logic [31:0]  a_res_st_rsp_generation;
 logic [31:0]  a_res_st_rsp_epoch;
 logic [3:0]  a_res_st_rsp_head;
 logic [2:0]  a_res_st_rsp_phase;
 logic  a_res_st_ps_wr_valid;
 logic  a_res_st_ps_wr_ready;
 logic [1023:0]  a_res_st_ps_wr_mask;
 logic [1023:0][3:0]  a_res_st_ps_wr_addr;
 logic [1023:0][31:0]  a_res_st_ps_wr_data;
 logic [95:0]  a_res_st_ps_wr_tag;
 logic  a_res_st_ps_wr_rsp_valid;
 logic  a_res_st_ps_wr_rsp_ready;
 logic [95:0]  a_res_st_ps_wr_rsp_tag;
 logic  a_res_st_ps_rd_valid;
 logic  a_res_st_ps_rd_ready;
 logic [1023:0]  a_res_st_ps_rd_mask;
 logic [1023:0][3:0]  a_res_st_ps_rd_addr;
 logic [95:0]  a_res_st_ps_rd_tag;
 logic  a_res_st_ps_rd_rsp_valid;
 logic  a_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0]  a_res_st_ps_rd_rsp_data;
 logic [1023:0]  a_res_st_ps_rd_rsp_mask;
 logic [95:0]  a_res_st_ps_rd_rsp_tag;
 logic  a_res_st_g_wr_valid;
 logic  a_res_st_g_wr_ready;
 logic [255:0]  a_res_st_g_wr_mask;
 logic [255:0][5:0]  a_res_st_g_wr_addr;
 logic [255:0][31:0]  a_res_st_g_wr_data;
 logic [95:0]  a_res_st_g_wr_tag;
 logic  a_res_st_g_wr_rsp_valid;
 logic  a_res_st_g_wr_rsp_ready;
 logic [95:0]  a_res_st_g_wr_rsp_tag;
 logic  a_res_st_g_rd_valid;
 logic  a_res_st_g_rd_ready;
 logic [255:0]  a_res_st_g_rd_mask;
 logic [255:0][5:0]  a_res_st_g_rd_addr;
 logic [95:0]  a_res_st_g_rd_tag;
 logic  a_res_st_g_rd_rsp_valid;
 logic  a_res_st_g_rd_rsp_ready;
 logic [255:0][31:0]  a_res_st_g_rd_rsp_data;
 logic [255:0]  a_res_st_g_rd_rsp_mask;
 logic [95:0]  a_res_st_g_rd_rsp_tag;
 logic  a_res_st_context_wr_valid;
 logic  a_res_st_context_wr_ready;
 logic [63:0]  a_res_st_context_wr_mask;
 logic [63:0][10:0]  a_res_st_context_wr_addr;
 logic [63:0][31:0]  a_res_st_context_wr_data;
 logic [95:0]  a_res_st_context_wr_tag;
 logic  a_res_st_context_wr_rsp_valid;
 logic  a_res_st_context_wr_rsp_ready;
 logic [95:0]  a_res_st_context_wr_rsp_tag;
 logic  a_res_st_context_rd_valid;
 logic  a_res_st_context_rd_ready;
 logic [63:0]  a_res_st_context_rd_mask;
 logic [63:0][10:0]  a_res_st_context_rd_addr;
 logic [95:0]  a_res_st_context_rd_tag;
 logic  a_res_st_context_rd_rsp_valid;
 logic  a_res_st_context_rd_rsp_ready;
 logic [63:0][31:0]  a_res_st_context_rd_rsp_data;
 logic [63:0]  a_res_st_context_rd_rsp_mask;
 logic [95:0]  a_res_st_context_rd_rsp_tag;
 logic  a_res_st_idle;
 logic  a_res_fp_lease_valid;
 logic  a_res_fp_lease_ready;
 logic [63:0]  a_res_fp_lease_request_id;
 logic [31:0]  a_res_fp_lease_generation;
 logic [31:0]  a_res_fp_lease_epoch;
 logic [3:0]  a_res_fp_lease_head;
 logic [2:0]  a_res_fp_lease_phase;
 logic  a_res_fp_release_valid;
 logic  a_res_fp_release_ready;
 logic [2:0]  a_res_fp_release_phase;
 logic [31:0]  a_res_fp_release_epoch;
 logic  a_res_fp_phase_debt_clear;
 logic  a_res_fp_lease_active;
 logic  a_res_fp_draining;
 logic [63:0]  a_res_fp_rsp_request_id;
 logic [31:0]  a_res_fp_rsp_generation;
 logic [31:0]  a_res_fp_rsp_epoch;
 logic [3:0]  a_res_fp_rsp_head;
 logic [2:0]  a_res_fp_rsp_phase;
 logic  a_res_fp_mul_req_valid;
 logic  a_res_fp_mul_req_ready;
 logic [2:0]  a_res_fp_mul_req_phase;
 logic [31:0]  a_res_fp_mul_req_epoch;
 logic [95:0]  a_res_fp_mul_req_tag;
 logic [255:0][31:0]  a_res_fp_mul_a;
 logic [255:0][31:0]  a_res_fp_mul_b;
 logic  a_res_fp_mul_rsp_valid;
 logic  a_res_fp_mul_rsp_ready;
 logic [95:0]  a_res_fp_mul_rsp_tag;
 logic [255:0][31:0]  a_res_fp_mul_rsp_data;
 logic [6:0]  a_res_fp_add_req_valid;
 logic [6:0]  a_res_fp_add_req_is_root;
 logic [6:0]  a_res_fp_add_req_ready;
 logic [6:0][2:0]  a_res_fp_add_req_phase;
 logic [6:0][31:0]  a_res_fp_add_req_epoch;
 logic [6:0][95:0]  a_res_fp_add_req_tag;
 logic [255:0][31:0]  a_res_fp_add_a;
 logic [255:0][31:0]  a_res_fp_add_b;
 logic [6:0]  a_res_fp_add_rsp_valid;
 logic [6:0]  a_res_fp_add_rsp_ready;
 logic [6:0][95:0]  a_res_fp_add_rsp_tag;
 logic [255:0][31:0]  a_res_fp_add_rsp_data;
 logic [6:0]  a_res_fp_mul_pending;
 logic [6:0][6:0]  a_res_fp_add_pending;
 logic  a_res_fp_protocol_fault;
 logic  a_res_ln_bind_valid;
 logic  a_res_ln_bind_ready;
 logic [63:0]  a_res_ln_bind_request_id;
 logic [31:0]  a_res_ln_bind_generation;
 logic [31:0]  a_res_ln_bind_epoch;
 logic [3:0]  a_res_ln_bind_head;
 logic [2:0]  a_res_ln_bind_phase;
 logic [63:0]  a_res_ln_op_request_id;
 logic [31:0]  a_res_ln_op_generation;
 logic [31:0]  a_res_ln_op_epoch;
 logic [2:0]  a_res_ln_op_phase;
 logic [63:0]  a_res_ln_rsp_request_id;
 logic [31:0]  a_res_ln_rsp_generation;
 logic [31:0]  a_res_ln_rsp_epoch;
 logic [3:0]  a_res_ln_rsp_head;
 logic [2:0]  a_res_ln_rsp_phase;
 logic  a_res_ln_wr_valid;
 logic  a_res_ln_wr_ready;
 logic [255:0]  a_res_ln_wr_mask;
 logic [255:0][4:0]  a_res_ln_wr_addr;
 logic [255:0][31:0]  a_res_ln_wr_data;
 logic [95:0]  a_res_ln_wr_tag;
 logic  a_res_ln_wr_rsp_valid;
 logic  a_res_ln_wr_rsp_ready;
 logic [95:0]  a_res_ln_wr_rsp_tag;
 logic  a_res_ln_rd_valid;
 logic  a_res_ln_rd_ready;
 logic [255:0]  a_res_ln_rd_mask;
 logic [255:0][4:0]  a_res_ln_rd_addr;
 logic [95:0]  a_res_ln_rd_tag;
 logic  a_res_ln_rd_rsp_valid;
 logic  a_res_ln_rd_rsp_ready;
 logic [255:0][31:0]  a_res_ln_rd_rsp_data;
 logic [255:0]  a_res_ln_rd_rsp_mask;
 logic [95:0]  a_res_ln_rd_rsp_tag;
 logic  a_res_ln_idle;
 logic  a_res_sfu_lease_valid;
 logic  a_res_sfu_lease_ready;
 logic [63:0]  a_res_sfu_lease_request_id;
 logic [31:0]  a_res_sfu_lease_generation;
 logic [31:0]  a_res_sfu_lease_epoch;
 logic [3:0]  a_res_sfu_lease_head;
 logic [2:0]  a_res_sfu_lease_phase;
 logic  a_res_sfu_release_valid;
 logic [2:0]  a_res_sfu_release_phase;
 logic [31:0]  a_res_sfu_release_epoch;
 logic  a_res_sfu_phase_debt_clear;
 logic  a_res_sfu_lease_active;
 logic [63:0]  a_res_sfu_context_valid;
 logic [63:0]  a_res_sfu_context_row_hi;
 logic  a_res_sfu_req_valid;
 logic  a_res_sfu_req_ready;
 logic [1:0]  a_res_sfu_req_mode;
 logic [31:0]  a_res_sfu_req_generation;
 logic [31:0]  a_res_sfu_req_epoch;
 logic [2:0]  a_res_sfu_req_phase;
 logic [10:0]  a_res_sfu_req_tag;
 logic [7:0][31:0]  a_res_sfu_req_x;
 logic  a_res_sfu_reject_valid;
 logic  a_res_sfu_rsp_valid;
 logic  a_res_sfu_rsp_ready;
 logic [10:0]  a_res_sfu_rsp_tag;
 logic [7:0][31:0]  a_res_sfu_rsp_data;
 logic [8:0]  a_res_sfu_pending_vectors;
 logic [8:0]  a_res_sfu_in_flight_vectors;
 logic  a_res_sfu_protocol_fault;
 logic  a_res_div_lease_valid;
 logic  a_res_div_lease_ready;
 logic [63:0]  a_res_div_lease_request_id;
 logic [31:0]  a_res_div_lease_generation;
 logic [31:0]  a_res_div_lease_epoch;
 logic [3:0]  a_res_div_lease_head;
 logic [2:0]  a_res_div_lease_phase;
 logic  a_res_div_release_valid;
 logic [2:0]  a_res_div_release_phase;
 logic [31:0]  a_res_div_release_epoch;
 logic  a_res_div_phase_debt_clear;
 logic  a_res_div_lease_active;
 logic  a_res_div_req_valid;
 logic  a_res_div_req_ready;
 logic [31:0]  a_res_div_req_generation;
 logic [31:0]  a_res_div_req_epoch;
 logic [2:0]  a_res_div_req_phase;
 logic [7:0]  a_res_div_req_lane_mask;
 logic [95:0]  a_res_div_req_tag;
 logic [7:0][31:0]  a_res_div_req_a;
 logic [7:0][31:0]  a_res_div_req_b;
 logic  a_res_div_protocol_reject_valid;
 logic  a_res_div_rsp_valid;
 logic  a_res_div_rsp_ready;
 logic [95:0]  a_res_div_rsp_tag;
 logic [7:0]  a_res_div_rsp_numeric_error;
 logic [7:0][31:0]  a_res_div_rsp_data;
 logic [5:0]  a_res_div_pending_vectors;
 logic [5:0]  a_res_div_in_flight_vectors;
 logic [8:0]  a_res_div_in_flight_scalars;
 logic  a_res_div_protocol_fault;
 logic  a_res_scale_valid;
 logic  a_res_scale_ready;
 logic [95:0]  a_res_scale_tag;
 logic [3:0][31:0]  a_res_scale_input;
 logic  a_res_scale_rsp_valid;
 logic  a_res_scale_rsp_ready;
 logic [95:0]  a_res_scale_rsp_tag;
 logic [3:0][31:0]  a_res_scale_data;
 logic [6:0]  a_res_scale_pending;
 logic  a_res_scale_fault;
 logic  a_rope_owner_valid;
 logic [63:0]  a_rope_owner_request_id;
 logic [31:0]  a_rope_owner_generation;
 logic [31:0]  a_rope_owner_epoch;
 logic  a_rope_wr_valid;
 logic  a_rope_wr_ready;
 logic [63:0]  a_rope_wr_request_id;
 logic [31:0]  a_rope_wr_generation;
 logic [31:0]  a_rope_wr_epoch;
 logic [3:0]  a_rope_wr_head;
 logic [6:0]  a_rope_wr_token;
 logic [95:0]  a_rope_wr_tag;
 logic [63:0][31:0]  a_rope_wr_q;
 logic [63:0][31:0]  a_rope_wr_k;
 logic  a_rope_wr_commit_valid;
 logic [95:0]  a_rope_wr_commit_tag;
 logic  a_rope_reject_valid;
 logic [2:0]  a_rope_reject_code;
 logic  a_cache_bound_valid;
 logic [127:0]  a_cache_bound_model_id;
 logic [127:0]  a_cache_bound_numeric_id;
 logic [127:0]  a_cache_bound_table_key;
 logic [1:0]  a_cache_family_complete;
 logic  a_cache_owner_valid;
 logic [63:0]  a_cache_owner_request_id;
 logic [31:0]  a_cache_owner_generation;
 logic [31:0]  a_cache_owner_epoch;
 logic  a_cache_rd_valid;
 logic  a_cache_rd_ready;
 logic  a_cache_rd_family;
 logic [6:0]  a_cache_rd_row;
 logic [95:0]  a_cache_rd_tag;
 logic [63:0]  a_cache_rd_request_id;
 logic [31:0]  a_cache_rd_generation;
 logic [31:0]  a_cache_rd_epoch;
 logic  a_cache_rd_reject_valid;
 logic [2:0]  a_cache_rd_reject_code;
 logic  a_cache_rsp_valid;
 logic  a_cache_rsp_ready;
 logic  a_cache_rsp_family;
 logic [6:0]  a_cache_rsp_row;
 logic [95:0]  a_cache_rsp_tag;
 logic [127:0][31:0]  a_cache_rsp_data;
 logic storage_bind_ready,lease_ready,lease_active,draining,storage_idle;
 logic actual_bind,resource_owned,pool_reset_n,pool_fault,sfu_fault,sfu_reject;
 logic [1:0] sfu_reject_code;
 logic [63:0] storage_rid,sfu_rid;logic [31:0] storage_gen,storage_epoch,sfu_gen,sfu_epoch;
 logic [2:0] storage_phase,sfu_phase;
 logic [8:0] fp_req_valid,fp_req_ready;logic [8:0][95:0] fp_req_tag;
 logic [8:0][7:0][31:0] fp_req_a,fp_req_b;
 logic sfu_req_valid,sfu_req_ready,tanh_release_ready;
 logic [95:0] sfu_req_tag;logic [7:0] sfu_req_mask;logic [7:0][31:0] sfu_req_x;
 logic [255:0] g_wr_mask,g_rd_mask,g_rd_rsp_mask;
 logic [255:0][5:0] g_wr_addr,g_rd_addr;
 logic [255:0][31:0] g_wr_data,g_rd_rsp_data;logic [95:0] g_wr_tag;
 assign a_prepare_request_id=request_id;
 assign a_prepare_model_id='0;
 assign a_prepare_generation=generation;
 assign a_prepare_epoch=epoch;
 assign a_prepare_numeric_id='0;
 assign a_prepare_table_key='0;
 assign a_prepare_kind=2'd2;
 assign a_prepare_layer='0;
 assign a_prepare_mask='0;
 assign a_qkv_wr_request_id=request_id;
 assign a_qkv_wr_generation=generation;
 assign a_qkv_wr_epoch=epoch;
 assign a_start_valid='0;
 assign a_start_request_id='0;
 assign a_start_generation='0;
 assign a_abort_valid='0;
 assign a_qkv_read_grant='0;
 assign a_ps_grant='0;
 assign a_g_grant='0;
 assign a_context_grant='0;
 assign a_fp_grant='0;
 assign a_sfu_grant='0;
 assign a_exp_grant='0;
 assign a_div_grant='0;
 assign a_done_ready='0;
 assign a_result_rd_valid='0;
 assign a_result_rd_generation='0;
 assign a_result_rd_tag='0;
 assign a_result_rd_head='0;
 assign a_result_rd_query='0;
 assign a_result_rd_half='0;
 assign a_result_rsp_ready='0;
 assign a_result_discard_valid='0;
 assign a_result_discard_generation='0;
 assign a_prepare_cancel_request_id=request_id;
 assign a_prepare_cancel_generation=generation;
 assign a_prepare_cancel_epoch=epoch;
 assign a_res_st_bind_ready=storage_bind_ready;
 assign a_res_st_rsp_request_id='0;
 assign a_res_st_rsp_generation='0;
 assign a_res_st_rsp_epoch='0;
 assign a_res_st_rsp_head='0;
 assign a_res_st_rsp_phase='0;
 assign a_res_st_ps_wr_ready='0;
 assign a_res_st_ps_wr_rsp_valid='0;
 assign a_res_st_ps_wr_rsp_tag='0;
 assign a_res_st_ps_rd_ready='0;
 assign a_res_st_ps_rd_rsp_valid='0;
 assign a_res_st_ps_rd_rsp_data='0;
 assign a_res_st_ps_rd_rsp_mask='0;
 assign a_res_st_ps_rd_rsp_tag='0;
 assign a_res_st_g_wr_ready='0;
 assign a_res_st_g_wr_rsp_valid='0;
 assign a_res_st_g_wr_rsp_tag='0;
 assign a_res_st_g_rd_ready='0;
 assign a_res_st_g_rd_rsp_valid='0;
 assign a_res_st_g_rd_rsp_data='0;
 assign a_res_st_g_rd_rsp_mask='0;
 assign a_res_st_g_rd_rsp_tag='0;
 assign a_res_st_context_wr_ready='0;
 assign a_res_st_context_wr_rsp_valid='0;
 assign a_res_st_context_wr_rsp_tag='0;
 assign a_res_st_context_rd_ready='0;
 assign a_res_st_context_rd_rsp_valid='0;
 assign a_res_st_context_rd_rsp_data='0;
 assign a_res_st_context_rd_rsp_mask='0;
 assign a_res_st_context_rd_rsp_tag='0;
 assign a_res_st_idle=storage_idle;
 assign a_res_fp_lease_ready=1'b1;
 assign a_res_fp_release_ready='0;
 assign a_res_fp_lease_active='0;
 assign a_res_fp_draining='0;
 assign a_res_fp_rsp_request_id='0;
 assign a_res_fp_rsp_generation='0;
 assign a_res_fp_rsp_epoch='0;
 assign a_res_fp_rsp_head='0;
 assign a_res_fp_rsp_phase='0;
 assign a_res_fp_mul_req_ready='0;
 assign a_res_fp_mul_rsp_valid='0;
 assign a_res_fp_mul_rsp_tag='0;
 assign a_res_fp_mul_rsp_data='0;
 assign a_res_fp_add_req_ready='0;
 assign a_res_fp_add_rsp_valid='0;
 assign a_res_fp_add_rsp_tag='0;
 assign a_res_fp_add_rsp_data='0;
 assign a_res_fp_mul_pending='0;
 assign a_res_fp_add_pending='0;
 assign a_res_fp_protocol_fault='0;
 assign a_res_ln_bind_ready='0;
 assign a_res_ln_rsp_request_id='0;
 assign a_res_ln_rsp_generation='0;
 assign a_res_ln_rsp_epoch='0;
 assign a_res_ln_rsp_head='0;
 assign a_res_ln_rsp_phase='0;
 assign a_res_ln_wr_ready='0;
 assign a_res_ln_wr_rsp_valid='0;
 assign a_res_ln_wr_rsp_tag='0;
 assign a_res_ln_rd_ready='0;
 assign a_res_ln_rd_rsp_valid='0;
 assign a_res_ln_rd_rsp_data='0;
 assign a_res_ln_rd_rsp_mask='0;
 assign a_res_ln_rd_rsp_tag='0;
 assign a_res_ln_idle=1'b1;
 assign a_res_sfu_lease_ready='0;
 assign a_res_sfu_lease_active=lease_active;
 assign a_res_sfu_req_ready='0;
 assign a_res_sfu_reject_valid='0;
 assign a_res_sfu_rsp_valid='0;
 assign a_res_sfu_rsp_tag='0;
 assign a_res_sfu_rsp_data='0;
 assign a_res_sfu_pending_vectors=sfu_pending;
 assign a_res_sfu_in_flight_vectors=sfu_flight;
 assign a_res_sfu_protocol_fault='0;
 assign a_res_div_lease_ready='0;
 assign a_res_div_lease_active='0;
 assign a_res_div_req_ready='0;
 assign a_res_div_protocol_reject_valid='0;
 assign a_res_div_rsp_valid='0;
 assign a_res_div_rsp_tag='0;
 assign a_res_div_rsp_numeric_error='0;
 assign a_res_div_rsp_data='0;
 assign a_res_div_pending_vectors='0;
 assign a_res_div_in_flight_vectors='0;
 assign a_res_div_in_flight_scalars='0;
 assign a_res_div_protocol_fault='0;
 assign a_res_scale_ready='0;
 assign a_res_scale_rsp_valid='0;
 assign a_res_scale_rsp_tag='0;
 assign a_res_scale_data='0;
 assign a_res_scale_pending='0;
 assign a_res_scale_fault='0;
 assign a_cache_bound_valid='0;
 assign a_cache_bound_model_id='0;
 assign a_cache_bound_numeric_id='0;
 assign a_cache_bound_table_key='0;
 assign a_cache_family_complete='0;
 assign a_cache_rd_ready='0;
 assign a_cache_rd_reject_valid='0;
 assign a_cache_rd_reject_code='0;
 assign a_cache_rsp_valid='0;
 assign a_cache_rsp_family='0;
 assign a_cache_rsp_row='0;
 assign a_cache_rsp_tag='0;
 assign a_cache_rsp_data='0;
 assign slot_release_fire=joint.g_engine.pair_release_valid&&joint.g_engine.pair_release_ready;
 assign slot_release_slot=joint.g_engine.pair_release_slot;
 assign slot_release_s=joint.g_engine.pair_release_s;
 assign bind_ready=rst_n&&!resource_owned&&storage_bind_ready&&lease_ready&&engine_idle;
 assign actual_bind=bind_valid&&bind_ready;
 assign resources_bound=resource_owned&&lease_active&&storage_rid==request_id&&storage_gen==generation&&storage_epoch==epoch&&storage_phase==1&&
  sfu_rid==request_id&&sfu_gen==generation&&sfu_epoch==epoch&&sfu_phase==1;
 assign release_ready=resources_bound&&engine_idle&&storage_idle&&sfu_pending==0&&sfu_flight==0&&tanh_release_ready;
 always_ff @(posedge clk)begin
  if(!rst_n)resource_owned<=0;
  else begin if(actual_bind)resource_owned<=1;if(release_valid&&release_ready)resource_owned<=0;end
 end
 laya_m007_control_workspace_joint_v1 joint(.g_producer_cancel_valid(producer_cancel_valid),.g_producer_cancel_request_id(producer_cancel_request_id),.g_producer_cancel_generation(producer_cancel_generation),.g_producer_cancel_epoch(producer_cancel_epoch),.g_producer_cancel_ready(producer_cancel_ready),.g_producer_cancel_reject_valid(producer_cancel_reject_valid),.g_done_cancelled(done_cancelled),.owner_req_valid,.owner_req_g,.owner_req_ready,.a_enable,.g_enable,.rearm,.owner_g,.a_prepare_valid(a_prepare_valid),.a_prepare_ready(a_prepare_ready),.a_prepare_request_id(a_prepare_request_id),.a_prepare_model_id(a_prepare_model_id),.a_prepare_generation(a_prepare_generation),.a_prepare_epoch(a_prepare_epoch),.a_prepare_numeric_id(a_prepare_numeric_id),.a_prepare_table_key(a_prepare_table_key),.a_prepare_kind(a_prepare_kind),.a_prepare_layer(a_prepare_layer),.a_prepare_mask(a_prepare_mask),.a_qkv_wr_valid(a_qkv_wr_valid),.a_qkv_wr_ready(a_qkv_wr_ready),.a_qkv_wr_request_id(a_qkv_wr_request_id),.a_qkv_wr_generation(a_qkv_wr_generation),.a_qkv_wr_epoch(a_qkv_wr_epoch),.a_qkv_wr_plane(a_qkv_wr_plane),.a_qkv_wr_head(a_qkv_wr_head),.a_qkv_wr_token(a_qkv_wr_token),.a_qkv_wr_half(a_qkv_wr_half),.a_qkv_wr_data(a_qkv_wr_data),.a_start_valid(a_start_valid),.a_start_ready(a_start_ready),.a_start_request_id(a_start_request_id),.a_start_generation(a_start_generation),.a_reject_valid(a_reject_valid),.a_reject_code(a_reject_code),.a_abort_valid(a_abort_valid),.a_abort_ready(a_abort_ready),.a_qkv_read_grant(a_qkv_read_grant),.a_ps_grant(a_ps_grant),.a_g_grant(a_g_grant),.a_context_grant(a_context_grant),.a_fp_grant(a_fp_grant),.a_sfu_grant(a_sfu_grant),.a_exp_grant(a_exp_grant),.a_div_grant(a_div_grant),.a_rope_write_grant(a_rope_write_grant),.a_done_valid(a_done_valid),.a_done_ready(a_done_ready),.a_done_request_id(a_done_request_id),.a_done_generation(a_done_generation),.a_done_status(a_done_status),.a_done_cycles(a_done_cycles),.a_rope_cycles(a_rope_cycles),.a_head_completed(a_head_completed),.a_head_context_valid(a_head_context_valid),.a_active_head(a_active_head),.a_error_valid(a_error_valid),.a_error_tuple(a_error_tuple),.a_check_completed(a_check_completed),.a_check_unreachable(a_check_unreachable),.a_check_dominated(a_check_dominated),.a_av_check_completed(a_av_check_completed),.a_av_check_unreachable(a_av_check_unreachable),.a_av_check_dominated(a_av_check_dominated),.a_result_rd_valid(a_result_rd_valid),.a_result_rd_ready(a_result_rd_ready),.a_result_rd_generation(a_result_rd_generation),.a_result_rd_tag(a_result_rd_tag),.a_result_rd_head(a_result_rd_head),.a_result_rd_query(a_result_rd_query),.a_result_rd_half(a_result_rd_half),.a_result_rsp_valid(a_result_rsp_valid),.a_result_rsp_ready(a_result_rsp_ready),.a_result_rsp_tag(a_result_rsp_tag),.a_result_rsp_data(a_result_rsp_data),.a_result_discard_valid(a_result_discard_valid),.a_result_discard_ready(a_result_discard_ready),.a_result_discard_generation(a_result_discard_generation),.a_context_discarded(a_context_discarded),.a_producer_done_cycles(a_producer_done_cycles),.a_context_release_cycles(a_context_release_cycles),.a_prepare_cancel_valid(a_prepare_cancel_valid),.a_prepare_cancel_ready(a_prepare_cancel_ready),.a_prepare_cancel_request_id(a_prepare_cancel_request_id),.a_prepare_cancel_generation(a_prepare_cancel_generation),.a_prepare_cancel_epoch(a_prepare_cancel_epoch),.a_prepare_cancel_rsp_valid(a_prepare_cancel_rsp_valid),.a_prepare_cancel_rsp_ready(a_prepare_cancel_rsp_ready),.a_prepare_cancel_rsp_request_id(a_prepare_cancel_rsp_request_id),.a_prepare_cancel_rsp_generation(a_prepare_cancel_rsp_generation),.a_prepare_cancel_rsp_epoch(a_prepare_cancel_rsp_epoch),.a_prepare_cancel_rsp_status(a_prepare_cancel_rsp_status),.a_layer_idle(a_layer_idle),.a_check_coverage_fault(a_check_coverage_fault),.a_check_first_conflict(a_check_first_conflict),.a_res_qkv_wr_valid(a_res_qkv_wr_valid),.a_res_qkv_wr_ready(a_res_qkv_wr_ready),.a_res_qkv_wr_plane(a_res_qkv_wr_plane),.a_res_qkv_wr_head(a_res_qkv_wr_head),.a_res_qkv_wr_token(a_res_qkv_wr_token),.a_res_qkv_wr_half(a_res_qkv_wr_half),.a_res_qkv_wr_data(a_res_qkv_wr_data),.a_res_qkv_rd_valid(a_res_qkv_rd_valid),.a_res_qkv_rd_ready(a_res_qkv_rd_ready),.a_res_qkv_rd_head(a_res_qkv_rd_head),.a_res_qkv_rd_token(a_res_qkv_rd_token),.a_res_qkv_rd_tag(a_res_qkv_rd_tag),.a_res_qkv_rd_rsp_valid(a_res_qkv_rd_rsp_valid),.a_res_qkv_rd_rsp_ready(a_res_qkv_rd_rsp_ready),.a_res_qkv_rd_rsp_head(a_res_qkv_rd_rsp_head),.a_res_qkv_rd_rsp_token(a_res_qkv_rd_rsp_token),.a_res_qkv_rd_rsp_tag(a_res_qkv_rd_rsp_tag),.a_res_qkv_rd_rsp_data(a_res_qkv_rd_rsp_data),.a_res_st_bind_valid(a_res_st_bind_valid),.a_res_st_bind_ready(a_res_st_bind_ready),.a_res_st_bind_request_id(a_res_st_bind_request_id),.a_res_st_bind_generation(a_res_st_bind_generation),.a_res_st_bind_epoch(a_res_st_bind_epoch),.a_res_st_bind_head(a_res_st_bind_head),.a_res_st_bind_phase(a_res_st_bind_phase),.a_res_st_op_request_id(a_res_st_op_request_id),.a_res_st_op_generation(a_res_st_op_generation),.a_res_st_op_epoch(a_res_st_op_epoch),.a_res_st_op_phase(a_res_st_op_phase),.a_res_st_rsp_request_id(a_res_st_rsp_request_id),.a_res_st_rsp_generation(a_res_st_rsp_generation),.a_res_st_rsp_epoch(a_res_st_rsp_epoch),.a_res_st_rsp_head(a_res_st_rsp_head),.a_res_st_rsp_phase(a_res_st_rsp_phase),.a_res_st_ps_wr_valid(a_res_st_ps_wr_valid),.a_res_st_ps_wr_ready(a_res_st_ps_wr_ready),.a_res_st_ps_wr_mask(a_res_st_ps_wr_mask),.a_res_st_ps_wr_addr(a_res_st_ps_wr_addr),.a_res_st_ps_wr_data(a_res_st_ps_wr_data),.a_res_st_ps_wr_tag(a_res_st_ps_wr_tag),.a_res_st_ps_wr_rsp_valid(a_res_st_ps_wr_rsp_valid),.a_res_st_ps_wr_rsp_ready(a_res_st_ps_wr_rsp_ready),.a_res_st_ps_wr_rsp_tag(a_res_st_ps_wr_rsp_tag),.a_res_st_ps_rd_valid(a_res_st_ps_rd_valid),.a_res_st_ps_rd_ready(a_res_st_ps_rd_ready),.a_res_st_ps_rd_mask(a_res_st_ps_rd_mask),.a_res_st_ps_rd_addr(a_res_st_ps_rd_addr),.a_res_st_ps_rd_tag(a_res_st_ps_rd_tag),.a_res_st_ps_rd_rsp_valid(a_res_st_ps_rd_rsp_valid),.a_res_st_ps_rd_rsp_ready(a_res_st_ps_rd_rsp_ready),.a_res_st_ps_rd_rsp_data(a_res_st_ps_rd_rsp_data),.a_res_st_ps_rd_rsp_mask(a_res_st_ps_rd_rsp_mask),.a_res_st_ps_rd_rsp_tag(a_res_st_ps_rd_rsp_tag),.a_res_st_g_wr_valid(a_res_st_g_wr_valid),.a_res_st_g_wr_ready(a_res_st_g_wr_ready),.a_res_st_g_wr_mask(a_res_st_g_wr_mask),.a_res_st_g_wr_addr(a_res_st_g_wr_addr),.a_res_st_g_wr_data(a_res_st_g_wr_data),.a_res_st_g_wr_tag(a_res_st_g_wr_tag),.a_res_st_g_wr_rsp_valid(a_res_st_g_wr_rsp_valid),.a_res_st_g_wr_rsp_ready(a_res_st_g_wr_rsp_ready),.a_res_st_g_wr_rsp_tag(a_res_st_g_wr_rsp_tag),.a_res_st_g_rd_valid(a_res_st_g_rd_valid),.a_res_st_g_rd_ready(a_res_st_g_rd_ready),.a_res_st_g_rd_mask(a_res_st_g_rd_mask),.a_res_st_g_rd_addr(a_res_st_g_rd_addr),.a_res_st_g_rd_tag(a_res_st_g_rd_tag),.a_res_st_g_rd_rsp_valid(a_res_st_g_rd_rsp_valid),.a_res_st_g_rd_rsp_ready(a_res_st_g_rd_rsp_ready),.a_res_st_g_rd_rsp_data(a_res_st_g_rd_rsp_data),.a_res_st_g_rd_rsp_mask(a_res_st_g_rd_rsp_mask),.a_res_st_g_rd_rsp_tag(a_res_st_g_rd_rsp_tag),.a_res_st_context_wr_valid(a_res_st_context_wr_valid),.a_res_st_context_wr_ready(a_res_st_context_wr_ready),.a_res_st_context_wr_mask(a_res_st_context_wr_mask),.a_res_st_context_wr_addr(a_res_st_context_wr_addr),.a_res_st_context_wr_data(a_res_st_context_wr_data),.a_res_st_context_wr_tag(a_res_st_context_wr_tag),.a_res_st_context_wr_rsp_valid(a_res_st_context_wr_rsp_valid),.a_res_st_context_wr_rsp_ready(a_res_st_context_wr_rsp_ready),.a_res_st_context_wr_rsp_tag(a_res_st_context_wr_rsp_tag),.a_res_st_context_rd_valid(a_res_st_context_rd_valid),.a_res_st_context_rd_ready(a_res_st_context_rd_ready),.a_res_st_context_rd_mask(a_res_st_context_rd_mask),.a_res_st_context_rd_addr(a_res_st_context_rd_addr),.a_res_st_context_rd_tag(a_res_st_context_rd_tag),.a_res_st_context_rd_rsp_valid(a_res_st_context_rd_rsp_valid),.a_res_st_context_rd_rsp_ready(a_res_st_context_rd_rsp_ready),.a_res_st_context_rd_rsp_data(a_res_st_context_rd_rsp_data),.a_res_st_context_rd_rsp_mask(a_res_st_context_rd_rsp_mask),.a_res_st_context_rd_rsp_tag(a_res_st_context_rd_rsp_tag),.a_res_st_idle(a_res_st_idle),.a_res_fp_lease_valid(a_res_fp_lease_valid),.a_res_fp_lease_ready(a_res_fp_lease_ready),.a_res_fp_lease_request_id(a_res_fp_lease_request_id),.a_res_fp_lease_generation(a_res_fp_lease_generation),.a_res_fp_lease_epoch(a_res_fp_lease_epoch),.a_res_fp_lease_head(a_res_fp_lease_head),.a_res_fp_lease_phase(a_res_fp_lease_phase),.a_res_fp_release_valid(a_res_fp_release_valid),.a_res_fp_release_ready(a_res_fp_release_ready),.a_res_fp_release_phase(a_res_fp_release_phase),.a_res_fp_release_epoch(a_res_fp_release_epoch),.a_res_fp_phase_debt_clear(a_res_fp_phase_debt_clear),.a_res_fp_lease_active(a_res_fp_lease_active),.a_res_fp_draining(a_res_fp_draining),.a_res_fp_rsp_request_id(a_res_fp_rsp_request_id),.a_res_fp_rsp_generation(a_res_fp_rsp_generation),.a_res_fp_rsp_epoch(a_res_fp_rsp_epoch),.a_res_fp_rsp_head(a_res_fp_rsp_head),.a_res_fp_rsp_phase(a_res_fp_rsp_phase),.a_res_fp_mul_req_valid(a_res_fp_mul_req_valid),.a_res_fp_mul_req_ready(a_res_fp_mul_req_ready),.a_res_fp_mul_req_phase(a_res_fp_mul_req_phase),.a_res_fp_mul_req_epoch(a_res_fp_mul_req_epoch),.a_res_fp_mul_req_tag(a_res_fp_mul_req_tag),.a_res_fp_mul_a(a_res_fp_mul_a),.a_res_fp_mul_b(a_res_fp_mul_b),.a_res_fp_mul_rsp_valid(a_res_fp_mul_rsp_valid),.a_res_fp_mul_rsp_ready(a_res_fp_mul_rsp_ready),.a_res_fp_mul_rsp_tag(a_res_fp_mul_rsp_tag),.a_res_fp_mul_rsp_data(a_res_fp_mul_rsp_data),.a_res_fp_add_req_valid(a_res_fp_add_req_valid),.a_res_fp_add_req_is_root(a_res_fp_add_req_is_root),.a_res_fp_add_req_ready(a_res_fp_add_req_ready),.a_res_fp_add_req_phase(a_res_fp_add_req_phase),.a_res_fp_add_req_epoch(a_res_fp_add_req_epoch),.a_res_fp_add_req_tag(a_res_fp_add_req_tag),.a_res_fp_add_a(a_res_fp_add_a),.a_res_fp_add_b(a_res_fp_add_b),.a_res_fp_add_rsp_valid(a_res_fp_add_rsp_valid),.a_res_fp_add_rsp_ready(a_res_fp_add_rsp_ready),.a_res_fp_add_rsp_tag(a_res_fp_add_rsp_tag),.a_res_fp_add_rsp_data(a_res_fp_add_rsp_data),.a_res_fp_mul_pending(a_res_fp_mul_pending),.a_res_fp_add_pending(a_res_fp_add_pending),.a_res_fp_protocol_fault(a_res_fp_protocol_fault),.a_res_ln_bind_valid(a_res_ln_bind_valid),.a_res_ln_bind_ready(a_res_ln_bind_ready),.a_res_ln_bind_request_id(a_res_ln_bind_request_id),.a_res_ln_bind_generation(a_res_ln_bind_generation),.a_res_ln_bind_epoch(a_res_ln_bind_epoch),.a_res_ln_bind_head(a_res_ln_bind_head),.a_res_ln_bind_phase(a_res_ln_bind_phase),.a_res_ln_op_request_id(a_res_ln_op_request_id),.a_res_ln_op_generation(a_res_ln_op_generation),.a_res_ln_op_epoch(a_res_ln_op_epoch),.a_res_ln_op_phase(a_res_ln_op_phase),.a_res_ln_rsp_request_id(a_res_ln_rsp_request_id),.a_res_ln_rsp_generation(a_res_ln_rsp_generation),.a_res_ln_rsp_epoch(a_res_ln_rsp_epoch),.a_res_ln_rsp_head(a_res_ln_rsp_head),.a_res_ln_rsp_phase(a_res_ln_rsp_phase),.a_res_ln_wr_valid(a_res_ln_wr_valid),.a_res_ln_wr_ready(a_res_ln_wr_ready),.a_res_ln_wr_mask(a_res_ln_wr_mask),.a_res_ln_wr_addr(a_res_ln_wr_addr),.a_res_ln_wr_data(a_res_ln_wr_data),.a_res_ln_wr_tag(a_res_ln_wr_tag),.a_res_ln_wr_rsp_valid(a_res_ln_wr_rsp_valid),.a_res_ln_wr_rsp_ready(a_res_ln_wr_rsp_ready),.a_res_ln_wr_rsp_tag(a_res_ln_wr_rsp_tag),.a_res_ln_rd_valid(a_res_ln_rd_valid),.a_res_ln_rd_ready(a_res_ln_rd_ready),.a_res_ln_rd_mask(a_res_ln_rd_mask),.a_res_ln_rd_addr(a_res_ln_rd_addr),.a_res_ln_rd_tag(a_res_ln_rd_tag),.a_res_ln_rd_rsp_valid(a_res_ln_rd_rsp_valid),.a_res_ln_rd_rsp_ready(a_res_ln_rd_rsp_ready),.a_res_ln_rd_rsp_data(a_res_ln_rd_rsp_data),.a_res_ln_rd_rsp_mask(a_res_ln_rd_rsp_mask),.a_res_ln_rd_rsp_tag(a_res_ln_rd_rsp_tag),.a_res_ln_idle(a_res_ln_idle),.a_res_sfu_lease_valid(a_res_sfu_lease_valid),.a_res_sfu_lease_ready(a_res_sfu_lease_ready),.a_res_sfu_lease_request_id(a_res_sfu_lease_request_id),.a_res_sfu_lease_generation(a_res_sfu_lease_generation),.a_res_sfu_lease_epoch(a_res_sfu_lease_epoch),.a_res_sfu_lease_head(a_res_sfu_lease_head),.a_res_sfu_lease_phase(a_res_sfu_lease_phase),.a_res_sfu_release_valid(a_res_sfu_release_valid),.a_res_sfu_release_phase(a_res_sfu_release_phase),.a_res_sfu_release_epoch(a_res_sfu_release_epoch),.a_res_sfu_phase_debt_clear(a_res_sfu_phase_debt_clear),.a_res_sfu_lease_active(a_res_sfu_lease_active),.a_res_sfu_context_valid(a_res_sfu_context_valid),.a_res_sfu_context_row_hi(a_res_sfu_context_row_hi),.a_res_sfu_req_valid(a_res_sfu_req_valid),.a_res_sfu_req_ready(a_res_sfu_req_ready),.a_res_sfu_req_mode(a_res_sfu_req_mode),.a_res_sfu_req_generation(a_res_sfu_req_generation),.a_res_sfu_req_epoch(a_res_sfu_req_epoch),.a_res_sfu_req_phase(a_res_sfu_req_phase),.a_res_sfu_req_tag(a_res_sfu_req_tag),.a_res_sfu_req_x(a_res_sfu_req_x),.a_res_sfu_reject_valid(a_res_sfu_reject_valid),.a_res_sfu_rsp_valid(a_res_sfu_rsp_valid),.a_res_sfu_rsp_ready(a_res_sfu_rsp_ready),.a_res_sfu_rsp_tag(a_res_sfu_rsp_tag),.a_res_sfu_rsp_data(a_res_sfu_rsp_data),.a_res_sfu_pending_vectors(a_res_sfu_pending_vectors),.a_res_sfu_in_flight_vectors(a_res_sfu_in_flight_vectors),.a_res_sfu_protocol_fault(a_res_sfu_protocol_fault),.a_res_div_lease_valid(a_res_div_lease_valid),.a_res_div_lease_ready(a_res_div_lease_ready),.a_res_div_lease_request_id(a_res_div_lease_request_id),.a_res_div_lease_generation(a_res_div_lease_generation),.a_res_div_lease_epoch(a_res_div_lease_epoch),.a_res_div_lease_head(a_res_div_lease_head),.a_res_div_lease_phase(a_res_div_lease_phase),.a_res_div_release_valid(a_res_div_release_valid),.a_res_div_release_phase(a_res_div_release_phase),.a_res_div_release_epoch(a_res_div_release_epoch),.a_res_div_phase_debt_clear(a_res_div_phase_debt_clear),.a_res_div_lease_active(a_res_div_lease_active),.a_res_div_req_valid(a_res_div_req_valid),.a_res_div_req_ready(a_res_div_req_ready),.a_res_div_req_generation(a_res_div_req_generation),.a_res_div_req_epoch(a_res_div_req_epoch),.a_res_div_req_phase(a_res_div_req_phase),.a_res_div_req_lane_mask(a_res_div_req_lane_mask),.a_res_div_req_tag(a_res_div_req_tag),.a_res_div_req_a(a_res_div_req_a),.a_res_div_req_b(a_res_div_req_b),.a_res_div_protocol_reject_valid(a_res_div_protocol_reject_valid),.a_res_div_rsp_valid(a_res_div_rsp_valid),.a_res_div_rsp_ready(a_res_div_rsp_ready),.a_res_div_rsp_tag(a_res_div_rsp_tag),.a_res_div_rsp_numeric_error(a_res_div_rsp_numeric_error),.a_res_div_rsp_data(a_res_div_rsp_data),.a_res_div_pending_vectors(a_res_div_pending_vectors),.a_res_div_in_flight_vectors(a_res_div_in_flight_vectors),.a_res_div_in_flight_scalars(a_res_div_in_flight_scalars),.a_res_div_protocol_fault(a_res_div_protocol_fault),.a_res_scale_valid(a_res_scale_valid),.a_res_scale_ready(a_res_scale_ready),.a_res_scale_tag(a_res_scale_tag),.a_res_scale_input(a_res_scale_input),.a_res_scale_rsp_valid(a_res_scale_rsp_valid),.a_res_scale_rsp_ready(a_res_scale_rsp_ready),.a_res_scale_rsp_tag(a_res_scale_rsp_tag),.a_res_scale_data(a_res_scale_data),.a_res_scale_pending(a_res_scale_pending),.a_res_scale_fault(a_res_scale_fault),.a_rope_owner_valid(a_rope_owner_valid),.a_rope_owner_request_id(a_rope_owner_request_id),.a_rope_owner_generation(a_rope_owner_generation),.a_rope_owner_epoch(a_rope_owner_epoch),.a_rope_wr_valid(a_rope_wr_valid),.a_rope_wr_ready(a_rope_wr_ready),.a_rope_wr_request_id(a_rope_wr_request_id),.a_rope_wr_generation(a_rope_wr_generation),.a_rope_wr_epoch(a_rope_wr_epoch),.a_rope_wr_head(a_rope_wr_head),.a_rope_wr_token(a_rope_wr_token),.a_rope_wr_tag(a_rope_wr_tag),.a_rope_wr_q(a_rope_wr_q),.a_rope_wr_k(a_rope_wr_k),.a_rope_wr_commit_valid(a_rope_wr_commit_valid),.a_rope_wr_commit_tag(a_rope_wr_commit_tag),.a_rope_reject_valid(a_rope_reject_valid),.a_rope_reject_code(a_rope_reject_code),.a_cache_bound_valid(a_cache_bound_valid),.a_cache_bound_model_id(a_cache_bound_model_id),.a_cache_bound_numeric_id(a_cache_bound_numeric_id),.a_cache_bound_table_key(a_cache_bound_table_key),.a_cache_family_complete(a_cache_family_complete),.a_cache_owner_valid(a_cache_owner_valid),.a_cache_owner_request_id(a_cache_owner_request_id),.a_cache_owner_generation(a_cache_owner_generation),.a_cache_owner_epoch(a_cache_owner_epoch),.a_cache_rd_valid(a_cache_rd_valid),.a_cache_rd_ready(a_cache_rd_ready),.a_cache_rd_family(a_cache_rd_family),.a_cache_rd_row(a_cache_rd_row),.a_cache_rd_tag(a_cache_rd_tag),.a_cache_rd_request_id(a_cache_rd_request_id),.a_cache_rd_generation(a_cache_rd_generation),.a_cache_rd_epoch(a_cache_rd_epoch),.a_cache_rd_reject_valid(a_cache_rd_reject_valid),.a_cache_rd_reject_code(a_cache_rd_reject_code),.a_cache_rsp_valid(a_cache_rsp_valid),.a_cache_rsp_ready(a_cache_rsp_ready),.a_cache_rsp_family(a_cache_rsp_family),.a_cache_rsp_row(a_cache_rsp_row),.a_cache_rsp_tag(a_cache_rsp_tag),.a_cache_rsp_data(a_cache_rsp_data),.clk(clk),.rst_n(rst_n),.g_cmd_valid(cmd_valid&&resources_bound),.g_cmd_ready(cmd_ready),
  .g_cmd_request_id(request_id),.g_cmd_generation(generation),.g_cmd_epoch(epoch),
  .g_storage_owner_valid(resource_owned),.g_storage_owner_request_id(storage_rid),.g_storage_owner_generation(storage_gen),.g_storage_owner_epoch(storage_epoch),.g_storage_owner_phase(storage_phase),
  .g_sfu_owner_valid(lease_active),.g_sfu_owner_request_id(sfu_rid),.g_sfu_owner_generation(sfu_gen),.g_sfu_owner_epoch(sfu_epoch),.g_sfu_owner_phase(sfu_phase),
  .g_fill_valid(fill_valid),.g_fill_ready(fill_ready),.g_fill_request_id(request_id),.g_fill_generation(generation),.g_fill_epoch(epoch),.g_fill_slot(fill_slot),.g_fill_half(fill_half),.g_fill_s(fill_s),.g_fill_row(fill_row),.g_fill_data(fill_data),.g_fill_reject_valid(fill_reject_valid),.g_fill_reject_code(fill_reject_code),
  .g_out_valid(out_valid),.g_out_ready(out_ready),.g_out_data(out_data),.g_out_status(out_status),.g_out_tag(out_tag),.g_out_s(out_s),.g_out_row(out_row),.g_out_chunk(out_chunk),
  .g_done_valid(done_valid),.g_done_ready(done_ready),.g_done_status(done_status),.g_done_error_rank(done_error_rank),.g_done_error_row(done_error_row),.g_done_error_column(done_error_column),.g_rsp_request_id(rsp_request_id),.g_rsp_generation(rsp_generation),.g_rsp_epoch(rsp_epoch),
  .g_discard_valid(discard_valid),.g_discard_ready(discard_ready),.g_discard_request_id(request_id),.g_discard_generation(generation),.g_discard_epoch(epoch),.g_discard_reject_valid(discard_reject_valid),
  .g_engine_idle(engine_idle),.g_active(active),.g_needs_discard(needs_discard),.g_protocol_fault(protocol_fault),.g_slot_active(slot_active),.g_slot_ready(slot_ready),.g_slot_s(slot_s),.g_slot_consumed_vectors(slot_consumed_vectors),.g_slot_math_pending(slot_math_pending),.g_slot_sfu_debt(slot_sfu_debt),.g_slot_fp_debt(slot_fp_debt),.g_covered(covered),.g_evaluated(evaluated),.g_pool_reset_n(pool_reset_n),
  .g_fp_req_valid(fp_req_valid),.g_fp_req_ready(fp_req_ready),.g_fp_req_tag(fp_req_tag),.g_fp_req_a(fp_req_a),.g_fp_req_b(fp_req_b),.g_fp_rsp_valid(fp_rsp_valid),.g_fp_rsp_tag(fp_rsp_tag),.g_fp_rsp_data(fp_rsp_data),.g_fp_rsp_status(fp_rsp_status),.g_fp_pool_fault(pool_fault),
  .g_sfu_req_valid(sfu_req_valid),.g_sfu_req_ready(sfu_req_ready),.g_sfu_req_tag(sfu_req_tag),.g_sfu_req_mask(sfu_req_mask),.g_sfu_req_x(sfu_req_x),.g_sfu_rsp_valid(sfu_rsp_valid),.g_sfu_rsp_ready(sfu_rsp_ready),.g_sfu_rsp_tag(sfu_rsp_tag),.g_sfu_rsp_data(sfu_rsp_data),.g_sfu_rsp_status(sfu_rsp_status),.g_sfu_protocol_fault(sfu_fault),.g_sfu_reject_valid(sfu_reject),
  .g_g_wr_valid(g_wr_valid),.g_g_wr_ready(g_wr_ready),.g_g_wr_mask(g_wr_mask),.g_g_wr_addr(g_wr_addr),.g_g_wr_data(g_wr_data),.g_g_wr_tag(g_wr_tag),.g_g_wr_rsp_valid(g_wr_rsp_valid),.g_g_wr_rsp_ready(g_wr_rsp_ready),.g_g_wr_rsp_tag(g_wr_rsp_tag),
  .g_g_rd_valid(g_rd_valid),.g_g_rd_ready(g_rd_ready),.g_g_rd_mask(g_rd_mask),.g_g_rd_addr(g_rd_addr),.g_g_rd_tag(g_rd_tag),.g_g_rd_rsp_valid(g_rd_rsp_valid),.g_g_rd_rsp_ready(g_rd_rsp_ready),.g_g_rd_rsp_data(g_rd_rsp_data),.g_g_rd_rsp_mask(g_rd_rsp_mask),.g_g_rd_rsp_tag(g_rd_rsp_tag));
 laya_m007_g_vector_pool_v1 pool(.clk,.rst_n(pool_reset_n),.req_valid(fp_req_valid),.req_ready(fp_req_ready),.req_tag(fp_req_tag),.req_a(fp_req_a),.req_b(fp_req_b),
  .rsp_valid(fp_rsp_valid),.rsp_tag(fp_rsp_tag),.rsp_data(fp_rsp_data),.rsp_status(fp_rsp_status),.protocol_fault(pool_fault));
 laya_m007_tanh8_v1 tanh(.clk,.rst_n,.lease_valid(actual_bind),.lease_ready,.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_phase(3'd1),
  .release_valid(release_valid&&resource_owned&&engine_idle&&storage_idle&&sfu_pending==0&&sfu_flight==0),.release_ready(tanh_release_ready),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(engine_idle&&storage_idle),
  .lease_active,.draining,.rsp_request_id(sfu_rid),.rsp_generation(sfu_gen),.rsp_epoch(sfu_epoch),.rsp_phase(sfu_phase),
  .req_valid(sfu_req_valid),.req_ready(sfu_req_ready),.req_mode(2'd1),.req_request_id(rsp_request_id),.req_generation(rsp_generation),.req_epoch(rsp_epoch),.req_phase(3'd1),.req_tag(sfu_req_tag),.req_mask(sfu_req_mask),.req_x(sfu_req_x),
  .reject_valid(sfu_reject),.reject_code(sfu_reject_code),.rsp_valid(sfu_rsp_valid),.rsp_ready(sfu_rsp_ready),.rsp_tag(sfu_rsp_tag),.rsp_mask(sfu_rsp_mask),.rsp_data(sfu_rsp_data),.rsp_status(sfu_rsp_status),
  .pending_vectors(sfu_pending),.in_flight_vectors(sfu_flight),.protocol_fault(sfu_fault));
 laya_attention_storage_v1 storage(.clk,.rst_n,.bind_valid(actual_bind),.bind_ready(storage_bind_ready),.bind_request_id(request_id),.bind_generation(generation),.bind_epoch(epoch),.bind_head(4'd0),.bind_phase(3'd1),
  .op_request_id(rsp_request_id),.op_generation(rsp_generation),.op_epoch(rsp_epoch),.op_phase(3'd1),.rsp_request_id(storage_rid),.rsp_generation(storage_gen),.rsp_epoch(storage_epoch),.rsp_head(),.rsp_phase(storage_phase),
  .ps_wr_valid(1'b0),.ps_wr_ready(),.ps_wr_mask('0),.ps_wr_addr('0),.ps_wr_data('0),.ps_wr_tag('0),.ps_wr_rsp_valid(),.ps_wr_rsp_ready(1'b0),.ps_wr_rsp_tag(),
  .ps_rd_valid(1'b0),.ps_rd_ready(),.ps_rd_mask('0),.ps_rd_addr('0),.ps_rd_tag('0),.ps_rd_rsp_valid(),.ps_rd_rsp_ready(1'b0),.ps_rd_rsp_data(),.ps_rd_rsp_mask(),.ps_rd_rsp_tag(),
  .g_wr_valid,.g_wr_ready,.g_wr_mask,.g_wr_addr,.g_wr_data,.g_wr_tag,.g_wr_rsp_valid,.g_wr_rsp_ready,.g_wr_rsp_tag,
  .g_rd_valid,.g_rd_ready,.g_rd_mask,.g_rd_addr,.g_rd_tag,.g_rd_rsp_valid,.g_rd_rsp_ready,.g_rd_rsp_data,.g_rd_rsp_mask,.g_rd_rsp_tag,
  .context_wr_valid(1'b0),.context_wr_ready(),.context_wr_mask('0),.context_wr_addr('0),.context_wr_data('0),.context_wr_tag('0),.context_wr_rsp_valid(),.context_wr_rsp_ready(1'b0),.context_wr_rsp_tag(),
  .context_rd_valid(1'b0),.context_rd_ready(),.context_rd_mask('0),.context_rd_addr('0),.context_rd_tag('0),.context_rd_rsp_valid(),.context_rd_rsp_ready(1'b0),.context_rd_rsp_data(),.context_rd_rsp_mask(),.context_rd_rsp_tag(),.idle(storage_idle));
 laya_attention_qkv_bank_v2 qkv_bank(.clk(clk),.rst_n(rst_n),.wr_valid(a_res_qkv_wr_valid),.wr_ready(a_res_qkv_wr_ready),.wr_plane(a_res_qkv_wr_plane),.wr_head(a_res_qkv_wr_head),.wr_token(a_res_qkv_wr_token),.wr_half(a_res_qkv_wr_half),.wr_data(a_res_qkv_wr_data),.rd_valid(a_res_qkv_rd_valid),.rd_ready(a_res_qkv_rd_ready),.rd_head(a_res_qkv_rd_head),.rd_token(a_res_qkv_rd_token),.rd_tag(a_res_qkv_rd_tag),.rd_rsp_valid(a_res_qkv_rd_rsp_valid),.rd_rsp_ready(a_res_qkv_rd_rsp_ready),.rd_rsp_head(a_res_qkv_rd_rsp_head),.rd_rsp_token(a_res_qkv_rd_rsp_token),.rd_rsp_tag(a_res_qkv_rd_rsp_tag),.rd_rsp_data(a_res_qkv_rd_rsp_data),.rope_owner_valid(a_rope_owner_valid),.rope_owner_request_id(a_rope_owner_request_id),.rope_owner_generation(a_rope_owner_generation),.rope_owner_epoch(a_rope_owner_epoch),.rope_wr_valid(a_rope_wr_valid),.rope_wr_ready(a_rope_wr_ready),.rope_wr_request_id(a_rope_wr_request_id),.rope_wr_generation(a_rope_wr_generation),.rope_wr_epoch(a_rope_wr_epoch),.rope_wr_head(a_rope_wr_head),.rope_wr_token(a_rope_wr_token),.rope_wr_tag(a_rope_wr_tag),.rope_wr_q(a_rope_wr_q),.rope_wr_k(a_rope_wr_k),.rope_wr_commit_valid(a_rope_wr_commit_valid),.rope_wr_commit_tag(a_rope_wr_commit_tag),.rope_reject_valid(a_rope_reject_valid),.rope_reject_code(a_rope_reject_code));
endmodule
