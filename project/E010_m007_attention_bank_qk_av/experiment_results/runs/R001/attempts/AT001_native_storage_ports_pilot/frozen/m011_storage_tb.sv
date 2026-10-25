`timescale 1ns/1ps
module m011_storage_tb;
 logic clk=0;always #1.6665 clk=~clk;
 logic rst_n=0,bind_valid=0,bind_ready;
 logic [63:0] bind_request_id=64'h1234,op_request_id=64'h1234,rsp_request_id;
 logic [31:0] bind_generation=7,bind_epoch=9,op_generation=7,op_epoch=9,rsp_generation,rsp_epoch;
 logic [3:0] bind_head=15,rsp_head;logic [2:0] bind_phase=2,op_phase=2,rsp_phase;
 logic idle;
 logic ps_wr_valid=0,ps_wr_ready,ps_wr_rsp_valid,ps_wr_rsp_ready=1;
 logic [1023:0] ps_wr_mask=0;logic [1023:0][3:0] ps_wr_addr=0;logic [1023:0][31:0] ps_wr_data=0;
 logic [95:0] ps_wr_tag=0,ps_wr_rsp_tag;
 logic ps_rd_valid=0,ps_rd_ready,ps_rd_rsp_valid,ps_rd_rsp_ready=1;
 logic [1023:0] ps_rd_mask=0,ps_rd_rsp_mask;logic [1023:0][3:0] ps_rd_addr=0;logic [1023:0][31:0] ps_rd_rsp_data;
 logic [95:0] ps_rd_tag=0,ps_rd_rsp_tag;
 logic g_wr_valid=0,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready=1;
 logic [255:0] g_wr_mask=0;logic [255:0][5:0] g_wr_addr=0;logic [255:0][31:0] g_wr_data=0;
 logic [95:0] g_wr_tag=0,g_wr_rsp_tag;
 logic g_rd_valid=0,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready=1;
 logic [255:0] g_rd_mask=0,g_rd_rsp_mask;logic [255:0][5:0] g_rd_addr=0;logic [255:0][31:0] g_rd_rsp_data;
 logic [95:0] g_rd_tag=0,g_rd_rsp_tag;
 logic context_wr_valid=0,context_wr_ready,context_wr_rsp_valid,context_wr_rsp_ready=1;
 logic [63:0] context_wr_mask=0;logic [63:0][10:0] context_wr_addr=0;logic [63:0][31:0] context_wr_data=0;
 logic [95:0] context_wr_tag=0,context_wr_rsp_tag;
 logic context_rd_valid=0,context_rd_ready,context_rd_rsp_valid,context_rd_rsp_ready=1;
 logic [63:0] context_rd_mask=0,context_rd_rsp_mask;logic [63:0][10:0] context_rd_addr=0;logic [63:0][31:0] context_rd_rsp_data;
 logic [95:0] context_rd_tag=0,context_rd_rsp_tag;

 laya_attention_storage_v1 dut(.*);
 int cycle=0;
 task automatic bind_now;
  @(negedge clk);bind_valid=1;@(posedge clk);if(!bind_ready)$fatal(1,"STORAGE_BIND");@(negedge clk);bind_valid=0;
 endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;bind_now();
  @(negedge clk);ps_wr_mask[0]=1;ps_wr_mask[1023]=1;ps_wr_addr[0]=0;ps_wr_addr[1023]=15;
  ps_wr_data[0]=32'h11111111;ps_wr_data[1023]=32'haaaaaaaa;ps_wr_tag=96'h101;ps_wr_valid=1;ps_wr_rsp_ready=0;
  @(posedge clk);if(!ps_wr_ready)$fatal(1,"STORAGE_PS_WRITE");
  @(negedge clk);ps_wr_valid=0;bind_valid=1;
  repeat(3)begin
   @(negedge clk);if(!ps_wr_rsp_valid||ps_wr_rsp_tag!==96'h101||bind_ready||idle)$fatal(1,"STORAGE_COMMIT_HOLD");
  end
  bind_valid=0;ps_wr_rsp_ready=1;
  @(negedge clk);ps_rd_mask=ps_wr_mask;ps_rd_addr=ps_wr_addr;ps_rd_tag=96'h102;ps_rd_valid=1;ps_rd_rsp_ready=0;
  @(posedge clk);if(!ps_rd_ready)$fatal(1,"STORAGE_PS_READ");
  @(negedge clk);ps_rd_valid=0;
  repeat(3)begin
   if(!ps_rd_rsp_valid||ps_rd_rsp_tag!==96'h102||ps_rd_rsp_data[0]!==32'h11111111||ps_rd_rsp_data[1023]!==32'haaaaaaaa)$fatal(1,"STORAGE_PS_DATA_HOLD");
   @(negedge clk);
  end
  ps_rd_rsp_ready=1;
  @(negedge clk);ps_rd_valid=1;ps_wr_valid=1;ps_wr_data[0]=32'h22222222;ps_rd_rsp_ready=1;
  #0.1;if(!ps_rd_ready||ps_wr_ready)$fatal(1,"STORAGE_COLLISION_PRIORITY");
  @(negedge clk);ps_rd_valid=0;ps_wr_valid=0;
  if(ps_rd_rsp_data[0]!==32'h11111111)$fatal(1,"STORAGE_COLLISION_MUTATED");
  @(negedge clk);g_wr_mask[0]=1;g_wr_mask[255]=1;g_wr_addr[255]=63;g_wr_data[0]=32'h33333333;g_wr_data[255]=32'hbbbbbbbb;g_wr_tag=96'h201;g_wr_valid=1;
  context_wr_mask[0]=1;context_wr_mask[63]=1;context_wr_addr[63]=2047;context_wr_data[0]=32'h44444444;context_wr_data[63]=32'hcccccccc;context_wr_tag=96'h301;context_wr_valid=1;
  @(posedge clk);if(!g_wr_ready||!context_wr_ready)$fatal(1,"STORAGE_G_CONTEXT_WRITE");
  @(negedge clk);g_wr_valid=0;context_wr_valid=0;
  g_rd_mask=g_wr_mask;g_rd_addr=g_wr_addr;g_rd_tag=96'h202;g_rd_valid=1;
  context_rd_mask=context_wr_mask;context_rd_addr=context_wr_addr;context_rd_tag=96'h302;context_rd_valid=1;
  @(posedge clk);if(!g_rd_ready||!context_rd_ready)$fatal(1,"STORAGE_G_CONTEXT_READ");
  @(negedge clk);g_rd_valid=0;context_rd_valid=0;
  if(!g_rd_rsp_valid||g_rd_rsp_data[0]!==32'h33333333||g_rd_rsp_data[255]!==32'hbbbbbbbb||
     !context_rd_rsp_valid||context_rd_rsp_data[0]!==32'h44444444||context_rd_rsp_data[63]!==32'hcccccccc||
     rsp_request_id!==64'h1234||rsp_generation!==7||rsp_epoch!==9||rsp_head!==15||rsp_phase!==2)$fatal(1,"STORAGE_G_CONTEXT_ID_DATA");
  @(negedge clk);op_generation=6;ps_rd_valid=1;
  #0.1;if(ps_rd_ready)$fatal(1,"STORAGE_OLD_GENERATION_ACCEPT");
  @(negedge clk);ps_rd_valid=0;op_generation=7;
  repeat(3)@(negedge clk);if(!idle)$fatal(1,"STORAGE_NOT_IDLE");
  bind_generation=8;op_generation=8;bind_epoch=10;op_epoch=10;bind_phase=4;op_phase=4;bind_now();
  @(negedge clk);g_rd_valid=1;g_rd_rsp_ready=0;
  @(posedge clk);if(!g_rd_ready)$fatal(1,"STORAGE_NEW_OWNER_READ");
  @(negedge clk);g_rd_valid=0;rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;g_rd_rsp_ready=1;
  repeat(3)@(negedge clk);if(!idle||g_rd_rsp_valid||ps_rd_rsp_valid||context_rd_rsp_valid)$fatal(1,"STORAGE_RESET_DEBT");
  $display("HARDWARE_AGENT_SIM_PASS M011_STORAGE ps_banks=1024 depth16 g_banks=256 depth64 context_banks=64 depth2048 held=3 collision=1 generation_reject=1 reset_debt=1");$finish;
 end
 always @(posedge clk)begin cycle++;if(cycle>200)$fatal(1,"STORAGE_TIMEOUT");end
endmodule
