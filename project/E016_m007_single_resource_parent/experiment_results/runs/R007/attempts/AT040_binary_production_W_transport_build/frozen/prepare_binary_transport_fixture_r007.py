#!/usr/bin/env python3
"""Bounded production-cache records expected directly from original GGUF bytes."""
from pathlib import Path
import argparse,hashlib,json,mmap,time
ROOT=Path(__file__).resolve().parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--out',type=Path,required=True);a=p.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);start=time.monotonic()
 r=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';base=r/'attempts/AT038_binary_weight_peer_byte_fixture_build/work/fixture';old=json.loads((base/'manifest.json').read_text());package=Path(old['package']);manifest=json.loads((package/'manifest.json').read_text());assert sha(package/'manifest.json')==old['package_manifest_sha256'];metadata=base/'metadata.hex';assert sha(metadata)==old['files']['metadata.hex']['sha256'];(out/'metadata.hex').write_bytes(metadata.read_bytes())
 names={x['name']:i+1 for i,x in enumerate(manifest['tensors'])};fixture=root/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
 selections=[(0,0),(1,15),(2,81),(3,15),(112,47),(114,63),(115,15),(118,0)];expected=[];loads=[];cross_bytes=0;cross_tensors=set();rawpath=Path(old['original_GGUF'])
 with rawpath.open('rb')as stream,mmap.mmap(stream.fileno(),0,access=mmap.ACCESS_READ)as raw:
  for index,s in selections:
   d=old['descriptors'][index];base_record=len(expected);assert 0<=s<(82 if d['N']==5248 else d['N']//64)
   for g in range(d['G']):
    for port in range(4):
     record=bytearray()
     for cell in range(544):
      if cell<512:c,j=divmod(cell,32);source_byte=2+j
      else:c,source_byte=divmod(cell-512,2)
      col=s*32+(port%2)*16+c+(2624 if port>=2 else 0)if d['N']==5248 else s*64+16*port+c
      record.append(raw[d['GGUF_offset']+34*(col*d['G']+g)+source_byte])
     expected.append(record[::-1].hex()+'\n')
     f=fixture/d['name'].replace('.','_')/f'p{port}.bin'
     if f.exists():
      with f.open('rb')as inp:inp.seek((s*d['G']+g)*576);existing=inp.read(576)
      assert existing==record+bytes(32),(d['name'],s,g,port);cross_bytes+=576;cross_tensors.add(d['name'])
   loads.append({'catalog_index':index,'name':d['name'],'tensor':names[d['name']],'s':s,'K':d['K'],'N':d['N'],'G':d['G'],'expected_record_base':base_record,'expected_records':4*d['G'],'base':d['base'],'span':d['span']})
 (out/'transport_expected.hex').write_text(''.join(expected));(out/'transport_loads.hex').write_text(''.join(f"{x['catalog_index']|(x['s']<<7)|(x['tensor']<<23)|(x['expected_record_base']<<55):032x}\n"for x in loads))
 report={'schema':'m007-r007-binary-production-transport-fixtures-v1','metadata_count':120,'load_count':len(loads),'record_count':len(expected),'checked_cache_payload_B':544*len(expected),'actual_R_payload_B':576*len(expected),'loads':loads,'independent_oracle':'Direct original GGUF Q8_0 output-byte offsets; no TN8 or peer repack oracle','package':str(package),'package_manifest_sha256':old['package_manifest_sha256'],'original_GGUF':str(rawpath),'original_GGUF_SHA_inherited':old['original_GGUF_SHA_inherited'],'original_BO_metadata':old['original_BO_metadata'],'crosschecked_existing_W576_tensors':sorted(cross_tensors),'crosschecked_existing_W576_bytes':cross_bytes,'new_floating_gold_or_model_run_or_full120_pack':False,'base_fixture_manifest':str((base/'manifest.json').relative_to(root)),'base_fixture_manifest_sha256':sha(base/'manifest.json'),'files':{x.name:{'sha256':sha(x),'bytes':x.stat().st_size}for x in out.glob('*.hex')},'wall_s':time.monotonic()-start}
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:report[k]for k in ['schema','load_count','record_count','checked_cache_payload_B','actual_R_payload_B','crosschecked_existing_W576_bytes','wall_s']}))
if __name__=='__main__':main()
