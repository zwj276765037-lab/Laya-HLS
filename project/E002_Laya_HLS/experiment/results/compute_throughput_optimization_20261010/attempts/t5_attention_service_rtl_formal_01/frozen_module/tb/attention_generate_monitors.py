#!/usr/bin/env python3
"""Find actual generated operator cores and emit only passive monitor wiring."""
from pathlib import Path
import json,re,sys
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
mul_paths=[path for path,op,_ in items if op=='fmul']
add_paths=[path for path,op,_ in items if op=='fadd']
lines += ["wire attention_mul_advance = "+' | '.join(p+'.aclken' for p in mul_paths)+";"]
lines += ["wire attention_add_advance = "+' | '.join(p+'.aclken' for p in add_paths)+";"]
lines += ["wire ["+str(32*len(items)-1)+":0] attention_fp_returns = {"+
          ','.join(p+'.r_tdata' for p,_,_ in items)+"};"]
manifest=rtl.parents[3]/'ce_patch_manifest.json'
state=[]
if manifest.is_file():
 closure=json.loads(manifest.read_text())
 all_modules={}
 for file in rtl.glob('*.v'):
  source=file.read_text()
  for match in re.finditer(r'\bmodule\s+(\w+)\b[\s\S]*?\bendmodule\b',source):all_modules[match[1]]=match[0]
 for node in closure['hierarchy']:
  path=node['path'];source=all_modules[node['module']]
  lines.append(f'always @(negedge ap_clk) begin #2; if(!ap_rst&&!ap_ce&&{path}.laya_global_ce!==1\'b0) $fatal(1,"CE distribution not low at {path}"); end')
  for match in re.finditer(r'\breg\s+(?:signed\s+)?(?:\[[^\]]+\]\s*)?(\w+)\s*;',source):
   name=match[1]
   if re.search(r'\b'+re.escape(name)+r'\s*(?:\[[^\]]+\]\s*)?<=',source):state.append(path+'.'+name)
  depth=re.search(r'\bparameter\s+AddressRange\s*=\s*(\d+)\s*;',source)
  if depth and int(depth[1])<=128 and re.search(r'\breg\s+\[[^\]]+\]\s+ram\s*\[',source):
   state += [path+'.ram['+str(i)+']' for i in range(int(depth[1]))]
 # RAM output registers, tags, counters, valid/FSM pipeline registers and
 # wrapper CE adapters are all captured. RAM arrays are structurally gated;
 # their produced data is verified on resume by the full independent gold.
 state += [path+'.'+name for path,_,_ in items for name in ['r_tdata','r_tvalid']]
 lines.append('localparam int ATTENTION_STATE_BITS = '+' + '.join('$bits('+x+')' for x in state)+';')
 lines.append('wire [ATTENTION_STATE_BITS-1:0] attention_state_snapshot = {'+','.join(state)+'};')
 output.with_suffix('.state.json').write_text(json.dumps({'ce_manifest':str(manifest),'captured_state_registers':state},indent=2)+'\n')
else:
 lines += ['localparam int ATTENTION_STATE_BITS=1;','wire [0:0] attention_state_snapshot=0;']
output.write_text('\n'.join(lines)+'\n')
print('ATTENTION_FP_MONITOR_BINDINGS '+str(items)+' frozen_state_registers='+str(len(state)))
