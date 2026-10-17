#!/usr/bin/env python3
"""Generate the exact §8.4.9 graph with explicit static synchronous edges."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
from dataclasses import dataclass


@dataclass
class Signal:
    name: str
    width: int
    edge: int
    signed: bool = False


class Graph:
    def __init__(self):
        self.signals = {}
        self.lines = []
        self.alignments = {}
        self.nodes = []

    def declare(self, name, width, edge, expression=None, deps=(), registered=True, signed=False):
        assert name not in self.signals
        if expression is not None:
            launch = max((self.signals[d].edge for d in deps), default=0)
            assert edge == launch + int(registered), (name, edge, launch)
            expression = self.expression(expression, deps, launch)
        typ = "reg" if registered else "wire"
        sign = " signed" if signed else ""
        self.lines.append(f" {typ}{sign} [{width-1}:0] {name};")
        self.signals[name] = Signal(name, width, edge, signed)
        if expression is not None:
            self.lines.append(f" always @(posedge clk) {name} <= {expression};" if registered
                              else f" assign {name} = {expression};")
        return name

    def aligned(self, name, edge):
        sig = self.signals[name]
        assert edge >= sig.edge, (name, edge, sig.edge)
        if edge == sig.edge:
            return name
        self.alignments[name] = max(self.alignments.get(name, sig.edge), edge)
        return f"{name}_at_{edge}"

    def expression(self, text, deps, edge):
        for name in sorted(deps, key=len, reverse=True):
            text = re.sub(r"\b" + re.escape(name) + r"\b", self.aligned(name, edge), text)
        return text

    def bit(self, name, width, expression, deps, edge, signed=False):
        return self.declare(name, width, edge, expression, deps, signed=signed)

    def fp(self, op, index, a, a_deps, b, b_deps, expected_edge):
        name = f"{op}{index}"
        launch = max((self.signals[d].edge for d in (*a_deps, *b_deps)), default=0)
        latency = {"add": 6, "mul": 14, "div": 12}[op]
        assert launch + latency == expected_edge, (name, launch, expected_edge)
        a = self.expression(a, a_deps, launch)
        b = self.expression(b, b_deps, launch)
        safe_b = "32'h3f800000" if op in ("mul", "div") else "32'b0"
        self.lines += [f" wire {name}_issue_valid = valid_pipe[{launch-1}];",
                       f" wire [31:0] {name}_a = {name}_issue_valid ? ({a}) : 32'b0;",
                       f" wire [31:0] {name}_b = {name}_issue_valid ? ({b}) : {safe_b};",
                       f" wire [31:0] {name};"]
        self.signals[name] = Signal(name, 32, expected_edge)
        canonical = {"add": "add_node_0", "mul": "mul_node_14", "div": "div_node_0"}[op]
        module = "tanh_libm_stream_leaf_stream_" + canonical + "_s"
        self.lines.append(f" {module} {name}_kernel(.ap_clk(clk),.ap_rst(reset),.ap_ce(1'b1),"
                          f".a({name}_a),.b({name}_b),.ap_return({name}));")
        self.nodes.append({"name": name, "op": op, "index": index, "module": module,
                           "instance": "core/" + name + "_kernel", "launch_edge": launch,
                           "consumer_edge": expected_edge, "after_nba_latency": latency-1,
                           "a_expression": a, "b_expression": b,
                           "a_sources": list(a_deps), "b_sources": list(b_deps)})

    def emit(self):
        declarations, assignments = [], []
        for name, edge in sorted(self.alignments.items()):
            sig = self.signals[name]
            previous = name
            for c in range(sig.edge+1, edge+1):
                current = f"{name}_at_{c}"
                signed = " signed" if sig.signed else ""
                declarations.append(f" reg{signed} [{sig.width-1}:0] {current};")
                assignments.append(f" always @(posedge clk) {current} <= {previous};")
                previous = current
        return "\n".join(declarations + self.lines + assignments)


FUNCTIONS = r"""
 function automatic signed [31:0] to_int_bits(input [31:0] value);
  integer exponent;
  reg [31:0] mantissa, magnitude;
  begin
   exponent = {24'b0,value[30:23]} - 127;
   mantissa = {8'b0,1'b1,value[22:0]};
   magnitude = exponent < 0 ? 0 : mantissa >> (23-exponent);
   to_int_bits = value[31] ? -$signed(magnitude) : $signed(magnitude);
  end
 endfunction
 function automatic [31:0] from_int_bits(input signed [31:0] value);
  reg [31:0] magnitude, significand, remainder;
  reg sign;
  integer i, leading, shift, exponent;
  begin
   sign = value < 0;
   magnitude = sign ? -value : value;
   leading=0;
   for(i=0;i<32;i=i+1) if(magnitude[i]) leading=i;
   exponent=leading+127;
   if(leading<=23) significand=magnitude << (23-leading);
   else begin
    shift=leading-23; significand=magnitude >> shift;
    remainder=magnitude & ((32'b1 << shift)-1);
    if(remainder>(32'b1 << (shift-1)) ||
       (remainder==(32'b1 << (shift-1)) && significand[0]))
       significand=significand+1;
    if(significand[24]) begin significand=significand>>1; exponent=exponent+1; end
   end
   from_int_bits = magnitude==0 ? 0 : {sign,exponent[7:0],significand[22:0]};
  end
 endfunction
"""


def create_graph():
    g=Graph()
    g.declare("input_bits",32,1)
    g.lines.append(" always @(posedge clk) input_bits <= in_data;")
    g.bit("sign",32,"input_bits & 32'h80000000",("input_bits",),2)
    g.bit("abs",32,"input_bits & 32'h7fffffff",("input_bits",),2)
    g.bit("core_branch",1,"(input_bits & 32'h7fffffff)>=32'h24000000 && (input_bits & 32'h7fffffff)<32'h41b00000",("input_bits",),2)
    g.bit("low",1,"(input_bits & 32'h7fffffff)<32'h3f800000",("input_bits",),2)
    g.fp("mul",0,"low ? 32'hc0000000 : 32'h40000000",("low",),"core_branch ? abs : 32'b0",("core_branch","abs"),16)
    g.bit("ya",32,"mul0 & 32'h7fffffff",("mul0",),17)
    g.bit("yn",1,"mul0[31]",("mul0",),17)
    g.bit("reduce",1,"(mul0 & 32'h7fffffff)>32'h3eb17218",("mul0",),17)
    g.bit("simple",1,"(mul0 & 32'h7fffffff)<32'h3f851592",("mul0",),17)
    g.fp("mul",1,"32'h3fb8aa3b",(),"mul0",("mul0",),30)
    g.fp("add",0,"mul1",("mul1",),"yn ? 32'hbf000000 : 32'h3f000000",("yn",),36)
    g.bit("k",32,"reduce ? (simple ? (yn ? -32'sd1 : 32'sd1) : to_int_bits(add0)) : 32'sd0",("reduce","simple","yn","add0"),37,signed=True)
    g.bit("fk",32,"from_int_bits(k)",("k",),38)
    g.fp("mul",2,"fk",("fk",),"32'h3f317180",(),52)
    g.fp("mul",3,"fk",("fk",),"32'h3717f7d1",(),52)
    g.fp("add",1,"mul0",("mul0",),"mul2 ^ 32'h80000000",("mul2",),58)
    g.fp("add",2,"add1",("add1",),"mul3 ^ 32'h80000000",("mul3",),64)
    g.bit("x",32,"reduce ? add2 : mul0",("reduce","add2","mul0"),65)
    g.fp("add",3,"add1",("add1",),"x ^ 32'h80000000",("x",),71)
    g.fp("add",4,"add3",("add3",),"mul3 ^ 32'h80000000",("mul3",),77)
    g.bit("c",32,"reduce ? add4 : 32'b0",("reduce","add4"),78)
    g.fp("mul",4,"32'h3f000000",(),"x",("x",),79)
    g.fp("mul",5,"x",("x",),"mul4",("mul4",),93)
    g.fp("mul",6,"mul5",("mul5",),"32'hb457edbb",(),107)
    g.fp("add",5,"32'h36867e54",(),"mul6",("mul6",),113)
    for mul,add,constant,mc,ac in [(7,6,"b8a670cd",127,133),(8,7,"3ad00d01",147,153),(9,8,"bd088889",167,173),(10,9,"3f800000",187,193)]:
        g.fp("mul",mul,"mul5",("mul5",),f"add{add-1}",(f"add{add-1}",),mc)
        g.fp("add",add,f"32'h{constant}",(),f"mul{mul}",(f"mul{mul}",),ac)
    g.fp("mul",11,"add9",("add9",),"mul4",("mul4",),207)
    g.fp("add",10,"32'h40400000",(),"mul11 ^ 32'h80000000",("mul11",),213)
    g.fp("mul",12,"x",("x",),"add10",("add10",),227)
    g.fp("add",11,"add9",("add9",),"add10 ^ 32'h80000000",("add10",),219)
    g.fp("add",12,"32'h40c00000",(),"mul12 ^ 32'h80000000",("mul12",),233)
    g.fp("div",0,"add11",("add11",),"add12",("add12",),245)
    g.fp("mul",13,"mul5",("mul5",),"div0",("div0",),259)
    g.fp("add",13,"mul13",("mul13",),"c ^ 32'h80000000",("c",),265)
    g.bit("mul14_operand",32,"k==0 ? mul13 : add13",("k","mul13","add13"),266)
    g.fp("mul",14,"x",("x",),"mul14_operand",("mul14_operand",),280)
    g.bit("add14_operand",32,"(k==0 ? mul5 : c) ^ 32'h80000000",("k","mul5","c"),94)
    g.fp("add",14,"mul14",("mul14",),"add14_operand",("add14_operand",),286)
    g.fp("add",15,"add14",("add14",),"mul5 ^ 32'h80000000",("mul5",),292)
    g.bit("e",32,"k==0 ? add14 : add15",("k","add14","add15"),293)
    g.bit("k1neg",1,"k==1 && x[31] && (x & 32'h7fffffff)>32'h3e800000",("k","x"),66)
    g.bit("forward_branch",1,"k==0 || k==-1 || (k==1 && !(x[31] && (x & 32'h7fffffff)>32'h3e800000))",("k","x"),66)
    g.bit("power",32,"k>=23 && k<=56 ? (32'd127-$unsigned(k)) << 23 : 32'b0",("k",),38)
    g.bit("rep_t",32,"k>=2 && k<23 ? 32'h3f800000-(32'h01000000 >> k) : 32'h3f800000",("k",),38)
    g.bit("factor",32,"k==-1 ? 32'h3f000000 : (k==1 ? (k1neg ? 32'hc0000000 : 32'h40000000) : 32'h3f800000)",("k","k1neg"),67)
    g.bit("outside",1,"k<=-2 || k>56",("k",),38)
    g.bit("final_bias",32,"k==-1 ? 32'hbf000000 : ((k==1 && !k1neg) || (k>=23 && k<=56) ? 32'h3f800000 : 32'hbf800000)",("k","k1neg"),67)
    g.bit("add16_operand_a",32,"forward_branch ? x : e",("forward_branch","x","e"),294)
    g.bit("add16_operand_b",32,"(forward_branch ? e : x) ^ 32'h80000000",("forward_branch","x","e"),294)
    g.fp("add",16,"add16_operand_a",("add16_operand_a",),"add16_operand_b",("add16_operand_b",),300)
    g.bit("add17_operand_a",32,"k1neg ? x : e",("k1neg","x","e"),294)
    g.bit("add17_operand_b",32,"k1neg ? 32'h3f000000 : power",("k1neg","power","e"),294)
    g.fp("add",17,"add17_operand_a",("add17_operand_a",),"add17_operand_b",("add17_operand_b",),300)
    g.bit("add18_operand_a",32,"k1neg ? e : (k>=23 ? x : rep_t)",("k1neg","e","k","x","rep_t","add17"),301)
    g.bit("add18_operand_b",32,"(k1neg || k>=23 ? add17 : add16) ^ 32'h80000000",("k1neg","k","add17","add16"),301)
    g.fp("add",18,"add18_operand_a",("add18_operand_a",),"add18_operand_b",("add18_operand_b",),307)
    g.bit("mul15_operand",32,"forward_branch ? add16 : add18",("forward_branch","add16","add18"),308)
    g.fp("mul",15,"factor",("factor",),"mul15_operand",("mul15_operand",),322)
    g.bit("scale_input",32,"outside ? mul15+($unsigned(k) << 23) : mul15",("outside","mul15","k"),323)
    g.fp("add",19,"scale_input",("scale_input",),"final_bias",("final_bias",),329)
    g.bit("rebuilt",32,"k==0 ? add16 : (k==-1 ? add19 : (k==1 ? (k1neg ? mul15 : add19) : (outside ? add19 : (k<23 ? mul15 : add19)+($unsigned(k) << 23))))",("k","add16","add19","k1neg","mul15","outside"),330)
    g.bit("exp_value",32,"ya<32'h33000000 ? mul0 : rebuilt",("ya","mul0","rebuilt"),331)
    g.fp("add",20,"exp_value",("exp_value",),"32'h40000000",(),337)
    g.bit("dtanh_numerator",32,"low ? exp_value ^ 32'h80000000 : 32'h40000000",("low","exp_value"),332)
    g.fp("div",1,"dtanh_numerator",("dtanh_numerator",),"add20",("add20",),349)
    g.fp("add",21,"32'h3f800000",(),"div1 ^ 32'h80000000",("div1",),355)
    g.bit("tiny_input",32,"abs>0 && abs<32'h24000000 ? input_bits : 32'b0",("abs","input_bits"),3)
    g.fp("add",22,"32'h3f800000",(),"tiny_input",("tiny_input",),9)
    g.fp("mul",16,"tiny_input",("tiny_input",),"add22",("add22",),23)
    g.bit("selected_result",32,"abs>=32'h7f800000 ? 32'b0 : (abs==0 ? input_bits : (abs<32'h24000000 ? mul16 : (core_branch ? (low ? div1 : add21) : 32'h3f800000) ^ sign))",("abs","input_bits","mul16","core_branch","low","div1","add21","sign"),356)
    g.bit("selected_status",32,"abs>=32'h7f800000 ? 32'd1 : 32'd0",("abs","add21"),356)
    result=g.aligned("selected_result",384)
    status=g.aligned("selected_status",384)
    return g,result,status


WRAPPER = r"""
module tanh_libm_canonical_wrapper(
 input wire clk,reset,input wire in_valid,output wire in_ready,
 input wire [31:0] in_data,in_tag,
 output wire out_valid,input wire out_ready,
 output wire [31:0] out_data,out_tag,out_status
);
 reg [31:0] result_mem[0:511],tag_mem[0:511],status_mem[0:511];
 reg [8:0] reserve_ptr,produce_ptr,consume_ptr;
 reg [9:0] credits,returned;
 wire accept=in_valid && in_ready;
 wire consume=out_valid && out_ready;
 wire commit_valid;
 wire [31:0] core_result,core_status;
 assign in_ready=!reset && credits<512;
 assign out_valid=!reset && returned!=0;
 assign out_data=result_mem[consume_ptr];
 assign out_tag=tag_mem[consume_ptr];
 assign out_status=status_mem[consume_ptr];
 tanh_libm_canonical_core core(.clk(clk),.reset(reset),.in_valid(accept),
  .in_data(in_data),.commit_valid(commit_valid),.result(core_result),.status(core_status));
 always @(posedge clk) begin
  if(reset) begin
   reserve_ptr<=0;produce_ptr<=0;consume_ptr<=0;credits<=0;returned<=0;
  end else begin
   case({accept,consume})
    2'b10:credits<=credits+1;
    2'b01:credits<=credits-1;
   endcase
   case({commit_valid,consume})
    2'b10:returned<=returned+1;
    2'b01:returned<=returned-1;
   endcase
   if(accept) begin tag_mem[reserve_ptr]<=in_tag;reserve_ptr<=reserve_ptr+1;end
   if(commit_valid) begin
    result_mem[produce_ptr]<=core_result;status_mem[produce_ptr]<=core_status;
    produce_ptr<=produce_ptr+1;
   end
   if(consume) consume_ptr<=consume_ptr+1;
  end
 end
endmodule
"""


def identity(path):
    data=path.read_bytes()
    return {"path":str(path.resolve()),"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest()}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source",type=Path)
    parser.add_argument("bottomup",type=Path)
    parser.add_argument("attempt",type=Path)
    parser.add_argument("module",type=Path)
    args=parser.parse_args()
    src=args.source.resolve();bottom=args.bottomup.resolve();a=args.attempt.resolve();module=args.module.resolve()
    a.mkdir();(a/"rtl").mkdir();(a/"frozen_source").mkdir();(a/"fixture").mkdir();(a/"ooc").mkdir()
    g,result,status=create_graph()
    text="// Same glibc/Sun tanhf graph and notice as frozen stream02 source.\n"+"// Generated static synchronous-edge graph; §8.4.9.\n"
    text+="module tanh_libm_canonical_core(input wire clk,reset,in_valid,input wire [31:0] in_data,output wire commit_valid,output wire [31:0] result,status);\n"
    text+=" reg [383:0] valid_pipe;\n always @(posedge clk) begin if(reset) valid_pipe<=0;else valid_pipe<={valid_pipe[382:0],in_valid};end\n assign commit_valid=!reset && valid_pipe[383];\n"
    text+=FUNCTIONS+g.emit()+f"\n assign result={result};\n assign status={status};\nendmodule\n"+WRAPPER
    out=module/"rtl/tanh_libm_canonical.sv";out.write_text(text);shutil.copy2(out,a/"frozen_source"/out.name)
    previous=json.loads((bottom/"source_manifest_v02.json").read_text())
    canonical=[n for n in previous["nodes"] if n["module"] in {"tanh_libm_stream_leaf_stream_add_node_0_s","tanh_libm_stream_leaf_stream_mul_node_14_s","tanh_libm_stream_leaf_stream_div_node_0_s"}]
    assert len(canonical)==3
    for n in canonical:
        for d in n["dependencies"]:
            path=Path(d["file"]["path"]);dest=a/"rtl"/path.name
            if not dest.exists():shutil.copy2(path,dest)
    for name in ("x.mem","gold.mem"):
        shutil.copy2(src/"fixture"/name,a/"fixture"/name)
    shutil.copy2(src/"cpu/ops_directed.mem",a/"fixture/ops_directed.mem")
    for name in ("tanh_libm_guard.py","tanh_libm_stream_bits.cpp","tanh_libm_stream_bits.h"):
        shutil.copy2(src/"frozen_source"/name,a/"frozen_source"/name)
    (a/"frozen_source/clock.xdc").write_text("create_clock -name ap_clk -period 6.666666667 [get_ports clk]\n")
    helper_dcp=bottom/"nodes/tanh_libm_stream_leaf_stream_add_node_0_s/child_synth.dcp"
    assert identity(helper_dcp)["sha256"]=="94da0b741f7476e1935079b1f027581a82f09ac9ec0565afc65cdc23e3ebe719"
    schedule={"schema":"laya-canonical-static-edges-v1","commit_edge":384,"first_consume_edge":385,
              "fp_nodes":g.nodes,"signals":[vars(s) for s in g.signals.values()],
              "helper_classes":canonical,"reused_add_dcp":identity(helper_dcp),
              "prior_bottomup_receipt":identity(bottom/"receipt.json"),
              "prior_cumulative_ooc_seconds":220.97339908406138,"remaining_ooc_seconds":3379.0266009159386}
    (a/"schedule.json").write_text(json.dumps(schedule,indent=2,sort_keys=True)+"\n")
    manifest={"schema":"laya-canonical-source-v1","source_graph":identity(src/"frozen_source/tanh_libm_stream_bits.cpp"),
              "source_receipt":identity(src/"receipt.json"),"schedule":identity(a/"schedule.json"),
              "scope":"New parent and L384 control; original helper RTL/independent gold; old L375 RTL evidence does not cover new parent",
              "files":[identity(p) for p in sorted(a.rglob("*")) if p.is_file()]}
    (a/"source_manifest.json").write_text(json.dumps(manifest,indent=2,sort_keys=True)+"\n")
    print("TANH_CANONICAL_GENERATE_PASS nodes=42 add=23 mul=17 div=2 commit_edge=384 first_consume_edge=385")


if __name__=="__main__":main()
