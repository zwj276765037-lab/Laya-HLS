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
  input logic staged_ln_cmd_valid,
  output logic staged_ln_cmd_ready,
  input logic [6:0] staged_ln_row,
  output logic staged_ln_view_valid,
  input logic staged_ln_rd_valid,
  input logic [9:0] staged_ln_rd_tile,
  output logic staged_ln_rd_ready,
  input logic staged_ln_release_valid, staged_ln_release_discard,
  output logic staged_ln_release_ready,
  output logic staged_ln_done_valid,
  input logic staged_ln_done_ready,
  output logic [3:0] staged_ln_done_status, staged_ln_done_phase,
  output logic [31:0] staged_ln_done_bad,
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
  input logic q16_fill_cmd_valid,
  output logic q16_fill_cmd_ready,
  output logic q16_fill_done_valid,
  input logic q16_fill_done_ready,
  output logic [3:0] q16_fill_done_status,
  output logic [31:0] q16_fill_done_bad,
  input logic q16_retire_success,
  input logic q16_window_begin,
  input logic [6:0] q16_row,
  input logic [31:0] q16_epoch,
  input logic [3327:0] q16_model,
  input logic [671:0] q16_numeric,
  output logic q16_done, q16_fault,
  output logic q16_partial_owned, q16_window_ok,
  output logic [4:0] q16_next_row,
  output logic a_window_ready,
  input logic a_window_release_valid, a_window_discard,
  output logic a_window_release_ready,

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
  input logic res_store_valid,
  input logic [9:0] res_store_index,
  input logic [31:0] res_store_bits,

  input logic feed_start, feed_active,
  output logic [2:0] feed_state,
  output logic [31:0] replay_hold,
  input logic result_reset,
  input logic result_accept,
  input logic [9:0] result_physical_addr, result_logical_tile,
  output logic result_pending,
  output logic result_rsp_valid,
  input logic result_rsp_ready,
  output logic [9:0] result_rsp_tile,
  output logic [255:0] result_rsp_bits,
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
  typedef enum logic [2:0] {
    ST_IDLE, ST_CMD, ST_FEED, ST_VIEW, ST_DONE
  } staged_state_t;
  staged_state_t staged_state;
  logic [6:0] staged_row_q;
  logic [10:0] staged_norm_count;
  logic staged_norm_fault;
  wire staged_norm_store = staged_state==ST_FEED && norm_valid &&
      staged_norm_count<11'd1024 &&
      norm_index===staged_norm_count[9:0];
  logic [31:0] prepared_id, prepared_epoch, gamma_token_epoch;
  logic [6:0] prepared_row;
  logic [3327:0] prepared_model, gamma_token_model;
  logic [671:0] prepared_numeric, gamma_token_numeric;
  logic [63:0] gamma_token_aux_base, gamma_token_aux_span;
  localparam logic [2:0] FEED_IDLE=3'd0, FEED_RAW_READ=3'd1,
      FEED_RAW_SEND=3'd2, FEED_GAMMA_READ=3'd3,
      FEED_GAMMA_SEND=3'd4, FEED_DONE=3'd5;
  logic [10:0] raw_replay_count, gamma_replay_count;
  logic [9:0] read_addr, read_logical_tile;
  localparam logic [2:0] Q16_IDLE=3'd0, Q16_REQ=3'd1,
      Q16_RSP=3'd2, Q16_WRITE=3'd3, Q16_SCALE=3'd4,
      Q16_RELEASE=3'd5, Q16_DONE=3'd6;
  logic [2:0] q16_state;
  logic [5:0] q16_group;
  logic [255:0] q16_bits;
  logic [15:0] q16_scale_even, q16_scale_current;
  logic [6:0] q16_window_base;
  logic [31:0] q16_window_epoch;
  logic [3327:0] q16_window_model;
  logic [671:0] q16_window_numeric;
  logic [15:0] q16_cover;
  localparam logic [2:0] QF_IDLE=3'd0,QF_CMD=3'd1,
      QF_READ=3'd2,QF_SEND=3'd3,QF_WAIT=3'd4,
      QF_EXPORT=3'd5,QF_LEAF_DONE=3'd6,QF_DONE=3'd7;
  logic [2:0] qf_state;
  logic [11:0] qf_index;
  logic [31:0] qf_word;
  logic [6:0] qf_row;
  assign staged_ln_cmd_ready=staged_state==ST_IDLE &&
      qf_state==QF_IDLE && q16_state==Q16_IDLE &&
      !prep_active && !q16_partial_owned && !a_window_ready &&
      prepared_match && gamma_match && ln_cmd_ready;
  assign staged_ln_view_valid=staged_state==ST_VIEW;
  assign staged_ln_rd_ready=staged_ln_view_valid &&
      staged_ln_rd_tile<=10'd127 && !staged_ln_release_valid &&
      !result_pending && !result_rsp_valid;
  assign staged_ln_release_ready=staged_ln_view_valid &&
      !result_pending && !result_rsp_valid;
  assign staged_ln_done_valid=staged_state==ST_DONE;
  assign q16_fill_cmd_ready=qf_state==QF_IDLE &&
      staged_state==ST_IDLE &&
      q16_state==Q16_IDLE && !prep_active &&
      prepared_match && q16_window_ok;
  assign q16_fill_done_valid=qf_state==QF_DONE;
  wire [12:0] q16_word_base =
      13'(q16_row[3:0])*13'd272+13'(q16_group)*13'd8;
  wire [12:0] q16_scale_word =
      13'(q16_row[3:0])*13'd272+13'd256+
      13'(q16_group[5:1]);
  assign q16_done=q16_state==Q16_DONE;
  assign q16_partial_owned=q16_next_row!=0 && !a_window_ready;
  assign q16_window_ok=q16_next_row!=5'd16 &&
      (q16_next_row==0 ? q16_row[3:0]==0 :
       (q16_row==q16_window_base+q16_next_row &&
        q16_epoch==q16_window_epoch &&
        q16_model==q16_window_model &&
        q16_numeric==q16_window_numeric));
  assign a_window_release_ready=bank_idle && qf_state==QF_IDLE &&
      staged_state==ST_IDLE &&
      (a_window_ready || (a_window_discard && q16_next_row!=0)) &&
      !prep_active && !prep_token_valid &&
      !result_rsp_valid && !result_pending &&
      q16_state==Q16_IDLE;
  wire [11:0] prep_target_count =
      active_prep_kind==2'b00 ? 12'd2048 : 12'd1024;
  wire [12:0] prep_physical_word =
      active_prep_kind==2'b10 ? 13'd4224+{2'b00,prep_write_index} :
      active_prep_kind==2'b11 ? 13'd1024+{2'b00,prep_write_index} :
      {2'b00,prep_write_index};
  assign prep_begin_ready=prep_begin_idle && prep_begin_allow &&
      qf_state==QF_IDLE && staged_state==ST_IDLE &&
      !a_window_ready &&
      (!q16_partial_owned || prep_kind==2'b10) &&
      !prep_active && !prep_token_valid &&
      (prep_kind!=2'b11 || !gamma_token_valid);
  assign prep_write_ready=bank_idle && qf_state==QF_IDLE &&
      staged_state==ST_IDLE &&
      prep_active && !prep_fault &&
      prep_count<prep_target_count &&
      prep_write_index==prep_count[10:0];
  assign prep_commit_ready=bank_idle && qf_state==QF_IDLE &&
      staged_state==ST_IDLE &&
      prep_active && !prep_fault &&
      prep_count==prep_target_count;
  assign prep_abort_ready=prep_begin_idle && qf_state==QF_IDLE &&
      staged_state==ST_IDLE &&
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
    .cmd_valid(ln_cmd_valid || qf_state==QF_CMD ||
               staged_state==ST_CMD),
    .cmd_ready(ln_cmd_ready),
    .source_mode(staged_state==ST_CMD ? 2'b10 :
                 qf_state==QF_CMD ? 2'b11 : ln_source_mode),
    .ln_only_valid(),
    .ln_only_ready(staged_state==ST_FEED ?
        (feed_state==FEED_DONE && staged_norm_count<11'd1024) :
        ln_only_ready),.ln_only_last(),
    .gamma_kind(staged_state==ST_CMD ? 2'd1 :
                qf_state==QF_CMD ? 2'd0 : ln_gamma_kind),
    .cmd_row(staged_state==ST_CMD ? {9'd0,staged_row_q} :
             qf_state==QF_CMD ? {9'd0,qf_row} : ln_cmd_row),
    .x_valid(ln_x_valid || qf_state==QF_SEND ||
             (staged_state==ST_FEED && feed_state==FEED_RAW_SEND)),
    .x_ready(ln_x_ready),
    .x_bits(staged_state==ST_FEED ? replay_hold :
            qf_state==QF_SEND ? qf_word : ln_x_bits),
    .gamma_valid(ln_gamma_valid ||
        (staged_state==ST_FEED && feed_state==FEED_GAMMA_SEND)),
    .gamma_ready(ln_gamma_ready),
    .gamma_bits(staged_state==ST_FEED ? replay_hold : ln_gamma_bits),
    .row_valid(ln_row_valid),
    .rd_valid(ln_rd_valid || q16_state==Q16_REQ),
    .rd_ready(ln_rd_ready),
    .rd_group(q16_state==Q16_REQ ? {1'b0,q16_group} : ln_rd_group),
    .rsp_valid(ln_rsp_valid),
    .rsp_ready(ln_rsp_ready || q16_state==Q16_RSP),
    .rsp_group(ln_rsp_group),
    .rsp_q8(ln_rsp_q),.rsp_scale(ln_rsp_scale),
    .row_release_valid(ln_release_valid || q16_state==Q16_RELEASE),
    .row_release_ready(ln_release_ready),
    .done_valid(ln_done_valid),
    .done_ready(ln_done_ready ||
        (qf_state==QF_WAIT && ln_done_valid && ln_done_status!=0) ||
        qf_state==QF_LEAF_DONE ||
        (staged_state==ST_DONE && staged_ln_done_ready)),
    .done_status(ln_done_status),.done_bad_element(ln_done_bad),
    .mean_bits(ln_mean),.variance_bits(ln_variance),
    .inverse_bits(ln_inverse),.norm_valid,.norm_index,.norm_bits
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      prep_active<=0;prep_token_valid<=0;gamma_token_valid<=0;
      staged_state<=ST_IDLE;staged_row_q<=0;
      staged_norm_count<=0;staged_norm_fault<=0;
      staged_ln_done_status<=0;staged_ln_done_phase<=0;
      staged_ln_done_bad<=32'hffffffff;
      prep_fault<=0;active_prep_kind<=0;prepared_kind<=0;
      prep_count<=0;prepared_id<=0;prepared_row<=0;prepared_epoch<=0;
      prepared_model<=0;prepared_numeric<=0;
      gamma_token_epoch<=0;gamma_token_model<=0;
      gamma_token_numeric<=0;gamma_token_aux_base<=0;
      gamma_token_aux_span<=0;
      feed_state<=FEED_IDLE;
      raw_replay_count<=0;gamma_replay_count<=0;
      q16_state<=Q16_IDLE;q16_fault<=0;
      q16_group<=0;q16_bits<=0;
      q16_scale_even<=0;q16_scale_current<=0;
      q16_next_row<=0;q16_window_base<=0;q16_window_epoch<=0;
      q16_window_model<=0;q16_window_numeric<=0;
      q16_cover<=0;a_window_ready<=0;
      qf_state<=QF_IDLE;qf_index<=0;qf_word<=0;qf_row<=0;
      q16_fill_done_status<=0;
      q16_fill_done_bad<=32'hffffffff;
      replay_hold<=0;
      result_pending<=0;result_rsp_valid<=0;
      result_rsp_tile<=0;result_rsp_bits<=0;
      read_addr<=0;read_logical_tile<=0;
      g_x_hold<=0;
      g_gate_hold<=0;
      qd_word<=0;
      res_b_hold<=0;
    end else begin
      if(staged_state==ST_FEED && norm_valid)begin
        if(!staged_norm_store)staged_norm_fault<=1;
        else staged_norm_count<=staged_norm_count+1'b1;
      end
      case(staged_state)
        ST_IDLE:if(staged_ln_cmd_valid && staged_ln_cmd_ready)begin
          staged_row_q<=staged_ln_row;
          staged_norm_count<=0;staged_norm_fault<=0;
          staged_ln_done_status<=0;staged_ln_done_phase<=4'd14;
          staged_ln_done_bad<=32'hffffffff;
          staged_state<=ST_CMD;
        end
        ST_CMD:if(ln_cmd_ready)staged_state<=ST_FEED;
        ST_FEED:if(ln_done_valid)begin
          if(ln_done_status!=0)begin
            staged_ln_done_status<=ln_done_status;
            staged_ln_done_bad<=ln_done_bad;
            staged_state<=ST_DONE;
          end else if(staged_norm_fault ||
                      staged_norm_count!=11'd1024 ||
                      feed_state!=FEED_DONE)begin
            staged_ln_done_status<=4'd7;
            staged_state<=ST_DONE;
          end else staged_state<=ST_VIEW;
        end
        ST_VIEW:begin
          if(staged_ln_rd_valid && staged_ln_rd_tile>10'd127 &&
             !staged_ln_release_valid && !result_pending &&
             !result_rsp_valid)begin
            staged_ln_done_status<=4'd7;
            staged_ln_done_phase<=4'd12;
            staged_state<=ST_DONE;
          end else if(staged_ln_release_valid &&
                      staged_ln_release_ready)begin
            if(staged_ln_release_discard)begin
              staged_ln_done_status<=4'd7;
              staged_ln_done_phase<=4'd12;
            end
            staged_state<=ST_DONE;
          end
        end
        ST_DONE:if(staged_ln_done_ready && ln_done_valid)
          staged_state<=ST_IDLE;
        default:staged_state<=ST_IDLE;
      endcase
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
      if(a_window_release_valid && a_window_release_ready)begin
        a_window_ready<=0;q16_next_row<=0;q16_cover<=0;
      end
      if(q16_window_begin)begin
        q16_window_base<=q16_row;
        q16_window_epoch<=q16_epoch;
        q16_window_model<=q16_model;
        q16_window_numeric<=q16_numeric;
        q16_cover<=0;
      end
      if(q16_retire_success)begin
        q16_cover[q16_row[3:0]]<=1;
        q16_next_row<=q16_next_row+1'b1;
        if(q16_next_row==5'd15 && q16_cover[14:0]==15'h7fff)
          a_window_ready<=1;
      end
      case(qf_state)
        QF_IDLE:if(q16_fill_cmd_valid && q16_fill_cmd_ready)begin
          qf_row<=q16_row;qf_index<=0;
          q16_fill_done_status<=0;
          q16_fill_done_bad<=32'hffffffff;
          qf_state<=QF_CMD;
        end
        QF_CMD:if(ln_cmd_ready)qf_state<=QF_READ;
        QF_READ:begin
          qf_word<=final_bank[qf_index[2:0]]
                 [10'd528+{3'd0,qf_index[9:3]}];
          qf_state<=QF_SEND;
        end
        QF_SEND:if(ln_x_ready)begin
          qf_index<=qf_index+1'b1;
          qf_state<=qf_index==12'd1023 ? QF_WAIT : QF_READ;
        end
        QF_WAIT:if(ln_row_valid)qf_state<=QF_EXPORT;
          else if(ln_done_valid && ln_done_status!=0)begin
            q16_fill_done_status<=ln_done_status;
            q16_fill_done_bad<=ln_done_bad;
            qf_state<=QF_DONE;
          end
        QF_EXPORT:if(q16_done)qf_state<=QF_LEAF_DONE;
        QF_LEAF_DONE:if(ln_done_valid)begin
          q16_fill_done_status<=q16_fault ? 4'd7 : ln_done_status;
          q16_fill_done_bad<=q16_fault ?
              32'hffffffff : ln_done_bad;
          qf_state<=QF_DONE;
        end
        QF_DONE:if(q16_fill_done_ready)qf_state<=QF_IDLE;
        default:qf_state<=QF_IDLE;
      endcase
      case(q16_state)
        Q16_IDLE:if(qf_state==QF_WAIT && ln_row_valid)begin
          q16_group<=0;q16_fault<=0;q16_state<=Q16_REQ;
        end
        Q16_REQ:if(ln_rd_ready)q16_state<=Q16_RSP;
        Q16_RSP:if(ln_rsp_valid)begin
          if(ln_rsp_group!={1'b0,q16_group})begin
            q16_fault<=1;q16_state<=Q16_RELEASE;
          end else begin
            q16_bits<=ln_rsp_q;
            q16_scale_current<=ln_rsp_scale;
            q16_state<=Q16_WRITE;
          end
        end
        Q16_WRITE:begin
          for(int lane=0;lane<8;lane++)
            final_bank[(q16_word_base+13'(lane))%13'd8]
                      [(q16_word_base+13'(lane))/13'd8]<=
              q16_bits[lane*32+:32];
          if(!q16_group[0])begin
            q16_scale_even<=q16_scale_current;
            q16_group<=q16_group+1'b1;
            q16_state<=Q16_REQ;
          end else q16_state<=Q16_SCALE;
        end
        Q16_SCALE:begin
          final_bank[q16_scale_word[2:0]][q16_scale_word[12:3]]<=
            {q16_scale_current,q16_scale_even};
          if(q16_group==6'd31)q16_state<=Q16_RELEASE;
          else begin
            q16_group<=q16_group+1'b1;q16_state<=Q16_REQ;
          end
        end
        Q16_RELEASE:if(ln_release_ready)q16_state<=Q16_DONE;
        Q16_DONE:if(qf_state==QF_EXPORT)q16_state<=Q16_IDLE;
        default:q16_state<=Q16_IDLE;
      endcase
      if(feed_start || (staged_state==ST_CMD && ln_cmd_ready))begin
        feed_state<=FEED_RAW_READ;
        raw_replay_count<=0;gamma_replay_count<=0;
      end else if(feed_active || staged_state==ST_FEED)begin
        case(feed_state)
          FEED_RAW_READ:begin
            replay_hold<=final_bank[raw_replay_count[2:0]]
                                   [raw_replay_count[9:3]];
            feed_state<=FEED_RAW_SEND;
          end
          FEED_RAW_SEND:if(ln_x_ready)begin
            if(raw_replay_count==11'd1023)feed_state<=FEED_GAMMA_READ;
            else begin
              raw_replay_count<=raw_replay_count+1'b1;
              feed_state<=FEED_RAW_READ;
            end
          end
          FEED_GAMMA_READ:begin
            replay_hold<=final_bank[gamma_replay_count[2:0]]
                                   [10'd128+{3'd0,gamma_replay_count[9:3]}];
            feed_state<=FEED_GAMMA_SEND;
          end
          FEED_GAMMA_SEND:if(ln_gamma_ready)begin
            if(gamma_replay_count==11'd1023)feed_state<=FEED_DONE;
            else begin
              gamma_replay_count<=gamma_replay_count+1'b1;
              feed_state<=FEED_GAMMA_READ;
            end
          end
          default:;
        endcase
      end
      if(result_reset || (staged_ln_cmd_valid && staged_ln_cmd_ready))begin
        result_pending<=0;result_rsp_valid<=0;
      end else begin
        if(result_rsp_valid && result_rsp_ready)result_rsp_valid<=0;
        if(result_pending)begin
          for(int lane=0;lane<8;lane++)
            result_rsp_bits[lane*32+:32]<=final_bank[lane][read_addr];
          result_rsp_tile<=read_logical_tile;
          result_rsp_valid<=1;result_pending<=0;
        end
        if(result_accept ||
           (staged_ln_rd_valid && staged_ln_rd_ready))begin
          read_addr<=staged_ln_view_valid ?
              10'd384+staged_ln_rd_tile : result_physical_addr;
          read_logical_tile<=staged_ln_view_valid ?
              staged_ln_rd_tile : result_logical_tile;
          result_pending<=1;
        end
      end
      if(norm_store_valid)
        final_bank[norm_store_index[2:0]]
                  [10'd384+{3'd0,norm_store_index[9:3]}]<=norm_store_bits;
      if(staged_norm_store)
        final_bank[norm_index[2:0]]
                  [10'd384+{3'd0,norm_index[9:3]}]<=norm_bits;
      if(ps_store_valid)
        for(int lane=0;lane<8;lane++)
          final_bank[lane][ps_store_tile]<=ps_store_bits[lane*32+:32];
      if(g_store_valid)
        final_bank[g_store_index[2:0]][g_store_index[11:3]]<=g_store_bits;
      if(res_store_valid)
        final_bank[res_store_index[2:0]][res_store_index[9:3]]<=res_store_bits;

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
    assert(!(norm_store_valid && staged_norm_store))
      else $fatal(1,"shared result bank two norm clients");
    assert($onehot0({(prep_write_valid && prep_write_ready),
                     (norm_store_valid || staged_norm_store),ps_store_valid,
                     g_store_valid,q16_state==Q16_WRITE,
                     q16_state==Q16_SCALE,
                     res_store_valid}))
      else $fatal(1,"shared result bank conflicting write clients");
    assert($onehot0({(feed_active &&
                     (feed_state==FEED_RAW_READ ||
                      feed_state==FEED_GAMMA_READ)),
                     (staged_state==ST_FEED &&
                      (feed_state==FEED_RAW_READ ||
                       feed_state==FEED_GAMMA_READ)),
                     result_pending,g_x_read_valid,
                     g_gate_read_valid,
                     (qd_read_valid || qf_state==QF_READ),
                     res_read_valid}))
      else $fatal(1,"shared result bank conflicting read clients");
  end
`endif
endmodule
