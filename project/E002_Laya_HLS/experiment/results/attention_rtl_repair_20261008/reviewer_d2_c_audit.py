"""Read-only independent audit of completed official D2-C CPU artifacts.

Does not execute DUT, oracle, synthesis or simulation. Writes only reviewer JSON.
"""
import hashlib
import json
import math
import struct
import subprocess
from pathlib import Path

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
OUT = ROOT / 'results/attention_rtl_repair_20261008'
RUN = OUT / 'd2_cpu_full_official'
BUILD = ROOT / 'build/full-attention-repair-20261008'
MODEL = ROOT / 'build/model-attention-rtl-repair-20261008'
evidence = {}
checks = []

def digest(data):
    return hashlib.sha256(data).hexdigest()

def sha(path):
    path = Path(path)
    with path.open('rb') as stream:
        result = hashlib.file_digest(stream, 'sha256').hexdigest()
    evidence[str(path)] = result
    return result

def read(path):
    sha(path)
    return json.loads(Path(path).read_text())

def check(ok, label):
    if not ok:
        raise AssertionError(label)
    checks.append(label)

gate = read(RUN / 'full_final_gate_report.json')
closure_path = RUN / 'source_closure/full_source_closure_report.json'
closure = read(closure_path)
dut = read(RUN / 'dut/full_forward_dut_run_report.json')
oracle_path = RUN / 'oracle/full_forward_oracle_report.json'
oracle = read(oracle_path)
comparison = read(RUN / 'compare/full_forward_dut_compare_report.json')
manifest = read(MODEL / 'manifest.json')
compdb = read(BUILD / 'compile_commands.json')
counts_path = ROOT / 'results/p2_environment_20261007/f0_expected_task_counts_s128.json'
counts = read(counts_path)
check(closure['root'] == str(ROOT) and closure['build'] == str(BUILD), 'official build roots')
check(gate['tags'] == manifest['tags'], 'current model tags')
check(sha(closure_path) == dut['source_build_sha256'] == comparison['source_build_sha256'] == gate['source_closure_sha256'], 'source closure report identity')
check(sha(BUILD / 'compile_commands.json') == closure['compile_database_sha256'] == gate['compile_database_sha256'], 'compile database identity')
for path, expected in closure['project_dependency_sha256'].items():
    check(Path(path).is_relative_to(ROOT) and sha(path) == expected, 'official project dependency ' + path)
objects = {}
for source, rec in closure['compiled_sources'].items():
    check(sha(ROOT / source) == rec['source_sha256'], 'compiled source hash ' + source)
    matches = [c for c in compdb if c['file'] == str(ROOT / source) and 'CMakeFiles/laya_full.dir/' in c['command']]
    check(len(matches) == 1 and matches[0]['command'] == rec['compile_command'], 'actual compiler command ' + source)
    check(digest(rec['compile_command'].encode()) == rec['compile_command_sha256'], 'compile command hash ' + source)
    check('-fno-fast-math' in rec['compile_command'] and '-ffp-contract=off' in rec['compile_command'], 'strict host floating point flags ' + source)
    obj = Path(rec['object'])
    check(obj.is_relative_to(BUILD) and sha(obj) == rec['object_sha256'], 'object hash ' + source)
    check(sha(Path(str(obj) + '.d')) == rec['dependency_file_sha256'], 'dependency file hash ' + source)
    objects[obj.name] = obj
check(len(objects) == 25, '25 compiled production archive members')
archive = BUILD / 'liblaya_full.a'
check(sha(archive) == closure['library_sha256'] == dut['library_sha256'], 'linked production archive identity')
members = subprocess.check_output(['/usr/bin/ar', 't', str(archive)], text=True).splitlines()
check(set(members) == set(objects) and len(members) == len(objects), 'archive member list matches compiled objects')
for name, obj in objects.items():
    check(digest(subprocess.check_output(['/usr/bin/ar', 'p', str(archive), name])) == sha(obj), 'archive actual object bytes ' + name)
