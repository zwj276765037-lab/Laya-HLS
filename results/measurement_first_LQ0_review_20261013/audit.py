from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re, difflib

R = Path(__file__).resolve().parents[2]
D = Path(__file__).resolve().parent
B = R / 'project/E005_full_request_performance/experiment_results/runs/R001/attempts'
A = B / 'AT014_LQ0_measurement_02'
H = B / 'AT015_LQ1_LN_hls_01'
def get(p): return json.loads(p.read_text())
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
verified = {}
def check(x, actual=None):
    p = actual or Path(x['path'])
    if not p.is_absolute(): p = R / p
    assert p.is_file(), str(p)
    assert sha(p) == x['sha256'], str(p)
    if 'bytes' in x: assert p.stat().st_size == x['bytes'], str(p)
    verified[str(p)] = {'bytes': p.stat().st_size, 'sha256': sha(p)}
    return p
def refs(x, skip=()):
    if isinstance(x, dict):
        if {'path', 'sha256'} <= x.keys(): check(x)
        else:
            for k, v in x.items():
                if k not in skip: refs(v, skip)
    elif isinstance(x, list):
        for v in x: refs(v, skip)

m, r = get(A/'input_manifest.json'), get(A/'receipt.json')
assert r['measurement_status'] == 'PASS_SCOPED'
refs(m, ('historical_tb',)); refs(r)
old = Path(m['historical_source_manifest']['path']).parent
om = get(old/'input_manifest.json')
old_declared = {str(Path(x['frozen']['path']).relative_to(old/'frozen')): x['frozen'] for x in om['files']}
new = {str(Path(x['path']).relative_to(A/'frozen')): x for x in m['frozen_files']}
assert len(old_declared) == 152 and len(new) == 153
extra = sorted(set(new)-set(old_declared))
assert extra == ['tools/__pycache__/hls_guard_helpers.cpython-312.pyc']
changed = []
for rel, x in new.items():
    oldp = old/'frozen'/rel
    assert oldp.is_file(), rel
    if rel in old_declared: check(old_declared[rel])
    if sha(oldp) != x['sha256']: changed.append(rel)
tbrel = 'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_layernorm_quant_source_shell_tb_v1.sv'
assert changed == [tbrel]
check(m['historical_tb'], old/'frozen'/tbrel)
before = (old/'frozen'/tbrel).read_text().splitlines()
after = (A/'frozen'/tbrel).read_text().splitlines()
ops = difflib.SequenceMatcher(None, before, after, autojunk=False).get_opcodes()
assert all(op in ('insert', 'equal') for op, *_ in ops)
assert len(before) == 601 and len(after) == 722
(D/'observation.diff').write_text('\n'.join(difflib.unified_diff(before, after, fromfile='historical_03', tofile='AT014', n=3))+'\n')
fixture_counts = {}
for key in ['fixture_files', 'pilot_fixture_files']:
    oldmap = {Path(x['path']).name: x for x in om[key]}
    assert len(m[key]) == len(oldmap) == 17
    for x in m[key]:
        y = oldmap[Path(x['path']).name]; check(y)
        assert (x['sha256'], x['bytes']) == (y['sha256'], y['bytes'])
    fixture_counts[key] = len(m[key])
assert len(r['native_ip']) == len(r['runtime_dat_staging']) == 7
for pair in r['runtime_dat_staging']:
    assert pair['source']['sha256'] == pair['staged']['sha256']
generated = [p for p in new if p.startswith('external/layernorm_producer_rtl/')]
assert len(generated) == 83
log = (A/'full_sim.log').read_text()
assert not re.search(r'^(?:FATAL|ERROR|Fatal|Error):', log, re.M)
markers = {}
for line in log.splitlines():
    if line.startswith(('LQ0_', 'FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS')):
        name = line.split()[0]
        markers[name] = {k: [int(i) for i in v.split(',')] if ',' in v else int(v) for k,v in re.findall(r'(\w+)=([\d,-]+)', line)}
