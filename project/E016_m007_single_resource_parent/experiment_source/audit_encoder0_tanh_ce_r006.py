#!/usr/bin/env python3
"""Actual instantiated CE-v2 replacement proof, not an unused-v1 hash census."""
import hashlib
import json
import re
from pathlib import Path


def audit(frozen,hierarchy,top,check):
    wrapper=(frozen/'laya_m007_resident_joint_v2.sv').read_text()
    if not re.search(r'\blaya_m007_tanh8_v2\b',wrapper):return None
    manifest=json.loads((frozen/'ce26_production_manifest_v1.json').read_text())
    expected={Path(p).name:h for p,h in manifest['v2_selected_dependencies'].items()}
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    for name,value in expected.items():check(sha(frozen/name)==value,'actual selected CE26 dependency '+name)
    check(re.search(r'parameter\s+bit\s+TANH_FORCE_CORE_CE\s*=\s*0',wrapper)is not None,'actual joint defaults to automatic CE without FF')
    check(len(re.findall(r'\blaya_m007_tanh8_v2\b',wrapper))==1 and 'laya_m007_tanh8_v1'not in wrapper,'actual joint source selects exactly one v2 TANH8 and no old wrapper')
    check(re.search(r'laya_m007_tanh8_v2\s*#\s*\(\s*\.FORCE_CORE_CE\(TANH_FORCE_CORE_CE\)\s*\)\s*g_tanh',wrapper)is not None,'actual single g_tanh uses declared CE control')
    parent=(frozen/'laya_m007_single_parent_v2.sv').read_text()
    check('laya_m007_resident_joint_v2 resident('in parent,'actual parent inherits auto0 default without force1 override')
    old_core=(frozen/'laya_m007_tanh_lane_v1.sv.reference').read_text().split('\nendmodule',1)[0]+'\nendmodule\n'
    core=(frozen/'laya_m007_tanh_core_v2.sv').read_text()
    old_header='module laya_m007_tanh_core_v1(input wire clk,reset,in_valid,input wire [31:0] in_data,'
    new_header='module laya_m007_tanh_core_v2(input wire clk,reset,in_valid,core_ce,input wire [31:0] in_data,'
    empty=' assign token_empty=~(|valid_pipe[151:0]);\n'
    inverse=core.replace(new_header,old_header).replace('commit_valid,token_empty,','commit_valid,')
    inverse=inverse.replace('else if(core_ce)valid_pipe','else valid_pipe').replace('always @(posedge clk) if(core_ce) ','always @(posedge clk) ')
    inverse=inverse.replace('.aclken(core_ce)',".aclken(1'b1)").replace(empty,'')
    check(inverse==old_core,'actual compiled CE core exact reversible transform preserves all old registers, widths and mathematical DAG')
    check(core.count('always @(posedge clk)')==core.count('if(core_ce)')==2447 and core.count('.aclken(core_ce)')==42,'actual 2447 sequential enables and42 unchanged arithmetic leaf instances')
    old=(frozen/'laya_m007_tanh8_v1.sv.reference').read_text();new=(frozen/'laya_m007_tanh8_v2.sv').read_text()
    marker=' wire req_fire=req_valid&&req_ready;'
    ce=''' wire req_fire=req_valid&&req_ready;
 wire lease_fire=lease_valid&&lease_ready;
 wire [7:0] core_token_empty;
 wire all_token_empty=&core_token_empty;
 wire core_ce=FORCE_CORE_CE||!rst_n||lease_active||lease_fire||req_fire||
  (pending_vectors!=0)||(in_flight_vectors!=0)||!all_token_empty||protocol_fault;'''
    inverse=new.replace('module laya_m007_tanh8_v2 #(parameter bit FORCE_CORE_CE=0)(','module laya_m007_tanh8_v1(').replace(ce,marker)
    inverse=inverse.replace('laya_m007_tanh_core_v2 core(.clk,.reset(!rst_n),.core_ce,.token_empty(core_token_empty[lane]),.in_valid(req_fire),','laya_m007_tanh_core_v1 core(.clk,.reset(!rst_n),.in_valid(req_fire),')
    check(inverse==old,'actual CE wrapper exact inverse preserves all old lease/credit/fault state and wiring')
    normalized={p.replace('\\','').replace(' ','')for p in hierarchy};base=top+'/resident/g_tanh'
    check(sum(p==base for p in normalized)==1,'actual hierarchy has one production g_tanh')
    lanes={int(m[1])for p in normalized if(m:=re.fullmatch(re.escape(base)+r'/tanh_lane\[(\d+)\]\.core',p))}
    check(lanes==set(range(8)),'actual hierarchy has exactly eight selected CE core instances')
    check(not any('/resident/tanh8_v1'in p or '/resident/tanh_core_v1'in p for p in normalized),'no second old named TANH array in actual parent hierarchy')
    return {'implementation':'TANH v2 automatic CE','added_sequential_bits':0,'control_count_transfer_basis':'exact inverse of actual instantiated v2 core/wrapper to immutable audited v1; unchanged credit and42 arithmetic leaves','core_sha256':sha(frozen/'laya_m007_tanh_core_v2.sv'),'wrapper_sha256':sha(frozen/'laya_m007_tanh8_v2.sv'),'reference_core_file_sha256':sha(frozen/'laya_m007_tanh_lane_v1.sv.reference'),'reference_wrapper_sha256':sha(frozen/'laya_m007_tanh8_v1.sv.reference'),'actual_core_instance_count':len(lanes),'sequential_blocks_per_core':2447,'arithmetic_leaf_instances_per_core':42,'unused_old_source_not_used_as_instantiation_evidence':True}
