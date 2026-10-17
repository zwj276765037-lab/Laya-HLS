#include "laya_numeric.h"

#include <array>
#include <bit>
#include <cstdint>
#include <cstdio>
#include <filesystem>
#include <limits>
#include <stdexcept>
#include <string>

namespace fs = std::filesystem;

static void write_words(const fs::path& path, const uint32_t* words, size_t n) {
  FILE* f = std::fopen(path.c_str(), "w");
  if (!f) throw std::runtime_error("open fixture");
  for (size_t i = 0; i < n; ++i) std::fprintf(f, "%08x\n", words[i]);
  if (std::fclose(f)) throw std::runtime_error("close fixture");
}

int main(int argc, char** argv) {
  if (argc != 2) return 2;
  fs::create_directories(argv[1]);
  std::array<float,1024> x{}, gamma{}, y{};
  std::array<uint32_t,1024> bits{};
  std::array<uint32_t,6*5> meta{};
  for (unsigned c=0; c<6; ++c) {
    x.fill(0.0f);
    switch(c) {
      case 0:
        x[1000]=x[1022]=std::bit_cast<float>(0xff7fffffu);
        x[1023]=std::bit_cast<float>(0x7f7fffffu);
        break;
      case 1:
        x[0]=std::bit_cast<float>(0x7f7fffffu);
        x[1]=std::bit_cast<float>(0xff7fffffu);
        break;
      case 2: x.fill(1.0f); break;
      case 3:
        for (unsigned i=0; i<1024; ++i) x[i]=(i&1) ? -1.0f : 1.0f;
        break;
      case 4:
        for (unsigned i=0; i<1024; ++i)
          x[i]=(i&1) ? 1048576.25f : 1048576.0f;
        break;
      case 5:
        for (unsigned i=0; i<1024; ++i)
          x[i]=(i&1) ? -std::numeric_limits<float>::denorm_min() :
                         std::numeric_limits<float>::denorm_min();
        break;
    }
    for (unsigned i=0; i<1024; ++i) bits[i]=std::bit_cast<uint32_t>(x[i]);
    write_words(fs::path(argv[1])/("x"+std::to_string(c)+".mem"),bits.data(),bits.size());
    float mean=0.0f,variance=0.0f,inverse=0.0f;
    const auto r=laya::layernorm_row_arithmetic(laya::Op::LN_FFN,0,
                 x.data(),gamma.data(),0,y.data(),mean,variance,inverse);
    meta[c*5+0]=static_cast<uint32_t>(r.code);
    meta[c*5+1]=r ? 0xffffffffu : static_cast<uint32_t>(r.bad_element);
    meta[c*5+2]=std::bit_cast<uint32_t>(mean);
    meta[c*5+3]=std::bit_cast<uint32_t>(variance);
    meta[c*5+4]=std::bit_cast<uint32_t>(inverse);
    for (unsigned i=0; i<1024; ++i) bits[i]=std::bit_cast<uint32_t>(y[i]);
    write_words(fs::path(argv[1])/("y"+std::to_string(c)+".mem"),bits.data(),bits.size());
    std::printf("LN_EDGE_REF case=%u status=%u bad=%u mean=%08x variance=%08x inverse=%08x\n",
      c,meta[c*5],meta[c*5+1],meta[c*5+2],meta[c*5+3],meta[c*5+4]);
  }
  write_words(fs::path(argv[1])/"meta.mem",meta.data(),meta.size());
  if (meta[0]!=6 || meta[1]!=0 || meta[5]!=6 || meta[6]!=0 ||
      meta[4*5+2]!=0x49800001u || meta[4*5+3]!=0x3c800000u ||
      meta[4*5+4]!=0x40ffeb0au || meta[5*5+2]!=0 ||
      meta[5*5+3]!=0 || meta[5*5+4]!=0x439e1d28u)
    throw std::runtime_error("independent edge reference mismatch");
  std::puts("LN_EDGE_REF_PASS cases=6");
}
