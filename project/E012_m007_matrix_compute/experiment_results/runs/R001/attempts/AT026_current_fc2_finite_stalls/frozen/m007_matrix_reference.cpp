#include <cstdint>
#include <cstring>
#include <cmath>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <vector>
#include <cfenv>
#include <xmmintrin.h>
static uint32_t state=0x00120021;
uint32_t rnd(){state^=state<<13;state^=state>>17;state^=state<<5;return state;}
uint32_t bits(float x){uint32_t u;std::memcpy(&u,&x,4);return u;}
float half(uint16_t h){int e=(h>>10)&31,m=h&1023;float f=std::ldexp(float(e?m+1024:m),e?e-25:-24);return h&32768?-f:f;}
int main(int argc,char**argv){
 if(argc!=2)return 2;std::fesetround(FE_TONEAREST);_mm_setcsr(_mm_getcsr()&~((1u<<15)|(1u<<6)));
 std::string out=argv[1];uint64_t exhaustive=0;
 for(int a=-128;a<128;a++)for(int w0=-128;w0<128;w0++)for(int w1=-128;w1<128;w1++){
  int64_t prod=int64_t(a)*(int64_t(w1)*131072+w0);int lo=int16_t(uint16_t(prod));int64_t hi=prod/131072;if(prod<0&&prod%131072)hi--;
  if(lo!=a*w0||hi+(lo<0)!=a*w1){std::cerr<<"signed packing proof failed\n";return 3;}exhaustive++;
 }
 std::ofstream pf(out+"/pair.hex");pf<<std::hex<<std::setfill('0');uint32_t pc=0;
 auto pair=[&](int a,int x,int y){pf<<std::setw(4)<<uint16_t(a*y)<<std::setw(4)<<uint16_t(a*x)<<std::setw(2)<<uint8_t(y)+0u<<std::setw(2)<<uint8_t(x)+0u<<std::setw(2)<<uint8_t(a)+0u<<"\n";pc++;};
 int edge[]={-128,-127,-1,0,1,126,127};for(int a=-128;a<128;a++)for(int x:edge)for(int y:edge)pair(a,x,y);
 for(int i=0;i<262144;i++)pair(int8_t(rnd()),int8_t(rnd()),int8_t(rnd()));
 std::ofstream sf(out+"/scale.hex");sf<<std::hex<<std::setfill('0');uint32_t count=0;
 uint16_t bs[]={0,0x8000,1,3,0x3ff,0x400,0x401,0x3800,0x3c00,0x3c01,0x4000,0x7bff,0x8001,0x83ff,0xbc00,0xc000,0xfbff,0x3555};
 for(uint32_t aa=0;aa<65536;aa++)if(((aa>>10)&31)!=31)for(uint16_t bb:bs){
  volatile float av=half(aa),bv=half(bb);volatile float product=av*bv;int dot=int(count%1048577)-524288;volatile float df=float(dot);
  sf<<std::setw(8)<<bits(df)<<std::setw(6)<<(uint32_t(dot)&0x1fffff)<<std::setw(8)<<bits(product)<<std::setw(4)<<bb<<std::setw(4)<<aa<<"\n";count++;
 }
 std::ofstream af(out+"/dot_a.hex"),wf(out+"/dot_w.hex"),df(out+"/dot_expected.hex");af<<std::hex<<std::setfill('0');wf<<std::hex<<std::setfill('0');df<<std::hex<<std::setfill('0');
 for(int v=0;v<1024;v++){
  int8_t a[512],w[512];for(int i=0;i<512;i++){a[i]=int8_t(rnd());w[i]=int8_t(rnd());if(v<4){a[i]=v==0?-128:v==1?127:v==2?-128:(i%2?-128:127);w[i]=v==0?-128:v==1?127:v==2?127:(i%2?127:-128);}}
  for(int i=511;i>=0;i--){af<<std::setw(2)<<uint8_t(a[i])+0u;wf<<std::setw(2)<<uint8_t(w[i])+0u;}af<<"\n";wf<<"\n";
  for(int lane=255;lane>=0;lane--){int r=lane/16,c=lane%16,d=0;for(int k=0;k<32;k++)d+=int(a[r*32+k])*int(w[c*32+k]);if(std::abs(d)>524288)return 4;df<<std::setw(8)<<uint32_t(d);}df<<"\n";
 }
 std::ofstream meta(out+"/reference.json");meta<<"{\"signed_pair_exhaustive\":"<<exhaustive<<",\"pair_vectors\":"<<pc<<",\"scale_vectors\":"<<count<<",\"dot_vectors\":1024,\"dot_lanes\":256,\"activation\":\"DIAGNOSTIC_INDEPENDENT_LEAF_ONLY\",\"mxcsr\":"<<_mm_getcsr()<<"}\n";
 std::cout<<"M007_MATRIX_REFERENCE_PASS pair_exhaustive="<<exhaustive<<" pair_vectors="<<pc<<" scale_vectors="<<count<<" dot_vectors=1024 lanes=256\n";
}
