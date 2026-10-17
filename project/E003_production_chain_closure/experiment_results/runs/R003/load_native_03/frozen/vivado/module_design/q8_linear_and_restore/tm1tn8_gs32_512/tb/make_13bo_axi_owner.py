#!/usr/bin/env python3
"""Generate named 13BO AXI bindings; preserve all historical interface bits."""
import json
from pathlib import Path
import re

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
ROLES = ['embedding', 'io', 'w_q0', 'w_q1', 'w_scale', 'aux', 'state0',
         'state1', 'qkv0', 'qkv1', 'ff0', 'ff1', 'att_out']
FIELDS = {'addr': 64, 'id': 1, 'size': 3, 'burst': 2, 'lock': 2,
          'cache': 4, 'prot': 3, 'qos': 4, 'region': 4, 'user': 1,
          'len': 8, 'data': 32, 'strb': 4, 'resp': 2,
          'valid': 1, 'ready': 1, 'last': 1}
CHANNELS = {
    'ar': ['addr', 'id', 'len', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user', 'valid', 'ready'],
    'aw': ['addr', 'id', 'len', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user', 'valid', 'ready'],
    'w': ['data', 'strb', 'id', 'user', 'last', 'valid', 'ready'],
    'r': ['data', 'resp', 'id', 'user', 'last', 'valid', 'ready'],
    'b': ['resp', 'id', 'user', 'valid', 'ready']}
PAYLOADS = {'ar': ['addr', 'id', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user'],
            'aw': ['addr', 'id', 'size', 'burst', 'lock', 'cache', 'prot', 'qos', 'region', 'user'],
            'w': ['data', 'strb', 'id', 'user'], 'r': ['data', 'resp', 'id', 'user'],
            'b': ['resp', 'id', 'user']}
PWIDTH = {'ar': 96, 'aw': 96, 'w': 38, 'r': 36, 'b': 4}


def owner_input(ch, field):
    return (ch in ('ar', 'aw', 'w')) != (field == 'ready')


def main():
    reference = ROOT / 'vivado/project/build/20261008T022231Z-2961016/stage/rtl_verilog/laya_typed_q8_forward.v'
    raw = reference.read_text()
    expressions = dict(re.findall(r'parameter\s+(\w+)\s*=\s*([^;]+);', raw))
    parameters = {}
    for _ in range(4):
        for key, expr in expressions.items():
            for known, value in parameters.items():
                expr = re.sub(r'\b' + known + r'\b', str(value), expr)
            if re.fullmatch(r'[0-9 +\-*/()]+', expr.strip()):
                parameters[key] = int(eval(expr.replace('/', '//'), {'__builtins__': {}}))
    # Reject a new generated width rather than silently truncate a signal.
    for role in ROLES:
        for ch, fields in CHANNELS.items():
            for field in fields:
                name = 'm_axi_' + role + '_' + ch.upper() + field.upper()
                match = re.search(r'(input|output)\s*(?:\[([^]]+)\])?\s+' + name + r'\s*;', raw)
                assert match, name
                width = 1
                if match[2]:
                    expr = match[2]
                    for key in sorted(parameters, key=len, reverse=True):
                        expr = re.sub(r'\b' + key + r'\b', str(parameters[key]), expr)
                    high, low = expr.split(':')
                    assert re.fullmatch(r'[0-9 +\-]+', high) and re.fullmatch(r'[0-9 +\-]+', low), expr
                    width = eval(high, {'__builtins__': {}}) - eval(low, {'__builtins__': {}}) + 1
                assert width == FIELDS[field], (name, width, FIELDS[field])
                assert (match[1] == 'output') == owner_input(ch, field), name
    ports = [('input', '', 'clk'), ('input', '', 'rst_n'),
             ('input', '[12:0]', 'desired_owner'), ('input', '[12:0]', 'clear_error'),
             ('output', '[12:0]', 'selected_owner'), ('output', '[12:0]', 'debt_zero'),
             ('output', '[12:0]', 'protocol_error')]
    for ch, fields in CHANNELS.items():
        for field in fields:
            width = '' if FIELDS[field] == 1 else f'[{FIELDS[field]-1}:0]'
            direction = 'input' if owner_input(ch, field) else 'output'
            ports += [(direction, '[12:0][1:0]' + width, 'owner_' + ch + field),
                      ('output' if direction == 'input' else 'input', '[12:0]' + width, 'memory_' + ch + field)]
    for count in ['accepted_ar', 'returned_r', 'accepted_aw', 'accepted_w', 'returned_b']:
        ports += [('output', '[12:0][31:0]', count)]
    s = '''`timescale 1ns/1ps
// Generated from actual historical 13BO declarations, with all bits checked.
// Controller is owner0, converted physical service is owner1. Active cancel
// changes desired_owner only; rst_n is cold fabric reset.
module laya_axi_13bo_owner_v1 (
'''
    s += ',\n'.join(f'  {d} logic {w} {n}'.replace('logic  ', 'logic ') for d, w, n in ports) + '\n);\n'
    for ch, width in PWIDTH.items():
        s += f'  logic [12:0][1:0][{width-1}:0] owner_{ch}_payload;\n'
        s += f'  logic [12:0][{width-1}:0] memory_{ch}_payload;\n'
    s += '  for(genvar bo=0;bo<13;bo++)begin : bo_owner\n'
    for ch, fields in PAYLOADS.items():
        payload_bits = sum(FIELDS[f] for f in fields)
        zero = PWIDTH[ch] - payload_bits
        for prefix in ('owner', 'memory'):
            for suffix in (('[bo][o]', '[bo][o]'),) if prefix == 'owner' else (('[bo]', '[bo]'),):
                lhs = '{' + ','.join(prefix + '_' + ch + f + suffix[0] for f in fields) + '}'
                packed = prefix + '_' + ch + '_payload' + suffix[1]
                incoming = owner_input(ch, fields[0]) if prefix == 'owner' else not owner_input(ch, fields[0])
                if prefix == 'owner':
                    s += '    for(genvar o=0;o<2;o++)begin : ' + ch + '_pack\n'
                if incoming:
                    s += f'      assign {packed}=' + ("{" + str(zero) + "'d0," + lhs + "}" if zero else lhs) + ';\n'
                else:
                    s += f'      assign {lhs}={packed}[{payload_bits-1}:0];\n'
                if prefix == 'owner':
                    s += '    end\n'
    s += '    laya_axi_owner_v1 arbiter(\n'
    binds = ['.clk', '.rst_n']
    binds += [f'.{n}({n}[bo])' for n in ['desired_owner', 'clear_error', 'selected_owner', 'debt_zero', 'protocol_error']]
    for ch, fields in CHANNELS.items():
        binds += [f'.owner_{ch}_payload(owner_{ch}_payload[bo])', f'.memory_{ch}_payload(memory_{ch}_payload[bo])']
        for field in fields:
            if field in PAYLOADS[ch]:
                continue
            binds += [f'.{prefix}_{ch}{field}({prefix}_{ch}{field}[bo])' for prefix in ('owner', 'memory')]
    binds += [f'.{n}({n}[bo])' for n in ['accepted_ar', 'returned_r', 'accepted_aw', 'accepted_w', 'returned_b']]
    s += ',\n'.join('      ' + x for x in binds) + '\n    );\n  end\nendmodule\n'
    (MODULE / 'rtl/laya_axi_13bo_owner_v1.sv').write_text(s)
    (MODULE / 'tb/laya_axi_13bo_ports_v1.json').write_text(json.dumps({'ports': ports, 'payloads': PAYLOADS,
        'field_widths': FIELDS, 'payload_widths': PWIDTH, 'roles': ROLES,
        'reference': str(reference)}, indent=2) + '\n')
    print('FULL_CURRENT_13BO_OWNER_GENERATED roles=13 signal_fields=' + str(sum(map(len, CHANNELS.values()))))


if __name__ == '__main__':
    main()
