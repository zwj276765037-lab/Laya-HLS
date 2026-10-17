"""Bounded, read-only evidence audit; never launches EDA or follows a directory tree."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, os, re, subprocess, sys

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
EXP = ROOT / 'project/E002_Laya_HLS/experiment'
ST = EXP / 'results/compute_throughput_optimization_20261010'
OUT = ROOT / 'project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011'
LEGACY = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline'

def mapped(value):
    value = str(value)
    if value == LEGACY or value.startswith(LEGACY + '/'):
        return Path(str(EXP) + value[len(LEGACY):])
    p = Path(value)
    return p if p.is_absolute() else ROOT / p

def refs(node, trail=''):
    if isinstance(node, dict):
        if isinstance(node.get('path'), str) and isinstance(node.get('sha256'), str):
            yield trail, node
        for key, value in node.items():
            yield from refs(value, trail + '/' + key)
    elif isinstance(node, list):
        for index, value in enumerate(node):
            yield from refs(value, trail + '/' + str(index))

cache = {}
def digest(p):
    if str(p) not in cache:
        h = hashlib.sha256()
        with p.open('rb') as f:
            for block in iter(lambda: f.read(1024 * 1024), b''):
                h.update(block)
        cache[str(p)] = h.hexdigest()
    return cache[str(p)]

def check_document(p):
    d = json.loads(p.read_text())
    rows = []
    for trail, ref in refs(d):
        target = mapped(ref['path'])
        row = {'field': trail, 'original_path': ref['path'], 'mapped_path': str(target),
               'expected_sha256': ref['sha256'], 'expected_bytes': ref.get('bytes')}
        if target.is_file():
            row.update(actual_sha256=digest(target), actual_bytes=target.stat().st_size)
            row['status'] = 'MATCH' if row['actual_sha256'] == ref['sha256'] and (ref.get('bytes') is None or row['actual_bytes'] == ref['bytes']) else 'MISMATCH'
        else:
            row['status'] = 'MISSING'
        rows.append(row)
    return {'document_path': str(p.relative_to(ROOT)), 'document_sha256': digest(p),
            'references': rows, 'reference_count': len(rows),
            'match_count': sum(r['status']=='MATCH' for r in rows)}

def processes():
    own=[]; legacy=[]; uncertain=[]
    heavy=re.compile(r'(^|/)(vivado|vitis_hls|vitis-run|xsim|xelab|xvlog)( |$)|run_with_resource_guard|[a-z_]*guard\.py')
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():
            continue
        try:
            raw=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace').strip()
            if not heavy.search(raw):
                continue
            try: cwd=os.readlink(p/'cwd')
            except OSError: cwd=None
            row={'pid':int(p.name),'cmdline':raw,'cwd':cwd}
            if str(ROOT) in raw or (cwd and cwd.startswith(str(ROOT))): own.append(row)
            elif LEGACY in raw or (cwd and cwd.startswith(LEGACY)): legacy.append(row)
            elif cwd is None: uncertain.append({'pid':int(p.name),'reason':'heavy-looking command but cwd unreadable; no project ownership established'})
        except (OSError, ProcessLookupError):
            continue
    return {'checked_at':datetime.now(timezone.utc).isoformat(),'project_heavy_processes':own,
            'legacy_heavy_processes':legacy,'unattributed_unreadable_cwd':uncertain,
            'processes_managed':False,'limitation':'Point-in-time cmdline/cwd observation; no ownership inferred for unrelated processes.'}

mode = sys.argv[1] if len(sys.argv) > 1 else None
if mode in ('audit', 'supplement'):
    os.nice(19)
    affinity=sorted(os.sched_getaffinity(0) & {0,1,2,3})
    if affinity: os.sched_setaffinity(0,affinity)
    io=subprocess.run(['ionice','-c','3','-p',str(os.getpid())],capture_output=True,text=True)
    docs=[
      'attempts/t2_production_stage_close_01/receipt.json',
      'attempts/t2_production_stage_close_01/working_source_manifest.json',
      'attempts/t2_production_stage_close_01/evidence_manifest.json',
      'attempts/t5_attention_tile_v1_01/handoff/final_summary.json',
      'attempts/t5_attention_tile_v1_01/source_manifest_v10.json',
      'attempts/t2_tm4_matrix_resident_full_down_01/receipt.json',
      'attempts/t2_tm4_matrix_resident_full_down_01/input_manifest.json',
      'attempts/t2_tm4_matrix_resident_pilot_03/input_manifest.json',
      'attempts/t2_tm4_matrix_resident_pilot_02/input_manifest.json',
      'attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json',
      'attempts/t2_geglu_gate_quant_bridge_rtl_04/input_manifest.json',
      'attempts/t2_geglu_gate_quant_bridge_rtl_04/work/fixture/manifest.json',
      'attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json',
      'attempts/geglu_canonical_row_01/row_bank_v1/receipt_functional.json',
      'attempts/geglu_canonical_row_01/row_bank_v1/ooc_source_manifest.json',
      'attempts/current_production_full_vitis_csim_02/receipt.json',
    ]
    if sys.argv[1] == 'supplement':
        docs=[
          'attempts/current_production_full_cpu_01/receipt.json',
          'attempts/current_production_full_cpu_01/input_manifest.json',
          'attempts/current_production_full_vitis_csim_02/input_manifest.json',
          'attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json',
          'attempts/t5_attention_fixture_01/work/fixture/manifest.json',
          'attempts/t5_attention_tile_v1_01/head128_01/numeric_result.json',
          'attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json',
          'attempts/t5_attention_tile_v1_01/ooc_01/ooc_result.json',
          'attempts/geglu_canonical_row_01/receipt_ooc_01.json',
        ]
    result={'schema':1,'audit_type':'posthoc_evidence_identity_check_no_hardware_run',
      'project_root':str(ROOT),'started_at':datetime.now(timezone.utc).isoformat(),
      'resource_policy':{'nice':os.getpriority(os.PRIO_PROCESS,0),'cpu_affinity':sorted(os.sched_getaffinity(0)),
      'idle_io_applied':io.returncode==0},'documents':[]}
    for rel in docs:
        p=ST/rel
        if not p.is_file():
            result['documents'].append({'document_path':str(p.relative_to(ROOT)),'status':'DOCUMENT_MISSING'})
            continue
        group=check_document(p);result['documents'].append(group)
        print(json.dumps({'document':rel,'references':group['reference_count'],'match':group['match_count'],
           'exceptions':[r for r in group['references'] if r['status']!='MATCH']},ensure_ascii=False),flush=True)
    if sys.argv[1] == 'supplement':
        csim=json.loads((ST/'attempts/current_production_full_vitis_csim_02/receipt.json').read_text())
        current=[]
        for ref in csim['actual_compiled_dependencies']:
            if '/work/source_root/' not in ref['path']: continue
            rel=ref['path'].split('/work/source_root/',1)[1]
            p=EXP/rel
            row={'current_path':str(p.relative_to(ROOT)),'frozen_csim_sha256':ref['sha256']}
            if p.is_file():
                row.update(current_sha256=digest(p),bytes=p.stat().st_size,
                           unchanged=digest(p)==ref['sha256'])
            else: row['status']='MISSING'
            current.append(row)
        result['current_production_source_comparison_to_old_csim']=current
        result['current_production_source_changes']=[x for x in current if not x.get('unchanged',False)]
        print(json.dumps({'current_C_sources':len(current),'changed':result['current_production_source_changes']},ensure_ascii=False))
        marker_files=['hls/operators/full_tasks.cpp','hls/operators/full_tasks_attention.cpp','hls/platform/full_kernel_wrapper.cpp']
        result['current_production_markers']=[]
        for rel in marker_files:
            p=EXP/rel
            lines=p.read_text().splitlines()
            markers=[{'line':i+1,'text':line.strip()} for i,line in enumerate(lines)
               if re.search(r'laya_attention_service|laya_typed_q8_forward|for.*n0|laya_q8|compute_cmd|compute_rsp|hls::stream|uint8_t \*',line)]
            result['current_production_markers'].append({'path':str(p.relative_to(ROOT)),
                 'sha256':digest(p),'markers':markers})
        print(json.dumps({'source_markers':result['current_production_markers']},ensure_ascii=False))
    result['process_check']=processes()
    result['finished_at']=datetime.now(timezone.utc).isoformat()
    result['unique_hashed_files']=len(cache)
    output='identity_audit.json' if sys.argv[1]=='audit' else 'supplemental_identity_audit.json'
    (OUT/output).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'unique_hashed_files':len(cache),'process_check':result['process_check']},ensure_ascii=False))
elif mode == 'inputs':
    os.nice(19)
    os.sched_setaffinity(0,os.sched_getaffinity(0)&{0,1,2,3})
    subprocess.run(['ionice','-c','3','-p',str(os.getpid())],capture_output=True)
    package=EXP/'build/model-current-production-v2-20261011/manifest.json'
    raw=EXP/'build/current-production-requests-v2-20261011/raw_identity_manifest.json'
    request=EXP/'build/current-production-requests-v2-20261011/identity_manifest.json'
    result={'schema':1,'checked_at':datetime.now(timezone.utc).isoformat(),
        'package':check_document(package),'raw_inputs':check_document(raw),'requests':[]}
    pd=json.loads(package.read_text());rd=json.loads(request.read_text())
    result['package_tags']=pd['tags'];result['source_model']=pd['source_model']
    result['package_BO_checks']=[]
    items=pd['bo'].items() if isinstance(pd['bo'],dict) else enumerate(pd['bo'])
    for role,rec in items:
        filename=rec.get('file',rec.get('path',rec.get('filename')))
        if filename is None:
            result['package_BO_checks'].append({'role':role,'status':'NO_FILE_FIELD','record':rec})
            continue
        p=Path(filename)
        if not p.is_absolute():p=package.parent/p
        p=mapped(p);actual=digest(p)
        expected=rec.get('sha256');size=rec.get('bytes',rec.get('size'))
        result['package_BO_checks'].append({'role':role,'path':str(p.relative_to(ROOT)),
          'bytes':p.stat().st_size,'expected_bytes':size,'expected_sha256':expected,'actual_sha256':actual,
          'status':'MATCH' if actual==expected and (size is None or p.stat().st_size==size) else 'MISMATCH'})
    result['package_tensor_count']=len(pd['tensors'])
    result['package_weight_matrix_count']=len(pd['weights'])
    for rec in rd['requests']:
        for key in ['source','target']:
            p=mapped(rec[key]);expected=rec[key+'_sha256'];actual=digest(p)
            result['requests'].append({'name':rec['name'],'B':rec['B'],'S':rec['S'],
              'generation':rec['generation'],'kind':key,'path':str(p.relative_to(ROOT)),
              'expected_sha256':expected,'actual_sha256':actual,'status':'MATCH' if actual==expected else 'MISMATCH'})
    result['raw_manifest_gguf']=json.loads(raw.read_text())['gguf']
    result['declared_shape']='B1/S128;28 Encoder+2 Decision+scorer/ACT;122 Q8 matrices'
    current=(ST/'source/design.md').read_bytes()
    start=current.find('#### 8.4.11 '.encode())
    end=current.find(b'\n#',start+1)
    if start>=0:
        if end<0:end=len(current)
        expected='11506f2e2f2da70a62bf1a58219c5070cea3a171f40b3feaca5590bf775ea0b6'
        candidates=[current[:start]+current[end:],current[:start].rstrip()+b'\n'+current[end:],current[:start].rstrip()+b'\n\n'+current[end:]]
        result['attention_contract_document_drift_check']={
          'current_sha256':digest(ST/'source/design.md'),'manifest_expected_sha256':expected,
          'section_8_4_11_removed_hashes':[hashlib.sha256(x).hexdigest() for x in candidates],
          'matches_old_hash_by_removing_only_section_8_4_11':any(hashlib.sha256(x).hexdigest()==expected for x in candidates)}
    protected=['goal/goal.md','mission/current.md','mission/M002_完整Laya加速器实现.md','project/missions/SM002.md',
       'results/overview.md','results/review_queue.md','.research-agent/project.json','.research-agent/models.json',
       '.research-agent/events.json','agent/model_policy.md','source/method.md']
    result['protected_file_sha256_before_delivery']={p:digest(ROOT/p) for p in protected}
    (OUT/'input_checks.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['package','raw_inputs','protected_file_sha256_before_delivery']},ensure_ascii=False))
    for key in ['package','raw_inputs']:
        g=result[key];print(json.dumps({'group':key,'reference_count':g['reference_count'],'match_count':g['match_count'],
         'exceptions':[x for x in g['references'] if x['status']!='MATCH']},ensure_ascii=False))
elif mode == 'read':
    for arg in sys.argv[2:]:
        p=ROOT/arg
        print('\nFILE '+str(p))
        if p.suffix=='.json':
            d=json.loads(p.read_text());print(json.dumps(d,ensure_ascii=False,indent=2)[:18000])
        else:
            print(p.read_text()[:14000])
elif mode == 'core':
    os.nice(19)
    os.sched_setaffinity(0,os.sched_getaffinity(0)&{0,1,2,3})
    subprocess.run(['ionice','-c','3','-p',str(os.getpid())],capture_output=True)
    docs=['attempts/current_production_full_cpu_01/receipt.json',
          'attempts/current_production_full_vitis_csim_02/input_manifest.json',
          'attempts/t5_attention_tile_v1_01/head128_01/numeric_result.json',
          'attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json',
          'attempts/geglu_canonical_row_01/receipt_ooc_01.json']
    result={'schema':1,'checked_at':datetime.now(timezone.utc).isoformat(),'documents':[], 'raw_log_checks':[]}
    logs=['attempts/current_production_full_cpu_01/guard/driver.log',
          'attempts/current_production_full_vitis_csim_02/guard/driver.log',
          'attempts/t2_tm4_matrix_resident_full_down_01/simulate.log',
          'attempts/t2_geglu_gate_quant_bridge_rtl_04/work/vivado/gate_quant_bridge.sim/sim_1/behav/xsim/simulate.log',
          'attempts/tanh_service_real_01/guard/driver.log',
          'attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log']
    for rel in docs:
        p=ST/rel;d=json.loads(p.read_text())
        small={k:v for k,v in d.items() if k in ['schema','status','scope','terminal','guard','build','package','model','model_sha256','build_id','model_identity','numerical','protocol','metrics','resources','timing','counts','profiles','fixture']}
        result['documents'].append({'path':str(p.relative_to(ROOT)),'keys':list(d),'selected_fields':small})
        for _,ref in refs(d):
            rp=mapped(ref['path'])
            if rp.suffix=='.log' and str(rp).startswith(str(ST)):
                logs.append(str(rp.relative_to(ST)))
            if ref['sha256']=='6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18':
                print('MODEL_FILE',str(rp))
                result.setdefault('actual_model_hash_checks',[]).append({'path':str(rp),'sha256':digest(rp),'bytes':rp.stat().st_size})
    for rel in dict.fromkeys(logs):
        p=ST/rel
        if not p.is_file(): continue
        lines=p.read_text(errors='replace').splitlines()
        selected=[{'line':i+1,'text':line} for i,line in enumerate(lines)
             if re.search(r'PASS|FAIL|FATAL|ERROR|CSim done|PROFILE|NUMERIC|ordinal=|ordinal23|SEVERITY',line,re.I)]
        entry={'path':str(p.relative_to(ROOT)),'sha256':digest(p),'matching_line_count':len(selected),'selected_lines':selected[-15:]}
        result['raw_log_checks'].append(entry)
        print(json.dumps(entry,ensure_ascii=False),flush=True)
    (OUT/'core_checks.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    for d in result['documents']:
        print(json.dumps(d,ensure_ascii=False)[:4500])
