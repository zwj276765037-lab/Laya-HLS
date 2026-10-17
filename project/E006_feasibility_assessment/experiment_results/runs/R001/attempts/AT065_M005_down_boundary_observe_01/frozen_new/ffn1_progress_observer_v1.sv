`timescale 1ns/1ps
// Passive, reset-once event accumulator. Each input is a count of actual
// handshakes or causally bound arithmetic retirements sampled at this edge.
module ffn1_progress_observer_v1 #(
    parameter integer FAMILIES = 35
) (
    input  logic clk,
    input  logic rst_n,
    input  logic [FAMILIES-1:0][2:0] event_inc,
    output logic [FAMILIES-1:0][63:0] counts,
    output logic [63:0] work
);
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (integer i=0; i<FAMILIES; i=i+1) counts[i] <= 64'd0;
    end else begin
      for (integer i=0; i<FAMILIES; i=i+1) begin
        if ((^event_inc[i]) === 1'bx)
          $fatal(1, "FFN1 observer unknown event family=%0d", i);
        if (event_inc[i] != 0) begin
          if (counts[i] > 64'hffffffffffffffff - {61'd0,event_inc[i]})
            $fatal(1, "FFN1 observer count overflow family=%0d", i);
          counts[i] <= counts[i] + {61'd0,event_inc[i]};
        end
      end
    end
  end
  always_comb begin
    work = 64'd0;
    for (integer i=0; i<FAMILIES; i=i+1) work = work + counts[i];
  end
endmodule
