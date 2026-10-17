`timescale 1ns/1ps
// Arithmetic probes of the exact frozen classes used by the tile. These
// testbench instances are excluded from module OOC; full tile routing is
// checked independently by the production fixture and tagged intermediates.
module attention_tile_helpers_tb;
 reg clk=0;always #5 clk=~clk;
 reg rst=1,ce=1,issue=0;
 reg [31:0] a[0:3],b[0:3];wire [31:0] d[0:3];
 reg [31:0] pairs[0:1214];reg [31:0] exp_x[0:3];wire [31:0] exp_y[0:3];
 reg [31:0] directed_x[0:11],directed_y[0:11],expected_exp[0:3];
 reg [3:0] exp_start=0,exp_active=0,exp_retired=0;
 wire [3:0] exp_done,exp_idle,exp_ready;
 genvar g;
 generate for(g=0;g<4;g=g+1)begin: lanes
  tanh_libm_stream_leaf_stream_div_node_0_s div(.ap_clk(clk),.ap_rst(rst),.ap_ce(ce|rst),.a(a[g]),.b(b[g]),.ap_return(d[g]));
  laya_attention_service_attention_exp_bits exp(.ap_clk(clk),.ap_rst(rst),.ap_ce(ce),.laya_global_ce(ce|rst),.ap_start(exp_start[g]),.ap_done(exp_done[g]),.ap_idle(exp_idle[g]),.ap_ready(exp_ready[g]),.x(exp_x[g]),.ap_return(exp_y[g]));
 end endgenerate
 reg [11:0] valid=0;reg [31:0] gold[0:11][0:3],next_gold[0:3];
 integer checked_d=0,checked_exp=0,cycle=0,enabled=0,exp_began[0:3];
 string fixture,trace_dir;
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>10000)$fatal(1,"Helper cap");
  if(rst)begin valid<=0;exp_active<=0;exp_retired<=0;end
  else if(ce)begin
   enabled=enabled+1;
   if(valid[11])for(integer n=0;n<4;n=n+1)begin
    if(d[n]!==gold[11][n])$fatal(1,"Directed D%0d got=%08x gold=%08x",n,d[n],gold[11][n]);checked_d=checked_d+1;
   end
   valid<={valid[10:0],issue};for(integer n=0;n<4;n=n+1)gold[0][n]<=next_gold[n];
   for(integer t=1;t<12;t=t+1)for(integer n=0;n<4;n=n+1)gold[t][n]<=gold[t-1][n];
   for(integer n=0;n<4;n=n+1)begin
    if(exp_start[n])begin exp_active[n]<=1;exp_retired[n]<=0;exp_began[n]=enabled;end
    else if(exp_active[n]&&exp_done[n])begin
     if(exp_y[n]!==expected_exp[n])$fatal(1,"Directed EXP%0d input=%08x got=%08x gold=%08x",n,exp_x[n],exp_y[n],expected_exp[n]);
     $display("ATTENTION_EXP_QUAD_RETURN worker=%0d x=%08x y=%08x enabled_gap=%0d",n,exp_x[n],exp_y[n],enabled-exp_began[n]);
     checked_exp=checked_exp+1;exp_active[n]<=0;exp_retired[n]<=1;
    end
   end
  end
 end
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("TRACE=%s",trace_dir))$fatal(1,"Probe fixtures required");
  $readmemh({trace_dir,"/div_directed.mem"},pairs);
  $readmemh({fixture,"/exp_directed_x.mem"},directed_x);$readmemh({fixture,"/exp_directed_gold.mem"},directed_y);
  for(integer n=0;n<4;n=n+1)begin a[n]=0;b[n]='h3f800000;next_gold[n]=0;exp_x[n]=0;expected_exp[n]=0;end
  repeat(8)@(negedge clk);rst=0;
  for(integer n=0;n<405;n=n+1)begin
   @(negedge clk);issue=1;
   for(integer lane=0;lane<4;lane=lane+1)begin integer ix;ix=(n+lane*101)%405;a[lane]=pairs[3*ix];b[lane]=pairs[3*ix+1];next_gold[lane]=pairs[3*ix+2];end
   if(n==100)begin ce=0;repeat(8)@(negedge clk);ce=1;end
  end
  @(negedge clk);issue=0;while(checked_d<1620)@(negedge clk);
  if(checked_d!=1620)$fatal(1,"Directed D coverage");
  for(integer n=0;n<12;n=n+1)begin
   @(negedge clk);for(integer lane=0;lane<4;lane=lane+1)begin integer ix;ix=(n+lane*3)%12;exp_x[lane]=directed_x[ix];expected_exp[lane]=directed_y[ix];end exp_start=15;
   @(negedge clk);exp_start=0;
   while(exp_retired!=15)@(negedge clk);
  end
  if(checked_exp!=48)$fatal(1,"Directed exp coverage");
  $display("ATTENTION_SERVICE_TILE_HELPER_PASS div4=1620 exp4=48 original_directed_gold=1 CE_div_inflight=1 cycles=%0d",cycle);
  $finish;
 end
endmodule
