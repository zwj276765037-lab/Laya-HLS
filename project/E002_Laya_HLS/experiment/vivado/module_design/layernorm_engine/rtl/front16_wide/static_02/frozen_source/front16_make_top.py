#!/usr/bin/env python3
"""Bind four checked AXI endpoints to actual generated front16 RTL widths."""
from pathlib import Path
import re
import sys

if len(sys.argv) != 3:
    raise SystemExit('usage: front16_make_top.py GENERATED_TOP_VERILOG OUTPUT_SV')
top = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2]).resolve()
source = top.read_text()
module = top.stem
assert module in ('laya_front16_byte', 'laya_front16_wide')
header = source.split(f'module {module} (', 1)[1].split(');', 1)[0]
ports = [line.strip().rstrip(',') for line in header.splitlines() if line.strip()]
params = re.findall(r'^parameter\s+[^;]+;', source, re.M)
decls = re.findall(r'^(input|output)\s+(?:(?:wire|reg)\s+)?(\[[^\]]+\]\s+)?(\w+);', source, re.M)
by_name = {name: (direction, width) for direction, width, name in decls}
assert len(ports) == len(set(ports)) == len(by_name) and set(ports) == set(by_name)
bo_names = ('state0', 'aux', 'state1', 'observed')
channels = ('AWVALID','AWREADY','AWADDR','AWID','AWLEN','AWSIZE','AWBURST',
            'WVALID','WREADY','WDATA','WSTRB','WLAST',
            'ARVALID','ARREADY','ARADDR','ARID','ARLEN','ARSIZE','ARBURST',
            'RVALID','RREADY','RDATA','RLAST','RID','RRESP',
            'BVALID','BREADY','BRESP','BID')
memory_outputs = {'AWREADY','WREADY','ARREADY','RVALID','RDATA','RLAST',
                  'RID','RRESP','BVALID','BRESP','BID'}
widths = {}
prefixes = {}
for bo in bo_names:
    match = re.search(rf'parameter\s+C_M_AXI_(?:GMEM_)?{bo.upper()}_DATA_WIDTH\s*=\s*(\d+)\s*;',source)
    assert match, bo
    widths[bo] = int(match.group(1))
    assert widths[bo] == (512 if module.endswith('wide') and bo!='observed' else 32)
    prefixes[bo] = next(prefix for prefix in (f'm_axi_gmem_{bo}_',f'm_axi_{bo}_')
                        if f'{prefix}ARVALID' in by_name)
    assert all(f'{prefixes[bo]}{c}' in by_name for c in channels)
for name in ('ap_clk','ap_rst_n','s_axi_control_AWVALID'):
    assert name in by_name
assert re.search(r'^(?:reg|wire)\s+ap_done;',source,re.M)
run_module = f'{module}_p_anonymous_namespace_run_{module.removeprefix("laya_front16_")}'
run_match = re.search(rf'{run_module}\s+(\w+)\s*\(',source)
assert run_match, 'generated run instance'
run_instance = run_match.group(1)
run_source = (top.parent / f'{run_module}.v').read_text()
arith_match = re.search(rf'{module}_layernorm_row_arithmetic\s+(\w+)\s*\(',run_source)
assert arith_match, 'generated arithmetic instance'
arith_instance = arith_match.group(1)
arith_path = f'dut.{run_instance}.{arith_instance}'

