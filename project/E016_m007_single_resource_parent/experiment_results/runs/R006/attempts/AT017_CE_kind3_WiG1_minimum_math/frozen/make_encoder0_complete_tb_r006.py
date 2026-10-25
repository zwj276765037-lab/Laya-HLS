#!/usr/bin/env python3
"""Complete kind4 original checker plus identical-source scalar/packed G modes."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[3]
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
public=(MOD/'tb/m007_encoder0_public_tb.sv').read_text()
decl=public[public.index(' logic  clk;'):public.index(' laya_m007_single_parent_v2 dut')]
packed=(MOD/'tb/m007_ffn_packed_parent_tb.sv').read_text()
attention=(MOD/'tb/m007_full_parent_tb.sv').read_text()
g=packed[packed.index('   if(dut.g_g_wr_valid'):packed.index('   if(dut.m_done_valid&&dut.m_done_ready)')]
g=g.replace('if((vi>=0&&vi<41984)&&', 'if(packed_check&&(vi>=0&&vi<41984)&&')
g=g.replace('if(g_outputs>=0&&g_outputs<41984)', 'if(packed_check&&g_outputs>=0&&g_outputs<41984)')
g=g.replace('{cmd_generation,cmd_epoch,16\'b0,16\'(g_outputs)}', '{cmd_generation,op_epoch(4),16\'b0,16\'(g_outputs)}')
g=g.replace('dut.layer.g_engine.', 'dut.resident.joint.g_engine.')
for prefix in ['g_g_','g_fp_','g_sfu_','tanh_rsp_mask']:
 g=re.sub(r'\bdut\.'+prefix+r'(\w*)',r'dut.resident.'+prefix+r'\1',g)
g=re.sub(r'\bchecked\((\d+)\)',r'checked(\1,"G")',g)
# The original actual-node failure path is copied byte-for-byte apart from
# hierarchy paths, operationepoch, the packed branch enable and progress label.
att=attention[attention.index(' always @(posedge clk)if(rst_n&&parent_state==7)'):attention.index(' always @(negedge clk)if(rst_n&&normal_started)')]
att=att.replace('dut.layer.','dut.resident.joint.layer.').replace('dut.l_res_','dut.resident.a_res_')
att=att.replace('if(stop_after_head>0&&nheads==stop_after_head)', 'if(stop_after_head>0&&nheads==stop_after_head)')
att=att.replace('matrix_accepts!=1||ctx_reads!=0||wo_outputs!=0', 'mcommands!=1||ctx_reads!=0||m_outputs[1]!=0')
att=att.replace('M007_PARENT_TWO_HEAD_PASS', 'M007_ENCODER0_HEAD_PREFIX_PASS').replace('HARDWARE_AGENT_SIM_PASS M007_PARENT_TWO_HEAD','HARDWARE_AGENT_SIM_PASS M007_ENCODER0_HEAD_PREFIX')
att=att.replace('$display("M007_ENCODER0_HEAD_PREFIX_PASS', 'observed_output.finish_capture(0);$display("M007_ENCODER0_HEAD_PREFIX_PASS')
body=(ROOT/'project/E016_m007_single_resource_parent/experiment_source/encoder0_complete_tb_body_r006.svpart').read_text()
body=body.replace('__G_CHECKER__',g).replace('__ATTENTION_CHECKER__',att)
old=(MOD/'tb/m007_ffn_parent_tb.sv').read_text()
defaults=old[old.rfind(' initial begin')+len(' initial begin'):old.index('  if(!$value$plusargs("FIXTURE=')]
body=body.replace('__DEFAULTS__',defaults)
oldmem=' logic [511:0] qkv_mem[0:3][0:13823],wo_mem[0:3][0:4607],wi_mem[0:3][0:23615],down_mem[0:3][0:11807];'
newmem=[];weightloads=[];cases=[]
for ph,(family,maximum,folder,base)in enumerate([('qkv',13823,'qkv_0_weight','matrix_fixture'),('wo',4607,'wo_0_weight','context_fixture'),('wi',23615,None,'wi_weights'),('down',11807,None,'down_weights')]):
 newmem.extend(f' logic [511:0] {family}_mem{channel}[0:{maximum}];'for channel in range(4))
 cases.append(str(ph)+':case(p)'+''.join(str(channel)+':return '+family+'_mem'+str(channel)+'[idx];'for channel in range(3))+'default:return '+family+'_mem3[idx];endcase')
 for channel in range(4):
  path=('/'+folder if folder else '')+'/p'+str(channel)+'.hex'
  weightloads.append('  $readmemh({'+base+',"'+path+'"},'+family+'_mem'+str(channel)+');')
assert oldmem in body;body=body.replace(oldmem,'\n'.join(newmem))
body=re.sub(r' function automatic logic \[511:0\] word_at.*?endfunction',' function automatic logic [511:0] word_at(input int ph,p,idx);case(ph)'+' '.join(cases)+' endcase endfunction',body,count=1)
body=body.replace('__WEIGHTS__','\n'.join(weightloads))

s='`timescale 1ns/1ps\nmodule m007_encoder0_complete_tb;\n'+decl+body
out=MOD/'tb/m007_encoder0_complete_tb.sv';out.write_text(s)
r={'schema':'m007-encoder0-complete-checker-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'original_attention_checker_sha256':hashlib.sha256((MOD/'tb/m007_full_parent_tb.sv').read_bytes()).hexdigest(),'original_G_packed_candidate_sha256':hashlib.sha256((MOD/'tb/m007_ffn_packed_parent_tb.sv').read_bytes()).hexdigest(),'math_oracle_recomputed':False,'scalar_packed_modes_same_production':True,'coverage':'Four real matrix/A/W paths, original Attention/G nodes, residual/LN/final public original checkers, capture','NOT_RUN':['compilation','numerical function','packed speedup','same-runtime complete Encoder0']}
(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R006/reports/complete_tb_generation.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r))
