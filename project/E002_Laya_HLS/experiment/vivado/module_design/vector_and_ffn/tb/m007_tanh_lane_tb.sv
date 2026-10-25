`timescale 1ns/1ps
module m007_tanh_lane_tb;
 localparam int MAXV=400000;
 logic clk=0;always #1.6665 clk=~clk;
 logic reset=1,iv=0,ir,ov,ready=1;logic [31:0] x=0,y,status;logic [95:0] tag=0,ot;
 wire [8:0] pending,flight;
 logic [95:0] vectors[0:MAXV-1];logic [1343:0] nodes[0:MAXV-1];
 logic [31:0] expected[0:MAXV+1023],errors[0:MAXV+1023];logic [95:0] tags[0:MAXV+1023];
 int accepted=0,returned=0,wall=0,checked=0,reference_index=0,count,total_count,cycles_q[0:MAXV+1023];
 int id_pipe[0:151];int phase=0,last=-1,first_latency=-1,peak_pending=0,peak_flight=0,held_cycles=0,node_checks=0;
 string vf,nf,pf;integer progress_fd;
 // Only called after the actual output handshake and numeric/status/tag checks.
 // The file is flushed here; host liveness never relies on a log mtime/heartbeat.
 task automatic consumed_progress;
  $fdisplay(progress_fd,"{\"schema\":\"m007-tanh-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":%0d,\"returned\":%0d}",checked,node_checks,wall,phase,returned);
  $fflush(progress_fd);
 endtask
 laya_m007_tanh_lane_v1 dut(.clk,.reset,.in_valid(iv),.in_ready(ir),.in_data(x),.in_tag(tag),.out_valid(ov),.out_ready(ready),.out_data(y),.out_status(status),.out_tag(ot),.pending,.in_flight(flight));
 task automatic drive(input int i);reference_index=i;x=vectors[i][95:64];tag={32'h12345678+32'(phase>=4),32'h9abcdef0+32'(phase>=4),32'(i)};iv=1;endtask
 task automatic send(input int i);@(negedge clk);drive(i);while(!ir)@(negedge clk);endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf)||!$value$plusargs("NODES=%s",nf)||!$value$plusargs("PROGRESS_FILE=%s",pf)||!$value$plusargs("COUNT=%d",count)||!$value$plusargs("TOTAL_COUNT=%d",total_count)||count>MAXV||total_count>MAXV)$fatal(1,"ARGS");
  progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_FILE_OPEN");
  $readmemh(vf,vectors);$readmemh(nf,nodes);
  repeat(5)@(negedge clk);reset=0;phase=1;
  for(int i=0;i<count;i++)send(i);
  @(negedge clk);iv=0;wait(returned==count);repeat(3)@(negedge clk);
  $display("TANH_MAIN_PASS count=%0d first_actual_consume=%0d ii=1 node_checks=%0d",count,first_latency,node_checks);
  phase=2;ready=0;
  for(int i=0;i<256;i++)send(i);
  @(negedge clk);iv=0;wait(pending==256);repeat(160)@(negedge clk);
  if(ir||flight!=0||!ov)$fatal(1,"NOT_REAL_FULL_CREDIT");
  repeat(19)@(negedge clk);ready=1;wait(returned==count+256);repeat(3)@(negedge clk);
  if(pending||flight)$fatal(1,"DRAIN_DEBT");phase=3;
  for(int i=0;i<17;i++)send(i);
  @(negedge clk);if(!flight)$fatal(1,"RESET_NOT_REAL_INFLIGHT");reset=1;iv=0;ready=0;
  repeat(3)@(negedge clk);reset=0;ready=1;repeat(160)@(negedge clk);
  if(ov||pending||flight||accepted||returned)$fatal(1,"RESET_OLD_RETURN");phase=4;
  for(int i=0;i<64;i++)send(i);
  @(negedge clk);iv=0;wait(returned==64);repeat(3)@(negedge clk);
  phase=5;ready=0;
  for(int i=total_count-6;i<total_count;i++)send(i);
  @(negedge clk);iv=0;wait(flight==0);repeat(17)@(negedge clk);
  if(!ov||status!==1||y!==0||pending!=6)$fatal(1,"ERROR_RECORD_HOLD");
  ready=1;wait(returned==70);repeat(3)@(negedge clk);
  $fclose(progress_fd);
  $display("HARDWARE_AGENT_SIM_PASS TANH_LANE checked=%0d node_checks=%0d first_actual_consume=%0d pending_peak=%0d flight_peak=%0d held_cycles=%0d reset_inflight17_newgen_recovery64=1 error_held_retired6=1",checked,node_checks,first_latency,peak_pending,peak_flight,held_cycles);$finish;
 end
 logic holding=0;logic [159:0] held;
 always @(posedge clk)begin
  wall=wall+1;if(wall>2*MAXV)$fatal(1,"TIMEOUT");
  if(reset)begin accepted=0;returned=0;last=-1;holding=0;end
  else begin
   if(holding&&(!ov||{y,status,ot}!==held))$fatal(1,"HELD_PAYLOAD");
   holding=ov&&!ready;if(holding)begin held={y,status,ot};held_cycles=held_cycles+1;end
   if(iv&&ir)begin expected[accepted]=vectors[reference_index][63:32];errors[accepted]=vectors[reference_index][31:0];tags[accepted]=tag;cycles_q[accepted]=wall;accepted=accepted+1;end
   if(ov&&ready)begin
    if(returned>=accepted||y!==expected[returned]||status!==errors[returned]||ot!==tags[returned])$fatal(1,"NUMERIC_TAG_ERROR phase=%0d index=%0d got=%h expected=%h status=%h",phase,returned,y,expected[returned],status);
    if(phase==1)begin
     if(first_latency<0)first_latency=wall-cycles_q[returned];
     if(wall-cycles_q[returned]>160)$fatal(1,"LATENCY_OVER160");
     if(last>=0&&wall!=last+1)$fatal(1,"II");last=wall;
    end
    returned=returned+1;checked=checked+1;
    if((checked%4096)==0||(phase==1&&returned==count)||(phase==2&&returned==count+256)||(phase==4&&returned==64)||(phase==5&&returned==70))consumed_progress();
   end
   if(pending>peak_pending)peak_pending=pending;if(flight>peak_flight)peak_flight=flight;
  end
 end
 always @(posedge clk)begin
  id_pipe[0]<=reference_index;for(int i=1;i<152;i++)id_pipe[i]<=id_pipe[i-1];
 end
 `include "m007_tanh_node_checks.svh"
endmodule
