"""Bounded byte/SHA/integer inspection only. No numeric evaluation or DUT import."""
from pathlib import Path
import hashlib, json, os, resource, struct, time

ROOT = Path(__file__).resolve().parents[2]
E = "project/E002_Laya_HLS/experiment/"
M = E + "vivado/module_design/"
Q = M + "q8_linear_and_restore/tm1tn8_gs32_512/"
C = E + "results/compute_throughput_optimization_20261010/attempts/"
F = E + "results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/"
D = E + "results/attention_rtl_repair_20261008/d2_cpu_full_official/"
R = "source/fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/"
A = "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT225_SM004_rev14_rope_real_rows01_progress_02/"
T = "project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/"
start = time.monotonic()
files, checks = {}, {}

def read(p, off=0, size=None):
    with (ROOT/p).open('rb') as f:
        f.seek(off); b = f.read() if size is None else f.read(size)
    if size is not None: assert len(b) == size
    return b

def ident(p, off=0, size=None):
    b=read(p,off,size)
    r=dict(path=p,bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
    if size is not None: r['offset']=off
    files[p+(f'@{off}:{size}' if size is not None else '')]=r
    return r

def check(k,v):
    checks[k]=bool(v)
    assert v,k

def diff(a,b):
    assert len(a)==len(b)
    pairs=list(zip(struct.iter_unpack('<I',a),struct.iter_unpack('<I',b)))
    ds=[i for i,(x,y) in enumerate(pairs) if x!=y]
    return dict(words=len(pairs),different_words=len(ds),first_different=ds[0] if ds else None)

sources=[Q+'rtl/laya_qkv_scratch_row_v1.sv',Q+'rtl/laya_lnq_wi_gqdown_row_v1.sv',
 Q+'rtl/tm1tn8_axi512_writer.sv',M+'hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv',
 M+'hbm_loader_and_cache/rtl/t4_aux_bias_reader_v1.sv',M+'layernorm_engine/rtl/laya_ln_row_v1.sv',
 M+'attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv',
 M+'attention_and_fp_engine/source/attention_service.h',M+'attention_and_fp_engine/source/attention_tile_service.h',
 M+'attention_and_fp_engine/tb/attention_production_fixture.py',
 E+'hls/control/full_forward_controller.cpp',E+'hls/operators/full_tasks_attention.cpp',
 E+'hls/operators/attention_full_compute.cpp',E+'hls/common/laya_memory_map.cpp',
 E+'hls/common/laya_cpu_embedding_io.cpp',E+'tests/full_reference.py',
 'results/m004_simplified_start_20261014/qkv_rope_stage_handoff_review.md']
for p in sources: ident(p)
check('current_attention_matches_AT021_sha',files[sources[6]]['sha256']=='11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16')

raw=D+'oracle/B1_from_b0_S128/embedding_raw.f32.bin'
norm=D+'oracle/B1_from_b0_S128/embedding_norm.f32.bin'
state=C+'new_raw_B1_from_b0_S128_production_02/work/state0.bin'
for p in (raw,norm,F+'manifest.json',R+'manifest.json',F+'qkv_rows4_source_f32.bin',
          F+'qkv_rows4_output_f32.bin',F+'qkv_rows4_scatter_u32x4.bin',F+'qkv_rows4_steps_u32x6.bin'):
    ident(p)
ident(state,0,524288)
check('all128_STATE0_raw_equals_independent_raw',read(state,0,524288)==read(raw))
check('norm_full128_shape',len(read(norm))==524288)
check('four_row_norm_same_parent',read(norm,0,16384)==read(F+'qkv_rows4_source_f32.bin'))
gamma=E+'build/model-current-production-v2-20261011/aux.bin'
ident(gamma,128,4096)
check('gamma_identity',ident(gamma,128,4096)['sha256']=='dfb0f4aaaedeb189d0698f68603641bf325c60b9857ecb19a5f9fe4f9df0aa2d')
reqs=[E+'build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin',
 E+'build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin']
for p in reqs: ident(p);ident(p,832,128)
check('v4_current_mask_equal',read(reqs[0],832,128)==read(reqs[1],832,128))
mask=read(reqs[1],832,128)
check('mask_binary_72',set(mask)=={0,1} and sum(mask)==72)

tf=C+'t5_attention_fixture_01/work/fixture/'
tm=json.loads(read(tf+'manifest.json'));ident(tf+'manifest.json')
for n in ('q.bin','k.bin','v.bin','score.bin','maximum.bin','shift.bin','exp.bin','sum.bin','prob.bin','out.bin','mask.mem','identity_words.mem'):
    got=ident(tf+n);rec=tm['products'][n]
    check('saved_t5_'+n,got['bytes']==rec['bytes'] and got['sha256']==rec['sha256'])
check('saved_attention_mask_same',bytes(int(x,16) for x in read(tf+'mask.mem').split())==mask)
comparisons=[]
for s in (0,1):
    final=R+f'products/row{s}_full_FINAL.f32.bin';ident(final)
    for p,n in enumerate(('q','k','v')):
        a=read(final,p*4096,256);b=read(tf+n+'.bin',s*256,256)
        ident(final,p*4096,256);ident(tf+n+'.bin',s*256,256)
        comparisons.append(dict(row=s,head=0,plane=n,current_final_vs_t5_input=diff(a,b)))
for n in ('q','k','v'):
    cap=C+f't2_av_feedback_qkv_capture_run_01/work/capture/t2_enc0_{n}_head0_source.f32.bin'
    ident(cap);check('t5_'+n+'_equals_software_capture',read(cap)==read(tf+n+'.bin'))
ident(C+'t2_av_feedback_qkv_capture_run_01/work/generated/source_manifest.json')
ident(C+'t2_av_feedback_qkv_capture_run_01/input_manifest.json')
native=D+'attention_fixture/'
for n in ('full_attention_fixture_report.json','raw_qkv.f32.bin','full_final_qkv.f32.bin',
          'full_score.f32.bin','full_probability.f32.bin','full_av.f32.bin'):
    ident(native+n)

measurements={}
for label,p in [('AT225_RTL',A+'guard_rtl/guard_result.json'),('AT225_static',A+'guard_static/guard_result.json'),
                ('AT021_full',T+'guard_full_01/guard_result.json'),('AT021_pilot',T+'guard_pilot_01/guard_result.json')]:
    ident(p);measurements[label]=json.loads(read(p))
for p in (A+'guard_rtl/driver.log',T+'full_01/numeric_result.json',T+'full_01/measurement.json',
          T+'full_01/simulate.log',T+'source_manifest.json'):
    ident(p)
for n in ('laya_qkv_scratch_row_v1.sv','laya_lnq_wi_gqdown_row_v1.sv','tm1tn8_axi512_writer.sv'):
    ident(A+'frozen/'+n)

# Enumerate logical addresses only; no tensor contents are generated.
seen=set()
for s in range(128):
    for p in range(3):
        for h in range(16):
            for beat in range(4):
                off=(((p*2*8+h//2)*1024+s)*64+beat*16)*4
                key=(h&1,off)
                assert key not in seen and off%64==0 and off+64<=12*1024*1024
                seen.add(key)
check('all128_qkv_unique_beats',len(seen)==24576)
check('all128_norm_beats',128*4096//64==8192)
record=dict(scope='Static SHA/bytes/integers only; no oracle/DUT import, model evaluation, EDA or simulation',
 files=list(files.values()),checks=checks,current_vs_saved_attention=comparisons,measurements=measurements,
 selected_request=dict(request_id=3,generation=1,B=1,S=128,mask_offset=832,mask_ones=72),
 structural_counts_not_timing=dict(raw_input_bytes=524288,gamma_bytes_per_row=4096,qkv_raw_B=24576,norm_B=8192,
 rope_B=16384,producer_rows=128,matrix_stripes=1572864,rope_heads=4096,
 attention_tiles_per_head=8,attention_heads=16,attention_KV_words_per_tile=16384,attention_Q_words_per_tile=1024,
 attention_output_bytes=524288,attention_output_B=8192),
 sampling=dict(wall_seconds=time.monotonic()-start,maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
 affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),interactive_reads_cumulative='UNKNOWN'))
Path(__file__).with_name('s128_final_attention_binding_20261015.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(files=len(files),checks=len(checks),comparisons=comparisons,sampling=record['sampling']),ensure_ascii=False))
