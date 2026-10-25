// Independent expected values: native IEEE binary32 MULSS, no DUT helpers.
#include <xmmintrin.h>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <limits>
static float from_bits(uint32_t u) { float f; std::memcpy(&f,&u,4); return f; }
static uint32_t bits(float f) { uint32_t u; std::memcpy(&u,&f,4); return u; }
static uint32_t ref(uint32_t a,uint32_t b) {
  volatile float x=from_bits(a),y=from_bits(b);
  volatile float z=x*y;
  return bits(z);
}
static uint32_t rng=0x00800721;
static uint32_t next() { rng^=rng<<13; rng^=rng>>17; rng^=rng<<5; return rng; }
static bool finite(uint32_t u) { return (u&0x7f800000)!=0x7f800000; }
int main(int argc,char **argv) {
  if(argc!=2) return 2;
  if(std::fesetround(FE_TONEAREST)) return 3;
  const unsigned before=_mm_getcsr();
  _mm_setcsr(before & ~(unsigned(1<<15)|unsigned(1<<6)|unsigned(3<<13)));
  const unsigned active=_mm_getcsr();
  if(active & ((1<<15)|(1<<6)|(3<<13))) return 4;
  if(ref(1,0x3f800000)!=1 || ref(1,0x3f000000)!=0 ||
     ref(3,0x3f000000)!=2 || ref(0x80000000,0x40000000)!=0x80000000 ||
     ref(0x007fffff,0x3f800000)!=0x007fffff) return 5;
  FILE *f=std::fopen(argv[1],"w"); if(!f) return 6;
  uint64_t count=0;
  auto emit=[&](uint32_t a,uint32_t b) {
    if(!finite(a)||!finite(b)) std::abort();
    std::fprintf(f,"%08x%08x%08x\n",a,b,ref(a,b)); ++count;
  };
  const uint32_t edges[]={0,1,2,3,0x003fffff,0x00400000,0x007ffffe,
    0x007fffff,0x00800000,0x00800001,0x00ffffff,0x01000000,
    0x33800000,0x34000000,0x3effffff,0x3f000000,0x3f000001,
    0x3f7fffff,0x3f800000,0x3f800001,0x3fc00000,0x40000000,
    0x4affffff,0x4b000000,0x4b000001,0x7f000000,0x7f7ffffe,0x7f7fffff};
  for(auto a:edges) for(auto b:edges) for(unsigned sa=0;sa<2;sa++)
    for(unsigned sb=0;sb<2;sb++) emit(a|(sa<<31),b|(sb<<31));
  // Every exponent: cancellation, adjacent significands, half-ULP and carry.
  for(unsigned e=1;e<255;e++) for(unsigned low=0;low<32;low++) {
    uint32_t a=(e<<23)|(next()&0x7fffff);
    uint32_t b=(e<<23)|((a+low)&0x7fffff);
    emit(a,b^0x80000000); emit(a^0x80000000,b);
    uint32_t h=e>24 ? (e-24)<<23 : 1u<<(e>1?e-2:0);
    emit(a,h); emit(a,h^0x80000000);
    emit((e<<23)|0x7fffff,h); emit((e<<23),h^0x80000000);
  }
  for(unsigned i=0;i<100000;i++) {
    uint32_t a=next(),b=next();
    if(!finite(a)) a^=1u<<23;
    if(!finite(b)) b^=1u<<23;
    emit(a,b);
  }
  // Extra subnormal/normal boundary and near-cancellation population.
  for(unsigned i=0;i<20000;i++) {
    uint32_t a=next()&0x80ffffff,b=next()&0x80ffffff;
    emit(a,b);
    a=next();if(!finite(a)) a^=1u<<23;
    b=(a^0x80000000) + (i%5) - 2;
    if(finite(b)) emit(a,b);
  }
  const uint32_t tails[]={0,1,2,0x7ffffe,0x7fffff};
  const uint32_t factors[]={0x3f000000,0x3f7fffff,0x3f800000,0x3f800001,0x3fc00000};
  for(unsigned e=1;e<255;e++)for(auto t:tails)for(auto v:factors)
    for(unsigned sa=0;sa<2;sa++)for(unsigned sb=0;sb<2;sb++)
      emit((e<<23)|t|(sa<<31),v|(sb<<31));
  std::fclose(f);
  std::printf("FMUL_REFERENCE_PASS count=%llu seed=00800721 rounding=FE_TONEAREST mxcsr_before=%08x active=%08x native_float_iec559=%d\n",
    (unsigned long long)count,before,active,std::numeric_limits<float>::is_iec559);
  return 0;
}
