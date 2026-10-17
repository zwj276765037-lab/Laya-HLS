#!/usr/bin/env python3
"""Independently compare a later sealed mode3 XSim result to frozen CPU bytes."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

from check_cpu_gold import FIXTURE, checked, cpu_expected_words, sha

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
REVIEW = BASE / 'results/attention_rtl_repair_20261008'
RELEASE = REVIEW / 'reviewer_d2_i_vector_mode3_static_source_preparation_release.json'
PREDICTION = REVIEW / 'd2_i_vector_mode3_static_schedule_ports_budget_precheck.json'
ERRATUM = REVIEW / 'd2_i_vector_mode3_static_schedule_ports_budget_precheck_io_scope_erratum.json'
RELEASE_SHA = '853ff64b50b2fb1d879453e6aff8759222d5c949e94916cc0b26c8ac72882466'
PREDICTION_SHA = 'cc2b6dfb20af23caa5f9e1f5f951f0de5cb830b193c43057d7f155cda9a1bb5d'
ERRATUM_SHA = '623518d02b2ae86e463ba9df30bd12cdc085d25e3f8f47ee2c7844ffcda75e2f'
PORTS = ('src0_input', 'src1_input', 'io', 'aux', 'state0', 'state1', 'observed')
PAGE = 4096


def one_line_hex(path: Path, length: int) -> bytes:
    value = path.read_text(encoding='ascii')
    if len(value) != length * 2 + 1 or not value.endswith('\n') or re.fullmatch(r'[0-9a-f]+', value[:-1]) is None:
        raise ValueError(f'raw XSim dump shape: {path}')
    return bytes.fromhex(value[:-1])


def first_difference(label: str, got: bytes, expected: bytes) -> None:
    if got == expected:
        return
    if len(got) != len(expected):
        raise ValueError(f'{label} length {len(got)} != {len(expected)}')
    index = next(i for i, (a, b) in enumerate(zip(got, expected)) if a != b)
    raise ValueError(f'{label} byte {index}: {got[index]:02x} != {expected[index]:02x}')


def unique(pattern: str, log: str, label: str) -> re.Match[str]:
    matches = list(re.finditer(pattern, log, re.M))
    if len(matches) != 1:
        raise ValueError(f'{label} count={len(matches)}')
    return matches[0]


def verify_log(log: str, prediction: dict) -> dict:
    if re.search(r'^\s*(?:ERROR:|FATAL:|\$fatal)', log, re.M | re.I):
        raise ValueError('simulator log reports fatal/error')
    source = (Path(__file__).with_name('vector_mode3_control.svh')).read_text()
    fatal_labels = set(re.findall(r'\$fatal\(1,"(D2_MODE3_[A-Z0-9_]+)', source))
    for label in fatal_labels:
        if re.search(r'\b' + re.escape(label) + r'\b', log):
            raise ValueError(f'testbench fatal label in simulator log: {label}')
    for prefix in ('ATT_AXI_', 'ATT_STALL_', 'ATT_LITE_', 'AXI_STATIC_'):
        if prefix in log:
            raise ValueError(f'accepted endpoint fatal label in simulator log: {prefix}')
    accepted = unique(r'^D2_MODE3_AP_ACCEPT cycle=(\d+) state1=1$', log, 'AP accepted start')
    first = unique(r'^D2_MODE3_FIRST_DONE accepted_to_done=(\d+) total_cycle=(\d+) ap_ready=1 physical_and_adapter_drained=1$', log, 'first done')
    passed = unique(r'^D2_MODE3_STATIC_MODE3_PASS candidates=16 mapped_pages=14 dut_cycles=(\d+) total_cycles=(\d+)$', log, 'PASS')
    start_cycle, dut_cycles, done_cycle, pass_cycles = map(int, (accepted[1], first[1], first[2], passed[1]))
    if done_cycle - start_cycle != dut_cycles or pass_cycles != dut_cycles:
        raise ValueError('start/done cycle accounting')
    hold = unique(r'^D2_MODE3_HOLDS raw_r_count=(\d+) raw_r_cycles=(\d+) masked_b_count=(\d+) masked_b_cycles=(\d+) final_aw=([0-9a-f]+) len=(\d+) size=(\d+) final_w_strb=([0-9a-f]+) final_w_last=1$', log, 'terminal hold')
    if [int(hold[i]) for i in (1, 3)] != [1, 1] or min(int(hold[2]), int(hold[4])) < 16:
        raise ValueError('terminal hold count or duration')
    if (int(hold[5], 16), int(hold[6]), int(hold[7]), int(hold[8], 16)) != (0x3501022840 + 60, 0, 2, 8):
        raise ValueError('masked final AW/W identity')
    port_expect = prediction['physical_AXI_static_prediction']['per_port']
    seen = set()
    for match in re.finditer(r'^D2_MODE3_PORT port=(\d+) side=(dut|ram) ar=(\d+) r=(\d+) rlast=(\d+) aw=(\d+) w=(\d+) b=(\d+) read_bus=(\d+) write_bus=(\d+) write_useful=(\d+) wr_pending=0 rd_pending=0$', log, re.M):
        port = int(match[1]); side = match[2]
        key = (port, side)
        if key in seen or port >= 7:
            raise ValueError('duplicate/invalid port summary')
        seen.add(key)
        actual = list(map(int, match.groups()[2:]))
        expected = port_expect[PORTS[port]]
        keys = ('AR', 'R', 'AR', 'AW', 'W', 'B', 'physical_read_bus_bytes',
                'physical_write_bus_bytes', 'logical_write_bytes')
        wanted = [expected[k] for k in keys]
        if actual != wanted:
            raise ValueError(f'{side} {PORTS[port]} physical totals {actual} != prediction {wanted}')
    if seen != {(p, side) for p in range(7) for side in ('dut', 'ram')}:
        raise ValueError(f'incomplete seven-port physical summaries: {len(seen)}')
    adapter_lines = list(re.finditer(r'^D2_MODE3_ADAPTER port=(\d+) channel=(\d+) accepted=(\d+) delivered=(\d+) debt=0$', log, re.M))
    if len(adapter_lines) != 35 or {(int(m[1]), int(m[2])) for m in adapter_lines} != {(p, c) for p in range(7) for c in range(5)}:
        raise ValueError('adapter debt summary')
    if any(m[3] != m[4] for m in adapter_lines):
        raise ValueError('adapter accepted/delivered mismatch')
    return {'accepted_cycle': start_cycle, 'first_done_cycle': done_cycle,
            'accepted_to_first_done_cycles': dut_cycles,
            'total_clock_at_pass': int(passed[2]),
            'terminal_raw_r_hold_cycles': int(hold[2]),
            'terminal_masked_b_hold_cycles': int(hold[4]),
            'per_port_physical_counts_checked_both_sides': 14,
            'adapter_channels_drained': 35}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('runtime', type=Path)
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    for path, digest in ((RELEASE, RELEASE_SHA), (PREDICTION, PREDICTION_SHA), (ERRATUM, ERRATUM_SHA)):
        if sha(path.read_bytes()) != digest:
            raise ValueError(f'frozen authority changed: {path}')
    release = json.loads(RELEASE.read_text())
    prediction = json.loads(PREDICTION.read_text())
    erratum = json.loads(ERRATUM.read_text())
    if erratum['clarification']['DUT_IO_unique_byte_offsets_inclusive'] != [0, 831]:
        raise ValueError('mandatory IO scope erratum')
    fixture = json.loads((FIXTURE / 'fixture_report.json').read_text())
    request = bytearray(checked('request', fixture))
    source = checked('candidate', fixture)
    gold = checked('candidate_gold', fixture)
    if cpu_expected_words(request, source) != list(struct.unpack('<16I', gold)):
        raise ValueError('frozen CPU gold arithmetic mismatch')
    request[24:32] = (305).to_bytes(8, 'little')
    state1 = one_line_hex(args.runtime / 'state1_raw.hex', PAGE)
    observed = one_line_hex(args.runtime / 'observed_raw.hex', PAGE)
    state_page_offset = release['static_pages']['state1']['physical_page_offset']
    raw_at = release['static_pages']['state1']['raw_write_read_offset_range'][0] - state_page_offset
    masked_at = release['static_pages']['state1']['masked_write_offset_range'][0] - state_page_offset
    expected_state = bytearray(b'\xa5' * PAGE)
    expected_state[raw_at:raw_at + 64] = source
    expected_state[masked_at:masked_at + 64] = gold
    first_difference('state1 full mapped page', state1, expected_state)
    words = [0xffffffff] * 32
    for key, value in release['exact_observed_words'].items():
        if key != '19_through31':
            words[int(key)] = value
    expected_observed = struct.pack('<32I', *words) + b'\xa5' * (PAGE - 128)
    first_difference('observed full mapped page', observed, expected_observed)
    first_difference('raw candidate payload', state1[raw_at:raw_at + 64], source)
    first_difference('masked F32 bit patterns including signed zero', state1[masked_at:masked_at + 64], gold)
    log_path = args.runtime / 'xsim.log'
    log = log_path.read_text(errors='replace')
    metrics = verify_log(log, prediction)
    result = {'schema': 'd2_i_mode3_independent_runtime_numeric_check_v1',
              'status': 'PASS', 'release_sha256': RELEASE_SHA,
              'prediction_sha256': PREDICTION_SHA, 'io_erratum_sha256': ERRATUM_SHA,
              'source_request_sha256': fixture['files']['request']['sha256'],
              'patched_request_sha256': sha(request),
              'candidate_sha256': sha(source), 'cpu_gold_sha256': sha(gold),
              'state1_dump_sha256': sha(state1), 'observed_dump_sha256': sha(observed),
              'xsim_log_sha256': sha(log_path.read_bytes()),
              'f32_exact_words': 16, 'mapped_state1_bytes_checked': PAGE,
              'observed_words_checked': 32, 'observed_tail_bytes_checked': PAGE - 128,
              'metrics': metrics}
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print('D2_MODE3_RUNTIME_NUMERIC_PASS candidates=16 observed_words=32')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
