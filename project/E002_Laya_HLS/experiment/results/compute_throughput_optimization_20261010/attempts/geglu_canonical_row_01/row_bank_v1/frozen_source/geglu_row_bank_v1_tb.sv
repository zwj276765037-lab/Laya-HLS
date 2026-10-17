`timescale 1ns/1ps
module geglu_row_bank_v1_tb;
 reg clk=0;always #3.333333 clk=~clk;
 reg wr_en=0,rd_en=0;
 reg [11:0] wr_addr=0,rd_addr=0;
 reg [31:0] wr_data[0:2];wire [31:0] q[0:2];
 reg [31:0] expected[0:2][0:2623],held[0:2],sample[0:2],before_change[0:2];
 reg known=0;integer reads=0,writes=0,concurrent=0,holds=0,i,l;
 genvar lane;
 generate for(lane=0;lane<3;lane=lane+1)begin:banks
  geglu_row_bank_v1 dut(.clk(clk),.wr_en(wr_en),.wr_addr(wr_addr),.wr_data(wr_data[lane]),
   .rd_en(rd_en),.rd_addr(rd_addr),.q(q[lane]));
 end endgenerate
 function automatic [31:0] pattern(input integer bank,input integer addr,input integer pass);
  pattern=32'hb65c321f ^ (bank*32'h13298765) ^ (addr*32'h01002013) ^ (pass*32'h7f45a921);
 endfunction
 always @(posedge clk)begin
  if(rd_en && rd_addr>=2624 || wr_en && wr_addr>=2624)$fatal(1,"BANK_ADDRESS_RANGE");
  if(rd_en && wr_en && rd_addr==wr_addr)$fatal(1,"BANK_SAME_ADDRESS_TEST");
  for(integer k=0;k<3;k=k+1)begin
   held[k]=q[k];if(rd_en)sample[k]=expected[k][rd_addr];
   if(wr_en)expected[k][wr_addr]=wr_data[k];
  end
  #1;
  for(integer k=0;k<3;k=k+1)begin
   if(rd_en && q[k]!==sample[k])$fatal(1,"BANK_SYNCHRONOUS_RETURN bank=%0d addr=%0d",k,rd_addr);
   if(!rd_en && known && q[k]!==held[k])$fatal(1,"BANK_Q_HOLD bank=%0d",k);
  end
  if(rd_en)begin known=1;reads=reads+3;end
  if(wr_en)writes=writes+3;
  if(rd_en && wr_en)concurrent=concurrent+3;
  if(!rd_en && known)holds=holds+1;
 end
 initial begin
  // Fill every physical address independently in all three banks.
  for(i=0;i<2624;i=i+1)begin
   @(negedge clk);wr_en=1;wr_addr=i;for(l=0;l<3;l=l+1)wr_data[l]=pattern(l,i,0);
  end
  @(negedge clk);wr_en=0;
  for(i=0;i<2624;i=i+1)begin
   @(negedge clk);for(l=0;l<3;l=l+1)before_change[l]=q[l];rd_en=1;rd_addr=i;
   #1;if(known)for(l=0;l<3;l=l+1)if(q[l]!==before_change[l])$fatal(1,"BANK_ASYNCHRONOUS_READ");
  end
  @(negedge clk);rd_en=0;repeat(31)@(negedge clk);
  // Concurrent non-same-address reads/writes with deterministic read bubbles.
  for(i=0;i<2624;i=i+1)begin
   @(negedge clk);rd_en=1;wr_en=1;rd_addr=i;wr_addr=(i+1)%2624;
   for(l=0;l<3;l=l+1)wr_data[l]=pattern(l,(i+1)%2624,1);
   if((i%17)==0)begin @(negedge clk);rd_en=0;wr_en=0;end
  end
  @(negedge clk);wr_en=0;rd_en=0;repeat(19)@(negedge clk);
  for(i=0;i<2624;i=i+1)begin @(negedge clk);rd_en=1;rd_addr=i;end
  @(negedge clk);rd_en=0;repeat(7)@(negedge clk);
  if(reads!=23616 || writes!=15744 || concurrent!=7872 || holds<200)$fatal(1,"BANK_COVERAGE");
  $display("TANH_PROGRESS bank_read_checks=%0d writes=%0d concurrent=%0d holds=%0d",reads,writes,concurrent,holds);
  $display("GEGLU_ROW_BANK_V1_PASS banks=3 words_per_bank=2624 read_checks=%0d writes=%0d concurrent=%0d holds=%0d synchronous=1 no_payload_or_q_reset=1",reads,writes,concurrent,holds);
  $finish;
 end
endmodule
