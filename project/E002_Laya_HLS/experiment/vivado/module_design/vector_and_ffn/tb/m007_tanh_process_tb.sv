`timescale 1ns/1ps
`ifdef TANH_V3
 `define TANH_PRIMARY laya_m007_tanh8_v3
`else
 `define TANH_PRIMARY laya_m007_tanh8_v2
`endif
`ifdef TANH_EQ
 `define TANH_OBSERVER auto_dut
`else
 `define TANH_OBSERVER dut
`endif
module m007_tanh_process_tb;
 localparam int MAXV=400000,MAXQ=51024;
 logic clk=0;always #1.6665 clk=~clk;
 logic rst_n=0,lease_valid=0,lease_ready,release_valid=0,release_ready,debt_clear=1,active,draining;
 logic [63:0] rid=64'h123456789abcdef0,rrid,req_rid;
 logic [31:0] generation=7,epoch=9,rgen,repoch,req_gen,req_epoch;
 logic [2:0] lease_phase=1,req_phase=1,rphase;
 logic iv=0,ir,ov,ready=1,reject_valid,fault;logic [1:0] mode=1,reject_code;
 logic [95:0] tag=0,ot;logic [7:0] mask=0,om;
 logic [7:0][31:0] x=0,y,status;
 logic [8:0] pending,flight;
 logic [95:0] vectors[0:MAXV-1];logic [1343:0] nodes[0:MAXV-1];
 logic [7:0][31:0] expected[0:MAXQ-1],errors[0:MAXQ-1];
 logic [95:0] tags[0:MAXQ-1];logic [7:0] masks[0:MAXQ-1];int cycles_q[0:MAXQ-1];
 int ref_id[0:7],id_pipe[0:151][0:7];logic [7:0] mask_pipe[0:151];
 int accepted=0,returned=0,checked=0,wall=0,phase=0,count,total_count,main_vectors;
 int first_latency=-1,last=-1,peak_pending=0,peak_flight=0,held_cycles=0,node_checks=0,rejections=0;
 string vf,nf,pf,trace_path;integer progress_fd,trace_fd;
 `TANH_PRIMARY dut(.clk,.rst_n,.lease_valid,.lease_ready,.lease_request_id(rid),.lease_generation(generation),.lease_epoch(epoch),.lease_phase,
  .release_valid,.release_ready,.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(debt_clear),.lease_active(active),.draining,
  .rsp_request_id(rrid),.rsp_generation(rgen),.rsp_epoch(repoch),.rsp_phase(rphase),
  .req_valid(iv),.req_ready(ir),.req_mode(mode),.req_request_id(req_rid),.req_generation(req_gen),.req_epoch,.req_phase,.req_tag(tag),.req_mask(mask),.req_x(x),
  .reject_valid,.reject_code,.rsp_valid(ov),.rsp_ready(ready),.rsp_tag(ot),.rsp_mask(om),.rsp_data(y),.rsp_status(status),
  .pending_vectors(pending),.in_flight_vectors(flight),.protocol_fault(fault));

 logic [1:0] ce_lease_ready,ce_release_ready,ce_active,ce_draining,ce_ir,ce_ov,ce_reject,ce_fault;
 logic [1:0][63:0] ce_rrid;logic [1:0][31:0] ce_gen,ce_epoch;
 logic [1:0][2:0] ce_phase;logic [1:0][1:0] ce_reject_code;
 logic [1:0][95:0] ce_tag;logic [1:0][7:0] ce_mask;
 logic [1:0][7:0][31:0] ce_y,ce_status;logic [1:0][8:0] ce_pending,ce_flight;
 int ce_idle_cycles=0,ce_active_cycles=0,ce_pending_empty_pipe_cycles=0;
 int ce_first_stage=0,ce_middle_stage=0,ce_last_stage=0,ce_valid_events=0;
 int core_accepted=0,core_returned=0,core_cycles[0:MAXQ-1],core_latency_checks=0,ce_wall=0;

