from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[3];A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
ports=json.loads((Path(__file__).parent/'joint_v2_port_manifest.json').read_text())['consumers']['vector']['ports']
s=(A/'tb/m007_resident21_tb.sv').read_text().replace('module m007_resident21_tb;','module m007_vector23_equivalence_tb;')
insert=' logic external_enable=1;logic[47:0]external_q=0,external_next,local_next;logic local_private_idle,external_private_idle;integer compared_cycles=0,retired_guard_cycles=0;bit equivalence_active=1;\n'
for pre in ['local','external']:
 for di,dims,n in ports:
  if di=='output'and n not in ['external_control_next','control_private_idle']:insert+=f' logic {dims} {pre}_{n};\n'
 mapping={'external_control_enable':"1'b1"if pre=='local'else'external_enable','external_control_q':"48'b0"if pre=='local'else'external_q','external_control_next':'local_next'if pre=='local'else'external_next','control_private_idle':pre+'_private_idle'}
 insert+=f' laya_m007_resident_vector32_v2 #(.EXTERNAL_CONTROL({0 if pre=="local"else 1})) {pre}_provider(\n'+',\n'.join(' .'+n+'('+mapping.get(n,pre+'_'+n if di=='output'else n)+')'for di,dims,n in ports)+'\n );\n'
insert+=' always@(posedge clk)begin if(!rst_n)external_q<=0;else if(external_enable)external_q<=external_next;end\n'
insert+=' always@(posedge clk)begin if(rst_n&&equivalence_active)begin\n'
for di,dims,n in ports:
 if di=='output'and n not in ['external_control_next','control_private_idle']:
  if n=='control_retired':insert+='  if(local_control_retired!==(control_retired&&!(start_valid&&start_ready))||local_control_retired!==external_control_retired)$fatal(1,"VECTOR_QUALIFIED_RETIRE_GUARD");\n'
  else:insert+=f'  if({n}!==local_{n}||{n}!==external_{n})$fatal(1,"VECTOR_EQ_{n}");\n'
insert+='  if(start_valid&&start_ready&&control_retired&&!local_control_retired)retired_guard_cycles++;if(local_private_idle!==external_private_idle)$fatal(1,"VECTOR_PRIVATE_IDLE_EQ");if(local_next!==external_next)$fatal(1,"VECTOR_EQ_NEXT");compared_cycles++;end end\n'
insert+=''' task automatic inactive_foreign_q;
  if(retired_guard_cycles==0)$fatal(1,"RETIRE_GUARD_NO_ACCEPT_WITNESS");\n  @(negedge clk);equivalence_active=0;external_enable=0;external_q='1;loaded=0;start_valid=1;
  repeat(3)begin step();if(external_start_ready||external_start_reject_valid||external_done_valid||external_idle||external_control_retired||external_h_rd_valid||external_q_rd_valid||external_h_wr_valid||external_fp_lease_valid||external_fp_release_valid||external_add_req_valid||external_add_rsp_ready||external_h_rsp_ready||external_q_rsp_ready||external_next!==external_q)$fatal(1,"VECTOR_INACTIVE_FOREIGN_Q");end
  $display("HARDWARE_AGENT_SIM_PASS VECTOR23_EQ compared_cycles=%0d retired_guard_cycles=%0d local_control_bits=48 external_shadow_bits=0 inactive_foreign_q=1",compared_cycles,retired_guard_cycles);
 endtask
'''
s=s.replace(' laya_m007_resident_vector32_v1 provider(.*);',' laya_m007_resident_vector32_v1 provider(.*);\n'+insert)
s=s.replace('$finish;','inactive_foreign_q();$finish;')
s=s.replace('if(commits%128==0)begin', 'if(commits%128==0||mode==4)begin')
# Exercise the final real bank-write/FP-return barrier for exactly17 held cycles.
s=s.replace('bit hold_started=0,hold_done=0;', 'bit hold_started=0,hold_done=0;integer final_hold_checked_cycles=0;')
s=s.replace('  wait(done_valid);@(negedge clk);', '  wait(done_valid);@(negedge clk);\n  if(mode==3&&(!hold_done||held_write_cycles!=17||final_hold_checked_cycles!=17))$fatal(1,"FINAL_WRITE_HOLD_COVERAGE");')
s=s.replace('   if(fp_protocol_fault)$fatal(1,"FP_PROTOCOL");', '''   if(fp_protocol_fault)$fatal(1,"FP_PROTOCOL");
   if(mode==3&&h_wr_valid&&h_wr_addr==4095&&!write_gate)begin
    final_hold_checked_cycles++;
    if(h_wr_ready||raw_h_commit||h_wr_commit||done_valid||fp_release_valid||control_retired||local_control_retired||external_control_retired||!fp_lease_active||!add_rsp_valid[0]||add_rsp_ready[0]||issued_vectors!=4096||retired_vectors!=4095)$fatal(1,"FINAL_WRITE_REAL_DEBT_BARRIER");
    for(int l=0;l<32;l++)if(h_wr_data[l]!==GOLD[4095*32+l])$fatal(1,"FINAL_WRITE_HELD_PAYLOAD");
   end''')
(A/'tb/m007_vector23_equivalence_tb.sv').write_text(s)
# Independent driver reuses the original fixture/checkers and real resources.
p=A/'tb/m007_resident21_run.py';t=p.read_text().replace('m007_resident21_tb.sv','m007_vector23_equivalence_tb.sv').replace('work.m007_resident21_tb','work.m007_vector23_equivalence_tb').replace('resident21_sim','vector23_equivalence_sim')
t=t.replace("'rtl/laya_m007_resident_vector32_v1.sv',", "'rtl/laya_m007_resident_vector32_v1.sv','rtl/laya_m007_resident_vector32_v2.sv',")
t=t.replace("save(o/'report.json',{'status':'PASS','scope':scope", "eq=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS VECTOR23_EQ '));assert 'inactive_foreign_q=1'in eq\n save(o/'report.json',{'status':'PASS','equivalence_marker':eq,'scope':scope")
t=t.replace("eq=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS VECTOR23_EQ '));assert 'inactive_foreign_q=1'in eq", "eq=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS VECTOR23_EQ '));eqm={k:int(val)for k,val in re.findall(r'(\\w+)=(\\d+)',eq)};assert eqm['inactive_foreign_q']==1 and eqm['retired_guard_cycles']>0 and eqm['compared_cycles']>4096 and eqm['local_control_bits']==48 and eqm['external_shadow_bits']==0\n if a.mode==3:assert v['external_write_held']==17")
t=t.replace("'equivalence_marker':eq,", "'equivalence_marker':eq,'equivalence_metrics':eqm,'retirement_semantics':'v2 local/external equal; v2_retired=v1_retired&&!start_accept; all other outputs bitwise equal each sampled edge',")
(A/'tb/m007_vector23_equivalence_run.py').write_text(t)
print('wrote equivalence TB and driver')
