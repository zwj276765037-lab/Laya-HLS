`timescale 1ns/1ps
module tanh_libm_tb;
 reg clk=0; always #3.333333 clk=~clk;
 reg reset=1,in_valid=0,out_ready=1;
 reg [31:0] in_data=0,in_tag=0;
 wire in_ready,out_valid; wire [31:0] out_data,out_tag,out_status;
 tanh_libm_wrapper dut(.*);
 reg [31:0] x[0:9999],gold[0:9999];
 reg [31:0] add_directed[0:6143];
 reg add_reset=1,add_start=0;
 reg [31:0] add_a=0,add_b=0;
 wire add_done,add_idle,add_ready;
 wire [31:0] add_result;
 tanh_libm_leaf_fp_add_bits directed_add(.ap_clk(clk),.ap_rst(add_reset),
   .ap_start(add_start),.ap_done(add_done),.ap_idle(add_idle),.ap_ready(add_ready),
   .a(add_a),.b(add_b),.ap_return(add_result));
 integer count=3270,add_count=52,cycle=0,accepts=0,retires=0,epoch=1,mode=0;
 integer accept_cycle=0,first_valid_cycle=0,first_accept=0,last_retire=0;
 integer last_accept=0,last_return=0,min_gap=2147483647,max_gap=0;
 integer branch_n[0:2],branch_sum[0:2],branch_min[0:2],branch_max[0:2];
 reg debt=0,announced=0,was_stalled=0;
 reg [31:0] pending_tag,stall_data,stall_tag,stall_status;
 integer b,idx,lat;
 string xf,gf,af;
 function integer branch(input [31:0] z);
   if((z&32'h7fffffff)<32'h3f800000) branch=0;
   else if((z&32'h7fffffff)<32'h41b00000) branch=1;
   else branch=2;
 endfunction
 always @(negedge clk) begin
   if(reset) out_ready<=0;
   else if(mode==1) out_ready<=((cycle%17)>=6 && (cycle%53)>=9);
   else if(mode==2) out_ready<=0;
   else out_ready<=1;
 end
 always @(posedge clk) begin
   cycle=cycle+1;
   if(cycle>40000000) $fatal(1,"CYCLE_LIMIT");
   if(reset) begin debt=0; announced=0; was_stalled=0; end
   else begin
     if(was_stalled && (!out_valid || out_data!==stall_data || out_tag!==stall_tag || out_status!==stall_status))
       $fatal(1,"UNSTABLE_BACKPRESSURE");
     was_stalled=out_valid&&!out_ready;
     if(was_stalled) begin stall_data=out_data; stall_tag=out_tag; stall_status=out_status; end
     if(in_valid&&in_ready) begin
       if(debt) $fatal(1,"OVERACCEPT_RETURN_SLOT");
       debt=1; pending_tag=in_tag; accept_cycle=cycle; announced=0;
       accepts=accepts+1;
       if(!first_accept) first_accept=cycle;
       if(last_accept) begin
         if(cycle-last_accept<min_gap) min_gap=cycle-last_accept;
         if(cycle-last_accept>max_gap) max_gap=cycle-last_accept;
       end
       last_accept=cycle;
     end
     if(out_valid && !announced) begin
       if(!debt) $fatal(1,"STALE_RETURN");
       first_valid_cycle=cycle; announced=1;
     end
     if(out_valid&&out_ready) begin
       if(!debt || out_tag!==pending_tag) $fatal(1,"TAG_OR_DEBT got=%08x expected=%08x",out_tag,pending_tag);
       idx=out_tag&65535;
       if(idx>=count || $isunknown({out_data,out_tag,out_status})) $fatal(1,"UNKNOWN_OR_INDEX");
       if(out_data!==gold[idx]) $fatal(1,"NUMERIC_FAIL ordinal=%0d x=%08x got=%08x gold=%08x",idx,x[idx],out_data,gold[idx]);
       if(out_status!==((x[idx]&32'h7fffffff)>=32'h7f800000 ? 32'd1 : 32'd0)) $fatal(1,"STATUS_FAIL ordinal=%0d",idx);
       debt=0; retires=retires+1; last_retire=cycle;
       if((retires%128)==0) $display("TANH_PROGRESS mode=%0d retires=%0d cycle=%0d",mode,retires,cycle);
       if(idx<2624) begin
         b=branch(x[idx]); lat=first_valid_cycle-accept_cycle;
         branch_n[b]=branch_n[b]+1; branch_sum[b]=branch_sum[b]+lat;
         if(lat<branch_min[b]) branch_min[b]=lat;
         if(lat>branch_max[b]) branch_max[b]=lat;
       end
     end
     if(dut.busy&&dut.done && !(dut.seen_result||dut.result_valid)) $fatal(1,"MISSING_RESULT_AT_DONE");
     if(dut.busy&&dut.done && !(dut.seen_status||dut.status_valid)) $fatal(1,"MISSING_STATUS_AT_DONE");
   end
 end
 task send(input integer i,input integer ep);
   begin
     @(negedge clk); in_valid=1; in_data=x[i]; in_tag=(ep<<16)|i;
     do @(posedge clk); while(!in_ready);
     @(negedge clk); in_valid=0;
   end
 endtask
 task clean_reset;
   begin
     @(negedge clk); reset=1; in_valid=0;
     repeat(4) @(negedge clk);
     reset=0;
     repeat(600) begin @(posedge clk); if(out_valid) $fatal(1,"OLD_RETURN_AFTER_RESET"); end
   end
 endtask
 task run_profile(input integer md,input integer ep);
   integer i,j;
   begin
     mode=md; accepts=0; retires=0; first_accept=0; last_retire=0;
     last_accept=0; min_gap=2147483647; max_gap=0;
     for(j=0;j<3;j=j+1) begin branch_n[j]=0; branch_sum[j]=0; branch_min[j]=2147483647; branch_max[j]=0; end
     for(i=0;i<count;i=i+1) send(i,ep);
     wait(retires==count); @(negedge clk);
     if(debt || dut.busy || out_valid) $fatal(1,"FINAL_DEBT");
     $display("TANH_PROFILE_PASS mode=%0d count=%0d first_accept=%0d last_retire=%0d span=%0d min_accept_gap=%0d max_accept_gap=%0d",md,count,first_accept,last_retire,last_retire-first_accept,min_gap,max_gap);
     for(j=0;j<3;j=j+1) $display("TANH_BRANCH mode=%0d branch=%0d real_count=%0d latency_sum=%0d min_latency=%0d max_latency=%0d",md,j,branch_n[j],branch_sum[j],branch_min[j],branch_max[j]);
   end
 endtask
 task run_directed_add;
   integer i;
   begin
     repeat(4) @(negedge clk); add_reset=0;
     for(i=0;i<add_count;i=i+1) begin
       @(negedge clk); add_a=add_directed[3*i]; add_b=add_directed[3*i+1]; add_start=1;
       @(posedge clk); @(negedge clk); add_start=0;
       do @(posedge clk); while(!add_done);
       if(add_result!==add_directed[3*i+2]) $fatal(1,"DIRECTED_ADD_FAIL index=%0d a=%08x b=%08x got=%08x gold=%08x",i,add_a,add_b,add_result,add_directed[3*i+2]);
       @(negedge clk);
       if(i==51) $display("RNE_ZERO_DIRECTED_RTL_PASS count=52 gold=native_binary32_RNE");
     end
     $display("ADD_BOUNDARY_DIRECTED_RTL_PASS count=%0d gold=native_binary32_RNE",add_count);
   end
 endtask
 initial begin
   if(!$value$plusargs("X_FILE=%s",xf)||!$value$plusargs("GOLD_FILE=%s",gf)||!$value$plusargs("ADD_FILE=%s",af)) $fatal(1,"MISSING_FIXTURE");
   if($value$plusargs("COUNT=%d",count)) begin end
   if($value$plusargs("ADD_COUNT=%d",add_count)) begin end
   if(add_count<52 || add_count>2048) $fatal(1,"INVALID_ADD_COUNT");
   $readmemh(xf,x,0,count-1); $readmemh(gf,gold,0,count-1);
   $readmemh(af,add_directed,0,3*add_count-1);
   for(idx=0;idx<3*add_count;idx=idx+1) if($isunknown(add_directed[idx])) $fatal(1,"UNKNOWN_ADD_FIXTURE");
   for(idx=0;idx<count;idx=idx+1) if($isunknown({x[idx],gold[idx]})) $fatal(1,"UNKNOWN_FIXTURE");
   run_directed_add(); clean_reset();
   run_profile(0,1); run_profile(1,2);
   mode=0; send(23,3); repeat(20) @(posedge clk); clean_reset();
   send(23,4); wait(!debt); @(negedge clk);
   mode=2; send(0,5); wait(out_valid); repeat(20) @(posedge clk); clean_reset();
   mode=0; send(0,6); wait(!debt); @(negedge clk);
   if(dut.busy||out_valid||debt) $fatal(1,"RECOVERY_DEBT");
   $display("TANH_LIBM_RTL_PASS count=%0d profiles=2 reset_inflight=1 reset_pending_return=1 total_cycles=%0d",count,cycle);
   $finish;
 end
endmodule
