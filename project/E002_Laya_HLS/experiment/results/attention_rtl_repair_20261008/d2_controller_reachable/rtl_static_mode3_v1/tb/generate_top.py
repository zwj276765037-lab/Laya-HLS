#!/usr/bin/env python3
"""Generate literal seven-AXI/two-Lite mode3 wiring from frozen D2-I pins."""
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
D2 = ROOT.parent
BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
RTL = D2/'runs/v3/csynth_vector_work/hls/syn/verilog/vector_controller_slice.v'
GATE = BASE/'results/attention_rtl_repair_20261008/reviewer_d2_i_vector_mode3_static_source_preparation_release.json'
OUT = HERE/'vector_mode3_top.sv'
AXI_FIELDS = ['AWVALID','AWREADY','AWADDR','AWID','AWLEN','AWSIZE','AWBURST',
    'AWLOCK','AWCACHE','AWPROT','AWQOS','AWREGION','AWUSER','WVALID','WREADY',
    'WDATA','WSTRB','WLAST','WID','WUSER','ARVALID','ARREADY','ARADDR','ARID',
    'ARLEN','ARSIZE','ARBURST','ARLOCK','ARCACHE','ARPROT','ARQOS','ARREGION',
    'ARUSER','RVALID','RREADY','RDATA','RLAST','RID','RUSER','RRESP',
    'BVALID','BREADY','BRESP','BID','BUSER']
COUNTS = ['aw_count','w_count','b_count','ar_count','r_count','rlast_count',
    'read_bus_bytes','write_bus_bytes','write_useful_bytes','write_pending','read_pending']
PORT_NAMES = ['src0_input','src1_input','io','aux','state0','state1','observed']
PHYSICAL_BASES = {name: (0x30 + i) << 32 for i, name in enumerate(PORT_NAMES)}
PAGE_OFFSETS = {
    'src0_input':[0], 'src1_input':[0], 'io':list(range(0,32768,4096)),
    'aux':[0], 'state0':[0], 'state1':[16916480], 'observed':[0],
}
READ_WINDOWS = {
    # The eight IO pages are mapped and checked, but the DUT reads only
    # frame offsets 0..831 (the accepted IO-scope erratum).
    'src0_input':[(0,64)], 'io':[(0,832)], 'aux':[(0,128)],
    'state1':[(16918976,64)],
}
WRITE_WINDOWS = {
    'state1':[(16918976,64),(16918592,64)], 'observed':[(0,128)],
}

def packed(values):
    return '{' + ','.join(f"64'h{x:016x}" for x in reversed(values)) + '}'

