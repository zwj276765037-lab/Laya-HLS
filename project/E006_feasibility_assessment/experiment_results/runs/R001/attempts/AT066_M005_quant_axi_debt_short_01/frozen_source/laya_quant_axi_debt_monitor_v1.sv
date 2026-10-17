`timescale 1ns/1ps
// Finite monitor for the bridge's single-outstanding 64-byte AXI read port.
// It observes accepted transactions continuously across Q and G tasks.
module laya_quant_axi_debt_monitor_v1 (
  input  logic clk, rst_n,
  input  logic arvalid, arready,
  input  logic [7:0] arlen,
  input  logic rvalid, rready, rlast,
  input  logic quant_task_debt_zero,
  output logic physical_and_task_debt_zero,
  output logic [8:0] beats_remaining,
  output logic burst_in_flight,
  output logic accounting_error
);
  wire ar_fire = arvalid && arready;
  wire r_fire = rvalid && rready;
  wire [8:0] offered_beats = {1'b0, arlen} + 9'd1;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      beats_remaining <= 9'd0;
      burst_in_flight <= 1'b0;
      accounting_error <= 1'b0;
    end else if (!accounting_error) begin
      // The feeder cannot retire R while accepting a new burst. Treat an
      // unexpected simultaneous pair as a fault, never as zero net debt.
      if (ar_fire && r_fire) begin
        accounting_error <= 1'b1;
      end else if (ar_fire) begin
        if (burst_in_flight || beats_remaining != 0 || offered_beats > 9'd64)
          accounting_error <= 1'b1;
        else begin
          beats_remaining <= offered_beats;
          burst_in_flight <= 1'b1;
        end
      end else if (r_fire) begin
        if (!burst_in_flight || beats_remaining == 0 ||
            rlast != (beats_remaining == 9'd1))
          accounting_error <= 1'b1;
        else begin
          beats_remaining <= beats_remaining - 9'd1;
          if (beats_remaining == 9'd1)
            burst_in_flight <= 1'b0;
        end
      end
    end
  end

  // The last R is first reflected in registered debt on the following
  // cycle. Presented but unaccepted AR/R also block a release.
  assign physical_and_task_debt_zero = rst_n && !accounting_error &&
      !burst_in_flight && beats_remaining == 0 && !arvalid && !rvalid &&
      quant_task_debt_zero;
endmodule
