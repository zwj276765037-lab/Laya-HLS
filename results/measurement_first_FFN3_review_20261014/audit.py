"""A001 read-only evidence audit. Never launches/imports the experiment runner."""
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
AT = RUN / 'attempts/AT062_FFN3_typed_xsim_01'
OUT = ROOT / 'results/measurement_first_FFN3_review_20261014'
checks, failures, cache = [], [], {}

def read(path):
    return json.loads(Path(path).read_text())

def identity(path):
    path = Path(path)
    key = str(path)
    if key not in cache:
        h = hashlib.sha256()
        with path.open('rb') as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(chunk)
        cache[key] = {'path': key, 'bytes': path.stat().st_size, 'sha256': h.hexdigest()}
    return cache[key]

def check(path, expected=None, scope='evidence'):
    record = dict(identity(path), scope=scope)
    if expected is not None:
        record['matches'] = all(record[k] == expected[k] for k in ('bytes', 'sha256'))
        if not record['matches']:
            failures.append(record)
    checks.append(record)

def require(condition, label):
    if not condition:
        failures.append({'assertion': label})

manifest = read(AT / 'package_manifest.json')
source = read(AT / 'frozen/at059_source_manifest.json')
engineering = read(AT / 'verification.json')
for item in engineering['checked']:
    check(item['path'], item, 'engineering_reported_identity')
for item in source['files']:
    check(item['path'], item, 'AT059_source')
source_manifest = Path(manifest['source_at']) / 'source_manifest.json'
check(source_manifest, manifest['source_manifest'], 'source_manifest')
require(read(source_manifest) == source, 'copied source manifest matches original')
for group in ('frozen_files', 'vendor_tool_files', 'source_chain', 'resolved_runtime_libraries'):
    for item in manifest[group]:
        check(item['path'], item, group)
        if 'kind' in item:
            magic = Path(item['path']).read_bytes()[:4]
            require((magic == b'\x7fELF') == (item['kind'] == 'ELF'), 'magic: ' + item['path'])
            require(str(Path(item['path']).resolve()) == item['resolved_path'], 'resolved path: ' + item['path'])

dynamic = set(manifest['dynamic_outputs'])
runtime_changes, runtime_extras = [], {}
for item in manifest['runtime_files']:
    check(item['source'], item, 'original_compiled_package')
    check(AT / 'bundle' / item['relative'], item, 'unrun_bundle')
    for phase in ('pilot', 'full'):
        target = AT / ('runtime_' + phase) / item['relative']
        if item['relative'] in dynamic:
            current = identity(target)
            runtime_changes.append(dict(current, phase=phase, declared_dynamic=True,
                                        changed=any(current[k] != item[k] for k in ('bytes', 'sha256'))))
        else:
            check(target, item, phase + '_immutable_runtime')
expected_files = {x['relative'] for x in manifest['runtime_files']}
for directory in ('bundle', 'runtime_pilot', 'runtime_full'):
    folder = AT / directory
    actual = {str(p.relative_to(folder)) for p in folder.rglob('*') if p.is_file()}
    require(not any(p.is_symlink() for p in folder.rglob('*')), directory + ' has no symlinks')
    require(expected_files <= actual, directory + ' no missing declared file')
    runtime_extras[directory] = sorted(actual - expected_files)
    require(all(x in dynamic or x.endswith('TempBreakPointFile.txt') or x == manifest['snapshot_name'] + '.wdb' for x in actual - expected_files),
            directory + ' extra files are runtime outputs')

fixture_roles = {'downstream_fixtures', 'LN_fixture', 'bound_identity', 'ffn_fixture'}
fixture_files = {str(Path(x['path']).resolve()) for x in source['files'] if x['role'] in fixture_roles}
roots = manifest['fixture_roots']
require(roots['FIXTURE'] == roots['LN_FIXTURE'], 'FIXTURE same source as LN_FIXTURE')
for key, folder in roots.items():
    actual = {str(p.resolve()) for p in Path(folder).iterdir() if p.is_file()}
    wanted = {p for p in fixture_files if Path(folder) in Path(p).parents}
    require(actual == wanted and bool(wanted), 'fixture set ' + key)

preflight_cases = read(AT / 'preflight_negatives.json')['cases']
for case in preflight_cases:
    rec = read(case['record'])
    check(case['record'])
    require(rec['status'] == case['status'] and rec['spawned'] is False, 'preflight ' + case['case'])
    require(case['exit_code'] == (0 if case['case'] == 'intact' else 2), 'preflight exit ' + case['case'])