check(sha(BUILD / 'full_forward_dut_runner') == dut['executable_sha256'], 'executed runner binary identity')
check(sha(ROOT / 'tests/full_forward_dut_runner.cpp') == dut['runner_source_sha256'], 'runner source identity')
check(sha(ROOT / 'tests/full_forward_dut_run.py') == dut['wrapper_source_sha256'], 'wrapper source identity')
check(sha(ROOT / 'tests/full_forward_dut_compare.py') == comparison['comparator_sha256'], 'comparator source identity')
check(sha(ROOT / 'tests/full_reference.py') == oracle['reference_sha256'], 'independent oracle reference source identity')
check(sha(ROOT / 'tests/full_forward_oracle.py') == oracle['script_sha256'], 'oracle driver identity')
check(sha(oracle_path) == comparison['oracle_report_sha256'], 'oracle report identity')
for path in [BUILD / 'CMakeFiles/full_forward_dut_runner.dir/link.txt', BUILD / 'CMakeFiles/full_forward_dut_runner.dir/tests/full_forward_dut_runner.cpp.o', BUILD / 'CMakeCache.txt']:
    sha(path)
input_lines = (RUN / 'input_hashes.sha256').read_text().splitlines()
for line in input_lines:
    expected, path = line.split(None, 1)
    check(sha(path.strip()) == expected, 'input manifest entry ' + path.strip())
for key, rec in manifest['bo'].items():
    check((MODEL / rec['file']).stat().st_size == rec['size'] and sha(MODEL / rec['file']) == rec['sha256'], 'model BO identity ' + key)
for key, rec in manifest['tag_preimages'].items():
    check(sha(MODEL / rec['file']) == rec['sha256'] and rec['sha256'].startswith(manifest['tags'][key]), 'tag preimage ' + key)
check(sha(MODEL / 'manifest.json') == gate['model_manifest_sha256'] == dut['model_manifest_sha256'], 'model manifest identity')
check(sha(counts_path) == dut['design_count_table_sha256'], 'frozen task count table identity')

source = (ROOT / 'reference/runs/typed_q8_ref_20261005/abi_replay/request_v1.bin').read_bytes()
payloads = []
for index in range(5):
    offset, size = struct.unpack_from('<II', source, 132 + 32 * index)
    payloads.append(source[offset:offset + size])
for scenario, rec in dut['inputs'].items():
    frame = Path(rec['path']).read_bytes()
    check(sha(rec['path']) == rec['sha256'] and len(frame) == rec['bytes'], 'request file identity ' + scenario)
    B = 1 if scenario.startswith('B1_') else 2
    check(frame[:4] == b'LYRQ' and struct.unpack_from('<HH', frame, 20) == (B, 128) and struct.unpack_from('<Q', frame, 24)[0] == rec['request_id'], 'request ABI identity ' + scenario)
    aux_header = (MODEL / 'aux.bin').read_bytes()[:128]
    check(frame[40:104] == aux_header[32:96], 'request model tags ' + scenario)
    batch = 1 if scenario.startswith('B1_from_b1') else 0
    for index, frozen in enumerate(payloads):
        off, size = struct.unpack_from('<II', frame, 132 + index * 32)
        wanted = frozen
        if B == 1:
            half = len(frozen) // 2
            wanted = frozen[batch * half:(batch + 1) * half]
            if index == 2:
                wanted = struct.pack('<16i', *(x - batch * 128 for x in struct.unpack('<16i', wanted)))
        check(frame[off:off + size] == wanted, 'original input payload and B1 marker rebase ' + scenario + ':' + str(index))

