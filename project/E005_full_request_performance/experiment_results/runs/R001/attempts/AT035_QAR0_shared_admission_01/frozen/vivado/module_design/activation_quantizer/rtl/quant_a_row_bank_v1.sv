`timescale 1ns/1ps

// One complete A row, physically split into two 128-bit q half banks.
// No payload reset. The owner parent validates group/row before enabling.
module quant_a_row_bank_v1 (
  input logic clk,
  input logic q0_we,q1_we,scale_we,
  input logic [6:0] wgroup,
  input logic [127:0] q_wdata,
  input logic [15:0] scale_wdata,
  input logic re,
  input logic [6:0] rgroup,
  output logic [255:0] q_rdata,
  output logic [15:0] scale_rdata
);
  (* ram_style = "block" *) logic [127:0] q0[0:127],q1[0:127];
  (* ram_style = "block" *) logic [15:0] scale[0:127];
  always_ff @(posedge clk) begin
    if(q0_we) q0[wgroup]<=q_wdata;
    if(re) q_rdata[127:0]<=q0[rgroup];
  end
  always_ff @(posedge clk) begin
    if(q1_we) q1[wgroup]<=q_wdata;
    if(re) q_rdata[255:128]<=q1[rgroup];
  end
  always_ff @(posedge clk) begin
    if(scale_we) scale[wgroup]<=scale_wdata;
    if(re) scale_rdata<=scale[rgroup];
  end
endmodule
