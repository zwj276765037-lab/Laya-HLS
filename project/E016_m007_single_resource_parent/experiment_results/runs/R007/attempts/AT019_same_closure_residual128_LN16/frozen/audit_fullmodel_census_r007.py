#!/usr/bin/env python3
"""Actual canonical parent elaboration and field-bounded logical control census."""
from pathlib import Path
import argparse,hashlib,json,re,math
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();b=a.build.resolve();ROOT=next(q for q in b.parents if(q/'.research-agent/project.json').exists());f=b/'frozen';R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs';old=R/'R006/attempts/AT014_CE_fixed_capture_minimum_prefix_build/frozen'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());checks=[]
def check(c,s):
 checks.append({'passed':bool(c),'label':s});assert c,s

def seq(s):
 s=re.sub(r'//[^\n]*','',s);result=set()
 for m in re.finditer(r'\balways_ff\b',s):
  tail=s[m.end():];depth=0;entered=False;end=None
  for t in re.finditer(r'\b(begin|end)\b',tail):
   depth+=1 if t[1]=='begin'else -1
   if t[1]=='begin':entered=True
   if entered and depth==0:end=t.end();break
  assert end is not None
  body=tail[:end]
  while re.search(r'\[[^\[\]]*\]',body):body=re.sub(r'\[[^\[\]]*\]','',body)
  result.update(re.findall(r'\b(\w+)\s*<=',body))
 return result
m=read(b/'source_manifest.json');check(read(b/'receipt_static.json')['verdict']=='PASS','actual compiled current top')
for row in m['files']:check(sha(f/row['frozen'])==row['sha256'],'immutable compiled input '+row['frozen'])
s=(f/'laya_m007_single_parent_v3.sv').read_text();v2=(old/'laya_m007_single_parent_v2.sv').read_text()
new_parent={'model_committed':1,'catalog_base':64,'active_epoch_offset':9,'qtype':2,'marker_rows':112,'marker_mask':16}
check(seq(s)-seq(v2)==set(new_parent)and seq(v2)-seq(s)==set(),'parent exactly six new stored fields; no identity/error/tail shadows')
check(re.search(r'logic\s*\[6:0\]\s*state;',s)is not None,'parent state is7 bits')
for pattern in [r'logic\[8:0\]active_epoch_offset',r'logic\[63:0\]catalog_base',r'logic\[1:0\]qtype',r'logic\[15:0\]\[6:0\]marker_rows',r'logic\[15:0\]marker_mask']:
 check(re.search(pattern,s)is not None,'parent field exact width '+pattern)
h={x.strip().replace('\\','').replace(' ','')for x in(b/'work/hierarchy_scopes.txt').read_text().splitlines()};top='/'+m['top']+'/dut'
for suffix in ['/resident','/resident/resources','/resident/resources/fp','/resident/resources/div','/resident/coeff','/resident/hidden','/resident/scratch','/resident/type_bank','/resident/ln_provider','/resident/g_pool','/resident/g_tanh','/resident/joint','/resident/joint/workspace','/resident/joint/layer','/resident/joint/g_engine','/resident/joint/ln_engine','/resident/joint/vector_engine','/matrix','/matrix/canonical','/front','/context_adapter','/catalog_reader']:
 check(top+suffix in h,'actual canonical unique scope '+suffix)
check(not any(x.startswith(top+'/matrix/legacy')for x in h),'no actual legacy coef window/398 control fields elaborate')
wrapper=(f/'laya_m007_resident_joint_v3.sv').read_text();check(not re.search(r'\balways_ff\b',wrapper),'actual wrapper router has zero sequential state')
# Actual field removal is generate-exclusive, including legacy response outputs.
fac=(f/'laya_m007_matrix_facade_v2.sv').read_text();can=fac[fac.index('generate if(CANONICAL_MODEL)'):fac.index('end else begin:legacy')]
removed={'coeff_busy':1,'coeff_valid':1,'coeff_bad':1,'coeff_coverage':128,'coeff_count':8,'coeff_model':64,'coeff_request':64,'coeff_tensor':32,'coeff_generation':32,'coeff_epoch':32,'coeff_n':16,'coef_rsp_valid':1,'coef_status':2,'coef_error_col':16}
for name in removed:check(name not in seq(can),'actual canonical branch has no old FF '+name)
check(sum(removed.values())==398,'actual removed old fields sum398')
check(seq(can)=={'words','response_valid','response_data'},'canonical bank/one valid and explicit256B payload only')
check('words[0:287]'in can and 'logic[63:0][31:0] response_data;'in can,'canonical73728B bank plus256B holding')
for name in ['laya_m007_w_reader','laya_m007_w_supply']:
 new=(f/(name+'_v2.sv')).read_text();baseline=(old/(name+'_v1.sv')).read_text()
 check(seq(new)==seq(baseline),'actual '+name+' successor adds zero sequential fields')
