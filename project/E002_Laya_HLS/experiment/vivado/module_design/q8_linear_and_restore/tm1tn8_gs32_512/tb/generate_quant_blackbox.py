#!/usr/bin/env python3
"""Emit the explicit scalar-port adapter for the actual quant16 row engine."""
import json
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
OUT = MODULE / "source/blackbox"
OUT.mkdir(parents=True, exist_ok=True)

inputs = [("owner" + str(i), 64) for i in range(14)] + \
         [("x" + str(i), 64) for i in range(16)] + [("row", 32)]
outputs = [("echo" + str(i), 64) for i in range(14)] + \
          [("q" + str(i), 64) for i in range(4)] + \
          [(name, 32) for name in ("scale", "d_full", "reciprocal", "status", "bad_col")]
signature = "void laya_quant_group_service(\n  " + ",\n  ".join(
    [f"uint{width}_t {name}" for name, width in inputs] +
    [f"uint{width}_t &{name}" for name, width in outputs]) + ")"
(OUT / "laya_quant_group_service.h").write_text("#pragma once\n#include <cstdint>\n" + signature + ";\n")
body = '''#include "laya_quant_group_service.h"
#include "laya_numeric.h"
#include <cmath>

@SIGNATURE@ {
#pragma HLS inline off
  @ECHO@
  q0=q1=q2=q3=0; scale=d_full=reciprocal=status=0; bad_col=UINT32_MAX;
  const uint64_t packed[16] = {@X@};
  float values[32], amax=0;
  for (unsigned i=0;i<32;++i) {
    values[i]=laya::numeric_bits_f32(uint32_t(packed[i/2] >> (32*(i%2))));
    if ((laya::numeric_f32_bits(values[i]) & 0x7f800000u)==0x7f800000u) {
      status=1;bad_col=i;return;
    }
    if (::fabsf(values[i])>amax) amax=::fabsf(values[i]);
  }
  const float d=amax/127.0f;
  const float r=d==0.0f ? 0.0f : 1.0f/d;
  d_full=laya::numeric_f32_bits(d);reciprocal=laya::numeric_f32_bits(r);
  scale=laya::numeric_f32_to_half_rne(d);
  if ((d_full&0x7f800000u)==0x7f800000u ||
      (reciprocal&0x7f800000u)==0x7f800000u || (scale&0x7c00u)==0x7c00u) {
    status=1;bad_col=0;return;
  }
  uint64_t packed_q[4]={};
  for (unsigned i=0;i<32;++i) {
    const float product=d==0.0f ? 0.0f : values[i]*r;
    const float rounded=::roundf(product);
    if ((laya::numeric_f32_bits(product)&0x7f800000u)==0x7f800000u ||
        (laya::numeric_f32_bits(rounded)&0x7f800000u)==0x7f800000u ||
        rounded < -127.0f || rounded > 127.0f) {status=1;bad_col=i;return;}
    packed_q[i/8] |= uint64_t(uint8_t(int8_t(rounded))) << (8*(i%8));
  }
  q0=packed_q[0];q1=packed_q[1];q2=packed_q[2];q3=packed_q[3];
}
'''.replace("@SIGNATURE@", signature).replace("@ECHO@", ";".join(
    f"echo{i}=owner{i}" for i in range(14)) + ";").replace("@X@", ",".join(f"x{i}" for i in range(16)))
(OUT / "laya_quant_group_service.cpp").write_text(body)
ports = ["input wire ap_clk,ap_rst,ap_ce,ap_start,ap_continue",
         "output wire ap_idle,ap_ready,ap_done"]
ports += [f"input wire [{width-1}:0] {name}" for name, width in inputs]
for name, width in outputs:
    ports += [f"output wire [{width-1}:0] {name}", f"output wire {name}_ap_vld"]
