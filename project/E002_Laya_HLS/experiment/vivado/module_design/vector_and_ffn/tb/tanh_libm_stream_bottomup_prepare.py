#!/usr/bin/env python3
"""Freeze the exact stream02 module boundaries for bounded bottom-up OOC."""
import hashlib,json,re,shutil,sys
from pathlib import Path
src=Path(sys.argv[1]).resolve();dst=Path(sys.argv[2]).resolve()
repair=len(sys.argv)>3 and sys.argv[3]=='--repair-existing'
if repair:
 assert (dst/'source_manifest.json').is_file()
else:
 dst.mkdir();(dst/'rtl').mkdir();(dst/'frozen_source').mkdir();(dst/'nodes').mkdir();(dst/'parent').mkdir()
def ident(p):
 p=Path(p);b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
receipt=json.loads((src/'receipt.json').read_text())
assert receipt['status']=='RTL_COMPLETE_OOC_COST_ABORTED' and receipt['numerical_pass']
rtl=src/'hls_project/solution1/syn/verilog'
catalog={}
for p in sorted(rtl.glob('*.v')):
 q=dst/'rtl'/p.name
 if repair:assert q.read_bytes()==p.read_bytes(),str(q)
 else:shutil.copy2(p,q)
 s=q.read_text()
 for name in re.findall(r'\bmodule\s+(\w+)\b',s):
  assert name not in catalog,name
  catalog[name]=dict(path=q,text=s)
deps={}
for name,e in catalog.items():
 deps[name]=[]
 for other in catalog:
  if other==name:continue
  if re.search(r'\b'+re.escape(other)+r'\b\s*(?:#\s*\([\s\S]*?\)\s*)?\w+\s*\(',e['text']):
   deps[name].append(other)
def closure(name,seen=None):
 seen=set() if seen is None else seen
 if name in seen:return seen
 seen.add(name)
 for dep in deps[name]:closure(dep,seen)
 return seen
nodes=[];stubs=[];normalized={}
for n in receipt['generated_nodes']:
 name=n['module'];e=catalog[name];s=e['text']
 header=re.search(r'\bmodule\s+'+re.escape(name)+r'\s*\([\s\S]*?\);',s).group()
 declarations=re.findall(r'^\s*(?:input|output|inout)\b[^;]*;',s,re.M)
 assert declarations and not re.search(r'\bparameter\b',s.split('endmodule')[0]),name
 portnames=[p.strip() for p in header[header.index('(')+1:header.rindex(')')].split(',')]
 declared=[]
 for d in declarations:
  declared += re.findall(r'\b(\w+)\s*;',d)
 assert sorted(portnames)==sorted(declared),(name,portnames,declared)
 stubs.append('(* black_box = "true", keep_hierarchy = "yes" *)\n'+header+'\n'+'\n'.join(declarations)+'\nendmodule\n')
 c=closure(name);paths=sorted({catalog[x]['path'] for x in c})
 norm=re.sub(r'\b'+re.escape(name)+r'\b','NORMALIZED_TOP_MODULE',s)
 normalized[name]=hashlib.sha256(norm.encode()).hexdigest()
 nodes.append(dict(**n,parent_cell='leaf/'+n['instance'],ports=declarations,
  normalized_module_body_sha256=normalized[name],
  dependencies=[dict(module=x,file=ident(catalog[x]['path'])) for x in sorted(c)],
  sources=[str(p) for p in paths],dcp=str(dst/'nodes'/name/'child_synth.dcp')))
assert len(nodes)==42 and len(set(normalized.values()))==42
stub_text='\n'.join(stubs)
if repair:assert (dst/'rtl/stream_child_stubs.v').read_text()==stub_text
else:(dst/'rtl/stream_child_stubs.v').write_text(stub_text)
for name in ['tanh_libm_stream_wrapper.sv','tanh_libm_clock.xdc','tanh_libm_guard.py']:
 if repair:assert (dst/'frozen_source'/name).read_bytes()==(src/'frozen_source'/name).read_bytes()
 else:shutil.copy2(src/'frozen_source'/name,dst/'frozen_source'/name)
(dst/'frozen_source/child_clock.xdc').write_text('create_clock -name ap_clk -period 6.666666667 [get_ports ap_clk]\n# Same board-independent OOC clock; child port is ap_clk.\n')
top='tanh_libm_stream_leaf'
parent_support=closure(top)-{top}-set(n['module'] for n in nodes)
# Include unchanged shared primitive definitions; arithmetic child definitions
# are replaced only in the parent synthesis by exact-port black-box stubs.
parent_sources=sorted({catalog[x]['path'] for x in parent_support if x not in {n['module'] for n in nodes}})
parent_sources += [catalog[top]['path'],dst/'rtl/stream_child_stubs.v',dst/'frozen_source/tanh_libm_stream_wrapper.sv']
def tq(s):
 return '{'+str(s).replace('\\','/')+'}'
lines=['set node_order [list '+' '.join(tq(n['module']) for n in nodes)+']']
for n in nodes:
 name=n['module'];lines += [
  'set node_sources('+name+') [list '+' '.join(tq(p) for p in n['sources'])+']',
  'set node_cell('+name+') '+tq(n['parent_cell']),
  'set node_op('+name+') '+tq(n['op'])]
lines.append('set parent_sources [list '+' '.join(tq(p) for p in parent_sources)+']')
boundary_name='boundaries_v02.tcl' if repair else 'boundaries.tcl'
(dst/'frozen_source'/boundary_name).write_text('\n'.join(lines)+'\n')
files=[*sorted((dst/'rtl').glob('*')),*sorted((dst/'frozen_source').glob('*'))]
manifest=dict(schema='laya-stream02-bottomup-same-rtl-v1',
 source_attempt=str(src),reused_source_receipt=ident(src/'receipt.json'),
 reused_evidence_manifest=ident(src/'evidence_manifest.json'),
 scope='42 exact generated helper DCPs, unchanged parent leaf and 512-credit wrapper; no arithmetic/port/gold/credit change',
 configuration=dict(part='xcu55c-fsvh2892-2L-e',clock_period_ns=6.667,
  flatten_hierarchy='none',directive='RuntimeOptimized',resource_sharing='off'),
 cumulative_budget=dict(max_seconds=3600,max_owned_rss_gib=24,semantic_stall_seconds=120),
 equivalence_reuse='none: all 42 normalized module-name-only bodies are distinct',
 nodes=nodes,parent_sources=[str(p) for p in parent_sources],files=[ident(p) for p in files])
if repair:
 manifest['repair']={'original_manifest':ident(dst/'source_manifest.json'),'reason':'Exact module-name word boundary prevents top-name prefix from creating spurious dependencies','boundaries':ident(dst/'frozen_source'/boundary_name)}
(dst/('source_manifest_v02.json' if repair else 'source_manifest.json')).write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
print('TANH_LIBM_BOTTOMUP_FREEZE_PASS nodes=42 exact_ports=1 unchanged_arithmetic=1')

