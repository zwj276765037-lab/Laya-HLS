#!/usr/bin/env python3
"""Independent full-local matrix gold and lossless production W576 inputs."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
import numpy as np
REF_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ident(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);sys.modules[name]=m;s.loader.exec_module(m);return m
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True)
 refp=root/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py';assert sha(refp)==REF_SHA;ref=load('independent_original_full_local',refp)
 packp=Path(__file__).with_name('m007_weight_pack.py')
 if not packp.exists():packp=root/'project/E002_Laya_HLS/experiment/tools/m007_weight_pack.py'
 pack=load('lossless_production_w576_packer',packp)
 mapping=json.loads((root/'source/m007_matrix_supply_map_20261021.json').read_text());mp=Path(mapping['manifest']['path']);assert sha(mp)==mapping['manifest']['sha256'];manifest=json.loads(mp.read_text());tensors={t['name']:t for t in manifest['tensors']};weights={t['name']:t for t in manifest['weights']}
 base=root/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official';old=base/'matrix_fixture';oldp=old/'full_matrix_fixture_report.json';oldcases={c['name']:c for c in json.loads(oldp.read_text())['cases']}
 norm=base/'oracle/B1_from_b0_S128/embedding_norm.f32.bin';assert sha(norm)=='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
 cases=[('qkv.0.weight','qkv_full_b0'),('wo.0.weight','wo_full_b1'),('mlp_wi.0.weight','wi_full_b0'),('mlp_wo.0.weight','down_full_b1'),('head_fc1.0.weight','decision_fc1_full_b0'),('head_fc2.0.weight','decision_fc2_full_b1'),('head_qkv.0.weight','decision_qkv_full_b0'),('head_wo.0.weight','decision_wo_full_b1')]
 bos=[(mp.parent/manifest['bo'][key]['file']).open('rb') for key in ['w_q0','w_q1','w_scale']];details=[]
 with Path(mapping['remapped_source_model_path']).open('rb') as gf:
  for ci,(name,legacyname) in enumerate(cases):
   td=tensors[name];wd=weights[name];k,n=td['ggml_ne'][:2];groups=k//32;blocks=82 if n==5248 else n//64
   rr=np.arange(128,dtype=np.int64)[:,None];kk=np.arange(k,dtype=np.int64)[None,:]
   x=np.ldexp((((rr*131+kk*17+ci*29)%1021-510).astype('<f4')/np.float32(512)),((rr*7+(kk//32)*3+ci)%25-18).astype(np.int32)).astype('<f4')
   legacy=oldcases[legacyname];src=old/(legacyname+'.source_f32.bin');assert sha(src)==legacy['files']['source_f32']['sha256'];assert legacy['weight']==name
   row0=int(legacy['row0']);rows=int(legacy['rows']);sourcebytes=src.read_bytes()
   if ci==0:x=np.frombuffer(norm.read_bytes(),dtype='<f4').reshape(128,k).copy();realrows=list(range(128));classification='ACTUAL_ENCODER0_QKV_128_ROWS'
   else:x[row0:row0+rows]=np.frombuffer(sourcebytes,dtype='<f4').reshape(rows,k);realrows=list(range(row0,row0+rows));classification='16_ORIGINAL_OPERATOR_ROWS_PLUS112_INDEPENDENT_DIAGNOSTIC_ROWS'
   aqb=b''.join(ref.quantize_rows(x[r:r+16]) for r in range(0,128,16));gf.seek(td['source_offset']);wb=gf.read(td['source_bytes']);assert hashlib.sha256(wb).hexdigest()==td['source_sha256']
   bias=None;bd=None
   if wd['bias_name']:
    bd=tensors[wd['bias_name']];gf.seek(bd['source_offset']);bb=gf.read(bd['source_bytes']);assert hashlib.sha256(bb).hexdigest()==bd['source_sha256'];bias=np.frombuffer(bb,dtype='<f4').copy();assert len(bias)==n
   expected,_=ref.q8_linear_full(aqb,wb,128,k,n,bias)
   d=out/name.replace('.','_');d.mkdir();(d/'source_f32.bin').write_bytes(x.tobytes());(d/'activation_q8.bin').write_bytes(aqb);(d/'original_weight_q8.bin').write_bytes(wb);(d/'expected_f32.bin').write_bytes(expected.tobytes())
   (d/'a_write.hex').write_text(''.join((aqb[i+2:i+34]+aqb[i:i+2])[::-1].hex()+'\n' for i in range(0,len(aqb),34)))
   if bias is None:bvec=np.zeros(n,dtype='<f4')
   else:bvec=bias
   (d/'bias.hex').write_text(''.join(bvec[i:i+32].tobytes()[::-1].hex()+'\n' for i in range(0,n,32)))
   # Final output stored in actual s,row,32-column-half order. Wi halves retain original columns.
   with (d/'output.hex').open('w') as f:
    for s in range(blocks):
     cols=list(range(32*s,32*s+32))+list(range(2624+32*s,2624+32*s+32)) if n==5248 else list(range(64*s,64*s+64))
     for row in range(128):
      for h in range(2):f.write(expected[row,cols[32*h:32*h+32]].tobytes()[::-1].hex()+'\n')
   ports=[bytearray() for _ in range(4)];verified=0
   for s in range(blocks):
    p=pack.pack_superblock(gf,td['source_offset'],k,n,s)
    v=pack.verify_independent(p,gf,td['source_offset'],k,n,s,wd,bos);verified+=v['inverse_checked_bytes']
    for lane in range(4):ports[lane].extend(p[lane])
   for lane,b in enumerate(ports):
    (d/f'p{lane}.bin').write_bytes(b);(d/f'p{lane}.hex').write_text(''.join(b[i:i+64][::-1].hex()+'\n' for i in range(0,len(b),64)))
   oldexp=old/(legacyname+'.expected_f32.bin');assert sha(oldexp)==legacy['files']['expected_f32']['sha256'];legacy_match=x[row0:row0+rows].tobytes()==sourcebytes
   if legacy_match:assert expected[row0:row0+rows].tobytes()==oldexp.read_bytes()
   meta={'case':ci,'tensor':name,'K':k,'N':n,'G':groups,'superblocks':blocks,'bias_name':wd['bias_name'],'bias_source':bd,'tensor_source':td,'activation_classification':classification,'original_model_real_rows':realrows,'diagnostic_rows':[r for r in range(128) if r not in realrows],'original_local_input':ident(src),'original_legacy_gold':ident(oldexp),'legacy_exact_rows':rows if legacy_match else 0,'original_norm128':ident(norm) if ci==0 else None,'layout':'M007-W576-v1','packed_port_span':len(ports[0]),'inverse_and_old_bo_verified_bytes':verified,'files':[ident(p) for p in d.iterdir() if p.is_file()]}
   (d/'fixture.json').write_text(json.dumps(meta,indent=2)+'\n');details.append(meta);print('M007_FULL_FIXTURE_CASE_PASS case='+str(ci)+' tensor='+name+' final_values='+str(128*n),flush=True)
 for f in bos:f.close()
 (out/'full_matrix_fixture_report.json').write_text(json.dumps({'scope':'eight original local operators, six complete shape representatives and two bias variants; not whole-model gold','reference':ident(refp),'lossless_packer':ident(packp),'model_sha256_inherited':mapping['stored_source_model']['sha256'],'full_model_sha_recomputed':False,'manifest':ident(mp),'original_fixture_report':ident(oldp),'cases':details},indent=2)+'\n')
 print('M007_FULL_MATRIX_FIXTURE_PASS cases=8 final_values='+str(sum(128*c['N'] for c in details)),flush=True)
if __name__=='__main__':main()
