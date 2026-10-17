`timescale 1ns/1ps

// Single physical LN/Q leaf and 8 x 656-word result bank shared by the
// staged frontend and the existing Wi/G/Down executor. All reads below
// sample on the same edge as their original client FSM states.
module laya_lnq_bank_service_v1 (
  input logic clk, rst_n,
  input logic ln_cmd_valid,
  output logic ln_cmd_ready,
  input logic [1:0] ln_source_mode, ln_gamma_kind,
  input logic [15:0] ln_cmd_row,
  input logic ln_only_ready,
  input logic ln_x_valid,
  output logic ln_x_ready,
  input logic [31:0] ln_x_bits,
  input logic ln_gamma_valid,
  output logic ln_gamma_ready,
  input logic [31:0] ln_gamma_bits,
  output logic ln_row_valid,
  input logic ln_rd_valid,
  output logic ln_rd_ready,
  input logic [6:0] ln_rd_group,
  output logic ln_rsp_valid,
  input logic ln_rsp_ready,
  output logic [6:0] ln_rsp_group,
  output logic [255:0] ln_rsp_q,
  output logic [15:0] ln_rsp_scale,
  input logic ln_release_valid,
  output logic ln_release_ready,
  output logic ln_done_valid,
  input logic ln_done_ready,
  output logic [3:0] ln_done_status,
  output logic [31:0] ln_done_bad,
  output logic [31:0] ln_mean, ln_variance, ln_inverse,
  output logic norm_valid,
  output logic [9:0] norm_index,
  output logic [31:0] norm_bits,

  input logic bank_idle, prep_begin_idle, prep_begin_allow,
  input logic prep_begin_valid,
  output logic prep_begin_ready,
  input logic [1:0] prep_kind,
  input logic [31:0] prep_id,
  input logic [6:0] prep_row,
  input logic [31:0] prep_epoch,
  input logic [3327:0] prep_model_identity,
  input logic [671:0] prep_numeric_identity,
  input logic [63:0] prep_gamma_aux_base, prep_gamma_aux_span,
  input logic prep_write_valid,
  output logic prep_write_ready,
  input logic [10:0] prep_write_index,
  input logic [31:0] prep_write_bits,
  input logic prep_commit_valid,
  output logic prep_commit_ready,
  input logic prep_abort_valid,
  output logic prep_abort_ready,
  output logic prep_active,
  output logic prep_token_valid, gamma_token_valid, prep_fault,
  input logic prep_consume,
  input logic [31:0] match_id,
  input logic [6:0] match_row,
  input logic [31:0] match_epoch,
  input logic [3327:0] match_model_identity,
  input logic [671:0] match_numeric_identity,
  input logic [1:0] match_kind,
  input logic [63:0] match_gamma_aux_base, match_gamma_aux_span,
  output logic prepared_basic_match, prepared_match, gamma_match,
  input logic norm_store_valid,
  input logic [9:0] norm_store_index,
  input logic [31:0] norm_store_bits,
  input logic ps_store_valid,
  input logic [9:0] ps_store_tile,
  input logic [255:0] ps_store_bits,
  input logic g_store_valid,
  input logic [11:0] g_store_index,
  input logic [31:0] g_store_bits,
  input logic q16_store_valid,
  input logic [12:0] q16_store_base,
  input logic [255:0] q16_store_bits,
  input logic scale_store_valid,
  input logic [12:0] scale_store_word,
  input logic [31:0] scale_store_bits,
  input logic res_store_valid,
  input logic [9:0] res_store_index,
  input logic [31:0] res_store_bits,

  input logic replay_read_valid,
  input logic [12:0] replay_read_word,
  output logic [31:0] replay_hold,
  input logic result_read_valid,
  input logic [9:0] result_read_addr,
  output logic [255:0] result_read_bits,
  input logic g_x_read_valid,
  input logic [8:0] g_x_read_tile,
  output logic [255:0] g_x_hold,
  input logic g_gate_read_valid,
  input logic [9:0] g_gate_read_tile,
  output logic [255:0] g_gate_hold,
  input logic qd_read_valid,
  input logic [12:0] qd_read_word,
  output logic [31:0] qd_word,
  input logic res_read_valid,
  input logic [9:0] res_read_index,
  output logic [31:0] res_b_hold
);
  logic [31:0] final_bank [0:7][0:655];
  logic [1:0] active_prep_kind, prepared_kind;
  logic [11:0] prep_count;
  logic [31:0] prepared_id, prepared_epoch, gamma_token_epoch;
  logic [6:0] prepared_row;
  logic [3327:0] prepared_model, gamma_token_model;
  logic [671:0] prepared_numeric, gamma_token_numeric;
  logic [63:0] gamma_token_aux_base, gamma_token_aux_span;
  wire [11:0] prep_target_count =
      active_prep_kind==2'b00 ? 12'd2048 : 12'd1024;
  wire [12:0] prep_physical_word =
      active_prep_kind==2'b10 ? 13'd4224+{2'b00,prep_write_index} :
      active_prep_kind==2'b11 ? 13'd1024+{2'b00,prep_write_index} :
      {2'b00,prep_write_index};
  assign prep_begin_ready=prep_begin_idle && prep_begin_allow &&
      !prep_active && !prep_token_valid &&
      (prep_kind!=2'b11 || !gamma_token_valid);
  assign prep_write_ready=bank_idle && prep_active && !prep_fault &&
      prep_count<prep_target_count &&
      prep_write_index==prep_count[10:0];
  assign prep_commit_ready=bank_idle && prep_active && !prep_fault &&
      prep_count==prep_target_count;
  assign prep_abort_ready=prep_begin_idle &&
      (prep_active || prep_token_valid || gamma_token_valid || prep_fault);
  assign prepared_basic_match=prep_token_valid && !prep_fault &&
      prepared_id==match_id && prepared_row==match_row &&
      prepared_epoch==match_epoch;
  assign prepared_match=prepared_basic_match &&
      prepared_model==match_model_identity &&
      prepared_numeric==match_numeric_identity &&
      prepared_kind==match_kind;
  assign gamma_match=gamma_token_valid &&
      gamma_token_epoch==match_epoch &&
      gamma_token_model==match_model_identity &&
      gamma_token_numeric==match_numeric_identity &&
      gamma_token_aux_base==match_gamma_aux_base &&
      gamma_token_aux_span==match_gamma_aux_span;

  laya_lnq_row_v1 lnq (
    .clk,.rst_n,
    .cmd_valid(ln_cmd_valid),.cmd_ready(ln_cmd_ready),
    .source_mode(ln_source_mode),
    .ln_only_valid(),.ln_only_ready,.ln_only_last(),
    .gamma_kind(ln_gamma_kind),.cmd_row(ln_cmd_row),
    .x_valid(ln_x_valid),.x_ready(ln_x_ready),.x_bits(ln_x_bits),
    .gamma_valid(ln_gamma_valid),.gamma_ready(ln_gamma_ready),
    .gamma_bits(ln_gamma_bits),
    .row_valid(ln_row_valid),
    .rd_valid(ln_rd_valid),.rd_ready(ln_rd_ready),
    .rd_group(ln_rd_group),.rsp_valid(ln_rsp_valid),
    .rsp_ready(ln_rsp_ready),.rsp_group(ln_rsp_group),
    .rsp_q8(ln_rsp_q),.rsp_scale(ln_rsp_scale),
    .row_release_valid(ln_release_valid),
    .row_release_ready(ln_release_ready),
    .done_valid(ln_done_valid),.done_ready(ln_done_ready),
    .done_status(ln_done_status),.done_bad_element(ln_done_bad),
    .mean_bits(ln_mean),.variance_bits(ln_variance),
    .inverse_bits(ln_inverse),.norm_valid,.norm_index,.norm_bits
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      prep_active<=0;prep_token_valid<=0;gamma_token_valid<=0;
      prep_fault<=0;active_prep_kind<=0;prepared_kind<=0;
      prep_count<=0;prepared_id<=0;prepared_row<=0;prepared_epoch<=0;
      prepared_model<=0;prepared_numeric<=0;
      gamma_token_epoch<=0;gamma_token_model<=0;
      gamma_token_numeric<=0;gamma_token_aux_base<=0;
      gamma_token_aux_span<=0;
      replay_hold<=0;
      result_read_bits<=0;
      g_x_hold<=0;
      g_gate_hold<=0;
      qd_word<=0;
      res_b_hold<=0;
    end else begin
      if(prep_abort_valid && prep_abort_ready)begin
        prep_active<=0;prep_token_valid<=0;gamma_token_valid<=0;
        prep_fault<=0;prep_count<=0;
      end else begin
        if(prep_begin_valid && prep_begin_ready)begin
          prep_active<=1;prep_count<=0;prep_fault<=0;
          active_prep_kind<=prep_kind;
          prepared_id<=prep_id;prepared_row<=prep_row;
          prepared_epoch<=prep_epoch;
          prepared_model<=prep_model_identity;
          prepared_numeric<=prep_numeric_identity;
          if(prep_kind==2'b11)begin
            gamma_token_epoch<=prep_epoch;
            gamma_token_model<=prep_model_identity;
            gamma_token_numeric<=prep_numeric_identity;
            gamma_token_aux_base<=prep_gamma_aux_base;
            gamma_token_aux_span<=prep_gamma_aux_span;
          end
        end
        if(prep_write_valid)begin
          if(prep_write_ready)begin
            final_bank[prep_physical_word[2:0]]
                      [prep_physical_word[12:3]]<=prep_write_bits;
            prep_count<=prep_count+1'b1;
          end else if(prep_active)prep_fault<=1;
        end
        if(prep_commit_valid)begin
          if(prep_commit_ready)begin
            prep_active<=0;
            if(active_prep_kind==2'b11)gamma_token_valid<=1;
            else begin
              prep_token_valid<=1;
              prepared_kind<=active_prep_kind;
            end
          end else if(prep_active)prep_fault<=1;
        end
      end
      if(prep_consume)prep_token_valid<=0;
      if(norm_store_valid)
        final_bank[norm_store_index[2:0]]
                  [10'd384+{3'd0,norm_store_index[9:3]}]<=norm_store_bits;
      if(ps_store_valid)
        for(int lane=0;lane<8;lane++)
          final_bank[lane][ps_store_tile]<=ps_store_bits[lane*32+:32];
      if(g_store_valid)
        final_bank[g_store_index[2:0]][g_store_index[11:3]]<=g_store_bits;
      if(q16_store_valid)
        for(int lane=0;lane<8;lane++)
          final_bank[(q16_store_base+13'(lane))%13'd8]
                    [(q16_store_base+13'(lane))/13'd8]<=
            q16_store_bits[lane*32+:32];
      if(scale_store_valid)
        final_bank[scale_store_word[2:0]][scale_store_word[12:3]]<=
          scale_store_bits;
      if(res_store_valid)
        final_bank[res_store_index[2:0]][res_store_index[9:3]]<=res_store_bits;

      if(replay_read_valid)
        replay_hold<=final_bank[replay_read_word[2:0]]
                               [replay_read_word[12:3]];
      if(result_read_valid)
        for(int lane=0;lane<8;lane++)
          result_read_bits[lane*32+:32]<=final_bank[lane][result_read_addr];
      if(g_x_read_valid)
        for(int lane=0;lane<8;lane++)
          g_x_hold[lane*32+:32]<=final_bank[lane][g_x_read_tile];
      if(g_gate_read_valid)
        for(int lane=0;lane<8;lane++)
          g_gate_hold[lane*32+:32]<=final_bank[lane][g_gate_read_tile];
      if(qd_read_valid)
        qd_word<=final_bank[qd_read_word[2:0]][qd_read_word[12:3]];
      if(res_read_valid)
        res_b_hold<=final_bank[res_read_index[2:0]][res_read_index[9:3]];
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk) if(rst_n) begin
    assert($onehot0({(prep_write_valid && prep_write_ready),
                     norm_store_valid,ps_store_valid,
                     g_store_valid,q16_store_valid,scale_store_valid,
                     res_store_valid}))
      else $fatal(1,"shared result bank conflicting write clients");
    assert($onehot0({replay_read_valid,result_read_valid,g_x_read_valid,
                     g_gate_read_valid,qd_read_valid,res_read_valid}))
      else $fatal(1,"shared result bank conflicting read clients");
  end
`endif
endmodule