e, ax, life, p = (markers[k] for k in ['LQ0_EVENT','LQ0_AXI','LQ0_LIFECYCLE','FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS'])
assert e['cycles'] == p['cycles'] == life['zero_debt'] == 659334
assert [e['phase'+str(i)] for i in range(6)] == [25,54,72,655290,3838,55]
assert sum(e['phase'+str(i)] for i in range(6)) == e['cycles']
assert ax['math_start'] == [4441,4441] and ax['math_done'] == [653821,653821] and ax['math_count'] == [1,1]
assert [e[k] for k in ['q_accept','q_consume','lease_off']] == [655498,658765,658766]
assert p['rows'] == 16 and p['gold_elements'] == 16384 and p['store_bytes'] == 65536
assert [p[k] for k in ['source_AR','source_R','destination_AW','destination_W','destination_B','quant_AR','quant_R','fullA_groups']] == [16,1024,16,1024,16,16,1024,128]
intervals=[]; policies=[]
for phase in ['static','pilot','full']:
    gdir=A/('guard_'+phase)
    g,launch,plan,pol=get(gdir/'guard_result.json'),get(gdir/'launch.json'),get(gdir/'guard_plan.json'),get(gdir/'policy_checks.json')
    assert g['child_exit_code']==0 and g['trigger'] is None
    assert g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and g['elapsed_seconds']<plan['maximum_seconds']
    assert g['minimum_mem_available_kb']>201326592 and plan['semantic_stall_seconds']==120
    assert all(x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['matches'] for x in pol)
    policies.extend(pol)
    intervals.append({'phase':phase,'start':launch['at'],'end':g['finished_at'],**g,'policy_samples':len(pol)})
assert all(datetime.fromisoformat(x['end'])<=datetime.fromisoformat(y['start']) for x,y in zip(intervals,intervals[1:]))

# LQ1 inspection is limited to the already-finished generation/source facts.
hm, hr = get(H/'input_manifest.json'), get(H/'receipt.json')
hp=Path(hm['original_manifest']['path']).parent
refs(hm, ('original_source',)); refs(hr)
check(hm['original_source'],hp/'frozen/hls/operators/layernorm_compute.cpp')
old_hm=get(hp/'input_manifest.json')
old_hmap={str(Path(x['frozen']['path']).relative_to(hp/'frozen')):x['frozen'] for x in old_hm['files']}
new_hmap={str(Path(x['path']).relative_to(H/'frozen')):x for x in hm['frozen_files']}
hchanges=[]
for rel,x in new_hmap.items():
    op=hp/'frozen'/rel
    assert op.is_file(),rel
    if rel in old_hmap: check(old_hmap[rel])
    if sha(op)!=x['sha256']:hchanges.append(rel)
assert hchanges==['hls/operators/layernorm_compute.cpp']
old_src=(hp/'frozen/hls/operators/layernorm_compute.cpp').read_text()
new_src=(H/'frozen/hls/operators/layernorm_compute.cpp').read_text()
assert new_src.replace('#pragma HLS PIPELINE II=1\n','',1)==old_src
(D/'LQ1_source.diff').write_text('\n'.join(difflib.unified_diff(old_src.splitlines(),new_src.splitlines(),fromfile='original_frozen_LN',tofile='LQ1'))+'\n')
assert hr['status']=='PASS_SCOPED_GENERATION'
rp=Path(hr['report']['path']); report=rp.read_text()
selected=[l for l in report.splitlines() if '+ laya_layernorm_producer_engine ' in l or '+ layernorm_row_arithmetic ' in l or '+ layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7 ' in l or 'o VITIS_LOOP_107_7 ' in l]
assert any('Resource Limitation' in l and '|             2|' in l and '|          2049|' in l for l in selected)
assert any('-48.76' in l for l in selected)
(D/'LQ1_HLS_selected.txt').write_text('\n'.join(selected)+'\n')
out={'schema':'controller-LQ0-readonly-review-v1','audited_at':datetime.now(timezone.utc).isoformat(),'dut_tools_run':False,
     'LQ0':{'verdict':'PASS_SCOPED','frozen_files':153,'historical_manifest_declared_files':152,'historical_undeclared_file':extra,'changed':changed,'original_tb_lines':601,'inserted_observation_lines':121,'generated_files_unchanged':83,**fixture_counts,'native_ip':7,'staged_dat_pairs':7,'markers':markers,'LN_run_envelope_cycles':649380,'Q_accept_to_consume_cycles':3267,'fullA_readback_cycles':512,'DDR_bytes':196608,'guards':intervals,'serial':True,'policy_records':len(policies)},
     'LQ1':{'frozen_files':len(new_hmap),'changed':hchanges,'source_change':'one PIPELINE II=1 pragma only','generation_status':hr['status'],'requested_II':1,'reported_II':2,'reported_loop_latency_cycles':2049,'old_reported_loop_latency_cycles':10249,'reported_slack_ns':-48.76,'physical_timing':'NOT_RUN','RTL_result':'NOT_REVIEWED','HLS_selected_rows':selected},
     'reference_count':len(verified),'verified_references':verified,
     'pre_overlay_reference_notes':['AT014 historical_tb resolves to historical _03 frozen TB; AT014 observer_installed resolves to current frozen TB.','AT015 original_source resolves to original HLS01 frozen source; candidate_installed resolves to current candidate.']}
(D/'verification.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k!='verified_references'},ensure_ascii=False,indent=2))
