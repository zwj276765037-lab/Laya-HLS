from pathlib import Path
import argparse,hashlib,json,struct,importlib.util,sys
ROOT=Path(__file__).resolve().parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
prior=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work';r=json.loads((prior/'report.json').read_text())
h=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin';q=prior/'wo.bin';g=prior/'attention_residual.bin';ref=ROOT/r['reference']['path'];assert sha(ref)==r['reference']['sha256']
assert sha(h)=='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
assert sha(q)==r['products']['wo']['sha256'] and sha(g)==r['products']['attention_residual']['sha256']
spec=importlib.util.spec_from_file_location('orig_residual_reference',ref);mod=importlib.util.module_from_spec(spec);sys.modules[spec.name]=mod;spec.loader.exec_module(mod)
import numpy as np
actual=mod.add(np.fromfile(h,dtype='<f4').reshape(128,1024),np.fromfile(q,dtype='<f4').reshape(128,1024));assert np.asarray(actual,dtype='<f4').tobytes()==g.read_bytes(),'original CPU residual expression differs'
products={}
for n,f in [('H',h),('Q',q),('GOLD',g)]:
 data=f.read_bytes();assert len(data)==524288;out=a.output/(n+'.hex');out.write_text(''.join(f'{v:08x}\n'for(v,)in struct.iter_unpack('<I',data)));products[n]={'source':str(f.relative_to(ROOT)),'source_sha256':sha(f),'words':131072,'hex_sha256':sha(out)}
(a.output/'report.json').write_text(json.dumps({'status':'PASS','scope':'Original Encoder0 local H+WO; original reference add rechecked; serialization only, no new model gold','original_AT007_report_sha256':sha(prior/'report.json'),'reference_sha256':sha(ref),'products':products},indent=2)+'\n');print('ORIGINAL_RESIDUAL_FIXTURE_PASS words=131072 original_add_exact=1')
