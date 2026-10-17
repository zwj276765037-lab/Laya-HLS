from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,difflib,xml.etree.ElementTree as ET
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
eng=get(B/'executor_program_runtime_inputs_structure_verification_20261013.json')
names=list(eng['attempts']);checks={};snaps=[];intervals=[]
for n in names:
 p=B/n;r=get(p/'receipt.json');m=get(p/'input_manifest.json');drift=[]
 assert r['status']==eng['attempts'][n]['status']
 for f in m['files']:
  assert valid(f['frozen']) and f['frozen']['sha256']==f['original']['sha256'] and f['frozen']['bytes']==f['original']['bytes']
  if not valid(f['original']):drift.append(f.get('relative',f['original']['path']))
 nr=0;cr=[]
 for obj in [m,r]:
  for k,x in refs(obj):
   if k.endswith('/original') or k.endswith('_original'):
    if not valid(x):cr.append({'key':k,'record':x})
    continue
   assert valid(x),(n,k,x);nr+=1
 guards=[]
 for gp in sorted(p.glob('guard_*/guard_result.json')):
  g=get(gp);plan=get(gp.parent/'guard_plan.json');polp=gp.parent/'policy_checks.json';pol=get(polp) if polp.exists() else []
  if n=='executor_hls_03' and gp.parent.name=='guard_hls':
   assert g['child_exit_code']==-9 and g['trigger']=='semantic_stall'
  else:assert g['child_exit_code']==0 and g['trigger'] is None
  assert plan['semantic_stall_seconds']==120 and plan['maximum_seconds']<=1800 and plan['maximum_owned_rss_kb']<=24*1024*1024
  assert g['minimum_mem_available_kb']>192*1024*1024
  assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
  guards.append({'name':gp.parent.name,'result':g,'policy_samples':len(pol),'plan':plan})
  lp=gp.parent/'launch.json';intervals.append({'attempt':n,'guard':gp.parent.name,'start':get(lp)['at'],'end':g['finished_at']})
  snaps.extend([gp,gp.parent/'guard_plan.json',lp])
  if polp.exists():snaps.append(polp)
 checks[n]={'status':r['status'],'frozen_pairs':len(m['files']),'current_drift':drift,'declared_current_reference_drift':cr,'nonoriginal_references_verified':nr,'guards':guards}
 snaps.extend([p/'receipt.json',p/'input_manifest.json'])
 # Functional markers are checked against recorded raw files, not exit code alone.
 for section in ['operations','phases']:
  for key,op in r.get(section,{}).items():
   markers=op.get('markers',[])+op.get('observations',[])
   if not markers:continue
   logs=[Path(x['path']) for _,x in refs(op) if Path(x['path']).name=='driver.log']
   assert logs,(n,key)
   body='\n'.join(x.read_text() for x in dict.fromkeys(logs))
   assert all(s in body for s in markers),(n,key)
   snaps.extend(logs)
intervals.sort(key=lambda x:x['start']);assert all(a['end']<=b['start'] for a,b in zip(intervals,intervals[1:]))

# Actual generation ports and candidate-only resource report.
p=B/'graph_program_owned_hls_06';rec=get(p/'receipt.json');pe=rec['port_evidence'];assert pe['pass'] and pe['fifo_count']==8 and pe['fifo_signal_count']==24
top=Path(pe['generated']['path']);sv=top.read_text();ports=[]
for group in list(pe['fifos'].values())+[pe['scalars']]:
 for spec in group.values():
  assert spec['pass'] and len(spec['actual'])==1
  name=spec['actual'][0];m=re.search(r'^\s*(input|output)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'+re.escape(name)+r'\s*;',sv,re.M);assert m,name
  width=int(m.group(2))-int(m.group(3))+1 if m.group(2) else 1
  assert width==spec['expected_width'] and m.group(1)==spec['expected_direction'];ports.append({'name':name,'width':width,'direction':m.group(1)})
