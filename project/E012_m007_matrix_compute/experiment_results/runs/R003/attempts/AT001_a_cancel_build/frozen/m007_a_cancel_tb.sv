`timescale 1ns/1ps
module m007_a_cancel_tb;
 logic clk=0;always #1 clk=~clk;
 logic rst_n=0,cfg_valid=0,cfg_ready,cfg_slot=0;logic [15:0] cfg_k=1024;
 logic [63:0] cfg_request=0;logic [31:0] cfg_generation=0,cfg_epoch=0;
 logic cfg_rsp_valid,cfg_rsp_ready=0,cfg_rsp_slot;logic [1:0] cfg_status;logic [15:0] cfg_rsp_k;logic [63:0] cfg_rsp_request;logic [31:0] cfg_rsp_generation,cfg_rsp_epoch;logic [6:0] error_row,error_group;
 logic wr_valid=0,wr_ready;logic [6:0] wr_row,wr_group;logic [271:0] wr_data;logic [63:0] wr_request;logic [31:0] wr_generation,wr_epoch;
 logic wr_rsp_valid,wr_rsp_ready=0;logic [6:0] wr_rsp_row,wr_rsp_group;
 logic lease_valid=0,lease_ready,lease_slot=0;logic [63:0] lease_request;logic [31:0] lease_generation,lease_epoch;
 logic rd_valid=0,rd_ready,rd_slot=0;logic [2:0] rd_m;logic [6:0] rd_group;logic [95:0] rd_tag;logic [63:0] rd_request;logic [31:0] rd_generation,rd_epoch;
 logic rd_rsp_valid,rd_rsp_ready,rd_rsp_slot;logic [95:0] rd_rsp_tag;logic [4351:0] rd_rsp_data;
 logic ret_valid,ret_ready,ret_slot;logic [95:0] ret_tag;logic [63:0] ret_request;logic [31:0] ret_generation,ret_epoch;
 logic release_valid=0,release_ready,release_slot=0;logic [63:0] release_request;logic [31:0] release_generation,release_epoch;
 logic [1:0] slot_valid,slot_leased;logic [6:0] read_debt;
 logic fill_cancel_valid=0,fill_cancel_ready,fill_cancel_slot=0;
 logic [63:0] fill_cancel_request=0;logic [31:0] fill_cancel_generation=0,fill_cancel_epoch=0;
 logic fill_cancel_reject_valid;logic [3:0] fill_cancel_reject_code;
 logic fill_cancel_rsp_valid,fill_cancel_rsp_ready=0,fill_cancel_rsp_slot;
 logic [63:0] fill_cancel_rsp_request;logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch;
 laya_m007_a_cache_v1 dut(.*);
 integer cycle=0,writes=0,acks=0,cancels=0,publications=0;
 localparam logic [271:0] WORD={16'h3c00,256'h123456789abcdef};
 always @(posedge clk)begin
  cycle<=cycle+1;
  if(rst_n)begin
   if(wr_valid&&wr_ready)writes=writes+1;
   if(wr_rsp_valid&&wr_rsp_ready)acks=acks+1;
   if(fill_cancel_rsp_valid&&fill_cancel_rsp_ready)cancels=cancels+1;
   if(cfg_rsp_valid&&cfg_rsp_ready)publications=publications+1;
  end
  if(cycle>30000)$fatal(1,"bounded cancel watchdog");
 end
 task automatic configure(input logic sl,input logic [63:0] req);
  @(negedge clk);cfg_slot=sl;cfg_request=req;cfg_generation=32'(req);cfg_epoch=32'(req+100);cfg_valid=1;
  do @(posedge clk);while(!cfg_ready);
  @(negedge clk);cfg_valid=0;wr_request=cfg_request;wr_generation=cfg_generation;wr_epoch=cfg_epoch;
 endtask
 task automatic write_groups(input integer count);
  for(integer i=0;i<count;i++)begin
   @(negedge clk);wr_valid=1;wr_row=i/32;wr_group=i%32;wr_data=WORD;
   do @(posedge clk);while(!wr_ready);
  end
  @(negedge clk);wr_valid=0;
 endtask
 task automatic consume_cfg;
  wait(cfg_rsp_valid);@(negedge clk);
  if(cfg_status!=0||cfg_rsp_request!=cfg_request||cfg_rsp_generation!=cfg_generation||cfg_rsp_epoch!=cfg_epoch)$fatal(1,"real cfg publication identity");
  cfg_rsp_ready=1;@(negedge clk);cfg_rsp_ready=0;
 endtask
 task automatic request_cancel(input logic sl,input logic [63:0] req,input logic [31:0] gen,ep);
  @(negedge clk);fill_cancel_valid=1;fill_cancel_slot=sl;fill_cancel_request=req;fill_cancel_generation=gen;fill_cancel_epoch=ep;
  @(posedge clk);if(!fill_cancel_ready)$fatal(1,"matching real cancel not accepted code=%0d",fill_cancel_reject_code);
  @(negedge clk);fill_cancel_valid=0;
 endtask
 task automatic consume_cancel(input logic sl,input logic [63:0] req,input logic [31:0] gen,ep);
  wait(fill_cancel_rsp_valid);@(negedge clk);cfg_valid=1;
  repeat(5)begin
   if(!fill_cancel_rsp_valid||fill_cancel_rsp_slot!=sl||fill_cancel_rsp_request!=req||fill_cancel_rsp_generation!=gen||fill_cancel_rsp_epoch!=ep||cfg_ready||slot_valid[sl])$fatal(1,"held cancel identity/config barrier");
   @(negedge clk);
  end
  cfg_valid=0;fill_cancel_rsp_ready=1;@(negedge clk);fill_cancel_rsp_ready=0;
 endtask
 task automatic reject_cancel(input logic sl,input logic [63:0] req,input logic [31:0] gen,ep);
  @(negedge clk);fill_cancel_slot=sl;fill_cancel_request=req;fill_cancel_generation=gen;fill_cancel_epoch=ep;fill_cancel_valid=1;
  @(posedge clk);if(fill_cancel_ready||!fill_cancel_reject_valid)$fatal(1,"invalid cancel accepted or silent");
  @(negedge clk);fill_cancel_valid=0;
 endtask
 initial begin
  rd_valid=0;rd_rsp_ready=0;ret_valid=0;rd_m=0;rd_group=0;rd_tag=96'hfeed;
  repeat(5)@(negedge clk);rst_n=1;
  // Keep another physically populated slot leased across every slot0 cancellation.
  configure(1,1);wr_rsp_ready=1;write_groups(4096);consume_cfg;
  @(negedge clk);lease_valid=1;lease_slot=1;lease_request=1;lease_generation=1;lease_epoch=101;
  @(posedge clk);if(!lease_ready)$fatal(1,"other slot lease");@(negedge clk);lease_valid=0;
  configure(0,2);wr_rsp_ready=0;write_groups(1);
  reject_cancel(0,99,2,102);reject_cancel(0,2,99,102);reject_cancel(0,2,2,99);reject_cancel(1,1,1,101);
  // Cancellation priority over a new write, with an actual held write ack.
  @(negedge clk);wr_valid=1;wr_group=1;fill_cancel_valid=1;fill_cancel_slot=0;fill_cancel_request=2;fill_cancel_generation=2;fill_cancel_epoch=102;
  @(posedge clk);if(!fill_cancel_ready||wr_ready)$fatal(1,"cancel lacks write priority");
  @(negedge clk);wr_valid=0;fill_cancel_valid=0;cfg_valid=1;
  repeat(5)begin @(negedge clk);if(!wr_rsp_valid||wr_rsp_row!=0||wr_rsp_group!=0||cfg_ready||cfg_rsp_valid||fill_cancel_rsp_valid)$fatal(1,"cancel erased live ack or published early");end
  cfg_valid=0;wr_rsp_ready=1;consume_cancel(0,2,2,102);
  if(!slot_valid[1]||!slot_leased[1]||dut.coverage!=0||dut.filling)$fatal(1,"other slot/coverage isolation");
  // Already visible success publication must remain visible until consumed.
  configure(0,3);write_groups(4096);wait(cfg_rsp_valid);request_cancel(0,3,3,103);
  repeat(5)begin @(negedge clk);if(!cfg_rsp_valid||cfg_status!=0||cfg_rsp_request!=3||fill_cancel_rsp_valid)$fatal(1,"visible cfg rsp retracted by cancel");end
  consume_cfg;consume_cancel(0,3,3,103);
  // A publication previously consumed is also cancellable while unleased.
  configure(0,4);write_groups(4096);consume_cfg;request_cancel(0,4,4,104);consume_cancel(0,4,4,104);
  // Full coverage with the final real ack held: cancel beats publication.
  configure(0,5);write_groups(4095);@(negedge clk);wr_rsp_ready=0;wr_valid=1;wr_row=127;wr_group=31;wr_data=WORD;
  // Consume penultimate ack to permit accepting last write, then hold that last ack.
  wr_rsp_ready=1;@(posedge clk);if(!wr_ready)$fatal(1,"last write acceptance");@(negedge clk);wr_valid=0;wr_rsp_ready=0;
  request_cancel(0,5,5,105);repeat(4)begin @(negedge clk);if(!wr_rsp_valid||cfg_rsp_valid||fill_cancel_rsp_valid)$fatal(1,"last ack cancel barrier");end
  wr_rsp_ready=1;consume_cancel(0,5,5,105);
  // Real synchronous read proves other slot payload survived.
  @(negedge clk);rd_valid=1;rd_slot=1;rd_request=1;rd_generation=1;rd_epoch=101;
  @(posedge clk);if(!rd_ready)$fatal(1,"other slot real read blocked");@(negedge clk);rd_valid=0;wait(rd_rsp_valid);
  for(integer lane=0;lane<16;lane++)if(rd_rsp_data[256*lane+:256]!==WORD[255:0]||rd_rsp_data[4096+16*lane+:16]!==WORD[271:256])$fatal(1,"other slot payload changed");
  rd_rsp_ready=1;@(negedge clk);rd_rsp_ready=0;ret_valid=1;ret_slot=1;ret_tag=rd_tag;ret_request=1;ret_generation=1;ret_epoch=101;
  @(posedge clk);if(!ret_ready)$fatal(1,"other slot real return");@(negedge clk);ret_valid=0;
  if(writes!=acks||writes!=16385||cancels!=4||publications!=3||slot_valid!=2||slot_leased!=2||read_debt!=0)$fatal(1,"cancel exact counters writes=%0d acks=%0d cancels=%0d pubs=%0d",writes,acks,cancels,publications);
  $display("HARDWARE_AGENT_SIM_PASS M007_A_CANCEL writes=%0d real_acks=%0d cancellations=%0d publications=%0d other_slot_read=1 cycles=%0d",writes,acks,cancels,publications,cycle);$finish;
 end
endmodule
