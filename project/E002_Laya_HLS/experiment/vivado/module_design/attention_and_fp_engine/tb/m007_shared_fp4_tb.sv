`timescale 1ns/1ps
module m007_shared_fp4_tb;
 localparam int LANES=4;
 logic clk=0;always #1.6665 clk=~clk;
 logic rst_n=0,lease_valid=0,lease_ready,release_valid=0,release_ready;
 logic [63:0] lease_request_id=64'h123456789abcdef0,rsp_request_id;
 logic [31:0] lease_generation=7,lease_epoch=101,release_epoch=101;
 logic [31:0] rsp_generation,rsp_epoch;
 logic [3:0] lease_head=3,rsp_head;
 logic [2:0] lease_phase=2,release_phase=2,rsp_phase;
 logic phase_debt_clear=1,lease_active,draining;
 logic mul_req_valid=0,mul_req_ready,mul_rsp_valid,mul_rsp_ready=0;
 logic [2:0] mul_req_phase=2;
 logic [31:0] mul_req_epoch=101;
 logic [95:0] mul_req_tag,mul_rsp_tag;
 logic [LANES-1:0][31:0] mul_a,mul_b,mul_rsp_data;
 logic [0:0] add_req_valid=0,add_req_is_root=0,add_req_ready;
 logic [0:0][2:0] add_req_phase=2;
 logic [0:0][31:0] add_req_epoch=101;
 logic [0:0][95:0] add_req_tag,add_rsp_tag;
 logic [LANES-1:0][31:0] add_a,add_b,add_rsp_data;
 logic [0:0] add_rsp_valid,add_rsp_ready=0;
 logic [6:0] mul_pending;
 logic [0:0][6:0] add_pending;
 logic protocol_fault;
 logic [191:0] vectors [0:16383];
 int m_sent=0,a_sent=0,m_got=0,a_got=0,cycle=0,step=0;
 int checked=0,overlap=0,independent=0,full_reject=0,phase=0;
 logic [95:0] m_hold_tag,a_hold_tag;
 logic [LANES-1:0][31:0] m_hold_data,a_hold_data;
 logic m_held=0,a_held=0;
 int m_accept_at[0:1023],a_accept_at[0:1023],raw_m=0,raw_a=0,physical8_checks=0,idle_m=0,idle_a=0;
 string vf;
 laya_shared_fp256_v2 #(.LANES(LANES),.ADD_GROUPS(1)) dut(.*);
 task automatic values;
  mul_req_tag={64'h4d554c,32'(m_sent)};add_req_tag[0]={64'h414444,32'(a_sent)};
  for(int lane=0;lane<LANES;lane++) begin
   mul_a[lane]=vectors[m_sent*LANES+lane][191:160];
   mul_b[lane]=vectors[m_sent*LANES+lane][159:128];
   add_a[lane]=vectors[a_sent*LANES+lane][95:64];
   add_b[lane]=vectors[a_sent*LANES+lane][63:32];
  end
 endtask
 task automatic take_lease;
  @(negedge clk);lease_valid=1;
  @(posedge clk);if(!lease_ready)$fatal(1,"SHARED_LEASE");
  @(negedge clk);lease_valid=0;
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf))$fatal(1,"SHARED_FIXTURE_ARG");
  $readmemh(vf,vectors);
  repeat(5)@(negedge clk);rst_n=1;take_lease();
  @(negedge clk);values();mul_req_valid=1;add_req_valid=1;
  mul_req_epoch=100;add_req_epoch[0]=100;release_epoch=100;release_valid=1;
  #0.1;if(mul_req_ready||add_req_ready[0]||release_ready)$fatal(1,"SHARED_WRONG_EPOCH_ACCEPT");
  @(negedge clk);mul_req_valid=0;add_req_valid=0;release_valid=0;
  mul_req_epoch=101;add_req_epoch[0]=101;release_epoch=101;
  if(draining)$fatal(1,"SHARED_WRONG_RELEASE_DRAIN");
  phase=1;
  while(m_sent<64||a_sent<64)begin
   @(negedge clk);values();mul_req_valid=m_sent<64;add_req_valid[0]=a_sent<64;
  end
  @(negedge clk);values();mul_req_valid=1;add_req_valid=1;
  repeat(14)begin
   @(negedge clk);
   if(mul_pending!=64||add_pending[0]!=64||mul_req_ready||add_req_ready[0])
    $fatal(1,"SHARED_CAPACITY m=%0d a=%0d",mul_pending,add_pending[0]);
   full_reject++;
  end
  mul_req_valid=0;add_req_valid=0;mul_rsp_ready=1;add_rsp_ready=1;
  wait(m_got==64&&a_got==64);@(negedge clk);
  phase=2;step=0;
  while(m_sent<512||a_sent<512)begin
   @(negedge clk);values();
   mul_req_valid=m_sent<512&&step%3!=0;
   add_req_valid[0]=a_sent<512&&step%5!=0;
   mul_rsp_ready=!(step>=80&&step<180);
   add_rsp_ready[0]=!(step>=200&&step<300);
   step++;
  end
  @(negedge clk);mul_req_valid=0;add_req_valid=0;mul_rsp_ready=1;add_rsp_ready=1;
  wait(m_got==512&&a_got==512);repeat(4)@(negedge clk);
  $display("SHARED_STREAM_PASS lanes=4 mul=512 add=512 full_reject=%0d overlap=%0d independent=%0d",full_reject,overlap,independent);
  // A matching release stops roots, while dependent add work may drain.
  phase=3;mul_rsp_ready=0;
  while(m_sent<520)begin @(negedge clk);values();mul_req_valid=1;end
  @(negedge clk);mul_req_valid=1;release_valid=1;phase_debt_clear=0;
  #0.1;if(release_ready||mul_req_ready)$fatal(1,"SHARED_RELEASE_EARLY");
  while(a_sent<520)begin
   @(negedge clk);values();add_req_valid=1;add_req_is_root=0;
   #0.1;if(!add_req_ready[0])$fatal(1,"SHARED_DRAIN_ADD_BLOCKED");
  end
  @(negedge clk);mul_req_valid=0;add_req_valid=0;mul_rsp_ready=1;
  wait(m_got==520&&a_got==520);repeat(4)@(negedge clk);
  if(release_ready||!lease_active||!draining)$fatal(1,"SHARED_BANK_DEBT_BYPASS");
  phase_debt_clear=1;
  @(posedge clk);if(!release_ready)$fatal(1,"SHARED_RELEASE_NOT_READY");
  @(negedge clk);release_valid=0;
  if(lease_active)$fatal(1,"SHARED_RELEASE_STILL_ACTIVE");
  $display("SHARED_RELEASE_PASS stopped_root=1 dependent_add=8 external_debt_wait=1");
  // New lease, reset with real in-flight multiplier/adder operations.
  lease_epoch=102;release_epoch=102;mul_req_epoch=102;add_req_epoch[0]=102;
  lease_generation=8;take_lease();phase=4;
  repeat(3)begin @(negedge clk);values();mul_req_valid=1;add_req_valid=1;end
  @(negedge clk);rst_n=0;mul_req_valid=0;add_req_valid=0;
  repeat(3)@(negedge clk);rst_n=1;
  repeat(12)@(negedge clk);
  if(mul_rsp_valid||add_rsp_valid[0]||mul_pending||add_pending[0])$fatal(1,"SHARED_RESET_OLD_RETURN");
  lease_epoch=103;release_epoch=103;mul_req_epoch=103;add_req_epoch[0]=103;
  lease_generation=9;take_lease();phase=5;
  while(m_sent<32||a_sent<32)begin
   @(negedge clk);values();mul_req_valid=m_sent<32;add_req_valid[0]=a_sent<32;
  end
  @(negedge clk);mul_req_valid=0;add_req_valid=0;
  wait(m_got==32&&a_got==32);repeat(14)@(negedge clk);
  if(protocol_fault||mul_pending||add_pending[0]||overlap==0||independent==0)$fatal(1,"SHARED_FINAL_STATE");
  if(dut.mul_leaf_ce!==0||dut.add_group[0].add_leaf_ce!==0||idle_m==0||idle_a==0)$fatal(1,"FP4_EMPTY_ACTIVE_LEASE_CE");
  $display("FP4_CHANNEL_CE_PASS idle_mul%0d idle_add%0d physical8_returns%0d active_lease_empty1",idle_m,idle_a,physical8_checks);
  $display("HARDWARE_AGENT_SIM_PASS SHARED_FP4 checked_scalar_results=%0d independent_mul_add=1 reset_generation=9",checked);
  $finish;
 end
 always @(posedge clk)begin
  cycle++;
  if(cycle>20000)$fatal(1,"SHARED_TIMEOUT");
  if(!rst_n)begin m_sent=0;a_sent=0;m_got=0;a_got=0;m_held=0;a_held=0;raw_m=0;raw_a=0;end
  else begin
   if(dut.mul_leaf_valid[0])begin if(cycle-m_accept_at[raw_m]!=8)$fatal(1,"FP4_MUL_PHYSICAL8");raw_m++;physical8_checks++;end
   if(dut.add_leaf_valid[0])begin if(cycle-a_accept_at[raw_a]!=8)$fatal(1,"FP4_ADD_PHYSICAL8");raw_a++;physical8_checks++;end
   if(protocol_fault)$fatal(1,"SHARED_PROTOCOL_FAULT cycle=%0d",cycle);
   if(m_held&&(!mul_rsp_valid||mul_rsp_tag!==m_hold_tag||mul_rsp_data!==m_hold_data))$fatal(1,"SHARED_MUL_HOLD");
   if(a_held&&(!add_rsp_valid[0]||add_rsp_tag[0]!==a_hold_tag||add_rsp_data!==a_hold_data))$fatal(1,"SHARED_ADD_HOLD");
   m_held=mul_rsp_valid&&!mul_rsp_ready;a_held=add_rsp_valid[0]&&!add_rsp_ready[0];
   m_hold_tag=mul_rsp_tag;a_hold_tag=add_rsp_tag[0];m_hold_data=mul_rsp_data;a_hold_data=add_rsp_data;
   if(mul_req_valid&&mul_req_ready)begin
    m_accept_at[m_sent]=cycle;
    if(mul_req_tag!=={64'h4d554c,32'(m_sent)})$fatal(1,"SHARED_MUL_REQ_TAG");m_sent++;
   end
   if(add_req_valid[0]&&add_req_ready[0])begin
    a_accept_at[a_sent]=cycle;
    if(add_req_tag[0]!=={64'h414444,32'(a_sent)})$fatal(1,"SHARED_ADD_REQ_TAG");a_sent++;
   end
   if((mul_req_valid&&mul_req_ready)!=(add_req_valid[0]&&add_req_ready[0]))independent++;
   if((mul_req_valid&&mul_req_ready||add_req_valid[0]&&add_req_ready[0])&&
      (mul_rsp_valid&&mul_rsp_ready||add_rsp_valid[0]&&add_rsp_ready[0]))overlap++;
   if(mul_rsp_valid&&mul_rsp_ready)begin
    if(mul_rsp_tag!=={64'h4d554c,32'(m_got)}||m_got>=m_sent)$fatal(1,"SHARED_MUL_RSP_TAG");
    for(int lane=0;lane<LANES;lane++)if(mul_rsp_data[lane]!==vectors[m_got*LANES+lane][127:96])
     $fatal(1,"SHARED_MUL_NUMERIC tag=%0d lane=%0d got=%h exp=%h",m_got,lane,mul_rsp_data[lane],vectors[m_got*LANES+lane][127:96]);
    m_got++;checked+=LANES;
   end
   if(add_rsp_valid[0]&&add_rsp_ready[0])begin
    if(add_rsp_tag[0]!=={64'h414444,32'(a_got)}||a_got>=a_sent)$fatal(1,"SHARED_ADD_RSP_TAG");
    for(int lane=0;lane<LANES;lane++)if(add_rsp_data[lane]!==vectors[a_got*LANES+lane][31:0])
     $fatal(1,"SHARED_ADD_NUMERIC tag=%0d lane=%0d got=%h exp=%h",a_got,lane,add_rsp_data[lane],vectors[a_got*LANES+lane][31:0]);
    a_got++;checked+=LANES;
   end
   if((mul_rsp_valid||add_rsp_valid[0])&&
      (rsp_phase!==lease_phase||rsp_epoch!==lease_epoch||rsp_request_id!==lease_request_id||
       rsp_generation!==lease_generation||rsp_head!==lease_head))$fatal(1,"SHARED_RSP_LEASE_ID");
  end
 end
 always @(negedge clk)begin
  #0.1;
  if(!rst_n)begin if(dut.mul_leaf_ce!==1||dut.add_group[0].add_leaf_ce!==1)$fatal(1,"FP4_RESET_CE");end
  else begin
   if(dut.mul_leaf_ce!==(!((!dut.mul_fire)&&(dut.mul_inflight==0)&&(mul_pending==0)&&(dut.mul_leaf_valid==0))))$fatal(1,"FP4_MUL_CE_CONDITION");
   if(dut.add_group[0].add_leaf_ce!==(!((!dut.add_fire[0])&&(dut.add_inflight[0]==0)&&(add_pending[0]==0)&&(dut.add_leaf_valid==0))))$fatal(1,"FP4_ADD_CE_CONDITION");
   if(!dut.mul_leaf_ce)idle_m++;if(!dut.add_group[0].add_leaf_ce)idle_a++;
  end
 end
endmodule
