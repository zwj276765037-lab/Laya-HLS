from pathlib import Path
from datetime import datetime, timezone
import hashlib, json

R=Path(__file__).resolve().parents[2]; D=Path(__file__).resolve().parent
B=R/'project/E005_full_request_performance/experiment_results/runs/R001'
E=B/'attempts/AT003_KB2_Down_two64/evidence'
def get(p): return json.loads(p.read_text())
def sha(p):
    with p.open('rb') as f: return hashlib.file_digest(f,'sha256').hexdigest()
verified={}
def check(x):
    p=Path(x['path']); assert p.is_file() and sha(p)==x['sha256'],str(p)
    assert p.stat().st_size==x['bytes'],str(p)
    verified[str(p)]={'path':str(p),'sha256':x['sha256'],'bytes':x['bytes']};return p
baseline=get(B/'attempts/AT002_KB1_Down_rowpack/evidence/measurement/input_manifest.json')
base={x['baseline']['path']:x['frozen'] for x in baseline['files']}
manifests=[]; changed=[]; snapshots=[]
assert get(E/'measurement/receipt.json')['status']=='NOT_RUN'
assert get(E/'measurement_01/receipt.json')['status']=='FAIL'
for label in ['measurement_02','measurement_03']:
    p=E/label;r=get(p/'receipt.json');m=get(p/'input_manifest.json');manifests.append(m)
    assert r['status']=='COST_STOP' and len(m['files'])==26 and len(m['fixture_files'])==12
    check(r['input_manifest'])
    for x in m['files']:check(x['frozen'])
    for x in m['fixture_files']:check(x['frozen'])
    for x in r['native_ip']:check(x)
    assert [x['frozen']['sha256'] for x in m['fixture_files']]==[x['frozen']['sha256'] for x in baseline['fixture_files']]
    sm={x['baseline']['path']:x['frozen'] for x in m['files']}
    differences=[Path(k).name for k in base if base[k]['sha256']!=sm[k]['sha256']]
    assert set(differences)=={'tm4tn8_sync_ps_front_v2.sv','tm4tn8_matrix_resident_v2.sv','tm4tn8_matrix_resident_tb_v2.sv'},differences
    changed.append({'attempt':label,'vs_KB1':differences})
    for phase in ['static','pilot','full']:
        a=r['phases'][phase];body=check(a['driver_log']).read_text()
        for k in ['raw_log','measurement']:
            if k in a:check(a[k])
        if phase!='full':
            assert a['status']=='PASS' and a['guard']['child_exit_code']==0 and a['guard']['trigger'] is None
            assert all(marker in body for marker in a['marker']) and 'Fatal:' not in body
        else:
            assert a['status']=='COST_STOP' and a['guard']['child_exit_code']==-9 and a['guard']['trigger']=='semantic_stall'
            assert 'TM4_MATRIX_RESIDENT_FULL_PASS' not in body
    assert r['phases']['pilot']['guard']['elapsed_seconds']<=120
    pilot=(p/'raw_pilot.log').read_text()
    assert 'A_reads=5 W_reads=288 real_stripes=288 actual_PS_gold_checks=1024 output_final_B=NOT_RUN' in pilot
    snapshots.extend([p/'receipt.json',p/'input_manifest.json',p/'guard_full/driver.log',p/'guard_full/guard_trigger.json'])
m0={x['baseline']['path']:x['frozen'] for x in manifests[0]['files']}
m1={x['baseline']['path']:x['frozen'] for x in manifests[1]['files']}
delta=[Path(k).name for k in m0 if m0[k]['sha256']!=m1[k]['sha256']]
assert delta==['tm4tn8_matrix_resident_tb_v2.sv']
cmd=get(E/'delta_01/command.json')
assert 'measurement_03/work/' in cmd['snapshot'] and cmd['command'][cmd['command'].index('-maxdeltaid')+1]=='10000'
intervals=[];policies=0;stops=[]
for gp in E.glob('**/guard_result.json'):
    g=get(gp);plan=get(gp.parent/'guard_plan.json');pol=get(gp.parent/'policy_checks.json')
    assert plan['semantic_stall_seconds']==120 and g['minimum_mem_available_kb']>192*1024*1024
    assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
    policies+=len(pol)
    intervals.append({'path':str(gp.relative_to(R)),'start':get(gp.parent/'launch.json')['at'],'end':g['finished_at']})
    if g['trigger']=='semantic_stall':
        t=get(gp.parent/'guard_trigger.json');raw=(gp.parent/'driver.log').read_text()
        assert t['last_progress_line']=='MATRIX_PROGRESS cycle=33397 stripes=5151 ps0=5120 outputs=0'
        assert t['seconds_since_progress']>=120 and g['child_exit_code']==-9
        assert 'KB2_STALL_DIAGNOSTIC' not in raw and 'TM4_MATRIX_RESIDENT_FULL_PASS' not in raw
        stops.append({'path':str(gp.relative_to(R)),'result':g,'last_observed_progress':t['last_progress_line']})
    snapshots.extend([gp,gp.parent/'guard_plan.json',gp.parent/'policy_checks.json'])
intervals.sort(key=lambda x:x['start']);assert len(intervals)==8 and len(stops)==3
assert all(a['end']<=b['start'] for a,b in zip(intervals,intervals[1:]))
snapshots.extend([B/'reports/KB2_two64_no_go_20261013.md',R/'project/E002_Laya_HLS/experiment/hls/control/owner_ct0/source/design.md',E/'delta_01/command.json',E/'delta_01/guard/driver.log'])
records=[]
for p in snapshots:
    q=D/'snapshot'/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
    records.append({'source':str(p.relative_to(R)),'sha256':sha(q)})
result={'review':'R-SM005-KB2-STOP-20261013','at':datetime.now(timezone.utc).isoformat(),'frozen_source_checks':52,'fixture_checks':24,'unique_referenced_files':len(verified),'verified_files':list(verified.values()),'changes':changed,'between_02_03':delta,'guard_count':len(intervals),'policy_records':policies,'serial_intervals':intervals,'cost_stops':stops,'last_marker_is_not_exact_terminal_cycle':True,'PS_count_in_marker_is_row0_only':True,'root_cause':'UNKNOWN','full_numeric_and_speedup':'NOT_MEASURED','decision':'STOP_THIS_KB2_CANDIDATE_RETAIN_KB1_CT0_CONTINUES_WITHIN_EXISTING_CONTRACT','snapshots':records,'no_DUT_tools_run':True}
(D/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['frozen_source_checks','fixture_checks','unique_referenced_files','guard_count','policy_records','root_cause','full_numeric_and_speedup','decision']},ensure_ascii=False))
