#!/usr/bin/env python3
"""Invoke frozen independent FP32 CPU reference for one exact saved Encoder0 G."""
import argparse,contextlib,ctypes,hashlib,importlib.util,io,json,os,platform,runpy,sys,time
from pathlib import Path
import numpy as np
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R004'
ORIG=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work'
MATRIX=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
REF=ROOT/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py'
REF_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def identity(p):return {'path':str(p.relative_to(ROOT))if p.is_relative_to(ROOT)else str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def load_reference():
 assert sha(REF)==REF_SHA
 spec=importlib.util.spec_from_file_location('frozen_original_ffn_cpu_reference',REF);ref=importlib.util.module_from_spec(spec);sys.modules[spec.name]=ref;spec.loader.exec_module(ref);return ref
def inputs():
 r=json.loads((ORIG/'report.json').read_text());assert r['status']=='ORIGINAL_LOCAL_REFERENCE_COMPLETE'and r['real_rows']==128
 ids={'original_report':identity(ORIG/'report.json'),'reference':identity(REF)};data={}
 for name in ['norm_ff','wi','geglu','attention_residual']:
  d=r['products'][name];p=ROOT/d['path'];assert sha(p)==d['sha256'];ids[name]=identity(p);data[name]=p.read_bytes()
 for name,folder in [('wi_weight','mlp_wi_0_weight'),('down_weight','mlp_wo_0_weight')]:
  path=MATRIX/folder;desc=json.loads((path/'fixture.json').read_text());p=path/'original_weight_q8.bin';assert sha(p)==desc['tensor_source']['source_sha256'];ids[name]=identity(p);ids[name+'_descriptor']=identity(path/'fixture.json');data[name]=p.read_bytes()
 ids['supply_map']=identity(ROOT/'source/m007_matrix_supply_map_20261021.json')
 return ids,data
def runtime(o):
 out=io.StringIO()
 with contextlib.redirect_stdout(out):np.show_config()
 (o/'numpy_build_config.txt').write_text(out.getvalue())
 libm=Path('/usr/lib/x86_64-linux-gnu/libm.so.6');lib=ctypes.CDLL(str(libm));lib.fegetround.restype=ctypes.c_int;assert lib.fegetround()==0
 smallest=np.array([1],dtype='<u4').view('<f4');assert np.add(smallest,np.float32(0),dtype=np.float32).view('<u4')[0]==1
 core=Path(np.core._multiarray_umath.__file__).resolve()
 return {'python_version':platform.python_version(),'python_executable':identity(Path(sys.executable).resolve()),'numpy_version':np.__version__,'numpy_core':identity(core),'numpy_build_config':identity(o/'numpy_build_config.txt'),'libm':identity(libm),'fegetround':lib.fegetround(),'f32_subnormal_add_preserved':True,'new_compiler_invocation':False,'compile_flags':'No local reference compilation; invoke unchanged frozen Python/NumPy CPU oracle. Installed NumPy build configuration and shared object SHA recorded.','thread_env':{k:os.environ.get(k)for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','MKL_NUM_THREADS']}}
def console(o,state,stage,next_step):
 report={'execution_state':state,'current_task':'SM012 FFN-REFERENCE-18 E016/R004 local original Q8(G)/Down CPU reference','stage':stage,'blocker':None,'next_step':next_step,'runtime_id':'/root/m007_weight_supply_engineering','thread_id':None};p=o/'A010_report.json';save(p,report)
 scripts='/home/zwj/.codex/skills/research-agent/scripts';sys.path.insert(0,scripts);old=sys.argv;sys.argv=['console.py','report','--root',str(ROOT),'--agent','A010','--input',str(p)]
 log=io.StringIO()
 try:
  with contextlib.redirect_stdout(log):
   try:runpy.run_path(scripts+'/console.py',run_name='__main__')
   except SystemExit as e:
    if e.code not in [0,None]:raise
 finally:sys.argv=old
 (o/'console_report.log').write_text(log.getvalue())
def prepare(o,ref,data):
 console(o,'running','Authority/runtime and frozen-overlap checks in progress','One-row original G pilot, then measured128-row cost gate')
 folder=MATRIX/'mlp_wo_0_weight';row=112;source=np.frombuffer((folder/'source_f32.bin').read_bytes(),dtype='<f4').reshape(128,2624)[row:row+1]
 packed=ref.quantize_many(source);assert packed==ref.quantize_rows(source)
 old=(folder/'activation_q8.bin').read_bytes();assert packed==old[row*82*34:(row+1)*82*34]
 output=ref.q8_linear_full(packed,data['down_weight'],1,2624,1024)[0].tobytes();expected=(folder/'expected_f32.bin').read_bytes();assert output==expected[row*4096:(row+1)*4096]
 norm=np.frombuffer(data['norm_ff'],dtype='<f4').reshape(128,1024)[:1];qn=ref.quantize_many(norm);assert qn==ref.quantize_rows(norm)
 wi=ref.q8_linear_full(qn,data['wi_weight'],1,1024,5248)[0].tobytes();assert wi==data['wi'][:5248*4]
 overlaps={'existing_down_diagnostic_row':112,'existing_down_q8_groups_bitwise':82,'existing_down_output_f32_bitwise':1024,'original_AT007_norm_ff_to_Wi_row':0,'original_Wi_values_bitwise':5248,'scope':'Existing diagnostic row checks original oracle adaptation only; the newly generated Down uses actual AT007 G instead.'}
 for key,rel in [('existing_source','source_f32.bin'),('existing_q8','activation_q8.bin'),('existing_output','expected_f32.bin')]:overlaps[key]=identity(folder/rel)
 save(o/'overlap_checks.json',overlaps);return {'rows':0,'overlap_checks':overlaps}
def write_quant(o,name,source,packed,rows,groups):
 d=o/name;d.mkdir();(d/'activation_q8.bin').write_bytes(packed)
 q=np.frombuffer(packed,dtype=np.dtype([('scale','<f2'),('q','i1',(32,))])).reshape(rows,groups)
 (d/'codes_s8.bin').write_bytes(q['q'].tobytes());(d/'scales_f16.bin').write_bytes(q['scale'].tobytes())
 for group_major in [False,True]:
  order=((row,group)for group in range(groups)for row in range(rows))if group_major else((row,group)for row in range(rows)for group in range(groups))
  suffix='group_major'if group_major else'row_major'
  with(d/f'a_write_{suffix}.hex').open('w')as f:
   for row,group in order:
    record=packed[(row*groups+group)*34:(row*groups+group+1)*34];f.write((record[2:]+record[:2])[::-1].hex()+'\n')
 order=((row,group)for group in range(groups)for row in range(rows))if groups==82 else((row,group)for row in range(rows)for group in range(groups))
 with(d/'source_f32_groups.hex').open('w')as f:
  for row,group in order:f.write(source[row,32*group:32*group+32].tobytes()[::-1].hex()+'\n')
 return {'rows':rows,'K':groups*32,'groups':rows*groups,'code_count':rows*groups*32,'scale_format':'IEEE binary16 little-endian; no double-rounding of reciprocal','A_hex_packing':'MSB-first272bit, actual low256 q codes followed by half scale in high16','source_order':'group,row'if groups==82 else'row,group'}
def generate(o,ref,data,rows):
 events=[];begin=time.monotonic()
 def event(name,**values):
  x={'event':name,'elapsed_s':time.monotonic()-begin,**values};events.append(x);print(json.dumps(x),flush=True)
 g=np.frombuffer(data['geglu'],dtype='<f4').reshape(128,2624)[:rows];norm=np.frombuffer(data['norm_ff'],dtype='<f4').reshape(128,1024)[:rows]
 qg=ref.quantize_many(g);assert qg[:82*34]==ref.quantize_rows(g[:1]);event('original_G_quant_complete',groups=rows*82,codes=rows*2624)
 qn=ref.quantize_many(norm);assert qn[:32*34]==ref.quantize_rows(norm[:1]);event('original_norm_ff_quant_complete',groups=rows*32,codes=rows*1024)
 down=np.empty((rows,1024),dtype='<f4')
 for row0 in range(0,rows,16):
  count=min(16,rows-row0);tile=qg[row0*82*34:(row0+count)*82*34]
  down[row0:row0+count]=ref.q8_linear_full(tile,data['down_weight'],count,2624,1024)[0]
  event('original_Down_rows_complete',row0=row0,rows=count,completed_rows=row0+count,completed_f32=(row0+count)*1024)
 assert np.isfinite(down).all();meta={'g_quant':write_quant(o,'g_quant',g,qg,rows,82),'norm_ff_quant':write_quant(o,'norm_ff_quant',norm,qn,rows,32)}
 dd=o/'down';dd.mkdir();(dd/'expected_f32.bin').write_bytes(down.tobytes())
 with(dd/'output.hex').open('w')as f:
  for s in range(16):
   for row in range(rows):
    for half in range(2):f.write(down[row,64*s+32*half:64*s+32*half+32].tobytes()[::-1].hex()+'\n')
 wi=np.frombuffer(data['wi'],dtype='<f4').reshape(128,5248)[:rows]
 with(o/'wi_native_output.hex').open('w')as f:
  for s in range(82):
   for row in range(rows):
    for half in range(2):f.write(wi[row,32*s+2624*half:32*s+2624*half+32].tobytes()[::-1].hex()+'\n')
 weights={}
 for name,folder in [('wi','mlp_wi_0_weight'),('down','mlp_wo_0_weight')]:
  wd=o/(name+'_weights');wd.mkdir();weights[name]={}
  for port in range(4):
   src=MATRIX/folder/f'p{port}.bin';b=src.read_bytes();dst=wd/src.name;dst.write_bytes(b);weights[name][str(port)]={'source':identity(src),'output':identity(dst)}
 event('fixture_serialization_complete',down_f32=rows*1024)
 save(o/'stage_events.json',events)
 return {'rows':rows,'down_values':rows*1024,'quant':meta,'weights':weights,'events':events,'complete128':rows==128,'scope':'Original saved G/norm_ff input boundary; no new full-model/G computation or RTL result'}
def audit(o,ref,data):
 full=RUN/'attempts/AT003_full128_reference/work';pilot=RUN/'attempts/AT002_one_row_reference_pilot/work'
 target=full if(full/'report.json').exists()else pilot
 report=json.loads((target/'report.json').read_text());rows=report['rows'];assert report['status']=='PASS'and rows in [1,128]
 for d in report['outputs'].values():assert sha(ROOT/d['path'])==d['sha256']
 checks={}
 for name,width in [('g_quant',2624),('norm_ff_quant',1024)]:
  key='geglu'if name=='g_quant'else'norm_ff';x=np.frombuffer(data[key],dtype='<f4').reshape(128,width)[:rows]
  q=b''.join(ref.quantize_rows(x[r:r+16])for r in range(0,rows,16));packed=(target/name/'activation_q8.bin').read_bytes();assert q==packed
  shape=(rows,width)
  first=shape[1]//32*34;assert packed[:first]==(pilot/name/'activation_q8.bin').read_bytes()
  groups=shape[1]//32;lines=(target/name/'a_write_group_major.hex').read_text().splitlines();assert len(lines)==rows*groups
  for group in range(groups):
   for row in range(rows):
    b=q[(row*groups+group)*34:(row*groups+group+1)*34];assert lines[group*rows+row]==(b[2:]+b[:2])[::-1].hex()
  checks[name]={'scalar_tiled_vs_batched_quant_groups_bitwise':rows*groups,'codes':rows*shape[1],'half_scales':rows*groups,'A_group_major_records_bitwise':rows*groups,'full_vs_pilot_prefix_match':True if rows==128 else 'NOT_RUN_FULL128'}
 down=(target/'down/expected_f32.bin').read_bytes();assert down[:4096]==(pilot/'down/expected_f32.bin').read_bytes();lines=(target/'down/output.hex').read_text().splitlines();assert len(lines)==rows*32
 for s in range(16):
  for row in range(rows):
   for half in range(2):
    col=64*s+32*half;assert bytes.fromhex(lines[s*rows*2+row*2+half])[::-1]==down[(row*1024+col)*4:(row*1024+col+32)*4]
 checks['down']={'output_f32':rows*1024,'native_hex_records_bitwise':rows*32,'full_vs_pilot_first_row_bitwise':True if rows==128 else 'NOT_RUN_FULL128'}
 pr=json.loads((pilot.parent/'receipt.json').read_text());bound=1.35*128*pr['child_wall_s']+10
 gate={'schema':'m007-ffn-reference18-measured-cost-v1','pilot_attempt':pilot.parent.name,'pilot_receipt_sha256':sha(pilot.parent/'receipt.json'),'pilot_driver_sha256':pr['driver_sha256'],'pilot_guard_sha256':pr['guard_sha256'],'measured_pilot_child_wall_s':pr['child_wall_s'],'formula':'1.35*128*pilot_child_wall_s+10','full128_bound_s':bound,'contract_full128_cap_s':120,'decision':'ADMIT'if bound<=120 else'COST_STOP','full128_execution':'NOT_RUN'if rows==1 else'RUN','full128_rows':128 if rows==128 else 0,'actual_fixture_rows':rows,'note':'No original timeout extension, unmodified rerun, cheaper pilot or substitute arithmetic. Partial fixture scope is explicit.'}
 save(o/'cost_exit.json',gate)
 return {'rows':rows,'checks':checks,'cost_gate':gate,'audited_fixture':str(target.relative_to(ROOT)),'scope':'Actual available local fixture authority/serialization audit; full128 NOT_RUN when cost gate fails; no RTL result'}
def main():
 p=argparse.ArgumentParser();p.add_argument('--mode',choices=['prepare','pilot','full','audit'],required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);start=time.monotonic()
 ref=load_reference();ids,data=inputs();save(o/'input_identity.json',ids);rt=runtime(o)
 if a.mode=='prepare':result=prepare(o,ref,data)
 elif a.mode=='audit':result=audit(o,ref,data)
 else:result=generate(o,ref,data,1 if a.mode=='pilot' else 128)
 outputs={str(q.relative_to(o)):identity(q)for q in sorted(o.rglob('*'))if q.is_file()and q.name!='report.json'}
 report={'schema':'m007-ffn-original-local-reference-v1','status':'PASS','mode':a.mode,'driver':identity(Path(__file__).resolve()),'original_reference':identity(REF),'inputs':ids,'runtime':rt,**result,'outputs':outputs,'elapsed_s':time.monotonic()-start,'verdict':'LOCAL_CPU_REFERENCE_ONLY'}
 save(o/'report.json',report);print('M007_FFN_LOCAL_REFERENCE_PASS '+json.dumps({'mode':a.mode,'rows':result['rows'],'elapsed_s':report['elapsed_s']}),flush=True)
if __name__=='__main__':main()
