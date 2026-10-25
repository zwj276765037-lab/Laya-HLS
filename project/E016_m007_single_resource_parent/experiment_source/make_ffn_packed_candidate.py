#!/usr/bin/env python3
"""Prepare two self-contained observation-equivalent future TB candidates.
No EDA/RTL run, gold calculation or current R005 source replacement.
"""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller';baseline=(M/'tb/m007_ffn_parent_tb.sv').read_text();capture=(M/'tb/m007_public_f32_capture_tb_v1.sv').read_text();s=baseline.replace(' laya_m007_single_parent_v1 dut(.*);',' laya_m007_single_parent_v1 dut(.*);\n m007_public_f32_capture_tb_v1 observed_output(.clk,.rst_n,.command_fire(cmd_valid&&cmd_ready),.request_id(cmd_request),.generation(cmd_generation),.source_epoch(cmd_epoch),.output_fire(out_valid&&out_ready),.row(out_row),.col(out_col),.data(out_data));')
s=s.replace('$display("HARDWARE_AGENT_SIM_PASS M007_FFN_PREFIX");', 'observed_output.finish_capture(1\'b0);$display("HARDWARE_AGENT_SIM_PASS M007_FFN_PREFIX");')
s=s.replace('$display("HARDWARE_AGENT_SIM_PASS M007_FFN_FULL");', 'observed_output.finish_capture(1\'b1);$display("HARDWARE_AGENT_SIM_PASS M007_FFN_FULL");')
scalar=s.replace('module m007_ffn_parent_tb;', 'module m007_ffn_capture_parent_tb;')
(M/'tb/m007_ffn_capture_parent_tb.sv').write_text(scalar+'\n'+capture)
packed=s.replace('module m007_ffn_parent_tb;', 'module m007_ffn_packed_parent_tb;')
packed=packed.replace('logic[383:0]vectors[0:335871];','logic[383:0]vectors[0:335871];\n logic[255:0]node_expected[0:8][0:41983],tanh_expected[0:41983],g_expected[0:41983];')
prepack='''
  // Serialization of unchanged original independent records, no arithmetic.
  for(int vi=0;vi<41984;vi++)for(int lane=0;lane<8;lane++)begin
   int si;si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+lane;
   for(int node=0;node<9;node++)begin int gw;gw=node==0?2:node==1?3:node==2?4:node==3?5:node==4?6:node==5?8:node==6?9:node==7?10:11;node_expected[node][vi][32*lane+:32]=vectors[si][383-gw*32-:32];end
   tanh_expected[vi][32*lane+:32]=vectors[si][159:128];g_expected[vi][32*lane+:32]=vectors[si][31:0];
  end
'''
packed=packed.replace('$readmemh(g_fixture,vectors);', '$readmemh(g_fixture,vectors);'+prepack)
old='''    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.g_fp_rsp_data[n][l]!==vectors[si][383-gw*32-:32]||dut.g_fp_rsp_status[n][l]!==0)$fatal(1,"original FP node n=%0d vi=%0d lane=%0d",n,vi,l);node_checks++;end'''
assert old in packed
new='''    if((vi>=0&&vi<41984)&&(dut.g_fp_rsp_data[n]===node_expected[n][vi])&&(dut.g_fp_rsp_status[n]===256'b0))node_checks+=8;
    else begin
'''+old+'''
    end'''
packed=packed.replace(old,new)
old='''    for(int l=0;l<8;l++)begin si=((vi%512)/4)*2624+(vi/512)*32+(vi%4)*8+l;if(dut.g_sfu_rsp_data[l]!==vectors[si][159:128]||dut.g_sfu_rsp_status[l]!==0)$fatal(1,"original TANH H");node_checks++;end''';assert old in packed
packed=packed.replace(old,'''    if((vi>=0&&vi<41984)&&(dut.g_sfu_rsp_data===tanh_expected[vi])&&(dut.g_sfu_rsp_status===256'b0))node_checks+=8;
    else begin
'''+old+'''
    end''')
old='''    for(int l=0;l<8;l++)begin si=((g_outputs%512)/4)*2624+(g_outputs/512)*32+(g_outputs%4)*8+l;ev[l]=vectors[si][31:0];end''';assert old in packed
packed=packed.replace(old,'''    if(g_outputs>=0&&g_outputs<41984)ev=g_expected[g_outputs];
    else begin
'''+old+'''
    end''')
(M/'tb/m007_ffn_packed_parent_tb.sv').write_text(packed+'\n'+capture)
report={'scope':'PREPARATION_ONLY_NO_EDA_OR_NEW_GOLD','baseline_TB_sha256':hashlib.sha256(baseline.encode()).hexdigest(),'capture_helper_sha256':hashlib.sha256(capture.encode()).hexdigest(),'scalar_capture_TB_sha256':hashlib.sha256((M/'tb/m007_ffn_capture_parent_tb.sv').read_bytes()).hexdigest(),'packed_capture_TB_sha256':hashlib.sha256((M/'tb/m007_ffn_packed_parent_tb.sv').read_bytes()).hexdigest(),'packed_expected_extra_TB_payload_bytes':(9+2)*41984*32,'production_RTL_modified':False,'original_gold_modified':False,'future_comparison':'Same production closure/fixtures/shape/assertions/capture; scalar vs packed only, initialization charged. Packed success iff all8 original lane4state comparisons/statuses succeed; any mismatch/out-of-domain falls back to exact original ordered lane loop and originalfatal/partialcounter behavior.','actual_output_capture':'Observe public handshakes only; exactcoordinates/context/trace, row-major actualbits, fullcoverage then postprocess SHA/runmanifest. Prefix exports marked incomplete/no binary. No DUT feed from captures in these TBs.','runtime_status':'NOT_COMPILED_NOT_RUN'}
(ROOT/'project/E016_m007_single_resource_parent/experiment_source/ffn_packed_candidate_preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
