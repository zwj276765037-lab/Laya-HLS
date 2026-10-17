`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_qkv_s128_request_v1 (
  input logic clk, rst_n,
  input logic request_valid,
  output logic request_ready,
  input logic request_staged_ln,
  input logic [31:0] request_base_cmd_id,
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
  output logic request_done_valid,
  input logic request_done_ready,
  output logic [3:0] request_done_status,
  output logic [3:0] request_done_phase,
  output logic result_mode,
  output logic [6:0] result_row,
  output logic [31:0] request_done_bad_element,
  output logic [7:0] request_done_op,
  output logic [15:0] request_done_check_status,
  output logic [31:0] request_done_detail,
  output logic [63:0] request_done_bad64,
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
  output logic aux_rready,
  input logic [31:0] cmd_tensor_epoch,
  input logic [2:0][31:0] cmd_dst_epoch,
  input logic [2:0][63:0] cmd_dst_base, cmd_dst_span,
  input logic [63:0] cmd_rope_aux_base, cmd_rope_aux_span,
  input logic [63:0] cmd_state0_base, cmd_state0_span,
  input logic [31:0] cmd_state0_epoch,
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
  output logic [31:0] request_done_id,
  output logic [6:0] request_done_row,
  input logic tensor_release_valid,
  output logic tensor_release_ready,
  input logic tensor_release_discard,
  input logic [31:0] tensor_release_epoch,
  input logic [63:0] tensor_release_request, tensor_release_generation,
  output logic tensor_raw_valid,
  output logic tensor_rope_enable,
  output logic [127:0] row_final,
  output logic tensor_final_valid,
  output logic [2:0][31:0] tensor_final_dst_epoch,
  output logic [127:0] row_written,
  output logic [127:0] norm_written,
  output logic norm_stage_ready,
  output logic tensor_failed,
  output logic [31:0] tensor_epoch,
  output logic [63:0] tensor_request, tensor_generation,
  output logic [3327:0] tensor_model_identity,
  output logic [671:0] tensor_numeric_identity,
  output logic [2:0][31:0] tensor_dst_epoch,
  output logic [2:0][63:0] tensor_dst_base, tensor_dst_span,
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
  output logic [2:0] m_axi_bready,
  output logic [2:0][31:0] scratch_aw_count, scratch_w_count,
  output logic [2:0][31:0] scratch_b_count,
  output logic [9:0] scratch_rsp_count,
  output logic [5:0] scratch_flush_count,
  output logic [1:0] scratch_error_dst,
  output logic [31:0] scratch_error_ordinal,
  output logic [1:0] scratch_error_bresp,
  output logic request_done_rope_check_valid,
  output logic [127:0] request_done_rope_check,
  output logic [3:0] request_done_rope_head,
  output logic request_done_rope_plane,
  output logic [1:0][63:0] rope_araddr,
  output logic [1:0][7:0] rope_arlen,
  output logic [1:0][2:0] rope_arsize,
  output logic [1:0][1:0] rope_arburst,
  output logic [1:0] rope_arvalid,
  input logic [1:0] rope_arready,
  input logic [1:0][511:0] rope_rdata,
  input logic [1:0][1:0] rope_rresp,
  input logic [1:0] rope_rlast, rope_rvalid,
  output logic [1:0] rope_rready
);

  typedef enum logic [2:0] {
    S_IDLE, S_SEND, S_ROW, S_PUBLISH, S_DONE, S_STAGE_READY
  } state_t;
  state_t state;
  logic [7:0] retired_rows;
  logic [31:0] base_id;
  logic q_staged_ln, row_norm_stage_ready;
  logic [127:0] row_norm_written;
  logic [7:0] row_done_op;
  logic [15:0] row_done_check_status;
  logic [31:0] row_done_detail;
  logic [63:0] row_done_bad64;
  logic [31:0] q_w_epoch, q_down_w_epoch, q_tensor_epoch;
  logic [15:0] q_weight_key, q_down_weight_key;
  logic [3327:0] q_model_identity;
  logic [671:0] q_numeric_identity;
  logic [95:0] q_task_context;
  logic [1023:0] q_expected_aux_header, q_down_expected_aux_header;
  logic [2:0][63:0] q_load_base, q_down_load_base;
  logic [2:0][31:0] q_load_bytes, q_down_load_bytes;
  logic [63:0] q_aux_base, q_bias_base, q_down_aux_base, q_down_bias_base;
  logic [31:0] q_bias_bytes, q_down_bias_bytes;
  logic [2:0][31:0] q_dst_epoch;
  logic [2:0][63:0] q_dst_base, q_dst_span;
  logic [63:0] q_rope_aux_base, q_rope_aux_span;
  logic [63:0] q_state0_base, q_state0_span;
  logic [31:0] q_state0_epoch;
  logic row_cmd_ready, row_done_valid;
  logic [3:0] row_done_status, row_done_phase;
  logic [31:0] row_done_bad, row_done_id;
  logic row_done_check_valid, row_done_plane;
  logic [127:0] row_done_check;
  logic [3:0] row_done_head;
  logic inner_release_ready;
  wire [32:0] end_id={1'b0,request_base_cmd_id}+33'd127;
  wire [64:0] state0_limit={1'b0,cmd_state0_base}+{1'b0,cmd_state0_span};
  wire [64:0] aux_limit={1'b0,cmd_rope_aux_base}+{1'b0,cmd_rope_aux_span};
  function automatic logic safe_range(input logic [63:0] base, span,
                                      input logic [63:0] required_span);
    logic [64:0] limit;
    begin
      limit={1'b0,base}+{1'b0,span};
      return base[5:0]==0 && span>=required_span && !limit[64];
    end
  endfunction
  function automatic logic safe_add(input logic [63:0] base,
                                    input logic [63:0] size_bytes);
    logic [64:0] limit;
    begin
      limit={1'b0,base}+{1'b0,size_bytes};
      return base[5:0]==0 && !limit[64];
    end
  endfunction
  wire descriptor_ok=request_base_cmd_id!=0 && !end_id[32] &&
      cmd_w_epoch!=0 && cmd_weight_key==16'h0001 &&
      cmd_tensor_epoch!=0 && cmd_tensor_epoch!=32'hffffffff &&
      cmd_state0_epoch==cmd_tensor_epoch &&
      cmd_task_context[31:0]!=0 &&
      cmd_state0_base[5:0]==0 && cmd_state0_span>=64'd8388608 &&
      !state0_limit[64] &&
      cmd_rope_aux_base[3:0]==0 &&
      cmd_rope_aux_span>=64'd1142528 && !aux_limit[64] &&
      cmd_aux_base[3:0]==0 &&
      safe_add(cmd_load_base[0],64'd1572864) &&
      safe_add(cmd_load_base[1],64'd1572864) &&
      safe_add(cmd_load_base[2],64'd196608) &&
      cmd_load_bytes[0]==32'd1572864 &&
      cmd_load_bytes[1]==32'd1572864 &&
      cmd_load_bytes[2]==32'd196608 && cmd_bias_bytes==0 &&
      cmd_dst_epoch[0]==cmd_tensor_epoch &&
      cmd_dst_epoch[1]==cmd_tensor_epoch &&
      cmd_dst_epoch[2]==cmd_tensor_epoch &&
      safe_range(cmd_dst_base[0],cmd_dst_span[0],64'd12582912) &&
      safe_range(cmd_dst_base[1],cmd_dst_span[1],64'd12582912) &&
      safe_range(cmd_dst_base[2],cmd_dst_span[2],64'd8388608);
  wire [31:0] row_id=base_id+{24'd0,retired_rows};
  // The context row field is 16 bits, with the current 7-bit row in low bits.
  wire [95:0] actual_row_context=
      {8'd1,9'd0,retired_rows[6:0],8'd128,
       32'h01000001,q_task_context[31:0]};
  assign request_ready=state==S_IDLE && tensor_epoch==0 &&
      !tensor_release_valid;
  assign request_done_valid=state==S_DONE;
  assign norm_written=row_norm_written;
  assign norm_stage_ready=state==S_STAGE_READY &&
      row_norm_stage_ready && &row_norm_written &&
      !tensor_failed && !tensor_final_valid && !tensor_raw_valid;
  assign tensor_release_ready=(state==S_IDLE || state==S_STAGE_READY) &&
      inner_release_ready;

  laya_qkv_scratch_row_v1 row_engine (
    .*, .cmd_staged_ln(q_staged_ln),
    .norm_written(row_norm_written),
    .norm_stage_ready(row_norm_stage_ready),
    .done_op(row_done_op), .done_check_status(row_done_check_status),
    .done_detail(row_done_detail), .done_bad64(row_done_bad64),
    .cmd_valid(state==S_SEND), .cmd_ready(row_cmd_ready),
    .cmd_id(row_id), .cmd_cold(!q_staged_ln && retired_rows==0),
    .cmd_mode(1'b1), .cmd_row(retired_rows[6:0]),
    .cmd_w_epoch(q_w_epoch), .cmd_weight_key(q_weight_key),
    .cmd_model_identity(q_model_identity),
    .cmd_numeric_identity(q_numeric_identity),
    .cmd_task_context(actual_row_context),
    .cmd_expected_aux_header(q_expected_aux_header),
    .cmd_load_base(q_load_base),.cmd_load_bytes(q_load_bytes),
    .cmd_aux_base(q_aux_base),.cmd_bias_base(q_bias_base),
    .cmd_bias_bytes(q_bias_bytes),
    .cmd_down_w_epoch(q_down_w_epoch),
    .cmd_down_weight_key(q_down_weight_key),
    .cmd_down_expected_aux_header(q_down_expected_aux_header),
    .cmd_down_load_base(q_down_load_base),
    .cmd_down_load_bytes(q_down_load_bytes),
    .cmd_down_aux_base(q_down_aux_base),
    .cmd_down_bias_base(q_down_bias_base),
    .cmd_down_bias_bytes(q_down_bias_bytes),
    .cmd_tensor_begin(retired_rows==0),
    .cmd_tensor_epoch(q_tensor_epoch),.cmd_dst_epoch(q_dst_epoch),
    .cmd_dst_base(q_dst_base),.cmd_dst_span(q_dst_span),
    .cmd_source_hidden_bank(1'b0),.cmd_rope_enable(1'b1),
    .cmd_rope_aux_base(q_rope_aux_base),
    .cmd_rope_aux_span(q_rope_aux_span),
    .cmd_input_from_state0(1'b1),
    .cmd_state0_base(q_state0_base),.cmd_state0_span(q_state0_span),
    .cmd_state0_epoch(q_state0_epoch),
    .tensor_release_valid((state==S_IDLE || state==S_STAGE_READY) &&
                          tensor_release_valid),
    .tensor_release_ready(inner_release_ready),
    .done_valid(row_done_valid),.done_ready(state==S_ROW),
    .done_status(row_done_status),.done_phase(row_done_phase),
    .done_bad_element(row_done_bad),.done_id(row_done_id),
    .done_rope_check_valid(row_done_check_valid),
    .done_rope_check(row_done_check),
    .done_rope_head(row_done_head),.done_rope_plane(row_done_plane)
  );
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      state<=S_IDLE;retired_rows<=0;base_id<=0;q_staged_ln<=0;
      request_done_status<=0;request_done_phase<=4'd7;
      request_done_bad_element<=32'hffffffff;
      request_done_op<=0;request_done_check_status<=0;
      request_done_detail<=0;
      request_done_bad64<=64'hffff_ffff_ffff_ffff;
      request_done_id<=0;request_done_row<=0;
      request_done_rope_check_valid<=0;
      request_done_rope_check<=0;request_done_rope_head<=0;
      request_done_rope_plane<=0;
    end else case(state)
      S_IDLE:if(request_valid && request_ready)begin
        retired_rows<=0;base_id<=request_base_cmd_id;
        q_staged_ln<=request_staged_ln;
        q_w_epoch<=cmd_w_epoch;q_down_w_epoch<=cmd_down_w_epoch;
        q_weight_key<=cmd_weight_key;
        q_down_weight_key<=cmd_down_weight_key;
        q_model_identity<=cmd_model_identity;
        q_numeric_identity<=cmd_numeric_identity;
        q_task_context<=cmd_task_context;
        q_expected_aux_header<=cmd_expected_aux_header;
        q_down_expected_aux_header<=cmd_down_expected_aux_header;
        q_load_base<=cmd_load_base;q_load_bytes<=cmd_load_bytes;
        q_aux_base<=cmd_aux_base;q_bias_base<=cmd_bias_base;
        q_bias_bytes<=cmd_bias_bytes;
        q_down_load_base<=cmd_down_load_base;
        q_down_load_bytes<=cmd_down_load_bytes;
        q_down_aux_base<=cmd_down_aux_base;
        q_down_bias_base<=cmd_down_bias_base;
        q_down_bias_bytes<=cmd_down_bias_bytes;
        q_tensor_epoch<=cmd_tensor_epoch;
        q_dst_epoch<=cmd_dst_epoch;
        q_dst_base<=cmd_dst_base;q_dst_span<=cmd_dst_span;
        q_rope_aux_base<=cmd_rope_aux_base;
        q_rope_aux_span<=cmd_rope_aux_span;
        q_state0_base<=cmd_state0_base;
        q_state0_span<=cmd_state0_span;
        q_state0_epoch<=cmd_state0_epoch;
        request_done_rope_check_valid<=0;
        request_done_rope_check<=0;
        request_done_rope_head<=0;
        request_done_rope_plane<=0;
        if(!descriptor_ok)begin
          request_done_status<=4'd7;
          request_done_phase<=4'd14;
          request_done_bad_element<=32'hffffffff;
          request_done_op<=request_staged_ln ? 8'h10 : 8'h00;
          request_done_check_status<=16'd7;
          request_done_detail<=request_staged_ln ? 32'h0710_0005 : 0;
          request_done_bad64<=64'hffff_ffff_ffff_ffff;
          request_done_id<=request_base_cmd_id;
          request_done_row<=0;
          state<=S_DONE;
        end else state<=S_SEND;
      end
      S_SEND:if(row_cmd_ready)state<=S_ROW;
      S_ROW:if(row_done_valid)begin
        request_done_id<=row_done_id;
        request_done_row<=retired_rows[6:0];
        request_done_status<=row_done_status;
        request_done_phase<=row_done_phase;
        request_done_bad_element<=row_done_bad;
        request_done_op<=row_done_op;
        request_done_check_status<=row_done_check_status;
        request_done_detail<=row_done_detail;
        request_done_bad64<=row_done_bad64;
        request_done_rope_check_valid<=row_done_check_valid;
        request_done_rope_check<=row_done_check;
        request_done_rope_head<=row_done_head;
        request_done_rope_plane<=row_done_plane;
        if(row_done_status!=0)state<=S_DONE;
        else if(retired_rows==8'd127)begin
          retired_rows<=8'd128;
          state<=q_staged_ln ? S_STAGE_READY : S_PUBLISH;
        end else begin
          retired_rows<=retired_rows+1'b1;
          state<=S_SEND;
        end
      end
      S_PUBLISH:if(tensor_final_valid && &row_written && &row_final &&
                    !tensor_failed)begin
        request_done_status<=0;
        request_done_phase<=4'd7;
        request_done_bad_element<=32'hffffffff;
        state<=S_DONE;
      end
      S_DONE:if(request_done_ready)state<=S_IDLE;
      S_STAGE_READY:if(tensor_release_valid && inner_release_ready &&
                       tensor_release_discard)state<=S_IDLE;
      default:state<=S_IDLE;
    endcase
  end
endmodule
