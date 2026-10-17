`timescale 1ns/1ps
module tanh_libm_stream_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,in_valid=0,out_ready=0;
 reg [31:0] in_data=0,in_tag=0;
 wire in_ready,out_valid; wire [31:0] out_data,out_tag,out_status;
 tanh_libm_stream_wrapper dut(.*);
 reg [31:0] x[0:3269],gold[0:3269];
 reg [31:0] tags[0:9999];
 integer ordinals[0:9999],accept_cycles[0:9999];
 integer count=3270,cycle=0,mode=0,accepted=0,retired=0,produced=0;
 integer first_accept=0,last_accept=0,last_retire=0,min_gap=2147483647,max_gap=0;
 integer latency=-1,credit_peak=0,pressure_stops=0,first_valid=0;
 integer ordinal,gotlat,i,pilot=0;
 integer div0_issue=0,div0_return=0,div1_issue=0,div1_return=0;
 // Actual generated call schedule: dexp SV250..262, dtanh SV357..369.
 // Child ap_ce is a clock enable, not a token handshake. Count only the
 // corresponding parent token-valid stage at actual operand/capture edges.
 wire div0_issue_valid=dut.leaf.ap_enable_reg_pp0_iter250 && dut.leaf.grp_stream_div_node_0_s_fu_448_ap_ce;
 wire div0_return_valid=dut.leaf.ap_enable_reg_pp0_iter262 && !dut.leaf.ap_block_pp0_stage0_11001_ignoreCallOp911;
 wire div1_issue_valid=dut.leaf.ap_enable_reg_pp0_iter357 && dut.leaf.grp_stream_div_node_1_s_fu_524_ap_ce;
 wire div1_return_valid=dut.leaf.ap_enable_reg_pp0_iter369 && !dut.leaf.ap_block_pp0_stage0_11001_ignoreCallOp1125;
 reg was_stalled=0;
 reg [31:0] stall_data,stall_tag,stall_status;
 string xf,gf;
 always @(negedge clk) begin
  if(reset||mode==2) out_ready<=0;
  else if(mode==1) out_ready<=((cycle%17)>=6 && (cycle%53)>=9);
  else out_ready<=1;
  if(!reset) begin
   if(dut.credits!==accepted-retired || dut.returned!==produced-retired ||
      dut.credits>512 || dut.returned>dut.credits) $fatal(1,"STREAM_CREDIT_CONSERVATION");
   if(dut.credits>credit_peak) credit_peak=dut.credits;
   if(dut.credits==512 && in_ready) $fatal(1,"STREAM_OVERCREDIT");
  end
 end
 always @(posedge clk) begin
  cycle=cycle+1; if(cycle>40000000) $fatal(1,"STREAM_CYCLE_CAP");
  if(reset) begin was_stalled=0; end
  else begin
   if(was_stalled && (!out_valid || {out_data,out_tag,out_status}!=={stall_data,stall_tag,stall_status}))
      $fatal(1,"STREAM_UNSTABLE_RETURN");
   was_stalled=out_valid&&!out_ready;
   if(was_stalled) begin stall_data=out_data; stall_tag=out_tag; stall_status=out_status; end
   if(in_valid&&in_ready) begin
    if(accepted>=10000) $fatal(1,"STREAM_SCOREBOARD_CAP");
    tags[accepted]=in_tag; ordinals[accepted]=in_tag&65535; accept_cycles[accepted]=cycle;
    if(!first_accept) first_accept=cycle;
    if(last_accept) begin
     if(cycle-last_accept<min_gap) min_gap=cycle-last_accept;
     if(cycle-last_accept>max_gap) max_gap=cycle-last_accept;
    end
    last_accept=cycle; accepted=accepted+1;
   end else if(in_valid && dut.credits==512) pressure_stops=pressure_stops+1;
   if(div0_issue_valid) begin
    if(div0_issue>=accepted || cycle-accept_cycles[div0_issue]!=250 ||
       $isunknown({dut.leaf.grp_stream_div_node_0_s_fu_448.a,dut.leaf.grp_stream_div_node_0_s_fu_448.b}))
     $fatal(1,"STREAM_DIV0_ISSUE");
    div0_issue=div0_issue+1;
   end
   if(div0_return_valid) begin
    if(div0_return>=div0_issue || cycle-accept_cycles[div0_return]!=262 ||
       $isunknown(dut.leaf.grp_stream_div_node_0_s_fu_448_ap_return)) $fatal(1,"STREAM_DIV0_RETURN");
    div0_return=div0_return+1;
   end
   if(div1_issue_valid) begin
    if(div1_issue>=accepted || cycle-accept_cycles[div1_issue]!=357 ||
       $isunknown({dut.leaf.grp_stream_div_node_1_s_fu_524.a,dut.leaf.grp_stream_div_node_1_s_fu_524.b}))
     $fatal(1,"STREAM_DIV1_ISSUE");
    div1_issue=div1_issue+1;
   end
   if(div1_return_valid) begin
    if(div1_return>=div1_issue || cycle-accept_cycles[div1_return]!=369 ||
       $isunknown(dut.leaf.grp_stream_div_node_1_s_fu_524_ap_return)) $fatal(1,"STREAM_DIV1_RETURN");
    div1_return=div1_return+1;
   end
   if(dut.result_valid) begin
    if(produced>=accepted || $isunknown(dut.leaf_result)) $fatal(1,"STREAM_UNRESERVED_RETURN");
    ordinal=ordinals[produced]; gotlat=cycle-accept_cycles[produced];
    if(latency<0) latency=gotlat;
    if(gotlat!=latency) $fatal(1,"STREAM_VARIABLE_EXTERNAL_LATENCY index=%0d got=%0d expected=%0d",produced,gotlat,latency);
    if(dut.leaf_result!==gold[ordinal]) $fatal(1,"STREAM_CORE_NUMERIC index=%0d ordinal=%0d x=%08x got=%08x gold=%08x",produced,ordinal,x[ordinal],dut.leaf_result,gold[ordinal]);
    produced=produced+1;
   end
   if(out_valid&&!first_valid) first_valid=cycle;
   if(out_valid&&out_ready) begin
    if(retired>=produced || $isunknown({out_data,out_tag,out_status}) || out_tag!==tags[retired])
      $fatal(1,"STREAM_TAG_OR_DEBT");
    ordinal=ordinals[retired];
    if(out_data!==gold[ordinal] || out_status!==((x[ordinal]&32'h7fffffff)>=32'h7f800000 ? 32'd1 : 32'd0))
      $fatal(1,"STREAM_NUMERIC_STATUS ordinal=%0d x=%08x got=%08x gold=%08x",ordinal,x[ordinal],out_data,gold[ordinal]);
    retired=retired+1; last_retire=cycle;
    if((retired%128)==0) $display("TANH_PROGRESS stream mode=%0d accepted=%0d produced=%0d retired=%0d credit=%0d cycle=%0d",mode,accepted,produced,retired,dut.credits,cycle);
   end
  end
 end
 task prepare;
  begin
   accepted=0; retired=0; produced=0; first_accept=0; last_accept=0; last_retire=0;
   first_valid=0; min_gap=2147483647; max_gap=0; credit_peak=0; pressure_stops=0; latency=-1;
   div0_issue=0; div0_return=0; div1_issue=0; div1_return=0;
  end
 endtask
 task clean_reset;
  begin
   @(negedge clk); reset=1; in_valid=0;
   repeat(4) @(negedge clk); prepare(); reset=0;
   repeat(2000) begin @(posedge clk); if(out_valid||dut.result_valid) $fatal(1,"STREAM_OLD_EPOCH_RETURN"); end
  end
 endtask
 task feed(input integer n,input integer ep,input integer mixed);
  integer k,idx;
  begin
   @(negedge clk); in_valid=1;
   for(k=0;k<n;k=k+1) begin
    idx=mixed?(k*73)%3270:k;
    in_data=x[idx]; in_tag=(ep<<16)|idx;
    do @(posedge clk); while(!in_ready);
    @(negedge clk);
   end
   in_valid=0;
  end
 endtask
 task profile(input integer md,input integer n,input integer ep);
  begin
   mode=md; prepare(); feed(n,ep,0); wait(retired==n); @(negedge clk);
   if(dut.credits||dut.returned||out_valid||accepted!=produced||accepted!=retired)
     $fatal(1,"STREAM_FINAL_DEBT");
   if(div0_issue!=n || div0_return!=n || div1_issue!=n || div1_return!=n)
     $fatal(1,"STREAM_DIV_FINAL_DEBT");
   $display("TANH_STREAM_PROFILE_PASS mode=%0d count=%0d first_accept=%0d first_valid=%0d last_retire=%0d span=%0d min_gap=%0d max_gap=%0d core_fixed_latency=%0d peak_credit=%0d credit_stops=%0d",md,n,first_accept,first_valid,last_retire,last_retire-first_accept,min_gap,max_gap,latency,credit_peak,pressure_stops);
   $display("TANH_STREAM_DIVIDER_PASS mode=%0d div0_issue=%0d div0_return=%0d div1_issue=%0d div1_return=%0d call_stages=250,357 capture_stages=262,369",md,div0_issue,div0_return,div1_issue,div1_return);
  end
 endtask
 initial begin
  if(!$value$plusargs("X_FILE=%s",xf)||!$value$plusargs("GOLD_FILE=%s",gf)) $fatal(1,"STREAM_MISSING_FIXTURE");
  if($value$plusargs("COUNT=%d",count)) begin end
  if($value$plusargs("PILOT=%d",pilot)) begin end
  $readmemh(xf,x); $readmemh(gf,gold);
  for(i=0;i<3270;i=i+1) if($isunknown({x[i],gold[i]})) $fatal(1,"STREAM_UNKNOWN_FIXTURE");
  clean_reset();
  if(pilot) begin
   profile(0,128,1); $display("TANH_STREAM_PILOT_PASS count=128"); $finish;
  end
  mode=2; prepare(); feed(128,1,1); repeat(20) @(posedge clk); clean_reset();
  mode=2; prepare(); feed(32,2,1); wait(dut.returned==32); repeat(20) @(posedge clk); clean_reset();
  profile(0,count,3); profile(1,count,4);
  mode=2; prepare();
  fork
   feed(640,5,1);
   begin
    wait(dut.credits==512); repeat(50) begin @(posedge clk); if(in_ready) $fatal(1,"STREAM_FULL_CREDIT_READY"); end
    wait(dut.returned==512); @(negedge clk); mode=0;
   end
  join
  wait(retired==640); @(negedge clk);
  if(credit_peak!=512 || !pressure_stops || dut.credits || dut.returned) $fatal(1,"STREAM_CREDIT_FILL_DRAIN");
  if(div0_issue!=640 || div0_return!=640 || div1_issue!=640 || div1_return!=640) $fatal(1,"STREAM_CREDIT_DIV_DEBT");
  $display("TANH_STREAM_CREDIT_PASS count=640 peak=512 stops=%0d fixed_latency=%0d",pressure_stops,latency);
  $display("TANH_STREAM_RTL_PASS count=%0d profiles=2 mixed_credit=640 reset_inflight=1 reset_pending=1 cycles=%0d",count,cycle);
  $finish;
 end
endmodule
