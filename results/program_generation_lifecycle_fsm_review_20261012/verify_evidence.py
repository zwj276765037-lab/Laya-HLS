from pathlib import Path
import hashlib,json,shutil,difflib,re
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def read(p):return json.loads(Path(p).read_text())
def snap(p):
 target=OUT/'snapshot'/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True)
 if not target.exists():shutil.copyfile(p,target)
 assert sha(p)==sha(target)
 return {'path':str(target.relative_to(ROOT)),'sha256':sha(target)}
pairs=[];refs=[];snaps=[];attempts={};diffs=[]
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);refs.append({'origin':origin,'path':str(p),'expected':x['sha256'],'actual':sha(p) if p.is_file() else None,'match':p.is_file() and sha(p)==x['sha256']})
  for v in x.values():walk(v,origin)
 elif isinstance(x,list):
  for v in x:walk(v,origin)
for name in ['graph_program_hls_01','graph_program_rtl_01','task_lifecycle_fsm_host_02']:
 base=RUNS/name;m=read(base/'input_manifest.json');r=read(base/'receipt.json')
 for e in m['files']+([m['contract']] if 'contract' in m else []):
  a,b=e['original'],e['frozen'];pa,pb=Path(a['path']),Path(b['path'])
  row={'attempt':name,'path':a['path'],'current_match':sha(pa)==a['sha256'],'frozen_match':sha(pb)==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']};pairs.append(row)
  if not row['current_match']:
   target=OUT/'diff'/name/(pa.name+'.diff');target.parent.mkdir(parents=True,exist_ok=True)
   target.write_text(''.join(difflib.unified_diff(pb.read_text().splitlines(True),pa.read_text().splitlines(True),fromfile='frozen/'+pa.name,tofile='live/'+pa.name)))
   diffs.append(str(target.relative_to(ROOT)));snaps.extend([snap(pa),snap(pb)])
 for kind,data in [('manifest',m),('receipt',r)]:walk(data,name+'/'+kind)
 for fn in ['input_manifest.json','receipt.json','launcher.json','run.log','build.log','host_run.log']:
  if (base/fn).exists():snaps.append(snap(base/fn))
 guards=[]
 for gd in sorted(base.glob('guard*')):
  if not gd.is_dir():continue
  plan=read(gd/'guard_plan.json');result=read(gd/'guard_result.json');policy=read(gd/'policy_checks.json')
  policy_ok=bool(policy) and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
  budget_ok=result['elapsed_seconds']<=plan['maximum_seconds'] and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['minimum_mem_available_kb']>=plan['minimum_mem_available_kb']
  guards.append({'name':gd.name,'plan':plan,'result':result,'policy_rows':len(policy),'policy_ok':policy_ok,'budget_ok':budget_ok})
  for fn in ['guard_plan.json','guard_result.json','policy_checks.json','launch.json','driver.log']:snaps.append(snap(gd/fn))
 attempts[name]={'status':r['status'],'guards':guards,'launcher':read(base/'launcher.json'),'sources':m.get('source_list',m.get('lifecycle_sources')),'forbidden':m.get('forbidden_sources',m.get('forbidden_present',[]))}
 if name=='task_lifecycle_fsm_host_02':
  attempts[name]['commands']=[{k:v for k,v in c.items() if k!='command'} for c in r['commands']];attempts[name]['markers']=r['markers']
agg=RUNS/'program_generation_lifecycle_fsm_verification_20261012.json'
expected={agg:'dac277f992a762ee91dab222d02a271b38aa93f4349e524aa66fe7792cc96457'}
for name,x in read(agg)['attempts'].items():
 for e in x.values():expected[Path(e['path'])]=e['sha256']
hashes=[{'path':str(p.relative_to(ROOT)),'expected':h,'actual':sha(p),'match':sha(p)==h} for p,h in expected.items()]
for p in expected:
 if p.parent==RUNS:snaps.append(snap(p))
syn=RUNS/'graph_program_hls_01/work/hls/syn/verilog';top=syn/'laya_graph_program_sequencer.v'
body=top.read_text();header=re.search(r'module\s+laya_graph_program_sequencer\s*\((.*?)\)\s*;',body,re.S).group(1)
ports=set(re.findall(r'\b[A-Za-z_]\w*\b',header))
required={'ap_clk','ap_rst','cancel','result_consumed'}
for p,suffs in [('accepted_command',['dout','empty_n','read']),('request_result',['din','full_n','write']),('action_request',['din','full_n','write']),('action_completion',['dout','empty_n','read'])]:
 required.update(p+'_'+s for s in suffs)
top_evidence={'verilog':len(list(syn.glob('*.v'))),'dat':len(list(syn.glob('*.dat'))),'sha256':sha(top),'ports':sorted(ports),'exact_ports':ports==required,'copied_equal':sha(top)==sha(RUNS/'graph_program_hls_01/laya_graph_program_sequencer.v'),'rtl_frozen_equal':sha(top)==sha(RUNS/'graph_program_rtl_01/frozen/external/program_rtl/laya_graph_program_sequencer.v')}
rtl=read(RUNS/'graph_program_rtl_01/receipt.json');rom=rtl['rom_dat_staging']
rom_ok=all(sha(x['source']['path'])==sha(x['staged']['path'])==x['source']['sha256']==x['staged']['sha256'] for x in rom)
cost=rtl['cost_decision'];rate=cost['pilot_cycles']/rtl['pilot']['guard']['elapsed_seconds'];projection=cost['pilot_cycles']*4*1.5
cost_ok=abs(rate-cost['pilot_cycles_per_second'])<1e-6 and projection==cost['projected_cycles'] and abs(projection/rate-cost['projected_seconds'])<1e-6 and projection<=1000000 and projection/rate<=3600
prior=read(RUNS/'task_lifecycle_fsm_host_01/input_manifest.json');current=read(RUNS/'task_lifecycle_fsm_host_02/input_manifest.json')
old={e['relative']:e for e in prior['files']};new={e['relative']:e for e in current['files']}
changed=[f for f in old.keys()&new.keys() if old[f]['frozen']['sha256']!=new[f]['frozen']['sha256']]
for f in changed:
 target=OUT/'diff'/('fsm_01_02_'+Path(f).name+'.diff')
 target.write_text(''.join(difflib.unified_diff(Path(old[f]['frozen']['path']).read_text().splitlines(True),Path(new[f]['frozen']['path']).read_text().splitlines(True),fromfile='01/'+f,tofile='02/'+f)))
 diffs.append(str(target.relative_to(ROOT)))
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json']:snaps.append(snap(ROOT/f))
v={'review_id':'R-SM003-PROGRAM-GENERATION-LIFECYCLE-FSM-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snaps,'diffs':diffs,'summary':{'pairs':len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'handoff_hashes':hashes,'attempts':attempts,'top_evidence':top_evidence,'rom_staged_count':len(rom),'rom_equal':rom_ok,'cost':cost,'cost_recomputed_equal':cost_ok,'fsm_01_02_changed_common':changed,'decision_pending':True,'no_controller_compilation_simulation_hls':True}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'handoff_hashes_match':all(x['match'] for x in hashes),'top':top_evidence,'rom_ok':rom_ok,'cost_ok':cost_ok,'changed':changed,'mismatches':[(x['origin'],x['path']) for x in refs if not x['match']],'guards':[(n,g['name'],g['policy_ok'],g['budget_ok'],g['result']['child_exit_code'],g['result']['trigger']) for n,a in attempts.items() for g in a['guards']]},ensure_ascii=False,indent=2))

