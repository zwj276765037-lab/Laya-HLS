#!/usr/bin/env python3
"""Hash two already verified LN fixtures; do not execute the oracle or LN."""
from pathlib import Path
import hashlib
import json
import os
import resource
import time

t0 = time.monotonic()
root = Path(__file__).resolve().parents[2]
mem_kib = next(int(s.split()[1]) for s in Path('/proc/meminfo').read_text().splitlines()
               if s.startswith('MemAvailable:'))
if mem_kib <= 192 * 1024 * 1024:
    raise SystemExit('MemAvailable <= 192 GiB')
base = root / 'project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture'
report = base / 'numeric_fixture_report.json'
doc = json.loads(report.read_text())
entries = []
for name in ('wi_ln_rows1', 'qkv_ln_rows1'):
    case = next(c for c in doc['cases'] if c['name'] == name)
    files = []
    checks = {'input_f32.bin': case['derived_input_sha256']}
    for leaf in ('dut.ln.bin', 'dut.ln_stats.bin'):
        checks[leaf] = case['outputs'][f'cases/{name}/{leaf}']['sha256']
    if 'gamma' in case:
        checks['gamma_f32.bin'] = case['gamma']['sha256']
    for leaf, expected in checks.items():
        path = base / 'cases' / name / leaf
        data = path.read_bytes()
        actual = hashlib.sha256(data).hexdigest()
        assert actual == expected, (name, leaf, actual, expected)
        files.append({'path': str(path.relative_to(root)), 'bytes': len(data), 'sha256': actual})
    stats = (base / 'cases' / name / 'dut.ln_stats.bin').read_bytes()
    entries.append({'name': name, 'oracle_exact_record': case['oracle_exact'],
                    'files': files, 'mean_variance_inverse_bits_le': [
                        f'{int.from_bytes(stats[i:i+4], "little"):08x}' for i in (0,4,8)]})
result = {
    'scope': 'existing fixture identity only; no forward/oracle/gold generation',
    'reference_report': {'path': str(report.relative_to(root)),
                         'sha256': hashlib.sha256(report.read_bytes()).hexdigest()},
    'fixture_provenance': 'dut.ln/dut.ln_stats are saved historical DUT outputs already compared bytewise to an independent oracle; not newly generated independent-gold files',
    'fixtures': entries,
    'planned_buffer_payload_bytes': {'X': 4096, 'T0_even_odd': 4096, 'T1_even_odd': 2048, 'G': 4096, 'total': 14336},
    'tree_node_counts': [512,256,128,64,32,16,8,4,2,1],
    'arithmetic_calls': {'ADD_or_SUB': 4095, 'MUL_gamma0': 2048, 'MUL_gamma1_or_2': 3072, 'DIV': 3, 'SQRT': 1},
    'sampling': {'elapsed_seconds_inside_script': time.monotonic()-t0,
                 'max_RSS_KiB_self': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                 'MemAvailable_KiB_before': mem_kib,
                 'CPU_affinity': sorted(os.sched_getaffinity(0)),
                 'nice': os.getpriority(os.PRIO_PROCESS, 0),
                 'cumulative_interactive_browsing_time_and_RSS': 'UNKNOWN; not uniformly sampled'},
}
(Path(__file__).parent / 'ln_fixture_identity.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'fixtures': [c['name'] for c in entries], 'hash_checks': sum(len(c['files']) for c in entries), 'sampling': result['sampling']}))
