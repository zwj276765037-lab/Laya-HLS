#include <cstdint>
#include <cstdlib>
#include <initializer_list>
#include <iostream>

extern "C" void full_cache_packing_pilot(uint8_t, uint32_t, uint32_t, bool,
                                           int32_t*, uint32_t*);

namespace {
void require(bool good, const char* message) {
  if (!good) {
    std::cerr << "CACHE_PACKING_PILOT_FAIL " << message << '\n';
    std::exit(1);
  }
}
int32_t read(uint8_t target, uint32_t index) {
  int32_t result = -999;
  uint32_t status = 99;
  full_cache_packing_pilot(target, index, 0, false, &result, &status);
  require(status == 0, "read status");
  return result;
}
void write(uint8_t target, uint32_t index, uint32_t value) {
  int32_t result = -999;
  uint32_t status = 99;
  full_cache_packing_pilot(target, index, value, true, &result, &status);
  require(status == 0, "write status");
}
} // namespace

int main() {
  require(read(2, 0) == ((255 << 8) | 6), "cold metadata defaults");
  for (uint32_t index : {0u, 6u, 7u, 8u, 9u, 5373950u, 5373951u})
    require(read(0, index) == 0, "cold Q8 zero");
  for (uint32_t index : {0u, 2u, 3u, 4u, 5u, 167934u, 167935u})
    require(read(1, index) == 0, "cold scale zero");

  write(0, 0, uint32_t(-128));
  write(0, 7, uint32_t(-1));
  write(0, 8, 127);
  write(0, 5373951u, uint32_t(-37));
  require(read(0, 0) == -128 && read(0, 7) == -1 &&
          read(0, 8) == 127 && read(0, 5373951u) == -37,
          "signed Q8 first/word boundary/last readback");
  require(read(0, 6) == 0 && read(0, 9) == 0 &&
          read(0, 5373950u) == 0, "Q8 neighbors preserved");

  write(1, 0, 0x8001u);
  write(1, 3, 0xffffu);
  write(1, 4, 0x1234u);
  write(1, 167935u, 0xabcdu);
  require(read(1, 0) == 0x8001 && read(1, 3) == 0xffff &&
          read(1, 4) == 0x1234 && read(1, 167935u) == 0xabcd,
          "scale first/word boundary/last bit pattern");
  require(read(1, 2) == 0 && read(1, 5) == 0 &&
          read(1, 167934u) == 0, "scale neighbors preserved");

  int32_t result = -999;
  uint32_t status = 0;
  full_cache_packing_pilot(0, 5373952u, 1, true, &result, &status);
  require(status == 1 && read(0, 5373951u) == -37, "Q8 upper bound");
  full_cache_packing_pilot(1, 167936u, 1, true, &result, &status);
  require(status == 1 && read(1, 167935u) == 0xabcd, "scale upper bound");
  std::cout << "CACHE_PACKING_PILOT_PASS q8=8 scale=4 cold_and_boundaries\n";
  return 0;
}
