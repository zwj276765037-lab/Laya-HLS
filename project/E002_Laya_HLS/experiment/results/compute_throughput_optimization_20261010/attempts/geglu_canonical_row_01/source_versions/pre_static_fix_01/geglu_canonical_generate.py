#!/usr/bin/env python3
"""Wire original GEGLU 7M/2A around the verified canonical tanh service."""
import json
from pathlib import Path
import sys
from tanh_libm_canonical_generate import Graph

m=Path(sys.argv[1]).resolve();g=Graph()
g.declare('x_bits',32,1);g.declare('g_bits',32,1)
g.lines+=[' always @(posedge clk) x_bits<=in_x;',' always @(posedge clk) g_bits<=in_g;']
g.bit('g_finite',1,"(g_bits & 32'h7f800000)!=32'h7f800000",('g_bits',),2)
g.bit('x_finite',1,"(x_bits & 32'h7f800000)!=32'h7f800000",('x_bits',),2)
g.bit('p0',1,"(g_bits & 32'h7f800000)!=32'h7f800000 && (x_bits & 32'h7f800000)!=32'h7f800000",('g_bits','x_bits'),2)
g.fp('mul',100,"32'h3d372713",(),"p0 ? x_bits : 32'b0",('p0','x_bits'),16)
g.bit('p1',1,"p0 && (mul100 & 32'h7f800000)!=32'h7f800000",('p0','mul100'),17)
g.fp('mul',101,"p1 ? mul100 : 32'b0",('p1','mul100'),"p1 ? x_bits : 32'b0",('p1','x_bits'),31)
g.bit('p2',1,"p1 && (mul101 & 32'h7f800000)!=32'h7f800000",('p1','mul101'),32)
g.fp('add',100,"32'h3f800000",(),"p2 ? mul101 : 32'b0",('p2','mul101'),38)
g.bit('p3',1,"p2 && (add100 & 32'h7f800000)!=32'h7f800000",('p2','add100'),39)
g.fp('mul',102,"32'h3f4c422a",(),"p3 ? x_bits : 32'b0",('p3','x_bits'),53)
g.bit('p4',1,"p3 && (mul102 & 32'h7f800000)!=32'h7f800000",('p3','mul102'),54)
g.fp('mul',103,"p4 ? mul102 : 32'b0",('p4','mul102'),"p4 ? add100 : 32'b0",('p4','add100'),68)
g.bit('p5',1,"p4 && (mul103 & 32'h7f800000)!=32'h7f800000",('p4','mul103'),69)
g.declare('h',32,453,registered=False)
h_input=g.expression("p5 ? mul103 : 32'b0",('p5','mul103'),69)
g.lines += [' wire tanh_commit_valid;wire [31:0] tanh_status;',
            f" tanh_libm_canonical_core tanh_service(.clk(clk),.reset(reset),.in_valid(valid_pipe[68]),.in_data({h_input}),.commit_valid(tanh_commit_valid),.result(h),.status(tanh_status));"]
g.bit('p6',1,"p5 && (h & 32'h7f800000)!=32'h7f800000",('p5','h'),454)
g.fp('add',101,"32'h3f800000",(),"p6 ? h : 32'b0",('p6','h'),460)
g.bit('p7',1,"p6 && (add101 & 32'h7f800000)!=32'h7f800000",('p6','add101'),461)
g.fp('mul',104,"32'h3f000000",(),"p7 ? x_bits : 32'b0",('p7','x_bits'),475)
g.bit('p8',1,"p7 && (mul104 & 32'h7f800000)!=32'h7f800000",('p7','mul104'),476)
g.fp('mul',105,"p8 ? mul104 : 32'b0",('p8','mul104'),"p8 ? add101 : 32'b0",('p8','add101'),490)
g.bit('p9',1,"p8 && (mul105 & 32'h7f800000)!=32'h7f800000",('p8','mul105'),491)
g.fp('mul',106,"p9 ? mul105 : 32'b0",('p9','mul105'),"p9 ? g_bits : 32'b0",('p9','g_bits'),505)
last_deps=('p9','mul106')
success="p9 && (mul106 & 32'h7f800000)!=32'h7f800000"
g.bit('selected_data',32,f"({success}) ? mul106 : 32'b0",last_deps,506)
g.bit('selected_status',32,f"({success}) ? 32'd0 : 32'd1",last_deps,506)
g.bit('failed_step',32,"!g_finite ? 32'd10 : (!x_finite ? 32'd11 : (!p1 ? 32'd0 : (!p2 ? 32'd1 : (!p3 ? 32'd2 : (!p4 ? 32'd3 : (!p5 ? 32'd4 : (!p6 ? 32'd5 : (!p7 ? 32'd6 : (!p8 ? 32'd7 : (!p9 ? 32'd8 : ((mul106 & 32'h7f800000)==32'h7f800000 ? 32'd9 : 32'hffffffff))))))))))",('g_finite','x_finite',*(f'p{i}' for i in range(1,10)),'mul106'),506)
text="// Original GEGLU 7 separate F32 multiplies, 2 adds, canonical tanh; no FMA.\n"
text+="module geglu_canonical_core(input wire clk,reset,in_valid,input wire [31:0] in_x,in_g,output wire commit_valid,output wire [31:0] data,status,failed);\n reg [505:0] valid_pipe;\n always @(posedge clk)begin if(reset)valid_pipe<=0;else valid_pipe<={valid_pipe[504:0],in_valid};end\n assign commit_valid=!reset && valid_pipe[505];\n"
text+=g.emit()+"\n assign data=selected_data;assign status=selected_status;assign failed=failed_step;\nendmodule\n"
(m/'rtl/geglu_canonical_core.sv').write_text(text)
schedule={'schema':'laya-geglu-canonical-edges-v1','commit_edge':506,'tanh_accept_edge':69,'tanh_consumer_edge':453,
          'external_nodes':g.nodes,'step_signals':[{'name':n,'edge':c} for n,c in [('mul100',16),('mul101',31),('add100',38),('mul102',53),('mul103',68),('h',453),('add101',460),('mul104',475),('mul105',490),('mul106',505)]],
          'predicates':[vars(g.signals['p'+str(i)]) for i in range(10)],
          'scope':'Static schedule, not measured RTL service or Fmax; requires actual whole-row verification'}
(m/'tb/geglu_canonical_schedule.json').write_text(json.dumps(schedule,indent=2,sort_keys=True)+'\n')
print('TANH_LIBM_GEGLU_CANONICAL_GENERATE_PASS external_mul=7 external_add=2 tanh=1 commit_edge=506')
