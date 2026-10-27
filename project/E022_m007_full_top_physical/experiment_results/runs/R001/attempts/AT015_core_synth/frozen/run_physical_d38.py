#!/usr/bin/env python3
"""D38 full-top source freeze, checkpoint-resumable Vivado stages and owned guard."""
import argparse, ctypes, datetime as dt, fcntl, hashlib, json, os
from pathlib import Path
import shutil, signal, subprocess, sys, time

ROOT=Path(__file__).resolve().parents[7]
HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
EXPERIMENT=RUN.parents[2]
TOOLS=ROOT/'project/E002_Laya_HLS/experiment/tools'
sys.path.insert(0,str(TOOLS))
import hls_guard_helpers as owned
VIVADO=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado')
MANIFEST=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007/d36_final_gamma_suffix_source/rev2/fixed_source_manifest.json'
ORDER=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT001_fixed_original30_build/config.json'
CONTRACT=ROOT/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md'
CAPS={'preparation':1200,'repair_static':600,'repair_rtl':600,'synthesis':43200,'implementation':86400,'reports':3600}
STAGES={'preflight':('preparation',1200),'parameters':('preparation',1200),'synth':('synthesis',21600),'report_synth':('reports',3600),'opt':('implementation',14400),'place':('implementation',43200),'report_place':('reports',3600),'phys_opt':('implementation',14400),'route':('implementation',43200),'report_route':('reports',3600)}
PRIOR={'report_synth':'synth','opt':'synth','place':'opt','report_place':'place','phys_opt':'place','route':'phys_opt','report_route':'route'}
for name in ['core_synth','facade_synth','facade_link','resident_synth','parent_synth','full_link']:STAGES[name]=('synthesis',21600)
STAGES['report_full']=('reports',3600)
STAGES['report_core']=('reports',3600)
PRIOR['report_core']='core_synth'
STAGES['repair_static']=('repair_static',300)
STAGES['repair_rtl']=('repair_rtl',300)
DEPS={'facade_synth':['core_synth'],'facade_link':['facade_synth','core_synth'],'parent_synth':['facade_link','resident_synth'],'full_link':['parent_synth','facade_link','resident_synth'],'report_full':['full_link']}
PRIOR['opt']='full_link'
def now():return dt.datetime.now(dt.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,v):
 p.parent.mkdir(parents=True,exist_ok=True);tmp=p.with_suffix(p.suffix+'.tmp');tmp.write_text(json.dumps(v,indent=2)+'\n');os.replace(tmp,p)
