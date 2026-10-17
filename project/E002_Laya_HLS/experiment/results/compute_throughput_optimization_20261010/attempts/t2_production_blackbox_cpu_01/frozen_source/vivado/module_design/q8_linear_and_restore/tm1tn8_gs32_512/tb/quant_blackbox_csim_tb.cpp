#include <array>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

void laya_quant_blackbox_smoke(const uint64_t input[31], uint64_t output[23]);
namespace {
std::vector<uint8_t> read(const std::string& name) {
  std::ifstream f(name, std::ios::binary);
  if (!f) {std::cerr<<"QUANT_BLACKBOX_FAIL open="<<name<<'\n';std::exit(1);}
  return {std::istreambuf_iterator<char>(f),std::istreambuf_iterator<char>()};
}
void check(bool good,const std::string& reason) {
  if(!good) {std::cerr<<"QUANT_BLACKBOX_FAIL "<<reason<<'\n';std::exit(1);}
}
uint64_t word(const uint8_t* data,unsigned bytes) {
  uint64_t out=0;for(unsigned b=0;b<bytes;++b)out|=uint64_t(data[b])<<(8*b);return out;
}
}
int main() {
  const char* root=std::getenv("LAYA_QUANT_FIXTURE");
  check(root&&*root,"fixture path required");
  unsigned groups=0;
  for (const std::string name : {"wi","down"}) {
    const auto x=read(std::string(root)+"/"+name+"_source_f32.bin");
    const auto q=read(std::string(root)+"/"+name+"_q.bin");
    const auto s=read(std::string(root)+"/"+name+"_scale.bin");
    const auto scalar=read(std::string(root)+"/"+name+"_scalar_u32x3.bin");
    check(x.size()%128==0&&q.size()==x.size()/4&&s.size()==x.size()/64&&scalar.size()==x.size()/128*12,"frozen shape");
    for(unsigned g=0;g<x.size()/128;++g) {
      uint64_t input[31]={}, output[23]={};
      // Transport marker fields cover every full owner bit. This short
      // arithmetic adapter is not the production owner admission function.
      for(unsigned i=0;i<14;++i) input[i]=0x71c303204865ac9dULL^(uint64_t(i+1)<<40)^g;
      input[0]=3;input[1]=1;input[10]=(input[10]&0xffffffffULL)|(uint64_t(g+1)<<32);
      input[11]=0x0100000000000220ULL;
      input[12]=0x0000000300000001ULL;input[13]=0x0000002200000001ULL;
      for(unsigned i=0;i<16;++i)input[14+i]=word(x.data()+g*128+i*8,8);
      input[30]=0;
      laya_quant_blackbox_smoke(input,output);
      for(unsigned i=0;i<14;++i)check(output[i]==input[i],"complete owner echo");
      for(unsigned i=0;i<4;++i)check(output[14+i]==word(q.data()+g*32+i*8,8),"independent q group="+std::to_string(g));
      check(output[18]==word(s.data()+g*2,2),"independent saved scale");
      check(output[19]==word(scalar.data()+g*12+4,4),"independent d_full");
      check(output[20]==word(scalar.data()+g*12+8,4),"independent reciprocal");
      check(output[21]==0&&output[22]==UINT32_MAX,"success status");
      ++groups;
    }
  }
  uint64_t input[31]={},output[23]={};
  for(unsigned i=0;i<14;++i)input[i]=0x59162810bad37901ULL+i;
  for(unsigned i=0;i<16;++i)input[14+i]=0x3f8000003f800000ULL;
  input[29]=(uint64_t(0x7f800000u)<<32)|0x3f800000u;
  laya_quant_blackbox_smoke(input,output);
  check(output[21]==1&&output[22]==31,"late numerical first error");
  input[29]=0x3f8000003f800000ULL;laya_quant_blackbox_smoke(input,output);
  check(output[21]==0,"subsequent invocation recovery");
  std::cout<<"QUANT_BLACKBOX_CSIM_PASS real_groups="<<groups<<" full_owner_bits=896 late_error=31 recovery=1\n";
}
