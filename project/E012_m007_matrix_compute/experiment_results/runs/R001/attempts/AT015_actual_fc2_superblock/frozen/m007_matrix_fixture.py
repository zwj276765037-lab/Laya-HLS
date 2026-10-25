#!/usr/bin/env python3
"""Four local N64 current-reference cases; no DUT helper/output imports."""
import argparse,hashlib,importlib.util,json,shutil,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[7] if 'project/E002' in str(Path(__file__).resolve()) else None
REF_SHA='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identity(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def hexline(x):return x.tobytes()[::-1].hex()+'\n'
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();root=a.root.resolve();out=a.out;out.mkdir(parents=True,exist_ok=True)
 refp=root/'source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py';assert sha(refp)==REF_SHA
 spec=importlib.util.spec_from_file_location('m007_independent_full_reference',refp);ref=importlib.util.module_from_spec(spec);sys.modules[spec.name]=ref;spec.loader.exec_module(ref)
 eroot=root/'project/E002_Laya_HLS/experiment';norm=eroot/'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin';assert sha(norm)=='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
 old=eroot/'results/attention_rtl_repair_20261008/d2_cpu_full_official/matrix_fixture';reportp=old/'full_matrix_fixture_report.json';oldreport=json.loads(reportp.read_text());oldcases={x['name']:x for x in oldreport['cases']}
 mapping=json.loads((root/'source/m007_matrix_supply_map_20261021.json').read_text());manifestp=Path(mapping['manifest']['path']);assert sha(manifestp)==mapping['manifest']['sha256'];manifest=json.loads(manifestp.read_text())
 gguf=Path(mapping['remapped_source_model_path']);packed=root/'project/E011_m007_weight_supply/experiment_results/runs/R001/attempts/AT001_four_superblock_pack/work/fixtures'
 details=[]
 with gguf.open('rb') as gf:
  for ci,r in enumerate(mapping['records']):
   name=r['tensor'];k,n=r['K'],r['N'];gcount=k//32;s=81 if n==5248 else 0
   cols=(list(range(2592,2624))+list(range(5216,5248))) if n==5248 else list(range(64))
   rngrow=np.arange(128,dtype=np.int64)[:,None];rngk=np.arange(k,dtype=np.int64)[None,:]
   x=np.ldexp((((rngrow*131+rngk*17+ci*29)%1021-510).astype('<f4')/np.float32(512)),((rngrow*7+(rngk//32)*3+ci)%25-18).astype(np.int32)).astype('<f4')
   legacy_name=['qkv_full_b0','wi_full_b0','down_full_b1','decision_fc2_full_b1'][ci];legacy=oldcases[legacy_name];src=old/(legacy_name+'.source_f32.bin');assert sha(src)==legacy['files']['source_f32']['sha256'];assert legacy['weight']==name
   legacy_input=src.read_bytes();real_row0=int(legacy['row0']);real_rows=int(legacy['rows'])
   if ci==0:
    x=np.frombuffer(norm.read_bytes(),dtype='<f4').reshape(128,1024).copy();classification='ACTUAL_ENCODER0_QKV_128_ROWS';original_real_rows=list(range(128));original_batch=0
   else:
    x[real_row0:real_row0+real_rows]=np.frombuffer(legacy_input,dtype='<f4').reshape(real_rows,k);classification='MIXED_16_ORIGINAL_OPERATOR_ROWS_PLUS112_INDEPENDENT_DIAGNOSTIC_ROWS';original_real_rows=list(range(real_row0,real_row0+real_rows));original_batch=legacy['batch']
   aqb=b''.join(ref.quantize_rows(x[row:row+16]) for row in range(0,128,16));aq=np.frombuffer(aqb,dtype=ref.Q8_DTYPE).reshape(128,gcount)
   blocks=bytearray()
   for col in cols:
    gf.seek(r['tensor_descriptor']['source_offset']+34*col*gcount);blocks.extend(gf.read(34*gcount))
   wb=bytes(blocks);wq=np.frombuffer(wb,dtype=ref.Q8_DTYPE).reshape(64,gcount)
   bias=None;bias_source=None
   if ci==3:
    bd=next(t for t in manifest['tensors'] if t['name']=='head_fc2.0.bias');gf.seek(bd['source_offset']);raw_bias=gf.read(bd['source_bytes']);assert hashlib.sha256(raw_bias).hexdigest()==bd['source_sha256'];bias=np.frombuffer(raw_bias,dtype='<f4')[cols].copy();bias_source=bd
   expected,_=ref.q8_linear_full(aqb,wb,128,k,64,bias)
   d=out/name.replace('.','_');d.mkdir(exist_ok=True);(d/'source_f32.bin').write_bytes(x.tobytes());(d/'activation_q8.bin').write_bytes(aqb);(d/'weight_source_q8.bin').write_bytes(wb);(d/'expected_f32.bin').write_bytes(expected.tobytes())
   with (d/'a_write.hex').open('w') as f:
    for row in range(128):
     for g in range(gcount):
      block=aqb[34*(row*gcount+g):34*(row*gcount+g+1)];f.write((block[2:]+block[:2])[::-1].hex()+'\n')
   with (d/'a_record.hex').open('w') as f:
    for g in range(gcount):
     for m in range(8):
      qq=aq['q'][16*m:16*m+16,g].tobytes();ss=aq['scale'][16*m:16*m+16,g].tobytes();f.write((qq+ss)[::-1].hex()+'\n')
   with (d/'w_record.hex').open('w') as f:
    for g in range(gcount):
     for pp in range(4):f.write((wq['q'][16*pp:16*pp+16,g].tobytes()+wq['scale'][16*pp:16*pp+16,g].tobytes())[::-1].hex()+'\n')
   handles={key:(d/(key+'.hex')).open('w') for key in ['dot','converted','product','term','partial']};ps=np.zeros((128,64),dtype='<f4')
   for g in range(gcount):
    dot=aq['q'][:,g,:].astype(np.int32)@wq['q'][:,g,:].astype(np.int32).T
    cv=dot.astype('<f4');product=np.multiply(aq['scale'][:,g].astype('<f4')[:,None],wq['scale'][:,g].astype('<f4')[None,:],dtype=np.float32);term=np.multiply(cv,product,dtype=np.float32);ps=np.add(ps,term,dtype=np.float32)
    vectors={'dot':dot,'converted':cv,'product':product,'term':term,'partial':ps}
    for pp in range(4):
     for m in range(8):
      for key,value in vectors.items():handles[key].write(hexline(value[16*m:16*m+16,16*pp:16*pp+16].reshape(256)))
   for h in handles.values():h.close()
   if bias is not None:ps=np.add(ps,bias[None,:],dtype=np.float32)
   assert ps.tobytes()==expected.tobytes(),'trace versus current original q8_linear_full'
   with (d/'output.hex').open('w') as f:
    for row in range(128):
     for half in range(2):f.write(hexline(expected[row,32*half:32*half+32]))
   bvec=np.zeros(64,dtype='<f4') if bias is None else bias;(d/'bias.hex').write_text(''.join(hexline(np.asarray([z],dtype='<f4')) for z in bvec))
   oldexpectedp=old/(legacy_name+'.expected_f32.bin');assert sha(oldexpectedp)==legacy['files']['expected_f32']['sha256'];oldexpected=np.frombuffer(oldexpectedp.read_bytes(),dtype='<f4').reshape(real_rows,n)[:,cols]
   legacy_match=(x[real_row0:real_row0+real_rows].tobytes()==legacy_input)
   if legacy_match:assert expected[real_row0:real_row0+real_rows].tobytes()==oldexpected.tobytes(),'original local gold mismatch '+name
   layout=json.loads((packed/name.replace('.','_')/'layout.json').read_text())
   for pp in range(4):
    srcp=packed/name.replace('.','_')/f'p{pp}.bin';assert sha(srcp)==layout['ports'][pp]['sha256'];shutil.copy2(packed/name.replace('.','_')/f'p{pp}.hex',d/f'p{pp}.hex')
   meta={'case':ci,'tensor':name,'K':k,'N':n,'s':s,'columns':cols,'activation_classification':classification,'original_model_real_rows':original_real_rows,'original_batch':original_batch,'diagnostic_rows':[] if ci==0 else [r for r in range(128) if r not in original_real_rows],'original_norm128':identity(norm) if ci==0 else None,'original_local_input':identity(src),'legacy_case':legacy_name,'legacy_semantic_node':legacy['source'],'legacy_gold_exact_rows':real_rows if legacy_match else 0,'legacy_output':identity(oldexpectedp),'current_oracle_sha256':REF_SHA,'W_source_tensor_sha256_inherited':r['tensor_descriptor']['source_sha256'],'W_selected_raw_sha256':hashlib.sha256(wb).hexdigest(),'bias_source':bias_source,'E011_layout':layout,'files':[identity(z) for z in d.iterdir() if z.is_file()]}
   (d/'fixture.json').write_text(json.dumps(meta,indent=2)+'\n');details.append(meta)
 (out/'matrix_fixture_report.json').write_text(json.dumps({'scope':'four local original N64 operators; no whole-model gold','model_sha256_inherited':mapping['stored_source_model']['sha256'],'reference':identity(refp),'norm128':identity(norm),'original_fixture_report':identity(reportp),'cases':details},indent=2)+'\n')
 print('M007_MATRIX_FIXTURE_PASS cases=4 original_QKV_rows=128 original_other_operator_rows=16_each local_outputs=32768 group_checks='+str(sum(c['K']*256 for c in details)),flush=True)
if __name__=='__main__':main()
