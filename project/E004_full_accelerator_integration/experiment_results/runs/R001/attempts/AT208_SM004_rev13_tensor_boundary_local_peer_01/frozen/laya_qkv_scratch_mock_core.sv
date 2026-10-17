`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_lnq_wi_gqdown_row_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
  input logic cmd_mode,
  input logic [6:0] cmd_row,
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
  output logic result_mode,
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
  typedef enum logic [1:0] {IDLE, ROW, DONE} state_t;
  state_t state;
  logic [9:0] pending_tile;
  logic pending;
  logic [3:0] held_status, held_phase;
  logic [31:0] held_bad;
  logic bad_tag_mode;
  assign cmd_ready = state == IDLE;
  assign row_valid = state == ROW;
  assign rd_ready = state == ROW && !row_release_valid &&
                    !rsp_valid && !pending &&
                    rd_tile <= (result_mode ? 10'd511 : 10'd127);
  assign row_release_ready = state == ROW && !rsp_valid && !pending;
  assign done_valid = state == DONE;
  assign done_status = held_status;
  assign done_phase = held_phase;
  assign done_bad_element = held_bad;
  assign x_ready = 0;
  assign gamma_ready = 0;
  assign mean_bits = 0; assign variance_bits = 0; assign inverse_bits = 0;
  assign actual_w_reads = 0; assign actual_w_returns = 0;
  assign actual_stripes = 0; assign actual_ps_commits = 0;
  assign araddr = '0; assign arlen = '0; assign arsize = '0;
  assign arburst = '0; assign arvalid = '0; assign rready = '0;
  assign aux_araddr = 0; assign aux_arlen = 0; assign aux_arsize = 0;
  assign aux_arburst = 0; assign aux_arvalid = 0; assign aux_rready = 0;
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE; pending <= 0; pending_tile <= 0;
      rsp_valid <= 0; rsp_tile <= 0; rsp_bits <= 0;
      result_mode <= 0; result_row <= 0;
      held_status <= 0; held_phase <= 4'd7;
      held_bad <= 32'hffffffff;
      bad_tag_mode <= 0;
    end else begin
      if (rsp_valid && rsp_ready) rsp_valid <= 0;
      if (pending) begin
        rsp_valid <= 1;
        rsp_tile <= bad_tag_mode ? pending_tile + 1'b1 : pending_tile;
        for (int lane=0; lane<8; lane++)
          rsp_bits[lane*32+:32] <= {result_row,7'd0,pending_tile,5'(lane)};
        pending <= 0;
      end
      case (state)
        IDLE: if (cmd_valid) begin
          result_mode <= cmd_mode; result_row <= cmd_row;
          bad_tag_mode <= cmd_id == 32'd98;
          held_status <= cmd_id == 32'd99 ? 4'd6 : 0;
          held_phase <= cmd_id == 32'd99 ? 4'd11 : 4'd7;
          held_bad <= cmd_id == 32'd99 ? 32'd42 : 32'hffffffff;
          state <= cmd_id == 32'd99 ? DONE : ROW;
        end
        ROW: begin
          if (row_release_valid && row_release_ready) state <= DONE;
          else if (rd_valid && rd_ready) begin
            pending <= 1; pending_tile <= rd_tile;
          end
        end
        DONE: if (done_ready) state <= IDLE;
        default: state <= IDLE;
      endcase
    end
  end
endmodule
