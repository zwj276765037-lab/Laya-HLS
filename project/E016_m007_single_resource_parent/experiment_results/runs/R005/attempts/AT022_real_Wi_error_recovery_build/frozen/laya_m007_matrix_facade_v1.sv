`timescale 1ns/1ps
// One matrix descriptor, one existing compute/restore core, one A/W cache pair.
module laya_m007_matrix_facade_v1 #(parameter bit PROFILE_ENABLE=0)(
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
,
 output logic profile_valid,
 output logic [63:0] fp_owner_request,
 output logic [31:0] fp_owner_generation,
 output logic [31:0] fp_owner_epoch,
 output logic bind_new_lease,
 output logic fp_release_valid,
 output logic fp_phase_debt_clear,
 input logic fp_lease_ready,
 input logic fp_release_ready,
 input logic fp_lease_active,
 input logic fp_draining,
 input logic fp_fault,
 input logic storage_bind_ready,
 input logic storage_idle,
 output logic mul_req_valid,
 output logic mul_rsp_ready,
 input logic mul_req_ready,
 input logic mul_rsp_valid,
 output logic [95:0] mul_req_tag,
 input logic [95:0] mul_rsp_tag,
 output logic [255:0][31:0] mul_a,
 output logic [255:0][31:0] mul_b,
 input logic [255:0][31:0] mul_rsp_data,
 input logic [6:0] mul_pending,
 output logic [6:0] add_req_valid,
 output logic [6:0] add_req_is_root,
 output logic [6:0] add_rsp_ready,
 input logic [6:0] add_req_ready,
 input logic [6:0] add_rsp_valid,
 output logic [6:0][2:0] add_req_phase,
 output logic [6:0][31:0] add_req_epoch,
 output logic [6:0][95:0] add_req_tag,
 input logic [6:0][95:0] add_rsp_tag,
 output logic [255:0][31:0] add_a,
 output logic [255:0][31:0] add_b,
 input logic [255:0][31:0] add_rsp_data,
 input logic [6:0][6:0] add_pending,
 output logic ps_wr_valid,
 output logic ps_wr_rsp_ready,
 output logic ps_rd_valid,
 output logic ps_rd_rsp_ready,
 input logic ps_wr_ready,
 input logic ps_wr_rsp_valid,
 input logic ps_rd_ready,
 input logic ps_rd_rsp_valid,
 output logic [1023:0] ps_wr_mask,
 output logic [1023:0] ps_rd_mask,
 input logic [1023:0] ps_rd_rsp_mask,
 output logic [1023:0][3:0] ps_wr_addr,
 output logic [1023:0][3:0] ps_rd_addr,
 output logic [1023:0][31:0] ps_wr_data,
 input logic [1023:0][31:0] ps_rd_rsp_data,
 output logic [95:0] ps_wr_tag,
 output logic [95:0] ps_rd_tag,
 input logic [95:0] ps_wr_rsp_tag,
 input logic [95:0] ps_rd_rsp_tag);
 logic a_complete;
 logic a_complete_slot;
 logic [1:0] a_complete_status;
 logic [15:0] a_complete_k;
 logic [63:0] a_complete_request;
 logic [31:0] a_complete_generation,a_complete_epoch;
 logic w_complete;
 logic w_complete_slot;
 logic [2:0] w_complete_status;
 logic [15:0] w_complete_k,w_complete_n,w_complete_s;
 logic [63:0] w_complete_request,w_complete_model;
 logic [31:0] w_complete_generation,w_complete_tensor;
 logic a_lease_valid;
 logic a_lease_ready;
 logic a_lease_slot;
 logic [63:0] a_lease_request;
 logic [31:0] a_lease_generation,a_lease_epoch;
 logic a_rd_valid;
 logic a_rd_ready;
 logic a_rd_slot;
 logic [2:0] a_rd_m;
 logic [6:0] a_rd_group;
 logic [95:0] a_rd_tag;
 logic [63:0] a_rd_request;
 logic [31:0] a_rd_generation,a_rd_epoch;
 logic a_rsp_valid;
 logic a_rsp_ready;
 logic [4351:0] a_rsp_data;
 logic [95:0] a_rsp_tag;
 logic a_rsp_slot;
 logic a_ret_valid;
 logic a_ret_ready;
 logic a_ret_slot;
 logic [95:0] a_ret_tag;
 logic [63:0] a_ret_request;
 logic [31:0] a_ret_generation,a_ret_epoch;
 logic a_release_valid;
 logic a_release_ready;
 logic a_release_slot;
 logic [63:0] a_release_request;
 logic [31:0] a_release_generation,a_release_epoch;
 logic w_lease_valid;
 logic w_lease_ready;
 logic w_lease_slot;
 logic [63:0] w_lease_request,w_lease_model;
 logic [31:0] w_lease_generation,w_lease_tensor;
 logic w_rd_valid;
 logic w_rd_ready;
 logic w_rd_slot;
 logic [8:0] w_rd_addr;
 logic [63:0] w_rd_tag;
 logic [63:0] w_rd_request,w_rd_model;
 logic [31:0] w_rd_generation,w_rd_tensor;
 logic w_rsp_valid;
 logic w_rsp_ready;
 logic [4351:0] w_rsp_data;
 logic [63:0] w_rsp_tag;
 logic w_rsp_slot;
 logic w_ret_valid;
 logic w_ret_ready;
 logic w_ret_slot;
 logic [63:0] w_ret_tag,w_ret_request;
 logic [31:0] w_ret_generation;
 logic w_release_valid;
 logic w_release_ready;
 logic w_release_slot;
 logic [63:0] w_release_request;
 logic [31:0] w_release_generation;
 logic trace_issue;
 logic [12:0] trace_issue_seq;
 logic [4095:0] trace_a_q,trace_w_q;
 logic [255:0] trace_a_scale,trace_w_scale;
 logic trace_dot;
 logic [12:0] trace_dot_seq;
 logic [255:0][20:0] trace_dot_data;
 logic trace_format;
 logic [12:0] trace_format_seq;
 logic [255:0][31:0] trace_scale_product,trace_converted;
 logic trace_term;
 logic [12:0] trace_term_seq;
 logic [255:0][31:0] trace_term_data;
 logic trace_commit;
 logic [12:0] trace_commit_seq;
 logic [255:0][31:0] trace_commit_data;

 logic active,aborting,core_started,core_finished;logic [63:0] request_id,model;logic [31:0] generation,epoch,tensor;logic [15:0] k,n,total_blocks;logic a_slot,bias;logic [3:0][63:0] base,span;logic [31:0] tick;logic [15:0] issue_next,load_next;logic load_pending,waiting_next;
 logic [1:0] slot_ready,slot_in_use;logic [1:0][15:0] slot_s;
 logic [1:0] a_valid;logic [1:0][15:0] a_k;logic [1:0][63:0] a_request;logic [1:0][31:0] a_generation,a_epoch;
 logic acfg_rsp_slot;logic [15:0] acfg_rsp_k;logic [63:0] acfg_rsp_request;logic [31:0] acfg_rsp_generation,acfg_rsp_epoch;logic [6:0] ae_r,ae_g,awr_rsp_row,awr_rsp_group;logic [1:0] a_slot_valid,a_slot_leased;logic [6:0] a_read_debt;
 logic wl_valid,wl_ready,wl_slot,wl_rsp_valid,wl_rsp_ready,wl_rsp_slot;logic [15:0] wl_k,wl_n,wl_s,wl_rsp_k,wl_rsp_n,wl_rsp_s,we_n,we_g;
 logic [31:0] wl_version,wl_tensor,wl_generation,wl_rsp_version,wl_rsp_tensor,wl_rsp_generation,wl_cycles;logic [63:0] wl_model,wl_request,wl_rsp_model,wl_rsp_request;logic [3:0][63:0] wl_base,wl_span,wl_rsp_base,wl_rsp_span;logic [2:0] wl_status;logic [3:0][3:0] w_peak;logic [3:0][31:0] w_ar_count,w_r_count;logic [1:0] w_slot_valid,w_slot_leased;
 logic core_cmd_valid,core_cmd_ready,core_done_valid;logic [2:0] core_status;logic [63:0] core_done_request;logic [31:0] core_done_generation;logic [6:0] core_error_row;logic [15:0] core_error_col;logic [7:0] core_error_group;logic [3:0] core_error_stage;
 logic block_done_valid,block_done_ctx;logic [15:0] block_done_s;logic [15:0] trace_block_s;logic trace_compute_ctx,out_half;
 logic [31:0] core_elapsed,first_issue_cycle,last_issue_cycle,last_output_cycle,max_issue_commit,max_ps_feedback,output_bubbles;
 logic [1:0][6:0] ctx_bias_reads,ctx_bias_adds,ctx_bias_acks;logic [1:0] ctx_busy_debug;
 logic [63:0][31:0] coeff_words[0:63];logic coeff_busy,coeff_valid,coeff_bad;logic [127:0] coeff_coverage;logic [7:0] coeff_count;
 logic [63:0] coeff_model,coeff_request;logic [31:0] coeff_tensor,coeff_generation,coeff_epoch;logic [15:0] coeff_n;logic descriptor_ok;logic [64:0] needed,last_byte;
 integer b;logic coef_cycle_bad;logic [15:0] coef_cycle_col;
 assign out_request=request_id;assign out_generation=generation;assign out_epoch=epoch;
 assign a_complete=acfg_rsp_valid&&acfg_rsp_ready;assign a_complete_slot=acfg_rsp_slot;assign a_complete_status=acfg_status;assign a_complete_k=acfg_rsp_k;assign a_complete_request=acfg_rsp_request;assign a_complete_generation=acfg_rsp_generation;assign a_complete_epoch=acfg_rsp_epoch;
 assign w_complete=wl_rsp_valid&&wl_rsp_ready;assign w_complete_slot=wl_rsp_slot;assign w_complete_status=wl_status;assign w_complete_k=wl_rsp_k;assign w_complete_n=wl_rsp_n;assign w_complete_s=wl_rsp_s;assign w_complete_request=wl_rsp_request;assign w_complete_generation=wl_rsp_generation;assign w_complete_model=wl_rsp_model;assign w_complete_tensor=wl_rsp_tensor;
 always_comb begin
  descriptor_ok=cmd_version==1&&((cmd_k==1024&&(cmd_n==1024||cmd_n==3072||cmd_n==4096||cmd_n==5248))||(cmd_n==1024&&(cmd_k==2624||cmd_k==4096)));
  needed=65'd576*(cmd_k>>5)*((cmd_n==5248)?82:(cmd_n>>6));last_byte=0;
  for(integer p=0;p<4;p++)begin last_byte={1'b0,cmd_base[p]}+needed;descriptor_ok=descriptor_ok&&cmd_base[p][11:0]==0&&{1'b0,cmd_span[p]}>=needed&&last_byte<65'h10000000000000000&&({1'b0,cmd_base[p]}+{1'b0,cmd_span[p]})<65'h10000000000000000;end
  if(cmd_bias)descriptor_ok=descriptor_ok&&coeff_valid&&coeff_model==cmd_model&&coeff_tensor==cmd_tensor&&coeff_request==cmd_request&&coeff_generation==cmd_generation&&coeff_epoch==cmd_epoch&&coeff_n==cmd_n;
  descriptor_precheck_ok=descriptor_ok;
  descriptor_ok=descriptor_ok&&a_valid[cmd_a_slot]&&a_k[cmd_a_slot]==cmd_k&&a_request[cmd_a_slot]==cmd_request&&a_generation[cmd_a_slot]==cmd_generation&&a_epoch[cmd_a_slot]==cmd_epoch;
  cmd_ready=rst_n&&!active&&!done_valid&&!coeff_busy&&!coef_rsp_valid;
  coef_cfg_ready=rst_n&&!active&&!coeff_busy&&!coef_rsp_valid;coef_wr_ready=rst_n&&coeff_busy&&coef_wr_addr<(coeff_n>>5);
  wl_valid=active&&!aborting&&!load_pending&&load_next<total_blocks&&!slot_ready[load_next[0]]&&!slot_in_use[load_next[0]]&&!w_slot_leased[load_next[0]];
  wl_version=1;wl_model=model;wl_tensor=tensor;wl_request=request_id;wl_generation=generation;wl_k=k;wl_n=n;wl_s=load_next;wl_slot=load_next[0];wl_base=base;wl_span=span;wl_rsp_ready=active&&load_pending;
  core_cmd_valid=active&&!aborting&&issue_next<total_blocks&&slot_ready[issue_next[0]]&&slot_s[issue_next[0]]==issue_next;
 end
 laya_m007_matrix_engine_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) core(
  .clk,.rst_n,.cmd_valid(core_cmd_valid),.cmd_ready(core_cmd_ready),.cmd_request(request_id),.cmd_model(model),.cmd_generation(generation),.cmd_epoch(epoch),.cmd_tensor(tensor),.cmd_k(k),.cmd_n(n),.cmd_s(issue_next),.cmd_a_slot(a_slot),.cmd_w_slot(issue_next[0]),.cmd_ctx(issue_next[0]),.cmd_bias(bias),.cmd_bias_data(coeff_words[issue_next[5:0]]),.cmd_first(issue_next==0),.cmd_last(issue_next+1==total_blocks),
  .cancel_valid(aborting&&core_started),.cancel_status(status),.cancel_row(error_row),.cancel_col(error_col),.cancel_group(error_group),.cancel_stage(error_stage),
  .done_valid(core_done_valid),.done_ready(1'b1),.status(core_status),.done_request(core_done_request),.done_generation(core_done_generation),.error_row(core_error_row),.error_col(core_error_col),.error_group(core_error_group),.error_stage(core_error_stage),
  .elapsed_cycles(core_elapsed),.out_block_s(out_s),.block_done_ready(1'b1),.*);
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   active<=0;aborting<=0;core_started<=0;core_finished<=0;request_id<=0;model<=0;generation<=0;epoch<=0;tensor<=0;k<=0;n<=0;total_blocks<=0;a_slot<=0;bias<=0;base<=0;span<=0;tick<=0;issue_next<=0;load_next<=0;load_pending<=0;waiting_next<=0;slot_ready<=0;slot_in_use<=0;slot_s<=0;
   a_valid<=0;a_k<=0;a_request<=0;a_generation<=0;a_epoch<=0;
   coeff_busy<=0;coeff_valid<=0;coeff_bad<=0;coeff_coverage<=0;coeff_count<=0;coeff_model<=0;coeff_request<=0;coeff_tensor<=0;coeff_generation<=0;coeff_epoch<=0;coeff_n<=0;coef_rsp_valid<=0;coef_status<=0;coef_error_col<=0;
   done_valid<=0;status<=0;done_request<=0;done_generation<=0;done_epoch<=0;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;elapsed_cycles<=0;first_output_cycle<=0;w_wait_cycles<=0;ctx_wait_cycles<=0;blocks_issued<=0;blocks_computed<=0;blocks_retired<=0;
  end else begin
   coef_cycle_bad=0;coef_cycle_col=65535;
   if(done_valid&&done_ready)done_valid<=0;
   if(coef_rsp_valid&&coef_rsp_ready)coef_rsp_valid<=0;
   if(a_complete)begin a_valid[a_complete_slot]<=a_complete_status==0;a_k[a_complete_slot]<=a_complete_k;a_request[a_complete_slot]<=a_complete_request;a_generation[a_complete_slot]<=a_complete_generation;a_epoch[a_complete_slot]<=a_complete_epoch;end
   if(fill_cancel_rsp_valid&&fill_cancel_rsp_ready)a_valid[fill_cancel_rsp_slot]<=0;
   if(coef_cfg_valid&&coef_cfg_ready)begin
    coeff_valid<=0;coeff_bad<=0;coeff_coverage<=0;coeff_count<=0;coeff_model<=coef_model;coeff_request<=coef_request;coeff_tensor<=coef_tensor;coeff_generation<=coef_generation;coeff_epoch<=coef_epoch;coeff_n<=coef_n;coef_status<=0;coef_error_col<=0;
    if(coef_n==1024||coef_n==3072||coef_n==4096)coeff_busy<=1;else begin coef_rsp_valid<=1;coef_status<=1;end
   end
   if(coef_wr_valid&&coef_wr_ready)begin
    for(integer lane=0;lane<32;lane++)begin
     coeff_words[coef_wr_addr[6:1]][32*coef_wr_addr[0]+lane]<=coef_wr_data[lane];
     if(coef_wr_data[lane][30:23]==255)begin coef_cycle_bad=1;if(32*coef_wr_addr+lane<coef_cycle_col)coef_cycle_col=32*coef_wr_addr+lane;end
    end
    if(coef_cycle_bad)begin coeff_bad<=1;coef_status<=2;if(!coeff_bad||coef_cycle_col<coef_error_col)coef_error_col<=coef_cycle_col;end
    if(coeff_coverage[coef_wr_addr])begin coeff_bad<=1;coef_status<=1;end
    else begin coeff_coverage[coef_wr_addr]<=1;coeff_count<=coeff_count+1;end
    if(!coeff_coverage[coef_wr_addr]&&coeff_count+1==(coeff_n>>5))begin
     coeff_busy<=0;coef_rsp_valid<=1;coeff_valid<=!coeff_bad&&!coef_cycle_bad;
    end
   end
   if(cmd_valid&&cmd_ready)begin
    done_request<=cmd_request;done_generation<=cmd_generation;done_epoch<=cmd_epoch;status<=0;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;elapsed_cycles<=0;first_output_cycle<=0;w_wait_cycles<=0;ctx_wait_cycles<=0;blocks_issued<=0;blocks_computed<=0;blocks_retired<=0;
    if(!descriptor_ok)begin done_valid<=1;status<=1;end
    else begin
     active<=1;aborting<=0;core_started<=0;core_finished<=0;request_id<=cmd_request;model<=cmd_model;generation<=cmd_generation;epoch<=cmd_epoch;tensor<=cmd_tensor;k<=cmd_k;n<=cmd_n;total_blocks<=(cmd_n==5248)?82:(cmd_n>>6);a_slot<=cmd_a_slot;bias<=cmd_bias;base<=cmd_base;span<=cmd_span;tick<=0;issue_next<=0;load_next<=0;load_pending<=0;waiting_next<=1;slot_ready<=0;slot_in_use<=0;
    end
   end
   if(active)begin
    tick<=tick+1;
    if(waiting_next&&!slot_ready[issue_next[0]])w_wait_cycles<=w_wait_cycles+1;
    if(waiting_next&&slot_ready[issue_next[0]]&&!core_cmd_ready)ctx_wait_cycles<=ctx_wait_cycles+1;
   end
   if(wl_valid&&wl_ready)begin load_pending<=1;load_next<=load_next+1;end
   if(w_complete)begin
    load_pending<=0;
    if(w_complete_status==0)begin slot_ready[w_complete_slot]<=1;slot_s[w_complete_slot]<=w_complete_s;end
    else begin
     aborting<=1;status<=(w_complete_status==4)?2:3;error_row<=0;error_col<=we_n;error_group<=we_g;error_stage<=1;
     if(!core_started)begin active<=0;done_valid<=1;elapsed_cycles<=tick;end
    end
   end
   if(core_cmd_valid&&core_cmd_ready)begin core_started<=1;slot_ready[issue_next[0]]<=0;slot_in_use[issue_next[0]]<=1;issue_next<=issue_next+1;blocks_issued<=blocks_issued+1;waiting_next<=0;end
   if(block_done_valid)begin slot_in_use[block_done_s[0]]<=0;blocks_computed<=blocks_computed+1;if(issue_next<total_blocks&&!(core_cmd_valid&&core_cmd_ready))waiting_next<=1;end
   if(out_valid&&out_ready)begin
    if(first_output_cycle==0)first_output_cycle<=tick;
    if(out_row==127&&out_half)blocks_retired<=blocks_retired+1;
   end
   if(core_done_valid&&active)begin
    core_started<=0;core_finished<=1;
    if(core_status!=0)begin
     aborting<=1;
     if(core_status==3||status!=3)begin status<=core_status;error_row<=core_error_row;error_col<=core_error_col;error_group<=core_error_group;error_stage<=core_error_stage;end
    end else if(!aborting&&(issue_next!=total_blocks||blocks_retired!=total_blocks||slot_in_use!=0))begin status<=3;error_stage<=8;aborting<=1;end
   end
   // A core error cannot erase a real outstanding prefetch: drain its actual response before final done.
   if(active&&core_finished&&!load_pending&&!wl_rsp_valid&&slot_in_use==0)begin active<=0;done_valid<=1;elapsed_cycles<=tick;end
  end
 end
 laya_m007_a_cache_v1 a_cache(.clk,.rst_n,.cfg_valid(acfg_valid),.cfg_ready(acfg_ready),.cfg_slot(acfg_slot),.cfg_k(acfg_k),.cfg_request(acfg_request),.cfg_generation(acfg_generation),.cfg_epoch(acfg_epoch),.cfg_rsp_valid(acfg_rsp_valid),.cfg_rsp_ready(acfg_rsp_ready),.cfg_status(acfg_status),.cfg_rsp_slot(acfg_rsp_slot),.cfg_rsp_k(acfg_rsp_k),.cfg_rsp_request(acfg_rsp_request),.cfg_rsp_generation(acfg_rsp_generation),.cfg_rsp_epoch(acfg_rsp_epoch),.error_row(ae_r),.error_group(ae_g),
 .fill_cancel_valid,.fill_cancel_ready,.fill_cancel_slot,.fill_cancel_request,.fill_cancel_generation,.fill_cancel_epoch,.fill_cancel_reject_valid,.fill_cancel_reject_code,.fill_cancel_rsp_valid,.fill_cancel_rsp_ready,.fill_cancel_rsp_slot,.fill_cancel_rsp_request,.fill_cancel_rsp_generation,.fill_cancel_rsp_epoch,
 .wr_valid(awr_valid),.wr_ready(awr_ready),.wr_row(awr_row),.wr_group(awr_group),.wr_data(awr_data),.wr_request(awr_request),.wr_generation(awr_generation),.wr_epoch(awr_epoch),.wr_rsp_valid(awr_rsp_valid),.wr_rsp_ready(awr_rsp_ready),.wr_rsp_row(awr_rsp_row),.wr_rsp_group(awr_rsp_group),
 .lease_valid(a_lease_valid),.lease_ready(a_lease_ready),.lease_slot(a_lease_slot),.lease_request(a_lease_request),.lease_generation(a_lease_generation),.lease_epoch(a_lease_epoch),.rd_valid(a_rd_valid),.rd_ready(a_rd_ready),.rd_slot(a_rd_slot),.rd_m(a_rd_m),.rd_group(a_rd_group),.rd_tag(a_rd_tag),.rd_request(a_rd_request),.rd_generation(a_rd_generation),.rd_epoch(a_rd_epoch),.rd_rsp_valid(a_rsp_valid),.rd_rsp_ready(a_rsp_ready),.rd_rsp_slot(a_rsp_slot),.rd_rsp_tag(a_rsp_tag),.rd_rsp_data(a_rsp_data),
 .ret_valid(a_ret_valid),.ret_ready(a_ret_ready),.ret_slot(a_ret_slot),.ret_tag(a_ret_tag),.ret_request(a_ret_request),.ret_generation(a_ret_generation),.ret_epoch(a_ret_epoch),.release_valid(a_release_valid),.release_ready(a_release_ready),.release_slot(a_release_slot),.release_request(a_release_request),.release_generation(a_release_generation),.release_epoch(a_release_epoch),.slot_valid(a_slot_valid),.slot_leased(a_slot_leased),.read_debt(a_read_debt));
 laya_m007_w_supply_v1 w_cache(.clk,.rst(!rst_n),.load_valid(wl_valid),.load_ready(wl_ready),.load_version(wl_version),.load_model(wl_model),.load_tensor(wl_tensor),.load_request(wl_request),.load_generation(wl_generation),.load_k(wl_k),.load_n(wl_n),.load_s(wl_s),.load_slot(wl_slot),.load_base(wl_base),.load_span(wl_span),.load_rsp_valid(wl_rsp_valid),.load_rsp_ready(wl_rsp_ready),.load_status(wl_status),.rsp_version(wl_rsp_version),.rsp_model(wl_rsp_model),.rsp_tensor(wl_rsp_tensor),.rsp_request(wl_rsp_request),.rsp_generation(wl_rsp_generation),.rsp_k(wl_rsp_k),.rsp_n(wl_rsp_n),.rsp_s(wl_rsp_s),.rsp_slot(wl_rsp_slot),.rsp_base(wl_rsp_base),.rsp_span(wl_rsp_span),.error_n(we_n),.error_g(we_g),.load_cycles(wl_cycles),.arvalid,.arready,.araddr,.arid,.arlen,.rvalid,.rready,.rid,.rdata,.rresp,.rlast,.peak_inflight(w_peak),.accepted_ar(w_ar_count),.accepted_r(w_r_count),
 .lease_valid(w_lease_valid),.lease_slot(w_lease_slot),.lease_ready(w_lease_ready),.lease_model(w_lease_model),.lease_request(w_lease_request),.lease_tensor(w_lease_tensor),.lease_generation(w_lease_generation),.rd_valid(w_rd_valid),.rd_ready(w_rd_ready),.rd_slot(w_rd_slot),.rd_addr(w_rd_addr),.rd_tag(w_rd_tag),.rd_model(w_rd_model),.rd_request(w_rd_request),.rd_tensor(w_rd_tensor),.rd_generation(w_rd_generation),.rd_rsp_valid(w_rsp_valid),.rd_rsp_ready(w_rsp_ready),.rd_rsp_data(w_rsp_data),.rd_rsp_tag(w_rsp_tag),.rd_rsp_slot(w_rsp_slot),.ret_valid(w_ret_valid),.ret_slot(w_ret_slot),.ret_tag(w_ret_tag),.ret_request(w_ret_request),.ret_generation(w_ret_generation),.ret_ready(w_ret_ready),.release_valid(w_release_valid),.release_slot(w_release_slot),.release_request(w_release_request),.release_generation(w_release_generation),.release_ready(w_release_ready),.slot_valid(w_slot_valid),.slot_leased(w_slot_leased));
endmodule
