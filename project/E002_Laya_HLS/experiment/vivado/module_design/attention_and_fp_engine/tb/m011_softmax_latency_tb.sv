`timescale 1ns/1ps
module m011_softmax_latency_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic lease_valid=0,lease_ready,release_valid=0,release_ready,lease_active,draining;
 logic [63:0] rsp_request_id;logic[31:0]rsp_generation,rsp_epoch;logic[3:0]rsp_head;logic[2:0]rsp_phase;
 logic mul_req_ready,mul_rsp_valid;logic[95:0]mul_rsp_tag;logic[255:0][31:0]mul_rsp_data;
 logic[6:0]add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;
 logic[6:0][2:0]add_req_phase;logic[6:0][31:0]add_req_epoch;
 logic[6:0][95:0]add_req_tag,add_rsp_tag;logic[255:0][31:0]add_a,add_b,add_rsp_data;
 logic[6:0]mul_pending;logic[6:0][6:0]add_pending;logic protocol_fault;
 logic launch_pending=0;
 int cycle=0,first_accept=-1,first_return=-1,last_return=-1,sent=0,received=0;
 laya_shared_fp256_v2 dut(.clk,.rst_n,.lease_valid,.lease_ready,.lease_request_id(64'd3),.lease_generation(32'd1),.lease_epoch(32'd90),.lease_head(4'd0),.lease_phase(3'd3),.release_valid,.release_ready,.release_phase(3'd3),.release_epoch(32'd90),.phase_debt_clear(1'b1),.lease_active,.draining,.rsp_request_id,.rsp_generation,.rsp_epoch,.rsp_head,.rsp_phase,
 .mul_req_valid(1'b0),.mul_req_ready,.mul_req_phase(3'd3),.mul_req_epoch(32'd90),.mul_req_tag(96'b0),.mul_a(8192'b0),.mul_b(8192'b0),.mul_rsp_valid,.mul_rsp_ready(1'b1),.mul_rsp_tag,.mul_rsp_data,
 .add_req_valid,.add_req_is_root,.add_req_ready,.add_req_phase,.add_req_epoch,.add_req_tag,.add_a,.add_b,.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data,.mul_pending,.add_pending,.protocol_fault);
 always_comb begin
  add_req_valid=0;add_req_is_root=0;add_req_phase={7{3'd3}};add_req_epoch={7{32'd90}};add_req_tag=0;add_a=0;add_b=0;add_rsp_ready=0;
  add_req_valid[0]=lease_active&&(launch_pending||(add_rsp_valid[0]&&add_rsp_tag[0]<6));
  add_req_is_root[0]=launch_pending;
  add_req_tag[0]=launch_pending?96'd0:add_rsp_tag[0]+1'b1;
  for(int c=0;c<256;c++)begin add_a[c]=launch_pending?32'h3f800000:add_rsp_data[c];add_b[c]=32'h3f800000;end
  add_rsp_ready[0]=add_rsp_tag[0]<6?add_req_ready[0]:1'b1;
 end
 function automatic logic[31:0] gold(input int idx);case(idx)0:return 32'h40000000;1:return 32'h40400000;2:return 32'h40800000;3:return 32'h40a00000;4:return 32'h40c00000;5:return 32'h40e00000;default:return 32'h41000000;endcase endfunction
 initial begin
  repeat(4)@(negedge clk);rst_n=1;@(negedge clk);lease_valid=1;do @(posedge clk);while(!lease_ready);@(negedge clk);lease_valid=0;launch_pending=1;
  wait(received==7);@(negedge clk);if(mul_pending||add_pending||protocol_fault)$fatal(1,"SUM_BASELINE_DEBT");release_valid=1;wait(!lease_active);@(negedge clk);
  $display("M011_SUM_NUMERIC_PASS phase3 full256 checked%0d first_latency%0d seventh_return_tail%0d consecutive_dependency_gap%0d actual_debt0 lease_release1",received*256,first_return-first_accept,last_return-first_accept,(last_return-first_return)/6);
  if(last_return-first_accept>56)$fatal(1,"SOFTMAX_SUM_TAIL_CYCLE_FAIL got%0d limit56",last_return-first_accept);
  $display("HARDWARE_AGENT_SIM_PASS M011_SUM_LATENCY");$finish;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>300)$fatal(1,"SUM_BASELINE_TIMEOUT");
  if(rst_n)begin
   if(protocol_fault)$fatal(1,"SUM_BASELINE_PROTOCOL");
   if(add_req_valid[0]&&add_req_ready[0])begin if(sent==0)first_accept=cycle;sent++;launch_pending<=0;end
   if(add_rsp_valid[0]&&add_rsp_ready[0])begin
    if(add_rsp_tag[0]!==96'(received)||rsp_request_id!==3||rsp_generation!==1||rsp_epoch!==90||rsp_phase!==3)$fatal(1,"SUM_BASELINE_ID");
    for(int c=0;c<256;c++)if(add_rsp_data[c]!==gold(received))$fatal(1,"SUM_BASELINE_VALUE idx%0d lane%0d got%h",received,c,add_rsp_data[c]);
    if(received==0)first_return=cycle;last_return=cycle;received++;
   end
  end
 end
endmodule
