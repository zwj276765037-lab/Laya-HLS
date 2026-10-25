`timescale 1ns/1ps
module m011_layer_coeff_tb;
 logic clk=0,rst_n=0;always #5 clk=~clk;
 logic bind_valid,bind_ready,bound_valid;logic[63:0]bind_model_id,bound_model_id,wr_model_id;logic[31:0]bind_numeric_id,bound_numeric_id,wr_numeric_id;logic[127:0]bind_table_key,bound_table_key,wr_table_key;
 logic[1:0]family_complete,wr_table;logic wr_valid,wr_ready,wr_half,wr_reject_valid;logic[6:0]wr_row;logic[31:0][31:0]wr_data;logic[2:0]wr_reject_code;logic[4:0]wr_nonfinite_lane;
 logic owner_valid;logic[63:0]owner_request_id,rd_request_id;logic[31:0]owner_generation,owner_epoch,rd_generation,rd_epoch;
 logic rd_valid,rd_ready,rd_family,rd_reject_valid,rsp_valid,rsp_ready,rsp_family;logic[6:0]rd_row,rsp_row;logic[95:0]rd_tag,rsp_tag;logic[2:0]rd_reject_code;logic[127:0][31:0]rsp_data;
 logic[31:0]cf[0:8191],sf[0:8191],cs[0:8191],ss[0:8191];string data;int writes=0,reads=0,words=0;
 laya_rope_coeff_cache_v1 dut(.*);
 function automatic logic[31:0]gold(input int t,r,c);case(t)0:return cf[r*64+c];1:return sf[r*64+c];2:return cs[r*64+c];3:return ss[r*64+c];endcase endfunction
 task automatic step;@(posedge clk);#1;endtask
 task automatic load(input int t,r,h);
  @(negedge clk);wr_valid=1;wr_table=t;wr_row=r;wr_half=h;for(int c=0;c<32;c++)wr_data[c]=gold(t,r,h*32+c);
  #1;if(!wr_ready||wr_reject_valid)$fatal(1,"coeff load rejected t%0d r%0d h%0d",t,r,h);step();writes++;
 endtask
 task automatic check(input int f,r);
  if(!rsp_valid||rsp_family!=f||rsp_row!=r||rsp_tag!==96'(f*128+r))$fatal(1,"coeff response identity");
  for(int b=0;b<128;b++)if(rsp_data[b]!==gold(f*2+b/64,r,b%64))$fatal(1,"coeff mismatch f%0d r%0d b%0d got%x",f,r,b,rsp_data[b]);
 endtask
 task automatic readrow(input int f,r,input bit held);
  @(negedge clk);rd_valid=1;rd_family=f;rd_row=r;rd_tag=96'(f*128+r);rsp_ready=0;#1;if(!rd_ready||rd_reject_valid)$fatal(1,"coeff read rejected");step();reads++;words+=128;check(f,r);
  @(negedge clk);rd_valid=0;
  if(held)repeat(3)begin step();check(f,r);if(rd_ready)$fatal(1,"coeff held ready");end
  rsp_ready=1;step();@(negedge clk);rsp_ready=0;
 endtask
 initial begin
  if(!$value$plusargs("DATA=%s",data))$fatal(1,"DATA required");$readmemh({data,"/cos_full.mem"},cf);$readmemh({data,"/sin_full.mem"},sf);$readmemh({data,"/cos_slide.mem"},cs);$readmemh({data,"/sin_slide.mem"},ss);
  bind_valid=0;bind_model_id=64'h12;bind_numeric_id=32'h34;bind_table_key=128'h5678;wr_model_id=bind_model_id;wr_numeric_id=bind_numeric_id;wr_table_key=bind_table_key;wr_valid=0;wr_table=0;wr_row=0;wr_half=0;wr_data=0;owner_valid=0;owner_request_id=77;owner_generation=8;owner_epoch=9;rd_valid=0;rd_family=0;rd_row=0;rd_tag=0;rd_request_id=77;rd_generation=8;rd_epoch=9;rsp_ready=0;
  repeat(3)step();@(negedge clk);rst_n=1;bind_valid=1;#1;if(!bind_ready)$fatal(1,"bind ready");step();@(negedge clk);bind_valid=0;
  if(!bound_valid||family_complete!=0)$fatal(1,"bind coverage");
  wr_valid=1;wr_table_key=128'h5679;#1;if(wr_ready||!wr_reject_valid||wr_reject_code!=3)$fatal(1,"wrong coefficient key accepted");step();@(negedge clk);wr_valid=0;wr_table_key=bind_table_key;
  for(int t=0;t<4;t++)for(int r=0;r<128;r++)for(int h=0;h<2;h++)begin
   if(t==1&&r==127&&h==1&&family_complete[0])$fatal(1,"premature table complete");load(t,r,h);
  end
  @(negedge clk);wr_valid=0;if(family_complete!==3)$fatal(1,"table incomplete");
  // A finite fault invalidates the exact real half and cannot mark coverage.
  wr_valid=1;wr_table=0;wr_row=0;wr_half=0;for(int c=0;c<32;c++)wr_data[c]=gold(0,0,c);wr_data[7]=32'h7fc00001;#1;
  if(!wr_ready||!wr_reject_valid||wr_reject_code!=4||wr_nonfinite_lane!=7)$fatal(1,"nonfinite load");step();if(family_complete[0])$fatal(1,"bad coefficients complete");
  load(0,0,0);@(negedge clk);wr_valid=0;owner_valid=1;#1;if(family_complete!==3||bind_ready||wr_ready)$fatal(1,"owner exclusion");
  rd_valid=1;rd_generation=7;#1;if(rd_ready||!rd_reject_valid||rd_reject_code!=2)$fatal(1,"old generation coefficient read");step();@(negedge clk);rd_valid=0;rd_generation=8;
  for(int f=0;f<2;f++)for(int r=0;r<128;r++)readrow(f,r,r==127);
  // Rebind stays blocked by a held actual response after owner release.
  @(negedge clk);rd_valid=1;rd_family=1;rd_row=127;rd_tag=255;step();reads++;check(1,127);
  @(negedge clk);rd_valid=0;owner_valid=0;bind_valid=1;#1;if(bind_ready)$fatal(1,"rebind destroyed held coefficient");repeat(3)begin step();check(1,127);end
  @(negedge clk);rsp_ready=1;step();@(negedge clk);rsp_ready=0;#1;if(!bind_ready)$fatal(1,"drained rebind");step();@(negedge clk);bind_valid=0;if(family_complete!=0)$fatal(1,"rebind old coverage");
  owner_valid=1;rd_valid=1;#1;if(rd_ready||rd_reject_code!=3)$fatal(1,"missing coefficients accepted");step();@(negedge clk);rd_valid=0;owner_valid=0;rst_n=0;step();if(bound_valid||rsp_valid||family_complete!=0)$fatal(1,"reset cache validity");
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_COEFF accepted_writes=%0d returned_rows=%0d independent_words=%0d all_four_original_tables=1",writes,reads,words);$finish;
 end
 initial begin repeat(10000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
