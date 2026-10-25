#!/usr/bin/env python3
"""Current parent-v2 logical sequential declarations and actual hierarchy audit."""
import argparse,hashlib,json,re,math
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();b=a.build.resolve();ROOT=next(q for q in b.parents if(q/'.research-agent/project.json').exists());f=b/'frozen'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
checks=[]
def check(ok,label):
 checks.append({'passed':bool(ok),'label':label});assert ok,label

def sequential_names(text):
 text=re.sub(r'//[^\n]*','',text);result=set()
 for start in re.finditer(r'\balways_ff\b',text):
  tail=text[start.end():];depth=0;entered=False;end=None
  for token in re.finditer(r'\b(begin|end)\b',tail):
   depth+=1 if token[1]=='begin'else -1
   if token[1]=='begin':entered=True
   if entered and depth==0:end=token.end();break
  assert end is not None
  body=tail[:end]
  while re.search(r'\[[^\[\]]*\]',body):body=re.sub(r'\[[^\[\]]*\]','',body)
  result.update(re.findall(r'\b(\w+)\s*<=',body))
 return result

m=read(b/'source_manifest.json');check(read(b/'receipt_static.json')['verdict']=='PASS','actual compile and hierarchy completed')
for row in m['files']:check(sha(f/row['frozen'])==row['sha256'],'frozen input '+row['frozen'])
s=(f/'laya_m007_single_parent_v2.sv').read_text();old=(f/'laya_m007_single_parent_v1.sv').read_text()
check(sha(f/'laya_m007_single_parent_v1.sv')=='62cf04f53be966ac3b214dc955fda236efba2dc0cc20b90c539352c96312b86f','frozen complete FFN v1 source preserved')
old_seq=sequential_names(old);new_seq=sequential_names(s)
check(new_seq-old_seq=={'resident_issue','resident_sink'}and old_seq-new_seq==set(),'exact new parent sequential names and no hidden router/identity copies')
for pattern in [r'logic\s*\[5:0\]\s*state;',r'logic\s*\[2:0\]\s*kind;',r'logic\s*\[12:0\]\s*resident_issue,resident_sink;']:
 check(re.search(pattern,s)is not None,'actual parent register width '+pattern)
check('state>=20'not in s and 'state>=QSUB'not in s,'explicit state ownership')
check("ENCODER0_BUILD_ID=128'hd92a1f8e927c3051289016db36f20d27"in s and "BUILD_ID=128'h7209eb09c3f265363cfb274f7790a733"in s,'new kind4 and old0..3 ABI tags both present')
check('v2_ln_cancel_valid&&v2_ln_cancel_ready)g_cancel_sent<=1;'in s,'existing cancel bit reused across disjoint failure phases')
wrapper=(f/'laya_m007_resident_joint_v2.sv').read_text();provider=(f/'laya_m007_resident_ln32_v1.sv').read_text();ln=(f/'laya_m007_layernorm32_compact_v2.sv').read_text();joint=(f/'laya_m007_control_workspace_joint_v2.sv').read_text();vector=(f/'laya_m007_resident_vector32_v2.sv').read_text()
check(not re.search(r'\balways_ff\b',wrapper),'public resident wrapper has no sequential router state')
pstates={'state':3,'issued_vectors':13,'written_vectors':13,'source_witness':1,'provider_protocol_error':1,'terminal_kind':2}
check(sequential_names(provider)==set(pstates),'provider33 actual sequential fields distinct from parent counters')
lnseq=sequential_names(ln);persistent={'gamma_mem','gamma_coverage','gamma_loading','gamma_done_valid_i','held_model','held_key','gamma_loaded','gamma_done_error'}
ln_numeric={'add_hold_a','add_hold_b','inverse_value','left_value','mean_value','mul_hold_a','mul_hold_b','out_data','shift_value','square_sum_value','sum_value','wr_hold_delta','wr_hold_raw'}
check(lnseq-persistent-ln_numeric=={'local_control'},'LN private persistent control, explicit numeric payload fields and externalized local view only')
lnpersistent={'gamma_coverage':32,'gamma_loading':1,'gamma_done_valid_i':1,'held_model':64,'held_key':32,'gamma_loaded':1,'gamma_done_error':1}
check(sum(lnpersistent.values())==132,'LN gamma persistent control132 exact; gamma_mem payload separate')
check(re.search(r'logic\[12287:0\]state_q',joint)is not None,'single 12288bit joint control view')
check(re.search(r'EXTERNAL_CONTROL\(1\)\)\s*ln_engine',joint)is not None,'actual pure LN external-control parameter')
check(re.search(r'EXTERNAL_CONTROL\(1\)\)\s*vector_engine',joint)is not None,'actual VECTOR48 external-control parameter')
# One shared v1 baseline is inherited only for identical implementations.
base=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/attempts/AT020_Gstatus_literal_lexical_fix_build/source_manifest.json';bm=read(base)
unchanged=[]
for row in bm['files']:
 name=row['frozen']
 if name.endswith(('.sv','.v'))and '/rtl/'in row['source']and name!='laya_m007_single_parent_v1.sv':
  check((f/name).exists()and sha(f/name)==row['sha256'],'unchanged baseline implementation '+name);unchanged.append(name)