state_keys = ['session_generation','last_accepted_request_id','last_task_id','tasks_retired','request_valid','model_header_valid','valid_owner_count','nonfree_owner_count','a8_max_epoch','ln_gamma_max_epoch','numeric_a8_epoch','owner_claims','owner_leases','encoder_layers_completed','decision_layers_completed']
sequence = ['B2_S128','accepted_gamma_failure','B1_from_b0_S128','B1_from_b1_S128']
metadata = {}
previous = None
raw_states = {}
checkpoint_summary = {}
total_bytes = 0
for scenario in sequence:
    directory = RUN / 'dut/dut' / scenario
    md = read(directory / 'metadata.json')
    metadata[scenario] = md
    lines = (directory / 'runtime.tsv').read_text().splitlines()
    sha(directory / 'runtime.tsv')
    states = []
    for phase, line in zip(['pre','post'], lines):
        fields = line.split('\t')
        check(len(fields) == 272 and fields[0] == phase, 'raw runtime row ' + scenario + ':' + phase)
        values = list(map(int, fields[1:]))
        state = dict(zip(state_keys, values[:15]))
        state['op_calls_by_code'] = values[15:]
        state['op_calls_total'] = sum(values[15:])
        check(state == md[phase + '_runtime'], 'raw runtime matches metadata ' + scenario + ':' + phase)
        states.append(state)
    check(previous is None or previous == states[0], 'unbroken persistent runtime ' + scenario)
    previous = states[1]
    raw_states[scenario] = states
    check(md['run_session_id'] == dut['run_session_id'] and md['source_build_sha256'] == sha(closure_path), 'session and compiled build identity ' + scenario)
    check(sha(directory / 'result.bin') == md['result_frame_sha256'], 'raw ABI result hash ' + scenario)
    if scenario == 'accepted_gamma_failure':
        continue
    expected = {c['name']: c for c in oracle['runs'][scenario]['checkpoints']}
    got = {c['name']: c for c in md['checkpoints']}
    check(len(expected) == len(got) == 47 and set(got) == set(expected), 'exact 47 checkpoint names ' + scenario)
    scenario_bytes = 0
    for name, e in expected.items():
        d = got[name]
        opath = Path(e['path'])
        dpath = directory / (name + '.f32.bin')
        check(opath == RUN / 'oracle' / scenario / (name + '.f32.bin') and Path(d['path']) == dpath, 'independent checkpoint path ' + scenario + ':' + name)
        check(e['shape'] == d['shape'] and e['bytes'] == d['bytes'] == dpath.stat().st_size == 4 * math.prod(e['shape']), 'checkpoint dimensions ' + scenario + ':' + name)
        check(sha(opath) == e['sha256'] and sha(dpath) == d['sha256'], 'checkpoint recorded hashes ' + scenario + ':' + name)
        actual = dpath.read_bytes()
        check(actual == opath.read_bytes(), 'independent actual byte comparison ' + scenario + ':' + name)
        if scenario.startswith('B1_'):
            whole = (RUN / 'dut/dut/B2_S128' / (name + '.f32.bin')).read_bytes()
            batch = int('from_b1' in scenario)
            check(actual == whole[batch * len(actual):(batch + 1) * len(actual)], 'persistent B1 equals B2 batch slice ' + scenario + ':' + name)
        scenario_bytes += len(actual)
    total_bytes += scenario_bytes
    B = md['B']
    ops = md['post_runtime']['op_calls_by_code']
    observed = dut['runs'][scenario]['observed_counts']
    for name, wanted in counts['B' + str(B) + '_S128']['expected_calls'].items():
        actual = sum(ops[0x30:0x38]) if name == 'Q8_LINEAR_all' else observed['op_calls_by_name'].get(name, 0)
        check(actual == wanted, 'design task count ' + scenario + ':' + name)
    check(sum(ops) == md['post_runtime']['tasks_retired'] == 18263 * B + 632, 'independent total task formula ' + scenario)
    check(ops[0x30] == 30 * 8 * B and ops[0x40] == 28 * 16 * 8 * B and ops[0x50] == ops[0x51] == ops[0x52] == 30 * 16 * 8 * B, 'QKV RoPE QK softmax AV task formulas ' + scenario)
    check(md['post_runtime']['encoder_layers_completed'] == 28 and md['post_runtime']['decision_layers_completed'] == 2, 'all graph layers complete ' + scenario)
    checkpoint_summary[scenario] = {'checkpoints':47,'bytes_compared':scenario_bytes,'tasks':sum(ops),'qkv':ops[0x30],'rope':ops[0x40],'qk':ops[0x50],'softmax':ops[0x51],'av':ops[0x52],'owner_claims':md['post_runtime']['owner_claims'],'owner_leases':md['post_runtime']['owner_leases']}

