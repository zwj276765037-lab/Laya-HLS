#!/usr/bin/env python3
import argparse,datetime as dt,fcntl,hashlib,json,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003'
GUARD=MOD/'tm1tn8_gs32_512/tb/production_guard.py';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['fixture','build','rtl']);p.add_argument('attempt');p.add_argument('--compiled-sources',action='store_true',help='Explicitly run immutable build SV, preserving old shared dependency versions');p.add_argument('--top',default='m007_matrix_f32_tb',choices=['m007_matrix_f32_tb','m007_a_cancel_tb','m007_quant_a_peer_tb']);p.add_argument('--input-fixture',type=Path);p.add_argument('--fixture',type=Path);p.add_argument('--build',type=Path);p.add_argument('--pilot',type=Path);p.add_argument('--timeout',type=int,default=120);p.add_argument('--case',type=int,default=0);p.add_argument('--prefix',type=int,default=3);p.add_argument('--stress',type=int,default=0);p.add_argument('--cost-baseline',type=Path,action='append',default=[],help='Explicit prior PASS full-N checker cost floor; does not replace current-build pilot');p.add_argument('--reserve-rtl',type=float,default=0,help='Seconds reserved for already-required remaining directed coverage; never extra budget');a=p.parse_args()
 if not re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt):p.error('ATnnn_name required')
 if a.stage=='rtl' and a.prefix==0 and (RUN/'automatic_full_queue_defer.json').exists():
  print('NOT_RUN automatic full queue deferred for actual-cost replanning; no lock/tool/attempt launched',flush=True);return 2
 caps={'reference':900,'static':1800,'rtl':4800,'ooc':600}
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  used={k:0.0 for k in caps}
  for rp in (RUN/'attempts').glob('*/receipt_*.json'):
   r=json.loads(rp.read_text());used[r['category']]+=r['wall_s']
  at=RUN/'attempts'/a.attempt
  if at.exists():raise RuntimeError('preserve old attempts')
  frozen=at/'frozen';work=at/'work';frozen.mkdir(parents=True);work.mkdir()
  shared=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl';wmod=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl'
  src=[Path(__file__),MOD/'tb/m007_matrix_f32_fixture.py',ROOT/'project/E002_Laya_HLS/experiment/tools/m007_weight_pack.py',GUARD,ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']+list((MOD/'rtl').glob('laya_m007_*.sv'))+[MOD/'tm1tn8_gs32_512/rtl'/x for x in ['tm1tn8_integer_tree_packed.sv','tm1tn8_signed_pack_pair.sv']]+[shared/x for x in ['laya_shared_fp256_v2.sv','laya_fp_return_credit_v1.sv','laya_fmul_rne_v1.sv','laya_fadd_rne_v1.sv','laya_attention_storage_v1.sv']]+[wmod/x for x in ['laya_m007_w_bank_v1.sv','laya_m007_w_reader_v1.sv','laya_m007_w_supply_v1.sv']]
  if a.stage=='fixture':src+=[ROOT/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py',ROOT/'source/m007_matrix_supply_map_20261021.json']
  else:src+=[MOD/('tb/'+a.top+'.sv')]
  src += list((ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl').glob('laya_m007_quant*.sv'))+[shared/'laya_shared_div8_v1.sv',shared/'laya_fdiv_rne_v1.sv',shared/'laya_return_vector_credit_v1.sv']
  if a.top=='m007_a_cancel_tb' and a.stage!='fixture':src=[s for s in src if s.suffix!='.sv' or s.name in {'laya_m007_a_cache_v1.sv','laya_m007_a_bank_v1.sv','m007_a_cancel_tb.sv'}]
  for s in src:
   origin=a.build.resolve()/'frozen'/s.name if a.stage=='rtl' and a.compiled_sources and s.suffix=='.sv' else s
   shutil.copy2(origin,frozen/s.name)
  dump(at/'source_manifest.json',{'time':dt.datetime.now(dt.timezone.utc).isoformat(),'hostname':os.uname().nodename,'requested_model':'gpt-6.1-sol','requested_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','compiled_sources_explicit':a.compiled_sources,'sources':[{'path':str(s),'frozen':s.name,'sha256':sha(frozen/s.name),'bytes':(frozen/s.name).stat().st_size,'observed_current_sha256':sha(s),'compiled_origin':str(a.build.resolve()/'frozen'/s.name) if a.stage=='rtl' and a.compiled_sources and s.suffix=='.sv' else None} for s in src]})
  if a.stage=='fixture':category='reference';rss=16;cmd=[sys.executable,str(frozen/'m007_matrix_f32_fixture.py'),'--root',str(ROOT),'--out',str(work/'fixture')];marker='M007_F32_INPUT_FIXTURE_PASS'
  elif a.stage=='build':
   category='static';rss=24;marker=None;script=work/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(x) for x in sorted(frozen.glob('*.sv'),key=lambda p:(0 if 'pkg' in p.name else 1,p.name)))+'\n'+str(VIV/'xelab')+' work.'+a.top+' --relax -mt 4 --O3 -s m007_matrix_f32_sim\n');cmd=['/bin/bash',str(script)]
  else:
   category='rtl';rss=8;marker='HARDWARE_AGENT_SIM_PASS '+('M007_A_CANCEL' if a.top=='m007_a_cancel_tb' else 'M007_QUANT_A_PEER' if a.top=='m007_quant_a_peer_tb' else 'M007_MATRIX_F32')
   if not a.build or (a.top!='m007_a_cancel_tb' and (not a.fixture or not a.input_fixture)):p.error('build and actual data/input fixture required')
   fixture=a.fixture.resolve() if a.fixture else RUN;input_fixture=a.input_fixture.resolve() if a.input_fixture else RUN;build=a.build.resolve()
   for h in frozen.glob('*.sv'):
    if not (build/'frozen'/h.name).exists() or sha(h)!=sha(build/'frozen'/h.name):raise RuntimeError('compiled closure mismatch '+h.name)
   if a.prefix==0 and a.top!='m007_a_cancel_tb':
    if not a.pilot:p.error('complete shape requires actual same-version pilot')
    pilot=a.pilot.resolve();r=json.loads((pilot/'receipt_rtl.json').read_text());identity=json.loads((pilot/'fixture_identity.json').read_text());log=(pilot/'guard_rtl/driver.log').read_text()
    if r['verdict']!='PASS' or identity['build_source_manifest_sha256']!=sha(build/'source_manifest.json'):raise RuntimeError('pilot version/verdict mismatch')
    m=re.search(r'M007_F32_PREFIX_PASS .*?total_cycles=(\d+)',log)
    if not m:raise RuntimeError('missing measured pilot cycles')
    k=[1024,1024,1024,2624,1024,4096,1024,1024][a.case];n=[3072,1024,5248,1024,4096,1024,3072,1024][a.case];cap=[57344,22528,92160,56576,73728,86016,57344,22528][a.case]
    projected_cycles=cap+n//32+128  # F32 cap already includes the complete streamed quant/A front end; no TB A prefill
    build_manifest=json.loads((build/'source_manifest.json').read_text())
    def dut_identity(manifest):return {e['path']:e['sha256'] for e in manifest['sources'] if e['path'].endswith('.sv') and '/rtl/' in e['path']}
    measured=[{'attempt':str(pilot),'kind':'three_block_pilot','wall_s':r['wall_s'],'total_cycles':int(m.group(1)),'wall_s_per_cycle':r['wall_s']/int(m.group(1))}]
    # Full-N checker/data costs can exceed the short prefix rate. Use every actual
    # PASS from this exact build, retaining the largest measured cost per TB cycle.
    for full_receipt in (RUN/'attempts').glob('*/receipt_rtl.json'):
     fr=json.loads(full_receipt.read_text());fd=full_receipt.parent
     if fr['verdict']!='PASS' or not (fd/'fixture_identity.json').exists():continue
     fident=json.loads((fd/'fixture_identity.json').read_text())
     same_build=fident['build_source_manifest_sha256']==sha(build/'source_manifest.json')
     prior_build=Path(fident['build']);prior_manifest=json.loads((prior_build/'source_manifest.json').read_text())
     if sha(prior_build/'source_manifest.json')!=fident['build_source_manifest_sha256']:raise RuntimeError('prior full-N build manifest changed')
     if not same_build and dut_identity(prior_manifest)!=dut_identity(build_manifest):continue
     flog=(fd/'guard_rtl/driver.log').read_text();fm=re.search(r'M007_F32_MATRIX_PASS .*?total_cycles=(\d+)',flog)
     if fm:measured.append({'attempt':str(fd),'kind':'complete_N' if same_build else 'complete_N_same_DUT_prior_TB','build_source_manifest_sha256':fident['build_source_manifest_sha256'],'wall_s':fr['wall_s'],'total_cycles':int(fm.group(1)),'wall_s_per_cycle':fr['wall_s']/int(fm.group(1))})
    for baseline in a.cost_baseline:
     baseline=baseline.resolve();br=json.loads((baseline/'receipt_rtl.json').read_text());bi=json.loads((baseline/'fixture_identity.json').read_text());bm=re.search(r'M007_(?:FULL|F32)_MATRIX_PASS .*?total_cycles=(\d+)',(baseline/'guard_rtl/driver.log').read_text())
     if br['verdict']!='PASS' or not bm or br['guard']['trigger']:raise RuntimeError('explicit cost baseline lacks actual complete-N PASS')
     if sha(Path(bi['build'])/'source_manifest.json')!=bi['build_source_manifest_sha256']:raise RuntimeError('explicit baseline build changed')
     measured.append({'attempt':str(baseline),'kind':'explicit_prior_DUT_full_checker_cost_floor','build_source_manifest_sha256':bi['build_source_manifest_sha256'],'wall_s':br['wall_s'],'total_cycles':int(bm.group(1)),'wall_s_per_cycle':br['wall_s']/int(bm.group(1))})
    estimate=max(x['wall_s_per_cycle'] for x in measured)*projected_cycles*1.35+10
    gate={'pilot':str(pilot),'pilot_receipt_sha256':sha(pilot/'receipt_rtl.json'),'pilot_cycles':int(m.group(1)),'pilot_wall_s':r['wall_s'],'projected_cycles':projected_cycles,'measured_cost_sources':measured,'checker_and_data_safety_factor':1.35,'conservative_estimate_s':estimate,'requested_timeout_s':a.timeout,'remaining_rtl_s':caps['rtl']-used['rtl'],'required_directed_reserve_s':a.reserve_rtl,'passed':estimate<=min(a.timeout,1200,caps['rtl']-used['rtl']-a.reserve_rtl)};dump(at/'cost_gate.json',gate)
    if not gate['passed']:
     dump(at/'receipt_rtl.json',{'category':'rtl','wall_s':0,'verdict':'COST_STOP','reason':'latest same-version measured cost exceeds single/remaining cap after required-coverage reserve; no simulation launched','cost_gate':gate});print('M007_FULL_COST_STOP no simulation launched',flush=True);return 1
   shutil.copytree(build/'work/xsim.dir',work/'xsim.dir');dump(at/'fixture_identity.json',{'build':str(build),'build_source_manifest_sha256':sha(build/'source_manifest.json'),'fixture':str(fixture),'input_fixture':str(input_fixture),'files':[{'path':str(x),'sha256':sha(x),'bytes':x.stat().st_size} for x in ([] if a.top=='m007_a_cancel_tb' else list(fixture.rglob('*'))+list(input_fixture.rglob('*'))) if x.is_file()],'snapshot_files':[{'path':str(x.relative_to(work)),'sha256':sha(x),'bytes':x.stat().st_size} for x in (work/'xsim.dir').rglob('*') if x.is_file()]})
   cmd=[str(VIV/'xsim'),'m007_matrix_f32_sim','-runall','-testplusarg','FIXTURE='+str(fixture),'-testplusarg','INPUT_FIXTURE='+str(input_fixture),'-testplusarg','CASE='+str(a.case),'-testplusarg','PREFIX='+str(a.prefix),'-testplusarg','STRESS='+str(a.stress)]
  if a.timeout>min(1200 if category=='rtl' else 600,caps[category]-used[category]):raise RuntimeError('independent R003 budget exceeded')
  gcmd=[sys.executable,str(GUARD),'--out',str(at/('guard_'+category)),'--cwd',str(work),'--rss-gib',str(rss),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(work),'--',*cmd]
  dump(at/('command_'+category+'.json'),{'argv':gcmd,'lock_held_through_children':True,'used_before_s':used.copy()});rc=subprocess.call(gcmd,cwd=work);result=json.loads((at/('guard_'+category)/'guard_result.json').read_text());log=(at/('guard_'+category)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));ok=rc==0 and not fatal and (not marker or marker in log);used[category]+=result['elapsed_seconds']
  dump(at/('receipt_'+category+'.json'),{'category':category,'guard':result,'wall_s':result['elapsed_seconds'],'guard_exit':rc,'error_or_fatal':fatal,'required_marker':marker,'marker_found':marker in log if marker else None,'verdict':'PASS' if ok else ('COST_STOP' if result.get('trigger') else 'FAIL'),'driver_sha256':sha(at/('guard_'+category)/'driver.log')})
  dump(RUN/'budget_ledger.json',{'limits_s':caps,'used_s':used,'remaining_s':{k:caps[k]-used[k] for k in caps}})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
  print(json.dumps(result),flush=True);return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
