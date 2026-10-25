#!/usr/bin/env python3
import argparse,json,hashlib,re,math
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--frozen',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();f=a.frozen
s=(f/'laya_m007_single_parent_v1.sv').read_text();adapter=(f/'laya_m007_context_quant_adapter_v1.sv').read_text()
assert not re.search(r'\b(?:laya_m007_matrix_(?:full|f32|superblock|resources)_v1|laya_attention_layer_v1)\s+(?:#.*?\)\s*)?\w+\s*\(',s)
expected=['laya_attention_resources_v1','laya_rope_coeff_cache_v1','laya_attention_layer_engine_v1','laya_m007_matrix_facade_v1','laya_m007_quant_a_fill_v1','laya_m007_context_quant_adapter_v1']
for name in expected:assert len(re.findall(r'\b'+name+r'\s+(?:#\([^;]*?\)\s*)?\w+\s*\(',s))==1,name
for name in ['laya_shared_fp256_v2','laya_shared_div8_v1','laya_attention_storage_v1','laya_attention_qkv_bank_v2','laya_ln_exp_storage_v1','laya_sfu_exp8_v1']:
 rs=(f/'laya_attention_resources_v1.sv').read_text();assert len(re.findall(r'\b'+name+r'\s+\w+\(',rs))==1,name
assert '.PROFILE_ENABLE(0)' in s
for name in ['valid','model_id','numeric_id','table_key']:assert 'assign l_cache_bound_'+name+'=coeff_bound_'+name+';' in s
assert 'assign l_cache_family_complete=coeff_family_complete;' in s
assert 'producer_failure=producer_failed||producer_fail_fire' in s and 'if(!producer_failure)' in s
assert 'rsp_fire&&matching' in adapter
# Every input of the four main instances has an explicit assignment or sole-cache driver.
portmap=json.loads((f/'parent_port_map.json').read_text());assigned=portmap['explicit_assignments'];cache=(s[s.index('laya_rope_coeff_cache_v1 coeff'):]).split(';',1)[0]
for pref,ports in portmap['ports'].items():
 for name,(direction,width) in ports.items():
  if direction=='input' and name not in ['clk','rst_n']:
   target=pref+'_'+name
   assert target in assigned or (pref=='l' and name.startswith('cache_') and '('+target+')' in cache),target
# Exact sequential declarations in newly owned parent and adapter; all identities/flags/counters included.
parent_fields={'state':5,'request_id':64,'generation':32,'epoch':32,'kind':2,'layer_index':5,'mask':128,'tensor_id':64,'base':512,'span':512,'inputs_accepted':13,'producer_failed':1,'context_failed':1,'done_status':8,'error_domain':3,'error_tuple':96,'source_status':8,'elapsed_cycles':32}
adapter_fields={'active':1,'pending':1,'stopped':1,'pending_coordinate':12,'accepted_reads':13,'consumed_groups':13,'complete':1,'protocol_fault':1}
for source,fields in [(s,parent_fields),(adapter,adapter_fields)]:
 actual=set(re.findall(r'\b(\w+)(?:\[[^\]]+\])*\s*<=',source));assert actual==set(fields),(actual-set(fields),set(fields)-actual)
newbits=sum(parent_fields.values())+sum(adapter_fields.values());newbytes=math.ceil(sum(parent_fields.values())/8)+math.ceil(sum(adapter_fields.values())/8)
combined=3550+newbytes;assert combined<=4096
p=a.out;p.mkdir(exist_ok=True)
report={'scope':'Declaration/source connectivity audit; actual elaboration and dynamic function require their own logs','new_parent_fields_bits':parent_fields,'new_adapter_fields_bits':adapter_fields,'actual_input_connections_excluding_clock_reset':sum(1 for ports in portmap['ports'].values() for n,(d,w) in ports.items() if d=='input' and n not in ['clk','rst_n']),'new_control_bits':newbits,'new_module_rounded_bytes':newbytes,'existing_layer_bits':20691,'existing_matrix_reserved_bytes':963,'prior_joint_rounded_bytes':3550,'combined_conservative_bytes':combined,'capacity_bytes':4096,'remaining_bytes':4096-combined,'single_resource_source_counts':{x:1 for x in expected},'new_payload_copy_bytes':0,'payload_note':'Context adapter uses actual public storage response hold; it adds no payload register. Existing A/W/coefficient/PS/QKV/context and numerical holding stay counted once. Fixed per-lane pipeline metadata and existing shared service tags remain separate unchanged physical accounts.','source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in f.glob('*.sv')}}
(p/'source_control_audit.json').write_text(json.dumps(report,indent=2)+'\n')
print('M007_PARENT_SOURCE_AUDIT_PASS combined_control_bytes='+str(combined)+' new_bits='+str(newbits))
