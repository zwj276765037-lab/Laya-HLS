#include "geglu_libm_stream_bits.h"
#include "gelu_libm_bits.h"
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <vector>
#include <array>
static std::vector<uint32_t> read(const char *p) {
 std::ifstream f(p,std::ios::binary); if(!f) std::exit(2);
 std::vector<uint32_t> v; uint32_t x;
 while(f.read(reinterpret_cast<char*>(&x),4)) v.push_back(x); return v;
}
static std::array<uint32_t,10> fields(const GeGluStreamTrace &t) {
 return {t.u,t.v,t.w,t.t,t.z,t.h,t.r,t.s,t.y,t.gate};
}
static bool finite(uint32_t x) { return (x&0x7f800000u)!=0x7f800000u; }
int main(int argc,char **argv) {
 if(argc!=4) return 2;
 auto wi=read(argv[1]),gold=read(argv[2]);
 if(wi.size()!=5248 || gold.size()!=26240) return 2;
 for(unsigned i=0;i<2624;++i) {
  uint32_t result,status; GeGluStreamTrace t{};
  geglu_libm_stream_leaf(wi[i],wi[i+2624],result,status,t);
  if(status || result!=gold[10*i+9] || t.mask!=1023 || t.failed_step!=0xffffffffu) return 1;
  for(unsigned j=0;j<10;++j) if(fields(t)[j]!=gold[10*i+j]) {
   std::printf("GEGLU_STREAM_STEP_FAIL col=%u step=%u got=%08x gold=%08x\n",i,j,fields(t)[j],gold[10*i+j]);return 1;
  }
 }
 std::puts("TANH_LIBM_GEGLU_STREAM_CPU_PASS wi=5248 outputs=2624 independent_step_comparisons=26240");
 const uint32_t edge[]={0,0x80000000,1,0x80000001,0x007fffff,0x807fffff,
  0x00800000,0x80800000,0x24000000,0xa4000000,0x3f800000,0xbf800000,
  0x40000000,0xc0000000,0x41b00000,0xc1b00000,0x7f7fffff,0xff7fffff,
  0x7f800000,0xff800000,0x7fc00001};
 FILE *output=std::fopen(argv[3],"w");if(!output)return 2;
 unsigned corner=0,stepchecks=0;
 for(uint32_t x:edge) for(uint32_t g:edge) {
  uint32_t sr,ss,steps[10]={},result,status;GeGluStreamTrace t{};
  geglu_libm_leaf(x,g,sr,ss,steps);
  geglu_libm_stream_leaf(x,g,result,status,t);
  uint32_t failed=!finite(g)?10:(!finite(x)?11:0xffffffffu),mask=0;
  if(failed==0xffffffffu) for(unsigned j=0;j<10;++j) {
   mask|=1u<<j;
   if(fields(t)[j]!=steps[j]) {
    std::printf("GEGLU_STREAM_CORNER_STEP_FAIL x=%08x g=%08x step=%u got=%08x gold=%08x\n",x,g,j,fields(t)[j],steps[j]);return 1;
   }
   ++stepchecks;
   if(!finite(steps[j])) { failed=j;break; }
  }
  if(result!=sr || status!=ss || t.mask!=mask || t.failed_step!=failed) {
   std::printf("GEGLU_STREAM_CORNER_STATUS_FAIL x=%08x g=%08x result=%08x/%08x status=%u/%u mask=%x/%x failed=%u/%u\n",x,g,result,sr,status,ss,t.mask,mask,t.failed_step,failed);return 1;
  }
  std::fprintf(output,"%08x\n%08x\n%08x\n%08x\n%08x\n%08x\n",x,g,sr,ss,failed,mask);
  for(unsigned j=0;j<10;++j)std::fprintf(output,"%08x\n",steps[j]);
  ++corner;
 }
 std::fclose(output);
 std::printf("TANH_LIBM_GEGLU_STREAM_CORNER_CPU_PASS cases=%u checked_applicable_steps=%u frozen_scalar_reference=1\n",corner,stepchecks);
}

