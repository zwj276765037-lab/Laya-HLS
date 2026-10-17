`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_lnq_wi_gqdown_row_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
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
  output logic row_release_ready,
  output logic done_valid,
  input logic done_ready,
  output logic [3:0] done_status,
  output logic [3:0] done_phase,
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
  localparam logic [9:0] WI_LAST_TILE=10'd655, DOWN_LAST_TILE=10'd127;
  localparam logic [6:0] WI_LAST_GROUP=7'd31, DOWN_LAST_GROUP=7'd81;
  typedef enum logic [5:0] {
    IDLE, LOAD_REQ, LOAD_WAIT, LN_CMD, LN_WAIT, LEASE_REQ, LEASE_WAIT,
    FRONT_CFG, A_REQ, A_WAIT, W_REQ, W_WAIT, ISSUE, DRAIN,
    W_RELEASE_REQ, W_RELEASE_WAIT, A_RELEASE, A_DONE, ROW, DONE,
    G_R0, G_R1, G_SEND, G_WAIT, G_DRAIN,
    QD_CMD, QD_READ, QD_SEND, QD_WAIT,
    RES_INIT, RES_READ, RES_SEND, RES_WAIT, RES_DRAIN
  } state_t;
  state_t state;

  logic [31:0] id, w_epoch;
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
  wire [9:0] last_tile=phase_down ? DOWN_LAST_TILE : WI_LAST_TILE;
  wire [6:0] last_group=phase_down ? DOWN_LAST_GROUP : WI_LAST_GROUP;
  wire [31:0] expected_stripes=phase_down ? 32'd10496 : 32'd20992;
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
  logic [31:0] final_bank [0:7][0:655];
  logic [31:0] skip_bank [0:1023];
  logic [10:0] skip_count, res_index, res_issued, res_consumed, res_written;
  logic [31:0] res_a_hold, res_b_hold;
  logic [9:0] res_ordinal;
  logic res_fault;
  wire add_in_ready, add_out_valid;
  wire [31:0] add_bits;
  wire add_accept=(state==RES_SEND) && add_in_ready && !res_fault &&
                  res_a_hold[30:23]!=8'hff && res_b_hold[30:23]!=8'hff;
  wire add_consume=(state==RES_WAIT || state==RES_DRAIN) && add_out_valid;
  logic [31:0] stage_stripes;
  logic [8:0] g_tile;
  wire [9:0] g_gate_tile={1'b0,g_tile}+10'd328;
  logic [2:0] g_lane;
  logic [255:0] g_x_hold,g_gate_hold;
  logic [11:0] g_issued,g_returned;
  logic [9:0] g_credits;
  logic [2623:0] g_cover;
  logic g_fault;
  logic [31:0] g_bad;
  logic [11:0] qd_index;
  logic [31:0] qd_word;
  wire g_commit;
  wire [31:0] g_data,g_status,g_failed;
  wire g_commit_bad=g_commit && g_status!=0;
  wire g_issue=(state==G_SEND) && !g_fault && !g_commit_bad &&
               g_issued<12'd2624 && g_credits<10'd512;
  wire g_return_legal=g_commit && g_credits!=0 &&
                      g_returned<12'd2624 && !g_cover[g_returned];
  logic [9:0] read_addr;
  logic read_pending;

  logic load_ready,load_done,load_error,load_reject;
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

  assign cmd_ready=state==IDLE;
  assign row_valid=state==ROW;
  assign done_valid=state==DONE;
  assign rd_ready=state==ROW && !row_release_valid && rd_tile<=DOWN_LAST_TILE &&
    !rsp_valid && !read_pending;
  assign row_release_ready=state==ROW && !rsp_valid && !read_pending;
  assign mean_bits=state==ROW || (state==DONE && done_status==0) ? saved_mean : 0;
  assign variance_bits=state==ROW || (state==DONE && done_status==0) ? saved_variance : 0;
  assign inverse_bits=state==ROW || (state==DONE && done_status==0) ? saved_inverse : 0;
  assign ret_ready=state==W_WAIT || state==DRAIN;
  assign commit_ready=4'hf;
  wire ln_x_ready,ln_gamma_ready;
  assign x_ready=(state==LN_WAIT) && ln_x_ready;
  assign gamma_ready=(state==LN_WAIT) && ln_gamma_ready;

  laya_lnq_row_v1 lnq (
    .clk,.rst_n,.cmd_valid(state==LN_CMD || state==QD_CMD),.cmd_ready(ln_cmd_ready),
    .source_direct(state==QD_CMD),
    .gamma_kind(2'd0),.cmd_row(16'd0),
    .x_valid((x_valid && state==LN_WAIT) || state==QD_SEND),
    .x_ready(ln_x_ready),.x_bits(state==QD_SEND ? qd_word : x_bits),
    .gamma_valid(gamma_valid && state==LN_WAIT),
    .gamma_ready(ln_gamma_ready),.gamma_bits,
    .row_valid(ln_row_valid),
    .rd_valid(state==A_REQ),.rd_ready(ln_rd_ready),.rd_group(group_no),
    .rsp_valid(ln_rsp_valid),.rsp_ready(state==A_WAIT),
    .rsp_group(ln_rsp_group),.rsp_q8(ln_rsp_q),.rsp_scale(ln_rsp_scale),
    .row_release_valid(state==A_RELEASE),.row_release_ready(ln_release_ready),
    .done_valid(ln_done_valid),
    .done_ready(((state==LN_WAIT || state==QD_WAIT) &&
                  ln_done_status!=0) || state==A_DONE),
    .done_status(ln_done_status),.done_bad_element(ln_done_bad),
    .mean_bits(ln_mean),.variance_bits(ln_variance),.inverse_bits(ln_inverse));

  t4_dual_w_cache_v1 w_cache (
    .clk,.rst_n,.load_cancel(1'b0),
    .load_valid(state==LOAD_REQ),.load_ready,.load_slot(active_slot),
    .load_epoch(active_epoch),.load_k(active_slot ? 32'd2624 : 32'd1024),
    .load_n(active_slot ? 32'd1024 : 32'd5248),
    .load_weight_key(active_key),.load_model_identity(model_id),
    .load_expected_aux_header(active_slot ? down_aux_header : aux_header),
    .load_base(active_slot ? down_load_base : load_base),
    .load_bytes(active_slot ? down_load_bytes : load_bytes),
    .load_aux_base(active_slot ? down_aux_base : aux_base),
    .load_bias_base(active_slot ? down_bias_base : bias_base),
    .load_bias_bytes(active_slot ? down_bias_bytes : bias_bytes),
    .load_done,.load_error,.load_reject,.load_scale_checks,.load_bad_element,
    .slot_state,.slot_epoch,.slot_readers,.slot_coverage,.commit_ready(4'hf),
    .araddr,.arlen,.arsize,.arburst,.arvalid,.arready,
    .rdata,.rresp,.rlast,.rvalid,.rready,
    .aux_araddr,.aux_arlen,.aux_arsize,.aux_arburst,.aux_arvalid,.aux_arready,
    .aux_rdata,.aux_rresp,.aux_rlast,.aux_rvalid,.aux_rready,
    .lease_valid(state==LEASE_REQ),.lease_ready,.lease_done,.lease_error,
    .lease_slot(active_slot),.lease_epoch(active_epoch),
    .lease_k(phase_down ? 32'd2624 : 32'd1024),
    .lease_n(phase_down ? 32'd1024 : 32'd5248),
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
    .release_numeric_identity(numeric_id),.release_task_context(task_context));

  tm4tn8_sync_ps_front_v2 front (
    .clk,.rst_n,.config_valid(state==FRONT_CFG),.config_ready(front_cfg_ready),
    .config_k(phase_down ? 16'd2624 : 16'd1024),
    .config_n(phase_down ? 16'd1024 : 16'd5248),
    .config_rows(3'd1),.config_row0(16'd0),
    .config_identity({front_issue_identity,64'd0}),
    .issue_valid(state==ISSUE),.issue_ready(front_issue_ready),
    .issue_identity(front_issue_identity),.issue_version(4'd1),
    .issue_sequence(27'(32'(group_no)*(phase_down ? 32'd128 : 32'd656)+32'(tile_no))),
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
    .clk,.rst_n,.in_valid(add_accept),.in_ready(add_in_ready),
    .a(res_a_hold),.b(res_b_hold),
    .out_valid(add_out_valid),.out_ready(state==RES_WAIT || state==RES_DRAIN),
    .bits(add_bits));

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE; id<=0;w_epoch<=0;down_epoch<=0;
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
      g_tile<=0;g_lane<=0;g_x_hold<=0;g_gate_hold<=0;
      g_issued<=0;g_returned<=0;g_credits<=0;g_cover<=0;
      g_fault<=0;g_bad<=32'hffffffff;qd_index<=0;qd_word<=0;
      skip_count<=0;res_index<=0;res_issued<=0;res_consumed<=0;
      res_written<=0;res_a_hold<=0;res_b_hold<=0;res_ordinal<=0;
      res_fault<=0;
      rsp_valid<=0;rsp_tile<=0;rsp_bits<=0;read_addr<=0;read_pending<=0;
      done_status<=0;done_phase<=4'd7;
      done_bad_element<=32'hffffffff;
      actual_w_reads<=0;actual_w_returns<=0;
      actual_stripes<=0;actual_ps_commits<=0;
      saved_mean<=0;saved_variance<=0;saved_inverse<=0;
    end else begin
      if(state==LN_WAIT && x_valid && x_ready)begin
        if(skip_count<11'd1024)begin
          skip_bank[skip_count[9:0]]<=x_bits;
          skip_count<=skip_count+1'b1;
        end else begin
          local_fault<=1;
          done_status<=4'd7;done_phase<=4'd2;
          done_bad_element<=32'hffffffff;
        end
      end
      if(rsp_valid && rsp_ready)rsp_valid<=0;
      if(read_pending)begin
        for(int lane=0;lane<8;lane++)
          rsp_bits[lane*32+:32]<=final_bank[lane][read_addr];
        rsp_tile<=read_addr;rsp_valid<=1;read_pending<=0;
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
          if(commit_bad[7:0]==0)
            for(int lane=0;lane<8;lane++)
              final_bank[lane][commit_tile[9:0]]<=commit_next_ps[lane*32+:32];
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
            final_bank[g_returned[2:0]][g_returned[11:3]]<=g_data;
          end
        end
      end
      if(state==W_REQ && w_read_ready)begin w_pending<=1;actual_w_reads<=actual_w_reads+1;end
      if((state==W_WAIT || state==DRAIN) && (ret_valid || w_read_error))begin
        w_pending<=0;
        if(ret_valid)actual_w_returns<=actual_w_returns+1;
      end
      case(state)
        IDLE:if(cmd_valid)begin
          id<=cmd_id;w_epoch<=cmd_w_epoch;weight_key<=cmd_weight_key;
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
          res_written<=0;res_a_hold<=0;res_b_hold<=0;res_ordinal<=0;
          res_fault<=0;
          local_fault<=0;done_status<=0;done_phase<=4'd7;
          done_bad_element<=32'hffffffff;
          actual_w_reads<=0;actual_w_returns<=0;actual_stripes<=0;actual_ps_commits<=0;
          rsp_valid<=0;read_pending<=0;
          saved_mean<=0;saved_variance<=0;saved_inverse<=0;
          if(cmd_id==0 || cmd_w_epoch==0 || cmd_down_w_epoch==0 ||
             cmd_task_context[31:0]==0)begin
            done_status<=4'd7;state<=DONE;
          end else state<=cmd_cold ? LOAD_REQ : LN_CMD;
        end
        LOAD_REQ:if(load_ready)state<=LOAD_WAIT;
        LOAD_WAIT:if(load_done)begin
          if(load_error || load_reject)begin
            done_status<=4'd7;done_phase<=active_slot ? 4'd1 : 4'd0;
            done_bad_element<=load_bad_element;state<=DONE;
          end else if(!active_slot)begin
            active_slot<=1;state<=LOAD_REQ;
          end else begin
            active_slot<=0;state<=LN_CMD;
          end
        end
        LN_CMD:if(ln_cmd_ready)state<=LN_WAIT;
        LN_WAIT:begin
          if(ln_row_valid)begin
            have_a_row<=1;state<=local_fault ? A_RELEASE : LEASE_REQ;
            saved_mean<=ln_mean;saved_variance<=ln_variance;saved_inverse<=ln_inverse;
          end
          else if(ln_done_valid && ln_done_status!=0)begin
            done_status<=ln_done_status;done_phase<=4'd2;
            done_bad_element<=ln_done_bad;state<=DONE;
          end
        end
        LEASE_REQ:if(lease_ready)state<=LEASE_WAIT;
        LEASE_WAIT:if(lease_done)begin
          if(lease_error)begin
            done_status<=4'd7;done_phase<=phase_down ? 4'd6 : 4'd3;
            state<=A_RELEASE;
          end
          else begin have_w_lease<=1;state<=FRONT_CFG;end
        end
        FRONT_CFG:if(front_cfg_ready)state<=A_REQ;
        A_REQ:if(front_protocol)begin
          local_fault<=1;done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
        end
          else if(ln_rd_ready)state<=A_WAIT;
        A_WAIT:if(front_protocol)begin
          local_fault<=1;done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
        end
          else if(ln_rsp_valid)begin
          if(ln_rsp_group!=group_no)begin
            local_fault<=1;done_status<=4'd7;
            done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
          end else begin
            a_q<=ln_rsp_q;a_scale<=half_to_f32(ln_rsp_scale);
            tile_no<=0;state<=W_REQ;
          end
        end
        W_REQ:if(front_protocol)begin
          local_fault<=1;done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
        end
          else if(w_read_ready)state<=W_WAIT;
        W_WAIT:begin
          if(front_protocol || w_read_error || (ret_valid && !ret_ok))begin
            local_fault<=1;done_status<=4'd7;
            done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
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
          local_fault<=1;done_phase<=phase_down ? 4'd6 : 4'd3;state<=DRAIN;
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
          if(local_fault || front_protocol || front_accepted!=expected_stripes ||
             stage_stripes!=expected_stripes)begin
            done_status<=4'd7;done_phase<=phase_down ? 4'd6 : 4'd3;
          end else if(front_error || front_first_rank!='1)begin
            done_status<=4'd6;done_phase<=phase_down ? 4'd6 : 4'd3;
            done_bad_element<=front_bad;
          end else if(final_duplicate ||
                      final_count!=(phase_down ? 10'd128 : 10'd656) ||
                      (phase_down ? !(&final_cover[127:0]) : !(&final_cover)))begin
            done_status<=4'd7;done_phase<=phase_down ? 4'd6 : 4'd3;
            final_missing<=1;
          end
          state<=W_RELEASE_REQ;
        end
        W_RELEASE_REQ:if(release_ready)state<=W_RELEASE_WAIT;
        W_RELEASE_WAIT:if(release_done)begin
          if(release_error)begin
            done_status<=4'd7;done_phase<=phase_down ? 4'd6 : 4'd3;
          end
          have_w_lease<=0;state<=A_RELEASE;
        end
        A_RELEASE:if(!have_a_row)state<=DONE;
          else if(ln_release_ready)state<=A_DONE;
        A_DONE:if(ln_done_valid)begin
          have_a_row<=0;
          if(ln_done_status!=0)begin
            done_status<=ln_done_status;
            done_phase<=phase_down ? 4'd5 : 4'd2;
            done_bad_element<=ln_done_bad;state<=DONE;
          end else if(done_status!=0)state<=DONE;
          else if(phase_down)state<=RES_INIT;
          else begin
            g_tile<=0;g_lane<=0;g_issued<=0;g_returned<=0;
            g_credits<=0;g_cover<=0;g_fault<=0;
            state<=G_R0;
          end
        end
        G_R0:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else if(!(g_commit && g_returned[11:3]==g_tile))begin
            for(int lane=0;lane<8;lane++)
              g_x_hold[lane*32+:32]<=final_bank[lane][g_tile];
            state<=G_R1;
          end
        G_R1:if(g_fault || g_commit_bad)state<=G_DRAIN;
          else begin
            for(int lane=0;lane<8;lane++)
              g_gate_hold[lane*32+:32]<=final_bank[lane][g_gate_tile];
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
          qd_word<=final_bank[qd_index[2:0]][qd_index[11:3]];
          state<=QD_SEND;
        end
        QD_SEND:if(ln_x_ready)begin
          qd_index<=qd_index+1'b1;
          state<=qd_index==12'd2623 ? QD_WAIT : QD_READ;
        end
        QD_WAIT:begin
          if(ln_row_valid)begin
            have_a_row<=1;active_slot<=1;phase_down<=1;
            front_issue_identity<={task_context[31:0],id,down_epoch};
            group_no<=0;tile_no<=0;stage_stripes<=0;
            final_cover<=0;final_count<=0;
            final_duplicate<=0;final_missing<=0;local_fault<=0;
            state<=LEASE_REQ;
          end else if(ln_done_valid && ln_done_status!=0)begin
            done_status<=ln_done_status;done_phase<=4'd5;
            done_bad_element<=ln_done_bad;state<=DONE;
          end
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
            res_b_hold<=final_bank[res_index[2:0]][res_index[9:3]];
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
            final_bank[res_consumed[2:0]][res_consumed[9:3]]<=add_bits;
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
          if(rd_valid && rd_tile>DOWN_LAST_TILE && !row_release_valid &&
             !rsp_valid && !read_pending)begin
            done_status<=4'd7;done_phase<=4'd7;
            done_bad_element<=32'hffffffff;state<=DONE;
          end else if(row_release_valid && row_release_ready)state<=DONE;
          else if(rd_valid && rd_ready)begin read_addr<=rd_tile;read_pending<=1;end
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
    if(state==ROW)
      assert(phase_down && done_status==0 && final_count==10'd128 &&
             &final_cover[127:0] && skip_count==11'd1024 &&
             res_index==11'd1024 && res_issued==11'd1024 &&
             res_consumed==11'd1024 && res_written==11'd1024 &&
             !add_out_valid)
        else $fatal(1,"Residual visible incomplete row");
  end
`endif
endmodule