def frozen(p,data):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_bytes()==data,str(p)
 else:p.write_bytes(data)
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def ledger():return json.loads((RUN/'budget_ledger.json').read_text())if(RUN/'budget_ledger.json').exists()else{'caps_seconds':CAPS,'entries':[]}
def charged(j,cat):return sum(x.get('elapsed_seconds',x['maximum_seconds'])for x in j['entries']if x['category']==cat)
def prepare():
 start=time.monotonic();assert 'D-M007-SM012-FULL-TOP-PHYSICAL-38'in CONTRACT.read_text()
 m=json.loads(MANIFEST.read_text());cfg=json.loads(ORDER.read_text());byname={Path(x['path']).name:x for x in m['compile_sources']};assert len(byname)==94
 excluded={'m007_fullgraph_binary_tb.sv','m007_binary_weight_peer_tb.sv','m007_public_f32_capture_tb_v2.sv'}
 assert {Path(x).name for x in cfg['sources']}==set(byname)
 rows=[]
 for original in map(Path,cfg['sources']):
  row=byname[original.name];assert sha(original)==row['sha256'],str(original)
  if original.name in excluded:continue
  p=RUN/'input/rtl'/original.name;frozen(p,original.read_bytes());rows.append({'original':identify(original),'frozen':identify(p),'D37_source':str(original),'D36_manifest_path':row['path']})
 assert len(rows)==91
 parent=next(x for x in rows if Path(x['frozen']['path']).name=='laya_m007_single_parent_v3.sv');assert parent['frozen']['sha256']=='9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6'
 rom=[]
 for x in m['ROM_initialization_files']:
  p=ROOT/x['path'];assert sha(p)==x['sha256'];f=RUN/'input/rom'/p.name;frozen(f,p.read_bytes());rom.append({'original':identify(p),'frozen':identify(f)})
 sources='set production_sources [list \\\n'+''.join(' {'+x['frozen']['path']+'} \\\n'for x in rows)+']\n'
 frozen(RUN/'input/sources.tcl',sources.encode())
 result={'schema':'m007-d38-full-production-source-v1','production_source_count':91,'excluded_simulation_sources':sorted(excluded),'top':'laya_m007_single_parent_v3','parameters':{'VERIFY_POST_ENCODER27_H':0},'part':'xcu55c-fsvh2892-2L-e','clock_period_ns':3.333333333,'D36_fixed_manifest':identify(MANIFEST),'D37_order_config':identify(ORDER),'sources':rows,'ROM':rom,'no_constant_tieoff':True,'no_replacement_IP':True,'no_shell':True}
 path=RUN/'input/source_manifest.json';frozen(path,(json.dumps(result,indent=2)+'\n').encode())
 if not(RUN/'preparation_receipt.json').exists():
  rec={'category':'preparation','status':'PASS_SOURCE_FREEZE_ONLY','elapsed_seconds':time.monotonic()-start,'at':now(),'source_manifest':identify(path),'no_Vivado_executed':True};dump(RUN/'preparation_receipt.json',rec);j=ledger();j['entries'].append({'stage':'source_freeze','category':'preparation','maximum_seconds':600,'elapsed_seconds':rec['elapsed_seconds'],'status':'complete','receipt':str(RUN/'preparation_receipt.json')});dump(RUN/'budget_ledger.json',j)
 return result
def active_paths():
 p=RUN/'input/active_source_version.json'
 return json.loads(p.read_text())if p.exists()else {'manifest':'source_manifest.json','sources':'sources.tcl','bottom_configuration':'bottom_up_configuration_v4.json','bottom_flow':'bottom_up_flow_v4.tcl'}
def repair_path():
 p=RUN/'input/active_repair_version.json'
 return RUN/json.loads(p.read_text())['directory']if p.exists()else RUN/'repair'
def verify_inputs(stage=None):
 if stage in {'repair_static','repair_rtl'}:
  m=repair_path()/'repair_manifest.json';v=json.loads(m.read_text())
  for row in v['files']:assert sha(Path(row['path']))==row['sha256'],row['path']
  return {'repair_manifest_sha256':sha(m),'repair_inputs':v['files'],'xdc_sha256':sha(HERE/'full_top_d38.xdc'),'physical_configuration_sha256':sha(RUN/'input/physical_configuration_v2.json'),'generics_tcl_sha256':sha(RUN/'input/physical_generics_v2.tcl')}
 active=active_paths();p=RUN/'input'/active['manifest'];m=json.loads(p.read_text())
 for row in m['sources']:
  for k in ['original','frozen']:assert sha(Path(row[k]['path']))==row[k]['sha256'],row[k]['path']
 for row in m['ROM']:
  for k in ['original','frozen']:assert sha(Path(row[k]['path']))==row[k]['sha256'],row[k]['path']
 config=RUN/'input/physical_configuration_v2.json';v=json.loads(config.read_text());generics=RUN/'input/physical_generics_v2.tcl'
 assert generics.read_text()=='set production_generics [list '+' '.join('{'+k+'='+value+'}'for k,value in v['generics'].items())+']\n','Physical generic Tcl/JSON differ'
 result={'manifest_sha256':sha(p),'physical_configuration_sha256':sha(config),'generics_tcl_sha256':sha(generics),'xdc_sha256':sha(HERE/'full_top_d38.xdc'),'top':m['top'],'parameters':v['generics'],'part':m['part']}
 flow=RUN/'input'/active['bottom_configuration']
 if flow.exists():
  b=json.loads(flow.read_text());assert b['production_manifest_sha256']==sha(p)and b['parent_configuration_v2_sha256']==sha(config)
  for item in b['stubs']:assert sha(Path(item['source']))==item['source_sha256']and sha(Path(item['stub']))==item['stub_sha256']
  result.update({'bottom_up_configuration_sha256':sha(flow),'bottom_up_tcl_sha256':sha(RUN/'input'/active['bottom_flow']),'stub_sha256':{x['module']:x['stub_sha256']for x in b['stubs']}})
 return result