rtl = '''`timescale 1ns/1ps
// Actual quant16 engine. Full NumericIdentity/TaskContext/source/A refs are
// held in owner_q until the physical arithmetic and output debts retire.
module laya_quant_group_service (
  @PORTS@
);
  typedef enum logic [2:0] {IDLE,START,FEED0,FEED1,DRAIN,REPORT} phase_t;
  phase_t phase;
  logic [895:0] owner_q;
  logic [1023:0] source_q;
  logic [15:0] row_q;
  logic start_ready,in_ready,out_valid,out_half,done_valid;
  logic [6:0] out_group;
  logic [127:0] out_q;
  logic [15:0] out_scale,first_bad_col;
  logic [31:0] out_d_full,out_reciprocal;
  logic [1:0] done_status;
  logic [31:0] accepted,covered,si,sr,ri,rr,ar,br,mi,mr;
  logic [1:0] received;
  logic [255:0] q_result;
  logic [31:0] scale_q,d_q,reciprocal_q,status_q,bad_q;
  assign ap_idle=phase==IDLE;
  assign ap_ready=phase==REPORT && ap_continue && ap_ce;
  assign ap_done=phase==REPORT;
  @OUTPUTS@
  quant16_stream_row quant (
    .clk(ap_clk),.rst(ap_rst),.start_valid(phase==START && ap_ce),.start_ready,
    .cfg_task_id(owner_q[703:672]),.cfg_source_epoch(owner_q[799:768]),
    .cfg_row(row_q),.cfg_groups(8'd1),
    .in_valid((phase==FEED0 || phase==FEED1) && ap_ce),.in_ready,
    .in_lanes(phase==FEED1 ? source_q[1023:512] : source_q[511:0]),
    .in_task_id(owner_q[703:672]),.in_source_epoch(owner_q[799:768]),
    .in_row(row_q),.in_group(7'd0),.in_half(phase==FEED1),.in_mask(16'hffff),
    .out_valid,.out_ready(phase==DRAIN && ap_ce),.out_group,.out_half,.out_q,
    .out_scale,.out_d_full,.out_reciprocal,.done_valid,
    .done_ready(phase==DRAIN && ap_ce),.done_status,.first_bad_col,
    .accepted_groups(accepted),.covered_groups(covered),.scale_issues(si),
    .scale_returns(sr),.recip_issues(ri),.recip_returns(rr),
    .amax_read_beats(ar),.replay_read_beats(br),.mul_halves_issued(mi),
    .mul_halves_returned(mr));
  always_ff @(posedge ap_clk) begin
    if(ap_rst) begin
      phase<=IDLE;owner_q<=0;source_q<=0;row_q<=0;received<=0;q_result<=0;
      scale_q<=0;d_q<=0;reciprocal_q<=0;status_q<=0;bad_q<='1;
    end else if(ap_ce) begin
      case(phase)
        IDLE: if(ap_start) begin
          owner_q<=@OWNER@;source_q<=@SOURCE@;row_q<=row[15:0];
          received<=0;q_result<=0;scale_q<=0;d_q<=0;reciprocal_q<=0;
          status_q<=0;bad_q<='1;phase<=START;
        end
        START: if(start_ready) phase<=FEED0;
        FEED0: if(in_ready) phase<=FEED1;
        FEED1: if(in_ready) phase<=DRAIN;
        DRAIN: begin
          if(out_valid) begin
            if(out_group!=0 || out_half!=received[0]) status_q<=2;
            q_result[out_half*128 +:128]<=out_q;received<=received+1;
            if(out_half) begin scale_q<={16'd0,out_scale};d_q<=out_d_full;reciprocal_q<=out_reciprocal;end
          end
          if(done_valid) begin
            if(done_status!=0) begin status_q<={30'd0,done_status};bad_q<={16'd0,first_bad_col};end
            else if(received!=2 || accepted!=1 || covered!=1 || si!=sr || ri!=rr || mi!=mr)
              status_q<=2;
            phase<=REPORT;
          end
        end
        REPORT: if(ap_continue) phase<=IDLE;
        default: phase<=IDLE;
      endcase
    end
  end
endmodule
'''.replace("@PORTS@", ",\n  ".join(ports))
assigns = [f"assign echo{i}=owner_q[{i*64} +:64];" for i in range(14)]
assigns += [f"assign q{i}=q_result[{i*64} +:64];" for i in range(4)]
assigns += [f"assign {a}={b};" for a,b in
            (("scale","scale_q"),("d_full","d_q"),("reciprocal","reciprocal_q"),
             ("status","status_q"),("bad_col","bad_q"))]