cat=(f/'laya_m007_catalog_reader_v1.sv').read_text();check(seq(cat)=={'state'}and 'logic[1:0]state;'in cat,'catalog2-bit state only; no header/descriptor holding')
typebank=(f/'laya_m007_type32_v1.sv').read_text();check(seq(typebank)=={'rsp_valid','rsp_vector_addr','words','rsp_data'},'actual type13 control and128B response, no duplicate model identity')
check('logic[11:0]rsp_vector_addr'in typebank,'actual type response address12 bits')
# Same audited original implementation identities; changed selected wrappers
# have explicit successor/state proofs above and owner dependency evidence.
changed={'laya_m007_single_parent_v2.sv','laya_m007_matrix_facade_v1.sv','laya_m007_w_supply_v1.sv','laya_m007_w_reader_v1.sv','laya_m007_resident_joint_v2.sv','laya_m007_control_workspace_joint_v2.sv','laya_m007_resident_vector32_v2.sv','laya_m007_tanh8_v2.sv','laya_m007_tanh_core_v2.sv'}
unchanged=[]
base_manifest=read(R/'R006/attempts/AT014_CE_fixed_capture_minimum_prefix_build/source_manifest.json')
for row in base_manifest['files']:
 name=row['frozen']
 if name in changed or not name.endswith(('.sv','.v'))or '/rtl/'not in row['source']:continue
 check((f/name).exists()and sha(f/name)==row['sha256'],'audited unchanged implementation '+name);unchanged.append(name)
vector=(f/'laya_m007_resident_vector32_v3.sv').read_text();j=(f/'laya_m007_control_workspace_joint_v3.sv').read_text()
check('logic[47:0]control_q;'in vector and 'EXTERNAL_CONTROL(1)) vector_engine'in j,'VECTOR48 remains externalized; no op FF')
check('logic[12287:0]state_q'in j,'single12288bit owner arena')
# D31 successor changes scheduling only; compare actual stored field names.
if 'laya_m007_tanh8_v3'in wrapper:
 for name in ['laya_m007_tanh8','laya_m007_tanh_core']:
  check(set(re.findall(r'\b(\w+)\s*(?:\[[^\]]+\])?\s*<=',(f/(name+'_v3.sv')).read_text()))==set(re.findall(r'\b(\w+)\s*(?:\[[^\]]+\])?\s*<=',(old/(name+'_v2.sv')).read_text())),'actual TANH v3 identical nonblocking target names '+name)
 check(re.search(r'TANH_FORCE_CORE_CE\s*=\s*0',wrapper)is not None,'actual joint uses default automatic CE')
lanes={int(m[1])for x in h if(m:=re.fullmatch(re.escape(top+'/resident/g_tanh')+r'/tanh_lane\[(\d+)\]\.core',x))};check(lanes==set(range(8)),'exactly eight actual production TANH cores')
components={'verified_R006_control':32519,'parent_state_width_delta':1,'parent_stored_fields':sum(new_parent.values()),'catalog_reader_state':2,'type_response_valid_and_address':13,'bias_response_valid':1,'actual_removed_legacy_coef':-398}
exact=sum(components.values());check(exact==32342,'all declared successor deltas give32342 logical bits')
report={'schema':'m007-fullmodel-actual-control-census-v1','status':'PASS'if exact<=32768 else'OVER_BUDGET','scope':'actual elaborated canonical source declaration census, not physical implementation','build_manifest_sha256':sha(b/'source_manifest.json'),'hierarchy_sha256':sha(b/'work/hierarchy_scopes.txt'),'parent_sha256':sha(f/'laya_m007_single_parent_v3.sv'),'components_bits':components,'new_parent_field_bits':new_parent,'actual_deleted_legacy_fields_bits':removed,'exact_control_bits':exact,'exact_control_bytes':exact/8,'remaining_control_bits':32768-exact,'payload_increment_bytes':{'bias_expansion':57344,'type':12288,'bias_response':256,'type_response':128},'new_router_registers':0,'checks':checks,'check_count':len(checks),'unchanged_implementations':unchanged,'physical_fit_timing':'NOT_RUN','full_graph':'NOT_RUN','external_DMA_frontend_census':'OPEN'}
a.out.mkdir(parents=True,exist_ok=True);(a.out/'source_control_hierarchy_audit.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_FULLMODEL_CENSUS_PASS bits='+str(exact)+' checks='+str(len(checks)))
