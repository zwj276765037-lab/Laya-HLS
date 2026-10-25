`timescale 1ns/1ps
// One matrix descriptor, one existing compute/restore core, one A/W cache pair.
module laya_m007_matrix_full_v1 #(parameter bit PROFILE_ENABLE=1)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,output logic descriptor_precheck_ok,input logic [31:0] cmd_version,
 input logic [63:0] cmd_request,cmd_model,input logic [31:0] cmd_generation,cmd_epoch,cmd_tensor,
 input logic [15:0] cmd_k,cmd_n,input logic cmd_a_slot,cmd_bias,
 input logic [3:0][63:0] cmd_base,cmd_span,
 output logic done_valid,input logic done_ready,output logic [2:0] status,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [6:0] error_row,output logic [15:0] error_col,output logic [7:0] error_group,output logic [3:0] error_stage,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,out_s,
 output logic [63:0] out_request,output logic [31:0] out_generation,out_epoch,
 input logic acfg_valid,output logic acfg_ready,input logic acfg_slot,input logic [15:0] acfg_k,
 input logic [63:0] acfg_request,input logic [31:0] acfg_generation,acfg_epoch,
 output logic acfg_rsp_valid,input logic acfg_rsp_ready,output logic [1:0] acfg_status,
 input logic fill_cancel_valid,output logic fill_cancel_ready,input logic fill_cancel_slot,
 input logic [63:0] fill_cancel_request,input logic [31:0] fill_cancel_generation,fill_cancel_epoch,
 output logic fill_cancel_reject_valid,output logic [3:0] fill_cancel_reject_code,
 output logic fill_cancel_rsp_valid,input logic fill_cancel_rsp_ready,output logic fill_cancel_rsp_slot,
 output logic [63:0] fill_cancel_rsp_request,output logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch,
 input logic awr_valid,output logic awr_ready,input logic [6:0] awr_row,awr_group,input logic [271:0] awr_data,
 input logic [63:0] awr_request,input logic [31:0] awr_generation,awr_epoch,
 output logic awr_rsp_valid,input logic awr_rsp_ready,
 input logic coef_cfg_valid,output logic coef_cfg_ready,input logic [63:0] coef_model,coef_request,input logic [31:0] coef_tensor,coef_generation,coef_epoch,input logic [15:0] coef_n,
 input logic coef_wr_valid,output logic coef_wr_ready,input logic [6:0] coef_wr_addr,input logic [31:0][31:0] coef_wr_data,
 output logic coef_rsp_valid,input logic coef_rsp_ready,output logic [1:0] coef_status,output logic [15:0] coef_error_col,
 output logic [3:0] arvalid,input logic [3:0] arready,output logic [3:0][63:0] araddr,output logic [3:0][2:0] arid,output logic [3:0][7:0] arlen,
 input logic [3:0] rvalid,output logic [3:0] rready,input logic [3:0][2:0] rid,input logic [3:0][511:0] rdata,input logic [3:0][1:0] rresp,input logic [3:0] rlast,
 input logic run_enable,
 output logic [31:0] elapsed_cycles,first_output_cycle,w_wait_cycles,ctx_wait_cycles,
 output logic [15:0] blocks_issued,blocks_computed,blocks_retired,
 output logic [31:0] ps_merged_reads,ps_response_holds,bias_add_conflicts,compute_output_overlap,
 output logic [7:0] peak_return_reservations,output logic [6:0] arithmetic_debt,peak_arithmetic_reservations
);
// Thin compatibility shell: A/W/coefficient state exists only in facade.
 logic [63:0] fp_owner_request;
 logic [31:0] fp_owner_generation;
 logic [31:0] fp_owner_epoch;
 logic bind_new_lease;
 logic fp_release_valid;
 logic fp_phase_debt_clear;
 logic fp_lease_ready;
 logic fp_release_ready;
 logic fp_lease_active;
 logic fp_draining;
 logic fp_fault;
 logic storage_bind_ready;
 logic storage_idle;
 logic mul_req_valid;
 logic mul_rsp_ready;
 logic mul_req_ready;
 logic mul_rsp_valid;
 logic [95:0] mul_req_tag;
 logic [95:0] mul_rsp_tag;
 logic [255:0][31:0] mul_a;
 logic [255:0][31:0] mul_b;
 logic [255:0][31:0] mul_rsp_data;
 logic [6:0] mul_pending;
 logic [6:0] add_req_valid;
 logic [6:0] add_req_is_root;
 logic [6:0] add_rsp_ready;
 logic [6:0] add_req_ready;
 logic [6:0] add_rsp_valid;
 logic [6:0][2:0] add_req_phase;
 logic [6:0][31:0] add_req_epoch;
 logic [6:0][95:0] add_req_tag;
 logic [6:0][95:0] add_rsp_tag;
 logic [255:0][31:0] add_a;
 logic [255:0][31:0] add_b;
 logic [255:0][31:0] add_rsp_data;
 logic [6:0][6:0] add_pending;
 logic ps_wr_valid;
 logic ps_wr_rsp_ready;
 logic ps_rd_valid;
 logic ps_rd_rsp_ready;
 logic ps_wr_ready;
 logic ps_wr_rsp_valid;
 logic ps_rd_ready;
 logic ps_rd_rsp_valid;
 logic [1023:0] ps_wr_mask;
 logic [1023:0] ps_rd_mask;
 logic [1023:0] ps_rd_rsp_mask;
 logic [1023:0][3:0] ps_wr_addr;
 logic [1023:0][3:0] ps_rd_addr;
 logic [1023:0][31:0] ps_wr_data;
 logic [1023:0][31:0] ps_rd_rsp_data;
 logic [95:0] ps_wr_tag;
 logic [95:0] ps_rd_tag;
 logic [95:0] ps_wr_rsp_tag;
 logic [95:0] ps_rd_rsp_tag;
 logic profile_valid;
 laya_m007_matrix_facade_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) facade(.*);
 laya_m007_matrix_resources_v1 resources(.*);
endmodule
