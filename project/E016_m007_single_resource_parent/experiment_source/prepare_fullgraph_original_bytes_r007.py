#!/usr/bin/env python3
"""Serialize original checkpoints without floating evaluation or model execution."""
from pathlib import Path
import argparse,ctypes,hashlib,json,os,resource,time
ROOT=Path(__file__).resolve().parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 start=time.monotonic();parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,default=ROOT);parser.add_argument('--out',type=Path,required=True);a=parser.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));affinity=sorted(os.sched_getaffinity(0));nice=os.getpriority(os.PRIO_PROCESS,0);io=ctypes.CDLL(None).syscall(252,1,0);assert affinity and set(affinity)<=set(range(4))and nice==19 and io>>13==3
 available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')));assert available>192*1024*1024
 r=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';inventory=root/'results/reviews/m007_model_checkpoint_inventory_20261023.json';inv=json.loads(inventory.read_text());support=root/'source/m007_fullmodel_input_binding_20261023.json';binding=json.loads(support.read_text());assert inv['count']==inv['matches']==47
 original={};identities=[]
 for row in inv['rows']:
  p=Path(row['copied_path']);assert p.is_relative_to(root);data=p.read_bytes();assert len(data)==row['bytes']and hashlib.sha256(data).hexdigest()==row['sha256'];original[row['name']]=data;identities.append({'name':row['name'],'path':str(p.relative_to(root)),'bytes':len(data),'sha256':row['sha256'],'raw_SHA_rechecked_here':True})
 def serialize(name,data):
  assert len(data)%128==0;p=out/name
  with p.open('w')as stream:
   for offset in range(0,len(data),128):stream.write(data[offset:offset+128][::-1].hex()+'\n')
  return {'path':str(p.relative_to(root)),'sha256':sha(p),'groups128B':len(data)//128,'restored_raw_sha256':hashlib.sha256(data).hexdigest()}
 products={};products['H0']=serialize('initial_H.hex',original['embedding_norm']);names=[f'encoder_{i:02d}_out'for i in range(28)]+['final_norm','type_add','decision_00_out','decision_01_out'];products['checkpoint_gold']=serialize('checkpoints.hex',b''.join(original[n]for n in names));products['kind6_Decision0_public_H']=serialize('decision0_input.hex',original['type_add']);products['kind6_Decision1_public_H']=serialize('decision1_input.hex',original['decision_00_out'])
 tail=original['marker_gather']+original['decision_01_out'][:4096];merged=root/binding['tail_checker']['existing_merged_tail']['path'];assert merged.read_bytes()==tail;products['tail']=serialize('tail544.hex',tail)
 metadata=binding['metadata'];assert metadata['qtype']==2 and metadata['candidate_count']==2 and metadata['marker_mask16_lsb_is_slot0_hex']=='0003'
 source=r/'attempts/AT038_binary_weight_peer_byte_fixture_build/work/fixture';fi=json.loads((source/'manifest.json').read_text());assert sha(source/'metadata.hex')==fi['files']['metadata.hex']['sha256'];(out/'peer_metadata.hex').write_bytes((source/'metadata.hex').read_bytes())
 package=Path(fi['package']);pm=json.loads((package/'manifest.json').read_text());assert sha(package/'manifest.json')==fi['package_manifest_sha256'];ids={x['name']:i+1 for i,x in enumerate(pm['tensors'])};(out/'tensor_ids.hex').write_text(''.join(f"{ids[d['name']]:08x}\n"for d in fi['descriptors']))
 products['peer_metadata']={'path':str((out/'peer_metadata.hex').relative_to(root)),'sha256':sha(out/'peer_metadata.hex'),'descriptors':120};products['tensor_ids']={'path':str((out/'tensor_ids.hex').relative_to(root)),'sha256':sha(out/'tensor_ids.hex'),'count':120}
 result={'schema':'m007-r007-fullgraph-original-byte-binding-v1','status':'ORIGINAL_BYTES_SERIALIZED_NOT_COMPILED_NOT_RUN','original_inventory':str(inventory.relative_to(root)),'inventory_sha256':sha(inventory),'support_binding':str(support.relative_to(root)),'support_binding_sha256':sha(support),'original_checkpoints_47':identities,'checkpoint_gold_indices':{n:i for i,n in enumerate(names)},'products':products,'metadata':metadata,'package':str(package),'package_manifest_sha256':fi['package_manifest_sha256'],'original_BO_metadata':fi['original_BO_metadata'],'kind7_driver':'Only original embedding_norm H0 at the one public BEGIN; all later checkpoints are read-only expected bytes, never internal or repeated-layer producers','kind6_driver':'One public complete Decision component, layer0 type_add or layer1 decision_00_out original input; not evidence of its preceding producer or the once-BEGIN kind7 graph','FPGA_checkpoints':'30 layer residual endpoints + final_norm + type_add + initial input + tail544; remaining original47 CPU/embedding/scorer/ACT records are identity binding only','new_floating_evaluation_or_model_run_or_gold':False,'full120_weight_pack':False,'resource_policy':{'affinity':affinity,'nice':nice,'ioprio_encoded':io,'ioprio_class':io>>13,'initial_MemAvailable_KiB':available,'max_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'address_space_limit_B':1024**3},'wall_s':time.monotonic()-start}
 (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n');(r/'fullgraph_original_input_binding.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k]for k in ['status','FPGA_checkpoints','resource_policy','wall_s']}))
if __name__=='__main__':main()
