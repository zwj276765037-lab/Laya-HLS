#include "laya_full_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

using namespace laya;

static void require(bool ok, const char* what) {
  if (!ok) { std::cerr << "FULL_EMBEDDING_FAIL " << what << '\n'; std::exit(1); }
}

int main() {
  unsigned cases = 0;
  uint8_t raw[1088] = {};
  float y[1024];
  for (unsigned g = 0; g < 32; ++g) {
    raw[g * 34] = 0x00; raw[g * 34 + 1] = 0x3c; // FP16 1.0
    for (unsigned i = 0; i < 32; ++i)
      raw[g * 34 + 2 + i] = uint8_t(int(i) - 16);
  }
  require(bool(full::embedding_row(raw, y)), "valid Q8 row");
  for (unsigned g = 0; g < 32; ++g)
    for (unsigned i = 0; i < 32; ++i)
      require(y[g * 32 + i] == float(int(i) - 16), "group/feature order");
  ++cases;

  raw[32 * 34 - 1] = 127;
  raw[0] = 0x01; raw[1] = 0x00; // minimum positive FP16 subnormal
  require(bool(full::embedding_row(raw, y)) && y[0] == -16.0f * 0x1p-24f &&
          y[1023] == 127.0f, "FP16 subnormal and final group");
  ++cases;

  raw[0] = 0x00; raw[1] = 0x7c; // +Inf
  require(full::embedding_row(raw, y).code == Status::E_NUMERICAL,
          "reject nonfinite scale");
  ++cases;
  raw[0] = 0x00; raw[1] = 0xbc; // -1
  require(full::embedding_row(raw, y).code == Status::E_NUMERICAL,
          "reject negative scale");
  ++cases;
  raw[0] = 0x00; raw[1] = 0x3c;
  raw[2] = 0x80; // -128 outside this model's Q8-F domain
  require(full::embedding_row(raw, y).code == Status::E_NUMERICAL,
          "reject out-of-domain Q8 value");
  ++cases;
  std::cout << "FULL_EMBEDDING_PASS cases=" << cases << '\n';
}