lines = ['`timescale 1ns/1ps','module front16_top;',
         'import "DPI-C" function int front16_mem_init();',
         'import "DPI-C" function int front16_mem_progress();',
         'import "DPI-C" function int front16_mem_import_bytes();',
         'import "DPI-C" function int front16_mem_ln_bytes();',
         'import "DPI-C" function int front16_mem_gamma_bytes();',
         'import "DPI-C" function int front16_mem_norm_bytes();',
         'import "DPI-C" function int front16_mem_obs_bytes();',
         'import "DPI-C" function int front16_mem_errors();',
         'import "DPI-C" function int front16_mem_capture();',
         'import "DPI-C" function int front16_mem_check();',
         *[p.replace('parameter','localparam',1) for p in params],
         *[f'logic {by_name[p][1]}{p};' for p in ports],
         'wire ap_done = dut.ap_done;',
         f'wire arith_start = {arith_path}.ap_start;',
         f'wire arith_done = {arith_path}.ap_done;',
         'logic pressure=0, launch=0, aw_sent=0, w_sent=0;',
         'logic [3:0] debt_zero;',
         'logic [31:0] ar_count[4],r_count[4],aw_count[4],w_count[4],b_count[4];',
         'logic [31:0] r_hold_hits[4],b_hold_hits[4],r_hold_cycles[4],b_hold_cycles[4];',
         'integer cycles=0;',
         'integer arith_start_edges=0, arith_done_edges=0;',
         'integer arith_first_cycle=-1, arith_last_cycle=-1;',
         'logic arith_start_prev=0, arith_done_prev=0;',
         'initial ap_clk=0; always #3.333 ap_clk=~ap_clk;',
         'initial begin',
         '  pressure=$test$plusargs("PRESSURE");',
         '  ap_rst_n=0;',
         '  if (!front16_mem_init()) $fatal(1,"front16 memory setup");',
         '  repeat (20) @(negedge ap_clk);',
         '  ap_rst_n=1;',
         '  repeat (5) @(negedge ap_clk);',
         '  launch=1;',
         'end',
         'assign s_axi_control_AWVALID=launch && !aw_sent;',
         'assign s_axi_control_AWADDR=0;',
         'assign s_axi_control_WVALID=launch && !w_sent;',
         "assign s_axi_control_WDATA=32'h1;",
         "assign s_axi_control_WSTRB=4'hf;",
         'assign s_axi_control_BREADY=1;',
         'assign s_axi_control_ARVALID=0;',
         'assign s_axi_control_ARADDR=0;',
         'assign s_axi_control_RREADY=1;',
         'always @(posedge ap_clk) if (ap_rst_n) begin',
         '  if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent<=1;',
         '  if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent<=1;',
         '  cycles<=cycles+1;',
         '  if (arith_start && !arith_start_prev) begin',
         '    arith_start_edges<=arith_start_edges+1;',
         '    if (arith_first_cycle<0) arith_first_cycle<=cycles;',
         '  end',
         '  if (arith_done && !arith_done_prev) begin',
         '    arith_done_edges<=arith_done_edges+1;',
         '    arith_last_cycle<=cycles;',
         '  end',
         '  arith_start_prev<=arith_start;',
         '  arith_done_prev<=arith_done;',
         '  if (cycles!=0 && cycles%8192==0)',
         '    $display("FRONT16_PROGRESS cycles=%0d import=%0d gamma=%0d ln=%0d norm=%0d observed=%0d",',
         '      cycles,front16_mem_import_bytes(),front16_mem_gamma_bytes(),',
         '      front16_mem_ln_bytes(),front16_mem_norm_bytes(),front16_mem_obs_bytes());',
         '  if (front16_mem_errors()) $fatal(1,"front16 memory error");',
         '  if (ap_done) begin',
         '    $display("FRONT16_ARITH starts=%0d dones=%0d first_cycle=%0d last_cycle=%0d",',
         '      arith_start_edges,arith_done_edges,arith_first_cycle,arith_last_cycle);',
         '    for (int p=0;p<4;p++) begin',
         '      $display("FRONT16_PORT port=%0d AR=%0d R=%0d AW=%0d W=%0d B=%0d lane_read_bytes=%0d transfer_read_bytes=%0d lane_write_bytes=%0d strobed_write_bytes=%0d",',
         '        p,ar_count[p],r_count[p],aw_count[p],w_count[p],b_count[p],',
         '        r_count[p]*(p==3?4:(p==0||p==1||p==2)?' + ('64' if module.endswith('wide') else '4') + ':4),',
         '        p==0?mem_state0.read_transfer_bytes:p==1?mem_aux.read_transfer_bytes:p==2?mem_state1.read_transfer_bytes:mem_observed.read_transfer_bytes,',
         '        w_count[p]*(p==3?4:' + ('64' if module.endswith('wide') else '4') + '),',
         '        p==0?mem_state0.write_transfer_bytes:p==1?mem_aux.write_transfer_bytes:p==2?mem_state1.write_transfer_bytes:mem_observed.write_transfer_bytes);',
         '    end',
         '    if (!front16_mem_capture()) $fatal(1,"front16 first-done capture");',
         '    if (!front16_mem_check()) $fatal(1,"front16 first-done numerical/coverage");',
         "    if (debt_zero!==4'b1111) $fatal(1,\"front16 physical debt at first done %b\",debt_zero);",
         '    if (pressure && (r_hold_hits[0]!=1 || b_hold_hits[2]!=1))',
         '      $fatal(1,"front16 required hold count R=%0d B=%0d",r_hold_hits[0],b_hold_hits[2]);',
         '    if (!pressure && (r_hold_hits[0]!=0 || b_hold_hits[2]!=0))',
         '      $fatal(1,"front16 unexpected hold");',
         '    $display("FRONT16_RTL_PASS mode=%s pressure=%0d cycles=%0d r_hold_cycles=%0d b_hold_cycles=%0d",',
         f'      "{module.removeprefix("laya_front16_")}",pressure,cycles,r_hold_cycles[0],b_hold_cycles[2]);',
         '    $finish;',
         '  end',
         '  if (cycles>=40000000) $fatal(1,"front16 40M cycle cap");',
         'end']
