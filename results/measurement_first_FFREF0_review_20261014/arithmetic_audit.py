"""Read-only identity/classification audit; does not run reference math or RTL."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib,json,struct

ROOT=Path(__file__).resolve().parents[2]; OUT=Path(__file__).resolve().parent
R=ROOT/'project/E005_full_request_performance/experiment_results/runs/R001'
OLD=ROOT/'project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts'
def ident(p):
    p=Path(p);b=p.read_bytes()
    return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def j(p):return json.loads(Path(p).read_text())
paths=[OLD/'t2_tm4_generated_rtl_02/work/vivado/tm4_generated.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci',
       R/'attempts/AT049_LNQ2_runtime_01/work_static/vivado/lnq0_chain_tb_v1.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci']
ids=[ident(p) for p in paths]
assert [x['sha256'] for x in ids]==['de95586f7d41fb4832329bf22952bc8321743629543d7b353a2ae05fcc16f92c','244d6ab50960499221348b32698d57613d5934b9643188baf4b88e1c93e8f430']
diff=[]
def compare(a,b,p=''):
    if isinstance(a,dict) and isinstance(b,dict):
        assert a.keys()==b.keys()
        for k in a:compare(a[k],b[k],p+'/'+k)
    elif isinstance(a,list) and isinstance(b,list):
        assert len(a)==len(b)
        for i,(x,y) in enumerate(zip(a,b)):compare(x,y,p+'/'+str(i))
    elif a!=b:diff.append(dict(path=p,old=a,AT049=b))
compare(j(paths[0]),j(paths[1]))
assert {x['path'] for x in diff}=={'/checksum','/ip_inst/gen_directory','/ip_inst/parameters/runtime_parameters/OUTPUTDIR/0/value'}
report=j(R/'attempts/AT050_FFREF0_reference_01/output/ffn_residual_reference_report.json')
classes={}
for name,expected in [('skip',(2076,2020)),('down',(2100,1996)),('enc0_out',(2094,2002))]:
    p=Path(report['outputs'][name]['rows4']['path']);a=ident(p)
    assert all(a[k]==report['outputs'][name]['rows4'][k] for k in ('bytes','sha256'))
    c=dict(normal_positive=0,normal_negative=0,subnormal=0,zero=0,inf=0,nan=0)
    for (u,) in struct.iter_unpack('<I',p.read_bytes()):
        e=(u>>23)&255;m=u&0x7fffff
        k=('nan' if m else 'inf') if e==255 else (('subnormal' if m else 'zero') if e==0 else ('normal_negative' if u>>31 else 'normal_positive'))
        c[k]+=1
    assert (c['normal_positive'],c['normal_negative'])==expected and sum(c.values())==4096
    assert all(c[k]==0 for k in ('subnormal','zero','inf','nan'))
    classes[name]=dict(identity=a,counts=c)
o=OLD/'tanh_libm_round1_02'
leaf=o/'hls_project/solution1/syn/verilog/tanh_libm_leaf_fp_add_bits.v'
lid=ident(leaf);manifest=j(o/'rtl_manifest.json')
oldentry=next(x for x in manifest['files'] if x['path'].endswith('/tanh_libm_leaf_fp_add_bits.v'))
assert all(lid[k]==oldentry[k] for k in ('bytes','sha256'))
assert lid['sha256']=='d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474'
gold=ident(o/'cpu/add_directed.mem');gm=j(o/'directed_add_manifest.json')
assert all(gold[k]==gm['fixture'][k] for k in ('bytes','sha256')) and gm['count']==52
assert len((o/'cpu/add_directed.mem').read_text().split())==156
log=(o/'rtl_run/xsim.log').read_text();assert 'RNE_ZERO_DIRECTED_RTL_PASS count=52' in log
tb=(o/'frozen_source/tanh_libm_tb.sv').read_text()
assert 'tanh_libm_leaf_fp_add_bits directed_add' in tb and 'add_result!==add_directed[3*i+2]' in tb
source=leaf.read_text()
assert 'input   ap_start;' in source and 'output   ap_done;' in source and 'output  [31:0] ap_return;' in source
evidence=[ident(o/n) for n in ['rtl_manifest.json','directed_add_manifest.json','frozen_source/tanh_libm_tb.sv',
    'frozen_source/tanh_libm_cpu.cpp','frozen_source/tanh_libm_bits.cpp','rtl_run/xsim.log','hls_project/solution1/syn/report/fp_add_bits_csynth.rpt']]
messages=[]
for n in ['measurement-first-FFREF0-fadd-identity-answer-20261014','measurement-first-FFREF0-fadd-four-row-classification-20261014']:
    p=ROOT/'.research-agent/communications'/(n+'.json');m=j(p)
    payload={k:m[k] for k in ['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']}
    sha=hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()
    assert m['status']=='delivered' and sha==m['payload_sha256']
    assert m['from_thread_id']=='01a129af-29ef-7102-b86a-a43995a36279' and m['to_thread_id']=='01a129af-0395-7fd0-95ac-edd54873bd5f'
    assert (ROOT/m['message_file']).read_text().strip()==m['text'].strip()
    messages.append(dict(identity=ident(p),message_file=ident(ROOT/m['message_file']),payload_sha256=sha))
result=dict(at=datetime.now(timezone.utc).isoformat(),scope='Read-only files/bytes, no math/reference/DUT execution',
    xilinx_XCI=ids,only_XCI_differences=diff,AT050_four_row_classification=classes,
    selected_HLS_leaf=lid,old_directed_gold=gold,old_evidence=evidence,messages=messages,
    decision='FFR0 reuses one unchanged HLS fp_add_bits leaf; new wrapper and 4096 data pairs plus 52 directed cases require RTL verification',
    limitations='Old HLS leaf tests do not prove Xilinx IP; no general IEEE, new CE, producer/lease or physical proof; new FFR0 NOT_RUN')
(OUT/'arithmetic_route_verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(XCI_differences=len(diff),leaf_SHA=lid['sha256'],classes={k:v['counts'] for k,v in classes.items()},messages=len(messages)),ensure_ascii=False))