mod=next(x for x in rec['resource_evidence']['modules'] if x['module']=='laya_graph_program_owned_sequencer')
xml=ET.parse(mod['file']['path']);res={x.tag:int(x.text) for x in xml.find('.//AreaEstimates/Resources')};assert all(res[k]==int(v) for k,v in mod['estimated_resources'].items())
checks[p.name].update({'verified_ports':ports,'candidate_HLS_estimate':res});snaps.extend([top,Path(mod['file']['path']),Path(rec['hls']['driver_log']['path'])])

# Independent generated validator: preserve every known bit; padding only.
p=B/'owned_bootstrap_validator_rtl_01';m=get(p/'input_manifest.json');r=get(p/'receipt.json');a=m['source_audit'];expected=m['expected'];assert len(expected)==15
positive=Path(next(x for x in expected if x['case']=='valid')['message']['path']).read_bytes();assert len(positive)==768
padding={i for lo,hi in a['padding_byte_ranges_half_open'] for i in range(lo,hi)};assert len(padding)==49
unknown=set()
for k,w in a['message_words'].items():
 for j in range(64):
  byte=w[len(w)-2*(j+1):len(w)-2*j];off=int(k)*64+j
  if 'x' in byte.lower():assert off in padding;unknown.add(off)
  for nibble,shift in [(byte[0],4),(byte[1],0)]:
   if nibble.lower()!='x':assert (positive[off]>>shift)&15==int(nibble,16)
   else:assert (positive[off]>>shift)&15==0
assert unknown==padding and a['known_bits_changed']==0 and a['unknown_bit_count']==392
assert set(map(int,a['semantic_wire_spans']))==set(range(768))-padding
assert a['semantic_bytes_compared']==719 and a['model_bytes_compared']==416
for e in expected:
 op=r['operations'][e['case']];assert op['status']=='PASS'
 observations=op['observations'];done=next(x for x in observations if '_DONE ' in x)
 result=int(re.search(r'return=(\d+)',done).group(1))
 assert (result==0)==(e['case']=='valid')
checks[p.name].update({'actual_positive_and_14_negative':True,'known_bits_unchanged':True,'padding_bytes':49,'padding_invariance':'NOT_RUN'})

# Top witnesses follow real start and cover each full compare before echo.
p=B/'graph_program_owned_rtl_05';r=get(p/'receipt.json');facts={}
events=['owner_read','owner_decode_start','nested_start','geometry_complete','copy416_last','build_l13m_start','build_l13m_done','canonical416_last','validate_l13m_start','validate_l13m_done','nested_done','outer_binding_packet_start','outer_binding_packet_done','outer_encode_complete','canonical1024_last','owner_decode_done','owner_echo_write']
for case in ['success','cancel-command-prefix','cancel-allocated','stale-completion']:
 op=r['operations'][case];assert op['status']=='PASS'
 raw=p/('guard_'+case)/'driver.log';body=raw.read_text();assert 'Fatal:' not in body
 rows=[dict(re.findall(r'(\w+)=([^ ]+)',line)) for line in body.splitlines() if line.startswith('FULL_CURRENT_OWNED_OWNER_WITNESS ')]
 assert [x['event'] for x in rows]==events
 assert all(int(x['cycle'])<=int(y['cycle']) for x,y in zip(rows,rows[1:]))
 last=rows[-1];assert last['copy']=='416' and last['model_cmp']=='416' and last['packet_cmp']=='1024' and last['cycle']=='20816'
 assert 'FULL_CURRENT_OWNED_OWNER_SCALARS purpose=1 content=1' in body
 facts[case]={'witnesses':rows,'marker':op['markers']};snaps.append(raw)
checks[p.name]['actual_execution_witnesses']=facts
rel=Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_graph_program_owned_tb_v1.sv')
old=B/'graph_program_owned_rtl_04/frozen'/rel;new=p/'frozen'/rel
checks[p.name]['monitor_diff']=''.join(difflib.unified_diff(old.read_text().splitlines(True),new.read_text().splitlines(True)))
snaps.extend([old,new,B/'graph_program_owned_rtl_04/guard_success/driver.log'])
assert 'Time: 145 ns' in (B/'graph_program_owned_rtl_04/guard_success/driver.log').read_text()

