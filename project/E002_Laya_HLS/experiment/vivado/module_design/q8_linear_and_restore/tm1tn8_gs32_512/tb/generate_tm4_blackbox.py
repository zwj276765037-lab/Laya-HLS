#!/usr/bin/env python3
"""Emit one complete four-row Group32 arithmetic call for real RTL binding."""
import json
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
OUT = MODULE / "source/blackbox"
OUT.mkdir(parents=True, exist_ok=True)
inputs = [("owner"+str(i),64) for i in range(16)] + [("aq"+str(i),64) for i in range(16)] + \
         [("wq"+str(i),64) for i in range(32)] + [("sa"+str(i),32) for i in range(4)] + \
         [("sw"+str(i),32) for i in range(8)] + [("old"+str(i),32) for i in range(32)] + \
         [(name,32) for name in ("lane_masks","group","tile","sequence")]
outputs = [("echo"+str(i),64) for i in range(16)] + [("next"+str(i),32) for i in range(32)] + \
          [("bad"+str(i),32) for i in range(4)] + [("phases"+str(i),32) for i in range(4)] + [("status",32)]
signature = "void laya_tm4_group_service(\n  " + ",\n  ".join(
 [f"uint{w}_t {n}" for n,w in inputs]+[f"uint{w}_t &{n}" for n,w in outputs]) + ")"
(OUT/"laya_tm4_group_service.h").write_text("#pragma once\n#include <cstdint>\n"+signature+";\n")
model = '''#include "laya_tm4_group_service.h"
#include "laya_numeric.h"

@SIGNATURE@ {
#pragma HLS inline off
  @ECHO@
  const uint64_t a[16]={@AQ@},w[32]={@WQ@};
  const uint32_t scales_a[4]={@SA@},scales_w[8]={@SW@},old_bits[32]={@OLD@};
  uint32_t next_bits[32],bad_mask[4]={},phase_bits[4]={};
  status=0;
  if(group>127 || tile>655 || sequence>0x7ffffffu)status=2;
  for(unsigned r=0;r<4;++r)for(unsigned n=0;n<8;++n) {
    const unsigned index=r*8+n;
    next_bits[index]=old_bits[index];
    unsigned phase=4;
    if(!status && ((lane_masks>>(r*8+n))&1u)) {
      int32_t tree[32];
      for(unsigned k=0;k<32;++k)
        tree[k]=int32_t(int8_t(a[r*4+k/8]>>(8*(k%8))))*
                int32_t(int8_t(w[n*4+k/8]>>(8*(k%8))));
      for(unsigned count=32;count>1;count/=2)
        for(unsigned k=0;k<count/2;++k)tree[k]=tree[2*k]+tree[2*k+1];
      const float sa=laya::numeric_bits_f32(scales_a[r]),sw=laya::numeric_bits_f32(scales_w[n]);
      const auto finite=[](float f){return (laya::numeric_f32_bits(f)&0x7f800000u)!=0x7f800000u;};
      const float product=sa*sw;
      float term=product*float(tree[0]);
      if(!finite(sa)||!finite(sw)||sa<0||sw<0)phase=0;
      else if(!finite(product))phase=1;
      else if(!finite(term))phase=2;
      float prior=laya::numeric_bits_f32(old_bits[index]);
      if(phase!=4){term=0.0f;prior=0.0f;}
      const float result=term+prior;
      next_bits[index]=laya::numeric_f32_bits(result);
      if(phase==4&&!finite(result))phase=3;
      if(phase!=4)bad_mask[r]|=1u<<n;
    }
    phase_bits[r]|=phase<<(n*3);
  }
  if(!status && (bad_mask[0]|bad_mask[1]|bad_mask[2]|bad_mask[3]))status=1;
  @WRITE@
}
'''.replace("@SIGNATURE@",signature).replace("@ECHO@",";".join(f"echo{i}=owner{i}" for i in range(16))+";")
for field,count in (("AQ",16),("WQ",32),("SA",4),("SW",8),("OLD",32)):
 model=model.replace("@"+field+"@",",".join(field.lower()+str(i) for i in range(count)))
model=model.replace("@WRITE@","\n  ".join([f"next{i}=next_bits[{i}];" for i in range(32)]+[
 f"bad{i}=bad_mask[{i}];phases{i}=phase_bits[{i}];" for i in range(4)]))
