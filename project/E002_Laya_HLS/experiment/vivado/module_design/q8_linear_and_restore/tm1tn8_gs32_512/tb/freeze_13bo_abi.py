#!/usr/bin/env python3
"""Extract pointer/control ABI and bus widths from actual generated RTL."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROLES = 'embedding io w_q0 w_q1 w_scale aux state0 state1 qkv0 qkv1 ff0 ff1 att_out'.split()


def record(p):
    return dict(path=str(p.resolve()), bytes=p.stat().st_size,
                sha256=hashlib.sha256(p.read_bytes()).hexdigest())


def extract(directory, top):
    files = [directory / (top + suffix + '.v') for suffix in ['', '_control_s_axi', '_control_r_s_axi']]
    source, control, pointers = [p.read_text() for p in files]
    offsets = {}
    for role in ROLES:
        pair = []
        for half in [0, 1]:
            pattern = r'\bADDR_' + role.upper() + r'_R_DATA_' + str(half) + r'\s*=\s*8\x27h([0-9a-fA-F]+)'
            found = re.findall(pattern, pointers)
            assert len(found) == 1, (role, half, found)
            pair.append(int(found[0], 16))
        offsets[role] = pair
        assert pair[1] == pair[0] + 4
        assert re.search(r'output\s+wire\s+\[63:0\]\s+' + role + '_r\\b', pointers), role
    def parameter(name):
        found = re.findall(r'parameter\s+' + name + r'\s*=\s*(\d+)\s*;', source)
        assert len(found) == 1, (name, found)
        return int(found[0])
    abi = dict(pointer_offsets=offsets,
               control_address_bits=parameter('C_S_AXI_CONTROL_ADDR_WIDTH'),
               pointer_address_bits=parameter('C_S_AXI_CONTROL_R_ADDR_WIDTH'),
               control_data_bits=parameter('C_S_AXI_CONTROL_DATA_WIDTH'),
               pointer_data_bits=parameter('C_S_AXI_CONTROL_R_DATA_WIDTH'),
               buses={role: dict(data_bits=parameter('C_M_AXI_' + role.upper() + '_DATA_WIDTH'),
                                address_bits=parameter('C_M_AXI_' + role.upper() + '_ADDR_WIDTH'))
                      for role in ROLES})
    assert len(set(x for v in offsets.values() for x in v)) == 26
    assert abi['control_data_bits'] == abi['pointer_data_bits'] == 32
    return dict(abi=abi, files=[record(p) for p in files])


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--rtl', type=Path, required=True)
    p.add_argument('--top', default='laya_typed_q8_forward')
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--reference', type=Path)
    args = p.parse_args()
    result = extract(args.rtl.resolve(), args.top)
    if args.reference:
        reference = json.loads(args.reference.read_text())['abi']
        for name in ['pointer_offsets', 'control_address_bits', 'pointer_address_bits',
                     'control_data_bits', 'pointer_data_bits']:
            assert result['abi'][name] == reference[name], name
        result['reference'] = record(args.reference)
    args.output.mkdir(parents=True, exist_ok=False)
    result['scope'] = 'Actual generated ABI extraction; historical generation is a control reference, not current production RTL proof.'
    result['generator'] = record(Path(__file__))
    (args.output / 'abi.json').write_text(json.dumps(result, indent=2) + '\n')
    package = '`timescale 1ns/1ps\npackage laya_13bo_abi_v1;\n'
    for index, role in enumerate(ROLES):
        lo, hi = result['abi']['pointer_offsets'][role]
        package += f"  localparam logic [7:0] {role.upper()}_LOW=8'h{lo:02x}, {role.upper()}_HIGH=8'h{hi:02x};\n"
    package += '  function automatic int role_of(input logic [7:0] address);\n    case(address)\n'
    for index, role in enumerate(ROLES):
        package += f'      {role.upper()}_LOW,{role.upper()}_HIGH: return {index};\n'
    package += '      default:return -1;\n    endcase\n  endfunction\n'
    package += '  function automatic bit high_half(input logic [7:0] address);\n    case(address)\n'
    package += '      ' + ','.join(role.upper() + '_HIGH' for role in ROLES) + ':return 1;\n'
    package += '      default:return 0;\n    endcase\n  endfunction\nendpackage\n'
    (args.output / 'laya_13bo_abi_v1.sv').write_text(package)
    print('FULL_CURRENT_13BO_ABI_EXTRACTED roles=13 pointer_words=26')


if __name__ == '__main__':
    main()
