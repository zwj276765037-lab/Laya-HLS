#!/usr/bin/env python3
"""Apply the existing additive same-clock CE repair to local exact helpers."""
from pathlib import Path
import importlib.util,json,re,sys,hashlib

def rec(p):
 b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

a,native=map(lambda x:Path(x).resolve(),sys.argv[1:3])
generator=Path(__file__).with_name('attention_freeze_ce.py')
spec=importlib.util.spec_from_file_location('ce_generator',generator)
ce=importlib.util.module_from_spec(spec);spec.loader.exec_module(ce)
ce.TOP='__external_attention_tile_controller__'
files={p.name:p.read_text() for p in native.glob('*.v')};modules={};owners={}
for name,s in files.items():
 for mod,start,end in ce.module_ranges(s):modules[mod]=s[start:end];owners[mod]=name
names=set(modules);roots=['tanh_libm_stream_leaf_stream_mul_node_14_s','tanh_libm_stream_leaf_stream_add_node_0_s','tanh_libm_stream_leaf_stream_div_node_0_s']
selected=set();graph={}
def visit(mod):
 if mod in selected:return
 selected.add(mod);_,r=ce.modify(modules[mod],mod,names);graph[mod]=r
 for child in r['children']:visit(child['module'])
for root in roots:visit(root)
records=[]
for filename in sorted({owners[mod] for mod in selected}):
 s=files[filename];entries=[]
 for mod,start,end in reversed(ce.module_ranges(s)):
  s1,r=ce.modify(s[start:end],mod,names);s=s[:start]+s1+s[end:];entries.append(r)
 rename=re.compile(r'\b('+'|'.join(re.escape(x) for x in sorted(selected,key=len,reverse=True))+r')\b')
 s=rename.sub(lambda x:'attention_tile_ce_'+x[0],s)
 dst=a/'rtl'/('attention_tile_ce_'+filename);original=native/filename
 assert not dst.exists(),'fresh namespaced local helper required'
 dst.write_text(s);records.append(dict(original=rec(original),patched=rec(dst),modules=list(reversed(entries))))
manifest=dict(schema='attention-tile-exact-helpers-same-clock-ce-v1',generator=rec(Path(__file__)),reused_generator=rec(generator),roots=roots,reachable_modules=sorted(selected),files=records,
 rule='Add one laya_global_ce input, propagate it to original named instances, wrap every original posedge block; prefix local module/file names attention_tile_ce_ to avoid collisions with unchanged GEGLU canonical closure; arithmetic/data/latency/instances unchanged. Controller drives ap_ce|ap_rst; synchronous reset preempts freeze.',
 posedge_blocks=sum(graph[m]['posedge_blocks'] for m in selected),status='CANDIDATE_PENDING_RTL_AND_OOC')
(a/'helper_ce_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('ATTENTION_SERVICE_TILE_HELPER_CE_FREEZE_PASS modules='+str(len(selected))+' posedge='+str(manifest['posedge_blocks']))
