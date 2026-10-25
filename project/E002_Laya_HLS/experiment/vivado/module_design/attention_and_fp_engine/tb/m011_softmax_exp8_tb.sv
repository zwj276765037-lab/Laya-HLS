`timescale 1ns/1ps
module m011_softmax_exp8_tb;
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
logic[63:0]context_valid,context_row_hi;
logic req_valid;
logic req_ready;
logic[1:0]req_mode;
logic[31:0]req_generation,req_epoch;
logic[2:0]req_phase;
logic[10:0]req_tag;
logic[7:0][31:0]req_x;
logic reject_valid;
logic[1:0]reject_code;
logic rsp_valid;
logic rsp_ready;
logic[10:0]rsp_tag;
logic[7:0][31:0]rsp_data;
logic[8:0]pending_vectors,in_flight_vectors;
logic protocol_fault;
 laya_sfu_exp8_v1 dut(.*);always #1.6665 clk=~clk;
 logic[31:0]xs[0:49999],gold[0:49999];int count,goal,sent=0,received=0,cycle=0,first_accept=-1,last_accept=-1,first_return=-1;
 int max_pending=0,max_inflight=0;bit driver_enable=0,traffic=0;string data_dir;
 task automatic clear_counts(input int n);sent=0;received=0;goal=n;first_accept=-1;last_accept=-1;first_return=-1;endtask
 task automatic claim;
  @(negedge clk);lease_valid=1;do @(posedge clk);while(!lease_ready);@(negedge clk);lease_valid=0;
 endtask
 task automatic end_lease;
  @(negedge clk);traffic=0;release_valid=1;wait(!lease_active);@(negedge clk);release_valid=0;
  if(pending_vectors||in_flight_vectors||protocol_fault)$fatal(1,"EXP8_RELEASE_DEBT");
 endtask
 initial begin
  clk=0;rst_n=0;lease_valid=0;lease_request_id=3;lease_generation=1;lease_epoch=31;lease_head=0;lease_phase=3;
  release_valid=0;release_phase=3;release_epoch=31;phase_debt_clear=1;context_valid='1;context_row_hi=0;
  req_valid=0;req_mode=0;req_generation=1;req_epoch=31;req_phase=3;req_tag=0;req_x=0;rsp_ready=1;
  if(!$value$plusargs("DATA=%s",data_dir)||!$value$plusargs("COUNT=%d",count))$fatal(1,"EXP8_ARGS");
  $readmemh({data_dir,"/exp_x.mem"},xs,0,count-1);$readmemh({data_dir,"/exp_gold.mem"},gold,0,count-1);
  repeat(5)@(negedge clk);rst_n=1;claim();
  @(negedge clk);req_valid=1;req_mode=1;#0.1;if(req_ready||!reject_valid||reject_code!=1)$fatal(1,"EXP8_TANH_NOT_REJECTED");
  @(negedge clk);req_mode=0;req_x={8{32'h3f800000}};#0.1;if(req_ready||!reject_valid||reject_code!=2)$fatal(1,"EXP8_POSITIVE_DOMAIN");
  @(negedge clk);req_x={8{32'hff800000}};#0.1;if(req_ready||reject_code!=2)$fatal(1,"EXP8_NONFINITE_DOMAIN");
  @(negedge clk);req_x=0;req_generation=0;#0.1;if(req_ready||reject_code!=3)$fatal(1,"EXP8_GENERATION");
  @(negedge clk);req_generation=1;req_phase=2;#0.1;if(req_ready||reject_code!=3)$fatal(1,"EXP8_PHASE");
  @(negedge clk);req_phase=3;context_valid[0]=0;#0.1;if(req_ready||reject_code!=3)$fatal(1,"EXP8_CONTEXT_VALID");
  @(negedge clk);context_valid[0]=1;context_row_hi[0]=1;#0.1;if(req_ready||reject_code!=3)$fatal(1,"EXP8_CONTEXT_OWNER");
  @(negedge clk);req_valid=0;context_row_hi=0;clear_counts((count+7)/8);driver_enable=1;traffic=1;
  wait(received==goal);@(negedge clk);traffic=0;
  if(first_return-first_accept>256||last_accept-first_accept!=goal-1)$fatal(1,"EXP8_LATENCY_OR_II latency%0d span%0d goal%0d",first_return-first_accept,last_accept-first_accept,goal);
  $display("M011_EXP8_STREAM_PASS vectors%0d scalars%0d independent_words%0d padded%0d latency%0d II1 maxpending%0d maxinflight%0d",goal,goal*8,count,goal*8-count,first_return-first_accept,max_pending,max_inflight);
  end_lease();
  lease_generation=2;req_generation=2;lease_epoch=32;req_epoch=32;release_epoch=32;context_row_hi=0;clear_counts(16);rsp_ready=0;claim();traffic=1;
  wait(sent==goal);@(negedge clk);traffic=0;wait(rsp_valid);
  begin logic[255:0] held;logic[10:0]tag;held=rsp_data;tag=rsp_tag;@(negedge clk);release_valid=1;
   repeat(3)begin @(negedge clk);if(!rsp_valid||rsp_data!==held||rsp_tag!==tag||release_ready||!lease_active)$fatal(1,"EXP8_HELD_DEBT");end
  end
  rsp_ready=1;wait(received==goal);wait(!lease_active);@(negedge clk);release_valid=0;
  lease_generation=3;req_generation=3;lease_epoch=33;req_epoch=33;release_epoch=33;context_row_hi=0;clear_counts(8);rsp_ready=0;claim();traffic=1;
  wait(sent==goal);@(negedge clk);traffic=0;req_valid=0;
  if(in_flight_vectors==0||pending_vectors==0)$fatal(1,"EXP8_RESET_NOT_INFLIGHT");rst_n=0;
  repeat(3)@(negedge clk);rst_n=1;rsp_ready=1;
  repeat(180)begin @(negedge clk);if(rsp_valid||lease_active||pending_vectors||in_flight_vectors||protocol_fault)$fatal(1,"EXP8_RESET_STALE");end
  lease_generation=4;req_generation=4;lease_epoch=34;req_epoch=34;release_epoch=34;context_row_hi=0;clear_counts(16);claim();traffic=1;
  wait(received==goal);end_lease();
  $display("HARDWARE_AGENT_SIM_PASS M011_EXP8 independent_words%0d eight_lanes1 II1 latency%0d held3 real_reserved_space1 invalid_mode_domain_generation_phase_context_reject1 reset_inflight1 generation4 debt0 TANH_NOT_IMPLEMENTED",count,first_return-first_accept);$finish;
 end
 always @(negedge clk)if(driver_enable)begin
  req_valid=rst_n&&traffic&&sent<goal;
  req_tag=11'(sent%2048);context_row_hi[req_tag[9:4]]=req_tag[10];
  for(int lane=0;lane<8;lane++)req_x[lane]=sent*8+lane<count?xs[sent*8+lane]:0;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>15000)$fatal(1,"EXP8_TIMEOUT sent%0d received%0d goal%0d",sent,received,goal);
  if(rst_n)begin
   if(protocol_fault)$fatal(1,"EXP8_PROTOCOL_FAULT pending%0d inflight%0d",pending_vectors,in_flight_vectors);
   if(pending_vectors>256||in_flight_vectors>256)$fatal(1,"EXP8_SCALAR_CAP");
   if(pending_vectors>max_pending)max_pending=pending_vectors;if(in_flight_vectors>max_inflight)max_inflight=in_flight_vectors;
   if(req_valid&&req_ready)begin if(sent==0)first_accept=cycle;last_accept=cycle;sent<=sent+1;end
   if(rsp_valid&&rsp_ready)begin
    if(rsp_tag!==11'(received%2048)||rsp_request_id!==3||rsp_generation!==lease_generation||rsp_epoch!==lease_epoch||rsp_phase!==3||rsp_head!==0)$fatal(1,"EXP8_RETURN_ID idx%0d tag%0d",received,rsp_tag);
    for(int lane=0;lane<8;lane++)begin
     logic[31:0]expected;expected=received*8+lane<count?gold[received*8+lane]:32'h3f800000;
     if(rsp_data[lane]!==expected)$fatal(1,"EXP8_ORACLE idx%0d lane%0d got%h gold%h",received,lane,rsp_data[lane],expected);
    end
    if(received==0)first_return=cycle;received=received+1;
    if(received%1024==0)$display("M011_EXP8_PROGRESS vectors%0d goal%0d",received,goal);
   end
  end
 end
endmodule
