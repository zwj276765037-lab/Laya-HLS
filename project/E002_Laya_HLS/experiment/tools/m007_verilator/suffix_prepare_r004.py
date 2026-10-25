#!/usr/bin/env python3
"""Freeze the A010 exact source closure for one D36 suffix build; do not compile."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent;RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path,required=True);p.add_argument('--attempt',required=True);a=p.parse_args();start=time.monotonic();assert not (RUN/'attempts'/a.attempt).exists(),'preserve prior attempt';src=json.loads(a.manifest.read_text());at=RUN/'attempts'/a.attempt;at.mkdir();work=at/'work';work.mkdir()
assert src['compile_source_count']==94 and src['formal_default_parameter']==0 and src['top_parameter']=={'VERIFY_POST_ENCODER27_H':1}
for z in src['compile_sources']+src['ROM_initialization_files']:
 q=ROOT/z['path'];assert sha(q)==z['sha256'],str(q)
top=ROOT/src['top_source'];assert sha(top)==src['top_sha256'] and 'endfinal_norm_seen' not in top.read_text()
assert src['input_hex']['roundtrip_actual_bytes_equal'];raw=RUN/'frozen_input/encoder27.actual.f32.bin';hexfile=RUN/'frozen_input/encoder27.actual.group32.hex';assert sha(raw)==src['input_actual_raw']['sha256'] and sha(hexfile)==src['input_hex']['sha256']
base=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts/AT010_kind6_public_abi';cfg=json.loads((base/'config.json').read_text());cfg['case']='D36_SEGMENTED_SUFFIX_'+src['variant'];mapping={Path(z['path']).name:ROOT/z['path'] for z in src['compile_sources']};assert len(mapping)==94;prior_sources=list(cfg['sources']);assert {Path(z).name for z in prior_sources}==set(mapping);cfg['sources']=[str(mapping[Path(z).name]) for z in prior_sources];cfg['plusargs']=[('+KIND=7' if q=='+KIND=6' else q.replace(str(base/'work'),str(work)) if q.startswith('+EXPORT=') else q) for q in cfg['plusargs']]+['+POST_ENCODER27_H='+str(hexfile)];cfg['verilator_flags']=[*cfg['verilator_flags'],'-GVERIFY_POST_ENCODER27_H=1'];cfg['marker']=src['required_marker']
extra=[a.manifest,Path(__file__),base/'config.json',raw,hexfile,RUN/'saved_actual_input_integrity.json',HERE/'runtime_fixed_batch_v1/verilated_timing.cpp',HERE/'runtime_fixed_batch_v1/manifest.json']
cfg['inputs']=list(dict.fromkeys([*cfg['inputs'],*map(str,extra)]));dump(at/'proposed_config.json',cfg);dump(at/'d36_source_binding.json',{'manifest_path':str(a.manifest),'manifest_sha256':sha(a.manifest),'variant':src['variant'],'top_source_sha256':src['top_sha256'],'parent_sha256':src['parent_sha256'],'scope':src['coverage'],'actual_input_hex':str(hexfile),'source_entry_default':0,'verification_parameter':1})
for z in src['ROM_initialization_files']:
 q=ROOT/z['path'];(work/q.name).symlink_to(q)
subprocess.run([sys.executable,str(HERE/'suffix_static_r004.py'),'prepare',a.attempt,'--config',str(at/'proposed_config.json')],cwd=ROOT,check=True)
elapsed=time.monotonic()-start;dump(at/'receipt_prepare.json',{'category':'static','verdict':'PASS' if elapsed<=120 else 'COST_STOP','stage':'source_bound_suffix_build_preparation','elapsed_seconds':elapsed,'guarded':False,'new_build_or_simulation':False});assert elapsed<=120
print(json.dumps({'attempt':a.attempt,'variant':src['variant'],'preparation_seconds':elapsed,'top_sha256':src['top_sha256'],'parent_sha256':src['parent_sha256']}))
