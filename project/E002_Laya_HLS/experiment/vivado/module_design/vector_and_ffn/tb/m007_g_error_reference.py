#!/usr/bin/env python3
"""Sparse input changes, evaluated by the frozen original F32/libm primitives.

Unchanged values remain the original AT007 products. No DUT observation is used.
Masks describe per-lane original numerical eligibility, not fabricated coverage.
"""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[7]
ORIGINAL=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work'
REF_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
NAMES=['x','gate','u','v','w','t','z','h','r','s','y','geglu']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def bits(x):return int(np.asarray(x,dtype='<f4').view('<u4'))
def f32(x):return np.asarray(x,dtype='<u4').view('<f4')[()]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 r=json.loads((ORIGINAL/'report.json').read_text());rp=ROOT/r['reference']['path'];assert sha(rp)==r['reference']['sha256']==REF_SHA
 spec=importlib.util.spec_from_file_location('frozen_original_g_error_ref',rp);ref=importlib.util.module_from_spec(spec);sys.modules[spec.name]=ref;spec.loader.exec_module(ref)
 original={}
 for name in NAMES:
  d=r['products'][name];src=ROOT/d['path'];assert sha(src)==d['sha256'];original[name]=np.fromfile(src,dtype='<f4').reshape(128,2624)
 cases={
  'gate_then_late_input':[(0,0,'gate',0x7f800000),(127,2623,'x',0x7f800000)],
  'gate_then_late_v':[(0,0,'gate',0x7f800000),(127,2623,'x',bits(np.float32(1e20)))],
  'gate_then_late_z':[(0,0,'gate',0x7f800000),(127,2623,'x',bits(np.float32(3e13)))],
  'gate_inverse_row':[(127,0,'gate',0x7f800000),(0,32,'gate',0x7f800000)],
 }
 reports={}
 for name,changes in cases.items():
  records=[];candidates=[];eval_counts=[335872]*8
  for row,column,field,value in changes:
   x=original['x'][row,column];gate=original['gate'][row,column]
   if field=='x':x=f32(value)
   else:gate=f32(value)
   with np.errstate(over='ignore',invalid='ignore'):
    u=ref.mul(f32(0x3d372713),x);v=ref.mul(u,x);w=ref.add(f32(0x3f800000),v);t=ref.mul(f32(0x3f4c422a),x);z=ref.mul(t,w)
    h=ref.libm_tanh(z);rr=ref.add(f32(0x3f800000),h);ss=ref.mul(f32(0x3f000000),x);y=ref.mul(ss,rr);g=ref.mul(y,gate)
   vals=[x,gate,u,v,w,t,z,h,rr,ss,y,g];finite=lambda a:bool(np.isfinite(a))
   xok=finite(x);uok=xok and finite(u);vok=uok and finite(v);wok=vok and finite(w);tok=xok and finite(t);ze=wok and tok;zok=ze and finite(z)
   ye=zok and finite(h)and finite(rr)and finite(ss);yok=ye and finite(y);ge=yok
   evals=[True,xok,uok,vok,xok,ze,ye,ge];checks=[xok,uok,vok,xok,ze,zok,zok,ye,ge,zok]
   rank_values=[x,u,v,w,t,z,y,g];bad=False;errors=[]
   for rank,(eligible,result)in enumerate(zip(evals,rank_values)):
    eval_counts[rank]-=int(not eligible)
    if eligible and not finite(result):errors.append(rank);candidates.append((rank,row,column));bad=True
   assert bad,'case must actually exercise a reachable numerical failure'
   vector=(column//32)*512+row*4+(column%32)//8
   records.append({'row':row,'column':column,'scalar_index':row*2624+column,'vector_index':vector,'lane':column%8,'changed_field':field,'changed_bits':f'{value:08x}','original_bits':f'{bits(original[field][row,column]):08x}','fields':{key:f'{bits(vv):08x}'for key,vv in zip(NAMES,vals)},'node_check_mask':sum(int(vv)<<i for i,vv in enumerate(checks)),'rank_evaluated_mask':sum(int(vv)<<i for i,vv in enumerate(evals)),'local_numeric_error_ranks':errors,'output_bits':'00000000','output_status':6})
  first=min(candidates);expected_rank={'gate_then_late_input':0,'gate_then_late_v':2,'gate_then_late_z':5,'gate_inverse_row':7}[name];assert first[0]==expected_rank
  target=o/(name+'.hex')
  # 32-bit flattened index + 12 original fields + 16-bit node mask +
  # 16-bit rank-evaluated mask + 32-bit expected output + 32-bit status.
  target.write_text(''.join(f"{q['scalar_index']:08x}"+''.join(q['fields'][n]for n in NAMES)+f"{q['node_check_mask']:04x}{q['rank_evaluated_mask']:04x}{q['output_bits']}{q['output_status']:08x}\n"for q in records))
  reports[name]={'patch_count':len(records),'patch_file':target.name,'patch_sha256':sha(target),'patch_record_width_bits':512,'patches':records,'first_error':{'rank':first[0],'row':first[1],'column':first[2]},'expected_covered':[335872]*8,'expected_evaluated':eval_counts,'expected_error_outputs':len(records)}
  print('SPARSE_ORIGINAL_G_ERROR_REFERENCE',name,'first',first,flush=True)
 lib=Path('/lib/x86_64-linux-gnu/libm.so.6').resolve();assert sha(lib)==r['libm']['sha256']
 (o/'report.json').write_text(json.dumps({'schema':'m007-g-sparse-error-fixture-v1','status':'SPARSE_REFERENCE_COMPLETE','scope':'Only modified scalar inputs use frozen original primitive arithmetic; all other products are byte-reused AT007; not new full-model gold','original_report_sha256':sha(ORIGINAL/'report.json'),'reference_sha256':sha(rp),'libm_sha256':sha(lib),'field_order_msb_first':['scalar_index32',*NAMES,'node_check_mask16','rank_evaluated_mask16','expected_output32','expected_status32'],'cases':reports},indent=2)+'\n')
if __name__=='__main__':main()
