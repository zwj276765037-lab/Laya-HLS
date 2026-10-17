#!/usr/bin/env python3
"""Read-only source/page binding audit; this is not an RTL compiler."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parent.parent
V5=ROOT.parent
BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
GATE=BASE/'results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_source_preparation_release.json'
RTL=V5/'runs/local_csynth_v1/work/hls/syn/verilog/attention_preloaded_slice.v'
PREP=ROOT/'runs/materialize_base_h0_r0_v2/prepared'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def read_ranges(top,name):
    match=re.search(r'\bu_port_'+name+r'\s*\((.*?)\n  \);',top,re.S)
    assert match,name
    def values(signal):
        item=re.search(r'\.'+signal+r'\(\{([^}]*)\}\)',match[1])
        assert item,(name,signal)
        return list(reversed([int(value,16) for value in
            re.findall(r"64'h([0-9a-fA-F]+)",item[1])]))
    lo,hi=values('read_lo'),values('read_hi')
    assert len(lo)==len(hi)==4
    return [(a,b) for a,b in zip(lo,hi) if a!=b]

def main():
    assert sha(GATE)=='b73b9095ca3e3c80c512ff404c4c6c8883afd31626e85c38b7e012016cca61eb'
    gate=json.loads(GATE.read_text())
    text=RTL.read_text()
    top=(ROOT/'tb/att_cold_top.sv').read_text()
    pins=set(re.findall(r'^\s*(?:input|output)\s+(?:\[[^]]+\])?\s*(\w+)\s*;',text,re.M))
    bound=re.findall(r'^\s*\.(\w+)\((\w+)\)',top,re.M)
    byname={name:signal for name,signal in bound[:len(pins)]}
    assert len(bound[:len(pins)])==len(pins)==352 and set(byname)==pins
    assert byname['ap_clk']=='clk' and byname['ap_rst_n']=='resetn'
    assert all(byname[name]==name for name in pins-{'ap_clk','ap_rst_n'})
    assert len({int(x,0) for port in gate['interfaces']['ports'] for x in port['physical_page_bases']})==267
    qkv0=int(next(p for p in gate['interfaces']['ports'] if p['name']=='qkv0')['physical_pointer_base'],0)
    att_out=int(next(p for p in gate['interfaces']['ports'] if p['name']=='att_out')['physical_pointer_base'],0)
    assert read_ranges(top,'qkv0')==[(qkv0,qkv0+256),
        (qkv0+0x400000,qkv0+0x404000),(qkv0+0x800000,qkv0+0x804000)]
    assert read_ranges(top,'qkv1')==[]
    assert read_ranges(top,'att_out')==[(att_out,att_out+256)]
    prepared=json.loads((PREP/'materialization.json').read_text())
    assert prepared['status']=='HOST_SOURCE_AND_FULL_IMAGE_CHECK_ONLY_NO_EDA'
    assert sum(x['count'] for x in prepared['mapped_pages'])==267
    assert all(x['inverse_checked_bytes']==12<<20 for x in prepared['host_shards'])
    for name,item in prepared['generated'].items():
        p=PREP/name
        assert p.stat().st_size==item['memh_bytes'] and sha(p)==item['memh_sha256']
    assert len(prepared['generated'])==10
    print('ATT_COLD_SOURCE_AUDIT_PASS exact_top_pins=352 mapped_pages=267 memh=10 qkv0_ranges=3 qkv1_ranges=0 att_out_read_bytes=256 full_host_inverse_bytes=25165824 no_eda=1')
if __name__=='__main__': main()
