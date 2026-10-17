"""Read-only source/receipt verification for the rev15 stage closeout."""
from pathlib import Path
from decimal import Decimal
import datetime, hashlib, json, os, resource, subprocess, time

ROOT = Path(__file__).resolve().parents[2]
B = ROOT/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
EVIDENCE = ROOT/'results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json'
ledger_path = ROOT/'project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT264_20261015.json'
old_review = json.loads(EVIDENCE.read_text())['revision15_at250_prefix_milestone_review']
ledger = json.loads(ledger_path.read_text())
started = time.monotonic()
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def relative(path): return str(path.relative_to(ROOT))
identities, artifacts, fixture_pairs, policies, guards, lineage = [], [], [], [], [], []
fixture_reference_only = []
old_id = {x['path']:x['expected'] for x in old_review['identities']}
prior_count = 0
for number in range(243,265):
    candidates=list(B.glob(f'AT{number}_*'));assert len(candidates)==1,number
    a=candidates[0];m=json.loads((a/'source_manifest.json').read_text())
    for name,expected in m['files'].items():
        path=a/'frozen'/name
        if number<=250:
            assert old_id[relative(path)]==expected
            prior_count+=1
        else:
            actual=digest(path);assert actual==expected,path
            identities.append(dict(path=relative(path),expected=expected,actual=actual))
    if number>250:
        artifacts.append(dict(path=relative(a/'source_manifest.json'),sha256=digest(a/'source_manifest.json')))
        if 'fixture_identity' in m:
            prior=Path(m['fixture_identity'])
            for directory in ('fixture_qkv','fixture_ffn'):
                if not (a/directory).is_dir():
                    fixture_reference_only.append(dict(attempt=a.name, directory=directory, reference=str(prior), actual_local_copy=False))
                    continue
                for f in sorted((a/directory).iterdir()):
                    if not f.is_file():continue
                    old=prior/directory/f.name
                    assert old.exists() and f.read_bytes()==old.read_bytes(),f
                    fixture_pairs.append(dict(path=relative(f),same_as=relative(old),sha256=digest(f)))

totals={'static':Decimal(0),'rtl':Decimal(0)}
counts={'static':0,'rtl':0}
prior_policies=0
all_actual=set()
for number in range(243,265):
    a=next(B.glob(f'AT{number}_*'))
    all_actual.update(relative(p) for p in a.glob('guard*/guard_result.json'))
assert all_actual=={x['guard_result'] for x in ledger['entries']}
for entry in ledger['entries']:
    path=ROOT/entry['guard_result'];directory=path.parent
    result=json.loads(path.read_text(),parse_float=Decimal)
    plan=json.loads((directory/'guard_plan.json').read_text())
    number=int(entry['attempt'][2:5]);category=entry['class']
    assert category==('static' if directory.name=='guard_static' else 'rtl')
    assert Decimal(entry['elapsed_seconds'])==result['elapsed_seconds']
    assert entry['child_exit_code']==result['child_exit_code'] and entry['trigger']==result['trigger']
    assert digest(directory.parent/'source_manifest.json')==entry['source_manifest_sha256']
    assert result['peak_owned_rss_kb']==entry['peak_owned_rss_kib']<=plan['maximum_owned_rss_kb']
    assert result['minimum_mem_available_kb']==entry['minimum_mem_available_kib']>201326592
    assert plan['selected_cpu_ids']==[0,1,2,3] and plan['minimum_mem_available_kb']==201326592
    assert plan['maximum_seconds']<=(600 if category=='static' else 2400)
    totals[category]+=result['elapsed_seconds'];counts[category]+=1
    samples=json.loads((directory/'policy_checks.json').read_text())
    assert len(samples)==entry['policy_samples'] and entry['policy_mismatches']==0
    for sample in samples:
        assert sample['affinity']==[0,1,2,3] and sample['nice']==19
        assert sample['ionice']=='idle' and sample['ionice_exit']==0 and sample['matches']
    if number<=250:prior_policies+=len(samples)
    else:
        policies.extend(dict(path=relative(directory/'policy_checks.json'),sample=s) for s in samples)
        for name in ('guard_result.json','guard_plan.json','policy_checks.json','driver.log','launch.json'):
            p=directory/name
            if p.exists():artifacts.append(dict(path=relative(p),sha256=digest(p),bytes=p.stat().st_size))
    log=(directory/'driver.log').read_text()
    if result['child_exit_code']==0:
        assert result['trigger'] is None and 'Fatal:' not in log and 'ERROR:' not in log
    guards.append(dict(**entry,terminal_lines=[s for s in log.splitlines() if any(x in s for x in ('PASS','PREP_FAULT_DURING_RAW_LOAD','Fatal:','ERROR:'))]))
