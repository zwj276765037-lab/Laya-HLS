#!/usr/bin/env python3
"""Bind LOAD read ports to real AMD converters and full native 13BO owners."""
import json
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]
meta = json.loads((MODULE / 'tb/laya_axi_13bo_ports_v1.json').read_text())
fields = meta['field_widths']
channels = {
    'ar': ['addr', 'id', 'len', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user', 'valid', 'ready'],
    'aw': ['addr', 'id', 'len', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user', 'valid', 'ready'],
    'w': ['data', 'strb', 'id', 'user', 'last', 'valid', 'ready'],
    'r': ['data', 'resp', 'id', 'user', 'last', 'valid', 'ready'],
    'b': ['resp', 'id', 'user', 'valid', 'ready']}

def outgoing(ch, f):
    return (ch in ('ar', 'aw', 'w')) != (f == 'ready')

ports = [('input', '', 'clk'), ('input', '', 'rst_n'), ('input', '', 'service_select'),
         ('input', '[12:0]', 'clear_error'), ('output', '[12:0]', 'selected_owner'),
         ('output', '[12:0]', 'debt_zero'), ('output', '[12:0]', 'protocol_error'),
         ('output', '', 'physical_debt_zero'), ('output', '[3:0]', 'upstream_read_pending')]
for ch, fs in channels.items():
    for f in fs:
        w = '' if fields[f] == 1 else f'[{fields[f]-1}:0]'
        d = 'input' if outgoing(ch, f) else 'output'
        ports += [(d, '[12:0]' + w, 'controller_' + ch + f),
                  ('output' if d == 'input' else 'input', '[12:0]' + w, 'memory_' + ch + f)]
for prefix, dimensions, width in [('load_', '[2:0]', 512), ('aux_', '', 128)]:
    for ch in ('ar', 'r'):
        for f in (['addr', 'len', 'size', 'burst', 'valid', 'ready'] if ch == 'ar' else ['data', 'resp', 'last', 'valid', 'ready']):
            w = (width if f == 'data' else fields[f])
            d = 'input' if outgoing(ch, f) else 'output'
            ports += [(d, dimensions + ('' if w == 1 else f'[{w-1}:0]'), prefix + ch + f)]
for name in ['accepted_ar', 'returned_r', 'accepted_aw', 'accepted_w', 'returned_b']:
    ports.append(('output', '[12:0][31:0]', name))

s = '''`timescale 1ns/1ps
// Read-only LOAD adapter. One converter per actual q0/q1/scale/AUX BO.
// Cold reset only; selected service ownership survives accepted SI reads,
// offered SI/MI AR and buffered SI R until their actual LAST handshakes.
module laya_load_axi_native_v1(
'''
s += ',\n'.join(f'  {d} logic {w} {n}'.replace('logic  ', 'logic ') for d, w, n in ports) + '\n);\n'
s += '  logic [12:0] desired_owner;\n'
for d, w, n in meta['ports']:
    if n.startswith('owner_'):
        s += f'  logic {w} {n};\n'
for ch, fs in channels.items():
    for f in fs:
        w = '' if fields[f] == 1 else f'[{fields[f]-1}:0]'
        s += f'  logic [3:0]{w} cv_{ch}{f};\n'
s += '  logic [3:0] si_arvalid,si_arready,si_rvalid,si_rready,si_rlast;\n'
s += '  assign physical_debt_zero=(&debt_zero) && upstream_read_pending==0 &&\n    si_arvalid==0 && si_rvalid==0 && cv_arvalid==0 && cv_rvalid==0;\n'
s += '''  for(genvar bo=0;bo<13;bo++)begin : native_bo
    if(bo>=2 && bo<=5)begin : load_bo
      assign desired_owner[bo]=service_select || upstream_read_pending[bo-2] ||
        si_arvalid[bo-2] || si_rvalid[bo-2] || cv_arvalid[bo-2] || cv_rvalid[bo-2];
    end else assign desired_owner[bo]=0;
'''
for ch, fs in channels.items():
    for f in fs:
        n = ch + f
        if outgoing(ch, f):
            s += f'    assign owner_{n}[bo][0]=controller_{n}[bo];\n'
            s += f'    if(bo>=2 && bo<=5)assign owner_{n}[bo][1]=cv_{n}[bo-2];\n    else assign owner_{n}[bo][1]=0;\n'
        else:
            s += f'    assign controller_{n}[bo]=owner_{n}[bo][0];\n'
            s += f'    if(bo>=2 && bo<=5)assign cv_{n}[bo-2]=owner_{n}[bo][1];\n'
s += '  end\n'
s += '  always_ff @(posedge clk)begin\n    if(!rst_n)upstream_read_pending<=0;\n    else for(int p=0;p<4;p++)begin\n'
s += '      if(si_arvalid[p] && si_arready[p])upstream_read_pending[p]<=1;\n      if(si_rvalid[p] && si_rready[p] && si_rlast[p])upstream_read_pending[p]<=0;\n    end\n  end\n'
s += '  laya_axi_13bo_owner_v1 native_owners(\n' + ',\n'.join('    .' + n for _, _, n in meta['ports']) + '\n  );\n'
for p in range(4):
    pre = 'load_' if p < 3 else 'aux_'
    ix = f'[{p}]' if p < 3 else ''
    nsi = lambda n: pre + n + ix
    s += f'  assign si_arvalid[{p}]={nsi("arvalid")};\n'
    s += f'  assign {nsi("arready")}=si_arready[{p}] && selected_owner[{p+2}];\n'
    s += f'  assign si_rvalid[{p}]={nsi("rvalid")};\n  assign si_rready[{p}]={nsi("rready")};\n  assign si_rlast[{p}]={nsi("rlast")};\n'
    # Every service-side ID/user/region is explicitly zero; the original
    # controller owner keeps all historical fields through the arbiter.
    for ch, fs in channels.items():
        for f in fs:
            if outgoing(ch, f) and (ch not in ('ar', 'r') or f in ('id', 'user')):
                s += f'  assign cv_{ch}{f}[{p}]=0;\n'
    s += f'  logic cv_arlock{p};\n  assign cv_arlock[{p}]={{1\'b0,cv_arlock{p}}};\n'
    name = 'laya_load_dwidth512_v1' if p < 3 else 'laya_load_dwidth128_v1'
    binds = ['.s_axi_aclk(clk)', '.s_axi_aresetn(rst_n)',
             '.s_axi_awaddr(64\'d0)', '.s_axi_awlen(8\'d0)', '.s_axi_awsize(3\'d0)',
             '.s_axi_awburst(2\'d1)', '.s_axi_awlock(1\'d0)', '.s_axi_awcache(4\'d0)',
             '.s_axi_awprot(3\'d0)', '.s_axi_awqos(4\'d0)', '.s_axi_awregion(4\'d0)', '.s_axi_awvalid(1\'d0)', '.s_axi_awready()',
             f'.s_axi_wdata({512 if p<3 else 128}\'d0)', f'.s_axi_wstrb({64 if p<3 else 16}\'d0)',
             '.s_axi_wlast(1\'d0)', '.s_axi_wvalid(1\'d0)', '.s_axi_wready()',
             '.s_axi_bresp()', '.s_axi_bvalid()', '.s_axi_bready(1\'d1)']
    for f in ['addr', 'len', 'size', 'burst']:
        binds.append(f'.s_axi_ar{f}({nsi("ar"+f)})')
    binds += [f'.s_axi_arvalid(si_arvalid[{p}] && selected_owner[{p+2}])', f'.s_axi_arready(si_arready[{p}])',
              '.s_axi_arlock(1\'d0)', '.s_axi_arcache(4\'d3)', '.s_axi_arprot(3\'d0)', '.s_axi_arqos(4\'d0)', '.s_axi_arregion(4\'d0)']
    for f in ['data', 'resp', 'last', 'valid', 'ready']:
        binds.append(f'.s_axi_r{f}({nsi("r"+f)})')
    binds += ['.m_axi_awaddr()', '.m_axi_awlen()', '.m_axi_awsize()', '.m_axi_awburst()',
              '.m_axi_awlock()', '.m_axi_awcache()', '.m_axi_awprot()', '.m_axi_awqos()', '.m_axi_awregion()',
              '.m_axi_awvalid()', '.m_axi_awready(1\'d0)', '.m_axi_wdata()', '.m_axi_wstrb()',
              '.m_axi_wlast()', '.m_axi_wvalid()', '.m_axi_wready(1\'d0)',
              '.m_axi_bresp(2\'d0)', '.m_axi_bvalid(1\'d0)', '.m_axi_bready()']
    for f in ['addr', 'len', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'valid', 'ready']:
        value = f'cv_arlock{p}' if f == 'lock' else f'cv_ar{f}[{p}]'
        binds.append(f'.m_axi_ar{f}({value})')
    for f in ['data', 'resp', 'last', 'valid', 'ready']:
        binds.append(f'.m_axi_r{f}(cv_r{f}[{p}])')
    s += f'  {name} converter{p}(\n' + ',\n'.join('    ' + v for v in binds) + '\n  );\n'
s += 'endmodule\n'
(MODULE / 'rtl/laya_load_axi_native_v1.sv').write_text(s)
(MODULE / 'tb/laya_load_axi_native_ports_v1.json').write_text(json.dumps({'ports': ports}, indent=2) + '\n')
print('FULL_CURRENT_LOAD_AXI_NATIVE_GENERATED converters=4 physical_BO=13')
