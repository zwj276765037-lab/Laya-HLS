#!/usr/bin/env python3
"""Freeze v7: only core synthesis gains the documented no-timing strategy."""
from pathlib import Path
import copy
import datetime as dt
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[7]
RUN=ROOT/'project/E022_m007_full_top_physical/experiment_results/runs/R001'
MANUAL=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/doc/eng/man/synth_design')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identity(p):return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def freeze(p,b):
 if p.exists():assert p.read_bytes()==b,str(p)
 else:p.write_bytes(b)
def main():
 candidates=sorted((RUN/'attempts').glob('AT*_synth_help'))
 proof=next(p for p in reversed(candidates) if (p/'receipt.json').exists() and json.loads((p/'receipt.json').read_text())['verdict']=='PASS')
 receipt=json.loads((proof/'receipt.json').read_text());assert receipt['source_verify_after'] is True and not receipt['owned_after_cleanup']
 log=(proof/'vivado.log').read_text();matches=[{'line':i+1,'text':s}for i,s in enumerate(log.splitlines())if re.search(r'^\s*(?:\[)?-no_timing_driven\b',s)]
 assert matches,'Actual local help output must list -no_timing_driven'
 assert '-no_timing_driven' in MANUAL.read_text()
 freeze(RUN/'input/synth_design_local_manual_2025_2.txt',MANUAL.read_bytes())
 evidence={'schema':'d38-local-synthesis-option-support','help_attempt':str(proof),'help_receipt':identity(proof/'receipt.json'),'help_log':identity(proof/'vivado.log'),'option_lines':matches,'installed_manual':identity(MANUAL),'frozen_installed_manual':identity(RUN/'input/synth_design_local_manual_2025_2.txt'),'manual_lines':[{'line':i+1,'text':s}for i,s in enumerate(MANUAL.read_text().splitlines())if 327<=i<=329],'scope':'synthesis-only option; original300MHzXDC and finalP&R/STA unchanged'}
 freeze(RUN/'input/no_timing_driven_support.json',(json.dumps(evidence,indent=2)+'\n').encode())
 old_path=RUN/'input/bottom_up_configuration_v6.json';old=json.loads(old_path.read_text());new=copy.deepcopy(old);new['schema']='m007-d38-bottom-up-configuration-v7'
 new['stages']['core_synth']['synth_design_options']=['-no_timing_driven']
 new['synthesis_strategy']={'scope':'core_synth only','reason':'AT015 completed areaoptimization then spent remainingwallbudget inTimingOptimization withoutDCP','option_support':identity(RUN/'input/no_timing_driven_support.json'),'generator':identity(Path(__file__)),'RTL_changed_from_v6':False,'XDC_changed_from_v6':False,'final_internal_300MHz_PnR_acceptance_unchanged':True}
 stripped=copy.deepcopy(new);stripped['schema']=old['schema'];del stripped['synthesis_strategy'];del stripped['stages']['core_synth']['synth_design_options'];assert stripped==old
 old_flow=RUN/'input/bottom_up_flow_v6.tcl';flow=old_flow.read_text()
 for stage in old['stages']:flow+='set ooc_synth_options('+stage+') [list'+(' -no_timing_driven'if stage=='core_synth'else'')+']\n'
 freeze(RUN/'input/bottom_up_configuration_v7.json',(json.dumps(new,indent=2)+'\n').encode());freeze(RUN/'input/bottom_up_flow_v7.tcl',flow.encode())
 relation={'old_configuration':identity(old_path),'old_flow':identity(old_flow),'new_configuration':identity(RUN/'input/bottom_up_configuration_v7.json'),'new_flow':identity(RUN/'input/bottom_up_flow_v7.tcl'),'only_effective_strategy_change':{'core_synth':['-no_timing_driven']},'all_other_stage_specs_and_source_stub_GENERIC_identity_equal':stripped==old,'option_support':identity(RUN/'input/no_timing_driven_support.json')}
 freeze(RUN/'input/strategy_v7_relation.json',(json.dumps(relation,indent=2)+'\n').encode())
 selector=RUN/'input/active_source_version.json';active=json.loads(selector.read_text());assert active['bottom_configuration']=='bottom_up_configuration_v6.json';freeze(RUN/'input/active_source_version_before_v7.json',selector.read_bytes());active.update({'bottom_configuration':'bottom_up_configuration_v7.json','bottom_flow':'bottom_up_flow_v7.tcl','reason':'Samef849/91sources/ROM/11parentgenerics/300MHzXDC;onlycore_synth adds documented-no_timing_driven;finalP&R/STAunchanged','strategy_relation':'strategy_v7_relation.json'});selector.write_text(json.dumps(active,indent=2)+'\n');print(json.dumps(relation))
if __name__=='__main__':main()
