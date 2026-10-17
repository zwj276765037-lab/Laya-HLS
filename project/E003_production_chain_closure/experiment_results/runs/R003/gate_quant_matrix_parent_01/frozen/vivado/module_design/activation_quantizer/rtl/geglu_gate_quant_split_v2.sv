`timescale 1ns/1ps

// Split GEGLU producer and QUANT consumer around one persistent GATE tensor.
// GEGLU commands only produce one physical window and return. A distinct QUANT
// command later acquires that recorded window, reads GATE and publishes full A.
module geglu_gate_quant_split_v2(
  input logic clk,rst_n,cancel,
  input logic g_cfg_valid,
  output logic g_cfg_ready,g_cfg_reject,
  input logic g_cfg_owner_admitted,g_cfg_plan_admitted,
  input logic [671:0] g_cfg_numeric_identity,
  input logic [95:0] g_cfg_producer_context,g_cfg_quant_context,g_cfg_linear_context,
  input logic [63:0] g_cfg_wi_ref,g_cfg_gate_ref,g_cfg_a_ref,g_cfg_w_ref,g_cfg_ps_ref,g_cfg_down_dst_ref,
  input logic [7:0] g_cfg_gate_region,g_cfg_dst_region,
  input logic [327:0] g_cfg_output_binding,
  input logic g_cfg_a_slot,
  input logic [31:0] g_cfg_a_slot_epoch,
  input logic [63:0] g_cfg_bo_base,g_cfg_bo_span,g_cfg_region_base,g_cfg_region_span,
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
  output logic g_done_valid,
  input logic g_done_ready,
  output logic [31:0] g_done_status,g_done_task_id,g_done_dst_epoch,
  output logic [63:0] g_done_bad_element,
  output logic [15:0] g_done_covered_rows,
  input logic q_cfg_valid,
  output logic q_cfg_ready,q_cfg_reject,
  input logic q_cfg_owner_admitted,
  input logic [671:0] q_cfg_numeric_identity,
  input logic [95:0] q_cfg_producer_context,q_cfg_quant_context,q_cfg_linear_context,
  input logic [63:0] q_cfg_gate_ref,q_cfg_a_ref,q_cfg_w_ref,q_cfg_ps_ref,q_cfg_down_dst_ref,
  input logic [7:0] q_cfg_dst_region,
  input logic [6:0] q_cfg_window,
  input logic q_cfg_a_slot,
  input logic [31:0] q_cfg_a_slot_epoch,
  input logic [63:0] q_cfg_bo_base,q_cfg_bo_span,q_cfg_region_base,q_cfg_region_span,
  output logic q_done_valid,
  input logic q_done_ready,
  output logic [31:0] q_done_status,
  output logic [63:0] q_done_bad_element,
  output logic tensor_published,cancel_done,writer_busy,
  output logic [2:0] gate_owner_state,
  output logic [7:0] next_window,
  output logic [127:0] valid_windows,covered_windows,consumed_windows,
  output logic [2047:0] covered_rows,
  input logic tensor_release_valid,
  output logic tensor_release_ready,tensor_release_done,tensor_release_error,
  input logic [671:0] tensor_release_numeric_identity,
  input logic [63:0] tensor_release_ref,
  input logic tensor_release_debt_zero,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch,
  output logic [1:0][15:0] slot_rows_done,
  output logic [31:0] aw_count,w_count,b_count,accepted_words,
  output logic [63:0] useful_bytes,physical_bytes,
  output logic [31:0] physical_half_commits,physical_scale_commits,
  output logic [31:0] source_ar_count,source_r_count,source_complete_rows,
  output logic [31:0] quant_starts,quant_input_beats,quant_rows,
  output logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns,
  output logic [31:0] mul_halves_issued,mul_halves_returned,
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
  typedef enum logic [3:0] {IDLE,G_RUN,Q_ACQUIRE,Q_CONFIG,Q_RUN,Q_RELEASE,Q_REPORT} phase_t;
  phase_t phase;
  logic store_claim_valid,store_claim_ready,store_claim_admitted,store_claim_rejected;
  logic store_done_valid,store_done_ready,store_done_write_debt_zero;
  logic [31:0] store_done_status,store_done_task_id,store_done_dst_epoch;
  logic [63:0] store_done_bad_element;
  logic [15:0] store_done_covered_rows;
  logic row_success,row_write_done_valid,row_write_done_ready,row_write_debt_zero;
  logic [15:0] row_success_row,row_write_row;
  logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch;
  logic [63:0] row_write_bad_element;
  logic v_valid,v_ready,v_last;
  logic [31:0] v_data,v_status,v_frame_tag;
  logic [15:0] v_row;
  logic [12:0] v_col;
  logic vector_cmd_ready,vector_cmd_reject,vector_done_valid,vector_done_ready;
  logic vector_arithmetic_debt_zero,vector_coverage;
  logic [31:0] vector_done_status;
  logic [63:0] vector_done_bad_element;
  logic [15:0] vector_done_bad_row;
  logic gate_acquire_valid_i,gate_acquire_ready_i,gate_acquire_done_i,gate_acquire_error_i;
  logic gate_release_valid_i,gate_release_ready_i,gate_release_done_i,gate_release_error_i;
  logic quant_cfg_ready,quant_cfg_reject,quant_done_valid,quant_done_ready,quant_task_debt_zero;
  logic [2:0] quant_done_status;
  logic [63:0] quant_done_bad_element;
  logic q_command_ok,q_cancel_pending;
  logic [671:0] q_identity;
  logic [95:0] q_producer,q_quant,q_linear;
  logic [63:0] q_gate,q_a,q_w,q_ps,q_dst,q_bo_base,q_bo_span,q_region_base,q_region_span;
  logic [7:0] q_dst_region;
  logic [6:0] q_window;
  logic q_slot,q_owner;
  logic [31:0] q_slot_epoch;
  logic [4:0] q_rows;
  logic [551:0] q_binding;
  logic [31:0] q_terminal_status;
  logic [63:0] q_terminal_bad;
  logic [6:0] q_derived_window;
  logic [31:0] g_ar_baseline,g_quant_baseline;

  always_comb begin
    q_derived_window=7'(q_cfg_quant_context[63:56])*
      7'((q_cfg_numeric_identity[159:144]+15)/16)+7'(q_cfg_quant_context[87:72]>>4);
    q_command_ok=q_cfg_owner_admitted && q_cfg_numeric_identity[63:0]!=0 &&
      q_cfg_numeric_identity[127:64]!=0 && q_cfg_numeric_identity[143:128]>=1 &&
      q_cfg_numeric_identity[143:128]<=2 && q_cfg_numeric_identity[159:144]>=64 &&
      q_cfg_numeric_identity[159:144]<=1024 && q_cfg_quant_context[39:32]==8'h20 &&
      q_cfg_producer_context[39:32]==8'h60 && q_cfg_linear_context[39:32]==8'h33 &&
      q_cfg_quant_context[47:40]==2 && q_cfg_quant_context[71:64]==0 &&
      q_cfg_quant_context[95:88]>=1 && q_cfg_quant_context[95:88]<=16 &&
      q_cfg_producer_context[87:40]==q_cfg_quant_context[87:40] &&
      q_cfg_linear_context[87:40]==q_cfg_quant_context[87:40] &&
      q_cfg_producer_context[95:88]==q_cfg_quant_context[95:88] &&
      q_cfg_linear_context[95:88]==q_cfg_quant_context[95:88] &&
      q_cfg_gate_ref[39:32]==7 && q_cfg_a_ref[39:32]==8'h22 &&
      q_cfg_w_ref[39:32]==8'h23 && q_cfg_ps_ref[39:32]==8'h24 &&
      q_cfg_down_dst_ref[39:32]==3 && q_cfg_a_ref[47:40]=={7'd0,q_cfg_a_slot} &&
      q_cfg_a_slot_epoch!=0 && q_cfg_window==q_derived_window;
  end

  assign g_cfg_ready=phase==IDLE && store_claim_ready && vector_cmd_ready && !q_done_valid;
  assign store_claim_valid=g_cfg_valid && phase==IDLE && vector_cmd_ready;
  assign g_cfg_reject=store_claim_rejected || vector_cmd_reject;
  wire g_admit=g_cfg_valid && g_cfg_ready && store_claim_admitted;
  assign g_done_valid=phase==G_RUN && store_done_valid;
  assign g_done_status=store_done_status;
  assign g_done_task_id=store_done_task_id;
  assign g_done_dst_epoch=store_done_dst_epoch;
  assign g_done_bad_element=store_done_bad_element;
  assign g_done_covered_rows=store_done_covered_rows;
  assign store_done_ready=phase==G_RUN && g_done_ready;
  assign q_cfg_ready=rst_n && phase==IDLE && !store_done_valid;
  assign gate_acquire_valid_i=phase==Q_ACQUIRE;
  assign gate_release_valid_i=phase==Q_RELEASE;
  assign quant_done_ready=phase==Q_RUN && quant_task_debt_zero;
  assign q_binding={q_producer,q_quant,q_linear,q_a,q_w,q_ps,q_dst,q_dst_region};

  geglu_canonical_row_adapter vector_row(
    .clk,.reset(!rst_n),.cmd_valid(g_admit),.cmd_ready(vector_cmd_ready),
    .cmd_reject(vector_cmd_reject),.cmd_numeric_identity(g_cfg_numeric_identity),
    .cmd_producer_context(g_cfg_producer_context),.cmd_quant_context(g_cfg_quant_context),
    .cmd_consumer_context(g_cfg_linear_context),.cmd_source_ref(g_cfg_wi_ref),
    .cmd_a_ref(g_cfg_a_ref),.cmd_w_ref(g_cfg_w_ref),.cmd_dst_ref(g_cfg_gate_ref),
    .cmd_region(g_cfg_gate_region),.cmd_batch(g_cfg_producer_context[63:56]),
    .cmd_k(13'd2624),.cmd_rows(5'(g_cfg_producer_context[95:88])),
    .cmd_row0(g_cfg_producer_context[87:72]),.cmd_a_slot({7'd0,g_cfg_a_slot}),
    .cmd_a_slot_epoch(g_cfg_a_slot_epoch),.wi_valid,.wi_ready,.wi_data,.wi_status,
    .wi_numeric_identity,.wi_source_ref,.wi_row,.wi_index,.wi_row_done_valid,
    .wi_row_done_ready,.wi_row_done_status,.wi_row_bad_element,.wi_read_debt_zero,
    .row_success,.row_success_row,.v_valid,.v_ready,.v_data,.v_status,.v_frame_tag,
    .v_row,.v_col,.v_last,.row_write_done_valid,.row_write_done_ready,
    .row_write_status,.row_write_task_id,.row_write_dst_epoch,.row_write_row,
    .row_write_bad_element,.row_write_debt_zero,.done_valid(vector_done_valid),
    .done_ready(vector_done_ready),.done_status(vector_done_status),
    .done_bad_element(vector_done_bad_element),.done_bad_row(vector_done_bad_row),
    .arithmetic_debt_zero(vector_arithmetic_debt_zero),
    .local_row_coverage_complete(vector_coverage));

  geglu_gate_tensor_store_v2 store(
    .clk,.rst_n,.cancel,.claim_valid(store_claim_valid),.claim_ready(store_claim_ready),
    .claim_admitted(store_claim_admitted),.claim_rejected(store_claim_rejected),
    .claim_plan_admitted(g_cfg_plan_admitted),.claim_numeric_identity(g_cfg_numeric_identity),
    .claim_producer_context(g_cfg_producer_context),.claim_quant_context(g_cfg_quant_context),
    .claim_linear_context(g_cfg_linear_context),.claim_source_ref(g_cfg_wi_ref),
    .claim_gate_ref(g_cfg_gate_ref),.claim_a_ref(g_cfg_a_ref),.claim_w_ref(g_cfg_w_ref),
    .claim_ps_ref(g_cfg_ps_ref),.claim_dst_ref(g_cfg_down_dst_ref),
    .claim_gate_region(g_cfg_gate_region),.claim_dst_region(g_cfg_dst_region),
    .claim_output_binding(g_cfg_output_binding),.claim_bo_base(g_cfg_bo_base),
    .claim_bo_span(g_cfg_bo_span),.claim_region_base(g_cfg_region_base),
    .claim_region_span(g_cfg_region_span),.row_success,.row_success_row,.v_valid,.v_ready,
    .v_data,.v_status,.v_frame_tag,.v_row,.v_col,.v_last,.row_write_done_valid,
    .row_write_done_ready,.row_write_status,.row_write_task_id,.row_write_dst_epoch,
    .row_write_row,.row_write_bad_element,.row_write_debt_zero,
    .service_done_valid(vector_done_valid),.service_done_ready(vector_done_ready),
    .service_done_status(vector_done_status),.service_done_bad_element(vector_done_bad_element),
    .service_read_debt_zero(wi_read_debt_zero),
    .service_arithmetic_debt_zero(vector_arithmetic_debt_zero),
    .producer_done_valid(store_done_valid),.producer_done_ready(store_done_ready),
    .producer_done_status(store_done_status),.producer_done_task_id(store_done_task_id),
    .producer_done_dst_epoch(store_done_dst_epoch),
    .producer_done_bad_element(store_done_bad_element),
    .producer_done_covered_rows(store_done_covered_rows),
    .producer_done_write_debt_zero(store_done_write_debt_zero),
    .tensor_published,.cancel_done,.writer_busy,.gate_owner_state,.next_window,
    .valid_windows,.covered_windows,.consumed_windows,.covered_rows,
    .gate_acquire_valid(gate_acquire_valid_i),.gate_acquire_ready(gate_acquire_ready_i),
    .gate_acquire_done(gate_acquire_done_i),.gate_acquire_error(gate_acquire_error_i),
    .gate_acquire_numeric_identity(q_identity),.gate_acquire_ref(q_gate),
    .gate_acquire_window(q_window),.gate_acquire_binding(q_binding),
    .gate_release_valid(gate_release_valid_i),.gate_release_ready(gate_release_ready_i),
    .gate_release_done(gate_release_done_i),.gate_release_error(gate_release_error_i),
    .gate_release_numeric_identity(q_identity),.gate_release_ref(q_gate),
    .gate_release_window(q_window),.gate_release_binding(q_binding),
    .gate_release_read_debt_zero(quant_task_debt_zero),.tensor_release_valid,
    .tensor_release_ready,.tensor_release_done,.tensor_release_error,
    .tensor_release_numeric_identity,.tensor_release_ref,.tensor_release_debt_zero,
    .aw_count,.w_count,.b_count,.accepted_words,.useful_bytes,.physical_bytes,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,.m_axi_awvalid,
    .m_axi_awready,.m_axi_wdata,.m_axi_wstrb,.m_axi_wlast,.m_axi_wvalid,
    .m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready);

  quant_task_to_dual_a_v1 quant_task(
    .clk,.rst_n,.cfg_valid(phase==Q_CONFIG),.cfg_ready(quant_cfg_ready),
    .cfg_reject(quant_cfg_reject),.cfg_owner_admitted(q_owner),
    .cfg_source_published(gate_owner_state==3),.cfg_a_slot(q_slot),
    .cfg_a_slot_epoch(q_slot_epoch),.cfg_numeric_identity(q_identity),
    .cfg_producer_context(q_producer),.cfg_quant_context(q_quant),
    .cfg_linear_context(q_linear),.cfg_source_ref(q_gate),.cfg_a_ref(q_a),
    .cfg_w_ref(q_w),.cfg_dst_ref(q_dst),.cfg_K(13'd2624),.cfg_rows(q_rows),
    .cfg_input_lanes(8'd8),.cfg_bo_base(q_bo_base),.cfg_bo_span(q_bo_span),
    .cfg_region_base(q_region_base),.cfg_region_span(q_region_span),
    .cfg_row_stride_bytes(64'd10496),.cfg_batch_stride_bytes(64'd10747904),
    .done_valid(quant_done_valid),.done_ready(quant_done_ready),
    .done_status(quant_done_status),.done_bad_element(quant_done_bad_element),
    .task_debt_zero(quant_task_debt_zero),.slot_state,.slot_epoch,.slot_rows_done,
    .physical_half_commits,.physical_scale_commits,.source_ar_count,.source_r_count,
    .source_complete_rows,.quant_starts,.quant_input_beats,.quant_rows,.scale_issues,
    .scale_returns,.recip_issues,.recip_returns,.mul_halves_issued,
    .mul_halves_returned,.command_cycles(quant_command_cycles),.m_axi_araddr,
    .m_axi_arlen,.m_axi_arsize,.m_axi_arburst,.m_axi_arvalid,.m_axi_arready,
    .m_axi_rdata,.m_axi_rresp,.m_axi_rlast,.m_axi_rvalid,.m_axi_rready,
    .acquire_valid,.acquire_ready,.acquire_done,.acquire_error,.acquire_slot,
    .acquire_slot_epoch,.acquire_K,.acquire_rows,.acquire_numeric_identity,
    .acquire_linear_context,.acquire_a_ref,.acquire_w_ref,.acquire_dst_ref,
    .read_valid,.read_ready,.read_error,.read_slot,.read_slot_epoch,
    .read_numeric_identity,.read_linear_context,.read_a_ref,.read_row_block_base,
    .read_rows,.read_group,.ret_valid,.ret_ready,.ret_slot,.ret_slot_epoch,
    .ret_numeric_identity,.ret_linear_context,.ret_a_ref,.ret_row_block_base,
    .ret_rows,.ret_group,.ret_q,.ret_scale,.release_valid,.release_ready,
    .release_done,.release_error,.release_slot,.release_slot_epoch,
    .release_numeric_identity,.release_linear_context,.release_a_ref,.read_debt_zero);

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      phase<=IDLE;q_cfg_reject<=0;q_done_valid<=0;q_done_status<=0;
      q_done_bad_element<='1;q_cancel_pending<=0;q_identity<=0;q_producer<=0;
      q_quant<=0;q_linear<=0;q_gate<=0;q_a<=0;q_w<=0;q_ps<=0;q_dst<=0;
      q_dst_region<=0;q_window<=0;q_slot<=0;q_owner<=0;q_slot_epoch<=0;q_rows<=0;
      q_bo_base<=0;q_bo_span<=0;q_region_base<=0;q_region_span<=0;
      q_terminal_status<=0;q_terminal_bad<='1;g_ar_baseline<=0;g_quant_baseline<=0;
    end else begin
      q_cfg_reject<=0;
      if(g_admit)begin
        phase<=G_RUN;g_ar_baseline<=source_ar_count;g_quant_baseline<=quant_starts;
      end
      if(phase==G_RUN && store_done_valid && store_done_ready)phase<=IDLE;
      if(q_cfg_valid && q_cfg_ready)begin
        if(!q_command_ok)q_cfg_reject<=1;
        else begin
          phase<=Q_ACQUIRE;q_identity<=q_cfg_numeric_identity;
          q_producer<=q_cfg_producer_context;q_quant<=q_cfg_quant_context;
          q_linear<=q_cfg_linear_context;q_gate<=q_cfg_gate_ref;q_a<=q_cfg_a_ref;
          q_w<=q_cfg_w_ref;q_ps<=q_cfg_ps_ref;q_dst<=q_cfg_down_dst_ref;
          q_dst_region<=q_cfg_dst_region;q_window<=q_cfg_window;q_slot<=q_cfg_a_slot;
          q_owner<=q_cfg_owner_admitted;q_slot_epoch<=q_cfg_a_slot_epoch;
          q_rows<=5'(q_cfg_quant_context[95:88]);
          q_bo_base<=q_cfg_bo_base;q_bo_span<=q_cfg_bo_span;
          q_region_base<=q_cfg_region_base;q_region_span<=q_cfg_region_span;
          q_terminal_status<=0;q_terminal_bad<='1;q_cancel_pending<=0;
        end
      end
      if(cancel && phase>=Q_ACQUIRE && phase<=Q_RELEASE)q_cancel_pending<=1;
      if(phase==Q_ACQUIRE && gate_acquire_done_i)begin
        if(gate_acquire_error_i)begin
          q_terminal_status<=2;q_terminal_bad<='1;q_done_status<=2;
          q_done_bad_element<='1;q_done_valid<=1;phase<=Q_REPORT;
        end else phase<=Q_CONFIG;
      end
      if(phase==Q_CONFIG && quant_cfg_ready)phase<=Q_RUN;
      if(phase==Q_RUN && quant_cfg_reject)begin
        q_terminal_status<=2;q_terminal_bad<='1;phase<=Q_RELEASE;
      end
      if(phase==Q_RUN && quant_done_valid && quant_done_ready)begin
        q_terminal_status<={29'd0,quant_done_status};
        q_terminal_bad<=quant_done_bad_element;phase<=Q_RELEASE;
      end
      if(phase==Q_RELEASE && gate_release_done_i)begin
        q_done_status<=q_cancel_pending ? 7 :
          gate_release_error_i ? 2 : q_terminal_status;
        q_done_bad_element<=q_terminal_bad;q_done_valid<=1;phase<=Q_REPORT;
      end
      if(phase==Q_REPORT && q_done_valid && q_done_ready)begin
        q_done_valid<=0;q_cancel_pending<=0;phase<=IDLE;
      end
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    if(m_axi_arvalid)
      assert(phase==Q_RUN && gate_owner_state==3)
        else $fatal(1,"GATE AR issued without a live QUANT command/window lease");
    if(phase==G_RUN)
      assert(!m_axi_arvalid && source_ar_count==g_ar_baseline && quant_starts==g_quant_baseline)
        else $fatal(1,"GEGLU command started fused QUANT work");
  end
`endif
endmodule
