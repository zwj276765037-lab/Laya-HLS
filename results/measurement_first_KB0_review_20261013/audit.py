from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,re
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E005_full_request_performance/experiment_results/runs/R001'
P=B/'attempts/AT001_KB0_resident_Down_measurement/evidence/measurement'
def get(p):return json.loads(p.read_text())
def sha(p):
 with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def valid(x):
 p=Path(x['path']);return p.is_file() and p.stat().st_size==x['bytes'] and sha(p)==x['sha256']
r=get(P/'receipt.json');m=get(P/'input_manifest.json');v=get(P/'measurement_full.json')
assert r['status']=='PASS_SCOPED_KB0_DOWN_MEASUREMENT' and m['label']=='KB0'
assert len(m['files'])==26 and len(m['fixture_files'])==12 and not m['baseline_live_sources_used']
changed=[]
for x in m['files']:
 assert valid(x['frozen']) and valid(x['baseline'])
 if x['frozen']['sha256']!=x['baseline']['sha256']:changed.append(x['frozen']['path'])
for x in m['fixture_files']:
 assert valid(x['frozen']) and valid(x['baseline']) and x['frozen']['sha256']==x['baseline']['sha256']
assert len(changed)==1 and changed[0].endswith('tm4tn8_matrix_resident_tb_v2.sv')
assert valid(r['input_manifest']) and all(valid(x) for x in r['native_ip'])
for n,p in r['phases'].items():
 assert p['status']=='PASS' and p['guard']['child_exit_code']==0 and p['guard']['trigger'] is None
 assert valid(p['driver_log'])
 body=Path(p['driver_log']['path']).read_text()
 assert all(x in body for x in p['marker']) and 'Fatal:' not in body
 for k in ['raw_log','measurement']:
  if k in p:assert valid(p[k])
assert r['phases']['pilot']['guard']['elapsed_seconds']<=120
assert r['phases']['full']['guard']['elapsed_seconds']<r['full_cost_estimate_before_launch']['estimate_seconds']<3600
raw=(P/'raw_full.log').read_text()
for name,label in [('boundaries','BOUNDARIES'),('states','STATES'),('overlap','OVERLAP'),('front','FRONT'),('load','LOAD'),('output','OUTPUT')]:
 line=next(x for x in raw.splitlines() if x.startswith('DOWN_MEASURE_'+label+' '))
 fields={k:(int(val) if re.fullmatch(r'-?\d+',val) else val) for k,val in re.findall(r'(\w+)=([^ ]+)',line)}
 assert fields==v[name],name
b=v['boundaries'];lat=v['latency_cycles'];out=v['output']
assert sum(v['state_cycles_exclusive'].values())==v['states']['cycles']==b['first_done_valid']-b['cfg_accept']==21100
assert b['actual_done_consume']-b['cfg_accept']==lat['cfg_to_actual_done_consume']==21107
assert b['actual_done_consume']-b['first_done_valid']==out['done_not_ready_edges']==7
assert b['finish']==48864 and b['W_publish_post_NBA']<b['cfg_accept']
assert out['actual_done_consumes']==1 and out['actual_AW']==out['actual_W']==out['actual_B']==512
assert out['useful_strobe_bytes']==16384 and out['physical_W_bytes']==32768 and v['strobe_utilization']==0.5
tb=Path(changed[0]).read_text()
for s in ['dut.commit_ps[r*256+:256]!==vps[seq][r*256+:256]','output_seen[idx+lane]','wd_data[lane*32+:32]!==outgold[idx+lane]','actual_ps_commits!=41984','actual_final_copies!=512','output_words!=4096','ledger_parent_publications!=1','!ledger_retire_debt_zero']:
 assert s in tb,s
guards=[];intervals=[]
for gp in sorted(P.glob('guard_*/guard_result.json')):
 g=get(gp);plan=get(gp.parent/'guard_plan.json');pol=get(gp.parent/'policy_checks.json')
 assert g['child_exit_code']==0 and g['trigger'] is None
 assert g['minimum_mem_available_kb']>192*1024*1024 and plan['semantic_stall_seconds']==120
 assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
 guards.append({'name':gp.parent.name,'result':g,'policy_samples':len(pol)})
 intervals.append({'name':gp.parent.name,'start':get(gp.parent/'launch.json')['at'],'end':g['finished_at']})
intervals.sort(key=lambda x:x['start']);assert all(a['end']<=b['start'] for a,b in zip(intervals,intervals[1:]))
a=get(B/'reports/KB1_rowpack_static_audit_20261013.json')
assert valid(a['baseline_source']) and valid(a['candidate_source'])
candidate=Path(a['candidate_source']['path']).read_text().splitlines(True);base=Path(a['baseline_source']['path']).read_text()
for block in a['byte_identical_blocks']:
 s=''.join(candidate[block['candidate_start_line']-1:block['candidate_end_line']])
 assert s in base and len(s.encode())==block['bytes'] and hashlib.sha256(s.encode()).hexdigest()==block['sha256']
assert a['logical_storage']['additional_pack_bits']==3*(1+64+64+512)==1923
paths=[P/'receipt.json',P/'input_manifest.json',P/'measurement_full.json',P/'raw_full.log',Path(changed[0]),B/'reports/KB0_Down_measurement_20261013.md',B/'reports/KB1_rowpack_static_audit_20261013.md',B/'reports/KB1_rowpack_static_audit_20261013.json',Path(a['candidate_source']['path']),R/'.research-agent/communications/measurement-first-KB0-result-KB1-plan-20261013.json']
paths.extend(P.glob('guard_*/guard_result.json'))
snaps=[]
for p in paths:
 q=D/'snapshot'/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes());snaps.append({'source':str(p.relative_to(R)),'snapshot':str(q.relative_to(R)),'sha256':sha(q)})
result={'review':'R-SM005-KB0-20261013','at':datetime.now(timezone.utc).isoformat(),'frozen_sources_verified':26,'unchanged_baseline_files':25,'changed_file':changed[0],'fixtures_verified':12,'native_IP_identities_verified':3,'measurement_matches_raw':True,'exclusive_state_sum':21100,'cfg_to_consume':21107,'guards':guards,'serial_intervals':intervals,'KB1_scope':'static source/unchanged authority blocks only; simulation and benefit NOT_REVIEWED','snapshots':snaps,'no_DUT_tools_run':True}
(D/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'frozen':26,'fixture':12,'cfg_to_done':21100,'cfg_to_consume':21107,'guards':len(guards),'policy_samples':sum(x['policy_samples'] for x in guards),'KB1':'static_only'},ensure_ascii=False))
