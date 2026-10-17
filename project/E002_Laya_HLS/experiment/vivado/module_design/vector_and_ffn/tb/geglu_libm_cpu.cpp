#include "gelu_libm_bits.h"
#include "laya_full_numeric.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <vector>
static std::vector<uint32_t> read(const char *p) {
 std::ifstream f(p,std::ios::binary); if(!f) std::exit(2);
 std::vector<uint32_t> v; uint32_t x;
 while(f.read(reinterpret_cast<char*>(&x),4)) v.push_back(x); return v;
}
int main(int argc,char **argv) {
 if(argc!=3) return 2;
 auto wi=read(argv[1]),gold=read(argv[2]);
 if(wi.size()!=5248 || gold.size()!=26240) return 2;
 float input[5248],output[2624]; std::memcpy(input,wi.data(),sizeof input);
 auto c=laya::full::geglu_row(input,output);
 if(!c) { std::puts("GEGLU_PRODUCTION_CPU_FAIL status"); return 1; }
 for(unsigned i=0;i<2624;++i) {
  uint32_t result,status,steps[10];
  geglu_libm_leaf(wi[i],wi[i+2624],result,status,steps);
  if(status) return 1;
  for(unsigned j=0;j<10;++j) if(steps[j]!=gold[10*i+j]) {
   std::printf("GEGLU_STEP_FAIL col=%u step=%u got=%08x gold=%08x\n",i,j,steps[j],gold[10*i+j]); return 1;
  }
  uint32_t prod; std::memcpy(&prod,&output[i],4);
  if(result!=gold[10*i+9] || prod!=result) return 1;
 }
 std::puts("GEGLU_PRODUCTION_CPU_PASS wi=5248 outputs=2624 independent_step_comparisons=26240");
}
