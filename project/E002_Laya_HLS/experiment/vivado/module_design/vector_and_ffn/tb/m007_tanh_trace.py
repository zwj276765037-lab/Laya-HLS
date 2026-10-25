#!/usr/bin/env python3
"""Native SSE node oracle derived from the frozen original scalar DAG."""
import argparse,hashlib,json,re,shutil,subprocess
from pathlib import Path
MODULE=Path(__file__).resolve().parents[1];ROOT=MODULE.parents[5]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('build','run'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--vectors',type=Path);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
 if a.stage=='build':
  src=MODULE/'source/tanh_libm_stream_bits.cpp';header=MODULE/'source/tanh_libm_stream_bits.h';original=src.read_text();text=original.split('uint32_t tanh_libm_stream_bits(uint32_t x)')[0]
  prefix='''#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cfenv>
#include <xmmintrin.h>
static unsigned nodes[42];
static unsigned native_f32(char op,unsigned a,unsigned b){
 float x,y;std::memcpy(&x,&a,4);std::memcpy(&y,&b,4);
 volatile float xx=x,yy=y;volatile float zz=op=='a'?xx+yy:(op=='m'?xx*yy:xx/yy);
 float z=zz;unsigned r;std::memcpy(&r,&z,4);return r;
}
'''
  for kind,letter,offset,limit in(('add','a',0,23),('mul','m',23,17),('div','d',40,2)):
   pattern=r'(template<int Node> static uint32_t stream_'+kind+r'_node\(uint32_t a,uint32_t b\) \{).*?(\n\})'
   replacement=r"\1\n unsigned r=native_f32('"+letter+"',a,b);if(Node<"+str(limit)+')nodes['+str(offset)+r'+Node]=r;return r;\2'
   text,n=re.subn(pattern,replacement,text,count=1,flags=re.S);assert n==1
  text=prefix+text+'''
int main(int argc,char**argv){
 if(argc!=3)return 2;std::fesetround(FE_TONEAREST);_mm_setcsr(_mm_getcsr()&~((1u<<15)|(1u<<6)|(3u<<13)));
 if(_mm_getcsr()&((1u<<15)|(1u<<6)|(3u<<13)))return 3;
 FILE *in=std::fopen(argv[1],"r"),*out=std::fopen(argv[2],"w");if(!in||!out)return 4;
 unsigned x,gold,status,count=0;
 while(std::fscanf(in,"%8x%8x%8x",&x,&gold,&status)==3){
  unsigned got=stream_graph(x);if(got!=gold){std::fprintf(stderr,"TRACE_GOLD_FAIL i=%u x=%08x got=%08x gold=%08x\\n",count,x,got,gold);return 5;}
  for(unsigned node=0;node<42;node++)std::fprintf(out,"%08x",nodes[node]);std::fputc('\\n',out);++count;
 }
 std::fclose(in);std::fclose(out);std::printf("M007_NATIVE_TANH_NODE_REFERENCE_PASS count=%u nodes42 libm_gold_exact1\\n",count);return 0;
}
'''
  cpp=o/'native_trace.cpp';cpp.write_text(text);shutil.copy2(header,o/header.name)
  cmd=['/usr/bin/g++','-O2','-std=c++17','-fno-fast-math','-frounding-math','-ffp-contract=off',str(cpp),'-o',str(o/'native_trace')];subprocess.run(cmd,check=True)
  report={'status':'BUILD_COMPLETE','original_source':str(src.relative_to(ROOT)),'original_source_sha256':sha(src),'original_header_sha256':sha(header),'derived_source_sha256':sha(cpp),'binary_sha256':sha(o/'native_trace'),'command':cmd,'arithmetic':'native binary32 SSE separate volatile operations; FMA disabled, FE_TONEAREST, FTZ/DAZ off'}
 else:
  b=a.build;manifest=json.loads((b/'report.json').read_text());assert sha(b/'native_trace')==manifest['binary_sha256'];cmd=[str(b/'native_trace'),str(a.vectors),str(o/'nodes.hex')];subprocess.run(cmd,check=True)
  report={'status':'NATIVE_NODE_ORACLE_COMPLETE','count':sum(1 for _ in a.vectors.open()),'nodes_per_input':42,'input_sha256':sha(a.vectors),'nodes_sha256':sha(o/'nodes.hex'),'nodes_bytes':(o/'nodes.hex').stat().st_size,'build_manifest_sha256':sha(b/'report.json'),'binary_sha256':sha(b/'native_trace'),'command':cmd,'independent_final_host_libm_exact':True}
 (o/'report.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
