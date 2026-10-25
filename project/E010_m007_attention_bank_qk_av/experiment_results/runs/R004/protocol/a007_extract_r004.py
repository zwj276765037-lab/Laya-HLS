from pathlib import Path
import json,re
m=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine')
p=m/'rtl/laya_attention_layer_v1.sv';s=(m.parents[4]/'E010_m007_attention_bank_qk_av/experiment_results/runs/R004/baseline/laya_attention_layer_v1.sv').read_text();header,body=s.split('\n);',1);body=body.removeprefix('\n');ports=header.split('module laya_attention_layer_v1(',1)[1]
assert 'laya_attention_layer_engine_v1' not in s
mp=json.loads((m/'source/m011_layer_pure_engine_interface_map.json').read_text());res=mp['proposed_pure_engine_resource_ports'];cache=mp['coefficient_engine_boundary'];assert len(res)==262 and len(cache)==25
inst={}
for name,module in [('resources','laya_attention_resources_v1'),('coeff','laya_rope_coeff_cache_v1')]:
 lines=[x for x in body.splitlines()if x.strip().startswith(module+' '+name+'(')];assert len(lines)==1;inst[name]=lines[0];body=body.replace(lines[0]+'\n','')
extra=''' input logic prepare_cancel_valid,output logic prepare_cancel_ready,input logic[63:0]prepare_cancel_request_id,input logic[31:0]prepare_cancel_generation,prepare_cancel_epoch,
 output logic prepare_cancel_rsp_valid,input logic prepare_cancel_rsp_ready,output logic[63:0]prepare_cancel_rsp_request_id,output logic[31:0]prepare_cancel_rsp_generation,prepare_cancel_rsp_epoch,output logic[7:0]prepare_cancel_rsp_status,
 output logic layer_idle,check_coverage_fault,output logic[31:0]check_first_conflict'''
public=ports.split(' input logic coeff_bind_valid,',1)[0].rstrip().rstrip(',')
cache_names={x['physical_cache_port']:'cache_'+x['physical_cache_port']for x in cache}
replace={x['current_layer_expression']:cache_names[x['physical_cache_port']]for x in cache if not x['physical_cache_port'].startswith('owner_') and re.fullmatch(r'[A-Za-z_]\w*',x['current_layer_expression'])}
# Direction/width is preserved mechanically from the audited current instance map.
engine_ports=public+',\n'+extra+',\n'+',\n'.join(' '+x['direction']+' logic'+x['width']+' '+x['name']for x in res)+',\n'+',\n'.join(' '+x['pure_engine_direction']+' logic'+x['width']+' '+cache_names[x['physical_cache_port']]for x in cache)
remove_names={x['name']for x in res}|set(replace)
pat=re.compile(r'\blogic\s*((?:\[[^\]\n]+\]\s*)*)([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*;')
def prune(match):
 names=[n.strip()for n in match[2].split(',')];keep=[n for n in names if n not in remove_names]
 return 'logic '+match[1]+','.join(keep)+';'if keep else ''
body=pat.sub(prune,body)
for old,new in sorted(replace.items(),key=lambda x:-len(x[0])):body=re.sub(r'\b'+old+r'\b',new,body)
assigns=[]
for x in cache:
 if x['pure_engine_direction']=='output'and x['current_layer_expression']not in replace:assigns.append(' assign '+cache_names[x['physical_cache_port']]+'='+x['current_layer_expression']+';')
