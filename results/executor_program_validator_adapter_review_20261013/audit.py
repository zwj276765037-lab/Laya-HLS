from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,difflib
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p):
 with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def get(p):return json.loads(p.read_text())
def valid(x):
 p=Path(x['path']);return p.is_file() and p.stat().st_size==x['bytes'] and sha(p)==x['sha256']
def refs(x,key=''):
 if isinstance(x,dict):
  if {'path','bytes','sha256'}<=x.keys():yield key,x
  else:
   for k,v in x.items():yield from refs(v,key+'/'+k)
 elif isinstance(x,list):
  for i,v in enumerate(x):yield from refs(v,key+'/'+str(i))
checks={};snaps=[];intervals=[]
for n in ['graph_program_owned_host_08','executor_adapter_lpv_generated_rtl_01']:
 p=B/n;r=get(p/'receipt.json');m=get(p/'input_manifest.json');drift=[]
 for f in m['files']:
  assert valid(f['frozen']) and f['frozen']['sha256']==f['original']['sha256'] and f['frozen']['bytes']==f['original']['bytes']
  if not valid(f['original']):drift.append(f.get('relative',f['original']['path']))
 nr=0;current_ref_drift=[]
 for obj in [m,r]:
  for k,x in refs(obj):
   if k.endswith('/original') or k.endswith('_original'):
    if not valid(x):current_ref_drift.append({'key':k,'record':x})
    continue
   assert valid(x),(n,k,x);nr+=1
 guards=[]
 for gp in sorted(p.glob('guard_*/guard_result.json')):
  g=get(gp);plan=get(gp.parent/'guard_plan.json');polp=gp.parent/'policy_checks.json';pol=get(polp) if polp.exists() else []
  assert g['child_exit_code']==0 and g['trigger'] is None
  assert plan['semantic_stall_seconds']==120 and plan['maximum_seconds']<=1800 and plan['maximum_owned_rss_kb']<=24*1024*1024
  assert g['minimum_mem_available_kb']>192*1024*1024
  assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
  guards.append({'name':gp.parent.name,'result':g,'policy_samples':len(pol),'plan':plan})
  lp=gp.parent/'launch.json';intervals.append({'attempt':n,'guard':gp.parent.name,'start':get(lp)['at'],'end':g['finished_at']})
  snaps.extend([gp,gp.parent/'guard_plan.json',lp])
  if polp.exists():snaps.append(polp)
 checks[n]={'status':r['status'],'frozen_pairs':len(m['files']),'current_drift':drift,'declared_current_reference_drift':current_ref_drift,'nonoriginal_references_verified':nr,'guards':guards}
 snaps.extend([p/'receipt.json',p/'input_manifest.json'])
intervals.sort(key=lambda x:x['start']);assert all(a['end']<=b['start'] for a,b in zip(intervals,intervals[1:]))

h=B/'graph_program_owned_host_08';r=get(h/'receipt.json');assert r['status']=='PASS_SCOPED_HOST'
ops={k:v for k,v in r['operations'].items() if k.startswith('host_') and k!='host_build'}
assert len(ops)==10
for name,o in ops.items():
 assert o['status']=='PASS' and o['guard']['child_exit_code']==0 and o['guard']['trigger'] is None
 raw=Path(o['driver_log']['path']);assert all(marker in raw.read_text() for marker in o['markers']);snaps.append(raw)
checks['graph_program_owned_host_08']['case_markers']={k:v['markers'] for k,v in ops.items()}
old=B/'graph_program_owned_host_07/frozen';new=h/'frozen'
diffs=[]
for rel in ['hls/control/bootstrap_snapshot_protocol.cpp','tests/graph_program_owned_test.cpp']:
 a=old/rel;c=new/rel
 diffs.append({'relative':rel,'diff':''.join(difflib.unified_diff(a.read_text().splitlines(True),c.read_text().splitlines(True)))})
 snaps.extend([a,c])
source=(new/'hls/control/bootstrap_snapshot_protocol.cpp').read_text()
assert 'return validate_fields(r, r.purpose, r.source.content);' in source
assert 'content != Content::F32' in source and 'd.target_region' in source
assert 'i < r.model_identity.size()' in source and '#pragma HLS unroll off' in source
assert 'model.identity[i] = r.model_identity[i];' in source
assert 'packet_equal(model.identity, r.model_identity)' in source
checks['graph_program_owned_host_08']['source_diffs_from_07']=diffs

# Check the original Message bytes without converting unknown padding to zeros.
dp=B/'graph_program_owned_decode_diagnostic_03/guard_rtl/driver.log'
owner=B/'graph_program_owned_rtl_03/fixture/owner.bin'
words={}
for line in dp.read_text().splitlines():
 if line.startswith('OBS ') and '/m_U/ram[' in line:
  k=int(re.search(r'/ram\[(\d+)\]',line).group(1));words[k]=line.rsplit(' ',1)[1]
