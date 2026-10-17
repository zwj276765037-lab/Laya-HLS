"""Bounded controller audit of frozen AT243--250 evidence; no simulation."""
from pathlib import Path
from decimal import Decimal
import datetime, hashlib, json, os, resource, subprocess, time

ROOT = Path(__file__).resolve().parents[2]
B = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
start = time.monotonic()
sha = lambda b: hashlib.sha256(b).hexdigest()
identities, artifacts, policies, fixtures, parents, guards = [], [], [], [], [], []
totals = {'static': Decimal(0), 'rtl': Decimal(0)}
for number in range(243, 251):
    choices = list(B.glob(f'AT{number}_*'))
    assert len(choices) == 1, number
    a = choices[0]
    manifest = json.loads((a/'source_manifest.json').read_text())
    for name, expected in manifest['files'].items():
        f = a/'frozen'/name
        actual = sha(f.read_bytes())
        identities.append(dict(path=str(f.relative_to(ROOT)), expected=expected, actual=actual))
        assert actual == expected, f
    for g in sorted(a.glob('guard*/guard_result.json')):
        result = json.loads(g.read_text(), parse_float=Decimal)
        category = 'static' if 'static' in g.parent.name else 'rtl'
        totals[category] += result['elapsed_seconds']
        guards.append(dict(attempt=a.name, guard=g.parent.name, category=category,
                           elapsed_seconds=str(result['elapsed_seconds']),
                           child_exit_code=result['child_exit_code'], trigger=result['trigger']))
        plan = json.loads((g.parent/'guard_plan.json').read_text())
        assert plan['selected_cpu_ids'] == [0,1,2,3]
        assert plan['minimum_mem_available_kb'] == 201326592
        assert result['minimum_mem_available_kb'] > 201326592
        assert result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb']
        for sample in json.loads((g.parent/'policy_checks.json').read_text()):
            policies.append(dict(path=str((g.parent/'policy_checks.json').relative_to(ROOT)), sample=sample))
            assert sample['affinity'] == [0,1,2,3] and sample['nice'] == 19
            assert sample['ionice'] == 'idle' and sample['ionice_exit'] == 0 and sample['matches']
        for name in ('guard_result.json','guard_plan.json','policy_checks.json','driver.log','launch.json'):
            f = g.parent/name
            if f.exists(): artifacts.append(dict(path=str(f.relative_to(ROOT)), bytes=f.stat().st_size, sha256=sha(f.read_bytes())))

A = B/'AT250_SM004_rev15_s128_real_prefix_01'
old = B/'AT225_SM004_rev14_rope_real_rows01_progress_02'
for directory in ('fixture_qkv','fixture_ffn'):
    for f in sorted((A/directory).iterdir()):
        assert f.is_file()
        prior = old/directory/f.name
        assert prior.is_file() and f.read_bytes() == prior.read_bytes(), f
        fixtures.append(dict(path=str(f.relative_to(ROOT)), same_as=str(prior.relative_to(ROOT)), sha256=sha(f.read_bytes())))
manifest = json.loads((A/'fixture_qkv/manifest.json').read_text())
for label, item in manifest['inputs'].items():
    p = ROOT/item['path']
    with p.open('rb') as stream:
        stream.seek(item['offset']); payload = stream.read(item['bytes'])
    assert len(payload) == item['bytes'] and sha(payload) == item['sha256'], label
    parents.append(dict(label=label, **item))
for label, item in manifest['outputs'].items():
    filename = label if label.endswith('.hex') else label+'.hex'
    payload = (A/'fixture_qkv'/filename).read_bytes()
    assert len(payload) == item['bytes'] and sha(payload) == item['sha256'], label

def read_hex(name, width):
    return b''.join(int(word,16).to_bytes(width,'little') for word in (A/'fixture_qkv'/name).read_text().split())

reference = ROOT/'source/fixed_graph_support_20261014/rope_reference_rows01_20261015/run01'
checks = {}
for row in (0,1):
    checks[f'row{row}_RoPE_final_bytes'] = read_hex(f'rope_final_row{row}.hex',4) == (reference/f'products/row{row}_full_FINAL.f32.bin').read_bytes()
    raw = parents[0] if parents[0]['label']=='raw' else next(x for x in parents if x['label']=='raw')
    with (ROOT/raw['path']).open('rb') as f:
        f.seek(row*4096); expected=f.read(4096)
    checks[f'row{row}_raw_bytes'] = read_hex(f'raw_row{row}.hex',4) == expected
checks['gamma_bytes'] = read_hex('gamma.hex',4) == (ROOT/manifest['inputs']['gamma']['path']).read_bytes()[128:4224]
assert all(checks.values())
logs = {}
for number, terminal in [(246,'SOURCE_PREPARE_PASS'),(249,'S128_SEQUENCER_PEER_PASS'),(250,'PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX')]:
    a = next(B.glob(f'AT{number}_*'))
    log = (a/'guard_rtl/driver.log').read_text()
    assert log.count(terminal) == 1 and 'Fatal:' not in log and 'ERROR:' not in log
    logs[str(number)] = [line for line in log.splitlines() if any(s in line for s in (terminal,'ROPE_QKV_ROW_PASS','ROPE_TWO_ROW_REAL_PASS','QKV_CMD_ACCEPT','SOURCE_PREFIX_NEXT_ROW'))]
    result=json.loads((a/'guard_rtl/guard_result.json').read_text())
    assert result['child_exit_code']==0 and result['trigger'] is None

current = {}
rtl = ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
for name in ('laya_lnq_wi_gqdown_row_v1.sv','laya_qkv_scratch_row_v1.sv','laya_qkv_s128_request_v1.sv'):
    frozen = sha((A/'frozen'/name).read_bytes())
    now = sha((rtl/name).read_bytes())
    current[name] = dict(frozen=frozen, sampled_current=now, equal=frozen==now)
record = dict(reviewed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    source_message='m004-rev15-at250-source-prefix-milestone-20261015',
    identity_count=len(identities), identities=identities,
    artifact_count=len(artifacts), artifacts=artifacts,
    actual_policy_sample_count=len(policies), policies=policies,
    fixture_count=len(fixtures), fixtures=fixtures, fixture_parent_windows=parents,
    byte_checks=checks, terminal_lines=logs, current_identity_sample=current,
    guard_snapshot_through_AT250=guards,
    guard_cost_snapshot_seconds={k:str(v) for k,v in totals.items()},
    verdict='PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX_AT250_ONLY; REV15_REMAINS_RUNNING',
    not_accepted=['all128 real producer','whole request success','full-model error-order equivalence','physical BO/sentinels','input error recovery/reset/legacy not yet reviewed'],
    static_finding='AT250 wrapper abort is asserted on entry IN_ERR before read-debt retirement; core abort may clear prep_abort_ready before wrapper exit condition. Fix and local evidence required, no normal-prefix invalidation.',
    sampling=dict(internal_wall_seconds=time.monotonic()-start, maxrss_before_evidence_write_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                  affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),
                  ionice=subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip(),
                  interactive_reads_total='UNKNOWN'))
p=ROOT/'results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json'
d=json.loads(p.read_text());assert 'revision15_at250_prefix_milestone_review' not in d
d['revision15_at250_prefix_milestone_review']=record
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ['identity_count','artifact_count','actual_policy_sample_count','fixture_count','byte_checks','guard_cost_snapshot_seconds','current_identity_sample','verdict','sampling']},ensure_ascii=False))
