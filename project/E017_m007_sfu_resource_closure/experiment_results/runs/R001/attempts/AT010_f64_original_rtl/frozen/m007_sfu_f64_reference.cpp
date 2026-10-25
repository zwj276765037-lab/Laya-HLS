// Independent host binary64 oracle, the same volatile native-product rule used
// by frozen E007 AT005 attention_exp_cpu.cpp. No DUT arithmetic is called.
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <immintrin.h>
#include <limits>
#include <vector>
template<class T,class U> T cast(U x){T y;static_assert(sizeof x==sizeof y);std::memcpy(&y,&x,sizeof y);return y;}
static uint64_t rand64(uint64_t &s){s^=s<<13;s^=s>>7;s^=s<<17;return s;}
int main(int argc,char **argv){
  if(argc!=2 || std::fesetround(FE_TONEAREST)!=0 || sizeof(double)!=8 ||
     !std::numeric_limits<double>::is_iec559 || (_mm_getcsr() & ((1u<<15)|(1u<<6))))return 2;
  FILE *f=std::fopen(argv[1],"w");if(!f)return 2;
  unsigned count=0;
  auto emit=[&](uint64_t a,uint64_t b){
    volatile double fa=cast<double>(a),fb=cast<double>(b),product=fa*fb;
    auto gold=cast<uint64_t>(double(product));
    std::fprintf(f,"%016llx %016llx %016llx\n",(unsigned long long)a,(unsigned long long)b,(unsigned long long)gold);++count;
  };
  std::vector<uint64_t> v={0,0x8000000000000000ull,1,0x8000000000000001ull,
    0xfffffffffffffull,0x800fffffffffffffull,0x10000000000000ull,0x8010000000000000ull,
    0x3ff0000000000000ull,0xbff0000000000000ull,0x3ff0000000000001ull,0x3fefffffffffffffull,
    0x4000000000000000ull,0xc000000000000000ull,0x7fefffffffffffffull,0xffefffffffffffffull,
    0x3fe0000000000000ull,0x3ca0000000000000ull,0x4340000000000000ull,0x4340000000000001ull};
  for(auto a:v)for(auto b:v)emit(a,b);
  uint64_t state=0x6de4921ba95f9073ull;
  for(unsigned i=0;i<100000;++i){
    uint64_t a=rand64(state),b=rand64(state);
    if((a&0x7ff0000000000000ull)==0x7ff0000000000000ull)a^=0x0010000000000000ull;
    if((b&0x7ff0000000000000ull)==0x7ff0000000000000ull)b^=0x0010000000000000ull;
    emit(a,b);
  }
  if(std::fclose(f)!=0)return 2;
  std::printf("SFU_REFERENCE_PASS binary64_native_finite_pairs=%u rounding=FE_TONEAREST frozen_AT005_seed=6de4921ba95f9073\n",count);
}