# New executor candidate is a three-file body-preserving change.
old=B/'executor_hls_host_06/frozen';new=B/'executor_hls_host_07/frozen';diffs=[]
for rel in ['hls/control/executor_stream.cpp','hls/control/executor_hls.cpp','include/laya_executor_stream.h']:
 x=old/rel;y=new/rel;diffs.append({'relative':rel,'diff':''.join(difflib.unified_diff(x.read_text().splitlines(True),y.read_text().splitlines(True)))})
 snaps.extend([x,y])
x=(old/'hls/control/executor_stream.cpp').read_text();y=(new/'hls/control/executor_stream.cpp').read_text()
start='#pragma HLS pipeline off\n';oldbody=x.split(start,1)[1].split('\n}\n',1)[0].replace('  executor::Inputs in = live;\n','')
newbody=y.split(start,1)[1].split('\n}\n',1)[0];assert oldbody==newbody
assert 'executor::Inputs scratch = live;' in y and 'step_in_place(actor, t, memory, scratch' in y
checks['executor_hls_host_07']['structural_diffs']=diffs;checks['executor_hls_host_07']['consumer_body_unchanged_except_removed_copy']=True
er=get(B/'executor_hls_03/receipt.json');assert er['status']=='COST_STOP' and not er['generated_candidates'] and er['port_evidence'] is None
snaps.extend([B/'executor_hls_03/guard_hls/driver.log',B/'executor_hls_03/work/hls/syn/report/csynth_design_size.rpt'])
p4=B/'executor_hls_04';mm=get(p4/'input_manifest.json');mh=get(B/'executor_hls_host_07/input_manifest.json')
assert {x['relative']:x['frozen']['sha256'] for x in mm['files']}=={x['relative']:x['frozen']['sha256'] for x in mh['files']}
for f in mm['files']:assert valid(f['frozen'])
checks['executor_hls_04_observed']={'at':datetime.now(timezone.utc).isoformat(),'receipt_status':get(p4/'receipt.json')['status'],'frozen_equal_host07':91,'generation_behavior_verdict':'NOT_REVIEWED'}
snaps.extend([p4/'receipt.json',p4/'input_manifest.json',R/'agent/A004/result.md',R/'agent/A006/result.md',R/'.research-agent/communications/executor-program-rtl-inputs-structure-progress-20261013.json'])
items=[]
for p in dict.fromkeys(snaps):
 out=D/'snapshot'/p.relative_to(R);out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(p.read_bytes());items.append({'source':str(p.relative_to(R)),'snapshot':str(out.relative_to(R)),'sha256':sha(out)})
v={'review':'R-SM003-PROGRAM-RTL-EXECUTOR-INPUTS-20261013','at':datetime.now(timezone.utc).isoformat(),'attempts':checks,'snapshots':items,'selected_guard_intervals_serial':intervals,'no_DUT_tools_run':True,'scope_limits':['managed adapter/LTP only finite host evidence, no complete cleanup acceptance','const/in_place differential test pending','A006 LLVM call graph/copy root cause not independently recomputed','actual executor/NORM/Q arithmetic NOT_RUN']}
vp=D/'verification.json';assert not vp.exists();vp.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
gs=[g for x in checks.values() for g in x.get('guards',[])]
print(json.dumps({'frozen_total':sum(x.get('frozen_pairs',0) for x in checks.values()),'references':sum(x.get('nonoriginal_references_verified',0) for x in checks.values()),'current_drift':{n:x['current_drift'] for n,x in checks.items() if 'current_drift' in x and x['current_drift']},'guards':len(gs),'policies':sum(g['policy_samples'] for g in gs),'no_RSS':sum(not g['result']['rss_captured'] for g in gs),'no_policy':sum(not g['policy_samples'] for g in gs),'snapshots':len(items),'verification_sha256':sha(vp)},ensure_ascii=False))
