`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_lnq_wi_gqdown_row_engine_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
  input logic cmd_mode,
  input logic [6:0] cmd_row,
  input logic cmd_prepared_source,
  input logic [31:0] cmd_source_epoch,
  input logic [2:0] cmd_exec,
  input logic [63:0] cmd_gamma_aux_base, cmd_gamma_aux_span,
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
  output logic prep_token_valid,
  output logic gamma_token_valid,
  output logic prep_fault,
  output logic a_window_ready,
  input logic a_window_release_valid,
  input logic a_window_discard,
  output logic a_window_release_ready,
  input logic [31:0] cmd_w_epoch,
  input logic [15:0] cmd_weight_key,
  input logic [3327:0] cmd_model_identity,
  input logic [671:0] cmd_numeric_identity,
  input logic [95:0] cmd_task_context,
  input logic [1023:0] cmd_expected_aux_header,
  input logic [2:0][63:0] cmd_load_base,
  input logic [2:0][31:0] cmd_load_bytes,
  input logic [63:0] cmd_aux_base,
  input logic [63:0] cmd_bias_base,
  input logic [31:0] cmd_bias_bytes,
  input logic [31:0] cmd_down_w_epoch,
  input logic [15:0] cmd_down_weight_key,
  input logic [1023:0] cmd_down_expected_aux_header,
  input logic [2:0][63:0] cmd_down_load_base,
  input logic [2:0][31:0] cmd_down_load_bytes,
  input logic [63:0] cmd_down_aux_base,
  input logic [63:0] cmd_down_bias_base,
  input logic [31:0] cmd_down_bias_bytes,
  input logic x_valid,
  output logic x_ready,
  input logic [31:0] x_bits,
  input logic gamma_valid,
  output logic gamma_ready,
  input logic [31:0] gamma_bits,
  output logic row_valid,
  input logic rd_valid,
  output logic rd_ready,
  input logic [9:0] rd_tile,
  output logic rsp_valid,
  input logic rsp_ready,
  output logic [9:0] rsp_tile,
  output logic [255:0] rsp_bits,
  input logic row_release_valid,
  input logic row_release_discard,
  output logic row_release_ready,
  output logic done_valid,
  input logic done_ready,
  output logic [3:0] done_status,
  output logic [3:0] done_phase,
  output logic [7:0] done_op,
  output logic [15:0] done_check_status,
  output logic [31:0] done_detail,
  output logic [63:0] done_bad64,
  output logic [31:0] wprep_result_id, wprep_result_source_epoch,
  output logic [31:0] wprep_result_epoch,
  output logic [63:0] wprep_result_request, wprep_result_generation,
  output logic [15:0] wprep_result_key,
  output logic [3327:0] wprep_result_model,
  output logic [671:0] wprep_result_numeric,
  output logic result_mode,
  output logic [2:0] result_exec,
  output logic [6:0] result_row,
  output logic [31:0] done_bad_element,
  output logic [31:0] mean_bits, variance_bits, inverse_bits,
  output logic [31:0] actual_w_reads, actual_w_returns,
  output logic [31:0] actual_stripes, actual_ps_commits,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready
  ,laya_lnq_bank_link_v1 bank_link
);
  localparam logic [9:0] WI_LAST_TILE=10'd655, DOWN_LAST_TILE=10'd127,
                         QKV_LAST_TILE=10'd383, QKV_LAST_READ_TILE=10'd511;
  localparam logic [6:0] WI_LAST_GROUP=7'd31, DOWN_LAST_GROUP=7'd81;
  typedef enum logic [5:0] {
    IDLE, LOAD_REQ, LOAD_WAIT, LN_CMD, LN_WAIT, LEASE_REQ, LEASE_WAIT,
    FRONT_CFG, A_REQ, A_WAIT, W_REQ, W_WAIT, ISSUE, DRAIN,
    W_RELEASE_REQ, W_RELEASE_WAIT, A_RELEASE, A_DONE, ROW, DONE,
    G_R0, G_R1, G_SEND, G_WAIT, G_DRAIN,
    QD_CMD, QD_READ, QD_SEND, QD_WAIT,
    RES_INIT, RES_READ, RES_SEND, RES_WAIT, RES_DRAIN,
    Q16_WAIT, STAGED_PROXY, WP_REQ, WP_WAIT
  } state_t;
  state_t state;

  logic [31:0] id, w_epoch, source_epoch;
  logic [2:0] exec_mode;
  logic mode_qkv;
  logic [6:0] token_row;
  logic [10:0] norm_count;
  logic [31:0] down_epoch;
  logic [15:0] weight_key;
  logic [15:0] down_weight_key;
  logic [3327:0] model_id;
  logic [671:0] numeric_id;
  logic [95:0] task_context;
  logic [1023:0] aux_header;
  logic [1023:0] down_aux_header;
  logic [2:0][63:0] load_base;
  logic [2:0][63:0] down_load_base;
  logic [2:0][31:0] load_bytes;
  logic [2:0][31:0] down_load_bytes;
  logic [63:0] aux_base,bias_base;
  logic [63:0] down_aux_base,down_bias_base;
  logic [31:0] bias_bytes;
  logic [31:0] down_bias_bytes;
  logic active_slot,phase_down;
  wire [31:0] active_epoch=active_slot ? down_epoch : w_epoch;
  wire [15:0] active_key=active_slot ? down_weight_key : weight_key;
  wire [9:0] last_tile=mode_qkv ? QKV_LAST_TILE :
                             (phase_down ? DOWN_LAST_TILE : WI_LAST_TILE);
  wire [6:0] last_group=phase_down ? DOWN_LAST_GROUP : WI_LAST_GROUP;
  wire [31:0] expected_stripes=mode_qkv ? 32'd12288 :
                                (phase_down ? 32'd10496 : 32'd20992);
  wire [3:0] matrix_error_phase=mode_qkv ? 4'd11 : (phase_down ? 4'd6 : 4'd3);
  wire [3:0] ln_error_phase=exec_mode==3'd1 ? 4'd14 :
                            (mode_qkv ? 4'd10 : 4'd2);
  logic [95:0] front_issue_identity;
  logic [6:0] group_no;
  logic [9:0] tile_no;
  logic [255:0] a_q;
  logic [31:0] a_scale;
  logic [2047:0] w_q;
  logic [255:0] w_scale;
  logic w_pending, have_w_lease, have_a_row;
  logic local_fault, final_duplicate, final_missing;
  logic [655:0] final_cover;
  logic [9:0] final_count;
  wire prep_active, prepared_basic_match, prepared_match, gamma_match;
  logic source_prepared;
  localparam logic [2:0] FEED_RAW_SEND=3'd2,
      FEED_GAMMA_SEND=3'd4, FEED_DONE=3'd5;
  wire [2:0] feed_state;
  wire [31:0] replay_hold;
  logic [31:0] skip_bank [0:1023];
  logic [10:0] skip_count, res_index, res_issued, res_consumed, res_written;
  logic [31:0] res_a_hold;
  wire [31:0] res_b_hold;
  logic [9:0] res_ordinal;
  logic res_fault;
  wire add_in_ready, add_out_valid;
  wire [31:0] add_bits;
  wire add_in_valid=(state==RES_SEND) && !res_fault &&
                  res_a_hold[30:23]!=8'hff && res_b_hold[30:23]!=8'hff;
  wire add_accept=add_in_valid && add_in_ready;
  wire add_consume=(state==RES_WAIT || state==RES_DRAIN) && add_out_valid;
  logic [31:0] stage_stripes;
  logic [8:0] g_tile;
  wire [9:0] g_gate_tile={1'b0,g_tile}+10'd328;
  logic [2:0] g_lane;
  wire [255:0] g_x_hold,g_gate_hold;
  logic [11:0] g_issued,g_returned;
  logic [9:0] g_credits;
  logic [2623:0] g_cover;
  logic g_fault;
  logic [31:0] g_bad;
  logic [11:0] qd_index;
  wire [31:0] qd_word;
  wire [4:0] q16_next_row;
  wire q16_done,q16_fault,q16_partial_owned,q16_window_ok;
  wire q16_fill_cmd_ready;
  wire q16_fill_done_valid;
  wire [3:0] q16_fill_done_status;
  wire [31:0] q16_fill_done_bad;
  wire g_commit;
  wire [31:0] g_data,g_status,g_failed;
  wire g_commit_bad=g_commit && g_status!=0;
  wire g_issue=(state==G_SEND) && !g_fault && !g_commit_bad &&
               g_issued<12'd2624 && g_credits<10'd512;
  wire g_return_legal=g_commit && g_credits!=0 &&
                      g_returned<12'd2624 && !g_cover[g_returned];
  wire read_pending;

  logic load_ready,load_done,load_error,load_reject;
  logic load_protocol_error,load_numeric_error;
  logic [31:0] load_scale_checks,load_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch,slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic lease_ready,lease_done,lease_error;
  logic w_read_ready,w_read_error,ret_valid,ret_ready,ret_slot,ret_pair;
  logic [31:0] ret_epoch;
  logic [15:0] ret_tile;
  logic [7:0] ret_group;
  logic [3327:0] ret_model_identity;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_task_context;
  logic [1:0][7:0][255:0] ret_q;
  logic [1:0][7:0][15:0] ret_scale;
  logic [1:0][7:0][31:0] ret_bias;
  logic [1:0][7:0] ret_mask;
  logic release_ready,release_done,release_error;
  logic wp_ready,wp_done_valid;
  logic [31:0] wp_done_id,wp_done_source_epoch,wp_done_epoch;
  logic [63:0] wp_done_request,wp_done_generation;
  logic [15:0] wp_done_key;
  logic [3327:0] wp_done_model;
  logic [671:0] wp_done_numeric;
  logic [3:0] wp_done_status;
  logic [7:0] wp_done_op;
  logic [15:0] wp_done_check_status;
  logic [31:0] wp_done_detail;
  logic [63:0] wp_done_bad64;
  logic wp_delegated;

  logic ln_cmd_ready,ln_row_valid,ln_rd_ready,ln_rsp_valid,ln_release_ready;
  logic [6:0] ln_rsp_group;
  logic [255:0] ln_rsp_q;
  logic [15:0] ln_rsp_scale;
  logic ln_done_valid;
  logic [3:0] ln_done_status;
  logic [31:0] ln_done_bad;

  logic front_cfg_ready,front_issue_ready,front_abort_ready;
  logic [3:0] commit_valid,commit_ready;
  logic [767:0] commit_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_mask,commit_bad;
  logic [95:0] commit_phase;
  logic [1023:0] commit_next_ps;
  logic [3:0] final_skip_valid;
  logic [9:0] final_skip_tile;
  logic [7:0] final_skip_mask;
  logic [23:0] result_free,result_reserved,result_returned;
  logic [11:0] trace_free;
  logic front_done,front_error,front_protocol;
  logic [63:0] front_first_rank;
  logic [31:0] front_bad,front_accepted;
  logic [31:0] ln_mean,ln_variance,ln_inverse;
  logic norm_valid;
  logic [9:0] norm_index;
  logic [31:0] norm_bits;
  logic [31:0] saved_mean,saved_variance,saved_inverse;

  function automatic logic [31:0] half_to_f32(input logic [15:0] h);
    logic [4:0] e; logic [9:0] f; integer shift;
    e=h[14:10];f=h[9:0];shift=0;
    if(e==0) begin
      if(f==0)return {h[15],31'd0};
      while(!f[9]) begin f=f<<1;shift=shift+1;end
      return {h[15],8'(112-shift),f[8:0],14'd0};
    end
    if(e==31)return {h[15],8'hff,h[9:0],13'd0};
    return {h[15],8'(int'(e)+112),h[9:0],13'd0};
  endfunction

  wire ret_ok=ret_slot==active_slot && !ret_pair && ret_epoch==active_epoch &&
    ret_tile==16'(tile_no) && ret_group==8'(group_no) &&
    ret_model_identity==model_id && ret_numeric_identity==numeric_id &&
    ret_task_context==task_context && ret_mask[0]==8'hff;
  wire external_w_abort=(state==W_WAIT && (w_read_error ||
                            (ret_valid && !ret_ok)));
  wire front_abort_valid=external_w_abort ||
    (state==A_WAIT && ln_rsp_valid && ln_rsp_group!=group_no);
  wire last_commit=commit_valid[0] && commit_ready[0] &&
    {commit_tag[160],commit_tag[11+:6]}==last_group;
  wire issue_fire=state==ISSUE && front_issue_ready;
  wire ln_x_ready,ln_gamma_ready;
  wire staged_ln_cmd_ready,staged_ln_view_valid;
  wire staged_ln_rd_ready,staged_ln_release_ready;
  wire staged_ln_done_valid;
  wire [3:0] staged_ln_done_status,staged_ln_done_phase;
  wire [31:0] staged_ln_done_bad;
  wire [31:0] staged_ln_done_id,staged_ln_done_epoch;
  wire [6:0] staged_ln_done_row;
  wire [2:0] staged_ln_result_exec;
  wire [7:0] staged_ln_done_op;
  wire [15:0] staged_ln_done_check_status;
  wire [31:0] staged_ln_done_detail;
  wire [63:0] staged_ln_done_bad64;
  wire staged_ln_identity_bad=staged_ln_done_id!=id ||
      staged_ln_done_row!=token_row ||
      staged_ln_done_epoch!=source_epoch ||
      staged_ln_result_exec!=3'd1;
  wire staged_ln_admissible=cmd_exec==3'd1 && cmd_mode &&
      cmd_prepared_source && prepared_match && gamma_match;
  // The lower service retains its previous done fields after retirement.
  // Identity alone cannot identify the source of a new locally rejected
  // command, because the rejected command may reuse that same identity.
  logic staged_ln_delegated;
  wire staged_ln_accept=state==IDLE && cmd_valid && cmd_ready &&
      staged_ln_admissible && staged_ln_cmd_ready;

  assign cmd_ready=state==IDLE && !prep_active && !a_window_ready &&
                   (!q16_partial_owned || cmd_exec==3'd2) &&
                   (!prep_token_valid || cmd_prepared_source) &&
                   (!staged_ln_admissible || staged_ln_cmd_ready) &&
                   (cmd_exec!=3'd4 ||
                    (bank_link.service_quiescent &&
                     !bank_link.gamma_token_valid && !cmd_prepared_source)) &&
                   (cmd_exec!=3'd2 || !prepared_match ||
                    !q16_window_ok || q16_fill_cmd_ready);
  assign row_valid=state==ROW ||
      (state==STAGED_PROXY && staged_ln_view_valid);
  assign done_valid=state==DONE;
  assign wprep_result_id=wp_done_id;
  assign wprep_result_source_epoch=wp_done_source_epoch;
  assign wprep_result_epoch=wp_done_epoch;
  assign wprep_result_request=wp_done_request;
  assign wprep_result_generation=wp_done_generation;
  assign wprep_result_key=wp_done_key;
  assign wprep_result_model=wp_done_model;
  assign wprep_result_numeric=wp_done_numeric;
  assign done_op=exec_mode==3'd1 ?
      (staged_ln_delegated ? staged_ln_done_op : 8'h10) :
                 exec_mode==3'd2 ? 8'h20 :
                 exec_mode==3'd4 ? 8'h80 : 8'h00;
  assign done_check_status=exec_mode==3'd1 ?
      (!staged_ln_delegated || staged_ln_identity_bad ?
       16'd7 : staged_ln_done_check_status) :
      exec_mode==3'd4 && wp_delegated ? wp_done_check_status :
      {12'd0,done_status};
  assign done_detail=exec_mode==3'd1 ?
      (!staged_ln_delegated || staged_ln_identity_bad ?
       32'h0710_0005 : staged_ln_done_detail) :
      exec_mode==3'd4 && wp_delegated ? wp_done_detail :
      done_status==4'd6 ?
      {8'h07,done_op,16'h000f} :
      done_status==4'd7 ? {8'h07,done_op,16'h0005} : 32'd0;
  assign done_bad64=exec_mode==3'd1 ?
      (!staged_ln_delegated || staged_ln_identity_bad ?
       64'hffff_ffff_ffff_ffff :
       staged_ln_done_bad64) :
      exec_mode==3'd4 && wp_delegated ? wp_done_bad64 :
      done_status==4'd6 && exec_mode!=0 ?
      64'(token_row[3:0])*64'd4096+64'(done_bad_element) :
      64'hffff_ffff_ffff_ffff;
  assign rd_ready=state==STAGED_PROXY ? staged_ln_rd_ready :
      state==ROW && !row_release_valid &&
      rd_tile<=(mode_qkv ? QKV_LAST_READ_TILE : DOWN_LAST_TILE) &&
      !rsp_valid && !read_pending;
  assign row_release_ready=state==STAGED_PROXY ?
      staged_ln_release_ready :
      state==ROW && !rsp_valid && !read_pending;
  assign mean_bits=state==STAGED_PROXY && staged_ln_view_valid ?
      ln_mean : (state==ROW || (state==DONE && done_status==0) ? saved_mean : 0);
  assign variance_bits=state==STAGED_PROXY && staged_ln_view_valid ?
      ln_variance : (state==ROW || (state==DONE && done_status==0) ? saved_variance : 0);
  assign inverse_bits=state==STAGED_PROXY && staged_ln_view_valid ?
      ln_inverse : (state==ROW || (state==DONE && done_status==0) ? saved_inverse : 0);
  assign ret_ready=state==W_WAIT || state==DRAIN;
  assign commit_ready=4'hf;
  assign x_ready=(state==LN_WAIT) && !source_prepared && ln_x_ready;
  assign gamma_ready=(state==LN_WAIT) && !source_prepared && ln_gamma_ready;

  wire ps_bank_write=last_commit &&
      commit_tile[9:0]<=last_tile &&
      !final_cover[commit_tile[9:0]] &&
      (commit_mask[7:0]|commit_bad[7:0])==8'hff &&
      commit_bad[7:0]==0;
  wire g_bank_write=g_commit && g_return_legal &&
      g_status==0 && !g_fault;
  wire res_bank_write=state==RES_WAIT && add_consume &&
      res_issued==res_consumed+11'd1 &&
      res_consumed==res_written &&
      res_consumed<11'd1024 &&
      res_consumed==11'(res_ordinal) &&
      add_bits[30:23]!=8'hff;
  wire res_bank_read=state==RES_READ &&
      res_index<11'd1024 && res_issued==res_index &&
      res_consumed==res_index && res_written==res_index &&
      !add_out_valid;
  assign bank_link.staged_ln_cmd_valid = state==IDLE && cmd_valid && cmd_ready &&
        staged_ln_admissible;
  assign staged_ln_cmd_ready = bank_link.staged_ln_cmd_ready;
  assign bank_link.staged_ln_row = cmd_row;
  assign staged_ln_view_valid = bank_link.staged_ln_view_valid;
  assign bank_link.staged_ln_rd_valid = state==STAGED_PROXY && rd_valid;
  assign bank_link.staged_ln_rd_tile = rd_tile;
  assign staged_ln_rd_ready = bank_link.staged_ln_rd_ready;
  assign bank_link.staged_ln_release_valid = state==STAGED_PROXY && row_release_valid;
  assign bank_link.staged_ln_release_discard = row_release_discard;
  assign staged_ln_release_ready = bank_link.staged_ln_release_ready;
  assign staged_ln_done_valid = bank_link.staged_ln_done_valid;
  assign bank_link.staged_ln_done_ready = state==DONE && done_ready && exec_mode==3'd1;
  assign staged_ln_done_status = bank_link.staged_ln_done_status;
  assign staged_ln_done_phase = bank_link.staged_ln_done_phase;
  assign staged_ln_done_bad = bank_link.staged_ln_done_bad;
  assign staged_ln_done_id = bank_link.staged_ln_done_id;
  assign staged_ln_done_epoch = bank_link.staged_ln_done_epoch;
  assign staged_ln_done_row = bank_link.staged_ln_done_row;
  assign staged_ln_result_exec = bank_link.staged_ln_result_exec;
  assign staged_ln_done_op = bank_link.staged_ln_done_op;
  assign staged_ln_done_check_status = bank_link.staged_ln_done_check_status;
  assign staged_ln_done_detail = bank_link.staged_ln_done_detail;
  assign staged_ln_done_bad64 = bank_link.staged_ln_done_bad64;
  assign bank_link.ln_cmd_valid = state==LN_CMD || state==QD_CMD;
  assign ln_cmd_ready = bank_link.ln_cmd_ready;
  assign bank_link.ln_source_mode = state==LN_CMD && exec_mode==3'd1 ? 2'b10 :
                    state==QD_CMD && exec_mode==3'd2 ? 2'b11 :
                    {1'b0,state==QD_CMD};
  assign bank_link.ln_gamma_kind = mode_qkv && state!=QD_CMD ? 2'd1 : 2'd0;
  assign bank_link.ln_cmd_row = {9'd0,token_row};
  assign bank_link.ln_only_ready = 1'b0;
  assign bank_link.ln_x_valid = (state==LN_WAIT &&
                 (source_prepared ? feed_state==FEED_RAW_SEND : x_valid)) ||
                state==QD_SEND;
  assign ln_x_ready = bank_link.ln_x_ready;
  assign bank_link.ln_x_bits = state==QD_SEND ? qd_word :
                          (source_prepared ? replay_hold : x_bits);
  assign bank_link.ln_gamma_valid = state==LN_WAIT &&
        (source_prepared ? feed_state==FEED_GAMMA_SEND : gamma_valid);
  assign ln_gamma_ready = bank_link.ln_gamma_ready;
  assign bank_link.ln_gamma_bits = source_prepared ? replay_hold : gamma_bits;
  assign ln_row_valid = bank_link.ln_row_valid;
  assign bank_link.ln_rd_valid = state==A_REQ;
  assign ln_rd_ready = bank_link.ln_rd_ready;
  assign bank_link.ln_rd_group = group_no;
  assign ln_rsp_valid = bank_link.ln_rsp_valid;
  assign bank_link.ln_rsp_ready = state==A_WAIT;
  assign ln_rsp_group = bank_link.ln_rsp_group;
  assign ln_rsp_q = bank_link.ln_rsp_q;
  assign ln_rsp_scale = bank_link.ln_rsp_scale;
  assign bank_link.ln_release_valid = state==A_RELEASE;
  assign ln_release_ready = bank_link.ln_release_ready;
  assign ln_done_valid = bank_link.ln_done_valid;
  assign bank_link.ln_done_ready = ((state==LN_WAIT || state==QD_WAIT) &&
                    ln_done_status!=0) || state==A_DONE;
  assign ln_done_status = bank_link.ln_done_status;
  assign ln_done_bad = bank_link.ln_done_bad;
  assign ln_mean = bank_link.ln_mean;
  assign ln_variance = bank_link.ln_variance;
  assign ln_inverse = bank_link.ln_inverse;
  assign norm_valid = bank_link.norm_valid;
  assign norm_index = bank_link.norm_index;
  assign norm_bits = bank_link.norm_bits;
  assign bank_link.q16_fill_cmd_valid = state==IDLE && cmd_valid && cmd_ready &&
        cmd_exec==3'd2 && cmd_mode && cmd_prepared_source &&
        prepared_match && q16_window_ok;
  assign q16_fill_cmd_ready = bank_link.q16_fill_cmd_ready;
  assign q16_fill_done_valid = bank_link.q16_fill_done_valid;
  assign bank_link.q16_fill_done_ready = state==Q16_WAIT && q16_fill_done_valid;
  assign q16_fill_done_status = bank_link.q16_fill_done_status;
  assign q16_fill_done_bad = bank_link.q16_fill_done_bad;
  assign bank_link.q16_retire_success = state==DONE && done_ready &&
        exec_mode==3'd2 && done_status==0;
  assign bank_link.q16_window_begin = state==IDLE && cmd_valid && cmd_ready &&
        cmd_exec==3'd2 && cmd_mode && cmd_prepared_source &&
        prepared_match && q16_window_ok && q16_next_row==0;
  assign bank_link.q16_row = state==IDLE ? cmd_row : token_row;
  assign bank_link.q16_epoch = cmd_source_epoch;
  assign bank_link.q16_model = cmd_model_identity;
  assign bank_link.q16_numeric = cmd_numeric_identity;
  assign q16_done = bank_link.q16_done;
  assign q16_fault = bank_link.q16_fault;
  assign q16_partial_owned = bank_link.q16_partial_owned;
  assign q16_window_ok = bank_link.q16_window_ok;
  assign q16_next_row = bank_link.q16_next_row;
  assign a_window_ready = bank_link.a_window_ready;
  assign bank_link.a_window_release_valid = a_window_release_valid;
  assign bank_link.a_window_discard = a_window_discard;
  assign a_window_release_ready = bank_link.a_window_release_ready;
  assign bank_link.bank_idle = state==IDLE;
  assign bank_link.prep_begin_idle = state==IDLE && !cmd_valid;
  assign bank_link.prep_begin_allow = !a_window_ready &&
        (!q16_partial_owned || prep_kind==2'b10);
  assign bank_link.prep_begin_valid = prep_begin_valid;
  assign prep_begin_ready = bank_link.prep_begin_ready;
  assign bank_link.prep_kind = prep_kind;
  assign bank_link.prep_id = prep_id;
  assign bank_link.prep_row = prep_row;
  assign bank_link.prep_epoch = prep_epoch;
  assign bank_link.prep_model_identity = prep_model_identity;
  assign bank_link.prep_numeric_identity = prep_numeric_identity;
  assign bank_link.prep_gamma_aux_base = prep_gamma_aux_base;
  assign bank_link.prep_gamma_aux_span = prep_gamma_aux_span;
  assign bank_link.prep_write_valid = prep_write_valid;
  assign prep_write_ready = bank_link.prep_write_ready;
  assign bank_link.prep_write_index = prep_write_index;
  assign bank_link.prep_write_bits = prep_write_bits;
  assign bank_link.prep_commit_valid = prep_commit_valid;
  assign prep_commit_ready = bank_link.prep_commit_ready;
  assign bank_link.prep_abort_valid = prep_abort_valid;
  assign prep_abort_ready = bank_link.prep_abort_ready;
  assign prep_active = bank_link.prep_active;
  assign prep_token_valid = bank_link.prep_token_valid;
  assign gamma_token_valid = bank_link.gamma_token_valid;
  assign prep_fault = bank_link.prep_fault;
  assign bank_link.prep_consume = state==IDLE && cmd_valid && cmd_ready &&
                  cmd_prepared_source;
  assign bank_link.match_id = cmd_id;
  assign bank_link.match_row = cmd_row;
  assign bank_link.match_epoch = cmd_source_epoch;
  assign bank_link.match_model_identity = cmd_model_identity;
  assign bank_link.match_numeric_identity = cmd_numeric_identity;
  assign bank_link.match_kind = cmd_exec==3'd1 ? 2'b01 :
                cmd_exec==3'd2 ? 2'b10 : 2'b00;
  assign bank_link.match_gamma_aux_base = cmd_gamma_aux_base;
  assign bank_link.match_gamma_aux_span = cmd_gamma_aux_span;
  assign prepared_basic_match = bank_link.prepared_basic_match;
  assign prepared_match = bank_link.prepared_match;
  assign gamma_match = bank_link.gamma_match;
  assign bank_link.norm_store_valid = norm_valid && mode_qkv && state==LN_WAIT &&
        norm_count<11'd1024 && norm_index===norm_count[9:0];
  assign bank_link.norm_store_index = norm_index;
  assign bank_link.norm_store_bits = norm_bits;
  assign bank_link.ps_store_valid = ps_bank_write;
  assign bank_link.ps_store_tile = commit_tile[9:0];
  assign bank_link.ps_store_bits = commit_next_ps[255:0];
  assign bank_link.g_store_valid = g_bank_write;
  assign bank_link.g_store_index = g_returned;
  assign bank_link.g_store_bits = g_data;
  assign bank_link.res_store_valid = res_bank_write;
  assign bank_link.res_store_index = res_consumed[9:0];
  assign bank_link.res_store_bits = add_bits;
  assign bank_link.feed_start = state==LN_CMD && ln_cmd_ready && source_prepared;
  assign bank_link.feed_active = state==LN_WAIT && source_prepared;
  assign feed_state = bank_link.feed_state;
  assign replay_hold = bank_link.replay_hold;
  assign bank_link.result_reset = state==IDLE && cmd_valid && cmd_ready &&
      cmd_exec!=3'd4;
  assign bank_link.result_accept = state==ROW && rd_valid && rd_ready;
  assign bank_link.result_physical_addr = rd_tile;
  assign bank_link.result_logical_tile = rd_tile;
  assign read_pending = bank_link.result_pending;
  assign rsp_valid = bank_link.result_rsp_valid;
  assign bank_link.result_rsp_ready = rsp_ready;
  assign rsp_tile = bank_link.result_rsp_tile;
  assign rsp_bits = bank_link.result_rsp_bits;
  assign bank_link.g_x_read_valid = state==G_R0 && !g_fault && !g_commit_bad &&
        !(g_commit && g_returned[11:3]==g_tile);
  assign bank_link.g_x_read_tile = g_tile;
  assign g_x_hold = bank_link.g_x_hold;
  assign bank_link.g_gate_read_valid = state==G_R1 && !g_fault && !g_commit_bad;
  assign bank_link.g_gate_read_tile = g_gate_tile;
  assign g_gate_hold = bank_link.g_gate_hold;
  assign bank_link.qd_read_valid = state==QD_READ;
  assign bank_link.qd_read_word = exec_mode==3'd2 ? 13'd4224+13'(qd_index) :
                  13'(qd_index);
  assign qd_word = bank_link.qd_word;
  assign bank_link.res_read_valid = res_bank_read;
  assign bank_link.res_read_index = res_index[9:0];
  assign res_b_hold = bank_link.res_b_hold;

  laya_w_prep_service_v1 w_cache (
    .clk,.rst_n,.load_cancel(1'b0),
    .load_valid(state==LOAD_REQ),.load_ready,.load_slot(active_slot),
    .load_epoch(active_epoch),.load_k(active_slot ? 32'd2624 : 32'd1024),
    .load_n(mode_qkv ? 32'd3072 : (active_slot ? 32'd1024 : 32'd5248)),
    .load_weight_key(active_key),.load_model_identity(model_id),
    .load_expected_aux_header(active_slot ? down_aux_header : aux_header),
    .load_base(active_slot ? down_load_base : load_base),
    .load_bytes(active_slot ? down_load_bytes : load_bytes),
    .load_aux_base(active_slot ? down_aux_base : aux_base),
    .load_bias_base(active_slot ? down_bias_base : bias_base),
    .load_bias_bytes(active_slot ? down_bias_bytes : bias_bytes),
    .load_done,.load_error,.load_reject,
    .load_protocol_error,.load_numeric_error,
    .load_scale_checks,.load_bad_element,
    .slot_state,.slot_epoch,.slot_readers,.slot_coverage,.commit_ready(4'hf),
    .araddr,.arlen,.arsize,.arburst,.arvalid,.arready,
    .rdata,.rresp,.rlast,.rvalid,.rready,
    .aux_araddr,.aux_arlen,.aux_arsize,.aux_arburst,.aux_arvalid,.aux_arready,
    .aux_rdata,.aux_rresp,.aux_rlast,.aux_rvalid,.aux_rready,
    .lease_valid(state==LEASE_REQ),.lease_ready,.lease_done,.lease_error,
    .lease_slot(active_slot),.lease_epoch(active_epoch),
    .lease_k(phase_down ? 32'd2624 : 32'd1024),
    .lease_n(mode_qkv ? 32'd3072 : (phase_down ? 32'd1024 : 32'd5248)),
    .lease_weight_key(active_key),.lease_model_identity(model_id),
    .lease_numeric_identity(numeric_id),.lease_task_context(task_context),
    .read_valid(state==W_REQ),.read_ready(w_read_ready),.read_error(w_read_error),
    .read_slot(active_slot),.read_epoch(active_epoch),.read_tile(16'(tile_no)),
    .read_group(8'(group_no)),.read_pair(1'b0),
    .read_model_identity(model_id),.read_numeric_identity(numeric_id),
    .read_task_context(task_context),.ret_valid,.ret_ready,.ret_slot,.ret_pair,
    .ret_epoch,.ret_tile,.ret_group,.ret_model_identity,.ret_numeric_identity,
    .ret_task_context,.ret_q,.ret_scale,.ret_bias,.ret_mask,
    .release_valid(state==W_RELEASE_REQ),.release_ready,.release_done,.release_error,
    .release_slot(active_slot),.release_epoch(active_epoch),
    .release_numeric_identity(numeric_id),.release_task_context(task_context),
    .wp_valid(state==WP_REQ),.wp_ready,
    .wp_id(id),.wp_source_epoch(source_epoch),.wp_epoch(w_epoch),
    .wp_request(numeric_id[63:0]),.wp_generation(numeric_id[127:64]),
    .wp_key(weight_key),.wp_model(model_id),.wp_numeric(numeric_id),
    .wp_header(aux_header),.wp_base(load_base),.wp_bytes(load_bytes),
    .wp_aux_base(aux_base),.wp_bias_base(bias_base),
    .wp_bias_bytes(bias_bytes),.wp_done_valid,
    .wp_done_ready(state==WP_WAIT && wp_done_valid),
    .wp_done_id,.wp_done_source_epoch,.wp_done_epoch,
    .wp_done_request,.wp_done_generation,.wp_done_key,
    .wp_done_model,.wp_done_numeric,.wp_done_status,.wp_done_op,
    .wp_done_check_status,.wp_done_detail,.wp_done_bad64);

  tm4tn8_sync_ps_front_v2 front (
    .clk,.rst_n,.config_valid(state==FRONT_CFG),.config_ready(front_cfg_ready),
    .config_k(phase_down ? 16'd2624 : 16'd1024),
    .config_n(mode_qkv ? 16'd3072 : (phase_down ? 16'd1024 : 16'd5248)),
    .config_rows(3'd1),.config_row0({9'd0,token_row}),
    .config_identity({front_issue_identity,64'd0}),
    .issue_valid(state==ISSUE),.issue_ready(front_issue_ready),
    .issue_identity(front_issue_identity),.issue_version(4'd1),
    .issue_sequence(27'(32'(group_no)*(mode_qkv ? 32'd384 :
      (phase_down ? 32'd128 : 32'd656))+32'(tile_no))),
    .issue_group(group_no),.issue_tile(tile_no),.issue_lane_mask(8'hff),
    .issue_trace_mask(4'd0),.issue_trace_lane(12'd0),
    .issue_a8({768'd0,a_q}),.issue_sa({96'd0,a_scale}),
    .issue_w8(w_q),.issue_sw(w_scale),
    .abort_valid(front_abort_valid),.abort_ready(front_abort_ready),
    .commit_valid,.commit_ready,.commit_tag,.commit_tile,
    .commit_lane_mask(commit_mask),.commit_bad_mask(commit_bad),
    .commit_phase,.commit_next_ps,
    .final_skip_valid,.final_skip_ready(4'hf),.final_skip_tile,.final_skip_mask,
    .trace_valid(),.trace_ready(4'd0),.trace_slot(),.trace_tag(),.trace_payload(),
    .trace_ack_valid(4'd0),.trace_ack_slot(8'd0),
    .trace_ack_tag(768'd0),.trace_ack_ok(4'hf),
    .result_free,.result_reserved,.result_returned,.trace_free,
    .done_valid(front_done),.done_error(front_error),
    .protocol_failure(front_protocol),.first_error_rank(front_first_rank),
    .first_bad_element(front_bad),.accepted_stripes(front_accepted));

  geglu_canonical_core g_core (
    .clk,.reset(!rst_n),.in_valid(g_issue),
    .in_x(g_x_hold[g_lane*32+:32]),
    .in_g(g_gate_hold[g_lane*32+:32]),
    .commit_valid(g_commit),.data(g_data),
    .status(g_status),.failed(g_failed));

  laya_vector_add_stream_v1 residual_add (
    .clk,.rst_n,.in_valid(add_in_valid),.in_ready(add_in_ready),
    .a(res_a_hold),.b(res_b_hold),
    .out_valid(add_out_valid),.out_ready(state==RES_WAIT || state==RES_DRAIN),
    .bits(add_bits));

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE; id<=0;w_epoch<=0;source_epoch<=0;down_epoch<=0;
      mode_qkv<=0;token_row<=0;result_mode<=0;result_row<=0;norm_count<=0;
      weight_key<=0;down_weight_key<=0;model_id<=0;
      numeric_id<=0;task_context<=0;aux_header<=0;load_base<=0;
      load_bytes<=0;aux_base<=0;bias_base<=0;bias_bytes<=0;
      down_aux_header<=0;down_load_base<=0;down_load_bytes<=0;
      down_aux_base<=0;down_bias_base<=0;down_bias_bytes<=0;
      active_slot<=0;phase_down<=0;
      front_issue_identity<=0;group_no<=0;tile_no<=0;
      a_q<=0;a_scale<=0;w_q<=0;w_scale<=0;
      w_pending<=0;have_w_lease<=0;have_a_row<=0;
      local_fault<=0;final_duplicate<=0;final_missing<=0;
      final_cover<=0;final_count<=0;
      stage_stripes<=0;
      g_tile<=0;g_lane<=0;
      g_issued<=0;g_returned<=0;g_credits<=0;g_cover<=0;
      g_fault<=0;g_bad<=32'hffffffff;qd_index<=0;
      skip_count<=0;res_index<=0;res_issued<=0;res_consumed<=0;
      res_written<=0;res_a_hold<=0;res_ordinal<=0;
      res_fault<=0;
      done_status<=0;done_phase<=4'd7;
      done_bad_element<=32'hffffffff;
      actual_w_reads<=0;actual_w_returns<=0;
      actual_stripes<=0;actual_ps_commits<=0;
      saved_mean<=0;saved_variance<=0;saved_inverse<=0;
      source_prepared<=0;
      exec_mode<=0;result_exec<=0;
      staged_ln_delegated<=0;
      wp_delegated<=0;
    end else begin
      if(state==LN_WAIT && !mode_qkv && x_valid && x_ready)begin
        if(skip_count<11'd1024)begin
          skip_bank[skip_count[9:0]]<=x_bits;
          skip_count<=skip_count+1'b1;
        end else begin
          local_fault<=1;
          done_status<=4'd7;done_phase<=ln_error_phase;
          done_bad_element<=32'hffffffff;
        end
      end
      if(norm_valid && mode_qkv && exec_mode==3'd0)begin
        if(state!=LN_WAIT || norm_count>=11'd1024 ||
           norm_index!==norm_count[9:0])local_fault<=1;
        else begin
          norm_count<=norm_count+1'b1;
        end
      end
      if(last_commit)begin
        if(commit_tile[9:0]>last_tile || final_cover[commit_tile[9:0]] ||
           (commit_mask[7:0] | commit_bad[7:0])!=8'hff)begin
          final_duplicate<=1;local_fault<=1;
        end else begin
          // Earlier poison may remove lanes from commit_mask. Require every
          // missing lane to be explained by bad/poison metadata, and count
          // the commit so a later duplicate remains a protocol fault.
          final_cover[commit_tile[9:0]]<=1;
          final_count<=final_count+1;
        end
      end
      if(commit_valid[0] && commit_ready[0])actual_ps_commits<=actual_ps_commits+1;
      case({g_issue,g_commit})
        2'b10:g_credits<=g_credits+1'b1;
        2'b01:if(g_credits!=0)g_credits<=g_credits-1'b1;
        default:;
      endcase
      if(g_issue)g_issued<=g_issued+1'b1;
      if(g_commit)begin
        if(!g_return_legal)begin
          g_fault<=1;done_status<=4'd7;done_phase<=4'd4;
          done_bad_element<=32'hffffffff;
        end else begin
          g_returned<=g_returned+1'b1;
          if(g_status!=0 && !g_fault)begin
            g_fault<=1;g_bad<=g_failed==32'd10 ?
              32'd2624+32'(g_returned) : 32'(g_returned);
            done_status<=4'd6;done_phase<=4'd4;
            done_bad_element<=g_failed==32'd10 ?
              32'd2624+32'(g_returned) : 32'(g_returned);
          end else if(!g_fault)begin
            g_cover[g_returned]<=1;
          end
        end
      end
      if(state==W_REQ && w_read_ready)begin w_pending<=1;actual_w_reads<=actual_w_reads+1;end
      if((state==W_WAIT || state==DRAIN) && (ret_valid || w_read_error))begin
        w_pending<=0;
        if(ret_valid)actual_w_returns<=actual_w_returns+1;
      end
      case(state)
        IDLE:if(cmd_valid && cmd_ready)begin
          staged_ln_delegated<=staged_ln_accept;
          wp_delegated<=0;
          id<=cmd_id;w_epoch<=cmd_w_epoch;
          source_epoch<=cmd_source_epoch;weight_key<=cmd_weight_key;
          mode_qkv<=cmd_mode;token_row<=cmd_row;
          exec_mode<=cmd_exec;result_exec<=cmd_exec;
          source_prepared<=cmd_prepared_source;
          result_mode<=cmd_mode;result_row<=cmd_row;norm_count<=0;
          down_epoch<=cmd_down_w_epoch;
          down_weight_key<=cmd_down_weight_key;
          model_id<=cmd_model_identity;numeric_id<=cmd_numeric_identity;
          task_context<=cmd_task_context;aux_header<=cmd_expected_aux_header;
          down_aux_header<=cmd_down_expected_aux_header;
          load_base<=cmd_load_base;load_bytes<=cmd_load_bytes;
          down_load_base<=cmd_down_load_base;
          down_load_bytes<=cmd_down_load_bytes;
          aux_base<=cmd_aux_base;bias_base<=cmd_bias_base;bias_bytes<=cmd_bias_bytes;
          down_aux_base<=cmd_down_aux_base;
          down_bias_base<=cmd_down_bias_base;
          down_bias_bytes<=cmd_down_bias_bytes;
          active_slot<=0;phase_down<=0;
          front_issue_identity<={cmd_task_context[31:0],cmd_id,cmd_w_epoch};
          group_no<=0;tile_no<=0;w_pending<=0;have_w_lease<=0;have_a_row<=0;
          final_cover<=0;final_count<=0;final_duplicate<=0;final_missing<=0;
          stage_stripes<=0;
          g_tile<=0;g_lane<=0;g_issued<=0;g_returned<=0;
          g_credits<=0;g_cover<=0;g_fault<=0;g_bad<=32'hffffffff;
          qd_index<=0;
          skip_count<=0;res_index<=0;res_issued<=0;res_consumed<=0;
          res_written<=0;res_a_hold<=0;res_ordinal<=0;
          res_fault<=0;
          local_fault<=0;done_status<=0;done_phase<=4'd7;
          done_bad_element<=32'hffffffff;
          actual_w_reads<=0;actual_w_returns<=0;actual_stripes<=0;actual_ps_commits<=0;
          saved_mean<=0;saved_variance<=0;saved_inverse<=0;
          if(cmd_exec==3'd4)begin
            if(!cmd_mode || !cmd_cold || cmd_prepared_source ||
               cmd_id==0 || cmd_source_epoch==0 ||
               cmd_w_epoch==0 || cmd_weight_key!=16'h0001 ||
               cmd_task_context[95:88]!=8'd1 ||
               cmd_task_context[87:72]!=16'd0 ||
               cmd_task_context[71:64]!=8'd128 ||
               cmd_task_context[63:56]!=8'd1 ||
               cmd_task_context[55:40]!=16'd0 ||
               cmd_task_context[39:32]!=8'd1 ||
               cmd_task_context[31:0]==0 ||
               cmd_load_bytes[0]!=32'd1572864 ||
               cmd_load_bytes[1]!=32'd1572864 ||
               cmd_load_bytes[2]!=32'd196608 ||
               cmd_bias_bytes!=0 || !bank_link.service_quiescent ||
               bank_link.gamma_token_valid)begin
              done_status<=4'd7;done_phase<=4'd9;state<=DONE;
            end else state<=WP_REQ;
          end else if(cmd_exec!=3'd0)begin
            if(cmd_exec>3'd2 || !cmd_mode || !cmd_prepared_source ||
               !prepared_match ||
               (cmd_exec==3'd1 && !gamma_match))begin
              done_status<=4'd7;done_phase<=4'd14;state<=DONE;
            end else if(cmd_exec==3'd1)state<=STAGED_PROXY;
            else if(!q16_window_ok)begin
              done_status<=4'd7;done_phase<=4'd14;state<=DONE;
            end else begin
              state<=Q16_WAIT;
            end
          end else if((cmd_prepared_source &&
               (!cmd_mode || !prepared_basic_match)) ||
             cmd_id==0 || cmd_w_epoch==0 ||
             (!cmd_mode && cmd_down_w_epoch==0) ||
             cmd_task_context[31:0]==0 ||
             cmd_task_context[95:88]!=8'd1 ||
             cmd_task_context[87:72]!={9'd0,cmd_row} ||
             (!cmd_mode && cmd_row!=0) ||
             (cmd_mode && (cmd_weight_key!=16'h0001 ||
               cmd_load_bytes[0]!=32'd1572864 ||
               cmd_load_bytes[1]!=32'd1572864 ||
               cmd_load_bytes[2]!=32'd196608 || cmd_bias_bytes!=0)))begin
            done_status<=4'd7;
            if(cmd_prepared_source)done_phase<=4'd14;
            state<=DONE;
          end else state<=cmd_cold ? LOAD_REQ : LN_CMD;
        end
        LOAD_REQ:if(load_ready)state<=LOAD_WAIT;
        WP_REQ:if(wp_ready)begin
          wp_delegated<=1;
          state<=WP_WAIT;
        end
        WP_WAIT:if(wp_done_valid)begin
          if(wp_done_id!=id || wp_done_source_epoch!=source_epoch ||
             wp_done_epoch!=w_epoch || wp_done_key!=weight_key ||
             wp_done_model!=model_id || wp_done_numeric!=numeric_id ||
             wp_done_request!=numeric_id[63:0] ||
             wp_done_generation!=numeric_id[127:64])begin
            done_status<=4'd7;wp_delegated<=0;
          end else begin
            done_status<=wp_done_status;
            done_bad_element<=wp_done_bad64[31:0];
          end
          done_phase<=4'd9;state<=DONE;
        end
        LOAD_WAIT:if(load_done)begin
          if(load_error || load_reject || slot_state[active_slot]!=3'd2 ||
             slot_epoch[active_slot]!=active_epoch || slot_readers[active_slot]!=0)begin
            done_status<=4'd7;done_phase<=mode_qkv ? 4'd9 : (active_slot ? 4'd1 : 4'd0);
            done_bad_element<=load_bad_element;state<=DONE;
          end else if(!active_slot && !mode_qkv)begin
            active_slot<=1;state<=LOAD_REQ;
          end else begin
            active_slot<=0;state<=LN_CMD;
          end
        end
        LN_CMD:if(ln_cmd_ready)state<=LN_WAIT;
        LN_WAIT:begin
          if(ln_row_valid)begin
            have_a_row<=1;
            if(local_fault ||
               (source_prepared && feed_state!=FEED_DONE) ||
               (mode_qkv ? norm_count!=11'd1024 :
                 (x_valid && x_ready && skip_count>=11'd1024)))begin
              done_status<=4'd7;done_phase<=ln_error_phase;
              state<=A_RELEASE;
            end else state<=LEASE_REQ;
            saved_mean<=ln_mean;saved_variance<=ln_variance;saved_inverse<=ln_inverse;
          end
          else if(ln_done_valid && ln_done_status!=0)begin
            done_status<=ln_done_status;done_phase<=ln_error_phase;
            done_bad_element<=ln_done_bad;state<=DONE;
          end
        end
        LEASE_REQ:if(lease_ready)state<=LEASE_WAIT;
        LEASE_WAIT:if(lease_done)begin
          if(lease_error)begin
            done_status<=4'd7;done_phase<=matrix_error_phase;
            state<=A_RELEASE;
          end
          else begin have_w_lease<=1;state<=FRONT_CFG;end
        end
        FRONT_CFG:if(front_cfg_ready)state<=A_REQ;
        A_REQ:if(front_protocol)begin
          local_fault<=1;done_phase<=matrix_error_phase;state<=DRAIN;
        end
          else if(ln_rd_ready)state<=A_WAIT;
        A_WAIT:if(front_protocol)begin
          local_fault<=1;done_phase<=matrix_error_phase;state<=DRAIN;
        end
          else if(ln_rsp_valid)begin
          if(ln_rsp_group!=group_no)begin
            local_fault<=1;done_status<=4'd7;
            done_phase<=matrix_error_phase;state<=DRAIN;
          end else begin
            a_q<=ln_rsp_q;a_scale<=half_to_f32(ln_rsp_scale);
            tile_no<=0;state<=W_REQ;
          end
        end
        W_REQ:if(front_protocol)begin
          local_fault<=1;done_phase<=matrix_error_phase;state<=DRAIN;
        end
          else if(w_read_ready)state<=W_WAIT;
        W_WAIT:begin
          if(front_protocol || w_read_error || (ret_valid && !ret_ok))begin
            local_fault<=1;done_status<=4'd7;
            done_phase<=matrix_error_phase;state<=DRAIN;
          end else if(ret_valid)begin
            // The outer ret_q index denotes the first/second tile of a
            // read_pair response, not the cache slot. This service requests
            // one tile, so its data is always in response lane zero.
            w_q<=ret_q[0];
            for(int lane=0;lane<8;lane++)
              w_scale[lane*32+:32]<=half_to_f32(ret_scale[0][lane]);
            state<=ISSUE;
          end
        end
        ISSUE:if(front_protocol)begin
          local_fault<=1;done_phase<=matrix_error_phase;state<=DRAIN;
        end
          else if(front_issue_ready)begin
          actual_stripes<=actual_stripes+1;
          stage_stripes<=stage_stripes+1;
          if(tile_no==last_tile)begin
            if(group_no==last_group)state<=DRAIN;
            else begin group_no<=group_no+1;state<=A_REQ;end
          end else begin tile_no<=tile_no+1;state<=W_REQ;end
        end
        DRAIN:if(front_done && !w_pending && !ret_valid)begin
          if(local_fault || front_protocol)begin
            done_status<=4'd7;done_phase<=matrix_error_phase;
          end else if(front_error || front_first_rank!='1)begin
            done_status<=4'd6;done_phase<=matrix_error_phase;
            done_bad_element<=front_bad;
          end else if(front_accepted!=expected_stripes ||
                      stage_stripes!=expected_stripes)begin
            done_status<=4'd7;done_phase<=matrix_error_phase;
          end else if(final_duplicate ||
                      final_count!=(mode_qkv ? 10'd384 :
                                     (phase_down ? 10'd128 : 10'd656)) ||
                      (mode_qkv ? !(&final_cover[383:0]) :
                        (phase_down ? !(&final_cover[127:0]) : !(&final_cover))))begin
            done_status<=4'd7;done_phase<=matrix_error_phase;
            final_missing<=1;
          end
          state<=W_RELEASE_REQ;
        end
        W_RELEASE_REQ:if(release_ready)state<=W_RELEASE_WAIT;
        W_RELEASE_WAIT:if(release_done)begin
          if(release_error)begin
            done_status<=4'd7;done_phase<=matrix_error_phase;
          end
          have_w_lease<=0;state<=A_RELEASE;
        end
        A_RELEASE:if(!have_a_row)state<=DONE;
          else if(ln_release_ready)state<=A_DONE;
        A_DONE:if(ln_done_valid)begin
          have_a_row<=0;
          if(ln_done_status!=0)begin
            done_status<=ln_done_status;
            done_phase<=exec_mode!=3'd0 ? 4'd14 :
                        (mode_qkv ? 4'd10 : (phase_down ? 4'd5 : 4'd2));
            done_bad_element<=ln_done_bad;state<=DONE;
          end else if(done_status!=0)state<=DONE;
          else if(exec_mode==3'd1 || exec_mode==3'd2)state<=DONE;
          else if(mode_qkv)state<=ROW;
          else if(phase_down)state<=RES_INIT;
          else begin
            g_tile<=0;g_lane<=0;g_issued<=0;g_returned<=0;
            g_credits<=0;g_cover<=0;g_fault<=0;
            state<=G_R0;
          end
        end
        G_R0:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else if(!(g_commit && g_returned[11:3]==g_tile))begin
            state<=G_R1;
          end
        G_R1:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else begin
            state<=G_SEND;
          end
        G_SEND:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else if(g_issue)begin
            if(g_lane==3'd7)begin
              if(g_tile==9'd327)state<=G_WAIT;
              else begin g_tile<=g_tile+1'b1;state<=G_R0;end
              g_lane<=0;
            end else g_lane<=g_lane+1'b1;
          end
        G_WAIT:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else if(g_returned==12'd2624 && g_credits==0 && (&g_cover))begin
            qd_index<=0;state<=QD_CMD;
          end
        G_DRAIN:if(g_credits==0 && !g_commit)state<=DONE;
        QD_CMD:if(ln_cmd_ready)state<=QD_READ;
        QD_READ:begin
          state<=QD_SEND;
        end
        QD_SEND:if(ln_x_ready)begin
          qd_index<=qd_index+1'b1;
          state<=qd_index==(exec_mode==3'd2 ? 12'd1023 : 12'd2623) ?
                 QD_WAIT : QD_READ;
        end
        QD_WAIT:begin
          if(ln_row_valid)begin
            if(exec_mode==3'd2)begin
              state<=Q16_WAIT;
            end else begin
            have_a_row<=1;active_slot<=1;phase_down<=1;
            front_issue_identity<={task_context[31:0],id,down_epoch};
            group_no<=0;tile_no<=0;stage_stripes<=0;
            final_cover<=0;final_count<=0;
            final_duplicate<=0;final_missing<=0;local_fault<=0;
            state<=LEASE_REQ;
            end
          end else if(ln_done_valid && ln_done_status!=0)begin
            done_status<=ln_done_status;
            done_phase<=exec_mode==3'd2 ? 4'd14 : 4'd5;
            done_bad_element<=ln_done_bad;state<=DONE;
          end
        end
        Q16_WAIT:if(q16_fill_done_valid)begin
          done_status<=q16_fill_done_status;
          done_phase<=q16_fill_done_status==0 ? 4'd7 : 4'd14;
          done_bad_element<=q16_fill_done_bad;
          state<=DONE;
        end
        RES_INIT:begin
          if(skip_count!=11'd1024 || final_count!=10'd128 ||
             !(&final_cover[127:0]) || g_credits!=0 ||
             res_issued!=0 || res_consumed!=0 || res_written!=0 ||
             add_out_valid)begin
            res_fault<=1;done_status<=4'd7;done_phase<=4'd8;
            done_bad_element<=32'hffffffff;state<=RES_DRAIN;
          end else state<=RES_READ;
        end
        RES_READ:begin
          if(res_index>=11'd1024 || res_issued!=res_index ||
             res_consumed!=res_index || res_written!=res_index ||
             add_out_valid)begin
            res_fault<=1;done_status<=4'd7;done_phase<=4'd8;
            done_bad_element<=32'hffffffff;state<=RES_DRAIN;
          end else begin
            // A clocked read into held operands. No result bank write can
            // occur in this state, so the Down value is read before reuse.
            res_a_hold<=skip_bank[res_index[9:0]];
            res_ordinal<=res_index[9:0];
            state<=RES_SEND;
          end
        end
        RES_SEND:begin
          if(res_index>=11'd1024 || res_ordinal!=res_index[9:0] ||
             add_out_valid)begin
            res_fault<=1;done_status<=4'd7;done_phase<=4'd8;
            done_bad_element<=32'hffffffff;state<=RES_DRAIN;
          end else if(res_a_hold[30:23]==8'hff ||
                      res_b_hold[30:23]==8'hff)begin
            res_fault<=1;done_status<=4'd6;done_phase<=4'd8;
            done_bad_element<=32'(res_index);state<=RES_DRAIN;
          end else if(add_accept)begin
            res_issued<=res_issued+1'b1;
            res_index<=res_index+1'b1;
            state<=RES_WAIT;
          end
        end
        RES_WAIT:if(add_consume)begin
          if(res_issued!=res_consumed+11'd1 ||
             res_consumed!=res_written || res_consumed>=11'd1024 ||
             res_consumed!=11'(res_ordinal))begin
            if(res_consumed<res_issued)res_consumed<=res_consumed+1'b1;
            res_fault<=1;done_status<=4'd7;done_phase<=4'd8;
            done_bad_element<=32'hffffffff;state<=RES_DRAIN;
          end else if(add_bits[30:23]==8'hff)begin
            res_consumed<=res_consumed+1'b1;
            res_fault<=1;done_status<=4'd6;done_phase<=4'd8;
            done_bad_element<=32'(res_consumed);state<=RES_DRAIN;
          end else begin
            res_consumed<=res_consumed+1'b1;
            res_written<=res_written+1'b1;
            if(res_consumed==11'd1023)state<=ROW;
            else state<=RES_READ;
          end
        end
        RES_DRAIN:begin
          if(add_consume)begin
            if(res_consumed<res_issued)res_consumed<=res_consumed+1'b1;
            else begin
              done_status<=4'd7;done_phase<=4'd8;
              done_bad_element<=32'hffffffff;
            end
          end else if(res_consumed==res_issued)state<=DONE;
        end
        ROW:begin
          if(rd_valid && rd_tile>(mode_qkv ? QKV_LAST_READ_TILE : DOWN_LAST_TILE) &&
             !row_release_valid &&
             !rsp_valid && !read_pending)begin
            done_status<=4'd7;done_phase<=4'd7;
            done_bad_element<=32'hffffffff;state<=DONE;
          end else if(row_release_valid && row_release_ready)state<=DONE;
        end
        STAGED_PROXY:begin
          if(staged_ln_view_valid)begin
            saved_mean<=ln_mean;
            saved_variance<=ln_variance;
            saved_inverse<=ln_inverse;
          end
          if(staged_ln_done_valid)begin
            done_status<=staged_ln_identity_bad ? 4'd7 :
                staged_ln_done_status;
            done_phase<=staged_ln_identity_bad ? 4'd12 :
                staged_ln_done_phase;
            done_bad_element<=staged_ln_identity_bad ?
                32'hffffffff : staged_ln_done_bad;
            result_exec<=staged_ln_result_exec;
            result_row<=staged_ln_done_row;
            state<=DONE;
          end
        end
        DONE:if(done_ready)state<=IDLE;
        default:state<=IDLE;
      endcase
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    if(state==ISSUE && front_issue_ready)
      assert(ret_valid==0 && !w_pending)else $fatal(1,"Wi issue before W retirement");
    if(state==ROW && !mode_qkv)
      assert(phase_down && done_status==0 && final_count==10'd128 &&
             &final_cover[127:0] && skip_count==11'd1024 &&
             res_index==11'd1024 && res_issued==11'd1024 &&
             res_consumed==11'd1024 && res_written==11'd1024 &&
             !add_out_valid)
        else $fatal(1,"Residual visible incomplete row");
    if(state==ROW && mode_qkv)
      assert(!phase_down && done_status==0 && norm_count==11'd1024 &&
             final_count==10'd384 && (&final_cover[383:0]) &&
             !have_w_lease && !have_a_row)
        else $fatal(1,"QKV visible incomplete row");
  end
`endif
endmodule

