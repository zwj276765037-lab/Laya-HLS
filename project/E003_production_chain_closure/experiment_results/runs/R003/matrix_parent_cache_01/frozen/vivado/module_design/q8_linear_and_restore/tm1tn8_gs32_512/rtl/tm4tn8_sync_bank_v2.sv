`timescale 1ns/1ps
// One independent 1R1W synchronous bank. Reset belongs to lazy-valid control;
// neither payload nor the held read register is reset or cleared per command.
module tm4tn8_sync_bank_v2 #(parameter integer WIDTH=32,DEPTH=656) (
  input logic clk,
  input logic rd_en,
  input logic [9:0] rd_addr,
  output logic [WIDTH-1:0] rd_data,
  input logic wr_en,
  input logic [9:0] wr_addr,
  input logic [WIDTH-1:0] wr_data
);
  (* ram_style="block" *) logic [WIDTH-1:0] mem[0:DEPTH-1];
  always_ff @(posedge clk)begin
    if(rd_en)rd_data<=mem[rd_addr];
    if(wr_en)mem[wr_addr]<=wr_data;
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)begin
    if(rd_en)assert(rd_addr<DEPTH)else $fatal(1,"PS bank read bounds");
    if(wr_en)assert(wr_addr<DEPTH)else $fatal(1,"PS bank write bounds");
    if(rd_en && wr_en)assert(rd_addr!=wr_addr)else $fatal(1,"PS bank same-address read/write is forbidden");
  end
`endif
endmodule