`ifdef TANH_EQ
 laya_m007_tanh8_v3 #(.FORCE_CORE_CE(0)) auto_dut(.clk,.rst_n,
  .lease_valid,.lease_ready(ce_lease_ready[1]),.lease_request_id(rid),.lease_generation(generation),.lease_epoch(epoch),.lease_phase,
  .release_valid,.release_ready(ce_release_ready[1]),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(debt_clear),
  .lease_active(ce_active[1]),.draining(ce_draining[1]),.rsp_request_id(ce_rrid[1]),.rsp_generation(ce_gen[1]),.rsp_epoch(ce_epoch[1]),.rsp_phase(ce_phase[1]),
  .req_valid(iv),.req_ready(ce_ir[1]),.req_mode(mode),.req_request_id(req_rid),.req_generation(req_gen),.req_epoch,.req_phase,.req_tag(tag),.req_mask(mask),.req_x(x),
  .reject_valid(ce_reject[1]),.reject_code(ce_reject_code[1]),.rsp_valid(ce_ov[1]),.rsp_ready(ready),.rsp_tag(ce_tag[1]),.rsp_mask(ce_mask[1]),.rsp_data(ce_y[1]),.rsp_status(ce_status[1]),
  .pending_vectors(ce_pending[1]),.in_flight_vectors(ce_flight[1]),.protocol_fault(ce_fault[1]));

`else
 assign {ce_lease_ready[1],ce_release_ready[1],ce_active[1],ce_draining[1],ce_ir[1],ce_ov[1],ce_reject[1],ce_reject_code[1],ce_fault[1],ce_pending[1],ce_flight[1],ce_rrid[1],ce_gen[1],ce_epoch[1],ce_phase[1],ce_y[1],ce_status[1],ce_tag[1],ce_mask[1]}=
 {lease_ready,release_ready,active,draining,ir,ov,reject_valid,reject_code,fault,pending,flight,rrid,rgen,repoch,rphase,y,status,ot,om};
