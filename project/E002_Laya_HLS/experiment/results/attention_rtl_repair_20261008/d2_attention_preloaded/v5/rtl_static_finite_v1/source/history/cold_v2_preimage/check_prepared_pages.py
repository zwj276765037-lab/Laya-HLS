#!/usr/bin/env python3
"""Independent read-only check of all serialized mapped page bytes."""
from pathlib import Path
import hashlib,json
BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
ROOT=Path(__file__).resolve().parent.parent
V5=ROOT.parent
PREP=ROOT/'runs/materialize_base_h0_r0_v2/prepared'
FIX=V5/'tb/fixture_preloaded'
OLD=BASE/'results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision'
PKG=BASE/'build/model-attention-rtl-repair-20261008'
GATE=BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_source_preparation_release.json'

def sha(x): return hashlib.sha256(x).hexdigest()
def mem(name):
    text=(PREP/f'{name}.memh').read_bytes()
    assert text.endswith(b'\n') and len(text)%3==0,name
    for i in range(2,len(text),3): assert text[i]==10,name
    return bytes(int(text[i:i+2],16) for i in range(0,len(text),3))

def check(name,expected):
    got=mem(name)
    assert got==expected,(name,next((i for i,(a,b) in enumerate(zip(got,expected)) if a!=b),None),len(got),len(expected))
    return {'name':name,'bytes':len(got),'sha256':sha(got)}

def main():
    manifest=json.loads((FIX/'fixture_manifest.json').read_text())
    gate=json.loads(GATE.read_text())
    raw=(OLD/'qkv_final.f32.bin').read_bytes()
    assert len(raw)==786432 and sha(raw)==manifest['cases']['base']['source_sha256']
    request=(OLD/'request.bin').read_bytes(); assert len(request)==832
    aux=(PKG/'aux.bin').read_bytes(); assert len(aux)==1671872
    begin=(FIX/'base_h0_r0_begin.u32le.bin').read_bytes()
    run=(FIX/'base_h0_r0_run_ticket1_epoch1.u32le.bin').read_bytes()
    io=bytearray(32768); io[:832]=request
    io[24:32]=(301).to_bytes(8,'little'); io[32:40]=(1).to_bytes(8,'little')
    expected={'init_descriptor':begin+b'\xa5'*(4096-640),
              'descriptor_run':run+b'\xa5'*(4096-640),
              'init_io':bytes(io),
              'init_aux':aux[:128]+b'\xa5'*(4096-128),
              'init_qkv0':b'\xa5'*(96*4096),
              'init_qkv1':b'\xa5'*(96*4096),
              'init_att_out':b'\xa5'*(64*4096),
              'init_observed':b'\xef\xbe\xad\xde'*256+b'\xa5'*(4096-1024)}
    checked=[]
    for name,data in expected.items(): checked.append(check(name,data))
    for shard in (0,1):
        port=next(p for p in gate['interfaces']['ports'] if p['name']==f'qkv{shard}')
        data=bytearray()
        for ofs_hex in port['logical_page_offsets']:
            start=int(ofs_hex,0)
            for off in range(start,start+4096):
                index=off>>2
                plane=index>>20
                batch=(index>>19)&1
                local_head=(index>>16)&7
                row=(index>>6)&1023
                d=index&63
                value=0xa5
                if plane<3 and batch==0 and row<64:
                    head=2*local_head+shard
                    source=4*(row*3072+plane*1024+head*64+d)+(off&3)
                    value=raw[source]
                data.append(value)
        checked.append(check(f'run_qkv{shard}',bytes(data)))
    assert len(checked)==10 and sum(x['bytes'] for x in checked)==460*4096
    result={'schema':'attention_v5_cold_independent_page_serialization_check_v1',
            'status':'PASS_NO_EDA','source_sha256':sha(raw),
            'mapped_page_count':267,'initial_mapped_page_bytes':267*4096,
            'prepared_total_bytes':sum(x['bytes'] for x in checked),
            'qkv_run_checked_bytes':2*96*4096,'files':checked}
    out=ROOT/'runs/materialize_base_h0_r0_v2/independent_page_check.json'
    if out.exists(): raise FileExistsError(out)
    out.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print('ATT_COLD_INDEPENDENT_PAGES_PASS files=10 qkv_bytes=786432')
if __name__=='__main__': main()
