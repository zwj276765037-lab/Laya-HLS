#include "tanh_libm_stream_bits.h"
#include <cfenv>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <vector>
static float fl(uint32_t x) { float y; std::memcpy(&y,&x,4); return y; }
static uint32_t bi(float x) { uint32_t y; std::memcpy(&y,&x,4); return y; }
int main(int argc,char **argv) {
 if(argc!=3 || std::fegetround()!=FE_TONEAREST) return 2;
 std::ifstream input(argv[1]); std::ofstream out(argv[2]); if(!input||!out) return 2;
 unsigned count=0,counts[3]={0,0,0};
 auto emit=[&](uint32_t op,uint32_t a,uint32_t b) {
  if(op==2 && !(b&0x7fffffff)) return;
  volatile float fa=fl(a),fb=fl(b),gold=op==0?fa+fb:(op==1?fa*fb:fa/fb);
  uint32_t got=op==0?stream_fp_add_bits(a,b):(op==1?stream_fp_mul_bits(a,b):stream_fp_div_bits(a,b));
  if(got!=bi(gold)) { std::printf("STREAM_HELPER_CPU_FAIL op=%u a=%08x b=%08x got=%08x gold=%08x\n",op,a,b,got,bi(gold)); std::exit(1); }
  out<<std::hex<<std::setfill('0')<<std::setw(8)<<op<<'\n'<<std::setw(8)<<a<<'\n'<<std::setw(8)<<b<<'\n'<<std::setw(8)<<bi(gold)<<'\n'; ++count; ++counts[op];
 };
 uint32_t a,b,gold;
 while(input>>std::hex>>a>>b>>gold) for(uint32_t op=0;op<3;++op) emit(op,a,b);
 const uint32_t pairs[][2]={{1,0x40000000},{3,0x40000000},{5,0x40000000},
  {0x007fffff,0x40000000},{0x00800000,0x3f800001},{0x00800001,0x3f800001},
  {0x3f800001,0x3fc00000},{0x3f800003,0x3fc00000},{0x3f800001,0x40400000},
  {0x3faaaaab,0x3f800001},{0x7f7fffff,0x3f800001},{0x7f7fffff,0x3f000000},
  {0x00800000,0x007fffff},{1,2},{0x007fffff,0x00800001},{0x3fffffff,0x3fffffff}};
 for(const auto &p:pairs) for(unsigned order=0;order<2;++order)
  for(unsigned sign=0;sign<2;++sign) for(unsigned op=1;op<3;++op)
   emit(op,p[order]|(sign?0x80000000:0),p[1-order]);
 std::printf("TANH_LIBM_STREAM_HELPER_CPU_PASS count=%u add=%u mul=%u div=%u native_gold=RNE\n",count,counts[0],counts[1],counts[2]);
}
