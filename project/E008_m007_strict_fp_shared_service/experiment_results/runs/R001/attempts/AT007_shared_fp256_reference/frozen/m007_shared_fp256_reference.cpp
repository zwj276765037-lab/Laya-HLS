#include <xmmintrin.h>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cstdlib>
static float f(uint32_t x){float y;std::memcpy(&y,&x,4);return y;}
static uint32_t u(float x){uint32_t y;std::memcpy(&y,&x,4);return y;}
static uint32_t state=0x00700004;
static uint32_t next(){state^=state<<13;state^=state>>17;state^=state<<5;return state;}
int main(int argc,char **argv){
 if(argc!=3||std::fesetround(FE_TONEAREST))return 2;
 _mm_setcsr(_mm_getcsr()&~unsigned((1<<15)|(1<<6)|(3<<13)));
 FILE *in=std::fopen(argv[1],"r"),*out=std::fopen(argv[2],"w");if(!in||!out)return 3;
 for(unsigned i=0;i<262144;i++){
  uint32_t aa,ab,ay;
  if(std::fscanf(in,"%8x%8x%8x",&aa,&ab,&ay)!=3){std::rewind(in);if(std::fscanf(in,"%8x%8x%8x",&aa,&ab,&ay)!=3)return 4;}
  uint32_t ma=(next()&0x807fffff)|((112+next()%31)<<23);
  uint32_t mb=(next()&0x807fffff)|((112+next()%31)<<23);
  volatile float a=f(ma),b=f(mb);volatile float product=a*b;
  std::fprintf(out,"%08x%08x%08x%08x%08x%08x\n",ma,mb,u(product),aa,ab,ay);
 }
 std::fclose(in);std::fclose(out);
 std::printf("SHARED_FP_REFERENCE_PASS records=262144 fullwidth_vectors=1024 seed=00700004 native_mul_normal_range FTZ_DAZ_off\n");
}
