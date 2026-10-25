`timescale 1ns/1ps
module m011_layer_bank_test #(parameter bit LEGACY=0);
 logic clk=0,rst_n=0;always #5 clk=~clk;
 logic wr_valid,wr_ready,wr_half;logic[1:0]wr_plane;logic[3:0]wr_head;logic[6:0]wr_token;logic[31:0][31:0]wr_data;
 logic[2:0]rd_valid,rd_ready,rd_rsp_valid,rd_rsp_ready;logic[2:0][3:0]rd_head,rd_rsp_head;logic[2:0][6:0]rd_token,rd_rsp_token;logic[2:0][31:0]rd_tag,rd_rsp_tag;logic[2:0][63:0][31:0]rd_rsp_data;
 logic rope_owner_valid;logic[63:0]rope_owner_request_id,rope_wr_request_id;logic[31:0]rope_owner_generation,rope_owner_epoch,rope_wr_generation,rope_wr_epoch;
 logic rope_wr_valid,rope_wr_ready,rope_wr_commit_valid,rope_reject_valid;logic[2:0]rope_reject_code;logic[3:0]rope_wr_head;logic[6:0]rope_wr_token;logic[95:0]rope_wr_tag,rope_wr_commit_tag;logic[63:0][31:0]rope_wr_q,rope_wr_k;
 generate if(LEGACY)begin
 laya_attention_qkv_bank_v1 dut(.*);
 assign rope_wr_ready=0;assign rope_wr_commit_valid=0;assign rope_reject_valid=0;assign rope_reject_code=0;assign rope_wr_commit_tag=0;
 end else begin laya_attention_qkv_bank_v2 dut(.*);end endgenerate
 int writes=0,reads=0,commits=0,rejects=0;
 function automatic logic[31:0]oldword(input int loc,p,c);return 32'h3f000000+loc*65536+p*4096+c;endfunction
 function automatic logic[31:0]newword(input int loc,p,c);return 32'h40000000+loc*65536+p*4096+c;endfunction
 task automatic step;@(posedge clk);#1;endtask
 task automatic narrow(input int loc,p,half);
  @(negedge clk);wr_valid=1;wr_plane=p;wr_head=loc?15:0;wr_token=loc?127:0;wr_half=half;
  for(int c=0;c<32;c++)wr_data[c]=oldword(loc,p,half*32+c);
  #1;if(!wr_ready)$fatal(1,"narrow not ready");step();writes++;
  @(negedge clk);wr_valid=0;
 endtask
 task automatic check_rsp(input int loc,input bit changed,input logic[31:0]tagbase);
  if(rd_rsp_valid!==3'b111)$fatal(1,"missing joined response");
  for(int p=0;p<3;p++)begin
   if(rd_rsp_head[p]!=(loc?15:0)||rd_rsp_token[p]!=(loc?127:0)||rd_rsp_tag[p]!==tagbase+p)$fatal(1,"response identity");
   for(int c=0;c<64;c++)if(rd_rsp_data[p][c]!==((changed&&p<2)?newword(loc,p,c):oldword(loc,p,c)))$fatal(1,"read mismatch loc%0d p%0d c%0d got%x",loc,p,c,rd_rsp_data[p][c]);
  end
 endtask
 task automatic read_hold(input int loc,input bit changed);
  @(negedge clk);rd_valid=7;rd_rsp_ready=0;
  for(int p=0;p<3;p++)begin rd_head[p]=loc?15:0;rd_token[p]=loc?127:0;rd_tag[p]=32'h1200+p;end
  #1;if(rd_ready!==7)$fatal(1,"read ready");step();reads+=3;check_rsp(loc,changed,32'h1200);
  @(negedge clk);rd_valid=0;
  repeat(3)begin step();check_rsp(loc,changed,32'h1200);if(rd_ready!==0)$fatal(1,"held response ready");end
  @(negedge clk);rd_rsp_ready=7;step();if(rd_rsp_valid!==0)$fatal(1,"read consume");
  @(negedge clk);rd_rsp_ready=0;
 endtask
 task automatic bad_identity(input int which);
  @(negedge clk);rope_wr_valid=1;rope_owner_valid=which!=1;rope_wr_request_id=77;rope_wr_generation=8;rope_wr_epoch=9;
  if(which==2)rope_wr_request_id=76;if(which==3)rope_wr_generation=7;if(which==4)rope_wr_epoch=8;
  #1;if(rope_wr_ready||rope_wr_commit_valid||!rope_reject_valid||rope_reject_code!=which)$fatal(1,"reject%0d code%0d",which,rope_reject_code);
  repeat(2)begin step();if(rope_wr_commit_valid)$fatal(1,"rejected commit");end rejects++;
  @(negedge clk);rope_wr_valid=0;rope_owner_valid=1;rope_wr_request_id=77;rope_wr_generation=8;rope_wr_epoch=9;
 endtask
 initial begin
  wr_valid=0;wr_plane=0;wr_head=0;wr_token=0;wr_half=0;wr_data=0;rd_valid=0;rd_rsp_ready=0;rd_head=0;rd_token=0;rd_tag=0;
  rope_owner_valid=0;rope_owner_request_id=77;rope_owner_generation=8;rope_owner_epoch=9;rope_wr_valid=0;rope_wr_request_id=77;rope_wr_generation=8;rope_wr_epoch=9;rope_wr_head=0;rope_wr_token=0;rope_wr_tag=96'h123456789abcdef001122334;rope_wr_q=0;rope_wr_k=0;
  repeat(3)step();@(negedge clk);rst_n=1;
  for(int loc=0;loc<2;loc++)for(int p=0;p<3;p++)for(int h=0;h<2;h++)narrow(loc,p,h);
  read_hold(0,0);read_hold(1,0);
  if(!LEGACY)begin
   for(int e=1;e<=4;e++)bad_identity(e);
   // Accepted same-address Q/K reads win. Entire Q/K write and its tag remain held.
   @(negedge clk);rope_owner_valid=1;rope_wr_valid=1;wr_valid=1;rd_valid=7;rd_rsp_ready=0;
   for(int p=0;p<3;p++)begin rd_head[p]=0;rd_token[p]=0;rd_tag[p]=32'h2300+p;end
   for(int c=0;c<64;c++)begin rope_wr_q[c]=newword(0,0,c);rope_wr_k[c]=newword(0,1,c);end
   #1;if(rope_wr_ready||rope_wr_commit_valid||wr_ready)$fatal(1,"same address collision/owner exclusion");
   step();reads+=3;check_rsp(0,0,32'h2300);
   @(negedge clk);rd_valid=0;#1;if(!rope_wr_ready||!rope_wr_commit_valid||rope_wr_commit_tag!==rope_wr_tag)$fatal(1,"actual commit missing");
   step();commits++;check_rsp(0,0,32'h2300);
   @(negedge clk);rope_wr_valid=0;wr_valid=0;
   repeat(3)begin step();check_rsp(0,0,32'h2300);if(rope_wr_commit_valid)$fatal(1,"fake ack");end
   @(negedge clk);rd_rsp_ready=7;step();@(negedge clk);rd_rsp_ready=0;
   read_hold(0,1);
   // Different-address reads and an atomic boundary write overlap on one 1R1W bank.
   @(negedge clk);rope_wr_valid=1;rope_wr_head=15;rope_wr_token=127;rope_wr_tag=96'hfee123;rd_valid=7;
   for(int p=0;p<3;p++)begin rd_head[p]=0;rd_token[p]=0;rd_tag[p]=32'h3400+p;end
   for(int c=0;c<64;c++)begin rope_wr_q[c]=newword(1,0,c);rope_wr_k[c]=newword(1,1,c);end
   #1;if(!rope_wr_ready||rd_ready!==7)$fatal(1,"different address overlap");step();commits++;reads+=3;check_rsp(0,1,32'h3400);
   @(negedge clk);rope_wr_valid=0;rd_valid=0;rd_rsp_ready=7;step();@(negedge clk);rd_rsp_ready=0;
   read_hold(1,1);
   // Reset clears held-valid, retains payload, then old generation cannot write.
   @(negedge clk);rd_valid=7;for(int p=0;p<3;p++)begin rd_head[p]=15;rd_token[p]=127;end step();reads+=3;
   @(negedge clk);rd_valid=0;rst_n=0;step();if(rd_rsp_valid!==0||rope_wr_ready)$fatal(1,"reset valid");
   @(negedge clk);rst_n=1;rope_owner_generation=9;rope_wr_generation=8;rope_wr_valid=1;#1;
   if(!rope_reject_valid||rope_reject_code!=3||rope_wr_ready)$fatal(1,"old generation accepted");step();rejects++;
   @(negedge clk);rope_wr_valid=0;rope_wr_generation=9;read_hold(0,1);read_hold(1,1);
  end
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_BANK legacy=%0d narrow=%0d plane_reads=%0d atomic_commits=%0d identity_rejects=%0d",LEGACY,writes,reads,commits,rejects);$finish;
 end
 initial begin repeat(2000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
module m011_layer_bank_tb;m011_layer_bank_test #(.LEGACY(0)) t();endmodule
module m011_layer_bank_legacy_tb;m011_layer_bank_test #(.LEGACY(1)) t();endmodule
