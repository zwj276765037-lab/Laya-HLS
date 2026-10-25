`timescale 1ns/1ps
// D32 canonical full graph. Functional/tool evidence is recorded separately.
module laya_m007_single_parent_v3 #(
 parameter logic[255:0] MODEL_SHA256=256'h6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18,
 parameter logic[255:0] GRAPH_SHA256=256'hf33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9,
 parameter logic[255:0] NUMERIC_SHA256=256'haeb13e7937d29fe6a2c68c407249f294212aa24f4e45fd3862b092795ab066f7,
 parameter logic[255:0] LAYOUT_SHA256=256'h2d848b5fb78236c795cb1d442f088393a3fd6cbd7f8ecf3cf9f984c59b5e0991,
 parameter logic[255:0] PACKAGE_BUILD_SHA256=256'h7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5,
 parameter logic[127:0] TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965,
 parameter logic[1:0]ADDRESS_PROFILE=0,
 parameter logic[3:0][63:0]HBM_PORT_BASE=0,HBM_PORT_SPAN=0,
 parameter logic[255:0]PLATFORM_MANIFEST_SHA256=0
)(
 input logic clk,rst_n,
 input logic setup_valid,output logic setup_ready,
 input logic[63:0]setup_request,input logic[31:0]setup_generation,input logic[127:0]setup_build_id,setup_table_key,
 input logic[255:0]setup_model_sha256,setup_graph_sha256,setup_numeric_sha256,setup_layout_sha256,setup_package_build_sha256,
 input logic[63:0]setup_catalog_base,setup_catalog_span,input logic[255:0]setup_records_sha256,input logic[63:0]setup_records_crc,
 input logic invalidate_valid,output logic invalidate_ready,input logic[63:0]invalidate_request,input logic[31:0]invalidate_generation,input logic[127:0]invalidate_build_id,
 input logic model_word_valid,output logic model_word_ready,input logic[63:0]model_word_request,input logic[31:0]model_word_generation,input logic[1:0]model_word_kind,input logic[9:0]model_word_index,input logic[31:0][31:0]model_word_data,
 output logic model_committed,output logic[1:0]done_op,
 output logic reject_valid,output logic[2:0]reject_port,output logic[7:0]reject_code,output logic[95:0]reject_tuple,
 input logic[1:0]cmd_qtype,input logic[15:0][31:0]cmd_marker_rows,input logic[15:0]cmd_marker_mask,input logic[4:0]cmd_candidate_count,
 output logic tail_begin_valid,input logic tail_begin_ready,output logic[63:0]tail_request,output logic[31:0]tail_generation,tail_source_epoch,tail_expected_bytes,
 input logic tail_commit_valid,output logic tail_commit_ready,input logic[63:0]tail_commit_request,input logic[31:0]tail_commit_generation,tail_commit_source_epoch,tail_commit_bytes,input logic[7:0]tail_commit_status,
 output logic tail_abort_valid,input logic tail_abort_ready,input logic tail_owner_idle,
 input logic cmd_valid,output logic cmd_ready,
 input logic [63:0] cmd_request,input logic [31:0] cmd_generation,cmd_epoch,
 input logic [127:0] cmd_model_id,cmd_numeric_id,cmd_table_key,cmd_graph_id,cmd_layout_id,cmd_build_id,
 input logic [2:0] cmd_kind,input logic [4:0] cmd_layer,input logic [127:0] cmd_mask,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 input logic producer_fail_valid,input logic[7:0] producer_fail_code,input logic[79:0] producer_fail_detail,
 input logic [63:0] producer_fail_request,input logic [31:0] producer_fail_generation,producer_fail_epoch,
 output logic producer_fail_ready,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,output logic[4:0] out_slot,
 output logic done_valid,input logic done_ready,output logic [7:0] done_status,
 output logic [2:0] error_domain,output logic [95:0] error_tuple,
 output logic [7:0] source_status,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [6:0] parent_state,output logic [31:0] elapsed_cycles,
 output logic [15:0] layer_head_completed,
 input logic  coeff_bind_valid,
 output logic  coeff_bind_ready,
 input logic [127:0] coeff_bind_model_id,
 input logic [127:0] coeff_bind_numeric_id,
 input logic [127:0] coeff_bind_table_key,
 output logic  coeff_bound_valid,
 output logic [127:0] coeff_bound_model_id,
 output logic [127:0] coeff_bound_numeric_id,
 output logic [127:0] coeff_bound_table_key,
 output logic [1:0] coeff_family_complete,
 input logic  coeff_wr_valid,
 output logic  coeff_wr_ready,
 input logic [127:0] coeff_wr_model_id,
 input logic [127:0] coeff_wr_numeric_id,
 input logic [127:0] coeff_wr_table_key,
 input logic [1:0] coeff_wr_table,
 input logic [6:0] coeff_wr_row,
 input logic  coeff_wr_half,
 input logic [31:0][31:0] coeff_wr_data,
 output logic  coeff_wr_reject_valid,
 output logic [2:0] coeff_wr_reject_code,
 output logic [4:0] coeff_wr_nonfinite_lane,
 output logic [3:0] arvalid,
 input logic [3:0] arready,
 output logic [3:0][63:0] araddr,
 output logic [3:0][2:0] arid,
 output logic [3:0][7:0] arlen,
 input logic [3:0] rvalid,
 output logic [3:0] rready,
 input logic [3:0][2:0] rid,
 input logic [3:0][511:0] rdata,
 input logic [3:0][1:0] rresp,
 input logic [3:0] rlast
);
 localparam logic[127:0] MODEL_ID=MODEL_SHA256[255:128],GRAPH_ID=GRAPH_SHA256[255:128],NUMERIC_ID=NUMERIC_SHA256[255:128],LAYOUT_ID=LAYOUT_SHA256[255:128];
 localparam logic[127:0]BUILD_ID=128'hcedb4c130303f16da9fa1c605b2cf985;
 logic l_prepare_valid;
 logic  l_prepare_ready;
 logic [63:0] l_prepare_request_id;
 logic [127:0] l_prepare_model_id;
 logic [31:0] l_prepare_generation;
 logic [31:0] l_prepare_epoch;
 logic [127:0] l_prepare_numeric_id;
 logic [127:0] l_prepare_table_key;
 logic [1:0] l_prepare_kind;
 logic [4:0] l_prepare_layer;
 logic [127:0] l_prepare_mask;
 logic  l_qkv_wr_valid;
 logic  l_qkv_wr_ready;
 logic [63:0] l_qkv_wr_request_id;
 logic [31:0] l_qkv_wr_generation;
 logic [31:0] l_qkv_wr_epoch;
 logic [1:0] l_qkv_wr_plane;
 logic [3:0] l_qkv_wr_head;
 logic [6:0] l_qkv_wr_token;
 logic  l_qkv_wr_half;
 logic [31:0][31:0] l_qkv_wr_data;
 logic  l_start_valid;
 logic  l_start_ready;
 logic [63:0] l_start_request_id;
 logic [31:0] l_start_generation;
 logic  l_reject_valid;
 logic [3:0] l_reject_code;
 logic  l_abort_valid;
 logic  l_abort_ready;
 logic [2:0] l_qkv_read_grant;
 logic  l_ps_grant;
 logic  l_g_grant;
 logic  l_context_grant;
 logic  l_fp_grant;
 logic  l_sfu_grant;
 logic  l_exp_grant;
 logic  l_div_grant;
 logic  l_rope_write_grant;
 logic  l_done_valid;
 logic  l_done_ready;
 logic [63:0] l_done_request_id;
 logic [31:0] l_done_generation;
 logic [7:0] l_done_status;
 logic [31:0] l_done_cycles;
 logic [31:0] l_rope_cycles;
 logic [15:0] l_head_completed;
 logic [15:0] l_head_context_valid;
 logic [3:0] l_active_head;
 logic  l_error_valid;
 logic [95:0] l_error_tuple;
 logic [25:0][15:0] l_check_completed;
 logic [25:0][15:0] l_check_unreachable;
 logic [25:0][15:0] l_check_dominated;
 logic [2047:0] l_av_check_completed;
 logic [2047:0] l_av_check_unreachable;
 logic [2047:0] l_av_check_dominated;
 logic  l_result_rd_valid;
 logic  l_result_rd_ready;
 logic [31:0] l_result_rd_generation;
 logic [31:0] l_result_rd_tag;
 logic [3:0] l_result_rd_head;
 logic [6:0] l_result_rd_query;
 logic  l_result_rd_half;
 logic  l_result_rsp_valid;
 logic  l_result_rsp_ready;
 logic [31:0] l_result_rsp_tag;
 logic [31:0][31:0] l_result_rsp_data;
 logic  l_result_discard_valid;
 logic  l_result_discard_ready;
 logic [31:0] l_result_discard_generation;
 logic  l_context_discarded;
 logic [31:0] l_producer_done_cycles;
 logic [31:0] l_context_release_cycles;
 logic  l_prepare_cancel_valid;
 logic  l_prepare_cancel_ready;
 logic [63:0] l_prepare_cancel_request_id;
 logic [31:0] l_prepare_cancel_generation;
 logic [31:0] l_prepare_cancel_epoch;
 logic  l_prepare_cancel_rsp_valid;
 logic  l_prepare_cancel_rsp_ready;
 logic [63:0] l_prepare_cancel_rsp_request_id;
 logic [31:0] l_prepare_cancel_rsp_generation;
 logic [31:0] l_prepare_cancel_rsp_epoch;
 logic [7:0] l_prepare_cancel_rsp_status;
 logic  l_layer_idle;
 logic  l_check_coverage_fault;
 logic [31:0] l_check_first_conflict;
 logic  l_res_qkv_wr_valid;
 logic  l_res_qkv_wr_ready;
 logic [1:0] l_res_qkv_wr_plane;
 logic [3:0] l_res_qkv_wr_head;
 logic [6:0] l_res_qkv_wr_token;
 logic  l_res_qkv_wr_half;
 logic [31:0][31:0] l_res_qkv_wr_data;
 logic [2:0] l_res_qkv_rd_valid;
 logic [2:0] l_res_qkv_rd_ready;
 logic [2:0][3:0] l_res_qkv_rd_head;
 logic [2:0][6:0] l_res_qkv_rd_token;
 logic [2:0][31:0] l_res_qkv_rd_tag;
 logic [2:0] l_res_qkv_rd_rsp_valid;
 logic [2:0] l_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] l_res_qkv_rd_rsp_head;
 logic [2:0][6:0] l_res_qkv_rd_rsp_token;
 logic [2:0][31:0] l_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] l_res_qkv_rd_rsp_data;
 logic  l_res_st_bind_valid;
 logic  l_res_st_bind_ready;
 logic [63:0] l_res_st_bind_request_id;
 logic [31:0] l_res_st_bind_generation;
 logic [31:0] l_res_st_bind_epoch;
 logic [3:0] l_res_st_bind_head;
 logic [2:0] l_res_st_bind_phase;
 logic [63:0] l_res_st_op_request_id;
 logic [31:0] l_res_st_op_generation;
 logic [31:0] l_res_st_op_epoch;
 logic [2:0] l_res_st_op_phase;
 logic [63:0] l_res_st_rsp_request_id;
 logic [31:0] l_res_st_rsp_generation;
 logic [31:0] l_res_st_rsp_epoch;
 logic [3:0] l_res_st_rsp_head;
 logic [2:0] l_res_st_rsp_phase;
 logic  l_res_st_ps_wr_valid;
 logic  l_res_st_ps_wr_ready;
 logic [1023:0] l_res_st_ps_wr_mask;
 logic [1023:0][3:0] l_res_st_ps_wr_addr;
 logic [1023:0][31:0] l_res_st_ps_wr_data;
 logic [95:0] l_res_st_ps_wr_tag;
 logic  l_res_st_ps_wr_rsp_valid;
 logic  l_res_st_ps_wr_rsp_ready;
 logic [95:0] l_res_st_ps_wr_rsp_tag;
 logic  l_res_st_ps_rd_valid;
 logic  l_res_st_ps_rd_ready;
 logic [1023:0] l_res_st_ps_rd_mask;
 logic [1023:0][3:0] l_res_st_ps_rd_addr;
 logic [95:0] l_res_st_ps_rd_tag;
 logic  l_res_st_ps_rd_rsp_valid;
 logic  l_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] l_res_st_ps_rd_rsp_data;
 logic [1023:0] l_res_st_ps_rd_rsp_mask;
 logic [95:0] l_res_st_ps_rd_rsp_tag;
 logic  l_res_st_g_wr_valid;
 logic  l_res_st_g_wr_ready;
 logic [255:0] l_res_st_g_wr_mask;
 logic [255:0][5:0] l_res_st_g_wr_addr;
 logic [255:0][31:0] l_res_st_g_wr_data;
 logic [95:0] l_res_st_g_wr_tag;
 logic  l_res_st_g_wr_rsp_valid;
 logic  l_res_st_g_wr_rsp_ready;
 logic [95:0] l_res_st_g_wr_rsp_tag;
 logic  l_res_st_g_rd_valid;
 logic  l_res_st_g_rd_ready;
 logic [255:0] l_res_st_g_rd_mask;
 logic [255:0][5:0] l_res_st_g_rd_addr;
 logic [95:0] l_res_st_g_rd_tag;
 logic  l_res_st_g_rd_rsp_valid;
 logic  l_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] l_res_st_g_rd_rsp_data;
 logic [255:0] l_res_st_g_rd_rsp_mask;
 logic [95:0] l_res_st_g_rd_rsp_tag;
 logic  l_res_st_context_wr_valid;
 logic  l_res_st_context_wr_ready;
 logic [63:0] l_res_st_context_wr_mask;
 logic [63:0][10:0] l_res_st_context_wr_addr;
 logic [63:0][31:0] l_res_st_context_wr_data;
 logic [95:0] l_res_st_context_wr_tag;
 logic  l_res_st_context_wr_rsp_valid;
 logic  l_res_st_context_wr_rsp_ready;
 logic [95:0] l_res_st_context_wr_rsp_tag;
 logic  l_res_st_context_rd_valid;
 logic  l_res_st_context_rd_ready;
 logic [63:0] l_res_st_context_rd_mask;
 logic [63:0][10:0] l_res_st_context_rd_addr;
 logic [95:0] l_res_st_context_rd_tag;
 logic  l_res_st_context_rd_rsp_valid;
 logic  l_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] l_res_st_context_rd_rsp_data;
 logic [63:0] l_res_st_context_rd_rsp_mask;
 logic [95:0] l_res_st_context_rd_rsp_tag;
 logic  l_res_st_idle;
 logic  l_res_fp_lease_valid;
 logic  l_res_fp_lease_ready;
 logic [63:0] l_res_fp_lease_request_id;
 logic [31:0] l_res_fp_lease_generation;
 logic [31:0] l_res_fp_lease_epoch;
 logic [3:0] l_res_fp_lease_head;
 logic [2:0] l_res_fp_lease_phase;
 logic  l_res_fp_release_valid;
 logic  l_res_fp_release_ready;
 logic [2:0] l_res_fp_release_phase;
 logic [31:0] l_res_fp_release_epoch;
 logic  l_res_fp_phase_debt_clear;
 logic  l_res_fp_lease_active;
 logic  l_res_fp_draining;
 logic [63:0] l_res_fp_rsp_request_id;
 logic [31:0] l_res_fp_rsp_generation;
 logic [31:0] l_res_fp_rsp_epoch;
 logic [3:0] l_res_fp_rsp_head;
 logic [2:0] l_res_fp_rsp_phase;
 logic  l_res_fp_mul_req_valid;
 logic  l_res_fp_mul_req_ready;
 logic [2:0] l_res_fp_mul_req_phase;
 logic [31:0] l_res_fp_mul_req_epoch;
 logic [95:0] l_res_fp_mul_req_tag;
 logic [255:0][31:0] l_res_fp_mul_a;
 logic [255:0][31:0] l_res_fp_mul_b;
 logic  l_res_fp_mul_rsp_valid;
 logic  l_res_fp_mul_rsp_ready;
 logic [95:0] l_res_fp_mul_rsp_tag;
 logic [255:0][31:0] l_res_fp_mul_rsp_data;
 logic [6:0] l_res_fp_add_req_valid;
 logic [6:0] l_res_fp_add_req_is_root;
 logic [6:0] l_res_fp_add_req_ready;
 logic [6:0][2:0] l_res_fp_add_req_phase;
 logic [6:0][31:0] l_res_fp_add_req_epoch;
 logic [6:0][95:0] l_res_fp_add_req_tag;
 logic [255:0][31:0] l_res_fp_add_a;
 logic [255:0][31:0] l_res_fp_add_b;
 logic [6:0] l_res_fp_add_rsp_valid;
 logic [6:0] l_res_fp_add_rsp_ready;
 logic [6:0][95:0] l_res_fp_add_rsp_tag;
 logic [255:0][31:0] l_res_fp_add_rsp_data;
 logic [6:0] l_res_fp_mul_pending;
 logic [6:0][6:0] l_res_fp_add_pending;
 logic  l_res_fp_protocol_fault;
 logic  l_res_ln_bind_valid;
 logic  l_res_ln_bind_ready;
 logic [63:0] l_res_ln_bind_request_id;
 logic [31:0] l_res_ln_bind_generation;
 logic [31:0] l_res_ln_bind_epoch;
 logic [3:0] l_res_ln_bind_head;
 logic [2:0] l_res_ln_bind_phase;
 logic [63:0] l_res_ln_op_request_id;
 logic [31:0] l_res_ln_op_generation;
 logic [31:0] l_res_ln_op_epoch;
 logic [2:0] l_res_ln_op_phase;
 logic [63:0] l_res_ln_rsp_request_id;
 logic [31:0] l_res_ln_rsp_generation;
 logic [31:0] l_res_ln_rsp_epoch;
 logic [3:0] l_res_ln_rsp_head;
 logic [2:0] l_res_ln_rsp_phase;
 logic  l_res_ln_wr_valid;
 logic  l_res_ln_wr_ready;
 logic [255:0] l_res_ln_wr_mask;
 logic [255:0][4:0] l_res_ln_wr_addr;
 logic [255:0][31:0] l_res_ln_wr_data;
 logic [95:0] l_res_ln_wr_tag;
 logic  l_res_ln_wr_rsp_valid;
 logic  l_res_ln_wr_rsp_ready;
 logic [95:0] l_res_ln_wr_rsp_tag;
 logic  l_res_ln_rd_valid;
 logic  l_res_ln_rd_ready;
 logic [255:0] l_res_ln_rd_mask;
 logic [255:0][4:0] l_res_ln_rd_addr;
 logic [95:0] l_res_ln_rd_tag;
 logic  l_res_ln_rd_rsp_valid;
 logic  l_res_ln_rd_rsp_ready;
 logic [255:0][31:0] l_res_ln_rd_rsp_data;
 logic [255:0] l_res_ln_rd_rsp_mask;
 logic [95:0] l_res_ln_rd_rsp_tag;
 logic  l_res_ln_idle;
 logic  l_res_sfu_lease_valid;
 logic  l_res_sfu_lease_ready;
 logic [63:0] l_res_sfu_lease_request_id;
 logic [31:0] l_res_sfu_lease_generation;
 logic [31:0] l_res_sfu_lease_epoch;
 logic [3:0] l_res_sfu_lease_head;
 logic [2:0] l_res_sfu_lease_phase;
 logic  l_res_sfu_release_valid;
 logic [2:0] l_res_sfu_release_phase;
 logic [31:0] l_res_sfu_release_epoch;
 logic  l_res_sfu_phase_debt_clear;
 logic  l_res_sfu_lease_active;
 logic [63:0] l_res_sfu_context_valid;
 logic [63:0] l_res_sfu_context_row_hi;
 logic  l_res_sfu_req_valid;
 logic  l_res_sfu_req_ready;
 logic [1:0] l_res_sfu_req_mode;
 logic [31:0] l_res_sfu_req_generation;
 logic [31:0] l_res_sfu_req_epoch;
 logic [2:0] l_res_sfu_req_phase;
 logic [10:0] l_res_sfu_req_tag;
 logic [7:0][31:0] l_res_sfu_req_x;
 logic  l_res_sfu_reject_valid;
 logic  l_res_sfu_rsp_valid;
 logic  l_res_sfu_rsp_ready;
 logic [10:0] l_res_sfu_rsp_tag;
 logic [7:0][31:0] l_res_sfu_rsp_data;
 logic [8:0] l_res_sfu_pending_vectors;
 logic [8:0] l_res_sfu_in_flight_vectors;
 logic  l_res_sfu_protocol_fault;
 logic  l_res_div_lease_valid;
 logic  l_res_div_lease_ready;
 logic [63:0] l_res_div_lease_request_id;
 logic [31:0] l_res_div_lease_generation;
 logic [31:0] l_res_div_lease_epoch;
 logic [3:0] l_res_div_lease_head;
 logic [2:0] l_res_div_lease_phase;
 logic  l_res_div_release_valid;
 logic [2:0] l_res_div_release_phase;
 logic [31:0] l_res_div_release_epoch;
 logic  l_res_div_phase_debt_clear;
 logic  l_res_div_lease_active;
 logic  l_res_div_req_valid;
 logic  l_res_div_req_ready;
 logic [31:0] l_res_div_req_generation;
 logic [31:0] l_res_div_req_epoch;
 logic [2:0] l_res_div_req_phase;
 logic [7:0] l_res_div_req_lane_mask;
 logic [95:0] l_res_div_req_tag;
 logic [7:0][31:0] l_res_div_req_a;
 logic [7:0][31:0] l_res_div_req_b;
 logic  l_res_div_protocol_reject_valid;
 logic  l_res_div_rsp_valid;
 logic  l_res_div_rsp_ready;
 logic [95:0] l_res_div_rsp_tag;
 logic [7:0] l_res_div_rsp_numeric_error;
 logic [7:0][31:0] l_res_div_rsp_data;
 logic [5:0] l_res_div_pending_vectors;
 logic [5:0] l_res_div_in_flight_vectors;
 logic [8:0] l_res_div_in_flight_scalars;
 logic  l_res_div_protocol_fault;
 logic  l_res_scale_valid;
 logic  l_res_scale_ready;
 logic [95:0] l_res_scale_tag;
 logic [3:0][31:0] l_res_scale_input;
 logic  l_res_scale_rsp_valid;
 logic  l_res_scale_rsp_ready;
 logic [95:0] l_res_scale_rsp_tag;
 logic [3:0][31:0] l_res_scale_data;
 logic [6:0] l_res_scale_pending;
 logic  l_res_scale_fault;
 logic  l_rope_owner_valid;
 logic [63:0] l_rope_owner_request_id;
 logic [31:0] l_rope_owner_generation;
 logic [31:0] l_rope_owner_epoch;
 logic  l_rope_wr_valid;
 logic  l_rope_wr_ready;
 logic [63:0] l_rope_wr_request_id;
 logic [31:0] l_rope_wr_generation;
 logic [31:0] l_rope_wr_epoch;
 logic [3:0] l_rope_wr_head;
 logic [6:0] l_rope_wr_token;
 logic [95:0] l_rope_wr_tag;
 logic [63:0][31:0] l_rope_wr_q;
 logic [63:0][31:0] l_rope_wr_k;
 logic  l_rope_wr_commit_valid;
 logic [95:0] l_rope_wr_commit_tag;
 logic  l_rope_reject_valid;
 logic [2:0] l_rope_reject_code;
 logic  l_cache_bound_valid;
 logic [127:0] l_cache_bound_model_id;
 logic [127:0] l_cache_bound_numeric_id;
 logic [127:0] l_cache_bound_table_key;
 logic [1:0] l_cache_family_complete;
 logic  l_cache_owner_valid;
 logic [63:0] l_cache_owner_request_id;
 logic [31:0] l_cache_owner_generation;
 logic [31:0] l_cache_owner_epoch;
 logic  l_cache_rd_valid;
 logic  l_cache_rd_ready;
 logic  l_cache_rd_family;
 logic [6:0] l_cache_rd_row;
 logic [95:0] l_cache_rd_tag;
 logic [63:0] l_cache_rd_request_id;
 logic [31:0] l_cache_rd_generation;
 logic [31:0] l_cache_rd_epoch;
 logic  l_cache_rd_reject_valid;
 logic [2:0] l_cache_rd_reject_code;
 logic  l_cache_rsp_valid;
 logic  l_cache_rsp_ready;
 logic  l_cache_rsp_family;
 logic [6:0] l_cache_rsp_row;
 logic [95:0] l_cache_rsp_tag;
 logic [127:0][31:0] l_cache_rsp_data;
 logic  m_cmd_valid;
 logic  m_cmd_ready;
 logic  m_descriptor_precheck_ok;
 logic [31:0] m_cmd_version;
 logic [63:0] m_cmd_request;
 logic [63:0] m_cmd_model;
 logic [31:0] m_cmd_generation;
 logic [31:0] m_cmd_epoch;
 logic [31:0] m_cmd_tensor;
 logic [15:0] m_cmd_k;
 logic [15:0] m_cmd_n;
 logic  m_cmd_a_slot;
 logic  m_cmd_bias;
 logic [3:0][63:0] m_cmd_base;
 logic [3:0][63:0] m_cmd_span;
 logic  m_done_valid;
 logic  m_done_ready;
 logic [2:0] m_status;
 logic [63:0] m_done_request;
 logic [31:0] m_done_generation;
 logic [31:0] m_done_epoch;
 logic [6:0] m_error_row;
 logic [15:0] m_error_col;
 logic [7:0] m_error_group;
 logic [3:0] m_error_stage;
 logic  m_out_valid;
 logic  m_out_ready;
 logic [31:0][31:0] m_out_data;
 logic [6:0] m_out_row;
 logic [15:0] m_out_col;
 logic [15:0] m_out_s;
 logic [63:0] m_out_request;
 logic [31:0] m_out_generation;
 logic [31:0] m_out_epoch;
 logic  m_acfg_valid;
 logic  m_acfg_ready;
 logic  m_acfg_slot;
 logic [15:0] m_acfg_k;
 logic [63:0] m_acfg_request;
 logic [31:0] m_acfg_generation;
 logic [31:0] m_acfg_epoch;
 logic  m_acfg_rsp_valid;
 logic  m_acfg_rsp_ready;
 logic [1:0] m_acfg_status;
 logic  m_fill_cancel_valid;
 logic  m_fill_cancel_ready;
 logic  m_fill_cancel_slot;
 logic [63:0] m_fill_cancel_request;
 logic [31:0] m_fill_cancel_generation;
 logic [31:0] m_fill_cancel_epoch;
 logic  m_fill_cancel_reject_valid;
 logic [3:0] m_fill_cancel_reject_code;
 logic  m_fill_cancel_rsp_valid;
 logic  m_fill_cancel_rsp_ready;
 logic  m_fill_cancel_rsp_slot;
 logic [63:0] m_fill_cancel_rsp_request;
 logic [31:0] m_fill_cancel_rsp_generation;
 logic [31:0] m_fill_cancel_rsp_epoch;
 logic  m_awr_valid;
 logic  m_awr_ready;
 logic [6:0] m_awr_row;
 logic [6:0] m_awr_group;
 logic [271:0] m_awr_data;
 logic [63:0] m_awr_request;
 logic [31:0] m_awr_generation;
 logic [31:0] m_awr_epoch;
 logic  m_awr_rsp_valid;
 logic  m_awr_rsp_ready;
 logic  m_coef_cfg_valid;
 logic  m_coef_cfg_ready;
 logic [63:0] m_coef_model;
 logic [63:0] m_coef_request;
 logic [31:0] m_coef_tensor;
 logic [31:0] m_coef_generation;
 logic [31:0] m_coef_epoch;
 logic [15:0] m_coef_n;
 logic  m_coef_wr_valid;
 logic  m_coef_wr_ready;
 logic [6:0] m_coef_wr_addr;
 logic [31:0][31:0] m_coef_wr_data;
 logic  m_coef_rsp_valid;
 logic  m_coef_rsp_ready;
 logic [1:0] m_coef_status;
 logic [15:0] m_coef_error_col;
 logic [3:0] m_arvalid;
 logic [3:0] m_arready;
 logic [3:0][63:0] m_araddr;
 logic [3:0][2:0] m_arid;
 logic [3:0][7:0] m_arlen;
 logic [3:0] m_rvalid;
 logic [3:0] m_rready;
 logic [3:0][2:0] m_rid;
 logic [3:0][511:0] m_rdata;
 logic [3:0][1:0] m_rresp;
 logic [3:0] m_rlast;
 logic  m_run_enable;
 logic [31:0] m_elapsed_cycles;
 logic [31:0] m_first_output_cycle;
 logic [31:0] m_w_wait_cycles;
 logic [31:0] m_ctx_wait_cycles;
 logic [15:0] m_blocks_issued;
 logic [15:0] m_blocks_computed;
 logic [15:0] m_blocks_retired;
 logic [31:0] m_ps_merged_reads;
 logic [31:0] m_ps_response_holds;
 logic [31:0] m_bias_add_conflicts;
 logic [31:0] m_compute_output_overlap;
 logic [7:0] m_peak_return_reservations;
 logic [6:0] m_arithmetic_debt;
 logic [6:0] m_peak_arithmetic_reservations;
 logic  m_profile_valid;
 logic [63:0] m_fp_owner_request;
 logic [31:0] m_fp_owner_generation;
 logic [31:0] m_fp_owner_epoch;
 logic  m_bind_new_lease;
 logic  m_fp_release_valid;
 logic  m_fp_phase_debt_clear;
 logic  m_fp_lease_ready;
 logic  m_fp_release_ready;
 logic  m_fp_lease_active;
 logic  m_fp_draining;
 logic  m_fp_fault;
 logic  m_storage_bind_ready;
 logic  m_storage_idle;
 logic  m_mul_req_valid;
 logic  m_mul_rsp_ready;
 logic  m_mul_req_ready;
 logic  m_mul_rsp_valid;
 logic [95:0] m_mul_req_tag;
 logic [95:0] m_mul_rsp_tag;
 logic [255:0][31:0] m_mul_a;
 logic [255:0][31:0] m_mul_b;
 logic [255:0][31:0] m_mul_rsp_data;
 logic [6:0] m_mul_pending;
 logic [6:0] m_add_req_valid;
 logic [6:0] m_add_req_is_root;
 logic [6:0] m_add_rsp_ready;
 logic [6:0] m_add_req_ready;
 logic [6:0] m_add_rsp_valid;
 logic [6:0][2:0] m_add_req_phase;
 logic [6:0][31:0] m_add_req_epoch;
 logic [6:0][95:0] m_add_req_tag;
 logic [6:0][95:0] m_add_rsp_tag;
 logic [255:0][31:0] m_add_a;
 logic [255:0][31:0] m_add_b;
 logic [255:0][31:0] m_add_rsp_data;
 logic [6:0][6:0] m_add_pending;
 logic  m_ps_wr_valid;
 logic  m_ps_wr_rsp_ready;
 logic  m_ps_rd_valid;
 logic  m_ps_rd_rsp_ready;
 logic  m_ps_wr_ready;
 logic  m_ps_wr_rsp_valid;
 logic  m_ps_rd_ready;
 logic  m_ps_rd_rsp_valid;
 logic [1023:0] m_ps_wr_mask;
 logic [1023:0] m_ps_rd_mask;
 logic [1023:0] m_ps_rd_rsp_mask;
 logic [1023:0][3:0] m_ps_wr_addr;
 logic [1023:0][3:0] m_ps_rd_addr;
 logic [1023:0][31:0] m_ps_wr_data;
 logic [1023:0][31:0] m_ps_rd_rsp_data;
 logic [95:0] m_ps_wr_tag;
 logic [95:0] m_ps_rd_tag;
 logic [95:0] m_ps_wr_rsp_tag;
 logic [95:0] m_ps_rd_rsp_tag;
 logic  q_run_enable;
 logic  q_cmd_valid;
 logic  q_cmd_ready;
 logic  q_cmd_slot;
 logic [15:0] q_cmd_k;
 logic [63:0] q_cmd_request;
 logic [31:0] q_cmd_generation;
 logic [31:0] q_cmd_epoch;
 logic  q_in_valid;
 logic  q_in_ready;
 logic [31:0][31:0] q_in_data;
 logic [63:0] q_in_request;
 logic [31:0] q_in_generation;
 logic [31:0] q_in_epoch;
 logic [7:0] q_in_row;
 logic [7:0] q_in_group;
 logic  q_producer_close_valid;
 logic  q_producer_close_ready;
 logic  q_producer_close_success;
 logic  q_done_valid;
 logic  q_done_ready;
 logic [2:0] q_status;
 logic [2:0] q_quant_phase;
 logic [6:0] q_quant_row;
 logic [6:0] q_quant_group;
 logic [4:0] q_quant_element;
 logic [31:0] q_quant_accepted;
 logic [31:0] q_quant_retired;
 logic [31:0] q_a_writes;
 logic [31:0] q_a_write_acks;
 logic  q_quant_last_event;
 logic  q_a_publish_event;
 logic  q_acfg_valid;
 logic  q_acfg_ready;
 logic  q_acfg_slot;
 logic [15:0] q_acfg_k;
 logic [63:0] q_acfg_request;
 logic [31:0] q_acfg_generation;
 logic [31:0] q_acfg_epoch;
 logic  q_acfg_rsp_valid;
 logic  q_acfg_rsp_ready;
 logic [1:0] q_acfg_status;
 logic  q_awr_valid;
 logic  q_awr_ready;
 logic [6:0] q_awr_row;
 logic [6:0] q_awr_group;
 logic [271:0] q_awr_data;
 logic [63:0] q_awr_request;
 logic [31:0] q_awr_generation;
 logic [31:0] q_awr_epoch;
 logic  q_awr_rsp_valid;
 logic  q_awr_rsp_ready;
 logic  q_fill_cancel_valid;
 logic  q_fill_cancel_ready;
 logic  q_fill_cancel_slot;
 logic [63:0] q_fill_cancel_request;
 logic [31:0] q_fill_cancel_generation;
 logic [31:0] q_fill_cancel_epoch;
 logic  q_fill_cancel_reject_valid;
 logic [3:0] q_fill_cancel_reject_code;
 logic  q_fill_cancel_rsp_valid;
 logic  q_fill_cancel_rsp_ready;
 logic  q_fill_cancel_rsp_slot;
 logic [63:0] q_fill_cancel_rsp_request;
 logic [31:0] q_fill_cancel_rsp_generation;
 logic [31:0] q_fill_cancel_rsp_epoch;
 logic  q_d_lease_valid;
 logic  q_d_lease_ready;
 logic [63:0] q_d_lease_request_id;
 logic [31:0] q_d_lease_generation;
 logic [31:0] q_d_lease_epoch;
 logic [3:0] q_d_lease_head;
 logic [2:0] q_d_lease_phase;
 logic  q_d_release_valid;
 logic  q_d_release_ready;
 logic [2:0] q_d_release_phase;
 logic [31:0] q_d_release_epoch;
 logic  q_d_phase_debt_clear;
 logic  q_d_lease_active;
 logic  q_d_draining;
 logic [63:0] q_d_rsp_request_id;
 logic [31:0] q_d_rsp_generation;
 logic [31:0] q_d_rsp_epoch;
 logic [3:0] q_d_rsp_head;
 logic [2:0] q_d_rsp_phase;
 logic  q_d_req_valid;
 logic  q_d_req_ready;
 logic [31:0] q_d_req_generation;
 logic [31:0] q_d_req_epoch;
 logic [2:0] q_d_req_phase;
 logic [7:0] q_d_req_lane_mask;
 logic [95:0] q_d_req_tag;
 logic [7:0][31:0] q_d_req_a;
 logic [7:0][31:0] q_d_req_b;
 logic  q_d_protocol_reject_valid;
 logic [3:0] q_d_protocol_reject_code;
 logic  q_d_rsp_valid;
 logic  q_d_rsp_ready;
 logic [95:0] q_d_rsp_tag;
 logic [7:0] q_d_rsp_lane_mask;
 logic [7:0] q_d_rsp_numeric_error;
 logic [7:0][31:0] q_d_rsp_data;
 logic [5:0] q_d_pending_vectors;
 logic [5:0] q_d_in_flight_vectors;
 logic [8:0] q_d_in_flight_scalars;
 logic  q_d_protocol_fault;
 logic  r_res_qkv_wr_valid;
 logic  r_res_qkv_wr_ready;
 logic [1:0] r_res_qkv_wr_plane;
 logic [3:0] r_res_qkv_wr_head;
 logic [6:0] r_res_qkv_wr_token;
 logic  r_res_qkv_wr_half;
 logic [31:0][31:0] r_res_qkv_wr_data;
 logic [2:0] r_res_qkv_rd_valid;
 logic [2:0] r_res_qkv_rd_ready;
 logic [2:0][3:0] r_res_qkv_rd_head;
 logic [2:0][6:0] r_res_qkv_rd_token;
 logic [2:0][31:0] r_res_qkv_rd_tag;
 logic [2:0] r_res_qkv_rd_rsp_valid;
 logic [2:0] r_res_qkv_rd_rsp_ready;
 logic [2:0][3:0] r_res_qkv_rd_rsp_head;
 logic [2:0][6:0] r_res_qkv_rd_rsp_token;
 logic [2:0][31:0] r_res_qkv_rd_rsp_tag;
 logic [2:0][63:0][31:0] r_res_qkv_rd_rsp_data;
 logic  r_res_st_bind_valid;
 logic  r_res_st_bind_ready;
 logic [63:0] r_res_st_bind_request_id;
 logic [31:0] r_res_st_bind_generation;
 logic [31:0] r_res_st_bind_epoch;
 logic [3:0] r_res_st_bind_head;
 logic [2:0] r_res_st_bind_phase;
 logic [63:0] r_res_st_op_request_id;
 logic [31:0] r_res_st_op_generation;
 logic [31:0] r_res_st_op_epoch;
 logic [2:0] r_res_st_op_phase;
 logic [63:0] r_res_st_rsp_request_id;
 logic [31:0] r_res_st_rsp_generation;
 logic [31:0] r_res_st_rsp_epoch;
 logic [3:0] r_res_st_rsp_head;
 logic [2:0] r_res_st_rsp_phase;
 logic  r_res_st_ps_wr_valid;
 logic  r_res_st_ps_wr_ready;
 logic [1023:0] r_res_st_ps_wr_mask;
 logic [1023:0][3:0] r_res_st_ps_wr_addr;
 logic [1023:0][31:0] r_res_st_ps_wr_data;
 logic [95:0] r_res_st_ps_wr_tag;
 logic  r_res_st_ps_wr_rsp_valid;
 logic  r_res_st_ps_wr_rsp_ready;
 logic [95:0] r_res_st_ps_wr_rsp_tag;
 logic  r_res_st_ps_rd_valid;
 logic  r_res_st_ps_rd_ready;
 logic [1023:0] r_res_st_ps_rd_mask;
 logic [1023:0][3:0] r_res_st_ps_rd_addr;
 logic [95:0] r_res_st_ps_rd_tag;
 logic  r_res_st_ps_rd_rsp_valid;
 logic  r_res_st_ps_rd_rsp_ready;
 logic [1023:0][31:0] r_res_st_ps_rd_rsp_data;
 logic [1023:0] r_res_st_ps_rd_rsp_mask;
 logic [95:0] r_res_st_ps_rd_rsp_tag;
 logic  r_res_st_g_wr_valid;
 logic  r_res_st_g_wr_ready;
 logic [255:0] r_res_st_g_wr_mask;
 logic [255:0][5:0] r_res_st_g_wr_addr;
 logic [255:0][31:0] r_res_st_g_wr_data;
 logic [95:0] r_res_st_g_wr_tag;
 logic  r_res_st_g_wr_rsp_valid;
 logic  r_res_st_g_wr_rsp_ready;
 logic [95:0] r_res_st_g_wr_rsp_tag;
 logic  r_res_st_g_rd_valid;
 logic  r_res_st_g_rd_ready;
 logic [255:0] r_res_st_g_rd_mask;
 logic [255:0][5:0] r_res_st_g_rd_addr;
 logic [95:0] r_res_st_g_rd_tag;
 logic  r_res_st_g_rd_rsp_valid;
 logic  r_res_st_g_rd_rsp_ready;
 logic [255:0][31:0] r_res_st_g_rd_rsp_data;
 logic [255:0] r_res_st_g_rd_rsp_mask;
 logic [95:0] r_res_st_g_rd_rsp_tag;
 logic  r_res_st_context_wr_valid;
 logic  r_res_st_context_wr_ready;
 logic [63:0] r_res_st_context_wr_mask;
 logic [63:0][10:0] r_res_st_context_wr_addr;
 logic [63:0][31:0] r_res_st_context_wr_data;
 logic [95:0] r_res_st_context_wr_tag;
 logic  r_res_st_context_wr_rsp_valid;
 logic  r_res_st_context_wr_rsp_ready;
 logic [95:0] r_res_st_context_wr_rsp_tag;
 logic  r_res_st_context_rd_valid;
 logic  r_res_st_context_rd_ready;
 logic [63:0] r_res_st_context_rd_mask;
 logic [63:0][10:0] r_res_st_context_rd_addr;
 logic [95:0] r_res_st_context_rd_tag;
 logic  r_res_st_context_rd_rsp_valid;
 logic  r_res_st_context_rd_rsp_ready;
 logic [63:0][31:0] r_res_st_context_rd_rsp_data;
 logic [63:0] r_res_st_context_rd_rsp_mask;
 logic [95:0] r_res_st_context_rd_rsp_tag;
 logic  r_res_st_idle;
 logic  r_res_fp_lease_valid;
 logic  r_res_fp_lease_ready;
 logic [63:0] r_res_fp_lease_request_id;
 logic [31:0] r_res_fp_lease_generation;
 logic [31:0] r_res_fp_lease_epoch;
 logic [3:0] r_res_fp_lease_head;
 logic [2:0] r_res_fp_lease_phase;
 logic  r_res_fp_release_valid;
 logic  r_res_fp_release_ready;
 logic [2:0] r_res_fp_release_phase;
 logic [31:0] r_res_fp_release_epoch;
 logic  r_res_fp_phase_debt_clear;
 logic  r_res_fp_lease_active;
 logic  r_res_fp_draining;
 logic [63:0] r_res_fp_rsp_request_id;
 logic [31:0] r_res_fp_rsp_generation;
 logic [31:0] r_res_fp_rsp_epoch;
 logic [3:0] r_res_fp_rsp_head;
 logic [2:0] r_res_fp_rsp_phase;
 logic  r_res_fp_mul_req_valid;
 logic  r_res_fp_mul_req_ready;
 logic [2:0] r_res_fp_mul_req_phase;
 logic [31:0] r_res_fp_mul_req_epoch;
 logic [95:0] r_res_fp_mul_req_tag;
 logic [255:0][31:0] r_res_fp_mul_a;
 logic [255:0][31:0] r_res_fp_mul_b;
 logic  r_res_fp_mul_rsp_valid;
 logic  r_res_fp_mul_rsp_ready;
 logic [95:0] r_res_fp_mul_rsp_tag;
 logic [255:0][31:0] r_res_fp_mul_rsp_data;
 logic [6:0] r_res_fp_add_req_valid;
 logic [6:0] r_res_fp_add_req_is_root;
 logic [6:0] r_res_fp_add_req_ready;
 logic [6:0][2:0] r_res_fp_add_req_phase;
 logic [6:0][31:0] r_res_fp_add_req_epoch;
 logic [6:0][95:0] r_res_fp_add_req_tag;
 logic [255:0][31:0] r_res_fp_add_a;
 logic [255:0][31:0] r_res_fp_add_b;
 logic [6:0] r_res_fp_add_rsp_valid;
 logic [6:0] r_res_fp_add_rsp_ready;
 logic [6:0][95:0] r_res_fp_add_rsp_tag;
 logic [255:0][31:0] r_res_fp_add_rsp_data;
 logic [6:0] r_res_fp_mul_pending;
 logic [6:0][6:0] r_res_fp_add_pending;
 logic  r_res_fp_protocol_fault;
 logic  r_res_ln_bind_valid;
 logic  r_res_ln_bind_ready;
 logic [63:0] r_res_ln_bind_request_id;
 logic [31:0] r_res_ln_bind_generation;
 logic [31:0] r_res_ln_bind_epoch;
 logic [3:0] r_res_ln_bind_head;
 logic [2:0] r_res_ln_bind_phase;
 logic [63:0] r_res_ln_op_request_id;
 logic [31:0] r_res_ln_op_generation;
 logic [31:0] r_res_ln_op_epoch;
 logic [2:0] r_res_ln_op_phase;
 logic [63:0] r_res_ln_rsp_request_id;
 logic [31:0] r_res_ln_rsp_generation;
 logic [31:0] r_res_ln_rsp_epoch;
 logic [3:0] r_res_ln_rsp_head;
 logic [2:0] r_res_ln_rsp_phase;
 logic  r_res_ln_wr_valid;
 logic  r_res_ln_wr_ready;
 logic [255:0] r_res_ln_wr_mask;
 logic [255:0][4:0] r_res_ln_wr_addr;
 logic [255:0][31:0] r_res_ln_wr_data;
 logic [95:0] r_res_ln_wr_tag;
 logic  r_res_ln_wr_rsp_valid;
 logic  r_res_ln_wr_rsp_ready;
 logic [95:0] r_res_ln_wr_rsp_tag;
 logic  r_res_ln_rd_valid;
 logic  r_res_ln_rd_ready;
 logic [255:0] r_res_ln_rd_mask;
 logic [255:0][4:0] r_res_ln_rd_addr;
 logic [95:0] r_res_ln_rd_tag;
 logic  r_res_ln_rd_rsp_valid;
 logic  r_res_ln_rd_rsp_ready;
 logic [255:0][31:0] r_res_ln_rd_rsp_data;
 logic [255:0] r_res_ln_rd_rsp_mask;
 logic [95:0] r_res_ln_rd_rsp_tag;
 logic  r_res_ln_idle;
 logic  r_res_sfu_lease_valid;
 logic  r_res_sfu_lease_ready;
 logic [63:0] r_res_sfu_lease_request_id;
 logic [31:0] r_res_sfu_lease_generation;
 logic [31:0] r_res_sfu_lease_epoch;
 logic [3:0] r_res_sfu_lease_head;
 logic [2:0] r_res_sfu_lease_phase;
 logic  r_res_sfu_release_valid;
 logic [2:0] r_res_sfu_release_phase;
 logic [31:0] r_res_sfu_release_epoch;
 logic  r_res_sfu_phase_debt_clear;
 logic  r_res_sfu_lease_active;
 logic [63:0] r_res_sfu_context_valid;
 logic [63:0] r_res_sfu_context_row_hi;
 logic  r_res_sfu_req_valid;
 logic  r_res_sfu_req_ready;
 logic [1:0] r_res_sfu_req_mode;
 logic [31:0] r_res_sfu_req_generation;
 logic [31:0] r_res_sfu_req_epoch;
 logic [2:0] r_res_sfu_req_phase;
 logic [10:0] r_res_sfu_req_tag;
 logic [7:0][31:0] r_res_sfu_req_x;
 logic  r_res_sfu_reject_valid;
 logic  r_res_sfu_rsp_valid;
 logic  r_res_sfu_rsp_ready;
 logic [10:0] r_res_sfu_rsp_tag;
 logic [7:0][31:0] r_res_sfu_rsp_data;
 logic [8:0] r_res_sfu_pending_vectors;
 logic [8:0] r_res_sfu_in_flight_vectors;
 logic  r_res_sfu_protocol_fault;
 logic  r_res_div_lease_valid;
 logic  r_res_div_lease_ready;
 logic [63:0] r_res_div_lease_request_id;
 logic [31:0] r_res_div_lease_generation;
 logic [31:0] r_res_div_lease_epoch;
 logic [3:0] r_res_div_lease_head;
 logic [2:0] r_res_div_lease_phase;
 logic  r_res_div_release_ready;
 logic  r_res_div_draining;
 logic [63:0] r_res_div_rsp_request_id;
 logic [31:0] r_res_div_rsp_generation;
 logic [31:0] r_res_div_rsp_epoch;
 logic [3:0] r_res_div_rsp_head;
 logic [2:0] r_res_div_rsp_phase;
 logic [3:0] r_res_div_protocol_reject_code;
 logic [7:0] r_res_div_rsp_lane_mask;
 logic  r_res_div_release_valid;
 logic [2:0] r_res_div_release_phase;
 logic [31:0] r_res_div_release_epoch;
 logic  r_res_div_phase_debt_clear;
 logic  r_res_div_lease_active;
 logic  r_res_div_req_valid;
 logic  r_res_div_req_ready;
 logic [31:0] r_res_div_req_generation;
 logic [31:0] r_res_div_req_epoch;
 logic [2:0] r_res_div_req_phase;
 logic [7:0] r_res_div_req_lane_mask;
 logic [95:0] r_res_div_req_tag;
 logic [7:0][31:0] r_res_div_req_a;
 logic [7:0][31:0] r_res_div_req_b;
 logic  r_res_div_protocol_reject_valid;
 logic  r_res_div_rsp_valid;
 logic  r_res_div_rsp_ready;
 logic [95:0] r_res_div_rsp_tag;
 logic [7:0] r_res_div_rsp_numeric_error;
 logic [7:0][31:0] r_res_div_rsp_data;
 logic [5:0] r_res_div_pending_vectors;
 logic [5:0] r_res_div_in_flight_vectors;
 logic [8:0] r_res_div_in_flight_scalars;
 logic  r_res_div_protocol_fault;
 logic  r_res_scale_valid;
 logic  r_res_scale_ready;
 logic [95:0] r_res_scale_tag;
 logic [3:0][31:0] r_res_scale_input;
 logic  r_res_scale_rsp_valid;
 logic  r_res_scale_rsp_ready;
 logic [95:0] r_res_scale_rsp_tag;
 logic [3:0][31:0] r_res_scale_data;
 logic [6:0] r_res_scale_pending;
 logic  r_res_scale_fault;
 logic  r_rope_owner_valid;
 logic [63:0] r_rope_owner_request_id;
 logic [31:0] r_rope_owner_generation;
 logic [31:0] r_rope_owner_epoch;
 logic  r_rope_wr_valid;
 logic  r_rope_wr_ready;
 logic [63:0] r_rope_wr_request_id;
 logic [31:0] r_rope_wr_generation;
 logic [31:0] r_rope_wr_epoch;
 logic [3:0] r_rope_wr_head;
 logic [6:0] r_rope_wr_token;
 logic [95:0] r_rope_wr_tag;
 logic [63:0][31:0] r_rope_wr_q;
 logic [63:0][31:0] r_rope_wr_k;
 logic  r_rope_wr_commit_valid;
 logic [95:0] r_rope_wr_commit_tag;
 logic  r_rope_reject_valid;
 logic [2:0] r_rope_reject_code;

 localparam [6:0] IDLE=0,PREP=1,QSUB=2,QRUN=3,QMSUB=4,QMRUN=5,LSTART=6,LRUN=7,CSUB=8,CRUN=9,CDRAIN=10,WMSUB=11,WMRUN=12,PCANCEL=13,PCWAIT=14,DISCARD=15,DISCWAIT=16,FINISH=17,ACANCEL=18,ACWAIT=19;
 localparam [6:0] F_ARENA=20,F_NQSUB=21,F_NQRUN=22,F_WISUB=23,F_GQSUB=24,F_RUN=25,F_CLOSE=26,F_QDRAIN=27,F_ABORT=28,F_DISCARD=29,F_RELEASE=30,F_RETURN=31;
  logic [6:0] state;
 logic [63:0] request_id;logic [31:0] generation,epoch;
 logic [2:0] kind;logic [4:0] layer_index;logic [127:0] mask;
 logic [1:0][31:0] tensor_id;logic [1:0][3:0][63:0] base,span;
 logic [12:0] inputs_accepted;
 logic producer_failed,context_failed;
  logic g_producer_cancel_valid;
  logic g_producer_cancel_ready;
  logic [63:0] g_producer_cancel_request_id;
  logic [31:0] g_producer_cancel_generation;
  logic [31:0] g_producer_cancel_epoch;
  logic g_producer_cancel_reject_valid;
  logic g_done_cancelled;
  logic g_cmd_valid;
  logic g_cmd_ready;
  logic [63:0] g_cmd_request_id;
  logic [31:0] g_cmd_generation;
  logic [31:0] g_cmd_epoch;
  logic g_storage_owner_valid;
  logic [63:0] g_storage_owner_request_id;
  logic [31:0] g_storage_owner_generation;
  logic [31:0] g_storage_owner_epoch;
  logic [2:0] g_storage_owner_phase;
  logic g_sfu_owner_valid;
  logic [63:0] g_sfu_owner_request_id;
  logic [31:0] g_sfu_owner_generation;
  logic [31:0] g_sfu_owner_epoch;
  logic [2:0] g_sfu_owner_phase;
  logic g_fill_valid;
  logic g_fill_ready;
  logic [63:0] g_fill_request_id;
  logic [31:0] g_fill_generation;
  logic [31:0] g_fill_epoch;
  logic g_fill_slot;
  logic g_fill_half;
  logic [6:0] g_fill_s;
  logic [6:0] g_fill_row;
  logic [31:0][31:0] g_fill_data;
  logic g_fill_reject_valid;
  logic [1:0] g_fill_reject_code;
  logic g_out_valid;
  logic g_out_ready;
  logic [7:0][31:0] g_out_data;
  logic [7:0][31:0] g_out_status;
  logic [95:0] g_out_tag;
  logic [6:0] g_out_s;
  logic [6:0] g_out_row;
  logic [1:0] g_out_chunk;
  logic g_done_valid;
  logic g_done_ready;
  logic [31:0] g_done_status;
  logic [2:0] g_done_error_rank;
  logic [6:0] g_done_error_row;
  logic [11:0] g_done_error_column;
  logic [63:0] g_rsp_request_id;
  logic [31:0] g_rsp_generation;
  logic [31:0] g_rsp_epoch;
  logic g_discard_valid;
  logic g_discard_ready;
  logic [63:0] g_discard_request_id;
  logic [31:0] g_discard_generation;
  logic [31:0] g_discard_epoch;
  logic g_discard_reject_valid;
  logic g_engine_idle;
  logic g_active;
  logic g_needs_discard;
  logic g_protocol_fault;
  logic [1:0] g_slot_active;
  logic [1:0] g_slot_ready;
  logic [1:0][6:0] g_slot_s;
  logic [1:0][9:0] g_slot_consumed_vectors;
  logic [1:0][8:0] g_slot_math_pending;
  logic [1:0][8:0] g_slot_sfu_debt;
  logic [1:0][7:0] g_slot_fp_debt;
  logic [7:0][18:0] g_covered;
  logic [7:0][18:0] g_evaluated;
  logic g_pool_reset_n;
  logic [8:0] g_fp_req_valid;
  logic [8:0] g_fp_req_ready;
  logic [8:0][95:0] g_fp_req_tag;
  logic [8:0][7:0][31:0] g_fp_req_a;
  logic [8:0][7:0][31:0] g_fp_req_b;
  logic [8:0] g_fp_rsp_valid;
  logic [8:0][95:0] g_fp_rsp_tag;
  logic [8:0][7:0][31:0] g_fp_rsp_data;
  logic [8:0][7:0][31:0] g_fp_rsp_status;
  logic g_fp_pool_fault;
  logic g_sfu_req_valid;
  logic g_sfu_req_ready;
  logic [95:0] g_sfu_req_tag;
  logic [7:0] g_sfu_req_mask;
  logic [7:0][31:0] g_sfu_req_x;
  logic g_sfu_rsp_valid;
  logic g_sfu_rsp_ready;
  logic [95:0] g_sfu_rsp_tag;
  logic [7:0][31:0] g_sfu_rsp_data;
  logic [7:0][31:0] g_sfu_rsp_status;
  logic g_sfu_protocol_fault;
  logic g_sfu_reject_valid;
  logic g_g_wr_valid;
  logic g_g_wr_ready;
  logic [255:0] g_g_wr_mask;
  logic [255:0][5:0] g_g_wr_addr;
  logic [255:0][31:0] g_g_wr_data;
  logic [95:0] g_g_wr_tag;
  logic g_g_wr_rsp_valid;
  logic g_g_wr_rsp_ready;
  logic [95:0] g_g_wr_rsp_tag;
  logic g_g_rd_valid;
  logic g_g_rd_ready;
  logic [255:0] g_g_rd_mask;
  logic [255:0][5:0] g_g_rd_addr;
  logic [95:0] g_g_rd_tag;
  logic g_g_rd_rsp_valid;
  logic g_g_rd_rsp_ready;
  logic [255:0][31:0] g_g_rd_rsp_data;
  logic [255:0] g_g_rd_rsp_mask;
  logic [95:0] g_g_rd_rsp_tag;
  logic ws_owner_req_valid,ws_owner_req_g,ws_owner_req_ready,ws_a_enable,ws_g_enable,ws_rearm,ws_owner_g;
  logic [15:0] pack_seq; logic pack_full,pack_fault,g_cancel_sent,q_close_sent;
  logic [31:0][31:0] pack_data;
  wire [15:0] pack_previous=pack_seq-1'b1;
  wire encoder0_mode=kind>=5;
  wire decision_mode=layer_index>=28;
  wire ffn_mode=active_epoch_offset==layer_offset(layer_index,4);
  wire ffn_state=state==D1SUB||state==D1RUN||state==D1DRAIN||state==D2SUB||state==D2RUN||state==D2DRAIN||state==F_ARENA||state==F_NQSUB||state==F_NQRUN||state==F_WISUB||state==F_GQSUB||state==F_RUN||state==F_CLOSE||state==F_QDRAIN||state==F_ABORT||state==F_DISCARD||state==F_RELEASE||state==F_RETURN;

  wire [8:0] tanh_pending,tanh_flight;
  logic tanh_lease_ready,tanh_lease_active,tanh_draining,tanh_release_ready;
  logic [63:0] tanh_request;logic [31:0] tanh_generation,tanh_epoch;logic [2:0] tanh_phase;
  logic [7:0] tanh_rsp_mask;logic [1:0] tanh_reject_code;
  wire g_all_covered=&{g_covered[0]==335872,g_covered[1]==335872,g_covered[2]==335872,g_covered[3]==335872,g_covered[4]==335872,g_covered[5]==335872,g_covered[6]==335872,g_covered[7]==335872};
  wire g_output_fire=g_out_valid&&g_out_ready;
  wire ffn_close_fire=q_producer_close_valid&&q_producer_close_ready;
  wire ffn_failure=pack_fault||g_protocol_fault||done_status!=0;

wire matrix_owner,front_owner,legal_input;
// Generated from frozen A007 public header; wire declarations only.
logic [1:0] v2_owner_req;
logic [1:0] v2_owner;
logic v2_ln_enable;
logic v2_vector_enable;
logic v2_resident_owner_valid;
logic [63:0] v2_resident_owner_request_id;
logic [31:0] v2_resident_owner_generation;
logic [31:0] v2_resident_owner_epoch;
logic v2_resident_inputs_ready;
logic v2_parent_matrix_retired;
logic v2_parent_quant_retired;
logic [63:0] v2_resident_access_request_id;
logic [31:0] v2_resident_access_generation;
logic [31:0] v2_resident_access_epoch;
logic v2_h_wr_valid;
logic v2_h_wr_ready;
logic v2_h_wr_commit;
logic [11:0] v2_h_wr_addr;
logic [31:0][31:0] v2_h_wr_data;
logic v2_h_rd_valid;
logic v2_h_rd_ready;
logic [11:0] v2_h_rd_addr;
logic v2_h_rsp_valid;
logic v2_h_rsp_ready;
logic [11:0] v2_h_rsp_addr;
logic [31:0][31:0] v2_h_rsp_data;
logic v2_h_reject_valid;
logic v2_q_wr_valid;
logic v2_q_wr_ready;
logic v2_q_wr_commit;
logic [11:0] v2_q_wr_addr;
logic [31:0][31:0] v2_q_wr_data;
logic v2_q_rd_valid;
logic v2_q_rd_ready;
logic [11:0] v2_q_rd_addr;
logic v2_q_rsp_valid;
logic v2_q_rsp_ready;
logic [11:0] v2_q_rsp_addr;
logic [31:0][31:0] v2_q_rsp_data;
logic v2_q_reject_valid;
logic v2_scratch_lease_valid;
logic v2_scratch_release_valid;
logic v2_scratch_lease_ready;
logic v2_scratch_release_ready;
logic v2_scratch_owner_active;
logic v2_scratch_retired;
logic v2_h_bank_idle;
logic v2_resident_bank_idle;
logic v2_shared_resources_idle;
logic v2_ln_provider_idle;
logic v2_ln_gamma_begin_valid;
logic v2_ln_gamma_begin_ready;
logic [63:0] v2_ln_gamma_model;
logic [31:0] v2_ln_gamma_key;
logic v2_ln_gamma_valid;
logic v2_ln_gamma_ready;
logic [4:0] v2_ln_gamma_chunk;
logic [31:0][31:0] v2_ln_gamma_data;
logic v2_ln_gamma_done_valid;
logic v2_ln_gamma_done_ready;
logic v2_ln_gamma_done_error;
logic v2_ln_gamma_loaded;
logic v2_ln_done_valid;
logic v2_ln_done_error;
logic [4:0] v2_ln_error_stage;
logic [3:0] v2_ln_error_level;
logic [6:0] v2_ln_error_row;
logic [9:0] v2_ln_error_node;
logic v2_ln_reject_valid;
logic [3:0] v2_ln_reject_code;
logic v2_ln_active;
logic v2_ln_debt_clear;
logic v2_ln_trace_add_valid;
logic [175:0] v2_ln_trace_add_meta;
logic v2_ln_trace_mul_valid;
logic [23:0] v2_ln_trace_mul_meta;
logic [6:0] v2_ln_trace_scalar_valid;
logic [6:0][1:0] v2_ln_trace_scalar_ctx;
logic [6:0][31:0] v2_ln_trace_scalar_data;
logic v2_ln_trace_row_start;
logic [6:0] v2_ln_trace_row;
logic [3:0] v2_ln_ctx_active;
logic [3:0][6:0] v2_ln_ctx_row;
logic [3:0][31:0] v2_ln_raw_coverage;
logic [3:0][31:0] v2_ln_delta_coverage;
logic [31:0] v2_ln_cycle_count;
logic [6:0] v2_ln_peak_add_pending;
logic [6:0] v2_ln_peak_mul_pending;
logic v2_ln_reject_ready;
logic v2_ln_cancel_valid;
logic v2_ln_cancel_ready;
logic [63:0] v2_ln_cancel_request_id;
logic [31:0] v2_ln_cancel_generation;
logic [31:0] v2_ln_cancel_epoch;
logic [1:0] v2_ln_done_kind;
logic v2_ln_cancel_rsp_valid;
logic v2_ln_protocol_fault;
logic [3:0] v2_ln_protocol_code;
logic [7:0] v2_ln_protocol_location;
logic [1:0] v2_ln_error_class;
logic [3:0] v2_ln_error_check;
logic v2_vector_start_valid;
logic v2_vector_start_ready;
logic [1:0] v2_vector_start_op;
logic [63:0] v2_vector_start_request_id;
logic [31:0] v2_vector_start_generation;
logic [31:0] v2_vector_start_epoch;
logic v2_vector_start_reject_valid;
logic v2_vector_done_valid;
logic v2_vector_done_ready;
logic [31:0] v2_vector_done_status;
logic [6:0] v2_vector_done_error_row;
logic [9:0] v2_vector_done_error_column;
logic v2_vector_idle;
logic [12:0] v2_vector_issued_vectors;
logic [12:0] v2_vector_retired_vectors;
logic v2_resident_ln_start_valid;
logic v2_resident_ln_start_ready;
logic [7:0] v2_resident_ln_rows;
logic v2_resident_ln_use_gamma;
logic [63:0] v2_resident_ln_model;
logic [31:0] v2_resident_ln_key;
logic v2_resident_ln_done_valid;
logic v2_resident_ln_done_ready;
logic [31:0] v2_resident_ln_done_status;
logic [1:0] v2_resident_ln_done_kind;
logic v2_resident_ln_source_qualified;
logic [12:0] v2_resident_ln_issued_vectors;
logic [12:0] v2_resident_ln_written_vectors;
logic v2_ext_fp_select;
logic v2_ext_div_select;
logic v2_ext_bind_select;
logic v2_ext_ps_select;
logic v2_ext_context_select;
logic v2_g_tanh_lease_valid;
logic [63:0] v2_g_tanh_lease_request_id;
logic [31:0] v2_g_tanh_lease_generation;
logic [31:0] v2_g_tanh_lease_epoch;
logic [2:0] v2_g_tanh_lease_phase;
logic v2_g_tanh_release_valid;
logic [2:0] v2_g_tanh_release_phase;
logic [31:0] v2_g_tanh_release_epoch;
logic v2_g_tanh_phase_debt_clear;

 // Fixed ABI state plan; all routing predicates below are combinational.
 localparam logic[6:0]
 E_H_LOAD=32,E_H_READY=33,E_WO_LEASE=34,E_WO_POST=35,
 E_REFILL0=36,E_REFILL1=37,E_RA_LEASE=38,E_RA_OWNER=39,
 E_RA_SUB=40,E_RA_RUN=41,E_RA_RELEASE=42,E_LN_LEASE=43,
 E_LN_OWNER=44,E_LN_SUB=45,E_LN_RUN=46,E_LN_RELEASE=47,
 E_FF_LEASE=48,E_FF_OWNER=49,E_FF_POST=50,E_RF_LEASE=51,
 E_RF_OWNER=52,E_RF_SUB=53,E_RF_RUN=54,E_RF_RELEASE=55,
 E_EXPORT=56,E_EXPORT_DRAIN=57,E_ABORT=58,E_FINAL_A=59,
 S_CHECK=60,S_HAR=61,S_HR=62,S_RAR=63,S_RR=64,S_BIAS=65,
 S_GOWNER=66,S_GBEGIN=67,S_GDATA=68,S_GDONE=69,S_TYPE=70,
 S_ROPE=71,S_FINISH=72,I_FINISH=73,
 C_A0_AR=74,C_A0_R=75,C_A1_AR=76,C_A1_R=77,
 C_F0_AR=78,C_F0_R=79,C_F1_AR=80,C_F1_R=81,
 P_OWNER=82,P_LEASE=83,P_START=84,P_RUN=85,P_RETIRE=86,
 N_OWNER=87,N_LEASE=88,N_START=89,N_RUN=90,N_RETIRE=91,
 T_OWNER=92,T_LEASE=93,T_START=94,T_RUN=95,T_RETIRE=96,
 LAYER_NEXT=97,D1SUB=98,D1RUN=99,D1DRAIN=100,D2SUB=101,D2RUN=102,D2DRAIN=103,
 GATHER_START=104,GATHER_RUN=105,GATHER_DRAIN=106,TAIL_ARM=107,TAIL_WAIT=108,TAIL_ABORT=109,
 ERROR_CLEAN=110,SETUP_ERROR=111,C_A0_DRAIN=112,C_A1_DRAIN=113,C_F0_DRAIN=114,C_F1_DRAIN=115,S_HDRAIN=116,S_RDRAIN=117;
 logic[12:0]resident_issue,resident_sink;
 logic[8:0]active_epoch_offset;
 logic[63:0]catalog_base;
 logic[1:0]qtype;
 logic[15:0][6:0]marker_rows;
 logic[15:0]marker_mask;
 wire[31:0]operation_epoch=epoch+{23'b0,active_epoch_offset};
 function automatic logic[8:0]layer_offset(input logic[4:0]l,input logic[2:0]p);
  return l<28?9'(16*l+p):9'(464+16*(l-28)+p);
 endfunction
 function automatic logic[31:0]graph_tensor(input logic[4:0]l,input logic pair_kind,slot);
  if(l<28)return (pair_kind?(slot?88:60):(slot?32:4))+32'(l);
  return (pair_kind?(slot?129:125):(slot?121:117))+2*(32'(l)-28);
 endfunction
 function automatic logic[63:0]required_bytes(input logic[4:0]l,input logic pair_kind,slot);
  if(!pair_kind)return slot?64'd294912:64'd884736;
  if(l>=28)return 64'd1179648;
  return slot?64'd755712:64'd1511424;
 endfunction
 function automatic logic[5:0]first_nonfinite(input logic[31:0][31:0]v);
  logic[5:0]r;r=0;for(int j=31;j>=0;j--)if(v[j][30:23]==255)r={1'b1,5'(j)};return r;
 endfunction
 function automatic logic[63:0]crc_word(input logic[63:0]prior,input logic[511:0]v);
  logic[63:0]c;logic feedback;c=prior;
  for(int byte_index=0;byte_index<64;byte_index++)for(int bit_index=7;bit_index>=0;bit_index--)begin
   feedback=c[63]^v[byte_index*8+bit_index];c={c[62:0],1'b0};if(feedback)c=c^64'h42f0e1eba9ea3693;
  end
  return c;
 endfunction
 function automatic logic[79:0]check_detail(input logic[7:0]code,input logic[15:0]index,input logic[7:0]field,input logic[2:0]port_id,input logic[4:0]lane,input logic[31:0]observed);
  return {code,index,field,port_id,lane,observed,8'b0};
 endfunction
 function automatic logic[7:0]matrix_status_map(input logic[2:0]v);
  case(v)0:return 0;1:return 5;2:return 1;default:return 2;endcase
 endfunction
 function automatic logic[7:0]layer_status_map(input logic[7:0]v);
  case(v)0:return 0;1:return 1;2:return 6;default:return 2;endcase
 endfunction
 wire[4:0]error_global=kind<5?5'd31:active_epoch_offset==448||active_epoch_offset==449||active_epoch_offset==496?5'd30:layer_index;
 task automatic fail(input logic[7:0]op,input logic[2:0]domain_id,input logic[7:0]status_id,source_id,input logic[2:0]format_id,input logic[79:0]detail,input logic[6:0]next_state);
  begin state<=next_state;if(done_status==0)begin done_status<=status_id;source_status<=source_id;error_domain<=domain_id;error_tuple<={op,error_global,format_id,detail};end end
 endtask
 wire m_transport_idle,bias_word_ready,type_word_ready,type_word_commit,type_bank_idle,type_reject_valid;
 wire raw_coeff_bind_ready,raw_coeff_wr_ready;
 wire resident_retired=m_transport_idle&&q_cmd_ready&&!q_done_valid&&v2_shared_resources_idle&&v2_resident_bank_idle&&v2_ln_provider_idle&&!v2_resident_ln_done_valid&&!v2_vector_done_valid;
 wire global_idle=resident_retired&&v2_scratch_retired&&l_layer_idle&&c_idle&&!v2_ln_gamma_done_valid&&type_bank_idle&&tail_owner_idle;
 wire coeff_offer_window=!model_committed&&(state==IDLE||kind==0&&state>=S_CHECK&&state<=S_ROPE)&&l_layer_idle&&v2_scratch_retired&&ws_a_enable;
 assign coeff_bind_ready=raw_coeff_bind_ready&&coeff_offer_window;
 assign coeff_wr_ready=raw_coeff_wr_ready&&coeff_offer_window;
 wire[5:0]input_bad=first_nonfinite(in_data),model_bad=first_nonfinite(model_word_data);
 assign legal_input=state==E_H_LOAD&&!producer_failed&&inputs_accepted<4096&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row=={1'b0,inputs_accepted[11:5]}&&in_group=={3'b0,inputs_accepted[4:0]};
 wire h_load_fire=in_valid&&in_ready;
 wire producer_fail_fire=producer_fail_valid&&producer_fail_ready;
 wire producer_failure=producer_failed||producer_fail_fire;
 wire context_phase=state==CSUB||state==CRUN||state==CDRAIN||state==DISCARD||state==DISCWAIT;
 wire wo_phase=state==WMSUB||state==WMRUN||state==D2SUB||state==D2RUN||state==D2DRAIN;
 wire resident_source_phase=state==QRUN||state==F_NQRUN;
 wire resident_source_q=state==F_NQRUN||state==QRUN&&layer_index!=0;
 wire resident_source_valid=resident_source_q?v2_q_rsp_valid:v2_h_rsp_valid;
 wire[31:0][31:0]resident_source_data=resident_source_q?v2_q_rsp_data:v2_h_rsp_data;
 wire[11:0]resident_source_addr=resident_source_q?v2_q_rsp_addr:v2_h_rsp_addr;
 wire internal_source_fire=resident_source_phase&&q_in_valid&&q_in_ready;
 wire projection_identity_ok=m_out_request==request_id&&m_out_generation==generation&&m_out_epoch==operation_epoch&&m_out_col<1024&&m_out_col[4:0]==0;
 logic[31:0][31:0]relu_data;
 wire[5:0]fc1_bad=first_nonfinite(m_out_data);
 wire fc1_finite=!fc1_bad[5];
 always_comb for(int lane=0;lane<32;lane++)relu_data[lane]=!m_out_data[lane][31]&&m_out_data[lane][30:0]!=0?m_out_data[lane]:32'b0;
 wire vector_done_fire=v2_vector_done_valid&&v2_vector_done_ready;
 wire resident_ln_done_fire=v2_resident_ln_done_valid&&v2_resident_ln_done_ready;
 wire ln_reject_fire=v2_ln_reject_valid&&v2_ln_reject_ready;
 wire h_load_success_valid=state==E_H_READY&&inputs_accepted==4096&&done_status==0&&v2_h_bank_idle;
 wire vector_phase=state==E_RA_SUB||state==E_RA_RUN||state==E_RF_SUB||state==E_RF_RUN||state==T_START||state==T_RUN;
 wire ln_phase=state==E_LN_SUB||state==E_LN_RUN||state==P_START||state==P_RUN||state==N_START||state==N_RUN;
 wire[7:0]ln_op=state==P_RUN?8'h21:state==N_RUN?8'h2f:8'h28;
 wire[7:0]vector_op=state==T_RUN?8'h30:state==E_RA_RUN?8'h27:8'h2e;
 assign matrix_owner=state==QSUB||state==QRUN||state==QMSUB||state==QMRUN||state==WMSUB||state==WMRUN||(ffn_state&&state!=F_ARENA&&state!=F_RETURN);
 assign front_owner=matrix_owner||context_phase;
 assign v2_owner_req=state==S_GOWNER||state==P_OWNER||state==N_OWNER||state==E_LN_OWNER?2'd2:state==T_OWNER||state==E_RA_OWNER||state==E_RF_OWNER?2'd3:state==E_FF_OWNER&&!decision_mode||state==F_ARENA?2'd1:2'd0;
 assign v2_ext_fp_select=matrix_owner;assign v2_ext_div_select=front_owner;assign v2_ext_bind_select=matrix_owner;assign v2_ext_ps_select=matrix_owner;assign v2_ext_context_select=0;
 assign v2_resident_owner_valid=kind>=5&&state!=IDLE&&state!=FINISH;
 assign v2_resident_owner_request_id=request_id;assign v2_resident_owner_generation=generation;assign v2_resident_owner_epoch=operation_epoch;
 assign v2_resident_access_request_id=request_id;assign v2_resident_access_generation=generation;assign v2_resident_access_epoch=operation_epoch;
 assign v2_resident_inputs_ready=done_status==0&&vector_phase;
 assign v2_parent_matrix_retired=m_transport_idle;assign v2_parent_quant_retired=q_cmd_ready&&!q_done_valid;
 assign v2_h_wr_valid=state==E_H_LOAD&&in_valid&&legal_input;
 assign v2_h_wr_addr={in_row[6:0],in_group[4:0]};assign v2_h_wr_data=in_data;
 wire gather_phase=state==GATHER_RUN;
 wire[4:0]gather_issue_slot=resident_issue[9:5];
 wire[6:0]gather_issue_row=gather_issue_slot==16?7'b0:marker_mask[gather_issue_slot[3:0]]?marker_rows[gather_issue_slot[3:0]]:7'b0;
 assign v2_h_rd_valid=state==QRUN&&!resident_source_q&&resident_issue<4096&&!producer_failed||state==E_EXPORT&&resident_issue<4096||gather_phase&&resident_issue<544;
 assign v2_h_rd_addr=gather_phase?{gather_issue_row,resident_issue[4:0]}:resident_issue[11:0];
 assign v2_h_rsp_ready=state==E_ABORT?1'b1:state==QRUN&&!resident_source_q?q_in_ready:state==E_EXPORT||gather_phase?out_ready:1'b0;
 assign v2_q_wr_valid=(state==WMRUN||state==D2RUN)&&m_out_valid&&projection_identity_ok;
 assign v2_q_wr_addr={m_out_row,m_out_col[9:5]};assign v2_q_wr_data=m_out_data;
 assign v2_q_rd_valid=resident_source_phase&&resident_source_q&&resident_issue<4096&&!producer_failed;
 assign v2_q_rd_addr=resident_issue[11:0];assign v2_q_rsp_ready=state==E_ABORT?1'b1:resident_source_phase&&resident_source_q&&q_in_ready;
 wire scratch_acquire=state==E_WO_LEASE||state==E_RA_LEASE||state==E_LN_LEASE||state==E_FF_LEASE||state==E_RF_LEASE||state==P_LEASE||state==N_LEASE||state==T_LEASE||state==E_REFILL0;
 wire scratch_release=state==E_WO_POST||state==E_RA_RELEASE||state==E_LN_RELEASE||state==E_FF_POST||state==E_RF_RELEASE||state==P_RETIRE||state==N_RETIRE||state==T_RETIRE||state==E_REFILL1||state==E_ABORT;
 assign v2_scratch_lease_valid=scratch_acquire&&resident_retired;
 assign v2_scratch_release_valid=scratch_release&&resident_retired&&v2_scratch_owner_active;
 assign v2_vector_start_valid=state==E_RA_SUB||state==E_RF_SUB||state==T_START;
 assign v2_vector_start_op=state==T_START?2'd1:2'd0;
 assign v2_vector_start_request_id=request_id;assign v2_vector_start_generation=generation;assign v2_vector_start_epoch=operation_epoch;
 assign v2_vector_done_ready=state==E_RA_RUN||state==E_RF_RUN||state==T_RUN||state==E_ABORT;
 assign v2_resident_ln_start_valid=state==E_LN_SUB||state==P_START||state==N_START;
 assign v2_resident_ln_rows=128;assign v2_resident_ln_use_gamma=state==N_START;
 assign v2_resident_ln_model=MODEL_ID[63:0];assign v2_resident_ln_key=32'h464e4f52;
 assign v2_resident_ln_done_ready=state==E_LN_RUN||state==P_RUN||state==N_RUN||state==E_ABORT;
 assign v2_ln_reject_ready=ln_phase;
 assign v2_ln_cancel_valid=state==E_ABORT&&v2_ln_active&&!g_cancel_sent;
 assign v2_ln_cancel_request_id=request_id;assign v2_ln_cancel_generation=generation;assign v2_ln_cancel_epoch=operation_epoch;
 assign v2_ln_gamma_begin_valid=state==S_GBEGIN;
 assign v2_ln_gamma_model=MODEL_ID[63:0];assign v2_ln_gamma_key=32'h464e4f52;
 assign v2_ln_gamma_valid=state==S_GDATA&&model_word_valid&&model_offer_ok;
 assign v2_ln_gamma_chunk=model_word_index[4:0];assign v2_ln_gamma_data=model_word_data;
 assign v2_ln_gamma_done_ready=state==S_GDONE;
 assign v2_g_tanh_lease_valid=state==F_GQSUB&&!tanh_lease_active&&ws_g_enable;
 assign v2_g_tanh_lease_request_id=request_id;assign v2_g_tanh_lease_generation=generation;assign v2_g_tanh_lease_epoch=operation_epoch;assign v2_g_tanh_lease_phase=1;
 assign v2_g_tanh_release_valid=state==F_RELEASE&&tanh_lease_active&&g_engine_idle&&r_res_st_idle&&tanh_pending==0&&tanh_flight==0;
 assign v2_g_tanh_release_phase=1;assign v2_g_tanh_release_epoch=operation_epoch;assign v2_g_tanh_phase_debt_clear=g_engine_idle&&r_res_st_idle;
 // Single-beat arbitration; malformed idle commands still receive a terminal.
 assign invalidate_ready=rst_n&&state==IDLE&&global_idle;
 assign setup_ready=invalidate_ready&&!invalidate_valid&&!model_committed;
 assign cmd_ready=invalidate_ready&&!invalidate_valid&&!setup_valid;
 assign done_valid=state==FINISH||state==S_FINISH||state==I_FINISH;
 assign done_op=kind==0?2'd0:kind==1?2'd1:2'd2;
 assign done_request=request_id;assign done_generation=generation;assign done_epoch=epoch;
 assign parent_state=state;assign layer_head_completed=l_head_completed;
 assign in_ready=rst_n&&legal_input&&v2_h_wr_ready;
 assign producer_fail_ready=rst_n&&state==E_H_LOAD&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch;
 assign out_valid=(state==E_EXPORT||gather_phase)&&v2_h_rsp_valid;
 assign out_data=v2_h_rsp_data;assign out_row=v2_h_rsp_addr[11:5];assign out_col={6'b0,v2_h_rsp_addr[4:0],5'b0};
 assign out_slot=kind==7?resident_sink[9:5]:5'b0;
 assign tail_request=request_id;assign tail_generation=generation;assign tail_source_epoch=epoch;assign tail_expected_bytes=69632;
 assign tail_begin_valid=state==TAIL_ARM;assign tail_abort_valid=state==TAIL_ABORT;
 wire tail_identity=tail_commit_request==request_id&&tail_commit_generation==generation&&tail_commit_source_epoch==epoch;
 assign tail_commit_ready=state==TAIL_WAIT&&resident_issue==544&&resident_sink==544&&resident_retired&&v2_scratch_retired&&tail_identity;
 wire setup_phase=state>=S_CHECK&&state<=S_ROPE||state==SETUP_ERROR||state==S_HDRAIN||state==S_RDRAIN;
 wire model_phase=state==S_BIAS||state==S_GDATA||state==S_TYPE;
 wire[1:0]model_expected_kind=state==S_BIAS?2'd0:state==S_GDATA?2'd1:2'd2;
 wire model_offer_ok=model_phase&&model_word_request==request_id&&model_word_generation==generation&&model_word_kind==model_expected_kind&&{3'b0,model_word_index}==resident_issue;
 wire bias_word_valid=state==S_BIAS&&model_word_valid&&model_offer_ok;
 wire type_word_valid=state==S_TYPE&&model_word_valid&&model_offer_ok;
 assign model_word_ready=rst_n&&model_offer_ok&&(state==S_BIAS?bias_word_ready:state==S_GDATA?v2_ln_gamma_ready:type_word_ready);
 // Reject describes an unaccepted offer only; the current transaction remains usable.
 always_comb begin
  reject_valid=0;reject_port=0;reject_code=0;reject_tuple=0;
  if(model_word_valid&&!model_offer_ok)begin reject_valid=1;reject_port=2;reject_code=!model_phase?4:model_word_request!=request_id||model_word_generation!=generation?2:4;reject_tuple={8'h0d,5'd31,3'd0,check_detail(reject_code,{6'b0,model_word_index},26,0,0,32'(model_word_kind))};end
  else if(in_valid&&!legal_input)begin reject_valid=1;reject_port=1;reject_code=state!=E_H_LOAD?4:in_request!=request_id||in_generation!=generation||in_epoch!=epoch?2:4;reject_tuple={8'h20,error_global,3'd0,check_detail(reject_code,16'(inputs_accepted),26,0,0,{16'b0,in_row,in_group})};end
  else if(producer_fail_valid&&!(state==E_H_LOAD&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch))begin reject_valid=1;reject_port=3;reject_code=2;reject_tuple={8'h20,error_global,3'd0,check_detail(2,0,26,0,0,0)};end
  else if(tail_commit_valid&&!(state==TAIL_WAIT&&tail_identity))begin reject_valid=1;reject_port=4;reject_code=tail_identity?4:2;reject_tuple={8'h37,5'd30,3'd0,check_detail(reject_code,0,26,0,0,0)};end
 end
 // Catalog ownership is encoded solely by state, including four fault origins.
 wire runtime_catalog=state>=C_A0_AR&&state<=C_F1_R||state>=C_A0_DRAIN&&state<=C_F1_DRAIN;
 wire catalog_owns=runtime_catalog||state==S_HAR||state==S_HR||state==S_RAR||state==S_RR||state==S_HDRAIN||state==S_RDRAIN;
 wire catalog_ffn=state>=C_F0_AR&&state<=C_F1_R||state==C_F0_DRAIN||state==C_F1_DRAIN;
 wire catalog_slot=state==C_A1_AR||state==C_A1_R||state==C_F1_AR||state==C_F1_R||state==C_A1_DRAIN||state==C_F1_DRAIN;
 logic cat_req_valid,cat_req_ready,cat_rsp_valid,cat_rsp_ready,cat_fault,cat_idle;
 logic[6:0]cat_word;logic[511:0]cat_data;logic[2:0]cat_rid;logic[1:0]cat_rresp;logic cat_rlast;
 logic cat_arvalid,cat_rready;logic[63:0]cat_araddr;logic[2:0]cat_arid,cat_arsize;logic[7:0]cat_arlen;logic[1:0]cat_arburst;
 assign cat_word=state==S_HAR||state==S_HR||state==S_HDRAIN?resident_issue[6:0]:state==S_RAR||state==S_RR||state==S_RDRAIN?7'(4+resident_issue):7'(4+4*layer_index+2*catalog_ffn+catalog_slot);
 assign cat_req_valid=(state==S_HAR||state==S_RAR||state==C_A0_AR||state==C_A1_AR||state==C_F0_AR||state==C_F1_AR)&&m_transport_idle&&q_cmd_ready&&!q_done_valid&&cat_idle;
 assign cat_rsp_ready=state==S_HR||state==S_RR||state==C_A0_R||state==C_A1_R||state==C_F0_R||state==C_F1_R;
 laya_m007_catalog_reader_v1 catalog_reader(.clk,.rst_n,.req_valid(cat_req_valid),.req_ready(cat_req_ready),.req_word(cat_word),.catalog_base,.rsp_valid(cat_rsp_valid),.rsp_ready(cat_rsp_ready),.rsp_data(cat_data),.fault(cat_fault),.rsp_rid(cat_rid),.rsp_rresp(cat_rresp),.rsp_rlast(cat_rlast),.idle(cat_idle),.arvalid(cat_arvalid),.arready(arready[0]&&catalog_owns),.araddr(cat_araddr),.arid(cat_arid),.arlen(cat_arlen),.arsize(cat_arsize),.arburst(cat_arburst),.rvalid(rvalid[0]&&catalog_owns),.rready(cat_rready),.rdata(rdata[0]),.rid(rid[0]),.rresp(rresp[0]),.rlast(rlast[0]));
 assign arvalid=catalog_owns?{3'b0,cat_arvalid}:m_arvalid;
 assign araddr=catalog_owns?{192'b0,cat_araddr}:m_araddr;
 assign arid=catalog_owns?{9'b0,cat_arid}:m_arid;assign arlen=catalog_owns?{24'b0,cat_arlen}:m_arlen;
 assign rready=catalog_owns?{3'b0,cat_rready}:m_rready;
 logic[7:0]record_code,record_field;logic[2:0]record_port;logic[31:0]record_observed;
 logic[7:0]header_code,header_field;logic[15:0]header_index;logic[31:0]header_observed;
 logic[4:0]record_layer;logic record_pair,record_slot;
 logic[64:0]record_end,aperture_end,setup_end;logic[63:0]record_base,record_span;
 always_comb begin
  record_layer=state==S_RR?5'(resident_issue>>2):layer_index;
  record_pair=state==S_RR?resident_issue[1]:catalog_ffn;record_slot=state==S_RR?resident_issue[0]:catalog_slot;
  record_code=0;record_field=0;record_port=0;record_observed=0;record_end=0;aperture_end=0;record_base=0;record_span=0;
  for(int p=3;p>=0;p--)begin
   record_base=cat_data[128*p+:64];record_span=cat_data[128*p+64+:64];
   record_end={1'b0,record_base}+{1'b0,record_span};aperture_end={1'b0,HBM_PORT_BASE[p]}+{1'b0,HBM_PORT_SPAN[p]};
   if(record_base[11:0]!=0||record_end[64]||record_span<required_bytes(record_layer,record_pair,record_slot))begin record_code=3;record_field=record_base[11:0]!=0?15:16;record_port=3'(p);record_observed=32'(record_base[11:0]!=0?record_base:record_span);end
   else if(HBM_PORT_SPAN[p]==0||aperture_end[64]||record_base<HBM_PORT_BASE[p]||record_end>aperture_end)begin record_code=3;record_field=17;record_port=3'(p);record_observed=32'(record_base);end
   else if(p==0&&{1'b0,record_base}<{1'b0,catalog_base}+65'd8192&&record_end>{1'b0,catalog_base})begin record_code=3;record_field=15;record_port=0;record_observed=32'(record_base);end
  end
 end
 // Compare SHA bytes in ascending memory address, never as a little-endian integer.
 logic[7:0]header_expected;integer byte_address,digest_index;
 always_comb begin
  header_code=0;header_field=0;header_index=0;header_observed=0;header_expected=0;byte_address=0;digest_index=0;
  for(int j=63;j>=0;j--)begin
   byte_address=64*int'(resident_issue)+j;header_expected=0;digest_index=0;
   case(byte_address)
    0:header_expected=8'h4c;1:header_expected=8'h41;2:header_expected=8'h59;3:header_expected=8'h41;4:header_expected=8'h43;5:header_expected=8'h32;6:header_expected=8'h35;7:header_expected=0;
    8:header_expected=1;9:header_expected=0;10:header_expected=0;11:header_expected=1;12:header_expected=120;13:header_expected=0;14:header_expected=64;15:header_expected=0;
    default:begin
     if(byte_address>=16&&byte_address<48)header_expected=MODEL_SHA256[255-8*(byte_address-16)-:8];
     else if(byte_address<80)header_expected=GRAPH_SHA256[255-8*(byte_address-48)-:8];
     else if(byte_address<112)header_expected=NUMERIC_SHA256[255-8*(byte_address-80)-:8];
     else if(byte_address<144)header_expected=LAYOUT_SHA256[255-8*(byte_address-112)-:8];
     else if(byte_address<176)header_expected=PACKAGE_BUILD_SHA256[255-8*(byte_address-144)-:8];
     else if(byte_address<208)header_expected=base[0][3-((byte_address-176)/8)][63-8*((byte_address-176)%8)-:8];
     else if(byte_address<216)header_expected=span[0][0][8*(byte_address-208)+:8];
     else if(byte_address<224)header_expected=64'd7936>>(8*(byte_address-216));
    end
   endcase
   if(cat_data[8*j+:8]!=header_expected)begin
    header_code=byte_address>=224?16:byte_address>=216?1:byte_address>=208?5:2;
    header_field=byte_address<8?1:byte_address<10?2:byte_address<12?3:byte_address<14?4:byte_address<16?5:byte_address<48?6:byte_address<80?7:byte_address<112?8:byte_address<144?9:byte_address<176?10:byte_address<208?11:byte_address<216?12:byte_address<224?13:14;
    header_index=16'(byte_address);header_observed={24'b0,cat_data[8*j+:8]};
   end
  end
 end
 wire[63:0]crc_next=crc_word(tensor_id,cat_data);
 logic[7:0]begin_code,begin_field;logic[15:0]begin_index;logic[31:0]begin_observed;integer marker_count;
 always_comb begin
  begin_code=0;begin_field=0;begin_index=0;begin_observed=0;marker_count=0;
  for(int j=0;j<16;j++)marker_count+=int'(cmd_marker_mask[j]);
  if(cmd_kind==7)begin
   if(cmd_qtype==3)begin begin_code=1;begin_field=21;begin_observed=32'(cmd_qtype);end
   else if(cmd_candidate_count==0||cmd_candidate_count>16||int'(cmd_candidate_count)!=marker_count||cmd_qtype==2&&cmd_candidate_count!=2)begin begin_code=4;begin_field=24;begin_observed=32'(cmd_candidate_count);end
   else for(int j=15;j>=0;j--)if(cmd_marker_mask[j]?(cmd_marker_rows[j][31]||cmd_marker_rows[j]>127||!cmd_mask[cmd_marker_rows[j][6:0]]):cmd_marker_rows[j]!=0)begin begin_code=3;begin_field=22;begin_index=16'(j);begin_observed=cmd_marker_rows[j];end
  end else begin
   if(cmd_qtype!=0||cmd_marker_mask!=0||cmd_candidate_count!=0)begin begin_code=16;begin_field=21;begin_observed=32'(cmd_qtype);end
   for(int j=15;j>=0;j--)if(cmd_marker_rows[j]!=0)begin begin_code=16;begin_field=22;begin_index=16'(j);begin_observed=cmd_marker_rows[j];end
  end
  if(cmd_epoch>32'hfffffe00)begin begin_code=3;begin_field=26;begin_observed=cmd_epoch;end
  if(cmd_kind<5||cmd_kind>7)begin begin_code=1;begin_field=19;begin_observed=32'(cmd_kind);end
  else if(cmd_kind==5&&cmd_layer>=28||cmd_kind==6&&cmd_layer>=2||cmd_kind==7&&cmd_layer!=0)begin begin_code=3;begin_field=20;begin_observed=32'(cmd_layer);end
  if(!model_committed)begin begin_code=12;begin_field=0;begin_observed=0;end
  if(cmd_model_id!=MODEL_ID||cmd_numeric_id!=NUMERIC_ID||cmd_table_key!=TABLE_KEY||cmd_graph_id!=GRAPH_ID||cmd_layout_id!=LAYOUT_ID||cmd_build_id!=BUILD_ID)begin begin_code=2;begin_field=cmd_build_id!=BUILD_ID?18:26;begin_observed=cmd_build_id[31:0];end
 end
 // Counters change only for real bank commits, requests or public output accepts.
 always_ff@(posedge clk)begin
  if(!rst_n)begin resident_issue<=0;resident_sink<=0;end
  else if(setup_valid&&setup_ready||cmd_valid&&cmd_ready||state==S_CHECK||state==S_HR&&cat_rsp_valid&&cat_rsp_ready&&!cat_fault&&resident_issue==3||state==S_RR&&cat_rsp_valid&&cat_rsp_ready&&!cat_fault&&resident_issue==119||state==S_BIAS&&model_word_valid&&model_word_ready&&resident_issue==575||state==S_GBEGIN&&v2_ln_gamma_begin_valid&&v2_ln_gamma_begin_ready||state==S_GDONE&&v2_ln_gamma_done_valid&&v2_ln_gamma_done_ready||state==E_H_READY||state==QSUB&&q_cmd_valid&&q_cmd_ready||state==F_NQSUB&&q_cmd_valid&&q_cmd_ready||state==WMSUB&&m_cmd_valid&&m_cmd_ready||state==D2SUB&&m_cmd_valid&&m_cmd_ready||state==E_RF_RELEASE&&v2_scratch_release_valid&&v2_scratch_release_ready||state==GATHER_START)begin resident_issue<=0;resident_sink<=0;end
  else begin
   if(cat_rsp_valid&&cat_rsp_ready&&!cat_fault&&(state==S_HR||state==S_RR)||model_word_valid&&model_word_ready)resident_issue<=resident_issue+1'b1;
   if(v2_h_rd_valid&&v2_h_rd_ready||v2_q_rd_valid&&v2_q_rd_ready)resident_issue<=resident_issue+1'b1;
   if(v2_q_wr_commit||out_valid&&out_ready)resident_sink<=resident_sink+1'b1;
  end
 end
 logic c_rd_valid,c_rd_ready,c_rsp_valid,c_rsp_ready,c_out_valid,c_out_ready,c_idle,c_complete,c_fault,c_start_ready;
 logic[31:0]c_rd_generation,c_rd_tag,c_rsp_tag;logic[3:0]c_rd_head;logic[6:0]c_rd_query;logic c_rd_half;
 logic[31:0][31:0]c_rsp_data,c_out_data;logic[7:0]c_out_row,c_out_group;logic[12:0]c_accepted,c_consumed;
 wire[79:0]matrix_detail={16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),16'b0};
 wire[79:0]quant_detail={16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),16'b0};
 wire[79:0]ln_detail={v2_ln_error_class,v2_ln_error_row,v2_ln_error_check,v2_ln_error_level,v2_ln_error_node,v2_ln_protocol_code,v2_ln_protocol_location,v2_ln_error_stage,36'b0};
 wire[79:0]vector_detail={16'(v2_vector_done_error_row),16'(v2_vector_done_error_column),8'(v2_vector_done_error_column[4:0]),v2_vector_done_status,8'b0};
 wire[7:0]bus_code=cat_rid!=7?8'd7:cat_rresp!=0?8'd8:8'd9;
 wire[79:0]bus_detail=check_detail(bus_code,{9'b0,cat_word},0,0,0,{26'b0,cat_rid,cat_rresp,cat_rlast});
 // Original Attention tuple is stage8 + a..e16 + f8. High bytes must be zero.
 wire attention_range_bad=|{l_error_tuple[87:80],l_error_tuple[71:64],l_error_tuple[55:48],l_error_tuple[39:32],l_error_tuple[23:16]};
 logic[7:0]attention_bad_field;logic[15:0]attention_bad_value;
 always_comb begin
  attention_bad_field=0;attention_bad_value=0;
  if(l_error_tuple[23:16]!=0)begin attention_bad_field=5;attention_bad_value=l_error_tuple[23:8];end
  if(l_error_tuple[39:32]!=0)begin attention_bad_field=4;attention_bad_value=l_error_tuple[39:24];end
  if(l_error_tuple[55:48]!=0)begin attention_bad_field=3;attention_bad_value=l_error_tuple[55:40];end
  if(l_error_tuple[71:64]!=0)begin attention_bad_field=2;attention_bad_value=l_error_tuple[71:56];end
  if(l_error_tuple[87:80]!=0)begin attention_bad_field=1;attention_bad_value=l_error_tuple[87:72];end
 end
 wire[79:0]attention_detail={l_error_tuple[95:88],l_error_tuple[79:72],l_error_tuple[63:56],l_error_tuple[47:40],l_error_tuple[31:24],l_error_tuple[15:8],l_error_tuple[7:0],24'b0};
 always_ff@(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;request_id<=0;generation<=0;epoch<=0;kind<=0;layer_index<=0;mask<=0;tensor_id<=0;base<=0;span<=0;
   inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;
   model_committed<=0;catalog_base<=0;active_epoch_offset<=0;qtype<=0;marker_rows<=0;marker_mask<=0;
  end else begin
   if(state!=IDLE&&!done_valid)elapsed_cycles<=elapsed_cycles+1;
   if(invalidate_valid&&invalidate_ready)begin
    request_id<=invalidate_request;generation<=invalidate_generation;epoch<=0;kind<=1;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;state<=I_FINISH;
    if(invalidate_build_id==BUILD_ID)model_committed<=0;
    else begin done_status<=4;error_domain<=1;source_status<=2;error_tuple<={8'h02,5'd31,3'd0,check_detail(2,0,18,0,0,invalidate_build_id[31:0])};end
   end else if(setup_valid&&setup_ready)begin
    request_id<=setup_request;generation<=setup_generation;epoch<=0;kind<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;model_committed<=0;
    catalog_base<=setup_catalog_base;base[0]<=setup_records_sha256;span[0][0]<=setup_records_crc;tensor_id<=0;state<=S_CHECK;
    if(setup_build_id!=BUILD_ID||setup_table_key!=TABLE_KEY||setup_model_sha256!=MODEL_SHA256||setup_graph_sha256!=GRAPH_SHA256||setup_numeric_sha256!=NUMERIC_SHA256||setup_layout_sha256!=LAYOUT_SHA256||setup_package_build_sha256!=PACKAGE_BUILD_SHA256)begin
     state<=S_FINISH;done_status<=4;error_domain<=1;source_status<=2;
     error_tuple<={8'h01,5'd31,3'd0,check_detail(2,0,setup_build_id!=BUILD_ID?8'd18:setup_model_sha256!=MODEL_SHA256?8'd6:setup_graph_sha256!=GRAPH_SHA256?8'd7:setup_numeric_sha256!=NUMERIC_SHA256?8'd8:setup_layout_sha256!=LAYOUT_SHA256?8'd9:setup_package_build_sha256!=PACKAGE_BUILD_SHA256?8'd10:8'd26,0,0,0)};
    end else if(setup_catalog_span!=8192||setup_catalog_base[11:0]!=0||({1'b0,setup_catalog_base}+65'd8192)>=65'h10000000000000000)begin
     state<=S_FINISH;done_status<=5;error_domain<=1;source_status<=3;error_tuple<={8'h01,5'd31,3'd0,check_detail(3,0,setup_catalog_span!=8192?8'd16:8'd15,0,0,setup_catalog_span[31:0])};
    end
   end else if(cmd_valid&&cmd_ready)begin
    request_id<=cmd_request;generation<=cmd_generation;epoch<=cmd_epoch;kind<=cmd_kind>=5?cmd_kind:3'd5;layer_index<=cmd_kind==6?cmd_layer+5'd28:cmd_layer;mask<=cmd_mask;
    inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;active_epoch_offset<=0;
    qtype<=cmd_qtype;marker_mask<=cmd_marker_mask;for(int j=0;j<16;j++)marker_rows[j]<=cmd_marker_rows[j][6:0];
    if(begin_code!=0)begin state<=FINISH;done_status<=begin_code==12?5:4;error_domain<=1;source_status<=begin_code;error_tuple<={8'h03,5'd31,3'd0,check_detail(begin_code,begin_index,begin_field,0,0,begin_observed)};end
    else state<=cmd_kind==7?TAIL_ARM:E_H_LOAD;
   end
   case(state)
    S_CHECK:begin
     if(ADDRESS_PROFILE==0||ADDRESS_PROFILE==3||PLATFORM_MANIFEST_SHA256==0)fail(8'h01,1,5,11,0,check_detail(11,0,17,0,0,32'(ADDRESS_PROFILE)),S_FINISH);
     else if(HBM_PORT_SPAN[0]==0||({1'b0,HBM_PORT_BASE[0]}+{1'b0,HBM_PORT_SPAN[0]})>=65'h10000000000000000||catalog_base<HBM_PORT_BASE[0]||({1'b0,catalog_base}+65'd8192)>({1'b0,HBM_PORT_BASE[0]}+{1'b0,HBM_PORT_SPAN[0]}))fail(8'h01,1,5,3,0,check_detail(3,0,17,0,0,catalog_base[31:0]),S_FINISH);
     else state<=S_HAR;
    end
    S_HAR,S_RAR,C_A0_AR,C_A1_AR,C_F0_AR,C_F1_AR:if(cat_req_valid&&cat_req_ready)state<=state+1'b1;
    S_HR:if(cat_rsp_valid&&cat_rsp_ready)begin
     if(cat_fault)fail(8'h04,1,2,bus_code,0,bus_detail,S_HDRAIN);
     else if(header_code!=0)fail(8'h04,1,5,header_code,0,check_detail(header_code,header_index,header_field,0,0,header_observed),SETUP_ERROR);
     else state<=resident_issue==3?S_RAR:S_HAR;
    end
    S_RR:if(cat_rsp_valid&&cat_rsp_ready)begin
     if(cat_fault)fail(8'h05,1,2,bus_code,0,bus_detail,S_RDRAIN);
     else if(record_code!=0)fail(8'h05,1,5,record_code,0,check_detail(record_code,16'(resident_issue),record_field,record_port,0,record_observed),SETUP_ERROR);
     else begin
      tensor_id<=crc_next;
      if(resident_issue==119)begin
       if(crc_next!=span[0][0])fail(8'h06,1,5,5,0,check_detail(5,119,12,0,0,crc_next[31:0]),SETUP_ERROR);
       else state<=S_BIAS;
      end else state<=S_RAR;
     end
    end
    S_HDRAIN,S_RDRAIN:if(cat_idle)state<=SETUP_ERROR;
    S_BIAS:if(model_word_valid&&model_word_ready)begin
     if(model_bad[5])fail(8'h07,1,1,6,0,check_detail(6,16'(model_word_index),29,0,model_bad[4:0],model_word_data[model_bad[4:0]]),SETUP_ERROR);
     else if(resident_issue==575)state<=S_GOWNER;
    end
    S_GOWNER:if(v2_ln_enable)state<=S_GBEGIN;
    S_GBEGIN:if(v2_ln_gamma_begin_valid&&v2_ln_gamma_begin_ready)state<=S_GDATA;
    S_GDATA:begin
     if(model_word_valid&&model_word_ready&&model_bad[5]&&done_status==0)begin
      done_status<=1;source_status<=6;error_domain<=1;error_tuple<={8'h08,5'd31,3'd0,check_detail(6,16'(model_word_index),29,0,model_bad[4:0],model_word_data[model_bad[4:0]])};
     end
     if(v2_ln_gamma_done_valid||model_word_valid&&model_word_ready&&resident_issue==31)state<=S_GDONE;
    end
    S_GDONE:if(v2_ln_gamma_done_valid&&v2_ln_gamma_done_ready)begin
     if(done_status!=0)state<=SETUP_ERROR;
     else if(v2_ln_gamma_done_error||!v2_ln_gamma_loaded)fail(8'h08,1,1,1,0,check_detail(6,31,29,0,0,32'(v2_ln_gamma_done_error)),SETUP_ERROR);
     else state<=S_TYPE;
    end
    S_TYPE:if(model_word_valid&&model_word_ready)begin
     if(!type_word_commit)fail(8'h09,7,2,10,0,check_detail(10,16'(model_word_index),0,0,0,0),SETUP_ERROR);
     else if(model_bad[5])fail(8'h09,1,1,6,0,check_detail(6,16'(model_word_index),29,0,model_bad[4:0],model_word_data[model_bad[4:0]]),SETUP_ERROR);
     else if(resident_issue==95)state<=S_ROPE;
    end
    S_ROPE:if(ws_a_enable&&type_bank_idle&&v2_shared_resources_idle)begin
     if(coeff_bound_valid&&coeff_bound_model_id==MODEL_ID&&coeff_bound_numeric_id==NUMERIC_ID&&coeff_bound_table_key==TABLE_KEY&&coeff_family_complete==3)state<=S_FINISH;
     else fail(8'h0a,1,5,12,0,check_detail(12,0,26,0,0,32'(coeff_family_complete)),S_FINISH);
    end
    SETUP_ERROR:if(cat_idle&&!v2_ln_gamma_done_valid&&v2_ln_provider_idle&&type_bank_idle&&ws_a_enable&&v2_shared_resources_idle)state<=S_FINISH;
    TAIL_ARM:if(tail_begin_valid&&tail_begin_ready)state<=E_H_LOAD;
    E_H_LOAD:begin
     if(h_load_fire)begin
      inputs_accepted<=inputs_accepted+1'b1;
      if(!v2_h_wr_commit)fail(8'h20,7,2,10,0,check_detail(10,16'(inputs_accepted),0,0,0,0),E_ABORT);
      else if(input_bad[5])fail(8'h20,7,1,6,6,{16'(in_row),16'(32*in_group+input_bad[4:0]),8'(input_bad[4:0]),32'd6,8'b0},E_ABORT);
      else if(inputs_accepted==4095)state<=E_H_READY;
     end
     if(producer_fail_fire)begin producer_failed<=1;fail(8'h20,2,3,producer_fail_code,7,producer_fail_detail,E_ABORT);end
    end
    E_H_READY:if(h_load_success_valid&&resident_retired)begin
     active_epoch_offset<=layer_offset(layer_index,0);
     if(layer_index==0)begin active_epoch_offset<=layer_offset(layer_index,1);state<=C_A0_AR;end
     else state<=P_OWNER;
    end
    P_OWNER:if(v2_ln_enable)state<=P_LEASE;
    N_OWNER:if(v2_ln_enable)state<=N_LEASE;
    T_OWNER:if(v2_vector_enable)state<=T_LEASE;
    P_LEASE,N_LEASE,T_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=state+1'b1;
    P_START,N_START:if(v2_resident_ln_start_valid&&v2_resident_ln_start_ready)state<=state+1'b1;
    T_START:if(v2_vector_start_valid&&v2_vector_start_ready)state<=T_RUN;
    P_RETIRE:if(v2_scratch_release_valid&&v2_scratch_release_ready)begin active_epoch_offset<=layer_offset(layer_index,1);state<=C_A0_AR;end
    N_RETIRE:if(v2_scratch_release_valid&&v2_scratch_release_ready)begin active_epoch_offset<=449;state<=T_OWNER;end
    T_RETIRE:if(v2_scratch_release_valid&&v2_scratch_release_ready)begin layer_index<=28;active_epoch_offset<=464;state<=P_OWNER;end
    C_A0_R,C_A1_R,C_F0_R,C_F1_R:if(cat_rsp_valid&&cat_rsp_ready)begin
     if(cat_fault)fail(catalog_ffn?8'h0c:8'h0b,1,2,bus_code,0,bus_detail,state==C_A0_R?C_A0_DRAIN:state==C_A1_R?C_A1_DRAIN:state==C_F0_R?C_F0_DRAIN:C_F1_DRAIN);
     else if(record_code!=0)fail(catalog_ffn?8'h0c:8'h0b,1,5,record_code,0,check_detail(record_code,{9'b0,cat_word},record_field,record_port,0,record_observed),E_ABORT);
     else begin
      tensor_id[catalog_slot]<=graph_tensor(layer_index,catalog_ffn,catalog_slot);
      for(int p=0;p<4;p++)begin base[catalog_slot][p]<=cat_data[128*p+:64];span[catalog_slot][p]<=cat_data[128*p+64+:64];end
      case(state)C_A0_R:state<=C_A1_AR;C_A1_R:state<=layer_index==0?PREP:E_REFILL0;C_F0_R:state<=C_F1_AR;default:begin active_epoch_offset<=layer_offset(layer_index,2);state<=E_RA_LEASE;end endcase
     end
    end
    C_A0_DRAIN,C_A1_DRAIN,C_F0_DRAIN,C_F1_DRAIN:if(cat_idle)state<=E_ABORT;
    E_REFILL0:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=QSUB;
    E_REFILL1:if(v2_scratch_release_valid&&v2_scratch_release_ready)state<=PREP;
    PREP:if(l_prepare_valid&&l_prepare_ready)state<=layer_index==0?QSUB:QMSUB;
    QSUB:if(q_cmd_valid&&q_cmd_ready)begin state<=QRUN;inputs_accepted<=0;end
    QRUN:begin
     if(internal_source_fire)inputs_accepted<=inputs_accepted+1'b1;
     if(q_done_valid&&q_done_ready)begin
      if(q_status!=0)fail(8'h22,3,matrix_status_map(q_status),8'(q_status),3,quant_detail,ACANCEL);
      else state<=layer_index==0?QMSUB:E_REFILL1;
     end
    end
    QMSUB:if(m_cmd_valid&&m_cmd_ready)state<=QMRUN;
    QMRUN:if(m_done_valid&&m_done_ready)begin
     if(m_status!=0)fail(8'h23,4,matrix_status_map(m_status),8'(m_status),2,matrix_detail,PCANCEL);
     else state<=LSTART;
    end
    ACANCEL:if(m_fill_cancel_valid&&m_fill_cancel_ready)state<=ACWAIT;
    ACWAIT:if(m_fill_cancel_rsp_valid&&m_fill_cancel_rsp_ready)state<=layer_index==0?PCANCEL:E_ABORT;
    PCANCEL:if(l_prepare_cancel_valid&&l_prepare_cancel_ready)state<=PCWAIT;
    PCWAIT:if(l_prepare_cancel_rsp_valid&&l_prepare_cancel_rsp_ready)state<=DISCWAIT;
    LSTART:if(l_start_valid&&l_start_ready)state<=LRUN;
    LRUN:if(l_done_valid&&l_done_ready)begin
     if(l_done_status!=0)begin
      if(attention_range_bad)fail(8'h24,5,2,17,0,check_detail(17,0,attention_bad_field,0,0,{16'b0,attention_bad_value}),DISCWAIT);
      else fail(8'h24,5,layer_status_map(l_done_status),l_done_status,4,attention_detail,DISCWAIT);
     end else state<=CSUB;
    end
    CSUB:if(q_cmd_valid&&q_cmd_ready&&c_start_ready)state<=CRUN;
    CRUN:if(q_done_valid&&q_done_ready)begin
     state<=CDRAIN;
     if(q_status!=0||c_fault)begin context_failed<=1;fail(8'h25,3,q_status==0?8'd2:matrix_status_map(q_status),8'(q_status),3,quant_detail,CDRAIN);end
    end
    CDRAIN:if(c_idle)begin if(context_failed)state<=l_layer_idle?E_ABORT:DISCARD;else if(c_complete&&l_layer_idle)state<=E_WO_LEASE;end
    DISCARD:if(l_result_discard_valid&&l_result_discard_ready)state<=DISCWAIT;
    DISCWAIT:if(l_layer_idle)state<=E_ABORT;
    E_WO_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=WMSUB;
    WMSUB:if(m_cmd_valid&&m_cmd_ready)state<=WMRUN;
    WMRUN:if(m_done_valid&&m_done_ready)begin
     if(m_status!=0)fail(ffn_mode?8'h2d:8'h26,4,matrix_status_map(m_status),8'(m_status),2,matrix_detail,E_ABORT);
     else state<=ffn_mode?F_RETURN:E_WO_POST;
    end
    E_WO_POST:if(resident_sink==4096&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=C_F0_AR;
    E_RA_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_RA_OWNER;
    E_RA_OWNER:if(v2_vector_enable)state<=E_RA_SUB;
    E_RA_SUB:if(v2_vector_start_valid&&v2_vector_start_ready)state<=E_RA_RUN;
    E_RA_RELEASE:if(v2_scratch_release_valid&&v2_scratch_release_ready)begin active_epoch_offset<=layer_offset(layer_index,3);state<=E_LN_LEASE;end
    E_LN_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_LN_OWNER;
    E_LN_OWNER:if(v2_ln_enable)state<=E_LN_SUB;
    E_LN_SUB:if(v2_resident_ln_start_valid&&v2_resident_ln_start_ready)state<=E_LN_RUN;
    E_LN_RELEASE:if(v2_scratch_release_valid&&v2_scratch_release_ready)begin active_epoch_offset<=layer_offset(layer_index,4);state<=E_FF_LEASE;end
    E_FF_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_FF_OWNER;
    E_FF_OWNER:if(decision_mode?ws_a_enable:ws_g_enable)state<=F_NQSUB;
    F_ARENA:if(ws_g_enable)state<=F_NQSUB;
    F_NQSUB:if(q_cmd_valid&&q_cmd_ready)begin state<=F_NQRUN;inputs_accepted<=0;end
    F_NQRUN:begin
     if(internal_source_fire)inputs_accepted<=inputs_accepted+1'b1;
     if(q_done_valid&&q_done_ready)begin
      if(q_status!=0)fail(8'h29,3,matrix_status_map(q_status),8'(q_status),3,quant_detail,F_RELEASE);
      else state<=decision_mode?D1SUB:F_WISUB;
     end
    end
    F_WISUB:if(m_cmd_valid&&m_cmd_ready)state<=F_GQSUB;
    F_GQSUB:if(g_cmd_valid&&g_cmd_ready&&q_cmd_valid&&q_cmd_ready)state<=F_RUN;
    F_RUN:begin
     if(pack_fault||g_protocol_fault||m_done_valid&&m_status!=0)state<=F_ABORT;
     else if(m_done_valid&&m_status==0&&g_done_valid)begin
      if(g_done_status!=0||g_done_cancelled)state<=F_ABORT;
      else if(pack_seq==41984&&!pack_full&&g_all_covered&&q_quant_accepted==10496)state<=F_CLOSE;
     end
    end
    F_CLOSE:if(ffn_close_fire)state<=F_QDRAIN;
    F_QDRAIN:if(q_done_valid&&q_done_ready)begin
     if(q_status!=0)fail(decision_mode?8'h33:8'h2c,3,matrix_status_map(q_status),8'(q_status),3,quant_detail,F_RELEASE);
     else state<=F_RELEASE;
    end
    F_ABORT:begin
     if(m_done_valid&&m_done_ready&&m_status!=0)begin
      done_status<=matrix_status_map(m_status);source_status<=8'(m_status);error_domain<=4;error_tuple<={decision_mode?8'h31:8'h2a,error_global,3'd2,matrix_detail};
     end else if(!decision_mode&&g_done_valid&&g_done_ready&&error_domain!=4&&(done_status==0||g_done_status!=0))begin
      done_status<=g_done_status==6?8'd1:8'd2;source_status<=g_done_status[7:0];error_domain<=6;error_tuple<={8'h2b,error_global,3'd5,16'(g_done_error_rank),16'(g_done_error_row),16'(g_done_error_column),g_done_status};
     end else if((pack_fault||g_protocol_fault)&&done_status==0)begin done_status<=2;source_status<=8;error_domain<=7;error_tuple<={8'h38,error_global,3'd0,check_detail(13,pack_seq,30,0,0,0)};end
     if(decision_mode&&m_transport_idle&&q_cmd_ready&&!q_done_valid)state<=F_RELEASE;
     else if(!decision_mode&&m_transport_idle&&!g_active&&!g_done_valid&&q_cmd_ready&&(g_needs_discard||g_engine_idle))state<=F_DISCARD;
    end
    F_DISCARD:if(!g_needs_discard||g_discard_valid&&g_discard_ready)state<=F_RELEASE;
    F_RELEASE:if((decision_mode||g_engine_idle)&&!tanh_lease_active&&r_res_st_idle&&!r_res_fp_lease_active&&!r_res_div_lease_active&&m_transport_idle&&q_cmd_ready&&!q_done_valid)state<=done_status==0?(decision_mode?D2SUB:WMSUB):F_RETURN;
    F_RETURN:if(ws_a_enable)state<=done_status==0?E_FF_POST:E_ABORT;
    D1SUB:if(q_cmd_valid&&q_cmd_ready)state<=D1RUN;
    D1RUN:if(m_cmd_valid&&m_cmd_ready)state<=D1DRAIN;
    D1DRAIN:begin
     if(m_out_valid&&!fc1_finite)fail(8'h32,7,1,6,6,{16'(m_out_row),m_out_col,8'b0,32'd6,8'b0},F_ABORT);
     else if(m_done_valid&&ffn_close_fire)begin
      if(m_status!=0)fail(8'h31,4,matrix_status_map(m_status),8'(m_status),2,matrix_detail,F_ABORT);
      else state<=F_QDRAIN;
     end
    end
    D2SUB:if(m_cmd_valid&&m_cmd_ready)state<=D2RUN;
    D2RUN:if(m_done_valid&&m_done_ready)begin
     if(m_status!=0)fail(8'h34,4,matrix_status_map(m_status),8'(m_status),2,matrix_detail,E_ABORT);
     else state<=D2DRAIN;
    end
    D2DRAIN:if(m_transport_idle&&q_cmd_ready&&!q_done_valid)state<=F_RETURN;
    E_FF_POST:if(resident_sink==4096&&v2_scratch_release_valid&&v2_scratch_release_ready)begin active_epoch_offset<=layer_offset(layer_index,5);state<=E_RF_LEASE;end
    E_RF_LEASE:if(v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_RF_OWNER;
    E_RF_OWNER:if(v2_vector_enable)state<=E_RF_SUB;
    E_RF_SUB:if(v2_vector_start_valid&&v2_vector_start_ready)state<=E_RF_RUN;
    E_RF_RELEASE:if(v2_scratch_release_valid&&v2_scratch_release_ready)state<=LAYER_NEXT;
    LAYER_NEXT:if(resident_retired&&v2_scratch_retired&&ws_a_enable)begin
     if(kind!=7)begin active_epoch_offset<=layer_offset(layer_index,6);state<=E_EXPORT;end
     else if(layer_index==27)begin active_epoch_offset<=448;state<=N_OWNER;end
     else if(layer_index==29)begin active_epoch_offset<=496;state<=GATHER_START;end
     else begin layer_index<=layer_index+1'b1;active_epoch_offset<=layer_offset(layer_index+1'b1,0);state<=P_OWNER;end
    end
    E_EXPORT:if(out_valid&&out_ready&&resident_sink==4095)state<=E_EXPORT_DRAIN;
    E_EXPORT_DRAIN:if(resident_issue==4096&&resident_sink==4096&&resident_retired&&v2_scratch_retired)state<=E_FINAL_A;
    GATHER_START:if(resident_retired&&v2_scratch_retired)state<=GATHER_RUN;
    GATHER_RUN:if(out_valid&&out_ready&&resident_sink==543)state<=GATHER_DRAIN;
    GATHER_DRAIN:if(resident_issue==544&&resident_sink==544&&resident_retired&&v2_scratch_retired)state<=TAIL_WAIT;
    TAIL_WAIT:if(tail_commit_valid&&tail_commit_ready)begin
     if(tail_commit_bytes!=69632||tail_commit_status!=0)fail(8'h37,7,2,tail_commit_bytes!=69632?8'd14:8'd15,0,check_detail(tail_commit_bytes!=69632?8'd14:8'd15,0,tail_commit_bytes!=69632?8'd25:8'd0,0,0,tail_commit_bytes!=69632?tail_commit_bytes:{24'b0,tail_commit_status}),tail_owner_idle?FINISH:TAIL_ABORT);
     else state<=ERROR_CLEAN;
    end
    ERROR_CLEAN:if(tail_owner_idle&&resident_retired&&v2_scratch_retired)state<=FINISH;
    TAIL_ABORT:if(tail_abort_valid&&tail_abort_ready)state<=ERROR_CLEAN;
    E_ABORT:if(resident_retired&&v2_scratch_retired)state<=E_FINAL_A;
    E_FINAL_A:if(ws_a_enable&&resident_retired&&v2_scratch_retired)state<=kind==7&&done_status!=0?TAIL_ABORT:FINISH;
    default:begin end
   endcase
   if(vector_done_fire&&state!=E_ABORT)begin
    if(v2_vector_done_status==0&&v2_vector_issued_vectors==4096&&v2_vector_retired_vectors==4096&&v2_h_bank_idle)state<=state==E_RA_RUN?E_RA_RELEASE:state==T_RUN?T_RETIRE:E_RF_RELEASE;
    else fail(vector_op,7,v2_vector_done_status==6?8'd1:8'd2,v2_vector_done_status[7:0],6,vector_detail,E_ABORT);
   end
   if(ln_reject_fire&&done_status==0)fail(ln_op,7,2,8,1,{2'd3,7'b0,4'b0,4'b0,10'b0,v2_ln_reject_code,8'b0,5'b0,36'b0},E_ABORT);
   if(resident_ln_done_fire&&state!=E_ABORT&&!ln_reject_fire)begin
    if(v2_resident_ln_done_kind==0&&v2_resident_ln_done_status==0&&v2_resident_ln_issued_vectors==4096&&v2_resident_ln_written_vectors==4096)state<=state==P_RUN?P_RETIRE:state==N_RUN?N_RETIRE:E_LN_RELEASE;
    else fail(ln_op,7,v2_resident_ln_done_kind==1?8'd1:v2_resident_ln_done_kind==3?8'd6:8'd2,{6'b0,v2_resident_ln_done_kind},1,ln_detail,E_ABORT);
   end
   if(done_valid&&done_ready)begin
    if(kind==0&&done_status==0)model_committed<=1;
    state<=IDLE;
   end
  end
 end

 assign l_prepare_valid=state==PREP;
 assign l_prepare_request_id=request_id;
 assign l_prepare_model_id=MODEL_ID;
 assign l_prepare_generation=generation;
 assign l_prepare_epoch=operation_epoch;
 assign l_prepare_numeric_id=NUMERIC_ID;
 assign l_prepare_table_key=TABLE_KEY;
 assign l_prepare_kind=decision_mode?2'd2:(layer_index%3==0?2'd0:2'd1);
 assign l_prepare_layer=decision_mode?layer_index-5'd28:layer_index;
 assign l_prepare_mask=mask;
 assign l_qkv_wr_valid=state==QMRUN&&m_out_valid;
 assign l_qkv_wr_request_id=m_out_request;
 assign l_qkv_wr_generation=m_out_generation;
 assign l_qkv_wr_epoch=m_out_epoch;
 assign l_qkv_wr_plane=m_out_col[11:10];
 assign l_qkv_wr_head=m_out_col[9:6];
 assign l_qkv_wr_token=m_out_row;
 assign l_qkv_wr_half=m_out_col[5];
 assign l_qkv_wr_data=m_out_data;
 assign l_start_valid=state==LSTART;
 assign l_start_request_id=request_id;
 assign l_start_generation=generation;
 assign l_abort_valid=1'b0;
 assign l_qkv_read_grant=3'b111;
 assign l_ps_grant=1'b1;
 assign l_g_grant=1'b1;
 assign l_context_grant=1'b1;
 assign l_fp_grant=1'b1;
 assign l_sfu_grant=1'b1;
 assign l_exp_grant=1'b1;
 assign l_div_grant=1'b1;
 assign l_rope_write_grant=1'b1;
 assign l_done_ready=state==LRUN;
 assign l_result_rd_valid=c_rd_valid;
 assign l_result_rd_generation=c_rd_generation;
 assign l_result_rd_tag=c_rd_tag;
 assign l_result_rd_head=c_rd_head;
 assign l_result_rd_query=c_rd_query;
 assign l_result_rd_half=c_rd_half;
 assign l_result_rsp_ready=c_rsp_ready;
 assign l_result_discard_valid=state==DISCARD;
 assign l_result_discard_generation=generation;
 assign l_prepare_cancel_valid=state==PCANCEL;
 assign l_prepare_cancel_request_id=request_id;
 assign l_prepare_cancel_generation=generation;
 assign l_prepare_cancel_epoch=operation_epoch;
 assign l_prepare_cancel_rsp_ready=state==PCWAIT;

 assign m_cmd_valid=state==QMSUB||state==WMSUB||state==F_WISUB||state==D1RUN||state==D2SUB;
 assign m_cmd_version=32'd1;
 assign m_cmd_request=request_id;
 assign m_cmd_model=MODEL_ID[63:0];
 assign m_cmd_generation=generation;
 assign m_cmd_epoch=operation_epoch;
 assign m_cmd_tensor=tensor_id[wo_phase];
 assign m_cmd_k=ffn_mode&&wo_phase?(decision_mode?16'd4096:16'd2624):16'd1024;
 assign m_cmd_n=wo_phase?16'd1024:ffn_mode?(decision_mode?16'd4096:16'd5248):16'd3072;
 assign m_cmd_a_slot=ffn_mode&&wo_phase;
 assign m_cmd_bias=decision_mode;
 assign m_cmd_base=base[wo_phase];
 assign m_cmd_span=span[wo_phase];
 assign m_done_ready=state==QMRUN||state==WMRUN||state==D2RUN||state==F_ABORT||state==F_CLOSE&&ffn_close_fire||state==D1DRAIN&&ffn_close_fire;
 assign m_out_ready=state==F_ABORT?1'b1:state==WMRUN||state==D2RUN?projection_identity_ok&&v2_q_wr_ready:state==D1DRAIN?fc1_finite&&q_in_ready:state==QMRUN?l_qkv_wr_ready:ffn_mode&&!decision_mode?g_fill_ready:1'b0;
 assign m_acfg_valid=q_acfg_valid;
 assign m_acfg_slot=q_acfg_slot;
 assign m_acfg_k=q_acfg_k;
 assign m_acfg_request=q_acfg_request;
 assign m_acfg_generation=q_acfg_generation;
 assign m_acfg_epoch=q_acfg_epoch;
 assign m_acfg_rsp_ready=q_acfg_rsp_ready;
 assign m_fill_cancel_valid=(state==ACANCEL||state==ACWAIT)?(state==ACANCEL):q_fill_cancel_valid;
 assign m_fill_cancel_slot=(state==ACANCEL||state==ACWAIT)?(1'b0):q_fill_cancel_slot;
 assign m_fill_cancel_request=(state==ACANCEL||state==ACWAIT)?(request_id):q_fill_cancel_request;
 assign m_fill_cancel_generation=(state==ACANCEL||state==ACWAIT)?(generation):q_fill_cancel_generation;
 assign m_fill_cancel_epoch=(state==ACANCEL||state==ACWAIT)?(epoch):q_fill_cancel_epoch;
 assign m_fill_cancel_rsp_ready=(state==ACANCEL||state==ACWAIT)?(1'b1):q_fill_cancel_rsp_ready;
 assign m_awr_valid=q_awr_valid;
 assign m_awr_row=q_awr_row;
 assign m_awr_group=q_awr_group;
 assign m_awr_data=q_awr_data;
 assign m_awr_request=q_awr_request;
 assign m_awr_generation=q_awr_generation;
 assign m_awr_epoch=q_awr_epoch;
 assign m_awr_rsp_ready=q_awr_rsp_ready;
 assign m_coef_cfg_valid='0;
 assign m_coef_model='0;
 assign m_coef_request='0;
 assign m_coef_tensor='0;
 assign m_coef_generation='0;
 assign m_coef_epoch='0;
 assign m_coef_n='0;
 assign m_coef_wr_valid='0;
 assign m_coef_wr_addr='0;
 assign m_coef_wr_data='0;
 assign m_coef_rsp_ready='0;
 assign m_arready=catalog_owns?4'b0:arready;
 assign m_rvalid=catalog_owns?4'b0:rvalid;
 assign m_rid=rid;
 assign m_rdata=rdata;
 assign m_rresp=rresp;
 assign m_rlast=rlast;
 assign m_run_enable=1'b1;
 assign m_fp_lease_ready=(matrix_owner?r_res_fp_lease_ready:'0);
 assign m_fp_release_ready=(matrix_owner?r_res_fp_release_ready:'0);
 assign m_fp_lease_active=r_res_fp_lease_active;
 assign m_fp_draining=r_res_fp_draining;
 assign m_fp_fault=r_res_fp_protocol_fault;
 assign m_storage_bind_ready=(matrix_owner?r_res_st_bind_ready:'0);
 assign m_storage_idle=r_res_st_idle;
 assign m_mul_req_ready=(matrix_owner?r_res_fp_mul_req_ready:'0);
 assign m_mul_rsp_valid=(matrix_owner?r_res_fp_mul_rsp_valid:'0);
 assign m_mul_rsp_tag=(matrix_owner?r_res_fp_mul_rsp_tag:'0);
 assign m_mul_rsp_data=(matrix_owner?r_res_fp_mul_rsp_data:'0);
 assign m_mul_pending=(matrix_owner?r_res_fp_mul_pending:'0);
 assign m_add_req_ready=(matrix_owner?r_res_fp_add_req_ready:'0);
 assign m_add_rsp_valid=(matrix_owner?r_res_fp_add_rsp_valid:'0);
 assign m_add_rsp_tag=(matrix_owner?r_res_fp_add_rsp_tag:'0);
 assign m_add_rsp_data=(matrix_owner?r_res_fp_add_rsp_data:'0);
 assign m_add_pending=(matrix_owner?r_res_fp_add_pending:'0);
 assign m_ps_wr_ready=(matrix_owner?r_res_st_ps_wr_ready:'0);
 assign m_ps_wr_rsp_valid=(matrix_owner?r_res_st_ps_wr_rsp_valid:'0);
 assign m_ps_rd_ready=(matrix_owner?r_res_st_ps_rd_ready:'0);
 assign m_ps_rd_rsp_valid=(matrix_owner?r_res_st_ps_rd_rsp_valid:'0);
 assign m_ps_rd_rsp_mask=(matrix_owner?r_res_st_ps_rd_rsp_mask:'0);
 assign m_ps_rd_rsp_data=(matrix_owner?r_res_st_ps_rd_rsp_data:'0);
 assign m_ps_wr_rsp_tag=(matrix_owner?r_res_st_ps_wr_rsp_tag:'0);
 assign m_ps_rd_rsp_tag=(matrix_owner?r_res_st_ps_rd_rsp_tag:'0);
 assign q_run_enable=1'b1;
 assign q_cmd_valid=state==QSUB||state==F_NQSUB||state==D1SUB||state==CSUB&&c_start_ready||state==F_GQSUB&&g_cmd_ready;
 assign q_cmd_slot=state==F_GQSUB||state==D1SUB;
 assign q_cmd_k=state==D1SUB?16'd4096:state==F_GQSUB?16'd2624:16'd1024;
 assign q_cmd_request=request_id;
 assign q_cmd_generation=generation;
 assign q_cmd_epoch=operation_epoch;
 assign q_in_valid=resident_source_phase?resident_source_valid:state==CRUN?c_out_valid:state==D1DRAIN?m_out_valid&&fc1_finite:(state==F_RUN||state==F_CLOSE||state==F_ABORT)&&pack_full&&!q_close_sent;
 assign q_in_data=resident_source_phase?resident_source_data:state==CRUN?c_out_data:state==D1DRAIN?relu_data:pack_data;
 assign q_in_request=request_id;
 assign q_in_generation=generation;
 assign q_in_epoch=operation_epoch;
 assign q_in_row=resident_source_phase?{1'b0,resident_source_addr[11:5]}:state==CRUN?c_out_row:state==D1DRAIN?{1'b0,m_out_row}:{1'b0,pack_previous[8:2]};
 assign q_in_group=resident_source_phase?{3'b0,resident_source_addr[4:0]}:state==CRUN?c_out_group:state==D1DRAIN?8'(m_out_col>>5):{1'b0,pack_previous[15:9]};
 assign q_producer_close_valid=(state==QRUN||state==F_NQRUN)&&(inputs_accepted==4096||producer_failure)||state==CRUN&&(c_complete||producer_failure||c_fault)||state==F_CLOSE||state==D1DRAIN&&m_done_valid&&(m_status!=0||pack_seq==16384)||state==F_ABORT&&!q_close_sent&&!q_cmd_ready&&!q_done_valid;
 assign q_producer_close_success=state!=F_ABORT&&!producer_failure&&!c_fault&&!(state==D1DRAIN&&m_status!=0);
 assign q_done_ready=state==QRUN||state==CRUN||state==F_NQRUN||state==F_QDRAIN||state==F_ABORT;
 assign q_acfg_ready=m_acfg_ready;
 assign q_acfg_rsp_valid=m_acfg_rsp_valid;
 assign q_acfg_status=m_acfg_status;
 assign q_awr_ready=m_awr_ready;
 assign q_awr_rsp_valid=m_awr_rsp_valid;
 assign q_fill_cancel_ready=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_ready;
 assign q_fill_cancel_reject_valid=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_reject_valid;
 assign q_fill_cancel_reject_code=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_reject_code;
 assign q_fill_cancel_rsp_valid=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_valid;
 assign q_fill_cancel_rsp_slot=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_slot;
 assign q_fill_cancel_rsp_request=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_request;
 assign q_fill_cancel_rsp_generation=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_generation;
 assign q_fill_cancel_rsp_epoch=(state==ACANCEL||state==ACWAIT)?'0:m_fill_cancel_rsp_epoch;
 assign q_d_lease_ready=(front_owner?r_res_div_lease_ready:'0);
 assign q_d_release_ready=(front_owner?r_res_div_release_ready:'0);
 assign q_d_lease_active=r_res_div_lease_active;
 assign q_d_draining=r_res_div_draining;
 assign q_d_rsp_request_id=r_res_div_rsp_request_id;
 assign q_d_rsp_generation=r_res_div_rsp_generation;
 assign q_d_rsp_epoch=r_res_div_rsp_epoch;
 assign q_d_rsp_head=r_res_div_rsp_head;
 assign q_d_rsp_phase=r_res_div_rsp_phase;
 assign q_d_req_ready=(front_owner?r_res_div_req_ready:'0);
 assign q_d_protocol_reject_valid=(front_owner?r_res_div_protocol_reject_valid:'0);
 assign q_d_protocol_reject_code=r_res_div_protocol_reject_code;
 assign q_d_rsp_valid=(front_owner?r_res_div_rsp_valid:'0);
 assign q_d_rsp_tag=(front_owner?r_res_div_rsp_tag:'0);
 assign q_d_rsp_lane_mask=r_res_div_rsp_lane_mask;
 assign q_d_rsp_numeric_error=(front_owner?r_res_div_rsp_numeric_error:'0);
 assign q_d_rsp_data=(front_owner?r_res_div_rsp_data:'0);
 assign q_d_pending_vectors=(front_owner?r_res_div_pending_vectors:'0);
 assign q_d_in_flight_vectors=(front_owner?r_res_div_in_flight_vectors:'0);
 assign q_d_in_flight_scalars=(front_owner?r_res_div_in_flight_scalars:'0);
 assign q_d_protocol_fault=(front_owner?r_res_div_protocol_fault:'0);
 assign r_res_qkv_wr_valid='0;
 assign r_res_qkv_wr_plane='0;
 assign r_res_qkv_wr_head='0;
 assign r_res_qkv_wr_token='0;
 assign r_res_qkv_wr_half='0;
 assign r_res_qkv_wr_data='0;
 assign r_res_qkv_rd_valid='0;
 assign r_res_qkv_rd_head='0;
 assign r_res_qkv_rd_token='0;
 assign r_res_qkv_rd_tag='0;
 assign r_res_qkv_rd_rsp_ready='0;
 assign r_res_st_bind_valid=matrix_owner?m_bind_new_lease:'0;
 assign r_res_st_bind_request_id=matrix_owner?m_fp_owner_request:'0;
 assign r_res_st_bind_generation=matrix_owner?m_fp_owner_generation:'0;
 assign r_res_st_bind_epoch=matrix_owner?m_fp_owner_epoch:'0;
 assign r_res_st_bind_head=matrix_owner?4'b0:'0;
 assign r_res_st_bind_phase=matrix_owner?3'd1:'0;
 assign r_res_st_op_request_id=matrix_owner?m_fp_owner_request:'0;
 assign r_res_st_op_generation=matrix_owner?m_fp_owner_generation:'0;
 assign r_res_st_op_epoch=matrix_owner?m_fp_owner_epoch:'0;
 assign r_res_st_op_phase=matrix_owner?3'd1:'0;
 assign r_res_st_ps_wr_valid=matrix_owner?m_ps_wr_valid:'0;
 assign r_res_st_ps_wr_mask=matrix_owner?m_ps_wr_mask:'0;
 assign r_res_st_ps_wr_addr=matrix_owner?m_ps_wr_addr:'0;
 assign r_res_st_ps_wr_data=matrix_owner?m_ps_wr_data:'0;
 assign r_res_st_ps_wr_tag=matrix_owner?m_ps_wr_tag:'0;
 assign r_res_st_ps_wr_rsp_ready=matrix_owner?m_ps_wr_rsp_ready:'0;
 assign r_res_st_ps_rd_valid=matrix_owner?m_ps_rd_valid:'0;
 assign r_res_st_ps_rd_mask=matrix_owner?m_ps_rd_mask:'0;
 assign r_res_st_ps_rd_addr=matrix_owner?m_ps_rd_addr:'0;
 assign r_res_st_ps_rd_tag=matrix_owner?m_ps_rd_tag:'0;
 assign r_res_st_ps_rd_rsp_ready=matrix_owner?m_ps_rd_rsp_ready:'0;

 assign r_res_st_context_wr_valid='0;
 assign r_res_st_context_wr_mask='0;
 assign r_res_st_context_wr_addr='0;
 assign r_res_st_context_wr_data='0;
 assign r_res_st_context_wr_tag='0;
 assign r_res_st_context_wr_rsp_ready='0;
 assign r_res_st_context_rd_valid='0;
 assign r_res_st_context_rd_mask='0;
 assign r_res_st_context_rd_addr='0;
 assign r_res_st_context_rd_tag='0;
 assign r_res_st_context_rd_rsp_ready='0;
 assign r_res_fp_lease_valid=matrix_owner?m_bind_new_lease:'0;
 assign r_res_fp_lease_request_id=matrix_owner?m_fp_owner_request:'0;
 assign r_res_fp_lease_generation=matrix_owner?m_fp_owner_generation:'0;
 assign r_res_fp_lease_epoch=matrix_owner?m_fp_owner_epoch:'0;
 assign r_res_fp_lease_head=matrix_owner?4'b0:'0;
 assign r_res_fp_lease_phase=matrix_owner?3'd1:'0;
 assign r_res_fp_release_valid=matrix_owner?m_fp_release_valid:'0;
 assign r_res_fp_release_phase=matrix_owner?3'd1:'0;
 assign r_res_fp_release_epoch=matrix_owner?m_fp_owner_epoch:'0;
 assign r_res_fp_phase_debt_clear=matrix_owner?m_fp_phase_debt_clear:'0;
 assign r_res_fp_mul_req_valid=matrix_owner?m_mul_req_valid:'0;
 assign r_res_fp_mul_req_phase=matrix_owner?3'd1:'0;
 assign r_res_fp_mul_req_epoch=matrix_owner?m_fp_owner_epoch:'0;
 assign r_res_fp_mul_req_tag=matrix_owner?m_mul_req_tag:'0;
 assign r_res_fp_mul_a=matrix_owner?m_mul_a:'0;
 assign r_res_fp_mul_b=matrix_owner?m_mul_b:'0;
 assign r_res_fp_mul_rsp_ready=matrix_owner?m_mul_rsp_ready:'0;
 assign r_res_fp_add_req_valid=matrix_owner?m_add_req_valid:'0;
 assign r_res_fp_add_req_is_root=matrix_owner?m_add_req_is_root:'0;
 assign r_res_fp_add_req_phase=matrix_owner?m_add_req_phase:'0;
 assign r_res_fp_add_req_epoch=matrix_owner?m_add_req_epoch:'0;
 assign r_res_fp_add_req_tag=matrix_owner?m_add_req_tag:'0;
 assign r_res_fp_add_a=matrix_owner?m_add_a:'0;
 assign r_res_fp_add_b=matrix_owner?m_add_b:'0;
 assign r_res_fp_add_rsp_ready=matrix_owner?m_add_rsp_ready:'0;
 assign r_res_ln_bind_valid='0;
 assign r_res_ln_bind_request_id='0;
 assign r_res_ln_bind_generation='0;
 assign r_res_ln_bind_epoch='0;
 assign r_res_ln_bind_head='0;
 assign r_res_ln_bind_phase='0;
 assign r_res_ln_op_request_id='0;
 assign r_res_ln_op_generation='0;
 assign r_res_ln_op_epoch='0;
 assign r_res_ln_op_phase='0;
 assign r_res_ln_wr_valid='0;
 assign r_res_ln_wr_mask='0;
 assign r_res_ln_wr_addr='0;
 assign r_res_ln_wr_data='0;
 assign r_res_ln_wr_tag='0;
 assign r_res_ln_wr_rsp_ready='0;
 assign r_res_ln_rd_valid='0;
 assign r_res_ln_rd_mask='0;
 assign r_res_ln_rd_addr='0;
 assign r_res_ln_rd_tag='0;
 assign r_res_ln_rd_rsp_ready='0;
 assign r_res_sfu_lease_valid='0;
 assign r_res_sfu_lease_request_id='0;
 assign r_res_sfu_lease_generation='0;
 assign r_res_sfu_lease_epoch='0;
 assign r_res_sfu_lease_head='0;
 assign r_res_sfu_lease_phase='0;
 assign r_res_sfu_release_valid='0;
 assign r_res_sfu_release_phase='0;
 assign r_res_sfu_release_epoch='0;
 assign r_res_sfu_phase_debt_clear='0;
 assign r_res_sfu_context_valid='0;
 assign r_res_sfu_context_row_hi='0;
 assign r_res_sfu_req_valid='0;
 assign r_res_sfu_req_mode='0;
 assign r_res_sfu_req_generation='0;
 assign r_res_sfu_req_epoch='0;
 assign r_res_sfu_req_phase='0;
 assign r_res_sfu_req_tag='0;
 assign r_res_sfu_req_x='0;
 assign r_res_sfu_rsp_ready='0;
 assign r_res_div_lease_valid=front_owner?q_d_lease_valid:'0;
 assign r_res_div_lease_request_id=front_owner?q_d_lease_request_id:'0;
 assign r_res_div_lease_generation=front_owner?q_d_lease_generation:'0;
 assign r_res_div_lease_epoch=front_owner?q_d_lease_epoch:'0;
 assign r_res_div_lease_head=front_owner?q_d_lease_head:'0;
 assign r_res_div_lease_phase=front_owner?q_d_lease_phase:'0;
 assign r_res_div_release_valid=front_owner?q_d_release_valid:'0;
 assign r_res_div_release_phase=front_owner?q_d_release_phase:'0;
 assign r_res_div_release_epoch=front_owner?q_d_release_epoch:'0;
 assign r_res_div_phase_debt_clear=front_owner?q_d_phase_debt_clear:'0;
 assign r_res_div_req_valid=front_owner?q_d_req_valid:'0;
 assign r_res_div_req_generation=front_owner?q_d_req_generation:'0;
 assign r_res_div_req_epoch=front_owner?q_d_req_epoch:'0;
 assign r_res_div_req_phase=front_owner?q_d_req_phase:'0;
 assign r_res_div_req_lane_mask=front_owner?q_d_req_lane_mask:'0;
 assign r_res_div_req_tag=front_owner?q_d_req_tag:'0;
 assign r_res_div_req_a=front_owner?q_d_req_a:'0;
 assign r_res_div_req_b=front_owner?q_d_req_b:'0;
 assign r_res_div_rsp_ready=front_owner?q_d_rsp_ready:'0;
 assign r_res_scale_valid='0;
 assign r_res_scale_tag='0;
 assign r_res_scale_input='0;
 assign r_res_scale_rsp_ready='0;
 assign r_rope_owner_valid=l_rope_owner_valid;
 assign r_rope_owner_request_id=l_rope_owner_request_id;
 assign r_rope_owner_generation=l_rope_owner_generation;
 assign r_rope_owner_epoch=l_rope_owner_epoch;
 assign r_rope_wr_valid=l_rope_wr_valid;
 assign r_rope_wr_request_id=l_rope_wr_request_id;
 assign r_rope_wr_generation=l_rope_wr_generation;
 assign r_rope_wr_epoch=l_rope_wr_epoch;
 assign r_rope_wr_head=l_rope_wr_head;
 assign r_rope_wr_token=l_rope_wr_token;
 assign r_rope_wr_tag=l_rope_wr_tag;
 assign r_rope_wr_q=l_rope_wr_q;
 assign r_rope_wr_k=l_rope_wr_k;

 assign c_rd_ready=l_result_rd_ready;assign c_rsp_valid=l_result_rsp_valid;assign c_rsp_tag=l_result_rsp_tag;assign c_rsp_data=l_result_rsp_data;
 assign c_out_ready=state==CRUN&&q_in_ready;
 laya_m007_context_quant_adapter_v1 context_adapter(
  .clk,.rst_n,.start_valid(state==CSUB&&q_cmd_valid&&q_cmd_ready),.start_ready(c_start_ready),.generation,.cancel(producer_failed||c_fault||context_failed),
  .rd_valid(c_rd_valid),.rd_ready(c_rd_ready),.rd_generation(c_rd_generation),.rd_tag(c_rd_tag),.rd_head(c_rd_head),.rd_query(c_rd_query),.rd_half(c_rd_half),
  .rsp_valid(c_rsp_valid),.rsp_ready(c_rsp_ready),.rsp_tag(c_rsp_tag),.rsp_data(c_rsp_data),.out_valid(c_out_valid),.out_ready(c_out_ready),.out_data(c_out_data),.out_row(c_out_row),.out_group(c_out_group),
  .idle(c_idle),.complete(c_complete),.protocol_fault(c_fault),.accepted_reads(c_accepted),.consumed_groups(c_consumed));  
 laya_m007_matrix_facade_v2 #(.PROFILE_ENABLE(0),.CANONICAL_MODEL(1),.CANONICAL_MODEL_ID(MODEL_ID[63:0])) matrix(
 .model_committed,.bias_word_valid(bias_word_valid),.bias_word_ready(bias_word_ready),.bias_word_index(model_word_index),.bias_word_data(model_word_data),.transport_idle(m_transport_idle),
 .clk(clk),
 .rst_n(rst_n),
 .cmd_valid(m_cmd_valid),
 .cmd_ready(m_cmd_ready),
 .descriptor_precheck_ok(m_descriptor_precheck_ok),
 .cmd_version(m_cmd_version),
 .cmd_request(m_cmd_request),
 .cmd_model(m_cmd_model),
 .cmd_generation(m_cmd_generation),
 .cmd_epoch(m_cmd_epoch),
 .cmd_tensor(m_cmd_tensor),
 .cmd_k(m_cmd_k),
 .cmd_n(m_cmd_n),
 .cmd_a_slot(m_cmd_a_slot),
 .cmd_bias(m_cmd_bias),
 .cmd_base(m_cmd_base),
 .cmd_span(m_cmd_span),
 .done_valid(m_done_valid),
 .done_ready(m_done_ready),
 .status(m_status),
 .done_request(m_done_request),
 .done_generation(m_done_generation),
 .done_epoch(m_done_epoch),
 .error_row(m_error_row),
 .error_col(m_error_col),
 .error_group(m_error_group),
 .error_stage(m_error_stage),
 .out_valid(m_out_valid),
 .out_ready(m_out_ready),
 .out_data(m_out_data),
 .out_row(m_out_row),
 .out_col(m_out_col),
 .out_s(m_out_s),
 .out_request(m_out_request),
 .out_generation(m_out_generation),
 .out_epoch(m_out_epoch),
 .acfg_valid(m_acfg_valid),
 .acfg_ready(m_acfg_ready),
 .acfg_slot(m_acfg_slot),
 .acfg_k(m_acfg_k),
 .acfg_request(m_acfg_request),
 .acfg_generation(m_acfg_generation),
 .acfg_epoch(m_acfg_epoch),
 .acfg_rsp_valid(m_acfg_rsp_valid),
 .acfg_rsp_ready(m_acfg_rsp_ready),
 .acfg_status(m_acfg_status),
 .fill_cancel_valid(m_fill_cancel_valid),
 .fill_cancel_ready(m_fill_cancel_ready),
 .fill_cancel_slot(m_fill_cancel_slot),
 .fill_cancel_request(m_fill_cancel_request),
 .fill_cancel_generation(m_fill_cancel_generation),
 .fill_cancel_epoch(m_fill_cancel_epoch),
 .fill_cancel_reject_valid(m_fill_cancel_reject_valid),
 .fill_cancel_reject_code(m_fill_cancel_reject_code),
 .fill_cancel_rsp_valid(m_fill_cancel_rsp_valid),
 .fill_cancel_rsp_ready(m_fill_cancel_rsp_ready),
 .fill_cancel_rsp_slot(m_fill_cancel_rsp_slot),
 .fill_cancel_rsp_request(m_fill_cancel_rsp_request),
 .fill_cancel_rsp_generation(m_fill_cancel_rsp_generation),
 .fill_cancel_rsp_epoch(m_fill_cancel_rsp_epoch),
 .awr_valid(m_awr_valid),
 .awr_ready(m_awr_ready),
 .awr_row(m_awr_row),
 .awr_group(m_awr_group),
 .awr_data(m_awr_data),
 .awr_request(m_awr_request),
 .awr_generation(m_awr_generation),
 .awr_epoch(m_awr_epoch),
 .awr_rsp_valid(m_awr_rsp_valid),
 .awr_rsp_ready(m_awr_rsp_ready),
 .coef_cfg_valid(m_coef_cfg_valid),
 .coef_cfg_ready(m_coef_cfg_ready),
 .coef_model(m_coef_model),
 .coef_request(m_coef_request),
 .coef_tensor(m_coef_tensor),
 .coef_generation(m_coef_generation),
 .coef_epoch(m_coef_epoch),
 .coef_n(m_coef_n),
 .coef_wr_valid(m_coef_wr_valid),
 .coef_wr_ready(m_coef_wr_ready),
 .coef_wr_addr(m_coef_wr_addr),
 .coef_wr_data(m_coef_wr_data),
 .coef_rsp_valid(m_coef_rsp_valid),
 .coef_rsp_ready(m_coef_rsp_ready),
 .coef_status(m_coef_status),
 .coef_error_col(m_coef_error_col),
 .arvalid(m_arvalid),
 .arready(m_arready),
 .araddr(m_araddr),
 .arid(m_arid),
 .arlen(m_arlen),
 .rvalid(m_rvalid),
 .rready(m_rready),
 .rid(m_rid),
 .rdata(m_rdata),
 .rresp(m_rresp),
 .rlast(m_rlast),
 .run_enable(m_run_enable),
 .elapsed_cycles(m_elapsed_cycles),
 .first_output_cycle(m_first_output_cycle),
 .w_wait_cycles(m_w_wait_cycles),
 .ctx_wait_cycles(m_ctx_wait_cycles),
 .blocks_issued(m_blocks_issued),
 .blocks_computed(m_blocks_computed),
 .blocks_retired(m_blocks_retired),
 .ps_merged_reads(m_ps_merged_reads),
 .ps_response_holds(m_ps_response_holds),
 .bias_add_conflicts(m_bias_add_conflicts),
 .compute_output_overlap(m_compute_output_overlap),
 .peak_return_reservations(m_peak_return_reservations),
 .arithmetic_debt(m_arithmetic_debt),
 .peak_arithmetic_reservations(m_peak_arithmetic_reservations),
 .profile_valid(m_profile_valid),
 .fp_owner_request(m_fp_owner_request),
 .fp_owner_generation(m_fp_owner_generation),
 .fp_owner_epoch(m_fp_owner_epoch),
 .bind_new_lease(m_bind_new_lease),
 .fp_release_valid(m_fp_release_valid),
 .fp_phase_debt_clear(m_fp_phase_debt_clear),
 .fp_lease_ready(m_fp_lease_ready),
 .fp_release_ready(m_fp_release_ready),
 .fp_lease_active(m_fp_lease_active),
 .fp_draining(m_fp_draining),
 .fp_fault(m_fp_fault),
 .storage_bind_ready(m_storage_bind_ready),
 .storage_idle(m_storage_idle),
 .mul_req_valid(m_mul_req_valid),
 .mul_rsp_ready(m_mul_rsp_ready),
 .mul_req_ready(m_mul_req_ready),
 .mul_rsp_valid(m_mul_rsp_valid),
 .mul_req_tag(m_mul_req_tag),
 .mul_rsp_tag(m_mul_rsp_tag),
 .mul_a(m_mul_a),
 .mul_b(m_mul_b),
 .mul_rsp_data(m_mul_rsp_data),
 .mul_pending(m_mul_pending),
 .add_req_valid(m_add_req_valid),
 .add_req_is_root(m_add_req_is_root),
 .add_rsp_ready(m_add_rsp_ready),
 .add_req_ready(m_add_req_ready),
 .add_rsp_valid(m_add_rsp_valid),
 .add_req_phase(m_add_req_phase),
 .add_req_epoch(m_add_req_epoch),
 .add_req_tag(m_add_req_tag),
 .add_rsp_tag(m_add_rsp_tag),
 .add_a(m_add_a),
 .add_b(m_add_b),
 .add_rsp_data(m_add_rsp_data),
 .add_pending(m_add_pending),
 .ps_wr_valid(m_ps_wr_valid),
 .ps_wr_rsp_ready(m_ps_wr_rsp_ready),
 .ps_rd_valid(m_ps_rd_valid),
 .ps_rd_rsp_ready(m_ps_rd_rsp_ready),
 .ps_wr_ready(m_ps_wr_ready),
 .ps_wr_rsp_valid(m_ps_wr_rsp_valid),
 .ps_rd_ready(m_ps_rd_ready),
 .ps_rd_rsp_valid(m_ps_rd_rsp_valid),
 .ps_wr_mask(m_ps_wr_mask),
 .ps_rd_mask(m_ps_rd_mask),
 .ps_rd_rsp_mask(m_ps_rd_rsp_mask),
 .ps_wr_addr(m_ps_wr_addr),
 .ps_rd_addr(m_ps_rd_addr),
 .ps_wr_data(m_ps_wr_data),
 .ps_rd_rsp_data(m_ps_rd_rsp_data),
 .ps_wr_tag(m_ps_wr_tag),
 .ps_rd_tag(m_ps_rd_tag),
 .ps_wr_rsp_tag(m_ps_wr_rsp_tag),
 .ps_rd_rsp_tag(m_ps_rd_rsp_tag)
 );
 laya_m007_quant_a_fill_v1 front(
 .clk(clk),
 .rst_n(rst_n),
 .run_enable(q_run_enable),
 .cmd_valid(q_cmd_valid),
 .cmd_ready(q_cmd_ready),
 .cmd_slot(q_cmd_slot),
 .cmd_k(q_cmd_k),
 .cmd_request(q_cmd_request),
 .cmd_generation(q_cmd_generation),
 .cmd_epoch(q_cmd_epoch),
 .in_valid(q_in_valid),
 .in_ready(q_in_ready),
 .in_data(q_in_data),
 .in_request(q_in_request),
 .in_generation(q_in_generation),
 .in_epoch(q_in_epoch),
 .in_row(q_in_row),
 .in_group(q_in_group),
 .producer_close_valid(q_producer_close_valid),
 .producer_close_ready(q_producer_close_ready),
 .producer_close_success(q_producer_close_success),
 .done_valid(q_done_valid),
 .done_ready(q_done_ready),
 .status(q_status),
 .quant_phase(q_quant_phase),
 .quant_row(q_quant_row),
 .quant_group(q_quant_group),
 .quant_element(q_quant_element),
 .quant_accepted(q_quant_accepted),
 .quant_retired(q_quant_retired),
 .a_writes(q_a_writes),
 .a_write_acks(q_a_write_acks),
 .quant_last_event(q_quant_last_event),
 .a_publish_event(q_a_publish_event),
 .acfg_valid(q_acfg_valid),
 .acfg_ready(q_acfg_ready),
 .acfg_slot(q_acfg_slot),
 .acfg_k(q_acfg_k),
 .acfg_request(q_acfg_request),
 .acfg_generation(q_acfg_generation),
 .acfg_epoch(q_acfg_epoch),
 .acfg_rsp_valid(q_acfg_rsp_valid),
 .acfg_rsp_ready(q_acfg_rsp_ready),
 .acfg_status(q_acfg_status),
 .awr_valid(q_awr_valid),
 .awr_ready(q_awr_ready),
 .awr_row(q_awr_row),
 .awr_group(q_awr_group),
 .awr_data(q_awr_data),
 .awr_request(q_awr_request),
 .awr_generation(q_awr_generation),
 .awr_epoch(q_awr_epoch),
 .awr_rsp_valid(q_awr_rsp_valid),
 .awr_rsp_ready(q_awr_rsp_ready),
 .fill_cancel_valid(q_fill_cancel_valid),
 .fill_cancel_ready(q_fill_cancel_ready),
 .fill_cancel_slot(q_fill_cancel_slot),
 .fill_cancel_request(q_fill_cancel_request),
 .fill_cancel_generation(q_fill_cancel_generation),
 .fill_cancel_epoch(q_fill_cancel_epoch),
 .fill_cancel_reject_valid(q_fill_cancel_reject_valid),
 .fill_cancel_reject_code(q_fill_cancel_reject_code),
 .fill_cancel_rsp_valid(q_fill_cancel_rsp_valid),
 .fill_cancel_rsp_ready(q_fill_cancel_rsp_ready),
 .fill_cancel_rsp_slot(q_fill_cancel_rsp_slot),
 .fill_cancel_rsp_request(q_fill_cancel_rsp_request),
 .fill_cancel_rsp_generation(q_fill_cancel_rsp_generation),
 .fill_cancel_rsp_epoch(q_fill_cancel_rsp_epoch),
 .d_lease_valid(q_d_lease_valid),
 .d_lease_ready(q_d_lease_ready),
 .d_lease_request_id(q_d_lease_request_id),
 .d_lease_generation(q_d_lease_generation),
 .d_lease_epoch(q_d_lease_epoch),
 .d_lease_head(q_d_lease_head),
 .d_lease_phase(q_d_lease_phase),
 .d_release_valid(q_d_release_valid),
 .d_release_ready(q_d_release_ready),
 .d_release_phase(q_d_release_phase),
 .d_release_epoch(q_d_release_epoch),
 .d_phase_debt_clear(q_d_phase_debt_clear),
 .d_lease_active(q_d_lease_active),
 .d_draining(q_d_draining),
 .d_rsp_request_id(q_d_rsp_request_id),
 .d_rsp_generation(q_d_rsp_generation),
 .d_rsp_epoch(q_d_rsp_epoch),
 .d_rsp_head(q_d_rsp_head),
 .d_rsp_phase(q_d_rsp_phase),
 .d_req_valid(q_d_req_valid),
 .d_req_ready(q_d_req_ready),
 .d_req_generation(q_d_req_generation),
 .d_req_epoch(q_d_req_epoch),
 .d_req_phase(q_d_req_phase),
 .d_req_lane_mask(q_d_req_lane_mask),
 .d_req_tag(q_d_req_tag),
 .d_req_a(q_d_req_a),
 .d_req_b(q_d_req_b),
 .d_protocol_reject_valid(q_d_protocol_reject_valid),
 .d_protocol_reject_code(q_d_protocol_reject_code),
 .d_rsp_valid(q_d_rsp_valid),
 .d_rsp_ready(q_d_rsp_ready),
 .d_rsp_tag(q_d_rsp_tag),
 .d_rsp_lane_mask(q_d_rsp_lane_mask),
 .d_rsp_numeric_error(q_d_rsp_numeric_error),
 .d_rsp_data(q_d_rsp_data),
 .d_pending_vectors(q_d_pending_vectors),
 .d_in_flight_vectors(q_d_in_flight_vectors),
 .d_in_flight_scalars(q_d_in_flight_scalars),
 .d_protocol_fault(q_d_protocol_fault)
 );
 
  assign ws_owner_req_valid=state==F_ARENA||state==F_RETURN||state==E_RA_OWNER||state==E_LN_OWNER||state==E_FF_OWNER||state==E_RF_OWNER||state==E_FINAL_A||state==S_GOWNER||state==P_OWNER||state==N_OWNER||state==T_OWNER||state==C_A0_AR||state==LAYER_NEXT||state==S_ROPE||state==SETUP_ERROR;
  
  assign g_cmd_valid=state==F_GQSUB&&q_cmd_ready;
  assign g_cmd_request_id=request_id;assign g_cmd_generation=generation;assign g_cmd_epoch=operation_epoch;

  assign g_fill_valid=ffn_mode&&!decision_mode&&g_active&&state!=F_ABORT&&m_out_valid&&!wo_phase;
  assign g_fill_request_id=m_out_request;assign g_fill_generation=m_out_generation;assign g_fill_epoch=m_out_epoch;
  assign g_fill_slot=m_out_s[0];assign g_fill_s=m_out_s[6:0];assign g_fill_half=m_out_col>=2624;assign g_fill_row=m_out_row;assign g_fill_data=m_out_data;
  assign g_out_ready=state==F_ABORT?1'b1:((state==F_RUN||state==F_CLOSE)&&(!pack_full||q_in_ready)&&pack_seq<41984);
  assign g_done_ready=(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT;
  assign g_producer_cancel_valid=state==F_ABORT&&!decision_mode&&g_active&&!g_cancel_sent;
  assign g_producer_cancel_request_id=request_id;assign g_producer_cancel_generation=generation;assign g_producer_cancel_epoch=operation_epoch;
  assign g_discard_valid=state==F_DISCARD&&g_needs_discard;
  assign g_discard_request_id=request_id;assign g_discard_generation=generation;assign g_discard_epoch=operation_epoch;
  always_ff @(posedge clk)begin
   if(!rst_n)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
   else begin
    if(cmd_valid&&cmd_ready||state==E_FF_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
    if(q_in_valid&&q_in_ready&&ffn_mode&&!decision_mode&&state!=F_NQRUN)pack_full<=0;
    if(state==D1DRAIN&&m_out_valid&&m_out_ready)pack_seq<=pack_seq+1'b1;
    if(g_output_fire&&state!=F_ABORT)begin
     if(g_out_tag!={generation,operation_epoch,16'b0,pack_seq})pack_fault<=1;
     pack_data[8*pack_seq[1:0]+:8]<=g_out_data;pack_seq<=pack_seq+1'b1;
     if(pack_seq[1:0]==3)pack_full<=1;
    end
    if(g_producer_cancel_valid&&g_producer_cancel_ready||v2_ln_cancel_valid&&v2_ln_cancel_ready)g_cancel_sent<=1;
    if(ffn_close_fire&&ffn_mode&&state!=F_NQRUN)begin q_close_sent<=1;if(state==F_ABORT)pack_full<=0;end
   end
  end

// Generated public bindings; body owned by A007, not copied here.
laya_m007_resident_joint_v3 resident(
 .type_model_committed(model_committed),.type_qtype(qtype),.type_wr_valid(type_word_valid),.type_wr_ready(type_word_ready),.type_wr_index(model_word_index[6:0]),.type_wr_data(model_word_data),.type_wr_commit(type_word_commit),.type_bank_idle(type_bank_idle),.type_reject_valid(type_reject_valid),.h_load_success_valid(h_load_success_valid),
  .clk(clk),
  .rst_n(rst_n),
  .owner_req_valid(ws_owner_req_valid),
  .owner_req(v2_owner_req),
  .owner_req_ready(ws_owner_req_ready),
  .owner(v2_owner),
  .rearm(ws_rearm),
  .a_enable(ws_a_enable),
  .g_enable(ws_g_enable),
  .ln_enable(v2_ln_enable),
  .vector_enable(v2_vector_enable),
  .resident_owner_valid(v2_resident_owner_valid),
  .resident_owner_request_id(v2_resident_owner_request_id),
  .resident_owner_generation(v2_resident_owner_generation),
  .resident_owner_epoch(v2_resident_owner_epoch),
  .resident_inputs_ready(v2_resident_inputs_ready),
  .parent_matrix_retired(v2_parent_matrix_retired),
  .parent_quant_retired(v2_parent_quant_retired),
  .resident_access_request_id(v2_resident_access_request_id),
  .resident_access_generation(v2_resident_access_generation),
  .resident_access_epoch(v2_resident_access_epoch),
  .h_wr_valid(v2_h_wr_valid),
  .h_wr_ready(v2_h_wr_ready),
  .h_wr_commit(v2_h_wr_commit),
  .h_wr_addr(v2_h_wr_addr),
  .h_wr_data(v2_h_wr_data),
  .h_rd_valid(v2_h_rd_valid),
  .h_rd_ready(v2_h_rd_ready),
  .h_rd_addr(v2_h_rd_addr),
  .h_rsp_valid(v2_h_rsp_valid),
  .h_rsp_ready(v2_h_rsp_ready),
  .h_rsp_addr(v2_h_rsp_addr),
  .h_rsp_data(v2_h_rsp_data),
  .h_reject_valid(v2_h_reject_valid),
  .q_wr_valid(v2_q_wr_valid),
  .q_wr_ready(v2_q_wr_ready),
  .q_wr_commit(v2_q_wr_commit),
  .q_wr_addr(v2_q_wr_addr),
  .q_wr_data(v2_q_wr_data),
  .q_rd_valid(v2_q_rd_valid),
  .q_rd_ready(v2_q_rd_ready),
  .q_rd_addr(v2_q_rd_addr),
  .q_rsp_valid(v2_q_rsp_valid),
  .q_rsp_ready(v2_q_rsp_ready),
  .q_rsp_addr(v2_q_rsp_addr),
  .q_rsp_data(v2_q_rsp_data),
  .q_reject_valid(v2_q_reject_valid),
  .scratch_lease_valid(v2_scratch_lease_valid),
  .scratch_release_valid(v2_scratch_release_valid),
  .scratch_lease_ready(v2_scratch_lease_ready),
  .scratch_release_ready(v2_scratch_release_ready),
  .scratch_owner_active(v2_scratch_owner_active),
  .scratch_retired(v2_scratch_retired),
  .h_bank_idle(v2_h_bank_idle),
  .resident_bank_idle(v2_resident_bank_idle),
  .shared_resources_idle(v2_shared_resources_idle),
  .ln_provider_idle(v2_ln_provider_idle),
  .a_prepare_valid(l_prepare_valid),
  .a_prepare_ready(l_prepare_ready),
  .a_prepare_request_id(l_prepare_request_id),
  .a_prepare_model_id(l_prepare_model_id),
  .a_prepare_generation(l_prepare_generation),
  .a_prepare_epoch(l_prepare_epoch),
  .a_prepare_numeric_id(l_prepare_numeric_id),
  .a_prepare_table_key(l_prepare_table_key),
  .a_prepare_kind(l_prepare_kind),
  .a_prepare_layer(l_prepare_layer),
  .a_prepare_mask(l_prepare_mask),
  .a_qkv_wr_valid(l_qkv_wr_valid),
  .a_qkv_wr_ready(l_qkv_wr_ready),
  .a_qkv_wr_request_id(l_qkv_wr_request_id),
  .a_qkv_wr_generation(l_qkv_wr_generation),
  .a_qkv_wr_epoch(l_qkv_wr_epoch),
  .a_qkv_wr_plane(l_qkv_wr_plane),
  .a_qkv_wr_head(l_qkv_wr_head),
  .a_qkv_wr_token(l_qkv_wr_token),
  .a_qkv_wr_half(l_qkv_wr_half),
  .a_qkv_wr_data(l_qkv_wr_data),
  .a_start_valid(l_start_valid),
  .a_start_ready(l_start_ready),
  .a_start_request_id(l_start_request_id),
  .a_start_generation(l_start_generation),
  .a_reject_valid(l_reject_valid),
  .a_reject_code(l_reject_code),
  .a_abort_valid(l_abort_valid),
  .a_abort_ready(l_abort_ready),
  .a_qkv_read_grant(l_qkv_read_grant),
  .a_ps_grant(l_ps_grant),
  .a_g_grant(l_g_grant),
  .a_context_grant(l_context_grant),
  .a_fp_grant(l_fp_grant),
  .a_sfu_grant(l_sfu_grant),
  .a_exp_grant(l_exp_grant),
  .a_div_grant(l_div_grant),
  .a_rope_write_grant(l_rope_write_grant),
  .a_done_valid(l_done_valid),
  .a_done_ready(l_done_ready),
  .a_done_request_id(l_done_request_id),
  .a_done_generation(l_done_generation),
  .a_done_status(l_done_status),
  .a_done_cycles(l_done_cycles),
  .a_rope_cycles(l_rope_cycles),
  .a_head_completed(l_head_completed),
  .a_head_context_valid(l_head_context_valid),
  .a_active_head(l_active_head),
  .a_error_valid(l_error_valid),
  .a_error_tuple(l_error_tuple),
  .a_check_completed(l_check_completed),
  .a_check_unreachable(l_check_unreachable),
  .a_check_dominated(l_check_dominated),
  .a_av_check_completed(l_av_check_completed),
  .a_av_check_unreachable(l_av_check_unreachable),
  .a_av_check_dominated(l_av_check_dominated),
  .a_result_rd_valid(l_result_rd_valid),
  .a_result_rd_ready(l_result_rd_ready),
  .a_result_rd_generation(l_result_rd_generation),
  .a_result_rd_tag(l_result_rd_tag),
  .a_result_rd_head(l_result_rd_head),
  .a_result_rd_query(l_result_rd_query),
  .a_result_rd_half(l_result_rd_half),
  .a_result_rsp_valid(l_result_rsp_valid),
  .a_result_rsp_ready(l_result_rsp_ready),
  .a_result_rsp_tag(l_result_rsp_tag),
  .a_result_rsp_data(l_result_rsp_data),
  .a_result_discard_valid(l_result_discard_valid),
  .a_result_discard_ready(l_result_discard_ready),
  .a_result_discard_generation(l_result_discard_generation),
  .a_context_discarded(l_context_discarded),
  .a_producer_done_cycles(l_producer_done_cycles),
  .a_context_release_cycles(l_context_release_cycles),
  .a_prepare_cancel_valid(l_prepare_cancel_valid),
  .a_prepare_cancel_ready(l_prepare_cancel_ready),
  .a_prepare_cancel_request_id(l_prepare_cancel_request_id),
  .a_prepare_cancel_generation(l_prepare_cancel_generation),
  .a_prepare_cancel_epoch(l_prepare_cancel_epoch),
  .a_prepare_cancel_rsp_valid(l_prepare_cancel_rsp_valid),
  .a_prepare_cancel_rsp_ready(l_prepare_cancel_rsp_ready),
  .a_prepare_cancel_rsp_request_id(l_prepare_cancel_rsp_request_id),
  .a_prepare_cancel_rsp_generation(l_prepare_cancel_rsp_generation),
  .a_prepare_cancel_rsp_epoch(l_prepare_cancel_rsp_epoch),
  .a_prepare_cancel_rsp_status(l_prepare_cancel_rsp_status),
  .a_layer_idle(l_layer_idle),
  .a_check_coverage_fault(l_check_coverage_fault),
  .a_check_first_conflict(l_check_first_conflict),
  .g_producer_cancel_valid(g_producer_cancel_valid),
  .g_producer_cancel_ready(g_producer_cancel_ready),
  .g_producer_cancel_request_id(g_producer_cancel_request_id),
  .g_producer_cancel_generation(g_producer_cancel_generation),
  .g_producer_cancel_epoch(g_producer_cancel_epoch),
  .g_producer_cancel_reject_valid(g_producer_cancel_reject_valid),
  .g_cmd_valid(g_cmd_valid),
  .g_cmd_ready(g_cmd_ready),
  .g_cmd_request_id(g_cmd_request_id),
  .g_cmd_generation(g_cmd_generation),
  .g_cmd_epoch(g_cmd_epoch),
  .g_fill_valid(g_fill_valid),
  .g_fill_ready(g_fill_ready),
  .g_fill_request_id(g_fill_request_id),
  .g_fill_generation(g_fill_generation),
  .g_fill_epoch(g_fill_epoch),
  .g_fill_slot(g_fill_slot),
  .g_fill_half(g_fill_half),
  .g_fill_s(g_fill_s),
  .g_fill_row(g_fill_row),
  .g_fill_data(g_fill_data),
  .g_fill_reject_valid(g_fill_reject_valid),
  .g_fill_reject_code(g_fill_reject_code),
  .g_out_valid(g_out_valid),
  .g_out_ready(g_out_ready),
  .g_out_data(g_out_data),
  .g_out_status(g_out_status),
  .g_out_tag(g_out_tag),
  .g_out_s(g_out_s),
  .g_out_row(g_out_row),
  .g_out_chunk(g_out_chunk),
  .g_done_valid(g_done_valid),
  .g_done_ready(g_done_ready),
  .g_done_cancelled(g_done_cancelled),
  .g_done_status(g_done_status),
  .g_done_error_rank(g_done_error_rank),
  .g_done_error_row(g_done_error_row),
  .g_done_error_column(g_done_error_column),
  .g_rsp_request_id(g_rsp_request_id),
  .g_rsp_generation(g_rsp_generation),
  .g_rsp_epoch(g_rsp_epoch),
  .g_discard_valid(g_discard_valid),
  .g_discard_ready(g_discard_ready),
  .g_discard_request_id(g_discard_request_id),
  .g_discard_generation(g_discard_generation),
  .g_discard_epoch(g_discard_epoch),
  .g_discard_reject_valid(g_discard_reject_valid),
  .g_engine_idle(g_engine_idle),
  .g_active(g_active),
  .g_needs_discard(g_needs_discard),
  .g_protocol_fault(g_protocol_fault),
  .g_slot_active(g_slot_active),
  .g_slot_ready(g_slot_ready),
  .g_slot_s(g_slot_s),
  .g_slot_consumed_vectors(g_slot_consumed_vectors),
  .g_slot_math_pending(g_slot_math_pending),
  .g_slot_sfu_debt(g_slot_sfu_debt),
  .g_slot_fp_debt(g_slot_fp_debt),
  .g_covered(g_covered),
  .g_evaluated(g_evaluated),
  .ln_gamma_begin_valid(v2_ln_gamma_begin_valid),
  .ln_gamma_begin_ready(v2_ln_gamma_begin_ready),
  .ln_gamma_model(v2_ln_gamma_model),
  .ln_gamma_key(v2_ln_gamma_key),
  .ln_gamma_valid(v2_ln_gamma_valid),
  .ln_gamma_ready(v2_ln_gamma_ready),
  .ln_gamma_chunk(v2_ln_gamma_chunk),
  .ln_gamma_data(v2_ln_gamma_data),
  .ln_gamma_done_valid(v2_ln_gamma_done_valid),
  .ln_gamma_done_ready(v2_ln_gamma_done_ready),
  .ln_gamma_done_error(v2_ln_gamma_done_error),
  .ln_gamma_loaded(v2_ln_gamma_loaded),
  .ln_done_valid(v2_ln_done_valid),
  .ln_done_error(v2_ln_done_error),
  .ln_error_stage(v2_ln_error_stage),
  .ln_error_level(v2_ln_error_level),
  .ln_error_row(v2_ln_error_row),
  .ln_error_node(v2_ln_error_node),
  .ln_reject_valid(v2_ln_reject_valid),
  .ln_reject_code(v2_ln_reject_code),
  .ln_active(v2_ln_active),
  .ln_debt_clear(v2_ln_debt_clear),
  .ln_trace_add_valid(v2_ln_trace_add_valid),
  .ln_trace_add_meta(v2_ln_trace_add_meta),
  .ln_trace_mul_valid(v2_ln_trace_mul_valid),
  .ln_trace_mul_meta(v2_ln_trace_mul_meta),
  .ln_trace_scalar_valid(v2_ln_trace_scalar_valid),
  .ln_trace_scalar_ctx(v2_ln_trace_scalar_ctx),
  .ln_trace_scalar_data(v2_ln_trace_scalar_data),
  .ln_trace_row_start(v2_ln_trace_row_start),
  .ln_trace_row(v2_ln_trace_row),
  .ln_ctx_active(v2_ln_ctx_active),
  .ln_ctx_row(v2_ln_ctx_row),
  .ln_raw_coverage(v2_ln_raw_coverage),
  .ln_delta_coverage(v2_ln_delta_coverage),
  .ln_cycle_count(v2_ln_cycle_count),
  .ln_peak_add_pending(v2_ln_peak_add_pending),
  .ln_peak_mul_pending(v2_ln_peak_mul_pending),
  .ln_reject_ready(v2_ln_reject_ready),
  .ln_cancel_valid(v2_ln_cancel_valid),
  .ln_cancel_ready(v2_ln_cancel_ready),
  .ln_cancel_request_id(v2_ln_cancel_request_id),
  .ln_cancel_generation(v2_ln_cancel_generation),
  .ln_cancel_epoch(v2_ln_cancel_epoch),
  .ln_done_kind(v2_ln_done_kind),
  .ln_cancel_rsp_valid(v2_ln_cancel_rsp_valid),
  .ln_protocol_fault(v2_ln_protocol_fault),
  .ln_protocol_code(v2_ln_protocol_code),
  .ln_protocol_location(v2_ln_protocol_location),
  .ln_error_class(v2_ln_error_class),
  .ln_error_check(v2_ln_error_check),
  .vector_start_valid(v2_vector_start_valid),
  .vector_start_ready(v2_vector_start_ready),
  .vector_start_op(v2_vector_start_op),
  .vector_start_request_id(v2_vector_start_request_id),
  .vector_start_generation(v2_vector_start_generation),
  .vector_start_epoch(v2_vector_start_epoch),
  .vector_start_reject_valid(v2_vector_start_reject_valid),
  .vector_done_valid(v2_vector_done_valid),
  .vector_done_ready(v2_vector_done_ready),
  .vector_done_status(v2_vector_done_status),
  .vector_done_error_row(v2_vector_done_error_row),
  .vector_done_error_column(v2_vector_done_error_column),
  .vector_idle(v2_vector_idle),
  .vector_issued_vectors(v2_vector_issued_vectors),
  .vector_retired_vectors(v2_vector_retired_vectors),
  .coeff_bind_valid(coeff_bind_valid&&coeff_offer_window),
  .coeff_bind_ready(raw_coeff_bind_ready),
  .coeff_bind_model_id(coeff_bind_model_id),
  .coeff_bind_numeric_id(coeff_bind_numeric_id),
  .coeff_bind_table_key(coeff_bind_table_key),
  .coeff_bound_valid(coeff_bound_valid),
  .coeff_bound_model_id(coeff_bound_model_id),
  .coeff_bound_numeric_id(coeff_bound_numeric_id),
  .coeff_bound_table_key(coeff_bound_table_key),
  .coeff_family_complete(coeff_family_complete),
  .coeff_wr_valid(coeff_wr_valid&&coeff_offer_window),
  .coeff_wr_ready(raw_coeff_wr_ready),
  .coeff_wr_model_id(coeff_wr_model_id),
  .coeff_wr_numeric_id(coeff_wr_numeric_id),
  .coeff_wr_table_key(coeff_wr_table_key),
  .coeff_wr_table(coeff_wr_table),
  .coeff_wr_row(coeff_wr_row),
  .coeff_wr_half(coeff_wr_half),
  .coeff_wr_data(coeff_wr_data),
  .coeff_wr_reject_valid(coeff_wr_reject_valid),
  .coeff_wr_reject_code(coeff_wr_reject_code),
  .coeff_wr_nonfinite_lane(coeff_wr_nonfinite_lane),
  .resident_ln_start_valid(v2_resident_ln_start_valid),
  .resident_ln_start_ready(v2_resident_ln_start_ready),
  .resident_ln_rows(v2_resident_ln_rows),
  .resident_ln_use_gamma(v2_resident_ln_use_gamma),
  .resident_ln_model(v2_resident_ln_model),
  .resident_ln_key(v2_resident_ln_key),
  .resident_ln_done_valid(v2_resident_ln_done_valid),
  .resident_ln_done_ready(v2_resident_ln_done_ready),
  .resident_ln_done_status(v2_resident_ln_done_status),
  .resident_ln_done_kind(v2_resident_ln_done_kind),
  .resident_ln_source_qualified(v2_resident_ln_source_qualified),
  .resident_ln_issued_vectors(v2_resident_ln_issued_vectors),
  .resident_ln_written_vectors(v2_resident_ln_written_vectors),
  .ext_fp_select(v2_ext_fp_select),
  .ext_div_select(v2_ext_div_select),
  .ext_bind_select(v2_ext_bind_select),
  .ext_ps_select(v2_ext_ps_select),
  .ext_context_select(v2_ext_context_select),
  .ext_res_st_bind_valid(r_res_st_bind_valid),
  .ext_res_st_bind_ready(r_res_st_bind_ready),
  .ext_res_st_bind_request_id(r_res_st_bind_request_id),
  .ext_res_st_bind_generation(r_res_st_bind_generation),
  .ext_res_st_bind_epoch(r_res_st_bind_epoch),
  .ext_res_st_bind_head(r_res_st_bind_head),
  .ext_res_st_bind_phase(r_res_st_bind_phase),
  .ext_res_st_op_request_id(r_res_st_op_request_id),
  .ext_res_st_op_generation(r_res_st_op_generation),
  .ext_res_st_op_epoch(r_res_st_op_epoch),
  .ext_res_st_op_phase(r_res_st_op_phase),
  .ext_res_st_rsp_request_id(r_res_st_rsp_request_id),
  .ext_res_st_rsp_generation(r_res_st_rsp_generation),
  .ext_res_st_rsp_epoch(r_res_st_rsp_epoch),
  .ext_res_st_rsp_head(r_res_st_rsp_head),
  .ext_res_st_rsp_phase(r_res_st_rsp_phase),
  .ext_res_st_ps_wr_valid(r_res_st_ps_wr_valid),
  .ext_res_st_ps_wr_ready(r_res_st_ps_wr_ready),
  .ext_res_st_ps_wr_mask(r_res_st_ps_wr_mask),
  .ext_res_st_ps_wr_addr(r_res_st_ps_wr_addr),
  .ext_res_st_ps_wr_data(r_res_st_ps_wr_data),
  .ext_res_st_ps_wr_tag(r_res_st_ps_wr_tag),
  .ext_res_st_ps_wr_rsp_valid(r_res_st_ps_wr_rsp_valid),
  .ext_res_st_ps_wr_rsp_ready(r_res_st_ps_wr_rsp_ready),
  .ext_res_st_ps_wr_rsp_tag(r_res_st_ps_wr_rsp_tag),
  .ext_res_st_ps_rd_valid(r_res_st_ps_rd_valid),
  .ext_res_st_ps_rd_ready(r_res_st_ps_rd_ready),
  .ext_res_st_ps_rd_mask(r_res_st_ps_rd_mask),
  .ext_res_st_ps_rd_addr(r_res_st_ps_rd_addr),
  .ext_res_st_ps_rd_tag(r_res_st_ps_rd_tag),
  .ext_res_st_ps_rd_rsp_valid(r_res_st_ps_rd_rsp_valid),
  .ext_res_st_ps_rd_rsp_ready(r_res_st_ps_rd_rsp_ready),
  .ext_res_st_ps_rd_rsp_data(r_res_st_ps_rd_rsp_data),
  .ext_res_st_ps_rd_rsp_mask(r_res_st_ps_rd_rsp_mask),
  .ext_res_st_ps_rd_rsp_tag(r_res_st_ps_rd_rsp_tag),
  .ext_res_st_context_wr_valid(r_res_st_context_wr_valid),
  .ext_res_st_context_wr_ready(r_res_st_context_wr_ready),
  .ext_res_st_context_wr_mask(r_res_st_context_wr_mask),
  .ext_res_st_context_wr_addr(r_res_st_context_wr_addr),
  .ext_res_st_context_wr_data(r_res_st_context_wr_data),
  .ext_res_st_context_wr_tag(r_res_st_context_wr_tag),
  .ext_res_st_context_wr_rsp_valid(r_res_st_context_wr_rsp_valid),
  .ext_res_st_context_wr_rsp_ready(r_res_st_context_wr_rsp_ready),
  .ext_res_st_context_wr_rsp_tag(r_res_st_context_wr_rsp_tag),
  .ext_res_st_context_rd_valid(r_res_st_context_rd_valid),
  .ext_res_st_context_rd_ready(r_res_st_context_rd_ready),
  .ext_res_st_context_rd_mask(r_res_st_context_rd_mask),
  .ext_res_st_context_rd_addr(r_res_st_context_rd_addr),
  .ext_res_st_context_rd_tag(r_res_st_context_rd_tag),
  .ext_res_st_context_rd_rsp_valid(r_res_st_context_rd_rsp_valid),
  .ext_res_st_context_rd_rsp_ready(r_res_st_context_rd_rsp_ready),
  .ext_res_st_context_rd_rsp_data(r_res_st_context_rd_rsp_data),
  .ext_res_st_context_rd_rsp_mask(r_res_st_context_rd_rsp_mask),
  .ext_res_st_context_rd_rsp_tag(r_res_st_context_rd_rsp_tag),
  .ext_res_st_idle(r_res_st_idle),
  .ext_res_fp_lease_valid(r_res_fp_lease_valid),
  .ext_res_fp_lease_ready(r_res_fp_lease_ready),
  .ext_res_fp_lease_request_id(r_res_fp_lease_request_id),
  .ext_res_fp_lease_generation(r_res_fp_lease_generation),
  .ext_res_fp_lease_epoch(r_res_fp_lease_epoch),
  .ext_res_fp_lease_head(r_res_fp_lease_head),
  .ext_res_fp_lease_phase(r_res_fp_lease_phase),
  .ext_res_fp_release_valid(r_res_fp_release_valid),
  .ext_res_fp_release_ready(r_res_fp_release_ready),
  .ext_res_fp_release_phase(r_res_fp_release_phase),
  .ext_res_fp_release_epoch(r_res_fp_release_epoch),
  .ext_res_fp_phase_debt_clear(r_res_fp_phase_debt_clear),
  .ext_res_fp_lease_active(r_res_fp_lease_active),
  .ext_res_fp_draining(r_res_fp_draining),
  .ext_res_fp_rsp_request_id(r_res_fp_rsp_request_id),
  .ext_res_fp_rsp_generation(r_res_fp_rsp_generation),
  .ext_res_fp_rsp_epoch(r_res_fp_rsp_epoch),
  .ext_res_fp_rsp_head(r_res_fp_rsp_head),
  .ext_res_fp_rsp_phase(r_res_fp_rsp_phase),
  .ext_res_fp_mul_req_valid(r_res_fp_mul_req_valid),
  .ext_res_fp_mul_req_ready(r_res_fp_mul_req_ready),
  .ext_res_fp_mul_req_phase(r_res_fp_mul_req_phase),
  .ext_res_fp_mul_req_epoch(r_res_fp_mul_req_epoch),
  .ext_res_fp_mul_req_tag(r_res_fp_mul_req_tag),
  .ext_res_fp_mul_a(r_res_fp_mul_a),
  .ext_res_fp_mul_b(r_res_fp_mul_b),
  .ext_res_fp_mul_rsp_valid(r_res_fp_mul_rsp_valid),
  .ext_res_fp_mul_rsp_ready(r_res_fp_mul_rsp_ready),
  .ext_res_fp_mul_rsp_tag(r_res_fp_mul_rsp_tag),
  .ext_res_fp_mul_rsp_data(r_res_fp_mul_rsp_data),
  .ext_res_fp_add_req_valid(r_res_fp_add_req_valid),
  .ext_res_fp_add_req_is_root(r_res_fp_add_req_is_root),
  .ext_res_fp_add_req_ready(r_res_fp_add_req_ready),
  .ext_res_fp_add_req_phase(r_res_fp_add_req_phase),
  .ext_res_fp_add_req_epoch(r_res_fp_add_req_epoch),
  .ext_res_fp_add_req_tag(r_res_fp_add_req_tag),
  .ext_res_fp_add_a(r_res_fp_add_a),
  .ext_res_fp_add_b(r_res_fp_add_b),
  .ext_res_fp_add_rsp_valid(r_res_fp_add_rsp_valid),
  .ext_res_fp_add_rsp_ready(r_res_fp_add_rsp_ready),
  .ext_res_fp_add_rsp_tag(r_res_fp_add_rsp_tag),
  .ext_res_fp_add_rsp_data(r_res_fp_add_rsp_data),
  .ext_res_fp_mul_pending(r_res_fp_mul_pending),
  .ext_res_fp_add_pending(r_res_fp_add_pending),
  .ext_res_fp_protocol_fault(r_res_fp_protocol_fault),
  .ext_res_div_lease_valid(r_res_div_lease_valid),
  .ext_res_div_lease_ready(r_res_div_lease_ready),
  .ext_res_div_lease_request_id(r_res_div_lease_request_id),
  .ext_res_div_lease_generation(r_res_div_lease_generation),
  .ext_res_div_lease_epoch(r_res_div_lease_epoch),
  .ext_res_div_lease_head(r_res_div_lease_head),
  .ext_res_div_lease_phase(r_res_div_lease_phase),
  .ext_res_div_release_ready(r_res_div_release_ready),
  .ext_res_div_draining(r_res_div_draining),
  .ext_res_div_rsp_request_id(r_res_div_rsp_request_id),
  .ext_res_div_rsp_generation(r_res_div_rsp_generation),
  .ext_res_div_rsp_epoch(r_res_div_rsp_epoch),
  .ext_res_div_rsp_head(r_res_div_rsp_head),
  .ext_res_div_rsp_phase(r_res_div_rsp_phase),
  .ext_res_div_protocol_reject_code(r_res_div_protocol_reject_code),
  .ext_res_div_rsp_lane_mask(r_res_div_rsp_lane_mask),
  .ext_res_div_release_valid(r_res_div_release_valid),
  .ext_res_div_release_phase(r_res_div_release_phase),
  .ext_res_div_release_epoch(r_res_div_release_epoch),
  .ext_res_div_phase_debt_clear(r_res_div_phase_debt_clear),
  .ext_res_div_lease_active(r_res_div_lease_active),
  .ext_res_div_req_valid(r_res_div_req_valid),
  .ext_res_div_req_ready(r_res_div_req_ready),
  .ext_res_div_req_generation(r_res_div_req_generation),
  .ext_res_div_req_epoch(r_res_div_req_epoch),
  .ext_res_div_req_phase(r_res_div_req_phase),
  .ext_res_div_req_lane_mask(r_res_div_req_lane_mask),
  .ext_res_div_req_tag(r_res_div_req_tag),
  .ext_res_div_req_a(r_res_div_req_a),
  .ext_res_div_req_b(r_res_div_req_b),
  .ext_res_div_protocol_reject_valid(r_res_div_protocol_reject_valid),
  .ext_res_div_rsp_valid(r_res_div_rsp_valid),
  .ext_res_div_rsp_ready(r_res_div_rsp_ready),
  .ext_res_div_rsp_tag(r_res_div_rsp_tag),
  .ext_res_div_rsp_numeric_error(r_res_div_rsp_numeric_error),
  .ext_res_div_rsp_data(r_res_div_rsp_data),
  .ext_res_div_pending_vectors(r_res_div_pending_vectors),
  .ext_res_div_in_flight_vectors(r_res_div_in_flight_vectors),
  .ext_res_div_in_flight_scalars(r_res_div_in_flight_scalars),
  .ext_res_div_protocol_fault(r_res_div_protocol_fault),
  .g_tanh_lease_valid(v2_g_tanh_lease_valid),
  .g_tanh_lease_ready(tanh_lease_ready),
  .g_tanh_lease_request_id(v2_g_tanh_lease_request_id),
  .g_tanh_lease_generation(v2_g_tanh_lease_generation),
  .g_tanh_lease_epoch(v2_g_tanh_lease_epoch),
  .g_tanh_lease_phase(v2_g_tanh_lease_phase),
  .g_tanh_release_valid(v2_g_tanh_release_valid),
  .g_tanh_release_ready(tanh_release_ready),
  .g_tanh_release_phase(v2_g_tanh_release_phase),
  .g_tanh_release_epoch(v2_g_tanh_release_epoch),
  .g_tanh_phase_debt_clear(v2_g_tanh_phase_debt_clear),
  .g_tanh_lease_active(tanh_lease_active),
  .g_tanh_draining(tanh_draining),
  .g_tanh_pending_vectors(tanh_pending),
  .g_tanh_in_flight_vectors(tanh_flight)
);

endmodule