body='\n'.join(assigns)+'\n'+body
# Physical coverage lifecycle reuse: one12288bit array, low4096bits change role after real start.
body=body.replace(' logic[4095:0]output_consumed;',' wire[4095:0]output_consumed=qkv_coverage[4095:0];logic qkv_complete;')
body=body.replace('L_RELEASE=10;','L_RELEASE=10,L_CANCEL=11;')
body=body.replace(' assign start_ready=rst_n&&state==L_PREP&&',' assign start_ready=rst_n&&state==L_PREP&&!cancel_fire&&')
body=body.replace('assign qkv_wr_ready=rst_n&&state==L_PREP&&','assign qkv_wr_ready=rst_n&&state==L_PREP&&!cancel_fire&&')
body=body.replace('assign res_qkv_wr_valid=state==L_PREP&&','assign res_qkv_wr_valid=state==L_PREP&&!cancel_fire&&')
body=body.replace('assign h_resident_valid=state==L_HRES&&(&qkv_coverage);','assign h_resident_valid=state==L_HRES&&qkv_complete&&!coverage_fault;')
body=body.replace('assign r_qkv_complete=&qkv_coverage;','assign r_qkv_complete=qkv_complete;')
body=body.replace('assign h_prepare_valid=state==L_HPREP;','assign h_prepare_valid=state==L_HPREP&&!coverage_fault;')
body=body.replace('assign h_start_valid=state==L_HSTART;','assign h_start_valid=state==L_HSTART&&!coverage_fault;')
body=body.replace('assign r_start_valid=state==L_RSTART;','assign r_start_valid=state==L_RSTART&&!coverage_fault;')
body=body.replace('assign h_abort_valid=aborted&&h_abort_ready;','assign h_abort_valid=(aborted||protocol_bad||coverage_fault)&&h_abort_ready;')
body=body.replace('assign r_abort_valid=aborted&&r_abort_ready;','assign r_abort_valid=(aborted||protocol_bad||coverage_fault)&&r_abort_ready;')
body=body.replace('laya_attention_head_engine_v1 head(','laya_attention_head_engine_v1 #(.RESIDENT_ONLY(1)) head(')
body=body.replace('.final_ready(check_ready),.coverage_fault);','.final_ready(check_ready),.coverage_fault,.first_conflict(check_first_conflict));')
body=body.replace('output_consumed<=0;','qkv_complete<=0;')
body=body.replace('if(layer_start)begin start_stamp<=clock_count;','if(layer_start)begin qkv_complete<=1;qkv_coverage[4095:0]<=0;start_stamp<=clock_count;')
body=body.replace('if(abort_valid&&abort_ready)aborted<=1;','if(abort_valid&&abort_ready)aborted<=1;\n   if(coverage_fault)begin protocol_bad<=1;if(state==L_HPREP||state==L_RSTART)state<=L_WAIT;end\n   if(cancel_fire)begin state<=L_CANCEL;qkv_coverage<=0;qkv_complete<=0;end\n   if(state==L_CANCEL&&prepare_cancel_rsp_ready)state<=L_IDLE;')
body=body.replace('if(aborted||protocol_bad||(r_done_status!=0&&!head_completed[0])||active_head==15)begin if(check_ready)','if(aborted||protocol_bad||coverage_fault||(r_done_status!=0&&!head_completed[0])||active_head==15)begin if(check_ready||coverage_fault)')
body=body.replace('if(error_valid||aborted||protocol_bad)context_discarded<=1;','if(error_valid||aborted||protocol_bad||coverage_fault)context_discarded<=1;')
body=body.replace('output_consumed[res_st_context_rd_rsp_tag[43:32]]<=1;','qkv_coverage[res_st_context_rd_rsp_tag[43:32]]<=1;')
control=''' wire cancel_fire=(prepare_cancel_valid===1'b1)&&prepare_cancel_ready;
 assign prepare_cancel_ready=rst_n&&state==L_PREP&&prepare_cancel_request_id==request_id&&prepare_cancel_generation==generation&&prepare_cancel_epoch==epoch;
 assign prepare_cancel_rsp_valid=state==L_CANCEL;
 assign prepare_cancel_rsp_request_id=request_id;assign prepare_cancel_rsp_generation=generation;assign prepare_cancel_rsp_epoch=epoch;assign prepare_cancel_rsp_status=8'd4;
 assign layer_idle=rst_n&&state==L_IDLE&&real_idle;
 assign check_coverage_fault=coverage_fault;
'''
body=body.replace(' wire prepare_descriptor_ok=',control+' wire prepare_descriptor_ok=')
engine='`timescale 1ns/1ps\n// Pure production layer: no resource or coefficient-cache instance.\nmodule laya_attention_layer_engine_v1('+engine_ports+'\n);\n'+body
(m/'rtl/laya_attention_layer_engine_v1.sv').write_text(engine)
# Compatibility shell owns exactly one physical resources and one cache.
shell_header='`timescale 1ns/1ps\n// Compatibility shell: one pure layer and one physical instance of every service.\nmodule laya_attention_layer_v1('+ports.rstrip()+',\n'+extra+'\n);\n'
# Public header already ends with a final input declaration, no trailing comma.
shell_header=shell_header.replace('coeff_wr_nonfinite_lane\n,','coeff_wr_nonfinite_lane,')
local='\n'.join(' logic'+x['width']+' '+x['name']+';'for x in res)+'\n'+'\n'.join(' logic'+x['width']+' '+cache_names[x['physical_cache_port']]+';'for x in cache if not x['physical_cache_port'].startswith('bound_') and x['physical_cache_port']!='family_complete')+'\n'
cache_inst=inst['coeff']
for x in cache:
 old='.'+x['physical_cache_port']+'('+x['current_layer_expression']+')';new='.'+x['physical_cache_port']+'('+(x['current_layer_expression']if x['physical_cache_port'].startswith('bound_')or x['physical_cache_port']=='family_complete'else cache_names[x['physical_cache_port']])+')';assert old in cache_inst;cache_inst=cache_inst.replace(old,new)
# Parse public port identifiers preserving grouped declarations.
def port_names(txt):
 names=[]
 for decl in txt.split(','):
  v=re.sub(r'\[[^\]]*\]','',decl);tokens=v.split();names.append(tokens[-1])
 return names
pub_names=port_names(public);extra_names=port_names(extra)
connections=['.'+n+'('+n+')'for n in pub_names+extra_names]+['.'+x['name']+'('+x['name']+')'for x in res]+['.'+cache_names[x['physical_cache_port']]+'('+(x['current_layer_expression']if x['physical_cache_port'].startswith('bound_')or x['physical_cache_port']=='family_complete'else cache_names[x['physical_cache_port']])+')'for x in cache]
p.write_text(shell_header+local+' laya_attention_layer_engine_v1 engine(\n  '+',\n  '.join(connections)+'\n );\n'+inst['resources']+'\n'+cache_inst+'\nendmodule\n')
print('extracted',len(res),len(cache),'public',len(pub_names),'extra',len(extra_names))
