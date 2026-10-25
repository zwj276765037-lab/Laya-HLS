#!/usr/bin/env python3
"""D36 read-only actual suffix interface capture and generated build identity gate."""
import argparse,hashlib,json,math,re,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004'
R2=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
p=argparse.ArgumentParser();p.add_argument('attempt');a=p.parse_args();at=RUN/'attempts'/a.attempt;obj=at/'work/obj';cfg=json.loads((at/'config.json').read_text());top='V'+cfg['top'];main=obj/(top+'__main.cpp');prior=R2/'AT010_kind6_public_abi/frozen'/main.name
assert not (at/'generated_build_inputs.json').exists(), 'preserve current derivation'
assert json.loads((at/'receipt_translate.json').read_text())['verdict']=='PASS'
text=prior.read_text();frozen=at/'frozen';frozen.mkdir(exist_ok=True);(frozen/(main.name+'.generated')).write_bytes(main.read_bytes())
assert text.count('topp->eval();')==1 and 'contextp->threads(1);' in text
header=(obj/(top+'___024root.h')).read_text()
for name in set(re.findall(r'topp->rootp->([A-Za-z0-9_]+)',text)):assert re.search(r'\b'+name+r'\b',header),name
main.write_text(text);(frozen/main.name).write_text(text)
cpp=sorted(obj.glob('*.cpp'));old=R2/'AT010_kind6_public_abi/work/obj';oldcpp=list(old.glob('*.cpp'))
scale={'verdict':'PASS' if len(cpp)<=math.ceil(len(oldcpp)*1.15) and sum(p.stat().st_size for p in cpp)<=sum(p.stat().st_size for p in oldcpp)*1.15 and max(p.stat().st_size for p in cpp)<=max(p.stat().st_size for p in oldcpp)*1.15 else 'FAIL','actual_cpp_count':len(cpp),'actual_cpp_bytes':sum(p.stat().st_size for p in cpp),'actual_max_cpp_bytes':max(p.stat().st_size for p in cpp),'baseline_cpp_count':len(oldcpp),'baseline_cpp_bytes':sum(p.stat().st_size for p in oldcpp),'baseline_max_cpp_bytes':max(p.stat().st_size for p in oldcpp),'allowed_factor':1.15}
dump(at/'generated_scale_gate.json',scale);assert scale['verdict']=='PASS',scale
fixed=R2/'AT004_fullgraph_fixedbatch_pilot';receipt=json.loads((fixed/'receipt_build.json').read_text());rt=receipt['new_runtime_object'];src=Path(rt['path']);assert receipt['verdict']=='PASS' and identify(src)==rt
runtime=obj/'verilated_timing.o';shutil.copy2(src,runtime);assert sha(runtime)==rt['sha256']
dump(at/'fixed_runtime_object_reuse.json',{'status':'VERIFIED_REUSE_OF_ACTUAL_PASS','original_build_receipt':identify(fixed/'receipt_build.json'),'original_runtime_object':rt,'copied_runtime_object':identify(runtime),'actual_runtime_source':identify(Path(__file__).parent/'runtime_fixed_batch_v1/verilated_timing.cpp'),'make_excludes_recompiling_verilated_timing_object':True,'same_VROOT_headers_and_flags_as_baseline_config':cfg['runtime_identity']})
paths=[*cpp,*obj.glob('*.h'),*obj.glob('*.mk'),runtime,Path(__file__),prior]
dump(at/'generated_build_inputs.json',{'sources_and_inputs':[identify(p) for p in paths],'read_only_observer_no_DUT_writes':True,'single_eval_per_iteration':True,'main_original_generic_all_layer_capture':identify(prior),'capture_endpoints':['global28','global29'],'finalLN_type_capture':'A010 TB actual commit-site final_norm/type_add files; original uniqueness and value checks retained','not_fullgraph_acceptance':True})
print(json.dumps({'derived_main':str(main),'scale':scale,'fixed_runtime_sha256':rt['sha256']}))
