from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[3];SRC=Path(__file__).parent;A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
ports=json.loads((SRC/'resident_joint_v3_public_ports_v1.json').read_text())['ports'];s='`timescale 1ns/1ps\nmodule m007_type29_joint_tb;\n'
for di,dims,n in ports:s+=f' logic {dims} {n}'+("='0"if di=='input'else'')+';\n'
s+=' always #1 clk=~clk;\n laya_m007_resident_joint_v3 dut(.*);\n'
s+=r'''
 integer cycle=0,commits=0,checked=0,fd,type_setup_count=0,h_load_commits=0,q_load_commits=0,q_reads=0,type_reads=0,h_reads=0,switches=0;
 logic[31:0]N[0:131071],G[0:131071],T[0:3071];string np,gp,tp,pf;integer mode_arg,op_arg;
 task automatic tick;@(posedge clk);#0.01;endtask
 task automatic switch_to(input logic[1:0]t);
  @(negedge clk);owner_req=t;owner_req_valid=1;#0.001;begin int waited;waited=0;while(!owner_req_ready)begin @(negedge clk);#0.001;waited++;if(waited>128)$fatal(1,"OWNER_BLOCKED");end end
  tick();if(!rearm||owner!=t||{a_enable,g_enable,ln_enable,vector_enable}!=0||dut.joint.state_q!==0)$fatal(1,"REARM_FIRST");
  @(negedge clk);owner_req_valid=0;tick();if(rearm||dut.joint.state_q!==0)$fatal(1,"REARM_ONE_CYCLE");switches++;
 endtask
 task automatic load_hq(input bit with_q);
  for(int a=0;a<4096;a++)begin
   @(negedge clk);h_wr_valid=1;q_wr_valid=with_q;h_wr_addr=12'(a);q_wr_addr=12'(a);
   for(int l=0;l<32;l++)begin h_wr_data[l]=N[a*32+l];q_wr_data[l]=N[a*32+l];if(N[a*32+l][30:23]==255)$fatal(1,"H_LOAD_NONFINITE");end
   #0.001;if(!h_wr_ready||!h_wr_commit||(with_q&&(!q_wr_ready||!q_wr_commit)))$fatal(1,"PUBLIC_LOAD_COMMIT");tick();h_load_commits++;if(with_q)q_load_commits++;
   if(resident_ln_source_qualified)$fatal(1,"PUBLIC_WRITE_STALE_WITNESS");
  end
  @(negedge clk);h_wr_valid=0;q_wr_valid=0;tick();if(!h_bank_idle)$fatal(1,"LOAD_NOT_IDLE");
 endtask
 task automatic load_success;
  if(h_load_commits%4096||h_load_commits==0||!h_bank_idle)$fatal(1,"TB_ILLEGAL_LOAD_EVENT");
  @(negedge clk);h_load_success_valid=1;tick();@(negedge clk);h_load_success_valid=0;if(!resident_ln_source_qualified)$fatal(1,"ACTUAL_LOAD_WITNESS");
 endtask
 initial begin
  if(!$value$plusargs("MODE=%d",mode_arg)||!$value$plusargs("OP=%d",op_arg)||!$value$plusargs("Q=%s",np)||!$value$plusargs("GOLD=%s",gp)||!$value$plusargs("TYPE=%s",tp)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  if(op_arg!=1)$fatal(1,"JOINT_TYPE_ONLY");$readmemh(np,N);$readmemh(gp,G);$readmemh(tp,T);fd=$fopen(pf,"w");if(!fd)$fatal(1,"PROGRESS_OPEN");
  repeat(4)tick();@(negedge clk);rst_n=1;resident_owner_valid=1;resident_owner_request_id=64'h298765;resident_owner_generation=31;resident_owner_epoch=71;
  resident_access_request_id=resident_owner_request_id;resident_access_generation=resident_owner_generation;resident_access_epoch=resident_owner_epoch;parent_matrix_retired=1;parent_quant_retired=1;
  a_qkv_read_grant=7;a_ps_grant=1;a_g_grant=1;a_context_grant=1;a_fp_grant=1;a_sfu_grant=1;a_exp_grant=1;a_div_grant=1;a_rope_write_grant=1;
  type_qtype=2;type_model_committed=0;tick();
  for(int a=0;a<96;a++)begin
   @(negedge clk);type_wr_valid=1;type_wr_index=7'(a);for(int l=0;l<32;l++)begin type_wr_data[l]=T[a*32+l];if(T[a*32+l][30:23]==255)$fatal(1,"TYPE_SETUP_FINITE");end
   #0.001;if(!type_wr_ready||!type_wr_commit)$fatal(1,"TYPE_SETUP_NOT_READY");tick();type_setup_count++;
  end
  @(negedge clk);type_wr_valid=0;type_model_committed=1;type_wr_index=0;type_wr_valid=1;#0.001;if(type_wr_ready||!type_reject_valid)$fatal(1,"TYPE_COMMITTED_WRITE");tick();@(negedge clk);type_wr_valid=0;
  load_hq(0);
  // Wrong owner identity after a genuinely complete finite load must not publish.
  @(negedge clk);resident_access_generation++;h_load_success_valid=1;tick();if(resident_ln_source_qualified)$fatal(1,"WRONG_LOAD_IDENTITY");@(negedge clk);h_load_success_valid=0;resident_access_generation=resident_owner_generation;
  load_success();
  // Real next-BEGIN ownership invalidation clears the one existing witness.
  @(negedge clk);resident_owner_valid=0;tick();if(resident_ln_source_qualified)$fatal(1,"BEGIN_STALE_WITNESS");
  @(negedge clk);resident_owner_valid=1;resident_owner_generation++;resident_access_generation=resident_owner_generation;resident_owner_epoch++;resident_access_epoch=resident_owner_epoch;
  switch_to(3);@(negedge clk);scratch_lease_valid=1;#0.001;if(!scratch_lease_ready)$fatal(1,"SCRATCH_ADMISSION");tick();@(negedge clk);scratch_lease_valid=0;
  load_hq(1);load_success();resident_inputs_ready=1;
  vector_start_request_id=resident_owner_request_id;vector_start_generation=resident_owner_generation;vector_start_epoch=resident_owner_epoch;vector_start_op=1;
  @(negedge clk);type_qtype=3;vector_start_valid=1;#0.001;if(vector_start_ready||!vector_start_reject_valid)$fatal(1,"TYPE3_START");tick();@(negedge clk);vector_start_valid=0;type_qtype=2;
  vector_start_epoch++;vector_start_valid=1;#0.001;if(vector_start_ready||!vector_start_reject_valid)$fatal(1,"WRONG_START_EPOCH");tick();@(negedge clk);vector_start_valid=0;vector_start_epoch=resident_owner_epoch;
  vector_start_valid=1;owner_req_valid=1;owner_req=2;#0.001;if(!vector_start_ready||owner_req_ready)$fatal(1,"START_OWNER_RACE");tick();if(resident_ln_source_qualified)$fatal(1,"START_STALE_WITNESS");@(negedge clk);vector_start_valid=0;
  while(!vector_done_valid)begin tick();if(owner_req_ready||rearm)$fatal(1,"TYPE_EARLY_SWITCH");end
  if(vector_done_status||commits!=4096||vector_issued_vectors!=4096||vector_retired_vectors!=4096||dut.r_res_fp_lease_active||!type_bank_idle)$fatal(1,"TYPE_FINAL_REAL_DEBT");
  repeat(17)begin tick();if(!vector_done_valid||owner_req_ready||resident_ln_source_qualified)$fatal(1,"TYPE_HELD_DONE");end
  @(negedge clk);owner_req_valid=0;vector_done_ready=1;tick();@(negedge clk);vector_done_ready=0;if(!resident_ln_source_qualified)$fatal(1,"TYPE_SUCCESS_WITNESS");
  // One real H response is held17 while owner switch is requested.
  h_rd_addr=4095;h_rd_valid=1;h_rsp_ready=0;tick();@(negedge clk);h_rd_valid=0;owner_req_valid=1;owner_req=2;
  repeat(17)begin tick();if(!h_rsp_valid||h_rsp_addr!=4095||owner_req_ready||resident_bank_idle)$fatal(1,"H_HELD_OWNER_BARRIER");for(int l=0;l<32;l++)if(h_rsp_data[l]!==G[4095*32+l])$fatal(1,"H_ACTUAL_OUTPUT");end
  @(negedge clk);owner_req_valid=0;h_rsp_ready=1;tick();@(negedge clk);h_rsp_ready=0;switch_to(2);resident_ln_rows=16;#0.001;
  if(!resident_ln_source_qualified||!resident_ln_start_ready)$fatal(1,"LN_ACTUAL_SOURCE_ADMISSION witness=%b ready=%b enable=%b scratch=%b rows=%0d idle=%b",resident_ln_source_qualified,resident_ln_start_ready,ln_enable,scratch_owner_active,resident_ln_rows,dut.ln_provider.actual_idle);
  // Actual public H overwrite invalidates eligibility; no pseudo completion event.
  h_wr_valid=1;h_wr_addr=0;for(int l=0;l<32;l++)h_wr_data[l]=N[l];#0.001;if(!h_wr_ready||!h_wr_commit)$fatal(1,"PUBLIC_FINAL_WRITE");tick();@(negedge clk);h_wr_valid=0;if(resident_ln_source_qualified)$fatal(1,"PUBLIC_OVERWRITE_QUALIFIED");
  scratch_release_valid=1;#0.001;if(!scratch_release_ready)$fatal(1,"FINAL_SCRATCH_RELEASE");tick();@(negedge clk);scratch_release_valid=0;switch_to(0);
  if(!shared_resources_idle||!resident_bank_idle||!type_bank_idle||!ln_provider_idle||!a_layer_idle)$fatal(1,"FINAL_RETIRE");
  $fclose(fd);$display("HARDWARE_AGENT_SIM_PASS TYPE29_JOINT commits=%0d checked=%0d type_setup=%0d h_load_commits=%0d q_load_commits=%0d q_reads=%0d type_reads=%0d h_reads=%0d switches=%0d done_held=17 H_response_held=17 load_witness=1 type_witness=1 newgen=1 model_reused=1 type_control_bits=13 vector_control_bits=48",commits,checked,type_setup_count,h_load_commits,q_load_commits,q_reads,type_reads,h_reads,switches);$finish;
 end
 always@(posedge clk)begin
  cycle++;if(cycle>40000000)$fatal(1,"CYCLE_CAP");
  if(rst_n)begin
   if(vector_enable&&!vector_idle)begin
    if(dut.vector_h_rd_valid||dut.raw_h_rd_valid||dut.vector_h_rsp_ready)$fatal(1,"TYPE_H_READ");
    if(dut.vector_q_rd_valid&&dut.vector_q_rd_ready)q_reads++;
    if(dut.vector_type_rd_valid&&dut.vector_type_rd_ready)type_reads++;
    if(dut.vector_h_rd_valid&&dut.vector_h_rd_ready)h_reads++;
   end
   if(dut.vector_h_wr_valid&&dut.vector_h_wr_ready)begin
    if(!dut.vector_h_wr_commit||int'(dut.vector_h_wr_addr)!=commits)$fatal(1,"TYPE_H_COMMIT_ORDER");
    for(int l=0;l<32;l++)if(dut.vector_h_wr_data[l]!==G[commits*32+l])$fatal(1,"TYPE_BITS addr=%0d lane=%0d",commits,l);
    commits++;checked+=32;
    if(commits%128==0)begin $fdisplay(fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":0,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",checked,cycle,commits);$fflush(fd);end
   end
   if(dut.vector_fp_release_valid&&dut.vector_fp_release_ready&&commits!=4096)$fatal(1,"EARLY_FP_RELEASE");
   if(!vector_enable&&(dut.vector_type_rd_valid||dut.vector_type_rsp_ready))$fatal(1,"INACTIVE_TYPE_HANDSHAKE");
  end
 end
endmodule
'''
(A/'tb/m007_type29_joint_tb.sv').write_text(s);print('TYPE29 production475-port TB written')
