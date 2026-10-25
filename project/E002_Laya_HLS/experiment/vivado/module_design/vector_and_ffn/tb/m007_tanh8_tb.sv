`timescale 1ns/1ps
module m007_tanh8_tb;
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
 string vf,nf,pf;integer progress_fd;
 laya_m007_tanh8_v1 dut(.clk,.rst_n,.lease_valid,.lease_ready,.lease_request_id(rid),.lease_generation(generation),.lease_epoch(epoch),.lease_phase,
  .release_valid,.release_ready,.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(debt_clear),.lease_active(active),.draining,
  .rsp_request_id(rrid),.rsp_generation(rgen),.rsp_epoch(repoch),.rsp_phase(rphase),
  .req_valid(iv),.req_ready(ir),.req_mode(mode),.req_request_id(req_rid),.req_generation(req_gen),.req_epoch,.req_phase,.req_tag(tag),.req_mask(mask),.req_x(x),
  .reject_valid,.reject_code,.rsp_valid(ov),.rsp_ready(ready),.rsp_tag(ot),.rsp_mask(om),.rsp_data(y),.rsp_status(status),
  .pending_vectors(pending),.in_flight_vectors(flight),.protocol_fault(fault));
 task automatic lease;
  @(negedge clk);lease_valid=1;while(!lease_ready)@(negedge clk);
  @(negedge clk);lease_valid=0;if(!active||rrid!=rid||rgen!=generation||repoch!=epoch||rphase!=1)$fatal(1,"LEASE_IDENTITY");
 endtask
 task automatic drive(input int base,input int limit);
  req_rid=rid;req_gen=generation;req_epoch=epoch;req_phase=1;mode=1;tag={32'hfedcba98,generation,32'(base)};
  for(int lane=0;lane<8;lane++)begin ref_id[lane]=base+lane;mask[lane]=base+lane<limit;x[lane]=mask[lane]?vectors[base+lane][95:64]:32'b0;end
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
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("NODES=%s",nf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("COUNT=%d",count)||!$value$plusargs("TOTAL_COUNT=%d",total_count)||count<8||count>MAXV||total_count>MAXV)$fatal(1,"ARGS");
  main_vectors=(count+7)/8;$readmemh(vf,vectors);$readmemh(nf,nodes);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;lease();
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
  if(fault||pending||flight||checked!=count+2566)$fatal(1,"FINAL_DEBT_COUNT fault=%0d pending=%0d flight=%0d checked=%0d expected=%0d",fault,pending,flight,checked,count+2566);$fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS TANH8 checked=%0d node_checks=%0d first_actual_consume=%0d pending_peak=%0d flight_peak=%0d held_cycles=%0d rejects=%0d reset_inflight17vectors_newgen64=1 nonfinite6_masked2=1 release_external_debt=1",checked,node_checks,first_latency,peak_pending,peak_flight,held_cycles,rejections);$finish;
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
 `include "m007_tanh8_node_checks.svh"
endmodule
