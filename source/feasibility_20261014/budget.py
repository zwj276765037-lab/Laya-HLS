#!/usr/bin/env python3
"""M005 host-only, declarative graph/work/traffic/scheduling budget.

No model execution, tensor loading, EDA or GPU. All rates are scoped observations
or explicit conditional parameters, never an end-to-end measurement.
Run with run_host.py. Input snapshots permit offline reproduction with --replay.
"""
import argparse, csv, hashlib, json, math, re, struct
from collections import Counter, defaultdict
from pathlib import Path

ROOT=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
BASE=ROOT/'project/E002_Laya_HLS/experiment'
RUN=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
HERE=Path(__file__).resolve().parent
P=argparse.ArgumentParser();P.add_argument('--out',default='v1');P.add_argument('--replay',type=Path)
args=P.parse_args(); OUT=HERE/args.out
assert not OUT.exists(), 'Output identities are immutable; select a new --out'
OUT.mkdir(); (OUT/'inputs').mkdir()
inputs=[]; snapshots={}
prior=json.loads((args.replay/'input_manifest.json').read_text()) if args.replay else None
def read(path):
    path=Path(path); key=str(path.relative_to(ROOT))
    if key in snapshots: return snapshots[key]
    if prior:
        item=next(x for x in prior if x['path']==key)
        blob=(args.replay/item['snapshot']).read_bytes()
        assert hashlib.sha256(blob).hexdigest()==item['sha256']
    else:
        assert path.stat().st_size<2*1024**2, f'Only bounded evidence reads: {path}'
        blob=path.read_bytes()
    sha=hashlib.sha256(blob).hexdigest(); local=f'inputs/{sha[:16]}_{path.name}'
    (OUT/local).write_bytes(blob); snapshots[key]=blob
    inputs.append({'path':key,'bytes':len(blob),'sha256':sha,'snapshot':local})
    return blob
