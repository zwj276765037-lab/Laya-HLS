#!/usr/bin/env python3
"""Read-only source pin, port, page and mode-range audit; no RTL compilation."""
from pathlib import Path
import hashlib,json,re

ROOT=Path(__file__).resolve().parent.parent
V5=ROOT.parent
BASE=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
TASK=BASE/'results/attention_rtl_repair_20261008'
GATE=TASK/'reviewer_attention_v5_cold_static_source_preparation_release.json'
FINITE=TASK/'reviewer_attention_v5_head15_changed_finite_source_preparation_release.json'
RTL=V5/'runs/local_csynth_v1/work/hls/syn/verilog/attention_preloaded_slice.v'

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def ranges(top,name,kind):
    match=re.search(r'\bu_port_'+name+r'\s*\((.*?)\n  \);',top,re.S)
    assert match,name
    def values(signal):
        item=re.search(r'\.'+signal+r'\(\{([^}]*)\}\)',match[1])
        assert item,(name,signal)
        return list(reversed([int(value,16) for value in
            re.findall(r"64'h([0-9a-fA-F]+)",item[1])]))
    lo,hi=values(kind+'_lo'),values(kind+'_hi')
    assert len(lo)==len(hi)==4
    return [(a,b) for a,b in zip(lo,hi) if a!=b]

def main():
    assert sha(GATE)=='b73b9095ca3e3c80c512ff404c4c6c8883afd31626e85c38b7e012016cca61eb'
    assert sha(FINITE)=='7044e85372af05ba3660ac0bde6a094f7385229c11ff86ae090f8a3168ef2203'
    gate=json.loads(GATE.read_text())
    finite=json.loads(FINITE.read_text())
    text=RTL.read_text()
    pins=set(re.findall(r'^\s*(?:input|output)\s+(?:\[[^]]+\])?\s*(\w+)\s*;',text,re.M))
    ports=gate['interfaces']['ports']
    assert len({int(x,0) for port in ports for x in port['physical_page_bases']})==267
    assert sum(port['page_capacity'] for port in ports)==267
    for mode in finite['prepared_modes']:
        name=mode['mode']
        top=(ROOT/f'tb/att_finite_{name}_top.sv').read_text()
        bound=re.findall(r'^\s*\.(\w+)\((\w+)\)',top,re.M)
        byname={key:signal for key,signal in bound[:len(pins)]}
        assert len(bound[:len(pins)])==len(pins)==352 and set(byname)==pins
        assert byname['ap_clk']=='clk' and byname['ap_rst_n']=='resetn'
        assert all(byname[key]==key for key in pins-{'ap_clk','ap_rst_n'})
        selected=mode['selected_port']
        inactive=mode['inactive_numeric_port']
        qkv=int(next(p for p in ports if p['name']==selected)['physical_pointer_base'],0)
        output=int(next(p for p in ports if p['name']=='att_out')['physical_pointer_base'],0)
        out_start,out_end=mode['ATT_OUT_write_read_offset_bytes']
        assert ranges(top,selected,'read')==[
            (qkv+mode['Q_read_offset_bytes'][0],qkv+mode['Q_read_offset_bytes'][1]),
            (qkv+mode['K_read_offset_bytes'][0],qkv+mode['K_read_offset_bytes'][1]),
            (qkv+mode['V_read_offset_bytes'][0],qkv+mode['V_read_offset_bytes'][1])]
        assert ranges(top,inactive,'read')==[]
        assert ranges(top,'att_out','read')==ranges(top,'att_out','write')==[(output+out_start,output+out_end)]
        assert mode['final_aligned_AW_offset']==out_start+252
        assert f'localparam int SELECTED_PORT={3 if selected=="qkv0" else 4};' in top
        assert f'localparam int OUTPUT_START={out_start};' in top
        print(f'ATT_FINITE_SOURCE_AUDIT_PASS mode={name} exact_top_pins=352 mapped_pages=267 selected={selected} output_offset={out_start} no_eda=1')

if __name__=='__main__': main()