(OUT/"laya_tm4_group_service.cpp").write_text(model)
ports=["input wire ap_clk,ap_rst,ap_ce,ap_start,ap_continue","output wire ap_idle,ap_ready,ap_done"]
ports += [f"input wire [{w-1}:0] " + ("issue_sequence" if n == "sequence" else n) for n,w in inputs]
for n,w in outputs:ports += [f"output wire [{w-1}:0] {n}",f"output wire {n}_ap_vld"]
rtl='''`timescale 1ns/1ps
// One atomic 4-row stripe, with full 1024-bit owner retention in the HLS call.
// Actual four Q35/D4 row pipelines independently return; done waits for all
// accepted commits and the actual reservation credit to retire.
module laya_tm4_group_service (
  @PORTS@
);
  typedef enum logic [1:0] {IDLE,ISSUE,DRAIN,REPORT} phase_t;
  phase_t phase;
  logic [1023:0] owner_q,aq_q,old_q,next_q;
  logic [2047:0] wq_q;
  logic [127:0] sa_q;
  logic [255:0] sw_q;
  logic [31:0] masks_q,status_q;
  logic [6:0] group_q;
  logic [9:0] tile_q;
  logic [26:0] sequence_q;
  logic [3:0] active_rows,received,ready_rows,commit_valid,protocol;
  logic [31:0] bad_q;
  logic [95:0] phases_q;
  logic [191:0] request_tag,commit_tag[0:3];
  logic [9:0] commit_tile[0:3];
  logic [7:0] commit_mask[0:3],commit_bad[0:3];
  logic [23:0] commit_phase[0:3];
  logic [255:0] commit_ps[0:3];
  logic [5:0] free_rows[0:3],reserved_rows[0:3],returned_rows[0:3];
  logic [2:0] trace_free[0:3];
  logic all_ready,all_free;
  wire issue_fire=phase==ISSUE && all_ready && ap_ce;
  assign ap_idle=phase==IDLE;
  assign ap_done=phase==REPORT;
  assign ap_ready=phase==REPORT && ap_continue && ap_ce;
  assign request_tag={32'd0,owner_q[703:672],owner_q[799:768],owner_q[863:832],
                      1'b0,sequence_q,36'd0};
  always_comb begin
    all_ready=1;all_free=1;
    for(int r=0;r<4;r++) begin
      if(active_rows[r] && !ready_rows[r]) all_ready=0;
      if(free_rows[r]!=35 || reserved_rows[r]!=0 || returned_rows[r]!=0 || trace_free[r]!=4 || commit_valid[r])all_free=0;
    end
  end
  @OUTPUTS@
  for(genvar r=0;r<4;r++) begin:row
    tm4tn8_row_pipeline_v1 arithmetic (
      .clk(ap_clk),.rst_n(!ap_rst),.issue_valid(issue_fire && active_rows[r]),
      .issue_ready(ready_rows[r]),.issue_identity_tag(request_tag),.issue_tile(tile_q),
      .issue_lane_mask(masks_q[r*8 +:8]),.issue_trace(1'b0),.issue_trace_lane(3'd0),
      .issue_group(group_q),.issue_row(2'(r)),.issue_a8(aq_q[r*256 +:256]),
      .issue_w8(wq_q),.issue_old_ps(old_q[r*256 +:256]),.issue_sa(sa_q[r*32 +:32]),.issue_sw(sw_q),
      .commit_valid(commit_valid[r]),.commit_ready(phase==DRAIN && ap_ce),
      .commit_tag(commit_tag[r]),.commit_tile(commit_tile[r]),.commit_lane_mask(commit_mask[r]),
      .commit_bad_mask(commit_bad[r]),.commit_phase(commit_phase[r]),.commit_next_ps(commit_ps[r]),
      .trace_valid(),.trace_ready(1'b1),.trace_slot(),.trace_tag(),.trace_payload(),
      .trace_ack_valid(1'b0),.trace_ack_slot(2'd0),.trace_ack_tag(192'd0),.trace_ack_ok(1'b1),
      .result_free(free_rows[r]),.result_reserved(reserved_rows[r]),.result_returned(returned_rows[r]),
      .trace_free(trace_free[r]),.protocol_error(protocol[r]));
  end
  always_ff @(posedge ap_clk) begin
    if(ap_rst) begin
      phase<=IDLE;owner_q<=0;aq_q<=0;wq_q<=0;sa_q<=0;sw_q<=0;old_q<=0;next_q<=0;
      masks_q<=0;status_q<=0;group_q<=0;tile_q<=0;sequence_q<=0;active_rows<=0;
      received<=0;bad_q<=0;phases_q<=0;
    end else if(ap_ce) begin
      case(phase)
        IDLE: if(ap_start) begin
          owner_q<=@OWNER@;aq_q<=@AQ@;wq_q<=@WQ@;sa_q<=@SA@;sw_q<=@SW@;
          old_q<=@OLD@;next_q<=@OLD@;masks_q<=lane_masks;group_q<=group[6:0];
          tile_q<=tile[9:0];sequence_q<=sequence[26:0];
          for(int r=0;r<4;r++) active_rows[r]<=|lane_masks[r*8 +:8];
          received<=0;bad_q<=0;phases_q<={32{3'd4}};
          if(group>127 || tile>655 || sequence>32'h7ffffff) begin status_q<=2;phase<=REPORT;end
          else begin status_q<=0;phase<=ISSUE;end
        end
        ISSUE: if(issue_fire) phase<=DRAIN;
        DRAIN: begin
          for(int r=0;r<4;r++) if(commit_valid[r]) begin
            if(!active_rows[r] || received[r] || commit_tile[r]!=tile_q || commit_mask[r]!=masks_q[r*8 +:8] ||
               commit_tag[r][159:64]!=request_tag[159:64] || commit_tag[r][62:36]!=sequence_q ||
               {commit_tag[r][160],commit_tag[r][16:11]}!=group_q ||
               commit_tag[r][27:26]!=r || commit_tag[r][167:164]!=1 || commit_tag[r][191:168]!=0)
              status_q<=2;
            received[r]<=1;next_q[r*256 +:256]<=commit_ps[r];
            bad_q[r*8 +:8]<=commit_bad[r];phases_q[r*24 +:24]<=commit_phase[r];
          end
          if((received&active_rows)==active_rows && all_free) begin
            if(|protocol)status_q<=2;
            else if(status_q==0 && |bad_q)status_q<=1;
            phase<=REPORT;
          end
        end
        REPORT: if(ap_continue) phase<=IDLE;
      endcase
    end
  end
endmodule
'''.replace("@PORTS@",",\n  ".join(ports))
# Keep the C argument name while avoiding the SystemVerilog keyword on RTL.
rtl=rtl.replace("sequence[", "issue_sequence[").replace(" sequence>", " issue_sequence>")
assigns=[f"assign echo{i}=owner_q[{64*i} +:64];" for i in range(16)] + [
 f"assign next{i}=next_q[{32*i} +:32];" for i in range(32)]
