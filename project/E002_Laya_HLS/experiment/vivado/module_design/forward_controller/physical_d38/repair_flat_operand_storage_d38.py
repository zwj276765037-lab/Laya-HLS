#!/usr/bin/env python3
"""Second authorized representation-only step: flat8192-bit packed slots."""
from pathlib import Path
import hashlib,json,difflib
ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
PRE=RUN/'repair';OUT=RUN/'repair_v2'
SRC=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_engine_v1.sv'
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
def freeze(p,s):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_text()==s,str(p)
 else:p.write_text(s)
def main():
 original=(PRE/'original_matrix_engine.sv').read_text();prior=(PRE/'fixed_matrix_engine.sv').read_text();relation=json.loads((PRE/'source_relation.json').read_text())
 assert sha(prior)=='e279968ca6407bc4c96687a689ba187cd7e29c1f0e2c61a358ecf1f18c917154'
 changes=[('logic [255:0][31:0] op0[0:63],op1[0:63];','logic [8191:0] op0[0:63],op1[0:63];'),('op1[slot][16*a+c]','op1[slot][32*(16*a+c)+:32]'),('op0[write_next[5:0]][16*a+c]','op0[write_next[5:0]][32*(16*a+c)+:32]')]
 fixed=prior
 for before,after in changes:assert fixed.count(before)==1;fixed=fixed.replace(before,after)
 assert SRC.read_text()in(prior,fixed);SRC.write_text(fixed)
 inverse=fixed
 for before,after in reversed(changes):assert inverse.count(after)==1;inverse=inverse.replace(after,before)
 assert inverse==prior
 inverse=inverse.replace(relation['generated_static_process'],'',1)
 for op in reversed(relation['removed_write_operations']):at=op['offset_in_sequential_transform'];inverse=inverse[:at]+op['removed']+inverse[at:]
 inverse=inverse.replace(' logic [255:0][31:0] op0[0:63],op1[0:63];',' logic [63:0][255:0][31:0]  op0,op1;')
 assert inverse==original
 freeze(OUT/'original_matrix_engine.sv',original);freeze(OUT/'prior_matrix_engine.sv',prior);freeze(OUT/'fixed_matrix_engine.sv',fixed)
 freeze(OUT/'production_from_original.diff',''.join(difflib.unified_diff(original.splitlines(True),fixed.splitlines(True),fromfile='original2147d041',tofile=str(SRC))))
 freeze(OUT/'production_from_prior.diff',''.join(difflib.unified_diff(prior.splitlines(True),fixed.splitlines(True),fromfile='prior_e279968c',tofile=str(SRC))))
 old_extract=(PRE/'old_storage.sv').read_text();new_extract=(PRE/'new_storage.sv').read_text()
 for before,after in changes:assert new_extract.count(before)==1;new_extract=new_extract.replace(before,after)
 # Entire new static process and every old/new storage read RHS must occur in production.
 generated=relation['generated_static_process']
 for before,after in changes:generated=generated.replace(before,after)
 assert generated in fixed
 reads=relation['read_expressions'];new_reads=[r.replace(changes[2][0],changes[2][1])for r in reads]
 mapping=[]
 for version,text,fragments in [('original',original,reads),('fixed',fixed,new_reads)]:
  for fragment in fragments:assert fragment in text;mapping.append({'version':version,'kind':'read','fragment':fragment,'line':text.count('\n',0,text.index(fragment))+1})
 for before,after in changes:mapping.append({'version':'fixed','kind':'authorized_edit','prior':before,'actual':after,'line':fixed.count('\n',0,fixed.index(after))+1})
 freeze(OUT/'old_storage.sv',old_extract);freeze(OUT/'new_storage.sv',new_extract)
 proof={'original_sha256':sha(original),'prior_sha256':sha(prior),'fixed_sha256':sha(fixed),'exact_inverse_restores_original_bytes':inverse==original,'exact_inverse_restores_prior_bytes':True,'changes_from_prior':changes,'prior_source_relation':{'path':str(PRE/'source_relation.json'),'sha256':sha((PRE/'source_relation.json').read_text())},'source_fragments':mapping,'generated_static_process':generated,'layout_identity':'packed[255:0][31:0] lane j maps exactly to flat[32*j+:32]; whole8192-bit assignments unchanged','all_other_guards_control_and_reads_byte_unchanged':True,'scope':'actual original/latest storage blocks; four-state6721cycle comparison planned; known64-slot domain, no new full30 rerun'}
 freeze(OUT/'source_relation.json',json.dumps(proof,indent=2)+'\n')
 print(json.dumps({'latest_SHA256':sha(fixed),'inverse_original_exact':True,'inverse_prior_exact':True,'changed_expressions_from_prior':len(changes)}))
if __name__=='__main__':main()
