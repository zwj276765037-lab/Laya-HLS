from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[3];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';A=MOD/'attention_and_fp_engine';G=MOD/'vector_and_ffn'
def ports(s):
 s=re.sub(r'//[^\n]*','',s);s=s[s.index(')(\n')+2:s.index(');')]
 r=[];direction=None;dims=''
 for part in s.split(','):
  x=part.strip();m=re.match(r'(input|output)\s+(?:logic\s*)?((?:\[[^\]]+\]\s*)*)(\w+)$',x)
  if m:direction,dims,name=m.groups()
  else:
   assert re.fullmatch(r'\w+',x),x
   name=x
  r.append((direction,dims,name))
 return r
ap=ports((A/'rtl/laya_attention_layer_engine_v1.sv').read_text());gp=ports((G/'rtl/laya_m007_g_engine_v1.sv').read_text())
skip={'clk','rst_n','external_control_enable','external_control_q','external_control_next','control_retired','control_private_idle'}
s='''`timescale 1ns/1ps\n// Pure production composition. Safety is wired to actual consumer state.\nmodule laya_m007_control_workspace_joint_v1(\n input logic clk,rst_n,owner_req_valid,owner_req_g,output logic owner_req_ready,\n output logic a_enable,g_enable,rearm,owner_g,\n'''
ps=[]
for pre,pp in [('a',ap),('g',gp)]:
 for di,dims,n in pp:
  if n not in skip:ps.append(f' {di} logic {dims} {pre}_{n}')
s+=',\n'.join(ps)+'\n);\n logic [12287:0]state_q,a_next;logic [11342:0]g_next;\n logic a_private_idle,g_private_idle,a_retired,g_retired;\n laya_m007_control_workspace_v1 workspace(.clk,.rst_n,.owner_req_valid,.owner_req_g,.owner_req_ready,.a_retired,.g_retired,.a_private_idle,.g_private_idle,.a_next,.g_next,.state_q,.a_enable,.g_enable,.rearm,.owner_g);\n'
for pre,pp,typ,inst in [('a',ap,'laya_attention_layer_engine_v1','layer'),('g',gp,'laya_m007_g_engine_v1','g_engine')]:
 con={'clk':'clk','rst_n':'rst_n','external_control_enable':pre+'_enable','external_control_q':'state_q'if pre=='a'else'state_q[11342:0]','external_control_next':pre+'_next','control_retired':pre+'_retired','control_private_idle':pre+'_private_idle'}
 s+=f' {typ} #(.EXTERNAL_CONTROL(1)) {inst}(\n'+',\n'.join(f'  .{n}({con.get(n,pre+"_"+n)})'for di,dims,n in pp)+'\n );\n'
s+='endmodule\n';(A/'rtl/laya_m007_control_workspace_joint_v1.sv').write_text(s)
(Path(__file__).parent/'joint_port_manifest.json').write_text(json.dumps({'layer':ap,'g_engine':gp},indent=2)+'\n')
print('JOINT_WRAPPER_GENERATED',len(ap),len(gp))
