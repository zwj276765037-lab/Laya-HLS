`timescale 1ns/1ps

// Fixed MATRIX16 executor. The frontend is the same physical four-row
// arithmetic service used by the parent; A and PS use the one LNQ bank link.
// W ports attach to the existing single laya_w_prep_service_v1.
module laya_matrix_service_v1 (
  input logic clk,rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic [6:0] cmd_window_row0,
  input logic [31:0] cmd_source_epoch,cmd_a_epoch,cmd_w_epoch,
  input logic [15:0] cmd_w_key,
  input logic [3327:0] cmd_model,
  input logic [671:0] cmd_numeric,
  input logic [95:0] cmd_task_context,
  output logic done_valid,
  input logic done_ready,
  output logic [31:0] done_id,
  output logic [6:0] done_window_row0,
  output logic [31:0] done_source_epoch,done_a_epoch,done_w_epoch,
  output logic [3:0] done_status,
  output logic [7:0] done_op,
  output logic [15:0] done_check_status,
  output logic [31:0] done_detail,
  output logic [63:0] done_bad64,
  output logic ps_tile_valid,
  output logic [9:0] ps_tile,
  output logic [6:0] ps_window_row0,
  output logic [31:0] ps_a_epoch,ps_source_epoch,
  output logic ps_tile_discard,
  input logic ps_retire_valid,ps_retire_error,
  output logic ps_retire_ready,
  output logic [31:0] actual_a_reads,actual_a_returns,
  output logic [31:0] actual_w_reads,actual_w_returns,
  output logic [31:0] actual_stripes,actual_row_retired,
  output logic [31:0] actual_terminal,actual_ps_retired,
  output logic w_lease_valid,
  input logic w_lease_ready,w_lease_done,w_lease_error,
  output logic w_lease_slot,
  output logic [31:0] w_lease_epoch,w_lease_k,w_lease_n,
  output logic [15:0] w_lease_weight_key,
  output logic [3327:0] w_lease_model_identity,
  output logic [671:0] w_lease_numeric_identity,
  output logic [95:0] w_lease_task_context,
  output logic w_read_valid,
  input logic w_read_ready,w_read_error,
  output logic w_read_slot,
  output logic [31:0] w_read_epoch,
  output logic [15:0] w_read_tile,
  output logic [7:0] w_read_group,
  output logic w_read_pair,
  output logic [3327:0] w_read_model_identity,
  output logic [671:0] w_read_numeric_identity,
  output logic [95:0] w_read_task_context,
  input logic w_ret_valid,
  output logic w_ret_ready,
  input logic w_ret_slot,w_ret_pair,
  input logic [31:0] w_ret_epoch,
  input logic [15:0] w_ret_tile,
  input logic [7:0] w_ret_group,
  input logic [3327:0] w_ret_model_identity,
  input logic [671:0] w_ret_numeric_identity,
  input logic [95:0] w_ret_task_context,
  input logic [1:0][7:0][255:0] w_ret_q,
  input logic [1:0][7:0][15:0] w_ret_scale,
  input logic [1:0][7:0] w_ret_mask,
  output logic w_release_valid,
  input logic w_release_ready,w_release_done,w_release_error,
  output logic w_release_slot,
  output logic [31:0] w_release_epoch,
  output logic [671:0] w_release_numeric_identity,
  output logic [95:0] w_release_task_context,
  laya_lnq_bank_link_v1 bank_link
);
  typedef enum logic [4:0] {
    M_IDLE,M_CLAIM,M_LEASE,M_LEASE_WAIT,M_CFG,M_STEP,
    M_A_REQ,M_A_WAIT,M_W_REQ,M_W_WAIT,M_ISSUE,M_STEP_WAIT,
    M_TILE_HELD,M_FULL_DRAIN,M_ABORT_DRAIN,M_W_RELEASE,
    M_W_RELEASE_WAIT,M_A_RELEASE,M_DONE
  } state_t;
  state_t state;
  logic [31:0] id,source_epoch,a_epoch,w_epoch;
  logic [6:0] window_row0;
  logic [15:0] w_key;
  logic [3327:0] model;
  logic [671:0] numeric;
  logic [95:0] task_context;
  logic [9:0] tile;
  logic [1:0] block,terminal_ptr;
  logic [5:0] group;
  logic [2:0] a_index;
  logic [1023:0] a_q;
  logic [127:0] a_scale;
  logic [2047:0] w_q;
  logic [255:0] w_scale;
  logic have_a,have_w,protocol_fault,numeric_fault,store_fault;
  logic [63:0] numeric_rank;
  logic [31:0] numeric_bad;
  logic front_cfg_ready,front_issue_ready,front_abort_ready;
  logic front_step_ready,front_step_done_valid;
  logic [9:0] front_step_tile;
  logic [1:0] front_step_block;
  logic [5:0] front_step_accepted;
  logic [7:0] front_step_row_retired;
  logic [2:0] front_step_terminal;
  logic front_step_error,front_step_protocol;
  logic [63:0] front_step_rank;
  logic [31:0] front_step_bad;
  logic [3:0] commit_valid,commit_ready,final_skip_valid,final_skip_ready;
  logic [767:0] commit_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_mask,commit_bad;
  logic [95:0] commit_phase;
  logic [1023:0] commit_ps;
  logic [9:0] final_skip_tile;
  logic [7:0] final_skip_mask;
  logic [23:0] result_free,result_reserved,result_returned;
  logic [11:0] trace_free;
  logic front_done,front_error,front_protocol;
  logic [63:0] front_rank;
  logic [31:0] front_bad;
  logic [26:0] front_accepted;

  function automatic logic [31:0] half_to_f32(input logic [15:0] h);
    logic [4:0] e;logic [9:0] f;integer shift;
    e=h[14:10];f=h[9:0];shift=0;
    if(e==0)begin
      if(f==0)return {h[15],31'd0};
      while(!f[9])begin f=f<<1;shift=shift+1;end
      return {h[15],8'(112-shift),f[8:0],14'd0};
    end
    if(e==31)return {h[15],8'hff,h[9:0],13'd0};
    return {h[15],8'(int'(e)+112),h[9:0],13'd0};
  endfunction

  wire [3:0] local_row={block,a_index[2:1]};
  wire a_is_scale=a_index[0];
  wire [9:0] a_word_addr=10'(34*int'(local_row)+
      (a_is_scale ? 32+int'(group[4]) : int'(group)));
  wire [9:0] a_tag={a_is_scale,local_row,group[4:0]};
  wire [95:0] front_identity={task_context[31:0],id,w_epoch};
  wire w_return_ok=!w_ret_slot && !w_ret_pair &&
      w_ret_epoch==w_epoch && w_ret_tile==16'(tile) &&
      w_ret_group==8'(group) && w_ret_model_identity==model &&
      w_ret_numeric_identity==numeric &&
      w_ret_task_context==task_context && w_ret_mask[0]==8'hff;
  wire [3:0] terminal_commit;
  wire [3:0] terminal_skip;
  for(genvar p=0;p<4;p++)begin:terminal_select
    wire is_last=commit_valid[p] &&
        {commit_tag[p*192+160],commit_tag[p*192+11+:6]}==7'd31;
    assign commit_ready[p]=is_last ?
        (terminal_ptr==2'(p) &&
         !bank_link.result_pending && !bank_link.result_rsp_valid) : 1'b1;
    assign final_skip_ready[p]=terminal_ptr==2'(p) &&
         !bank_link.result_pending && !bank_link.result_rsp_valid;
    assign terminal_commit[p]=is_last && commit_ready[p];
    assign terminal_skip[p]=final_skip_valid[p] && final_skip_ready[p];
  end
  logic [1:0] selected_terminal;
  always_comb begin
    selected_terminal=terminal_ptr;
    bank_link.matrix_ps_store_valid=0;
    bank_link.matrix_ps_store_tile=10'd544+10'(block)*10'd4+
        10'(selected_terminal);
    bank_link.matrix_ps_store_bits=commit_ps[selected_terminal*256+:256];
    for(int p=0;p<4;p++)if(terminal_commit[p] &&
        (commit_mask[p*8+:8] | commit_bad[p*8+:8])==8'hff &&
        commit_bad[p*8+:8]==0)
      bank_link.matrix_ps_store_valid=1;
  end
  wire terminal_advance=(|terminal_commit) || (|terminal_skip);

  assign cmd_ready=state==M_IDLE;
  assign done_valid=state==M_DONE;
  assign done_id=id;
  assign done_window_row0=window_row0;
  assign done_source_epoch=source_epoch;
  assign done_a_epoch=a_epoch;
  assign done_w_epoch=w_epoch;
  assign done_op=8'h30;
  assign done_check_status={12'd0,done_status};
  assign done_detail=done_status==4'd6 ? 32'h0730_000f :
      done_status==4'd7 ? 32'h0730_0005 : 32'd0;
  assign done_bad64=done_status==4'd6 ? 64'(numeric_bad) :
      64'hffff_ffff_ffff_ffff;
  assign ps_tile_valid=state==M_TILE_HELD;
  assign ps_tile=tile;
  assign ps_window_row0=window_row0;
  assign ps_a_epoch=a_epoch;
  assign ps_source_epoch=source_epoch;
  assign ps_tile_discard=store_fault;
  assign ps_retire_ready=state==M_TILE_HELD;

  assign bank_link.a_claim_valid=state==M_CLAIM;
  assign bank_link.a_claim_id=id;
  assign bank_link.a_claim_base=window_row0;
  assign bank_link.a_claim_epoch=a_epoch;
  assign bank_link.a_claim_source_epoch=source_epoch;
  assign bank_link.a_claim_model=model;
  assign bank_link.a_claim_numeric=numeric;
  assign bank_link.matrix_result_accept=state==M_A_REQ &&
      bank_link.matrix_result_ready;
  assign bank_link.matrix_result_physical_addr=a_word_addr;
  assign bank_link.matrix_result_logical_tile=a_tag;
  assign bank_link.matrix_result_rsp_ready=state==M_A_WAIT;
  assign bank_link.matrix_a_release_valid=state==M_A_RELEASE && have_a;
  assign bank_link.matrix_a_release_discard=done_status!=0;

  assign w_lease_valid=state==M_LEASE;
  assign w_lease_slot=1'b0;
  assign w_lease_epoch=w_epoch;
  assign w_lease_k=32'd1024;
  assign w_lease_n=32'd3072;
  assign w_lease_weight_key=w_key;
  assign w_lease_model_identity=model;
  assign w_lease_numeric_identity=numeric;
  assign w_lease_task_context=task_context;
  assign w_read_valid=state==M_W_REQ;
  assign w_read_slot=1'b0;
  assign w_read_epoch=w_epoch;
  assign w_read_tile=16'(tile);
  assign w_read_group=8'(group);
  assign w_read_pair=1'b0;
  assign w_read_model_identity=model;
  assign w_read_numeric_identity=numeric;
  assign w_read_task_context=task_context;
  assign w_ret_ready=state==M_W_WAIT || state==M_ABORT_DRAIN;
  assign w_release_valid=state==M_W_RELEASE && have_w;
  assign w_release_slot=1'b0;
  assign w_release_epoch=w_epoch;
  assign w_release_numeric_identity=numeric;
  assign w_release_task_context=task_context;

  tm4tn8_sync_ps_front_v2 front (
    .clk,.rst_n,.config_valid(state==M_CFG),.config_ready(front_cfg_ready),
    .config_k(16'd1024),.config_n(16'd3072),.config_rows(5'd16),
    .config_step16(1'b1),.config_row0({9'd0,window_row0}),
    .config_identity({front_identity,64'd0}),
    .issue_valid(state==M_ISSUE),.issue_ready(front_issue_ready),
    .issue_identity(front_identity),.issue_version(4'd1),
    .issue_sequence(27'((32'(tile)*32'd4+32'(block))*32'd32+
                         32'(group))),
    .issue_group({1'b0,group}),.issue_tile(tile),.issue_block(block),
    .issue_lane_mask(8'hff),.issue_trace_mask(4'd0),
    .issue_trace_lane(12'd0),.issue_a8(a_q),.issue_sa(a_scale),
    .issue_w8(w_q),.issue_sw(w_scale),
    .abort_valid(state==M_ABORT_DRAIN),.abort_ready(front_abort_ready),
    .commit_valid,.commit_ready,.commit_tag,.commit_tile,
    .commit_lane_mask(commit_mask),.commit_bad_mask(commit_bad),
    .commit_phase,.commit_next_ps(commit_ps),
    .final_skip_valid,.final_skip_ready,.final_skip_tile,.final_skip_mask,
    .trace_valid(),.trace_ready(4'd0),.trace_slot(),.trace_tag(),
    .trace_payload(),.trace_ack_valid(4'd0),.trace_ack_slot(8'd0),
    .trace_ack_tag(768'd0),.trace_ack_ok(4'hf),
    .result_free,.result_reserved,.result_returned,.trace_free,
    .done_valid(front_done),.done_error(front_error),
    .protocol_failure(front_protocol),.first_error_rank(front_rank),
    .first_bad_element(front_bad),.accepted_stripes(front_accepted),
    .step_valid(state==M_STEP),.step_ready(front_step_ready),
    .step_tile(tile),.step_block(block),
    .step_done_valid(front_step_done_valid),
    .step_done_ready(state==M_STEP_WAIT &&
        !bank_link.result_pending && !bank_link.result_rsp_valid &&
        !w_ret_valid),
    .step_done_tile(front_step_tile),.step_done_block(front_step_block),
    .step_done_accepted(front_step_accepted),
    .step_done_row_retired(front_step_row_retired),
    .step_done_terminal(front_step_terminal),
    .step_done_error(front_step_error),
    .step_done_protocol(front_step_protocol),
    .step_done_first_rank(front_step_rank),.step_done_bad(front_step_bad));

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=M_IDLE;id<=0;window_row0<=0;source_epoch<=0;
      a_epoch<=0;w_epoch<=0;w_key<=0;model<=0;numeric<=0;
      task_context<=0;tile<=0;block<=0;group<=0;a_index<=0;
      a_q<=0;a_scale<=0;w_q<=0;w_scale<=0;terminal_ptr<=0;
      have_a<=0;have_w<=0;protocol_fault<=0;numeric_fault<=0;
      store_fault<=0;numeric_rank<='1;numeric_bad<='1;
      done_status<=0;actual_a_reads<=0;actual_a_returns<=0;
      actual_w_reads<=0;actual_w_returns<=0;actual_stripes<=0;
      actual_row_retired<=0;actual_terminal<=0;actual_ps_retired<=0;
    end else begin
      if(terminal_advance)terminal_ptr<=terminal_ptr+1'b1;
      case(state)
        M_IDLE:if(cmd_valid && cmd_ready)begin
          id<=cmd_id;window_row0<=cmd_window_row0;
          source_epoch<=cmd_source_epoch;a_epoch<=cmd_a_epoch;
          w_epoch<=cmd_w_epoch;w_key<=cmd_w_key;
          model<=cmd_model;numeric<=cmd_numeric;
          task_context<=cmd_task_context;
          tile<=0;block<=0;group<=0;a_index<=0;
          have_a<=0;have_w<=0;protocol_fault<=0;
          numeric_fault<=0;store_fault<=0;
          numeric_rank<='1;numeric_bad<='1;done_status<=0;
          actual_a_reads<=0;actual_a_returns<=0;
          actual_w_reads<=0;actual_w_returns<=0;
          actual_stripes<=0;actual_row_retired<=0;
          actual_terminal<=0;actual_ps_retired<=0;
          if(cmd_id==0 || cmd_window_row0[3:0]!=0 ||
             cmd_window_row0>7'd112 || cmd_source_epoch==0 ||
             cmd_a_epoch==0 || cmd_w_epoch==0 ||
             cmd_w_key!=16'h0001 ||
             cmd_task_context[95:88]!=8'd16)begin
            done_status<=4'd7;state<=M_DONE;
          end else state<=M_CLAIM;
        end
        M_CLAIM:if(bank_link.a_claim_ready)begin
          if(bank_link.a_claim_error)begin
            done_status<=4'd7;protocol_fault<=1;have_a<=1;
            state<=M_A_RELEASE;
          end else begin have_a<=1;state<=M_LEASE;end
        end
        M_LEASE:if(w_lease_ready)state<=M_LEASE_WAIT;
        M_LEASE_WAIT:if(w_lease_done)begin
          if(w_lease_error)begin
            done_status<=4'd7;protocol_fault<=1;state<=M_A_RELEASE;
          end else begin have_w<=1;state<=M_CFG;end
        end
        M_CFG:if(front_cfg_ready)state<=M_STEP;
        M_STEP:if(front_step_ready)begin
          terminal_ptr<=0;group<=0;a_index<=0;state<=M_A_REQ;
        end
        M_A_REQ:if(bank_link.matrix_result_accept)begin
          actual_a_reads<=actual_a_reads+1'b1;state<=M_A_WAIT;
        end
        M_A_WAIT:if(bank_link.result_rsp_valid)begin
          if(bank_link.result_rsp_tile!=a_tag)begin
            done_status<=4'd7;protocol_fault<=1;state<=M_ABORT_DRAIN;
          end else begin
            actual_a_returns<=actual_a_returns+1'b1;
            if(a_is_scale)
              a_scale[a_index[2:1]*32+:32]<=half_to_f32(
                bank_link.result_rsp_bits[((group[3:1])*32)+
                                          (group[0]*16)+:16]);
            else a_q[a_index[2:1]*256+:256]<=bank_link.result_rsp_bits;
            if(a_index==3'd7)state<=M_W_REQ;
            else begin a_index<=a_index+1'b1;state<=M_A_REQ;end
          end
        end
        M_W_REQ:if(w_read_error)begin
          done_status<=4'd7;protocol_fault<=1;state<=M_ABORT_DRAIN;
        end else if(w_read_ready)begin
          actual_w_reads<=actual_w_reads+1'b1;state<=M_W_WAIT;
        end
        M_W_WAIT:if(w_read_error || (w_ret_valid && !w_return_ok))begin
          done_status<=4'd7;protocol_fault<=1;state<=M_ABORT_DRAIN;
        end else if(w_ret_valid)begin
          actual_w_returns<=actual_w_returns+1'b1;
          w_q<=w_ret_q[0];
          for(int lane=0;lane<8;lane++)
            w_scale[lane*32+:32]<=half_to_f32(w_ret_scale[0][lane]);
          state<=M_ISSUE;
        end
        M_ISSUE:if(front_protocol)begin
          done_status<=4'd7;protocol_fault<=1;state<=M_ABORT_DRAIN;
        end else if(front_issue_ready)begin
          actual_stripes<=actual_stripes+1'b1;
          if(group==6'd31)state<=M_STEP_WAIT;
          else begin group<=group+1'b1;a_index<=0;state<=M_A_REQ;end
        end
        M_STEP_WAIT:if(front_step_done_valid &&
            !bank_link.result_pending && !bank_link.result_rsp_valid &&
            !w_ret_valid)begin
          actual_row_retired<=actual_row_retired+
              32'(front_step_row_retired);
          actual_terminal<=actual_terminal+32'(front_step_terminal);
          if(front_step_tile!=tile || front_step_block!=block ||
             front_step_accepted!=6'd32 ||
             front_step_row_retired!=8'd128 ||
             front_step_terminal!=3'd4 || front_step_protocol)begin
            done_status<=4'd7;protocol_fault<=1;state<=M_ABORT_DRAIN;
          end else begin
            if(front_step_rank<numeric_rank)begin
              numeric_rank<=front_step_rank;
              numeric_bad<=front_step_bad;
            end
            if(front_step_error)numeric_fault<=1;
            if(block==2'd3)begin
              if(numeric_fault || front_step_error)begin
                done_status<=4'd6;state<=M_W_RELEASE;
              end else state<=M_TILE_HELD;
            end else begin block<=block+1'b1;state<=M_STEP;end
          end
        end
        M_TILE_HELD:if(ps_retire_valid && ps_retire_ready)begin
          actual_ps_retired<=actual_ps_retired+1'b1;
          if(ps_retire_error)store_fault<=1;
          if(tile==10'd383)state<=M_FULL_DRAIN;
          else begin tile<=tile+1'b1;block<=0;state<=M_STEP;end
        end
        M_FULL_DRAIN:if(front_done && !w_ret_valid &&
            !bank_link.result_pending && !bank_link.result_rsp_valid)begin
          if(front_protocol || front_error && front_rank=='1 ||
             front_accepted!=27'd49152 ||
             actual_stripes!=32'd49152 ||
             actual_ps_retired!=32'd384)begin
            done_status<=4'd7;protocol_fault<=1;
          end else if(store_fault)done_status<=4'd7;
          state<=M_W_RELEASE;
        end
        M_ABORT_DRAIN:if(front_done && !w_ret_valid &&
            !bank_link.result_pending && !bank_link.result_rsp_valid)
          state<=M_W_RELEASE;
        M_W_RELEASE:if(!have_w)state<=M_A_RELEASE;
          else if(w_release_ready)state<=M_W_RELEASE_WAIT;
        M_W_RELEASE_WAIT:if(w_release_done)begin
          if(w_release_error)begin done_status<=4'd7;protocol_fault<=1;end
          have_w<=0;state<=M_A_RELEASE;
        end
        M_A_RELEASE:if(!have_a)state<=M_DONE;
          else if(bank_link.a_window_release_ready)begin
            have_a<=0;state<=M_DONE;
          end
        M_DONE:if(done_ready)state<=M_IDLE;
        default:state<=M_IDLE;
      endcase
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(bank_link.matrix_ps_store_valid &&
             bank_link.matrix_result_accept))
      else $fatal(1,"matrix PS write/read conflict");
    if(ps_tile_valid)assert(actual_stripes==
        (32'(tile)+32'd1)*32'd128)
      else $fatal(1,"matrix tile published before four STEP16 blocks");
  end
`endif
endmodule