def main():
    gate_bytes=GATE.read_bytes()
    assert hashlib.sha256(gate_bytes).hexdigest()==\
        '853ff64b50b2fb1d879453e6aff8759222d5c949e94916cc0b26c8ac72882466'
    gate=json.loads(gate_bytes)
    assert gate['ports']['m_axi']['ports'] == PORT_NAMES
    rtl_bytes=RTL.read_bytes()
    assert hashlib.sha256(rtl_bytes).hexdigest()==\
        gate['immutable_source_refs']['generated_top']['sha256']
    text=rtl_bytes.decode('ascii')
    param={}
    for name,value in re.findall(r'^parameter\s+(C_\w+)\s*=\s*([^;]+);',text,re.M):
        value=value.strip()
        if value.isdecimal(): param[name]=int(value)
        elif re.fullmatch(r'\(\d+ / \d+\)',value):
            a,b=map(int,re.findall(r'\d+',value)); param[name]=a//b
    decls=[]
    for direction,width,name in re.findall(r'^\s*(input|output)\s+(\[[^\]]+\])?\s*(\w+)\s*;',text,re.M):
        if name in ('ap_clk','ap_rst_n'): continue
        if width:
            m=re.fullmatch(r'\[(C_\w+) - 1:0\]',width)
            if m: width=f'[{param[m[1]]-1}:0]'
        decls.append((direction,width,name))
    names={n for _,_,n in decls}
    for name in PORT_NAMES:
        n=name.upper()
        assert all(f'm_axi_{name}_{f}' in names for f in AXI_FIELDS)
        assert gate['ports']['m_axi']['data_width_bits']==param[f'C_M_AXI_{n}_DATA_WIDTH']==32
        assert gate['ports']['m_axi']['address_width_bits']==param[f'C_M_AXI_{n}_ADDR_WIDTH']==64
        assert gate['ports']['m_axi']['id_width_bits']==param[f'C_M_AXI_{n}_ID_WIDTH']==1
    assert param['C_S_AXI_CONTROL_ADDR_WIDTH']==5
    assert param['C_S_AXI_CONTROL_R_ADDR_WIDTH']==7
    assert len(decls)==7*len(AXI_FIELDS)+35,(len(decls),len(AXI_FIELDS))
    lines=['`timescale 1ns/1ps','// Literal wiring derived from frozen vector_controller_slice.v.',
           'module vector_mode3_top;','  logic clk=0;','  always #3.333 clk=~clk;',
           '  logic resetn=0;']
    for _,width,name in decls:
        lines.append(f'  logic {width} {name};' if width else f'  logic {name};')
    lines += ['  vector_controller_slice dut (','    .ap_clk(clk),','    .ap_rst_n(resetn),']
    for i,(_,_,name) in enumerate(decls):
        lines.append(f'    .{name}({name}){"," if i<len(decls)-1 else ""}')
    lines.append('  );')
    for side in ('dut','ram'):
        for count in COUNTS:
            width='[63:0] ' if count.endswith('bytes') else '' if count.endswith('pending') else '[31:0] '
            lines.append(f'  logic {width}{side}_{count} [0:6];')
    lines += ['  logic [31:0] accepted [0:6][0:4], delivered [0:6][0:4];',
              '  logic r_hold_applied [0:6], b_hold_applied [0:6];',
              '  logic [31:0] r_special_wait_cycles [0:6], b_special_wait_cycles [0:6];',
              '  logic hold_final_r [0:6], hold_final_b [0:6];']
    for idx,name in enumerate(PORT_NAMES):
        bits=32; base=PHYSICAL_BASES[name]
        pages=[base+offset for offset in PAGE_OFFSETS[name]]
        rr=[(base+offset,length) for offset,length in READ_WINDOWS.get(name,[])]
        ww=[(base+offset,length) for offset,length in WRITE_WINDOWS.get(name,[])]
        assert len(rr)<=4 and len(ww)<=4
        rr += [(0,0)]*(4-len(rr)); ww += [(0,0)]*(4-len(ww))
        lines += [f'  att_axi_port #(.DATA_BITS({bits}),.PORT({idx}),.PAGE_COUNT({len(pages)}),',
                  f'                 .PAGE_BASES({packed(pages)})) u_port_{name} (',
                  '    .clk(clk),.resetn(resetn),',
                  f'    .read_lo({packed([x for x,_ in rr])}),.read_hi({packed([x+n for x,n in rr])}),',
                  f'    .write_lo({packed([x for x,_ in ww])}),.write_hi({packed([x+n for x,n in ww])}),',
                  f'    .hold_final_r(hold_final_r[{idx}]),.hold_final_b(hold_final_b[{idx}]),',
                  f'    .r_hold_applied(r_hold_applied[{idx}]),.b_hold_applied(b_hold_applied[{idx}]),',
                  f'    .r_special_wait_cycles(r_special_wait_cycles[{idx}]),',
                  f'    .b_special_wait_cycles(b_special_wait_cycles[{idx}]),']
        for f in AXI_FIELDS: lines.append(f'    .{f.lower()}(m_axi_{name}_{f}),')
        for side in ('dut','ram'):
            for count in COUNTS: lines.append(f'    .{side}_{count}({side}_{count}[{idx}]),')
        lines += [f'    .accepted(accepted[{idx}]),.delivered(delivered[{idx}])','  );']
    for bank,prefix,width in ((0,'s_axi_control',5),(1,'s_axi_control_r',7)):
        lines += [f'  logic lite_cmd_valid_{bank},lite_cmd_ready_{bank},lite_cmd_write_{bank},lite_cmd_done_{bank};',
                  f'  logic [{width-1}:0] lite_cmd_addr_{bank};',
                  f'  logic [31:0] lite_cmd_wdata_{bank},lite_cmd_rdata_{bank};',
                  f'  att_axi_lite_master #(.ADDR_BITS({width}),.BANK({bank})) lite_{bank} (',
                  f'    .clk(clk),.resetn(resetn),.cmd_valid(lite_cmd_valid_{bank}),',
                  f'    .cmd_ready(lite_cmd_ready_{bank}),.cmd_write(lite_cmd_write_{bank}),',
                  f'    .cmd_addr(lite_cmd_addr_{bank}),.cmd_wdata(lite_cmd_wdata_{bank}),',
                  f'    .cmd_done(lite_cmd_done_{bank}),.cmd_rdata(lite_cmd_rdata_{bank}),']
        fields=('AWVALID','AWREADY','AWADDR','WVALID','WREADY','WDATA','WSTRB',
                'BVALID','BREADY','BRESP','ARVALID','ARREADY','ARADDR','RVALID',
                'RREADY','RDATA','RRESP')
        for j,f in enumerate(fields):
            lines.append(f'    .{f.lower()}({prefix}_{f}){"," if j<len(fields)-1 else ""}')
        lines.append('  );')
    lines += ['  `include "vector_mode3_control.svh"','endmodule']
    OUT.write_text('\n'.join(lines)+'\n')
    print(f'VECTOR_MODE3_TOP_PINS {len(decls)+2} pages={sum(map(len,PAGE_OFFSETS.values()))}')

if __name__=='__main__': main()
