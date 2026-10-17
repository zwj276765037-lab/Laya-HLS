`timescale 1ns/1ps
// Synthetic physical capacity/port test only. It does not certify a new shape's numerical domain.
module attention_tile_capacity_tb;
 reg ap_clk=0;always #5 ap_clk=~ap_clk;
 reg ap_rst=1,ap_ce=1,ap_start=0,ap_continue=0;
 reg [31:0] command=0,index=0,payload=0,epoch=0;
 wire ap_done,ap_idle,ap_ready,result_ap_vld,status_ap_vld;wire [31:0] result,status;
 attention_tile_service_v1 dut(.*);
 reg cap_mode=0,cap_we=0,cap_re=0;reg [11:0] cap_addr=0;integer stage=0,calls=0,checks=0;
 reg [31:0] words[0:54],id[0:20];string fixture;
 function automatic [31:0] pattern(input integer tag,addr);pattern=32'h3c000000^tag^addr;endfunction
 task automatic invoke(input integer cmd,idx,data,expected);
  while(!ap_idle)@(negedge ap_clk);command=cmd;index=idx;payload=data;epoch=201;ap_start=1;
  @(negedge ap_clk);ap_start=0;while(!ap_done)@(negedge ap_clk);
  if(status!==32'(expected)||!result_ap_vld||!status_ap_vld)$fatal(1,"Capacity command cmd=%0d idx=%0d status=%0d",cmd,idx,status);
  ap_continue=1;@(negedge ap_clk);ap_continue=0;@(negedge ap_clk);calls=calls+1;
  if(calls%16384==0)$display("ATTENTION_SERVICE_PROGRESS capacity synthetic calls=%0d",calls);
 endtask
 initial begin wait(cap_mode);force dut.banks[0].k.re=cap_re;force dut.banks[0].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[0].k.rd!==pattern(65536,cap_addr*16+0))$fatal(1,"Synthetic loaded k bank0 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].v.re=cap_re;force dut.banks[0].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[0].v.rd!==pattern(131072,cap_addr*16+0))$fatal(1,"Synthetic loaded v bank0 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].q.re=cap_re;force dut.banks[0].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[0].q.rd!==pattern(196608,cap_addr*16+0))$fatal(1,"Synthetic loaded q bank0 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].k.re=cap_re;force dut.banks[1].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[1].k.rd!==pattern(65536,cap_addr*16+1))$fatal(1,"Synthetic loaded k bank1 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].v.re=cap_re;force dut.banks[1].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[1].v.rd!==pattern(131072,cap_addr*16+1))$fatal(1,"Synthetic loaded v bank1 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].q.re=cap_re;force dut.banks[1].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[1].q.rd!==pattern(196608,cap_addr*16+1))$fatal(1,"Synthetic loaded q bank1 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].k.re=cap_re;force dut.banks[2].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[2].k.rd!==pattern(65536,cap_addr*16+2))$fatal(1,"Synthetic loaded k bank2 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].v.re=cap_re;force dut.banks[2].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[2].v.rd!==pattern(131072,cap_addr*16+2))$fatal(1,"Synthetic loaded v bank2 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].q.re=cap_re;force dut.banks[2].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[2].q.rd!==pattern(196608,cap_addr*16+2))$fatal(1,"Synthetic loaded q bank2 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].k.re=cap_re;force dut.banks[3].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[3].k.rd!==pattern(65536,cap_addr*16+3))$fatal(1,"Synthetic loaded k bank3 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].v.re=cap_re;force dut.banks[3].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[3].v.rd!==pattern(131072,cap_addr*16+3))$fatal(1,"Synthetic loaded v bank3 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].q.re=cap_re;force dut.banks[3].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[3].q.rd!==pattern(196608,cap_addr*16+3))$fatal(1,"Synthetic loaded q bank3 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].k.re=cap_re;force dut.banks[4].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[4].k.rd!==pattern(65536,cap_addr*16+4))$fatal(1,"Synthetic loaded k bank4 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].v.re=cap_re;force dut.banks[4].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[4].v.rd!==pattern(131072,cap_addr*16+4))$fatal(1,"Synthetic loaded v bank4 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].q.re=cap_re;force dut.banks[4].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[4].q.rd!==pattern(196608,cap_addr*16+4))$fatal(1,"Synthetic loaded q bank4 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].k.re=cap_re;force dut.banks[5].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[5].k.rd!==pattern(65536,cap_addr*16+5))$fatal(1,"Synthetic loaded k bank5 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].v.re=cap_re;force dut.banks[5].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[5].v.rd!==pattern(131072,cap_addr*16+5))$fatal(1,"Synthetic loaded v bank5 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].q.re=cap_re;force dut.banks[5].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[5].q.rd!==pattern(196608,cap_addr*16+5))$fatal(1,"Synthetic loaded q bank5 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].k.re=cap_re;force dut.banks[6].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[6].k.rd!==pattern(65536,cap_addr*16+6))$fatal(1,"Synthetic loaded k bank6 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].v.re=cap_re;force dut.banks[6].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[6].v.rd!==pattern(131072,cap_addr*16+6))$fatal(1,"Synthetic loaded v bank6 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].q.re=cap_re;force dut.banks[6].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[6].q.rd!==pattern(196608,cap_addr*16+6))$fatal(1,"Synthetic loaded q bank6 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].k.re=cap_re;force dut.banks[7].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[7].k.rd!==pattern(65536,cap_addr*16+7))$fatal(1,"Synthetic loaded k bank7 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].v.re=cap_re;force dut.banks[7].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[7].v.rd!==pattern(131072,cap_addr*16+7))$fatal(1,"Synthetic loaded v bank7 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].q.re=cap_re;force dut.banks[7].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[7].q.rd!==pattern(196608,cap_addr*16+7))$fatal(1,"Synthetic loaded q bank7 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].k.re=cap_re;force dut.banks[8].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[8].k.rd!==pattern(65536,cap_addr*16+8))$fatal(1,"Synthetic loaded k bank8 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].v.re=cap_re;force dut.banks[8].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[8].v.rd!==pattern(131072,cap_addr*16+8))$fatal(1,"Synthetic loaded v bank8 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].q.re=cap_re;force dut.banks[8].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[8].q.rd!==pattern(196608,cap_addr*16+8))$fatal(1,"Synthetic loaded q bank8 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].k.re=cap_re;force dut.banks[9].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[9].k.rd!==pattern(65536,cap_addr*16+9))$fatal(1,"Synthetic loaded k bank9 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].v.re=cap_re;force dut.banks[9].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[9].v.rd!==pattern(131072,cap_addr*16+9))$fatal(1,"Synthetic loaded v bank9 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].q.re=cap_re;force dut.banks[9].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[9].q.rd!==pattern(196608,cap_addr*16+9))$fatal(1,"Synthetic loaded q bank9 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].k.re=cap_re;force dut.banks[10].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[10].k.rd!==pattern(65536,cap_addr*16+10))$fatal(1,"Synthetic loaded k bank10 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].v.re=cap_re;force dut.banks[10].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[10].v.rd!==pattern(131072,cap_addr*16+10))$fatal(1,"Synthetic loaded v bank10 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].q.re=cap_re;force dut.banks[10].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[10].q.rd!==pattern(196608,cap_addr*16+10))$fatal(1,"Synthetic loaded q bank10 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].k.re=cap_re;force dut.banks[11].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[11].k.rd!==pattern(65536,cap_addr*16+11))$fatal(1,"Synthetic loaded k bank11 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].v.re=cap_re;force dut.banks[11].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[11].v.rd!==pattern(131072,cap_addr*16+11))$fatal(1,"Synthetic loaded v bank11 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].q.re=cap_re;force dut.banks[11].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[11].q.rd!==pattern(196608,cap_addr*16+11))$fatal(1,"Synthetic loaded q bank11 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].k.re=cap_re;force dut.banks[12].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[12].k.rd!==pattern(65536,cap_addr*16+12))$fatal(1,"Synthetic loaded k bank12 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].v.re=cap_re;force dut.banks[12].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[12].v.rd!==pattern(131072,cap_addr*16+12))$fatal(1,"Synthetic loaded v bank12 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].q.re=cap_re;force dut.banks[12].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[12].q.rd!==pattern(196608,cap_addr*16+12))$fatal(1,"Synthetic loaded q bank12 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].k.re=cap_re;force dut.banks[13].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[13].k.rd!==pattern(65536,cap_addr*16+13))$fatal(1,"Synthetic loaded k bank13 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].v.re=cap_re;force dut.banks[13].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[13].v.rd!==pattern(131072,cap_addr*16+13))$fatal(1,"Synthetic loaded v bank13 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].q.re=cap_re;force dut.banks[13].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[13].q.rd!==pattern(196608,cap_addr*16+13))$fatal(1,"Synthetic loaded q bank13 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].k.re=cap_re;force dut.banks[14].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[14].k.rd!==pattern(65536,cap_addr*16+14))$fatal(1,"Synthetic loaded k bank14 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].v.re=cap_re;force dut.banks[14].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[14].v.rd!==pattern(131072,cap_addr*16+14))$fatal(1,"Synthetic loaded v bank14 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].q.re=cap_re;force dut.banks[14].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[14].q.rd!==pattern(196608,cap_addr*16+14))$fatal(1,"Synthetic loaded q bank14 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].k.re=cap_re;force dut.banks[15].k.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[15].k.rd!==pattern(65536,cap_addr*16+15))$fatal(1,"Synthetic loaded k bank15 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].v.re=cap_re;force dut.banks[15].v.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<4096)begin
  #1;if(dut.banks[15].v.rd!==pattern(131072,cap_addr*16+15))$fatal(1,"Synthetic loaded v bank15 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].q.re=cap_re;force dut.banks[15].q.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==0&&cap_addr<64)begin
  #1;if(dut.banks[15].q.rd!==pattern(196608,cap_addr*16+15))$fatal(1,"Synthetic loaded q bank15 read mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].score.we=cap_we&&(cap_addr<1024);force dut.banks[0].score.wa=cap_addr;force dut.banks[0].score.wd=pattern(262144,cap_addr);force dut.banks[0].score.re=cap_re;force dut.banks[0].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[0].score.rd!==pattern(262144,cap_addr))$fatal(1,"Synthetic dut.banks[0].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].prob.we=cap_we&&(cap_addr<1024);force dut.banks[0].prob.wa=cap_addr;force dut.banks[0].prob.wd=pattern(327680,cap_addr);force dut.banks[0].prob.re=cap_re;force dut.banks[0].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[0].prob.rd!==pattern(327680,cap_addr))$fatal(1,"Synthetic dut.banks[0].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].ex.we=cap_we&&(cap_addr<512);force dut.banks[0].ex.wa=cap_addr;force dut.banks[0].ex.wd=pattern(393216,cap_addr);force dut.banks[0].ex.re=cap_re;force dut.banks[0].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[0].ex.rd!==pattern(393216,cap_addr))$fatal(1,"Synthetic dut.banks[0].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[0].y.we=cap_we&&(cap_addr<64);force dut.banks[0].y.wa=cap_addr;force dut.banks[0].y.wd=pattern(458752,cap_addr);force dut.banks[0].y.re=cap_re;force dut.banks[0].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[0].y.rd!==pattern(458752,cap_addr))$fatal(1,"Synthetic dut.banks[0].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].score.we=cap_we&&(cap_addr<1024);force dut.banks[1].score.wa=cap_addr;force dut.banks[1].score.wd=pattern(266240,cap_addr);force dut.banks[1].score.re=cap_re;force dut.banks[1].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[1].score.rd!==pattern(266240,cap_addr))$fatal(1,"Synthetic dut.banks[1].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].prob.we=cap_we&&(cap_addr<1024);force dut.banks[1].prob.wa=cap_addr;force dut.banks[1].prob.wd=pattern(331776,cap_addr);force dut.banks[1].prob.re=cap_re;force dut.banks[1].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[1].prob.rd!==pattern(331776,cap_addr))$fatal(1,"Synthetic dut.banks[1].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].ex.we=cap_we&&(cap_addr<512);force dut.banks[1].ex.wa=cap_addr;force dut.banks[1].ex.wd=pattern(397312,cap_addr);force dut.banks[1].ex.re=cap_re;force dut.banks[1].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[1].ex.rd!==pattern(397312,cap_addr))$fatal(1,"Synthetic dut.banks[1].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[1].y.we=cap_we&&(cap_addr<64);force dut.banks[1].y.wa=cap_addr;force dut.banks[1].y.wd=pattern(462848,cap_addr);force dut.banks[1].y.re=cap_re;force dut.banks[1].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[1].y.rd!==pattern(462848,cap_addr))$fatal(1,"Synthetic dut.banks[1].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].score.we=cap_we&&(cap_addr<1024);force dut.banks[2].score.wa=cap_addr;force dut.banks[2].score.wd=pattern(270336,cap_addr);force dut.banks[2].score.re=cap_re;force dut.banks[2].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[2].score.rd!==pattern(270336,cap_addr))$fatal(1,"Synthetic dut.banks[2].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].prob.we=cap_we&&(cap_addr<1024);force dut.banks[2].prob.wa=cap_addr;force dut.banks[2].prob.wd=pattern(335872,cap_addr);force dut.banks[2].prob.re=cap_re;force dut.banks[2].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[2].prob.rd!==pattern(335872,cap_addr))$fatal(1,"Synthetic dut.banks[2].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].ex.we=cap_we&&(cap_addr<512);force dut.banks[2].ex.wa=cap_addr;force dut.banks[2].ex.wd=pattern(401408,cap_addr);force dut.banks[2].ex.re=cap_re;force dut.banks[2].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[2].ex.rd!==pattern(401408,cap_addr))$fatal(1,"Synthetic dut.banks[2].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[2].y.we=cap_we&&(cap_addr<64);force dut.banks[2].y.wa=cap_addr;force dut.banks[2].y.wd=pattern(466944,cap_addr);force dut.banks[2].y.re=cap_re;force dut.banks[2].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[2].y.rd!==pattern(466944,cap_addr))$fatal(1,"Synthetic dut.banks[2].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].score.we=cap_we&&(cap_addr<1024);force dut.banks[3].score.wa=cap_addr;force dut.banks[3].score.wd=pattern(274432,cap_addr);force dut.banks[3].score.re=cap_re;force dut.banks[3].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[3].score.rd!==pattern(274432,cap_addr))$fatal(1,"Synthetic dut.banks[3].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].prob.we=cap_we&&(cap_addr<1024);force dut.banks[3].prob.wa=cap_addr;force dut.banks[3].prob.wd=pattern(339968,cap_addr);force dut.banks[3].prob.re=cap_re;force dut.banks[3].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[3].prob.rd!==pattern(339968,cap_addr))$fatal(1,"Synthetic dut.banks[3].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].ex.we=cap_we&&(cap_addr<512);force dut.banks[3].ex.wa=cap_addr;force dut.banks[3].ex.wd=pattern(405504,cap_addr);force dut.banks[3].ex.re=cap_re;force dut.banks[3].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[3].ex.rd!==pattern(405504,cap_addr))$fatal(1,"Synthetic dut.banks[3].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[3].y.we=cap_we&&(cap_addr<64);force dut.banks[3].y.wa=cap_addr;force dut.banks[3].y.wd=pattern(471040,cap_addr);force dut.banks[3].y.re=cap_re;force dut.banks[3].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[3].y.rd!==pattern(471040,cap_addr))$fatal(1,"Synthetic dut.banks[3].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].score.we=cap_we&&(cap_addr<1024);force dut.banks[4].score.wa=cap_addr;force dut.banks[4].score.wd=pattern(278528,cap_addr);force dut.banks[4].score.re=cap_re;force dut.banks[4].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[4].score.rd!==pattern(278528,cap_addr))$fatal(1,"Synthetic dut.banks[4].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].prob.we=cap_we&&(cap_addr<1024);force dut.banks[4].prob.wa=cap_addr;force dut.banks[4].prob.wd=pattern(344064,cap_addr);force dut.banks[4].prob.re=cap_re;force dut.banks[4].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[4].prob.rd!==pattern(344064,cap_addr))$fatal(1,"Synthetic dut.banks[4].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].ex.we=cap_we&&(cap_addr<512);force dut.banks[4].ex.wa=cap_addr;force dut.banks[4].ex.wd=pattern(409600,cap_addr);force dut.banks[4].ex.re=cap_re;force dut.banks[4].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[4].ex.rd!==pattern(409600,cap_addr))$fatal(1,"Synthetic dut.banks[4].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[4].y.we=cap_we&&(cap_addr<64);force dut.banks[4].y.wa=cap_addr;force dut.banks[4].y.wd=pattern(475136,cap_addr);force dut.banks[4].y.re=cap_re;force dut.banks[4].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[4].y.rd!==pattern(475136,cap_addr))$fatal(1,"Synthetic dut.banks[4].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].score.we=cap_we&&(cap_addr<1024);force dut.banks[5].score.wa=cap_addr;force dut.banks[5].score.wd=pattern(282624,cap_addr);force dut.banks[5].score.re=cap_re;force dut.banks[5].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[5].score.rd!==pattern(282624,cap_addr))$fatal(1,"Synthetic dut.banks[5].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].prob.we=cap_we&&(cap_addr<1024);force dut.banks[5].prob.wa=cap_addr;force dut.banks[5].prob.wd=pattern(348160,cap_addr);force dut.banks[5].prob.re=cap_re;force dut.banks[5].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[5].prob.rd!==pattern(348160,cap_addr))$fatal(1,"Synthetic dut.banks[5].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].ex.we=cap_we&&(cap_addr<512);force dut.banks[5].ex.wa=cap_addr;force dut.banks[5].ex.wd=pattern(413696,cap_addr);force dut.banks[5].ex.re=cap_re;force dut.banks[5].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[5].ex.rd!==pattern(413696,cap_addr))$fatal(1,"Synthetic dut.banks[5].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[5].y.we=cap_we&&(cap_addr<64);force dut.banks[5].y.wa=cap_addr;force dut.banks[5].y.wd=pattern(479232,cap_addr);force dut.banks[5].y.re=cap_re;force dut.banks[5].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[5].y.rd!==pattern(479232,cap_addr))$fatal(1,"Synthetic dut.banks[5].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].score.we=cap_we&&(cap_addr<1024);force dut.banks[6].score.wa=cap_addr;force dut.banks[6].score.wd=pattern(286720,cap_addr);force dut.banks[6].score.re=cap_re;force dut.banks[6].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[6].score.rd!==pattern(286720,cap_addr))$fatal(1,"Synthetic dut.banks[6].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].prob.we=cap_we&&(cap_addr<1024);force dut.banks[6].prob.wa=cap_addr;force dut.banks[6].prob.wd=pattern(352256,cap_addr);force dut.banks[6].prob.re=cap_re;force dut.banks[6].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[6].prob.rd!==pattern(352256,cap_addr))$fatal(1,"Synthetic dut.banks[6].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].ex.we=cap_we&&(cap_addr<512);force dut.banks[6].ex.wa=cap_addr;force dut.banks[6].ex.wd=pattern(417792,cap_addr);force dut.banks[6].ex.re=cap_re;force dut.banks[6].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[6].ex.rd!==pattern(417792,cap_addr))$fatal(1,"Synthetic dut.banks[6].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[6].y.we=cap_we&&(cap_addr<64);force dut.banks[6].y.wa=cap_addr;force dut.banks[6].y.wd=pattern(483328,cap_addr);force dut.banks[6].y.re=cap_re;force dut.banks[6].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[6].y.rd!==pattern(483328,cap_addr))$fatal(1,"Synthetic dut.banks[6].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].score.we=cap_we&&(cap_addr<1024);force dut.banks[7].score.wa=cap_addr;force dut.banks[7].score.wd=pattern(290816,cap_addr);force dut.banks[7].score.re=cap_re;force dut.banks[7].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[7].score.rd!==pattern(290816,cap_addr))$fatal(1,"Synthetic dut.banks[7].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].prob.we=cap_we&&(cap_addr<1024);force dut.banks[7].prob.wa=cap_addr;force dut.banks[7].prob.wd=pattern(356352,cap_addr);force dut.banks[7].prob.re=cap_re;force dut.banks[7].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[7].prob.rd!==pattern(356352,cap_addr))$fatal(1,"Synthetic dut.banks[7].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].ex.we=cap_we&&(cap_addr<512);force dut.banks[7].ex.wa=cap_addr;force dut.banks[7].ex.wd=pattern(421888,cap_addr);force dut.banks[7].ex.re=cap_re;force dut.banks[7].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[7].ex.rd!==pattern(421888,cap_addr))$fatal(1,"Synthetic dut.banks[7].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[7].y.we=cap_we&&(cap_addr<64);force dut.banks[7].y.wa=cap_addr;force dut.banks[7].y.wd=pattern(487424,cap_addr);force dut.banks[7].y.re=cap_re;force dut.banks[7].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[7].y.rd!==pattern(487424,cap_addr))$fatal(1,"Synthetic dut.banks[7].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].score.we=cap_we&&(cap_addr<1024);force dut.banks[8].score.wa=cap_addr;force dut.banks[8].score.wd=pattern(294912,cap_addr);force dut.banks[8].score.re=cap_re;force dut.banks[8].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[8].score.rd!==pattern(294912,cap_addr))$fatal(1,"Synthetic dut.banks[8].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].prob.we=cap_we&&(cap_addr<1024);force dut.banks[8].prob.wa=cap_addr;force dut.banks[8].prob.wd=pattern(360448,cap_addr);force dut.banks[8].prob.re=cap_re;force dut.banks[8].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[8].prob.rd!==pattern(360448,cap_addr))$fatal(1,"Synthetic dut.banks[8].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].ex.we=cap_we&&(cap_addr<512);force dut.banks[8].ex.wa=cap_addr;force dut.banks[8].ex.wd=pattern(425984,cap_addr);force dut.banks[8].ex.re=cap_re;force dut.banks[8].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[8].ex.rd!==pattern(425984,cap_addr))$fatal(1,"Synthetic dut.banks[8].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[8].y.we=cap_we&&(cap_addr<64);force dut.banks[8].y.wa=cap_addr;force dut.banks[8].y.wd=pattern(491520,cap_addr);force dut.banks[8].y.re=cap_re;force dut.banks[8].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[8].y.rd!==pattern(491520,cap_addr))$fatal(1,"Synthetic dut.banks[8].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].score.we=cap_we&&(cap_addr<1024);force dut.banks[9].score.wa=cap_addr;force dut.banks[9].score.wd=pattern(299008,cap_addr);force dut.banks[9].score.re=cap_re;force dut.banks[9].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[9].score.rd!==pattern(299008,cap_addr))$fatal(1,"Synthetic dut.banks[9].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].prob.we=cap_we&&(cap_addr<1024);force dut.banks[9].prob.wa=cap_addr;force dut.banks[9].prob.wd=pattern(364544,cap_addr);force dut.banks[9].prob.re=cap_re;force dut.banks[9].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[9].prob.rd!==pattern(364544,cap_addr))$fatal(1,"Synthetic dut.banks[9].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].ex.we=cap_we&&(cap_addr<512);force dut.banks[9].ex.wa=cap_addr;force dut.banks[9].ex.wd=pattern(430080,cap_addr);force dut.banks[9].ex.re=cap_re;force dut.banks[9].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[9].ex.rd!==pattern(430080,cap_addr))$fatal(1,"Synthetic dut.banks[9].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[9].y.we=cap_we&&(cap_addr<64);force dut.banks[9].y.wa=cap_addr;force dut.banks[9].y.wd=pattern(495616,cap_addr);force dut.banks[9].y.re=cap_re;force dut.banks[9].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[9].y.rd!==pattern(495616,cap_addr))$fatal(1,"Synthetic dut.banks[9].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].score.we=cap_we&&(cap_addr<1024);force dut.banks[10].score.wa=cap_addr;force dut.banks[10].score.wd=pattern(303104,cap_addr);force dut.banks[10].score.re=cap_re;force dut.banks[10].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[10].score.rd!==pattern(303104,cap_addr))$fatal(1,"Synthetic dut.banks[10].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].prob.we=cap_we&&(cap_addr<1024);force dut.banks[10].prob.wa=cap_addr;force dut.banks[10].prob.wd=pattern(368640,cap_addr);force dut.banks[10].prob.re=cap_re;force dut.banks[10].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[10].prob.rd!==pattern(368640,cap_addr))$fatal(1,"Synthetic dut.banks[10].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].ex.we=cap_we&&(cap_addr<512);force dut.banks[10].ex.wa=cap_addr;force dut.banks[10].ex.wd=pattern(434176,cap_addr);force dut.banks[10].ex.re=cap_re;force dut.banks[10].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[10].ex.rd!==pattern(434176,cap_addr))$fatal(1,"Synthetic dut.banks[10].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[10].y.we=cap_we&&(cap_addr<64);force dut.banks[10].y.wa=cap_addr;force dut.banks[10].y.wd=pattern(499712,cap_addr);force dut.banks[10].y.re=cap_re;force dut.banks[10].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[10].y.rd!==pattern(499712,cap_addr))$fatal(1,"Synthetic dut.banks[10].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].score.we=cap_we&&(cap_addr<1024);force dut.banks[11].score.wa=cap_addr;force dut.banks[11].score.wd=pattern(307200,cap_addr);force dut.banks[11].score.re=cap_re;force dut.banks[11].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[11].score.rd!==pattern(307200,cap_addr))$fatal(1,"Synthetic dut.banks[11].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].prob.we=cap_we&&(cap_addr<1024);force dut.banks[11].prob.wa=cap_addr;force dut.banks[11].prob.wd=pattern(372736,cap_addr);force dut.banks[11].prob.re=cap_re;force dut.banks[11].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[11].prob.rd!==pattern(372736,cap_addr))$fatal(1,"Synthetic dut.banks[11].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].ex.we=cap_we&&(cap_addr<512);force dut.banks[11].ex.wa=cap_addr;force dut.banks[11].ex.wd=pattern(438272,cap_addr);force dut.banks[11].ex.re=cap_re;force dut.banks[11].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[11].ex.rd!==pattern(438272,cap_addr))$fatal(1,"Synthetic dut.banks[11].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[11].y.we=cap_we&&(cap_addr<64);force dut.banks[11].y.wa=cap_addr;force dut.banks[11].y.wd=pattern(503808,cap_addr);force dut.banks[11].y.re=cap_re;force dut.banks[11].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[11].y.rd!==pattern(503808,cap_addr))$fatal(1,"Synthetic dut.banks[11].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].score.we=cap_we&&(cap_addr<1024);force dut.banks[12].score.wa=cap_addr;force dut.banks[12].score.wd=pattern(311296,cap_addr);force dut.banks[12].score.re=cap_re;force dut.banks[12].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[12].score.rd!==pattern(311296,cap_addr))$fatal(1,"Synthetic dut.banks[12].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].prob.we=cap_we&&(cap_addr<1024);force dut.banks[12].prob.wa=cap_addr;force dut.banks[12].prob.wd=pattern(376832,cap_addr);force dut.banks[12].prob.re=cap_re;force dut.banks[12].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[12].prob.rd!==pattern(376832,cap_addr))$fatal(1,"Synthetic dut.banks[12].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].ex.we=cap_we&&(cap_addr<512);force dut.banks[12].ex.wa=cap_addr;force dut.banks[12].ex.wd=pattern(442368,cap_addr);force dut.banks[12].ex.re=cap_re;force dut.banks[12].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[12].ex.rd!==pattern(442368,cap_addr))$fatal(1,"Synthetic dut.banks[12].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[12].y.we=cap_we&&(cap_addr<64);force dut.banks[12].y.wa=cap_addr;force dut.banks[12].y.wd=pattern(507904,cap_addr);force dut.banks[12].y.re=cap_re;force dut.banks[12].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[12].y.rd!==pattern(507904,cap_addr))$fatal(1,"Synthetic dut.banks[12].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].score.we=cap_we&&(cap_addr<1024);force dut.banks[13].score.wa=cap_addr;force dut.banks[13].score.wd=pattern(315392,cap_addr);force dut.banks[13].score.re=cap_re;force dut.banks[13].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[13].score.rd!==pattern(315392,cap_addr))$fatal(1,"Synthetic dut.banks[13].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].prob.we=cap_we&&(cap_addr<1024);force dut.banks[13].prob.wa=cap_addr;force dut.banks[13].prob.wd=pattern(380928,cap_addr);force dut.banks[13].prob.re=cap_re;force dut.banks[13].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[13].prob.rd!==pattern(380928,cap_addr))$fatal(1,"Synthetic dut.banks[13].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].ex.we=cap_we&&(cap_addr<512);force dut.banks[13].ex.wa=cap_addr;force dut.banks[13].ex.wd=pattern(446464,cap_addr);force dut.banks[13].ex.re=cap_re;force dut.banks[13].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[13].ex.rd!==pattern(446464,cap_addr))$fatal(1,"Synthetic dut.banks[13].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[13].y.we=cap_we&&(cap_addr<64);force dut.banks[13].y.wa=cap_addr;force dut.banks[13].y.wd=pattern(512000,cap_addr);force dut.banks[13].y.re=cap_re;force dut.banks[13].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[13].y.rd!==pattern(512000,cap_addr))$fatal(1,"Synthetic dut.banks[13].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].score.we=cap_we&&(cap_addr<1024);force dut.banks[14].score.wa=cap_addr;force dut.banks[14].score.wd=pattern(319488,cap_addr);force dut.banks[14].score.re=cap_re;force dut.banks[14].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[14].score.rd!==pattern(319488,cap_addr))$fatal(1,"Synthetic dut.banks[14].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].prob.we=cap_we&&(cap_addr<1024);force dut.banks[14].prob.wa=cap_addr;force dut.banks[14].prob.wd=pattern(385024,cap_addr);force dut.banks[14].prob.re=cap_re;force dut.banks[14].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[14].prob.rd!==pattern(385024,cap_addr))$fatal(1,"Synthetic dut.banks[14].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].ex.we=cap_we&&(cap_addr<512);force dut.banks[14].ex.wa=cap_addr;force dut.banks[14].ex.wd=pattern(450560,cap_addr);force dut.banks[14].ex.re=cap_re;force dut.banks[14].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[14].ex.rd!==pattern(450560,cap_addr))$fatal(1,"Synthetic dut.banks[14].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[14].y.we=cap_we&&(cap_addr<64);force dut.banks[14].y.wa=cap_addr;force dut.banks[14].y.wd=pattern(516096,cap_addr);force dut.banks[14].y.re=cap_re;force dut.banks[14].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[14].y.rd!==pattern(516096,cap_addr))$fatal(1,"Synthetic dut.banks[14].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].score.we=cap_we&&(cap_addr<1024);force dut.banks[15].score.wa=cap_addr;force dut.banks[15].score.wd=pattern(323584,cap_addr);force dut.banks[15].score.re=cap_re;force dut.banks[15].score.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[15].score.rd!==pattern(323584,cap_addr))$fatal(1,"Synthetic dut.banks[15].score capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].prob.we=cap_we&&(cap_addr<1024);force dut.banks[15].prob.wa=cap_addr;force dut.banks[15].prob.wd=pattern(389120,cap_addr);force dut.banks[15].prob.re=cap_re;force dut.banks[15].prob.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<1024)begin
  #1;if(dut.banks[15].prob.rd!==pattern(389120,cap_addr))$fatal(1,"Synthetic dut.banks[15].prob capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].ex.we=cap_we&&(cap_addr<512);force dut.banks[15].ex.wa=cap_addr;force dut.banks[15].ex.wd=pattern(454656,cap_addr);force dut.banks[15].ex.re=cap_re;force dut.banks[15].ex.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<512)begin
  #1;if(dut.banks[15].ex.rd!==pattern(454656,cap_addr))$fatal(1,"Synthetic dut.banks[15].ex capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.banks[15].y.we=cap_we&&(cap_addr<64);force dut.banks[15].y.wa=cap_addr;force dut.banks[15].y.wd=pattern(520192,cap_addr);force dut.banks[15].y.re=cap_re;force dut.banks[15].y.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<64)begin
  #1;if(dut.banks[15].y.rd!==pattern(520192,cap_addr))$fatal(1,"Synthetic dut.banks[15].y capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[0].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[0].ram.wa=cap_addr;force dut.softmax_tree[0].ram.wd=pattern(524288,cap_addr);force dut.softmax_tree[0].ram.re=cap_re;force dut.softmax_tree[0].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[0].ram.rd!==pattern(524288,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[0].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[1].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[1].ram.wa=cap_addr;force dut.softmax_tree[1].ram.wd=pattern(528384,cap_addr);force dut.softmax_tree[1].ram.re=cap_re;force dut.softmax_tree[1].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[1].ram.rd!==pattern(528384,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[1].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[2].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[2].ram.wa=cap_addr;force dut.softmax_tree[2].ram.wd=pattern(532480,cap_addr);force dut.softmax_tree[2].ram.re=cap_re;force dut.softmax_tree[2].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[2].ram.rd!==pattern(532480,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[2].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[3].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[3].ram.wa=cap_addr;force dut.softmax_tree[3].ram.wd=pattern(536576,cap_addr);force dut.softmax_tree[3].ram.re=cap_re;force dut.softmax_tree[3].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[3].ram.rd!==pattern(536576,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[3].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[4].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[4].ram.wa=cap_addr;force dut.softmax_tree[4].ram.wd=pattern(540672,cap_addr);force dut.softmax_tree[4].ram.re=cap_re;force dut.softmax_tree[4].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[4].ram.rd!==pattern(540672,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[4].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[5].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[5].ram.wa=cap_addr;force dut.softmax_tree[5].ram.wd=pattern(544768,cap_addr);force dut.softmax_tree[5].ram.re=cap_re;force dut.softmax_tree[5].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[5].ram.rd!==pattern(544768,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[5].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[6].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[6].ram.wa=cap_addr;force dut.softmax_tree[6].ram.wd=pattern(548864,cap_addr);force dut.softmax_tree[6].ram.re=cap_re;force dut.softmax_tree[6].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[6].ram.rd!==pattern(548864,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[6].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[7].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[7].ram.wa=cap_addr;force dut.softmax_tree[7].ram.wd=pattern(552960,cap_addr);force dut.softmax_tree[7].ram.re=cap_re;force dut.softmax_tree[7].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[7].ram.rd!==pattern(552960,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[7].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[8].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[8].ram.wa=cap_addr;force dut.softmax_tree[8].ram.wd=pattern(557056,cap_addr);force dut.softmax_tree[8].ram.re=cap_re;force dut.softmax_tree[8].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[8].ram.rd!==pattern(557056,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[8].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[9].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[9].ram.wa=cap_addr;force dut.softmax_tree[9].ram.wd=pattern(561152,cap_addr);force dut.softmax_tree[9].ram.re=cap_re;force dut.softmax_tree[9].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[9].ram.rd!==pattern(561152,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[9].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[10].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[10].ram.wa=cap_addr;force dut.softmax_tree[10].ram.wd=pattern(565248,cap_addr);force dut.softmax_tree[10].ram.re=cap_re;force dut.softmax_tree[10].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[10].ram.rd!==pattern(565248,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[10].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[11].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[11].ram.wa=cap_addr;force dut.softmax_tree[11].ram.wd=pattern(569344,cap_addr);force dut.softmax_tree[11].ram.re=cap_re;force dut.softmax_tree[11].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[11].ram.rd!==pattern(569344,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[11].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[12].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[12].ram.wa=cap_addr;force dut.softmax_tree[12].ram.wd=pattern(573440,cap_addr);force dut.softmax_tree[12].ram.re=cap_re;force dut.softmax_tree[12].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[12].ram.rd!==pattern(573440,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[12].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[13].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[13].ram.wa=cap_addr;force dut.softmax_tree[13].ram.wd=pattern(577536,cap_addr);force dut.softmax_tree[13].ram.re=cap_re;force dut.softmax_tree[13].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[13].ram.rd!==pattern(577536,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[13].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[14].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[14].ram.wa=cap_addr;force dut.softmax_tree[14].ram.wd=pattern(581632,cap_addr);force dut.softmax_tree[14].ram.re=cap_re;force dut.softmax_tree[14].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[14].ram.rd!==pattern(581632,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[14].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[15].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[15].ram.wa=cap_addr;force dut.softmax_tree[15].ram.wd=pattern(585728,cap_addr);force dut.softmax_tree[15].ram.re=cap_re;force dut.softmax_tree[15].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[15].ram.rd!==pattern(585728,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[15].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[16].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[16].ram.wa=cap_addr;force dut.softmax_tree[16].ram.wd=pattern(589824,cap_addr);force dut.softmax_tree[16].ram.re=cap_re;force dut.softmax_tree[16].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[16].ram.rd!==pattern(589824,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[16].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[17].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[17].ram.wa=cap_addr;force dut.softmax_tree[17].ram.wd=pattern(593920,cap_addr);force dut.softmax_tree[17].ram.re=cap_re;force dut.softmax_tree[17].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[17].ram.rd!==pattern(593920,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[17].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[18].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[18].ram.wa=cap_addr;force dut.softmax_tree[18].ram.wd=pattern(598016,cap_addr);force dut.softmax_tree[18].ram.re=cap_re;force dut.softmax_tree[18].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[18].ram.rd!==pattern(598016,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[18].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[19].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[19].ram.wa=cap_addr;force dut.softmax_tree[19].ram.wd=pattern(602112,cap_addr);force dut.softmax_tree[19].ram.re=cap_re;force dut.softmax_tree[19].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[19].ram.rd!==pattern(602112,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[19].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[20].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[20].ram.wa=cap_addr;force dut.softmax_tree[20].ram.wd=pattern(606208,cap_addr);force dut.softmax_tree[20].ram.re=cap_re;force dut.softmax_tree[20].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[20].ram.rd!==pattern(606208,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[20].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[21].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[21].ram.wa=cap_addr;force dut.softmax_tree[21].ram.wd=pattern(610304,cap_addr);force dut.softmax_tree[21].ram.re=cap_re;force dut.softmax_tree[21].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[21].ram.rd!==pattern(610304,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[21].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[22].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[22].ram.wa=cap_addr;force dut.softmax_tree[22].ram.wd=pattern(614400,cap_addr);force dut.softmax_tree[22].ram.re=cap_re;force dut.softmax_tree[22].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[22].ram.rd!==pattern(614400,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[22].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[23].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[23].ram.wa=cap_addr;force dut.softmax_tree[23].ram.wd=pattern(618496,cap_addr);force dut.softmax_tree[23].ram.re=cap_re;force dut.softmax_tree[23].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[23].ram.rd!==pattern(618496,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[23].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[24].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[24].ram.wa=cap_addr;force dut.softmax_tree[24].ram.wd=pattern(622592,cap_addr);force dut.softmax_tree[24].ram.re=cap_re;force dut.softmax_tree[24].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[24].ram.rd!==pattern(622592,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[24].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[25].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[25].ram.wa=cap_addr;force dut.softmax_tree[25].ram.wd=pattern(626688,cap_addr);force dut.softmax_tree[25].ram.re=cap_re;force dut.softmax_tree[25].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[25].ram.rd!==pattern(626688,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[25].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[26].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[26].ram.wa=cap_addr;force dut.softmax_tree[26].ram.wd=pattern(630784,cap_addr);force dut.softmax_tree[26].ram.re=cap_re;force dut.softmax_tree[26].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[26].ram.rd!==pattern(630784,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[26].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[27].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[27].ram.wa=cap_addr;force dut.softmax_tree[27].ram.wd=pattern(634880,cap_addr);force dut.softmax_tree[27].ram.re=cap_re;force dut.softmax_tree[27].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[27].ram.rd!==pattern(634880,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[27].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[28].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[28].ram.wa=cap_addr;force dut.softmax_tree[28].ram.wd=pattern(638976,cap_addr);force dut.softmax_tree[28].ram.re=cap_re;force dut.softmax_tree[28].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[28].ram.rd!==pattern(638976,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[28].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[29].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[29].ram.wa=cap_addr;force dut.softmax_tree[29].ram.wd=pattern(643072,cap_addr);force dut.softmax_tree[29].ram.re=cap_re;force dut.softmax_tree[29].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[29].ram.rd!==pattern(643072,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[29].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[30].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[30].ram.wa=cap_addr;force dut.softmax_tree[30].ram.wd=pattern(647168,cap_addr);force dut.softmax_tree[30].ram.re=cap_re;force dut.softmax_tree[30].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[30].ram.rd!==pattern(647168,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[30].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.softmax_tree[31].ram.we=cap_we&&(cap_addr<256);force dut.softmax_tree[31].ram.wa=cap_addr;force dut.softmax_tree[31].ram.wd=pattern(651264,cap_addr);force dut.softmax_tree[31].ram.re=cap_re;force dut.softmax_tree[31].ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<256)begin
  #1;if(dut.softmax_tree[31].ram.rd!==pattern(651264,cap_addr))$fatal(1,"Synthetic dut.softmax_tree[31].ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[0].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[0].live.ram.wd=pattern(1048576,cap_addr);force dut.dot_levels[0].bank[0].live.ram.re=cap_re;force dut.dot_levels[0].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[0].live.ram.rd!==pattern(1048576,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[1].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[1].live.ram.wd=pattern(1052672,cap_addr);force dut.dot_levels[0].bank[1].live.ram.re=cap_re;force dut.dot_levels[0].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[1].live.ram.rd!==pattern(1052672,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[2].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[2].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[2].live.ram.wd=pattern(1056768,cap_addr);force dut.dot_levels[0].bank[2].live.ram.re=cap_re;force dut.dot_levels[0].bank[2].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[2].live.ram.rd!==pattern(1056768,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[2].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[3].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[3].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[3].live.ram.wd=pattern(1060864,cap_addr);force dut.dot_levels[0].bank[3].live.ram.re=cap_re;force dut.dot_levels[0].bank[3].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[3].live.ram.rd!==pattern(1060864,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[3].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[4].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[4].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[4].live.ram.wd=pattern(1064960,cap_addr);force dut.dot_levels[0].bank[4].live.ram.re=cap_re;force dut.dot_levels[0].bank[4].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[4].live.ram.rd!==pattern(1064960,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[4].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[5].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[5].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[5].live.ram.wd=pattern(1069056,cap_addr);force dut.dot_levels[0].bank[5].live.ram.re=cap_re;force dut.dot_levels[0].bank[5].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[5].live.ram.rd!==pattern(1069056,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[5].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[6].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[6].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[6].live.ram.wd=pattern(1073152,cap_addr);force dut.dot_levels[0].bank[6].live.ram.re=cap_re;force dut.dot_levels[0].bank[6].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[6].live.ram.rd!==pattern(1073152,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[6].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[7].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[7].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[7].live.ram.wd=pattern(1077248,cap_addr);force dut.dot_levels[0].bank[7].live.ram.re=cap_re;force dut.dot_levels[0].bank[7].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[7].live.ram.rd!==pattern(1077248,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[7].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[8].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[8].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[8].live.ram.wd=pattern(1081344,cap_addr);force dut.dot_levels[0].bank[8].live.ram.re=cap_re;force dut.dot_levels[0].bank[8].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[8].live.ram.rd!==pattern(1081344,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[8].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[9].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[9].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[9].live.ram.wd=pattern(1085440,cap_addr);force dut.dot_levels[0].bank[9].live.ram.re=cap_re;force dut.dot_levels[0].bank[9].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[9].live.ram.rd!==pattern(1085440,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[9].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[10].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[10].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[10].live.ram.wd=pattern(1089536,cap_addr);force dut.dot_levels[0].bank[10].live.ram.re=cap_re;force dut.dot_levels[0].bank[10].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[10].live.ram.rd!==pattern(1089536,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[10].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[11].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[11].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[11].live.ram.wd=pattern(1093632,cap_addr);force dut.dot_levels[0].bank[11].live.ram.re=cap_re;force dut.dot_levels[0].bank[11].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[11].live.ram.rd!==pattern(1093632,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[11].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[12].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[12].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[12].live.ram.wd=pattern(1097728,cap_addr);force dut.dot_levels[0].bank[12].live.ram.re=cap_re;force dut.dot_levels[0].bank[12].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[12].live.ram.rd!==pattern(1097728,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[12].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[13].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[13].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[13].live.ram.wd=pattern(1101824,cap_addr);force dut.dot_levels[0].bank[13].live.ram.re=cap_re;force dut.dot_levels[0].bank[13].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[13].live.ram.rd!==pattern(1101824,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[13].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[14].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[14].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[14].live.ram.wd=pattern(1105920,cap_addr);force dut.dot_levels[0].bank[14].live.ram.re=cap_re;force dut.dot_levels[0].bank[14].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[14].live.ram.rd!==pattern(1105920,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[14].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[15].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[15].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[15].live.ram.wd=pattern(1110016,cap_addr);force dut.dot_levels[0].bank[15].live.ram.re=cap_re;force dut.dot_levels[0].bank[15].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[15].live.ram.rd!==pattern(1110016,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[15].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[16].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[16].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[16].live.ram.wd=pattern(1114112,cap_addr);force dut.dot_levels[0].bank[16].live.ram.re=cap_re;force dut.dot_levels[0].bank[16].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[16].live.ram.rd!==pattern(1114112,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[16].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[17].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[17].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[17].live.ram.wd=pattern(1118208,cap_addr);force dut.dot_levels[0].bank[17].live.ram.re=cap_re;force dut.dot_levels[0].bank[17].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[17].live.ram.rd!==pattern(1118208,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[17].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[18].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[18].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[18].live.ram.wd=pattern(1122304,cap_addr);force dut.dot_levels[0].bank[18].live.ram.re=cap_re;force dut.dot_levels[0].bank[18].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[18].live.ram.rd!==pattern(1122304,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[18].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[19].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[19].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[19].live.ram.wd=pattern(1126400,cap_addr);force dut.dot_levels[0].bank[19].live.ram.re=cap_re;force dut.dot_levels[0].bank[19].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[19].live.ram.rd!==pattern(1126400,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[19].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[20].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[20].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[20].live.ram.wd=pattern(1130496,cap_addr);force dut.dot_levels[0].bank[20].live.ram.re=cap_re;force dut.dot_levels[0].bank[20].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[20].live.ram.rd!==pattern(1130496,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[20].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[21].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[21].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[21].live.ram.wd=pattern(1134592,cap_addr);force dut.dot_levels[0].bank[21].live.ram.re=cap_re;force dut.dot_levels[0].bank[21].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[21].live.ram.rd!==pattern(1134592,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[21].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[22].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[22].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[22].live.ram.wd=pattern(1138688,cap_addr);force dut.dot_levels[0].bank[22].live.ram.re=cap_re;force dut.dot_levels[0].bank[22].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[22].live.ram.rd!==pattern(1138688,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[22].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[23].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[23].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[23].live.ram.wd=pattern(1142784,cap_addr);force dut.dot_levels[0].bank[23].live.ram.re=cap_re;force dut.dot_levels[0].bank[23].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[23].live.ram.rd!==pattern(1142784,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[23].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[24].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[24].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[24].live.ram.wd=pattern(1146880,cap_addr);force dut.dot_levels[0].bank[24].live.ram.re=cap_re;force dut.dot_levels[0].bank[24].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[24].live.ram.rd!==pattern(1146880,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[24].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[25].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[25].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[25].live.ram.wd=pattern(1150976,cap_addr);force dut.dot_levels[0].bank[25].live.ram.re=cap_re;force dut.dot_levels[0].bank[25].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[25].live.ram.rd!==pattern(1150976,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[25].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[26].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[26].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[26].live.ram.wd=pattern(1155072,cap_addr);force dut.dot_levels[0].bank[26].live.ram.re=cap_re;force dut.dot_levels[0].bank[26].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[26].live.ram.rd!==pattern(1155072,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[26].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[27].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[27].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[27].live.ram.wd=pattern(1159168,cap_addr);force dut.dot_levels[0].bank[27].live.ram.re=cap_re;force dut.dot_levels[0].bank[27].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[27].live.ram.rd!==pattern(1159168,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[27].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[28].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[28].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[28].live.ram.wd=pattern(1163264,cap_addr);force dut.dot_levels[0].bank[28].live.ram.re=cap_re;force dut.dot_levels[0].bank[28].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[28].live.ram.rd!==pattern(1163264,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[28].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[29].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[29].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[29].live.ram.wd=pattern(1167360,cap_addr);force dut.dot_levels[0].bank[29].live.ram.re=cap_re;force dut.dot_levels[0].bank[29].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[29].live.ram.rd!==pattern(1167360,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[29].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[30].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[30].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[30].live.ram.wd=pattern(1171456,cap_addr);force dut.dot_levels[0].bank[30].live.ram.re=cap_re;force dut.dot_levels[0].bank[30].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[30].live.ram.rd!==pattern(1171456,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[30].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[0].bank[31].live.ram.we=cap_we&&(cap_addr<32);force dut.dot_levels[0].bank[31].live.ram.wa=cap_addr;force dut.dot_levels[0].bank[31].live.ram.wd=pattern(1175552,cap_addr);force dut.dot_levels[0].bank[31].live.ram.re=cap_re;force dut.dot_levels[0].bank[31].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<32)begin
  #1;if(dut.dot_levels[0].bank[31].live.ram.rd!==pattern(1175552,cap_addr))$fatal(1,"Synthetic dut.dot_levels[0].bank[31].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[0].live.ram.wd=pattern(1179648,cap_addr);force dut.dot_levels[1].bank[0].live.ram.re=cap_re;force dut.dot_levels[1].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[0].live.ram.rd!==pattern(1179648,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[1].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[1].live.ram.wd=pattern(1183744,cap_addr);force dut.dot_levels[1].bank[1].live.ram.re=cap_re;force dut.dot_levels[1].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[1].live.ram.rd!==pattern(1183744,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[2].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[2].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[2].live.ram.wd=pattern(1187840,cap_addr);force dut.dot_levels[1].bank[2].live.ram.re=cap_re;force dut.dot_levels[1].bank[2].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[2].live.ram.rd!==pattern(1187840,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[2].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[3].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[3].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[3].live.ram.wd=pattern(1191936,cap_addr);force dut.dot_levels[1].bank[3].live.ram.re=cap_re;force dut.dot_levels[1].bank[3].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[3].live.ram.rd!==pattern(1191936,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[3].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[4].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[4].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[4].live.ram.wd=pattern(1196032,cap_addr);force dut.dot_levels[1].bank[4].live.ram.re=cap_re;force dut.dot_levels[1].bank[4].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[4].live.ram.rd!==pattern(1196032,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[4].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[5].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[5].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[5].live.ram.wd=pattern(1200128,cap_addr);force dut.dot_levels[1].bank[5].live.ram.re=cap_re;force dut.dot_levels[1].bank[5].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[5].live.ram.rd!==pattern(1200128,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[5].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[6].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[6].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[6].live.ram.wd=pattern(1204224,cap_addr);force dut.dot_levels[1].bank[6].live.ram.re=cap_re;force dut.dot_levels[1].bank[6].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[6].live.ram.rd!==pattern(1204224,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[6].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[7].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[7].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[7].live.ram.wd=pattern(1208320,cap_addr);force dut.dot_levels[1].bank[7].live.ram.re=cap_re;force dut.dot_levels[1].bank[7].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[7].live.ram.rd!==pattern(1208320,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[7].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[8].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[8].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[8].live.ram.wd=pattern(1212416,cap_addr);force dut.dot_levels[1].bank[8].live.ram.re=cap_re;force dut.dot_levels[1].bank[8].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[8].live.ram.rd!==pattern(1212416,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[8].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[9].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[9].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[9].live.ram.wd=pattern(1216512,cap_addr);force dut.dot_levels[1].bank[9].live.ram.re=cap_re;force dut.dot_levels[1].bank[9].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[9].live.ram.rd!==pattern(1216512,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[9].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[10].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[10].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[10].live.ram.wd=pattern(1220608,cap_addr);force dut.dot_levels[1].bank[10].live.ram.re=cap_re;force dut.dot_levels[1].bank[10].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[10].live.ram.rd!==pattern(1220608,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[10].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[11].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[11].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[11].live.ram.wd=pattern(1224704,cap_addr);force dut.dot_levels[1].bank[11].live.ram.re=cap_re;force dut.dot_levels[1].bank[11].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[11].live.ram.rd!==pattern(1224704,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[11].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[12].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[12].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[12].live.ram.wd=pattern(1228800,cap_addr);force dut.dot_levels[1].bank[12].live.ram.re=cap_re;force dut.dot_levels[1].bank[12].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[12].live.ram.rd!==pattern(1228800,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[12].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[13].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[13].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[13].live.ram.wd=pattern(1232896,cap_addr);force dut.dot_levels[1].bank[13].live.ram.re=cap_re;force dut.dot_levels[1].bank[13].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[13].live.ram.rd!==pattern(1232896,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[13].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[14].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[14].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[14].live.ram.wd=pattern(1236992,cap_addr);force dut.dot_levels[1].bank[14].live.ram.re=cap_re;force dut.dot_levels[1].bank[14].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[14].live.ram.rd!==pattern(1236992,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[14].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[15].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[15].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[15].live.ram.wd=pattern(1241088,cap_addr);force dut.dot_levels[1].bank[15].live.ram.re=cap_re;force dut.dot_levels[1].bank[15].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[15].live.ram.rd!==pattern(1241088,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[15].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[16].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[16].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[16].live.ram.wd=pattern(1245184,cap_addr);force dut.dot_levels[1].bank[16].live.ram.re=cap_re;force dut.dot_levels[1].bank[16].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[16].live.ram.rd!==pattern(1245184,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[16].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[17].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[17].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[17].live.ram.wd=pattern(1249280,cap_addr);force dut.dot_levels[1].bank[17].live.ram.re=cap_re;force dut.dot_levels[1].bank[17].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[17].live.ram.rd!==pattern(1249280,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[17].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[18].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[18].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[18].live.ram.wd=pattern(1253376,cap_addr);force dut.dot_levels[1].bank[18].live.ram.re=cap_re;force dut.dot_levels[1].bank[18].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[18].live.ram.rd!==pattern(1253376,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[18].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[19].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[19].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[19].live.ram.wd=pattern(1257472,cap_addr);force dut.dot_levels[1].bank[19].live.ram.re=cap_re;force dut.dot_levels[1].bank[19].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[19].live.ram.rd!==pattern(1257472,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[19].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[20].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[20].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[20].live.ram.wd=pattern(1261568,cap_addr);force dut.dot_levels[1].bank[20].live.ram.re=cap_re;force dut.dot_levels[1].bank[20].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[20].live.ram.rd!==pattern(1261568,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[20].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[21].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[21].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[21].live.ram.wd=pattern(1265664,cap_addr);force dut.dot_levels[1].bank[21].live.ram.re=cap_re;force dut.dot_levels[1].bank[21].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[21].live.ram.rd!==pattern(1265664,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[21].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[22].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[22].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[22].live.ram.wd=pattern(1269760,cap_addr);force dut.dot_levels[1].bank[22].live.ram.re=cap_re;force dut.dot_levels[1].bank[22].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[22].live.ram.rd!==pattern(1269760,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[22].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[23].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[23].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[23].live.ram.wd=pattern(1273856,cap_addr);force dut.dot_levels[1].bank[23].live.ram.re=cap_re;force dut.dot_levels[1].bank[23].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[23].live.ram.rd!==pattern(1273856,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[23].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[24].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[24].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[24].live.ram.wd=pattern(1277952,cap_addr);force dut.dot_levels[1].bank[24].live.ram.re=cap_re;force dut.dot_levels[1].bank[24].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[24].live.ram.rd!==pattern(1277952,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[24].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[25].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[25].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[25].live.ram.wd=pattern(1282048,cap_addr);force dut.dot_levels[1].bank[25].live.ram.re=cap_re;force dut.dot_levels[1].bank[25].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[25].live.ram.rd!==pattern(1282048,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[25].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[26].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[26].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[26].live.ram.wd=pattern(1286144,cap_addr);force dut.dot_levels[1].bank[26].live.ram.re=cap_re;force dut.dot_levels[1].bank[26].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[26].live.ram.rd!==pattern(1286144,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[26].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[27].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[27].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[27].live.ram.wd=pattern(1290240,cap_addr);force dut.dot_levels[1].bank[27].live.ram.re=cap_re;force dut.dot_levels[1].bank[27].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[27].live.ram.rd!==pattern(1290240,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[27].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[28].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[28].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[28].live.ram.wd=pattern(1294336,cap_addr);force dut.dot_levels[1].bank[28].live.ram.re=cap_re;force dut.dot_levels[1].bank[28].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[28].live.ram.rd!==pattern(1294336,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[28].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[29].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[29].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[29].live.ram.wd=pattern(1298432,cap_addr);force dut.dot_levels[1].bank[29].live.ram.re=cap_re;force dut.dot_levels[1].bank[29].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[29].live.ram.rd!==pattern(1298432,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[29].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[30].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[30].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[30].live.ram.wd=pattern(1302528,cap_addr);force dut.dot_levels[1].bank[30].live.ram.re=cap_re;force dut.dot_levels[1].bank[30].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[30].live.ram.rd!==pattern(1302528,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[30].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[1].bank[31].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[1].bank[31].live.ram.wa=cap_addr;force dut.dot_levels[1].bank[31].live.ram.wd=pattern(1306624,cap_addr);force dut.dot_levels[1].bank[31].live.ram.re=cap_re;force dut.dot_levels[1].bank[31].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[1].bank[31].live.ram.rd!==pattern(1306624,cap_addr))$fatal(1,"Synthetic dut.dot_levels[1].bank[31].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[0].live.ram.wd=pattern(1310720,cap_addr);force dut.dot_levels[2].bank[0].live.ram.re=cap_re;force dut.dot_levels[2].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[0].live.ram.rd!==pattern(1310720,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[1].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[1].live.ram.wd=pattern(1314816,cap_addr);force dut.dot_levels[2].bank[1].live.ram.re=cap_re;force dut.dot_levels[2].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[1].live.ram.rd!==pattern(1314816,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[2].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[2].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[2].live.ram.wd=pattern(1318912,cap_addr);force dut.dot_levels[2].bank[2].live.ram.re=cap_re;force dut.dot_levels[2].bank[2].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[2].live.ram.rd!==pattern(1318912,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[2].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[3].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[3].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[3].live.ram.wd=pattern(1323008,cap_addr);force dut.dot_levels[2].bank[3].live.ram.re=cap_re;force dut.dot_levels[2].bank[3].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[3].live.ram.rd!==pattern(1323008,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[3].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[4].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[4].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[4].live.ram.wd=pattern(1327104,cap_addr);force dut.dot_levels[2].bank[4].live.ram.re=cap_re;force dut.dot_levels[2].bank[4].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[4].live.ram.rd!==pattern(1327104,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[4].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[5].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[5].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[5].live.ram.wd=pattern(1331200,cap_addr);force dut.dot_levels[2].bank[5].live.ram.re=cap_re;force dut.dot_levels[2].bank[5].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[5].live.ram.rd!==pattern(1331200,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[5].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[6].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[6].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[6].live.ram.wd=pattern(1335296,cap_addr);force dut.dot_levels[2].bank[6].live.ram.re=cap_re;force dut.dot_levels[2].bank[6].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[6].live.ram.rd!==pattern(1335296,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[6].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[7].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[7].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[7].live.ram.wd=pattern(1339392,cap_addr);force dut.dot_levels[2].bank[7].live.ram.re=cap_re;force dut.dot_levels[2].bank[7].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[7].live.ram.rd!==pattern(1339392,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[7].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[8].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[8].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[8].live.ram.wd=pattern(1343488,cap_addr);force dut.dot_levels[2].bank[8].live.ram.re=cap_re;force dut.dot_levels[2].bank[8].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[8].live.ram.rd!==pattern(1343488,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[8].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[9].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[9].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[9].live.ram.wd=pattern(1347584,cap_addr);force dut.dot_levels[2].bank[9].live.ram.re=cap_re;force dut.dot_levels[2].bank[9].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[9].live.ram.rd!==pattern(1347584,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[9].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[10].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[10].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[10].live.ram.wd=pattern(1351680,cap_addr);force dut.dot_levels[2].bank[10].live.ram.re=cap_re;force dut.dot_levels[2].bank[10].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[10].live.ram.rd!==pattern(1351680,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[10].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[11].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[11].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[11].live.ram.wd=pattern(1355776,cap_addr);force dut.dot_levels[2].bank[11].live.ram.re=cap_re;force dut.dot_levels[2].bank[11].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[11].live.ram.rd!==pattern(1355776,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[11].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[12].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[12].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[12].live.ram.wd=pattern(1359872,cap_addr);force dut.dot_levels[2].bank[12].live.ram.re=cap_re;force dut.dot_levels[2].bank[12].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[12].live.ram.rd!==pattern(1359872,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[12].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[13].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[13].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[13].live.ram.wd=pattern(1363968,cap_addr);force dut.dot_levels[2].bank[13].live.ram.re=cap_re;force dut.dot_levels[2].bank[13].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[13].live.ram.rd!==pattern(1363968,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[13].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[14].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[14].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[14].live.ram.wd=pattern(1368064,cap_addr);force dut.dot_levels[2].bank[14].live.ram.re=cap_re;force dut.dot_levels[2].bank[14].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[14].live.ram.rd!==pattern(1368064,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[14].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[2].bank[15].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[2].bank[15].live.ram.wa=cap_addr;force dut.dot_levels[2].bank[15].live.ram.wd=pattern(1372160,cap_addr);force dut.dot_levels[2].bank[15].live.ram.re=cap_re;force dut.dot_levels[2].bank[15].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[2].bank[15].live.ram.rd!==pattern(1372160,cap_addr))$fatal(1,"Synthetic dut.dot_levels[2].bank[15].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[0].live.ram.wd=pattern(1441792,cap_addr);force dut.dot_levels[3].bank[0].live.ram.re=cap_re;force dut.dot_levels[3].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[0].live.ram.rd!==pattern(1441792,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[1].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[1].live.ram.wd=pattern(1445888,cap_addr);force dut.dot_levels[3].bank[1].live.ram.re=cap_re;force dut.dot_levels[3].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[1].live.ram.rd!==pattern(1445888,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[2].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[2].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[2].live.ram.wd=pattern(1449984,cap_addr);force dut.dot_levels[3].bank[2].live.ram.re=cap_re;force dut.dot_levels[3].bank[2].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[2].live.ram.rd!==pattern(1449984,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[2].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[3].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[3].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[3].live.ram.wd=pattern(1454080,cap_addr);force dut.dot_levels[3].bank[3].live.ram.re=cap_re;force dut.dot_levels[3].bank[3].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[3].live.ram.rd!==pattern(1454080,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[3].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[4].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[4].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[4].live.ram.wd=pattern(1458176,cap_addr);force dut.dot_levels[3].bank[4].live.ram.re=cap_re;force dut.dot_levels[3].bank[4].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[4].live.ram.rd!==pattern(1458176,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[4].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[5].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[5].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[5].live.ram.wd=pattern(1462272,cap_addr);force dut.dot_levels[3].bank[5].live.ram.re=cap_re;force dut.dot_levels[3].bank[5].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[5].live.ram.rd!==pattern(1462272,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[5].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[6].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[6].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[6].live.ram.wd=pattern(1466368,cap_addr);force dut.dot_levels[3].bank[6].live.ram.re=cap_re;force dut.dot_levels[3].bank[6].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[6].live.ram.rd!==pattern(1466368,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[6].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[3].bank[7].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[3].bank[7].live.ram.wa=cap_addr;force dut.dot_levels[3].bank[7].live.ram.wd=pattern(1470464,cap_addr);force dut.dot_levels[3].bank[7].live.ram.re=cap_re;force dut.dot_levels[3].bank[7].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[3].bank[7].live.ram.rd!==pattern(1470464,cap_addr))$fatal(1,"Synthetic dut.dot_levels[3].bank[7].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[4].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[4].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[4].bank[0].live.ram.wd=pattern(1572864,cap_addr);force dut.dot_levels[4].bank[0].live.ram.re=cap_re;force dut.dot_levels[4].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[4].bank[0].live.ram.rd!==pattern(1572864,cap_addr))$fatal(1,"Synthetic dut.dot_levels[4].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[4].bank[1].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[4].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[4].bank[1].live.ram.wd=pattern(1576960,cap_addr);force dut.dot_levels[4].bank[1].live.ram.re=cap_re;force dut.dot_levels[4].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[4].bank[1].live.ram.rd!==pattern(1576960,cap_addr))$fatal(1,"Synthetic dut.dot_levels[4].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[4].bank[2].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[4].bank[2].live.ram.wa=cap_addr;force dut.dot_levels[4].bank[2].live.ram.wd=pattern(1581056,cap_addr);force dut.dot_levels[4].bank[2].live.ram.re=cap_re;force dut.dot_levels[4].bank[2].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[4].bank[2].live.ram.rd!==pattern(1581056,cap_addr))$fatal(1,"Synthetic dut.dot_levels[4].bank[2].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[4].bank[3].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[4].bank[3].live.ram.wa=cap_addr;force dut.dot_levels[4].bank[3].live.ram.wd=pattern(1585152,cap_addr);force dut.dot_levels[4].bank[3].live.ram.re=cap_re;force dut.dot_levels[4].bank[3].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[4].bank[3].live.ram.rd!==pattern(1585152,cap_addr))$fatal(1,"Synthetic dut.dot_levels[4].bank[3].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[5].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[5].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[5].bank[0].live.ram.wd=pattern(1703936,cap_addr);force dut.dot_levels[5].bank[0].live.ram.re=cap_re;force dut.dot_levels[5].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[5].bank[0].live.ram.rd!==pattern(1703936,cap_addr))$fatal(1,"Synthetic dut.dot_levels[5].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[5].bank[1].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[5].bank[1].live.ram.wa=cap_addr;force dut.dot_levels[5].bank[1].live.ram.wd=pattern(1708032,cap_addr);force dut.dot_levels[5].bank[1].live.ram.re=cap_re;force dut.dot_levels[5].bank[1].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[5].bank[1].live.ram.rd!==pattern(1708032,cap_addr))$fatal(1,"Synthetic dut.dot_levels[5].bank[1].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin wait(cap_mode);force dut.dot_levels[6].bank[0].live.ram.we=cap_we&&(cap_addr<16);force dut.dot_levels[6].bank[0].live.ram.wa=cap_addr;force dut.dot_levels[6].bank[0].live.ram.wd=pattern(1835008,cap_addr);force dut.dot_levels[6].bank[0].live.ram.re=cap_re;force dut.dot_levels[6].bank[0].live.ram.ra=cap_addr;end
 always @(posedge ap_clk)if(cap_mode&&ap_ce&&cap_re&&stage==2&&cap_addr<16)begin
  #1;if(dut.dot_levels[6].bank[0].live.ram.rd!==pattern(1835008,cap_addr))$fatal(1,"Synthetic dut.dot_levels[6].bank[0].live.ram capacity/port mismatch addr=%0d",cap_addr);checks=checks+1;
 end
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"Identity fixture required");$readmemh({fixture,"/identity_words.mem"},id);
  repeat(8)@(negedge ap_clk);ap_rst=0;repeat(3)@(negedge ap_clk);
  invoke(0,0,0,0);for(integer n=0;n<55;n=n+1)words[n]=0;for(integer n=0;n<21;n=n+1)words[n]=id[n];words[4]=(1024<<16)|1;
  for(integer n=0;n<3;n=n+1)begin words[21+4*n]=100+n;words[22+4*n]='h250+n;words[23+4*n]=(16<<16)|1008;end
  for(integer n=0;n<7;n=n+1)begin words[33+3*n]=n==0?'h25:(n==3?'h28:(n==4?8:(n==5?5:(n==6?'h105:'h26))));words[34+3*n]=n==2?2:1;end
  for(integer n=0;n<55;n=n+1)invoke(1,n,words[n],0);invoke(2,1024,1008,0);
  for(integer n=0;n<65536;n=n+1)begin invoke(4,n,pattern('h10000,n),0);invoke(5,n,pattern('h20000,n),0);end
  for(integer n=0;n<1024;n=n+1)begin invoke(6,n,n%2,0);invoke(18,n,pattern('h30000,n),0);end
  invoke(4,65536,0,2);invoke(5,65536,0,2);invoke(6,1024,0,2);invoke(18,1024,0,2);
  cap_mode=1;cap_re=1;
  for(integer n=0;n<4096;n=n+1)begin cap_addr=n;@(negedge ap_clk);end
  cap_re=0;stage=1;cap_we=1;
  for(integer n=0;n<1024;n=n+1)begin cap_addr=n;@(negedge ap_clk);end
  cap_we=0;stage=2;cap_re=1;
  for(integer n=0;n<1024;n=n+1)begin cap_addr=n;@(negedge ap_clk);end
  cap_re=0;
  if(checks!=184304)$fatal(1,"Synthetic exact capacity count got=%0d expected=184304",checks);
  $display("ATTENTION_SERVICE_TILE_CAPACITY_PASS synthetic=1 S1024 rows16 highrow1008 K65536 V65536 Q1024 physical_port_checks=%0d command_calls=%0d",checks,calls);$finish;
 end
endmodule
