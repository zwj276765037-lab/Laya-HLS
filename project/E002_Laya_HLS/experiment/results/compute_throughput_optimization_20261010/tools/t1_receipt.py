#!/usr/bin/env python3
"""Summarize frozen front16 XSim runs without treating a log marker as a guard PASS."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
MODULE = ROOT / 'vivado/module_design/layernorm_engine'
USEFUL_TOTAL = 65536 + 65536 + 4096 + 65536
RUNS = {'wide-normal': ('wide', 'formal_normal_02', 'static_02'),
        'byte-normal': ('byte', 'formal_normal_02', 'static_02'),
        'wide-pressure': ('wide', 'formal_pressure_02', 'static_04'),
        'byte-pressure': ('byte', 'formal_pressure_02', 'static_04'),
        'wide-normal-adapter': ('wide', 'formal_normal_adapter_01', 'static_04'),
        'byte-normal-adapter': ('byte', 'formal_normal_adapter_01', 'static_04')}


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1 << 20), b''):
            h.update(data)
    return h.hexdigest()


def one(key: str) -> dict:
    mode, name, static_name = RUNS[key]
    profile = key.split('-')[1]
    run = MODULE / 'rtl' / f'front16_{mode}' / name
    log = (run / 'xsim.log').read_text()
    guard = json.loads((run / 'guard/guard_result.json').read_text())
    assert guard['child_exit_code'] == 0 and guard['trigger'] is None, key
    assert 'FRONT16_MEM_PASS raw_f32=16384 norm_f32=16384 norm_max_abs=0 norm_max_rel=0 local_crc32c=d5c15b0f' in log, key
    assert not re.search(r'(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)', log), key
    match = re.search(r'FRONT16_RTL_PASS mode=(\w+) pressure=(\d+) cycles=(\d+) r_hold_cycles=(\d+) b_hold_cycles=(\d+)', log)
    assert match and match.group(1) == mode and int(match.group(2)) == (key.endswith('pressure')), key
    cycles = int(match.group(3))
    holds = {'r_cycles': int(match.group(4)), 'b_cycles': int(match.group(5))}
    if key.endswith('pressure'):
        assert holds == {'r_cycles': 4, 'b_cycles': 4}, (key, holds)
    else:
        assert holds == {'r_cycles': 0, 'b_cycles': 0}, (key, holds)
    ports = {}
    for line in re.findall(r'^FRONT16_PORT .*$', log, re.M):
        values = dict((name, int(value)) for name, value in re.findall(r'(\w+)=(\d+)', line))
        ports[values.pop('port')] = values
    assert set(ports) == {0, 1, 2, 3}, key
    assert ports[0]['transfer_read_bytes'] == 131072 and ports[1]['transfer_read_bytes'] == 4096
    assert ports[2]['strobed_write_bytes'] == 65536 and ports[3]['strobed_write_bytes'] == 256
    arith = re.search(r'FRONT16_ARITH starts=(\d+) dones=(\d+) first_cycle=(\d+) last_cycle=(\d+)', log)
    assert arith, key
    # HLS child ap_done is also high in its idle state before any call:
    # (ap_CS_fsm_state1 && !ap_start). The edge monitor therefore sees one
    # initial idle assertion in addition to the 16 real row completions.
    assert int(arith.group(1)) == 16 and int(arith.group(2)) == 17, key
    stalls = {}
    for line in re.findall(r'^FRONT16_STALL .*$', log, re.M):
        role = re.search(r'port=(\w+)', line).group(1)
        values = dict((name, int(value)) for name, value in re.findall(r'(\w+)=(\d+)', line))
        # These two text fields are generator constants, not sampled peaks.
        if 'max_read_outstanding' in values:
            assert values.pop('max_read_outstanding') == 1
            assert values.pop('max_write_outstanding') == 1
        else:
            assert values.pop('endpoint_read_capacity') == 1
            assert values.pop('endpoint_write_capacity') == 1
        stalls[role] = values
    hist = {'AR': {}, 'AW': {}}
    for kind in ('AR', 'AW'):
        for line in re.findall(rf'^FRONT16_{kind}LEN .*$', log, re.M):
            role = re.search(r'port=(\w+)', line).group(1)
            length = int(re.search(r'len=(\d+)', line).group(1))
            count = int(re.search(r'count=(\d+)', line).group(1))
            hist[kind].setdefault(role, {})[length] = count
    files = ['runner.sh', 'fixture_manifest.json', 'frozen_inputs.sha256',
             'xsim.log', 'front16_actual_norm.bin', 'front16_norm_seen.bin',
             'front16_actual_observed.bin', 'guard/guard_result.json',
             'guard/guard_plan.json', 'guard/policy_checks.json']
    frozen = MODULE / 'rtl' / f'front16_{mode}' / static_name
    hls_root = MODULE / 'rtl' / f'front16_{mode}' / 'hls'
    files_in_static = ['frozen_source/front16_top.sv',
                       'frozen_source/front16_axi_memory.sv',
                       'frozen_source/front16_mem.c',
                       'frozen_source/front16_make_top.py',
                       'xvlog_dut.log', 'xvlog_tb.log', 'xvhdl.log', 'xelab.log']
    frozen_top = (frozen / 'frozen_source/front16_top.sv').read_text()
    command_line = re.search(r'FRONT16_COMMAND start_cycle=(\d+) done_cycle=(\d+) command_cycles=(\d+) reset_counter=(\d+)', log)
    if command_line:
        start, done, elapsed, reset_counter = map(int, command_line.groups())
        assert elapsed == done - start == cycles and reset_counter == done, key
        command_timing = {'status': 'DIRECTLY_OBSERVED', 'start_cycle': start,
                          'first_done_cycle': done, 'start_to_done_cycles': elapsed}
        cycle_basis = 'TOP_START_TO_FIRST_DONE'
    else:
        # Both static_02 and static_04 use the same deterministic AXI-Lite
        # launch. After reset release, launch rises at the fifth negedge;
        # counter 5 accepts AW, 6 accepts W, and 7 accepts top ap_start in
        # FSM state1. No waveform or direct start timestamp was saved.
        assert static_name in ('static_02', 'static_04'), key
        for snippet in ('repeat (20) @(negedge ap_clk);',
                        'repeat (5) @(negedge ap_clk);',
                        'launch=1;', 'cycles<=cycles+1;',
                        'assign s_axi_control_AWVALID=launch && !aw_sent;',
                        'assign s_axi_control_WVALID=launch && !w_sent;'):
            assert snippet in frozen_top, (key, snippet)
        control = (hls_root / f'syn/verilog/laya_front16_{mode}_control_s_axi.v').read_text()
        generated_top = (hls_root / f'syn/verilog/laya_front16_{mode}.v').read_text()
        for snippet in ('assign AWREADY = (wstate == WRIDLE);',
                        'assign WREADY  = (wstate == WRDATA);',
                        'assign aw_hs   = AWVALID & AWREADY;',
                        'assign w_hs    = WVALID & WREADY;',
                        "if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])",
                        "int_ap_start <= 1'b1;", 'assign ap_start          = int_ap_start;'):
            assert snippet in control, (key, snippet)
        assert "if (((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1)))" in generated_top, key
        command_timing = {'status': 'DERIVED_FROM_FROZEN_CONTROL_HANDSHAKES',
                          'start_cycle': 7, 'first_done_cycle': cycles,
                          'start_to_done_cycles': cycles - 7,
                          'derivation': 'TB counter 5 AW handshake in WRIDLE; counter 6 W handshake in WRDATA sets int_ap_start; counter 7 top FSM state1 accepts ap_start. Source hashes are recorded in files.'}
        cycle_basis = 'TB_RESET_TO_DONE'
    compiled_sources = sorted((hls_root / 'syn/verilog').glob('*.v'))
    compiled_sources += sorted((hls_root / 'syn/verilog').glob('*.dat'))
    compiled_sources += sorted((hls_root / 'impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip').glob('*/sim/*_ip.vhd'))
    assert compiled_sources, key
    adapter_lines = re.findall(r'^FRONT16_ADAPTER .*$', log, re.M)
    adapter = {'status': 'NOT_OBSERVED', 'reason': 'static_02 normal run predates I_CH0 probe'}
    if adapter_lines:
        assert len(adapter_lines) == 4, key
        adapter_ports = {}
        for line in adapter_lines:
            values = {name: int(value) for name, value in re.findall(r'(\w+)=(\d+)', line)}
            port = values.pop('port')
            assert port not in adapter_ports, key
            assert all(values[f'pending_{channel}'] == 0 for channel in ('AR', 'R', 'AW', 'W', 'B')), key
            assert values['RFIFONUM'] == 0 and values['AR_elems'] == values['R_elems'], key
            assert values['AW'] == values['B'] and values['AW_elems'] == values['W'], key
            adapter_ports[port] = values
        assert set(adapter_ports) == {0, 1, 2, 3}, key
        adapter = {'status': 'PASS', 'ports': adapter_ports,
                   'sampling': 'same first-done rising edge, after NBA at +2ps'}
    return {'status': 'PASS', 'mode': mode, 'profile': profile,
            'static_snapshot': static_name,
            'cycles': cycles, 'cycle_basis': cycle_basis,
            'command_timing': command_timing,
            'useful_bytes_per_cycle': USEFUL_TOTAL / cycles,
            'useful_bytes_per_command_cycle': USEFUL_TOTAL / command_timing['start_to_done_cycles'],
            'useful_bytes': USEFUL_TOTAL, 'hold': holds, 'ports': ports,
            'arith': {'start_rising_edges': int(arith.group(1)),
                      'done_rising_edges_raw': int(arith.group(2)),
                      'initial_idle_done_assertion_excluded': 1,
                      'paired_row_completions': int(arith.group(2)) - 1,
                      'basis': 'Generated layernorm_row_arithmetic.v asserts ap_done in FSM state1 while ap_start=0, before the first accepted call; subsequent 16 row calls produce the remaining done edges.',
                      'first_cycle': int(arith.group(3)), 'last_cycle': int(arith.group(4))},
            'outstanding': {'basis': 'Endpoint ARREADY gates !rd_active; AWREADY gates !wr_active && !b_valid. Each accepted AR/AW creates one active transaction; accepted transaction counts are recorded above.',
                            'endpoint_capacity_bound': {'read': 1, 'write': 1},
                            'peak_inferred_from_handshakes': {
                                str(port): {'read': 1 if item['AR'] else 0,
                                            'write': 1 if item['AW'] else 0}
                                for port, item in ports.items()}},
            'stalls': stalls, 'burst_len_hist': hist, 'adapter_first_done': adapter,
            'guard': guard,
            'files': [{'path': str(run / f), 'sha256': sha(run / f)} for f in files] +
                     [{'path': str(frozen / f), 'sha256': sha(frozen / f)}
                      for f in files_in_static] +
                     [{'path': str(f), 'sha256': sha(f)} for f in compiled_sources]}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('runs', nargs='+', choices=RUNS)
    args = parser.parse_args()
    results = {name: one(name) for name in args.runs}
    comparisons = {}
    for profile in ('normal', 'pressure', 'normal-adapter'):
        byte, wide = results.get(f'byte-{profile}'), results.get(f'wide-{profile}')
        if byte and wide:
            byte_cycles = byte['command_timing']['start_to_done_cycles']
            wide_cycles = wide['command_timing']['start_to_done_cycles']
            comparisons[profile] = {'cycle_basis': 'TOP_START_TO_FIRST_DONE',
                                    'byte_command_cycles': byte_cycles,
                                    'wide_command_cycles': wide_cycles,
                                    'cycle_reduction': byte_cycles - wide_cycles,
                                    'cycle_reduction_percent': 100 * (
                                        byte_cycles - wide_cycles) / byte_cycles,
                                    'speedup': byte_cycles / wide_cycles}
    receipt = {'scope': 'T1 front16 local 16-row RTL microbenchmark',
               'status': 'PASS', 'runs': results, 'comparisons': comparisons,
               'production_full_128_rows': 'NOT_RUN',
               'board_xrt_hbm': 'NOT_MEASURED'}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
    print(json.dumps({'out': str(args.out.resolve()), 'comparisons': comparisons}))


if __name__ == '__main__':
    main()