`endif
 int secondary_node_checks=0;
 task automatic cost_mark(input string stage_name);
  $display("TANH_PROCESS_STAGE stage=%s cycle=%0d",stage_name,wall);$fflush();
 endtask

 task automatic idle_noise(input int clocks);
  cost_mark("IDLE");
  iv=0;lease_valid=0;release_valid=0;mask=8'hff;
  repeat(clocks)begin
   @(negedge clk);
   for(int lane=0;lane<8;lane++)x[lane]=32'(wall*32'h13579bdf)^32'(lane*32'hdeadbeef);
   #0.001;if(`TANH_OBSERVER.core_ce||!`TANH_OBSERVER.all_token_empty||active||pending||flight)$fatal(1,"CE_IDLE_NOT_FROZEN");
  end
  cost_mark("RUN");
 endtask
 for(genvar lane=0;lane<8;lane++)begin:ce_token_monitor
  always @(posedge clk)if(rst_n)begin
   if(dut.tanh_lane[lane].core.valid_pipe!==`TANH_OBSERVER.tanh_lane[lane].core.valid_pipe)$fatal(1,"CE_TOKEN_ALIGNMENT lane=%0d",lane);
  end
  logic[63:0]idle_sample;
  always @(posedge clk)if(rst_n&&!`TANH_OBSERVER.core_ce)begin
   idle_sample={`TANH_OBSERVER.tanh_lane[lane].core.input_bits,`TANH_OBSERVER.tanh_lane[lane].core.selected_result};
   #0.001;if({`TANH_OBSERVER.tanh_lane[lane].core.input_bits,`TANH_OBSERVER.tanh_lane[lane].core.selected_result}!==idle_sample)$fatal(1,"CE_IDLE_DATA_CHANGED lane=%0d",lane);
  end
 end
 always @(posedge clk)begin:ce_equivalence
  ce_wall++;
  if(!rst_n)begin
   core_accepted=0;core_returned=0;
   if(!`TANH_OBSERVER.core_ce)$fatal(1,"CE_RESET_DISABLED");
  end else begin
   for(int variant=1;variant<2;variant++)begin
    if({lease_ready,release_ready,active,draining,ir,ov,reject_valid,reject_code,fault,pending,flight,rrid,rgen,repoch,rphase}!==
       {ce_lease_ready[variant],ce_release_ready[variant],ce_active[variant],ce_draining[variant],ce_ir[variant],ce_ov[variant],ce_reject[variant],ce_reject_code[variant],ce_fault[variant],ce_pending[variant],ce_flight[variant],ce_rrid[variant],ce_gen[variant],ce_epoch[variant],ce_phase[variant]})$fatal(1,"CE_PUBLIC_CONTROL variant=%0d phase=%0d",variant,phase);
    if(ov&&{y,status,ot,om}!=={ce_y[variant],ce_status[variant],ce_tag[variant],ce_mask[variant]})$fatal(1,"CE_VALID_RESPONSE variant=%0d phase=%0d",variant,phase);
   end
   if((active||pending!=0||flight!=0||!`TANH_OBSERVER.all_token_empty||fault||(lease_valid&&lease_ready)||(iv&&ir))&&!`TANH_OBSERVER.core_ce)$fatal(1,"CE_REQUIRED_WAKE");
   if(active)ce_active_cycles++;if(!`TANH_OBSERVER.core_ce)ce_idle_cycles++;
   if(pending!=0&&`TANH_OBSERVER.all_token_empty)begin if(!`TANH_OBSERVER.core_ce)$fatal(1,"CE_PENDING_EMPTY_PIPE");ce_pending_empty_pipe_cycles++;end
   if(`TANH_OBSERVER.core_token_empty!==~{|`TANH_OBSERVER.tanh_lane[7].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[6].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[5].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[4].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[3].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[2].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[1].core.valid_pipe,|`TANH_OBSERVER.tanh_lane[0].core.valid_pipe})$fatal(1,"CE_TOKEN_EMPTY_FULL_VIEW");
   if(`TANH_OBSERVER.tanh_lane[0].core.valid_pipe[0])ce_first_stage++;
   if(`TANH_OBSERVER.tanh_lane[0].core.valid_pipe[75])ce_middle_stage++;
   if(`TANH_OBSERVER.tanh_lane[0].core.valid_pipe[151])ce_last_stage++;
   if(iv&&ir)begin core_cycles[core_accepted]=ce_wall;core_accepted++;end
   if(dut.core_valid[0])begin
    if(core_returned>=core_accepted||ce_wall-core_cycles[core_returned]!=152)$fatal(1,"CE_CORE_TOKEN_LATENCY observed=%0d",ce_wall-core_cycles[core_returned]);
    core_returned++;core_latency_checks++;
   end
   if(ov)ce_valid_events++;
  end
 end

 task automatic lease;
  @(negedge clk);lease_valid=1;while(!lease_ready)@(negedge clk);
  @(negedge clk);lease_valid=0;if(!active||rrid!=rid||rgen!=generation||repoch!=epoch||rphase!=1)$fatal(1,"LEASE_IDENTITY");
 endtask
 task automatic drive(input int base,input int limit);
  req_rid=rid;req_gen=generation;req_epoch=epoch;req_phase=1;mode=1;tag={32'hfedcba98,generation,32'(base)};
  for(int lane=0;lane<8;lane++)begin ref_id[lane]=phase==1?(base+lane<384?total_count-390+base+lane:base+lane-384):base+lane;mask[lane]=base+lane<limit;x[lane]=mask[lane]?vectors[ref_id[lane]][95:64]:32'b0;end
  iv=1;
 endtask
 task automatic send(input int base,input int limit);
  @(negedge clk);drive(base,limit);#0.001;
  while(!ir)begin @(negedge clk);#0.001;end
 endtask
 task automatic reject_check(input int code);
  repeat(2)begin @(negedge clk);if(ir||!reject_valid||reject_code!=code)$fatal(1,"REJECT code=%0d",code);end
  rejections=rejections+1;
 endtask
 task automatic progress;
  $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":%0d,\"returned\":%0d}",checked,node_checks,wall,phase,returned);$fflush(progress_fd);
 endtask
 initial begin
  cost_mark("INIT");if(!$value$plusargs("TRACE_FILE=%s",trace_path))$fatal(1,"TRACE_REQUIRED");trace_fd=$fopen(trace_path,"w");if(!trace_fd)$fatal(1,"TRACE_OPEN");
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("NODES=%s",nf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("COUNT=%d",count)||!$value$plusargs("TOTAL_COUNT=%d",total_count)||count<8||count>MAXV||total_count>MAXV)$fatal(1,"ARGS");
  main_vectors=(count+7)/8;$readmemh(vf,vectors);$readmemh(nf,nodes);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");cost_mark("RUN");
  repeat(5)@(negedge clk);rst_n=1;idle_noise(128);rst_n=0;repeat(3)@(negedge clk);rst_n=1;idle_noise(64);lease();
  @(negedge clk);drive(0,total_count);mode=0;reject_check(1);
  mode=1;req_gen=generation+1;reject_check(3);req_gen=generation;req_epoch=epoch+1;reject_check(3);
  req_epoch=epoch;req_phase=3;reject_check(3);req_phase=1;req_rid=rid+1;reject_check(3);
  req_rid=rid;mask=0;reject_check(2);iv=0;phase=1;
  for(int i=0;i<main_vectors;i++)send(8*i,count);
  @(negedge clk);iv=0;wait(returned==main_vectors);repeat(3)@(negedge clk);
  if(accepted!=main_vectors||returned!=main_vectors||checked!=count||node_checks!=count*42)$fatal(1,"MAIN_COUNTS accepted=%0d returned=%0d checked=%0d nodes=%0d",accepted,returned,checked,node_checks);
  $display("TANH8_MAIN_PASS count=%0d vectors=%0d first_actual_consume=%0d ii=1 node_checks=%0d",count,main_vectors,first_latency,node_checks);
  phase=2;ready=0;for(int i=0;i<256;i++)send(8*i,total_count);
  @(negedge clk);iv=0;wait(pending==256);repeat(160)@(negedge clk);
  if(ir||flight||!ov)$fatal(1,"REAL_FULL_CREDIT");release_valid=1;debt_clear=0;
  repeat(19)begin @(negedge clk);if(release_ready||!active)$fatal(1,"RELEASE_HELD_DEBT");end
  ready=1;wait(returned==main_vectors+256);repeat(3)@(negedge clk);
  if(pending||flight||release_ready||!active||!draining)$fatal(1,"EXTERNAL_DEBT_BARRIER");
  debt_clear=1;wait(!active);@(negedge clk);release_valid=0;epoch=epoch+1;lease();phase=3;
  for(int i=0;i<17;i++)send(8*i,total_count);
  @(negedge clk);if(flight!=17||accepted-returned!=17)$fatal(1,"RESET_NOT_17_INFLIGHT actual=%0d",flight);rst_n=0;iv=0;ready=0;
  repeat(3)@(negedge clk);rst_n=1;ready=1;repeat(160)@(negedge clk);
  if(ov||pending||flight||active||accepted||returned)$fatal(1,"RESET_OLD_RETURN");
  generation=generation+1;epoch=epoch+1;lease();phase=4;
  for(int i=0;i<64;i++)send(8*i,total_count);
  @(negedge clk);iv=0;wait(returned==64);repeat(3)@(negedge clk);
  phase=5;ready=0;send(total_count-6,total_count);@(negedge clk);iv=0;wait(!flight);repeat(17)@(negedge clk);
  if(!ov||pending!=1||om!=8'h3f)$fatal(1,"ERROR_HELD_VECTOR");
  for(int lane=0;lane<8;lane++)if(y[lane]!==0||status[lane]!==32'(lane<6))$fatal(1,"ERROR_LANE_RETIRE");
  ready=1;wait(returned==65);repeat(3)@(negedge clk);release_valid=1;wait(!active);@(negedge clk);release_valid=0;

  idle_noise(192);generation++;epoch++;lease();phase=4;
  for(int i=0;i<8;i++)begin send(8*i,total_count);@(negedge clk);iv=0;repeat(3*(i+1))@(negedge clk);end
  @(negedge clk);iv=0;wait(returned==73);repeat(3)@(negedge clk);
  release_valid=1;wait(!active);@(negedge clk);release_valid=0;idle_noise(64);progress();
  if(ce_idle_cycles<448||ce_first_stage==0||ce_middle_stage==0||ce_last_stage==0||ce_pending_empty_pipe_cycles<17||core_latency_checks==0||core_returned!=core_accepted)$fatal(1,"CE_COVERAGE");
  $display("TANH_PROCESS_WORKLOAD_PASS idle_ce0=%0d active_ce1=%0d pending_empty_pipe=%0d first=%0d middle=%0d last=%0d valid_events=%0d core152_checks=%0d wrapper_consume_latency=%0d no_reset_newgen8=1 boundary384=1",ce_idle_cycles,ce_active_cycles,ce_pending_empty_pipe_cycles,ce_first_stage,ce_middle_stage,ce_last_stage,ce_valid_events,core_latency_checks,first_latency);
`ifdef TANH_EQ
  if(secondary_node_checks!=node_checks)$fatal(1,"SECONDARY_NODE_COUNTS primary=%0d secondary=%0d",node_checks,secondary_node_checks);
  $display("TANH_PROCESS_SAME_RUNTIME_PASS secondary_node_checks=%0d",secondary_node_checks);
`endif
  if(fault||pending||flight||checked!=count+2630)$fatal(1,"FINAL_DEBT_COUNT fault=%0d pending=%0d flight=%0d checked=%0d expected=%0d",fault,pending,flight,checked,count+2630);$fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS TANH8 checked=%0d node_checks=%0d first_actual_consume=%0d pending_peak=%0d flight_peak=%0d held_cycles=%0d rejects=%0d reset_inflight17vectors_newgen64=1 nonfinite6_masked2=1 release_external_debt=1",checked,node_checks,first_latency,peak_pending,peak_flight,held_cycles,rejections);cost_mark("DONE");$fclose(trace_fd);$finish;
 end
 logic holding=0;logic [615:0] held;
 always @(posedge clk)begin
  wall=wall+1;if(wall>2*MAXV)$fatal(1,"TIMEOUT");
  if(!rst_n)begin accepted=0;returned=0;last=-1;holding=0;end
  else begin
   if(fault)$fatal(1,"PROTOCOL_FAULT");
   if(holding&&(!ov||{y,status,ot,om}!==held))$fatal(1,"HELD_PAYLOAD");
   holding=ov&&!ready;if(holding)begin held={y,status,ot,om};held_cycles=held_cycles+1;end
   if(iv&&ir)begin
    for(int lane=0;lane<8;lane++)begin expected[accepted][lane]=mask[lane]?vectors[ref_id[lane]][63:32]:0;errors[accepted][lane]=mask[lane]?vectors[ref_id[lane]][31:0]:0;end
    tags[accepted]=tag;masks[accepted]=mask;cycles_q[accepted]=wall;accepted=accepted+1;
   end
   if(ov&&ready)begin
    $fdisplay(trace_fd,"%0d %0d %h %h %h %h %h %h %h %h",wall,phase,y,status,ot,om,rrid,rgen,repoch,rphase);
    if(returned>=accepted||y!==expected[returned]||status!==errors[returned]||ot!==tags[returned]||om!==masks[returned])$fatal(1,"NUMERIC_TAG_MASK phase=%0d vector=%0d",phase,returned);
    if(phase==1)begin
     if(first_latency<0)first_latency=wall-cycles_q[returned];
     if(wall-cycles_q[returned]>160)$fatal(1,"LATENCY_OVER160");
     if(last>=0&&wall!=last+1)$fatal(1,"II");last=wall;
    end
    checked=checked+$countones(masks[returned]);returned=returned+1;
    if(checked%4096==0||(phase==1&&returned==main_vectors)||(phase==2&&returned==main_vectors+256)||(phase==4&&returned==64)||(phase==5&&returned==65))progress();
   end
   if(pending>peak_pending)peak_pending=pending;if(flight>peak_flight)peak_flight=flight;
  end
 end
 always @(posedge clk)begin
  for(int lane=0;lane<8;lane++)begin id_pipe[0][lane]<=ref_id[lane];for(int i=1;i<152;i++)id_pipe[i][lane]<=id_pipe[i-1][lane];end
  mask_pipe[0]<=mask;for(int i=1;i<152;i++)mask_pipe[i]<=mask_pipe[i-1];
 end
 `include "m007_tanh_process_nodes.svh"
endmodule
