`timescale 1ns/1ps
module m005_down_entry_short_tb_v1;
  logic clk, rst_n;
  logic source_q_accept;
  logic [8191:0] source_q_command;
  logic gate_accept;
  logic [671:0] gate_numeric_identity;
  logic [2:0] gate_rows;
  logic [12:0] gate_k;
  logic [95:0] gate_producer_context, gate_quant_context;
  logic [95:0] gate_linear_context;
  logic [63:0] gate_source_ref, gate_a_ref, gate_w_ref;
  logic [63:0] gate_dst_ref;
  logic down_candidate_valid;
  logic down_candidate_ready, down_candidate_reject;
  logic matrix_cfg_valid;
  logic matrix_cfg_ready, matrix_cfg_reject;
  logic ledger_claim_ready, ledger_claim_admitted;
  logic ledger_claim_reject;
  logic [15:0] cfg_k, cfg_n;
  logic [2:0] cfg_rows;
  logic [3:0] cfg_row_block;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_linear_context;
  logic [63:0] cfg_source_ref, cfg_a_ref, cfg_w_ref;
  logic [63:0] cfg_ps_ref, cfg_dst_ref;
  logic [3327:0] cfg_w_model_identity;
  logic [31:0] cfg_a_epoch, cfg_w_epoch;
  logic [15:0] cfg_weight_key;
  logic [63:0] cfg_bo_base, cfg_bo_span;
  logic [63:0] cfg_region_base, cfg_region_span;
  logic [63:0] cfg_row_stride, cfg_batch_stride;
  logic down_awvalid, down_awready;
  logic [63:0] down_awaddr;
  logic [7:0] down_awlen;
  logic [2:0] down_awsize;
  logic down_wvalid, down_wready;
  logic [63:0] down_wstrb;
  logic down_wlast;
  logic down_bvalid, down_bready;
  logic [1:0] down_bresp;
  logic owner_retire_valid, owner_retire_ready;
  logic owner_retire_success;
  logic [2:0] ledger_dst_state;
  logic [31:0] ledger_parent_publications;
  logic ledger_retire_debt_zero;
  logic down_done_valid, down_done_ready;
  logic [15:0] down_done_status;
  logic residual_cfg_ready;
  logic residual_cfg_valid;
  logic [31:0] residual_request, residual_generation;
  logic [95:0] residual_task_context;
  logic [415:0] residual_local_context;
  logic [127:0] residual_model_tag, residual_numeric_tag;
  logic [127:0] residual_layout_tag, residual_build_tag;
  logic [63:0] residual_src0_ref, residual_src1_ref;
  logic [63:0] residual_dst_ref;
  logic residual_rsp_valid, residual_rsp_ready;
  logic [7:0] residual_rsp_status;
  logic residual_source_locked, residual_dst_published;
  logic [15:0] residual_skip_ar, residual_skip_r;
  logic [15:0] residual_down_ar, residual_down_r;
  logic [15:0] residual_add_start, residual_add_done;
  logic [15:0] residual_aw, residual_w, residual_b;
  logic tmp_reserved, hidden_ticket_reserved;
  logic hidden_published, handoff_error;
  logic [15:0] observed_down_aw, observed_down_w;
  logic [15:0] observed_down_b;
  logic down_done_consumed, residual_accepted;
  logic residual_consumed;
  logic [511:0] query_beats[0:15];
  logic [3327:0] w_model[0:0];
  string ln_fixture,bound_fixture;

  logic wi_mode=1,wi_claim_valid=0;
  logic [95:0] wi_context;
  logic [63:0] wi_source_ref,wi_a_ref,wi_w_ref,wi_ps_ref,wi_dst_ref;
  logic [15:0] wi_k=1024,wi_n=5248;
  logic [2:0] wi_rows=4;
  logic [3:0] wi_row_block=0;
  logic ledger_retire_valid=0,ledger_retire_ready,ledger_retire_error;
  logic [2:0] ledger_ps_state,ledger_dst_state;
  logic [15:0] ledger_checked_rows,ledger_covered_rows;
  logic [31:0] ledger_claims,ledger_view_retirements,ledger_parent_publications;
  wire ledger_claim_valid=wi_mode ? wi_claim_valid : matrix_cfg_valid;
  laya_ffn0_down_residual_admission_v1 dut(.*);
  tm4tn8_matrix_owner_ledger_v2 ledger(
    .clk,.rst_n,
    .claim_valid(ledger_claim_valid),
    .claim_ready(ledger_claim_ready),
    .claim_admitted(ledger_claim_admitted),
    .claim_reject(ledger_claim_reject),
    .claim_K(wi_mode ? wi_k : cfg_k),
    .claim_N(wi_mode ? wi_n : cfg_n),
    .claim_rows(wi_mode ? wi_rows : cfg_rows),
    .claim_row_block_base(wi_mode ? wi_row_block : cfg_row_block),
    .claim_numeric_identity(cfg_numeric_identity),
    .claim_parent_context(wi_mode ? wi_context : cfg_linear_context),
    .claim_source_ref(wi_mode ? wi_source_ref : cfg_source_ref),
    .claim_a_ref(wi_mode ? wi_a_ref : cfg_a_ref),
    .claim_w_ref(wi_mode ? wi_w_ref : cfg_w_ref),
    .claim_ps_ref(wi_mode ? wi_ps_ref : cfg_ps_ref),
    .claim_dst_ref(wi_mode ? wi_dst_ref : cfg_dst_ref),
    .claim_model_identity(cfg_w_model_identity),
    .invalidate_valid(1'b0),
    .retire_valid(ledger_retire_valid),
    .retire_ready(ledger_retire_ready),
    .retire_error(ledger_retire_error),
    .retire_success(1'b1),
    .retire_debt_zero(1'b1),
    .retire_row_block_base(4'd0),
    .retire_rows(3'd4),
    .ps_state(ledger_ps_state),
    .dst_state(ledger_dst_state),
    .target_invalidated(),
    .parent_complete(),
    .parent_error(),
    .checked_rows(ledger_checked_rows),
    .covered_rows(ledger_covered_rows),
    .claims(ledger_claims),
    .view_retirements(ledger_view_retirements),
    .parent_publications(ledger_parent_publications)
  );
  initial clk=0;
  always #5 clk=~clk;
  integer cycle=0;
  always @(posedge clk) begin
    cycle++;
    if(cycle>100) $fatal(1,"M005 short clock advanced without closure");
  end
  task automatic tick(); @(posedge clk); #1; endtask
  initial begin
    rst_n=0;
    source_q_accept=0; source_q_command='0;
    gate_accept=0; gate_numeric_identity='0;
    gate_rows=0; gate_k=0;
    gate_producer_context='0; gate_quant_context='0;
    gate_linear_context='0; gate_source_ref='0;
    gate_a_ref='0; gate_w_ref='0; gate_dst_ref='0;
    down_candidate_valid=0;
    matrix_cfg_ready=1; matrix_cfg_reject=0;
    cfg_k=2624; cfg_n=1024; cfg_rows=4; cfg_row_block=0;
    cfg_numeric_identity='0; cfg_linear_context='0;
    cfg_source_ref='0; cfg_a_ref='0; cfg_w_ref='0;
    cfg_ps_ref=64'h0000002400000002;
    cfg_dst_ref=64'h0000000300000001;
    cfg_w_model_identity='0; cfg_a_epoch=2; cfg_w_epoch=2;
    cfg_weight_key=4;
    cfg_bo_base=64'h310000000; cfg_bo_span=16919104;
    cfg_region_base=64'h310800000; cfg_region_span=8388608;
    cfg_row_stride=4096; cfg_batch_stride=4194304;
    down_awvalid=0;down_awready=0;down_awaddr=0;down_awlen=0;down_awsize=0;
    down_wvalid=0;down_wready=0;down_wstrb=0;down_wlast=0;
    down_bvalid=0;down_bready=0;down_bresp=0;
    owner_retire_valid=0;owner_retire_ready=0;owner_retire_success=0;
    ledger_retire_debt_zero=1;
    down_done_valid=0;down_done_ready=0;down_done_status=0;
    residual_cfg_ready=0;residual_rsp_valid=0;residual_rsp_ready=0;
    residual_rsp_status=0;residual_source_locked=0;residual_dst_published=0;
    residual_skip_ar=0;residual_skip_r=0;residual_down_ar=0;residual_down_r=0;
    residual_add_start=0;residual_add_done=0;residual_aw=0;residual_w=0;residual_b=0;
    if(!$value$plusargs("LN_FIXTURE=%s",ln_fixture) ||
       !$value$plusargs("BOUND_FIXTURE=%s",bound_fixture))
      $fatal(1,"M005 short missing fixture");
    $readmemh({ln_fixture,"/source_query.hex"},query_beats);
    $readmemh({bound_fixture,"/model_identity.hex"},w_model);
    for(int i=0;i<16;i++)source_q_command[i*512+:512]=query_beats[i];
    source_q_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+32+:8]=8'h32;
    source_q_command[laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64]=
      64'h0000000600000001;
    cfg_numeric_identity=source_q_command[
      laya_compute_portal_layout_v1::IDENTITY*8+:672];
    cfg_w_model_identity=w_model[0];
    wi_context=source_q_command[
      laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
    wi_source_ref=source_q_command[
      laya_compute_portal_layout_v1::SOURCE_REF*8+:64];
    wi_a_ref=source_q_command[
      laya_compute_portal_layout_v1::A_REF*8+:64];
    wi_w_ref=source_q_command[
      laya_compute_portal_layout_v1::W_REF*8+:64];
    wi_ps_ref=source_q_command[
      laya_compute_portal_layout_v1::PS_REF*8+:64];
    wi_dst_ref=source_q_command[
      laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64];
    cfg_linear_context=wi_context;
    cfg_linear_context[31:0]=32'hac000006;
    cfg_linear_context[39:32]=8'h33;
    cfg_source_ref=64'h0000000700000001;
    cfg_a_ref=64'h0000002200000002;
    cfg_w_ref=64'h0000002300000002;
    gate_producer_context=cfg_linear_context;
    gate_producer_context[31:0]=32'hac000004;
    gate_producer_context[39:32]=8'h60;
    gate_quant_context=cfg_linear_context;
    gate_quant_context[31:0]=32'hac000005;
    gate_quant_context[39:32]=8'h20;
    gate_linear_context=cfg_linear_context;
    gate_numeric_identity=cfg_numeric_identity;
    gate_rows=4;gate_k=2624;
    gate_source_ref=64'h0000000600000001;
    gate_dst_ref=cfg_source_ref;
    gate_a_ref=cfg_a_ref;gate_w_ref=cfg_w_ref;
    repeat(4)tick();
    @(negedge clk);rst_n=1;
    @(negedge clk);wi_claim_valid=1;
    #1;
    $display("M005_WI_LEDGER_PRE cycle=%0d ready=%b admitted=%b ps=%h dst=%h",
      cycle,ledger_claim_ready,ledger_claim_admitted,wi_ps_ref,wi_dst_ref);
    if(ledger_claim_ready!==1'b1 || ledger_claim_admitted!==1'b1)
      $fatal(1,"M005 Wi ledger precondition not legal");
    tick();
    @(negedge clk);wi_claim_valid=0;
    @(negedge clk);ledger_retire_valid=1;
    if(ledger_retire_ready!==1'b1)
      $fatal(1,"M005 Wi retirement not ready");
    tick();
    @(negedge clk);ledger_retire_valid=0;wi_mode=0;
    if(ledger_parent_publications!==32'd1 || ledger_claims!==32'd1)
      $fatal(1,"M005 Wi ledger retirement missing");
    @(negedge clk);source_q_accept=1;
    tick();@(negedge clk);source_q_accept=0;gate_accept=1;
    tick();@(negedge clk);gate_accept=0;
    if(dut.source_seen!==1'b1 || dut.gate_seen!==1'b1 ||
       handoff_error!==1'b0)
      $fatal(1,"M005 source/G capture invalid");
    $display("M005_DOWN_ENTRY_BEFORE cycle=%0d time=%0t",cycle,$time);
    @(negedge clk);down_candidate_valid=1;
    #1;
    $display("M005_DOWN_ENTRY_SAMPLE cycle=%0d time=%0t static_ok=%b matrix_valid=%b matrix_ready=%b ledger_ready=%b ledger_admitted=%b candidate_ready=%b error=%b",
      cycle,$time,dut.static_ok,matrix_cfg_valid,matrix_cfg_ready,
      ledger_claim_ready,ledger_claim_admitted,down_candidate_ready,handoff_error);
    if({dut.static_ok,matrix_cfg_valid,matrix_cfg_ready,
        ledger_claim_ready,ledger_claim_admitted,down_candidate_ready,
        handoff_error} !== 7'b1111110)
      $fatal(1,"M005 Down entry nonlegal or unknown");
    tick();
    if(tmp_reserved!==1'b1 || hidden_ticket_reserved!==1'b1 ||
       ledger_claims!==32'd2)
      $fatal(1,"M005 Down claim was not accepted");
    $display("M005_DOWN_ENTRY_SHORT_PASS cycle=%0d",cycle);
    $finish;
  end
endmodule
