`timescale 1ns/1ps

// One original HLS tanh leaf behind a single-entry response reservation.
// The leaf has ap_done high while idle, so only active ap_ready retires a call.
module tanh_service_wrapper (
    input  logic        clk,
    input  logic        rst,
    input  logic        in_valid,
    output logic        in_ready,
    input  logic [31:0] in_bits,
    input  logic [31:0] in_tag,
    output logic        out_valid,
    input  logic        out_ready,
    output logic [31:0] out_bits,
    output logic [31:0] out_tag
);
  logic busy;
  logic [31:0] active_tag;
  logic [31:0] active_bits;
  wire leaf_start = in_valid && in_ready;
  wire leaf_done, leaf_idle, leaf_ready;
  wire [31:0] leaf_result;

  assign in_ready = !rst && !busy && (!out_valid || out_ready);

  laya_typed_q8_forward_generic_tanh_float_s u_leaf (
      .ap_clk(clk), .ap_rst(rst), .ap_start(leaf_start),
      .ap_done(leaf_done), .ap_idle(leaf_idle), .ap_ready(leaf_ready),
      .t_in(leaf_start ? in_bits : active_bits), .ap_return(leaf_result)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      busy <= 1'b0;
      active_tag <= '0;
      active_bits <= '0;
      out_valid <= 1'b0;
      out_bits <= '0;
      out_tag <= '0;
    end else begin
      if (out_valid && out_ready) out_valid <= 1'b0;
      if (leaf_start) begin
        busy <= 1'b1;
        active_tag <= in_tag;
        active_bits <= in_bits;
      end
      if (busy && leaf_ready) begin
        busy <= 1'b0;
        out_valid <= 1'b1;
        out_bits <= leaf_result;
        out_tag <= active_tag;
      end
    end
  end
endmodule
