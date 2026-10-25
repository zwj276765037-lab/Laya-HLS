from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[3];SRC=Path(__file__).parent;A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
pub=json.loads((SRC/'resident_joint_v2_public_ports_v1.json').read_text())['ports']
old=A/'tb/m007_joint23_tb.sv';s=old.read_text();assert hashlib.sha256(s.encode()).hexdigest()=='185238e62bc373456283ea1e2075f23056b12623b13e0595728628ddda6f5693'
s=s.replace('module m007_joint23_tb;', 'module m007_joint27_tb #(parameter bit FORCE_CORE_CE=0);')
s=s.replace('laya_m007_resident_joint_v2 dut(.*);', 'laya_m007_resident_joint_v2 #(.TANH_FORCE_CORE_CE(FORCE_CORE_CE)) dut(.*);')
fields=[n for di,dims,n in pub if di=='output'and re.search(r'valid|ready|idle|active|pending|in_flight|commit|owner|rearm|enable|retired|issued|written',n)]
w=(A/'rtl/laya_m007_resident_joint_v2.sv').read_text();internals=[]
for dims,n in re.findall(r'^ logic (.*?) (\w+);$',w,re.M):
 if n.startswith('r_res_')and re.search(r'valid|ready|idle|active|draining|pending|in_flight',n):internals.append('dut.'+n)
fields+=internals+['dut.g_fp_req_valid','dut.g_fp_rsp_valid','dut.g_sfu_req_valid','dut.g_sfu_req_ready','dut.g_sfu_rsp_valid','dut.g_sfu_rsp_ready','dut.ln_in_ready','dut.ln_add_req_valid','dut.ln_div_req_valid','dut.vector_h_rd_valid','dut.vector_q_rd_valid','dut.vector_h_wr_valid','dut.p_q_wr_valid','dut.p_q_wr_ready','dut.p_q_wr_commit']
s=s.replace(' integer mode_arg=0,', ' integer trace_fd,ce0_cycles=0,ce1_cycles=0;string trace_path;\n integer mode_arg=0,',1)
s=s.replace(' initial begin\n', ' initial begin\n  $display("JOINT27_START force=%0d cycle=%0d",FORCE_CORE_CE,cycle);\n',1)
s=s.replace('  repeat(3)tick();', '''  if(!$value$plusargs("TRACE_FILE=%s",trace_path))$fatal(1,"TRACE_ARGS");
  trace_fd=$fopen(trace_path,"w");if(!trace_fd)$fatal(1,"TRACE_OPEN");
  if(dut.TANH_FORCE_CORE_CE!==FORCE_CORE_CE||dut.g_tanh.FORCE_CORE_CE!==FORCE_CORE_CE)$fatal(1,"ACTUAL_FORCE_CONFIG");
  repeat(3)tick();''',1)
s=s.replace('  if(rst_n)begin\n', '  if(rst_n)begin\n   $fdisplay(trace_fd,"%0d %h",cycle,{'+','.join(fields)+'});\n   if(dut.g_tanh.core_ce)ce1_cycles++;else ce0_cycles++;\n   if(g_tanh_lease_active&&!dut.g_tanh.core_ce)$fatal(1,"ACTIVE_TANH_CE_PAUSED");\n',1)
s=s.replace('  progress();$fclose(fd);$display(', '''  $display("JOINT27_CYCLES total=%0d vector_first=%0d vector_done=%0d ln_start=%0d ln_done=%0d rearm=%0d",cycle,vector_first_write,vector_done_cycle,ln_start_cycle,ln_done_cycle,rearm_cycles);
  $display("JOINT27_CE force=%0d ce0=%0d ce1=%0d",FORCE_CORE_CE,ce0_cycles,ce1_cycles);$fclose(trace_fd);
  progress();$fclose(fd);$display(''',1)
(A/'tb/m007_joint27_tb.sv').write_text(s)
(SRC/'joint27_functional_cycle_trace_v1.json').write_text(json.dumps({'schema':'m007-joint27-functional-cycle-trace-v1','signals':fields,'signal_count':len(fields),'meaning':'Each active clock edge records all public control/valid/ready/counters and actual sole resource service valid/ready/debt plus G/LN/VECTOR producer events; original independent per-value/node assertions remain unmodified','old_TB_sha256':hashlib.sha256(old.read_bytes()).hexdigest(),'new_TB_sha256':hashlib.sha256(s.encode()).hexdigest()},indent=2)+'\n')
print('new joint27 TB',len(fields),'trace signals')
