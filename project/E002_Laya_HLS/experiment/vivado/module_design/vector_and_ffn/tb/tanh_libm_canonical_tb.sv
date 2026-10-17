`timescale 1ns/1ps
module tanh_libm_canonical_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,in_valid=0,out_ready=0;
 reg [31:0] in_data=0,in_tag=0;
 wire in_ready,out_valid; wire [31:0] out_data,out_tag,out_status;
 tanh_libm_canonical_wrapper dut(.*);
 reg [31:0] x[0:3269],gold[0:3269];
 reg [31:0] tags[0:9999];
 integer ordinals[0:9999],accept_cycles[0:9999];
 integer count=3270,cycle=0,mode=0,accepted=0,retired=0,produced=0;
 integer first_accept=0,last_accept=0,last_retire=0,min_gap=2147483647,max_gap=0;
 integer latency=-1,credit_peak=0,pressure_stops=0,first_valid=0;
 integer ordinal,gotlat,i,pilot=0;
 integer div0_issue=0,div0_return=0,div1_issue=0,div1_return=0;

 reg [31:0] trace_gold[0:412019];
 reg source_valid[0:1023];integer source_ordinal[0:1023];
 integer node_issued[0:41],node_returned[0:41];
 string tf;
 task check_node(input integer slot,input integer launch,input integer sample_edge,
                 input issue_valid,input [31:0] a,b,result);
  integer src,ord;
  reg expected_valid;
  begin
   src=(cycle-launch)%1024;
   expected_valid=cycle>=launch && source_valid[src];
   if(issue_valid!==expected_valid)
    $fatal(1,"CANONICAL_NODE_TOKEN slot=%0d launch=%0d cycle=%0d",slot,launch,cycle);
   if(issue_valid) begin
    ord=source_ordinal[src];
    if(a!==trace_gold[(ord*42+slot)*3] || b!==trace_gold[(ord*42+slot)*3+1])
     $fatal(1,"CANONICAL_NODE_OPERAND slot=%0d ordinal=%0d a=%08x/%08x b=%08x/%08x cycle=%0d",slot,ord,a,trace_gold[(ord*42+slot)*3],b,trace_gold[(ord*42+slot)*3+1],cycle);
    node_issued[slot]=node_issued[slot]+1;
    if(slot==40)div0_issue=div0_issue+1;
    if(slot==41)div1_issue=div1_issue+1;
   end else if(a!==0 || b!==(slot<23?32'b0:32'h3f800000))
    $fatal(1,"CANONICAL_UNSAFE_BUBBLE slot=%0d a=%08x b=%08x",slot,a,b);
   src=(cycle-sample_edge)%1024;
   if(cycle>=sample_edge && source_valid[src]) begin
    ord=source_ordinal[src];
    if(result!==trace_gold[(ord*42+slot)*3+2])
     $fatal(1,"CANONICAL_NODE_RESULT slot=%0d ordinal=%0d got=%08x gold=%08x sample_edge=%0d cycle=%0d",slot,ord,result,trace_gold[(ord*42+slot)*3+2],sample_edge,cycle);
    node_returned[slot]=node_returned[slot]+1;
    if(node_returned[slot]>node_issued[slot])$fatal(1,"CANONICAL_NODE_UNRESERVED_RETURN");
    if(slot==40)div0_return=div0_return+1;
    if(slot==41)div1_return=div1_return+1;
   end
  end
 endtask
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
  if(reset) begin was_stalled=0;for(integer r=0;r<1024;r=r+1)source_valid[r]=0;end
  else begin
   source_valid[cycle%1024]=in_valid&&in_ready;source_ordinal[cycle%1024]=in_tag&65535;
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
   check_node(23,2,16,dut.core.mul0_issue_valid,dut.core.mul0_a,dut.core.mul0_b,dut.core.mul0);
   check_node(24,16,30,dut.core.mul1_issue_valid,dut.core.mul1_a,dut.core.mul1_b,dut.core.mul1);
   check_node(0,30,36,dut.core.add0_issue_valid,dut.core.add0_a,dut.core.add0_b,dut.core.add0);
   check_node(25,38,52,dut.core.mul2_issue_valid,dut.core.mul2_a,dut.core.mul2_b,dut.core.mul2);
   check_node(26,38,52,dut.core.mul3_issue_valid,dut.core.mul3_a,dut.core.mul3_b,dut.core.mul3);
   check_node(1,52,58,dut.core.add1_issue_valid,dut.core.add1_a,dut.core.add1_b,dut.core.add1);
   check_node(2,58,64,dut.core.add2_issue_valid,dut.core.add2_a,dut.core.add2_b,dut.core.add2);
   check_node(3,65,71,dut.core.add3_issue_valid,dut.core.add3_a,dut.core.add3_b,dut.core.add3);
   check_node(4,71,77,dut.core.add4_issue_valid,dut.core.add4_a,dut.core.add4_b,dut.core.add4);
   check_node(27,65,79,dut.core.mul4_issue_valid,dut.core.mul4_a,dut.core.mul4_b,dut.core.mul4);
   check_node(28,79,93,dut.core.mul5_issue_valid,dut.core.mul5_a,dut.core.mul5_b,dut.core.mul5);
   check_node(29,93,107,dut.core.mul6_issue_valid,dut.core.mul6_a,dut.core.mul6_b,dut.core.mul6);
   check_node(5,107,113,dut.core.add5_issue_valid,dut.core.add5_a,dut.core.add5_b,dut.core.add5);
   check_node(30,113,127,dut.core.mul7_issue_valid,dut.core.mul7_a,dut.core.mul7_b,dut.core.mul7);
   check_node(6,127,133,dut.core.add6_issue_valid,dut.core.add6_a,dut.core.add6_b,dut.core.add6);
   check_node(31,133,147,dut.core.mul8_issue_valid,dut.core.mul8_a,dut.core.mul8_b,dut.core.mul8);
   check_node(7,147,153,dut.core.add7_issue_valid,dut.core.add7_a,dut.core.add7_b,dut.core.add7);
   check_node(32,153,167,dut.core.mul9_issue_valid,dut.core.mul9_a,dut.core.mul9_b,dut.core.mul9);
   check_node(8,167,173,dut.core.add8_issue_valid,dut.core.add8_a,dut.core.add8_b,dut.core.add8);
   check_node(33,173,187,dut.core.mul10_issue_valid,dut.core.mul10_a,dut.core.mul10_b,dut.core.mul10);
   check_node(9,187,193,dut.core.add9_issue_valid,dut.core.add9_a,dut.core.add9_b,dut.core.add9);
   check_node(34,193,207,dut.core.mul11_issue_valid,dut.core.mul11_a,dut.core.mul11_b,dut.core.mul11);
   check_node(10,207,213,dut.core.add10_issue_valid,dut.core.add10_a,dut.core.add10_b,dut.core.add10);
   check_node(35,213,227,dut.core.mul12_issue_valid,dut.core.mul12_a,dut.core.mul12_b,dut.core.mul12);
   check_node(11,213,219,dut.core.add11_issue_valid,dut.core.add11_a,dut.core.add11_b,dut.core.add11);
   check_node(12,227,233,dut.core.add12_issue_valid,dut.core.add12_a,dut.core.add12_b,dut.core.add12);
   check_node(40,233,245,dut.core.div0_issue_valid,dut.core.div0_a,dut.core.div0_b,dut.core.div0);
   check_node(36,245,259,dut.core.mul13_issue_valid,dut.core.mul13_a,dut.core.mul13_b,dut.core.mul13);
   check_node(13,259,265,dut.core.add13_issue_valid,dut.core.add13_a,dut.core.add13_b,dut.core.add13);
   check_node(37,266,280,dut.core.mul14_issue_valid,dut.core.mul14_a,dut.core.mul14_b,dut.core.mul14);
   check_node(14,280,286,dut.core.add14_issue_valid,dut.core.add14_a,dut.core.add14_b,dut.core.add14);
   check_node(15,286,292,dut.core.add15_issue_valid,dut.core.add15_a,dut.core.add15_b,dut.core.add15);
   check_node(16,294,300,dut.core.add16_issue_valid,dut.core.add16_a,dut.core.add16_b,dut.core.add16);
   check_node(17,294,300,dut.core.add17_issue_valid,dut.core.add17_a,dut.core.add17_b,dut.core.add17);
   check_node(18,301,307,dut.core.add18_issue_valid,dut.core.add18_a,dut.core.add18_b,dut.core.add18);
   check_node(38,308,322,dut.core.mul15_issue_valid,dut.core.mul15_a,dut.core.mul15_b,dut.core.mul15);
   check_node(19,323,329,dut.core.add19_issue_valid,dut.core.add19_a,dut.core.add19_b,dut.core.add19);
   check_node(20,331,337,dut.core.add20_issue_valid,dut.core.add20_a,dut.core.add20_b,dut.core.add20);
   check_node(41,337,349,dut.core.div1_issue_valid,dut.core.div1_a,dut.core.div1_b,dut.core.div1);
   check_node(21,349,355,dut.core.add21_issue_valid,dut.core.add21_a,dut.core.add21_b,dut.core.add21);
   check_node(22,3,9,dut.core.add22_issue_valid,dut.core.add22_a,dut.core.add22_b,dut.core.add22);
   check_node(39,9,23,dut.core.mul16_issue_valid,dut.core.mul16_a,dut.core.mul16_b,dut.core.mul16);
   if(dut.commit_valid) begin
    if(produced>=accepted || $isunknown(dut.core_result)) $fatal(1,"STREAM_UNRESERVED_RETURN");
    ordinal=ordinals[produced]; gotlat=cycle-accept_cycles[produced];
    if(latency<0) latency=gotlat;
    if(gotlat!=384 || gotlat!=latency) $fatal(1,"STREAM_VARIABLE_EXTERNAL_LATENCY index=%0d got=%0d expected=%0d",produced,gotlat,latency);
    if(dut.core_result!==gold[ordinal]) $fatal(1,"STREAM_CORE_NUMERIC index=%0d ordinal=%0d x=%08x got=%08x gold=%08x",produced,ordinal,x[ordinal],dut.core_result,gold[ordinal]);
    if(dut.core_status!==((x[ordinal]&32'h7fffffff)>=32'h7f800000 ? 32'd1 : 32'd0))$fatal(1,"CANONICAL_CORE_STATUS");
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
   for(integer r=0;r<42;r=r+1)begin node_issued[r]=0;node_returned[r]=0;end
  end
 endtask
 task clean_reset;
  begin
   @(negedge clk); reset=1; in_valid=0;
   repeat(4) @(negedge clk); prepare(); reset=0;
   repeat(2000) begin @(posedge clk); if(out_valid||dut.commit_valid) $fatal(1,"STREAM_OLD_EPOCH_RETURN"); end
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
   for(integer r=0;r<42;r=r+1)if(node_issued[r]!=n||node_returned[r]!=n)$fatal(1,"CANONICAL_PROFILE_NODE_DEBT");
   $display("TANH_CANONICAL_PROFILE_PASS mode=%0d count=%0d first_accept=%0d first_valid=%0d last_retire=%0d span=%0d min_gap=%0d max_gap=%0d core_fixed_latency=%0d peak_credit=%0d credit_stops=%0d",md,n,first_accept,first_valid,last_retire,last_retire-first_accept,min_gap,max_gap,latency,credit_peak,pressure_stops);
   $display("TANH_CANONICAL_DIVIDER_PASS mode=%0d div0_issue=%0d div0_return=%0d div1_issue=%0d div1_return=%0d issue_edges=233,337 consumer_edges=245,349",md,div0_issue,div0_return,div1_issue,div1_return);
  end
 endtask
 initial begin
  if(!$value$plusargs("X_FILE=%s",xf)||!$value$plusargs("GOLD_FILE=%s",gf)) $fatal(1,"STREAM_MISSING_FIXTURE");
  if($value$plusargs("COUNT=%d",count)) begin end
  if($value$plusargs("PILOT=%d",pilot)) begin end
  if(!$value$plusargs("TRACE_FILE=%s",tf))$fatal(1,"CANONICAL_MISSING_TRACE");
  $readmemh(tf,trace_gold);
  for(i=0;i<412020;i=i+1)if($isunknown(trace_gold[i]))$fatal(1,"CANONICAL_UNKNOWN_TRACE");
  $readmemh(xf,x); $readmemh(gf,gold);
  for(i=0;i<3270;i=i+1) if($isunknown({x[i],gold[i]})) $fatal(1,"STREAM_UNKNOWN_FIXTURE");
  clean_reset();
  if(pilot) begin
   profile(0,128,1); $display("TANH_CANONICAL_PILOT_PASS count=128"); $finish;
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
  $display("TANH_CANONICAL_CREDIT_PASS count=640 peak=512 stops=%0d fixed_latency=%0d",pressure_stops,latency);
  $display("TANH_CANONICAL_RTL_PASS count=%0d profiles=2 mixed_credit=640 reset_inflight=1 reset_pending=1 cycles=%0d",count,cycle);
  $finish;
 end
endmodule
