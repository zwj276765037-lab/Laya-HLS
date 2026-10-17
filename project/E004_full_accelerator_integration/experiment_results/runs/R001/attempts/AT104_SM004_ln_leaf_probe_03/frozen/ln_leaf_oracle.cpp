#include <array>
#include <bit>
#include <cmath>
#include <cstdint>
#include <cstdio>
int main() {
  constexpr std::array<uint32_t,16> a = {
    0x3f800000,0x40400000,0xbf400000,0x3eaaaaab,
    0x00800000,0x00000001,0x3f000000,0x40800000,
    0x3dcccccd,0xc0000000,0x3f7fffff,0x7f7fffff,
    0x3f123456,0x41234567,0x00012345,0x3f800001
  };
  constexpr std::array<uint32_t,16> b = {
    0x44800000,0x3f800000,0x40000000,0x3f000000,
    0x3f800000,0x3f800000,0x3d800000,0x40400000,
    0x3e800000,0x3fc00000,0x3f000000,0x3f000000,
    0x3f654321,0x3f800000,0x3f800000,0x3f000000
  };
  for(size_t i=0;i<a.size();i++) {
    volatile float x=std::bit_cast<float>(a[i]), y=std::bit_cast<float>(b[i]);
    volatile float m=x*y, d=x/y, s=::sqrtf(y);
    std::printf("%08x %08x %08x %08x %08x\n",a[i],b[i],
      std::bit_cast<uint32_t>(float(m)),std::bit_cast<uint32_t>(float(d)),
      std::bit_cast<uint32_t>(float(s)));
  }
}
