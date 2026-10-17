`timescale 1ns/1ps

// One task binding, one quant16 instance, one start per complete row.
// The physical source feeder and complete dual-A publication are actual RTL.
module quant_task_to_dual_a_v1 #(parameter bit WI_PREFILL=1'b0) (
  input logic clk,rst_n,
  input logic cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic cfg_owner_admitted,cfg_source_published,cfg_a_slot,
  input logic [31:0] cfg_a_slot_epoch,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_producer_context,cfg_quant_context,cfg_linear_context,
  input logic [63:0] cfg_source_ref,cfg_a_ref,cfg_w_ref,cfg_dst_ref,
  input logic [12:0] cfg_K,
  input logic [4:0] cfg_rows,
  input logic [7:0] cfg_input_lanes,
  input logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes,
  output logic done_valid,
  input logic done_ready,
  output logic [2:0] done_status,
  output logic [63:0] done_bad_element,
  output logic task_debt_zero,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch,
  output logic [1:0][15:0] slot_rows_done,
  output logic [31:0] physical_half_commits,physical_scale_commits,
  output logic [31:0] source_ar_count,source_r_count,source_complete_rows,quant_starts,quant_input_beats,quant_rows,
  output logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns,mul_halves_issued,mul_halves_returned,
  output logic [63:0] command_cycles,
  output logic [63:0] m_axi_araddr,
  output logic [7:0] m_axi_arlen,
  output logic [2:0] m_axi_arsize,
  output logic [1:0] m_axi_arburst,
  output logic m_axi_arvalid,
  input logic m_axi_arready,
  input logic [511:0] m_axi_rdata,
  input logic [1:0] m_axi_rresp,
  input logic m_axi_rlast,m_axi_rvalid,
  output logic m_axi_rready,
  input logic acquire_valid,
  output logic acquire_ready,acquire_done,acquire_error,
  input logic acquire_slot,
  input logic [31:0] acquire_slot_epoch,
  input logic [12:0] acquire_K,
  input logic [4:0] acquire_rows,
  input logic [671:0] acquire_numeric_identity,
  input logic [95:0] acquire_linear_context,
  input logic [63:0] acquire_a_ref,acquire_w_ref,acquire_dst_ref,
  input logic read_valid,
  output logic read_ready,read_error,
  input logic read_slot,
  input logic [31:0] read_slot_epoch,
  input logic [671:0] read_numeric_identity,
  input logic [95:0] read_linear_context,
  input logic [63:0] read_a_ref,
  input logic [3:0] read_row_block_base,
  input logic [2:0] read_rows,
  input logic [6:0] read_group,
  output logic ret_valid,
  input logic ret_ready,
  output logic ret_slot,
  output logic [31:0] ret_slot_epoch,
  output logic [671:0] ret_numeric_identity,
  output logic [95:0] ret_linear_context,
  output logic [63:0] ret_a_ref,
  output logic [3:0] ret_row_block_base,
  output logic [2:0] ret_rows,
  output logic [6:0] ret_group,
  output logic [3:0][255:0] ret_q,
  output logic [3:0][15:0] ret_scale,
  input logic release_valid,
  output logic release_ready,release_done,release_error,
  input logic release_slot,
  input logic [31:0] release_slot_epoch,
  input logic [671:0] release_numeric_identity,
  input logic [95:0] release_linear_context,
  input logic [63:0] release_a_ref,
  output logic read_debt_zero,
  // Optional sequential Wi prefill of this same physical dual-A store.
  // The selector is held through finish; the normal quant task is idle then.
  input logic prefill_select,prefill_fill_valid,prefill_owner_admitted,prefill_source_published,
  input logic prefill_slot,
  input logic [31:0] prefill_slot_epoch,
  input logic [12:0] prefill_K,
  input logic [4:0] prefill_rows,
  input logic [671:0] prefill_numeric_identity,
  input logic [95:0] prefill_producer_context,prefill_quant_context,prefill_linear_context,
  input logic [63:0] prefill_source_ref,prefill_a_ref,prefill_w_ref,prefill_dst_ref,
  output logic prefill_fill_ready,prefill_fill_reject,
  input logic prefill_commit_valid,
  output logic prefill_commit_ready,prefill_commit_error,
  input logic [671:0] prefill_commit_numeric_identity,
  input logic [95:0] prefill_commit_quant_context,
  input logic [63:0] prefill_commit_a_ref,
  input logic [3:0] prefill_commit_row,
  input logic [6:0] prefill_commit_group,
  input logic prefill_commit_half,
  input logic [127:0] prefill_commit_q,
  input logic [15:0] prefill_commit_scale,
  input logic prefill_row_done_valid,
  output logic prefill_row_done_ready,
  input logic [3:0] prefill_row_done_row,
  input logic [1:0] prefill_row_done_status,
  input logic [15:0] prefill_row_done_bad_col,
  input logic prefill_row_done_debt_zero,prefill_finish_valid,prefill_finish_debt_zero,
  output logic prefill_finish_ready,prefill_fill_done,prefill_fill_error,prefill_publish_valid,
  output logic [63:0] prefill_fill_bad_element
);
  typedef enum logic [1:0] {IDLE,RUN,FINISH,REPORT} phase_t;
  phase_t phase;
  logic [3:0] quarantine;
  logic [671:0] numeric_id;
  logic [95:0] producer_ctx,quant_ctx,linear_ctx;
  logic [63:0] source_ref,a_ref,w_ref,dst_ref;
  logic a_slot;
  logic [31:0] a_slot_epoch;
  logic [12:0] K;
  logic [4:0] rows;
  logic [3:0] active_row;
  logic command_ok,admit,f_cfg_ready,f_cfg_reject,a_fill_ready,a_fill_reject;
  logic row_start_valid,row_start_ready;
  logic [31:0] row_task,row_epoch;
  logic [15:0] row_global;
  logic [7:0] row_groups;
  logic in_valid,in_ready;
  logic [511:0] in_lanes;
  logic [31:0] in_task,in_epoch;
  logic [15:0] in_row,in_mask;
  logic [6:0] in_group;
  logic in_half;
  logic q_out_valid,q_out_ready,q_out_half,q_done_valid,q_done_ready,q_debt_zero;
  logic [6:0] q_out_group;
  logic [127:0] q_out;
  logic [15:0] q_scale,q_bad;
  logic [31:0] q_d,q_recip,q_accepted,q_covered,q_ab,q_rb;
  logic [1:0] q_status;
  logic f_row_done_ready,a_row_done_ready,f_done_valid,f_done_ready,f_debt_zero;
  logic [2:0] f_done_status;
  logic [63:0] f_bad;
  logic [1:0][2:0] f_slot_state;
  logic a_commit_ready,a_commit_error,a_finish_ready,a_fill_done,a_fill_error,a_publish;
  logic [63:0] a_bad;
  logic [2:0] terminal_status;
  logic [63:0] terminal_bad;
  logic q_input_debt,q_slots_debt,q_div_debt,q_mul_debt;
  wire prefill_active=WI_PREFILL && prefill_select;
  assign prefill_fill_ready=prefill_active && a_fill_ready;
  assign prefill_fill_reject=prefill_active && a_fill_reject;
  assign prefill_commit_ready=prefill_active && a_commit_ready;
  assign prefill_commit_error=prefill_active && a_commit_error;
  assign prefill_row_done_ready=prefill_active && a_row_done_ready;
  assign prefill_finish_ready=prefill_active && a_finish_ready;
  assign prefill_fill_done=prefill_active && a_fill_done;
  assign prefill_fill_error=prefill_active && a_fill_error;
  assign prefill_publish_valid=prefill_active && a_publish;
  assign prefill_fill_bad_element=prefill_active ? a_bad : '1;
  // Atomic admission prevents one endpoint starting an invalid partial command.
  always_comb begin : admission
    logic [64:0] bend,rend;
    logic [127:0] first_addr,last_end,row_stride,batch_stride;
    logic [16:0] endrow;
    logic [15:0] row_limit;
    logic source_ok;
    source_ok=0;
    case(cfg_quant_context[47:40])
      2:source_ok=cfg_quant_context[71:64]==0 && ((cfg_K==1024 && (cfg_source_ref[39:32]==1 || cfg_source_ref[39:32]==2 || cfg_source_ref[39:32]==8)) || (cfg_K==2624 && cfg_source_ref[39:32]==7));
      4:source_ok=cfg_quant_context[71:64]==0 && ((cfg_K==1024 && (cfg_source_ref[39:32]==1 || cfg_source_ref[39:32]==2 || cfg_source_ref[39:32]==8)) || (cfg_K==4096 && cfg_source_ref[39:32]==9));
      5:source_ok=cfg_quant_context[71:64]==1 && cfg_K==1024 && cfg_source_ref[39:32]==10 && cfg_source_ref[55:48]==0;
      6:source_ok=cfg_quant_context[71:64]==2 && cfg_K==256 && cfg_source_ref[39:32]==10 && cfg_source_ref[55:48]==2;
      default:source_ok=0;
    endcase
    row_limit=cfg_quant_context[71:64]==0 ? cfg_numeric_identity[159:144] : cfg_quant_context[71:64]==1 ? 16 : 1;
    endrow={1'b0,cfg_quant_context[87:72]}+17'(cfg_rows);
    row_stride=128'(cfg_K)*4;batch_stride=row_stride*(cfg_quant_context[71:64]==0 ? 1024 : cfg_quant_context[71:64]==1 ? 16 : 1);
    bend={1'b0,cfg_bo_base}+{1'b0,cfg_bo_span};rend={1'b0,cfg_region_base}+{1'b0,cfg_region_span};
    first_addr=128'(cfg_region_base)+128'(cfg_quant_context[63:56])*128'(cfg_batch_stride_bytes)+128'(cfg_quant_context[87:72])*128'(cfg_row_stride_bytes);
    last_end=first_addr+128'(cfg_rows)*128'(cfg_row_stride_bytes);
    command_ok=cfg_input_lanes==8 && cfg_owner_admitted && cfg_source_published && source_ok &&
      cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 && cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 && cfg_rows>=1 && cfg_rows<=16 && cfg_quant_context[95:88]==cfg_rows && endrow<=row_limit &&
      cfg_quant_context[31:0]!=0 && cfg_linear_context[31:0]!=0 && cfg_quant_context[87:48]==cfg_linear_context[87:48] && cfg_quant_context[95:88]==cfg_linear_context[95:88] &&
      cfg_quant_context[63:56]<cfg_numeric_identity[143:128] && cfg_source_ref[31:0]!=0 && cfg_a_ref[31:0]!=0 &&
      cfg_a_ref[39:32]==8'h22 && cfg_a_ref[47:40]=={7'd0,cfg_a_slot} && cfg_a_ref[63:56]==0 && cfg_a_slot_epoch!=0 &&
      slot_epoch[cfg_a_slot]!=32'hffffffff && cfg_a_slot_epoch==slot_epoch[cfg_a_slot]+1 && (slot_state[cfg_a_slot]==0 || slot_state[cfg_a_slot]==4) &&
      cfg_row_stride_bytes==row_stride && cfg_batch_stride_bytes==batch_stride && cfg_bo_span!=0 && cfg_region_span!=0 && !bend[64] && !rend[64] &&
      cfg_region_base>=cfg_bo_base && rend<=bend && first_addr[127:64]==0 && last_end[127:64]==0 && first_addr[5:0]==0 && last_end<=128'(rend) && last_end<=128'(bend);
  end
  assign cfg_ready=rst_n && phase==IDLE && !done_valid && !prefill_active && quarantine==0 && f_cfg_ready && a_fill_ready;
  assign admit=cfg_valid && cfg_ready && command_ok;
  assign q_done_ready=f_row_done_ready && a_row_done_ready;
  assign q_out_ready=a_commit_ready;
  assign f_done_ready=phase==REPORT;
  assign task_debt_zero=f_debt_zero && q_debt_zero;
  quant_f32_two_row_feeder_v1 feeder(
    .clk,.rst_n,.cfg_valid(admit),.cfg_ready(f_cfg_ready),.cfg_reject(f_cfg_reject),.cfg_owner_admitted,.cfg_source_published,
    .cfg_numeric_identity,.cfg_producer_context,.cfg_quant_context,.cfg_source_ref,.cfg_K,.cfg_rows,
    .cfg_bo_base,.cfg_bo_span,.cfg_region_base,.cfg_region_span,.cfg_row_stride_bytes,.cfg_batch_stride_bytes,
    .m_axi_araddr,.m_axi_arlen,.m_axi_arsize,.m_axi_arburst,.m_axi_arvalid,.m_axi_arready,.m_axi_rdata,.m_axi_rresp,.m_axi_rlast,.m_axi_rvalid,.m_axi_rready,
    .row_start_valid,.row_start_ready,.row_cfg_task_id(row_task),.row_cfg_source_epoch(row_epoch),.row_cfg_row(row_global),.row_cfg_groups(row_groups),
    .in_valid,.in_ready,.in_lanes,.in_task_id(in_task),.in_source_epoch(in_epoch),.in_row,.in_group,.in_half,.in_mask,
    .row_done_valid(q_done_valid && a_row_done_ready),.row_done_ready(f_row_done_ready),.row_done_status(q_status),.row_done_bad_col(q_bad),.row_done_debt_zero(q_debt_zero),
    .done_valid(f_done_valid),.done_ready(f_done_ready),.done_status(f_done_status),.done_bad_element(f_bad),.debt_zero(f_debt_zero),
    .ar_count(source_ar_count),.r_count(source_r_count),.complete_rows(source_complete_rows),.quant_starts,.input_beats(quant_input_beats),.quant_rows,.slot_state(f_slot_state));
  quant16_stream_row quant(
    .clk,.rst(!rst_n),.start_valid(row_start_valid),.start_ready(row_start_ready),.cfg_task_id(row_task),.cfg_source_epoch(row_epoch),.cfg_row(row_global),.cfg_groups(row_groups),
    .in_valid,.in_ready,.in_lanes,.in_task_id(in_task),.in_source_epoch(in_epoch),.in_row,.in_group,.in_half,.in_mask,
    .out_valid(q_out_valid),.out_ready(q_out_ready),.out_group(q_out_group),.out_half(q_out_half),.out_q(q_out),.out_scale(q_scale),.out_d_full(q_d),.out_reciprocal(q_recip),
    .done_valid(q_done_valid),.done_ready(q_done_ready),.done_status(q_status),.first_bad_col(q_bad),.accepted_groups(q_accepted),.covered_groups(q_covered),
    .scale_issues,.scale_returns,.recip_issues,.recip_returns,.amax_read_beats(q_ab),.replay_read_beats(q_rb),.mul_halves_issued,.mul_halves_returned,
    .input_read_debt_zero(q_input_debt),.slot_debt_zero(q_slots_debt),.divider_helper_debt_zero(q_div_debt),.mul_return_debt_zero(q_mul_debt),.physical_debt_zero(q_debt_zero));
  quant_dual_a_v1 astore(
    .clk,.rst_n,.fill_valid(prefill_active ? prefill_fill_valid : admit),.fill_ready(a_fill_ready),.fill_reject(a_fill_reject),.fill_owner_admitted(prefill_active ? prefill_owner_admitted : cfg_owner_admitted),.fill_source_published(prefill_active ? prefill_source_published : cfg_source_published),
    .fill_slot(prefill_active ? prefill_slot : cfg_a_slot),.fill_slot_epoch(prefill_active ? prefill_slot_epoch : cfg_a_slot_epoch),.fill_K(prefill_active ? prefill_K : cfg_K),.fill_rows(prefill_active ? prefill_rows : cfg_rows),.fill_numeric_identity(prefill_active ? prefill_numeric_identity : cfg_numeric_identity),
    .fill_producer_context(prefill_active ? prefill_producer_context : cfg_producer_context),.fill_quant_context(prefill_active ? prefill_quant_context : cfg_quant_context),.fill_linear_context(prefill_active ? prefill_linear_context : cfg_linear_context),
    .fill_source_ref(prefill_active ? prefill_source_ref : cfg_source_ref),.fill_a_ref(prefill_active ? prefill_a_ref : cfg_a_ref),.fill_w_ref(prefill_active ? prefill_w_ref : cfg_w_ref),.fill_dst_ref(prefill_active ? prefill_dst_ref : cfg_dst_ref),
    .commit_valid(prefill_active ? prefill_commit_valid : q_out_valid),.commit_ready(a_commit_ready),.commit_error(a_commit_error),.commit_numeric_identity(prefill_active ? prefill_commit_numeric_identity : numeric_id),.commit_quant_context(prefill_active ? prefill_commit_quant_context : quant_ctx),.commit_a_ref(prefill_active ? prefill_commit_a_ref : a_ref),
    .commit_row(prefill_active ? prefill_commit_row : active_row),.commit_group(prefill_active ? prefill_commit_group : q_out_group),.commit_half(prefill_active ? prefill_commit_half : q_out_half),.commit_q(prefill_active ? prefill_commit_q : q_out),.commit_scale(prefill_active ? prefill_commit_scale : q_scale),
    .row_done_valid(prefill_active ? prefill_row_done_valid : q_done_valid && f_row_done_ready),.row_done_ready(a_row_done_ready),.row_done_row(prefill_active ? prefill_row_done_row : active_row),.row_done_status(prefill_active ? prefill_row_done_status : q_status),.row_done_bad_col(prefill_active ? prefill_row_done_bad_col : q_bad),.row_done_debt_zero(prefill_active ? prefill_row_done_debt_zero : q_debt_zero),
    .finish_valid(prefill_active ? prefill_finish_valid : phase==FINISH),.finish_ready(a_finish_ready),.finish_debt_zero(prefill_active ? prefill_finish_debt_zero : task_debt_zero),.fill_done(a_fill_done),.fill_error(a_fill_error),.publish_valid(a_publish),.fill_bad_element(a_bad),
    .slot_state,.slot_epoch,.slot_rows_done,.physical_half_commits,.physical_scale_commits,
    .acquire_valid,.acquire_ready,.acquire_done,.acquire_error,.acquire_slot,.acquire_slot_epoch,.acquire_K,.acquire_rows,.acquire_numeric_identity,.acquire_linear_context,.acquire_a_ref,.acquire_w_ref,.acquire_dst_ref,
    .read_valid,.read_ready,.read_error,.read_slot,.read_slot_epoch,.read_numeric_identity,.read_linear_context,.read_a_ref,.read_row_block_base,.read_rows,.read_group,
    .ret_valid,.ret_ready,.ret_slot,.ret_slot_epoch,.ret_numeric_identity,.ret_linear_context,.ret_a_ref,.ret_row_block_base,.ret_rows,.ret_group,.ret_q,.ret_scale,
    .release_valid,.release_ready,.release_done,.release_error,.release_slot,.release_slot_epoch,.release_numeric_identity,.release_linear_context,.release_a_ref,.read_debt_zero);
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      phase<=IDLE;quarantine<=12;numeric_id<=0;producer_ctx<=0;quant_ctx<=0;linear_ctx<=0;source_ref<=0;a_ref<=0;w_ref<=0;dst_ref<=0;
      a_slot<=0;a_slot_epoch<=0;K<=0;rows<=0;active_row<=0;terminal_status<=0;terminal_bad<='1;done_valid<=0;done_status<=0;done_bad_element<='1;cfg_reject<=0;command_cycles<=0;
    end else begin
      cfg_reject<=0;if(quarantine!=0)quarantine<=quarantine-1;
      if(cfg_valid && cfg_ready && !command_ok)cfg_reject<=1;
      if(admit)begin
        phase<=RUN;numeric_id<=cfg_numeric_identity;producer_ctx<=cfg_producer_context;quant_ctx<=cfg_quant_context;linear_ctx<=cfg_linear_context;
        source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;w_ref<=cfg_w_ref;dst_ref<=cfg_dst_ref;a_slot<=cfg_a_slot;a_slot_epoch<=cfg_a_slot_epoch;K<=cfg_K;rows<=cfg_rows;
        terminal_status<=0;terminal_bad<='1;command_cycles<=0;
      end
      if(phase!=IDLE && phase!=REPORT)command_cycles<=command_cycles+1;
      if(row_start_valid && row_start_ready)active_row<=4'(row_global-quant_ctx[87:72]);
      if(phase==RUN && f_done_valid)begin terminal_status<=f_done_status;terminal_bad<=f_bad;phase<=FINISH;end
      if(phase==FINISH && a_fill_done)begin
        phase<=REPORT;done_valid<=1;done_status<=terminal_status!=0 ? terminal_status : a_fill_error ? 2 : 0;
        done_bad_element<=terminal_status!=0 ? terminal_bad : a_fill_error ? a_bad : 64'hffffffffffffffff;
      end
      if(done_valid && done_ready)begin done_valid<=0;phase<=IDLE;end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(f_cfg_reject || a_fill_reject))else $fatal(1,"non-atomic quant task admission");
    if(done_valid && done_status==0)assert(slot_state[a_slot]==2 || slot_state[a_slot]==3)else $fatal(1,"successful task without A publication");
  end
`endif
endmodule
