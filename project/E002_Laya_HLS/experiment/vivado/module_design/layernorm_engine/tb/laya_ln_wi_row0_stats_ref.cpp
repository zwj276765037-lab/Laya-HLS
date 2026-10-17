#include "laya_numeric.h"

#include <array>
#include <bit>
#include <cstdint>
#include <cstdio>

static bool read_hex(const char* path, std::array<float,1024>& words) {
  FILE* f=std::fopen(path,"r");
  if(!f)return false;
  for(auto& word:words) {
    unsigned bits=0;
    if(std::fscanf(f,"%x",&bits)!=1){std::fclose(f);return false;}
    word=std::bit_cast<float>(uint32_t(bits));
  }
  unsigned extra=0;
  const bool exact=std::fscanf(f,"%x",&extra)==EOF;
  std::fclose(f);
  return exact;
}

int main(int argc,char** argv) {
  if(argc!=3)return 2;
  std::array<float,1024> x{},gold{},gamma{},y{};
  if(!read_hex(argv[1],x) || !read_hex(argv[2],gold))return 3;
  float mean=0,variance=0,inverse=0;
  const auto status=laya::layernorm_row_arithmetic(
      laya::Op::LN_FFN,0,x.data(),gamma.data(),0,y.data(),
      mean,variance,inverse);
  if(!status)return 4;
  for(unsigned i=0;i<1024;i++)
    if(std::bit_cast<uint32_t>(y[i])!=std::bit_cast<uint32_t>(gold[i])) {
      std::printf("LN_WI_ROW0_REF_MISMATCH index=%u got=%08x expected=%08x\n",
          i,std::bit_cast<uint32_t>(y[i]),std::bit_cast<uint32_t>(gold[i]));
      return 5;
    }
  std::printf("LN_WI_ROW0_STATS_REF_PASS mean=%08x variance=%08x inverse=%08x y=1024\n",
      std::bit_cast<uint32_t>(mean),std::bit_cast<uint32_t>(variance),
      std::bit_cast<uint32_t>(inverse));
}
