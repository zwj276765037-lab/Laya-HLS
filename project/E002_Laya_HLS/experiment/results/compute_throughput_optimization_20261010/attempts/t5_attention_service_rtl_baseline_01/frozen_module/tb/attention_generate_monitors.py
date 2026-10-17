#!/usr/bin/env python3
"""Find actual generated operator cores and emit only passive monitor wiring."""
from pathlib import Path
import re,sys
rtl=Path(sys.argv[1]);output=Path(sys.argv[2])
modules={}
for p in rtl.glob('*.v'):
 s=p.read_text();m=re.search(r'\bmodule\s+(\w+)',s)
 if m:modules[m[1]]=s
def instances(source):
 for mod in modules:
  pattern=r'\b'+re.escape(mod)+r'\s+(?:#\s*\([\s\S]*?\)\s*)?(\w+)\s*\('
  for m in re.finditer(pattern,source):yield mod,m[1]
items=[]
def visit(mod,path,ancestors):
 if mod in ancestors:return
 if re.search(r'_(fmul|fadd|fdiv)_',mod) and (rtl/(mod+'_ip.tcl')).is_file():
  op=re.search(r'_(fmul|fadd|fdiv)_',mod)[1]
  t=(rtl/(mod+'_ip.tcl')).read_text();lat=int(re.search(r'CONFIG\.c_latency\s+(\d+)',t)[1])
  for name in ['aclken','a_tdata','b_tdata','r_tdata','r_tvalid']:
   if not re.search(r'\b'+name+r'\b',modules[mod]):raise RuntimeError('FP port alias absent: '+mod+'/'+name)
  items.append((path,op,lat));return
 for child,instance in instances(modules[mod]):visit(child,path+'.'+instance,ancestors+[mod])
visit('laya_attention_service','dut',[])
assert items and all(any(op==k for _,op,_ in items) for k in ['fmul','fadd','fdiv'])
lines=[]
for i,(path,op,lat) in enumerate(items):
 kind=['fmul','fadd','fdiv'].index(op)
 lines.append(f'''attention_fp_monitor #(.OP_KIND({kind}),.CORE_LATENCY({lat})) basic_fp_monitor_{i}(
 .clk(ap_clk),.rst_n(!ap_rst),.advance({path}.aclken),.valid({path}.r_tvalid),
 .a({path}.a_tdata),.b({path}.b_tdata),.y({path}.r_tdata),.finish_check(check_finish));''')
output.write_text('\n'.join(lines)+'\n')
print('ATTENTION_FP_MONITOR_BINDINGS '+str(items))
