#!/usr/bin/env python3
"""Freeze three exact helpers and 42 explicit canonical parent cell mappings."""
import json
import re
import shutil
import sys
from pathlib import Path
import hashlib

a=Path(sys.argv[1]).resolve();m=Path(sys.argv[2]).resolve()
s=json.loads((a/'schedule.json').read_text())
def ident(p):
 data=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def tq(value):return '{'+str(value)+'}'
stubs=[];lines=[];classes=[]
for helper in s['helper_classes']:
 name=helper['module'];paths=[]
 for source in helper['dependencies']:
  path=a/'rtl'/Path(source['file']['path']).name
  assert ident(path)['sha256']==source['file']['sha256']
  paths.append(path)
 text=(a/'rtl'/(name+'.v')).read_text()
 header=re.search(r'\bmodule\s+'+name+r'\s*\([\s\S]*?\);',text).group()
 ports=re.findall(r'^\s*(?:input|output|inout)\b[^;]*;',text,re.M)
 names=[n.strip() for n in header[header.index('(')+1:header.rindex(')')].split(',')]
 assert set(names)=={'ap_clk','ap_rst','ap_ce','a','b','ap_return'}
 assert sorted(names)==sorted(re.findall(r'\b(\w+)\s*;', '\n'.join(ports)))
 assert not re.search(r'\bparameter\b',text)
 stubs.append('(* black_box="true", keep_hierarchy="yes" *)\n'+header+'\n'+'\n'.join(ports)+'\nendmodule\n')
 if '_add_node_0_' in name:dcp=Path(s['reused_add_dcp']['path'])
 else:dcp=a/'ooc'/name/'child_synth.dcp';classes.append(name)
 lines += ['set class_sources('+name+') [list '+' '.join(tq(p) for p in paths)+']',
           'set class_dcp('+name+') '+tq(dcp)]
lines.insert(0,'set new_classes [list '+' '.join(tq(n) for n in classes)+']')
lines.append('set boundary_cells [list '+' '.join(tq(n['instance']) for n in s['fp_nodes'])+']')
for node in s['fp_nodes']:lines.append('set boundary_module('+node['instance']+') '+tq(node['module']))
(a/'frozen_source/canonical_stubs.v').write_text('\n'.join(stubs))
(a/'frozen_source/canonical_boundaries.tcl').write_text('\n'.join(lines)+'\n')
prior=Path(s['prior_bottomup_receipt']['path']).parent
shutil.copy2(prior/'frozen_source/child_clock.xdc',a/'frozen_source/child_clock.xdc')
shutil.copy2(m/'tb/tanh_libm_canonical_ooc.tcl',a/'frozen_source/tanh_libm_canonical_ooc.tcl')
shutil.copy2(m/'tb/tanh_libm_canonical_ooc_prepare.py',a/'frozen_source/tanh_libm_canonical_ooc_prepare.py')
manifest={'schema':'laya-canonical-ooc-input-v1','part':'xcu55c-fsvh2892-2L-e',
          'configuration':'OOC flatten_hierarchy none RuntimeOptimized resource_sharing off',
          'original_cumulative_seconds':s['prior_cumulative_ooc_seconds'],
          'initial_remaining_seconds':s['remaining_ooc_seconds'],
          'reused_add_dcp':s['reused_add_dcp'],'boundary_count':42,
          'files':[ident(p) for p in sorted(a.rglob('*')) if p.is_file() and (p.parent.name in ('frozen_source','rtl') or p.name=='schedule.json')]}
(a/'ooc_source_manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
print('TANH_LIBM_CANONICAL_OOC_FREEZE_PASS helper_classes=3 new=2 reused_add=1 instances=42')
