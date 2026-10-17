`timescale 1ns/1ps

// Single command owner for the HLS AXI-Lite control interface. The host gives
// one observed address; this controller writes that exact shadow value into
// the generated HLS pointer register, then initializes the trace context and
// only then starts HLS. Register offsets are supplied by the generated-wrapper
// parser, which rejects missing/high-word or drifted registers.
module tm1tn8_hls_control #(
  parameter int ARG_ADDR_W=16,
  parameter logic [ARG_ADDR_W-1:0] ADDR_DESCRIPTOR_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_DESCRIPTOR_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_Q0_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_Q0_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_Q1_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_Q1_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_SCALE_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_W_SCALE_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_AUX_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_AUX_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_ACTIVATION_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_ACTIVATION_HI=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_OBSERVED_LO=0,
  parameter logic [ARG_ADDR_W-1:0] ADDR_OBSERVED_HI=0
) (
  input  logic clk,
  input  logic rst_n,
  input  logic command_start,
  output logic command_ready,
  output logic command_done,
  output logic command_fault,
  input  logic [63:0] descriptor_base,
  input  logic [63:0] w_q0_base,
  input  logic [63:0] w_q1_base,
  input  logic [63:0] w_scale_base,
  input  logic [63:0] aux_base,
  input  logic [63:0] activation_base,
  input  logic [63:0] observed_base,
  input  logic [63:0] observed_span,
  output logic [63:0] active_observed_base,
  output logic [63:0] active_observed_span,
  output logic trace_command_start,
  input  logic all_writer_debt_zero,
  input  logic hls_axi_debt_zero,
  output logic [ARG_ADDR_W-1:0] arg_awaddr,
  output logic arg_awvalid,
  input  logic arg_awready,
  output logic [31:0] arg_wdata,
  output logic [3:0] arg_wstrb,
  output logic arg_wvalid,
  input  logic arg_wready,
  input  logic [1:0] arg_bresp,
  input  logic arg_bvalid,
  output logic arg_bready,
  output logic [ARG_ADDR_W-1:0] arg_araddr,
  output logic arg_arvalid,
  input  logic arg_arready,
  input  logic [31:0] arg_rdata,
  input  logic [1:0] arg_rresp,
  input  logic arg_rvalid,
  output logic arg_rready,
  output logic [3:0] ctrl_awaddr,
  output logic ctrl_awvalid,
  input  logic ctrl_awready,
  output logic [31:0] ctrl_wdata,
  output logic [3:0] ctrl_wstrb,
  output logic ctrl_wvalid,
  input  logic ctrl_wready,
  input  logic [1:0] ctrl_bresp,
  input  logic ctrl_bvalid,
  output logic ctrl_bready,
  output logic [3:0] ctrl_araddr,
  output logic ctrl_arvalid,
  input  logic ctrl_arready,
  input  logic [31:0] ctrl_rdata,
  input  logic [1:0] ctrl_rresp,
  input  logic ctrl_rvalid,
  output logic ctrl_rready
);
  typedef enum logic [2:0] {IDLE, AW, W, B, TRACE, AR, R, DRAIN} state_t;
  state_t state;
  logic [3:0] word_index;
  logic [63:0] pointer [0:6];
  logic ap_started;

  function automatic logic [ARG_ADDR_W-1:0] word_address(input logic [3:0] i);
    case (i)
      0: return ADDR_DESCRIPTOR_LO;
      1: return ADDR_DESCRIPTOR_HI;
      2: return ADDR_W_Q0_LO;
      3: return ADDR_W_Q0_HI;
      4: return ADDR_W_Q1_LO;
      5: return ADDR_W_Q1_HI;
      6: return ADDR_W_SCALE_LO;
      7: return ADDR_W_SCALE_HI;
      8: return ADDR_AUX_LO;
      9: return ADDR_AUX_HI;
      10: return ADDR_ACTIVATION_LO;
      11: return ADDR_ACTIVATION_HI;
      12: return ADDR_OBSERVED_LO;
      13: return ADDR_OBSERVED_HI;
      default: return '0; // HLS ap_ctrl address
    endcase
  endfunction
  assign command_ready = state == IDLE && all_writer_debt_zero &&
                         hls_axi_debt_zero;
  assign arg_awaddr = word_address(word_index);
  assign arg_awvalid = state == AW && word_index != 14;
  assign arg_wdata = word_index == 14 ? 32'd0 :
                     word_index[0] ? pointer[word_index >> 1][63:32] :
                                     pointer[word_index >> 1][31:0];
  assign arg_wstrb = 4'hf;
  assign arg_wvalid = state == W && word_index != 14;
  assign arg_bready = state == B && word_index != 14;
  assign arg_araddr = '0;
  assign arg_arvalid = 0;
  assign arg_rready = 1;
  assign ctrl_awaddr = 0;
  assign ctrl_awvalid = state == AW && word_index == 14;
  assign ctrl_wdata = 32'd1;
  assign ctrl_wstrb = 4'hf;
  assign ctrl_wvalid = state == W && word_index == 14;
  assign ctrl_bready = state == B && word_index == 14;
  assign ctrl_araddr = 0;
  assign ctrl_arvalid = state == AR;
  assign ctrl_rready = state == R;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      word_index <= 0;
      active_observed_base <= 0;
      active_observed_span <= 0;
      command_done <= 0;
      command_fault <= 0;
      trace_command_start <= 0;
      ap_started <= 0;
      for (int i=0; i<7; i++) pointer[i] <= 0;
    end else begin
      command_done <= 0;
      trace_command_start <= 0;
      case (state)
        IDLE: if (command_start && command_ready) begin
          command_fault <= 0;
          ap_started <= 0;
          if (observed_base[1:0] != 0 ||
              observed_span < 64'd131072 ||
              observed_base > 64'hffff_ffff_ffff_ffff-observed_span) begin
            command_fault <= 1;
            command_done <= 1;
          end else begin
            pointer[0] <= descriptor_base;
            pointer[1] <= w_q0_base;
            pointer[2] <= w_q1_base;
            pointer[3] <= w_scale_base;
            pointer[4] <= aux_base;
            pointer[5] <= activation_base;
            pointer[6] <= observed_base;
            active_observed_base <= observed_base;
            active_observed_span <= observed_span;
            word_index <= 0;
            state <= AW;
          end
        end
        AW: if (word_index == 14 ? ctrl_awready : arg_awready)
          state <= W;
        W: if (word_index == 14 ? ctrl_wready : arg_wready)
          state <= B;
        B: if (word_index == 14 ? ctrl_bvalid : arg_bvalid) begin
          if (word_index == 14 ? ctrl_bresp != 0 : arg_bresp != 0) begin
            command_fault <= 1;
            command_done <= 1;
            state <= IDLE;
          end else if (word_index == 13) state <= TRACE;
          else if (word_index == 14) begin
            ap_started <= 1;
            state <= AR;
          end else begin
            word_index <= word_index + 1'b1;
            state <= AW;
          end
        end
        TRACE: begin
          trace_command_start <= 1;
          word_index <= 14;
          state <= AW;
        end
        AR: if (ctrl_arready) state <= R;
        R: if (ctrl_rvalid) begin
          if (ctrl_rresp != 0) begin
            command_fault <= 1;
            command_done <= 1;
            state <= IDLE;
          end else if (ctrl_rdata[1]) state <= DRAIN;
          else state <= AR;
        end
        DRAIN: if (all_writer_debt_zero && hls_axi_debt_zero) begin
          command_done <= 1;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
