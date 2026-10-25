from pathlib import Path
import hashlib,json,struct
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R004/data';OUT.mkdir(parents=True,exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inventory=ROOT/'results/reviews/m007_model_checkpoint_inventory_20261023.json';rows=json.loads(inventory.read_text())['rows'];products={}
for name in ['final_norm','type_add']:
 e=next(x for x in rows if x['name']==name);p=Path(e['copied_path']);assert sha(p)==e['sha256'];data=p.read_bytes();assert len(data)==524288
 q=OUT/(name+'.words.hex');text=''.join(f'{x:08x}\n'for(x,)in struct.iter_unpack('<I',data));q.write_text(text);assert b''.join(struct.pack('<I',int(x,16))for x in text.splitlines())==data
 products[name]={'source':str(p.relative_to(ROOT)),'sha256':sha(p),'words_hex':str(q.relative_to(ROOT)),'hex_sha256':sha(q),'role':'PUBLIC_Q_COMPONENT_INPUT'if name=='final_norm'else'CHECKER_ONLY','word_count':131072}
t=ROOT/'project/E020_m007_model_catalog/experiment_results/runs/R001/attempts/AT002_host_fix/work/host/coefficients/type.f32.bin';assert sha(t)=='09c9cc40955fc14237f23e0c807f9381ebc2f1eb3ae8be1953e5d3a0446ca798';q=OUT/'type.words.hex';text=''.join(f'{x:08x}\n'for(x,)in struct.iter_unpack('<I',t.read_bytes()));q.write_text(text);assert b''.join(struct.pack('<I',int(x,16))for x in text.splitlines())==t.read_bytes()
products['type']={'source':str(t.relative_to(ROOT)),'sha256':sha(t),'words_hex':str(q.relative_to(ROOT)),'hex_sha256':sha(q),'role':'MODEL_SETUP_COEFFICIENTS','word_count':3072}
ir=ROOT/'project/E002_Laya_HLS/experiment/reference/runs/typed_q8_ref_20261005/abi_replay/native/forward_0/ir_215.bin';assert struct.unpack('<2i',ir.read_bytes())==(2,0)
m={'status':'PASS_SERIALIZATION_ONLY','qtype':2,'qtype_source':str(ir.relative_to(ROOT)),'qtype_sha256':sha(ir),'original_slice_evidence':'tests/full_forward_oracle.py request_inputs54–64/single_request69–80/B1 loop181–185','inventory_sha256':sha(inventory),'products':products,'arithmetic_or_newgold':False,'parent_previous28layer_producer':'NOT_PROVIDED component input only'};(OUT/'fixture_manifest.json').write_text(json.dumps(m,indent=2)+'\n');print('TYPE29_ORIGINAL_BIT_SERIALIZATION_PASS')