assigns += [f"assign bad{i}={{24'd0,bad_q[{8*i} +:8]}};assign phases{i}={{8'd0,phases_q[{24*i} +:24]}};" for i in range(4)]
assigns += ["assign status=status_q;"]+[f"assign {n}_ap_vld=phase==REPORT;" for n,_ in outputs]
rtl=rtl.replace("@OUTPUTS@","\n  ".join(assigns))
for field,count in (("OWNER",16),("AQ",16),("WQ",32),("SA",4),("SW",8),("OLD",32)):
 rtl=rtl.replace("@"+field+"@","{"+",".join(field.lower()+str(i) for i in range(count-1,-1,-1))+"}")
(OUT/"laya_tm4_group_service.sv").write_text(rtl)
common=json.loads((OUT/"laya_quant_group_service.json").read_text())["rtl_common_signal"]
params=[{"c_name":n,"c_port_direction":"in","rtl_ports":{"data_read_in":"issue_sequence" if n == "sequence" else n}} for n,_ in inputs]
params += [{"c_name":n,"c_port_direction":"out","rtl_ports":{"data_write_out":n,"data_write_valid":n+"_ap_vld"}} for n,_ in outputs]
deps=[MODULE/"rtl"/(n+".sv") for n in ("tm1tn8_integer_tree_lut","tm1tn8_signed_pack_pair","tm1tn8_integer_tree_packed",
 "tm4tn8_tag_v1","tm4tn8_reserved_store_v1","tm4tn8_fp_restore_v1","tm4tn8_row_pipeline_v1")]
bb=dict(c_function_name="laya_tm4_group_service",rtl_top_module_name="laya_tm4_group_service",
 c_files=[{"c_file":str(OUT/"laya_tm4_group_service.cpp"),"cflag":"-I"+str(ROOT/"include")+" -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"}],
 rtl_files=[str(p) for p in deps]+[str(OUT/"laya_tm4_group_service.sv")],c_parameters=params,rtl_common_signal=common,
 rtl_performance={"latency":"1","II":"1"},
 rtl_resource_usage={"FF":"65536","LUT":"65536","BRAM":"64","URAM":"0","DSP":"256"})
(OUT/"laya_tm4_group_service.json").write_text(json.dumps(bb,indent=2)+"\n")
smoke='#include "laya_tm4_group_service.h"\nvoid laya_tm4_blackbox_smoke(const uint64_t input[112],uint64_t output[57]) {\n'
smoke+='\n'.join(f'  uint{w}_t {n}=0;' for n,w in outputs)+'\n  laya_tm4_group_service('+',\n    '.join(
 [f'input[{i}]' for i in range(len(inputs))]+[n for n,_ in outputs])+');\n'
smoke+='\n'.join(f'  output[{i}]={n};' for i,(n,_) in enumerate(outputs))+'\n}\n'
(OUT/"laya_tm4_blackbox_smoke.cpp").write_text(smoke)
print("TM4_BLACKBOX_SOURCES_GENERATED explicit_inputs=112 explicit_outputs=57 full_owner_bits=1024 actual_row_pipelines=4")