fail_dir = RUN / 'dut/dut/accepted_gamma_failure'
mutation = (fail_dir / 'mutation.tsv').read_text().strip().split('\t')
sha(fail_dir / 'mutation.tsv')
check(list(map(int, mutation[:6])) == [128,1060110336,2139095040,6,125960207,17] and mutation[6] == dut['run_session_id'], 'actual finite gamma to +infinity mutation record')
frame = (fail_dir / 'result.bin').read_bytes()
check(len(frame) == 384 and frame[:4] == b'LYRS' and struct.unpack_from('<H', frame, 10)[0] == 6 and struct.unpack_from('<I', frame, 112)[0] == 9, 'failure actual ABI status and flags')
check(struct.unpack_from('<HHI', frame, 116) == (1,130,0x0782000f) and struct.unpack_from('<I', frame, 360)[0] == 17, 'failure first cause stage op detail task')
check(frame[128:320] == bytes(192) and struct.unpack_from('<QQQ', frame, 328) == (17,578,0), 'failure zero payload retired accepted committed counts')
check(raw_states['accepted_gamma_failure'][1]['op_calls_by_code'][1] == 16 and raw_states['accepted_gamma_failure'][1]['op_calls_by_code'][130] == 1 and raw_states['accepted_gamma_failure'][1]['op_calls_total'] == 17, 'failure production task sequence counts')
check([metadata[s]['request_id'] for s in sequence] == [1,2,3,4] and all(metadata[s]['generation'] == 1 for s in sequence), 'persistent generation and monotonically accepted request IDs')
check([metadata[s]['post_runtime']['numeric_a8_epoch'] for s in sequence] == [1924,1924,2886,3848], 'A8 epochs survive accepted failure and recovery')
check([metadata[s]['post_runtime']['ln_gamma_max_epoch'] for s in sequence] == [1,2,3,4], 'gamma epochs advance through failure and recovery')
exits = {}
for path in sorted(RUN.glob('*.exit')):
    sha(path)
    exits[path.stem] = int(path.read_text())
check(len(exits) == 17 and all(v == 0 for v in exits.values()), '17 official CPU workflow exit codes zero')
for path in sorted(RUN.glob('*.log')):
    sha(path)
for path in sorted(RUN.glob('*.command')):
    sha(path)
for scenario in sequence:
    path = RUN / 'dut/dut' / scenario / 'checkpoints.tsv'
    if path.exists(): sha(path)
check('100% tests passed, 0 tests failed out of 27' in (RUN / 'ctest.log').read_text(), '27 recorded CTest cases passed')
check('FULL_FORWARD_DUT_RUNNER_PASS persistent_requests=4 successful_requests=3 checkpoints=141 accepted_failure_recovered=1' in dut['combined_log'], 'complete raw runner success marker')
check(all(v == 'unverified_current_build' for k,v in gate['phase_status'].items() if k != 'cpu'), 'gate does not claim unexecuted HLS or hardware phases')

report = {
    'decision':'ACCEPT_D2_C_OFFICIAL_NATIVE_CPU_SEGMENT_ONLY',
    'reviewer':{'model':'gpt-6-astra','reasoning_effort':'xhigh','role':'independent read-only reviewer'},
    'official_root':str(ROOT),'actual_build':str(BUILD),'model_package':str(MODEL),
    'controller_sha256':closure['compiled_sources']['hls/control/full_forward_controller.cpp']['source_sha256'],
    'tags':gate['tags'],'run_session_id':dut['run_session_id'],
    'checks_passed':len(checks),'checks':checks,
    'input_manifest_entries_verified':len(input_lines),
    'production_dependency_hashes_verified':len(closure['project_dependency_sha256']),
    'compiled_sources_and_archive_members_verified':len(objects),
    'checkpoint_count':141,'checkpoint_bytes_directly_compared':total_bytes,
    'checkpoint_summary':checkpoint_summary,
    'persistent_request_sequence':sequence,
    'accepted_failure':{'status':6,'stage':1,'op':130,'detail':'0x0782000f','task':17,'input_elements':578,'output_elements':0,'payload_zero':True,'gamma_mutation':'+infinity at AUX offset 128','recovery':'subsequent two B1 requests complete with all checkpoints bit-identical to independent oracle and B2 batch slices'},
    'scope_limits':['This is native CPU execution of the actual modified official controller and full production archive.','Compiler database has no synthesis-storage shadow define; that D2-C shadow branch remains unverified here.','Standard-libm Vitis CSim is unverified in this reviewed run.','D2-R real-QKV-boundary RTL attention and D2-I modified production method reachability remain pending.','27 additional CTest passes and focused shape reports do not prove full-network execution at S64/S256/S512/S1024.','Full top HLS remains unreleased. Complete functional RTL is not accepted.'],
    'phase_status':{'native_cpu':'accepted','synthesis_storage_shadow':'unverified','vitis_csim':'unverified','d2_r_rtl':'unverified','d2_i_production_reachability':'unverified','full_top_hls_release':False,'complete_functional_rtl_accepted':False},
    'artifact_sha256':evidence,
}
out = OUT / 'reviewer_d2_c_official_cpu_review.json'
out.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
print(json.dumps({'decision':report['decision'],'checks_passed':len(checks),'checkpoint_bytes':total_bytes,'evidence_files':len(evidence),'report':str(out),'sha256':digest(out.read_bytes())},indent=2))
