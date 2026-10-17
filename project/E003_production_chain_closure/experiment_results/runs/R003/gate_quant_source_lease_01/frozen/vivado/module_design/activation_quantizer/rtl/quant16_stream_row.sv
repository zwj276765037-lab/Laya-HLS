`timescale 1ns/1ps

// One-row stream candidate. The input producer supplies an already-published
// F32 row in two 16-lane beats per Group32. The output sink commits two 128b
// Q8 halves and a 16b scale; done/READY waits for every output handshake.
// There are 32 physical group slots, 16x64 F32 source banks, one actual F32
// divider and sixteen actual F32 multipliers. No software step is a clock.
module quant16_stream_row (
    input  logic         clk,
    input  logic         rst,
    input  logic         start_valid,
    output logic         start_ready,
    input  logic [31:0]  cfg_task_id,
    input  logic [31:0]  cfg_source_epoch,
    input  logic [15:0]  cfg_row,
    input  logic [7:0]   cfg_groups,
    input  logic         in_valid,
    output logic         in_ready,
    input  logic [511:0] in_lanes,
    input  logic [31:0]  in_task_id,
    input  logic [31:0]  in_source_epoch,
    input  logic [15:0]  in_row,
    input  logic [6:0]   in_group,
    input  logic         in_half,
    input  logic [15:0]  in_mask,
    output logic         out_valid,
    input  logic         out_ready,
    output logic [6:0]   out_group,
    output logic         out_half,
    output logic [127:0] out_q,
    output logic [15:0]  out_scale,
    output logic [31:0]  out_d_full,
    output logic [31:0]  out_reciprocal,
    output logic         done_valid,
    input  logic         done_ready,
    output logic [1:0]   done_status, // 0 READY, 1 numerical, 2 protocol
    output logic [15:0]  first_bad_col,
    output logic [31:0]  accepted_groups,
    output logic [31:0]  covered_groups,
    output logic [31:0]  scale_issues,
    output logic [31:0]  scale_returns,
    output logic [31:0]  recip_issues,
    output logic [31:0]  recip_returns,
    output logic [31:0]  amax_read_beats,
    output logic [31:0]  replay_read_beats,
    output logic [31:0]  mul_halves_issued,
    output logic [31:0]  mul_halves_returned,
    output logic         input_read_debt_zero,slot_debt_zero,
    output logic         divider_helper_debt_zero,mul_return_debt_zero,
    output logic         physical_debt_zero,
    // Held diagnostics of the most recently retired group. This also records
    // ERROR_SLOT arithmetic results when no Q payload may be committed.
    output logic [31:0]  retired_d_full,retired_reciprocal,
    output logic [15:0]  retired_scale
);
  import r0_fp_bits_pkg::*;
  localparam logic [3:0] FREE=0,FILL=1,AMAX_READY=2,AMAX_READ=3,
                         SCALE_REQ=4,SCALE_WAIT=5,RECIP_REQ=6,
                         RECIP_WAIT=7,QUANT_READY=8,REPLAY_READ=9,
                         MUL_WAIT=10,Q_DRAIN=11,ERROR_SLOT=12;
  logic active, protocol_error, numerical_error;
  logic [31:0] task_epoch, task_id, source_epoch;
  logic [15:0] row;
  logic [7:0] groups, capture_group, write_group, drain_groups;
  logic capture_half, write_half;
  logic [63:0] first_error_key;
  logic [3:0] state [0:31];
  logic [31:0] slot_epoch [0:31], ordinal [0:31];
  logic [31:0] amax [0:31], d_full [0:31], reciprocal [0:31];
  logic [15:0] scale [0:31];
  logic [127:0] q0 [0:31], q1 [0:31];
  logic [1:0] q_received [0:31];
  logic slot_nonfinite [0:31];

  wire start_fire=start_valid && start_ready;
  wire in_fire=in_valid && in_ready;
  wire out_fire=out_valid && out_ready;
  assign start_ready=!rst && !active && !done_valid && task_epoch!=32'hffffffff;
  assign in_ready=active && !protocol_error && capture_group<groups &&
      (capture_half ? state[capture_group[4:0]]==FILL :
                      state[capture_group[4:0]]==FREE);
  assign out_group=write_group;
  assign out_half=write_half;
  assign out_valid=active && write_group<drain_groups &&
                   state[write_group[4:0]]==Q_DRAIN;
  assign out_q=write_half ? q1[write_group[4:0]] : q0[write_group[4:0]];
  assign out_scale=write_half ? scale[write_group[4:0]] : 16'd0;
  assign out_d_full=d_full[write_group[4:0]];
  assign out_reciprocal=reciprocal[write_group[4:0]];

  // The single bank read port alternates whole two-beat AMAX/REPLAY groups.
  logic read_active, read_kind, read_half, prefer_replay;
  logic [4:0] read_slot;
  logic [4:0] amax_choice, replay_choice, chosen_slot;
  logic have_amax, have_replay, chosen_kind, bank_read_valid;
  logic [101:0] bank_read_tag, bank_return_tag;
  logic bank_return_kind;
  logic bank_return_valid;
  logic [511:0] bank_return_lanes;
  logic [6:0] bank_reads_pending;
  logic [2:0] mul_quarantine;
  always_comb begin
    have_amax=0; have_replay=0;
    amax_choice=0; replay_choice=0;
    for (int i=0;i<32;i++) begin
      if (state[i]==AMAX_READY &&
          (!have_amax || ordinal[i]<ordinal[amax_choice])) begin
        have_amax=1; amax_choice=5'(i);
      end
      if (state[i]==QUANT_READY &&
          (!have_replay || ordinal[i]<ordinal[replay_choice])) begin
        have_replay=1; replay_choice=5'(i);
      end
    end
    chosen_kind=read_active ? read_kind :
        (have_amax && have_replay ? prefer_replay : have_replay);
    chosen_slot=read_active ? read_slot :
        (chosen_kind ? replay_choice : amax_choice);
    bank_read_valid=active && !rst && !start_fire &&
        (read_active || (have_amax || have_replay)) &&
        (!chosen_kind || mul_quarantine==0);
    bank_read_tag={task_epoch,slot_epoch[chosen_slot],chosen_slot,
                   ordinal[chosen_slot],read_active ? read_half : 1'b0};
  end
  quant16_slot_banks banks (
      .clk(clk),.rst(rst),.write_valid(in_fire && !protocol_error &&
          in_task_id==task_id && in_source_epoch==source_epoch &&
          in_row==row && in_group==capture_group &&
          in_half==capture_half && in_mask==16'hffff),
      .write_slot(capture_group[4:0]),.write_half(capture_half),
      .write_lanes(in_lanes),.read_valid(bank_read_valid),
      .read_slot(chosen_slot),.read_half(read_active ? read_half : 1'b0),
      .read_return_valid(bank_return_valid),
      .read_return_lanes(bank_return_lanes));
  always_ff @(posedge clk) begin
    if (rst || start_fire) begin
      bank_return_tag<='0;
      bank_return_kind<=0;
    end else if (bank_read_valid) begin
      bank_return_tag<=bank_read_tag;
      bank_return_kind<=chosen_kind;
    end
  end

  wire amax_req_valid=bank_return_valid && !bank_return_kind && active;
  wire amax_ret_valid;
  wire [31:0] amax_ret_bits;
  wire [3:0] amax_ret_lane;
  wire [4:0] amax_bad_lane;
  wire [101:0] amax_ret_tag;
  logic [6:0] amax_pending;
  quant16_amax16 max16 (
      .clk(clk),.rst(rst || start_fire),.req_valid(amax_req_valid),
      .req_lanes(bank_return_lanes),.req_tag(bank_return_tag),
      .ret_valid(amax_ret_valid),.ret_amax_bits(amax_ret_bits),
      .ret_max_lane(amax_ret_lane),.ret_first_bad_lane(amax_bad_lane),
      .ret_tag(amax_ret_tag));

  // One divider transaction per clock if ready; choose the oldest ordinal in
  // each phase and alternate phases when both have work.
  logic prefer_recip;
  logic have_scale, have_recip, div_phase;
  logic [4:0] scale_choice, recip_choice, div_slot;
  wire div_req_valid, div_req_ready, div_resp_valid, div_protocol_fault;
  wire [31:0] div_resp_bits;
  wire [101:0] div_resp_tag;
  wire [5:0] div_pending;
  wire [1:0] div_route = div_phase ?
      (is_subnormal(d_full[div_slot]) ? 2'd2 : 2'd0) :
      (amax[div_slot] <= R0_TINY_MAX ? 2'd1 : 2'd0);
  wire [31:0] div_numerator = div_phase ? 32'h3f800000 :
      (div_route == 2'd1 ? 32'h00000000 : amax[div_slot]);
  wire [31:0] div_denominator = div_phase ?
      (div_route == 2'd2 ? subnormal_up24(d_full[div_slot]) :
                           d_full[div_slot]) : 32'h42fe0000;
  wire [101:0] div_tag={task_epoch,slot_epoch[div_slot],div_slot,
                        ordinal[div_slot],div_phase};
  always_comb begin
    have_scale=0; have_recip=0;
    scale_choice=0; recip_choice=0;
    for (int i=0;i<32;i++) begin
      if (state[i]==SCALE_REQ &&
          (!have_scale || ordinal[i]<ordinal[scale_choice])) begin
        have_scale=1; scale_choice=5'(i);
      end
      if (state[i]==RECIP_REQ &&
          (!have_recip || ordinal[i]<ordinal[recip_choice])) begin
        have_recip=1; recip_choice=5'(i);
      end
    end
    div_phase=have_scale && have_recip ? prefer_recip : have_recip;
    div_slot=div_phase ? recip_choice : scale_choice;
  end
  assign div_req_valid=active && (have_scale || have_recip) && !rst;
  wire div_fire=div_req_valid && div_req_ready;
  quant16_divider_service divider (
      .clk(clk),.rst(rst || start_fire),.req_valid(div_req_valid),
      .req_ready(div_req_ready),.req_numerator(div_numerator),
      .req_denominator(div_denominator),.req_tiny_amax(amax[div_slot]),
      .req_route(div_route),.req_tag(div_tag),
      .resp_valid(div_resp_valid),.resp_bits(div_resp_bits),
      .resp_tag(div_resp_tag),.pending(div_pending),
      .protocol_fault(div_protocol_fault));
  wire [15:0] returned_half;
  quant16_half_rne half_converter (
      .f32_bits(div_resp_bits),.half_bits(returned_half));

  // Each replay bank return issues sixteen simultaneous FMUL operands. Every
  // returned half has a reserved q payload and a FIFO token before issue.
  logic [101:0] mul_tags [0:63];
  logic [15:0] mul_bypass [0:63];
  logic [5:0] mul_head,mul_tail;
  logic [6:0] mul_pending;
  wire mul_req_valid=bank_return_valid && bank_return_kind && active &&
                     mul_quarantine==0;
  wire [31:0] mul_result [0:15];
  wire [15:0] mul_result_valid;
  wire mul_any_valid=|mul_result_valid;
  wire mul_all_valid=&mul_result_valid;
  wire mul_pop=mul_all_valid && mul_pending!=0 && mul_quarantine==0 && !rst;
  wire [101:0] mul_ret_tag=mul_tags[mul_head];
  logic [15:0] mul_issue_bypass;
  logic [31:0] mul_operand_a [0:15], mul_operand_b [0:15];
  for (genvar lane=0;lane<16;lane++) begin : g_mul_route
    wire [31:0] x_bits = bank_return_lanes[lane*32 +: 32];
    wire [31:0] r_bits = reciprocal[bank_return_tag[37:33]];
    wire [1:0] route = quant_route(x_bits,r_bits,
                                  d_full[bank_return_tag[37:33]] == 0);
    assign mul_issue_bypass[lane] = route == 2'd0 || route == 2'd1;
    assign mul_operand_a[lane] = mul_issue_bypass[lane] ? 32'h00000000 :
                                  quant_x_operand(x_bits,route);
    assign mul_operand_b[lane] = mul_issue_bypass[lane] ? 32'h3f800000 :
                                  quant_reciprocal_operand(r_bits,route);
  end
  for (genvar lane=0;lane<16;lane++) begin : g_fmul
    laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip u_mul (
        .aclk(clk),.aclken(1'b1),
        .s_axis_a_tvalid(mul_req_valid),
        .s_axis_a_tdata(mul_operand_a[lane]),
        .s_axis_b_tvalid(mul_req_valid),
        .s_axis_b_tdata(mul_operand_b[lane]),
        .m_axis_result_tvalid(mul_result_valid[lane]),
        .m_axis_result_tdata(mul_result[lane]));
  end

  function automatic logic finite32(input logic [31:0] bits);
    finite32=bits[30:23]!=8'hff;
  endfunction
  function automatic logic [8:0] rounded_q8(input logic [31:0] bits);
    logic [7:0] exponent;
    logic [23:0] mantissa;
    logic [31:0] whole, fraction, halfway;
    integer shift;
    begin
      exponent=bits[30:23];
      mantissa={1'b1,bits[22:0]};
      whole=0; fraction=0; halfway=0; shift=0;
      if (exponent==8'hff || exponent>=8'd134)
        rounded_q8={1'b1,8'd0};
      else begin
        if (exponent<=8'd125) whole=0;
        else if (exponent==8'd126) whole=1;
        else begin
          shift=23-(integer'(exponent)-127);
          whole=mantissa>>shift;
          fraction=mantissa & ((32'h1<<shift)-1);
          halfway=32'h1<<(shift-1);
          if (fraction>=halfway) whole=whole+1;
        end
        if (whole>127) rounded_q8={1'b1,8'd0};
        else if (bits[31]) rounded_q8={1'b0,8'(-integer'(whole))};
        else rounded_q8={1'b0,whole[7:0]};
      end
    end
  endfunction

  wire [4:0] amax_ret_slot=amax_ret_tag[37:33];
  wire [4:0] div_ret_slot=div_resp_tag[37:33];
  wire [4:0] mul_ret_slot=mul_ret_tag[37:33];
  wire [5:0] mul_ret_half_index={mul_ret_tag[0],5'd0};
  always_comb begin
    slot_debt_zero=1;
    for(int ds=0;ds<32;ds++) if(state[ds]!=FREE) slot_debt_zero=0;
  end
  assign input_read_debt_zero=!active && !capture_half && bank_reads_pending==0 && amax_pending==0 && !read_active && !bank_return_valid && !amax_ret_valid;
  assign divider_helper_debt_zero=div_pending==0 && !div_resp_valid;
  assign mul_return_debt_zero=mul_pending==0 && !mul_any_valid && !out_valid;
  assign physical_debt_zero=input_read_debt_zero && slot_debt_zero && divider_helper_debt_zero && mul_return_debt_zero;
  assign first_bad_col=first_error_key==64'hffffffffffffffff ? 16'hffff :
                       16'(first_error_key[47:16]*32 + first_error_key[7:0]);

  always_ff @(posedge clk) begin : p_control
    logic [63:0] best_error;
    logic [127:0] result_q;
    logic [8:0] converted;
    logic [5:0] bad_lane;
    if (rst) begin
      active<=0; done_valid<=0; done_status<=0;
      retired_d_full<=0;retired_reciprocal<=0;retired_scale<=0;
      task_epoch<=0; task_id<=0; source_epoch<=0; row<=0; groups<=0;
      drain_groups<=0;
      capture_group<=0; write_group<=0; capture_half<=0; write_half<=0;
      protocol_error<=0; numerical_error<=0;
      first_error_key<=64'hffffffffffffffff;
      read_active<=0; read_kind<=0; read_half<=0; read_slot<=0;
      prefer_replay<=0; prefer_recip<=0;
      bank_reads_pending<=0; amax_pending<=0;
      mul_quarantine<=3'd4; mul_head<=0; mul_tail<=0; mul_pending<=0;
      accepted_groups<=0; covered_groups<=0;
      scale_issues<=0; scale_returns<=0;
      recip_issues<=0; recip_returns<=0;
      amax_read_beats<=0; replay_read_beats<=0;
      mul_halves_issued<=0; mul_halves_returned<=0;
      for (int i=0;i<32;i++) begin
        state[i]<=FREE; slot_epoch[i]<=0; ordinal[i]<=0;
        amax[i]<=0; d_full[i]<=0; reciprocal[i]<=0; scale[i]<=0;
        q_received[i]<=0; slot_nonfinite[i]<=0;
      end
    end else if (start_fire) begin
      active<=1; done_valid<=0; done_status<=0;
      retired_d_full<=0;retired_reciprocal<=0;retired_scale<=0;
      task_epoch<=task_epoch+1;
      task_id<=cfg_task_id; source_epoch<=cfg_source_epoch;
      row<=cfg_row; groups<=cfg_groups; drain_groups<=cfg_groups;
      capture_group<=0; write_group<=0; capture_half<=0; write_half<=0;
      protocol_error<=0; numerical_error<=0;
      first_error_key<=64'hffffffffffffffff;
      read_active<=0; read_kind<=0; read_half<=0; read_slot<=0;
      prefer_replay<=0; prefer_recip<=0;
      bank_reads_pending<=0; amax_pending<=0;
      mul_quarantine<=3'd4; mul_head<=0; mul_tail<=0; mul_pending<=0;
      accepted_groups<=0; covered_groups<=0;
      scale_issues<=0; scale_returns<=0;
      recip_issues<=0; recip_returns<=0;
      amax_read_beats<=0; replay_read_beats<=0;
      mul_halves_issued<=0; mul_halves_returned<=0;
      for (int i=0;i<32;i++) begin
        state[i]<=FREE; slot_epoch[i]<=0; ordinal[i]<=0;
        amax[i]<=0; d_full[i]<=0; reciprocal[i]<=0; scale[i]<=0;
        q_received[i]<=0; slot_nonfinite[i]<=0;
      end
      if (cfg_task_id==0 || cfg_source_epoch==0 || cfg_groups==0 ||
          cfg_groups>8'd128) begin
        active<=0; done_valid<=1; done_status<=2;
      end
    end else begin
      best_error=first_error_key;
      if (done_valid && done_ready) done_valid<=0;
      if (mul_quarantine!=0) mul_quarantine<=mul_quarantine-1;
      if (div_protocol_fault || (mul_any_valid && !mul_all_valid) ||
          (mul_any_valid && mul_pending==0 && mul_quarantine==0)) begin
        protocol_error<=1;
        if (!protocol_error) begin
          drain_groups<=capture_group+(capture_half ? 8'd1 : 8'd0);
          if (capture_half) begin
            state[capture_group[4:0]]<=ERROR_SLOT;
            q_received[capture_group[4:0]]<=2'b11;
            capture_group<=capture_group+1'b1;
            capture_half<=0;
          end
        end
      end

      if (in_fire) begin
        if (in_task_id!=task_id || in_source_epoch!=source_epoch ||
            in_row!=row || in_group!=capture_group ||
            in_half!=capture_half || in_mask!=16'hffff) begin
          protocol_error<=1;
          // Stop accepting the malformed current group. Its slot is retired
          // through ERROR_SLOT after all prior accepted groups drain.
          state[capture_group[4:0]]<=ERROR_SLOT;
          ordinal[capture_group[4:0]]<=capture_group;
          q_received[capture_group[4:0]]<=2'b11;
          drain_groups<=capture_group+8'd1;
          capture_group<=capture_group+1;
          accepted_groups<=accepted_groups+1;
          capture_half<=0;
        end else if (!capture_half) begin
          state[capture_group[4:0]]<=FILL;
          slot_epoch[capture_group[4:0]]<=slot_epoch[capture_group[4:0]]+1;
          ordinal[capture_group[4:0]]<=capture_group;
          q_received[capture_group[4:0]]<=0;
          slot_nonfinite[capture_group[4:0]]<=0;
          amax[capture_group[4:0]]<=0;
          d_full[capture_group[4:0]]<=0;reciprocal[capture_group[4:0]]<=0;scale[capture_group[4:0]]<=0;
          capture_half<=1;
        end else begin
          state[capture_group[4:0]]<=AMAX_READY;
          capture_group<=capture_group+1;
          accepted_groups<=accepted_groups+1;
          capture_half<=0;
        end
      end

      if (bank_read_valid) begin
        if (!read_active) begin
          read_active<=1; read_kind<=chosen_kind;
          read_slot<=chosen_slot; read_half<=1;
          state[chosen_slot]<=chosen_kind ? REPLAY_READ : AMAX_READ;
        end else begin
          read_active<=0; read_half<=0;
          prefer_replay<=!read_kind;
          if (read_kind) state[chosen_slot]<=MUL_WAIT;
        end
        if (chosen_kind) replay_read_beats<=replay_read_beats+1;
        else amax_read_beats<=amax_read_beats+1;
      end
      case ({bank_read_valid,bank_return_valid})
        2'b10:bank_reads_pending<=bank_reads_pending+1;
        2'b01:bank_reads_pending<=bank_reads_pending-1;
        default:;
      endcase
      case ({amax_req_valid,amax_ret_valid})
        2'b10:amax_pending<=amax_pending+1;
        2'b01:amax_pending<=amax_pending-1;
        default:;
      endcase
      if (amax_ret_valid) begin
        if (amax_ret_tag[101:70]!=task_epoch ||
            amax_ret_tag[69:38]!=slot_epoch[amax_ret_slot] ||
            amax_ret_tag[32:1]!=ordinal[amax_ret_slot] ||
            state[amax_ret_slot]!=AMAX_READ) protocol_error<=1;
        if (!amax_ret_tag[0]) begin
          amax[amax_ret_slot]<=amax_ret_bits;
          if (amax_bad_lane!=16) begin
            slot_nonfinite[amax_ret_slot]<=1;
            // Keep the earliest invalid half0 element even if half1 is also bad.
            best_error=best_error < ((64'(ordinal[amax_ret_slot])<<16) |
                64'(amax_bad_lane)) ? best_error :
                ((64'(ordinal[amax_ret_slot])<<16) | 64'(amax_bad_lane));
          end
        end else begin
          if (amax_ret_bits>amax[amax_ret_slot])
            amax[amax_ret_slot]<=amax_ret_bits;
          if (amax_bad_lane!=16) begin
            best_error=best_error < ((64'(ordinal[amax_ret_slot])<<16) |
                64'(16+amax_bad_lane)) ? best_error :
                ((64'(ordinal[amax_ret_slot])<<16) | 64'(16+amax_bad_lane));
          end
          if (slot_nonfinite[amax_ret_slot] || amax_bad_lane!=16) begin
            state[amax_ret_slot]<=ERROR_SLOT;
            q_received[amax_ret_slot]<=2'b11;
          end else state[amax_ret_slot]<=SCALE_REQ;
        end
      end

      if (div_fire) begin
        state[div_slot]<=div_phase ? RECIP_WAIT : SCALE_WAIT;
        prefer_recip<=!div_phase;
        if (div_phase) recip_issues<=recip_issues+1;
        else scale_issues<=scale_issues+1;
      end
      if (div_resp_valid) begin
        if (div_resp_tag[101:70]!=task_epoch ||
            div_resp_tag[69:38]!=slot_epoch[div_ret_slot] ||
            div_resp_tag[32:1]!=ordinal[div_ret_slot] ||
            state[div_ret_slot]!=(div_resp_tag[0] ? RECIP_WAIT : SCALE_WAIT))
          protocol_error<=1;
        if (!div_resp_tag[0]) begin
          scale_returns<=scale_returns+1;
          d_full[div_ret_slot]<=div_resp_bits;
          scale[div_ret_slot]<=returned_half;
          if (!finite32(div_resp_bits)) begin
            state[div_ret_slot]<=ERROR_SLOT;
            q_received[div_ret_slot]<=2'b11;
            if (((64'(ordinal[div_ret_slot])<<16)|(64'd1<<8))<best_error)
              best_error=(64'(ordinal[div_ret_slot])<<16)|(64'd1<<8);
          end else if (div_resp_bits==0) begin
            reciprocal[div_ret_slot]<=0;
            if (returned_half[14:10]==5'h1f) begin
              state[div_ret_slot]<=ERROR_SLOT;
              q_received[div_ret_slot]<=2'b11;
              if (((64'(ordinal[div_ret_slot])<<16)|(64'd3<<8))<best_error)
                best_error=(64'(ordinal[div_ret_slot])<<16)|(64'd3<<8);
            end else state[div_ret_slot]<=QUANT_READY;
          end else state[div_ret_slot]<=RECIP_REQ;
        end else begin
          recip_returns<=recip_returns+1;
          reciprocal[div_ret_slot]<=div_resp_bits;
          if (!finite32(div_resp_bits)) begin
            state[div_ret_slot]<=ERROR_SLOT;
            q_received[div_ret_slot]<=2'b11;
            if (((64'(ordinal[div_ret_slot])<<16)|(64'd2<<8))<best_error)
              best_error=(64'(ordinal[div_ret_slot])<<16)|(64'd2<<8);
          end else if (scale[div_ret_slot][14:10]==5'h1f) begin
            state[div_ret_slot]<=ERROR_SLOT;
            q_received[div_ret_slot]<=2'b11;
            if (((64'(ordinal[div_ret_slot])<<16)|(64'd3<<8))<best_error)
              best_error=(64'(ordinal[div_ret_slot])<<16)|(64'd3<<8);
          end else state[div_ret_slot]<=QUANT_READY;
        end
      end

      if (mul_req_valid) begin
        mul_tags[mul_tail]<=bank_return_tag;
        mul_bypass[mul_tail]<=mul_issue_bypass;
        mul_tail<=mul_tail+1;
        mul_halves_issued<=mul_halves_issued+1;
      end
      if (mul_pop) begin
        mul_head<=mul_head+1;
        mul_halves_returned<=mul_halves_returned+1;
        result_q=0; bad_lane=6'd63;
        for (int lane=0;lane<16;lane++) begin
          converted=mul_bypass[mul_head][lane] ? 9'b0 :
                    rounded_q8(mul_result[lane]);
          result_q[lane*8 +: 8]=converted[7:0];
          if (converted[8] && bad_lane==6'd63) bad_lane=6'(lane);
        end
        if (mul_ret_tag[101:70]!=task_epoch ||
            mul_ret_tag[69:38]!=slot_epoch[mul_ret_slot] ||
            mul_ret_tag[32:1]!=ordinal[mul_ret_slot] ||
            (state[mul_ret_slot]!=MUL_WAIT &&
             state[mul_ret_slot]!=ERROR_SLOT)) protocol_error<=1;
        if (!mul_ret_tag[0]) q0[mul_ret_slot]<=result_q;
        else q1[mul_ret_slot]<=result_q;
        q_received[mul_ret_slot][mul_ret_tag[0]]<=1;
        if (bad_lane!=6'd63) begin
          state[mul_ret_slot]<=ERROR_SLOT;
          if (((64'(ordinal[mul_ret_slot])<<16)|(64'd4<<8)|
                (64'(mul_ret_tag[0])<<4)|64'(bad_lane))<best_error)
            best_error=(64'(ordinal[mul_ret_slot])<<16)|(64'd4<<8)|
                       (64'(mul_ret_tag[0])<<4)|64'(bad_lane);
        end else if (q_received[mul_ret_slot][!mul_ret_tag[0]] &&
                     state[mul_ret_slot]!=ERROR_SLOT)
          state[mul_ret_slot]<=Q_DRAIN;
      end
      case ({mul_req_valid,mul_pop})
        2'b10:mul_pending<=mul_pending+1;
        2'b01:mul_pending<=mul_pending-1;
        default:;
      endcase
      if (out_fire) begin
        if (!write_half) write_half<=1;
        else begin
          retired_d_full<=d_full[write_group[4:0]];retired_reciprocal<=reciprocal[write_group[4:0]];retired_scale<=scale[write_group[4:0]];
          write_half<=0;
          state[write_group[4:0]]<=FREE;
          write_group<=write_group+1;
          covered_groups<=covered_groups+1;
        end
      end else if (active && write_group<drain_groups &&
                   state[write_group[4:0]]==ERROR_SLOT &&
                   q_received[write_group[4:0]]==2'b11) begin
        retired_d_full<=d_full[write_group[4:0]];retired_reciprocal<=reciprocal[write_group[4:0]];retired_scale<=scale[write_group[4:0]];
        state[write_group[4:0]]<=FREE;
        write_group<=write_group+1;
        write_half<=0;
      end
      if (best_error!=first_error_key) numerical_error<=1;
      first_error_key<=best_error;
      if (active && capture_group==drain_groups && write_group==drain_groups &&
          bank_reads_pending==0 && amax_pending==0 &&
          div_pending==0 && mul_pending==0 && !read_active &&
          !bank_return_valid && !amax_ret_valid &&
          !div_resp_valid && !mul_any_valid) begin
        active<=0; done_valid<=1;
        done_status<=protocol_error ? 2 :
                     (numerical_error || best_error!=64'hffffffffffffffff ||
                      covered_groups!=groups ? 1 : 0);
      end
    end
  end
endmodule
