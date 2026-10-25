#!/usr/bin/env python3
"""Read-only inverse-source proof; no HDL frontend, RTL or mathematical model."""
from pathlib import Path
import argparse
import ctypes
import hashlib
import json
import os
import re
import resource
import time


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    start = time.monotonic()
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    root = args.root.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_AS, (1024**3, 1024**3))
    affinity = sorted(os.sched_getaffinity(0))
    nice = os.getpriority(os.PRIO_PROCESS, 0)
    io = ctypes.CDLL(None).syscall(252, 1, 0)
    available = int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines()
                         if x.startswith('MemAvailable:')))
    assert affinity and set(affinity) <= set(range(4)) and nice == 19 and io >> 13 == 3
    assert available > 192 * 1024 * 1024
    r = root / 'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
    manifest = r / 'prepared/binary_peer_posedge_unrolled_v2/source_manifest.json'
    d = json.loads(manifest.read_text())
    old_path = root / d['previous_source']
    new_path = root / d['source']
    assert sha(old_path) == d['previous_sha256'] == '4d9265c219d1712327c31a0a0f3558d858563e84f0dc83374fc9431a0d31abe8'
    assert sha(new_path) == sha(root / d['live_source']) == d['sha256']
    before, after = old_path.read_text(), new_path.read_text()
    head = '   for(int p=0;p<4;p++)begin\n'
    start_loop = before.index(head, before.index(' always@(posedge clk)begin\n'))
    end_loop = before.index('   live=0;', start_loop)
    old_loop = before[start_loop:end_loop]
    body = old_loop[len(head):-len('   end\n')]
    replacement_start = after.index('   begin : m007_peer_posedge_port_0\n')
    replacement_end = after.index('   live=0;', replacement_start)
    new_loop = after[replacement_start:replacement_end]
    expected = ''.join(f'   begin : m007_peer_posedge_port_{p}\n'
                       + re.sub(r'\bp\b', str(p), body) + '   end\n' for p in range(4))
    assert new_loop == expected
    assert after[:replacement_start] == before[:start_loop]
    assert after[replacement_end:] == before[end_loop:]
    assert after[:replacement_start] + old_loop + after[replacement_end:] == before
    assert body.count('<=') == 8
    assert before.count('always@(posedge clk)') == after.count('always@(posedge clk)')
    assert 'accepted_ar++;' in body and 'returned_beats++;' in body
    for p in range(4):
        segment = re.sub(r'\bp\b', str(p), body)
        assert segment.count('<=') == 8
        assert segment.index('if(arvalid[') < segment.index('if(rvalid[')
    previous = json.loads((root / d['prior_fullgraph_manifest']).read_text())
    assert d['compile_source_count'] == len(d['compile_sources']) == 94
    changed = []
    for a, b in zip(previous['compile_sources'], d['compile_sources']):
        assert sha(root / b['path']) == b['sha256']
        if a != b:
            changed.append((a, b))
    assert len(changed) == 1
    assert changed[0][0]['path'] == d['previous_source']
    assert changed[0][1]['path'] == d['source']
    assert d['fullgraph_top_sha256'] == '8b556ca2b32f2a41f7ca1d259d5f7c714a8dd473d131e8949f6dcabd1a3ea570'
    assert sha(root / d['fullgraph_top_source']) == d['fullgraph_top_sha256']
    assert previous['ROM_initialization_files'] == d['ROM_initialization_files']
    for row in d['ROM_initialization_files']:
        assert sha(root / row['path']) == row['sha256']
    m = root / 'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb'
    assert sha(m / 'm007_fullmodel_encoder_1d_tb.sv') == '505e0b93652303b2f12049325ea3b4a9d434d9452a8795e634b91ace969f9327'
    assert sha(m / 'm007_fullmodel_encoder_binary_tb.sv') == '8a4a3956cff9289c026d16d1e1d7405d00393dc42ad586e62d4fdbb5624c4f8a'
    report = {
        'schema': 'm007-r007-peer-posedge-unroll-static-audit-v1',
        'status': 'PASS_STATIC_INVERSE_SOURCE_ONLY',
        'old_peer_sha256': sha(old_path), 'new_peer_sha256': sha(new_path),
        'inverse_byte_exact': True, 'only_main_posedge_port_loop_changed': True,
        'port_order': [0, 1, 2, 3], 'original_NBA_operators_per_port': 8,
        'same_process_no_new_always': True,
        'all_original_port_body_tokens_except_p_substitution_preserved': True,
        'NBA_statement_order_function_calls_shared_counters_assertions_preserved': True,
        'reset_comb_negedge_functions_cache_unit_checker_unchanged': True,
        'fullgraph_compile_sources_checked': 94, 'only_peer_record_changed': True,
        'fullgraph_top8b55_ROM_production_and_505e_8a4a_unchanged': True,
        'HDL_compile_RTL_or_model_run': False,
        'limitations': 'No frontend acceptance, actual AXI run or fullgraph result; A012 actual compile/run is separate.',
        'resource_policy_self': {'affinity': affinity, 'nice': nice, 'ioprio_class': io >> 13,
                                 'initial_MemAvailable_KiB': available,
                                 'max_RSS_KiB': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                                 'address_space_limit_B': 1024**3},
        'wall_s': time.monotonic() - start,
    }
    (out / 'peer_posedge_unroll_audit.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
