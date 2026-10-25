// Independent native SSE boundary gold for the exact early-overflow adder.
#include <xmmintrin.h>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstring>
static float value(uint32_t x){float f;std::memcpy(&f,&x,4);return f;}
static uint32_t ref(uint32_t a,uint32_t b){volatile float x=value(a),y=value(b);volatile float z=x+y;float f=z;uint32_t u;std::memcpy(&u,&f,4);return u;}
int main(int argc,char**argv){
 if(argc!=2||std::fesetround(FE_TONEAREST))return 2;
 _mm_setcsr(_mm_getcsr()&~((1u<<15)|(1u<<6)|(3u<<13)));
 if(_mm_getcsr()&((1u<<15)|(1u<<6)|(3u<<13)))return 3;
 if(ref(0x7f7fffff,0x73000000)!=0x7f800000||ref(0x7f7fffff,0x72ffffff)!=0x7f7fffff||
    ref(0xff7fffff,0xf3000000)!=0xff800000||ref(0x7f7fffff,0xff7fffff)!=0)return 4;
 FILE*f=std::fopen(argv[1],"w");if(!f)return 5;unsigned count=0;
 auto emit=[&](uint32_t a,uint32_t b){std::fprintf(f,"%08x%08x%08x\n",a,b,ref(a,b));++count;};
 // Exact positive/negative overflow threshold and immediately adjacent bits.
 for(int da=-8;da<=0;da++)for(int db=-8;db<=8;db++)for(unsigned sa=0;sa<2;sa++)for(unsigned sb=0;sb<2;sb++)
  emit((0x7f7fffffu+da)|(sa<<31),(0x73000000u+db)|(sb<<31));
 // Carry after adding two large finite values and every sign/cancellation pair.
 for(int da=-8;da<=0;da++)for(int db=-32;db<=0;db++)for(unsigned sa=0;sa<2;sa++)for(unsigned sb=0;sb<2;sb++)
  emit((0x7f7fffffu+da)|(sa<<31),(0x7f7fffffu+db)|(sb<<31));
 const uint32_t fractions[]={0,1,0x3fffff,0x400000,0x7ffffe,0x7fffff};
 for(unsigned exponent=246;exponent<=254;exponent++)for(auto fraction:fractions)for(int neighbor=-4;neighbor<=4;neighbor++)for(unsigned sa=0;sa<2;sa++)for(unsigned sb=0;sb<2;sb++)
  emit((exponent<<23)|fraction|(sa<<31),(((exponent-24)<<23)+neighbor)|(sb<<31));
 const uint32_t tiny[]={0,1,2,0x007fffff,0x00800000,0x00800001};
 for(auto a:tiny)for(auto b:tiny)for(unsigned sa=0;sa<2;sa++)for(unsigned sb=0;sb<2;sb++)emit(a|(sa<<31),b|(sb<<31));
 std::fclose(f);std::printf("M007_ADD_OVERFLOW_BOUNDARY_REFERENCE_PASS count=%u FE_TONEAREST1 FTZ0 DAZ0\n",count);return 0;
}
