#!/usr/bin/env python3
"""Freeze D37 full normal input and the D36 fixed 94-source closure. No RTL run."""
import hashlib,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005'
BASE=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts/AT010_kind6_public_abi'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
start=time.monotonic();assert not RUN.exists(),'preserve independent R005/no retry'
at=RUN/'attempts/AT001_fixed_original30_build';work=at/'work';work.mkdir(parents=True)
manifest=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007/d36_final_gamma_suffix_source/rev2/fixed_source_manifest.json';source=json.loads(manifest.read_text())
assert source['compile_source_count']==94 and source['formal_default_parameter']==0
assert source['parent_sha256']=='9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6'
assert source['top_sha256']=='2bd73c51255634e190b0b1c288ccd7150852f555c229218a755d7989fa734f2a'
for z in source['compile_sources']+source['ROM_initialization_files']:assert sha(ROOT/z['path'])==z['sha256'],z['path']
cfg=json.loads((BASE/'config.json').read_text());mapping={Path(z['path']).name:ROOT/z['path'] for z in source['compile_sources']}
assert len(mapping)==94 and set(mapping)=={Path(z).name for z in cfg['sources']}
cfg['sources']=[str(mapping[Path(z).name]) for z in cfg['sources']]
cfg['case']='D37_FIXED_original30_once_BEGIN_original_initial_H_no_injection'
cfg['plusargs']=[('+KIND=7' if z=='+KIND=6' else z.replace(str(BASE/'work'),str(work)) if z.startswith('+EXPORT=') else z) for z in cfg['plusargs']]
cfg['verilator_flags']=[*cfg['verilator_flags'],'-GVERIFY_POST_ENCODER27_H=0']
cfg['marker']='HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1'
assert '+KIND=7' in cfg['plusargs'] and '+LAYER=0' in cfg['plusargs']
assert not any(z.startswith(('+POST_ENCODER27_H=','+STOP')) for z in cfg['plusargs'])
assert not any('STOP' in z or 'VERIFY_POST_ENCODER27_H=1' in z for z in cfg['verilator_flags'])
gold=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128'
fixture=Path(next(z.split('=',1)[1] for z in cfg['plusargs'] if z.startswith('+ORIGINAL_GRAPH=')))
initial=fixture/'initial_H.hex';packed=b''.join(int(z,16).to_bytes(128,'little') for z in initial.read_text().splitlines() if z.strip())
assert packed==(gold/'embedding_norm.f32.bin').read_bytes() and len(packed)==524288
expected=[gold/(f'encoder_{i:02d}_out.f32.bin' if i<28 else f'decision_{i-28:02d}_out.f32.bin') for i in range(30)]
cfg['inputs']=list(dict.fromkeys([*cfg['inputs'],str(manifest),str(Path(__file__)),*[str(z) for z in expected],str(gold/'embedding_norm.f32.bin'),str(gold/'final_norm.f32.bin'),str(gold/'type_add.f32.bin')]))
dump(at/'proposed_config.json',cfg)
for z in source['ROM_initialization_files']:
 q=ROOT/z['path'];(work/q.name).symlink_to(q)
contract=ROOT/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md';text=contract.read_text();frozen=at/'frozen';frozen.mkdir();(frozen/'D37_contract.md').write_text(text[text.index('## D-M007-SM012-FIXED-ORIGINAL30-37'):]);(frozen/'AGENTS.md').write_bytes((ROOT/'AGENTS.md').read_bytes())
dump(RUN/'budget_authorization.json',{'decision':'D-M007-SM012-FIXED-ORIGINAL30-37','scope':'FIXED_ORIGINAL30_ONCE_BEGIN','limits_seconds':{'reference':0,'static':1800,'rtl':15600,'rtl_reserve':600,'ooc':0,'single_full_run':15000,'layer':600,'continuous_stage':120,'semantic_stall':120,'supported_fresh_build':600,'unknown_static_batch':120},'prior_balance_transferred':False,'full_run_once_only':True,'after_completion':'paused'})
dump(RUN/'cost_plan.json',{'planning_only_not_new_measurement':True,'D35_actual_prefix_seconds':9085.828054456972,'D36_actual_suffix_seconds':710.2027710779803,'planned_seconds':1.35*(9085.828054456972+710.2027710779803)+180,'single_run_cap':15000,'static_scale_baseline':{'cpp_count':741,'cpp_bytes':268284937,'allowed_factor':1.15},'supported_static_fresh_build_cap_seconds':600})
dump(at/'fixed_source_full_parameter_binding.json',{'source_manifest':identify(manifest),'parent_sha256':source['parent_sha256'],'top_sha256':source['top_sha256'],'compile_source_count':94,'source_default_parameter':0,'actual_requested_parameter':{'VERIFY_POST_ENCODER27_H':0},'original_initial_H':identify(initial),'original_embedding_norm':identify(gold/'embedding_norm.f32.bin'),'public_initial_H_roundtrip_exact':True,'no_saved_H_input_or_STOP_or_layer_jump':True})
subprocess.run([sys.executable,str(HERE/'fixed30_static_r005.py'),'prepare',at.name,'--config',str(at/'proposed_config.json')],cwd=ROOT,check=True)
elapsed=time.monotonic()-start;dump(at/'receipt_prepare.json',{'category':'static','verdict':'PASS' if elapsed<=120 else 'COST_STOP','stage':'freeze_repaired_full30_source_inputs_and_parameters','elapsed_seconds':elapsed,'guarded':False});assert elapsed<=120
print(json.dumps({'prepared':str(at),'source_count':94,'parameter':0,'elapsed_seconds':elapsed}),flush=True)