assigns += [f"assign {name}_ap_vld=phase==REPORT;" for name,_ in outputs]
rtl = rtl.replace("@OUTPUTS@", "\n  ".join(assigns)).replace("@OWNER@", "{" + ",".join(
    f"owner{i}" for i in range(13,-1,-1)) + "}").replace("@SOURCE@", "{" + ",".join(
    f"x{i}" for i in range(15,-1,-1)) + "}")
(OUT / "laya_quant_group_service.sv").write_text(rtl)
params = [{"c_name":name,"c_port_direction":"in","rtl_ports":{"data_read_in":name}}
          for name,_ in inputs]
params += [{"c_name":name,"c_port_direction":"out",
            "rtl_ports":{"data_write_out":name,"data_write_valid":name+"_ap_vld"}}
           for name,_ in outputs]
common = dict(module_clock="ap_clk",module_reset="ap_rst",module_clock_enable="ap_ce",
              ap_ctrl_chain_protocol_idle="ap_idle",ap_ctrl_chain_protocol_start="ap_start",
              ap_ctrl_chain_protocol_ready="ap_ready",ap_ctrl_chain_protocol_done="ap_done",
              ap_ctrl_chain_protocol_continue="ap_continue")
dependencies = [ROOT / "vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv"]
dependencies += [ROOT / "vivado/module_design/activation_quantizer/rtl" / (name + ".sv") for name in
                 ("quant16_slot_banks","quant16_amax16","quant16_half_rne","quant16_tiny_div127",
                  "quant16_divider_service","quant16_stream_row")]
model = dict(c_function_name="laya_quant_group_service",rtl_top_module_name="laya_quant_group_service",
             c_files=[{"c_file":str(OUT/"laya_quant_group_service.cpp"),"cflag":"-I"+str(ROOT/"include")+" -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"}],
             rtl_files=[str(p) for p in dependencies]+[str(OUT/"laya_quant_group_service.sv")],
             c_parameters=params,rtl_common_signal=common,
             rtl_performance={"latency":"1","II":"1"},
             rtl_resource_usage={"FF":"16384","LUT":"16384","BRAM":"32","URAM":"0","DSP":"48"})
(OUT / "laya_quant_group_service.json").write_text(json.dumps(model,indent=2)+"\n")
arguments = [f"input[{i}]" for i in range(len(inputs))] + [name for name,_ in outputs]
smoke = '''#include "laya_quant_group_service.h"
void laya_quant_blackbox_smoke(const uint64_t input[31], uint64_t output[23]) {
@DECL@
  laya_quant_group_service(@ARGS@);
@WRITE@
}
'''.replace("@DECL@", "\n".join(f"  uint{width}_t {name}=0;" for name,width in outputs))
smoke = smoke.replace("@ARGS@", ",\n    ".join(arguments)).replace("@WRITE@", "\n".join(
    f"  output[{i}]={name};" for i,(name,_) in enumerate(outputs)))
(OUT / "laya_quant_blackbox_smoke.cpp").write_text(smoke)
(OUT / "annotations.json").write_text(json.dumps({"schema":"laya-rtl-blackbox-annotations-v1",
  "resource_and_latency_scope":"Minimal HLS scheduling lower bounds for variable-latency real ap_done wait; not measured resources, service latency, or throughput.",
  "full_owner_layout":"NumericIdentity bits0..671; TaskContext bits672..767; source BufferRef bits768..831; A BufferRef bits832..895",
  "numeric_scope":"one complete Group32 of one already published row; actual quant16_stream_row with cfg_groups=1",
  "publication_scope":"full production controller retains the A FILLING owner across all group calls; no Group32 service call can publish A READY",
  "floating_ip_dependency":"actual two generated FP IPs must be created with the frozen quant16_hls_syn_03 IP Tcl before Vivado simulation/OOC",
  "current_status":"PREPARED_NOT_SYNTHESIZED_NOT_PRODUCTION_BOUND"},indent=2)+"\n")
print("QUANT_BLACKBOX_SOURCES_GENERATED explicit_inputs=31 explicit_outputs=23 owner_bits=896")
