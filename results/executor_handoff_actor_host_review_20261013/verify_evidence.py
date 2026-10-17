from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib, struct, re

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
cache = {}
def sha(p):
    p = Path(p)
    if str(p) not in cache:
        cache[str(p)] = hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
    return cache[str(p)]
def read(p): return json.loads(Path(p).read_text())
snapshots = {}
def snap(p):
    p = Path(p); t = OUT / 'snapshot' / p.relative_to(ROOT)
    t.parent.mkdir(parents=True, exist_ok=True)
    if not t.exists(): shutil.copyfile(p, t)
    assert sha(p) == sha(t)
    snapshots[str(t.relative_to(ROOT))] = sha(t)
def entries(x):
    if isinstance(x, dict):
        if 'original' in x and 'frozen' in x: yield x
        else:
            for v in x.values(): yield from entries(v)
    elif isinstance(x, list):
        for v in x: yield from entries(v)
def refs(x, origin):
    if isinstance(x, dict):
        if isinstance(x.get('path'), str) and isinstance(x.get('sha256'), str):
            actual = sha(x['path'])
            yield dict(origin=origin, path=x['path'], expected=x['sha256'], actual=actual, match=actual == x['sha256'])
        for v in x.values(): yield from refs(v, origin)
    elif isinstance(x, list):
        for v in x: yield from refs(v, origin)

aggregate_path = RUNS / 'executor_actor_verification_20261013.json'
assert sha(aggregate_path) == 'f625a58f585e582de2058d89cfad0236e3e41a7ebd07f5a60c609bbd8c40a769'
aggregate = read(aggregate_path)
delta_path = RUNS / 'executor_actor_catalog_delta_20261013.json'
delta = read(delta_path)
delivery_path = RUNS / 'executor_handoff_actor_deliverables_20261013.json'
delivered = read(delivery_path)['files']
for item in delivered:
    assert sha(item['path']) == item['sha256']; snap(item['path'])
snap(delivery_path); snap(delta_path)
pairs = []; references = []; stages = []; manifest_by_attempt = {}
for name in ['executor_actor_host_02', 'executor_checkpoint_host_05']:
    base = RUNS / name
    m = read(base / 'input_manifest.json'); receipt = read(base / 'receipt.json')
    manifest_by_attempt[name] = m
    assert receipt['status'] == 'PASS'
    snap(base / 'input_manifest.json'); snap(base / 'receipt.json')
    for e in entries(m):
        a, b = e['original'], e['frozen']
        current, frozen = sha(a['path']), sha(b['path'])
        assert frozen == b['sha256'] == a['sha256']
        pairs.append(dict(attempt=name, path=a['path'], frozen_path=b['path'], expected=a['sha256'],
                          current=current, frozen=frozen, current_match=current == a['sha256'],
                          frozen_match=True, pair_match=True))
        if Path(b['path']).suffix in ['.h', '.cpp', '.py', '.sv', '.json', '.cmake', '.md']: snap(b['path'])
        if current != a['sha256']: snap(a['path'])
    references.extend(refs(m, name + '/manifest')); references.extend(refs(receipt, name + '/receipt'))
    launcher = read(base / 'launcher.json'); snap(base / 'launcher.json')
    assert launcher['pass'] and launcher['cpu_affinity'] == [0,1,2,3]
    assert launcher['nice'] == 19 and launcher['ionice'] == 'idle'
    assert launcher['mem_available_kib'] >= 201326592
    for mode in ['oracle', 'build', 'run']:
        entry = receipt[mode]; gd = base / ('guard_' + mode)
        guard = read(gd / 'guard_result.json'); plan = read(gd / 'guard_plan.json')
        launch = read(gd / 'launch.json')
        policy = read(gd / 'policy_checks.json') if (gd / 'policy_checks.json').exists() else []
        raw = (gd / 'driver.log').read_text()
        markers = [l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
        assert guard == entry['guard'] and entry['runner_exit_code'] == 0
        assert guard['child_exit_code'] == 0 and guard['trigger'] is None
        # The nested literal fixture runners also emit their own markers;
        # the receipt selects only this stage's top-level marker.
        assert all(marker in markers for marker in entry['markers'])
        if mode != 'oracle': assert entry['markers'] == markers
        assert plan['maximum_seconds'] == 1800 and plan['maximum_owned_rss_kb'] == 25165824
        assert plan['semantic_stall_seconds'] == 120 and plan['minimum_mem_available_kb'] == 201326592
        assert guard['elapsed_seconds'] <= 1800 and guard['minimum_mem_available_kb'] >= 201326592
        assert all(p['matches'] and p['affinity'] == [0,1,2,3] and p['nice'] == 19 and p['ionice'] == 'idle' for p in policy)
        if guard['rss_captured']: assert guard['peak_owned_rss_kb'] <= 25165824 and policy
        else: assert name == 'executor_actor_host_02' and mode == 'run' and guard['peak_owned_rss_kb'] is None and not policy
        for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
            if (gd / f).exists(): snap(gd / f)
        stages.append(dict(attempt=name, mode=mode, start=launch['at'], finish=guard['finished_at'],
                           guard=guard, plan=plan, policy_count=len(policy), markers=markers))
    for item in receipt.get('fixture_files', []):
        assert sha(item['path']) == item['sha256']; snap(item['path'])
ordered = sorted(stages, key=lambda s:s['start'])
assert all(datetime.fromisoformat(a['finish']) <= datetime.fromisoformat(b['start']) for a,b in zip(ordered, ordered[1:]))
assert len(stages) == 6 and sum(s['policy_count'] for s in stages) == 55
assert len(pairs) == 158 and len(references) == 366
catalog_after = {x['after']['path']: x['after']['sha256'] for x in delta['changes']}
differences = [{**p, 'matches_catalog_delta': catalog_after.get(p['path']) == p['current']} for p in pairs if not p['current_match']]
ref_differences = [p for p in references if not p['match']]

old_base = RUNS / 'executor_actor_host_01'
old_manifest = read(old_base / 'input_manifest.json')
old = {e['original']['path']: e for e in entries(old_manifest)}
new = {e['original']['path']: e for e in entries(manifest_by_attempt['executor_actor_host_02'])}
changes = []
for path in sorted(old.keys() & new.keys()):
    a, b = old[path]['frozen'], new[path]['frozen']
    assert sha(a['path']) == a['sha256'] and sha(b['path']) == b['sha256']
    if a['sha256'] != b['sha256']:
        changes.append(path)
        diff = ''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True), Path(b['path']).read_text().splitlines(True), fromfile='actor_01/'+Path(path).name, tofile='actor_02/'+Path(path).name))
        (OUT / (Path(path).name + '.diff')).write_text(diff)
