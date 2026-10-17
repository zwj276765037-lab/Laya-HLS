"""Controller file audit only; does not execute DUT or historical audit scripts."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, shutil, re, difflib

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUN = ROOT / 'project/E005_full_request_performance/experiment_results/runs/R001'
OLD = RUN / 'attempts/AT047_LNQ0_chain_06'
NEW = RUN / 'attempts/AT048_LNQ1_observation_01'
LIVE = ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb'
for name in ['mission/current.md', 'results/overview.md', 'results/hardware_metrics.md',
             'results/hardware_progress.md', 'results/review_queue.md', 'results/reviews/SM005.md',
             'project/missions/SM005.md', 'agent/A001/result.md', 'agent/A001/state.json', 'NEW_CHAT_START.md']:
    dst = OUT / 'prior_records' / name
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists():
        shutil.copy2(ROOT / name, dst)

cache, checks = {}, []
def ident(p):
    p = Path(p)
    if str(p) not in cache:
        h, n = hashlib.sha256(), 0
        with p.open('rb') as f:
            while b := f.read(4 * 1024**2):
                h.update(b); n += len(b)
        cache[str(p)] = dict(path=str(p), bytes=n, sha256=h.hexdigest())
    return cache[str(p)]
def refs(obj, origin):
    if isinstance(obj, dict):
        if {'path', 'bytes', 'sha256'} <= obj.keys():
            actual = ident(obj['path'])
            ok = all(obj[k] == actual[k] for k in ['bytes', 'sha256'])
            checks.append(dict(origin=origin, expected=obj, actual=actual, match=ok))
            assert ok, origin
        else:
            for k, v in obj.items(): refs(v, origin + '/' + k)
    elif isinstance(obj, list):
        for i, v in enumerate(obj): refs(v, origin + '/' + str(i))
def readj(p): return json.loads(Path(p).read_text())

m, oldm, receipt = readj(NEW/'source_manifest.json'), readj(OLD/'source_manifest.json'), readj(NEW/'receipt.json')
refs(m, 'AT048/manifest'); refs(receipt, 'AT048/receipt')
assert len(m['files']) == 286 and len({x['path'] for x in m['files']}) == 285
assert receipt['verdict'] == 'COST_STOP_INVALID_RUNTIME_ROM_STAGING'
changes = []
for a, b in zip(oldm['files'], m['files'], strict=True):
    assert a['role'] == b['role']
    if a['role'] == 'new_frozen':
        assert Path(a['path']).name == Path(b['path']).name
        refs(a, 'AT047/new_frozen')
        if a['sha256'] != b['sha256']: changes.append(Path(b['path']).name)
    else:
        assert a == b
assert sorted(changes) == ['laya_lnq0_source_stage_v1.sv', 'lnq0_chain_tb_v1.sv']
for name in changes:
    diff = ''.join(difflib.unified_diff((OLD/'frozen_new'/name).read_text().splitlines(True),
                                      (NEW/'frozen_new'/name).read_text().splitlines(True),
                                      fromfile='AT047/'+name, tofile='AT048/'+name))
    (OUT/(name+'.diff')).write_text(diff)

guards = []
for stage in ['static', 'full']:
    p = NEW / ('guard_' + stage)
    plan, result, policy = [readj(p/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json']]
    assert plan['maximum_seconds'] == (1800 if stage == 'static' else 3600)
    assert plan['maximum_owned_rss_kb'] == (24 if stage == 'static' else 8)*1024**2
    assert plan['minimum_mem_available_kb'] == 192*1024**2
    assert plan['semantic_stall_seconds'] == 120 and plan['selected_cpu_ids'] == [0,1,2,3]
    assert result == receipt['stages'][stage]['guard']
    assert result['minimum_mem_available_kb'] > plan['minimum_mem_available_kb']
    assert result['peak_owned_rss_kb'] < plan['maximum_owned_rss_kb']
    assert policy and all(x['matches'] and x['affinity'] == [0,1,2,3] and x['nice'] == 19
                         and x['ionice'] == 'idle' and x['ionice_exit'] == 0 for x in policy)
    guards.append(dict(stage=stage, plan=plan, result=result, policy_samples=len(policy),
                       evidence=[ident(p/n) for n in ['guard_plan.json','guard_result.json','policy_checks.json']]))
assert guards[0]['result']['child_exit_code'] == 0 and guards[0]['result']['trigger'] is None
assert guards[1]['result']['child_exit_code'] == -9 and guards[1]['result']['trigger'] == 'semantic_stall'
assert datetime.fromisoformat(guards[0]['result']['finished_at']) < datetime.fromisoformat(guards[1]['plan']['at'])
assert sum(g['policy_samples'] for g in guards) == 35
assert 'LNQ0_STATIC_PASS' in (NEW/'guard_static/driver.log').read_text()
raw = (NEW/'guard_full/driver.log').read_text()
missing = re.findall(r'^WARNING: File \./(\S+\.dat).*cannot be opened for reading', raw, re.M)
assert len(missing) == 8 and len(set(missing)) == 7
assert 'MATRIX_PROGRESS cycle=149 LN_generated_row_cursor=0' in raw
for forbidden in ['source_AR row=', 'destination_B row=', 'LNQ1_WITNESS_END_SAMPLE',
                  'LNQ1_WITNESS_PUBLISH_SAMPLE', 'LNQ0_CHAIN_PASS', 'Fatal:']:
    assert forbidden not in raw
rom = readj(NEW/'missing_dat_audit.json')
oldcwd = Path(readj(OLD/'guard_full/guard_plan.json')['cwd'])
newcwd = Path(guards[1]['plan']['cwd'])
rom_checks = []
datrefs = [f for f in m['files'] if f['path'].endswith('.dat')]
assert len(datrefs) == 7 and set(missing) == {Path(x['path']).name for x in datrefs}
for item in rom['items']:
    source = ident(item['frozen_source']); staged = ident(oldcwd/item['name'])
    assert source['sha256'] == staged['sha256'] == item['frozen_sha256']
    assert source['bytes'] == staged['bytes']
    assert not (newcwd/item['name']).exists()
    assert missing.count(item['name']) == item['AT048_warning_count']
    rom_checks.append(dict(source=source, AT047_staged=staged,
                           AT048_target=str(newcwd/item['name']), AT048_exists=False,
                           warning_count=missing.count(item['name'])))
assert sum(x['source']['bytes'] for x in rom_checks) == 338

cost = readj(NEW/'full_cost_decision.json')
f = cost['forecast']
forecast = (f['structural_LN_reference_cycles'] + f['structural_post_reference_cycles'] *
            f['post_unentered_slowdown_factor']) / f['conservative_pilot_rate_cycles_per_second'] * f['reserve_factor']
assert abs(forecast - f['admission_forecast_seconds']) < 1e-7 and forecast < 3600
assert cost['pilot_reuse']['guard'] == readj(OLD/'guard_pilot/guard_result.json')

# Keep copies of the live preparation addendum for a time-specific code review.
# Host execution of its positive/negative checks is engineering-reported only.
live_ids = []
for name, expected in [
    ('run_lnq0_chain_v1.tcl', '2c7f28d45a8af296b8026073cd989a2b2ac80f666b10551121c51a6819e489b6'),
    ('stage_ln_roms_v1.tcl', '31d7e56d5e2b63cf1510d84129db542f35779704dfc051cf9f36f11286e17a85')]:
    x = ident(LIVE/name); assert x['sha256'] == expected
    dst = OUT/'reviewed_preparation'/name; dst.parent.mkdir(exist_ok=True)
    if not dst.exists(): shutil.copy2(LIVE/name, dst)
    assert ident(dst)['sha256'] == x['sha256']
    live_ids.append(dict(live=x, review_copy=ident(dst)))
helper = (OUT/'reviewed_preparation/stage_ln_roms_v1.tcl').read_text()
expected_roms = dict(re.findall(r'(laya_\S+\.dat) ([0-9a-f]{64})', helper))
assert expected_roms == {x['name']: x['frozen_sha256'] for x in rom['items']}
assert helper.index('Validate every frozen source') < helper.index('file copy -force')
runner = (OUT/'reviewed_preparation/run_lnq0_chain_v1.tcl').read_text()
assert runner.index('-step elaborate') < runner.index('stage_ln_roms_v1 $ln_engine') < runner.index('puts LNQ0_STATIC_PASS')
oldrunner = (NEW/'frozen_new/run_lnq0_chain_v1.tcl').read_text()
assert 'stage_ln_roms_v1' not in oldrunner
(OUT/'runner_preparation.diff').write_text(''.join(difflib.unified_diff(
    oldrunner.splitlines(True), runner.splitlines(True), fromfile='AT048/runner', tofile='live_reviewed/runner')))

result = dict(at=datetime.now(timezone.utc).isoformat(), scope='Controller read-only file/guard audit; no DUT run',
              references=checks, reference_count=len(checks), unique_hashed_paths=len(cache), all_references_match=True,
              manifest_rows=286, manifest_unique_paths=285, changed_files=changes,
              guards=guards, guard_count=2, policy_samples=35, serial=True, rom=rom_checks,
              missing_warning_lines=8, missing_unique_roms=7, last_observed_cycle=149,
              final_simulation_cycle='UNKNOWN; last marker is not final edge',
              live_preparation=live_ids, helper_expected_hashes_verified=True,
              helper_execution='Engineering reports host positive/corrupted-source checks; not independently rerun by controller',
              preparation_gap='Post-elaboration copy/check is present. Direct xsim launch still needs immediate verify-only gate of resolved cwd/ROM/fixtures and bounded startup smoke.',
              cost_seconds=forecast, cost_qualification='Conditional runtime-equivalence assumption failed; no chain timing evidence',
              observation_review='Two TB-only passive witness changes; no new DUT/fixture/clock/response change; dynamic witness NOT_REACHED',
              verdict='AT048 static PASS; full COST_STOP_INVALID_RUNTIME_ROM_STAGING. No new integration verdict.',
              next='LNQ2 runtime preparation only, then bounded prefix and at most one separately admitted cold full; AT048 DUT/TB unchanged')
(OUT/'verification.json').write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_hashed_paths','guard_count','policy_samples','missing_unique_roms','verdict']}, ensure_ascii=False))
