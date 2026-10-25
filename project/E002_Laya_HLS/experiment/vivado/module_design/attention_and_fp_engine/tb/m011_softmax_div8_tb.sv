`timescale 1ns/1ps
module m011_softmax_div8_tb;
logic clk,rst_n;
logic lease_valid;
logic lease_ready;
logic[63:0]lease_request_id;
logic[31:0]lease_generation,lease_epoch;
logic[3:0]lease_head;
logic[2:0]lease_phase;
logic release_valid;
logic release_ready;
logic[2:0]release_phase;
logic[31:0]release_epoch;
logic phase_debt_clear;
logic lease_active,draining;
logic[63:0]rsp_request_id;
logic[31:0]rsp_generation,rsp_epoch;
logic[3:0]rsp_head;
logic[2:0]rsp_phase;
logic req_valid;
logic req_ready;
logic[31:0]req_generation,req_epoch;
logic[2:0]req_phase;
logic[7:0]req_lane_mask;
logic[95:0]req_tag;
logic[7:0][31:0]req_a,req_b;
logic protocol_reject_valid;
logic[3:0]protocol_reject_code;
logic rsp_valid;
logic rsp_ready;
logic[95:0]rsp_tag;
logic[7:0]rsp_lane_mask,rsp_numeric_error;
logic[7:0][31:0]rsp_data;
logic[5:0]pending_vectors,in_flight_vectors;
logic[8:0]in_flight_scalars;
logic protocol_fault;
 laya_shared_div8_v1 dut(.*);always #1.6665 clk=~clk;
 logic[31:0]av[0:39999],bv[0:39999],gold[0:39999],errs[0:39999];
 int count,goal,base=0,sent=0,received=0,cycle=0,first_accept=-1,last_accept=-1,first_return=-1;
 int full_reuses=0,max_pending=0,max_scalars=0;bit driver_enable=0,traffic=0,vary_masks=0,gapped=0;string data_dir;
 int accept_cycle[0:4095],physical_returns=0,checked_physical_returns=0,idle_ce_cycles=0,active_gap_cycles=0;
 function automatic logic[7:0]mask(input int n);if(lease_phase==3)return 8'hff;if(lease_phase==6)return 1;if(vary_masks)return n%3==0?1:n%3==1?2:3;return 3;endfunction
 function automatic logic[95:0]tag(input int n);return {32'hd1800000|{29'b0,lease_phase},32'(n+100),32'(n+200)};endfunction
 task automatic clear_counts(input int n,input int offset);goal=n;base=offset;sent=0;received=0;first_accept=-1;last_accept=-1;first_return=-1;physical_returns=0;endtask
 task automatic claim(input int gen,ep,ph);
  lease_generation=32'(gen);req_generation=32'(gen);lease_epoch=32'(ep);req_epoch=32'(ep);release_epoch=32'(ep);lease_phase=3'(ph);req_phase=3'(ph);release_phase=3'(ph);
  @(negedge clk);lease_valid=1;do @(posedge clk);while(!lease_ready);@(negedge clk);lease_valid=0;
 endtask
 task automatic observe_idle;
  bit saved_driver;logic[23:0]held_decode;
  saved_driver=driver_enable;driver_enable=0;req_valid=0;
  @(negedge clk);#0.1;held_decode=dut.divider_lane[0].leaf.ma1;
  repeat(4)begin
   req_a=~req_a;req_b=~req_b;
   @(negedge clk);#0.1;
   if(dut.leaf_ce!==0||dut.leaf_valid!==0||dut.divider_lane[0].leaf.valid!==0||dut.divider_lane[0].leaf.ma1!==held_decode)$fatal(1,"DIV8_IDLE_LEAF_NOT_FROZEN");
  end
  driver_enable=saved_driver;
 endtask
 task automatic finish_lease;
  @(negedge clk);traffic=0;release_valid=1;wait(!lease_active);@(negedge clk);release_valid=0;
  if(pending_vectors||in_flight_vectors||in_flight_scalars||protocol_fault)$fatal(1,"DIV8_RELEASE_DEBT");
  observe_idle();
 endtask
 initial begin
  clk=0;rst_n=0;lease_valid=0;lease_request_id=3;lease_generation=1;lease_epoch=41;lease_head=0;lease_phase=3;
  release_valid=0;release_phase=3;release_epoch=41;phase_debt_clear=1;
  req_valid=0;req_generation=1;req_epoch=41;req_phase=3;req_lane_mask=8'hff;req_tag=0;req_a=0;req_b={8{32'h3f800000}};rsp_ready=1;
  if(!$value$plusargs("DATA=%s",data_dir)||!$value$plusargs("COUNT=%d",count))$fatal(1,"DIV8_ARGS");
  $readmemh({data_dir,"/div_a.mem"},av,0,count+7);$readmemh({data_dir,"/div_b.mem"},bv,0,count+7);$readmemh({data_dir,"/div_gold.mem"},gold,0,count+7);$readmemh({data_dir,"/div_error.mem"},errs,0,count+7);
  repeat(5)begin @(negedge clk);if(dut.leaf_ce!==1)$fatal(1,"DIV8_RESET_CE_BLOCKED");end rst_n=1;observe_idle();
  @(negedge clk);lease_phase=7;lease_valid=1;#0.1;if(lease_ready||!protocol_reject_valid||protocol_reject_code!=6)$fatal(1,"DIV8_BAD_LEASE");
  @(negedge clk);lease_valid=0;claim(1,41,3);
  @(negedge clk);req_valid=1;req_generation=0;#0.1;if(req_ready||!protocol_reject_valid||protocol_reject_code!=2)$fatal(1,"DIV8_WRONG_GEN");
  @(negedge clk);req_generation=1;req_epoch=0;#0.1;if(req_ready||protocol_reject_code!=3)$fatal(1,"DIV8_WRONG_EPOCH");
  @(negedge clk);req_epoch=41;req_phase=5;#0.1;if(req_ready||protocol_reject_code!=4)$fatal(1,"DIV8_WRONG_PHASE");
  @(negedge clk);req_phase=3;req_lane_mask=1;#0.1;if(req_ready||protocol_reject_code!=5)$fatal(1,"DIV8_SM_MASK");
  @(negedge clk);req_lane_mask=0;#0.1;if(req_ready||protocol_reject_code!=5)$fatal(1,"DIV8_ZERO_MASK");
  @(negedge clk);req_valid=0;req_lane_mask=8'hff;release_valid=1;release_epoch=99;#0.1;if(release_ready||protocol_reject_code!=7)$fatal(1,"DIV8_WRONG_RELEASE");
  @(negedge clk);release_valid=0;release_epoch=41;clear_counts(count/8,0);driver_enable=1;traffic=1;
  wait(received==goal);@(negedge clk);traffic=0;
  if(first_return-first_accept!=32||last_accept-first_accept!=goal-1||full_reuses==0||max_pending!=32||max_scalars!=256)$fatal(1,"DIV8_MAIN_II_LAT_CAP latency%0d span%0d reuse%0d pending%0d scalar%0d",first_return-first_accept,last_accept-first_accept,full_reuses,max_pending,max_scalars);
  $display("M011_DIV8_REAL_PASS pairs%0d latency32 II1 maxpending32 maxphysicalscalar256 full_same_slot_reuses%0d",count,full_reuses);finish_lease();
  clear_counts(1,count);claim(2,42,3);traffic=1;wait(received==1);@(negedge clk);traffic=0;
  if(first_return-first_accept!=32)$fatal(1,"DIV8_ERROR_RETIRE_LATENCY");
  $display("M011_DIV8_ERROR_RETIRE_PASS latency32 dividezero_nan_inf_errors1 finite_overflow_error1 subnormal_preserved1 negativezero_preserved1");finish_lease();
  clear_counts(32,0);vary_masks=0;rsp_ready=0;claim(3,43,5);traffic=1;wait(sent==goal);@(negedge clk);traffic=0;wait(rsp_valid);
  begin logic[367:0]held;held={rsp_tag,rsp_lane_mask,rsp_numeric_error,rsp_data};@(negedge clk);release_valid=1;
   repeat(3)begin @(negedge clk);if(!rsp_valid||{rsp_tag,rsp_lane_mask,rsp_numeric_error,rsp_data}!==held||release_ready||!lease_active||pending_vectors!=32)$fatal(1,"DIV8_HELD_FULL_DEBT");end
  end
  rsp_ready=1;wait(received==goal);wait(!lease_active);@(negedge clk);release_valid=0;
  clear_counts(9,0);vary_masks=1;claim(4,44,5);traffic=1;wait(received==goal);finish_lease();
  clear_counts(8,0);vary_masks=0;claim(5,45,6);traffic=1;wait(received==goal);finish_lease();
  clear_counts(8,0);rsp_ready=0;claim(6,46,6);traffic=1;wait(sent==goal);@(negedge clk);traffic=0;req_valid=0;
  if(in_flight_scalars==0||pending_vectors==0)$fatal(1,"DIV8_RESET_NOT_INFLIGHT");rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;rsp_ready=1;
  repeat(40)begin @(negedge clk);if(rsp_valid||lease_active||pending_vectors||in_flight_vectors||in_flight_scalars||protocol_fault)$fatal(1,"DIV8_RESET_STALE");end
  clear_counts(16,0);claim(7,47,3);traffic=1;wait(received==goal);finish_lease();
  // Reset must propagate even while the numerical leaves were idle-frozen.
  rst_n=0;#0.1;if(dut.leaf_ce!==1)$fatal(1,"DIV8_IDLE_RESET_CE_BLOCKED");
  repeat(3)@(negedge clk);rst_n=1;observe_idle();
  gapped=1;clear_counts(96,0);claim(8,48,3);traffic=1;wait(received==goal);finish_lease();
  clear_counts(18,0);vary_masks=1;claim(9,49,5);traffic=1;wait(received==goal);finish_lease();
  gapped=0;
  if(idle_ce_cycles<20||active_gap_cycles==0)$fatal(1,"DIV8_CE_COVERAGE idle%0d active_gap%0d",idle_ce_cycles,active_gap_cycles);
  $display("M011_DIV8_IDLE_CE_PASS frozen_cycles%0d active_empty_gap_cycles%0d checked_physical_returns%0d gapped_vectors114 idle_reset1 idle_new_phase_epoch1",idle_ce_cycles,active_gap_cycles,checked_physical_returns);
  $display("HARDWARE_AGENT_SIM_PASS M011_DIV8 realpairs%0d active_lane_II1 latency32 fullconsume_reuse1 held3 Qmask123 LNmask1 SMmaskff protocol_reject1 illegal_operand_retire1 gradual_underflow1 reset_inflight1 generation9 debt0 idle_only_CE1 gapped_physical32_each1 idle_reset1",count);$finish;
 end
 always @(negedge clk)if(driver_enable)begin
  req_valid=rst_n&&traffic&&sent<goal&&(!gapped||cycle%11==0||cycle%11==1||cycle%11==7);req_lane_mask=mask(sent);req_tag=tag(sent);
  for(int lane=0;lane<8;lane++)begin req_a[lane]=av[base+sent*8+lane];req_b[lane]=bv[base+sent*8+lane];end
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>12000)$fatal(1,"DIV8_TIMEOUT sent%0d received%0d goal%0d",sent,received,goal);
  if(rst_n)begin
   if(lease_active||dut.token_valid!=0||dut.good_pipe!=0||dut.bad_pipe!=0||dut.leaf_valid!=0||pending_vectors!=0||in_flight_vectors!=0||in_flight_scalars!=0)begin
    if(dut.leaf_ce!==1)$fatal(1,"DIV8_CE_FROZE_ACTIVITY");
    if(lease_active&&dut.token_valid==0&&!req_valid)active_gap_cycles++;
   end else begin
    if(dut.leaf_ce!==0||dut.leaf_valid!==0)$fatal(1,"DIV8_CE_IDLE_NOT_CLEAR");idle_ce_cycles++;
   end
   if(dut.token_valid[31])begin
    if(physical_returns>=sent||cycle-accept_cycle[physical_returns]!=32)$fatal(1,"DIV8_PHYSICAL_LATENCY idx%0d age%0d",physical_returns,cycle-accept_cycle[physical_returns]);
    physical_returns++;checked_physical_returns++;
   end
   if(protocol_fault)$fatal(1,"DIV8_PROTOCOL_FAULT");
   if(pending_vectors>32||in_flight_vectors>32||in_flight_scalars>256)$fatal(1,"DIV8_CAP");
   if(pending_vectors>max_pending)max_pending=pending_vectors;if(in_flight_scalars>max_scalars)max_scalars=in_flight_scalars;
   if(req_valid&&req_ready)begin accept_cycle[sent]=cycle;if(sent==0)first_accept=cycle;last_accept=cycle;sent<=sent+1;if(pending_vectors==32&&rsp_valid&&rsp_ready)full_reuses++;end
   if(rsp_valid&&rsp_ready)begin
    if(rsp_tag!==tag(received)||rsp_lane_mask!==mask(received)||rsp_request_id!==3||rsp_generation!==lease_generation||rsp_epoch!==lease_epoch||rsp_phase!==lease_phase||rsp_head!==0)$fatal(1,"DIV8_RETURN_ID idx%0d tag%h mask%h",received,rsp_tag,rsp_lane_mask);
    for(int lane=0;lane<8;lane++)begin
     logic[31:0]expected;logic err;logic[7:0]active;active=mask(received);expected=active[lane]?gold[base+received*8+lane]:0;err=active[lane]?errs[base+received*8+lane][0]:0;
     if(rsp_data[lane]!==expected||rsp_numeric_error[lane]!==err)$fatal(1,"DIV8_ORACLE idx%0d lane%0d got%h gold%h error%0d gold_error%0d",received,lane,rsp_data[lane],expected,rsp_numeric_error[lane],err);
    end
    if(received==0)first_return=cycle;received=received+1;
    if(received%1024==0)$display("M011_DIV8_PROGRESS vectors%0d goal%0d",received,goal);
   end
  end
 end
endmodule
