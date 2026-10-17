from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re
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
checks={};snaps=[]
for n in ['graph_program_owned_hls_05','graph_program_owned_rtl_03','executor_hls_host_05']:
 p=B/n;r=get(p/'receipt.json');m=get(p/'input_manifest.json');drift=[]
 for f in m['files']:
  assert valid(f['frozen']) and f['frozen']['sha256']==f['original']['sha256'] and f['frozen']['bytes']==f['original']['bytes']
  if not valid(f['original']):drift.append(f['relative'])
 nr=0;current_ref_drift=[]
 for obj in [m,r]:
  for k,x in refs(obj):
   if k.endswith('/original') or k.endswith('_original'):
    if not valid(x):current_ref_drift.append({'key':k,'record':x})
    continue
   assert valid(x),(n,k,x)
   nr+=1
 guards=[]
 for gp in sorted(p.glob('guard_*/guard_result.json')):
  g=get(gp);plan=get(gp.parent/'guard_plan.json');polp=gp.parent/'policy_checks.json';pol=get(polp) if polp.exists() else []
  assert g['child_exit_code']==0 and g['trigger'] is None
  assert plan['semantic_stall_seconds']==120 and plan['maximum_seconds']<=1800
  assert plan['maximum_owned_rss_kb']<=24*1024*1024
  assert g['minimum_mem_available_kb']>192*1024*1024
  assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
  guards.append({'name':gp.parent.name,'result':g,'policy_samples':len(pol),'plan':plan})
  snaps.extend([gp,gp.parent/'guard_plan.json'])
  if polp.exists():snaps.append(polp)
 checks[n]={'status':r['status'],'frozen_pairs':len(m['files']),'current_drift':drift,'declared_current_reference_drift':current_ref_drift,'nonoriginal_references_verified':nr,'guards':guards}
 snaps.extend([p/'receipt.json',p/'input_manifest.json'])

p=B/'graph_program_owned_hls_05';r=get(p/'receipt.json');pe=r['port_evidence'];assert r['status']=='PASS_SCOPED_GENERATION'
assert pe['pass'] and pe['fifo_count']==8 and pe['fifo_signal_count']==24
top=Path(pe['generated']['path']);sv=top.read_text();ports=[]
for group in list(pe['fifos'].values())+[pe['scalars']]:
 for key,spec in group.items():
  assert spec['pass'] and len(spec['actual'])==1
  name=spec['actual'][0]
  m=re.search(r'^\s*(input|output)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'+re.escape(name)+r'\s*;',sv,re.M)
  assert m,name
  width=int(m.group(2))-int(m.group(3))+1 if m.group(2) else 1
  assert width==spec['expected_width'] and m.group(1)==spec['expected_direction']
  ports.append({'name':name,'width':width,'direction':m.group(1)})
checks['graph_program_owned_hls_05']['verified_ports']=ports
snaps.extend([top,Path(r['hls']['driver_log']['path'])])

rtl=B/'graph_program_owned_rtl_03';r=get(rtl/'receipt.json');assert r['status']=='FAIL'
assert r['operations']['static']['status']=='PASS' and r['operations']['success']['status']=='FAIL'
assert not any(x in r['operations'] for x in ['cancel-command-prefix','cancel-allocated','stale-completion'])
raw=rtl/'guard_success/driver.log';s=raw.read_text();assert 'Fatal: unexpected isolation case=success phase=1' in s and 'Time: 84645 ns' in s
checks['graph_program_owned_rtl_03']['actual_DUT_fatal']=True
checks['graph_program_owned_rtl_03']['remaining_three_cases']='NOT_RUN'
snaps.append(raw)

diag=B/'graph_program_owned_decode_diagnostic_03';dr=get(diag/'receipt.json');assert dr['status']=='OBSERVED'
log=diag/'guard_rtl/driver.log';s=log.read_text()
assert '/purpose 0001' in s and '/or_ln79_reg_9486 1' in s and dr['nested_validate_fields_return']==7
assert dr['canonical_equality']=='NOT_MEASURED'
line=next(l for l in s.splitlines() if l.startswith('OBS ') and '/m_U/ram[9] ' in l)
word=line.rsplit(' ',1)[1]
def bits(hi,lo):return int(word[-(hi//4+1):len(word)-lo//4 if lo else None],16)
assert bits(7,0)==0 and bits(199,192)==1 and bits(191,176)==1024
vp=p/'work/hls/syn/verilog/laya_graph_program_owned_sequencer_p_anonymous_namespace_validate_fields.v';vs=vp.read_text()
assert 'assign region_fu_8494_p1 = m_q0[7:0];' in vs
assert "assign icmp_ln79_4_fu_8907_p2 = ((region_fu_8494_p1 != 8'd1)" in vs
assert 'assign or_ln79_fu_8913_p2 = (icmp_ln79_fu_8901_p2 | icmp_ln79_4_fu_8907_p2);' in vs
checks['diagnostic03']={'status':'OBSERVED','nested_purpose':1,'validator_return':7,
 'ram9_region':bits(7,0),'ram9_content':bits(199,192),'ram9_width':bits(191,176),
 'RTL_content_comparator_reads_region':True,'canonical_equality':'NOT_MEASURED'}
snaps.extend([diag/'receipt.json',diag/'input_manifest.json',log,diag/'observe.tcl',vp,
 p/'frozen/hls/control/bootstrap_snapshot_protocol.cpp',
 R/'.research-agent/communications/executor-program-content-mapping-progress-20261013.json'])
h=get(B/'executor_hls_host_05/receipt.json');hostops={k:v for k,v in h['operations'].items() if k.startswith('host_') and k!='host_build'}
assert len(hostops)==7 and all(x['status']=='PASS' for x in hostops.values())
checks['executor_hls_host_05']['seven_host_cases']={k:v.get('markers') for k,v in hostops.items()}
for o in hostops.values():
 raw=Path(o['driver_log']['path']);assert all(marker in raw.read_text() for marker in o['markers']);snaps.append(raw)

items=[]
for p in dict.fromkeys(snaps):
 out=D/'snapshot'/p.relative_to(R);out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(p.read_bytes())
 items.append({'source':str(p.relative_to(R)),'snapshot':str(out.relative_to(R)),'sha256':sha(out)})
v={'review':'R-SM003-PROGRAM-CONTENT-MAPPING-20261013','at':datetime.now(timezone.utc).isoformat(),
 'attempts':checks,'snapshots':items,'no_DUT_tools_run':True,
 'not_recomputed':['Exact AMD pass/root cause','A004 full IR field-mapping audit','New content repair validation','Complete executor/arithmetic behavior']}
out=D/'verification.json';assert not out.exists();out.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'frozen_pairs':{n:x['frozen_pairs'] for n,x in checks.items() if 'frozen_pairs' in x},
 'current_drift':{n:x['current_drift'] for n,x in checks.items() if 'frozen_pairs' in x},
 'references':sum(x.get('nonoriginal_references_verified',0) for x in checks.values()),
 'snapshots':len(items),'verification_sha256':sha(out)},ensure_ascii=False))
