`timescale 1ns/1ps
// One finite LN_FFN source window to the existing external quantizer port.
// Query and quantizer acceptance share one edge. This adapter holds the exact
// query packet through response retirement and the hub's drained release.
module laya_lnq0_external_quant_admission_v1 (
  input logic clk,rst_n,
  input logic candidate_valid,
  output logic candidate_ready,candidate_reject,
  input logic [8191:0] candidate_command,
  input logic bridge_can_accept,
  output logic bridge_ext_valid,
  input logic bridge_ext_ready,bridge_ext_reject,
  input logic bridge_done_valid,
  output logic bridge_done_ready,
  input logic candidate_done_ready,
  input logic physical_r_debt_zero,
  output logic source_query_valid,
  input logic source_query_ready,source_query_granted,
  output logic [8191:0] source_query_command,
  output logic source_release_valid,
  input logic source_release_ready,
  output logic [8191:0] source_release_command,
  output logic source_release_drained,
  output logic lease_pending,protocol_error,
  output logic ext_owner_admitted,ext_source_published,ext_a_slot,
  output logic [31:0] ext_a_slot_epoch,
  output logic [671:0] ext_numeric_identity,
  output logic [95:0] ext_producer_context,ext_quant_context,ext_linear_context,
  output logic [63:0] ext_source_ref,ext_a_ref,ext_w_ref,ext_dst_ref,
  output logic [12:0] ext_K,
  output logic [4:0] ext_rows,
  output logic [63:0] ext_bo_base,ext_bo_span,ext_region_base,ext_region_span,
  output logic [63:0] ext_row_stride_bytes,ext_batch_stride_bytes
);
  import laya_compute_portal_layout_v1::*;
  import laya_model_identity_13bo_generated_v1::*;
  localparam logic [63:0] STATE0_BASE=64'h300000000;
  localparam logic [63:0] STATE0_BYTES=64'd16920576;
  localparam logic [63:0] NORM_OFFSET=64'h800000;
  localparam logic [63:0] NORM_SPAN=64'd16384;
  // The bridge response may retire before its physical AXI R debt does.
  // Remember that retirement independently of the bridge's valid pulse.
  typedef enum logic [1:0] {IDLE,ACTIVE,DRAINING,RELEASING} state_t;
  state_t state;
  logic [8191:0] held_command;
  logic static_ok,query_fire,quant_fire;
  logic [95:0] producer,quant,linear;

  assign producer=candidate_command[PRODUCER_CONTEXT*8+:96];
  assign quant=candidate_command[QUANT_CONTEXT*8+:96];
  assign linear=candidate_command[LINEAR_CONTEXT*8+:96];
  always_comb begin
    static_ok=command_frame_ok(candidate_command) &&
      candidate_command[OP_STATUS*8+:16]==16'd2 &&
      candidate_command[MODEL_IDENTITY*8+:3328]==L13M_CANONICAL &&
      candidate_command[IDENTITY*8+20*8+:512]==L13M_CANONICAL[0+:512] &&
      candidate_command[CONTEXT*8+:96]==quant &&
      producer[39:32]==8'h12 && quant[39:32]==8'h20 &&
      linear[39:32]==8'h32 && producer[47:40]==8'd2 &&
      quant[47:40]==8'd2 && linear[47:40]==8'd2 &&
      producer[95:88]==8'd4 && quant[95:88]==8'd4 &&
      linear[95:88]==8'd4 &&
      candidate_command[SOURCE_REF*8+32+:8]==8'd2 &&
      candidate_command[SOURCE_REF*8+:32]==32'd9 &&
      candidate_command[A_REF*8+32+:8]==8'h22 &&
      candidate_command[W_REF*8+32+:8]==8'h23 &&
      // A QUANT service publishes into dualA; Wi later writes role 6.
      candidate_command[DST_REF*8+:64]==
        candidate_command[A_REF*8+:64] &&
      candidate_command[SOURCE_ROLE*8+:8]==8'd6 &&
      candidate_command[K*8+:16]==16'd1024 &&
      candidate_command[ROWS*8+:8]==8'd4 &&
      candidate_command[SOURCE_OFFSET*8+:64]==NORM_OFFSET &&
      candidate_command[SOURCE_SPAN*8+:64]==NORM_SPAN &&
      candidate_command[SOURCE_STRIDE*8+:64]==64'd4096 &&
      candidate_command[ROW_STRIDE*8+:64]==64'd4096 &&
      candidate_command[BATCH_STRIDE*8+:64]==64'd4194304 &&
      candidate_command[GENERATION*8+:64]!=0 &&
      candidate_command[A_EPOCH*8+:32]!=0 &&
      candidate_command[A_SLOT*8+:8]<2;
  end
  assign source_query_command=candidate_command;
  // bridge_can_accept is independent of bridge_ext_valid. The hub's grant
  // depends on source_query_valid, so this direction has no ready/valid loop.
  assign source_query_valid=state==IDLE && candidate_valid &&
      bridge_can_accept && static_ok;
  assign candidate_ready=state==IDLE && bridge_can_accept &&
      (!static_ok || source_query_ready);
  assign query_fire=source_query_valid && source_query_ready;
  assign bridge_ext_valid=query_fire && source_query_granted;
  assign quant_fire=bridge_ext_valid && bridge_ext_ready;
  assign ext_owner_admitted=bridge_ext_valid;
  assign ext_source_published=bridge_ext_valid;
  assign ext_numeric_identity=candidate_command[IDENTITY*8+:672];
  assign ext_producer_context=producer;
  assign ext_quant_context=quant;
  assign ext_linear_context=linear;
  assign ext_source_ref=candidate_command[SOURCE_REF*8+:64];
  assign ext_a_ref=candidate_command[A_REF*8+:64];
  assign ext_w_ref=candidate_command[W_REF*8+:64];
  assign ext_dst_ref=candidate_command[DST_REF*8+:64];
  assign ext_K=candidate_command[K*8+:13];
  assign ext_rows=candidate_command[ROWS*8+:5];
  assign ext_a_slot=candidate_command[A_SLOT*8];
  assign ext_a_slot_epoch=candidate_command[A_EPOCH*8+:32];
  assign ext_bo_base=STATE0_BASE;
  assign ext_bo_span=STATE0_BYTES;
  assign ext_region_base=STATE0_BASE+NORM_OFFSET;
  assign ext_region_span=NORM_SPAN;
  assign ext_row_stride_bytes=candidate_command[ROW_STRIDE*8+:64];
  assign ext_batch_stride_bytes=candidate_command[BATCH_STRIDE*8+:64];

  assign bridge_done_ready=state==ACTIVE && candidate_done_ready;
  assign source_release_valid=state==RELEASING && physical_r_debt_zero;
  assign source_release_command=held_command;
  assign source_release_drained=physical_r_debt_zero;
  assign lease_pending=state!=IDLE;
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      state<=IDLE;
      held_command<=0;
      candidate_reject<=0;
      protocol_error<=0;
    end else begin
      candidate_reject<=0;
      if(state==IDLE && candidate_valid && candidate_ready)begin
        if(!static_ok || !source_query_granted)candidate_reject<=1;
        else begin
          held_command<=candidate_command;
          if(quant_fire)state<=ACTIVE;
          else begin
            // A grant without the matched bridge handshake must be drained.
            protocol_error<=1;
            state<=RELEASING;
          end
        end
      end
      if(state==ACTIVE)begin
        if(bridge_ext_reject || (bridge_done_valid && bridge_done_ready))
          state<=DRAINING;
      end
      if(state==DRAINING && physical_r_debt_zero)state<=RELEASING;
      if(state==RELEASING && source_release_valid && source_release_ready)begin
        state<=IDLE;
        held_command<=0;
      end
    end
  end
endmodule
