#!/usr/bin/env python3
"""E016/R002 sole-option simulator-cost comparison, independent guarded budget."""
import argparse,datetime as dt,fcntl,hashlib,json,re,shlex,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1]
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R002';SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source'
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');CAPS={'reference':0,'static':300,'rtl':300,'ooc':0}
sys.path.insert(0,str(MOD/'tb'));from m007_parent_run import closure
EXPECTED_PARENT='e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def read(p):return json.loads(p.read_text())
def costs():
 d={k:0. for k in CAPS}
 for p in (RUN/'attempts').glob('*/receipt_*.json'):
  a=read(p);d[a['category']]+=a['wall_s']
 return d
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('attempt');p.add_argument('--debug',choices=['typical','off'],required=True);p.add_argument('--baseline',type=Path);p.add_argument('--build',type=Path);a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 if a.stage=='build' and a.debug=='off':assert a.baseline and read(a.baseline/'receipt_static.json')['verdict']=='PASS'
 if a.stage=='rtl':assert a.build and read(a.build/'receipt_static.json')['verdict']=='PASS' and read(a.build/'source_manifest.json')['debug']==a.debug
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  cat='static' if a.stage=='build' else 'rtl';used=costs();assert CAPS[cat]-used[cat]>=120
  at=RUN/'attempts'/a.attempt;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  if a.stage=='build':
   if a.baseline:
    baseline=a.baseline.resolve();b=read(baseline/'source_manifest.json');assert b['debug']=='typical'
    for q in (baseline/'frozen').iterdir():
     if q.is_file():shutil.copy2(q,f/q.name)
   else:
    for name,(origin,current,why) in closure('m007_single_parent_tb').items():shutil.copy2(origin,f/name)
    shutil.copy2(SRC/'r002_m007_single_parent_tb.sv',f/'m007_single_parent_tb.sv')
    for q in [Path(__file__),MOD/'tb/m007_parent_wall_driver.py',SRC/'r002_sim_cost_protocol.md',RUN/'instrumentation_boundary.json']:shutil.copy2(q,f/q.name)
   assert sha(f/'laya_m007_single_parent_v1.sv')==EXPECTED_PARENT
   files=[{'frozen':q.name,'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted(f.iterdir()) if q.is_file()]
   if a.baseline:assert [(x['frozen'],x['sha256']) for x in files]==[(x['frozen'],x['sha256']) for x in b['files']]
   argv=[str(VIV/'xelab'),'work.m007_single_parent_tb','--relax','-debug',a.debug,'-mt','4','--O3','-s','m007_parent_sim']
   dump(at/'source_manifest.json',{'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'host':socket.gethostname(),'debug':a.debug,'files':files,'top':'m007_single_parent_tb','parent_sha256':EXPECTED_PARENT,'all_original_assertions_retained':True,'O3':True,'xelab_argv':argv,'same_source_as':str(a.baseline.resolve()) if a.baseline else None,'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN'})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nif {[catch {set scopes [get_scopes -r /*]} message]} {\n puts $h "HIERARCHY_UNAVAILABLE $message"\n} else {\n foreach scope $scopes { puts $h $scope }\n}\nclose $h\nquit\n')
   lines=['#!/bin/bash','set -euo pipefail',shlex.join([sys.executable,str(f/'audit_parent_source.py'),'--frozen',str(f),'--out',str(at)]),shlex.join([str(VIV/'xvlog'),'--sv',*[str(q) for q in sorted(f.iterdir()) if q.suffix in ['.sv','.v']]]),shlex.join(argv),'echo M007_DEBUG_COST_COMPILE_PASS','set +e',shlex.join([str(VIV/'xsim'),'m007_parent_sim','-tclbatch',str(hier)])+' > hierarchy_query.log 2>&1','query_rc=$?','set -e',"printf '%s\\n' \"$query_rc\" > hierarchy_query_exit.txt",'echo M007_DEBUG_COST_BUILD_PASS']
   script=w/'build.sh';script.write_text('\n'.join(lines)+'\n');cmd=['/bin/bash',str(script)];marker='M007_DEBUG_COST_BUILD_PASS'
  else:
   build=a.build.resolve();b=read(build/'source_manifest.json')
   for q in (build/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(build/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   fi=read(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001/attempts/AT012_checked_semantic_qkv3/fixture_identity.json')
   fixtures=fi['fixture_files']
   for x in fixtures:assert sha(Path(x['path']))==x['sha256']
   dump(at/'fixture_identity.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'fixture_files':fixtures,'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted((w/'xsim.dir').rglob('*')) if q.is_file()]})
   dump(at/'source_manifest.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'debug':a.debug,'files':[{'frozen':q.name,'sha256':sha(q)} for q in sorted(f.iterdir()) if q.is_file()]})
   matrix=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture';inp=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture';attention=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'
   cmd=[sys.executable,str(f/'m007_parent_wall_driver.py'),'--out',str(w/'parent_wall_events.json'),'--',str(VIV/'xsim'),'m007_parent_sim','-runall','-testplusarg','MATRIX='+str(matrix),'-testplusarg','INPUT='+str(inp),'-testplusarg','ATTENTION='+str(attention),'-testplusarg','PREFIX=3'];marker='HARDWARE_AGENT_SIM_PASS M007_PARENT_QKV_PREFIX'
  gcmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static' else 8),'--timeout-seconds','120','--semantic-stall-seconds','120','--phase',cat]+(['--artifact-progress-root',str(w)] if cat=='static' else [])+['--',*cmd]
  dump(at/('command_'+cat+'.json'),{'argv':gcmd,'used_before_s':used,'lock_held_through_children':True,'debug':a.debug,'caps_s':CAPS,'no_old_budget_transfer':True});rc=subprocess.call(gcmd,cwd=w)
  g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
  if cat=='static':
   hp=w/'hierarchy_scopes.txt';scopes=hp.read_text(errors='replace').splitlines() if hp.exists() else [];expected=['resources','resources/fp','resources/div','resources/st','resources/qkv','resources/ln','resources/sfu','coeff','front','matrix','matrix/core','layer','context_adapter'];paths={x:scopes.count('/m007_single_parent_tb/dut/'+x) for x in expected};full=all(x==1 for x in paths.values())
   dump(at/'hierarchy_observation.json',{'debug':a.debug,'query_exit':int((w/'hierarchy_query_exit.txt').read_text()) if (w/'hierarchy_query_exit.txt').exists() else None,'scope_lines':len(scopes),'unique_expected_paths':paths,'observed_required_paths':full,'state':'OBSERVED' if full else 'UNOBSERVED','no_cross_snapshot_inheritance':True,'query_log':str(w/'hierarchy_query.log'),'scope':'Tcl observation only; separate from compile and numerical verdict'})
  else:
   fields=re.search(r'M007_PARENT_QKV_PREFIX_PASS blocks=(\d+) final_values=(\d+) public_QKV32_writes=(\d+) inputs=(\d+) Awrites=(\d+) Aacks=(\d+) elapsed=(\d+) actual_issue_ack=(\d+) actual_PS_feedback=(\d+) unfinished_parent=1',log)
   counts=re.search(r'M007_R002_HANDSHAKES inputs=(\d+) quant_returns=(\d+) Awrites=(\d+) Aacks=(\d+) W_AR=(\d+) W_R=(\d+) public_QKV32=(\d+) parent_phase=(\d+) cycle=(\d+)',log)
   if passed:assert fields and counts and tuple(map(int,fields.groups()))[:6]==(3,24576,768,4096,4096,4096) and tuple(map(int,counts.groups()))[:4]==(4096,4096,4096,4096)
   dump(at/'observed_metrics.json',{'debug':a.debug,'wall_s':g['elapsed_seconds'],'prefix_metrics':dict(zip(['blocks','final_values','public_QKV32_writes','inputs','Awrites','Aacks','elapsed_cycles','actual_issue_ack','actual_PS_feedback'],map(int,fields.groups()))) if fields else None,'handshake_counts':dict(zip(['inputs','quant_returns','Awrites','Aacks','W_AR','W_R','public_QKV32','parent_phase','absolute_cycle'],map(int,counts.groups()))) if counts else None,'strict_checked_highwater':g['checked_highwater'],'original_identity_rejects':len(re.findall(r'^M007_PARENT_IDENTITY_REJECT_PASS',log,re.M)),'no_hardware_performance_claim':True})
  dump(at/('receipt_'+cat+'.json'),{'category':cat,'debug':a.debug,'wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':fatal,'marker_found':marker in log,'required_marker':marker,'verdict':'PASS' if passed else 'COST_STOP' if g['trigger'] else 'FAIL','driver_sha256':sha(at/('guard_'+cat)/'driver.log')});used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS},'R001_balances_transferred':False})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line or 'M007_R002_HANDSHAKES' in line:print(line,flush=True)
  print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
