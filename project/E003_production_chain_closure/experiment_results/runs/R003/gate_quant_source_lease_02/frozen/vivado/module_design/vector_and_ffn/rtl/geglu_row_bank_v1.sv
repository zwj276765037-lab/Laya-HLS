// §8.4.10: 2624 F32 words, one synchronous read and one synchronous write.
// Payload and q intentionally have no reset; the adapter owns valid/generation.
module geglu_row_bank_v1(
 input wire clk,
 input wire wr_en,input wire [11:0] wr_addr,input wire [31:0] wr_data,
 input wire rd_en,input wire [11:0] rd_addr,output reg [31:0] q
);
 (* ram_style="block" *) reg [31:0] mem[0:2623];
 always @(posedge clk) begin
  if(wr_en)mem[wr_addr]<=wr_data;
  if(rd_en)q<=mem[rd_addr];
 end
endmodule
