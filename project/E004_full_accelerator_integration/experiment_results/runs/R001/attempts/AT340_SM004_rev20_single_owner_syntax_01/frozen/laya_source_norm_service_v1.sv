`timescale 1ns/1ps

// Fixed shared source/AUX readers and output writer. These are the original
// production engines; the surrounding request FSM grants each fixed client
// and holds its selected route until the engine's real debt retires.
module laya_source_norm_service_v1 (
  input logic clk, rst_n,
  laya_lnq_bank_link_v1 bank_link,
  input logic reader_cancel,
  // Fixed staged source/gamma preload client. The accepted row identity and
  // both AXI addresses are retained here until the real loads and prep debt
  // retire. Legacy and RoPE clients continue through the ports below.
  input logic stage_input_start,
  output logic stage_input_ready,
  input logic stage_input_staged,
  input logic stage_input_first,
  input logic [31:0] stage_input_id, stage_input_epoch,
  input logic [6:0] stage_input_row,
  input logic [3327:0] stage_input_model,
  input logic [671:0] stage_input_numeric,
  input logic [63:0] stage_input_source_addr,
  input logic [63:0] stage_input_source_span,
  input logic [63:0] stage_input_aux_base, stage_input_aux_span,
  input logic [63:0] stage_input_dest_base, stage_input_dest_span,
  output logic stage_input_done_valid,
  input logic stage_input_done_ready,
  output logic [3:0] stage_input_done_status,
  output logic [3:0] stage_done_phase,
  output logic [31:0] stage_done_id,
  output logic [6:0] stage_done_row,
  output logic [31:0] stage_done_bad,
  output logic [7:0] stage_done_op,
  output logic [15:0] stage_done_check_status,
  output logic [31:0] stage_done_detail,
  output logic [63:0] stage_done_bad64,
  output logic [7:0] stage_retired_rows,
  // Staged norm view and writeback. The wrapper only carries the fixed
  // lower-bank request/response signals; this service owns the read/write
  // sequence, flush barrier, and release decision.
  input logic stage_store_start,
  input logic [6:0] stage_store_row,
  input logic [63:0] stage_store_base, stage_store_span,
  input logic stage_store_discard,
  input logic stage_store_identity_bad,
  output logic stage_store_rd_valid,
  input logic stage_store_rd_ready,
  output logic [9:0] stage_store_rd_tile,
  input logic stage_store_rsp_valid,
  output logic stage_store_rsp_ready,
  input logic [9:0] stage_store_rsp_tile,
  input logic [255:0] stage_store_rsp_bits,
  output logic stage_store_release_valid,
  output logic stage_store_release_discard,
  input logic stage_store_release_ready,
  output logic stage_store_done_valid,
  input logic stage_store_done_ready,
  output logic stage_store_error,
  input logic scratch_reader_load_valid,
  output logic scratch_reader_load_ready,
  input logic [63:0] scratch_reader_load_base,
  input logic [31:0] scratch_reader_load_bytes,
  input logic [31:0] scratch_reader_load_epoch,
  output logic scratch_reader_done, scratch_reader_error,
  output logic [31:0] scratch_reader_bytes,
  output logic [63:0] scratch_reader_araddr,
  output logic [7:0] scratch_reader_arlen,
  output logic [2:0] scratch_reader_arsize,
  output logic [1:0] scratch_reader_arburst,
  output logic scratch_reader_arvalid,
  output logic scratch_reader_rready,
  input logic source_load_active,
  input logic [1:0] rope_route,
  output logic [63:0] state0_araddr,
  output logic [7:0] state0_arlen,
  output logic [2:0] state0_arsize,
  output logic [1:0] state0_arburst,
  output logic state0_arvalid,
  input logic state0_arready,
  input logic [511:0] state0_rdata,
  input logic [1:0] state0_rresp,
  input logic state0_rlast, state0_rvalid,
  output logic state0_rready,
  output logic [1:0][63:0] rope_araddr,
  output logic [1:0][7:0] rope_arlen,
  output logic [1:0][2:0] rope_arsize,
  output logic [1:0][1:0] rope_arburst,
  output logic [1:0] rope_arvalid,
  input logic [1:0] rope_arready,
  input logic [1:0][511:0] rope_rdata,
  input logic [1:0][1:0] rope_rresp,
  input logic [1:0] rope_rlast, rope_rvalid,
  output logic [1:0] rope_rready,
  output logic [511:0] scratch_reader_out_data,
  output logic [31:0] scratch_reader_offset, scratch_reader_epoch,
  output logic [6:0] scratch_reader_out_bytes,
  output logic scratch_reader_last, scratch_reader_out_valid,
  input logic scratch_reader_out_ready,

  input logic table_reader_load_valid,
  output logic table_reader_load_ready,
  input logic [63:0] table_reader_load_base,
  input logic [31:0] table_reader_load_bytes,
  input logic [31:0] table_reader_load_epoch,
  output logic table_reader_done, table_reader_error,
  output logic [31:0] table_reader_bytes,
  output logic [63:0] table_reader_araddr,
  output logic [7:0] table_reader_arlen,
  output logic [2:0] table_reader_arsize,
  output logic [1:0] table_reader_arburst,
  output logic table_reader_arvalid,
  output logic table_reader_rready,
  input logic rope_aux_owner,
  input logic [63:0] core_aux_araddr,
  input logic [7:0] core_aux_arlen,
  input logic [2:0] core_aux_arsize,
  input logic [1:0] core_aux_arburst,
  input logic core_aux_arvalid,
  output logic core_aux_arready,
  output logic [127:0] core_aux_rdata,
  output logic [1:0] core_aux_rresp,
  output logic core_aux_rlast, core_aux_rvalid,
  input logic core_aux_rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,
  output logic [127:0] table_reader_out_data,
  output logic [31:0] table_reader_offset, table_reader_epoch,
  output logic [4:0] table_reader_out_bytes,
  output logic table_reader_last, table_reader_out_valid,
  input logic table_reader_out_ready,

  input logic writer_tile_valid,
  output logic writer_tile_ready,
  input logic [255:0] writer_tile_f32,
  input logic [11:0] writer_tile_n0,
  input logic writer_rearm_valid,
  output logic writer_rearm_ready,
  input logic writer_flush_req,
  output logic writer_flush_done, writer_debt_zero, writer_fault,
  input logic segment_begin_valid,
  input logic [1:0] segment_begin_route,
  input logic [63:0] segment_begin_base, segment_begin_span,
  input logic stage_row_accept, stage_tensor_begin,
  input logic [6:0] stage_row,
  input logic stage_row_discard,
  input logic stage_row_done_fire,
  input logic [3:0] stage_row_done_status,
  input logic stage_release_fire,
  output logic [127:0] norm_written,
  output logic norm_stage_ready, stage_store_fault,
  output logic [1:0] segment_route,
  output logic [63:0] writer_output_base, writer_output_span,
  output logic [31:0] writer_aw_count, writer_w_count, writer_b_count,
  output logic [63:0] writer_useful_bytes, writer_physical_bytes,
  output logic [63:0] writer_awaddr,
  output logic [7:0] writer_awlen,
  output logic [2:0] writer_awsize,
  output logic [1:0] writer_awburst,
  output logic writer_awvalid,
  output logic writer_awready,
  output logic [511:0] writer_wdata,
  output logic [63:0] writer_wstrb,
  output logic writer_wlast, writer_wvalid,
  output logic writer_wready,
  output logic [1:0] writer_bresp,
  output logic writer_bvalid,
  output logic writer_bready,
  output logic [2:0][63:0] m_axi_awaddr,
  output logic [2:0][7:0] m_axi_awlen,
  output logic [2:0][2:0] m_axi_awsize,
  output logic [2:0][1:0] m_axi_awburst,
  output logic [2:0] m_axi_awvalid,
  input logic [2:0] m_axi_awready,
  output logic [2:0][511:0] m_axi_wdata,
  output logic [2:0][63:0] m_axi_wstrb,
  output logic [2:0] m_axi_wlast, m_axi_wvalid,
  input logic [2:0] m_axi_wready,
  input logic [2:0][1:0] m_axi_bresp,
  input logic [2:0] m_axi_bvalid,
  output logic [2:0] m_axi_bready
);
  typedef enum logic [2:0] {
    SP_IDLE, SP_BEGIN, SP_LOAD, SP_WAIT, SP_COMMIT, SP_ERROR, SP_DONE
  } stage_prep_state_t;
  stage_prep_state_t stage_prep_state;
  logic stage_prep_staged, stage_prep_gamma;
  logic stage_prep_error, stage_prep_nonfinite;
  logic stage_prep_load_active, stage_prep_load_done;
  logic stage_prep_raw_done;
  logic stage_prep_hold_valid;
  logic [511:0] stage_prep_hold;
  logic [10:0] stage_prep_words;
  logic [31:0] stage_prep_id, stage_prep_epoch;
  logic [6:0] stage_prep_row;
  logic [3327:0] stage_prep_model;
  logic [671:0] stage_prep_numeric;
  logic [63:0] stage_prep_source_addr;
  logic [63:0] stage_prep_aux_base, stage_prep_aux_span;
  typedef enum logic [3:0] {
    SL_IDLE, SL_REARM, SL_PREP_SEND, SL_PREP_WAIT, SL_CMD,
    SL_WAIT_VIEW, SL_STORE, SL_WAIT_DONE, SL_FINAL, SL_HELD
  } stage_loop_state_t;
  stage_loop_state_t stage_loop_state;
  logic [31:0] stage_base_id, stage_epoch;
  logic [6:0] stage_loop_row;
  logic [3327:0] stage_model;
  logic [671:0] stage_numeric;
  logic [63:0] stage_source_base, stage_source_span;
  logic [63:0] stage_aux_base, stage_aux_span;
  logic [63:0] stage_dest_base, stage_dest_span;
  logic stage_drain_window;
  logic [31:0] stage_saved_store_id;
  logic [6:0] stage_saved_store_row;
  logic [7:0] stage_discarded_rows;
  logic [3:0] stage_final_status;
  logic [3:0] stage_prep_done_status;
  wire stage_direct_active=stage_loop_state!=SL_IDLE;
  wire [31:0] stage_current_id=stage_base_id+{25'd0,stage_loop_row};
  wire [64:0] stage_source_addr=
      {1'b0,stage_source_base}+({58'd0,stage_loop_row}*65'd4096);
  wire [32:0] stage_end_id={1'b0,stage_input_id}+33'd127;
  wire [64:0] stage_source_limit=
      {1'b0,stage_input_source_addr}+{1'b0,stage_input_source_span};
  wire [64:0] stage_dest_limit=
      {1'b0,stage_input_dest_base}+{1'b0,stage_input_dest_span};
  wire [64:0] stage_aux_limit=
      {1'b0,stage_input_aux_base}+{1'b0,stage_input_aux_span};
  wire stage_request_ok=stage_input_id!=0 &&
      !stage_end_id[32] &&
      stage_input_row==0 && stage_input_first &&
      stage_input_epoch!=0 &&
      stage_input_numeric[63:0]!=0 &&
      stage_input_numeric[127:64]!=0 &&
      stage_input_numeric[143:128]==16'd1 &&
      stage_input_numeric[159:144]==16'd128 &&
      stage_input_source_addr[5:0]==0 &&
      stage_input_source_span>=64'd8388608 && !stage_source_limit[64] &&
      stage_input_dest_base[5:0]==0 &&
      stage_input_dest_span>=64'd8388608 && !stage_dest_limit[64] &&
      stage_input_aux_base[3:0]==0 &&
      stage_input_aux_span>=64'd1142528 && !stage_aux_limit[64];
  wire stage_prep_start=stage_loop_state==SL_PREP_SEND &&
      stage_prep_state==SP_IDLE;
  wire stage_legacy_prep_start=stage_input_start && !stage_input_staged &&
      stage_input_ready;
  wire stage_any_prep_start=stage_prep_start || stage_legacy_prep_start;
  wire stage_store_start_selected=stage_direct_active ?
      (stage_loop_state==SL_WAIT_VIEW && bank_link.staged_ln_view_valid) :
      stage_store_start;
  wire stage_store_done_ready_selected=stage_direct_active ?
      stage_loop_state==SL_STORE : stage_store_done_ready;
  wire stage_store_rd_ready_selected=stage_direct_active ?
      bank_link.staged_ln_rd_ready : stage_store_rd_ready;
  wire stage_store_rsp_valid_selected=stage_direct_active ?
      bank_link.result_rsp_valid : stage_store_rsp_valid;
  wire [9:0] stage_store_rsp_tile_selected=stage_direct_active ?
      bank_link.result_rsp_tile : stage_store_rsp_tile;
  wire [255:0] stage_store_rsp_bits_selected=stage_direct_active ?
      bank_link.result_rsp_bits : stage_store_rsp_bits;
  wire stage_store_release_ready_selected=stage_direct_active ?
      bank_link.staged_ln_release_ready : stage_store_release_ready;
  wire stage_store_identity_bad_selected=stage_direct_active ?
      (bank_link.staged_ln_done_id!=stage_current_id ||
       bank_link.staged_ln_done_row!=stage_loop_row ||
       bank_link.staged_ln_done_epoch!=stage_epoch ||
       bank_link.staged_ln_result_exec!=3'd1) :
      stage_store_identity_bad;
  wire stage_row_accept_selected=stage_direct_active ?
      (stage_loop_state==SL_CMD && bank_link.staged_ln_cmd_ready) :
      stage_row_accept;
  wire stage_row_done_fire_selected=stage_direct_active ?
      (stage_loop_state==SL_WAIT_DONE &&
       bank_link.staged_ln_done_valid) : stage_row_done_fire;
  wire stage_tensor_begin_selected=stage_direct_active ?
      stage_loop_row==0 : stage_tensor_begin;
  wire [6:0] stage_row_selected=stage_direct_active ?
      stage_loop_row : stage_row;
  wire stage_row_discard_selected=stage_direct_active ?
      stage_drain_window : stage_row_discard;
  wire [3:0] stage_row_done_status_selected=stage_direct_active ?
      ((stage_store_error || writer_fault ||
        bank_link.staged_ln_done_status!=0) ? 4'd7 : 4'd0) :
      stage_row_done_status;
  assign stage_input_ready=stage_prep_state==SP_IDLE &&
      stage_loop_state==SL_IDLE && writer_debt_zero;
  assign stage_input_done_valid=stage_loop_state==SL_FINAL ||
      (stage_loop_state==SL_IDLE && stage_prep_state==SP_DONE);
  assign stage_input_done_status=stage_loop_state==SL_FINAL ?
      stage_final_status : stage_prep_done_status;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      stage_loop_state<=SL_IDLE;stage_base_id<=0;stage_epoch<=0;
      stage_loop_row<=0;stage_model<=0;stage_numeric<=0;
      stage_source_base<=0;stage_source_span<=0;
      stage_aux_base<=0;stage_aux_span<=0;
      stage_dest_base<=0;stage_dest_span<=0;
      stage_drain_window<=0;stage_saved_store_id<=0;
      stage_saved_store_row<=0;stage_discarded_rows<=0;
      stage_retired_rows<=0;stage_final_status<=0;
      stage_done_phase<=4'd7;stage_done_id<=0;stage_done_row<=0;
      stage_done_bad<=32'hffffffff;stage_done_op<=8'h10;
      stage_done_check_status<=0;stage_done_detail<=0;
      stage_done_bad64<=64'hffff_ffff_ffff_ffff;
    end else if(stage_release_fire)begin
      stage_loop_state<=SL_IDLE;
      stage_drain_window<=0;stage_retired_rows<=0;
      stage_discarded_rows<=0;
    end else begin
      case(stage_loop_state)
        SL_IDLE:if(stage_input_start && stage_input_staged &&
                   stage_input_ready)begin
          stage_base_id<=stage_input_id;
          stage_epoch<=stage_input_epoch;
          stage_model<=stage_input_model;
          stage_numeric<=stage_input_numeric;
          stage_source_base<=stage_input_source_addr;
          stage_source_span<=stage_input_source_span;
          stage_aux_base<=stage_input_aux_base;
          stage_aux_span<=stage_input_aux_span;
          stage_dest_base<=stage_input_dest_base;
          stage_dest_span<=stage_input_dest_span;
          stage_loop_row<=0;stage_retired_rows<=0;
          stage_discarded_rows<=0;stage_drain_window<=0;
          stage_done_id<=stage_input_id;stage_done_row<=0;
          stage_done_bad<=32'hffffffff;stage_done_op<=8'h10;
          stage_done_bad64<=64'hffff_ffff_ffff_ffff;
          if(!stage_request_ok)begin
            stage_final_status<=4'd7;stage_done_phase<=4'd14;
            stage_done_check_status<=16'd7;
            stage_done_detail<=32'h0710_0005;
            stage_loop_state<=SL_FINAL;
          end else stage_loop_state<=SL_REARM;
        end
        SL_REARM:if(writer_rearm_ready && writer_debt_zero)
          stage_loop_state<=SL_PREP_SEND;
        SL_PREP_SEND:if(stage_prep_start)stage_loop_state<=SL_PREP_WAIT;
        SL_PREP_WAIT:if(stage_prep_state==SP_DONE)begin
          if(stage_prep_done_status!=0)begin
            stage_final_status<=stage_prep_done_status;
            stage_done_id<=stage_current_id;
            stage_done_row<=stage_loop_row;
            stage_done_phase<=4'd14;
            stage_done_check_status<={12'd0,stage_prep_done_status};
            stage_done_detail<=stage_prep_done_status==4'd6 ?
                               32'h0710_000f : 32'h0710_0005;
            stage_loop_state<=SL_FINAL;
          end else stage_loop_state<=SL_CMD;
        end
        SL_CMD:if(bank_link.staged_ln_cmd_ready)
          stage_loop_state<=SL_WAIT_VIEW;
        SL_WAIT_VIEW:if(bank_link.staged_ln_view_valid)
          stage_loop_state<=SL_STORE;
        else if(bank_link.staged_ln_done_valid)begin
          stage_final_status<=bank_link.staged_ln_done_status==0 ?
                              4'd7 : bank_link.staged_ln_done_status;
          stage_done_phase<=bank_link.staged_ln_done_status==0 ?
                            4'd14 : bank_link.staged_ln_done_phase;
          stage_done_id<=stage_current_id;
          stage_done_row<=stage_loop_row;
          stage_done_bad<=bank_link.staged_ln_done_bad;
          stage_done_op<=bank_link.staged_ln_done_op;
          stage_done_check_status<=bank_link.staged_ln_done_status==0 ?
              16'd7 : bank_link.staged_ln_done_check_status;
          stage_done_detail<=bank_link.staged_ln_done_status==0 ?
              32'h0710_0005 : bank_link.staged_ln_done_detail;
          stage_done_bad64<=bank_link.staged_ln_done_status==0 ?
              64'hffff_ffff_ffff_ffff : bank_link.staged_ln_done_bad64;
          stage_loop_state<=SL_FINAL;
        end
        SL_STORE:if(stage_store_done_valid)
          stage_loop_state<=SL_WAIT_DONE;
        SL_WAIT_DONE:if(bank_link.staged_ln_done_valid)begin
          if(bank_link.staged_ln_done_id!=stage_current_id ||
             bank_link.staged_ln_done_row!=stage_loop_row ||
             bank_link.staged_ln_done_epoch!=stage_epoch ||
             bank_link.staged_ln_result_exec!=3'd1)begin
            stage_final_status<=4'd7;stage_done_phase<=4'd12;
            stage_done_id<=stage_current_id;stage_done_row<=stage_loop_row;
            stage_done_check_status<=16'd7;
            stage_done_detail<=32'h0710_0005;
            stage_loop_state<=SL_FINAL;
          end else if(bank_link.staged_ln_done_status==4'd6)begin
            stage_final_status<=4'd6;
            stage_done_phase<=bank_link.staged_ln_done_phase;
            stage_done_id<=stage_current_id;
            stage_done_row<=stage_loop_row;
            stage_done_bad<=bank_link.staged_ln_done_bad;
            stage_done_op<=bank_link.staged_ln_done_op;
            stage_done_check_status<=bank_link.staged_ln_done_check_status;
            stage_done_detail<=bank_link.staged_ln_done_detail;
            stage_done_bad64<=bank_link.staged_ln_done_bad64;
            stage_loop_state<=SL_FINAL;
          end else if(!stage_drain_window &&
                 (stage_store_error || writer_fault))begin
            stage_saved_store_id<=stage_current_id;
            stage_saved_store_row<=stage_loop_row;
            stage_drain_window<=1;
            if(stage_loop_row[3:0]==4'd15)begin
              stage_final_status<=4'd7;stage_done_phase<=4'd12;
              stage_done_id<=stage_current_id;
              stage_done_row<=stage_loop_row;
              stage_done_check_status<=16'd7;
              stage_done_detail<=32'h0710_0005;
              stage_loop_state<=SL_FINAL;
            end else begin
              stage_loop_row<=stage_loop_row+1'b1;
              stage_loop_state<=SL_REARM;
            end
          end else if(bank_link.staged_ln_done_status!=0 &&
                      !(stage_drain_window &&
                        bank_link.staged_ln_done_status==4'd7 &&
                        bank_link.staged_ln_done_phase==4'd12 &&
                        stage_store_discard_q))begin
            stage_final_status<=bank_link.staged_ln_done_status;
            stage_done_phase<=bank_link.staged_ln_done_phase;
            stage_done_id<=stage_current_id;
            stage_done_row<=stage_loop_row;
            stage_done_bad<=bank_link.staged_ln_done_bad;
            stage_done_op<=bank_link.staged_ln_done_op;
            stage_done_check_status<=bank_link.staged_ln_done_check_status;
            stage_done_detail<=bank_link.staged_ln_done_detail;
            stage_done_bad64<=bank_link.staged_ln_done_bad64;
            stage_loop_state<=SL_FINAL;
          end else begin
            if(stage_drain_window)stage_discarded_rows<=
                stage_discarded_rows+1'b1;
            else stage_retired_rows<=stage_retired_rows+1'b1;
            if(stage_drain_window && stage_loop_row[3:0]==4'd15)begin
              stage_final_status<=4'd7;stage_done_phase<=4'd12;
              stage_done_id<=stage_saved_store_id;
              stage_done_row<=stage_saved_store_row;
              stage_done_check_status<=16'd7;
              stage_done_detail<=32'h0710_0005;
              stage_loop_state<=SL_FINAL;
            end else if(stage_loop_row==7'd127)begin
              stage_final_status<=0;stage_done_phase<=4'd7;
              stage_done_id<=stage_current_id;
              stage_done_row<=stage_loop_row;
              stage_done_check_status<=0;stage_done_detail<=0;
              stage_loop_state<=SL_FINAL;
            end else begin
              stage_loop_row<=stage_loop_row+1'b1;
              stage_loop_state<=SL_REARM;
            end
          end
        end
        SL_FINAL:if(stage_input_done_ready)stage_loop_state<=SL_HELD;
        SL_HELD:;
        default:stage_loop_state<=SL_IDLE;
      endcase
    end
  end
  typedef enum logic [3:0] {
    SS_IDLE, SS_SEGMENT, SS_READ_REQ, SS_READ_RSP, SS_FLUSH,
    SS_UNFLUSH, SS_ERR_READ, SS_ERR_DRAIN, SS_RELEASE, SS_DONE
  } stage_store_state_t;
  stage_store_state_t stage_store_state;
  logic [7:0] stage_store_tile_count;
  logic stage_store_read_pending;
  logic [6:0] stage_store_row_q;
  logic [63:0] stage_store_base_q, stage_store_span_q;
  logic stage_store_discard_q;
  logic [6:0] stage_store_ok_b;
  wire [64:0] stage_store_addr=
      {1'b0,stage_store_base_q}+({58'd0,stage_store_row_q}*65'd4096);
  wire [63:0] stage_store_offset={57'd0,stage_store_row_q}*64'd4096;
  wire stage_store_addr_ok=!stage_store_addr[64] &&
      stage_store_addr[5:0]==0 &&
      stage_store_offset<=stage_store_span_q &&
      64'd4096<=stage_store_span_q-stage_store_offset;
  wire stage_store_owner=stage_store_state!=SS_IDLE;
  wire stage_store_segment_begin=stage_store_state==SS_SEGMENT &&
      !stage_store_identity_bad_selected && stage_store_addr_ok &&
      writer_debt_zero && !stage_store_read_pending;
  assign stage_store_rd_valid=stage_store_state==SS_READ_REQ &&
      !stage_store_error && !stage_store_identity_bad_selected && !writer_fault;
  assign stage_store_rd_tile={2'd0,stage_store_tile_count};
  assign stage_store_rsp_ready=stage_store_state==SS_READ_RSP ?
      (stage_store_error || stage_store_identity_bad_selected || writer_fault ||
       stage_store_rsp_tile_selected!=stage_store_rd_tile || writer_tile_ready) :
      (stage_store_state==SS_ERR_READ ||
       stage_store_state==SS_ERR_DRAIN);
  assign stage_store_release_valid=stage_store_state==SS_RELEASE;
  assign stage_store_release_discard=stage_store_discard_q ||
      stage_store_error || writer_fault;
  assign stage_store_done_valid=stage_store_state==SS_DONE;
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      stage_store_state<=SS_IDLE;
      stage_store_tile_count<=0;
      stage_store_read_pending<=0;
      stage_store_row_q<=0;stage_store_base_q<=0;
      stage_store_span_q<=0;stage_store_discard_q<=0;
      stage_store_ok_b<=0;stage_store_error<=0;
    end else begin
      if(stage_store_start_selected && stage_store_state==SS_IDLE)begin
        stage_store_row_q<=stage_direct_active ? stage_loop_row : stage_store_row;
        stage_store_base_q<=stage_direct_active ? stage_dest_base : stage_store_base;
        stage_store_span_q<=stage_direct_active ? stage_dest_span : stage_store_span;
        stage_store_discard_q<=stage_direct_active ? stage_drain_window : stage_store_discard;
        stage_store_tile_count<=0;
        stage_store_read_pending<=0;
        stage_store_ok_b<=0;
        stage_store_error<=0;
        stage_store_state<=(stage_direct_active ? stage_drain_window :
                           stage_store_discard) ? SS_RELEASE : SS_SEGMENT;
      end else begin
        if(stage_store_rd_valid && stage_store_rd_ready_selected)
          stage_store_read_pending<=1;
        if(stage_store_rsp_valid_selected && stage_store_rsp_ready)
          stage_store_read_pending<=0;
        if(stage_store_owner && writer_bvalid && writer_bready &&
           writer_bresp==2'b00)
          stage_store_ok_b<=stage_store_ok_b+1'b1;
        case(stage_store_state)
          SS_IDLE:;
          SS_SEGMENT:if(stage_store_identity_bad_selected || !stage_store_addr_ok ||
                        !writer_debt_zero || stage_store_read_pending)begin
            stage_store_error<=1;
            stage_store_state<=SS_ERR_DRAIN;
          end else stage_store_state<=SS_READ_REQ;
          SS_READ_REQ:if(stage_store_identity_bad_selected || writer_fault)begin
            stage_store_error<=1;
            stage_store_state<=SS_ERR_DRAIN;
          end else if(stage_store_rd_valid && stage_store_rd_ready_selected)
            stage_store_state<=SS_READ_RSP;
          SS_READ_RSP:if(stage_store_identity_bad_selected || writer_fault)begin
            stage_store_error<=1;
            stage_store_state<=SS_ERR_READ;
          end else if(stage_store_rsp_valid_selected && stage_store_rsp_ready)begin
            if(stage_store_rsp_tile_selected!=stage_store_rd_tile)begin
              stage_store_error<=1;
              stage_store_state<=SS_ERR_DRAIN;
            end else if(stage_store_tile_count==8'd127)
              stage_store_state<=SS_FLUSH;
            else begin
              stage_store_tile_count<=stage_store_tile_count+1'b1;
              stage_store_state<=SS_READ_REQ;
            end
          end
          SS_FLUSH:if(stage_store_identity_bad_selected || writer_fault)begin
            stage_store_error<=1;
            stage_store_state<=SS_ERR_DRAIN;
          end else if(writer_flush_done && writer_debt_zero)
            stage_store_state<=SS_UNFLUSH;
          SS_UNFLUSH:if(stage_store_identity_bad_selected || writer_fault)begin
            stage_store_error<=1;
            stage_store_state<=SS_ERR_DRAIN;
          end else if(writer_tile_ready && writer_debt_zero)begin
            if(stage_store_tile_count!=8'd127 ||
               writer_aw_count!=32'd64 || writer_w_count!=32'd64 ||
               writer_b_count!=32'd64 || stage_store_ok_b!=7'd64)begin
              stage_store_error<=1;
              stage_store_state<=SS_ERR_DRAIN;
            end else stage_store_state<=SS_RELEASE;
          end
          SS_ERR_READ:if(!stage_store_read_pending ||
                         (stage_store_rsp_valid_selected && stage_store_rsp_ready))
            stage_store_state<=SS_ERR_DRAIN;
          SS_ERR_DRAIN:if(!stage_store_read_pending &&
                           !stage_store_rsp_valid_selected && writer_debt_zero)
            stage_store_state<=SS_RELEASE;
          SS_RELEASE:if(stage_store_release_valid &&
                        stage_store_release_ready_selected)
            stage_store_state<=SS_DONE;
          SS_DONE:if(stage_store_done_ready_selected)stage_store_state<=SS_IDLE;
          default:stage_store_state<=SS_IDLE;
        endcase
      end
    end
  end
  wire stage_prep_owner=stage_prep_state!=SP_IDLE;
  wire stage_scratch_load=stage_prep_state==SP_LOAD && !stage_prep_gamma &&
                          !stage_prep_error;
  wire stage_table_load=stage_prep_state==SP_LOAD && stage_prep_gamma &&
                        !stage_prep_error;
  wire stage_out_valid=stage_prep_gamma ? table_reader_out_valid :
                       scratch_reader_out_valid;
  wire stage_reader_done=stage_prep_gamma ? table_reader_done :
                         scratch_reader_done;
  wire stage_reader_error=stage_prep_gamma ? table_reader_error :
                          scratch_reader_error;
  wire [31:0] stage_reader_bytes=stage_prep_gamma ? table_reader_bytes :
                                 scratch_reader_bytes;
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      stage_prep_state<=SP_IDLE;
      stage_prep_staged<=0;stage_prep_gamma<=0;stage_prep_error<=0;
      stage_prep_nonfinite<=0;stage_prep_load_active<=0;
      stage_prep_load_done<=0;stage_prep_raw_done<=0;
      stage_prep_hold_valid<=0;
      stage_prep_hold<=0;stage_prep_words<=0;
      stage_prep_id<=0;stage_prep_epoch<=0;stage_prep_row<=0;
      stage_prep_model<=0;stage_prep_numeric<=0;
      stage_prep_source_addr<=0;
      stage_prep_aux_base<=0;stage_prep_aux_span<=0;
      stage_prep_done_status<=0;
    end else begin
      if(stage_any_prep_start)begin
        stage_prep_id<=stage_prep_start ? stage_current_id : stage_input_id;
        stage_prep_row<=stage_prep_start ? stage_loop_row : stage_input_row;
        stage_prep_epoch<=stage_prep_start ? stage_epoch : stage_input_epoch;
        stage_prep_model<=stage_prep_start ? stage_model : stage_input_model;
        stage_prep_numeric<=stage_prep_start ? stage_numeric :
                            stage_input_numeric;
        stage_prep_source_addr<=stage_prep_start ?
                                stage_source_addr[63:0] :
                                stage_input_source_addr;
        stage_prep_aux_base<=stage_prep_start ? stage_aux_base :
                             stage_input_aux_base;
        stage_prep_aux_span<=stage_prep_start ? stage_aux_span :
                             stage_input_aux_span;
        stage_prep_staged<=stage_prep_start || stage_input_staged;
        stage_prep_gamma<=stage_prep_start ? stage_loop_row==0 :
                          (stage_input_staged && stage_input_first);
        stage_prep_error<=0;stage_prep_nonfinite<=0;
        stage_prep_load_active<=0;stage_prep_load_done<=0;
        stage_prep_raw_done<=0;
        stage_prep_hold_valid<=0;stage_prep_words<=0;
        stage_prep_done_status<=0;
        stage_prep_state<=SP_BEGIN;
      end else begin
        if(stage_prep_state==SP_WAIT && stage_out_valid &&
           !stage_prep_hold_valid && !stage_prep_error)begin
          if(stage_prep_gamma)begin
            for(int word=0;word<4;word++)
              if(table_reader_out_data[word*32+23+:8]==8'hff)
                stage_prep_nonfinite<=1;
            if(table_reader_offset!={19'd0,stage_prep_words,2'b00} ||
               table_reader_epoch!=stage_prep_epoch ||
               table_reader_out_bytes!=5'd16 ||
               table_reader_last!=(stage_prep_words==11'd1020))
              stage_prep_error<=1;
            else begin
              stage_prep_hold<={384'd0,table_reader_out_data};
              stage_prep_hold_valid<=1;
            end
          end else if(scratch_reader_offset!=
                      {19'd0,stage_prep_words,2'b00} ||
                      scratch_reader_epoch!=stage_prep_epoch ||
                      scratch_reader_out_bytes!=7'd64 ||
                      scratch_reader_last!=(stage_prep_words==11'd1008))
            stage_prep_error<=1;
          else begin
            stage_prep_hold<=scratch_reader_out_data;
            stage_prep_hold_valid<=1;
          end
        end
        if(stage_prep_state==SP_WAIT && stage_prep_hold_valid &&
           !stage_prep_error)begin
          if(bank_link.prep_write_ready)begin
            stage_prep_hold<={32'd0,stage_prep_hold[511:32]};
            stage_prep_words<=stage_prep_words+1'b1;
            if(stage_prep_gamma ? stage_prep_words[1:0]==2'd3 :
                                stage_prep_words[3:0]==4'd15)
              stage_prep_hold_valid<=0;
          end else stage_prep_error<=1;
        end
        if(stage_prep_state==SP_WAIT && stage_reader_done)begin
          stage_prep_load_done<=1;
          if(!stage_prep_gamma)stage_prep_raw_done<=1;
          stage_prep_load_active<=0;
          if(stage_reader_error || stage_reader_bytes!=32'd4096)
            stage_prep_error<=1;
        end
        case(stage_prep_state)
          SP_IDLE:;
          SP_BEGIN:if(bank_link.prep_begin_ready)stage_prep_state<=SP_LOAD;
          SP_LOAD:if(stage_prep_gamma ?
                     (table_reader_load_ready && stage_table_load) :
                     (scratch_reader_load_ready && stage_scratch_load))begin
            stage_prep_load_active<=1;
            stage_prep_state<=SP_WAIT;
          end
          SP_WAIT:if(stage_prep_error || bank_link.prep_fault)
                    stage_prep_state<=SP_ERROR;
                  else if(stage_prep_load_done && !stage_prep_hold_valid &&
                          !stage_out_valid && stage_prep_words==11'd1024)begin
                    if(!stage_prep_staged && !stage_prep_gamma)begin
                      stage_prep_gamma<=1;
                      stage_prep_words<=0;
                      stage_prep_load_done<=0;
                      stage_prep_state<=SP_LOAD;
                    end else stage_prep_state<=SP_COMMIT;
                  end
          SP_COMMIT:if(bank_link.prep_fault ||
                       (stage_prep_staged && stage_prep_gamma ?
                         (!stage_prep_load_done || stage_prep_nonfinite) :
                         (!stage_prep_load_done ||
                          !stage_prep_raw_done ||
                          (stage_prep_staged &&
                           !bank_link.gamma_token_valid))))
                      stage_prep_state<=SP_ERROR;
                    else if(bank_link.prep_commit_ready)begin
                      if(stage_prep_staged && stage_prep_gamma)begin
                        stage_prep_gamma<=0;
                        stage_prep_words<=0;
                        stage_prep_load_done<=0;
                        stage_prep_state<=SP_BEGIN;
                      end else stage_prep_state<=SP_DONE;
                    end
          SP_ERROR:begin
            stage_prep_hold_valid<=0;
            if(stage_reader_done)stage_prep_load_active<=0;
            if(bank_link.prep_abort_ready && !stage_prep_load_active &&
               !scratch_reader_out_valid && !table_reader_out_valid)begin
              stage_prep_done_status<=stage_prep_nonfinite ? 4'd6 : 4'd7;
              stage_prep_state<=SP_DONE;
            end
          end
          SP_DONE:if(stage_direct_active ?
                     stage_loop_state==SL_PREP_WAIT : stage_input_done_ready)
            stage_prep_state<=SP_IDLE;
          default:stage_prep_state<=SP_IDLE;
        endcase
      end
    end
  end
  laya_lnq_bank_service_v1 bank_service (
    .clk(clk),
    .rst_n(rst_n),
    .ln_cmd_valid(bank_link.ln_cmd_valid),
    .ln_cmd_ready(bank_link.ln_cmd_ready),
    .ln_source_mode(bank_link.ln_source_mode),
    .ln_gamma_kind(bank_link.ln_gamma_kind),
    .ln_cmd_row(bank_link.ln_cmd_row),
    .ln_only_ready(bank_link.ln_only_ready),
    .staged_ln_cmd_valid(stage_direct_active ?
        stage_loop_state==SL_CMD : bank_link.staged_ln_cmd_valid),
    .staged_ln_cmd_ready(bank_link.staged_ln_cmd_ready),
    .staged_ln_row(stage_direct_active ? stage_loop_row : bank_link.staged_ln_row),
    .staged_ln_view_valid(bank_link.staged_ln_view_valid),
    .staged_ln_rd_valid(stage_direct_active ?
        stage_store_rd_valid : bank_link.staged_ln_rd_valid),
    .staged_ln_rd_tile(stage_direct_active ?
        stage_store_rd_tile : bank_link.staged_ln_rd_tile),
    .staged_ln_rd_ready(bank_link.staged_ln_rd_ready),
    .staged_ln_release_valid(stage_direct_active ?
        stage_store_release_valid : bank_link.staged_ln_release_valid),
    .staged_ln_release_discard(stage_direct_active ?
        stage_store_release_discard : bank_link.staged_ln_release_discard),
    .staged_ln_release_ready(bank_link.staged_ln_release_ready),
    .staged_ln_done_valid(bank_link.staged_ln_done_valid),
    .staged_ln_done_ready(stage_direct_active ?
        (stage_loop_state==SL_WAIT_DONE ||
         (stage_loop_state==SL_WAIT_VIEW &&
          !bank_link.staged_ln_view_valid)) :
        bank_link.staged_ln_done_ready),
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
    .prep_begin_idle(stage_direct_active ?
        bank_link.bank_idle : bank_link.prep_begin_idle),
    .prep_begin_allow(bank_link.prep_begin_allow),
    .prep_begin_valid(stage_prep_owner ? stage_prep_state==SP_BEGIN :
                      bank_link.prep_begin_valid),
    .prep_begin_ready(bank_link.prep_begin_ready),
    .prep_kind(stage_prep_owner ?
               (!stage_prep_staged ? 2'b00 :
                stage_prep_gamma ? 2'b11 : 2'b01) : bank_link.prep_kind),
    .prep_id(stage_prep_owner ? stage_prep_id : bank_link.prep_id),
    .prep_row(stage_prep_owner ? stage_prep_row : bank_link.prep_row),
    .prep_epoch(stage_prep_owner ? stage_prep_epoch : bank_link.prep_epoch),
    .prep_model_identity(stage_prep_owner ? stage_prep_model :
                         bank_link.prep_model_identity),
    .prep_numeric_identity(stage_prep_owner ? stage_prep_numeric :
                           bank_link.prep_numeric_identity),
    .prep_gamma_aux_base(stage_prep_owner ? stage_prep_aux_base :
                         bank_link.prep_gamma_aux_base),
    .prep_gamma_aux_span(stage_prep_owner ? stage_prep_aux_span :
                         bank_link.prep_gamma_aux_span),
    .prep_write_valid(stage_prep_owner ?
                      (stage_prep_hold_valid && !stage_prep_error &&
                       stage_prep_state==SP_WAIT) :
                      bank_link.prep_write_valid),
    .prep_write_ready(bank_link.prep_write_ready),
    .prep_write_index(stage_prep_owner ?
                      (!stage_prep_staged && stage_prep_gamma ?
                       11'd1024+stage_prep_words : stage_prep_words) :
                      bank_link.prep_write_index),
    .prep_write_bits(stage_prep_owner ? stage_prep_hold[31:0] :
                     bank_link.prep_write_bits),
    .prep_commit_valid(stage_prep_owner ? stage_prep_state==SP_COMMIT :
                       bank_link.prep_commit_valid),
    .prep_commit_ready(bank_link.prep_commit_ready),
    .prep_abort_valid(stage_prep_owner ?
                      (stage_prep_state==SP_ERROR &&
                       !stage_prep_load_active && !stage_prep_hold_valid &&
                       !scratch_reader_out_valid && !table_reader_out_valid) :
                      bank_link.prep_abort_valid),
    .prep_abort_ready(bank_link.prep_abort_ready),
    .prep_active(bank_link.prep_active),
    .prep_token_valid(bank_link.prep_token_valid),
    .gamma_token_valid(bank_link.gamma_token_valid),
    .prep_fault(bank_link.prep_fault),
    .prep_consume(stage_direct_active ?
        (stage_loop_state==SL_CMD && bank_link.staged_ln_cmd_ready) :
        bank_link.prep_consume),
    .match_id(stage_direct_active ? stage_current_id : bank_link.match_id),
    .match_row(stage_direct_active ? stage_loop_row : bank_link.match_row),
    .match_epoch(stage_direct_active ? stage_epoch : bank_link.match_epoch),
    .match_model_identity(stage_direct_active ?
        stage_model : bank_link.match_model_identity),
    .match_numeric_identity(stage_direct_active ?
        stage_numeric : bank_link.match_numeric_identity),
    .match_kind(stage_direct_active ? 2'b01 : bank_link.match_kind),
    .match_gamma_aux_base(stage_direct_active ?
        stage_aux_base : bank_link.match_gamma_aux_base),
    .match_gamma_aux_span(stage_direct_active ?
        stage_aux_span : bank_link.match_gamma_aux_span),
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
    .result_rsp_ready(stage_direct_active ?
        stage_store_rsp_ready : bank_link.result_rsp_ready),
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
  logic scratch_reader_arready;
  logic [511:0] scratch_reader_rdata;
  logic [1:0] scratch_reader_rresp;
  logic scratch_reader_rlast, scratch_reader_rvalid;
  logic table_reader_arready;
  logic [127:0] table_reader_rdata;
  logic [1:0] table_reader_rresp;
  logic table_reader_rlast, table_reader_rvalid;
  logic stage_row_active, stage_discard_q, stage_flush_seen;
  logic [6:0] stage_row_q;
  wire selected_source_load=stage_prep_owner ?
      !stage_prep_gamma : source_load_active;
  wire selected_aux_owner=stage_prep_owner || rope_aux_owner;
  assign scratch_reader_arready = selected_source_load ?
      state0_arready : rope_arready[rope_route];
  assign scratch_reader_rdata = selected_source_load ?
      state0_rdata : rope_rdata[rope_route];
  assign scratch_reader_rresp = selected_source_load ?
      state0_rresp : rope_rresp[rope_route];
  assign scratch_reader_rlast = selected_source_load ?
      state0_rlast : rope_rlast[rope_route];
  assign scratch_reader_rvalid = selected_source_load ?
      state0_rvalid : rope_rvalid[rope_route];
  assign state0_araddr = selected_source_load ? scratch_reader_araddr : '0;
  assign state0_arlen = selected_source_load ? scratch_reader_arlen : '0;
  assign state0_arsize = selected_source_load ? scratch_reader_arsize : '0;
  assign state0_arburst = selected_source_load ? scratch_reader_arburst : '0;
  assign state0_arvalid = selected_source_load && scratch_reader_arvalid;
  assign state0_rready = selected_source_load && scratch_reader_rready;
  always_comb begin
    rope_araddr = '0; rope_arlen = '0; rope_arsize = '0;
    rope_arburst = '0; rope_arvalid = '0; rope_rready = '0;
    if (!selected_source_load) begin
      rope_araddr[rope_route] = scratch_reader_araddr;
      rope_arlen[rope_route] = scratch_reader_arlen;
      rope_arsize[rope_route] = scratch_reader_arsize;
      rope_arburst[rope_route] = scratch_reader_arburst;
      rope_arvalid[rope_route] = scratch_reader_arvalid;
      rope_rready[rope_route] = scratch_reader_rready;
    end
  end
  assign aux_araddr = selected_aux_owner ? table_reader_araddr : core_aux_araddr;
  assign aux_arlen = selected_aux_owner ? table_reader_arlen : core_aux_arlen;
  assign aux_arsize = selected_aux_owner ? table_reader_arsize : core_aux_arsize;
  assign aux_arburst = selected_aux_owner ? table_reader_arburst : core_aux_arburst;
  assign aux_arvalid = selected_aux_owner ? table_reader_arvalid : core_aux_arvalid;
  assign core_aux_arready = selected_aux_owner ? 1'b0 : aux_arready;
  assign core_aux_rdata = aux_rdata;
  assign core_aux_rresp = aux_rresp;
  assign core_aux_rlast = aux_rlast;
  assign core_aux_rvalid = selected_aux_owner ? 1'b0 : aux_rvalid;
  assign aux_rready = selected_aux_owner ? table_reader_rready : core_aux_rready;
  assign table_reader_arready = selected_aux_owner && aux_arready;
  assign table_reader_rdata = aux_rdata;
  assign table_reader_rresp = aux_rresp;
  assign table_reader_rlast = aux_rlast;
  assign table_reader_rvalid = selected_aux_owner && aux_rvalid;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      segment_route<=0;
      writer_output_base<=0;writer_output_span<=0;
      norm_written<='0;
      norm_stage_ready<=0;
      stage_store_fault<=0;
      stage_row_active<=0;stage_discard_q<=0;
      stage_flush_seen<=0;stage_row_q<=0;
    end else if(segment_begin_valid || stage_store_segment_begin)begin
      segment_route<=stage_store_segment_begin ? 2'd2 : segment_begin_route;
      writer_output_base<=stage_store_segment_begin ?
                          stage_store_addr[63:0] : segment_begin_base;
      writer_output_span<=stage_store_segment_begin ?
                          64'd4096 : segment_begin_span;
    end
    if(rst_n)begin
      if(stage_release_fire ||
         (stage_row_accept_selected && stage_tensor_begin_selected))begin
        norm_written<='0;
        norm_stage_ready<=0;
        stage_store_fault<=0;
      end else if(stage_row_active)begin
        if(writer_fault)stage_store_fault<=1;
        if(writer_flush_done && writer_debt_zero)
          stage_flush_seen<=1;
        if(stage_row_done_fire_selected)begin
          if(stage_row_done_status_selected==0 && !stage_discard_q &&
             !writer_fault && writer_debt_zero && stage_flush_seen &&
             writer_aw_count==32'd64 && writer_w_count==32'd64 &&
             writer_b_count==32'd64)begin
            norm_written[stage_row_q]<=1;
            if(stage_row_q==7'd127 && &norm_written[126:0] &&
               !stage_store_fault)norm_stage_ready<=1;
          end
          stage_row_active<=0;
        end
      end
      if(stage_row_accept_selected)begin
        stage_row_active<=1;
        stage_row_q<=stage_row_selected;
        stage_discard_q<=stage_row_discard_selected;
        stage_flush_seen<=0;
      end
      if(stage_release_fire)begin
        stage_row_active<=0;
        stage_flush_seen<=0;
      end
    end
  end
  always_comb begin
    m_axi_awaddr='0;m_axi_awlen='0;
    m_axi_awsize='0;m_axi_awburst='0;m_axi_awvalid='0;
    m_axi_wdata='0;m_axi_wstrb='0;
    m_axi_wlast='0;m_axi_wvalid='0;m_axi_bready='0;
    writer_awready=m_axi_awready[segment_route];
    writer_wready=m_axi_wready[segment_route];
    writer_bvalid=m_axi_bvalid[segment_route];
    writer_bresp=m_axi_bresp[segment_route];
    m_axi_awaddr[segment_route]=writer_awaddr;
    m_axi_awlen[segment_route]=writer_awlen;
    m_axi_awsize[segment_route]=writer_awsize;
    m_axi_awburst[segment_route]=writer_awburst;
    m_axi_awvalid[segment_route]=writer_awvalid;
    m_axi_wdata[segment_route]=writer_wdata;
    m_axi_wstrb[segment_route]=writer_wstrb;
    m_axi_wlast[segment_route]=writer_wlast;
    m_axi_wvalid[segment_route]=writer_wvalid;
    m_axi_bready[segment_route]=writer_bready;
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n &&
      (segment_begin_valid || stage_store_segment_begin))
    assert(writer_debt_zero && !writer_flush_req && !writer_tile_valid)
      else $fatal(1,"source/norm writer route changed with outstanding debt");
`endif
  t4_w_reader_port_v1 #(.SCALE_MODE(1'b0)) rope_scratch_reader (
    .clk,.rst_n,.cancel(reader_cancel ||
                        (stage_prep_owner &&
                         (stage_prep_error || stage_prep_state==SP_ERROR))),
    .load_valid(stage_prep_owner ? stage_scratch_load :
                scratch_reader_load_valid),
    .load_ready(scratch_reader_load_ready),
    .load_base(stage_prep_owner ? stage_prep_source_addr :
               scratch_reader_load_base),
    .load_bytes(stage_prep_owner ? 32'd4096 : scratch_reader_load_bytes),
    .load_epoch(stage_prep_owner ? stage_prep_epoch :
                scratch_reader_load_epoch),
    .load_done(scratch_reader_done),.load_error(scratch_reader_error),
    .committed_bytes(scratch_reader_bytes),
    .araddr(scratch_reader_araddr),.arlen(scratch_reader_arlen),
    .arsize(scratch_reader_arsize),.arburst(scratch_reader_arburst),
    .arvalid(scratch_reader_arvalid),.arready(scratch_reader_arready),
    .rdata(scratch_reader_rdata),.rresp(scratch_reader_rresp),
    .rlast(scratch_reader_rlast),.rvalid(scratch_reader_rvalid),
    .rready(scratch_reader_rready),
    .out_data(scratch_reader_out_data),.out_offset(scratch_reader_offset),
    .out_epoch(scratch_reader_epoch),.out_bytes(scratch_reader_out_bytes),
    .out_last(scratch_reader_last),.out_valid(scratch_reader_out_valid),
    .out_ready(stage_prep_owner ?
               (stage_prep_state==SP_ERROR ||
                (stage_prep_state==SP_WAIT &&
                 !stage_prep_hold_valid && !stage_prep_error)) :
               scratch_reader_out_ready)
  );
  t4_aux_bias_reader_v1 rope_table_reader (
    .clk,.rst_n,.cancel(reader_cancel ||
                        (stage_prep_owner &&
                         (stage_prep_error || stage_prep_state==SP_ERROR))),
    .load_valid(stage_prep_owner ? stage_table_load :
                table_reader_load_valid),.load_ready(table_reader_load_ready),
    .load_base(stage_prep_owner ? stage_prep_aux_base+64'd128 :
               table_reader_load_base),
    .load_bytes(stage_prep_owner ? 32'd4096 : table_reader_load_bytes),
    .load_epoch(stage_prep_owner ? stage_prep_epoch :
                table_reader_load_epoch),
    .load_done(table_reader_done),.load_error(table_reader_error),
    .committed_bytes(table_reader_bytes),
    .araddr(table_reader_araddr),.arlen(table_reader_arlen),
    .arsize(table_reader_arsize),.arburst(table_reader_arburst),
    .arvalid(table_reader_arvalid),.arready(table_reader_arready),
    .rdata(table_reader_rdata),.rresp(table_reader_rresp),
    .rlast(table_reader_rlast),.rvalid(table_reader_rvalid),
    .rready(table_reader_rready),
    .out_data(table_reader_out_data),.out_offset(table_reader_offset),
    .out_epoch(table_reader_epoch),.out_bytes(table_reader_out_bytes),
    .out_last(table_reader_last),.out_valid(table_reader_out_valid),
    .out_ready(stage_prep_owner ?
               (stage_prep_state==SP_ERROR ||
                (stage_prep_state==SP_WAIT &&
                 !stage_prep_hold_valid && !stage_prep_error)) :
               table_reader_out_ready)
  );
  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer (
    .clk,.rst_n,
    .tile_valid(stage_store_owner ?
                (stage_store_state==SS_READ_RSP &&
                 stage_store_rsp_valid_selected &&
                 stage_store_rsp_tile_selected==stage_store_rd_tile &&
                 !stage_store_error && !stage_store_identity_bad_selected &&
                 !writer_fault) : writer_tile_valid),
    .tile_ready(writer_tile_ready),
    .tile_f32(stage_store_owner ?
              stage_store_rsp_bits_selected : writer_tile_f32),
    .tile_n0(stage_store_owner ?
             {1'b0,stage_store_tile_count,3'b000} : writer_tile_n0),
    .tile_row_local(2'd0),.tile_row0(10'd0),.tile_batch(1'b0),
    .tile_lanes(4'd8),.mode_qkv(1'b0),
    .rearm_valid(stage_direct_active ?
                 stage_loop_state==SL_REARM : writer_rearm_valid),
    .rearm_ready(writer_rearm_ready),
    .flush_req(stage_store_owner ?
               (stage_store_state==SS_FLUSH ||
                stage_store_state==SS_ERR_DRAIN) : writer_flush_req),
    .flush_done(writer_flush_done),
    .debt_zero(writer_debt_zero),.output_base(writer_output_base),
    .output_span(writer_output_span),.fault(writer_fault),
    .aw_count(writer_aw_count),.w_count(writer_w_count),
    .b_count(writer_b_count),.useful_bytes(writer_useful_bytes),
    .physical_bytes(writer_physical_bytes),
    .m_axi_awaddr(writer_awaddr),.m_axi_awlen(writer_awlen),
    .m_axi_awsize(writer_awsize),.m_axi_awburst(writer_awburst),
    .m_axi_awvalid(writer_awvalid),.m_axi_awready(writer_awready),
    .m_axi_wdata(writer_wdata),.m_axi_wstrb(writer_wstrb),
    .m_axi_wlast(writer_wlast),.m_axi_wvalid(writer_wvalid),
    .m_axi_wready(writer_wready),.m_axi_bresp(writer_bresp),
    .m_axi_bvalid(writer_bvalid),.m_axi_bready(writer_bready)
  );
endmodule
