`timescale 1ns/1ps

// One lane of one complete F32 row slot; 16 banks form a 512-bit beat.
module quant_f32_row_bank_v1 (
  input logic clk,we,re,
  input logic [7:0] wbeat,rbeat,
  input logic [31:0] wdata,
  output logic [31:0] rdata
);
  (* ram_style = "block" *) logic [31:0] row[0:255];
  always_ff @(posedge clk) begin
    if(we) row[wbeat]<=wdata;
    if(re) rdata<=row[rbeat];
  end
endmodule
