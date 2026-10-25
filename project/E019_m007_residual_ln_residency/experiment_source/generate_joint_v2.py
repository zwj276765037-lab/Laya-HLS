from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';A=M/'attention_and_fp_engine';G=M/'vector_and_ffn';L=M/'layernorm_engine'
def ports(s):
 s=re.sub(r'//[^\n]*','',s);head=s[:s.index(');')];pos=head.index('module ');pos=head.index('(',pos)
 # Parameterized modules start with#(...), then a separate port parenthesis.
 if '#'in head[:pos]:
  depth=0
  for i in range(pos,len(head)):
   if head[i]=='(':depth+=1
   elif head[i]==')':
    depth-=1
    if depth==0:pos=head.index('(',i+1);break
 items=[];direction=None;dims=''
 for part in head[pos+1:].split(','):
  x=part.strip();m=re.fullmatch(r'(input|output)\s+(?:logic\s*)?((?:\[[^\]]+\]\s*)*)(\w+)',x)
  if m:direction,dims,name=m.groups()
  else:
   assert re.fullmatch(r'\w+',x),(x,head[:70]);name=x
  items.append((direction,dims,name))
 return items
spec=[('a',A/'rtl/laya_attention_layer_engine_v1.sv','laya_attention_layer_engine_v1','layer'),('g',G/'rtl/laya_m007_g_engine_v1.sv','laya_m007_g_engine_v1','g_engine'),('ln',L/'rtl/laya_m007_layernorm32_v1.sv','laya_m007_layernorm32_v1','ln_engine'),('vector',A/'rtl/laya_m007_resident_vector32_v2.sv','laya_m007_resident_vector32_v2','vector_engine')]
skip={'clk','rst_n','external_control_enable','external_control_q','external_control_next','control_retired','control_private_idle','control_enable','control_q','control_next'}
pp={pre:ports(path.read_text())for pre,path,typ,inst in spec}
s='''`timescale 1ns/1ps
// Pure production four-consumer composition with exactly one arena.
// Production resource wrapper supplies actual service/bank probes and admission.
module laya_m007_control_workspace_joint_v2 #(parameter int LN_CONTROL_BITS=12128)(
 input logic clk,rst_n,owner_req_valid,input logic[1:0]owner_req,
 output logic owner_req_ready,output logic[1:0]owner,output logic rearm,
 output logic a_enable,g_enable,ln_enable,vector_enable,
 input logic shared_resources_idle,resident_bank_idle,ln_provider_idle,
 input logic[3:0]outer_admission_quiet,
'''
parts=[]
for pre,path,typ,inst in spec:
 for di,dims,n in pp[pre]:
  if n not in skip:parts.append(f' {di} logic {dims} {pre}_{n}')
s+=',\n'.join(parts)+'\n);\n'
s+=''' logic[12287:0]state_q,a_next,ln_next;logic[11342:0]g_next;logic[47:0]vector_next;
 logic a_private_idle,g_private_idle,ln_private_idle,vector_private_idle;
 logic a_retired_raw,g_retired_raw,ln_retired_raw,vector_retired_raw;
 logic a_retired,g_retired,ln_retired,vector_retired;
 logic[3:0]admission_quiet;
 wire physical_idle=shared_resources_idle&&resident_bank_idle;
 assign a_retired=a_retired_raw&&physical_idle;
 assign g_retired=g_retired_raw&&physical_idle;
 assign ln_retired=ln_retired_raw&&ln_provider_idle&&physical_idle;
 assign vector_retired=vector_retired_raw&&physical_idle;
 // Enabled-LN retirement is the sole exit. All gamma/service entrypoints are
 // disabled outside LN; global reset is unconditional. Thus no private LN
 // loading/held result can arise while inactive. Real probes below never readq.
 assign ln_private_idle=ln_provider_idle&&physical_idle;
 assign admission_quiet[0]=outer_admission_quiet[0]&&!a_prepare_valid&&!a_start_valid&&!a_result_rd_valid;
 assign admission_quiet[1]=outer_admission_quiet[1]&&!g_cmd_valid;
 assign admission_quiet[2]=outer_admission_quiet[2]&&!ln_cmd_valid&&!ln_gamma_begin_valid&&!ln_control_clear;
 assign admission_quiet[3]=outer_admission_quiet[3]&&!vector_start_valid;
 laya_m007_control_workspace_v2 #(.LN_CONTROL_BITS(LN_CONTROL_BITS))workspace(
 .clk,.rst_n,.owner_req_valid,.owner_req,.owner_req_ready,.owner,.rearm,
 .a_retired,.g_retired,.ln_retired,.vector_retired,.a_private_idle,.g_private_idle,.ln_private_idle,.vector_private_idle,
 .admission_quiet,.a_next,.g_next,.ln_next,.vector_next,.state_q,.a_enable,.g_enable,.ln_enable,.vector_enable);
'''
for pre,path,typ,inst in spec:
 con={'clk':'clk','rst_n':'rst_n','control_retired':pre+'_retired_raw','control_private_idle':pre+'_private_idle'}
 if pre=='ln':
  con.update(control_enable='ln_enable',control_q='state_q',control_next='ln_next');params='.CANONICAL_TAGS(1),.EXTERNAL_CONTROL(1)'
 else:
  con.update(external_control_enable=pre+'_enable',external_control_q='state_q'if pre=='a'else'state_q[11342:0]'if pre=='g'else'state_q[47:0]',external_control_next=pre+'_next');params='.EXTERNAL_CONTROL(1)'
 s+=f' {typ} #({params}) {inst}(\n'+',\n'.join(f'  .{n}({con.get(n,pre+"_"+n)})'for di,dims,n in pp[pre])+'\n );\n'
s+='endmodule\n';out=A/'rtl/laya_m007_control_workspace_joint_v2.sv';out.write_text(s)
manifest={'schema':'m007-four-owner-joint-ports-v1','consumers':{pre:{'source':str(path.relative_to(ROOT)),'source_sha256_at_header_generation':hashlib.sha256(path.read_bytes()).hexdigest(),'ports':pp[pre]}for pre,path,typ,inst in spec},'LN_binding':'Stableports/layoutv3 only; pending actual A008v3 verification. Normalc612 results not transferred.','generated_file':str(out.relative_to(ROOT)),'stage':'written_not_compiled_no_EDA'}
(Path(__file__).parent/'joint_v2_port_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print({k:len(v)for k,v in pp.items()})
