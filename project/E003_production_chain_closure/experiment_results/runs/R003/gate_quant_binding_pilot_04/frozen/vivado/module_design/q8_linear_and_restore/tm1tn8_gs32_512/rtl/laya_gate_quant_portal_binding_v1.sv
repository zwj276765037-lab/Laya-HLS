`timescale 1ns/1ps
// One physical GEGLU/GATE-QUANT endpoint.  Both portal services share exactly
// one split G producer, one quantizer, and one dual-A cache.  Ordinary non-GATE
// QUANT commands are identified by the decoder for the later unified source
// mux; this endpoint admits only the GATE-backed subset.
module laya_gate_quant_portal_binding_v1(
  input logic clk,rst_n,
  input logic g_service_cancel,q_service_cancel,
  input logic g_service_command_valid,
  output logic g_service_command_ready,
  input logic q_service_command_valid,
  output logic q_service_command_ready,
  input logic [8191:0] service_command,
  output logic g_service_completion_valid,
  input logic g_service_completion_ready,
  output logic [4095:0] g_service_completion,
  output logic q_service_completion_valid,
  input logic q_service_completion_ready,
  output logic [4095:0] q_service_completion,
  input logic [12:0][63:0] latched_bo_base,latched_bo_span,
  input logic wi_axi_physical_debt_zero,gate_write_physical_debt_zero,
  input logic gate_read_physical_debt_zero,
  output logic g_physical_debt_zero,q_physical_debt_zero,
  output logic g_persistent_active,q_persistent_active,
  output logic [63:0] wi_axi_araddr,
  output logic [7:0] wi_axi_arlen,
  output logic [2:0] wi_axi_arsize,
  output logic [1:0] wi_axi_arburst,
  output logic wi_axi_arvalid,
  input logic wi_axi_arready,
  input logic [511:0] wi_axi_rdata,
  input logic [1:0] wi_axi_rresp,
  input logic wi_axi_rlast,wi_axi_rvalid,
  output logic wi_axi_rready,
  output logic [63:0] gate_axi_awaddr,
  output logic [7:0] gate_axi_awlen,
  output logic [2:0] gate_axi_awsize,
  output logic [1:0] gate_axi_awburst,
  output logic gate_axi_awvalid,
  input logic gate_axi_awready,
  output logic [511:0] gate_axi_wdata,
  output logic [63:0] gate_axi_wstrb,
  output logic gate_axi_wlast,gate_axi_wvalid,
  input logic gate_axi_wready,
  input logic [1:0] gate_axi_bresp,
  input logic gate_axi_bvalid,
  output logic gate_axi_bready,
  output logic [63:0] gate_axi_araddr,
  output logic [7:0] gate_axi_arlen,
  output logic [2:0] gate_axi_arsize,
  output logic [1:0] gate_axi_arburst,
  output logic gate_axi_arvalid,
  input logic gate_axi_arready,
  input logic [511:0] gate_axi_rdata,
  input logic [1:0] gate_axi_rresp,
  input logic gate_axi_rlast,gate_axi_rvalid,
  output logic gate_axi_rready,
  input logic a_acquire_valid,
  output logic a_acquire_ready,a_acquire_done,a_acquire_error,
  input logic a_acquire_slot,
  input logic [31:0] a_acquire_slot_epoch,
  input logic [12:0] a_acquire_K,
  input logic [4:0] a_acquire_rows,
  input logic [671:0] a_acquire_numeric_identity,
  input logic [95:0] a_acquire_linear_context,
  input logic [63:0] a_acquire_a_ref,a_acquire_w_ref,a_acquire_dst_ref,
  input logic a_read_valid,
  output logic a_read_ready,a_read_error,
  input logic a_read_slot,
  input logic [31:0] a_read_slot_epoch,
  input logic [671:0] a_read_numeric_identity,
  input logic [95:0] a_read_linear_context,
  input logic [63:0] a_read_a_ref,
  input logic [3:0] a_read_row_block_base,
  input logic [2:0] a_read_rows,
  input logic [6:0] a_read_group,
  output logic a_ret_valid,
  input logic a_ret_ready,
  output logic a_ret_slot,
  output logic [31:0] a_ret_slot_epoch,
  output logic [671:0] a_ret_numeric_identity,
  output logic [95:0] a_ret_linear_context,
  output logic [63:0] a_ret_a_ref,
  output logic [3:0] a_ret_row_block_base,
  output logic [2:0] a_ret_rows,
  output logic [6:0] a_ret_group,
  output logic [3:0][255:0] a_ret_q,
  output logic [3:0][15:0] a_ret_scale,
  input logic a_release_valid,
  output logic a_release_ready,a_release_done,a_release_error,
  input logic a_release_slot,
  input logic [31:0] a_release_slot_epoch,
  input logic [671:0] a_release_numeric_identity,
  input logic [95:0] a_release_linear_context,
  input logic [63:0] a_release_a_ref,
  output logic a_read_debt_zero,
  output logic [1:0][2:0] a_slot_state,
  output logic [1:0][31:0] a_slot_epoch,
  output logic [1:0][15:0] a_slot_rows_done,
  output logic [2:0] gate_owner_state,
  output logic [7:0] gate_next_window,
  output logic [127:0] gate_valid_windows,gate_covered_windows,gate_consumed_windows,
  output logic [2047:0] gate_covered_rows
);
  import laya_compute_portal_layout_v1::*;
  logic g_command_ok,q_command_ok,q_gate_command_ok;
  logic [671:0] cfg_identity;
  logic [95:0] cfg_producer,cfg_quant,cfg_linear;
  logic [63:0] cfg_source,cfg_a,cfg_w,cfg_ps,cfg_dst,cfg_future_dst;
  logic cfg_a_slot;logic [31:0] cfg_a_epoch;logic [6:0] cfg_window;
  logic [7:0] cfg_source_role,cfg_output_role,cfg_gate_region,cfg_dst_region;
  logic [63:0] cfg_source_bo_base,cfg_source_bo_span,cfg_source_region_base,cfg_source_region_span;
  logic [63:0] cfg_output_bo_base,cfg_output_bo_span,cfg_output_region_base,cfg_output_region_span;
  logic [327:0] cfg_output_binding;
  logic split_cancel,g_cfg_valid,g_cfg_ready,g_cfg_reject,g_cfg_admitted;
  logic q_cfg_valid,q_cfg_ready,q_cfg_reject;
  logic wi_cfg_valid,wi_cfg_ready,wi_cfg_reject;
  logic wi_valid,wi_ready;logic [31:0] wi_data,wi_status;
  logic [671:0] wi_numeric_identity;logic [63:0] wi_source_ref;
  logic [15:0] wi_row;logic [12:0] wi_index;
  logic wi_row_done_valid,wi_row_done_ready;logic [31:0] wi_row_done_status;
  logic [63:0] wi_row_bad_element;logic wi_read_debt_zero,wi_active;
  logic [31:0] wi_ar_count,wi_r_count,wi_complete_rows;
  logic g_done_valid,g_done_ready;logic [31:0] g_done_status,g_done_task_id,g_done_dst_epoch;
  logic [63:0] g_done_bad_element;logic [15:0] g_done_covered_rows;
  logic q_done_valid,q_done_ready;logic [31:0] q_done_status;logic [63:0] q_done_bad_element;
  logic tensor_published,split_cancel_done,writer_busy;
  logic tensor_release_valid,tensor_release_ready,tensor_release_done,tensor_release_error;
  logic [671:0] tensor_identity;logic [63:0] tensor_gate_ref;
  logic [31:0] gate_aw_count,gate_w_count,gate_b_count,gate_accepted_words;
  logic [63:0] gate_useful_bytes,gate_physical_bytes;
  logic [31:0] physical_half_commits,physical_scale_commits;
  logic [31:0] source_ar_count,source_r_count,source_complete_rows;
  logic [31:0] quant_starts,quant_input_beats,quant_rows;
  logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns;
  logic [31:0] mul_halves_issued,mul_halves_returned;
  logic [63:0] quant_command_cycles;
  logic g_active,g_rejected,g_inner_rejected,q_active,q_rejected;
  logic [63:0] g_cycles,q_cycles;
  logic [15:0] g_result_status,q_result_status;

  laya_gate_quant_portal_decode_v1 decode(
    .service_command,.latched_bo_base,.latched_bo_span,.g_command_ok,.q_command_ok,
    .q_gate_command_ok,.numeric_identity(cfg_identity),.producer_context(cfg_producer),
    .quant_context(cfg_quant),.linear_context(cfg_linear),.source_ref(cfg_source),
    .a_ref(cfg_a),.w_ref(cfg_w),.ps_ref(cfg_ps),.dst_ref(cfg_dst),
    .future_dst_ref(cfg_future_dst),.a_slot(cfg_a_slot),.a_slot_epoch(cfg_a_epoch),
    .window(cfg_window),.source_role(cfg_source_role),.output_role(cfg_output_role),
    .gate_region(cfg_gate_region),.dst_region(cfg_dst_region),
    .source_bo_base(cfg_source_bo_base),.source_bo_span(cfg_source_bo_span),
    .source_region_base(cfg_source_region_base),.source_region_span(cfg_source_region_span),
    .output_bo_base(cfg_output_bo_base),.output_bo_span(cfg_output_bo_span),
    .output_region_base(cfg_output_region_base),.output_region_span(cfg_output_region_span),
    .output_binding(cfg_output_binding));

  assign split_cancel=g_service_cancel || q_service_cancel;
  // writer_busy includes the held logical completion (window_done_valid).  It
  // therefore remains asserted until g_done_ready consumes that completion
  // and must not participate in the physical-debt predicate used to generate
  // g_done_ready.  The reader and the external AXI adapters carry the actual
  // accepted read/write debt; the split writer only raises g_done_valid after
  // its own last B and local write debt have retired.
  assign g_physical_debt_zero=wi_read_debt_zero && !wi_active &&
    wi_axi_physical_debt_zero && gate_write_physical_debt_zero;
  assign q_physical_debt_zero=gate_read_physical_debt_zero;
  assign g_persistent_active=(gate_owner_state>=1 && gate_owner_state<=3) || writer_busy;
  assign q_persistent_active=(a_slot_state[0]>=1 && a_slot_state[0]<=3) ||
    (a_slot_state[1]>=1 && a_slot_state[1]<=3);
  assign g_service_command_ready=!g_active && !g_rejected && !q_active && !q_rejected &&
    !split_cancel && g_physical_debt_zero &&
    (!g_command_ok || (g_cfg_ready && wi_cfg_ready));
  assign q_service_command_ready=!q_active && !q_rejected && !g_active && !g_rejected &&
    !split_cancel && q_physical_debt_zero && (!q_gate_command_ok || q_cfg_ready);
  assign g_cfg_valid=g_service_command_valid && g_service_command_ready && g_command_ok;
  assign wi_cfg_valid=g_cfg_admitted;
  assign q_cfg_valid=q_service_command_valid && q_service_command_ready && q_gate_command_ok;
  assign g_done_ready=g_active && !g_inner_rejected && g_service_completion_ready && g_physical_debt_zero;
  assign q_done_ready=q_active && q_service_completion_ready && q_physical_debt_zero;
  assign g_service_completion_valid=(g_rejected || g_inner_rejected ||
    (g_active && g_done_valid)) && g_physical_debt_zero;
  assign q_service_completion_valid=(q_rejected || (q_active && q_done_valid)) && q_physical_debt_zero;
  assign tensor_release_valid=tensor_gate_ref!=0;

  always_comb begin
    g_result_status=g_rejected || g_inner_rejected ? 16'd5 :
      g_done_status==0 ? 16'd0 : g_done_status==7 ? 16'd7 : 16'd6;
    g_service_completion=rejected_response(service_command,g_result_status,
      g_result_status==0 ? 0 : g_result_status==5 ? 32'h04000008 : 32'h0780000f);
    if(!g_rejected && !g_inner_rejected)begin
      g_service_completion[BAD_ELEMENT*8+:64]=g_done_bad_element;
      g_service_completion[CYCLES*8+:64]=g_cycles;
      g_service_completion[COUNTERS*8+:32]=wi_ar_count;
      g_service_completion[(COUNTERS+4)*8+:32]=wi_r_count;
      g_service_completion[(COUNTERS+8)*8+:32]=wi_complete_rows;
      g_service_completion[(COUNTERS+12)*8+:32]=gate_aw_count;
      g_service_completion[(COUNTERS+16)*8+:32]=gate_w_count;
      g_service_completion[(COUNTERS+20)*8+:32]=gate_b_count;
      g_service_completion[(COUNTERS+24)*8+:32]=gate_accepted_words;
      if(g_result_status==0)begin
        g_service_completion[ELEMENTS*8+:32]=32'(service_command[ROWS*8+:8])*2624;
        g_service_completion[UNIT*8+:8]=1;g_service_completion[RETIRE_FLAGS*8+1]=1;
      end
    end
    q_result_status=q_rejected ? 16'd5 : q_done_status==0 ? 16'd0 :
      q_done_status==7 ? 16'd7 : 16'd6;
    q_service_completion=rejected_response(service_command,q_result_status,
      q_result_status==0 ? 0 : q_result_status==5 ? 32'h04000008 : 32'h0780000f);
    if(!q_rejected)begin
      q_service_completion[BAD_ELEMENT*8+:64]=q_done_bad_element;
      q_service_completion[CYCLES*8+:64]=quant_command_cycles;
      q_service_completion[COUNTERS*8+:32]=source_ar_count;
      q_service_completion[(COUNTERS+4)*8+:32]=source_r_count;
      q_service_completion[(COUNTERS+8)*8+:32]=source_complete_rows;
      q_service_completion[(COUNTERS+12)*8+:32]=quant_starts;
      q_service_completion[(COUNTERS+16)*8+:32]=quant_input_beats;
      q_service_completion[(COUNTERS+20)*8+:32]=quant_rows;
      q_service_completion[(COUNTERS+24)*8+:32]=physical_half_commits;
      q_service_completion[(COUNTERS+28)*8+:32]=physical_scale_commits;
      q_service_completion[(COUNTERS+32)*8+:32]=scale_issues;
      q_service_completion[(COUNTERS+36)*8+:32]=scale_returns;
      q_service_completion[(COUNTERS+40)*8+:32]=recip_issues;
      q_service_completion[(COUNTERS+44)*8+:32]=recip_returns;
      if(q_result_status==0)begin
        q_service_completion[ELEMENTS*8+:32]=32'(service_command[ROWS*8+:8])*
          (32'(service_command[K*8+:16])>>5);
        q_service_completion[UNIT*8+:8]=2;q_service_completion[RETIRE_FLAGS*8+1]=1;
      end
    end
  end

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      g_active<=0;g_rejected<=0;g_inner_rejected<=0;q_active<=0;q_rejected<=0;
      g_cycles<=0;q_cycles<=0;tensor_identity<=0;tensor_gate_ref<=0;
    end else begin
      if(g_active && !g_service_completion_valid)g_cycles<=g_cycles+1;
      if(q_active && !q_service_completion_valid)q_cycles<=q_cycles+1;
      if(g_service_command_valid && g_service_command_ready)begin
        g_active<=g_command_ok;g_rejected<=!g_command_ok;g_inner_rejected<=0;g_cycles<=0;
      end
      if(q_service_command_valid && q_service_command_ready)begin
        q_active<=q_gate_command_ok;q_rejected<=!q_gate_command_ok;q_cycles<=0;
      end
      if(g_active && (g_cfg_reject || wi_cfg_reject))g_inner_rejected<=1;
      if(g_cfg_admitted)begin tensor_identity<=cfg_identity;tensor_gate_ref<=cfg_dst;end
      if(tensor_release_done && !tensor_release_error)begin tensor_identity<=0;tensor_gate_ref<=0;end
      if(g_service_completion_valid && g_service_completion_ready)begin
        g_active<=0;g_rejected<=0;g_inner_rejected<=0;
      end
      if(q_service_completion_valid && q_service_completion_ready)begin q_active<=0;q_rejected<=0;end
    end
  end

  laya_wi_axi_reader_v1 wi_reader(
    .clk,.rst_n,.cancel(split_cancel),.cfg_valid(wi_cfg_valid),.cfg_ready(wi_cfg_ready),
    .cfg_reject(wi_cfg_reject),.cfg_numeric_identity(cfg_identity),
    .cfg_producer_context(cfg_producer),.cfg_source_ref(cfg_source),
    .cfg_bo_base(cfg_source_bo_base),.cfg_bo_span(cfg_source_bo_span),
    .cfg_region_base(cfg_source_region_base),.cfg_region_span(cfg_source_region_span),
    .cfg_row_stride_bytes(64'd20992),.cfg_batch_stride_bytes(64'd21495808),
    .wi_valid,.wi_ready,.wi_data,.wi_status,.wi_numeric_identity,.wi_source_ref,
    .wi_row,.wi_index,.wi_row_done_valid,.wi_row_done_ready,.wi_row_done_status,
    .wi_row_bad_element,.read_debt_zero(wi_read_debt_zero),.active(wi_active),
    .ar_count(wi_ar_count),.r_count(wi_r_count),.complete_rows(wi_complete_rows),
    .m_axi_araddr(wi_axi_araddr),.m_axi_arlen(wi_axi_arlen),
    .m_axi_arsize(wi_axi_arsize),.m_axi_arburst(wi_axi_arburst),
    .m_axi_arvalid(wi_axi_arvalid),.m_axi_arready(wi_axi_arready),
    .m_axi_rdata(wi_axi_rdata),.m_axi_rresp(wi_axi_rresp),.m_axi_rlast(wi_axi_rlast),
    .m_axi_rvalid(wi_axi_rvalid),.m_axi_rready(wi_axi_rready));

  geglu_gate_quant_split_v2 split(
    .clk,.rst_n,.cancel(split_cancel),.g_cfg_valid,.g_cfg_ready,.g_cfg_reject,.g_cfg_admitted,
    .g_cfg_owner_admitted(g_command_ok),.g_cfg_plan_admitted(g_command_ok),
    .g_cfg_numeric_identity(cfg_identity),.g_cfg_producer_context(cfg_producer),
    .g_cfg_quant_context(cfg_quant),.g_cfg_linear_context(cfg_linear),
    .g_cfg_wi_ref(cfg_source),.g_cfg_gate_ref(cfg_dst),.g_cfg_a_ref(cfg_a),
    .g_cfg_w_ref(cfg_w),.g_cfg_ps_ref(cfg_ps),.g_cfg_down_dst_ref(cfg_future_dst),
    .g_cfg_gate_region(cfg_gate_region),.g_cfg_dst_region(cfg_dst_region),
    .g_cfg_output_binding(cfg_output_binding),.g_cfg_a_slot(cfg_a_slot),
    .g_cfg_a_slot_epoch(cfg_a_epoch),.g_cfg_bo_base(cfg_output_bo_base),
    .g_cfg_bo_span(cfg_output_bo_span),.g_cfg_region_base(cfg_output_region_base),
    .g_cfg_region_span(cfg_output_region_span),.wi_valid,.wi_ready,.wi_data,.wi_status,
    .wi_numeric_identity,.wi_source_ref,.wi_row,.wi_index,.wi_row_done_valid,
    .wi_row_done_ready,.wi_row_done_status,.wi_row_bad_element,
    .wi_read_debt_zero,.g_done_valid,.g_done_ready,.g_done_status,.g_done_task_id,
    .g_done_dst_epoch,.g_done_bad_element,.g_done_covered_rows,
    .q_cfg_valid,.q_cfg_ready,.q_cfg_reject,.q_cfg_owner_admitted(q_gate_command_ok),
    .q_cfg_numeric_identity(cfg_identity),.q_cfg_producer_context(cfg_producer),
    .q_cfg_quant_context(cfg_quant),.q_cfg_linear_context(cfg_linear),
    .q_cfg_gate_ref(cfg_source),.q_cfg_a_ref(cfg_a),.q_cfg_w_ref(cfg_w),
    .q_cfg_ps_ref(cfg_ps),.q_cfg_down_dst_ref(cfg_future_dst),
    .q_cfg_dst_region(cfg_dst_region),.q_cfg_window(cfg_window),
    .q_cfg_a_slot(cfg_a_slot),.q_cfg_a_slot_epoch(cfg_a_epoch),
    .q_cfg_bo_base(cfg_source_bo_base),.q_cfg_bo_span(cfg_source_bo_span),
    .q_cfg_region_base(cfg_source_region_base),.q_cfg_region_span(cfg_source_region_span),
    .q_done_valid,.q_done_ready,.q_done_status,.q_done_bad_element,
    .tensor_published,.cancel_done(split_cancel_done),.writer_busy,
    .gate_owner_state,.next_window(gate_next_window),.valid_windows(gate_valid_windows),
    .covered_windows(gate_covered_windows),.consumed_windows(gate_consumed_windows),
    .covered_rows(gate_covered_rows),.tensor_release_valid,.tensor_release_ready,
    .tensor_release_done,.tensor_release_error,
    .tensor_release_numeric_identity(tensor_identity),.tensor_release_ref(tensor_gate_ref),
    .tensor_release_debt_zero(gate_read_physical_debt_zero),.slot_state(a_slot_state),
    .slot_epoch(a_slot_epoch),.slot_rows_done(a_slot_rows_done),
    .aw_count(gate_aw_count),.w_count(gate_w_count),.b_count(gate_b_count),
    .accepted_words(gate_accepted_words),.useful_bytes(gate_useful_bytes),
    .physical_bytes(gate_physical_bytes),.physical_half_commits,.physical_scale_commits,
    .source_ar_count,.source_r_count,.source_complete_rows,.quant_starts,
    .quant_input_beats,.quant_rows,.scale_issues,.scale_returns,.recip_issues,.recip_returns,
    .mul_halves_issued,.mul_halves_returned,.quant_command_cycles,
    .m_axi_awaddr(gate_axi_awaddr),.m_axi_awlen(gate_axi_awlen),
    .m_axi_awsize(gate_axi_awsize),.m_axi_awburst(gate_axi_awburst),
    .m_axi_awvalid(gate_axi_awvalid),.m_axi_awready(gate_axi_awready),
    .m_axi_wdata(gate_axi_wdata),.m_axi_wstrb(gate_axi_wstrb),
    .m_axi_wlast(gate_axi_wlast),.m_axi_wvalid(gate_axi_wvalid),
    .m_axi_wready(gate_axi_wready),.m_axi_bresp(gate_axi_bresp),
    .m_axi_bvalid(gate_axi_bvalid),.m_axi_bready(gate_axi_bready),
    .m_axi_araddr(gate_axi_araddr),.m_axi_arlen(gate_axi_arlen),
    .m_axi_arsize(gate_axi_arsize),.m_axi_arburst(gate_axi_arburst),
    .m_axi_arvalid(gate_axi_arvalid),.m_axi_arready(gate_axi_arready),
    .m_axi_rdata(gate_axi_rdata),.m_axi_rresp(gate_axi_rresp),
    .m_axi_rlast(gate_axi_rlast),.m_axi_rvalid(gate_axi_rvalid),
    .m_axi_rready(gate_axi_rready),.acquire_valid(a_acquire_valid),
    .acquire_ready(a_acquire_ready),.acquire_done(a_acquire_done),
    .acquire_error(a_acquire_error),.acquire_slot(a_acquire_slot),
    .acquire_slot_epoch(a_acquire_slot_epoch),.acquire_K(a_acquire_K),
    .acquire_rows(a_acquire_rows),.acquire_numeric_identity(a_acquire_numeric_identity),
    .acquire_linear_context(a_acquire_linear_context),.acquire_a_ref(a_acquire_a_ref),
    .acquire_w_ref(a_acquire_w_ref),.acquire_dst_ref(a_acquire_dst_ref),
    .read_valid(a_read_valid),.read_ready(a_read_ready),.read_error(a_read_error),
    .read_slot(a_read_slot),.read_slot_epoch(a_read_slot_epoch),
    .read_numeric_identity(a_read_numeric_identity),.read_linear_context(a_read_linear_context),
    .read_a_ref(a_read_a_ref),.read_row_block_base(a_read_row_block_base),
    .read_rows(a_read_rows),.read_group(a_read_group),.ret_valid(a_ret_valid),
    .ret_ready(a_ret_ready),.ret_slot(a_ret_slot),.ret_slot_epoch(a_ret_slot_epoch),
    .ret_numeric_identity(a_ret_numeric_identity),.ret_linear_context(a_ret_linear_context),
    .ret_a_ref(a_ret_a_ref),.ret_row_block_base(a_ret_row_block_base),
    .ret_rows(a_ret_rows),.ret_group(a_ret_group),.ret_q(a_ret_q),.ret_scale(a_ret_scale),
    .release_valid(a_release_valid),.release_ready(a_release_ready),
    .release_done(a_release_done),.release_error(a_release_error),
    .release_slot(a_release_slot),.release_slot_epoch(a_release_slot_epoch),
    .release_numeric_identity(a_release_numeric_identity),
    .release_linear_context(a_release_linear_context),.release_a_ref(a_release_a_ref),
    .read_debt_zero(a_read_debt_zero));

`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(g_service_command_valid && q_service_command_valid))
      else $fatal(1,"G and Q portal commands asserted together");
    if(wi_axi_arvalid)assert(g_active)
      else $fatal(1,"WI AR without an admitted GEGLU command");
  end
`endif
endmodule