def js(path):return json.loads(read(path))
def dump(name,data):(OUT/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def csvwrite(name,rows):
    if not rows:return
    with (OUT/name).open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
def ceil(a,b):return (a+b-1)//b

m=js(BASE/'build/model-current-production-v2-20261011/manifest.json')
ctl=read(BASE/'hls/control/full_forward_controller.cpp').decode()
ref=read(RUN/'attempts/AT038_LNREF0_reference_prefix_02/frozen/tests/full_reference.py').decode()
for token in ['layer < 28','layer < 2','row += 16','for (unsigned head = 0; head < 16','{9, 255}','{12, 255}']:
    assert token in ctl, token
read(BASE/'hls/operators/full_tasks_front.cpp');read(BASE/'hls/operators/full_tasks_tail.cpp')
read(BASE/'hls/operators/layernorm_compute.cpp');read(BASE/'hls/operators/rope_full_compute.cpp')
read(BASE/'hls/operators/decision_full_compute.cpp')
read(BASE/'config/graph_action_registry.json');read(BASE/'config/u55c_link.cfg');read(BASE/'host/laya_host.cpp')
read(BASE/'vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv')
read(BASE/'vivado/module_design/hbm_loader_and_cache/rtl/t4_w_cache_bank_v1.sv')
read(BASE/'vivado/module_design/activation_quantizer/rtl/quant_dual_a_v1.sv')
read(BASE/'vivado/module_design/activation_quantizer/rtl/quant_a_row_bank_v1.sv')
read(BASE/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_ps_front_v2.sv')
read(BASE/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_bank_v2.sv')
read(BASE/'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_resident_v2.sv')
eng=js(ROOT/'.research-agent/communications/m005-engineering-capacity-answer-20261014.json')
assert eng['status']=='delivered' and eng['in_reply_to']=='m005-research-capacity-question-20261014'
assert eng['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279'
read(BASE/'tests/full_reference.py')
old=js(BASE/'results/performance_estimate_20261008/model_weights_q8_work.json')
frame=read(BASE/'build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin')
im=js(BASE/'build/current-production-requests-v2-20261011/identity_manifest.json')
legacy=read(BASE/'build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin')
assert len(frame)==1152 and frame[:4]==b'LYRQ'
B,S,request_id,generation=struct.unpack_from('<HHQQ',frame,20)
assert (B,S,request_id,generation)==(1,128,3,1)
ent=next(x for x in im['requests'] if x['name']=='B1_from_b0_S128')
assert ent['target_sha256']==hashlib.sha256(frame).hexdigest()
payload=[]
for i in range(5):
    offset,length=struct.unpack_from('<II',frame,128+i*32+4)
    blob=frame[offset:offset+length]
    assert blob==read(RUN/f'attempts/AT038_LNREF0_reference_prefix_02/output/abi_input_{i+1}.bin')
    payload.append(blob)
for i,key in enumerate(['model','numeric','layout','build']):
    assert frame[40+i*16:56+i*16].hex()==im['tags'][key]
profile={'B':B,'S':S,'request_id':request_id,'generation':generation,
 'physical_candidate_rows':len(payload[3]),'valid_candidate_count':sum(payload[3]),
 'active_attention_tokens':sum(payload[1]),'marker_positions':list(struct.unpack('<16i',payload[2])),
 'question_type':struct.unpack('<i',payload[4])[0],'request_tags':im['tags'],'manifest_tags':m['tags'],
 'production_request_sha256':hashlib.sha256(frame).hexdigest(),
 'legacy_reference_request_sha256':hashlib.sha256(legacy).hexdigest(),
 'identity_scope':'production-v2 frame four tags match production-v2 manifest; five payloads match AT038 old-build reference input; neither proves current full RTL execution',
 'workload_scope':'audited intended complete graph; most current physical action consumers are not full-graph validated',
 'mask_compute':'dense padded S128 and all 16 candidate rows; no unproven masked-token/candidate skipping'}
assert profile['physical_candidate_rows']==16 and profile['valid_candidate_count']==2 and profile['active_attention_tokens']==72
assert all(im['tags'][k]==m['tags'][k] for k in ['model','numeric','layout','build'])
assert im['package_manifest_sha256']==hashlib.sha256(read(BASE/'build/model-current-production-v2-20261011/manifest.json')).hexdigest()

att=js(RUN/'attempts/AT021_ATN1_attention_prefetch_01/full_01/measurement.json')
att_log=read(Path(att['raw_log']['path']))
assert hashlib.sha256(att_log).hexdigest()==att['raw_log']['sha256']
lnlog=read(RUN/'attempts/AT049_LNQ2_runtime_01/guard_full/driver.log').decode()
ffrlog=read(RUN/'attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log').decode()
read(ROOT/'results/measurement_first_LNQ2_review_20261014.md')
read(RUN/'reports/FFR1_status_measurement_result_20261014.md')
read(RUN/'reports/ATN1_attention_softmax_comparison_20261013.md')
read(RUN/'reports/KB1_W_load_service_bound_20261013.md')
read(RUN/'reports/LNF0_four_row_rtl_result_20261014.md')
bound=[]
for line in lnlog.splitlines():
    if line.startswith('DOWN_MEASURE_BOUNDARIES '):
        bound.append({k:int(v) for k,v in re.findall(r'(\w+)=([0-9]+)',line)})
assert len(bound)==2
wi,down=bound
assert wi['actual_done_consume']-wi['cfg_accept']==46917
assert down['actual_done_consume']-down['cfg_accept']==16192
line=next(x for x in lnlog.splitlines() if x.startswith('WIGQD_BOUNDARIES '))
gstart=int(re.search(r'G_cfg=(\d+)',line)[1]);glast=int(re.search(r'GATE_B=\d+/(\d+)',line)[1])
qstart=int(re.search(r'quant_R=(\d+)/',line)[1]);apub=int(re.search(r'A_publish=(\d+)',line)[1])
assert '103289' in ffrlog and glast-gstart==57993
measure={'Wi_MAC_per_cycle':4*1024*5248/46917,'Down_MAC_per_cycle':4*2624*1024/16192,
 'Wi_service_cycles':46917,'Down_service_cycles':16192,
 'Wi_load_cycles':wi['W_publish_post_NBA']-wi['W_load_accept'],
 'Down_load_cycles':down['W_publish_post_NBA']-down['W_load_accept'],
 'LN_four_rows_phase_cycles':168692,'LN_marginal_row_cycles':40535,
 'quant_first_Q_accept_to_A_publish_cycles':1078,'quant_second_first_R_to_A_publish_cycles':apub-qstart,
 'G_cfg_to_last_B_cycles':glast-gstart,'G_cfg_to_final_chain_consume_cycles_DO_NOT_ADD':down['actual_done_consume']-gstart,
 'residual_four_rows_cfg_to_consume_inclusive_cycles':103289,
 'attention_QK_head_cycles':250912,'attention_SM_head_cycles':265108,'attention_AV_head_cycles':66280,
 'attention_TB_cycles_NOT_service':att['terminal']['cycles'],
 'scope':'local RTL service observations contain original backpressure; rates transferred across full graph are conditional'}
assert sum(x['wall_to_consume'] for x in att['commands'])==582300
bus=[]
for idx,label in enumerate(('Wi','Down')):
    l=next(x for j,x in enumerate([a for a in lnlog.splitlines() if a.startswith('DOWN_MEASURE_LOAD ')]) if j==idx)
    vals={k:int(v) for k,v in re.findall(r'(\w+)=([0-9]+)',l)}
    for port in ('q0','q1','scale'):
        beats=vals[port+'_R'];bus.append({'sample':'AT049','stage':label+' LOAD_W','port':port,'direction':'read',
           'AXI_beats':beats,'physical_data_bytes':beats*64,'scope':'observed 512-bit R transfers; does not count address/response/header wire bytes'})
for stage,port,direction,beats in [('LN','STATE','read',256),('LN','STATE','write',256),
 ('first Q','NORM','read',256),('Wi','FF','write',1312),('Wi reader','FF','read',1312),
 ('G','GATE','write',656),('second Q','GATE','read',656),('Down','TMP','write',256),
 ('residual','skip','read',256),('residual','Down','read',256),('residual','HIDDEN','write',256)]:
    bus.append({'sample':'AT054' if stage=='residual' else 'AT049','stage':stage,'port':port,'direction':direction,
     'AXI_beats':beats,'physical_data_bytes':beats*64,'scope':'scoped observed transfers; AT054 is a separate runtime, not an added complete-chain measurement'})
ffn_replay={'scope':'AT049 same-runtime interval decomposition, excludes terminal residual absent in this run',
 'LN_source_Q_checks_until':170043,'gap_before_Wi_load':wi['W_load_accept']-170043,
 'Wi_load':measure['Wi_load_cycles'],'gap_to_Wi_cfg':wi['cfg_accept']-wi['W_publish_post_NBA'],
 'Wi_service':measure['Wi_service_cycles'],'gap_to_G_cfg':gstart-wi['actual_done_consume'],
 'G_until_last_B':glast-gstart,'gap_G_to_Q_first_R':qstart-glast,
 'Q_first_R_until_A_publish':apub-qstart,'gap_A_publish_to_Down_load':down['W_load_accept']-apub,
 'Down_load':measure['Down_load_cycles'],'gap_Down_load_to_cfg':down['cfg_accept']-down['W_publish_post_NBA'],
 'Down_service':measure['Down_service_cycles'],'terminal_check':1}
ffn_replay['sum_cycles']=sum(v for v in ffn_replay.values() if isinstance(v,int))
assert ffn_replay['sum_cycles']==375074

weights={ (w['family'],w['layer']):w for w in m['weights'] }
old_by={w['name']:w for w in old['weights']}
for w in m['weights']:
    if w['name'] in old_by:
        for k in ('K','N','dtype','q_span','scale_span','aux_span','bias_span'):
            assert w[k]==old_by[w['name']][k]
ops=[]; matrices=[]; traffic=[]
def tr(op,port,direction,note,n,scope='logical boundary bytes; 64B packing assumed unless stated'):
    traffic.append({'op':op,'port':port,'direction':direction,'bytes':int(n),'kind':note,'scope':scope})
def op(name,kind,rows,width,cycles=0,unknown_units=0,**extra):
    d={'ordinal':len(ops),'name':name,'kind':kind,'rows':rows,'width':width,
       'calibrated_cycles':float(cycles),'unmeasured_rate_units':int(unknown_units),**extra};ops.append(d);return name
def norm(name,rows,gamma=False):
    n=op(name,'LN',rows,1024,rows*measure['LN_four_rows_phase_cycles']/4,gamma=int(gamma))
    tr(n,'STATE','read','LN source',rows*4096);tr(n,'STATE','write','LN result',rows*4096)
def lin(name,f,l,rows):
    w=weights[f,l];K,N=w['K'],w['N'];mac=rows*K*N
    # All operations share one matrix. Bias and unmeasured shapes are flagged.
    rate=measure['Down_MAC_per_cycle'] if K in (2624,4096) else measure['Wi_MAC_per_cycle']
    groups=rows*K//32
    c=ceil(rows,4); load=sum(w['q_span'])+w['scale_span']
    matrix={'name':name,'family':f,'layer':l,'M':rows,'K':K,'N':N,'MAC':mac,
      'weight_bytes_once':load,'weight_q0':w['q_span'][0],'weight_q1':w['q_span'][1],
      'weight_scale':w['scale_span'],'bias_bytes':w['bias_span'],'quant_groups':groups,
      'output_elements':rows*N,'parent_rows16_calls':ceil(rows,16),'views4_calls':c,
      'service_cycles_conditional':mac/rate,'cycle_transfer':'Wi/Down local rate; other shapes/bias are unmeasured'}
    matrices.append(matrix)
    op(name+'/LOAD_W','W_LOAD',rows,K,weight=matrix)
    for row0 in range(0,rows,16):
        r=min(16,rows-row0)
        n=op(f'{name}/Q_r{row0}','QUANT',r,K,r*K/32*max(1078/128,measure['quant_second_first_R_to_A_publish_cycles']/328))
        tr(n,'STATE_FF_ATT','read','quant F32 source',r*K*4)
        tr(n,'ONCHIP_A','write','quant q+FP16scale fill',r*K+r*K//32*2,'on-chip service bytes, NOT HBM')
        # FullA owns a 16-row parent; PS holds one four-row view. The next Q
        # does not overwrite A before all four views consume it.
        for view in range(row0,row0+r,4):
            vr=min(4,row0+r-view); vg=vr*K//32
            n=op(f'{name}/M_r{view}','MATRIX',vr,N,vr*K*N/rate,MAC=vr*K*N,family=f,K=K,weight=matrix)
            tr(n,'QKV_FF_STATE','write','matrix F32 output',ceil(vr*N*4,64)*64)
            tr(n,'ONCHIP_A','read','q+FP16scale once per view/group, broadcast TN tiles',vr*K+vg*2,'on-chip service bytes, NOT HBM')
            tr(n,'ONCHIP_W','read','W q/scale read once per four-row view, reused across its rows',load,'on-chip bytes, NOT additional HBM LOAD_W')
            tr(n,'ONCHIP_PS','read_write','FP32 RMW per dot-group',vr*N*(K//32)*8,'logical internal RMW volume; not external traffic; first group may avoid read')
def attention(name,layer,encoder):
    if encoder:
        n=op(name+'/RoPE','OTHER',128,2048,unknown_units=128*2048)
        tr(n,'QKV','read_write','RoPE Q,K in-place read+write',128*2048*8)
    n=op(name,'ATTENTION',128,1024,16*sum(x['wall_to_consume'] for x in att['commands']),heads=16)
    tr(n,'QKV','read','Q,K,V one resident load per head',3*128*1024*4)
    tr(n,'ATT_OUT','write','Attention output',128*1024*4)
def residual(name):
    n=op(name,'RESIDUAL',128,1024,128/4*103289)
    tr(n,'STATE','read','skip and TMP',128*1024*8);tr(n,'STATE','write','next hidden',128*1024*4)

norm('embedding_LN',128,True)
for l in range(28):
    p=f'enc{l:02d}'
    if l:norm(p+'/LN_ATTN',128)
    lin(p+'/QKV',1,l,128);attention(p+'/ATT',l,True);lin(p+'/WO',2,l,128);residual(p+'/RES_ATTN')
    norm(p+'/LN_FFN',128);lin(p+'/Wi',3,l,128)
    n=op(p+'/G','G',128,2624,128/4*measure['G_cfg_to_last_B_cycles'])
    tr(n,'FF','read','Wi spill reread',128*5248*4);tr(n,'FF','write','GATE spill',128*2624*4)
    lin(p+'/Down',4,l,128);residual(p+'/RES_FFN')
norm('final_LN',128,True)
n=op('type_embedding_add','OTHER',128,1024,unknown_units=128*1024+3*1024)
tr(n,'EMBEDDING','read','3 type embedding rows Q8_0',3*1088)
tr(n,'STATE','read_write','type add hidden',128*1024*8)
for l in range(2):
    p=f'dec{l}'
    norm(p+'/LN_ATTN',128);lin(p+'/QKV',5,l,128);attention(p+'/ATT',l,False)
    lin(p+'/WO',6,l,128);residual(p+'/RES_ATTN');norm(p+'/LN_FFN',128);lin(p+'/FC1',7,l,128)
    n=op(p+'/RELU','OTHER',128,4096,unknown_units=128*4096)
    tr(n,'FF','read_write','decision ReLU',128*4096*8)
    lin(p+'/FC2',8,l,128);residual(p+'/RES_FFN')
n=op('gather','OTHER',16,1024,unknown_units=16*1024)
tr(n,'STATE','read_write','gather 16 physical candidates including masked',16*1024*8)
norm('marker_LN',16);lin('scorer_FC1',9,255,16)
n=op('scorer_bias_GELU','G',16,1024,16*1024*measure['G_cfg_to_last_B_cycles']/(4*2624))
tr(n,'STATE','read_write','scorer bias/GELU',16*1024*8)
n=op('scorer_FC2','FP_TAIL',16,1024,unknown_units=16*1024)
tr(n,'STATE','read','scorer input',16*1024*4);tr(n,'STATE','write','scorer result',64)
n=op('candidate_mask_softmax_stats','OTHER',1,16,unknown_units=16*8)
tr(n,'STATE','read_write','candidate masked/prob/stat stages',16*4*6)
n=op('act_concat','OTHER',1,1028,unknown_units=1028)
tr(n,'STATE','read_write','CLS+stats input and ACT write',2*1028*4)
n=op('act_FC1','FP_TAIL',1,256,unknown_units=1028*256)
tr(n,'STATE','read_write','ACT FC1 activation IO',(1028+256)*4)
n=op('act_bias_GELU','G',1,256,256*measure['G_cfg_to_last_B_cycles']/(4*2624))
tr(n,'STATE','read_write','ACT GELU',256*8)
lin('act_FC2',12,255,1)
tr('all','AUX','read','non-Q8 matrices,bias,LN gamma and RoPE tables at most manifest AUX package',m['bo']['aux']['size'],'conditional once per request aggregate; may duplicate negligible per-stage metadata, not measured')

assert len(matrices)==122
tot=Counter()
for x in matrices:
    for k in ('MAC','weight_bytes_once','quant_groups','output_elements','parent_rows16_calls','views4_calls'):tot[k]+=x[k]
assert tot['MAC']==47160754688 and tot['weight_bytes_once']==392448128
assert tot['quant_groups']==695816 and tot['parent_rows16_calls']==962
ln_rows=sum(x['rows'] for x in ops if x['kind']=='LN')
assert ln_rows==61*128+16
work={'Q8_INT8_MAC':tot['MAC'],'Q8_FP_restore_dot_groups':tot['MAC']//32,
 'Q8_restore_FP_mul':2*(tot['MAC']//32),'Q8_restore_FP_add':tot['MAC']//32,
 'Q8_quant_groups32':tot['quant_groups'],'Q8_quant_elements':tot['quant_groups']*32,
 'Q8_output_F32':tot['output_elements'],'Attention_QK_FP_MAC':30*16*128*128*64,
 'Attention_AV_FP_MAC':30*16*128*128*64,'Attention_softmax_scores_EXP_DIV':30*16*128*128,
 'Attention_softmax_rows':30*16*128,'LN_rows_D1024':ln_rows,'LN_elements':ln_rows*1024,
 'LN_FP_add_sub':ln_rows*(2*1023+2*1024+1),'LN_FP_mul':ln_rows*2048+2*128*1024,
 'LN_sqrt':ln_rows,'LN_div_constant_or_reciprocal':ln_rows*3,
 'encoder_GEGLU_outputs':28*128*2624,'residual_adds':60*128*1024,
 'RoPE_rotated_values':28*2*128*1024,'RoPE_FP_mul':28*2*128*1024*2,'RoPE_FP_add_sub':28*2*128*1024,
 'decision_RELU':2*128*4096,'scorer_GELU':16*1024,'ACT_GELU':256,
 'FP_scorer_MAC':16*1024,'FP_ACT_MAC':1028*256,
 'type_embedding_dequant_values':3*1024,'type_add_elements':128*1024,
 'candidate_mask_softmax_length':16,'candidate_valid_options':profile['valid_candidate_count'],
 'candidate_softmax_EXP':16,'candidate_statistics_logf':17,'candidate_statistics_div':18,
 'candidate_statistics_mul':32,'candidate_statistics_tree_add':15,
 'candidate_top1_top2_serial_reduce_steps':30,
 'ACT_concat_width':1028}
bytes_external=sum(t['bytes'] for t in traffic if not t['port'].startswith('ONCHIP'))
bytes_internal=sum(t['bytes'] for t in traffic if t['port'].startswith('ONCHIP'))
cycles_by=Counter();units=Counter()
for x in ops:cycles_by[x['kind']]+=x['calibrated_cycles'];units[x['kind']]+=x['unmeasured_rate_units']

# Traffic cannot be equated to LOAD_W. Weight reload is separately derived per
# matrix from declared physical row reuse. One request does not keep all 392 MB.
traffic_cases=[]
for row_reuse in (128,16,4):
    q0=q1=sc=bias=0
    for x in matrices:
        reloads=ceil(x['M'],row_reuse)
        q0+=x['weight_q0']*reloads;q1+=x['weight_q1']*reloads
        sc+=x['weight_scale']*reloads;bias+=ceil(x['bias_bytes'],64)*64*reloads
    traffic_cases.append({'row_reuse':row_reuse,'q0':q0,'q1':q1,'scale':sc,'bias':bias,
      'weight_total':q0+q1+sc+bias,'other_external_modeled':bytes_external,
      'external_total':q0+q1+sc+bias+bytes_external,
      'PS_spill_extra_if_external':tot['MAC']//32*8,
      'scope':'conditional payload/64B packing budget, not measured bus totals; score/prob on chip'})
traffic_alternatives={
 'Attention_score_and_probability_spill_if_needed_bytes':30*16*128*128*4*4,
 'Attention_KV_reload_per_query_tile_instead_of_head_extra_bytes':30*16*2*128*64*4*(128//16-1),
 'PS_every_group_external_RMW_bytes_NOT_current_resident_design':tot['MAC']//32*8,
 'scope':'additive counterfactual traffic sensitivities; none is claimed as current measured traffic; no spill automatically assumed free'}

scenarios=[]
by_op_bytes=Counter()
port_totals=Counter()
for t in traffic:
    if not t['port'].startswith('ONCHIP'):
        by_op_bytes[t['op']]+=t['bytes'];port_totals[t['port']]+=t['bytes']
def weight_time(x,reuse,hz,bps):
    reloads=ceil(x['M'],reuse)
    total=x['weight_bytes_once']+ceil(x['bias_bytes'],64)*64
    wi_bytes=sum(weights[3,0]['q_span'])+weights[3,0]['scale_span']
    profile_rate=wi_bytes/measure['Wi_load_cycles']
    return reloads*max(total/bps,x['weight_q0']/(64*hz),x['weight_q1']/(64*hz),
                       x['weight_scale']/(64*hz),total/(profile_rate*hz))
def service_time(x,reuse,hz,bps,aux_cpp):
    if x['kind']=='W_LOAD':return weight_time(x['weight'],reuse,hz,bps)
    calibrated=(x['calibrated_cycles']+x['unmeasured_rate_units']*aux_cpp)/hz
    # One conservative memory-service group per op, bounded by a 512b port
    # and aggregate BW. The measured service already contains its original IO.
    return max(calibrated,by_op_bytes[x['name']]/min(bps,64*hz))
fixed_upload=sum(x['size'] for x in m['bo'].values())
# Actual generic host source uploads all workspace on invocation. The desired
# persistent CPU-embedding host should only upload active raw embeddings/ABI.
workspace_upload=(32+32+16+16+48+24+16)*1024**2
host_cases={'model_once_bytes':fixed_upload,'generic_host_workspace_init_bytes':workspace_upload,
 'generic_host_IO_upload_bytes':32768,'desired_persistent_request_raw_embedding_plus_ABI':128*1024*4+1152,
 'D2H_result_bytes':384,'host_CPU_embedding_validation_XRT_launch_seconds':'UNKNOWN',
 'scope':'generic host source behavior versus desired persistent deployment; no matched board timings'}
for mhz in (100,150,200):
    hz=mhz*1e6
    for bw in (2,10,25,50):
        for tc in traffic_cases:
            # At most one 64B/clock transaction per modeled memory port. q0/q1
            # may transfer independently but total traffic also shares the BW cap.
            bps=bw*1e9
            wt=sum(weight_time(x,tc['row_reuse'],hz,bps) for x in matrices)
            known=sum(cycles_by.values())/hz
            # For read/write operators the reference cycles already include the
            # TB transport. max only adds a per-resource capacity necessity,
            # not a claim that all DAG stages can pipeline at their largest stage.
            traffic_floor=tc['external_total']/bps
            local_total=known+wt
            for aux_cpp in (1,8,32):
                aux=sum(units.values())*aux_cpp/hz
                serial=sum(service_time(x,tc['row_reuse'],hz,bps,aux_cpp) for x in ops)
                serial+=by_op_bytes['all']/min(bps,64*hz)
                # This is only an additive pessimistic stress scenario. Reference
                # service intervals contain memory already, so NOT a bound or fit.
                stress=local_total+aux+bytes_external/min(bps,64*hz)
                largest=max(max(cycles_by.values())/hz,wt,traffic_floor,aux)
                scenarios.append({'MHz':mhz,'effective_aggregate_GBps':bw,'row_reuse':tc['row_reuse'],
                 'unknown_aux_cycles_per_unit':aux_cpp,'known_service_seconds':known,'weight_load_seconds':wt,
                 'unknown_aux_seconds_assumed':aux,'serial_warm_device_seconds_conditional':serial,
                 'serial_II_seconds_conditional':serial,'serial_QPS_conditional':1/serial,
                 'serial_two_request_total_seconds':2*serial,'single_context_fill_drain_seconds':serial,
                 'cold_extra_at_assumed_PCIe_8GBps_seconds':(fixed_upload+workspace_upload+32768)/8e9,
                 'cold_device_plus_transfer_seconds_conditional':serial+(fixed_upload+workspace_upload+32768)/8e9,
                 'additive_memory_stress_seconds_NOT_bound':stress,
                 'multi_context_resource_demand_II_lower_seconds_NOT_attainable_claim':largest,
                 'end_to_end_measured_seconds':None})

# Explicit attainable-within-model overlap is only the local arithmetic/PS/
# writer overlap already included in service observations. No inter-request
# overlap is granted to a one-request-slot controller. Amdahl sensitivity uses
# the same serialized resource schedule and no duplicated matrix.
center=next(x for x in scenarios if (x['MHz'],x['effective_aggregate_GBps'],x['row_reuse'],x['unknown_aux_cycles_per_unit'])==(150,10,128,8))
timeline=[];clock=0.0
for x in ops:
    dt=service_time(x,128,150e6,10e9,8)
    timeline.append({'ordinal':x['ordinal'],'name':x['name'],'resource':x['kind'],
      'start_seconds':clock,'finish_seconds':clock+dt,'seconds':dt,
      'depends_on':x['ordinal']-1 if x['ordinal'] else '',
      'scope':'serial single request, conditional rates; not measured trace'})
    clock+=dt
assert abs(clock+by_op_bytes['all']/9.6e9-center['serial_warm_device_seconds_conditional'])<1e-8
sens=[]
for kind in ('LN','ATTENTION','RESIDUAL','MATRIX','G'):
    oldsec=cycles_by[kind]/150e6
    for gain in (2,4,10):
        new=center['serial_warm_device_seconds_conditional']-oldsec+oldsec/gain
        sens.append({'changed_service':kind,'assumed_service_speedup':gain,'saved_seconds':oldsec*(1-1/gain),
                     'conditional_serial_seconds':new,'whole_request_speedup':center['serial_warm_device_seconds_conditional']/new,
                     'resource_cost':'UNKNOWN; not authorized implementation; preserve numerical order'})
targets=[]
for seconds in (0.05,0.1,0.5,1.0):
    targets.append({'illustrative_latency_or_II_seconds_NOT_requirement':seconds,
      'Q8_MAC_per_cycle_required_150MHz':tot['MAC']/(150e6*seconds),
      'attention_cycles_per_head_required_single_service':150e6*seconds/(30*16),
      'LN_cycles_per_row_required_single_service':150e6*seconds/ln_rows,
      'residual_cycles_per_element_required_single_service':150e6*seconds/work['residual_adds'],
      'weight_only_GBps_required_reuse128':tot['weight_bytes_once']/seconds/1e9,
      'frequency_MHz_if_all_calibrated_services_unchanged_and_serial':
         (sum(cycles_by.values())+sum(units.values())*8)/(seconds*1e6),
      'scope':'each is a necessary condition with entire target assigned to that service; not jointly sufficient'})
capacity={'W_slots':2,'W_banks_total':32,'W_bank_Q_bytes':10496*32,'W_bank_scale_bytes':10496*2,
 'W_total_payload_bytes':32*10496*34,'W_bias_allocated_bytes':32*328*4,
 'W_single_slot_payload_bytes':16*10496*34,
 'largest_matrix_weight_payload_bytes':max(x['weight_bytes_once'] for x in matrices),
 'all_model_weight_resident_onchip':'NOT_ASSUMED; 392MB greatly exceeds two 5.71MB slots',
 'fullA_payload_bytes':2*16*128*34,'PS_F32_payload_bytes':4*8*656*4,'PS_metadata_bytes':4*656*2,
 'fullA_capacity':'two 16-row slots, PS four-row view; actual mapped resource count UNKNOWN',
 'other_onchip_resource_mapping':'UNKNOWN pending A002 joint synthesis',
 'cross_request_slots':1,'overlap_claim':'only observed local intra-unit overlap; other prefetch/requests need scheduling and capacity proof'}
result={'schema':'M005_independent_budget_v2','status':'CONDITIONAL_NOT_END_TO_END_MEASURED',
 'profile':profile,'model_source_identity_declared_not_rehashed':m['source_model'],
 'matrix_totals':dict(tot),'workload':work,'measured_anchors':measure,'AT049_interval_replay':ffn_replay,
 'service_cycles_conditional_by_shared_resource':dict(cycles_by),'unknown_units_by_kind':dict(units),
 'external_nonweight_modeled_bytes':bytes_external,'onchip_logical_service_bytes':bytes_internal,
 'external_port_group_bytes_excluding_weights':dict(port_totals),
 'traffic_alternatives':traffic_alternatives,
 'capacity':capacity,'host_transfer_cases':host_cases,'central_scenario':center,
 'limitations':['Current physical full graph unvalidated; graph counts are intended workload, not executed trace.',
 'LN gamma/marker, most Q8 shapes+bias, layers/inputs and unknown aux rates not measured under one complete runtime.',
 'Attention one normal head may not bound all EXP/mask inputs. RoPE/tail/control actual service UNKNOWN.',
 'Per-stage memory already occurs inside calibrated observations; additional-memory stress deliberately pessimistic, not an upper bound.',
 'No CPU embedding/init/validation/XRT overhead measurement or matched CPU/GPU baseline. End-to-end time UNKNOWN.',
 'No actual routed clock, current joint resource fit, platform HBM throughput or board data yet.',
 'No claim that resource-demand max is realizable pipeline throughput; one current request slot implies serial completion.']}
dump('budget.json',result);dump('traffic_scenarios.json',traffic_cases);dump('sensitivity.json',sens);dump('thresholds.json',targets)
read(HERE/'budget.py');read(HERE/'run_host.py')
dump('operations.json',ops);dump('input_manifest.json',inputs);dump('ffn_replay.json',ffn_replay)
csvwrite('observed_bus_transfers.csv',bus)
csvwrite('matrices.csv',matrices);csvwrite('traffic.csv',traffic);csvwrite('scenarios.csv',scenarios);csvwrite('sensitivity.csv',sens);csvwrite('thresholds.csv',targets)
csvwrite('serial_timeline_150MHz_10GBps_reuse128_aux8.csv',timeline)
flat=[{'ordinal':x['ordinal'],'name':x['name'],'kind':x['kind'],'rows':x['rows'],'width':x['width'],
       'calibrated_cycles':x['calibrated_cycles'],'unmeasured_rate_units':x['unmeasured_rate_units']} for x in ops]
csvwrite('operations.csv',flat)
print(json.dumps({'profile':profile,'totals':dict(tot),'cycles':dict(cycles_by),'central':center,'traffic':traffic_cases,
                  'inputs':len(inputs),'replay_cycles':ffn_replay['sum_cycles']},ensure_ascii=False,indent=2))
