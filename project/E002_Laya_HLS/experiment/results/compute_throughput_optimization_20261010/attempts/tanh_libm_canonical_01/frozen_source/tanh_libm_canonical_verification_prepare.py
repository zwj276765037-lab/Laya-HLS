#!/usr/bin/env python3
"""Freeze independent native-F32 node traces and adapted canonical RTL checks."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil


PREFIX = r'''
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cfenv>
#include <fstream>
#include <vector>
#include <string>
static uint32_t node_a[42],node_b[42],node_result[42];
static bool seen[42];
static uint32_t native_fp(unsigned op,uint32_t a,uint32_t b) {
 float af,bf;std::memcpy(&af,&a,4);std::memcpy(&bf,&b,4);
 volatile float av=af,bv=bf,rv=0;
 if(op==0)rv=av+bv;else if(op==1)rv=av*bv;else rv=av/bv;
 float result=rv;uint32_t bits;std::memcpy(&bits,&result,4);return bits;
}
static uint32_t traced_fp(unsigned op,unsigned index,uint32_t a,uint32_t b) {
 uint32_t result=native_fp(op,a,b);
 if(op==0 && index==23) {
  if(a!=0x3f800000u||b!=0x8da24260u||result!=0x3f800000u)std::exit(3);
  return result;
 }
 unsigned slot=op==0?index:(op==1?23+index:40+index);
 if(slot>=42||seen[slot])std::exit(4);
 node_a[slot]=a;node_b[slot]=b;node_result[slot]=result;seen[slot]=true;
 return result;
}
'''


SUFFIX = r'''
static std::vector<uint32_t> read_mem(const char *path) {
 std::ifstream input(path);std::vector<uint32_t> words;std::string word;
 if(!input)std::exit(2);
 while(input>>word)words.push_back(uint32_t(std::stoul(word,nullptr,16)));
 return words;
}
int main(int argc,char **argv) {
 if(argc!=5 || std::fesetround(FE_TONEAREST)!=0)return 2;
 auto inputs=read_mem(argv[1]),gold=read_mem(argv[2]),ops=read_mem(argv[3]);
 if(inputs.size()!=3270||gold.size()!=3270||ops.size()!=4*1159)return 2;
 FILE *output=std::fopen(argv[4],"w");if(!output)return 2;
 for(unsigned i=0;i<inputs.size();++i) {
  std::memset(seen,0,sizeof(seen));uint32_t result=stream_graph(inputs[i]);
  if(result!=gold[i]) {
   std::printf("TANH_CANONICAL_CPU_FINAL_FAIL index=%u x=%08x got=%08x gold=%08x\n",i,inputs[i],result,gold[i]);return 1;
  }
  for(unsigned j=0;j<42;++j) {
   if(!seen[j])return 1;
   std::fprintf(output,"%08x\n%08x\n%08x\n",node_a[j],node_b[j],node_result[j]);
  }
 }
 std::fclose(output);
 for(unsigned i=0;i<1159;++i) {
  unsigned op=ops[4*i];uint32_t a=ops[4*i+1],b=ops[4*i+2],expected=ops[4*i+3];
  uint32_t bits=op==0?stream_detail::fp_add_bits(a,b):
   (op==1?stream_detail::fp_mul_bits(a,b):stream_detail::fp_div_bits(a,b));
  if(bits!=expected||native_fp(op,a,b)!=expected) {
   std::printf("TANH_CANONICAL_CPU_HELPER_FAIL index=%u op=%u a=%08x b=%08x got=%08x gold=%08x\n",i,op,a,b,bits,expected);return 1;
  }
 }
 std::puts("TANH_CANONICAL_CPU_PASS fixture=3270 nodes=42 independent_native_node_results=137340 native_helpers=1159 original_gold_unchanged=1");
}
'''


TB_EXTRA = r'''
 reg [31:0] trace_gold[0:412019];
 reg source_valid[0:1023];integer source_ordinal[0:1023];
 integer node_issued[0:41],node_returned[0:41];
 string tf;
 task check_node(input integer slot,input integer launch,input integer sample_edge,
                 input issue_valid,input [31:0] a,b,result);
  integer src,ord;
  reg expected_valid;
  begin
   src=(cycle-launch)%1024;
   expected_valid=cycle>=launch && source_valid[src];
   if(issue_valid!==expected_valid)
    $fatal(1,"CANONICAL_NODE_TOKEN slot=%0d launch=%0d cycle=%0d",slot,launch,cycle);
   if(issue_valid) begin
    ord=source_ordinal[src];
    if(a!==trace_gold[(ord*42+slot)*3] || b!==trace_gold[(ord*42+slot)*3+1])
     $fatal(1,"CANONICAL_NODE_OPERAND slot=%0d ordinal=%0d a=%08x/%08x b=%08x/%08x cycle=%0d",slot,ord,a,trace_gold[(ord*42+slot)*3],b,trace_gold[(ord*42+slot)*3+1],cycle);
    node_issued[slot]=node_issued[slot]+1;
    if(slot==40)div0_issue=div0_issue+1;
    if(slot==41)div1_issue=div1_issue+1;
   end else if(a!==0 || b!==(slot<23?32'b0:32'h3f800000))
    $fatal(1,"CANONICAL_UNSAFE_BUBBLE slot=%0d a=%08x b=%08x",slot,a,b);
   src=(cycle-sample_edge)%1024;
   if(cycle>=sample_edge && source_valid[src]) begin
    ord=source_ordinal[src];
    if(result!==trace_gold[(ord*42+slot)*3+2])
     $fatal(1,"CANONICAL_NODE_RESULT slot=%0d ordinal=%0d got=%08x gold=%08x sample_edge=%0d cycle=%0d",slot,ord,result,trace_gold[(ord*42+slot)*3+2],sample_edge,cycle);
    node_returned[slot]=node_returned[slot]+1;
    if(node_returned[slot]>node_issued[slot])$fatal(1,"CANONICAL_NODE_UNRESERVED_RETURN");
    if(slot==40)div0_return=div0_return+1;
    if(slot==41)div1_return=div1_return+1;
   end
  end
 endtask
'''


def ident(path):
    data=path.read_bytes()
    return dict(path=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("attempt",type=Path)
    parser.add_argument("module",type=Path)
    args=parser.parse_args();a=args.attempt.resolve();m=args.module.resolve()
    original=(a/"frozen_source/tanh_libm_stream_bits.cpp").read_text()
    traced=original
    for op,code in (("add",0),("mul",1),("div",2)):
        pattern=r"(template<int Node> static uint32_t stream_"+op+r"_node\(uint32_t a,uint32_t b\) \{[\s\S]*?)return stream_detail::fp_"+op+r"_bits\(a,b\);"
        traced,count=re.subn(pattern,lambda match:match[1]+f"return traced_fp({code},Node,a,b);",traced)
        assert count==1,(op,count)
    cpu=m/"tb/tanh_libm_canonical_cpu.cpp";cpu.write_text(PREFIX+traced+SUFFIX)
    shutil.copy2(cpu,a/"frozen_source"/cpu.name)
    tb=(m/"tb/tanh_libm_stream_tb.sv").read_text()
    tb=tb.replace("module tanh_libm_stream_tb;","module tanh_libm_canonical_tb;")
    tb=tb.replace("tanh_libm_stream_wrapper dut","tanh_libm_canonical_wrapper dut")
    tb=tb.replace("dut.result_valid","dut.commit_valid").replace("dut.leaf_result","dut.core_result")
    start=tb.index(" // Actual generated call schedule:");end=tb.index(" reg was_stalled",start)
    tb=tb[:start]+TB_EXTRA+tb[end:]
    start=tb.index("   if(div0_issue_valid)");end=tb.index("   if(dut.commit_valid)",start)
    schedule=json.loads((a/"schedule.json").read_text())
    checks=[]
    for n in schedule["fp_nodes"]:
        slot=n["index"]+{"add":0,"mul":23,"div":40}[n["op"]]
        name=n["name"]
        checks.append(f"   check_node({slot},{n['launch_edge']},{n['consumer_edge']},dut.core.{name}_issue_valid,dut.core.{name}_a,dut.core.{name}_b,dut.core.{name});")
    tb=tb[:start]+"\n".join(checks)+"\n"+tb[end:]
    tb=tb.replace("  if(reset) begin was_stalled=0; end","  if(reset) begin was_stalled=0;for(integer r=0;r<1024;r=r+1)source_valid[r]=0;end")
    tb=tb.replace("  else begin\n   if(was_stalled", "  else begin\n   source_valid[cycle%1024]=in_valid&&in_ready;source_ordinal[cycle%1024]=in_tag&65535;\n   if(was_stalled",1)
    tb=tb.replace("if(gotlat!=latency)","if(gotlat!=384 || gotlat!=latency)")
    tb=tb.replace("    produced=produced+1;", "    if(dut.core_status!==((x[ordinal]&32'h7fffffff)>=32'h7f800000 ? 32'd1 : 32'd0))$fatal(1,\"CANONICAL_CORE_STATUS\");\n    produced=produced+1;")
    tb=tb.replace("   div0_issue=0; div0_return=0; div1_issue=0; div1_return=0;", "   div0_issue=0; div0_return=0; div1_issue=0; div1_return=0;\n   for(integer r=0;r<42;r=r+1)begin node_issued[r]=0;node_returned[r]=0;end")
    tb=tb.replace("   $display(\"TANH_STREAM_PROFILE_PASS", "   for(integer r=0;r<42;r=r+1)if(node_issued[r]!=n||node_returned[r]!=n)$fatal(1,\"CANONICAL_PROFILE_NODE_DEBT\");\n   $display(\"TANH_STREAM_PROFILE_PASS")
    tb=tb.replace("call_stages=250,357 capture_stages=262,369","issue_edges=233,337 consumer_edges=245,349")
    tb=tb.replace("  $readmemh(xf,x); $readmemh(gf,gold);", "  if(!$value$plusargs(\"TRACE_FILE=%s\",tf))$fatal(1,\"CANONICAL_MISSING_TRACE\");\n  $readmemh(tf,trace_gold);\n  for(i=0;i<412020;i=i+1)if($isunknown(trace_gold[i]))$fatal(1,\"CANONICAL_UNKNOWN_TRACE\");\n  $readmemh(xf,x); $readmemh(gf,gold);")
    tb=tb.replace("TANH_STREAM_","TANH_CANONICAL_")
    out=m/"tb/tanh_libm_canonical_tb.sv";out.write_text(tb);shutil.copy2(out,a/"frozen_source"/out.name)
    shutil.copy2(m/"tb/tanh_libm_stream_helper_tb.sv",a/"frozen_source/tanh_libm_stream_helper_tb.sv")
    (a/"verification_manifest.json").write_text(json.dumps({"schema":"laya-canonical-verification-v1",
         "original_graph":ident(a/"frozen_source/tanh_libm_stream_bits.cpp"),"native_reference_transformation":"Only three template operation returns replaced with independent volatile native FE_TONEAREST F32 operations plus recording; graph body/constants/control preserved",
         "cpu":ident(a/"frozen_source/tanh_libm_canonical_cpu.cpp"),"tb":ident(a/"frozen_source/tanh_libm_canonical_tb.sv"),
         "checks":"All 42 per-token operands/results against native reference, L384, original3270 gold, bothprofiles, finite512credit, reset, original1159 helper native gold"},indent=2,sort_keys=True)+"\n")
    print("TANH_CANONICAL_VERIFY_FREEZE_PASS nodes=42 independent_native_trace=1 original_gold=1")


if __name__=="__main__":main()
