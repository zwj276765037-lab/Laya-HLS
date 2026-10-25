from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
s=(M/'tb/m007_parent_fault_tb.sv').read_text().replace('module m007_parent_fault_tb;','module m007_parent_reset_tb;')
start=s.index(' task automatic error_then_recover;');end=s.index(' task automatic send_command;',start)
s=s[:start]+'''
 task automatic error_then_recover;
  begin
   mode=4;send_command();
   for(int g=0;g<4096;g++)begin in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=g/32;in_group=g%32;in_data=inputs[g];do @(posedge clk);while(!in_ready);@(negedge clk);end in_valid=0;
   wait(dut.r_res_fp_lease_active&&dut.r_res_fp_mul_pending!=0&&dut.r_res_fp_add_pending!=0&&dut.matrix.core.issue_count>=32);
   @(negedge clk);$display("M007_PARENT_COMMON_RESET_LIVE mul=%0d add=%h arithmetic=%0d PS_idle=%0d actual_inputs=%0d",dut.r_res_fp_mul_pending,dut.r_res_fp_add_pending,dut.m_arithmetic_debt,dut.r_res_st_idle,input_count);$fflush();
   rst_n=0;repeat(3)step();@(negedge clk);rst_n=1;
   repeat(40)begin step();if(done_valid||out_valid||dut.l_qkv_wr_valid||dut.r_res_fp_lease_active||dut.r_res_fp_mul_pending!=0||dut.r_res_fp_add_pending!=0||dut.r_res_div_lease_active||dut.r_res_div_pending_vectors||dut.matrix.a_slot_leased!=0||dut.matrix.w_slot_leased!=0)$fatal(1,"common reset old resource response isolation");end
   if(coeff_bound_valid||coeff_family_complete!=0)$fatal(1,"common reset inherited old coefficient coverage");
   @(negedge clk);coeff_bind_valid=1;do @(posedge clk);while(!coeff_bind_ready);@(negedge clk);coeff_bind_valid=0;
   for(int t=0;t<2;t++)for(int r=0;r<128;r++)for(int half=0;half<2;half++)begin coeff_wr_valid=1;coeff_wr_table=t;coeff_wr_row=r;coeff_wr_half=half;for(int c=0;c<32;c++)coeff_wr_data[c]=t?sf[r*64+half*32+c]:cf[r*64+half*32+c];#0.1;if(!coeff_wr_ready||coeff_wr_reject_valid)$fatal(1,"actual common-reset coefficient reload");@(posedge clk);@(negedge clk);end coeff_wr_valid=0;
   cmd_request=78;cmd_generation=9;cmd_epoch=10;mode=0;qkv_count=0;input_count=0;awrites=0;aacks=0;matrix_accepts=0;layer_starts=0;layer_prepares=0;ar_count=0;r_count=0;issue_owned=0;ps_owned=0;max_issue_ack=0;max_ps_feedback=0;
   for(int ss=0;ss<48;ss++)begin issues[ss]=0;acks[ss]=0;retired[ss]=0;first_issue[ss]=-1;last_issue[ss]=-1;end
   $display("M007_PARENT_COMMON_RESET_ISOLATION_PASS observed_clean_cycles=40 real_coefficient_reload=512 shared_functional_peer_common_reset=1 physical_HBM_reset_NOT_RUN=1");$fflush();
  end
 endtask
'''+s[end:]
s=s.replace('HARDWARE_AGENT_SIM_PASS M007_PARENT_ERROR_RECOVERY','HARDWARE_AGENT_SIM_PASS M007_PARENT_COMMON_RESET')
(M/'tb/m007_parent_reset_tb.sv').write_text(s)
print('M007_PARENT_RESET_TB_SOURCE_WRITTEN')