module laya_lnq_wi_gqdown_row_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
  input logic cmd_mode,
  input logic [6:0] cmd_row,
  input logic cmd_prepared_source,
  input logic [31:0] cmd_source_epoch,
  input logic [2:0] cmd_exec,
  input logic [63:0] cmd_gamma_aux_base, cmd_gamma_aux_span,
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
  output logic prep_token_valid,
  output logic gamma_token_valid,
  output logic prep_fault,
  output logic a_window_ready,
  input logic a_window_release_valid,
  input logic a_window_discard,
  output logic a_window_release_ready,
  input logic [31:0] cmd_w_epoch,
  input logic [15:0] cmd_weight_key,
  input logic [3327:0] cmd_model_identity,
  input logic [671:0] cmd_numeric_identity,
  input logic [95:0] cmd_task_context,
  input logic [1023:0] cmd_expected_aux_header,
  input logic [2:0][63:0] cmd_load_base,
  input logic [2:0][31:0] cmd_load_bytes,
  input logic [63:0] cmd_aux_base,
  input logic [63:0] cmd_bias_base,
  input logic [31:0] cmd_bias_bytes,
  input logic [31:0] cmd_down_w_epoch,
  input logic [15:0] cmd_down_weight_key,
  input logic [1023:0] cmd_down_expected_aux_header,
  input logic [2:0][63:0] cmd_down_load_base,
  input logic [2:0][31:0] cmd_down_load_bytes,
  input logic [63:0] cmd_down_aux_base,
  input logic [63:0] cmd_down_bias_base,
  input logic [31:0] cmd_down_bias_bytes,
  input logic x_valid,
  output logic x_ready,
  input logic [31:0] x_bits,
  input logic gamma_valid,
  output logic gamma_ready,
  input logic [31:0] gamma_bits,
  output logic row_valid,
  input logic rd_valid,
  output logic rd_ready,
  input logic [9:0] rd_tile,
  output logic rsp_valid,
  input logic rsp_ready,
  output logic [9:0] rsp_tile,
  output logic [255:0] rsp_bits,
  input logic row_release_valid,
  input logic row_release_discard,
  output logic row_release_ready,
  output logic done_valid,
  input logic done_ready,
  output logic [3:0] done_status,
  output logic [3:0] done_phase,
  output logic [7:0] done_op,
  output logic [15:0] done_check_status,
  output logic [31:0] done_detail,
  output logic [63:0] done_bad64,
  output logic result_mode,
  output logic [2:0] result_exec,
  output logic [6:0] result_row,
  output logic [31:0] done_bad_element,
  output logic [31:0] mean_bits, variance_bits, inverse_bits,
  output logic [31:0] actual_w_reads, actual_w_returns,
  output logic [31:0] actual_stripes, actual_ps_commits,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready
);
  laya_lnq_bank_link_v1 bank_link();
  laya_lnq_bank_service_v1 bank_service (
    .clk(clk),
    .rst_n(rst_n),
    .ln_cmd_valid(bank_link.ln_cmd_valid),
    .ln_cmd_ready(bank_link.ln_cmd_ready),
    .ln_source_mode(bank_link.ln_source_mode),
    .ln_gamma_kind(bank_link.ln_gamma_kind),
    .ln_cmd_row(bank_link.ln_cmd_row),
    .ln_only_ready(bank_link.ln_only_ready),
    .staged_ln_cmd_valid(bank_link.staged_ln_cmd_valid),
    .staged_ln_cmd_ready(bank_link.staged_ln_cmd_ready),
    .staged_ln_row(bank_link.staged_ln_row),
    .staged_ln_view_valid(bank_link.staged_ln_view_valid),
    .staged_ln_rd_valid(bank_link.staged_ln_rd_valid),
    .staged_ln_rd_tile(bank_link.staged_ln_rd_tile),
    .staged_ln_rd_ready(bank_link.staged_ln_rd_ready),
    .staged_ln_release_valid(bank_link.staged_ln_release_valid),
    .staged_ln_release_discard(bank_link.staged_ln_release_discard),
    .staged_ln_release_ready(bank_link.staged_ln_release_ready),
    .staged_ln_done_valid(bank_link.staged_ln_done_valid),
    .staged_ln_done_ready(bank_link.staged_ln_done_ready),
    .staged_ln_done_status(bank_link.staged_ln_done_status),
    .staged_ln_done_phase(bank_link.staged_ln_done_phase),
    .staged_ln_done_bad(bank_link.staged_ln_done_bad),
    .staged_ln_done_id(bank_link.staged_ln_done_id),
    .staged_ln_done_epoch(bank_link.staged_ln_done_epoch),
    .staged_ln_done_row(bank_link.staged_ln_done_row),
    .staged_ln_result_exec(bank_link.staged_ln_result_exec),
    .staged_ln_done_op(bank_link.staged_ln_done_op),
    .staged_ln_done_check_status(bank_link.staged_ln_done_check_status),
    .staged_ln_done_detail(bank_link.staged_ln_done_detail),
    .staged_ln_done_bad64(bank_link.staged_ln_done_bad64),
    .ln_x_valid(bank_link.ln_x_valid),
    .ln_x_ready(bank_link.ln_x_ready),
    .ln_x_bits(bank_link.ln_x_bits),
    .ln_gamma_valid(bank_link.ln_gamma_valid),
    .ln_gamma_ready(bank_link.ln_gamma_ready),
    .ln_gamma_bits(bank_link.ln_gamma_bits),
    .ln_row_valid(bank_link.ln_row_valid),
    .ln_rd_valid(bank_link.ln_rd_valid),
    .ln_rd_ready(bank_link.ln_rd_ready),
    .ln_rd_group(bank_link.ln_rd_group),
    .ln_rsp_valid(bank_link.ln_rsp_valid),
    .ln_rsp_ready(bank_link.ln_rsp_ready),
    .ln_rsp_group(bank_link.ln_rsp_group),
    .ln_rsp_q(bank_link.ln_rsp_q),
    .ln_rsp_scale(bank_link.ln_rsp_scale),
    .ln_release_valid(bank_link.ln_release_valid),
    .ln_release_ready(bank_link.ln_release_ready),
    .ln_done_valid(bank_link.ln_done_valid),
    .ln_done_ready(bank_link.ln_done_ready),
    .ln_done_status(bank_link.ln_done_status),
    .ln_done_bad(bank_link.ln_done_bad),
    .ln_mean(bank_link.ln_mean),
    .ln_variance(bank_link.ln_variance),
    .ln_inverse(bank_link.ln_inverse),
    .norm_valid(bank_link.norm_valid),
    .norm_index(bank_link.norm_index),
    .norm_bits(bank_link.norm_bits),
    .q16_fill_cmd_valid(bank_link.q16_fill_cmd_valid),
    .q16_fill_cmd_ready(bank_link.q16_fill_cmd_ready),
    .q16_fill_done_valid(bank_link.q16_fill_done_valid),
    .q16_fill_done_ready(bank_link.q16_fill_done_ready),
    .q16_fill_done_status(bank_link.q16_fill_done_status),
    .q16_fill_done_bad(bank_link.q16_fill_done_bad),
    .q16_retire_success(bank_link.q16_retire_success),
    .q16_window_begin(bank_link.q16_window_begin),
    .q16_row(bank_link.q16_row),
    .q16_epoch(bank_link.q16_epoch),
    .q16_model(bank_link.q16_model),
    .q16_numeric(bank_link.q16_numeric),
    .q16_done(bank_link.q16_done),
    .q16_fault(bank_link.q16_fault),
    .q16_partial_owned(bank_link.q16_partial_owned),
    .q16_window_ok(bank_link.q16_window_ok),
    .q16_next_row(bank_link.q16_next_row),
    .a_window_ready(bank_link.a_window_ready),
    .a_window_release_valid(bank_link.a_window_release_valid),
    .a_window_discard(bank_link.a_window_discard),
    .a_window_release_ready(bank_link.a_window_release_ready),
    .bank_idle(bank_link.bank_idle),
    .prep_begin_idle(bank_link.prep_begin_idle),
    .prep_begin_allow(bank_link.prep_begin_allow),
    .prep_begin_valid(bank_link.prep_begin_valid),
    .prep_begin_ready(bank_link.prep_begin_ready),
    .prep_kind(bank_link.prep_kind),
    .prep_id(bank_link.prep_id),
    .prep_row(bank_link.prep_row),
    .prep_epoch(bank_link.prep_epoch),
    .prep_model_identity(bank_link.prep_model_identity),
    .prep_numeric_identity(bank_link.prep_numeric_identity),
    .prep_gamma_aux_base(bank_link.prep_gamma_aux_base),
    .prep_gamma_aux_span(bank_link.prep_gamma_aux_span),
    .prep_write_valid(bank_link.prep_write_valid),
    .prep_write_ready(bank_link.prep_write_ready),
    .prep_write_index(bank_link.prep_write_index),
    .prep_write_bits(bank_link.prep_write_bits),
    .prep_commit_valid(bank_link.prep_commit_valid),
    .prep_commit_ready(bank_link.prep_commit_ready),
    .prep_abort_valid(bank_link.prep_abort_valid),
    .prep_abort_ready(bank_link.prep_abort_ready),
    .prep_active(bank_link.prep_active),
    .prep_token_valid(bank_link.prep_token_valid),
    .gamma_token_valid(bank_link.gamma_token_valid),
    .gamma_retire_valid(1'b0),
    .gamma_retire_ready(bank_link.gamma_retire_ready),
    .service_quiescent(bank_link.service_quiescent),
    .prep_fault(bank_link.prep_fault),
    .prep_consume(bank_link.prep_consume),
    .match_id(bank_link.match_id),
    .match_row(bank_link.match_row),
    .match_epoch(bank_link.match_epoch),
    .match_model_identity(bank_link.match_model_identity),
    .match_numeric_identity(bank_link.match_numeric_identity),
    .match_kind(bank_link.match_kind),
    .match_gamma_aux_base(bank_link.match_gamma_aux_base),
    .match_gamma_aux_span(bank_link.match_gamma_aux_span),
    .prepared_basic_match(bank_link.prepared_basic_match),
    .prepared_match(bank_link.prepared_match),
    .gamma_match(bank_link.gamma_match),
    .norm_store_valid(bank_link.norm_store_valid),
    .norm_store_index(bank_link.norm_store_index),
    .norm_store_bits(bank_link.norm_store_bits),
    .ps_store_valid(bank_link.ps_store_valid),
    .ps_store_tile(bank_link.ps_store_tile),
    .ps_store_bits(bank_link.ps_store_bits),
    .g_store_valid(bank_link.g_store_valid),
    .g_store_index(bank_link.g_store_index),
    .g_store_bits(bank_link.g_store_bits),
    .res_store_valid(bank_link.res_store_valid),
    .res_store_index(bank_link.res_store_index),
    .res_store_bits(bank_link.res_store_bits),
    .feed_start(bank_link.feed_start),
    .feed_active(bank_link.feed_active),
    .feed_state(bank_link.feed_state),
    .replay_hold(bank_link.replay_hold),
    .result_reset(bank_link.result_reset),
    .result_accept(bank_link.result_accept),
    .result_physical_addr(bank_link.result_physical_addr),
    .result_logical_tile(bank_link.result_logical_tile),
    .result_pending(bank_link.result_pending),
    .result_rsp_valid(bank_link.result_rsp_valid),
    .result_rsp_ready(bank_link.result_rsp_ready),
    .result_rsp_tile(bank_link.result_rsp_tile),
    .result_rsp_bits(bank_link.result_rsp_bits),
    .g_x_read_valid(bank_link.g_x_read_valid),
    .g_x_read_tile(bank_link.g_x_read_tile),
    .g_x_hold(bank_link.g_x_hold),
    .g_gate_read_valid(bank_link.g_gate_read_valid),
    .g_gate_read_tile(bank_link.g_gate_read_tile),
    .g_gate_hold(bank_link.g_gate_hold),
    .qd_read_valid(bank_link.qd_read_valid),
    .qd_read_word(bank_link.qd_read_word),
    .qd_word(bank_link.qd_word),
    .res_read_valid(bank_link.res_read_valid),
    .res_read_index(bank_link.res_read_index),
    .res_b_hold(bank_link.res_b_hold)
  );
  laya_lnq_wi_gqdown_row_engine_v1 engine (.*, .bank_link(bank_link));
endmodule