phases = {}
for phase in ('pilot', 'full'):
    pre = read(AT / f'preflight_{phase}.json')
    launch = read(AT / f'launch_{phase}.json')
    spawn = read(AT / f'guard_{phase}/launch.json')
    plan = read(AT / f'guard_{phase}/guard_plan.json')
    result = read(AT / f'guard_{phase}/guard_result.json')
    policy = read(AT / f'guard_{phase}/policy_checks.json')
    log = (AT / f'guard_{phase}/driver.log').read_text()
    for filename in (f'preflight_{phase}.json', f'launch_{phase}.json', f'result_{phase}.json',
                     f'guard_{phase}/launch.json', f'guard_{phase}/guard_plan.json',
                     f'guard_{phase}/guard_result.json', f'guard_{phase}/policy_checks.json',
                     f'guard_{phase}/driver.log'):
        check(AT / filename)
    require(pre['at'] < launch['at'] < spawn['at'], phase + ' preflight before spawn')
    require(pre['cwd'] == launch['cwd'] == plan['cwd'], phase + ' actual cwd')
    require(pre['command'] == launch['command'], phase + ' actual command')
    require(plan['command'][-len(launch['command']):] == launch['command'], phase + ' policy wrapper command')
    args = launch['command']
    plus = [args[i+1] for i, x in enumerate(args) if x == '-testplusarg']
    expected_plus = {f'{k}={v}' for k, v in roots.items()}
    if phase == 'pilot':
        expected_plus.add('PREFIX=1')
    require(set(plus) == expected_plus and len(plus) == len(expected_plus), phase + ' plusargs')
    require(all(p['matches'] and p['affinity'] == [0, 1, 2, 3] and p['nice'] == 19 and p['ionice'] == 'idle' for p in policy), phase + ' policy')
    require(result['child_exit_code'] == 0 and result['trigger'] is None and result['simulation_started'], phase + ' launched/no guard trigger')
    phases[phase] = {'guard': result, 'policy_count': len(policy), 'plusargs_count': len(plus),
                     'fatal_lines': [s for s in log.splitlines() if 'Fatal:' in s],
                     'chain_pass': 'FFN0_CHAIN_PASS' in log,
                     'selected_lines': [s for s in log.splitlines() if any(k in s for k in
                       ('PREFIX_PILOT_PASS', 'LNQ0_LN_SOURCE_PASS', 'DOWN_MEASURE_BOUNDARIES',
                        'WIGQD_WI_COMPLETE', 'GQD0_cfg_accepted', 'Wi_reader_cfg', '$finish'))]}

require(phases['pilot']['fatal_lines'] == [], 'pilot no Fatal')
require(phases['full']['fatal_lines'] == ['Fatal: WIGQD Wi reader cfg rejected'], 'full exact Fatal')
require(not phases['full']['chain_pass'], 'no full chain PASS')
cost = read(AT / 'full_cost_decision.json')
require(cost['at'] < read(AT / 'launch_full.json')['at'], 'cost decision before full launch')
require(abs(500000 / cost['selected_conservative_rate_cycles_per_second'] * 1.05 - cost['wall_projection_seconds_with_5pct_margin']) < 1e-8, 'planning arithmetic')

for name in ('host_budget.json', 'script_chain_audit.json', 'loaded_dependency_audit.json',
             'pilot_maps_sample.json', 'full_maps_sample_early.json', 'receipt.json', 'verification.json'):
    check(AT / name)
for p in (AT / 'host_raw').iterdir():
    if p.is_file():
        check(p, scope='host_raw')
        if p.suffix == '.json':
            require(read(p)['returncode'] == 0, 'host probe exit ' + p.name)
for p in [RUN / 'reports/FFN3_typed_runtime_semantic_failure_20261014.md',
          ROOT / 'agent/A002/state.json', ROOT / '.research-agent/communication.json',
          ROOT / 'mission/ffn_typed_runtime_preparation_stage_20261014.md']:
    check(p)
for name in ('experiment_source', 'experiment_results', 'experiment_status'):
    check(ROOT / 'project/E005_full_request_performance' / name / 'summary.md')

tb = RUN / 'attempts/AT059_FFN1_progress_replay_02/frozen_new/ffn0_chain_tb_v1.sv'
reader = RUN / 'attempts/AT035_QAR0_shared_admission_01/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_wi_axi_reader_v1.sv'
anchors = {}
for p, tokens in [(tb, ['wi_region_base=', '.cfg_bo_base(cfg_bo_base[0])', 'cfg_bo_base[0]=STATE1_BASE', 'cfg_bo_base[0]=DDR_BASE']),
                  (reader, ['cfg_region_base>=cfg_bo_base', 'if(!command_ok)cfg_reject<=1'])]:
    anchors[str(p)] = [{'line': i, 'text': line} for i, line in enumerate(p.read_text().splitlines(), 1) if any(t in line for t in tokens)]
require(0x100001000 < 0x310000000, 'Wi region below incorrect STATE1 base')
report = {'schema': 'A001_FFN3_readonly_review_v1', 'at': datetime.now(timezone.utc).isoformat(),
          'verdict': 'FAIL_SEMANTIC_WI_READER_CONFIG', 'audit_pass': not failures,
          'source_references': len(source['files']), 'runtime_package_files': len(manifest['runtime_files']),
          'runtime_package_bytes': sum(x['bytes'] for x in manifest['runtime_files']),
          'fixture_files': len(fixture_files), 'roms': sum(x['role'] == 'LN_ROM_target' for x in manifest['runtime_files']),
          'elf_roots': len(manifest['elf_details']), 'library_entries': len(manifest['resolved_runtime_libraries']),
          'unique_hashed_paths': len(cache), 'identity_checks': checks,
          'runtime_dynamic_changes': runtime_changes, 'runtime_extra_outputs': runtime_extras,
          'preflight_cases': preflight_cases, 'phases': phases, 'source_anchors': anchors,
          'cost': {'arithmetic_matches': True, 'is_new_full_measurement': False,
                   'limitation': '500k workload and 5% margin use independent historical runs; per-stage remaining-cost evidence is insufficient for reusing this number as FFN4 admission'},
          'host_limits': {'recorded_wall_seconds': read(AT / 'host_budget.json')['cumulative_wall_seconds'],
                          'peak_kind': 'rusage self/children, not sampled owned tree',
                          'actual_idle_io_policy': 'UNKNOWN: not recorded in host budget/probes'},
          'scope': 'read-only files/hashes/logs; no runner import or experiment/EDA/reference execution',
          'failures': failures}
(OUT / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({k: report[k] for k in ('verdict', 'audit_pass', 'source_references', 'runtime_package_files', 'runtime_package_bytes', 'fixture_files', 'unique_hashed_paths', 'failures')}, ensure_ascii=False))