def checkpoint_identity_match(meta,identity,dep):
 old=meta['source_identity']
 if old==identity:return None
 # Only the already-running v3 core may cross a future-stub metadata revision.
 assert dep=='core_synth','DCP identity differs'
 keys={'bottom_up_configuration_sha256','bottom_up_tcl_sha256','stub_sha256'}
 assert {k:v for k,v in old.items()if k not in keys}=={k:v for k,v in identity.items()if k not in keys}
 actual=Path(meta['produced_by'])/'frozen/bottom_up_configuration_v3.json';assert sha(actual)==old['bottom_up_configuration_sha256']
 before=json.loads(actual.read_text());after=json.loads((RUN/'input/bottom_up_configuration_v4.json').read_text())
 assert before['stages'][dep]==after['stages'][dep]and not before['stages'][dep]['stub_modules']
 assert before['flatten_hierarchy']==after['flatten_hierarchy']=='none'
 assert before['synthesis_maxThreads']==after['synthesis_maxThreads']==1
 return {'checkpoint':meta['checkpoint'],'scope':'v3 core only; no stubs used; unchanged actual core top/PROFILE0/source closure/ROM/part/XDC/flatten none','old_frozen_configuration':identify(actual),'new_configuration':identify(RUN/'input/bottom_up_configuration_v4.json'),'matched_core_spec':after['stages'][dep],'base_source_and_parameter_identity_equal':True}
def proc_cpu(pid):
 try:
  s=Path(f'/proc/{pid}/stat').read_text();x=s[s.rfind(')')+2:].split();return int(x[11])+int(x[12])
 except (FileNotFoundError,ProcessLookupError,IndexError,ValueError):return 0
def reap():
 while True:
  try:
   pid,_=os.waitpid(-1,os.WNOHANG)
   if not pid:return
  except ChildProcessError:return
def rss_limit_gib(stage):
 return 8 if STAGES[stage][0]=='repair_rtl'else 24 if STAGES[stage][0]=='repair_static'else 128
