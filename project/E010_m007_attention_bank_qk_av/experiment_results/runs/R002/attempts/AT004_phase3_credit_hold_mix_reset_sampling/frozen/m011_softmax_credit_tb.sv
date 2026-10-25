`timescale 1ns/1ps
module m011_softmax_credit_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic lease_valid=0,lease_ready,release_valid=0,release_ready,lease_active,draining;
 logic [63:0] rsp_request_id;logic[31:0]rsp_generation,rsp_epoch;logic[3:0]rsp_head;logic[2:0]rsp_phase;
 logic mul_req_ready,mul_rsp_valid;logic[95:0]mul_rsp_tag;logic[255:0][31:0]mul_rsp_data;
 logic[6:0]add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;
 logic[6:0][2:0]add_req_phase;logic[6:0][31:0]add_req_epoch;
 logic[6:0][95:0]add_req_tag,add_rsp_tag;logic[255:0][31:0]add_a,add_b,add_rsp_data;
 logic[6:0]mul_pending;logic[6:0][6:0]add_pending;logic protocol_fault;
 logic send_enable=0,rsp_gate=0;logic[2:0] phase=3;logic[31:0] generation=1,epoch=90;int goal=6;int bypass_held=0,buffered_consumed=0,mixed_return=0;
 int cycle=0,first_accept=-1,first_return=-1,last_return=-1,sent=0,received=0;
 laya_shared_fp256_v2 dut(.clk,.rst_n,.lease_valid,.lease_ready,.lease_request_id(64'd3),.lease_generation(generation),.lease_epoch(epoch),.lease_head(4'd0),.lease_phase(phase),.release_valid,.release_ready,.release_phase(phase),.release_epoch(epoch),.phase_debt_clear(1'b1),.lease_active,.draining,.rsp_request_id,.rsp_generation,.rsp_epoch,.rsp_head,.rsp_phase,
 .mul_req_valid(1'b0),.mul_req_ready,.mul_req_phase(3'd3),.mul_req_epoch(32'd90),.mul_req_tag(96'b0),.mul_a(8192'b0),.mul_b(8192'b0),.mul_rsp_valid,.mul_rsp_ready(1'b1),.mul_rsp_tag,.mul_rsp_data,
 .add_req_valid,.add_req_is_root,.add_req_ready,.add_req_phase,.add_req_epoch,.add_req_tag,.add_a,.add_b,.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data,.mul_pending,.add_pending,.protocol_fault);

 always_comb begin
  add_req_valid=0;add_req_is_root=0;add_req_phase={7{phase}};add_req_epoch={7{epoch}};add_req_tag=0;add_a=0;add_b=0;add_rsp_ready=0;
  add_req_valid[0]=lease_active&&send_enable&&sent<goal;add_req_is_root[0]=1;add_req_tag[0]=96'(sent);
  for(int c=0;c<256;c++)begin add_a[c]=word(sent+1);add_b[c]=32'h3f800000;end
  add_rsp_ready[0]=rsp_gate;
 end
 function automatic logic[31:0] word(input int n);case(n)1:return 32'h3f800000;2:return 32'h40000000;3:return 32'h40400000;4:return 32'h40800000;5:return 32'h40a00000;6:return 32'h40c00000;7:return 32'h40e00000;default:return 32'h41000000;endcase endfunction
 task automatic lease_now;
  @(negedge clk);lease_valid=1;do @(posedge clk);while(!lease_ready);@(negedge clk);lease_valid=0;
 endtask
 task automatic clear_counts;
  sent=0;received=0;first_accept=-1;first_return=-1;last_return=-1;
 endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;lease_now();send_enable=1;
  wait(sent==6);@(negedge clk);send_enable=0;wait(add_rsp_valid[0]);
  begin logic[8191:0] held;logic[95:0] held_tag;held=add_rsp_data;held_tag=add_rsp_tag[0];
   @(negedge clk);release_valid=1;
   repeat(4)begin
    @(negedge clk);if(!add_rsp_valid[0]||add_rsp_data!==held||add_rsp_tag[0]!==held_tag||release_ready||!lease_active)$fatal(1,"CREDIT_HELD_OR_RELEASE");
   end
  end
  rsp_gate=1;wait(received==6);wait(!lease_active);@(negedge clk);release_valid=0;
  if(mul_pending||add_pending||protocol_fault||bypass_held<1||buffered_consumed<1||mixed_return<1)$fatal(1,"CREDIT_MIXED_COVERAGE b%0d h%0d m%0d",bypass_held,buffered_consumed,mixed_return);
  $display("M011_CREDIT_HELD_PASS checked1536 bypass_held%0d buffered_consumed%0d mixed_return%0d debt0 release_delayed1",bypass_held,buffered_consumed,mixed_return);
  generation=2;epoch=91;phase=3;goal=4;clear_counts();rsp_gate=0;lease_now();send_enable=1;
  wait(sent==4);@(negedge clk);send_enable=0;
  if(add_pending==0||dut.add_inflight==0)$fatal(1,"CREDIT_RESET_NOT_INFLIGHT");
  $display("M011_CREDIT_RESET_INFLIGHT pending%h inflight%h",add_pending,dut.add_inflight);
  rst_n=0;repeat(3)@(negedge clk);rst_n=1;rsp_gate=1;
  repeat(12)begin @(negedge clk);if(add_rsp_valid||mul_rsp_valid||add_pending||mul_pending||lease_active||protocol_fault)$fatal(1,"CREDIT_RESET_STALE_RETURN");end
  generation=3;epoch=92;phase=1;goal=4;clear_counts();lease_now();send_enable=1;
  wait(received==4);@(negedge clk);send_enable=0;
  if(first_return-first_accept!=9)$fatal(1,"CREDIT_PHASE1_TIMING got%0d",first_return-first_accept);
  release_valid=1;wait(!lease_active);@(negedge clk);
  if(add_pending||mul_pending||protocol_fault)$fatal(1,"CREDIT_FINAL_DEBT");
  $display("HARDWARE_AGENT_SIM_PASS M011_CREDIT held_to_reserved_slot1 mixed_head1 reset_inflight1 generation3 phase1_latency9 checked2560 debt0 release1");$finish;
 end
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>500)$fatal(1,"CREDIT_TIMEOUT");
  if(rst_n)begin
   if(protocol_fault)$fatal(1,"CREDIT_PROTOCOL_FAULT");
   if(add_rsp_valid[0]&&!add_rsp_ready[0]&&dut.add_group[0].credit.bypass_head)bypass_held++;
   if(dut.add_group[0].credit.result_valid&&dut.add_group[0].credit.available[dut.add_group[0].credit.head_ptr])mixed_return++;
   if(add_req_valid[0]&&add_req_ready[0])begin if(sent==0)first_accept=cycle;sent<=sent+1;end
   if(add_rsp_valid[0]&&add_rsp_ready[0])begin
    if(dut.add_group[0].credit.available[dut.add_group[0].credit.head_ptr])buffered_consumed++;
    if(add_rsp_tag[0]!==96'(received)||rsp_request_id!==3||rsp_generation!==generation||rsp_epoch!==epoch||rsp_phase!==phase)$fatal(1,"CREDIT_RETURN_ID");
    for(int c=0;c<256;c++)if(add_rsp_data[c]!==word(received+2))$fatal(1,"CREDIT_VALUE idx%0d lane%0d got%h",received,c,add_rsp_data[c]);
    if(received==0)first_return=cycle;last_return=cycle;received++;
   end
  end
 end
endmodule
