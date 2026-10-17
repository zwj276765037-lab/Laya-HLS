from pathlib import Path
from datetime import datetime, timezone
import json,hashlib,re
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
def get(p):return json.loads(p.read_text())
def sig(p):return {'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
verified={}
def check(x,actual=None):
 p=actual or Path(x['path']);s=sig(p)
 assert s['sha256']==x['sha256'] and ('bytes' not in x or s['bytes']==x['bytes']),str(p)
 verified[str(p)]=s
def refs(x):
 if isinstance(x,dict):
  if {'path','sha256'}<=x.keys():check(x)
  else:
   for k,v in x.items():
    if k not in ['original_source','candidate_source']:refs(v)
 elif isinstance(x,list):
  for v in x:refs(v)
facts=[];intervals=[];policies=0
for attempt,parent,ii,latency,slack,path_ns,state,fl,fs in [
 ('AT017_LQ1R_LN_hls_01','AT015_LQ1_LN_hls_01',9,9224,-0.43,5.298,7,3,5),
 ('AT018_LQ1R_LN_hls_02','AT017_LQ1R_LN_hls_01',10,10249,-0.41,5.277,8,4,6)]:
 p=B/attempt;q=B/parent;m=get(p/'input_manifest.json');r=get(p/'receipt.json');pm=get(q/'input_manifest.json')
 refs(m);refs(r);check(m['original_source'],q/'frozen/hls/operators/layernorm_compute.cpp')
 mm={str(Path(x['path']).relative_to(p/'frozen')):x for x in m['frozen_files']};qm={str(Path(x['path']).relative_to(q/'frozen')):x for x in pm['frozen_files']}
 assert len(mm)==len(qm)==31 and set(mm)==set(qm)
 assert [k for k in mm if mm[k]['sha256']!=qm[k]['sha256']]==['hls/operators/layernorm_compute.cpp']
 current=(p/'frozen/hls/operators/layernorm_compute.cpp').read_text();old=(q/'frozen/hls/operators/layernorm_compute.cpp').read_text()
 if fs==5:
  assert current.replace('#pragma HLS BIND_OP variable=delta op=fsub impl=fulldsp latency=4\n','').replace('#pragma HLS BIND_OP variable=norm op=fmul impl=maxdsp latency=3\n','')==old
 else:assert current.replace('variable=delta op=fsub impl=fulldsp latency=5','variable=delta op=fsub impl=fulldsp latency=4')==old
 assert r['status']=='PASS_SCOPED_GENERATION' and r['csim_run']['exit_code']==0
 sched=p/'work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt';flow=p/'work/hls/.autopilot/db/autopilot.flow.log'
 assert f'<State {state}>: {path_ns}ns' in sched.read_text()
 assert f'Final II = {ii}, Depth = {ii}' in flow.read_text()
 report=Path(r['report']['path']).read_text()
 assert any(str(slack) in l for l in report.splitlines() if '|+ laya_layernorm_producer_engine ' in l)
 assert any(str(latency) in l for l in report.splitlines() if 'o VITIS_LOOP_107_7 ' in l)
 for name,core in [(f'fsub_32ns_32ns_32_{fs}_full_dsp_1',fl),('fmul_32ns_32ns_32_4_max_dsp_1',2)]:
  ip=p/'work/hls/syn/verilog'/('laya_layernorm_producer_engine_'+name+'_ip.tcl')
  assert f'CONFIG.c_latency {core}' in ip.read_text() and 'CONFIG.has_aclken true' in ip.read_text()
 for f in [sched,flow]:verified[str(f)]=sig(f)
 g=get(p/'guard/guard_result.json');launch=get(p/'guard/launch.json');plan=get(p/'guard/guard_plan.json');pol=get(p/'guard/policy_checks.json')
 assert g==r['guard'] and g['child_exit_code']==0 and g['trigger'] is None
 assert g['elapsed_seconds']<plan['maximum_seconds'] and g['peak_owned_rss_kb']<plan['maximum_owned_rss_kb']
 assert g['minimum_mem_available_kb']>201326592 and plan['semantic_stall_seconds']==120
 assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
 intervals.append((launch['at'],g['finished_at']));policies+=len(pol)
 facts.append({'attempt':attempt,'frozen_sources':31,'actual_II':ii,'estimated_loop_cycles':latency,'slack_ns':slack,'path_ns':path_ns,'guard':g,'policy_count':len(pol),'RTL':'NOT_RUN'})
assert datetime.fromisoformat(intervals[0][1])<datetime.fromisoformat(intervals[1][0])
# Reuse the existing bounded Attention inventory; do not scan the old project.
invpath=R/'project/E005_full_request_performance/experiment_results/runs/R001/reports/attention_inventory_20261013.json'
inventory=get(invpath);check(inventory['source_identity'])
for key in ['source_checks','snapshot_checks','numeric_reference_checks']:
 for x in inventory[key]:check(x['mapped'])
assert len(inventory['source_checks'])==93 and len(inventory['snapshot_checks'])==81
att=R/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01'
nr=get(att/'head128_01/numeric_result.json');assert nr['status']=='PASS'
commands=[v for v in nr.values() if isinstance(v,list) and v and isinstance(v[0],dict) and {'cmd','normal_cycles'}<=v[0].keys()]
assert len(commands)==1
phases={c:sum(x['normal_cycles'] for x in commands[0] if x['cmd']==c) for c in [19,20,21]}
assert list(phases.values())==[250888,287173,66256]
out={'schema':'controller-LQ1R-terminal-and-next-entry-v1','at':datetime.now(timezone.utc).isoformat(),'DUT_tools_run':False,'LQ1R_verdict':'NO_GO_WITHIN_TWO_REPAIR_BOUND','repairs':facts,'serial':True,'policy_records':policies,'all_LQ1R_RTL_and_F9':'NOT_RUN','original_LQ0_LQ1_preserved':True,'Attention_entry':{'inventory':str(invpath),'inventory_sha256':sig(invpath)['sha256'],'source_files':93,'snapshot_files':81,'numeric_refs':len(inventory['numeric_reference_checks']),'source_manifest_sha256':inventory['source_identity']['sha256'],'historical_phases':inventory['phase_cycles'],'historical_normal_cycles':inventory['inherited_normal_cycles'],'historical_TB_cycles':inventory['tb_cycles'],'new_measurement':'NOT_RUN','reported_command_sums':phases},'unique_refs':len(verified),'verified_refs':verified}
(D/'verification.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k!='verified_refs'},ensure_ascii=False,indent=2))
