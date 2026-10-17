"""Read-only AT041 provenance/payload audit; no reference or DUT execution."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re, shutil, struct

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
AT=RUN/'attempts/AT041_LNQI0_identity_preflight_01'
for name in ['mission/current.md','results/overview.md','results/hardware_metrics.md',
             'results/hardware_progress.md','results/review_queue.md','results/reviews/SM005.md',
             'project/missions/SM005.md','agent/A001/result.md','agent/A001/state.json','NEW_CHAT_START.md']:
    dest=OUT/'prior_records'/name
    dest.parent.mkdir(parents=True,exist_ok=True)
    if not dest.exists():shutil.copy2(ROOT/name,dest)
cache={};checks=[]
def identity(path):
    path=Path(path)
    if str(path) not in cache:
        h=hashlib.sha256();n=0
        with path.open('rb') as f:
            while b:=f.read(4*1024**2):h.update(b);n+=len(b)
        cache[str(path)]={'path':str(path),'bytes':n,'sha256':h.hexdigest()}
    return cache[str(path)]
def check(v,origin):
    actual=identity(v['path']);ok=all(v[k]==actual[k] for k in ['bytes','sha256'])
    checks.append(dict(origin=origin,expected=v,actual=actual,match=ok));assert ok,origin
def refs(v,origin):
    if isinstance(v,dict):
        if {'path','bytes','sha256'}<=v.keys():check(v,origin)
        else:
            for k,x in v.items():refs(x,origin+'/'+k)
    elif isinstance(v,list):
        for i,x in enumerate(v):refs(x,origin+'/'+str(i))
manifest=json.loads((AT/'input_manifest.json').read_text())
receipt=json.loads((AT/'receipt.json').read_text())
report=json.loads((AT/'result/report.json').read_text())
for name,value in [('manifest',manifest),('receipt',receipt),('report',report)]:refs(value,name)
assert len(manifest['files'])==28 and len(receipt['fixture_outputs'])==11
assert receipt['verdict']==report['status']=='PASS_HOST_ONLY'
bo={x['role']:x for x in report['package_bos']}
whole=[]
for role,x in bo.items():
    a,b=Path(x['canonical']['path']),Path(x['legacy']['path'])
    if role!='aux':
        with a.open('rb') as fa,b.open('rb') as fb:
            while chunk:=fa.read(4*1024**2):assert chunk==fb.read(len(chunk))
            assert not fb.read(1)
        whole.append(dict(role=role,bytes=a.stat().st_size,byte_equal=True))
aux=Path(bo['aux']['canonical']['path']).read_bytes()
old_aux=Path(bo['aux']['legacy']['path']).read_bytes()
assert aux[128:]==old_aux[128:] and len(aux)==len(old_aux)==1671872
aux_diff=[i for i,(a,b) in enumerate(zip(aux,old_aux)) if a!=b]
assert len(aux_diff)==32 and all(64<=x<96 for x in aux_diff)
def decode(p,width):
    lines=Path(p).read_text().splitlines();assert all(len(x)==width*2 for x in lines)
    return b''.join(int(x,16).to_bytes(width,'little') for x in lines)
gguf=next(x for x in manifest['files'] if x['path'].endswith('.gguf'))
segments=[]
for w in report['weights']:
    with Path(gguf['path']).open('rb') as f:
        f.seek(w['GGUF_offset']);raw=f.read(w['GGUF_bytes'])
    assert hashlib.sha256(raw).hexdigest()==w['GGUF_sha256']
    for v in w['physical']:
        path=Path(bo[v['bo']]['canonical']['path'])
        with path.open('rb') as f:f.seek(v['offset']);raw=f.read(v['bytes'])
        assert len(raw)==v['bytes'] and hashlib.sha256(raw).hexdigest()==v['sha256']
        assert raw==decode(v['AT035_hex']['path'],64)
        assert raw==decode(report['outputs'][w['case']+'_'+v['role']+'.hex']['path'],64)
        segments.append(dict(case=w['case'],role=v['role'],offset=v['offset'],bytes=v['bytes'],sha256=v['sha256']))
assert len(segments)==6
assert decode(report['outputs']['aux_header.hex']['path'],16)==aux[:128]
assert decode(report['outputs']['expected_aux_header.hex']['path'],128)==aux[:128]
sv=next(x for x in manifest['files'] if x['path'].endswith('laya_model_identity_13bo_generated_v1.sv'))
l13m=int(re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)",Path(sv['path']).read_text())[1],16).to_bytes(416,'little')
old=decode(next(x['path'] for x in manifest['files'] if '/wi_w/model_identity.hex' in x['path']),416)
wire=decode(report['outputs']['model_identity_q8s2_diagnostic.hex']['path'],416)
assert sum(a!=b for a,b in zip(old,l13m))==233
assert l13m[:32]==old[:32] and wire[:64]==l13m[:64]
assert int.from_bytes(l13m[64:68],'little')==0x4d33314c and wire[64:68]==bytes(4)
assert int.from_bytes(wire[72:80],'little')!=0
assert wire[256:]==old[256:]
assert hashlib.sha256(wire).hexdigest()==report['diagnostic_W_identity_sha256']
validation=json.loads((AT/'result/validation_record.json').read_text())
assert wire[96:128]==hashlib.sha256(json.dumps(validation,sort_keys=True,separators=(',',':')).encode()).digest()

guards=[]
for name,exit_code in [('guard_host',1),('guard_host_corrected',0)]:
    p=AT/name;plan=json.loads((p/'guard_plan.json').read_text());result=json.loads((p/'guard_result.json').read_text())
    policy=json.loads((p/'policy_checks.json').read_text())
    assert plan['maximum_seconds']==120 and plan['maximum_owned_rss_kb']==8*1024**2
    assert plan['minimum_mem_available_kb']==192*1024**2 and plan['semantic_stall_seconds']==120
    assert result['child_exit_code']==exit_code and result['trigger'] is None
    assert policy and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0 for x in policy)
    guards.append(dict(name=name,start=plan['at'],end=result['finished_at'],command=plan['command'],result=result,policy_samples=len(policy)))
assert datetime.fromisoformat(guards[0]['end'])<datetime.fromisoformat(guards[1]['start'])
command_diff=[(a,b) for a,b in zip(guards[0]['command'],guards[1]['command']) if a!=b]
assert len(command_diff)==1 and 'model-cpu-embedding-ln-v4' in command_diff[0][0] and 'model-q8-session-v2-actual-r2' in command_diff[0][1]
assert 'ValueError: Q8S2 source schema' in (AT/'guard_host/driver.log').read_text()
assert 'LNQI0_HOST_PASS weights=2 payload_views=6 GGUF=1 BO=5 identity_dialects=2' in (AT/'guard_host_corrected/driver.log').read_text()

# Current diagnostic addresses do not match the copied Q8S2 record table.
qar=RUN/'attempts/AT035_QAR0_shared_admission_01'
m35=json.loads((qar/'input_manifest.json').read_text())
tb=next(x['frozen'] for x in m35['files'] if x['frozen']['path'].endswith('/wigqd0_chain_tb_v1.sv'))
check(tb,'AT035/address_binding_source')
text=Path(tb['path']).read_text()
assert "wc_load_aux_base=64'h400000000" in text
assert "64'h500000000+64'(pp)*64'h10000000+config_words[3+pp]" in text
binding_gaps={'AT041_inherits_AT035_record_bases':{x['role']:hex(x['base']) for x in report['bo_bindings']},
              'AT035_actual_TB_bases':{'w_q0':'0x500000000','w_q1':'0x510000000','w_scale':'0x520000000','aux':'0x400000000'},
              'embedding_record_collides_with_AT040_STATE0':'0x300000000',
              'conclusion':'Host output is a diagnostic encoding, not a verified live binding; must rebind successor.'}
result=dict(scope='controller host evidence audit only; no new compute/RTL',at=datetime.now(timezone.utc).isoformat(),
            references=checks,reference_count=len(checks),unique_paths=len(cache),all_match=True,
            input_manifest_rows=28,fixture_outputs=11,whole_BO_byte_comparison=whole,AUX_diff_offsets=aux_diff,
            weight_segments=segments,identity_different_bytes=233,guards=guards,policy_samples=sum(x['policy_samples'] for x in guards),
            command_diff=command_diff,binding_gaps=binding_gaps,
            verdict='ACCEPT_HOST_PAYLOAD_COMPATIBILITY; diagnostic W encoding is not live-binding or RTL proof',
            limits=['No LN-to-QAR0 same-runtime result','No full ordinary Q/L, production request, physical resources/timing'])
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['reference_count','unique_paths','input_manifest_rows','fixture_outputs','policy_samples','verdict']},ensure_ascii=False))
