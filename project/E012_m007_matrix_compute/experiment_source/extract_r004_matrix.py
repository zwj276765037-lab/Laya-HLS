#!/usr/bin/env python3
"""Mechanical extraction from immutable R003 AT018; no numerical FSM fork."""
import hashlib,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[3]
mod=root/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore'
base=root/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT018_f32_shared_div_idle_build/frozen'
run=root/'project/E012_m007_matrix_compute/experiment_results/runs/R004'
# Pure-engine directions. Private shell uses their exact inverses.
ports=[]
def add(direction,width,names):
 for name in names.split(','):ports.append((direction,width,name))
add('output','[63:0]','fp_owner_request');add('output','[31:0]','fp_owner_generation,fp_owner_epoch')
add('output','','bind_new_lease,fp_release_valid,fp_phase_debt_clear')
add('input','','fp_lease_ready,fp_release_ready,fp_lease_active,fp_draining,fp_fault,storage_bind_ready,storage_idle')
add('output','','mul_req_valid,mul_rsp_ready');add('input','','mul_req_ready,mul_rsp_valid')
add('output','[95:0]','mul_req_tag');add('input','[95:0]','mul_rsp_tag')
add('output','[255:0][31:0]','mul_a,mul_b');add('input','[255:0][31:0]','mul_rsp_data');add('input','[6:0]','mul_pending')
add('output','[6:0]','add_req_valid,add_req_is_root,add_rsp_ready');add('input','[6:0]','add_req_ready,add_rsp_valid')
add('output','[6:0][2:0]','add_req_phase');add('output','[6:0][31:0]','add_req_epoch')
add('output','[6:0][95:0]','add_req_tag');add('input','[6:0][95:0]','add_rsp_tag')
add('output','[255:0][31:0]','add_a,add_b');add('input','[255:0][31:0]','add_rsp_data');add('input','[6:0][6:0]','add_pending')
add('output','','ps_wr_valid,ps_wr_rsp_ready,ps_rd_valid,ps_rd_rsp_ready');add('input','','ps_wr_ready,ps_wr_rsp_valid,ps_rd_ready,ps_rd_rsp_valid')
add('output','[1023:0]','ps_wr_mask,ps_rd_mask');add('input','[1023:0]','ps_rd_rsp_mask')
add('output','[1023:0][3:0]','ps_wr_addr,ps_rd_addr');add('output','[1023:0][31:0]','ps_wr_data');add('input','[1023:0][31:0]','ps_rd_rsp_data')
add('output','[95:0]','ps_wr_tag,ps_rd_tag');add('input','[95:0]','ps_wr_rsp_tag,ps_rd_rsp_tag')
port_names={x[2] for x in ports}
def porttext(inverse=False):return ',\n'.join(' '+(('input' if d=='output' else 'output') if inverse else d)+' logic '+(w+' ' if w else '')+n for d,w,n in ports)
def wires():return '\n'.join(' logic '+(w+' ' if w else '')+n+';' for _,w,n in ports)
def module_parts(s):
 i=s.index(');\n');return s[:i],s[i+3:]
def header(old,new,extra=True):
 h,_=module_parts(old);h=h.replace('module '+new[0]+'(', 'module '+new[1]+' #(parameter bit PROFILE_ENABLE='+('0' if extra else '1')+')(')
 if extra:h+=',\n output logic profile_valid,\n'+porttext()
 return h+');\n'
def remove_external_declarations(body):
 # Only the declaration prefix before functions is changed. All controller logic remains.
 i=body.index(' function automatic');pre=body[:i];post=body[i:]
 def change(m):
  width=m.group(1) or '';names=[n.strip() for n in m.group(2).split(',')];kept=[n for n in names if n not in port_names]
  return 'logic '+width+(' ' if width else '')+','.join(kept)+';' if kept else ''
 pre=re.sub(r'logic\s*((?:\[[^\]]+\]\s*)*)([A-Za-z_][A-Za-z0-9_]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)\s*;',change,pre)
 return pre+post
