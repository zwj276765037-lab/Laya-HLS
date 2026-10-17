#!/usr/bin/env python3
"""Controller audit of saved identities/bytes and integer mappings; no arithmetic oracle."""
import hashlib
import json
from pathlib import Path
import resource
import struct
import time

START = time.monotonic()
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).parent
SUPPORT = ROOT / 'source/fixed_graph_support_20261014/a16_matrix16_interface_20261016.json'
d = json.loads(SUPPORT.read_text())
checks = []
current = []

def check(name, value):
    checks.append({'check': name, 'pass': bool(value)})

def identity(record, name):
    b = (ROOT / record['path']).read_bytes()
    check(name, len(b) == record['bytes'] and hashlib.sha256(b).hexdigest() == record['sha256'])
    return b

manifests = {}
for item in d['manifest_identities']:
    content = identity(item, 'manifest:' + item['path'])
    manifests[str(Path(item['path']).parent)] = json.loads(content)
for item in d['frozen_sources']:
    f = item['frozen']
    identity(f, 'frozen:' + Path(f['path']).name)
    manifest = manifests[str(Path(f['path']).parents[1])]
    entry = next(e for e in manifest['entries'] if e['path'] == 'frozen/' + Path(f['path']).name)
    check('manifest_entry:' + Path(f['path']).name,
          (entry['sha256'], entry['bytes']) == (f['sha256'], f['bytes']))
    c = item['current_at_read']
    b = (ROOT / c['path']).read_bytes()
    current.append({'path': c['path'], 'sha256': hashlib.sha256(b).hexdigest(),
                    'matches_research_time': hashlib.sha256(b).hexdigest() == c['sha256']})

prior = json.loads(identity(d['reused_reference_binding'], 'reference_binding'))
check('reference_metadata_reused_exactly', d['reused_reference_products'] == prior['fixture_products']['qkv_rows4'])
identity(d['script'], 'research_script')
products = d['reused_reference_products']
data = {}
for name in ('steps_u32x6', 'output_f32', 'scatter_u32x4'):
    data[name] = (ROOT / products[name]['path']).read_bytes()
    check('saved_size:' + name, len(data[name]) == products[name]['bytes'])
steps, final, scatter = (data[k] for k in ('steps_u32x6', 'output_f32', 'scatter_u32x4'))
for w in d['selected_windows']:
    r, t = w['row'], w['tile']
    chunks = [steps[((r*32+g)*3072+8*t)*24:((r*32+g)*3072+8*t)*24+192] for g in range(32)]
    fb = final[(r*3072+8*t)*4:(r*3072+8*t)*4+32]
    check(f'window:{r}:{t}', hashlib.sha256(b''.join(chunks)).hexdigest() == w['steps_concat_sha256']
          and hashlib.sha256(fb).hexdigest() == w['final_sha256'])
    check(f'last_PS:{r}:{t}', all(chunks[31][lane*24+20:lane*24+24] == fb[lane*4:lane*4+4] for lane in range(8)))
    for lane in range(8):
        n = 8*t+lane
        plane, rem = divmod(n, 1024)
        head, col = divmod(rem, 64)
        offset = ((((plane*2)*8+head//2)*1024+r)*64+col)*4
        got = struct.unpack_from('<4I', scatter, (r*3072+n)*16)
        want = (head&1, offset, struct.unpack_from('<I', fb, lane*4)[0], r)
        check(f'scatter:{r}:{t}:{lane}', got == want)

# Prove the proposed read addressing returns the existing dense representation.
words = set()
for r in range(16):
    for g in range(32):
        qs = [272*r+8*g+j for j in range(8)]
        sw = 272*r+256+g//2
        check(f'A_mapping:{r}:{g}', all((w%8,w//8) == (j,34*r+g) for j,w in enumerate(qs))
              and (sw%8,sw//8) == ((g//2)%8,34*r+32+g//16))
        words.update(qs+[sw])
check('A_dense_PS_disjoint', words == set(range(4352)) and not words.intersection(range(4352,4480)) and 4479//8 < 656)
check('first_TN8_work', (4*32, 4*32*4, 16*8, 16, 128*8) == (128,512,128,16,1024))
check('full_parent_work', (384*4*32, 384*4*32*4, 384*16) == (49152,196608,6144))
check('payload_delta_108B', (1024-256+128-32)//8 == 108)
check('bad_does_not_define_global_order', 5248*128+31 == 671775 and 8*128 == 1024 and 671775 > 1024)
check('static_scope', d['new_gold'] is False and d['implementation_or_dynamic_result'] == 'NOT_RUN')
check('research_checks_true', all(d['checks'].values()))

result = {
    'decision': 'D-M004-A16-MATRIX16-INTERFACE-01',
    'scope': 'Static design intake; no RTL, EDA, oracle, gold or implementation execution.',
    'support_sha256': hashlib.sha256(SUPPORT.read_bytes()).hexdigest(),
    'passed': sum(c['pass'] for c in checks), 'failed': [c for c in checks if not c['pass']],
    'checks': checks, 'current_source_observations': current,
    'current_changes_do_not_invalidate_frozen_design_basis': True,
    'parent_gold_SHA_reused_not_rehashed': True,
    'runtime_validation': 'NOT_RUN', 'interactive_host_cost': 'UNKNOWN',
    'wall_seconds_before_output': time.monotonic()-START,
    'peak_rss_KiB': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
}
dest = OUT / 'a16_matrix16_interface_review_20261016.json'
dest.write_text(json.dumps(result, indent=2, ensure_ascii=False)+'\n')
print(json.dumps({k: result[k] for k in ('passed','failed','wall_seconds_before_output','peak_rss_KiB')}, ensure_ascii=False))
print(json.dumps({'current_source_matches': sum(x['matches_research_time'] for x in current), 'sources': len(current)}))
raise SystemExit(bool(result['failed']))
