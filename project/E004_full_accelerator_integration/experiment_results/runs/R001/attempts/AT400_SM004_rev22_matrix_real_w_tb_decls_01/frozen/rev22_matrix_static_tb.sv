`timescale 1ns/1ps
module rev22_matrix_static_tb;
  logic clk=0,rst_n=0;
  laya_lnq_bank_link_v1 link();
  laya_matrix_service_v1 matrix_u(.clk(clk),.rst_n(rst_n),.bank_link(link));
  laya_source_norm_service_v1 source_u(.clk(clk),.rst_n(rst_n),.bank_link(link));
endmodule