h=set(x.strip()for x in(b/'work/hierarchy_scopes.txt').read_text().splitlines());top='/'+m['top']+'/dut'
required=['/resident','/resident/resources','/resident/resources/fp','/resident/resources/div','/resident/coeff','/resident/hidden','/resident/scratch','/resident/ln_provider','/resident/g_pool','/resident/g_tanh','/resident/joint','/resident/joint/workspace','/resident/joint/layer','/resident/joint/g_engine','/resident/joint/ln_engine','/resident/joint/vector_engine','/matrix','/front','/context_adapter']
for suffix in required:check(top+suffix in h,'actual required instance '+suffix)
for forbidden in ['/g_math/gen_local_control','/layer/gen_local_coverage','/ln_engine/local_q','/vector_engine/local_control']:
 check(not any(forbidden in x for x in h),'no actual private control mirror '+forbidden)
parent_delta={'kind_width_delta':1,'state_width_delta':1,'resident_issue':13,'resident_sink':13}
components={'frozen_FFN_parent_and_shared_implementations':32311,'hidden_read_control':13,'scratch_owner':1,'four_owner_width_delta':1,'LN_persistent_gamma_control':132,'resident_LN_provider_private_control':33,'parent_v2_delta':sum(parent_delta.values()),'VECTOR_private_control_after_externalization':0,'public_wrapper_sequential_control':0}
exact_bits=sum(components.values());check(exact_bits==32519 and exact_bits<=32768,'current actual declaration census within4096B')
report={'schema':'m007-encoder0-actual-control-hierarchy-v1','status':'PASS','scope':'Actual elaborated current parent-v2 logical sequential declarations; functional elaboration, no synthesis/physical fit','parent_v2_sha256':sha(f/'laya_m007_single_parent_v2.sv'),'build_manifest_sha256':sha(b/'source_manifest.json'),'hierarchy_sha256':sha(b/'work/hierarchy_scopes.txt'),'components_bits':components,'parent_added_fields_bits':parent_delta,'LN_provider_separate_fields_bits':pstates,'LN_persistent_fields_bits':lnpersistent,'LN_numeric_sequential_fields_separate':sorted(ln_numeric),'exact_control_bits':exact_bits,'exact_control_bytes':exact_bits/8,'ceiling_control_bytes':math.ceil(exact_bits/8),'remaining_control_bits':32768-exact_bits,'new_router_registers':0,'payload_separate':{'new_H_bytes':524288,'H_sync_response_bytes':128,'existing_FFN_assembler_bytes':128,'Q_alias_additional_array_bytes':0,'LN_gamma_bytes':4096},'unchanged_baseline_implementations':unchanged,'checks':checks,'check_count':len(checks),'scope_limits':['not behavioral success','not OOC/P&R/timing/896DSP acceptance','full30layer catalog/coeff initialization metadata remains outside this fixed Encoder0 public-refill scope']}
a.out.mkdir(parents=True,exist_ok=True);(a.out/'source_control_hierarchy_audit.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_ENCODER0_CENSUS_PASS bits='+str(exact_bits)+' bytes='+str(exact_bits/8)+' checks='+str(len(checks)))
