#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
s=(M/'tb/m007_single_parent_tb.sv').read_text().replace('module m007_single_parent_tb;','module m007_parent_fault_tb;')
s=s.replace('integer nrope=0,', 'logic fault_injected=0;integer actual_faults=0,actual_prepare_cancels=0,actual_A_cancels=0;string fault_kind;\n integer nrope=0,')
s=s.replace('rresp[p]=0;end', "rresp[p]=0;if(mode==2&&!fault_injected&&baddr[p][pick]-cmd_base[0][p]>=64'd36864)begin rresp[p]=2;fault_injected=1;end end")
s=s.replace('cycle=cycle+1;last_r_fire<=rvalid&rready;', 'cycle=cycle+1;last_r_fire<=rvalid&rready;\n  if(rst_n)begin\n   if(dut.l_prepare_cancel_valid&&dut.l_prepare_cancel_ready)actual_prepare_cancels=actual_prepare_cancels+1;\n   if(dut.m_fill_cancel_valid&&dut.m_fill_cancel_ready)actual_A_cancels=actual_A_cancels+1;\n   for(int p=0;p<4;p++)if(rvalid[p]&&rready[p]&&rresp[p]!=0)actual_faults=actual_faults+1;\n  end')
s=s.replace('if(done_valid&&done_status!=0&&mode==0)', 'if(done_valid&&mode==0)')
s=s.replace('task automatic send_command;', '''task automatic error_then_recover;
  logic [242:0] held;
  begin
   mode=fault_kind=="w"?2:fault_kind=="close"?3:1;
   send_command();
   for(int g=0;g<4096;g++)begin
    in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=g/32;in_group=g%32;in_data=inputs[g];if(mode==1&&g==0)in_data[17]=32'h7fc00000;
    do @(posedge clk);while(!in_ready);@(negedge clk);
   end in_valid=0;
   if(mode==3)begin
    wait(dut.q_done_valid);@(negedge clk);
    if(!dut.q_done_valid||!dut.q_done_ready||parent_state!=3||dut.q_status!=0)$fatal(1,"legal same-edge producer failure trigger");
    producer_fail_valid=1;producer_fail_tuple=96'h123456789abcdef0fedcba98;producer_fail_request=cmd_request;producer_fail_generation=cmd_generation;producer_fail_epoch=cmd_epoch;
    #0.1;if(!producer_fail_ready)$fatal(1,"real producer failure not ready");
    @(posedge clk);if(!(dut.producer_fail_fire&&dut.q_done_valid&&dut.q_done_ready))$fatal(1,"actual same-edge producer-failure/done missing");@(negedge clk);producer_fail_valid=0;
   end
   wait(done_valid);@(negedge clk);
   if(layer_starts!=0||actual_prepare_cancels!=1||dut.r_res_fp_lease_active||dut.r_res_div_lease_active||!dut.r_res_st_idle||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0)$fatal(1,"parent failure drain/PREPcancel resources");
   if(mode==1&&(done_status!=1||source_status!=2||error_domain!=3||qkv_count!=0||ar_count!=0||error_tuple!={8'b0,16'd1,16'd0,16'd0,16'd17,24'b0}||dut.matrix.a_slot_valid[0]))$fatal(1,"actual quant NaN original error mapping");
   if(mode==2&&(done_status!=2||source_status!=3||error_domain!=4||actual_faults!=1||qkv_count==0))$fatal(1,"actual late W error and partial QKV");
   if(mode==3&&(done_status!=3||source_status!=3||error_domain!=2||error_tuple!=96'h123456789abcdef0fedcba98||actual_A_cancels!=1||qkv_count!=0||ar_count!=0||dut.matrix.a_slot_valid[0]))$fatal(1,"same-edge producer tuple and real published A cancellation");
   held={done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch};
   repeat(5)begin step();if(!done_valid||{done_status,source_status,error_domain,error_tuple,done_request,done_generation,done_epoch}!==held||cmd_ready)$fatal(1,"actual parent243bit failure hold");end
   $display("M007_PARENT_FAILURE_PASS kind=%s inputs=%0d public_QKV32=%0d actual_RRESP=%0d actual_PREPcancel=%0d actual_Acancel=%0d status=%0d raw_status=%0d domain=%0d tuple=%h no_reset=1",fault_kind,input_count,qkv_count,actual_faults,actual_prepare_cancels,actual_A_cancels,done_status,source_status,error_domain,error_tuple);$fflush();
   @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(cmd_ready);
   cmd_request=78;cmd_generation=9;cmd_epoch=10;
   mode=0;qkv_count=0;input_count=0;awrites=0;aacks=0;matrix_accepts=0;layer_starts=0;layer_prepares=0;ar_count=0;r_count=0;issue_owned=0;ps_owned=0;max_issue_ack=0;max_ps_feedback=0;
   for(int ss=0;ss<48;ss++)begin issues[ss]=0;acks[ss]=0;retired[ss]=0;first_issue[ss]=-1;last_issue[ss]=-1;end
  end
 endtask
 task automatic send_command;''')
s=s.replace('for(int field=0;field<8;field++)invalid_identity(field);\n  send_command();','for(int field=0;field<8;field++)invalid_identity(field);\n  if(!$value$plusargs("FAULT=%s",fault_kind))fault_kind="quant";\n  error_then_recover();\n  send_command();')
s=s.replace('$display("HARDWARE_AGENT_SIM_PASS M007_PARENT_QKV_PREFIX");', '$display("M007_PARENT_RECOVERY_PASS kind=%s generation=%0d epoch=%0d actual_reloaded_inputs=%0d actual_quant_Awrites=%0d public_QKV32=%0d no_reset=1",fault_kind,cmd_generation,cmd_epoch,input_count,awrites,qkv_count);$display("HARDWARE_AGENT_SIM_PASS M007_PARENT_ERROR_RECOVERY");')
(M/'tb/m007_parent_fault_tb.sv').write_text(s)
print('M007_PARENT_FAULT_TB_SOURCE_WRITTEN')
