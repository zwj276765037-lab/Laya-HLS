#!/usr/bin/env python3
"""Serialize existing setup/H products and generate public v3 integration TB."""
from pathlib import Path
import hashlib,json,re,struct
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';S=Path(__file__).parent
P=M/'forward_controller/rtl/laya_m007_single_parent_v3.sv'
t=P.read_text();header=t[t.index(' input logic clk'):t.index('\n);')]
# Parse grouped ANSI logic ports without dropping names or packed dimensions.
ports=[]
for match in re.finditer(r'\b(input|output)\s+logic\s*((?:\[[^\]]+\]\s*)*)(.*?)(?=,\s*(?:input|output)\s+logic|\s*$)',header,re.S):
 direction,width,names=match.groups()
 for name in names.split(','):
  name=name.strip();assert re.fullmatch(r'\w+',name),name
  ports.append((direction,width.strip(),name))
assert {'clk','rst_n','setup_valid','rlast'}<=set(p[2]for p in ports)
assert len(ports)==len(set(p[2]for p in ports))
D=R/'data';D.mkdir(exist_ok=True)
host=ROOT/'project/E020_m007_model_catalog/experiment_results/runs/R001/attempts/AT002_host_fix/work/host'
files=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name in ['bias','gamma','type']:
 p=host/'coefficients'/f'{name}.f32.bin';data=p.read_bytes();o=D/f'{name}.words.hex';o.write_text(''.join(f'{v:08x}\n'for(v,)in struct.iter_unpack('<I',data)));files.append({'source':str(p.relative_to(ROOT)),'source_sha256':sha(p),'serialized':str(o.relative_to(ROOT)),'serialized_sha256':sha(o),'bytes':len(data),'arithmetic':False})
p=host/'catalog.hex';o=D/'catalog.hex';o.write_bytes(p.read_bytes());files.append({'source':str(p.relative_to(ROOT)),'source_sha256':sha(p),'serialized':str(o.relative_to(ROOT)),'serialized_sha256':sha(o),'arithmetic':False})
# Preserve original fixed-capture serializer identity; no re-evaluation of F32.
p=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R006/data/original_encoder0_fixture/embedding_norm.groups1024.hex'
assert p.exists();files.append({'source':str(p.relative_to(ROOT)),'source_sha256':sha(p),'role':'original H0 groups serialization'})
(R/'input_products.json').write_text(json.dumps({'schema':'m007-r007-original-setup-products-v1','files':files,'catalog':json.loads((host/'report.json').read_text())['catalog'],'address_manifest':str((host/'sim_addresses.json').relative_to(ROOT)),'address_manifest_sha256':sha(host/'sim_addresses.json'),'address_profile':'SIM','new_gold':False},indent=2)+'\n')
decl='\n'.join(' logic '+(w+' 'if w else'')+n+';'for d,w,n in ports)
defaults='\n'.join('  '+n+"='0;"for d,w,n in ports if d=='input')
body=(S/'fullmodel_tb_body_r007.svpart').read_text().replace('__DEFAULTS__',defaults).replace('__PLATFORM_SHA__',sha(host/'sim_addresses.json'))
o=M/'forward_controller/tb/m007_fullmodel_parent_tb.sv';o.write_text('`timescale 1ns/1ps\nmodule m007_fullmodel_parent_tb;\n'+decl+'\n'+body)
(R/'tb_source_preparation.json').write_text(json.dumps({'stage':'SOURCE_PREPARED_NOT_COMPILED','source':str(o.relative_to(ROOT)),'sha256':sha(o),'ports':len(ports),'actual_setup':'NOT_RUN','no_internal_state_forcing':True},indent=2)+'\n')
print('TB',len(ports),'ports',sha(o))
