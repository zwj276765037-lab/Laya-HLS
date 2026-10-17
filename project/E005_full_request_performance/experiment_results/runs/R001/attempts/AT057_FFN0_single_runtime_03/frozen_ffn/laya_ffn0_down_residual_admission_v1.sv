`timescale 1ns/1ps
// Finite, cold-request FFN handoff. The accepted Down command is the only
// authority for the TMP ticket. This is deliberately smaller than FullRuntime:
// one LN/Q binding, one G/Q binding, one Down, and one residual publication.
module laya_ffn0_down_residual_admission_v1 (
  input  logic clk, rst_n,
  input  logic source_q_accept,
  input  logic [8191:0] source_q_command,
  input  logic gate_accept,
  input  logic [671:0] gate_numeric_identity,
  input  logic [2:0] gate_rows,
  input  logic [12:0] gate_k,
  input  logic [95:0] gate_producer_context, gate_quant_context,
  input  logic [95:0] gate_linear_context,
  input  logic [63:0] gate_source_ref, gate_a_ref, gate_w_ref,
  input  logic [63:0] gate_dst_ref,
  input  logic down_candidate_valid,
  output logic down_candidate_ready, down_candidate_reject,
  output logic matrix_cfg_valid,
  input  logic matrix_cfg_ready, matrix_cfg_reject,
  input  logic ledger_claim_ready, ledger_claim_admitted,
  input  logic ledger_claim_reject,
  input  logic [15:0] cfg_k, cfg_n,
  input  logic [2:0] cfg_rows,
  input  logic [3:0] cfg_row_block,
  input  logic [671:0] cfg_numeric_identity,
  input  logic [95:0] cfg_linear_context,
  input  logic [63:0] cfg_source_ref, cfg_a_ref, cfg_w_ref,
  input  logic [63:0] cfg_ps_ref, cfg_dst_ref,
  input  logic [3327:0] cfg_w_model_identity,
  input  logic [31:0] cfg_a_epoch, cfg_w_epoch,
  input  logic [15:0] cfg_weight_key,
  input  logic [63:0] cfg_bo_base, cfg_bo_span,
  input  logic [63:0] cfg_region_base, cfg_region_span,
  input  logic [63:0] cfg_row_stride, cfg_batch_stride,
  input  logic down_awvalid, down_awready,
  input  logic [63:0] down_awaddr,
  input  logic [7:0] down_awlen,
  input  logic [2:0] down_awsize,
  input  logic down_wvalid, down_wready,
  input  logic [63:0] down_wstrb,
  input  logic down_wlast,
  input  logic down_bvalid, down_bready,
  input  logic [1:0] down_bresp,
  input  logic owner_retire_valid, owner_retire_ready,
  input  logic owner_retire_success,
  input  logic [2:0] ledger_dst_state,
  input  logic [31:0] ledger_parent_publications,
  input  logic ledger_retire_debt_zero,
  input  logic down_done_valid, down_done_ready,
  input  logic [15:0] down_done_status,
  input  logic residual_cfg_ready,
  output logic residual_cfg_valid,
  output logic [31:0] residual_request, residual_generation,
  output logic [95:0] residual_task_context,
  output logic [415:0] residual_local_context,
  output logic [127:0] residual_model_tag, residual_numeric_tag,
  output logic [127:0] residual_layout_tag, residual_build_tag,
  output logic [63:0] residual_src0_ref, residual_src1_ref,
  output logic [63:0] residual_dst_ref,
  input  logic residual_rsp_valid, residual_rsp_ready,
  input  logic [7:0] residual_rsp_status,
  input  logic residual_source_locked, residual_dst_published,
  input  logic [15:0] residual_skip_ar, residual_skip_r,
  input  logic [15:0] residual_down_ar, residual_down_r,
  input  logic [15:0] residual_add_start, residual_add_done,
  input  logic [15:0] residual_aw, residual_w, residual_b,
  output logic tmp_reserved, hidden_ticket_reserved,
  output logic hidden_published, handoff_error,
  output logic [15:0] observed_down_aw, observed_down_w,
  output logic [15:0] observed_down_b,
  output logic down_done_consumed, residual_accepted,
  output logic residual_consumed
);
  import laya_compute_portal_layout_v1::*;
  import laya_model_identity_13bo_generated_v1::L13M_CANONICAL;
  import laya_lnq0_bound_identity_generated_v1::W_IDENTITY;
  localparam logic [63:0] STATE1_BASE=64'h310000000;
  localparam logic [63:0] TMP_BASE=64'h310800000;
  localparam logic [63:0] TMP_REF=64'h0000000300000001;
  localparam logic [63:0] SKIP_REF=64'h0000000100000001;
  localparam logic [63:0] HIDDEN_REF=64'h0000010100000002;
  localparam logic [95:0] FFN_CONTEXT={8'd4,16'd0,8'd0,8'd0,8'd0,
                                      8'd2,8'h62,32'hac000007};
  typedef enum logic [2:0] {EMPTY, WAIT_DOWN, ISSUE_RESIDUAL,
                            WAIT_RESIDUAL, FINISHED, FAILED} state_t;
  state_t state;
  logic source_seen,gate_seen,ticket_used,retire_seen;
  logic [8191:0] source_command_held;
  logic [671:0] gate_numeric_held;
  logic [2:0] gate_rows_held;
  logic [12:0] gate_k_held;
  logic [95:0] gate_p_held,gate_q_held,gate_l_held;
  logic [63:0] gate_src_held,gate_a_held,gate_w_held,gate_dst_held;
  logic [95:0] down_context_held;
  logic [3327:0] canonical_held;
  logic [31:0] request_held,generation_held;
  logic [15:0] aw_beats,w_beats,b_beats;
  logic static_ok,accept_down;

  always_comb begin
    static_ok=source_seen && gate_seen && !ticket_used &&
      source_command_held[MODEL_IDENTITY*8+:3328]==L13M_CANONICAL &&
      source_command_held[IDENTITY*8+:64]==64'd3 &&
      source_command_held[GENERATION*8+:64]!=0 &&
      source_command_held[(IDENTITY+8)*8+:64]==64'd1 &&
      source_command_held[(IDENTITY+16)*8+:16]==16'd1 &&
      source_command_held[(IDENTITY+18)*8+:16]==16'd128 &&
      source_command_held[IDENTITY*8+20*8+:512]==L13M_CANONICAL[0+:512] &&
      cfg_numeric_identity==source_command_held[IDENTITY*8+:672] &&
      gate_numeric_held==cfg_numeric_identity &&
      gate_rows_held==3'd4 && gate_k_held==13'd2624 &&
      cfg_w_model_identity==W_IDENTITY &&
      gate_p_held[31:0]==32'hac000004 && gate_p_held[39:32]==8'h60 &&
      gate_q_held[31:0]==32'hac000005 && gate_q_held[39:32]==8'h20 &&
      gate_l_held[31:0]==32'hac000006 && gate_l_held[39:32]==8'h33 &&
      cfg_linear_context==gate_l_held &&
      gate_src_held==64'h0000000600000001 &&
      gate_dst_held==64'h0000000700000001 &&
      cfg_source_ref==gate_dst_held && cfg_a_ref==gate_a_held &&
      cfg_w_ref==gate_w_held && cfg_dst_ref==TMP_REF &&
      cfg_ps_ref==64'h0000002400000002 &&
      cfg_a_epoch==32'd2 && cfg_w_epoch==32'd2 &&
      cfg_weight_key==16'd4 && cfg_k==16'd2624 &&
      cfg_n==16'd1024 && cfg_rows==3'd4 && cfg_row_block==0 &&
      cfg_bo_base==STATE1_BASE && cfg_bo_span==64'd16919104 &&
      cfg_region_base==TMP_BASE && cfg_region_span==64'd8388608 &&
      cfg_row_stride==64'd4096 && cfg_batch_stride==64'd4194304 &&
      cfg_linear_context[40+:56]==gate_p_held[40+:56] &&
      cfg_linear_context[40+:56]==gate_q_held[40+:56] &&
      gate_p_held[31:0]<gate_q_held[31:0] &&
      gate_q_held[31:0]<cfg_linear_context[31:0];
    // Both consumers must be ready on the same edge.  Their ready signals
    // are independent of valid; neither may claim the command alone.
    matrix_cfg_valid=state==EMPTY && down_candidate_valid && static_ok &&
      !handoff_error && matrix_cfg_ready && ledger_claim_ready;
    down_candidate_ready=(state==FINISHED || state==FAILED) ||
      (state==EMPTY &&
       (!static_ok || (matrix_cfg_ready && ledger_claim_ready)));
    accept_down=matrix_cfg_valid && matrix_cfg_ready &&
      ledger_claim_ready && ledger_claim_admitted;
    residual_cfg_valid=state==ISSUE_RESIDUAL;
    residual_request=request_held;
    residual_generation=generation_held;
    residual_task_context=FFN_CONTEXT;
    residual_src0_ref=TMP_REF;
    residual_src1_ref=SKIP_REF;
    residual_dst_ref=HIDDEN_REF;
    residual_local_context='0;
    residual_local_context[0+:96]=FFN_CONTEXT;
    residual_local_context[96+:64]=TMP_REF;
    residual_local_context[160+:64]=SKIP_REF;
    residual_local_context[224+:64]=HIDDEN_REF;
    residual_local_context[288+:32]=request_held;
    residual_local_context[320+:32]=generation_held;
    residual_local_context[352+:32]=down_context_held[0+:32];
    residual_model_tag=canonical_held[0+:128];
    residual_numeric_tag=canonical_held[128+:128];
    residual_layout_tag=canonical_held[256+:128];
    residual_build_tag=canonical_held[384+:128];
  end

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=EMPTY;
      source_seen<=0;gate_seen<=0;ticket_used<=0;retire_seen<=0;
      source_command_held<='0;gate_p_held<='0;gate_q_held<='0;
      gate_numeric_held<='0;gate_rows_held<='0;gate_k_held<='0;
      gate_l_held<='0;gate_src_held<='0;gate_a_held<='0;
      gate_w_held<='0;gate_dst_held<='0;down_context_held<='0;
      canonical_held<='0;request_held<=0;generation_held<=0;
      aw_beats<=0;w_beats<=0;b_beats<=0;
      observed_down_aw<=0;observed_down_w<=0;observed_down_b<=0;
      tmp_reserved<=0;hidden_ticket_reserved<=0;hidden_published<=0;
      handoff_error<=0;down_candidate_reject<=0;
      down_done_consumed<=0;residual_accepted<=0;residual_consumed<=0;
    end else begin
      down_candidate_reject<=0;
      if(source_q_accept)begin
        if(source_seen || source_q_command[MODEL_IDENTITY*8+:3328]!=L13M_CANONICAL)
          handoff_error<=1;
        else begin source_seen<=1;source_command_held<=source_q_command;end
      end
      if(gate_accept)begin
        if(!source_seen || gate_seen)handoff_error<=1;
        else begin
          gate_seen<=1;gate_p_held<=gate_producer_context;
          gate_q_held<=gate_quant_context;gate_l_held<=gate_linear_context;
          gate_numeric_held<=gate_numeric_identity;
          gate_rows_held<=gate_rows;gate_k_held<=gate_k;
          gate_src_held<=gate_source_ref;gate_a_held<=gate_a_ref;
          gate_w_held<=gate_w_ref;gate_dst_held<=gate_dst_ref;
        end
      end
      if(state==EMPTY && down_candidate_valid && down_candidate_ready)begin
        if(!static_ok || !accept_down)down_candidate_reject<=1;
        else begin
          state<=WAIT_DOWN;ticket_used<=1;tmp_reserved<=1;
          hidden_ticket_reserved<=1;
          canonical_held<=source_command_held[MODEL_IDENTITY*8+:3328];
          request_held<=source_command_held[IDENTITY*8+:32];
          // Residual cfg_generation is the model request generation.  The
          // packet-header portal generation remains in source_command_held.
          generation_held<=source_command_held[(IDENTITY+8)*8+:32];
          down_context_held<=cfg_linear_context;
          aw_beats<=0;w_beats<=0;b_beats<=0;retire_seen<=0;
          observed_down_aw<=0;observed_down_w<=0;observed_down_b<=0;
        end
      end
      if((state==FINISHED || state==FAILED) && down_candidate_valid &&
         down_candidate_ready)
        down_candidate_reject<=1;
      if(state==WAIT_DOWN)begin
        if(matrix_cfg_reject || ledger_claim_reject)begin
          state<=FAILED;handoff_error<=1;
        end
        if(down_awvalid && down_awready)begin
          if(aw_beats>=256 || down_awaddr!=TMP_BASE+64'(aw_beats)*64 ||
             down_awlen!=0 || down_awsize!=6)begin
            state<=FAILED;handoff_error<=1;
          end else begin aw_beats<=aw_beats+1'b1;observed_down_aw<=observed_down_aw+1'b1;end
        end
        if(down_wvalid && down_wready)begin
          if(w_beats>=256 || w_beats>=aw_beats || down_wstrb!='1 || !down_wlast)begin
            state<=FAILED;handoff_error<=1;
          end else begin w_beats<=w_beats+1'b1;observed_down_w<=observed_down_w+1'b1;end
        end
        if(down_bvalid && down_bready)begin
          if(b_beats>=256 || b_beats>=w_beats || down_bresp!=0)begin
            state<=FAILED;handoff_error<=1;
          end else begin b_beats<=b_beats+1'b1;observed_down_b<=observed_down_b+1'b1;end
        end
        if(owner_retire_valid && owner_retire_ready)begin
          if(!owner_retire_success || b_beats!=256)begin
            state<=FAILED;handoff_error<=1;
          end else retire_seen<=1;
        end
        if(down_done_valid && down_done_ready)begin
          down_done_consumed<=1;
          if(down_done_status!=0 || !retire_seen ||
             aw_beats!=256 || w_beats!=256 || b_beats!=256 ||
             ledger_dst_state!=3'd2 || ledger_parent_publications!=2 ||
             !ledger_retire_debt_zero)begin
            state<=FAILED;handoff_error<=1;
          end else state<=ISSUE_RESIDUAL;
        end
      end
      if(state==ISSUE_RESIDUAL && residual_cfg_ready)begin
        residual_accepted<=1;
        state<=WAIT_RESIDUAL;
      end
      if(state==WAIT_RESIDUAL && residual_rsp_valid && residual_rsp_ready)begin
        residual_consumed<=1;
        if(residual_rsp_status!=0 || !residual_dst_published ||
           residual_source_locked ||
           residual_skip_ar!=256 || residual_skip_r!=256 ||
           residual_down_ar!=256 || residual_down_r!=256 ||
           residual_add_start!=4096 || residual_add_done!=4096 ||
           residual_aw!=256 || residual_w!=256 || residual_b!=256)begin
          state<=FAILED;handoff_error<=1;
        end else begin
          tmp_reserved<=0;hidden_ticket_reserved<=0;
          hidden_published<=1;state<=FINISHED;
        end
      end
    end
  end
endmodule
