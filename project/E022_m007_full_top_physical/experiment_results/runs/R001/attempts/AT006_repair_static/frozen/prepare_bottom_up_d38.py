#!/usr/bin/env python3
"""Mechanical, transient hierarchy stubs for real bottom-up DCP integration."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def freeze(p,s):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_text()==s,str(p)
 else:p.write_text(s)
def header(s,name):
 start=re.search(r'^module\s+'+re.escape(name)+r'\b',s,re.M).start();i=start;depth=0;quote=False
 while i<len(s):
  if not quote and s.startswith('//',i):i=s.find('\n',i);continue
  if not quote and s.startswith('/*',i):i=s.index('*/',i+2)+2;continue
  c=s[i]
  if c=='"'and(i==0 or s[i-1]!='\\'):quote=not quote
  if not quote:
   if c in '([{':depth+=1
   elif c in ')]}':depth-=1
   elif c==';'and depth==0:return s[start:i+1]
  i+=1
 raise ValueError('module header terminator missing')
def main():
 m=json.loads((RUN/'input/source_manifest.json').read_text());v=json.loads((RUN/'input/physical_configuration_v2.json').read_text());files={Path(x['frozen']['path']).stem:Path(x['frozen']['path'])for x in m['sources']}
 names=['laya_m007_matrix_engine_v1','laya_m007_matrix_facade_v2','laya_m007_resident_joint_v3'];stubs=[]
 for name in names:
  source=files[name];text=source.read_text();h=header(text,name);body=text[text.index(h)+len(h):];body_parameters=re.findall(r'(?m)^[ \t]*parameter\b[^;]*;',body)
  p=RUN/'input/stubs_v4'/(name+'.sv');freeze(p,'`timescale 1ns/1ps\n// Transient blackbox; replaced by its real source-bound DCP before final acceptance.\n(* black_box = "yes" *) '+h+'\n'+'\n'.join(body_parameters)+'\nendmodule\n');assert h in p.read_text();stubs.append({'module':name,'source':str(source),'source_sha256':sha(source),'header_sha256':hashlib.sha256(h.encode()).hexdigest(),'body_parameters':body_parameters,'stub':str(p),'stub_sha256':sha(p),'header_byte_exact':True})
 model=int(v['generics']['MODEL_SHA256'].split("'h")[1],16);model64=(model>>128)&((1<<64)-1)
 stages={
 'core_synth':{'top':'laya_m007_matrix_engine_v1','generics':{'PROFILE_ENABLE':"1'b0"},'stub_modules':[],'expected_blackboxes':[]},
 'facade_synth':{'top':'laya_m007_matrix_facade_v2','generics':{'PROFILE_ENABLE':"1'b0",'CANONICAL_MODEL':"1'b1",'CANONICAL_MODEL_ID':f"64'h{model64:016x}"},'stub_modules':['laya_m007_matrix_engine_v1'],'expected_blackboxes':['core']},
 'resident_synth':{'top':'laya_m007_resident_joint_v3','generics':{'TANH_FORCE_CORE_CE':"1'b0"},'stub_modules':[],'expected_blackboxes':[]},
 'parent_synth':{'top':m['top'],'generics':v['generics'],'stub_modules':['laya_m007_matrix_facade_v2','laya_m007_resident_joint_v3'],'expected_blackboxes':['matrix','resident']}}
 data={'schema':'m007-d38-bottom-up-configuration-v4','production_RTL_unchanged':True,'production_manifest_sha256':sha(RUN/'input/source_manifest.json'),'parent_configuration_v2_sha256':sha(RUN/'input/physical_configuration_v2.json'),'flatten_hierarchy':'none','synthesis_maxThreads':1,'stubs':stubs,'stages':stages,'facade_model_id_derivation':'MODEL_ID=MODEL_SHA256[255:128]; CANONICAL_MODEL_ID=MODEL_ID[63:0]=MODEL_SHA256[191:128]','facade_link':{'shell':'facade_synth.dcp','insertions':{'core':'core_synth.dcp'},'expected_blackboxes':[]},'full_link':{'shell':'parent_synth.dcp','insertions':{'matrix':'facade_link.dcp','resident':'resident_synth.dcp'},'expected_blackboxes':[]},'final_clock':'delete child OOC clocks and reread unchanged single-core 3.333333333ns XDC','acceptance':'Only actual full_link DCP with zero blackboxes and complete hierarchy is a full-kernel netlist; no component summation substitutes for linkage'}
 freeze(RUN/'input/bottom_up_configuration_v4.json',json.dumps(data,indent=2)+'\n')
 lines=['set ooc_stub_directory {'+str(RUN/'input/stubs_v4')+'}']
 for stage,spec in stages.items():
  lines += ['set ooc_top('+stage+') {'+spec['top']+'}','set ooc_generics('+stage+') [list '+' '.join('{'+k+'='+val+'}'for k,val in spec['generics'].items())+']','set ooc_stubs('+stage+') [list '+' '.join(spec['stub_modules'])+']','set ooc_expected_bb('+stage+') [list '+' '.join(spec['expected_blackboxes'])+']']
 freeze(RUN/'input/bottom_up_flow_v4.tcl','\n'.join(lines)+'\n')
 print(json.dumps({'bottom_up_configuration':str(RUN/'input/bottom_up_configuration_v4.json'),'stub_headers_byte_exact':len(stubs),'body_parameters':[x['body_parameters']for x in stubs],'core_PROFILE_ENABLE':0,'facade_CANONICAL_MODEL_ID':f'{model64:016x}'}))
if __name__=='__main__':main()
