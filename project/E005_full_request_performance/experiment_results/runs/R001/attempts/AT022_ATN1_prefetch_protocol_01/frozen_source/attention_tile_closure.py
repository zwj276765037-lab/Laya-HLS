#!/usr/bin/env python3
"""Select the actual reachable tile RTL without importing unused old services."""
from pathlib import Path
import hashlib,importlib.util,json,re,sys
a=Path(sys.argv[1]).resolve();g=Path(__file__).with_name('attention_freeze_ce.py')
spec=importlib.util.spec_from_file_location('ce_parser',g);parser=importlib.util.module_from_spec(spec);spec.loader.exec_module(parser)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
modules={};owners={}
for p in [*sorted((a/'rtl').glob('*.v')),a/'frozen_source/attention_tile_service_v1.sv']:
 s=p.read_text()
 for n,start,end in parser.module_ranges(s):assert n not in modules,n;modules[n]=parser.masked(s[start:end]);owners[n]=p
pattern=re.compile(r'\b('+'|'.join(re.escape(n) for n in sorted(modules,key=len,reverse=True))+r')\b')
selected=set();graph={}
def visit(n):
 if n in selected:return
 selected.add(n);s=modules[n];children=[]
 for m in pattern.finditer(s):
  pos=m.end()
  while pos<len(s) and s[pos].isspace():pos+=1
  if pos<len(s) and s[pos]=='#':
   pos+=1
   while s[pos].isspace():pos+=1
   pos=parser.close_paren(s,pos)+1
   while pos<len(s) and s[pos].isspace():pos+=1
  inst=re.match(r'(\w+)\s*\(',s[pos:])
  if inst:children.append(dict(module=m[1],instance=inst[1]));visit(m[1])
 graph[n]=children
visit('attention_tile_service_v1')
rtl=sorted({owners[n] for n in selected});texts='\n'.join(p.read_text() for p in rtl)
data=[p for p in sorted((a/'rtl').glob('*.dat')) if p.name in texts]
ip=[p for p in sorted((a/'rtl').glob('*_ip.tcl')) if p.name[:-7] in selected]
body=dict(schema='attention-tile-reachable-rtl-closure-v1',top='attention_tile_service_v1',modules=sorted(selected),graph=graph,rtl=[rec(p) for p in rtl],ip_tcl=[rec(p) for p in ip],memory_init=[rec(p) for p in data],generator=rec(Path(__file__)),parser=rec(g))
(a/'rtl_closure.json').write_text(json.dumps(body,indent=2)+'\n')
def tl(paths):return '[list '+' '.join('{'+str(p)+'}' for p in paths)+']'
(a/'rtl_closure.tcl').write_text('set attention_tile_rtl_files '+tl(rtl)+'\nset attention_tile_ip_tcl '+tl(ip)+'\nset attention_tile_init_data '+tl(data)+'\n')
print('ATTENTION_SERVICE_TILE_CLOSURE_PASS modules='+str(len(selected))+' files='+str(len(rtl))+' IP='+str(len(ip))+' data='+str(len(data)))
