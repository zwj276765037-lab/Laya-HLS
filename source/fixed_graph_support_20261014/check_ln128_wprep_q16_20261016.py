"""Only frozen-source identities, saved bytes and integer address checks."""
from pathlib import Path
import hashlib
import json
import os
import resource
import subprocess
import time

start = time.monotonic()
root = Path(__file__).resolve().parents[2]
exp = root / 'project/E002_Laya_HLS/experiment'
at = root / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01'
support = Path(__file__).parent
manifest = json.loads((at/'source_manifest.json').read_text())
records = {Path(x['path']).name:x for x in manifest['files']}
rtl = exp/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def identity(path):
    b = path.read_bytes()
    return {'path':str(path.relative_to(root)), 'bytes':len(b), 'sha256':sha(b)}

sources = []
for name in ['laya_source_norm_service_v1.sv', 'laya_lnq_bank_service_v1.sv',
             'laya_lnq_wi_gqdown_row_v1.sv', 'laya_qkv_scratch_row_v1.sv',
             'laya_qkv_s128_request_v1.sv']:
    rec = records[name]
    frozen = identity(at/rec['path'])
    current = identity(rtl/name)
    assert frozen['sha256'] == current['sha256'] == rec['sha256'], name
    sources.append({'frozen':frozen, 'current':current})
name = 't4_dual_w_cache_v1.sv'
rec = records[name]
frozen = identity(at/rec['path'])
current = identity(exp/'vivado/module_design/hbm_loader_and_cache/rtl'/name)
assert frozen['sha256'] == current['sha256'] == rec['sha256']
sources.append({'frozen':frozen, 'current':current})

fixture = exp/'results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures'
fm = json.loads((fixture/'manifest.json').read_text())
assert fm['session'] == {'request_id':3,'generation':1,'B':1,'S':128}
case = next(x for x in fm['cases'] if x['name']=='qkv_rows4')
products = {}
for role in ['source_f32','a8_q','a8_scale','q0','q1','w_scale']:
    rec = case['products'][role]
    got = identity(fixture/Path(rec['path']).name)
    assert got['sha256'] == rec['sha256'] and got['bytes'] == rec['bytes']
    products[role] = got
normp = exp/'results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin'
norm = normp.read_bytes()
assert len(norm)==524288
assert sha(norm)=='5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056'
assert (fixture/'qkv_rows4_source_f32.bin').read_bytes()==norm[:16384]
normhex = at/'fixture/norm_s128.hex'
hexrec = next(x for x in manifest['runtime_fixture'] if Path(x['path']).name=='norm_s128.hex')
assert sha(normhex.read_bytes())==hexrec['sha256']
decoded = b''.join(int(s,16).to_bytes(4,'little') for s in normhex.read_text().split())
assert decoded==norm
q = (fixture/'qkv_rows4_a8_q.bin').read_bytes()
scale = (fixture/'qkv_rows4_a8_scale.bin').read_bytes()
rows = []
for row in range(16):
    r = {'row':row,'norm_offset':row*4096,'norm_bytes':4096,
         'norm_sha256':sha(norm[row*4096:(row+1)*4096]),
         'q_bank_words':[272*row,272*row+255],
         'scale_bank_words':[272*row+256,272*row+271],
         'q_scale_independent_gold':row<4}
    if row<4:
        r.update(q_offset=row*1024,q_bytes=1024,
                 q_sha256=sha(q[row*1024:(row+1)*1024]),
                 scale_offset=row*64,scale_bytes=64,
                 scale_sha256=sha(scale[row*64:(row+1)*64]))
    rows.append(r)

checks = {
    'AT343_full_norm_hex_equals_independent_norm': True,
    'rows4_source_equals_same_norm_rows0_3': True,
    'first_window_read_bytes':16*4096,
    'first_window_R64_beats':16*64,
    'first_window_lnq_input_words':16*1024,
    'first_window_Q_halves':16*64,
    'first_window_Q_scales':16*32,
    'first_window_bank_words':16*272,
    'first_window_export_write_edges':16*(32+16),
    'r15_norm_prep_overlap_bytes':len(set(range(15*272,16*272))&set(range(4224,5248)))*4,
    'w_payload_bytes':1572864*2+196608,
    'w_R64_beats':[1572864//64,1572864//64,196608//64],
    'w_AUX_header_R16_beats':128//16,
    'w_scale_checks':3072*32,
}
assert checks['r15_norm_prep_overlap_bytes']==512
assert checks['w_payload_bytes']==3342336
assert checks['w_scale_checks']==98304
dependencies = [identity(exp/p) for p in ['hls/memory/full_loader.cpp',
    'hls/control/full_forward_controller.cpp','include/laya_types.h']]
prior = identity(support/'embedding_qkv_binding_20261015.json')
record = {
    'task':'m004-ln128-q16-next-interface-question-20261016',
    'scope':'STATIC_ONLY; no model/oracle/gold/RTL/EDA execution',
    'frozen_manifest':identity(at/'source_manifest.json'),
    'frozen_current_sources':sources,
    'newly_read_dependencies':dependencies,
    'reused_reference_binding':prior,
    'saved_products':products,
    'full_norm':identity(normp),
    'AT343_norm_hex':identity(normhex),
    'first16_rows':rows,
    'integer_checks_not_measurements':checks,
    'open_numeric_reference':'rows4..15 have norm gold, no located independent Q/scale gold; no new evaluation',
    'script_sha256':sha(Path(__file__).read_bytes()),
    'measurement_before_write':{
        'monotonic_s':time.monotonic()-start,
        'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        'affinity':sorted(os.sched_getaffinity(0)),
        'nice':os.getpriority(os.PRIO_PROCESS,0),
        'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip(),
        'interactive_reads_cumulative':'UNKNOWN'},
    'external_measurement':'ln128_wprep_q16_static_time_20261016_02.txt',
    'initial_script_failure':{'cause':'wrong manifest key fixtures; actual key runtime_fixture',
        'time_record':'ln128_wprep_q16_static_time_20261016.txt',
        'wall_s':0.13,'maxrss_kib':31040,'exit_code':1},
}
assert record['measurement_before_write']['affinity']==[0,1,2,3]
assert record['measurement_before_write']['nice']==19
assert record['measurement_before_write']['ionice']=='idle'
out = support/'ln128_wprep_q16_20261016.json'
out.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'status':'PASS_STATIC','production_current_frozen_pairs':len(sources),'saved_products':len(products),'rows':len(rows),'Q_gold_rows':4}))
