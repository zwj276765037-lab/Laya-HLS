"""Verify the last-row peer receipts without running simulation or an oracle."""
from pathlib import Path
from decimal import Decimal
import datetime, hashlib, json, os, resource, subprocess, time

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'project/E004_full_accelerator_integration/experiment_results/runs/R001'
A = BASE / 'attempts/AT265_SM004_rev15_s128_last_row_error_peer_01'
REPORT = BASE / 'reports/SM004_rev15_guard_ledger_AT243_AT265_20261015.json'
OLD = BASE / 'reports/SM004_rev15_guard_ledger_AT243_AT264_20261015.json'
EVIDENCE = ROOT / 'results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json'
started = time.monotonic()
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def rel(p): return str(p.relative_to(ROOT))
def artifact(p): return {'path': rel(p), 'sha256': sha(p), 'bytes': p.stat().st_size}

m = json.loads((A/'source_manifest.json').read_text())
assert sha(A/'source_manifest.json') == 'a74c147ce4c1cc5d4d0a0bd48c2e5966514ac4b79f6cae0f3fe8bf2ae00f7ee6'
identities = []
for name, expected in m['files'].items():
    p = A/'frozen'/name
    assert sha(p) == expected, p
    identities.append(dict(artifact(p), expected=expected))
assert len(identities) == 5
seq = 'laya_qkv_s128_request_v1.sv'
prior = BASE/'attempts/AT252_SM004_rev15_s128_latched_fields_peer_01/frozen'/seq
rtl = ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
assert sha(prior) == sha(rtl/seq) == sha(A/'frozen'/seq) == m['production_sequencer_sha256']
existing = json.loads(EVIDENCE.read_text())
current = existing['revision15_at264_stage_closeout_review']['current_sources']
assert all(sha(rtl/name) == digest for name, digest in current.items())

ledger = json.loads(REPORT.read_text())
old = json.loads(OLD.read_text())
old_entries = [e for e in ledger['entries'] if e['attempt'] != A.name]
assert old_entries == old['entries'] and len(old_entries) == 42
new_entries = [e for e in ledger['entries'] if e['attempt'] == A.name]
assert len(new_entries) == 2
assert {str(p.relative_to(ROOT)) for p in A.glob('guard*/guard_result.json')} == {e['guard_result'] for e in new_entries}
artifacts = [artifact(A/'source_manifest.json'), artifact(REPORT)]
policies = []
for entry in new_entries:
    g = ROOT/entry['guard_result']
    result = json.loads(g.read_text(), parse_float=Decimal)
    plan = json.loads((g.parent/'guard_plan.json').read_text())
    assert result['elapsed_seconds'] == Decimal(entry['elapsed_seconds']) <= 20
    assert result['child_exit_code'] == entry['child_exit_code'] == 0
    assert result['trigger'] is entry['trigger'] is None
    assert plan['maximum_seconds'] == 20
    assert result['peak_owned_rss_kb'] == entry['peak_owned_rss_kib'] <= plan['maximum_owned_rss_kb']
    assert result['minimum_mem_available_kb'] == entry['minimum_mem_available_kib'] > 201326592
    assert plan['selected_cpu_ids'] == [0,1,2,3]
    assert plan['minimum_mem_available_kb'] == 201326592
    samples = json.loads((g.parent/'policy_checks.json').read_text())
    assert len(samples) == entry['policy_samples'] and entry['policy_mismatches'] == 0
    for s in samples:
        assert s['affinity'] == [0,1,2,3] and s['nice'] == 19
        assert s['ionice'] == 'idle' and s['ionice_exit'] == 0 and s['matches']
    policies.extend(samples)
    log = (g.parent/'driver.log').read_text()
    assert 'Fatal:' not in log and 'ERROR:' not in log
    terminal = 'S128_PEER_ELAB_PASS' if entry['class'] == 'static' else 'S128_LAST_ROW_ERROR_PEER_PASS'
    assert log.count(terminal) == 1
    for name in ('guard_result.json','guard_plan.json','policy_checks.json','driver.log','launch.json'):
        p = g.parent/name
        if p.exists(): artifacts.append(artifact(p))
assert len(policies) == 11
totals = {k: sum((Decimal(e['elapsed_seconds']) for e in ledger['entries'] if e['class'] == k), Decimal(0)) for k in ('static','rtl')}
for k, limit in (('static',1800),('rtl',4800)):
    assert totals[k] == Decimal(ledger['totals'][k+'_seconds'])
    assert Decimal(limit)-totals[k] == Decimal(ledger['totals'][k+'_remaining_seconds'])
assert ledger['totals']['static_guards'] == 21 and ledger['totals']['rtl_guards'] == 23
assert sum(e['policy_samples'] for e in ledger['entries']) == 413 == ledger['totals']['policy_samples']
assert ledger['totals']['policy_mismatches'] == 0
record = dict(
    reviewed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    source_message='m004-rev15-at265-last-row-error-peer-handoff-20261015',
    prior_review='revision15_at264_stage_closeout_review',
    decision_id='D-M004-REV15-CLOSEOUT-01',
    verdict='PASS_SCOPED_S128_LAST_ROW_ERROR_COMPLETION_PEER',
    stage_status='bounded_closed', budget_sealed=True,
    identities=identities, new_identity_count=len(identities), total_identity_count=1275,
    artifacts=artifacts, artifact_count=len(artifacts),
    new_policy_samples=policies, total_policy_sample_count=413,
    original_42_entries_unchanged=True, new_entries=new_entries,
    cost_seconds={k:str(v) for k,v in totals.items()},
    remaining_seconds={k:str(Decimal(limit)-totals[k]) for k,limit in (('static',1800),('rtl',4800))},
    host_complete_total='UNKNOWN', current_sources=current,
    audit_scope='Frozen production sequencer and legal row completion peer; no EDA/oracle run',
    manual_source_review='128 genuine row commands,127 successful done handshakes and1 failed done; request7/14/bad all1/id208/row127 held3 cycles until consumption; retired_rows127, first127 RAW/FINAL bits set and last clear; no final publication or extra row in observed window. No real128-row arithmetic or row127 input fault proof.',
    sampling=dict(internal_wall_seconds=time.monotonic()-started,maxrss_before_final_write_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),ionice=subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip(),interactive_reads_total='UNKNOWN'))
existing['revision15_at265_last_row_error_closeout_review'] = record
EVIDENCE.write_text(json.dumps(existing, ensure_ascii=False, indent=2)+'\n')
print(json.dumps({k:record[k] for k in ('verdict','new_identity_count','artifact_count','total_policy_sample_count','cost_seconds','remaining_seconds')}, ensure_ascii=False))
