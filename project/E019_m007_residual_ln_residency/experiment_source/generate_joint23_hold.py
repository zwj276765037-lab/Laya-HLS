from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[3];A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
p=json.loads((Path(__file__).parent/'resident_joint_v2_public_ports_v1.json').read_text())['ports']
s='`timescale 1ns/1ps\nmodule m007_joint23_hold_tb;\n'
for di,dims,n in p:s+=f' logic {dims} {n}'+("='0"if di=='input'else'')+';\n'
s+=' always #1 clk=~clk;\n laya_m007_resident_joint_v2 dut(.*);\n'
s+=r'''
 integer cycles=0,checked=0,returned=0,fd;string pf;
 task automatic tick;@(posedge clk);#0.01;endtask
 task automatic progress;$fdisplay(fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":0,\"cycle\":%0d,\"phase\":5,\"returned\":%0d}",checked,cycles,returned);$fflush(fd);endtask
 initial begin
  if(!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");fd=$fopen(pf,"w");
  repeat(3)tick();@(negedge clk);rst_n=1;resident_owner_valid=1;resident_owner_request_id=31;resident_owner_generation=21;resident_owner_epoch=41;parent_matrix_retired=1;parent_quant_retired=1;tick();
  // Real phase1 shared ADD response held at the public external service boundary.
  @(negedge clk);ext_fp_select=1;ext_res_fp_lease_valid=1;ext_res_fp_lease_request_id=31;ext_res_fp_lease_generation=21;ext_res_fp_lease_epoch=41;ext_res_fp_lease_phase=1;
  #0.001;if(!ext_res_fp_lease_ready)$fatal(1,"FP_LEASE_NOT_READY");tick();@(negedge clk);ext_res_fp_lease_valid=0;
  ext_res_fp_add_req_valid=1;ext_res_fp_add_req_phase[0]=1;ext_res_fp_add_req_epoch[0]=41;ext_res_fp_add_req_tag[0]=96'h123456;
  for(int l=0;l<256;l++)begin ext_res_fp_add_a[l]=32'h3f800000;ext_res_fp_add_b[l]=32'h3f800000;end
  #0.001;if(!ext_res_fp_add_req_ready[0])$fatal(1,"ADD_NOT_READY");tick();@(negedge clk);ext_res_fp_add_req_valid=0;owner_req_valid=1;owner_req=3;
  ext_res_fp_release_valid=1;ext_res_fp_release_phase=1;ext_res_fp_release_epoch=41;ext_res_fp_phase_debt_clear=1;
  while(!ext_res_fp_add_rsp_valid[0])begin tick();if(owner_req_ready||ext_res_fp_release_ready||rearm)$fatal(1,"FP_INFLIGHT_SWITCH");end
  repeat(17)begin
   tick();if(!ext_res_fp_add_rsp_valid[0]||ext_res_fp_add_rsp_tag[0]!==96'h123456||ext_res_fp_add_pending==0||owner_req_ready||ext_res_fp_release_ready||rearm||!a_enable)$fatal(1,"FP_HELD17");
   for(int l=0;l<256;l++)if(ext_res_fp_add_rsp_data[l]!==32'h40000000)$fatal(1,"FP_HELD_DATA");
  end
  @(negedge clk);owner_req_valid=0;ext_res_fp_add_rsp_ready=1;tick();checked+=256;returned++;progress();@(negedge clk);ext_res_fp_add_rsp_ready=0;
  #0.001;while(!ext_res_fp_release_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ext_res_fp_release_valid=0;ext_res_fp_phase_debt_clear=0;ext_fp_select=0;
  if(ext_res_fp_lease_active||!shared_resources_idle)$fatal(1,"FP_NOT_RELEASED");
  // Real phase6 scalar DIV, held response prevents actual lease release/switch.
  ext_div_select=1;ext_res_div_lease_valid=1;ext_res_div_lease_request_id=31;ext_res_div_lease_generation=21;ext_res_div_lease_epoch=41;ext_res_div_lease_phase=6;
  #0.001;if(!ext_res_div_lease_ready)$fatal(1,"DIV_LEASE_NOT_READY");tick();@(negedge clk);ext_res_div_lease_valid=0;ext_res_div_req_valid=1;ext_res_div_req_generation=21;ext_res_div_req_epoch=41;ext_res_div_req_phase=6;ext_res_div_req_lane_mask=1;ext_res_div_req_tag=96'habcdef;ext_res_div_req_a[0]=32'h40800000;ext_res_div_req_b[0]=32'h40000000;
  #0.001;if(!ext_res_div_req_ready)$fatal(1,"DIV_NOT_READY");tick();@(negedge clk);ext_res_div_req_valid=0;owner_req_valid=1;owner_req=3;ext_res_div_release_valid=1;ext_res_div_release_phase=6;ext_res_div_release_epoch=41;ext_res_div_phase_debt_clear=1;
  while(!ext_res_div_rsp_valid)begin tick();if(owner_req_ready||ext_res_div_release_ready||rearm)$fatal(1,"DIV_INFLIGHT_SWITCH");end
  repeat(17)begin tick();if(!ext_res_div_rsp_valid||ext_res_div_rsp_tag!==96'habcdef||ext_res_div_rsp_data[0]!==32'h40000000||ext_res_div_rsp_numeric_error||ext_res_div_pending_vectors==0||owner_req_ready||ext_res_div_release_ready||rearm)$fatal(1,"DIV_HELD17");end
  @(negedge clk);owner_req_valid=0;ext_res_div_rsp_ready=1;tick();checked++;returned++;progress();@(negedge clk);ext_res_div_rsp_ready=0;
  #0.001;while(!ext_res_div_release_ready)begin @(negedge clk);#0.001;end
  tick();@(negedge clk);ext_res_div_release_valid=0;ext_res_div_phase_debt_clear=0;ext_div_select=0;
  if(ext_res_div_lease_active||!shared_resources_idle)$fatal(1,"DIV_NOT_RELEASED");
  owner_req_valid=1;owner_req=3;#0.001;if(!owner_req_ready)$fatal(1,"REAL_RELEASE_NO_SWITCH");tick();if(!rearm||a_enable||g_enable||ln_enable||vector_enable||dut.joint.state_q!==0)$fatal(1,"REARM");@(negedge clk);owner_req_valid=0;tick();if(rearm||!vector_enable)$fatal(1,"REARM_END");
  // Offer inputs to inactive consumers. Their public valid/ready path accepts none.
  @(negedge clk);a_prepare_valid=1;g_cmd_valid=1;ln_gamma_begin_valid=1;resident_ln_start_valid=1;resident_ln_rows=16;ext_res_fp_lease_valid=1;ext_res_div_lease_valid=1;
  repeat(3)begin tick();if(a_prepare_ready||g_cmd_ready||ln_gamma_begin_ready||resident_ln_start_ready||ext_res_fp_lease_ready||ext_res_div_lease_ready||dut.a_res_fp_lease_valid||dut.g_g_wr_valid||dut.ln_cmd_valid)$fatal(1,"INACTIVE_PUBLIC_ACCEPT");end
  $fclose(fd);$display("HARDWARE_AGENT_SIM_PASS JOINT23_HOLD checked=257 fp_held17=17 div_held17=17 real_release=2 inactive_zero_accept=1 arena_bits=12288");$finish;
 end
 always@(posedge clk)begin cycles++;if(cycles>1000)$fatal(1,"TIMEOUT");end
endmodule
'''
(A/'tb/m007_joint23_hold_tb.sv').write_text(s)
print('wrote hold TB')
