#!/usr/bin/env python3
"""Bounded integer-byte fixtures: TN8 peer source, independent GGUF oracle."""
from pathlib import Path
import argparse,hashlib,json,mmap,struct,time

ROOT=Path(__file__).resolve().parents[3]
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
P=ROOT/'project/E002_Laya_HLS/experiment/build/model-q8-session-v2-actual-r2-20261010'
F=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 global ROOT,R,P,F
 parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,default=ROOT);parser.add_argument('--out',type=Path);a=parser.parse_args()
 ROOT=a.root.resolve();R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';P=ROOT/'project/E002_Laya_HLS/experiment/build/model-q8-session-v2-actual-r2-20261010';F=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture'
 start=time.monotonic();out=a.out.resolve()if a.out else R/'binary_peer_data';out.mkdir(parents=True,exist_ok=False)
 manifest=json.loads((P/'manifest.json').read_text());assert sha(P/'manifest.json')=='46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
 weights={x['name']:x for x in manifest['weights']};tensors={x['name']:x for x in manifest['tensors']}
 catalog=bytes.fromhex(''.join(bytes.fromhex(x)[::-1].hex()for x in(R/'data/catalog.hex').read_text().splitlines()))
 assert hashlib.sha256(catalog).hexdigest()=='bf187e0b2987b0fbc5e1951dee35b6b3219631dfabb9158c0b77f2b92b81dfe3'
 descriptors=[];encoded=[]
 for index in range(120):
  layer,role=divmod(index,4);stem=('qkv','wo','mlp_wi','mlp_wo')[role]if layer<28 else('head_qkv','head_wo','head_fc1','head_fc2')[role];local=layer if layer<28 else layer-28;name=f'{stem}.{local}.weight';w=weights[name];t=tensors[name]
  pairs=struct.unpack_from('<8Q',catalog,256+64*index);bases=pairs[::2];spans=pairs[1::2];k,n=w['K'],w['N'];groups=k//32;needed=576*groups*(82 if n==5248 else n//64)
  assert k in [1024,2624,4096]and all(s>=needed for s in spans)
  d={'index':index,'name':name,'K':k,'N':n,'G':groups,'q_base':w['q_base'],'scale_base':w['scale_base'],'base':bases,'span':spans,'payload_per_port':needed,'GGUF_offset':t['source_offset']};descriptors.append(d)
  v=k|(n<<16)|(w['q_base'][0]<<32)|(w['q_base'][1]<<96)|(w['scale_base']<<160)
  for p in range(4):v|=bases[p]<<(224+128*p);v|=spans[p]<<(288+128*p)
  encoded.append(f'{v:0184x}\n')
 (out/'metadata.hex').write_text(''.join(encoded))
 cases=[]
 def case(index,p,offset,beats,flag):
  d=descriptors[index];assert offset%64==0 and 1<=beats<=16 and offset+64*beats<=d['payload_per_port'];address=d['base'][p]+offset;assert address//4096==(address+64*beats-1)//4096
  cases.append({'tensor':index,'port':p,'local_offset':offset,'address':address,'beats':beats,'flag':flag})
 # Eight different tensor sources overlap on port0 while its first last-R is
 # held. The ninth request reuses ID0 and must remain stable until actual R.
 for i in range(9):case(i,0,0,1,0)
 for d in descriptors:
  i=d['index'];payload=d['payload_per_port']
  for p in range(4):
   case(i,p,0,16,1);case(i,p,payload-1024,16,2)
   case(i,p,512,4,4)  # word8 scale -> next record, crossing576B
   case(i,p,3840,4,8);case(i,p,4096,4,8)  # legal adjacent4KiB pages
   boundary=576*d['G'];offset=boundary-128
   if (d['base'][p]+offset)//4096==(d['base'][p]+offset+255)//4096:case(i,p,offset,4,16)
   else:case(i,p,offset,2,16);case(i,p,boundary,2,16)
 expected=[];cross_bytes=0;cross_tensors=set();raw_path=Path(manifest['source_model']['path'])
 with raw_path.open('rb')as stream,mmap.mmap(stream.fileno(),0,access=mmap.ACCESS_READ)as raw:
  for request in cases:
   d=descriptors[request['tensor']];p=request['port'];start_word=len(expected);answer=bytearray()
   # Independent output-byte decoder: direct original Q8_0 block address.
   # It neither reads TN8 nor calls the peer's column/repack routines.
   for byte_index in range(64*request['beats']):
    absolute=request['local_offset']+byte_index;record,cell=divmod(absolute,576)
    if cell>=544:value=0
    else:
     block,group=divmod(record,d['G'])
     if cell<512:column_lane,byte_in_Q=divmod(cell,32);source_byte=2+byte_in_Q
     else:column_lane,source_byte=divmod(cell-512,2)
     if d['N']==5248:column=block*32+(p%2)*16+column_lane+(2624 if p>=2 else 0)
     else:column=block*64+p*16+column_lane
     value=raw[d['GGUF_offset']+34*(column*d['G']+group)+source_byte]
    answer.append(value)
   for offset in range(0,len(answer),64):expected.append(answer[offset:offset+64][::-1].hex()+'\n')
   request['expected_word']=start_word
   fixture=F/d['name'].replace('.','_')/f'p{p}.bin'
   if fixture.exists():
    with fixture.open('rb')as f:f.seek(request['local_offset']);existing=f.read(len(answer))
    assert existing==answer,(d['name'],p,request['local_offset']);cross_bytes+=len(answer);cross_tensors.add(d['name'])
 assert len(cases)<=4096 and len(expected)<=65536
 assert len(cross_tensors)==8,'all existing eight W576 tensors must be independently crosschecked'
 (out/'expected.hex').write_text(''.join(expected))
 rows=[]
 for x in cases:
  v=x['port']|(x['address']<<2)|((x['beats']-1)<<66)|(x['expected_word']<<74)|(x['tensor']<<106)|(x['flag']<<113);rows.append(f'{v:032x}\n')
 (out/'requests.hex').write_text(''.join(rows))
 report={'schema':'m007-r007-binary-peer-fixtures-v1','status':'INTEGER_BYTE_FIXTURES_ONLY','request_count':len(cases),'expected_64B_words':len(expected),'expected_bytes':64*len(expected),'metadata_count':120,'descriptors':descriptors,'cases':cases,'independent_oracle':'Original GGUF direct output-byte Q8_0 addressing; no TN8 read or peer repack function in expected generation','peer_source':'Original TN8 w_q0/w_q1/w_scale bytes per architecture§17','original_GGUF':str(raw_path),'original_GGUF_SHA_inherited':manifest['source_model']['sha256'],'package':str(P),'package_manifest_sha256':sha(P/'manifest.json'),'original_BO_metadata':{k:manifest['bo'][k]for k in ['w_q0','w_q1','w_scale']},'crosschecked_existing_W576_tensors':sorted(cross_tensors),'crosschecked_existing_W576_bytes':cross_bytes,'all120_first_tail_each4ports':True,'page_coverage':'Two adjacent legal AR spans across4KiB; an individual AR never crosses page','new_F32_gold_or_model_run':False,'files':{p.name:{'sha256':sha(p),'bytes':p.stat().st_size}for p in out.glob('*.hex')},'wall_s':time.monotonic()-start}
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({k:report[k]for k in ['status','request_count','expected_64B_words','crosschecked_existing_W576_bytes','wall_s']}))

if __name__=='__main__':main()
