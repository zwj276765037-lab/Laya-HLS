#!/usr/bin/env python3
"""Generate literal Type top wiring from the accepted 352-pin RTL binder.

This is a source-preparation utility. It never invokes EDA or a materializer.
The finite control include deliberately retains a disabled runtime watchdog
until its generated-FSM proof is accepted under a later gate.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
MODULE = HERE.parent
BOUND = MODULE / 'source/port_page_binding.json'
BOUND_SHA = '4fde049617b5f24933cebfd5f5ea9d36dffd48a316ecf8fa7e2af8a9fd953c4a'
PORTS = ('hidden_input', 'embedding', 'io', 'aux', 'state0', 'state1', 'observed')
CHANNEL_COUNTS = ('aw_count', 'w_count', 'b_count', 'ar_count', 'r_count',
                  'rlast_count', 'read_bus_bytes', 'write_bus_bytes',
                  'write_useful_bytes', 'write_pending', 'read_pending')
LITE_FIELDS = ('AWVALID', 'AWREADY', 'AWADDR', 'WVALID', 'WREADY', 'WDATA',
               'WSTRB', 'BVALID', 'BREADY', 'BRESP', 'ARVALID', 'ARREADY',
               'ARADDR', 'RVALID', 'RREADY', 'RDATA', 'RRESP')


def packed(values: list[int]) -> str:
    return '{' + ','.join(f"64'h{value:016x}" for value in reversed(values)) + '}'


def geometry(name: str, base: int, capacity: int, q8_offset: int,
             f32_offset: int) -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    # Intervals are half-open. Empty slots never authorize address zero.
    if name == 'hidden_input':
        reads, writes = [(base, base + 262144)], []
    elif name == 'embedding':
        reads, writes = [(base + q8_offset, base + q8_offset + 1088)], []
    elif name == 'io':
        reads, writes = [(base, base + 832)], []
    elif name == 'aux':
        reads, writes = [(base, base + 4096)], []
    elif name == 'state0':
        spans = [(base, base + 262144),
                 (base + f32_offset, base + f32_offset + 4096)]
        reads, writes = spans, spans
    elif name == 'state1':
        reads, writes = [(base, base + 262144)], [(base, base + 262144)]
    elif name == 'observed':
        reads, writes = [], [(base, base + 128)]
    else:
        raise ValueError(name)
    if any(lo < base or hi > base + capacity or lo >= hi
           for lo, hi in reads + writes):
        raise ValueError(f'BO capacity mismatch on {name}')
    return reads, writes


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('case', choices=('qtype2', 'qtype1'))
    args = parser.parse_args()
    raw = BOUND.read_bytes()
    if hashlib.sha256(raw).hexdigest() != BOUND_SHA:
        raise ValueError('accepted generated-pin/page binder changed')
    binding = json.loads(raw)
    if binding['status'] != 'SOURCE_ONLY_ACTUAL_GENERATED_PINS_AND_SPARSE_PAGES_BOUND' or \
            len(binding['ordered_top_pins']) != 352 or binding['mapped_page_count'] != 206 or \
            tuple(binding['axi_ports']) != PORTS or binding['axi_data_bits'] != 32:
        raise ValueError('bound Type top geometry changed')
    case = next(x for x in json.loads((MODULE.parent / 'tb/static_mapping.json').read_text())['qtype_cases']
                if x['qtype'] == int(args.case[-1]))
    all_pins = binding['top_pins']
    ordered = binding['ordered_top_pins']
    if set(ordered) != set(all_pins) or len(set(ordered)) != 352:
        raise ValueError('pin inventory changed')
    module_name = f'type_cold_{args.case}_top'
    lines = ['`timescale 1ns/1ps',
             '// Literal generated Type pins; no warm-reset claim.',
             f'module {module_name};',
             '  logic clk=0;', '  always #3.335 clk=~clk;',
             '  logic resetn=0;',
             f'  localparam int TYPE_ID={case["qtype"]};',
             f'  localparam string CASE_NAME="{args.case}";']
    for name in ordered:
        if name in ('ap_clk', 'ap_rst_n'):
            continue
        width = all_pins[name]['width']
        lines.append(f'  logic {name};' if width == 1 else f'  logic [{width-1}:0] {name};')
    lines.extend(['  type_producer_binary_slice dut (',
                  '    .ap_clk(clk),', '    .ap_rst_n(resetn),'])
    for i, name in enumerate(x for x in ordered if x not in ('ap_clk', 'ap_rst_n')):
        lines.append(f'    .{name}({name}){"," if i < 349 else ""}')
    lines.append('  );')
    for side in ('dut', 'ram'):
        for count in CHANNEL_COUNTS:
            width = '[63:0] ' if count.endswith('bytes') else '' if count.endswith('pending') else '[31:0] '
            lines.append(f'  logic {width}{side}_{count} [0:6];')
    lines.extend(['  logic [31:0] accepted [0:6][0:4], delivered [0:6][0:4];',
                  '  logic [118:0] ram_accepted_r_record [0:6];',
                  '  logic r_hold_applied [0:6], b_hold_applied [0:6];',
                  '  logic [31:0] r_special_wait_cycles [0:6], b_special_wait_cycles [0:6];',
                  '  logic hold_final_r [0:6], hold_final_b [0:6];'])
    mapping = json.loads((MODULE.parent / 'tb/static_mapping.json').read_text())
    page_rows = binding['pages']
    for index, port in enumerate(mapping['top_ports']):
        name = port['name']
        if name != PORTS[index]:
            raise ValueError('AXI port order changed')
        base = int(port['base_hex'], 16)
        pages = [x for x in page_rows if x['port'] == name]
        pages.sort(key=lambda x: x['slot'])
        if [x['slot'] for x in pages] != list(range(len(pages))) or \
                [x['physical_base'] for x in pages] != [base + x for x in binding['page_offsets_by_port'][name]]:
            raise ValueError(f'physical page order changed: {name}')
        reads, writes = geometry(name, base, port['capacity_bytes'],
                                 case['type_q8_row_byte_offset'],
                                 case['type_f32_row_byte_offset'])
        reads += [(0, 0)] * (4 - len(reads))
        writes += [(0, 0)] * (4 - len(writes))
        fields = [x.removeprefix(f'm_axi_{name}_') for x in ordered
                  if x.startswith(f'm_axi_{name}_')]
        if len(fields) != 45 or any(f != f.upper() for f in fields):
            raise ValueError(f'AXI field inventory changed: {name}')
        lines.extend([f'  att_axi_port #(.DATA_BITS(32),.PORT({index}),.PAGE_COUNT({len(pages)}),',
                      f'                 .PAGE_BASES({packed([x["physical_base"] for x in pages])})) u_port_{name} (',
                      '    .clk(clk),.resetn(resetn),',
                      f'    .read_lo({packed([lo for lo,_ in reads])}),.read_hi({packed([hi for _,hi in reads])}),',
                      f'    .write_lo({packed([lo for lo,_ in writes])}),.write_hi({packed([hi for _,hi in writes])}),',
                      f'    .hold_final_r(hold_final_r[{index}]),.hold_final_b(hold_final_b[{index}]),',
                      f'    .r_hold_applied(r_hold_applied[{index}]),.b_hold_applied(b_hold_applied[{index}]),',
                      f'    .r_special_wait_cycles(r_special_wait_cycles[{index}]),',
                      f'    .b_special_wait_cycles(b_special_wait_cycles[{index}]),'])
        for field in fields:
            lines.append(f'    .{field.lower()}(m_axi_{name}_{field}),')
        for side in ('dut', 'ram'):
            for count in CHANNEL_COUNTS:
                lines.append(f'    .{side}_{count}({side}_{count}[{index}]),')
        lines.append(f'    .ram_accepted_r_record(ram_accepted_r_record[{index}]),')
        lines.append(f'    .accepted(accepted[{index}]),.delivered(delivered[{index}])')
        lines.append('  );')
    for bank, prefix, width in ((0, 's_axi_control', 4),
                                (1, 's_axi_control_r', 7)):
        if all_pins[f'{prefix}_AWADDR']['width'] != width or \
                all_pins[f'{prefix}_ARADDR']['width'] != width:
            raise ValueError(f'CSR address width changed: {prefix}')
        lines.extend([f'  logic lite_cmd_valid_{bank},lite_cmd_ready_{bank},lite_cmd_write_{bank},lite_cmd_done_{bank};',
                      f'  logic [{width-1}:0] lite_cmd_addr_{bank};',
                      f'  logic [31:0] lite_cmd_wdata_{bank},lite_cmd_rdata_{bank};',
                      f'  att_axi_lite_master #(.ADDR_BITS({width}),.BANK({bank})) lite_{bank} (',
                      f'    .clk(clk),.resetn(resetn),.cmd_valid(lite_cmd_valid_{bank}),',
                      f'    .cmd_ready(lite_cmd_ready_{bank}),.cmd_write(lite_cmd_write_{bank}),',
                      f'    .cmd_addr(lite_cmd_addr_{bank}),.cmd_wdata(lite_cmd_wdata_{bank}),',
                      f'    .cmd_done(lite_cmd_done_{bank}),.cmd_rdata(lite_cmd_rdata_{bank}),'])
        for i, field in enumerate(LITE_FIELDS):
            lines.append(f'    .{field.lower()}({prefix}_{field}){"," if i < len(LITE_FIELDS)-1 else ""}')
        lines.append('  );')
    lines.extend(['  `include "type_cold_control.svh"', 'endmodule'])
    output = HERE / f'{module_name}.sv'
    if output.exists():
        raise FileExistsError(output)
    output.write_text('\n'.join(lines) + '\n')
    print(f'TYPE_COLD_TOP_SOURCE case={args.case} pins={len(ordered)} pages={len(page_rows)}')


if __name__ == '__main__':
    main()
