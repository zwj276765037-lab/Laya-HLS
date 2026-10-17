"""Read-only provenance audit; does not execute reference or DUT."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, math, shutil, struct

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
NEW=RUN/'attempts/AT038_LNREF0_reference_prefix_02'
OLD=RUN/'attempts/AT037_LNREF0_reference_prefix_01'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md','results/hardware_progress.md',
             'results/review_queue.md','results/reviews/SM005.md','project/missions/SM005.md',
             'agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']:
    p=OUT/'prior_records'/name;p.parent.mkdir(parents=True,exist_ok=True)
    if not p.exists():shutil.copy2(ROOT/name,p)
cache={};checks=[]
def identity(p):
    p=Path(p)
    if str(p) not in cache:
        h=hashlib.sha256();size=0
        with p.open('rb') as f:
            while b:=f.read(4*1024**2):h.update(b);size+=len(b)
        cache[str(p)]={'path':str(p),'bytes':size,'sha256':h.hexdigest()}
    return cache[str(p)]
def check(v,origin):
    a=identity(v['path']);ok=all(a[k]==v[k] for k in ['bytes','sha256'])
    checks.append({'origin':origin,'expected':v,'actual':a,'match':ok});assert ok,origin
def refs(v,origin):
    if isinstance(v,dict):
        if {'path','bytes','sha256'}<=v.keys():check(v,origin)
        else:
            for k,x in v.items():refs(x,origin+'/'+k)
    elif isinstance(v,list):
        for i,x in enumerate(v):refs(x,origin+'/'+str(i))
for p in [OLD,NEW]:
    m=json.loads((p/'input_manifest.json').read_text())
    for i,row in enumerate(m['files']):check(row['frozen'],p.name+'/frozen/'+str(i))
    refs(m['external_inputs'],p.name+'/external_inputs')
    refs(json.loads((p/'receipt.json').read_text()),p.name+'/receipt')
raw=json.loads((NEW/'output/ln_ffn_reference_report.json').read_text())
verification=json.loads((NEW/'verification.json').read_text())
refs(raw,'AT038/report');refs(verification,'AT038/engineering_check')
for path,v in raw['checked_reference_files'].items():check(dict(v,path=path),'actual_reference_input')
weights=[]
for key,v in raw['weights'].items():
    path,name=key.split('::',1)
    with Path(path).open('rb') as f:f.seek(v['absolute_file_offset']);b=f.read(v['bytes'])
    assert len(b)==v['bytes'] and hashlib.sha256(b).hexdigest()==v['sha256']
    weights.append({'name':name,'bytes':len(b),'sha256':v['sha256'],'offset':v['absolute_file_offset']})
assert len(weights)==8 and raw['status']=='PASS_EXACT_INDEPENDENT_REFERENCE'
assert raw['reference']['sha256']==raw['imported_reference']['sha256']=='fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784'
assert verification['LQ0_LN_generated']['total_files']==83
arrays={}
for kind,parts in raw['outputs'].items():
    arrays[kind]={k:Path(v['path']).read_bytes() for k,v in parts.items()}
    assert len(arrays[kind]['full128'])==524288 and arrays[kind]['full128'][:16384]==arrays[kind]['rows4']
    assert all(math.isfinite(x[0]) for x in struct.iter_unpack('<f',arrays[kind]['full128']))
assert arrays['ln_ffn']['full128']==Path(raw['observations']['old_full_capture']['path']).read_bytes()
at35=RUN/'attempts/AT035_QAR0_shared_admission_01'
assert arrays['ln_ffn']['rows4']==(at35/'frozen/inputs/wi_rows4_source_f32.bin').read_bytes()
m35=json.loads((at35/'input_manifest.json').read_text())
decoded={}
for name,nbytes,key in [('q.mem',32,'q'),('scale.mem',2,'scale')]:
    row=next(x for x in m35['files'] if '/wi_a/' in x['frozen']['path'] and Path(x['frozen']['path']).name==name)
    check(row['frozen'],'AT035/'+name)
    b=b''.join(int(x,16).to_bytes(nbytes,'little') for x in Path(row['frozen']['path']).read_text().split())
    h=hashlib.sha256(b).hexdigest();assert len(b)==raw['quantized_rows4'][key+'_bytes']
    assert h==raw['quantized_rows4'][key+'_sha256']
    decoded[name]={'bytes':len(b),'sha256':h}
frame=Path(raw['abi_request']['path']).read_bytes()
assert struct.unpack_from('<HHQQ',frame,20)==(1,128,3,1)
im=json.loads(Path(raw['abi_request_manifest']['path']).read_text())
for i,name in enumerate(['model','numeric','layout','build']):
    assert frame[40+i*16:56+i*16]==bytes.fromhex(im['tags'][name])
for i,entry in enumerate(raw['abi_inputs']):
    offset,size=struct.unpack_from('<II',frame,128+i*32+4)
    assert frame[offset:offset+size]==Path(entry['path']).read_bytes()
runner=(NEW/'frozen/tests/ln_ffn_reference_prefix.py').read_text()
assert runner.index('ref.full_forward_graph(*inputs, weight)')<runner.index('old_capture =')
assert 'captured["ln_ffn"] = original_ln(values, gamma).copy()' in runner
assert 'require(calls == 2' in runner and 'raise PrefixComplete' in runner
guards=[]
for p,n in [(OLD,'guard'),(OLD,'guard_run_02'),(NEW,'guard')]:
    g=p/n;plan=json.loads((g/'guard_plan.json').read_text());r=json.loads((g/'guard_result.json').read_text())
    assert plan['maximum_seconds']==120 and plan['maximum_owned_rss_kb']==8*1024**2
    assert plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==192*1024**2
    policy=json.loads((g/'policy_checks.json').read_text()) if (g/'policy_checks.json').exists() else []
    assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
    guards.append({'attempt':p.name,'guard':n,'start':plan['at'],'end':r['finished_at'],'result':r,
                   'policy_samples':len(policy),'policy_observed':bool(policy)})
assert [x['result']['child_exit_code'] for x in guards]==[2,1,0]
assert all(x['result']['trigger'] is None for x in guards)
assert all(datetime.fromisoformat(a['end'])<datetime.fromisoformat(b['start']) for a,b in zip(guards,guards[1:]))
result={'scope':'controller read-only source closure audit; no reference/DUT execution','at':datetime.now(timezone.utc).isoformat(),
        'references':checks,'reference_count':len(checks),'unique_paths':len(cache),'weight_segments':weights,
        'guards':guards,'guard_count':3,'policy_samples':sum(x['policy_samples'] for x in guards),
        'early_launch_policy':'AT037 first failed before sample; policy UNKNOWN, no fabricated sample',
        'full_LN_elements':131072,'rows4_LN_elements':4096,'bit_diff_count':0,'decoded_AT035_Q':decoded,
        'outputs':raw['outputs'],'LN_generated_files':83,'receipt_status':'PASS_SCOPED_LNREF0',
        'limits':['Host independent reference only','No new LN DUT/HLS/RTL','No full request/physical evidence']}
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_paths','guard_count','policy_samples','bit_diff_count','LN_generated_files','receipt_status']},ensure_ascii=False))
