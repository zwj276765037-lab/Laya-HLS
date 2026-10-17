#!/usr/bin/env python3
"""Emit a passive snapshot of real tile/canonical/exp sequential state."""
from pathlib import Path
import re,json,sys
a=Path(sys.argv[1]).resolve();modules={}
for p in (a/'rtl').glob('*.v'):
 for m in re.finditer(r'\bmodule\s+(\w+)\b[\s\S]*?\bendmodule\b',p.read_text()):modules[m[1]]=m[0]
state=[];gates=[]
def visit(mod,path,parents=()):
 if mod in parents:return
 s=modules[mod]
 for m in re.finditer(r'\breg\s+(?:signed\s+)?(?:\[[^\]]+\]\s*)?(\w+)\s*;',s):
  n=m[1]
  if re.search(r'\b'+re.escape(n)+r'\s*(?:\[[^\]]+\]\s*)?<=',s):state.append(path+'.'+n)
 if re.search(r'\bwire\s+aclken\b|\bassign\s+aclken\s*=',s):
  gates.append(path+'.aclken');state.extend([path+'.r_tdata',path+'.r_tvalid'])
 for child in modules:
  for m in re.finditer(r'\b'+re.escape(child)+r'\s+(?:#\s*\([\s\S]*?\)\s*)?(\w+)\s*\(',s):visit(child,path+'.'+m[1],(*parents,mod))
for n in range(16):
 visit('tanh_libm_stream_leaf_stream_mul_node_14_s',f'dut.pool[{n}].mul')
 visit('tanh_libm_stream_leaf_stream_add_node_0_s',f'dut.pool[{n}].add')
for n in range(4):
 visit('tanh_libm_stream_leaf_stream_div_node_0_s',f'dut.div_pool[{n}].div')
 visit('laya_attention_service_attention_exp_bits',f'dut.exp_pool[{n}].kernel')
state += ['dut.'+n for n in ['state','phase','bound_epoch','bind_count','S','query','row0','rows','head','nq','nk','nv','nmask','mq_wp','mq_rp','aq_wp','aq_rp','mv','av','dv','m_read_valid','a_read_valid','d_read_valid','qk_written','sm_row','scan_key','exp_key','exp_written','norm_key','norm_written','tree_issue','tree_commit','av_issue','av_committed','m_accept','a_accept','d_accept','exp_accept','exp_return','m_occupancy','a_occupancy']]
state += ['dut.'+n for n in ['sliding','result','status','selected_cmd','selected_index','err_valid','err_rank','err_element','group_row','group_key','qk_group','av_key','av_row','av_stripe','zero_index','max_pending','max_key','sm_level','sm_width','m_read_q','a_read_q','m_read_type','a_read_type','m_read_dot','a_read_dot','m_read_row','a_read_row','m_read_key','a_read_key','m_read_stripe','a_read_stripe','a_read_level','a_read_lanes','d_read_lanes','m_credit_stall','a_credit_stall','exp_hold_stall','av_busy_stall','m_peak','a_peak']]
for n in range(55):state.append(f'dut.binding[{n}]')
for n in range(1024):state.append(f'dut.mask[{n}]')
for n in range(8):state.extend([f'dut.scratch_valid[{n}]',f'dut.scratch_row[{n}]'])
for n in range(32):
 for k in ['mq_state','aq_state','mq_type','aq_type','mq_dot','aq_dot','mq_row','aq_row','mq_key','aq_key','mq_stripe','aq_stripe','aq_level','aq_lanes']:state.append(f'dut.{k}[{n}]')
 for j in range(16):state.extend([f'dut.mq_data[{n}][{j}]',f'dut.aq_data[{n}][{j}]'])
 for j in range(4):state.append(f'dut.aq_workers[{n}][{j}]')
for n in range(16):
 for k in ['dot_state','dot_level','dot_prod_issue','dot_prod_commit','dot_tree_issue','dot_tree_commit','dot_row','dot_key','dot_root','dot_scaled','dot_pad','dot_bias','dot_final','maximum','total','kd','vd','qd','yd','sd','pd','ed']:state.append(f'dut.{k}[{n}]')
 for k in ['m_direct_a','m_direct_b','a_direct_a','a_direct_b']:state.append(f'dut.{k}[{n}]')
 for j in range(4):state.append(f'dut.ybusy[{n}][{j}]')
for n in range(4):
 for k in ['worker_state','worker_launch','worker_x','worker_y','worker_key','dq_wp','dq_rp','d_read_q','d_read_key']:state.append(f'dut.{k}[{n}]')
 for j in range(32):
  for k in ['dq_state','dq_data','dq_row','dq_key']:state.append(f'dut.{k}[{n}][{j}]')
for n in range(14):state.append(f'dut.mtag[{n}]')
for n in range(6):state.append(f'dut.atag[{n}]')
for n in range(12):
 for j in range(4):state.append(f'dut.dtag[{n}][{j}]')
for n in range(32):state.append(f'dut.std[{n}]')
for l in range(7):
 for n in range(min(32,64>>l)):state.append(f'dut.td[{l}][{n}]')
state=list(dict.fromkeys(state))
text='localparam TILE_STATE_BITS = '+' + '.join('$bits('+x+')' for x in state)+';\n'
text+='function automatic [TILE_STATE_BITS-1:0] read_tile_state(); read_tile_state = {'+','.join(state)+'}; endfunction\n'
active=[f'(dut.worker_state[{n}]==2 && !dut.worker_launch[{n}] && !dut.exp_idle[{n}])' for n in range(4)]
text+='wire exp_native_advance = ap_ce && ('+' | '.join(active)+');\n'
(a/'frozen_source/attention_tile_state.svh').write_text(text)
(a/'state_manifest.json').write_text(json.dumps(dict(captured_state=state,actual_native_gates=gates,actual_exp_activity=active,exp_dependencies='Original F64 arithmetic is RTL; no native aclken instance occurs in this EXP closure'),indent=2)+'\n')
print('ATTENTION_SERVICE_TILE_STATE_PASS registers='+str(len(state)))
