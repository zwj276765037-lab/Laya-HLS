`timescale 1ns/1ps
// Tests the exact 32 PS and four metadata bank bodies; no payload reset.
module tm4tn8_sync_banks_tb_v2(input logic clk,output logic done);
  logic rd_en=0,wr_en=0;
  logic [9:0] rd_addr=0,wr_addr=0;
  logic second_pattern=0;
  logic [31:0] q[0:31],d[0:31];
  logic [15:0] mq[0:3],md[0:3];
  function automatic logic[31:0] pattern(input int bank,input int addr,input bit second);
    return 32'h012389ab ^ (32'(bank)*32'h009db187) ^
           (32'(addr)*32'h800127bd) ^ (second ? 32'hfb743f01 : 32'd0);
  endfunction
  function automatic logic[15:0] metadata(input int row,input int addr,input bit second);
    return {8'(row*13+addr+(second ? 97 : 0)),8'(addr)};
  endfunction
  for(genvar b=0;b<32;b++)begin:ps
    assign d[b]=pattern(b,int'(wr_addr),second_pattern);
    tm4tn8_sync_bank_v2 bank(.clk,.rd_en,.rd_addr,.rd_data(q[b]),
      .wr_en,.wr_addr,.wr_data(d[b]));
  end
  for(genvar r=0;r<4;r++)begin:meta
    assign md[r]=metadata(r,int'(wr_addr),second_pattern);
    tm4tn8_sync_bank_v2 #(.WIDTH(16)) bank(.clk,.rd_en,.rd_addr,.rd_data(mq[r]),
      .wr_en,.wr_addr,.wr_data(md[r]));
  end
  task automatic check(input int addr,input bit second);
    for(int b=0;b<32;b++)if(q[b]!==pattern(b,addr,second))
      $fatal(1,"sync PS bank %0d address %0d got=%h",b,addr,q[b]);
    for(int r=0;r<4;r++)if(mq[r]!==metadata(r,addr,second))
      $fatal(1,"sync metadata bank %0d address %0d got=%h",r,addr,mq[r]);
  endtask
  initial begin
    done=0;
    @(negedge clk);
    wr_en=1;
    for(int a=0;a<656;a++)begin wr_addr=10'(a);@(negedge clk);end
    rd_en=1;second_pattern=1;
    for(int a=0;a<656;a++)begin
      rd_addr=10'(a);wr_addr=10'(a==655 ? 0 : a+1);
      #1ps;
      if(a>0)check(a-1,a-1!=0);
      @(negedge clk);check(a,a!=0);
    end
    rd_en=0;wr_en=0;
    repeat(4)begin @(negedge clk);check(655,1);end
    rd_en=1;
    for(int a=0;a<656;a++)begin rd_addr=10'(a);@(negedge clk);check(a,1);end
    if(mq[0][7:0]!==8'(655))$fatal(1,"metadata eight-bit progress");
    rd_addr=127;@(negedge clk);if(mq[0][7:0]!==8'd127)$fatal(1,"metadata g127");
    rd_addr=128;@(negedge clk);if(mq[0][7:0]!==8'd128)$fatal(1,"metadata progress128");
    rd_en=0;done=1;
    $display("TM4_SYNC_BANKS_PASS banks32=1 metadata4=1 depth=656 read_checks=47232 concurrent_different_address=656 no_payload_reset=1 held_q=4 progress128=1");
  end
endmodule
