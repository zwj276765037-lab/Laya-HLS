#!/usr/bin/env python3
"""Retiming only: invoke the frozen original graph with real fast arithmetic."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--adder',choices=('z','o','e'),default='z');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
 add_module='laya_m007_tanh_add3_'+a.adder+'_v1'
 original=MODULE/'tb/tanh_libm_canonical_generate.py';digest=hashlib.sha256(original.read_bytes()).hexdigest();assert digest=='cb80cbd4832f21817a0d5f7bf9b1d9fc187e857f2d73fdba94678e69a20512e5'
 spec=importlib.util.spec_from_file_location('original_graph',original);m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)
 class FastGraph(m.Graph):
  def bit(self,name,width,expression,deps,edge,signed=False):return super().bit(name,width,expression,deps,max(self.signals[d].edge for d in deps)+1,signed)
  def fp(self,op,index,a,ad,b,bd,expected_edge):
   name=f'{op}{index}';launch=max((self.signals[d].edge for d in(*ad,*bd)),default=0);lat={'add':3,'mul':4,'div':12}[op]
   ae=self.expression(a,ad,launch);be=self.expression(b,bd,launch);safe="32'h3f800000"if op in('mul','div')else"32'b0"
   self.signals[name]=m.Signal(name,32,launch+lat)
   implementation={'add':add_module,'mul':'laya_m007_tanh_mul4_v1','div':'laya_m007_tanh_div12_r4_v1'}[op]
   self.lines.extend([f' wire [31:0] {name};',f' {implementation} {name}_kernel(.aclk(clk),.aclken(1\'b1),.aresetn(!reset),',
    f'  .s_axis_a_tvalid(valid_pipe[{launch-1}]),.s_axis_b_tvalid(valid_pipe[{launch-1}]),',
    f'  .s_axis_a_tdata(valid_pipe[{launch-1}] ? ({ae}) : 32\'b0),.s_axis_b_tdata(valid_pipe[{launch-1}] ? ({be}) : {safe}),',f'  .m_axis_result_tvalid(),.m_axis_result_tdata({name}));'])
   self.nodes.append({'name':name,'op':op,'implementation':implementation,'launch_edge':launch,'consumer_edge':launch+lat,'latency':lat,'original_consumer_edge':expected_edge,'a_expression':a,'b_expression':b,'a_sources':list(ad),'b_sources':list(bd)})
 m.Graph=FastGraph;g,_,_=m.create_graph();edge=g.signals['selected_result'].edge;assert edge==152
 g.alignments.pop('selected_result',None);g.alignments.pop('selected_status',None)
 core=f'''// tanhf/expm1f graph adapted from glibc2.39 sysdeps/ieee754/flt-32.
// Copyright (C)1993 by Sun Microsystems, Inc. All rights reserved.
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this software is freely
// granted, provided that this notice is preserved.
// Generated from original cb80cbd4...; independent F32 nodes unchanged.
module laya_m007_tanh_core_v1(input wire clk,reset,in_valid,input wire [31:0] in_data,
 output wire commit_valid,output wire [31:0] result,status);
 reg [{edge-1}:0] valid_pipe;
 always @(posedge clk)if(reset)valid_pipe<=0;else valid_pipe<={{valid_pipe[{edge-2}:0],in_valid}};
 assign commit_valid=!reset&&valid_pipe[{edge-1}];
'''+m.FUNCTIONS+g.emit()+'''\n assign result=selected_result;assign status=selected_status;
endmodule
module laya_m007_tanh_lane_v1(
 input wire clk,reset,input wire in_valid,output wire in_ready,
 input wire [31:0] in_data,input wire [95:0] in_tag,
 output wire out_valid,input wire out_ready,output wire [31:0] out_data,out_status,
 output wire [95:0] out_tag,output wire [8:0] pending,in_flight
);
 reg [31:0] result_mem[0:255],status_mem[0:255];reg [95:0] tag_mem[0:255];
 reg [7:0] reserve_ptr,produce_ptr,consume_ptr;reg [8:0] credits,returned,flight;
 wire accept=in_valid&&in_ready;wire consume=out_valid&&out_ready;
 wire commit_valid;wire [31:0] result,status;
 assign in_ready=!reset&&credits<256;assign out_valid=!reset&&returned!=0;
 assign out_data=result_mem[consume_ptr];assign out_status=status_mem[consume_ptr];assign out_tag=tag_mem[consume_ptr];
 assign pending=credits;assign in_flight=flight;
 laya_m007_tanh_core_v1 core(.clk,.reset,.in_valid(accept),.in_data,.commit_valid,.result,.status);
 always @(posedge clk)begin
  if(reset)begin reserve_ptr<=0;produce_ptr<=0;consume_ptr<=0;credits<=0;returned<=0;flight<=0;end
  else begin
   case({accept,consume})2'b10:credits<=credits+1'b1;2'b01:credits<=credits-1'b1;endcase
   case({commit_valid,consume})2'b10:returned<=returned+1'b1;2'b01:returned<=returned-1'b1;endcase
   case({accept,commit_valid})2'b10:flight<=flight+1'b1;2'b01:flight<=flight-1'b1;endcase
   if(accept)begin tag_mem[reserve_ptr]<=in_tag;reserve_ptr<=reserve_ptr+1'b1;end
   if(commit_valid)begin result_mem[produce_ptr]<=result;status_mem[produce_ptr]<=status;produce_ptr<=produce_ptr+1'b1;end
   if(consume)consume_ptr<=consume_ptr+1'b1;
  end
 end
endmodule
'''
 target=MODULE/'rtl/laya_m007_tanh_lane_v1.sv';target.write_text(core)
 schedule={'original_generator_sha256':digest,'selected_result_edge':edge,'wrapper_fifo_depth':256,'tag_bits':96,'fp_node_counts':{'add':23,'mul':17,'div':2},'nodes':g.nodes,'signals':[vars(s)for s in g.signals.values()],'generated_rtl_sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'leaf_sources_sha256':{n:hashlib.sha256((MODULE/'rtl'/n).read_bytes()).hexdigest()for n in('laya_m007_tanh_fast_leaves_v1.sv',add_module+'.sv','laya_m007_tanh_div12_r4_v1.sv')}}
 (a.output/'schedule.json').write_text(json.dumps(schedule,indent=2)+'\n');(a.output/'laya_m007_tanh_lane_v1.sv').write_text(core)
 print('M007_TANH_ORIGINAL_GRAPH_GENERATED selected_edge152 nodes42',flush=True)
if __name__=='__main__':main()
