#!/usr/bin/env python3
"""Bounded R007 actual build/RTL runner. No model reference work."""
from pathlib import Path
from decimal import Decimal,ROUND_CEILING
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
 for rel in ['forward_controller/rtl/laya_m007_single_parent_v3.sv','forward_controller/tb/m007_fullmodel_parent_tb.sv','forward_controller/tb/m007_fullmodel_joint_tb.sv','forward_controller/tb/m007_quant_A_cancel_r007_tb.sv','forward_controller/tb/m007_fullmodel_encoder_tb.sv','forward_controller/tb/m007_fullmodel_encoder_1d_tb.sv','attention_and_fp_engine/tb/m007_type29_joint_tb.sv','q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv','hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv','hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv','model_catalog/rtl/laya_m007_catalog_reader_v1.sv']:
  q=M/rel;out[q.name]=(q,'R007 canonical integration source')
 # Non-instantiated old wrappers are excluded where a successor is selected.
 for name in ['laya_m007_resident_joint_v2.sv','laya_m007_control_workspace_joint_v2.sv','laya_m007_resident_vector32_v2.sv']:
  out.pop(name,None)
 for q in [Path(__file__),S/'compose_fullmodel_parent_r007.py',S/'fullmodel_parent_control_r007.svpart',S/'prepare_fullmodel_services_r007.py',S/'prepare_fullmodel_tb_r007.py',S/'fullmodel_tb_body_r007.svpart',S/'audit_fullmodel_census_r007.py',S/'prepare_fullmodel_joint_r007.py',S/'prepare_full_encoder_checker_r007.py',S/'prepare_full_encoder_inputs_r007.py',S/'prepare_encoder_1d_compat_r007.py',R/'encoder_1d_compat_source_preparation.json',M/'forward_controller/tb/m007_fullmodel_wall_driver.py',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',R/'protocol.md']:
  out[q.name]=(q,'owned protocol/runner')
 return out

def ln128_gate(build,pilot,used,timeout):
 """Actual LN16 cost, with the sole allowed TB observer correction explicit."""
 pr=read(pilot/'receipt_rtl.json');assert pr['verdict']=='PASS'and pr['mode']==7
 pm=read(pilot/'source_manifest.json');bm=read(build/'source_manifest.json')
 assert bm['top']=='m007_fullmodel_joint_tb'
 for row in pm['files']:assert sha(pilot/'frozen'/row['frozen'])==row['sha256']
 for row in bm['files']:assert sha(build/'frozen'/row['frozen'])==row['sha256']
 production=lambda manifest:{x['frozen']:x['sha256']for x in manifest['files']if Path(x['frozen']).suffix in ['.sv','.v','.dat']and not x['frozen'].endswith('_tb.sv')}
 assert production(pm)==production(bm),'LN pilot production closure changed'
 old=(pilot/'frozen/m007_fullmodel_joint_tb.sv').read_text();new=(build/'frozen/m007_fullmodel_joint_tb.sv').read_text()
 before='vector_writes++;checked+=32;';after='vector_writes++;residual_total++;checked+=32;'
 assert old.count(before)==1 and old.replace(before,after)==new,'only aggregate observer increment is admitted'
 assert sha(pilot/'frozen/m007_fullmodel_wall_driver.py')==sha(build/'frozen/m007_fullmodel_wall_driver.py')
 ev=read(pilot/'work/wall_events.json')['events']
 start=[x for x in ev if x['line'].startswith('JOINT23_LN_BEGIN gamma=0 rows=16 ')];end=[x for x in ev if x['line'].startswith('JOINT23_LN_END gamma=0 rows=16 ')];assert len(start)==len(end)==1
 assert 'outputs=512' in end[0]['line']
 phase=Decimal(str(end[0]['elapsed_s']))-Decimal(str(start[0]['elapsed_s']));fixed=Decimal(str(pr['wall_s']))-phase
 estimate=fixed+Decimal('1.35')*8*phase+10
 assert 0<phase and estimate<=1200 and estimate<=timeout<=1200
 assert Decimal(CAP['rtl'])-used['rtl']>=timeout+400
 return {'schema':'m007-r007-LN128-cost-gate-v1','pilot':str(pilot.relative_to(ROOT)),'pilot_receipt_sha256':sha(pilot/'receipt_rtl.json'),'pilot_wall_events_sha256':sha(pilot/'work/wall_events.json'),'build':str(build.relative_to(ROOT)),'build_manifest_sha256':sha(build/'source_manifest.json'),'production_closure_equal':True,'tb_delta':'Only residual_total++ at existing real VECTOR commit checker; original arithmetic, numerical comparisons, protocol assertions, checked counter and scheduling unchanged. AT023 raw residual_vectors=0 is preserved as a reporting defect.','rows_pilot':16,'rows_target':128,'measured_LN16_phase_s':str(phase),'fixed_guard_total_minus_LN16_s':str(fixed),'estimate_formula':'fixed + 1.35 * 8 * measured_LN16_phase + 10','estimate_s':str(estimate),'ceil_estimate_s':int(estimate.to_integral_value(rounding=ROUND_CEILING)),'timeout_s':timeout,'remaining_before_s':str(Decimal(CAP['rtl'])-used['rtl']),'reserve_s':400,'scope':'same production G/residual128/LN128 component; final A means Attention owner return, not LN-to-quant/A-cache chaining','gate':'OPEN'}

def qkv_head_gate(build,pilot,used,timeout):
 contract=ROOT/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md'
 text=contract.read_text();assert 'D32 正常路径成本边界接续（主控增量97' in text and '1649s' in text
 pr=read(pilot/'receipt_rtl.json');assert pr['verdict']=='PASS'and pr['mode']==8
 pm=read(pilot/'source_manifest.json');assert pm['compiled_build']==str(build.relative_to(ROOT))and pm['build_manifest_sha256']==sha(build/'source_manifest.json')
 bm=read(build/'source_manifest.json');assert bm['top']=='m007_fullmodel_parent_tb'
 for row in bm['files']:assert sha(build/'frozen'/row['frozen'])==row['sha256']
 assert read(pilot/'normal_chain_input_identity.json')['original_B1_mask128']=='00000000000000ffffffffffffffffff'
 ev=read(pilot/'work/wall_events.json')['events'];blocks=[Decimal(str(x['elapsed_s']))for x in ev if x['line'].startswith('M007_FULLMODEL_MATRIX_BLOCK phase=QKV ')];assert len(blocks)==3
 estimate=Decimal('1.35')*(Decimal(str(pr['wall_s']))+45*max(blocks[1]-blocks[0],blocks[2]-blocks[1]))+10
 qkv=int(estimate.to_integral_value(rounding=ROUND_CEILING));assert qkv==1519 and timeout==qkv+120+10==1649
 assert Decimal(CAP['rtl'])-used['rtl']>=timeout+400
 return {'schema':'m007-r007-QKV48-first-head-segment-gate-v1','contract':str(contract.relative_to(ROOT)),'contract_sha256':sha(contract),'contract_scope':'D32 controller increment97 normal path cost boundary','pilot':str(pilot.relative_to(ROOT)),'pilot_receipt_sha256':sha(pilot/'receipt_rtl.json'),'pilot_wall_events_sha256':sha(pilot/'work/wall_events.json'),'build':str(build.relative_to(ROOT)),'build_manifest_sha256':sha(build/'source_manifest.json'),'snapshot_and_TB_unchanged':True,'QKV48_estimate_s':str(estimate),'QKV_retire_cap_s':qkv,'post_QKV_to_HEAD_END_cap_s':120,'retirement_tail_cap_s':10,'outer_timeout_s':timeout,'remaining_before_s':str(Decimal(CAP['rtl'])-used['rtl']),'reserve_s':400,'post_QKV_includes_unmeasured_RoPE_and_launch':True,'full_Encoder_cost':'UNKNOWN','complete_parent_or_kind7':False,'gate':'OPEN'}

def peer_binding(data):
 fi=read(data/'manifest.json');assert fi['metadata_count']==120
 transport=fi['schema']=='m007-r007-binary-production-transport-fixtures-v1'
 if transport:
  assert fi['new_floating_gold_or_model_run_or_full120_pack']is False and fi['load_count']==8 and 0<fi['record_count']<=4096
 else:
  assert fi['new_F32_gold_or_model_run']is False and fi['all120_first_tail_each4ports']is True and len(fi['crosschecked_existing_W576_tensors'])==8
  assert 0<fi['request_count']<=4096 and 0<fi['expected_64B_words']<=65536
 for name,row in fi['files'].items():assert sha(data/name)==row['sha256']and(data/name).stat().st_size==row['bytes']
 package=Path(fi['package']);assert sha(package/'manifest.json')==fi['package_manifest_sha256']=='46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
 original=read(package/'manifest.json');source_stats={}
 for name,row in fi['original_BO_metadata'].items():
  assert row==original['bo'][name];q=package/row['file'];stat=q.stat();assert stat.st_size==row['size']
  with q.open('rb')as stream:assert len(stream.read(1))==1
  source_stats[name]={'path':str(q.relative_to(ROOT)),'bytes':stat.st_size,'mtime_ns':stat.st_mtime_ns,'sha256_inherited':row['sha256'],'full_file_rehashed_here':False}
 raw=Path(fi['original_GGUF']);assert raw.stat().st_size==original['source_model']['size']and fi['original_GGUF_SHA_inherited']==original['source_model']['sha256']
 return {'schema':'m007-r007-binary-peer-input-binding-v1','fixture_manifest':str((data/'manifest.json').relative_to(ROOT)),'fixture_manifest_sha256':sha(data/'manifest.json'),'fixture_hex':fi['files'],'source_BO':source_stats,'original_GGUF_SHA_inherited':fi['original_GGUF_SHA_inherited'],'new_floating_gold_or_full120_pack':False,'plusargs':{'PEER_META':str(data/'metadata.hex'),'MODEL_PACKAGE':str(package),'PEER_DATA':str(data),**({'LOADS':fi['load_count'],'RECORDS':fi['record_count']}if transport else{'REQUESTS':fi['request_count'],'WORDS':fi['expected_64B_words']})}}

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','build-off','rtl','audit']);p.add_argument('attempt');p.add_argument('--checkpoint',type=Path);p.add_argument('--build',type=Path);p.add_argument('--top',choices=['m007_fullmodel_parent_tb','m007_w_reader_transport_v2_tb','m007_quant_A_cancel_r007_tb','m007_fullmodel_joint_tb','m007_fullmodel_encoder_tb','m007_binary_weight_peer_unit_tb','m007_binary_weight_transport_tb','m007_fullmodel_encoder_1d_tb'],default='m007_fullmodel_parent_tb');p.add_argument('--timeout',type=int,default=120);p.add_argument('--mode',type=int,choices=range(9),default=0);p.add_argument('--rows',type=int,choices=[16,128],default=16);p.add_argument('--pilot',type=Path);p.add_argument('--parent-only',action='store_true');p.add_argument('--debug',choices=['typical','off'],default='typical');p.add_argument('--qkv-blocks',type=int,choices=[0,1,3,48],default=3);p.add_argument('--heads',type=int,choices=[0,1,2],default=0);p.add_argument('--qkv-head-segments',action='store_true');a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 cat='rtl'if a.stage=='rtl'else'static';timeout=a.timeout;
 assert 0<timeout<=(1650 if a.qkv_head_segments else 1200)
 if timeout>120 and a.stage=='build':
  assert timeout<=300
  basis=read(R/'attempts/AT011_service_declaration_closure_build/receipt_static.json');assert basis['wall_s']>60
  assert 'Built simulation snapshot m007_fullmodel_sim' in(R/'attempts/AT011_service_declaration_closure_build/guard_static/driver.log').read_text()
 used=costs();assert Decimal(timeout)<=Decimal(CAP[cat])-used[cat]
 assert cat!='rtl'or Decimal(CAP['rtl'])-used['rtl']>=timeout+400
 gate=None
 if a.qkv_head_segments:
  assert a.stage=='rtl'and a.mode==8 and a.qkv_blocks==0 and a.heads==1 and a.build and a.pilot
  gate=qkv_head_gate(a.build.resolve(),a.pilot.resolve(),used,timeout)
 elif a.stage=='rtl'and a.mode==7 and a.rows==128:
  assert a.build and a.pilot;gate=ln128_gate(a.build.resolve(),a.pilot.resolve(),used,timeout)
 elif a.stage!='build':assert timeout<=120,'unmeasured RTL/audit must remain <=120s'
 # Caller has already received actual resource handoff; no speculative queued EDA.
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  at=R/'attempts'/a.attempt;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir();shutil.copy2(Path(__file__),at/'actual_orchestrator.py')
  if gate:dump(at/'actual_cost_gate.json',gate)
  if a.stage=='build':
   if a.top not in ['m007_w_reader_transport_v2_tb','m007_binary_weight_peer_unit_tb','m007_binary_weight_transport_tb']:
    assert a.checkpoint;admitted=dependency(a.checkpoint.resolve());chosen=selected(admitted)
   elif a.top=='m007_w_reader_transport_v2_tb':
    admitted=None;chosen={q.name:(q,'standalone real W transport')for q in [M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv',M/'hbm_loader_and_cache/tb/m007_w_reader_transport_v2_tb.sv',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',Path(__file__)]}
   else:
    assert timeout<=120 and a.debug=='off'
    admitted=None;chosen={q.name:(q,'standalone §17 integer-byte AXI peer and independent GGUF fixture generator')for q in [M/'forward_controller/tb/m007_binary_weight_peer_tb.sv',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py',S/'prepare_binary_weight_peer_r007.py',R/'protocol.md',Path(__file__)]}
   if a.top=='m007_binary_weight_transport_tb':
    for q in [M/'forward_controller/tb/m007_binary_weight_transport_tb.sv',M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv',M/'hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv',M/'hbm_loader_and_cache/rtl/laya_m007_w_bank_v1.sv',S/'prepare_binary_transport_fixture_r007.py']:
     chosen[q.name]=(q,'current production W reader/cache and independent original-GGUF transport fixtures')
   for name,(q,why)in chosen.items():shutil.copy2(q,f/name)
   dump(at/'source_manifest.json',{'top':a.top,'xelab_debug':a.debug,'host':socket.gethostname(),'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','bundle_evidence':admitted,'files':[{'frozen':name,'source':str(q.relative_to(ROOT)),'sha256':sha(f/name),'why':why}for name,(q,why)in chosen.items()]})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
   snapshot='m007_fullmodel_joint_sim'if a.top=='m007_fullmodel_joint_tb'else'm007_fullmodel_sim'
   cmd1=[str(VIV/'xvlog'),'--sv',*[str(q)for q in sorted(f.iterdir(),key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))if q.suffix in ['.sv','.v']]]
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join(cmd1)+'\n'+shlex.join([str(VIV/'xelab'),'work.'+a.top,'--relax','-debug',a.debug,'-mt','4','--O3','-s',snapshot])+'\n'+shlex.join([str(VIV/'xsim'),snapshot,'-tclbatch',str(hier)])+'\necho M007_FULLMODEL_BUILD_PASS\n')
   if a.top in ['m007_binary_weight_peer_unit_tb','m007_binary_weight_transport_tb']:
    generator='prepare_binary_transport_fixture_r007.py'if a.top=='m007_binary_weight_transport_tb'else'prepare_binary_weight_peer_r007.py'
    text=script.read_text();text=text.replace(shlex.join([str(VIV/'xsim'),snapshot,'-tclbatch',str(hier)])+'\n','')
    text=text.replace('set -euo pipefail\n','set -euo pipefail\n'+shlex.join([sys.executable,str(f/generator),'--root',str(ROOT),'--out',str(w/'fixture')])+'\n',1);script.write_text(text)
   if a.top=='m007_fullmodel_encoder_1d_tb':
    prep=read(R/'encoder_1d_compat_source_preparation.json');assert prep['baseline_reconstructed_exactly']is True and sha(f/'m007_fullmodel_encoder_1d_tb.sv')==prep['sha256']
   if a.top=='m007_fullmodel_encoder_tb':
    prep=read(R/'full_encoder_checker_source_preparation.json');assert sha(f/'m007_fullmodel_encoder_tb.sv')==prep['source_sha256']
    text=script.read_text();text=text.replace('set -euo pipefail\n','set -euo pipefail\n'+shlex.join([sys.executable,str(S/'prepare_full_encoder_inputs_r007.py')])+'\n',1);script.write_text(text)
   if a.top=='m007_fullmodel_parent_tb'and not a.parent_only:
    text=script.read_text();needle='\necho M007_FULLMODEL_BUILD_PASS\n'
    extra=shlex.join([str(VIV/'xelab'),'work.m007_type29_joint_tb','--relax','-debug',a.debug,'-mt','4','--O3','-s','m007_type29_joint_sim'])
    extra+='\n'+shlex.join([str(VIV/'xelab'),'work.m007_fullmodel_joint_tb','--relax','-debug',a.debug,'-mt','4','--O3','-s','m007_fullmodel_joint_sim'])
    assert needle in text;script.write_text(text.replace(needle,'\n'+extra+needle))
   cmd=['/bin/bash',str(script)];marker='M007_FULLMODEL_BUILD_PASS'
  elif a.stage=='build-off':
   assert a.build and timeout<=120;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'
   bm=read(b/'source_manifest.json');assert bm['top']=='m007_fullmodel_parent_tb'
   for row in bm['files']:
    q=b/'frozen'/row['frozen'];assert sha(q)==row['sha256'];shutil.copy2(q,f/q.name)
   shutil.copytree(b/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   dump(at/'source_manifest.json',{'top':bm['top'],'configuration_only_from':str(b.relative_to(ROOT)),'base_manifest_sha256':sha(b/'source_manifest.json'),'single_variable':'xelab -debug typical -> off; original O3/mt4/relax/HDL/TB unchanged','files':bm['files']})
   script=w/'build_off.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([str(VIV/'xelab'),'work.m007_fullmodel_parent_tb','--relax','-debug','off','-mt','4','--O3','-s','m007_fullmodel_sim'])+'\necho M007_FULLMODEL_BUILD_OFF_PASS\n')
   cmd=['/bin/bash',str(script)];marker='M007_FULLMODEL_BUILD_OFF_PASS'
  elif a.stage=='audit':
   assert a.build;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'
   for q in [S/'audit_fullmodel_census_r007.py',S/'prepare_fullmodel_joint_r007.py',M/'forward_controller/tb/m007_fullmodel_wall_driver.py',M/'forward_controller/tb/m007_parent_guard_v2.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']:
    shutil.copy2(q,f/q.name)
   dump(at/'source_manifest.json',{'compiled_build':str(b.relative_to(ROOT)),'build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
   shutil.copytree(b/'work/xsim.dir',w/'xsim.dir')
   for q in(b/'frozen').glob('*.dat'):shutil.copy2(q,w/q.name)
   tcl=w/'objects.tcl';tcl.write_text('set o [open canonical_objects.txt w]\nforeach obj [get_objects -r /m007_fullmodel_parent_tb/dut/matrix/*canonical*] {puts $o $obj}\nforeach obj [get_objects -r /m007_fullmodel_parent_tb/dut/matrix/*legacy*] {puts $o $obj}\nclose $o\nquit\n')
   script=w/'audit.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([str(VIV/'xsim'),'m007_fullmodel_sim','-tclbatch',str(tcl)])+'\n'+shlex.join([sys.executable,str(f/'audit_fullmodel_census_r007.py'),'--build',str(b),'--out',str(w)])+'\n')
   cmd=['/bin/bash',str(script)];marker='M007_FULLMODEL_CENSUS_PASS'
  else:
   assert a.build;b=a.build.resolve();assert read(b/'receipt_static.json')['verdict']=='PASS'
   for row in read(b/'source_manifest.json')['files']:assert sha(b/'frozen'/row['frozen'])==row['sha256']
   for q in(b/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   if a.qkv_head_segments:shutil.copy2(M/'forward_controller/tb/m007_parent_guard_v3_segment.py',f/'m007_parent_guard_v3_segment.py')
   shutil.copytree(b/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   dump(at/'source_manifest.json',{'compiled_build':str(b.relative_to(ROOT)),'build_manifest_sha256':sha(b/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]})
   if read(b/'source_manifest.json')['top']in ['m007_binary_weight_peer_unit_tb','m007_binary_weight_transport_tb']:
    binding=peer_binding(b/'work/fixture');dump(at/'binary_peer_input_binding.json',binding)
    cmd=[str(VIV/'xsim'),'m007_fullmodel_sim','-runall']
    for k,v in binding['plusargs'].items():cmd+=['-testplusarg',k+'='+str(v)]
    marker='M007_BINARY_W_TRANSPORT'if read(b/'source_manifest.json')['top']=='m007_binary_weight_transport_tb'else'M007_BINARY_WEIGHT_PEER'
   else:
    products=read(R/'input_products.json');
    for row in products['files']:
     assert sha(ROOT/row['source'])==row['source_sha256']
     if 'serialized'in row:assert sha(ROOT/row['serialized'])==row['serialized_sha256']
    dump(at/'input_products.json',products)
    att=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'
    h=ROOT/next(x['source']for x in products['files']if x.get('role')=='original H0 groups serialization')
    cmd=[str(VIV/'xsim'),'m007_fullmodel_sim','-runall','-testplusarg','MODE='+str(a.mode),'-testplusarg','DATA='+str(R/'data'),'-testplusarg','ROPE='+str(att),'-testplusarg','H='+str(h)]
    if a.mode in [5,8]:
     matrix=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
     cmd+=['-testplusarg','MATRIX='+str(matrix)]
     dump(at/'matrix_input_identity.json',{'files':[{'path':str(q.relative_to(ROOT)),'sha256':sha(q)}for q in sorted((matrix/'qkv_0_weight').glob('*.hex'))]})
    marker=['M007_FULLMODEL_ABI','M007_FULLMODEL_SETUP','M007_FULLMODEL_CATALOG_DRAIN','M007_FULLMODEL_CRC','M007_FULLMODEL_H_CATALOG_PREFIX','M007_FULLMODEL_QKV_PREFIX','TYPE29_JOINT','JOINT23','M007_FULLMODEL_NORMAL_PREFIX'][a.mode]
    if a.mode==8:
     assert (a.qkv_blocks==0)!=(a.heads==0),'exactly one normal-chain prefix boundary'
     refs=[att/('encoder0_'+name+'.mem')for name in ['pre_qkv','post_qkv','score','maximum','prob','context']]
     dump(at/'normal_chain_input_identity.json',{'original_B1_mask128':'00000000000000ffffffffffffffffff','files':[{'path':str(q.relative_to(ROOT)),'sha256':sha(q)}for q in refs],'scope':'normal parent autonomous single BEGIN to selected actual prefix; no forced state, no intermediate gold injection','stop_QKV_blocks':a.qkv_blocks,'stop_heads':a.heads,'unmeasured':['WO','residual/LN-to-FFN','Wi/G/Down','final H export'],'complete_Encoder_or_model':False})
     cmd+=['-testplusarg','STOP_QKV_BLOCKS='+str(a.qkv_blocks),'-testplusarg','STOP_AFTER_HEAD='+str(a.heads)]
     if a.heads:marker='M007_FULLMODEL_HEAD_PREFIX'
     cmd=[sys.executable,str(f/'m007_fullmodel_wall_driver.py'),'--events',str(w/'wall_events.json'),'--',*cmd]
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
     dump(at/'joint_input_identity.json',{'files':{k:{'path':str(v.relative_to(ROOT)),'sha256':sha(v)}for k,v in files.items()},'source_adapter':read(R/'joint_adapter_source.json'),'scope':'same closure G/residual128/LN'+str(a.rows)+' actual composition checker; final A is Attention owner return only'})
     cmd=[str(VIV/'xsim'),'m007_fullmodel_joint_sim','-runall','-testplusarg','MODE=0','-testplusarg','ROWS='+str(a.rows),'-testplusarg','PROGRESS_FILE='+str(w/'joint_semantic_progress.jsonl'),'-testplusarg','TRACE_FILE='+str(w/'joint_trace.jsonl')]
     for k,v in files.items():cmd+=['-testplusarg',k+'='+str(v)]
     cmd=[sys.executable,str(f/'m007_fullmodel_wall_driver.py'),'--events',str(w/'wall_events.json'),'--',*cmd]
    if read(b/'source_manifest.json')['top']in ['m007_fullmodel_encoder_tb','m007_fullmodel_encoder_1d_tb']:
     if read(b/'source_manifest.json')['top']=='m007_fullmodel_encoder_1d_tb':assert a.qkv_blocks==1 and timeout<=60,'one bounded QKV1 compatibility baseline only'
     assert a.qkv_blocks in [1,3]and a.heads==0 and timeout<=120,'new complete checker initial pilots only; full Encoder cost remains UNKNOWN'
     binding=read(R/'full_encoder_input_binding.json')
     for row in binding['inputs']:assert sha(ROOT/row['path'])==row['sha256']
     fi=ROOT/binding['existing_FFN_manifest'];assert sha(fi)==binding['existing_FFN_manifest_sha256']
     for row in read(fi)['files']:assert sha(fi.parent/row['frozen'])==row['sha256']
     dump(at/'full_encoder_input_binding.json',binding)
     cmd=[str(VIV/'xsim'),'m007_fullmodel_sim','-runall']
     for k,v in binding['candidate_plusargs'].items():cmd+=['-testplusarg',k+'='+v]
     cmd+=['-testplusarg','KIND=5','-testplusarg','PACKED=0','-testplusarg','STOP_QKV_BLOCKS='+str(a.qkv_blocks),'-testplusarg','STOP_AFTER_HEAD=0','-testplusarg','STOP_FFN_BLOCKS=0','-testplusarg','STOP_DOWN_BLOCKS=0','-testplusarg','EXPORT='+str(w/'actual_public')]
     marker='M007_FULLMODEL_ENCODER0_QKV_PREFIX'
     cmd=[sys.executable,str(f/'m007_fullmodel_wall_driver.py'),'--events',str(w/'wall_events.json'),'--',*cmd]
    if read(b/'source_manifest.json')['top']=='m007_w_reader_transport_v2_tb':marker='M007_W_READER_TRANSPORT'
    if read(b/'source_manifest.json')['top']=='m007_quant_A_cancel_r007_tb':
     fixture=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
     source=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture'
     files=[fixture/'qkv_0_weight/a_write.hex',source/'qkv_0_weight/input.hex']
     dump(at/'cancel_input_identity.json',{'files':[{'path':str(q.relative_to(ROOT)),'sha256':sha(q)}for q in files],'scope':'real quant/DIV/A partial-fill cancellation and new-generation recovery, not forced parent ACANCEL branch'})
     cmd=[str(VIV/'xsim'),'m007_fullmodel_sim','-runall','-testplusarg','FIXTURE='+str(fixture),'-testplusarg','INPUT_FIXTURE='+str(source)];marker='M007_QUANT_A_CANCEL'
  guard_name='m007_parent_guard_v3_segment.py'if a.qkv_head_segments else'm007_parent_guard_v2.py'
  guard=[sys.executable,str(f/guard_name),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static'else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',cat]
  if a.qkv_head_segments:guard+=['--qkv-retire-seconds','1519','--post-qkv-seconds','120','--retirement-tail-seconds','10']
  if cat=='static':guard+=['--artifact-progress-root',str(w)]
  guard+=['--',*cmd]
  dump(at/('command_'+cat+'.json'),{'argv':guard,'lock_held_through_descendants':True,'used_before_seconds':{k:str(v)for k,v in used.items()},'mode':a.mode,'full_graph_authorized_by_command':False})
  rc=subprocess.call(guard,cwd=w);g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)^\s*(?:Fatal|ERROR|FATAL_ERROR):',log));ok=rc==0 and marker in log and not fatal
  if a.stage=='build'and a.top in ['m007_binary_weight_peer_unit_tb','m007_binary_weight_transport_tb']and ok:dump(at/'binary_peer_input_binding.json',peer_binding(w/'fixture'))
  receipt={'category':cat,'wall_s':g['elapsed_seconds'],'guard_exit':rc,'guard':g,'mode':a.mode,'marker':marker,'marker_found':marker in log,'verdict':'PASS'if ok else'FAIL'if fatal else'COST_STOP'if g['trigger']else'FAIL','full_graph':'NOT_RUN'}
  dump(at/('receipt_'+cat+'.json'),receipt)
  new=costs();dump(R/'budget_ledger.json',{'schema':'m007-r007-budget-v1','limits_seconds':CAP,'used_seconds':{k:str(v)for k,v in new.items()},'remaining_seconds':{k:str(Decimal(CAP[k])-v)for k,v in new.items()},'rtl_reserve_seconds':400,'old_run_budget_transferred':False})
  print(json.dumps({'attempt':a.attempt,'category':cat,'verdict':receipt['verdict'],'wall_s':receipt['wall_s'],'trigger':g['trigger']}),flush=True)
  return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