model=[]
for j in range(416):
 a=152+j;w=words[a//64];offset=a%64;byte=w[len(w)-2*(offset+1):len(w)-2*offset]
 assert len(byte)==2 and 'x' not in byte.lower(),(j,byte)
 model.append(int(byte,16))
assert bytes(model)==owner.read_bytes()[160:576]
snaps.extend([dp,owner,R/'agent/A004/result.md'])

a=B/'executor_adapter_lpv_generated_rtl_01';r=get(a/'receipt.json');m=get(a/'input_manifest.json')
assert r['status']=='PASS_SCOPED_RTL_ACTUAL_GENERATED_ADAPTER_PORTAL' and len(r['cases'])==4
cycles=0;transactions=0;casefacts=[]
for key,c in r['cases'].items():
 assert c['status']=='PASS' and not c['simulator_exception_lines']
 raw=a/('guard_case_'+key)/'driver.log';body=raw.read_text()
 assert 'Fatal:' not in body and 'FATAL_ERROR:' not in body
 for marker in c['marker']+c['case_markers']+c['transaction_markers']:assert marker in body
 assert len(c['transaction_markers'])==len(m['case_transactions'][key])
 for marker in c['transaction_markers']:
  assert all(x in marker for x in ['actual_LTX=24','actual_LPV=16','actual_LPA=8','actual_LTC=16','caller_final_pop=1'])
 ncycles=int(re.search(r'cycles=(\d+)',c['marker'][0]).group(1));cycles+=ncycles;transactions+=len(c['transaction_markers'])
 casefacts.append({'case':key,'cycles':ncycles,'transactions':len(c['transaction_markers']),'markers':c['case_markers']})
 snaps.append(raw)
assert cycles==343711 and transactions==11
top=Path(m['port_evidence']['generated']['path']);sv=top.read_text();ports=[]
for name,spec in m['port_evidence']['declarations'].items():
 match=re.search(r'^\s*(input|output)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'+re.escape(name)+r'\s*;',sv,re.M)
 assert match,name
 width=int(match.group(2))-int(match.group(3))+1 if match.group(2) else 1
 assert width==spec['width'] and match.group(1)==spec['direction'];ports.append({'name':name,**spec})
checks['executor_adapter_lpv_generated_rtl_01'].update({'cases':casefacts,'total_cycles':cycles,'transactions':transactions,'top_ports_verified':ports,'known_gap':r['known_gap']})
tb=a/'frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_adapter_lpv_generated_tb_v1.sv'
snaps.extend([tb,top])

p6=B/'graph_program_owned_hls_06';m6=get(p6/'input_manifest.json');mh=get(h/'input_manifest.json')
map6={f['relative']:f['frozen']['sha256'] for f in m6['files']};maph={f['relative']:f['frozen']['sha256'] for f in mh['files']};assert map6==maph
for f in m6['files']:assert valid(f['frozen'])
checks['hls06_point_in_time']={'at':datetime.now(timezone.utc).isoformat(),'receipt_status':get(p6/'receipt.json')['status'],'frozen_equal_host08':399,'generation_behavior_verdict':'NOT_REVIEWED'}
snaps.extend([p6/'receipt.json',p6/'input_manifest.json',R/'.research-agent/communications/executor-program-validator-adapter-progress-20261013.json'])
items=[]
for p in dict.fromkeys(snaps):
 out=D/'snapshot'/p.relative_to(R);out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(p.read_bytes())
 items.append({'source':str(p.relative_to(R)),'snapshot':str(out.relative_to(R)),'sha256':sha(out)})
v={'review':'R-SM003-PROGRAM-VALIDATOR-ADAPTER-20261013','at':datetime.now(timezone.utc).isoformat(),'attempts':checks,
 'selected_guard_intervals_serial':intervals,'diagnostic03_model_message_to_independent_wire_equal_bytes':416,
 'snapshots':items,'no_DUT_tools_run':True,'not_recomputed':['A004 all416 LLVM store traces and exact AMD pass','HLS06 new generated behavior','Complete LN/executor/production lifecycle']}
out=D/'verification.json';assert not out.exists();out.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
guards=[g for x in checks.values() for g in x.get('guards',[])]
print(json.dumps({'frozen_pairs':{k:x['frozen_pairs'] for k,x in checks.items() if 'frozen_pairs' in x},'current_drift':{k:x['current_drift'] for k,x in checks.items() if 'frozen_pairs' in x},'references':sum(x.get('nonoriginal_references_verified',0) for x in checks.values()),'guards':len(guards),'policy_samples':sum(g['policy_samples'] for g in guards),'no_RSS':sum(not g['result']['rss_captured'] for g in guards),'no_policy':sum(not g['policy_samples'] for g in guards),'snapshots':len(items),'verification_sha256':sha(out)},ensure_ascii=False))
