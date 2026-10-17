"""Bounded static identity and stored-byte review; no new reference evaluation."""
import hashlib
import json
import os
import resource
import struct
import subprocess
import time
from pathlib import Path

resource.setrlimit(resource.RLIMIT_AS, (1024**3, 1024**3))
start = time.monotonic()
root = Path(__file__).resolve().parents[2]
support_path = root / 'source/fixed_graph_support_20261014/ln128_wprep_q16_20261016.json'
support_bytes = support_path.read_bytes()
d = json.loads(support_bytes)
checks = []
identities = []

def check(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def read(entry):
    p = root / entry['path']
    b = p.read_bytes()
    h = hashlib.sha256(b).hexdigest()
    check('identity:' + entry['path'], len(b) == entry['bytes'] and h == entry['sha256'])
    identities.append({'path': entry['path'], 'bytes': len(b), 'sha256': h})
    return b

read(d['frozen_manifest'])
for pair in d['frozen_current_sources']:
    check('current_equals_frozen:' + Path(pair['frozen']['path']).name,
          read(pair['frozen']) == read(pair['current']))
for entry in d['newly_read_dependencies']:
    read(entry)
read(d['reused_reference_binding'])
products = {k: read(v) for k, v in d['saved_products'].items()}
norm = read(d['full_norm'])
norm_hex = read(d['AT343_norm_hex'])
norm_from_hex = b''.join(struct.pack('<I', int(w, 16)) for w in norm_hex.split())
check('norm_hex_equals_independent', norm_from_hex == norm and len(norm) == 128 * 4096)
check('independent_rows4_input_binding', products['source_f32'] == norm[:4 * 4096])
check('Q_gold_only_four_rows', len(products['a8_q']) == 4 * 1024 and len(products['a8_scale']) == 4 * 64)
for row in d['first16_rows']:
    r = row['row']
    check(f'row{r}:norm_window', row['norm_offset'] == r * 4096 and row['norm_bytes'] == 4096 and hashlib.sha256(norm[r*4096:(r+1)*4096]).hexdigest() == row['norm_sha256'])
    check(f'row{r}:bank_layout', row['q_bank_words'] == [272*r, 272*r+255] and row['scale_bank_words'] == [272*r+256, 272*r+271])
    check(f'row{r}:reference_scope', row['q_scale_independent_gold'] == (r < 4))
    if r < 4:
        check(f'row{r}:Q_bytes', row['q_offset'] == r*1024 and hashlib.sha256(products['a8_q'][r*1024:(r+1)*1024]).hexdigest() == row['q_sha256'])
        check(f'row{r}:scale_bytes', row['scale_offset'] == r*64 and hashlib.sha256(products['a8_scale'][r*64:(r+1)*64]).hexdigest() == row['scale_sha256'])
counts = d['integer_checks_not_measurements']
expected = {'first_window_read_bytes': 16*4096, 'first_window_R64_beats': 16*64,
            'first_window_lnq_input_words': 16*1024, 'first_window_Q_halves': 16*32*2,
            'first_window_Q_scales': 16*32, 'first_window_bank_words': 16*272,
            'first_window_export_write_edges': 16*48, 'r15_norm_prep_overlap_bytes': (4352-4224)*4,
            'w_payload_bytes': 1572864*2+196608, 'w_R64_beats': [24576,24576,3072],
            'w_AUX_header_R16_beats': 8, 'w_scale_checks': 3072*32}
for k,v in expected.items():
    check('integer_not_measurement:' + k, counts[k] == v)
check('research_single_run_accepted', 'Exit status: 0' in (support_path.parent / d['external_measurement']).read_text())
check('research_initial_failure_retained', d['initial_script_failure']['exit_code'] == 1 and 'Exit status: 1' in (support_path.parent / d['initial_script_failure']['time_record']).read_text())
result = {'scope': 'STATIC_INTERFACE_INPUT_IDENTITIES_AND_STORED_BYTES_ONLY',
          'support': {'path': str(support_path.relative_to(root)), 'sha256': hashlib.sha256(support_bytes).hexdigest()},
          'checks': checks, 'check_count': len(checks), 'failures': [x for x in checks if not x['pass']],
          'identities': identities, 'no_new_numeric_gold': True,
          'measurement': {'elapsed_seconds': time.monotonic()-start,
                          'maxrss_kib': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                          'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS,0),
                          'ionice': subprocess.check_output(['ionice','-p',str(os.getpid())], text=True).strip(),
                          'interactive_reads_cumulative': 'UNKNOWN'}}
Path(__file__).with_name('ln128_wprep_q16_interface_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'checks': len(checks), 'failures': result['failures']}))
raise SystemExit(bool(result['failures']))
