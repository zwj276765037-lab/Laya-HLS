`timescale 1ns/1ps
// Real complete-WI adapter -> physical GATE writer/publication -> AXI F32
// feeder -> one resident row quantizer -> complete dual-A. Down leases the
// published A through the exposed ports. The outer owner admission is explicit.
module geglu_gate_quant_bridge_v1 (
  input logic clk,rst_n,cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic cfg_owner_admitted,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_producer_context,cfg_quant_context,cfg_linear_context,
  input logic [63:0] cfg_wi_ref,cfg_gate_ref,cfg_a_ref,cfg_w_ref,cfg_down_dst_ref,
  input logic [4:0] cfg_rows,
  input logic cfg_a_slot,
  input logic [31:0] cfg_a_slot_epoch,
  input logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic wi_valid,
  output logic wi_ready,
  input logic [31:0] wi_data,wi_status,
  input logic [671:0] wi_numeric_identity,
  input logic [63:0] wi_source_ref,
  input logic [15:0] wi_row,
  input logic [12:0] wi_index,
  input logic wi_row_done_valid,
  output logic wi_row_done_ready,
  input logic [31:0] wi_row_done_status,
  input logic [63:0] wi_row_bad_element,
  input logic wi_read_debt_zero,
  output logic done_valid,
  input logic done_ready,
  output logic [31:0] done_status,
  output logic [63:0] done_bad_element,
  output logic [2:0] gate_owner_state,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch,
  output logic [1:0][15:0] slot_rows_done,
  output logic [31:0] aw_count,w_count,b_count,accepted_words,
  output logic [63:0] useful_bytes,physical_bytes,
  output logic [31:0] physical_half_commits,physical_scale_commits,
  output logic [31:0] source_ar_count,source_r_count,source_complete_rows,quant_starts,quant_input_beats,quant_rows,
  output logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns,mul_halves_issued,mul_halves_returned,
  output logic [63:0] quant_command_cycles,
  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast,m_axi_wvalid,
  input logic m_axi_wready,
  input logic [1:0] m_axi_bresp,
  input logic m_axi_bvalid,
  output logic m_axi_bready,
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
  output logic read_debt_zero
);
  typedef enum logic [3:0] {IDLE,PRODUCE,ACQUIRE,QUANT_CFG,QUANT_RUN,RELEASE,REPORT} phase_t;
  phase_t phase;
  logic [671:0] identity_q;
  logic [95:0] producer_q,quant_q,linear_q;
  logic [63:0] gate_q,a_q,w_q,dst_q,bo_base_q,bo_span_q,region_base_q,region_span_q;
  logic [4:0] rows_q;
  logic slot_q;
  logic [31:0] slot_epoch_q,last_gate_epoch_q;
  logic admitted_owner_q;
  logic command_ok,admit,writer_cfg_ready,writer_cfg_reject,vector_cmd_ready,vector_cmd_reject;
  logic row_success,row_write_done_valid,row_write_done_ready,row_write_debt_zero;
  logic [15:0] row_success_row,row_write_row;
  logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch;
  logic [63:0] row_write_bad_element;
  logic v_valid,v_ready,v_last;
  logic [31:0] v_data,v_status,v_frame_tag;
  logic [15:0] v_row;
  logic [12:0] v_col;
  logic vector_done_valid,vector_done_ready,vector_arithmetic_debt_zero,vector_coverage;
  logic [31:0] vector_done_status;
  logic [63:0] vector_done_bad_element;
  logic [15:0] vector_done_bad_row;
  logic producer_done_valid,producer_done_ready,producer_done_write_debt_zero;
  logic [31:0] producer_done_status,producer_done_task_id,producer_done_dst_epoch;
  logic [63:0] producer_done_bad_element;
  logic [15:0] producer_done_covered_rows;
  logic gate_acquire_ready,gate_acquire_done,gate_acquire_error,gate_release_ready,gate_release_done,gate_release_error;
  logic quant_cfg_ready,quant_cfg_reject,quant_done_valid,quant_done_ready,quant_task_debt_zero;
  logic [2:0] quant_done_status;
  logic [63:0] quant_done_bad_element;
  always_comb begin : admission
    logic [64:0] bend,rend;
    logic [127:0] first_addr,last_end;
    logic [16:0] endrow;
    bend={1'b0,cfg_bo_base}+{1'b0,cfg_bo_span};rend={1'b0,cfg_region_base}+{1'b0,cfg_region_span};
    first_addr=128'(cfg_region_base)+128'(cfg_producer_context[63:56])*1024*10496+128'(cfg_producer_context[87:72])*10496;
    last_end=first_addr+128'(cfg_rows)*10496;
    endrow={1'b0,cfg_producer_context[87:72]}+17'(cfg_rows);
    command_ok=cfg_owner_admitted && vector_cmd_ready &&
      cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 && cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 && cfg_rows>=1 && cfg_rows<=16 && endrow<=cfg_numeric_identity[159:144] &&
      cfg_producer_context[31:0]!=0 && cfg_producer_context[39:32]==8'h60 && cfg_producer_context[47:40]==2 && cfg_producer_context[71:64]==0 && cfg_producer_context[95:88]==cfg_rows &&
      cfg_producer_context[63:56]<cfg_numeric_identity[143:128] && cfg_quant_context[87:40]==cfg_producer_context[87:40] && cfg_linear_context[87:40]==cfg_producer_context[87:40] &&
      cfg_quant_context[95:88]==cfg_rows && cfg_linear_context[95:88]==cfg_rows && cfg_quant_context[31:0]!=0 && cfg_linear_context[31:0]!=0 &&
      cfg_wi_ref[39:32]==6 && cfg_gate_ref[39:32]==7 && cfg_wi_ref[31:0]!=0 && cfg_gate_ref[31:0]!=0 && cfg_wi_ref[63:56]==0 && cfg_gate_ref[63:56]==0 && cfg_wi_ref[55:48]==cfg_gate_ref[55:48] &&
      cfg_gate_ref[31:0]>last_gate_epoch_q && cfg_a_ref[39:32]==8'h22 && cfg_a_ref[47:40]=={7'd0,cfg_a_slot} && cfg_a_ref[63:56]==0 && cfg_a_ref[31:0]!=0 && cfg_w_ref[39:32]==8'h23 && cfg_down_dst_ref[39:32]==3 &&
      cfg_a_slot_epoch!=0 && slot_epoch[cfg_a_slot]!=32'hffffffff && cfg_a_slot_epoch==slot_epoch[cfg_a_slot]+1 && (slot_state[cfg_a_slot]==0 || slot_state[cfg_a_slot]==4) &&
      cfg_bo_span!=0 && cfg_region_span!=0 && !bend[64] && !rend[64] && cfg_region_base>=cfg_bo_base && rend<=bend && first_addr[127:64]==0 && last_end[127:64]==0 && first_addr[5:0]==0 && last_end<=128'(rend) && last_end<=128'(bend);
  end
  assign cfg_ready=rst_n && phase==IDLE && writer_cfg_ready && !done_valid;
  assign admit=cfg_valid && cfg_ready && command_ok;
  assign producer_done_ready=phase==PRODUCE && producer_done_write_debt_zero;
  assign quant_done_ready=phase==QUANT_RUN && quant_task_debt_zero;
  geglu_canonical_row_adapter vector_row(
    .clk,.reset(!rst_n),.cmd_valid(admit),.cmd_ready(vector_cmd_ready),.cmd_reject(vector_cmd_reject),
    .cmd_numeric_identity(cfg_numeric_identity),.cmd_producer_context(cfg_producer_context),.cmd_quant_context(cfg_quant_context),.cmd_consumer_context(cfg_linear_context),
    .cmd_source_ref(cfg_wi_ref),.cmd_a_ref(cfg_a_ref),.cmd_w_ref(cfg_w_ref),.cmd_dst_ref(cfg_gate_ref),
    .cmd_region(cfg_wi_ref[55:48]),.cmd_batch(cfg_producer_context[63:56]),.cmd_k(13'd2624),.cmd_rows(cfg_rows),.cmd_row0(cfg_producer_context[87:72]),.cmd_a_slot({7'd0,cfg_a_slot}),.cmd_a_slot_epoch(cfg_a_slot_epoch),
    .wi_valid,.wi_ready,.wi_data,.wi_status,.wi_numeric_identity,.wi_source_ref,.wi_row,.wi_index,.wi_row_done_valid,.wi_row_done_ready,.wi_row_done_status,.wi_row_bad_element,.wi_read_debt_zero,
    .row_success,.row_success_row,.v_valid,.v_ready,.v_data,.v_status,.v_frame_tag,.v_row,.v_col,.v_last,
    .row_write_done_valid,.row_write_done_ready,.row_write_status,.row_write_task_id,.row_write_dst_epoch,.row_write_row,.row_write_bad_element,.row_write_debt_zero,
    .done_valid(vector_done_valid),.done_ready(vector_done_ready),.done_status(vector_done_status),.done_bad_element(vector_done_bad_element),.done_bad_row(vector_done_bad_row),.arithmetic_debt_zero(vector_arithmetic_debt_zero),.local_row_coverage_complete(vector_coverage));
  geglu_gate_writer_ledger_v1 writer(
    .clk,.rst_n,.cfg_valid(admit),.cfg_ready(writer_cfg_ready),.cfg_reject(writer_cfg_reject),.cfg_owner_admitted,
    .cfg_numeric_identity,.cfg_producer_context,.cfg_quant_context,.cfg_consumer_context(cfg_linear_context),.cfg_source_ref(cfg_wi_ref),.cfg_gate_ref,.cfg_a_ref,.cfg_w_ref,.cfg_down_dst_ref,.cfg_rows,.cfg_bo_base,.cfg_bo_span,.cfg_region_base,.cfg_region_span,
    .row_success,.row_success_row,.v_valid,.v_ready,.v_data,.v_status,.v_frame_tag,.v_row,.v_col,.v_last,
    .row_write_done_valid,.row_write_done_ready,.row_write_status,.row_write_task_id,.row_write_dst_epoch,.row_write_row,.row_write_bad_element,.row_write_debt_zero,
    .service_done_valid(vector_done_valid),.service_done_ready(vector_done_ready),.service_done_status(vector_done_status),.service_done_bad_element(vector_done_bad_element),.service_done_bad_row(vector_done_bad_row),.service_read_debt_zero(wi_read_debt_zero),.service_arithmetic_debt_zero(vector_arithmetic_debt_zero),
    .producer_done_valid,.producer_done_ready,.producer_done_status,.producer_done_task_id,.producer_done_dst_epoch,.producer_done_bad_element,.producer_done_covered_rows,.producer_done_write_debt_zero,.gate_owner_state,
    .gate_acquire_valid(phase==ACQUIRE && !gate_acquire_done),.gate_acquire_ready,.gate_acquire_done,.gate_acquire_error,.gate_acquire_numeric_identity(identity_q),.gate_acquire_quant_context(quant_q),.gate_acquire_ref(gate_q),
    .gate_release_valid(phase==RELEASE && !gate_release_done),.gate_release_ready,.gate_release_done,.gate_release_error,.gate_release_numeric_identity(identity_q),.gate_release_quant_context(quant_q),.gate_release_ref(gate_q),.gate_release_read_debt_zero(quant_task_debt_zero),
    .aw_count,.w_count,.b_count,.accepted_words,.useful_bytes,.physical_bytes,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,.m_axi_awvalid,.m_axi_awready,.m_axi_wdata,.m_axi_wstrb,.m_axi_wlast,.m_axi_wvalid,.m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready);
  quant_task_to_dual_a_v1 quant_task(
    .clk,.rst_n,.cfg_valid(phase==QUANT_CFG),.cfg_ready(quant_cfg_ready),.cfg_reject(quant_cfg_reject),.cfg_owner_admitted(admitted_owner_q),.cfg_source_published(gate_owner_state==3),.cfg_a_slot(slot_q),.cfg_a_slot_epoch(slot_epoch_q),
    .cfg_numeric_identity(identity_q),.cfg_producer_context(producer_q),.cfg_quant_context(quant_q),.cfg_linear_context(linear_q),.cfg_source_ref(gate_q),.cfg_a_ref(a_q),.cfg_w_ref(w_q),.cfg_dst_ref(dst_q),.cfg_K(13'd2624),.cfg_rows(rows_q),.cfg_input_lanes(8'd8),
    .cfg_bo_base(bo_base_q),.cfg_bo_span(bo_span_q),.cfg_region_base(region_base_q),.cfg_region_span(region_span_q),.cfg_row_stride_bytes(64'd10496),.cfg_batch_stride_bytes(64'd10747904),
    .done_valid(quant_done_valid),.done_ready(quant_done_ready),.done_status(quant_done_status),.done_bad_element(quant_done_bad_element),.task_debt_zero(quant_task_debt_zero),
    .slot_state,.slot_epoch,.slot_rows_done,.physical_half_commits,.physical_scale_commits,.source_ar_count,.source_r_count,.source_complete_rows,.quant_starts,.quant_input_beats,.quant_rows,.scale_issues,.scale_returns,.recip_issues,.recip_returns,.mul_halves_issued,.mul_halves_returned,.command_cycles(quant_command_cycles),
    .m_axi_araddr,.m_axi_arlen,.m_axi_arsize,.m_axi_arburst,.m_axi_arvalid,.m_axi_arready,.m_axi_rdata,.m_axi_rresp,.m_axi_rlast,.m_axi_rvalid,.m_axi_rready,
    .acquire_valid,.acquire_ready,.acquire_done,.acquire_error,.acquire_slot,.acquire_slot_epoch,.acquire_K,.acquire_rows,.acquire_numeric_identity,.acquire_linear_context,.acquire_a_ref,.acquire_w_ref,.acquire_dst_ref,
    .read_valid,.read_ready,.read_error,.read_slot,.read_slot_epoch,.read_numeric_identity,.read_linear_context,.read_a_ref,.read_row_block_base,.read_rows,.read_group,
    .ret_valid,.ret_ready,.ret_slot,.ret_slot_epoch,.ret_numeric_identity,.ret_linear_context,.ret_a_ref,.ret_row_block_base,.ret_rows,.ret_group,.ret_q,.ret_scale,
    .release_valid,.release_ready,.release_done,.release_error,.release_slot,.release_slot_epoch,.release_numeric_identity,.release_linear_context,.release_a_ref,.read_debt_zero);
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      phase<=IDLE;cfg_reject<=0;done_valid<=0;done_status<=0;done_bad_element<='1;
      last_gate_epoch_q<=0;admitted_owner_q<=0;identity_q<=0;producer_q<=0;quant_q<=0;linear_q<=0;gate_q<=0;a_q<=0;w_q<=0;dst_q<=0;rows_q<=0;slot_q<=0;slot_epoch_q<=0;
      bo_base_q<=0;bo_span_q<=0;region_base_q<=0;region_span_q<=0;
    end else begin
      cfg_reject<=0;
      if(cfg_valid && cfg_ready && !command_ok)cfg_reject<=1;
      if(admit)begin
        phase<=PRODUCE;last_gate_epoch_q<=cfg_gate_ref[31:0];admitted_owner_q<=cfg_owner_admitted;identity_q<=cfg_numeric_identity;producer_q<=cfg_producer_context;quant_q<=cfg_quant_context;linear_q<=cfg_linear_context;
        gate_q<=cfg_gate_ref;a_q<=cfg_a_ref;w_q<=cfg_w_ref;dst_q<=cfg_down_dst_ref;rows_q<=cfg_rows;slot_q<=cfg_a_slot;slot_epoch_q<=cfg_a_slot_epoch;
        bo_base_q<=cfg_bo_base;bo_span_q<=cfg_bo_span;region_base_q<=cfg_region_base;region_span_q<=cfg_region_span;
        done_status<=0;done_bad_element<='1;
      end
      if(phase==PRODUCE && producer_done_valid && producer_done_ready)begin
        if(producer_done_status!=0)begin phase<=REPORT;done_valid<=1;done_status<=producer_done_status;done_bad_element<=producer_done_bad_element;end
        else phase<=ACQUIRE;
      end
      if(phase==ACQUIRE && gate_acquire_done)begin
        if(gate_acquire_error)begin phase<=REPORT;done_valid<=1;done_status<=2;end else phase<=QUANT_CFG;
      end
      if(phase==QUANT_CFG && quant_cfg_ready)phase<=QUANT_RUN;
      if(phase==QUANT_RUN && quant_cfg_reject)begin done_status<=2;done_bad_element<='1;phase<=RELEASE;end
      if(phase==QUANT_RUN && quant_done_valid && quant_done_ready)begin done_status<={29'd0,quant_done_status};done_bad_element<=quant_done_bad_element;phase<=RELEASE;end
      if(phase==RELEASE && gate_release_done)begin
        if(gate_release_error)done_status<=2;
        phase<=REPORT;done_valid<=1;
      end
      if(done_valid && done_ready)begin done_valid<=0;phase<=IDLE;end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(writer_cfg_reject || vector_cmd_reject))else $fatal(1,"non-atomic GEGLU task admission");
    if(m_axi_arvalid)assert(gate_owner_state==3 && aw_count==b_count && w_count==b_count)else $fatal(1,"GATE read before physical task publication/lease");
    if(done_valid && done_status==0)assert(slot_state[slot_q]==2 || slot_state[slot_q]==3)else $fatal(1,"bridge success without complete A publication");
  end
`endif
endmodule
