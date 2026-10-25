`timescale 1ns/1ps
module laya_m007_single_parent_v2 #(
 parameter logic [127:0] MODEL_ID=128'h6eb6ef58bc4f99bd9db40381604108af,
 parameter logic [127:0] NUMERIC_ID=128'haeb13e7937d29fe6a2c68c407249f294,
 parameter logic [127:0] TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965,
 parameter logic [127:0] GRAPH_ID=128'hf33f7848434b73048f957dcd232e1bd4,
 parameter logic [127:0] LAYOUT_ID=128'h2d848b5fb78236c795cb1d442f088393,
 parameter logic [127:0] BUILD_ID=128'h7209eb09c3f265363cfb274f7790a733
)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,
 input logic [63:0] cmd_request,input logic [31:0] cmd_generation,cmd_epoch,
 input logic [127:0] cmd_model_id,cmd_numeric_id,cmd_table_key,cmd_graph_id,cmd_layout_id,cmd_build_id,
 input logic [2:0] cmd_kind,input logic [4:0] cmd_layer,input logic [127:0] cmd_mask,
 input logic [1:0][31:0] cmd_tensor,
 input logic [1:0][3:0][63:0] cmd_base,cmd_span,
 input logic desc_valid,output logic desc_ready,
 input logic [63:0] desc_request,input logic [31:0] desc_generation,desc_source_epoch,
 input logic [4:0] desc_global_layer,input logic desc_pair_kind,desc_slot,
 input logic [31:0] desc_tensor,input logic [3:0][63:0] desc_base,desc_span,
 output logic desc_reject_valid,output logic [3:0] desc_reject_code,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 output logic input_reject_valid,output logic [3:0] input_reject_code,
 input logic producer_fail_valid,input logic [95:0] producer_fail_tuple,
 input logic [63:0] producer_fail_request,input logic [31:0] producer_fail_generation,producer_fail_epoch,
 output logic producer_fail_ready,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,
 output logic done_valid,input logic done_ready,output logic [7:0] done_status,
 output logic [2:0] error_domain,output logic [95:0] error_tuple,
 output logic [7:0] source_status,
 input logic [127:0] bias_model_id,bias_numeric_id,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [5:0] parent_state,output logic [31:0] elapsed_cycles,
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
 input logic  coef_cfg_valid,
 output logic  coef_cfg_ready,
 input logic [63:0] coef_model,
 input logic [63:0] coef_request,
 input logic [31:0] coef_tensor,
 input logic [31:0] coef_generation,
 input logic [31:0] coef_epoch,
 input logic [15:0] coef_n,
 input logic  coef_wr_valid,
 output logic  coef_wr_ready,
 input logic [6:0] coef_wr_addr,
 input logic [31:0][31:0] coef_wr_data,
 output logic  coef_rsp_valid,
 input logic  coef_rsp_ready,
 output logic [1:0] coef_status,
 output logic [15:0] coef_error_col,
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
 function automatic logic [31:0] tensor_key(input logic [1:0] k,input logic [4:0] l,input logic wo);
  if(k==3)return l==0?(wo?32'd88:32'd60):32'hffffffff;
  case({k==2,l,wo})
   7'd0:return 32'd4; // qkv.0.weight
   7'd2:return 32'd5; // qkv.1.weight
   7'd4:return 32'd6; // qkv.2.weight
   7'd6:return 32'd7; // qkv.3.weight
   7'd8:return 32'd8; // qkv.4.weight
   7'd10:return 32'd9; // qkv.5.weight
   7'd12:return 32'd10; // qkv.6.weight
   7'd14:return 32'd11; // qkv.7.weight
   7'd16:return 32'd12; // qkv.8.weight
   7'd18:return 32'd13; // qkv.9.weight
   7'd20:return 32'd14; // qkv.10.weight
   7'd22:return 32'd15; // qkv.11.weight
   7'd24:return 32'd16; // qkv.12.weight
   7'd26:return 32'd17; // qkv.13.weight
   7'd28:return 32'd18; // qkv.14.weight
   7'd30:return 32'd19; // qkv.15.weight
   7'd32:return 32'd20; // qkv.16.weight
   7'd34:return 32'd21; // qkv.17.weight
   7'd36:return 32'd22; // qkv.18.weight
   7'd38:return 32'd23; // qkv.19.weight
   7'd40:return 32'd24; // qkv.20.weight
   7'd42:return 32'd25; // qkv.21.weight
   7'd44:return 32'd26; // qkv.22.weight
   7'd46:return 32'd27; // qkv.23.weight
   7'd48:return 32'd28; // qkv.24.weight
   7'd50:return 32'd29; // qkv.25.weight
   7'd52:return 32'd30; // qkv.26.weight
   7'd54:return 32'd31; // qkv.27.weight
   7'd1:return 32'd32; // wo.0.weight
   7'd3:return 32'd33; // wo.1.weight
   7'd5:return 32'd34; // wo.2.weight
   7'd7:return 32'd35; // wo.3.weight
   7'd9:return 32'd36; // wo.4.weight
   7'd11:return 32'd37; // wo.5.weight
   7'd13:return 32'd38; // wo.6.weight
   7'd15:return 32'd39; // wo.7.weight
   7'd17:return 32'd40; // wo.8.weight
   7'd19:return 32'd41; // wo.9.weight
   7'd21:return 32'd42; // wo.10.weight
   7'd23:return 32'd43; // wo.11.weight
   7'd25:return 32'd44; // wo.12.weight
   7'd27:return 32'd45; // wo.13.weight
   7'd29:return 32'd46; // wo.14.weight
   7'd31:return 32'd47; // wo.15.weight
   7'd33:return 32'd48; // wo.16.weight
   7'd35:return 32'd49; // wo.17.weight
   7'd37:return 32'd50; // wo.18.weight
   7'd39:return 32'd51; // wo.19.weight
   7'd41:return 32'd52; // wo.20.weight
   7'd43:return 32'd53; // wo.21.weight
   7'd45:return 32'd54; // wo.22.weight
   7'd47:return 32'd55; // wo.23.weight
   7'd49:return 32'd56; // wo.24.weight
   7'd51:return 32'd57; // wo.25.weight
   7'd53:return 32'd58; // wo.26.weight
   7'd55:return 32'd59; // wo.27.weight
   7'd64:return 32'd117; // head_qkv.0.weight
   7'd66:return 32'd119; // head_qkv.1.weight
   7'd65:return 32'd121; // head_wo.0.weight
   7'd67:return 32'd123; // head_wo.1.weight
   default:return 0;
  endcase
 endfunction logic  l_prepare_valid;
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

 localparam [5:0] IDLE=0,PREP=1,QSUB=2,QRUN=3,QMSUB=4,QMRUN=5,LSTART=6,LRUN=7,CSUB=8,CRUN=9,CDRAIN=10,WMSUB=11,WMRUN=12,PCANCEL=13,PCWAIT=14,DISCARD=15,DISCWAIT=16,FINISH=17,ACANCEL=18,ACWAIT=19;
 localparam [5:0] F_ARENA=20,F_NQSUB=21,F_NQRUN=22,F_WISUB=23,F_GQSUB=24,F_RUN=25,F_CLOSE=26,F_QDRAIN=27,F_ABORT=28,F_DISCARD=29,F_RELEASE=30,F_RETURN=31;
  logic [5:0] state;
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
  wire encoder0_mode=kind==3'd4;
  wire ffn_mode=kind==3'd3||(encoder0_mode&&tensor_id[0]==32'd60);
  wire ffn_state=state==F_ARENA||state==F_NQSUB||state==F_NQRUN||state==F_WISUB||state==F_GQSUB||state==F_RUN||state==F_CLOSE||state==F_QDRAIN||state==F_ABORT||state==F_DISCARD||state==F_RELEASE||state==F_RETURN;

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

// Pure combinational helpers for the independent Encoder0 parent v2.
// Include inside laya_m007_single_parent_v2; no state/payload declaration.
// Authority: source/m007_residual_encoder30_20261023.md section11.
// Compilation and integrated verification remain separate R006 attempts.
function automatic logic encoder0_f32_finite(input logic [31:0] value);
  return value[30:23] != 8'hff;
endfunction

// {any_nonfinite, smallest_nonfinite_lane}; lane0 has graph priority.
function automatic logic [5:0] encoder0_first_nonfinite(
  input logic [31:0][31:0] values
);
  logic [5:0] result;
  result = 6'b0;
  for (int lane = 31; lane >= 0; lane = lane - 1)
    if (!encoder0_f32_finite(values[lane])) result = {1'b1, 5'(lane)};
  return result;
endfunction

// Tensor metadata remains in the original two descriptor registers.
// This validates a replacement record before any overwrite handshake.
function automatic logic encoder0_ffn_descriptor_ok(
  input logic slot,
  input logic [31:0] tensor,
  input logic [3:0][63:0] bases,
  input logic [3:0][63:0] spans
);
  logic accepted;
  logic [64:0] endpoint;
  accepted = tensor == (slot ? 32'd88 : 32'd60);
  for (int channel = 0; channel < 4; channel = channel + 1) begin
    endpoint = {1'b0, bases[channel]} + {1'b0, spans[channel]};
    if (bases[channel][11:0] != 0 ||
        spans[channel] < (slot ? 64'd755712 : 64'd1511424) ||
        endpoint[64]) accepted = 1'b0;
  end
  return accepted;
endfunction

// All source inputs are ordered row-major; upper bits must be zero.
function automatic logic encoder0_input_coordinate_ok(
  input logic [12:0] accepted_count,
  input logic [7:0] row,
  input logic [7:0] group_index
);
  return accepted_count < 13'd4096 &&
         row == {1'b0, accepted_count[11:5]} &&
         group_index == {3'b0, accepted_count[4:0]};
endfunction

function automatic logic encoder0_projection_coordinate_ok(
  input logic [6:0] row,
  input logic [15:0] column
);
  return column < 16'd1024 && column[4:0] == 0;
endfunction

// The full public kind never passes through a two-bit legacy truncation.
function automatic logic [1:0] encoder0_island_kind(
  input logic [2:0] public_kind,
  input logic ffn_island
);
  if (public_kind == 3'd4) return ffn_island ? 2'd3 : 2'd0;
  case (public_kind)
    3'd0: return 2'd0;
    3'd1: return 2'd1;
    3'd2: return 2'd2;
    3'd3: return 2'd3;
    default: return 2'd0; // Invalid kinds are rejected before any island.
  endcase
endfunction

  localparam logic [127:0] ENCODER0_BUILD_ID=128'hd92a1f8e927c3051289016db36f20d27;
  localparam logic [5:0]
    E_H_LOAD=32,E_H_READY=33,E_WO_LEASE=34,E_WO_POST=35,
    E_REFILL0=36,E_REFILL1=37,E_RA_LEASE=38,E_RA_OWNER=39,
    E_RA_SUB=40,E_RA_RUN=41,E_RA_RELEASE=42,E_LN_LEASE=43,
    E_LN_OWNER=44,E_LN_SUB=45,E_LN_RUN=46,E_LN_RELEASE=47,
    E_FF_LEASE=48,E_FF_OWNER=49,E_FF_POST=50,E_RF_LEASE=51,
    E_RF_OWNER=52,E_RF_SUB=53,E_RF_RUN=54,E_RF_RELEASE=55,
    E_EXPORT=56,E_EXPORT_DRAIN=57,E_ABORT=58,E_FINAL_A=59;
  logic [12:0] resident_issue,resident_sink;
  logic [2:0] operation_code;
  wire [31:0] operation_epoch=encoder0_mode?epoch+{23'b0,layer_index,4'b0}+{29'b0,operation_code}:epoch;
  wire resident_source_phase=state==QRUN||state==F_NQRUN;
  wire resident_source_q=state==F_NQRUN;
  wire resident_source_valid=resident_source_q?v2_q_rsp_valid:v2_h_rsp_valid;
  wire [31:0][31:0] resident_source_data=resident_source_q?v2_q_rsp_data:v2_h_rsp_data;
  wire [11:0] resident_source_addr=resident_source_q?v2_q_rsp_addr:v2_h_rsp_addr;
  wire internal_source_fire=resident_source_phase&&q_in_valid&&q_in_ready;
  wire [5:0] input_bad=encoder0_first_nonfinite(in_data);
  wire projection_identity_ok=m_out_request==request_id&&m_out_generation==generation&&m_out_epoch==operation_epoch&&encoder0_projection_coordinate_ok(m_out_row,m_out_col);
  wire desc_window=encoder0_mode&&(state==E_REFILL0||state==E_REFILL1);
  wire desc_identity_ok=desc_request==request_id&&desc_generation==generation&&desc_source_epoch==epoch&&desc_global_layer==0&&desc_pair_kind==1&&desc_slot==(state==E_REFILL1);
  wire desc_record_ok=encoder0_ffn_descriptor_ok(desc_slot,desc_tensor,desc_base,desc_span);
  wire resident_retired=m_cmd_ready&&q_cmd_ready&&!m_done_valid&&!q_done_valid&&v2_shared_resources_idle&&v2_resident_bank_idle&&v2_ln_provider_idle;
  wire h_load_fire=encoder0_mode&&state==E_H_LOAD&&in_valid&&in_ready;
  wire vector_done_fire=v2_vector_done_valid&&v2_vector_done_ready;
  wire resident_ln_done_fire=v2_resident_ln_done_valid&&v2_resident_ln_done_ready;
  wire ln_reject_fire=v2_ln_reject_valid&&v2_ln_reject_ready;
  function automatic logic [95:0] encoder0_error_envelope(
    input logic [7:0] stage_id,input logic [6:0] row_id,
    input logic [1:0] class_id,input logic [3:0] check_id,sub_id,
    input logic [9:0] element_id,input logic [3:0] protocol_code_id,
    input logic [7:0] protocol_location_id
  );
    return {stage_id,row_id[6:4],class_id,row_id[3:0],check_id,sub_id,
            element_id,protocol_code_id,protocol_location_id,49'b0};
  endfunction
  // Sourceepoch never changes. Error cleanup keeps the failed operationepoch
  // until all real responses, held terminal and leases retire.
  always_comb begin
    operation_code=ffn_mode?3'd4:3'd1;
    case(state)
      E_H_LOAD,E_H_READY:operation_code=0;
      E_WO_LEASE,E_WO_POST,E_REFILL0,E_REFILL1:operation_code=1;
      E_RA_LEASE,E_RA_OWNER,E_RA_SUB,E_RA_RUN,E_RA_RELEASE:operation_code=2;
      E_LN_LEASE,E_LN_OWNER,E_LN_SUB,E_LN_RUN,E_LN_RELEASE:operation_code=3;
      E_FF_LEASE,E_FF_OWNER,E_FF_POST:operation_code=4;
      E_RF_LEASE,E_RF_OWNER,E_RF_SUB,E_RF_RUN,E_RF_RELEASE:operation_code=5;
      E_EXPORT,E_EXPORT_DRAIN,E_FINAL_A:operation_code=6;
      default:begin end
    endcase
    if((state==E_ABORT||state==E_FINAL_A)&&done_status!=0)begin
      if(error_domain==7)case(error_tuple[95:88])
        8'h80:operation_code=0;
        8'h81:operation_code=2;
        8'h82:operation_code=3;
        8'h83:operation_code=5;
        default:operation_code=ffn_mode?4:1;
      endcase
      else operation_code=producer_failed?0:ffn_mode?4:1;
    end
  end
  assign v2_owner_req=state==F_ARENA||state==E_FF_OWNER?2'd1:
                      state==E_LN_OWNER?2'd2:
                      state==E_RA_OWNER||state==E_RF_OWNER?2'd3:2'd0;
  assign v2_ext_fp_select=matrix_owner;
  assign v2_ext_div_select=front_owner;
  assign v2_ext_bind_select=matrix_owner;
  assign v2_ext_ps_select=matrix_owner;
  assign v2_ext_context_select=1'b0;
  assign v2_resident_owner_valid=encoder0_mode&&state!=IDLE&&state!=FINISH;
  assign v2_resident_owner_request_id=request_id;
  assign v2_resident_owner_generation=generation;
  assign v2_resident_owner_epoch=operation_epoch;
  assign v2_resident_access_request_id=request_id;
  assign v2_resident_access_generation=generation;
  assign v2_resident_access_epoch=operation_epoch;
  assign v2_resident_inputs_ready=encoder0_mode&&done_status==0&&(state==E_RA_SUB||state==E_RA_RUN||state==E_RF_SUB||state==E_RF_RUN);
  assign v2_parent_matrix_retired=m_cmd_ready&&!m_done_valid;
  assign v2_parent_quant_retired=q_cmd_ready&&!q_done_valid;
  assign v2_h_wr_valid=encoder0_mode&&state==E_H_LOAD&&in_valid&&legal_input;
  assign v2_h_wr_addr={in_row[6:0],in_group[4:0]};
  assign v2_h_wr_data=in_data;
  assign v2_h_rd_valid=encoder0_mode&&resident_issue<4096&&((state==QRUN&&!producer_failed)||state==E_EXPORT);
  assign v2_h_rd_addr=resident_issue[11:0];
  assign v2_h_rsp_ready=state==E_ABORT?1'b1:encoder0_mode&&state==QRUN?q_in_ready:encoder0_mode&&state==E_EXPORT?out_ready:1'b0;
  assign v2_q_wr_valid=encoder0_mode&&state==WMRUN&&m_out_valid&&projection_identity_ok;
  assign v2_q_wr_addr={m_out_row,m_out_col[9:5]};
  assign v2_q_wr_data=m_out_data;
  assign v2_q_rd_valid=encoder0_mode&&state==F_NQRUN&&resident_issue<4096&&!producer_failed;
  assign v2_q_rd_addr=resident_issue[11:0];
  assign v2_q_rsp_ready=state==E_ABORT?1'b1:encoder0_mode&&state==F_NQRUN&&q_in_ready;
  assign v2_scratch_lease_valid=encoder0_mode&&(state==E_WO_LEASE||state==E_RA_LEASE||state==E_LN_LEASE||state==E_FF_LEASE||state==E_RF_LEASE)&&resident_retired;
  assign v2_scratch_release_valid=encoder0_mode&&(state==E_WO_POST||state==E_RA_RELEASE||state==E_LN_RELEASE||state==E_FF_POST||state==E_RF_RELEASE||state==E_ABORT)&&resident_retired&&v2_scratch_owner_active;
  assign desc_ready=rst_n&&desc_window&&desc_identity_ok;
  assign desc_reject_valid=rst_n&&desc_valid&&(!desc_window||!desc_identity_ok);
  assign desc_reject_code=!desc_window?4'd1:desc_request!=request_id?4'd2:desc_generation!=generation?4'd3:desc_source_epoch!=epoch?4'd4:desc_global_layer!=0||desc_pair_kind!=1?4'd5:4'd6;
  assign v2_vector_start_valid=state==E_RA_SUB||state==E_RF_SUB;
  assign v2_vector_start_op=2'b0;
  assign v2_vector_start_request_id=request_id;
  assign v2_vector_start_generation=generation;
  assign v2_vector_start_epoch=operation_epoch;
  assign v2_vector_done_ready=state==E_RA_RUN||state==E_RF_RUN;
  assign v2_resident_ln_start_valid=state==E_LN_SUB;
  assign v2_resident_ln_rows=8'd128;
  assign v2_resident_ln_use_gamma=1'b0;
  assign v2_resident_ln_model=MODEL_ID[63:0];
  assign v2_resident_ln_key=32'b0;
  assign v2_resident_ln_done_ready=state==E_LN_RUN||state==E_ABORT;
  assign v2_ln_reject_ready=state==E_LN_RUN;
  assign v2_ln_cancel_valid=state==E_ABORT&&v2_ln_active&&!g_cancel_sent;
  assign v2_ln_cancel_request_id=request_id;
  assign v2_ln_cancel_generation=generation;
  assign v2_ln_cancel_epoch=operation_epoch;
  // PlainLN in this ABI has no gamma producer. The persistent gamma public
  // interface stays entirely within its resource owner, unused by this parent.
  assign v2_ln_gamma_begin_valid=1'b0;
  assign v2_ln_gamma_model=64'b0;
  assign v2_ln_gamma_key=32'b0;
  assign v2_ln_gamma_valid=1'b0;
  assign v2_ln_gamma_chunk=5'b0;
  assign v2_ln_gamma_data='0;
  assign v2_ln_gamma_done_ready=1'b1;
  assign v2_g_tanh_lease_valid=state==F_GQSUB&&!tanh_lease_active&&ws_g_enable;
  assign v2_g_tanh_lease_request_id=request_id;
  assign v2_g_tanh_lease_generation=generation;
  assign v2_g_tanh_lease_epoch=operation_epoch;
  assign v2_g_tanh_lease_phase=3'd1;
  assign v2_g_tanh_release_valid=state==F_RELEASE&&tanh_lease_active&&g_engine_idle&&r_res_st_idle&&tanh_pending==0&&tanh_flight==0;
  assign v2_g_tanh_release_phase=3'd1;
  assign v2_g_tanh_release_epoch=operation_epoch;
  assign v2_g_tanh_phase_debt_clear=g_engine_idle&&r_res_st_idle;
  // Two actual resident counters are reused only at debt-free stage boundaries.
  always_ff @(posedge clk)begin
    if(!rst_n)begin resident_issue<=0;resident_sink<=0;end
    else begin
      if(cmd_valid&&cmd_ready||state==E_H_READY||state==F_NQSUB&&q_cmd_valid&&q_cmd_ready||state==WMSUB&&m_cmd_valid&&m_cmd_ready||state==E_RF_RELEASE&&v2_scratch_release_valid&&v2_scratch_release_ready)begin resident_issue<=0;resident_sink<=0;end
      else begin
        if(v2_h_rd_valid&&v2_h_rd_ready||v2_q_rd_valid&&v2_q_rd_ready)resident_issue<=resident_issue+1'b1;
        if(v2_q_wr_commit||encoder0_mode&&state==E_EXPORT&&out_valid&&out_ready)resident_sink<=resident_sink+1'b1;
      end
    end
  end

 wire producer_fail_fire=producer_fail_valid&&producer_fail_ready;
 wire producer_failure=producer_failed||producer_fail_fire;
 function automatic logic [7:0] matrix_status_map(input logic [2:0] v);
  case(v)0:return 0;1:return 5;2:return 1;default:return 2;endcase
 endfunction
 function automatic logic [7:0] layer_status_map(input logic [7:0] v);
  case(v)0:return 0;1:return 1;2:return 6;default:return 2;endcase
 endfunction
 wire context_phase=state==CSUB||state==CRUN||state==CDRAIN||state==DISCARD||state==DISCWAIT;
 assign matrix_owner=(state==QSUB||state==QRUN||state==QMSUB||state==QMRUN)||state==WMSUB||state==WMRUN||(ffn_state&&state!=F_ARENA&&state!=F_RETURN);
 assign front_owner=matrix_owner||context_phase;
 wire wo_phase=state==WMSUB||state==WMRUN;
 assign legal_input=(!encoder0_mode&&(state==QRUN||state==F_NQRUN)||encoder0_mode&&state==E_H_LOAD)&&!producer_failed&&inputs_accepted<4096&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row=={1'b0,inputs_accepted[11:5]}&&in_group=={3'b0,inputs_accepted[4:0]};
 wire identity_ok=cmd_model_id==MODEL_ID&&cmd_numeric_id==NUMERIC_ID&&cmd_table_key==TABLE_KEY&&cmd_graph_id==GRAPH_ID&&cmd_layout_id==LAYOUT_ID&&((cmd_kind<=3&&cmd_build_id==BUILD_ID)||(cmd_kind==4&&cmd_build_id==ENCODER0_BUILD_ID));
 wire tables_ready=cmd_kind==3||cmd_kind==2||(coeff_bound_valid&&coeff_bound_model_id==MODEL_ID&&coeff_bound_numeric_id==NUMERIC_ID&&coeff_bound_table_key==TABLE_KEY&&coeff_family_complete[cmd_kind==1]);
 logic spans_ok;
 always_comb begin
  spans_ok=1;
  for(int t=0;t<2;t++)for(int p=0;p<4;p++)begin
   if(cmd_base[t][p][11:0]!=0||cmd_span[t][p]<(cmd_kind==3?(t==0?64'd1511424:64'd755712):(t==0?64'd884736:64'd294912))||({1'b0,cmd_base[t][p]}+{1'b0,cmd_span[t][p]})>65'hffffffffffffffff)spans_ok=0;
  end
 end
 wire tensor_ok=cmd_tensor[0]==tensor_key(encoder0_island_kind(cmd_kind,0),cmd_layer,0)&&cmd_tensor[1]==tensor_key(encoder0_island_kind(cmd_kind,0),cmd_layer,1);
 wire bias_identity_ok=bias_model_id==MODEL_ID&&bias_numeric_id==NUMERIC_ID&&coef_model==MODEL_ID[63:0]&&coef_request==(state==IDLE?cmd_request:request_id)&&coef_generation==(state==IDLE?cmd_generation:generation)&&coef_epoch==(state==IDLE?cmd_epoch:epoch)&&coef_tensor==tensor_key(encoder0_island_kind(state==IDLE?cmd_kind:kind,0),state==IDLE?cmd_layer:layer_index,coef_n==1024)&&((coef_n==3072&&state==IDLE)||(coef_n==1024&&(state==IDLE||state==LRUN||state==CSUB||state==CRUN||state==CDRAIN)));
 wire kind_ok=(cmd_kind==0&&cmd_layer<28&&cmd_layer%3==0)||(cmd_kind==1&&cmd_layer<28&&cmd_layer%3!=0)||(cmd_kind==2&&cmd_layer<2)||(cmd_kind==3&&cmd_layer==0)||(cmd_kind==4&&cmd_layer==0&&cmd_epoch<=32'hfffffe00);
 logic c_rd_valid,c_rd_ready,c_rsp_valid,c_rsp_ready,c_out_valid,c_out_ready,c_idle,c_complete,c_fault,c_start_ready;
 logic [31:0] c_rd_generation,c_rd_tag,c_rsp_tag;logic [3:0] c_rd_head;logic [6:0] c_rd_query;logic c_rd_half;
 logic [31:0][31:0] c_rsp_data,c_out_data;logic [7:0] c_out_row,c_out_group;logic [12:0] c_accepted,c_consumed;
 assign parent_state=state;
 assign cmd_ready=rst_n&&state==IDLE&&l_layer_idle&&!coef_cfg_valid&&!coef_wr_valid;
 assign done_valid=state==FINISH;
 assign done_request=request_id;assign done_generation=generation;assign done_epoch=epoch;
 assign producer_fail_ready=rst_n&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch&&((!encoder0_mode&&(state==QRUN||state==QMRUN||state==CRUN||state==F_NQRUN))||(encoder0_mode&&state==E_H_LOAD));
 assign in_ready=legal_input&&(encoder0_mode?v2_h_wr_ready:q_in_ready);
 assign input_reject_valid=rst_n&&in_valid&&!legal_input;
 assign input_reject_code=encoder0_mode?(state!=E_H_LOAD?1:in_request!=request_id?2:in_generation!=generation?3:in_epoch!=epoch?4:in_row!={1'b0,inputs_accepted[11:5]}?5:6):(state!=QRUN?1:in_request!=request_id?2:in_generation!=generation?3:in_epoch!=epoch?4:in_row!={1'b0,inputs_accepted[11:5]}?5:6);
 assign out_valid=encoder0_mode?(state==E_EXPORT&&v2_h_rsp_valid):(state==WMRUN&&m_out_valid);assign out_data=encoder0_mode?v2_h_rsp_data:m_out_data;assign out_row=encoder0_mode?v2_h_rsp_addr[11:5]:m_out_row;assign out_col=encoder0_mode?{6'b0,v2_h_rsp_addr[4:0],5'b0}:m_out_col;
 assign layer_head_completed=l_head_completed;
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;request_id<=0;generation<=0;epoch<=0;kind<=0;layer_index<=0;mask<=0;tensor_id<=0;base<=0;span<=0;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;end
  else begin
   if(state!=IDLE&&state!=FINISH)elapsed_cycles<=elapsed_cycles+1;
   if(cmd_valid&&cmd_ready)begin
    request_id<=cmd_request;generation<=cmd_generation;epoch<=cmd_epoch;kind<=cmd_kind;layer_index<=cmd_layer;mask<=cmd_mask;tensor_id<=cmd_tensor;base<=cmd_base;span<=cmd_span;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;
    if(!identity_ok||!kind_ok||!tensor_ok)begin state<=FINISH;done_status<=4;error_domain<=1;end else if(!tables_ready||!spans_ok)begin state<=FINISH;done_status<=5;source_status<=1;error_domain<=1;end else state<=cmd_kind==4?E_H_LOAD:cmd_kind==3?F_ARENA:PREP;
   end
   if(producer_fail_fire)begin producer_failed<=1;done_status<=3;source_status<=3;error_domain<=2;error_tuple<=producer_fail_tuple;end
   if(in_valid&&in_ready||encoder0_mode&&internal_source_fire)inputs_accepted<=inputs_accepted+1;
   if(state==PREP&&l_prepare_valid&&l_prepare_ready)state<=QSUB;
   if(state==QSUB)begin
    if(!m_descriptor_precheck_ok)begin state<=PCANCEL;done_status<=5;source_status<=1;error_domain<=1;end
    else if(q_cmd_valid&&q_cmd_ready)state<=QRUN;
   end
   if(state==QRUN&&q_done_valid&&q_done_ready)begin
    if(q_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end else state<=QMSUB;
   end
   if(state==QMSUB&&m_cmd_valid&&m_cmd_ready)state<=QMRUN;
   if(state==QMRUN&&m_done_valid&&m_done_ready)begin
    if(m_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
    end else state<=LSTART;
   end
   if(state==ACANCEL&&m_fill_cancel_valid&&m_fill_cancel_ready)state<=ACWAIT;
   if(state==ACWAIT&&m_fill_cancel_rsp_valid&&m_fill_cancel_rsp_ready)state<=PCANCEL;
   if(state==PCANCEL&&l_prepare_cancel_valid&&l_prepare_cancel_ready)state<=PCWAIT;
   if(state==PCWAIT&&l_prepare_cancel_rsp_valid&&l_prepare_cancel_rsp_ready)state<=DISCWAIT;
   if(state==LSTART&&l_start_valid&&l_start_ready)state<=LRUN;
   if(state==LRUN&&l_done_valid&&l_done_ready)begin
    if(l_done_status!=0)begin state<=DISCWAIT;done_status<=layer_status_map(l_done_status);source_status<=l_done_status;error_domain<=5;error_tuple<=l_error_tuple;end
    else state<=CSUB;
   end
   if(state==CSUB&&q_cmd_valid&&q_cmd_ready&&c_start_ready)begin state<=CRUN;inputs_accepted<=0;end
   if(state==CRUN&&q_done_valid&&q_done_ready)begin
    state<=CDRAIN;
    if(q_status!=0||producer_failure||c_fault)begin context_failed<=1;if(!producer_failure)begin done_status<=q_status==0?2:matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
   end
   if(state==CDRAIN&&c_idle)begin
    if(context_failed)begin if(l_layer_idle)state<=encoder0_mode?E_ABORT:FINISH;else state<=DISCARD;end
    else if(c_complete&&l_layer_idle)state<=encoder0_mode?E_WO_LEASE:WMSUB;
   end
   if(state==DISCARD&&l_result_discard_valid&&l_result_discard_ready)state<=DISCWAIT;
   if(state==DISCWAIT&&l_layer_idle)state<=encoder0_mode?E_ABORT:FINISH;
   if(state==WMSUB&&m_cmd_valid&&m_cmd_ready)state<=WMRUN;
   if(state==WMRUN&&m_done_valid&&m_done_ready)begin state<=encoder0_mode?(m_status!=0?E_ABORT:ffn_mode?F_RETURN:E_WO_POST):ffn_mode?F_RETURN:FINISH;done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=m_status==0?0:4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
   
    if(state==F_ARENA&&ws_g_enable)state<=F_NQSUB;
    if(state==F_NQSUB&&q_cmd_valid&&q_cmd_ready)state<=F_NQRUN;
    if(state==F_NQRUN&&q_done_valid&&q_done_ready)begin
     if(q_status!=0||producer_failure)begin state<=F_RELEASE;if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd1,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
     else state<=F_WISUB;
    end
    if(state==F_WISUB&&m_cmd_valid&&m_cmd_ready)state<=F_GQSUB;
    if(state==F_GQSUB&&g_cmd_valid&&g_cmd_ready&&q_cmd_valid&&q_cmd_ready)state<=F_RUN;
    if((state==F_RUN||state==F_GQSUB)&&(pack_fault||g_protocol_fault||(m_done_valid&&m_status!=0)))state<=F_ABORT;
    if(state==F_RUN&&m_done_valid&&m_status==0&&g_done_valid)begin
     if(g_done_status!=0||g_done_cancelled)state<=F_ABORT;
     else if(pack_seq==41984&&!pack_full&&g_all_covered&&q_quant_accepted==10496)state<=F_CLOSE;
    end
    if(state==F_CLOSE&&ffn_close_fire)state<=F_QDRAIN;
    if(state==F_QDRAIN&&q_done_valid&&q_done_ready)begin
     state<=F_RELEASE;
     if(q_status!=0)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd4,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end
    if(state==F_ABORT)begin
     if(m_done_valid&&m_done_ready&&m_status!=0)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'd2,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
     else if(g_done_valid&&g_done_ready&&error_domain!=4&&(error_domain==0||g_done_status!=0))begin done_status<=g_done_status==32'd6 ? 8'd1 : 8'd2;source_status<=g_done_status==32'd6 ? 8'd6 : 8'd8;error_domain<=6;if(g_done_status==32'd6||g_done_status==32'd8)error_tuple<={8'd3,16'(g_done_error_rank),16'(g_done_error_row),16'(g_done_error_column),16'b0,24'b0};else error_tuple<={8'd3,16'(g_done_error_rank),16'(g_done_error_row),16'(g_done_error_column),g_done_status,8'b0};end
     else if((pack_fault||g_protocol_fault)&&done_status==0)begin done_status<=2;source_status<=8;error_domain<=7;error_tuple<={8'd3,56'b0,16'b0,pack_seq};end
     if(m_cmd_ready&&!g_active&&!g_done_valid&&q_cmd_ready&&(g_needs_discard||g_engine_idle))state<=F_DISCARD;
    end
    if(state==F_DISCARD&&(!g_needs_discard||(g_discard_valid&&g_discard_ready)))state<=F_RELEASE;
    if(state==F_RELEASE&&g_engine_idle&&!tanh_lease_active&&r_res_st_idle&&!r_res_fp_lease_active&&!r_res_div_lease_active&&m_cmd_ready&&q_cmd_ready)state<=done_status==0?WMSUB:F_RETURN;
    if(state==F_RETURN&&ws_a_enable)state<=encoder0_mode?(done_status==0?E_FF_POST:E_ABORT):FINISH;
        if(encoder0_mode)begin
      if(h_load_fire&&!producer_failure)begin
        if(!v2_h_wr_commit)begin
          done_status<=2;source_status<=8;error_domain<=7;
          error_tuple<=encoder0_error_envelope(8'h80,0,3,0,0,0,0,0);state<=E_ABORT;
        end else if(input_bad[5])begin
          done_status<=1;source_status<=6;error_domain<=7;
          error_tuple<=encoder0_error_envelope(8'h80,in_row[6:0],0,0,0,{in_group[4:0],input_bad[4:0]},0,0);state<=E_ABORT;
        end else if(inputs_accepted==4095)state<=E_H_READY;
      end
      if(state==E_H_LOAD&&producer_fail_fire)state<=E_ABORT;
      if(state==E_H_READY&&v2_h_bank_idle)begin state<=PREP;inputs_accepted<=0;end
      if(state==E_WO_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=WMSUB;
      if(state==E_WO_POST&&resident_sink==4096&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=E_REFILL0;
      if(desc_valid&&desc_ready)begin
        if(!desc_record_ok)begin state<=E_ABORT;done_status<=5;source_status<=1;error_domain<=1;end
        else begin tensor_id[desc_slot]<=desc_tensor;base[desc_slot]<=desc_base;span[desc_slot]<=desc_span;state<=state==E_REFILL0?E_REFILL1:E_RA_LEASE;end
      end
      if(state==E_RA_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_RA_OWNER;
      if(state==E_RA_OWNER&&v2_vector_enable)state<=E_RA_SUB;
      if(state==E_RA_SUB&&v2_vector_start_valid&&v2_vector_start_ready)state<=E_RA_RUN;
      if(state==E_RF_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_RF_OWNER;
      if(state==E_RF_OWNER&&v2_vector_enable)state<=E_RF_SUB;
      if(state==E_RF_SUB&&v2_vector_start_valid&&v2_vector_start_ready)state<=E_RF_RUN;
      if(vector_done_fire)begin
        if(v2_vector_done_status==0&&v2_vector_issued_vectors==4096&&v2_vector_retired_vectors==4096&&v2_h_bank_idle)state<=state==E_RA_RUN?E_RA_RELEASE:E_RF_RELEASE;
        else begin
          state<=E_ABORT;error_domain<=7;
          done_status<=v2_vector_done_status==6?8'd1:8'd2;
          source_status<=v2_vector_done_status==6?8'd6:8'd8;
          if(v2_vector_done_status==6)error_tuple<=encoder0_error_envelope(state==E_RA_RUN?8'h81:8'h83,v2_vector_done_error_row,0,0,0,v2_vector_done_error_column,0,0);
          else error_tuple<=encoder0_error_envelope(state==E_RA_RUN?8'h81:8'h83,0,3,0,0,0,0,0);
        end
      end
      if(state==E_RA_RELEASE&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=E_LN_LEASE;
      if(state==E_LN_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_LN_OWNER;
      if(state==E_LN_OWNER&&v2_ln_enable)state<=E_LN_SUB;
      if(state==E_LN_SUB&&v2_resident_ln_start_valid&&v2_resident_ln_start_ready)state<=E_LN_RUN;
      if(ln_reject_fire&&done_status==0)begin
        state<=E_ABORT;done_status<=2;source_status<=8;error_domain<=7;
        error_tuple<=encoder0_error_envelope(8'h82,0,3,0,0,0,v2_ln_reject_code,0);
      end
      if(state==E_LN_RUN&&resident_ln_done_fire&&!ln_reject_fire)begin
        if(v2_resident_ln_done_kind==0&&v2_resident_ln_done_status==0&&v2_resident_ln_issued_vectors==4096&&v2_resident_ln_written_vectors==4096)state<=E_LN_RELEASE;
        else begin
          state<=E_ABORT;error_domain<=7;
          done_status<=v2_resident_ln_done_kind==1?8'd1:8'd2;
          source_status<={6'b0,v2_resident_ln_done_kind};
          if(v2_resident_ln_done_kind==1)error_tuple<=encoder0_error_envelope(8'h82,v2_ln_error_row,v2_ln_error_class,v2_ln_error_check,v2_ln_error_level,v2_ln_error_node,0,0);
          else if(v2_resident_ln_done_kind==2)error_tuple<=encoder0_error_envelope(8'h82,0,3,0,0,0,v2_ln_protocol_code,v2_ln_protocol_location);
          else error_tuple<=encoder0_error_envelope(8'h82,0,3,0,0,0,0,0);
        end
      end
      if(state==E_LN_RELEASE&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=E_FF_LEASE;
      if(state==E_FF_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)state<=E_FF_OWNER;
      if(state==E_FF_OWNER&&ws_g_enable)state<=F_NQSUB;
      if(state==F_NQSUB&&q_cmd_valid&&q_cmd_ready)inputs_accepted<=0;
      if(state==E_FF_POST&&resident_sink==4096&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=E_RF_LEASE;
      if(state==E_RF_RELEASE&&v2_scratch_release_valid&&v2_scratch_release_ready)state<=E_EXPORT;
      if(state==E_EXPORT&&out_valid&&out_ready&&resident_sink==4095)state<=E_EXPORT_DRAIN;
      if(state==E_EXPORT_DRAIN&&resident_issue==4096&&resident_sink==4096&&resident_retired&&v2_scratch_retired)state<=E_FINAL_A;
      if(state==E_ABORT&&resident_retired&&v2_scratch_retired)state<=E_FINAL_A;
      if(state==E_FINAL_A&&ws_a_enable&&resident_retired&&v2_scratch_retired)state<=FINISH;
    end

    if(done_valid&&done_ready)state<=IDLE;
  end
 end
 assign coef_cfg_ready=m_coef_cfg_ready&&bias_identity_ok;
 assign coef_wr_ready=m_coef_wr_ready;
 assign coef_rsp_valid=m_coef_rsp_valid;
 assign coef_status=m_coef_status;
 assign coef_error_col=m_coef_error_col;
 assign arvalid=m_arvalid;
 assign araddr=m_araddr;
 assign arid=m_arid;
 assign arlen=m_arlen;
 assign rready=m_rready;
 
 assign l_prepare_valid=state==PREP;
 assign l_prepare_request_id=request_id;
 assign l_prepare_model_id=MODEL_ID;
 assign l_prepare_generation=generation;
 assign l_prepare_epoch=operation_epoch;
 assign l_prepare_numeric_id=NUMERIC_ID;
 assign l_prepare_table_key=TABLE_KEY;
 assign l_prepare_kind=encoder0_island_kind(kind,0);
 assign l_prepare_layer=layer_index;
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
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 assign m_cmd_valid=ffn_mode?(state==QMSUB||state==WMSUB||state==F_WISUB):(state==QMSUB||state==WMSUB);
 assign m_cmd_version=32'd1;
 assign m_cmd_request=request_id;
 assign m_cmd_model=MODEL_ID[63:0];
 assign m_cmd_generation=generation;
 assign m_cmd_epoch=operation_epoch;
 assign m_cmd_tensor=tensor_id[wo_phase];
 assign m_cmd_k=ffn_mode?(ffn_mode&&wo_phase?16'd2624:16'd1024):(16'd1024);
 assign m_cmd_n=ffn_mode?(wo_phase?16'd1024:(ffn_mode?16'd5248:16'd3072)):(wo_phase?16'd1024:16'd3072);
 assign m_cmd_a_slot=ffn_mode?(ffn_mode&&wo_phase):(1'b0);
 assign m_cmd_bias=kind==2;
 assign m_cmd_base=base[wo_phase];
 assign m_cmd_span=span[wo_phase];
 assign m_done_ready=ffn_mode?(state==QMRUN||state==WMRUN||(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT):(state==QMRUN||state==WMRUN);
 assign m_out_ready=encoder0_mode&&state==WMRUN?(projection_identity_ok&&v2_q_wr_ready):(ffn_mode?(ffn_mode?(wo_phase?out_ready:(state==F_ABORT?1'b1:g_fill_ready)):wo_phase?out_ready:l_qkv_wr_ready):(state==QMRUN?l_qkv_wr_ready:(state==WMRUN&&out_ready)));
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
 assign m_coef_cfg_valid=coef_cfg_valid&&bias_identity_ok;
 assign m_coef_model=coef_model;
 assign m_coef_request=coef_request;
 assign m_coef_tensor=coef_tensor;
 assign m_coef_generation=coef_generation;
 assign m_coef_epoch=coef_epoch;
 assign m_coef_n=coef_n;
 assign m_coef_wr_valid=coef_wr_valid;
 assign m_coef_wr_addr=coef_wr_addr;
 assign m_coef_wr_data=coef_wr_data;
 assign m_coef_rsp_ready=coef_rsp_ready;
 assign m_arready=arready;
 assign m_rvalid=rvalid;
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
 assign q_cmd_valid=ffn_mode?(state==QSUB||state==CSUB||state==F_NQSUB||(state==F_GQSUB&&g_cmd_ready)):((state==QSUB&&m_descriptor_precheck_ok)||(state==CSUB&&c_start_ready));
 assign q_cmd_slot=ffn_mode?(state==F_GQSUB):(1'b0);
 assign q_cmd_k=ffn_mode?(state==F_GQSUB?16'd2624:16'd1024):(16'd1024);
 assign q_cmd_request=request_id;
 assign q_cmd_generation=generation;
 assign q_cmd_epoch=operation_epoch;
 assign q_in_valid=encoder0_mode&&resident_source_phase?resident_source_valid:(ffn_mode?(ffn_mode?((state==F_NQRUN)?(in_valid&&legal_input):((state==F_RUN||state==F_CLOSE||state==F_ABORT)&&pack_full&&!q_close_sent)):(context_phase?c_out_valid:(in_valid&&legal_input))):(state==CRUN?c_out_valid:(in_valid&&legal_input)));
 assign q_in_data=encoder0_mode&&resident_source_phase?resident_source_data:(ffn_mode?(ffn_mode&&state!=F_NQRUN?pack_data:context_phase?c_out_data:in_data):(state==CRUN?c_out_data:in_data));
 assign q_in_request=request_id;
 assign q_in_generation=generation;
 assign q_in_epoch=operation_epoch;
 assign q_in_row=encoder0_mode&&resident_source_phase?{1'b0,resident_source_addr[11:5]}:(ffn_mode?(ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[8:2]}:context_phase?c_out_row:in_row):(state==CRUN?c_out_row:in_row));
 assign q_in_group=encoder0_mode&&resident_source_phase?{3'b0,resident_source_addr[4:0]}:(ffn_mode?(ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[15:9]}:context_phase?c_out_group:in_group):(state==CRUN?c_out_group:in_group));
 assign q_producer_close_valid=ffn_mode?(ffn_mode?((state==F_NQRUN)&&(inputs_accepted==4096||producer_failure)||(state==F_CLOSE)||(state==F_ABORT&&!q_close_sent&&!q_cmd_ready&&!q_done_valid)):(state==QRUN&&(inputs_accepted==4096||producer_failure)||state==CRUN&&(c_complete||producer_failure||c_fault))):((state==QRUN&&(inputs_accepted==4096||producer_failed))||(state==CRUN&&(c_complete||producer_failed||c_fault)));
 assign q_producer_close_success=ffn_mode?(ffn_mode?(state!=F_ABORT&&!producer_failure):(!producer_failure&&!c_fault)):(!producer_failed&&(state!=CRUN||!c_fault));
 assign q_done_ready=ffn_mode?(state==QRUN||state==CRUN||state==F_NQRUN||state==F_QDRAIN||state==F_ABORT):(state==QRUN||state==CRUN);
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
 laya_m007_matrix_facade_v1 #(.PROFILE_ENABLE(0)) matrix(
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
 
  assign ws_owner_req_valid=state==F_ARENA||state==F_RETURN||state==E_RA_OWNER||state==E_LN_OWNER||state==E_FF_OWNER||state==E_RF_OWNER||state==E_FINAL_A;
  
  assign g_cmd_valid=state==F_GQSUB&&q_cmd_ready;
  assign g_cmd_request_id=request_id;assign g_cmd_generation=generation;assign g_cmd_epoch=operation_epoch;
  
  
  
  assign g_fill_valid=ffn_mode&&g_active&&state!=F_ABORT&&m_out_valid&&!wo_phase;
  assign g_fill_request_id=m_out_request;assign g_fill_generation=m_out_generation;assign g_fill_epoch=m_out_epoch;
  assign g_fill_slot=m_out_s[0];assign g_fill_s=m_out_s[6:0];assign g_fill_half=m_out_col>=2624;assign g_fill_row=m_out_row;assign g_fill_data=m_out_data;
  assign g_out_ready=state==F_ABORT?1'b1:((state==F_RUN||state==F_CLOSE)&&(!pack_full||q_in_ready)&&pack_seq<41984);
  assign g_done_ready=(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT;
  assign g_producer_cancel_valid=state==F_ABORT&&g_active&&!g_cancel_sent;
  assign g_producer_cancel_request_id=request_id;assign g_producer_cancel_generation=generation;assign g_producer_cancel_epoch=operation_epoch;
  assign g_discard_valid=state==F_DISCARD&&g_needs_discard;
  assign g_discard_request_id=request_id;assign g_discard_generation=generation;assign g_discard_epoch=operation_epoch;
  always_ff @(posedge clk)begin
   if(!rst_n)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
   else begin
    if(cmd_valid&&cmd_ready)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
    if(q_in_valid&&q_in_ready&&ffn_mode&&state!=F_NQRUN)pack_full<=0;
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
laya_m007_resident_joint_v2 resident(
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
  .coeff_bind_valid(coeff_bind_valid),
  .coeff_bind_ready(coeff_bind_ready),
  .coeff_bind_model_id(coeff_bind_model_id),
  .coeff_bind_numeric_id(coeff_bind_numeric_id),
  .coeff_bind_table_key(coeff_bind_table_key),
  .coeff_bound_valid(coeff_bound_valid),
  .coeff_bound_model_id(coeff_bound_model_id),
  .coeff_bound_numeric_id(coeff_bound_numeric_id),
  .coeff_bound_table_key(coeff_bound_table_key),
  .coeff_family_complete(coeff_family_complete),
  .coeff_wr_valid(coeff_wr_valid),
  .coeff_wr_ready(coeff_wr_ready),
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
