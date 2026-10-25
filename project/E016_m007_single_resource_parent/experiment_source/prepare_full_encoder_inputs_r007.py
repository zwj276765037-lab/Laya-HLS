#!/usr/bin/env python3
"""Bind existing independent bytes to the source-only kind5 Encoder0 TB."""
from pathlib import Path
import hashlib,json,time

ROOT=Path(__file__).resolve().parents[3]
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def binary_groups_sha(p):
 h=hashlib.sha256();count=0
 for line in p.read_text().splitlines():
  if not line.strip():continue
  value=line.strip();assert len(value)==256
  h.update(int(value,16).to_bytes(128,'little'));count+=1
 assert count==4096
 return h.hexdigest()

def main():
 start=time.monotonic()
 prior=R.parent/'R006/attempts/AT016_CE_kind4_QKV1_minimum_math/command_rtl.json'
 argv=read(prior)['argv'];paths={}
 for i,arg in enumerate(argv[:-1]):
  if arg=='-testplusarg'and'='in argv[i+1]:
   key,value=argv[i+1].split('=',1)
   if key in ['ORIGINAL','MATRIX','INPUT','ATTENTION','CONTEXT','FFN','WI','DOWN','G','RESIDUAL']:paths[key]=Path(value)
 paths['DATA']=R/'data'
 inventory=ROOT/'results/reviews/m007_model_checkpoint_inventory_20261023.json';inv=read(inventory)
 assert inv['count']==inv['matches']==47
 original=[]
 for name in ['embedding_norm','encoder_00_out']:
  row=next(x for x in inv['rows']if x['name']==name)
  p=paths['ORIGINAL']/(name+'.groups1024.hex');digest=binary_groups_sha(p)
  assert digest==row['sha256']
  original.append({'name':name,'original_inventory_binary_sha256':row['sha256'],'serialized':str(p.relative_to(ROOT)),'serialized_sha256':sha(p),'restored_integer_bytes_sha256':digest,'F32_evaluated':False})
 assert binary_groups_sha(paths['INPUT']/'qkv_0_weight/input.hex')==original[0]['original_inventory_binary_sha256']
 ffn=R.parent/'R005/fixtures/manifest.json';fm=read(ffn)
 for row in fm['files']:assert sha(ffn.parent/row['frozen'])==row['sha256']
 norm_original=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/norm_ff.bin'
 assert binary_groups_sha(paths['FFN']/'norm_ff_quant/source_f32_groups.hex')==sha(norm_original)
 suffixes={
  'MATRIX':['qkv_0_weight/'+n for n in ['output.hex','pre_bias.hex','a_write.hex','p0.hex','p1.hex','p2.hex','p3.hex']],
  'CONTEXT':['wo_0_weight/'+n for n in ['output.hex','input.hex','pre_bias.hex','a_write.hex','p0.hex','p1.hex','p2.hex','p3.hex']],
  'ATTENTION':['mask.mem','cos_full.mem','sin_full.mem','cos_slide.mem','sin_slide.mem']+['encoder0_'+n+'.mem'for n in ['pre_qkv','post_qkv','score','maximum','prob','context']],
  'RESIDUAL':['GOLD.hex'],
  'DATA':['catalog.hex','bias.words.hex','gamma.words.hex','type.words.hex'],
 }
 files=[]
 for key,names in suffixes.items():
  for name in names:
   p=paths[key]/name;files.append({'flag':key,'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size})
 addresses=ROOT/'project/E020_m007_model_catalog/experiment_results/runs/R001/attempts/AT002_host_fix/work/host/sim_addresses.json';address=read(addresses)
 result={'schema':'m007-r007-full-Encoder-input-binding-v1','status':'SOURCE_AND_EXISTING_BYTE_BINDING_ONLY_NOT_COMPILED_NOT_RUN','source_checker':'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_fullmodel_encoder_tb.sv','original_47_inventory':str(inventory.relative_to(ROOT)),'original_47_inventory_sha256':sha(inventory),'bound_checkpoint_subset':original,'existing_FFN_manifest':str(ffn.relative_to(ROOT)),'existing_FFN_manifest_sha256':sha(ffn),'all_15_FFN_products_SHA_checked':True,'norm_FF_groups_restore_original_binary_sha256':sha(norm_original),'inputs':files,'candidate_plusargs':{k:str(v)for k,v in paths.items()},'weight_AR_source_bindings':address['records'][:4],'SIM_address_manifest_sha256':sha(addresses),'integer_mappings':{'QKV_WO_Down_output':'stream=256*s+2*row+half; col=64*s+32*half; H/Q address=32*row+col/32','Wi_native_output':'stream=256*s+2*row+half; col=32*s+2624*half; s=0..81; no0/41 reorder','G_vector':'vi=512*s+4*row+quarter; original scalar record=row*2624+32*s+8*quarter+lane','G_A1':'row-major independent group=row*82+s; actual quant uses original group-major arrival with those coordinates','final_H':'4096 real public groups at row=seq/32,col=32*(seq%32), exactly original encoder_00_out bytes','epochs':'input+0; QKV/context/WO+1; first residual+2; plainLN+3; Wi/G/Down+4; final residual+5; export+6'},'weight_response_rule':'On real AR acceptance latch phase,tensor-derived source,port(base is per-port),origin address,length and per-ID position; R uses latched bphase/bbase/baddr, never current parent descriptor or phase. Refills require actual W transport and old quant/context/scratch retirement.','producer_rule':'Only initial_h is public model input. Norm/WO/Wi/G/Down/final-H files are independent comparisons, never internal activation producers. Model coefficient stream is original setup data.','no_new_gold':True,'whole_Encoder_cost':'UNKNOWN','kind7':'Original30-layer production and real SIM tail writer preserved; this new checker is only kind5/layer0 and does not sign kind7.','source_byte_binding_wall_s':time.monotonic()-start}
 (R/'full_encoder_input_binding.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps({'status':result['status'],'bound_original_checkpoints':2,'file_identities':len(files),'FFN_products':15,'wall_s':result['source_byte_binding_wall_s']}))

if __name__=='__main__':main()
