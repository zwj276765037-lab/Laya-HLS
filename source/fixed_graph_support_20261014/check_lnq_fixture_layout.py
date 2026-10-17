"""Read existing P1 bytes and source identities only; no oracle or model execution."""
import hashlib
import json
import os
from pathlib import Path
import resource
import struct
import time

started = time.monotonic()
root = Path(__file__).resolve().parents[2]
exp = root / "project/E002_Laya_HLS/experiment"
fixture = exp / "results/engineering_p1/20261007T021236Z-1800667/fixture"
mem = next(int(x.split()[1]) for x in Path('/proc/meminfo').read_text().splitlines()
           if x.startswith('MemAvailable:'))
assert mem > 192 * 1024 * 1024, 'MemAvailable gate'

def identity(path):
    data = path.read_bytes()
    return {'path': str(path.relative_to(root)), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}

report_path = fixture / 'numeric_fixture_report.json'
report = json.loads(report_path.read_text())
out = {'scope': 'Existing bytes/layout/provenance only; no new gold or forward',
       'reference_report': identity(report_path), 'historical_profile': report['profile'],
       'historical_status': report['status'], 'cases': [], 'sources': []}
assert report['status'] == 'PASS'
for name in ('wi_ln_rows1', 'qkv_ln_rows1'):
    case = next(c for c in report['cases'] if c['name'] == name)
    assert (case['rows'], case['K'], case['batch'], case['row0']) == (1, 1024, 0, 0)
    files = []
    for fn in ('input_f32.bin', 'dut.ln.bin', 'dut.ln_stats.bin', 'dut.q8.bin'):
        item = identity(fixture / 'cases' / name / fn)
        expected = (case['derived_input_sha256'] if fn == 'input_f32.bin'
                    else case['outputs'][f'cases/{name}/{fn}']['sha256'])
        assert item['sha256'] == expected, item['path']
        item['historical_hash_match'] = True
        files.append(item)
    if 'gamma' in case:
        item = identity(fixture / 'cases' / name / 'gamma_f32.bin')
        assert item['sha256'] == case['gamma']['sha256']
        item['historical_hash_match'] = True
        files.append(item)
    raw = (fixture / 'cases' / name / 'dut.q8.bin').read_bytes()
    assert len(raw) == 32 * 34
    blocks = [struct.unpack_from('<H32b', raw, 34*g) for g in range(32)]
    assert b''.join(struct.pack('<H32b', *b) for b in blocks) == raw
    q = bytes(v & 255 for b in blocks for v in b[1:])
    scales = b''.join(struct.pack('<H', b[0]) for b in blocks)
    assert len(q) == 1024 and len(scales) == 64
    out['cases'].append({
        'name': name, 'source': case['source'], 'files': files,
        'gamma': case.get('gamma'), 'oracle_exact': case['oracle_exact'],
        'layout': {'format': '32 consecutive <H32b blocks, scale first',
                   'groups': 32, 'q_bytes': len(q), 'scale_bytes': len(scales),
                   'q_sha256_decoded_in_memory': hashlib.sha256(q).hexdigest(),
                   'scale_sha256_decoded_in_memory': hashlib.sha256(scales).hexdigest(),
                   'first_scale_bits': f'{blocks[0][0]:04x}',
                   'last_scale_bits': f'{blocks[-1][0]:04x}',
                   'first_q16_hex': q[:16].hex(),
                   'last_q16_hex': q[-16:].hex(),
                   'q_min': min(v for b in blocks for v in b[1:]),
                   'q_max': max(v for b in blocks for v in b[1:])}})
paths = [
    'tests/numeric_reference.py', 'tests/numeric_cli.cpp',
    'vivado/module_design/top/tb/numeric_fixture_test.py',
    'vivado/module_design/activation_quantizer/rtl/quant16_stream_row.sv',
    'vivado/module_design/activation_quantizer/rtl/quant_a_row_bank_v1.sv',
    'vivado/module_design/activation_quantizer/tb/quant16_stream_row_tb.sv',
    'vivado/module_design/layernorm_engine/rtl/laya_ln_row_v1.sv',
    'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv']
for rel in paths:
    item = identity(exp / rel)
    if rel in report['source_hashes']:
        item['historical_P1_sha256'] = report['source_hashes'][rel]
        item['matches_historical_P1'] = item['sha256'] == item['historical_P1_sha256']
    out['sources'].append(item)
out['sampling'] = {'elapsed_seconds_this_process': time.monotonic()-started,
                   'peak_rss_KiB_self': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                   'MemAvailable_KiB_before': mem, 'cpu_affinity': sorted(os.sched_getaffinity(0)),
                   'nice': os.getpriority(os.PRIO_PROCESS, 0),
                   'cumulative_interactive_reads_time_RSS': 'UNKNOWN; not uniformly sampled'}
destination = Path(__file__).with_name('lnq_fixture_layout_20261015.json')
destination.write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'case_files_verified': sum(len(c['files']) for c in out['cases']),
                  'case_Q8_SHA': {c['name']: next(f['sha256'] for f in c['files']
                                    if f['path'].endswith('/dut.q8.bin')) for c in out['cases']},
                  'P1_source_matches': {s['path']: s['matches_historical_P1'] for s in out['sources']
                                        if 'matches_historical_P1' in s},
                  'source_sha': {s['path']: s['sha256'] for s in out['sources'][-5:]},
                  'sampling': out['sampling']}, ensure_ascii=False))
