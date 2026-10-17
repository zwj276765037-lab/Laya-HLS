// One outstanding binary32 addition with a retained result.  The arithmetic
// module is the unchanged tanh_libm_round1_02 generated fp_add_bits leaf.
module laya_ffn_fadd_slot_v1 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    output logic        in_ready,
    input  logic [31:0] in_a,
    input  logic [31:0] in_b,
    output logic        out_valid,
    input  logic        out_ready,
    output logic [31:0] out_bits,
    output logic        leaf_busy,
    output logic        accepted_pulse,
    output logic        returned_pulse,
    output logic        consumed_pulse
);
  logic [31:0] a_hold, b_hold;
  logic [31:0] leaf_a, leaf_b, leaf_result;
  logic leaf_start, leaf_done, leaf_idle, leaf_ready;

  assign in_ready = !leaf_busy && !out_valid;
  assign leaf_start = in_valid && in_ready;
  assign leaf_a = leaf_busy ? a_hold : in_a;
  assign leaf_b = leaf_busy ? b_hold : in_b;
  assign accepted_pulse = leaf_start;
  assign returned_pulse = leaf_busy && leaf_done;
  assign consumed_pulse = out_valid && out_ready;

  tanh_libm_leaf_fp_add_bits fadd (
      .ap_clk(clk), .ap_rst(!rst_n), .ap_start(leaf_start),
      .ap_done(leaf_done), .ap_idle(leaf_idle), .ap_ready(leaf_ready),
      .a(leaf_a), .b(leaf_b), .ap_return(leaf_result)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      a_hold <= '0;
      b_hold <= '0;
      leaf_busy <= 1'b0;
      out_valid <= 1'b0;
      out_bits <= '0;
    end else begin
      if (leaf_start) begin
        a_hold <= in_a;
        b_hold <= in_b;
        leaf_busy <= 1'b1;
      end
      if (returned_pulse) begin
        out_bits <= leaf_result;
        out_valid <= 1'b1;
        leaf_busy <= 1'b0;
      end
      if (consumed_pulse) out_valid <= 1'b0;
    end
  end
endmodule
