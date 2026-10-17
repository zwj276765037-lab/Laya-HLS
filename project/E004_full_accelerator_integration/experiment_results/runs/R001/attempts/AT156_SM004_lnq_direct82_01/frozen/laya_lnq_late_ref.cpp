#include "laya_numeric.h"

#include <algorithm>
#include <array>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <filesystem>
#include <stdexcept>

namespace fs = std::filesystem;

int main(int argc, char** argv) {
  if (argc != 3) return 2;
  const fs::path source = argv[1], output = argv[2];
  std::array<float,1024> x{},g{},y{};
  auto read = [](const fs::path& p,float* v) {
    FILE* f=std::fopen(p.c_str(),"rb");
    if (!f || std::fread(v,4,1024,f)!=1024 || std::fclose(f))
      throw std::runtime_error("source row read failed");
  };
  read(source/"input_f32.bin",x.data());
  read(source/"gamma_f32.bin",g.data());
  for(unsigned i=960;i<992;i++) g[i]=std::bit_cast<float>(0x71800000u);
  float mean=0,variance=0,inverse=0;
  const auto r=laya::layernorm_row_arithmetic(laya::Op::LN_EMB,0,
                x.data(),g.data(),1,y.data(),mean,variance,inverse);
  if (!r) throw std::runtime_error("modified LN should remain finite");
  unsigned first_bad=32;
  for(unsigned group=0;group<32;group++) {
    float amax=0;
    for(unsigned lane=0;lane<32;lane++)
      amax=std::max(amax,std::fabs(y[group*32+lane]));
    const float scale=amax/127.0f;
    if (scale>65504.0f && first_bad==32) first_bad=group;
  }
  if(first_bad!=30) throw std::runtime_error("late half-scale error not group30");
  FILE* f=std::fopen(output.c_str(),"w");
  if(!f) throw std::runtime_error("open output");
  for(float v:y) std::fprintf(f,"%08x\n",std::bit_cast<uint32_t>(v));
  if(std::fclose(f)) throw std::runtime_error("close output");
  std::printf("LNQ_LATE_REF_PASS first_bad_group=%u first_bad_col=%u mean=%08x var=%08x inv=%08x\n",
    first_bad,first_bad*32,std::bit_cast<uint32_t>(mean),
    std::bit_cast<uint32_t>(variance),std::bit_cast<uint32_t>(inverse));
}