for f in ['input_manifest.json','receipt.json','guard_run/driver.log','guard_run/guard_result.json']: snap(old_base / f)
assert read(old_base / 'receipt.json')['status'] == 'PASS'

fixture = RUNS / 'executor_actor_host_02/fixture'
goldbase = bytearray((fixture / 'v2/checkpoint_request.bin').read_bytes())
struct.pack_into('<IHH', goldbase, 0, 0x3143484c, 1, 16)
struct.pack_into('<Q', goldbase, 32, (1 << 64) - 1)
struct.pack_into('<QQ', goldbase, 776, 29, 101)
frames = []
for kind in range(1,8):
    p = bytearray(goldbase); p[8] = kind
    struct.pack_into('<Q', p, 680, 0 if kind == 1 else 19); p[792] = int(kind in [3,4])
    if kind >= 5:
        struct.pack_into('<H', p, 10, 7); struct.pack_into('<I', p, 24, 0x0700000e)
    assert len(p) == 1024 and p == (fixture / f'control_{kind}.bin').read_bytes()
    frames.append(p)
assert b''.join(frames) == (fixture / 'all_control.bin').read_bytes()
frozen = RUNS / 'executor_actor_host_02/frozen'
sv = (frozen / 'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_layout_v1.sv').read_text()
for k, n in aggregate['static_sv_layout'].items():
    assert re.search(r'\b' + k + r'\s*=\s*' + str(n) + r'\s*[,;]', sv)
assert len(manifest_by_attempt['executor_actor_host_02']['production_sources']) == 21
assert not manifest_by_attempt['executor_actor_host_02']['forbidden_present']
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json', '.research-agent/communications/executor-handoff-actor-host-milestone-20261013.json']: snap(ROOT / f)
summary = dict(pairs=len(pairs), frozen_matches=158, declared_pairs=158,
               current_matches=sum(p['current_match'] for p in pairs), references=len(references),
               reference_matches=sum(p['match'] for p in references), deliverables=len(delivered),
               guards=6, policy_records=55, oracle_bytes=7168)
v = dict(review_id='R-SM003-EXECUTOR-HANDOFF-ACTOR-HOST-20261013', checked_at=datetime.now(timezone.utc).isoformat(),
         summary=summary, delivered=delivered, pairs=pairs, references=references, current_differences=differences,
         reference_differences=ref_differences, stages=stages, serial_no_overlap=True,
         actor_01_to_02=dict(common_pairs=len(old.keys() & new.keys()), changes=changes, old_status='PASS'),
         literal_oracle=dict(bytes=7168, frames=7, independently_reconstructed=True, sv_static_constants=aggregate['static_sv_layout'], sv_execution=False),
         snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()], no_controller_compilation_simulation_hls=True,
         decision='pending_source_review')
(OUT / 'verification.json').write_text(json.dumps(v, ensure_ascii=False, indent=2)+'\n')
print(json.dumps(dict(summary=summary, differences=[dict(attempt=p['attempt'],path=p['path'],catalog=p['matches_catalog_delta']) for p in differences], history=v['actor_01_to_02']), ensure_ascii=False, indent=2))
