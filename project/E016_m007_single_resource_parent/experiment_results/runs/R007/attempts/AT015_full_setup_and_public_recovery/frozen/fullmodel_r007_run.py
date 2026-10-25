#!/usr/bin/env python3
"""Bounded R007 actual build/RTL runner. No model reference work."""
from pathlib import Path
from decimal import Decimal
import argparse,fcntl,hashlib,json,re,shlex,shutil,socket,subprocess,sys
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';S=Path(__file__).parent
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
CAP={'reference':0,'static':1200,'rtl':3600,'ooc':0}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def dump(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def costs():
 d={k:Decimal(0)for k in CAP}
 for p in(R/'attempts').glob('*/receipt_*.json'):
  x=read(p);d[x['category']]+=Decimal(str(x['wall_s']))
 return d

def dependency(checkpoint):
 d=read(checkpoint)
 if d.get('schema')=='d32-joint-tanh3-source-integration-v1':
  assert d['ready_for_A010_R007_compile_and_affected_tests']is True and d['source_only']is True and d['combined_runtime_verified']is False
  base=read(ROOT/d['D29_frozen_bundle']);assert sha(ROOT/d['D29_frozen_bundle'])==d['D29_frozen_bundle_sha256']and base['cleanup_empty']is True
  for key in ['build_report','pilot_receipt','pilot_report']:assert sha(ROOT/base[key])==base[key+'_sha256']
  assert read(ROOT/base['pilot_report'])['status']=='PASS'
  assert sha(ROOT/d['D29_frozen_body_source'])==d['D29_frozen_body_sha256']
  assert (ROOT/d['current_body_source']).read_text().replace('laya_m007_tanh8_v3','laya_m007_tanh8_v2')==(ROOT/d['D29_frozen_body_source']).read_text()
  assert sha(ROOT/d['D31_manifest'])==d['D31_manifest_sha256']
  sources=d['proposed_combined_production_closure_sha256']
 else:
  assert d.get('ready_for_parent_static_and_affected_functional_integration')is True or d.get('ready_for_parent_static_integration')is True
  assert d['cleanup_empty']is True
  sources=d.get('actual_compiled_production_closure_sha256',d.get('source_sha256'))
 assert sources
 for name,h in sources.items():assert sha(ROOT/name)==h,name
 assert any(name.endswith('laya_m007_resident_joint_v3.sv')for name in sources)
 return {'checkpoint':str(checkpoint.relative_to(ROOT)),'checkpoint_sha256':sha(checkpoint),'owner_evidence':d,'sources':sources}

def selected(admitted):
 # Preserve the exact last original verified matrix/A/W/quant/resource closure.
 old=R.parent/'R006/attempts/AT014_CE_fixed_capture_minimum_prefix_build'
 out={}
 for row in read(old/'source_manifest.json')['files']:
  q=old/'frozen'/row['frozen'];assert sha(q)==row['sha256']
  if q.suffix in ['.sv','.v','.dat']and not q.name.endswith('_tb.sv')and not q.name.startswith('laya_m007_single_parent_'):
   out[q.name]=(q,'immutable R006 leaf baseline')
 for name,h in admitted['sources'].items():
  q=ROOT/name
  if q.suffix in ['.sv','.v','.dat']:out[q.name]=(q,'A007 actual delivered production bundle')
 for rel in ['forward_controller/rtl/laya_m007_single_parent_v3.sv','forward_controller/tb/m007_fullmodel_parent_tb.sv','forward_controller/tb/m007_fullmodel_joint_tb.sv','attention_and_fp_engine/tb/m007_type29_joint_tb.sv','q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv','hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv','hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv','model_catalog/rtl/laya_m007_catalog_reader_v1.sv']:
  q=M/rel;out[q.name]=(q,'R007 canonical integration source')
 # Non-instantiated old wrappers are excluded where a successor is selected.
 for name in ['laya_m007_resident_joint_v2.sv','laya_m007_control_workspace_joint_v2.sv','laya_m007_resident_vector32_v2.sv']:
  out.pop(name,None)
 for q in [Path(__file__),S/'compose_fullmodel_parent_r007.py',S/'fullmodel_parent_control_r007.svpart',S/'prepare_fullmodel_services_r007.py',S/'prepare_fullmodel_tb_r007.py',S/'fullmodel_tb_body_r007.svpart',S/'audit_fullmodel_census_r007.py',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',R/'protocol.md']:
  out[q.name]=(q,'owned protocol/runner')
 return out

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl','audit']);p.add_argument('attempt');p.add_argument('--checkpoint',type=Path);p.add_argument('--build',type=Path);p.add_argument('--top',choices=['m007_fullmodel_parent_tb','m007_w_reader_transport_v2_tb'],default='m007_fullmodel_parent_tb');p.add_argument('--timeout',type=int,choices=[120,300],default=120);p.add_argument('--mode',type=int,choices=range(8),default=0);a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 cat='rtl'if a.stage=='rtl'else'static';timeout=a.timeout;
 if timeout>120:
  assert a.stage=='build'
  basis=read(R/'attempts/AT011_service_declaration_closure_build/receipt_static.json');assert basis['wall_s']>60
  assert 'Built simulation snapshot m007_fullmodel_sim' in(R/'attempts/AT011_service_declaration_closure_build/guard_static/driver.log').read_text()
 used=costs();assert Decimal(timeout)<=Decimal(CAP[cat])-used[cat]
 assert cat!='rtl'or Decimal(CAP['rtl'])-used['rtl']>=timeout+400
 # Caller has already received actual resource handoff; no speculative queued EDA.
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  at=R/'attempts'/a.attempt;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir();shutil.copy2(Path(__file__),at/'actual_orchestrator.py')
  if a.stage=='build':
   if a.top=='m007_fullmodel_parent_tb':
    assert a.checkpoint;admitted=dependency(a.checkpoint.resolve());chosen=selected(admitted)
   else:
    admitted=None;chosen={q.name:(q,'standalone real W transport')for q in [M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv',M/'hbm_loader_and_cache/tb/m007_w_reader_transport_v2_tb.sv',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',Path(__file__)]}
   for name,(q,why)in chosen.items():shutil.copy2(q,f/name)
   dump(at/'source_manifest.json',{'top':a.top,'host':socket.gethostname(),'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','bundle_evidence':admitted,'files':[{'frozen':name,'source':str(q.relative_to(ROOT)),'sha256':sha(f/name),'why':why}for name,(q,why)in chosen.items()]})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
   cmd1=[str(VIV/'xvlog'),'--sv',*[str(q)for q in sorted(f.iterdir(),key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))if q.suffix in ['.sv','.v']]]
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join(cmd1)+'\n'+shlex.join([str(VIV/'xelab'),'work.'+a.top,'--relax','-debug','typical','-mt','4','--O3','-s','m007_fullmodel_sim'])+'\n'+shlex.join([str(VIV/'xsim'),'m007_fullmodel_sim','-tclbatch',str(hier)])+'\necho M007_FULLMODEL_BUILD_PASS\n')
   if a.top=='m007_fullmodel_parent_tb':
    text=script.read_text();needle='\necho M007_FULLMODEL_BUILD_PASS\n'
    extra=shlex.join([str(VIV/'xelab'),'work.m007_type29_joint_tb','--relax','-debug','typical','-mt','4','--O3','-s','m007_type29_joint_sim'])
    extra+='\n'+shlex.join([str(VIV/'xelab'),'work.m007_fullmodel_joint_tb','--relax','-debug','typical','-mt','4','--O3','-s','m007_fullmodel_joint_sim'])
    assert needle in text;script.write_text(text.replace(needle,'\n'+extra+needle))
   cmd=['/bin/bash',str(script)];marker='M007_FULLMODEL_BUILD_PASS'
  elif a.stage=='audit':
   assert a.build;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'
   for q in [S/'audit_fullmodel_census_r007.py',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']:
    shutil.copy2(q,f/q.name)
   dump(at/'source_manifest.json',{'compiled_build':str(b.relative_to(ROOT)),'build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
   cmd=[sys.executable,str(f/'audit_fullmodel_census_r007.py'),'--build',str(b),'--out',str(w)];marker='M007_FULLMODEL_CENSUS_PASS'
  else:
   assert a.build;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'
   for row in read(b/'source_manifest.json')['files']:assert sha(b/'frozen'/row['frozen'])==row['sha256']
   for q in(b/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(b/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   dump(at/'source_manifest.json',{'compiled_build':str(b.relative_to(ROOT)),'build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
   products=read(R/'input_products.json');
   for row in products['files']:
    assert sha(ROOT/row['source'])==row['source_sha256']
    if 'serialized'in row:assert sha(ROOT/row['serialized'])==row['serialized_sha256']
   dump(at/'input_products.json',products)
   att=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'
   h=ROOT/next(x['source']for x in products['files']if x.get('role')=='original H0 groups serialization')
   cmd=[str(VIV/'xsim'),'m007_fullmodel_sim','-runall','-testplusarg','MODE='+str(a.mode),'-testplusarg','DATA='+str(R/'data'),'-testplusarg','ROPE='+str(att),'-testplusarg','H='+str(h)]
   if a.mode==5:
    matrix=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
    cmd+=['-testplusarg','MATRIX='+str(matrix)]
    dump(at/'matrix_input_identity.json',{'files':[{'path':str(q.relative_to(ROOT)),'sha256':sha(q)}for q in sorted((matrix/'qkv_0_weight').glob('*.hex'))]})
   marker=['M007_FULLMODEL_ABI','M007_FULLMODEL_SETUP','M007_FULLMODEL_CATALOG_DRAIN','M007_FULLMODEL_CRC','M007_FULLMODEL_H_CATALOG_PREFIX','M007_FULLMODEL_QKV_PREFIX','TYPE29_JOINT','JOINT23'][a.mode]
   if a.mode==6:
    owner=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R004/data/fixture_manifest.json';fi=read(owner)
    for row in fi['products'].values():
     assert sha(ROOT/row['source'])==row['sha256']and sha(ROOT/row['words_hex'])==row['hex_sha256']
    dump(at/'joint_input_identity.json',{'manifest':str(owner.relative_to(ROOT)),'sha256':sha(owner),'files':fi['products'],'scope':'same production closure affected joint checker; no preceding28-layer producer'})
    cmd=[str(VIV/'xsim'),'m007_type29_joint_sim','-runall','-testplusarg','MODE=2','-testplusarg','OP=1','-testplusarg','PROGRESS_FILE='+str(w/'joint_semantic_progress.jsonl')]
    for flag,name in [('Q','final_norm'),('GOLD','type_add'),('TYPE','type')]:cmd+=['-testplusarg',flag+'='+str(ROOT/fi['products'][name]['words_hex'])]
   if a.mode==7:
    residual=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work'
    gamma=ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R001/attempts/AT001_original_ln_reference/fixture'
    files={'H':residual/'H.hex','Q':residual/'Q.hex','GOLD':residual/'GOLD.hex','NORM':R/'data/norm_ff.words.hex','GRAW':gamma/'gamma_encoder27/raw.hex','GGOLD':gamma/'gamma_encoder27/output.hex','GAMMA':gamma/'gamma.hex','GV':ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work/geglu_vectors.hex'}
    dump(at/'joint_input_identity.json',{'files':{k:{'path':str(v.relative_to(ROOT)),'sha256':sha(v)}for k,v in files.items()},'source_adapter':read(R/'joint_adapter_source.json'),'scope':'same closure G/residual128/LN16 actual composition checker'})
    cmd=[str(VIV/'xsim'),'m007_fullmodel_joint_sim','-runall','-testplusarg','MODE=0','-testplusarg','ROWS=16','-testplusarg','PROGRESS_FILE='+str(w/'joint_semantic_progress.jsonl'),'-testplusarg','TRACE_FILE='+str(w/'joint_trace.jsonl')]
    for k,v in files.items():cmd+=['-testplusarg',k+'='+str(v)]
   if read(b/'source_manifest.json')['top']=='m007_w_reader_transport_v2_tb':marker='M007_W_READER_TRANSPORT'
  guard=[sys.executable,str(f/'m007_parent_guard_v2.py'),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static'else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',cat]
  if cat=='static':guard+=['--artifact-progress-root',str(w)]
  guard+=['--',*cmd]
  dump(at/('command_'+cat+'.json'),{'argv':guard,'lock_held_through_descendants':True,'used_before_seconds':{k:str(v)for k,v in used.items()},'mode':a.mode,'full_graph_authorized_by_command':False})
  rc=subprocess.call(guard,cwd=w);g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)^\s*(?:Fatal|ERROR):',log));ok=rc==0 and marker in log and not fatal
  receipt={'category':cat,'wall_s':g['elapsed_seconds'],'guard_exit':rc,'guard':g,'mode':a.mode,'marker':marker,'marker_found':marker in log,'verdict':'PASS'if ok else'COST_STOP'if g['trigger']else'FAIL','full_graph':'NOT_RUN'}
  dump(at/('receipt_'+cat+'.json'),receipt)
  new=costs();dump(R/'budget_ledger.json',{'schema':'m007-r007-budget-v1','limits_seconds':CAP,'used_seconds':{k:str(v)for k,v in new.items()},'remaining_seconds':{k:str(Decimal(CAP[k])-v)for k,v in new.items()},'rtl_reserve_seconds':400,'old_run_budget_transferred':False})
  print(json.dumps({'attempt':a.attempt,'category':cat,'verdict':receipt['verdict'],'wall_s':receipt['wall_s'],'trigger':g['trigger']}),flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
