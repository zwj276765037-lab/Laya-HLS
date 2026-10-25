#include "attention_exp_bits.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <vector>
template<class T> static std::vector<T> read(const char *p) {std::ifstream f(p,std::ios::binary);if(!f)std::exit(2);std::vector<T> v;T x;while(f.read((char*)&x,sizeof(x)))v.push_back(x);return v;}
template<class T,class U> static T cast(U x){T y;std::memcpy(&y,&x,sizeof(y));return y;}
static uint64_t rand64(uint64_t &s){s^=s<<13;s^=s>>7;s^=s<<17;return s;}
static void check(const char*op,uint64_t a,uint64_t b,uint64_t got,uint64_t gold){if(got!=gold){std::printf("FAIL %s a=%016llx b=%016llx got=%016llx gold=%016llx\n",op,(unsigned long long)a,(unsigned long long)b,(unsigned long long)got,(unsigned long long)gold);std::exit(1);}}
int main(int argc,char **argv){
 if(argc!=5)return 2;
 auto x=read<uint32_t>(argv[1]),g=read<uint32_t>(argv[2]);auto d=read<uint32_t>(argv[3]),dg=read<uint32_t>(argv[4]);
 if(x.size()!=g.size()||d.size()!=dg.size())return 2;
 x.insert(x.end(),d.begin(),d.end());g.insert(g.end(),dg.begin(),dg.end());
 for(size_t i=0;i<x.size();++i){uint32_t y,s;attention_exp_leaf(x[i],y,s);check("exp",x[i],i,y,g[i]);check("status",x[i],i,s,0);}
 std::printf("ATTENTION_EXP_REAL_CPU_PASS count=%zu\n",x.size());std::fflush(stdout);
 uint64_t state=0x6de4921ba95f9073ull;
 for(unsigned i=0;i<100000;++i){
  uint64_t a=rand64(state),b=rand64(state);
  if((a&0x7ff0000000000000ull)==0x7ff0000000000000ull)a^=0x0010000000000000ull;
  if((b&0x7ff0000000000000ull)==0x7ff0000000000000ull)b^=0x0010000000000000ull;
  volatile double fa=cast<double>(a),fb=cast<double>(b),sum=fa+fb,prod=fa*fb;
  check("f64add",a,b,attention_f64_add(a,b),cast<uint64_t>(double(sum)));
  check("f64mul",a,b,attention_f64_mul(a,b),cast<uint64_t>(double(prod)));
 }
 std::puts("ATTENTION_EXP_CPU_PASS basic_f64_ops=200000");
}