oldcore=(base/'laya_m007_matrix_superblock_v1.sv').read_text();h,body=module_parts(oldcore)
start=body.index(' laya_shared_fp256_v2 fp(');end=body.index(' always_ff @(posedge clk)begin',start);private=body[start:end];body=body[:start]+body[end:]
body=remove_external_declarations(body)
body=re.sub(r'logic\s+\[63:0\]\[31:0\]\s+issue_time,ps_time;','',body)
for x in ['issue_time[issue_count[5:0]]<=tick;','ps_time[ps_next[5:0]]<=tick;','max_issue_commit<=0;','max_ps_feedback<=0;']:
 body=body.replace(x,'')
body=body.replace('     if(tick-issue_time[ps_wr_rsp_tag[5:0]]>max_issue_commit)max_issue_commit<=tick-issue_time[ps_wr_rsp_tag[5:0]];\n','').replace('     if(tick-ps_time[ps_wr_rsp_tag[5:0]]>max_ps_feedback)max_ps_feedback<=tick-ps_time[ps_wr_rsp_tag[5:0]];\n','')
profile='''
 assign fp_owner_request=request_id;assign fp_owner_generation=generation;assign fp_owner_epoch=epoch;
 assign fp_release_valid=state==FINALRELEASE&&!release_fp_done;
 assign fp_phase_debt_clear=arithmetic_debt==0&&retire_debt==0&&storage_idle&&!a_ret_valid&&w_state==0&&!out_hold_valid;
 assign ps_wr_rsp_ready=1'b1;
 assign profile_valid=PROFILE_ENABLE;
 generate if(PROFILE_ENABLE)begin:g_profile
  logic [63:0][31:0] issue_time,ps_time;
  always_ff @(posedge clk)begin
   if(!rst_n)begin max_issue_commit<=0;max_ps_feedback<=0;end
   else begin
    if(cmd_valid&&cmd_ready&&descriptor_ok&&!matrix_active)begin max_issue_commit<=0;max_ps_feedback<=0;end
    if(trace_issue)issue_time[issue_count[5:0]]<=tick;
    if(state==RUN&&ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32)ps_time[ps_next[5:0]]<=tick;
    if(math_read_fire)ps_time[ps_next[5:0]]<=tick;
    if(state==RUN&&normal_write_ack)begin
     if(tick-issue_time[ps_wr_rsp_tag[5:0]]>max_issue_commit)max_issue_commit<=tick-issue_time[ps_wr_rsp_tag[5:0]];
     if(tick-ps_time[ps_wr_rsp_tag[5:0]]>max_ps_feedback)max_ps_feedback<=tick-ps_time[ps_wr_rsp_tag[5:0]];
    end
   end
  end
 end else begin:g_no_profile
  assign max_issue_commit=32'b0;assign max_ps_feedback=32'b0;
 end endgenerate
'''
body=body.replace(' always_ff @(posedge clk)begin',profile+' always_ff @(posedge clk)begin',1)
engine=header(oldcore,('laya_m007_matrix_superblock_v1','laya_m007_matrix_engine_v1'))+body
(mod/'rtl/laya_m007_matrix_engine_v1.sv').write_text(engine)
private=private.replace('.lease_request_id(request_id)','.lease_request_id(fp_owner_request)').replace('.lease_generation(generation)','.lease_generation(fp_owner_generation)').replace('.lease_epoch(epoch)','.lease_epoch(fp_owner_epoch)')
private=private.replace('.release_valid(state==FINALRELEASE&&!release_fp_done)','.release_valid(fp_release_valid)').replace('.phase_debt_clear(arithmetic_debt==0&&retire_debt==0&&storage_idle&&!a_ret_valid&&w_state==0&&!out_hold_valid)','.phase_debt_clear(fp_phase_debt_clear)')
private=private.replace('.mul_req_epoch(epoch)','.mul_req_epoch(fp_owner_epoch)').replace('.release_epoch(epoch)','.release_epoch(fp_owner_epoch)')
private=private.replace('.bind_request_id(request_id)','.bind_request_id(fp_owner_request)').replace('.bind_generation(generation)','.bind_generation(fp_owner_generation)').replace('.bind_epoch(epoch)','.bind_epoch(fp_owner_epoch)').replace('.op_request_id(request_id)','.op_request_id(fp_owner_request)').replace('.op_generation(generation)','.op_generation(fp_owner_generation)').replace('.op_epoch(epoch)','.op_epoch(fp_owner_epoch)').replace('.ps_wr_rsp_ready(1\'b1)','.ps_wr_rsp_ready(ps_wr_rsp_ready)')
resources='`timescale 1ns/1ps\n// Standalone-only private resource shell; never instantiate in a production pure parent.\nmodule laya_m007_matrix_resources_v1(\n input logic clk,rst_n,\n'+porttext(True)+'\n);\n'+private+'endmodule\n'
(mod/'rtl/laya_m007_matrix_resources_v1.sv').write_text(resources)
corewrapper=header(oldcore,('laya_m007_matrix_superblock_v1','laya_m007_matrix_superblock_v1'),False)+'// Thin compatibility shell: exactly one common pure numerical implementation.\n'+wires()+'\n logic profile_valid;\n laya_m007_matrix_engine_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) engine(.*);\n laya_m007_matrix_resources_v1 resources(.*);\nendmodule\n'
(mod/'rtl/laya_m007_matrix_superblock_v1.sv').write_text(corewrapper)
oldfull=(base/'laya_m007_matrix_full_v1.sv').read_text();_,fullbody=module_parts(oldfull)
fullbody=fullbody.replace('laya_m007_matrix_superblock_v1 core(', 'laya_m007_matrix_engine_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) core(')
facade=header(oldfull,('laya_m007_matrix_full_v1','laya_m007_matrix_facade_v1'))+fullbody
(mod/'rtl/laya_m007_matrix_facade_v1.sv').write_text(facade)
fullwrapper=header(oldfull,('laya_m007_matrix_full_v1','laya_m007_matrix_full_v1'),False)+'// Thin compatibility shell: A/W/coefficient state exists only in facade.\n'+wires()+'\n logic profile_valid;\n laya_m007_matrix_facade_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) facade(.*);\n laya_m007_matrix_resources_v1 resources(.*);\nendmodule\n'
(mod/'rtl/laya_m007_matrix_full_v1.sv').write_text(fullwrapper)
f32=(base/'laya_m007_matrix_f32_v1.sv').read_text().replace('module laya_m007_matrix_f32_v1(', 'module laya_m007_matrix_f32_v1 #(parameter bit PROFILE_ENABLE=0)(').replace('laya_m007_matrix_full_v1 matrix(', 'laya_m007_matrix_full_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) matrix(')
(mod/'rtl/laya_m007_matrix_f32_v1.sv').write_text(f32)
manifest={'baseline':str(base),'shared_resources_frozen':True,'profile_production_default':False,'FSM_boundary':'One copied immutable controller body in engine and one facade body; legacy modules now wrappers only','changes':['externalize FP/PS connections and actual owner/release/debt signals','move profile-only512B arrays into generate','profile_valid explicitly gates historical numeric validity','F32 shell propagates profile config'], 'resource_ports':[{'direction':d,'width':w,'name':n} for d,w,n in ports], 'sources':[]}
for name in ['laya_m007_matrix_engine_v1.sv','laya_m007_matrix_facade_v1.sv','laya_m007_matrix_resources_v1.sv','laya_m007_matrix_superblock_v1.sv','laya_m007_matrix_full_v1.sv','laya_m007_matrix_f32_v1.sv']:
 f=mod/'rtl'/name;manifest['sources'].append({'path':str(f.relative_to(root)),'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'bytes':f.stat().st_size})
(run/'reports/extraction_source_map.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('EXTRACTED_REAL_SOURCE_FILES',len(manifest['sources']))