def run_stage(stage):
 RUN.mkdir(parents=True,exist_ok=True)
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  identity=verify_inputs(stage);j=ledger();cat,limit=STAGES[stage];limit=min(limit,CAPS[cat]-charged(j,cat));assert limit>0,'D38 category budget exhausted'
  rss_cap=rss_limit_gib(stage)
  dependencies=DEPS.get(stage,[PRIOR[stage]]if stage in PRIOR else [])
  compatibility=[]
  for dep in dependencies:
   cp=RUN/'checkpoints'/(dep+'.dcp');meta=json.loads(cp.with_suffix('.identity.json').read_text());assert sha(cp)==meta['checkpoint']['sha256'],'DCP byte identity differs';proof=checkpoint_identity_match(meta,identity,dep)
   if proof:compatibility.append(proof)
  outputs=['synth','opt','place','phys_opt','route','core_synth','facade_synth','facade_link','resident_synth','parent_synth','full_link']
  if stage in outputs:assert not(RUN/'checkpoints'/(stage+'.dcp')).exists(),'Existing DCP must be resumed, never overwritten'
  ats=RUN/'attempts';ats.mkdir(exist_ok=True);numbers=[int(p.name[2:5])for p in ats.iterdir()if p.name.startswith('AT')];at=ats/f'AT{max(numbers,default=0)+1:03d}_{stage}';at.mkdir();work=at/'work';work.mkdir();(at/'frozen').mkdir()
  for p in [Path(__file__),HERE/'full_top_d38.tcl',HERE/'full_top_d38.xdc',RUN/'input/physical_configuration_v2.json',RUN/'input/physical_generics_v2.tcl']:(at/'frozen'/p.name).write_bytes(p.read_bytes())
  if stage not in {'repair_static','repair_rtl'}:
   active=active_paths()
   for key,dest in [('manifest','source_manifest.json'),('sources','sources.tcl'),('bottom_configuration','bottom_up_configuration.json'),('bottom_flow','bottom_up_flow.tcl')]:shutil.copyfile(RUN/'input'/active[key],at/'frozen'/dest)
   shutil.copyfile(HERE/'prepare_bottom_up_d38.py',at/'frozen/prepare_bottom_up_d38.py')
   assert sha(at/'frozen/bottom_up_configuration.json')==identity['bottom_up_configuration_sha256']and sha(at/'frozen/bottom_up_flow.tcl')==identity['bottom_up_tcl_sha256']
  shutil.copyfile(CONTRACT,at/'frozen/contract_SM012.md');shutil.copyfile(ROOT/'AGENTS.md',at/'frozen/project_AGENTS.md')
  if compatibility:dump(at/'checkpoint_configuration_compatibility.json',compatibility)
  assert sha(at/'frozen/full_top_d38.xdc')==identity['xdc_sha256'],'Frozen XDC identity mismatch before launch'
  assert sha(at/'frozen/physical_configuration_v2.json')==identity['physical_configuration_sha256']
  assert sha(at/'frozen/physical_generics_v2.tcl')==identity['generics_tcl_sha256']
  m=json.loads((RUN/'input'/active_paths()['manifest']).read_text())
  for row in m['ROM']:shutil.copyfile(row['frozen']['path'],work/Path(row['frozen']['path']).name)
  if stage in {'repair_static','repair_rtl'}:
   for row in json.loads((repair_path()/'repair_manifest.json').read_text())['files']:
    source=Path(row['path']);shutil.copyfile(source,at/'frozen'/source.name)
  guard_plan={'stage':stage,'category':cat,'cumulative_category_caps_seconds':CAPS,'maximum_seconds':limit,'maximum_owned_RSS_GiB':rss_cap,'minimum_MemAvailable_GiB':192,'CPU_ids':[0,1,2,3],'maxThreads':1 if cat=='synthesis'else 4,'nice':19,'IOclass':3,'stall_seconds':300,'stall_progress':'owned user+system CPU ticks OR real log/checkpoint size/mtime changes; not stdout silence alone','source_identity':identity,'script_identities':[identify(p)for p in (at/'frozen').iterdir()]}
  command=['/usr/bin/nice','-n','19','/usr/bin/ionice','-c','3','/usr/bin/taskset','-c','0-3',str(VIVADO),'-mode','batch','-notrace','-log',str(at/'vivado.log'),'-journal',str(at/'vivado.jou'),'-source',str(at/'frozen/full_top_d38.tcl'),'-tclargs',stage,str(at),str(RUN)]
  if stage in {'repair_static','repair_rtl'}:command=['/usr/bin/nice','-n','19','/usr/bin/ionice','-c','3','/usr/bin/taskset','-c','0-3',sys.executable,str(at/'frozen/run_operand_equivalence_d38.py'),stage,str(at),str(RUN)]
  guard_plan.update({'argv':command,'cwd':str(work),'started_utc':now()});dump(at/'command.json',guard_plan)
  entry={'stage':stage,'category':cat,'maximum_seconds':limit,'attempt':str(at),'status':'running'};j['entries'].append(entry);dump(RUN/'budget_ledger.json',j)
  start=time.monotonic();known={};cpu_hwm={};policy={};peak=0;minimum=owned.mem_available_kb();last_progress=start;last_files={};reason=None;proc=None;last_items={};exit_code=None
  ctypes.CDLL(None).prctl(36,1,0,0,0) # own-descendant subreaper
  stop_requested=False
  def stop(signum,frame):
   nonlocal stop_requested
   stop_requested=True
  signal.signal(signal.SIGTERM,stop);signal.signal(signal.SIGINT,stop)
  try:
   assert set(range(4)).issubset(os.sched_getaffinity(0));assert minimum>192*1024*1024
   with (at/'driver.log').open('wb')as output,(at/'guard_samples.jsonl').open('w')as samples:
    proc=subprocess.Popen(command,cwd=work,stdout=output,stderr=subprocess.STDOUT,start_new_session=True);leader=proc.pid;tick=owned.process_start(leader);assert tick is not None;known[leader]=tick
    dump(at/'launch.json',{'utc':now(),'pid':leader,'start_time_ticks':tick,'pgid':os.getpgid(leader),'sid':os.getsid(leader)});dump(RUN/'current_status.json',{'stage':stage,'attempt':str(at),'execution_state':'running','verdict':'unassessed','utc':now()});print(json.dumps({'event':'ACTUAL_LAUNCH','stage':stage,'attempt':str(at),'pid':leader,'maximum_seconds':limit}),flush=True)
    next_policy=0
    while proc.poll()is None:
     current=time.monotonic();last_items=owned.owned_processes(owned.process_table(),leader,known);rss=sum(x['rss_kb']for x in last_items.values());peak=max(peak,rss);available=owned.mem_available_kb();minimum=min(minimum,available);cpu_advanced=False
     for pid,item in last_items.items():
      key=f'{pid}:{item["start_time_ticks"]}';v=proc_cpu(pid);old=cpu_hwm.get(key,0)
      if v>old:cpu_advanced=True;cpu_hwm[key]=v
     paths=[at/'driver.log',at/'vivado.log',at/'xsim.log',*list((RUN/'checkpoints').glob('*.dcp'))];file_advanced=False
     for p in paths:
      try:s=p.stat();v=(s.st_size,s.st_mtime_ns)
      except FileNotFoundError:continue
      if p in last_files and v!=last_files[p]:file_advanced=True
      last_files[p]=v
     if cpu_advanced or file_advanced:last_progress=current
     if current>=next_policy:
      next_policy=current+10
      for pid,item in last_items.items():
       if not owned.still_owned(item)or item['state'].startswith('Z'):continue
       try:
        affinity=sorted(os.sched_getaffinity(pid));io=subprocess.run(['/usr/bin/ionice','-p',str(pid)],capture_output=True,text=True,timeout=3);threads=list(Path(f'/proc/{pid}/task').iterdir());bad_threads=[int(t.name)for t in threads if not set(os.sched_getaffinity(int(t.name))).issubset({0,1,2,3})]
        ok=item['nice']==19 and set(affinity).issubset({0,1,2,3})and bool(affinity)and io.returncode==0 and 'idle'in io.stdout.lower()and not bad_threads
        policy[f'{pid}:{item["start_time_ticks"]}']={**item,'affinity':affinity,'ionice':io.stdout.strip(),'thread_count':len(threads),'bad_thread_affinity':bad_threads,'matches':ok}
        if not ok:reason='owned_resource_policy_mismatch'
       except (ProcessLookupError,FileNotFoundError,subprocess.TimeoutExpired):pass
     elapsed=current-start
     if stop_requested:reason='requested_stop'
     elif rss>=rss_cap*1024*1024:reason=f'owned_RSS_at_or_above_{rss_cap}GiB'
     elif available<=192*1024*1024:reason='MemAvailable_at_or_below_192GiB'
     elif elapsed>=limit:reason='stage_or_total_category_budget'
     elif current-last_progress>=300:reason='no_owned_CPU_log_checkpoint_progress_300s'
     sample={'utc':now(),'elapsed_seconds':elapsed,'owned_rss_kb':rss,'available_kb':available,'owned_CPU_ticks_observed':sum(cpu_hwm.values()),'last_progress_age_seconds':current-last_progress,'owned_processes':len(last_items),'trigger':reason};samples.write(json.dumps(sample)+'\n');samples.flush();dump(at/'live_status.json',sample)
     if reason:break
     time.sleep(1)
    if reason:
     dump(at/'initial_guard_trigger.json',{'reason':reason,'utc':now(),'owned_snapshot':list(last_items.values())})
     owned.OUT=at;owned.stop_and_kill(leader,known,last_items,{'reason':reason,'utc':now()})
    exit_code=proc.wait(timeout=15)
  except Exception as exc:
   reason=reason or 'guard_or_launch_exception';dump(at/'guard_exception.json',{'exception':repr(exc)})
   if proc is not None:
    owned.OUT=at;owned.stop_and_kill(proc.pid,known,last_items,{'reason':reason,'utc':now()});exit_code=proc.wait(timeout=15)
  finally:
   reap()
   remaining=owned.owned_processes(owned.process_table(),proc.pid if proc else -1,known)
   if remaining:
    owned.OUT=at/'cleanup';owned.OUT.mkdir(exist_ok=True);owned.stop_and_kill(proc.pid,known,remaining,{'reason':'remaining_owned_after_parent_exit','utc':now()})
    cleanup_start=time.monotonic()
    while remaining:
     time.sleep(.2);reap();remaining=owned.owned_processes(owned.process_table(),proc.pid,known)
     if time.monotonic()-cleanup_start>60:dump(at/'owned_cleanup_pending.json',{'utc':now(),'remaining':list(remaining.values()),'lock_still_held':True})
   elapsed=time.monotonic()-start
   success=exit_code==0 and reason is None and(at/'stage_complete.txt').exists()and not remaining
   receipt={'stage':stage,'category':cat,'verdict':'PASS'if success else 'COST_STOP'if reason and reason!='guard_or_launch_exception'else 'FAIL','elapsed_seconds':elapsed,'child_exit_code':exit_code,'guard_trigger':reason,'peak_owned_rss_kb':peak,'minimum_MemAvailable_kb':minimum,'known_owned_identities':known,'policy_samples':list(policy.values()),'policy_unobserved_identities':[{'pid':pid,'start_time_ticks':tick}for pid,tick in known.items()if f'{pid}:{tick}'not in policy],'owned_after_cleanup':list(remaining.values()),'source_identity':identity,'source_verify_after':None}
   try:
    receipt['source_verify_after']=verify_inputs(stage)==identity
    if stage not in {'repair_static','repair_rtl'}:receipt['source_verify_after']=receipt['source_verify_after'] and sha(at/'frozen/full_top_d38.xdc')==identity['xdc_sha256'] and sha(at/'frozen/physical_generics_v2.tcl')==identity['generics_tcl_sha256']
    if not receipt['source_verify_after']:success=False;receipt['verdict']='FAIL_SOURCE_IDENTITY'
   except Exception as exc:receipt['source_verify_after']=repr(exc);success=False;receipt['verdict']='FAIL_SOURCE_IDENTITY'
   cp=RUN/'checkpoints'/(stage+'.dcp')
   if success and cp.exists():dump(cp.with_suffix('.identity.json'),{'source_identity':identity,'checkpoint':identify(cp),'produced_by':str(at)})
   dump(at/'receipt.json',receipt);entry.update({'status':'complete','elapsed_seconds':elapsed,'verdict':receipt['verdict'],'receipt':str(at/'receipt.json')});dump(RUN/'budget_ledger.json',j);dump(RUN/'current_status.json',{'stage':stage,'attempt':str(at),'verdict':receipt['verdict'],'utc':now()});print(json.dumps({'event':'STAGE_COMPLETE','stage':stage,'verdict':receipt['verdict'],'elapsed_seconds':elapsed,'attempt':str(at),'peak_owned_rss_kb':peak}),flush=True)
  return success
def main():
 p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--stage',choices=list(STAGES));a=p.parse_args()
 os.sched_setaffinity(0,{0,1,2,3});os.nice(19);subprocess.run(['/usr/bin/ionice','-c','3','-p',str(os.getpid())],check=True,capture_output=True)
 if a.prepare:print(json.dumps({'source_freeze':prepare()['production_source_count'],'run':str(RUN)}),flush=True)
 if a.stage:sys.exit(0 if run_stage(a.stage)else 1)
if __name__=='__main__':main()
