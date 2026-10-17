#!/usr/bin/env python3
"""Make name-isolated, byte-bound copies of the eight joined funcsim banks.

The only edits are top module names and removal of seven identical, already
certified trailing glbl support capsules. This never changes the frozen export.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import sys

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
JOIN = BASE / 'results/offline_validation_20261009/attempts/ws_join_03/work/actual_join.json'
BANKS = ('ws_U', 'ws_8_U', 'ws_9_U', 'ws_10_U', 'ws_11_U', 'ws_12_U',
         'ws_13_U', 'ws_14_U')


def digest(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit('usage: prepare_capacity_sim.py FRESH_OUTPUT_DIR')
    output = Path(sys.argv[1]).resolve()
    if output.exists():
        raise SystemExit('fresh output directory required')
    join = json.loads(JOIN.read_text())
    if (join['status'] != 'STRUCTURAL_AND_PARAMETER_JOIN_ONLY_MAPPING_HELD' or
            len(join['per_bank']) != 8 or join['semantic_property_count'] != 17424):
        raise SystemExit('unexpected accepted join identity')
    exclusions = {x['bank']: x for x in join['excluded_support_modules']}
    exports = {Path(x['path']).stem: x for x in join['exports']}
    bindings = {x['bank']: x for x in join['per_bank']}
    if (set(exclusions) != set(BANKS) or set(exports) != set(BANKS) or
            set(bindings) != set(BANKS)):
        raise SystemExit('bank set mismatch')
    output.mkdir(parents=True)
    report = {'schema': 'ws_capacity_funcsim_preparation_v1',
              'join_path': str(JOIN), 'join_sha256': digest(JOIN.read_bytes()),
              'bank_sources': [], 'testbench': None}
    for index, bank in enumerate(BANKS):
        source = exports[bank]
        raw = Path(source['path']).read_bytes()
        if len(raw) != source['bytes'] or digest(raw) != source['sha256']:
            raise SystemExit(f'frozen export identity mismatch: {bank}')
        exclusion = exclusions[bank]
        start = exclusion['start_byte']
        end = exclusion['end_byte']
        if (end != len(raw) or digest(raw[start:end]) != exclusion['capsule_sha256'] or
                exclusion['state'] != 'EXCLUDED_EXACT_INSTALLED_GLBL_CAPSULE'):
            raise SystemExit(f'glbl capsule mismatch: {bank}')
        # Retain exactly one certified glbl for the whole simulation.
        body = raw if index == 0 else raw[:start]
        old_name = bindings[bank]['top_module'].encode('ascii')
        match = list(re.finditer(rb'(?m)^module\s+' + re.escape(old_name) + rb'\s*$', body))
        if len(match) != 1:
            raise SystemExit(f'not one bank module declaration: {bank}')
        declaration = match[0]
        new_name = f'ws_capacity_bank_{index}'.encode('ascii')
        prepared = (body[:declaration.start()] + b'module ' + new_name +
                    body[declaration.end():])
        path = output / f'bank_{index}.v'
        path.write_bytes(prepared)
        report['bank_sources'].append({
            'bank': bank, 'source': source, 'prepared_path': str(path),
            'prepared_bytes': len(prepared), 'prepared_sha256': digest(prepared),
            'module_rename': [old_name.decode(), new_name.decode()],
            'retained_glbl_capsule': index == 0,
            'removed_exact_glbl_capsule': index != 0})

    tb_source = Path(__file__).with_name('ws_capacity_top.sv')
    tb_raw = tb_source.read_bytes()
    tb_prepared = tb_raw.replace(b'// WS_BANK_INSTANCES\n', b''.join(
        (f'  ws_capacity_bank_{i} bank_{i} '
         f'(.address0(address0), .ce0(ce0), .q0(q[{i}]), '
         f'.address1(address1), .ce1(ce1), .d1(d[{i}]), '
         f'.we1(we1), .reset(reset), .clk(clk));\n').encode()
        for i in range(8)))
    if tb_prepared == tb_raw or b'// WS_BANK_INSTANCES' in tb_prepared:
        raise SystemExit('testbench substitution failed')
    tb_path = output / 'ws_capacity_top.sv'
    tb_path.write_bytes(tb_prepared)
    report['testbench'] = {'source_path': str(tb_source),
                           'source_sha256': digest(tb_raw),
                           'prepared_path': str(tb_path),
                           'prepared_sha256': digest(tb_prepared)}
    (output / 'preparation.json').write_text(json.dumps(report, indent=2,
                                                       sort_keys=True) + '\n')
    print('WS_CAPACITY_PREPARED banks=8 source=matched_join')


if __name__ == '__main__':
    main()