assert counts=={'static':20,'rtl':22}
assert prior_count==old_review['identity_count']==547
assert prior_policies==old_review['actual_policy_sample_count']==135
assert totals['static']==Decimal(ledger['totals']['static_seconds'])
assert totals['rtl']==Decimal(ledger['totals']['rtl_seconds'])
assert len(policies)+prior_policies==ledger['totals']['policy_samples']==402
assert len(identities)+prior_count==1270

A=next(B.glob('AT264_*'));P=next(B.glob('AT261_*'))
for f in (A/'frozen').iterdir():
    if f.suffix not in ('.sv','.v','.vhd','.tcl') or '_tb.' in f.name:continue
    peer=P/'frozen'/f.name
    if peer.exists():
        assert f.read_bytes()==peer.read_bytes(),f
        lineage.append(dict(path=relative(f),compiled_parent=relative(peer),sha256=digest(f)))
for name in ('laya_qkv_scratch_row_v1','laya_lnq_wi_gqdown_row_v1','t4_w_reader_port_v1','t4_aux_bias_reader_v1'):
    current=A/'work/xsim.dir/work'/(name+'.sdb')
    prior=P/'work/xsim.dir/work'/(name+'.sdb')
    assert current.exists() and prior.exists() and digest(current)==digest(prior),name
    lineage.append(dict(compiled_database=relative(current),same_as=relative(prior),sha256=digest(current)))

rtl=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
current_sources={}
for name in ('laya_qkv_scratch_row_v1.sv','laya_lnq_wi_gqdown_row_v1.sv','tm1tn8_axi512_writer.sv','laya_rope_head_adapter_v1.sv'):
    assert digest(rtl/name)==digest(A/'frozen'/name),name
    current_sources[name]=digest(rtl/name)
current_sources['laya_qkv_s128_request_v1.sv']=digest(rtl/'laya_qkv_s128_request_v1.sv')
assert current_sources['laya_qkv_s128_request_v1.sv']==digest(next(B.glob('AT252_*'))/'frozen/laya_qkv_s128_request_v1.sv')
expected_terminals={
    (259,'guard_rtl'):'SOURCE_EARLY_FAULT_DRAIN_RECOVERY_PASS',
    (256,'guard_raw_only_aux_identity'):'SOURCE_RAW_ONLY_AUX_ID_PASS',
    (261,'guard_page_row127'):'SOURCE_PAGE_TAIL_ROW127_PASS',
    (262,'guard_legacy_ln'):'LEGACY_EXTERNAL_LN_PASS',
    (263,'guard_rtl'):'PREPARED_TOKEN_BOUNDARY_PASS',
    (264,'guard_rtl'):'SOURCE_LOGICAL_SENTINEL_PASS'}
for (num,guard),terminal in expected_terminals.items():
    text=(next(B.glob(f'AT{num}_*'))/guard/'driver.log').read_text()
    assert text.count(terminal)==1

record=dict(reviewed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    source_message='m004-rev15-at264-engineering-stage-handoff-20261015',
    ledger=dict(path=relative(ledger_path),sha256=digest(ledger_path)),
    prior_review='revision15_at250_prefix_milestone_review',
    inherited_identity_count=prior_count,new_identity_count=len(identities),new_identities=identities,
    total_identity_count=prior_count+len(identities),new_artifact_count=len(artifacts),new_artifacts=artifacts,
    new_policy_sample_count=len(policies),new_policy_samples=policies,total_policy_samples=prior_policies+len(policies),
    fixture_pair_count=len(fixture_pairs),fixture_pairs=fixture_pairs,fixture_reference_only=fixture_reference_only,compiled_lineage=lineage,
    current_sources=current_sources,guards=guards,
    cost_seconds={k:str(v) for k,v in totals.items()},guard_counts=counts,
    remaining_seconds={'static':str(Decimal(1800)-totals['static']),'rtl':str(Decimal(4800)-totals['rtl'])},
    host_complete_total='UNKNOWN',
    execution_claims='old AT250 two-row prefix; new AT264 single real row; all other local scopes retained separately',
    audit_scope='No EDA, oracle or DUT run; source/byte/receipt review only',
    sampling=dict(internal_wall_seconds=time.monotonic()-started,maxrss_before_final_write_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
      affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),ionice=subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip(),interactive_reads_total='UNKNOWN'))
d=json.loads(EVIDENCE.read_text());assert 'revision15_at264_stage_closeout_review' not in d
d['revision15_at264_stage_closeout_review']=record
EVIDENCE.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:record[k] for k in ['new_identity_count','total_identity_count','new_artifact_count','new_policy_sample_count','total_policy_samples','fixture_pair_count','current_sources','cost_seconds','remaining_seconds','sampling']},ensure_ascii=False))
