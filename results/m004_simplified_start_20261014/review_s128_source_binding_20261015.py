"""Controller review: saved bytes/integers only, no model or DUT execution."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import resource
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
started = time.monotonic()
binding_path = 'source/fixed_graph_support_20261014/s128_final_attention_binding_20261015.json'
binding = json.loads((ROOT / binding_path).read_text())
identities, checks, comparisons = [], {}, []

def data(path, offset=0, count=None):
    with (ROOT / path).open('rb') as stream:
        stream.seek(offset)
        value = stream.read() if count is None else stream.read(count)
    if count is not None:
        assert len(value) == count, path
    return value

def sha(value):
    return hashlib.sha256(value).hexdigest()

def check(name, value):
    checks[name] = bool(value)
    assert value, name

for item in binding['files']:
    payload = data(item['path'], item.get('offset', 0), item['bytes'] if 'offset' in item else None)
    actual = sha(payload)
    identities.append(dict(**item, actual_sha256=actual, actual_bytes=len(payload)))
    assert actual == item['sha256'] and len(payload) == item['bytes'], item['path']

E = 'project/E002_Laya_HLS/experiment/'
C = E + 'results/compute_throughput_optimization_20261010/attempts/'
F = E + 'results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/'
D = E + 'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/'
R = 'source/fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/'
T = C + 't5_attention_fixture_01/work/fixture/'
tm = json.loads(data(T + 'manifest.json'))
check('AT021_attention_current_identity', sha(data(E + 'vivado/module_design/attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv')) == '11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16')
check('STATE0_valid_bytes_equal_independent_raw_all128', data(C + 'new_raw_B1_from_b0_S128_production_02/work/state0.bin', 0, 524288) == data(D + 'embedding_raw.f32.bin'))
check('independent_norm_128_rows', len(data(D + 'embedding_norm.f32.bin')) == 524288)
check('norm_first4_same_matrix_fixture_parent', data(D + 'embedding_norm.f32.bin', 0, 16384) == data(F + 'qkv_rows4_source_f32.bin'))
check('gamma_current_AUX_window', sha(data(E + 'build/model-current-production-v2-20261011/aux.bin', 128, 4096)) == 'dfb0f4aaaedeb189d0698f68603641bf325c60b9857ecb19a5f9fe4f9df0aa2d')
old_request = data(E + 'build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin')
new_request = data(E + 'build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin')
mask = new_request[832:960]
check('mask_v4_current_equal', old_request[832:960] == mask)
check('mask_128_binary_72_ones', len(mask) == 128 and set(mask) == {0, 1} and sum(mask) == 72)
for name in ('q.bin', 'k.bin', 'v.bin', 'score.bin', 'maximum.bin', 'shift.bin', 'exp.bin', 'sum.bin', 'prob.bin', 'out.bin', 'mask.mem', 'identity_words.mem'):
    payload = data(T + name)
    expected = tm['products'][name]
    check('t5_manifest_' + name, len(payload) == expected['bytes'] and sha(payload) == expected['sha256'])
check('t5_mask_current_request', bytes(int(x, 16) for x in data(T + 'mask.mem').split()) == mask)
for row in (0, 1):
    for plane, name in enumerate(('q', 'k', 'v')):
        current = data(R + f'products/row{row}_full_FINAL.f32.bin', plane * 4096, 256)
        saved = data(T + name + '.bin', row * 256, 256)
        mismatch_words = sum(current[i:i+4] != saved[i:i+4] for i in range(0, 256, 4))
        comparisons.append(dict(row=row, plane=name, head=0, words=64, different_words=mismatch_words, sha256=sha(current)))
        assert mismatch_words == 0
for name in ('q', 'k', 'v'):
    capture = data(C + f't2_av_feedback_qkv_capture_run_01/work/capture/t2_enc0_{name}_head0_source.f32.bin')
    check('t5_' + name + '_software_capture_identity', data(T + name + '.bin') == capture and sha(capture) == tm['producer_planes'][name]['sha256'])
addresses = set()
for row in range(128):
    for plane in range(3):
        for head in range(16):
            for d in (0, 16, 32, 48):
                offset = ((plane * 16 + head // 2) * 1024 + row) * 256 + d * 4
                assert 0 <= offset and offset + 64 <= 12582912 and offset % 64 == 0
                key = (head % 2, offset)
                assert key not in addresses
                addresses.add(key)
check('QKV_all128_unique_legal_beats', len(addresses) == 24576)
check('norm_all128_beats', len(data(D + 'embedding_norm.f32.bin')) // 64 == 8192)
assert len(checks) == 25
check('t5_reference_unchanged_original', sha(data(E + 'tests/full_reference.py')) == tm['independent_reference']['sha256'] == 'fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784')
check('t5_scope_head0_128_queries_full_keys', tm['rows'] == tm['keys'] == 128 and tm['D'] == 64 and tm['scope'] == 'enc0/head0/request3/generation1 B1S128 Q/K/V after RoPE checkpoint replay')
check('request_packages_not_identical', sha(old_request) != sha(new_request))
check('RoPE_reference_manifest_frozen', sha(data(R + 'manifest.json')) == '979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2')
check('source_row127_last_word_boundary', 127 * 4096 + 1023 * 4 + 4 == 524288)

record = dict(
    reviewed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    source_message='m004-s128-final-attention-minimal-next-answer-20261015',
    scope='READ_ONLY_SHA_BYTE_INTEGER_REVIEW; no oracle, numerical forward, DUT or EDA',
    binding=dict(path=binding_path, sha256=sha(data(binding_path))),
    identities=identities, identity_count=len(identities), checks=checks,
    independent_condition_count=len(checks), comparisons=comparisons,
    verdict='PASS_STATIC_BINDING_ONLY',
    reference_limit='t5 Q/K/V are software producer captures; saved Attention gold is only valid for matched inputs. Current two rows match head0, not all128 actual producer inputs.',
    implementation='NOT_RUN',
    full_request_error_equivalence='UNRESOLVED_NOT_ACCEPTED; no change to original whole-model contract',
    sampling=dict(wall_seconds=time.monotonic()-started, cpu_seconds=resource.getrusage(resource.RUSAGE_SELF).ru_utime+resource.getrusage(resource.RUSAGE_SELF).ru_stime, maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss, affinity=sorted(os.sched_getaffinity(0)), nice=os.getpriority(os.PRIO_PROCESS,0), io_priority=subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip(), interactive_reads_cumulative='UNKNOWN'))
path = ROOT / 'results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json'
all_records = json.loads(path.read_text())
assert 'revision15_source_s128_static_review' not in all_records
all_records['revision15_source_s128_static_review'] = record
path.write_text(json.dumps(all_records, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k:record[k] for k in ('identity_count','independent_condition_count','comparisons','verdict','sampling')}, ensure_ascii=False))