if 's_axi_control_r_AWVALID' in by_name:
    lines += ['assign s_axi_control_r_AWVALID=0;', 'assign s_axi_control_r_AWADDR=0;',
              'assign s_axi_control_r_WVALID=0;', 'assign s_axi_control_r_WDATA=0;',
              'assign s_axi_control_r_WSTRB=0;', 'assign s_axi_control_r_BREADY=1;',
              'assign s_axi_control_r_ARVALID=0;', 'assign s_axi_control_r_ARADDR=0;',
              'assign s_axi_control_r_RREADY=1;']
for name,(direction,_) in by_name.items():
    if name.startswith('m_axi_') and direction=='input':
        if name.endswith(('RUSER','BUSER')):
            lines.append(f'assign {name}=0;')
        elif name.endswith(('AWREADY','WREADY','ARREADY','RVALID','RDATA',
                            'RLAST','RID','RRESP','BVALID','BRESP','BID')):
            pass  # wired to checked memory endpoint below
        else:
            raise ValueError(f'unhandled RTL AXI input: {name}')
lines += [f'{module} dut(', ',\n'.join(f'  .{p}({p})' for p in ports), ');']
for index,bo in enumerate(bo_names):
    prefix=prefixes[bo]
    lines.append(f'front16_axi_memory #(.DATA_W({widths[bo]}),.PORT_INDEX({index})) mem_{bo} (')
    connections=['  .clk(ap_clk)', '  .rst_n(ap_rst_n)', '  .pressure(pressure)']
    connections += [f'  .{c}({prefix}{c})' for c in channels]
    connections += [f'  .debt_zero(debt_zero[{index}])']
    connections += [f'  .{c}({c}[{index}])' for c in ('ar_count','r_count','aw_count','w_count','b_count',
                                                     'r_hold_hits','b_hold_hits','r_hold_cycles','b_hold_cycles')]
    lines += [',\n'.join(connections),');']
    if bo in ('state0','aux'):
        lines.append(f'wire {bo}_write_illegal = {prefix}AWVALID || {prefix}WVALID;')
    else:
        lines.append(f'wire {bo}_read_illegal = {prefix}ARVALID;')
lines += ['always @(posedge ap_clk) if (ap_rst_n) begin',
          '  if (state0_write_illegal || aux_write_illegal || state1_read_illegal || observed_read_illegal)',
          '    $fatal(1,"front16 BO direction violation");',
          'end','endmodule']
stats = []
for bo in bo_names:
    mem = f'mem_{bo}'
    stats += [f'    $display("FRONT16_STALL port={bo} AR=%0d AW=%0d W=%0d R=%0d B=%0d max_read_outstanding=1 max_write_outstanding=1",',
              f'      {mem}.ar_stall_cycles,{mem}.aw_stall_cycles,{mem}.w_stall_cycles,{mem}.r_stall_cycles,{mem}.b_stall_cycles);',
              '    for (int l=0;l<64;l++) begin',
              f'      if ({mem}.ar_len_hist[l]) $display("FRONT16_ARLEN port={bo} len=%0d count=%0d",l,{mem}.ar_len_hist[l]);',
              f'      if ({mem}.aw_len_hist[l]) $display("FRONT16_AWLEN port={bo} len=%0d count=%0d",l,{mem}.aw_len_hist[l]);',
              '    end']
lines[lines.index('    $finish;'):lines.index('    $finish;')] = stats
out.write_text('\n'.join(lines)+'\n')
print(f'FRONT16_TOP_GENERATED {module} widths={widths} ports={len(ports)} output={out}')
