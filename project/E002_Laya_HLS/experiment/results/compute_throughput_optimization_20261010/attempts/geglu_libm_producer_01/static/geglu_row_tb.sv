`timescale 1ns/1ps
module geglu_row_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,in_valid=0,out_ready=0;
 reg [31:0] in_data=0,in_tag=0;
 reg [12:0] in_index=0;
 wire in_ready,out_valid,out_last;
 wire [31:0] out_data,out_tag,out_status;
 wire [11:0] out_index;
 wire trace_valid; wire [3:0] trace_index;
 wire [31:0] trace_data,trace_tag; wire [11:0] trace_column;
 geglu_row_wrapper dut(.*);
 reg [31:0] wi[0:5247],gold[0:26239];
 reg [9:0] traces[0:2623];
 integer cycle=0,mode=0,accepted=0,retired=0,trace_checks=0;
 integer first_accept=0,last_retire=0,first_valid=0;
 integer column_start=0,min_latency=2147483647,max_latency=0,sum_latency=0;
 integer i,j,lat,expected_error=0,pilot=0;
 reg checking=0,was_stalled=0;
 reg [31:0] expected_tag=0,stall_data,stall_tag,stall_status;
 reg [11:0] stall_index; reg stall_last;
 string wf,sf;
 always @(negedge clk) begin
  if(reset||mode==2) out_ready<=0;
  else if(mode==1) out_ready<=((cycle%17)>=6 && (cycle%53)>=9);
  else out_ready<=1;
 end
 always @(posedge clk) begin
  cycle=cycle+1;
  if(cycle>40000000) $fatal(1,"GEGLU_CYCLE_CAP");
  if(reset) begin was_stalled=0; column_start=0; end
  else begin
   if(was_stalled && (!out_valid || {out_data,out_tag,out_status,out_index,out_last}!==
     {stall_data,stall_tag,stall_status,stall_index,stall_last})) $fatal(1,"GEGLU_UNSTABLE_RETURN");
   was_stalled=out_valid&&!out_ready;
   if(was_stalled) begin
    stall_data=out_data; stall_tag=out_tag; stall_status=out_status;
    stall_index=out_index; stall_last=out_last;
   end
   if(in_valid&&in_ready) begin
    accepted=accepted+1; if(!first_accept) first_accept=cycle;
   end
   if(dut.start) column_start=cycle;
   if(checking && trace_valid && !expected_error) begin
    if($isunknown({trace_data,trace_tag,trace_column,trace_index}) ||
      trace_tag!==expected_tag || trace_column>=2624 || trace_index>=10)
      $fatal(1,"GEGLU_TRACE_METADATA");
    if(trace_data!==gold[10*trace_column+trace_index])
      $fatal(1,"GEGLU_STEP_FAIL col=%0d step=%0d got=%08x gold=%08x",trace_column,trace_index,trace_data,gold[10*trace_column+trace_index]);
    if(traces[trace_column][trace_index]) $fatal(1,"GEGLU_DUPLICATE_TRACE");
    traces[trace_column][trace_index]=1; trace_checks=trace_checks+1;
   end
   if(out_valid && !first_valid) first_valid=cycle;
   if(out_valid&&out_ready) begin
    if(!checking) $fatal(1,"GEGLU_STALE_RETURN");
    if($isunknown({out_data,out_tag,out_status,out_index,out_last}) || out_tag!==expected_tag)
      $fatal(1,"GEGLU_RETURN_METADATA");
    if(expected_error) begin
     if(out_status!==expected_error || out_data!==0 || !out_last) $fatal(1,"GEGLU_ERROR_RETURN");
    end else begin
     if(out_status!==0 || out_index!==retired || out_last!==(out_index==2623))
       $fatal(1,"GEGLU_RETURN_INDEX_STATUS index=%0d expected=%0d",out_index,retired);
     if(out_data!==gold[10*out_index+9] || traces[out_index]!==10'h3ff)
       $fatal(1,"GEGLU_OUTPUT_OR_INCOMPLETE_STEPS index=%0d got=%08x gold=%08x trace=%03x",out_index,out_data,gold[10*out_index+9],traces[out_index]);
     lat=cycle-column_start; sum_latency=sum_latency+lat;
     if(lat<min_latency) min_latency=lat;
     if(lat>max_latency) max_latency=lat;
    end
    retired=retired+1; last_retire=cycle;
    if((retired%128)==0) $display("TANH_PROGRESS GEGLU mode=%0d outputs=%0d step_checks=%0d cycle=%0d",mode,retired,trace_checks,cycle);
   end
   if(dut.state==dut.RUN&&dut.done && (!(dut.seen_result||dut.result_valid)||!(dut.seen_status||dut.status_valid)))
     $fatal(1,"GEGLU_MISSING_HLS_RETURN");
  end
 end
 task prepare(input [31:0] tag,input integer error_code);
  begin
   expected_tag=tag; expected_error=error_code; checking=1;
   accepted=0; retired=0; trace_checks=0; first_accept=0; last_retire=0; first_valid=0;
   min_latency=2147483647; max_latency=0; sum_latency=0;
   for(j=0;j<2624;j=j+1) traces[j]=0;
  end
 endtask
 task send_word(input integer idx,input [31:0] value,input [31:0] tag);
  begin
   @(negedge clk); in_valid=1; in_index=idx; in_data=value; in_tag=tag;
   do @(posedge clk); while(!in_ready);
   @(negedge clk); in_valid=0;
  end
 endtask
 task load_row(input [31:0] tag,input integer invalid_x);
  begin
   for(i=0;i<5248;i=i+1) send_word(i,(invalid_x&&i==0)?32'h7fc00001:wi[i],tag);
  end
 endtask
 task clean_reset;
  begin
   @(negedge clk); reset=1; in_valid=0; checking=0;
   repeat(4) @(negedge clk); reset=0;
   repeat(800) begin @(posedge clk); if(out_valid||trace_valid) $fatal(1,"GEGLU_OLD_EPOCH_AFTER_RESET"); end
  end
 endtask
 task profile(input integer md,input [31:0] tag);
  begin
   mode=md; prepare(tag,0); load_row(tag,0);
   wait(retired==2624); @(negedge clk);
   if(accepted!=5248 || trace_checks!=26240 || !in_ready || out_valid || dut.loaded!=0)
     $fatal(1,"GEGLU_FINAL_ROW_DEBT");
   $display("GEGLU_ROW_PROFILE_PASS mode=%0d inputs=%0d outputs=%0d step_checks=%0d first_accept=%0d first_valid=%0d last_retire=%0d span=%0d min_start_to_consume=%0d max_start_to_consume=%0d sum_start_to_consume=%0d",md,accepted,retired,trace_checks,first_accept,first_valid,last_retire,last_retire-first_accept,min_latency,max_latency,sum_latency);
   checking=0;
  end
 endtask
 initial begin
  if(!$value$plusargs("WI_FILE=%s",wf)||!$value$plusargs("STEP_FILE=%s",sf)) $fatal(1,"GEGLU_MISSING_FIXTURE");
  $readmemh(wf,wi); $readmemh(sf,gold);
  for(i=0;i<5248;i=i+1) if($isunknown(wi[i])) $fatal(1,"GEGLU_UNKNOWN_WI");
  for(i=0;i<26240;i=i+1) if($isunknown(gold[i])) $fatal(1,"GEGLU_UNKNOWN_GOLD");
  clean_reset();
  if($value$plusargs("PILOT=%d",pilot) && pilot) begin
   prepare(32'h03010001,0); load_row(expected_tag,0);
   wait(retired==128); @(negedge clk);
   $display("GEGLU_ROW_PILOT_PASS complete_inputs=%0d checked_outputs=%0d checked_steps=%0d cycles=%0d",accepted,retired,trace_checks,cycle);
   $finish;
  end
  // Complete-memory capture, epoch cancellation, and full-row recovery.
  prepare(32'h03010001,0);
  for(i=0;i<31;i=i+1) send_word(i,wi[i],expected_tag);
  clean_reset();
  prepare(32'h03010002,2); send_word(1,wi[0],expected_tag);
  wait(retired==1); @(negedge clk); checking=0;
  prepare(32'h03010003,1); load_row(expected_tag,1);
  wait(retired==1); @(negedge clk); checking=0;
  prepare(32'h03010004,0); load_row(expected_tag,0);
  wait(dut.state==dut.RUN && dut.column==23); repeat(20) @(posedge clk);
  clean_reset(); profile(0,32'h03010005);
  mode=2; prepare(32'h03010006,0); load_row(expected_tag,0);
  wait(out_valid); repeat(20) @(posedge clk); clean_reset();
  profile(1,32'h03010007);
  $display("GEGLU_ROW_RTL_PASS full_profiles=2 full_inputs=10496 full_outputs=5248 independent_full_step_checks=52480 reset_loading=1 reset_inflight=1 reset_pending=1 malformed_index=1 numerical_reject=1 cycles=%0d",cycle);
  $finish;
 end
endmodule
