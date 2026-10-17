#!/usr/bin/env python3
"""Freeze full GEGLU row parent plus51 actual FP cells; reuse successful exact child EDIFs."""
import sys,json,hashlib,shutil
from pathlib import Path
c=Path(sys.argv[1]).resolve();a=Path(sys.argv[2]).resolve();m=Path(sys.argv[3]).resolve()
def ident(p):
 b=p.read_bytes();return {'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
receipt=json.loads((c/'receipt_ooc_01.json').read_text())
core_receipt=json.loads((c/'core_export_receipt.json').read_text());assert core_receipt['status']=='PASS'
core_edif=c/'ooc/core_export/tanh_libm_canonical_core.edf'
assert receipt['ooc']['status']=='PASS', 'First complete original tanh assembly; do not move its failures to G budget'
schedule=json.loads((c/'schedule.json').read_text());external=json.loads((a/'frozen_source/geglu_canonical_schedule.json').read_text())
nodes=[]
for n in schedule['fp_nodes']:nodes.append(dict(n,instance='arithmetic/tanh_service/'+n['name']+'_kernel'))
for n in external['external_nodes']:nodes.append(dict(n,instance='arithmetic/'+n['name']+'_kernel'))
assert len(nodes)==51 and {op:sum(n['op']==op for n in nodes) for op in ('add','mul','div')}=={'add':25,'mul':24,'div':2}
lines=[f'set canonical_core_edif {{{core_edif}}}'];reused=[]
for h in schedule['helper_classes']:
 module=h['module'];edf=c/'ooc/edif'/f'{module}.edf'
 dcp=Path(schedule['reused_add_dcp']['path']) if '_add_node_0_' in module else c/'ooc'/module/'child_synth.dcp'
 reused.append({'module':module,'DCP':ident(dcp),'exported_EDIF':ident(edf),'accepted_canonical_receipt':ident(c/'receipt_ooc_01.json')})
 lines.append(f'set class_edif({module}) {{{edf}}}')
lines.append('set stub_boundary_cells [list {arithmetic/tanh_service} '+' '.join('{arithmetic/'+n['name']+'_kernel}' for n in external['external_nodes'])+']')
lines.append('set boundary_module(arithmetic/tanh_service) {tanh_libm_canonical_core}')
lines.append('set boundary_cells [list '+' '.join('{'+n['instance']+'}' for n in nodes)+']')
for n in nodes:lines.append(f"set boundary_module({n['instance']}) {{{n['module']}}}")
(a/'frozen_source/geglu_canonical_boundaries.tcl').write_text('\n'.join(lines)+'\n')
shutil.copy2(c/'frozen_source/canonical_stubs.v',a/'frozen_source/canonical_stubs.v')
(a/'frozen_source/canonical_core_stub.v').write_text('(* black_box="true", keep_hierarchy="yes" *)\nmodule tanh_libm_canonical_core(input wire clk,reset,in_valid,input wire [31:0] in_data,output wire commit_valid,output wire [31:0] result,status);\nendmodule\n')
(a/'frozen_source/clock.xdc').write_text('create_clock -name clk -period 6.666666667 [get_ports clk]\n')
for name in ('geglu_canonical_ooc.tcl','geglu_canonical_ooc.sh','geglu_canonical_ooc_prepare.py'):shutil.copy2(m/'tb'/name,a/'frozen_source'/name)
manifest={'schema':'laya-geglu-canonical-ooc-input-v1','part':'xcu55c-fsvh2892-2L-e','configuration':'OOC RuntimeOptimized resource_sharing off flatten_hierarchy none; exact EDIF structural link mode out_of_context; IO pads forbidden','independent_module_cumulative_budget_seconds':3600,'tanh_cumulative_budget_separate_not_reset':True,'boundary_count':51,'synthesis_stub_boundary_count':10,'canonical_core_subtree':{'DCP':ident(c/'ooc/core_export/tanh_libm_canonical_core.dcp'),'EDIF':ident(core_edif),'export_receipt':ident(c/'core_export_receipt.json')},'node_counts':{'add':25,'mul':24,'div':2},'row_data_bytes':31488,'reused_classes':reused,'nodes':nodes,'scope':'All9 external FP sites,42 actual tanh sites,full U/G/gate RAM,coverage,resident identity/control; no physical HBM writer/quant/Down resource claim','files':[ident(p) for p in sorted((a/'frozen_source').glob('*')) if p.is_file()]}
(a/'ooc_source_manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
print('TANH_LIBM_GEGLU_CANONICAL_OOC_FREEZE_PASS boundaries=51 add=25 mul=24 div=2 row_data_bytes=31488 reused_successful_classes=3')
