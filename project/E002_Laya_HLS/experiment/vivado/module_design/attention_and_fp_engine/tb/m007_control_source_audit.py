"""Independent source-declared census and old-RHS/order preservation audit."""
import argparse,json,hashlib,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';E=ROOT/'project/E018_m007_control_workspace_joint';BASE=E/'experiment_source/input_baseline'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def assignments(s,op):
 # Independent balanced-bracket LHS scanner. Existing RHS must remain old q.
 out=[]
 for m in re.finditer(r'\b[A-Za-z_]\w*',s):
  start=m.start();i=m.end();name=m.group();suffix=''
  if start and(s[start-1].isalnum()or s[start-1]in'_.'):continue
  while i<len(s)and s[i].isspace():i+=1
  while i<len(s)and s[i]=='[':
   beg=i;depth=1;i+=1
   while depth:
    if s[i]=='[':depth+=1
    if s[i]==']':depth-=1
    i+=1
   suffix+=s[beg:i]
   while i<len(s)and s[i].isspace():i+=1
  if s[i:i+len(op)]!=op:continue
  i+=len(op);end=s.index(';',i);out.append((name,re.sub(r'\s+','',suffix),re.sub(r'\s+','',s[i:end])))
 return out
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir()
layout=json.loads((E/'experiment_source/g_control_layout_v1.json').read_text());fields={x['name']for x in layout['fields']}
assert layout['bits']==11343 and len(fields)==41
for prev,nxt in zip(layout['fields'],layout['fields'][1:]):assert prev['msb']+1==nxt['lsb']
old=(BASE/'laya_m007_g_math_v1.sv').read_text();old=old[old.index(' always_ff @(posedge clk)begin'):]
new=(MOD/'vector_and_ffn/rtl/laya_m007_g_math_v1.sv').read_text();comb=new[new.index(' always_comb begin\n  control_d=control_q;'):new.index(' always_ff @(posedge clk)begin\n  if(pool_reset_n)')]
bo=[x for x in assignments(old,'<=')if x[0]in fields]
# Temporarily strip only the packed next LHS prefix for tuple extraction.
ac=assignments(comb.replace('control_d.',''),'=');ac=[x for x in ac if x[0]in fields]
assert bo==ac,(len(bo),len(ac),[(x,y)for x,y in zip(bo,ac)if x!=y][:2])
assert not re.search(r'control_d\.', ''.join(x[2]for x in ac))
# Every numeric NBA remains ordered and at its original data cycle.
old_payload=[x for x in assignments(old,'<=')if x[0]not in fields]
new_payload=assignments(new[new.index(' always_ff @(posedge clk)begin\n  if(pool_reset_n)'):],'<=')
assert old_payload==new_payload,(old_payload,new_payload)
for n in fields:assert not re.search(r'\b'+n+r'(?:\[[^;]+\])*\s*<=',new)
layer=(MOD/'attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv').read_text()
old_layer=(BASE/'laya_attention_layer_engine_v1.sv').read_text();old_layer=old_layer[old_layer.index(' always_ff@(posedge clk)begin'):]
new_layer=layer[layer.index(' always_ff@(posedge clk)begin'):]
old_layer_private=[x for x in assignments(old_layer,'<=')if x[0]!='qkv_coverage']
assert old_layer_private==assignments(new_layer,'<=')
engine=(MOD/'vector_and_ffn/rtl/laya_m007_g_engine_v1.sv').read_text();old_engine=(BASE/'laya_m007_g_engine_v1.sv').read_text()
assert engine[engine.index(' always_ff @(posedge clk)begin'):]==old_engine[old_engine.index(' always_ff @(posedge clk)begin'):]
assert 'qkv_coverage<='not in layer and 'qkv_coverage[' in layer
assert 'if(layer_start)coverage_next[4095:0]=0;'in layer
assert '!prepare_valid&&!done_valid'in layer and '!cmd_valid&&!out_valid'in(MOD/'vector_and_ffn/rtl/laya_m007_g_engine_v1.sv').read_text()
workspace=(MOD/'attention_and_fp_engine/rtl/laya_m007_control_workspace_v1.sv').read_text()
assert 'output logic [12287:0] state_q' in workspace and 'owner_g<=0;rearm<=0'in workspace
at133=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT133_g_ring15_exact_state_census/work/report.json';baseline=json.loads(at133.read_text());unchanged={}
for name,digest in baseline['source_sha256'].items():
 if Path(name).name not in('laya_m007_g_math_v1.sv','laya_m007_g_engine_v1.sv'):
  assert sha(ROOT/name)==digest,name;unchanged[name]=digest
paths=[MOD/'attention_and_fp_engine/rtl'/x for x in ['laya_attention_layer_engine_v1.sv','laya_m007_control_workspace_v1.sv','laya_m007_control_workspace_joint_v1.sv']]+[MOD/'vector_and_ffn/rtl'/x for x in ['laya_m007_g_math_v1.sv','laya_m007_g_engine_v1.sv']]
r={'schema':'m007-control-arena-source-audit-v1','status':'PASS','basis':'SOURCE_DECLARATIONS_AND_GENERATE_BRANCHES; elaborated scope evidence separate, no synthesis/physical claim','g_layout_bits':11343,'workspace_bits':12288,'new_owner_rearm_bits':2,'new_other_glue_FF_bits':0,'joint_bits':3746*8+13661-11343+2,'joint_bytes':4036,'remaining_to4096_bytes':60,'g_control_NBA_old_rhs_and_order_checked':len(bo),'numeric_NBA_preserved':len(old_payload),'layer_private_NBA_old_rhs_and_order_preserved':len(old_layer_private),'g_engine_private_FF_algorithm':'BYTE_IDENTICAL','baseline_AT133_sha256':sha(at133),'unchanged_baseline_sources':unchanged,'source_sha256':{str(x.relative_to(ROOT)):sha(x)for x in paths},'external_mode_private_control_shadow_FF':'NONE_BY_GENERATE_SOURCE; actual elaborated hierarchy pending'}
(a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print('CONTROL_ARENA_SOURCE_AUDIT_PASS fields=41 math_bits=11343 old_rhs_writes='+str(len(bo))+' numeric_writes='+str(len(old_payload))+' owner_bits=2 joint_bytes=4036 physical_fitOPEN')
